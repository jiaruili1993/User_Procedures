#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.00
#pragma IgorVersion = 5.0
#pragma ModuleName = panelcommon

















//////////////////////////////////////
//
// Public functions
//
//////////////////////////////////////














// this is executed whenever any cursors on any graphs are moved...
Function CursorMovedHook(info)
	String info
	
	String graphName = StringByKey("GRAPH",info,":",";")
	String cursorName = StringByKey("CURSOR",info,":",";")
	updateCursorInfo(cursorName, graphName=graphName)
End



// create the waves: w_DF, w_sourceNames, w_sourceNamesSel in: 'root:internalUse:panelcommon'
// called by init_norm_panel, i.e. when the normalization-panel or the gold-panel is created
Function panelcommon_srcListBoxInit()

	String DF = getdatafolder (1)
	SetDataFolder root:internalUse:panelcommon
	
	String/G gs_currentDF 	//= "root:carpets:rawData:"	// default to start with
	String/G gs_sourcePathList = ""
	String/G gs_sourceNameList = ""
	String/G gs_TopItemPath
	String/G gs_TopItemName
	
	String List, name
	
	// textwaves for the source list-boxes
	List = utils_getFolderList("root",match="!*internal*",dim=2)	// all folders which do not match to *internal* and contain 2D waves
	if (strlen(list) >= 1)
	
		utils_stringList2wave(List)
		duplicate/o/t w_StringList w_DF
		KillWaves/z w_StringList
		gs_currentDF = w_DF[0]
		SetDataFolder $gs_currentDF	
		List = wavelist("*",";", "DIMS:2")
		
		SetDataFolder root:internalUse:panelcommon
		utils_stringList2wave(SortList(list))
		Duplicate/o/t w_stringList w_sourceNames
		Make/o/n=(numpnts(w_sourceNames))/b w_sourceNamesSel=0
		
	
		// update the strings	
		Variable i=0
		do
			//if (w_sourceNamesSel[i] == 1)
				name = w_sourceNames[i]
				gs_sourcenameList += name+";"
				gs_sourcePathList += gs_currentDF+name+";"
			//endif
		i += 1
		while (i < numpnts(w_sourceNamesSel))
		gs_TopItemPath = StringFromList(0,gs_sourcePathList)
		gs_TopItemName = StringFromList(0,gs_sourcenameList)
		w_sourceNamesSel[0]=1
	else
		Make/o/n=0/b w_sourceNamesSel=0
	endif
	
	setdatafolder $DF
End




// update the list-box waves, and the following global strings in 'root:internalUse:panelcommon':
// gs_currentDF: selected folder in the folder listbox
// gs_sourcePathList: string-list with pathes to all selected waves
// gs_sourceNameList: names of all selected waves
// gs_TopItemPath: first selected wave
// gs_TopItemName: its name
// finally execute a function which must have the name of the calling panel + "_SLB_proc"
// the calling controls can have any name and be either on a graph or panel		FB 07/30/03
Function panelcommon_srcListBoxProc(ctrlname, row, col, event)
	String ctrlName
	Variable row
	Variable col
	Variable event
	
	String fList, wList,name
	
	String Df0 = getdatafolder (1)
	//print event
	if(event == 1 || event == 4 || event == 5)	// click in the control or select a row
	
		SetDatafolder root:internalUse:panelcommon
		WAVE/t w_DF; WAVE/t w_sourceNames; WAVE/b w_sourceNamesSel
		SVAR pList = gs_sourcePathList
		SVAR nList = gs_sourceNameList
		SVAR topPath = gs_TopItemPath
		SVAR topName = gs_TopItemName
		SVAR DF = gs_currentDF
		
		// click in the DF - box -> update the current DF
		ControlInfo $ctrlName
		Variable DFswitch = stringmatch(s_value,"w_DF")
		if (DFswitch)	// folder control
			DF = w_DF[v_value]
		endif
			
		// update folder-list
		fList = utils_getFolderList("root",match="!*internal*",dim=2)	// all folders which do not match to *internal*
		utils_stringList2wave(fList)
		WAVE/t w_Stringlist
		duplicate/o/t w_StringList root:internalUse:panelcommon:w_DF
			
		// update wave-list
		SetDataFolder $DF
		wList = wavelist("*",";", "DIMS:2")
		SetDatafolder root:internalUse:panelcommon
		utils_stringList2wave(SortList(wlist))
		Duplicate/o w_stringList root:internalUse:panelcommon:w_sourceNames
		Make/o/n=(numpnts(w_sourceNames))/b w_sourceNamesSel
		Killwaves/z w_stringList
	
		if (DFswitch)
			w_sourceNamesSel = 0
			w_sourceNamesSel[0] = 1
		endif
		
		// update the strings	
		if (event == 4 || event == 5)	
			Variable i=0
			pList = ""
			nList = ""
			do
				if (w_sourceNamesSel[i] == 1)		// list with all selected items
					name = w_sourceNames[i]
					nList += name+";"
					pList += DF+name+";"
				endif
			i += 1
			while (i < numpnts(w_sourceNamesSel))
			
			//i = 0	// first active item
			//do
			//	if (w_sourceNamesSel[i] == 1)
					topPath = StringFromList(0,pList)
					topName = StringFromList(0,nList)
			//		break
			//	endif
			//i += 1
			//while (i < numpnts(w_sourceNamesSel))
			endif
		endif
		
		//ControlUpdate waves_lb
	SetDataFolder $Df0
	
	// execute the function for the panel specific stuff (if it exists)
	if (event == 4)	// do not update for multiple selections (changed 01-05-04)	 || event == 5)
		String cmd = WinName(0,65)+"_SLB_proc"		// top graph OR panel
		if (strlen (FunctionList(cmd,";","KIND:2")) > 0)	// function exists
			execute cmd+"()"
			// Execute is EVIL. It is not clear where in the command queue your stuff gets
			// inserted. To make sure that all modifications punch through before returning 
			// to the script, I inserted a Sleep and a DoUpdate here:
			Sleep/T 2
			DoUpdate
		endif
		bzplanner_updateFromCommonPanel()
	endif
	
	//print event
	return 0
End




Function panelcommon_addImage(panelName)
	String panelName
	
	String Df = getdatafolder (1)
	//setdatafolder root:internalUse:panelcommon
	//SVAR path = gs_TopItemPath
	//WAVE w_image; WAVE n_mdc; WAVE n_edc; WAVE n_edc_x
	if (waveexists(root:internalUse:panelcommon:w_image) == 0)
		panelcommon_makeNaNWaves()
	endif
	
	setdatafolder root:internalUse:panelcommon
	//SVAR path = gs_TopItemPath
	WAVE w_image; WAVE n_mdc; WAVE n_edc; WAVE n_edc_x
	
	//RemoveFromGraph/Z temp_EDC
	AppendToGraph/Q/L=edc_en/T=edc_int n_edc_x vs n_edc
	AppendToGraph/Q n_mdc
	AppendImage/T=image_m/L=image_en w_image
	//added by Wei-Sheng 0407/05
	ModifyImage w_image ctab= {*,*,Terrain,0}
	
	ShowInfo; Cursor/P/I/H=1 B w_image 20,20
	
	ModifyGraph margin(left)=36,margin(bottom)=22,margin(top)=18
	ModifyGraph gfSize=10
	ModifyGraph btLen=3,stLen=2
	
	ModifyGraph rgb(n_mdc)=(1,16019,65535),rgb(n_edc_x)=(1,26214,0)

	ModifyGraph nticks(image_m)=0, nticks(image_en)=0
	ModifyGraph noLabel(image_m)=2
	ModifyGraph axThick(image_m)=0,axThick(image_en)=0
	
	ModifyGraph freePos(edc_en)={0,edc_int}
	//ModifyGraph freePos(edc_int)={0,edc_en}
	ModifyGraph freePos(edc_int)={Inf,edc_en}
	ModifyGraph freePos(image_en)=0
	ModifyGraph freePos(image_m)={0,image_en}
	ModifyGraph axisEnab(left)={0,0.38},axisEnab(bottom)={0,0.55}
	ModifyGraph axisEnab(edc_en)={0.42,1},axisEnab(edc_int)={0.65,1}
	ModifyGraph axisEnab(image_en)={0.42,1},axisEnab(image_m)={0,0.55}
	TextBox/A=RB/X=.2/Y=.2/Z=1/N=waveInfoTextBox
	
	Label image_en "\\u#2"
	//AddPlotFrame()
	
	SetDataFolder $DF
End




Function panelcommon_makeNaNWaves()

	String Df = getdatafolder (1)
	Setdatafolder root:internalUse:panelcommon
		Make/o/n=(10,10) w_image=nan
		Duplicate/o w_image w_image_u1, w_image_u2		// the 'undo' images
		Make/N=10/O n_mdc, n_mdc2, w_norm
		Make/N=10/O n_edc, n_edc2, n_edc_x
	
	SetDataFolder $DF
End





// modified 06-16-04
// collapses and uncollapses (i.e. integrates) now both DCs in the Display panel 
// modified 12-17-04  for additional "between cursors" box in the display panel
Function panelcommon_checkBoxIntEorK(ctrlName,checked)
	String ctrlName
	Variable checked
	
	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse:panelcommon
	
	WAVE n_edc; WAVE w_image
	String topGraphName = WinName(0,1)
	
	Variable aExists= strlen(CsrInfo(A)) > 0
	Variable bExists= strlen(CsrInfo(B)) > 0
	Variable DCpanel = stringmatch(topGraphName,"DC_panel")
	Variable x0, x1, y0, y1
	Variable csrCheck, eCollapse, kCollapse
	
	if (! bExists)
		ShowInfo; Cursor/P/I/H=1 B w_image 20,20
	endif
	if (DCpanel)
		if (aExists == 0)
			ShowInfo; Cursor/P/I/H=1 A w_image 10,10
		endif
		ControlInfo n_check4
		csrCheck = v_value
		x0 = dimoffset(w_image,0) + pcsr(A,topGraphName) * dimdelta(w_image,0)
		x1 = dimoffset(w_image,0) + pcsr(B,topGraphName) * dimdelta(w_image,0)
		y0 = dimoffset(w_image,1) + qcsr(A,topGraphName) * dimdelta(w_image,1)
		y1 = dimoffset(w_image,1) + qcsr(B,topGraphName) * dimdelta(w_image,1)
	endif
	
	ControlInfo n_check2
	eCollapse = v_value
	ControlInfo n_check3
	kCollapse = v_value

	
	if (kCollapse)	// collapse k
		if (csrCheck)
			utils_getWaveAvg(w_image, 1, from=x0, to=x1)
		else
			utils_getWaveAvg(w_image,1)
		endif
		WAVE w_avg
		Duplicate/o w_avg n_edc, n_edc2
	else
		n_edc = w_image[pcsr(B,topGraphName)][p]
		if (DCpanel)
			n_edc2 = w_image[pcsr(A,topGraphName)][p]
		endif
	endif
		
	if (eCollapse)
		if (csrCheck)
			utils_getWaveAvg(w_image, 0, from=y0, to=y1)
		else
			utils_getWaveAvg(w_image,0)
		endif
		WAVE w_avg
		Duplicate/o w_avg n_mdc, n_mdc2
	else
		n_mdc = w_image[p][qcsr(B,topGraphName)]
		if (DCpanel)
			n_mdc2 = w_image[p][qcsr(A,topGraphName)]
		endif
	endif
	
	SetDataFolder $DF
End




// Locks the DC intensity scale in the display panels.
Function panelcommon_checkBoxLockInt(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	String topGraphName = WinName(0,1)
	
	if (checked)
		GetAxis/q/w=$topGraphName edc_int
		SetAxis edc_int v_min,v_max
		
		GetAxis/q/w=$topGraphName left
		SetAxis left v_min,v_max
	else
		SetAxis/A edc_int
		SetAxis/A left
	endif
end




// sets global variables V_kx and V_ky to the 
// current kx, ky values of the current cursor on the image/panel
// of the active panel. If not alll the neccessary fields are defined
// on the wave, V_kx and V_ky will be set to NaN and the 
// function returns 0. Returns 1 on success.
// The current energy position of the cursor will be used to determine
// kx, ky; so, if you want it at EF, set the cursors there.
// This is a convenience function; alternatively, you could also
// read out V_kx_csrA, V_ky_csrA, V_kx_csrB and V_ky_csrB
// directly. But the pproblem is that the cursor might be stale
// when you do this directly, i.e. the user might have changed the
// focus to another window, and then the cursor values you get are
// wrong. So, use this function instead since it makes sure the 
// cursor values are up to date.
//
// The kx, ky are in units of inverse Angstroms.
//
// CursorName is a string; can be either "A" or "B".
Function panelcommon_bzPosFromCursor(CursorName)
	String CursorName
	Variable/G V_kx=NaN, V_ky=NaN
	updateCursorInfo(CursorName)
	NVAR kx = root:internalUse:panelcommon:$("V_kx_csr"+CursorName)
	NVAR ky = root:internalUse:panelcommon:$("V_ky_csr"+CursorName)
	V_kx = kx
	V_ky = ky
	return (numtype(kx) == 0 && numtype(ky) == 0)
End




// Returns the BZ angle for the current cursor on the graph. Calls 
// panelcommon_bzPosFromCursor.
// The returned angle is either NaN if relevant information in the 
// wave is missing or something else goes wrong, or the value 
// of the BZ angle, in radian units.
//
// CursorName is a string; can be either "A" or "B".
// 
// if degrees is set to 1, units are in degrees instead of radian.
// Default is 0 (radian units)
//
// kx_center, ky_center determine the center from which to measure
// the BZ angle. In units of inverse Angstroms.
Function panelcommon_bzAngleFromCursor(CursorName, kx_center, ky_center, [degrees])
	String CursorName
	Variable kx_center, ky_center
	Variable degrees
	
	Variable/G V_kx=NaN, V_ky=NaN
	updateCursorInfo(CursorName)
	NVAR kx = root:internalUse:panelcommon:$("V_kx_csr"+CursorName)
	NVAR ky = root:internalUse:panelcommon:$("V_ky_csr"+CursorName)
	if (numtype(kx) != 0 || numtype(ky) != 0)
		return NaN
	endif
	Variable angle = atan((kx - kx_center) / (ky - ky_center))
	if (degrees == 1)
		angle *= 180/pi
	endif
	return angle
End













//////////////////////////////////////
//
// Private functions
//
//////////////////////////////////////














Static Function updateCursorInfo(cursorName, [graphName])
	String graphName, cursorName
	if (ParamIsDefault(graphName))
		graphName=StringFromList(0, WinList("*_panel", ";", "WIN:65"))
	endif
	
	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse:panelcommon


	WAVE w_image = w_image
	WAVE n_edc = n_edc
	WAVE n_edc2 = n_edc2
	WAVE n_mdc = n_mdc
	WAVE n_mdc2 = n_mdc2
		
	if (stringmatch(graphName,"norm_panel") || stringmatch(graphName,"gold_panel")|| stringmatch(graphName,"process_panel")|| stringmatch(graphName,"merge_panel"))
		Checkbox n_check3, value = 0
		
		if (stringmatch(cursorName,"B"))
			Variable xPoint = pcsr(B, graphName)//NumberByKey("POINT",info,":",";")
			Variable yPoint = qcsr(B, graphName)//NumberByKey("YPOINT",info,":",";")
			n_mdc = w_image[p][yPoint]
			n_edc = w_image[xPoint][p]
			updateWInfoTextBox(w_image, xPoint, yPoint, "B", graphName)
			KillVariables/Z V_kx_csrB, V_ky_csrB
			Rename V_kx, V_kx_csrB
			Rename V_ky, V_ky_csrB
			Variable/G V_kx_csrB
			Variable/G V_ky_csrB
			NVAR kx = V_kx_csrB
			NVAR ky = V_ky_csrB
			NVAR V_kx, V_ky
			kx = V_kx
			ky = V_ky
			KillVariables/Z V_kx, V_ky
		endif
		// there should not be a reading for cursor A, since it does not neccessarily
		// have to be on the graph and the info is also not updated for it:
		Variable/G V_kx_csrA
		Variable/G V_ky_csrA
		NVAR kx = V_kx_csrA
		NVAR ky = V_ky_csrA
		kx = 0
		ky = 0
		
	elseif(stringmatch(graphName,"DC_panel"))
		Checkbox n_check3, value = 0
		ControlInfo DCs_cbEDC	// EDCs/MDCs

		NVAR first = root:internalUse:disp:gv_first
		NVAR last = root:internalUse:disp:gv_last
		NVAR step = root:internalUse:disp:gv_step
		
		if (stringmatch(cursorName,"B"))
			xPoint = pcsr(B, graphName)//NumberByKey("POINT",info,":",";")
			yPoint = qcsr(B, graphName)//NumberByKey("YPOINT",info,":",";")
			if (v_value)
				last = xPoint//xPoint	//NumberByKey("POINT",info,":",";")
			else
				last = yPoint//yPoint	//NumberByKey("YPOINT",info,":",";")
			endif
			n_mdc = w_image[p][yPoint]
			n_edc = w_image[xPoint][p]
			updateWInfoTextBox(w_image, xPoint, yPoint, "B", graphName)
		
		elseif (stringmatch(cursorName,"A"))
			xPoint = pcsr(A, graphName)//NumberByKey("POINT",info,":",";")
			yPoint = qcsr(A, graphName)//NumberByKey("YPOINT",info,":",";")
			if (v_value)
				first = xPoint//xPoint	//NumberByKey("POINT",info,":",";")
			else
				first = yPoint//yPoint	//NumberByKey("YPOINT",info,":",";")
			endif
			n_mdc2 = w_image[p][yPoint]
			n_edc2 = w_image[xPoint][p]
			updateWInfoTextBox(w_image, xPoint, yPoint, "A", graphName)
		endif
		Variable/G $("V_kx_csr"+cursorName)
		Variable/G $("V_ky_csr"+cursorName)
		NVAR kx = $("V_kx_csr"+cursorName)
		NVAR ky = $("V_ky_csr"+cursorName)
		NVAR V_kx, V_ky
		kx = V_kx
		ky = V_ky
		KillVariables/Z V_kx, V_ky

	
		if (last < first)
			step = -(abs(step))
		else
			step = abs(step)
		endif
		ControlUpdate DCs_sv0
		ControlUpdate DCs_sv1
		ControlUpdate DCs_sv2
	else // No known panels active/called. Need to update cursors to NaN's
		Variable/G V_kx_csrA = NaN, V_ky_csrA = NaN, V_kx_csrB = NaN, V_ky_csrB = NaN
		SetDataFolder $DF
		return 1
	endif
	SetDataFolder $DF
End





Static Function updateWInfoTextBox(w_image, xpos, ypos,csrString, graphName)
	WAVE w_image
	Variable xpos, ypos
	String csrString
	String graphName
	
	Variable en = utils_pnt2y(w_image, ypos)
	Variable beta = utils_pnt2x(w_image, xpos)

	String winfo = "\f04Wave info csr("+csrString+")\f00                   \Z04\r\r\Z08"

	String notestr = note(w_image)
	String manipulator = StringByKey("ManipulatorType", notestr, "=", "\r")
	String eScale = StringByKey("EnergyScale", notestr, "=", "\r")
	String angleMapping = StringByKey("AngleMapping", notestr, "=", "\r")
	angleMapping = angleMapping[0, min(strlen(angleMapping) - 1, 5)]
	sprintf winfo, "%s%s, %s, Angle-Map: %s\r", winfo, manipulator, eScale, angleMapping
		
	Variable gamma = NumberByKey("ScientaOrientation",notestr,"=","\r")
	Variable al = NumberByKey("InitialAlphaAnalyzer", notestr, "=", "\r")
	Variable th = NumberByKey("InitialThetaManipulator", notestr, "=", "\r")
	th  += NumberByKey("OffsetThetaManipulator", notestr, "=", "\r")
	Variable ph = NumberByKey("InitialPhiManipulator", notestr, "=", "\r")
	ph += NumberByKey("OffsetPhiManipulator", notestr, "=", "\r")
	Variable om = NumberByKey("InitialOmegaManipulator", notestr, "=", "\r")
	om += NumberByKey("OffsetOmegaManipulator", notestr, "=", "\r")
	sprintf winfo, "%stheta: %.2f; phi: %.2f; om:%.2f\r", winfo, th, ph, om
	sprintf winfo, "%sal: %.2f; ga: %.2f; be: %.2f\r", winfo, al, gamma, beta
	Variable EF = NumberByKey("FermiLevel", notestr, "=", "\r")
	Variable hn = NumberByKey("PhotonEnergy", notestr, "=", "\r")
	Variable workfunc = NumberByKey("WorkFunction", notestr, "=", "\r")
	sprintf winfo, "%sEF: %.3f; h\F'Symbol'n\F'Arial': %.3f; \F'Symbol'F\F'Arial': %.3f\r", winfo, EF, hn, workfunc
	Variable signs = NumberByKey("AngleSignConventions", notestr, "=", "\r")

	Variable energy = NaN
	if (Stringmatch(eScale,"kinetic"))
		energy = hn-EF+ en - workfunc
	elseif (stringmatch(eScale,"Initial*"))
		energy = hn + en - workfunc
	endif

	Variable kvac = sqrt(energy) * 0.5123

	if (stringmatch(manipulator,"flip") || stringmatch(manipulator,"Fadley"))
		globals_flip_ang2k(th,al,ph,om,beta,gamma, signs=signs)
		NVAR V_kx, V_ky
		V_kx *= kvac
		V_ky *= kvac
		sprintf winfo, "%skx: %.4f[1/Å]; ky: %.4f[1/Å]",winfo, V_kx, V_ky
	else
		sprintf winfo, "%skx: %.4f[1/Å]; ky: %.4f[1/Å]",winfo, NaN, NaN
		Variable/G V_kx=NaN, V_ky=NaN
	endif
	if (WhichListItem("waveInfoTextBox", AnnotationList(graphName)) != -1)
		ReplaceText/W=$(graphName)/N=waveInfoTextBox winfo
	endif
End
