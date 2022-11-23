#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 3.00
#pragma ModuleName = process
#pragma IgorVersion = 5.0




















//////////////////////////////////////
//
// Public functions
//
//////////////////////////////////////




















Function process_open(ctrlName)
	String ctrlName

	norm_init()
	init()
	
	String DF = GetDataFolder (1)
	SetDataFolder root:internalUse:process
	
	DoWindow/K process_panel
	Display/K=1 as "process panel"
	DoWindow/C process_panel
	utils_resizeWindow("process_panel", 510, 565)
	utils_autoPosWindow("process_panel", win=127)
	String cmd = "ControlBar 213"
	execute cmd
	
	Variable r=57000, g=57000, b=57000	// background color for the TabControl
	ModifyGraph cbRGB=(42428,42428,42428)
	ModifyGraph wbRGB=(52428,52428,52428),gbRGB=(52428,52428,52428)
	
	// controls that do not depend on the tabs
	panelcommon_srcListBoxInit()
	listbox waves_lb, pos={16,37}, size={130,145}, listwave=root:internalUse:panelcommon:w_sourceNames, selwave=root:internalUse:panelcommon:w_sourceNamesSel, frame=2,mode=4, proc=panelcommon_srcListboxProc, widths={200}
	
	CheckBox n_check0, pos={20,197}, title="suppress par. update"
	CheckBox n_check1, pos={160,197}, title="lock DC-intensity scale", proc=panelcommon_checkBoxLockInt
	CheckBox n_check2, pos={340,197}, title="integrate E", proc=panelcommon_checkBoxIntEorK
	CheckBox n_check3, pos={420,197}, title="integrate k", proc=panelcommon_checkBoxIntEorK

	
	// --------------------------tab-controls -----------------
	// source tab
	TabControl process,proc=process#tabControlChange,pos={8,6},size={494,190},tabLabel(0)="source",value=0,labelBack=(r,g,b), fsize=12
	GroupBox sou_gb0, frame=1,labelBack=(r,g,b), pos={170,35}, size={240,149}, title="source folder", fsize=10
	listbox sou_lb1, pos={180,60}, size={220,90}, listwave=root:internalUse:panelcommon:w_DF, selrow=0, frame=2,mode=1, proc=panelcommon_srcListboxProc
	
	
	//--------------------------------------------------------------------------------------------------------------
	TabControl process,tabLabel(1)="axes"
	GroupBox axe_gb1, frame=1, labelBack=(r,g,b), pos={160,110}, size={225,70}, title="energies/y-values", fsize=10, disable=1
	Button axe_bEkEi, pos={170,128}, size={80,20},labelBack=(r,g,b), fsize=12, title="E\Bk\M to E\Bi", proc=process#buttonRescaleEnergy, disable=1
	SetVariable axe_sv0, pos={270,130}, size={80,15}, labelBack=(r,g,b), fsize=12, limits={-inf,inf,0}, title="EF", value=gv_axes_EF, disable=1
	Button axe_bEBEi, labelBack=(r,g,b), pos={170,152}, size={80,20}, title="E\BB\M <-> E\Bi", proc=process#buttonRescaleEnergy, disable=1
	
	GroupBox axe_gb11, frame=1, labelBack=0, pos={375,35}, size={110,65}, title=" " , disable=1
	GroupBox axe_gb10, frame=1, labelBack=0, pos={160,35}, size={325,65}, title="angles/x-values", fsize=10, disable=1
	SetVariable axe_svaxesX0, pos={175,55}, size={80,15}, labelBack=(r,g,b), fsize=10, limits={-inf,inf,0}, title="start", proc=process#setVariableUpdateAxes, value=gv_axes_x0, disable=1
	SetVariable axe_svaxesX1, pos={275,55}, size={80,15}, labelBack=(r,g,b), fsize=10, limits={-inf,inf,0}, title="  end ", proc=process#setVariableUpdateAxes, value=gv_axes_x1, disable=1
	SetVariable axe_svaxesDx, pos={175,75}, size={80,15}, labelBack=(r,g,b), fsize=10, limits={-inf,inf,0}, title="delta", proc=process#setVariableUpdateAxes, value=gv_axes_dx, disable=1
	SetVariable axe_svaxesXCenter, pos={275,75}, size={80,15}, labelBack=(r,g,b), fsize=10, limits={-inf,inf,0}, title="center", proc=process#setVariableUpdateAxes, value=gv_axes_xcenter, disable=1
	SetVariable axe_svaxesCsrZero, pos={400,75}, size={60,15}, labelBack=(r,g,b), fsize=10, limits={-inf,inf,0}, title="x=", proc=process#setVariableUpdateAxes, value=gv_axes_csrZero, disable=1
	Button axe_b10, labelBack=(r,g,b), pos={385,55}, size={90,16}, title="shift cursor to", proc=process#buttonRescaleToCsr, disable=1
	
	//--------------------------------------------------------------------------------------------------------------
	TabControl process,tabLabel(2)="k_par"
	GroupBox k_p_gb0, frame=1, labelBack=(r,g,b), pos={395,35}, size={94,80}, title="energies", fsize=10, disable=1
	SetVariable k_p_sv0,labelBack=(r,g,b), pos={400,55},size={84,15}, limits={0,100,0}, title="hn ",frame=1,fsize=10,value= gv_hn, disable=1
	SetVariable k_p_sv1,labelBack=(r,g,b), pos={400,73},size={84,15}, limits={0,100,0}, title="E_F",frame=1,fsize=10,value= gv_EF, disable=1
	SetVariable k_p_sv2,labelBack=(r,g,b), pos={400,91},size={84,15}, limits={0,100,0}, title="work-f.",frame=1,fsize=10,value= gv_workfunc, disable=1
	
	GroupBox k_p_gb10, frame=1, labelBack=(r,g,b), pos={160,35}, size={80,150}, title="polar cuts", fsize=10, disable=1
	SetVariable k_p_sv10,labelBack=(r,g,b), pos={167,60},size={65,15}, limits={0,100,0}, title="k-pnts",frame=1,fsize=10,value= gs_kpnts, disable=1
	SetVariable k_p_sv11,labelBack=(r,g,b), pos={167,80},size={65,15}, limits={0,100,0}, title="e-pnts",frame=1,fsize=10,value= gs_epnts, disable=1
	Button k_p_b10, labelBack=(r,g,b), pos={170,158}, size={60,16}, title="preview", proc=process#buttonMapPolarCut, disable=1
	Button k_p_b10, help={"Maps polar cuts to k. Uses correct energy dependence of the vacuum wave vector."}
	
	GroupBox k_p_gb20, frame=1, labelBack=(r,g,b), pos={250,35}, size={135,150}, title="flip-stage cuts", fsize=10, disable=1
	SetVariable k_p_sv20,labelBack=(r,g,b), pos={255,55},size={60,15}, limits={-180,180,0}, title="th",frame=1,fsize=10,value= gv_th, disable=1
	SetVariable k_p_sv21,labelBack=(r,g,b), pos={320,55},size={60,15}, limits={-180,180,0}, title="ph",frame=1,fsize=10,value= gv_ph, disable=1
	SetVariable k_p_sv22,labelBack=(r,g,b), pos={255,73},size={60,15}, limits={0,360,0}, title="om",frame=1,fsize=10,value= gv_omega, disable=1
	SetVariable k_p_sv23,labelBack=(r,g,b), pos={320,73},size={60,15}, limits={0,360,0}, title="al",frame=1,fsize=10,value= gv_alpha, disable=1
	SetVariable k_p_sv24,labelBack=(r,g,b), pos={255,91},size={60,15}, limits={0,360,0}, title="ga",frame=1,fsize=10,value= gv_gamma, disable=1
	SetVariable k_p_sv25,labelBack=(r,g,b), pos={320,91},size={60,15}, limits={0,360,0}, title="sgn",frame=1,fsize=10,value= gv_signs, disable=1
	PopupMenu k_p_pm20, pos={255, 109}, size={125,18},title="E-Scale",value="kinetic;InitialState", disable=1
	SVAR gs_energyScale
	if (stringmatch(gs_energyScale, "kinetic"))
		PopupMenu k_p_pm20, mode = 1
	else
		PopupMenu k_p_pm20, mode = 2
	endif
	CheckBox k_p_lattice_check, pos={257,139}, title="", disable=1
	SetVariable k_p_lattice, pos={277,139},labelBack=(r,g,b), size={102,15},limits={0,inf,0}, title="units (pi/a),a=", frame=1, fsize=10, value=lattice_a, disable=1
	Button k_p_b20, labelBack=(r,g,b), pos={305,158}, size={70,16}, title="preview", proc=process#buttonMapFlipstageCut, disable=1
	Button k_p_b20, help={"Assumes a linear cut in k-space and ingores the energy dependence of the vacuum wave vector (projects onto a radial k// coordinate)."}
	CheckBox k_p_eDep_check, pos={257,158}, title="e-dep", disable=1

	// -------------------------------------------------------------------------------------------
	TabControl process,tabLabel(3)="smooth/2nd"
	GroupBox smo_gb0, frame=1, labelBack=(r,g,b), pos={160,35}, size={175,55}, title="reduce points", fsize=10, disable=1
	Button smo_bredYPnts, pos={170,60}, size={65,16}, labelBack=(r,g,b), title="y-points", proc = process#buttonReducePnts, disable=1
	Button smo_bredXPnts, pos={260,60}, size={65,16}, labelBack=(r,g,b), title="x-points", proc = process#buttonReducePnts, disable=1
	
	GroupBox smo_gb10, frame=1, labelBack=(r,g,b), pos={160,105}, size={175,75}, title="smooth", fsize=10, disable=1
	SetVariable smo_sv10,labelBack=(r,g,b), pos={170,130},size={90,15}, limits={0,100,1}, title="x-pnts:",frame=1,fsize=10,value= gv_xSmooth, disable=1
	SetVariable smo_sv11,labelBack=(r,g,b), pos={170,152},size={90,15}, limits={0,100,1}, title="y-pnts:",frame=1,fsize=10,value= gv_ySmooth, disable=1
	Button smo_bsmoothXPnts, pos={280,130}, size={35,16}, labelBack=(r,g,b), title="go", proc = process#buttonSmoothPnts, disable=1
	Button smo_bsmoothYPnts, pos={280,152}, size={35,16}, labelBack=(r,g,b), title="go", proc = process#buttonSmoothPnts, disable=1
	
	GroupBox smo_gb20, frame=1, labelBack=(r,g,b), pos={355,35}, size={130,55}, title="derivative", fsize=10, disable=1
	Button smo_bd_dx, pos={370,60}, size={45,16}, labelBack=(r,g,b), title="d/dx", proc = process#buttonDoDerivative, disable=1
	Button smo_bd_dy, pos={425,60}, size={45,16}, labelBack=(r,g,b), title="d/dy", proc = process#buttonDoDerivative, disable=1
	
	Button smo_breset, pos={395,120}, size={80,16}, labelBack=(r,g,b), title="reset", proc=process#buttonClearProcAndMacro, disable=1
	Button smo_bsaveAs, pos={395,145}, size={55,16}, labelBack=(r,g,b), title="save as", proc=process#buttonSaveProcessed, disable=1
	SetVariable smo_svsaveName,labelBack=(r,g,b), pos={396,166},size={94,15}, title=" ",frame=1,fsize=10,value= gs_Mname, disable=1
	CheckBox smo_cboverwrite, pos={455,145}, labelBack=(r,g,b), fsize=12, title="/O", disable=1
	
	
	//--------------------------------------------------------------------------------------------------------------
	TabControl process,tabLabel(4)="bkg."
	GroupBox bkg_gb0, frame=1, labelBack=0, pos={160,34}, size={324,75}, title="subtract bkg.", fsize=10, disable=1
	Button bkg_bbrowse, pos={220,50}, size={60,14}, labelBack=(r,g,b), fsize=10, title="browse", proc=process#buttonsubBkgBrowse, disable=1
	SetVariable bkg_sv0,labelBack=(r,g,b), pos={220,65},size={200,15}, title=" ",frame=0, noedit=1,fsize=10,value= gs_bkgPath, disable=1
	CheckBox bkg_cbkOfX, pos={165,50}, labelBack=(r,g,b), title="k (x):", proc=process#checkBoxSubAvgXorY, disable=1
	CheckBox bkg_cbeOfY, pos={165,67}, labelBack=(r,g,b), title="e (y):", proc=process#checkBoxSubAvgXorY, value=1, disable=1
	Button bkg_bsmooth, pos={210,87}, size={50,14}, labelBack=(r,g,b), fsize=10, title="smooth", proc=process#buttonSubBkgSmooth,  disable=1
	SetVariable bkg_sv1,labelBack=(r,g,b), pos={265,87},size={50,15}, limits={0,100,1}, title=" ",frame=1,fsize=10,value= gv_bkgSmooth, disable=1
	Button bkg_b2, pos={380,86}, size={80,16}, labelBack=(r,g,b), title="preview", proc=process#buttonDoSubBkg,  disable=1
	
	GroupBox bkg_gbpanelLooks, frame=1, labelBack=(r,g,b), pos={160,115}, size={200,70}, title="panel appearance", fsize=10, disable=1
	Button bkg_bshowProcWave, pos={170,140}, size={120,14}, fsize=10, labelBack=(r,g,b), title="show process wave", proc= process#buttonShowProcWave, disable=1
	Button bkg_bremoveProcWave, pos={170,160}, size={120,14}, fsize=10, labelBack=(r,g,b), title="remove process wave", proc= process#buttonRemoveProcWave, disable=1
	
	//--------------------------------------------------------------------------------------------------------------
	TabControl process,tabLabel(5)="avg."
	GroupBox avg_gb0, frame=1, labelBack=0, pos={160,34}, size={324,75}, title="divide by e/k-average", fsize=10, disable=1
	
//	CheckBox avg_c0, pos={165,50}, labelBack=(r,g,b), title="e-avg:", proc=process#checkBoxSubAvgXorY, disable=1
//	CheckBox avg_c1, pos={165,67}, labelBack=(r,g,b), title="k-avg:", proc=process#checkBoxSubAvgXorY, value=1, disable=1
	
	SetVariable avg_sv10,labelBack=(r,g,b), pos={218,50},size={65,15}, limits={-inf,inf,0}, title="k0:",frame=1,fsize=10,value= gv_avg_x0, disable=1
	SetVariable avg_sv11,labelBack=(r,g,b), pos={290,50},size={65,15}, limits={-inf,inf,0}, title="k1:",frame=1,fsize=10,value= gv_avg_x1, disable=1
	SetVariable avg_sv12,labelBack=(r,g,b), pos={218,67},size={65,15}, limits={-inf,inf,0}, title="e0:",frame=1,fsize=10,value= gv_avg_y0, disable=1
	SetVariable avg_sv13,labelBack=(r,g,b), pos={290,67},size={65,15}, limits={-inf,inf,0}, title="e1:",frame=1,fsize=10,value= gv_avg_y1, disable=1
	
	Button avg_b1, pos={170,87}, size={35,14}, labelBack=(r,g,b), fsize=10, title="calc.", proc=process#buttonCalcAvgWave,  disable=1
	Button avg_b11, pos={365,51}, size={20,29}, labelBack=(r,g,b), title="m", proc=process#buttonReadAvgMarquee,  disable=1
	Button avg_b13, pos={380,87}, size={80,16}, labelBack=(r,g,b), title="preview", proc=process#buttonDoAverage,  disable=1
	
	
	//--------------------------------------------------------------------------------------------------------------
	//TabControl process,tabLabel(4)="Fermi"
	//The following is added by Wei-Sheng 10/31/05
	TabControl process,tabLabel(6)="sym."
	GroupBox sym_gb0, frame=1, labelBack=0, pos={160,34}, size={324,75}, title="Symmetrization", fsize=10, disable=1
	SetVariable sym_sv1,labelBack=(r,g,b), pos={180,50},size={65,15}, limits={-inf,inf,0}, title="Ef:",frame=1,fsize=10,value= gv_sym_e0, disable=1
	Button sym_b1, pos={180,87}, size={80,16}, labelBack=(r,g,b), title="preview", proc=process#buttonEDCSymmetrize,  disable=1
	//-----------------------------------------------------------------------------------------------------------------------

	TabControl process,tabLabel(7)="macro"
	listbox mac_lb0, pos={180,40}, size={300,120}, listwave=w_process_macro, frame=2,mode=0, disable=1
//	GroupBox mac_gb0, frame=1, labelBack=0, pos={160,34}, size={324,75}, title="Symmetrization", fsize=10, disable=1
//	SetVariable mac_sv1,labelBack=(r,g,b), pos={180,50},size={65,15}, limits={-inf,inf,0}, title="Ef:",frame=1,fsize=10,value= gv_sym_e0, disable=1
	Button mac_b0, pos={180,170}, size={140,16}, labelBack=(r,g,b), title="clear macro list", proc=process#buttonClearProcAndMacro,  disable=1
	Button mac_b1, pos={330,170}, size={140,16}, labelBack=(r,g,b), title="apply to selected", proc=process#buttonMacroApplySelected,  disable=1
	
	panelcommon_addImage("process_panel")
	process_panel_SLB_proc()
	
	SetDataFolder $DF
End



// NOTE: this is vintage code. It will be replaced eventually.
// This function is called from i_panelcommon, namely from panelcommon_srcListboxProc().
// The function name is auto-generated; it needs to be composed out of
// <windowname>_SLB_proc such that panelcommon_srcListboxProc()
// can find it. This function updates the graph view.
// executed whenever one or more cells in the source list-boxes are selected
Function process_panel_SLB_proc()
	
	String pDF = GetDataFolder (1)
	SetDataFolder root:internalUse:panelcommon
	SVAR DF = root:internalUse:panelcommon:gs_currentDF
	SVAR pList = root:internalUse:panelcommon:gs_sourcePathList
	SVAR topPath = root:internalUse:panelcommon:gs_TopItemPath
		
	//WAVE w_sourceNamesSel
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
			
	Variable xPoint = pcsr(B,"process_panel")
	Variable yPoint = qcsr(B,"process_panel")
	n_mdc = w_image[p][yPoint]
	n_edc = w_image[xPoint][p]
	
	process_defaults()
	//update_crop_limits(w_image)
	// This is needed to call the CursorMovedHook() function to update the
	// image info if the image changes:
	Cursor/I B, w_image, utils_pnt2x(w_image, xPoint), utils_pnt2y(w_image, yPoint)
	SetDataFolder $pDF
End




Function process_defaults()

	ControlInfo/w=process_panel n_check0
	if (v_value)
		return 0
	endif
	
	SVAR name = root:internalUse:process:gs_Mname
	SVAR topName = root:internalUse:panelcommon:gs_TopItemName
	SVAR topPath = root:internalUse:panelcommon:gs_TopItemPath
	WAVE M = $topPath
	
	if (waveexists($topPath) == 0)
		return 0
	endif
	
	String notestr = note(M)
	
	// smooth stuff
	NVAR xSmooth = root:internalUse:process:gv_xSmooth
	NVAR ySmooth = root:internalUse:process:gv_ySmooth
	NVAR x0 = root:internalUse:process:gv_avg_x0
	NVAR x1 = root:internalUse:process:gv_avg_x1
	NVAR y0 = root:internalUse:process:gv_avg_y0
	NVAR y1 = root:internalUse:process:gv_avg_y1

	xSmooth = 2
	ySmooth = 5
	x0 = utils_x0(M)
	x1 = utils_x1(M)
	y0 = utils_y0(M)
	y1 = utils_y1(M)
	name = topName
 	
 	SetVariable avg_sv10, limits={x0,x1,0}
 	SetVariable avg_sv11, limits={x0,x1,0}
 	SetVariable avg_sv12, limits={y0,y1,0}
 	SetVariable avg_sv13, limits={y0,y1,0}
 	
 	// k-parallel stuff
 	NVAR hn = root:internalUse:process:gv_hn
 	NVAR EF = root:internalUse:process:gv_EF 
 	NVAR workfunc = root:internalUse:process:gv_workfunc 
 	NVAR th = root:internalUse:process:gv_th 
 	NVAR ph = root:internalUse:process:gv_ph
 	NVAR alpha = root:internalUse:process:gv_alpha 
 	NVAR omega = root:internalUse:process:gv_omega
 	NVAR gamma = root:internalUse:process:gv_gamma
 	NVAR signs = root:internalUse:process:gv_signs
 	SVAR energyScale = root:internalUse:process:gs_energyScale

 	hn = NumberByKey("PhotonEnergy", notestr,"=","\r")
 	EF = NumberByKey("FermiLevel", notestr,"=","\r")
 	workfunc = NumberByKey("WorkFunction", notestr,"=","\r")
 	th = NumberByKey("InitialThetaManipulator", notestr,"=","\r")
 	th += NumberByKey("OffsetThetaManipulator", notestr,"=","\r")
 	ph = NumberByKey("InitialPhiManipulator", notestr,"=","\r")
 	ph += NumberByKey("OffsetPhiManipulator", notestr,"=","\r")
 	omega = NumberByKey("InitialAzimuthManipulator", notestr,"=","\r")
 	omega += NumberByKey("OffsetAzimuthManipulator", notestr,"=","\r")
 	alpha = NumberByKey("InitialAlphaAnalyzer", notestr,"=","\r")
 	gamma = NumberByKey("ScientaOrientation", notestr,"=","\r")
 	signs = NumberByKey("AngleSignConventions", notestr,"=","\r")
 	energyScale = StringByKey("EnergyScale", notestr, "=", "\r")
	if (stringmatch(energyScale, "kinetic"))
		PopupMenu k_p_pm20, mode = 1
	else
		PopupMenu k_p_pm20, mode = 2
		energyScale = "InitialState"
	endif
 	
 	// axes-scaling
 	NVAR sym_EF = root:internalUse:process:gv_sym_e0
 	NVAR axes_EF = root:internalUse:process:gv_axes_EF
 	NVAR axes_x0 = root:internalUse:process:gv_axes_x0
 	NVAR axes_x1 = root:internalUse:process:gv_axes_x1
 	NVAR axes_dx = root:internalUse:process:gv_axes_dx
 	NVAR axes_xcenter = root:internaluse:process:gv_axes_xcenter
 	
 	axes_EF = EF
 	sym_EF = EF
 	axes_x0 = utils_x0(M)
 	axes_x1 = utils_x1(M)
 	axes_dx = dimdelta(M,0)
 	axes_xcenter = (axes_x1 + axes_x0) / 2
End

























//////////////////////////////////////
//
// Private functions: Control Callbacks
//
//////////////////////////////////////

















// Vintage function for vintage code.
// Just a wrapper to the more modern function globals_flip_ang2k(t,p,a,b,g)
//Static Function flip_to_k(kvac,th,alpha,ph,omega,beta,gamma,flag)
//	Variable kvac, th,alpha,ph,omega,beta,gamma,flag
//	
//	globals_flip_ang2k(th,alpha,ph,omega,beta,gamma)
//	NVAR V_kx, V_ky
//	Variable kx = V_kx * kvac
//	Variable ky = V_ky * kvac
//	KillWaves angles2k_Result
//	if (flag == 0)
//		return kx
//	else
//		return ky
//	endif
//End




Static Function buttonMapFlipstageCut(ctrlName)
 	String ctrlName
 	
 	NVAR hn = root:internalUse:process:gv_hn
 	NVAR EF = root:internalUse:process:gv_EF
 	NVAR workfunc = root:internalUse:process:gv_workfunc
 	NVAR th = root:internaluse:process:gv_th
 	NVAR ph = root:internaluse:process:gv_ph
 	NVAR omega = root:internaluse:process:gv_omega
 	NVAR alpha = root:internaluse:process:gv_alpha
 	NVAR gamma = root:internaluse:process:gv_gamma
 	NVAR signs = root:internaluse:process:gv_signs
 	SVAR energyScale = root:internaluse:process:gs_energyScale
 	NVAR lattice_a = root:internaluse:process:lattice_a   // Added by Wei-Sheng 12/08/04
 	WAVE image = root:internalUse:panelcommon:w_image

 	Variable kvac = sqrt(hn - workfunc) * 0.5123
 	Variable test, kx0, kx1, ky0, ky1
 	globals_flip_ang2k(th,alpha,ph,omega,utils_x0(image),gamma, signs=signs)
 	NVAR V_kx, V_ky
 	kx0 = V_kx// * kvac//flip_to_k(kvac,th,alpha,ph,omega,utils_x0(image),gamma,0)
 	ky0 = V_ky// * kvac//flip_to_k(kvac,th,alpha,ph,omega,utils_x0(image),gamma,1)
 	globals_flip_ang2k(th,alpha,ph,omega,utils_x1(image),gamma, signs=signs)
 	NVAR V_kx, V_ky
 	kx1 = V_kx// * kvac//flip_to_k(kvac,th,alpha,ph,omega,utils_x1(image),gamma,0)
 	ky1 = V_ky// * kvac//flip_to_k(kvac,th,alpha,ph,omega,utils_x1(image),gamma,1)
 	
 	Variable angle = atan2(ky1-ky0, kx1-kx0)
 	Variable azi0 = atan2(ky0,kx0)
 	Variable azi1 = atan2(ky1,kx1)
 	Variable kp0 = sqrt(kx0*kx0 + ky0*ky0)
 	Variable kp1 = sqrt(kx1*kx1 + ky1*ky1)
 	Variable k0 = kp0 * cos(angle - azi0)
 	Variable k1 = kp1 * cos(angle - azi1)
 	
 	//The following 5 lines are added by Wei-Sheng to transfor it in unit of Pi/a   12/08/04
 	ControlInfo k_p_lattice_check
 	Variable latticeCheck = V_Value
 	if (latticeCheck == 1)
 		if (alpha != 0)
 			String s = "You chose both to scale with a and azi != 0. Be aware that a is the distance "
 			s += "between the unit cell boundaries, along a line with angle azi, going through the center. "
 			s += "=> Only for azi = 0 and rectangular unit cell does it correspond to lattice a/b."
	 		DoAlert 0, s
	 	endif
 		k0 = k0 * lattice_a / pi
 		k1 = k1 * lattice_a / pi					
 	endif
 

 	ControlInfo k_p_eDep_check
 	Variable eDepCheck = V_Value
 	if (eDepCheck == 1)
	 	SetScale/I x k0*kvac,k1*kvac,"" image
		Variable kmax, kmin
	 	if (stringmatch(energyScale, "kinetic"))
	 		kmax = k0*sqrt(hn-EF - workfunc+utils_y1(image)) * 0.5123
	 		kmin = k1*sqrt(hn-EF - workfunc+utils_y1(image)) * 0.5123
	 	else // "initial*"
	 		kmax = k0*sqrt(hn- workfunc+utils_y1(image)) * 0.5123
	 		kmin = k1*sqrt(hn- workfunc+utils_y1(image)) * 0.5123
	 	endif
	 	if (latticeCheck)
		 	kmax *= lattice_a / pi
		 	kmin *= lattice_a / pi
		endif
	 	Duplicate/O image, root:internalUse:process:w_tmp
	 	WAVE w_tmp = root:internalUse:process:w_tmp
	 	Redimension/N=(abs((kmax-kmin)/((k1-k0)*kvac))*DimSize(image, 0),-1) w_tmp
	 	w_tmp = NaN
	 	SetScale/I x kmin, kmax,"" w_tmp

	 	Make/O/N=(DimSize(image, 0)) root:internalUse:process:w_image1D = NaN, root:internalUse:process:w_image1D_x
	 	WAVE w_image1D = root:internalUse:process:w_image1D
	 	WAVE w_image1D_x = root:internalUse:process:w_image1D_x
	 	w_image1D_x = (p/DimSize(w_image1D_x, 0)) * (utils_x1(image) - utils_x0(image)) + utils_x0(image)

		Variable energyScale_Insane = 0
		Variable i, j
	 	for (i = 0; i < DimSize(w_tmp, 1); i += 1)
	 		Variable energy = utils_pnt2y(w_tmp, i)
	 		Variable kvac_i
		 	if (stringmatch(energyScale, "kinetic"))
		 		kvac_i = sqrt(hn-EF - workfunc+energy) * 0.5123
		 	else // "initial*"
		 		kvac_i = sqrt(hn - workfunc+energy) * 0.5123
		 	endif
		 	if (numtype(kvac_i) != 0) // this probably means that the energies are < 0 at some point.
		 		energyScale_Insane = 1
		 	endif
	 		w_image1D = image[p][i]
	 		for(j = 0; j < DimSize(w_tmp, 0); j += 1)
	 			Variable xx = utils_pnt2x(w_tmp, j)*kvac/kvac_i
	 			w_tmp[j][i] = (xx > utils_x0(image) && xx < utils_x1(image)) ? interp(xx, w_image1D_x, w_image1D) : NaN
	 		endfor
	 	endfor
	 	Duplicate/O w_tmp, root:internalUse:panelcommon:w_image
	 	KillWaves root:internalUse:process:w_tmp, root:internalUse:process:w_image1D, root:internalUse:process:w_image1d_x

	 	if (energyScale_Insane)
		 	DoAlert 0, "Could not determine k_vacuum for all energies. This probably means that some energies were smaller than zero, which in turn could mean the energy scaling is wrong."
		endif
 	else 
	 	SetScale/I x k0*kvac,k1*kvac,"" image
 	endif

  	String m
 	sprintf m, "map flipstage cut: hn=%f;EF=%f;workfn=%f;theta=%f;phi=%f;alpha=%f;gamma=%f;signs=%d;lattice_a=%f;lattice_check=%d;edep_check=%d;energyscale=%s",hn,EF,workfunc,th,ph,alpha,gamma,signs,lattice_a,latticeCheck, eDepCheck, energyScale
 	macro_add_process(m)
 	
 	new_panel_DCs(image, "process_panel")
 	
 	String notestr = note(image)
 	String map_note = ""
 	if (eDepCheck == 1)
 		map_note += "KVAC_PROJECTION;"
 	endif
 	map_note += "APPROXIMATIVE;hn="+num2str(hn)+";EF="+num2str(EF)+";workfunction="+num2str(workfunc)
 	map_note += ";theta="+num2str(th)+";phi="+num2str(ph)+";alpha="+num2str(alpha)+";omega="+num2str(omega)+";gamma="+num2str(gamma)+";signs="+num2istr(signs)
 	notestr = ReplaceStringByKey("AngleMapping", notestr, map_note,"=","\r")
 	Note/K image
 	Note image notestr
End
 


 
Static Function buttonMapPolarCut(ctrlName)
 	String ctrlName
 	
 	NVAR hn = root:internalUse:process:gv_hn
 	NVAR EF = root:internalUse:process:gv_EF
 	NVAR workfunc = root:internalUse:process:gv_workfunc
 	SVAR kpnts = root:internalUse:process:gs_kpnts
 	SVAR epnts = root:internalUse:process:gs_epnts
 	WAVE image = root:internalUse:panelcommon:w_image
 	
 	String m
 	sprintf m, "map polar cut: hn=%f; EF=%f; workfn=%f;epnts=%s;kpnts=%s",hn,EF,workfunc,epnts,kpnts
 	macro_add_process(m)
 	
 	String notestr = note(image)
 	
 	Variable ep = str2num(epnts)
 	Variable kp = str2num(kpnts)
 	if (numtype(ep) > 0)	// not a number -> auto-settings
 		ep = dimsize(image,1)
 	endif
 	if (numtype(kp) > 0)
 		kp = dimsize(image,0)
 	endif
 	
 	// 02-07-04: implemented check for initial state energy scaling
 	if (stringmatch(StringByKey("EnergyScale",notestr,"=","\r"),"*initial*"))
 		EF = 0
 	endif
 	
 	Variable Evac = hn - workfunc
 	
 	polar_to_k_parallel(image,Evac,EF,kp,ep)
 	new_panel_DCs(image, "process_panel")
 	
 	//String notestr = note(image)
 	String map_note = "EXACT;hn="+num2str(hn)+";EF="+num2str(EF)+";workfunction="+num2str(workfunc)
 	notestr = ReplaceStringByKey("AngleMapping", notestr, map_note,"=","\r")
 	Note/K image
 	Note image notestr
End





Static Function buttonCalcAvgWave(ctrlName)
	String ctrlName

	//SVAR name = root:internalUse:panelcommon:gs_TopItemName
	NVAR x0 = root:internalUse:process:gv_avg_x0
	NVAR x1 = root:internalUse:process:gv_avg_x1
	NVAR y0 = root:internalUse:process:gv_avg_y0
	NVAR y1 = root:internalUse:process:gv_avg_y1
	WAVE M = root:internalUse:panelcommon:w_image
	
	
	ControlInfo/w=process_panel bkg_cbkOfX
	Variable x_avg = v_value
	
	String avgPath = "root:internalUse:process:process_wave"
	Variable pnt1, pnt2, p1, p2
	
	String mstr
	if(x_avg)
		sprintf mstr, "calculate bkg k: y0=%f;y1=%f;x0=%f;x1=%f",x0,x1,y0,y1
		utils_getWaveAvg(M,0,from=y0,to=y1)
		WAVE w_avg
		pnt1 = x2pnt(w_avg, x0)
		pnt2 = x2pnt(w_avg, x1)
		w_avg[0,pnt1] = w_avg[pnt1]
		w_avg[pnt2,numpnts(w_avg)-1] = w_avg[pnt2]
	else
		sprintf mstr, "calculate bkg e: y0=%f;y1=%f;x0=%f;x1=%f",x0,x1,y0,y1
		utils_getWaveAvg(M,1,from=x0,to=x1)
		WAVE w_avg
		pnt1 = x2pnt(w_avg, y0)
		pnt2 = x2pnt(w_avg, y1)
		p1 = min(pnt1, pnt2)
		p2 = max(pnt1, pnt2)
		w_avg[0,p1] = w_avg[p1]
		w_avg[p2,numpnts(w_avg)-1] = w_avg[p2]
	endif
	macro_add_process(mstr)
	
	Duplicate/O w_avg $avgPath	// renew the current process wave
	
	KillWaves/Z w_avg
End




Static Function tabControlChange( name, tab )
	String name
	Variable tab
	
	// Get the name of the current tab
	ControlInfo $name
	String tabStr = S_Value
	tabStr = tabStr[0,2]
	
	// Get a list of all the controls in the window
	Variable i = 0
	String all = ControlNameList( "process_panel" )
	String thisControl
	
	do
		thisControl = StringFromList( i, all )
		if( strlen( thisControl ) <= 0 )
			break
		endif
		
		// Found another control.  Does it start with two letters and an underscore?
		if( !CmpStr( thisControl[3], "_" ) )
			// If it matches the current tab, show it.  Otherwise, hide it
			if( !CmpStr( thisControl[0,2], tabStr ) )
				utils_setControlEnabled( thisControl, 0 )
			else
				utils_setControlEnabled( thisControl, 1)
			endif
		endif
		i += 1
	while( 1 )
	
	String Df = GetDataFolder (1)
	
	// tab-specific adjustments
	
	switch( tab )
		case 0:
		case 3:
			buttonRemoveProcWave("dum")
			break
		case 1:
		case 2:
			buttonRemoveProcWave("dum")
			Button smo_breset, disable=0
			Button smo_bsaveAs, disable=0
			SetVariable smo_svsaveName, disable=0
			CheckBox smo_cboverwrite, disable=0
			break
		case 4:
			Button smo_breset, disable=0
			Button smo_bsaveAs, disable=0
			SetVariable smo_svsaveName, disable=0
			CheckBox smo_cboverwrite, disable=0
		case 5:				
			GroupBox bkg_gbpanelLooks, disable = 0
			Button bkg_bshowProcWave, disable = 0
			Button bkg_bremoveProcWave, disable = 0
			CheckBox bkg_cbkOfX, disable=0
			CheckBox bkg_cbeOfY, disable=0
			Button bkg_bsmooth,  disable=0
			SetVariable bkg_sv1, disable=0
			break
		case 6:
			Button smo_breset, disable=0
			Button smo_bsaveAs, disable=0
			SetVariable smo_svsaveName, disable=0
			CheckBox smo_cboverwrite, disable=0
				
			SetVariable sym_sv1, disable=0
			Button sym_b1,  disable=0
			break
		case 7:
			
			break
	endswitch
	
	SetDataFolder $DF
End




Static Function buttonDoDerivative(ctrlName)
	String ctrlName
	
	WAVE M = root:internalUse:panelcommon:w_image
	String add
	String notestr = note(M)
	String modifications = StringByKey("OtherModifications", notestr, "=", "\r")
	Variable dim
	
	if (stringmatch(ctrlName,"smo_bd_dx"))
		dim = 0
		add = "d/dx,"
		macro_add_process("derivative x")
	else
		dim = 1
		add = "d/dy,"
		macro_add_process("derivative y")
	endif
	Differentiate/DIM = (dim) M
	
	modifications += add
	notestr = ReplaceStringByKey("OtherModifications", notestr, modifications, "=", "\r")
	Note/K M
	Note M, notestr
	
	new_panel_DCs(M, "process_panel")
	KillWaves/Z m_source
End




// save the preview. In 'bkg.' and 'avg' cases the process wave is saved and the note is updated
Static Function buttonSaveProcessed(ctrlName)
	String ctrlName
	
	SVAR name = root:internalUse:process:gs_Mname
	WAVE M = root:internalUse:panelcommon:w_image
	WAVE w_proc = root:internalUse:process:process_wave
	
	ControlInfo/w=process_panel smo_cboverwrite
	String Path = utils_uniqueName(M,"root:carpets:processed:",name, v_value)
	
	String notestr = note(M)
	String proc_name, proc_Path
	
	ControlInfo process; Variable tab = v_value
	if (tab == 5 || tab == 4)
		if (tab == 4)	//bkg
			proc_name = name+"_bkg"
		elseif (tab == 5)	// avg
			ControlInfo bkg_cbkOfX 
			if (v_value)
				proc_name = name+"_Eavg"
			else
				proc_name = name+"_Kavg"
			endif
		endif
		proc_Path = utils_uniqueName(w_proc,"root:carpets:processed:ProcessWaves:",proc_name, 0)
		Duplicate/o w_proc $proc_Path
		notestr = ReplaceStringByKey("AverageWave", notestr, proc_Path, "=", "\r")
		Note/K M
		Note M, notestr
	endif
	
	Duplicate/o M $path

	// Need to execute this at the end of the command queue, because otherwise Igor
	// resets the image before it is saves and the user looses all his shiny new process
	// stuff:
	Execute/P/Q "process#buttonClearProcAndMacro(\"\")"
End




// energy scale on 'dispersion tab'
Static Function checkBoxSubAvgXorY(name,value)
	String name
	Variable value
	
	Variable checkVal
	strswitch (name)
		case "bkg_cbkOfX":
			checkVal= 0
			break
		case "bkg_cbeOfY":
			checkVal= 1
			break
	endswitch
	CheckBox bkg_cbkOfX,value= checkVal==0
	CheckBox bkg_cbeOfY,value= checkVal==1
	
	buttonCalcAvgWave("dum")
	buttonRemoveProcWave("dum")
End




Static Function buttonShowProcWave(ctrlname)
	String ctrlname
	
	RemoveFromGraph/z process_wave
	
	ControlInfo bkg_cbkOfX
	if (v_value)	//x
		AppendToGraph root:internalUse:process:process_wave
		//RemoveFromGraph n_mdc
	else
		AppendToGraph/T=edc_int/L=edc_en/VERT root:internalUse:process:process_wave
		//RemoveFromGraph n_edc_x	// this line causes igor to crash badly!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	endif
End




Static Function buttonRemoveProcWave(ctrlname)
	String ctrlname
	
	ControlInfo bkg_cbkOfX		// DCs
	if (v_value)	//x
		//AppendToGraph root:internalUse:panelcommon:n_mdc
		RemoveFromGraph/z process_wave
		//ModifyGraph rgb(n_mdc)=(1,16019,65535)
	else
		//AppendToGraph root:internalUse:panelcommon:n_edc_x vs root:internalUse:panelcommon:n_edc
		RemoveFromGraph/z process_wave
	endif
End




// calculates the preview. Does not update the note
Static Function buttonDoAverage(ctrlName)
	String ctrlName
	
	WAVE avg = root:internalUse:process:Process_Wave
	WAVE M = root:internalUse:panelcommon:w_image
	SVAR name = root:internalUse:process:gs_Mname
	
	if (waveexists(avg)==0)
		Abort "Please calculate the average wave first."
	endif
	
	ControlInfo bkg_cbkOfX
	if (v_value)
		macro_add_process("divide bkg k")
		M /= avg[p]
	else
		macro_add_process("divide bkg e")
		M /= avg[q]
	endif
End




// calculates the preview. Does not update the note
Static Function buttonDoSubBkg(ctrlName)
	String ctrlName
	
	WAVE avg = root:internalUse:process:Process_Wave
	WAVE M = root:internalUse:panelcommon:w_image
	SVAR name = root:internalUse:process:gs_Mname
	
	if (waveexists(avg)==0)
		Abort  "Use 'browse' to select a background-wave first."
	endif
			
	ControlInfo bkg_cbkOfX
	if (v_value)
		macro_add_process("bkg subtract k")
		M -= avg[p]
	else
		macro_add_process("bkg subtract e")
		M -= avg[q]
	endif
End




Static Function buttonSubBkgSmooth(ctrlName)
	String ctrlName
	
	WAVE avg = root:internalUse:process:Process_Wave
	NVAR pnts = root:internalUse:process:gv_bkgSmooth
	
	if (waveexists(avg)==0)
		Abort "Please calculate the average wave first."
	endif
	Smooth pnts, avg
	macro_add_process("smooth bkg wave: pnts="+num2str(pnts))
End	




Static Function buttonReadAvgMarquee(ctrlName)
	String ctrlName

	NVAR e0 = root:internalUse:process:gv_avg_y0
	NVAR e1 = root:internalUse:process:gv_avg_y1
	NVAR k0 = root:internalUse:process:gv_avg_x0
	NVAR k1 = root:internalUse:process:gv_avg_x1
	
	GetMarquee/K image_en, image_m
	if (v_flag == 0)
		Abort "You need to set a marquee first (this is the rectangle, you usually use to expand a graph)."
	endif
	e0 = V_bottom
	e1 = V_top
	k0 = V_left
	k1 = V_right
End




Static Function buttonsubBkgBrowse(ctrlName)
	String ctrlname
	
	SVAR path = root:internalUse:process:gs_bkgPath
	
	String cmd = "CreateBrowser prompt=\"select the background wave and click 'ok'\""
	execute cmd
	SVAR S_BrowserList=S_BrowserList
	
	NVAR V_Flag=V_Flag
	if(V_Flag==0)
		return -1
	endif
		
	path = StringFromList(0,s_browserList)
	macro_add_process("new bkg wave: path="+path)
	
	Duplicate/o $path root:internalUse:process:process_wave	
End




Static Function setVariableUpdateAxes(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	NVAR x0 = root:internalUse:process:gv_axes_x0
	NVAR x1 = root:internalUse:process:gv_axes_x1
	NVAR dx = root:internalUse:process:gv_axes_dx
	NVAR xcenter = root:internalUse:process:gv_axes_xcenter
	WAVE image = root:internalUse:panelcommon:w_image
	
	Variable xp = dimsize(image,0)
	Variable xc, pc

	if (stringmatch(varName,"gv_axes_x0") || stringmatch(varName,"gv_axes_x1"))	
		dx = (x1 - x0) / (xp - 1)
		xcenter = (x0 + x1) / 2
		ControlUpdate axe_svaxesDx
		ControlUpdate axe_svaxesXCenter
	else
		x0 = xcenter - (xp-1)/2 * dx
		x1 = xcenter + (xp-1)/2 * dx
		ControlUpdate axe_svaxesX0
		ControlUpdate axe_svaxesX1
	endif
	
	rescale_angles(x0,x1, image)
End




Static Function buttonRescaleToCsr(ctrlName)
	String ctrlName
	
	NVAR x0 = root:internalUse:process:gv_axes_x0
	NVAR x1 = root:internalUse:process:gv_axes_x1
	NVAR xcenter = root:internalUse:process:gv_axes_xcenter
	WAVE image = root:internalUse:panelcommon:w_image
	
	ControlInfo axe_svaxesCsrZero
	Variable csrZero = v_value
	
	if (strlen(csrWave(B)) > 0)
		x0 -= (xcsr(B)-csrZero)
		x1 -= (xcsr(B)-csrZero)
		xcenter = (x0 + x1) / 2
		ControlUpdate axe_svaxesX0
		ControlUpdate axe_svaxesX1
		ControlUpdate axe_svaxesDx
		
		rescale_angles(x0,x1, image)
	else
		DoAlert 0, "Please set cursor B on the graph."
		abort
	endif
	
End




Static Function buttonReducePnts(ctrlName)
	String ctrlName
	
	WAVE M = root:internalUse:panelcommon:w_image
	Variable xPoint = xcsr(B,"process_panel")
	Variable yPoint = vcsr(B,"process_panel")
	String add
	String notestr = note(M)
	String modifications = StringByKey("OtherModifications", notestr, "=", "\r")
	
	
	if (stringmatch (ctrlname,"smo_bredYPnts"))
		Matrix_y_reduce(M,1)
		macro_add_process("reduce points y");
		add = "y-red.,"
	else
		Matrix_x_reduce(M,1)
		macro_add_process("reduce points x");
		add = "x-red.,"
	endif
	
	modifications += add
	notestr = ReplaceStringByKey("OtherModifications", notestr, modifications, "=", "\r")
	Note/K M
	Note M, notestr
	
	new_panel_DCs(M,"process_panel")
	Cursor/I B, w_image, xPoint,yPoint
End




Static Function buttonSmoothPnts(ctrlName)
	String ctrlName

	NVAR xSmooth = root:internalUse:process:gv_xSmooth
	NVAR ySmooth = root:internalUse:process:gv_ySmooth
	WAVE M = root:internalUse:panelcommon:w_image
	String add
	String notestr = note(M)
	String modifications = StringByKey("OtherModifications", notestr, "=", "\r")
	
	Variable dim, pnts
	
	if (stringmatch(ctrlName,"smo_bsmoothXPnts"))
		dim = 0
		pnts = xSmooth
		add = "xSmooth:"+num2str(pnts)+","
		macro_add_process("smooth x: xsmooth="+num2str(xSmooth))
	else
		dim = 1
		pnts = ySmooth
		add = "ySmooth:"+num2str(pnts)+","
		macro_add_process("smooth y: ysmooth="+num2str(ySmooth))
	endif
	
	M_smooth(M,dim,pnts)
	
	modifications += add
	notestr = ReplaceStringByKey("OtherModifications", notestr, modifications, "=", "\r")
	Note/K M
	Note M, notestr
	
	new_panel_DCs(M, "process_panel")
End




Static Function buttonRescaleEnergy(ctrlName)
	String ctrlName
	
	NVAR EF = root:internalUse:process:gv_axes_EF
	WAVE image = root:internalUse:panelcommon:w_image

	if (waveexists(image))
		String notestr = note(image)
		Variable y0 = utils_y0(image)
		Variable y1 = utils_y1(image)
		String energyScale = StringByKey("EnergyScale", note(image), "=", "\r")
		if (stringmatch(ctrlName,"axe_bEkEi"))	// Ek to Ei
			if (stringmatch(energyScale, "Initial*"))
				Abort "Scaling appears to be already Initial scale. Cannot apply this operation to the same wave twice."
			endif
			notestr = ReplaceNumberByKey("FermiLevel", notestr, EF, "=", "\r")
			y0 -= EF
			y1 -= EF
			notestr = ReplaceStringByKey("EnergyScale", notestr, "Initial state", "=", "\r")
			macro_add_process("E_kin to E_initial: EF="+num2str(EF))
		else
			y0 = -y0
			y1 = -y1
			macro_add_process("E_binding <-> E_initial")
		endif
		Note/K image
		Note image, notestr
		SetScale/I y y0,y1,"" image
		
		new_panel_DCs(image, "process_panel")
	else
		return -1
	endif
End




//This function symmetrize the EDC with respect to the Ef, It is useful to check the existence of the gap. By Wei-Sheng 10/31/05
Static Function buttonEDCSymmetrize(ctrlName)
	String ctrlName
	
	WAVE M = root:internalUse:panelcommon:w_image
	Variable E_start, E_end, npnts, npnts_slice
	npnts_slice = dimsize(M,0)
	E_start = dimoffset(M,1)
	E_end = E_start + (dimsize(M,1)-1)*dimdelta(M,1)
	Duplicate/O M,M_p, M_n
	
	ControlInfo sym_sv1
	macro_add_process("symmetrization: E_F="+num2str(V_value))
	SetScale /I y (E_start-V_value), (E_end-V_value), M_p 
	SetScale /I y -1*(E_start-V_value), -1*(E_end-V_value), M_n
	npnts = 2 * ceil( abs(V_value-E_start)/dimdelta(M,1)) 
	redimension /N=(npnts_slice, npnts) M
	setscale /I y (E_start-V_value), -1* (E_start-V_value), M
	M = M_p(x)(y) + M_n(x)(y)
	
	new_panel_DCs(M, "process_panel")
	killwaves/Z M_n, M_p
End




Static Function buttonClearProcAndMacro(ctrlName) : ButtonControl
	String ctrlName
	WAVE/T w_process_macro = root:internalUse:process:w_process_macro
	Redimension/N=0 w_process_macro
	norm_resetImage(ctrlName)
End





Static Function buttonMacroApplySelected(ctrlName)
	String ctrlName

	WAVE/T w_process_macro = root:internalUse:process:w_process_macro
	NVAR gv_is_executing_macro = root:internalUse:process:gv_is_executing_macro
	gv_is_executing_macro = 1

 	NVAR hn = root:internalUse:process:gv_hn
	NVAR EF = root:internalUse:process:gv_EF
	NVAR workfunc = root:internalUse:process:gv_workfunc
	NVAR th = root:internaluse:process:gv_th
	NVAR ph = root:internaluse:process:gv_ph
	NVAR alpha = root:internaluse:process:gv_alpha
	NVAR omega = root:internaluse:process:gv_omega
	NVAR gamma = root:internaluse:process:gv_gamma
	NVAR signs = root:internaluse:process:gv_signs
	SVAR energyScale = root:internaluse:process:gs_energyScale
	NVAR lattice_a = root:internaluse:process:lattice_a

	SVAR kpnts = root:internalUse:process:gs_kpnts
	SVAR epnts = root:internalUse:process:gs_epnts

	NVAR x0 = root:internalUse:process:gv_avg_x0
	NVAR x1 = root:internalUse:process:gv_avg_x1
	NVAR y0 = root:internalUse:process:gv_avg_y0
	NVAR y1 = root:internalUse:process:gv_avg_y1

	NVAR xSmooth = root:internalUse:process:gv_xSmooth
	NVAR ySmooth = root:internalUse:process:gv_ySmooth

	NVAR pnts = root:internalUse:process:gv_bkgSmooth

	SVAR path = root:internalUse:process:gs_bkgPath

	NVAR gv_axes_EF = root:internalUse:process:gv_axes_EF
	
	NVAR gv_sym_e0 = root:internalUse:process:gv_sym_e0

	SVAR DF = root:internalUse:panelcommon:gs_currentDF
	SVAR pList = root:internalUse:panelcommon:gs_sourcePathList
	SVAR nList = root:internalUse:panelcommon:gs_sourceNameList
	SVAR topPath = root:internalUse:panelcommon:gs_TopItemPath
	SVAR topName = root:internalUse:panelcommon:gs_TopItemName
	String sourceNameList_copy = nList
	
	Variable i
	Variable map_flipstage_cut_warningAck = 0
	for (i = 0; i < ItemsInList(sourceNameList_copy); i+=1)

		pList = DF + StringFromList(i, sourceNameList_copy)
		topPath = pList
		nList = StringFromList(i, sourceNameList_copy)
		topName = nList
		process_panel_SLB_proc()
	
		WAVE M = root:internalUse:panelcommon:w_image
		SVAR Mname = root:internalUse:process:gs_Mname
		WAVE process_wave = root:internalUse:process:process_wave
		String MPath = utils_uniqueName(M,"root:carpets:processed:",Mname, 1)

		Variable j
		for (j = 0; j < numpnts(w_process_macro); j += 1)
			String cmd = utils_trimSpaces(StringFromList(0, w_process_macro[j], ":"))
			String par = utils_trimSpaces(StringFromList(1, w_process_macro[j], ":"))
			strswitch(cmd)
				case "map flipstage cut":
					hn = NumberByKey("hn", par, "=", ";")
					EF = NumberByKey("EF", par, "=", ";")
					workfunc = NumberByKey("workfn", par, "=", ";")
					th = NumberByKey("theta", par, "=", ";")
					ph = NumberByKey("phi", par, "=", ";")
					alpha = NumberByKey("alpha", par, "=", ";")
					gamma = NumberByKey("gamma", par, "=", ";")
					signs = NumberByKey("signs", par, "=", ";")
					lattice_a = NumberByKey("lattice_a", par, "=", ";")
					energyScale = StringByKey("energyscale", par, "=", ";")
					Variable eDep = NumberByKey("edep_check", par, "=", ";")
				 	CheckBox k_p_lattice_check, value=(NumberByKey("lattice_check", par, "=", ";"))
				 	CheckBox k_p_eDep_check, value=(eDep)
				 	if (eDep && map_flipstage_cut_warningAck == 0)
				 		map_flipstage_cut_warningAck = 1
				 		DoAlert 1, "Note that for the 'map flipstage cut' macro, I will use the *same* set of angles, energies, and settings for all waves, ignoring the angles of the individual waves. Is this what you want?"
				 		if (V_Flag == 2)
				 			utils_abort("Aborted by user")
				 		endif
				 	endif
				 	DoUpdate
					buttonMapFlipstageCut("k_p_b20")
					break
				case "map polar cut":
					hn = NumberByKey("hn", par, "=", ";")
					EF = NumberByKey("EF", par, "=", ";")
					workfunc = NumberByKey("workfn", par, "=", ";")
					epnts = StringByKey("epnts", par, "=", ";")
					kpnts = StringByKey("kpnts", par, "=", ";")
					buttonMapPolarCut("k_p_b10")
					break
				case "calculate bkg k":
					x0 = NumberByKey("x0", par, "=", ";")
					x1 = NumberByKey("x1", par, "=", ";")
					y0 = NumberByKey("y0", par, "=", ";")
					y1 = NumberByKey("y1", par, "=", ";")
					CheckBox bkg_cbkOfX, value=1
				 	DoUpdate
					buttonCalcAvgWave("avg_b1")
					break
				case "calculate bkg e":
					x0 = NumberByKey("x0", par, "=", ";")
					x1 = NumberByKey("x1", par, "=", ";")
					y0 = NumberByKey("y0", par, "=", ";")
					y1 = NumberByKey("y1", par, "=", ";")
					CheckBox bkg_cbkOfX, value=0
				 	DoUpdate
					buttonCalcAvgWave("avg_b1")
					break
				case "reduce points x":
					buttonReducePnts("smo_bredXPnts")
					break
				case "reduce points y":
					buttonReducePnts("smo_bredYPnts")
					break
				case "smooth x":
					xSmooth = NumberByKey("xsmooth", par, "=", ";")
					buttonSmoothPnts("smo_bsmoothXPnts")
					break
				case "smooth y":
					ySmooth = NumberByKey("ysmooth", par, "=", ";")
					buttonSmoothPnts("smo_bsmoothYPnts")
					break
				case "derivative x":
					buttonDoDerivative("smo_bd_dx")
					break
				case "derivative y":
					buttonDoDerivative("smo_bd_dy")
					break
				case "divide bkg k":
					CheckBox bkg_cbkOfX, value = 1
				 	DoUpdate
					buttonDoAverage("avg_b13")
					String proc_Path = utils_uniqueName(w_proc,"root:carpets:processed:ProcessWaves:",Mname+"_bkg", 1)
					Duplicate/o process_wave $proc_Path
					String notestr = note(M)
					notestr = ReplaceStringByKey("AverageWave", notestr, proc_Path, "=", "\r")
					Note/K M
					Note M, notestr
					break
				case "divide bkg e":
					CheckBox bkg_cbkOfX, value = 0
				 	DoUpdate
					buttonDoAverage("avg_b13")
					proc_Path = utils_uniqueName(w_proc,"root:carpets:processed:ProcessWaves:",Mname+"_bkg", 1)
					Duplicate/o process_wave $proc_Path
					notestr = note(M)
					notestr = ReplaceStringByKey("AverageWave", notestr, proc_Path, "=", "\r")
					Note/K M
					Note M, notestr
					break
				case "bkg subtract k":
					CheckBox bkg_cbkOfX, value = 1
				 	DoUpdate
					buttonDoSubBkg("bkg_b2")
					proc_Path = utils_uniqueName(w_proc,"root:carpets:processed:ProcessWaves:",Mname+"_Kavg", 1)
					Duplicate/o process_wave $proc_Path
					notestr = note(M)
					notestr = ReplaceStringByKey("AverageWave", notestr, proc_Path, "=", "\r")
					Note/K M
					Note M, notestr
					break
				case "bkg subtract e":
					CheckBox bkg_cbkOfX, value = 0
				 	DoUpdate
					buttonDoSubBkg("bkg_b2")
					proc_Path = utils_uniqueName(w_proc,"root:carpets:processed:ProcessWaves:",Mname+"_Eavg", 1)
					Duplicate/o process_wave $proc_Path
					notestr = note(M)
					notestr = ReplaceStringByKey("AverageWave", notestr, proc_Path, "=", "\r")
					Note/K M
					Note M, notestr
					break
				case "smooth bkg wave":
					pnts = NumberByKey("pnts", par, "=", ";")
					buttonSubBkgSmooth("bkg_bsmooth")
					break
				case "new bkg wave":
					path = StringByKey("path", par, "=", ";")
					Duplicate/o $path root:internalUse:process:process_wave
					break
				case "rescale angles":
					Variable ra_x0 = NumberByKey("x0", par, "=", ";")
					Variable ra_x1 = NumberByKey("x1", par, "=", ";")
					rescale_angles(ra_x0,ra_x1,root:internalUse:panelcommon:w_image)
					break
				case "E_kin to E_initial":
					gv_axes_EF = NumberByKey("EF", par, "=", ";")
					buttonRescaleEnergy("axe_bEkEi")
					break;
				case "E_binding <-> E_initial":
					buttonRescaleEnergy("axe_bEBEi")
					break;
				case "symmetrization":
					gv_sym_e0 = NumberByKey("E_F", par, "=", ";")
					buttonEDCSymmetrize("sym_b1")
					break;
			endswitch
		endfor
		Duplicate/o M $MPath
	endfor
	
	// Since I modified variables that are normally set by panelcommon_srcListboxProc(),
	// I have to call this again to make the variables right again. Note that row and col
	// are not used in this function. crtlName sould equal "waves_lb"
	// (i_panel_common.ipf:) panelcommon_srcListboxProc(ctrlname, row, col, event)
	panelcommon_srcListboxProc("waves_lb", 0, 0, 4)
	// Not sure if i have to call the following, since in theory, panelcommon_srcListboxProc() calls the _SLB_proc
	// of the top window if event == 4. Well, twice is better than none in this case:
	process_panel_SLB_proc()

//	buttonClearProcAndMacro("")

	gv_is_executing_macro = 0
End






















//////////////////////////////////////
//
// Private functions
// N.B.: the keyword "Static" in front of "Procedure" limits visibility to the containing Igor Procedure File only.
//
//////////////////////////////////////


























Static Function init()

	String DF = GetDataFolder (1)
	SetDataFolder root:carpets
	NewDataFolder/o/s processed
	NewDataFolder/o ProcessWaves
	SetDataFolder root:internalUse
	NewDataFolder/o/s process
	
	Variable/G gv_xSmooth = 2
	Variable/G gv_ySmooth = 5
	Variable/G gv_bkgSmooth = 25
	Variable/G gv_avg_x0, gv_avg_x1, gv_avg_y0, gv_avg_y1
	Variable/G gv_hn = 21.2
	Variable/G gv_EF = 16.7
	Variable/G gv_workfunc = 4.35
	String/G gs_energyScale = "kinetic"
	Variable/G gv_th
	Variable/G gv_ph
	Variable/G gv_alpha
	Variable/G gv_omega
	Variable/G gv_gamma
	Variable/G gv_signs = 0
	Variable/G gv_axes_x0
	Variable/G gv_axes_x1
	Variable/G gv_axes_dx
	Variable/G gv_axes_xcenter
	Variable/G gv_axes_csrZero = 0
	Variable/G gv_axes_EF
	Variable/G lattice_a     // this is added by Wei-Sheng   12/08/04
	Variable/G gv_sym_e0=0// By Wei-Sheng 10/31/05
	
	String/G gs_kpnts = "auto"
	String/G gs_epnts = "auto"
	String/G gs_Mname
	String/G gs_bkgPath = "_none"
	Make/O/T/N=0 w_process_macro
	Variable/G gv_is_executing_macro = 0
	
	SetDataFolder $DF
End
 



 
 // x-axis scaling is interpreted as polar angle (in degrees)
 // y-axis scaling has the direction of kinetic energy
 // Evac is the kinetic energy for electrons from the Fermi level													FB 01-14-04
Static Function polar_to_k_parallel(M,Evac,EF,xp,yp)
 	WAVE M; Variable Evac,EF,xp,yp
 	
 	// get the k-range:
 	Variable x0 = utils_x0(M)
 	Variable x1 = utils_x1(M)
 	Variable y0 = utils_y0(M)
 	Variable y1 = utils_y1(M)
 	Variable Evac_min = min(Evac + y0 - EF, Evac + y1 - EF)
 	Variable Evac_max = max(Evac + y0 - EF, Evac + y1 - EF)
 	Variable kmax, kmin
 	if (sign(x0) == sign(x1))
 		if (sign(x0) == 1)	// both positive
 			kmax = sin(max(x0,x1)*pi/180) * sqrt(Evac_max)*0.5123
 			kmin = sin(min(x0,x1)*pi/180) * sqrt(Evac_min)*0.5123
 		else		// both negative
 			kmax = sin(min(x0,x1)*pi/180) * sqrt(Evac_max)*0.5123
 			kmin = sin(max(x0,x1)*pi/180) * sqrt(Evac_min)*0.5123
 		endif
 	else
 		kmax = sin(max(x0,x1)*pi/180) * sqrt(Evac_max)*0.5123
 		kmin = sin(min(x0,x1)*pi/180) * sqrt(Evac_max)*0.5123
 	endif
 	
 	// find the values in the source for e/th that correspond to e/k
 	Make/o/n=(xp,yp) M_out 
 	CopyScales/I M, M_out
 	SetScale/I x kmin, kmax, M_out		
 	
 	//SetScale/I y y0,y1, M_out		
 	
 	M_out = interp2D(M,180/pi*asin(x/(sqrt(evac + y-EF)*0.5123)),y)
 	
 	// copy the note
 	String notestr = note(M)
 	Duplicate/o M_out M
 	Note M, notestr
 	KillWaves/Z M_out
End




// executed whenever one or more cells in the source list-boxes are selected
Static Function new_panel_DCs(w_image,panel)
	WAVE w_image; String panel
	
	String pDF = GetDataFolder (1)
	SetDataFolder root:internalUse:panelcommon

		Make/N=(dimsize(w_image,0))/O n_mdc, n_mdc2
		Make/N=(dimsize(w_image,1))/O n_edc, n_edc2, n_edc_x
		SetScale/I x, utils_x0(w_image),utils_x1(w_image), n_mdc, n_mdc2
		SetScale/I x, utils_y0(w_image),utils_y1(w_image), n_edc, n_edc2, n_edc_x
		n_edc_x = x
		
		Variable pPoint = pcsr(B,panel)
		Variable qPoint = qcsr(B,panel)
		n_mdc = w_image[p][qPoint]
		n_edc = w_image[pPoint][p]
		
	SetDataFolder $pDF
End




Static Function Matrix_y_reduce(M,flag)
	WAVE M; Variable flag
	
	Duplicate/o M m12
	Make/o/n=(dimsize(M,0)) cut
	Make/o/n=(dimsize(m,0),dimsize(M,1)/2) M_red
	Variable x0 = dimoffset(M,1) + dimdelta(M,1)/2
	Variable dx = 2* dimdelta(M,1)
	
	m12 = m+m[p][q-1]
	
	Variable index = 0
	do
		cut = m12[p][index+1]
		M_red[][index/2] = cut[p]
	index += 2
	while (index < dimsize(M,1))
	
	M_red/=2
	SetScale/P x dimoffset(M,0), dimdelta(M,0),"" M_red
	SetScale/P y x0, dx,"" M_red
	
	if (flag)
		Duplicate/o M_red M
		KillWaves/Z M_red
	endif
	
	KillWaves/Z m12, cut
End




Static Function Matrix_x_reduce(M,flag)
	WAVE M; Variable flag
	
	Duplicate/o M m12
	Make/o/n=(dimsize(M,1)) cut
	Make/o/n=(dimsize(m,0)/2,dimsize(M,1)) M_red
	Variable x0 = dimoffset(M,0) + dimdelta(M,0)/2
	Variable dx = 2* dimdelta(M,0)
	
	m12 = m+m[p-1][q]
	
	Variable index = 0
	do
		cut = m12[index+1][p]
		M_red[index/2][] = cut[q]
	index += 2
	while (index < dimsize(M,0))
	
	M_red/=2
	SetScale/P x x0, dx,"" M_red
	SetScale/P y dimoffset(M,1), dimdelta(M,1),"" M_red
	
	if (flag)
		Duplicate/o M_red M
		KillWaves/Z M_red
	endif
	
	KillWaves/Z m12, cut
End





Static Function M_smooth(M,dim,pnts)
	WAVE M; Variable dim, pnts
	
	Make/o/N=(dimsize(M,dim)) cut
	SetScale/P x dimoffset(M,dim), dimdelta(M,dim),"" cut
	
	Variable index = 0
	if (dim == 0)
		do
			cut = M[p][index]
			Smooth pnts, cut
			M[][index] = cut[p]
		index += 1
		while (index < dimsize(M,1))
	elseif (dim == 1)
		do
			cut = M[index][p]
			Smooth pnts, cut
			M[index][] = cut[q]
		index += 1
		while (index < dimsize(M,0))
	else
		KillWaves/Z cut
		return -1
	endif
	KillWaves/Z cut
End




Static Function rescale_angles(x0,x1,M)
	Variable x0, x1; WAVE M
	
	if (waveexists(M))
		String notestr = note(M)
		String modified = "rescaled x-axis from "+num2str(x0)+" to "+ num2str(x1)
		notestr = ReplaceStringByKey("OtherModifications", notestr, modified, "=", "\r")
		Note/K M
		Note M, notestr
		SetScale/I x x0,x1,"" M
		macro_add_process("rescale angles: x0="+num2str(x0)+";x1="+num2str(x1))
		
		new_panel_DCs(M, "process_panel")
	else
		return -1
	endif
End




Static Function macro_add_process(process)
	String process
	NVAR gv_is_executing_macro = root:internalUse:process:gv_is_executing_macro
	if (gv_is_executing_macro) // we are already in macro execution mode. Don't add anything to avoid recursions
		return 0
	endif
	WAVE/T w_process_macro = root:internalUse:process:w_process_macro
	Variable size = numpnts(w_process_macro)
	Redimension/N=(size+1) w_process_macro
	w_process_macro[size] = process
End
