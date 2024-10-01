#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 0.01

Function /DF init_process()
	DFREf DF = GetDataFolderDFR()
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetDatafolder DFR_panel
	DFREF DF_common=$(DF_panel+":panel_common")
	
	NewDataFolder/O/S process
	DFREF DFR_proc=GetDatafolderDFR()	
	
	SetDatafolder DFR_proc
	
	Variable/G gv_input_Energy=0
	Variable/G gv_input_angle0=0
	Variable/G gv_input_angle1=0
	
	//Variable/G gv_csr_m0
	//Variable/G gv_csr_m1	// the cursor values on the graph
	Variable/G gv_csr_set=0
	Variable/G gv_scale_ratio=1
	
	Variable/G gv_axes_x0
	Variable/G gv_axes_x1
	Variable/G gv_axes_dx
	Variable/G gv_polyfit_num=3
	Variable/G gv_Fermibkg_Ef=0
	Variable/G gv_Fermibkg_T=15
	Variable/G gv_Fermibkg_res=0.005
	Variable/G gv_Fermibkg_num=4
	
	Variable/G gv_procwaveflag=0
	Make /o/n=(0,2)/t w_procwavelist
	String /G gs_procwavepath=""
	
	Variable/G gv_nonlinear_flag=0
	
	if (Datafolderexists(DFS_global+"proc_wave")==0)
		newDatafolder /o $(DFS_global+"proc_wave")
	endif
	
	make /o/n=1 w_coef
	make /T/o/n=0 w_Macrolist1,w_Macrolist2
		
	Variable/G gv_xSmooth = 2
	Variable/G gv_ySmooth = 2
	Variable/G gv_reducefactor = 2
	String /G gs_procstr_disp
	String /G gs_procstr1,gs_procstr2
	
	Variable /G gv_MDCweight=1
	Variable /G gv_curveFactor=0.1
	
	Variable/G gv_symef=0
	
	SetDataFolder DF
	return DFR_proc
End
 
 
Function add_Tab_process()
	DFREF DF=GetDatafolderDFR()

	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")

	DFREF DFR_proc=init_process()

	SetDatafolder DFR_Proc

	Variable r=57000, g=57000, b=57000

	Variable SC=Screensize(5)

//	GroupBox Scale_gb11, frame=0, labelBack=0, pos={230*SC,35*SC}, size={400*SC,70*SC}, title="angles_shift" , disable=1
//	SetVariable Scale_sv10, pos={235*SC,55*SC}, size={95*SC,15*SC}, labelBack=(r,g,b), limits={-inf,inf,0}, title="Set to:", value=gv_csr_Set, disable=1//proc=Proc_angle_change
//	//SetVariable Scale_sv11, pos={325,55}, size={85,15}, labelBack=(r,g,b), fsize=12, limits={-inf,inf,0}, title="Red ", value=gv_csr_m1, disable=1//,proc=Proc_angle_change
//	//Button Scale_b2, labelBack=(r,g,b), pos={415,55}, size={40,18}, title="G->0", proc=rescale_axes, disable=1
//	Button Scale_b3, labelBack=(r,g,b), pos={340*SC,53*SC}, size={60*SC,18*SC}, title="Center->", proc=rescale_axes, disable=1
//	Button Scale_b5, labelBack=(r,g,b), pos={400*SC,53*SC}, size={50*SC,18*SC}, title="Green->", proc=rescale_axes, disable=1
//	Button Scale_b6, labelBack=(r,g,b), pos={450*SC,53*SC}, size={40*SC,18*SC}, title="Red->", proc=rescale_axes, disable=1
//	//Button Scale_b4, labelBack=(r,g,b), pos={565,55}, size={60,18}, title="Set R+G", proc=rescale_axes, disable=1
//
//	SetVariable Scale_sv12, pos={235*SC,80*SC}, size={80*SC,15*SC}, labelBack=(r,g,b), limits={-inf,inf,0}, title="start", value=gv_axes_x0, disable=1,proc=Proc_setvariable_updatevar
//	SetVariable Scale_sv13, pos={320*SC,80*SC}, size={80*SC,15*SC}, labelBack=(r,g,b), limits={-inf,inf,0}, title="end",  value=gv_axes_x1, disable=1,proc=Proc_setvariable_updatevar
//	SetVariable Scale_sv14, pos={405*SC,80*SC}, size={85*SC,15*SC}, labelBack=(r,g,b), limits={-inf,inf,0}, title="delta", value=gv_axes_dx, disable=1,proc=Proc_setvariable_updatevar
//	Button Scale_b11, labelBack=(r,g,b), pos={495*SC,78*SC}, size={50*SC,18*SC}, title="Set", proc=rescale_axes, disable=1
//
//	//GroupBox Scale_gb2,frame=1, labelBack=(r,g,b), pos={540,35}, size={90,105}, title="angle Scale", fsize=11, disable=1
//
//	Checkbox Scale_ck0,pos={495*SC,55*SC}, size={100*SC,15*SC}, labelBack=(r,g,b), title="Scale?",value=0,disable=1
//	//Checkbox Scale_ck1,pos={545,70}, size={80,15}, labelBack=(r,g,b), fsize=12, title="ratio",value=1,disable=1
//	SetVariable Scale_sv15, pos={555*SC,53*SC}, size={70*SC,18*SC}, labelBack=(r,g,b), limits={-inf,inf,0}, title="R:", value=gv_scale_ratio, disable=1,proc=Proc_setvariable_updatevar
//	Button Scale_b12, labelBack=(r,g,b), pos={555*SC,78*SC}, size={70*SC,18*SC}, title="Set Ratio", proc=rescale_axes, disable=1
////	Button Scale_b16, labelBack=(r,g,b), pos={545*SC,153*SC}, size={80*SC,18*SC}, title="Use profile", proc=rescale_axes, disable=1
//
//	GroupBox Scale_gb3,frame=0, labelBack=(r,g,b), pos={430*SC,105*SC}, size={200*SC,40*SC}, frame=0,title="find MDC Peak", disable=1
//	Button Scale_b13, labelBack=(r,g,b), pos={440*SC,125*SC}, size={80*SC,18*SC}, title="MDC Peaks", proc=ScaleFindpeaks, disable=1
//	Button Scale_b14, labelBack=(r,g,b), pos={530*SC,125*SC}, size={40*SC,18*SC}, title="Green", proc=ScaleFindpeaks, disable=1
//	Button Scale_b15, labelBack=(r,g,b), pos={570*SC,125*SC}, size={40*SC,18*SC}, title="Red", proc=ScaleFindpeaks, disable=1
//
//
//
//	GroupBox Scale_gb1, frame=0, labelBack=(r,g,b), pos={230*SC,105*SC}, size={190*SC,80*SC}, frame=0,title="Energy_adjust", disable=1
//	Button Scale_b17, labelBack=(r,g,b), pos={240*SC,123*SC}, size={100*SC,18*SC}, title="Auto Find Ef", proc=Scale_AutoFindEf, disable=1
//	Button Scale_b0, pos={350*SC,145*SC}, size={60*SC,18*SC},labelBack=(r,g,b),  title="Set EF", proc=rescale_energy, disable=1
//	SetVariable Scale_sv0, pos={240*SC,145*SC}, size={100*SC,15*SC}, labelBack=(r,g,b), limits={-inf,inf,0}, title="EF=", value=gv_csr_e, proc=Proc_setvariable_energychange,disable=1
//	SetVariable Scale_sv1, pos={240*SC,165*SC}, size={100*SC,15*SC}, labelBack=(r,g,b), limits={-inf,inf,0}, title="E_Green=", value=gv_input_Energy,disable=1
//	Button Scale_b1, labelBack=(r,g,b), pos={350*SC,165*SC}, size={60*SC,18*SC}, title="SetEnergy", proc=rescale_energy, disable=1
//
//
//	Button Scale_b9, pos={503*SC,170*SC},size={60*SC,18*SC}, labelback=(r,g,b),title="undo", disable=1, proc=undo_image
//	Button Scale_b10, pos={566*SC,170*SC},size={60*SC,18*SC}, labelback=(r,g,b),title="reset", disable=1, proc=reset_image
//
	Button bkg_b8, pos={503*SC,150*SC},size={60*SC,18*SC}, labelback=(r,g,b),title="Substract", disable=1, proc=Proc_bkg_image
	Button bkg_b9, pos={503*SC,170*SC},size={60*SC,18*SC}, labelback=(r,g,b),title="undo", disable=1, proc=undo_image
	Button bkg_b10, pos={566*SC,170*SC},size={60*SC,18*SC}, labelback=(r,g,b),title="reset", disable=1, proc=reset_image

	Groupbox bkg_gp0, frame=0, labelBack=(r,g,b), pos={430*SC,35*SC}, size={200*SC,105*SC}, title="from wave", disable=1
	Listbox bkg_lb0, labelBack=(r,g,b), widths={150,50},pos={435*SC,50*SC}, size={140*SC,60*SC},mode=2,listwave=w_procwavelist,disable=1,proc=Proc_listbox_procwave
	Button bkg_bt0, labelBack=(r,g,b), pos={580*SC,50*SC}, size={40*SC,20*SC}, title="Disp",disable=1,proc=Proc_bt_Procwave
	Button bkg_bt1, labelBack=(r,g,b), pos={580*SC,75*SC}, size={40*SC,20*SC}, title="Del",disable=1,proc=Proc_bt_Procwave
	
	//Groupbox Norm_gp3, frame=0, labelBack=(r,g,b), pos={430*SC,95*SC}, size={200*SC,40*SC}, title="from wave", disable=1
	
	checkbox bkg_ck11, pos={440*SC,117*SC},size={45*SC,18*SC}, labelback=(r,g,b),title="EDC",disable=1,proc=Proc_checkbox_ProcWchange
	checkbox bkg_ck21, pos={490*SC,117*SC},size={45*SC,18*SC}, labelback=(r,g,b),title="MDC", disable=1,proc=Proc_checkbox_ProcWchange
	checkbox  bkg_ck31, pos={540*SC,117*SC},size={45*SC,18*SC}, labelback=(r,g,b),title="2D", disable=1,proc=Proc_checkbox_ProcWchange
	checkbox  bkg_ck41, pos={580*SC,108*SC},size={45*SC,15*SC}, labelback=(r,g,b),title="Ch", disable=1,proc=Proc_checkbox_ProcPchange
	checkbox  bkg_ck51, pos={580*SC,123*SC},size={45*SC,15*SC}, labelback=(r,g,b),title="scale", value=1,disable=1,proc=Proc_checkbox_ProcPchange
	
	//CheckBox Norm_c1, pos={310*SC,30*SC}, title=" ",labelBack=(r,g,b), mode=0, disable=1, proc=Proc_checkbox_Norm
	
	GroupBox Norm_gb1, pos={230*SC,35*SC}, size={195*SC,105*SC}, title="from data", frame=0, disable=1
	checkBox Norm_c3, pos={245*SC,55*SC}, title="MDC:",labelBack=(r,g,b), value=1, disable=1,proc=Proc_checkbox_changeDCs
	SetVariable Norm_sv0,labelBack=(r,g,b), pos={290*SC,55*SC},size={55*SC,15*SC}, limits={-inf,inf,0}, title=" ",frame=1,live=1,value=DFR_common:gv_E0,proc=Proc_setvariable_energychange, disable=1
	SetVariable Norm_sv1,labelBack=(r,g,b), pos={350*SC,55*SC},size={65*SC,15*SC}, limits={-inf,inf,0}, title="-",frame=1,live=1,value=DFR_common:gv_E1,proc=Proc_setvariable_energychange, disable=1
	checkBox Norm_c4, pos={245*SC,75*SC}, title="EDC:",labelBack=(r,g,b), value=0, disable=1,proc=Proc_checkbox_changeDCs
	SetVariable Norm_sv4,labelBack=(r,g,b), pos={290*SC,75*SC},size={55*SC,15*SC}, limits={-inf,inf,0}, title=" ",frame=1,value=DFR_common:gv_M0,proc=Proc_setvariable_energychange, disable=1
	SetVariable Norm_sv5,labelBack=(r,g,b), pos={350*SC,75*SC},size={65*SC,15*SC}, limits={-inf,inf,0}, title="-",frame=1,value=DFR_common:gv_M1,proc=Proc_setvariable_energychange, disable=1
	TitleBox Norm_t5, pos={245*SC,117*SC}, size={80*SC,12*SC}, labelback=(r,g,b), frame=0,title="default", disable=1
	Button Norm_b5, pos={290*SC,115*SC}, size={40*SC,18*SC}, labelback=(r,g,b), title="low", proc=default_E0E1, disable=1
	Button Norm_b6, pos={340*SC,115*SC}, size={40*SC,18*SC}, labelback=(r,g,b), title="high", proc=default_E0E1, disable=1
	SetVariable Norm_sv2,labelBack=(r,g,b), pos={265*SC,95*SC},size={105*SC,15*SC}, limits={-inf,inf,1}, title="smooth pnts",frame=1,value= gv_tmfsmt,proc=Proc_setvariable_smoothchange,disable=1
	SetVariable Norm_sv3,labelBack=(r,g,b), pos={370*SC,95*SC},size={50*SC,15*SC}, limits={-inf,inf,1}, title="x",frame=1,value= gv_tmfsmtrep,proc=Proc_setvariable_smoothchange, disable=1
	checkBox Norm_c2, pos={245*SC,95*SC}, title="",labelBack=(r,g,b), value=1, disable=1,proc=Proc_checkbox_smoothchange

	
	GroupBox Norm_gb01, frame=0, labelBack=(r,g,b), pos={230*SC,135*SC}, size={255*SC,55*SC}, title="from Func", disable=1
	
	checkbox Norm_ck11, pos={240*SC,152*SC},size={45*SC,18*SC}, labelback=(r,g,b),title="const", value=1,disable=1,proc=Proc_checkbox_fitchange
	checkbox Norm_ck21, pos={290*SC,152*SC},size={45*SC,18*SC}, labelback=(r,g,b),title="linear", disable=1,proc=Proc_checkbox_fitchange
	checkbox  Norm_ck31, pos={240*SC,170*SC},size={40*SC,18*SC}, labelback=(r,g,b),title="poly", disable=1,proc=Proc_checkbox_fitchange
	SetVariable Norm_sv01, pos={290*SC,170*SC}, size={30*SC,15*SC}, labelBack=(r,g,b), limits={3,20,1}, title=" ", value=gv_polyfit_num,disable=1

	Button Norm_b01, pos={340*SC,152*SC},size={50*SC,18*SC}, labelback=(r,g,b),title="Fit", disable=1, proc=Bkg_Func_fit
	Button Norm_b11, pos={390*SC,152*SC},size={50*SC,18*SC}, labelback=(r,g,b),title="Remove", disable=1, proc=Bkg_Func_fit
	CheckBox Norm_ck01, pos={440*SC,152*SC}, size={65*SC,15*SC},title="Csr",labelBack=(r,g,b), mode=0, disable=1//, proc=c_bkg_Proc
	
	//The following three lines were commented out by W. S. Lee, 01/090/2022
	//CheckBox Norm_ck02, pos={340*SC,170*SC}, size={65*SC,15*SC},title="Fermi",labelBack=(r,g,b), mode=0, disable=1//, proc=c_bkg_Proc
	//SetVariable Norm_sv02, pos={390*SC,170*SC}, size={45*SC,15*SC}, labelBack=(r,g,b), limits={-inf,inf,0}, title="Ef:", value=gv_Fermibkg_Ef,disable=1
	//SetVariable Norm_sv03, pos={440*SC,170*SC}, size={40*SC,15*SC}, labelBack=(r,g,b), limits={0,inf,0}, title="T:", value=gv_Fermibkg_res,disable=1

	Button Norm_b7, pos={503*SC,150*SC},size={30*SC,18*SC}, labelback=(r,g,b),title="Div", disable=1, proc=Proc_Norm_image
	Button Norm_b8, pos={535*SC,150*SC},size={30*SC,18*SC}, labelback=(r,g,b),title="Mult", disable=1, proc=Proc_Norm_image
	Button Norm_b9, pos={503*SC,170*SC},size={60*SC,18*SC}, labelback=(r,g,b),title="undo", disable=1, proc=undo_image
	Button Norm_b10, pos={566*SC,170*SC},size={60*SC,18*SC}, labelback=(r,g,b),title="reset", disable=1, proc=reset_image

//	GroupBox kplot_gb0, frame=0, labelBack=(r,g,b), pos={230*SC,35*SC}, size={188*SC,60*SC}, title="Energies (eV)",  disable=1
//	SetVariable kplot_sv0,labelBack=(r,g,b), pos={237*SC,53*SC},size={75*SC,15*SC}, limits={0,200,0}, title="hn: ",frame=1,noedit=1,value= DFR_common:gv_hn, disable=1
//	SetVariable kplot_sv1,labelBack=(r,g,b), pos={322*SC,53*SC},size={85*SC,15*SC}, limits={0,200,0}, title="Ef: ",frame=1,noedit=1,value= DFR_common:gv_EF, disable=1
//	SetVariable kplot_sv2,labelBack=(r,g,b), pos={237*SC,73*SC},size={75*SC,15*SC}, limits={0,200,0}, title="wf: ",frame=1,noedit=1,value= DFR_common:gv_workfunc, disable=1
//	SetVariable kplot_sv3,labelBack=(r,g,b), pos={322*SC,73*SC},size={85*SC,15*SC}, limits={0,200,0}, title="Inner: ",frame=1,noedit=1,value= DFR_common:gv_innerE, disable=1
//	
//      //GroupBox kplot_gb10, frame=1, labelBack=(r,g,b), pos={403,85}, size={90,100}, title="polar cuts", fsize=10, disable=1
//      //SetVariable kplot_sv10,labelBack=(r,g,b), pos={237,110},size={75,15}, limits={0,100,0}, title="k-pnts",frame=1,fsize=10,value= gs_kpnts, disable=1
//      //SetVariable kplot_sv11,labelBack=(r,g,b), pos={237,130},size={75,15}, limits={0,100,0}, title="e-pnts",frame=1,fsize=10,value= gs_epnts, disable=1
//	Button kplot_b10, labelBack=(r,g,b), pos={353*SC,170*SC}, size={60*SC,18*SC}, title="Polar", proc=map_polar_cut, disable=1
//	Button kplot_b10, help={"Maps polar cuts to k. Uses correct energy dependence of the vacuum wave vector."}
//	
//	GroupBox kplot_gb20, labelBack=(r,g,b), pos={425*SC,35*SC}, size={205*SC,80*SC}, title="flip-stage cuts", frame=0,disable=1
//	SetVariable kplot_sv20,labelBack=(r,g,b), pos={437*SC,55*SC},size={65*SC,15*SC}, limits={-100,100,0}, title="th",frame=1,noedit=1,value= DFR_common:gv_th, disable=1
//	SetVariable kplot_sv21,labelBack=(r,g,b), pos={437*SC,73*SC},size={65*SC,15*SC}, limits={-100,100,0}, title="ph",frame=1,noedit=1,value= DFR_common:gv_ph, disable=1
//	SetVariable kplot_sv22,labelBack=(r,g,b), pos={437*SC,91*SC},size={65*SC,15*SC}, limits={-100,100,0}, title="azi",frame=1,noedit=1,value= DFR_common:gv_alpha, disable=1
//	SetVariable kplot_sv24,labelBack=(r,g,b), pos={507*SC,55*SC},size={60*SC,15*SC}, limits={-100,100,0}, title="off",frame=1,noedit=1,value= DFR_common:gv_thoff, disable=1
//	SetVariable kplot_sv25,labelBack=(r,g,b), pos={507*SC,73*SC},size={60*SC,15*SC}, limits={-100,100,0}, title="off",frame=1,noedit=1,value= DFR_common:gv_phoff, disable=1
//	SetVariable kplot_sv26,labelBack=(r,g,b), pos={507*SC,91*SC},size={60*SC,15*SC}, limits={-100,100,0}, title="off",frame=1,noedit=1,value= DFR_common:gv_azioff, disable=1
//	
//	SetVariable kplot_sv23,labelBack=(r,g,b), pos={572*SC,55*SC},size={55*SC,15*SC}, limits={0,100,0}, title="Slit",frame=1,noedit=1,value= DFR_common:gv_gamma, disable=1
//	checkbox kplot_ck27,labelBack=(r,g,b), pos={572*SC,73*SC},size={55*SC,15*SC}, limits={-100,100,0}, title="Curve",variable= DFR_common:gv_curveflag, disable=1
//	
//	Button kplot_b20, labelBack=(r,g,b), pos={426*SC,170*SC}, size={60*SC,18*SC}, title="Flip", proc=map_flipStage_cut, disable=1
//	Button kplot_b20, help={"Assumes a linear cut in k-space and ingores the energy dependence of the vacuum wave vector (projects onto a radial k// coordinate)."}
//	//Button kplot_b21, labelBack=(r,g,b), pos={430,90}, size={70,16}, title="crop", proc=cropMerged, disable=1
//
//	Button kplot_b99, pos={503*SC,170*SC},size={60*SC,18*SC}, labelback=(r,g,b),title="undo", disable=1, proc=undo_image
//	Button kplot_b109, pos={566*SC,170*SC},size={60*SC,18*SC}, labelback=(r,g,b),title="reset", disable=1, proc=reset_image
//


	GroupBox proc_gb0, frame=0, labelBack=(r,g,b), pos={230*SC,35*SC}, size={180*SC,60*SC}, title="reduce points", disable=1
	SetVariable proc_sv9,labelBack=(r,g,b), pos={240*SC,62*SC},size={80*SC,15*SC}, limits={0,inf,1}, title="factor",frame=1,value= gv_reducefactor, disable=1
	Button proc_b0, pos={330*SC,52*SC}, size={65*SC,18*SC}, labelBack=(r,g,b), title="y-points", proc = reduce_pnts, disable=1
	Button proc_b1, pos={330*SC,72*SC}, size={65*SC,18*SC}, labelBack=(r,g,b), title="x-points", proc = reduce_pnts, disable=1
	
	GroupBox proc_gb10, frame=0, labelBack=(r,g,b), pos={230*SC,95*SC}, size={180*SC,60*SC}, title="smooth",disable=1
	SetVariable proc_sv10,labelBack=(r,g,b), pos={240*SC,115*SC},size={80*SC,15*SC}, limits={0,100,1}, title="x-pnts:",frame=1,value= gv_xSmooth, disable=1
	SetVariable proc_sv11,labelBack=(r,g,b), pos={240*SC,135*SC},size={80*SC,15*SC}, limits={0,100,1}, title="y-pnts:",frame=1,value= gv_ySmooth, disable=1
	Button proc_b10, pos={330*SC,113*SC}, size={65*SC,18*SC}, labelBack=(r,g,b), title="x-smooth", proc = smooth_xORy, disable=1
	Button proc_b11, pos={330*SC,133*SC}, size={65*SC,18*SC}, labelBack=(r,g,b), title="y-smooth", proc = smooth_xORy, disable=1

	GroupBox proc_gb2, frame=0, labelBack=(r,g,b),pos={420*SC,35*SC}, size={195*SC,60*SC}, title="crop",  disable=1
	Button proc_b5, pos={430*SC,50*SC},size={65*SC,18*SC}, labelback=(r,g,b),title="x_crop", disable=1, proc=crop_image
	Button proc_b6, pos={520*SC,50*SC},size={65*SC,18*SC}, labelback=(r,g,b),title="y_crop", disable=1, proc=crop_image
	Button proc_b7, pos={430*SC,70*SC},size={65*SC,18*SC}, labelback=(r,g,b),title="both", disable=1, proc=crop_image
	Button proc_b8, pos={520*SC,70*SC},size={65*SC,18*SC}, labelback=(r,g,b),title="smart", disable=1, proc=crop_image
	
	GroupBox proc_gb20, frame=0, labelBack=(r,g,b), pos={420*SC,95*SC}, size={195*SC,72*SC}, title="derivative & curvature",disable=1
	Button proc_b20, pos={430*SC,113*SC}, size={50*SC,18*SC}, labelBack=(r,g,b), title="d/dx", proc = M_derivative, disable=1
	Button proc_b21, pos={430*SC,131*SC}, size={50*SC,18*SC}, labelBack=(r,g,b), title="d/dy", proc = M_derivative, disable=1
	Button proc_b22, pos={430*SC,149*SC}, size={50*SC,18*SC}, labelBack=(r,g,b), title="d/dxdy", proc = M_derivative, disable=1
	SetVariable proc_sv22,labelBack=(r,g,b), pos={485*SC,149*SC},size={70*SC,15*SC}, limits={-inf,inf,0}, title="Ix:",frame=1,value= gv_MDCweight, disable=1
	SetVariable proc_sv23,labelBack=(r,g,b), pos={485*SC,131*SC},size={70*SC,15*SC}, limits={-inf,inf,0}, title="A0:",frame=1,value= gv_curveFactor, disable=1
	Button proc_b23, pos={560*SC,113*SC}, size={50*SC,18*SC}, labelBack=(r,g,b), title="Cx", proc = M_curvature, disable=1
	Button proc_b24, pos={560*SC,131*SC}, size={50*SC,18*SC}, labelBack=(r,g,b), title="Cy", proc = M_curvature, disable=1
	Button proc_b25, pos={560*SC,149*SC}, size={50*SC,18*SC}, labelBack=(r,g,b), title="C2D", proc = M_curvature, disable=1
	
	Button proc_b99, pos={503*SC,170*SC},size={60*SC,18*SC}, labelback=(r,g,b),title="undo", disable=1, proc=undo_image
	Button proc_b109, pos={566*SC,170*SC},size={60*SC,18*SC}, labelback=(r,g,b),title="reset", disable=1, proc=reset_image

//	GroupBox proc_gb3,frame=0,labelBack=(r,g,b), pos={230*SC,155*SC}, size={180*SC,35*SC}, title="Symmetrize",  disable=1
//	SetVariable proc_sv21,labelBack=(r,g,b), pos={240*SC,170*SC},size={70*SC,15*SC}, limits={-inf,inf,0}, title="Ef:",frame=1,value= gv_symef, disable=1
//	Button proc_b209, pos={320*SC,170*SC},size={85*SC,18*SC}, labelback=(r,g,b),title="Symmetrize", disable=1, proc=Sym_image

//	GroupBox Corr_gb2, frame=0, labelBack=(r,g,b), pos={230*SC,35*SC}, size={190*SC,110*SC}, title="from Fermi", disable=1
//	checkbox Corr_ck4, frame=0, pos={235*SC,55*SC},size={60*SC,18*SC}, labelback=(r,g,b),title="Fermi:", disable=1,proc=proc_Checkbox_Fermsel
//	SetVariable Corr_sv10, pos={290*SC,55*SC}, size={60*SC,15*SC}, labelBack=(r,g,b), limits={-inf,inf,0}, title="EF=", value=gv_Fermibkg_Ef,disable=1,Proc=Proc_Fermisv_change
//	SetVariable Corr_sv11, pos={355*SC,55*SC}, size={60*SC,15*SC}, labelBack=(r,g,b), limits={0,inf,0}, title="T=", value=DFR_common:gv_sampletem,disable=1,Proc=Proc_Fermisv_change
//	checkbox Corr_ck5, pos={235*SC,75*SC}, size={60*SC,15*SC}, labelBack=(r,g,b), title="convolve?", value=1,disable=1,Proc=Proc_Fermick_change
//	SetVariable Corr_sv12, pos={325*SC,75*SC}, size={90*SC,15*SC}, labelBack=(r,g,b), limits={0,inf,0}, title="FWHM=", value=gv_Fermibkg_res,disable=1,Proc=Proc_Fermisv_change
//	
//	checkbox Corr_ck6, pos={235*SC,95*SC}, size={60*SC,15*SC}, labelBack=(r,g,b), title="cropkBT?", value=1,disable=1//,Proc=Proc_Fermick_change
//	SetVariable Corr_sv13, pos={325*SC,95*SC}, size={90*SC,15*SC}, labelBack=(r,g,b), limits={0,inf,0}, title="num=", value=gv_Fermibkg_num,disable=1//,Proc=Proc_Fermisv_change
//	
//	Button Corr_bt0, pos={235*SC,120*SC},size={70*SC,18*SC},labelBack=(r,g,b),title="DivideFM",disable=1,proc=Proc_DF_image
//	Button Corr_bt1, pos={315*SC,120*SC},size={70*SC,18*SC},labelBack=(r,g,b),title="MultiFM",disable=1,proc=Proc_DF_image
//	Button Corr_b99, pos={503*SC,170*SC},size={60*SC,18*SC}, labelback=(r,g,b),title="undo", disable=1, proc=undo_image
//	Button Corr_b109, pos={566*SC,170*SC},size={60*SC,18*SC}, labelback=(r,g,b),title="reset", disable=1, proc=reset_image
//	
//	GroupBox Corr_gb1, frame=0, labelBack=(r,g,b), pos={230*SC,150*SC}, size={190*SC,35*SC}, title="nonlinearity", disable=1
//	Button Corr_bt2, pos={315*SC,165*SC},size={70*SC,18*SC},labelBack=(r,g,b),title="Correct",disable=1,proc=Proc_nonLinear_image
//	Checkbox Corr_ck0,pos={238*SC,165*SC},size={70*SC,18*SC},labelBack=(r,g,b),title="TMF",variable=gv_nonlinear_flag,disable=1
//	
//	SVAR gs_procstr
//
//	titlebox Macro_sv0,title="Proc",pos={235*SC,35*SC},size={140*SC,90*SC},labelBack=(r,g,b),frame=0,Variable=gs_procstr_disp,disable=1
//
//	Titlebox Macro_tb1,title="Macro1",pos={375*SC,30*SC},labelBack=(r,g,b),frame=0,disable=1
//	Listbox Macro_Lb1,labelBack=(r,g,b), pos={370*SC,45*SC}, size={120*SC,60*SC},Listwave=w_macrolist1,frame=2,mode=5,disable=1
//	Button Macro_bt10,labelBack=(r,g,b),pos={370*SC,105*SC},size={35*SC,20*SC},title="Add",proc=Add_proc_macro,disable=1
//	Button Macro_bt11,labelBack=(r,g,b),pos={410*SC,105*SC},size={35*SC,20*SC},title="Del",proc=Add_proc_macro,disable=1
//	Button Macro_bt12,labelBack=(r,g,b),pos={450*SC,105*SC},size={35*SC,20*SC},title="Clear",proc=Add_proc_macro,disable=1
//	Button Macro_bt13,labelBack=(r,g,b),pos={370*SC,125*SC},size={120*SC,20*SC},title="Apply",proc=Apply_proc_macro,disable=1
//	//checkbox Macro_ck1,labelBack=(r,g,b),pos={435,30},size={60,20},title="Auto",disable=1
//
//	Titlebox Macro_tb2,title="Macro2",pos={505*SC,30*SC},labelBack=(r,g,b),frame=0,disable=1
//	Listbox Macro_Lb2,labelBack=(r,g,b), pos={500*SC,45*SC}, size={120*SC,60*SC},Listwave=w_macrolist2,frame=2,mode=5,disable=1
//	Button Macro_bt20,labelBack=(r,g,b),pos={500*SC,105*SC},size={35*SC,20*SC},title="Add",proc=Add_proc_macro,disable=1
//	Button Macro_bt21,labelBack=(r,g,b),pos={540*SC,105*SC},size={35*SC,20*SC},title="Del",proc=Add_proc_macro,disable=1
//	Button Macro_bt22,labelBack=(r,g,b),pos={580*SC,105*SC},size={35*SC,20*SC},title="Clear",proc=Add_proc_macro,disable=1
//	Button Macro_bt23,labelBack=(r,g,b),pos={500*SC,125*SC},size={120*SC,20*SC},title="Apply",proc=Apply_proc_macro,disable=1
//	//checkbox Macro_ck2,labelBack=(r,g,b),pos={565,30},size={60,20},title="Auto",disable=1
//
//
//	Button Macro_b99, pos={403*SC,170*SC},size={60*SC,18*SC}, labelback=(r,g,b),title="undo", disable=1, proc=undo_image
//	Button Macro_b109, pos={466*SC,170*SC},size={60*SC,18*SC}, labelback=(r,g,b),title="reset", disable=1, proc=reset_image

	SetDatafolder DF
End 



////////////////////////////scale //////////////////////////
Function Proc_setvariable_updatevar(ctrlName,varNum,varStr,varName) : SetVariableControl 
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_normal=$(DF_panel+":process")
	SetActivesubwindow $winname(0,65)
	NVAR ppnts = DF_common:gv_ppnts
	
	NVAR x0 = DF_normal:gv_axes_x0
	NVAR x1 = DF_normal:gv_axes_x1
	NVAR dx = DF_normal:gv_axes_dx
	
	if (stringmatch(varName,"gv_axes_x0") || stringmatch(varName,"gv_axes_x1"))	
		dx = (x1 - x0) / (ppnts - 1)
		ControlUpdate scale_sv12
		ControlUpdate scale_sv13
		ControlUpdate scale_sv14
	else
		Variable m_scale=dx/((x1-x0)/(ppnts - 1))
		x0 =x0*m_scale
		x1 =x1*m_scale
		ControlUpdate scale_sv12
		ControlUpdate axe_sv13
	endif
		
	SetDatafolder DF
End



//////////////////Norm/////////////

Function Proc_bt_Procwave(ctrlname)
	String ctrlname
	
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_normal=$(DF_panel+":process")
	SetActiveSubwindow $winname(0,65)
	
	SVAR gs_procwavepath=DFR_normal:gs_procwavepath	
	Wave /T w_procwavelist=DFR_normal:w_procwavelist
	
	if (stringmatch(ctrlname,"bkg_bt0")) //disp
		if (strlen(gs_procwavepath)>0)
			Wave procwave=$gs_procwavepath
			display_wave(procwave,0,0)
		endif
	else
		if (strlen(gs_procwavepath)>0)
			Wave procwave=$gs_procwavepath
			doalert 1,"Delete "+nameofwave(procwave)
			if (V_flag==1)
				controlinfo bkg_lb0
				Killwaves /Z procwave
				DeletePoints /M=0  V_value, 1, w_procwavelist
			endif
		endif
	endif
End


Function Proc_listbox_procwave(ctrlname, row, col, event)
	String ctrlName
	Variable row
	Variable col
	Variable event
	
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_normal=$(DF_panel+":process")
	SetActiveSubwindow $winname(0,65)
	
	
	Wave /T w_procwavelist=DFR_normal:w_procwavelist
	
	DFREF DFR_procwave=$(DFS_global+"Proc_wave")
	
	String suffix="*"
	
	if (event ==1 || event ==4)
	
		SetDatafolder DFR_procwave
	
		String list=wavelist(suffix,";","")
		if (strlen(list)==0)
			redimension /n=(0,2),w_procwavelist
		else
			SListToWave(List,1,";",Nan,Nan)
			Wave /t w_Stringlist
			redimension /n=(numpnts(w_Stringlist),2),w_procwavelist
			w_procwavelist[][0]=w_Stringlist[p]
			KillWaves/Z w_StringList
			Variable index
			do
				Wave procwave=DFR_procwave:$w_procwavelist[index][0]
				String notestr=note(procwave)
				w_procwavelist[index][1]=StringByKey("Type", notestr, "=" , "\r")
				index+=1
			while (index<dimsize(w_procwavelist,0))
		endif
	endif
	
	if (event ==4)	
		SVAR gs_procwavepath=DFR_normal:gs_procwavepath
		if (dimsize(w_procwavelist,0)>0)
			gs_procwavepath=DFS_global+"Proc_wave:"+w_procwavelist[row][0]
		else
			gs_procwavepath=""
		endif
		
		update_proc_wave(1)
	endif
	
	
	
	SetDatafolder DF
	
End


Function Proc_setvariable_energychange(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlname
	Variable varnum
	String varSTr,varname
	
	DFREF DF = GetDataFolderDFR()
	String Name_win=winname(0,65)
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_normal=$(DF_panel+":process")
	SetActiveSubwindow $winname(0,65)
		// lowest or highest n-MDC's to average
	WAVE w_image = DFR_common:w_image
	
	//if (stringmatch(ctrlname,"disp_sv0")||stringmatch(ctrlname,"scale_sv0"))
	//Cursor/P/I/H=1 B w_image pcsr(B),x2pntsmult(w_image,varnum,1)
	//endif
	
	NVAR e0 = DFR_common:gv_E0
	NVAR e1 = DFR_common:gv_E1
	NVAR m0 = DFR_common:gv_M0
	NVAR m1 = DFR_common:gv_M1
	
	if (stringmatch(ctrlname,"Norm_*"))
	
		Controlinfo Norm_c3
		Variable mdcflag=v_value
		controlinfo Nrom_c4
		Variable edcflag=v_value
	
		Variable temp1,temp2
		if (mdcflag)
			temp1=e0
			temp2=e1
			Cursor/P/I/H=1 A w_image pcsr(A),x2pntsmult(w_image,temp2,1)
			Cursor/P/I/H=1 B w_image pcsr(B),x2pntsmult(w_image,temp1,1)
		endif
		if (edcflag)
			temp1=m0
			temp2=m1
			Cursor/P/I/H=1 A w_image x2pntsmult(w_image,temp2,0),qcsr(A)
			Cursor/P/I/H=1 B w_image x2pntsmult(w_image,temp1,0),qcsr(B)
		endif
	endif
	
	if (stringmatch(ctrlname,"Scale_sv0"))
		temp1=varnum
		Cursor/P/I/H=1 B w_image pcsr(B),x2pntsmult(w_image,temp1,1)
		NVAR gv_csr_E=DFR_normal:gv_Csr_E
		gv_csr_E=varnum
	endif
	
	SetDatafolder DF
	
End


//////////////////ABOUT FERMI


 Function update_Fermi_wave()

	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DF_common=$(DF_panel+":panel_common")
	DFREF DF_normal=$(DF_panel+":process")
	SetActivesubwindow $winname(0,65)
	
	Wave w_image=DF_common:w_image
	//Wave w_norm_x=DF_normal:w_norm_x
	Wave w_norm_e=DF_normal:w_norm_e
	
	NVAR FermiEF=DF_normal:gv_Fermibkg_ef
	NVAR FermiT=DF_common:gv_sampletem//DF_normal:gv_Fermibkg_T
	NVAR Fermires=DF_normal:gv_Fermibkg_res
	controlinfo Corr_ck5
	Variable convolveflag=v_value
	
	//make /o/n=1000 w_avg
	M_avg(w_image,1)
	Wave w_avg
	
	Cal_fermi_function(w_avg,FermiEf,FermiT,convolveflag,Fermires)
	Wave FermiProc
	duplicate/o FermiProc w_norm_e//,w_norm_x
	//w_norm_x=x
	killwaves/Z w_avg,FermiProc
	
	SetDatafolder DF

End 

 
Function Proc_Fermisv_change(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlname
	Variable varnum
	String varSTr,varname
	update_Fermi_wave()
End

Function Proc_Fermick_change(ctrlName,value)
	String ctrlname
	Variable value
	update_Fermi_wave()
End

///////////////ABOOUT FROM DATA
 
Function Proc_checkbox_ProcPchange(ctrlname,value)
	String ctrlname
	Variable value
	SetActivesubwindow $winname(0,65)
	
	 Variable Checkval
	 strswitch (ctrlname)
		case "bkg_ck41":
			Checkval= 1
			break
		case "bkg_ck51":
			Checkval=2
			break
	endswitch
	
	CheckBox bkg_ck41,value= Checkval==1
	CheckBox bkg_ck51,value= Checkval==2
End



Function Proc_checkbox_ProcWchange(ctrlname,value)
	String ctrlname
	Variable value
	SetActivesubwindow $winname(0,65)
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_normal=$(DF_panel+":process")
	
	NVAR gv_procwaveflag=DFR_normal:gv_procwaveflag
	
	Variable Checkval
	
	if (value==1)
		strswitch (ctrlname)
			case "bkg_ck11":
				Checkval= 1
				break
			case "bkg_ck21":
				Checkval= 2
				break
			case "bkg_ck31":
				Checkval= 3
				break
		endswitch
		CheckBox bkg_ck11,value= Checkval==1
		CheckBox bkg_ck21,value= Checkval==2
		CheckBox bkg_ck31,value= Checkval==3
		gv_procwaveflag=Checkval
		
		if (Checkval==2)
			CheckBox Norm_c3,value=1
			Proc_checkbox_changeDCs("Proc_Norm_c3",1)
		elseif  (Checkval==1)
			CheckBox Norm_c4,value=1
			Proc_checkbox_changeDCs("Proc_Norm_c4",1)
		endif
		
		if (Checkval==3)
			CheckBox Disp_c2,value=0
			Proc_checkbox_showDisp("Disp_c2",0)
		else
			CheckBox Disp_c2,value=1
			Proc_checkbox_showDisp("Disp_c2",1)
		endif
	else
		gv_procwaveflag=0
	endif
	

	
	update_proc_wave(1)
	
End

Function Proc_checkbox_fitchange(ctrlname,value)
	String ctrlname
	Variable value
	SetActivesubwindow $winname(0,65)
	Variable Checkval

	strswitch (ctrlname)
		case "Norm_ck11":
			Checkval= 1
			break
		case "Norm_ck21":
			Checkval= 2
			break
		case "Norm_ck31":
			Checkval= 3
			break
					
	endswitch
	CheckBox Norm_ck11,value= Checkval==1
	CheckBox Norm_ck21,value= Checkval==2
	CheckBox Norm_ck31,value= Checkval==3
End


Function Proc_checkbox_smoothchange(ctrlname,value)
	String ctrlname
	Variable value
	update_proc_wave(1)
	
End


Function Proc_setvariable_smoothchange(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlname
	Variable varnum
	String varSTr,varname
	update_proc_wave(1)
End



Function update_proc_wave(flag)
	Variable flag
	DFREF DF = GetDataFolderDFR()

	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_normal=$(DF_panel+":process")
	SetActiveSubwindow $winname(0,65)
	
	NVAR gv_procwaveflag=DFR_normal:gv_procwaveflag
	
	Wave w_norm=DFR_normal:w_norm
	Wave w_norm_e=DFR_normal:w_norm_e
	
		
	NVAR pnts=DFR_normal:gv_tmfsmt
	NVAR times=DFR_normal:gv_tmfsmtrep
	
	SetDatafolder DFR_normal
	
	if  ((gv_procwaveflag>0))
		if (flag==1)
			SVAR gs_procwavepath=DFR_normal:gs_procwavepath
		
			if (strlen(gs_procwavepath)>0)
				Wave procwave_raw=$gs_procwavepath
				duplicate /o procwave_raw, procwave
			
				controlinfo Norm_c2
				if (v_value)
					if (gv_procwaveflag!=3)
						M_smooth_times(procwave,-1,pnts,times)
					else
						M_smooth_times(procwave,0,pnts,times)
						M_smooth_times(procwave,1,pnts,times)
					endif
				endif
			
				if (gv_procwaveflag==1)
					duplicate /o procwave,w_norm_e
				elseif (gv_procwaveflag==2)
					duplicate /o procwave,w_norm
				else
					//duplicate /o procwave,w_norm_2D
				endif
			
				SetDatafolder DF
				return 0	
			endif
		
			SetDatafolder DF
			return 0
		endif
	else
		NVAR E0=DFR_common:gv_E0
		NVAR E1=DFR_common:gv_E1
		NVAR M0=DFR_common:gv_M0
		NVAR M1=DFR_common:gv_M1
	
		Wave w_image=DFR_common:w_image
	
	
		M_avg_subRange(w_image,0,E0,E1)
		Wave w_avg
		controlinfo Norm_c2
		if (v_value)
			M_smooth_times(w_avg,-1,pnts,times)
		endif
	
		duplicate/o w_avg w_norm
		killwaves/Z w_avg
	
		M_avg_subRange(w_image,1,M0,M1)
		Wave w_avg
		//duplicate/o w_avg DFR_normal:w_norm_e
		//Wave w_norm_e=DFR_normal:w_norm_e
	
		controlinfo Norm_c2
		if (v_value)
			M_smooth_times(w_avg,-1,pnts,times)
		endif
		duplicate/o w_avg w_norm_e
		killwaves/Z w_avg
	endif
	
	SetDatafolder DF

End



Function proc_Checkbox_Fermsel(name,value)  ///for Norm_Ck4
	String name
	Variable value
	SetActiveSubwindow $winname(0,65)
	
	Variable checkVal
	//strswitch (name)
	//	case "Norm_c1": //fromdata
	//		checkVal= 1
	//		break
	//	case "Norm_ck4": //from Fermi
	//		checkVal= 2
	//		break
		
	//endswitch
	//CheckBox Norm_c1,value= checkVal==1
	//CheckBox Norm_ck4,value= checkVal==2
	
	if (value)
		checkVal= 2
	else
		checkVal= 1
	endif
	
	if (checkval==1) 	//fromdata
	
		update_proc_wave(1)
		
	elseif (checkval==2) //from fermi
		
		
		//GroupBox Norm_gb2,  disable=0
		///checkbox Norm_ck4, frame=0, pos={440*SC,55*SC},size={60*SC,18*SC}, labelback=(r,g,b),title="Fermi:", disable=1,proc=proc_Checkbox_fermisel
		//SetVariable Norm_sv10, disable=0
		//SetVariable Norm_sv11,  disable=0
		//checkbox Norm_ck5, disable=0
		//SetVariable Norm_sv12, disable=0
		
		Proc_checkbox_changeDCs("Norm_c4",1)
		//controlinfo disp_lb1
		//Proc_listbox_dispNames("disp_lb1", v_value, 0, 4)
		 update_Fermi_wave()
	endif
	
	
			
	controlinfo disp_c2
	Proc_checkbox_showDisp("dummy",v_value)
End


Function Proc_checkbox_showDisp(ctrlName,checked)
	String ctrlName
	Variable checked
	DFREF DF = GetDataFolderDFR()
	String Name_win=winname(0,65)
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_normal=$(DF_panel+":process")
	
	SetActiveSubwindow $winname(0,65)
	
	WAVE w_norm = DFR_normal:w_norm
	WAVE w_norm_e = DFR_normal:w_norm_e
	//WAVE w_norm_x = DFR_normal:w_norm_x
	WAVE  n_mdc = DFR_common:n_mdc
	WAVE  n_mdc2 = DFR_common:n_mdc2
	WAVE  n_edc = DFR_common:n_edc
	WAVE  n_edc2 = DFR_common:n_edc2
//	WAVE  n_edc_x = DFR_common:n_edc_x
	
	Variable mdcflag,edcflag
	
	controlinfo /W=$winname(0,65) Norm_c3
	if (V_disable==0)
		Controlinfo Norm_c3
		mdcflag=v_value
		controlinfo Norm_c4
		edcflag=v_value
	else
		controlinfo main
		if (stringmatch(S_Value,"TMF")||Stringmatch(S_value,"Disp")) ///for Wave from gold
			mdcflag=1
			edcflag=0
		elseif (stringmatch(S_Value,"Norm")) ///for Fermi
			//controlinfo Norm_ck4
			//if (V_Value)
			 	mdcflag=0
				 edcflag=1
			//endif
		else
			Controlinfo Norm_c3
			mdcflag=v_value
			controlinfo Norm_c4
			edcflag=v_value
		endif		
	endif
		
		if( checked&&mdcflag)
			if (traceexist(winname(0,65),"w_norm",1)==0)
				Appendtograph w_norm
				endif
			ModifyGraph rgb(w_norm)=(0,0,56214)
			RemoveFromGraph/Z n_mdc,n_mdc2
		else
			if (traceexist(winname(0,65),"n_mdc",1)==0)
			Appendtograph n_mdc,n_mdc2
			endif
			ModifyGraph rgb(n_mdc)=(1,26214,0), rgb(n_mdc2)=(52428,1,1)
			RemoveFromGraph/Z w_norm
		endif
		if( checked&&edcflag)
			if (traceexist(winname(0,65),"w_norm_e",1)==0)
			Appendtograph /VERT/L=edc_en/T=edc_int w_norm_e//w_norm_x vs w_norm_e
			endif
			ModifyGraph rgb(w_norm_e)=(0,0,56214)
			RemoveFromGraph/Z n_edc,n_edc2
		else
			if (traceexist(winname(0,65),"n_edc",1)==0)
			Appendtograph/Q /VERT/L=edc_en/T=edc_int n_edc
			Appendtograph/Q /VERT/L=edc_en/T=edc_int n_edc2
			endif
			ModifyGraph rgb(n_edc)=(1,26214,0), rgb(n_edc2)=(52428,1,1)
			RemoveFromGraph/Z w_norm_e
		endif
		RemovefromGraph/Z w_norm_fit//,w_norm_fit_x
End


Function Proc_checkbox_changeDCs(ctrlName,checked)
	String ctrlName
	Variable checked
	SetActiveSubwindow $winname(0,65)
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_normal=$(DF_panel+":process")
	
	NVAR gv_procwaveflag=DFR_normal:gv_procwaveflag
	
	if (stringmatch(ctrlname,"Norm_c*"))
		Variable checkVal
		strswitch (Ctrlname)
			case "Norm_c3":
				checkVal= 3
				break
			case "Norm_c4":
				checkVal= 4
				break
		endswitch
		
		gv_procwaveflag=0
		CheckBox bkg_ck11,value=0
		CheckBox bkg_ck21,value=0
		CheckBox bkg_ck31,value=0
	
		checkbox Disp_c2,value=1
	else
		if (stringmatch(ctrlname,"*Norm_c3"))
			checkVal= 3
		else
			checkVal= 4
		endif
		
	endif
	
	CheckBox Norm_c3,value= checkVal==3
	CheckBox Norm_c4,value= checkVal==4
	
	controlinfo Disp_c2
	
	Proc_checkbox_showDisp("dummy",1)
	
End




Function Default_E0E1(ctrlname)
	String ctrlname
	
	Variable n = 30
	DFREF DF = GetDataFolderDFR()
	String Name_win=winname(0,65)
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_normal=$(DF_panel+":process")
	SetActiveSubwindow $winname(0,65)
		// lowest or highest n-MDC's to average
	WAVE w_image = DFR_common:w_image
	NVAR e0 = DFR_common:gv_E0
	NVAR e1 = DFR_common:gv_E1
	NVAR m0 = DFR_common:gv_M0
	NVAR m1 = DFR_common:gv_M1
	
	Controlinfo Norm_c3
	Variable mdcflag=v_value
	controlinfo Norm_c4
	Variable edcflag=v_value
	
	if(stringmatch(ctrlName, "Norm_b5"))	
		if (mdcflag)// low
		e0 = dimoffset(w_image,1)
		e1 = e0 + n * dimdelta(w_image,1)
		endif
		if (edcflag)
		m0= dimoffset(w_image,0)
		m1= m0 + n*dimdelta(w_image,0)
		endif
	elseif(stringmatch(ctrlName, "Norm_b6"))	
		if (mdcflag)// high
		e0 = M_y1(w_image) - n* dimdelta(w_image,1)
		e1 = M_y1(w_image)
		endif
		if (edcflag)
		m0= M_x1(w_image)-n*dimdelta(w_image,0)
		m1= M_x1(w_image) 
		endif
	endif
	Variable temp1,temp2
	//print x2pntsmult(w_image,e0,1)
	if (mdcflag)
		temp1=e0
		temp2=e1
		Cursor/P/I/H=1 A w_image pcsr(A),x2pntsmult(w_image,temp2,1)
		Cursor/P/I/H=1 B w_image pcsr(B),x2pntsmult(w_image,temp1,1)
	endif
	if (edcflag)
		temp1=m0
		temp2=m1
		Cursor/P/I/H=1 A w_image x2pntsmult(w_image,temp2,0),qcsr(A)
		Cursor/P/I/H=1 B w_image x2pntsmult(w_image,temp1,0),qcsr(B)
	endif
	SetDatafolder DF
End




/////////Function Fit ///////////////////////////////////////////////////// 

Function Bkg_Func_fit(ctrlname)
	String ctrlname

	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_normal=$(DF_panel+":process")
	SetActivesubwindow $winname(0,65)
	
	Wave w_image=DFR_common:w_image
	NVAR pA=DFR_common:gv_pA
	NVAR qA=DFR_common:gv_qA
	NVAR pB=DFR_common:gv_pB
	NVAR qB=DFR_common:gv_qB
	
	if (stringmatch(ctrlname,"NORM_b11"))
		RemovefromGraph/Z w_norm_fit//,w_norm_fit_x
	else
		checkbox disp_c2, value=1
		Proc_checkbox_showDisp("dummy",1)
	
		Variable rangeflag,fitflag,fermiflag
		controlinfo Norm_ck01
		rangeflag=v_value
		controlinfo Norm_ck02
		Fermiflag=v_Value
	
		Variable range0,range1
	
		controlinfo Norm_c3
		if (v_value)
			Wave w_proc=DFR_normal:w_norm
			if (rangeflag)
				range0=min(pA,pB)
				range1=max(pA,pB)
			else
				range0=0
				range1=numpnts(w_proc)
			endif
		else
			Wave w_proc=DFR_normal:w_norm_e
			if (rangeflag)
				range0=min(qA,qB)
				range1=max(qA,qB)
			else
				range0=0
				range1=numpnts(w_proc)
			endif
		endif
			
	
		controlinfo Norm_ck11
		if (v_value)
			fitflag=0
		else
			controlinfo Norm_ck21	
			if (v_value)
				fitflag=1
			else
				controlinfo Norm_ck31	
				if (v_value)
					fitflag=2
					NVAR polynum=DFR_normal:gv_polyfit_num
				endif
			endif	
		endif
	
		SetDatafolder DFR_normal
		duplicate /o w_proc w_norm_fit,w_norm_fitsb
		wave w_norm_fit
		wave w_norm_fitsb
	
		switch (fitflag)
		case 0:
			make /o/n=2 w_coef
			w_coef=0
			//curvefit /N/Q /H="01" line, w_proc[range0,range1] /D=w_norm_fitsb
			w_norm_fit=mean(w_proc,pnt2x(w_proc,range0),pnt2x(w_proc,range1))//w_coef[0]
			w_coef[0]=mean(w_proc,pnt2x(w_proc,range0),pnt2x(w_proc,range1))
			break
		case 1:
			curvefit /N/Q line w_proc[range0,range1] /D=w_norm_fitsb
			Wave w_coef
			w_norm_fit=w_coef[0]+w_coef[1]*x	
			break
		case 2:
			//sdc
			//this works for edc bkg subtraction
			AN_edc_bkg_prepare_process(w_proc)
			duplicate/o w_proc, w_norm_fit
			funcfit /N/Q  AN_edc_bkg para w_proc /D=w_norm_fit
			duplicate/o w_norm_fit, w_norm_fitsb
			duplicate/o para, w_coef
			//sdc
			break
		endswitch
		
		if (fermiflag)
			Variable kB=8.617385e-5
			NVAR gv_Fermibkg_Ef=DFR_normal:gv_Fermibkg_Ef
			NVAR gv_Fermibkg_T=DFR_normal:gv_Fermibkg_T
			w_norm_fit*=1/(exp((x-gv_Fermibkg_Ef)/KB/gv_Fermibkg_T)+1)
		endif
		
		controlinfo Norm_c3
		if (v_value)
			if (traceexist(winname(0,65),"w_norm_fit",1)==0)
				w_norm_Fit=(w_norm_fit<0)?(0):(w_norm_Fit)
				Appendtograph w_norm_fit
			endif
		else
			if (traceexist(winname(0,65),"w_norm_fit",1)==0)
				Appendtograph/Q /VERT/L=edc_en/T=edc_int w_norm_fit
				Variable index
				do 
					if (w_norm_Fit[index]<0)
						w_norm_fit[index,inf]=0
					endif
					index+=1
				while (index<numpnts(w_norm_Fit))
				
			endif
		endif	 
	
	endif

	SetDatafolder DF
end





Function AN_edc_bkg_prepare_process(edc)
	wave edc
	//settings:
		variable poly1num = 3
		variable poly2num = 19
	//end settings

	make/o/n=(poly1num) poly1wave
	make/o/n=(poly2num) poly2wave
	make/o/n=(poly1num+poly2num+2) para
	
	para=0
	para[0]=edc(0.05)
	para[poly1num]=edc(-0.3)
	para[poly1num+poly2num] = 0
	para[poly1num+poly2num+1] = 100
end
	
	