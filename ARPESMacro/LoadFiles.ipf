#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 0.01
#pragma ModuleName = Loadfiles




//////////////////////////////GlobalFunction////////////////////////////////




Function BeforeExperimentSaveHook(refNum, fileNameStr, pathNameStr, fileTypeStr, fileCreatorStr, fileKind )
	Variable refnum
	String filenameStr,Pathnamestr,filetypestr,filecreatorstr
	Variable filekind
	
	//doalert 1,"Clear all cubes and 3D show to save disk space?"
	//V_flag==1
	if (0)
		DFREF DF=GetDatafolderdFR()
		
		
		String objName
		Variable index = 0,cubeindex
		do
			SetDatafolder root:InternalUse:
			objName = GetIndexedObjName(":", 4, index)
			if (strlen(objName) == 0)
				break
			endif
			if (stringmatch(objName,"mapper_panel_*"))
				SetDatafolder $objName
				String cubename,cubelist
				cubelist=WaveList("cfe_*ube*", ";", "DIMS:3")
				cubeindex=0
				do
					cubename=stringfromlist(cubeindex,cubelist,";")
					if (strlen(cubename)==0)
						break
					endif
					Killwaves /Z $cubename
					cubeindex+=1
				while (1)
			endif
			index += 1
		while(1)
		
		String map3Dlist=winlist("mapper3D*",";","")
		String map3Dwinname
		index=0
		do
			map3Dwinname=Stringfromlist(index,Map3Dlist,";")
			if (strlen(map3Dwinname)==0)
				break
			endif
			Dowindow /K $map3Dwinname
			String map3DDF="root:internalUse:"+map3Dwinname
			Killdatafolder /Z $map3DDF
			
			index+=1
		while (1)
		
		SetDatafolder DF
	Endif 
	
	
	////write preview notebook/////
	DFREF DFR_pref=$DFS_prefs
	NVAR gv_savenbflag=DFR_pref:gv_savenbflag
	if (gv_savenbflag)
		NBP_Save()
	endif	
	return 0
End


Function opensaveNBwindow(graphname)
	String graphName
	DFREF DF=getdatafolderDFR()

	DFREF DFR_global=$DF_global
	DFREF DFR_log=$(DFS_global+"Data_log")
	
	
	SetDatafolder DFR_log
	
	SVAR gs_samplename=DFR_log:gs_samplename
	SVAR gs_samplecomment=DFR_log:gs_samplecomment
	SVAR gs_previewcomment=DFR_log:gs_previewcomment
	SVAR gs_location=DFR_log:gs_location
	SVAR gs_user=DFR_log:gs_user
	SVAR /Z gs_expdate=DFR_log:gs_expdate
	SVAR gs_Expcklist=DFR_log:gs_Expcklist
	NVAR gv_commentflag=DFR_log:gv_commentflag
	NVAR gv_saveNBflag=DFR_log:gv_saveNBflag
	
	if (!SVAR_exists(gs_expdate))
		String/G gs_expdate=Secs2Date(DateTime,-2)
	endif
	
	DoWindow/F $graphName	
	
	Variable SC= Screensize(5)
	
	Variable SR = ScreenSize(3) //* SC
	Variable ST = ScreenSize(2)// * SC
	Variable SL = ScreenSize(1)//* SC
   	Variable SB = ScreenSize(4)// * SC
	//Variable SR = Igorsize(3) 
	//Variable ST = Igorsize(2)
	//Variable SL = Igorsize(1)
    //Variable SB = Igorsize(4)
	Variable Width = 300*SC 	// panel size  
	Variable height = 210*SC
	
	Variable xOffset = (SR-SL)/2-width/2
	Variable yOffset = (SB-ST)/2-height/2
	NewPanel /K=2 /W=(xoffset, yoffset,xOffset+width,Height+yOffset) as "Pause for Input Notebook Information"
	DoWindow/K/Z  PauseforsaveNB		
	DoWindow/C PauseforsaveNB					// Set to an unlikely name
	//AutoPositionWindow/E/M=1/R=$graphName			// Put panel near the graph

	SetVariable nb_sv0,pos={20*SC,5*SC},size={240*SC,20*SC},title="Sampe Name:",variable=gs_samplename
	SetVariable nb_sv1,pos={20*SC,25*SC},size={240*SC,20*SC},title="Sampe comment:",variable=gs_samplecomment
	SetVariable nb_sv2,pos={20*SC,45*SC},size={240*SC,20*SC},title="User:",variable=gs_user
	SetVariable nb_sv3,pos={20*SC,65*SC},size={240*SC,20*SC},title="Location:",variable=gs_location
	SetVariable nb_sv4,pos={20*SC,85*SC},size={240*SC,20*SC},title="Date:",variable=gs_expdate
	SetVariable nb_sv5,pos={20*SC,105*SC},size={240*SC,20*SC},title="Comments:",variable=gs_previewcomment
	
	Checkbox nb_ck0,pos={20*SC,130*SC},size={40*SC,20*SC},title="Map",value=numberbykey("Map",gs_Expcklist,"=",";")
	Checkbox nb_ck1,pos={65*SC,130*SC},size={40*SC,20*SC},title="Tdep",value=numberbykey("Tdep",gs_Expcklist,"=",";")
	Checkbox nb_ck2,pos={110*SC,130*SC},size={40*SC,20*SC},title="Gap",value=numberbykey("Gap",gs_Expcklist,"=",";")
	Checkbox nb_ck3,pos={155*SC,130*SC},size={40*SC,20*SC},title="kz",value=numberbykey("kz",gs_Expcklist,"=",";")
	Checkbox nb_ck4,pos={200*SC,130*SC},size={40*SC,20*SC},title="Cut",value=numberbykey("Cut",gs_Expcklist,"=",";")
	Checkbox nb_ck5,pos={245*SC,130*SC},size={40*SC,20*SC},title="Sum",value=numberbykey("Sum",gs_Expcklist,"=",";")
	
	Checkbox nb_ck6,pos={20*SC,155*SC},size={40*SC,20*SC},title="Bad",value=gv_commentflag==1,proc=proc_ck_expcomment
	Checkbox nb_ck7,pos={65*SC,155*SC},size={40*SC,20*SC},title="Normal",value=gv_commentflag==2,proc=proc_ck_expcomment
	Checkbox nb_ck8,pos={110*SC,155*SC},size={40*SC,20*SC},title="Good",value=gv_commentflag==3,proc=proc_ck_expcomment

	Button button1,pos={20*SC,180*SC},size={85*SC,20*SC},title="OK",proc=saveNB_ContButtonProc
	Button button4,pos={115*SC,180*SC},size={85*SC,20*SC},title="Cancel",proc=saveNB_ContButtonProc
	

	PauseForUser  PauseforsaveNB,$graphName
	SetDatafolder DF
End

Function proc_ck_expcomment(ctrlname,value)
	String ctrlname
	Variable value
	DFREF DFR_global=$DF_global
	DFREF DFR_log=$(DFS_global+"Data_log")
	
	NVAR gv_commentflag=DFR_log:gv_commentflag
	
	strswitch (ctrlname)
		case "nb_ck6":
			gv_commentflag=1
			break
		case "nb_ck7":
			gv_commentflag=2
			break
		case "nb_ck8":
			gv_commentflag=3
			break	
	endswitch		
	
	Checkbox nb_ck6,	value=gv_commentflag==1		
	Checkbox nb_ck7,	value=gv_commentflag==2		
	Checkbox nb_ck8,	value=gv_commentflag==3		
end
Function saveNB_ContButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	DFREF DFR_global=$DF_global
	DFREF DFR_log=$(DFS_global+"Data_log")
	NVAR gv_saveNBflag=DFR_log:gv_saveNBflag
	SVAR gs_Expcklist=DFR_log:gs_Expcklist
	
	strswitch(ctrlname)
		case "Button1":
			gv_saveNBflag=1
			break
		case "Button4":
			gv_saveNBflag=0
			break
	endswitch
	
	controlinfo nb_ck0
	gs_Expcklist=ReplaceNumberByKey("Map", gs_Expcklist, v_value ,"=",";")
	controlinfo nb_ck1
	gs_Expcklist=ReplaceNumberByKey("Tdep", gs_Expcklist, v_value ,"=",";")
	controlinfo nb_ck2
	gs_Expcklist=ReplaceNumberByKey("Gap", gs_Expcklist, v_value ,"=",";")
	controlinfo nb_ck3
	gs_Expcklist=ReplaceNumberByKey("kz", gs_Expcklist, v_value ,"=",";")
	controlinfo nb_ck4
	gs_Expcklist=ReplaceNumberByKey("Cut", gs_Expcklist, v_value ,"=",";")
	controlinfo nb_ck5
	gs_Expcklist=ReplaceNumberByKey("Sum", gs_Expcklist, v_value ,"=",";")
	
	
	DoWindow/K PauseforsaveNB
End


Function  NBP_Save()
	
	String sGraphList = ""
	String sGraphName = ""
	String sExperimentName = ""
	String sExperimentPath = ""
	String sNotebookName = ""
	String sMsg = ""
	String sNBtext = ""
	Variable vIndex
	
	sGraphList = WinList("*", ";", "WIN:1")
//check for empty string
	if( strlen( sGraphList ) == 0 )
		print "No Graphs were found. (Save Preview)"
		return 1	//failed
	endif
	
//name of current experiment
//if it is "Untitled", the experiment has not yet been saved; quit & request user first save experiment
	sExperimentName = IgorInfo(1)
	if( stringmatch( sExperimentName, "Untitled" ) == 1 )
		sMsg = "This experiment has not been saved.\r"  
		sMsg += "The preview notebook must be named after the experiment, "
		sMsg += "please save the experiment and then create the preview notebook."
		print sMsg
		return 1	//failed
	endif
//	print sExperimentName
	
//path to current experiment
//if the experiment is not named "Untitled", this should be valid, right?
	PathInfo home	
	sExperimentPath = S_path
	if( V_flag == 0 )	//path doesn't exist; this shouldn't happen given the previous check
		sMsg = "This experiment has not been saved.\r"  
		sMsg += "The preview notebook must be named after the experiment, "
		sMsg += "please save the experiment and then create the preview notebook."
		print sMsg
	endif
//	print sExperimentPath
//get legal & unique name for preview notebook
	sNotebookName = CleanupName( sExperimentName, 0 )
	sNotebookName = UniqueName( sNotebookName, 10, 0 )
	
	String timesuffix
	sprintf timesuffix, "%012.0f", Datetime*1e3
	
	DFREF DF=GetDatafolderDFR()
	DFREF DFR_global=$DF_global
	DFREF DFR_log=$(DFS_global+"Data_log")
	

	
	opensaveNBwindow(winname(0,1))
	
	SVAR gs_samplename=DFR_log:gs_samplename
	SVAR gs_samplecomment=DFR_log:gs_samplecomment
	SVAR gs_previewcomment=DFR_log:gs_previewcomment
	SVAR gs_location=DFR_log:gs_location
	SVAR gs_user=DFR_log:gs_user
	SVAR gs_expdate=DFR_log:gs_expdate
	NVAR gv_saveNBflag=DFR_log:gv_saveNBflag
	SVAR gs_Expcklist=DFR_log:gs_Expcklist
	NVAr gv_commentflag=DFR_log:gv_commentflag
	
	
	
	
	if (gv_saveNBflag==0)
		return 1 //failed
	endif
	
	sNBtext = "ExperimentName=" + sExperimentName + "\r"
	sNBtext += "ExperimentPath=" + sExperimentPath + "\r"

	sNBtext += "NotebookName=" +sExperimentName +timesuffix+ ".ifn"+ "\r"
	sNBtext +=  "SaveDate=" + Secs2Date(DateTime,0) + ", " + Secs2Time(DateTime,0) + "\r"
	
	sNBtext += "Samplename="+gs_samplename+ "\r"
	sNBtext += "Samplecomment="+gs_samplecomment+ "\r"
	sNBtext += "Location="+gs_location+ "\r"
	sNBtext += "User="+gs_user+ "\r"
	sNBtext += "ExperimentDate="+gs_expdate+"\r"
	sNBtext += "Comment="+gs_previewcomment+ "\r"
	sNBtext += "Expcontent="+gs_Expcklist+ "\r"
	sNBtext += "Explevel="+num2str(gv_commentflag)+ "\r"
	//prompt gs_samplename,"Sample Name:"
	//prompt gs_previewcomment,"Preview Comments:"
	//prompt gs_location,"Location:"
	//prompt gs_user,"User:"
	
	//Doprompt "Input info for notebook",gs_samplename,gs_user,gs_location,gs_previewcomment
	
//create notebook
	NewNotebook /F=1 /K=0 /N=$sNotebookName as sNotebookName

//Add some potentially helpful header text	
//Other items could be added here as well
	
	Notebook $sNotebookName, fsize=16, text=sNBtext

//process graph list and add graphs to notebook
	vIndex = 0
	Do
		sGraphName = StringFromList( vIndex, sGraphList, ";" )
		if( strlen( sGraphName ) == 0 )
			break	//done
		endif
		if (vindex>10)
			break
		endif
		Notebook $sNotebookName, picture={$sGraphName, -5, 1}
//		print sGraphName
		vIndex += 1
	While ( 1 )
	
//save the notebook
	SetDatafolder DFR_log
	LoadWave/O/Q/T/P = NBPath "NBlist.itx"
	if (V_flag==0)
		Make /o/T/n=0 NBnamelist,NBpathlist,NBtimelist,NBtextlist
	else
		Wave /T NBnamelist,NBpathlist,NBtimelist,NBtextlist
	endif
	
	Variable temp=SearchStringInWave(NBpathlist,sExperimentPath)
	if (temp!=-1)
		if (stringmatch(NBnamelist[temp],sExperimentName))
			String notestr=NBtextlist[temp]
			String oldnbname=StringByKey("NotebookName", notestr ,"=","\r")
			DeleteFile   /P=NBpath /Z=2 oldnbname
			Deletepoints temp,1, NBnamelist,NBpathlist,NBtimelist,NBtextlist
		endif
	endif	
	
	InsertPoints 0, 1, NBnamelist,NBpathlist,NBtimelist,NBtextlist
	NBnamelist[0]=sExperimentName
	NBpathlist[0]=sExperimentPath
	NBtimelist[0]=Secs2Date(DateTime,0) + ", " + Secs2Time(DateTime,0)
	NBtextlist[0]=sNBtext
	
	SaveNotebook /O/P=NBpath /S=7  $sNotebookName as sExperimentName +timesuffix+ ".ifn"
	Save/T/O/P=NBPath NBnamelist,NBpathlist,NBtimelist,NBtextlist as "NBlist.itx"
	Killwaves /Z NBnamelist,NBpathlist
	
	Dowindow /K $sNotebookName
	SetDatafolder DF
End

Function BeforeFileOpenHook(refnum, filename, symPath, type, creator, kind)

	Variable	refnum, kind
	String 		filename, symPath, type, creator
	
	return fileType(filename, symPath, refnum)		//  0 open it with igor //1 
	
End

Function FileType(FileName, symPath, refnum)
	
	String FileName, symPath
	Variable refnum
	
	String ext, file_line
	
	Variable index
		
	Variable n_char = strlen(FileName)	
		
	ext = FileName[strsearch(FileName,".",inf,1)+1, strlen(fileName)-1]
	
	
	if (stringmatch(ext,"ibw"))
	    //load_SES_ibw_file(symPath,filename)
	    return 1
	endif
	
	if  (stringmatch(ext,"txt"))
		open /R /P=$symPath refnum as FileName
		index=0
		do
			FReadline refnum, file_line
			if (stringmatch(file_line,"Instrument=SES*") || stringmatch(file_line,"Instrument=R*")|| stringmatch(file_line,"Instrument=SPIN*")||stringmatch(file_line,"Instrument=DA30*"))
				//---------------------- SES - txt files: ---------------------------------
				load_SES_txt_file(symPath,filename)
				close refnum
				return 1
			endif	
			index += 1
		while(index < 40)
		close refnum
	endif
	
	
  	if (stringmatch(ext,"itx"))	
  		open /R /P=$symPath refnum as FileName
		index = 0
		do							// read it only if second line shows...
			FReadline refnum, file_line
			// SIS itx files
			if (stringmatch(file_line,"*) Spectrum*") )
				//---------------------- SIS - itx files: ---------------------------------
				load_SIS_itx_file(symPath,filename)
				close refnum
				return 1
			endif
			index += 1
		while(index < 5)
		close refnum
	endif
	//print ext
	

	if (cmpstr(ext,"sp2")==0)
	      load_specs_sp2_file(sympath,filename)
		return 1
	endif
	
	if (cmpstr(ext,"fits")==0)
		//---------------------- ALS fits files: ---------------------------------
		load_fits_file(sympath,filename)
		return 1
	endif
	
	
	if (cmpstr(ext,"h5")==0)
		//---------------------- DA30 h5 file SSRL BL52 ---------------------------------
		load_h5_file(sympath,filename)
		return 1
	endif
	
	
	if (cmpstr(ext,"bin")==0)
		//---------------------- DA30 h5 file SSRL BL52 ---------------------------------
		load_SES_bin_file(sympath,filename)
		return 1
	endif
	
	
	//--------------------  files recognized from header key-words -----------------
	open /R /P=$symPath refnum as FileName
	index = 0
	do
		FReadline refnum, file_line
		//print file_line
		// SES - text-files
	
		
		// CCDOPS-binary files
		if (stringmatch(file_line,"ST-7 Image*") )
		//	load_CCDOPS_binary_file(symPath,filename)
			close refnum
			return 1
		endif
		if (stringmatch(file_line,"*aedc*"))
		//    load_Taiwan_file(symPath,filename)
		    close refnum
			return 1
		endif 
		if (stringmatch(file_line,"Start K.E.*"))
		   load_UVSOR_file(symPath,filename)
		   close refnum
		    return 1
		endif    
	index += 1
	while(index < 40)
	
	//-------------------- no file type was recognized --------------------------
	DoAlert 0, "sorry, the Macro could not recognize the file-type!"
	
	close refnum
	return 0
End






Function/s fileName_to_waveName(fileName, convention)	
	String fileName, convention
	
	Variable n = strlen(filename)
	DFREF DFR_prefs=$DF_prefs
	
	NVAR first_char =DFR_prefs:gv_Nick_firstChar
	NVAR last_char = DFR_prefs:gv_Nick_lastChar
	
	String NickName
	Variable p_ext
	strswitch(convention)
		case "SES":		
			p_ext = strsearch(fileName,".txt",0)
			if (p_ext < 0)			// added for SIS files 080410
				p_ext = strsearch(fileName,".itx",0)
			endif
			break
		case "fits":
		 	p_ext=strsearch(fileName,".fits",0)
		  	 break	
		case "SES_pxt":	
			NickName = CleanUpName(fileName[n-6,n-1],0)
			break
		case "SPECS":
			p_ext=strsearch(fileName,".sp2",0)
			break
		default:			
			NickName = CleanUpName(fileName[first_char, last_char],0)	// when no case matches
			return NickName
	endswitch
	
	
	
	
	Variable pos_temp=strsearch(fileName,"_",(p_ext-1),1)
	
	variable findnumpos
	
	if (pos_temp<0)
		findnumpos=(p_ext-1)-5
	else
		findnumpos=pos_temp
	endif
	
	Variable numpos=Findnumberend_instr(filename,(p_ext-1),findnumpos)
	
	if (numpos==-1) //no number find
		NickName= CleanUpName(fileName[first_char, min(p_ext-1,last_char)],0)
	else
		string filenum_str=fileName[numpos,(p_ext-1)]
		NickName = CleanUpName(fileName[first_char,min(findnumpos-1,last_char)],0)+"_"+filenum_str
	endif	
	
	//	pos_temp=Findnumberend_instr(filename,min(p_ext-1,last_char),0)
	//	if (pos_temp<0)
	//		NickName= CleanUpName(fileName[first_char, Max(last_char,p_ext-1)],0)
	//		return NickName
	//	else
	//		String filenum_str=fileName[min(p_ext-1,last_char)-pos_temp,min(p_ext-1,last_char)]
	//		NickName = CleanUpName(fileName[first_char,min(p_ext-1,last_char)-pos_temp-1],0)+"_"+filenum_str
	//	endif
	//else
	//	filenum_str=fileName[pos_temp+1,min(p_ext-1,last_char)]
	//	Variable filenum=str2num(filenum_str)
	//	if (numtype(filenum)==2)
	//		pos_temp=Findnumberend_instr(filename,min(p_ext-1,last_char),0)
	//		if (pos_temp<0)
	//			NickName= CleanUpName(fileName[first_char, Max(last_char,p_ext-1)],0)
	//			return NickName
	//		else
	//			filenum_str=fileName[min(p_ext-1,last_char)-pos_temp,min(p_ext-1,last_char)]
	//			NickName = CleanUpName(fileName[first_char,min(p_ext-1,last_char)-pos_temp-1],0)+"_"+filenum_str
	//		endif
	//	else
	//		NickName = CleanUpName(fileName[first_char,pos_temp-1],0)+"_"+filenum_str
	//	endif
	//endif	
					
	
	
	//
	//	NickName= CleanUpName(fileName[first_char, max(last_char,p_ext-1)],0)
	//else
		
	//endif
	
	return NickName
End

Function Findnumberend_instr(str,startpos,endpos)
	String str
	variable startpos
	variable endpos
	
	Variable index
	
	if (startpos<endpos)
		index=endpos
		do
			String tempstr=str[startpos,index]
			Variable tempvar=str2num(tempstr)
			if (numtype(tempvar)!=2)
				return index// (index-1-startpos)
			endif
			index-=1
		while (index >=startpos)
		
		return -1//(index-1-startpos)
	else
		index=endpos
		do
			tempstr=str[index,startpos]
			tempvar=str2num(tempstr)
			if (numtype(tempvar)!=2)
				return index//(startpos-index-1)
			endif
			index+=1
		while (index<=startpos)
		
		return -1//(startpos-index-1)
	endif

end





///////////Key word function/////////
	
Function/S Wave_KeyList(data_type)
	Variable data_type //no meaning for now
	
	String keylist=""
	keylist+="WaveName=\r"
	keylist+="RawDataWave=\r"
	keylist+="RawWaveName=\r"
	keylist+="FileName=\r"
	keylist+="FilePath=\r"
	keylist+="User=\r"
	keylist+="Sample=\r"
	keylist+="LatticeA=\r"
	keylist+="LatticeB=\r"
	keylist+="LatticeC=\r"
	keylist+="LatticeAlpha=\r"
	keylist+="LatticeBeta=\r"
	keylist+="LatticeGamma=\r"
	keylist+="LatticeType=\r"
	keylist+="InnerPotential=\r"
	keylist+="\r"
	
	keylist+="Instrument=\r"
	keylist+="MeasurementSoftware=\r"
	keylist+="ScientaOrientation=\r"
	keylist+="CCDFirstXChannel=\r"
	keylist+="CCDLastXChannel=\r"
	keylist+="CCDFirstYChannel=\r"
	keylist+="CCDLastYChannel=\r"
	keylist+="CCDDegreePerChannel=\r"
	keylist+="CCDeVPerChannel=\r"
	keylist+="AnalyzerSlit=\r"
	keylist+="DwellTime=\r"
	keylist+="\r"
	
	keylist+="RegionName=\r"
	keylist+="StartDate=\r"
	keylist+="StartTime=\r"
	keylist+="LensMode=\r"
	keylist+="AcquisitionMode=\r"
	keylist+="PassEnergy=\r"
	keylist+="EnergyScale=\r"
	keylist+="NumberOfSweeps=\r"
	keylist+="SampleOrientation=\r"
	keylist+="SampleTemperature=\r"
	keylist+="PhotonEnergy=\r"
	keylist+="WorkFunction=\r"
	keylist+="Polarization=\r"
	keylist+="AreaIntensity=\r"
	keylist+="BeamCurrent=\r"
	keylist+="\r"

	
	keylist+="FirstEnergy=\r"
	keylist+="LastEnergy=\r"
	keylist+="NumberOfEnergies=\r"
	keylist+="Energy Step=\r"
	keylist+="\r"
	

	keylist+="FirstSlice=\r"
	keylist+="LastSlice=\r"
	keylist+="NumberOfSlices=\r"
	keylist+="DegreeSlices=\r"
	keylist+="\r"
	
	keylist+="InitialThetaManipulator=\r"
	keylist+="OffsetThetaManipulator=\r"
	keylist+="InitialPhiManipulator=\r"
	keylist+="OffsetPhiManipulator=\r"
	keylist+="InitialAzimuthManipulator=\r"
	keylist+="OffsetAzimuthManipulator=\r"
	keylist+="X_Manipulator=\r"
	keylist+="Y_Manipulator=\r"
	keylist+="Z_Manipulator=\r"
	keylist+="DeflectorAngle=\r"
	keylist+="\r"
	
	
	keylist+="Comments=\r"
	keylist+="LeftNotes=\r"
	Keylist+="\r"
	
	return keylist
End



Function /S InitialForProcess(M_int,notestr)
	Wave M_int
	String notestr
	
	notestr+="\rProcessing Information:\r"
	notestr+="numofLayers=\r"
	notestr=ReplacenumberByKey("numofLayers", noteStr, 1,"=","\r")
			
	Variable layernum=0
	notestr+="Layer_"+num2str(layernum)+"\r"
	notestr+="Wavetype=\r"
	notestr+="ProcessNumber=\r"
	notestr+="RawLayerNumber=-1\r"
	notestr+="RawProcNumber=-1\r"
	notestr+="Appendflag=0\r"
	notestr+="xpnts=\r"
	notestr+="ypnts=\r"
	notestr+="x0=\r"
	notestr+="x1=\r"
	notestr+="y0=\r"
	notestr+="y1=\r"
	notestr+="Layer_"+num2str(layernum)+"\r"
				
	notestr=ReplaceStringByKey("Wavetype", noteStr, "rawData","=","\r")
	notestr=ReplacenumberByKey("ProcessNumber", noteStr, 0,"=","\r")
	notestr=ReplacenumberByKey("xpnts",notestr,dimsize(M_int,0),"=","\r")
	notestr=ReplacenumberByKey("ypnts",notestr,dimsize(M_int,1),"=","\r")
	notestr=ReplacenumberByKey("x0",notestr,M_x0(M_int),"=","\r")
	notestr=ReplacenumberByKey("x1",notestr,M_x1(M_int),"=","\r")
	notestr=ReplacenumberByKey("y0",notestr,M_y0(M_int),"=","\r")
	notestr=ReplacenumberByKey("y1",notestr,M_y1(M_int),"=","\r")
	
	return notestr
End		




Function /S Autoloadwritenote(Notestr)
	String notestr
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_global=$DF_global


	NVAR gv_gammaA=DFR_global:gv_gammaA
	NVAR gv_InnerE=DFR_global:gv_InnerE
	NVAR gv_samthetaoff=DFR_global:gv_samthetaoff
	NVAR gv_samphioff=DFR_global:gv_samphioff
	NVAR gv_samazioff=DFR_global:gv_samazioff
	NVAR gv_SampleOrientation=DFR_global:gv_SampleOrientation
	
	NVAR gv_uca=DFR_global:gv_uca
	NVAR gv_ucb=DFR_global:gv_ucb
	NVAR gv_ucc=DFR_global:gv_ucc
	NVAR gv_alphaA=DFR_global:gv_alphaA
	NVAR gv_betaA=DFR_global:gv_betaA
	NVAR gv_gammaAA=DFR_global:gv_gammaAA
	NVAR gv_BZtype=DFR_global:gv_BZtype
	
	SVAR gs_Polarization=DFR_global:gs_Polarization
	SVAR gs_Analyzerslit=DFR_global:gs_Analyzerslit

	variable gammaA=numberbykey("ScientaOrientation",notestr,"=","\r")
	variable InnerE=numberbykey("InnerPotential",notestr,"=","\r")
	String analslit=stringbykey("AnalyzerSlit",notestr,"=","\r")
	String Polarization=stringbykey("Polarization",notestr,"=","\r")

	if ((numtype(gammaA)==2)&&(numtype(gv_gammaA)!=2))
		notestr=replacenumberbykey("ScientaOrientation",notestr,gv_gammaA,"=","\r")
	endif

	if ((numtype(InnerE)==2)&&(numtype(gv_InnerE)!=2))
		notestr=replacenumberbykey("InnerPotential",notestr,gv_InnerE,"=","\r")
	endif

	if ((strlen(analslit)==0)&&(strlen(gs_Analyzerslit)>0))
		notestr=replacestringbykey("AnalyzerSlit",notestr,gs_Analyzerslit,"=","\r")
	endif

	if ((strlen(Polarization)==0)&&(strlen(gs_Polarization)>0))
		notestr=replacestringbykey("Polarization",notestr,gs_Polarization,"=","\r")
	endif

	notestr=replacenumberbykey("OffsetThetaManipulator",notestr,gv_samthetaoff,"=","\r")
	notestr=replacenumberbykey("OffsetPhiManipulator",notestr,gv_samphioff,"=","\r")
	notestr=replacenumberbykey("OffsetAzimuthManipulator",notestr,gv_samazioff,"=","\r")
	notestr=replacenumberbykey("SampleOrientation",notestr,gv_sampleorientation,"=","\r")
	
	notestr=replacenumberbykey("LatticeA",notestr,gv_uca,"=","\r")
	notestr=replacenumberbykey("LatticeB",notestr,gv_ucb,"=","\r")
	notestr=replacenumberbykey("LatticeC",notestr,gv_ucc,"=","\r")
	notestr=replacenumberbykey("LatticeAlpha",notestr,gv_alphaA,"=","\r")
	notestr=replacenumberbykey("LatticeBeta",notestr,gv_betaA,"=","\r")
	notestr=replacenumberbykey("LatticeGamma",notestr,gv_gammaAA,"=","\r")
	notestr=replacenumberbykey("LatticeType",notestr,gv_BZtype,"=","\r")


	return notestr

End



Function Write_or_read_from_logfile(data)
	Wave data
	
	DFREF DF=GetDatafolderDFR()
	
	DFREF DFR_global=$DF_global
	SetDatafolder DFR_global
	newDatafolder /o/s Data_Log
	DFREF DFR_log=GetDatafolderDFR()
	
	Wave /T titleStrs=DFR_log:titleStrs
	Wave /T titleVars=DFR_log:titleVars
	Wave /T KeywordStrs=DFR_log:KeywordStrs
	Wave /T KeywordVars=DFR_log:KeywordVars
	
	NVAR gv_LogFileflag=DFR_global:gv_LogFileflag
	NVAR gv_LogDataflag=DFR_global:gv_LogDataflag
	
	SVAR Datatable_Strkey_to_num=DFR_log:Datatable_Strkey_to_num
	SVAR Datatable_Varkey_to_num=DFR_log:Datatable_Varkey_to_num
	
	ReadDetailWaveNote(data,Nan,0)
	Wave /T WaveInfoStrings
	Wave WaveInfoVars
	
	String notestr=Note(data)
	
	String RawWaveNamestr=WaveInfoStrings[2]
	String filenamestr=WaveInfoStrings[3]
	String filePathstr=WaveInfoStrings[4]
	
	Variable findnoteflag=0
	///////////////////////try read from log datafolder//////////////////
	
	if (gv_LogDataflag==0)
	
	if (waveexists(filename))
		Wave /T filename
		Wave /T RawWaveN
		Wave /T WaveInfoStringsList
		Wave  WaveInfoVarsList
		
		Variable filepos= SearchStringInWave(filename,filenamestr)
		Variable WaveNpos= SearchStringInWave(RawwaveN,RawWaveNamestr)
		
		if (filepos>-1)
			if  (WaveNpos>-1)
				findnoteflag=1
				
				Variable keyindex=1
				do
					if ((keyindex==4)||(keyindex==11)||(keyindex==12))
					else
						notestr=replaceStringbykey(KeywordStrs[Keyindex],notestr,WaveInfoStringsList[WaveNpos][keyindex],"=","\r")
					endif
					keyindex+=1
				while (keyindex<19)
	
				keyindex=0
				do
					if (keyindex==17)
					else
					notestr=replacenumberbykey(KeywordVars[Keyindex],notestr,WaveInfoVarsList[WaveNpos][keyindex],"=","\r")
					endif
					keyindex+=1
				while (keyindex<41)
				
				//notestr=replacestringbykey("FilePath",notestr,filePathstr,"=","\r")
			
			
				note /K data
				note data,notestr
				
				ReadDetailWaveNote(data,Nan,0)
				Wave /T WaveInfoStrings
				Wave WaveInfoVars

	
				RawWaveNamestr=WaveInfoStrings[2]
				filenamestr=WaveInfoStrings[3]
				filePathstr=WaveInfoStrings[4]
				
			endif
		endif
	endif
	
	endif
	
	/////////////////////////// try read from log file in the disk folder///////////////////////
	
	if ((gv_LogFileflag==0)&&(findnoteflag==0))
	
	Variable refnum
	newPath /O/Q DataFolderPath,filePathstr
	open /R/Z /P=DataFolderPath refnum as "Experiment.log"
	if (v_flag==0)
		Variable index=0
		String Fline
		FReadLine refnum,fline //read headfile
		SListToWave(fline,0,"\t",Nan,Nan)
		Wave /T w_StringList
		Duplicate /o/Free/T w_StringList Headkeyindex
		
		do
			FReadLine refnum,fline
			if (strlen(fline)==0)
				break
			endif
			if (strsearch(fline,filenamestr,0)>=0)
				if (strsearch(fline,RawWaveNameStr,0)>=0)
					findnoteflag=1
					Make /t/o/n=21  WaveInfoStrings
					Make /o/n=43 WaveInfoVars
					SListToWave(fline,0,"\t",Nan,Nan)
					Wave /T w_StringList
					
					Variable headindex=0
					do
						variable keynum=numberbykey(Headkeyindex[headindex],Datatable_Strkey_to_num,"=",";")
						if (numtype(keynum)==2)
				 			keynum=numberbykey(Headkeyindex[headindex],Datatable_Varkey_to_num,"=",";")
				 			WaveInfoVars[keynum]=str2num(w_StringList[headindex])
				 		else
				 			WaveInfoStrings[keynum]=w_StringList[headindex]
						endif
						headindex+=1
					while (headindex<numpnts(w_StringList))
						
					keyindex=1
					do
						if ((keyindex==4)||(keyindex==11)||(keyindex==12))	
						else
						notestr=replaceStringbykey(KeywordStrs[Keyindex],notestr,WaveInfoStrings[keyindex],"=","\r")
						endif
						keyindex+=1
					while (keyindex<19)
	
					keyindex=0
					do
						if (keyindex==17)
						else
						notestr=replacenumberbykey(KeywordVars[Keyindex],notestr,WaveInfoVars[keyindex],"=","\r")
						endif
						keyindex+=1
					while (keyindex<41)
					
					//notestr=replacestringbykey("FilePath",notestr,filePathstr,"=","\r")
					
					note /K data
					note data,notestr					
				endif
			endif
		while (1)
		close refnum
	endif
	
	endif
	
	/////////////////////// write the one in log datafolder///////////
//	print GetDataFolder(1),waveexists(filename)
	Wave /T/Z filename
	if (waveexists(filename)==1)
		Wave /T filename
		Wave /T RawwaveN
		Wave /T filepath
		Wave /T WaveInfoStringsList
		Wave  WaveInfoVarsList
		
		filepos= SearchStringInWave(filename,filenamestr)
		WaveNpos= SearchStringInWave(RawwaveN,RawWaveNamestr)
		
		if (filepos>-1)
			if  (WaveNpos>-1)
				if (numpnts(filename)>1)
					DeletePoints /M=0 WaveNpos,1,filename,RawWaveN,filepath
					DeletePoints /M=0 WaveNpos,1,WaveInfoStringsList,WaveInfoVarsList
				else
					Make /t/o/n=0 filename,RawWaveN,filepath
					Make /t/o/n=(0,21) WaveInfoStringsList
					Make /o/n=(0,43) WaveInfoVarsList
				endif
			endif
		endif
	
	else
		Make /t/o/n=0 filename,RawWaveN,filepath
		Make /t/o/n=(0,21) WaveInfoStringsList
		Make /o/n=(0,43) WaveInfoVarsList	
	endif
	
	
	InsertPoints /M=0 0,1,filename,RawWaveN,filepath,WaveInfoStringsList,WaveInfoVarsList
	filename[0]=filenamestr
	RawWaveN[0]=RawWaveNamestr
	filepath[0]=filePathstr
	WaveInfoStringsList[0][]=WaveInfoStrings[q]
	WaveInfoVarsList[0][]=WaveInfoVars[q]
	
	SetDatafolder DF
End

		//dataname[index]=WaveInfoStrings[0]
		//WaveN[index]=WaveInfoStrings[1]
		//rawWaveN[index]=WaveInfoStrings[2]
		//Filename[index]=WaveInfoStrings[3]
		///FilePath[index]=WaveInfoStrings[4]
		//User[index]=WaveInfoStrings[5]
		//Sample[index]=WaveInfoStrings[6]
		
		//LatticeA[index]=WaveInfoVars[0]
		//LatticeB[index]=WaveInfoVars[1]
		//LatticeC[index]=WaveInfoVars[2]
		//LatticeAlpha[index]=WaveInfoVars[3]
		//LatticeBeta[index]=WaveInfoVars[4]
		//Latticegamma[index]=WaveInfoVars[5]
		//LatticeType[index]=WaveInfoVars[6]
		//InnerE[index]=WaveInfoVars[7]
		
		//instrument[index]=WaveInfoStrings[7]
		//measurementsoftware[index]=WaveInfoStrings[8]
		//AnalyzerSlit[index]=WaveInfoStrings[9]
		
		//gammaA[index]=WaveInfoVars[8]
		//fYchannel[index]=WaveInfoVars[9]
		//lYchannel[index]=WaveInfoVars[10]
		//fXchannel[index]=WaveInfoVars[11]
		//lXchannel[index]=WaveInfoVars[12]
		//DegreeperChannel[index]=WaveInfoVars[13]
		//EvperChannel[index]=WaveInfoVars[14]
		//DwellTime[index]=WaveInfoVars[15]
		
		//Region[index]=WaveInfoStrings[10]
		//Sdate[index]=WaveInfoStrings[11]
		//Stime[index]=WaveInfoStrings[12]
		//LensMode[index]=WaveInfoStrings[13]
		//AcMode[index]=WaveInfoStrings[14]
		//Polarization[index]=WaveInfoStrings[15]
		//EnergyScale[index]=WaveInfoStrings[16]
		
		//PassE[index]=WaveInfoVars[16]
		//Sweeps[index]=WaveInfoVars[17]
		//SampleOrientation[index]=WaveInfoVars[18]
		//Tem[index]=WaveInfoVars[19]
		//PhotonE[index]=WaveInfoVars[20]
		//WorkFn[index]=WaveInfoVars[21]
		//BeamCurrent[index]=WaveInfoVars[22]
		//AreaI[index]=WaveInfoVars[23]
		
		//LowEnergy[index]=WaveInfoVars[24]
		//HighEnergy[index]=WaveInfoVars[25]
		//NumEnergy[index]=WaveInfoVars[26]
		//Estep[index]=WaveInfoVars[27]
		
		//firstslice[index]=WaveInfoVars[28]
		//lastslice[index]=WaveInfoVars[29]
		//numslices[index]=WaveInfoVars[30]
		//Degreeslices[index]=WaveInfoVars[31]
		
		//theta[index]=WaveInfoVars[32]
		//thetaoff[index]=WaveInfoVars[33]
		//phi[index]=WaveInfoVars[34]
		//phioff[index]=WaveInfoVars[35]
		//azi[index]=WaveInfoVars[36]
		//azioff[index]=WaveInfoVars[37]
		
		//ManiX[index]=WaveInfoVars[38]
		//ManiY[index]=WaveInfoVars[39]
		//ManiZ[index]=WaveInfoVars[40]
		
		//Comment[index]=WaveInfoStrings[17]
		//Leftnotes[index]=WaveInfoStrings[18]
		
		//FermiEnergy[index]=WaveInfoVars[41]
		//Initialflag[index]=WaveInfoVars[42]
		
		//tmfname[index]=WaveInfoStrings[19]
		//dispname[index]=WaveInfoStrings[20]



//SSRL BL52 DA30 h5 file
Function load_h5_file(sympath,filename)
	string sympath
	string filename
	
	
	variable fileID
	variable groupID
	variable result=0
	
	variable is_3D
	
	DFREF DF = getDataFolderDFR()
	
	//NewDataFolder/O/S root:process
	
	
	
	NewDataFolder /O/S root:rawData
	killdatafolder/Z Load_DA30_h5_temp
	NewDataFolder/O/S load_DA30_h5_temp
	
	
	HDF5OpenFile /P=$sympath  /R /Z fileID  as filename
	
	//attributes under root
	HDF5LoadData /Q/Z /A="creation_time"/TYPE=1  fileID,"/"
	HDF5LoadData /Q/Z /A="region_name"/TYPE=1  fileID,"/"
	HDF5LoadData /Q/Z /A="description"/TYPE=1  fileID,"/"
	HDF5LoadData/N=$("Sample")/Q /Z /A="sample"/TYPE=1  fileID,"/"
	HDF5LoadData/N=$("FileName") /Q/Z /A="file_name"/TYPE=1  fileID,"/"
	HDF5LoadData /N=$("FilePath")/Q/Z /A="data_folder"/TYPE=1  fileID,"/"
	HDF5LoadData /Q/Z /A="group"/TYPE=1  fileID,"/"
	HDF5LoadData /N=$("User")/Q/Z /A="user"/TYPE=1  fileID,"/"
	HDF5LoadData /Q/Z /A="location"/TYPE=1  fileID,"/"
	HDF5LoadData /Q/Z /A="beamline"/TYPE=1  fileID,"/"
	HDF5LoadData/Q /Z /A="comments"/TYPE=1  fileID,"/"
	
	//attributes under root/analyzer
	HDF5OpenGroup /Q/Z fileID , "/analyzer" , groupID
	HDF5LoadData/N=$("Instrument")/Q /Z /A="model"/TYPE=1  groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="start_time"/TYPE=1  groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="stop_time"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData/N=$("LensMode")/Q /Z /A="lens_mode"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData/N=$("PassEnergy") /Q/Z /A="pass_energy"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="acquisition_time"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData/Q /Z /A="number_of_frames"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="camera_mode"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="LowX"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="HighX"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="LowY"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="HighY"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="Width"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="Height"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="CenterX"/TYPE=1  fileID,"/analyzer"
	HDF5LoadData /Q/Z /A="CenterY"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="EnergyAxis"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="EnergyBinning"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="DeflectionXAxis"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="DeflectionXBinning"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="DeflectionYAxis"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="DeflectionYStrategy"/TYPE=1   groupID,"/analyzer"
	if(waveexists($("DeflectionYStrategy")))
		is_3D = 1
	else
		is_3D = 0
		HDF5LoadData /Q/Z /A="DeflectionY"/TYPE=1   groupID,"/analyzer"
	endif
	
	
	
	
	HDF5LoadData /Q/Z /A="ScreenVoltage"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="MCPVoltage"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="NumberOfSweeps"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="SlitWidth"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="SlitLength"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="SlitKnob"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="SlitType"/TYPE=1   groupID,"/analyzer"
	HDF5LoadData /Q/Z /A="SlitAperature"/TYPE=1   groupID,"/analyzer"
	HDF5CloseGroup groupID
	
	//attributes under root/beamline
	HDF5OpenGroup /Q/Z  fileID , "/beamline" , groupID
	HDF5LoadData/Q /Z /A="spear_current"/TYPE=1   groupID,"/beamline"
	HDF5LoadData/N=$("BeamCurrent")/Q /Z /A="i0"/TYPE=1   groupID,"/beamline"
	HDF5LoadData/N=$("PhotonEnergy")/Q /Z /A="photon_energy"/TYPE=1   groupID,"/beamline"
	HDF5LoadData/Q /Z /A="polarization"/TYPE=1   groupID,"/beamline"
	HDF5LoadData /Q/Z /A="epu_gap"/TYPE=1   groupID,"/beamline"
	HDF5LoadData /Q/Z /A="epu_phase"/TYPE=1   groupID,"/beamline"
	HDF5LoadData /Q/Z /A="grating"/TYPE=1   groupID,"/beamline"
	HDF5LoadData /Q/Z /A="pgm_grating_pitch"/TYPE=1   groupID,"/beamline"
	HDF5LoadData /Q/Z /A="pgm_mirror_pitch"/TYPE=1   groupID,"/beamline"
	HDF5LoadData /Q/Z /A="m3_pitch"/TYPE=1   groupID,"/beamline"
	HDF5LoadData /Q/Z /A="m3_insert"/TYPE=1   groupID,"/beamline"
	HDF5LoadData /Q/Z /A="exit_slit"/TYPE=1   groupID,"/beamline"
	HDF5LoadData /Q/Z /A="ig6_pressure"/TYPE=1   groupID,"/beamline"
	HDF5CloseGroup groupID
	
	//attributes under root/endstation
	HDF5OpenGroup /Q/Z  fileID , "/endstation" , groupID
	HDF5LoadData/Q/N=$("InitialThetaManipulator") /Z /A="t"/TYPE=1   groupID,"/endstation"
	HDF5LoadData/Q /N=$("InitialPhiManipulator")/Z /A="f"/TYPE=1   groupID,"/endstation"
	HDF5LoadData /Q/Z /N=$("InitialAzimuthManipulator")/A="a"/TYPE=1   groupID,"/endstation"
	HDF5LoadData /Q/Z /N=$("X_Manipulator")/A="x"/TYPE=1   groupID,"/endstation"
	HDF5LoadData /Q/Z /N=$("Y_Manipulator")/A="y"/TYPE=1   groupID,"/endstation"
	HDF5LoadData/Q /Z /N=$("Z_Manipulator")/A="z"/TYPE=1   groupID,"/endstation"
	HDF5LoadData/Q /Z /N=$("SampleTemperature")/A="sample_stage_temperature"/TYPE=1   groupID,"/endstation"
	HDF5LoadData/Q /Z /A="cold_head_temperature"/TYPE=1   groupID,"/endstation"
	HDF5LoadData/Q /Z /A="radiation_shield_temperature"/TYPE=1   groupID,"/endstation"
	HDF5LoadData /Q/Z /A="cryo_temperature"/TYPE=1   groupID,"/endstation"
	HDF5LoadData /Q/Z /A="heater_range_sample"/TYPE=1   groupID,"/endstation"
	HDF5LoadData /Q/Z /A="heater_sample"/TYPE=1   groupID,"/endstation"
	HDF5LoadData /Q/Z /A="heater_range_cryo"/TYPE=1   groupID,"/endstation"
	HDF5LoadData/Q /Z /A="heater_cryp"/TYPE=1   groupID,"/endstation"
	HDF5LoadData /Q/Z /A="pressure_lower_chamber"/TYPE=1   groupID,"/endstation"
	HDF5LoadData /Q/Z /A="pressure_upper_chamber"/TYPE=1   groupID,"/endstation"
	HDF5LoadData /Q/Z /A="liquid_he_left"/TYPE=1   groupID,"/endstation"
	HDF5CloseGroup groupID
	
	//attributes under root/resolution
	HDF5OpenGroup /Q/Z  fileID , "/resolution" , groupID
	HDF5LoadData/Q /Z /A="beam_size_h"/TYPE=1   groupID,"/resolution"
	HDF5LoadData /Q/Z /A="sample_tempearture_estimate"/TYPE=1   groupID,"/resolution"
	HDF5CloseGroup groupID
	
	
	
	string raw_note = get_all_attributes()
	killwaves/A
	
	variable index
	string dataname
	variable subgroupID
	variable theta, deflector_angle
	string new_note,dataprc_name
	
	if(is_3D)
		
		
		

	
		//attributes and dataset under root/data
		HDF5OpenGroup /Z fileID , "/data" , groupID
		HDF5LoadData/Q /Z /A="data_shape"/TYPE=1   groupID,"/data"
		wave data_shape
		HDF5MakeHyperslabWave("slab", 3)
		wave slab
		//https://support.hdfgroup.org/HDF5/Tutor/selectsimple.html
		
		slab[][%Stride] = 1	// Use a stride of 1 for all dimensions
		slab[][%Block] = 1
		slab[][%Start] = 0	// Start at zero for all dimensions
		
		slab[][%Count] = data_shape[p]
		slab[0][%Count] = 1
		
		
		HDF5OpenGroup /Z groupID , "/data/axis0" , subgroupID
		HDF5LoadData/N=$("p_offset")/Q /Z /A="offset"/TYPE=1   subgroupID,"/data/axis0"
		HDF5LoadData/N=$("p_delta")/Q /Z /A="delta"/TYPE=1   subgroupID,"/data/axis0"
		HDF5CloseGroup subgroupID
		
		HDF5OpenGroup /Z groupID , "/data/axis1" , subgroupID
		HDF5LoadData/N=$("q_offset")/Q /Z /A="offset"/TYPE=1   subgroupID,"/data/axis1"
		HDF5LoadData/N=$("q_delta")/Q /Z /A="delta"/TYPE=1   subgroupID,"/data/axis1"
		HDF5CloseGroup subgroupID
		
		HDF5OpenGroup /Z groupID , "/data/axis2" , subgroupID
		HDF5LoadData/N=$("r_offset")/Q /Z /A="offset"/TYPE=1   subgroupID,"/data/axis2"
		HDF5LoadData/N=$("r_delta")/Q /Z /A="delta"/TYPE=1   subgroupID,"/data/axis2"
		HDF5CloseGroup subgroupID
		
		wave p_offset, q_offset, r_offset, p_delta, q_delta, r_delta
		

		
		for(index=0;index<data_shape[0];index+=1)
			slab[0][%Start]=index
			
		
			HDF5LoadData /Q/Z/SLAB=slab groupID, "counts"
			HDF5LoadData /Q/Z/SLAB=slab groupID, "exposure"
			wave counts
			wave exposure
			
			dataname = "root:rawdata:"+replacestring(".h5", filename,"")+"_"+num2str(index)
			
			make/o/n=(dimsize(counts, 1), dimsize(counts, 2)) $(dataname)	

			wave data = $(dataname)	
			
			setscale/P x, q_offset[0],q_delta[0], data
			setscale/P y, r_offset[0],r_delta[0], data
			
			data = counts[0][p][q]/exposure[0][p][q]	
			killwaves/Z counts, exposure
			
			deflector_angle = p_offset[0]+p_delta[0]*index
			new_note = raw_note
			new_note += "DeflectorAngle"+"="+num2str(deflector_angle)+"\r"
			note/K data, new_note
			
			
			dataprc_name = "root:process:"+replacestring(".h5", filename,"")+"_"+num2str(index)
			duplicate/o data, $(dataprc_name)
			
			wave dataprc=$(dataprc_name)
			InitialprocNotestr2D(dataprc,"rawData")
			
			redimension /N=(dimsize(data,0),dimsize(data,1),1) dataprc
		endfor
			
			
			
			
		HDF5CloseGroup groupID
		HDF5CloseFile fileID
		//HDF5LoadData /Z /A="data_num"/TYPE=1  groupID,"/data"
		killwaves/Z slab, data_shape
		
		
		NewDataFolder /O/S root:rawData
		killdatafolder/Z Load_DA30_h5_temp
		setdatafolder DF
		
	else
	
		//attributes and dataset under root/data
		HDF5OpenGroup /Z fileID , "/data" , groupID
		HDF5LoadData/Q /Z /A="data_shape"/TYPE=1   groupID,"/data"
		wave data_shape
//		HDF5MakeHyperslabWave("slab", 3)
//		wave slab
//		//https://support.hdfgroup.org/HDF5/Tutor/selectsimple.html
//		
//		slab[][%Stride] = 1	// Use a stride of 1 for all dimensions
//		slab[][%Block] = 1
//		slab[][%Start] = 0	// Start at zero for all dimensions
//		
//		slab[][%Count] = data_shape[p]
//		slab[0][%Count] = 1
//		
//		variable index
		
	
		
		
	
		
		HDF5OpenGroup /Z groupID , "/data/axis0" , subgroupID
		HDF5LoadData/N=$("p_offset")/Q /Z /A="offset"/TYPE=1   subgroupID,"/data/axis0"
		HDF5LoadData/N=$("p_delta")/Q /Z /A="delta"/TYPE=1   subgroupID,"/data/axis0"
		HDF5CloseGroup subgroupID
		
		HDF5OpenGroup /Z groupID , "/data/axis1" , subgroupID
		HDF5LoadData/N=$("q_offset")/Q /Z /A="offset"/TYPE=1   subgroupID,"/data/axis1"
		HDF5LoadData/N=$("q_delta")/Q /Z /A="delta"/TYPE=1   subgroupID,"/data/axis1"
		HDF5CloseGroup subgroupID
		
		wave p_offset, q_offset, p_delta, q_delta
		

	
		
	
		HDF5LoadData /Q/Z groupID, "counts"
		HDF5LoadData /Q/Z groupID, "exposure"
		
		dataname = "root:rawdata:"+replacestring(".h5", filename,"")
		wave counts
		wave exposure
		
		
		
		make/o/n=(dimsize(counts, 0), dimsize(counts, 1)) $(dataname)	

		wave data = $(dataname)	
		
		setscale/P x, p_offset[0],p_delta[0], data
		setscale/P y, q_offset[0],q_delta[0], data
		
		data = counts[p][q]/exposure[p][q]	
		
		
		//data =exposure[p][q]	
		killwaves/Z counts, exposure
		
		deflector_angle = numberbykey("DeflectionY",raw_note,"=","\r")
		
		new_note = raw_note
		new_note += "DeflectorAngle"+"="+num2str(deflector_angle)+"\r"
		note/K data, new_note
		
		MatrixTranspose data
		
		
		dataprc_name = "root:process:"+replacestring(".h5", filename,"")+"_"+num2str(index)
		duplicate/o data, $(dataprc_name)
		
		wave dataprc=$(dataprc_name)
		InitialprocNotestr2D(dataprc,"rawData")
		
		redimension /N=(dimsize(data,0),dimsize(data,1),1) dataprc

		
		
			
		HDF5CloseGroup groupID
		HDF5CloseFile fileID
		//HDF5LoadData /Z /A="data_num"/TYPE=1  groupID,"/data"
		killwaves/Z slab, data_shape
		
		
		NewDataFolder /O/S root:rawData
		killdatafolder/Z Load_DA30_h5_temp
		setdatafolder DF
	endif
	
	
	return result
end


function/T get_all_attributes()

	string attributes_list = WaveList("*", ";", "" )
	variable index=0
	string raw_note_list=""
	string attribute_name
		
	do
		attribute_name = stringfromlist(index,attributes_list)
		if(strlen(attribute_name)==0)
			break
		endif		
		if(wavetype($attribute_name)==0)
			wave/T attribute = $attribute_name
			raw_note_list +=attribute_name +"="+attribute[0]+"\r"
		else
			wave attribute2 = $attribute_name
			raw_note_list += attribute_name+"="+num2str(attribute2[0])+"\r"
			
			//print num2str(attribute2[0])
		endif	
		index+=1
	while(1)	
	
	return raw_note_list
	//print raw_note_list[0]
	//print ReplaceString(" ", raw_note_list, "")
end



//---------------SES txt file-------------------

Function load_SES_txt_file(symPath, filename)			
	
	String symPath, filename
	
	DFREF DF = getDataFolderDFR()
	
	NewDataFolder/O/S root:process
	NewDataFolder/O/S root:rawData
	
	Variable refnum
	String SES_line
	
	String noteStrList=""
	
	Variable line
	line=0
	Open/R /P=$symPath refnum filename
	do
	  	FReadline/N=128 refnum, SES_line
	   	if (stringmatch(SES_line, "[Data*") )
			break
		endif
		noteStrList += SES_line
	While (line<150)
	Close refnum
	
	/////////////Overwrite or note?////////////////
	 		
	Variable numberofsweepscmp = NumberbyKey("Number of Sweeps",noteStrList,"=","\r")
      	String Datecmp=StringbyKey("Date",noteStrList,"=","\r")
      	String Timecmp=Stringbykey("Time",noteStrList,"=","\r")
    
      	
	String noteStrListcmp="Filename=;NumberofSweeps=;Date=;Time=;"
	String noteStrListcmp1
      	
      	noteStrListcmp=ReplaceStringByKey("Filename", noteStrListcmp, filename, "=", ";")
      	noteStrListcmp=ReplacenumberByKey("NumberofSweeps", noteStrListcmp, numberofsweepscmp, "=", ";")
      	noteStrListcmp=ReplaceStringByKey("Date", noteStrListcmp, Datecmp, "=", ";")
      	noteStrListcmp=ReplaceStringByKey("Time", noteStrListcmp, Timecmp, "=", ";")
      	
      	
      	DFREF DFR_global=$DF_global
      	NVAR gv_overflag= DFR_global:gv_overflag
      	SVAR LoadWaveList=DFR_global:LoadWaveList
      	SVAR LoadWaveNotes=DFR_global:LoadWaveNotes
      	NVAR gv_rawwaveexists=DFR_global:gv_rawwaveexists
      	SVAR gs_rawnotestr=DFR_global:gs_rawnotestr
      	
      	Variable filenum
      	if (strlen(LoadWaveList)==0)
      		filenum=-1
      	else
      		filenum=Whichlistitem(filename, LoadWaveList, "\r", 0 )
      	endif
      	
	if (filenum>=0)      	
		if (gv_overflag==0)	
      			noteStrListcmp1=StringFromList(filenum, LoadWaveNotes,"\r")
			if (stringmatch(noteStrListcmp,noteStrListcmp1)) 
      				// same file
      				SetDatafolder DF
      				return 1
      			endif
      		endif
      				// not the same file or overwrite
      		LoadWaveNotes=RemoveListItem(filenum,LoadWaveNotes,"\r")
      		LoadWaveList=Removelistitem(filenum,LoadwaveList,"\r")
      		
      		gv_rawwaveexists=1
      	else
      		gv_rawwaveexists=0
	endif
     
	LoadWaveNotes=AddListItem(noteStrListcmp, LoadWaveNotes, "\r",inf)		
	LoadWaveList=AddListItem(filename, LoadWaveList, "\r",inf)
	
	//////////////begin the loading//////////////
	
	//String filenamebase=filename[0,(strsearch(filename,".",inf,1)-1)]
	//String ext=filename[0,(strsearch(filename,".",inf,1)-1)]
	
	Variable NumberofRegions
	NumberOfRegions=NumberByKey("Number of Regions",noteStrList,"=","\r")
	
	
	// Load all matrices:
	KillWaves_withBase("MM")
	LoadWave/G/M/Q/O/A=MM /P=$symPath filename
   	if (V_flag==0)
  		 SetDatafolder DF
   		return 1
   	endif
   	
   	String   DataName, cmd, NickName, w_Name
	String th, ph
	Variable done
	
	Variable NumberOfBlocks, Block
	Variable e0, e1, divideBy
	
   	Variable Region, index
	index = 0
	Region = 1
	do	
		// for each region: get the header, the number of Blocks, and the "run mode information"
		String notestr = sFunc_SES_header(symPath, filename,Region)
		String dim3info = sFunc_SES_dim3(symPath, filename, Region)
   	
		NumberOfBlocks = str2num(StringFromList(0,dim3info))
		if (numtype(NumberofBlocks)==2)
			NumberOfBlocks=0
		endif
		
		Variable FirstYchannel = NumberByKey("CCDFirstYChannel",noteStr,"=","\r")
		Variable LastYchannel = NumberByKey("CCDLastYChannel",noteStr,"=","\r")
		Variable FirstXchannel = NumberByKey("CCDFirstXChannel",noteStr,"=","\r")
		Variable LastXchannel = NumberByKey("CCDLastXChannel",noteStr,"=","\r")
	
		Variable DwellTime = NumberByKey("DwellTime", noteStr, "=","\r")
		Variable NumberOfSweeps = NumberByKey("NumberOfSweeps", noteStr, "=","\r")
		Variable x0=NumberByKey("Firstslice", noteStr, "=","\r")
		Variable x1=NumberByKey("Lastslice", noteStr, "=","\r")
		Variable Beamcurrent=Numberbykey("BeamCurrent",noteStr,"=","\r")
		Variable NumberofSlices=NumberByKey("NumberOfSlices", noteStr, "=","\r")
		Variable EnergyStep=NumberByKey("Energy Step", noteStr, "=","\r")
		
		string AcquisitionMode=stringbykey("AcquisitionMode",noteStr,"=","\r")
		
		if (NumberOfRegions > 1)
			NickName = fileName_to_waveName(fileName,"SES")+"_"+num2str(Region)
		else
			NickName = fileName_to_waveName(fileName,"SES")
		endif
	
		String baseNickname=NickName
		Block = 1	
		do
			if (NumberOfBlocks > 1)
				NickName = baseNickname+"_" + num2str(Block)
			endif
		
			WAVE M = $("MM"+num2str(index))
			MatrixTranspose M
			Duplicate/R=[1,dimsize(M,0)-1][]/O M M_int		// skip the energy-column
		 	
//			if (DwellTime >= 33)		
//
//				divideBy =DwellTime *NumberOfSweeps*((abs(LastYChannel-FirstYChannel)+1 )/NumberofSlices)*(abs(LastXChannel-FirstXChannel)+1)
//				//(abs(LastYChannel-FirstYChannel)+1 )/NumberofSlices takes care of binning  along k direction
//				//(abs(LastXChannel-FirstXChannel)+1) only works when sweep mode is used
//				
//			else
//				
//				//old in Yan's version, not really used
//				// divideBy =  NumberOfSweeps*((abs(LastYChannel-FirstYChannel)+1 )/NumberofSlices)
//				divideBy =DwellTime *NumberOfSweeps
//			endif
			
			//print notestr
			if (stringmatch(AcquisitionMode,"swept"))	//sweep mode	

				divideBy =DwellTime *NumberOfSweeps*((abs(LastYChannel-FirstYChannel)+1 )/NumberofSlices)*(abs(LastXChannel-FirstXChannel)+1)
				// the total X channels used matter. However, the energy step doesn't.
				//(abs(LastYChannel-FirstYChannel)+1 )/NumberofSlices takes care of binning  along k direction
				//(abs(LastXChannel-FirstXChannel)+1) only works when sweep mode is used
				
			else //fix mode
				
				//old in Yan's version, not really used
				// divideBy =  NumberOfSweeps*((abs(LastYChannel-FirstYChannel)+1 )/NumberofSlices)
				divideBy =DwellTime *NumberOfSweeps
			endif
			
			
			
			
			
			//if ((numtype(BeamCurrent)!=2)&&(BeamCurrent!=0))
			//	divideby*=BeamCurrent
			//endif
			
			M_int /= divideBy	// kcts/s/channel
								// changed to counts/pixel/s, FB 10-05-04
			
			Variable FirstEnergy =round(M[0][0] * 1e5)/1e5//M[0][0]//
			Variable LastEnergy = round(M[0][dimsize(M,1)-1] * 1e5)/1e5//M[0][dimsize(M,1)-1]//	// single precision loading results in funny rounding...
			SetScale/I x, x0,x1,"deg", M_int
			SetScale/I y, FirstEnergy,LastEnergy,"eV", M_int
			
			KillWaves/Z M		
						
			// write the angles for manipulator scans in the note
			if (NumberOfBlocks > 1)
				th = StringByKey("T"+num2str(Block), dim3info,"=",";")
				ph = StringByKey("F"+num2str(Block), dim3info,"=",";")
				notestr = ReplaceStringByKey("InitialThetaManipulator", noteStr, th,"=","\r")
				notestr = ReplaceStringByKey("InitialPhiManipulator", noteStr, ph,"=","\r")
			endif
			
			notestr=Autoloadwritenote(notestr)
			if (Block==1)
				notestr=InitialForProcess(M_int,notestr)
			endif

			
//	
			//SSRL auto non-linear correction added by SDC 20140526
			//updated 20181112 to include 2D method		
//			String location=Stringbykey("location",	noteStrList,"=","\r")
//			if(stringmatch(location,"SSRL BL5-4*"))	
//			
//			String mdate=Stringbykey("date", noteStrList,"=","\r")	//find date, the NLC curve of old and new MCPs are different 20150606
//			variable year=str2num(stringfromlist(2,mdate,"/"))
//			variable day=str2num(stringfromlist(1,mdate,"/"))
//			variable month=str2num(stringfromlist(0,mdate,"/"))
//			string method
//			
//			switch(year)
//				case 2014:
//					wave B = root:gold:NLC:B_NLC_Fit_20141231
//					method = "Bwave"
//					break
//				case 2015:
//					wave B = root:gold:NLC:B_NLC_Fit_2015
//					method = "Bwave"
//					break
//				case 2016:
//					if (month<11)
//						wave B= root:gold:NLC:B_NLC_Fit_20160430
//						method = "Bwave"
//					else
//						method = "none"
//					endif
//					break
//				//after september 2017. switching to 2D method (absolute value of counts matters)
//				//it is then necessary to use the same number of energy channels to take data in swept mode.
//				//for fix mode, i have fixed the "divided by" parameter.
//				case 2017:
//					if(month<9)
//						wave B= root:gold:NLC:B_NLC_Fit_201702
//						method = "Bwave"
//					else
//						wave B= root:gold:NLC:I_channel_I0_20181110
//						method = "2D"
//					endif
//					break
//				case 2018:
//					if(month<6)
//						wave B= root:gold:NLC:I_channel_I0_20181110
//						method = "2D"
//					elseif(month<10)
//						wave B= root:gold:NLC:I_channel_I0_20180611
//						method = "2D"
//					else
//						method="none"
//					endif
//					break
//				case 2019:
//					if(month==2)
//						wave B= root:gold:NLC:I_channel_I0_201902_1600
//						method = "2D"
//					elseif(month==3)
//						wave B= root:gold:NLC:I_channel_I0_201903_1420
//						method = "2D"
//					elseif(month==5)
//						wave B= root:gold:NLC:I_channel_I0_20190502_1600
//						method = "2D"
//					else
//						method="none"
//					endif
//					break
//				default:
//					method = "none"
//			endswitch
//
//			variable channelfrom_nlc
//			
//			channelfrom_nlc=numberbykey("CCDFirstYChannel",notestr,"=","\r")
//			
//			if(stringmatch(method,"Bwave"))
//				duplicate/o M_int M_temp
//				M_int[][]=(M_temp[p][q])^(1/B[p+channelfrom_nlc-1])
//				notestr = "NLC using "+nameofwave(B)+"\r"+notestr
//				killwaves/Z M_temp
//			endif
//			
//			if(stringmatch(method,"Single"))
//				duplicate/o M_int M_temp
//				M_int[][]=(M_temp[p][q])^(1/1.4)
//				notestr = "NLC using "+"single power index = 1.4"+"\r"+notestr
//				killwaves/Z M_temp
//			endif
//			
//			if(stringmatch(method, "2D"))
//				NLC_load(M_int,B, channelfrom_nlc)
//				wave M_temp
//				M_int[][]=M_temp[p][q]
//				killwaves/Z M_temp
//				notestr = "NLC using "+nameofwave(B)+"\r"+notestr
//			endif
//			
//			endif
			//added by SDC 20140526 ends here
			
			Note M_int, noteStr
			
			
			
						
			// linescans added 02-16-04
			if (dimsize(M_int,0) > 1)
				Duplicate/O M_int $"root:rawData:"+NickName
					if (gv_rawwaveexists==1)
						Wave /Z Rawdata=$("root:process:"+NickName)
						if (waveexists(Rawdata))
							gs_rawnotestr=GetLayernotestr(note(rawdata),1,2)
							gv_rawwaveexists=2
						endif
					endif
				Duplicate/O M_int $"root:process:"+NickName
				Wave proc_data=$"root:process:"+NickName
				redimension /N=(dimsize(proc_data,0),dimsize(proc_data,1),1),proc_data
				
				if (NumberofBlocks>1)
				else	
					Write_or_read_from_logfile(proc_data)
				endif	

				String wave_path=SingleWave_autoproc_proc("root:process:"+NickName,NickName)

				//////////////for auto proc.//////////////////////
				Wave /T WavePathlist= DFR_global:WavePathlist
				Wave /T Wavenamelist= DFR_global:Wavenamelist
				
				NVAR gv_autoloadflag=DFR_global:gv_autoloadflag
				if (gv_autoloadflag)
					InsertPoints inf,1,WavePathlist,Wavenamelist
					WavePathlist[numpnts(WavePathlist)-2]=wave_path
					WaveNamelist[numpnts(WaveNamelist)-2]=NickName
				endif
		
			else		
			       NewDataFolder/o root:linescans
				NewDataFolder/o root:linescans:rawData
				e0 = M_y0(M_int)
				e1 = M_y1(M_int)
				Redimension/N=(dimsize(M_int,1)) M_int
				SetScale/I x e0,e1,"", M_int
				Duplicate/o M_int $"root:linescans:rawData:"+NickName
			endif
	
			Block += 1
			index += 1
		while (Block <= NumberOfBlocks)
		
		Region += 1
	while (Region <= NumberOfRegions)
	
	Print "loading "+filename+" complete."
	//KillWaves_withBase("MM*")		// doesn't work for large data-sets
	KillWaves/Z m_int
	KillStrings/Z s_fileName, s_waveNames, s_Path
			
	SetDataFolder DF
End

/////////////////read dim3 header////////////
static Function/S sFunc_SES_dim3(symPath, filename, Region_number)
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

/////////////// read SES header/////////////////////////

static Function/S sFunc_SES_header(symPath,filename,Region_number)		
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
	
	
	sliceValues = StringbyKey("Dimension 2 scale",noteStrList,"=","\r")
	str0 = Stringfromlist(0,sliceValues," ")//sliceValues[0,aux0]
	x0 = str2num(str0)
	str1 =Stringfromlist((itemsinlist(sliceValues," ")-1),sliceValues," ") 
	x1 = str2num(str1)

	if (stringmatch(num2str(x0),"Nan") || stringmatch(num2str(x1),"Nan") )		// scale with the slice numbers
		x0 = 0
		x1 = 1
	endif
	
		
	// get the values from the string-list
	
	//comment keywords
	String instrument = StringbyKey("Instrument",noteStrList,"=","\r")
	String location = StringbyKey("Location",noteStrList,"=","\r")
	
	
	String user = StringbyKey("User",noteStrList,"=","\r")
	String sample = StringbyKey("Sample",noteStrList,"=","\r")
	String startDate = StringbyKey("Date",noteStrList,"=","\r")
	String startTime = StringbyKey("Time",noteStrList,"=","\r")
       String regionName = StringbyKey("Region Name",noteStrList,"=","\r")
	String Energyscale = StringbyKey("Energy Scale",noteStrList,"=","\r")
	String aquisitionmode = StringbyKey("Acquisition Mode",noteStrList,"=","\r")
	String centerEnergy= StringbyKey("Center Energy",noteStrList,"=","\r")
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
	
	String polarization=""
	String AnalyzerSlit=Stringbykey("slit",notestrList,"=","\r")
	String AreaI=StringbyKey("Area",notestrlist,"=","\r")
	String comments =ReadCommentStr(noteStrList)// StringbyKey("Comments",noteStrList,"=","\r")
	
		variable polar=NumberbyKey("epu",noteStrList,"=","\r")
		if(abs(polar+0.25)<0.1)
			polarization="CL"
		endif
		if(abs(polar+0)<0.1)
			polarization="LH"
		endif
		if(abs(polar-0.25)<0.1)
			polarization="CR"
		endif
		if(abs(polar-0.5)<0.1)
			polarization="LV"
		endif
		
		comments+=polarization+";"
	//Addition keywords by user
	
	

	String temperature=""
	String Beamcurrent=""
	String manipulatorZ=""
	String manipulatorX=""
	String manipulatorY=""
	Variable theta=NAN
	Variable phi=NAN
	Variable azimuth=nan
	String excitationEnergy=""
	
	//For Hisor_BL9
	if (stringmatch("BL-9A",Location))
		manipulatorZ = Get_string_FT(comments,"z=","mm,")//StringbyKey("z",comments,"=","mm,")
		manipulatorX =  Get_string_FT(comments,"x=","mm,")//StringbyKey("x",comments,"=","mm,")
		manipulatorY =  Get_string_FT(comments,"y=","mm,")//StringbyKey("y",comments,"=","mm,")
		temperature=Get_string_FT(comments,"T=","K,")+"K"
		excitationEnergy=Get_string_FT(comments,"hn=","eV,")
		//Beamcurrent=StringbyKey("I0",notestrlist,"=","\r")
		theta=str2num(Get_string_FT(comments,"DPRF=","deg,"))
		phi=-str2num(Get_string_FT(comments,"Tilt=","deg,"))
	endif
	
	// For SSRL 5-4
	if (stringmatch(Location,"SSRL BL5-4*"))
		manipulatorZ = StringbyKey("Z",noteStrList,"=","\r")
		manipulatorX = StringbyKey("X",noteStrList,"=","\r")
		manipulatorY = StringbyKey("Y",noteStrList,"=","\r")
		temperature=Stringbykey("Sample Stage Temperature",notestrList,"=","\r")+"K"
		if ((strlen(temperature)==0)||(stringmatch(temperature,"K")==1))
			temperature=Stringbykey("Tflip",notestrList,"=","\r")+"K"
		endif
		Beamcurrent=StringbyKey("I0",notestrlist,"=","\r")
		theta=-round(NumberbyKey("T",noteStrList,"=","\r") * 1e4) / 1e4
		phi=-round(NumberbyKey("F",noteStrList,"=","\r") * 1e4) / 1e4
		
	
	endif
	
	// For SSRL 5-2
	if (stringmatch(Location,"SSRL BL5-2*"))
		manipulatorZ = StringbyKey("Z",noteStrList,"=","\r")
		manipulatorX = StringbyKey("X",noteStrList,"=","\r")
		manipulatorY = StringbyKey("Y",noteStrList,"=","\r")
		temperature=Stringbykey("T_azi",notestrList,"=","\r")+"K"
		Beamcurrent=StringbyKey("I0",notestrlist,"=","\r")
		theta=-round(NumberbyKey("T",noteStrList,"=","\r") * 1e4) / 1e4
		phi=-round(NumberbyKey("F",noteStrList,"=","\r") * 1e4) / 1e4
		
		azimuth=round(NumberbyKey("A",noteStrList,"=","\r") * 1e4) / 1e4
		comments+= "azi_"+num2str(azimuth)+";"
		azimuth=0
	endif
	
		// For Basement
	if (stringmatch(Location,"Shen-Lab, Stanford University*"))
		manipulatorZ = StringbyKey("Z",noteStrList,"=","\r")
		manipulatorX = StringbyKey("X",noteStrList,"=","\r")
		manipulatorY = StringbyKey("Y",noteStrList,"=","\r")
		temperature=Stringbykey("Sample Temperature Estimate",notestrList,"=","\r")+"K"
		
		theta=round(NumberbyKey("T",noteStrList,"=","\r") * 1e4) / 1e4
		phi=-round(NumberbyKey("F",noteStrList,"=","\r") * 1e4) / 1e4
		
	
	endif
	

	//For Bessy
	if (stringmatch("Bessy",Location))
		numberofsweeps=num2str(str2num(numberofsweeps)+1)
	endif
	
	
	
	
	//String detectorChannels = StringbyKey("Detector Channels",noteStrList,"=","\r")
	if (strlen(excitationEnergy)==0)
	excitationEnergy= StringbyKey("Excitation Energy",noteStrList,"=","\r")
	endif
	
	if (strlen(Beamcurrent)==0)
	Beamcurrent=StringbyKey("I0",notestrlist,"=","\r")
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature=Stringbykey("T",notestrList,"=","\r")
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature=Stringbykey("T",notestrList,"=",";")
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature=Stringbykey("T",notestrList,"=","K\r")+"K"
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature=Stringbykey("T",notestrList,"=","K;")+"K"
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature=Stringbykey("Tflip",notestrList,"=","\r")+"K"
	endif
	
	
	
	if ((strlen(temperature)==0)||stringmatch(temperature,"K"))
	temperature=Stringbykey("Sample Stage Temperature",notestrList,"=","\r")+"K"
	endif

	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature="0K"
	endif
		
	if ( numtype(phi)==2 )
		phi = round(NumberbyKey("phi",noteStrList,"=","\r") * 1e4) / 1e4
	endif	
	if( numtype(phi)==2 )
		phi=round(NumberbyKey("phi",noteStrList,"=",";") * 1e4) / 1e4
	endif
	if( numtype(phi)==2 )
		phi=round(NumberbyKey("F",noteStrList,"=","\r") * 1e4) / 1e4
	endif
	if( numtype(phi)==2 )
		phi=0
	endif
	
	if ( numtype(theta)==2 )
		theta = round(NumberbyKey("theta",noteStrList,"=","\r") * 1e4) / 1e4
	endif
	if( numtype(theta)==2 )
		theta=round(NumberbyKey("theta",noteStrList,"=",";") * 1e4) / 1e4
	endif
	if( numtype(theta)==2 )
		theta=round(NumberbyKey("T",noteStrList,"=","\r") * 1e4) / 1e4
	endif
	if( numtype(theta)==2 )
		theta=0
	endif
	
	
	if (numtype(azimuth)==2)
	   azimuth= round(NumberbyKey("azi",noteStrList,"=","\r") * 1e4) / 1e4
	endif
	
	if (numtype(azimuth)==2)
	    azimuth=round(NumberbyKey("azi",noteStrList,"=",";") * 1e4) / 1e4
	endif
	if (numtype(azimuth)==2)
	    azimuth=0
	endif
	
	Variable temp
	temp=strsearch(notestrlist,"[Info",0)
	notestrlist=notestrlist[temp,inf]
	noteStrList=RemoveByKey("Instrument",noteStrList,"=","\r")
	noteStrList=RemoveByKey("Location",noteStrList,"=","\r")
	noteStrList=RemoveByKey("User",noteStrList,"=","\r")
	noteStrList=RemoveByKey("Sample",noteStrList,"=","\r")
	
	noteStrList=RemoveByKey("Date",noteStrList,"=","\r")
	noteStrList=RemoveByKey("Time",noteStrList,"=","\r")
    	noteStrList=RemoveByKey("Region Name",noteStrList,"=","\r")
	noteStrList=RemoveByKey("Excitation Energy",noteStrList,"=","\r")
	noteStrList=RemoveByKey("Energy Scale",noteStrList,"=","\r")
	noteStrList=RemoveByKey("Acquisition Mode",noteStrList,"=","\r")
	noteStrList=RemoveByKey("Center Energy",noteStrList,"=","\r")
	noteStrList=RemoveByKey("Low Energy",noteStrList,"=","\r")
	noteStrList=RemoveByKey("High Energy",noteStrList,"=","\r")
	noteStrList=RemoveByKey("Energy Step",noteStrList,"=","\r")
	noteStrList=RemoveByKey("Step Time",noteStrList,"=","\r")
	noteStrList=RemoveByKey("Detector First X-Channel",noteStrList,"=","\r")
	noteStrList=RemoveByKey("Detector Last X-Channel",noteStrList,"=","\r")
	noteStrList=RemoveByKey("Detector First Y-Channel",noteStrList,"=","\r")
	noteStrList=RemoveByKey("Detector Last Y-Channel",noteStrList,"=","\r")
	noteStrList=RemoveByKey("Number of Slices",noteStrList,"=","\r")
	noteStrList=RemoveByKey("Lens Mode",noteStrList,"=","\r")
	noteStrList=RemoveByKey("Pass Energy",noteStrList,"=","\r")
	noteStrList=RemoveByKey("Number of Sweeps",noteStrList,"=","\r")
	noteStrList=RemoveByKey("slit",notestrList,"=","\r")
	noteStrList=RemoveByKey("Area",notestrlist,"=","\r")
	noteStrList=RemoveByKey("theta",notestrlist,"=","\r")
	noteStrList=RemoveByKey("phi",notestrlist,"=","\r")
	noteStrList=RemoveByKey("azi",notestrlist,"=","\r")
	noteStrList=RemoveByKey("T",notestrlist,"=","\r")
	noteStrList=RemoveByKey("F",notestrlist,"=","\r")
	noteStrList=RemoveByKey("Polarization",notestrlist,"=","\r")
	noteStrList=RemoveByKey("polarization",notestrlist,"=","\r")
	noteStrList=RemoveByKey("T",notestrlist,"=","\r")
	noteStrList=RemoveByKey("F",notestrlist,"=","\r")	
	noteStrList=RemoveByKey("Z",noteStrList,"=","\r")
	noteStrList=RemoveByKey("X",noteStrList,"=","\r")
	noteStrList=RemoveByKey("Y",noteStrList,"=","\r")
	noteStrList=RemoveByKey("Tflip",notestrList,"=","\r")
	noteStrList=RemoveByKey("Tcryo",notestrList,"=","\r")
	noteStrList=RemoveByKey("I0",notestrlist,"=","\r")
	noteStrList=RemoveByKey("Time per Spectrum Channel",notestrlist,"=","\r")
	noteStrList=RemoveByKey("Comments",notestrlist,"=","\r")
	
	String LeftNotes = ReadLeftNotes(notestrlist)//StringbyKey("Comments",noteStrList,"=","\r")
	
	// make the correct note
	noteStr = wave_keyList(2)		// with the scienta keywords
	String NickName = fileName_to_waveName(fileName,"SES")
	noteStr = ReplaceStringByKey("WaveName", noteStr,NickName,"=","\r")
	noteStr = ReplaceStringByKey("RawWaveName", noteStr,NickName,"=","\r")
	noteStr = ReplaceStringByKey("RawDataWave", noteStr,"root:rawData:"+NickName,"=","\r")
	noteStr = ReplaceStringByKey("FileName", noteStr,filename,"=","\r")
	Pathinfo $symPath
	noteStr = ReplaceStringByKey("FilePath", noteStr,S_path,"=","\r")
	noteStr = ReplaceStringByKey("User", noteStr,user,"=","\r")
	noteStr = ReplaceStringByKey("Sample", noteStr,Sample,"=","\r")
	
	noteStr = ReplaceStringByKey("Instrument", noteStr,Instrument,"=","\r")
	noteStr = ReplaceStringByKey("MeasurementSoftware", noteStr,"SES","=","\r")
	noteStr = ReplaceStringByKey("CCDFirstXChannel", noteStr,firstXchannel,"=","\r")
	noteStr = ReplaceStringByKey("CCDLastXChannel", noteStr,lastXchannel,"=","\r")
	noteStr = ReplaceStringByKey("CCDFirstYChannel", noteStr,firstYchannel,"=","\r")
	noteStr = ReplaceStringByKey("CCDLastYChannel", noteStr,lastYchannel,"=","\r")
	Variable channel_slice = (str2num(lastYchannel)-str2num(firstYchannel)+1)/str2num(NumberOfSlices)
	Variable deltaangle= 36/500/1.008//round((x1-x0)/(str2num(numberofslices)-1)* 1e7) / 1e7
	Variable degChannel = deltaangle / channel_slice
	degChannel = round (degChannel * 1e7) / 1e7
	noteStr = ReplaceNumberByKey("CCDDegreePerChannel", noteStr,degChannel,"=","\r")
	noteStr = ReplaceStringByKey("AnalyzerSlit", noteStr,AnalyzerSlit,"=","\r")
	noteStr = ReplaceStringByKey("DwellTime", noteStr,stepTime,"=","\r")
	
	noteStr = ReplaceStringByKey("RegionName", noteStr,regionName,"=","\r")
	noteStr = ReplaceStringByKey("StartDate", noteStr,StartDate,"=","\r")
	noteStr = ReplaceStringByKey("StartTime", noteStr,StartTime,"=","\r")
	noteStr = ReplaceStringByKey("LensMode", noteStr,lensmode,"=","\r")
	noteStr = ReplaceStringByKey("AcquisitionMode", noteStr,aquisitionmode,"=","\r")
	noteStr = ReplaceStringByKey("PassEnergy", noteStr,passEnergy,"=","\r")
	noteStr = ReplaceStringByKey("EnergyScale", noteStr,Energyscale,"=","\r")
	noteStr = ReplaceStringByKey("NumberOfSweeps", noteStr,numberofsweeps,"=","\r")
	noteStr = ReplaceStringbykey("SampleTemperature",noteStr,temperature,"=","\r")
	noteStr = ReplaceStringBykey("AreaIntensity",noteStr,AreaI,"=","\r")
	noteStr = ReplaceStringBykey("BeamCurrent",noteStr,Beamcurrent,"=","\r")
	noteStr = ReplaceStringByKey("PhotonEnergy", noteStr, excitationEnergy,"=","\r")
	noteStr = ReplaceNumberByKey("WorkFunction", noteStr, 4.35,"=","\r")
	
	noteStr = ReplaceStringByKey("FirstEnergy", noteStr,lowEnergy,"=","\r")	// do all Scienta's scan from low to high??
	noteStr = ReplaceStringByKey("LastEnergy", noteStr,highEnergy,"=","\r")
	aux0 = round(abs(str2num(lowEnergy) - str2num(highenergy) ) / str2num(EnergyStep) +1)
	noteStr = ReplaceStringByKey("NumberOfEnergies", noteStr,num2str(aux0),"=","\r")
	noteStr = ReplaceStringByKey("Energy Step",noteStr,Energystep,"=","\r")
	
	noteStr = ReplaceNumberByKey("FirstSlice",notestr,x0,"=","\r")
	noteStr = ReplaceNumberByKey("LastSlice",notestr,x1,"=","\r")
	noteStr = ReplaceStringByKey("NumberOfSlices", noteStr,numberofslices,"=","\r")
	noteStr = ReplaceNumberByKey("DegreeSlices", noteStr,deltaangle,"=","\r")

	noteStr = ReplaceNumberByKey("InitialThetaManipulator", noteStr,theta,"=","\r")
	noteStr = ReplaceStringByKey("OffsetThetaManipulator", noteStr,"0","=","\r")
	noteStr = ReplaceNumberByKey("InitialPhiManipulator", noteStr,Phi,"=","\r")
	noteStr = ReplaceStringByKey("OffsetPhiManipulator", noteStr,"0","=","\r")
	noteStr = ReplaceNumberByKey("InitialAzimuthManipulator", noteStr,azimuth,"=","\r")
	noteStr = ReplaceStringByKey("OffsetAzimuthManipulator", noteStr,"0","=","\r")
	noteStr = ReplaceStringByKey("X_Manipulator", noteStr,manipulatorX,"=","\r")
	noteStr = ReplaceStringByKey("Y_Manipulator", noteStr,manipulatorY,"=","\r")
	noteStr = ReplaceStringByKey("Z_Manipulator", noteStr,manipulatorZ,"=","\r")

	noteStr = ReplaceStringByKey("Comments", noteStr,Comments,"=","\r")
	noteStr = ReplaceStringByKey("LeftNotes",noteStr,LeftNotes,"=","\r")
		
	return noteStr
End



static Function /S ReadCommentStr(Str)
	String str
	
	String commentstr=""
	String tempstr

	Variable temp1,temp2
	temp1=strsearch(str,"Comments=",0)
	temp2=strsearch(str,"Date=",0)
	str=str[temp1+9,temp2-1]
	temp1=0
	temp2=0
	
	do 
		if ((temp1+1)>strlen(str))
			break
		endif
		temp2=strsearch(str,"\r",temp1)
		if (temp2==-1)
			break
		elseif (temp2==temp1)
			temp1=temp2+1
			continue
		else
			tempstr=str[temp1,temp2-1]
			if (stringmatch(tempstr,"[*]"))
				temp1=temp2+1
				continue
			endif
			commentstr+=tempstr+";"
			temp1=temp2+1
		endif
	while (1)
	return commentstr
End

Static Function /S ReadleftNotes(Str)
	String str
	
	String commentstr=""
	String tempstr
	str=noSpace(str)
	Variable temp1,temp2
	temp1=0
	temp2=0
	do 
		if ((temp1+1)>strlen(str))
			break
		endif
		temp2=strsearch(str,"\r",temp1)
		if (temp2==-1)
			break
		elseif (temp2==temp1)
			temp1=temp2+1
			continue
		else
			tempstr=str[temp1,temp2-1]
			if (stringmatch(tempstr,"[*]"))
				temp1=temp2+1
				continue
			endif
			commentstr+=tempstr+";"
			temp1=temp2+1
		endif
	while (1)
	
	return commentstr
end


















/////////////////////// fits type for ALS//////////////////////////////////////////

Function Load_fits_file(sympath,filename)
	String sympath,filename
	String nickname=fileName_to_waveName(fileName,"fits")
	DFREF DF=GetDatafolderdFR()
	
    	NewDataFolder/O/S root:rawData
 	NewDataFolder/O/S root:process
	
	DFREF DFR_raw=$("root:rawData:")//+nickname)
	DFREF DFR_proc=$("root:process:")//+nickname)
	
	Variable refnum
	Open/R/P=$sympath refnum filename
	if( refnum==0 )
		return 0
	endif
	
	String Headstr,Extendstr
	Headstr=Load_fits_headstr(refnum)
	Extendstr=Load_fits_headstr(refnum)
	SetFPosToNextRecord(refnum)
	Load_fits_data(refnum,sympath,filename,Extendstr,Headstr,DFR_raw,DFR_proc)
	
	SetDatafolder DF

End



Function Load_Fits_Data(refnum,sympath,filename,Extendstr,Headstr,DFR_raw,DFR_proc)
	Variable refnum
	String sympath,filename,Extendstr,Headstr
	DFREF DFR_raw
	DFREF DFR_proc
	
	
	Variable tempdim=numberbykey("NAXIS",Extendstr,"=","\r")
	if (tempdim==0)
		return 0
	else
		Load_fits_wave(refnum,tempdim,sympath,filename,Extendstr,Headstr,DFR_raw,DFR_proc)
	endif	

End

Function /S Load_fits_headstr(refnum)
	Variable refnum
	FStatus refnum

	String s,writestr
	String notestr=""
	s= PadString("",80,0)
	
	do
		FBinRead refnum,s
		if (cmpstr("END",s[0,2])==0)
			break
		else
			writestr=removespace(s)
			if (strlen(writestr)>0)
				notestr+=writestr+"\r"
			endif
		endif
	
	while (1)
	return notestr
End





Function Load_Fits_Wave(refnum,tempdim,sympath,filename,Extendstr, Headstr,DFR_raw,DFR_proc)
	Variable refnum,tempdim
	String sympath,filename,Extendstr,Headstr
	DFREF DFR_Raw
	DFREF DFR_proc
	
	DFREF DFR_prefs=$DF_prefs
	
	NVAR gv_ReduceXpnt=DFR_prefs:gv_ReduceXpnt
	NVAR gv_ReduceYpnt=DFR_prefs:gv_ReduceYpnt
	
	FStatus refnum

	
	Variable i=1
	Make /U/I/o/n=(tempdim),tempdimsize
	do
		tempdimsize[i-1]=numberbykey("NAXIS"+num2str(i),Extendstr,"=","\r")
		
		i+=1
	while (i<(tempdim+1))
	
	switch(tempdim)
	case 1:
		make /B/U/o/n=(tempdimsize[0]),bindata
		break
	case 2:
		make /B/U/o/n=(tempdimsize[0],tempdimsize[1]),bindata
		
		FBinRead refnum,bindata
		Variable emode= CmpStr( IgorInfo(4 ),"Intel")==0 ? 2 : 1;		
		Variable colStart=0,colBytes
		String tempstr
		for(i=1;;i+=1)
			tempstr="TFORM"+num2str(i)
			if (strsearch(Extendstr,tempstr,0,2)==-1)
				break
			endif
			String tform=Stringbykey(tempstr,Extendstr,"=","\r")
			Variable nType,numpoints,isAscii=0
			numpoints= ParseTFORM(tform[1,inf],nType,isAscii)
		
			if( numpoints==0 )		// null records are allowed
				continue
			endif
		
			colBytes= numpoints*NumSize(nType)

			String wname= Stringbykey("TTYPE"+num2str(i),Extendstr,"=","\r")
			wname=CleanupName(wname,0)
			Duplicate/O/R=[colStart,colStart+colBytes-1] bindata,$wname
			WAVE w= $wname
			if (numpoints>1)
				Redimension/E=(emode)/N=(numpoints==1 ? 0 : numpoints,tempdimsize[1])/Y=(nType) w
			else
				Redimension/E=(emode)/N=(tempdimsize[1],0)/Y=(nType) w
			endif
			
			DFREF DF=GetDatafolderdFR()
			
			if (strsearch(Extendstr,"TDIM"+num2str(i),0,2)>=0)
				
				DFREF DFR_global=$DF_global
	
				NVAR gv_autoloadflag=DFR_global:gv_autoloadflag
				NVAR gv_overflag= DFR_global:gv_overflag
				
				String spectradim=Stringbykey("TDIM"+num2str(i),Extendstr,"=","\r")
				Variable nx,ny
				Sscanf spectradim,"'(%g,%g)'",ny,nx
				
				String notestr=Fitsnote_to_Keynote(Headstr,Extendstr)
				notestr=Autoloadwritenote(notestr)
				
				Variable x0,dx,y0,dy
				
				tempstr=Stringbykey("TRVAL"+num2str(i),Extendstr,"=","\r")
			
				Sscanf tempstr,"'(%g,%g)'",x0,y0
				tempstr=Stringbykey("TDELT"+num2str(i),Extendstr,"=","\r")
				Sscanf tempstr,"'(%g,%g)'",dx,dy
				Variable angleperpixel=0.04631
				Variable zeroangle=482.497
				
				Variable Ax0=-(zeroangle-x0-0.5)*0.04631
				Variable Adx=dx*0.04631
				Variable Edy=dy
					
				
				
				
				Variable waveindex=0,countindex=0
				Variable wavenum=dimsize(w,1)
				
				Wave Xtime=$"X_time_"
		
				String scantypestr=Stringbykey("TTYPE"+num2str(i-1), Extendstr,"=","\r")
				scantypestr=removeending(scantypestr[1,inf],"'")
				String XwaveN="X_"+scantypestr+"_"
				Wave Xwave=$XwaveN
	
				
				do
					SetDatafolder DFR_raw
					if (waveindex>(wavenum-1))
						break
					endif
					
					if (wavenum>1)
						String NickName = filename_to_Wavename(filename,"fits")+"_"+num2str(waveindex)
					else
						NickName= filename_to_Wavename(filename,"fits")
					endif
					make /o/Free/n=(nx*ny) SaveWavetemp
			      		make /o/n=(nx,ny) $NickName
			      		Wave data=$Nickname
			      		
			      		SaveWavetemp=w[p][waveindex]
			      		imagetransform /M=1/D=SaveWavetemp fillImage data
					Matrixtranspose data
					
					//Matrix_reducepnts(data,gv_ReduceXpnt,gv_ReduceYpnt)
					
					String acqmode=StringByKey("AcquisitionMode", notestr, "=" ,"\r")
					if (stringmatch(acqmode,"Dithered"))
						ImageInterpolate /PXSZ={gv_ReduceXpnt,gv_ReduceYpnt} Pixelate data
						Wave M_PixelatedImage
						duplicate /o M_Pixelatedimage data
						Killwaves /Z M_PixelatedImage
						
						Adx=Adx*gv_ReduceXpnt
						Edy=dy*gv_ReduceYpnt
					endif
					
					if (wavenum>1)
						notestr=Write_loop_value(notestr,scantypestr,-Xwave[waveindex])
					endif	
					
					Variable photonenergy=numberbykey("PhotonEnergy",notestr,"=","\r")
					
					if (stringmatch(scantypestr,"mono_eV"))
						Variable Ey0=photonenergy+y0
					else
						Variable  monoev=numberbykey("MONOEV",notestr,"=","\r")
				  		if (numtype(monoev)==2)
				  			Ey0=photonenergy+y0
				  		else
							Ey0=photonenergy+y0//-(monoeV-photonenergy)*5
						endif
					endif
					
					
					Setscale /P x,Ax0,Adx,data
					Setscale /P y,Ey0,Edy,data
					
					notestr=Write_energy_angle_range(notestr,nickname,filename,sympath,Ax0,Adx,Ey0,Edy,ny,nx)
					
					String notestrWrite=notestr
	
					notestrWrite=InitialforProcess(data,notestrWrite)
			
					note data,notestrWrite
	
					SetDatafolder DFR_proc	
					Wave /Z rawdata=$Nickname
					NVAR gv_rawwaveexists=DFR_global:gv_rawwaveexists
					SVAR gs_rawnotestr=DFR_global:gs_rawnotestr
					
					if (waveexists(rawdata))
						gv_rawwaveexists=2
						gs_rawnotestr=Getlayernotestr(note(rawdata),1,2)
					else	
						gv_rawwaveexists=1
					endif
					
					Duplicate/O data, $Nickname
					Wave proc_data=$nameofwave(data)
					redimension /N=(dimsize(proc_data,0),dimsize(proc_data,1),1),proc_data
					
					Write_or_read_from_logfile(Proc_data)
				
					Wave /T WavePathlist= DFR_global:WavePathlist
					Wave /T Wavenamelist= DFR_global:Wavenamelist
				
					if (gv_autoloadflag)
						InsertPoints inf,1,WavePathlist,Wavenamelist
						WavePathlist[numpnts(WavePathlist)-2]=GetDatafolder(1)+NickName
						WaveNamelist[numpnts(WaveNamelist)-2]=NickName
					endif
					
					SingleWave_autoproc_proc(GetDatafolder(1)+NickName,NickName)
					
					Waveindex+=1
				while (waveindex<dimsize(w,1))	
			endif
			SetDatafolder DF
			colStart += colBytes
		
		endfor		
		
		break
	endswitch	
	
	
	
	KillWaves /Z bindata,w,tempdimsize,xtime,xwave
End




Static Function /S Write_loop_value(notestr,scantypestr,xwave_index)
	String notestr,scantypestr
	Variable xwave_index
	strswitch(scantypestr)
	case "mono_eV":
		notestr=replacenumberbykey("PhotonEnergy",notestr,abs(xwave_index),"=","\r")
		break
	case "Alpha":
		notestr=replacenumberbykey("InitialThetaManipulator",notestr,xwave_index,"=","\r")
		break
	endswitch
	return notestr
End

static Function /s Write_energy_angle_range(notestr,nickname,filename,sympath,Ax0,Adx,Ey0,Edy,nx,ny)
	String notestr,nickname,filename,sympath
	Variable Ax0,Adx,Ey0,Edy,nx,ny
	notestr=replacestringbykey("WaveName",notestr,nickname,"=","\r")
	notestr=replacestringbykey("RawWaveName",notestr,nickname,"=","\r")
	noteStr = ReplaceStringByKey("RawDataWave", noteStr,"root:rawData:"+NickName,"=","\r")
	notestr=replacestringbykey("Filename",notestr,filename,"=","\r")
	Pathinfo $symPath
	noteStr = ReplaceStringByKey("FilePath", noteStr,S_path,"=","\r")
	notestr=replacenumberbykey("FirstEnergy",notestr,Ey0,"=","\r")
	Variable Ey1=Ey0+Edy*ny
	notestr=replacenumberbykey("LastEnergy",notestr,Ey1,"=","\r")
	notestr=replacenumberbykey("NumberOfEnergies",notestr,ny,"=","\r")
	notestr=replacenumberbykey("Energy Step",notestr,Edy,"=","\r")
	notestr=replacenumberbykey("FirstSlice",notestr,Ax0,"=","\r")
	Variable Ax1=Ax0+Adx*nx
	notestr=replacenumberbykey("LastSlice",notestr,Ax1,"=","\r")
	notestr=replacenumberbykey("NumberOfSlices",notestr,nx,"=","\r")
	notestr=replacenumberbykey("DegreeSlices",notestr,Adx,"=","\r")
	notestr=replacenumberbykey("CCDDegreePerChannel",notestr,0.04631,"=","\r")
	return notestr
End

Static Function /S Get_string_FT(Datastring,Fstr,Tstr)
	String DataString
	String Fstr
	String Tstr	
	if (strlen(Datastring)==0)
		return ""
	endif
	
	Variable temppos1,temppos2
	if (strlen(Fstr)==0)
		temppos1=0
	else	
		temppos1=strsearch(Datastring,Fstr,0)
	endif
	
	if  (temppos1==-1)
		return ""
	endif
	
	if (strlen(Tstr)==0)
		temppos2=inf
	else
		temppos2=strsearch(Datastring,Tstr,temppos1)
	endif
	
	if (temppos2==-1)
		return ""
	else
		return Datastring[temppos1+strlen(Fstr),temppos2-1]
	endif
End

Static Function /S Fitsnote_to_Keynote(Headstr,Extendstr)
	String Headstr,Extendstr
	
	String filename=""
	String Instrument="R4000"
	//comment keywords
	String location = "ALS"//StringbyKey("Location",noteStrList,"=","\r")
	String user =""// StringbyKey("User",noteStrList,"=","\r")
	String sample = ""//StringbyKey("Sample",noteStrList,"=","\r")
	String startDate = ""//StringbyKey("Date",noteStrList,"=","\r")
	String startTime ="" //StringbyKey("Time",noteStrList,"=","\r")
    	String regionName = StringbyKey("SSRGN0",Headstr,"=","\r")
    	regionName=Get_string_FT(regionName,"","'/")
	String excitationEnergy = StringbyKey("SS_HV",Headstr,"=","\r")
	excitationEnergy=Get_string_FT(excitationEnergy,"","/#")
	
	String Energyscale = "Kinetic"//StringbyKey("Energy Scale",noteStrList,"=","\r")
	String acquisitionmode = StringbyKey("SSDE_0",Headstr,"=","\r")//Sweep"//
	acquisitionmode=Get_string_FT(acquisitionmode,"","/")
	
	if (str2num(acquisitionmode)==48)
		acquisitionmode="Dithered"
	else
		acquisitionmode="Swept"
	endif
	//print StringbyKey("SSSW0",Headstr,"=","\r")
	//print acquisitionmode
	
	String centerEnergy= "0"//StringbyKey("Center Energy",noteStrList,"=","\r")
	String lowEnergy = "0"//StringbyKey("Low Energy",noteStrList,"=","\r")
	String highEnergy = "0"//StringbyKey("High Energy",noteStrList,"=","\r")
	String EnergyStep = "0"//StringbyKey("Energy Step",noteStrList,"=","\r")
	
	String stepTime = StringbyKey("SSFR_0",Headstr,"=","\r")
	steptime=Get_string_FT(steptime,"","/#")
	
	String firstXchannel = StringbyKey("SSX0_0",Headstr,"=","\r")
	firstXchannel=Get_String_FT(firstXChannel,"","/")
	String lastXchannel = StringbyKey("SSX1_0",Headstr,"=","\r")
	LastXchannel=Get_String_FT(LastXChannel,"","/")
	String firstYchannel = StringbyKey("SSY0_0",Headstr,"=","\r")
	firstYchannel=Get_String_FT(firstYChannel,"","/")
	String lastYchannel = StringbyKey("SSY1_0",Headstr,"=","\r")
	lastYchannel=Get_String_FT(lastYChannel,"","/")
	
	
	String numberofslices = "0"//StringbyKey("Number of Slices",noteStrList,"=","\r")
	String Lensmode = StringbyKey("SSLNM0",Headstr,"=","\r")
	Lensmode=Get_String_FT(Lensmode,"'","'/")
	String passEnergy = StringbyKey("SSPE_0",Headstr,"=","\r")
	PassEnergy=Get_String_FT(PassEnergy,"","/")
	String numberofsweeps = StringbyKey("SSSW0",Headstr,"=","\r")
	numberofsweeps=Get_string_FT(numberofsweeps,"","/#")
	String polarization=""
	String AnalyzerSlit=""//Stringbykey("slit",notestrList,"=","\r")
	String AreaI=""//StringbyKey("Area",notestrlist,"=","\r")
	String comments =""//ReadCommentStr(noteStrList)// StringbyKey("Comments",noteStrList,"=","\r")
	//Addition keywords by user
	
	// For ALS
	String temperature=""
	String Beamcurrent=""
	String manipulatorZ=""
	String manipulatorX=""
	String manipulatorY=""
	Variable theta=NAN
	Variable phi=NAN
	Variable azimuth=nan
	
	
	if (strlen(Beamcurrent)==0)
	Beamcurrent=StringbyKey("I0",Headstr,"=","\r")
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature=Stringbykey("T",Headstr,"=","\r")
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature=Stringbykey("T",Headstr,"=",";")
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature=Stringbykey("T",Headstr,"=","K\r")+"K"
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature=Stringbykey("T",Headstr,"=","K;")+"K"
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature="0K"
	endif
		
	if ( numtype(phi)==2 )
		phi = round(NumberbyKey("phi",Headstr,"=","\r") * 1e4) / 1e4
	endif	
	if( numtype(phi)==2 )
		phi=round(NumberbyKey("phi",Headstr,"=",";") * 1e4) / 1e4
	endif
	if( numtype(phi)==2 )
		phi=round(NumberbyKey("F",Headstr,"=","\r") * 1e4) / 1e4
	endif
	if( numtype(phi)==2 )
		phi=0
	endif
	
	if ( numtype(theta)==2 )
		theta = round(NumberbyKey("theta",Headstr,"=","\r") * 1e4) / 1e4
	endif
	if( numtype(theta)==2 )
		theta=round(NumberbyKey("theta",Headstr,"=",";") * 1e4) / 1e4
	endif
	if( numtype(theta)==2 )
		theta=round(NumberbyKey("T",Headstr,"=","\r") * 1e4) / 1e4
	endif
	if( numtype(theta)==2 )
		theta=0
	endif
	
	
	azimuth= round(NumberbyKey("azi",Headstr,"=","\r") * 1e4) / 1e4
	if (numtype(azimuth)==2)
	    azimuth=round(NumberbyKey("azi",Headstr,"=",";") * 1e4) / 1e4
	endif
	if (numtype(azimuth)==2)
	    azimuth=0
	endif
	
	
	String LeftNotes = Headstr+Extendstr//ReadLeftNotes(Headstr)//StringbyKey("Comments",Headstr,"=","\r")
	
	// make the correct note
	String noteStr = wave_keyList(1)		// with the scienta keywords
	String NickName = fileName_to_waveName(fileName,"fits")
	noteStr = ReplaceStringByKey("WaveName", noteStr,NickName,"=","\r")
	noteStr = ReplaceStringByKey("RawWaveName", noteStr,NickName,"=","\r")
	noteStr = ReplaceStringByKey("RawDataWave", noteStr,"root:rawData:"+NickName,"=","\r")
	noteStr = ReplaceStringByKey("FileName", noteStr,filename,"=","\r")
	noteStr = ReplaceStringByKey("Sample", noteStr,Sample,"=","\r")
	noteStr = ReplaceStringByKey("Comments", noteStr,Comments,"=","\r")
	noteStr = ReplaceStringByKey("StartDate", noteStr,StartDate,"=","\r")
	noteStr = ReplaceStringByKey("StartTime", noteStr,StartTime,"=","\r")
	noteStr = ReplaceStringByKey("Instrument", noteStr,Instrument,"=","\r")
	noteStr = ReplaceStringByKey("MeasurementSoftware", noteStr,"SES","=","\r")
	noteStr = ReplaceStringByKey("User", noteStr,user,"=","\r")

	noteStr = ReplaceStringByKey("AcquisitionMode", noteStr,acquisitionmode,"=","\r")
	noteStr = ReplaceStringByKey("NumberOfSweeps", noteStr,numberofsweeps,"=","\r")
	noteStr = ReplaceStringByKey("PassEnergy", noteStr,passEnergy,"=","\r")
	noteStr = ReplaceStringByKey("AnalyzerSlit", noteStr,AnalyzerSlit,"=","\r")
	noteStr = ReplaceStringByKey("DwellTime", noteStr,stepTime,"=","\r")
	
	noteStr = ReplaceStringbykey("SampleTemperature",noteStr,temperature,"=","\r")
	noteStr = ReplaceStringBykey("AreaIntensity",noteStr,AreaI,"=","\r")
	noteStr = ReplaceStringBykey("BeamCurrent",noteStr,Beamcurrent,"=","\r")
	noteStr = ReplaceStringByKey("PhotonEnergy", noteStr, excitationEnergy,"=","\r")
	noteStr = ReplaceNumberByKey("WorkFunction", noteStr, 4.35,"=","\r")
	
	noteStr = ReplaceStringByKey("EnergyScale", noteStr,Energyscale,"=","\r")
	noteStr = ReplaceStringByKey("FirstEnergy", noteStr,lowEnergy,"=","\r")	// do all Scienta's scan from low to high??
	noteStr = ReplaceStringByKey("LastEnergy", noteStr,highEnergy,"=","\r")
	Variable aux0 = 0//round(abs(str2num(lowEnergy) - str2num(highenergy) ) / str2num(EnergyStep) +1)
	noteStr = ReplaceStringByKey("NumberOfEnergies", noteStr,num2str(aux0),"=","\r")
	noteStr = ReplaceStringByKey("Energy Step",noteStr,Energystep,"=","\r")
	
	Variable x0,x1
	
	noteStr = ReplaceStringByKey("LensMode", noteStr,lensmode,"=","\r")
	noteStr = ReplaceNumberByKey("FirstSlice",notestr,x0,"=","\r")
	noteStr = ReplaceNumberByKey("LastSlice",notestr,x1,"=","\r")
	noteStr = ReplaceStringByKey("NumberOfSlices", noteStr,numberofslices,"=","\r")
	Variable deltaangle= round((x1-x0)/(str2num(numberofslices)-1)* 1e7) / 1e7
	noteStr = ReplaceNumberByKey("DegreeSlices", noteStr,deltaangle,"=","\r")
	
	noteStr = ReplaceNumberByKey("InitialThetaManipulator", noteStr,theta,"=","\r")
	//noteStr = ReplaceNumberByKey("FinalThetaManipulator", noteStr,theta,"=","\r")
	noteStr = ReplaceStringByKey("OffsetThetaManipulator", noteStr,"0","=","\r")
	noteStr = ReplaceNumberByKey("InitialPhiManipulator", noteStr,Phi,"=","\r")
	//noteStr = ReplaceNumberByKey("FinalPhiManipulator", noteStr,Phi,"=","\r")
	noteStr = ReplaceStringByKey("OffsetPhiManipulator", noteStr,"0","=","\r")
	//noteStr = ReplaceStringByKey("NumberOfManipulatorAngles", noteStr,"1","=","\r")
	noteStr = ReplaceNumberByKey("InitialAzimuthManipulator", noteStr,azimuth,"=","\r")
	//noteStr = ReplaceNumberByKey("FinalAzimuthManipulator", noteStr,azimuth,"=","\r")
	noteStr = ReplaceStringByKey("OffsetAzimuthManipulator", noteStr,"0","=","\r")
	
	noteStr = ReplaceStringByKey("X_Manipulator", noteStr,manipulatorX,"=","\r")
	noteStr = ReplaceStringByKey("Y_Manipulator", noteStr,manipulatorY,"=","\r")
	noteStr = ReplaceStringByKey("Z_Manipulator", noteStr,manipulatorZ,"=","\r")
	
	noteStr = ReplaceStringByKey("RegionName", noteStr,regionName,"=","\r")
	// scienta orientation? try 90 as a default
	
	//noteStr = ReplaceStringByKey("InnerPotential", noteStr, InnerPotential,"=","\r")
	//noteStr = ReplaceStringByKey("ScientaOrientation", noteStr,"90","=","\r")	// this is too much confusing
	
	noteStr = ReplaceStringByKey("CCDFirstXChannel", noteStr,firstXchannel,"=","\r")
	noteStr = ReplaceStringByKey("CCDLastXChannel", noteStr,lastXchannel,"=","\r")
	noteStr = ReplaceStringByKey("CCDFirstYChannel", noteStr,firstYchannel,"=","\r")
	noteStr = ReplaceStringByKey("CCDLastYChannel", noteStr,lastYchannel,"=","\r")
	
	Variable channel_slice = (str2num(lastYchannel)-str2num(firstYchannel)+1)/str2num(NumberOfSlices)
	Variable degChannel = deltaangle / channel_slice
	degChannel = round (degChannel * 1e7) / 1e7
	//Variable channelZero = str2num(firstYchannel) + x0/(x0-x1) * channel_slice + 1		// check the '+1'!
	//channelZero = round(channelZero * 1e4) / 1e4
	//String s1
	//sprintf s1, "%18.16f", degChannel		// num2str is limited to 5 digits!
	noteStr = ReplaceNumberByKey("CCDDegreePerChannel", noteStr,degChannel,"=","\r")
	//noteStr = ReplaceNumberByKey("CCDXChannelZero", noteStr,ChannelZero,"=","\r")
	//noteStr = ReplaceNumberByKey("CCDDegreePerChannel", noteStr,degChannel,"=","\r")
	noteStr = ReplaceStringByKey("LeftNotes",noteStr,LeftNotes,"=","\r")
	//notestr = ReplaceStringByKey("MatrixType", noteStr, "carpet","=","\r")
	//noteStr = ReplaceStringByKey("AngleMapping", noteStr,"none","=","\r")
	
	
	return noteStr

End


Static Function SetFPosToNextRecord(refnum)
	Variable refnum

	FStatus refnum
	Variable nextRec= ceil(V_filePos/2880)*2880
	if( nextRec != V_filePos )
		if( nextRec >= V_logEOF )
			String/G errorstr= "hit end of file"
			return 1
		endif
		FSetPos refnum,nextRec
	endif
	return 0
end	

Static Function NumSize(ntype)
	Variable ntype
	
	Variable cmult= (ntype&0x01) ? 2 : 1;

	if( ntype&0x40 )
		return 1*cmult
	elseif( ntype &0x10 )
		return 2*cmult
	elseif( (ntype&0x20) || (ntype&0x02) )
		return 4*cmult
	elseif( ntype&0x04 )
		return 8*cmult
	else
		return -1
	endif
End

Static  Function ParseTFORM(tform,nType,isAscii)
	String tform
	Variable &nType
	Variable &isAscii
	
	Variable i,digit,num=0
	String s=""
	for(i=0;;i+=1)
		digit= char2num( tform[i]) - 48
		if( digit < 0 || digit > 9 )
			break
		endif
		num= num*10+digit
	endfor
	if( i==0 )
		num= 1		// missing repeat count is defined as 1
	endif

	strswitch(tform[i])
		case "A":
			isAscii= 1			// data is really text
		case "L":
		case "B":
			nType= 0x48		// unsigned byte
			break
		case "I":
			nType= 0x10		// signed 16 bit int
			break
		case "J":
			nType= 0x20		// signed 32 bit int
			break
		case "E":
			nType= 0x02		// 32 bit float
			break
		case "D":
			nType= 0x04		// 64 bit float
			break
		case "C":
			nType= 0x03		// 32 bit float complex
			break
		case "M":
			nType= 0x05		// 64 bit float complex
			break
		default:						// Don't handle X,A,P yet
			nType= -1
	endswitch
	return num
end







///////////////////////////////////load SIS auto itx data

Function load_SIS_itx_file(symPath, filename)
	String symPath
	
	String filename
	DFREF DFR_global=$DF_global
	NVAR gv_rawwaveexists=DFR_global:gv_rawwaveexists
	NVAR gv_autoloadflag=DFR_global:gv_autoloadflag
	SVAR gs_rawnotestr=DFR_global:gs_rawnotestr
					
	
	String nickname=fileName_to_waveName(fileName,"SES")
    	NewDataFolder/O/S root:rawData
    	//newDatafolder/o/S $nickname
	NewDataFolder/O/S root:process
	//newDatafolder/o/S $nickname
	
	String Filesub=nickname
	prompt Filesub,"Wavename"
	Variable filetype
	prompt filetype,"Auto type", popup "hv dep;mapping;"
	doprompt "load SIS itx",filesub,filetype
	if (V_flag)
		return 0
	endif
	
	LoadWave/Q/T/P=$symPath filename
	Wave Spectrum, elapsed_time_secs, phi, theta, tilt, manip_X_mm, manip_Y_mm, manip_Z_mm, hv_eV, Ep_eV
	Wave KEi_eV, KEf_eV, dE_eV, dt_ms, sweeps, tempA_K, tempB_K
	Wave machine_current_mA
	// convert to "SES-like" 2D format
	
	
	
	String wName
	Variable i
	if(!WaveExists(Spectrum))		// this would indicate some problem in loading the data
		abort
	elseif(WaveDims(Spectrum) == 3)
		for(i = 0; i < DimSize(Spectrum, 2); i += 1)
			switch	(filetype)
			case 1:
				wName = filesub+"_"+num2str(hv_eV[i])+"eV"
				break
			case 2:
			 	wName = filesub+"_"+num2indstr(i,3)
				break
			endswitch
			
			Wave /Z rawdata=$wName
			
			if (waveexists(rawdata))
				gv_rawwaveexists=2
				gs_rawnotestr=Getlayernotestr(note(rawdata),1,2)
			else	
				gv_rawwaveexists=1
			endif
						
			Make/o/D/N=(DimSize(Spectrum,1), DimSize(Spectrum,0)) $wName
			Wave w = $wName
			w = Spectrum[q][p][i]	
			SetScale/P x, KEi_eV[i], dE_eV[i], "eV", w
			Variable angle0 = DimOffset(Spectrum, 0)
			Variable dAngle = DimDelta(Spectrum, 0)
			Reverse/P/DIM=1 w	 // at the moment, the array needs to be reversed in the y direction
//			SetScale/P y, -13.1896, 0.043252, "deg", w	// right now this is hard-wired, due to lack of angular scaling in Juraj's software
			SetScale/P y, DimOffset(Spectrum, 0), DimDelta(Spectrum, 0), "deg", w
			MatrixTranspose w	
			String notestr
			notestr=note_SIS_data(filename, wName,sympath,hv_eV[i], KEi_eV[i],KEf_eV[i],dE_eV[i],dt_ms[i],DimSize(w,1),Ep_eV[i],sweeps[i],theta[i],-tilt[i],phi[i],tempB_K[i],machine_current_mA[i],manip_X_mm[i],manip_Y_mm[i],manip_Z_mm[i])			
			notestr=Autoloadwritenote(notestr)
			notestr=InitialforProcess(w,notestr)
			
			Note w, noteStr
			
			if (dimsize(w,0) > 1)
				Duplicate/O w $"root:rawData:"+nameofwave(w)
				redimension /N=(dimsize(w,0),dimsize(w,1),1),w
				
				Write_or_read_from_logfile(w)
			endif		
			
			
			Wave /T WavePathlist= DFR_global:WavePathlist
			Wave /T Wavenamelist= DFR_global:Wavenamelist
				
			if (gv_autoloadflag)
				InsertPoints inf,1,WavePathlist,Wavenamelist
				WavePathlist[numpnts(WavePathlist)-2]=GetDatafolder(1)+wName
				WaveNamelist[numpnts(WaveNamelist)-2]=wName
			endif
					
			SingleWave_autoproc_proc(GetDatafolder(1)+wName,wName)
							
			
		endfor
	else
		print "Error when attempting to load "+symPath+". Unsupported data format."
	endif
	Killwaves /Z	Spectrum, elapsed_time_secs, phi, theta, tilt, manip_X_mm, manip_Y_mm, manip_Z_mm, hv_eV, Ep_eV, KEi_eV, KEf_eV, dE_eV, dt_ms, sweeps, tempA_K, tempB_K
	Killwaves /Z 	machine_current_mA,EXSLIT_um,FMURx,FMURy,FMURz,FMUx,FMUy,FMUz
End

Function /S note_SIS_data(filename, WavesName,sympath,hn, LE,HE,Es,dt,slices,PE,sweeps, theta,phi,azi,Tem,I0,X,Y,Z)
	String filename,WavesName,sympath
	Variable hn, LE,HE,Es,dt,slices,PE,sweeps, theta,phi,azi,Tem,I0,X,Y,Z

	String noteStr = Wave_KeyList(1)		// with the scienta keywords
	String NickName = fileName_to_waveName(fileName,"SES")
	
	noteStr = ReplaceStringByKey("WaveName", noteStr,WavesName,"=","\r")
	noteStr = ReplaceStringByKey("RawWaveName", noteStr,WavesName,"=","\r")
	noteStr = ReplaceStringByKey("RawDataWave", noteStr,"root:rawData:"+WavesName,"=","\r")
	
	noteStr = ReplaceStringByKey("FileName", noteStr,filename,"=","\r")
	Pathinfo $sympath
	noteStr = ReplaceStringByKey("FilePath", noteStr,S_Path,"=","\r")

	noteStr = ReplaceStringByKey("Instrument", noteStr,"SIS","=","\r")
	noteStr = ReplaceStringByKey("MeasurementSoftware", noteStr,"SES","=","\r")

	noteStr = ReplacenumberByKey("NumberOfSweeps", noteStr,sweeps,"=","\r")
	noteStr = ReplacenumberByKey("PassEnergy", noteStr,PE,"=","\r")
	noteStr = ReplacenumberByKey("DwellTime", noteStr,dt,"=","\r")
	
	noteStr = Replacenumberbykey("SampleTemperature",noteStr,Tem,"=","\r")
	noteStr = ReplacenumberBykey("BeamCurrent",noteStr,I0,"=","\r")
	noteStr = ReplacenumberByKey("PhotonEnergy", noteStr, hn,"=","\r")
	noteStr = ReplaceNumberByKey("WorkFunction", noteStr, 4.35,"=","\r")
	
	String EnergyScale="Kinetic"
	
	noteStr = ReplaceStringByKey("EnergyScale", noteStr,Energyscale,"=","\r")
	noteStr = ReplacenumberByKey("FirstEnergy", noteStr,LE,"=","\r")	// do all Scienta's scan from low to high??
	noteStr = ReplacenumberByKey("LastEnergy", noteStr,HE,"=","\r")
	Variable aux0 = round(abs(LE-HE) / Es +1)
	noteStr = ReplacestringByKey("NumberOfEnergies", noteStr,num2str(aux0),"=","\r")
	noteStr = ReplacenumberByKey("Energy Step",noteStr,Es,"=","\r")
	
	noteStr = ReplacenumberByKey("NumberOfSlices", noteStr,slices,"=","\r")
	
	noteStr = ReplaceNumberByKey("InitialThetaManipulator", noteStr,theta,"=","\r")
	noteStr = ReplaceStringByKey("OffsetThetaManipulator", noteStr,"0","=","\r")
	noteStr = ReplaceNumberByKey("InitialPhiManipulator", noteStr,Phi,"=","\r")
	noteStr = ReplaceStringByKey("OffsetPhiManipulator", noteStr,"0","=","\r")
	noteStr = ReplaceNumberByKey("InitialAzimuthManipulator", noteStr,azi,"=","\r")
	noteStr = ReplaceStringByKey("OffsetAzimuthManipulator", noteStr,"0","=","\r")
	
	noteStr = ReplacenumberByKey("X_Manipulator", noteStr,X,"=","\r")
	noteStr = ReplacenumberByKey("Y_Manipulator", noteStr,Y,"=","\r")
	noteStr = ReplacenumberByKey("Z_Manipulator", noteStr,Z,"=","\r")
	
	noteStr = ReplaceStringByKey("RegionName", noteStr,"auto_itx","=","\r")

	Variable firstXchannel=148
	Variable lastXchannel=893
	Variable firstYchannel=191
	Variable lastYchannel=838
	Variable degChannel=0.046065
	noteStr = ReplacenumberByKey("CCDFirstXChannel", noteStr,firstXchannel,"=","\r")
	noteStr = ReplacenumberByKey("CCDLastXChannel", noteStr,lastXchannel,"=","\r")
	noteStr = ReplacenumberByKey("CCDFirstYChannel", noteStr,firstYchannel,"=","\r")
	noteStr = ReplacenumberByKey("CCDLastYChannel", noteStr,lastYchannel,"=","\r")
	
	noteStr = ReplaceNumberByKey("CCDDegreePerChannel", noteStr,degChannel,"=","\r")


	return noteStr
End


Function/S sFunc_UVSOR_header(symPath,filename)		
	String symPath, filename
	String SES_line
	String noteStrList=""
	String ValueStrList=""
	String noteStr
	
	String slicevalues
	String str0, str1
	
	Variable refnum
	Variable  aux0, aux1
	
	// convert the header between [Region N] and [Data N] in a Keyword-Value paired string-list
	Open/R /P=$symPath refnum filename
		
	// for the Helm files, we need to cut the 'Region Name' line of the header, the same line for the V-4 files contains the instrument line, which should appear in the note
	Variable index=0
	do
		FReadline refnum, SES_line		
		if (Stringmatch(SES_line,"DATA:*"))
			break
		else
			noteStrList += SES_line//removeSpace(SES_line)
		endif
	index+=1
	while (index<100)

	Close refnum

	// get the dimension 2 values
	String instrument = "MBS" //StringbyKey("Instrument",noteStrList,"=","\r")

	Variable TempPosition
	Variable TempPosition1
	String location ="UVSOR"// StringbyKey("Location",noteStrList,"=","\r")
	String user = "FengGoup"//StringbyKey("User",noteStrList,"=","\r")
	String sample =Stringbykey("NameString",noteStrList,"\t","\r")
	String tempstr=Stringbykey("STim",noteStrList,"\t","\r")
	variable temppos=0
	temppos=strsearch(tempstr,"  ",inf,1)
	String startDate =tempstr[0,temppos-2]// Stringbykey("STim",noteStrList,"\t","\t")
	String startTime =tempstr[temppos+2,inf]// PSbykey("STim",noteStrList,"\r")
	
	String regionName = StringbyKey("RegName",noteStrList,"\t","\r")
	String Energyscale = "Kinetic"//StringbyKey("Energy Scale",noteStrList,"=","\r")
	String aquisitionmode = StringbyKey("Swept Mode",noteStrList,"\t","\r")
	if (stringmatch(aquisitionmode,"Yes"))
		aquisitionmode="Swept"
	else
		aquisitionmode="Fix"
	endif
	String centerEnergy= StringbyKey("Center K.E.",noteStrList,"\t","\r")
	String lowEnergy = StringbyKey("Start K.E.",noteStrList,"\t","\r")
	String highEnergy = StringbyKey("End K.E.",noteStrList,"\t","\r")
	String EnergyStep = StringbyKey("Step Size",noteStrList,"\t","\r")
	String stepTime = StringbyKey("Frames Per Step",noteStrList,"\t","\r")
	
	String firstXchannel = StringbyKey("SX",noteStrList,"\t","\r")
	String lastXchannel = StringbyKey("EX",noteStrList,"\t","\r")
	String firstYchannel = StringbyKey("SY",noteStrList,"\t","\r")
	String lastYchannel = StringbyKey("EndY",noteStrList,"\t","\r")
	String numberofslices = StringbyKey("NoS",noteStrList,"\t","\r")
	String Lensmode = StringbyKey("Lens Mode",noteStrList,"\t","\r")
	String passEnergy = StringbyKey("Pass Energy",noteStrList,"\t","\r")[2,inf]
	String numberofsweeps = StringbyKey("No Scans",noteStrList,"\t","\r")

	String polarization=""
	String AnalyzerSlit=Stringbykey("slit",notestrList,"=","\r")
	String AreaI=StringbyKey("Area",notestrlist,"=","\r")
	String comments =Stringbykey("C1",noteStrList,"\t","\r")+","+Stringbykey("C2",noteStrList,"\t","\r")+","+Stringbykey("C3",noteStrList,"\t","\r")+","

	String temperature=""
	String Beamcurrent=""
	String manipulatorZ=""
	String manipulatorX=""
	String manipulatorY=""
	Variable theta=NAN
	Variable phi=NAN
	Variable azimuth=nan
	String excitationEnergy=""
	
	String commentsInfo=ReplaceString(",", comments, "\r" )
	 commentsInfo=ReplaceString(";", commentsInfo, "\r" )
	 commentsInfo=removeSpace(commentsInfo)
	 
	if (strlen(excitationEnergy)==0)
		excitationEnergy= StringbyKey("Excitation Energy",noteStrList,"=","\r")
	endif
	
	if (strlen(excitationEnergy)==0)
		excitationEnergy= StringbyKey("hv",commentsInfo,"=","eV\r")
	endif
	
	if (strlen(excitationEnergy)==0)
		excitationEnergy= StringbyKey("hv",commentsInfo,"=","\r")
	endif
	
	if (strlen(Beamcurrent)==0)
		Beamcurrent=StringbyKey("I0",commentsInfo,"=","\r")
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature=Stringbykey("T",commentsInfo,"=","\r")
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature=Stringbykey("T",commentsInfo,"=",";")
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature=Stringbykey("T",commentsInfo,"=",",")
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature=Stringbykey("T",commentsInfo,"=","K\r")+"K"
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature=Stringbykey("T",commentsInfo,"=","K;")+"K"
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature="0K"
	endif
		
	if ( numtype(phi)==2 )
		phi = round(NumberbyKey("phi",commentsInfo,"=","\r") * 1e4) / 1e4
	endif	
	if( numtype(phi)==2 )
		phi=round(NumberbyKey("phi",commentsInfo,"=",";") * 1e4) / 1e4
	endif
	if( numtype(phi)==2 )
		phi=round(NumberbyKey("phi",commentsInfo,"=",",") * 1e4) / 1e4
	endif
	if( numtype(phi)==2 )
		phi=round(NumberbyKey("F",commentsInfo,"=","\r") * 1e4) / 1e4
	endif
	if( numtype(phi)==2 )
		phi=0
	endif
	
	if ( numtype(theta)==2 )
		theta = round(NumberbyKey("theta",commentsInfo,"=","\r") * 1e4) / 1e4
	endif
	if( numtype(theta)==2 )
		theta=round(NumberbyKey("theta",commentsInfo,"=",";") * 1e4) / 1e4
	endif
	if( numtype(theta)==2 )
		theta=round(NumberbyKey("theta",commentsInfo,"=",",") * 1e4) / 1e4
	endif
	if( numtype(theta)==2 )
		theta=round(NumberbyKey("T",commentsInfo,"=","\r") * 1e4) / 1e4
	endif
	if( numtype(theta)==2 )
		theta=0
	endif
	
	
	azimuth= round(NumberbyKey("azi",commentsInfo,"=","\r") * 1e4) / 1e4
	if (numtype(azimuth)==2)
	    azimuth=round(NumberbyKey("azi",commentsInfo,"=",";") * 1e4) / 1e4
	endif
	if (numtype(azimuth)==2)
	    azimuth=round(NumberbyKey("azi",commentsInfo,"=",",") * 1e4) / 1e4
	endif
	if (numtype(azimuth)==2)
	    azimuth=0
	endif

	String LeftNotes = ""
	
	
	// make the correct note
	noteStr = wave_keyList(2)		// with the scienta keywords
	String NickName = fileName_to_waveName(fileName,"SES")
	noteStr = ReplaceStringByKey("WaveName", noteStr,NickName,"=","\r")
	noteStr = ReplaceStringByKey("RawWaveName", noteStr,NickName,"=","\r")
	noteStr = ReplaceStringByKey("RawDataWave", noteStr,"root:rawData:"+NickName,"=","\r")
	noteStr = ReplaceStringByKey("FileName", noteStr,filename,"=","\r")
	Pathinfo $symPath
	noteStr = ReplaceStringByKey("FilePath", noteStr,S_path,"=","\r")
	noteStr = ReplaceStringByKey("User", noteStr,user,"=","\r")
	noteStr = ReplaceStringByKey("Sample", noteStr,Sample,"=","\r")
	
	noteStr = ReplaceStringByKey("Instrument", noteStr,Instrument,"=","\r")
	noteStr = ReplaceStringByKey("MeasurementSoftware", noteStr,"SES","=","\r")
	noteStr = ReplaceStringByKey("CCDFirstXChannel", noteStr,firstXchannel,"=","\r")
	noteStr = ReplaceStringByKey("CCDLastXChannel", noteStr,lastXchannel,"=","\r")
	noteStr = ReplaceStringByKey("CCDFirstYChannel", noteStr,firstYchannel,"=","\r")
	noteStr = ReplaceStringByKey("CCDLastYChannel", noteStr,lastYchannel,"=","\r")
	Variable channel_slice = (str2num(lastYchannel)-str2num(firstYchannel)+1)/str2num(NumberOfSlices)
	Variable channelZero=524
	Variable firstX=str2num(firstYchannel)
	Variable lastX=str2num(lastYchannel)

	Variable degChannel =36/500/1.008//deltaangle / channel_slice
	degChannel = round (degChannel * 1e7) / 1e7
	
	
	Variable x0 = (firstX+ (channel_slice-1)/2 - channelZero)* degChannel
	Variable x1 = (lastX- (channel_slice-1)/2 - channelZero)* degChannel
	Variable deltaangle= round((x1-x0)/(str2num(numberofslices)-1)* 1e7) / 1e7
	
	
		
	noteStr = ReplaceNumberByKey("CCDDegreePerChannel", noteStr,degChannel,"=","\r")
	noteStr = ReplaceStringByKey("AnalyzerSlit", noteStr,AnalyzerSlit,"=","\r")
	noteStr = ReplaceStringByKey("DwellTime", noteStr,stepTime,"=","\r")
	
	noteStr = ReplaceStringByKey("RegionName", noteStr,regionName,"=","\r")
	noteStr = ReplaceStringByKey("StartDate", noteStr,StartDate,"=","\r")
	noteStr = ReplaceStringByKey("StartTime", noteStr,StartTime,"=","\r")
	noteStr = ReplaceStringByKey("LensMode", noteStr,lensmode,"=","\r")
	noteStr = ReplaceStringByKey("AcquisitionMode", noteStr,aquisitionmode,"=","\r")
	noteStr = ReplaceStringByKey("PassEnergy", noteStr,passEnergy,"=","\r")
	noteStr = ReplaceStringByKey("EnergyScale", noteStr,Energyscale,"=","\r")
	noteStr = ReplaceStringByKey("NumberOfSweeps", noteStr,numberofsweeps,"=","\r")
	noteStr = ReplaceStringbykey("SampleTemperature",noteStr,temperature,"=","\r")
	noteStr = ReplaceStringBykey("AreaIntensity",noteStr,AreaI,"=","\r")
	noteStr = ReplaceStringBykey("BeamCurrent",noteStr,Beamcurrent,"=","\r")
	noteStr = ReplaceStringByKey("PhotonEnergy", noteStr, excitationEnergy,"=","\r")
	noteStr = ReplaceNumberByKey("WorkFunction", noteStr, 4.35,"=","\r")
	
	noteStr = ReplaceStringByKey("FirstEnergy", noteStr,lowEnergy,"=","\r")	// do all Scienta's scan from low to high??
	noteStr = ReplaceStringByKey("LastEnergy", noteStr,highEnergy,"=","\r")
	aux0 = round(abs(str2num(lowEnergy) - str2num(highenergy) ) / str2num(EnergyStep) +1)
	noteStr = ReplaceStringByKey("NumberOfEnergies", noteStr,num2str(aux0),"=","\r")
	noteStr = ReplaceStringByKey("Energy Step",noteStr,Energystep,"=","\r")
	
	noteStr = ReplaceNumberByKey("FirstSlice",notestr,x0,"=","\r")
	noteStr = ReplaceNumberByKey("LastSlice",notestr,x1,"=","\r")
	noteStr = ReplaceStringByKey("NumberOfSlices", noteStr,numberofslices,"=","\r")
	noteStr = ReplaceNumberByKey("DegreeSlices", noteStr,deltaangle,"=","\r")

	noteStr = ReplaceNumberByKey("InitialThetaManipulator", noteStr,theta,"=","\r")
	noteStr = ReplaceStringByKey("OffsetThetaManipulator", noteStr,"0","=","\r")
	noteStr = ReplaceNumberByKey("InitialPhiManipulator", noteStr,Phi,"=","\r")
	noteStr = ReplaceStringByKey("OffsetPhiManipulator", noteStr,"0","=","\r")
	noteStr = ReplaceNumberByKey("InitialAzimuthManipulator", noteStr,azimuth,"=","\r")
	noteStr = ReplaceStringByKey("OffsetAzimuthManipulator", noteStr,"0","=","\r")
	noteStr = ReplaceStringByKey("X_Manipulator", noteStr,manipulatorX,"=","\r")
	noteStr = ReplaceStringByKey("Y_Manipulator", noteStr,manipulatorY,"=","\r")
	noteStr = ReplaceStringByKey("Z_Manipulator", noteStr,manipulatorZ,"=","\r")

	noteStr = ReplaceStringByKey("Comments", noteStr,Comments,"=","\r")
	noteStr = ReplaceStringByKey("LeftNotes",noteStr,LeftNotes,"=","\r")
		
	return noteStr
End





Function load_UVSOR_file(symPath,filename)
	String symPath, filename
	DFREF  DF = getDataFolderDFR()
	
	NewDataFolder/O/S root:process
	NewDataFolder/O/S root:rawData
	
	Variable refnum
	String SES_line
	
	String noteStrList=""
	
	Variable line
	line=0
	Open/R /P=$symPath refnum filename
	do
	  	FReadline/N=128 refnum, SES_line
	   	if (stringmatch(SES_line, "Data:*") )
			break
		endif
		noteStrList += SES_line
	While (line<150)
	Close refnum
	
	/////////////Overwrite or note?////////////////
	 		
	Variable numberofsweepscmp = NumberbyKey("No Scans",noteStrList,"\t","\r")
	String tempstr=Stringbykey("STim",noteStrList,"\t","\r")
	variable temppos=0
	temppos=strsearch(tempstr,"  ",inf,1)
	String Datecmp =tempstr[0,temppos-2]// Stringbykey("STim",noteStrList,"\t","\t")
	String Timecmp =tempstr[temppos+2,inf]// PSbykey("STim",noteStrList,"\r")
 	
      	
	String noteStrListcmp="Filename=;NumberofSweeps=;Date=;Time=;"
	String noteStrListcmp1
      	
      	noteStrListcmp=ReplaceStringByKey("Filename", noteStrListcmp, filename, "=", ";")
      	noteStrListcmp=ReplacenumberByKey("NumberofSweeps", noteStrListcmp, numberofsweepscmp, "=", ";")
      	noteStrListcmp=ReplaceStringByKey("Date", noteStrListcmp, Datecmp, "=", ";")
      	noteStrListcmp=ReplaceStringByKey("Time", noteStrListcmp, Timecmp, "=", ";")
      	
      	
      	DFREF DFR_global=$DF_global
      	NVAR gv_overflag= DFR_global:gv_overflag
      	SVAR LoadWaveList=DFR_global:LoadWaveList
      	SVAR LoadWaveNotes=DFR_global:LoadWaveNotes
      	NVAR gv_rawwaveexists=DFR_global:gv_rawwaveexists
      	SVAR gs_rawnotestr=DFR_global:gs_rawnotestr
      	
      	Variable filenum
      	if (strlen(LoadWaveList)==0)
      		filenum=-1
      	else
      		filenum=Whichlistitem(filename, LoadWaveList, "\r", 0 )
      	endif
      	
	if (filenum>=0)      	
		if (gv_overflag==0)	
      			noteStrListcmp1=StringFromList(filenum, LoadWaveNotes,"\r")
			if (stringmatch(noteStrListcmp,noteStrListcmp1)) 
      				// same file
      				SetDatafolder DF
      				return 1
      			endif
      		endif
      				// not the same file or overwrite
      		LoadWaveNotes=RemoveListItem(filenum,LoadWaveNotes,"\r")
      		LoadWaveList=Removelistitem(filenum,LoadwaveList,"\r")
      		
      		gv_rawwaveexists=1
      	else
      		gv_rawwaveexists=0
	endif
     
	LoadWaveNotes=AddListItem(noteStrListcmp, LoadWaveNotes, "\r",inf)		
	LoadWaveList=AddListItem(filename, LoadWaveList, "\r",inf)
	
	KillWaves_withBase("MM")
	LoadWave/G/M/Q/O/A=MM /P=$symPath filename
	
	if (V_flag==0)
  		 SetDatafolder DF
   		return 1
   	endif
   	


	String DataName, cmd, NickName, w_Name
	String th, ph
	Variable done
	Variable index
	Variable e0, e1, divideBy
	String ValueStrList

	// scaling, saving and header
	String notestr = sFunc_UVSOR_header(symPath, filename)
		
	Variable FirstYchannel = NumberByKey("CCDFirstYChannel",noteStr,"=","\r")
	Variable LastYchannel = NumberByKey("CCDLastYChannel",noteStr,"=","\r")
	Variable FirstXchannel = NumberByKey("CCDFirstXChannel",noteStr,"=","\r")
	Variable LastXchannel = NumberByKey("CCDLastXChannel",noteStr,"=","\r")
	
	Variable DwellTime = NumberByKey("DwellTime", noteStr, "=","\r")
	Variable NumberOfSweeps = NumberByKey("NumberOfSweeps", noteStr, "=","\r")
	Variable x0=NumberByKey("Firstslice", noteStr, "=","\r")
	Variable x1=NumberByKey("Lastslice", noteStr, "=","\r")
	Variable Beamcurrent=Numberbykey("BeamCurrent",noteStr,"=","\r")
	Variable NumberofSlices=NumberByKey("NumberOfSlices", noteStr, "=","\r")
	Variable EnergyStep=NumberByKey("Energy Step", noteStr, "=","\r")
	
	NickName = fileName_to_waveName(fileName,"SES")
	
	String baseNickname=NickName
	
	WAVE M = $("MM"+num2str(0))
	MatrixTranspose M
	Duplicate/R=[1,dimsize(M,0)-1][]/O M M_int	
	
	if (DwellTime >= 33)		// seems to be a file with ms 'Step Time' try to get absolute CCD value//only work for sweep modes
				//divideBy=DwellTime*NumberOfSweeps*
				//divideBy = DwellTime * NumberOfSweeps * channel_slice
		divideBy =DwellTime *NumberOfSweeps*((abs(LastYChannel-FirstYChannel)+1 )/NumberofSlices)*(abs(LastXChannel-FirstXChannel)+1)
	else
				//divideBy = DwellTime * NumberOfSweeps * channel_slice * 1000
		divideBy =  NumberOfSweeps*((abs(LastYChannel-FirstYChannel)+1 )/NumberofSlices)
				//NumberOfSweeps * (abs(LastXChannel-FirstXChannel)+1) * ((abs(LastYChannel-FirstYChannel)+1 )/NumberofSlices)
	endif

	M_int /= divideBy
	
	Variable FirstEnergy =round(M[0][0] * 1e5)/1e5//M[0][0]//
	Variable LastEnergy = round(M[0][dimsize(M,1)-1] * 1e5)/1e5//M[0][dimsize(M,1)-1]//	// single precision loading results in funny rounding...
	SetScale/I x, x0,x1,"deg", M_int
	SetScale/I y, FirstEnergy,LastEnergy,"eV", M_int
			
	KillWaves/Z M		
						
	KillWaves_withBase("MM")
	notestr=Autoloadwritenote(notestr)

	notestr=InitialForProcess(M_int,notestr)

	Note M_int, noteStr
			
			
						
	// linescans added 02-16-04
	if (dimsize(M_int,0) > 1)
		Duplicate/O M_int $"root:rawData:"+NickName
			if (gv_rawwaveexists==1)
				Wave /Z Rawdata=$("root:process:"+NickName)
				if (waveexists(Rawdata))
					gs_rawnotestr=GetLayernotestr(note(rawdata),1,2)
					gv_rawwaveexists=2
				endif
			endif
		Duplicate/O M_int $"root:process:"+NickName
		Wave proc_data=$"root:process:"+NickName
		redimension /N=(dimsize(proc_data,0),dimsize(proc_data,1),1),proc_data
				
		
		Write_or_read_from_logfile(proc_data)	

		String wave_path=SingleWave_autoproc_proc("root:process:"+NickName,NickName)

		//////////////for auto proc.//////////////////////
		Wave /T WavePathlist= DFR_global:WavePathlist
		Wave /T Wavenamelist= DFR_global:Wavenamelist
				
		NVAR gv_autoloadflag=DFR_global:gv_autoloadflag
		if (gv_autoloadflag)
			InsertPoints inf,1,WavePathlist,Wavenamelist
			WavePathlist[numpnts(WavePathlist)-2]=wave_path
			WaveNamelist[numpnts(WaveNamelist)-2]=NickName
		endif
		
	else		
		NewDataFolder/o root:linescans
		NewDataFolder/o root:linescans:rawData
		e0 = M_y0(M_int)
		e1 = M_y1(M_int)
		Redimension/N=(dimsize(M_int,1)) M_int
		SetScale/I x e0,e1,"", M_int
		Duplicate/o M_int $"root:linescans:rawData:"+NickName
	endif
	
	
	//KillWaves_withBase("MM*")		// doesn't work for large data-sets
	KillWaves/Z m_int
	KillStrings/Z s_fileName, s_waveNames, s_Path
			
	SetDataFolder DF

End

Function/S sFunc_SPECS_header(symPath,filename)		
	String symPath, filename
	String SES_line
	String noteStrList=""
	String ValueStrList=""
	String noteStr
	
	String slicevalues
	String str0, str1
	
	Variable refnum
	Variable  aux0, aux1,line
	
	// convert the header between [Region N] and [Data N] in a Keyword-Value paired string-list
	Open/R /P=$symPath refnum filename
	

	// for the Helm files, we need to cut the 'Region Name' line of the header, the same line for the V-4 files contains the instrument line, which should appear in the note
	Variable index=0
	do
		FReadline refnum, SES_line
	   	if (numtype(str2num(SES_line[0]))!=2)
	   		noteStrList += "DIM="+SES_line[0,inf]+"\r"
			break
		endif
		noteStrList += SES_line[1,inf]
	While (line<150)
	Close refnum

	noteStrlist=removeallspecs(notestrlist)
	// get the dimension 2 values
	String instrument = "SPECS" //StringbyKey("Instrument",noteStrList,"=","\r")

	Variable TempPosition
	Variable TempPosition1
	String location ="SPECS"// StringbyKey("Location",noteStrList,"=","\r")
	String user = "FengGoup"//StringbyKey("User",noteStrList,"=","\r")
	String sample =""//Stringbykey("",noteStrList,"\t","\r")
	
	String tempstr=Stringbykey("CreationDate",noteStrList,"=","\r")
	String startDate// =tempstr[0,9]// Stringbykey("STim",noteStrList,"\t","\t")
	String startTime// =tempstr[10,17]// PSbykey("STim",noteStrList,"\r")
	sscanf tempstr, " %s %s UTC", startDate,startTime
		
	
	String regionName = "Specs"//StringbyKey("RegName",noteStrList,"\t","\r")
	String Energyscale = "Kinetic"//StringbyKey("Energy Scale",noteStrList,"=","\r")
	String aquisitionmode = StringbyKey("Images",noteStrList,"=","\r")
	if (stringmatch(aquisitionmode,"Corrected"))
		aquisitionmode="Swept"
	else
		aquisitionmode="Fix"
	endif
	
	tempstr=StringbyKey("ERange",noteStrList,"=","\r")
	String lowEnergy,highEnergy
	sscanf tempstr," %s %s [eV],*",lowEnergy,highEnergy
	
	tempstr=Stringbykey("DIM",notestrList,"=","\r")
	String n_angle,n_energy
	sscanf tempstr,"%s %s *",n_energy,n_angle
	
	Variable d_energy=(str2num(highEnergy)-str2num(lowEnergy))/str2num(n_energy)
	lowEnergy=num2str(str2num(lowEnergy)+d_energy*0.5)
	highEnergy=num2str(str2num(lowEnergy)+d_energy*(str2num(n_energy)-1))
	
	String EnergyStep = num2str(d_energy)//StringbyKey("Step Size",noteStrList,"\t","\r")
	String centerEnergy= num2str((str2num(highEnergy)-str2num(lowEnergy))/2)//StringbyKey("Center K.E.",noteStrList,"\t","\r")
	
	
	String stepTime = StringbyKey("Frames Per Step",noteStrList,"\t","\r")
	
	String firstXchannel = "1"//StringbyKey("SX",noteStrList,"\t","\r")
	String lastXchannel = "1000"//StringbyKey("EX",noteStrList,"\t","\r")
	String firstYchannel ="1"// StringbyKey("SY",noteStrList,"\t","\r")
	String lastYchannel = "1000"//StringbyKey("EndY",noteStrList,"\t","\r")
	String numberofslices = n_angle//StringbyKey("NoS",noteStrList,"\t","\r")
	
	String Lensmode = StringbyKey("lensmode",noteStrList,"=","\r")
	
	tempstr=Stringbykey("Ep",noteStrlist,"=","\r")
	String passEnergy
	sscanf tempstr,"%s [eV]*",passEnergy
	 
	
	//StringbyKey("Pass Energy",noteStrList,"\t","\r")[2,inf]
	String numberofsweeps = StringbyKey("No Scans",noteStrList,"\t","\r")

	String polarization=""
	String AnalyzerSlit=Stringbykey("slit",notestrList,"=","\r")
	String AreaI=StringbyKey("Area",notestrlist,"=","\r")
	String comments =Stringbykey("C1",noteStrList,"\t","\r")+","+Stringbykey("C2",noteStrList,"\t","\r")+","+Stringbykey("C3",noteStrList,"\t","\r")+","

	String temperature=""
	String Beamcurrent=""
	String manipulatorZ=""
	String manipulatorX=""
	String manipulatorY=""
	Variable theta=NAN
	Variable phi=NAN
	Variable azimuth=nan
	String excitationEnergy=""
	
	String commentsInfo=ReplaceString(",", comments, "\r" )
	 commentsInfo=ReplaceString(";", commentsInfo, "\r" )
	 commentsInfo=removeSpace(commentsInfo)
	 
	if (strlen(excitationEnergy)==0)
		excitationEnergy= StringbyKey("Excitation Energy",noteStrList,"=","\r")
	endif
	
	if (strlen(excitationEnergy)==0)
		excitationEnergy= StringbyKey("hv",commentsInfo,"=","eV\r")
	endif
	
	if (strlen(excitationEnergy)==0)
		excitationEnergy= StringbyKey("hv",commentsInfo,"=","\r")
	endif
	
	if (strlen(Beamcurrent)==0)
		Beamcurrent=StringbyKey("I0",commentsInfo,"=","\r")
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature=Stringbykey("T",commentsInfo,"=","\r")
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature=Stringbykey("T",commentsInfo,"=",";")
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature=Stringbykey("T",commentsInfo,"=",",")
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature=Stringbykey("T",commentsInfo,"=","K\r")+"K"
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature=Stringbykey("T",commentsInfo,"=","K;")+"K"
	endif
	
	if ((strlen(temperature)==0)||(strsearch(temperature,"K",0)==-1))
	temperature="0K"
	endif
		
	if ( numtype(phi)==2 )
		phi = round(NumberbyKey("phi",commentsInfo,"=","\r") * 1e4) / 1e4
	endif	
	if( numtype(phi)==2 )
		phi=round(NumberbyKey("phi",commentsInfo,"=",";") * 1e4) / 1e4
	endif
	if( numtype(phi)==2 )
		phi=round(NumberbyKey("phi",commentsInfo,"=",",") * 1e4) / 1e4
	endif
	if( numtype(phi)==2 )
		phi=round(NumberbyKey("F",commentsInfo,"=","\r") * 1e4) / 1e4
	endif
	if( numtype(phi)==2 )
		phi=0
	endif
	
	if ( numtype(theta)==2 )
		theta = round(NumberbyKey("theta",commentsInfo,"=","\r") * 1e4) / 1e4
	endif
	if( numtype(theta)==2 )
		theta=round(NumberbyKey("theta",commentsInfo,"=",";") * 1e4) / 1e4
	endif
	if( numtype(theta)==2 )
		theta=round(NumberbyKey("theta",commentsInfo,"=",",") * 1e4) / 1e4
	endif
	if( numtype(theta)==2 )
		theta=round(NumberbyKey("T",commentsInfo,"=","\r") * 1e4) / 1e4
	endif
	if( numtype(theta)==2 )
		theta=0
	endif
	
	
	azimuth= round(NumberbyKey("azi",commentsInfo,"=","\r") * 1e4) / 1e4
	if (numtype(azimuth)==2)
	    azimuth=round(NumberbyKey("azi",commentsInfo,"=",";") * 1e4) / 1e4
	endif
	if (numtype(azimuth)==2)
	    azimuth=round(NumberbyKey("azi",commentsInfo,"=",",") * 1e4) / 1e4
	endif
	if (numtype(azimuth)==2)
	    azimuth=0
	endif

	String LeftNotes = ""
	
	
	// make the correct note
	noteStr = wave_keyList(2)		// with the scienta keywords
	String NickName = fileName_to_waveName(fileName,"SPECS")
	noteStr = ReplaceStringByKey("WaveName", noteStr,NickName,"=","\r")
	noteStr = ReplaceStringByKey("RawWaveName", noteStr,NickName,"=","\r")
	noteStr = ReplaceStringByKey("RawDataWave", noteStr,"root:rawData:"+NickName,"=","\r")
	noteStr = ReplaceStringByKey("FileName", noteStr,filename,"=","\r")
	Pathinfo $symPath
	noteStr = ReplaceStringByKey("FilePath", noteStr,S_path,"=","\r")
	noteStr = ReplaceStringByKey("User", noteStr,user,"=","\r")
	noteStr = ReplaceStringByKey("Sample", noteStr,Sample,"=","\r")
	
	noteStr = ReplaceStringByKey("Instrument", noteStr,Instrument,"=","\r")
	noteStr = ReplaceStringByKey("MeasurementSoftware", noteStr,"SES","=","\r")
	noteStr = ReplaceStringByKey("CCDFirstXChannel", noteStr,firstXchannel,"=","\r")
	noteStr = ReplaceStringByKey("CCDLastXChannel", noteStr,lastXchannel,"=","\r")
	noteStr = ReplaceStringByKey("CCDFirstYChannel", noteStr,firstYchannel,"=","\r")
	noteStr = ReplaceStringByKey("CCDLastYChannel", noteStr,lastYchannel,"=","\r")
	
	Variable channel_slice = (str2num(lastYchannel)-str2num(firstYchannel)+1)/str2num(NumberOfSlices)
	
	tempstr=StringBykey("aRange",noteStrlist,"=","\r")
	Variable x0
	Variable x1
	sscanf tempstr,"%g %g [*",x0,x1
	x0=(x0==0)?(	-15):(x0)
	x1=(x1==0)?(15):(x1)
	
	Variable deltaangle= round((x1-x0)/(str2num(numberofslices)-1)* 1e7) / 1e7
	
	Variable firstX=str2num(firstYchannel)
	Variable lastX=str2num(lastYchannel)

	Variable degChannel =deltaangle / channel_slice
	degChannel = round (degChannel * 1e7) / 1e7

		
	noteStr = ReplaceNumberByKey("CCDDegreePerChannel", noteStr,degChannel,"=","\r")
	noteStr = ReplaceStringByKey("AnalyzerSlit", noteStr,AnalyzerSlit,"=","\r")
	noteStr = ReplaceStringByKey("DwellTime", noteStr,stepTime,"=","\r")
	
	noteStr = ReplaceStringByKey("RegionName", noteStr,regionName,"=","\r")
	noteStr = ReplaceStringByKey("StartDate", noteStr,StartDate,"=","\r")
	noteStr = ReplaceStringByKey("StartTime", noteStr,StartTime,"=","\r")
	noteStr = ReplaceStringByKey("LensMode", noteStr,lensmode,"=","\r")
	noteStr = ReplaceStringByKey("AcquisitionMode", noteStr,aquisitionmode,"=","\r")
	noteStr = ReplaceStringByKey("PassEnergy", noteStr,passEnergy,"=","\r")
	noteStr = ReplaceStringByKey("EnergyScale", noteStr,Energyscale,"=","\r")
	noteStr = ReplaceStringByKey("NumberOfSweeps", noteStr,numberofsweeps,"=","\r")
	noteStr = ReplaceStringbykey("SampleTemperature",noteStr,temperature,"=","\r")
	noteStr = ReplaceStringBykey("AreaIntensity",noteStr,AreaI,"=","\r")
	noteStr = ReplaceStringBykey("BeamCurrent",noteStr,Beamcurrent,"=","\r")
	noteStr = ReplaceStringByKey("PhotonEnergy", noteStr, excitationEnergy,"=","\r")
	noteStr = ReplaceNumberByKey("WorkFunction", noteStr, 4.35,"=","\r")
	
	noteStr = ReplaceStringByKey("FirstEnergy", noteStr,lowEnergy,"=","\r")	// do all Scienta's scan from low to high??
	noteStr = ReplaceStringByKey("LastEnergy", noteStr,highEnergy,"=","\r")
	aux0 = round(abs(str2num(lowEnergy) - str2num(highenergy) ) / str2num(EnergyStep) +1)
	noteStr = ReplaceStringByKey("NumberOfEnergies", noteStr,num2str(aux0),"=","\r")
	noteStr = ReplaceStringByKey("Energy Step",noteStr,Energystep,"=","\r")
	
	noteStr = ReplaceNumberByKey("FirstSlice",notestr,x0,"=","\r")
	noteStr = ReplaceNumberByKey("LastSlice",notestr,x1,"=","\r")
	noteStr = ReplaceStringByKey("NumberOfSlices", noteStr,numberofslices,"=","\r")
	noteStr = ReplaceNumberByKey("DegreeSlices", noteStr,deltaangle,"=","\r")

	noteStr = ReplaceNumberByKey("InitialThetaManipulator", noteStr,theta,"=","\r")
	noteStr = ReplaceStringByKey("OffsetThetaManipulator", noteStr,"0","=","\r")
	noteStr = ReplaceNumberByKey("InitialPhiManipulator", noteStr,Phi,"=","\r")
	noteStr = ReplaceStringByKey("OffsetPhiManipulator", noteStr,"0","=","\r")
	noteStr = ReplaceNumberByKey("InitialAzimuthManipulator", noteStr,azimuth,"=","\r")
	noteStr = ReplaceStringByKey("OffsetAzimuthManipulator", noteStr,"0","=","\r")
	noteStr = ReplaceStringByKey("X_Manipulator", noteStr,manipulatorX,"=","\r")
	noteStr = ReplaceStringByKey("Y_Manipulator", noteStr,manipulatorY,"=","\r")
	noteStr = ReplaceStringByKey("Z_Manipulator", noteStr,manipulatorZ,"=","\r")

	noteStr = ReplaceStringByKey("Comments", noteStr,Comments,"=","\r")
	noteStr = ReplaceStringByKey("LeftNotes",noteStr,LeftNotes,"=","\r")
		
	return noteStr
End


Function load_Specs_sP2_file(symPath,filename)
	String symPath, filename
	DFREF  DF = getDataFolderDFR()
	
	NewDataFolder/O/S root:process
	NewDataFolder/O/S root:rawData
	
	Variable refnum
	String SES_line
	
	String noteStrList=""
	
	Variable line
	line=0
	Open/R /P=$symPath refnum filename
	do
	  	FReadline refnum, SES_line
	   	if (numtype(str2num(SES_line[0]))!=2)
			noteStrList += "DIM="+SES_line[0,inf]+"\r"
			break
		endif
		noteStrList += SES_line[1,inf]
		line+=1
	While (line<150)
	Close refnum
	/////////////Overwrite or note?////////////////
	noteStrlist=removeallspecs(notestrlist)
	 		
	Variable numberofsweepscmp = 1//mberbyKey("No Scans",noteStrList,"\t","\r")
	String tempstr=Stringbykey("CreationDate",noteStrList,"=","\r")
	String Datecmp,Timecmp
	sscanf tempstr, " %s %s UTC", Datecmp,Timecmp
	
 	
      	
	String noteStrListcmp="Filename=;NumberofSweeps=;Date=;Time=;"
	String noteStrListcmp1
      	
      	noteStrListcmp=ReplaceStringByKey("Filename", noteStrListcmp, filename, "=", ";")
      	noteStrListcmp=ReplacenumberByKey("NumberofSweeps", noteStrListcmp, numberofsweepscmp, "=", ";")
      	noteStrListcmp=ReplaceStringByKey("Date", noteStrListcmp, Datecmp, "=", ";")
      	noteStrListcmp=ReplaceStringByKey("Time", noteStrListcmp, Timecmp, "=", ";")
      	
      	
      	DFREF DFR_global=$DF_global
      	NVAR gv_overflag= DFR_global:gv_overflag
      	SVAR LoadWaveList=DFR_global:LoadWaveList
      	SVAR LoadWaveNotes=DFR_global:LoadWaveNotes
      	NVAR gv_rawwaveexists=DFR_global:gv_rawwaveexists
      	SVAR gs_rawnotestr=DFR_global:gs_rawnotestr
      	
      	Variable filenum
      	if (strlen(LoadWaveList)==0)
      		filenum=-1
      	else
      		filenum=Whichlistitem(filename, LoadWaveList, "\r", 0 )
      	endif
      	
	if (filenum>=0)      	
		if (gv_overflag==0)	
      			noteStrListcmp1=StringFromList(filenum, LoadWaveNotes,"\r")
			if (stringmatch(noteStrListcmp,noteStrListcmp1)) 
      				// same file
      				SetDatafolder DF
      				return 1
      			endif
      		endif
      				// not the same file or overwrite
      		LoadWaveNotes=RemoveListItem(filenum,LoadWaveNotes,"\r")
      		LoadWaveList=Removelistitem(filenum,LoadwaveList,"\r")
      		
      		gv_rawwaveexists=1
      	else
      		gv_rawwaveexists=0
	endif
     
	LoadWaveNotes=AddListItem(noteStrListcmp, LoadWaveNotes, "\r",inf)		
	LoadWaveList=AddListItem(filename, LoadWaveList, "\r",inf)
	
	KillWaves_withBase("MM")
	tempstr=Stringbykey("DIM",notestrList,"=","\r")
	Variable numTotalRows,numTotalCols
	sscanf tempstr,"%g %g *",numTotalRows,numTotalCols
	
	//LoadWave/G/M/Q/O/A=MM /P=$symPath filename
	LoadWave/O/Q/K=0/A=MM/G/L={0,line+1, numTotalRows*numTotalCols,0,1} /P=$symPath filename
 	Wave M = $StringFromList(0,S_waveNames)

	String DataName, cmd, NickName, w_Name
	String th, ph
	Variable done
	Variable index
	Variable e0, e1, divideBy
	String ValueStrList

	// scaling, saving and header
	String notestr = sFunc_SPECS_header(symPath, filename)
		
	Variable FirstYchannel = NumberByKey("CCDFirstYChannel",noteStr,"=","\r")
	Variable LastYchannel = NumberByKey("CCDLastYChannel",noteStr,"=","\r")
	Variable FirstXchannel = NumberByKey("CCDFirstXChannel",noteStr,"=","\r")
	Variable LastXchannel = NumberByKey("CCDLastXChannel",noteStr,"=","\r")
	
	Variable DwellTime = NumberByKey("DwellTime", noteStr, "=","\r")
	Variable NumberOfSweeps = NumberByKey("NumberOfSweeps", noteStr, "=","\r")
	Variable x0=NumberByKey("Firstslice", noteStr, "=","\r")
	Variable x1=NumberByKey("Lastslice", noteStr, "=","\r")
	Variable Beamcurrent=Numberbykey("BeamCurrent",noteStr,"=","\r")
	Variable NumberofSlices=NumberByKey("NumberOfSlices", noteStr, "=","\r")
	Variable EnergyStep=NumberByKey("Energy Step", noteStr, "=","\r")
	String acqmode=Stringbykey("AcquisitionMode",noteStr,"=","\r")
	
	NickName = fileName_to_waveName(fileName,"SPECS")
	
	String baseNickname=NickName
	
	
	Make/o/I/U/N=(numTotalRows,numTotalCols) tempMatrix
       Wave wv = tempMatrix
       Variable i
        for( i=0; i < numTotalCols; i+=1 )
            wv[][i] = M[p+i*numTotalRows]
          endfor
	
	
	MatrixTranspose wv
	Duplicate /O wv M_int	
	Killwaves /Z wv
	
	if (DwellTime >= 33)		// seems to be a file with ms 'Step Time' try to get absolute CCD value//only work for sweep modes
				//divideBy=DwellTime*NumberOfSweeps*
				//divideBy = DwellTime * NumberOfSweeps * channel_slice
		divideBy =DwellTime *NumberOfSweeps*((abs(LastYChannel-FirstYChannel)+1 )/NumberofSlices)*(abs(LastXChannel-FirstXChannel)+1)
	else
				//divideBy = DwellTime * NumberOfSweeps * channel_slice * 1000
		divideBy =  NumberOfSweeps*((abs(LastYChannel-FirstYChannel)+1 )/NumberofSlices)
				//NumberOfSweeps * (abs(LastXChannel-FirstXChannel)+1) * ((abs(LastYChannel-FirstYChannel)+1 )/NumberofSlices)
	endif

	divideBy=1
	
	M_int /= divideBy
	
	
	if (stringmatch(acqmode,"fix"))
		DFREF DFR_prefs=$DF_prefs
		NVAR gv_ReduceXpnt=DFR_prefs:gv_ReduceXpnt
		NVAR gv_ReduceYpnt=DFR_prefs:gv_ReduceYpnt
		ImageInterpolate /PXSZ={gv_ReduceXpnt,gv_ReduceYpnt} Pixelate M_int
		Wave M_PixelatedImage
		duplicate /o M_Pixelatedimage M_int
		Killwaves /Z M_PixelatedImage
	endif
	
	Variable FirstEnergy = NumberbyKey("FirstEnergy",noteStr,"=","\r")//round(M[0][0] * 1e5)/1e5//M[0][0]//
	Variable LastEnergy = NumberbyKey("LastEnergy",noteStr,"=","\r")//round(M[0][dimsize(M,1)-1] * 1e5)/1e5//M[0][dimsize(M,1)-1]//	// single precision loading results in funny rounding...
	SetScale/I x, x0,x1,"deg", M_int
	SetScale/I y, FirstEnergy,LastEnergy,"eV", M_int
				
	KillWaves/Z M					

	notestr=Autoloadwritenote(notestr)
	
	notestr=InitialForProcess(M_int,notestr)

	Note M_int, noteStr
			
			
						
	// linescans added 02-16-04
	if (dimsize(M_int,0) > 1)
		Duplicate/O M_int $"root:rawData:"+NickName
			if (gv_rawwaveexists==1)
				Wave /Z Rawdata=$("root:process:"+NickName)
				if (waveexists(Rawdata))
					gs_rawnotestr=GetLayernotestr(note(rawdata),1,2)
					gv_rawwaveexists=2
				endif
			endif
		Duplicate/O M_int $"root:process:"+NickName
		Wave proc_data=$"root:process:"+NickName
		redimension /N=(dimsize(proc_data,0),dimsize(proc_data,1),1),proc_data
				
		
		Write_or_read_from_logfile(proc_data)	

		String wave_path=SingleWave_autoproc_proc("root:process:"+NickName,NickName)

		//////////////for auto proc.//////////////////////
		Wave /T WavePathlist= DFR_global:WavePathlist
		Wave /T Wavenamelist= DFR_global:Wavenamelist
				
		NVAR gv_autoloadflag=DFR_global:gv_autoloadflag
		if (gv_autoloadflag)
			InsertPoints inf,1,WavePathlist,Wavenamelist
			WavePathlist[numpnts(WavePathlist)-2]=wave_path
			WaveNamelist[numpnts(WaveNamelist)-2]=NickName
		endif
		
	else		
		NewDataFolder/o root:linescans
		NewDataFolder/o root:linescans:rawData
		e0 = M_y0(M_int)
		e1 = M_y1(M_int)
		Redimension/N=(dimsize(M_int,1)) M_int
		SetScale/I x e0,e1,"", M_int
		Duplicate/o M_int $"root:linescans:rawData:"+NickName
	endif
	
	
	//KillWaves_withBase("MM*")		// doesn't work for large data-sets
	KillWaves/Z m_int
	KillStrings/Z s_fileName, s_waveNames, s_Path
			
	SetDataFolder DF

End

Function /S removeallspecs(str)
	String str
	String tempstr,resultstr
	
	Variable i,j
	Variable equalflag=0
	
	resultstr=""
	
	i=0
	do
		if (i>=strlen(Str))
			break
		endif
		tempstr=""
		
		do
			if (i>=strlen(Str))
				break
			endif
			if (cmpstr(str[i],"\r")==0)
				tempstr+=str[i]
				i+=1
				break
			endif
			tempstr+=str[i]
			i+=1
		while (1)
		
		j=0
		equalflag=0
		do
			if (j>=strlen(tempstr))
				break
			endif
			
			if (cmpstr(tempstr[j],"=")==0)
				equalflag=1
			endif
			
			if (equalflag)
				if ((cmpstr(tempstr[j],"\"")==0)||(cmpstr(tempstr[j],"#")==0)||(cmpstr(tempstr[i],"\t")==0))
					tempstr=tempstr[0,j-1]+tempstr[j+1,inf]
				else
					j+=1
				endif
			else
				if ((cmpstr(tempstr[j],"\"")==0)||(cmpstr(tempstr[j],"#")==0)||(cmpstr(tempstr[j]," ")==0)||(cmpstr(tempstr[i],"\t")==0))
					tempstr=tempstr[0,j-1]+tempstr[j+1,inf]
				else
					j+=1
				endif
			endif
		while (1)
		
		resultstr+=tempstr
		
	while (1)
	
	return resultstr
End

Function JoinrawData()
print "function to be developed"
//	String df=GetDatafolder(1)
//	Variable index=0
//	String Sname
//	prompt Sname,"JoinWaveName:"
//	doPrompt "Join RawData",Sname
//	if (V_flag)
// 		return 0
//	endif
//	PauseUpdate; Silent 1 
//	String Wname
//	Variable k00,k10,dk0,e00,e10,de0,sweep,k0,k1,dk,e0,e1,de
//	String noteStr
//	String Slist=MakeWlist()
//	Wname=Stringfromlist(0,Slist)
//	Wave rawData=$Wname
//	k00=M_x0(rawData)
//	k10=M_x1(rawData)
//	dk0=dimdelta(rawData,0)
//	e00=M_y0(rawData)
//	e10=M_y1(rawData)
//	de0=dimdelta(rawData,1)
//	
//	if (wavedims(rawdata)>2)
//		Variable dimnum0=dimsize(rawdata,2)
//	endif
//		
//	do 
// 		Wname=Stringfromlist(index,Slist)
// 		if (strlen(Wname)<=0)
// 			break
// 		endif
// 
// 		Wave rawData=$Wname
// 		k0=M_x0(rawData)
// 		k1=M_x1(rawData)
// 		dk=dimdelta(rawData,0)
// 		e0=M_y0(rawData)
// 		e1=M_y1(rawData)
// 		de=dimdelta(rawData,1)
// 		
// 		if (wavedims(rawdata)>2)
//			Variable dimnum=dimsize(rawdata,2)
//			if (dimnum!=dimnum0)
// 				DoAlert 1,"Not Equal Layers"
// 				return 1
// 			endif
//		endif
// 		
// 		k00=(k0>k00)?(k0):(k00)
// 		k10=(k1<k10)?(k1):(k10)
// 		dk0=(dk<dk0)?(dk):(dk0)
// 		
// 		e00=(e0>e00)?(e0):(e00)
// 		e10=(e1<e10)?(e1):(e10)
// 		de0=(de<de0)?(de):(de0)
// 		
// 		
// 		//if ((k0!=k00)||(k1!=k10)||(dk!=dk0)||(e0!=e00)||(e1!=e10)||(de!=de0))
// 		//	DoAlert 1,"Not Equal Points"
// 		//return 1
// 	
//	index+=1
//	while (1) 
//	
//
//
//	index =0
//	Wname=Stringfromlist(0,Slist)
//	Wave RawData=$Wname
//	SetDatafolder GetWavesDatafolder(RawData,1) 
//	
//	
//	Variable kn=round((k10-k00)/dk0+1)
//	Variable en=round((e10-e00)/de0+1)
//	if (wavedims(rawdata)>2)
//		make /o/n=(kn,en,dimnum)  $Sname	
//	else
//		make /o/n=(kn,en) $Sname
//	endif
//	Setscale /I x,k00,k10,$Sname
//	Setscale /I y,e00,e10,$Sname
//	//duplicate /o RawData $Sname
//	Wave joinData=$Sname
//	JoinData=0
//	Variable SumSweep=0
//	do
// 		Wname=Stringfromlist(index,Slist)
//		if (strlen(Wname)<=0)
//			break
// 		endif
// 		Wave rawData=$Wname
//		noteStr=note(rawData)
// 		sweep=numberBykey("NumberofSweeps",noteStr,"=","\r")
// 		if (wavedims(rawdata)>2)
// 			Variable layerindex=0
// 			do
// 				Duplicate /o/R=[][][layerindex] rawdata, rawdatatemp
// 				redimension  /N=(dimsize(rawdatatemp,0),dimsize(rawdatatemp,1)) rawdatatemp
// 				copyscales rawdata,rawdatatemp
// 				Variable tempvalue=interp2D(rawdatatemp,x,y)*sweep
// 				if (numtype(tempvalue)==2)
// 					joinData[][][layerindex]+=rawdatatemp[p][q]*sweep
// 				else
// 					joinData[][][layerindex]+=interp2D(rawdatatemp,x,y)*sweep
// 				endif
// 				layerindex+=1
// 			while (layerindex<dimnum)
// 			//joinData+=interp2D(rawData[r],x,y)*sweep
// 		else
// 			joinData+=interp2D(rawData,x,y)*sweep
// 		endif
// 		SumSweep+=sweep
// 		print sweep;
// 		index+=1
//	while (1)
//	joinData/=SumSweep
//	notestr=note(rawData)
//	note /K JoinData
//	notestr=replacenumberbykey("NumberofSweeps",noteStr,SumSweep,"=","\r")
//	notestr=replacestringbykey("WaveName",noteStr,Sname,"=","\r")
//	note JoinData,notestr
//	print SumSweep
//	Killwaves/ Z rawdatatemp
//	SetDatafolder $DF
return 0
End


function NLC_load(target,I_channel_I0,start_channel)
	//for loading file use
	wave target
	wave I_channel_I0
	variable start_channel
	
	make/o/n=(dimsize(I_channel_I0,1)) temp_intensity, temp_beamcurrent
	setscale/P x, dimoffset(I_channel_I0,1), dimdelta(I_channel_I0,1), temp_intensity, temp_beamcurrent
	temp_beamcurrent = x
	
	duplicate/o target, M_temp
	wave nlc_target = M_temp
	nlc_target = NaN
	variable index
	for(index=0;index<dimsize(target,0);index+=1)
		temp_intensity[] = I_channel_I0[index+start_channel-1][p]
		nlc_target[index][] = interp(target[index][q], temp_intensity, temp_beamcurrent)
	endfor
end


///////////////////////////////////////////////



function load_SES_bin_file(sympath,filename)
	string sympath
	string filename
	
	DFREF DF = getDataFolderDFR()
	
	//NewDataFolder/O/S root:process
	
	
	
	NewDataFolder /O/S root:rawData
	killdatafolder/Z Load_DA30_SES_3D_temp
	NewDataFolder/O/S Load_DA30_SES_3D_temp
	
	make /O /N=(2,2) chunkImage
	make /O /N=(2,2,2) chunkCube
	make /O /N=(3)  dimInfoWave, offsetInfoWave, deltaInfoWave
	make /O /T /N=(3) labelInfoWave
	string /G dataFileName = ""
	variable/G iBegin=0, jBegin=0, kBegin=0
	variable/G iEnd=0, jEnd=0, kEnd=0
	variable/G iTot=0, jTot=0, kTot=0
	variable/G iMax=0, jMax=0, kMax=0
	variable/G iBin=1, jBin=1, kBin=1
	variable/G iBeginVal=0, jBeginVal=0, kBeginVal=0
	variable/G iEndVal=0, jEndVal=0, kEndVal=0
	variable/G iDeltaVal=0, jDeltaVal=0, kDeltaVal=0

	string /G iLabel = ""
	string /G jLabel = ""
	string /G kLabel = ""
	
	DFREF dfr = root:rawData:Load_DA30_SES_3D_temp
	
	
	wave fDimInfoWave = dfr:dimInfoWave
	wave fOffsetInfoWave = dfr:offsetInfoWave
	wave fDeltaInfoWave = dfr:deltaInfoWave
	wave /T fLabelInfoWave = dfr:labelInfoWave
	SVAR fDataFileName = dfr:dataFileName	
	NVAR f_iBegin = dfr:iBegin
	NVAR f_jBegin= dfr:jBegin
	NVAR f_kBegin= dfr:kBegin
	NVAR f_iEnd= dfr:iEnd
	NVAR f_jEnd= dfr:jEnd
	NVAR f_kEnd= dfr:kEnd
	NVAR f_iBin= dfr:iBin
	NVAR f_jBin= dfr:jBin
	NVAR f_kBin= dfr:kBin

	SVAR f_iLabel = dfr:iLabel
	SVAR f_jLabel = dfr:jLabel
	SVAR f_kLabel = dfr:kLabel
	
	
	variable refNum
	fDataFileName = "viewer.ini"
	
	open /R /P=$symPath  refNum fDataFileName
	
	fDataFileName = loadDimAndScales(refNum, fDimInfoWave, fOffsetInfoWave, fDeltaInfoWave, fLabelInfoWave)
	
	
	// Also set the starting values for the controls to full range
	f_iBegin = 0
	f_jBegin = 0
	f_kBegin = 0
	
	f_iEnd = fDimInfoWave[0]-1
	f_jEnd = fDimInfoWave[1]-1
	f_kEnd = fDimInfoWave[2]-1
	
	DAioUpdate()
	
	f_iLabel = "i label: " + fLabelInfoWave[0]
	f_jLabel = "j label: " + fLabelInfoWave[1]
	f_kLabel = "k label: " + fLabelInfoWave[2]

	Close refNum
	
	
	string cube_name = "Spectrum_Cube.bin"
	load_SES_3Doverview(sympath,cube_name)
	
	
	
	string notestr_common=""
	
	string SES_line
	
	fDataFileName = "Cube.ini"
	
	open /R /P=$symPath  refNum fDataFileName
	
	FReadline/N=256 refnum, SES_line
	
	do
		FReadline/N=256 refnum, SES_line
		if (stringmatch(SES_line,"[Run*"))
			break
		endif
		
		notestr_common += SES_line
	while (1)
	
	Close refnum
	
	notestr_common= ReplaceString("Excitation Energy", notestr_common, "PhotonEnergy")
	notestr_common= ReplaceString("Low Energy", notestr_common, "FirstEnergy")
	notestr_common= ReplaceString("High Energy", notestr_common, "LastEnergy")
	notestr_common= ReplaceString("Detector First X-Channel", notestr_common, "CCDFirstXChannel")
	notestr_common= ReplaceString("Detector First Y-Channel", notestr_common, "CCDFirstYChannel")
	notestr_common= ReplaceString("Detector Last X-Channel", notestr_common, "CCDLastXChannel")
	notestr_common= ReplaceString("Detector Last Y-Channel", notestr_common, "CCDLastYChannel")
	notestr_common=ReplaceString("\\", notestr_common, ":")
	
	notestr_common=ReplaceString(" ", notestr_common, "")
	
	
	variable Efrom = NumberByKey("FirstEnergy", notestr_common,"=", "\r")
	variable Eto = NumberByKey("LastEnergy", notestr_common,"=", "\r")
	
	string fullname = replacestring(":",replacestring("\\",sympath,""),"")
	string cubename
	variable namelen = strlen(cubename)
	
	if(strlen(fullname)>25)
		cubename = "s"+fullname[namelen-25,namelen-1]
	else
		cubename =fullname
	endif	
	
	wave cube = $("chunkCube")
	
	variable kfrom = dimoffset(cube,1)
	variable kdelta = dimdelta(cube, 1)
	
	variable deflectorfrom = dimoffset(cube,2)
	variable deflectordelta = dimdelta(cube, 2)
	
	variable index
	
	string wavenote
	
	string cutname, dataprc_name
	
	for(index=0;index<dimsize(cube, 2);index+=1)
		cutname = "root:rawdata:"+cubename+"_"+num2str(index)
		
		duplicate/o/R=(Efrom, Eto)[0,inf][index,index] cube, $cutname
		
		wave cut = $cutname
		
		
		redimension/N=(-1,-1) cut
		matrixtranspose cut
		
		wavenote = notestr_common+"DeflectorAngle="+num2str(deflectorfrom+deflectordelta*index)+"\r"
		
		
		note/K cut, wavenote
		
		
		dataprc_name = "root:process:"+cubename+"_"+num2str(index)
		duplicate/o cut, $(dataprc_name)
		
		wave dataprc=$(dataprc_name)
		InitialprocNotestr2D(dataprc,"rawData")
		redimension /N=(dimsize(cut,0),dimsize(cut,1),1) dataprc
		
		note/K cut, wavenote
	endfor
	
	
			
	NewDataFolder /O/S root:rawData
	killdatafolder/Z Load_DA30_SES_3D_temp
	setdatafolder DF
	
	return 0
end






function load_SES_3Doverview(sympath,filename)

	string sympath
	string filename
	
	variable refNum

	DFREF dfr = root:rawData:Load_DA30_SES_3D_temp
	
	wave trgWave = dfr:chunkCube

	SVAR fDataFileName = dfr:dataFileName
	wave fDimInfoWave = dfr:dimInfoWave
	wave fDeltaInfoWave = dfr:deltaInfoWave
	wave fOffsetInfoWave = dfr:offsetInfoWave
	wave /T fLabelInfoWave = dfr:labelInfoWave
	
	NVAR f_iBegin = dfr:iBegin
	NVAR f_jBegin= dfr:jBegin
	NVAR f_kBegin= dfr:kBegin
	NVAR f_iEnd= dfr:iEnd
	NVAR f_jEnd= dfr:jEnd
	NVAR f_kEnd= dfr:kEnd
	NVAR f_iBin= dfr:iBin
	NVAR f_jBin= dfr:jBin
	NVAR f_kBin= dfr:kBin

	NVAR f_iTot= dfr:iTot
	NVAR f_jTot= dfr:jTot
	NVAR f_kTot= dfr:kTot
	
	NVAR f_iMax= dfr:iMax
	NVAR f_jMax= dfr:jMax
	NVAR f_kMax= dfr:kMax

	NVAR f_iBeginVal= dfr:iBeginVal
	NVAR f_jBeginVal= dfr:jBeginVal
	NVAR f_kBeginVal= dfr:kBeginVal
	NVAR f_iEndVal= dfr:iEndVal
	NVAR f_jEndVal= dfr:jEndVal
	NVAR f_kEndVal= dfr:kEndVal
	NVAR f_iDeltaVal= dfr:iDeltaVal
	NVAR f_jDeltaVal= dfr:jDeltaVal
	NVAR f_kDeltaVal= dfr:kDeltaVal


	variable iiCount, jjCount, kkCount
	variable ii, jj, kk
	variable iiTrg, jjTrg, kkTrg 
	
	kkCount = 0

	redimension /N=(f_iTot,f_jTot,f_kTot) trgWave
	trgWave = 0

	make /O /N=(fDimInfoWave[0], fDimInfoWave[1]) currentPlane
	
	
	fDataFileName = filename
	
	open /R /P=$symPath  refNum fDataFileName
	kkTrg = 0
	kkCount = 0
	for (kk=0;kk<fDimInfoWave[2] ;kk+=1)
		fBinRead refNum, currentPlane // load one plane
		if ( kk >= f_kBegin && kkTrg < f_kTot )  
			jjTrg = 0
			jjCount = 0
			for (jj=0;jj<fDimInfoWave[1];jj+=1)
				if (jj >= f_jBegin && jjTrg < f_jTot)
					iiTrg = 0
					iiCount = 0 
					for (ii=0;ii<fDimInfoWave[0];ii+=1) 
						if (ii >= f_iBegin && iiTrg < f_iTot)
							trgWave[iiTrg][jjTrg][kkTrg] += currentPlane[ii][jj]
							iiCount += 1
							if (iiCount >= f_iBin)
								iiCount = 0
								iiTrg +=1
							endif
						endif
					endfor
					jjCount+=1
					if (jjCount >= f_jBin)
						jjCount = 0
						jjTrg += 1
					endif
				endif
			endfor
			kkCount += 1
			if ( kkCount >=  f_kBin)
				kkCount = 0
				kkTrg += 1
			endif
		endif
	endfor

	setScale /P x, f_iBeginVal, f_iDeltaVal, fLabelInfoWave[0], trgWave
	setScale /P y, f_jBeginVal, f_jDeltaVal, fLabelInfoWave[1], trgWave
	setScale /P z, f_kBeginVal, f_kDeltaVal, fLabelInfoWave[2], trgWave
	
	close RefNum
	
	
end






#pragma rtGlobals=1		// Use modern global access method.

function buildMask()

make /O /N=(24) horizontInd
variable ii, jj, kk

horizontInd[0]=9
horizontInd[1]=horizontInd[0]+4
horizontInd[2]=horizontInd[1]+2
horizontInd[3]=horizontInd[2]+2
horizontInd[4]=horizontInd[3]+2
horizontInd[5]=horizontInd[4]+2
horizontInd[6]=horizontInd[5]+2
horizontInd[7]=horizontInd[6]
horizontInd[8]=horizontInd[7]
horizontInd[9]=horizontInd[8]+2
horizontInd[10]=horizontInd[9]
horizontInd[11]=horizontInd[10]
for (ii=0;ii<12;ii+=1)
	horizontInd[12+ii]=horizontInd[11-ii]
endfor

variable basePointDimDelta = 0.6
variable verticalDimOffset = -1*(basePointDimDelta/2+11*basePointDimDelta)
variable horizontalDimOffset
variable basePointSum = 0
for (ii=0;ii<dimSize(horizontInd,0);ii+=1)
	basePointSum  += horizontInd[ii]
endfor
print basePointSum

make /O /N=(basePointSum) maskBaseX, maskBaseY
kk = 0

for (ii=0;ii<dimSize(horizontInd,0);ii+=1)
	horizontalDimOffset = (floor(horizontInd[ii]/2))*basePointDimDelta*-1
	for (jj=0;jj<horizontInd[ii];jj+=1)
		maskBaseX[kk] = horizontalDimOffset+jj*basePointDimDelta
		maskBaseY[kk] = verticalDimOffset+ii*basePointDimDelta
		kk +=1
	endfor
endfor

variable stripeCount = 25
variable stripeMarkers = 11
variable stripeVericalDimOffset = -0.3
variable stripeDimDelta = basePointDimDelta/(stripeMarkers-1)

make /O /N=(stripeCount*stripeMarkers) maskStripesX, maskStripesY
kk =  0
horizontalDimOffset = (floor(stripeCount/2))*basePointDimDelta*-1
for (ii=0;ii<stripeCount;ii+=1)
	for (jj=0;jj<stripeMarkers;jj+=1)
		maskStripesX[kk] = horizontalDimOffset+ii*basePointDimDelta
		maskStripesY[kk] = stripeVericalDimOffset+jj*stripeDimDelta
		kk+=1
	endfor
endfor

make /O /N=(stripeMarkers) verticalLineX, verticalLineY, horizontalLineX, horizontalLineY
variable verticalLineVerticalDimOffset = 1.5
kk=0
for (ii=0;ii<stripeMarkers;ii+=1)
	verticalLineX[kk] = 0
	verticalLineY[kk] = verticalLineVerticalDimOffset+ii*stripeDimDelta
	kk+=1
endfor
variable horizontalLineVerticalDimOffset = 2.1
variable hLineHorizontalDimOffset = basePointDimDelta
kk=0
for (ii=0;ii<stripeMarkers;ii+=1)
	horizontalLineX[kk] = hLineHorizontalDimOffset+ii*stripeDimDelta
	horizontalLineY[kk] = horizontalLineVerticalDimOffset
	kk+=1
endfor

// merge
variable totSize = dimSize(maskBaseX,0) + dimSize(maskStripesX,0) + dimSize(verticalLineX,0) + dimSize(horizontalLineX,0)


make /O /N=(totSize) maskGeoX, maskGeoY
kk = 0
for (ii=0;ii<dimSize(maskBaseX,0);ii+=1)
	maskGeoX[kk] = maskBaseX[ii]
	maskGeoY[kk] = maskBaseY[ii]
	kk += 1
endfor
for (ii=0;ii<dimSize(maskStripesX,0);ii+=1)
	maskGeoX[kk] = maskStripesX[ii]
	maskGeoY[kk] = maskStripesY[ii]
	kk += 1
endfor
for (ii=0;ii<dimSize(verticalLineX,0);ii+=1)
	maskGeoX[kk] = verticalLineX[ii]
	maskGeoY[kk] = verticalLineY[ii]
	kk += 1
endfor
for (ii=0;ii<dimSize(verticalLineX,0);ii+=1)
	maskGeoX[kk] = horizontalLineX[ii]
	maskGeoY[kk] = horizontalLineY[ii]
	kk += 1
endfor

killwaves /Z horizontInd, maskBaseX, maskBaseY, maskStripesX,  maskStripesY, verticalLineX, verticalLineY, horizontalLineX, horizontalLineY

variable sourceDist = 23.05 // see drawing 17491-A
variable radius
variable phi
variable theta
variable thetaX
variable thetaY

duplicate /O maskGeoX, angleMaskX
duplicate /O maskGeoY, angleMaskY

for (ii=0;ii<totSize;ii+=1)
	radius = sqrt(maskGeoX[ii]*maskGeoX[ii]+maskGeoY[ii]*maskGeoY[ii])
	theta = atan(radius/sourceDist)
	phi = atan2(maskGeoY[ii],maskGeoX[ii])
	angleMaskX[ii] = theta*cos(phi)
	angleMaskY[ii] = theta*sin(phi)
endfor

	angleMaskX = -angleMaskX*180/pi
	angleMaskY = angleMaskY*180/pi

	//Display maskGeoY vs maskGeoX
	//ModifyGraph mode=3,marker=19

	//Display angleMaskY vs angleMaskX
	//ModifyGraph mode=3,marker=19

end








// By Patrik Karlsson, VG Scienta AB, 2013
// The function will set the DA30_WD path if the first parameter is passed as 0.
// The function will return the fileName of the binary data file.
// Information waves should have been created outside of the function:
//make /O /N=(3)  dimInfoWave, offsetInfoWave, deltaInfoWave
//make /O /T /N=(3) labelInfoWave

function /S loadDimAndScales(refNum, dimInfoWave, offsetInfoWave, deltaInfoWave, labelInfoWave)
	variable refNum
	// Pass refNum as 0 if the function should open the file dialog. The function will open and close the file internally.
	// If a file reference is given the file should have been be opened outside of the function.
	// The function will not close the file in this case.
	wave dimInfoWave, offsetInfoWave, deltaInfoWave
	wave /T labelInfoWave
	//[viewer.region_0.channel_0]
	//width=1064
	//height=1000
	//depth=101
	//name=DA30F_Ek380Ep20
	//path=DA30F_Ek380Ep20_0.bin
	//width_offset=854.140259
	//width_delta=0.001616
	//width_label=energy
	//height_offset=-23.869286
	//height_delta=0.047739
	//height_label=theta_x
	//depth_offset=-10.000000
	//depth_delta=0.200000
	//depth_label=theta_y
	
	string viewer ="viewer"
	string firstBlock = "[viewer]"
	string region_list = ""
	string current_region = ""
	
	
	string iniBlock = ""
	string current_region_name = ""
	string channel_list = ""
	string current_channel = ""
	
	string block = "" //"[viewer.region_0.channel_0]"
	string dataFileName
	string tmpString, cutString
	string textLine
	string workingDirectory = ""
	variable ii,jj
	variable closeFile = 1

	if (refNum <= 0)
		Open/D/R/T=".ini"  refNum
		textLine = S_fileName
		jj = strlen(textLine)-strlen(":viewer.ini")
		ii = 0
		do
			workingDirectory[ii] = textLine[ii]
			ii = ii+1
		while(ii<jj)
		//print workingDirectory
		
		NewPath /O DA30_WD workingDirectory;
	
		open /R /Z=1 /P=DA30_WD refNum as "viewer.ini"
		FStatus refNum
		if (!V_Flag)
			abort "File error. Could not open viewer.ini"
		endif
	else
		closeFile = 0
	endif // if (refNum <= 0)	
	
	// ******** New section, first version, one region  only.
	
	region_list = ReadConfigStringDA30(refNum, firstBlock, "region_list")
	current_region = ReadConfigStringDA30(refNum, firstBlock, "current_region")
	current_region = removeLastCharFromString(current_region)
	
	iniBlock = "[" + viewer + "." + current_region + "]"
	
	current_region_name =  ReadConfigStringDA30(refNum, iniBlock, "name")
	channel_list = ReadConfigStringDA30(refNum, iniBlock, "channel_list")
	current_channel = ReadConfigStringDA30(refNum, iniBlock, "current_channel")
	current_channel = removeLastCharFromString(current_channel)
	block = "[" + viewer +  "." +  current_region + "." + current_channel + "]"
	
	// End of new section
	
	tmpString = ReadConfigStringDA30(refNum, block, "path")
	dataFileName = ""
	jj = strlen(tmpString)-1
	for (ii=0;ii<jj;ii+=1)
		dataFileName[ii] = tmpString[ii]
	endfor
	
	
	dimInfoWave[0] = readConfigParameterDA30(refNum, block, "width")
	dimInfoWave[1] = readConfigParameterDA30(refNum, block, "height")
	dimInfoWave[2] = readConfigParameterDA30(refNum, block, "depth")
	
	offsetInfoWave[0] = readConfigParameterDA30(refNum, block, "width_offset")
	offsetInfoWave[1] = readConfigParameterDA30(refNum, block, "height_offset")
	offsetInfoWave[2] = readConfigParameterDA30(refNum, block, "depth_offset")
	
	deltaInfoWave[0] = readConfigParameterDA30(refNum, block, "width_delta")
	deltaInfoWave[1] = readConfigParameterDA30(refNum, block, "height_delta")
	deltaInfoWave[2] = readConfigParameterDA30(refNum, block, "depth_delta")
	
	tmpString = ReadConfigStringDA30(refNum, block, "width_label")
	cutString = ""
	jj = strlen(tmpString)-1
	for (ii=0;ii<jj;ii+=1)
		cutString[ii] = tmpString[ii]
	endfor
	labelInfoWave[0] = cutString
	
	tmpString = ReadConfigStringDA30(refNum, block, "height_label")
	cutString = ""
	jj = strlen(tmpString)-1
	for (ii=0;ii<jj;ii+=1)
		cutString[ii] = tmpString[ii]
	endfor
	labelInfoWave[1] = cutString
	
	tmpString = ReadConfigStringDA30(refNum, block, "depth_label")
	cutString = ""
	jj = strlen(tmpString)-1
	for (ii=0;ii<jj;ii+=1)
		cutString[ii] = tmpString[ii]
	endfor
	labelInfoWave[2] = cutString
	
	return dataFileName
	if (closeFile > 0)
		close refNum
	endif
end

// Returns the variable value. Returns NaN if the variable is not found.
// RefNum is a reference to an already opened file.
// Patrik Karlsson, VG Scienta AB, 2010
function ReadConfigParameterDA30(refNum, block, parameter)
variable refNum
string block
string parameter

variable parameterValue = NaN
string subString = ""
variable ii
variable linesRead
variable maxNumberOfLines = 1000
string textLine
variable marker = 0

FSetPos refNum, 0 // Always start from the begining of the file.

//Go to block
do
	FReadLine refNum, textLine
	linesRead = linesRead + 1
	if (stringmatch(textLine,(block+"*"))) // Example block "[general]"
		marker = 1
		// Find keyword parameter
		do
			FReadLine refNum, textLine
			linesRead = linesRead + 1
			//print textLine
			if (stringmatch(textLine,(parameter+"=*"))) // Example parameter "spectrumBeginEnergy"
				marker = marker + 1
				ii = 0
				// Read lensIterations parameter value
				do
					subString[ii] = textLine[strlen(parameter+"=")+ii]
					ii = ii + 1
				while (strlen(parameter+"=")+ii<strlen(textLine)) 
				parameterValue = str2num(subString)
			endif	
		while (marker<2 && linesRead<maxNumberOfLines) 
	endif
while (marker<1 && linesRead<maxNumberOfLines)

return parameterValue

end



// Returns the variable value. Returns empty string if the variable is not found.
// RefNum is a reference to an already opened file.
// Patrik Karlsson, VG Scienta AB, 2010
function /S ReadConfigStringDA30(refNum, block, parameter)
variable refNum
string block
string parameter

string parameterString = ""
string subString = ""
variable ii
variable linesRead
variable maxNumberOfLines = 1000
string textLine
variable marker = 0

FSetPos refNum, 0 // Always start from the begining of the file.

//Go to block
do
	FReadLine refNum, textLine
	linesRead = linesRead + 1
	if (stringmatch(textLine,(block+"*"))) // Example block "[general]"
		marker = 1
		// Find keyword parameter
		do
			FReadLine refNum, textLine
			linesRead = linesRead + 1
			//print textLine
			if (stringmatch(textLine,(parameter+"=*"))) // Example parameter "spectrumBeginEnergy"
				marker = marker + 1
				ii = 0
				// Read lensIterations parameter value
				do
					subString[ii] = textLine[strlen(parameter+"=")+ii]
					ii = ii + 1
				while (strlen(parameter+"=")+ii<strlen(textLine)) 
				parameterString = subString
			endif	
		while (marker<2 && linesRead<maxNumberOfLines) 
	endif
while (marker<1 && linesRead<maxNumberOfLines)

return parameterString

end


function /S removeLastCharFromString(inputString)

string inputString
string outputString = ""
variable ii

for (ii=0; ii<(strLen(inputString)-1); ii+=1)
	outputString[ii] = inputString[ii] 
endfor

return outputString

end







Function iBeginBoundaryCheck(ctrlName,varNum,varStr,varName) : SetVariableControl
	// General format
	String ctrlName
	Variable varNum
	String varStr
	String varName

	DFREF dfr = root:rawData:Load_DA30_SES_3D_temp
	wave fDimInfoWave = dfr:dimInfoWave
	NVAR f_iBegin = dfr:iBegin
	NVAR f_jBegin= dfr:jBegin
	NVAR f_kBegin= dfr:kBegin
	NVAR f_iEnd= dfr:iEnd
	NVAR f_jEnd= dfr:jEnd
	NVAR f_kEnd= dfr:kEnd
	NVAR f_iBin= dfr:iBin
	NVAR f_jBin= dfr:jBin
	NVAR f_kBin= dfr:kBin
			
	if (f_iBegin<0)
		f_iBegin = 0
	endif	
	f_iBegin = abs(floor(f_iBegin))	
	if ( f_iBegin > (fDimInfoWave[0]-1) )
		f_iBegin = (fDimInfoWave[0]-1)
	endif
	if (f_iend<f_iBegin)
		f_iBegin = f_iend 
	endif
	DAioUpdate()
	// function call update energy from index
End

Function jBeginBoundaryCheck(ctrlName,varNum,varStr,varName) : SetVariableControl
	// General format
	String ctrlName
	Variable varNum
	String varStr
	String varName

	DFREF dfr = root:rawData:Load_DA30_SES_3D_temp
	wave fDimInfoWave = dfr:dimInfoWave
	NVAR f_iBegin = dfr:iBegin
	NVAR f_jBegin= dfr:jBegin
	NVAR f_kBegin= dfr:kBegin
	NVAR f_iEnd= dfr:iEnd
	NVAR f_jEnd= dfr:jEnd
	NVAR f_kEnd= dfr:kEnd
	NVAR f_iBin= dfr:iBin
	NVAR f_jBin= dfr:jBin
	NVAR f_kBin= dfr:kBin
		
	if (f_jBegin<0)
		f_jBegin = 0
	endif	
	f_jBegin = abs(floor(f_jBegin))	
	if ( f_jBegin > (fDimInfoWave[1]-1) )
		f_jBegin = (fDimInfoWave[1]-1)
	endif
	if (f_jend<f_jBegin)
		f_jBegin = f_jend 
	endif
	DAioUpdate()
	// function call update energy from index
End

Function kBeginBoundaryCheck(ctrlName,varNum,varStr,varName) : SetVariableControl
	// General format
	String ctrlName
	Variable varNum
	String varStr
	String varName

	DFREF dfr = root:rawData:Load_DA30_SES_3D_temp
	wave fDimInfoWave = dfr:dimInfoWave
	NVAR f_iBegin = dfr:iBegin
	NVAR f_jBegin= dfr:jBegin
	NVAR f_kBegin= dfr:kBegin
	NVAR f_iEnd= dfr:iEnd
	NVAR f_jEnd= dfr:jEnd
	NVAR f_kEnd= dfr:kEnd
	NVAR f_iBin= dfr:iBin
	NVAR f_jBin= dfr:jBin
	NVAR f_kBin= dfr:kBin
		
	if (f_kBegin<0)
		f_kBegin = 0
	endif	
	f_kBegin = abs(floor(f_kBegin))	
	if ( f_kBegin > (fDimInfoWave[2]-1) )
		f_kBegin = (fDimInfoWave[2]-1)
	endif
	if (f_kend<f_kBegin)
		f_kBegin = f_kend 
	endif
	DAioUpdate()
	// function call update energy from index
End

Function iEndBoundaryCheck(ctrlName,varNum,varStr,varName) : SetVariableControl
	// General format
	String ctrlName
	Variable varNum
	String varStr
	String varName

	DFREF dfr = root:rawData:Load_DA30_SES_3D_temp
	wave fDimInfoWave = dfr:dimInfoWave
	NVAR f_iBegin = dfr:iBegin
	NVAR f_jBegin= dfr:jBegin
	NVAR f_kBegin= dfr:kBegin
	NVAR f_iEnd= dfr:iEnd
	NVAR f_jEnd= dfr:jEnd
	NVAR f_kEnd= dfr:kEnd
	NVAR f_iBin= dfr:iBin
	NVAR f_jBin= dfr:jBin
	NVAR f_kBin= dfr:kBin
	
	f_iend = abs(floor(f_iEnd))
	
	if ( f_iend > (fDimInfoWave[0]-1) )
		f_iend = (fDimInfoWave[0]-1)
	elseif (f_iend<f_iBegin)
		f_iend = f_iBegin
	endif
	DAioUpdate()
	// function call update energy from index
End

Function jEndBoundaryCheck(ctrlName,varNum,varStr,varName) : SetVariableControl
	// General format
	String ctrlName
	Variable varNum
	String varStr
	String varName

	DFREF dfr = root:rawData:Load_DA30_SES_3D_temp
	wave fDimInfoWave = dfr:dimInfoWave
	NVAR f_iBegin = dfr:iBegin
	NVAR f_jBegin= dfr:jBegin
	NVAR f_kBegin= dfr:kBegin
	NVAR f_iEnd= dfr:iEnd
	NVAR f_jEnd= dfr:jEnd
	NVAR f_kEnd= dfr:kEnd
	NVAR f_iBin= dfr:iBin
	NVAR f_jBin= dfr:jBin
	NVAR f_kBin= dfr:kBin
	
	f_jend = abs(floor(f_jEnd))
	
	if ( f_jend > (fDimInfoWave[1]-1) )
		f_jend = (fDimInfoWave[1]-1)
	elseif (f_jend<f_jBegin)
		f_jend = f_jBegin
	endif
	DAioUpdate()
	// function call update energy from index
End



Function kEndBoundaryCheck(ctrlName,varNum,varStr,varName) : SetVariableControl
	// General format
	String ctrlName
	Variable varNum
	String varStr
	String varName

	DFREF dfr = root:rawData:Load_DA30_SES_3D_temp
	wave fDimInfoWave = dfr:dimInfoWave
	NVAR f_iBegin = dfr:iBegin
	NVAR f_jBegin= dfr:jBegin
	NVAR f_kBegin= dfr:kBegin
	NVAR f_iEnd= dfr:iEnd
	NVAR f_jEnd= dfr:jEnd
	NVAR f_kEnd= dfr:kEnd
	NVAR f_iBin= dfr:iBin
	NVAR f_jBin= dfr:jBin
	NVAR f_kBin= dfr:kBin
	
	f_kend = abs(floor(f_kEnd))
	
	if ( f_kend > (fDimInfoWave[2]-1) )
		f_kend = (fDimInfoWave[2]-1)
	elseif (f_kend<f_kBegin)
		f_kend = f_kBegin
	endif
	DAioUpdate()
	// function call update energy from index
End


///////////////////////////////////////////////////////////////////////////////////////////////////


Function iBinBoundaryCheck(ctrlName,varNum,varStr,varName) : SetVariableControl
	// General format
	String ctrlName
	Variable varNum
	String varStr
	String varName

	DFREF dfr = root:rawData:Load_DA30_SES_3D_temp
	wave fDimInfoWave = dfr:dimInfoWave
	NVAR f_iBegin = dfr:iBegin
	NVAR f_jBegin= dfr:jBegin
	NVAR f_kBegin= dfr:kBegin
	NVAR f_iEnd= dfr:iEnd
	NVAR f_jEnd= dfr:jEnd
	NVAR f_kEnd= dfr:kEnd
	NVAR f_iBin= dfr:iBin
	NVAR f_jBin= dfr:jBin
	NVAR f_kBin= dfr:kBin
	
	f_iBin = floor(f_iBin)
	
	if ( f_iBin < 1 )
		f_iBin = 1
	elseif (f_iBin > ( f_iEnd - f_iBegin ) )
		f_iBin = f_iEnd - f_iBegin + 1
	endif
	DAioUpdate()
	// function call update energy from index
End

Function jBinBoundaryCheck(ctrlName,varNum,varStr,varName) : SetVariableControl
	// General format
	String ctrlName
	Variable varNum
	String varStr
	String varName

	DFREF dfr = root:rawData:Load_DA30_SES_3D_temp
	wave fDimInfoWave = dfr:dimInfoWave
	NVAR f_iBegin = dfr:iBegin
	NVAR f_jBegin= dfr:jBegin
	NVAR f_kBegin= dfr:kBegin
	NVAR f_iEnd= dfr:iEnd
	NVAR f_jEnd= dfr:jEnd
	NVAR f_kEnd= dfr:kEnd
	NVAR f_iBin= dfr:iBin
	NVAR f_jBin= dfr:jBin
	NVAR f_kBin= dfr:kBin
	
	f_jBin = floor(f_jBin)
	
	if ( f_jBin < 1 )
		f_jBin = 1
	elseif (f_jBin > ( f_jEnd - f_jBegin ) )
		f_jBin = f_jEnd - f_jBegin + 1
	endif
	DAioUpdate()
	// function call update energy from index
End



Function kBinBoundaryCheck(ctrlName,varNum,varStr,varName) : SetVariableControl
	// General format
	String ctrlName
	Variable varNum
	String varStr
	String varName

	DFREF dfr = root:rawData:Load_DA30_SES_3D_temp
	wave fDimInfoWave = dfr:dimInfoWave
	NVAR f_iBegin = dfr:iBegin
	NVAR f_jBegin= dfr:jBegin
	NVAR f_kBegin= dfr:kBegin
	NVAR f_iEnd= dfr:iEnd
	NVAR f_jEnd= dfr:jEnd
	NVAR f_kEnd= dfr:kEnd
	NVAR f_iBin= dfr:iBin
	NVAR f_jBin= dfr:jBin
	NVAR f_kBin= dfr:kBin
	
	f_kBin = floor(f_kBin)
	
	if ( f_kBin < 1 )
		f_kBin = 1
	elseif (f_kBin > ( f_kEnd - f_kBegin ) )
		f_kBin = f_kEnd - f_kBegin + 1
	endif
	DAioUpdate()
	// function call update energy from index
End


Function DAioUpdate()

	DFREF dfr = root:rawData:Load_DA30_SES_3D_temp
	wave fDimInfoWave = dfr:dimInfoWave
	wave fDeltaInfoWave = dfr:deltaInfoWave
	wave fOffsetInfoWave = dfr:offsetInfoWave
	wave /T fLabelInfoWave = dfr:labelInfoWave
	
	NVAR f_iBegin = dfr:iBegin
	NVAR f_jBegin= dfr:jBegin
	NVAR f_kBegin= dfr:kBegin
	NVAR f_iEnd= dfr:iEnd
	NVAR f_jEnd= dfr:jEnd
	NVAR f_kEnd= dfr:kEnd
	NVAR f_iBin= dfr:iBin
	NVAR f_jBin= dfr:jBin
	NVAR f_kBin= dfr:kBin

	NVAR f_iTot= dfr:iTot
	NVAR f_jTot= dfr:jTot
	NVAR f_kTot= dfr:kTot
	
	NVAR f_iMax= dfr:iMax
	NVAR f_jMax= dfr:jMax
	NVAR f_kMax= dfr:kMax

	NVAR f_iBeginVal= dfr:iBeginVal
	NVAR f_jBeginVal= dfr:jBeginVal
	NVAR f_kBeginVal= dfr:kBeginVal
	NVAR f_iEndVal= dfr:iEndVal
	NVAR f_jEndVal= dfr:jEndVal
	NVAR f_kEndVal= dfr:kEndVal
	NVAR f_iDeltaVal= dfr:iDeltaVal
	NVAR f_jDeltaVal= dfr:jDeltaVal
	NVAR f_kDeltaVal= dfr:kDeltaVal

	if (f_iBin > ( f_iEnd - f_iBegin ) )
		f_iBin = f_iEnd - f_iBegin + 1
	endif
	if (f_jBin > ( f_jEnd - f_jBegin ) )
		f_jBin = f_jEnd - f_jBegin + 1
	endif
      if (f_kBin > ( f_kEnd - f_kBegin ) )
		f_kBin = f_kEnd - f_kBegin + 1
	endif

	f_iTot = (trunc( (f_iEnd-f_iBegin+1)/f_iBin))
	f_jTot = (trunc( (f_jEnd-f_jBegin+1)/f_jBin))
	f_kTot = (trunc( (f_kEnd-f_kBegin+1)/f_kBin))

	f_iBeginVal = (f_iBegin + (f_iBin-1)/2 ) * fDeltaInfoWave[0] + fOffsetInfoWave[0]
	f_jBeginVal = (f_jBegin + (f_jBin-1)/2 ) * fDeltaInfoWave[1] + fOffsetInfoWave[1]
	f_kBeginVal = (f_kBegin + (f_kBin-1)/2 ) * fDeltaInfoWave[2] + fOffsetInfoWave[2]
	
	f_iDeltaVal = fDeltaInfoWave[0]*f_iBin
	f_jDeltaVal = fDeltaInfoWave[1]*f_jBin
	f_kDeltaVal = fDeltaInfoWave[2]*f_kBin

	f_iEndVal = f_iBeginVal + (f_iTot-1)*f_iDeltaVal
	f_jEndVal = f_jBeginVal + (f_jTot-1)*f_jDeltaVal
	f_kEndVal = f_kBeginVal + (f_kTot-1)*f_kDeltaVal

	
end




