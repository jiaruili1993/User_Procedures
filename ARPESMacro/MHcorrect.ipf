#pragma rtGlobals=1		// Use modern global access method and strict wave access.


Function MHAuBGFitInitialize()

	DFREF svDF = GetDataFolderDFR()
	
	NewDataFolder/O/S root:Packages:MHAuBGFit
		Make/O/D wData, wGaussian, wFit,  wComp, wEpsilon, W_Sigma, wtFit, wGaussian2
		Make/O/D runpw, wsigma, wcoef, wTestFit, xwTestFit, xwFit
		Make/O/D/N=13 pw,wHold
		Make/O/D W_ParamConfidenceInterval
						
		Variable/G v_FitOptions = 4
		Variable/G v_FitTol = 1e-5
		Variable/G GaussWidth, dNpt, gNpt
	
	SetDataFolder svDF
End	


Function MHAuBackgroundFunc(pw, yw, xw) : FitFunc
	//pw[0]: FD const
	//pw[1]: FD slope
	//pw[2]: FD EF
	//pw[3]: FD temperature
	//pw[4]: main Gaussian width
	//pw[5]: Gaussian BG intensity
	//pw[6]: Gaussian BG position
	//pw[7]: Gaussian BG width 
	//pw[8]: Lor+Gauss BG intensity
	//pw[9]: Lor+Gauss BG position
	//pw[10]: Lor+Gauss BG Lor width
	//pw[11]: Lor+Gauss BG  Gauss width
	//pw[12]: 2nd Gaussian BG intensity
	//pw[13]: 2nd Gaussian BG position
	//pw[14]: 2nd Gaussian BG width 
	//pw[15]: 3rd Gaussian BG intensity
	//pw[16]: 3rd Gaussian BG position
	//pw[17]: 3rd Gaussian BG width 
	//pw[18]: constant
	//pw[19]: analyzer resolution
	
	Wave pw, yw, xw

	DFREF svDF = GetDataFolderDFR()	
	SetDataFolder root:Packages:MHAuBGFit	

	Wave wFit //= root:Packages:MHAuBGFit:wFit
	Wave wtFit //= root:Packages:MHAuBGFit:wtFit
	Wave wData //= root:Packages:MHAuBGFit:wData	
	Wave wGaussian //= root:Packages:MHAuBGFit:wGaussian		
	Wave wGaussian2 //= root:Packages:MHAuBGFit:wGaussian2
	
	
	Variable kB = 8.617342e-5
	Variable i
	
	wtFit = wData(x) - pw[18]//hv profile
	wtFit = wtFit(x) * (x<=0.25)
	
	wFit =  (pw[0] + pw[1] * x)/(exp((x-pw[2])/(kB*pw[3]))+1) //+ pw[12]//gold edc
	
	wGaussian = Gauss(x, 0, pw[4]/(2*(sqrt(2*ln(2)))))*DimDelta(wGaussian,0)//for main Gaussian
	convolve/A wGaussian, wFit//resolution convolved gold edc
	

	wGaussian2=Gauss(x, 0, pw[11]/(2*(sqrt(2*ln(2)))))*DimDelta(wGaussian2,0) 
	wGaussian = pw[8]*(pw[10]/(2*pi)) / ((x-pw[9])^2+pw[10]^2/4) //for Lorentzian+Gaussian BG
	convolve/A wGaussian2, wGaussian //lorentz convolved gaussian peak

	wGaussian += pw[5] * Gauss(x, pw[6], pw[7]/(2*(sqrt(2*ln(2))))) 	// for Gaussian BG	
	
	wGaussian += pw[12] * Gauss(x, pw[13], pw[14]/(2*(sqrt(2*ln(2))))) 	// for 2nd Gaussian BG	
	
	wGaussian += pw[15] * Gauss(x, pw[16], pw[17]/(2*(sqrt(2*ln(2))))) 	// for 2nd Gaussian BG	

//	wGaussian += Gauss(x, 0, pw[4]/(2*(sqrt(2*ln(2)))))//for main Gaussian

	wGaussian *= DimDelta(wGaussian,0)
//	convolve/A wGaussian, wFit
	
	For(i=0;i<11;i+=1)
		convolve/A wGaussian, wtFit	
		wFit += (-1)^i * wtFit(x)
	EndFor		

	wGaussian=Gauss(x, 0, pw[19]/(2*(sqrt(2*ln(2)))))*DimDelta(wGaussian,0)
	convolve/A wGaussian, wFit
	
	wFit += pw[18]

	yw =  wFit(xw[p])
	
	SetDataFolder svDF		
End


Function	MHAuBGFit(w, pw, hw, s,e, guess [, C])
	Wave w, pw, hw
	Variable s, e, guess
	Wave/T C
	
	DFREF svDF = GetDataFolderDFR()	
	SetDataFolder root:Packages:MHAuBGFit	
	
	Wave wFit
	Wave W_ParamConfidenceInterval
	Wave wGaussian

	Duplicate/O/D w, wData
	Duplicate/O/D pw runpw
//	Duplicate/O/D 
//	wtFit = wData(x)		
	
	Nvar width = GaussWidth	
	width = pw[4]	* 10	
	Variable delta =DimDelta(w,0)/MHCFitResults	

	MHMakeWavesGF(width, delta, s, e, 1)
	Duplicate/O/D wGaussian wGaussian2	
	Duplicate/O/D wFit, wtFit
//	wData = w(x)
	
	String holdstr = ""
	Variable v_FitError	=0
	
	Variable i
	
	for(i=0; i<DimSize(hw,0); i += 1)	
		holdstr += num2str(hw[i])					
	endfor		

	if(guess)
		Duplicate/O/D/R=(s,e) wData wTestFit, xwTestFit
		xwTestFit = x	
		MHAuBackgroundFunc(pw,wTestFit,xwtestfit)
		
	else
		if(WaveExists(wConstrain))
			FuncFit/n/q/H=holdstr MHAuBackgroundFunc runpw  wData(s, e) /C=wConstrain
		else
			FuncFit/n/q/H=holdstr MHAuBackgroundFunc runpw  wData(s, e) 
		endif
		
	  	if (v_FitError==0)
  			pw = runpw		
  			Duplicate/O/D/R=(s,e) wFit wTestFit	
  		else
  			print "Fit did not converge"
		endIf
	endIf
	
	SetDataFolder svDF
End


Function MHAuBackground2D(pw, w, f)
	Wave pw, w
	Variable f
	
	Variable i
	
	Make/O/D/N=(DimSize(w,0)) tw
	SetScale/P x DimOffset(w,0), DimDelta(w,0), tw

	For(i=0; i<DimSize(w,1);i+=1)		
//	For(i=0; i<5;i+=1)		
		tw = w[p][i]

//		Duplicate/O/D tw  root:Packages:MHAuBGFit:wData	
		MHAuBackground(pw, tw, f)
		w[][i] = tw[p]
	EndFor
	
	KillWaves tw
End
	

Function MHAuBackground(pw, w, f)
	Wave pw, w
	Variable f
	
	//pw[0]: FD const
	//pw[1]: FD slope
	//pw[2]: FD EF
	//pw[3]: FD temperature
	//pw[4]: main Gaussian width
	//pw[5]: Gaussian BG intensity
	//pw[6]: Gaussian BG position
	//pw[7]: Gaussian BG width 
	//pw[8]: Lor+Gauss BG intensity
	//pw[9]: Lor+Gauss BG position
	//pw[10]: Lor+Gauss BG Lor width
	//pw[11]: Lor+Gauss BG  Gauss width

	DFREF svDF = GetDataFolderDFR()	
	SetDataFolder root:Packages:MHAuBGFit	

//	Wave wFit// = root:Packages:MHAuBGFit:wFit
	Wave wGaussian //= root:Packages:MHAuBGFit:wGaussian		
	Wave wGaussian2 //= root:Packages:MHAuBGFit:wGaussian2		
//	Duplicate/O/D w wFit, wtFit	

	Nvar width = GaussWidth //= root:Packages:MHAuBGFit:GaussWidth	
	width = pw[4] * 10
	Variable delta =DimDelta(w,0)/MHCFitResults
	
	MHMakeWavesGF(width, delta, DimOffset(w,0), DimOffset(w,0)+DimDelta(w,0)*DimSize(w,0), 1)
	Wave wFit
	Duplicate/O/D wFit, wtFit

	Variable kB = 8.617342e-5
	Variable i	
	
	
	wFit = 0
	wtFit = w(x)
//	wtFit = wtFit(x) * (x<=0.2)
//	wtFit = w(x)
	
	
	wGaussian2=Gauss(x, 0, pw[11]/(2*(sqrt(2*ln(2)))))*DimDelta(wGaussian2,0) 
	wGaussian = pw[8]*(pw[10]/(2*pi)) / ((x-pw[9])^2+pw[10]^2/4) //for Lorentzian+Gaussian BG
	convolve/A wGaussian2, wGaussian
	
//	wGaussian *= f

	wGaussian += pw[5] * Gauss(x, pw[6], pw[7]/(2*(sqrt(2*ln(2)))))*f	// for Gaussian BG

	wGaussian += pw[12] * Gauss(x, pw[13], pw[14]/(2*(sqrt(2*ln(2))))) 	// for 2nd Gaussian BG	

	wGaussian += pw[15] * Gauss(x, pw[16], pw[17]/(2*(sqrt(2*ln(2))))) 	// for 2nd Gaussian BG	

	wGaussian *= DimDelta(wGaussian,0)	
	
//	wGaussian *= f
	

	For(i=0;i<11;i+=1)
		convolve/A wGaussian, wtFit	
		wFit += (-1)^i * wtFit(x)
	EndFor
	
	wGaussian=Gauss(x, 0, 0.0065/(2*(sqrt(2*ln(2)))))*DimDelta(wGaussian,0)
	convolve/A wGaussian, wFit


	w -= wFit(x)
	SetDataFolder svDF	

End

Function MHBGDeconvolve_old(w,BGpar,f)
	Wave w, BGpar
	Variable f
	
	Variable i
	
	Make/O/D/N=(DimSize(w,0)) tw
	SetScale/P x DimOffset(w,0), DimDelta(w,0), tw

	For(i=0; i<DimSize(w,1);i+=1)		
		tw = w[p][i]
		MHBGDeconvolve_core_old(BGpar, tw, f)
		w[][i] = tw[p]
	EndFor
End

Function MHBGDeconvolve_core_old(pw, w, f)
	Wave pw, w
	Variable f
	
	//pw[0]: FD const
	//pw[1]: FD slope
	//pw[2]: FD EF
	//pw[3]: FD temperature
	//pw[4]: main Gaussian width
	//pw[5]: Gaussian BG intensity
	//pw[6]: Gaussian BG position
	//pw[7]: Gaussian BG width 
	//pw[8]: Lor+Gauss BG intensity
	//pw[9]: Lor+Gauss BG position
	//pw[10]: Lor+Gauss BG Lor width
	//pw[11]: Lor+Gauss BG  Gauss width
	//pw[12]: Gaussian BG intensity
	//pw[13]: Gaussian BG position
	//pw[14]: Gaussian BG width 
	//pw[15]: Gaussian BG intensity
	//pw[16]: Gaussian BG position
	//pw[17]: Gaussian BG width 
	//pw[19]: Analyzer resolution


	DFREF svDF = GetDataFolderDFR()	
	SetDataFolder root:Packages:MHAuBGFit	
	Wave wGaussian
	Wave wGaussian2 
	Nvar width = GaussWidth
	width = pw[4] * 10
	Variable delta =DimDelta(w,0)/MHCFitResults
	
	MHMakeWavesGF(width, delta, DimOffset(w,0), DimOffset(w,0)+DimDelta(w,0)*DimSize(w,0), 1)
	Wave wFit
	Duplicate/O/D wFit, wtFit

	Variable kB = MHCkB_SI
	Variable i	
	
	
	wFit = 0
	
//	wtFit = w(xoutofrange(w,x,0))
	wtFit = w(x)

		
	
	wGaussian2=Gauss(x, 0, pw[11]/(2*(sqrt(2*ln(2)))))*DimDelta(wGaussian2,0) 
	wGaussian = pw[8]*(pw[10]/(2*pi)) / ((x-pw[9])^2+pw[10]^2/4) //for Lorentzian+Gaussian BG
	convolve/A wGaussian2, wGaussian
	
	wGaussian += pw[5] * Gauss(x, pw[6], pw[7]/(2*(sqrt(2*ln(2)))))*f	// for Gaussian BG

	wGaussian += pw[12] * Gauss(x, pw[13], pw[14]/(2*(sqrt(2*ln(2))))) 	// for 2nd Gaussian BG	

	wGaussian += pw[15] * Gauss(x, pw[16], pw[17]/(2*(sqrt(2*ln(2))))) 	// for 3rd Gaussian BG	

	wGaussian *= DimDelta(wGaussian,0)	
	
	wGaussian *= f
	

	For(i=0;i<7;i+=1)
		convolve/A wGaussian, wtFit	
		wFit += (-1)^i * wtFit(x)
	EndFor
	
	wGaussian=Gauss(x, 0, pw[19]/(2*(sqrt(2*ln(2)))))*DimDelta(wGaussian,0)
	convolve/A wGaussian, wFit


	w -= wFit(x)
	SetDataFolder svDF	

End