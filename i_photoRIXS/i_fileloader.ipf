#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 2.00
#pragma ModuleName = fileloader
#pragma IgorVersion = 5.0

// structure of the i_photo file-loader:
//
// (i) hook-function gets the path and filename
// (ii) the open file is passed to the 'filetype' function, which recognizes the type of the file, closes the file and calls a function to load the data
// (iii) the individual loader-functions call an aquisition-software specific string-function returning the header-info in a form suitable for wave notes.
// (the skeleton of the wave-note (all values blank) is defined in the 'fileloader_NoteKeyList' function)
//
//	All intensities are normalized with the aquisition time. Default units are 'eV' and 'deg'.
//
//																								FB 11/7/02, modified 05/12/03
// 12-22-03 loader currently works for: 
//		SES-text files (single and multiple regions)
//		SES-igor files
//		VG1Z-files
//		CCDOPS binary files
//		jpeg/tif-files























//////////////////////////////////////
//
// Public functions
//
//////////////////////////////////////























Function BeforeFileOpenHook(refnum, filename, symPath, type, creator, kind)
	
	Variable	refnum, kind
	String 		filename, symPath, type, creator
	
	SetDataFolder root:
	
	string s_runNB 
	
	if( stringmatch(filename,"_trRIXSi_*.csv") == 1)
		
		s_runNB = filename[9,strsearch(filename,".csv",0)-1]
		
		LoadWave/A/W/O/P=$(symPath)/G filename
		Import_trRIXS(str2num(s_runNB),"_i")
				
		close refnum
		
		return 1
	elseif( stringmatch(filename,"_trRIXSc_*.csv") == 1)
	
		s_runNB = filename[9,strsearch(filename,".csv",0)-1]
		
		LoadWave/A/W/O/P=$(symPath)/G filename
		Import_trRIXS(str2num(s_runNB),"_c")
				
		close refnum
		
		return 1
	elseif( stringmatch(filename,"_RIXSi_*.csv") == 1)
		
		s_runNB = filename[8,strsearch(filename,".csv",0)-1]
		
		LoadWave/A/W/O/P=$(symPath)/G filename
		Import_RIXSi(str2num(s_runNB))
				
		close refnum
		
		return 1
	elseif( stringmatch(filename,"_RIXSc_*.csv") == 1)
		
		s_runNB = filename[8,strsearch(filename,".csv",0)-1]
		
		LoadWave/A/W/O/P=$(symPath)/G filename
		Import_RIXSc(str2num(s_runNB))
		
		KillWaves/Z energy,hRIXS_delay,hRIXS_index,spectrum
		
		close refnum
		
		return 1	
	elseif(stringmatch(filename,"_XAS*.csv") == 1)
		s_runNB = filename[5,strsearch(filename,".csv",0)-1]
		LoadWave/A/W/O/P=$(symPath)/J filename
		
		Import_XAS(str2num(s_runNB))
		
		close refnum
		
		return 1

	
	elseif(stringmatch(filename,"_RIXS_nonAgg_*.csv") == 1)

		
		KillWaves/Z tempWave0
		
		s_runNB = filename[13,strsearch(filename,".csv",0)-1]
		print s_runNB
		LoadWave/A=tempWave/G/M/D/P=$(symPath) filename
		
		Import_RIXS_nonAgg(str2num(s_runNB))
		
		close refnum
		KillWaves/Z tempWave0
		return 1
	endif
	
End



// For time-resolved RIXS
Function Import_trRIXS(runNumber, type)
	Variable runNumber
	String type
	
	Newdatafolder/o root:RawRIXS
	
	// These must be imported from csv
	Wave energy, hRIXS_index, spectrum, hRIXS_delay, hRIXS_norm
	
	// Determine number of delays by number of hRIXS indices
	WaveStats/Q hRIXS_index
	Variable numDelays = V_max + 1
	
	// Number of energies = total size / numDelays
	Variable numEnergies = DimSize(energy,0) / numDelays
	
	// Generate trRIXS wave
	String sName
	sprintf sName, "_%04.f",runNumber
	sName = "trRIXS" + sName + type
	
	Make/O/N=(numDelays,numEnergies) $(sName)
	Wave newWave = $(sName)
	
	// Determine energy scaling
	WaveStats/Q energy
	Variable minE = V_min
	Variable maxE = V_max
	SetScale/I y,minE, maxE, newWave
	
	// Determine delay scaling
	WaveStats/Q hRIXS_delay
	SetScale/I x,V_min, V_max, newWave
	
	//Generate delay wave
	Make/O/N=(numDelays) delays_tmp
	delays_tmp[] = hRIXS_delay[p*numEnergies]
	
	//Generate norm wave
	Make/O/N=(numDelays) norm_tmp
	norm_tmp[] = hRIXS_norm[p*numEnergies]
	
	sprintf sName, "root:RawRIXS:delay_%04.f",runNumber
	Duplicate/O delays_tmp, $(sName)
	sprintf sName, "root:RawRIXS:norm_%04.f",runNumber
	Duplicate/O norm_tmp, $(sName)
	
	KillWaves/Z delays_tmp, norm_tmp
	
	newWave[][] = spectrum[mod(q,numEnergies) + p*numEnergies]
	
	
	// Wei-Sheng's request: save a separate wave for each delay
	Variable ii
	For(ii=0; ii<numDelays; ii+=1)
		sprintf sName, "_%04.f_%03.f",runNumber,ii
		sName = "root:RawRIXS:RIXS"+type + sName
		Make/O/N=(numEnergies) $(sName)
		Wave singleRIXS = $(sName)
		singleRIXS = spectrum[mod(p,numEnergies) + ii*numEnergies]
		SetScale/I x,minE, maxE, singleRIXS
	EndFor
	
	// Cleanup
	KillWaves/Z energy, hRIXS_index, spectrum, hRIXS_delay, hRIXS_norm
	
	// Remove this line if you want the 2D wave
	KillWaves/Z newWave
End

// For static RIXS (integrated)
Function Import_RIXSi(runNumber)
	Variable runNumber
	
	// These must be imported from csv
	Wave energy, spectrum
	
	
	// Number of energies = total size 
	Variable numEnergies = DimSize(energy,0) 
	
	// Generate trRIXS wave
	String sName
	sprintf sName, "RIXS_%04.f_i",runNumber
	
	Make/O/N=(1,numEnergies) $(sName)
	Wave newWave = $(sName)
	
	// Determine energy scaling
	WaveStats/Q energy
	SetScale/I y,V_min, V_max, newWave
	
	newWave[][] = spectrum
End

// For static RIXS (centroid)
Function Import_RIXSc(runNumber)
	Variable runNumber
	
	// These must be imported from csv
	Wave energy, spectrum
	
	
	// Number of energies = total size
	Variable numEnergies = DimSize(energy,0) 
	
	// Generate trRIXS wave
	String sName
	sprintf sName, "RIXS_%04.f_c",runNumber
	
	Make/O/N=(1,numEnergies) $(sName)
	Wave newWave = $(sName)
	
	// Determine energy scaling
	WaveStats/Q energy
	SetScale/I y,V_min, V_max, newWave
	
	newWave[][] = spectrum
End



// Works for XAS or trXAS
Function Import_XAS(runNumber)
	Variable runNumber
	
	Wave counts, muA, muIo, nrj, sigmaA, sterrA, XWave
	
	String sName
	sprintf sName, "root:XAS_%04.f",runNumber
	
	String sNum
	sprintf sNum, "%04.f",runNumber
	
	WaveStats/Q nrj
	SetScale/I x,V_min,V_max, counts, muA, muIo, nrj, sigmaA, sterrA, XWave

	NewDataFolder/O $(sName)
	Duplicate/O counts, $(sname+":counts_"+sNum)
	Duplicate/O muA, $(sname+":muA_"+sNum)
	Duplicate/O muIo, $(sname+":muIo_"+sNum)
	Duplicate/O nrj, $(sname+":nrj_"+sNum)
	Duplicate/O sigmaA, $(sname+":sigmaA_"+sNum)
	Duplicate/O sterrA, $(sname+":sterrA_"+sNum)
	
	Wave yy = $(sname+":muA_"+sNum)
	
	Display yy
	
	KillWaves/Z counts, muA, muIo, nrj, sigmaA, sterrA, XWave
	
End


Function Import_RIXS_nonAgg(runNumber)
	Variable runNumber
	
	// These must be imported from csv
	Wave tempWave0
	
	// Generate trRIXS wave
	String sName
	sprintf sName, "RIXS_%04.f",runNumber
	
	Duplicate/O tempWave0, $(sName) 
	
End

Function ShiftAndCombine(runNBs,type)	
	Wave runNBs // wave containing the list of run numbers
	String type // "c" for centroid or "i" for integrated
	
	Variable numRuns = dimSize(runNBs,0)
	
	// Determine number of delays
	String sName
	sprintf sName, "root:RawRIXS:delay_%04.f",runNBs[0]

	Wave delayWave = $(sName)
	Variable numDelays = DimSize(delayWave,0)
	
	// check that all runs contain the same number of delays
	Variable nn
	For(nn=0; nn<numRuns; nn+=1)
		sprintf sName, "root:RawRIXS:delay_%04.f",runNBs[0]
		Wave delayWave = $(sName)
		if(dimSize(delayWave,0) != numDelays)
			print "Error: not all runs contain the same number of delays"
			return 0
		endif
		if(runNBs[nn] == 329)
			print "Run# 329 contains a problem with the normalization factors. This needs to be fixed before this code can run properly"
			return 0
		EndIf
	EndFor
	
	// Duplicate to processed folder
	Newdatafolder/o root:ShiftedRIXS
	Variable dd
	For(dd=0; dd<numDelays; dd+=1)
		For(nn=0; nn<numRuns; nn+=1)
			sprintf sName, "_%04.f_%03.f",runNBs[nn],dd
			sName = "root:RawRIXS:RIXS_"+type + sName
			Wave original = $(sName)
			sprintf sName, "_%04.f_%03.f",runNBs[nn],dd
			sName = "root:ShiftedRIXS:RIXS_"+type + sName
			Duplicate/O original, $(sName)
		EndFor
	EndFor
	
	
	// Initialize 2D wave
	// Process delay-by-delay
	For(dd=0; dd<numDelays; dd+=1)
		sprintf sName, "_%04.f_%03.f",runNBs[0],dd
		sName = "root:ShiftedRIXS:RIXS_"+type + sName
		Wave FirstRun = $(sName)
		
		For(nn=1; nn<numRuns; nn+=1)
			sprintf sName, "_%04.f_%03.f",runNBs[nn],dd
			sName = "root:ShiftedRIXS:RIXS_"+type + sName
			Wave ThisRun = $(sName)
			ShiftSpectra(FirstRun,ThisRun)
		EndFor
	EndFor
	
	// Now add them
	Newdatafolder/o root:MergedRIXS
	
	// Initialize 2D wave
	Variable numEnergies = DimSize(ThisRun,0)
	sprintf sName, "_%04.f_%04.f",runNBs[0],runNBs[numRuns-1]
	sName = "root:MergedRIXS:trRIXS_"+type+sName
	Make/O/N=(numDelays,numEnergies) $(sName)
	Wave Wave2D = $(sName)
	Wave2D = 0
	
	Variable Emin = DimOffset(ThisRun,0)
	Variable Edelt = DimDelta(ThisRun,0)
	SetScale/P y,Emin,Edelt, Wave2D
	
	Make/O/N=(numDelays) NormFactor
	NormFactor = 0
	
	For(nn=0; nn<numRuns; nn+=1)
		sprintf sName, "root:RawRIXS:norm_%04.f",runNBs[nn]
		Wave normWave = $(sName)	// Normalization wave
		For(dd=0; dd<numDelays; dd+=1)
		 	sprintf sName, "_%04.f_%03.f",runNBs[nn],dd
			sName = "root:ShiftedRIXS:RIXS_"+type + sName
			Wave ThisRun = $(sName)
			
			// Skip first 5 and last 5 pixels
		 	Wave2D[dd][5,numEnergies-5] += ThisRun[x2pnt(ThisRun,y)]
		 	NormFactor[dd] += normWave[dd]
		 EndFor
	EndFor
	
	wave2D[][] /= NormFactor[p]
	
	// Export 1D waves
	
	For(dd=0; dd<numDelays; dd+=1)
		sprintf sName, "_%04.f_%04.f_d%03.f",runNBs[0],runNBs[numRuns-1],dd
		sName = "root:MergedRIXS:RIXS_"+type + sName
		Make/O/N=(numEnergies) $(sName)
		Wave ThisRun = $(sName)
		ThisRun = Wave2D[dd][p]
		SetScale/P x,Emin,Edelt, ThisRun
	EndFor
		 	
	KillWaves/Z NormFactor
	
	print "Processed RIXS waves created in root:ShiftedRIXS: and root:MergedRIXS:"
End



// this is the holy hopefully static KeyWord-list for the wave-notes			// FB  05/19/03
//
// Made some changes in i_filetable.ipf. It contains now a keyword list 
// similar to this one. If you change something here, please change 
// also i_filetable.ipf.								// F.Schmitt 04/22/07
//
Function/S fileloader_NoteKeyList(data_type)
	Variable data_type	// 1=SES, 2=MacESCAII, 3=Croissant
	
	String keylist=""
	keylist+="WaveName=\r"
	keylist+="RawDataWave=\r"
	keylist+="FileName=\r"
	keylist+="Sample=\r"
	keylist+="Comments=\r"
	keylist+="StartDate=\r"
	keylist+="StartTime=\r"
	keylist+="Instrument=\r"
	keylist+="MeasurementSoftware=\r"
	keylist+="User=\r"
	keylist+="\r"
	
	keylist+="ManipulatorType=\r"
	keylist+="AnalyzerType=\r"
	keylist+="AnalyzerMode=\r"
	keylist+="XScanType=\r"
	keylist+="\r"
	
	keylist+="FirstEnergy=\r"
	keylist+="LastEnergy=\r"
	keylist+="NumberOfEnergies=\r"
	keylist+="InitialAlphaAnalyzer=\r"
	keylist+="FinalAlphaAnalyzer=\r"
	keylist+="InitialThetaManipulator=\r"
	keylist+="FinalThetaManipulator=\r"
	keylist+="OffsetThetaManipulator=\r"
	keylist+="InitialPhiManipulator=\r"
	keylist+="FinalPhiManipulator=\r"
	keylist+="OffsetPhiManipulator=\r"
	keylist+="InitialOmegaManipulator=\r"
	keylist+="FinalOmegaManipulator=\r"
	keylist+="OffsetOmegaManipulator=\r"
	keylist+="NumberOfManipulatorAngles=\r"
	keylist+="AngleSignConventions=\r"
	keylist+="\r"
	
	keylist+="PhotonEnergy=\r"
	keylist+="FermiLevel=\r"
	keylist+="SampleTemperature=\r"
	keylist+="WorkFunction=\r"
	keylist+="PassEnergy=\r"
	keylist+="DwellTime=\r"
	keylist+="NumberOfSweeps=\r"
	keylist+="\r"
	
//	if ( data_type==1 )		// SES files			// enabled  F.Schmitt 22/04/07
	keylist+="RegionName=\r"
	keylist+="AnalyzerSlit=\r"
	keylist+="ScientaOrientation=\r"
	keylist+="CCDFirstXChannel=\r"
	keylist+="CCDLastXChannel=\r"
	keylist+="CCDFirstYChannel=\r"
	keylist+="CCDLastYChannel=\r"
	keylist+="NumberOfSlices=\r"
	keylist+="CCDXChannelZero=\r"
	keylist+="CCDDegreePerChannel=\r"
	keylist+="\r"
//	endif										// enabled  F.Schmitt 22/04/07
	
//	if ( data_type==2 )		// MacESCAII		// enabled  F.Schmitt 22/04/07
	keylist+="PhotonSource=\r"	
	keylist+="LensSlit=\r"	
	keylist+="LensIris=\r"	
	//keylist+="MacESCAIIThetaInitial\r"	
	//keylist+="MacESCAIIPhiInitial\r"	
	keylist+="\r"		
//	endif										// enabled  F.Schmitt 22/04/07
	
	keylist+="Processing Information:\r"
	keylist+="MatrixType=\r"
	keylist+="DispersionCorrection=\r"
	keylist+="aTMFWave=\r"
	keylist+="aTMFStartEnergy=\r"
	keylist+="aTMFEndEnergy=\r"
	keylist+="fixedTMFMatrix=\r"
	keylist+="x0Crop=\r"
	keylist+="x1Crop=\r"
	keylist+="y0Crop=\r"
	keylist+="y1Crop=\r"
	keylist+="AngleMapping=\r"
	keylist+="EnergyScale=\r"
	keylist+="AverageWave=\r"
	keylist+="FermiNorm=\r"
	keylist+="OtherModifications=\r"
	
	return keylist
End






// creates a temporary folder 'SES_pxt_import'
// user drags .pxt files in this folder
// execute conversion function, and delete the temporary folder
Function fileloader_loadSESpxt()
	
	String DF = getDataFolder(1)
	
	SetDataFolder root:
	NewDataFolder/O SES_pxt_import
	NewDataFolder/O/S carpets
	NewDataFolder/O/S rawData

	DoWindow/K convert_panel
	NewPanel /W=(400,0,660,140) as "convert .pxt"
	DoWindow/C convert_panel
	GroupBox gb0, pos={12,12}, size={236,116}
	String/G title = "Drag all '.pxt' files to the 'SES_pxt_import'\rfolder and click 'convert'"
	TitleBox fix_t0, pos={20,20}, size={236,100},variable=title
	Button conv_button, pos={40,80},size={180,18},title="convert", proc=fileloader#buttonImportSESpxt

	execute "CreateBrowser"
	
	SetDataFolder $DF
End




Function fileloader_loadCCDOPSbin(symPath,filename)
	String symPath, filename
	
	String DF = GetDataFolder (1)
	SetDataFolder root:
	NewDataFolder/o/s LEEDs
	
	Variable height, width
	String name = fileName_to_waveName(fileName, "pref")
		
	String cmd = "GBLoadWave/B/T={80,2}/S=2048/A=temp/Q /P="+sympath+" \""+filename+"\""
	Execute cmd
	
	do
		if (numpnts(temp0)==43350)			// Low Resolution
			height=170
			width=255
			break
		endif
		if (numpnts(temp0)==97410)			// Medium Resolution
			height=255
			width=382
			break
		endif
		if (numpnts(temp0)==390150)		// High Resolution
			height=510
			width=765
			break
		endif
		KillWaves/Z temp0, temp1
		Abort "i_photo attempted to read a CCDOPS binary file, but recognized a problem"		
	while(0)
	
	Redimension/N=(width,height) temp0
	Duplicate/O temp0 $Name
	KillWaves/Z temp0, temp1

	SetDataFolder $DF
End




// loads .tif and .jpg images and converts the three layers to a single precision gray-scale image
Function fileloader_loadTifJpg(symPath,FileName)
	String symPath, filename
	
	String DF = GetDataFolder (1)
	SetDataFolder root:
	NewDataFolder/o/s LEEDs
	
	String ext = FileName[strsearch(FileName,".",0)+1, strlen(fileName)-1]
	
	// without the type-specification, the Mac does not recognize bmp-files form the Stanford Laue machine
	if (WhichListItem(ext,"tif;tiff",";") != -1)
		ImageLoad/T=TIFF/Q/O/N=t_tiff/P=$symPath filename
	elseif (WhichListItem(ext,"jpg;jpeg",";") != -1)
		ImageLoad/T=JPEG/Q/O/N=t_tiff/P=$symPath filename
	elseif (WhichListItem(ext,"bmp",";") != -1)
		ImageLoad/T=BMP/Q/O/N=t_tiff/P=$symPath filename
	else
		ImageLoad /Q/O/N=t_tiff/P=$symPath filename	// give it a try
	endif
	
	String name = fileName_to_waveName(fileName, "pref")
	
	ImageTransform rgb2gray t_tiff
	WAVE M_RGB2Gray
	Redimension/S M_RGB2Gray
	
	// flip the image vertically
	Duplicate/o M_RGB2Gray M
	M = M_RGB2Gray[p][dimsize(M,1)-1-q]
	
	//SetScale/I y Dimsize(M_RGB2Gray,1)-1,0,"" M_RGB2Gray
	//SetScale/I x 0, Dimsize(M_RGB2Gray,0)-1,"" M_RGB2Gray
	
	Note M, "FileName="+filename
	Duplicate/o M $name
	KillWaves/Z t_tiff, M_RGB2Gray, M
	
	SetDataFolder $DF
End





// "version 2": first all blocks are loaded as matrices, then NickNames and Notes are assigned, depending on a reconstruction
// of the block-assignement based on the Region-number and Block-number.

// the energy scaling is taken from the data-matrix, the angle scaling from the header
// data are normalized to aquisition time. Units are: kcts/s/channel

// FB  03/17/04
// 06/27/04 implemented loading of angles for manipulator scans

Function fileloader_loadSEStxt(symPath, filename)			
	String symPath, filename
	
	String DF = getDataFolder(1)
	String SES_line, DataName, cmd, NickName, w_Name
	String th, ph, al
	Variable refnum, done, line
	Variable index
	Variable NumberOfRegions, Region
	Variable NumberOfBlocks, Block
	Variable e0, e1, divideBy
	
	SetDataFolder root:
	NewDataFolder/O/S carpets
	NewDataFolder/O/S rawData
	
	
	// get the number of Regions
	Open/R /P=$symPath refnum filename
	do
		FReadline refnum, SES_line
		if (stringmatch(SES_line, "Number of Regions=*") )
			NumberOfRegions=NumberByKey("Number of Regions",SES_line,"=","\r")
			break
		endif
	while(line < 12)
	Close refnum

	
	// Load all matrices:
	KillWaves_withBase("MM")
	LoadWave/G/M/Q/O/A=MM /P=$symPath filename
	
	// scaling, saving and header
	index = 0
	Region = 1
	do	
		// for each region: get the header, the number of Blocks, and the "run mode information"
		String notestr = sFunc_SES_header(symPath, filename,Region)
		String dim3info = sFunc_SES_dim3(symPath, filename, Region)
		
		NumberOfBlocks = str2num(StringFromList(0,dim3info))
		
		Variable FirstXchannel = NumberByKey("CCDFirstYChannel",noteStr,"=","\r")
		Variable LastXchannel = NumberByKey("CCDLastYChannel",noteStr,"=","\r")
		Variable FirstYchannel = NumberByKey("CCDFirstXChannel",noteStr,"=","\r")
		Variable LastYchannel = NumberByKey("CCDLastXChannel",noteStr,"=","\r")
		
		Variable channelZero = NumberByKey("CCDXChannelZero",noteStr,"=","\r")
		Variable deg_channel = NumberByKey("CCDDegreePerChannel",noteStr,"=","\r")
		Variable NumberOfSlices =  NumberByKey("NumberOfSlices",noteStr,"=","\r")
		Variable DwellTime = NumberByKey("DwellTime", noteStr, "=","\r")
		Variable NumberOfSweeps = NumberByKey("NumberOfSweeps", noteStr, "=","\r")
		Variable channel_slice = (LastXchannel-firstXchannel+1)/NumberOfSlices	// channels/slice
		Variable x0 = (FirstXchannel+ (channel_slice-1)/2 - channelZero)* deg_channel
		Variable x1 = (LastXchannel- (channel_slice-1)/2 - channelZero)* deg_channel	// assuming firstChannel < lastChannel

	
	
		Block = 1	
		do
			if (NumberOfRegions > 1 || NumberOfBlocks > 1)
				sprintf NickName, "%s_%02d_%03d", fileName_to_waveName(fileName,"SES"), Region, Block
			else
				NickName = fileName_to_waveName(fileName,"SES")
			endif
		
			WAVE M = $("MM"+num2str(index))
			MatrixTranspose M
			Duplicate/R=[1,dimsize(M,0)-1][]/O M M_int		// skip the energy-column
			if (DwellTime >= 33)		// seems to be a file with ms 'Step Time'
				//divideBy = DwellTime * NumberOfSweeps * channel_slice
				divideBy = DwellTime * NumberOfSweeps * abs( (LastXChannel-FirstXChannel) * (LastYChannel-FirstYChannel) ) / 1000
			else
				//divideBy = DwellTime * NumberOfSweeps * channel_slice * 1000
				divideBy = DwellTime * NumberOfSweeps * abs( (LastXChannel-FirstXChannel) * (LastYChannel-FirstYChannel) )
			endif
			M_int /= divideBy	// kcts/s/channel
								// changed to counts/pixel/s, FB 10-05-04
			
			Variable FirstEnergy = round(M[0][0] * 1e4)/1e4
			Variable LastEnergy = round(M[0][dimsize(M,1)-1] * 1e4)/1e4	// single precision loading results in funny rounding...
			SetScale/I x, x0,x1,"deg", M_int
			SetScale/I y, FirstEnergy,LastEnergy,"eV", M_int
			
			// write the angles for manipulator scans in the note
			if (NumberOfBlocks > 1)
				th = StringByKey("T"+num2str(Block), dim3info,"=",";")
				ph = StringByKey("F"+num2str(Block), dim3info,"=",";")
				// doubtful if this works:
				al = StringByKey("A"+num2str(Block), dim3info,"=",";")
				if (strlen(al) == 0) // if no alpha angle is defined, it is likely not ALS and therefore 0:
					al = "0"
				endif
				notestr = ReplaceStringByKey("InitialThetaManipulator", noteStr, th,"=","\r")
				notestr = ReplaceStringByKey("FinalThetaManipulator", noteStr, th,"=","\r")
				notestr = ReplaceStringByKey("InitialAlphaAnalyzer", noteStr, al,"=","\r")
				notestr = ReplaceStringByKey("FinalAlphaAnalyzer", noteStr, al,"=","\r")
				notestr = ReplaceStringByKey("InitialPhiManipulator", noteStr, ph,"=","\r")
				notestr = ReplaceStringByKey("FinalPhiManipulator", noteStr, ph,"=","\r")
			endif
			
			Note M_int, noteStr
			KillWaves/Z M		// 10/02/04 modified killing waves to avoid string-length problem
						
			// linescans added 02-16-04
			if (dimsize(M_int,0) > 1)
				Duplicate/O M_int $"root:carpets:rawData:"+NickName
			else		
				NewDataFolder/o root:linescans
				NewDataFolder/o root:linescans:rawData
				e0 = utils_y0(M_int)
				e1 = utils_y1(M_int)
				Redimension/N=(dimsize(M_int,1)) M_int
				SetScale/I x e0,e1,"", M_int
				Duplicate/o M_int $("root:linescans:rawData:"+NickName)
			endif
	
		Block += 1
		index += 1
		while (Block <= NumberOfBlocks)
		
	Region += 1
	while (Region <= NumberOfRegions)
	
	//KillWaves_withBase("MM*")		// doesn't work for large data-sets
	KillWaves/Z m_int
	KillStrings/Z s_fileName, s_waveNames, s_Path
			
	SetDataFolder $DF
End










// real angles do usually not agree with the fileheader -> prompt							FB 11/7/02
Function fileloader_loadVG1Zcarpet(symPath, filename)
	String symPath, fileName

	String fullPath = symPath+filename
	String DF = getDataFolder(1)
	String NickName, type
	String ext = filename[14,strlen(fileName)-1]		// extension
	Variable polar = StringMatch(ext,".p1") + StringMatch(ext,".pt1") + StringMatch(ext,".p1.s") + StringMatch(ext,".pt1.s")
	Variable xi, xf

	SetDataFolder root:
	NewDataFolder/O/S Carpets
	NewDataFolder/O/S rawData
	
	// load the intensity matix, write the note
	LoadWave/Q/G/M/N=TempMatrix/V={" "," $",0,0}/L={0,19,0,1,0} /P=$symPath filename
		WAVE w = TempMatrix0
		String w_Note = sFunc_VG1Z_header(symPath, filename)
		Note w, w_Note
		
	Variable first_e = NumberByKey("FirstEnergy", w_Note,"=","\r")
	Variable last_e = NumberByKey("LastEnergy", w_Note,"=","\r")
	Variable dwell = NumberByKey("DwellTime", w_Note,"=","\r")
	Variable sweeps = NumberByKey("NumberOfSweeps", w_Note,"=","\r")
	if (polar)
		xi = NumberByKey("InitialThetaManipulator", w_Note,"=","\r")
		xf = NumberByKey("FinalThetaManipulator", w_Note,"=","\r")
	else
		xi = NumberByKey("InitialOmegaManipulator", w_Note,"=","\r")
		xf = NumberByKey("FinalOmegaManipulator", w_Note,"=","\r")
	endif
		
	w /= (sweeps*dwell)
	SetScale/I x, xi, xf, "" w
	SetScale/I y, first_e, last_e, "" w
	
	NickName = fileName_to_waveName(fileName, "VG1Z")
	Duplicate/O TempMatrix0 $NickName

	KillWaves/Z TempMatrix0, TempMatrix1
	SetDataFolder $DF
End





Function fileloader_loadVG1Zholo(symPath, filename)		//		FB 11/7/02
	String symPath, fileName

	String fullPath = symPath+filename
	String DF = getDataFolder(1)
	String NickName, th_Name, ph_Name
	
	String ext = filename[14,strlen(fileName)-1]		// extension
	Variable polar = StringMatch(ext,".p1") + StringMatch(ext,".pt1") + StringMatch(ext,".p1.s") + StringMatch(ext,".pt1.s")
	Variable xi, xf

	SetDataFolder root:
	NewDataFolder/O/S pizzas
	NewDataFolder/O/S rawData
	
	// load angles and intensity as a matrix
	LoadWave/Q/G/W/N=h_0_ /L={0,22,0,0,0} /P=$symPath filename
		WAVE th = h_0_3
		WAVE ph = h_0_4
		WAVE c1= h_0_5
		WAVE c2= h_0_6
		WAVE c3= h_0_7
		WAVE c4= h_0_8
		WAVE c5= h_0_9
		WAVE c6= h_0_10
		
		String w_Note = sFunc_VG1Z_header(symPath, filename)
		Note th, w_Note
		Note ph, w_Note
		Note c1, w_Note
		Note c2, w_Note
		Note c3, w_Note
		Note c4, w_Note
		Note c5, w_Note
		Note c6, w_Note
		
		Variable dwell = str2num(StringByKey("DwellTime", w_Note,"=","\r"))
		Variable sweeps = str2num(StringByKey("NumberOfSweeps", w_Note,"=","\r"))
			c1 /= (sweeps*dwell)
			c2 /= (sweeps*dwell)
			c3 /= (sweeps*dwell)
			c4 /= (sweeps*dwell)
			c5 /= (sweeps*dwell)
			c6 /= (sweeps*dwell)
	
	//NickName = "h_"+filename[4,9]+fileName[11,13]
	NickName = fileName_to_waveName(fileName, "VG1Z")
	Duplicate/O th $NickName+"_th"
	Duplicate/O ph $NickName+"_ph"
	Duplicate/O c1 $NickName+"_c1"
	Duplicate/O c2 $NickName+"_c2"
	Duplicate/O c3 $NickName+"_c3"
	Duplicate/O c4 $NickName+"_c4"
	Duplicate/O c5 $NickName+"_c5"
	Duplicate/O c6 $NickName+"_c6"
	
	KillWaves_withBase("h_0_*")
	SetDataFolder $DF
End





Static Function/S loadFITS_translateWaveNote(FITSwnote)
	String FITSwnote  
	String FITS_keywords = ""
	String Note_keywords = ""

//	FITS_keywords+="BITPIX;"
//	Note_keywords+=";"

	FITS_keywords+="SS_HV;"
	Note_keywords+="PhotonEnergy;"

//	FITS_keywords+="BITPIX;"
//	Note_keywords+=";"
	
//	FITS_keywords+="DEVNM_0;" // device name for loop
//	Note_keywords+=";"

//	FITS_keywords+="NM_0_0;" // name of loop, usually "Alpha" for an automated Alpha scan...
//	Note_keywords+=";"

//	FITS_keywords+="ST_0_0;" // Start of loop angle
//	Note_keywords+=";"

//	FITS_keywords+="EN_0_0;" // Start of loop angle
//	Note_keywords+=";"

//	FITS_keywords+="N_0_0;" // number of loop angles
//	Note_keywords+=";"

	FITS_keywords+="SF_MODEL;"
	Note_keywords+="AnalyzerType;"
	
//	FITS_keywords+="SS_KE0;"
//	Note_keywords+="CCDYChannelZero;"

	FITS_keywords+="SSRNGN0;"
	Note_keywords+="RegionName;"
	
	FITS_keywords+="SSLNM0;" // lens mode name
	Note_keywords+="AnalyzerMode;"
	
	FITS_keywords+="SSPE_0;"
	Note_keywords+="PassEnergy;"

//	FITS_keywords+="SSKE_0;" // kinetic? Final?
//	Note_keywords+="EnergyScale;"

	FITS_keywords+="SSE0_0;"
	Note_keywords+="FirstEnergy;"

	FITS_keywords+="SSE1_0;"
	Note_keywords+="LastEnergy;"

	FITS_keywords+="SSDE_0;" // TODO: this is the energy step width in meV...
	Note_keywords+="NumberOfEnergies;" // ... while these are the number of steps

	FITS_keywords+="SSFR_0;" // number of frames...
	Note_keywords+="DwellTime;" // ...while this is in seconds = SSFR_0 / 15

	FITS_keywords+="SSSW0;"
	Note_keywords+="NumberOfSweeps;"
	
//	FITS_keywords+="SSPEV_0;" // pixels per eV
//	Note_keywords+=";"
//	FITS_keywords+="SSKE0_0;" // zero pixel in energy direction
//	Note_keywords+=";"

	// N.B.: I believe that the X and Y channel nomenclature is swapped for FITS vs. SES:
	FITS_keywords+="SSY0_0;"
	Note_keywords+="CCDFirstXChannel;"
	FITS_keywords+="SSY1_0;"
	Note_keywords+="CCDLastXChannel;"
	FITS_keywords+="SSX0_0;"
	Note_keywords+="CCDFirstYChannel;"
	FITS_keywords+="SSX1_0;"
	Note_keywords+="CCDLastYChannel;"
	
	String wnote = fileloader_NoteKeyList(-1)

	Variable i
	For(i = 0; i < ItemsInList(FITSwnote, "\r"); i += 1)
		String keyValuePair = StringFromList(i, FITSwnote, "\r")
		String key = keyValuePair[0,strsearch(keyValuePair, "=", 0)-1]
		String value = StringByKey(key, keyValuePair, "=", "\r")
		
		String newKey = ""
		String newValue = ""

		Variable n = WhichListItem(key, FITS_keywords, ";")
		if(n != -1)
			newKey = StringFromList(n, Note_keywords)
			strswitch(key)
				case "SSFR_0": // this is the number of frames...
					newValue = num2str( str2num(value) / 15 ) // ... while DwellTime is in seconds, and there are generally 15 frames/sec
					break
				case "SSDE_0": // energy step width in eV...
					Variable v = NumberByKey("SSE1_0", FITSwnote,"=","\r") - NumberByKey("SSE0_0", FITSwnote,"=","\r")
					v /= str2num(value)
					newValue = num2str(abs(v))
					break
				default:
					newValue = value
					break
			endswitch
			wnote = ReplaceStringByKey(newKey, wnote, newValue, "=", "\r")
		else
			newKey = "FITS_"+key
			newValue = value
			wnote += newKey+"="+newValue+"\r"
		endif
	EndFor
	return wnote
End

// Seems like each line of comment is saved as 80 characters long and that
// it is filled up with spaces if the contents is shorter:
Static Constant c_FITS_lineLen = 80
// There seem to be multiple blocks of comments/lines present. For some reason,
// each block has 36 lines in it:
Static Constant c_FITS_LinesPerBlock = 36
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// I modified Makoto Hashimoto's code to load the infamous FITS files that
// Eli Rothenberg's LabView measurement interface generates in order to 
// incorporate them into the i_photo package...
Function fileloader_loadFITS(symPath, FileName)
	String symPath, FileName
	NVAR centerpixel = root:InternalUse:prefs:gv_FITS_centerPixel
	NVAR anglePerPixel = root:InternalUse:prefs:gv_FITS_anglePerPixel
	NVAR convertVcp2Angle = root:InternalUse:prefs:gv_FITS_convertVcp2Angle
	
	Variable i, dataoffset,refnum
	
	String DF = GetDataFolder(1)

	String s= PadString("", c_FITS_lineLen, 0)
	String wvnote=""
	String NickName = filename_to_wavename(FileName, "FITS")
	
	Open/R/P=$symPath/T="????" refnum as FileName
	FStatus refnum	
	
	Do
		FBinRead refnum,s

		// We need to ignore certain keywords, like comments
		String keyword = s[0,strsearch(s, " ", 0)-1]
		if (FindListItem(keyword, "END;COMMENT", ";") == -1)
			// ...also, it seems that everything starting from a "/" in a line is an additional comment
			if (strsearch(s, "/", 0) != -1)
				wvnote+=s[0, strsearch(s, "/", 0)-1]+"\r"
			else
				wvnote+=s+"\r"
			endif
		endif
		
		If(!(StringMatch(s, "SIMPLE*")|StringMatch(s, "XTENSION*")))
			dataoffset = i * c_FITS_lineLen
			FSetPos refnum, dataoffset
			break
		EndIf
		i+=1
		do
			FBinRead refnum,s
			keyword = s[0,strsearch(s, " ", 0)-1]
			if (FindListItem(keyword, "END;COMMENT", ";") == -1)
				// ...also, it seems that everything starting from a "/" in a line is an additional comment
				if (strsearch(s, "/", 0) != -1)
					wvnote+=s[0, strsearch(s, "/", 0)-1]+"\r"
				else
					wvnote+=s+"\r"
				endif
			endif
			If(StringMatch(s, "END*"))
				i= (ceil(i/c_FITS_LinesPerBlock))*c_FITS_LinesPerBlock
				FSetPos refnum,i*c_FITS_lineLen
				break
			EndIf
		
			i+=1
		while(1)
	
	While(1)

	wvnote = ReplaceString(" ", wvnote, "")
	wvnote = ReplaceString("'", wvnote, "")
	String MONOEV = StringByKey("MONOEV", wvnote, "=","\r")
	String NAXIS2 = StringByKey("NAXIS2", wvnote, "=","\r")
	String TTYPE3 = StringByKey("TTYPE3", wvnote, "=","\r")
	String TUNIT3 =  StringByKey("TUNIT3", wvnote, "=","\r")	
	String TDIM3 = StringByKey("TDIM3", wvnote, "=","\r")
	String TRVAL3 = StringByKey("TRVAL3", wvnote, "=","\r")
	String TDELT3 =  StringByKey("TDELT3", wvnote, "=","\r")
	TDIM3 = ReplaceString("(", TDIM3, "")
	TDIM3 = ReplaceString(")", TDIM3, "")
	TRVAL3 = ReplaceString("(", TRVAL3, "")
	TRVAL3 = ReplaceString(")", TRVAL3, "")
	TDELT3 = ReplaceString(")", TDELT3, "")
	TDELT3 = ReplaceString("(", TDELT3, "")
	
	Variable pz = str2num(NAXIS2)
	Variable px = str2num(StringFromList(0,TDIM3,","))
	Variable py = str2num(StringFromList(1,TDIM3,","))
	Variable ox = str2num(StringFromList(0,TRVAL3,","))
	Variable oy = str2num(StringFromList(1,TRVAL3,","))+str2num(MONOEV)
	Variable dx = str2num(StringFromList(0,TDELT3,","))
	Variable dy = str2num(StringFromList(1,TDELT3,","))
	
//	dx=1
	// Felix: I don't think this is right... The detector x axis should have 
	// somewhere between 1024 and 1280 pixels:
	ox = 1000-(ox+px*dx)
	
	If(convertVcp2Angle)
		ox = (ox-centerpixel)*anglePerPixel*dx
		dx = anglePerPixel*dx
	EndIf
		
	Variable vTime, vAngle

	SetDataFolder root:carpets:rawData

	Make/O/D/N=(pz) $(NickName+"time"), $(NickName+"angle")
	WAVE w_time = $(NickName+"time")
	WAVE w_angle = $(NickName+"angle")
	
	String newWnote = loadFITS_translateWaveNote(wvnote)

	For(i=0;i<pz;i+=1)
		String wvnum
		sprintf wvnum, "_%03d",i
		Make/O/D/N=(px,py) $(NickName+wvnum), w_tmp
		Wave wv2D=$(NickName+wvnum)
		SetScale/P x, ox, dx, "" wv2D, w_tmp
		SetScale/P y, oy, dy, "" wv2D, w_tmp
		FBinRead  /b=2 refnum, vTime
		FBinRead /B=2 refnum, vAngle
		FBinRead/B=2 refnum, w_tmp
		wv2D=w_tmp[px-p-1][q]
		Note/K wv2D, newWnote
		w_time[i]=vTime
		w_angle[i]=vAngle
//		MatrixTranspose wv2D
		utils_ProgressDlg(message="Loading FITS "+FileName, numDone=i, numTotal=pz)
		DoUpdate
	EndFor
	utils_ProgressDlg(done=1)
	KillWaves/Z w_tmp
	Close refnum
	
	SetDataFolder $DF
End







//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// new loader for hopefully all croissant files
// note: in all carpet files other than plsp-files, equidistant x-values are assumed!!!!
// intensities are in kcts/s
//																	FB 06-30-04

Function fileloader_loadCroissant(symPath, FileName)
	String symPath, FileName
	
	NVAR all_groups = root:InternalUse:prefs:gv_Croissant_all_gr		// get the preferences
	NVAR all_channels = root:InternalUse:prefs:gv_Croissant_all_ch
	NVAR read_data = root:InternalUse:prefs:gv_Croissant_read_data
	
	Variable refnum
	Variable y0, dy, x0, x1
	Variable index, ch, gr, col, pos0, pos1, control_index
	Variable NumberOfControlVars
	String c_line, ugly_line, block_name, base, suffix, w_name
	String control_var_List, controlName
	String ext = FileName[strsearch(FileName,".",0)+1, strlen(fileName)-1]
	
	
	String DF = getDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S carpets
	NewDataFolder/O/S rawData
	
	// Load all matrices:
	KillWaves_withBase("MM*")
	LoadWave/G/M/Q/O/A=MM /P=$symPath filename
	
	
	// get the header
	String notestr = sFunc_croissant_header(symPath,filename)
	
	
	// figure out what to do with the matrices:
	// preference settings: 	read only one group/read all groups
	//						keep channels/kill channels
	//						read data-block
	// run through all loaded matrices:
	base = fileName_to_waveName(fileName, "")  // to be changed
	
	Open/R /P=$symPath refnum filename	// scrolls the file to the last '[...' line above the data:
	do
		FReadline/N=12 refnum, c_line
		if(stringmatch(c_line,"[Detector]*"))
			break
		endif
	while (1)
	
	index = 0
	ch = 1
	gr = 1
	do
		if (waveexists($("MM"+num2str(index))) == 0 )
			break
		endif
		
		do	// look for the title of the matrix
			FReadline refnum, c_line
			if(stringmatch(c_line,"[*"))
				block_name = c_line
				FReadline refnum, ugly_line
				break
			endif
		while (1)
		
		WAVE M = $("MM"+num2str(index))
		
		
		// spectra & 1D info for carpets
		if (stringmatch(block_name,"[Data]*") )
			if (strlen(ugly_line)==0 || stringmatch(ugly_line,"\r"))	// avoid skipping the first matrix for empty data sections
				index -= 1		
			else
				control_var_List = varNames_from_dim2Line(ugly_line)
				NumberOfControlVars = ItemsInList(control_var_List)
			
				Make/o/n=(dimsize(M,0)) w
				
				col = 0		
				do
					w = M[p][col]
					w_name = StringFromList(col, control_var_List)
					w_name = cleanupname(w_name,0)
					
					if (WhichListItem(ext, "plsp;ptsp;ppsp;pxsp",";") == -1)	// does not seem to be a carpet -> save in 'linescans'
						NewDataFolder/o root:linescans
						NewDataFolder/o root:linescans:rawData
						Duplicate/o w $("root:linescans:rawData:"+base+"_"+w_name)
					else
						if (read_data)
							Duplicate/o w $(base+"_"+w_name)
						endif
					endif
				col += 1
				while(col < NumberOfControlVars)
			endif
			
		endif
		
		
		
		// carpets (assumes that DwellTime and Sweeps are always the last control variables)
		if (stringmatch(block_name,"[Spectrum*") )
			control_Index = 0
			
			control_var_List = varNames_from_dim2Line(ugly_line)
			NumberOfControlVars = ItemsInList(control_var_List)
		
			y0 = E_from_dim2line(ugly_line,0)
			dy = E_from_dim2line(ugly_line,1)
			
			Make/O/N=(dimsize(M,0))/D w_dwell, w_sweeps, w_ac, w_control
			
			if (NumberOfControlVars == 3) 							// scale with first col, assume equidistant x-values
				x0 = M[0][0]
				x1 = M[dimsize(M,0)-1][0]
			endif
			if (NumberOfControlVars > 3 || stringmatch(ext,"plsp"))	// scale with point numbers, and save control-waves
				x0 = 0
				x1 = dimsize(M,0)-1
				do
					w_control = M[p][control_index]
					controlName = StringFromList(control_index, control_var_List)
					controlName = cleanUpName(controlName,0)
					Duplicate/o w_control $(base+"_"+controlName)
				control_index += 1
				while (control_index < NumberOfControlVars-2)
			endif
			if (NumberOfControlVars < 3) 
				DoAlert 0, "'i_photo' found less than 3 control-variables in a SpectrumGroup.\rAborted with incomplete data-load."
				break
			endif
			
			Make/O/N=(dimsize(M,0))/D w_dwell, w_sweeps, w_ac
			Duplicate/O/R=[0,inf][NumberOfControlVars,inf] M M_data	// this does not work for plsp-files, which have 4 control columns....
			w_dwell = M[p][NumberOfControlVars-2]
			w_sweeps = M[p][NumberOfControlVars-1]
			w_ac = w_dwell * w_sweeps * 1000 						// (kcts/s)
			M_data /= w_ac[q]
			SetScale/P y y0,dy,"" M_data
			SetScale/I x x0, x1,"" M_data
			Note M_data, notestr
			
			
			// check the prefs and decide whether the matrix needs to be saved
			if (stringmatch(block_name,"[SpectrumGroup*") )
				if (gr==1 || all_groups)
					suffix = "_gr"+num2str(gr)
					Duplicate/O M_data $(base+suffix)
				endif
				gr += 1
			elseif (stringmatch(block_name,"[SpectrumChannel*") )
				if (all_channels)
					suffix = "_ch"+num2str(ch)
					Duplicate/O M_data $(base+suffix)
				endif
				ch += 1
			elseif (stringmatch(block_name,"[PhotonFlux*") )
				suffix = "_flux"
				Duplicate/O M_data $(base+suffix)
			else
				DoAlert 0, "Only files with the Keywords '[SpectrumGroup]' or '[SpectrumChannel]' are supported."
				break
			endif
			
		endif
		
	index += 1
	while (1)
	
	KillWaves_withBase("MM*")
	KillWaves/Z w_ac, w_sweeps, w_dwell, M_data, w, w_control
	SetDataFolder $DF
End





























//////////////////////////////////////
//
// Private functions: Control Callbacks
//
//////////////////////////////////////



























Static Function buttonImportSESpxt(ctrlName)
	String ctrlName

	String DF = getDataFolder(1)
	String current_Df, current_waveName, NickName, notestr, newNote
	Variable firstYchannel, lastYchannel, numberofslices, x0, x1, channel_slice, channelZero, degChannel
	Variable DwellTime, NumberOfSweeps, e0,e1
	
	SetDataFolder root:SES_pxt_import
	
	// check for DF in DF
	SetDataFolder $GetIndexedObjName("",4,0)
	//String topfolder=GetIndexedObjName("",4,0)
	if (strlen(GetIndexedObjName("",4,0))==0)	// seems to be a full system folder	
		SetDataFolder root:SES_pxt_import
	endif
	String p_DF = getDataFolder(1)
	
	// step through the SES-folders
	Variable nDf = CountObjects("",4)
	Variable index = 0
	do
		SetDataFolder $p_DF
		current_Df = GetIndexedObjName("",4,index)
		SetDataFolder $current_DF
		current_waveName = GetIndexedObjName("",1,0)
		Duplicate/o $current_waveName w_temp
		MatrixTranspose w_temp
		Redimension/S w_temp	// from unsigned bite to single precision floating point
		
		// get a new name
		NickName = fileName_to_waveName(current_DF, "SES_pxt")
		
		// redo the wave-note:
		notestr = note(w_temp)
		newNote = convert_SES_pxt_note(notestr)
		
		firstYchannel = NumberByKey("CCDFirstYChannel",newNote,"=","\r")
		LastYchannel = NumberByKey("CCDLastYChannel",newNote,"=","\r")
		NumberOfslices = NumberByKey("NumberOfSlices",newNote,"=","\r")
		
		x0 = Dimoffset(w_temp,0)
		x1 = x0+dimdelta(w_temp,0)
		channel_slice = (lastYchannel - firstYchannel +1)/dimsize(w_temp,0)
		channelZero = firstYchannel + x0/(x0-x1) * channel_slice + 1		// check the '+1'!
		channelZero = round(channelZero * 1e4) / 1e4
		degChannel = (x1-x0) / channel_slice
		degChannel = round(degChannel * 1e7) / 1e7
	
		newNote = ReplaceNumberByKey("CCDXChannelZero", newNote,channelZero,"=","\r")
		newNote = ReplaceNumberByKey("CCDDegreePerChannel", newNote,degChannel,"=","\r")
		newNote = ReplaceStringByKey("FileName", newNote,current_Df+".pxt","=","\r")
		newNote = ReplaceStringByKey("WaveName", newNote,NickName,"=","\r")
		newNote = ReplaceStringByKey("RawDataWave", newNote,"root:carpets:rawData:"+current_Df+".pxt","=","\r")
	
		// 02-16-04 added normalization (kcts/s/channel)
		DwellTime = NumberByKey("DwellTime", newNote,"=","\r")
		NumberOfSweeps = NumberByKey("NumberOfSweeps", newNote,"=","\r")
		w_temp = w_temp/ (DwellTime * NumberOfSweeps * channel_slice * 1000)
		
		Note/K w_temp
		Note w_temp newNote
		if (dimsize(w_temp,0) > 1)
			Duplicate/o w_temp $("root:carpets:rawData:"+NickName)
		else		// linescans added 02-16-04
			NewDataFolder/o root:linescans
			NewDataFolder/o root:linescans:rawData
			e0 = utils_y0(w_temp)
			e1 = utils_y1(w_temp)
			Redimension/N=(dimsize(w_temp,1)) w_temp
			SetScale/I x e0,e1,"", w_temp
			Duplicate/o w_temp $("root:linescans:rawData:"+NickName)
		endif
	index += 1
	while(index < nDF)
	
	DoWindow/K convert_panel
	KillStrings/Z title
	KillDataFolder root:SES_pxt_import
	SetDataFolder $DF
End
























//////////////////////////////////////
//
// Private functions
// N.B.: the keyword "Static" in front of "Procedure" limits visibility to the containing Igor Procedure File only.
//
//////////////////////////////////////






















// kill all waves that match a BaseName
Static Function KillWaves_withBase(baseName)
	String baseName
	
	String str0 = Wavelist(baseName,",","")
	String str1 = str0[0,strlen(str0)-2]
	
	if (strlen(str1) > 0)
		execute "KillWaves/Z "+str1
	endif
End






// recognize different file types. Pass FileName and symbolic path to specialized functions loading the files and writing the note
// 5/14/03 modified to take symbolic path as input
// 11/11/03 modified to recognize and load jpeg- and tif-files (tested for Helm LEED cam)
Static Function fileType(FileName, symPath, refnum)
	String FileName, symPath
	Variable refnum
	
	String ext, file_line
	Variable software, type
	Variable spec, xpd, carpet, holo
	Variable index
		
	Variable n_char = strlen(FileName)
	
	//---------------------- VG1Z - files: ---------------------------------
	if (cmpstr(FileName[0,3], "VG1Z") == 0)
		ext = FileName[14,n_char-1]								// extension, e.g. '.pt1.s' 
		
		spec = stringmatch(ext,"")
		xpd = ( WhichListItem(ext, ".p1;.pt1;.a1;.at1", ";") != -1 )
		carpet = ( WhichListItem(ext, ".p1.s;.pt1.s;.a1.s;.at1.s", ";") != -1 )
		holo = ( WhichListItem(ext, ".h1;.ht1", ";") != -1 )
	
		if (spec)										
			load_VG1Z_spectrum(symPath, FileName)
		elseif (carpet) 		
			fileloader_loadVG1Zcarpet(symPath, FileName)
		elseif (holo) 
			fileloader_loadVG1Zholo(symPath, FileName)
		elseif (xpd) 								
			load_VG1Z_xpdScan(symPath, FileName)
		endif
		close refnum
		return 1		// don't check other possibilities
	endif
	
	//-------------------- croissant - files: ---------------------------------
	ext = FileName[strsearch(FileName,".",0)+1, strlen(fileName)-1]
	
	if (WhichListItem(ext,"plsp;ptsp;ppsp;pxsp;phsp;phfe;pesp;plfe;ppfe;pxfe",";") != -1)	// all possible croissant extensions
	
		fileloader_loadCroissant(symPath, FileName)
	
		close refnum
		return 1
	endif

	//-------------------- XCRYSDEN -----------------------------------
	if (WhichListItem(ext,"bxsf",";") != -1)
		fileloader_loadBxsf(symPath,FileName)
		close refnum
		return 1
	endif
	
	//-------------------- jpeg/tif - files: ---------------------------------
	if (WhichListItem(ext,"jpeg;jpg;tif;tiff;bmp;png;jif;pict",";") != -1)
		fileloader_loadTifJpg(symPath,FileName)
		close refnum
		return 1
	endif
	
	//-------------------- FITS files: ---------------------------------
	if (WhichListItem(ext,"fits;FITS",";") != -1)
		fileloader_loadFITS(symPath,FileName)
		close refnum
		return 1
	endif
	
	
	//--------------------  files recognized from header key-words -----------------
	index = 0
	do
		FReadline refnum, file_line
		// SES - text-files
		if (stringmatch(file_line,"Instrument=SES*") || stringmatch(file_line,"Instrument=R4000*" ))  //add R4000 string -By Wei-Sheng Lee
			fileloader_loadSEStxt(symPath,filename)
			return 1
		endif
		// CCDOPS-binary files
		if (stringmatch(file_line,"ST-7 Image*") )
			fileloader_loadCCDOPSbin(symPath,filename)
			return 1
		endif
	index += 1
	while(index < 200)
	close refnum
	
	//-------------------- no file type was recognized --------------------------
	return 0
End





Static Function/s fileName_to_waveName(fileName, convention)	// FB  05/19/03
	String fileName, convention
	
	Variable n = strlen(filename)
	NVAR first_char = root:InternalUse:prefs:gv_Nick_firstChar
	NVAR last_char = root:InternalUse:prefs:gv_Nick_lastChar
	
	String NickName
	
	strswitch(convention)
		case "SES":
		case "FITS":
				Variable p_ext = strsearch(fileName,".txt",0)
				NickName = CleanUpName(fileName[first_char, last_char],0)+"_"+fileName[p_ext-3,p_ext-1]
			break					
		case "SES_pxt":	
				NickName = CleanUpName(fileName[n-6,n-1],0)
			break
		case "VG1Z":		
				NickName = CleanUpName("VG"+fileName[4, 9]+fileName[11, 13],0)
			break
		case "pref":
				NickName = CleanUpName(fileName[first_char, last_char],0)
			break
		default:			
				NickName = CleanUpName(fileName[first_char, last_char],0)	// when no case matches
	endswitch
	
	return NickName
End





// convert the "run mode information" section of the SES-files in a easy to parse string:
// returns stringlist. first item: number of blocks in region, following items: keyword-value packed angles
Static Function/S sFunc_SES_dim3(symPath, filename, Region_number)
	String symPath, filename
	Variable Region_number
	
	String key1 = "="
	String key2 = "="
	String key3 = ";"
	Variable p1, p2, p11, p21, step
	Variable refnum
	
	String SES_line, dim3str=""
	
	Open/R /P=$symPath refnum filename
	do
		FReadline/N=128 refnum, SES_line
		
		// e.g. [Data 1:1] at the end of the header lines of Region 1
		if (stringmatch(SES_line, "[Data "+num2str(region_number)+"*") )
			break
		endif
		
		if (stringmatch(SES_line, "Dimension 3 size=*") )	// this block is above the run mode information
			dim3str += StringByKey("Dimension 3 size",SES_line,"=","\r")+";"
		endif
		
		if (stringmatch(SES_line, "[Run Mode Information "+num2str(Region_number)+"]\r") )
			step=1
			do
				FReadline refnum, SES_line
				if (stringmatch(SES_line,"Step*")==0)
					break
				endif
				p1 = StrSearch(SES_line, key1,0)
				p11 = StrSearch(SES_line, key3,p1)
				p2 = StrSearch(SES_line, key2,p11)
				p21 = StrSearch(SES_line, key3,p2)
				
				dim3str += "T"+num2str(step)+"="+SES_line[p1+1,p11-1]+";"
				dim3str += "F"+num2str(step)+"="+SES_line[p2+1, p21-1]+";"
			
				step += 1
			while (1)
		break
		endif
	while(1)
	
	Close refnum
	return dim3str
End




Static Function/S Bxsf_readLine(refnum)
	Variable refnum
	String line
	for(line = ""; (strlen(line) == 0); )
		FReadline refnum, line	
		if (strlen(line) == 0)
			return ""
		endif
		line = utils_trimSpaces(line)
		Variable comment = strsearch(line, "#", 0)
		if (comment != -1)
			line = line[0,comment-1]
		endif
	endfor
	return line
End



Static Function/S Bxsf_nextNumber(line)
	String line
	line = utils_trimSpaces(line)
	Variable nextIdx = strsearch(line, " ", 0)
	Variable i2 = strsearch(line, "\t", 0)
	if (nextIdx == -1)
		nextIdx = i2
	elseif (i2 != -1)
		nextIdx = min(i2, nextIdx)
	endif
	
	String num
	String remainder
	if (nextIdx == -1)
		num = line
		remainder = ""
	else
		num = line[0, nextIdx-1]
		remainder = utils_trimSpaces(line[nextIdx, strlen(line)])
	endif
	Variable/G V_number
	V_number = str2num(num)
	return remainder
End



Function fileloader_loadBxsf(symPath,FileName)
	String symPath, filename
	Variable refnum
	String line

	String DF = GetDataFolder(1)
	SetDataFolder root:

	Open/R /P=$symPath refnum filename

	line = Bxsf_readLine(refnum)
	if (stringmatch(line, "BEGIN_INFO") != 1)
		Abort "File does not start with BEGIN_INFO."
	endif

	Variable EF
	line = Bxsf_readLine(refnum)
	sscanf line, "Fermi Energy:%*[\t ]%e", EF
	if (V_Flag != 1)
		Abort "Expected Fermi Energy after BEGIN_INFO"
	endif

	line = Bxsf_readLine(refnum)
	if (stringmatch(line, "END_INFO") != 1)
		Abort "Expected END_INFO after BEGIN_INFO."
	endif

	line = Bxsf_readLine(refnum)
	if (stringmatch(line, "BEGIN_BLOCK_BANDGRID_3D") != 1)
		Abort "Expected BEGIN_BLOCK_BANDGRID_3D after END_INFO."
	endif
	
	line = Bxsf_readLine(refnum)
	if (stringmatch(line, "band_energies") != 1)
		Abort "Sorry, only band_energies is currently supported."
	endif
	
	line = Bxsf_readLine(refnum)
	if (stringmatch(line, "BANDGRID_3D_BANDS") != 1)
		Abort "Expected BANDGRID_3D_BANDS after BEGIN_BLOCK_BANDGRID_3D."
	endif
	
	Variable numBands
	line = Bxsf_readLine(refnum)
	sscanf line, "%e", numBands
	if (V_Flag != 1)
		Abort "Expected number of bands after BANDGRID_3D_BANDS"
	endif
	
	Variable numVecX, numVecY, numVecZ
	line = Bxsf_readLine(refnum)
	sscanf line, "%d%*[\t ]%d%*[\t ]%d", numVecX, numVecY, numVecZ
	if (V_Flag != 3)
		Abort "Expected number of x, y, and z coordinates after BANDGRID_3D_BANDS"
	endif
	
	Variable originX, originY, originZ
	line = Bxsf_readLine(refnum)
	sscanf line, "%e%*[\t ]%e%*[\t ]%e", originX, originY, originZ
	if (V_Flag != 3)
		Abort "Expected origin coordinates after BANDGRID_3D_BANDS"
	endif

	Variable vec1x, vec1y, vec1z
	line = Bxsf_readLine(refnum)
	sscanf line, "%e%*[\t ]%e%*[\t ]%e", vec1x, vec1y, vec1z
	if (V_Flag != 3)
		Abort "Expected coordinates after BANDGRID_3D_BANDS"
	endif
	
	Variable vec2x, vec2y, vec2z
	line = Bxsf_readLine(refnum)
	sscanf line, "%e%*[\t ]%e%*[\t ]%e", vec2x, vec2y, vec2z 
	if (V_Flag != 3)
		Abort "Expected coordinates after BANDGRID_3D_BANDS"
	endif
	
	Variable vec3x, vec3y, vec3z
	line = Bxsf_readLine(refnum)
	sscanf line, "%e%*[\t ]%e%*[\t ]%e", vec3x, vec3y, vec3z
	if (V_Flag != 3)
		Abort "Expected coordinates after BANDGRID_3D_BANDS"
	endif
	
	String wname = fileName_to_waveName(FileName, "Bxsf")
	Make/O/N=(numVecX, numVecY, numVecZ, numBands) $wname
	WAVE w = $wname
	Variable i
	Variable bandIdx = 0 // Purely for sanity checks
	Variable foundEOF = 0
	Variable wx = numVecX, wy = 0, wz = 0, wbands = -1
	For(line = Bxsf_readLine(refnum); strlen(line) != 0; line = Bxsf_readLine(refnum))
		if (stringmatch(line, "BAND:*") == 1)
			sscanf line, "BAND:%*[\t ]%d", wbands
			if (V_Flag != 1)
				Abort "Expected number after BAND:"
			endif
			if ((wx != numVecX) || (wy != 0) || (wz != 0))
				DoAlert 0, "WARNING: Band did not contain same number of points as claimed"
			endif
			wx = 0
			wy = 0
			wz = 0
			bandIdx += 1
		elseif (stringmatch(line, "END_BANDGRID_3D") == 1)
			foundEOF = 1
			If (bandIdx != numBands)
				DoAlert 0, "WARNING: Failed sanity check: # bands present in file != # expected bands"
			EndIf
			break
		else
			For( ; strlen(line) > 0; )
				line = Bxsf_nextNumber(line)
				NVAR V_number
				w[wx][wy][wz][wbands-1] = V_number
				wz += 1
				If(wz >= numVecZ)
					wz = 0
					wy += 1
				EndIf
				If(wy >= numVecY)
					wy = 0
					wx += 1
				EndIf
			EndFor
		endif
	EndFor
	if (foundEOF == 0)
		Abort "Unexpected end of file while reading in band data."
	endif

	line = Bxsf_readLine(refnum)
	if (stringmatch(line, "END_BLOCK_BANDGRID_3D") != 1)
		Abort "Expected END_BLOCK_BANDGRID_3D after END_BANDGRID_3D."
	endif

	line = Bxsf_readLine(refnum)
	if (strlen(line) > 0)
		DoAlert 0, "WARNING: Expected EOF, but more data available(?!), and I'm going to ignore that."
	endif

	String wnote = ""
	wnote += "FermiEnergy="+num2str(EF)+"\r"
	wnote += "OriginX="+num2str(originX)+"\r"
	wnote += "OriginY="+num2str(originY)+"\r"
	wnote += "OriginZ="+num2str(originZ)+"\r"
	wnote += "Vec1X="+num2str(vec1X)+"\r"
	wnote += "Vec1Y="+num2str(vec1Y)+"\r"
	wnote += "Vec1Z="+num2str(vec1Z)+"\r"
	wnote += "Vec2X="+num2str(Vec2X)+"\r"
	wnote += "Vec2Y="+num2str(Vec2Y)+"\r"
	wnote += "Vec2Z="+num2str(Vec2Z)+"\r"
	wnote += "Vec3X="+num2str(Vec3X)+"\r"
	wnote += "Vec3Y="+num2str(Vec3Y)+"\r"
	wnote += "Vec3Z="+num2str(Vec3Z)+"\r"
	wnote +=  "BxsfFormat=band_energies\r"
	wnote += "WaveFormat=raw\r"
	Note/K w, wnote
	
	Close refnum
	
	SetDataFolder $DF
End



// convert the header for the region, specified by the 'Region_number' to a wave-note string			// FB  05/19/03
Static Function/S sFunc_SES_header(symPath,filename,Region_number)		
	String symPath, filename
	Variable Region_number

	String SES_line
	String noteStrList=""
	String noteStr
	String slicevalues
	String str0, str1
	
	Variable refnum
	Variable x0,x1, aux0, aux1
	
	// convert the header between [Region N] and [Data N] in a Keyword-Value paired string-list
	Open/R /P=$symPath refnum filename
	do
		FReadline/N=12 refnum, SES_line
		if (stringmatch(SES_line, "[Region "+num2str(Region_number)+"]\r") )
			break
		endif
	while(1)	// scrolls to [Region N]
	
	
	// for the Helm files, we need to cut the 'Region Name' line of the header, the same line for the V-4 files contains the instrument line, which should appear in the note
	FReadline refnum, SES_line		
	if (stringmatch(SES_line, "Region Name=*")==0)
		noteStrList += SES_line
	endif
	
	do
		FReadline/N=128 refnum, SES_line
		if (stringmatch(SES_line, "[Data*") )
			break
		endif
		
		noteStrList += SES_line
	while (1)	// adds the lines up to [Data*
	Close refnum


	// get the dimension 2 values
	String instrument = StringbyKey("Instrument",noteStrList,"=","\r")
	if (stringmatch(instrument,"SES 200-16"))										// BL V-4 files
		sliceValues = StringbyKey("Slice Values (Deg)",noteStrList,"=","\r")
		x0 = str2num(sliceValues[0,22])	// probably not very stable programming...
		x1 = str2num(sliceValues[23,45])
	else
		sliceValues = StringbyKey("Dimension 2 scale",noteStrList,"=","\r")			// HeLM files
		aux0 = strsearch(sliceValues," ",2)
		aux1 = strsearch(sliceValues," ",aux0+2)
		str0 = sliceValues[0,aux0]
		x0 = str2num(str0)
		str1 = sliceValues[aux0+1,aux1]
		x1 = str2num(str1)
	endif
	if (stringmatch(num2str(x0),"Nan") || stringmatch(num2str(x1),"Nan") )		// scale with the slice numbers
		x0 = 0
		x1 = 1
	endif

	
	// get the values from the string-list
	String location = StringbyKey("Location",noteStrList,"=","\r")
	String user = StringbyKey("User",noteStrList,"=","\r")
	String sample = StringbyKey("Sample",noteStrList,"=","\r")
	String comments = StringbyKey("Comments",noteStrList,"=","\r")
	String startDate = StringbyKey("Date",noteStrList,"=","\r")
	String startTime = StringbyKey("Time",noteStrList,"=","\r")
	String detectorChannels = StringbyKey("Detector Channels",noteStrList,"=","\r")
	String regionName = StringbyKey("Region Name",noteStrList,"=","\r")
	String excitationEnergy = StringbyKey("Excitation Energy",noteStrList,"=","\r")
	String aquisitionmode = StringbyKey("Aquisition Mode",noteStrList,"=","\r")
	String lowEnergy = StringbyKey("Low Energy",noteStrList,"=","\r")
	String highEnergy = StringbyKey("High Energy",noteStrList,"=","\r")
	String EnergyStep = StringbyKey("Energy Step",noteStrList,"=","\r")
	String stepTime = StringbyKey("Step Time",noteStrList,"=","\r")
	String firstXchannel = StringbyKey("Detector First X-Channel",noteStrList,"=","\r")
	String lastXchannel = StringbyKey("Detector Last X-Channel",noteStrList,"=","\r")
	String firstYchannel = StringbyKey("Detector First Y-Channel",noteStrList,"=","\r")
	String lastYchannel = StringbyKey("Detector Last Y-Channel",noteStrList,"=","\r")
	String numberofslices = StringbyKey("Number of Slices",noteStrList,"=","\r")
	String Lensmode = StringbyKey("Lens Mode",noteStrList,"=","\r")
	String passEnergy = StringbyKey("Pass Energy",noteStrList,"=","\r")
	String numberofsweeps = StringbyKey("Number of Sweeps",noteStrList,"=","\r")
	String manipulatorZ = StringbyKey("Z",noteStrList,"=","\r")
	String manipulatorX = StringbyKey("X",noteStrList,"=","\r")
	String manipulatorY = StringbyKey("Y",noteStrList,"=","\r")
	String sampleTemperature = StringByKey("SampleTemperature",noteStrList,"=","\r")
	
	
	// manipulator angles: 
	// first search for 'Theta'/'Phi' keywords. If the '[User Interface Information] section is available, overwrite with the 'T'/'F' values.
	// If the [Run Mode Information] section is available, the values will be overwritten again in 'fileloader_loadSEStxt'.
	Variable phi = round(NumberbyKey("Phi",noteStrList,"=","\r") * 1e4) / 1e4
	Variable theta = round(NumberbyKey("Theta",noteStrList,"=","\r") * 1e4) / 1e4
	Variable alpha = round(NumberbyKey("Alpha",noteStrList,"=","\r") * 1e4) / 1e4
	if (stringmatch(notestrList,"*[User Interface Information*"))
		phi = round(NumberbyKey("F",noteStrList,"=","\r") * 1e4) / 1e4
		theta = round(NumberbyKey("T",noteStrList,"=","\r") * 1e4) / 1e4
		alpha = round(NumberbyKey("A",noteStrList,"=","\r") * 1e4) / 1e4
	endif
	if (numtype(alpha) != 0)
		alpha = 0
	endif
	// make the correct note
	noteStr = fileloader_NoteKeyList(1)		// with the scienta keywords
	String NickName = fileName_to_waveName(fileName,"SES")
	noteStr = ReplaceStringByKey("WaveName", noteStr,NickName,"=","\r")
	noteStr = ReplaceStringByKey("RawDataWave", noteStr,"root:carpets:"+NickName,"=","\r")
	noteStr = ReplaceStringByKey("FileName", noteStr,filename,"=","\r")
	noteStr = ReplaceStringByKey("Sample", noteStr,Sample,"=","\r")
	noteStr = ReplaceStringByKey("Comments", noteStr,Comments,"=","\r")
	noteStr = ReplaceStringByKey("StartDate", noteStr,StartDate,"=","\r")
	noteStr = ReplaceStringByKey("StartTime", noteStr,StartTime,"=","\r")
	noteStr = ReplaceStringByKey("Instrument", noteStr,Instrument,"=","\r")
	noteStr = ReplaceStringByKey("MeasurementSoftware", noteStr,"unknown","=","\r")
	noteStr = ReplaceStringByKey("User", noteStr,user,"=","\r")
	noteStr = ReplaceStringByKey("SampleTemperature",noteStr,SampleTemperature,"=","\r")
	noteStr = ReplaceStringByKey("ManipulatorType", noteStr,"flip","=","\r")
	noteStr = ReplaceStringByKey("AnalyzerType", noteStr,"2D","=","\r")
	noteStr = ReplaceStringByKey("AnalyzerMode", noteStr,aquisitionmode,"=","\r")
	if (stringmatch(lensmode,"Transmission"))
		noteStr = ReplaceStringByKey("XScanType", noteStr,"ScientaTransmission","=","\r")
	elseif (stringmatch(lensmode,"Angular"))
		noteStr = ReplaceStringByKey("XScanType", noteStr,"ScientaAngular","=","\r")
	else
		noteStr = ReplaceStringByKey("XScanType", noteStr,"unknown","=","\r")
	endif
	
	noteStr = ReplaceStringByKey("FirstEnergy", noteStr,lowEnergy,"=","\r")	// do all Scienta's scan from low to high??
	noteStr = ReplaceStringByKey("LastEnergy", noteStr,highEnergy,"=","\r")
	aux0 = round( abs(str2num(lowEnergy) - str2num(highenergy) ) / str2num(EnergyStep) +1 )
	noteStr = ReplaceStringByKey("NumberOfEnergies", noteStr,num2str(aux0),"=","\r")
	noteStr = ReplaceNumberByKey("InitialThetaManipulator", noteStr,theta,"=","\r")
	noteStr = ReplaceNumberByKey("FinalThetaManipulator", noteStr,theta,"=","\r")
	noteStr = ReplaceStringByKey("OffsetThetaManipulator", noteStr,"0","=","\r")
	noteStr = ReplaceNumberByKey("InitialPhiManipulator", noteStr,Phi,"=","\r")
	noteStr = ReplaceNumberByKey("FinalPhiManipulator", noteStr,Phi,"=","\r")
	noteStr = ReplaceNumberByKey("InitialAlphaManipulator", noteStr,alpha,"=","\r")
	noteStr = ReplaceNumberByKey("FinalAlphaManipulator", noteStr,alpha,"=","\r")
	noteStr = ReplaceStringByKey("OffsetPhiManipulator", noteStr,"0","=","\r")
	noteStr = ReplaceStringByKey("NumberOfManipulatorAngles", noteStr,"1","=","\r")
	// what about the omega? try 0 as a default
	noteStr = ReplaceStringByKey("InitialOmegaManipulator", noteStr,"0","=","\r")
	noteStr = ReplaceStringByKey("FinalOmegaManipulator", noteStr,"0","=","\r")
	noteStr = ReplaceStringByKey("OffsetOmegaManipulator", noteStr,"0","=","\r")
	
	noteStr = ReplaceStringByKey("PhotonEnergy", noteStr, excitationEnergy,"=","\r")
	noteStr = ReplaceStringByKey("PassEnergy", noteStr,passEnergy,"=","\r")
	noteStr = ReplaceStringByKey("DwellTime", noteStr,stepTime,"=","\r")
	noteStr = ReplaceStringByKey("NumberOfSweeps", noteStr,numberofsweeps,"=","\r")
	
	noteStr = ReplaceStringByKey("RegionName", noteStr,regionName,"=","\r")
	// scienta orientation? try 90 as a default
	//noteStr = ReplaceStringByKey("ScientaOrientation", noteStr,"90","=","\r")	// this is too much confusing
	
	noteStr = ReplaceStringByKey("CCDFirstXChannel", noteStr,firstXchannel,"=","\r")
	noteStr = ReplaceStringByKey("CCDLastXChannel", noteStr,lastXchannel,"=","\r")
	noteStr = ReplaceStringByKey("CCDFirstYChannel", noteStr,firstYchannel,"=","\r")
	noteStr = ReplaceStringByKey("CCDLastYChannel", noteStr,lastYchannel,"=","\r")
	noteStr = ReplaceStringByKey("NumberOfSlices", noteStr,numberofslices,"=","\r")
	
	Variable channel_slice = (str2num(lastYchannel)-str2num(firstYchannel)+1)/str2num(NumberOfSlices)
	Variable degChannel = (x1-x0) / channel_slice
	degChannel = round (degChannel * 1e7) / 1e7
	Variable channelZero = str2num(firstYchannel) + x0/(x0-x1) * channel_slice + 1		// check the '+1'!
	channelZero = round(channelZero * 1e4) / 1e4
	//String s1
	//sprintf s1, "%18.16f", degChannel		// num2str is limited to 5 digits!
	//noteStr = ReplaceStringByKey("CCDDegreePerChannel", noteStr,s1,"=","\r")
	noteStr = ReplaceNumberByKey("CCDXChannelZero", noteStr,ChannelZero,"=","\r")
	noteStr = ReplaceNumberByKey("CCDDegreePerChannel", noteStr,degChannel,"=","\r")
	
	notestr = ReplaceStringByKey("MatrixType", noteStr, "carpet","=","\r")
	noteStr = ReplaceStringByKey("AngleMapping", noteStr,"none","=","\r")
	noteStr = ReplaceStringByKey("EnergyScale", noteStr,"kinetic","=","\r")
	
	return noteStr
End





Static Function/S convert_SES_pxt_note(oldNote)
	String oldNote
	
	String notestr = fileloader_NoteKeyList(1)
	//Add \n for new ses software of ALS and delet the \n in th begining of the sring by Wei-Shneg
	String instrument = StringbyKey("Instrument",oldNote,"=","\r\n")
	String location = StringbyKey("Location",oldNote,"=","\r\n")
	String user = StringbyKey("User",oldNote,"=","\r\n")
	String sample = StringbyKey("Sample",oldNote,"=","\r\n")
	String comments = StringbyKey("Comments",oldNote,"=","\r\n")
	String n_date = StringbyKey("Date",oldNote,"=","\r\n")
	String n_time = StringbyKey("Time",oldNote,"=","\r\n")
	String detectorchannels = StringbyKey("Detector Channels",oldNote,"=","\r\n")
	String regionName = StringbyKey("Region Name",oldNote,"=","\r\n")
	String hn = StringbyKey("Excitation Energy",oldNote,"=","\r\n")
	String energyScale = StringbyKey("Energy Scale",oldNote,"=","\r\n")
	String aqMode = StringbyKey("Aquisition Mode",oldNote,"=","\r\n")
	String eLow = StringbyKey("Low Energy",oldNote,"=","\r\n")
	String eHigh = StringbyKey("High Energy",oldNote,"=","\r\n")
	String eStep = StringbyKey("Energy Step",oldNote,"=","\r\n")
	String dwell = StringbyKey("Step Time",oldNote,"=","\r\n")
	String firstXchannel = StringbyKey("Detector First X-Channel",oldNote,"=","\r\n")
	String lastXchannel = StringbyKey("Detector Last X-Channel",oldNote,"=","\r\n")
	String firstYchannel = StringbyKey("Detector First Y-Channel",oldNote,"=","\r\n")
	String lastYchannel = StringbyKey("Detector Last Y-Channel",oldNote,"=","\r\n")
	String nSlices = StringbyKey("Number of Slices",oldNote,"=","\r\n")
	String xScanType = StringbyKey("Lens Mode",oldNote,"=","\r\n")
	String passEnergy = StringbyKey("Pass Energy",oldNote,"=","\r\n")
	String nSweeps = StringbyKey("Number of Sweeps",oldNote,"=","\r\n")
	
	
	noteStr = ReplaceStringByKey("Instrument", noteStr,Instrument,"=","\r")
	noteStr = ReplaceStringByKey("User", noteStr,User,"=","\r")
	noteStr = ReplaceStringByKey("Sample", noteStr,sample,"=","\r")
	noteStr = ReplaceStringByKey("Comments", noteStr,comments,"=","\r")
	noteStr = ReplaceStringByKey("StartDate", noteStr,n_date,"=","\r")
	noteStr = ReplaceStringByKey("StartTime", noteStr,n_time,"=","\r")
	noteStr = ReplaceStringByKey("RegionName", noteStr,regionName,"=","\r")
	noteStr = ReplaceStringByKey("PhotonEnergy", noteStr,hn,"=","\r")
	noteStr = ReplaceStringByKey("EnergyScale", noteStr,EnergyScale,"=","\r")
	noteStr = ReplaceStringByKey("AnalyzerMode", noteStr,aqMode,"=","\r")
	noteStr = ReplaceStringByKey("FirstEnergy", noteStr,eLow,"=","\r")
	noteStr = ReplaceStringByKey("LastEnergy", noteStr,eHigh,"=","\r")
	noteStr = ReplaceStringByKey("DwellTime", noteStr,dwell,"=","\r")
	noteStr = ReplaceStringByKey("CCDFirstXChannel", noteStr,firstXchannel,"=","\r")
	noteStr = ReplaceStringByKey("CCDLastXChannel", noteStr,lastXchannel,"=","\r")
	noteStr = ReplaceStringByKey("CCDFirstYChannel", noteStr,firstYchannel,"=","\r")
	noteStr = ReplaceStringByKey("CCDLastYChannel", noteStr,lastYchannel,"=","\r")
	noteStr = ReplaceStringByKey("NumberOfSlices", noteStr,nSlices,"=","\r")
	noteStr = ReplaceStringByKey("XScanType", noteStr,xScanType,"=","\r")
	noteStr = ReplaceStringByKey("PassEnergy", noteStr,passEnergy,"=","\r")
	noteStr = ReplaceStringByKey("NumberOfSweeps", noteStr,nSweeps,"=","\r")
	
//	noteStr = ReplaceStringByKey("", noteStr,,"=","\r")
//	noteStr = ReplaceStringByKey("", noteStr,,"=","\r")
//	noteStr = ReplaceStringByKey("", noteStr,,"=","\r")
	
	return notestr
End






// write VG1Z header info in a string with linebreaks after the keyword-values			FB 11/7/02
// 5/14/03 modified to take symbolic path as input
// 12/22/03 modified for i_photo keywords
Static Function/S sFunc_VG1Z_header(symPath, fileName)
	String symPath, fileName

	//String w_Note = ""
	
	String ext = filename[14,strlen(fileName)-1]		// extension
	String MeasurementType, HoloMode
	
	Variable spec = StringMatch(ext,"")
	Variable xpd = StringMatch(ext,".p1") + StringMatch(ext,".pt1") + StringMatch(ext,".a1") + StringMatch(ext,".at1")
	Variable carpet = StringMatch(ext,".p1.s") + StringMatch(ext,".pt1.s") + StringMatch(ext,".a1.s") + StringMatch(ext,".at1.s")
	Variable holo =  StringMatch(ext,".h1") + StringMatch(ext,".ht1")
	Variable azi = StringMatch(ext,".a1") + StringMatch(ext,".at1") + StringMatch(ext,".a1.s") + StringMatch(ext,".at1.s")
	Variable polar = StringMatch(ext,".p1") + StringMatch(ext,".pt1") + StringMatch(ext,".p1.s") + StringMatch(ext,".pt1.s")

	// Kill all old Header-waves:
	KillWaves_withBase("c_0_*")
	KillWaves_withBase("c_1_*")
	KillWaves_withBase("c_2_*")
	KillWaves_withBase("c_3_*")
	KillWaves_withBase("c_4_*")
	

	// first we load all the information from the header in Strings with (usually..) the same names as the Keywords:
	
	// load the first 10 lines as text (common for spectra, carpets and holos)
	//LoadWave/J/Q/K=2/V={""," $",0,0}/L={0,0,10,0,1}/A=c_0_Header fullPath
	LoadWave/J/Q/K=2/L={0,0,10,0,1}/A=c_0_Header /P=$symPath filename
		Wave/T header0 = c_0_Header0
		
		String PhotonEnergy
		String Comments = header0[1]
		String StartDate = header0[2]
		String StartTime = header0[3]
		String PhotonSource = header0[4]
		String AnalyzerMode = header0[5]
		// who knows the meaning of the 6th entry??
		String Slit = header0[7]
		String User = header0[8]
		
		if (stringmatch(PhotonSource,"H1"))
			PhotonEnergy = "21.22"
		elseif (stringmatch(PhotonSource,"H2"))
			PhotonEnergy = "40.8"
		elseif (stringmatch(PhotonSource,"Si"))
			PhotonEnergy = "1740.0"
		elseif (stringmatch(PhotonSource,"Al"))
			PhotonEnergy = "1486.6"
		elseif (stringmatch(PhotonSource,"Mg"))
			PhotonEnergy = "1253.6"
		endif
		
	// load the following 4 lines as 3 text-waves (common for spectra, carpets and holos)
	//LoadWave/J/Q/K=2/V={"\t "," $",0,0}/L={0,10,4,1,4}/A=c_1_Header fullPath
	LoadWave/J/Q/K=2/V={"\t "," $",0,0}/L={0,10,4,1,4}/A=c_1_Header /P=$symPath filename
		Wave/T header1 = c_1_Header0
		Wave/T header2 = c_1_Header1
		Wave/T header3 = c_1_Header2
		
		String EnergyFirst = ReplaceString(" ", header1[0], "")		// used to scale the carpets
		String EnergyLast = ReplaceString(" ", header2[0], "")
		String PassEnergy = ReplaceString(" ", header3[0], "")
		String DwellTime = ReplaceString(" ", header1[1], "")
		String NumberOfSweeps = ReplaceString(" ", header2[1], "")
		String NumberOfEnergies = ReplaceString(" ", header3[1], "")
		String ThetaInitial = ReplaceString(" ", header1[2], "")		// these angles are only comments and will be overwritten for holos and carpets
		String PhiInitial = ReplaceString(" ", header2[2], "")
		String Iris = header3[2]
		String SampleTemperature = ReplaceString(" ", header1[3], "")		
		
		String SamplePressure = ReplaceString(" ", header2[3], "")	
		
	
	// for carpets and xpd-scans: load the angle information (line 16 of the header)
	if (xpd || carpet)
		//LoadWave/J/Q/K=2/V={"\t "," $",0,0}/L={0,16,1,1,3}/A=c_2_Header fullPath
		LoadWave/J/Q/K=2/V={"\t "," $",0,0}/L={0,16,1,1,3}/A=c_2_Header/P=$symPath filename
		Wave/T header4 = c_2_Header0
		Wave/T header5 = c_2_Header1
		Wave/T header6 = c_2_Header2
			
		if (azi)
			String motor_PhiInitial = ReplaceString(" ", header4[0], "")
			String motor_PhiFinal = ReplaceString(" ", header5[0], "")
			String motor_PhiStep = ReplaceString(" ", header6[0], "")
			if (xpd)
				MeasurementType = "Azimuthal Scan at Fixed Energy"
			else
				MeasurementType = "Azimuthal scan of spectra"
			endif
			
		elseif (polar)			
			String motor_ThetaInitial = ReplaceString(" ", header4[0], "")
			String motor_ThetaFinal = ReplaceString(" ", header5[0], "")
			String motor_ThetaStep = ReplaceString(" ", header6[0], "")
			if (xpd)
				MeasurementType = "Polar Scan at Fixed Energy"
			else
				MeasurementType = "Polar scan of spectra"
			endif
		endif
	endif
	
	// only for holos: angle mode is line 15, angle information are lines 16-18 (5 columns) of header
	if ( holo ) 
		//LoadWave/J/Q/K=2/V={"\t "," $",0,0}/L={0,15,1,0,1}/A=c_3_Header fullPath
		LoadWave/J/Q/K=2/V={"\t "," $",0,0}/L={0,15,1,0,1}/A=c_3_Header /P=$symPath filename
			Wave/T header7 = c_3_Header0
			
			if (cmpstr(header7[0], "hs\r")==0)
				HoloMode = "Stereographic"
			elseif (cmpstr(header7[0], "hp\r")==0)
				HoloMode = "Parallel"
			elseif (cmpstr(header7[0], "hn\r")==0)
				HoloMode = "Stereographic"
			else	
				HoloMode = "Unknown"
			endif
		
		//LoadWave/J/Q/K=2/V={"\t "," $",0,0}/L={0,16,3,0,5}/A=c_4_Header fullpath
		LoadWave/J/Q/K=2/V={"\t "," $",0,0}/L={0,16,3,0,5}/A=c_4_Header/P=$symPath filename
			Wave/T header8 = c_4_Header0
			Wave/T header9 = c_4_Header1
			Wave/T header10 = c_4_Header2
			Wave/T header11 = c_4_Header3
			Wave/T header12 = c_4_Header4
			
			MeasurementType = "Hologram Scan at Fixed Energy"	//	assume peak-mode
			motor_ThetaInitial = ReplaceString(" ", header8[0], "")
			String ThetaRange = ReplaceString(" ", header9[0], "")
			String ThetaStep = ReplaceString(" ", header10[0], "")
			String ThetaNormal = ReplaceString(" ", header11[0], "")
			motor_PhiInitial = ReplaceString(" ", header8[1], "")
			String PhiRange = ReplaceString(" ", header9[1], "")
			String PhiStep = ReplaceString(" ", header10[1], "")
			String PhiSymmetryAxis = ReplaceString(" ", header11[1], "")
			String PhiRefinement = ReplaceString(" ", header12[1], "")
			String SymmetryRange = ReplaceString(" ", header8[2], "")
	endif									// now we've got all the information from the header in Strings
	
	//if ( spec )
	//	MeasurementType = "Energy Spectrum"
	//endif
	
	

	
	
	// Notes common to all cases:
	String noteStr = fileloader_NoteKeyList(2)		// with the MacESCA keywords
	String NickName = fileName_to_waveName(fileName,"VG1Z")
	
	noteStr = ReplaceStringByKey("WaveName", noteStr,NickName,"=","\r")
	noteStr = ReplaceStringByKey("FileName", noteStr,FileName,"=","\r")
	noteStr = ReplaceStringByKey("Comments", noteStr,Comments,"=","\r")
	noteStr = ReplaceStringByKey("StartDate", noteStr,StartDate,"=","\r")
	noteStr = ReplaceStringByKey("StartTime", noteStr,StartTime,"=","\r")
	noteStr = ReplaceStringByKey("Instrument", noteStr,"VG ESCALAB220","=","\r")
	noteStr = ReplaceStringByKey("MeasurementSoftware", noteStr,"MacESCAII","=","\r")
	noteStr = ReplaceStringByKey("User", noteStr,User,"=","\r")
	
	noteStr = ReplaceStringByKey("ManipulatorType", noteStr,"Fadley","=","\r")
	noteStr = ReplaceStringByKey("AnalyzerType", noteStr,"1D","=","\r")
	
	noteStr = ReplaceStringByKey("FirstEnergy", noteStr,EnergyFirst,"=","\r")
	noteStr = ReplaceStringByKey("LastEnergy", noteStr,EnergyLast,"=","\r")
	noteStr = ReplaceStringByKey("NumberOfEnergies", noteStr,NumberOfEnergies,"=","\r")
	
	noteStr = ReplaceStringByKey("PhotonEnergy", noteStr,PhotonEnergy,"=","\r")

	noteStr = ReplaceStringByKey("SampleTemperature", noteStr,SampleTemperature,"=","\r")
	noteStr = ReplaceStringByKey("PassEnergy", noteStr,PassEnergy,"=","\r")
	noteStr = ReplaceStringByKey("DwellTime", noteStr,DwellTime,"=","\r")
	noteStr = ReplaceStringByKey("NumberOfSweeps", noteStr,NumberOfSweeps,"=","\r")
	
	noteStr = ReplaceStringByKey("PhotonSource", noteStr,photonsource,"=","\r")
	noteStr = ReplaceStringByKey("LensSlit", noteStr,slit,"=","\r")
	noteStr = ReplaceStringByKey("LensIris", noteStr,iris,"=","\r")
	
	noteStr = ReplaceStringByKey("EnergyScale", noteStr,"kinetic","=","\r")
	
//	w_note += "Instrument=VG ESCALAB220\r"
//	w_note += "User=" + User + "\r"
//	w_note += "FileName=" + fileName + "\r"
//	w_note += "MeasurementSoftware=MacESCAII" + "\r"
//	w_note += "MeasurementType=" + MeasurementType + "\r"
//	w_note += "Comments=" + Comments + "\r"
//	w_note += "StartDate=" + StartDate + "\r"
//	w_note += "StartTime=" + StartTime + "\r"
//	w_note += "PhotonSource=" + PhotonSource + "\r"
//	w_note += "PhotonEnergy=" + PhotonEnergy+ "\r"
//	w_note += "AnalyzerMode=" + AnalyzerMode + "\r"
//	w_note += "Slit=" + Slit + "\r"
//	w_note += "Iris=" + Iris + "\r"
//	w_note += "SampleTemperature=" + SampleTemperature + "\r"
//	w_note += "SamplePressure=" + SamplePressure + "\r"
//	w_note += "ThetaInitial=" + ThetaInitial + "\r"		// these angles are only comments and will be overwritten for holos and carpets
//	w_note += "PhiInitial=" + PhiInitial + "\r"
//	
//	w_note += "\r"				// a lovely space
//	w_note += "EnergyFirst=" + EnergyFirst + "\r"
//	w_note += "EnergyLast=" + EnergyLast + "\r"
//	w_note += "NumberOfEnergies=" + NumberOfEnergies + "\r"
//	w_note += "PassEnergy=" + PassEnergy + "\r"
//	w_note += "DwellTime=" + DwellTime + "\r"
//	w_note += "NumberOfSweeps=" + NumberOfSweeps + "\r"
//	w_note += "\r"				// and another lovely space
	
//	
//	// angle notes:
//	if (spec)
//		w_note += ""
//		w_note += "x_eUnits=eV" + "\r"
//		w_note += "x_eAxis=Ek" + "\r"
//	endif
	
	
	if (xpd || carpet)
		if (polar)
			noteStr = ReplaceStringByKey("InitialThetaManipulator", noteStr,motor_Thetainitial,"=","\r")
			noteStr = ReplaceStringByKey("FinalThetaManipulator", noteStr,motor_ThetaFinal,"=","\r")
			//w_note += "motor_ThetaInitial=" + motor_ThetaInitial + "\r"
			//w_note += "motor_ThetaFinal=" + motor_ThetaFinal + "\r"
			//w_note += "motor_ThetaStep=" + motor_ThetaStep + "\r"
		else
			noteStr = ReplaceStringByKey("InitialOmegaManipulator", noteStr,motor_PhiInitial,"=","\r")
			noteStr = ReplaceStringByKey("FinalOmegaManipulator", noteStr,motor_PhiFinal,"=","\r")
			//w_note += "motor_PhiInitial=" + motor_PhiInitial + "\r"
			//w_note += "motor_PhiFinal=" + motor_PhiFinal + "\r"
			//w_note += "motor_PhiStep=" + motor_PhiStep + "\r"
		endif
		if (carpet)
			//w_note += "" + "\r"
			//w_note += "x_eUnits=eV" + "\r"
			//w_note += "x_eAxis=Ek" + "\r"
		endif
		//w_note += "x_mUnits=deg" + "\r"
	endif
	
	
	if (holo)
		noteStr = ReplaceStringByKey("HoloMode", noteStr,HoloMode,"=","\r")
		//noteStr = ReplaceStringByKey("InitialThetaManipulator", noteStr,motor_Thetainitial,"=","\r")
		//noteStr = ReplaceStringByKey("FinalThetaManipulator", noteStr,motor_ThetaFinal,"=","\r")
		//noteStr = ReplaceStringByKey("InitialOmegaManipulator", noteStr,motor_PhiInitial,"=","\r")
		//noteStr = ReplaceStringByKey("FinalOmegaManipulator", noteStr,motor_PhiFinal,"=","\r")
			
//		w_note += "HoloMode=" + HoloMode + "\r"
//		w_note += "motor_ThetaInitial=" + motor_ThetaInitial + "\r"
//		w_note += "ThetaRange=" + ThetaRange + "\r"
//		w_note += "ThetaStep=" + ThetaStep + "\r"
//		w_note += "ThetaNormal=" + ThetaNormal + "\r"
//		w_note += "motor_PhiInitial=" + motor_PhiInitial + "\r"
//		w_note += "PhiRange=" + PhiRange + "\r"
//		w_note += "PhiStep=" + PhiStep + "\r"
//		w_note += "PhiSymmetryAxis=" + PhiSymmetryAxis + "\r"
//		w_note += "PhiRefinement=" + PhiRefinement + "\r"
//		w_note += " SymmetryRange=" + SymmetryRange + "\r"
	endif
	
	KillWaves_withBase("c_0_*")
	KillWaves_withBase("c_1_*")
	KillWaves_withBase("c_2_*")
	KillWaves_withBase("c_3_*")
	KillWaves_withBase("c_4_*")
	
	return noteStr		// uffa!
End






// VG1Z-files
///////////////////////////////////////////////////////////////////////////////////////////////////
Static Function load_VG1Z_spectrum(Path, Filename)		// 		FB 11/7/02
	String Path, FileName
	
	//String fullPath = Path+filename
	String DF = getDataFolder(1)
	String NickName, type
	
	SetDataFolder root:
	NewDataFolder/O/S linescans
	NewDataFolder/O/S rawData
	
	KillWaves_withBase("s_0_*")
	LoadWave/Q/G/O/L={0, 14, 0, 0, 0}/A=s_0_ /P=$path filename
		WAVE w = s_0_0
		String w_Note = sFunc_VG1Z_header(Path, filename)
		Note w, w_Note
		
	Variable first_e = NumberByKey("FirstEnergy", w_Note,"=","\r")
	Variable last_e = NumberByKey("LastEnergy", w_Note,"=","\r")
	Variable dwell = NumberByKey("DwellTime", w_Note,"=","\r")
	Variable sweeps = NumberByKey("NumberOfSweeps", w_Note,"=","\r")
	
	w /= (sweeps*dwell)
	SetScale/I x, first_e, last_e, "" w
	
	NickName = fileName_to_waveName(fileName, "VG1Z")
	Duplicate/O s_0_0 $NickName
	
	KillWaves_withBase("s_0_*")
	KillStrings/Z s_wavename
	SetDataFolder DF
End





// real angles do usually not agree with the fileheader -> prompt							FB 11/7/02
Static Function load_VG1Z_xpdScan(symPath, filename)
	String symPath, fileName

	String DF = getDataFolder(1)
	String NickName, type
	String ext = filename[14,strlen(fileName)-1]		// extension
	Variable polar = StringMatch(ext,".p1") + StringMatch(ext,".pt1") + StringMatch(ext,".p1.s") + StringMatch(ext,".pt1.s")
	Variable xi, xf
	Variable ch_index

	SetDataFolder root:
	NewDataFolder/O/S linescans
	NewDataFolder/O/S rawData
	
	// load as a matrix, cols. 1 & 2 are the angles
	LoadWave/G/M/Q/N=x_0_ /O/L={0,19,0,0,0} /P=$sympath filename			// wave as matrix
			WAVE w = x_0_0
		 	String w_Note = sFunc_VG1Z_header(symPath, filename)
			Note w, w_Note
	
	Variable dwell = NumberByKey("DwellTime", w_Note,"=","\r")
	Variable sweeps = NumberByKey("NumberOfSweeps", w_Note,"=","\r")
	if (polar >= 1)
		xi = NumberByKey("InitialThetaManipulator", w_Note,"=","\r")
		xf = NumberByKey("FinalThetaManipulator", w_Note,"=","\r")
	else
		xi = NumberByKey("InitialOmegaManipulator", w_Note,"=","\r")
		xf = NumberByKey("FinalOmegaManipulator", w_Note,"=","\r")
	endif
	
	Make/O/D/N=(dimsize(w,0)) int		//, th, ph
		
		ch_index=1
		do
			NickName = fileName_to_waveName(fileName, "VG1Z") + "_c"+num2str(ch_index)
			Note/K int
			int[]=w[p][ch_index+1]
			int/= (dwell * Sweeps)
			Note int, w_Note
	
			SetScale/I x xi,xf,"", int
			Duplicate/O int $NickName
	ch_index+=1
	while(ch_index<=6)
	
	KillWaves/Z int
	KillStrings/Z s_wavename
	KillWaves_withBase("x_0_*")
	
	SetDataFolder $DF
End






// extract the energies from the first line of the data-blocks
// flag=0 returns E0
// flag=1 returns dE
Static Function E_from_dim2Line(line, flag)
	String line
	Variable flag
	
	Variable y0, y1
	Variable pos0, pos1, pos2
	String str0, str1
	
	Variable start = 0
	do
		pos0 = StrSearch(line, "E", start)
		if (numtype(str2num(line[pos0+1])) == 0)	// first energy value
			break
		endif	
	start = pos0 +1
	while (1)
	
	// energy values:
	pos1 = StrSearch(line, "E", pos0+1)
	pos2 = StrSearch(line, "E", pos1+1)
	str0 = line[pos0+1,pos1-2]
	str1 = line[pos1+1,pos2-2]
	y0 = str2num(str0)
	y1 = str2num(str1)

	
	if (flag ==0)
		return y0
	elseif (flag==1)
		return y1 - y0
	else
		return -1
	endif
End





// return a string-list with the names of the control-variables
Static Function/S varNames_from_dim2Line(line)
	String line

	
	Variable pos0, pos1, ii
	String str0, str1
	String var_List = ""
	
	pos0 = 0
	pos1 = 0
	do
		pos1 = strsearch(line," ",pos0)
		if ( (stringmatch(line[pos1+1],"E")) && (numtype(str2num(line[pos1+2])) == 0) )
			var_List += line[pos0,pos1-1]+";"
			break
		endif
//		if (stringmatch(line[pos1+1,pos1+3],"\r"))
//			beep
//			var_List += line[pos0,pos1-1]+";"
//			break
//		endif
		if (pos1 < 0)
			var_List += line[pos0,strlen(line)-2]+";"
			break
		endif
				
		var_List += line[pos0,pos1-1]+";"		
		pos0 = pos1 +1
	while (1)

	// remove spaces:
//	for(ii=0;ii<strlen(var_List);ii+=1)
//		if(stringmatch(var_List[ii]," "))
//			var_List = var_List[0,ii-1]+var_List[ii+1,inf]
//			ii -= 1
//		endif								
//	endfor									
	return var_List
End






Static Function/S sFunc_croissant_header(symPath,filename)		
	String symPath, filename


	String c_line, notestr, noteStrList=""
	Variable refnum
	
	// convert the header in a Keyword-Value paired string-list
	Open/R /P=$symPath refnum filename
	do
		FReadline/N=128 refnum, c_line
		if (stringmatch(c_line, "[Detector]*") )
			break
		endif
		noteStrList += c_line
	while(1)	

	// generate the blank keyword-list
	noteStr = fileloader_NoteKeyList(3)		// with the croissant keywords
	
	// transfer the interesting values from the header list in the blank i_photo keyword-list
	String NickName = fileName_to_waveName(fileName, "")
	noteStr = ReplaceStringByKey("WaveName", noteStr,NickName,"=","\r")
	
	String instrument = StringbyKey("Instrument",noteStrList,"=","\r") + ", "
	instrument += StringbyKey("Location",noteStrList,"=","\r")
	noteStr = ReplaceStringByKey("Instrument", noteStr,instrument,"=","\r")
	
	String software = StringByKey("MeasurementSoftware", noteStrList, "=", "\r") + " "
	software += StringByKey("SoftwareVersion", noteStrList, "=", "\r")
	noteStr = ReplaceStringByKey("MeasurementSoftware", noteStr,software,"=","\r")
	
	notestr = addNoteValue(notestr, "Sample", noteStrList, "Sample")
	notestr = addNoteValue(notestr, "Comments", noteStrList, "Comments")
	notestr = addNoteValue(notestr, "StartDate", noteStrList, "StartDate")
	notestr = addNoteValue(notestr, "StartTime", noteStrList, "StartTime")
	notestr = addNoteValue(notestr, "User", noteStrList, "User")
	noteStr = ReplaceStringByKey("ManipulatorType", noteStr,"Fadley","=","\r")		// so far true for all croissant instruments??
	noteStr = ReplaceStringByKey("AnalyzerType", noteStr,"1D","=","\r")
	// analyzer mode?
	notestr = addNoteValue(notestr, "XScanType", noteStrList, "MeasurementType")
	notestr = addNoteValue(notestr, "FirstEnergy", noteStrList, "EnergyFirst")
	notestr = addNoteValue(notestr, "LastEnergy", noteStrList, "EnergyLast")
	notestr = addNoteValue(notestr, "NumberOfEnergies", noteStrList, "NumberOfEnergies")
	notestr = addNoteValue(notestr, "InitialThetaManipulator", noteStrList, "ThetaManipulatorInitial")
	// th_final?
	notestr = addNoteValue(notestr, "InitialOmegaManipulator", noteStrList, "PhiManipulatorInitial")
	// azi_final?
	noteStr = ReplaceStringByKey("InitialPhiManipulator", noteStr,"0","=","\r")		// so far true for all croissant instruments??
	noteStr = ReplaceStringByKey("FinalPhiManipulator", noteStr,"0","=","\r")
	// number of mani-angles?
	notestr = addNoteValue(notestr, "PhotonEnergy", noteStrList, "PhotonEnergy")
	// EF?
	notestr = addNoteValue(notestr, "SampleTemperature", noteStrList, "SampleTemperature")
	// workfunction?
	notestr = addNoteValue(notestr, "PassEnergy", noteStrList, "PassEnergy")
	notestr = addNoteValue(notestr, "DwellTime", noteStrList, "DwellTime")
	notestr = addNoteValue(notestr, "NumberOfSweeps", noteStrList, "NumberOfSweeps")
	//notestr = addNoteValue(notestr, "", noteStrList, "")
	
	return noteStr
End





Static Function/S addNoteValue(notestr, notestrKey, liststr, liststrKey)
	String notestr, notestrKey, liststr, liststrKey
	
	String value = StringByKey(liststrKey, liststr,"=","\r")
	notestr = ReplaceStringByKey(notestrKey,notestr,value,"=","\r")
	
	return notestr
End
