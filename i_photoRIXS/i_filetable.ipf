#pragma rtGlobals=1		// Use modern global access method.#pragma version = 3.00#pragma ModuleName = filetable#pragma IgorVersion = 5.0////////////////////////////////////////// Public functions////////////////////////////////////////Function filetable_open(wlist)	String wlist		if (!DataFolderExists("root:internalUse:filetable"))		init()	endif	String DF = GetDataFolder (1)	SetDataFolder root:internalUse:filetable	WAVE/T w_dialog_waves	WAVE/I w_dialog_selectedwaves	WAVE/T w_dialog_keys	WAVE/I w_dialog_selectedkeys	if (strlen(wlist) > 0)		Make/O/T/N=(ItemsInList(wlist)) w_dialog_waves		Make/O/I/N=(ItemsInList(wlist)) w_dialog_selectedwaves		Variable i = 0		for (i = 0; i < DimSize(w_dialog_waves,0); i+= 1)			w_dialog_waves[i] = StringFromList(i, wlist)		endfor	endif	NVAR gv_dialog_showhidden	NVAR gv_dialog_showreadonly	PauseUpdate; Silent 1		// building window...	DoWindow/K filetable_panel	DoWindow/K filetable_table	NewPanel /K=1 /W=(0,0,400,440)	DoWindow/C filetable_panel	utils_autoPosWindow("filetable_panel", win=127)	TabControl ftable,proc=filetable#tabControlChange,pos={10,10},size={380,420},tabLabel(0)="Selection",value=0//,labelBack=(r,g,b)	Button newWave_tab0,	pos={30,40},		size={120,18},title="new browser selection", proc=filetable#buttonWaveSel	Button addWave_tab0,	pos={30,65},		size={120,18},title="add browser selection", proc=filetable#buttonWaveSel	Button delWave_tab0,		pos={30,90},		size={120,18},title="remove selected", proc=filetable#buttonWaveSel	Listbox wavelist_tab0,		pos={160,40},	size={220,360}, listwave=w_dialog_waves,selwave=w_dialog_selectedwaves,frame=2,editstyle=0,mode=4,widths={300}	TabControl ftable, tabLabel(1)="Filetable"	Groupbox gb1_tab1,			pos={20,30},	size={360,340}, title="select fields to edit (multiple selections possible)"	CheckBox showHidden_tab1,	pos={30,55},	size={120,18},title="show hidden", proc=filetable#checkBoxKeySel, variable=gv_dialog_showhidden	CheckBox showReadOnly_tab1,pos={30,80},size={120,18},title="show read only", proc=filetable#checkBoxKeySel, variable=gv_dialog_showreadonly	Button go_tab1, 				pos={30,105},size={120,20}, title="Open filetable", proc=filetable#buttonOpenFromDlg	Listbox keylist_tab1,			pos={160,55},size={210,300}, listwave=w_dialog_keys,selwave=w_dialog_selectedkeys,frame=2,editstyle=0,mode=4	checkBoxKeySel("",0)		TabControl ftable, tabLabel(2)="Defaults"	NVAR gv_default_gamma	NVAR gv_default_workfunction	SVAR gv_default_maniptype	NVAR gv_default_fermilevel	NVAR gv_default_photonenergy	NVAR gv_default_signConventions//	NVAR gv_default_crystalaxisa//	NVAR gv_default_crystalaxisb	GroupBox    gb0_tab2,	pos={20,40}, size={360,250}, title="Experimental Setup:"	SetVariable  sv0_tab2,	pos={30,60},size={250,20},title="ScientaOrientation(gamma)", value= gv_default_gamma	SetVariable  sv1_tab2,	pos={30,80},size={250,20},title="WorkFunction", value= gv_default_workfunction	SetVariable  sv2_tab2,	pos={30,100},size={250,20},title="ManipulatorType", value= gv_default_maniptype	SetVariable  sv3_tab2,	pos={30,120},size={250,20},title="AngleSignConventions", value= gv_default_signConventions	TitleBox tb0_tab2,		pos={30,150}, size={250,20}, title="Predefined Settings:"	Button ssrl_tab2,			pos={30,170},size={90,18},proc=filetable#buttonAnaDefaults,title="SSRL"	Button als_tab2,			pos={130,170},size={90,18},proc=filetable#buttonAnaDefaults,title="ALS"	Button basement_tab2,	pos={230,170},size={90,18},proc=filetable#buttonAnaDefaults,title="Basement"	SetVariable  sv4_tab2, 	pos={30,200},size={250,20},title="FermiLevel(EF)", value= gv_default_fermilevel	SetVariable  sv5_tab2, 	pos={30,220},size={250,20},title="PhotonEnergy(hn)", value= gv_default_photonenergy//	SetVariable  sv6_tab2, 	pos={30,220},size={250,20},title="CrystalAxisA", value= gv_default_crystalaxisa//	SetVariable  sv7_tab2, 	pos={30,240},size={250,20},title="CrystalAxisB", value= gv_default_crystalaxisb	Button b0_tab2,			pos={30,260},size={250,20},proc=filetable#buttonApplySetup,title="Apply to selected waves"		NVAR gv_default_thetaoff	NVAR gv_default_phioff	NVAR gv_default_omoff	GroupBox    gb1_tab2,	pos={20,300}, size={360,110}, title="Angle offsets:"	SetVariable  sv7_tab2,	pos={30,320},size={250,20},title="OffsetThetaManipulator", value= gv_default_thetaoff	SetVariable  sv8_tab2,	pos={30,340},size={250,20},title="OffsetPhiManipulator", value= gv_default_phioff	SetVariable  sv9_tab2,	pos={30,360},size={250,20},title="OffsetOmegaManipulator", value= gv_default_omoff	Button go_tab2, 			pos={30,380},size={250,20}, title="Apply to selected waves", proc=filetable#buttonApplyOffsets//	TODO: move this to BZ mapper: SetVariable  sv2_tab2, pos={20,80},size={150,20},title="Detection Angle", value= gv_ana_det_angle, variable = gv_ana_det_angle\//	TODO: BZ-mapper: put in angle mode//	SetVariable  sv1_tab2, pos={180,40},size={150,20},title="Beta", value= gv_ana_beta, variable = gv_ana_beta//	TODO: put this back in BZ-mapper: SetVariable  exp_sv2, pos={20,260},size={150,20},title="crystal azimuth", value= gv_crystal_azimuth, variable = gv_crystal_azimuth	tabControlChange( "filetable_panel", 0 )	SetDataFolder $DFEnd////////////////////////////////////////// Private Control Callbacks////////////////////////////////////////Static Function buttonApplyOffsets(ctrlName) : ButtonControl	String ctrlName	String DF = GetDataFolder (1)	SetDataFolder root:internalUse:filetable	NVAR gv_default_thetaoff	NVAR gv_default_phioff	NVAR gv_default_omoff	WAVE/T w_dialog_waves		SVAR gs_datafolder		Variable i	for (i = 0; i < DimSize(w_dialog_waves,0); i += 1) // for each row (wave) in table		String wname = w_dialog_waves[i]		SetDataFolder $gs_datafolder		String notestr = note($wname)		Note/K $wname		SetDataFolder root:internalUse:filetable			notestr = ReplaceNumberByKey("OffsetThetaManipulator", notestr, gv_default_thetaoff,"=","\r")		notestr = ReplaceNumberByKey("OffsetPhiManipulator", notestr, gv_default_phioff,"=","\r")		notestr = ReplaceNumberByKey("OffsetOmegaManipulator", notestr, gv_default_omoff,"=","\r")		SetDataFolder $gs_datafolder		Note $wname, notestr		SetDataFolder root:internalUse:filetable	endfor		SetDataFolder $DFEndStatic Function buttonApplySetup(ctrlName) : ButtonControl	String ctrlName	String DF = GetDataFolder (1)	SetDataFolder root:internalUse:filetable	NVAR gv_default_gamma	NVAR gv_default_workfunction	SVAR gv_default_maniptype	NVAR gv_default_fermilevel	NVAR gv_default_photonenergy	NVAR gv_default_signConventions//	NVAR gv_default_crystalaxisa//	NVAR gv_default_crystalaxisb		WAVE/T w_dialog_waves		SVAR gs_datafolder		Variable i	for (i = 0; i < DimSize(w_dialog_waves,0); i += 1) // for each row (wave) in table		String wname = w_dialog_waves[i]		SetDataFolder $gs_datafolder		String notestr = note($wname)		Note/K $wname		SetDataFolder root:internalUse:filetable			notestr = ReplaceNumberByKey("ScientaOrientation", notestr, gv_default_gamma,"=","\r")		notestr = ReplaceNumberByKey("AngleSignConventions", notestr, gv_default_signConventions,"=","\r")		notestr = ReplaceNumberByKey("WorkFunction", notestr, gv_default_workfunction,"=","\r")		notestr = ReplaceStringByKey("ManipulatorType", notestr, gv_default_maniptype,"=","\r")		notestr = ReplaceNumberByKey("FermiLevel", notestr, gv_default_fermilevel,"=","\r")		notestr = ReplaceNumberByKey("PhotonEnergy", notestr, gv_default_photonenergy,"=","\r")//		notestr = ReplaceNumberByKey("CrystalAxisA", notestr, gv_default_crystalaxisa,"=","\r")//		notestr = ReplaceNumberByKey("CrystalAxisB", notestr, gv_default_crystalaxisb,"=","\r")		SetDataFolder $gs_datafolder		Note $wname, notestr		SetDataFolder root:internalUse:filetable		endfor		SetDataFolder $DFEndStatic Function buttonAnaDefaults(ctrlName) : ButtonControl	String ctrlName	String DF = GetDataFolder (1)	SetDataFolder root:internalUse:filetable	NVAR gv_default_gamma	NVAR gv_default_workfunction	NVAR gv_default_signConventions	SVAR gv_default_maniptype		String experiment	strswitch(ctrlName)		case "ssrl_tab2":			experiment = "SSRL"			break		case "als_tab2":			experiment = "ALS"			break		case "basement_tab2":			experiment = "Basement"			break	endswitch	gv_default_gamma = globals_getGamma(experiment)	gv_default_workfunction = globals_getWorkFn(experiment)	gv_default_maniptype = globals_getManipType(experiment)	gv_default_signConventions = globals_getSigns(experiment)	SetDataFolder $DFEndStatic Function tabControlChange( name, tab )	String name	Variable tab		String allControls = ControlNameList( "filetable_panel" )	String thisControl = StringFromList(0,allControls)	Variable i = 0	for (; strlen(thisControl)>0; )		if ( stringmatch(thisControl, "*_tab*"))			if ( stringmatch(thisControl, "*_tab" + num2str(tab)) )				utils_setControlEnabled( thisControl, 0 )			else				utils_setControlEnabled( thisControl, 1)			endif		endif		i+=1		thisControl = StringFromList(i,allControls)	endforEndStatic Function buttonOpenFromDlg(ctrlName) : ButtonControl	String ctrlName	String DF = GetDataFolder (1)	SetDataFolder root:internalUse:filetable	WAVE/T w_dialog_waves	WAVE/T w_dialog_keys	WAVE/I w_dialog_selectedkeys	String waves = ""	String keys = ""	Variable i		if (numpnts(w_dialog_selectedkeys) == 0 || numpnts(w_dialog_waves) == 0 )		Abort "Please select at least one wave and one element to edit."	endif		for (i = 0; i < numpnts(w_dialog_selectedkeys); i += 1)		if (w_dialog_selectedkeys[i] & 1 == 1) // item is selected			keys += w_dialog_keys[i] + ";"		endif	endfor		SVAR gs_keylist	SVAR gs_datafolder	DoWindow/K filetable_table	edit/k=1 as "filetable_table"	DoWindow/C filetable_table	SetWindow filetable_table, hookEvents=1, hook = filetable#tableSelectionHook	// live write-back in note//	execute "ModifyTable width(Point)=25,width(c_names)=70"	// check if the supplied keys to be edited are actually existent. If yes,	// create waves with the corresponding name (see gs_keylist), and add the	// columns to the table:	AppendToTable/W=$"filetable_table" w_dialog_waves		for (i = 0; i < ItemsInList(keys); i+=1)		String key = StringFromList(i,keys)		String opts = StringByKey(key,gs_keylist,"=","\r")		if (strlen(opts) == 0)			Abort "in i_filetable.ipf, in Function filetable_open(): did not find key " + key + " in global keylist root:internalUse:filetable:keylist"		endif		String colname = StringFromList(0,opts,":")		print colname		String coltype = StringFromList(0,StringFromList(1,opts,":"),";") // get the variable type 		if (stringmatch(coltype,"int"))			Make/O/I/N=(DimSize(w_dialog_waves,0)) $colname		elseif (stringmatch(coltype,"float"))			Make/O/N=(DimSize(w_dialog_waves,0)) $colname		else //(stringmatch(coltype,"string"))			Make/O/T/N=(DimSize(w_dialog_waves,0)) $colname		endif					AppendToTable/W=$"filetable_table" $colname	endfor	execute "ModifyTable size=8"	execute "ModifyTable width=35"	execute "ModifyTable width(w_dialog_waves)=150"	// need to fill in values into the waves which are connected to the columns in the table:	for ( i = 0; i < DimSize(w_dialog_waves, 0); i+=1 ) // for each row (wave) in table		String wname = w_dialog_waves[i]		SetDataFolder $gs_datafolder		String notestr = note($wname)		SetDataFolder root:internalUse:filetable		Variable j = 0		for (j = 0; j < ItemsInList(keys); j+=1) // for each column (key) in table			key = StringFromList(j,keys) // get the entry for the j-th column out of gs_keys			opts = StringByKey(key,gs_keylist,"=","\r") // get the associated options for key (see gs_)			colname = StringFromList(0,opts,":")			coltype = StringFromList(0,StringFromList(1,opts,":"),";") // get the variable type 			if (stringmatch(coltype,"int"))				WAVE/I w0 = $colname				w0[i] = round(NumberByKey(key,notestr,"=","\r"))			elseif (stringmatch(coltype,"float"))				WAVE w1 = $colname				w1[i] = NumberByKey(key,notestr,"=","\r")			elseif (stringmatch(coltype,"string"))				WAVE/T w2 = $colname				w2[i] = StringByKey(key,notestr,"=","\r")			endif		endfor	endfor	DoWindow/K filetable_panel	SetDataFolder $DFEndStatic Function buttonWaveSel(ctrlName) : ButtonControl	String ctrlName	String DF = GetDataFolder (1)	SetDataFolder root:internalUse:filetable	WAVE/T w_dialog_waves	WAVE/I w_dialog_selectedwaves	Variable i, j, k, size = numpnts(w_dialog_waves)	String browserCmd = "CreateBrowser prompt=\"select source data to add, and click 'ok'\", showWaves=1, showVars=0, showStrs=0"	strswitch(ctrlName)		case "delWave_tab0":			j = 0			for (i = 0; i < size; i += 1)				print w_dialog_selectedwaves[i]				if (! w_dialog_selectedwaves[i] & 1) // item is NOT selected, need to count it					j += 1				endif			endfor			print j			Duplicate/O/T w_dialog_waves, w_tmp			Redimension/N=(j) w_dialog_waves // allocate space for the remaining (unselected) entries			j = 0			for (i = 0; i < numpnts(w_dialog_selectedwaves); i += 1)				if (! w_dialog_selectedwaves[i] & 1) // item is NOT selected, needs to be copied					w_dialog_waves[j] = w_tmp[i]					j += 1				endif			endfor			Redimension/N=(j) w_dialog_selectedwaves			KillWaves w_tmp			break		case "newWave_tab0":			size = 0		case "addWave_tab0":			SetDataFolder $DF			execute browserCmd			SVAR S_BrowserList=S_BrowserList			NVAR V_Flag=V_Flag			if(V_Flag==0)				return 0			endif			SetDataFolder root:internalUse:filetable			Duplicate/O/T w_dialog_waves, w_tmp			Redimension/N=(size + ItemsInList(S_BrowserList)) w_dialog_waves			Redimension/N=(size + ItemsInList(S_BrowserList)) w_dialog_selectedwaves			k = size			for (i = 0; i < ItemsInList(S_BrowserList); i += 1)				String dlgwaves = utils_wave2StringList(w_dialog_waves)				// check to avoid duplicate items in the wave selection:				if (WhichListItem(StringFromList(i,S_BrowserList), dlgwaves) != -1)					continue				endif				// We only want 2D waves here:				if (WaveDims($StringFromList(i,S_BrowserList)) != 2)					continue				endif				w_dialog_waves[k] = StringFromList(i,S_BrowserList)				k += 1			endfor			Redimension/N=(k) w_dialog_waves			Redimension/N=(k) w_dialog_selectedwaves			break		default:			Abort "buttonWaveSel(): ctrlName \""+ctrlName+"\" not recognized."	endswitch	SetDataFolder $DFEndStatic Function checkBoxKeySel(ctrlName, checked) : CheckBoxControl	String ctrlName	Variable checked	String DF = GetDataFolder (1)	SetDataFolder root:internalUse:filetable	WAVE/T w_dialog_keys	WAVE/I w_dialog_selectedkeys	SVAR gs_keylist	NVAR gv_dialog_showhidden	NVAR gv_dialog_showreadonly	Redimension/N=0 w_dialog_keys	Redimension/N=0 w_dialog_selectedkeys	Variable i	for (i = 0; i < ItemsInList(gs_keylist,"\r"); i+=1)		String key = StringFromList(i,gs_keylist,"\r")		String keyname = StringFromList(0,key,"=")		String keyopts = StringFromList(1,key,"=")		String flags = StringFromList(1,keyopts,":") // get the variable type 		Variable size = numpnts(w_dialog_selectedkeys)		if ((stringmatch(flags, "*hidden*") && ! gv_dialog_showhidden) || (stringmatch(flags, "*readonly*") && ! gv_dialog_showreadonly))			continue		endif		Redimension/N=(size+1) w_dialog_selectedkeys		Redimension/N=(size+1) w_dialog_keys		w_dialog_keys[size+1] = keyname	endfor	SetDataFolder $DFEnd////////////////////////////////////////// Private Functions////////////////////////////////////////// Please see also the stuff in i_LoadFile.ipfStatic Function init()	String dataFolder = GetDataFolder(1)	NewDataFolder/o/s root:internalUse:filetable	String/G gs_keylist = ""	gs_keylist += "WaveName=Name:string\r"	gs_keylist += "RawDataWave=RawDataWave:string;readonly;hidden\r"	gs_keylist += "FileName=FileName:string;readonly;hidden\r"	gs_keylist += "Sample=Sample:string;readonly;hidden\r"	gs_keylist += "Comments=Comments:string;readonly;hidden\r"	gs_keylist += "StartDate=StartDate:string;readonly;hidden\r"	gs_keylist += "StartTime=StartTime:string;readonly;hidden\r"	gs_keylist += "Instrument=Instrument:string;readonly;hidden\r"	gs_keylist += "MeasurementSoftware=MeasurementSoftware:string;readonly;hidden\r"	gs_keylist += "User=User:string;readonly;hidden\r"		gs_keylist += "ManipulatorType=ManipulatorType:string;hidden\r"	gs_keylist += "AnalyzerType=AnalyzerType:string;readonly;hidden\r"	gs_keylist += "AnalyzerMode=AnalyzerMode:string;readonly;hidden\r"	gs_keylist += "XScanType=XScanType:string;readonly;hidden\r"		gs_keylist+="FirstEnergy=FirstEnergy:float;readonly;hidden\r"	gs_keylist+="LastEnergy=LastEnergy:float;readonly;hidden\r"	gs_keylist+="NumberOfEnergies=NumberOfEnergies:int;readonly;hidden\r"	gs_keylist+="InitialThetaManipulator=theta_i:float\r"	gs_keylist+="FinalThetaManipulator=theta_f:float;hidden\r"	gs_keylist+="OffsetThetaManipulator=theta_off:float\r"	gs_keylist+="InitialPhiManipulator=phi_i:float\r"	gs_keylist+="FinalPhiManipulator=phi_f:float;hidden\r"	gs_keylist+="InitialAlphaAnalyzer=alpha_i:float\r"	gs_keylist+="FinalAlphaAnalyzer=alpha_f:float;hidden\r"	gs_keylist+="OffsetPhiManipulator=phi_off:float\r"	gs_keylist+="InitialOmegaManipulator=om_i:float\r"	gs_keylist+="FinalOmegaManipulator=om_f:float;hidden\r"	gs_keylist+="OffsetOmegaManipulator=om_off:float\r"	gs_keylist+="NumberOfManipulatorAngles=NumberOfManipulatorAngles:int;readonly;hidden\r"	gs_keylist+="AngleSignConventions=AngleSignConventions:int\r"		gs_keylist+="PhotonEnergy=hn:float\r"	gs_keylist+="EnergyScale=EScale:string;hidden\r"	gs_keylist+="FermiLevel=Ef:float\r"	gs_keylist+="SampleTemperature=Temp:float;hidden\r"	gs_keylist+="WorkFunction=WorkFn:float\r"	gs_keylist+="PassEnergy=Epass:float;hidden\r"	gs_keylist+="DwellTime=DwellTime:float;readonly;hidden\r"	gs_keylist+="NumberOfSweeps=NumberOfSweeps:int;readonly;hidden\r"//	gs_keylist+="CrystalAxisA=a:float\r"//	gs_keylist+="CrystalAxisB=b:float\r"	gs_keylist+="RegionName=RegionName:string;readonly;hidden\r"	gs_keylist+="AnalyzerSlit=AnalyzerSlit:string;readonly;hidden\r"	gs_keylist+="ScientaOrientation=ScientaOrientation:float;hidden\r"	gs_keylist+="CCDFirstXChannel=CCDFirstXChannel:int;readonly;hidden\r"	gs_keylist+="CCDLastXChannel=CCDLastXChannel:int;readonly;hidden\r"	gs_keylist+="CCDFirstYChannel=CCDFirstYChannel:int;readonly;hidden\r"	gs_keylist+="CCDLastYChannel=CCDLastYChannel:int;readonly;hidden\r"	gs_keylist+="NumberOfSlices=NumberOfSlices:int;readonly;hidden\r"	gs_keylist+="CCDXChannelZero=CCDXChannelZero:float;readonly;hidden\r"	gs_keylist+="CCDDegreePerChannel=CCDDegreePerChannel:float;readonly;hidden\r"	String/G gs_datafolder = ""	Variable/G gv_dialog_showhidden = 0	Variable/G gv_dialog_showreadonly = 0	Make/O/T/N=0 w_dialog_waves	Make/O/I/N=0 w_dialog_selectedwaves	Make/O/T/N=0 w_dialog_keys	Make/O/I/N=0 w_dialog_selectedkeys		Variable/G gv_default_gamma = 0	Variable/G gv_default_signConventions = 0	Variable/G gv_default_workfunction = 4.35	String/G gv_default_maniptype = "flip"	Variable/G gv_default_fermilevel = 16.696	Variable/G gv_default_photonenergy = 21.218//	Variable/G gv_default_crystalaxisa = 3.95//	Variable/G gv_default_crystalaxisb = 3.95	Variable/G gv_default_thetaoff = 0	Variable/G gv_default_phioff = 0	Variable/G gv_default_omoff = 0		SetDataFolder(dataFolder)EndStatic Function tableSelectionHook (infoStr)	String infoStr	String event= StringByKey("EVENT",infoStr)	if (cmpstr(event,"mouseup")==0)		Variable xpix= NumberByKey("MOUSEX",infoStr)		Variable ypix= NumberByKey("MOUSEY",infoStr)		print "filetable_table MenuOpen\r"		tableSelectionPopupMenu(xpix,ypix)		print "filetable_table MenuOpen done\r"		return 1	endif	print "filetable_table Clicked: Writeback\r"	String DF = GetDataFolder (1)	SetDataFolder root:internalUse:filetable	SVAR gs_datafolder	WAVE/T w_dialog_waves	WAVE/T w_dialog_keys	WAVE/I w_dialog_selectedkeys	SVAR gs_keylist		String keys = ""	Variable i	for (i = 0; i < numpnts(w_dialog_selectedkeys); i += 1)		if (w_dialog_selectedkeys[i] & 1 == 1) // item is selected			keys += w_dialog_keys[i] + ";"		endif	endfor	for ( i = 0; i < DimSize(w_dialog_waves, 0); i+=1 ) // for each row (wave) in table		String wname = w_dialog_waves[i]		SetDataFolder $gs_datafolder		String notestr = note($wname)		Note/K $wname		SetDataFolder root:internalUse:filetable			Variable j = 0		for (j = 0; j < ItemsInList(keys); j+=1) // for each column (key) in table			String key = StringFromList(j,keys) // get the entry for the j-th column out of gs_keys			String opts = StringByKey(key,gs_keylist,"=","\r") // get the associated options for key (see gs_)			String colname = StringFromList(0,opts,":")			String coltype = StringFromList(0,StringFromList(1,opts,":"),";") // get the variable type 			if (stringmatch(coltype,"int"))				WAVE w0 = $colname				notestr = ReplaceNumberByKey(key, notestr, round(w0[i]),"=","\r")			elseif (stringmatch(coltype,"float"))				WAVE w1 = $colname				notestr = ReplaceNumberByKey(key, notestr, w1[i],"=","\r")			elseif (stringmatch(coltype,"string"))				WAVE/T w2 = $colname				notestr = ReplaceStringByKey(key, notestr, w2[i],"=","\r")			endif		endfor		SetDataFolder $gs_datafolder		Note $wname, notestr		SetDataFolder root:internalUse:filetable		endfor		SetDataFolder $DF	if (stringmatch(event,"kill"))		DoWindow/K filetable_table//		KillDataFolder root:internalUse:filetable		return 2	endif	return 1				// 0 if nothing done, else 1 or 2End//------------------------------------------------------------------------------------------------//// Popup menu for table selection////Static Function tableSelectionPopupMenu(xpix,ypix)	Variable xpix	Variable ypix		String info = TableInfo("filetable_table", -2)	String selection = StringByKey("SELECTION",info,":",";")	Variable fromRow,toRow,fromCol,toCol		sscanf selection, "%d,%d,%d,%d", fromRow, fromCol, toRow, toCol	if ( (fromCol != toCol) || (fromRow == toRow && fromCol == toCol) )		return 1	endif	NewPanel/W=((xpix),(ypix),(xpix+200),(ypix+200))	DoWindow/C filetable_popup	String DF = GetDataFolder (1)	SetDataFolder root:internalUse:filetable	WAVE/T w_dialog_keys	WAVE/I w_dialog_selectedkeys	SVAR gs_keylist	String keys = ""	Variable i	for (i = 0; i < numpnts(w_dialog_selectedkeys); i += 1)		if (w_dialog_selectedkeys[i] & 1 == 1) // item is selected			keys += w_dialog_keys[i] + ";"		endif	endfor	String key = StringFromList(fromCol-1,keys)	String opts = StringByKey(key,gs_keylist,"=","\r")	String colname = StringFromList(0,opts,":")	String coltype = StringFromList(0,StringFromList(1,opts,":"),";") // get the variable type 	Variable/G gv_popup_startvalue = 0	Variable/G gv_popup_endvalue = 0	Variable/G gv_popup_stepsize = 0	Variable/G gv_popup_numselected = toRow-fromRow+1	String/G gs_popup_stringvalue = ""	Titlebox tb0, pos={15,15},fsize=12,frame=0, title="Selected: \""+key+"\""	TitleBox tb1, pos={15,40},size={170,20},frame=0,title="Number of selected cells: "+num2str(gv_popup_numselected)	if (stringmatch(coltype,"string"))		SetVariable stringVal, pos={15,60}, size={170,20},title="First value: ",value=gs_popup_stringvalue	else // is a "float" or an "int"		SetVariable startVal, pos={15,60}, size={170,20},title="First value: ",value=gv_popup_startvalue		SetVariable endVal, pos={15,80}, size={170,20},title="Last value: ",value=gv_popup_endvalue,proc=filetable#tableSelection_setVariable		SetVariable stepSize, pos={15,100},size={170,20},title="Step size:",value=gv_popup_stepsize,proc=filetable#tableSelection_setVariable		if (stringmatch(coltype,"int"))			TitleBox tb1, pos={15,120},size={170,20},title="(Values will be rounded to integer when applied)"		endif	endif	Button okBtn, pos={15,160}, size={80,20}, title="ok", proc=filetable#tableSelection_buttonClose	Button abortBtn, pos={105,160}, size={80,20}, title="abort", proc=filetable#tableSelection_buttonClose	PauseForUser filetable_popup	for (i = 0; i < gv_popup_numselected; i+=1)		if (stringmatch(coltype,"int"))			WAVE/I w0 = $colname			w0[i+fromRow] = round(gv_popup_startvalue + i * gv_popup_stepsize)		elseif (stringmatch(coltype,"float"))			WAVE w1 = $colname			w1[i+fromRow] = gv_popup_startvalue + i * gv_popup_stepsize		elseif (stringmatch(coltype,"string"))			WAVE/T w2 = $colname			w2[i+fromRow] = gs_popup_stringvalue		endif	endfor		SetDataFolder $DF	return 1End//////////////////////////// Private Control callbacks for table selection popup menu//////////////////////////Static Function tableSelection_buttonClose(ctrlName) : ButtonControl	String ctrlName	DoWindow/K filetable_popup	NVAR gv_popup_numselected = root:internalUse:filetable:gv_popup_numselected	if (stringmatch(ctrlName,"abortBtn"))		gv_popup_numselected = 0	endifEndStatic Function tableSelection_setVariable(ctrlName,varNum,varStr,varName) : SetVariableControl	String ctrlName	Variable varNum	// value of variable as number	String varStr		// value of variable as string	String varName	// name of variable	NVAR gv_popup_startvalue = root:internalUse:filetable:gv_popup_startvalue	NVAR gv_popup_endvalue = root:internalUse:filetable:gv_popup_endvalue	NVAR gv_popup_stepsize = root:internalUse:filetable:gv_popup_stepsize	NVAR gv_popup_numselected = root:internalUse:filetable:gv_popup_numselected	strswitch(ctrlName)		case "endVal":			gv_popup_stepsize = (gv_popup_endvalue - gv_popup_startvalue) / (gv_popup_numselected-1)			break		case "stepSize":			gv_popup_endvalue = gv_popup_stepsize * (gv_popup_numselected-1) + gv_popup_startvalue	endswitchEnd//Function create_fileTable(s,v)//	String s//	Variable v//	Abort "Please use filetable_open() instead."//End