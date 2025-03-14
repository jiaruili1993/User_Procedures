#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.




////////////////////////////////////////////////////////////////////////////////
// Remove whitespace from start of string
Function/S RemoveLeadingWhitespace(str)
  String str
  do
    String firstChar= str[0]
    if( CmpStr(firstChar," ") == 0 )
      str= str[1,inf]
    else
      break
    endif  
  while(1) 
  return str
End
////////////////////////////////////////////////////////////////////////////////
// Remove whitespace from end of string
Function/S RemoveEndingWhitespace(str)
  String str 
  do
    String str2= RemoveEnding(str," ")
    if( CmpStr(str2, str) == 0 )
      break
    endif
    str= str2
  while(1)
  return str
End


////////////////////////////////////////////////////////////////////////////////
// Function to smooth waves that have NaNs in them without messing them up
// Basically it is a gaussian smooth on each region bracketed by NaNs
// If -1 < FixFactor <= 0 just do a normal gaussian smooth on each region. 
// If FixFactor > 0 the region endpoints will be fixed by mixing the smoothed
// and unsmoothed data, the rate this mixing falls off away from the endpoints
// is controlled by FixFactor (smaller number -> sharper falloff)
// If FixFactor <= -1 then wrap each subsection (/E = 1)
function/S SmoothWithNaN(inputwave,smoothfactor,fixfactor)
  wave/D inputwave
  variable smoothfactor, fixfactor
  string outname = nameofwave(inputwave)+"_smth"
  Duplicate/O inputwave $outname
  wave output = $outname
  variable i, jmin, jmax, insection = 0
  if(numtype(inputwave[0]) != 2)
    insection = 1
    jmin = 0
  endif
  for(i=1; i<dimsize(inputwave,0); i++)
    if(numtype(inputwave[i]) == 2 && !insection)
      // current is NaN, last is NaN, do nothing
      insection = 0
    elseif(numtype(inputwave[i]) != 2 && !insection)
      // current is not NaN, previous was, start counting
      insection = 1
      jmin = i
    elseif((numtype(inputwave[i]) == 2 && insection) || i==dimsize(inputwave,0)-1)
      // current is NaN, last was not, ended a section
      insection = 0
      jmax = i-1
      duplicate/O/FREE/R=[jmin,jmax] inputwave smth
      duplicate/O/FREE/R=[jmin,jmax] inputwave nosm
      if(fixFactor > 0)
        smooth smoothfactor, smth
        duplicate/O/FREE/R=[jmin,jmax] inputwave mixed
        variable Nm = dimsize(mixed,0)-1
        variable/D A = Nm^2/4.0
        mixed = (p*(Nm-p)/A)^fixfactor*smth[p] + (1-(p*(Nm-p)/A)^fixfactor)*nosm[p]
        output[jmin,jmax] = mixed[p-jmin]
      elseif(fixfactor > -1)
        smooth smoothfactor, smth
        output[jmin,jmax] = smth[p-jmin]
      else
        smooth/E=3 smoothfactor, smth
        output[jmin,jmax] = smth[p-jmin]
      endif
    endif
  endfor
End

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

Function MDsort(w,keycol, [reversed])
// For some insane reason igor lacks a built in function to do this.
// I mean even Microsoft Excel can do this, how can igor not???
// https://www.wavemetrics.com/code-snippet/sorting-2d-waves-using-one-column-key
    Wave w
    variable keycol, reversed
    
    variable type
    
    type = Wavetype(w)
 
    make/Y=(type)/free/n=(dimsize(w,0)) key
    make/free/n=(dimsize(w,0)) valindex
    
    if(type == 0)
        Wave/t indirectSource = w
        Wave/t output = key
        output[] = indirectSource[p][keycol]
    else
        Wave indirectSource2 = w
        multithread key[] = indirectSource2[p][keycol]
    endif
    
    valindex=p
    if(reversed)
        sort/a/r key,key,valindex
    else
        sort/a key,key,valindex
    endif
    
    if(type == 0)
        duplicate/free indirectSource, M_newtoInsert
        Wave/t output = M_newtoInsert
        output[][] = indirectSource[valindex[p]][q]
        indirectSource = output
    else
        duplicate/free indirectSource2, M_newtoInsert
        multithread M_newtoinsert[][] = indirectSource2[valindex[p]][q]
        multithread indirectSource2 = M_newtoinsert
    endif 
End

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

function rebin2D(inputwavex, binfactor,[yaxis])
  wave inputwavex
  variable binfactor
  variable yaxis  // Set this to 1 if you want to rebin along the y (1) 
                  // axis. By default rebinning is along the x (0) axis
  yaxis = paramisdefault(yaxis) ? 0 : yaxis
  variable numpts, newpts
  binfactor = ceil(binfactor)
  
  duplicate/O/FREE inputwavex inputwave
  if(yaxis == 1)
    Matrixtranspose inputwave
  endif
  // Perform the Rebinning
  if(binfactor > 0)
    numpts = dimsize(inputwave,0)
    newpts = floor(numpts/binfactor)
    // Make a new wave of the right size
    string outname = nameofwave(inputwavex)+"_bin"
    Make/O/N=(newpts,dimsize(inputwave,1)) $outname
    wave output = $outname
    // Put in the points
    variable i,j,k
    variable temp
    for(i=0; i<dimsize(inputwave,1); i++)
      for(j=0; j<newpts; j++)
        temp = 0
        for(k=0; k<binfactor; k++)
          temp = temp + inputwave[j*binfactor+k][i]
        endfor
        output[j][i] = temp/binfactor
      endfor
    endfor
    // Finally, coppy over the wave scaling
    setscale/P x, dimoffset(inputwave,0),dimdelta(inputwave,0)*(numpts/newpts), output
    setscale/P y, dimoffset(inputwave,1),dimdelta(inputwave,1), output
    if(yaxis == 1)
      Matrixtranspose output
    endif
  else
    print "Binfactor needs to be a positive integer"
  endif
End

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Function to remove rows from a 2D wave that have NANs in them
Function remove_blank_rows(inwave)
	wave inwave

	variable nrows = dimsize(inwave,0)  // includes NaN rows
	variable ncols = dimsize(inwave,1)
	Redimension /N=(nrows*ncols) inwave
	WaveTransform zapNaNs  inwave
	variable nrows2 = numpnts(inwave)/ncols // always divisable by ncols
	Redimension /N=(nrows2, ncols) inwave
end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

function rebin1D(inputwave, binfactor)
  wave inputwave
  variable binfactor
  variable numpts, newpts
  binfactor = ceil(binfactor)
  if(binfactor > 0)
    numpts = dimsize(inputwave,0)
    newpts = floor(numpts/binfactor)
    // Make a new wave of the right size
    string outname = nameofwave(inputwave)+"_bin"
    Make/D/O/N=(newpts) $outname
    wave output = $outname
    // Put in the points
    variable i,j,k
    variable temp
    for(j=0; j<newpts; j++)
      temp = 0
      for(k=0; k<binfactor; k++)
        temp = temp + inputwave[j*binfactor+k]
      endfor
      output[j] = temp/binfactor
    endfor
  setscale/P x, dimoffset(inputwave,0), dimdelta(inputwave,0)*binfactor, output
  else
    print "Binfactor needs to be a positive integer"
  endif
End

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

Function FindClosest1D(wave1D,value)
  // Returns the index of the wave with the value closest to input value
  wave wave1D
  variable value
  Duplicate/FREE wave1D tmpwave
  sort tmpwave,tmpwave
  variable maxi = dimsize(tmpwave,0)-1
  // First handle cases where value is outside wave
  if(value < tmpwave[0])
    return 0
  elseif(value > tmpwave[maxi])
    return maxi
  elseif(1)
    findLevel/P/Q tmpwave,value
    variable closei = round(V_LevelX)
    if(min(closei,maxi-closei,1)==0)
      return closei
    else
      variable besti = closei, i
      // Search the closest three neighbors to crossing, if not on end
      for(i=closei-1;i<closei+2;i++)
        if(abs(tmpwave[i]-value) < abs(tmpwave[besti]-value))
          besti = i
        endif
      endfor
      FindValue/T=1.0E-30/V=(tmpwave[besti]) wave1D
      return V_value
    endif
  endif
  // This should never happen
  Return NaN
END
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
Function FindIndexAbove(wave1D,value)
  wave Wave1D    // 1D wave of values assumed to be in increasing order
  variable value // Value to search for
  variable i
  for(i=0; i<dimsize(Wave1D,0);i++)
    if(value < Wave1D[i])
      return i
    endif
  endfor
  return dimsize(Wave1D,0)-1  // If we reach the end just return end value +1  
END
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
Function CsrDist()
  return sqrt((vcsr(A)-vcsr(B))^2 + (hcsr(A)-hcsr(B))^2)
END
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////  
  
Function LoadHDF5File()
    Variable fileID
    HDF5OpenFile /I/R fileID as ""
    if (V_Flag != 0)
        return -1       // User cancelled
    endif
    HDF5LoadGroup /O /R /T=TempHDF5Data root:, fileID , "." // Load entire file into root:TempHDF5Data
    HDF5CloseFile fileID
    return 0            // Success
End  

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

Function SuperRound(number,digits)                   
  // round values to selectable number of digits
  // Taken from : https://www.wavemetrics.com/code-snippet/rounding-values-defined-number-significant-digits
  Variable number, digits
   
  String StrNumber
  Variable Multiplier, i                           // multiplier decides how much the decimal spot is "shifted" for rounding
  if (number < 1)                              // separate numbers whether they are < or > 1
    sprintf StrNumber, "%.10f", number           // express the number as text to work with it
    for (i = 2; i < Strlen(StrNumber); i += 1)
      if(StringMatch(StrNumber[i],"0") == 0)       // find the first non-zero number
        Multiplier = 10^(2 - i - digits)
        break
      endif
    endfor
  else
    sprintf StrNumber, "%d", number              // express the number as text to count the digits
    Multiplier = 10^(strlen(StrNumber) - digits)
  endif
  if (Multiplier < 1)                          // countermeasure for rounding errors when dividing by small numbers
    Multiplier = 1/Multiplier
    number = round(number*Multiplier)/Multiplier   
  else
    number = round(number/Multiplier)*Multiplier
  endif
    return number
End

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


Function DigitRound(number,digits)
  variable number
  variable digits
  // Round the number to the desired number of decimal points.
  if(number == 0)
    return 0
  else
    variable sign = round(number / abs(number))
    variable unsigned = abs(number)
    variable integer_part = floor(unsigned)
    variable decimal_part = unsigned-integer_part
    variable decimal_round = round(decimal_part*10^digits)
    return sign*(integer_part+decimal_round/10^digits)
  endif
END

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

function RealSpaceConv(spectrum, convwv)
  // Takes two scaled 1-D waves, spectrum and convwv and convolves the former with the
  // latter.  The output is plotted at the same points as the input spectrum. For the 
  // edge cases spectrum is extended as a constant outside of the specified range.  
  // For the purposes of the convolution spectrum will be lineraly interpolated onto the 
  // grid specified by convwv.
  wave spectrum, convwv
  
  // Generate the output wave
  string nameout = nameofwave(spectrum)+"_cnv"
  duplicate/O spectrum $nameout
  wave output = $nameout
  
  variable i
  for(i=0; i<dimsize(spectrum,0); i++)
    // Perform the convolution point by point, this can be done in parallel
    multithread output = paraconv(spectrum,convwv,p)
  endfor
  
END


threadsafe function paraconv(spectrum,convwv,pp)
  wave spectrum, convwv
  variable pp
  
  duplicate/O/FREE convwv convtmp
  variable NN = dimsize(spectrum,0)
  variable aa = dimoffset(spectrum,0)
  variable bb = aa+dimdelta(spectrum,0)*(NN-1)
  variable x0 = aa+pp*dimDelta(spectrum,0)
  setscale/P x, dimoffset(convwv,0)+x0, dimdelta(convtmp,0), convtmp
  duplicate/O/FREE convtmp spectmp
  spectmp = x>aa ? ( x<bb ? spectrum(x) : spectrum[NN-1]) : spectrum[0]
  convtmp = convtmp[p]*spectmp[p]
  
  return Area(convtmp)
END

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////



Function strMatchFront(str, matchstr)
  // Return 1 if the matchstr appears at the start of str and 0 otherwise
  string str, matchstr
  variable matchlen = strlen(matchstr)
  if(matchlen <= strlen(str))
    return stringmatch(str[0,matchlen-1],matchstr)
  else
    return 0
  endif
  return 0 // Just to be sure
END

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

Function/T strGetStartInt(str)
  // Return a string of numbers (not incl. a decimal) that starts off the string
  // Is this function stupid? Yes. Does this function work?  Also yes.
  string str
  string numstr = ""
  string tmpstr = ""
  variable strlenv = strlen(str)
  variable i,j
  for(i=0; i<strlen(str); i++)
    tmpstr = str[i]
    for(j=0; j<10; j++)
      if(stringmatch(tmpstr,num2str(j)))
        numstr = numstr+tmpstr
        break;
      endif
    endfor
    if(j>9)
      break;
    endif
  endfor
  return numstr
END

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

Function strIsAValidFloat(str)
  // Return 1 if str is of the form Integer.Integer and 0 otherwise
  string str
  
  string FirstBlock = strGetStartInt(str)
  string dec = str[strlen(FirstBlock)]
  string remains = str[strlen(FirstBlock)+1,strlen(str)-1]
  string SecondBlock = strGetStartInt(remains)
  if(strlen(FirstBlock)>0 && StringMatch(dec,".") && strlen(SecondBlock)>0  && strlen(SecondBlock)==strlen(remains))
    return 1
  else
    return 0
  endif
  return 0 // Just to be sure
END

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

Function/T strDecimalToP(str)
  // Take a string of the form Integer.Integer and replce the decimal with a P
  // This is for using floats in wave names because Igor doesn't like "." in them
  // Returns the word "Failure" if str isn't of the correct form.  If the string is
  // just an integer (with no decimal point) then it just returns it as is.
  string str
  string FirstBlock = strGetStartInt(str)
  if(strlen(FirstBlock) == strlen(str))
    return FirstBlock
  elseif(strlen(str) > strlen(FirstBlock)+1) 
    string dec = str[strlen(FirstBlock)]
    string remains = str[strlen(FirstBlock)+1,strlen(str)-1]
    string SecondBlock = strGetStartInt(remains)
    if(strlen(FirstBlock)>0 && StringMatch(dec,".") && strlen(SecondBlock)>0  && strlen(SecondBlock)==strlen(remains))
      return FirstBlock+"p"+SecondBlock
    else
      print "Failure in replacing \".\" with \"p\" due to incorrect format"  
      return "Failure"
    endif
  else
    print "Failure in replacing \".\" with \"p\" due to incorrect format"
    return "Failure"
  endif
END


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

Function CharictarizePeak(Wave1D)
  wave Wave1D  // Must be a 1D wave
  if(dimsize(wave1D,1)>0)
    print "Must be a 1D wave"
    return 0;
  endif
  variable i
  variable N = dimsize(Wave1D,0)
  
  // First find the maximum value and it's position
  wavestats/Q Wave1D
  variable maxval = V_max
  variable minval = V_min
  variable maxind = V_maxRowLoc
  variable maxxxx = V_maxloc
  variable maxxxx_fit = 0
  variable maxval_fit = 0
  // Next try to get a slightly better estimate from fitting
  // Select a somewhat arbitrary range to fit over
  variable rightindex, leftindex=0;
  variable tempval = 0;
  for(i=maxind; i<N; i++)
    tempval = Wave1D[i]
    if((tempval-minval) < (maxval-minval)*0.85)
      rightindex = i
      break;
    endif
  endfor
  for(i=maxind; i>-1; i--)
    tempval = Wave1D[i]
    if((tempval-minval) < (maxval-minval)*0.85)
      leftindex = i
      break;
    endif
  endfor
  CurveFit/Q gauss Wave1D[leftindex,rightindex] /D 
  wave W_coef;
  maxxxx_fit = W_coef[2]
  maxval_fit = W_coef[0]+W_coef[1]
  // Ok, now let's find the FHXM values for different values of X
  Variable FWHM = GetPeakFWXM(Wave1D, 0.500)
  Variable FWTM = GetPeakFWXM(Wave1D, 0.333)
  Variable FWQM = GetPeakFWXM(Wave1D, 0.250)
  // Finally print all this stuff for the user
  //print("Peak position is at "+num2str(maxxxx,"%.5f")+" or "+num2str(maxxxx_fit,"%.5f")+" from a fit")
  //print("Width at half max is "+num2str(FWHM,"%.5f")+", third max "+num2str(FWTM,"%.5f")+", quarter max "+num2str(FWQM,"%.5f"))
END 

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

function GetPeakFWXM(Wave1D, XX)
  // Get the Full Width "X" Max of a peak, where X is a specified fraction from 0 to 1
  // For instance, XX=0.5 corresponds to the FWHM
  // This code is very simple and could probably be improved to make it more reliable
  // N.B. We take the minimum value of the curve as a baseline and subtract it in this calc.
  wave Wave1D  // Must be a 1D wave
  variable XX  // Must be a number in (0,1)
  if(dimsize(wave1D,1)>0 || XX<=0 || xx>=1)
    print "Must be a 1D wave and XX must be strictly between 0 and 1"
    return 0;
  endif
  variable i
  variable N = dimsize(Wave1D,0)  
  // First find the maximum value and it's position
  wavestats/Q Wave1D
  variable maxval = V_max;       variable minval = V_min
  variable maxind = V_maxRowLoc; variable maxxxx = V_maxloc
  variable maxxxx_fit = 0;       variable maxval_fit = 0
  // Next try to get a slightly better estimate from fitting
  // Select a somewhat arbitrary range to fit over
  variable rightindex, leftindex=0;
  variable tempval = 0;
  for(i=maxind; i<N; i++)
    tempval = Wave1D[i]
    if((tempval-minval) < (maxval-minval)*0.95)
      rightindex = i; 
      break;
    endif
  endfor
  for(i=maxind; i>-1; i--)
    tempval = Wave1D[i]
    if((tempval-minval) < (maxval-minval)*0.95)
      leftindex = i; 
      break;
    endif
  endfor
  CurveFit/Q/W=2 gauss Wave1D[leftindex,rightindex]
  wave W_coef
  maxxxx_fit = W_coef[2]
  maxval_fit = W_coef[0]+W_coef[1] 
  // If the estimate maxval is more then 10% difference from the actual max val
  // the fit was probably not reliable so let's just use the measured max val
  if(abs(maxval_fit-maxval) > 0.1*(maxval-minval))
    maxval_fit = maxval
  endif
  variable searchval = XX*(maxval_fit-minval)+minval
  // Now repeat that above procedure to find where the peak drops to below XX*maxval_fit
  for(i=maxind; i<N; i++)
    tempval = Wave1D[i]
    if(tempval < searchval)
      rightindex = i; 
      break;
    endif
  endfor
  for(i=maxind; i>-1; i--)
    tempval = Wave1D[i]
    if(tempval < searchval)
      leftindex = i; 
      break;
    endif
  endfor
  // Armed with our candidates we look back one point and try to get a better estimate
  variable x0= dimOffset(Wave1D,0)+dimDelta(Wave1D,0)*rightindex; variable y0=Wave1D(x0);
  variable x1=x0-dimDelta(Wave1D,0);                              variable y1=Wave1D(x1);
  variable rightEST = x0+(searchval-y0)*(x1-x0)/(y1-y0)
  x0= dimOffset(Wave1D,0)+dimDelta(Wave1D,0)*leftindex; y0=Wave1D(x0);
  x1=x0+dimDelta(Wave1D,0);                              y1=Wave1D(x1);
  variable leftEST = x0+(searchval-y0)*(x1-x0)/(y1-y0)
  
  return rightEST-leftEST
END

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

function GetPeakWidthAtValue(Wave1D, HH)
  // Get the Full Width at height "HH" of a peak, where H is a fixed value
  // This code is very simple and could probably be improved to make it more reliable
  wave Wave1D  // Must be a 1D wave
  variable HH  // Must be a number b/w the wavemax and wavemin
  // First find the maximum value and it's position
  wavestats/Q Wave1D
  variable maxval = V_max;       variable minval = V_min
  variable maxind = V_maxRowLoc; variable maxxxx = V_maxloc
  variable maxxxx_fit = 0;       variable maxval_fit = 0
  if(dimsize(wave1D,1)>0 || HH<=minval || HH>=maxval)
    print "Must be a 1D wave and HH must be between the min and max"
    return 0;
  endif
  variable i
  variable N = dimsize(Wave1D,0)  
  variable rightindex, leftindex, tempval=0;
  variable searchval = HH
  // Now repeat that above procedure to find where the peak drops to below XX*maxval_fit
  for(i=maxind; i<N; i++)
    tempval = Wave1D[i]
    if(tempval < searchval)
      rightindex = i; 
      break;
    endif
  endfor
  for(i=maxind; i>-1; i--)
    tempval = Wave1D[i]
    if(tempval < searchval)
      leftindex = i; 
      break;
    endif
  endfor
  // Armed with our candidates we look back one point and try to get a better estimate
  variable x0= dimOffset(Wave1D,0)+dimDelta(Wave1D,0)*rightindex; variable y0=Wave1D(x0);
  variable x1=x0-dimDelta(Wave1D,0);                              variable y1=Wave1D(x1);
  variable rightEST = x0+(searchval-y0)*(x1-x0)/(y1-y0)
  x0= dimOffset(Wave1D,0)+dimDelta(Wave1D,0)*leftindex; y0=Wave1D(x0);
  x1=x0+dimDelta(Wave1D,0);                              y1=Wave1D(x1);
  variable leftEST = x0+(searchval-y0)*(x1-x0)/(y1-y0)
  
  return rightEST-leftEST
END

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

Function CorrelateSpectra(wA, wB, [XStart, XEnd])
	Variable XStart, XEnd  // Region to crop both waves before correlating (X values not points)
	WAVE wA,wB  // Spectra A and B (1-D waves).  
	            // "A" is the reference spectrum, not exactly symmetric
	            // the output of this is the shift that must be applied to wB to best match wA
	            // For an average one would want to do AVG = 0.5*(wA(x) + wB(x-shift))
	Variable/G MaxLocX, delta, shift
	Variable offset_a, offset_b, start_b, end_b, start_a, end_a
	offset_a=DimOffset(wA,0)
	delta=DimDelta(wA,0)
	offset_b=DimOffset(wB,0)
	// Duplicate to avoid overwriting
	Duplicate/O wB, wave_corr_xx
	Duplicate/O wA, wave_src_xx

	// cut away outside regions
	If(!ParamIsDefault(XStart))
	  start_b=x2pnt(wB,XStart);end_b=x2pnt(wB,XEnd)
	  start_a=x2pnt(wA,XStart);end_a=x2pnt(wA,XEnd)
			
	  wave_corr_xx[,start_b]=0
	  wave_corr_xx[end_b,]=0
			
      wave_src_xx[,start_a]=0
      wave_src_xx[end_a,]=0
	EndIf
   // find correlation maximum, and then find the peak position
	Correlate wave_src_xx, wave_corr_xx
	WaveStats/Q wave_corr_xx
	MaxLocX=V_maxloc
	Execute "FindAPeak  0,1,3, wave_corr_xx (MaxLocX-10*delta,MaxLocX+10*delta)"
	NVAR pl=V_peakX
	// limit the shift to one digit more than delta
	// this is enough for most cases in RIXS spectra, not generally applicable!!!
	Shift=offset_a-pl
	// Output Stuff
	string outstring = nameofwave(wA)+nameofWave(wB)+"_corr"
	setscale/P x, offset_a-dimoffset(wave_corr_xx,0), -dimdelta(wave_corr_xx,0), wave_corr_xx
	duplicate/O wave_corr_xx $outstring
	display $outstring
	SetDrawEnv xcoord= bottom;
   DrawLine Shift,0,Shift,1
   SetDrawEnv xcoord= bottom;
   DrawLine offset_a-MaxLocX,0,offset_a-MaxLocX,1
	Print NameOfWave(wB), "needs to be offset by", Shift,"relative to", nameofwave(wA), "based on fit.  Raw value is", offset_a-MaxLocX
	killwaves/Z wave_corr_xx, wave_src_xx
	Return Shift
End