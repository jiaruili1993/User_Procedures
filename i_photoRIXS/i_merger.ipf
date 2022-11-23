#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 2.00
#pragma IgorVersion = 5.0
#pragma ModuleName = merger




















//////////////////////////////////////
//
// Public functions
//
//////////////////////////////////////

























Function merger_open(ctrlName)
	String ctrlName
	
	init()
	
	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse:merger
	
	DoWindow/K merger_panel
	Display/K=1 as "merge panel"
	DoWindow/C merger_panel
	utils_resizeWindow("merger_panel",510,565)
	utils_autoPosWindow("merger_panel", win=127)
	String cmd = "ControlBar 213"
	execute cmd
	
	Variable r=57000, g=57000, b=57000	// background color for the TabControl
	ModifyGraph cbRGB=(42428,42428,42428)
	ModifyGraph wbRGB=(63000,64000,55000),gbRGB=(63000,64000,55000)
	
	// controls that do not depend on the tabs
	//CheckBox n_check0, pos={20,197}, title="suppress par. update"
	CheckBox n_check1, pos={20,197}, title="lock DC-intensity scale", proc=panelcommon_checkBoxLockInt
	CheckBox n_check2, pos={340,197}, title="integrate E", proc=panelcommon_checkBoxIntEorK
	CheckBox n_check3, pos={420,197}, title="integrate k", proc=panelcommon_checkBoxIntEorK
	

	// --------------------------tab-controls -----------------
	// source tab
	TabControl merge,proc=merger#tabControlChange,pos={8,6},size={494,190},tabLabel(0)="source/dest",value=0,labelBack=(r,g,b), fsize=12
	Listbox sou_lb0,listwave=w_sourcePathes,size={248,95},pos={24,45}, frame=2,editstyle=0,mode=1
	Groupbox sou_gb0, size={248,40},pos={24,145}	//,title="source"
	Button sou_b1,pos={63,155},size={70,18},labelBack=(r,g,b),title="add", proc = merger#buttonAddCarpetsToMerge
	Button sou_b2,pos={163,155},size={70,18},labelBack=(r,g,b),title="remove", proc = merger#buttonDelCarpetsToMerge
	
	Groupbox sou_gb10, size={204,150},pos={284,35},title="dest.-dimension"
	CheckBox sou_c10, pos={295,55}, size={80,15},labelBack=(r,g,b),title="auto dimensions", proc=merger#checkBoxAutoDims, value = 1
	CheckBox sou_c10, help={"minimal enclosure but maximal point density of all source matrices"}
	Groupbox sou_gb11, size={204,111},pos={284,74},title="scaling"
	SetVariable sou_sv10, pos={310,94}, size={70,15},labelBack=(r,g,b),title="x_0:", value = gv_x0, limits={-Inf,Inf,0}
	SetVariable sou_sv11, pos={390,94}, size={70,15},labelBack=(r,g,b),title="x_1:", value = gv_x1, limits={-Inf,Inf,0}
	SetVariable sou_sv12, pos={310,112}, size={70,15},labelBack=(r,g,b),title="y_0:", value = gv_y0, limits={-Inf,Inf,0}
	SetVariable sou_sv13, pos={390,112}, size={70,15},labelBack=(r,g,b),title="y_1:", value = gv_y1, limits={-Inf,Inf,0}
	Groupbox sou_gb12, size={204,48},pos={284,137},title="matrix size"
	SetVariable sou_sv14, pos={296,160}, size={85,15},labelBack=(r,g,b),title="x-pnts:", value = gv_xp, limits={0,Inf,0}
	SetVariable sou_sv15, pos={391,160}, size={85,15},labelBack=(r,g,b),title="y-pnts:", value = gv_yp, limits={0,Inf,0}
	
	// merge tab
	TabControl merge,tabLabel(1)="merge"
	Listbox mer_lb0,listwave=w_mergeBox, selwave=w_mergeSel,size={462,95},pos={24,35}, frame=2, disable = 1
	Listbox mer_lb0, editstyle=0,mode=1, widths={200,40,40,40,40,40,40}, disable = 1
	Listbox mer_lb0, help={"only wimps use the help."}, disable = 1
	
	Groupbox mer_gb0, size={240,52},pos={24,135},title="options", disable=1
	CheckBox mer_c0, pos={29,151}, size={80,15},labelBack=(r,g,b),title="equalize intensities",  Variable=gv_auto_z, disable=1
	CheckBox mer_c1, pos={29,168}, size={80,15},labelBack=(r,g,b),title="use linear combination", Variable=gv_lin_comb, disable=1
	CheckBox mer_c2, pos={165,151}, size={80,15},labelBack=(r,g,b),title="use old style", Variable=gv_old_style, proc=merger#checkBoxOldStyle, disable=1
	
	NVAR gv_autoXRange
	NVAR gv_autoYRange
	NVAR gv_autoIntRange
	NVAR gv_autoNumSteps
	Button mer_b2,pos={270,146},size={40,18},labelBack=(r,g,b),title="auto", proc = merger#buttonOptimizeOffsets, disable=1
	SetVariable mer_sv0, pos={310,146}, size={45,15},labelBack=(r,g,b),title="#", value = gv_autoNumSteps,limits={-Inf,Inf,0}, disable = 1
	SetVariable mer_sv1, pos={355,146}, size={45,15},labelBack=(r,g,b),title="dx", value = gv_autoXRange,limits={-Inf,Inf,0}, disable = 1
	SetVariable mer_sv2, pos={400,146}, size={45,15},labelBack=(r,g,b),title="dy", value = gv_autoYRange,limits={-Inf,Inf,0}, disable = 1
	SetVariable mer_sv3, pos={445,146}, size={45,15},labelBack=(r,g,b),title="dI", value = gv_autoIntRange,limits={-Inf,Inf,0}, disable = 1
	Button mer_b0,pos={320,168},size={45,18},labelBack=(r,g,b),title="save:", proc=merger#buttonSaveMerged, disable=1
	Button mer_b0, help={"matrix will be saved in:\r'root:carpets:processed:'"}
	SetVariable mer_sv4, pos={370,170}, size={118,15},labelBack=(r,g,b),title=" ", value = gs_mNickName,limits={-Inf,Inf,0}, disable = 1
	Button mer_b1,pos={270,168},size={45,18},labelBack=(r,g,b),title="update", proc = merger#UpdateMerged, disable=1
	
	
	SetDataFolder $DF
	NVAR gv_old_style
	checkBoxOldStyle("", gv_old_style)
	checkBoxAutoDims("dum",1)
	
	tabControlChange("merge", 0)
	
	panelcommon_addImage("merger_panel")
End






















//////////////////////////////////////
//
// Private functions: Control Callbacks
//
//////////////////////////////////////





















Static Function tabControlChange( name, tab )
	String name
	Variable tab
	
	ControlInfo $name
	String tabStr = S_Value[0,2]
	String all = ControlNameList( "merger_panel" )
	String thisControl
	
	Variable i = 0
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
	
End





Static Function checkBoxAutoDims(ctrlName,checked)
	String ctrlName
	Variable checked

	if (checked)
		SetVariable sou_sv10, noedit=1
		SetVariable sou_sv11, noedit=1
		SetVariable sou_sv12, noedit=1
		SetVariable sou_sv13, noedit=1
		SetVariable sou_sv14, noedit=1
		SetVariable sou_sv15, noedit=1
		GroupBox sou_gb11, disable=2
		GroupBox sou_gb12, disable=2
	else
		SetVariable sou_sv10, noedit=0
		SetVariable sou_sv11, noedit=0
		SetVariable sou_sv12, noedit=0
		SetVariable sou_sv13, noedit=0
		SetVariable sou_sv14, noedit=0
		SetVariable sou_sv15, noedit=0
		GroupBox sou_gb11, disable=0
		GroupBox sou_gb12, disable=0
	endif
End





// adds new entries to the source waves
Static Function buttonAddCarpetsToMerge(ctrlName)
	string ctrlname
	
	String name, notestr
	
	WAVE/T w_sourcePathes = root:internalUse:merger:w_sourcePathes
	WAVE/T w_mergeBox = root:internalUse:merger:w_mergeBox
	WAVE w_mergeSel = root:internalUse:merger:w_mergeSel
	
	String cmd = "CreateBrowser prompt=\"select soucre data to add, and click 'ok'\""
	execute cmd
	SVAR S_BrowserList=S_BrowserList
	NVAR V_Flag=V_Flag
		if(V_Flag==0)
			return -1
		endif
	
	utils_stringList2wave(s_BrowserList)
	WAVE/T w_StringList		// generated by 'utils_stringList2wave'
	
	Variable old_pnts
	if (stringmatch(w_sourcePathes[0],"*none*"))
		old_pnts = 0
	else
		old_pnts = numpnts(w_sourcePathes)
	endif
	Variable add_pnts = numpnts(w_StringList)
	
	Redimension/N=(old_pnts+add_pnts,1) w_sourcePathes
	w_sourcePathes[old_pnts,old_pnts+add_pnts-1]=w_StringList[p-old_pnts]
	
	Redimension/N=(old_pnts+add_pnts,7) w_mergeBox, w_mergeSel
	w_mergeBox[][0] = w_sourcePathes[p]
	w_mergeBox[old_pnts,old_pnts+add_pnts-1][1,2] = "0"
	w_mergeBox[old_pnts,old_pnts+add_pnts-1][3] = "1"
	w_mergeBox[old_pnts,old_pnts+add_pnts-1][4,7] = "n"
	w_mergeSel[][1,7] = 2
	
	KillWaves/z w_stringList
	KillStrings/z s_BrowserList
end





// deletes entries from the source waves
Static Function buttonDelCarpetsToMerge(ctrlName)
	string ctrlname
	
	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse:merger
	
	WAVE/T w_sourcePathes = root:internalUse:merger:w_sourcePathes
	WAVE/T w_mergeBox = root:internalUse:merger:w_mergeBox
	WAVE/T w_mergeSel = root:internalUse:merger:w_mergeSel
	
	ControlInfo sou_lb0
	DeletePoints v_value,1, w_sourcePathes, w_mergeBox, w_mergeSel
	
	if(dimsize(w_sourcePathes,0) >= 1)
		Redimension/n=(dimsize(w_sourcePathes,0),1) w_sourcePathes
		SetDimLabel 1,0, source, w_sourcePathes
	else
		Make/n=(1,1)/o/t w_sourcePathes = "_none"
		SetDimLabel 1,0, source, w_sourcePathes
	endif
	SetDataFolder $DF
End





Static Function buttonSaveMerged(ctrlName)
	String ctrlName

	WAVE w_image = root:internalUse:panelcommon:w_image
	WAVE/T w_mergeBox = root:internalUse:merger:w_mergeBox
	SVAR mName = root:internalUse:merger:gs_mNickName
	
	//String DF = GetDataFolder (1)
	String name
	String notestr = note($w_mergeBox[0][0])
	String modification = "merged from: "
	
	Variable index = 0
	do
		name = w_mergeBox[index][0]
		modification += name+"; "
	index += 1
	while (index < dimsize(w_mergeBox,0))
	
	notestr = ReplaceStringByKey("OtherModifcations", notestr, modification,"=","\r")
	Note/K w_image
	Note w_image, notestr
	
	NewDataFolder/o root:carpets:processed
	String path =  utils_uniqueName(w_image,"root:carpets:processed:",mName, 0)
	
	//SetDataFolder $DF
	
	Duplicate/O w_image $path
End





Static Function checkBoxOldStyle(name,value)
	String name
	Variable value
	
	if (value)
		Checkbox mer_c0, disable=2
		Checkbox mer_c1, disable=2
//		Checkbox mer_c3, disable=2
	else
		Checkbox mer_c0, disable=0
		Checkbox mer_c1, disable=0
//		Checkbox mer_c3, disable=0
	endif
	
End
























//////////////////////////////////////
//
// Private functions
// N.B.: the keyword "Static" in front of "Procedure" limits visibility to the containing Igor Procedure File only.
//
//////////////////////////////////////




























// user interface for the 'merge2' function, which is also used by the mapper
//
//__________________________________________FB 12/22/03
//
// updated for the 'merge3' function
//__________________________________________FB 10/24/04
Static Function init()
	
	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse:
	NewDataFolder/O/S merger
	
	// a dummy textwave
	Make/n=(1,1)/o/t w_sourcePathes = "_none"
	SetDimLabel 1,0, source, w_sourcePathes
	Make/n=(1,7)/o/t w_mergeBox= {{"_none"},{"0"},{"0"},{"1"},{"n"},{"n"},{"n"}}
	Make/n=(1,7)/o w_mergeSel= {{0},{2},{2},{2},{2},{2},{2}}		// '2' means editable
	SetDimLabel 1,0,source, w_mergeBox
	SetDimLabel 1,1, x_off, w_mergeBox
	SetDimLabel 1,2, y_off, w_mergeBox
	SetDimLabel 1,3, int_fac, w_mergeBox
	SetDimLabel 1,4, hold_x, w_mergeBox
	SetDimLabel 1,5, hold_y, w_mergeBox
	SetDimLabel 1,6, hold_int, w_mergeBox
	
	// all the globals
	String/G gs_mNickName = "SUPERmerge"
	Variable/G gv_x0 = 0
	Variable/G gv_x1 = 1
	Variable/G gv_y0 = 0
	Variable/G gv_y1 = 1
	Variable/G gv_xp = 200
	Variable/G gv_yp = 200
	Variable/G gv_autoPoints = 1 // not in use
	Variable/g gv_dx = 0
	Variable/G gv_dy = 0
	Variable/G gv_auto_z = 0
	Variable/G gv_old_style = 0
	Variable/G gv_lin_comb = 1
	Variable/G gv_autoXRange = 5
	Variable/G gv_autoYRange = .1
	Variable/G gv_autoIntRange = 2
	Variable/G gv_autoNumSteps = 10
	
	
	SetDataFolder $DF
End






Static Function calcAutoDimensions()

	WAVE/T w_mergeBox = root:internalUse:merger:w_mergeBox
	WAVE w_image = root:internalUse:panelcommon:w_image
	NVAR x0 = root:internalUse:merger:gv_x0
	NVAR x1 = root:internalUse:merger:gv_x1
	NVAR y0 = root:internalUse:merger:gv_y0
	NVAR y1 = root:internalUse:merger:gv_y1
	NVAR xp = root:internalUse:merger:gv_xp
	NVAR yp = root:internalUse:merger:gv_yp
	
	Variable num = dimsize(w_mergeBox,0)
	Make/O/N=(num) xfrom, xto, yfrom, yto, dx, dy
	
	Variable index = 0
	do
		WAVE w = $w_mergeBox[index][0]
		xfrom[index] = min(utils_x0(w), utils_x1(w)) + str2num(w_mergeBox[index][1])
		xto[index] = max(utils_x0(w), utils_x1(w)) + str2num(w_mergeBox[index][1])
		
		yfrom[index] = min(utils_y0(w), utils_y1(w)) + str2num(w_mergeBox[index][2])
		yto[index] = max(utils_y0(w), utils_y1(w)) + str2num(w_mergeBox[index][2])
		
		dx[index] = dimdelta(w,0)
		dy[index] = dimdelta(w,1)
	
	index += 1
	while (index < num)
	
	WaveStats/Q xfrom; x0 = v_min
	WaveStats/Q xto; x1 = v_max
	WaveStats/Q yfrom; y0 = v_min
	WaveStats/Q yto; y1 = v_max
	WaveStats/Q dx
	xp = round( abs(x1-x0) / abs(v_min) )
	WaveStats/Q dy
	yp = round( abs(y1-y0) / abs(v_min) )
	
	KillWaves/Z xfrom, xto, yfrom, yto, dx, dy
End




// creates w_opt_tmp, which contains the squared difference of overlapping regions.
// returns the sum of w_opt_tmp, normalized by the total number of points that
// overlap.
Function merger_offsetOptFn(w_x)
	WAVE w_x

	WAVE/T w_mergeBox = root:internalUse:merger:w_mergeBox
	NVAR x0 = root:internalUse:merger:gv_x0
	NVAR x1 = root:internalUse:merger:gv_x1
	NVAR y0 = root:internalUse:merger:gv_y0
	NVAR y1 = root:internalUse:merger:gv_y1
	NVAR xp = root:internalUse:merger:gv_xp
	NVAR yp = root:internalUse:merger:gv_yp
//	WAVE w_image = root:internalUse:panelcommon:w_image
	calcAutoDimensions()
	Make/o/n=(xp,yp) w_opt_tmp, w_optNorm_tmp
	SetScale/I x x0,x1,"" w_opt_tmp, w_optNorm_tmp
	SetScale/I y y0, y1, "" w_opt_tmp, w_optNorm_tmp
	w_opt_tmp = 0
	w_optNorm_tmp = 0

	Variable i
	for (i = 0; i < DimSize(w_mergeBox, 0); i += 1)
		WAVE w_i = $w_mergeBox[i][0]
		Variable x_off_i = w_x[i*3]
		Variable y_off_i = w_x[i*3+1]
		Variable int_fac_i = w_x[i*3+2]
		Duplicate/O w_i, w_tmp_i
		w_tmp_i *= int_fac_i
		// BEGIN BUGFIX: when accessing a wave w with w(x)(y), and x, y, are outside the domain of w,
		// Igor returns the number which is closest to x and y, but still in the domain of w.
		// This feature is of course - you guessed it - undocumented. Setting the border of w
		// to NaN therefore returns NaN if x,y are outside of the domain of w.
		w_tmp_i[0][] = NaN
		w_tmp_i[][0] = NaN
		w_tmp_i[DimSize(w_i,0)-1][] = NaN
		w_tmp_i[][DimSize(w_i,1)-1] = NaN
		// END BUGFIX
		SetScale/P x, DimOffset(w_i,0)+x_off_i, DimDelta(w_i,0), w_tmp_i
		SetScale/P y, DimOffset(w_i,1)+y_off_i, DimDelta(w_i,1), w_tmp_i
		Variable j
		for (j = i+1; j < DimSize(w_mergeBox, 0); j += 1)
			WAVE w_j = $w_mergeBox[j][0]
			Variable x_off_j = w_x[j*3]
			Variable y_off_j = w_x[j*3+1]
			Variable int_fac_j = w_x[j*3+2]
			//print x_offset, y_offset
			Duplicate/O w_j, w_tmp_j
			w_tmp_j *= int_fac_j
			// BEGIN BUGFIX (see above)
			w_tmp_j[0][] = NaN
			w_tmp_j[][0] = NaN
			w_tmp_j[DimSize(w_j,0)-1][] = NaN
			w_tmp_j[][DimSize(w_j,1)-1] = NaN
			// END BUGFIX
			SetScale/P x, DimOffset(w_j,0)+x_off_j, DimDelta(w_j,0), w_tmp_j
			SetScale/P y, DimOffset(w_j,1)+y_off_j, DimDelta(w_j,1), w_tmp_j
			
			w_opt_tmp[][] += (numtype(w_tmp_i(x)(y))==0 && numtype(w_tmp_j(x)(y))==0) ? (w_tmp_i(x)(y)-w_tmp_j(x)(y))^2 : 0
			w_optNorm_tmp[][] += (numtype(w_tmp_i(x)(y))==0 && numtype(w_tmp_j(x)(y))==0) ? 1 : 0
		endfor
	endfor
	w_opt_tmp[][] = w_opt_tmp[p][q] / max(w_optNorm_tmp[p][q],1)
	Variable retval = sum(w_opt_tmp)
	w_opt_tmp[][] = (w_optNorm_tmp[p][q] == 0) ? NaN : w_opt_tmp[p][q]
	w_optNorm_tmp[][] = min(w_optNorm_tmp[p][q],1) // normalize by the total number of overlapping points.
	retval /= sum(w_optNorm_tmp)
	DoUpdate
	return retval
	KillWaves w_tmp_i, w_tmp_j, w_optNorm_tmp
End




Static Function buttonOptimizeOffsets(ctrlName)
	String ctrlName

	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse:merger

	WAVE/T w_mergeBox
	Make/O/N=(DimSize(w_mergeBox, 0) * 3) w_parms
	Variable/G gv_dbg = 0
	Variable i
	for (i = 0; i < DimSize(w_mergeBox, 0); i += 1)
		Variable j
		for(j = 0; j < 3; j += 1)
			w_parms[i*3+j] = str2num(w_mergeBox[i][j+1])
		endfor
	endfor

	merger_offsetOptFn(w_parms)
	WAVE w_opt_tmp
	DoWindow/F merger_panel
	AppendImage/L=image_en/T=image_m w_opt_tmp	
	
	// This is why Igor's Optimize does not work (and one more reason of why, ultimately, Igor 
	// sucks) (see also i_fsmap, the section about Precise method), and why I have wasted
	// a full day of my life trying to get it to work:
	// - simulated annealing does not work, since none of the /TSA parameters do work (all ignored)
	//	 Behavior is absolutely erratical, cooling rate is NOT controllable via /TSA, contrary to
	//	 what the docs advertize. Also, nowhere in the docs do they explain what they call
	//   "Temperature".
	// - normal optimize does not work, since they did not include a parameter that lets you adjust 
	//   the fucking minimum stepsize.
	// - setting the limits does not do shit, since they decided to ignore /XSA as well for 
	//   /M={1..2,...}, contrary to what they claim in their docs.
	// - the /F option is ignored as well. Again, not as the docs say.
	// These are just a couple of my (numerous) tries:
	// - Optimize/M={3,0}/TSA={1,1e-5}/X=w_opt_parms/XSA=w_limits,  merger_offsetOptFn, w_parms
	// - Optimize/Q/X=w_parms/XSA=w_limits merger_offsetOptFn, w_NULL
	// - Optimize/F=10/X=w_opt_parms,  merger_offsetOptFn, w_parms
	// - Optimize/XSA=w_limits/M={1,0}/X=w_opt_parms,  merger_offsetOptFn, w_parms
	//
	// Bottom line is: Optimize is totally broken (since more than half of all the options you can 
	// give it according to the docs) do not work, and it is incapable to find minima of multivariate
	// functions (even if they are very well behaved, have only one (absolute) minimum at all (see
	// fsmap_flip_ang2k, Precise issue in i_fsmap), and have only two parameters, and are given
	// a start point arbitrarily close to the minimum), no matter which method you supply.
	// --> Igor does not have any method to optimize multivariate functions. Even if they claim they 
	// do. They don't. Trust me. You'll save yourself a lot of trouble by just writing your own, just
	// like I did below.

	NVAR gv_autoNumSteps
	NVAR gv_autoXRange
	NVAR gv_autoYRange
	NVAR gv_autoIntRange
	
	Variable userAbort = 0
	Variable iter = 0
	
	utils_progressDlg(message="Finding limits for offsets", level=0)
	do
		Duplicate/O w_parms, w_old_parms
		for (i = 0; i < DimSize(w_parms, 0) && userAbort == 0; i += 1)
			if (stringmatch(w_mergeBox[trunc(i/3)][mod(i,3)+4],"y")) // Parameter is held, don't touch it
				continue
			endif
			Make/O/N=(gv_autoNumSteps) w_parm_result
			Variable minX, maxX
			String s = "Carpet "+num2istr(trunc(i/3))+", "
			switch(mod(i,3))
				case 2: // intensity
					s += "int_fac"
					minX = w_parms[i] / gv_autoIntRange
					maxX = w_parms[i] * gv_autoIntRange
					break
				case 0: // angle (X)
					s += "x_off"
					minX = w_parms[i] - gv_autoXRange / 2
					maxX = w_parms[i] + gv_autoXRange / 2
					break
				case 1: // energy (Y)
					s += "y_off"
					minX = w_parms[i] - gv_autoYRange / 2
					maxX = w_parms[i] + gv_autoYRange / 2
					break
			endswitch
			SetScale/I x, minX, maxX, w_parm_result
			for (j = 0; j <= gv_autoNumSteps && userAbort == 0; j += 1)
				w_parms[i] = pnt2x(w_parm_result, j)
				w_parm_result[j] = merger_offsetOptFn(w_parms)
				String msg
				sprintf msg, "%s, pos: %.2f, opt: %2.2e", s, w_parms[i], w_parm_result[j]
				userAbort = utils_progressDlg(message=msg, level=2)
			endfor
			if (userAbort)
				break
			endif
			CurveFit/Q/N poly 3, w_parm_result
			WAVE W_coef
			w_parms[i] = - (W_coef[1]/2/W_coef[2])
			userAbort = utils_progressDlg(message=s+", min: "+num2str(w_parms[i]), level=1)
		endfor
		if (userAbort)
			break
		endif
		w_old_parms = (w_old_parms[p]-w_parms[p])^2
		
		w_mergeBox[][1,3] = num2str(w_parms[p*3+q-1])

		updateMerged("")
		iter += 1
		sprintf msg, "Iter %d, distance from last: %2.2e", iter, sqrt(sum(w_old_parms))
		userAbort = utils_progressDlg(message=msg, level=0)
	while (sqrt(sum(w_old_parms)) > 1e-4 && userAbort == 0)

	DoWindow/F merger_panel
	RemoveImage w_opt_tmp

	KillWaves w_parms, w_old_parms, w_opt_tmp, w_parm_result

	utils_progressDlg(done=1)
	SetDataFolder $DF
End



Static Function updateMerged(ctrlName)
	String ctrlName

	WAVE/T w_mergeBox = root:internalUse:merger:w_mergeBox
	WAVE w_image = root:internalUse:panelcommon:w_image
	NVAR x0 = root:internalUse:merger:gv_x0
	NVAR x1 = root:internalUse:merger:gv_x1
	NVAR y0 = root:internalUse:merger:gv_y0
	NVAR y1 = root:internalUse:merger:gv_y1
	NVAR xp = root:internalUse:merger:gv_xp
	NVAR yp = root:internalUse:merger:gv_yp
	NVAR old_style = root:internalUse:merger:gv_old_style
	NVAR auto_z = root:internalUse:merger:gv_auto_z
	NVAR lin_comb = root:internalUse:merger:gv_lin_comb
	
	if (stringmatch(w_mergeBox[0][0],"_none"))
		DoAlert 0, "Seems that you have no matrix selected."
		abort
	endif
	
	ControlInfo sou_c10
	if (v_value)
		calcAutoDimensions()
	endif
	
	Variable x_offset, y_offset, int_factor
	
	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse:panelcommon
	
	Make/o/n=(xp,yp) w_image = 0
	SetScale/I x x0,x1,"" w_image
	SetScale/I y y0, y1, "" w_image
	
	Variable index = 0
	do
		WAVE w = $w_mergeBox[index][0]
		x_offset = str2num(w_mergeBox[index][1])
		y_offset = str2num(w_mergeBox[index][2])
		int_factor = str2num(w_mergeBox[index][3])
		//print x_offset, y_offset
		
		Duplicate/o w w_s
		w_s *= int_factor
		SetScale/P x dimoffset(w,0)+x_offset, dimdelta(w,0),"" w_s
		SetScale/P y dimoffset(w,1)+y_offset, dimdelta(w,1),"" w_s
	
		if (old_style)
			fsmap_merge2Baumberger(w_s, w_image,w_image)
		else
			fsmap_merge3Baumberger(w_s,w_image, w_image, auto_z, lin_comb)
		endif
		
	index += 1
	while (index < dimsize(w_mergeBox,0))

	// update the DCs
	Make/o/n=(dimsize(w_image,0)) n_mdc
	Make/o/n=(dimsize(w_image,1)) n_edc, n_edc_x
	SetScale/I x utils_x0(w_image),utils_x1(w_image), n_mdc
	SetScale/I x utils_y0(w_image),utils_y1(w_image), n_edc, n_edc_x
	n_edc_x = x
		
	n_mdc = w_image[p][qcsr(B,"merger_panel")]
	n_edc = w_image[pcsr(B,"merger_panel")][p]
		 	
	KillWaves/Z w_s
	SetDataFolder $DF
End


 