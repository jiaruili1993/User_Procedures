#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 2.00
#pragma ModuleName = prettypretty
#pragma IgorVersion = 5.0





Strconstant prettypretty_colorFns = "linear;2nd;log;exp;user;original"

Function prettypretty_open(ctrlname)
	String ctrlname

	String DF = GetDataFolder(1)
	if (DataFolderExists("root:internalUse:prettypretty") == 0)
		init()
	endif
	SetDataFolder root:internalUse:prettypretty
	
	DoWindow/K prettypretty_panel
	NewPanel/K=1/W=(0,0,510,600) as "Pretty Pretty"
	DoWindow/C prettypretty_panel
	utils_autoPosWindow("prettypretty_panel")

	Display/HOST=prettypretty_panel/W=(20,200,490,580)
	RenameWindow #, imagePreview
	SetActiveSubWindow prettypretty_panel

	WAVE/T w_graphList
	WAVE/T w_imageList
	TabControl pretty,proc=prettypretty#TabControlChange,pos={12,12},size={486,170},tabLabel(0)="graphs",value=0//,labelBack=(r,g,b)
	Listbox gra_lbgraph, pos={30,46}, size={150,100}, mode=1, listwave=w_graphList, proc=prettypretty#listBoxClicked,disable=1
	Listbox gra_lbimage, pos={190,46}, size={150,100}, mode=1, listwave=w_imageList, proc=prettypretty#listBoxClicked,disable=1
	
	NVAR gv_ctabmin, gv_ctabmax, gv_ctabreverse
	NVAR gv_ctabUnitsRelative
	TabControl pretty, tabLabel(1)="range"
	SetVariable ran_svmin, size={90,15}, pos={30,46}, title="min", value = gv_ctabmin,limits={-inf,inf,0},disable=1,proc=prettypretty#setVariableRange
	SetVariable ran_svmax, size={90,15}, pos={30,62}, title="max", value = gv_ctabmax,limits={-inf,inf,0},disable=1,proc=prettypretty#setVariableRange
	CheckBox ran_cbrel, size={90,15}, pos={30,78}, title="relative", value = gv_ctabUnitsRelative,disable=1,proc=prettypretty#checkBoxRange
	CheckBox ran_cbreverse, size={90,15}, pos={30,94}, title="reverse", value = gv_ctabreverse,disable=1,proc=prettypretty#checkBoxRange
	Button ran_breset, size={90,15}, pos={30,110}, title="reset", disable=1,proc=prettypretty#buttonRange
	
	SVAR gs_ctabname
	NVAR gv_colFuncPar
	NVAR gv_colorFuncEnabled
	TabControl pretty, tabLabel(2)="colors"
	PopupMenu col_pmname, size={200,25}, pos={30,46}, title="colors", value="*COLORTABLEPOP*",proc=prettypretty#popupMenuColors,disable=1
	PopupMenu col_pmfunction, size={100,25}, pos={30,76}, title="function", value=prettypretty_colorFns,proc=prettypretty#popupMenuColors,disable=1
	SetVariable col_svfuncpar, size={100,25}, pos={140,76}, title="par", value = gv_colFuncPar,limits={-inf,inf,0.1},disable=1,proc=prettypretty#setVariableColFuncPar
	CheckBox col_cbfuncenabled, size={150,15}, pos={30,106}, title="function enabled", value = gv_colorFuncEnabled,disable=1,proc=prettypretty#checkBoxColor

	NVAR gv_conmin, gv_conmax, gv_connum
	NVAR gv_conFuncPar
	NVAR gv_contourFuncEnabled
	TabControl pretty, tabLabel(3)="contours"
	PopupMenu con_pmname, size={150,15}, pos={20,46}, title="color", value="*COLORPOP*",proc=prettypretty#popupMenuColors,disable=1
	PopupMenu con_pmfunction, size={100,15}, pos={20,76}, title="function", value=prettypretty_colorFns,proc=prettypretty#popupMenuColors,disable=1
	SetVariable con_svfuncpar, size={100,15}, pos={20,106}, title="par", value = gv_conFuncPar,limits={-inf,inf,0.1},disable=1,proc=prettypretty#setVariableConFuncPar
	CheckBox con_cbfuncenabled, size={100,15}, pos={20, 126}, title="function enabled", value = gv_contourFuncEnabled,disable=1,proc=prettypretty#checkBoxContour
	SetVariable con_svmin, size={50,15}, pos={20,142}, title="min", value = gv_conmin,limits={-inf,inf,0},disable=1,proc=prettypretty#setVariableRange
	SetVariable con_svmax, size={50,15}, pos={75,142}, title="max", value = gv_conmax,limits={-inf,inf,0},disable=1,proc=prettypretty#setVariableRange
	SetVariable con_svnum, size={50,15}, pos={20,158}, title="num", value = gv_connum,limits={-inf,inf,0},disable=1,proc=prettypretty#setVariableRange
	CheckBox con_cbrel, size={50,15}, pos={75,158}, title="relative", value = gv_ctabUnitsRelative,disable=1,proc=prettypretty#checkBoxRange


	Button bapply, size={50,15}, pos={390,5}, title="apply",proc=prettypretty#buttonApply
	Button breset, size={50,15}, pos={450,5}, title="reset",proc=prettypretty#buttonReset


	Make/O/N=(100,100) w_image = NaN
	AppendImage/W=prettypretty_panel#imagePreview w_image
	updateGraphList()

	tabControlChange( "pretty", 1 )
	updatePreview()
	SetWindow prettypretty_panel, hook=prettypretty#hookFn, hookevents=3


	SetDataFolder $DF
End

















Function listBoxClicked(ctrlName,row,col,event) : ListboxControl
	String ctrlName     // name of this control
	Variable row        // row if click in interior, -1 if click in title
	Variable col        // column number
	Variable event      // event code
	
	if (event != 4)
		return 0
	endif
	
	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:prettypretty

	WAVE/T w_graphList
	WAVE/T w_imageList

	ControlInfo $ctrlName

	SVAR gs_currentGraph
	strswitch(ctrlName)
		case "gra_lbgraph":
			gs_currentGraph = w_graphList[V_Value]
			utils_stringList2wave(ImageNameList(gs_currentGraph, ";"))
			WAVE/T W_StringList
			Duplicate/O/T W_StringList, w_imageList
			KillWaves W_StringList
			ListBox gra_lbimage, selRow=0
			importImageFromGraph(gs_currentGraph, StringFromList(0, ImageNameList(gs_currentGraph, ";")))
			break
		case "gra_lbimage":
			importImageFromGraph(gs_currentGraph, StringFromList(V_Value, ImageNameList(gs_currentGraph, ";")))
			break
	endswitch
	updatePreview()

	SetDataFolder $DF
End



	
Static Function buttonApply(ctrlname) : ButtonControl
	String ctrlname

	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:prettypretty
	
	SVAR gs_currentGraph
	SVAR gs_currentWave
	SVAR gs_currentWavePath

	String iminfo = ImageInfo(gs_currentGraph, gs_currentWave, 0)

	NVAR gv_ctabmin, gv_ctabmax, gv_ctabreverse
	SVAR gs_ctabname
	NVAR gv_colorFuncEnabled
	Variable cmin = gv_ctabmin
	Variable cmax = gv_ctabmax
	NVAR gv_ctabUnitsRelative
	if(gv_ctabUnitsRelative == 1)
		cmin = rel2absolute(gv_ctabmin)
		cmax = rel2absolute(gv_ctabmax)
	endif
	if (! gv_colorFuncEnabled)
		ModifyImage/W=$gs_currentGraph $gs_currentWave ctab={cmin,cmax,$gs_ctabname,gv_ctabreverse}, lookup=$""
	else
		WAVE w_colorFunc
		SVAR gs_colorFuncWaveName
		SetDataFolder $gs_currentWavePath
		Duplicate/O w_colorFunc, $gs_colorFuncWaveName
		ModifyImage/W=$gs_currentGraph $gs_currentWave ctab={cmin,cmax,$gs_ctabname,gv_ctabreverse}, lookup=$gs_colorFuncWaveName
	endif
	
	NVAR gv_conmin, gv_conmax, gv_connum
	NVAR gv_conFuncPar
	NVAR gv_contourFuncEnabled
	NVAR gv_conR
	NVAR gv_conG
	NVAR gv_conB
	WAVE w_contourSliders
	String clist = ContourNameList("prettypretty_panel#imagePreview", ";")
	Variable i
	Variable contourIsPresent = 0
	For(i = 0; i < ItemsInList(clist); i += 1)
		if(stringmatch(StringFromList(i, clist), "w_image"))
			RemoveContour/W=prettypretty_panel#imagePreview $(StringFromList(i, clist))
		endif
	EndFor
	
	if (gv_connum > 0) // contours enabled
		String xaxis = StringByKey("XAXIS", iminfo, ":", ";")
		String yaxis = StringByKey("YAXIS", iminfo, ":", ";")
		String axisflags = StringByKey("AXISFLAGS", iminfo, ":", ";")
		if (stringmatch(axisflags, "*/T*") && stringmatch(axisflags, "*/R*"))
			AppendMatrixContour/W=$gs_currentGraph/T=$(xaxis)/R=$(yaxis) $(gs_currentWavePath+gs_currentWave)
		elseif (stringmatch(axisflags, "*/T*"))
			AppendMatrixContour/W=$gs_currentGraph/T=$(xaxis)/L=$(yaxis) $(gs_currentWavePath+gs_currentWave)
		elseif (stringmatch(axisflags, "*/R*"))
			AppendMatrixContour/W=$gs_currentGraph/B=$(xaxis)/R=$(yaxis) $(gs_currentWavePath+gs_currentWave)
		else
			AppendMatrixContour/W=$gs_currentGraph/B=$(xaxis)/L=$(yaxis) $(gs_currentWavePath+gs_currentWave)
		endif
		ModifyContour/W=$gs_currentGraph $gs_currentWave, manLevels= {0,1,0}, moreLevels=0, labels=0
		For (i = 0; i < gv_connum; i += 1)
			Variable contourVal = w_contourSliders[i][0][0]
			if(gv_ctabUnitsRelative == 1)
				contourVal = rel2absolute(contourVal)
			endif
			ModifyContour/W=$gs_currentGraph $gs_currentWave, morelevels={contourVal}

		EndFor
		ModifyContour/W=$gs_currentGraph $gs_currentWave, rgbLines=(gv_conR, gv_conG, gv_conB)
	endif

	SetDataFolder $DF
End



Static Function buttonReset(ctrlname) : ButtonControl
	String ctrlname

	SVAR gs_currentGraph = root:internalUse:prettypretty:gs_currentGraph
	SVAR gs_currentWave = root:internalUse:prettypretty:gs_currentWave
	if (strlen(gs_currentGraph) > 0)
		importImageFromGraph(gs_currentGraph,gs_currentWave)
		if (WinType("prettypretty_panel#rangeGraph") != 0)
			updateRangeGraph()
		endif
		if (WinType("prettypretty_panel#colorGraph") != 0)
			updateColorGraph()
		endif
		if (WinType("prettypretty_panel#contourGraph") != 0)
			updateContourGraph()
		endif
		updatePreview()
	endif
End




Static Function buttonRange(ctrlname) : ButtonControl
	String ctrlname
	WAVE w_rangeMaxSlider, w_rangeMinSlider
	WAVE w_rangeMaxIndicator, w_rangeMinIndicator
	NVAR gv_ctabmin, gv_ctabmax, gv_ctabUnitsRelative
	gv_ctabmin = w_rangeMinIndicator[0][0]
	gv_ctabmax = w_rangeMaxIndicator[0][0]
	w_rangeMinSlider[0][] = gv_ctabmin
	w_rangeMaxSlider[0][] = gv_ctabmax
	updateRangeGraph()
	updatePreview()
End



Static Function checkBoxColor(ctrlname, checked) : CheckBoxControl
	String ctrlname
	Variable checked
	NVAR gv_colorFuncEnabled = root:internalUse:prettypretty:gv_colorFuncEnabled
	gv_colorFuncEnabled = checked
	updatePreview()
End



Static Function checkBoxContour(ctrlname, checked) : CheckBoxControl
	String ctrlname
	Variable checked
	NVAR gv_contourFuncEnabled = root:internalUse:prettypretty:gv_contourFuncEnabled
	gv_contourFuncEnabled = checked
	updateContourGraph()
	updatePreview()
End




// changes the visible tab when the tab buttons are pressed.
Static Function tabControlChange( name, tab )
	String name
	Variable tab
	
	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:prettypretty
	
	ControlInfo $name
	String tabStr = S_Value[0,2]
	String all = ControlNameList( "prettypretty_panel" )
	String thisControl
	
	if (WinType("prettypretty_panel#rangeGraph") != 0)
		KillWindow prettypretty_panel#rangeGraph
	endif
	if (WinType("prettypretty_panel#colorGraph") != 0)
		KillWindow prettypretty_panel#colorGraph
	endif
	if (WinType("prettypretty_panel#contourGraph") != 0)
		KillWindow prettypretty_panel#contourGraph
	endif
	if (WinType("prettypretty_panel#ctabGraph") != 0)
		KillWindow prettypretty_panel#ctabGraph
	endif
	Variable i
	for (i = 0; i < ItemsInList(all); i+=1)
		thisControl = StringFromList( i, all )
		if( stringmatch( thisControl[3], "_" ) )
			utils_setControlEnabled( thisControl, ( stringmatch( thisControl[0,2], tabStr ) ? 0 : 1 ) )
		endif
	endfor
	strswitch(tabStr)
		case "ran":
			WAVE w_rangeMaxSlider, w_rangeMinSlider, w_rangeMaxIndicator, w_rangeMinIndicator
			WAVE w_rangeHisto
			Display/HOST=prettypretty_panel/W=(150,46,460,170) w_rangeHisto
			RenameWindow #, rangeGraph
			AppendToGraph w_rangeMinSlider[1][] vs w_rangeMinSlider[0][]
			AppendToGraph w_rangeMaxSlider[1][] vs w_rangeMaxSlider[0][]
			AppendToGraph w_rangeMinIndicator[1][] vs w_rangeMinIndicator[0][]
			AppendToGraph w_rangeMaxIndicator[1][] vs w_rangeMaxIndicator[0][]
			ModifyGraph margin(left)=56
			ModifyGraph mode(w_rangeHisto)=1
			ModifyGraph lSize(w_rangeMinSlider)=3,lSize(w_rangeMaxSlider)=3
			ModifyGraph rgb(w_rangeHisto)=(0,0,0),rgb(w_rangeMaxSlider)=(1,4,52428),rgb(w_rangeMaxIndicator)=(1,4,52428)
			NVAR gv_ctabmin, gv_ctabmax
			updateRangeGraph()
			break
		case "col":
			WAVE w_colorSplines_y, w_colorSplines_x
			WAVE w_colorFunc
			Display/HOST=prettypretty_panel/W=(300,46,460,170) w_colorFunc
			RenameWindow #, colorGraph
			SVAR gs_funcname
			if (stringmatch(gs_funcname,"user") == 1)
				AppendToGraph w_colorSplines_y vs w_colorSplines_x
				ModifyGraph mode(w_colorSplines_y)=3, marker(w_colorSplines_y)=5
			endif
			ModifyGraph mode(w_colorFunc)=0,rgb(w_colorFunc)=(0,0,0)
			SetAxis bottom, 0, 1
			SetAxis left, 0, 1
			WAVE w_ctabPreview
			Display/HOST=prettypretty_panel/W=(30,150,150,170)
			RenameWindow #, ctabGraph
			AppendImage w_ctabPreview
			SVAR gs_ctabname
			ModifyImage w_ctabPreview ctab= {*,*,$gs_ctabname,0}, lookup=w_colorFunc
			ModifyGraph nticks=0,noLabel=2
			ModifyGraph margin=4
			break
		case "con":
			WAVE w_rangeHisto
			WAVE w_contourSliders
			WAVE w_rangeMaxIndicator,  w_rangeMinIndicator
			NVAR gv_connum
			Display/HOST=prettypretty_panel/W=(150,46,460,170) w_rangeHisto
			RenameWindow #, contourGraph
			AppendToGraph w_rangeMinIndicator[1][] vs w_rangeMinIndicator[0][]
			AppendToGraph w_rangeMaxIndicator[1][] vs w_rangeMaxIndicator[0][]
			ModifyGraph margin(left)=56
			ModifyGraph mode(w_rangeHisto)=1
			ModifyGraph rgb(w_rangeHisto)=(0,0,0),rgb(w_rangeMaxIndicator)=(1,4,52428)
			For(i = 0; i < gv_connum;  i += 1)
				AppendToGraph/W=prettypretty_panel#contourGraph w_contourSliders[i][1][] vs w_contourSliders[i][0][]
			EndFor
			updateContourGraph()
			break
	endswitch
	SetActiveSubWindow prettypretty_panel
	SetDataFolder $DF
End



Static Function setVariableColFuncPar(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	NVAR gv_colFuncPar = root:internalUse:prettypretty:gv_colFuncPar
	updateColorGraph()
End



Static Function setVariableConFuncPar(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	NVAR gv_conFuncPar = root:internalUse:prettypretty:gv_conFuncPar
	updateContourGraph()
End




Static Function popupMenuColors(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:prettypretty

	strswitch(ctrlName)
		case "col_pmname":
			SVAR gs_ctabname
			gs_ctabname = popStr
			ModifyImage/W=prettypretty_panel#ctabGraph w_ctabPreview ctab= {*,*,$gs_ctabname,0}, lookup=w_colorFunc
			break
		case "col_pmfunction":
			SVAR gs_funcname
			gs_funcname = popStr
			updateColorGraph()
			// this updates the graph. If this popup menu was used, we are in tab no 1 ("colors")
			tabControlChange( "pretty", 1 )
			break
		case "con_pmname":
			ControlInfo $ctrlName
			NVAR gv_conR, gv_conG, gv_conB
			gv_conR = V_Red
			gv_conG = V_Green
			gv_conB = V_Blue
			break
		case "con_pmfunction":
			SVAR gs_contourfuncname
			gs_contourfuncname = popStr
			updateContourGraph()
			// this updates the graph. If this popup menu was used, we are in tab no 3 ("contours")
			tabControlChange( "pretty", 3 )
			break
	endswitch
	updatePreview()
End




Static Function setVariableRange(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable

	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:prettypretty

	WAVE w_rangeMaxSlider, w_rangeMinSlider
	NVAR gv_ctabmin, gv_ctabmax, gv_ctabUnitsRelative
	NVAR gv_conmin, gv_conmax, gv_contourUnitsRelative
	WAVE w_contourSliders
	NVAR gv_connum
	strswitch(ctrlname)
		case "ran_svmin":
			w_rangeMinSlider[0][] = gv_ctabmin
			updateRangeGraph()
			break
		case "ran_svmax":
			w_rangeMaxSlider[0][] = gv_ctabmax
			updateRangeGraph()
			break
		case "con_svmin":
		case "con_svmax":
			if (gv_connum > 1)
				Variable oldmax = w_contourSliders[gv_connum - 1][0][0]
				Variable oldmin = w_contourSliders[0][0][0]
				Variable scale = (gv_conmax - gv_conmin) / (oldmax - oldmin)
				Variable i
				For(i = 0; i < gv_connum;  i += 1)
					w_contourSliders[i][0][] = (w_contourSliders[i][0][r] - oldmin) * scale + gv_conmin
				EndFor
				updateContourGraph()
			endif
			break
		case "con_svnum":
			resizeContourSliders()
			break
	endswitch
	updatePreview()
	SetDataFolder $DF
End



Static Function resizeContourSliders()
	if (WinType("prettypretty_panel#contourGraph") == 0)
		return 0
	endif

	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:prettypretty
	WAVE w_contourSliders
	NVAR gv_connum, gv_conmin, gv_conmax
	
	// Need to remove the entire sliders from graph, since due to an Igor bug,
	// if you dont do this, Igor will crash when we try to resize the sliders.
	// This is a bit complicated, since upon removing a trace, Igor relabels
	// the remaining traces, so we have to get the list of traces whenever we 
	// remove a trace.
	Variable done
	do
		String tlist = TraceNameList("prettypretty_panel#contourGraph", ";", 1)
		done = 1
		Variable i
		For(i = 0; i < ItemsInList(tlist); i += 1)
			if (stringmatch(StringFromList(i, tlist), "w_contourSliders*"))
				RemoveFromGraph/W=prettypretty_panel#contourGraph $(StringFromList(i, tlist))
				done = 0
				break // start anew; we just removed a trace, so we need to get the tracenamelist again
			endif
		EndFor
	while(done == 0)

	gv_connum = max(0, gv_connum)
	gv_connum = (gv_connum == 1) ? 2 : gv_connum

	Redimension/N=(gv_connum,2,2) w_contourSliders
	if (gv_connum > 1)
		w_contourSliders[][1][0] = -inf
		w_contourSliders[][1][1] = inf
		For(i = 0; i < gv_connum;  i += 1)
			w_contourSliders[i][0][] = (i / (gv_connum - 1)) * (gv_conmax - gv_conmin) + gv_conmin
			AppendToGraph/W=prettypretty_panel#contourGraph w_contourSliders[i][1][] vs w_contourSliders[i][0][]
		EndFor
		// Make all contourSliders green. Can't do this directly after appendToGraph, since 
		// AppendToGraph is a black box, i.e. it does not tell you how Igor has labelled your
		// graph that you just appended.
		tlist = TraceNameList("prettypretty_panel#contourGraph", ";", 1)
		For(i = 0; i < ItemsInList(tlist); i += 1)
			if (stringmatch(StringFromList(i, tlist), "w_contourSliders*"))
				ModifyGraph/W=prettypretty_panel#contourGraph rgb($(StringFromList(i, tlist)))=(0,52224,0)
			endif
		EndFor
	
		w_contourSliders[gv_connum-1][0][] = gv_conmax
		w_contourSliders[0][0][] = gv_conmin
	endif
	
	updateContourGraph()
	
	SetDataFolder $DF
End



Static Constant splineTol = 1e-2

Static Function colorGraphHook(eventStr)
	String eventStr
	String e = StringByKey("EVENT", eventStr)
	Variable mods = str2num(StringByKey("MODIFIERS", eventStr))

	if ((stringmatch(e,"mousemoved") == 0) && (stringmatch(e,"mousedown") == 0))
		return 1
	endif
	
	if ((mods & 1) != 1)
		return 1
	endif

	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:prettypretty

	GetWindow prettypretty_panel#colorGraph, psizeDC // or gsizeDC?
			
	Variable posx = str2num(StringByKey("MOUSEX", eventStr))
	posx = (posx - V_left) / (V_right - V_left)
	Variable posy = str2num(StringByKey("MOUSEY", eventStr))
	posy = (V_bottom - posy) / (V_bottom - V_top)
	
	WAVE w_colorSplines_y, w_colorSplines_x
	
	Variable idx = -1, dist = inf
	Variable i
	For (i = 0; i < numpnts(w_colorSplines_y); i += 1)
		if ((w_colorSplines_y[i]-posy)^2+(w_colorSplines_x[i]-posx)^2 < dist)
			idx = i
			dist = (w_colorSplines_y[i]-posy)^2+(w_colorSplines_x[i]-posx)^2
		endif
	EndFor
	if ((mods & 8) == 8 && stringmatch(e,"mousedown") && numpnts(w_colorSplines_y) > 4)
		Duplicate/O w_colorSplines_x, w_tmp
		Redimension/N=(numpnts(w_colorSplines_y)-1) w_colorSplines_x
		w_colorSplines_x[0,idx-1] = w_tmp[p]
		w_colorSplines_x[idx,numpnts(w_colorSplines_x)-1] = w_tmp[p+1]
		Duplicate/O w_colorSplines_y, w_tmp
		Redimension/N=(numpnts(w_colorSplines_y)-1) w_colorSplines_y
		w_colorSplines_y[0,idx-1] = w_tmp[p]
		w_colorSplines_y[idx,numpnts(w_colorSplines_y)-1] = w_tmp[p+1]
		KillWaves w_tmp
		updateColorGraph()
		return 1
	endif
	For (i = 0; i < numpnts(w_colorSplines_y); i += 1)
		if (idx == i)
			continue
		endif
		if ((w_colorSplines_x[i] - splineTol) < posx && (w_colorSplines_x[i] + splineTol) > posx)
			return 1
		endif
	EndFor
	posx = max(min(1,posx),0)
	posy = max(min(1,posy),0)
	if ((mods & 2) == 2 && stringmatch(e,"mousedown"))
		Redimension/N=(numpnts(w_colorSplines_y)+1) w_colorSplines_x
		Redimension/N=(numpnts(w_colorSplines_y)+1) w_colorSplines_y
		idx = numpnts(w_colorSplines_y) - 1
	endif
	w_colorSplines_x[idx] = posx
	w_colorSplines_y[idx] = posy

	updateColorGraph()

	SetDataFolder $DF

	return 1
End



Static Function rangeGraphHook(eventStr)
	String eventStr

	if (stringmatch(StringByKey("EVENT", eventStr),"mouseup") == 1)
		updateRangeGraph()
	endif

	if ((stringmatch(StringByKey("EVENT", eventStr),"mousemoved") != 1))
		return 1
	endif

	Variable mods = str2num(StringByKey("MODIFIERS", eventStr))
	if (! mods & 1)
		return 0
	endif

	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:prettypretty

	GetWindow prettypretty_panel#rangeGraph, psizeDC // or gsizeDC?
			
	Variable posx = str2num(StringByKey("MOUSEX", eventStr))
	posx = (posx - V_left) / (V_right - V_left)
	WAVE w_rangeMaxSlider, w_rangeMinSlider, w_rangeMaxIndicator, w_rangeMinIndicator
	GetAxis/W=prettypretty_panel#rangeGraph/Q bottom
	posx = posx * (V_max - V_min) + V_min
	posx = min(max(posx, V_min), V_max)
	WAVE w_rangeHisto
	NVAR gv_ctabmin, gv_ctabmax, gv_ctabUnitsRelative
	if (abs(gv_ctabmax - posx) < abs(gv_ctabmin - posx))
		gv_ctabmax = posx
	else
		gv_ctabmin = posx
	endif
	w_rangeMinSlider[0][] = gv_ctabmin
	w_rangeMaxSlider[0][] = gv_ctabmax
	updatePreview()

	if (stringmatch(StringByKey("EVENT", eventStr),"mouseup") == 1)
		updateRangeGraph()
	endif

	SetDataFolder $DF

	return 1
End



Static Function contourGraphHook(eventStr)
	String eventStr

	if (stringmatch(StringByKey("EVENT", eventStr),"mouseup") == 1)
		updateContourGraph(adaptRange = 1)
	endif

	if ((stringmatch(StringByKey("EVENT", eventStr),"mousemoved") != 1))
		return 1
	endif

	Variable mods = str2num(StringByKey("MODIFIERS", eventStr))
	if (! mods & 1)
		return 0
	endif

	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:prettypretty
	NVAR gv_connum
	if (gv_connum < 2) // There is nothing for the user to do, since contours are disabled.
		SetDataFolder $DF
		return 1
	endif

	GetWindow prettypretty_panel#contourGraph, psizeDC // or gsizeDC?

	Variable posx = str2num(StringByKey("MOUSEX", eventStr))
	posx = (posx - V_left) / (V_right - V_left)
	WAVE w_contourSliders, w_rangeMaxIndicator, w_rangeMinIndicator
	GetAxis/W=prettypretty_panel#contourGraph/Q bottom
	posx = posx * (V_max - V_min) + V_min
	posx = min(max(posx, V_min), V_max)
	WAVE w_rangeHisto
	NVAR gv_conmin, gv_conmax, gv_contourUnitsRelative
	NVAR gv_contourFuncEnabled
	Variable i, idx = 0
	Variable idxDist = inf
	For(i = 0; i < gv_connum; i += 1)
		if (abs(w_contourSliders[i][0][0] - posx) < idxDist)
			idxDist = abs(w_contourSliders[i][0][0] - posx)
			idx = i
		endif
	EndFor
	if (gv_contourFuncEnabled == 1)
		if (abs(w_contourSliders[0][0][0] - posx) < abs(w_contourSliders[gv_connum-1][0][0] - posx))
			idx = 0
		else
			idx = gv_connum-1
		endif
	endif
	
	w_contourSliders[idx][0][] = posx
	
	For(i = 0; i < gv_connum; i += 1)
		w_contourSliders[i][0][] = max(w_contourSliders[i][0][r], w_contourSliders[0][0][0])
		w_contourSliders[i][0][] = min(w_contourSliders[i][0][r], w_contourSliders[gv_connum - 1][0][0])
	EndFor

	gv_conmin = w_contourSliders[0][0][0]
	gv_conmax = w_contourSliders[gv_connum - 1][0][0]
	updatePreview()

	if (stringmatch(StringByKey("EVENT", eventStr),"mouseup") == 1)
		updateContourGraph(adaptRange = 1)
	else
		updateContourGraph(adaptRange=0)
	endif

	SetDataFolder $DF

	return 1
End



Static Function hookFn(eventStr)
	String eventStr

	if (stringmatch(StringByKey("EVENT", eventStr),"activate") == 1)
		updateGraphList()
		return 0
	endif

	if (stringmatch(StringByKey("HCSPEC", eventStr), "prettypretty_panel#imagePreview") == 1)
		return 1 // user may not do anything to the preview
	endif
	if (stringmatch(StringByKey("HCSPEC", eventStr), "prettypretty_panel#ctabGraph") == 1)
		return 1 // user may not do anything to the preview
	endif
	if (stringmatch(StringByKey("HCSPEC", eventStr), "prettypretty_panel#rangeGraph") == 1)
		return rangeGraphHook(eventStr)
	endif

	if (stringmatch(StringByKey("HCSPEC", eventStr), "prettypretty_panel#colorGraph") == 1)
		return colorGraphHook(eventStr)
	endif

	if (stringmatch(StringByKey("HCSPEC", eventStr), "prettypretty_panel#contourGraph") == 1)
		return contourGraphHook(eventStr)
	endif

	return 0
End



Static Function checkBoxRange(ctrlname, checked) : CheckBoxControl
	String ctrlname
	Variable checked

	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:prettypretty
	strswitch(ctrlname)
		case "con_cbrel":
		case "ran_cbrel":
			WAVE w_rangeMaxSlider, w_rangeMinSlider, w_rangeMaxIndicator, w_rangeMinIndicator
			WAVE w_rangeHisto
			NVAR gv_ctabmin, gv_ctabmax
			NVAR gv_ctabUnitsRelative
			NVAR gv_connum, gv_conmax, gv_conmin
			WAVE w_contourSliders
			if (checked != 0)
				gv_ctabUnitsRelative = 1
				gv_ctabmin = absolute2rel(gv_ctabmin)
				gv_ctabmax = absolute2rel(gv_ctabmax)
				gv_conmin = absolute2rel(gv_conmin)
				gv_conmax = absolute2rel(gv_conmax)
				Variable i
				for (i = 0; i < gv_connum; i += 1)
					w_contourSliders[i][0][] = absolute2rel(w_contourSliders[i][0][r])
				endfor
				w_rangeMinIndicator[0][] = absolute2rel(w_rangeMinIndicator[0][0])
				w_rangeMaxIndicator[0][] = absolute2rel(w_rangeMaxIndicator[0][0])
			else
				gv_ctabUnitsRelative = 0
				gv_ctabmin = rel2absolute(gv_ctabmin)
				gv_ctabmax = rel2absolute(gv_ctabmax)
				gv_conmin = rel2absolute(gv_conmin)
				gv_conmax = rel2absolute(gv_conmax)
				for (i = 0; i < gv_connum; i += 1)
					w_contourSliders[i][0][] = rel2absolute(w_contourSliders[i][0][r])
				endfor
				w_rangeMinIndicator[0][] = rel2absolute(w_rangeMinIndicator[0][0])
				w_rangeMaxIndicator[0][] = rel2absolute(w_rangeMaxIndicator[0][0])
			endif
			w_rangeMinSlider[0][] = gv_ctabmin
			w_rangeMaxSlider[0][] = gv_ctabmax
			SetScale/I x, (w_rangeMinIndicator[0][0]), (w_rangeMaxIndicator[0][0]), w_rangeHisto
			if (stringmatch(ctrlname, "con_cbrel"))
				updateContourGraph()
			else
				updateRangeGraph()
			endif
			break
		case "ran_cbreverse":
			NVAR gv_ctabreverse
			gv_ctabreverse = checked
			updatePreview()
			break
	endswitch
	SetDataFolder $DF
End





































Static Function rel2absolute(i)
	Variable i
	NVAR gv_intMin = root:internalUse:prettypretty:gv_intMin
	NVAR gv_intMax = root:internalUse:prettypretty:gv_intMax
	Variable rng = gv_intMax - gv_intMin
	return i * rng + gv_intMin
End


Static Function absolute2rel(i)
	Variable i
	NVAR gv_intMin = root:internalUse:prettypretty:gv_intMin
	NVAR gv_intMax = root:internalUse:prettypretty:gv_intMax
	Variable rng = gv_intMax - gv_intMin
	return (i - gv_intMin) / rng
End



Static Function updatePreview()
	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:prettypretty

	NVAR gv_ctabmin, gv_ctabmax, gv_ctabreverse
	SVAR gs_ctabname
	NVAR gv_colorFuncEnabled
	Variable cmin = gv_ctabmin
	Variable cmax = gv_ctabmax
	NVAR gv_ctabUnitsRelative
	if(gv_ctabUnitsRelative == 1)
		cmin = rel2absolute(gv_ctabmin)
		cmax = rel2absolute(gv_ctabmax)
	endif

	if (! gv_colorFuncEnabled)
		ModifyImage/W=prettypretty_panel#imagePreview w_image ctab={cmin,cmax,$gs_ctabname,gv_ctabreverse}, lookup=$""
	else
		ModifyImage/W=prettypretty_panel#imagePreview w_image ctab={cmin,cmax,$gs_ctabname,gv_ctabreverse}, lookup=root:internalUse:prettypretty:w_colorFunc
	endif
	NVAR gv_conmin, gv_conmax, gv_connum
	NVAR gv_conFuncPar
	NVAR gv_contourFuncEnabled
	NVAR gv_conR
	NVAR gv_conG
	NVAR gv_conB
	WAVE w_contourSliders
	String clist = ContourNameList("prettypretty_panel#imagePreview", ";")
	Variable i
	Variable contourIsPresent = 0
	For(i = 0; i < ItemsInList(clist); i += 1)
		if(stringmatch(StringFromList(i, clist), "w_image"))
			contourIsPresent = 1
		endif
	EndFor
	
	if (gv_connum > 0) // contours enabled
		if(contourIsPresent == 0)
			AppendMatrixContour/W=prettypretty_panel#imagePreview w_image
		endif
		ModifyContour/W=prettypretty_panel#imagePreview w_image, manLevels= {0,1,0}, moreLevels=0, labels=0
		For (i = 0; i < gv_connum; i += 1)
			Variable contourVal = w_contourSliders[i][0][0]
			if(gv_ctabUnitsRelative == 1)
				contourVal = rel2absolute(contourVal)
			endif
			ModifyContour/W=prettypretty_panel#imagePreview w_image, morelevels={contourVal}
		EndFor
		ModifyContour/W=prettypretty_panel#imagePreview w_image, rgbLines=(gv_conR, gv_conG, gv_conB)
	else
		if (contourIsPresent == 1)
			RemoveContour/W=prettypretty_panel#imagePreview w_image
		endif
	endif
	
	DoUpdate

	SetDataFolder $DF
End




Static Function updateColorGraph()

	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:prettypretty

	WAVE w_colorSplines_y, w_colorSplines_x
	WAVE w_colorFunc
	NVAR gv_colFuncPar
	SVAR gs_funcname
	strswitch(gs_funcname)
		case "linear":
			w_colorFunc = x
			break
		case "2nd":
			w_colorFunc = (x + gv_colFuncPar * x^2) / (x + gv_colFuncPar)
			break
		case "log":
			w_colorFunc = ln(1+gv_colFuncPar*x) / ln(1+gv_colFuncPar)
			break
		case "exp":
			w_colorFunc = (exp(gv_colFuncPar*x) - 1) / (exp(gv_colFuncPar) - 1)
			break
		case "user":
			Interpolate2/A=0/I=3/Y=w_colorFunc w_colorSplines_x, w_colorSplines_y
			w_colorFunc = min(1,w_colorFunc[p])
			w_colorFunc = max(0,w_colorFunc[p])
			break
		case "original":
			SVAR gs_colorFuncWaveName
			SVAR gs_currentWavePath
			if (strlen(gs_colorFuncWaveName) > 0 && strlen(gs_currentWavePath) > 0 && WaveExists($(gs_currentWavePath+gs_colorFuncWaveName)))
				Duplicate/O $(gs_currentWavePath+gs_colorFuncWaveName), w_colorFunc
			else
				PopupMenu col_pmfunction, mode=((WhichListItem("linear", prettypretty_colorFns)+1))
				w_colorFunc = x
			endif
			break
	endswitch
	
	DoUpdate

	SetDataFolder $DF
End





Static Function updateRangeGraph()
	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:prettypretty

	WAVE w_rangeMaxSlider, w_rangeMinSlider
	Variable totalDist = w_rangeMaxSlider[0][0] - w_rangeMinSlider[0][0]
	Variable rMin = w_rangeMinSlider[0][0] - totalDist * 0.25
	Variable rMax = w_rangeMaxSlider[0][0] + totalDist * 0.25
	SetAxis/W=prettypretty_panel#rangeGraph bottom, rMin, rMax
	
	DoUpdate

	SetDataFolder $DF
End




Static Function updateContourGraph([adaptRange])
	Variable adaptRange
	if (paramIsDefault(adaptRange))
		adaptRange = 1
	endif
	
	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:prettypretty

	NVAR gv_connum
	if (gv_connum == 0)
		return 0
	endif
	WAVE w_contourSliders
//	RemoveFromGraph/W=prettypretty_panel#rangeGraph
	Variable totalDist, smin, smax
	if (gv_connum > 1)
		totalDist = w_contourSliders[gv_connum-1][0][0] - w_contourSliders[0][0][0]
		smin = w_contourSliders[0][0][0]
		smax = w_contourSliders[gv_connum - 1][0][0]
	else
		WAVE w_RangeMinIndicator, w_RangeMaxIndicator
		totalDist = w_RangeMaxIndicator[0][0] - w_RangeMinIndicator[0][0]
		smax = w_RangeMaxIndicator[0][0]
		smin = w_RangeMinIndicator[0][0]
	endif
	if (adaptRange == 1)
		Variable rMin = smin - totalDist * 0.25
		Variable rMax = smax + totalDist * 0.25
		SetAxis/W=prettypretty_panel#contourGraph bottom, rMin, rMax
	endif
	
//	Sleep/T 3
	NVAR gv_contourFuncEnabled
	if (gv_contourFuncEnabled == 1)
		NVAR gv_conFuncPar
		SVAR gs_contourfuncname
		strswitch(gs_contourfuncname)
			case "user":
			case "original":
			case "linear":
				Variable i
				For(i = 0; i < gv_connum;  i += 1)
					Variable xx = i / (gv_connum - 1)
					w_contourSliders[i][0][] = xx * totalDist + smin
				EndFor
				break
			case "2nd":
				For(i = 0; i < gv_connum;  i += 1)
					xx = i / (gv_connum - 1)
					Variable fn = (xx + gv_conFuncPar * xx^2) / (xx + gv_conFuncPar)
					w_contourSliders[i][0][] = fn * totalDist + smin
				EndFor
				break
			case "log":
				For(i = 0; i < gv_connum;  i += 1)
					xx = i / (gv_connum - 1)
					fn = ln(1+gv_conFuncPar*xx) / ln(1+gv_conFuncPar)
					w_contourSliders[i][0][] = fn * totalDist + smin
				EndFor
				break
			case "exp":
				For(i = 0; i < gv_connum;  i += 1)
					xx = i / (gv_connum - 1)
					fn = (exp(gv_conFuncPar*xx) - 1) / (exp(gv_conFuncPar) - 1)
					w_contourSliders[i][0][] = fn * totalDist + smin
				EndFor
				break
		endswitch
	endif
	
	DoUpdate

	SetDataFolder $DF
End




Static Function init()
	String DF = GetDataFolder(1)
	NewDataFolder/S root:internalUse:prettypretty
	Variable/G gv_ctabmin = 0, gv_ctabmax = 1, gv_ctabreverse = 0
	String/G gs_ctabname = "Terrain"
	String/G gs_currentGraph = ""
	String/G gs_currentWave = ""
	String/G gs_currentWavePath = ""
	Variable/G gv_ctabUnitsRelative = 1
	Variable/G gv_colFuncPar = 1
	String/G gs_funcname = "linear"
	Variable/G gv_colorFuncEnabled = 0
	String/G gs_colorFuncWaveName = ""
	Make/O/N=100 w_rangeHisto = NaN
	Make/O w_rangeMaxSlider = {{0,0},{-inf,inf}}
	Make/O w_rangeMinSlider = {{0,0},{-inf,inf}}
	Make/O w_rangeMaxIndicator = {{0,0},{-inf,inf}}
	Make/O w_rangeMinIndicator = {{0,0},{-inf,inf}}
	Variable/G gv_intMin = 0, gv_intMax = 1
	Variable/G gv_rangeActivated = 0
	Make/O w_colorSplines_y = {0,1/3,2/3,1}
	Make/O w_colorSplines_x = {0,1/3,2/3,1}
	Make/O/N=1000 w_colorFunc
	SetScale/I x, 0, 1, w_colorFunc
	w_colorFunc[] = x
	Make/O/N=(100,1) w_ctabPreview
	SetScale/I x, 0, 1, w_ctabPreview
	w_ctabPreview[][] = x
	Make/O/T/N=0 w_graphList
	Make/O/T/N=0 w_imageList
	
	Variable/G gv_conmin = 0, gv_conmax = 1, gv_connum = 2
	Variable/G gv_conFuncPar = 1
	String/G gs_contourFuncName = "linear"
	Variable/G gv_contourFuncEnabled = 0
	Variable/G gv_conR = 65535, gv_conG=65535, gv_conB = 65535
	Make/O/N=(2,2,2) w_contourSliders
	w_contourSliders[][0][] = 0
	w_contourSliders[][1][0] = -inf
	w_contourSliders[][1][1] = inf
	
	Make/O w_contourMaxIndicator = {{0,0},{-inf,inf}}
	Make/O w_contourMinIndicator = {{0,0},{-inf,inf}}

	SetDataFolder $DF
End





Static Function/S importImageFromGraph(graphname,imagename)
	String graphname
	String imagename
	
	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:prettypretty

	SVAR gs_currentGraph
	NVAR gv_ctabmin, gv_ctabmax, gv_ctabreverse
	NVAR gv_conmin, gv_conmax, gv_connum
	WAVE w_contourSliders
	NVAR gv_contourFuncEnabled, gv_conFuncPar
	SVAR gs_contourfuncname
	WAVE w_rangeMaxSlider, w_rangeMinSlider, w_rangeMaxIndicator, w_rangeMinIndicator
	WAVE w_rangeHisto
	SVAR gs_ctabname
	SVAR gs_currentGraph
	SVAR gs_currentWave, gs_currentWavePath

	gs_currentGraph = graphname

	String ginfo = ""
	if (strlen(imagename) > 0)
		ginfo = ImageInfo(graphname,imagename,0)
	endif

	gs_currentWave = StringByKey("ZWAVE",ginfo,":",";")
	gs_currentWavePath = StringByKey("ZWAVEDF",ginfo,":",";")


	Make/O/N=(100,100) w_image
	w_image = (p == q || p == 100-q) ? 1: NaN
	
	
	NVAR gv_intMin, gv_intMax
	SVAR gs_colorFuncWaveName
	NVAR gv_colorFuncEnabled
	WAVE w_contourSliders
	w_contourSliders[][1][0] = -inf
	w_contourSliders[][1][1] = inf
	if (strlen(gs_currentWave) != 0)
		Duplicate/O $(gs_currentWavePath+gs_currentWave) w_image
		WaveStats/Q w_image
		gv_intMin = V_min
		gv_intMax = V_max
		SetScale/I x, V_min, V_max, w_rangeHisto
		Histogram/B=2 w_image, w_rangeHisto
		NVAR gv_ctabUnitsRelative
		if (gv_ctabUnitsRelative == 0)
			w_rangeMinSlider[0][] = V_min
			w_rangeMinIndicator[0][] = V_min
			w_rangeMaxSlider[0][] = V_max
			w_rangeMaxIndicator[0][] = V_max
			SetScale/I x, V_min, V_max, w_rangeHisto
			gv_ctabmin = V_min
			gv_conmin = V_min
			gv_ctabmax = V_max
			gv_conmax = V_max
		else
			w_rangeMinSlider[0][] = 0
			w_rangeMinIndicator[0][] = 0
			w_rangeMaxSlider[0][] = 1
			w_rangeMaxIndicator[0][] = 1
			SetScale/I x, 0, 1, w_rangeHisto
			gv_ctabmin = 0
			gv_conmin = 0
			gv_ctabmax = 1
			gv_conmax = 1
		endif
		gv_ctabreverse = 0
		gs_ctabname = "Terrain"
		gs_colorFuncWaveName = gs_currentWave + "_colors"
		gv_colorFuncEnabled = 0
	else
		w_rangeMinSlider[0][] = 0
		w_rangeMinIndicator[0][] = 0
		w_rangeMaxSlider[0][] = 1
		w_rangeMaxIndicator[0][] = 1
		w_rangeHisto = 0
		SetScale/I x, 0, 1, w_rangeHisto
		gv_ctabmin = 0
		gv_conmin = 0
		gv_ctabmax = 1
		gv_conmax = 1
		gv_ctabreverse = 0
		gs_ctabname = "Terrain"
		gs_colorFuncWaveName = ""
		gv_colorFuncEnabled = 0
	endif
	
	if (strsearch(ginfo, "RECREATION:", inf, 1) >= 0)
		// Igor bug: ImageInfo is supposed to return a key:value; list.
		// But RECREATION can contain a ";" in the command that will then throw off
		// the key:list; syntax and we won't catch the wholw RECREATION string.
		// Therefore, we assume that RECREATION is always at the end of the string
		// returned by ImageInfo:
		String rec = ginfo[strsearch(ginfo, "RECREATION:", inf, 1)+11,strlen(ginfo)-1]
		// Igor bug 2: What I have to do here to extract the right stuff from the graph
		// recreation defies EVERYTHING the Igor fellas claim in their documentation.
		String ctab = StringByKey("ctab", rec, "=",";")
		if (strlen(ctab) != 0)
			String lookup = StringByKey("lookup", ctab, "=",",")
			if (strlen(lookup) > 0)
				gv_colorFuncEnabled = 1
				gs_colorFuncWaveName = lookup
				SVAR gs_funcname
				gs_funcname = "original"
			else
				gv_colorFuncEnabled = 0
			endif
			ctab = ctab[strsearch(ctab,"{",0)+1,strsearch(ctab,"}",inf,1)-1]
			String s = StringFromList(0,ctab,",")
			gv_ctabmin = (strsearch(s,"*",0) != -1) ? V_min : str2num(s)
		
			s = StringFromList(1,ctab,",")
			gv_ctabmax = (strsearch(s,"*",0) != -1) ? V_max : str2num(s)

			gs_ctabname = StringFromList(2,ctab,",")
			if (ItemsInList(ctab,",") == 4)
				gv_ctabreverse = str2num(StringFromList(3,ctab,","))
			endif
		
			if (gv_ctabUnitsRelative == 1)
				gv_ctabmin = absolute2rel(gv_ctabmin)
				gv_ctabmax = absolute2rel(gv_ctabmax)
			endif
			w_rangeMinSlider[0][] = gv_ctabmin
			w_rangeMaxSlider[0][] = gv_ctabmax
		endif
	endif

	gv_connum = 0
	resizeContourSliders()
	
	if (strlen(ginfo) > 0 && WhichListItem(imagename, ContourNameList(graphname, ";"), ";") != -1) // we have contours. -> Import contours
		String cLevels = StringByKey("LEVELS", ContourInfo(graphname, imagename, 0), ":", ";")
		gv_connum = ItemsInList(cLevels, ",")
		gv_conmin = str2num(StringFromList(0, cLevels, ","))
		gv_conmax = str2num(StringFromList(gv_connum - 1, cLevels, ","))
		if (gv_ctabUnitsRelative == 1)
			gv_conmin = absolute2rel(gv_conmin)
			gv_conmax = absolute2rel(gv_conmax)
		endif
		resizeContourSliders()

		gv_contourFuncEnabled = 1
		gs_contourfuncname = "user"
		Variable i
		For(i = 0; i < gv_connum;  i += 1)
			w_contourSliders[i][0][] = str2num(StringFromList(i, cLevels, ","))
			if (gv_ctabUnitsRelative == 1)
				w_contourSliders[i][0][] = absolute2rel(w_contourSliders[i][0][r])
			endif
			w_contourSliders[i][1][0] = -inf
			w_contourSliders[i][1][1] = inf
		EndFor
	endif

	// update the popupMenus, since Igor does not provide a mechanism 
	// to do this automatically:
	PopupMenu col_pmname, mode=((WhichListItem(gs_ctabname, CTabList())+1))
	SVAR gs_funcname
	if (WhichListItem(gs_funcname, prettypretty_colorFns) >= 0)
		PopupMenu col_pmfunction, mode=((WhichListItem(gs_funcname, prettypretty_colorFns)+1))
	endif
	SVAR gs_contourFuncName
	if (WhichListItem(gs_contourFuncName, prettypretty_colorFns) >= 0)
		PopupMenu con_pmfunction, mode=((WhichListItem(gs_contourFuncName, prettypretty_colorFns)+1))
	endif
	
	SetDataFolder $DF
	return gs_currentWavePath+gs_currentWave
End



Static Function/S getAllImageGraphs(topWindow)
	String topWindow
	String children = ChildWindowList(topWindow)
	String ret = ""
	
	Variable i
	for (i = 0; i < ItemsInList(children); i += 1)
		ret += getAllImageGraphs(topWindow+"#"+StringFromList(i, children))
	endfor
	if (ItemsInList(ImageNameList(topWindow,";")) > 0)
		ret += topWindow + ";"
	endif
	return ret
End


Static Function updateGraphList()
	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:prettypretty
	WAVE/T w_graphList
	WAVE/T w_imageList
	Variable i, j
	String s = ""
	for (i = 0; strlen(WinName(i,69)) > 0; i += 1)
		if (! stringmatch("prettypretty_panel", WinName(i,69)) )
			s += getAllImageGraphs(WinName(i,69))
		endif
	endfor
	utils_stringList2wave(s)
	Duplicate/O/T W_StringList, w_graphList
	KillWaves W_StringList
	ListBox gra_lbgraph, selRow=0

	if (DimSize(w_graphList,0) > 0)
		utils_stringList2wave(ImageNameList(w_graphList[0], ";"))
		Duplicate/O/T W_StringList, w_imageList
		KillWaves W_StringList
	else
		Make/O/T/N=0 w_imageList
	endif
	ListBox gra_lbimage, selRow=0
	if (DimSize(w_graphList, 0) > 0 && DimSize(w_imageList, 0) > 0)
		importImageFromGraph(w_graphList[0], w_imageList[0])
	else
		importImageFromGraph("", "")
	endif
	updatePreview()
	if (WinType("prettypretty_panel#rangeGraph") != 0)
		updateRangeGraph()
	endif
	if (WinType("prettypretty_panel#colorGraph") != 0)
		updateColorGraph()
	endif
	if (WinType("prettypretty_panel#contourGraph") != 0)
		updateContourGraph()
	endif
	SetDataFolder $DF
End
