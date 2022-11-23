#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 2.00
#pragma ModuleName = fit
#pragma IgorVersion = 5.0


















////////////////////////////////////////
//
// Public Functions
//
////////////////////////////////////////



















Function fit_open(ctrlName)
	String ctrlName

	init()
	
	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse:fit
	
	WAVE w_data = w_data
	WAVE w_guess = w_guess
	WAVE w_par = w_par
	
	DoWindow/K fit_panel
	Display/K=1 as "fit panel"
	DoWindow/C fit_panel
	utils_resizeWindow("fit_panel", 510,510)
	utils_autoPosWindow("fit_panel", win=127)
	String cmd = "ControlBar 206"
	execute cmd
	
	Variable r=57000, g=57000, b=57000	// background color for the TabControl
	ModifyGraph cbRGB=(42428,42428,42428)
	ModifyGraph wbRGB=(63000,64000,55000),gbRGB=(63000,64000,55000)
	
	//Display/HOST=fit_panel/w=(0,0,0.5,1) w_data, w_guess
	//Display/HOST=fit_panel/w=(0.5,0,1,1) w_data, w_guess
	
	AppendToGraph w_guess, w_data	//, w_Par
	ModifyGraph mode(w_data)=3,marker(w_data)=19,msize(w_data)=1, rgb(w_data)=(16385,16388,65535)
	ShowInfo
	Cursor/P A w_data 20
	Cursor/P B w_data 180
	
	// --------------------------tab-controls -----------------
	
	// composer
	TabControl norm,proc=fit#autoTabChange,pos={8,6},size={494,190},tabLabel(0)="function+data",value=0,labelBack=(r,g,b), fsize=12
	SetVariable fun_sv0, pos={55,35}, size={443,18},labelBack=(r,g,b), title="function:", value=root:internaluse:fit:gs_literalFF, noedit=1,frame=1	//, disable=1
	Listbox fun_lb0, pos={16,57}, size={120,100}, listwave=root:internalUse:fit:w_peakfuncLB, frame=2,mode=1	//, disable=1
	Button fun_b0, pos={26,167}, size={100,16}, title="add peak", proc=fit#buttonAddPeak	//, disable=1
	Listbox fun_lb1, pos={156,57}, size={120,100}, listwave=root:internalUse:fit:w_bkgfuncLB, frame=2,mode=1	//, disable=1
	Button fun_b1, pos={166,167}, size={100,16}, title="add bkg.", proc=fit#buttonAddBkg	//, disable=1
	CheckBox fun_cbFermiMult, pos={300,56}, size={120,15},labelBack=(r,g,b), title="multiply with Fermi-function",proc=fit#checkBoxFermiFn, value=0	//, disable=1
	CheckBox fun_cbFermiOffset, pos={300,74}, size={120,15},labelBack=(r,g,b), title="add offset above Fermi-level",proc=fit#checkBoxFermiFn, value=0	//, disable=1
	CheckBox fun_cbFermiConvGauss, pos={300,92}, size={120,15},labelBack=(r,g,b), title="convolve with Gaussian", proc=fit#checkBoxFermiFn, value=0	//, disable=1

	Button fun_b2, pos={16,35}, size={35,14}, fsize=10,labelBack=(r,g,b), title="clear", proc=fit#buttonClearFermiFn	//, disable=1
	
	GroupBox fun_gb10, frame=0,labelBack=(r,g,b), pos={288,125}, size={202,65}, title="data", fsize=11	//, disable=1
	Button fun_b10, pos={320,136},size={70,16},labelBack=(r,g,b), fsize=10,title="top-graph", proc=fit#buttonNewFitData	//, disable=1
	Button fun_b11, pos={400,136},size={60,16},labelBack=(r,g,b), fsize=10,title="browse"	, proc=fit#buttonNewFitData //, disable=1
	SetVariable fun_sv11, pos={292,157}, size={192,18},labelBack=(r,g,b), title=" ", value=root:internaluse:fit:gs_dataPath, noedit=1,frame=0	//, disable=1
	
	
	TabControl norm,tabLabel(1)="coefficients"
	Listbox coe_lb0, pos={16,37}, size={476,112}, widths={72,50,20,72,50,20,72,50,20,72,50,20,72,50,20,72,50,20,72,50,20,72,50,20,72,50,20,72}
	Listbox coe_lb0, listwave=w_fitLB, selwave=w_fitLBsw, frame=2,mode=5, proc=fit#listBoxGuessFit, disable=1
	Groupbox coe_gb0, pos={16,157}, size={476,30}, labelBack=(r,g,b), frame=3, disable=1
	//String/g titlestr = long_string()
	//titlebox coe_tb0, pos={16,160}, size={476,35}, labelBack=(r,g,b), frame=3, variable=titlestr, disable=1
	titlebox coe_tb0, pos={24,165}, size={476,35}, labelBack=(r,g,b), title="guess-wave:", fsize=12, frame=0, disable=1
	Button coe_b0, pos={380,164}, size={70,18}, labelBack=(r,g,b), title="test", proc=fit#buttonTestFit, disable=1
	CheckBox coe_cbEDC, pos={120,165}, size={50,16},labelBack=(r,g,b), fsize=12, title="EDCs",proc=fit#checkBoxDCEdcMdc, value=0	, disable=1
	CheckBox coe_cbMDC, pos={180,165}, size={50,16},labelBack=(r,g,b), fsize=12, title="MDCs",proc=fit#checkBoxDCEdcMdc, value=1, disable=1
	SetVariable coe_sv10, pos={240,165}, size={90,16},labelBack=(r,g,b), fsize=12, title="DC #:", limits={0,inf,1},proc=fit#setVariableDCNumber, value=root:internalUse:fit:gv_DC, disable=1
	
	
	
	TabControl norm,tabLabel(2)="data-options"
	Groupbox dat_gb0, pos={16,35}, size={270,145}, labelBack=(r,g,b), title="fit-range", fsize=11, disable=1
	Checkbox dat_c0, pos={24,60}, size={70,18}, labelBack=(r,g,b), title="\f01constant range", fsize=10, value=1, proc=checkBoxFitRange, disable=1
	SetVariable dat_sv0, pos={40,80}, size={80,16}, labelBack=(r,g,b), limits={-inf,inf,0}, title="from", value=gv_rangeFrom, disable=1
	SetVariable dat_sv1, pos={130,80}, size={67,16}, labelBack=(r,g,b), limits={-inf,inf,0}, title="to", value=gv_rangeTo, disable=1
	Button dat_b0, pos={220,80}, size={40,15}, labelBack=(r,g,b), title="csr", proc=fit#buttonGetCsrValues, disable=1
	Checkbox dat_c1, pos={24,105}, size={70,18}, labelBack=(r,g,b), title="\f01max. plus/minus", fsize=10, proc=fit#checkBoxFitRange, disable=1
	SetVariable dat_sv2, pos={40,125}, size={140,16}, labelBack=(r,g,b), limits={-inf,inf,0}, title="search max. within  ", value=gv_maxFrom, disable=1
	SetVariable dat_sv3, pos={185,125}, size={88,16}, labelBack=(r,g,b), limits={-inf,inf,0}, title="     and    ", value=gv_maxTo, disable=1
	SetVariable dat_sv4, pos={40,145}, size={140,16}, labelBack=(r,g,b), limits={-inf,inf,0}, title="range is from max -", value=gv_maxPlus, disable=1
	SetVariable dat_sv5, pos={185,145}, size={88,16}, labelBack=(r,g,b), limits={-inf,inf,0}, title="to max +", value=gv_maxMinus, disable=1
	
	Groupbox dat_gb10, pos={310,35}, size={140,116}, labelBack=(r,g,b), title="define DCs", fsize=11, disable=1
	CheckBox dat_cbEDC, pos={320,60}, size={50,16},labelBack=(r,g,b), fsize=11, title="EDCs",proc=fit#checkBoxDCEdcMdc, value=0	, disable=1
	CheckBox dat_cbMDC, pos={380,60}, size={50,16},labelBack=(r,g,b), fsize=11, title="MDCs",proc=fit#checkBoxDCEdcMdc, value=1, disable=1
	SetVariable dat_sv10, pos={330,85}, size={90,16}, labelBack=(r,g,b), limits={-inf,inf,1}, title="first", value=gv_firstDC, disable=1
	SetVariable dat_sv11, pos={330,105}, size={90,16}, labelBack=(r,g,b), limits={-inf,inf,1}, title="last ", value=gv_lastDC, disable=1
	SetVariable dat_sv12, pos={330,125}, size={90,16}, labelBack=(r,g,b), limits={-inf,inf,1}, title="step ", value=gv_stepDC, disable=1
	Button dat_b10, pos={310, 160}, size={80,18}, labelBack=(r,g,b), title="run fit", proc=fit#buttonRunFit, disable=1
	//The following is added by Wei-Sheng
	Button dat_b11, pos=	{410,160}, size={80,18}, labelBack=(r,g,b), title="Peak", proc=fit#buttonPeakDispersion, disable =1
	
	TabControl norm,tabLabel(3)="output"
	//Groupbox out_gb0, pos={16,35}, size={80,135}, labelBack=(r,g,b), title="fit", fsize=11, disable=1
	ListBox out_lb0, pos={16,35}, size={140,145}, listwave=w_fitprojects, frame=2, mode=1, proc=fit#listBoxProject, disable=1
	
	//Groupbox out_gb1, pos={110,35}, size={200,135}, labelBack=(r,g,b), title="parameter waves", fsize=11, disable=1
	ListBox out_lb1, pos={166,35}, size={170,100}, listwave=wt_nonTrivialCol, frame=2, mode=1, proc=fit#listBoxShowPar, disable=1
	//Button out_b0, pos={166, 160}, size={50,18}, labelBack=(r,g,b), title="show", disable=1
	Button out_b1, pos={216, 160}, size={70,18}, labelBack=(r,g,b), title="new graph", proc=fit#buttonNewParGraph, disable=1
	//Button out_b2, pos={245, 160}, size={70,18}, labelBack=(r,g,b), title="extract all", disable=1
	
	Groupbox out_gb10, pos={350,35}, size={135,145}, labelBack=(r,g,b), title="stack plot", fsize=11, disable=1
	SetVariable out_sv10, pos={360,60}, size={115,16},labelBack=(r,g,b), title="y-offset", limits={0,inf,0}, value=gv_yOffset, disable=1
	SetVariable out_sv11, pos={360,78}, size={115,16},labelBack=(r,g,b), title="dest-pnts.", limits={0,inf,0}, value=gv_destPoints, disable=1
	CheckBox out_c10, pos={360,102}, size={80,16},labelBack=(r,g,b), title="full width of graph", value=0, disable=1
	CheckBox out_c11, pos={360,120}, size={80,16},labelBack=(r,g,b), title="add background", value=0, disable=1
	Button out_b10, pos={380, 155}, size={70,18}, labelBack=(r,g,b), title="new graph", proc=fit#buttonFitStack, disable=1
	
	SetDataFolder $DF
End






























////////////////////////////////////////
//
// Private Control Callbacks
//
////////////////////////////////////////
























Static Function autoTabChange( name, tab )
	String name
	Variable tab
	
	NVAR csrA = root:internaluse:fit:gv_DCcsrA
	NVAR csrB = root:internaluse:fit:gv_DCcsrB
	NVAR prevTab = root:internaluse:fit:gv_previousTab
	WAVE w_data = root:internalUse:fit:w_data
	
	ControlInfo $name
	String tabStr = S_Value[0,2]
	String all = ControlNameList( "fit_panel" )
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
	
	if (prevTab != 3)	// store the cursor positions
		if (strlen(csrWave(A)) > 0)
			csrA = xcsr(A)
		else
			csrA = pnt2x(w_data,0.2*numpnts(w_data))		// a default
		endif
		 if (strlen(csrWave(B)) > 0)
			csrB = xcsr(B)
		else
			csrB = pnt2x(w_data,0.8*numpnts(w_data))
		endif
	endif
	
	if (tab ==1)		
		WAVE w_comp = root:internalUse:fit:w_FFcomposition
		make_LBguess_waves(w_comp)
	endif						
	if (tab ==3)
		project_wave()	
		AppendToGraph root:internalUse:fit:w_par
		ModifyGraph mode=4,marker=19,msize=2,rgb=(1,26214,0),lsize=0.5
		RemoveFromGraph/Z w_data, w_guess	
	else
		WAVE w_Par = root:internalUse:fit:w_Par
		RemoveFromGraph/Z w_data, w_guess
		AppendToGraph root:internalUse:fit:w_data
		AppendToGraph root:internalUse:fit:w_guess
		ModifyGraph mode(w_data)=3,marker(w_data)=19,msize(w_data)=1, rgb(w_data)=(16385,16388,65535)
		RemoveFromGraph/Z w_par
		Cursor A w_data csrA
		Cursor B w_data csrB
	endif
	 
	 prevTab = tab
End




Static Function buttonAddPeak(ctrlName)
	String ctrlName
	
	WAVE w_comp = root:internalUse:fit:w_FFcomposition
	SVAR literalFF = root:internalUse:fit:gs_literalFF
	
	ControlInfo fun_lb0
	if (v_value == 4 || v_value == 5)		// corrected 06-08-04
		if (w_comp[0] == 0)
			DoAlert 0, "'Fermi-liquid' and 'marginal-FL' require parameters from the Fermi-function!\rUse the 'empirical-FL' if you don't want to multiply by a Fermi-function."
			Checkbox fun_cbFermiMult value = 1
			w_comp[0] = 1
		endif	
	endif
	
	Variable old_pnts = numpnts(w_comp)
	InsertPoints old_pnts,1, w_comp
	
	w_comp[old_pnts] = v_value
	
	literalFF = FF_string(w_comp)
	
End




Static Function buttonAddBkg(ctrlName)
	String ctrlName

	WAVE w_comp = root:internalUse:fit:w_FFcomposition
	SVAR literalFF = root:internalUse:fit:gs_literalFF
	ControlInfo fun_lb1
	w_comp[3] = v_value
	
	literalFF = FF_string(w_comp)
End






Static Function checkBoxFermiFn(ctrlName,checked)
	String ctrlName
	Variable checked
	
	WAVE w_comp = root:internalUse:fit:w_FFcomposition
	SVAR literalFF = root:internalUse:fit:gs_literalFF
	
	if (stringmatch(ctrlName,"fun_cbFermiMult"))
		w_comp[0] = checked
	elseif (stringmatch(ctrlName,"fun_cbFermiOffset"))
		w_comp[1] = checked
	else
		w_comp[2] = checked				
		//if (checked)
		//	DoAlert 0, "Note: this does not work very satisfactory. Don't know why..."
		//endif
	endif
	
	literalFF = FF_string(w_comp)
End






Static Function buttonClearFermiFn(ctrlName)
	String ctrlName
	
	make/o/n=4 root:internalUse:fit:w_FFcomposition = 0
	SVAR literalFF = root:internalUse:fit:gs_literalFF
	
	WAVE/t w_fitLB = root:internalUse:fit:w_fitLB
	w_fitLB=""
	
	Checkbox fun_cbFermiMult, value=0
	Checkbox fun_cbFermiOffset, value=0
	Checkbox fun_cbFermiConvGauss, value=0
	literalFF = ""
End





Static Function buttonNewFitData(ctrlName)
	String ctrlName
	
	SVAR path = root:internaluse:fit:gs_dataPath
	string w_Name, win_Name
	
	if (stringmatch(ctrlname,"fun_b10"))	// top-graph
		//doalert 0, "not yet implemented"
		//abort
		Variable i = 0
		do 
			String gName = WinName(i, 69)
			i += 1
		while (strlen(ImageNameList(gName,";")) == 0)
		String iName = StringFromList(0, ImageNameList(gName,";"))
		WAVE dum = ImageNameToWaveRef(gName,iName)
		path = GetWavesDataFolder(dum,2)
		
	else
		String cmd = "CreateBrowser prompt=\"select a wave and click 'ok'\""
		execute cmd
		SVAR S_BrowserList=S_BrowserList
		path = StringFromList(0,S_BrowserList)
		
		NVAR V_Flag=V_Flag
		if(V_Flag==0)
			return -1
		endif
		
	endif
End





Static Function listBoxGuessFit(ctrlName,row,col,event) : ListBoxControl
	String ctrlName
	Variable row
	Variable col
	Variable event	//1=mouse down, 2=up, 3=dbl click, 4=cell select with mouse or keys
					//5=cell select with shift key, 6=begin edit, 7=end

	WAVE/t w_fitLB = root:internalUse:fit:w_fitLB
	WAVE w_fitLBsw = root:internalUse:fit:w_fitLBsw
	WAVE w_comp = root:internalUse:fit:w_FFcomposition
	WAVE w_par = root:internaluse:fit:parwave
	WAVE data = root:internaluse:fit:w_data
	WAVE w_guess = root:internaluse:fit:w_guess
	
	
	Variable x0, x1
	
	//print event
	
	if (event ==7 || (event == 2))
		parameter_wave_from_LB(w_fitLB, w_fitLBsw, w_comp)
		
		if (w_comp[2])	// resets dependency!...
			x0 = min(pnt2x(data,0),pnt2x(data,numpnts(data)-1))
			x1 = max(pnt2x(data,0),pnt2x(data,numpnts(data)-1))
			initConvComposedFitFn(w_par[5], 10, deltax(data), x0, x1)
			WAVE w_conv_y = root:internaluse:fit:w_conv_y
			calc_conv_waveform(w_par)
	
			w_guess = w_conv_y(x)
		else
			w_guess = composedFitFn(w_par,x)
		endif
	endif
	return 0
End





Static Function checkBoxDCEdcMdc(name,value)
	String name
	Variable value
	
	NVAR edc = root:internalUse:fit:gv_EDC
	
	Variable bVal
	strswitch (name)
		case "coe_cbEDC":
			bVal= 1
			edc = 1
			break
		case "coe_cbMDC":
			bVal= 2
			edc = 0
			break
		case "dat_cbEDC":
			bVal= 1
			edc = 1
			break
		case "dat_cbMDC":
			bVal= 2
			edc = 0
			break
	endswitch
	CheckBox coe_cbEDC,value= bVal==1
	CheckBox coe_cbMDC,value= bVal==2
	CheckBox dat_cbEDC,value= bVal==1
	CheckBox dat_cbMDC,value= bVal==2
End





Static Function checkBoxFitRange(name,value)
	String name
	Variable value
	
	NVAR c_range = root:internalUse:fit:gv_constantRange
	
	Variable bVal
	strswitch (name)
		case "dat_c0":
			bVal= 1
			c_range = 1
			break
		case "dat_c1":
			bVal= 2
			c_range = 0
			break
	endswitch
	CheckBox dat_c0,value= bVal==1
	CheckBox dat_c1,value= bVal==2
End





Static Function setVariableDCNumber(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	NVAR first = root:internalUse:fit:gv_firstDC
	NVAR last = root:internalUse:fit:gv_lastDC
	first = varNum
	last = first + 4
	SVAR path = root:internalUse:fit:gs_dataPath
	WAVE w_guess = root:internalUse:fit:w_guess
	
	Variable from, to
	
	if (waveexists($path))
		WAVE data = $path
		
		if (wavedims(data) == 1)
			Duplicate/o data root:internalUse:fit:w_data
		else
			ControlInfo coe_cbEDC
			if (v_value)	// EDCs
				Make/d/o/n=(dimsize(data,1)) DC
				DC = data[varNum][p]	
				from = utils_y0(data)
				to = utils_y1(data)
			else
				Make/d/o/n=(dimsize(data,0)) DC
				DC = data[p][varnum]	
				from = utils_x0(data)
				to = utils_x1(data)
			endif
			SetScale/I x from, to, "" DC, w_guess
			Duplicate/o DC root:internalUse:fit:w_data
		endif
	else
		DoAlert 0, "upload a wave first"
		abort
	endif
End





Static Function buttonGetCsrValues(ctrlName)
	String ctrlName
	
	NVAR from = root:internalUse:fit:gv_rangeFrom
	NVAR to = root:internalUse:fit:gv_rangeTo
	
	if (strlen(csrWave(A))==0 || strlen(csrWave(B))==0)
		DoAlert 0, "Both cursors must be on the graph!"
		abort
	endif
	
	from = min(xcsr(A), xcsr(B))
	to = max(xcsr(A), xcsr(B))
End





Static Function buttonTestFit(ctrlName)
	String ctrlName
	
	WAVE par = root:internalUse:fit:parwave
	WAVE w_hold = root:internalUse:fit:holdwave
	WAVE data = root:internaluse:fit:w_data
	WAVE w_guess = root:internaluse:fit:w_guess
	WAVE w_comp = root:internalUse:fit:w_FFcomposition
	
	//Variable/G v_FitQuitReason
	Variable/G v_FitOptions = 4
	Variable v_FitError = 0
	Variable v_fitNumIters
	
	Variable from, to, all_at_once
	Variable x0, x1
	Variable conv = w_comp[2]
	
	if (strlen(csrWave(A))==0 || strlen(csrWave(B))==0)
		DoAlert 0, "Cursors are not on graph!\ri_photo will fit the full data-range."
		from = pnt2x(data,0)
		to = pnt2x(data,numpnts(data)-1)
	else
		from = xcsr(A)
		to = xcsr(B)
		//if (abs(from-to) < 2)
		//	DoAlert 0, "Cursors must define more than 2 data-points!\ri_photo will fit the full data-range."
		//from = 0
		//to = numpnts(data)-1
		//endif
	endif


	String holdstr = ""
	Variable ii
	for(ii=0; ii< numpnts(w_hold); ii += 1)	
		holdstr += num2str(w_hold[ii])							
	endfor											
	
	
	if(conv)
		// initialize convolution
		x0 = min(from,to)
		x1 = max(from,to)
		initConvComposedFitFn(par[5], 10, deltax(data),x0, x1)	// oversampling=10
		// the 'max fit-range problem' seems to be independet of the initialization
		// calling from the igor dialog allows to fit a larger, but still limited range
		WAVE w_conv_y = root:internaluse:fit:w_conv_y

		Duplicate/o par epsilon		// the epsilon wave seems to solve most problems also here
		epsilon=1e-6
		FuncFit/n/q/H=holdstr fit#convComposedFitFn par  data(from,to) /E=epsilon
		//FuncFit/n/q/H=holdstr conv_composed_FitFn par  data(from,to) /E=epsilon
		//FuncFit/n/q/H=holdstr conv_composed_FitFn par  data(from,to) 
		
		calc_conv_waveform(par)
		w_guess = w_conv_y(x)
		LB_wave_from_parameter()
	else
		FuncFit/n/Q/H=holdstr fit#composedFitFn par  data(from,to) 
		w_guess = composedFitFn(par,x)
		LB_wave_from_parameter()
	endif
	
	if (v_FitError!=0)
		beep
		print "error in iteration ", v_fitnumiters
		abort
	else
		
	endif
	
	KillVariables/Z v_FitQuitReason, v_FitOptions
End





Static Function buttonFitStack(ctrlname)
	String ctrlname
	
	String DF = GetDataFolder (1)

	NVAR yOffset = root:internaluse:fit:gv_yOffset
	NVAR destPoints = root:internaluse:fit:gv_destPoints
	ControlInfo out_c10
	Variable fullwidth = v_value
	ControlInfo out_c11
	Variable buttonAddBkg = v_value
		
	SVAR outDF = root:internalUse:fit:gs_outputDF

	String intDF = outDF+"internal:"
	String DC_name, fit_name, base, bkg_name
	Variable x0, x1, nDC, y_off
	
	SetDataFolder $intDF
	WAVE w_comp = w_FFcomposition
	WAVE par_matrix = par_Matrix
	WAVE w_x0 = fit_range_x0
	WAVE w_x1 = fit_range_x1
	NVAR edc = gv_EDC
	NVAR first_DC = gv_first_DC
	NVAR last_DC = gv_last_DC
	NVAR step_DC = gv_step_DC
	SVAR dataPath = gs_dataPath
	WAVE M_data = $dataPath
	WAVE w_conv_y = root:internalUse:fit:w_conv_y
	
	Variable conv = w_comp[2]
	
	if (waveexists(m_data)==0)
		DoAlert 0, "An error occured. 'i_photo' could not identify the source data."
		abort
	endif
	
	SetDataFolder $outDF
	NewDataFolder/o/s DCs
	
	Duplicate/o root:internalUse:fit:w_FFcomposition w_store_comp
	Duplicate/o w_comp root:internalUse:fit:w_FFcomposition	// composedFitFn reads this wave
	
	// make DC and fit-wave
	Make/o/n=(dimsize(M_data,edc)) tempDC
	x0 = dimoffset(M_data,edc)
	x1 = dimoffset(M_data,edc) + (dimsize(M_data,edc)-1) * dimdelta(M_data,edc)
	SetScale/I x x0, x1, "" tempDC
	Make/o/n=(destPoints) temp_fit, temp_bkg
	
	Make/o/d/n=(dimsize(par_matrix,1)) w_par
	
	// extract DCs and calculate fits
	Display
	base = nameofwave(m_data)
	if (edc)
		base += "_e"
		Make /o/n=((last_DC-first_DC)/step_DC, dimsize(temp_fit,0)) fit_image //create the 2D wave for the image plot of the fit by Wei-Sheng
		Setscale /I y x0, x1,"" fit_image
		if(last_DC>first_DC)
			Setscale /I x (dimoffset(M_data,0) + (first_DC) * dimdelta(M_data,0)), (dimoffset(M_data,0) + (last_DC) * dimdelta(M_data,0)),"" fit_image
		else
			Setscale /I x (dimoffset(M_data,0) + (last_DC) * dimdelta(M_data,0)), (dimoffset(M_data,0) + (First_DC) * dimdelta(M_data,0)),"" fit_image
		endif
	else
		base += "_m"
		Make /o/n=(dimsize(temp_fit,0), (last_DC-first_DC)/step_DC) fit_image //creat the 2D wave for the image plot of the fit by Wei-Sheng
		setscale /I x x0, x1,"" fit_image
		if(last_DC>first_DC)
			Setscale /I y (dimoffset(M_data,1) + (first_DC) * dimdelta(M_data,1)), (dimoffset(M_data,1) + (last_DC) * dimdelta(M_data,1)),"" fit_image
		else
			Setscale /I y (dimoffset(M_data,1) + (last_DC) * dimdelta(M_data,1)), (dimoffset(M_data,1) + (First_DC) * dimdelta(M_data,1)),"" fit_image
		endif
	endif
	
	Variable ii
	ii = 0
	do
		nDC = ii*step_DC + first_DC
		if (edc)
			tempDC = M_data[nDC][p]
		else
			tempDC = M_data[p][nDC]
		endif
	
		w_par = par_Matrix[ii][p]
		if (fullwidth == 0)
			x0 = w_x0[nDC]
			x1 = w_x1[nDC]
		endif	// otherwise x0, x1 from above
		
		SetScale/I x x0,x1,"" temp_fit, temp_bkg
		
		if (conv)
			calc_conv_waveform(w_par)
			temp_fit = w_conv_y(x)
		else
			temp_fit = composedFitFn(w_par,x)
		endif
		
		DC_name = base+num2str(nDC)
		fit_name = "fit_"+base+num2str(nDC)
		bkg_name = "bkg_"+base+num2str(nDC)
		Duplicate/o tempDC $DC_name
		Duplicate/o temp_fit $fit_name
		
		if (edc)
			if(last_DC>first_DC)
				fit_image[ii][]=temp_fit(y)
			else
				fit_image[dimsize(fit_image,0)-1-ii][]=temp_fit(y)
			endif
		else
			if(last_DC>first_DC)
				fit_image[][ii]=temp_fit(x)
			else
				fit_image[][dimsize(fit_image,1)-1-ii]=temp_fit(x)
			endif
		endif
		y_off = yOffset * ii
		AppendToGraph $DC_name $fit_name
		ModifyGraph mode($DC_name)=3,marker($DC_name)=19,msize($DC_name)=1,mrkThick($DC_name)=0,rgb($DC_name)=(0,0,0)
		//ModifyGraph lsize($DC_name)=0.5, rgb($DC_name)=(0,0,0)
		ModifyGraph lsize($fit_name)=0.5
		ModifyGraph offset($DC_name)={0,y_off},offset($fit_name)={0,y_off}
		
		if (buttonAddBkg)
			w_par[10,inf] = 0
			temp_bkg = composedFitFn(w_par,x)
			Duplicate/o temp_bkg $bkg_name
			
			AppendToGraph $bkg_name
			ModifyGraph lsize($bkg_name)=0.5, offset($bkg_name)={0,y_off}, rgb($bkg_name)=(2,39321,1)
		endif
		
	ii += 1
	while( ii <= (last_DC-first_DC)/step_DC)
	
	ModifyGraph mirror=2
	if (edc)
		//Label bottom "energy"	
		Label bottom DC_axisLabel(note(M_data),"y")
	else
		//Label bottom "angle/momentum"
		Label bottom DC_axisLabel(note(M_data),"x")
	endif
		
	Duplicate/o w_store_comp root:internalUse:fit:w_FFcomposition
	
	KillWaves/Z w_store_comp, tempDC temp_fit, w_par
	SetDataFolder $DF
End




Static Function buttonNewParGraph(ctrlName)
	String ctrlName
	
	SVAR outDF = root:internalUse:fit:gs_outputDF
	NVAR edc = $outDF+"internal:gv_EDC"
	
	ControlInfo out_lb1
	string path = outDF+"par_waves:w"+num2str(v_value)
	Display $path
	
	ModifyGraph mode=3,marker=8
	ModifyGraph grid=1,mirror=2,gridRGB=(34952,34952,34952)
	String notestr = note($path)
	String lit = StringByKey("Parameter",notestr,"=","\r")
	Label left lit
	if (edc)
		Label bottom "angle/momentum"
	else
		Label bottom "energy"
	endif
	
End




Static Function listBoxProject(ctrlName,row,col,event) : ListBoxControl
	String ctrlName
	Variable row
	Variable col
	Variable event	//1=mouse down, 2=up, 3=dbl click, 4=cell select with mouse or keys
					//5=cell select with shift key, 6=begin edit, 7=end
	if (event ==4)
		WAVE/t w_project = root:internalUse:fit:w_fitProjects
		SVAR outDF = root:internalUse:fit:gs_outputDF
		outDF = "root:fits:"+w_project[row]+":"
		
		String Path = outDF+"internal:w_FFcomposition"
	
		nonTrivialCol(outDf,$Path)
	endif
	
	return 0
End





Static Function listBoxShowPar(ctrlName,row,col,event) : ListBoxControl
	String ctrlName
	Variable row
	Variable col
	Variable event	//1=mouse down, 2=up, 3=dbl click, 4=cell select with mouse or keys
					//5=cell select with shift key, 6=begin edit, 7=end
	if (event ==4)
		WAVE w_col = root:internalUse:fit:w_nonTrivialCol
		SVAR outDF = root:internalUse:fit:gs_outputDF
	
		string path = outDF+"par_waves:w"+num2str(row)
		Duplicate/o $path root:internalUse:fit:w_Par
	endif
	
	return 0
End





Static Function buttonRunFit(ctrlName)
	String ctrlName

	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse:fit
	
	// the globals:
	SVAR dataPath = gs_dataPath
	WAVE M_data = $dataPath
	WAVE w_comp = w_FFcomposition
	WAVE w_par = parwave	// initial parameter wave: don't change
	WAVE w_hold = holdwave
	NVAR EDC = gv_EDC
	NVAR first_DC = gv_firstDC
	NVAR last_DC = gv_lastDC
	NVAR step_DC = gv_stepDC
	NVAR quitReason = v_FitquitReason

	
	Variable mdc = abs(edc-1) // 1 if edc=0, 0 if edc=1
	Variable conv = w_comp[2]
	Variable ii, x0, x1, p0, p1, nDC
	Variable x0_min, x0_max, x1_min, x1_max
	String holdstr
	
	if (wavedims(M_data) != 2)
		DoAlert 0, "this works only for 2D waves. try the 'test' button in 'coefficients' for 1D waves."
		abort
	endif
	
	
	
	// folder to store results (function runs from this folder):
	SetDataFolder root:
	NewDataFolder/o/s fits
	String propName = nameofwave(M_data)+"_sf"
	propName = UniqueName(propName,11,0)
	String outDF = "root:fits:"+propName+":"
	NewDataFolder/o/s $propName
	NewDataFolder/o/s internal
	
		Variable/G v_fitoptions = 4
		Variable v_FitError
		//Variable all_at_once
		
		// fit range
		generate_range_waves()
		WAVE fit_range_p0
		WAVE fit_range_p1
		WAVE fit_range_x0
		WAVE fit_range_x1
		
		
		// parameter matrix: columns are the individual parameters, dim0 is scaled
		//Bug fix for step is negative! By Wei-Sheng 071605
		Make/o/d/n=(( abs(last_DC-first_DC)+1)/abs(step_DC), numpnts(w_par)) par_Matrix
		x0 = dimoffset(M_data,mdc) + dimdelta(M_data,mdc)*first_DC
		x1 = dimoffset(M_data,mdc) + dimdelta(M_data,mdc)*last_DC
		SetScale/I x x0, x1, "" par_Matrix
		//Add sigma_Matrix to record the error of the fitting parameters
		Duplicate /O 	par_Matrix sigma_Matrix
			
		// generate temporary 1D wave to fit
		Make/o/d/n=(dimsize(M_data,edc)) tempDC
		x0 = dimoffset(M_data,edc)
		x1 = dimoffset(M_data,edc) + (dimsize(M_data,edc)-1) * dimdelta(M_data,edc)
		SetScale/I x x0, x1, "" tempDC
		
		// initialize convolution
		if(conv)
			WaveStats/Q fit_range_x0
			x0_min = v_min
			x0_max = v_max
			WaveStats/Q fit_range_x1
			x1_min = v_min
			x1_max = v_max
			initConvComposedFitFn(w_par[5], 10, dimdelta(M_data,edc), min(x0_min,x1_min), max(x0_max,x1_max))	// oversampling=10
		endif
	
		
		// holdstr
		holdstr = ""
		for(ii=0; ii< numpnts(w_hold); ii += 1)	
			holdstr += num2str(w_hold[ii])							
		endfor			
		
		
		// run the fits:
		Duplicate w_par coef, epsilon	// the magic epsilon wave seems to help also here
		epsilon = 1e-6
		//the following is implemented by Wei-Sheng
		//Add some random noise to the initial value of the fitting parameter 
		ii = 0
		do
			v_FitError = 0	// no error alert
			nDC = ii*step_DC + first_DC
			//coef = coef[p]+gnoise(0.01*coef[p],1)
			if (edc)
				tempDC = M_data[nDC][p]
			else
				tempDC = M_data[p][nDC]
			endif
			p0 = fit_range_p0[nDC]
			p1 = fit_range_p1[nDC]
			
			if (conv)
				FuncFit/N/Q/H=holdstr fit#convComposedFitFn coef tempDC[p0, p1] /E=epsilon /F={0.997, 4}
			else
				FuncFit/N/Q/H=holdstr fit#composedFitFn coef  tempDC[p0, p1] /E=epsilon /F={0.997,4}
			endif
			
			if (utils_progressDlg(message="fit: performing multiple fit", numDone = ii, numTotal = (last_DC-first_DC)/step_DC))
				break
			endif
			
			WAVE w_sigma
			WAVE W_ParamConfidenceInterval
				
			if (v_FitError == 0)
				par_Matrix[ii][] = coef[q]
				//sigma_Matrix[ii][] =  w_sigma[q]
				sigma_Matrix[ii][] = W_ParamConfidenceInterval[q] // Record the error bar for 95% confidence level, Refer to Igor manual for detail
			else
				print "fit ofDC",nDC,"did not converge"
				par_Matrix[ii][] = NaN
				sigma_Matrix[ii][] =  Nan
			endif
	
		ii += 1
		while( ii <= (last_DC-first_DC)/step_DC)
	
	utils_progressDlg(done = 1)
	
	// store definitions
	Duplicate/o w_comp w_FFcomposition
	String/G gs_dataPath = dataPath
	Variable/G gv_EDC = edc
	Variable/G gv_first_DC = first_DC
	Variable/G gv_last_DC = last_DC
	Variable/G gv_step_DC = step_DC
	String/G gs_holdStr = holdstr
	
	// update interface
	project_wave()
	// store interpretation of par-matrix:
	nonTrivialCol(outDF,w_comp)
	// extract parameters:
	extract_par_waves(outDF)
	
	KillWaves/Z coef, tempDC, w_ParamConfidenceInterval, w_sigma
	KillVariables/Z v_FitOptions, v_FitQuitReason
	SetDataFolder $DF
End




// This function is for the extraction of the peak position only, no any fitting process. by Wei-Sheng Lee @ 2/14/05
Static Function buttonPeakDispersion(ctrlName)
	String ctrlName
	
	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse:fit
	
	// the globals:
	SVAR dataPath = gs_dataPath
	WAVE M_data = $dataPath
	NVAR EDC = gv_EDC
	NVAR first_DC = gv_firstDC
	NVAR last_DC = gv_lastDC
	NVAR step_DC = gv_stepDC
	NVAR quitReason = v_FitquitReason
	NVAR RangeFrom = gv_rangeFrom
	NVAR RangeTo = gv_rangeto
	
	Variable mdc = abs(edc-1) // 1 if edc=0, 0 if edc=1
	Variable ii, x0, x1, p0, p1, nDC
	Variable FitPeak_min, FitPeak_max

	if (wavedims(M_data) != 2)
		DoAlert 0, "this works only for 2D waves. try the 'test' button in 'coefficients' for 1D waves."
		abort
	endif
	
	
	// folder to store results (function runs from this folder):
	SetDataFolder root:
	NewDataFolder/o/s fits
	String propName = nameofwave(M_data)+"_sf"
	propName = UniqueName(propName,11,0)
	String outDF = "root:fits:"+propName+":"
	NewDataFolder/o/s $propName
	make /n=((last_DC-first_DC)/step_DC +1) P_Disp
	
	x0 = dimoffset(M_data,mdc) + dimdelta(M_data,mdc)*first_DC
	x1 = dimoffset(M_data,mdc) + dimdelta(M_data,mdc)*last_DC

	setscale /I x 	x0,x1,"" P_Disp
	
		
	// generate temporary 1D wave to extract the maximum
		Make/o/d/n=(dimsize(M_data,edc)) tempDC
		x0 = dimoffset(M_data,edc)
		x1 = dimoffset(M_data,edc) + (dimsize(M_data,edc)-1) * dimdelta(M_data,edc)
		SetScale/I x x0, x1, "" tempDC
	
	ii = 0
		do
			nDC = ii*step_DC + first_DC
			if (edc)
				tempDC = M_data[nDC][p]
			else
				tempDC = M_data[p][nDC]
			endif
			
			wavestats /R=(RangeFrom, RangeTo) /Q  tempDC			 
			FitPeak_min = V_maxloc - 0.02 * abs(x0-x1)
			FitPeak_max = V_maxloc + 0.02 * abs(x0-x1)
			CurveFit/Q lor, tempDC (FitPeak_min, fitPeak_max) /D
			wavestats  /Q  fit_tempDC
			P_Disp[ii] = V_maxloc	
		ii += 1
		while( ii <= (last_DC-first_DC)/step_DC)
		
		KillWaves/Z tempDC, fit_tempDC, W_coef, W_sigma, W_ParamConfidenceInterval
		
End























////////////////////////////////////////
//
// Private Functions
//
////////////////////////////////////////



























	
	
// fit ARPES spectra

// the composition of the fitfunction is defined by 'w_FFcomposition'
// w_FFcomposition[0] = 1: multiply with Fermi
// w_FFcomposition[1] = 1: offset above EF
// w_FFcomposition[2] = 1: convolve with Gaussian
// w_FFcomposition[3] = n: item in bkg-list (n=0: no bkg.)
// w_FFcomposition[4,m] = n: item in peak-list (n=0: no peak)

Static Function init()

	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse
	NewDataFolder/o/s fit
	
	make/o/n=4 w_FFcomposition = 0		//{0,0,0,1}
	Make/o/t/n=(5,4) w_fitLB
	Make/o/n=(5,4) w_fitLBsw
	
	// composer list-box waves and comment waves
	LoadWave/O/Q/T/P = i_photo_pathSupplemental "w_fitfunc_comments.itx"
	WAVE/T w_peakfunc_comments
	WAVE/T w_bkgfunc_comments
	
	make/o/t/n=(dimsize(w_peakfunc_comments,1),1) w_peakfuncLB	
	w_peakfuncLB[][0] = w_peakfunc_comments[0][p]
	SetDimLabel 1,0, peak_shape, w_peakfuncLB
	make/o/t/n=(dimsize(w_bkgfunc_comments,1),1) w_bkgfuncLB
	w_bkgfuncLB[][0] = w_bkgfunc_comments[0][p]
	SetDimLabel 1,0, background, w_bkgfuncLB

	// output listbox
	make/t/o/n=(1,1) w_fitprojects="_none"
	SetDimLabel 1,0, active_project, w_fitprojects
	make/t/o/n=(1,1) wt_NonTrivialCol="_none"
	SetDimLabel 1,0, parameter_waves, wt_NonTrivialCol
	
	// par-waves
	make/n=10/o/d holdwave, parwave=0
	
	// guess-wave and data-wave
	make/d/o/n=200 w_data = 0
	SetScale/I x -1,0,"" w_data
	Duplicate/o w_data w_guess
	//SetFormula w_guess, "composedFitFn(parwave,x)"
	w_data = (0.15^2/4) / ((x+0.5)^2+0.15^2/4) + gnoise(0.02)
	make/n=5/o/d w_par = NaN
	
	
	Variable/G v_FitOptions = 4
	Variable/G v_FitQuitReason = 0
	Variable/G gv_DC
	Variable/G gv_EDC = 0	// i.e. MDCs
	Variable/G gv_firstDC
	Variable/G gv_lastDC
	Variable/G gv_stepDC = 1
	Variable/G gv_constantRange = 1
	Variable/G gv_rangeFrom
	Variable/G gv_rangeto
	Variable/G gv_maxFrom
	Variable/G gv_maxTo
	Variable/G gv_maxPlus
	Variable/G gv_maxMinus
	Variable/G gv_DCcsrA
	Variable/G gv_DCcsrB
	Variable/G gv_previousTab
	Variable/G gv_destPoints = 200
	Variable/G gv_yOffset = 10
	Variable/G gv_peak=0
	
	String/G gs_dataPath = "_no data selected_"
	String/G gs_literalFF = ""
	String/G gs_outputDF
	
	// and the ultimate hack...
//	String/G gs_toggleCoef = ""
//	Dowindow/K toggle_panel
//	NewPanel
//	DoWindow/C toggle_panel
//	SetVariable tog_sv0, size={180,15},value=gs_toggleCoef
//	DoWindow/B toggle_panel
	
	SetDataFolder $DF
End






Static Function/S FF_string(w)
	WAVE w
	
	String lit = " ("		// the first two chars are empty, which allows to add brackets later
	WAVE/t w_peaks = root:internalUse:fit:w_peakfuncLB
	WAVE/t w_bkg = root:internalUse:fit:w_bkgfuncLB
	
	
	Variable index = 4
	do
		if (w[index] > 0)
			lit += w_peaks[w[index]]+" + "
		endif
	index += 1
	while (index < numpnts(w))
	lit = lit[0,strlen(lit)-4]	// cut the last ' + '
	
	// bkg
	if (w[3] > 0)
		if (numpnts(w) > 4)
			lit += " + "
		endif
		lit += w_bkg[w[3]]+"-bkg.)"
	else
		lit += ")"
	endif
	
	if (w[0])
		lit += " * Fermi-func."
	endif
	
	if (w[1])
		lit += " + offset"
	endif
	
	if (w[2])
		lit += ") x Gaussian"
		lit[0]="("
	endif
		
	return lit
End




// columns of the guess-LB-wave:
// [0,2n-1]: n peaks
// [2n,2n+1]: bkg
// [2n+2,2n+3]: Fermi,offset,Gaussian-FWHM

Static Function make_LBguess_waves(w_comp)
	WAVE w_comp
	
	String str
	
	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse:fit
	
	WAVE/t w_peaks = root:internalUse:fit:w_peakfuncLB
	WAVE/t w_peakfunc_comments
	WAVE/t w_bkgfunc_comments
	WAVE/t w_F_off_conv_comments
	
	Variable parnum, col, peak_id
	
	// make the waves
	Variable ncol = (numpnts(w_comp)-4) * 3
	if (sum(w_comp,0,2) > 0)
		ncol += 3
	endif
	if (w_comp[3]>0)
		ncol += 3
	endif
	ncol = max(ncol,1)
	Variable nrow =  5
	Make/o/t/n=(nrow,ncol) w_fitLB
	Make/o/n=(nrow,ncol) w_fitLBsw = 0
	
	// hold-checkboxes:
	w_fitLBsw[][2;3] = 32
	
	// dimlabels and comment-entries
	// peaks
	Variable index = 4
	do
		if (numpnts(w_comp)==4)
			break
		endif
		peak_id = w_comp[index]
		col = (index-4)*3
		str = w_peaks[peak_id]	
		SetDimLabel 1,col,$str, w_fitLB
		SetDimLabel 1,col+1,start_val, w_fitLB
		w_fitLB[][col] = w_peakfunc_comments[p+1][peak_id]
		w_fitLBsw[][col+1] = 2
		
		parnum = str2num(w_peakfunc_comments[7][peak_id])
		if (parnum < dimsize(w_fitLBsw,0))
			w_fitLBsw[parnum,inf][col+1,col+2] = 0
		endif
		//print parnum
	index += 1
	while (index < numpnts(w_comp))
	
	// bkg
	if (w_comp[3]>0)
		col = (index-4)*3
		SetDimLabel 1, col, bkg, w_fitLB
		SetDimLabel 1, col+1, start_val, w_fitLB
		w_fitLB[][col] = w_bkgfunc_comments[p+1][w_comp[3]]
		w_fitLBsw[][col+1] = 2
		
		parnum = str2num(w_bkgfunc_comments[7][w_comp[3]])
		w_fitLBsw[parnum,inf][col+1,col+2] = 0
		index += 1
	endif
	
	// Fermi & conv
	if (sum(w_comp,0,2) > 0)
		col = (index-4)*3
		SetDimLabel 1, col, Fermi_conv, w_fitLB
		SetDimLabel 1, col+1, start_val, w_fitLB
		w_fitLB[][col] = w_F_off_conv_comments[p]
		w_fitLBsw[][col+1] = 2
		
		if (w_comp[0] == 0)
			w_fitLBsw[0,1][col+1,col+2] = 0
			w_fitLB[0,1][col] = ""
		endif
		if (w_comp[1] == 0)
			w_fitLBsw[2,3][col+1,col+2] = 0
			w_fitLB[2,3][col] = ""
		endif
		if (w_comp[2] == 0)
			w_fitLBsw[4][col+1,col+2] = 0
			w_fitLB[4][col] = ""
		endif
		
		index += 1
	endif
	

	SetDataFolder $DF
End





// write the parameters back in the listbox-wave
Static Function LB_wave_from_parameter()

	WAVE/t w_fitLB = root:internaluse:fit:w_fitLB
	WAVE w_comp = root:internalUse:fit:w_FFcomposition
	WAVE w_par = root:internalUse:fit:parwave
	WAVE/t w_peak_comm = root:internaluse:fit:w_peakfunc_comments
	WAVE/t w_bkg_comm = root:internaluse:fit:w_bkgfunc_comments
	
	//peaks
	Variable ii = 4
	Variable LBcol = 1
	Variable npnts, n
	do
		npnts = str2num(w_peak_comm[7][w_comp[ii]])
		for (n=0;n<npnts;n+=1)
			w_fitLB[n][LBcol] = num2str(w_par[10+(ii-4)*5+n]) 
		endfor
		LBcol += 3
	ii += 1
	while (ii < numpnts(w_comp))
	
	// bkg
	if (w_comp[3] > 0)
		n = 0
		npnts = str2num(w_bkg_comm[7][w_comp[3]])
		for (n=0;n<npnts;n+=1)
			w_fitLB[n][LBcol] = num2str(w_par[6+n]) 
		endfor
		LBcol += 3
	endif
	
	// Fermi
	if(w_comp[0])
		w_fitLB[0][LBcol] = num2str(w_par[0])
		w_fitLB[1][LBcol] = num2str(w_par[1])
	endif
	
	// offset
	if(w_comp[1])
		w_fitLB[2][LBcol] = num2str(w_par[2])
		w_fitLB[3][LBcol] = num2str(w_par[3])
	endif
	
	// convolution
	if(w_comp[2])
		w_fitLB[4][LBcol] = num2str(w_par[5])
	endif
	
End





Static Function parameter_wave_from_LB(w_fitLB, w_fitLBsw,w_comp)
	WAVE/t w_fitLB; WAVE w_fitLBsw, w_comp
	
	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse:fit
	
	Variable peaknum = numpnts(w_comp)-4
	Variable parnum = 10 + 5* peaknum
	Variable p0
	Make/o/d/n=(parnum) parwave, holdwave = 1
	
	Make/o/n=5/t wt_peakpar
	Make/o/n=5 w_holdsw
	
	// peaks
	Variable i_peak = 0
	do
		p0 = 10 +  i_peak*5
		wt_peakpar = w_fitLB[p][3*i_peak+1]
		w_holdsw = w_fitLBsw[p][3*i_peak+2]
		w_holdsw = (w_holdsw < 48 && w_holdsw > 0)? (0):1	// hold-checkbox not checked
		utils_text2FPwave(wt_peakpar)
		WAVE FP_wave
		parwave[p0,p0+5] = FP_wave[p-p0]
		holdwave[p0,p0+5] = w_holdsw[p-p0]
		
	i_peak += 1
	while (i_peak < peaknum)
	
	// bkg
	if (w_comp[3] > 0)
		wt_peakpar = w_fitLB[p][3*i_peak+1]
		w_holdsw = w_fitLBsw[p][3*i_peak+2]
		w_holdsw = (w_holdsw < 48 && w_holdsw > 0)? (0):1
		utils_text2FPwave(wt_peakpar)
		WAVE FP_wave
		parwave[6,9] = FP_wave[p-6]		//+10+i_peak*5]
		holdwave[6,9] = w_holdsw[p-6]
		i_peak +=1
	endif
	
	// Fermi & offset & Gaussian
	if (sum(w_comp,0,2)>0)
		wt_peakpar = w_fitLB[p][3*i_peak+1]
		w_holdsw = w_fitLBsw[p][3*i_peak+2]
		w_holdsw = (w_holdsw < 48 && w_holdsw > 0)? (0):1
		utils_text2FPwave(wt_peakpar)
		parwave[0,3] = FP_wave[p]	// the second order term for the offset doesn't appear in the LB
		parwave[5] = FP_wave[4]
		
		holdwave[0,3] = w_holdsw[p]
		holdwave[5] = w_holdsw[4]
	endif
	
	parwave = ((numtype(parwave))==2)?(0):parwave		// replace NaNs
	
	KillWaves/Z FP_wave, wt_peakpar
	SetDatafolder $DF
End





Static Function extract_par_waves(outDF)
	String outDF

	String DF = GetDataFolder (1)
	String name, lit, notestr
	Variable col
	
	//SVAR outDF = root:internalUse:fit:gs_outputDF
	SetDataFolder $(outDF+"internal")
	
	SVAR dataPath = gs_dataPath
	WAVE w_NonTrivialCol
	WAVE par_Matrix
	WAVE/t wt_NonTrivialCol
	Wave sigma_Matrix
	
	SetDataFolder $outDF
	NewDataFolder/o/s par_waves
	
	Make/o/n=(dimsize(par_Matrix,0)) w_par
	SetScale/I x utils_x0(par_Matrix), utils_x1(par_Matrix),"" w_par
	duplicate /O w_par w_sigma
	Variable ii
	for (ii = 0; ii < numpnts(w_NonTrivialCol); ii+=1)
		name = "w"+num2str(ii)
		lit = wt_NonTrivialCol[ii]
		col = w_NonTrivialCol[ii]
		w_par = par_Matrix[p][col]
		w_sigma = sigma_Matrix[p][col]
		
		notestr = "SourceData="+dataPath+"\rParameter="+lit+"\r"
		Note/K w_par
		Note w_par, notestr
		Duplicate/o w_par $name
		name = "w"+num2str(ii)+"_sigma"
		Duplicate/o w_sigma $name
	endfor
	
	KillWaves/Z w_par, w_sigma
	
	SetDataFolder $DF
End





Static Function project_wave()

	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse:fit
	
	WAVE/t wt = w_fitprojects
	WAVE w_comp = w_FFcomposition
	WAVE parWave = parWave
	
	Variable ii, p0
	
	// project list
	Variable n = CountObjects("root:fits:",4)
	if (n >= 1)
		Redimension/N=(n,-1) wt	
		for(ii=0;ii<n;ii+=1)
			wt[ii] = GetIndexedObjName("root:fits:",4,ii) 
		endfor	
	endif
	SetDataFolder $DF
End





// generate a wave, which stores the non-empty column-numbers of par_Matrix,
// and a comment wave with a description of these columns	
Static Function nonTrivialCol(outDF,w_comp)
	String outDF; WAVE w_comp

	Variable p0, ii, n, ip
	String DF = GetDataFolder (1)
	//SetDataFolder root:internaluse:fit
	SetDataFolder $(outDF+"internal")
	
	WAVE/t bkg_comm = root:internaluse:fit:w_bkgfunc_comments
	WAVE/t peak_comm = root:internaluse:fit:w_peakfunc_comments
	
	Make/o/n=0 w_NonTrivialCol
	Make/t/o/n=0 wt_NonTrivialCol		
	if (w_comp[0])
		InsertPoints 0,2, w_NonTrivialCol,wt_NonTrivialCol
		w_NonTrivialCol[0,1] = p
		wt_NonTrivialCol[0] = "Fermi-level"
		wt_NonTrivialCol[1] = "Temperature"
	endif
	
	if (w_comp[1])
		p0 = numpnts(w_NonTrivialCol)
		InsertPoints p0,2, w_NonTrivialCol,wt_NonTrivialCol
		w_NonTrivialCol[p0] = 2
		w_NonTrivialCol[p0+1] = 3
		//w_NonTrivialCol[p0+1] = 4
		wt_NonTrivialCol[p0] = "offset w0"
		wt_NonTrivialCol[p0+1] = "ofset w1"
		//wt_NonTrivialCol[p0+1] = "above EF w2"
	endif
	if (w_comp[2])
		p0 = numpnts(w_NonTrivialCol)
		InsertPoints p0,1, w_NonTrivialCol,wt_NonTrivialCol
		w_NonTrivialCol[p0] = 5
		wt_NonTrivialCol[p0] = "Resolution (FWHM)"
	endif
	
	// background
	if (w_comp[3]>0)
		p0 = numpnts(w_NonTrivialCol)
		n = str2num(bkg_comm[7][w_comp[3]])
		InsertPoints p0,n, w_NonTrivialCol,wt_NonTrivialCol
		
		ii = 0
		do
			w_NonTrivialCol[p0+ii] = 6+ii
			wt_NonTrivialCol[p0+ii] = bkg_comm[ii+1][w_comp[3]]+ "-bkg" 
		ii += 1
		while (ii < n)
	endif
	
	// peaks
	ip = 4
	do
		if (ip >= numpnts(w_comp))
			break
		endif
		
		p0 = numpnts(w_NonTrivialCol)
		n = str2num(peak_comm[7][w_comp[ip]])
		InsertPoints p0,n, w_NonTrivialCol,wt_NonTrivialCol
		
		ii = 0
		do
			w_NonTrivialCol[p0+ii] = 10 + 5*(ip-4)+ii
			wt_NonTrivialCol[p0+ii] = peak_comm[0][w_comp[ip]] + "-" + peak_comm[ii+1][w_comp[ip]] 
		ii += 1
		while (ii < n)
	ip += 1
	while (1)
	
	Redimension/N=(-1,1) wt_NonTrivialCol
	SetDimLabel 1,0, parameter_waves, wt_NonTrivialCol
	
	Duplicate/o w_NonTrivialCol root:internaluse:fit:w_NonTrivialCol
	Duplicate/t/o wt_NonTrivialCol root:internaluse:fit:wt_NonTrivialCol
	
	SetDataFolder $DF
End






// generates waves containing x and p values with the fit-boundaries for the DCs to be fitted
// the waves are scaled, i.e. like MDCs, if EDCs are fitted and vice-versa
Static Function generate_range_waves()

	// globals for input:
	SVAR dataPath = root:internalUse:fit:gs_dataPath
	WAVE M = $dataPath
	NVAR edc = root:internalUse:fit:gv_EDC
	NVAR constantRange = root:internalUse:fit:gv_constantRange
	NVAR rangeFrom = root:internalUse:fit:gv_rangeFrom
	NVAR rangeTo = root:internalUse:fit:gv_rangeTo
	NVAR maxFrom = root:internalUse:fit:gv_maxFrom
	NVAR maxTo = root:internalUse:fit:gv_maxTo
	NVAR maxPlus = root:internalUse:fit:gv_maxPlus
	NVAR maxMinus = root:internalUse:fit:gv_maxMinus
	NVAR first = root:internalUse:fit:gv_firstDC
	NVAR last = root:internalUse:fit:gv_lastDC
	NVAR step = root:internalUse:fit:gv_stepDC
	
	Variable ii
	
	if (edc)
		Make/o/n=(dimsize(M,1)) tempDC
		SetScale/I x utils_y0(M), utils_y1(M), "" tempDC
		Make/o/n=(dimsize(M,0)) fit_range_p0 = NaN
		SetScale/I x utils_x0(M), utils_x1(M), "" fit_range_p0
		Duplicate/o fit_range_p0 fit_range_p1, fit_range_x0, fit_range_x1
		
		if (constantRange)
		//The following are remarked for bug fixing for the case of negative step By Wei-Sheng 071605
//			fit_range_x0[first,last;step] = rangeFrom
//			fit_range_x1[first,last;step] = rangeTo
//			fit_range_p0[first,last;step] = x2pnt(tempDC,rangeFrom)
//			fit_range_p1[first,last;step] = x2pnt(tempDC,rangeTo)
			fit_range_x0[min(first,last), max(first,last);abs(step)] = rangeFrom
			fit_range_x1[min(first,last), max(first,last);abs(step)] = rangeTo
			fit_range_p0[min(first,last), max(first,last);abs(step)] = x2pnt(tempDC,rangeFrom)
			fit_range_p1[min(first,last), max(first,last);abs(step)] = x2pnt(tempDC,rangeTo)
		else
			for (ii = first; ii <= last; ii += step)	// dynamical range
				tempDC = M[ii][p]
				Wavestats/Q/R=(maxFrom, maxTo) tempDC
				fit_range_x0[ii] = v_maxloc - maxMinus
				fit_range_x1[ii] = v_maxloc + maxPlus
				fit_range_p0[ii] = x2pnt(tempDC,v_maxloc - maxMinus)
				fit_range_p1[ii] = x2pnt(tempDC,v_maxloc + maxPlus)
			endfor
		endif
	else		// MDCs
		Make/o/n=(dimsize(M,0)) tempDC
		SetScale/I x utils_x0(M), utils_x1(M), "" tempDC
		Make/o/n=(dimsize(M,1)) fit_range_p0
		SetScale/I x utils_y0(M), utils_y1(M), "" fit_range_p0
		Duplicate/o fit_range_p0 fit_range_p1, fit_range_x0, fit_range_x1
		
		if (constantRange)
		//The following are remarked for bug fixing for the case of negative step By Wei-Sheng 071605
//			fit_range_x0[first,last;step] = rangeFrom
//			fit_range_x1[first,last;step] = rangeTo
//			fit_range_p0[first,last;step] = x2pnt(tempDC,rangeFrom)
//			fit_range_p1[first,last;step] = x2pnt(tempDC,rangeTo)
			fit_range_x0[min(first,last), max(first,last);abs(step)] = rangeFrom
			fit_range_x1[min(first,last), max(first,last);abs(step)] = rangeTo
			fit_range_p0[min(first,last), max(first,last);abs(step)] = x2pnt(tempDC,rangeFrom)
			fit_range_p1[min(first,last), max(first,last);abs(step)] = x2pnt(tempDC,rangeTo)
		else
			for (ii = first; ii <= last; ii += step)	// dynamical range
				tempDC = M[p][ii]
				Wavestats/Q/R=(maxFrom, maxTo) tempDC
				fit_range_x0[ii] = v_maxloc - maxMinus
				fit_range_x1[ii] = v_maxloc + maxPlus
				fit_range_p0[ii] = x2pnt(tempDC,v_maxloc - maxMinus)
				fit_range_p1[ii] = x2pnt(tempDC,v_maxloc + maxPlus)
			endfor
		endif
	endif
	
	KillWaves/Z tempDC, fit_tempDC, W_coef, W_sigma, W_ParamConfidenceInterval
End





//------------------------------------------------------------------------------------------------------
//
// The following are the Fit functions:
//
//





// parameters:
// w[0,1]: Fermi
// w[2,4]: offset
// w[5]: Gaussian FWHM
// w[6,9]: bkg
// w[10,14]: peak1
// w[15,19]: peak2...


Static Function composedFitFn(w,x)
	WAVE w;Variable x
	
	WAVE w_comp = root:internalUse:fit:w_FFcomposition
	Wave w_data = root:internalUse:fit:w_data
	Variable peak,bkg, fermi, offset, par0
	Variable aux0, ds0, ds1
	
	// Fermi-function
	Variable kB=8.617385e-5 	
	if (w_comp[0])
		fermi = 1/(exp((x-w[0]) / (kB*w[1]))+1.0 )
	else
		fermi = 1
	endif
	
	// offset above EF: w[2,4]
	if (w_comp[1])
		offset = w[2] + w[3] * x + w[4]*x*x
	else
		offset = 0
	endif
	
	// background: w[6,9]
	if (w_comp[3]>0)
		switch(w_comp[3])	
			case 1:		
				bkg = w[6]
				break					
			case 2:		
				bkg = w[6] + w[7]*x + w[8]*x*x
				break
			case 3:		
				bkg = w[6] + w[7]*x + w[8]*x*x + w[9]*x*x*x
				break			
			case 4:			
				bkg = w[6] + w[7]* exp(w[8]*x)
				break
			case 5:
				//bkg = (w[6]+w[7]*x) / (exp( (x-w[8])/(w[9]*8.617e-5))+1)
				bkg = (w[6]+w[7]*x) / (exp( (x-w[8])/abs(w[8]*0.3))+1)
				break
			case 6:
				bkg = w[6] * area(w_data, x,0)
		endswitch
	endif
	
	// peaks:
	Variable npeaks = numpnts(w_comp)-4
	Variable i_peaks
	peak = 0
	for(i_peaks=0; i_peaks<npeaks; i_peaks+=1)	
		
		par0 = 10+ i_peaks*5
		
		switch(w_comp[i_peaks+4])	
			case 1:		
				// Lorentzian
				peak += (w[par0+1]*w[par0+2]^2/4) / ((x-w[par0])^2+w[par0+2]^2/4) 
				break					
			case 2:		
				// Gaussian		
				aux0 = 2*sqrt(ln(2))
				peak += w[par0+1]*exp(-((x-w[par0])/(w[par0+2]/aux0))^2) 
				break		
			case 3:	
				// Doniach-Sunjic
				// w0: position
				// w1: intensity
				// w2: gamma			
				// w3: alpha
				ds0 = w[par0+1]*cos(pi*w[par0+3]/2+(1-w[par0+3])*atan((x-w[par0])/w[par0+2])) 	// nominator
				ds1 = ((x-w[par0])^2+w[par0+2]^2)^((1-w[par0+3])/2)									// denominator
				peak += ds0/ds1
				break
			case 4:
				// Fermi-liquid
				// requires Fermi-funciton parameters
				aux0 = w[par0+2] + w[par0+3]* ((x-w[0])^2 + (pi*kB*w[1])^2)	// self energy with impurity scattering
				//peak += (w[par0+1]*aux0^2/pi) / ((x-w[par0])^2+aux0^2)	// corrected 06-08-04
				peak += (w[par0+1]*aux0/pi) / ((x-w[par0])^2+aux0^2)
				break
			case 5:
				// marginal Fermi-liquid
				// requires Fermi-funciton parameters
				aux0 = w[par0+2] + w[par0+3]* pi*0.5* (x-w[0])	// self energy with impurity scattering
				peak += (w[par0+1]*aux0/pi) / ((x-w[par0])^2+aux0^2)
				break
			case 6:
				// "empirical FL"
				aux0 = w[par0+2] + w[par0+3]*x + w[par0+4]*x*x
				peak += (w[par0+1]*aux0/pi) / ((x-w[par0])^2+aux0^2/4)
				break
			//The following function is added by Wei-Sheng
			case 7:
				//MDC lineshape with bare band in second order in k
				peak += w[par0+1] / (  (  (x - w[par0])^2 + w[par0+2])^2 + w[par0+3]^2)
				break
			case 8:
				//"gapped Fermi Liquid  //by Wei-Sheng
				if (  x > abs(w[par0]) || x < (-1*abs(w[par0]))    )
				aux0 = w[par0+2] + abs(w[par0+3])* ((x-w[par0])^2 + (pi*kB*w[1])^2)
				else
				aux0=0
				endif				
				peak += (w[par0+1]*aux0/pi) / ((x-w[par0])^2+aux0^2)
				break
			case 9:
				//gapped SC lineshape, only valid for Kf
				variable /C sigma, Green, sig_gap, sig_FL, sig_gap_num, sig_gap_dom, sig
				variable gamma0
				
				sig_gap_num = cmplx(w[par0]*w[par0],0)
				
				//gamma0 = abs(w[par0+1]) + abs(w[par0+2])*abs(x)+abs(w[par0+3])*abs(x)^3  // The phenomenology model from PRB 57, pR11093
				
				if (  x > abs(w[par0]) || x < (-1*abs(w[par0]))    )
				
				gamma0 = abs(w[par0+1]) + abs(w[par0+2])* sqrt(x^2-w[par0]^2)/abs(x)
				else
				gamma0 = abs(w[par0+1])
				endif	
				 
				sig_gap_dom = cmplx(x, gamma0)
					
				sig_gap = sig_gap_num/sig_gap_dom
				
				sig = sig_gap - cmplx(0,1)*gamma0
				
				Green = w[par0+3] / ( x- sig)
				
				peak +=  -imag(Green) / pi
				break
			case 10:
				//gapped SC lineshapr with isotropic scattering under Born scattering. Clean limit.
				variable gap_0, d_pos, pre
				
				gamma0 = w[par0]
				gap_0 = w[par0+1]
				d_pos=w[par0+2]
				
				pre = -1*Gamma0 * 2 * x/(pi*gap_0)
				sigma = pre * ( ln( 4*gap_0/x ) + cmplx(0,1)*0.5*pi)
				Green = w[par0+3] * ( x -sigma) / ( ( x-sigma)^2 - (gap_0 * d_pos)^2)
				peak +=  -imag(Green) / pi
				break
			case 11:
				//gapped SC lineshapr with isotropic scattering under Born scattering dirty-limit.
				
				gamma0 = w[par0]
				gap_0 = w[par0+1]
				d_pos=w[par0+2]
				
				pre = -1*Gamma0 * 2 * ln(4*gap_0/Gamma0) /pi
				sigma = pre * cmplx(x/gap_0, Gamma0/gap_0)
				Green = w[par0+3] * ( x -sigma) / ((x-sigma)^2 - (gap_0 * d_pos)^2)
				peak +=  -imag(Green) / pi
				break
			
			case 12:
				//gapped SC lineshape with isotropic scattering under Born scattering self-consistent			
				variable/C xi, pre_c, xi_old
				variable i=0, dev, TINY=1.0e-6
	
				gamma0 = w[par0]
				gap_0 = w[par0+1]
				d_pos=w[par0+2]
				
				xi = cmplx(x,TINY)
	
				if(w[par0+3]==0)
					peak+=0
				else
				do
					xi_old=xi
					pre_c = -1 * cmplx(0,1)*2*gamma0/(gap_0*pi)
					sigma = pre_c*cEllipK(gap_0*gap_0/(xi*xi))
					xi = x - gap_0*sigma	
					dev = cabs(xi-xi_old)/cabs(xi)	
				while(dev > 0.01)
	
				Green = w[par0+3]*xi /( xi^2 - (gap_0 * d_pos)^2)
				peak +=  -1*imag(Green) / pi
				endif
				
			break
			
		endswitch		
	endfor											
	
	return offset + (peak + bkg) * fermi
End





// generates w_conv_gauss, w_conv_y with optimal pointnumbers and scaling
// Gaussian scaling is -4 FWHM to + 4 FWHM
// y_wave scaling exceeds x-range by ± 4 FWHM
// x0 needs to be smaller than x1!
Static Function initConvComposedFitFn(fwhm, res, data_dx, x0, x1)
	Variable fwhm, res, data_dx, x0, x1
	
	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse:fit
		
	
		if (fwhm == 0 || numtype(fwhm) != 0)
			fwhm = 0.002
		else
			fwhm =  abs(fwhm)
		endif

		Variable gauss_from = 10 * fwhm
		Variable dx =  min(fwhm/res, abs(data_dx/2))		// needs to be smaller than the data-width!, not really sure...
		Variable y_xfrom = x0 - 4 * fwhm
		Variable y_xto = x1 + 4 * fwhm
		
		Variable gauss_pnts = round(gauss_from/dx) * 2 + 1
		Variable y_pnts = round((y_xto-y_xfrom)/dx)
		
		Make/o/d/n=(gauss_pnts) w_conv_gauss = 0
		Make/o/d/n=(y_pnts) w_conv_y = 0
		
		SetScale/P x y_xfrom, dx, w_conv_y
		SetScale/P x -gauss_from, dx, w_conv_gauss
		
	SetDataFolder $DF
End




// recalculates w_conv_y for the current composed FF with the parameter-wave pw
Static Function calc_conv_waveform(pw)
	WAVE pw
	
	//WAVE w_comp = root:internalUse:fit:w_FFcomposition
	WAVE w_conv_y = root:internalUse:fit:w_conv_y
	WAVE w_conv_gauss = root:internalUse:fit:w_conv_gauss
	
	w_conv_y = composedFitFn(pw,x)	// depends on root:internalUse:fit:w_FFcomposition!!
    	
    	//if (numtype(pw[5])==0 && pw[5] != 0)
		w_conv_gauss = exp(-x^2*4*ln(2)/pw[5]^2)
	//else
	//	w_conv_gauss = 1
	//endif
	
	Variable sumGauss = sum(w_conv_gauss, -inf,inf)
    	w_conv_gauss /= sumGauss
    	
	Convolve/A w_conv_gauss w_conv_y
End




// fit
Static Function convComposedFitFn(pw,yw, xw): FitFunc
	Wave pw, yw, xw
	
	calc_conv_waveform(pw)
	//doupdate
	//print "line"
	WAVE w_conv_y = root:internalUse:fit:w_conv_y
	
	yw = w_conv_y(xw[p])
	//yw = (numtype(yw)==2)?(1):yw
End




// just an example, not in use by i_photo
Static Function example_convfunc(pw, yw, xw) : FitFunc
	Wave pw, yw, xw

	// pw[0] = gaussian baseline offset
	// pw[1] = gaussian amplitude
	// pw[2] = gaussian position
	// pw[3] = gaussian width
	// pw[4] = exponential decay constant of instrument 
	//			response (this parameter is actually
	// 		the inverse of the time constant, in 
	//			order to be just like Igor's built-in exp fit 
	//			function, which was written in the days when a 
	//			floating-point divide took much longer than a
	//			multiply).

	// make a wave to contain an exponential with decay
	// constant pw[4]. The wave needs enough points to allow
	// any reasonable decay constant to get really close to zero.
	// The scaling is made symmetric about zero to avoid an X
	// offset from Convolve/A
	
	// resolutionFactor sets the degree to which the exponential
	// will be over-sampled with regard to the problems parameters.
	// Increasing this number increases the number of time
	// constants included in the calculation. It also decreases
	// the point spacing relative to the problem's time constants.
	// Increasing will also increase the time required to compute

	Variable resolutionFactor = 10										

	// dt contains information on important time constants.
	// We wish to set the point spacing for model calculations 
	// much smaller than exponential time constant or gaussian width.
				
	Variable dT = min(1/(resolutionFactor*pw[4]), pw[3]/resolutionFactor)

	// Calculate suitable number points for the exponential. Length
	// of exponential wave is 10 time constants; doubled so
	// exponential can start in the middle; +1 to make it odd so
	// exponential starts at t=0, and t=0 is exactly the middle 
	// point. That is better for the convolution.

	Variable nExpWavePnts = round(resolutionFactor/(pw[4]*dT))*2 + 1	
				
	Make/D/O/N=(nExpWavePnts) expwave							

	// In this version of the function, we make a y output wave
	// ourselves, so that we can control the resolution and 
	// accuracy of the calculation. It also will allow us to use
	// a wave assignment later to solve the problem of variable
	// X spacing or missing points.

	Variable nYPnts = max(resolutionFactor*numpnts(yw), nExpWavePnts)
	Make/D/O/N=(nYPnts) yWave								
	
	// This wave scaling is set such that the exponential will 
	// start at the middle of the wave										
	setscale/P x -dT*(nExpWavePnts/2),dT,expwave			

	// Set the wave scaling of the intermediate output wave to have
	// the resolution calculated above, and to start at the first
	// X value.
	setscale/P x xw[0],dT, yWave

	// fill expwave with exponential decay
	expwave = (x>=0)*pw[4]*dT*exp(-pw[4]*x)

	// Normalize exponential so that convolution doesn't change
	// the amplitude of the result
	Variable sumexp
	sumexp = sum(expwave, -inf,inf)
	expwave /= sumexp

	// Put a Gaussian peak into the intermediate output wave. We use
	// our own wave (yWave) because the convolution requires a wave
	// with even spacing in X, whereas we may get X values input that
	// are not evenly spaced.
	yWave = pw[0]+pw[1]*exp(-((x-pw[2])/pw[3])^2)

	// and convolve with the exponential; NOTE /A
	convolve/A expwave, yWave
	
	// move appropriate values corresponding to input X data into 
	// the output Y wave. We use a wave assignment involving the
	// input X wave. This will extract the appropriate values from
	// the intermediate wave, interpolating values where the
	// intermediate wave doesn't have a value precisely at an X
	// value that is required by the input X wave. This wave
	// assignment also solves the problem with auto-destination:
	// The function can be called with an X wave that sets any X
	// spacing, so it doesn't matter what X values are required.
	yw = yWave(xw[p])
End
