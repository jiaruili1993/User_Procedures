#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later



////////////////////////////////////////////////////////////////////////////////
////////  _______ _________            _______ _________          _______  /////
//////// (  ____ \\__   __/|\     /|  (  ____ )\__   __/|\     /|(  ____ \ /////
//////// | (    \/   ) (   ( \   / )  | (    )|   ) (   ( \   / )| (    \/ /////
//////// | (_____    | |    \ (_) /   | (____)|   | |    \ (_) / | (_____  /////
//////// (_____  )   | |     ) _ (    |     __)   | |     ) _ (  (_____  ) /////
////////       ) |   | |    / ( ) \   | (\ (      | |    / ( ) \       ) | /////
//////// /\____) |___) (___( /   \ )  | ) \ \_____) (___( /   \ )/\____) | /////
//////// \_______)\_______/|/     \|  |/   \__/\_______/|/     \|\_______) /////
///////                                                                   //////
////////////////////////////////////////////////////////////////////////////////

function SixRIXSLoadFolder([postfix,XAS])
  // This function automatically loads all SIX RIXS data (.hdf files) in the specified directory
  // The data is all dumped in a directory sharing the name of the opened file (plus a specified prefix)
  // Based on code from https://www.wavemetrics.com/code-snippet/load-all-files-directory and
  // https://www.wavemetrics.com/forum/general/reading-hdf5-files
  // !!Warning!! Assumes data file names are of the form  six-[SampleIds].hdf  if they are not of this 
  // form then the code will need to be modified.
  string postfix // This is the postfix to add to the folders, manily to express the points-per-pixel
  variable XAS   // Set to 1 if you are loading SIX XAS type data (different processing steps)
  if(paramisdefault(postfix))
    postfix = ""
  endif
  XAS = paramisdefault(XAS)? 0 : XAS  // By default is zero, treat as XAS if > 0
  //initialize loop variable
  variable i=0
  string wname,fname
   
  //Ask the user to identify a folder on the computer
  getfilefolderinfo/D/Q
  //Store the folder that the user has selected as a new symbolic path in IGOR called cgms
  newpath/O/Q cgms S_path

  //Create a list of all files that are .hdf files in the folder. -1 parameter addresses all files.
  string filelist= indexedfile(cgms,-1,".hdf")
  do
    //store the ith name in the list into wname.
    fname = stringfromlist(i,filelist)
    //strip away ".hdf" to get the name we will use for the directory
    // We also have to strip away the "six-" at the front and replace it with a "six_" instead
    // because Igor does not like having dashes in path names
    wname = "six_"+fname[4,strlen(fname)-5]
    Variable fileID
    HDF5OpenFile/R/P=cgms fileID as fname
    if (V_Flag != 0)
        return -1       // User cancelled
    endif
    KillDataFolder/Z TempHDF5DataXXX
    HDF5LoadGroup /O /R /T=TempHDF5DataXXX root:, fileID , "." // Load entire file into root:TempHDF5Data 
    HDF5CloseFile fileID
    NewDataFolder/O root:SIXdata  // If this doesn't already exist, create it
    string fn = "root:SIXdata:"+wname+"_"+postfix
    NewDataFolder/O $fn
    // Remove the temporary folder
    DuplicateDataFolder/O=2 root:TempHDF5DataXXX $fn
    KillDataFolder/Z TempHDF5DataXXX
    // Copy the important data to the upper folder
    variable ScanLen
    if(XAS == 0)
      string tmp1 = fn+":data:E_l"
      wave tmpwv = $tmp1; ScanLen = dimsize(tmpwv,0)
      string sLeft = fn+":Left"; string sRight = fn+":Right"; string sCenter = fn+":Center"
      string sLeft1D   = fn+":L_"+fname[4,strlen(fname)-5]+"_"+postfix
      string sRight1D  = fn+":R_"+fname[4,strlen(fname)-5]+"_"+postfix
      string sCenter1D = fn+":C_"+fname[4,strlen(fname)-5]+"_"+postfix
      make/O/N=(ScanLen) $sLeft1D; make/O/N=(ScanLen) $sRight1D; make/O/N=(ScanLen) $sCenter1D    
      make/O/N=(ScanLen,2) $sLeft; make/O/N=(ScanLen,2) $sRight; make/O/N=(ScanLen,2) $sCenter
      // Copy over RIXS data and collapse into 1D waves with reasonable but annoying names.
      wave Left = $sLeft;   wave Right = $sRight;   wave Center = $sCenter; 
      wave Left1D=$sLeft1D; wave Right1D=$sRight1D; wave Center1D=$sCenter1D
      tmp1 = fn+":data:E_l"; string tmp2 = fn+":data:rixs_l"; wave E = $tmp1; wave II = $tmp2
      Left[][0] = E[p]; Left[][1] = II[p]
      setscale/I x, Left[0][0], Left[ScanLen-1][0], Left1D
      Left1D = interp(x,E,II);
      tmp1 = fn+":data:E_r"; tmp2 = fn+":data:rixs_r"; wave E = $tmp1; wave II = $tmp2 
      Right[][0] = E[p]; Right[][1] = II[p]
      setscale/I x, Right[0][0], Right[ScanLen-1][0], Right1D
      Right1D = interp(x,E,II);
      tmp1 = fn+":data:E0"; tmp2 = fn+":data:rixs"; wave E = $tmp1; wave II = $tmp2
      Center[][0] = E[p]; Center[][1] = II[p]
      setscale/I x, Center[0][0], Center[ScanLen-1][0], Center1D
      Center1D = interp(x,E,II);
    elseif(XAS > 0)
      string Estring   = fn+":data:pgm_en"
      string cryoxS    = fn+":data:cryo_x"; string xS = fn+"cryo_x"
      string cryoyS    = fn+":data:cryo_y"; string yS = fn+"cryo_y"
      string cryozS    = fn+":data:cryo_z"; string zS = fn+"cryo_z"
      string I0string  = fn+":data:sclr_channels_chan8" // CH8 is I0
      string TEYstring = fn+":data:sclr_channels_chan6" // CH6 is TEY
      string TFYstring = fn+":data:sclr_channels_chan2" // CH2 is TFY
      string Units
      if(waveexists($Estring))    // If this is actually an XAS scan   
        wave EnergyIn = $Estring; ScanLen = dimsize(EnergyIn,0); Units = "Energy (eV)" 
      elseif(waveexists($cryoxS)) // Other types of scans I have encountered
        wave EnergyIn = $cryoxS; ScanLen = dimsize(EnergyIn,0); Units = "X (mm)"
      elseif(waveexists($cryoyS)) 
        wave EnergyIn = $cryoyS; ScanLen = dimsize(EnergyIn,0); Units = "Y (mm)"
      elseif(waveexists($cryozS))
        wave EnergyIn = $cryozS; ScanLen = dimsize(EnergyIn,0); Units = "Z (mm)"
      endif   
      if(waveexists($Estring) || waveexists($cryoxS) || waveexists($cryoyS) || waveexists($cryozS) )      
        string sI0  = fn+":I0_" +fname[4,strlen(fname)-5]
        string sTEY = fn+":TEY_"+fname[4,strlen(fname)-5]
        string sTFY = fn+":TFY_"+fname[4,strlen(fname)-5]
        make/O/N=(ScanLen) $sI0; make/O/N=(ScanLen) $sTEY; make/O/N=(ScanLen) $sTFY
        wave I0in = $I0string; wave TEYin = $TEYstring; wave TFYin = $TFYstring
        wave I0   = $sI0;      wave TEY = $sTEY;        wave TFY = $sTFY
        setscale/I x, EnergyIn[0], EnergyIn[ScanLen-1],Units, I0;  I0  = interp(x,EnergyIn,I0in)
        setscale/I x, EnergyIn[0], EnergyIn[ScanLen-1],Units, TEY; TEY = interp(x,EnergyIn,TEYin)
        setscale/I x, EnergyIn[0], EnergyIn[ScanLen-1],Units, TFY; TFY = interp(x,EnergyIn,TFYin)
      endif
    endif
    i += 1          //move to next file
  while(i<itemsinlist(filelist))
end


function SixRIXSCopyToRoot(ScanNums,[postfix,detector])
  wave/T ScanNums
  string postfix
  string detector // set this to "L", "R", or "C" to select the left, right or center detector
  if(paramisdefault(postfix))
    postfix = ""
  endif
  if(paramisdefault(detector))
    detector = "C"
  endif
  // ScanNums should be a Nx2 wave with the 1st and second file IDs corresponding to the scans
  if(dimsize(ScanNums,1)<2)
    print "ScanNums has the wrong dimesions, exiting."
    return 0;
  endif
  variable Nscans = dimsize(ScanNums,0)
  variable i
  // Also make a wavelist for what you just spit out for use in other stuff
  string WavelistName = "root:"+nameofwave(ScanNums)+"_"+postfix
  make/T/O/N=(Nscans) $WavelistName
  wave/T TheWavesWeMoved = $WavelistName
  for(i=0; i<Nscans; i++)
    string IDstring = ScanNums[i][0]+"_"+ScanNums[i][1]+"_"+postfix
    string inpath = "root:SIXdata:"+"six_"+IDstring+":"
    string outpath= "root:"
    string filename = detector+"_"+IDstring
    string inwave = inpath+filename
    string outwave = outpath+filename
//    print( IDstring)
//    print( inwave)
//    print( outwave)
    duplicate/O $inwave $outwave
    TheWavesWeMoved[i] = filename
  endfor
END

////////////////////////////////////////////////////////////////////////////////
/////////////////////// EU XFEL EU XFEL EU XFEL EU XFEL ////////////////////////
////////////////////////////////////////////////////////////////////////////////


//Function EUXFEL_RIXS_Load([postfix])
//  // This function automatically loads all EUXFEL data (.csv files) into the specified directory
//  // The data is all dumped in a sub-directory based on the name of the file 
//  // Based on code from https://www.wavemetrics.com/code-snippet/load-all-files-directory and
//  // https://www.wavemetrics.com/forum/general/reading-hdf5-files
//  // !!Warning!! This code makes a lot of assumptions about how the file name is structured to 
//  // extract information so be aware of that if you use it on anything else! 
//  string postfix // if you only want to load RIXS data with a specified points-per-pixel PPPX then
//                 // set postfix = Integer.Integer to be that resolution
//                 // For example: postfix=1.500 loads all the scans with 1.5 points-per-pixel. Note 
//                 // That this is done by string manipulation so all digits must match exactly.
//  if(paramisdefault(postfix))
//    postfix = ""
//  endif
//  // Ask the user to identify a folder on the computer
//  getfilefolderinfo/D/Q
//  //Store the folder that the user has selected as a new symbolic path in IGOR called cgms
//  newpath/O/Q cgms S_path
//  // Create a list of all files that are .csv files in the folder. -1 parameter addresses all files.
//  string filelist= indexedfile(cgms,-1,".csv")
//  // Initialize variables
//  variable i=0
//  string wname,fname,tmpstr
//  variable errorencountered = 0
//  for(i=0;i<itemsinlist(filelist);i++)
//    errorencountered = 0
//    //store the ith name in the list into wname.
//    fname = stringfromlist(i,filelist)
//    // This bit of the code is to strip off the important information about the scan from the file name
//    // It could certainly be done in a smarter way using some regular expressions and/or swtitch statements
//    // -- it is a shame I am not a smarter man. This will have to be rewritten if you are using a 
//    // different structure for the file name.  Sorry about that ...
//    string ScanType, DataType, ScanNum, Grating, PPPX  // Metadata we will extract from the file name 
//    // Determine the Scan Type (just RIXS for this one)
//    string remains = fname
//    if(strMatchFront(fname,"RIXS"))
//      ScanType = "RIXS"
//      remains = fname[strlen("RIXS_"),strlen(fname)-5]
//    else
//      errorencountered = 1
//    endif
//    // Next get the scan number
//    if(!errorencountered)
//      ScanNum = strGetStartInt(remains)
//      tmpstr = remains[strlen(ScanNum)+1,strlen(remains)-1]
//      if(strlen(ScanNum)>0)
//        remains = tmpstr
//      else
//        errorencountered = 1
//      endif
//    endif    
//    // Next the grating, "HIRES" or "HITHRU"
//    if(!errorencountered)
//      if(strMatchFront(remains,"HIRES"))
//        Grating = "HIRES"
//        tmpstr = remains[strlen("HIRES_"),strlen(remains)-1]
//        remains = tmpstr
//      elseif(strMatchFront(remains,"HITHRU"))
//        Grating = "HITHRU"
//        tmpstr = remains[strlen("HITHRU_"),strlen(remains)-1]
//        remains = tmpstr
//      else
//        errorencountered = 1
//      endif
//    endif
//    // Next we have to figure out how much is the points-per-pixel value
//    string FirstBlock, dec, SecondBlock, tempstr
//    if(!errorencountered)
//      FirstBlock = strGetStartInt(remains)
//      if(strlen(remains) > strlen(FirstBlock)+1) 
//        dec = remains[strlen(FirstBlock)]
//        tempstr = remains[strlen(FirstBlock)+1,strlen(remains)-1]
//        SecondBlock = strGetStartInt(tempstr) 
//        if(strlen(FirstBlock)>0 && StringMatch(dec,".") && strlen(SecondBlock)>0  && strlen(SecondBlock)<strlen(remains))
//          PPPX = FirstBlock+dec+SecondBlock
//          tempstr = remains[strlen(PPPX+"_"),strlen(remains)-1]
//          remains = tempstr
//        else
//          errorencountered = 1
//        endif
//      else
//        errorencountered = 1
//      endif
//    endif    
//    // Determine the Data Type: "E" or "I" or "Comb" -> for now we are ignoring the comb
//    if(!errorencountered && stringmatch(ScanType,"RIXS"))
//      if(strMatchFront(remains,"comb"))
//        DataType = "Comb"
//        tmpstr = remains[strlen("comb"),strlen(remains)-1]
//        remains = tmpstr
//      elseif(strMatchFront(remains,"eloss"))
//        DataType = "E"
//        tmpstr = remains[strlen("eloss"),strlen(remains)-1]
//        remains = tmpstr
//      elseif(strMatchFront(remains,"spect"))
//        DataType = "I"
//        tmpstr = remains[strlen("spect"),strlen(remains)-1]
//        remains = tmpstr
//      else
//        errorencountered = 1
//      endif   
//    else
//      errorencountered = 1
//    endif
//    // We only proceed if no errors in reading the file name were encountered
//    // and the PPPX was either unspecified or matches what we read
//    if(!errorencountered && (StringMatch(PPPX,postfix) || strlen(postfix) == 0) && !stringmatch(DataType,"Comb"))
//      // Finally!  Load that data!
//      wname = fname
//      Variable fileID
//      killwaves/Z xxtempxx0, xxtempxx1, xxtempxx2 // Make sure this wave is available
//      loadwave/P=cgms/Q/G/A='xxtempxx' fname
//      wave xxtempxx0
//      // Format Data and move to the specified folder based on metadata we 
//      // collected: ScanType, DataType, ScanNum, MCPType, PPPX
//      string basefolder = "root:EUXFEL_"+ScanType
//      NewDataFolder/O $basefolder // If this doesn't already exist, create it
//      string foldername = "root:EUXFEL_"+ScanType+":Scan_"+ ScanNum
//      NewDataFolder/O $foldername     // If this doesn't already exist, create it
//      string filename = foldername+":"+DataType + "_"+ScanNum+"_"+Grating+"_"+strDecimalToP(PPPX)
//      duplicate/O xxtempxx0 $filename
//      killwaves/Z xxtempxx0, xxtempxx1, xxtempxx2
//    endif
//  endfor
//END

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

//function DLSi21RIXSLoadFolder([XAS,StartID,EndID,LoadFromWave,ScanWave])
//  // This function automatically loads all DLS RIXS data (.hdf files) in the specified directory
//  // The data is all dumped in a directory sharing the name of the opened file (plus a specified prefix)
//  // Based on code from https://www.wavemetrics.com/code-snippet/load-all-files-directory and
//  // https://www.wavemetrics.com/forum/general/reading-hdf5-files
//  // !!Warning!! Assumes data file names are of the form  andor-[SampleId].hdf  if they are not of this 
//  // form then the code will need to be modified.
//  //string postfix // This is the postfix to add to the folders, manily to express the points-per-pixel
//  variable XAS   // Set to 1 if you are loading SIX XAS type data (different processing steps)
//  variable StartID // If you want to specify a range of files to load, not the entire folder
//  variable EndID   // Needed when specifying a range using the above.  Note that these are inclusive
//  variable LoadFromWave //This will ignore Start and End and instead look for values in ScanWave
//  wave     ScanWave     // Wave of ints, must be used in conjunction with LoadFromWave
//  if(paramisdefault(LoadFromWave))
//    LoadFromWave = 0
//  elseif(LoadFromWave>0 && !waveexists(ScanWave))
//    print "Specified *LoadFromWave* but did not provide an appropriate *ScanWave* to use"
//    print "Aborting."
//    return 0;
//  endif
//  XAS = paramisdefault(XAS)? 0 : XAS  // By default is zero, treat as XAS if > 0
//  StartID = paramisdefault(StartID) ? -99999999999 : StartID
//  EndID   = paramisdefault(EndID)   ?  99999999999 : EndID
//  //initialize loop variable
//  variable i=0
//  string wname,fname,IDstring
//  variable fileisloaded = 0
//   
//  //Ask the user to identify a folder on the computer
//  getfilefolderinfo/D/Q
//  //Store the folder that the user has selected as a new symbolic path in IGOR called cgms
//  newpath/O/Q cgms S_path
//
//  //Create a list of all files that are .hdf files in the folder. -1 parameter addresses all files.
//  string filelist= indexedfile(cgms,-1,".hdf")
//  do
//    //store the ith name in the list into wname.
//    fname = stringfromlist(i,filelist)
//    //strip away ".hdf" to get the name we will use for the directory
//    // We also have to strip away the "andor-" at the front and replace it with a "DLS_" instead
//    // because Igor does not like having dashes in path names
//    IDstring = fname[6,strlen(fname)-5]
//    wname = "DLS_"+IDstring
//    variable SampleID = str2num(IDstring)
//    Variable fileID  // Numeric id for the file    
//    variable WeCareAboutThisFile = 0
//    if(LoadFromWave > 0)
//      WeCareAboutThisFile = IsInScanWave(SampleID,ScanWave)
//    else
//      WeCareAboutThisFile = (SampleID >= StartID && SampleID <= EndId)
//    endif
//    if(WeCareAboutThisFile)
//      HDF5OpenFile/R/P=cgms fileID as fname
//      if (V_Flag != 0)
//          return -1       // User cancelled
//      endif
//      KillDataFolder/Z TempHDF5DataXXX
//      HDF5LoadGroup /O /R /T=TempHDF5DataXXX root:, fileID , "." // Load entire file into root:TempHDF5Data 
//      HDF5CloseFile fileID
//      NewDataFolder/O root:DLSdata  // If this doesn't already exist, create it
//      string fn = "root:DLSdata:"+wname
//      NewDataFolder/O $fn
//      // Remove the temporary folder
//      DuplicateDataFolder/O=2 root:TempHDF5DataXXX $fn
//      KillDataFolder/Z TempHDF5DataXXX
//      fileisloaded = 1 // Indicate this was loaded
//    else
//      fileisloaded = 0 // Indicate that we skipped this file
//    endif
//    
//    // Copy the important data to the upper folder and do some basic manipulations
//    // Note that we have to do a transposition of the 3D matrix to get it into "normal"
//    // Igor form where the images are dimensions 0 and 1 and different scans are dim. 2
//    variable ScanLen
//    if(XAS == 0 && fileisloaded)
//      string datafile  = fn+":entry:data:data"
//      string Units
//      string temp = fn+":d"+IDstring
//      duplicate/O $datafile  $temp
//      wave WierdIndex = $temp
//      MatrixOP xxxtempxxx=transposeVol(WierdIndex,4)
//      duplicate/O xxxtempxxx $temp
//      killwaves/Z xxxtempxxx
//    endif
//    i += 1          // Move on to the next file
//  while(i<itemsinlist(filelist))
//end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

Function IsInScanWave(SampleID,ScanWave)
  // Very simple helper function to see if an int number is in a specified wave
  // only works properly for integers since it uses string-matching
  variable SampleID  // Must be an INTEGER
  wave     ScanWave  // Must be a wave of integers
  string IDString = num2str(SampleID)//, "%.0f")
  variable TheTruth = 0
  variable i
  for(i=0; i<dimsize(ScanWave,0); i++)
    string WaveString = num2str(ScanWave[i])//,"%.0f")
    if(stringmatch(IDString,WaveString))
      TheTruth = 1
      return TheTruth
    endif
  endfor
  return TheTruth
END


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

Function ProcessDLSi21(ScanName,dispersion,slope,[Tlow,Tmid,Thigh])
  string ScanName  // This should be a number, as a string: e.g. "387722"
  variable dispersion  // in eV/px
  variable slope  // in px/px, slope of elastic line in px along energy axis / px along "other" axis
  variable Tlow,Tmid,Thigh  // Low and High thresholding parameters 
  Tlow = paramIsDefault(Tlow)?  333 : Tlow
  Tmid = paramIsDefault(Tmid)?  500 : Tmid
  Thigh = paramIsDefault(Thigh)? 666 : Thigh  // Some defaults that work well for my data, YMMV

  string TheFolderName = "root:DLSdata:DLS_"+ScanName
  string TheWaveName   = "d"+ScanName
  string Input         = TheFolderName+":"+TheWaveName
  string Output        = "root:"+TheWaveName
  // Check the wave exists
  if(!waveexists($Input))
    print "Scan ",Input," does not exist, exiting"
    return 0;
  endif
  // Copy the raw Data to the root directory
  duplicate/O $Input $Output
  wave RawData = $Output
  // Move to the root directory for the following calculations
  SetDataFolder root:
  // Make a histogram of the counts (for reference later to check the thresolding was sensible)
  variable Wmax = wavemax(RawData)
  variable Wmin = wavemin(RawData)
  variable Nbins = ceil((Wmax-Wmin)/2)
  string HistName = Output+"_h"
  make/O/N=(Nbins) $HistName
  wave hist = $HistName
  histogram RawData hist
  // Okay, time to do some thresholding.
  string ThreshName = Output+"_T"
  duplicate/O RawData $ThreshName
  wave ThreshData = $ThreshName
  ChrisNotSmartThresholding(ThreshData,Tlow,Tmid,Thigh)
  // Next we apply the slope correction to straighten the elastic line
  duplicate/O/FREE ThreshData xTempStraightx
  xTempStraightx = (x+slope*y>0 && x+slope*y<dimsize(ThreshData,0)-1) ? ThreshData(x+slope*y)(y)[r] : 0
  // Collapse over the "z" direction (i.e. average over sweeps per scan)
  if(dimsize(xTempStraightx,2)>0)
    sumdimension/D=2/DEST=XXTheSumWaveXX xTempStraightx
  else
    duplicate/O xTempStraightx XXTheSumWaveXX 
  endif
  // Make the 2D output wave
  string Name2D = Output+"_2D"
  duplicate/O XXTheSumWaveXX $Name2D
  wave Output2D = $Name2D
  multithread Output2D = Output2D[p][q] / (dimsize(ThreshData,2)+1)
  // Finally, make the 1D output
  sumdimension/D=1/DEST=XXTheSumWaveXX Output2D
  string Name1D = Output+"_1D"
  duplicate/O XXTheSumWaveXX $Name1D
  wave Output1D = $Name1D
  Output1D = Output1D[p] / (dimsize(ThreshData,1)+1)
  // And apply the px to eV scaling to both
  setscale/P x, 0, dispersion, Output2D
  setscale/P x, 0, dispersion, Output1D
     
  // Clean Up
  killwaves/Z XXTheSumWaveXX
END

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

Function ChrisNotSmartThresholding(thewave,Tlow,Tmid,Thigh)
  wave thewave   // Wave to "smart" threshold
  variable Tlow,Tmid,Thigh  // Threshold Parameters
  // Step 1 is to chop anything below the 95% of the Tlow threshold
  variable frac=0.95
  multithread thewave = thewave[p][q][r] < frac*Tlow  ? 0 : thewave[p][q][r]
  // Step 2 is to look between 95% and 100% of Tlow and eliminate any isolated pixels
  // A real strike should cover more then one pixel due to charge spreading
  variable Np = dimsize(thewave,0)
  variable Nq = dimsize(thewave,1)
  multithread thewave = Thresholding1(thewave,p,q,r,Np,Nq,Tlow)
  // Step 3 is to remove points above the high threshold, here we replace those by the average of neighbors
  duplicate/O thewave  XXXthewaveXXX
  multithread thewave = Thresholding2(XXXthewaveXXX,p,q,r,Np,Nq,Thigh)
  duplicate/O thewave  XXXthewaveXXX
  multithread thewave = Thresholding2(XXXthewaveXXX,p,q,r,Np,Nq,Thigh)
  killwaves/Z XXXthewaveXXX
  // Finally we look at those points in the range between Tmid and Thigh and remove only isolated points
  multithread thewave = Thresholding3(thewave,p,q,r,Np,Nq,Tmid)
END

////////// Helper functions for the above function //////////
threadsafe Function IsNotOnBoundary(pp,qq,ppmax,qqmax)
  variable pp, qq  // Coordinates
  variable ppmax, qqmax // Dimsize 0 and 1
  return (pp>0 && qq>0 && pp<ppmax-1 && qq<qqmax-1)
END
/////
threadsafe Function Thresholding1(thewave,pp,qq,rr,Np,Nq,Tlow)
  wave thewave
  variable pp,qq,rr,Np,Nq,Tlow
  if(IsNotOnBoundary(pp,qq,Np,Nq) && thewave[pp][qq][rr]<=Tlow)
    if(thewave[pp-1][qq][rr]<=0 && thewave[pp+1][qq][rr]<=0 && \
       thewave[pp][qq-1][rr]<=0 && thewave[pp][qq+1][rr]<=0 )
       return 0;
    else
       return thewave[pp][qq][rr];
    endif
  else
    return thewave[pp][qq][rr]
  endif
END
/////
threadsafe Function Thresholding2(thewave,pp,qq,rr,Np,Nq,Thigh)
  wave thewave
  variable pp,qq,rr,Np,Nq,Thigh
  if(thewave[pp][qq][rr]>Thigh)
    if(IsNotOnBoundary(pp,qq,Np,Nq))
      return 0.250*(thewave[pp-1][qq][rr]+thewave[pp+1][qq][rr]+thewave[pp][qq-1][rr]+thewave[pp][qq+1][rr])
    else
      return 0;
    endif
  else
    return thewave[pp][qq][rr]
  endif
END
/////
threadsafe Function Thresholding3(thewave,pp,qq,rr,Np,Nq,Tmid)
  wave thewave
  variable pp,qq,rr,Np,Nq,Tmid
  if(IsNotOnBoundary(pp,qq,Np,Nq) && thewave[pp][qq][rr]>Tmid)
    if(thewave[pp-1][qq][rr]<=0 && thewave[pp+1][qq][rr]<=0 && \
       thewave[pp][qq-1][rr]<=0 && thewave[pp][qq+1][rr]<=0 )
       return 0;
    else
       return thewave[pp][qq][rr];
    endif
  else
    return thewave[pp][qq][rr]
  endif
END

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

Function ProcessDLSscans(ScanWave,dispersion,slope,[Tlow,Tmid,Thigh,plot,plothists])
  wave ScanWave  // Wave of integers indicating the scans to be processed
  variable dispersion  // in eV / px
  variable slope       // in horizontal px / vertical px
  variable Tlow,Tmid,Thigh,plot,plothists
  Tlow = paramisdefault(Tlow)  ?  -1  : Tlow
  Tmid = paramisdefault(Tmid)  ? 1e10 : Tmid
  Thigh = paramisdefault(Thigh)? 1e10 : Thigh  
  // See "ChrisNotSmartThresholding" for param details.  For this function by default no
  // thresholding is applied so the user should explicitly add these
  plot = paramisdefault(plot) ? -1 : plot  // Plot the processed data
  plothists = paramisdefault(plothists) ? -1 : plothists  // Plot histograms of the raw data
  
  variable Nscans = dimsize(ScanWave,0)
  variable i, scan
  string scanS, name
  for(i=0; i<Nscans; i++)
    scan = ScanWave[i]; scanS = num2str(scan)//,"%.0f")
    ProcessDLSi21(scanS,dispersion,slope,Tlow=Tlow,Tmid=Tmid,Thigh=Thigh)
  endfor
  // Now make some plots
  if(plot>0)
    display;
    for(i=0;i<Nscans;i++)
      scanS = num2str(ScanWave[i])//,"%.0f");
      name = "d"+scanS+"_1D"
      appendtoGraph $name
    endfor
    makePlotNormal()
  endif
  if(plothists>0)
    display;
    for(i=0;i<Nscans;i++)
      scanS = num2str(ScanWave[i])//,"%.0f");
      name = "d"+scanS+"_h"
      appendtoGraph $name
    endfor
    makePlotNormal()
    ModifyGraph log=1,lblMargin=10;DelayUpdate
    Label left "Binned Counts";DelayUpdate
    Label bottom "Intensity"
  endif
END  

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

function DLSfitCarbon(CarbonScan1D,[FWHMs])
  wave CarbonScan1D  // The scan to use 
  variable FWHMs     // Determinse range over which to fit, # of FWHMs
  FWHMs = paramisdefault(FWHMs) ? 3 : FWHMs
  // Identify peak by the maximum value
  wavestats/Q CarbonScan1D
  variable maxpos = V_maxloc
  variable FWHM = GetPeakFWXM(CarbonScan1D, 0.5)
  variable fitmin = maxpos-0.5*(FWHMs*FWHM)
  variable fitmax = maxpos+0.5*(FWHMs*FWHM)
  // Fit a voigt over this region to get the best estimate of the peak position
  CurveFit/Q/W=2 Voigt CarbonScan1D(fitmin,fitmax)
  wave W_coef
  return W_coef[2]
  
  // Clean Up
  killwaves/Z W_sigma, W_coef
END

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

Function DLSFitCarbonSeries(ScanWave,[FWHMs])
  wave ScanWave
  variable FWHMs
  FWHMs = paramisdefault(FWHMs) ? 3 : FWHMs // How many FWHM to use in fit
  string OutName1 = nameofwave(ScanWave)+"_centers"
  string OutName2 = nameofwave(ScanWave)+"_FWHMs"
  duplicate/O ScanWave $OutName1
  duplicate/O ScanWave $OutName2
  wave Output1 = $Outname1
  wave Output2 = $Outname2
  
  variable Nscans, i
  string ScanS,ScanName
  Nscans = dimsize(ScanWave,0)
  for(i=0;i<Nscans;i++)
    scanS = num2str(ScanWave[i])//,"%.0f");
    ScanName = "d"+scanS+"_1D" 
    wave CarbonScan = $ScanName
    if(!waveexists(CarbonScan))
      print "Could not find wave ",ScanName," Exiting."
      return 0;
    endif
    Output1[i] = DLSfitCarbon(CarbonScan,FWHMs=3)
    Output2[i] = GetPeakFWXM(CarbonScan, 0.5)
  endfor
  // All Done
END

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

Function ShiftDLSandPlot(ScanWave,CarbonPositions,[plot])
  wave ScanWave,CarbonPositions
  variable plot
  plot=paramisdefault(plot) ? 1 : plot  // By default make a plot, if you don't want one set to zero
  if(dimsize(ScanWave,0) != dimsize(CarbonPositions,0))
    print "Mismatch in wave sizes, aborting."
    return 0;
  endif
  // Loop through all scans, copy the 1D waves and modify scaling of each
  // Then add to the plot 
  
  variable Nscans, i
  string ScanS,ScanNameIn, ScanNameOut
  Nscans = dimsize(ScanWave,0)
  if(plot>0)
    display;
  endif
  for(i=0;i<Nscans;i++)
    scanS = num2str(ScanWave[i])//,"%.0f");
    ScanNameIn  = "d"+scanS+"_1D"
    ScanNameOut = "d"+scanS+"_Shft"
    duplicate/O $ScanNameIn $ScanNameOut
    wave input  = $ScanNameIn
    wave output = $ScanNameOut
    setscale/P x, dimoffset(input,0)-CarbonPositions[i], dimdelta(input,0), output
    if(plot>0)
      appendtograph output
    endif
  endfor
  if(plot>0)
    MakePlotNormal()
    settraceOffsets(VerticalOffset=6)
    ModifyGraph width=283.465,height=425.197
    ModifyGraph fSize=10,lblMargin=10,manTick(bottom)={0,5,0,0},manMinor(bottom)={4,0}
    SetAxis bottom 2,-20
    Label left "RIXS Intensity (arb. u.)"
    Label bottom "Energy Loss (eV)"
  endif
  // All Done
END

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

Function CleanDLS(ScanWave,[raw,T,h,D1,D2])
  wave ScanWave          // Scans to loop over
  variable raw,T,D2,h,D1 // Remove these data?
  raw = paramisdefault(raw) ? 0 : raw
  T   = paramisdefault(T)   ? 0 : T
  h   = paramisdefault(h)   ? 0 : h   
  D1  = paramisdefault(D1)  ? 0 : D2
  D2  = paramisdefault(D2)  ? 0 : D1  
  variable Nscans, i
  string ScanS,ScanRAW, ScanT, Scanh, ScanD1, ScanD2
  Nscans = dimsize(ScanWave,0)
  for(i=0;i<Nscans;i++)
    scanS = num2str(ScanWave[i])//,"%.0f");
    ScanRAW = "d"+scanS
    ScanT   = "d"+scanS+"_T"
    Scanh   = "d"+scanS+"_h"
    ScanD1  = "d"+scanS+"_1D"
    ScanD2  = "d"+scanS+"_2D"
    if(raw>0)
      killwaves/Z $ScanRAW
    endif 
    if(T>0)
      killwaves/Z $ScanT
    endif 
    if(h>0)
      killwaves/Z $Scanh
    endif 
    if(D1>0)
      killwaves/Z $ScanD1
    endif 
    if(D2>0)
      killwaves/Z $ScanD2
    endif
  endfor
END

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
Function DLSmakeStringWave(ScanNumbers)
  wave ScanNumbers  // Wave of integer scan numbers
  variable Nscans = dimsize(ScanNumbers,0)
  string InwaveS = nameofwave(ScanNumbers)
  string OutwaveS = InwaveS+"_str"
  make/O/T/N=(Nscans) $OutwaveS
  wave/T Output = $OutwaveS
  variable i
  for(i=0; i<Nscans; i++)
    Output[i] = "d"+num2str(ScanNumbers[i])+"_Shft"  //,"%.0f"
  endfor
END
  