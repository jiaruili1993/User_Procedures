#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 0.01
#pragma ModuleName = Fitpanel


/////////////////////////////////global panel Function ////////////////////////////////////////

Function /DF init_fit_panel()
	DFREF DF = GetDataFolderDFR()
    	String DF_panel="root:internalUse:"+winname(0,65)
    	NewDataFolder/O/S $DF_panel
    	DFREF DFR_panel=$DF_panel
    	Variable /G gv_killflag=0
    	Variable/G V_FitOptions=4	
    	Variable/G V_FitQuitReason = 0
    
   	Variable /G gv_dimflag=1
    	Variable /G gv_Fitdimflag=0
    
    	Variable /G gv_Fermiflag=0
    	Variable /G gv_Convolveflag=0
    	Variable /G gv_Offsetflag=0
    	Variable /G gv_symbkgflag=0
    	Variable /G gv_absbkgflag=0
    
    	Variable /G gv_protectflag=0
    
    	Variable /G gv_showoptionflag=0
    
    	Variable /G gv_fit_leftrange
	Variable /G gv_fit_rightrange
	Variable /G gv_fit_autorangeflag
	String /G gs_fit_leftrange
	String /G gs_fit_rightrange
	
	String /G gs_Fit_constrain
	
	Make /o/T/n=0 Fit_Constrain_list
    
   	 Variable /G gv_parsel_row
   	 Variable /G gv_parsel_col
    	 Variable /G gv_pathnum=0
    
    	String /G gs_parName
    	Variable /G gv_parError
    	Variable /G gv_parValue
    	Variable /G gv_parConf
    	Variable /G gv_errorbardispflag
          
    	Variable /G gv_showResflag
    
    	Variable /G gv_ConfInterval=0.95
    	Variable /G gv_showConfflag
   	Variable /G gv_showpredflag
   	
   	Variable /G gv_draw_peakmode
   	Variable /G gv_draw_Xremember
   	Variable /G gv_draw_yremember
    
    	Variable /G gv_ignorefitflag
    	
    	Variable /G gv_errorlevel=10
    	
    	Variable /G gv_imageresultpnts=Nan
    	variable /G gv_weightflag=0
    
    	Make /o/n=0 CurveFit_coef
    	Make /o/n=0 CurveFit_error
    	String /G CurveFit_Hdstr
    	String /G CurveFit_Constrain
    
    	Make /o/n=0 UC_w_trace,LC_w_trace,UP_w_trace,LP_w_trace
    	Make /o/n=0 w_res
    	Make /o/n=0 W_paramConfidenceInterval,w_sigma
        
   	Make /O /n=(3,18) Color_New10 
    	Color_New10[][0]={0,0,0}
      
    	Color_New10[][1]={65358,35325,30321}
 	Color_New10[][2]={30321,40333,65358}
 	Color_New10[][3]={30321,65358,36689}
	Color_New10[][4]={65358,65356,30321}
	Color_New10[][5]={65280,32768,45824}
	Color_New10[][6]={30321,65358,60580}
	Color_New10[][7]={65358,48673,30321}
	Color_New10[][8]={44032,29440,58880}
	Color_New10[][9,16]=Color_New10[p][q-8]
	Color_New10[][17]={0,0,65535}

	
	matrixtranspose Color_New10
    
    	Make /o/n=(3,17) Color_New10_curve
    	Color_New10_curve[][0]={0,0,0}
   	Color_New10_curve[][1]={65535,0,0}
	Color_New10_curve[][2]={0,0,65535}
	Color_New10_curve[][3]={0,65535,0}
	Color_New10_curve[][4]={65535,65535,0}
	Color_New10_curve[][5]={65535,0,65535}
	Color_New10_curve[][6]={0,65535,65535}
	Color_New10_curve[][7]={65535,34327,0}
	Color_New10_curve[][8]={32767,0,65535}
	Color_New10_curve[][9,16]=Color_New10_curve[p][q-8]

    	matrixtranspose Color_New10_curve
     
    	Make /n=0 /o/t FitWavename_list
    	Make /n=0 /o/t FitWavePath_list
    	Make /n=0 /o/t FitWavePathX_list
    	Make /n=0 /o/B fitWaveName_list_sel
    
    	make /n=(5,10) /o/t PeakFns
    	make /n=(5,10) /o/t bkgFns
    	make /n=(5,10) /o/t CoefFns
    
    	Make /n=(0,1) /o/t FitPar_list
    	Make /n=(0,1,3) /o/B FitPar_list_sel
    	Make /n=(0) /o/t FitPar_list_title
    	SetDimLabel 2,1,backColors,FitPar_list_sel
    	SetDimLabel 2,2,foreColors,FitPar_list_sel
        
   	init_FitFN_text(PeakFns,bkgFns,coefFns)
    
    	duplicate /o/R=[][0] PeakFns,PeakList
    	duplicate /o/R=[][0] bkgFns,bkgList
    
 	String /G gs_PeakStrlist=WaveToStringlist(PeakList,";",Nan,Nan)
 	String /G gs_bkgStrlist=WaveToStringlist(bkglist,";",Nan,Nan)
    
    
    	String /G gs_FitPeakbkglist
   	 String /G gs_Fndisplay=""
    
    	Make /n=(0,1) /O/T FitOutputName_list
	Make /n=(0,1,2) /O/B FitOutputName_list_sel
	SetDimLabel 2,1,backColors,FitOutputName_list_sel
	Make /n=(0,1) /O/T FitOutputpar_list
	
	Make /n=(0,1) /O/T FitOutputIMG_list
	Make /n=(0,1,2) /O/B FitOutputIMG_list_sel
	SetDimLabel 2,1,backColors,FitOutputIMG_list_sel
    
    	newDatafolder /o Raw_Data
   	newDatafolder /o Fit_curves
      
    	newDatafolder /o/s Fit_Data
    	Make /n=(0,1,3) /o/t FitFnName_list //0 for display //1 for Name //2 for Fnnum
    	Make /n=(0,1,3) /o/B/U FitFnName_list_sel
    
    	SetDimLabel 2,1,backColors,FitFnName_list_sel
    	SetDimLabel 2,2,foreColors,FitFnName_list_sel
   	// Make /n=(0,1,3) /o/W/U FitFnName_list_CW
    
    	Make /n=(0,1,1) /o/t FitFnSave_strlist
    	Make /n=(0,1,1) /o/t FitFnSave_Parstr
    	Make /n=(0,1,1) /o/t FitFnSave_Constrain
    	Make /n=(0,1,6) /o FitSave_DataWave //0 for res // 1 2 for confwave // 3 4 for predwave 5 for weight wave
    
   // Make /n=(0,1,4) /o/t FitSave_Para  //0 for par, //1 for hold //2 for error //4 for conf
    
   	//Make /n=(0,1,1) /o FitSave_FitCurve //differentlayer for differnt fn
    //  	Make /n=(0,1,1) /o FitSave_FitWeight
	
	SetDataFolder DF
	return DFR_panel
End    

Function close_fit_panel(ctrlName)
	String ctrlName
	String wname=winName(0,65)
	String DF_panel="root:internalUse:"+wname
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
		
	Doalert 1,"This action will delete all the data in this fit panel. Close?"
	if (V_flag==1)
		NVAR killflag=DFR_panel:gv_killflag
		killflag=1
		dowindow/K $wname
		killdatafolder/Z $(DF_panel+":Saved_Fit_Results")
	else
		return 1
	endif				
		
End

Function open_fit_panel(ctrlName)
	String ctrlName

	DFREF DF = GetDataFolderDFR()
	Variable SC = Screensize(5)
	Variable SR = Igorsize(3) 
	Variable ST = Igorsize(2)
	Variable SL = Igorsize(1)
    	Variable SB = Igorsize(4)
    
    	
    	DFREF DFR_prefs=$DF_prefs
    	NVAR panelscale=DFR_prefs:gv_panelscale
    	NVAR macscale=DFR_prefs:gv_macscale
    
    	Variable Width = 520 *panelscale*MacScale//* SC		// panel size  
	Variable height = 400 *panelscale*MacScale//* SC
	Variable xOffset = (SR-SL)/2-width/2
	Variable yOffset = (SB-ST)/2-height/2
	
	String panelnamelist=winlist("fit_panel_*",";","WIN:65")
	
	if (stringmatch(ctrlname,"recreate_window")==0)
	
		if (strlen(panelnamelist)==0)
			string spwinname=UniqueName("fit_panel_", 9, 0)
			Display /W=(xOffset, yOffset,xOffset+width,Height+yOffset) as spwinname
			DoWindow/C $spwinname
   			Setwindow $spwinname hook(MyHook) = MypanelHook
		else
	
			if (stringmatch(ctrlname,"global_duplicate_panel"))
				//Hidedown_Allthepanel(panelnamelist)
				spwinname=UniqueName("fit_panel_", 9, 0)
				Display /W=(xOffset, yOffset,xOffset+width,Height+yOffset) as spwinname
				DoWindow/C $spwinname
   				Setwindow $spwinname hook(MyHook) = MypanelHook
			else
	
				BringUP_thefirstpanel(panelnamelist)
				SetDataFolder DF 
				return 1
			endif
		endif
		
		DFREF DFR_panel=init_fit_panel()
		DFREF DFR_common=init_graph_panelcommon()
	
	else
		BringUP_thefirstpanel(panelnamelist)
		DFREF DFR_panel=$("root:internalUse:"+winname(0,65))
		DFREF DFR_common=$("root:internalUse:"+winname(0,65)+":panel_common")
		SetActiveSubwindow $winname(0,65)
		
	endif
	
	SetDataFolder DFR_panel
	String panelcommonPath=GetDatafolder(1,DFR_common)
	String DF_panel=GetDatafolder(1)
	DFREF DFR_fitdata=$(DF_panel+"Fit_Data")
	
	
	Variable r=57000, g=57000, b=57000	// background color for the TabControl
	ModifyGraph cbRGB=(52428,52428,52428)
	ModifyGraph wbRGB=(54872,54872,54872),gbRGB=(54872,54872,54872)
	
	ControlBar 210*SC
	
	Button global_close_panel, pos={530*SC,4*SC},size={60*SC,18*SC},title="close", proc=close_fit_panel
	Button global_duplicate_panel, size={80*SC,18*SC}, pos={590*SC,4*SC},title="New Fit", proc=open_fit_panel
	
	Button global_gold, size={40*SC,20*SC},pos={645*SC,25*SC}, title="gold", proc=open_gold_panel
	Button global_main, size={40*SC,20*SC},pos={645*SC,55*SC}, title="main", proc= Open_main_Panel
	Button global_map, size={40*SC,20*SC},pos={645*SC,85*SC}, title="map", proc= open_mapper_panel
	Button global_BZ, size={40*SC,20*SC},pos={645*SC,115*SC}, title="BZ", proc=open_bz_panel
	Button global_Anal, size={40*SC,20*SC},pos={645*SC,145*SC}, title="Anal", proc=Open_Analysis_Panel
  	Button global_opdt,labelBack=(r,g,b),pos={645*SC,175*SC},size={40*SC,20*SC},title="DataT",proc=open_data_table
	
	TabControl fit,proc=FitPanel#fit_AutoTab,pos={8*SC,6*SC},size={630*SC,190*SC},value=0,labelBack=(r,g,b)
	
	TabControl fit, tabLabel(0)="source"
	
	listbox source_waves_list, pos={16*SC,45*SC}, size={200*SC,140*SC},  widths={300},listwave=DFR_common:w_sourceNames, selwave=DFR_common:w_sourceNamesSel, frame=2,mode=9, proc=Graph_Listbox_proc
	//listbox source_prolist, pos={133,45}, size={90,110}, listwave=DFR_common:w_proclist,selwave=DFR_common:w_proclistsel, frame=2,mode=5,proc=proc_Listbox_proc
	Titlebox source_tb1,title="Image",pos={20*SC,30*SC},labelBack=(r,g,b),frame=0,variable=DFR_common:gs_currentDF
	checkbox source_ck1,title="Image",pos={380*SC,28*SC},size={60*SC,20*SC},labelBack=(r,g,b),value=0,frame=0,proc=proc_ck_dimsel
	checkbox source_ck0,title="Trace",pos={320*SC,28*SC},size={60*SC,20*SC},labelBack=(r,g,b),value=1,frame=0,proc=proc_ck_dimsel
	checkbox source_ck2,title="Sort",pos={445*SC,28*SC},size={60*SC,20*SC},labelBack=(r,g,b),variable=DFR_common:gv_sortopt,frame=0,proc=proc_ck_sortopt
	
	//Titlebox source_tb2,title="Proc",pos={145,30},labelBack=(r,g,b),frame=0,disable=1
	
	//selwave=DFR_common:w_DFListsel,
	GroupBox source_gb0, frame=0,labelBack=(r,g,b), pos={220*SC,35*SC}, size={285*SC,132*SC}, title="source graph"
	listbox source_lb1, pos={230*SC,70*SC}, size={250*SC,90*SC},  widths={400},listwave=DFR_common:w_DF, selrow=0, frame=2,mode=6, proc=graph_Listbox_proc
    	SetVariable source_sv0,labelBack=(r,g,b), pos={230*SC,50*SC},size={110*SC,20*SC}, title="search",frame=1,value=DFR_common:gs_matchstring,proc=graph_list_search_proc
    	Button source_bt0,labelBack=(r,g,b),pos={340*SC,48*SC},size={35*SC,20*SC},title="All",proc=Default_graph_proc
    	Button source_bt1,labelBack=(r,g,b),pos={380*SC,48*SC},size={35*SC,20*SC},title="EDC",proc=Default_graph_proc
    	Button source_bt2,labelBack=(r,g,b),pos={420*SC,48*SC},size={35*SC,20*SC},title="MDC",proc=Default_graph_proc
    	Button source_bt3,labelBack=(r,g,b),pos={460*SC,48*SC},size={35*SC,20*SC},title="IMG",proc=Default_graph_proc
   
   	Titlebox source_tb3,title="selected wave",pos={530*SC,30*SC},labelBack=(r,g,b),frame=0//,variable=DFR_common:gs_currentDF
  	Listbox source_lb0, widths={300},listwave=DFR_panel:FitWavename_list,selwave=DFR_panel:fitWaveName_list_sel,size={120*SC,120*SC},pos={510*SC,45*SC}, frame=2,editstyle=0,mode=9//,proc=source_Listbox_map_proc,disable=1
	
	 
	Button source_b2,pos={280*SC,170*SC},size={45*SC,20*SC},title="All--> ", proc=AddmainpanelSel
	Button source_b3,pos={230*SC,170*SC},size={45*SC,20*SC},title="Sel-->", proc=AddmainpanelSel
	Button source_b6,pos={330*SC,170*SC},size={45*SC,20*SC},title="Sel<--", proc=AddmainpanelSel
	
	Button source_b4,pos={585*SC,170*SC},size={45*SC,20*SC},title="<--Sel", proc=RemoveListSel
	Button source_b5,pos={510*SC,170*SC},size={70*SC,20*SC},title="Clear all", proc=RemoveListSel
	
	//Groupbox select_gb0, size={150,60},pos={300,33},title="select from browser",disable=1
	Button source_b7,pos={380*SC,170*SC},size={60*SC,20*SC},title="Browser", proc=AddbrowserSel
	Button source_b9,pos={455*SC,170*SC},size={40*SC,20*SC},title="Graph", proc=BringFrontGraph
	
	TabControl fit, tabLabel(1)="Function"
	Listbox Function_lb0,listwave=DFR_panel:Peaklist,size={120*SC,85*SC},pos={370*SC,50*SC}, frame=2,editstyle=0,mode=2,disable=1//,proc=source_Listbox_map_proc,disable=1
 	Listbox Function_lb1,listwave=DFR_panel:bkglist,size={120*SC,85*SC},pos={500*SC,50*SC}, frame=2,editstyle=0,mode=2,disable=1//,proc=source_Listbox_map_proc,disable=1
	Button Function_bt0,size={120*SC,18*SC},pos={370*SC,137*SC},title="Add Peak",disable=1,proc=fitpanel#proc_bt_AddPeaks
	Button Function_bt1,size={120*SC,18*SC},pos={500*SC,137*SC},title="Add bkg",disable=1,proc=fitpanel#proc_bt_Addbkgs
	Checkbox Function_ck0,size={80*SC,20*SC},pos={370*SC,160*SC},title="Fermi Fn",variable=gv_Fermiflag,disable=1,proc=fitpanel#proc_ck_Fncoef
	Checkbox Function_ck1,size={80*SC,20*SC},pos={450*SC,160*SC},title="Convolve",variable=gv_Convolveflag,disable=1,proc=fitpanel#proc_ck_Fncoef
	Checkbox Function_ck2,size={80*SC,20*SC},pos={530*SC,160*SC},title="Slope offset",variable=gv_Offsetflag,disable=1,proc=fitpanel#proc_ck_Fncoef
	Checkbox Function_ck3,size={80*SC,20*SC},pos={370*SC,177*SC},title="Sym Bkg",variable=gv_symbkgflag,disable=1,proc=fitpanel#proc_ck_Fncoef
	Checkbox Function_ck4,size={80*SC,20*SC},pos={450*SC,177*SC},title="ABS Bkg",variable=gv_absbkgflag,disable=1,proc=fitpanel#proc_ck_Fncoef
	
	Button Function_bt2,size={50*SC,20*SC},pos={20*SC,165*SC},title="All",disable=1,proc=fitpanel#proc_bt_CopyFn
	Button Function_bt21,size={50*SC,20*SC},pos={75*SC,165*SC},title="Up",disable=1,proc=fitpanel#proc_bt_CopyFn
	Button Function_bt22,size={50*SC,20*SC},pos={130*SC,165*SC},title="Down",disable=1,proc=fitpanel#proc_bt_CopyFn
	Button Function_bt3,size={50*SC,20*SC},pos={185*SC,165*SC},title="Remove",disable=1,proc=fitpanel#proc_bt_DelFn
	Button Function_bt31,size={30*SC,20*SC},pos={240*SC,165*SC},title="<--",disable=1,proc=fitpanel#proc_bt_MoveFn
	Button Function_bt32,size={30*SC,20*SC},pos={275*SC,165*SC},title="-->",disable=1,proc=fitpanel#proc_bt_MoveFn
	Button Function_bt4,size={50*SC,20*SC},pos={310*SC,165*SC},title="Clear",disable=1,proc=fitpanel#proc_bt_delFn
	
	Listbox Function_lb2,listwave=DFR_Fitdata:FitFnName_list,selwave=DFR_Fitdata:FitFnName_list_sel,colorWave=DFR_panel:Color_New10
	Listbox Function_lb2,widths={100*SC,60*SC},size={340*SC,110*SC},pos={20*SC,50*SC}, frame=2,editstyle=0,mode=6,disable=1,proc=fitpanel#FitFn_Listbox_proc
	Setvariable Function_sv0,size={300*SC,20*SC},pos={220*SC,30*SC},title=" ",value=gs_Fndisplay,disable=1
	Button Function_bt5,size={80*SC,20*SC},pos={140*SC,28*SC},title="Set Fit",disable=1,proc=fitpanel#proc_bt_SetFitString
	Button Function_bt6,size={100*SC,20*SC},pos={520*SC,28*SC},title="Set PeakNames",disable=1,proc=fitpanel#proc_bt_Set_PeakNames
	//titlebox Function_tb2,size={120,20},pos={20,30},fsize=14,variable=gs_Fndisplay,disable=1,frame=0
	
	Checkbox Function_ck5,size={60*SC,20*SC},pos={20*SC,30*SC},title="MDC",value=1,disable=1,proc=fitpanel#proc_ck_fitdim
	Checkbox Function_ck6,size={60*SC,20*SC},pos={70*SC,30*SC},title="EDC",disable=1,proc=fitpanel#proc_ck_fitdim
	
	TabControl fit, tabLabel(2)="Fit"
	titlebox Fit_tb0,size={120*SC,20*SC},pos={20*SC,30*SC},title="Fit Curves:",disable=1,frame=0
	//Listbox Fit_lb0,listwave=DFR_Fitdata:FitFnName_list,selwave=DFR_Fitdata:FitFnName_list_sel,colorWave=DFR_panel:Color_New10
	//Listbox Fit_lb0,widths={150,60},size={145,110},pos={20,50}, frame=2,editstyle=0,mode=3,disable=1,proc=fitpanel#FitProc_Listbox_proc,disable=1
	
	Button Fit_bt0,size={60*SC,20*SC},pos={20*SC,170*SC},title="Fit",disable=1,proc=ARPES_curvefit
	Button Fit_bt1,size={40*SC,20*SC},pos={85*SC,170*SC},title="Up",disable=1,proc=step_curvefit
	Button Fit_bt2,size={40*SC,20*SC},pos={130*SC,170*SC},title="Down",disable=1,proc=step_curvefit
	
	Listbox Fit_lb1,listwave=DFR_panel:Fitpar_list,selwave=DFR_panel:Fitpar_list_sel,titlewave=DFR_panel:Fitpar_list_title,colorWave=DFR_panel:Color_New10
	Listbox Fit_lb1,size={450*SC,130*SC},pos={175*SC,30*SC}, frame=2,editstyle=0,mode=6,disable=1,proc=FitPar_Listbox_proc
	Checkbox Fit_ck0,size={120*SC,20*SC},pos={180*SC,180*SC},title="Protect Hds" ,disable=1,variable=DFR_panel:gv_protectflag
	Checkbox Fit_ck1,size={120*SC,20*SC},pos={180*SC,163*SC},title="Ignore fit" ,disable=1,variable=DFR_panel:gv_ignorefitflag

	Button Fit_bt4,size={60*SC,20*SC},pos={475*SC,170*SC},title="Marquee",disable=1,proc=Proc_bt_GuessfromMarq
	Button Fit_bt5,size={60*SC,20*SC},pos={540*SC,170*SC},title="Drawing",disable=1,proc=Proc_bt_GuessfromDrawing
//	Button Fit_bt6,size={40,20},pos={430,170},title="Up",disable=1,proc=step_curvefit
	//Button Fit_bt7,size={40,20},pos={475,170},title="Down",disable=1,proc=step_curvefit
	Button Fit_bt10,size={50*SC,20*SC},pos={285*SC,170*SC},title="Initial",disable=1,proc=fitpanel#save_curvefit_coef	
//	Button Fit_bt8,size={60*SC,20*SC},pos={340*SC,170*SC},title="SavePar",disable=1,proc=fitpanel#save_curvefit_coef
	
	Button Fit_bt11,size={60*SC,20*SC},pos={340*SC,170*SC},title="Save",disable=1,proc=fitpanel#save_Fit_result
	
	Button Fit_bt9,size={60*SC,20*SC},pos={410*SC,170*SC},title="Plot Fitting",disable=1,proc=fitpanel#plot_curvefit
	
	Button Fit_bt3,size={20*SC,20*SC},pos={610*SC,170*SC},title="@",disable=1,proc=fitpanel#Proc_bt_showoptions

	groupbox FitMore_gb0,frame=0,size={200*SC,100*SC},pos={20*SC,200*SC},title="Fit Range",disable=1	
	Setvariable FitMore_sv0,size={90*SC,20*SC},pos={30*SC,220*SC},limits={-inf,inf,0},title="Left:",value=DFR_panel:gv_fit_leftrange,disable=1,proc=fitpanel#proc_sv_changefitrange
	Setvariable FitMore_sv1,size={90*SC,20*SC},pos={125*SC,220*SC},limits={-inf,inf,0},title="Right:",value=DFR_panel:gv_fit_rightrange,disable=1,proc=fitpanel#proc_sv_changefitrange
	checkbox FitMore_Ck01,size={80*SC,20*SC},pos={30*SC,243*SC},title="Auto Range",variable=gv_fit_autorangeflag,disable=1,proc=fitpanel#proc_ck_Autorange	
	button FitMore_bt20,size={45*SC,15*SC},pos={120*SC,243*SC},title="A_Min",disable=1,proc=fitpanel#proc_bt_AutorangeFromPeak
	button FitMore_bt21,size={45*SC,15*SC},pos={170*SC,243*SC},title="A_Max",disable=1,proc=fitpanel#proc_bt_AutorangeFromPeak
	Setvariable FitMore_sv2,size={180*SC,20*SC},pos={30*SC,262*SC},title="Auto Left :",value=DFR_panel:gs_fit_leftrange,disable=1,proc=fitpanel#proc_sv_Autochangefitrange
	Setvariable FitMore_sv3,size={180*SC,20*SC},pos={30*SC,280*SC},title="Auto Right:",value=DFR_panel:gs_fit_rightrange,disable=1,proc=fitpanel#proc_sv_Autochangefitrange
	
	groupbox FitMore_gb1,frame=0,size={160*SC,100*SC},pos={230*SC,200*SC},title="Constrain",disable=1	
	Setvariable FitMore_sv4,size={100*SC,20*SC},pos={240*SC,220*SC},title=" ",value=DFR_panel:gs_Fit_constrain,disable=1//,proc=fitpanel#proc_sv_Autochangefitrange
	Button FitMore_bt0,size={40*SC,18*SC},pos={345*SC,220*SC},title="Add",disable=1,proc=fitpanel#proc_bt_AddConstrain
	Button FitMore_bt1,size={40*SC,18*SC},pos={345*SC,240*SC},title="Del",disable=1,proc=fitpanel#proc_bt_delConstrain
	Listbox FitMore_lb0,size={100*SC,55*SC},pos={240*SC,240*SC},frame=2,listwave=DFR_panel:Fit_Constrain_list,mode=2,disable=1
	
	groupbox FitMore_gb2,frame=0,size={130*SC,100*SC},pos={400*SC,200*SC},title="Detail Info",disable=1
	Setvariable FitMore_sv5,size={110*SC,20*SC},pos={410*SC,220*SC},title=" ",value=DFR_panel:gs_parName,noedit=1,disable=1,frame=2
	Setvariable FitMore_sv6,size={110*SC,20*SC},pos={410*SC,240*SC},limits={-inf,inf,0},title="Value:",value=DFR_panel:gv_parValue,noedit=1,disable=1
	Setvariable FitMore_sv7,size={110*SC,20*SC},pos={410*SC,260*SC},limits={-inf,inf,0},title="Error:",value=DFR_panel:gv_parError,noedit=1,disable=1
	Setvariable FitMore_sv8,size={110*SC,20*SC},pos={410*SC,280*SC},limits={-inf,inf,0},title="Conf :",value=DFR_panel:gv_parConf,noedit=1,disable=1
	
	groupbox  FitMore_gb3,frame=0,size={130*SC,100*SC},pos={540*SC,200*SC},title="Wave Control",disable=1
	Button  FitMore_bt2,size={30*SC,20*SC},pos={550*SC,220*SC},title="Res",disable=1, proc=proc_bt_showRes
	Setvariable FitMore_sv9,size={70*SC,20*SC},pos={590*SC,222*SC},limits={0,1,0},title="Int:",value=DFR_panel:gv_confInterval,disable=1
	Button  FitMore_bt3,size={50*SC,20*SC},pos={550*SC,240*SC},title="Conf",disable=1 ,proc=proc_bt_showconf	
	Button  FitMore_bt4,size={50*SC,20*SC},pos={610*SC,240*SC},title="Pred",disable=1 ,proc=proc_bt_showconf	
	Checkbox FitMore_ck0,size={50*SC,20*SC},pos={550*SC,262*SC},title="use Weight",disable=1, variable=gv_weightflag,proc=proc_ck_weightck
	Button  FitMore_bt5,size={80*SC,20*SC},pos={550*SC,278*SC},title="Weight Wave",disable=1 ,proc=open_weightWavepanel	
	
	TabControl fit, tabLabel(3)="Output"
	titlebox Output_tb0,size={120*SC,20*SC},pos={20*SC,30*SC},title="Peak Names:",disable=1,frame=0
	listbox Output_lb0,listwave=DFR_panel:FitOutputName_list,selwave=DFR_panel:FitOutputName_list_sel,colorWave=DFR_panel:Color_New10
	Listbox Output_lb0,size={150*SC,130*SC},pos={20*SC,50*SC},frame=2,editstyle=2,mode=6,disable=1,proc=fitpanel#FitOutput_Listbox_proc
	
	titlebox Output_tb1,size={120*SC,20*SC},pos={170*SC,30*SC},title="Par Names:",disable=1,frame=0
	listbox Output_lb1,listwave=DFR_panel:FitOutputPar_list
	Listbox Output_lb1,size={150*SC,130*SC},pos={170*SC,50*SC}, frame=2,editstyle=2,mode=2,disable=1,proc=fitpanel#FitOutput_Listbox_proc
	
	groupbox Output_gb0,frame=0,size={300*SC,105*SC},pos={330*SC,30*SC},title="display Parwave",disable=1
	button Output_b0,size={60*SC,20*SC},pos={340*SC,50*SC},title="0->Nan",disable=1,proc=fitpanel#FitOutput_stylechange
	button Output_b4,size={60*SC,20*SC},pos={340*SC,70*SC},title="Abs",disable=1,proc=fitpanel#FitOutput_stylechange
		
	button Output_b1,size={60*SC,20*SC},pos={405*SC,50*SC},title="r-g Nan",disable=1,proc=fitpanel#FitOutput_stylechange
	button Output_b7,size={60*SC,20*SC},pos={405*SC,70*SC},title="<rg> Nan",disable=1,proc=fitpanel#FitOutput_stylechange
	button Output_b2,size={60*SC,20*SC},pos={470*SC,50*SC},title="<-r Nan",disable=1,proc=fitpanel#FitOutput_stylechange
	button Output_b3,size={60*SC,20*SC},pos={470*SC,70*SC},title="g-> Nan",disable=1,proc=fitpanel#FitOutput_stylechange	
	
	Setvariable Output_sv8,size={90*SC,20*SC},pos={535*SC,50*SC},limits={-inf,inf,0},title="Error (%):",value=DFR_panel:gv_errorlevel,disable=1
	button Output_b10,size={90*SC,20*SC},pos={535*SC,70*SC},title="Error-> Nan",disable=1,proc=fitpanel#FitOutput_stylechange	
	
	
	checkbox Output_ck1,size={60*SC,20*SC},pos={340*SC,95*SC},title="Error",disable=1,value=0,proc=fitpanel#FitOutput_errorChange
	checkbox Output_ck2,size={60*SC,20*SC},pos={395*SC,95*SC},title="Conf",disable=1,value=0,proc=fitpanel#FitOutput_errorChange
	
	checkbox Output_ck0,size={80*SC,20*SC},pos={340*SC,115*SC},title="VERT",disable=1,value=0,proc=fitpanel#FitOutput_VertChange
	
	PopupMenu output_pp0,size={100*SC,20*SC},pos={395*SC,112*SC},title="xwave:",disable=1,mode=1,value="Index;Tem;PhotoE;Energy;Momentum"
	
	button output_b5,size={55*SC,18*SC},pos={510*SC,95*SC},title="Display",disable=1,proc=fitpanel#FitOutput_displayPar
	button output_b6,size={55*SC,18*SC},pos={510*SC,115*SC},title="Append",disable=1,proc=fitpanel#FitOutput_displayPar
	button output_b8,size={55*SC,18*SC},pos={570*SC,95*SC},title="Mark App",disable=1,proc=fitpanel#FitOutput_SepAppendPar
	
	
	groupbox Output_gb1,frame=0,size={300*SC,55*SC},pos={330*SC,135*SC},title="display result Image",disable=1
	
	Setvariable Output_sv1,size={90*SC,20*SC},pos={340*SC,160*SC},limits={-inf,inf,0},title="pnts:",value=DFR_panel:gv_imageresultpnts,disable=1
	
	button output_b11,size={65*SC,20*SC},pos={440*SC,158*SC},title="Image disp",disable=1,proc=fitpanel#FitOutput_DisplayImage
	button output_b12,size={55*SC,20*SC},pos={510*SC,158*SC},title="Raw disp",disable=1,proc=fitpanel#FitOutput_DisplayImage
	button output_b13,size={55*SC,20*SC},pos={570*SC,158*SC},title="Fit disp",disable=1,proc=fitpanel#FitOutput_DisplayImage
	
	//titlebox Output_tb2,size={100*SC,20*SC},pos={490*SC,30*SC},title="IMG Names:",disable=1,frame=0
	//listbox Output_lb2,listwave=DFR_panel:FitOutputIMG_list,selwave=DFR_panel:FitOutputIMG_list_sel,colorWave=DFR_panel:Color_New10
	//listbox ,size={120*SC,130*SC},pos={490*SC,50*SC}, frame=2,editstyle=0,mode=2,disable=1,proc=fitpanel#FitOutput_Listbox_proc
	
	
	Graph_Listbox_Proc("source_lb1", 0, 0, 4)
	
	SetDatafolder DF
End



////////////////////////////tab control////////////////////////////


static Function fit_AutoTab( name, tab )
	String name
	Variable tab
	
	DFREF DF=GetDatafolderDFR()
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	SetActiveSubwindow $winname(0,65)
	
	
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
	
	if (stringmatch(tabstr,"Fit")!=1)
		NVAR gv_showoptionflag=DFR_panel:gv_showoptionflag
		if (gv_showoptionflag==1)
		Proc_bt_showoptions("Fit_bt3")
		endif
		update_display_curve(0)
	endif
	
	if (stringmatch(tabstr,"Output")!=1)
		Wave w_trace=DFR_common:w_trace
		checkdisplayed w_trace
		
		if (V_flag>0)
			removefromgraph /Z w_trace
			appendtograph w_trace
			ModifyGraph grid=2,gridStyle=1
			ModifyGraph mode=4,marker=8,msize=1.5
			//Errorbars w_trace OFF
		endif
		
	endif
	
	Variable SC=ScreenSize(5)
	
	NVAR dimflag=DFR_panel:gv_dimflag
	
	if (stringmatch(tabstr,"Function")==1)
		
			
		NVAR fitdimflag=DFR_panel:gv_fitdimflag
		if (dimflag==1)
			checkbox Function_ck5 disable=1
			checkbox Function_ck6 disable=1
		endif
		
		Listbox Function_lb2,widths={100*SC,60*SC},size={340*SC,110*SC}, mode=6//,proc=fitpanel#FitFn_Listbox_proc
	
		update_fitdata_savewave()
	//	WAVE /B FitFnName_list_sel=DFR_fit:FitFnName_list_sel
		//FitFnName_list_sel[][][0]=0
		//FitFnName_list_sel[0][0][0]=1
		NVAR gv_pathnum=DFR_panel:gv_pathnum
		FitFn_Listbox_proc("dummy",gv_pathnum,0,4)  
	endif
    
    if (stringmatch(tabstr,"Fit")==1)
    		//Listbox Fit_lb0,widths={150,60},size={145,110},pos={20,50}, frame=2,editstyle=0,mode=3,disable=1,proc=fitpanel#FitProc_Listbox_proc,disable=1
	
    		Listbox Function_lb2,widths={150*SC,60*SC},size={145*SC,110*SC}, mode=3,disable=0
    		//WAVE /B FitFnName_list_sel=DFR_fit:FitFnName_list_sel
    		NVAR gv_pathnum=DFR_panel:gv_pathnum
    		Wave w_trace=DFR_common:w_trace
		//FitFnName_list_sel[][][0]=0
		//FitFnName_list_sel[0][0][0]=1
		FitFn_Listbox_proc("dummy",gv_pathnum,0,4)
		
		Variable aExists= strlen(CsrInfo(A)) > 0
		Variable bExists= strlen(CsrInfo(B)) > 0

		if (bExists == 0)
			ShowInfo; Cursor /P/H=2 B w_trace  round(numpnts(w_trace)*0.8)
		endif
		if (aExists == 0)
			ShowInfo; Cursor /P/H=2 A w_trace round(numpnts(w_trace)*0.2)
		endif
		//FitProc_Listbox_proc("dummy",gv_pathnum,0,4) 
    endif
    
    if (stringmatch(tabstr,"Output")==1)
   		FitOutput_Listbox_proc("Output_lb0",0,0,4)
   		if (dimflag==2)
   			PopupMenu output_pp0,disable=1
   		endif
   		
   		aExists= strlen(CsrInfo(A)) > 0
		bExists= strlen(CsrInfo(B)) > 0

		if (bExists == 0)
			ShowInfo; Cursor /P/H=2 B w_trace 10 //10(numpnts(w_trace)-10)
		endif
		if (aExists == 0)
			ShowInfo; Cursor /P/H=2 A w_trace 10
		endif
		TextBox/K/N=text0
    endif
	
	SetDatafolder DF
	
End

//////////////////////////Global Function //////////////////////////////////////




//////////////////////////////////static function////////////////////////////////////

static Function Plot_allwaves_in_fit(wname,basename,appendflag)
	String wname
	string basename
	Variable appendflag
	
	String tracelist=tracenamelist(wname,";",1)
	String tracename,traceinfolist
	String addname,newname
	String procstr,cmd
	Variable index,temppos
	do
		tracename=Stringfromlist(index,tracelist,";")
		if (strlen(tracename)==0)
			break
		endif
		
		traceinfolist=traceinfo (wname,tracename,0)
		temppos=strsearch(traceinfolist,"RECREATION:",0)
		traceinfolist=traceinfolist[temppos+11,inf]
		Wave data=TraceNameToWaveRef(wname, tracename)
		
		temppos=strsearch(tracename,"w_",0)
		if (temppos==-1)
			addname=tracename
		elseif (temppos>0)
			addname=tracename[0,1]
		else
			addname=tracename[2,inf]
		endif
		
		newname=basename+"_"+addname
		newname=CleanupName(newname,0)
		
		Duplicate /o data,$(newname)
		Wave newdata=$newname
		String graphname=display_Wave(newdata,appendflag,0)
		if (appendflag==0)
			appendflag=1
		endif
			variable procindex=0
			do
				procstr=stringfromlist(procindex,traceinfolist,";")
				if (strlen(procstr)==0)
					break
				endif
				procstr=replacestring("(x)",procstr,"("+newname+")",0,1)
				cmd="modifygraph /Z /W="+graphname+" "+procstr
				execute cmd
				procindex+=1
			while(1)
		Killwaves /Z newdata
		index+=1
	while (1)
	
End

static Function plot_curvefit(ctrlname)
	String ctrlname
		
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	String wname=winname(0,65)
	
	Wave /B FitFnName_list_sel=DFR_fit:FitFnName_list_sel
	Wave /T FitFnName_list=DFR_fit:FitFnName_list
	
	NVAR gv_dimflag=DFR_panel:gv_dimflag
	
	Variable appendflag=0
	Variable index=0
	String basename,graphname
	
	do 
		if (FitFnName_list_sel[index][0][0]==1)
			Dowindow /F $wname
			FitFn_Listbox_proc("dummy",index,0,4)
			basename=FitFnName_list[index][0]
			basename=removeending(basename,"=")
			if (appendflag==1)
				Dowindow /F $graphname
			endif
			
			Plot_allwaves_in_fit(wname,basename,appendflag)
			if (appendflag==0)
				graphname=winname(0,65)
				appendflag=1
			endif
		endif
		index+=1
	while (index<dimsize(FitFnName_list_sel,0))
	
End


static Function save_Fit_result(ctrlname)
	String Ctrlname
	//save the results from the last fitting into waves
	//need to provide the name of the fit panel as a string.
	string DF=getdatafolder(1)
	
	String DF_panel="root:internalUse:"+winname(0,65)
	
	setdatafolder $(DF_panel)
	wave W_sigma
	wave CurveFit_coef
	wave w_trace=$(DF_panel+":Panel_common:w_trace")
	newdatafolder/o/s Saved_Fit_Results
	if(waveexists($"Fit_sigma_error"))
	wave Fit_coef,Fit_sigma_error
	wave/T Fit_notestr
	InsertPoints dimsize(Fit_coef,0), 1,Fit_coef,Fit_sigma_error, Fit_notestr
	else
	make/o/n=(1,numpnts(W_sigma)) Fit_coef,Fit_sigma_error
	make/o/n=(1)/T Fit_notestr
	endif

	Fit_coef[dimsize(Fit_coef,0)-1][]=CurveFit_coef[q]
	Fit_sigma_error[dimsize(Fit_coef,0)-1][]=w_sigma[q]
	Fit_notestr[dimsize(Fit_coef,0)-1]=note(w_trace)
	//print Fit_notestr[0]
	setdatafolder $DF

End



static Function save_curvefit_coef(ctrlname)
	String ctrlname
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	SVAR CurveFit_hdstr=DFR_panel:CurveFit_hdstr
	NVAR gv_pathnum=DFR_panel:gv_pathnum
		
	Wave CurveFit_coef=DFR_panel:CurveFit_coef
	SVAR CurveFit_constrain=DFR_panel:CurveFit_constrain
	
	Wave FitFnName_list_sel=DFR_fit:FitFnName_list_sel
		
	Variable rawpathnum=gv_pathnum
		
	Variable index=0
	do
		
		if  ((FitFnName_list_sel[index][0]==1))
			gv_pathnum=index
			if (stringmatch(ctrlname,"Fit_bt8"))
				update_listbox_to_SavePara()
			else
				CurveFit_hdstr=""
				CurveFit_coef=0
				CurveFit_constrain=""
				update_Coef_to_Listbox()
				update_coef_to_SavePara()
				update_display_curve(1)
				update_listbox_color(0)
				
			endif
		endif
		index+=1
	while (index<dimsize(FitFnName_list_sel,0))
		
	gv_pathnum=rawpathnum


End


static Function /S Cal_range_fromcoef(varstr)
	String varstr
	
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	Wave CurveFit_coef=DFR_panel:CurveFit_coef
	
	NVAR gv_fit_leftrange=DFR_panel:gv_fit_leftrange
	NVAR gv_fit_rightrange=DFR_panel:gv_fit_rightrange
	
	Wave w_Trace=DFR_common:w_Trace
	
	Variable maxminflag=0
	
	Variable temp=strsearch(varStr,"max",0,2)
	if (temp==-1)
		temp=strsearch(varStr,"min",0,2)
		if (temp==-1)
			temp=strsearch(varStr,"K",0,2)
			if (temp==-1)
				doalert 0,"Wrong expression."
				return ""
			endif
		else
			maxminflag=2
		endif
	else
		maxminflag=1	
	endif
		
	Variable temp1=strsearch(varStr,"+",temp,2)
	if (temp1==-1)
		temp1=strsearch(varStr,"-",temp,2)
		if (temp1==-1)
			doalert 0,"Wrong expression."
			return ""
		endif
	endif
	
	String parstr=varstr[temp,temp1-1]
	
	if (maxminflag==0)
	
		Variable coefnum=str2num(parstr[1,inf])
		if (numtype(coefnum)==2)
			doalert 0,"Wrong expression."
			return ""
		endif
		string cmdstr=ReplaceString(parstr,varstr,"CurveFit_coef["+parstr[1,inf]+"]")
	elseif (maxminflag==1)
		WaveStats /Q  /R=(gv_fit_leftrange,gv_fit_rightrange) w_Trace
		sprintf cmdstr,"%g",V_maxloc
		cmdstr=ReplaceString(parstr,varstr,cmdstr)
	elseif (maxminflag==2)
		WaveStats /Q  /R=(gv_fit_leftrange,gv_fit_rightrange) w_Trace
		sprintf cmdstr,"%g",V_minloc
		cmdstr=ReplaceString(parstr,varstr,cmdstr)
	endif
	return cmdstr
End



static Function proc_sv_Autochangefitrange(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	NVAR gv_fit_leftrange=DFR_panel:gv_fit_leftrange
	NVAR gv_fit_rightrange=DFR_panel:gv_fit_rightrange
	NVAR gv_fit_autorangeflag=DFR_panel:gv_fit_autorangeflag
	
	Wave w_trace=DFR_common:w_trace
	
	
	String cmd=cal_range_fromcoef(varStr)
	
	if (stringmatch(ctrlname,"FitMore_sv2"))
		if (strlen(cmd)>0)
			cmd="gv_fit_leftrange="+cmd
			SetDatafolder DFR_panel
			Execute /Q/Z cmd
			
			Variable pA=x2pnt(w_trace,gv_fit_leftrange)
			Variable pB=x2pnt(w_trace,gv_fit_rightrange)
	
			Cursor /P/H=2 A w_trace pA
			Cursor /P/H=2 B w_trace pB
			//gv_fit_autorangeflag=1
		else
			gv_fit_autorangeflag=0
		endif
	else
		if (strlen(cmd)>0)
			cmd="gv_fit_rightrange="+cmd
			SetDatafolder DFR_panel
			Execute /Q/Z cmd
			
			pA=x2pnt(w_trace,gv_fit_leftrange)
			pB=x2pnt(w_trace,gv_fit_rightrange)
	
			Cursor /P/H=2 A w_trace pA
			Cursor /P/H=2 B w_trace pB
			//gv_fit_autorangeflag=1
		else
			gv_fit_autorangeflag=0
		endif
	endif
	
	
	
	SetDatafolder DF
	
End
static Function proc_sv_changefitrange(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	NVAR gv_fit_leftrange=DFR_panel:gv_fit_leftrange
	NVAR gv_fit_rightrange=DFR_panel:gv_fit_rightrange
	
	Wave w_trace=DFR_common:w_trace
	
	Variable pA=x2pnt(w_trace,gv_fit_leftrange)
	Variable pB=x2pnt(w_trace,gv_fit_rightrange)
	
	Cursor /P/H=2 A w_trace pA
	Cursor /P/H=2 B w_trace pB
	
	
End

static Function Proc_bt_showoptions(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	NVAR gv_showoptionflag=DFR_panel:gv_showoptionflag
	
	String wname=winname(0,65)
	Getwindow $wname,wsize
	
	String tabStr = "FitMore"
	
		String curTabMatch= tabstr+"_*"
		String name_panel=winname(0,65)
	
		String controlsInATab= ControlNameList(name_panel,";","*_*")
		String controlsInCurTab= ListMatch(controlsInATab, curTabMatch)
	
	if (gv_showoptionflag==0)
		movewindow /W=$wname v_left, v_top, v_right, v_bottom+100
		String cmd 
		sprintf cmd,"ControlBar %g",313*screensize(5)
		execute cmd
		gv_showoptionflag=1
		Button Fit_bt3,title="#"
		
		
	//String controlsglobalcontrols=ListMatch(controlsInATab, "*global*")
	//String controlsInOtherTabs= ListMatch(controlsInATab, "!"+curTabMatch)

	//ModifyControlList controlsInOtherTabs disable=1	// hide
		ModifyControlList controlsInCurTab disable=0		// show
	//ModifyControlList controlsglobalcontrols disable=0	// show
		update_conf_curve(1)	
		update_Res_curve(1)
	else
		movewindow /W=$wname v_left, v_top, v_right, v_bottom-100
		sprintf cmd,"ControlBar %g",213*screensize(5)
		execute cmd
		gv_showoptionflag=0
		Button Fit_bt3,title="@"
		
		ModifyControlList controlsInCurTab disable=1	
		update_conf_curve(0)	
		update_Res_curve(0)
	endif
	
End

Function readFitrange_from_savepar()
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
End

Function update_fit_range()
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	NVAR gv_fit_autorangeflag=DFR_panel:gv_fit_autorangeflag
	
	if (gv_fit_autorangeflag==1)
		proc_ck_Autorange("dummy",1)
	//else
		//readFitrange_from_savepar()
	endif
	
End


static Function proc_bt_AutorangeFromPeak(ctrlname)
	String ctrlname
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	SVAR gs_fit_leftrange=DFR_panel:gs_fit_leftrange
	SVAR gs_fit_rightrange=DFR_panel:gs_fit_rightrange
	NVAR gv_parsel_col=DFR_panel:gv_parsel_col
	Wave /T FitPar_list=DFR_panel:FitPar_list
	
	Wave w_trace=DFR_common:w_trace
	
	String parname=FitPar_list[0][(gv_parsel_col-mod(gv_parsel_col,3))]
	Variable FWHM=str2num(FitPar_list[2][(gv_parsel_col-mod(gv_parsel_col,3))+1])
	if (numtype(FWHM)==2)
		FWHM=(rightx(w_Trace)-leftx(w_trace))/5
	else
		FWHM*=1.25
	endif
	
	Variable temp=strsearch(parname, ":", 0 )
	parname=parname[0,temp-1]
	
	strswitch(ctrlname)
		case "FitMore_bt20":
			gs_fit_leftrange=parname+"-"+num2str(FWHM)
			proc_sv_Autochangefitrange("FitMore_sv2",0,gs_fit_leftrange,"")
			break
		case "FitMore_bt21":
			gs_fit_rightrange=parname+"+"+num2str(FWHM)
			proc_sv_Autochangefitrange("FitMore_sv3",0,gs_fit_rightrange,"")
			break	
	endswitch
	
End

static Function proc_ck_Autorange(ctrlname,value)
	String ctrlname
	Variable value
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	SVAR gs_fit_leftrange=DFR_panel:gs_fit_leftrange
	SVAR gs_fit_rightrange=DFR_panel:gs_fit_rightrange
	NVAR gv_fit_autorangeflag=DFR_panel:gv_fit_autorangeflag
	
	if (value==1)
		proc_sv_Autochangefitrange("FitMore_sv2",0,gs_fit_leftrange,"")
		proc_sv_Autochangefitrange("FitMore_sv3",0,gs_fit_rightrange,"")
	endif
	
End


Function update_fit_wave(flag)
	Variable flag
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	NVAR gv_dimflag=DFR_panel:gv_dimflag
	NVAR gv_fitdimflag=DFR_panel:gv_fitdimflag
	NVAR Pathnum=DFR_panel:gv_pathnum
	
	wave w_trace=DFR_common:w_trace
	Wave /T FitWavePath_list=DFR_panel:FitWavePath_list
	Wave /T FitWavePathX_list=DFR_panel:FitWavePathX_list
	
	SetDatafolder dFR_panel
	
	String plotstr=""
	
	if (gv_dimflag==1) //trace
		Wave/Z data=$FitWavePath_list[pathnum]
		if (waveexists(data)==0)
			SetDatafolder DF
			return 0
		endif
		Duplicate /o data,w_trace
		
		if (strlen(FitWavePathX_list[pathnum])>0)
			Wave /Z xdata=$FitWavePathX_list[pathnum]
			if (waveexists(xdata))
				setscale /I x,wavemin(xdata),wavemax(xdata),w_trace
				w_trace=interp(x,xdata,data)
			endif
		endif
		//checkdisplayed 
	elseif (gv_dimflag==2) //image
		Wave/z data=$FitWavePath_list[0]
		if (waveexists(data)==0)
			SetDatafolder DF
			return 0
		endif
		
		if (gv_fitdimflag==0) //mdc
			duplicate /o/R=[][dimsize(data,1)-1-pathnum] data,w_trace
			sprintf plotstr,"Y=%g",dimoffset(data,1)+dimdelta(data,1)*(dimsize(data,1)-1-pathnum)
		else //edc
			duplicate /o/R=[pathnum][] data,w_trace
			Matrixtranspose w_trace
			sprintf plotstr,"X=%g",dimoffset(data,0)+dimdelta(data,0)*pathnum
		endif
		redimension /N=(-1) w_trace
	endif
	
	checkdisplayed w_trace
	if (V_flag==0)
		appendtograph w_trace
		ModifyGraph grid=2,gridStyle=1
		ModifyGraph mode(w_trace)=4,marker(w_trace)=8,msize(w_trace)=1.5
		//ModifyGraph axisEnab(bottom)={0,0.6}
		ModifyGraph mirror(left)=0
		removeimage /Z w_image
		//modifygraph 
	endif
	
	
			
	if (flag==0)		
		ModifyGraph mode(w_trace)=4,marker(w_trace)=8,msize(w_trace)=1.5//,marker(w_trace)=8,msize(w_trace)=0
		
		ReadDetailWaveNote(data,Nan,1)
		Wave /T WaveInfoL
		Wave WaveVars
		
		Variable SD=Screensize(6)
		
		DFREF DFR_prefs=$DF_prefs
       	NVAR Dfontsize=DFR_prefs:gv_Dfontsize
	
				
		String WaveinfoS=WaveInfoL[0]+"\r"+WaveInfoL[1]+"\r"+WaveInfoL[4] //+WaveInfoL[3]+"\r"+WaveInfoL[2]+"\r"
	
		if (gv_dimflag==1)
			WaveinfoS="\Z"+num2indstr(round(DFontsize*SD),2)+"\K(65535,0,0)"+WaveinfoS
			textBox/W=$winname(0,65)/B=1/C/N=text0/F=0/A=MC/LS=3/Z=1/X=27/Y=37 WaveinfoS
		else
			WaveinfoS="\Z"+num2indstr(round(DFontsize*SD),2)+"\K(65535,0,0)"+plotstr+"\r"+WaveinfoS
			textBox/W=$winname(0,65)/B=1/C/N=text0/F=0/A=MC/LS=3/Z=1/X=27/Y=37 WaveinfoS
		endif
		
	else
		ModifyGraph mode(w_trace)=3,marker(w_trace)=19,msize(w_trace)=1
		//waveinfoS="\K(65535,0,0)"+plotstr+"\r"//+WaveinfoS
		//textBox/W=$winname(0,65)/B=1/C/N=text0/F=0/A=MC/LS=3/Z=1/X=27.00/Y=32 WaveinfoS
		textBox /W=$winname(0,65)/K /N=text0
	endif
		
	
	
	Killwaves/Z WaveInfoL,WaveVars
	SetDatafolder DF
	return 0
end

static Function FitProc_Listbox_proc(ctrlName,row,col,event) : ListboxControl
	String ctrlName     // name of this control
	Variable row        // row if click in interior, -1 if click in title
	Variable col        // column number
	Variable event      // event code
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	Wave /T FitFnSave_strlist=DFR_fit:FitFnSave_strlist
	WAVE /T FitFnName_list=DFR_fit:FitFnName_list
   	 WAVE /B FitFnName_list_sel=DFR_fit:FitFnName_list_sel
    	NVAR gv_pathnum=DFR_panel:gv_pathnum
    
    
    
    	if ((event==4)||(event==5))
    		gv_pathnum=row
		update_fit_wave(1)
		Update_par_list(1)
		update_display_curve(1)		
	endif
	
	return 0            // other return values reserved
end

static Function FitFn_Listbox_proc(ctrlName,row,col,event) : ListboxControl
	String ctrlName     // name of this control
	Variable row        // row if click in interior, -1 if click in title
	Variable col        // column number
	Variable event      // event code
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	Wave /T FitFnSave_strlist=DFR_fit:FitFnSave_strlist
	WAVE /T FitFnName_list=DFR_fit:FitFnName_list
	WAVE /B FitFnName_list_sel=DFR_fit:FitFnName_list_sel
    
    	NVAR gv_Pathnum=DFR_panel:gv_pathnum
    
    	NVAR gv_showconfflag=DFR_panel:gv_showconfflag
    	NVAR gv_showpredflag=DFR_panel:gv_showpredflag
    
	if ((event==4)||(event==5))
		gv_Pathnum=row
		controlinfo fit
		if (stringmatch(S_Value,"Function"))
			SVAR gs_Fndisplay=DFR_panel:gs_Fndisplay
			if (col==0)
				gs_Fndisplay=FitFnSave_strlist[row]
				update_fit_wave(0)
			else
				if (strlen(FitFnName_list[row][col][0])>0)
					gs_Fndisplay=FitFnName_list[row][col][1]+"="+FitFnName_list[row][col][0]
				else
					gs_Fndisplay=""
				endif
			endif
			//update_conf_curve(0)
		elseif (stringmatch(S_Value,"Fit"))
			update_fit_wave(1)
			if (event==4)
				Update_par_list(1)
				//update_conf_curve()
				update_display_curve(1)
				update_fitpar_from_savePara()
			else
				//update_conf_curve()
				update_display_curve(0)
			endif
		endif
	endif
	
	return 0            // other return values reserved
End


static Function SetPeakColor(Savestr)
	string savestr
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	SVAR gs_FitPeakbkglist=DFR_panel:gs_FitPeakbkglist
	SVAR gs_FitPeakbkglist_Check=DFR_panel:gs_FitPeakbkglist_Check
	Wave Color_new10=DFR_panel:Color_New10
	
	Variable indexnum=	WhichListItem(savestr,gs_FitPeakbkglist,";",0)
	
	if (indexnum>=0)
		//gs_FitPeakbkglist_Check=removefromlist(savestr,gs_FitPeakbkglist_Check,";")
		return indexnum+1
	else
		gs_FitPeakbkglist=AddListItem(savestr, gs_FitPeakbkglist , ";",inf)
		//gs_FitPeakbkglist=sortlist(gs_FitPeakbkglist,";")
	//	gs_FitPeakbkglist_Check=AddListItem(savestr, gs_FitPeakbkglist_check, ";",inf)
		return WhichListItem(savestr,gs_FitPeakbkglist,";",0)+1//itemsinlist(gs_FitPeakbkglist,";")
	endif
end

Static Function  GetFn_num(fnstr)
	String fnstr
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	SVAR gs_PeakStrlist=DFR_panel:gs_PeakStrlist
	
	SVAR gs_bkgStrlist=DFR_panel:gs_bkgStrlist
	
	
	if (stringmatch(fnstr,"xFermi"))
		return 1
	endif
	if (stringmatch(fnstr,"Convolve"))
		return 2
	endif
	if (stringmatch(fnstr,"Offset"))
		return 3
	endif
	if (stringmatch(fnstr,"symbkg"))
		return 4
	endif
	if (stringmatch(fnstr,"absbkg"))
		return 5
	endif
	
	Variable peaknum=WhichListItem(fnstr,gs_PeakStrlist,";",0)
	if (peaknum>=0)
		return peaknum+200
	endif
	
	peaknum=WhichListItem(fnstr,gs_bkgStrlist,";",0)
	if (peaknum>=0)
		return peaknum+400
	endif
	
	return 0
end

Function Update_par_savewave(Peakname,Fnnum)
	String peakname
	Variable Fnnum
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	SetDatafolder DFR_fit
	
	Wave /T FitFnSave_strlist=DFR_fit:FitFnSave_strlist
	
	Variable parnum
	
	if (Fnnum>=400)
		Fnnum-=400
		Wave /T FNlist=DFR_panel:bkgFns
		parnum=str2num(FNlist[Fnnum][1])
	elseif (Fnnum>=200)
		Fnnum-=200
		Wave /T FNlist=DFR_panel:peakFns
		parnum=str2num(FNlist[Fnnum][1])
	elseif (Fnnum>=0)
		if (Fnnum>4)
			parnum=0
		else
			Fnnum-=1
			Wave /T FNlist=DFR_panel:coefFns
			parnum=str2num(FNlist[Fnnum][1])
		endif
	else
		SetDatafolder DF
		return 0
	endif
	
	String Savewavename="SavePar_"+Peakname
	
	Wave /Z Parsave=$Savewavename
		
	if (waveexists(Parsave))
		if (parnum!=dimsize(Parsave,1))
			redimension /n=(-1,parnum,-1) parsave
		endif
		if (dimsize(FitFnSave_strlist,0)!=dimsize(Parsave,0))
			redimension /n=(dimsize(FitFnSave_strlist,0),-1,-1) parsave
		endif
	else
		make /o/n=(dimsize(FitFnSave_strlist,0),parnum,4) $Savewavename
	endif
	
	String SaveImagename="SaveImage_"+Peakname
	
	Wave /Z Imgsave=$SaveImagename
	Variable tracenum=dimsize(FitFnSave_strlist,0)
	
	if (waveexists(Imgsave))
		if (tracenum>dimsize(Imgsave,0))
			redimension /n=(tracenum,-1) parsave
		endif
	else
		make /o/n=(tracenum,1) $SaveImagename
	endif
	
	SetDatafolder DF
	
End

static Function GetFnlist_to_Wave(fnlist)
	String fnlist
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	SetDatafolder DFR_fit
	
	Variable Fnnum=itemsinlist(Fnlist,";")
	Make /o/n=(Fnnum) M_FN_ColorWave
	Make /T/o/n=(Fnnum) M_FN_SaveWave
	Make /T/o/n=(Fnnum) M_FN_SaveWave_Name
	Make /T/o/n=(Fnnum) M_FN_SaveWave_num

	
	//Wave FitPeakbkglist_color=DFR_panel:FitPeakbkglist_color
		
	String savestr
	Variable index
	Variable temp
		
	do
		savestr=stringfromlist(index,Fnlist,";")
		temp=strsearch(savestr,"=",0)
		
		M_FN_SaveWave_Name[index]=savestr[0,temp-1]
		M_FN_SaveWave[index]=savestr[temp+1,inf]
		M_FN_SaveWave_num[index]=num2str(GetFn_num(savestr[temp+1,inf]))
		M_FN_ColorWave[index]=SetPeakColor(savestr[0,temp-1])
		
		Update_par_savewave(savestr[0,temp-1],str2num(M_FN_SaveWave_num[index]))
		
		index+=1
	while (index<Fnnum)
	
	
//	sort /A M_FN_SaveWave_Name,M_FN_SaveWave_Name,M_FN_SaveWave,M_FN_ColorWave
   
   SetDatafolder DF
End

static Function update_FitFnName_list()
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	SetDatafolder DFR_fit
	Wave /T FitFnSave_strlist=DFR_fit:FitFnSave_strlist
	WAVE /T FitFnName_list=DFR_fit:FitFnName_list
	//Wave FitFnName_list_CW=DFR_fit:FitFnName_list_CW
    	WAVE /B FitFnName_list_sel=DFR_fit:FitFnName_list_sel
    
    	//Wave FitSave_FitCurve=DFR_fit:FitSave_FitCurve
    
   	 SVAR gs_FitPeakbkglist=DFR_panel:gs_FitPeakbkglist
	//SVAR gs_FitPeakbkglist_Check=DFR_panel:gs_FitPeakbkglist_Check
    
	Variable index
	String Fnlist
	
	//Make /o/n=(1,1) FitFnNum_list
	
	
	Variable Fnnum,Fnmax=0
	do
		fnlist=FitFnSave_strlist[index]
		if (strlen(fnlist)>0)
			GetFnlist_to_Wave(fnlist)
			Wave /T M_FN_SaveWave
			Fnnum=numpnts(M_FN_SaveWave)
		else
			Fnnum=0
		endif
		if (Fnnum>Fnmax)
			Fnmax=Fnnum
		endif
		index+=1
	while (index<dimsize(FitFnSave_strlist,0))
	
	//if (strlen(gs_FitPeakbkglist_Check)>0)
	//	gs_FitPeakbkglist=removefromlist(gs_FitPeakbkglist_Check,gs_FitPeakbkglist,";")
	//endif
	
	//gs_FitPeakbkglist_Check=gs_FitPeakbkglist
	
	
//	if ((itemsinlist(gs_FitPeakbkglist)+2)>dimsize(FitSave_FitCurve,2))
//		redimension /N=(-1,-1,(itemsinlist(gs_FitPeakbkglist)+2)) FitSave_FitCurve
//	endif
	
	//if ((Fnmax+1)>dimsize(FitFnName_list,1))
	redimension /N=(-1,(Fnmax+1),-1)  FitFnName_list,FitFnName_list_sel
	//endif
	
	if (Fnmax>0)
	
	index=0
	do  
		fnlist=FitFnSave_strlist[index]
		if (strlen(fnlist)>0)
			GetFnlist_to_Wave(fnlist)
			Wave /T M_FN_SaveWave,M_FN_SaveWave_Name,M_FN_SaveWave_Num
			Wave M_FN_ColorWave
			
			Fnnum=numpnts(M_FN_SaveWave)
			
			FitFnName_list[index][1,Fnnum][0]=M_FN_SaveWave[q-1]
			FitFnName_list[index][1,Fnnum][1]=M_FN_SaveWave_Name[q-1]
			FitFnName_list[index][1,Fnnum][2]=M_FN_SaveWave_num[q-1]
			
			FitFnName_list_sel[index][1,Fnnum][1]=M_FN_ColorWave[q-1]
			
			if ((Fnnum+1)<dimsize(FitFnName_list,1))
				FitFnName_list[index][Fnnum+1,inf][]=""
				FitFnName_list_sel[index][Fnnum+1,inf][1]=0
			endif
			//FitFnName_list_sel[index][1,][2]=1//M_FN_ColorWave[q-1]
		//	FitFnName_list_CW[index][1,][]=M_FN_ColorWave[q][r]
		else
			FitFnName_list[index][1,inf]=""
			FitFnName_list_sel[index][1,inf][1]=0
		endif
		index+=1
	while (index<dimsize(FitFnSave_strlist,0))
	
	//gs_FitPeakbkglist_Check=gs_FitPeakbkglist
	
	
	
	endif
	
    	Killwaves /Z M_FN_SaveWave,M_FN_SaveWave_Name,M_FN_SaveWave_Num,M_FN_ColorWave
    
	SetDatafolder DF	 
End

static Function Add_to_FitNameList(Peakname,PeakNum,bkgflag,Addrow)
	String Peakname
	Variable PeakNum,bkgflag,addrow
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	Wave /T PeakFns=DFR_panel:PeakFns
	Wave /T bkgFns=DFR_panel:bkgFns
	
    
    	Wave /T FitFnSave_strlist=DFR_fit:FitFnSave_strlist
       
    	if(bkgflag)
    		String savestr=Peakname+"="+bkgFns[Peaknum][0]
    		//Peakname=Peakname
  	else
   		savestr=Peakname+"="+PeakFns[Peaknum][0]
   		//Peakname=Peakname
   	endif
   	
      	   	
   	String Fnliststr=FitFnSave_strlist[addrow]
   	
   	if (strlen(Fnliststr)==0)
   		FitFnSave_strlist[addrow]=savestr+";"
   	else
   		if (strsearch(FnlistStr,Peakname,0,2)==-1)
   			FitFnSave_strlist[addrow]=AddListItem(savestr, Fnliststr , ";",inf)
   		else
   			if	(bkgflag)
     			FitFnSave_strlist[addrow]=ReplaceStringByKey(Peakname,Fnliststr,bkgFns[Peaknum][0],"=",";")
   			else
   				FitFnSave_strlist[addrow]=ReplaceStringByKey(Peakname,Fnliststr,PeakFns[Peaknum][0],"=",";")
   			endif
   		endif
   	endif
   	
   	update_FitFnName_list()
  // 	FitFnName_list[addrow][FitFnnum-endnum]=bkgFns[Peaknum][0]
       
      
    
End

static Function proc_bt_Addbkgs(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	WAVE /T FitFnName_list=DFR_fit:FitFnName_list
	WAVE /B FitFnName_list_sel=DFR_fit:FitFnName_list_sel
	
	controlinfo Function_lb1
	Variable peaknum=v_value
	
	Variable Addrow=return_selected(FitFnName_list_sel,0)
		
	String Peakname="Bkg"
	Prompt Peakname,"Enter a name for Background:"
	doprompt "Enter Name",Peakname
	
	if (V_flag)
		SetDatafolder DF
		return 0
	endif
	
	Add_to_FitNameList(Peakname,PeakNum,1,Addrow)
End

static Function proc_bt_AddPeaks(ctrlname)
	string ctrlname
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	WAVE /T FitFnName_list=DFR_fit:FitFnName_list
	WAVE /B FitFnName_list_sel=DFR_fit:FitFnName_list_sel
	//Wave /T PeakFns=DFR_panel:PeakFns
	//Wave /T bkgFns=DFR_panel:bkgFns
	
	controlinfo Function_lb0
	Variable peaknum=v_value
	
	Variable Addrow=return_selected(FitFnName_list_sel,0)
		
	String Peakname="Peak"
	Prompt Peakname,"Enter a name for Peak:"
	doprompt "Enter Name",Peakname
	
	if (V_flag)
		SetDatafolder DF
		return 0
	endif
		
	Add_to_FitNameList(Peakname,PeakNum,0,Addrow)
End

static Function proc_ck_Fncoef(ctrlname,value)
	string ctrlname
	Variable value
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	WAVE /B FitFnName_list_sel=DFR_fit:FitFnName_list_sel
	
	String savestr
	 
	Strswitch(ctrlname)
	case "Function_ck0":
		savestr="FermiFn=xFermi"
	break
	case "Function_ck1":
		savestr="Convolve=Convolve"
	break
	case "Function_ck2":
		savestr="slopeoffset=Offset"
	break
	case "Function_ck3":
		savestr="symbkg=symbkg"
	break
	case "Function_ck4":
		savestr="absbkg=absbkg"
	break
	Endswitch
	
	Variable Addrow=return_selected(FitFnName_list_sel,0)
	
	Add_to_FitnameList_coef(savestr,Addrow,value)

End

static Function Add_to_FitnameList_coef(savestr,Addrow,flag)
	String savestr
	Variable Addrow,flag
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	Wave /T FitFnSave_strlist=DFR_fit:FitFnSave_strlist
	
	string Fnlist=FitFnSave_strlist[Addrow]
	
	if (flag)
		if (strlen(Fnlist)==0)
			SetDatafolder DF
			return 0
		endif
		
		if (Whichlistitem(savestr,Fnlist,";",0)==-1)
			Fnlist=AddListItem(savestr, Fnlist , ";",inf)
			FitFnSave_strlist[Addrow]=Fnlist
			update_FitFnName_list()
		endif
	else
		Fnlist=removefromlist(savestr,Fnlist,";")
		FitFnSave_strlist[Addrow]=Fnlist
		update_FitFnName_list()
	endif	
End

static Function proc_bt_moveFn(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	WAVE /T FitFnName_list=DFR_fit:FitFnName_list
	Wave /T FitFnSave_strlist=DFR_fit:FitFnSave_strlist
	WAVE /B FitFnName_list_sel=DFR_fit:FitFnName_list_sel
	
	Variable Addrow=return_selected(FitFnName_list_sel,0)
	Variable Addcol=return_selected(FitFnName_list_sel,1)
	
	String fnlist=FitFnSave_strlist[Addrow]
	
	Variable leftflag
	if (Stringmatch(ctrlname,"Function_bt31"))
		leftflag=1 //move left
	else
		leftflag=0 //move right
	endif
	
	if ((Addcol>0)&&(strlen(FitFnName_list[Addrow][Addcol][0])>0))
		String movestr=FitFnName_list[Addrow][Addcol][1]+"="+FitFnName_list[Addrow][Addcol][0]
		Variable preindex=WhichListItem(movestr,fnlist,";",0)
		if (leftflag)
			if (preindex>0)
			fnlist=AddListItem(movestr,fnlist,";",preindex-1)
			fnlist=RemoveListItem(preindex+1,fnlist,";")
			FitFnName_list_sel[Addrow][Addcol]=0
			FitFnName_list_sel[Addrow][Addcol-1]=1
			endif
		else
			if (preindex<(itemsinlist(fnlist,";")-1))
			fnlist=AddListItem(movestr,fnlist,";",preindex+2)
			fnlist=RemoveListItem(preindex,fnlist,";")
			FitFnName_list_sel[Addrow][Addcol]=0
			FitFnName_list_sel[Addrow][Addcol+1]=1
			endif
		endif
		FitFnsave_Strlist[Addrow]=fnlist
	endif
	
	
	update_FitFnName_list()	
End

static Function proc_bt_delFn(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	WAVE /T FitFnName_list=DFR_fit:FitFnName_list
	WAVE /B FitFnName_list_sel=DFR_fit:FitFnName_list_sel
	Wave /T FitFnSave_strlist=DFR_fit:FitFnSave_strlist
	
	Variable Addrow=return_selected(FitFnName_list_sel,0)
	Variable Addcol=return_selected(FitFnName_list_sel,1)
	
	String fnlist=FitFnSave_strlist[Addrow]
	
	if (stringmatch(ctrlname,"Function_bt3"))
		if ((Addcol>0)&&(strlen(FitFnName_list[Addrow][Addcol][0])>0))
		String removestr=FitFnName_list[Addrow][Addcol][1]+"="+FitFnName_list[Addrow][Addcol][0]
		fnlist=removefromlist(removestr,fnlist,";")
		FitFnsave_Strlist[Addrow]=fnlist
		endif
	elseif (stringmatch(ctrlname,"Function_bt4"))
		FitFnsave_Strlist[Addrow]=""
	endif
	
	update_FitFnName_list()
End
	
static Function proc_bt_CopyFn(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
		
	WAVE /T FitFnName_list=DFR_fit:FitFnName_list
	WAVE /B FitFnName_list_sel=DFR_fit:FitFnName_list_sel
	Wave /T FitFnSave_strlist=DFR_fit:FitFnSave_strlist
	
	Variable Addrow=return_selected(FitFnName_list_sel,0)
	
	String fnlist=FitFnSave_strlist[Addrow]
	
	if (stringmatch(ctrlname,"Function_bt2"))
		FitFnsave_Strlist=fnlist
	elseif (stringmatch(ctrlname,"Function_bt21"))
		FitFnsave_Strlist[0,Addrow]=fnlist
	elseif (stringmatch(ctrlname,"Function_bt22"))
		FitFnsave_Strlist[Addrow,inf]=fnlist
	endif
	
	update_FitFnName_list()
End

static Function proc_bt_Set_PeakNames(ctrlname)
	String ctrlname
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	SetDatafolder DFR_panel
	
	SVAR gs_FitPeakbkglist=DFR_panel:gs_FitPeakbkglist
	
	Variable peaknum=itemsinlist(gs_FitPeakbkglist,";")
	
	if (peaknum==0)
		SetDatafolder DF
		return 0
	endif
	
	newDatafolder /o/s SetPeakname
		
	String /G graphname=winname(0,65)
	
	update_SetPeakname_list(0)
	
	Variable SR = Igorsize(3) 
	Variable ST = Igorsize(2)
	Variable SL = Igorsize(1)
    Variable SB = Igorsize(4)
	Variable Width = 220 	// panel size  
	Variable height = 330 
	
	Variable xOffset = (SR-SL)/2-width/2
	Variable yOffset = (SB-ST)/2-height/2
	NewPanel /K=2 /W=(xoffset, yoffset,xOffset+width,Height+yOffset)/N=Auto_Process as "Pause for Set PeakName"
	Modifypanel /W=Auto_process noedit=1,fixedsize=1
	DoWindow/K/Z  PauseforSetPeakname		
	DoWindow/C PauseforSetPeakname
	
	listbox SetPeak_lb0,pos={20,30},size={140,200},listwave=SetPeakname_list,selwave=SetPeakname_list_sel,colorWave=DFR_panel:Color_New10
	listbox SetPeak_lb0,frame=2,editstyle=0,mode=6,proc=fitpanel#SetPeakname_listbox
	
	Button button0,pos={20,240},size={140,20},title="Del unused Name",proc=fitpanel#SetPeakname_delete	
	Button button1,pos={20,270},size={140,20},title="Apply Changes",proc=fitpanel#SetPeakname_Close	
//	Button button2,pos={20,300},size={140,20},title="Cancel",proc=fitpanel#SetPeakname_Close		
	
	Button button3,pos={170,150},size={40,20},title="Up",proc=fitpanel#SetPeakname_move
	Button button4,pos={170,180},size={40,20},title="Down",proc=fitpanel#SetPeakname_move
		
	PauseForUser  PauseforSetPeakname,$graphName
	
	update_FitFnName_list()
	
	SetDatafolder DF
	
	
End

static Function SetPeakname_listbox(ctrlName,row,col,event) : ListboxControl
	String ctrlName     // name of this control
	Variable row        // row if click in interior, -1 if click in title
	Variable col        // column number
	Variable event      // event code
	Wave /T SetPeakname_list
	Wave /B SetPeakname_list_sel
	
	SVAR graphname
	
	String DF_panel="root:internalUse:"+graphname
	DFREF DFR_panel=$DF_panel
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	if ((event==7)&&(stringmatch(SetPeakname_list[row][0],SetPeakname_list[row][1])==0))
				
		Wave/T FitFnSave_strlist=DFR_fit:FitFnSave_strlist
	
		String checkstr=SetPeakname_list[row][1]+"="
		Variable index
		String fnstr
		do
			if (index>=numpnts(FitFnSave_strlist))
				break
			endif
			fnstr=FitFnSave_strlist[index]
			if (strsearch(fnstr,checkstr,0)>=0)
				doalert 0, SetPeakname_list[row][1]+" is used by Curve"+num2str(index)+"."
				SetPeakname_list[row][1]=SetPeakname_list[row][0]
				break
			endif
		index+=1
		while (index<numpnts(	FitFnSave_strlist))
		
	endif
	
	return 0            // other return values reserved
End

static Function update_SetPeakname_list(flag)
	Variable flag
	Wave /T SetPeakname_list
	Wave /B SetPeakname_list_sel
	SVAR graphname
	String DF_panel="root:internalUse:"+graphname
	DFREF DFR_panel=$DF_panel
	
	SVAR gs_FitPeakbkglist=DFR_panel:gs_FitPeakbkglist
	
	Variable peaknum=itemsinlist(gs_FitPeakbkglist,";")
	
	
	
	Make /o/T/n=(peaknum,2) SetPeakname_list
	Make /o/B/n=(peaknum,2,2) SetPeakname_list_sel
	SetDimLabel 2,1,backColors,SetPeakname_list_sel
	Make /o/T/n=2 SetPeakname_list_title={"Old Name","New Name"}
	
	
	
	Variable index
	do
		if (index>=peaknum)
			break
		endif
		
		SetPeakname_list[index][]=stringfromlist(index,gs_FitPeakbkglist,";")
		if (flag==0)
			SetPeakname_list_sel[index][0][0]=0
			SetPeakname_list_sel[index][1][0]=2
		endif
		SetPeakname_list_sel[index][0][1]=index+1
		SetPeakname_list_sel[index][1][1]=index+1
		index+=1
	while (index<peaknum)
	
End

static Function SetPeakname_move(ctrlname)
	String ctrlname
	
	Wave /T SetPeakname_list
	Wave /B SetPeakname_list_sel
	
	Variable Addrow=return_selected(SetPeakname_list_sel,0)
	Variable Addcol=return_selected(SetPeakname_list_sel,1)
	
	SVAR graphname
	String DF_panel="root:internalUse:"+graphname
	DFREF DFR_panel=$DF_panel
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	SVAR gs_FitPeakbkglist=DFR_panel:gs_FitPeakbkglist
	//Wave/T FitFnSave_strlist=DFR_fit:FitFnSave_strlist
	
	
	Variable leftflag
	if (Stringmatch(ctrlname,"button3"))
		leftflag=1 //move up
	else
		leftflag=0 //move dow
	endif
	
	String movestr=SetPeakname_list[Addrow][0]
	String fnlist=gs_FitPeakbkglist
	Variable preindex=WhichListItem(movestr,fnlist,";",0)
		if (leftflag)
			if (preindex>0)
				fnlist=AddListItem(movestr,fnlist,";",preindex-1)
				fnlist=RemoveListItem(preindex+1,fnlist,";")
				if (SetPeakname_list_sel[Addrow][Addcol][0]>=2)
					SetPeakname_list_sel[Addrow][Addcol][0]=2
					SetPeakname_list_sel[Addrow-1][Addcol][0]=3
				else
					SetPeakname_list_sel[Addrow][Addcol][0]=0
					SetPeakname_list_sel[Addrow-1][Addcol][0]=1
				endif
			endif
		else
			if (preindex<(itemsinlist(fnlist,";")-1))
				fnlist=AddListItem(movestr,fnlist,";",preindex+2)
				fnlist=RemoveListItem(preindex,fnlist,";")
				if (SetPeakname_list_sel[Addrow][Addcol][0]>=2)
					SetPeakname_list_sel[Addrow][Addcol][0]=2
					SetPeakname_list_sel[Addrow+1][Addcol][0]=3
				else
					SetPeakname_list_sel[Addrow][Addcol][0]=0
					SetPeakname_list_sel[Addrow+1][Addcol][0]=1
				endif
			endif
		endif
				
	gs_FitPeakbkglist=fnlist
	
	update_SetPeakname_list(1)

End

static Function SetPeakname_delete(ctrlname)
	String ctrlname
	
	Wave /T SetPeakname_list
	Wave /B SetPeakname_list_sel
	
	Variable Add_row=return_selected(SetPeakname_list_sel,0)
	
	SVAR graphname
	String DF_panel="root:internalUse:"+graphname
	DFREF DFR_panel=$DF_panel
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	SVAR gs_FitPeakbkglist=DFR_panel:gs_FitPeakbkglist
	Wave/T FitFnSave_strlist=DFR_fit:FitFnSave_strlist
	
	String checkstr=SetPeakname_list[Add_row][0]+"="
	Variable index
	String fnstr
	do
		if (index>=numpnts(FitFnSave_strlist))
			break
		endif
		fnstr=FitFnSave_strlist[index]
		if (strsearch(fnstr,checkstr,0)>=0)
			doalert 0,SetPeakname_list[Add_row][0]+" is used by Curve"+num2str(index)+"."
			return 0
		endif
	index+=1
	while (index<numpnts(	FitFnSave_strlist))
	
	gs_FitPeakbkglist=RemoveListItem(Add_row, gs_FitPeakbkglist , ";")
	
	String savewavename="SavePar_"+SetPeakname_list[Add_row][0]
	
	Wave /Z Savewave=DFR_fit:$savewavename
	Killwaves /Z Savewave
	
	update_SetPeakname_list(0)

End

static Function SetPeakname_Close(ctrlname)
	String ctrlname
	
	//if (stringmatch(ctrlname,"button0"))
	//endif
	
	Change_PeakNames()
	
	DoWindow/K PauseforSetPeakname
End
	
	
static Function Change_peakNames()
	Wave /T SetPeakname_list
	
	SVAR graphname
	String DF_panel="root:internalUse:"+graphname
	DFREF DFR_panel=$DF_panel
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	DFREF DFR_curves=$(DF_panel+":Fit_curves")
	
	SVAR gs_FitPeakbkglist=DFR_panel:gs_FitPeakbkglist
	
	Wave /T FitFnSave_strlist=DFR_fit:FitFnSave_strlist
	
	string newPeaklist=gs_FitPeakbkglist
	String oldname,newname,oldcstr,newcstr,oldsstr,newsstr,fnstr
	Variable index=0
	Variable pathindex
	do 
		if (index>=dimsize(SetPeakname_list,0))
		break
		endif
		oldname=SetPeakname_list[index][0]
		newname=SetPeakname_list[index][1]
		
		
		newPeaklist=replaceString(oldname+";", newPeaklist, newname+";")
						
		oldcstr=oldname+"="
		newcstr=newname+"="
			pathindex=0
			do
				if (pathindex>=numpnts(FitFnSave_strlist))
				break
				endif
				fnstr=FitFnSave_strlist[pathindex]
				if (strlen(fnstr)>0)
					fnstr=replaceString(oldcstr, fnstr, newcstr)
					FitFnSave_strlist[pathindex]=fnstr
				endif
				pathindex+=1
			while (pathindex<numpnts(FitFnSave_strlist))
		oldsstr="SavePar_"+oldname
		newsstr="SavePar_"+newname
		
		Wave /Z saveWave=DFR_fit:$oldsstr
		if (waveexists(saveWave))
			Rename saveWave,$newsstr
		endif
		
		Wave /Z curveWave=DFR_curves:$oldname
		if (waveexists(curveWave))
			rename curveWave,$newname
		endif
		
		index+=1
	while (index<dimsize(SetPeakname_list,0))
	
	gs_FitPeakbkglist=newPeaklist
End	
	
	
static Function proc_bt_SetFitString(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	Wave /T FitFnSave_strlist=DFR_fit:FitFnSave_strlist
		
	WAVE /T FitFnName_list=DFR_fit:FitFnName_list
	WAVE /B FitFnName_list_sel=DFR_fit:FitFnName_list_sel
	
	SVAR gs_Fndisplay=DFR_panel:gs_Fndisplay
	    
    //NVAR gv_Pathnum=DFR_panel:gv_pathnum
    
	//if ((event==4)||(event==5))
		//gv_Pathnum=row
		//controlinfo fit
		//if (stringmatch(S_Value,"Function"))
	Variable Addrow=return_selected(FitFnName_list_sel,0)
	Variable Addcol=return_selected(FitFnName_list_sel,1)		
	
	if (addcol==0)
		FitFnSave_strlist[Addrow]=gs_Fndisplay
	elseif (strlen(FitFnName_list[Addrow][Addcol][0])>0)
		String Fnlist=FitFnSave_strlist[Addrow]
		Fnlist=RemoveListItem(Addcol, Fnlist, ";" )
		gs_Fndisplay=removeending(gs_Fndisplay,";")
		Fnlist=AddListItem(gs_Fndisplay,Fnlist,";",Addcol)
		FitFnSave_strlist[Addrow]=Fnlist
	endif
		
	update_FitFnName_list()	
end



static Function proc_bt_AddConstrain(ctrlname)
	String ctrlname
	
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	SVAR gs_Fit_constrain=DFR_panel:gs_Fit_constrain
	SVAR CurveFit_constrain=DFR_panel:CurveFit_constrain
	
	if (stringmatch(gs_Fit_constrain[0],"K")==0)
		doalert 0,"Wrong constrain."
		return 0
	endif
	
	Variable temp
	Variable equalflag=0
	temp=strsearch(gs_Fit_constrain,">",0)
	if (temp==-1)
		temp=strsearch(gs_Fit_constrain,"<",0)
		if (temp==-1)
			temp=strsearch(gs_Fit_constrain,"=",0)
			if (temp==-1)
				doalert 0,"Wrong constrain."
				return 0
			else
				equalflag=1
			endif
		endif
	endif
	
	String parstr=gs_Fit_constrain[0,temp-1]
	Variable parnum=str2num(gs_Fit_constrain[1,temp-1])
	if (numtype(parnum)!=0)
		doalert 0,"Wrong constrain."
		return 0
	endif
	
	if (equalflag==0)
		if (FindlistItem(gs_Fit_constrain,CurveFit_constrain,";",0)==-1)
			CurveFit_constrain=AddListItem(gs_Fit_constrain,CurveFit_constrain,";",inf)	
		endif
	else
		String tempconstrain=ReplaceString("=", gs_Fit_constrain, "<")
		if  (FindlistItem(tempconstrain,CurveFit_constrain,";",0)==-1)
			CurveFit_constrain=AddListItem(tempconstrain,CurveFit_constrain,";",inf)
		endif
		tempconstrain=ReplaceString("=", gs_Fit_constrain, ">")
		if  (FindlistItem(tempconstrain,CurveFit_constrain,";",0)==-1)
			CurveFit_constrain=AddListItem(tempconstrain,CurveFit_constrain,";",inf)	
		endif
	endif	
		
	CurveFit_constrain=Sortlist(CurveFit_constrain,";")
	Wave /T Fit_Constrain_list=DFR_panel:Fit_Constrain_list
	
	SlistToWave(CurveFit_constrain,0,";",Nan,Nan)
		
	Wave /T w_StringList
	duplicate /o /t w_StringList,Fit_Constrain_list		
	Killwaves /Z w_StringList
	
	update_constrain_to_SavePara()
End

static Function proc_bt_DelConstrain(ctrlname)
	String ctrlname
	
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	SVAR gs_Fit_constrain=DFR_panel:gs_Fit_constrain
	SVAR CurveFit_constrain=DFR_panel:CurveFit_constrain
	
	Wave /T Fit_Constrain_list=DFR_panel:Fit_Constrain_list
	
	controlinfo FitMore_lb0
	
	//deletepoints v_value,1,Fit_Constrain_list
	
	CurveFit_constrain=RemoveListitem(v_value,CurveFit_constrain,";")
	
	Wave /T Fit_Constrain_list=DFR_panel:Fit_Constrain_list
	
	SlistToWave(CurveFit_constrain,0,";",Nan,Nan)
		
	Wave /T w_StringList
	duplicate /o /t w_StringList,Fit_Constrain_list	
	
	update_constrain_to_SavePara()
		
	Killwaves /Z w_StringList	
	
end











static Function proc_ck_fitdim(ctrlname,value)
	String ctrlname
	Variable value
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	
	NVAR gv_dimflag=DFR_panel:gv_dimflag
	NVAR gv_fitdimflag=DFR_panel:gv_fitdimflag
	Wave /T FitWavePath_list=DFR_panel:FitWavePath_list

	Variable ckvalue
	
	strswitch(ctrlname)
	case "Function_ck5":
		ckvalue=0
		gv_fitdimflag=0
	break
	case "Function_ck6":
		ckvalue=1
		gv_fitdimflag=1
	break
	endswitch
	
	checkbox Function_ck5,value=ckvalue==0
	checkbox Function_ck6,value=ckvalue==1
	
	update_fitdata_savewave()
	
	WAVE /B FitFnName_list_sel=DFR_fit:FitFnName_list_sel
	FitFnName_list_sel[][][0]=0
	FitFnName_list_sel[0][0][0]=1
	FitFn_Listbox_proc("dummy",0,0,4)  
End



static Function update_fitdata_savewave()
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	SetActiveSubwindow $winname(0,65)
	
	Wave /T FitFnName_list=DFR_fit:FitFnName_list
	Wave /B FitFnName_list_sel=DFR_fit:FitFnName_list_sel	
	Wave /T FitFnSave_strlist=DFR_fit:FitFnSave_strlist
	Wave /T FitFnSave_Constrain=DFR_fit:FitFnSave_Constrain
  	Wave /T FitFnSave_Parstr=DFR_fit:FitFnSave_Parstr
    	Wave FitSave_DataWave=DFR_fit:FitSave_DataWave
    	
    	Wave /T FitWavename_list=DFR_panel:FitWavename_list
    	Wave /T FitWavePath_list=DFR_panel:FitWavePath_list
    	
    	if (numpnts(FitWavename_list)==0)
    		Redimension /n=(0, 1,-1),  FitFnName_list,FitFnName_list_sel,FitFnSave_strlist,FitFnSave_Constrain,FitFnSave_Parstr,FitSave_DataWave
		SetDatafolder DF
		return 0
	endif
	SetDatafolder DFR_panel
	
	NVAR gv_dimflag=DFR_panel:gv_dimflag
	
	if (gv_dimflag==1)
		Variable FitWave_num=numpnts(FitWavename_list)
		Variable FitWave_maxnumpnts=0
		Variable index=0
		
		do
			Wave /Z data=$FitWavePath_list[index]
			if (numpnts(data)>FitWave_maxnumpnts)
				FitWave_maxnumpnts=numpnts(data)
			endif
		
			index+=1
		while (index<Fitwave_num)
	else
		NVAR gv_fitdimflag=DFR_panel:gv_fitdimflag
		Wave /Z data=$FitWavePath_list[0]
		
		if (gv_fitdimflag==0)
			FitWave_num=dimsize(data,1)
			FitWave_maxnumpnts=dimsize(data,0)
		elseif (gv_fitdimflag==1) 
			FitWave_num=dimsize(data,0)
			FitWave_maxnumpnts=dimsize(data,1)
		endif
		
		
		Redimension /n=((FitWave_num), -1,-1), FitFnName_list,FitFnName_list_sel,FitFnSave_strlist,FitFnSave_Constrain,FitSave_DataWave,FitFnSave_Parstr//,FitSave_FitCurve
		
		if (dimsize(FitSave_DataWave,1)<FitWave_maxnumpnts)
			redimension /N=(-1,FitWave_maxnumpnts,-1) FitSave_DataWave//,FitSave_FitCurve
		endif
			
		if (gv_fitdimflag==0) //for mdc
    			FitFnName_list[][0]="MDC_"+num2str(FitWave_num-1-p)+"="
    		elseif (gv_fitdimflag==1) // for edc
    			FitFnName_list[][0]="EDC_"+num2str(p)+"="
    		endif
		
		SetDatafolder DF
		return 0
	endif
	
	String WaveNamelist=""
	
	if (numpnts(FitFnName_list)>0)
		Make /o/T /n=(dimsize(FitFnName_list,0)) FitFnNamelist
		FitFnNamelist=FitFnName_list[p][0]
		WaveNamelist= WaveToStringList(FitFnNamelist,";",Nan,Nan)
		Duplicate /T/o /FREE FitFnName_list, FitFnName_Free
		Duplicate /B/o/FREE FitFnName_list_sel,FitFnName_listsel_Free
		Duplicate /T/o /FREE FitFnSave_strlist,FitFNSave_strlist_free
		Duplicate /T/o /FREE FitFnSave_Constrain,FitFnsave_constrain_free
		Duplicate /o /FREE FitSave_DataWave,FitSave_Datawave_free
		Duplicate /T/o /FREE FitFnSave_Parstr,FitFnSave_parstr_free
	endif
	
	Redimension /n=((FitWave_num), -1,-1),  FitFnName_list,FitFnName_list_sel,FitFnSave_strlist,FitFnSave_Constrain,FitSave_DataWave,FitFnSave_Parstr//,FitSave_FitCurve
	if (dimsize(FitSave_DataWave,1)<FitWave_maxnumpnts)
		redimension /N=(-1,FitWave_maxnumpnts,-1) FitSave_DataWave//,FitSave_FitCurve
	endif
	FitFnName_list[][0]=FitWavename_list[p]+"="	
	
	
	index=0
	do
		String WaveN=FitFnName_list[index][0]
		
		Variable items=WhichListItem(WaveN, WaveNamelist, ";" , 0)
		if (items!=-1)
			FitFnName_list[index][][]=FitFnName_Free[items][q][r]
			FitFnName_list_sel[index][][]=FitFnName_listsel_Free[items][q][r]
			FitFnSave_strlist[index][][]=FitFNSave_strlist_free[items][q][r]
			FitFnSave_Constrain[index][][]=FitFnsave_constrain_free[items][q][r]
			FitSave_DataWave[index][][]=FitSave_Datawave_free[items][q][r]
			FitFnSave_Parstr[index][][]=FitFnSave_parstr_free[items][q][r]
		else
			FitFnName_list[index][1,inf]=""
			FitFnSave_strlist[index][][]=""
			FitFnSave_Constrain[index][][]=""
			FitFnSave_Parstr[index][][]=""
			FitSave_DataWave[index][][]=0
		endif
		index+=1
	while (index<Fitwave_num)
	
	FitFnName_list[][0]=FitWavename_list[p]+"="	
End



/////////////////////////////////////Output /////////////////////////////////////

static function FitOutput_SepAppendPar(ctrlname)
	string ctrlname
	
	GP_SepAppend()
End


static function FitOutput_DisplayImage(ctrlname)
	String ctrlname
	
	DFREF DF=GetDatafolderDFR()
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	SetActiveSubwindow $winname(0,65)
	String graphname=winname(0,65)
	
	
	Wave /T FitOutputpar_list=DFR_panel:FitOutputpar_list
	
	Wave /T FitWavePath_list=DFR_panel:FitWavePath_list
	
	
	
	
	NVAR gv_dimflag=DFR_panel:gv_dimflag
	NVAR gv_imageresultpnts=DFR_panel:gv_imageresultpnts
	
	Wave w_trace=DFR_common:w_trace
	
	if (stringmatch(ctrlname,"output_b11"))
		Wave /T FitOutputName_list=DFR_panel:FitOutputName_list
		Wave /B FitOutputName_list_sel=DFR_panel:FitOutputName_list_sel
		Variable Addrow=return_selected(FitOutputName_list_sel,0)
		String Peakname=FitOutputName_list[Addrow]
		
	elseif (stringmatch(ctrlname,"output_b12"))
		Peakname="rawData"
	elseif (stringmatch(ctrlname,"output_b13"))
		Peakname="fitData"
	endif
	
	
	String ImageSavename="SaveImage_"+Peakname
	Wave /Z IMGSave=DFR_fit:$ImageSavename
	
	String notestr=note(IMGSave)
	
	String ImagePlotname="ResultImage_"+Peakname
	
	Prompt ImagePlotname,"Input Image name"
	Doprompt "Input Image name",ImagePlotname
	if (V_flag)
		return 0
	endif
	
	SetDatafolder DFR_panel
	
	Variable x0,dx,xn,y0,dy,yn
	
	if (gv_dimflag==2)
		Wave w_image=$FitWavePath_list[0]
		NVAR gv_fitdimflag=DFR_panel:gv_fitdimflag
		if (gv_fitdimflag==0) //MDC
			x0=dimoffset(w_image,1)
			dx=dimdelta(w_image,1)
			xn=dimsize(w_image,1)
			
			y0=dimoffset(w_image,0)
			dy=dimdelta(w_image,0)
			yn=dimsize(w_image,0)
			
		else
			x0=dimoffset(w_image,0)
			dx=dimdelta(w_image,0)
			xn=dimsize(w_image,0)
		
			y0=dimoffset(w_image,1)
			dy=dimdelta(w_image,1)
			yn=dimsize(w_image,1)
		endif
		
		Make /o /n=(xn) w_y0,w_dy,w_yn
		Variable index=0
		do
			String Keystr="Line"+num2str(index)
			w_y0[index]=NumberByKey(Keystr+"x0", notestr ,"=","\r")
			w_dy[index]=NumberByKey(Keystr+"dx", notestr ,"=","\r")
			w_yn[index]=NumberByKey(Keystr+"xn", notestr ,"=","\r")
			
			index+=1
		while (index<xn)
	else
		x0=0
		dx=1
		xn=dimsize(FitWavePath_list,0)	
		
		Make /o /n=(xn) w_y0,w_dy,w_yn
		index=0
		do
			Keystr="Line"+num2str(index)
			w_y0[index]=NumberByKey(Keystr+"x0", notestr ,"=","\r")
			w_dy[index]=NumberByKey(Keystr+"dx", notestr ,"=","\r")
			w_yn[index]=NumberByKey(Keystr+"xn", notestr ,"=","\r")
			
			index+=1
		while (index<xn)
		
		y0=wavemin(w_y0)
		dy=wavemin(w_dy)
		yn=wavemax(w_yn)
		
	endif
		
	
		
	if (numtype(gv_imageresultpnts)==2)
		Make /o/n=(xn,yn) $ImagePlotname
	else
		Make /o/n=(xn,gv_imageresultpnts) $ImagePlotname	
	endif
	
	Wave w_result_temp=$ImagePlotname	
	
	Setscale /P x, x0,dx,w_result_temp
	Setscale /P y, y0,dy,w_result_temp
		
	index=0
	do 
		if ((numtype(w_trace[index])==2)||(numtype(w_yn[index])==2))
			w_result_temp[index][]=Nan
		else
			Make /o /n=(w_yn[index]) w_trace_temp
			Setscale /P x, w_y0[index],w_dy[index],w_trace_temp
			w_trace_temp[]=IMGSave[index][p]
			
			w_result_temp[index][]=w_trace_temp(y)
		endif
		
		
		index+=1
	while (index<xn)
	
	display_wave(w_result_temp,0,0)
	
	Killwaves /Z w_y0,w_dy,w_yn,w_result_Temp,w_trace_Temp
	
	SetDatafolder DF
	
End
static function FitOutput_displayPar(ctrlname)
	string ctrlname
	
	DFREF DF=GetDatafolderDFR()
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	String graphname=winname(0,65)
	
	Wave /T FitOutputName_list=DFR_panel:FitOutputName_list
	Wave /B FitOutputName_list_sel=DFR_panel:FitOutputName_list_sel
	Wave /T FitOutputpar_list=DFR_panel:FitOutputpar_list
	
	Variable Addrow=return_selected(FitOutputName_list_sel,0)
	String Peakname=FitOutputName_list[Addrow]
	
	controlinfo Output_lb1
	String Parname=FitOutputpar_list[V_value]
	
	String Savewavename=Peakname+"_"+Parname
	String panelname=winname(0,65)[9,inf]
	Savewavename+=panelname
	
	Wave w_trace=DFR_common:w_trace
	Wave w_trace_error=DFR_common:w_trace_error
	Wave w_trace_conf=DFR_common:w_trace_conf
	NVAR gv_fitdimflag=DFR_panel:gv_fitdimflag
	NVAR gv_dimflag=DFR_panel:gv_dimflag
	NVAR gv_errorbardispflag=DFR_panel:gv_errorbardispflag
	
	prompt Savewavename,"The Wave name"
	
	doprompt "Save the Parameter to:",Savewavename
	
	if (V_flag==1)
		SetDatafolder DF
		return 0
	endif
	
	controlinfo Output_ck0
	Variable vertflag=v_value
	
	//Variable x0=xcsr(A)
	//Variable x1=xcsr(B)
	//if (x0>x1)
	//	x0=xcsr(B)
	//	x1=xcsr(A)
	//endif
		
	if (stringmatch(ctrlname,"Output_b5"))
		String w_df="root:graphsave:Others:"
		display /K=1
		String gN=uniquename(Savewavename,6,0)
		Dowindow /C $gN
		SetWindow $gN, hook(MyHook) = MygraphHook
		newDatafolder /o/s $(w_df+gN)
	else
		gN=winname(1,65)
		Wave data_gn=WaveRefIndexed(gN, 0, 1)
		if (WaveExists(data_gN)==0)
			Wave data_gn=ImageNameToWaveRef(gN,stringfromlist(0,ImageNameList(gN, ";")))
		endif
			
		w_df=GetWavesDatafolder(data_gn,1)
		SetDatafolder $w_df
	endif
		
		duplicate /o w_trace $Savewavename
		Wave data_plot=$Savewavename
		
		String errorwavename=Savewavename
		
		NVAR gv_dimflag=DFR_panel:gv_dimflag
		
		if (gv_dimflag==2)
			if (vertflag)
				AppendToGraph  /W=$gN /VERT data_plot
			else
				AppendToGraph  /W=$gN data_plot
			endif
		else
			controlinfo /w=$graphname output_pp0
			switch(V_value)
			case 1:
				String xwaveN=Savewavename+"_xindex"
				duplicate /o data_plot, $xwaveN
				wave xwave=$xwaveN
				xwave=p
			case 2:
				xwaveN=Savewavename+"_xtem"
				wave xwave=DFR_panel:xwave_tem
				duplicate /o xwave, $xwaveN
				wave xwave=$xwaveN
				break
			case 3:
				xwaveN=Savewavename+"_xphotonE"
				wave xwave=DFR_panel:xwave_photonE
				duplicate /o xwave, $xwaveN
				wave xwave=$xwaveN
				break
			case 4:
				xwaveN=Savewavename+"_Energy"
				wave xwave=DFR_panel:xwave_Energy
				duplicate /o xwave, $xwaveN
				wave xwave=$xwaveN
				break
			case 5:
				xwaveN=Savewavename+"_momentum"
				wave xwave=DFR_panel:xwave_momentum
				duplicate /o xwave, $xwaveN
				wave xwave=$xwaveN
				break
			endswitch
			
			if (V_value==1)
				if (vertflag)
					AppendToGraph  /W=$gN /VERT data_plot
				else
					AppendToGraph  /W=$gN data_plot
				endif
			else
				if (vertflag)
					AppendToGraph  /W=$gN /VERT data_plot vs xwave
				else
					AppendToGraph  /W=$gN data_plot vs xwave
				endif
			endif
		endif
		
		if (gv_errorbardispflag==0)
			ErrorBars /W=$gN $Savewavename OFF 
		elseif (gv_errorbardispflag==1)
			errorwavename+="_error"
			duplicate /o  w_trace_error $errorwavename
			ErrorBars /W=$gN $Savewavename Y,wave=($errorwavename,$errorwavename)
		elseif (gv_errorbardispflag==2)
			errorwavename+="_conf"
			duplicate /o  w_trace_conf $errorwavename
			ErrorBars /W=$gN $Savewavename Y,wave=($errorwavename,$errorwavename)
		endif
			
		ModifyGraph /W=$gN mode($Savewavename)=4,marker($Savewavename)=8,msize($Savewavename)=1.5
	
	
		
		SetDatafolder DF
end

static function FitOutput_VertChange(ctrlname,value)
	String ctrlname
	Variable value
	
end

static function FitOutput_errorChange(ctrlname,value)
	String ctrlname
	Variable value
	DFREF DF=GetDatafolderDFR()
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	
	NVAR gv_errorbardispflag=DFR_panel:gv_errorbardispflag
	
	Variable ckvalue
	
	strswitch(ctrlname)
	case "Output_ck1":
		if (value)
			ckvalue=1
		else
			ckvalue=0
		endif
		break
	case "Output_ck2":
		if (value)
			ckvalue=2
		else
			ckvalue=0
		endif
		break
	endswitch
	
	gv_errorbardispflag=ckvalue
	
	checkbox Output_ck1,value=ckvalue==1
	checkbox Output_ck2,value=ckvalue==2
	update_outputwave()
end

static function FitOutput_stylechange(ctrlname)
	String ctrlname
	
	DFREF DF=GetDatafolderDFR()
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	
	Wave w_trace=DFR_common:w_trace
	
	if (stringmatch(ctrlname, "Output_b0"))
		w_trace=(w_trace==0)?(Nan):(w_trace)
		return 0
	endif
	
	Variable pA=pcsr(A)
	Variable pB=pcsr(B)
	
		
	if (stringmatch(ctrlname, "Output_b1"))
		w_trace[pA,pB]=Nan
		return 0
	endif
	
	if (stringmatch(ctrlname, "Output_b2"))
		w_trace[0,pA]=Nan
		return 0
	endif
	
	if (stringmatch(ctrlname, "Output_b3"))
		w_trace[pB,inf]=Nan
		return 0
	endif
	
	if (stringmatch(ctrlname, "Output_b4"))
		w_trace[]=ABS(w_trace)
	endif
	
	if (stringmatch(ctrlname, "Output_b7"))
		if (pA>pB)
			w_trace[0,pB]=Nan
			w_trace[pA,inf]=Nan
		else
			w_trace[0,pA]=Nan
			w_trace[pB,inf]=Nan
		endif
		return 0
	endif
	
	if (stringmatch(ctrlname,"Output_b10"))
		NVAR gv_errorlevel=DFR_panel:gv_errorlevel
		controlinfo Output_ck2
		if (v_Value)
			Wave w_error=DFR_common:w_trace_conf
		else
			Wave w_error=DFR_common:w_trace_error
		endif
		
		w_Trace=(abs(w_error[p]/w_trace[p])>gv_errorlevel/100)?(Nan):(w_trace[p])
		
		return 0
	endif
	
end

static Function FitOutput_Listbox_proc(ctrlName,row,col,event) : ListboxControl
	String ctrlName     // name of this control
	Variable row        // row if click in interior, -1 if click in title
	Variable col        // column number
	Variable event      // event code
	
	
	DFREF DF=GetDatafolderDFR()
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	
	Wave /T FitOutputName_list=DFR_panel:FitOutputName_list
	Wave /B FitOutputName_list_sel=DFR_panel:FitOutputName_list_sel
	Wave /T FitOutputpar_list=DFR_panel:FitOutputpar_list
	
	SetDatafolder DFR_panel
	
	if (stringmatch(ctrlname,"Output_lb0"))
	
		if ((event==1)||(event==4))
		
		SVAR gs_FitPeakbkglist=DFR_panel:gs_FitPeakbkglist
		Variable peaknum=itemsinlist(gs_FitPeakbkglist,";")	
		
		redimension /n=(peaknum,-1) FitOutputName_list
		redimension /n=(peaknum,-1,-1) FitOutputName_list_sel
		
		SetDimLabel 1,-1,PeakName,FitOutputName_list
		
		Variable index
		do
			if (index>=peaknum)
				break
			endif
		
			FitOutputName_list[index][]=stringfromlist(index,gs_FitPeakbkglist,";")
			FitOutputName_list_sel[index][0][0]=0
			FitOutputName_list_sel[index][0][1]=index+1
			index+=1
		while (index<peaknum)
		
		FitOutputName_list_sel[row][0][0]=1
		
		endif
		
		if (event==4)
			if (dimsize(FitOutputName_list,0)>0)
				Variable Fnnum=Check_Resturn_Fnnum(FitOutputName_list[row])
					if (Fnnum==-1)
						redimension /n=(0,1) FitOutputpar_list
						SetDatafolder DF
						return 0
					endif
				update_outputParlist(Fnnum)
				update_outputwave()
			else
				redimension /n=(0,1) FitOutputpar_list
			endif
			
		endif
		
	endif
	
	if (stringmatch(ctrlname,"Output_lb1"))
		update_outputwave()
	endif
		
	SetDatafolder DF
	return 0            // other return values reserved
end

Function update_outputWave()
	DFREF DF=GetDatafolderDFR()
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	SetActiveSubwindow $winname(0,65)
	
	Wave /T FitOutputName_list=DFR_panel:FitOutputName_list
	Wave /B FitOutputName_list_sel=DFR_panel:FitOutputName_list_sel
	Wave /T FitOutputpar_list=DFR_panel:FitOutputpar_list
	
	NVAR gv_errorbardispflag=DFR_panel:gv_errorbardispflag
	
	Variable Selrow=return_selected(FitOutputName_list_sel,0)
	
	controlinfo Output_lb1
	Variable parrow=v_value
	
	String peakname=FitOutputName_list[Selrow]
	String SaveWaveName="SavePar_"+peakname
	
	Wave /Z Savewave=DFR_fit:$SaveWaveName
	
	if (waveexists(Savewave)==0)
		SetDatafolder DF
		return 0
	endif
	
	SetDatafolder DFR_common
	duplicate /o /R=[][parrow][0] Savewave,w_trace
	duplicate /o /R=[][parrow][2] Savewave,w_trace_error
	duplicate /o /R=[][parrow][3] Savewave,w_trace_conf
	
	redimension /n=(-1) w_trace,w_trace_error,w_trace_conf
	
	NVAR gv_dimflag=DFR_panel:gv_dimflag
	NVAR gv_fitdimflag=DFR_panel:gv_fitdimflag
	
	SetDatafolder DFR_panel
	
	if (gv_dimflag==2)
		Wave /T FitWavePath_list=DFR_panel:FitWavePath_list
		Wave /Z data=$FitWavePath_list[0]
		if (Waveexists(data))
			if (gv_fitdimflag==0)  //mdc
				//w_trace=w_trace_temp[numpnts(w_trace)-1-p]
				Reverse /P w_trace,w_trace_error,w_trace_conf
				Variable x0=M_y0(data)
				Variable x1=M_y1(data)
				Setscale /I x,x0,x1,w_trace
			else
				x0=M_x0(data)
				x1=M_x1(Data)
				Setscale /I x,x0,x1,w_trace,w_trace_error,w_trace_conf
			endif
		endif
	else
		Variable aExists= strlen(CsrInfo(A)) > 0
		variable bExists= strlen(CsrInfo(B)) > 0
		
		Variable tempA,tempB
		if (bExists == 0)
			tempB= (numpnts(w_trace)-10)
		else
			tempB=pcsr(B)
		endif
		if (aExists == 0)
			tempA=10
		else	
			tempA=pcsr(A)
		endif
	
		controlinfo output_pp0
		switch(V_value)
			case 1:
				removefromgraph /Z w_trace
				appendtograph w_trace
				ModifyGraph grid=2,gridStyle=1
				break
			case 2:
				wave xwave=DFR_panel:xwave_tem
				removefromgraph /Z w_trace
				appendtograph w_trace vs xwave
				ModifyGraph grid=2,gridStyle=1
				break
			case 3:
				wave xwave=DFR_panel:xwave_photonE
				removefromgraph /Z w_trace
				appendtograph w_trace vs xwave
				ModifyGraph grid=2,gridStyle=1
				break
			case 4:
				wave xwave=DFR_panel:xwave_Energy
				removefromgraph /Z w_trace
				appendtograph w_trace vs xwave
				ModifyGraph grid=2,gridStyle=1
				break
			case 5:
				wave xwave=DFR_panel:xwave_Momentum
				removefromgraph /Z w_trace
				appendtograph w_trace vs xwave
				ModifyGraph grid=2,gridStyle=1
				break
		endswitch
		

		ShowInfo; Cursor /P/H=2 B w_trace tempB
		Cursor /P/H=2 A w_trace tempA
		
	endif
	
	ModifyGraph mode(w_trace)=4,marker(w_trace)=8,msize(w_trace)=1.5
	
	if (gv_errorbardispflag==0)
		ErrorBars w_trace OFF 
	elseif (gv_errorbardispflag==1)
		ErrorBars w_trace Y,wave=(w_trace_error,w_trace_error)
	elseif (gv_errorbardispflag==2)
		ErrorBars w_trace Y,wave=(w_trace_conf,w_trace_conf)
	endif
	Killwaves /Z w_trace_temp
	
	setDatafolder DF
end

Function update_outputParlist(Fnnum)
	Variable Fnnum
	
	DFREF DF=GetDatafolderDFR()
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	SetActiveSubwindow $winname(0,65)
	
	Wave /T FitOutputPar_list=DFR_panel:FitOutputPar_list
		
		if (Fnnum>=400)
			Fnnum-=400
			Wave /T FNlist=DFR_panel:bkgFns
		elseif (Fnnum>=200)
			Fnnum-=200
			Wave /T FNlist=DFR_panel:peakFns
		elseif (Fnnum>=0)
			if (Fnnum>4)
				//parnum=0
				redimension /n=0 FitOutputPar_list
				SetDatafolder DF
				return 0
			else
				Fnnum-=1
				Wave /T FNlist=DFR_panel:coefFns
			endif
		else
			SetDatafolder DF
			return 0
		endif
	
		Variable parnum=str2num(FNlist[Fnnum][1])
		
		redimension /n=(parnum) FitOutputPar_list
		
		Variable parindex=0
		do
			FitOutputPar_list[parindex]=FNlist[Fnnum][2+parindex]
			parindex+=1
		while (parindex<parnum)
		
		SetDatafolder DF
		return 1 
End

Function Check_Resturn_Fnnum(peakname)
	String peakname
	DFREF DF=GetDatafolderDFR()
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_fit=$(DF_panel+":Fit_data")
	SetActiveSubwindow $winname(0,65)
	
	Wave /T FitFnSave_strlist=DFR_fit:FitFnSave_strlist
	
	Variable index
	Variable Fnnum
	String fnlist,fnstr="",fnstrO=""
	do
		if (index>=numpnts(FitFnSave_strlist))
			break
		endif
		fnlist=FitFnSave_strlist[index]
		fnstr=stringbykey(peakname,fnlist,"=",";")
		
		if (strlen(fnstr)==0)
			index+=1
			continue
		endif
				
		if (strlen(fnstrO)==0)
			fnstrO=fnstr
		else
			if (stringmatch(fnstr,fnstrO)==0)
				doalert 0,"The Fit Function is not the same for "+peakname+"." 
				return -1
			endif
		endif	
		index+=1
	while (index<numpnts(FitFnSave_strlist))
	
	if (strlen(fnstrO)==0)
		doalert 0,"The "+peakname+" is not found."
		return -1
	endif
	
	return GetFn_num(fnstrO)
	
End


Function /DF initial_weightpanel()
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	SetDataFolder DFR_panel
	
	wave w_Trace=DFR_common:w_trace
	wave /z w_Weight=DFR_panel:w_weight
	if (Waveexists(w_weight)==0)
		duplicate /o w_trace DFR_panel:w_weight
		wave /z w_Weight=DFR_panel:w_weight
		w_Weight=1
	endif
	
	newDatafolder /o/s EditWeight
	
	
	Variable /G gv_setvalue=0.1
	Variable /G gv_leftlimit=leftx(w_Trace)
	Variable /G gv_rightlimit=rightx(w_trace)
	Variable /G gv_deltaX=deltax(w_trace)
	Variable /G gv_leftrange=gv_leftlimit
	Variable /G gv_rightrange=gv_rightlimit
	
	Variable /G gv_weightpnts=numpnts(w_weight)
	Variable /G gv_weightx0=leftx(w_weight)
	Variable /G gv_weightx1=rightx(w_weight)
	
	variable /G gv_smtpnts=5
	
	Make /o/n=2 sliceplot_YA,sliceplot_XA
	Make /o/n=2 sliceplot_YB,sliceplot_XB
	sliceplot_YA[0]=-2
	sliceplot_YA[1]=2
	sliceplot_yB[0]=-2
	sliceplot_YB[1]=2
	sliceplot_XA=gv_leftlimit
	sliceplot_XB=gv_rightlimit
	
	SetFormula sliceplot_XA, "gv_leftrange"
	SetFormula sliceplot_XB, "gv_rightrange"
	
	Killwaves /Z w_weight_backup
	
	DFREF DFR_weight=GetDatafolderDFR()
	
	SetDatafolder DF
	return DFR_weight
End

Function open_weightWavepanel(ctrlname)
	String ctrlname
	
	DFREF DF = GetDataFolderDFR()
		
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	SetDataFolder DFR_panel
	
	String wname=winname(0,65)

	String Cwnamelist=ChildWindowList(wname)
	
	if (Findlistitem("Edit_weightWave",Cwnamelist,";",0)!=-1)
 		KillWindow $wname#Edit_weightWave
 		SetDatafolder DF
 		return 0
	endif
	
	Variable SC=ScreenSize(5)
	Variable width=500*SC,Height=450*SC
	
	DFREF DFR_weight=Initial_weightpanel()
	
	wave w_Trace=DFR_common:w_trace
	wave /z w_Weight=DFR_panel:w_weight
	
	
	SetDatafolder DFR_weight
	
	NewPanel /Host=$wname/EXT=0/K=1/W=(0,0,width,Height)/N=Edit_weightWave as "Edit_weightWave"
	
	Modifypanel /W=$wname#Edit_weightWave cbRGB=(52428,52428,52428)
	ModifyPanel /W=$wname#Edit_weightWave noEdit=1, fixedSize=1
	
	DefineGuide UGH0={FT,70*SC},UGH1={FT,350*SC}
    	DefineGuide UGH2={FL,20*SC},UGH3={FL,480*SC}
    	Display   /FG=(UGH2,UGH0,UGH3,UGH1)/Host=$wname#Edit_weightWave  /N=Weight_InsertTrace as "Weight_InsertTrace"
    	
    	Appendtograph /W=$wname#Edit_weightWave#Weight_InsertTrace /L=left_weight w_Weight
	Appendtograph /W=$wname#Edit_weightWave#Weight_InsertTrace w_trace
	
	ModifyGraph /W=$wname#Edit_weightWave#Weight_InsertTrace axisEnab(left)={0,0.5}
	ModifyGraph /W=$wname#Edit_weightWave#Weight_InsertTrace freePos(left_weight)=0
	ModifyGraph /W=$wname#Edit_weightWave#Weight_InsertTrace axisEnab(left_weight)={0.52,1}
	
	Wave sliceplot_YA,sliceplot_YB,sliceplot_XA,sliceplot_XB
	
	Appendtograph /W=$wname#Edit_weightWave#Weight_InsertTrace /L=left_slice sliceplot_YA vs sliceplot_XA
	Appendtograph /W=$wname#Edit_weightWave#Weight_InsertTrace /L=left_slice sliceplot_YB vs sliceplot_XB
	
	ModifyGraph /W=$wname#Edit_weightWave#Weight_InsertTrace freePos(left_slice)=100
	ModifyGraph /W=$wname#Edit_weightWave#Weight_InsertTrace lstyle(sliceplot_YA)=2,rgb(sliceplot_YA)=(0,65535,0)
	ModifyGraph /W=$wname#Edit_weightWave#Weight_InsertTrace lstyle(sliceplot_YB)=2,rgb(sliceplot_YB)=(0,0,65535)
	
	NVAR gv_leftlimit,gv_rightlimit,gv_deltax
	
	slider weight_sl0,pos={64*SC,20*SC},size={404*SC,20*SC},ticks=0,vert=0,limits={gv_leftlimit,gv_rightlimit,gv_deltax},title="left:",variable=gv_leftrange
	slider weight_sl1,pos={64*SC,45*SC},size={404*SC,20*SC},ticks=0,vert=0,limits={gv_leftlimit,gv_rightlimit,gv_deltax},title="right:",variable=gv_rightrange
	Setvariable weight_sv0,pos={10*SC,20*SC},size={60*SC,20*SC},limits={gv_leftlimit,gv_rightlimit,gv_deltax},title=" ",variable=gv_leftrange
	Setvariable weight_sv1,pos={10*SC,45*SC},size={60*SC,20*SC},limits={gv_leftlimit,gv_rightlimit,gv_deltax},title=" ",variable=gv_rightrange
	
	groupbox weight_gp0,pos={20*SC,360*SC},size={140*SC,70*SC},title="Set Weight Value",frame=0
	
	Setvariable weight_sv2,pos={30*SC,380*SC},size={120*SC,20*SC},limits={0,inf,0},title="Weight Value ",variable=gv_setvalue
	Button weight_bt0,pos={30*SC,403*SC},size={55*SC,20*SC},limits={0,inf,0},title="Set",proc=proc_bt_setweightvalue
	Button weight_bt1,pos={95*SC,403*SC},size={55*SC,20*SC},limits={0,inf,0},title="Default",proc=proc_bt_setweightvalue
	
	groupbox weight_gp1,pos={170*SC,360*SC},size={175*SC,70*SC},title="Set Weight wave range",frame=0
	Setvariable weight_sv3,pos={180*SC,380*SC},size={60*SC,20*SC},limits={0,inf,0},title="pnts:",variable=gv_weightpnts
	Setvariable weight_sv4,pos={180*SC,405*SC},size={75*SC,20*SC},limits={0,inf,0},title="x0:",variable=gv_weightx0
	Setvariable weight_sv5,pos={265*SC,405*SC},size={75*SC,20*SC},limits={0,inf,0},title="x1:",variable=gv_weightx1
	Button weight_bt2,pos={245*SC,378*SC},size={45*SC,20*SC},limits={0,inf,0},title="Set",proc=proc_bt_setweightrange
	Button weight_bt3,pos={295*SC,378*SC},size={45*SC,20*SC},limits={0,inf,0},title="Default",proc=proc_bt_setweightrange
	
	groupbox weight_gp2,pos={350*SC,360*SC},size={130*SC,70*SC},title="Weight wave proc",frame=0
	Setvariable weight_sv6,pos={360*SC,380*SC},size={60*SC,20*SC},limits={0,inf,0},title="pnts:",variable=gv_smtpnts
	Button weight_bt5,pos={360*SC,403*SC},size={45*SC,20*SC},limits={0,inf,0},title="smooth",proc=proc_bt_smoothweight
	Button weight_bt6,pos={420*SC,403*SC},size={45*SC,20*SC},limits={0,inf,0},title="reset",proc=proc_bt_smoothweight
	
	
end

Function proc_bt_smoothweight(ctrlname)
	String ctrlname
	DFREF DF = GetDataFolderDFR()
		
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_weight=$(DF_panel+":EditWeight")
	
	wave  w_Weight=DFR_panel:w_weight
	
	SetDatafolder DFR_weight
	
	NVAR gv_smtpnts
	
	Wave /Z w_weight_Backup
	if (Waveexists(w_weight_Backup)==0)
		duplicate /o w_weight,w_weight_backup
	endif
	
	if (Stringmatch(ctrlname,"weight_bt5"))
		smooth gv_smtpnts,w_weight
	else
		duplicate /o w_weight_backup,w_weight
		Killwaves /Z w_weight_backup
	endif
	
	SetDatafolder DF
End

Function proc_bt_setweightrange(ctrlname)
	String ctrlname
	DFREF DF = GetDataFolderDFR()
		
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_weight=$(DF_panel+":EditWeight")
	
	wave  w_Weight=DFR_panel:w_weight
	
	NVAr gv_weightpnts=DFR_weight:gv_weightpnts
	NVAr gv_weightx0=DFR_weight:gv_weightx0
	NVAr gv_weightx1=DFR_weight:gv_weightx1
	
	duplicate /o /free w_weight,w_weight_backup
	
	if (stringmatch(ctrlname,"weight_bt3"))
		wave w_Trace=DFR_common:w_trace
		gv_weightpnts=numpnts(w_trace)
		gv_weightx0=leftx(w_Trace)
		gv_weightx1=rightx(w_Trace)	
	endif
	
	redimension /n=(gv_weightpnts) w_weight
	Setscale /I x,gv_weightx0,gv_weightx1, w_weight
	w_weight=w_weight_backup(x)
End

Function proc_bt_setweightvalue(ctrlname)
	string ctrlname
	
	DFREF DF = GetDataFolderDFR()
		
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_weight=$(DF_panel+":EditWeight")
	
	wave  w_Weight=DFR_panel:w_weight
	
	NVAR gv_leftrange=DFR_weight:gv_leftrange
	NVAR gv_rightrange=DFR_weight:gv_rightrange
	NVAR gv_setvalue=DFR_weight:gv_setvalue
	
	if (stringmatch(ctrlname,"weight_bt0"))
		w_Weight[x2pnt(w_weight, gv_leftrange),x2pnt(w_weight, gv_rightrange)]=gv_setvalue
	else
		w_Weight=1
	endif
End


