#pragma rtGlobals=1		// Use modern global access method
#pragma version = 3.00
#pragma ModuleName = DC
#pragma IgorVersion = 5.0











//////////////
//
// Public Functions
//
//////////////















//------------------ extract cuts from any matrix ------------------------------------
//
//
// note: graphs need size correction
//
// new 'image' version: FB 09-24-03
// version with 2 DCs: FB 10-31-03


//Open DC&Display panel in Tabcontrol mode  -WS 08/03/3002
//Main Function of Display is in Display.ipf
Function DC_open(ctrlName)
	String ctrlName
	
	String DF = GetDataFolder (1)
	
	init()
	SetDataFolder root:internaluse:DC
	
	DoWindow/K DC_panel
	Display/K=1 as "Carpet-DCs & Display"
	DoWindow/C DC_panel
	utils_resizeWindow("DC_panel",510,565)
	utils_autoPosWindow("DC_panel", win=127)
	
	String cmd = "ControlBar 213"
	execute cmd

	panelcommon_addImage("DC_display_panel")
	AppendToGraph/Q/L=edc_en/T=edc_int root:internalUse:panelcommon:n_edc_x vs root:internalUse:panelcommon:n_edc2
	AppendToGraph/Q root:internalUse:panelcommon:n_mdc2
	ModifyGraph rgb(n_mdc)=(1,26214,0)//,rgb(n_edc_x)=(1,26214,0)
	ModifyGraph rgb(n_edc_x#1)=(52428,1,1), rgb(n_mdc2)=(52428,1,1)

	ShowInfo; Cursor/P/I/H=1 B w_image 20,20; Cursor/P/I/H=1 A w_image 10,10
	
	// Control that do not depend on Tab
	panelcommon_srcListBoxInit()
//	listbox wave_lb, pos={16,37}, size={130,150}, listwave=root:internalUse:panelcommon:w_sourceNames, selwave=root:internalUse:panelcommon:w_sourceNamesSel, selrow=0, frame=2,mode=4, proc=panelcommon_srcListboxProc
	listbox wave_lb, pos={16,37}, size={130,150}, listwave=root:internalUse:panelcommon:w_sourceNames, selwave=root:internalUse:panelcommon:w_sourceNamesSel, selrow=0, frame=2,mode=4, proc=panelcommon_srcListboxProc, widths={200}
	
	CheckBox n_check1, pos={24,197}, title="lock DC-intensity scale", proc=panelcommon_checkBoxLockInt
	CheckBox n_check2, pos={300,197}, title="integrate E", proc=panelcommon_checkBoxIntEorK
	CheckBox n_check3, pos={366,197}, title="k", proc=panelcommon_checkBoxIntEorK
	CheckBox n_check4, pos={400,197}, title="between cursors", proc=panelcommon_checkBoxIntEorK
	
	// --------------------------tab-controls -----------------
	Variable r=57000, g=57000, b=57000
	ModifyGraph cbRGB=(42428,42428,42428)
	ModifyGraph wbRGB=(38776,46477,61383), gbRGB=(38776,46477,61383)

	// source tab
	TabControl DC_Display,proc=DC#tabControlChange, pos={8,6},size={494,190},tabLabel(0)="source",value=0,labelBack=(r,g,b), fsize=12
	GroupBox sou_gb0, frame=1,labelBack=(r,g,b), pos={170,35}, size={240,149}, title="source folder", fsize=10
	listbox sou_lb1, pos={180,60}, size={220,90}, listwave=root:internalUse:panelcommon:w_DF, selrow=1, frame=2,mode=1, proc=panelcommon_srcListboxProc
	
	// raw DC tab
	TabControl DC_Display,tabLabel(1)="DCs"
	
	Groupbox DCs_gb0, pos={160,40}, size={140,115}, title="define DC's", disable=1
	CheckBox DCs_cbEDC, pos={168,60}, title="EDC's", fsize=12,labelBack=(r,g,b), proc=DC#checkBoxMdcEdc,mode=1, value=1, disable=1
	CheckBox DCs_cbMDC, pos={238,60}, title="MDC's", fsize=12,labelBack=(r,g,b), proc=DC#checkBoxMdcEdc,mode=1, disable=1
	
	SetVariable DCs_sv0,pos={168,78},size={78,18},limits={0,inf,1},title="first:",labelBack=(r,g,b), value= gv_first, disable=1
	SetVariable DCs_sv1,pos={168,96},size={78,18},limits={0,inf,1},title="last: ",labelBack=(r,g,b), value = gv_last, disable=1
	SetVariable DCs_sv2,pos={168,114},size={78,18},limits={-inf,inf,1},title="step: ",labelBack=(r,g,b), value = gv_step, disable=1
	Button DCs_bAllDC,pos={252,78},size={40,15},title="all", proc=DC#buttonSelectDC, disable=1
	Button DCs_bgDC,pos={252,96},size={40,15},title="green", proc=DC#buttonSelectDC, disable=1
	Button DCs_brgDC,pos={252,114},size={40,15},title="r + g", proc=DC#buttonSelectDC, disable=1
	CheckBox DCs_cb0,pos={168,132}, title="integrate betw. steps", labelBack=(r,g,b), variable=gv_stepIntegrate, disable=1
	
	Groupbox DCs_gb2, pos={310,40}, size={182,115}, title="modify graph:", disable=1
	Titlebox DCs_tb0, pos={320,65}, title="x:", frame=0, disable=1
	Titlebox DCs_tb1, pos={320,82}, title="y:", frame=0, disable=1
	Slider DCs_sl0,pos={332,65},size={100,18},limits={-1,1,0.005},variable=gv_x_offset,side= 0,vert= 0, side=2,labelBack=(r,g,b), thumbcolor=(2,2,2), proc=DC#sliderOffset, disable=1
	Slider DCs_sl1,pos={332,82},size={100,18},limits={0,1,0.002},variable=gv_y_offset,side= 0,vert= 0, side=2,labelBack=(r,g,b), thumbcolor=(2,2,2), proc=DC#sliderOffset, disable=1
	SetVariable DCs_sv3, pos={440,65}, size={43,15}, value=gv_x_offset,limits={-inf,inf,0}, title=" ",labelBack=(r,g,b), proc=DC#setVariableOffset, disable=1
	SetVariable DCs_sv4, pos={440,82}, size={43,15}, value=gv_y_offset,limits={-inf,inf,0}, title=" ",labelBack=(r,g,b), proc=DC#setVariableOffset, disable=1
	PopupMenu DCs_p0,pos={320,108},size={144,18}, value="*COLORPOP*", proc=DC#popupMenuTraceColor, disable=1
	Button DCs_b1, pos={400,108}, size={80,16}, title="fill to zero", proc=DC#buttonFillToZero, disable=1
	Button DCs_b2, pos={400,134}, size={80,16}, title="no fill", proc=DC#buttonFillToZero, disable=1
	Button DCs_b3, pos={320,134}, size={60,16}, title="rainbow", proc=DC#buttonRainbowTraces, disable=1
	
	Button DCs_bdisplay,pos={162,166},size={70,18},title="display", proc=DC#buttonDoDisplayDC, disable=1
	Button DCs_badd,pos={243,166},size={70,18},title="add", proc=DC#buttonDoDisplayDC, disable=1
	Button DCs_bremove,pos={326,166},size={70,18},title="remove", proc=DC#buttonDoDisplayDC, disable=1
	Button DCs_bclose,pos={408,166},size={70,18},title="close & kill", proc=DC#buttonKillDC, disable=1
	
	// interpolated DC tab
	//TabControl DC_Display,tabLabel(2)="interp. DC's"
	
	//Display tab
	TabControl DC_Display,tabLabel(2)="Carpet Display"

	Groupbox car_gb0, pos={160,25}, size={330,60}, title="graph style", disable=1

	//PopupMenu car_p0, pos={300,63}, value = cTabList(), proc=popupMenuColorTable, disable=1
	PopupMenu car_p0, pos={165,40}, value = "*COLORTABLEPOP*", proc=DC#popupMenuColorTable, disable=1
	SetVariable car_sv2, pos={365,40}, size={80,15}, title="contrast:",limits={-2,2,0.05},labelBack=(r,g,b), variable=gv_d_low, proc=DC#setVariableImageContrast, disable=1
	SetVariable car_sv3, pos={445,40}, size={40,15}, title="-",limits={-2,2,0.05},labelBack=(r,g,b), variable=gv_d_high, proc=DC#setVariableImageContrast, disable=1

	SetVariable car_sv0, pos={165,63}, size={45,15}, title="w: ",limits={0,inf,0},labelBack=(r,g,b), variable=gv_d_width, disable=1
	SetVariable car_sv1, pos={215,63}, size={45,15}, title="h:",limits={0,inf,0},labelBack=(r,g,b), variable=gs_d_height, disable=1
	TitleBox car_tb0, pos={265,63}, title="add:", frame=0, disable=1
	CheckBox car_cbaddFName, pos={290,63}, title="filename",labelBack=(r,g,b), proc=DC#checkBoxAnnotation, disable=1
	CheckBox car_cbaddAngles, pos={350,63}, title="angles",labelBack=(r,g,b), proc=DC#checkBoxAnnotation, disable=1
	PopupMenu car_p1,pos={410,60},size={100,18}, title="text:", value="*COLORPOP*", proc=DC#popupMenuAnnotationColor, disable=1

	NVAR gv_d_tickPrec
	Groupbox car_gb1, pos={160,85}, size={330,80}, title="BZ pos (works only if all angles defined; see filetable)", disable=1
	CheckBox car_cb0, pos={165, 100}, title="enable",labelBack=(r,g,b), disable=1, variable=gv_d_bzPos
	SetVariable car_sv9, pos={240,100}, size={70,15}, title="# digits",limits={0,20,1},labelBack=(r,g,b), variable=gv_d_tickPrec, disable=1
	SetVariable car_sv4, pos={330,100}, size={95,15}, title="Crystal a",limits={0,20,1},labelBack=(r,g,b), variable=gv_lattice_a, disable=1
	SetVariable car_sv5, pos={430,100}, size={60,15}, title="b",limits={0,20,1},labelBack=(r,g,b), variable=gv_lattice_b, disable=1

	NVAR gv_d_tickMode
	NVAR gv_d_tickUseKx
	NVAR gv_d_tickUseKy
	CheckBox car_cbTicks, mode=1, pos={165, 120}, title="Ticks", disable=1, proc=DC#checkBoxDisplayBZTicks, value=(gv_d_tickMode == DC_TICK_MODE_TICKS)
	SetVariable car_sv6, pos={210 ,120}, size={45,15}, title="#:",limits={0,4,1},labelBack=(r,g,b), variable=gv_d_nTicks, disable=1
	CheckBox car_cbCanonical, mode=1, pos={270, 120}, title="Canonical", disable=1, proc=DC#checkBoxDisplayBZTicks, value=(gv_d_tickMode == DC_TICK_MODE_CANONICAL)
	SetVariable car_sv7, pos={340 ,120}, size={70,15}, title="start:",limits={-inf,inf,1},labelBack=(r,g,b), variable=gv_d_canonTickStart, disable=1
	SetVariable car_sv8, pos={415 ,120}, size={70,15}, title="delta:",limits={-inf,inf,1},labelBack=(r,g,b), variable=gv_d_canonTickDelta, disable=1
	CheckBox car_cbkx, pos={270, 140}, title="kx", disable=1, variable=gv_d_tickUseKx, proc=DC#checkBoxTickKxKy
	CheckBox car_cbkxcompact, pos={310, 140}, title="compact", disable=1, variable=gv_d_tickKxCompact, proc=DC#checkBoxTickKxKy
	CheckBox car_cbky, pos={370, 140}, title="ky", disable=1, variable=gv_d_tickUseKy, proc=DC#checkBoxTickKxKy
	CheckBox car_cbkycompact, pos={410, 140}, title="compact", disable=1, variable=gv_d_tickKyCompact, proc=DC#checkBoxTickKxKy
	

	Button car_bdisplay,pos={300,175},size={80,18},title="display", proc =DC#buttonCarpetDisplay, disable=1
	Button car_blayout,pos={400,175},size={80,18},title="layout", proc =DC#buttonCarpetDisplay, disable=1
	
	TabControl DC_Display,tabLabel(3)="LDA Data"
	WAVE w_LDAlist
	WAVE w_LDAsellist
	GroupBox lda_gb0, frame=1, labelBack=(r,g,b), pos={170,35}, size={255,149}, title="bands", fsize=10, disable=1
	listbox lda_lb1, pos={180,60}, size={230,90}, listwave=w_LDAlist, selwave=w_LDAsellist, frame=2,mode=4, editstyle=0, disable=1
	listbox lda_lb1, widths={120,50,50}, proc=DC#listboxLDAEvent
	Button lda_newWave,	pos={180,155},		size={70,18},title="new", proc=DC#buttonLDASel
	Button lda_addWave,	pos={255,155},		size={70,18},title="add", proc=DC#buttonLDASel
	Button lda_delWave,	pos={330,155},		size={70,18},title="remove", proc=DC#buttonLDASel
	SetVariable lda_sv4, pos={425,60}, size={65,15}, title="a",limits={1,11,1},labelBack=(r,g,b), variable=gv_lattice_a, disable=1
	SetVariable lda_sv5, pos={425,80}, size={65,15}, title="b",limits={1,11,1},labelBack=(r,g,b), variable=gv_lattice_b, disable=1
	CheckBox lda_cb0, pos={425,100}, title="units pi/A",labelBack=(r,g,b), disable=1, variable=gv_ldaunits_piA
	CheckBox lda_cb1, pos={425,120}, title="units EF",labelBack=(r,g,b), disable=1, variable=gv_ldaunits_EF
	CheckBox lda_cb2, pos={425,140}, title="cut E",labelBack=(r,g,b), disable=1, variable=gv_ldacutE
	


	DC_panel_SLB_proc()

	SetDataFolder $DF
End



Static Function listboxLDAEvent(LB_Struct) : ListBoxControl
	STRUCT WMListboxAction &LB_Struct
	if (LB_Struct.eventCode == 7) // Edit finished. -> Refresh
		WAVE w_image = root:internalUse:panelcommon:w_image
		try_add_LDA(w_image)
	endif
End



Static Function buttonLDASel(ctrlName) : ButtonControl
	String ctrlName
	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse:DC
	WAVE/T w_LDAlist
	WAVE/I w_LDAsellist

	Variable i, j, k, size = numpnts(w_LDAlist)
	String browserCmd = "CreateBrowser prompt=\"select source data to add, and click 'ok'\", showWaves=1, showVars=0, showStrs=0"

	strswitch(ctrlName)
		case "lda_delWave":
			j = 0
			for (i = 0; i < size; i += 1)
//				print w_dialog_selectedwaves[i]
				if (! w_LDAsellist[i][0] & 1) // item is NOT selected, need to count it
					j += 1
				endif
			endfor
//			print j
			if (j == 0) // special case: everything got deleted
				Make/O/T/N=(1,3) w_LDAlist = {{"_none"},{"1"},{"0"}}
				break
			endif
			Duplicate/O/T w_LDAlist, w_tmp
			Redimension/N=(j,3) w_LDAlist // allocate space for the remaining (unselected) entries
			j = 0
			for (i = 0; i < DimSize(w_LDAsellist, 0); i += 1)
				if (! w_LDAsellist[i][0] & 1) // item is NOT selected, needs to be copied
					w_LDAlist[j] = w_tmp[i]
					j += 1
				endif
			endfor
			Redimension/N=(j,3) w_LDAsellist
			KillWaves w_tmp
			break
		case "lda_newWave":
			size = 0
		case "lda_addWave":
			SetDataFolder $DF
			execute browserCmd
			SVAR S_BrowserList=S_BrowserList
			NVAR V_Flag=V_Flag
			if(V_Flag==0)
				break
			endif
			SetDataFolder root:internalUse:DC
			Duplicate/O/T w_LDAlist, w_tmp
			Redimension/N=(max(size + ItemsInList(S_BrowserList),1),3) w_LDAlist
			Redimension/N=(max(size + ItemsInList(S_BrowserList),1),3) w_LDAsellist
			k = size
			for (i = 0; i < ItemsInList(S_BrowserList); i += 1)
				String dlgwaves = utils_wave2StringList(w_LDAlist)
				// check to avoid duplicate items in the wave selection:
				if (WhichListItem(StringFromList(i,S_BrowserList), dlgwaves) != -1)
					continue
				endif
				// We only want 2D waves here:
				if (WaveDims($StringFromList(i,S_BrowserList)) != 2)
					continue
				endif
				w_LDAlist[k][0] = StringFromList(i,S_BrowserList)
				w_LDAlist[k][1] = "1"
				w_LDAlist[k][2] = "0"
				k += 1
			endfor
			Redimension/N=(max(k,1),3) w_LDAlist
			Redimension/N=(max(k,1),3) w_LDAsellist
			if (k == 0)
				w_LDAlist = {{"_none"},{"1"},{"0"}}
			endif
			w_LDAsellist[][0] = 0
			w_LDAsellist[][1,2] = 2
			KillWaves w_tmp
			break
		default:
			Abort "buttonWaveSel(): ctrlName \""+ctrlName+"\" not recognized."
	endswitch
	WAVE w_image = root:internalUse:panelcommon:w_image
	try_add_LDA(w_image)
	SetDataFolder $DF
End




// a first attempt to create meaningful x,y,z labels for carpets and maps
// dim=x,y,z
//														FB 04-09-21
Function/s DC_axisLabel(notestr,dim)
	String notestr, dim
	
	String x_label, y_label, z_label
	
	String MatrixType = StringByKey("MatrixType",notestr,"=","\r")
	String XScanType = StringByKey("XScanType",notestr,"=","\r")
	String AngleMapping = StringByKey("AngleMapping",notestr,"=","\r")
	String EnergyScale = StringByKey("EnergyScale",notestr,"=","\r")
	
	// x-axis
	if (stringmatch(notestr,"*AngleMapping*") == 0)
		x_label = ""
	else
		if (stringmatch(AngleMapping, "*none*"))
			x_label = "Emission Angle (deg)"
		else
			x_label = "Parallel Momentum (\S-1\M)"
		endif
	endif
	
	// y-axis
	if (stringmatch(notestr,"*EnergyScale*") == 0)
		y_label = ""
	else
		if (stringmatch(EnergyScale,"*kinetic*"))
			y_label = "Kinetic Energy (eV)"
		else
			y_label = "E-E\\BF\\M (eV)"
		endif
	endif
	
	// z-axis
	if (stringmatch(notestr,"*XScanType*") == 0)
		z_label = ""
	else
		if (stringmatch(XScanType,"Scienta*"))
			//z_label = "Intensity (kcts/s/channel)"
			z_label = "Intensity (cts/s/pixel)"
		else
			z_label = "Intensity (kcts/s)"
		endif
	endif
	
	// suppress dimension labels?
//	if (suppress_flag)
//		suppress_string= "\\u#2"
//	else
//		suppress_string = ""
//	endif
	
	
	strswitch(dim)	// string switch
		case "x":		
				return x_label
			break
		case "y":		
				return y_label
			break
		case "z":		
				return z_label
			break	
	endswitch
End




// NOTE: this is vintage code. It will be replaced eventually.
// This function is called from i_panelcommon, namely from panelcommon_srcListboxProc().
// The function name is auto-generated; it needs to be composed out of
// <windowname>_SLB_proc such that panelcommon_srcListboxProc()
// can find it. This function updates the graph view.
// executed whenever one or more cells in the source list-boxes are selected
Function DC_panel_SLB_proc()
	
	String pDF = GetDataFolder (1)
	SetDataFolder root:internalUse:panelcommon
	SVAR DF = root:internalUse:panelcommon:gs_currentDF
	SVAR pList = root:internalUse:panelcommon:gs_sourcePathList
	SVAR topPath = root:internalUse:panelcommon:gs_TopItemPath
		
	if (strlen(pList) == 0)
		Make/o/n=(10,10) w_image=nan
	else
		Duplicate/o $topPath w_image
	endif

	Make/N=(dimsize(w_image,0))/O n_mdc, n_mdc2
	Make/N=(dimsize(w_image,1))/O n_edc, n_edc2, n_edc_x
	SetScale/I x, utils_x0(w_image),utils_x1(w_image), n_mdc, n_mdc2
	SetScale/I x, utils_y0(w_image),utils_y1(w_image), n_edc, n_edc2, n_edc_x
	n_edc_x = x
			
	Variable xPoint = pcsr(B,"DC_panel")
	Variable yPoint = qcsr(B,"DC_panel")
	n_mdc = w_image[p][yPoint]
	n_edc = w_image[xPoint][p]

	xPoint = pcsr(A,"DC_panel")
	yPoint = qcsr(A,"DC_panel")
	// This is needed to call the CursorMovedHook() function to update the
	// image info if the image changes:
	Cursor/I A, w_image, utils_pnt2x(w_image, xPoint), utils_pnt2y(w_image, yPoint)
	n_mdc2 = w_image[p][yPoint]
	n_edc2 = w_image[xPoint][p]
	
	try_add_LDA(w_image)
	add_textbox($topPath)
		
	SetDataFolder $pDF
End























//////////////
//
// Private Control Callbacks
//
//////////////














Static Function tabControlChange( name, tab )
	String name
	Variable tab
	
	ControlInfo $name	// Get the name of the current tab
	String tabStr = S_Value[0,2]
	
	// Get a list of all the controls in the window
	Variable i = 0
	String all = ControlNameList( "DC_panel" )
	String thisControl
	
	do
		thisControl = StringFromList( i, all )
		if( strlen( thisControl ) <= 0 )
			break
		endif
		
		if( !CmpStr( thisControl[3], "_" ) )
			if( !CmpStr( thisControl[0,2], tabStr ) )
				utils_setControlEnabled( thisControl, 0 )
			else
				utils_setControlEnabled( thisControl, 1)
			endif
		endif
		i += 1
	while( 1 )
	if (stringmatch(tabStr, "car"))
		restoreCanonicalTickUISanity()
	endif
	SetActiveSubwindow DC_panel
End




Static Function buttonSelectDC(ctrlname)
	String ctrlname

	WAVE M = root:internalUse:panelcommon:w_image
	NVAR first = root:internalUse:DC:gv_first
	NVAR last = root:internalUse:DC:gv_last
	NVAR step = root:internalUse:DC:gv_step

//	Button DCs_bAllDC,pos={252,90},size={40,15},title="all", proc=DC#buttonAllDC, disable=1
//	Button DCs_bgDC,pos={252,110},size={40,15},title="green", proc=DC#buttonGreenDC, disable=1
//	Button DCs_brgDC,pos={252,130},size={40,15},title="r + g", proc=DC#buttonRedAndGreenDC, disable=1
	ControlInfo DCs_cbMDC
	strswitch(ctrlname)
		case "DCs_bAllDC":
			step = 1; first = 0
			last = dimsize(M,v_value)-1
			ShowInfo
			Cursor/P/I/H=1 A w_image 0,0
			Cursor/P/I/H=1 B w_image dimsize(M,0)-1,dimsize(M,1)-1
			break
		case "DCs_bgDC":
			first = (v_value) ? qcsr(B) : pcsr(B)
			last = first
			step = 1
			break
		case "DCs_brgDC":
			first = (v_value) ? qcsr(B) : pcsr(B)
			last = (v_value) ? qcsr(A) : pcsr(A)
			step = last - first
			break
	endswitch

	ControlUpdate DCs_sv0
	ControlUpdate DCs_sv1
	ControlUpdate DCs_sv2
end





Static Function buttonFillToZero(ctrlName)
	String ctrlName
	
	String gN = WinName(1,1)
	if (strlen(gN) == 0)
		return -1
	endif
	
	if (stringmatch(ctrlName, "DCs_b2"))	// "no fill"
		ModifyGraph/w=$gN mode=0
		return 1
	endif
	
	String List = TraceNameList(gN, ";",1)
	String TraceName
	Variable items = ItemsInList(List,";")
	
	Variable index = 0	//items-1
	do
		TraceName = StringFromList(index,List)
		ModifyGraph/w=$gN mode=7,hbFill=1,useNegPat($Tracename)=1,hBarNegFill($TraceName)=1
	index += 1
	while (index < items)
End


	
Static Function sliderOffset(name, value, event)
	String name			// name of this slider control
	Variable value		// value of slider
	Variable event		// bit field: bit 0: value set; 1: mouse down, 2: mouse up, 3: mouse moved

	NVAR x_offset = root:internalUse:DC:gv_x_offset
	NVAR y_offset = root:internalUse:DC:gv_y_offset
	
	ControlUpdate DCs_sv3
	ControlUpdate DCs_sv4
	
	String gN = WinName(1,1)
	if (strlen(gN) == 0)
		return -1
	endif
	
	String List = TraceNameList(gN, ";",1)
	String TraceName
	Variable items = ItemsInList(List,";")
	Variable default_y_offset=0, default_x_offset=0
	
	// get a rough estimate of the average y-values
	
	// corrected 06-16-04. works now with NaNs in the wave and for less than three waves
	Variable index = 0
	Variable n = 0
	do
		TraceName = StringFromList(index,List)
		WAVE temp = TraceNameToWaveRef(gN, TraceName)
		WaveStats/Q temp
		default_y_offset += v_avg
	n += 1
	index += 3	
	while (index < items)	// CORR 01-19-04
	default_y_offset = default_y_offset/ n *0.6	// 60% of average times 0.5 from slider
	default_x_offset = numpnts(temp)*deltax(temp)/10
	
	// offset the traces
	Variable delta_y = y_offset * default_Y_offset
	Variable delta_x = x_offset * default_x_offset
	index = 0
	do
		TraceName = StringFromList(index,List)
		// offsetting this way round makes filling easier
		ModifyGraph/w=$gn offset($TraceName)={delta_x*(items-index-1),delta_y*(items-index-1)}
	index += 1	
	while (index < items)
	
	return 0
End




Static Function setVariableOffset(ctrlName,varNum,varStr,varName)
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	NVAR x_off = root:internalUse:DC:gv_x_offset
	NVAR y_off = root:internalUse:DC:gv_y_offset
	ControlInfo DCs_sv3
	x_off = v_value
	ControlInfo DCs_sv4
	y_off = v_value
	
	//ControlUpdate DCs_sl0
	//ControlUpdate DCs_sl1
	Slider DCs_sl1, value=y_off
	Slider DCs_sl0, value=x_off
	sliderOffset("dum", NaN, 1)
End


Static Function popupMenuTraceColor(ctrlName,popNum,popStr)
	String ctrlName
	Variable popNum
	String popStr
	
	String gN = WinName(1,1)
	ControlInfo DCs_p0
	ModifyGraph/W=$gN rgb=(v_red, v_green, v_blue)
End



Static Function buttonRainbowTraces(ctrlName)
	String ctrlName
	
	String gN = WinName(1,1)
	if (strlen(gN) == 0)
		return -1
	endif

	ColorTab2Wave Rainbow
	WAVE M_colors

	String List = TraceNameList(gN, ";",1)

	Variable i
	for (i = 0; i < ItemsInList(List,";"); i += 1)
		Variable col = i * DimSize(M_colors, 0) / ItemsInList(List,";")
		ModifyGraph/W=$gN rgb[i]=(M_colors[col][0], M_colors[col][1], M_colors[col][2]) 
	endfor
	Killwaves M_colors
End



Static Function buttonKillDC(ctrlName)
	String ctrlName
	
	String gN = WinName(1,1)
	if (strlen(gN) == 0)
		return -1
	endif
	String List = TraceNameList(gN, ";",1)
	String TraceName = StringFromList(0,List)
	
	WAVE trace = TraceNameToWaveRef(gN,TraceName)
	String DF = GetWavesDataFolder(trace,1)
	DoWindow/K $gN		// check for other graphs with the same waves??
	KillDataFolder $DF
End

//--------------------------------- extract and display DC's --------------------------------------
//Function display_DC(ctrlname): buttonControl
//	String ctrlname
//	//ControlInfo DCpopup11
//	buttonDoDisplayDC(0)		// display
//End
//Function add_DC(ctrlname): buttonControl
//	String ctrlname
//	//ControlInfo DCpopup11
//	buttonDoDisplayDC(1)		// add
//End
//Function remove_DC(ctrlname): buttonControl
//	String ctrlname
//	//ControlInfo DCpopup11
//	buttonDoDisplayDC(2)		// remove
//End

//////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// 01-16-04	interpolation option removed and wavenote added
Static Function buttonDoDisplayDC(ctrlname)						// version 2, FB 11/26/02
	String ctrlname

	String DF = GetDataFolder(1)
	String suffix, cmd0, cmd1
	String DCname, Mname
	Variable index, val, offset, nDC, n
	Variable w_points
	Variable m_collapsed, e_collapsed

	// get the panel-Info and the carpet:
	SetDataFolder root:internalUse:DC
	NVAR first = gv_first
	NVAR last = gv_last
	NVAR step = gv_step
	NVAR stepIntegrate = gv_stepIntegrate
	NVAR first_i = gv_firstinterval
	NVAR last_i = gv_lastinterval
	NVAR step_i = gv_stepinterval
	//SVAR i_points = gs_interpoints
	ControlInfo DCs_cbEDC	
	Variable dim = v_value			// dimension (1=EDC, 0=MDC)
	
	SVAR path = root:internalUse:panelcommon:gs_TopItemPath
	Wave w = $path
	String notestr = note(w)
	String DCnote = ""
	
	String gN = WinName(1,1)
	Mname = NameofWave(w)
	SetDataFolder $GetWavesDataFolder(w,1)
	NewDataFolder/O/S DC	// pack the DC's in a subfolder of the matrix' folder
	NewDataFolder/O/S $Mname
	
	// check consistency of input
	if (sign((last-first)/step)==-1)
		Doalert 0, "Negative number of spectra! Please change step#!"
		SetDataFolder $DF
		return -1
	elseif (step == 0)
		DoAlert 0, "Please use a step-value different from zero!"
		SetDataFolder $DF
		return -1
	endif
	nDC = trunc(abs((last-first)/step) + 1)		// 06-16-04 trunc gives the correct offsets and correct number of DCs
	w_points = Dimsize(w,dim)
	
	// make and scale the DC
	Make/O/N=(w_points) t_DC=0
	// define the things which are different in for EDCs/MDCs
	if (dim == 1)	// EDC
		//DCnote = "Energy Distribution Curve\r"
		suffix = "_e"
		SetScale/I x utils_y0(w), utils_y1(w),"", t_DC
	else				// MDC
		//DCnote = "Momentum Distribution Curve\r"
		suffix = "_m"
		SetScale/I x utils_x0(w), utils_x1(w),"", t_DC
	endif

	// Determine the overall intensity average for calculating the offset for the slider
	for (index = min(first, last); index < max(first, last); index += (stepIntegrate ? 1 : abs(step)) )
		if (dim == 1)
			t_DC += w[index][p]
		else
			t_DC += w[p][index]
		endif
	endfor
	WaveStats/Q t_DC
	// 06-16-04: 0.3 == exactly the same default offset as the "slider-offset" function
	offset = 0.3 * V_avg / nDC
	
	// 06-16-04: extract collapsed DCs if the boxes are clicked
	ControlInfo n_check2
	e_collapsed = v_value
	ControlInfo n_check3
	m_collapsed = v_value
	
	if (stringmatch(ctrlname, "DCs_bdisplay"))
		Display  /W= (10, 10, 280,320)
	else
		DoWindow/F $gN
	endif

	
	// get the data and append to top-graph
	for (index = 0; index < nDC; index += 1)
		n = first+index*step
		
		if (dim == 1)	// EDC
			DCnote = "Energy Distribution Curve\r"
			DCnote +="SourceCarpet="+path+"\r"
			if (m_collapsed)	// 06-16-04
				DCnote += "Momentum=integrated\r"
				Duplicate/o root:internalUse:panelcommon:n_edc t_DC
				DCname = Mname + suffix
			else
				t_DC = w[n][p]		// FB 09-26-03 'interpolation' removed for raw data
				if (stepIntegrate)
					Variable j
					for (j = n+1; j < n+step; j+= 1)
						t_DC += w[j][p]
					endfor
					sprintf DCnote, "%sMomentum=%g,int%g\r", DCnote, utils_pnt2x(w, n), utils_pnt2x(w, n+step-1)
				else
					DCnote += "Momentum="+num2str(utils_pnt2x(w, n))+"\r"
				endif
				DCname = Mname + suffix + num2str(n)
			endif
		else				// MDC
			DCnote = "Momentum Distribution Curve\r"
			DCnote +="SourceCarpet="+path+"\r"
			if (e_collapsed)
				DCnote += "Energy=integrated\r"
				Duplicate/o root:internalUse:panelcommon:n_mdc t_DC
				DCname = Mname + suffix
			else
				t_DC = w[p][n]
				if (stepIntegrate)
					for (j = n+1; j < n+step; j+= 1)
						t_DC += w[p][j]
					endfor
					sprintf DCnote, "%sEnergy=%g,int%g\r", DCnote, utils_pnt2y(w, n), utils_pnt2y(w, n+step-1)
				else
					DCnote += "Energy="+num2str(utils_pnt2y(w, n))+"\r"
				endif
				DCname = Mname + suffix + num2str(n)
			endif
		endif
		
		Note/K t_DC
		Duplicate/O t_DC $DCName
		Note $DCName, DCnote
		
		if (stringmatch(ctrlname, "DCs_bdisplay"))
			AppendToGraph $DCName
			ModifyGraph offset($DCname)={0, offset*(nDC-index-1)}	// offsetting this way round makes filling easier
			ModifyGraph/Z lSize($DCname) = 0.5
			ModifyGraph rgb($DCname)=(0,0,0)
		elseif (stringmatch(ctrlname, "DCs_badd"))
			AppendToGraph/W=$gN  $DCName
			ModifyGraph/W=$gN offset($DCname)={0, offset*(nDC-index-1)}	// offsetting this way round makes filling easier
			ModifyGraph/Z lSize($DCname) = 0.5
			ModifyGraph rgb($DCname)=(0,0,0)
		else
			RemoveFromGraph/W=$gN /Z $DCName
		endif
		
		if((e_collapsed && dim==1) || (m_collapsed && dim==0))	// 06-16-04
			break
		endif
	endfor

	if (stringmatch(ctrlname, "DCs_bdisplay"))
		if (dim==1)
			Label Bottom DC_axisLabel(notestr,"y")
		else
			Label Bottom DC_axisLabel(notestr,"x")
		endif
		Label Left DC_axisLabel(notestr,"z")
		ModifyGraph tickUnit = 1
	endif

	ModifyGraph/Z mirror=2
	ModifyGraph/Z minor=1

	KillWaves/Z t_DC
	SetDataFolder $DF
End


//Function DC_Style()
//	//ModifyGraph/Z lSize=0.5
//	//ModifyGraph/Z rgb = (0,0,0)
//	ModifyGraph/Z mirror=2
//	ModifyGraph/Z minor=1
//	//Label Left "Intensity (cts/s)"
//End

//////////////////////////////////////////////////////////////////////////////////////////////////

// check-box switches
Static Function checkBoxMdcEdc(name,value)
	String name
	Variable value
	
	NVAR first = root:internalUse:DC:gv_first
	NVAR last = root:internalUse:DC:gv_last
	WAVE M = root:internalUse:DC:w_image
		
	Variable bVal, d_limit
	strswitch (name)
		case "DCs_cbEDC":
			bVal= 1
			first = pcsr(A)
			last = pcsr(B)
			d_limit = dimsize(M,0)-1
			break
		case "DCs_cbMDC":
			first = qcsr(A)
			last = qcsr(B)
			bVal= 2
			d_limit = dimsize(M,1)-1
			break
	endswitch
	CheckBox DCs_cbEDC,value= bVal==1
	CheckBox DCs_cbMDC,value= bVal==2
	SetVariable DCs_sv0, limits={0,d_limit,1}
	SetVariable DCs_sv1, limits={0,d_limit,1}
	SetVariable DCs_sv2, limits={-d_limit,d_limit,1}
End





Static Function popupMenuColorTable(ctrlName,popNum,popStr)
	String ctrlName
	Variable popNum
	String popStr

	ModifyImage w_image ctab= {*,*,$popStr,0}
End





Static Function setVariableImageContrast(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	WAVE M = root:internalUse:panelcommon:w_image
	NVAR c_min = root:internalUse:DC:gv_d_low
	NVAR c_max = root:internalUse:DC:gv_d_high
	Imagestats/M=1 M
	
	ControlInfo car_p0; String table = s_value
	
	Variable from = v_min + c_min * (v_max - v_min)
	Variable to = v_min + c_max * (v_max - v_min)
	ModifyImage w_image ctab= {from, to, $table,0}
End





Static Function buttonCarpetDisplay(ctrlName)
	String ctrlName
	
	NVAR width = root:internalUse:DC:gv_d_width
	SVAR s_height = root:internalUse:DC:gs_d_height
	Variable height
	if (stringmatch(s_height,"plan"))
		height = width	// for the layout 
	else
		height = str2num(s_height)
	endif
	
	SVAR path_list = root:internalUse:panelcommon:gs_sourcePathList
	String path, name
	Variable items = itemsinlist(path_list)
	Variable left, right, top, bottom
	
	Variable lay_left = 25
	Variable lay_top = 72
	Variable layout_width = 8.22 * 72	// approx. letter size - right/bottom margins
	Variable layout_height = 10.44 * 72
	
	if (stringmatch(ctrlName,"car_blayout"))
		NewLayout
		String layoutName = WinName(0,4)
		TextBox/C/N=text0/A=RT date()+", "+IgorInfo (1)
		ModifyLayout left(text0)=360,top(text0)=29
		ModifyLayout frame(text0)=0,trans(text0)=1
	endif
	
	Variable index = 0
	do
		path = StringFromList(index,path_list)
		WAVE w = $path
		Name = NameOfWave(w)
		left = 0
		top = 40 + 40*index
		right = left + 100
		bottom = top + 100
		Display/W=(left,top,right,bottom)/N=$("g"+Name) as Name
		Appendimage $path
		
		carpetStyle(w)
		
		if (stringmatch(ctrlName,"car_blayout"))
			String GraphName = WinName(0,1)
			if (lay_left + width * 72 + 55 > layout_width)
				DoWindow/F $layoutName
				ModifyLayout frame=0,trans=1
				DoAlert 0, "The graph '"+graphName+"' with the image '"+Name+"' does not fit anymore on the layout."
				abort
			endif
			AppendLayoutObject graph $GraphName
			ModifyLayout left($GraphName)=lay_left,top($GraphName)= lay_top
			lay_top += height*72 + 40
			if(lay_top > layout_height - (height*72 + 40))
				lay_left += width * 72 + 55
				lay_top = 72
			endif
		endif
	
	index += 1
	while(index<items)
	
	if (stringmatch(ctrlName,"car_blayout"))
		DoWindow/F $layoutName
		ModifyLayout frame=0,trans=1
	endif
End




Static Function checkBoxAnnotation(ctrlName,checked)
	String ctrlName
	Variable checked
	
	SVAR topPath = root:internalUse:panelcommon:gs_topItemPath
	add_textbox($topPath)
End




Static Function popupMenuAnnotationColor(ctrlName,popNum,popStr)
	String ctrlName
	Variable popNum
	String popStr
	
	SVAR topPath = root:internalUse:panelcommon:gs_topItemPath
	add_textbox($topPath)
End



Static Function checkBoxDisplayBZTicks(ctrlName,checked)
	String ctrlName
	Variable checked
	
	NVAR tickMode = root:internalUse:DC:gv_d_tickMode
	strswitch(ctrlName)
		case "car_cbTicks":
			CheckBox car_cbTicks, value = 1
			CheckBox car_cbCanonical, value = 0
			tickMode = DC_TICK_MODE_TICKS
			break
		case "car_cbCanonical":
			CheckBox car_cbTicks, value = 0
			CheckBox car_cbCanonical, value = 1
			tickMode = DC_TICK_MODE_CANONICAL
			break
	endswitch
	restoreCanonicalTickUISanity()
End



Static Function checkBoxTickKxKy(ctrlname, checked)
	String ctrlName
	Variable checked
	restoreCanonicalTickUISanity()
End













//////////////
//
// Private Functions
//
//////////////










Static Constant DC_TICK_MODE_TICKS = 1
Static Constant DC_TICK_MODE_CANONICAL = 2




Static Function init()

	String DF = GetDataFolder (1)
	
	SetdataFolder root:internalUse
	NewDatafolder/o/s DC
	
	//panelcommon_makeNaNWaves()
	panelcommon_srcListBoxInit()	// generate the list-box waves
	//SVAR path = root:internalUse:panelcommon:gs_TopItemPath
	if(waveexists(root:internalUse:panelcommon:w_image)==0)
		panelcommon_makeNaNWaves()
	endif
	
	Variable/G gv_first=0, gv_last=0, gv_step=1, gv_stepIntegrate=1
	Variable/G gv_firstinterval, gv_lastinterval, gv_stepinterval
	Variable/G gv_pA, gv_pB, gv_qA, gv_qB		// the cursor values on the graph
	Variable/G gv_x_offset=0, gv_y_offset=0.5
	Variable/G gv_d_width = 3		//, gv_d_height = 2
	String/G gs_d_height = "2"		// can be set to 'plan'
	Variable/G gv_d_low=0, gv_d_high = 1
	Variable/G  gv_lattice_a = 0
	Variable/G gv_lattice_b = 0
//	Variable/G Gamma, Azim, gv_th, gv_phi , Kx, Ky, Ef
	Variable/G gv_th, gv_phi , Kx, Ky, Ef
	Variable/G gv_d_nTicks = 3
	Variable/G gv_d_tickPrec = 2
	Variable/G gv_d_tickUseKx = 1
	Variable/G gv_d_tickUseKy = 1
	Variable/G gv_d_tickKxCompact = 1
	Variable/G gv_d_tickKyCompact = 1
	Variable/G gv_d_canonTickStart = 0
	Variable/G gv_d_canonTickDelta = 0.5
	Variable/G gv_d_tickMode = DC_TICK_MODE_TICKS
	Variable/G gv_d_bzPos = 1
	Variable/G gv_ldaunits_piA = 1
	Variable/G gv_ldaunits_EF = 0
	Variable/G gv_ldacutE = 1

	Make/n=(1,3)/o/t w_LDAlist= {{"_none"},{"1"},{"0"}}
	Make/n=(1,3)/o w_LDAsellist= {{0},{2},{2}}		// '2' means editable
	SetDimLabel 1,0,source, w_LDAlist
	SetDimLabel 1,1, scale, w_LDAlist
	SetDimLabel 1,2, offset, w_LDAlist

	SetDataFolder $DF
End




Static Function restoreCanonicalTickUISanity()
	NVAR tickMode = root:internalUse:DC:gv_d_tickMode
	if (tickMode == DC_TICK_MODE_TICKS)
		CheckBox car_cbkx, disable=2
		CheckBox car_cbky, disable=2
		CheckBox car_cbkxcompact, disable=2
		CheckBox car_cbkycompact, disable=2
	else
		CheckBox car_cbkx, disable=0
		CheckBox car_cbky, disable=0
		CheckBox car_cbkxcompact, disable=0
		CheckBox car_cbkycompact, disable=0
	endif
	NVAR useKx = root:internalUse:DC:gv_d_tickUseKx
	NVAR useKy = root:internalUse:DC:gv_d_tickUseKy
	if (useKx == 0 && useKy == 0)
		useKx = 1
	endif
End




Static Function carpetStyle__BZPos(t,a,p,o,b,g, signs, kvac)
	Variable t,a,p,o,b,g, signs, kvac
	globals_flip_ang2k(t,a,p,o,b,g, signs=signs)
	NVAR V_kx, V_ky
	V_kx = V_kx * kvac
	V_ky = V_ky * kvac
	NVAR lattice_a = root:internalUse:DC:gv_lattice_a
	NVAR lattice_b = root:internalUse:DC:gv_lattice_b
	if (numtype(V_kx) != 0 || numtype(V_ky) != 0 || numtype(signs) != 0)
		KillWaves M_xTicks, M_xNames
		Abort "BZ positions are only available if all the info in the wave is complete. Use the filetable to correct this."
	endif
	if (lattice_a != 0 && lattice_b != 0)
		V_kx *= lattice_a / pi
		V_ky *= lattice_b / pi
	endif
End

Static Function carpetStyle(M)
	WAVE M
	
	String name = NameOfWave(M)
	String text
	
	NVAR width = root:internalUse:DC:gv_d_width
	SVAR s_height = root:internalUse:DC:gs_d_height
	NVAR low = root:internalUse:DC:gv_d_low
	NVAR high = root:internalUse:DC:gv_d_high
	Variable from, to
	Variable height
	
	// image contrast
	ControlInfo/W=DC_panel car_p0; String table = s_value
	ImageStats/M=1 M
	from = v_min + low * (v_max - v_min)
	to = v_min + high * (v_max - v_min)
	ModifyImage $name ctab= {from, to,$table,0}
	utils_resizeWindow(WinName(0,1), 300, 200)

	// image size
	if(stringmatch(s_height,"plan"))
		// If run in the Debugger, everything works fine. When run w/out debugger,
		// it does not set the graph size right. Don't ask me why. This workaround 
		// fixes this behavior:
//		Execute/Q/P "ModifyGraph/W="+WinName(0,1)+" width="+num2str(width*72)+", height={Plan,1,left,bottom}"
		ModifyGraph/W=$(WinName(0,1)) width=(width*72), height={Plan,1,left,bottom}
	else
		height = str2num(s_height)
		// dito:
		ModifyGraph/W=$(WinName(0,1)) width=(width*72), height=(height*72)
//		Execute/Q/P "ModifyGraph/W="+WinName(0,1)+" width="+num2str(width*72)+",height="+num2str(height*72)
	endif

	ModifyGraph width=0,height=0
	ModifyGraph/Z axOffset(left)=-1
	ModifyGraph margin(top)=10,margin(right)=10
	ModifyGraph/Z mirror=2
	ModifyGraph/Z minor=1
	ModifyGraph/Z sep=8
	ModifyGraph/Z btLen=4
	
	NVAR nPrec = root:internalUse:DC:gv_d_tickPrec

	NVAR bzPos = root:internalUse:DC:gv_d_bzPos
	if (bzPos)
		String notestr = note(M)
		String manipulator = StringByKey("ManipulatorType", notestr, "=", "\r")
		String eScale = StringByKey("EnergyScale", notestr, "=", "\r")
		String angleMapping = StringByKey("AngleMapping", notestr, "=", "\r")
		
		Variable gamma = NumberByKey("ScientaOrientation",notestr,"=","\r")
		Variable th = NumberByKey("InitialThetaManipulator", notestr, "=", "\r")
		th  += NumberByKey("OffsetThetaManipulator", notestr, "=", "\r")
		Variable al = NumberByKey("InitialAlphaAnalyzer", notestr, "=", "\r")
		Variable ph = NumberByKey("InitialPhiManipulator", notestr, "=", "\r")
		ph += NumberByKey("OffsetPhiManipulator", notestr, "=", "\r")
		Variable om = NumberByKey("InitialOmegaManipulator", notestr, "=", "\r")
		om += NumberByKey("OffsetOmegaManipulator", notestr, "=", "\r")
		Variable EF = NumberByKey("FermiLevel", notestr, "=", "\r")
		Variable signConventions = NumberByKey("AngleSignConventions", notestr, "=", "\r")

		if (stringmatch(manipulator,"flip") == 0 && stringmatch(manipulator,"Fadley") == 0)
			Abort "BZ Pos currently is only implemented for flip type manipulators."
			return 0
		endif

		Variable kvac = sqrt(EF) * 0.5123

		NVAR nTicks = root:internalUse:DC:gv_d_nTicks
		NVAR canonTickStart = root:internalUse:DC:gv_d_canonTickStart
		NVAR canonTickDelta = root:internalUse:DC:gv_d_canonTickDelta
		NVAR tickMode = root:internalUse:DC:gv_d_tickMode

		String M_fullpath = GetWavesDataFolder(M, 2)
		String M_xNames_fullpath = M_fullpath + "_xNames"
		String M_xTicks_fullpath = M_fullpath + "_xTicks"
		
		Variable numTicks
		switch(tickMode)
			case DC_TICK_MODE_TICKS:
				numTicks = nTicks
				Make/O/T/N=(numTicks) $M_xNames_fullpath
				WAVE/T M_xNames = $M_xNames_fullpath
				Make/O/N=(numTicks) $M_xTicks_fullpath
				WAVE M_xTicks = $M_xTicks_fullpath
				Variable i
				for(i = 0; i < numTicks; i+= 1)
					M_xTicks[i] = ( utils_x1(M) - utils_x0(M) ) / numTicks * (i + 0.5) + utils_x0(M)
				endfor
				break
			case DC_TICK_MODE_CANONICAL:
				numTicks = 0
				Make/O/T/N=(0) $M_xNames_fullpath
				WAVE/T M_xNames = $M_xNames_fullpath
				Make/O/N=(0) $M_xTicks_fullpath
				WAVE M_xTicks = $M_xTicks_fullpath
				carpetStyle__BZpos(th,al,ph,om,utils_pnt2x(M, 0), gamma, signConventions, kvac)
				NVAR V_kx, V_ky
				Variable old_kx = V_kx, old_ky = V_ky
				carpetStyle__BZpos(th,al,ph,om,utils_pnt2x(M, 1), gamma, signConventions, kvac)
				NVAR V_kx, V_ky
				Variable di = (10^(-nPrec)) / max(abs(V_kx - old_kx), abs(V_ky - old_ky)) / 5
				
				for (i = 1; i < DimSize(M, 0); i += di)
					carpetStyle__BZpos(th,al,ph,om,utils_pnt2x(M, i), gamma, signConventions, kvac)
					NVAR V_kx, V_ky
					NVAR useKx = root:internalUse:DC:gv_d_tickUseKx
					NVAR useKy = root:internalUse:DC:gv_d_tickUseKy
					Variable kx_diff = (utils_mod(V_kx-canonTickStart, canonTickDelta) - utils_mod(old_kx-canonTickStart, canonTickDelta))
					Variable ky_diff = (utils_mod(V_ky-canonTickStart, canonTickDelta) - utils_mod(old_ky-canonTickStart, canonTickDelta))
					if ( ((abs(kx_diff) > canonTickDelta / 2) && useKx) || ((abs(ky_diff) > canonTickDelta / 2) && useKy) )
						numTicks += 1
						Redimension/N=(numTicks) M_xNames
						Redimension/N=(numTicks) M_xTicks
						M_xTicks[numTicks-1] = utils_pnt2x(M, i)
					endif
					old_kx = V_kx
					old_ky = V_ky
				endfor
				break
		endswitch
		
		NVAR kxCompact = root:internalUse:DC:gv_d_tickKxCompact
		NVAR kyCompact = root:internalUse:DC:gv_d_tickKyCompact
		
		for (i = 0; i < numTicks; i+= 1)
			carpetStyle__BZpos(th,al,ph,om,M_xTicks[i], gamma, signConventions, kvac)
			NVAR V_kx, V_ky
			String str = ""
			if (kxCompact)
				// BUGFIX: Igor's sprintf does not behave as documented (or vaguely as POSIX
				// as Igor claims: 
				Variable f = (round(V_kx * 10^nPrec)/10^nPrec)
				Variable nDigits
				for (nDigits = nPrec; f == (round(V_kx * 10^(nDigits-1))/10^(nDigits-1)); )
					nDigits -= 1
				endfor
				sprintf str, "(%.*f,", nDigits, f
			else
				sprintf str, "(%.*f,", nPrec, V_kx
			endif
			if (kyCompact)
				// BUGFIX: Igor's sprintf does not behave as documented (or vaguely as POSIX
				// as Igor claims: 
				f = (round(V_ky * 10^nPrec)/10^nPrec)
				for (nDigits = nPrec; f == (round(V_ky * 10^(nDigits-1))/10^(nDigits-1)); )
					nDigits -= 1
				endfor
				sprintf str, "%s%.*f)", str, nDigits, f
			else
				sprintf str, "%s%.*f)", str, nPrec, V_ky
			endif
			M_xNames[i] = str
		endfor
		ModifyGraph userticks(bottom)={$M_xTicks_fullpath,$M_xNames_fullpath}
	endif

	Label/Z left DC_axisLabel(notestr,"y")
	Label/Z bottom DC_axisLabel(notestr,"x")
	
	// This is a bit dirty, since it overrides the DC_axisLabel that was already set.
	// The reason to introduce yet a second place to alter the axis label is that I am not really
	// applying any mapping. I am just adding a new axis text. That is different from setting 
	// AngleMapping in the wave. F.S.
	NVAR lattice_a = root:internalUse:DC:gv_lattice_a
	NVAR lattice_b = root:internalUse:DC:gv_lattice_b

	if (bzPos)
		if (lattice_a != 0 && lattice_b != 0)
			Label/Z bottom "BZ Pos (\F'Symbol'p\F'Arial'/a)"
		else
			Label/Z bottom "BZ Pos (1/Å)"
		endif
	endif

	ModifyGraph tickUnit=1
	// filename and angles
	add_textbox(M)
	
End



Static Function try_add_LDA(w_image, [windowname])
	String windowname
	WAVE w_image
	if(ParamIsDefault(windowname))
		windowname = "DC_panel"
	endif
	
	String LDAtraces = TraceNameList(windowname, ";", 1)
	Variable i
	For(i = 0; i < ItemsInList(LDAtraces); i += 1)
		if (stringmatch(StringFromList(i, LDAtraces), "w_lda*"))
			RemoveFromGraph $(StringFromList(i, LDAtraces))
			WAVE w = TraceNameToWaveRef(windowname, StringFromList(i, LDAtraces))
			KillWaves/Z w
		endif
	EndFor
	if (!waveexists(w_image))
		return 0
	endif
	
	WAVE/T w_LDAlist = root:internalUse:DC:w_LDAlist
	if (DimSize(w_LDAlist, 0) <= 1 && stringmatch(w_LDAlist[0][0], "_none") == 1)
		return 0
	endif
	
	String notestr = note(w_image)
	String manipulator = StringByKey("ManipulatorType", notestr, "=", "\r")
	String eScale = StringByKey("EnergyScale", notestr, "=", "\r")
	String angleMapping = StringByKey("AngleMapping", notestr, "=", "\r")
	angleMapping = angleMapping[0, min(strlen(angleMapping) - 1, 5)]
		
	Variable gamma = NumberByKey("ScientaOrientation",notestr,"=","\r")
	Variable al = NumberByKey("InitialAlphaAnalyzer", notestr, "=", "\r")
	Variable th = NumberByKey("InitialThetaManipulator", notestr, "=", "\r")
	th  += NumberByKey("OffsetThetaManipulator", notestr, "=", "\r")
	Variable ph = NumberByKey("InitialPhiManipulator", notestr, "=", "\r")
	ph += NumberByKey("OffsetPhiManipulator", notestr, "=", "\r")
	Variable om = NumberByKey("InitialOmegaManipulator", notestr, "=", "\r")
	om += NumberByKey("OffsetOmegaManipulator", notestr, "=", "\r")
	Variable EF = NumberByKey("FermiLevel", notestr, "=", "\r")
	Variable hn = NumberByKey("PhotonEnergy", notestr, "=", "\r")
	Variable workfunc = NumberByKey("WorkFunction", notestr, "=", "\r")
	Variable signConventions = NumberByKey("AngleSignConventions", notestr, "=", "\r")

	Variable energy = hn - workfunc

	Variable kvac = sqrt(energy) * 0.5123

	Make/O/N=(DimSize(w_image, 0)) root:internalUse:DC:interp_kx = NaN
	Make/O/N=(DimSize(w_image, 0)) root:internalUse:DC:interp_ky = NaN
	WAVE interp_kx = root:internalUse:DC:interp_kx
	WAVE interp_ky = root:internalUse:DC:interp_ky
	if (stringmatch(manipulator,"flip") || stringmatch(manipulator,"Fadley"))
		for (i = 0; i < DimSize(w_image, 0); i += 1)
			Variable beta = utils_pnt2x(w_image, i)
			globals_flip_ang2k(th,al,ph,om,beta,gamma, signs=signConventions)
			NVAR V_kx, V_ky
			interp_kx[i] = V_kx * kvac
			interp_ky[i] = V_ky * kvac
		endfor
		NVAR gv_ldaunits_piA = root:internalUse:DC:gv_ldaunits_piA
		NVAR gv_lattice_a = root:internalUse:DC:gv_lattice_a
		NVAR gv_lattice_b = root:internalUse:DC:gv_lattice_b
		if (gv_ldaunits_piA == 1) // lda bands are in units of pi/a, need to convert into pi/A
			if ((gv_lattice_a != 0) && (gv_lattice_b != 0))
				interp_kx *= pi / gv_lattice_a
				interp_ky *= pi / gv_lattice_b
			else
				interp_kx *= pi
				interp_ky *= pi
			endif
		endif
		for (i = 0; i < DimSize(w_LDAlist, 0); i += 1)
			String tracename = "root:internalUse:DC:w_lda"+num2istr(i)
			Make/O/N=(DimSize(w_image, 0)) $tracename = NaN
			WAVE w_trace = $tracename
			SetScale/P x, DimOffset(w_image,0), DimDelta(w_image, 0), w_trace
			SVAR src_wave = root:internalUse:panelcommon:gs_sourcePathList
			Note/K w_trace, "LDAWave="+w_LDAlist[i][0]+"\rCutWave="+src_wave+"\r"
			WAVE w_lda = $(w_LDAlist[i][0])
			Variable EF_lda = NumberByKey("FermiEnergy", note (w_lda), "=", "\r")
			if (numtype(EF_lda) != 0) // If there is no EF defined in the LDA, silently ignore it (i.e. set to 0)
				EF_lda = 0
			endif
			w_trace = interp2d(w_lda, interp_kx, interp_ky)
			NVAR gv_ldaunits_EF = root:internalUse:DC:gv_ldaunits_EF
			if(gv_ldaunits_EF)
				w_trace *= -1
			endif
			Variable scale = str2num(w_LDAlist[i][1])
			Variable offset = str2num(w_LDAlist[i][2])
			WaveStats/Q w_lda
			w_trace = (w_trace[p] - V_avg) * scale + offset + V_avg - EF_lda
			if (Stringmatch(eScale,"kinetic"))
				w_trace += EF
			endif
			NVAR gv_ldacutE = root:internalUse:DC:gv_ldacutE
			if (gv_ldacutE)
				Variable minE = utils_y0(w_image)
				Variable maxE = utils_y1(w_image)
				w_trace = ((w_trace[p] < minE) || (w_trace[p] > maxE)) ? NaN : w_trace[p]
			endif
			if(stringmatch(windowname, "DC_panel"))
				AppendToGraph/B=image_m/L=image_en/W=$(windowname) $tracename
			else
				AppendToGraph/W=$(windowname) $tracename
			endif
		Endfor
	endif
End


// add/remove textbox to/from current top-graph
Static Function add_textbox(w)
	WAVE w
	
	if (waveexists(w))
		ControlInfo/W=DC_panel car_cbaddFName; Variable file_flag = v_value
		ControlInfo/W=DC_panel car_cbaddAngles; Variable angle_flag = v_value
		String noteStr = note(w)
		String fileName = StringByKey("FileName", noteStr, "=", "\r")
		Variable th = NumberByKey("InitialThetaManipulator", noteStr, "=", "\r")
		th += NumberByKey("OffsetThetaManipulator", noteStr, "=", "\r")
		Variable ph = NumberByKey("InitialPhiManipulator", noteStr, "=", "\r")
		ph += NumberByKey("OffsetPhiManipulator", noteStr, "=", "\r")
	
		String text = ""
		TextBox/K /N=text13
		if (file_flag)
			text += "\\Z09"+fileName
			if (angle_flag)
				text += "\r"
			endif
		endif
		if (angle_flag)
			sprintf text, "%s\\Z09th=%.2f; ph=%.2f", text, th, ph
		endif
		if (file_flag || angle_flag)
			ControlInfo/W=DC_display_panel car_p1
			TextBox/C/N=text13/A=LB text
			TextBox/C/N=text13/F=0/B=1/G=(v_red, v_green, v_blue)
			TextBox/C/N=text13/X=3.00/Y=3.00
			if (stringmatch(WinName(0,1),"DC_panel"))
				TextBox/C/N=text13/X=3.00/Y=45.00
			endif
		endif
	else
		return 0
	endif
End
