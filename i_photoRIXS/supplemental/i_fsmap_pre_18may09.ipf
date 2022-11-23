#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 2.00
#pragma ModuleName = fsmap
#pragma IgorVersion = 5.0


Static Constant NORM_NEIGHBOR_MAXLIMIT = 2
Static Constant NORM_NEIGHBOR_MINLIMIT = 0.5
Static Constant NORM_PERC_HISTO_SIZE = 65535

















//////////////////////////////////////
//
// Public functions
//
//////////////////////////////////////




















// opens the fsmap dialog.
Function fsmap_open(ctrlName)
	String ctrlName

	String DF = GetDataFolder(1)
	if (DataFolderExists("root:internalUse:FSMap") == 0)
		init()
	endif
	SetDataFolder root:internalUse:FSMap
	
	DoWindow/K mapper_panel
	Display/K=1 as "mapper panel"
	DoWindow/C mapper_panel
	utils_resizeWindow("mapper_panel",510,400)
	utils_autoPosWindow("mapper_panel", win=127)
//	ModifyGraph cbRGB=(52428,52428,52428)
	ControlBar 190
	
	WAVE w_fsmap
	
	AppendImage w_fsmap
	ModifyGraph axisEnab(bottom)={0,1}
	ModifyGraph mirror=0
	ModifyGraph height={Plan,1,left,bottom}
		
	//------------------------------------------------------------------------------------------
	WAVE/T w_dialog_waves
	WAVE/I w_dialog_selectedwaves
	TabControl map,proc=fsmap#TabControlChange,pos={12,12},size={486,170},tabLabel(0)="source",value=0//,labelBack=(r,g,b)
	Groupbox sou_gb0, size={190,120},pos={290,45},title="select carpets"
	Listbox sou_lb0,listwave=w_dialog_waves,size={240,120},pos={30,45}, selwave=w_dialog_selectedwaves,frame=2,editstyle=0,mode=4
	Button sou_new,pos={300,74},size={150,18},title="New browser selection", proc=fsmap#ButtonWaveSel
	Button sou_add,pos={300,94},size={150,18},title="Add browser selection", proc=fsmap#ButtonWaveSel
	Button sou_del,pos={300,114},size={150,18},title="Remove browser selection", proc=fsmap#ButtonWaveSel
	
	//------------------------------------------------------------------------------------------
	TabControl map,tabLabel(1)="settings"
	NVAR gv_centerE, gv_dE
	Groupbox set_gb0, size={140,52},pos={30,30},title="energies", disable=1
	SetVariable set_sv0, pos={40,46}, size={120,15},title="center (eV)", value = gv_centerE,limits={-Inf,Inf,0}, disable = 1
	SetVariable set_sv1, pos={40,62}, size={120,15},title="window (meV)", value = gv_dE,limits={-Inf,Inf,0}, disable = 1

	NVAR gv_omega_offset
	NVAR gv_theta_offset
	NVAR gv_phi_offset
	Groupbox set_gb1, size={140,72},pos={30,90},title="angles", disable=1
	SetVariable set_sv10, pos={40,110}, size={80,15},title="th off", value = gv_theta_offset,limits={-Inf,Inf,0}, disable = 1// TODO
	SetVariable set_sv11, pos={40,126}, size={80,15},title="ph off", value = gv_phi_offset,limits={-Inf,Inf,0}, disable = 1// TODO
	SetVariable set_sv12, pos={40,142}, size={80,15},title="om off", value = gv_omega_offset,limits={-Inf,Inf,0}, disable = 1// TODO

	NVAR gv_kx_min, gv_kx_max, gv_ky_min, gv_ky_max
	NVAR gv_kx_stepsize, gv_ky_stepsize
	NVAR gv_auto_grid
	Groupbox set_gb2, size={110,132},pos={180,30},title="k space", disable=1
	Button set_b20, pos = {190,46},size={50,15},title="get limits", proc=fsmap#buttonGetKSpaceLimits, disable=1
	CheckBox set_cb20, pos = {240,46},size={40,15},title="auto", variable=gv_auto_grid, disable=1
	SetVariable set_sv20, pos={190,62}, size={90,15},title="kx_min", value = gv_kx_min,limits={-Inf,Inf,0}, disable = 1// TODO
	SetVariable set_sv21, pos={190,78}, size={90,15},title="kx_max", value = gv_kx_max,limits={-Inf,Inf,0}, disable = 1// TODO
	SetVariable set_sv22, pos={190,94}, size={90,15},title="delta_kx", value = gv_kx_stepsize,limits={-Inf,Inf,0}, disable = 1// TODO
	SetVariable set_sv23, pos={190,110}, size={90,15},title="ky_min", value = gv_ky_min,limits={-Inf,Inf,0}, disable = 1// TODO
	SetVariable set_sv24, pos={190,126}, size={90,15},title="ky_max", value = gv_ky_max,limits={-Inf,Inf,0}, disable = 1// TODO
	SetVariable set_sv25, pos={190,142}, size={90,15},title="delta_ky", value = gv_ky_stepsize,limits={-Inf,Inf,0}, disable = 1// TODO
	
	SVAR gs_method
	Groupbox set_gb3, size={110,72},pos={300,30},title="Method", disable=1
	CheckBox set_cb3P, pos = {310,46},size={80,15},title="Precise", mode=1,value=(stringmatch(gs_method,"Precise")==1),proc=fsmap#CheckBoxMethod,disable=1
	CheckBox set_cb3V, pos = {310,62},size={80,15},title="Voronoi", mode=1,value=(stringmatch(gs_method,"Voronoi")==1),proc=fsmap#CheckBoxMethod,disable=1
	CheckBox set_cb3B, pos = {310,78},size={80,15},title="Baumberger", mode=1,value=(stringmatch(gs_method,"Baumberger")==1),proc=fsmap#CheckBoxMethod,disable=1
	
	Button set_exp pos={300,104}, size={110,18}, title="Filetable", proc=fsmap#ButtonFiletable, disable = 1
	Button set_go, pos={300,124}, size={110,18}, title="kxky-map", proc=fsmap#ButtonMap, disable = 1
	Button set_copy, pos={300,144}, size={40,18}, title="copy:", proc=fsmap#ButtonSaveCopy, disable = 1
	SetVariable set_svcopy0, pos={340,144}, size={70,18},title=" ", value = gs_save_wname, disable = 1// TODO

	//------------------------------------------------------------------------------------------
	TabControl map,tabLabel(2)="MethodSpec"
	NVAR gv_stripeTolPreciseVoronoi
	Groupbox met_gb0, size={110,128},pos={30,30},title="Voronoi", disable=1
	SetVariable met_sv00, pos={40,60}, size={95,15},title="stripe dist tol", value = gv_stripeTolPreciseVoronoi,limits={-Inf,Inf,0}, disable = 1

	NVAR gv_backmapTolPrecise
	NVAR gv_stripeTolPreciseVoronoi
	NVAR gv_numInterpAngPrecise
	NVAR gv_autoInterpAngPrecise
	NVAR gv_preAvgInterpPrecise
	Groupbox met_gb1, size={110,128},pos={150,30},title="Precise", disable=1
	SetVariable met_sv10, pos={160,46}, size={95,15},title="# backmap", value = gv_backmapTolPrecise,limits={-Inf,Inf,0}, disable = 1
	SetVariable met_sv11, pos={160,62}, size={95,15},title="stripe dist tol", value = gv_stripeTolPreciseVoronoi,limits={-Inf,Inf,0}, disable = 1
	SetVariable met_sv12, pos={160,78}, size={95,15},title="# interp ang", value = gv_numInterpAngPrecise,limits={-Inf,Inf,0}, disable = 1
	CheckBox met_cb10, pos={160,94}, size={155,15},title="auto # int. ang", variable = gv_autoInterpAngPrecise, disable = 1
	SetVariable met_sv13, pos={160,110}, size={95,15},title="interp preAvg", value = gv_preAvgInterpPrecise,limits={-Inf,Inf,0}, disable = 1


	NVAR gv_old_styleBaumberger
	NVAR gv_auto_zBaumberger
	NVAR gv_lin_combBaumberger
	Groupbox met_gb2, size={170,128},pos={270,30},title="Baumberger", disable=1
	CheckBox met_cb20, pos={280,46}, size={155,15},title="old style merging", variable = gv_old_styleBaumberger, disable = 1
	CheckBox met_cb21, pos={280,62}, size={155,15},title="auto z (new style only)", variable = gv_auto_zBaumberger, disable = 1
	CheckBox met_cb22, pos={280,78}, size={155,15},title="lin.comb.(new style only)", variable = gv_lin_combBaumberger, disable = 1
	CheckBox met_cb23, pos={280,94}, size={155,15},title="force CFE generation", variable = gv_forceGenCfeBaumberger, disable = 1

	//------------------------------------------------------------------------------------------
	TabControl map,tabLabel(3)="Misc"
	NVAR gv_intensity_cutting
	NVAR gv_intensity_lowPercent
	NVAR gv_intensity_highPercent
	NVAR gv_intensity_low
	NVAR gv_intensity_high
	Groupbox mis_gb0, size={160,128},pos={30,30},title="Intensity outlayers", disable=1
	CheckBox mis_cb00, pos={40,46}, size={145,15},title="use intensity cutting", variable = gv_intensity_cutting, disable = 1
	Button mis_b00, pos={40,62}, size={100,15},title="get min/max int.",proc=fsmap#buttonDoIntensityLimits, disable = 1
	CheckBox mis_cb01, pos={140,62}, size={145,15},title="auto", variable = gv_fsmap_autoInt, disable = 1
	SetVariable mis_sv00, pos={40,78}, size={145,15},title="low percentile cutoff", value = gv_intensity_lowPercent,limits={-Inf,Inf,0}, disable = 1
	SetVariable mis_sv01, pos={40,94}, size={145,15},title="high percentile cutoff", value = gv_intensity_highPercent,limits={-Inf,Inf,0}, disable = 1
	SetVariable mis_sv02, pos={40,110}, size={145,15},title="low int cutoff", value = gv_intensity_low,limits={-Inf,Inf,0}, disable = 1
	SetVariable mis_sv03, pos={40,126}, size={145,15},title="high int cutoff", value = gv_intensity_high,limits={-Inf,Inf,0}, disable = 1
	SetVariable mis_sv04, pos={40,142}, size={70,15},title="min", value = gv_fsmap_minInt,format="%2.2e",limits={-inf,inf,0},noedit=1, disable = 1
	SetVariable mis_sv05, pos={115,142}, size={70,15},title="max", value = gv_fsmap_maxInt,format="%2.2e",limits={-inf,inf,0},noedit=1, disable = 1
	
	NVAR gv_movie_startE
	NVAR gv_movie_endE
	NVAR gv_movie_deltaE
	NVAR gv_movie_xres
	NVAR gv_movie_yres
	SVAR gs_movie_hook
	Groupbox mis_gb1, size={170,128},pos={200,30},title="Movie", disable=1
	SetVariable mis_sv10, pos={210,46}, size={70,15},title="from E", value = gv_movie_startE,limits={-Inf,Inf,0}, disable = 1
	SetVariable mis_sv11, pos={285,46}, size={70,15},title="to E", value = gv_movie_endE,limits={-Inf,Inf,0}, disable = 1
	SetVariable mis_sv12, pos={210,62}, size={70,15},title="delta E", value = gv_movie_deltaE,limits={-Inf,Inf,0}, disable = 1
	SetVariable mis_sv15, pos={210,78}, size={70,15},title="x-res", value = gv_movie_xres, limits={-Inf,Inf,0}, disable = 1
	SetVariable mis_sv16, pos={285,78}, size={70,15},title="y-res", value = gv_movie_yres, limits={-Inf,Inf,0}, disable = 1
	SetVariable mis_sv17, pos={210,94}, size={145,15},title="hook", value = gs_movie_hook, disable = 1
	Button mis_bcreateMovie, pos={210, 110}, size={145,15},title="create movie",proc=fsmap#buttonCreateMovie,disable=1
	Button mis_btestMovie, pos={210, 126}, size={145,15},title="test movie",proc=fsmap#buttonCreateMovie,disable=1
	
	NVAR gv_symmetrize_NumAxes
	NVAR gv_symmetrize_AxesAngle
	NVAR gv_symmetrize_range
	NVAR gv_symmetrize_steps
	NVAR gv_symmetrize_cutSector
	Groupbox mis_gb2, size={110,128},pos={380,30},title="Symmetrize", disable=1
	SetVariable mis_sv20, pos={390,46}, size={90,15},title="# axes", value = gv_symmetrize_NumAxes, limits={0,Inf,1}, disable = 1
	SetVariable mis_sv21, pos={390,62}, size={90,15},title="Angle", value = gv_symmetrize_AxesAngle, limits={0,360,1}, disable = 1
	Button mis_bSym, pos={390, 78}, size={45,15},title="apply",proc=fsmap#buttonSymmetrize,disable=1
	Button mis_bSymReset, pos={435, 78}, size={45,15},title="reset",proc=fsmap#buttonSymmetrize,disable=1
	Checkbox mis_cb20, pos={390,94}, size={90,15},title="only 1st sector", variable = gv_symmetrize_cutSector, disable = 1
	TitleBox mis_tb20, pos={390,110}, size={40,15},title="Find", disable=1
	Button mis_bSymFindPhi, pos={435, 110}, size={15,15},title="p",proc=fsmap#buttonSymmetrize,disable=1
	Button mis_bSymFindTheta, pos={450, 110}, size={15,15},title="t",proc=fsmap#buttonSymmetrize,disable=1
	Button mis_bSymFindOmega, pos={465, 110}, size={15,15},title="o",proc=fsmap#buttonSymmetrize,disable=1
	SetVariable mis_sv22, pos={390,126}, size={45,15},title="#", value = gv_symmetrize_steps, limits={0,inf,0}, disable = 1
	SetVariable mis_sv23, pos={435,126}, size={45,15},title="rng", value = gv_symmetrize_range, limits={0,inf,0}, disable = 1

	TabControl map,tabLabel(4)="Norm"
	SVAR gs_norm_method
	NVAR gv_norm_manual
	Groupbox nor_gb0, size={90,128},pos={30,30},title="Method", disable=1
	CheckBox nor_cb0N, pos = {40,46},size={60,15},title="None", mode=1,value=(stringmatch(gs_norm_method,"None")==1),proc=fsmap#CheckBoxNormMethod,disable=1
	CheckBox nor_cb0T, pos = {40,62},size={60,15},title="Total", mode=1,value=(stringmatch(gs_norm_method,"Total")==1),proc=fsmap#CheckBoxNormMethod,disable=1
	CheckBox nor_cb0P, pos = {40,78},size={60,15},title="Percentile", mode=1,value=(stringmatch(gs_norm_method,"Percentile")==1),proc=fsmap#CheckBoxNormMethod,disable=1
	CheckBox nor_cb0R, pos = {40,94},size={60,15},title="Neighbor", mode=1,value=(stringmatch(gs_norm_method,"Neighbor")==1),proc=fsmap#CheckBoxNormMethod,disable=1
	CheckBox nor_cb01, pos = {40,110},size={60,15},title="Manual",variable=gv_norm_manual,disable=1

// TODO:	NVAR gv_norm_totalInt
	NVAR gv_norm_percentile
	NVAR gv_norm_percEWindow
	NVAR gv_norm_smPercentile
	Groupbox nor_gb1, size={130,88},pos={130,30},title="Percentile", disable=1
	CheckBox nor_cb10, pos={140,46}, size={110,15},title="Use E-window", variable = gv_norm_percEWindow, disable = 1
	SetVariable nor_sv11, pos={140,62}, size={110,15},limits={0,100,1},title="Percentile", value = gv_norm_percentile, disable = 1
	Checkbox nor_cb11, pos={140,78}, size={110,15},title="Collapse E", variable = gv_norm_percIntE, disable = 1
	SetVariable nor_sv12, pos={140,94}, size={110,15},limits={0,inf,1},title="Smoothing", value = gv_norm_smPercentile, disable = 1

	NVAR gv_norm_neighIters
	Groupbox nor_gb2, size={130,38},pos={130,118},title="Neighbor", disable=1
	SetVariable nor_sv20, pos={140,132}, size={110,15},limits={0,inf,0.1},title="Smoothing", value = gv_norm_neighSmooth, disable = 1

	NVAR gv_normStripes
	Groupbox nor_gb3, size={130,38},pos={270,30},title="Stripes", disable=1
	CheckBox nor_cb30, pos={280,46}, size={110,15},title="Least Square", variable = gv_normStripes, disable = 1

	SetDataFolder $DF


End



// TODO: maybe put this into another file?
// theta(t): polar angle
// alpha(a): another polar angle; the rotation of the analyzer around the sample. 
//      This is used only for ALS and is equivalent to theta, really.
// phi(p): flip stage
// omega(o): azimuthal orientation
// beta(b): Scienta-angle
// gamma(g): orientation of parallel detection
// writes output to angles2k_Result
// the result is in units of k_vacuum, so you need to multiply the result by k_vacuum.
Function fsmap_flip_ang2k(t,a,p,o,b,g)
	Variable t,a,p,o,b,g
	
	Variable d2r = pi/180
	t *= d2r
	a *= d2r
	p *= d2r
	o *= d2r
	b *= d2r
	g *= d2r
	Make/o/n=(3,3) Rom,Rphi,Rtheta,Ralpha,Rgamma,Rbeta
	Make/o/n=3 emission

	// Lab emission is in the z direction.
	emission = {0, 0, 1}

	// First rotation is in beta, the angle parallel to the slit direction of the analyzer. (e.g. +-7 degrees for the old analyzers)
	// Second rotation is around gamma, the azimuthal angle of the analyzer slit wrt the manip. (gamma = 0 means slit parallel to manip)\
	// third rotation is around theta and alpha, the rotation of the manip along its long axis and/or the Analyzer around sample.
	// fourth rotation is around phi, the rotation angle of the flip stage.
	// fifth rotation is around omega, the sample azimuthal angle (rotation of sample within the flip stage).
	Rbeta		= { {	1,		0,		0		}, {	0,		cos(b),	-sin(b)	}, {	0,		sin(b),	cos(b)	} }
	Rgamma	= { {	cos(g),	sin(g),	0		}, {	-sin(g),	cos(g),	0		}, {	0,		0,		1		} }
	Rtheta		= { {	cos(t)	,0,		-sin(t)	}, {	0,		1,		0		}, {	sin(t),	0,		cos(t)	} }
	Ralpha		= { {	cos(a)	,0,		-sin(a)	}, {	0,		1,		0		}, {	sin(a),	0,		cos(a)	} }
	Rphi		= { {	1,		0,		0		}, {	0,		cos(p),	-sin(p)	}, {	0,		sin(p),	cos(p)	} }
	Rom		= { {	cos(o),	-sin(o),	0		}, {	sin(o),	cos(o),	0		}, {	0,		0,		1		} }
	MatrixMultiply Rom, Rphi, Rtheta, Ralpha, Rgamma, Rbeta, emission
	WAVE M_product
		
	Make/O/N=2 angles2k_Result
	angles2k_Result[0] = M_product[0][0]
	angles2k_Result[1] = M_product[1][0]
	
	KillWaves M_product, Rom, Rphi, Rtheta, Ralpha, Rgamma, Rbeta, emission
End




// TODO: maybe put this into another file?
// theta(t): polar angle
// omega(o): azimuthal orientation
// sigma(s): tilt of the sample surface normal against the radial top post axis
// mu(m): rotation of the sample BZ against the tilt sigma
// writes output to angles2k_Result
// the result is in units of k_vacuum, so you need to multiply the result by k_vacuum.
Function fsmap_berlin_ang2k(t,o,s,m)
	Variable t,o,s,m
		
	Variable d2r = pi/180
	t *= d2r
	o *= d2r
	s *= d2r
	m *= d2r
	Make/o/n=(3,3) Rtheta, Rom, Rsigma,Rmu
	Make/o/n=3 emission

	// Lab emission is in the z direction.
	emission = {0, 0, 1}

	// First rotation is in beta, the angle parallel to the slit direction of the analyzer. (e.g. +-7 degrees for the old analyzers)
	// Second rotation is around gamma, the azimuthal angle of the analyzer slit wrt the manip. (gamma = 0 means slit parallel to manip)
	// third rotation is around theta, the rotation of the manip along its long axis.
	// fourth rotation is around phi, the rotation angle of the flip stage.
	// fifth rotation is around omega, the sample azimuthal angle (rotation of sample within the flip stage).
	Rtheta		= { {	cos(t),	0,		-sin(t)	}, {	0,		1,		0		}, {	sin(t),	0,		cos(t)	} }
	Rom		= { {	cos(o),	sin(o),	0		}, {	-sin(o),	cos(o),	0		}, {	0,		0,		1		} }
	Rsigma		= { {	cos(s),	0,		-sin(s)	}, {	0,		1,		0		}, {	sin(s),	0,		cos(s)	} }
	Rmu		= { {	cos(m),	sin(m),	0		}, {	-sin(m),	cos(m),	0		}, {	0,		0,		1		} }
	MatrixMultiply Rmu, Rsigma, Rom, Rtheta, emission
	WAVE M_product
		
	Make/O/N=2 angles2k_Result
	angles2k_Result[0] = M_product[0][0]
	angles2k_Result[1] = M_product[1][0]
	
	KillWaves M_product, Rtheta, Rom, Rsigma, Rmu, emission
End



// 'version 2': works for arbitrary shapes of free areas				FB 11/11/03
//Function fsmap_merge2Baumberger(w1,w2,w12)
// This is a public function only because i_merger also uses it.
// Thematically, it fits into the section about the Baumberger method
// below, under Private Functions. That is why it is stored down there.



// 'version 3': uses only the maximum square area with real data
//Function fsmap_merge3Baumberger(w1,w2,w12, auto_z, auto_straight)
// This is a public function only because i_merger also uses it.
// Thematically, it fits into the section about the Baumberger method
// below, under Private Functions. That is why it is stored down there.

























//////////////////////////////////////
//
// Private functions: Control Callbacks
//
//////////////////////////////////////





















Static Function buttonCreateMovie(ctrlname) : ButtonControl
	String ctrlname
	
	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:FSMap

	NVAR gv_centerE //
	NVAR gv_auto_grid //
	NVAR gv_movie_startE //
	NVAR gv_movie_endE //
	NVAR gv_movie_deltaE //
	NVAR gv_movie_xres
	NVAR gv_movie_yres
	SVAR gs_movie_hook
	NVAR gv_fsmap_minInt
	NVAR gv_fsmap_maxInt

	Variable centerE_backup = gv_centerE
	Variable auto_grid_backup = gv_auto_grid
	
//	Execute/Z/Q "CloseMovie"
	
	Variable e
	Variable firstCall = 1
		
	strswitch(ctrlname)
		case "mis_bcreateMovie":
			String msg = "Do NOT use the Igor 'abort' button (use [Esc] instead!) since due to an Igor bug,\r"
			msg += "this might prevent you from doing/creating any more movies until you restart Igor. Continue?"
			DoAlert 1, msg
			if (V_flag == 2)
				utils_progressDlg(done=1)
				SetDataFolder $DF
				return 0
			endif
			break
		case "mis_btestMovie":
			DoAlert 0, "This is a test run; the frames are created and I will pause after each frame so you can look at it."
			break
		default:
			Abort "buttonCreateMovie: unknown ctrlname: "+ctrlname
			break
	endswitch
	
	DoWindow/K movieframe
	Display/N=movieframe/W=(0,0,gv_movie_xres,gv_movie_yres)
	DoWindow/F mapper_panel
	
	for (e = gv_movie_startE; e <= gv_movie_endE; e += gv_movie_deltaE)

		gv_centerE = e

		buttonMap("", quiet = 1)

		gv_auto_grid = 0

		DoWindow/F movieframe
		
		if(strlen(gs_movie_hook) != 0) // User did supply a hook. No work for me.
			String parms
			sprintf parms, "START_E:%e;END_E:%e;CURRENT_E:%e;DELTA_E:%e",gv_movie_startE,gv_movie_endE,e,gv_movie_deltaE
			sprintf parms, "%s;MIN_INT:%e;MAX_INT:%e;FIRST_CALL:%d",parms, gv_fsmap_minInt, gv_fsmap_maxInt,firstCall
			SetDataFolder $DF
			Execute/Q gs_movie_hook+"(\""+parms+"\")"
			SetDataFolder root:internalUse:FSMap
			if (firstCall == 1)
				DoUpdate
				if (! stringmatch(ctrlname, "mis_btestMovie"))
					NewMovie/L/I
				endif
			endif
		else // No hook was supplied. Have to paint myself.
			if (firstCall == 1)
				// TODO: the color table could be user-modifyable. But then again, the
				// user could just write a quick hook.
				AppendImage/W=movieframe w_fsmap
				ModifyGraph/W=movieframe height={Plan,1,left,bottom}
				ModifyImage w_fsmap ctab= {gv_fsmap_minInt,gv_fsmap_maxInt,Grays,0}
				DoUpdate
				if (! stringmatch(ctrlname, "mis_btestMovie"))
					NewMovie/L/I
				endif
			endif
			String title
			sprintf title, "E = %3.3feV", e
			TextBox/C/N=text0/A=MT/X=.45/Y=.05 title
		endif
		firstCall = 0

		DoUpdate
		if (utils_progressDlg(message="adding movie frame", numDone=e-gv_movie_startE, numTotal=gv_movie_endE-gv_movie_startE))
			break
		endif
		
		if (! stringmatch(ctrlname, "mis_btestMovie"))
			AddMovieFrame
			Sleep/S 1
		else
			DoAlert 1, "Shall I continue and do the next frame?"
			if (V_flag == 2)
				utils_progressDlg(done=1)
				gv_centerE = centerE_backup
				gv_auto_grid = auto_grid_backup
				SetDataFolder $DF
				return 0
			endif
		endif
		
		DoWindow/F mapper_panel
	endfor

	if (! stringmatch(ctrlname, "mis_btestMovie"))
		CloseMovie
		DoWindow/K movieframe
	endif

	utils_progressDlg(done=1)

	gv_centerE = centerE_backup
	gv_auto_grid = auto_grid_backup

	SetDataFolder $DF
End




// called from button "kxky-map" in the main panel.
Static Function buttonSaveCopy(ctrlName) : ButtonControl
	String ctrlName

	String DF = GetDataFolder(1)
	NewDataFolder/O/S root:fsmaps
	SVAR gs_save_wname = root:internalUse:FSMap:gs_save_wname
	WAVE w = $gs_save_wname
	if(WaveExists(w))
		DoAlert 1, "Wave already exists. Overwrite?"
		if (V_flag == 2) // user cancelled.
			DoAlert 0, "FS map has NOT been saved."
			SetDataFolder $DF
			return 0
		endif
	endif
	Execute/Q/Z "Duplicate/O root:internalUse:FSMap:w_fsmap, '"+gs_save_wname+"'"
	if (V_flag != 0)
		DoAlert 0, "Error duplicating root:internalUse:FSMap:w_fsmap. Consider doing it manually."
	else
		DoAlert 0, "A copy of the FS map has been saved under \""+gs_save_wname+"\"."
	endif

	SetDataFolder $DF
End




Static Function buttonDoIntensityLimits(ctrlname)
	String ctrlname
	WAVE/T w_dialog_waves = root:internalUse:FSMap:w_dialog_waves
	determineIntensityLimits(w_dialog_waves)
End



// called from button "kxky-map" in the main panel.
Static Function buttonMap(ctrlName,[quiet]) : ButtonControl
	String ctrlName
	Variable quiet
	if (ParamIsDefault(quiet))
		quiet = 0
	endif
	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:FSMap
	
	WAVE/T w_dialog_waves
	NVAR gv_centerE
	NVAR gv_dE
	NVAR gv_auto_grid
	SVAR gs_method
	NVAR gv_stripeTolPreciseVoronoi
	NVAR gv_intensity_cutting
	NVAR gv_fsmap_minInt
	NVAR gv_fsmap_maxInt
	NVAR gv_fsmap_autoInt

	Variable numdatapoints = 0
	Variable minE = gv_centerE - gv_dE / 2000
	Variable maxE = gv_centerE + gv_dE / 2000
	
	WAVE w_fsmap
	w_fsmap = NaN
	KillWaves/Z w_fsmap_backup
	
	String nonFatalErrors = ""

	String dlg_waves = utils_wave2StringList(w_dialog_waves)
	
	// determine the intensity limits BEFORE mapping/backmapping, since mapping
	// can create outlayers etc. These intensities are the ones needed for the FS map.
	determineIntensityLimits(w_dialog_waves)

	if (gv_auto_grid == 1)
		getKSpaceLimits(dlg_waves)
	endif

	strswitch(gs_method)

		case "Baumberger":
			utils_progressDlg(message="map: Doing Baumberger map")
			nonFatalErrors += mapBaumberger()
			break;

		case "Precise":
		case "Voronoi":
			// Voronoi or Precise method:
			if (utils_progressDlg(message="map: total cuts: "+num2str(ItemsInList(dlg_waves)), numDone=0,numTotal=ItemsInList(dlg_waves)))
				break
			endif
			String stripe_of_waves = getWaveStripe(dlg_waves, gv_stripeTolPreciseVoronoi)
			dlg_waves = RemoveFromList(stripe_of_waves, dlg_waves)
			if (stringmatch(gs_method,"Voronoi"))
				nonFatalErrors += mapStripeVoronoi(stripe_of_waves)
			elseif (stringmatch(gs_method,"Precise"))
				nonFatalErrors += mapStripePrecise(stripe_of_waves)
			endif
			WAVE w_stripemap, w_stripemap_mask
			generateStripeMask(stripe_of_waves)
			w_stripemap = (w_stripemap_mask == 1) ? w_stripemap : NaN
//			subtractMask(stripe_of_waves)
			if (utils_progressDlg(message="map: Remaining cuts: "+num2str(ItemsInList(dlg_waves)), numDone=ItemsInList(stripe_of_waves), numNotDone=ItemsInList(dlg_waves)))
				break
			endif
			WAVE w_stripemap
			Duplicate/O w_stripemap, w_fsmap
			DoUpdate

			for (; strlen(dlg_waves) != 0 ;)
				stripe_of_waves = getWaveStripe(dlg_waves, gv_stripeTolPreciseVoronoi)
				dlg_waves = RemoveFromList(stripe_of_waves, dlg_waves)
				if (stringmatch(gs_method,"Voronoi"))
					nonFatalErrors += mapStripeVoronoi(stripe_of_waves)
				elseif (stringmatch(gs_method,"Precise"))
					nonFatalErrors += mapStripePrecise(stripe_of_waves)
				endif
				WAVE w_stripemap, w_stripemap_mask
				generateStripeMask(stripe_of_waves)
				w_stripemap = (w_stripemap_mask == 1) ? w_stripemap : NaN
//				subtractMask(stripe_of_waves)
				if (utils_progressDlg(message="map: Remaining cuts: "+num2str(ItemsInList(dlg_waves)), numDone=ItemsInList(stripe_of_waves), numNotDone=ItemsInList(dlg_waves)))
					break
				endif
				mergeStripeNorm()
				merge()

				DoUpdate
			endfor
			KillWaves w_stripemap, w_stripemap_dkx, w_stripemap_dky
			break;

		default:
			utils_Abort(gs_method + " is not a valid method.")

	endswitch

	if (gv_intensity_cutting == 1)
		utils_progressDlg(message="map: Doing intensity cutoff:")
		NVAR gv_intensity_low, gv_intensity_high
		NVAR gv_intensity_lowPercent, gv_intensity_highPercent
		if (gv_fsmap_autoInt) // a cutoff margin is added which is 10% of the intensity range.
			gv_intensity_low = gv_fsmap_minInt - (gv_fsmap_maxInt-gv_fsmap_minInt) / 10
			gv_intensity_high = gv_fsmap_maxInt + (gv_fsmap_maxInt-gv_fsmap_minInt) / 10
			gv_intensity_lowPercent = 0
			gv_intensity_highPercent = 0
		endif
		w_fsmap = (w_fsmap < (gv_intensity_low) || w_fsmap > (gv_intensity_high)) ? (NaN) : w_fsmap
		
		Make/O/N=(65536) w_fsmap_histo
		SetScale/I x, gv_intensity_low, gv_intensity_high, w_fsmap_histo
		Histogram/B={gv_intensity_low, (gv_intensity_high-gv_intensity_low)/65535, 65536} w_fsmap, w_fsmap_histo
		Integrate w_fsmap_histo /D=w_fsmap_intHisto
		// note that numTotalInts is different from just Dimsize(0,w_fsmap)*DimSize(1,w_fsmap) since
		// it does not include NaN's:
		Variable numTotalInts = w_fsmap_intHisto[65535]
		Variable lowPercentileInt = -inf
		Variable i
		for (i = 0; i < 65535; i += 1)
			if (w_fsmap_intHisto[i] / numTotalInts > gv_intensity_lowPercent / 100)
				lowPercentileInt = pnt2x(w_fsmap_histo, i-1)
				break
			endif
		endfor
		Variable highPercentileInt = +inf
		for (i = 0; i < 65535; i += 1)
			if (w_fsmap_intHisto[i] / numTotalInts > 1 - gv_intensity_highPercent / 100)
				highPercentileInt = pnt2x(w_fsmap_histo, i)
				break
			endif
		endfor
		w_fsmap = (w_fsmap < (lowPercentileInt) || w_fsmap > (highPercentileInt)) ? (NaN) : w_fsmap
	endif

//	utils_progressDlg(message="map: Done.", numDone=1, numNotDone=0, whenDone="timed", done=1)
	utils_progressDlg(done=1)
	
	String notestr = genFSMapNote()
	notestr = ReplaceStringByKey("Errors", notestr, nonFatalErrors, "=", "\r")
	Note/K w_fsmap, notestr

	if (strlen(nonFatalErrors) != 0 && ! quiet)
		DoAlert 0, "There were the following errors during FS map:\r"+ReplaceString(";", nonFatalErrors, "\r")
	endif
	
	SetDataFolder $DF
End




// called from the buttons in main panel that select the waves to be mapped.
// depending on the button where this was called from, it deletes, adds, or
// replaces the current selection with a browser selection.
Static Function buttonWaveSel(ctrlName) : ButtonControl
	String ctrlName
	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse:FSMap
	WAVE/T w_dialog_waves
	WAVE/I w_dialog_selectedwaves
	Variable i, j, k
	Variable size = numpnts(w_dialog_waves)
	String browserCmd = "CreateBrowser prompt=\"select source data to add, and click 'ok'\", showWaves=1, showVars=0, showStrs=0"

	strswitch(ctrlName)
		case "sou_del":
			j = 0
			for (i = 0; i < size; i += 1)
				if (! w_dialog_selectedwaves[i] & 1) // item is NOT selected, need to count it
					j += 1
				endif
			endfor
			Duplicate/O/T w_dialog_waves, w_tmp
			Redimension/N=(j) w_dialog_waves // allocate space for the remaining (unselected) entries
			j = 0
			for (i = 0; i < numpnts(w_dialog_selectedwaves); i += 1)
				if (! w_dialog_selectedwaves[i] & 1) // item is NOT selected, needs to be copied
					w_dialog_waves[j] = w_tmp[i]
					j += 1
				endif
			endfor
			Redimension/N=(j) w_dialog_selectedwaves
			KillWaves w_tmp
			break
		case "sou_new":
			size = 0
		case "sou_add":
			SetDataFolder $DF
			execute browserCmd
			SVAR S_BrowserList=S_BrowserList
			NVAR V_Flag=V_Flag
			if(V_Flag==0)
				return 0
			endif
			SetDataFolder root:internalUse:FSMap
			Duplicate/O/T w_dialog_waves, w_tmp
			Redimension/N=(size + ItemsInList(S_BrowserList)) w_dialog_waves
			Redimension/N=(size + ItemsInList(S_BrowserList)) w_dialog_selectedwaves
			k = size
			for (i = 0; i < ItemsInList(S_BrowserList); i += 1)
				String dlgwaves = utils_wave2StringList(w_dialog_waves)
				// check to avoid duplicate items in the wave selection:
				if (WhichListItem(StringFromList(i,S_BrowserList), dlgwaves) != -1)
					continue
				endif
				// We only want 2D waves here:
				if (WaveDims($StringFromList(i,S_BrowserList)) != 2)
					printf "fsmap#buttonSelWaves: %s is not a 2D wave. Ignoring.\r", StringFromList(i,S_BrowserList)
					continue
				endif
				w_dialog_waves[k] = StringFromList(i,S_BrowserList)
				k += 1
			endfor
			Redimension/N=(k) w_dialog_waves
			Redimension/N=(k) w_dialog_selectedwaves
			KillWaves w_tmp
			break
		default:
			utils_Abort("ButtonWaveSel(): ctrlName \""+ctrlName+"\" not recognized.")
	endswitch
	SetDataFolder $DF
End



// Call-back that is executed when the "Filetable" button in the main panel is
// pressed.
Static Function buttonFiletable(ctrlName) : ButtonControl
	String ctrlName
	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse:FSMap
	WAVE/T w_dialog_waves
	String waves = utils_wave2StringList(w_dialog_waves)
	SetDataFolder $DF
	filetable_open(waves)
End




Static Function buttonSymmetrize(ctrlName) : ButtonControl
	String ctrlName

	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse:FSMap

	WAVE w_fsmap
	if (stringmatch(ctrlName, "mis_bSymReset"))
		if (WaveExists(w_fsmap_backup))
			Duplicate/O w_fsmap_backup, w_fsmap
			KillWaves w_fsmap_backup
		endif
		SetDataFolder $DF
		return 0
	endif

	NVAR gv_symmetrize_NumAxes
	NVAR gv_symmetrize_AxesAngle

	if (gv_symmetrize_NumAxes < 1)
		SetDataFolder $DF
		utils_abort("Need at least one symmetry axis.")
	endif

	// Need to find the maximum extent of the FS map.
	Variable max_k = max(abs(utils_x1(w_fsmap)), abs(utils_x0(w_fsmap)))
	max_k = max( max_k, max(abs(utils_y1(w_fsmap)), abs(utils_y0(w_fsmap))) )
	// the target region should fit a circle with radius max_k:
	Variable delta_k = min(DimDelta(w_fsmap,0), DimDelta(w_fsmap,1))
	Make/O/N=(2*max_k*sqrt(2)/delta_k+1, 2*max_k*sqrt(2)/delta_k+1, 2*gv_symmetrize_NumAxes) w_symmetry_layers
	Make/O/N=(2*max_k*sqrt(2)/delta_k+1, 2*max_k*sqrt(2)/delta_k+1) w_interp
	SetScale/I x, -max_k*sqrt(2), max_k*sqrt(2), w_symmetry_layers, w_interp
	SetScale/I y, -max_k*sqrt(2), max_k*sqrt(2), w_symmetry_layers, w_interp
	Make/O/N=(2, 2*gv_symmetrize_NumAxes) w_symmetry_directions
	w_symmetry_directions[][] = 0 // p: angle, direction of rotation, q: symmetry operation number

	// If there are n axes, there are 2*n different regions (e.g. quadrants,sextants,octants,...)
	// We need only to include the symmetry operations that are different, i.e. that 
	// transform the image once into each region, i.e. the 2*n different operations:

	duplicate/o w_interp, w_dbg

	// Symmetry group: 0: no mirror
	w_symmetry_layers[][][0] = interp2D(w_fsmap,x,y) //M_InterpolatedImage[p][q]
	w_symmetry_directions[][0] = {0,1} // kx points in the direction of kx, sense of rotation
										 // is clockwise
	w_dbg = w_symmetry_layers[p][q][0]
	
	// Symmetry group: 1-n: one mirror
	w_interp = interp2D(w_fsmap,x,y)

	Variable i
	for (i = 1; i <= gv_symmetrize_NumAxes; i += 1)
		Variable angle = 180 / gv_symmetrize_NumAxes * (i-1) + gv_symmetrize_AxesAngle
		symmetrizeMirrorFSMap(angle)
		WAVE M_RotatedImage
		w_symmetry_layers[][][i] = M_RotatedImage(x)(y)
		w_symmetry_directions[][i] = {utils_mod(2*angle,360), -1} // sense of rotation is now ccw
		w_dbg = w_symmetry_layers[p][q][i]
	endfor
	
	// Symmetry group: 1,2-n: two mirrors
	w_interp[][] = w_symmetry_layers[p][q][1]
	for (i = 2; i <= gv_symmetrize_NumAxes; i += 1)
		angle = 180 / gv_symmetrize_NumAxes * (i-1) + gv_symmetrize_AxesAngle
		symmetrizeMirrorFSMap(angle)
		WAVE M_RotatedImage
		w_symmetry_layers[][][i+gv_symmetrize_NumAxes-1] = M_RotatedImage(x)(y)
		w_symmetry_directions[][i+gv_symmetrize_NumAxes-1] = {utils_mod(-w_symmetry_directions[0][1]+2*angle,360), +1} // sense of rotation is now cw
		w_dbg = w_symmetry_layers[p][q][i+gv_symmetrize_NumAxes-1]
	endfor

//	KillWaves w_interp, w_interpMirrored, M_RotatedImage

	if (! WaveExists(w_fsmap_backup))
		Duplicate w_fsmap, w_fsmap_backup
	else
		Duplicate/O w_fsmap_backup, w_fsmap
	endif
	Make/O/N=(2*max_k*sqrt(2)/delta_k+1, 2*max_k*sqrt(2)/delta_k+1) w_fsmap
	SetScale/I x, -max_k*sqrt(2), max_k*sqrt(2), w_fsmap
	SetScale/I y, -max_k*sqrt(2), max_k*sqrt(2), w_fsmap
	w_fsmap = NaN
	duplicate/o w_fsmap, w_dbg

	strswitch(ctrlName)
		case "mis_bSym":
			NVAR gv_symmetrize_cutSector
			if (gv_symmetrize_cutSector)
				// a1 and a2 are the two angles of the sector outside which
				// we have to cut the data set...
				for (i = 0; i < 2 * gv_symmetrize_NumAxes; i += 1)
					Variable a1 = gv_symmetrize_AxesAngle
					Variable a2 = 180 / gv_symmetrize_NumAxes + gv_symmetrize_AxesAngle
					if (w_symmetry_directions[1][i] == -1)
						a1 = 360 - (180 / gv_symmetrize_NumAxes + gv_symmetrize_AxesAngle)
						a2 = 360 - gv_symmetrize_AxesAngle
					endif
					a1  += w_symmetry_directions[0][i]// * w_symmetry_directions[1][i]
					a2  += w_symmetry_directions[0][i]// * w_symmetry_directions[1][i]
					
//					Variable a1 = gv_symmetrize_AxesAngle
//					Variable a2 = 180 / gv_symmetrize_NumAxes * w_symmetry_directions[1][i] + a1
//					a1  += w_symmetry_directions[0][i]// * w_symmetry_directions[1][i]
//					a2  += w_symmetry_directions[0][i]// * w_symmetry_directions[1][i]
					// This replaces a useless mod() function from Igor (not even that do they get right)
					a1 = utils_mod(a1, 360)
					a2 = utils_mod(a2, 360)
//					if (a1 == 0) // since 0 == 360, a1 is really bigger than a2 in this case. --> We have to fix it.
//						a1 = a2
//						a2 = 0
//					endif
					Variable x1 = a1<=180? 1:-1
					Variable x2 = a2<=180? 1:-1
					Variable slope1 = 1/tan(a1 / 180 * pi)
					Variable slope2 = 1/tan(a2 / 180 * pi)
					w_dbg = w_symmetry_layers[p][q][i]
					if (x1 > 0)
						w_symmetry_layers[][][i] = y>x*slope1? NaN : w_symmetry_layers[p][q][i]
					else
						w_symmetry_layers[][][i] = y<x*slope1? NaN : w_symmetry_layers[p][q][i]
					endif
					w_dbg = w_symmetry_layers[p][q][i]
					if (x2 > 0)
						w_symmetry_layers[][][i] = y<x*slope2? NaN : w_symmetry_layers[p][q][i]
					else
						w_symmetry_layers[][][i] = y>x*slope2? NaN : w_symmetry_layers[p][q][i]
					endif
					w_dbg = w_symmetry_layers[p][q][i]
				endfor
			endif
			symmetrizeFillFSmap(w_symmetry_layers, w_fsmap)
			break
		case "mis_bSymFindTheta":
		case "mis_bSymFindPhi":
		case "mis_bSymFindOmega":
			NVAR gv_symmetrize_range
			NVAR gv_symmetrize_steps

			String fermilevels = StringByKey("FermiLevels",note(w_fsmap_backup),"=","\r")
			Variable EF = str2num(StringFromList(0,fermilevels,";"))
			Variable kvac = sqrt(EF) * 0.5123
			Variable k_range = gv_symmetrize_range/180*pi * kvac
			if (numtype(k_range)!= 0)
				utils_abort("No valid EF entry in map found. Is your map screwed up?")
			endif

			Make/O/N=(gv_symmetrize_steps) w_symmetry_findAngle
			SetScale/I x, -gv_symmetrize_range/2, gv_symmetrize_range/2, w_symmetry_findAngle
			w_symmetry_findAngle = NaN

			Duplicate/O w_fsmap, w_trans_fsmap
			w_trans_fsmap = NaN
			AppendImage w_trans_fsmap
			ModifyImage w_trans_fsmap ctab= {0,1,Rainbow,0}

			DoWindow/K gFindAngle
			Display/N=gFindAngle /W=(200.25,62.75,453.75,298.25) w_symmetry_findAngle
			ModifyGraph mode=4,marker=19
			Label left "normed squared difference"
			Label bottom "Angle [deg]"
			strswitch(ctrlName)
				case "mis_bSymFindTheta":
					TextBox/N=text0/A=MT/X=0.95/Y=5.40/E "Theta [kx-direction]"
					break
				case "mis_bSymFindPhi":
					TextBox/N=text0/A=MT/X=0.95/Y=5.40/E "Phi [ky-direction]"
					break
				case "mis_bSymFindOmega":
					TextBox/N=text0/A=MT/X=0.95/Y=5.40/E "Alpha [rotation]"
					break
			endswitch
			utils_autoPosWindow("gFindAngle", win=127)
			
			Duplicate/O w_symmetry_layers, w_trans

			for(i = 0; i < gv_symmetrize_steps; i += 1)
				Variable ang = pnt2x(w_symmetry_findAngle,i)
				if (! stringmatch(ctrlName, "mis_bSymFindAlpha"))
					ang *= k_range / gv_symmetrize_range
				endif

				strswitch(ctrlName)
					case "mis_bSymFindTheta":
						w_symmetry_findAngle[i] = symmetrizeTranslate(0, ang, 0, w_trans_fsmap, w_trans)
						break
					case "mis_bSymFindPhi":
						w_symmetry_findAngle[i] = symmetrizeTranslate(ang, 0, 0, w_trans_fsmap, w_trans)
						break
					case "mis_bSymFindOmega":
						w_symmetry_findAngle[i] = symmetrizeTranslate(0, 0, ang, w_trans_fsmap, w_trans)
						break
				endswitch
				symmetrizeFillFSmap(w_trans, w_fsmap)
				DoUpdate
			endfor
			DoWindow/F mapper_panel
			RemoveImage w_trans_fsmap
			DoWindow/F gFindAngle
			CurveFit poly 3,  w_symmetry_findAngle /D
			ModifyGraph rgb(fit_w_symmetry_findAngle)=(0,0,65280)
			WAVE W_coef
			String msg
			sprintf msg, "Min: %.2f", (W_coef[1]/2/W_coef[2])
			TextBox/C/N=text1/A=MB/E msg
			KillWaves w_trans_fsmap, w_trans
			break
		default:
			utils_abort("Button name not recognized in buttonSymmetrize()")
	endswitch
//	KillWaves w_symmetry_layers, w_interp, w_symmetry_directions

	SetDataFolder $DF
End



// changes the visible tab when the tab buttons are pressed.
Static Function tabControlChange( name, tab )
	String name
	Variable tab
	
	ControlInfo $name
	String tabStr = S_Value[0,2]
	String all = ControlNameList( "mapper_panel" )
	String thisControl
	
	Variable i
	for (i = 0; i < ItemsInList(all); i+=1)
		thisControl = StringFromList( i, all )
		if( stringmatch( thisControl[3], "_" ) )
			utils_setControlEnabled( thisControl, ( stringmatch( thisControl[0,2], tabStr ) ? 0 : 1 ) )
		endif
	endfor
End




Static Function checkBoxMethod(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked			// 1 if selelcted, 0 if not
	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:FSMap
	CheckBox set_cb3V, value=(stringmatch(ctrlName,"set_cb3V")==1)
	CheckBox set_cb3P, value=(stringmatch(ctrlName,"set_cb3P")==1)
	CheckBox set_cb3B, value=(stringmatch(ctrlName,"set_cb3B")==1)
	SVAR gs_method
	strswitch(ctrlName)
		case "set_cb3V":
			gs_method = "Voronoi"
			break
		case "set_cb3P":
			gs_method = "Precise"
			break
		case "set_cb3B":
			gs_method = "Baumberger"
			break
	endswitch
	SetDataFolder $DF
End




Static Function checkBoxNormMethod(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked			// 1 if selelcted, 0 if not
	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:FSMap
	CheckBox nor_cb0N, value=(stringmatch(ctrlName,"nor_cb0N")==1)
	CheckBox nor_cb0T, value=(stringmatch(ctrlName,"nor_cb0T")==1)
	CheckBox nor_cb0P, value=(stringmatch(ctrlName,"nor_cb0P")==1)
	CheckBox nor_cb0R, value=(stringmatch(ctrlName,"nor_cb0R")==1)
	SVAR gs_norm_method
	strswitch(ctrlName)
		case "nor_cb0N":
			gs_norm_method = "None"
			break
		case "nor_cb0T":
			gs_norm_method = "Total"
			break
		case "nor_cb0P":
			gs_norm_method = "Percentile"
			break
		case "nor_cb0R":
			gs_norm_method = "Neighbor"
			break
	endswitch
	SetDataFolder $DF
End



Static Function buttonGetKSpaceLimits(ctrlname) : ButtonControl
	String ctrlname
	WAVE/T w_dialog_waves = root:internalUse:FSMap:w_dialog_waves
	getKSpaceLimits(utils_wave2StringList(w_dialog_waves))
End






















//////////////////////////////////////
//
// Private functions
// N.B.: the keyword "Static" in front of "Procedure" limits visibility to the containing Igor Procedure File only.
//
//////////////////////////////////////





























// inits all the varables neccessar to run the fsmap. Called whenever the fsmap() window is
// opened and the folder root:internalUse:FSMap does not exist.
Static Function init()
	String DF = GetDataFolder(1)
	NewDataFolder/O/S root:internalUse:FSMap
	Make/O/N=(128,128) w_fsmap
	Make/O/T/N=0 w_dialog_waves
	Make/O/I/N=0 w_dialog_selectedwaves
	Variable/G gv_centerE = 16.696
	Variable/G gv_dE = 10
	Variable/G gv_theta_offset = 0, gv_phi_offset = 0, gv_omega_offset = 0
	Variable/G gv_kx_min=-1, gv_kx_max=1, gv_ky_min=-1, gv_ky_max=1
	Variable/G gv_kx_stepsize=.025, gv_ky_stepsize=.025
	Variable/G gv_auto_grid=1
	String/G gs_method="Precise"
	String/G gs_save_wname="fsmap"

	Variable/G gv_backmapTolPrecise=20
	Variable/G gv_numInterpAngPrecise = 100
	Variable/G gv_autoInterpAngPrecise = 1
	Variable/G gv_preAvgInterpPrecise = 0

	Variable/G gv_stripeTolPreciseVoronoi = 3

	Variable/G gv_old_styleBaumberger = 1
	Variable/G gv_auto_zBaumberger = 1
	Variable/G gv_lin_combBaumberger = 1
	Variable/G gv_forceGenCfeBaumberger = 0

	Variable/G gv_intensity_cutting = 0
	Variable/G gv_intensity_lowPercent = 0
	Variable/G gv_intensity_highPercent = 0.1
	Variable/G gv_intensity_low = 1e-6
	Variable/G gv_intensity_high = 1e6

//	Variable/G gv_norm_totalInt = 0
	Variable/G gv_norm_percentile = 99
	Variable/G gv_norm_percEWindow = 0
	Variable/G gv_norm_smPercentile = 2
	String/G gs_norm_method = "None"
	Variable/G gv_norm_percIntE = 0
	Variable/G gv_norm_neighSmooth = 5
	Variable/G gv_norm_manual = 0
	Variable/G gv_normStripes = 0
	Variable/G gv_normStripes_factor = 1

	Variable/G gv_movie_startE = 16.60
	Variable/G gv_movie_endE = 16.80
	Variable/G gv_movie_deltaE = 0.01
	Variable/G gv_movie_xres = 200
	Variable/G gv_movie_yres = 200
	String/G gs_movie_hook = ""

	Variable/G gv_fsmap_minInt = 0
	Variable/G gv_fsmap_maxInt = 1
	Variable/G gv_fsmap_autoInt = 1

	Variable/G gv_symmetrize_NumAxes = 4
	Variable/G gv_symmetrize_AxesAngle = 0
	Variable/G gv_symmetrize_range = 5
	Variable/G gv_symmetrize_steps = 20
	Variable/G gv_symmetrize_cutSector = 0

	SetDataFolder $DF
End




Static Function/S genFSMapNote()

	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:FSMap

	NVAR gv_centerE
	NVAR gv_dE
	SVAR gs_method
	NVAR gv_stripeTolPreciseVoronoi
	NVAR gv_backmapTolPrecise
	NVAR gv_fsmap_minInt
	NVAR gv_fsmap_maxInt
	NVAR gv_theta_offset, gv_phi_offset, gv_omega_offset
	NVAR gv_intensity_cutting
	NVAR gv_intensity_high
	NVAR gv_intensity_highPercent
	NVAR gv_intensity_low
	NVAR gv_intensity_lowPercent
	NVAR gv_old_styleBaumberger
	NVAR gv_lin_combBaumberger
	NVAR gv_auto_zBaumberger
	
	String notestr = ""
	notestr += "Method="+gs_method+"\r"
	notestr += "CenterEnergy="+num2str(gv_centerE)+"\r"
	notestr += "EnergyIntegrationWindow="+num2str(gv_dE)+"\r"
	notestr += "MinimumIntensity="+num2str(gv_fsmap_minInt)+"\r"
	notestr += "MaximumIntensity="+num2str(gv_fsmap_maxInt)+"\r"
	notestr += "ThetaOffset="+num2str(gv_theta_offset)+"\r"
	notestr += "PhiOffset="+num2str(gv_phi_offset)+"\r"
	notestr += "OmegaOffset="+num2str(gv_omega_offset)+"\r"
	strswitch(gs_method)
		case "Voronoi":
			notestr += "VoronoiStripeTol="+num2str(gv_stripeTolPreciseVoronoi)+"\r"
			break
		case "Precise":
			notestr += "PreciseStripeTol="+num2str(gv_stripeTolPreciseVoronoi)+"\r"
			notestr += "PreciseNumBackmaps="+num2str(gv_backmapTolPrecise)+"\r"
			break
		case "Baumberger":
			notestr += "BaumbergerMergeOldStyle="+num2str(gv_old_styleBaumberger)+"\r"
			if (! gv_old_styleBaumberger)
				notestr += "BaumbergerMergeLinComb="+num2str(gv_lin_combBaumberger)+"\r"
				notestr += "BaumbergerMergeAutoZ="+num2str(gv_auto_zBaumberger)+"\r"
			endif
			break
	endswitch
	if (gv_intensity_cutting)
		notestr += "IntensityHighCutoff="+num2str(gv_intensity_high)+"\r"
		notestr += "IntensityHighPercentCutoff="+num2str(gv_intensity_highPercent)+"\r"
		notestr += "IntensityLowCutoff="+num2str(gv_intensity_low)+"\r"
		notestr += "IntensityLowPercentCutoff="+num2str(gv_intensity_lowPercent)+"\r"
	endif
	
	WAVE/T w_dialog_waves
	notestr += "NumWaves="+num2str(numpnts(w_dialog_wave))+"\r"

	notestr += "WaveList=\r"

	notestr += "ScientaOrientations=\r"
	notestr += "ManipulatorTypes=\r"
	notestr += "EnergyScales=\r"
	notestr += "AngleMappings=\r"

	notestr += "Thetas=\r"
	notestr += "Alphas=\r"
	notestr += "Phis=\r"
	notestr += "Omegas=\r"

	notestr += "FermiLevels=\r"
	notestr += "PhotonEnergies=\r"
	notestr += "WorkFunctions=\r"
	notestr += "Errors=\r"

	Variable i
	for(i = 0; i < numpnts(w_dialog_waves); i+=1)
		String wnote = note($w_dialog_waves[i])
		String s = StringByKey("WaveList", notestr, "=", "\r")+w_dialog_waves[i]+";"
		notestr = ReplaceStringByKey("WaveList", notestr, s, "=", "\r")
		s = StringByKey("ScientaOrientations",notestr,"=","\r")+StringByKey("ScientaOrientation",wnote,"=","\r")+";"
		notestr = ReplaceStringByKey("ScientaOrientations", notestr, s, "=", "\r")
		s = StringByKey("ManipulatorTypes",notestr,"=","\r")+StringByKey("ManipulatorType",wnote,"=","\r")+";"
		notestr = ReplaceStringByKey("ManipulatorTypes", notestr, s, "=", "\r")
		s = StringByKey("EnergyScales",notestr,"=","\r")+StringByKey("EnergyScale",wnote,"=","\r")+";"
		notestr = ReplaceStringByKey("EnergyScales", notestr, s, "=", "\r")
		s = StringByKey("AngleMappings",notestr,"=","\r")+StringByKey("AngleMapping",wnote,"=","\r")+";"
		notestr = ReplaceStringByKey("AngleMappings", notestr, s, "=", "\r")
		
		Variable v = NumberByKey("InitialThetaManipulator",wnote,"=","\r")
		v += NumberByKey("OffsetThetaManipulator",wnote,"=","\r")
		s = StringByKey("Thetas",notestr,"=","\r")+num2str(v)+";"
		notestr = ReplaceStringByKey("Thetas", notestr, s, "=", "\r")
		v = NumberByKey("InitialAlphaAnalyzer",wnote,"=","\r")
		s = StringByKey("Alphas",notestr,"=","\r")+num2str(v)+";"
		notestr = ReplaceStringByKey("Alphas", notestr, s, "=", "\r")
		v = NumberByKey("InitialPhiManipulator",wnote,"=","\r")
		v += NumberByKey("OffsetPhiManipulator",wnote,"=","\r")
		s = StringByKey("Phis",notestr,"=","\r")+num2str(v)+";"
		notestr = ReplaceStringByKey("Phis", notestr, s, "=", "\r")
		v = NumberByKey("InitialOmegaManipulator",wnote,"=","\r")
		v += NumberByKey("OffsetOmegaManipulator",wnote,"=","\r")
		s = StringByKey("Omegas",notestr,"=","\r")+num2str(v)+";"
		notestr = ReplaceStringByKey("Omegas", notestr, s, "=", "\r")
		
		s = StringByKey("FermiLevels",notestr,"=","\r")+StringByKey("FermiLevel",wnote,"=","\r")+";"
		notestr = ReplaceStringByKey("FermiLevels", notestr, s, "=", "\r")
		s = StringByKey("PhotonEnergies",notestr,"=","\r")+StringByKey("PhotonEnergy",wnote,"=","\r")+";"
		notestr = ReplaceStringByKey("PhotonEnergies", notestr, s, "=", "\r")
		s = StringByKey("WorkFunctions",notestr,"=","\r")+StringByKey("WorkFunction",wnote,"=","\r")+";"
		notestr = ReplaceStringByKey("WorkFunctions", notestr, s, "=", "\r")
	endfor
		
	SetDataFolder $DF
	
	return notestr
End





Static Function getKSpaceLimits(wlist)
	String wlist
	
	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:FSMap
	
	NVAR gv_centerE
	NVAR gv_theta_offset
	NVAR gv_phi_offset
	NVAR gv_omega_offset

	NVAR gv_kx_min, gv_kx_max
	NVAR gv_ky_min, gv_ky_max
	NVAR gv_kx_stepsize, gv_ky_stepsize

	gv_kx_min = inf
	gv_kx_max = -inf
	gv_ky_min = inf
	gv_ky_max = -inf

	Variable i
	for (i = 0; i < ItemsInList(wlist); i += 1)
		String wname = StringFromList(i,wlist)
		WAVE w = $wname

		String notestr = note($wname)
		String manipulator = StringByKey("ManipulatorType", notestr, "=", "\r")
		String angleMapping = StringByKey("AngleMapping", notestr, "=", "\r")
		
		String angles = getAngles(wname)
		Variable th = NumberByKey("theta", angles)
		Variable al = NumberByKey("alpha", angles)
		Variable ph = NumberByKey("phi", angles)
		Variable om = NumberByKey("omega", angles)
		Variable gamma = NumberByKey("gamma", angles)

		Variable startBeta = DimOffset(w,0)
		Variable endBeta = DimDelta(w,0) * DimSize(w,0) + startBeta

		if (stringmatch(manipulator,"flip") != 1)
			utils_Abort("Sorry, only flip manipulators are supported right now. (I think)")
		endif

		Variable energy = getFermiEnergy(wname) + gv_centerE
		Variable kvac = sqrt(energy) * 0.5123

		fsmap_flip_ang2k(th,ph,al,om,startBeta,gamma)
		WAVE angles2k_Result
		Variable kx = angles2k_Result[0] * kvac
		Variable ky = angles2k_Result[1] * kvac
		gv_kx_max = max(gv_kx_max,kx)
		gv_kx_min = min(gv_kx_min,kx)
		gv_ky_max = max(gv_ky_max,ky)
		gv_ky_min = min(gv_ky_min,ky)		

		fsmap_flip_ang2k(th,ph,al,om,endBeta,gamma)
		WAVE angles2k_Result
		kx = angles2k_Result[0] * kvac
		ky = angles2k_Result[1] * kvac
		gv_kx_max = max(gv_kx_max,kx)
		gv_kx_min = min(gv_kx_min,kx)
		gv_ky_max = max(gv_ky_max,ky)
		gv_ky_min = min(gv_ky_min,ky)		
	endfor

	Variable kx_size = gv_kx_max - gv_kx_min
	Variable ky_size = gv_ky_max - gv_ky_min

	// create a 10% border	
	gv_kx_min -= kx_size / 10
	gv_kx_max += kx_size / 10
	gv_ky_min -= kx_size / 10
	gv_ky_max += kx_size / 10

	gv_kx_stepsize = (kx_size) / 100
	gv_ky_stepsize = (ky_size) / 100

	KillWaves angles2k_Result

	SetDataFolder $DF
End




Static Function buttonNormManual(ctrlname)
	String ctrlname
	
	NVAR gv_normManualResult
	NVAR gv_norm_manualSliceNo
	NVAR gv_norm_manualFactor
	gv_normManualResult = -1
	WAVE w_normWave
	WAVE w_manualNormWave
	WAVE w_manualImage
	WAVE w_normedManualImage
	strswitch(ctrlname)
		case "manNorm_bMap":
			gv_normManualResult = 1
			break
		case "manNorm_bRevert":
			w_manualNormWave = w_normWave
			gv_norm_manualFactor = w_manualNormWave[gv_norm_manualSliceNo]
			svNormManualFactor("", 0, "", "")
			break
		case "manNorm_bOne":
			w_manualNormWave = 1
			gv_norm_manualFactor = w_manualNormWave[gv_norm_manualSliceNo]
			svNormManualFactor("", 0, "", "")
			break
		case "manNorm_bAbort":
			gv_normManualResult = 0
			break
	endswitch
	if (gv_normManualResult >= 0) // User wants to exit this; need to clean up variables & close window
		DoWindow/K gManualNormTMP
	endif
End
Static Function svNormManualSliceNo (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	NVAR gv_norm_manualSliceNo
	NVAR gv_norm_manualFactor
	WAVE w_manualNormWave
	gv_norm_manualFactor = w_manualNormWave[gv_norm_manualSliceNo]
	SetDrawLayer/K UserFront
	SetDrawEnv xcoord= bottom,ycoord= prel,dash= 1
	DrawLine gv_norm_manualSliceNo,0,gv_norm_manualSliceNo,1
	DoUpdate
End
Static Function svNormManualFactor (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	NVAR gv_norm_manualSliceNo
	NVAR gv_norm_manualFactor
	WAVE w_manualNormWave
	WAVE w_normedManualImage
	WAVE w_manualImage
	w_manualNormWave[gv_norm_manualSliceNo] = gv_norm_manualFactor
	w_normedManualImage[][] = w_manualImage[p][q] * w_manualNormWave[p]
	DoUpdate
End
Static Function slNormManualFactor(name, value, event)
	String name	// name of this slider control
	Variable value	// value of slider
	Variable event	// bit field: bit 0: value set; 1: mouse down, 
					//   2: mouse up, 3: mouse moved
	svNormManualFactor("", 0, "", "")
End
Function generateNormWaveManual(wlist)
	String wlist

	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:FSMap

	NVAR gv_centerE
	NVAR gv_dE
	Variable minE = gv_centerE - gv_dE / 2000
	Variable maxE = gv_centerE + gv_dE / 2000
	WAVE w_normWave
	Duplicate/O w_normWave, w_manualNormWave
	
	WAVE w = $StringFromList(0,wlist)
	Variable size_w = DimSize(w, 0)
	Make/O/N=(ItemsInList(wlist), size_w) w_manualImage, w_normedManualImage
	Variable i
	for (i = 0; i < ItemsInList(wlist); i += 1)
		WAVE w = $StringFromList(i,wlist)
		Integrate/DIM=1 w /D=w_tmp
		Variable dbg = utils_y2pnt(w, maxE)
		dbg = utils_y2pnt(w, minE)
		w_manualImage[i][] = w_tmp[q][utils_y2pnt(w, maxE)] - w_tmp[q][utils_y2pnt(w, minE)]
	endfor
	w_normedManualImage[][] = w_manualImage[p][q] * w_normWave[p]
	KillWaves w_tmp

	Display/K=2/N=gManualNormTMP/W=(0,0,340,500)/L=l1 w_manualNormWave as "ManualNormTMP"
	AppendImage w_normedManualImage
	ModifyImage w_normedManualImage ctab= {*,*,PlanetEarth,0}
	ModifyGraph mode=3
	ModifyGraph marker=19
	ModifyGraph msize=2
	ModifyGraph mirror(left)=2,mirror(bottom)=0
	ModifyGraph nticks(left)=0
	ModifyGraph lblPos(left)=36,lblPos(l1)=38
	ModifyGraph freePos(l1)={0,kwFraction}
	ModifyGraph axisEnab(left)={0,0.6}
	ModifyGraph axisEnab(l1)={0.65,1.00}
	Label l1 "Norm Factor"
	SetAxis l1 NORM_NEIGHBOR_MINLIMIT, NORM_NEIGHBOR_MAXLIMIT

	ControlBar/T 70

	Variable/G gv_norm_manualSliceNo = 0
	Variable/G gv_norm_manualFactor = w_normWave[gv_norm_manualSliceNo]

	SetVariable manNorm_sv0, pos={10,10}, size={120,15},limits={0,(ItemsInList(wlist)-1),1},title="Slice No.", value = gv_norm_manualSliceNo, proc=fsmap#svNormManualSliceNo
	Variable delta = (NORM_NEIGHBOR_MAXLIMIT - NORM_NEIGHBOR_MINLIMIT)/100
	SetVariable manNorm_sv1, pos={140,10}, size={200,15},limits={NORM_NEIGHBOR_MINLIMIT,NORM_NEIGHBOR_MAXLIMIT,delta},title="Norm Factor", value = gv_norm_manualFactor, proc=fsmap#svNormManualFactor
	Slider manNorm_sl0, 	 pos={140,30}, size={200,15},vert=0,ticks=0,limits={NORM_NEIGHBOR_MINLIMIT,NORM_NEIGHBOR_MAXLIMIT,delta}, variable = gv_norm_manualFactor, proc=fsmap#slNormManualFactor

	Button manNorm_bMap,    pos={10, 50}, size={50,15},title="Map",proc=fsmap#buttonNormManual
	Button manNorm_bRevert, pos={160, 50}, size={50,15},title="Revert",proc=fsmap#buttonNormManual
	Button manNorm_bOne,    pos={220, 50}, size={50,15},title="All One",proc=fsmap#buttonNormManual
	Button manNorm_bAbort,  pos={280, 50}, size={50,15},title="Abort",proc=fsmap#buttonNormManual
	
	svNormManualSliceNo("", 0, "", "")
	svNormManualFactor("", 0, "", "")

	Variable/G gv_normManualResult = -1
	PauseForUser gManualNormTMP
	
	if (gv_normManualResult > 0) // user did not press Abort, so we need to do sth
		w_normWave = w_manualNormWave
	endif
	
	Variable retval = gv_normManualResult
	KillVariables gv_norm_manualSliceNo, gv_norm_manualFactor, gv_normManualResult
	KillWaves w_manualImage, w_normedManualImage, w_manualNormWave

	return retval

	SetDataFolder $DF
End
Static Function generateNormWave(wlist)
	String wlist

	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:FSMap

	SVAR gs_norm_method
	NVAR gv_norm_neighIters
	NVAR gv_norm_percentile
	NVAR gv_norm_percEWindow
	NVAR gv_norm_percIntE
	NVAR gv_norm_smPercentile

	NVAR gv_centerE
	NVAR gv_dE
	Variable minE = gv_centerE - gv_dE / 2000
	Variable maxE = gv_centerE + gv_dE / 2000

	Make/O/N=(ItemsInList(wlist)) w_normWave
	w_normWave = 1

	Variable i
	strswitch(gs_norm_method)
		case "None":
			w_normWave = 1
			break
		case "Total":
			for (i = 0; i < ItemsInList(wlist); i+=1)
				WAVE w = $StringFromList(i,wlist)
				w_normWave[i] = 1 / sum(w) * DimSize(w, 0) * DimSize(w, 1)
			endfor
			break
		case "Percentile":
			for (i = 0; i < ItemsInList(wlist); i+=1)
				WAVE w = $StringFromList(i,wlist)
				if (gv_norm_percEWindow)
					Duplicate/O/R=(minE,maxE)[] w, w_percentile_tmp
				else
					Duplicate/O w, w_percentile_tmp
				endif
				if (gv_norm_percIntE)
					Integrate/DIM=1 w_percentile_tmp /D=w_tmp
					Duplicate/O/R=[][DimSize(w_tmp,1)-1] w_tmp, w_percentile_tmp
					KillWaves/Z w_tmp
				endif

				Make/O/N=(NORM_PERC_HISTO_SIZE), w_percHisto_tmp
				WaveStats/Q/Z w
				SetScale/I x, V_min, V_max, w_percHisto_tmp
				Histogram/B=2 w_percentile_tmp, w_percHisto_tmp
				Integrate/DIM=0 w_percHisto_tmp /D=w_percHistoInt_tmp
				Variable percentile = w_percHistoInt_tmp[NORM_PERC_HISTO_SIZE-1] * gv_norm_percentile / 100
				Variable j
				// BUGFIX FOR:
				// FindValue/T=(percentile/1000)/V=(percentile) w_percHistoInt_tmp
				for(j = 0; j < NORM_PERC_HISTO_SIZE; j += 1)
					if (w_percHistoInt_tmp[j] >= percentile)
						break
					endif
				endfor
				w_normWave[i] = 1 / pnt2x(w_percHistoInt_tmp, j)
			endfor
			Duplicate/O w_normWave, w_tmp
			if (gv_norm_smPercentile > 0)
				Smooth (gv_norm_smPercentile), w_tmp
				w_normWave /= w_tmp
			endif
			KillWaves w_percentile_tmp, w_percHisto_tmp, w_percHistoInt_tmp, w_tmp
			break
		case "Neighbor":
			// NOTE:
			// This works ONLY if the slices are sufficiently sequential and have 
			// the right properties, i.e., are the same except for one angle.
			// There have to be at least THREE waves per slice.
			WAVE w = $StringFromList(0,wlist)
			Variable size_w = DimSize(w, 0)
			Make/O/N=(size_w) w1_tmp, w2_tmp, w_tmp
			w_normWave = 1
			for (i = 0; i < ItemsInList(wlist)-1; i += 1)
				WAVE w1 = $StringFromList(i,wlist)
				Integrate/DIM=1 w1 /D=w1int_tmp
				WAVE w2 = $StringFromList(i+1,wlist)
				Integrate/DIM=1 w2 /D=w2int_tmp
				w1_tmp[] = w1int_tmp[p][utils_y2pnt(w1, maxE)] - w1int_tmp[p][utils_y2pnt(w1, minE)]
				w2_tmp[] = w2int_tmp[p][utils_y2pnt(w2, maxE)] - w2int_tmp[p][utils_y2pnt(w2, minE)]
				w_tmp[] = w1_tmp[p] / w2_tmp[p]
				w_normWave[i+1] = w_normWave[i] * sum(w_tmp) / size_w
			endfor
			NVAR gv_norm_neighSmooth
			if (gv_norm_neighSmooth > 0)
				Duplicate/O w_normWave, w_normWaveSmooth
				Smooth (gv_norm_neighSmooth), w_normWaveSmooth
				w_normWave[] /= w_normWaveSmooth[p]
				KillWaves w_normWaveSmooth
			endif
			KillWaves w1_tmp, w2_tmp, w_tmp, w1int_tmp, w2int_tmp
			break			
		default:
			Abort "Unknown normalization method: " + gs_norm_method
	endswitch

	Variable n = sum(w_normWave)
	w_normWave *= ItemsInList(wlist) / n

	SetDataFolder $DF
End




Static Function determineIntensityLimits(wlist)
	WAVE/T wlist

	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:FSMap

	NVAR gv_fsmap_minInt
	NVAR gv_fsmap_maxInt
	NVAR gv_fsmap_autoInt
	
	NVAR gv_centerE
	NVAR gv_dE
	Variable minE = gv_centerE - gv_dE / 2000
	Variable maxE = gv_centerE + gv_dE / 2000

	gv_fsmap_minInt = inf
	gv_fsmap_maxInt = -inf
	
	// Need to apply the intensity normalization, if any:
	generateNormWave(utils_wave2stringList(wlist))
	WAVE w_normWave
//	w_normWave[] = 1
	
	Variable i
	for (i = 0; i < numpnts(wlist); i+=1)
		WAVE w = $wlist[i]
		Integrate/DIM=1 w /D=w_INTcut_tmp

		WAVE w_normWave
		Variable j
		for (j = 0; j < DimSize(w, 1); j += 1)
			Variable int = (w_INTcut_tmp[j](maxE) - w_INTcut_tmp[j](minE)) * w_normWave[j]
			gv_fsmap_minInt = min(gv_fsmap_minInt, int)
			gv_fsmap_maxInt = max(gv_fsmap_maxInt, int)
		endfor
	endfor
	KillWaves w_INTcut_tmp
	if (gv_fsmap_autoInt)
		ModifyImage w_fsmap ctab= {(gv_fsmap_minInt),(gv_fsmap_maxInt),Grays,0}
	else
		ModifyImage w_fsmap ctab= {*,*,Grays,0}
	endif

	SetDataFolder $DF
End





// TODO: maybe put this in a global utilities file?
// checks if the wave wname has attribute keyname in its note string.
// Returns the value associated with keyname.
// If is_required is 1 and keyname is missing(undefined), it will abort, telling the 
// user that a required keyname is missing in the wave.
// If is_required is 0 and keyname is missing(undefined), it will return the empty string ""
Static Function getNumber(keyname,wname,is_required)
	String keyname
	String wname
	Variable is_required
	String notestr = note($wname)
	Variable ret = NumberByKey(keyname, notestr, "=", "\r")
	if (is_required != 0 && numtype(ret) != 0) 
		utils_Abort("The key \""+keyname+"\" in wave "+wname+" is not defined. Please use the filetable to define it and try again.")
	endif
	return ret
End




// Takes the first wave out of wlist. Then it subsequentially treats all waves whose 
// angular distance sqrt(theta^2+alpha^2+phi^2+om^2) is smaller than max_dist 
// as belonging to the same "stripe" of the angular mapping. Returns a list of neighboring waves.
// This function is used by both the Precise and the Voronoi method.
// TODO: Maybe later integrate the Baumberger method to use this merging as well.
//
// Returns a string with the wave stripe.
Static Function/S getWaveStripe(wlist, max_dist)
	String wlist
	Variable max_dist

	// Take the first wave from wlist:
	String wname = StringFromList(0, wlist)
	String wname2 = ""
	Variable found_wave_for_stripe = 0
	String stripe_of_waves = wname + ";"
	wlist = RemoveFromList(wname, wlist)

	for (;strlen(wlist) != 0;)
		found_wave_for_stripe = 0

		Variable i
		// measure the distance from each wave in stripe_of_waves ........
		for (i = 0; i < ItemsInList(stripe_of_waves); i+=1)
			wname = StringFromList(i, stripe_of_waves)
			String angles = getAngles(wname)
			Variable th1 = NumberByKey("theta", angles)
			Variable al1 = NumberByKey("alpha", angles)
			Variable ph1 = NumberByKey("phi", angles)
			Variable om1 = NumberByKey("omega", angles)
	
			Variable j
			// ...... against each of the remainind waves in wlist ......
			Variable min_d_squared = inf
			String min_d_wname = ""
			for(j = 0; j < ItemsInList(wlist); j+=1)
				wname2 = StringFromList(j, wlist)
				angles = getAngles(wname2)
				Variable th2 = NumberByKey("theta", angles)
				Variable al2 = NumberByKey("alpha", angles)
				Variable ph2 = NumberByKey("phi", angles)
				Variable om2 = NumberByKey("omega", angles)
				// This is debatable: since alpha and theta are technically equivalent, 
				// one could also put alpha and theta together. But then we would not
				// account for that this is a completely different polarization if you alter theta/alpha
				Variable d_squared = (al2-al1)^2 + (th2-th1)^2 + (ph2-ph1)^2 + (om2-om1)^2
				// ...... and if distance smaller, move wave over and set found_wave_for_stripe to true
				if (d_squared <= max_dist^2)
					found_wave_for_stripe = 1
					if (min_d_squared > d_squared) // ... also check if this is the wave w/ MINIMUM distance
						min_d_wname = wname2
						min_d_squared = d_squared
					endif
				endif
			endfor
			if (found_wave_for_stripe)
				// found a new wave from wlist. That means wlist was modified. That means 
				// we have to exit the wlist for() loop and start over for things not to get scrambled.
				// Also note that the i == 0 condition ensures that nearest neighbors are kept 
				// in order:
				if (i == 0)
					stripe_of_waves = min_d_wname + ";" + stripe_of_waves
				else
					stripe_of_waves += min_d_wname + ";"
				endif
				wlist = RemoveFromList(min_d_wname, wlist)
				break
			endif
		endfor
		if (! found_wave_for_stripe) // No more waves found that belong to this stripe. Job done.
			break
		endif
	endfor
	return stripe_of_waves
End



Function fsmap_mergeStripeNorm_LSq(w, x)
	WAVE w // no options
	Variable x
	WAVE w_fsmap = root:internalUse:FSMap:w_fsmap
	WAVE w_stripemap = root:internalUse:FSMap:w_stripemap
	Variable i, j, lSq
	lSq = NaN
	For (i = 0; i < DimSize(w_fsmap, 0); i += 1)
		For (j = 0; j < DimSize(w_fsmap, 1); j += 1)
			If ((numtype(w_fsmap[i][j]) == 0) && (numtype(w_stripemap[i][j]) == 0))
				Variable n = (w_stripemap[i][j]*x-w_fsmap[i][j])^2
				lSq = (numtype(lSq)!=0) ? n : lSq + n
			EndIf
		EndFor
	EndFor
	return lSq
End




// Calculates the number(norm) by which the stripe-to-be-merged has to be multiplied in order to 
// have the minimum least-squares difference in the overlapping region. Should make the merged
// region smoother.
Static Function mergeStripeNorm()
	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:FSMap
	NVAR gv_normStripes_factor
	NVAR gv_normStripes

	if (gv_normStripes == 0)
		gv_normStripes_factor = 1
		SetDataFolder $DF
		return 0
	endif

	Make/O/N=0 w_parms
	Optimize/A=0/Q/L=0.1/H=10 fsmap_mergeStripeNorm_LSq, w_parms
	KillWaves w_parms

	if (V_Flag != 0)
		DoAlert 0, "Warning: Norming stripes failed. Probably because regions do not overlap. Norm set to 1."
		gv_normStripes_factor = 1
		SetDataFolder $DF
		return 0
	endif
	gv_normStripes_factor = V_minloc
	return 1
End




// Merges the map in w_stripemap (which is created by the above 
// mapStripeVoronoi(wavelist)) with the stuff that is already 
// in w_fsmap: For each point in kx,ky-space, check for the following 
// possible cases:
// - is point NaN in w_stripemap? --> Nothing to be merged
// - is point NaN in w_fsmap but defined in w_stripemap? --> Trivial: w_fsmap = w_stripemap at that point
// - is point defined in BOTH w_fsmap and w_stripemap? --> merge, with linear weight in direction of
//           the cut in w_stripemap, using w_stripemap_dkx and w_stripemap_dky
Static Function merge()
	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:FSMap
	WAVE w_fsmap
	WAVE w_stripemap
	Duplicate/O w_fsmap, w_new_fsmap
	WAVE w_stripemap_dkx
	WAVE w_stripemap_dky
	w_new_fsmap[p][q] = NaN

	Variable max_x = DimSize(w_fsmap, 0)
	Variable max_y = DimSize(w_fsmap, 1)

	PauseUpdate

	NVAR gv_normStripes_factor

	Variable j
	Variable userAbort = 0
	
	for (j = 0; j < max_y && userAbort == 0; j+=1)
		Variable i
		for (i = 0; i < max_x && userAbort == 0; i+=1)
			if (mod(i+j*max_x, 1000) == 0)
				if(utils_progressDlg(message="merge: merging...", numDone=i+j*max_x,numTotal=max_x*max_y, level=2))
					userAbort = 1
					break
				endif
			endif
			
			// w_stripemap is not NaN at this point? -> we need to do something
			if(numtype(w_stripemap[i][j]) != 0)
				continue
			endif
			
			if (numtype(w_fsmap[i][j]) != 0) // only w_stripemap contains data. -> easy.
				w_new_fsmap[i][j] = w_stripemap[i][j] * gv_normStripes_factor
				continue
			endif
			
			// w_fsmap already contains data there. Not so easy.
			// This is how it's done:
			// from the point in question, go left and right (i.e. forward and backward) in the
			// direction parallel to the slice (which is saved by mapStripeVoronoi() into
			// w_stripemap_dkx and w_stripemap_dky), one pixel at a time, until we hit the border
			// of one of the wto overlapping carpets, i.e. until one of the two pixels is NaN.
			// Then merge the pixel, weighted by the number of pixels gone in each direction.
			Variable kx = i, ky = j
			Variable right = 0
			String right_wname = ""
			do 
				right += 1
				kx -= w_stripemap_dkx[i][j]
				ky -= w_stripemap_dky[i][j]
			while ( (numtype(w_stripemap[kx][ky]) == 0) && (numtype(w_fsmap[kx][ky]) == 0) )
			if (numtype(w_stripemap[kx][ky]) == 0)
				right_wname = "w_stripemap"
			else
				right_wname = "w_fsmap"
			endif
			kx = i
			ky = j
			Variable left = 0
			String left_wname = ""
			do 
				left += 1
				kx += w_stripemap_dkx[i][j]
				ky += w_stripemap_dky[i][j]
			while ( (numtype(w_stripemap[kx][ky]) == 0) && (numtype(w_fsmap[kx][ky]) == 0) )
			if (numtype(w_stripemap[kx][ky]) == 0)
				left_wname = "w_stripemap"
			else
				left_wname = "w_fsmap"
			endif
			WAVE left_wave = $left_wname
			WAVE right_wave = $right_wname
			if (stringmatch(left_wname, "w_stripemap"))
				w_new_fsmap[i][j] = ( right * left_wave[i][j] * gv_normStripes_factor + left * right_wave[i][j] ) / ( left + right )
			else
				w_new_fsmap[i][j] = ( right * left_wave[i][j] + left * right_wave[i][j] * gv_normStripes_factor ) / ( left + right )
			endif
		endfor
	endfor

	w_fsmap = w_new_fsmap
	KillWaves w_new_fsmap
	
	ResumeUpdate

	SetDataFolder $DF
End





Static Function generateStripeMask(wlist)
	String wlist
	
	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:FSMap
	
	NVAR gv_centerE
	NVAR gv_theta_offset
	NVAR gv_phi_offset
	NVAR gv_omega_offset
	NVAR gv_kx_stepsize, gv_ky_stepsize

	WAVE w_stripemap
	Duplicate/O w_stripemap, w_stripemap_mask
	w_stripemap_mask = 0

	Variable i
	Variable old_kx_start = NaN
	Variable old_ky_start = NaN
	Variable old_kx_end = NaN
	Variable old_ky_end = NaN
	for (i = 0; i < ItemsInList(wlist); i += 1)
		String wname = StringFromList(i,wlist)
		WAVE w = $wname

		String notestr = note($wname)
		String manipulator = StringByKey("ManipulatorType", notestr, "=", "\r")
		String angleMapping = StringByKey("AngleMapping", notestr, "=", "\r")
		
		String angles = getAngles(wname)
		Variable th = NumberByKey("theta", angles)
		Variable al = NumberByKey("alpha", angles)
		Variable ph = NumberByKey("phi", angles)
		Variable om = NumberByKey("omega", angles)
		Variable gamma = NumberByKey("gamma", angles)
		
		if (stringmatch(manipulator,"flip") != 1)
			utils_Abort("Sorry, only flip manipulators are supported right now. (I think)")
		endif

		Variable energy = getFermiEnergy(wname) + gv_centerE
		Variable kvac = sqrt(energy) * 0.5123

		Variable startBeta = DimOffset(w,0)
		Variable endBeta = DimDelta(w,0) * DimSize(w,0) + startBeta

		fsmap_flip_ang2k(th,al,ph,om,startBeta,gamma)
		WAVE angles2k_Result
		Variable kx_start = angles2k_Result[0] * kvac
		Variable ky_start = angles2k_Result[1] * kvac

		fsmap_flip_ang2k(th,al,ph,om,endBeta,gamma)
		WAVE angles2k_Result
		Variable kx_end = angles2k_Result[0] * kvac
		Variable ky_end = angles2k_Result[1] * kvac
		
		Variable kx_seed, ky_seed

		if (i > 0)
			utils_drawLineInMatrix(w_stripemap_mask, old_kx_start,old_ky_start,kx_start,ky_start, 1)
			utils_drawLineInMatrix(w_stripemap_mask, old_kx_end,old_ky_end,kx_end,ky_end, 1)
		endif
		
		if (i == 0 || i == ItemsInList(wlist) - 1)
			Variable beta
			for (beta = startBeta; beta < endBeta; beta += DimDelta(w,0))
				fsmap_flip_ang2k(th,al,ph,om,beta,gamma)
				WAVE angles2k_Result
				Variable kx_b0 = angles2k_Result[0] * kvac
				Variable ky_b0 = angles2k_Result[1] * kvac	
				fsmap_flip_ang2k(th,al,ph,om,beta+DimDelta(w,0),gamma)
				WAVE angles2k_Result
				Variable kx_b1 = angles2k_Result[0] * kvac
				Variable ky_b1 = angles2k_Result[1] * kvac	
				utils_drawLineInMatrix(w_stripemap_mask, kx_b0,ky_b0,kx_b1,ky_b1, 1)
			endfor
		endif
		
//		if (i == 1)
//			kx_seed = kx_start
//			ky_seed = ky_start
//			fsmap_flip_ang2k(th,al,ph,om,startBeta,gamma)
//			WAVE angles2k_Result
//			kx_b0 = angles2k_Result[0] * kvac
//			ky_b0 = angles2k_Result[1] * kvac	
			// One degree is generally a reasonable assumption here (startBeta+1)
			// since choosing it too small (e.g. DimDelta(w,0)) can reault in the seed pixel lying on the
			// rim of the shape, and choosing it too large can mean that the seep pixel can lie outside
//			fsmap_flip_ang2k(th,al,ph,om,startBeta+DimDelta(w,0)/abs(DimDelta(w,0)),gamma)
//			WAVE angles2k_Result
//			kx_seed = angles2k_Result[0] * kvac
//			ky_seed = angles2k_Result[1] * kvac
//			kx_b1 = angles2k_Result[0] * kvac
//			ky_b1 = angles2k_Result[1] * kvac	
//			Variable len = sqrt((kx_start - old_kx_start)^2 + (ky_start - old_ky_start)^2)
//			len /= sqrt((kx_b1 - kx_b0)^2 + (ky_b1 - ky_b0)^2)
//			kx_seed += (kx_b1-kx_b0) * len
//			ky_seed += (ky_b1-ky_b0) * len
//		endif
		if ( i == trunc(ItemsInList(wlist)/2) )
			fsmap_flip_ang2k(th,al,ph,om,(startBeta+endBeta)/2,gamma)
			WAVE angles2k_Result
			kx_seed = angles2k_Result[0] * kvac
			ky_seed = angles2k_Result[1] * kvac	
		endif
		
		old_kx_start = kx_start
		old_ky_start = ky_start
		old_kx_end = kx_end
		old_ky_end = ky_end
	endfor
//	printf "Image seed: %e, %e", kx_seed, ky_seed
//	w_stripemap_mask[utils_pnt2x(w_stripemap_mask, kx_seed)][utils_pnt2y(w_stripemap_mask, ky_seed)] = 0.2
	ImageSeedFill/O min=-0.5, max=0.5, target=1, seedX=kx_seed, seedY=ky_seed, srcWave=w_stripemap_mask

	KillWaves angles2k_Result

	SetDataFolder $DF
End




// returns a KeyList with the five angles(e.g. "omega:1;gamma:2;theta:34;alpha:2;phi:-12;"), ready
// with global angle offsets and error checking to see if everything is defined in the wave.
Static Function/S getAngles(wname)
	String wname
	String notestr = note($wname)

	NVAR gv_theta_offset
	NVAR gv_phi_offset
	NVAR gv_omega_offset

	Variable gamma = getNumber("ScientaOrientation",wname,1)
	Variable th = getNumber("InitialThetaManipulator",wname,1)
	th  += getNumber("OffsetThetaManipulator",wname,1)
	th += gv_theta_offset
	Variable al = getNumber("InitialAlphaAnalyzer",wname,1)
	Variable ph = getNumber("InitialPhiManipulator",wname,1)
	ph += getNumber("OffsetPhiManipulator",wname,1)
	ph += gv_phi_offset
	Variable om = getNumber("InitialOmegaManipulator",wname,1)
	om += getNumber("OffsetOmegaManipulator",wname,1)
	om += gv_omega_offset
	
	String ret = ""
	sprintf ret, "omega:%e;gamma:%e;theta:%e;alpha:%e;phi:%e;", om, gamma, th, al, ph
	return ret
End




Static Function getFermiEnergy(wname)
	String wname
	
	Variable energy = NaN
	
	String notestr = note($wname)
	String eScale = StringByKey("EnergyScale", notestr, "=", "\r")
	Variable EF = getNumber("FermiLevel",wname,1)
	Variable hn = getNumber("PhotonEnergy",wname,1)
	Variable workfunc = getNumber("WorkFunction",wname,1)
	if (Stringmatch(eScale,"kinetic"))
		energy = hn-EF - workfunc
	elseif (stringmatch(eScale,"Initial*"))
		energy = hn - workfunc
	else
		utils_Abort("The 'EnergyScale' keyword-value must be 'kinetic' or 'InitialState'. Please change in filetable.")
	endif
	return energy
End



//
// Helper Functions for buttonSymmetrize:
//

Static Function symmetrizeMirrorFSMap(angle)
	Variable angle

	WAVE w_interp
	Variable delta_k = DimDelta(w_interp,0)
	
	duplicate/O w_interp, w_dbg
	// 1. rotate by -theta
	// the /Q (quiet operation) is there because otherwise it complains about "Zero rotation".
	ImageRotate/Q/A=(angle)/E=(NaN) w_interp
	WAVE M_RotatedImage
	// ImageRotate does not preserve the image scaling. -> apply the following bugfix:
	// bugfix BEGIN
	Variable new_x = (DimSize(M_RotatedImage, 0)-1) / 2 * delta_k
	Variable new_y = (DimSize(M_RotatedImage, 1)-1) / 2 * delta_k
	SetScale/I x, -new_x, new_x, M_RotatedImage
	SetScale/I y, -new_y, new_y, M_RotatedImage
	// bugfix END
	w_dbg[][] = M_RotatedImage(x)(y)
	// 2. mirror horizontally:
	Duplicate/O M_RotatedImage, w_interpMirrored
	w_interpMirrored[][] = M_RotatedImage[DimSize(M_RotatedImage,0)-1-p][q]
	w_dbg[][] = w_interpMirrored[p][q]
	// 3. rotate by angle:
	// the /Q (quiet operation) is there because otherwise it complains about "Zero rotation".
	ImageRotate/Q/A=(-angle)/E=(NaN) w_interpMirrored
	WAVE M_RotatedImage
	// ImageRotate does not preserve the image scaling. -> apply the following bugfix:
	// bugfix BEGIN
	new_x = (DimSize(M_RotatedImage, 0)-1) / 2 * delta_k
	new_y = (DimSize(M_RotatedImage, 1)-1) / 2 * delta_k
	SetScale/I x, -new_x, new_x, M_RotatedImage
	SetScale/I y, -new_y, new_y, M_RotatedImage
	w_dbg[][] = M_RotatedImage(x)(y)
	KillWaves w_interpMirrored
End




Static Function symmetrizeTranslate(kx, ky, angle, w_fsmap, w_trans)
	Variable kx, ky, angle
	WAVE w_fsmap, w_trans

	WAVE w_symmetry_layers, w_symmetry_directions

	Variable delta_k = DimDelta(w_symmetry_layers,0)
	
	Variable i
	for (i = 0; i < DimSize(w_trans,2); i += 1)
		Variable coord_ang = w_symmetry_directions[0][i] / 180 * pi // Angle of y axis of coord system, in cw rotation
		Variable coord_rot = w_symmetry_directions[1][i] // sense of rotation. 1 = cw, -1 = ccw
		Make/O/N=(DimSize(w_trans,0),DimSize(w_trans,1)) w_tmp
		w_tmp = w_symmetry_layers[p][q][i]
		ImageRotate/Q/A=(coord_rot * angle)/E=(NaN) w_tmp
		WAVE M_RotatedImage
		Variable new_x = (DimSize(M_RotatedImage, 0)-1) / 2 * delta_k
		Variable new_y = (DimSize(M_RotatedImage, 1)-1) / 2 * delta_k
		SetScale/I x, -new_x, new_x, M_RotatedImage
		SetScale/I y, -new_y, new_y, M_RotatedImage
		Variable kx_i = kx * coord_rot
		Variable ky_i = ky
		Variable tmp = kx_i * cos(coord_ang) + ky_i * sin(coord_ang)
		ky_i = - kx_i * sin(coord_ang) + ky_i * cos(coord_ang)
		kx_i = tmp
//		nkx *= coord_rot // if the sense of rotation is ccw, we also need to make coord system ccw
		w_trans[][][i] = M_RotatedImage(x-kx_i)(y-ky_i)
	endfor
	Duplicate/O w_fsmap, w_fsmap_norm
	w_fsmap = 0
	w_fsmap_norm = 0
	for (i = 0; i < DimSize(w_trans,2); i += 1)
		Variable j
		for (j = i+1; j < DimSize(w_trans,2); j += 1)
			w_fsmap[][] += (numtype(w_trans[p][q][i]) == 0 && numtype(w_trans[p][q][j]) == 0)?4*(w_trans[p][q][i]-w_trans[p][q][j])^2/(w_trans[p][q][i]+w_trans[p][q][j])^2:0
			w_fsmap_norm[][] += (numtype(w_trans[p][q][i]) == 0 && numtype(w_trans[p][q][j]) == 0)?1:0
		endfor
	endfor
	w_fsmap[][] /= (w_fsmap_norm[p][q] > 0)?w_fsmap_norm[p][q]:1
	w_fsmap_norm[][] = (w_fsmap_norm[p][q] == 0)?0:1
	Variable retval = sum(w_fsmap) / sum(w_fsmap_norm)
	w_fsmap[][] = (w_fsmap_norm[p][q] == 0)? NaN : w_fsmap[p][q]
	KillWaves w_tmp, w_fsmap_norm
	return retval
End



Static Function symmetrizeFillFSmap(w_symmetry_layers, w_fsmap)
	WAVE w_symmetry_layers
	WAVE w_fsmap
	
	Duplicate/O w_fsmap, w_fsmap_norm
	w_fsmap = 0
	w_fsmap_norm = 0
	
	Variable i
	for(i = 0; i < DimSize(w_symmetry_layers, 2); i += 1)
		w_fsmap[][] += (numtype(w_symmetry_layers[p][q][i])==0)?w_symmetry_layers[p][q][i]:0
		w_fsmap_norm[][] += (numtype(w_symmetry_layers[p][q][i])==0)?1:0
	endfor
	w_fsmap[][] = (w_fsmap_norm[p][q]>0)?w_fsmap[p][q]/w_fsmap_norm[p][q]:NaN
	KillWaves w_fsmap_norm
End




////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
/////////   Voronoi Method
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////


// creates a map of a stripe constructed by getWaveStripe()
// (In order to add to the general confusion of terminology, I call a set of continuous
// cuts which belong to a carpet/rectangular region in the FS a "stripe".)
// wlist is the list of waves belonging to one stripe, using Voronoi interpolation.
//
// Will store its result in w_stripemap. 
// w_stripemap_dky, w_stripemap_dkx are used to determine in which direction the 
// cut runs in k-space in order to merge with the other stripes.
// Returns a string containing non-fatal error messages, if any occurred.
Static Function/S mapStripeVoronoi(wlist)
	String wlist
	
	String return_errors = ""
	
	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:FSMap
	
	NVAR gv_centerE
	NVAR gv_dE
	NVAR gv_theta_offset
	NVAR gv_phi_offset
	NVAR gv_omega_offset

	Variable numdatapoints = 0

	Variable minE = gv_centerE - gv_dE / 2000
	Variable maxE = gv_centerE + gv_dE / 2000

	Variable i
	// count the number of scatterplot points we need.
	for (i = 0; i < ItemsInList(wlist); i += 1)
		String wname = StringFromList(i,wlist)
		WAVE w = $wname
		numdatapoints += DimSize(w,0)
	endfor

	Make/O/N=(numdatapoints, 3) w_kspace_scatterdata
	

	// stores the direction of the cut in kx-ky-space. Needed later for
	// merging the carpets.
	Make/O/N=(ItemsInList(wlist)*2,3) w_dkx, w_dky
	Variable idx = 0
	// Need to apply the intensity normalization, if any:
	NVAR gv_norm_manual
	Variable dlgResult
	if (gv_norm_manual)
		generateNormWave(wlist)
		dlgResult = generateNormWaveManual(wlist)
		if (dlgResult == 0)
			utils_abort("Aborted by user.")
		endif
	else
		generateNormWave(wlist)
	endif

	for (i = 0; i < ItemsInList(wlist); i += 1)
		wname = StringFromList(i,wlist)
		WAVE w = $wname
		if (utils_progressDlg(message="mapStripeVoronoi: Filling scatterdata with waves", level=1,numDone=i, numTotal=ItemsInList(wlist)))
			break
		endif
		String notestr = note($wname)
		String manipulator = StringByKey("ManipulatorType", notestr, "=", "\r")
		String angleMapping = StringByKey("AngleMapping", notestr, "=", "\r")
		
		String angles = getAngles(wname)
		Variable th = NumberByKey("theta", angles)
		Variable al = NumberByKey("alpha", angles)
		Variable ph = NumberByKey("phi", angles)
		Variable om = NumberByKey("omega", angles)
		Variable gamma = NumberByKey("gamma", angles)
//		Variable crystal_a = getNumber("CrystalAxisA",wname,1)
//		Variable crystal_b = getNumber("CrystalAxisB",wname,1)
//TODO: include above into kx,ky calculation

		Variable numBetas = DimSize(w,0)
		Variable startBeta = DimOffset(w,0)
		Variable deltaBeta = DimDelta(w,0)

		Variable beta = startBeta

		if (stringmatch(manipulator,"flip") != 1)
			utils_Abort("Sorry, only flip manipulators are supported right now. (I think)")
		endif

		WAVE w_normWave
		Integrate/DIM=1 w /D=w_INT_tmp
		Make/O/N=(numBetas) w_tmp
		WAVE w_INT_tmp
		w_tmp[] = w_INT_tmp[p][utils_y2pnt(w,maxE)] - w_INT_tmp[p][utils_y2pnt(w,minE)]
		w_tmp[] *= w_normWave[i]

		Variable l
		Variable old_kx, old_ky
		for (l = 0; l < numBetas; l+=1)

//			Duplicate/O/R=[l,l][utils_y2pnt(w,minE),utils_y2pnt(w,maxE)] w,energies
//			Variable intensity = sum(energies) * DimDelta(w,1) * w_normWave[i]
			Variable intensity = w_tmp[l]

			Variable energy = getFermiEnergy(wname) + gv_centerE
			Variable kvac = sqrt(energy) * 0.5123

			fsmap_flip_ang2k(th,al,ph,om,beta,gamma)
			WAVE angles2k_Result

			w_kspace_scatterdata[idx][0] = angles2k_Result[0] * kvac
			w_kspace_scatterdata[idx][1] = angles2k_Result[1] * kvac
			w_kspace_scatterdata[idx][2] = intensity
			
			if (l == 1)
				Variable dkx = angles2k_Result[0] * kvac - old_kx
				Variable dky = angles2k_Result[1] * kvac - old_ky
				w_dkx[i * 2][0] = angles2k_Result[0] * kvac
				w_dky[i * 2][0] = angles2k_Result[0] * kvac
				w_dkx[i * 2][1] = angles2k_Result[1] * kvac
				w_dky[i * 2][1] = angles2k_Result[1] * kvac
				w_dkx[i * 2][2] = dkx / sqrt (dkx^2 + dky^2)
				w_dky[i * 2][2] = dky / sqrt (dkx^2 + dky^2)
			elseif (l == numBetas - 1)
				dkx = angles2k_Result[0] * kvac - old_kx
				dky = angles2k_Result[1] * kvac - old_ky
				w_dkx[i * 2 + 1][0] = angles2k_Result[0] * kvac
				w_dky[i * 2 + 1][0] = angles2k_Result[0] * kvac
				w_dkx[i * 2 + 1][1] = angles2k_Result[1] * kvac
				w_dky[i * 2 + 1][1] = angles2k_Result[1] * kvac
				w_dkx[i * 2 + 1][2] = dkx / sqrt (dkx^2 + dky^2)
				w_dky[i * 2 + 1][2] = dky / sqrt (dkx^2 + dky^2)
			endif
			
			old_kx = angles2k_Result[0] * kvac
			old_ky = angles2k_Result[1] * kvac
			

			idx += 1

			beta += deltaBeta

		endfor
	endfor
	
	KillWaves angles2k_Result, w_tmp, w_INT_tmp

	
	if (utils_progressDlg(message="mapStripeVoronoi: Interpolating (please be patient).", level=1))
		KillWaves/Z M_InterpolatedImage, w_kspace_scatterdata, w_dkx, w_dky
		return "Aborted by user"
	endif
		
	// TODO: this is an UGLY bug fix since the number of data points is not calculated correctly:
	if (idx != DimSize(w_kspace_scatterdata, 0))
		sprintf return_errors, "%sBUGFIX: actual data points(%d) do not match calculated(%d). Resizing.;", return_errors, idx, DimSize(w_kspace_scatterdata, 0)
		Redimension/N=(idx,3) w_kspace_scatterdata
	endif
	
	NVAR gv_kx_min, gv_kx_max
	NVAR gv_ky_min, gv_ky_max
	NVAR gv_kx_stepsize, gv_ky_stepsize
	
	// Method 1: use scatterdata and perform a sparse data Voronoi fit.
	
	ImageInterpolate/S={gv_kx_min,gv_kx_stepsize,gv_kx_max,gv_ky_min,gv_ky_stepsize,gv_ky_max} Voronoi w_kspace_scatterdata
	WAVE M_InterpolatedImage
	Duplicate/O M_InterpolatedImage, w_stripemap
	SetScale/P x, gv_kx_min, gv_kx_stepsize, "kx", w_stripemap
	SetScale/P y, gv_ky_min, gv_ky_stepsize, "ky", w_stripemap
	ImageInterpolate/S={gv_kx_min,gv_kx_stepsize,gv_kx_max,gv_ky_min,gv_ky_stepsize,gv_ky_max} Voronoi w_dkx
	WAVE M_InterpolatedImage
	Duplicate/O M_InterpolatedImage, w_stripemap_dkx
	SetScale/P x, gv_kx_min, gv_kx_stepsize, "kx", w_stripemap_dkx
	SetScale/P y, gv_ky_min, gv_ky_stepsize, "ky", w_stripemap_dkx
	ImageInterpolate/S={gv_kx_min,gv_kx_stepsize,gv_kx_max,gv_ky_min,gv_ky_stepsize,gv_ky_max} Voronoi w_dky
	WAVE M_InterpolatedImage
	Duplicate/O M_InterpolatedImage, w_stripemap_dky
	SetScale/P x, gv_kx_min, gv_kx_stepsize, "kx", w_stripemap_dky
	SetScale/P y, gv_ky_min, gv_ky_stepsize, "ky", w_stripemap_dky

	KillWaves M_InterpolatedImage, w_kspace_scatterdata, w_dkx, w_dky
	
	SetDataFolder $DF
	
	return return_errors
End




////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
/////////   Precise Method
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////




// Internal function to optimize.
// the first five positions of w carry the five angles in the order
// t, a, p, o, b, g
// The two idx* are the two variables to be optimized.
Static Function findFlipAnglePrecise(w, idx1, idx2, ang_x, ang_y, tol, maxIter)
	WAVE w
	Variable idx1, idx2
	Variable ang_x, ang_y
	Variable tol
	Variable maxIter

	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:FSMap

	NVAR gv_theta_offset
	NVAR gv_phi_offset
	NVAR gv_omega_offset

	Variable da1 = sqrt(tol)*180/pi*10, da2 = sqrt(tol)*180/pi*10
	Variable a1, a2
	Variable numIter = 0
	// What follows is a dumb optimization routine. 
	// <START RANT>
	// I spent half a day trying to
	// get the builtin Igor optimize function (and others) to work, but none of them
	// did work, although this is a trivial problem to optimize; the function is a map 
	// in the mathematical sense, i.e. no singularities, each (kx,ky) has (usually)
	// exactly one pair of (idx1, idx2) angles to map to and vice versa.
	// The Function is smooth. It does not get any easier than that. It is a mystery
	// why all optimizers/numerical solvers supplied by Igor with all their fany options
	// fail miserably.
	// <END RANT>
	// What this does is the following:
	// 1. 	take a pair of a1,a2 starting values. Calculate corresponding kx,ky.
	//		Measure the distance between the goal kx,ky and the ones resulting from a1,a2.
	//		Save it in d.
	// 2.		do the same as in 1., but with a1-da1, save it in d_a1_lo
	// 3.		do the same as in 1., but with a1+da1, save it in d_a1_hi
	// 4.		do the same as in 1., but with a2-da2, save it in d_a2_lo
	// 5.		do the same as in 1., but with a2+da2, save it in d_a2_hi
	// 6.		Look which one of the three d's we just calculated  for a1, a1+-da1 is the minimum.
	//		-	if it's d, the optimum for a1,a2 lies between a1+-da1. --> half da1, and go to
	//			either a1+da1 or a1-da1, depending on which d is smaller.
	//		- 	if it's one of the d_a1_lo/hi, go to a1-/+da1.
	// 7. 	Goto 1. if d is above the given tolerance, otherwise exit with the solution.
	// 7a.	If iterations > 10000, return NaN
	do
		a1 = w[idx1]
		a2 = w[idx2]

		w[idx1] = a1
		w[idx2] = a2
		fsmap_flip_ang2k(w[0],w[1],w[2],w[3],w[4], w[5])
		WAVE angles2k_Result
		Variable d = ( (angles2k_Result[0] - ang_x)^2 + (angles2k_Result[1] - ang_y)^2 )

		w[idx1] = a1 - da1
		w[idx2] = a2
		fsmap_flip_ang2k(w[0],w[1],w[2],w[3],w[4], w[5])
		WAVE angles2k_Result
		Variable d_a1_lo = ( (angles2k_Result[0] - ang_x)^2 + (angles2k_Result[1] - ang_y)^2 )

		w[idx1] = a1 + da1
		w[idx2] = a2
		fsmap_flip_ang2k(w[0],w[1],w[2],w[3],w[4], w[5])
		WAVE angles2k_Result
		Variable d_a1_hi = ( (angles2k_Result[0] - ang_x)^2 + (angles2k_Result[1] - ang_y)^2 )

		w[idx1] = a1
		w[idx2] = a2 - da2
		fsmap_flip_ang2k(w[0],w[1],w[2],w[3],w[4], w[5])
		WAVE angles2k_Result
		Variable d_a2_lo = ( (angles2k_Result[0] - ang_x)^2 + (angles2k_Result[1] - ang_y)^2 )

		w[idx1] = a1
		w[idx2] = a2 + da2
		fsmap_flip_ang2k(w[0],w[1],w[2],w[3],w[4], w[5])
		WAVE angles2k_Result
		Variable d_a2_hi = ( (angles2k_Result[0] - ang_x)^2 + (angles2k_Result[1] - ang_y)^2 )

		if (d > d_a1_lo) // go to a1_lo
			w[idx1] = a1 - da1/2
		elseif (d > d_a1_hi) // go to a1_hi
			w[idx1] = a1 + da1/2
		elseif (d < d_a1_lo && d < d_a1_hi) // go to in between
			da1 /= 2
			if (d_a1_lo < d_a1_hi)
				w[idx1] = a1 - da1/2
			else
				w[idx1] = a1 + da1/2
			endif
		endif

		if (d > d_a2_lo) // go to a2_lo
			w[idx2] = a2 - da2/2
		elseif (d > d_a2_hi) // go to a2_hi
			w[idx2] = a2 + da2/2
		elseif (d < d_a2_lo && d < d_a2_hi) // go to in between
			da2 /= 2
			if (d_a2_lo < d_a2_hi)
				w[idx2] = a2 - da2/2
			else
				w[idx2] = a2 + da2/2
			endif
		endif
		numIter += 1
	while(d > tol && numIter < maxIter)

	w[idx1] = a1
	w[idx2] = a2

	SetDataFolder $DF

	if (numIter >= maxIter) 
		return -1
	endif
	return numIter
End


//Function fsmap_mapBackFlipOptFn(w_parm, w_x)
//	WAVE w_parm
//	WAVE w_x
//	// w_parm[0,1]:
//	// the two angles to optimize
//	Variable optAng1Idx = w_parm[0], optAng2Idx = w_parm[1]
//	// w_parm[2,7]:
//	// the (static) angles: a set of angles, the series t, a, p, o, b, g,
//	Make/o/n=6 w_tmp
//	w_tmp = w_parm[p+2]
//	w_tmp[optAng1Idx] = w_x[0]
//	w_tmp[optAng2Idx] = w_x[1]
//	fsmap_flip_ang2k(w_tmp[0], w_tmp[1], w_tmp[2], w_tmp[3], w_tmp[4], w_tmp[5])
//	WAVE angles2k_Result
//	// w_parm[6,7]:
//	// the two target k's to optimize towards
//	Variable d_sqr = (angles2k_Result[0] - w_parm[6])^2 + (angles2k_Result[1] - w_parm[7])^2
////	printf "Current kx, ky: %e, %e, d_sqr %e\r", w_x[0], w_x[1], d_sqr
//	return d_sqr
//End


// the angx,angy... are the electron emission angles projected
// onto x and y directions. Basically, they are the k vectors that
// fsmap_flip_ang2k spits out (i.e. not multiplied by kvac).
//
// w_startparms needs to have the structure described above:
// the first five positions of w carry the five angles in the order
// t, a, p, o, b, g
// The two idx* are the position of the angles to be optimized, i.e.
// idx1 = 1 means the first angle to optimize is p.
Static Function reverseFlipMapPrecise(ang_x0,ang_xn,ang_y0,ang_yn,num_k,w_startparms, idx1, idx2)
	Variable ang_x0,ang_xn
	Variable ang_y0,ang_yn
	Variable num_k
	WAVE w_startparms
	Variable idx1, idx2

	Variable dang_x = (ang_xn - ang_x0) / (num_k - 1)
	Variable dang_y = (ang_yn - ang_y0) / (num_k - 1)

	Make/O/N=(num_k,num_k) w_ang1Result = NaN
	SetScale/P x, ang_x0, dang_x, w_ang1Result
	SetScale/P y, ang_y0, dang_y, w_ang1Result
	Make/O/N=(num_k,num_k) w_ang2Result = NaN
	SetScale/P x, ang_x0, dang_x, w_ang2Result
	SetScale/P y, ang_y0, dang_y, w_ang2Result

	Variable avgIter = 0
	Variable avgNaN = 0

	Variable i, j
	Variable userAbort = 0
//	Make/O/N=8 w_optparms_tmp
//	w_optparms_tmp[0] = idx1
//	w_optparms_tmp[1] = idx2
//	w_optparms_tmp[2,7] = w_startparms[p-2]
//	w_optparms_tmp[8] = ang_x0
//	w_optparms_tmp[9] = ang_y0
//	Make/O/N=2 w_optstart_tmp
//	w_optstart_tmp[0] = w_startparms[idx1]
//	w_optstart_tmp[1] = w_startparms[idx2]
//	Optimize/Q/X=w_optstart_tmp/Y=1e-6/R={90,90}/M={2,1}, fsmap_mapBackFlipOptFn, w_optparms_tmp
//	if (V_Flag != 0)
//		Abort "Was not able to initiate first point on Backmapping grid. This is bad."
//	EndIf
//	w_startparms[idx1] = w_optstart_tmp[0]
//	w_startparms[idx2] = w_optstart_tmp[1]
	findFlipAnglePrecise(w_startparms, idx1, idx2, ang_x0, ang_y0, (dang_x^2+dang_y^2), 10000)
	for (i = 0; i < DimSize(w_ang1Result, 0) && userAbort == 0; i += 1)
		Variable j_min, j_max, d_j
		// Since the starting value for the two angles to be optimized is stored in w_startparms,
		// it saves time and runs more stable if we sweep the BZ in a zig-zag rather than from 
		// left to right
		if (mod(i,2) == 0)
			j_min = 0
			j_max = DimSize(w_ang1Result, 1)
			d_j = 1
		else
			j_min = DimSize(w_ang1Result, 1) - 1
			j_max = -1
			d_j = -1
		endif
		for (j = j_min; j != j_max && userAbort == 0; j += d_j)
			Variable ang_x = ang_x0 + i * dang_x
			Variable ang_y = ang_y0 + j * dang_y
			// A tolerance of 1/10 the raster distance should do it
			Variable a1 = w_startparms[idx1]
			Variable a2 = w_startparms[idx2]
			// Spent a day trying to use Igor's Optimize function. Would not run stable.
			//  Optimize/S=.5/M={0,1}/Q/XSA=w_minmax/R={5,5}/Y=((dang_x^2+dang_y^2))/A=0/X={0,0} fsmap_mapBackFlip, w_startparms
//			w_optstart_tmp[0] = w_startparms[idx1]
//			w_optstart_tmp[0] = w_startparms[idx2]
//			Optimize/Q/X=w_optstart_tmp/Y=1e-6/R={180,180}/M={2,1}/S=.05, fsmap_mapBackFlipOptFn, w_optparms_tmp
//			w_startparms[idx1] = w_optstart_tmp[0]
//			w_startparms[idx2] = w_optstart_tmp[1]
			Variable tmp = findFlipAnglePrecise(w_startparms, idx1, idx2, ang_x, ang_y,  (dang_x^2+dang_y^2)/100, 100)
			if (tmp == -1)
//			if (V_flag != 0)
				w_startparms[idx1] = a1;
				w_startparms[idx2] = a2;
				avgNaN+=1
				continue
			endif
			avgIter += tmp
//			avgIter += V_OptNumIters
			w_ang1Result[i][j] = w_startparms[idx1]
			w_ang2Result[i][j] = w_startparms[idx2]
			if (mod(j + DimSize(w_ang1Result, 1)*i,100) == 0)
				Variable progressDone = j + DimSize(w_ang1Result, 1)*i
				Variable progressTotal = DimSize(w_ang1Result, 0) * DimSize(w_ang1Result, 1)
				Variable progressAvgIter = avgIter / progressDone
				String progressMsg
				sprintf progressMsg, "ReverseFlipMapPrecise: Avg iter: %.2f, NaN's: %d", progressAvgIter, avgNaN
				if (utils_progressDlg(message=progressMsg, level=2,numDone=progressDone,numTotal=progressTotal))
					userAbort = 1
				endif
			endif
		endfor
	endfor
	KillWaves angles2k_Result
	return avgNaN
End



Function fsmap_mapBackFlipOptFn(w_parm, x0, y0)
	WAVE w_parm
	Variable x0, y0
	// w_parm[0,1]:
	// the two angles to optimize
	Variable optAng1Idx = w_parm[0], optAng2Idx = w_parm[1]
	// w_parm[2,7]:
	// the (static) angles: a set of angles, the series t, a, p, o, b, g,
	Make/o/n=6 w_tmp
	w_tmp = w_parm[p+2]
	w_tmp[optAng1Idx] = x0
	w_tmp[optAng2Idx] = y0
	fsmap_flip_ang2k(w_tmp[0], w_tmp[1], w_tmp[2], w_tmp[3], w_tmp[4], w_tmp[5])
	WAVE angles2k_Result
	// w_parm[6,7]:
	// the two target k's to optimize towards
	Variable d_sqr = (angles2k_Result[0] - w_parm[6])^2 + (angles2k_Result[1] - w_parm[7])^2
//	printf "Current kx, ky: %e, %e, d_sqr %e\r", x0, y0, d_sqr
	return d_sqr
End


Function reverseFlipMapPrecise2(ang_x0, ang_dx,ang_xn, ang_y0, ang_dy,ang_yn, w_startparms, idx1, idx2)
	Variable ang_x0,ang_dx,ang_xn
	Variable ang_y0,ang_dy,ang_yn
	WAVE w_startparms
	Variable idx1, idx2

	Variable ang_numx = ceil(abs((ang_xn - ang_x0) / ang_dx))
	Variable ang_numy = ceil(abs((ang_yn - ang_y0) / ang_dy))

	Make/O/N=(ang_numx,ang_numy) w_ang1Result = NaN, w_ang2Result = NaN
	SetScale/P x, ang_x0, ang_dx, w_ang1Result, w_ang2Result
	SetScale/P y, ang_y0, ang_dy, w_ang1Result, w_ang2Result
	
	Variable avgIter = 0
	Variable avgNaN = 0

	Variable i, j
	Variable userAbort = 0
	
//	WAVE w_stripemap_mask
	Make/O/N=10 w_optparms_tmp
	w_optparms_tmp[0] = idx1
	w_optparms_tmp[1] = idx2
	w_optparms_tmp[2,7] = w_startparms[p-2]
	w_optparms_tmp[8] = ang_x0
	w_optparms_tmp[9] = ang_y0
	utils_NewtonOpt(fsmap_mapBackFlipOptFn, w_optparms_tmp, 0, 0, 1e-10, 1e-2, maxSteps=100, g=0.5)
	NVAR V_minloc_X, V_minloc_Y, V_OptNumIters
	w_startparms[idx1] = V_minloc_X
	w_startparms[idx2] = V_minloc_Y
//	findFlipAnglePrecise(w_startparms, idx1, idx2, ang_x0, ang_y0, (dang_x^2+dang_y^2), 10000)
	for (i = 0; i < DimSize(w_ang1Result, 0) && userAbort == 0; i += 1)
		Variable j_min, j_max, d_j
		// Since the starting value for the two angles to be optimized is stored in w_startparms,
		// it saves time and runs more stable if we sweep the BZ in a zig-zag rather than from 
		// left to right
		if (mod(i,2) == 0)
			j_min = 0
			j_max = DimSize(w_ang1Result, 1)
			d_j = 1
		else
			j_min = DimSize(w_ang1Result, 1) - 1
			j_max = -1
			d_j = -1
		endif
		for (j = j_min; j != j_max && userAbort == 0; j += d_j)
			Variable ang_x = ang_x0 + i * ang_dx
			Variable ang_y = ang_y0 + j * ang_dy
//			Variable a1 = w_startparms[idx1]
//			Variable a2 = w_startparms[idx2]
			// Spent a day trying to use Igor's Optimize function. Would not run stable.
			//  Optimize/S=.5/M={0,1}/Q/XSA=w_minmax/R={5,5}/Y=((dang_x^2+dang_y^2))/A=0/X={0,0} fsmap_mapBackFlip, w_startparms
//			w_optstart_tmp[0] = w_startparms[idx1]
//			w_optstart_tmp[0] = w_startparms[idx2]
//			Optimize/Q/X=w_optstart_tmp/Y=1e-6/R={180,180}/M={2,1}/S=.05, fsmap_mapBackFlipOptFn, w_optparms_tmp
//			w_startparms[idx1] = w_optstart_tmp[0]
//			w_startparms[idx2] = w_optstart_tmp[1]
//			Variable tmp = findFlipAnglePrecise(w_startparms, idx1, idx2, ang_x, ang_y,  (dang_x^2+dang_y^2)/100, 100)
//			if (w_stripemap_mask[i][j] != 1)
//				continue
//			endif
			w_optparms_tmp[8] = ang_x
			w_optparms_tmp[9] = ang_y
			if (numtype(w_startparms[idx1]) == 0 && numtype(w_startparms[idx2]) == 0)
				w_optparms_tmp[idx1+2] = w_startparms[idx1]
				w_optparms_tmp[idx2+2] = w_startparms[idx2]
			else
				w_optparms_tmp[idx1+2] = 0
				w_optparms_tmp[idx2+2] = 0
			endif
			utils_NewtonOpt(fsmap_mapBackFlipOptFn, w_optparms_tmp, w_optparms_tmp[0], w_optparms_tmp[1], 1e-10, 1e-2, maxSteps=100)
			NVAR V_minloc_X, V_minloc_Y, V_OptNumIters
			if (numtype(V_minloc_X) != 0)
//				w_startparms[idx1] = a1;
//				w_startparms[idx2] = a2;
				avgNaN+=1
				continue
			endif
			w_startparms[idx1] = V_minloc_X
			w_startparms[idx2] = V_minloc_Y
			avgIter += V_OptNumIters
			w_ang1Result[i][j] = w_startparms[idx1]
			w_ang2Result[i][j] = w_startparms[idx2]
			if (mod(j + DimSize(w_ang1Result, 1)*i,100) == 0)
				Variable progressDone = j + DimSize(w_ang1Result, 1)*i
				Variable progressTotal = DimSize(w_ang1Result, 0) * DimSize(w_ang1Result, 1)
				Variable progressAvgIter = avgIter / progressDone
				String progressMsg
				sprintf progressMsg, "ReverseFlipMapPrecise: Avg iter: %.2f, NaN's: %d", progressAvgIter, avgNaN
				if (utils_progressDlg(message=progressMsg, level=2,numDone=progressDone,numTotal=progressTotal))
					userAbort = 1
				endif
			endif
		endfor
	endfor
	KillWaves angles2k_Result
	return avgNaN

End

// Need to do some rudimentary checks: in this mode of operation,
// the whole wave stripe has to be equal in all but one angle, otherwise it does
// not work (because the other angle is the detector slit and mapping the kxky
// back onto angles only works if I have two angles too.)
// Returns a number, signifying the running angle; the numbers correspond to angles 
// in the order  t(0) p(1) a(2) b(3) g(4)
Static Function checkStripePrecise(wlist)
	String wlist
	if (ItemsInList(wlist) < 2)
		utils_Abort("There have to be bunches of waves of at least 2. Something is wrong with your angles.")
	endif

	String wname = StringFromList(0,wlist)
	WAVE w = $wname
	String notestr = note($wname)
	String old_manipulator = StringByKey("ManipulatorType", notestr, "=", "\r")
	String old_eScale = StringByKey("EnergyScale", notestr, "=", "\r")
	String old_angleMapping = StringByKey("AngleMapping", notestr, "=", "\r")
		
	String angles = getAngles(wname)
	Variable old_th = NumberByKey("theta", angles)
	Variable old_al = NumberByKey("alpha", angles)
	Variable old_ph = NumberByKey("phi", angles)
	Variable old_om = NumberByKey("omega", angles)
	Variable old_gamma = NumberByKey("gamma", angles)
	Variable old_EF = getNumber("FermiLevel",wname,1)
	Variable old_hn = getNumber("PhotonEnergy",wname,1)
	Variable old_workfunc = getNumber("WorkFunction",wname,1)
//		Variable crystal_a = getNumber("CrystalAxisA",wname,1)
//		Variable crystal_b = getNumber("CrystalAxisB",wname,1)
//TODO: include above into kx,ky calculation

	Variable old_numBetas = DimSize(w,0)
	Variable old_startBeta = DimOffset(w,0)
	Variable old_deltaBeta = DimDelta(w,0)

	Variable old_numEs = DimSize(w,1)
	Variable old_startE = DimOffset(w,1)
	Variable old_deltaE = DimDelta(w,1)

	String/G S_runningAngle = ""
	Variable/G V_deltaRunningAngle = inf
	Variable/G V_startTh = old_th
	Variable/G V_startAl = old_al
	Variable/G V_startPh = old_ph
	Variable/G V_startOm = old_om
	Variable/G V_startGamma = old_gamma
	
	Variable i
	for (i = 1; i < ItemsInList(wlist); i += 1)
		wname = StringFromList(i,wlist)
		WAVE w = $wname
		notestr = note($wname)
		String manipulator = StringByKey("ManipulatorType", notestr, "=", "\r")
		String angleMapping = StringByKey("AngleMapping", notestr, "=", "\r")
		
		angles = getAngles(wname)
		Variable th = NumberByKey("theta", angles)
		Variable al = NumberByKey("alpha", angles)
		Variable ph = NumberByKey("phi", angles)
		Variable om = NumberByKey("omega", angles)
		Variable gamma = NumberByKey("gamma", angles)

		String eScale = StringByKey("EnergyScale", notestr, "=", "\r")
		Variable EF = getNumber("FermiLevel",wname,1)
		Variable hn = getNumber("PhotonEnergy",wname,1)
		Variable workfunc = getNumber("WorkFunction",wname,1)
//		Variable crystal_a = getNumber("CrystalAxisA",wname,1)
//		Variable crystal_b = getNumber("CrystalAxisB",wname,1)
//TODO: include above into kx,ky calculation

		if (stringmatch(manipulator,"flip") != 1)
			utils_Abort("Sorry, only flip manipulators are supported right now. (I think)")
		endif

		Variable paramsDiffer = stringmatch(manipulator, old_manipulator) != 1
		paramsDiffer = paramsDiffer || stringmatch(eScale, old_eScale) != 1
		paramsDiffer = paramsDiffer || stringmatch(angleMapping, old_angleMapping) != 1
		paramsDiffer = paramsDiffer || EF != old_EF
		paramsDiffer = paramsDiffer || hn != old_hn
		paramsDiffer = paramsDiffer || workfunc != old_workfunc
		paramsDiffer = paramsDiffer || old_numBetas != DimSize(w,0)
		paramsDiffer = paramsDiffer || old_startBeta != DimOffset(w,0)
		paramsDiffer = paramsDiffer || old_deltaBeta != DimDelta(w,0)
		paramsDiffer = paramsDiffer || old_numEs != DimSize(w,1)
		paramsDiffer = paramsDiffer || old_startE != DimOffset(w,1)
		paramsDiffer = paramsDiffer || old_deltaE != DimDelta(w,1)
		if (paramsDiffer)
			String msg = "Waves have to have the same parameters. These need to be the same:\r"
			msg += "manipulator, eScale, angleMapping, EF, hn, workfunc.\r"
			msg += "Furthermore, the energy and angle scale of each wave has to be the same.\r"
			msg += "Either correct the error in the FileTable dialog, or try the much more accurate,\r"
			msg += "much more flexible, and much slower Voronoi method for FS map generation."
			utils_Abort(msg)
		endif
		
		V_startTh = min(th, V_startTh)
		V_startAl = min(al, V_startAl)
		V_startPh = min(ph, V_startPh)
		V_startOm = min(om, V_startOm)
		V_startGamma = min(gamma,V_startGamma)

		if (gamma != old_gamma)
			if (strlen(S_runningAngle) != 0 && stringmatch(S_runningAngle, "gamma") != 1)
				utils_Abort("gamma doesn't match, although there already is an angle running: " + S_runningAngle)
			endif
			S_runningAngle = "gamma"
			V_deltaRunningAngle = min(V_deltaRunningAngle, abs(gamma - old_gamma))
		endif

		if (th != old_th)
			if (strlen(S_runningAngle) != 0 && stringmatch(S_runningAngle, "theta") != 1)
				utils_Abort("th doesn't match, although there already is an angle running: " + S_runningAngle)
			endif
			S_runningAngle = "theta"
			V_deltaRunningAngle = min(V_deltaRunningAngle, abs(th - old_th))
		endif

		if (al != old_al)
			if (strlen(S_runningAngle) != 0 && stringmatch(S_runningAngle, "alpha") != 1)
				utils_Abort("al doesn't match, although there already is an angle running: " + S_runningAngle)
			endif
			S_runningAngle = "alpha"
			V_deltaRunningAngle = min(V_deltaRunningAngle, abs(th - old_th))
		endif

		if (ph != old_ph)
			if (strlen(S_runningAngle) != 0 && stringmatch(S_runningAngle, "phi") != 1)
				utils_Abort("ph doesn't match, although there already is an angle running: " + S_runningAngle)
			endif
			S_runningAngle = "phi"
			V_deltaRunningAngle = min(V_deltaRunningAngle, abs(ph - old_ph))
		endif

		if (om != old_om)
			if (strlen(S_runningAngle) != 0 && stringmatch(S_runningAngle, "omega") != 1)
				utils_Abort("omega doesn't match, although there already is an angle running: " + S_runningAngle)
			endif
			S_runningAngle = "omega"
			V_deltaRunningAngle = min(V_deltaRunningAngle, abs(om - old_om))
		endif
	endfor
End




// creates a map of a stripe constructed by getWaveStripe().
// wlist is the list of waves belonging to one stripe.
//
// This method works very similar to Felix Baumberger's method, except for the following 
// differences:
// -	I do the merging of stripes, or continuous pieces of the FS, AFTER transformation
// 	into k-space, since all the stuff is bent weirdly when you are finished, and there is 
// 	no way of knowing how two sets of continuous cuts with different sets of angles transform
// 	into k-space in advance, which makes merging before the angle-to-k transformation 
// 	impossible. This is the reason why there is a w_stripemap_dkx, and w_stripemap_dky, which
// 	saves the direction of the cut in k-space for each point in w_stripemap, in order to facilitate
// 	the merging that follows.
// -	The backmapping from a particular (kx,ky) to a pair of angles is done numerically, without
//	any assumptions.
//
// Will store its result in w_stripemap. 
// w_stripemap_dky, w_stripemap_dkx are used to determine in which direction the 
// cut runs in k-space in order to merge with the other stripes.
//
// Returns a string with all non-fatal errors encountered. If no errors happened, String will be empty.
Static Function/S mapStripePrecise(wlist)
	String wlist
	
	String DF = GetDataFolder(1)
	SetDataFolder root:internalUse:FSMap
	
	String return_error = ""
	
	////////
	// This is how it works:
	////////
	// 1. 	checkStripePrecise(wlist) checks the waves returned by getWaveStripe()
	//		to see if they are the same in energy and angles except for one running angle.
	//		This is a bit restrictive and can be probably a bit more general, but involves more
	//		code here (i.e. interpolation etc.).
	//		NOTE: the running angle i.e. the distance in this angle between two neighboring
	//		cuts has to be constant throughout the stripe for now. This can and will be fixed 
	//		soon (just involves some interpolation on my side).
	// 2a.	Next, we create a 3D cube with intensity as a function of the Energy and a pair
	//		of angles (usually beta, the Analyzer slit angle, and phi, the running angle) 
	// 2b.	fill it and determine the cut direction in k-space, (dkx, dky).
	// 3.		Integrate 3D cube over the given energy window.
	// 4a.	Do numerical backmapping. This is done on a grid of the relevant pair of angles 
	//		of the dimensions gv_backmapTolPrecise*gv_backmapTolPrecise. 
	// 4b.	This grid then gets interpolated on the dimensions of w_fsmap. This is much faster
	//		than doing the Backmap for each single point of w_fsmap.
	
	
	///////// (1.) do the tests (see above) and see if it fails.
	utils_progressDlg(message="mapStripePrecise: Checking consistency", level=1)
	checkStripePrecise(wlist)
	SVAR S_runningAngle
	NVAR V_deltaRunningAngle
	NVAR V_startPh, V_startTh, V_startOm, V_startGamma
	
	NVAR gv_theta_offset
	NVAR gv_phi_offset
	NVAR gv_omega_offset
	
	NVAR gv_centerE
	NVAR gv_dE
	Variable minE = gv_centerE - gv_dE / 2000
	Variable maxE = gv_centerE + gv_dE / 2000

	String wname = StringFromList(0,wlist)
	WAVE w0 = $wname
	String notestr = note($wname)

	Variable energy = getFermiEnergy(wname) + gv_centerE
	Variable kvac = sqrt(energy) * 0.5123

	///////// (2a.) This is a 3D cube that contains intensity versus angle1, angle2, Energy.
	// Since those cubes cannot have irregular spacing, we are pretty restricted here.
	// TODO: maybe do some interpolation. Should not be too hard. If this is done, also
	// remove the DoAlert warning that the angle spacing has to be the same ,and relax
	// the consistency checks in checkStripePrecise s.t. there can be differences in
	// TWO running angles (e.g. beta, theta or theta, phi)
	Make/O/N=(ItemsInList(wlist), DimSize(w0,0), DimSize(w0,1)) w_int_anglesEnergy
	Make/O/N=(ItemsInList(wlist), DimSize(w0,0)) w_dkx_angles
	Make/O/N=(ItemsInList(wlist), DimSize(w0,0)) w_dky_angles
	SetScale/P y, DimOffset(w0, 0), DimDelta(w0, 0), w_int_anglesEnergy, w_dkx_angles, w_dky_angles
	SetScale/P z, DimOffset(w0, 1), DimDelta(w0, 1), w_int_anglesEnergy
	
	//////// (2b.) 
	Variable i
	Variable kx, ky, old_kx, old_ky

	// BEGIN interpolation code:
	// Need to fill w_angles with the running angle, in the order of wlist
	Make/O/N=(ItemsInList(wlist)) w_angles
	for (i = 0; i < ItemsInList(wlist); i += 1)
		wname = StringFromList(i,wlist)
		WAVE w = $wname
		String angles = getAngles(wname)
		w_angles[i] = NumberByKey(S_runningAngle, angles)
	EndFor
	// Now, we need to sort w_angles (and wlist) ascending, since Igor's
	// interpolation functions need to have the x-waves in ascending order
	utils_StringList2Wave(wlist)
	WAVE/T W_StringList
	Sort w_angles, w_angles, W_StringList
	wlist = utils_Wave2StringList(W_StringList)
	KillWaves W_StringList
	// END interpolation code

	// Generate the norm waves here
	NVAR gv_norm_manual
	Variable dlgResult
	if (gv_norm_manual)
		generateNormWave(wlist)
		dlgResult = generateNormWaveManual(wlist)
		if (dlgResult == 0)
			utils_abort("Aborted by user.")
		endif
	else
		generateNormWave(wlist)
	endif

	// Filling the grid of angles to use for reverse mapping
	for (i = 0; i < ItemsInList(wlist); i += 1)
		wname = StringFromList(i,wlist)
		WAVE w = $wname
		
		if (utils_progressDlg(message="mapStripePrecise: Filling I(angle1,angle2,energy)", level=1, numDone=i, numTotal=ItemsInList(wlist)))
			break
		endif
		notestr = note($wname)
		angles = getAngles(wname)
		Variable th = NumberByKey("theta", angles)
		Variable al = NumberByKey("alpha", angles)
		Variable ph = NumberByKey("phi", angles)
		Variable om = NumberByKey("omega", angles)
		Variable gamma = NumberByKey("gamma", angles)

		WAVE w_normWave
		w_int_anglesEnergy[i][][] = w[q][r] * w_normWave[i]

		Variable beta = DimOffset(w0, 0)
		Variable j
		For (j = 0; j < DimSize(w0, 0); j += 1)
			// deternime the dkx,dky, i.e. the direction in which the cut runs in k-space
			fsmap_flip_ang2k(th, al, ph, om, beta, gamma)
			WAVE angles2k_Result
			kx = angles2k_Result[0]
			ky = angles2k_Result[1]
			if (j > 0)
				Variable len = sqrt((kx - old_kx)^2 + (ky - old_ky)^2)
				w_dkx_angles[i][j-1] = (kx - old_kx) / len
				w_dky_angles[i][j-1] = (ky - old_ky) / len
				if(j == DimSize(w0, 0) - 1)
					w_dkx_angles[i][j] = (kx - old_kx) / len
					w_dky_angles[i][j] = (ky - old_ky) / len
				endif
			endif
			old_kx = kx
			old_ky = ky
			
			beta += DimDelta(w0, 0)
		endfor
	endfor
	
	KillWaves angles2k_Result
	
	/////// (3.)
	Integrate/DIM=2 w_int_anglesEnergy /D=w_int_anglesINTEnergy
	Make/O/N=(ItemsInList(wlist),DimSize(w,0)) w_int_angles
	w_int_angles[][] = w_int_anglesINTEnergy[p][q](maxE) - w_int_anglesINTEnergy[p][q](minE)
	
	// BEGIN interpolation code
	// I put those interpolation sections in for two reasons. First,
	// the user is now able to have different spacing in his FS map which he was not
	// able before. Second, the different spacing between coarse and fine angle (i.e.
	// the point spacing within one cut is much much smaller than from cut to cut)
	// leads to artefacts. These artefacts are bubbles or intensity modulations in the FS.
	NVAR gv_numInterpAngPrecise
	NVAR gv_autoInterpAngPrecise
	Variable num_interp_ang
	if (gv_autoInterpAngPrecise == 1)
		num_interp_ang = (w_angles[numpnts(w_angles)-1]-w_angles[0])/DimDelta(w0,0)
	else
		num_interp_ang = gv_numInterpAngPrecise
	endif

	Make/O/N=(num_interp_ang, DimSize(w_int_anglesEnergy,1)) w_int_angInterp
//	Make/O/N=(ItemsInList(wlist), DimSize(w0,0)) w_dkx_angInterp
//	Make/O/N=(ItemsInList(wlist), DimSize(w0,0)) w_dky_angInterp
	Make/O/N=(num_interp_ang, DimSize(w0,0)) w_dkx_angInterp
	Make/O/N=(num_interp_ang, DimSize(w0,0)) w_dky_angInterp
	SetScale/I x, w_angles[0], w_angles[numpnts(w_angles)-1], w_int_angInterp, w_dkx_angInterp, w_dky_angInterp
	SetScale/P y, DimOffset(w0, 0), DimDelta(w0, 0), w_int_angInterp, w_dkx_angInterp, w_dky_angInterp
	Make/O/N=(num_interp_ang) w_dst
	SetScale/I x, w_angles[0], w_angles[numpnts(w_angles)-1], w_dst
	Make/O/N=(ItemsInList(wlist)) w_src
	NVAR gv_preAvgInterpPrecise
	For (i = 0; i < DimSize(w0,0); i += 1)
		w_src[] = w_int_angles[p][i]
		if (gv_preAvgInterpPrecise > 0)
			Interpolate2/T=3/F=(gv_preAvgInterpPrecise)/I=3/Y=w_dst w_angles, w_src
		else
			Interpolate2/I=3/Y=w_dst w_angles, w_src
		endif
		w_int_angInterp[][i] = w_dst[p]
		w_src[] = w_dkx_angles[p][i]
		Interpolate2/I=3/Y=w_dst w_angles, w_src
		w_dkx_angInterp[][i] = w_dst[p]
		w_src[] = w_dky_angles[p][i]
		Interpolate2/I=3/Y=w_dst w_angles, w_src
		w_dky_angInterp[][i] = w_dst[p]
	EndFor
	KillWaves w_dst, w_src
	// END experimental interpolation code
	
	//////// (4a.)
	// Start parameters for the numerical Backmapping. The angles are in that order: t, a, p, o, b, g
	Make/O/N=6 w_startparms = {th, al, ph, om, 0, gamma}
	Variable idx1, idx2 = 4 // idx2 is usually beta, the angle on the Analyzer along the slit...
	idx1 = WhichListItem(S_runningAngle, "theta;alpha;phi;omega;;gamma")
	NVAR gv_kx_min, gv_kx_max
	NVAR gv_ky_min, gv_ky_max
	NVAR gv_kx_stepsize, gv_ky_stepsize
	NVAR gv_backmapTolPrecise
//	Variable dkx = (gv_kx_max - gv_kx_min) / gv_backmapTolPrecise / kvac
//	Variable dky = (gv_ky_max - gv_ky_min) / gv_backmapTolPrecise / kvac
	PauseUpdate
	if (utils_progressDlg(message="mapStripePrecise: reverse angle mapping", level=1))
		KillWaves/Z w_ang1Result, w_ang2Result, w_int_angles, w_int_anglesEnergy, w_int_anglesINTEnergy, w_startparms, w_dkx_angles, w_dky_angles, M_InterpolatedImage
		return "Aborted by user"
	endif

	Variable numNaNs = reverseFlipMapPrecise2(gv_kx_min/kvac,gv_kx_stepsize/kvac,gv_kx_max/kvac,gv_ky_min/kvac,gv_ky_stepsize/kvac,gv_ky_max/kvac, w_startparms, idx1, idx2)
//	Variable numNaNs = reverseFlipMapPrecise(gv_kx_min/kvac,gv_kx_max/kvac,gv_ky_min/kvac,gv_ky_max/kvac,gv_backmapTolPrecise, w_startparms, idx1, idx2)
	if (numNaNs != 0)
		sprintf return_error, "%s%d out of %d points are NaNs. The FS map may be broken.;", return_error, numNaNs, gv_backmapTolPrecise^2
	endif
	ResumeUpdate
	WAVE w_ang1Result
	WAVE w_ang2Result
	
	///////// (4b.)
//	utils_progressDlg(message="mapStripePrecise: interpolating", level=1)
//	ImageInterpolate/S={gv_kx_min/kvac,gv_kx_stepsize/kvac,gv_kx_max/kvac,gv_ky_min/kvac,gv_ky_stepsize/kvac,gv_ky_max/kvac} Spline w_ang1Result
//	WAVE M_InterpolatedImage
//	Duplicate/O M_InterpolatedImage, w_ang1Result
//	ImageInterpolate/S={gv_kx_min/kvac,gv_kx_stepsize/kvac,gv_kx_max/kvac,gv_ky_min/kvac,gv_ky_stepsize/kvac,gv_ky_max/kvac} Spline w_ang2Result
//	WAVE M_InterpolatedImage
//	Duplicate/O M_InterpolatedImage, w_ang2Result
//	SetScale/P x, gv_kx_min/kvac, gv_kx_stepsize/kvac, "kx", w_ang1Result, w_ang2Result
//	SetScale/P y, gv_ky_min/kvac, gv_ky_stepsize/kvac, "ky", w_ang1Result, w_ang2Result
	
	Make/O/N=(DimSize(w_ang1Result,0),DimSize(w_ang1Result,1)) w_stripemap = NaN
	SetScale/P x, gv_kx_min, gv_kx_stepsize, "kx", w_stripemap
	SetScale/P y, gv_ky_min, gv_ky_stepsize, "ky", w_stripemap
	Duplicate/O w_stripemap, w_stripemap_dkx, w_stripemap_dky
	w_stripemap = Interp2D(w_int_angInterp, w_ang1Result, w_ang2Result)
	w_stripemap_dkx = Interp2D(w_dkx_angInterp, w_ang1Result, w_ang2Result)
	w_stripemap_dky = Interp2D(w_dky_angInterp, w_ang1Result, w_ang2Result)
	
	KillWaves w_ang1Result, w_ang2Result, w_int_angles, w_int_anglesEnergy, w_int_anglesINTEnergy, w_startparms
	KillWaves w_dkx_angles, w_dky_angles, M_InterpolatedImage, w_int_angInterp, w_dkx_angInterp, w_dky_angInterp

	SetDataFolder $DF
	return return_error
End


////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
/////////   Felix Baumberger's Method
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////


//////
//
// This is the original mapper from Felix Baumberger. I kept it basically unmodified, except for
// the following:
//
// stuff which I had to delete/change in order to increase interoperability/usability:
// - 	all the global variable names which are specific only to this method have been
//	suffixed with Baumberger.
// -	all global variable names of variables which are non-specific to this method (like
//	the FS map which (hopefully) gets created by all methods) have been renamed to
//	fit my new naming scheme.
// -	The original code modified the source waves in a very untransparent manner, i.e.
//	the ScientaOrientation flag or the ManipulatorType flag got changed/added - sometimes
//	even silently - without the user being able to easily change any mistakes lateron.
//	The behavior now has been changed such that it will abort whenever some flags/info
//	is missing in the wave. Changing of this information is not the task of the FS mapper.
//	That's what the FileTable is for.
//	
// stuff which probably never will be implemented since I do not see any use for it:
// -	The intensity normalization has been taken out. Afaik, nobody in our group is using it right now.
//	If something needs to be normalized, this can be done with the normalize GUI, which newly
//	features a macro tab which records changes made to a single wave which can then
//	be applied to selected waves in succession.
// -	Same goes for cropping. Although, this function might reappear since it might be practical
//	for a quick FS map on raw data.
//
//////



//	structure of the mapper:

//	1) generate a 2D waveform with the intensities as a function of fine (// entrance slit) and coarse 
//	angle directions for a fixed energy.
//	2) calculate fine and coarse angle matrices corrsponding to the final 2D k// waveform. These matrics depend
//	on the experimental geometry (manipulator type, slit orientation)
//	3) interpolate the constant energy matrix to the k// waveform using interp2D in conjunction with the 
//	angle matrices.
//
//		details of step 1):
//		1.1) normalize each scienta carpet if required
//		1.2) interpolate all carpets on a common fine-angle/energy grid and merge overlapping carpets
//		1.3) write merged carpets in a cube ('cfe_rawCube') with p=coarse angle, q=fine angle, r=energy, 
//		and generate the coarse axis-wave ('cfe_rawCube_c_axis')
//		1.4) integrate the cube over an energy range to obtain the 'cf_rawMatrix'
//		1.5) interpolate all merged carpets to a common finer 'coarse-angle' grid. This is done line by line, i.e. for 
//		each fine-angle point. Result is the 'cf_waveform'
	
//	NOTE: 	the coordinate transformation is simplified by adding the parallel detection angle to one of the manipulator angles.
//			this is exact for the Helm geometry (slit normal to theta-axis) and the SLS geometry (Fadley-type with slit normal to theta-axis)
//			but it's a (quite good) approximation for the SSRL V-4 geometry
//	Note 2: 	this panel requires an alias of the MDinterpolator in the igor extensions.
//	
//		FB 10/04/03

// significant bug-fixes:
// 	02-18-04 indexing used to write the 'cfe_raw_cube' works now correctly for multiple fine angles at one coarse angle
//	04-21-04  corrected normalization by the number of energies in the window. This bug produced a blank map, if the integration contained only one energy
// 	04-21-04 corrected the indexing for the scaling-offsets by the fine-angles. Affected multiple fine-angles only.



Static Function checkMapBaumberger(wlist)
	String wlist
	if (ItemsInList(wlist) < 2)
		utils_Abort("There have to be bunches of waves of at least 2. Something is wrong with your angles.")
	endif

	String wname = StringFromList(0,wlist)
	WAVE w = $wname
	String notestr = note($wname)
	String old_manipulator = StringByKey("ManipulatorType", notestr, "=", "\r")
	String old_eScale = StringByKey("EnergyScale", notestr, "=", "\r")
	String old_angleMapping = StringByKey("AngleMapping", notestr, "=", "\r")
		
//	String angles = getAngles(wname)
//	Variable old_al = NumberByKey("alpha", angles)
//	Variable old_th = NumberByKey("theta", angles)
//	Variable old_ph = NumberByKey("phi", angles)
//	Variable old_om = NumberByKey("omega", angles)
//	Variable old_gamma = NumberByKey("gamma", angles)

	Variable old_EF = getNumber("FermiLevel",wname,1)
	Variable old_hn = getNumber("PhotonEnergy",wname,1)
	Variable old_workfunc = getNumber("WorkFunction",wname,1)
//		Variable crystal_a = getNumber("CrystalAxisA",wname,1)
//		Variable crystal_b = getNumber("CrystalAxisB",wname,1)
//TODO: include above into kx,ky calculation

	Variable old_numBetas = DimSize(w,0)
	Variable old_startBeta = DimOffset(w,0)
	Variable old_deltaBeta = DimDelta(w,0)

	Variable old_numEs = DimSize(w,1)
	Variable old_startE = DimOffset(w,1)
	Variable old_deltaE = DimDelta(w,1)

	Variable i
	for (i = 1; i < ItemsInList(wlist); i += 1)
		wname = StringFromList(i,wlist)
		WAVE w = $wname
		notestr = note($wname)
		String manipulator = StringByKey("ManipulatorType", notestr, "=", "\r")
		String eScale = StringByKey("EnergyScale", notestr, "=", "\r")
		String angleMapping = StringByKey("AngleMapping", notestr, "=", "\r")
		if (stringmatch(angleMapping,"none") == 0 && stringmatch(angleMapping,"") == 0)
			utils_Abort("This method only works for AngleMapping=none. Please use filetable to fix this problem.")
		endif
		
		String angles = getAngles(wname)
//		Variable th = NumberByKey("theta", angles)
//		Variable al = NumberByKey("alpha", angles)
//		Variable ph = NumberByKey("phi", angles)
//		Variable om = NumberByKey("omega", angles)
		Variable gamma = NumberByKey("gamma", angles)

		Variable EF = getNumber("FermiLevel",wname,1)
		Variable hn = getNumber("PhotonEnergy",wname,1)
		Variable workfunc = getNumber("WorkFunction",wname,1)
//		Variable crystal_a = getNumber("CrystalAxisA",wname,1)
//		Variable crystal_b = getNumber("CrystalAxisB",wname,1)
//TODO: include above into kx,ky calculation

		if (gamma != 0 && gamma != 90 && gamma != 180 && gamma != 270)
			utils_Abort("This method can only handle the gamma values 0,90,180,270 degrees. Please consider using another method.")
		endif
		if (stringmatch(manipulator,"flip") == 0 && stringmatch(manipulator,"Fadley") == 0 )
			utils_Abort("This method can only use \"flip\" or \"Fadley\" type manipulators. Either set these values with filetable or use another method.")
		endif
		if (stringmatch(eScale,"kinetic") == 0 && stringmatch(eScale,"Initial*") == 0 )
			utils_Abort("This method can only use \"kinetic\" or \"Initial*\" type energy scales. Either set these values with filetable or use another method.")
		endif

		Variable paramsDiffer = stringmatch(manipulator, old_manipulator) != 1
		paramsDiffer = paramsDiffer || stringmatch(eScale, old_eScale) != 1
		paramsDiffer = paramsDiffer || stringmatch(angleMapping, old_angleMapping) != 1
		paramsDiffer = paramsDiffer || EF != old_EF
		paramsDiffer = paramsDiffer || hn != old_hn
		paramsDiffer = paramsDiffer || workfunc != old_workfunc
		paramsDiffer = paramsDiffer || old_numBetas != DimSize(w,0)
		paramsDiffer = paramsDiffer || old_startBeta != DimOffset(w,0)
		paramsDiffer = paramsDiffer || old_deltaBeta != DimDelta(w,0)
		paramsDiffer = paramsDiffer || old_numEs != DimSize(w,1)
		paramsDiffer = paramsDiffer || old_startE != DimOffset(w,1)
		paramsDiffer = paramsDiffer || old_deltaE != DimDelta(w,1)
		if (paramsDiffer)
			String msg = "Waves have to have the same parameters. These need to be the same:\r"
			msg += "manipulator, eScale, angleMapping, EF, hn, workfunc.\r"
			msg += "Furthermore, the energy and angle scale of each wave has to be the same.\r"
			msg += "Either correct the error in the FileTable dialog, or try the much more accurate,\r"
			msg += "much more flexible, and much slower Voronoi method for FS map generation."
			utils_Abort(msg)
		endif
	endfor
End




// linking the mapper procedures to the interface:
//
// 1) the 'master-mapper' first reads all the globals from the interface and calls several sub-procedures to check consistency
// and to calculate specific mapper variables from the user-set variables.
// 2) it generates the 'raw_cube' and the 'cf_waveform'
// 3) it performes the coordinate transformation on the 'cf_waveform'
//		
//																					FB 11/14/03
// Returns a string containing messages of all non-fatal errors that occurred. Empty if none occurred.
// Note that as of right now, all errors are treated as fatal (i.e. lead to an Abort)
// and the returned string will allways be empty.
Static Function/S mapBaumberger()

	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse:FSMap

	WAVE/T w_dialog_waves
//		WAVE w_disp = w_disp
	WAVE cfe_rawCubeBaumberger
	WAVE cf_waveformBaumberger
	NVAR gv_centerE
	NVAR gv_dE
	NVAR gv_theta_offset
	NVAR gv_phi_offset
	NVAR gv_omega_offset
	NVAR gv_kx_min
	NVAR gv_kx_max
	NVAR gv_ky_min
	NVAR gv_ky_max
	NVAR gv_kx_stepsize
	NVAR gv_ky_stepsize
	NVAR gv_forceGenCfeBaumberger
	
	SVAR gs_norm_method
	
	if ((! stringmatch(gs_norm_method, "Norm")) && (! stringmatch(gs_norm_method, "Total")))
		DoAlert 0, "You chose a norm method other than 'Total' or 'None'. Those might not do what you want when using Baumberger's mapping..."
	endif
		
	if (numpnts(w_dialog_waves) < 2)
		utils_Abort("You need at least two source carpets.")	// igor tends to crash with just one carpet...
	endif
		
	String dlg_waves = utils_wave2StringList(w_dialog_waves)
	
	utils_progressDlg(message="mapBaumberger: checking consistency", level=1)
	checkMapBaumberger(dlg_waves)
	
	String notestr = note($w_dialog_waves[0])
	String manipulator = StringByKey("ManipulatorType", notestr, "=", "\r")
	String angleMapping = StringByKey("AngleMapping", notestr, "=", "\r")

	String angles = getAngles(w_dialog_waves[0])
	Variable phi = NumberByKey("phi", angles)
	Variable om = NumberByKey("omega", angles)
	Variable gamma = NumberByKey("gamma", angles)
	// loc_alpha == om, loc_ph == phi


	// read the angles from the wavenote and check the values for consistency
	Make/o/n=(numpnts(w_dialog_waves)) w_thBaumberger, w_phBaumberger, w_omBaumberger
	Variable i
	for ( i = 0; i < numpnts(w_dialog_waves); i+=1 )
		angles = getAngles(w_dialog_waves[i])
		w_thBaumberger[i] = NumberByKey("theta", angles)
		w_phBaumberger[i] = NumberByKey("phi", angles)
		w_omBaumberger[i] = NumberByKey("omega", angles)
	endfor
	
	// get vacuum wave vector
	Variable kvac = sqrt(getFermiEnergy(w_dialog_waves[0]) + gv_centerE) * 0.5123
		
	// TODO: need w_cList back here
	
	// all geometry cases: calculate w_cList, w_fList and the angle matrices
	if (stringmatch(manipulator,"flip"))
		if (gamma == 90 || gamma == 270)
			WAVE w_coarseAngles = w_phBaumberger		// slit orthogonal to theta-axis
			WAVE w_fineAngles = w_thBaumberger
		elseif (gamma == 0 || gamma == 180)
			WAVE w_coarseAngles = w_thBaumberger			// slit parallel to theta-axis
			WAVE w_fineAngles = w_phBaumberger
		endif
	elseif (stringmatch(manipulator,"Fadley"))
		if (gamma == 90 || gamma == 270) // added 270 degree. Not sure if this works. FS, 29oct2007
			WAVE w_coarseAngles = w_omBaumberger
			WAVE w_fineAngles = w_thBaumberger
		else
			utils_Abort("sorry, Fadley-type manipulators are supported only if the parallel detection is along polar cuts (gamma = 90)")
		endif
	endif

	Variable nkx = abs(gv_kx_max-gv_kx_min) / gv_kx_stepsize + 1
	Variable nky = abs(gv_ky_max-gv_ky_min) / gv_ky_stepsize + 1

	String oldCubeNote = note(w_fsmap)

	Make/n=(nkx,nky)/o w_fsmap
	SetScale/I x gv_kx_min,gv_kx_max,"" w_fsmap
	SetScale/I y gv_ky_min,gv_ky_max,"" w_fsmap
	Duplicate/o w_fsmap w_fsmap_cBaumberger, w_fsmap_fBaumberger
		
	if (stringmatch(manipulator,"flip"))
		if (gamma == 90 || gamma == 270)
			w_fsmap_fBaumberger = flipCBaumberger(om,kvac,x,y)
			w_fsmap_cBaumberger = flipFBaumberger(om,kvac,x,y)
		elseif (gamma == 0 || gamma == 180)
			w_fsmap_cBaumberger = flipCBaumberger(om,kvac,x,y)
			w_fsmap_fBaumberger = flipFBaumberger(om,kvac,x,y)
		endif
	elseif (stringmatch(manipulator,"Fadley"))
		w_fsmap_cBaumberger = FadleyPolBaumberger(phi,kvac,x,y)
		w_fsmap_fBaumberger = FadleyOmBaumberger(phi,kvac,x,y)
	endif
		
	String newCubeNote = genFSMapNote()
	// throw away the intensity and energy information.
	oldCubeNote  = ReplaceStringByKey("CenterEnergy", oldCubeNote, "", "=", "\r")
	oldCubeNote  = ReplaceStringByKey("EnergyIntegrationWindow", oldCubeNote, "", "=", "\r")
	oldCubeNote  = ReplaceStringByKey("MinimumIntensity", oldCubeNote, "", "=", "\r")
	oldCubeNote  = ReplaceStringByKey("MaximumIntensity", oldCubeNote, "", "=", "\r")
	newCubeNote  = ReplaceStringByKey("CenterEnergy", newCubeNote, "", "=", "\r")
	newCubeNote  = ReplaceStringByKey("EnergyIntegrationWindow", newCubeNote, "", "=", "\r")
	newCubeNote  = ReplaceStringByKey("MinimumIntensity", newCubeNote, "", "=", "\r")
	newCubeNote  = ReplaceStringByKey("MaximumIntensity", newCubeNote, "", "=", "\r")
	// Don't throw away the Errors information, since if an error occurred, it is probably
	// a good idea to regenerate FS map from scratch again.
	newCubeNote = SortList(newCubeNote, "\r")
	oldCubeNote = SortList(oldCubeNote, "\r")

	// if either the rawCube doesn't exist, or the cube notes don't match, or the user 
	// wants to force regeneration, we have to generate the rawCube again:
	if (! WaveExists(cfe_rawCubeBaumberger) || ! stringmatch(newCubeNote, oldCubeNote) || gv_forceGenCfeBaumberger)
		utils_progressDlg(message="mapBaumberger: generating I(c,f,E)", level=1)
		if (gamma == 180 || gamma == 270)
			genCfeBaumberger(w_coarseAngles, w_fineAngles, invertBeta = 1)
		else
			genCfeBaumberger(w_coarseAngles, w_fineAngles, invertBeta = 0)
		endif
	endif
	
		
	Variable e_from = gv_centerE - gv_dE/2000
	Variable e_to = gv_centerE + gv_dE/2000

	if (utils_progressDlg(message="mapBaumberger: integrating I(c,f)", level=1))
		return "Aborted by user"
	endif
	genCfBaumberger(e_from, e_to)
	genCfBaumberger(e_from, e_to)
		
	// transform from angle- to k-space
	WAVE cf_waveformBaumberger
	w_fsmap = interp2D(cf_waveformBaumberger,w_fsmap_fBaumberger,w_fsmap_cBaumberger)	// produces sometimes high-intensity-stripes along the edges
	w_fsmap = (w_fsmap ==0)?(NaN):w_fsmap
	// the above should be modified. sometimes, we have true intensity=0-point in the data
		
	if (utils_progressDlg(message="mapBaumberger: removing edges", level=1))
		return "Aborted by user"
	endif
	CutEdgeBaumberger(w_fsmap, -1e6, NaN)	// set the perimeter pixels to 'NaN'
		
	// kill the 2D and 3D waves to save some memory
	//KillWaves/Z cfe_rawCube, cf_waveform, fe_waveform
	return ""
End

//CutParticleEdge(w_fsmap, -1e6, NaN)	// set the perimeter pixels to 'NaN'

Static Function flipCBaumberger(alpha,kvac,kx,ky)
	Variable alpha, kvac, kx, ky
	
	Variable x_rot = ( cos(alpha*pi/180)*kx - sin(alpha*pi/180)*ky ) / kvac
	Variable y_rot = ( sin(alpha*pi/180)*kx + cos(alpha*pi/180)*ky ) / kvac
	
	return atan(y_rot/sqrt(1-(x_rot^2+y_rot^2))) * 180/pi
End

Static Function flipFBaumberger(alpha,kvac,kx,ky)
	Variable alpha, kvac, kx, ky
	
	Variable x_rot = ( cos(alpha*pi/180)*kx - sin(alpha*pi/180)*ky ) / kvac
	Variable y_rot = ( sin(alpha*pi/180)*kx + cos(alpha*pi/180)*ky ) / kvac
	
	return asin(x_rot) * 180/pi
End

// correction for ph != 0 to be implemented
Static Function FadleyPolBaumberger(ph,kvac,kx,ky)	// fine angle has to be polar angle for Fadley-type
	Variable ph, kvac, kx, ky
	
	// should use ky(ph)
	return asin(sqrt(kx*kx+ky*ky)/kvac) * 180/pi
End

Static Function FadleyOmBaumberger(ph,kvac,kx,ky)	// coarse angle has to be azimuthal(omega) angle for Fadley type
	Variable ph, kvac, kx, ky
	
	// should use ky(ph)
	return atan2(-ky,-kx) * 180/pi + 180
End


// generate a waveform in the coarse and fine angle coordinates with the intensities 
// integrated over an energy range. 
// The flag invertBeta determines whether the beta angle will be inverted. Off (0) by default.
Static Function genCfeBaumberger(w_cList, w_fList, [invertBeta])
	WAVE w_cList
	WAVE w_fList
	Variable invertBeta // Default is 0. Igor does that for me.

	String Df = Getdatafolder (1)
	SetDataFolder root:internalUse:FSMap
	
	NVAR gv_old_styleBaumberger
	NVAR gv_auto_zBaumberger
	NVAR gv_lin_combBaumberger
	
	WAVE/T w_dialog_waves
		
		
	Sort {w_cList, w_fList}, w_cList, w_fList, w_dialog_waves		// sort for ascending coarse angles


																	// 04-11-11 added sub-sort for ascending fine angles (required for merge3)
	// fe_waveform: point density and scaling (cropping is ignored here)
	Variable fine_from=inf, fine_to=-inf, dfine=inf
	Variable e_from=inf, e_to=-inf, dE=inf
	Variable i
	for(i = 0; i < numpnts(w_dialog_waves); i+= 1)
		WAVE M = $w_dialog_waves[i]
		e_from = min(e_from, dimoffset(M,1))
		e_to = max(e_to, dimoffset(M,1) + (dimsize(M,1)-1)*dimdelta(M,1))
		dE = min(dE, dimdelta(M,1))
		fine_from = min(fine_from, dimoffset(M,0) + w_fList[i])
		fine_to = max(fine_to, dimoffset(M,0) + (dimsize(M,0)-1)*dimdelta(M,0) + w_fList[i])
		dfine = min(dfine, dimdelta(M,0))
	endfor
	Variable en = (e_to - e_from)/dE + 1
	Variable fn = (fine_to - fine_from)/dfine + 1

	Make/o/n=(fn,en) fe_waveformBaumberger
	SetScale/I x fine_from, fine_to,"" fe_waveformBaumberger
	SetScale/I y e_from, e_to,"" fe_waveformBaumberger
		
		
	// how many different coarse angles?
	i = 0
	Variable cn = numpnts(w_cList)
	for ( i = 0; i < numpnts(w_cList) - 1; i+=1)
		if (w_cList[i] == w_cList[i+1])
			cn -= 1
		endif
	endfor
	
	// make and fill the cube
	Make/o/n=(cn,fn,en) cfe_rawCubeBaumberger
	Make/o/n=(cn) cfe_rawCube_c_axisBaumberger
	SetScale/I y fine_from, fine_to,"" cfe_rawCubeBaumberger
	SetScale/I z e_from, e_to,"" cfe_rawCubeBaumberger
		
	// scaling of carpets needs to include the fine-angle mani setting!!

	// This is not good yet since it does not work for all normalization
	// methods yet if you have multiple stripes in one map:
	// This needs to be incorporated further downwards:
	NVAR gv_norm_manual
	Variable dlgResult
	if (gv_norm_manual)
		generateNormWave(utils_wave2stringList(w_dialog_waves))
		dlgResult = generateNormWaveManual(utils_wave2stringList(w_dialog_waves))
		if (dlgResult == 0)
			utils_abort("Aborted by user.")
		endif
	else
		generateNormWave(utils_wave2stringList(w_dialog_waves))
	endif
	
	Variable c_i = 0
	for ( i = 0; i < numpnts(w_cList); i+=1) // loop over all carpets

		if (utils_progressDlg(message="genCfeBaumberger: filling cube", level=2,numDone=i,numTotal=numpnts(w_cList)))
			break
		endif

		WAVE m1 = $w_dialog_waves[i]
		Duplicate/o m1 m1_sBaumberger

//		Variable normFactor = 1
//		NVAR gv_norm_totalInt
//		if (gv_norm_totalInt == 1)
//			normFactor = sum(m1_sBaumberger) / DimSize(m1_sBaumberger,0) / DimSize(m1_sBaumberger,1)
//		endif
		WAVE w_normWave
		m1_sBaumberger *= w_normWave[i]
		// normalization:
		// TODO: do normalization at another location
//		mapper_norm(m1_sBaumberger)
			
		// offset the scaling by the fine angle value
		if (invertBeta == 0)
			SetScale/I x utils_x0(m1_sBaumberger)+w_fList[i], utils_x1(m1_sBaumberger)+w_fList[i],"" m1_sBaumberger
		else
			SetScale/I x utils_x1(m1_sBaumberger)+w_fList[i], utils_x0(m1_sBaumberger)+w_fList[i],"" m1_sBaumberger
		endif
			
		//merge2(m1_s,m1_s,fe_waveform)
		fe_waveformBaumberger = interp2D(m1_sBaumberger,x,y)	// runs much faster for single fine-angles
		fe_waveformBaumberger = (numtype(fe_waveformBaumberger) ==2)?(0):(fe_waveformBaumberger)
		
		for ( ; i != numpnts(w_cList)-1; i += 1) // loop over all fine-angle-manipulator-settings of a given coarse angle
			if(utils_progressDlg(message="genCfeBaumberger: filling cube", level=2,numDone=i,numTotal=numpnts(w_cList)))
				break
			endif

			if ( (abs(w_cList[i] - w_cList[i+1]) > 1e-4))
				break
			endif
			WAVE m2 = $w_dialog_waves[i+1]
			Duplicate/o m2 m2_sBaumberger
//			mapper_norm(m2_sBaumberger)
			if (invertBeta == 0)
				SetScale/I x utils_x0(m2_sBaumberger)+w_fList[i+1], utils_x1(m2_sBaumberger)+w_fList[i+1],"" m2_sBaumberger
			else
				SetScale/I x utils_x1(m2_sBaumberger)+w_fList[i+1], utils_x0(m2_sBaumberger)+w_fList[i+1],"" m2_sBaumberger
			endif

			//print "i=", i, "c_i=", c_i, w_cList[i], w_fList[i]
			if (gv_old_styleBaumberger)
				fsmap_merge2Baumberger(m2_sBaumberger,fe_waveformBaumberger,fe_waveformBaumberger)
			else
				fsmap_merge3Baumberger(m2_sBaumberger,fe_waveformBaumberger,fe_waveformBaumberger, gv_auto_zBaumberger, gv_lin_combBaumberger)
			endif
		endfor
			
		//doupdate
		cfe_rawCubeBaumberger[c_i][][] = fe_waveformBaumberger[q][r]
		//cfe_rawCube_c_axis[c_i] = w_cList[c_i] 	// this cannot be right...
		cfe_rawCube_c_axisBaumberger[c_i] = w_cList[i]			// 02-18-04 works now correctly for multiple fine angles at one coarse angle
		c_i+= 1
	endfor
			
	SetDataFolder $DF
End

// w12 is the merged carpet of w1 and w2
// overlapping area is replaced by the average of w1 and w2, free area is set to zero



// 'version 2': works for arbitrary shapes of free areas				FB 11/11/03
Function fsmap_merge2Baumberger(w1,w2,w12)
	WAVE w1, w2, w12
	
	Duplicate/o w12 w121 w122 w12b
	
	w121 = interp2D(w1,x,y)
	w121 = (numtype(w121) ==2)?(0):w121	
	
	w122 = interp2D(w2,x,y)
	w122 = (numtype(w122) ==2)?(0):w122
	
	// generate a duplicate of w12 that equals 2 for non-blank areas common to w1 and w2, and 1 elsewhere
	w12b = 0
	w12b += (w121 != 0)?(1):0.5
	w12b += (w122 != 0)?(1):0.5

	w12 = (w121 + w122) / trunc(w12b)

	KillWaves/Z w121 w122 w12b
End



// 'version 3': uses only the maximum square area with real data
Function fsmap_merge3Baumberger(w1,w2,w12, auto_z, auto_straight)
	WAVE w1, w2, w12
	Variable auto_z, auto_straight
	
	Variable x0_1, x1_1, y0_1, y1_1, x0_2, x1_2, y0_2, y1_2 
	Variable p0_1, p1_1, q0_1, q1_1, p0_2, p1_2, q0_2, q1_2 
	Variable p0, p1, q0, q1
	Variable v_w121, v_w122

	Duplicate/o w12 w121 w122, w_combination
	
	// find edges of max. square with real data (not NaN or zero)
	FindEdgesBaumberger(w1)
	WAVE w_edges
	x0_1 = w_edges[0]
	x1_1 = w_edges[1]
	y0_1 = w_edges[2]
	y1_1 = w_edges[3]
	
	Wavestats/Q w_edges
	if (v_numNaNs == 0)
		p0_1 = round( (x0_1 - DimOffset(w12, 0))/DimDelta(w12,0) )+1
		p1_1 = round( (x1_1 - DimOffset(w12, 0))/DimDelta(w12,0) )-1
		q0_1 = round( (y0_1 - DimOffset(w12, 1))/DimDelta(w12,1) )+1
		q1_1 = round( (y1_1 - DimOffset(w12, 1))/DimDelta(w12,1) )-1
		
		w121[p0_1,p1_1][q0_1,q1_1] = interp2D(w1,x,y)
		v_w121 = 1
	else
		w121 = 0
		v_w121 = 0
	endif
	

	FindEdgesBaumberger(w2)
	WAVE w_edges
	x0_2 = w_edges[0]
	x1_2 = w_edges[1]
	y0_2 = w_edges[2]
	y1_2 = w_edges[3]
	
	Wavestats/Q w_edges
	if (v_numNaNs == 0)
		p0_2 = round( (x0_2 - DimOffset(w12, 0))/DimDelta(w12,0) ) +1
		p1_2 = round( (x1_2 - DimOffset(w12, 0))/DimDelta(w12,0) ) -1
		q0_2 = round( (y0_2 - DimOffset(w12, 1))/DimDelta(w12,1) ) +1
		q1_2 = round( (y1_2 - DimOffset(w12, 1))/DimDelta(w12,1) ) -1
		
		w122[p0_2,p1_2][q0_2,q1_2] = interp2D(w2,x,y)
		v_w122 = 1
	else
		w122 = 0
		v_w122 = 0
	endif
	
	// boundary of overlapping region in w12
	p0 = max(p0_1,p0_2)
	p1 = min(p1_1,p1_2)
	q0 = max(q0_1,q0_2)
	q1 = min(q1_1,q1_2)
	
	if (auto_z)
		if (v_w122 + v_w121 == 2)
			Imagestats/M=1/G={max(p0_1,p0_2),min(p1_1,p1_2),max(q0_1,q0_2),min(q1_1,q1_2)} w121
			// should check for meaningful output
			Variable avg_1 = v_avg
			Imagestats/M=1/G={max(p0_1,p0_2),min(p1_1,p1_2),max(q0_1,q0_2),min(q1_1,q1_2)} w122
			Variable avg_2 = v_avg
			 w122 *= (avg_1/avg_2)
		 endif
	endif
	
	// replace overlap by linear combination
	if( v_w121 == 0 && v_w122 == 0)
		w12 = 0
	endif
	if( v_w121 == 0 || v_w122 == 0)
		if (v_w121 == 0)
			w12 = w122
		endif
		if (v_w122 == 0)
			w12 = w121
		endif
	
	else
		w_combination = 1
		w_combination[p0_1,p1_1][q0_1,q1_1] = 0
		if (auto_straight && v_w121+v_w122 == 2)
			w_combination[p0,p1][q0,q1] = 1 - 1/(p1-p0)* (p-p0)
			//print p0, p1, p0_2
			if (p0 == p0_2)
				w_combination[p0,p1][q0,q1] = 1/(p1-p0)* (p-p0)
			endif
		else
			w_combination[p0,p1][q0,q1] = 0.5
		endif
		w12 = w122 * w_combination + w121 * (1-w_combination)	
	endif
	
	KillWaves/Z w121 w122 w12_combination, w_edges
End

// creates the wave w_Edges with x0, x1, y0, y1
Static Function FindEdgesBaumberger(M)
	WAVE M
	
	Make/O/N=4 w_Edges
	Make/O/N=2 w_xEdges, w_yEdges
	
	utils_getWaveAvg(M,0)
	WAVE w_avg
	w_avg = (numtype(w_avg)==2)?0:w_avg
	w_avg[0]=0	// make sure that edges exist
	w_avg[dimsize(w_avg,0)-1]=0
	Make/O/N=2 w_xEdges
	Findlevels /Q/N=2/D=w_xEdges w_avg, 1e-9
	w_Edges[0] = w_xEdges[0]
	w_Edges[1] = w_xEdges[1]
	
	utils_getWaveAvg(M,1)
	w_avg = (numtype(w_avg)==2)?0:w_avg
	w_avg[0]=0
	w_avg[dimsize(w_avg,0)-1]=0
	Findlevels /Q/N=2/D=w_yEdges w_avg, 1e-9
	w_Edges[2] = w_yEdges[0]
	w_Edges[3] = w_yEdges[1]
	
	KillWaves/Z w_xEdges, w_yEdges
End



// integrate the cfe_rawCube over an energy range and interpolate the resulting matrix line-by-line along the coarse angle coordinate
Static Function genCfBaumberger(e_from, e_to)
	Variable e_from, e_to
	
	String Df = Getdatafolder (1)
	SetDataFolder root:internalUse:FSMap
	
	WAVE cfe_rawCubeBaumberger
	WAVE cfe_rawCube_c_axisBaumberger
	Variable de = dimdelta(cfe_rawCubeBaumberger,2)

	Variable x0 = cfe_rawCube_c_axisBaumberger[0]
	Variable x1 = cfe_rawCube_c_axisBaumberger[numpnts(cfe_rawCube_c_axisBaumberger)-1]
	Variable y0 = utils_y0(cfe_rawCubeBaumberger)
	Variable y1 = utils_y1(cfe_rawCubeBaumberger)
	
	// same point density for interpolated coarse angle as for fine angle
	Variable dfine = dimdelta(cfe_rawCubeBaumberger,1)
	Variable c_points = round(abs(x1 - x0) / dfine + 1)
	
	Make/o/n=(dimsize(cfe_rawCubeBaumberger,0),dimsize(cfe_rawCubeBaumberger,1)) cf_rawMatrixBaumberger = 0	// x is 'coarse', y is 'fine'
	Make/o/n=(c_points,dimsize(cfe_rawCubeBaumberger,1)) cf_waveformBaumberger
	SetScale/I y y0, y1, "" cf_rawMatrixBaumberger, cf_waveformBaumberger
	
	// integrate energies
	// the x (coarse angle) scaling of the cfe_rawCube are data-points!
	Variable i
	for (i = e_from; i < e_to; i += de)
		cf_rawMatrixBaumberger += cfe_rawCubeBaumberger(x)(y)(i)	// gives the linear interpolation at exactly 'en'
	endfor
	
//	cf_rawMatrixBaumberger /= trunc(abs((e_to-e_from)/de)) + 1	// corrected by the '+1', FB 04-21-04
	cf_rawMatrixBaumberger *= de								// True integral. FS, 29oct2007
	
	// interpolate along coarse coordinate
	Make/o/n = (c_points) coarse_DC
	Make/o/n = (dimsize(cf_rawMatrixBaumberger,0)) coarse_rawDC
	SetScale/I x x0,x1,"" coarse_DC, coarse_rawDC
	
	if (utils_progressDlg(message="genCfBaumberger: backmapping", level=2))
		return 0
	endif
	
	for (i = 0; i < dimsize(cf_rawMatrixBaumberger,1); i += 1)
		coarse_rawDC = cf_rawMatrixBaumberger[p][i]
		coarse_DC = interp(x,cfe_rawCube_c_axisBaumberger,coarse_rawDC)	// here I could implement splines
		cf_waveformBaumberger[][i] = coarse_DC[p]
	endfor
	
	SetScale/I x x0, x1, "" cf_waveformBaumberger
	
	SetDataFolder $DF
End


// This function sets 1-2 pixels along the perimeter of all particles that exceed the value 'threshold' to 'value'
// useful to get rid of edge problems. runs rather slow.		FB 04-22-04
Static Function CutEdgeBaumberger(M, threshold, value)
	WAVE M; Variable threshold, value
	
	ImageThreshold /T= (threshold)  M
	WAVE M_ImageThresh
	M_ImageThresh = (M_ImageThresh==64)?(255):0
	ImageAnalyzeParticles/Q /M=1 stats M_ImageThresh
	WAVE M_ParticlePerimeter
	Redimension/S M_ParticlePerimeter
	
	M = (M_ParticlePerimeter==0)?(value):M
	
	KillWaves/Z M_ImageThresh, M_rawMoments, M_ParticlePerimeter, W_ImageObjArea, W_spotx, w_spoty, w_circularity
	KillWaves/Z w_rectangularity, w_imageobjperimeter, w_xmin, w_ymin, w_xmax, w_ymax
End
