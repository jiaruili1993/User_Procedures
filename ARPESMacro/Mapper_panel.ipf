#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 0.01
#pragma ModuleName = Mapperpanel

/////////////////////////////////global panel Function ////////////////////////////////////////

Function /DF init_mapper_panel()

	DFREF DF = GetDataFolderDFR()
  	String DF_panel="root:internalUse:"+winname(0,65)
    	NewDataFolder/O/S $DF_panel
    	DFREF DFR_panel=$DF_panel
    	Variable /G gv_killflag=0
	
	Variable/G V_FitOptions=4
	
	Make/o/n=0/b w_sourceNamesSel=0
	Make/o/n=0/T w_sourceNames=""
	Make/o/n=0/T w_sourcePathes=""
		
	Variable/G gv_centerE=0
	Variable/G gv_dE = 10
	Variable/G gv_EF = 16.7
	Variable/G gv_hn=21.22
	Variable/G gv_workfunction=4.35
	Variable/G gv_innerE=15
	Variable/G gv_initialflag=0
	Variable/G gv_mappingmethodflag=2
	Variable/G gv_rawmappingmethodflag=1
	
	Variable/G gv_angdensity=0.3
	Variable/G gv_slicedensity=0.3
	
	Variable/G gv_mergeflag
	
	Variable/G gv_multicubeflag=0
	Variable/G gv_alwaysInterpflag=1
	Variable/G gv_interptolerate=4
	
	Variable/G gv_th_off = 0	// global angle offsets
	Variable/G gv_ph_off = 0
	Variable/G gv_alpha_off = 0
	Variable/G gv_gammaA=0
	Variable/G gv_AScale=1
	Variable/G gv_dimflag=1
	Variable/G gv_azi_final=0
	Variable/G gv_theta_final=0
	Variable/G gv_phi_final=0
	Variable /G gv_curveflag
	
	
	Variable/G gv_normmethodflag=0
	Variable/G gv_normal_Percentage=100
	Variable/G gv_smoothflag=0
	Variable/G gv_smoothpnts=3
	Variable/G gv_smoothtimes=1
	Variable/G gv_tmf_e0, gv_tmf_e1
	Variable/G gv_changetabflag=0
	Variable/G gv_wave_pA,gv_wave_pB,gv_wave_qA,gv_wave_qB
	Variable/G gv_map_pA,gv_map_pB,gv_map_qA,gv_map_qB
	
	
	Variable /G gv_proc_pnts=5
	Variable /G gv_proc_times=2
	Variable /G gv_proc_cfactor=0.01
	Variable /G gv_proc_flag=0
	
	//Variable /G gv_autoIntflag=1
	//Variable /G gv_linearflag=1
	Variable/G gv_auto_z =1
	Variable/G gv_lin_comb = 1
	//Variable/G gv_old_style= 0
	Variable/G gv_auto_grid = 1
	
	Variable /G gv_InterpSF=0.5
	Variable /G gv_Interpmethodflag=0
	
	Variable /G gv_FSMcrossflag=0
	
	Variable/G gv_kxfrom = -1, gv_kxto = 1	// size of the FSM
	Variable/G gv_kyfrom = -1, gv_kyto = 1
	Variable/G gv_kxdensity = 0.01
	Variable/G gv_kydensity = 0.01
	
	String/G gs_notestring=""
	// dummy data
	Make/o/n=(128,128) FSM_kxky
	SetScale/I x -1,1,"" FSM_kxky
	SetScale/I y -1,1,"" FSM_kxky
	FSM_kxky = cos(x/y)* x^2+y^2
	
	Make/o/n=0 Wave_normal,Wave_normal_S	
	// a dummy textwave
	
	if (exists("FSMsArray"))
	else
		Make/n=0/o/t FSMs_Array,FSMsPath_array
		FSMs_Array=""
		FSMsPath_array=""
	endif
		
	Variable/G Nc_dk
	Variable/G Nc_kxM
	Variable/G Nc_kyM
	Variable/G Nc_Azi
	Variable/G Nc_Dx=0
	variable/G Nc_Dy=0
	
	Variable /G gv_autoFSMflag=0
	String /G gs_autoFSM_panellist=""

	
	SetDataFolder DF
	return DFR_panel
End


Function close_mapper_panel(ctrlName)
	String ctrlName
	String wname=winName(0,65)
	String DF_panel="root:internalUse:"+wname
		DFREF DFR_panel=$DF_panel
		
	Doalert 1,"This action will delete all the data in this mapper panel. Close?"
	if (V_flag==1)
			NVAR killflag=DFR_panel:gv_killflag
		killflag=1
	   dowindow/K $wname
	else
	return 1
	endif				
		
End
Function open_mapper_panel(ctrlName)
	String ctrlName

	DFREF DF = GetDataFolderDFR()
	Variable SR = Igorsize(3) 
	Variable ST = Igorsize(2)
	Variable SL = Igorsize(1)
    	Variable SB = Igorsize(4)
    	Variable SC = ScreenSize(5)
	//Variable SR = ScreenSize(3) * SC
	//Variable ST = ScreenSize(2) * SC
	//Variable SL = ScreenSize(1) * SC
      // Variable SB = ScreenSize(4) * SC
   
   	
    	DFREF DFR_prefs=$DF_prefs
    	NVAR panelscale=DFR_prefs:gv_panelscale
    	NVAR macscale=DFR_prefs:gv_macscale
    	
	Variable Width = 520 * Panelscale*MacScale		// panel size  
	Variable height = 500 * Panelscale*MacScale	
	Variable xOffset = (SR-SL)/2-width/2
	Variable yOffset = (SB-ST)/2-height/2
	
	String panelnamelist=winlist("mapper_panel_*",";","WIN:65")
	
	if (stringmatch(ctrlname,"recreate_window")==0)
	
		if (strlen(panelnamelist)==0)
			string spwinname=UniqueName("mapper_panel_", 9, 0)
			Display /W=(xOffset, yOffset,xOffset+width,Height+yOffset) as spwinname
			DoWindow/C $spwinname
   			Setwindow $spwinname hook(MyHook) =  MypanelHook
		else
	
			if (stringmatch(ctrlname,"global_duplicate_panel"))
				//Hidedown_Allthepanel(panelnamelist)
				spwinname=UniqueName("mapper_panel_", 9, 0)
				Display /W=(xOffset, yOffset,xOffset+width,Height+yOffset) as spwinname
				DoWindow/C $spwinname
   				Setwindow $spwinname hook(MyHook) = MypanelHook
			else
	
				BringUP_thefirstpanel(panelnamelist)
				SetDataFolder DF 
				return 1
			endif
		endif
		
		DFREF DFR_mapper=init_mapper_panel()
		DFREF DFR_common=init_panelcommon()
	else
		BringUP_thefirstpanel(panelnamelist)
		DFREF DFR_mapper=$("root:internalUse:"+winname(0,65))
		DFREF DFR_common=$("root:internalUse:"+winname(0,65)+":panel_common")
		SetActiveSubwindow $winname(0,65)
		
	endif
	
	Variable r=57000, g=57000, b=57000	// background color for the TabControl
	//ModifyGraph cbRGB=(42428,42428,42428)
	//ModifyGraph wbRGB=(65535,29812,27756),gbRGB=(65535,29812,27756)
	ModifyGraph cbRGB=(52428,52428,52428)
	ModifyGraph wbRGB=(65280,48896,48896), gbRGB=(65280,48896,48896)//(65280,43520,32768)//(38776,46477,61383)
	
	
	
	
	
	ControlBar 220*SC
	
	
	SetDataFolder DFR_mapper
	String panelcommonPath=GetDatafolder(1,DFR_common)
	
	NVAR gv_multicubeflag=DFR_mapper:gv_multicubeflag
	NVAR gv_alwaysInterpflag=DFR_mapper:gv_alwaysInterpflag
		
	WAVE FSM_kxky
		
	Button global_close_panel, pos={530*SC,4*SC},size={60*SC,18*SC},title="close", proc=close_mapper_panel
	Button global_newFSM, size={80*SC,18*SC}, pos={590*SC,4*SC},title="New FSM", proc=mapperPanel#newFSMs
	//Button global_duplicate_panel, pos={590,4},size={80,18},title="duplicate", proc=Open_mapper_Panel
	
	
	
	CheckBox global_ck0, pos={10*SC,200*SC}, title="suppress update"
	CheckBox global_ck1, pos={120*SC,200*SC}, title="lock DCs scale", proc=lock_intensity
	CheckBox global_ck5, pos={220*SC,200*SC}, title="lock Image scale", proc=lock_intensity
	CheckBox global_ck2, pos={350*SC,200*SC}, title="collapse E", proc=collapse_proc
	CheckBox global_ck3, pos={425*SC,200*SC}, title="collapse k", proc=collapse_proc
	CheckBox global_ck4, pos={505*SC,200*SC}, title="between cursors", proc=collapse_proc
	CheckBox global_ck10, pos={610*SC,200*SC}, title="lock aspect",value=1,proc=lock_aspect
	
	Button global_gold, size={40*SC,20*SC},pos={645*SC,25*SC}, title="gold", proc=open_gold_panel
	Button global_main, size={40*SC,20*SC},pos={645*SC,55*SC}, title="main", proc= Open_main_Panel
	//Button global_map, size={40,20},pos={640,85}, title="map", proc= open_mapper_panel
	Button global_BZ, size={40*SC,20*SC},pos={645*SC,85*SC}, title="BZ", proc=open_bz_panel
	Button global_Anal, size={40*SC,20*SC},pos={645*SC,115*SC}, title="Anal", proc=Open_Analysis_Panel
	//Button global_Merge, size={40*SC,20*SC},pos={645*SC,145*SC}, title="Merge", proc=Open_Merge_Panel
	Button global_Fit, size={40*SC,20*SC},pos={645*SC,145*SC}, title="Fit", proc=open_fit_panel
      Button global_opdt,labelBack=(r,g,b),pos={645*SC,175*SC},size={40*SC,20*SC},title="DataT",proc=open_data_table
	
	//------------------------------------------------------------------------------------------
	TabControl map,proc=mapperPanel#map_AutoTab,pos={8*SC,6*SC},size={630*SC,190*SC},value=0,labelBack=(r,g,b)
	
	TabControl map, tabLabel(0)="source"
	
	listbox source_waves_list, pos={16*SC,45*SC}, size={110*SC,140*SC}, widths={200},listwave=DFR_common:w_sourceNames, selwave=DFR_common:w_sourceNamesSel, frame=2,mode=9, proc=source_Listbox_proc
	listbox source_prolist, pos={133*SC,45*SC}, size={90*SC,110*SC}, listwave=DFR_common:w_proclist,selwave=DFR_common:w_proclistsel, frame=2,mode=5,proc=proc_Listbox_proc,colorwave=DFR_common:proclist_color
	Titlebox source_tb1,title="Image",pos={20*SC,30*SC},labelBack=(r,g,b),frame=0,variable=DFR_common:gs_currentDF
	//checkbox global_ck6,title="lock",pos={180,30},labelBack=(r,g,b),frame=0,proc=c_locklayerproc
	Titlebox source_tb2,title="Proc",pos={145*SC,30*SC},labelBack=(r,g,b),frame=0,disable=1
	
	//selwave=DFR_common:w_DFListsel,
	GroupBox source_gb0, frame=0,labelBack=(r,g,b), pos={230*SC,30*SC}, size={275*SC,125*SC}, title="source folder"
	listbox source_lb1, pos={240*SC,70*SC}, size={250*SC,80*SC}, listwave=DFR_common:w_DF,  widths={400},selrow=0, frame=2,mode=6, proc=source_Listbox_proc
    	SetVariable source_sv0,labelBack=(r,g,b), pos={240*SC,50*SC},size={110*SC,20*SC}, title="search",frame=1,value=DFR_common:gs_matchstring,proc=Folder_list_search_proc
    	Button source_bt0,labelBack=(r,g,b),pos={350*SC,48*SC},size={45*SC,20*SC},title="All",proc=Default_Folder_proc
    	Button source_bt1,labelBack=(r,g,b),pos={400*SC,48*SC},size={45*SC,20*SC},title="process",proc=Default_Folder_proc
    	Button source_bt2,labelBack=(r,g,b),pos={450*SC,48*SC},size={45*SC,20*SC},title="spectra",proc=Default_Folder_proc
   
   	Titlebox source_tb3,title="selected wave",pos={530*SC,30*SC},labelBack=(r,g,b),frame=0//,variable=DFR_common:gs_currentDF
  	Listbox source_lb0,listwave=w_sourceNames,selwave=w_sourceNamesSel, widths={200},size={120*SC,140*SC},pos={510*SC,45*SC}, frame=2,editstyle=0,mode=9//,proc=source_Listbox_map_proc,disable=1
	 
	Button source_b2,pos={180*SC,165*SC},size={45*SC,20*SC},title="All--> ", proc=mapperPanel#AddmainpanelSel
	Button source_b3,pos={130*SC,165*SC},size={45*SC,20*SC},title="Sel-->", proc=mapperPanel#AddmainpanelSel
	Button source_b6,pos={230*SC,165*SC},size={45*SC,20*SC},title="Sel<--", proc=mapperPanel#AddmainpanelSel
	
	Button source_b4,pos={455*SC,165*SC},size={45*SC,20*SC},title="<--Sel", proc=mapperPanel#RemoveListSel
	Button source_b5,pos={380*SC,165*SC},size={70*SC,20*SC},title="Clear all", proc=mapperPanel#RemoveListSel
	
	//Groupbox select_gb0, size={150,60},pos={300,33},title="select from browser",disable=1
	Button source_b7,pos={290*SC,165*SC},size={80*SC,20*SC},title="Add Browser", proc=mapperPanel#AddbrowserSel
	
	
	TabControl map, tabLabel(1)="select"
	
	Listbox select_lb0,listwave=w_sourceNames,selwave=w_sourceNamesSel,size={110*SC,140*SC},pos={16*SC,45*SC}, frame=2,editstyle=0,mode=9,proc=mapperPanel#source_Listbox_map_proc,disable=1
	Listbox select_proclist,listwave=DFR_common:w_proclist,selwave=DFR_common:w_proclistsel,size={90*SC,140*SC},pos={133*SC,45*SC}, frame=2,editstyle=0,mode=5,proc=proc_Listbox_proc,disable=1
	Titlebox select_tb1,title="selected wave",pos={20*SC,30*SC},labelBack=(r,g,b),frame=0//,variable=DFR_common:gs_currentDF,disable=1
	
	checkbox global_ck6,title="lock",pos={180*SC,30*SC},labelBack=(r,g,b),frame=0,proc=c_locklayerproc,variable=DFR_common:gv_autolayerflag
	Titlebox select_tb2,title="Proc",pos={145*SC,30*SC},labelBack=(r,g,b),frame=0,disable=1
	
	//Listbox source_waves_list,listwave=DFR_common:w_sourceNames,selwave=DFR_common:w_sourceNamesSel,size={110,140},pos={16,45}, frame=2,editstyle=0,mode=9,proc=source_Listbox_proc
	
	Button select_b4,pos={250*SC,50*SC},size={120*SC,18*SC},title="Remove from list", proc=mapperPanel#RemoveListSel,disable=1
	Button select_b5,pos={250*SC,80*SC},size={120*SC,18*SC},title="Clear all in list", proc=mapperPanel#RemoveListSel,disable=1
	
	
		
	//------------------------------------------------------------------------------------------
	TabControl map,tabLabel(2)="normal"
	//CheckBox nor_c0 pos={30,38},title="raw-data: ignore settings below",labelBack=(r,g,b), value=1,disable=1
//	titlebox normal_tb0,pos={170,165},title="Note: these procedures do not affect the source data.",frame=0, disable=1
	Groupbox normal_gb0, frame=0,size={130*SC,80*SC},pos={20*SC,33*SC},title="Energy Range", disable=1
	CheckBox normal_c10 pos={30*SC,50*SC},title="total",labelBack=(r,g,b), value=1,disable=1
	SetVariable normal_sv0, pos={30*SC,70*SC}, size={110*SC,15*SC},title="E0: ",labelBack=(r,g,b), value = gv_tmf_e0,limits={-Inf,Inf,0}, disable = 1
	SetVariable normal_sv1, pos={30*SC,90*SC}, size={110*SC,15*SC},title="E1: ",labelBack=(r,g,b), value = gv_tmf_e1,limits={-Inf,Inf,0}, disable = 1
	Groupbox normal_gb1, frame=0,size={130*SC,65*SC},pos={20*SC,115*SC},title="Correlation", disable=1
	CheckBox normal_c21 pos={30*SC,135*SC},title="All",labelBack=(r,g,b), value=1,disable=1, proc=mapperPanel#c_correlation
	CheckBox normal_c22 pos={30*SC,155*SC},title="Just neighbour",labelBack=(r,g,b), value=0,disable=1, proc=mapperPanel#c_correlation
	//CheckBox normal_c0 pos={32,57},title="no correction",labelBack=(r,g,b), value=1,disable=1
	
	Groupbox normal_gb2, frame=0,size={140*SC,148*SC},pos={160*SC,33*SC},title="Method", disable=1
	CheckBox normal_c1 pos={170*SC,50*SC},title="None",labelBack=(r,g,b), proc=mapperPanel#c_TMF_norm, value=1,disable=1
	CheckBox normal_c2 pos={170*SC,75*SC},title="Percentage",labelBack=(r,g,b), proc=mapperPanel#c_TMF_norm, value=0,disable=1
	SetVariable normal_sv2, pos={170*SC,95*SC}, size={110*SC,15*SC},title="%:",labelBack=(r,g,b), value = gv_normal_Percentage,limits={0,Inf,0}, disable = 1
	Checkbox normal_c3 pos={170*SC,115*SC},size={110*SC,15*SC},title="Partial Intensity",labelback=(r,g,b), proc=mapperPanel#c_TMF_norm, value=0,disable=1
	Checkbox normal_c4 pos={170*SC,140*SC},size={110*SC,15*SC},title="Manual",labelback=(r,g,b), proc=mapperPanel#c_TMF_norm, value=0,disable=1
	
	
	Groupbox normal_gb3, frame=0,size={150*SC,60*SC},pos={310*SC,33*SC},title="smooth Norm wave", disable=1
	checkbox normal_c30 pos={320*SC,50*SC},size={110*SC,15*SC},title="smooth:",labelback=(r,g,b), Variable=gv_smoothflag,disable=1
	SetVariable normal_sv3, pos={320*SC,70*SC}, size={60*SC,15*SC},title="pnts",labelBack=(r,g,b), value = gv_smoothpnts,limits={1,Inf,0}, disable = 1
	SetVariable normal_sv4, pos={390*SC,70*SC}, size={60*SC,15*SC},title="times",labelBack=(r,g,b), value = gv_smoothtimes,limits={1,Inf,0}, disable = 1
	
	
	Button normal_b1 pos={310*SC,130*SC},size={110*SC,20*SC},title="Disp&Edit",proc=mapperPanel#edit_wave_norm,labelback=(r,g,b),disable=1
	Button normal_b2 pos={310*SC,160*SC},size={110*SC,20*SC},title="Load",proc=mapperPanel#load_wave_norm,labelback=(r,g,b),disable=1
	//Button normal_b3 pos={310*SC,120*SC},size={110*SC,18*SC},title="Display",proc=mapperPanel#disp_wave_norm,labelback=(r,g,b),disable=1
		
	//------------------------------------------------------------------------------------------
	TabControl map,tabLabel(3)="settings"
	Groupbox settings_gb0, frame=0,size={150*SC,155*SC},pos={20*SC,33*SC},title="energies", disable=1
	SetVariable settings_sv0, pos={30*SC,50*SC}, size={130*SC,15*SC},labelBack=(r,g,b),title="center (eV)", value = gv_centerE,limits={-Inf,Inf,0.01}, disable = 1,proc=mapperPanel#proc_sv_centerE_update
	SetVariable settings_sv1, pos={30*SC,72*SC}, size={130*SC,15*SC},labelBack=(r,g,b),title="window (meV)", value = gv_dE,limits={-Inf,Inf,10}, disable = 1,proc=mapperPanel#proc_sv_centerE_update
	SetVariable settings_sv2, pos={30*SC,94*SC}, size={130*SC,15*SC},labelBack=(r,g,b),title="EF (eV)", value = gv_EF,limits={-Inf,Inf,0}, disable = 1,proc=update_global_to_note
	SetVariable settings_sv3, pos={30*SC,117*SC}, size={130*SC,15*SC},labelBack=(r,g,b),title="hn (eV)",noedit=1, value = gv_hn,limits={-Inf,Inf,0}, disable = 1
	SetVariable settings_sv4, pos={30*SC,140*SC}, size={130*SC,15*SC},labelBack=(r,g,b),title="work-func. (eV)", value = gv_workfunction,limits={-Inf,Inf,0}, disable = 1,proc=update_global_to_note
	SetVariable settings_sv5, pos={30*SC,163*SC}, size={130*SC,15*SC},labelBack=(r,g,b),title="Inner P. (eV)", value = gv_innerE,limits={-Inf,Inf,0}, disable = 1,proc=update_global_to_note
	
	Groupbox settings_gb1, frame=0,size={170*SC,155*SC},pos={175*SC,33*SC},title="angles", disable=1
	checkbox settings_ck10,pos={185*SC,50*SC},title="global offsets:",frame=0, value=1,disable=1
	SetVariable settings_sv10, pos={185*SC,72*SC}, size={100*SC,15*SC},labelBack=(r,g,b),title="theta_off", value = gv_th_off,limits={-Inf,Inf,0.1}, disable = 1,proc=update_global_to_note
	SetVariable settings_sv11, pos={185*SC,94*SC}, size={85*SC,15*SC},labelBack=(r,g,b),title="phi_off", value = gv_ph_off,limits={-Inf,Inf,0.1}, disable = 1,proc=update_global_to_note
	SetVariable settings_sv12, pos={185*SC,117*SC}, size={85*SC,15*SC},labelBack=(r,g,b),title="azi_off", value = gv_alpha_off,limits={-Inf,Inf,0.1}, disable = 1,proc=update_global_to_note
	SetVariable settings_sv13, pos={275*SC,94*SC}, size={60*SC,15*SC},labelBack=(r,g,b),title="gamma", value = gv_gammaA,limits={-Inf,Inf,0}, disable = 1,proc=update_global_to_note
	SetVariable settings_sv14, pos={275*SC,117*SC}, size={60*SC,15*SC},labelBack=(r,g,b),title="Scale", value = gv_AScale,limits={-Inf,Inf,0}, disable = 1
	checkbox settings_ck111,pos={185*SC,140*SC},title="Curve slit:",frame=0, variable=gv_curveflag,disable=1
	//titlebox settings_tb20,pos={185*SC,140*SC},title="individual offsets:",frame=0, disable=1
	Button settings_b20, pos={185*SC,160*SC}, size={70*SC,20*SC}, title="edit", proc=mapperPanel#edit_mapper_Table, disable=1
	
	Button settings_b31, pos={260*SC,160*SC}, size={80*SC,20*SC},labelBack=(r,g,b), title="Update Cube", proc=mapperPanel#proc_bt_update_cube, disable=1
	
	Groupbox settings_gb2, frame=0,size={130*SC,155*SC},pos={350*SC,33*SC},title="k-points", disable=1
	CheckBox settings_ck20, pos={360*SC,54*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="auto-grid",  Variable=gv_auto_grid, disable=1
	SetVariable settings_sv20, pos={360*SC,74*SC}, size={110*SC,15*SC},labelBack=(r,g,b),title="kx_0:", value = gv_kxfrom,limits={-Inf,Inf,0}, disable = 1
	SetVariable settings_sv21, pos={360*SC,91*SC}, size={110*SC,15*SC},labelBack=(r,g,b),title="kx_1:", value = gv_kxto,limits={-Inf,Inf,0}, disable = 1
	SetVariable settings_sv22, pos={360*SC,108*SC}, size={110*SC,15*SC},labelBack=(r,g,b),title="ky_0:", value = gv_kyfrom,limits={-Inf,Inf,0}, disable = 1
	SetVariable settings_sv23, pos={360*SC,125*SC}, size={110*SC,15*SC},labelBack=(r,g,b),title="ky_1:", value = gv_kyto,limits={-Inf,Inf,0}, disable = 1
	SetVariable settings_sv24, pos={360*SC,145*SC}, size={55*SC,15*SC},labelBack=(r,g,b),title="dkx:", value = gv_kxdensity,limits={0,Inf,0}, disable = 1
	SetVariable settings_sv25, pos={415*SC,145*SC}, size={55*SC,15*SC},labelBack=(r,g,b),title="dky:", value = gv_kydensity,limits={0,Inf,0}, disable = 1
	checkbox settings_ck03,pos={360*SC,165*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="Precise", value=1,disable=1,proc=mapperPanel#c_map_method
	checkbox settings_ck04,pos={415*SC,165*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="Scatter", disable=1,proc=mapperPanel#c_map_method
	
	Groupbox settings_gb3, frame=0,size={145*SC,60*SC},pos={485*SC,33*SC},title="Cube", disable=1
	
	checkbox settings_ck01,pos={495*SC,54*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="raw", disable=1,proc=mapperPanel#raw_map_method
	checkbox settings_ck02,pos={495*SC,74*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="Interp", value=1,disable=1,proc=mapperPanel#raw_map_method
	//checkbox settings_ck08,pos={565*SC,54*SC}, size={40*SC,15*SC},labelBack=(r,g,b),title="auto",variable=gv_autocubedensityflag,disable=1
	SetVariable settings_sv34, pos={548*SC,54*SC}, size={45*SC,15*SC},labelBack=(r,g,b),title="dA:", value = gv_angdensity,limits={0,Inf,0}, disable = 1
	SetVariable settings_sv35, pos={548*SC,74*SC}, size={45*SC,15*SC},labelBack=(r,g,b),title="dS:", value = gv_slicedensity,limits={0,Inf,0}, disable = 1
	Button settings_b36, pos={595*SC,54*SC}, size={30*SC,15*SC}, title="Auto", proc=mapperPanel#proc_bt_initial_anglestep, disable=1
	Button settings_b37, pos={595*SC,74*SC}, size={30*SC,15*SC}, title="Manu", proc=mapperPanel#proc_bt_initial_anglestep, disable=1
	
	
	Button settings_b30, pos={495*SC,100*SC}, size={60*SC,20*SC}, title="Map", proc=master_mapper, disable=1
	
	checkbox settings_ck05,pos={495*SC,125*SC}, size={40*SC,15*SC},labelBack=(r,g,b),title="Flip", value=1,disable=1,proc=mapperPanel#dimflag_method
	checkbox settings_ck06,pos={565*SC,145*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="Polar", disable=1,proc=mapperPanel#dimflag_method
	checkbox settings_ck07,pos={585*SC,125*SC}, size={40*SC,15*SC},labelBack=(r,g,b),title="kz", disable=1,proc=mapperPanel#dimflag_method
	
	checkbox settings_ck08,pos={535*SC,125*SC}, size={40*SC,15*SC},labelBack=(r,g,b),title="DA30", disable=1,proc=mapperPanel#dimflag_method


	Button settings_autoload,labelBack=(r,g,b),pos={495*SC,152*SC},size={65*SC,30*SC},title="auto Map",disable=1,proc=wave_autoload_proc
	Button settings_b35, pos={565*SC,100*SC}, size={60*SC,20*SC},labelBack=(r,g,b), title="Plot in BZ", proc=mapperPanel#proc_bt_plot_BZFSM, disable=1
	checkbox settings_ck09,pos={565*SC,168*SC}, size={70*SC,20*SC},labelBack=(r,g,b), title="Cross", variable=gv_FSMcrossflag,proc=mapperPanel#proc_ck_updateFSMcross, disable=1
	
	//Button Set_b71,pos={440,95},size={65,18},title="AddmyFSM",proc=merge_mapper,disable=1

	//------------------------------------------------------------------------------------------
	TabControl map,tabLabel(4)="options"
	

	Groupbox options_gb1,frame=0,pos={20*SC,33*SC}, size={270*SC,90*SC},title="merge-options for multi mapping", disable=1
	CheckBox options_c0, pos={30*SC,80*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="auto intensities",  Variable=gv_auto_z, disable=1
	CheckBox options_c1, pos={30*SC,100*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="use linear combination", Variable=gv_lin_comb, disable=1//, proc=mapperPanel#c_proc_old_style_map,
	//CheckBox options_c2, pos={180,50}, size={80,15},labelBack=(r,g,b),title="use old style", Variable=gv_old_style, proc=mapperPanel#c_proc_old_style_map, disable=1
	Checkbox options_c2,pos={170*SC,80*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="Y direction", value=1,proc=mapperPanel#proc_ck_mergedirection, disable=1
	Checkbox options_c6,pos={170*SC,100*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="X direction", value=0,proc=mapperPanel#proc_ck_mergedirection, disable=1
	
	Checkbox options_c7,pos={30*SC,50*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="Single Map", value=(gv_multicubeflag==0),proc=mapperPanel#proc_ck_multicube, disable=1
	Checkbox options_c8,pos={120*SC,50*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="Multi Maps", value=(gv_multicubeflag==1),proc=mapperPanel#proc_ck_multicube, disable=1
	
	Groupbox options_gb3,frame=0,pos={20*SC,125*SC}, size={270*SC,55*SC},title="options for Interp", disable=1
	
	Checkbox options_c9,pos={30*SC,150*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="Always Interp", value=(gv_alwaysinterpflag==1),proc=mapperPanel#proc_ck_alwaysinterp, disable=1
	Checkbox options_c10,pos={120*SC,150*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="Auto Interp", value=(gv_alwaysinterpflag==0),proc=mapperPanel#proc_ck_alwaysinterp, disable=1
	Setvariable options_sv1,pos={200*SC,150*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="tolerate", variable=gv_interptolerate,disable=1

	
	Groupbox options_gb2,frame=0,pos={300*SC,33*SC},size={270*SC,75*SC},title="options for Interpolote method", disable=1
	CheckBox options_c3, pos={310*SC,50*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="Liner",  Value=1, proc=mapperPanel#c_proc_Intep_method,disable=1
	CheckBox options_c4, pos={310*SC,70*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="Cubic spline", Value=0,  proc=mapperPanel#c_proc_Intep_method,disable=1
	CheckBox options_c5, pos={310*SC,90*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="Smoothing spline", Value=0, proc=mapperPanel#c_proc_Intep_method, disable=1
	Setvariable options_sv0,pos={440*SC,90*SC},size={120*SC,15*SC},labelBack=(r,g,b),title="Smooth Factor",Value=gv_InterpSF,disable=1
	
	
	
	
	//SetVariable options_sv5, pos={180,55}, size={80,15},labelBack=(r,g,b),title="EMax(eV)", value = CEMax,limits={-Inf,Inf,0}, disable = 1
	//SetVariable options_sv6, pos={180,75}, size={80,15},labelBack=(r,g,b),title="EMin(eV)", value = CEMin,limits={-Inf,Inf,0}, disable = 1
	//SetVariable options_sv7, pos={300,55},size={80,15},labelback=(r,g,b),title="Layer",proc=FrameReview,value=FrameNum,limits={0,inf,1},disable=1
	
	//------------------------------------------------------------------------------------------
    	TabControl map,tabLabel(5)="FSMproc"
    	Groupbox FSMproc_gb0, frame=0,size={140*SC,155*SC},pos={20*SC,33*SC},title="Sym Map Set", disable=1
    	Checkbox FSMproc_ck2,pos={30*SC,50*SC},size={60*SC,15*SC},labelBack=(r,g,b),title="auto k grid",value=1,disable=1
    	SetVariable FSMproc_sv0,pos={30*SC,93*SC},size={60*SC,15*SC},labelBack=(r,g,b),title="dk",Value=Nc_dk,limits={0,inf,0},disable = 1
   	SetVariable FSMproc_sv1,pos={30*SC,70*SC},size={60*SC,15*SC},labelBack=(r,g,b),title="kxMax",Value=Nc_kxM,limits={0,inf,0},disable = 1
    	SetVariable FSMproc_sv2,pos={95*SC,70*SC},size={60*SC,15*SC},labelBack=(r,g,b),title="kyMax",Value=Nc_kyM,limits={0,inf,0},disable = 1
    
    
	SetVariable FSMproc_sv3,pos={30*SC,142*SC},size={120*SC,15*SC},labelBack=(r,g,b),title="Rotate",Value=Nc_azi,limits={-inf,inf,0},disable=1 
	SetVariable FSMproc_sv11,pos={30*SC,120*SC},size={60*SC,15*SC},labelBack=(r,g,b),title="Dx",Value=Nc_Dx,limits={-inf,inf,0},disable=1
	SetVariable FSMproc_sv12,pos={95*SC,120*SC},size={60*SC,15*SC},labelBack=(r,g,b),title="Dy",Value=Nc_Dy,limits={-inf,inf,0},disable=1
	
	CheckBox FSMproc_c41,pos={30*SC,165*SC},title="flip-y",labelBack=(r,g,b),disable=1
	CheckBox FSMproc_c42,pos={95*SC,165*SC},title="flip-x",labelBack=(r,g,b),disable=1
	
		
	Groupbox FSMproc_gb1,frame=0,size={180*SC,85*SC},pos={165*SC,33*SC},title="Symmetrize",disable=1
	CheckBox FSMproc_c0,pos={180*SC,50*SC},title="mirror-y",labelBack=(r,g,b),disable=1
	CheckBox FSMproc_c1,pos={260*SC,50*SC},title="mirror-x",labelBack=(r,g,b),disable=1
	PopupMenu FSMproc_p0,pos={180*SC,70*SC}, title="rotation",value="None;2;3;4;6", disable=1
	PopupMenu FSMproc_p3,pos={287*SC,70*SC}, title="",value="Over;Add;Raw;", disable=1
	
	//CheckBox FSMproc_c3,pos={290*SC,75*SC},title="Over",LabelBack=(r,g,b),disable=1,Value=1
	
	PopupMenu FSMproc_p1,pos={180*SC,94*SC}, title="start",value="auto;left;right;up;down", disable=1
	Button FSMproc_b0, pos={270*SC,93*SC}, size={70*SC,20*SC}, title="Symmetrize", proc=mapperPanel#sym_mapper_waves, disable=1
	
	GroupBox FSMproc_gb2,frame=0,size={180*SC,68*SC},pos={165*SC,120*SC},labelBack=(r,g,b),title="Proc",disable=1
	Button FSMproc_b3,pos={172*SC,135*SC},size={60*SC,18*SC},labelback=(r,g,b),title="Nan-->-1",proc=mapperPanel#FSM_proc,disable=1
	Button FSMproc_b6,pos={172*SC,153*SC},size={60*SC,18*SC},labelback=(r,g,b),title="-1-->Nan",proc=mapperPanel#FSM_proc,disable=1
	
	Checkbox FSMproc_b2,pos={172*SC,170*SC},size={60*SC,18*SC},title="Gradient",proc=mapperPanel#Proc_Proc_Map,LabelBack=(r,g,b),disable=1
	Checkbox FSMproc_b21,pos={233*SC,170*SC},size={45*SC,18*SC},title="D2nd",proc=mapperPanel#Proc_Proc_Map,LabelBack=(r,g,b),disable=1
	Checkbox FSMproc_b22,pos={280*SC,170*SC},size={60*SC,18*SC},title="Curve",proc=mapperPanel#Proc_Proc_Map,LabelBack=(r,g,b),disable=1
	
	
	//Button FSMproc_b2,pos={172*SC,170*SC},size={60*SC,18*SC},title="Gradient",proc=mapperPanel#Proc_Proc_Map,LabelBack=(r,g,b),disable=1
	//Button FSMproc_b21,pos={233*SC,170*SC},size={45*SC,18*SC},title="D2nd",proc=mapperPanel#Proc_Proc_Map,LabelBack=(r,g,b),disable=1
	//Button FSMproc_b22,pos={280*SC,170*SC},size={60*SC,18*SC},title="Curve",proc=mapperPanel#Proc_Proc_Map,LabelBack=(r,g,b),disable=1
	
	SetVariable FSMproc_sv21,pos={233*SC,135*SC},size={45*SC,15*SC},labelBack=(r,g,b),title="pnts",Value=gv_proc_pnts,limits={-inf,inf,0},disable=1
	SetVariable FSMproc_sv22,pos={233*SC,153*SC},size={45*SC,15*SC},labelBack=(r,g,b),title="time",Value=gv_proc_times,limits={-inf,inf,0},disable=1
	SetVariable FSMproc_sv23,pos={280*SC,135*SC},size={60*SC,15*SC},labelBack=(r,g,b),title="factor",Value=gv_proc_cfactor,limits={-inf,inf,0},disable=1
	
	//GroupBox FSMproc_gb3,pos={350,33},size={100,65},title="Symmetrize", disable=1

	
	GroupBox FSMproc_gb5,frame=0,pos={350*SC,33*SC},size={100*SC,155*SC},title="Update", disable=1
	
	Button FSMproc_b1,pos={355*SC,60*SC},size={90*SC,18*SC},title="Load Map",proc=mapperPanel#sym_Load_Map,disable=1
	Button FSMproc_b9,pos={355*SC,90*SC},size={90*SC,18*SC},title="Update Map",proc=mapperPanel#sym_update_Map,disable=1
	Button FSMproc_b8,pos={355*SC,150*SC},size={90*SC,18*SC},title="Undo",proc=mapperPanel#sym_undo_Map,disable=1
	
	
	GroupBox FSMproc_gb4,frame=0,pos={460*SC,33*SC},size={170*SC,60*SC},title="FSM display", disable=1
	CheckBox FSMproc_c4,pos={470*SC,50*SC},title="3D",labelBack=(r,g,b),disable=1
	
	Button FSMproc_b31, pos={470*SC,70*SC}, size={65*SC,18*SC},labelBack=(r,g,b), title="Plot FSM", proc=mapperPanel#proc_bt_plot_FSM, disable=1
	Button  FSMproc_b34,pos={540*SC,70*SC},size={85*SC,18*SC},title="Append FSM",proc=mapperPanel#proc_bt_plot_FSM,disable=1
	
	
	GroupBox FSMproc_gb6,frame=0,pos={460*SC,103*SC},size={170*SC,85*SC},title="Cube display", disable=1
	Button FSMproc_b33,pos={470*SC,135*SC},size={85*SC,20*SC},title="Save kxky Cube",proc=FSM_initialCube,disable=1
	Button FSMproc_b35,pos={470*SC,160*SC},size={85*SC,20*SC},title="kxkycube Show",proc=FSM_enable3DShow,disable=1
	Button FSMproc_b36,pos={560*SC,135*SC},size={65*SC,20*SC},title="Sym Cube",proc=mapperPanel#sym_mapper_cube,disable=1
	
	//Button FSMproc_b10,pos={355,120},size={90,18},title="Save Map",proc=mapperPanel#proc_bt_save_FSM,disable=1
	
	

	TabControl map, tabLabel(6)="SaveFSM"
	GroupBox SaveFSM_gb0, frame=0,size={250*SC,135*SC}, pos={30*SC,35*SC}, title="FSMs:", disable=1
	Listbox SaveFSM_lb0, listwave=FSMs_Array, size={230*SC,110*SC},pos={40*SC,50*SC},frame=2, editstyle=0, mode=2 ,disable=1 ,proc=mapperPanel#ListFSMs
	//SetVariable SaveFSM_sv0, size={140,20},pos={280,45},title="FSM Name:", labelback=(r,g,b), Value=FSMsName,limits={-Inf,Inf,0},disable=1
	Button SaveFSM_bt0, size={100*SC,20*SC}, pos={300*SC,45*SC},title="New FSM", proc=mapperPanel#newFSMs, disable=1
	//Button SaveFSM_bt1, size={100,20}, pos={300,105},title="Save FSM", proc=SaveFSMs,disable=1
	//Button SaveFSM_bt2, size={100,20}, pos={300,135},title="Del FSM", proc=DelFSMs, disable=1
	Button SaveFSM_bt3, size={100*SC,20*SC}, pos={300*SC,70*SC},title="Load FSM", proc=mapperPanel#LoadFSMs, disable=1
	Button SaveFSM_bt4, size={100*SC,20*SC}, pos={300*SC,95*SC},title="Display FSM", proc=mapperPanel#LoadFSMs, disable=1
	
	//Checkbox Sav_ck0,pos={440,110},size={65,18},title="SaveData",disable=1,labelback=(r,g,b)
	
	
	add_image_DCs("mapper_panel")
	panelimageupdate(3)
	
	
	SetDataFolder DF
End


/////////////////////////////////static Function ////////////////////////////////////////

static Function source_Listbox_map_Proc(ctrlname, row, col, event)
	String ctrlName
	Variable row
	Variable col
	Variable event
	
	DFREF Df = getdatafolderDFR()
	
	String DF_panel="root:internalUse:"+winname(0,65)
	SetDataFolder $DF_panel
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	
	DFREF DFR_common=$(DF_panel+":panel_common")
	
	WAVE/T w_sourcePathes
	WAVE/t w_sourceNames
	WAVE/b w_sourceNamesSel
	
	//WAVE/t w_DF
		SVAR pList = DFR_common:gs_sourcePathList
		SVAR nList = DFR_common:gs_sourceNameList
		SVAR topPath = DFR_common:gs_TopItemPath
		SVAR topName = DFR_common:gs_TopItemName
		NVAR toplayernum=DFR_common:gv_toplayernum
		SVAR DF_data = DFR_common:gs_currentDF
		NVAR topwaverow=DFR_common:gv_topwaverow
	
	Variable toprow=row
	
	if (numpnts(w_sourcePathes)==0)
		SetDatafolder DF
		return 1
	endif
		String name
		Variable i=0,lastrow,multselflag=0
				do
				if ((w_sourceNamesSel[i] == 1)||(w_sourceNamesSel[i] == 8)||(w_sourceNamesSel[i] == 9))		// list with all selected items
				//	name = w_sourceNames[i]
				//	nList += name+";"
				//	pList += w_sourcePathes[i]+";"
					lastrow=i
					multselflag+=1
				endif
			i += 1
			while (i < numpnts(w_sourceNamesSel))
	     
			//i = 0	// first active item
			//do
				
				if (w_sourceNamesSel[toprow] == 0)
					toprow=lastrow
				endif
					topwaverow=toprow
					topPath = w_sourcePathes[toprow]
					topName = w_sourceNames[toprow]//StringFromList(0,nList)
				
				if (strlen(topPath)>0)
					
					Wave tImage=$topPath
					
				//	if (multselflag>1)
					//checkbox global_ck6,value=1
				////	c_locklayerproc("dummy",1)
					//endif
					
					GetProList(DFR_common,tImage,NAN)
					Panelimageupdate(3)
				endif
	SetDatafolder DF
	
End

static Function map_AutoTab( name, tab )
	String name
	Variable tab
	
	DFREF DF=GetDatafolderDFR()
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	
	Wave w_image=DFR_common:w_image
	Wave FSM_kxky=DFR_panel:FSM_kxky
	
	
	ControlInfo $name
	String tabStr = S_Value
	
	String curTabMatch= tabstr+"_*"
	String name_panel=winname(0,65)
	
	String controlsInATab= ControlNameList(name_panel,";","*_*")
	String controlsInCurTab= ListMatch(controlsInATab, curTabMatch)
	String controlsglobalcontrols=ListMatch(controlsInATab, "*global*")
	String controlsInOtherTabs= ListMatch(controlsInATab, "!"+curTabMatch)

	ModifyControlList controlsInOtherTabs disable=1	// hide
	ModifyControlList controlsInCurTab disable=0		// show
	ModifyControlList controlsglobalcontrols disable=0	// show
	
	SetDatafolder DFR_panel
	
	NVAR gv_wave_pA,gv_wave_pB,gv_wave_qA,gv_wave_qB
	NVAR gv_map_pA,gv_map_pB,gv_map_qA,gv_map_qB
	NVAR gv_changetabflag
	
	if ((stringmatch(tabstr,"select")!=1)&&(stringmatch(tabstr,"source")!=1))
		if (gv_changetabflag==0)
			gv_wave_pA=pcsr(A,name_panel)
			gv_wave_pB=pcsr(B,name_panel)
			gv_wave_qA=qcsr(A,name_panel)
			gv_wave_qB=qcsr(B,name_panel)
		endif
		
		checkbox global_ck6,disable=1
		duplicate /o FSM_kxky,w_image
		TextBox/K/N=text0
		
		Panelimageupdate(-1)
		Adjustdisplayratio(2)
		
		if (gv_changetabflag==0)
			Cursor/W=$name_panel /P/I/H=1 A w_image gv_map_pA,gv_map_qA
			Cursor/W=$name_panel /P/I/H=1 B w_image gv_map_pB,gv_map_qB
			gv_changetabflag=1
		endif
		
		
	else
		if (gv_changetabflag==1)
			gv_map_pA=pcsr(A,name_panel)
			gv_map_pB=pcsr(B,name_panel)
			gv_map_qA=qcsr(A,name_panel)
			gv_map_qB=qcsr(B,name_panel)
		endif
		
		
		Panelimageupdate(3)
		//ModifyGraph height={Aspect,0.6}
		Adjustdisplayratio(1)
		
		if (gv_changetabflag==1)
		
			Cursor/W=$name_panel /P/I/H=1 A w_image gv_wave_pA,gv_wave_qA
			Cursor/W=$name_panel /P/I/H=1 B w_image gv_wave_pB,gv_wave_qB
			gv_changetabflag=0
		endif
		
	endif
	//if (stringmatch(tabstr,"select")==1)
	
	//endif
	//remove_FSMs_graph(winname(0,65))
	//add_image_DCs(winname(0,65))
	//endif
	
	if (stringmatch(tabstr,"settings")==1)
		updata_mapping_par(0)
	endif
	
	if (stringmatch(tabstr,"SaveFSM")==1)
		updata_mapping_List(0)
	endif
	
	SetDatafolder DF
	
End

static FUnction proc_bt_initial_anglestep(ctrlname)
	String ctrlname
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	
	NVAR gv_angdensity=DFR_panel:gv_angdensity
	NVAR gv_slicedensity=DFR_panel:gv_slicedensity
	
	if (stringmatch(ctrlname,"settings_b36")) //auto
		gv_angdensity=Nan
		gv_slicedensity=Nan
	else
		gv_angdensity=0.3
		gv_slicedensity=0.3
	endif
End

static Function proc_ck_alwaysinterp(ctrlname,value)
	String ctrlname
	Variable value
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	NVAR gv_alwaysinterpflag=DFR_panel:gv_alwaysinterpflag

	Variable ckvalue
	strswitch(ctrlname)
		case "options_c9":
			ckvalue=1
			gv_alwaysinterpflag=1
		break
		case "options_c10":
			ckvalue=2
			gv_alwaysinterpflag=0
		break
	Endswitch
	
	checkbox options_c9,value=ckvalue==1
	checkbox options_c10,value=ckvalue==2
End

static Function proc_ck_multicube(ctrlname,value)
	String ctrlname
	Variable value
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	NVAR gv_multicubeflag=DFR_panel:gv_multicubeflag

	Variable ckvalue
	strswitch(ctrlname)
		case "options_c7":
			ckvalue=1
			gv_multicubeflag=0
		break
		case "options_c8":
			ckvalue=2
			gv_multicubeflag=1
		break
	Endswitch
	
	checkbox options_c7,value=ckvalue==1
	checkbox options_c8,value=ckvalue==2
End

static Function proc_ck_mergedirection(ctrlname,value)
	String ctrlname
	Variable value
	
	SetActiveSubwindow $winname(0,65)
	
		
	Variable ckvalue
	strswitch(ctrlname)
		case "options_c2":
			ckvalue=1
			break
		case "options_c6":
			ckvalue=2
			break
	Endswitch
	
	checkbox options_c2,value=ckvalue==1
	checkbox options_c6,value=ckvalue==2
	
End


static Function edit_mapper_Table(ctrlName)
	String ctrlName
	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	
	WAVE/T w_sourcePathes = DFR_panel:w_sourcePathes
	WAVE/T w_sourceNames = DFR_panel:w_sourceNames
	Wave/B w_sourceNamessel=DFR_panel:w_sourceNamessel
	String sourcePathlist=WavetoStringlist(w_sourcePathes,";",Nan,Nan)
	String sourcenamelist=WavetoStringlist(w_sourceNames,";",Nan,Nan)
	
	//SVAR currentDF=DF_common:gs_currentDF
	NVAR toplayernum=DFR_common:gv_toplayernum
	NVAR topprocnum=DFR_common:gv_topprocnum
	NVAR autolayerflag=DFR_common:gv_autolayerflag
	
	if (autolayerflag==1)
		if (Check_Autosimilar_layer_list(w_sourcePathes,w_sourceNamessel,toplayernum,topprocnum,0)==-1)
			doalert 0,"Not similar layer, change auto."
   			autolayerflag=0
   		endif
	endif
	
	MakeData_table_list(sourcePathlist,toplayernum,topprocnum,autolayerflag)
	Pauseforuser Data_table
	updata_mapping_par(0)
End

//Save FSMs


static Function ListFSMs(Ctrlname, row, col, event) 
	String CtrlName
	Variable row
	Variable col
	Variable event
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	

	if(event == 1 || event == 4 || event == 5)
		//	SVAR FSMsName= DF_panel:FSMsName
    		updata_mapping_List(0)
		Wave /T FSMsArray=DFR_panel:FSMs_Array
		Wave /T FSMsPathArray=DFR_panel:FSMsPath_Array
	
		//FSMsName=FSMsArray[row]
		String Foldername="root:internaluse:"+FSMsPathArray[row]
		String FSMname=foldername+":FSM_kxky"
		Wave FSM=$FSMname
		duplicate /o FSM DFR_common:w_image
		Panelimageupdate(-1)
		Adjustdisplayratio(2)
	endif
	SetDatafolder DF
End

static Function newFSMs(CtrlName)
	String CtrlName
	open_mapper_panel("global_duplicate_panel")
End


static Function LoadFSMs(CtrlName)
	String CtrlName
	DFREF DF=GetDatafolderDFR()
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	
	Wave /T FSMsArray=DFR_panel:FSMs_Array
	Wave /T FSMsPathArray=DFR_panel:FSMsPath_Array

	Controlinfo SaveFSM_lb0
	String FSMname=FSMsPathArray[V_Value]
	
	if (stringmatch(Ctrlname,"SaveFSM_bt3"))
		Dowindow /HiDE=1 $winname(0,65)
		Dowindow /HIDE=0 /F $FSMname
	else
		Dowindow /HIDE=0 /F $FSMname
	endif
	
	
	SetDatafolder DF
End



//Proc_Map
//


Function Proc_Map_process(w_image,smth_time,smth_pnts,proc_cfactor,proc_flag)
	Wave w_image
	Variable smth_time,smth_pnts
	Variable proc_cfactor
	Variable proc_flag
	
	Variable index=0
	Duplicate /o/Free w_image,w_image_zero
	w_image_zero=(numtype(w_image_zero)==2)?(0):(w_image_zero)
	do
		smooth /DIM=0 smth_pnts,w_image_zero
		smooth /DIM=1 smth_pnts,w_image_zero
		index+=1
	while (index<smth_time)
	w_image=(numtype(w_image)==2)?(Nan):(w_image_zero)
	
	Duplicate /o /FREE w_image Diff1X,Diff1Y,Diff2X,Diff2Y,DiffXY
	differentiate /Dim=0 Diff1X
	differentiate /Dim=1 Diff1Y
	differentiate /Dim=0 Diff2X
	differentiate /Dim=0 Diff2X
	differentiate /Dim=1 Diff2Y
	differentiate /Dim=1 Diff2Y
	differentiate /Dim=0 DiffXY
	differentiate /Dim=1 DiffXY

	
	Variable dx=dimdelta(w_image,0)
	Variable dy=dimdelta(w_image,1)
	
	Variable weight=(dx/dy)
	
	if (proc_flag==1) //gradient
		w_image=sqrt(Diff1X^2+diff1Y^2)
	elseif (proc_flag==2) //d2nd
		w_image=Diff2X[p][q]+weight*weight*Diff2Y[p][q]		
	elseif (proc_flag==3) //curve
		Variable normIx=abs(wavemin(Diff1x))
		Variable normIy=abs(wavemin(Diff1y))
		
		Variable normI=max(normIx*normIx,normIy*normIy*weight)
		
		Variable Cfactor=proc_cfactor
		
		w_image=((Cfactor*normI+weight*Diff1x*Diff1x)*Diff2y-2*weight*Diff1x*Diff1y*Diffxy+weight*(Cfactor*normI+Diff1y*Diff1y)*Diff2x)/(Cfactor*normI+weight*Diff1x*Diff1x+Diff1y*Diff1y)^1.5
		
	endif

end

static Function Proc_Proc_Map(CtrlName,value)
	String CtrlName
	Variable value
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	
	Wave w_image=DFR_common:w_image
	
	NVAR gv_proc_pnts=DFR_panel:gv_proc_pnts
	NVAR gv_proc_times=DFR_panel:gv_proc_times
	
	NVAR gv_proc_cfactor=DFR_panel:gv_proc_cfactor
	NVAR gv_proc_flag=DFR_panel:gv_proc_flag
	
	gv_proc_flag=0
	
	strswitch(ctrlname)
	case "FSMproc_b2":
		if (value==1)
			gv_proc_flag=1
		endif
		break
	case "FSMproc_b21":
		if (value==1)
			gv_proc_flag=2
		endif
		break	
	case "FSMproc_b22":
		if (value==1)
			gv_proc_flag=3
		endif
		break
	endswitch
		
	checkbox FSMproc_b2,value=gv_proc_flag==1
	checkbox FSMproc_b21,value=gv_proc_flag==2
	checkbox FSMproc_b22,value=gv_proc_flag==3
	
	if (gv_proc_Flag>0)
		sym_undo_Map("dummy")
		Proc_Map_process(w_image,gv_proc_times,gv_proc_pnts,gv_proc_cfactor,gv_proc_flag)
	else
		sym_undo_Map("dummy")
	endif

	Panelimageupdate(-1)

	SetDatafolder DF
End


static Function AddmainpanelSel(ctrlName)
	string ctrlname
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	SetDatafolder DFR_common
	
	SVAR sourcePathlist=DFR_common:gs_sourcePathlist
	SVAR sourcenamelist=DFR_common:gs_sourcenamelist
	WAVE/T w_sourcePathes = DFR_common:w_sourcePathes
	WAVE/T w_sourceNames = DFR_common:w_sourceNames
	Wave/B w_sourceNamessel=DFR_common:w_sourceNamessel
	//SVAR currentDF=DF_common:gs_currentDF
//	SVAR toppath=DF_common:gs_TopItemPath
//	SVAR topName = DF_common:gs_TopItemName
	
	WAVE/T w_sourcePathes_map = DFR_panel:w_sourcePathes
	WAVE/T w_sourceNames_map = DFR_panel:w_sourceNames
	Wave/B w_sourceNamessel_map=DFR_panel:w_sourceNamessel
	
	//DFREF MDF_common=root:internalUse:main_panel:panel_common
	//SVAR  sourcePathes = MDF_common:gs_sourcePathList
	//SVAR scurrentDF=MDF_common:gs_currentDF
	
	if (stringmatch (ctrlname,"source_b2"))
			Variable index=0,pindex=0
			do
			//Wave data=$w_StringList[index]
			//w_sourcePathes[pindex]=GetWavesDatafolder(data,2)//w_StringList[index-old_pnts]
			//w_sourceNames[pindex]=nameofwave(data)
			//pindex+=1
				if (AppendstringtoList_norepeat(w_sourcePathes_map,w_sourcePathes[index],0,1))
					AppendstringtoList_norepeat(w_sourceNames_map,w_sourceNames[index],0,0)
				endif
			index+=1
			while (index<numpnts(w_sourcePathes))
	
	        Variable add_pnts = numpnts(w_sourcePathes_map)
	        Redimension/N=(add_pnts) w_sourceNamessel_map
		    w_sourceNamessel_map=0
		    sort /A w_sourceNames_map,w_sourceNames_map,w_sourcePathes_map,w_sourceNamessel_map
		    
	elseif (stringmatch (ctrlname,"source_b3"))
	
	String	objpathlist=sourcePathlist
	String	objnamelist=sourcenamelist
	//Wave data=$stringfromlist(0,sourcePathlist,";")
	//	DF_data=GetWavesDatafolder(data,1)
	//	DFREF DFR_data=$DF_data
		index=0
			do
				if (itemsinlist(objpathlist)==0)
				break
				endif
				
				if (AppendstringtoList_norepeat(w_sourcePathes_map,Stringfromlist(index,objpathlist),0,1))
					AppendstringtoList_norepeat(w_sourceNames_map,Stringfromlist(index,objnamelist),0,0)
				endif
			
			index+=1	
			while (index<itemsinlist(objpathlist))
			
			//sourcePathlist+=objlist
			add_pnts = numpnts(w_sourcePathes_map)
	        Redimension/N=(add_pnts) w_sourceNamessel_map
		    w_sourceNamessel_map=0
		    sort /A w_sourceNames_map,w_sourceNames_map,w_sourcePathes_map,w_sourceNamessel_map
	  else	    
	        
	      objpathlist=sourcePathlist
	      objnamelist=sourcenamelist
	      do
				if (itemsinlist(objpathlist)==0)
				break
				endif
				
				Variable removeindex=RemovestringfromList_norepeat(w_sourcePathes_map,Stringfromlist(index,objpathlist),0)
				if (numtype(removeindex)==0)
					RemovestringfromList_norepeat(w_sourceNames_map,Stringfromlist(index,objnamelist),0)
				endif
			
			index+=1	
			while (index<itemsinlist(objpathlist))
			
			add_pnts = numpnts(w_sourcePathes_map)
	        Redimension/N=(add_pnts) w_sourceNamessel_map
		    w_sourceNamessel_map=0
		    sort /A w_sourceNames_map,w_sourceNames_map,w_sourcePathes_map,w_sourceNamessel_map
	  endif
	

	SetDatafolder DF
    

end

static Function RemoveListSel(ctrlName)
	string ctrlname
	DFREF df=GetDatafolderdfr()
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	SetDatafolder DFR_panel
	
	WAVE/T w_sourcePathes = DFR_panel:w_sourcePathes
	WAVE/T w_sourceNames = DFR_panel:w_sourceNames
	WAVE/B w_sourceNamesSel = DFR_panel:w_sourceNamesSel
	
	//SVAR currentDF=gs_currentDF
	
	Variable index=0
	
	if (stringmatch(ctrlname,"source_b4")||stringmatch(ctrlname,"select_b4"))
		do 
		if ((w_sourceNamesSel[index]==1)||(w_sourceNamesSel[index]==8)||(w_sourceNamesSel[index] == 9))
			DeletePoints index,1, w_sourcePathes,w_sourceNames,w_sourceNamesSel
		//if (cindex==10000)
		//cindex=index
		//endif
		index=0
		endif
	index+=1
	while (index<numpnts(w_sourceNamesSel))
		
	else
		redimension /N=0 w_sourcePathes,w_sourceNames,w_sourceNamesSel
	endif
	
	SetDatafolder DF
End



// adds new entries to the source waves
static Function AddBrowserSel(ctrlName)
	string ctrlname
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	SetDatafolder DFR_common
	
//	SVAR sourcePathlist=DF_common:gs_sourcePathlist
	//SVAR sourcenamelist=DF_common:gs_sourcenamelist
	WAVE/T w_sourcePathes = DFR_panel:w_sourcePathes
	WAVE/T w_sourceNames = DFR_panel:w_sourceNames
	Wave/B w_sourceNamessel=DFR_panel:w_sourceNamessel
	
	//SVAR currentDF=DF_common:gs_currentDF
	
	String name, notestr
	
	String cmd = "CreateBrowser prompt=\"select soucre data to add, and click 'ok'\""
	execute cmd
	SVAR S_BrowserList=S_BrowserList
    NVAR V_Flag=V_Flag
		if(V_Flag==0)
			SetDatafolder Df
			return -1
 	endif
	
	String objlist,objname,DF_data
	
	  if (strlen(s_BrowserList)>0)
		objname=stringfromlist(0,s_BrowserList,";")
		if (exists(objname)!=1)
			if (Datafolderexists(objname))
			String currentDF=objname
			SetDatafolder $currentDF
			objlist=wavelist("*",";","")
			
			else
			SetDatafolder Df
			return -1
			endif
		else
			objlist=s_BrowserList
		endif
		
		Variable index=0
			do
				if (itemsinlist(objlist)==0)
				break
				endif
			
			Wave data=$Stringfromlist(index,objlist)
				
			if (AppendstringtoList_norepeat(w_sourcePathes,GetWavesDatafolder(data,2),0,1))
				AppendstringtoList_norepeat(w_sourceNames,nameofwave(data),0,0)
			endif
					
			index+=1	
			while (index<itemsinlist(objlist))
		
			Variable add_pnts = numpnts(w_sourcePathes)
	        Redimension/N=(add_pnts) w_sourceNamessel
		    w_sourceNamessel=0
		    sort /A w_sourceNames_map,w_sourceNames_map,w_sourcePathes_map,w_sourceNamessel_map
	else
	SetDatafolder Df
	return -1
	endif
	
	SetDatafolder DF
	

end





static Function Append_FSMs_graph(panelName,flag)
	String panelName
	Variable flag
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	
	AppendImage FSM_kxky
	ModifyImage FSM_kxky ctab= {*,*,PlanetEarth256,0}
	ModifyGraph axisEnab(bottom)={0,0.5}
	ModifyGraph mirror=0
	//AppendToGraph/L=DC_int/B=DC_bottom DC
	//ModifyGraph axisEnab(DC_bottom)={0.6,1},freePos(DC_int)={0,DC_bottom}
	//ModifyGraph freePos(DC_bottom)={0,DC_int}
	ModifyGraph height={Plan,1,left,bottom}
	ShowInfo; Cursor/P/I/H=1 B  FSM_kxky 20,20; 
	SetDatafolder DF

End

static Function remove_FSMs_graph(panelName)
	String panelName
	Variable flag
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)

	removefromgraph/Z FSM_kxky
	
	//AppendToGraph/L=DC_int/B=DC_bottom DC
	//ModifyGraph axisEnab(DC_bottom)={0.6,1},freePos(DC_int)={0,DC_bottom}
	//ModifyGraph freePos(DC_bottom)={0,DC_int}
	
	SetDatafolder DF

End

static Function proc_sv_centerE_update(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	//SetDataFolder DFR_panel
	NVAR gv_centerE=DFR_panel:gv_centerE
	Master_mapper("dummy")
	
End

static Function proc_bt_update_cube(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	
	SetDataFolder DFR_panel
	String wavelistname=WaveList("cfe_rawcube*", ";","DIMS:3")
	wavelistname+=WaveList("cfe_interpCube*", ";","DIMS:3")
	
	if (strlen(wavelistname)==0)
		SetDatafolder DF
		return 0
	endif
	
	String cubename
	Variable index
	do	
		cubename=stringfromlist(index,wavelistname,";")
		wave cube=$cubename
		if (waveexists(cube))
			note/K cube
		endif
		index+=1
	while (index<itemsinlist(wavelistname,";"))
	SetDatafolder DF
End

static Function proc_ck_updateFSMcross(ctrlname,value)
	String ctrlname
	Variable value
	
	update_FSM_cross()
End
static Function proc_bt_plot_BZFSM(ctrlname)
	String ctrlName
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	SetDataFolder DFR_panel
	
	String wname=winname(0,65)
	
	Wave w_image=DFR_common:w_image
	
	NVAR gv_autoFSMflag=DFR_panel:gv_autoFSMflag
	SVAR gs_autoFSM_panellist=DFR_panel:gs_autoFSM_panellist

	
	Variable xpos,ypos
	xpos=pcsr(B)
	ypos=qcsr(B)
	
	String BZpanelname
	
	String panelnamelist=winlist("BZ_panel_*",";","WIN:65")
	if (strlen(panelnamelist)>0)
		if (itemsinlist(panelnamelist,";")>1)
			Variable BZnum=1
			prompt Bznum,"Select BZ panel",popup,panelnamelist
			doprompt "Select Bz panel",BZnum
			if (V_flag)
				SetDatafolder DF
				return 0
			endif
			BZpanelname=stringfromlist(Bznum-1,panelnamelist,";")
		else
			BZpanelname=stringfromlist(0,panelnamelist,";")
		endif
	else
		SetDatafolder DF
		return 0
	endif

	gv_autoFSMflag=1
	if (WhichListItem(BZpanelname,gs_autoFSM_panellist,";")==-1)
		gs_autoFSM_panellist=AddListItem(BZpanelname, gs_autoFSM_panellist,";" ,inf)
	endif
	
	Dowindow /HIDE=0/F $BZpanelname
	//open_bz_panel("mene")
	
	String DF_BZ="root:internalUse:"+BZpanelname
	DFREF DFR_BZ=$DF_BZ
	SetDataFolder $DF_BZ
	
	NVAR autoFSMflag=DFR_BZ:gv_autoFSMflag
	SVAR autoFSMname=DFR_BZ:gs_autoFSMname
	
	if (WhichListItem(wname,autoFSMname,";")==-1)
		autoFSMname=AddListItem(wname, autoFSMname,";" ,inf)
		autoFSMflag+=1
	endif
	
	String autoFSM_BZname="autoFSM_"+num2str(autoFSMflag-1)
	
	duplicate /o w_image $autoFSM_BZname
	
	Checkdisplayed /W=$BZpanelname $autoFSM_BZname
	
	if (V_flag==0)
		appendimage   /W=$BZpanelname  $autoFSM_BZname
	endif
	
	//gs_autoFSMpath=GetWavesDataFolder(autoFSM,2)
	
	//ShowInfo; Cursor/P/I/H=1 B  $autoFSM_BZname xpos,ypos
//	Variable bExists= strlen(CsrInfo(B)) > 0
	//	if (bExists == 0)
		
	//	endif
	
	
	SetDataFolder DF
End

static Function proc_bt_save_FSM(ctrlname)
	String ctrlName
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	
	String mapwin=winname(0,65)
	SetDataFolder DFR_panel
	
	
	Wave w_image=DFR_common:w_image
	
	display
	String gN=WinName(0,1)
	doWindow/F $gN
	gN=uniquename("FSM_",6,0)
	Dowindow /C $gN
	
	Attachtobottom(winname(1,65),gN,3)
	
	SetDatafolder root:graphsave:FSMs:
	
	if (DatafolderExists(gN))
	String gN_new=uniquename(gN,11,0)
	else
		gN_new=gN
	endif
		
	newDatafolder /o/s $("root:graphsave:FSMs:"+gN_new)
	Dowindow /C /W=$gN $gN_new
	
	GetWindow /Z  $mapwin wtitle
	String wname=S_value
	duplicate /o w_image,$wname
	Wave FSM=$wname
	
	InitialProcnotestr2D(FSM,"FSM")
	
	Appendimage /W=$gN_new FSM
	
	FSM_Style(gN_new,0)
	
	SetDataFolder DF
	//SetWindow $gN, hook(MyHook) = MygraphHook
	
End


static Function proc_bt_plot_FSM(ctrlname)
	String ctrlName
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	
	controlinfo FSMproc_c4
	Variable plot3Dflag=v_value
	
	if (plot3Dflag)
		NVAR gv_multicubeflag=DFR_panel:gv_multicubeflag
		NVAR gv_cubenum=DFR_panel:gv_cubenum
		if (gv_multicubeflag==0)
			Cal_3D_FSM(0)
		else
			Variable index=1
			do
				Cal_3D_FSM(index)
				index+=1
			while (index<(gv_cubenum+1))
		endif
		
		if (gv_multicubeflag==0)
			index=0
		else
			index=1
		endif
		
		string kxkykzname,FSMname
		
		String winame=winname(0,65)
		String imageinfostr=imageinfo(winame,"w_image",0)
		Variable temppos=strsearch(imageinfostr,"ctab=",0)
		Variable temppos1=strsearch(imageinfostr,"}",temppos)
		String ctabstr=imageinfostr[temppos,temppos1]

		DFREF DFR_map3D=$(DF_panel+":FSM3Dshow")
		
		SetDatafolder DFR_map3D
		
		String gizmoname=winname(0,4096)
		if (strlen(gizmoname)==0)
			string cmd="newGizmo /N=BZ_3D_show"
  			Execute cmd
   			cmd= "ModifyGizmo aspectRatio=1"
   			Execute cmd
   			cmd="modifyGizmo showAxisCue=1"
   			Execute cmd
  		endif
  	
  	
		do		
			if  (index>0)
				kxkykzname="cf_waveform3D"+"_"+num2str(index)
				FSMname="cf_waveform"+"_"+num2str(index)
			else
				kxkykzname="cf_waveform3D"
				FSMname="cf_waveform"
			endif
			
			Wave kxkykzcube=DFR_map3D:$kxkykzname
			Wave FSM=DFR_map3D:$FSMname
			
			Cal_colorwave_from_Image(FSM,ctabstr,1,1,4)
			String FSMcolorname=FSMname+"_Color"
			
			cmd="RemoveFromGizmo /Z /N=BZ_3D_show object="+kxkykzname
			Execute cmd
			cmd="AppendToGizmo /N=BZ_3D_show/D surface="+kxkykzname+" name="+kxkykzname
	 		Execute cmd
	 		cmd= "ModifyGizmo modifyObject="+kxkykzname+", property={srcMode, 4}"
	 		Execute cmd
	 		cmd= "ModifyGizmo modifyObject="+kxkykzname+", property={surfaceColorType, 3}"
  			Execute cmd
  			cmd= "ModifyGizmo modifyObject="+kxkykzname+", property={surfaceColorWave, "+FSMcolorname+"}"
  			Execute cmd
  			if (index==0)
  				break
  			endif
	 		index+=1
		while (index<(gv_cubenum+1)) 
		
		
		
	else
		String mapwin=winname(0,65)
		SetDataFolder DFR_panel

		Wave w_image=DFR_common:w_image
	
		GetWindow /Z  $mapwin wtitle
		String wname=S_value
		duplicate /o w_image,$wname
		Wave FSM=$wname
	
		InitialProcnotestr2D(FSM,"FSM")

		if (stringmatch(ctrlname,"FSMproc_b31"))
			display_wave(FSM,0,1)
		else
			display_wave(FSM,2,1)	
		endif
		Killwaves /Z FSM
	endif
	SetDataFolder DF
End



static Function FSM_proc(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	
	SetDataFolder DFR_panel

	
	WAVE w_image = DFR_common:w_image
	
	if (stringmatch(ctrlname,"FSMproc_b3"))
		w_image=(numtype(w_image)==2)?(-1):(w_image)
	else
		w_image=(w_image==-1)?(Nan):(w_image)
	endif
	Panelimageupdate(-1)	
	
	SetDataFolder DF
	
End	


static Function sym_Load_Map(ctrlName):Buttoncontrol
String ctrlName
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	SetDataFolder DFR_panel
	
	String name 
	String cmd = "CreateBrowser prompt=\"select soucre data to add, and click 'ok'\""
	execute cmd
	SVAR S_BrowserList=S_BrowserList
	NVAR V_Flag=V_Flag
		if(V_Flag==0)
			SetDataFolder DF
			return -1
		endif
	Name=Stringfromlist(0,S_BrowserList)
	Wave TempW=$Name
	duplicate /O tempW DFR_common:w_image
	Panelimageupdate(-1)
	Adjustdisplayratio(2)
	SetDataFolder DF
End

static Function sym_update_Map(ctrlName):Buttoncontrol
String ctrlName
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	SetDataFolder DFR_panel
	
	Wave w_image=DFR_common:w_image
	wave FSM=FSM_kxky

		
	duplicate /O w_image FSM 
	Panelimageupdate(-1)
	Adjustdisplayratio(2)
	SetDataFolder DF
End



static Function sym_undo_Map(ctrlName):Buttoncontrol
	String ctrlName
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	SetDataFolder DFR_panel
	
	wave FSM=FSM_kxky
		
	duplicate /O FSM DFR_common:w_image
	Panelimageupdate(-1)
	Adjustdisplayratio(2)
	SetDataFolder DF
End



static Function c_correlation(name,value)
	String name
	Variable value
	SetActiveSubwindow $winname(0,65)
	
	Variable bVal
		strswitch (name)
		case "normal_c21":
			bVal= 1
			break
		case "normal_c22":
			bVal= 2
			break
	endswitch
	CheckBox normal_c21,value= bVal==1
	CheckBox normal_c22,value= bVal==2
End

static Function c_TMF_norm(name,value)
	String name
	Variable value
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	
	NVAR normmethodflag=DFR_panel:gv_normmethodflag
	
	Variable bVal
	strswitch (name)
		case "normal_c1":
			bVal= 0
			break
		case "normal_c2":
			bVal= 1
			break
		case "normal_c3":
		    bVal= 2
		    break
		case "normal_c4":
		    bVal= 3
		    break    
	endswitch
	CheckBox normal_c1,value= bVal==0
	CheckBox normal_c2,value= bVal==1
	Checkbox normal_c3,value= bVal==2
	Checkbox normal_c4,value= bVal==3

	normmethodflag=bVal
End

static Function raw_map_method(ctrlname,value)
String ctrlname
Variable value
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
		
	SetDatafolder DFR_panel
	NVAR gv_rawmappingmethodflag

	Variable checkVal
	strswitch (ctrlname)
	case "settings_ck01":
	checkVal= 0
	break
	case "settings_ck02":
	checkVal= 1
	break
	endswitch
	
	CheckBox settings_ck01,value= checkVal==0
	CheckBox settings_ck02,value= checkVal==1
	gv_rawmappingmethodflag=checkval
	SetDatafolder DF
end


static Function dimflag_method(ctrlname,value)
String ctrlname
Variable value
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
		
	SetDatafolder DFR_panel
	NVAR gv_dimflag
	Variable checkVal
	strswitch (ctrlname)
	case "settings_ck05":
	checkVal= 1
	break
	case "settings_ck06":
	checkVal= 2
	break
	case "settings_ck07":
	checkVal= 3
	break
	case "settings_ck08":
	checkVal= 4 //DA30
	break
	endswitch
	
	CheckBox settings_ck05,value= checkVal==1
	CheckBox settings_ck06,value= checkVal==2
	CheckBox settings_ck07,value= checkVal==3
	CheckBox settings_ck08,value= checkVal==4
	gv_dimflag=checkval
	SetDatafolder DF
End
	
static Function c_map_method(ctrlname,value)
String ctrlname
Variable value
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
		
	
	NVAR gv_mappingmethodflag=DFR_panel:gv_mappingmethodflag

	Variable checkVal
	Variable rawcheck=0
	strswitch (ctrlname)
	case "settings_ck03":
		if (value)
			checkVal= 2
		else
			checkVal= 1
		endif
		break
	case "settings_ck04":
		if (value)
			checkVal= 3
		else
			checkVal= 1
		endif
		break
	case "settings_ck04_raw":
		if (value)
			checkVal= 3
			rawcheck=1
		else
			checkVal= 1
		endif
		break	
	endswitch
	
	CheckBox settings_ck03,value= checkVal==2
	CheckBox settings_ck04,value= checkVal==3
	gv_mappingmethodflag=checkval
	if (checkval==3)
		NVAR gv_slicedensity=DFR_panel:gv_slicedensity
		NVAR gv_angdensity=DFR_panel:gv_angdensity
		if (numtype(gv_slicedensity)==2)
			gv_slicedensity=0.3
		endif
		if (numtype(gv_angdensity)==2)
			gv_angdensity=0.3
		endif
		if (rawcheck)
			raw_map_method("settings_ck01",1)
		endif
	endif
	SetDatafolder DF
end

static Function c_proc_Intep_method(name,value)
	String name
	Variable value
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	
	NVAR gv_Interpmethodflag=DFR_panel:gv_Interpmethodflag
	
	Variable checkVal
	strswitch (name)
	case "options_c3":
	checkVal=0
	break
	case "options_c4":
	checkVal=1
	break
	case "options_c5":
	checkVal=2
	break
	endswitch
	
    CheckBox options_c3,value= checkVal==0
    CheckBox options_c4,value= checkVal==1
    CheckBox options_c5,value= checkVal==2
    
    gv_Interpmethodflag=checkval
End

//static Function c_proc_old_style_map(name,value)
//	String name
//	Variable value
//	SetActiveSubwindow $winname(0,65)
	
//	Variable checkVal
//	strswitch (name)
//	case "options_c1":
//	checkVal=1
//	break
//	case "options_c2":
//	checkVal=2
//	break
//	endswitch
	
//    CheckBox options_c1,value= checkVal==1
//    CheckBox options_c2,value= checkVal==2
    
//    if (checkval==2)
//    CheckBox options_c0,value=0,disable=1
//    else
//    CheckBox options_c0, disable=0
//    endif
	
//End


static Function sym_mapper_cube(CtrlName)
 	String ctrlName
 	DFREF DF=GetDatafolderDFR()
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	
 	Wave /Z kxkycube=DFR_panel:cfe_kxkycube
 
 	if(waveexists(kxkycube)==0)
 		master_mapper("Mapper_3D")
	
		Wave kxkycube=DFR_panel:cfe_kxkyCube
 	endif
 	
 	controlinfo FSMproc_ck2
	Variable autokgridflag=v_value
 	controlinfo FSMproc_p3
	Variable overflag=v_value
 
	Controlinfo FSMproc_p0
	Variable symvalue=V_value
	
	Controlinfo FSMproc_p1
	Variable startflag=V_value-1
	
 	Wave cube_temp=Macro_sym_cube(DFR_panel,kxkycube,symvalue,autokgridflag,overflag,startflag)
 	
 	duplicate /o cube_temp kxkycube
 	killwaves /Z cube_temp 
 	
 	
 	String mappername=winname(0,65)
	String suffix=mappername[strsearch(mappername,"_",inf,1)+1,inf]
	String cubename="Cube_"+suffix
	
	prompt cubename,"Input Cube name"
	doprompt "Input Cube name",cubename
	
	if (V_flag)
		return 0
	endif
	
	DFREF DF_save=root:graphsave:cubes
	
	Duplicate /o kxkycube,DF_save:$cubename
 	
 	//FSM_enable3DShow("dummy")
 //	Panelimageupdate(-1)
 	//Adjustdisplayratio(2)
 	Killwaves /Z kxkycube
	SetDataFolder DF
End


static Function sym_mapper_waves(CtrlName)
 	String ctrlName
 	DFREF DF=GetDatafolderDFR()
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	
 	Wave FSM=DFR_common:w_image
 
 	controlinfo FSMproc_ck2
	Variable autokgridflag=v_value
 	controlinfo FSMproc_p3
	Variable overflag=v_value

	Controlinfo FSMproc_p0
	Variable symvalue=V_value
	
	Controlinfo FSMproc_p1
	Variable startflag=V_value-1
	
 	Wave FSM_temp=Macro_sym_mapper(DFR_panel,FSM,symvalue,autokgridflag,overflag,startflag)
 	duplicate /o FSM_temp FSM
 	killwaves /Z FSM_temp 
 	Panelimageupdate(-1)
 	Adjustdisplayratio(2)
	SetDataFolder DF
End

Function DeleteNanEdgeFSM(FSM)
	Wave FSM
	Variable p0,p1,q0,q1
	duplicate /o FSM FSM_Cut_temp
	Wave FSM_Cut_temp
	p0=detect_value_edge(FSM_Cut_temp,0,0)
	p1=detect_value_edge(FSM_Cut_temp,0,1)
	q0=detect_value_edge(FSM_Cut_temp,1,0)
	q1=detect_value_edge(FSM_Cut_temp,1,1)

	duplicate /o /R=[p0,p1][q0,q1] FSM_Cut_temp FSM_temp 
	Killwaves /Z  FSM_Cut_temp
end









////////////////////////normalize panel///////////////////////////

static Function Initial_normal_mapper_cubenum(DFR_panel,DFR_normal,cubenum)
	DFREF DFR_panel
	DFREF DFR_normal
	Variable cubenum
	
	DFREF DF=GetDatafolderDFR()
	
	SetDatafolder DFR_normal
	
	
	SetDatafolder DF
End

static Function /DF Initial_normalmappanel()
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	SetDataFolder DFR_panel
	
	NVAR gv_multicubeflag=DFR_panel:gv_multicubeflag
	NVAR gv_cubenum=DFR_panel:gv_cubenum
	NVAR gv_centerE=DFR_panel:gv_centerE
	NVAR gv_dE=DFR_panel:gv_dE
	
	newDatafolder /o/s normal_mapper
	DFREF DFR_normal=GetDatafolderDFR()
	
	Variable /G gv_normalval
	Variable /G gv_slicenum
	Variable /G gv_rawcubenum
	Variable /G gV_centerE_normal=gv_centerE
	Variable /G gv_dE_normal=gv_dE
	
	Make /Wave/o/n=5 Waveref_normal
	Make /o/n=2, Sliceplot_Y,sliceplot_X
	
	Sliceplot_Y[0]=-inf
	Sliceplot_Y[1]=inf
	sliceplot_X=gv_slicenum
	
	String Rawcubename="cfe_rawcube"
	String Normwavename="Wave_normal"
	String Smtwavename="Wave_normal_S"
	
	if (gv_multicubeflag==0) //singlecube
		gv_rawcubenum=0
	else
		gv_rawcubenum=1
		Rawcubename+="_"+num2str(gv_rawcubenum)
		Normwavename+="_"+num2str(gv_rawcubenum)
		Smtwavename+="_"+num2str(gv_rawcubenum)
		
	endif
	
	Waveref_normal[0]=DFR_panel:$Rawcubename
	Waveref_normal[1]=DFR_panel:$Normwavename
	Waveref_normal[2]=DFR_panel:$Smtwavename
	
	Wave wave_normal_S=DFR_panel:$Smtwavename

	duplicate /o wave_normal_S,wave_normal_S_backup
	
	make_cf_waveform(Waveref_normal[0],gv_centerE_normal,gv_dE_normal/1000)
	
	Wave cf_waveform
	Waveref_normal[3]=cf_waveform
	
	duplicate /o cf_waveform,cf_waveform_backup
	cf_waveform_backup/=wave_normal_S_backup[p]
	Waveref_normal[4]=cf_waveform_backup
	
	SetDatafolder DF
	return DFR_normal
End

static function open_normalmap_panel(ctrlname)
	String ctrlname
	
	DFREF DF = GetDataFolderDFR()
		
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	SetDataFolder DFR_panel
	
	String wname=winname(0,65)

	String Cwnamelist=ChildWindowList(wname)
	
	if (Findlistitem("Normal_mapper",Cwnamelist,";",0)!=-1)
 		KillWindow $wname#Normal_mapper
 		SetDatafolder DF
 		return 0
	endif
	
	Variable SC=ScreenSize(5)
	Variable width=430*SC,Height=600*SC
	
	DFREF DFR_normal= Initial_normalmappanel()
	
	SetDatafolder DFR_normal
	
	NewPanel /Host=$wname/EXT=0/K=1/W=(0,0,width,Height)/N=Normal_mapper as "Normal_mapper"
	
	Modifypanel /W=$wname#Normal_mapper cbRGB=(52428,52428,52428)
	ModifyPanel /W=$wname#Normal_mapper noEdit=1, fixedSize=1
	
	DefineGuide UGH0={FT,30*SC},UGH1={FT,450*SC}
    	DefineGuide UGH2={FL,30*SC},UGH3={FL,400*SC}
    	Display   /FG=(UGH2,UGH0,UGH3,UGH1)/Host=$wname#Normal_mapper /N=Normal_InsertTrace as "DataTableInsetImage"
    	
    	NVAR gv_rawcubenum=DFR_normal:gv_rawcubenum
    	
    	update_wavenormal_disp(gv_rawcubenum)
    	
	Wave /Wave Waveref_normal=DFR_normal:Waveref_normal
	
	Wave cf_waveform=Waveref_normal[3]
	
	Appendimage /W=$wname#Normal_mapper#Normal_InsertTrace /L=Left_map cf_waveform 
	ModifyGraph /W=$wname#Normal_mapper#Normal_InsertTrace  axisEnab(bottom)={0,0.98}
	ModifyGraph /W=$wname#Normal_mapper#Normal_InsertTrace tlOffset(Left_map)=-30,freePos(Left_map)={0.98,kwFraction}
	ModifyGraph /W=$wname#Normal_mapper#Normal_InsertTrace standoff(left)=0
	ModifyGraph /W=$wname#Normal_mapper#Normal_InsertTrace axisEnab(left)={0,0.40}
	ModifyGraph /W=$wname#Normal_mapper#Normal_InsertTrace  axisEnab(Left_map)={0.40,1}
	
	
	Wave sliceplot_Y,sliceplot_X
	Appendtograph /W=$wname#Normal_mapper#Normal_InsertTrace /L=Left_slice  sliceplot_Y vs  sliceplot_X
	ModifyGraph /W=$wname#Normal_mapper#Normal_InsertTrace lstyle(Sliceplot_Y)=7,lsize(Sliceplot_Y)=0.5
	ModifyGraph /W=$wname#Normal_mapper#Normal_InsertTrace freePos(Left_slice)=100
	SetAxis /W=$wname#Normal_mapper#Normal_InsertTrace Left_slice -1,1
	
	NVAR gv_multicubeflag=DFR_panel:gv_multicubeflag
	NVAR gv_cubenum=DFR_panel:gv_cubenum
	Setvariable Nor_map_sv0, pos={30*SC,470*SC},size={100*SC,20*SC},title="CubeNum:",variable=gv_rawcubenum,proc=mapperpanel#proc_sv_changecubenum
	if (gv_multicubeflag==0)
		Setvariable Nor_map_sv0,limits={0,0,1}
	else
		Setvariable Nor_map_sv0,limits={1,gv_cubenum,1}
	endif
	Wave wave_normal=Waveref_normal[1]
	Wave wave_normal_S=Waveref_normal[2]
	
	Setvariable Nor_map_sv1, pos={140*SC,470*SC},size={130*SC,20*SC},limits={-inf,inf,0.01},title="CenterE(eV):",variable=gv_CenterE_normal,proc=mapperpanel#update_waveform_for_normal
	Setvariable Nor_map_sv2, pos={300*SC,470*SC},size={100*SC,20*SC},limits={-inf,inf,10},title="dE(meV):",variable=gv_dE_normal,proc=mapperpanel#update_waveform_for_normal
	
	Setvariable Nor_map_sv3, pos={30*SC,500*SC},size={100*SC,20*SC},limits={0,numpnts(wave_normal_S)-1,1},title="SliceNum:",variable=gv_slicenum,proc=mapperpanel#proc_sv_set_slicenum
	slider Nor_map_sl3, pos={140*SC,500*SC},size={150*SC,20*SC},ticks=0,vert=0,limits={0,numpnts(wave_normal_S)-1,1},title="SliceNum:",variable=gv_slicenum
	slider Nor_map_sl3, proc=mapperpanel#proc_slider_set_slicenum

	NVAR gv_normalval,gv_slicenum
	 
	gv_normalval=wave_normal_S[gv_slicenum]
	slider Nor_map_sl4, pos={410*SC,400*SC},size={50*SC,170*SC},ticks=0,vert=1,limits={gv_normalval*0.9,gv_normalval*1.1,0.01*gv_normalval},title="SliceNum:",variable=gv_normalval
	slider Nor_map_sl4, proc=mapperpanel#proc_slider_set_normalval
	Setvariable Nor_map_sv4, pos={300*SC,500*SC},size={100*SC,20*SC},limits={-inf,inf,gv_normalval*0.1},title="SetVal:",variable=gv_normalval,proc=mapperpanel#proc_sv_set_normalval
	
	
	Button Nor_map_bt0, pos={30*SC,565*SC},size={100*SC,20*SC},title="Update Map",proc=mapperpanel#proc_bt_updatemappernormal
	Button Nor_map_bt1, pos={145*SC,565*SC},size={60*SC,20*SC},title="Reset",proc=mapperpanel#proc_bt_reset_normalwave
	Button Nor_map_bt10, pos={215*SC,565*SC},size={60*SC,20*SC},title="Undo",proc=mapperpanel#proc_bt_reset_normalwave
	Button Nor_map_bt2, pos={300*SC,565*SC},size={60*SC,20*SC},title="Close",proc=mapperpanel#close_normal_map_panel

	SetDatafolder DF
End


static Function update_wavenormal_disp(gv_rawcubenum)
	Variable gv_rawcubenum
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_normal=$(DF_panel+":normal_mapper")
	
	String wname=winname(0,65)
	
	String list=tracenamelist(wname+"#Normal_mapper#Normal_InsertTrace",";",1)
	String tracename
	Variable index
	do
		tracename=Stringfromlist(index,list,";")
		if (Strlen(tracename)==0)
			break
		endif
		if (strsearch(tracename,"Wave_normal",0)!=-1)
			removefromgraph /Z /W=$wname#Normal_mapper#Normal_InsertTrace $tracename
		endif
		index+=1
	while (1)

	Wave /Wave Waveref_normal=DFR_normal:Waveref_normal
	
    	Wave wave_normal=Waveref_normal[1]
    	Wave wave_normal_S=Waveref_normal[2]
	
	Appendtograph /W=$wname#Normal_mapper#Normal_InsertTrace Wave_normal 
	Appendtograph  /W=$wname#Normal_mapper#Normal_InsertTrace Wave_normal_S
	
	ModifyGraph /W=$wname#Normal_mapper#Normal_InsertTrace axisEnab(left)={0,0.40}
	
	String wave_normalname=nameofwave(wave_normal)
	String wave_normalname_smth=nameofwave(wave_normal_S)
	ModifyGraph /W=$wname#Normal_mapper#Normal_InsertTrace mode($wave_normalname_smth)=4,marker($wave_normalname_smth)=8,msize($wave_normalname_smth)=3
	ModifyGraph /W=$wname#Normal_mapper#Normal_InsertTrace rgb($wave_normalname)=(0,0,52224)
	ModifyGraph   /W=$wname#Normal_mapper#Normal_InsertTrace minor(bottom)=1,sep(bottom)=1
	
End

static Function proc_sv_changecubenum(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_normal=$(DF_panel+":normal_mapper")
	
	Wave /Wave Waveref_normal=DFR_normal:Waveref_normal
	
	String Rawcubename="cfe_rawcube"
	String Normwavename="Wave_normal"
	String Smtwavename="Wave_normal_S"
	
	NVAR gv_rawcubenum=DFR_normal:gv_rawcubenum
	
	Rawcubename+="_"+num2str(gv_rawcubenum)
	Normwavename+="_"+num2str(gv_rawcubenum)
	Smtwavename+="_"+num2str(gv_rawcubenum)
	
	Waveref_normal[0]=DFR_panel:$Rawcubename
	Waveref_normal[1]=DFR_panel:$Normwavename
	Waveref_normal[2]=DFR_panel:$Smtwavename
	
	update_wavenormal_disp(gv_rawcubenum)
	update_waveform_for_normal("",0,"","") 
	
	///updatecontrols
	NVAR gv_slicenum=DFR_normal:gv_slicenum
	gv_slicenum=0
	
	Wave wave_normal=Waveref_normal[1]
	Wave wave_normal_S=Waveref_normal[2]
	
	Setvariable Nor_map_sv3, win=$winname(0,65)#Normal_mapper,limits={0,numpnts(wave_normal_S)-1,1}
	slider Nor_map_sl3, win=$winname(0,65)#Normal_mapper, limits={0,numpnts(wave_normal_S)-1,1}
	proc_sv_set_slicenum ("dummy",0,"","")
	
End


static function proc_bt_updatemappernormal(ctrlname)
	String ctrlname
	master_mapper("dummy")
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_normal=$(DF_panel+":normal_mapper")
	
	SetDAtafolder DFR_normal
	
	NVAR centerE=DFR_normal:gv_centerE_normal
	NVAR dE=DFR_normal:gv_dE_normal
	
	Wave /Wave Waveref_normal=DFR_normal:Waveref_normal
	
	make_cf_waveform(Waveref_normal[0],centerE,dE/1000)
	Wave cf_waveform
	
	Wave wave_normal=Waveref_normal[1]
    	Wave wave_normal_S=Waveref_normal[2]
    	
    	Duplicate /o cf_waveform,cf_waveform_backup
    	
    	Duplicate /o wave_normal_S,wave_normal_S_backup
    	
	Wave wave_normal_S_backup,cf_waveform_backup
	cf_waveform_backup/=wave_normal_S_backup[p]
	cf_waveform=cf_waveform_backup[p][q]*wave_normal_S[p]
End


static Function proc_slider_set_normalval(name, value, event) : SliderControl
	String name	// name of this slider control
	Variable value	// value of slider
	Variable event	// bit field: bit 0: value set; 1: mouse down, 
					//   2: mouse up, 3: mouse moved
	update_normalvar_to_normalwave()
	update_rawcube_waveform()
	
	return 0	// other return values reserved
End

static Function proc_sv_set_normalval (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_normal=$(DF_panel+":normal_mapper")
	
	update_normalvar_to_normalwave()
	update_rawcube_waveform()
	
	NVAR gv_normalval=DFR_normal:gv_normalval 
	slider Nor_map_sl4, win=$winname(0,65)#Normal_mapper,limits={gv_normalval*0.9,gv_normalval*1.1,0.01*gv_normalval}
	


	
End

static function update_waveform_for_normal(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_normal=$(DF_panel+":normal_mapper")
	
	SetDAtafolder DFR_normal
	
	NVAR centerE=DFR_normal:gv_centerE_normal
	NVAR dE=DFR_normal:gv_dE_normal
	
	Wave /Wave Waveref_normal=DFR_normal:Waveref_normal
	
	make_cf_waveform(Waveref_normal[0],centerE,dE/1000)
	Wave cf_waveform
	
	Duplicate /o cf_waveform,cf_waveform_backup
	Wave wave_normal_S_backup,cf_waveform_backup
	cf_waveform_backup/=wave_normal_S_backup[p]
	
    	Wave wave_normal=Waveref_normal[1]
    	Wave wave_normal_S=Waveref_normal[2]

    	cf_waveform=cf_waveform_backup[p][q]*wave_normal_S[p]
    	doupdate;
    	
	SEtDatafolder DF
End

static function update_rawcube_waveform()
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_normal=$(DF_panel+":normal_mapper")
	
	Wave /Wave Waveref_normal=DFR_normal:Waveref_normal
    	Wave wave_normal=Waveref_normal[1]
    	Wave wave_normal_S=Waveref_normal[2]
    	Wave cf_waveform=Waveref_normal[3]
    	Wave cf_waveform_backup=Waveref_normal[4]

    	cf_waveform=cf_waveform_backup[p][q]*wave_normal_S[p]
    	doupdate;
    	
End

static function update_normalvar_to_normalwave()
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_normal=$(DF_panel+":normal_mapper")
	
	NVAR gv_normalval=DFR_normal:gv_normalval 
	NVAR gv_slicenum=DFR_normal:gv_slicenum   	
	Wave /Wave Waveref_normal=DFR_normal:Waveref_normal
    	Wave wave_normal=Waveref_normal[1]
    	Wave wave_normal_S=Waveref_normal[2]
    	
    	Wave sliceplot_X=DFR_normal:sliceplot_X
	Wave sliceplot_y=DFR_normal:sliceplot_y
	sliceplot_X=gv_slicenum
	sliceplot_y[0]=-inf
	sliceplot_y[1]=-0.15
    	
    	
	wave_normal_S[gv_slicenum]=gv_normalval
	doupdate;
End

static Function proc_slider_set_slicenum(name, value, event) : SliderControl
	String name	// name of this slider control
	Variable value	// value of slider
	Variable event	// bit field: bit 0: value set; 1: mouse down, 
					//   2: mouse up, 3: mouse moved
					
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_normal=$(DF_panel+":normal_mapper")
	
	NVAR gv_slicenum=DFR_normal:gv_slicenum
	
	Wave sliceplot_X=DFR_normal:sliceplot_X
	Wave sliceplot_y=DFR_normal:sliceplot_y
	sliceplot_X=gv_slicenum
	sliceplot_y[0]=-inf
	sliceplot_y[1]=inf
	
	Wave /Wave Waveref_normal=DFR_normal:Waveref_normal
    	Wave wave_normal=Waveref_normal[1]
    	Wave wave_normal_S=Waveref_normal[2]
    	
    	NVAR gv_normalval=DFR_normal:gv_normalval    	
    	gv_normalval=wave_normal_S[gv_slicenum]
    	
	slider Nor_map_sl4, win=$winname(0,65)#Normal_mapper,limits={gv_normalval*0.9,gv_normalval*1.1,0.01*gv_normalval}
	Setvariable Nor_map_sv4,win=$winname(0,65)#Normal_mapper, limits={-inf,inf,gv_normalval*0.1}			
	return 0
end

static Function proc_sv_set_slicenum (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_normal=$(DF_panel+":normal_mapper")
	
	NVAR gv_slicenum=DFR_normal:gv_slicenum
	
	Wave sliceplot_X=DFR_normal:sliceplot_X
	sliceplot_X=gv_slicenum
	
	Wave /Wave Waveref_normal=DFR_normal:Waveref_normal
    	Wave wave_normal=Waveref_normal[1]
    	Wave wave_normal_S=Waveref_normal[2]
    	
    	NVAR gv_normalval=DFR_normal:gv_normalval    	
    	gv_normalval=wave_normal_S[gv_slicenum]
    	
	slider Nor_map_sl4, win=$winname(0,65)#Normal_mapper,limits={gv_normalval-0.1,gv_normalval+0.1,0.001}
	Setvariable Nor_map_sv4,win=$winname(0,65)#Normal_mapper, limits={-inf,inf,gv_normalval*0.1}
End

static Function proc_bt_reset_normalwave(ctrlname)
	String ctrlname
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_normal=$(DF_panel+":normal_mapper")
	
	Wave wave_backup=DFR_normal:wave_normal_S_backup
	
	Wave /Wave Waveref_normal=DFR_normal:Waveref_normal
    	Wave wave_normal=Waveref_normal[1]
    	Wave wave_normal_S=Waveref_normal[2]
    	
    	NVAR gv_slicenum=DFR_normal:gv_slicenum
    	
    	if (stringmatch(ctrlname,"Nor_map_bt1"))
    		Duplicate /o wave_backup,wave_normal_S
    	else
    		wave_normal_S[gv_slicenum]=wave_backup[gv_slicenum]
    	endif
    	update_rawcube_waveform()
    	doupdate;
End

static Function close_normal_map_panel(ctrlname)
	String ctrlname
	String wname=winname(0,65)
	KillWindow $wname#Normal_mapper
	
End

static Function load_wave_norm(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	SetDataFolder DFR_panel
	
	Wave /Z Wave_normal=DFR_panel:Wave_normal
	Wave /Z Wave_normal_S=DFR_panel:Wave_normal_S
	Wave /Z cfe_rawCube_c_axis=DFR_panel:cfe_rawCube_c_axis
	
	if (Waveexists(Wave_normal_S)==0)
		SetDatafolder DF
		return 0
	endif
	
	String path
	String cmd="CreateBrowser prompt=\"select the normalize wave and click 'ok'\""
	execute cmd
	SVAR S_BrowserList=S_BrowserList
	
	NVAR flag=V_Flag
		if(flag==0)
			return -1
		endif

	path = StringFromList(0,s_browserList)
	
	Wave normal_wave=$path
	
	if ((wavedims(normal_wave)==1)&&(numpnts(normal_wave)==numpnts(Wave_normal_S)))
		duplicate /o normal_wave DFR_panel:Wave_normal_S
		mapperPanel#c_TMF_norm("normal_c4",1)
	else
		SetDatafolder DF
		return 0
	endif
		
End

static Function edit_wave_norm(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	
	mapperPanel#c_TMF_norm("normal_c4",1)
	
	
	open_normalmap_panel(ctrlname)
	return 1
	
End







































