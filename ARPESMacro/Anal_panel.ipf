#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 0.01
#pragma ModuleName = Analpanel

Function /DF init_Anal_panel()
	DFREF DF = GetDataFolderDFR()
   	String DF_panel="root:internalUse:"+winname(0,65)
   	NewDataFolder/O/S $DF_panel
   	DFREF DFR_panel=$DF_panel
   	Variable /G gv_killflag=0
   	Variable/G V_FitOptions=4	
   
   	Variable /G gv_dimflag=1
   	
   	Make /n=0 /o/t FitWavename_list
    	Make /n=0 /o/t FitWavePath_list
    	Make /n=0 /o/t FitWavePathX_list
    	Make /n=0 /o/B fitWaveName_list_sel
   	
   	newDatafolder /o Raw_Data
   	
   	/////////correlation//////////
       newDatafolder /o /s Correlation
       
  	Variable /G gv_CorQ0=0
   	Variable /G gv_CorQ1=1
   	Variable /G gv_CordQ=0.1
   	Variable /G gv_CorKBZ=0
   	Variable /G gv_CorKBZx=0
   	Variable /G gv_CorKBZy=0
   	Variable /G gv_CorStep=1
   	Variable /G gv_CorAngle=0
   	Variable /G gv_Corthreshold=0
   	Variable /G gv_Cordimflag=0
   	Variable /G gv_pnumflag=0
   	
   	////SC gap////
   	
   	SetDatafolder dFR_panel
   	newDatafolder /o/s SC_Gap
   	
   	Make /o/n=6 w_FitSCGap_coef
	Variable /G gv_FitRange=0.05
	Variable /G gv_WeightRange
	Variable /G gv_WeightValue=1
	Variable /G gv_Gamma0
	Variable /G gv_Gamma1
	Variable /G gv_Gapsize
	Variable /G gv_Amp
	Variable /G gv_bkg
	Variable /G gv_GaussFWHM=0.005
	String /G gs_Holdstr="100001"
	String /G gs_FitWavePath
	String /G gs_GapsizeS="0.000meV"
	
	Variable /G gv_kxcenter=0
	Variable /G gv_kycenter=0
	Variable /G gv_kx_to_pi=1
	Variable /G gv_kz_to_pi=1
	Variable /G gV_ky_to_pi=1
	
	///Merge////
	SetDatafolder dFR_panel
	newDatafolder /o/s Merge
	Variable/G gv_autogridflag = 1
	Variable/G gv_linearflag = 1
	Variable/G gv_autoIntflag = 1
	Variable/G gv_ydirectionflag=0
	Variable /G gv_x0
	Variable /G gv_x1
	Variable /G gv_dx
	Variable /G gv_y0
	Variable /G gv_y1
	Variable /G gv_dy
	
    
   	Make /n=0 /o/t MergeWavename_list
    	Make /n=0 /o/t MergeWavePath_list
    	Make /n=0 /o/B MergeWaveName_list_sel
    
    	Make /n=4/o/T titlewave={"WaveName","x_offset","y_offset","z_facter"}
    	Make /n=(0,4) /o/t MergeList
    	Make /n=(0,4) /o/B MergeList_sel
	
   SetDatafolder DF
   return DFR_panel
End

Function close_anal_panel(ctrlname)
	String ctrlName
	String wname=winName(0,65)
	String DF_panel="root:internalUse:"+wname
		DFREF DFR_panel=$DF_panel
		NVAR killflag=DFR_panel:gv_killflag
		killflag=1
	dowindow/K $wname
End


Function Open_Analysis_Panel(ctrlName)
	String ctrlName
	
	DFREF DF = GetDataFolderDFR()
	
	Variable SC= Screensize(5)
	Variable SR = Igorsize(3) 
	Variable ST = Igorsize(2)
	Variable SL = Igorsize(1)
    	Variable SB = Igorsize(4)
    
    	
    	DFREF DFR_prefs=$DF_prefs
    	NVAR panelscale=DFR_prefs:gv_panelscale
    	NVAR macscale=DFR_prefs:gv_macscale

	Variable Width = 520*panelscale*Macscale		// panel size  
	Variable height = 500*panelscale*Macscale	

	Variable xOffset = (SR-SL)/2-width/2
	Variable yOffset = (SB-ST)/2-height/2
	
	String panelnamelist=winlist("Analysis_panel_*",";","WIN:65")
	
	if (stringmatch(ctrlname,"recreate_window")==0)
	
		if (strlen(panelnamelist)==0)
			string spwinname=UniqueName("Analysis_panel_", 9, 0)
			Display /W=(xOffset, yOffset,xOffset+width,Height+yOffset) as spwinname
			DoWindow/C $spwinname
   			Setwindow $spwinname hook(MyHook) = MypanelHook
		else
			if (stringmatch(ctrlname,"global_duplicate_panel"))
				spwinname=UniqueName("Analysis_panel_", 9, 0)
				Display /W=(xOffset, yOffset,xOffset+width,Height+yOffset) as spwinname
				DoWindow/C $spwinname
   				Setwindow $spwinname hook(MyHook) = MypanelHook
			else
				BringUP_Allthepanel(panelnamelist,0)
				SetDataFolder DF 
				return 1
			endif
		endif
		DFREF DFR_panel=init_anal_panel()
		DFREF DFR_common=init_graph_panelcommon()
	else
		BringUP_thefirstpanel(panelnamelist)
		DFREF DFR_panel=$("root:internalUse:"+winname(0,65))
		DFREF DFR_common=$("root:internalUse:"+winname(0,65)+":panel_common")
		SetActiveSubwindow $winname(0,65)
	endif	
	
	ControlBar 210*SC
	
	Variable r=57000, g=57000, b=57000
	ModifyGraph cbRGB=(52428,52428,52428)
	ModifyGraph wbRGB=(51456,44032,58880), gbRGB=(51456,44032,58880)
	
	SetDataFolder DFR_panel
	String panelcommonPath=GetDatafolder(1,DFR_common)
	String DF_panel=GetDatafolder(1,DFR_panel)
	DFREF DFR_cor=$(DF_panel+"Correlation")
	DFREF DFR_SC=$(DF_panel+"SC_gap")
	DFREF DFR_merge=$(DF_panel+"Merge")
	
	
	Button global_close_panel, pos={530*SC,4*SC},size={60*SC,18*SC},title="close", proc=close_Anal_panel
	Button global_duplicate_panel, pos={590*SC,4*SC},size={80*SC,18*SC},title="duplicate", proc=Open_Analysis_Panel
	
	//CheckBox global_ck1, pos={20*SC,200*SC}, title="lock DCs scale", proc=lock_intensity
	//CheckBox global_ck5, pos={125*SC,200*SC}, title="lock Image scale", proc=lock_intensity
	//CheckBox global_ck2, pos={250*SC,200*SC}, title="collapse E", proc=collapse_proc
	//CheckBox global_ck3, pos={330*SC,200*SC}, title="collapse k", proc=collapse_proc
	//CheckBox global_ck4, pos={420*SC,200*SC}, title="between cursors", proc=collapse_proc
	
	Button global_gold, size={40*SC,20*SC},pos={645*SC,25*SC}, title="gold", proc=open_gold_panel
	Button global_main, size={40*SC,20*SC},pos={645*SC,55*SC}, title="main", proc= Open_main_Panel
	Button global_map, size={40*SC,20*SC},pos={645*SC,85*SC}, title="map", proc= open_mapper_panel
	Button global_BZ, size={40*SC,20*SC},pos={645*SC,115*SC}, title="BZ", proc=open_bz_panel
	Button global_Fit, size={40*SC,20*SC},pos={645*SC,145*SC}, title="Fit", proc=open_fit_panel
    	Button global_opdt,labelBack=(r,g,b),pos={645*SC,175*SC},size={40*SC,20*SC},title="DataT",proc=open_data_table
	
	
    	TabControl main,proc=Anal_AutoTab_proc, pos={8*SC,6*SC},size={630*SC,190*SC},value=0,labelBack=(r,g,b)
    
    	TabControl main,tabLabel(0)="source"//selwave=DFR_common:w_DFListsel,
    
    	listbox source_waves_list, pos={16*SC,45*SC}, size={200*SC,140*SC},  widths={300},listwave=DFR_common:w_sourceNames, selwave=DFR_common:w_sourceNamesSel, frame=2,mode=9, proc=Graph_Listbox_proc
	//listbox source_prolist, pos={133,45}, size={90,110}, listwave=DFR_common:w_proclist,selwave=DFR_common:w_proclistsel, frame=2,mode=5,proc=proc_Listbox_proc
	Titlebox source_tb1,title="Image",pos={20*SC,30*SC},labelBack=(r,g,b),frame=0,variable=DFR_common:gs_currentDF
	checkbox source_ck1,title="Image",pos={380*SC,28*SC},size={60*SC,20*SC},labelBack=(r,g,b),value=0,frame=0,proc=proc_ck_dimsel
	checkbox source_ck0,title="Trace",pos={320*SC,28*SC},size={60*SC,20*SC},labelBack=(r,g,b),value=1,frame=0,proc=proc_ck_dimsel
	checkbox source_ck2,title="Sort",pos={445*SC,28*SC},size={60*SC,20*SC},labelBack=(r,g,b),variable=DFR_common:gv_sortopt,frame=0,proc=proc_ck_sortopt
	
	//selwave=DFR_common:w_DFListsel,
	GroupBox source_gb0, frame=0,labelBack=(r,g,b), pos={220*SC,35*SC}, size={285*SC,132*SC}, title="source graph"
	listbox source_lb1, pos={230*SC,70*SC}, size={250*SC,90*SC},  widths={400},listwave=DFR_common:w_DF, selrow=0, frame=2,mode=6, proc=graph_Listbox_proc
    	SetVariable source_sv0,labelBack=(r,g,b), pos={230*SC,50*SC},size={110*SC,20*SC}, title="search",frame=1,value=DFR_common:gs_matchstring,proc=graph_list_search_proc
    	Button source_bt0,labelBack=(r,g,b),pos={340*SC,48*SC},size={35*SC,20*SC},title="All",proc=Default_graph_proc
    	Button source_bt1,labelBack=(r,g,b),pos={380*SC,48*SC},size={35*SC,20*SC},title="EDC",proc=Default_graph_proc
    	Button source_bt2,labelBack=(r,g,b),pos={420*SC,48*SC},size={35*SC,20*SC},title="MDC",proc=Default_graph_proc
    	Button source_bt3,labelBack=(r,g,b),pos={460*SC,48*SC},size={35*SC,20*SC},title="IMG",proc=Default_graph_proc
   
  
  	Titlebox source_tb3,title="selected wave",pos={530*SC,30*SC},labelBack=(r,g,b),frame=0//,variable=DFR_common:gs_currentDF
  	Listbox source_lb0, widths={300},listwave=DFR_panel:FitWavename_list,selwave=DFR_panel:fitWaveName_list_sel,size={120*SC,120*SC},pos={510*SC,45*SC}, frame=2,editstyle=0,mode=9
  	Listbox source_lb0,proc=Graphsel_Listbox_proc
	 
	Button source_b2,pos={280*SC,170*SC},size={45*SC,20*SC},title="All--> ", proc=AddmainpanelSel
	Button source_b3,pos={230*SC,170*SC},size={45*SC,20*SC},title="Sel-->", proc=AddmainpanelSel
	Button source_b6,pos={330*SC,170*SC},size={45*SC,20*SC},title="Sel<--", proc=AddmainpanelSel
	
	Button source_b4,pos={585*SC,170*SC},size={45*SC,20*SC},title="<--Sel", proc=RemoveListSel
	Button source_b5,pos={510*SC,170*SC},size={70*SC,20*SC},title="Clear all", proc=RemoveListSel
	
	//Groupbox select_gb0, size={150,60},pos={300,33},title="select from browser",disable=1
	Button source_b7,pos={380*SC,170*SC},size={60*SC,20*SC},title="Browser", proc=AddbrowserSel
	Button source_b9,pos={455*SC,170*SC},size={40*SC,20*SC},title="Graph", proc=BringFrontGraph
  
  
  
	
	TabControl main,tabLabel(1)="Correlation"
	Groupbox Correlation_gb0,frame=0,pos={230*SC,35*SC},size={170*SC,80*SC},title="1D Correlation",disable=1
	Checkbox Correlation_ck0,pos={340*SC,35*SC},size={150*SC,120*SC},title="",value=1,disable=1,proc=proc_ck_CorrelationCK
	SetVariable Correlation_sv3,pos={240*SC,55*SC},size={150*SC,18*SC},title="Kx_BZ(pi/a)",limits={-inf,inf,0},variable=DFR_cor:gv_CorKBZ,labelBack=(r,g,b),disable=1
	//SetVariable Correlation_sv2,pos={330,75},size={100,18},title="Kend",limits={-inf,inf,0},variable=CorKend,labelBack=(r,g,b),disable=1
	
	
	Checkbox Correlation_ck1,pos={240*SC,75*SC},size={50*SC,120*SC},title="DCs:",value=1,disable=1,proc=proc_ck_CorrelationDCCK
	SetVariable Correlation_sv1,pos={290*SC,74*SC},size={80*SC,18*SC},title="Step",limits={1,inf,1},variable=DFR_cor:gv_CorStep,labelBack=(r,g,b),disable=1
	
	Checkbox Correlation_ck2,pos={240*SC,95*SC},size={50*SC,120*SC},title="FSM:",value=0,disable=1,proc=proc_ck_CorrelationDCCK
	SetVariable Correlation_sv7,pos={290*SC,94*SC},size={80*SC,18*SC},title="Angle:",limits={-inf,inf,0},variable=DFR_cor:gv_CorAngle,labelBack=(r,g,b),disable=1,proc=proc_sv_CorAngle
	

	Button Correlation_bt1,pos={420*SC,120*SC},size={140*SC,20*SC},title="Circular Correlation",proc=Circular_Correlation,disable=1
	
	SetVariable Correlation_sv4,pos={420*SC,145*SC},size={60*SC,18*SC},title="Q0",limits={-inf,inf,0},variable=DFR_cor:gv_CorQ0,labelBack=(r,g,b),disable=1
	SetVariable Correlation_sv5,pos={490*SC,145*SC},size={60*SC,18*SC},title="Q1",limits={-inf,inf,0},variable=DFR_cor:gv_CorQ1,labelBack=(r,g,b),disable=1
	SetVariable Correlation_sv6,pos={570*SC,145*SC},size={60*SC,18*SC},title="dQ",limits={-inf,inf,0},variable=DFR_cor:gv_CordQ,labelBack=(r,g,b),disable=1
	Button Correlation_bt2,pos={420*SC,165*SC},size={120*SC,20*SC},title="Correlation",proc=Correlation,disable=1
	CheckBox Correlation_ck3,pos={550*SC,168*SC},labelBack=(r,g,b),size={60*SC,18*SC},title="Point Norm",disable=1,variable=DFR_cor:gv_pnumflag
	//Button Correlation_bt3,pos={410,165},size={60,18},title="NewCor",proc=NewCor1D,disable=1
	//CheckBox Correlation_ck2,pos={220,165},labelBack=(r,g,b),size={60,18},title="1Norm",disable=1
	
	Groupbox Correlation_gb1,frame=0,pos={230*SC,120*SC},size={170*SC,65*SC},title="2D Correlation",disable=1
	Checkbox Correlation_ck4,pos={340*SC,120*SC},size={150*SC,120*SC},title="",value=0,disable=1,proc=proc_ck_CorrelationCK
	
	SetVariable Correlation_sv8,pos={240*SC,140*SC},size={130*SC,18*SC},title="Kx_BZ(pi/a)",limits={-inf,inf,0},variable=DFR_cor:gv_CorKBZx,labelBack=(r,g,b),disable=1
	SetVariable Correlation_sv9,pos={240*SC,160*SC},size={130*SC,18*SC},title="Ky_BZ(pi/a)",limits={-inf,inf,0},variable=DFR_cor:gv_CorKBZy,labelBack=(r,g,b),disable=1
	
	SetVariable Correlation_sv10,pos={420*SC,30*SC},size={130*SC,19*SC},title="threshold:",limits={0,inf,0},variable=DFR_cor:gv_Corthreshold,labelBack=(r,g,b),disable=1,proc=proc_sv_Corthreshold
	Button Correlation_bt3,pos={560*SC,30*SC},size={60*SC,18*SC},title="Disp th",labelBack=(r,g,b),disable=1,proc=Proc_bt_Corthreshold_disp
	//SetVariable Correlation_sv1,pos={240,55},size={130,18},title="Integrate Step",limits={0,inf,0},variable=CorKstart,labelBack=(r,g,b),disable=1
	//SetVariable Correlation_sv11,pos={330,75},size={100,18},title="Angle",limits={-inf,inf,0},variable=CorKend,labelBack=(r,g,b),disable=1
	//SetVariable Correlation_sv8,pos={400,105},size={60,18},title="Q0",limits={-inf,inf,0},variable=CorQ0,labelBack=(r,g,b),disable=1
	//SetVariable Correlation_sv9,pos={470,105},size={60,18},title="Q1",limits={-inf,inf,0},variable=CorQ1,labelBack=(r,g,b),disable=1
	//SetVariable Correlation_sv10,pos={240,130},size={100,18},title="dQ",limits={-inf,inf,0},variable=CordQ,labelBack=(r,g,b),disable=1
	//CheckBox Correlation_ck1,pos={510,168},labelBack=(r,g,b),size={60,18},title="Point Norm",disable=1
	//Button Correlation_bt1,pos={230,165},size={140,20},title="Circular Correlation",proc=Correlation1D,disable=1
	//Button Correlation_bt2,pos={380,165},size={120,20},title="Correlation",proc=NCorrelation1D,disable=1
	//TabControl DC_Display,tabLabel(4)="MirrorEDC"
	//SetVariable Mir_sv1,pos={200,55},size={90,18},title="EF=",limits={-inf,inf,0},Variable=MirrorEF,labelBack=(r,g,b),disable=1
	
	
	TabControl main,tabLabel(2)="SCGap"
	Button SCGap_bt4,pos={225*SC,45*SC},size={50*SC,18*SC},title="Cal K",proc=Analpanel#CalDCmomentum,disable=1
	Button SCGap_bt5,pos={280*SC,45*SC},size={70*SC,18*SC},title="Edit Table",proc=Analpanel#NewGapTable,disable=1
	SetVariable SCGap_sv9,pos={225*SC,65*SC},size={125*SC,15*SC},title="kx_center:",limits={-inf,inf,0},Value=DFR_SC:gv_kxcenter,disable=1
	SetVariable SCGap_sv10,pos={225*SC,83*SC},size={125*SC,15*SC},title="ky_center:",limits={-inf,inf,0},Value=DFR_SC:gv_kycenter,disable=1
	SetVariable SCGap_sv11,pos={225*SC,100*SC},size={60*SC,15*SC},title="kx_pi:",limits={0,inf,0},Value=DFR_SC:gv_kx_to_pi,disable=1
	SetVariable SCGap_sv12,pos={290*SC,100*SC},size={60*SC,15*SC},title="ky_pi:",limits={0,inf,0},Value=DFR_SC:gv_ky_to_pi,disable=1
	SetVariable SCGap_sv13,pos={225*SC,118*SC},size={125*SC,15*SC},title="kz_pi:",limits={0,inf,0},Value=DFR_SC:gv_kz_to_pi,disable=1
	
		
	Button SCGap_bt9,pos={225*SC,175*SC},size={50*SC,18*SC},title="kxkz",proc=Analpanel#dispDCmomentum,disable=1
	Button SCGap_bt10,pos={290*SC,175*SC},size={50*SC,18*SC},title="kykz",proc=Analpanel#dispDCmomentum,disable=1
	Button SCGap_bt11,pos={225*SC,160*SC},size={50*SC,18*SC},title="kxky",proc=Analpanel#dispDCmomentum,disable=1
	Checkbox SCGap_ck12,pos={290*SC,158*SC},size={50*SC,18*SC},title="Color",disable=1
//	Button SCGap_bt6,pos={225*SC,105*SC},size={90*SC,20*SC},title="disp Gap Table",proc=dispGapTable,disable=1
	
	
	Button SCGap_bt12,pos={225*SC,140*SC},size={50*SC,18*SC},title="Polar",proc=Analpanel#Polarplot_gapsize,disable=1
	Button SCGap_bt13,pos={290*SC,140*SC},size={50*SC,18*SC},title="gapkxky",proc=Analpanel#kxkyplot_gapsize,disable=1
	
	
	
	
	groupbox SCGap_gb0,pos={360*SC,35*SC},size={140*SC,150*SC},title="Fit Coef",disable=1
	SetVariable SCGap_sv0,pos={370*SC,60*SC},size={100*SC,18*SC},title="G0(eV)=",limits={-inf,inf,0},Value=DFR_SC:gv_Gamma0,proc=Analpanel#FitSym_CoefChange,disable=1
	SetVariable SCGap_sv1,pos={370*SC,80*SC},size={100*SC,18*SC},title="G1(eV)=",limits={-inf,inf,0},Value=DFR_SC:gv_Gamma1,proc=Analpanel#FitSym_CoefChange,disable=1
	SetVariable SCGap_sv2,pos={370*SC,100*SC},size={100*SC,18*SC},title="Gap(eV)=",limits={-inf,inf,0},Value=DFR_SC:gv_Gapsize,proc=Analpanel#FitSym_CoefChange,disable=1
	SetVariable SCGap_sv3,pos={370*SC,120*SC},size={100*SC,18*SC},title="Amp=",limits={-inf,inf,0},Value=DFR_SC:gv_Amp,proc=Analpanel#FitSym_CoefChange,disable=1
	SetVariable SCGap_sv4,pos={370*SC,140*SC},size={100*SC,18*SC},title="Bkg=",limits={-inf,inf,0},Value=DFR_SC:gv_bkg,proc=Analpanel#FitSym_CoefChange,disable=1
	SetVariable SCGap_sv5,pos={370*SC,160*SC},size={100*SC,18*SC},title="Gauss(eV)=",limits={-inf,inf,0},Value=DFR_SC:gv_GaussFWHM,proc=Analpanel#FitSym_CoefChange,disable=1
	Button SCGap_bt0,pos={510*SC,125*SC},size={50*SC,20*SC},title="Initial",proc=Analpanel#GuessFitSym_Coef,disable=1
	Button SCGap_bt1,pos={570*SC,125*SC},size={50*SC,20*SC},title="Guess",proc=Analpanel#GuessFitSym_Coef,disable=1
	Checkbox SCGap_ck0,pos={475*SC,60*SC},size={30*SC,18*SC},title="",value=1,proc=Analpanel#FitSym_HdstrChange,disable=1
	Checkbox SCGap_ck1,pos={475*SC,80*SC},size={30*SC,18*SC},title="",proc=Analpanel#FitSym_HdstrChange,disable=1
	Checkbox SCGap_ck2,pos={475*SC,100*SC},size={30*SC,18*SC},title="",proc=Analpanel#FitSym_HdstrChange,disable=1
	Checkbox SCGap_ck3,pos={475*SC,120*SC},size={30*SC,18*SC},title="",proc=Analpanel#FitSym_HdstrChange,disable=1
	Checkbox SCGap_ck4,pos={475*SC,140*SC},size={30*SC,18*SC},title="",proc=Analpanel#FitSym_HdstrChange,disable=1
	Checkbox SCGap_ck5,pos={475*SC,160*SC},size={30*SC,18*SC},title="",value=1,proc=Analpanel#FitSym_HdstrChange,disable=1

	groupbox SCGap_gb1,pos={505*SC,35*SC},size={130*SC,85*SC},title="Fit Setting",disable=1
	SetVariable SCGap_sv6,pos={515*SC,60*SC},size={105*SC,18*SC},title="FRange=",limits={0,inf,0},Value=DFR_SC:gv_FitRange,disable=1
	SetVariable SCGap_sv7,pos={515*SC,80*SC},size={105*SC,18*SC},title="WRange=",limits={0,inf,0},Value=DFR_SC:gv_WeightRange,disable=1
	SetVariable SCGap_sv8,pos={515*SC,100*SC},size={105*SC,18*SC},title="WValue=",limits={0,inf,0},Value=DFR_SC:gv_WeightValue,disable=1
	//titlebox SCGap_tb0,pos={480,120},size={140,40},fsize=27,font="Arial",fstyle=1,variable=GapsizeS
	Button SCGap_bt2,pos={510*SC,145*SC},size={50*SC,20*SC},title="Fit",proc=Analpanel#FitSymEDC,disable=1
	
	
	
	TabControl main, tabLabel(3)="Merge"
	titlebox merge_tb0,pos={24*SC,30*SC},size={90*SC,20*SC},title="Merge list:",disable=1,frame=0
	Listbox merge_lb0,listwave=DFR_merge:Mergelist, selwave=DFR_merge:Mergelist_Sel,titleWave=DFR_merge:titlewave,size={462*SC,95*SC},pos={24*SC,45*SC}, frame=2, disable = 1,editstyle=0,mode=1, widths={240,60,60,60}
	Listbox merge_lb0,proc=mergepanel#Listbox_merge_update_Proc
	Groupbox merge_gb10, frame=0,size={125*SC,155*SC},pos={495*SC,35*SC},title="auto grid", disable = 1
	CheckBox merge_c10, pos={510*SC,55*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="auto grid", variable = DFR_merge:gv_autogridflag, disable = 1
	//Groupbox merge_gb11, size={500,111},pos={284,74},title="Grid settings"
	SetVariable merge_sv10, pos={510*SC,75*SC}, size={85*SC,15*SC},labelBack=(r,g,b),title="x0:", value = DFR_merge:gv_x0, limits={-Inf,Inf,0}, disable = 1
	SetVariable merge_sv11, pos={510*SC,92*SC}, size={85*SC,15*SC},labelBack=(r,g,b),title="x1:", value = DFR_merge:gv_x1, limits={-Inf,Inf,0}, disable = 1
	SetVariable merge_sv12, pos={510*SC,135*SC}, size={85*SC,15*SC},labelBack=(r,g,b),title="y0:", value = DFR_merge:gv_y0, limits={-Inf,Inf,0}, disable = 1
	SetVariable merge_sv13, pos={510*SC,152*SC}, size={85*SC,15*SC},labelBack=(r,g,b),title="y1:", value = DFR_merge:gv_y1, limits={-Inf,Inf,0}, disable = 1
	SetVariable merge_sv14, pos={510*SC,109*SC}, size={85*SC,15*SC},labelBack=(r,g,b),title="dx:", value = DFR_merge:gv_dx, limits={0,Inf,0}, disable = 1
	SetVariable merge_sv15, pos={510*SC,169*SC}, size={85*SC,15*SC},labelBack=(r,g,b),title="dy:", value = DFR_merge:gv_dy, limits={0,Inf,0}, disable = 1
	
	CheckBox merge_c0, pos={29*SC,148*SC}, size={80*SC,20*SC},labelBack=(r,g,b),title="Auto intensities",  Variable=DFR_merge:gv_autoIntflag, disable=1
	CheckBox merge_c1, pos={29*SC,170*SC}, size={80*SC,20*SC},labelBack=(r,g,b),title="use linear combination", Variable=DFR_merge:gv_linearflag, disable=1
	CheckBox merge_c2, pos={195*SC,148*SC}, size={80*SC,20*SC},labelBack=(r,g,b),title="Y direction", Variable=DFR_merge:gv_ydirectionflag, disable=1//, proc=c_proc_old_style, disable=1
	
	Button Merge_bt0,pos={289*SC,165*SC}, size={80*SC,20*SC},labelBack=(r,g,b),title="Merge",  proc=mergePanel#update_merge_wave, disable=1
	
	Button Merge_btq,pos={379*SC,165*SC}, size={80*SC,20*SC},labelBack=(r,g,b),title="Plot",  proc=mergePanel#plot_merge_wave, disable=1
	
	
	Graph_Listbox_Proc("source_lb1", 0, 0, 4)
	
	SetDataFolder DF
End


/////////////////////////Add selected Curves Fn////////////////////////////////////






Function Analysis_panel_SLB_proc() //remove

	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	SetDataFolder $DF_panel
	DFREF DFR_common= $(DF_panel+":panel_common")
	SetActivesubwindow $winname(0,65)
	
			
	 	wave w_image=DFR_common:w_image
		Variable d_limit
		Controlinfo /W=$winname(0,65) DCs_c0
		if (v_value)
			d_limit = dimsize(w_image,0)-1
		else
			d_limit = dimsize(w_image,1)-1
		endif
		SetVariable DCs_sv0, win=$winname(0,65),limits={0,d_limit,1}
		SetVariable DCs_sv1, win=$winname(0,65),limits={0,d_limit,1}
	
		
	SetDatafolder DF

End

Function Proc_bt_Corthreshold_disp(ctrlname)
	String ctrlName
	DFREF DF=GetDatafolderDFR
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_cor=$(DF_panel+":Correlation")
	DFREF DFR_SC=$(DF_panel+":SC_gap")
	SetActiveSubwindow $winname(0,65)
	
	NVAR gv_dimflag=DFR_panel:gv_dimflag
	String wname=winname(0,65)
	
	if (gv_dimflag==1)
		WAVE /Z w_trace_disp = DFR_panel:w_trace_disp
		if (Waveexists(w_trace_disp)==0)
			SetDatafolder DF
			return 0
		endif
	
		checkdisplayed /W=$wname w_trace_disp
		if (V_flag==0)
			appendtograph /W=$wname w_trace_disp
			Modifygraph  /W=$wname rgb(w_trace_disp)=(0,0,0) 
		else
			removefromgraph /Z /W=$wname w_trace_disp
		endif
	else
	
		WAVE /Z w_image_disp = DFR_panel:w_image_disp
	
		if (Waveexists(w_image_disp)==0)
			SetDatafolder DF
			return 0
		endif
	
	
		checkdisplayed /W=$wname w_image_disp
	
		if (V_flag==0)
			appendimage /W=$wname  w_image_disp ///L=image_en /B=image_m
			ModifyImage  /W=$wname w_image_disp ctab= {0,0,Grays,0}
			ModifyImage  /W=$wname w_image_disp maxRGB=(65525,0,0)
		else
			removeimage /Z /W=$wname w_image_disp
		endif
	
	endif
End

Function proc_sv_Corthreshold(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	DFREF DF=GetDatafolderDFR
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_cor=$(DF_panel+":Correlation")
	DFREF DFR_SC=$(DF_panel+":SC_gap")
	SetActiveSubwindow $winname(0,65)
	SetDatafolder DFR_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	
	NVAR gv_dimflag=DFR_panel:gv_dimflag
	NVAR gv_Corthreshold=DFR_cor:gv_Corthreshold
	
	if (gv_dimflag==1)
		WAVE w_trace = DFR_common:w_trace
		duplicate /o w_trace,w_trace_disp
		w_trace_disp=(w_trace_disp>gv_Corthreshold)?(w_trace_disp):(Nan)
		
	else		
		WAVE w_image = DFR_common:w_image
		duplicate /o w_image,w_image_disp
		w_image_disp=(w_image_disp>gv_Corthreshold)?(Nan):(1)
	endif
		
	SetDatafolder DF
End


Function proc_sv_CorAngle(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	DFREF DF=GetDatafolderDFR
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_cor=$(DF_panel+":Correlation")
	DFREF DFR_SC=$(DF_panel+":SC_gap")
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	WAVE w_image = DFR_common:w_image
	NVAR gv_CorAngle=DFR_cor:gv_CorAngle
	
	ImageRotate /A=(gv_CorAngle) /Q/O/S w_image
	
	DeleteNanEdgeFSM(w_image)
	
End


Function proc_ck_CorrelationDCCK(ctrlname,value)
	String ctrlname
	Variable value
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_cor=$(DF_panel+":Correlation")
	DFREF DFR_SC=$(DF_panel+":SC_gap")
	SetActiveSubwindow $winname(0,65)
	
	NVAR gv_Cordimflag=DFR_cor:gv_Cordimflag
	
	Variable ckvalue
	strswitch(ctrlname)
	case "Correlation_ck1":
		ckvalue=1
		gv_Cordimflag=0
	break
	case "Correlation_ck2":
		ckvalue=2
		gv_Cordimflag=1
	break
	endswitch
	
	checkbox Correlation_ck1, value=ckvalue==1
	checkbox Correlation_ck2, value=ckvalue==2
End	
	
Function proc_ck_CorrelationCK(ctrlname,value)
	String ctrlname
	Variable value
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_cor=$(DF_panel+":Correlation")
	DFREF DFR_SC=$(DF_panel+":SC_gap")
	
	SetActiveSubwindow $winname(0,65)
	
	NVAR gv_Cordimflag=DFR_cor:gv_Cordimflag
	
	Variable ckvalue
	strswitch(ctrlname)
	case "Correlation_ck0":
		ckvalue=1
		controlinfo Correlation_ck2
		gv_Cordimflag=v_value
	break
	case "Correlation_ck4":
		ckvalue=2
		gv_Cordimflag=2
	break
	endswitch
	
	checkbox Correlation_ck0, value=ckvalue==1
	checkbox Correlation_ck4, value=ckvalue==2
	
	if (ckvalue==2)
			Groupbox Correlation_gb1,disable=0
				
			SetVariable Correlation_sv8,disable=0
			SetVariable Correlation_sv9,disable=0
			
			Groupbox Correlation_gb0,disable=2
			SetVariable Correlation_sv3,disable=2
				
			Checkbox Correlation_ck1,disable=2
			SetVariable Correlation_sv1,disable=2
	
			Checkbox Correlation_ck2,disable=2
			SetVariable Correlation_sv7,disable=2
	else
			Groupbox Correlation_gb0,disable=0
			SetVariable Correlation_sv3,disable=0
				
			Checkbox Correlation_ck1,disable=0
			SetVariable Correlation_sv1,disable=0
	
			Checkbox Correlation_ck2,disable=0
			SetVariable Correlation_sv7,disable=0
			
			Groupbox Correlation_gb1,disable=0
				
			SetVariable Correlation_sv8,disable=2
			SetVariable Correlation_sv9,disable=2
	
	endif
End

Function Anal_AutoTab_proc( name, tab )
	String name
	Variable tab
	
	DFREF DF = GetDataFolderDFR()
	String graphname=winname(0,65)
	SetActiveSubwindow $winname(0,65)
	
	ControlInfo /W=$graphname $name
	
	String tabStr = S_Value
	String curTabMatch= tabstr+"_*"
	String name_panel=winname(0,65)
			
	String controlsInATab= ControlNameList(name_panel,";","*_*")
	String controlsInCurTab= ListMatch(controlsInATab, curTabMatch)
	String controlsglobalcontrols=ListMatch(controlsInATab, "*global*")
	String controlsInOtherTabs= ListMatch(controlsInATab, "!"+curTabMatch)

	ModifyControlList  controlsInOtherTabs win=$graphname,disable=1	// hide
	ModifyControlList  controlsInCurTab win=$graphname,disable=0		// show
	ModifyControlList  controlsglobalcontrols win=$graphname,disable=0	// show
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetDataFolder DFR_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	
		
	NVAR first =DFR_panel:gv_first
	NVAR last = DFR_panel:gv_last
	NVAR step = DFR_panel:gv_step
	NVAR Dcnum=DFR_panel:gv_Dcnum
	WAVE M = DFR_common:w_image
	
	//listbox source_waves_list,disable=0
	Variable SC= Screensize(5)
	if (stringmatch(tabstr,"source")!=1)
		listbox source_lb0, pos={16*SC,45*SC}, size={200*SC,140*SC},disable=0
	else
		Listbox source_lb0,size={120*SC,120*SC},pos={510*SC,45*SC},disable=0
	endif
	
	if (stringmatch(tabstr,"Correlation")==1)
		removeFromgraph /Z FitWave
		controlinfo Correlation_ck0
		if (v_value==0)
			Groupbox Correlation_gb0,disable=2
			SetVariable Correlation_sv3,disable=2
				
			Checkbox Correlation_ck1,disable=2
			SetVariable Correlation_sv1,disable=2
	
			Checkbox Correlation_ck2,disable=2
			SetVariable Correlation_sv7,disable=2
		endif
		
		controlinfo Correlation_ck4
		if (v_value==0)
			Groupbox Correlation_gb1,disable=2
				
			SetVariable Correlation_sv8,disable=2
			SetVariable Correlation_sv9,disable=2
	
		endif
		
	endif
	
	if (stringmatch(tabstr,"source")==1)
		removeFromgraph /Z FitWave
	endif
	
	if (stringmatch(tabstr,"Merge")==1)
		listbox source_lb0,disable=1
		
		update_merge_selwave()
	else
		listbox source_lb0,disable=0
	endif
	SetDatafolder DF
	
End



////////////////////////SC Gap analysis///////////////////




Function FitGaussConvSymEDC(Data,W_coef,width,w_Weight,Hdstr)
	Wave Data
	Wave W_coef
	Variable width
	Wave W_Weight
	String HdStr
		
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common= $(DF_panel+":panel_common")
	SetActivesubwindow $winname(0,65)
	
	SetDAtafolder DFR_panel
	
	newDatafolder /o/s FitSymEDC
	 //Variable/G V_FitOptions=4	
	DFREF DFR_fit=GetDatafolderDFR()
	String Wname=nameofwave(Data)
	Variable x0,x1
	x0=-width
	x1=width

	IntConv(W_coef[5],20,deltax(Data),x0,x1)
	duplicate /o W_coef W_epsilon
	W_epsilon=1e-6
	FuncFit /n/q/H=Hdstr  FitFuncConvSymEDC W_coef Data(x0,x1) /W=w_Weight ///E=w_Epsilon
	Wave SymEDC=SymEDC
	make /o/n=((x2pnt(SymEDC,x1)-x2pnt(SymEDC,x0)+1)) FSymEDC
	Setscale /P x,pnt2x(SymEDC,x2pnt(SymEDC,x0)),deltax(SymEDC),FSymEDC
	FSymEDC=SymEDC(x)
	Duplicate /o Data OSymEDC

	removeFromgraph /Z FitWave
	Duplicate /o FSymEDC DFR_fit:FitWave
	appendtograph /C=(0,0,65280) DFR_fit:FitWave

	duplicate /o w_Coef CoefWave

	SetDatafolder DF
end


Function CalSymEDC(cof,x)
	Wave cof
	Variable x
	Variable SelfEim,SelfERe,Aw
	if (x==0)
	 	// if (cof[0]==0)
  		Aw=1/pi/cof[1]
	else
		SelfEIm=-cof[1]-cof[2]*cof[2]*cof[0]/(x*x+cof[0]*cof[0])
		SelfERe=cof[2]*cof[2]*x/(x*x+cof[0]*cof[0])
		Aw=1/pi*SelfEIm/((x-SelfERe)*(x-SelfERe)+SelfEIm*SelfEIm)
	endif
	return cof[3]*Aw+cof[4]
End


Function CalconvSymEDC(pw)
	Wave pw
	Wave SymEDC=SymEDC
	Wave Conv_Gauss=Conv_Gauss

	SymEDC=CalSymEDC(pw,x)
	duplicate /o SymEDC O_FSymEDC
	Conv_Gauss=exp(-x^2*4*ln(2)/pw[5]^2)

	Variable sumGauss=sum(Conv_Gauss,-inf,inf)
	Conv_Gauss/=sumGauss

	Convolve /A Conv_Gauss SymEDC
End

Function FitFuncConvSymEDC(pw,yw,xw):FitFunc
	Wave pw,yw,xw
   	CalconvSymEDC(pw)
  	Wave SymEDC=SymEDC
   	yw=symEDC(xw[p])
End


Function IntConv(fwhm,res,data_dx,x0,x1)
	Variable fwhm,res,data_dx,x0,x1
  
  	Variable gauss_from = 10 * fwhm
 	 Variable dx =  min(fwhm/res, abs(data_dx/2))		// needs to be smaller than the data-width!, not really sure...
 	 Variable y_xfrom = x0 - 4 * fwhm
  	Variable y_xto = x1 + 4 * fwhm
		
  	Variable gauss_pnts = round(gauss_from/dx) * 2 + 1
  	Variable y_pnts = round((y_xto-y_xfrom)/dx)
		
  	 Make/o/d/n=(gauss_pnts) Conv_gauss = 0
  	 Make/o/d/n=(y_pnts) SymEDC = 0
		
   	SetScale/P x y_xfrom+0.00001, dx, SymEDC
   	SetScale/P x -gauss_from, dx, Conv_Gauss
End



static Function FitSymEDC(CtrlName)
	String CtrlName
	
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common= $(DF_panel+":panel_common")
	DFREF DFR_SC= $(DF_panel+":SC_Gap")
	SetActivesubwindow $winname(0,65)
	
	Wave data=DFR_common:w_trace
	
	Wave w_Coef=DFR_SC:w_FitSCgap_coef
	
	NVAR Gamma0=DFR_SC:gv_Gamma0
	NVAR Gamma1=DFR_SC:gv_Gamma1
	NVAR Gapsize=DFR_SC:gv_Gapsize
	NVAR amp=DFR_SC:gv_amp
	NVAR bkg=DFR_SC:gv_bkg
	NVAR Gaussfwhm=DFR_SC:gv_Gaussfwhm
	
	NVAR Fitrange=DFR_SC:gv_FitRange
	
	NVAR Wei_Range=DFR_SC:gv_WeightRange
	NVAR Wei_Value=DFR_SC:gv_WeightValue
	
	SVAR HdStr=DFR_SC:gs_Holdstr
	
	SetDatafolder DFR_panel

	Make /o/n=(numpnts(Data)) w_weight
	w_weight=1
	Variable X1=x2pnt(Data,-Wei_Range)
	Variable X2=x2pnt(Data,Wei_Range)
	w_Weight[X1,X2]=wei_Value

	FitGaussConvSymEDC(Data,w_coef,FitRange,W_Weight,Hdstr)

	Gamma0=W_coef[0]
	Gamma1=W_coef[1]
	Gapsize=W_coef[2]
	Amp=W_coef[3]
	bkg=W_coef[4]
	Gaussfwhm=W_coef[5]
	//GapSS=num2str(Gapsize*1000)+"meV"
	//setdatafolder $(DF_panel+":Raw_Data:SCGaptable")
	//wave gapsize
	//wave gaperror
	SetDatafolder DF
End


static Function GuessFitSym_Coef(CtrlName)
	String CtrlName
	
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common= $(DF_panel+":panel_common")
	DFREF DFR_SC= $(DF_panel+":SC_Gap")
	SetActivesubwindow $winname(0,65)
	
	Wave data=DFR_common:w_trace
	
	checkdisplayed /W=$winname(0,65) data
	if (v_flag==0)
		SetDatafolder DF
		return 0
	endif
	
	Wave w_Coef=DFR_SC:w_FitSCgap_coef
	
	NVAR Gamma0=DFR_SC:gv_Gamma0
	NVAR Gamma1=DFR_SC:gv_Gamma1
	NVAR Gapsize=DFR_SC:gv_Gapsize
	NVAR amp=DFR_SC:gv_amp
	NVAR bkg=DFR_SC:gv_bkg
	NVAR Gaussfwhm=DFR_SC:gv_Gaussfwhm
	NVAR FitRange=DFR_SC:gv_FitRange
	
	if (stringmatch(ctrlname,"SCGap_bt1"))
		WaveStats /Q/Z /R=(-fitrange,fitrange) Data
		bkg=V_min
		Amp=V_min-V_max
		GaussFwhm=0.005
		Gamma0=0
		Gamma1=0.01
		Gapsize=abs(V_Maxloc)
	else
		Gamma0=0
		Gamma1=0
		Gapsize=0
		amp=0
		bkg=0
		GaussFwhm=0.005
	endif
	
	W_coef[0]=Gamma0
	W_coef[1]=Gamma1
	W_coef[2]=Gapsize
	W_coef[3]=Amp
	W_coef[4]=bkg
	W_coef[5]=Gaussfwhm
	
	//GapSS=num2str(Gapsize*1000)+"meV"
	SetDatafolder DF
	
	
End


static Function FitSym_HdstrChange(CtrlName,Value)
	String CtrlName
	Variable Value
	
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common= $(DF_panel+":panel_common")
	DFREF DFR_SC= $(DF_panel+":SC_Gap")
	SetActivesubwindow $winname(0,65)
	
	SVAR Hdstr=DFR_SC:gs_Holdstr
	Hdstr=""
	controlinfo SCGap_ck0
	HDstr[0]=num2str(v_value)
	controlinfo SCGap_ck1
	HDstr[1]=num2str(v_value)
	controlinfo SCGap_ck2
	HDstr[2]=num2str(v_value)
	controlinfo SCGap_ck3
	HDstr[3]=num2str(v_value)
	controlinfo SCGap_ck4
	HDstr[4]=num2str(v_value)
	controlinfo SCGap_ck5
	HDstr[5]=num2str(v_value)
End


static Function FitSym_CoefChange(CtrlName,varNum,varStr,varName)
	String CtrlName
	Variable varNum
	String varStr
	String varName
	
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common= $(DF_panel+":panel_common")
	DFREF DFR_SC= $(DF_panel+":SC_Gap")
	SetActivesubwindow $winname(0,65)
	
	
	NVAR Gamma0=DFR_SC:gv_Gamma0
	NVAR Gamma1=DFR_SC:gv_Gamma1
	NVAR Gapsize=DFR_SC:gv_Gapsize
	NVAR amp=DFR_SC:gv_amp
	NVAR bkg=DFR_SC:gv_bkg
	NVAR Gaussfwhm=DFR_SC:gv_Gaussfwhm
	Wave w_Coef=DFR_SC:w_FitSCGap_coef
	W_coef[0]=Gamma0
	W_coef[1]=Gamma1
	W_coef[2]=Gapsize
	W_coef[3]=Amp
	W_coef[4]=bkg
	W_coef[5]=Gaussfwhm

End
/////////////////////////////////////cal momentum////////////////////



static Function NewGapTable(ctrlname)
	String ctrlname
	
	
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF dFR_panel=$DF_panel
	DFREF DFR_common= $(DF_panel+":panel_common")
	DFREF DFR_SC=$(DF_panel+":SC_Gap")
	SetActivesubwindow $winname(0,65)
	
	SetDataFolder DFR_panel
	
	Variable index=0

	
	Wave w_sourceNamesSel=DFR_panel:FitWaveName_list_sel//DFR_common:w_sourceNamesSel
	Wave /T w_sourceNames=DFR_panel:FitWaveName_list//DFR_common:w_sourceNames
	Wave /T w_sourcePathes=DFR_panel:FitWavePath_list//DFR_common:w_sourcePathes
	
	NVAR gv_kxcenter=DFR_SC:gv_kxcenter
	NVAR gv_kycenter=DFR_SC:gv_kycenter
	
	NVAR gv_kx_to_pi=DFR_SC:gv_kx_to_pi
	NVAR gv_kz_to_pi=DFR_SC:gv_kz_to_pi
	
	do
		SetDataFolder DFR_panel
		
		Wave Point=$w_sourcePathes[index]
		String DCnote=note(Point)
		Variable kxtemp=numberbykey("kx",DCnote,"=","\r")
		Variable kytemp=numberbykey("ky",DCnote,"=","\r")
		Variable kztemp=numberbykey("kz",DCnote,"=","\r")
			
		DFREF DFR_save=$GetWavesDatafolder(point,1)
			
		SetDatafolder DFR_save
		newdatafolder /o/s SCGaptable
		Wave /Z kx
		if (waveexists(kx))
			Redimension /N=(numpnts(w_sourceNamesSel)) kx,ky,kz
		else
			make /o/n=(numpnts(w_sourceNamesSel))kx,ky,kz
		endif
		
		Wave kx,ky,kz
		
		kx[index]=kxtemp
		ky[index]=kytemp
		kz[index]=kztemp
		
		WAVE /T /Z Wavenamelist
		if (waveexists(Wavenamelist))
			Redimension /N=(numpnts(w_sourceNamesSel)) Wavenamelist
		else
			make /T /o/n=(numpnts(w_sourceNamesSel)) Wavenamelist
		endif
		wave /T Wavenamelist
		
		Wavenamelist[index]=w_sourceNames[p]
		
		WAVE /Z coskx
		if (waveexists(coskx))
			Redimension /N=(numpnts(w_sourceNamesSel)) coskx,cosky,coskz
		else
			make /o/n=(numpnts(w_sourceNamesSel)) coskx,cosky,coskz
		endif
		Wave coskx,cosky,coskz
		coskx[index]=cos(kx[index]/gv_kx_to_pi*pi)
		cosky[index]=cos(ky[index]/gv_kx_to_pi*pi)
		coskz[index]=cos(kz[index]/gv_kz_to_pi*pi)
		
		Wave /Z gapsize
		if (waveexists(gapsize))
			Redimension /N=(numpnts(w_sourceNamesSel)) gapsize,gaperror
		else
			make /o/n=(numpnts(w_sourceNamesSel)) gapsize,gaperror
		endif
		
		Wave /Z kxky_theta
		if (waveexists(kxky_theta))
			Redimension /N=(numpnts(w_sourceNamesSel))kxky_theta,kxky_kvac
		else
			make /o/n=(numpnts(w_sourceNamesSel))kxky_theta,kxky_kvac
		endif
		Wave kxky_theta,kxky_kvac
		
		kxtemp=kx[index]-gv_kxcenter
		kytemp=ky[index]-gv_kycenter
		
		kxky_kvac[index]=sqrt(kxtemp^2+kytemp^2)
		
		kxky_theta[index]=(kytemp>0)?(acos(kxtemp/kxky_kvac[index])):(-acos(kxtemp/kxky_kvac[index]))
		kxky_theta[index]=kxky_theta[index]/pi*180
						
		index+=1
	while (index<numpnts(w_sourceNamesSel))
	
	String Addwname=winname(0,65)[strsearch(winname(0,65),"panel",0)+5,inf]
	
	String Tablename="SCGap_table_"+Addwname
	
	if (strlen(winlist(Tablename,";","WIN:2 "))>0)
		Dowindow /Z /K $Tablename
	
	endif
	Edit /N=Tablename  Wavenamelist,gapsize, gaperror,coskx,cosky,coskz,kx,ky,kz,kxky_theta,kxky_kvac as Tablename

	
	SetDatafolder DF
End



static Function dispDCmomentum(ctrlname)
	String ctrlname


	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF dFR_panel=$DF_panel
	DFREF DFR_common= $(DF_panel+":panel_common")
	SetActivesubwindow $winname(0,65)
	
	SetDataFolder DFR_panel
	
	Variable index=0

	
	Wave w_sourceNamesSel=DFR_panel:FitWaveName_list_sel//DFR_common:w_sourceNamesSel
	Wave /T w_sourceNames=DFR_panel:FitWaveName_list//DFR_common:w_sourceNames
	Wave /T w_sourcePathes=DFR_panel:FitWavePath_list//DFR_common:w_sourcePathes
	

	do
		SetDataFolder DFR_panel
		
		Wave Point=$w_sourcePathes[index]
		String DCnote=note(Point)
		
		if ((w_sourceNamesSel[index]==1)||(w_sourceNamesSel[index]==8))
			
			Variable kxtemp=numberbykey("kx",DCnote,"=","\r")
			Variable kytemp=numberbykey("ky",DCnote,"=","\r")
			Variable kztemp=numberbykey("kz",DCnote,"=","\r")
	
		else
			kxtemp=Nan
			kytemp=Nan
			kztemp=Nan
		endif
			
				
		DFREF DFR_save=$GetWavesDatafolder(point,1)
			
		SetDatafolder DFR_save
		newdatafolder /o/s SCGaptable
		Wave /Z kx	
			
		if (waveexists(kx))
			Redimension /N=(numpnts(w_sourceNamesSel)) kx,ky,kz
		else
			make /o/n=(numpnts(w_sourceNamesSel))kx,ky,kz
		endif
		
		Wave kx,ky,kz
		
		kx[index]=kxtemp
		ky[index]=kytemp
		kz[index]=kztemp
						
		index+=1
	while (index<numpnts(w_sourceNamesSel))
	
	controlinfo SCgap_ck12
	if (v_value)
		SVAR gn=DFR_common:gs_currentDF
		index=0
		do
			SetDataFolder DFR_panel
			Wave Point=$w_sourcePathes[index]
			if ((w_sourceNamesSel[index]==1)||(w_sourceNamesSel[index]==8))
				string pointPlot=nameofwave(Point)
				if (stringmatch(ctrlname,"SCgap_bt9"))
					make /o/n=1 $(pointPlot+"_kz"),$(pointPlot+"_kx")
					Wave point_y=$(pointPlot+"_kz")
					Wave point_x=$(pointPlot+"_kx")
					point_y=kz[index]
					point_x=kx[index]
		
				elseif (stringmatch(ctrlname,"SCgap_bt10"))
					make /o/n=1 $(pointPlot+"_kz"),$(pointPlot+"_ky")
					Wave point_y=$(pointPlot+"_kz")
					Wave point_x=$(pointPlot+"_ky")
					point_y=kz[index]
					point_x=ky[index]
					
				else
					make /o/n=1 $(pointPlot+"_ky"),$(pointPlot+"_kx")
					Wave point_y=$(pointPlot+"_ky")
					Wave point_x=$(pointPlot+"_kx")
					point_y=ky[index]
					point_x=kx[index]
					
				endif
				
				display_XYwave(point_y,point_x,2,0)
				ModifyGraph /W=$winname(1,65) mode($nameofwave(point_y))=3,marker($nameofwave(point_y))=8
				
				String traceinfostr=TraceInfo(gn, pointPlot, 0 )
				Variable  tempp1=strsearch(traceinfostr, "rgb(x)=", 0)
				Variable  tempp2=strsearch(traceinfostr, ";", tempp1)
				traceinfostr=traceinfostr[tempp1,tempp2-1]
				traceinfostr=ReplaceString("(x)", traceinfostr, "("+nameofwave(point_y)+")")
				string cmd="ModifyGraph /W="+winname(1,65)+" "+traceinfostr
				execute /Q/Z cmd
			endif
			index+=1
		while (index<numpnts(w_sourceNamesSel))	
		
	else	
		if (stringmatch(ctrlname,"SCgap_bt9"))
			display_XYwave(kz,kx,2,0)
			ModifyGraph /W=$winname(1,65) mode(kz)=3,marker(kz)=8
		elseif (stringmatch(ctrlname,"SCgap_bt10"))
			display_XYwave(kz,ky,2,0)
			ModifyGraph /W=$winname(1,65) mode(kz)=3,marker(kz)=8
		else
			display_XYwave(ky,kx,2,0)
			ModifyGraph /W=$winname(1,65) mode(ky)=3,marker(ky)=8
		endif
	endif

	SetDatafolder DF

End


static Function CalDCmomentum(ctrlname)
	String ctrlname
	
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF dFR_panel=$DF_panel
	DFREF DFR_common= $(DF_panel+":panel_common")
	SetActivesubwindow $winname(0,65)
	
	SetDataFolder DFR_panel
	
	Variable index=0,kz_flag
	
	Wave w_sourceNamesSel=DFR_panel:FitWaveName_list_sel//DFR_common:w_sourceNamesSel
	Wave /T w_sourceNames=DFR_panel:FitWaveName_list//DFR_common:w_sourceNames
	Wave /T w_sourcePathes=DFR_panel:FitWavePath_list//DFR_common:w_sourcePathes
	
	do
	
		//if ((w_sourceNamesSel[index]==1)||(w_sourceNamesSel[index]==8))
			Wave Point=$w_sourcePathes[index]
			String DCnote=Cal_momentum_fromnotes(Point)
			if (strlen(DCnote)>0)
				note /K Point
				note Point,DCnote
			endif
		//endif
		
		index+=1
	while (index<numpnts(w_sourceNamesSel))

	SetDatafolder DF
End

Function /S Cal_momentum_fromnotes(data)
	Wave data
	String DCnote=note(data)
	
	ReadDetailWaveNote(data,Nan,1)
	Wave WaveVars
	
	Variable initialflag=WaveVars[10]
	//if (initialflag)
	Variable FermiEnergy=WaveVars[7]
	//else
	Variable kvac=0.5123*sqrt(FermiEnergy)	
	
	Variable innerE=WaveVars[8]
	Variable th=WaveVars[0]+WaveVars[1]
	Variable ph=WaveVars[2]+WaveVars[3]
	Variable azi=WaveVars[4]+WaveVars[5]
	Variable beta=numberbykey("Momentum",DCnote,"=","\r")
	Variable gamma=WaveVars[9]
	Variable curveflag=WaveVars[12]
	
	Killwaves /Z Wavevars,WaveinfoL
	
	innerE=(numtype(innerE)==2)?(0):(InnerE)
	
	if ((numtype(FermiEnergy)==2)||(numtype(th)==2)||(numtype(ph)==2)||(numtype(azi)==2)||(numtype(gamma)==2)||(numtype(beta)==2))
		doalert 0,"Wrong Parameters"
		SetDatafolder DF
		return ""
	endif
	Variable kxtemp=flip_to_k(kvac,innerE,th,ph,azi,beta,gamma,0,curveflag)
	Variable kytemp=flip_to_k(kvac,innerE,th,ph,azi,beta,gamma,1,curveflag)
	Variable kztemp=flip_to_k(kvac,innerE,th,ph,azi,beta,gamma,2,curveflag)
	
	DCnote=replacenumberbykey("kx",DCnote,kxtemp,"=","\r")
	DCnote=replacenumberbykey("ky",DCnote,kytemp,"=","\r")
	DCnote=replacenumberbykey("kz",DCnote,kztemp,"=","\r")
	
	return DCnote
End


///////////////////////////polar plot 


Static Function Polarplot_gapsize(ctrlname)
	string ctrlname
	
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF dFR_panel=$DF_panel
	DFREF DFR_common= $(DF_panel+":panel_common")
	SetActivesubwindow $winname(0,65)
	
	SetDataFolder DFR_panel
	
	Wave w_sourceNamesSel=DFR_panel:FitWaveName_list_sel//DFR_common:w_sourceNamesSel
	Wave /T w_sourceNames=DFR_panel:FitWaveName_list//DFR_common:w_sourceNames
	Wave /T w_sourcePathes=DFR_panel:FitWavePath_list//DFR_common:w_sourcePathes
	
	Wave point=$w_sourcepathes[0]
	DFREF DFR_save=$Getwavesdatafolder(point,1)
	
	SetDatafolder DFR_save
	DFREF DFR_table=$Getwavesdatafolder(point,1)+"SCGaptable"
	
	SetDAtafolder DFR_table
	
	Wave gapsize
	Wave gaperror
	Wave kxky_theta
	
	make /o/n=(numpnts(gapsize)) gapsize_polar_X,gapsize_polar_y
	make /o/n=(numpnts(gapsize)*3) gapsize_error_X,gapsize_error_y
	
	gapsize_polar_y=gapsize[p]*sin(kxky_theta[p]/180*pi)
	gapsize_polar_x=gapsize[p]*cos(kxky_theta[p]/180*pi)
	Variable index
	do
		gapsize_error_X[3*index]=(gapsize[index]-gaperror[index])*cos(kxky_theta[index]/180*pi)
		gapsize_error_Y[3*index]=(gapsize[index]-gaperror[index])*sin(kxky_theta[index]/180*pi)
		gapsize_error_X[3*index+1]=(gapsize[index]+gaperror[index])*cos(kxky_theta[index]/180*pi)
		gapsize_error_Y[3*index+1]=(gapsize[index]+gaperror[index])*sin(kxky_theta[index]/180*pi)
		gapsize_error_X[3*index+2]=nan
		gapsize_error_Y[3*index+2]=nan
		index+=1
	while (index<numpnts(Gapsize))
	
	
	
	controlinfo SCgap_ck12
	if (v_value)
		SVAR graphname=DFR_common:gs_currentDF
		index=0
		do
			SetDataFolder DFR_panel
			Wave Point=$w_sourcePathes[index]
			string pointPlot=nameofwave(Point)
			
			make /o/n=1 $(pointPlot+"_gapy"),$(pointPlot+"_gapx")
			Wave point_y=$(pointPlot+"_gapy")
			Wave point_x=$(pointPlot+"_gapx")
			point_y=gapsize_polar_y[index]
			point_x=gapsize_polar_x[index]
			
			if (index==0)
				display_XYwave(point_y,point_x,0,0)
				String gN=winname(0,65)
			else
				display_XYwave(point_y,point_x,1,0)
			endif
			
			ModifyGraph /W=$gn mode($nameofwave(point_y))=3,marker($nameofwave(point_y))=19
			
			String traceinfostr=TraceInfo(graphname, pointPlot, 0 )
			Variable  tempp1=strsearch(traceinfostr, "rgb(x)=", 0)
			Variable  tempp2=strsearch(traceinfostr, ";", tempp1)
			String rgbinfostr=traceinfostr[tempp1,tempp2-1]
			traceinfostr=ReplaceString("(x)", rgbinfostr, "("+nameofwave(point_y)+")")
			string cmd="ModifyGraph /W="+gn+" "+traceinfostr
			execute /Q/Z cmd
			
			Killwaves /Z point_y,point_x
			
			make /o/n=2 $(pointPlot+"_Ey"),$(pointPlot+"_Ex")
			Wave point_y=$(pointPlot+"_Ey")
			Wave point_x=$(pointPlot+"_Ex")
			point_y=gapsize_error_Y[3*index+p]
			point_x=gapsize_error_X[3*index+p]
			
			display_XYwave(point_y,point_x,1,0)
			
			
			ModifyGraph /W=$gn lstyle($nameofwave(point_y))=0
			traceinfostr=ReplaceString("(x)", rgbinfostr, "("+nameofwave(point_y)+")")
			
			cmd="ModifyGraph /W="+gn+" "+traceinfostr
			execute /Q/Z cmd
			
			
			Killwaves /Z point_y,point_x
				
			
			index+=1
		while (index<numpnts(w_sourceNamesSel))	
	else
	 	
		
		display_XYwave(gapsize_polar_y,gapsize_polar_x,0,0)
		gN=winname(0,65)
	
		display_XYwave(gapsize_error_Y,gapsize_error_X,1,0)
		
		
		ModifyGraph /W=$gn mode(gapsize_polar_y)=3,marker(gapsize_polar_y)=19,rgb(gapsize_polar_y)=(65535,0,0)
		ModifyGraph /W=$gn lstyle(gapsize_error_Y)=0,rgb(gapsize_error_Y)=(65535,0,0)
	endif
	
	
	Variable gapmax=wavemax(gapsize)*1.2
	
	ModifyGraph width={Plan,1,bottom,left}
	SetAxis bottom -gapmax,gapmax
	SetAxis left -gapmax,gapmax
		
	Wave data_gn=WaveRefIndexed(gN, 0, 1)
	if (WaveExists(data_gN)==0)
		Wave data_gn=ImageNameToWaveRef(gN,stringfromlist(0,ImageNameList(gN, ";")))
	endif
			
	String w_df=GetWavesDatafolder(data_gn,1)
	SetDatafolder $w_df
	
	Make /o/n=(100,100) plot_contour
	
	Setscale /I x,-gapmax,gapmax,plot_contour
	Setscale /I y,-gapmax,gapmax,plot_contour
	plot_contour=sqrt(x^2+y^2)

	AppendMatrixContour /W=$gn plot_contour
	ModifyContour /W=$gn plot_contour manLevels={0,round(gapmax/5*1000)/1000,7}
	ModifyContour /W=$gn plot_contour rgbLines=(0,0,0)


	SetDatafolder DF
End




Static Function kxkyplot_gapsize(ctrlname)
	string ctrlname
	
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF dFR_panel=$DF_panel
	DFREF DFR_common= $(DF_panel+":panel_common")
	SetActivesubwindow $winname(0,65)
	
	Variable gapsymmetry
	prompt gapsymmetry,"select gap symmetry",popup "|coskxcosky|;|coskx-cosky|/2;"
	
	DoPrompt "select gap symmetry",gapsymmetry
	if(V_flag==1)
		Setdatafolder DF
		return 1
	endif
	
	SetDataFolder DFR_panel
	
	Wave w_sourceNamesSel=DFR_panel:FitWaveName_list_sel//DFR_common:w_sourceNamesSel
	Wave /T w_sourceNames=DFR_panel:FitWaveName_list//DFR_common:w_sourceNames
	Wave /T w_sourcePathes=DFR_panel:FitWavePath_list//DFR_common:w_sourcePathes
	
	Wave point=$w_sourcepathes[0]
	DFREF DFR_save=$Getwavesdatafolder(point,1)
	
	SetDatafolder DFR_save
	DFREF DFR_table=$Getwavesdatafolder(point,1)+"SCGaptable"
	
	SetDAtafolder DFR_table
	
	Wave gapsize
	Wave kx,ky,kz
	Wave coskx,cosky,coskz
	
	Wave gaperror

	
	make /o/n=(numpnts(gapsize)) gapsize_kxky_X,gapsize_kxky_y
	
	gapsize_kxky_y=gapsize[p]
	
	
	
	switch(gapsymmetry)
	case 1:
		gapsize_kxky_x=abs(coskx[p]*cosky[p])
		break	
	case 2:
		gapsize_kxky_x=abs(coskx[p]-cosky[p])/2
		break
	endswitch
	
	
	
	display_XYwave(gapsize_kxky_y,gapsize_kxky_x,0,0)
	
	String gN=winname(0,65)
		
	Wave data_gn=WaveRefIndexed(gN, 0, 1)
	if (WaveExists(data_gN)==0)
		Wave data_gn=ImageNameToWaveRef(gN,stringfromlist(0,ImageNameList(gN, ";")))
	endif
			
	String w_df=GetWavesDatafolder(data_gn,1)
	SetDatafolder $w_df
	
	Duplicate /o gaperror gapsize_kxky_y_error
	
	Variable gapmax=wavemax(gapsize)*1.2
	
	ModifyGraph /W=$gn mode=3,marker=19
	//ModifyGraph width={Plan,1,bottom,left}
	SetAxis /W=$gn bottom 0,1
	SetAxis /W=$gn left 0, gapmax
	
	ErrorBars /T=0/W=$gn gapsize_kxky_y Y,wave=(gapsize_kxky_y_error,gapsize_kxky_y_error)
	
	SetDatafolder DF
End