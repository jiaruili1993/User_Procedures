#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 0.02

Function /DF init_main_panel()
   DFREF DF = GetDataFolderDFR()
   String DF_panel="root:internalUse:"+winname(0,65)
   NewDataFolder/O/S $DF_panel
   DFREF DFR_panel=$DF_panel
   Variable /G gv_killflag=0
   
   SetDatafolder DF
   return DFR_panel
End


Function close_main_panel(ctrlname)
	String ctrlName
	String wname=winName(0,65)
	String DF_panel="root:internalUse:"+wname
		DFREF DFR_panel=$DF_panel
		NVAR killflag=DFR_panel:gv_killflag
		killflag=1
	dowindow/K $wname
End

Function Open_main_Panel(ctrlName)
	String ctrlName
	
	DFREF DF = GetDataFolderDFR()
	
	Variable SC = ScreenSize(5)

   
      	Variable SR = Igorsize(3) 
	Variable ST = Igorsize(2)
	Variable SL = Igorsize(1)
       Variable SB = Igorsize(4)
    	
    	DFREF DFR_prefs=$DF_prefs
    	NVAR panelscale=DFR_prefs:gv_panelscale
    	NVAR macscale=DFR_prefs:gv_macscale
    
	Variable Width = 520*Panelscale*MacScale	// screen size  in point
	Variable height = 500*Panelscale*MacScale
	Variable xOffset = (SR-SL)/2-width/2
	Variable yOffset = (SB-ST)/2-height/2
	
	//DoWindow/K main_panel
	String panelnamelist=winlist("main_panel_*",";","WIN:65")
	
	if (strlen(panelnamelist)==0)
		string spwinname=UniqueName("main_panel_", 9, 0)
		Display /W=(xOffset, yOffset,xOffset+1.5*width,Height+yOffset) as spwinname
		DoWindow/C $spwinname
   		Setwindow $spwinname hook(MyHook) = MypanelHook
	else
		if (stringmatch(ctrlname,"global_duplicate_panel"))
			spwinname=UniqueName("main_panel_", 9, 0)
			Display /W=(xOffset, yOffset,xOffset+width,Height+yOffset) as spwinname
			DoWindow/C $spwinname
   			Setwindow $spwinname hook(MyHook) = MypanelHook
		else
			BringUP_Allthepanel(panelnamelist,0)
			SetDataFolder DF 
			return 1
		endif
	endif
	
	
	ControlBar 220*SC
	
	Variable r=57000, g=57000, b=57000
	ModifyGraph cbRGB=(52428,52428,52428)
	ModifyGraph wbRGB=(38776,46477,61383), gbRGB=(38776,46477,61383)
	
	DFREF DFR_panel=init_main_panel()
	DFREF DFR_common=init_panelcommon()
		
	SetDataFolder DFR_panel
	String panelcommonPath=GetDatafolder(1,DFR_common)

	Button global_close_panel, pos={640*SC,5*SC},size={60*SC,18*SC},title="close", proc=close_main_panel
	Button global_duplicate_panel, pos={720*SC,1*SC},size={70*SC,18*SC},title="duplicate", proc=Open_main_Panel
	
    	listbox global_waves_list, pos={16*SC,45*SC}, size={110*SC,140*SC}, widths={200},listwave=DFR_common:w_sourceNames, selwave=DFR_common:w_sourceNamesSel, frame=2,mode=9, proc=source_Listbox_proc
	listbox global_prolist, pos={133*SC,45*SC}, size={90*SC,140*SC},listwave=DFR_common:w_proclist,selwave=DFR_common:w_proclistsel, frame=2,mode=5,proc=proc_Listbox_proc,colorwave=DFR_common:proclist_color
	Titlebox global_tb1,title="Image",pos={20*SC,30*SC},labelBack=(r,g,b),frame=0,variable=DFR_common:gs_currentDF
	checkbox global_ck6,title="lock",pos={180*SC,30*SC},labelBack=(r,g,b),frame=0,proc=c_locklayerproc,variable=DFR_common:gv_autolayerflag
	
	//Popupmenu global_pop0,pos={16,170}, bodywidth=130, size={130,20},value=#(panelcommonPath+"gs_proclist")
	//Titlebox global_tb2,title="Proc",pos={135,30},labelBack=(r,g,b),frame=0
	
	CheckBox global_ck0, pos={10*SC,200*SC}, title="suppress update"
	CheckBox global_ck1, pos={120*SC,200*SC}, title="lock DCs scale", proc=lock_intensity
	CheckBox global_ck5, pos={225*SC,200*SC}, title="lock Image scale", proc=lock_intensity
	CheckBox global_ck2, pos={350*SC,200*SC}, title="collapse E", proc=collapse_proc
	CheckBox global_ck3, pos={430*SC,200*SC}, title="collapse k", proc=collapse_proc
	CheckBox global_ck4, pos={520*SC,200*SC}, title="between cursors", value=1, proc=collapse_proc
	
	Button global_gold, size={40*SC,20*SC},pos={645*SC,25*SC}, title="gold", proc=open_gold_panel
	//Button global_main, size={40,20},pos={640,55}, title="main", proc= Open_main_Panel
	Button global_map, size={40*SC,20*SC},pos={645*SC,55*SC}, title="map", proc= open_mapper_panel
	Button global_BZ, size={40*SC,20*SC},pos={645*SC,85*SC}, title="BZ", proc=open_bz_panel
	Button global_Anal, size={40*SC,20*SC},pos={645*SC,115*SC}, title="Anal", proc=Open_Analysis_Panel
	Button global_Fit, size={40*SC,20*SC},pos={645*SC,145*SC}, title="Fit", proc=open_fit_panel
   	Button global_opdt,pos={645*SC,175*SC},size={40*SC,20*SC},title="DataT",proc=open_data_table
    
    
	
	
    	TabControl main,proc=main_AutoTab_proc, pos={8*SC,6*SC},size={630*SC,190*SC},value=0,labelBack=(r,g,b)
    
    	TabControl main,tabLabel(0)="source"//selwave=DFR_common:w_DFListsel,
    
    	GroupBox source_gb0, frame=0,labelBack=(r,g,b), pos={230*SC,30*SC} ,size={295*SC,155*SC}, title="source folder"
	listbox source_lb1, pos={240*SC,70*SC}, size={270*SC,110*SC},listwave=DFR_common:w_DF, widths={400},selrow=0, frame=2,mode=6, proc=source_Listbox_proc
    	SetVariable source_sv0,labelBack=(r,g,b), pos={240*SC,50*SC},size={130*SC,20*SC}, title="search",frame=1,value=DFR_common:gs_matchstring,proc=Folder_list_search_proc
    	Button source_bt0,labelBack=(r,g,b),pos={370*SC,48*SC},size={45*SC,20*SC},fsize=10*SC,title="All",proc=Default_Folder_proc
    	Button source_bt1,labelBack=(r,g,b),pos={420*SC,48*SC},size={45*SC,20*SC},fsize=10*SC,title="process",proc=Default_Folder_proc
    	Button source_bt2,labelBack=(r,g,b),pos={470*SC,48*SC},size={45*SC,20*SC},fsize=10*SC,title="spectra",proc=Default_Folder_proc
  	checkbox source_ck1,labelBack=(r,g,b), pos={507*SC,30*SC},size={30*SC,20*SC}, title="2D", value=0,proc=Proc_checkbox_dimchange
 	checkbox source_ck2,labelBack=(r,g,b), pos={547*SC,30*SC},size={30*SC,20*SC}, title="3D", value=1,proc=Proc_checkbox_dimchange
    	checkbox source_ck0,labelBack=(r,g,b), pos={527*SC,50*SC},size={80*SC,20*SC}, title="sort", value=1,proc=wave_list_sort_proc
    	Button source_robt,labelBack=(r,g,b),pos={572*SC,48*SC},size={60*SC,18*SC},title="reorder",proc=wave_reorder_proc
    	Button source_autoload,labelBack=(r,g,b),pos={530*SC,75*SC},size={100*SC,25*SC},title="autoload",proc=wave_autoload_proc
    	Button source_delwave,labelBack=(r,g,b),pos={530*SC,106*SC},size={50*SC,18*SC},title="KillW",proc=wave_delfrompanel_proc
    	Button source_ribinwave,labelBack=(r,g,b),pos={585*SC,106*SC},size={45*SC,18*SC},title="Rebin",proc=wave_rebinfrompanel_proc
    	Button source_bt4,labelBack=(r,g,b),pos={530*SC,126*SC},size={40*SC,18*SC},title="New",proc=main_wave_save_NewDF
    	Button source_bt6,labelBack=(r,g,b),pos={570*SC,126*SC},size={30*SC,18*SC},title="Del",proc=main_wave_del_NewDF
    	Button source_bt7,labelBack=(r,g,b),pos={600*SC,126*SC},size={30*SC,18*SC},title="Re",proc=main_wave_rename_NewDF
    	Button source_bt5,labelBack=(r,g,b),pos={580*SC,28*SC},size={50*SC,18*SC},title="2D->3D",proc=main_wave_Convert_Process
   	popupmenu source_pop3,labelBack=(r,g,b),pos={530*SC,147*SC},bodywidth=100*SC,size={100*SC,18*SC},mode=1,title="",value=#(panelcommonPath+"gs_DFlist"),proc=pop_DFlist_update_proc
    	Button source_svbt0,labelBack=(r,g,b),pos={580*SC,170*SC},size={50*SC,18*SC},title="Move To",proc=main_wave_save_proc
  	Button source_svbt1,labelBack=(r,g,b),pos={530*SC,170*SC},size={50*SC,18*SC},title="Copy To",proc=main_wave_save_proc
  	
  
  	
	
	add_Tab_DCs()
	add_Tab_normalize()
	add_Tab_process()
	
	add_image_DCs("main_panel")
	panelimageupdate(3)
	
	TabControl main,tabLabel(1)="DCs"
	TabControl main,tabLabel(2)="TMF"
	TabControl main,tabLabel(3)="Disp"
	//TabControl main,tabLabel(4)="Wrap"
	TabControl main,tabLabel(4)="Scale"
	TabControl main,tabLabel(5)="Kplot"
	TabControl main,tabLabel(6)="Bkg"
	TabControl main,tabLabel(7)="Norm"
	TabControl main,tabLabel(8)="proc"
	TabControl main,tabLabel(9)="Corr"
	TabControl main,tabLabel(10)="Macro"
	
	//main_panel_SLB_proc()
	
	SetDataFolder DF
	

		
	//checkbox DCs_ck0, pos={320,140}, size={60,16}, title="kxky_plot",proc=c_kxkykzplot,disable=1
	//checkbox DCs_ck1, pos={400,140}, size={60,16}, title="kxkz_plot",proc=c_kxkykzplot,disable=1
	
	
	
	
End



///////////////////////////Tab control///////////////////


Function main_AutoTab_proc( name, tab )
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
	DFREF DFR_normal=$(DF_panel+":process")
		
	NVAR first =DFR_panel:gv_first
	NVAR last = DFR_panel:gv_last
	NVAR step = DFR_panel:gv_step
	NVAR Dcnum=DFR_panel:gv_Dcnum
	WAVE M = DFR_common:w_image
	Variable  d_limit
	
	Variable SC=Screensize(5)
	
	if (stringmatch(tabstr,"source")==1)
		//if (traceexist(winname(0,65),"w_norm",1))
		Proc_checkbox_showDisp("dummy",0)
		//endif
	endif
	
	if (stringmatch(tabstr,"DCs")==1)
		Proc_checkbox_showDisp("dummy",0)
    	//endif
	endif
	
	
	if (stringmatch(tabstr,"TMF")==1)
		//popupmenu source_pop3,win=$graphname,disable=0
    	//Button source_svbt0,win=$graphname,disable=0
    	//Button source_svbt1,win=$graphname,disable=0
	//	CheckBox tmf_c3,win=$graphname,value=1,disable=2
		//CheckBox tmf_c4,win=$graphname,value=0,disable=1
	//	SetVariable tmf_sv4,win=$graphname,disable=1
	//	SetVariable tmf_sv5,win=$graphname,disable=1
		//GroupBox tmf_gb0, disable=0
		Listbox disp_lb1, disable=0
		CheckBox disp_c0, disable=0
		CheckBox disp_c1, disable=0
		
		controlinfo /W=$graphname Disp_lb1
		Proc_listbox_dispNames("Disp_lb1", V_Value, 0, 4)
		
		checkbox disp_c2, win=$graphname,disable=0,value=1
		Proc_checkbox_showDisp("disp_c2",1)
		
	endif	
	
	if (stringmatch(tabstr,"Disp")==1)
		
		controlinfo  /W=$graphname disp_lb1
		Proc_listbox_dispNames("disp_lb1", V_Value, 0, 4)
	
		checkbox disp_c2,win=$graphname,value=1
		Proc_checkbox_showDisp("disp_c2",1)
	endif	
	
	if (stringmatch(tabstr,"Scale")==1)
		//popupmenu source_pop3,win=$graphname,disable=0
    	//Button source_svbt0,win=$graphname,disable=0
    	//Button source_svbt1,win=$graphname,disable=0
		Proc_checkbox_showDisp("dummy",0)
	endif
	
	if (stringmatch(tabstr,"Bkg")==1)
    	    	
		GroupBox Norm_gb1,disable=0
		Button Norm_b5, disable=0
		Button Norm_b6, disable=0
		checkbox Norm_c2, disable=0
		CheckBox Norm_c3,disable=0
		CheckBox Norm_c4,disable=0
		Setvariable Norm_sv0, disable=0
		Setvariable Norm_sv1, disable=0
		Setvariable Norm_sv2, disable=0
		Setvariable Norm_sv3, disable=0
		Setvariable Norm_sv4, disable=0
		Setvariable Norm_sv5, disable=0
		TitleBox Norm_t5,win=$graphname,disable=0
		
		GroupBox Norm_gb01, disable=0
		checkbox Norm_ck11, disable=0
		checkbox Norm_ck21, disable=0
		checkbox  Norm_ck31, disable=0
		SetVariable Norm_sv01, disable=0
		Button Norm_b01, disable=0
		Button Norm_b11, disable=0
		CheckBox Norm_ck01, disable=0
		CheckBox Norm_ck02, disable=0
		SetVariable Norm_sv02, disable=0
		SetVariable Norm_sv03, disable=0
		
		Groupbox bkg_gp0, pos={430*SC,35*SC}, size={200*SC,105*SC}, disable=0
		
		Proc_listbox_procwave("dummy",0,0,4)
		
		checkbox disp_c2,win=$graphname,value=1,disable=0
		Proc_checkbox_showDisp("dummy",1)
	endif

	if (stringmatch(tabstr,"Norm")==1)
		checkbox bkg_ck11,disable=0
		checkbox bkg_ck21,disable=0
		checkbox bkg_ck31,disable=0
		checkbox bkg_ck41,disable=0
		checkbox bkg_ck51,disable=0
		
		
		Groupbox bkg_gp0, pos={430*SC,35*SC}, size={200*SC,105*SC}, disable=0
		Listbox bkg_lb0,disable=0
		Button bkg_bt0,disable=0
		Button bkg_bt1,disable=0
		
		Proc_listbox_procwave("dummy",0,0,4)
	
		//controlinfo Norm_ck4
		//proc_Checkbox_Fermsel("dummy",V_value) 
		
		checkbox disp_c2,win=$graphname,value=1,disable=0
		Proc_checkbox_showDisp("dummy",1)
		
		//TitleBox tmf_t5,win=$graphname,disable=0
	endif

	
	if (stringmatch(tabstr,"kplot")==1)
		//popupmenu source_pop3,win=$graphname,disable=0
    	//Button source_svbt0,win=$graphname,disable=0
   	 	//Button source_svbt1,win=$graphname,disable=0
		Proc_checkbox_showDisp("dummy",0)
	endif
	
	if (stringmatch(tabstr,"proc")==1)
		//popupmenu source_pop3,win=$graphname,disable=0
    	//Button source_svbt0,win=$graphname,disable=0
    	//Button source_svbt1,win=$graphname,disable=0
		Proc_checkbox_showDisp("dummy",0)
	endif
	
	if (stringmatch(tabstr,"Corr")==1)
		Groupbox bkg_gp0, pos={430*SC,35*SC}, size={200*SC,105*SC}, disable=0
		Listbox bkg_lb0,disable=0
		Button bkg_bt0,disable=0
		Button bkg_bt1,disable=0
		checkbox bkg_ck11,disable=0
		checkbox bkg_ck21,disable=0
		checkbox bkg_ck31,disable=0
		checkbox bkg_ck41,disable=0
		checkbox bkg_ck51,disable=0
		Proc_listbox_procwave("dummy",0,0,4)
		
		checkbox disp_c2,win=$graphname,value=1,disable=0
		Proc_checkbox_showDisp("dummy",1)
	endif
	
	

	
	
	
	
	if (stringmatch(tabstr,"Macro")==1)
		popupmenu source_pop3,win=$graphname,disable=0
    		Button source_svbt0,win=$graphname,disable=0
    		Button source_svbt1,win=$graphname,disable=0
		Proc_checkbox_showDisp("dummy",0)
	
	Wave w_image=DFR_common:w_image
	SVAR procstr=DFR_normal:gs_procstr_disp
	NVAR toplayernum=DFR_common:gv_toplayernum
		procstr=Getlayernotestr(note(w_image),toplayernum,1)
			Variable tempx=strsearch(procstr,"\r",0)
			Variable tempx0=strsearch(procstr,"xpnts=",0)
			Variable tempx1=strsearch(procstr,"y1=",0)
			Variable tempx2=strsearch(procstr,"\r",tempx1)
			Variable tempx3=strsearch(procstr,"Layer_",tempx2)
			procstr=procstr[tempx+1,tempx0-1]+procstr[tempx2+1,tempx3-1]
	endif
	
	SetDatafolder DF
	
End


Function main_panel_SLB_proc()

	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	SetDataFolder $DF_panel
	DFREF DFR_common= $(DF_panel+":panel_common")
	SetActivesubwindow $winname(0,65)
	
	DFREF DF_normal=$(DF_panel+":process")
			
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
	
		ControlInfo /W=$winname(0,65) global_ck0
		if(v_value)
		else
		//NVAR csr_e=DF_normal:gv_csr_e
		//NVAR csr_m0=DF_normal:gv_csr_m0
		//NVAR csr_em1=DF_normal:gv_csr_m1
		NVAR x0=DF_normal:gv_axes_x0
		NVAR x1=DF_normal:gv_axes_x1
		NVAR dx=DF_normal:gv_axes_dx
		
		x0=M_x0(w_image)
		x1=M_x1(w_image)
		dx=dimdelta(w_image,0)	
	
		endif
		
		controlinfo main
		if (stringmatch(s_value,"Macro"))
			SVAR procstr=DF_normal:gs_procstr_disp
			NVAR toplayernum=DFR_common:gv_toplayernum
			procstr=Getlayernotestr(note(w_image),toplayernum,1)
			Variable tempx=strsearch(procstr,"\r",0)
			Variable tempx0=strsearch(procstr,"xpnts",0)
			Variable tempx1=strsearch(procstr,"y1=",0)
			Variable tempx2=strsearch(procstr,"\r",tempx1)
			Variable tempx3=strsearch(procstr,"Layer_",tempx2)
			procstr=procstr[tempx+1,tempx0-1]+procstr[tempx2+1,tempx3-1]//replacestring("\r",procstr,",")
		endif

SetDatafolder DF

End

Function Proc_checkbox_dimchange(name,value)
	String name
	Variable value
	
	String panelname=winname(0,65)
	String DF_panel="root:internalUse:"+panelName
	DFREF DFR_common=$(DF_panel+":panel_common")
	NVAR autolayerflag=DFR_common:gv_autolayerflag
	
	SetActiveSubwindow $winname(0,65)
	
	Variable checkVal
	strswitch (name)
		//case "disp_c3":
	//		checkVal= 3
	//		break
		case "source_ck1":
				TabControl main,tabLabel(10)=""
				TabControl main,tabLabel(9)=""
				TabControl main,tabLabel(8)=""
				TabControl main,tabLabel(7)=""
				TabControl main,tabLabel(6)=""
				TabControl main,tabLabel(5)=""
				TabControl main,tabLabel(4)=""
				TabControl main,tabLabel(3)=""
				TabControl main,tabLabel(2)=""
						
				checkbox global_ck6,value=0,disable=2
				listbox global_prolist,disable=2
				c_locklayerproc("dummy",0)
				
			checkVal= 1
			break
		case "source_ck2":
			checkVal= 2
			TabControl main,tabLabel(1)="DCs"
			TabControl main,tabLabel(2)="TMF"
			TabControl main,tabLabel(3)="Disp"
			TabControl main,tabLabel(4)="Scale"
			TabControl main,tabLabel(5)="Kplot"
			TabControl main,tabLabel(6)="Bkg"
			TabControl main,tabLabel(7)="Norm"
			TabControl main,tabLabel(8)="proc"
			TabControl main,tabLabel(9)="Corr"
			TabControl main,tabLabel(10)="Macro"
			checkbox global_ck6,disable=0
			listbox global_prolist,disable=0
			break
	endswitch
	//CheckBox disp_c3,value= checkVal==3
	CheckBox source_ck1,value= checkVal==1
	CheckBox source_ck2,value= checkVal==2
	source_Listbox_Proc("source_lb1", 0, 0, 4)
	
End



Function pop_DFlist_update_proc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	String panelname=winname(0,65)
	String DF_panel="root:internalUse:"+panelName
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	
	SetActiveSubwindow $winname(0,65)
	
	SVAR gs_DFlist=DFR_common:gs_DFlist
	
	String DFList=FoldertoList(root:spectra:,"*",0)
	DFlist=removeStringfromlist(DFlist,"root:spectra:",";",0)
	if (strlen(gs_DFlist)<2)
	gs_DFlist="process:;gold:;"
	else
	gs_DFlist="process:;gold:;"+DFlist
	endif	
	if (strsearch(gs_DFlist,popStr,0)<0)
	popupmenu source_pop3,mode=1
	ControlUpdate source_pop3
	endif
End

Function main_wave_rename_NewDF(ctrlname)
String ctrlname
DFREF df=GetDatafolderDFR()
	String panelname=winname(0,65)
	String DF_panel="root:internalUse:"+panelName
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	
	SVAR gs_DFlist=DFR_common:gs_DFlist
	SVAR currentDF=DFR_common:gs_currentDF
	
	DFREF DFR_current=$currentDF
	
	String DFfolder=GetDatafolder(0,DFR_current)

	prompt DFfolder,"Change name to?"
	DoPrompt "Input new Datafolder",DFfolder
	if (V_flag==0)
	if (strsearch(DFfolder,":",0)!=-1)
		//if (MakenewFolder(DFfolder)==0)
			DoAlert 0, "Sorry, "+DFfolder+" is no a legal DF name.\rPlease rename the folder!"
			SetDatafolder DF
			return 0
		//else
		//DuplicateDataFolder $CurrentDF, destDataFolderPath
		//endif
	else
		if (is_liberal(DFfolder))
			DoAlert 0, "Sorry, "+DFfolder+" is no a legal DF name.\rPlease rename the folder!"
			SetDatafolder DF
			return 0
		endif
	
		RenameDataFolder $currentDF $DFfolder
	endif
	
	String DFList=FoldertoList(root:spectra:,"*",0)
	DFlist=removeStringfromlist(DFlist,"root:spectra:",";",0)
	if (strlen(gs_DFlist)<2)
	gs_DFlist="process:;gold:;"
	else
	gs_DFlist="process:;gold:;"+DFlist
	endif

	Variable popnum=WhichListItem(DFfolder+":",gs_DFlist,";",0)
	if (popnum<0)
	popnum=0
	endif
	popupmenu source_pop3,mode=(popnum+1)
	ControlUpdate source_pop3
	
endif
	SetDatafolder DF

End



Function main_wave_del_NewDF(ctrlname)
	String Ctrlname
	DFREF DF=GetDatafolderDFR()
	String panelname=winname(0,65)
	String DF_panel="root:internalUse:"+panelName
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	SVAR gs_DFlist=DFR_common:gs_DFlist
	SVAR currentDF=DFR_common:gs_currentDF

	if (Strsearch(currentDF,"root:process",0)!=-1)
		Doalert 0, "Can't delete the process DataFolder!"
		SetDatafolder DF
		return 0
	elseif (Strsearch(currentDF,"root:gold",0)!=-1)
		Doalert 0, "Can't delete the gold DataFolder!"
		SetDatafolder DF
		return 0
	elseif (Strsearch(currentDF,"root:internalUse",0)!=-1)
		Doalert 0, "Can't delete the internalUse DataFolder!"
		SetDatafolder DF
		return 0
	elseif (Stringmatch(currentDF,"root:spectra")==1)
		Doalert 0, "Can't delete the spectra DataFolder!"
		SetDatafolder DF
		return 0
	elseif (Stringmatch(currentDF,"root:rawData")==1)
		Doalert 0, "Can't delete the spectra DataFolder!"
		SetDatafolder DF
		return 0
	else
	endif

	Doalert 1, "Delete the DataFolder?"

	if (V_flag==1)
     
		KillDataFolder /Z $CurrentDF
		source_Listbox_Proc("source_lb1", 0, 0, 1)
	
		String DFList=FoldertoList(root:spectra:,"*",0)
		DFlist=removeStringfromlist(DFlist,"root:spectra:",";",0)
		if (strlen(gs_DFlist)<2)
			gs_DFlist="process:;gold:;"
		else
			gs_DFlist="process:;gold:;"+DFlist
		endif
	
	popupmenu source_pop3,mode=1
	ControlUpdate source_pop3
	endif

	SetDatafolder DF
End

Function MakenewFolder(DFFolder)
	String DFfolder
	if (strsearch(DFfolder,":",0)!=-1)
		Variable temp=strsearch(DFfolder,":",0)
		String TempDF=DFfolder[0,temp-1]
		if (is_liberal(TempDF))
			DoAlert 0, "Sorry, "+DFfolder+" is no a legal DF name.\rPlease rename the folder!"
			return 0
		else
			newDatafolder /o/s $tempDF
			tempDF=DFfolder[temp+1,inf]
			return MakenewFolder(tempDF)
		endif
	else
		if (is_liberal(DFfolder))
			DoAlert 0, "Sorry, "+DFfolder+" is no a legal DF name.\rPlease rename the folder!"
			return 0
		else
		newDatafolder /o/s $DFfolder
		return 1
		endif
	endif
End

Function main_wave_save_NewDF(ctrlname)
	String Ctrlname
	DFREF DF=GetDatafolderDFR()
	String panelname=winname(0,65)
	String DF_panel="root:internalUse:"+panelName
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	SVAR gs_DFlist=DFR_common:gs_DFlist

	String DFfolder

	prompt DFfolder,"Datafolder in root:spectra:"
	DoPrompt "Input new Datafolder",DFfolder
	if (V_flag==1)
		SetDatafolder DF
		return 0
	endif
		
	SetDatafolder root:spectra
		//if (strsearch(DFfolder,":",0)!=-1)
	if (MakenewFolder(DFfolder)==0)
		//	DoAlert 0, "Sorry, "+DFfolder+" is no a legal DF name.\rPlease rename the folder!"
		SetDatafolder DF
		return 0
	endif
		//else
		//	if (is_liberal(DFfolder))
			//DoAlert 0, "Sorry, "+DFfolder+" is no a legal DF name.\rPlease rename the folder!"
			//SetDatafolder DF
			//return 0
			//endif
	//newDatafolder /o $("root:spectra:"+DFfolder)
	//endif
	
	String DFList=FoldertoList(root:spectra:,"*",0)
	DFlist=removeStringfromlist(DFlist,"root:spectra:",";",0)
	if (strlen(gs_DFlist)<2)
	gs_DFlist="process:;gold:;"
	else
	gs_DFlist="process:;gold:;"+DFlist
	endif

	Variable popnum=WhichListItem(DFfolder+":",gs_DFlist,";",0)
	if (popnum<0)
	popnum=0
	endif
	popupmenu source_pop3,mode=(popnum+1)
	ControlUpdate source_pop3

	SetDatafolder DF
End


Function main_wave_Convert_Process(ctrlname)
	String Ctrlname
	DFREF df=Getdatafolderdfr()
	String panelname=winname(0,65)
	String DFS_panel="root:internalUse:"+panelName
	String DFS_common="root:internalUse:"+panelName+":panel_common"
	DFREF DFR_common=$DFS_common
	DFREF DF_panel=$DFS_panel
	SetActiveSubwindow $winname(0,65)	
	
	controlinfo source_ck1
	if (v_value==0)
		return 0
	endif
	
	SVAR sourcePathlist=DFR_common:gs_sourcePathlist
	SVAR sourcenamelist=DFR_common:gs_sourcenamelist
	SVAR toppath=DFR_common:gs_TopItemPath
	SVAR topName = DFR_common:gs_TopItemName
	SVAR DFlist=DFR_common:gs_DFlist
	NVAR toplayernum=DFR_common:gv_toplayernum
	NVAR topwaverow=DFR_common:gv_topwaverow
	NVAR topdfrow=DFR_common:gv_topdfrow
	WAVE/t w_DF=DFR_common:w_DF
	WAVE/t w_sourceNames=DFR_common:w_sourceNames
	Wave/b w_sourceNamesSel=DFR_common:w_sourceNamesSel
		
	initialdialogwindow()
	DFREF DF_userpanel=root:InternalUse:User_panel
	NVAR processallflag=DF_userpanel:gv_processallflag	
	NVAR autoprocessflag=DF_userpanel:gv_autoprocessflag
	SVAR suffix=DF_userpanel:gs_suffix
	SVAR new_wavename=DF_userpanel:gs_new_wavename
	
		
	String saveDF="root:process:"
	
	Variable index=0
	String wave_path,wave_name,dwave_name
	Variable tempsel

	

	do 
	
	if ((w_sourceNamesSel[index] == 1)||(w_sourceNamesSel[index] == 8)||(w_sourceNamesSel[index]==9))
		toppath=w_DF[topdfrow]+w_sourceNames[index]
		topname=w_sourceNames[index]
		tempsel=w_sourceNamesSel[index]
		w_sourceNamesSel[index]=0
	
		if (strlen(toppath)==0)
			break
		endif
		wave_path=toppath
	
	
		Wave data=$wave_path
	
		if (wavedims(data)<3)
	
			GetProList(DFR_common,data,NAN)
			Panelimageupdate(3)
	
					
			String DFfolder=topname
  		//	prompt DFfolder,"Save Wave to Process: root:process:"+topname
  		//	DoPrompt "Save Datafolder",DFfolder
  		//	if (V_flag==1)
		//		SetDatafolder DF
		//		return 0
		//	else
			
		//	endif
		
			dwave_name=saveDF+DFfolder
			
			Variable overwriteflag=1
			do
			if (waveexists($dwave_name))
				if (processallflag==0)
					Setdialogwindow(winname(0,65),data,"Proc")
					openautosavewindow(winname(0,65))
				else
					break
				endif
			
				switch (autoprocessflag)
				case 0:
					dwave_name=wave_path
					overwriteflag=0
					break
				case 1:
					dwave_name=saveDF+topname
					overwriteflag=0
					break
				case 2:
					dwave_name=saveDF+topname+"_"+suffix
					break
				case 3:
					dwave_name=saveDF+new_wavename
					break
				endswitch
			else
				break
			endif
		while (overwriteflag)
	
		if (stringmatch(wave_path,dwave_name)==0)
			duplicate /o data,$(dwave_name)
			Wave dataprc=$(dwave_name)
			InitialprocNotestr2D(dataprc,"rawData")
			redimension /N=(dimsize(data,0),dimsize(data,1),1) dataprc
		endif
	endif
	
	w_sourceNamesSel[index]=tempsel
	endif
	
	index+=1
	while (index<numpnts(w_sourceNamesSel))
	
	Proc_checkbox_dimchange("source_ck2",1)
	//source_Listbox_Proc("source_lb1", topdfrow, 0, 4)
	
	
End

Function wave_rebinfrompanel_proc(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderDFR()
	String panelname=winname(0,65)
	String DF_panel="root:internalUse:"+panelName
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	
	
	SVAR sourcePathlist=DFR_common:gs_sourcePathlist
	SVAR sourcenamelist=DFR_common:gs_sourcenamelist
	SVAR currentDF=DFR_common:gs_currentDF
	SVAR toppath=DFR_common:gs_TopItemPath
	SVAR topName = DFR_common:gs_TopItemName
	SVAR DFlist=DFR_common:gs_DFlist
	NVAR toplayernum=DFR_common:gv_toplayernum
	NVAR topwaverow=DFR_common:gv_topwaverow
	NVAR topdfrow=DFR_common:gv_topdfrow
	WAVE/t w_DF=DFR_common:w_DF
	WAVE/t w_sourceNames=DFR_common:w_sourceNames
	Wave/b w_sourceNamesSel=DFR_common:w_sourceNamesSel
	
	initialdialogwindow()
	DFREF DF_userpanel=root:InternalUse:User_panel
	NVAR processallflag=DF_userpanel:gv_processallflag	
	NVAR autoprocessflag=DF_userpanel:gv_autoprocessflag
	NVAR forceinsertflag=DF_userpanel:gv_forceinsertflag
	
	
	Check_Autosimilar_layer(DF_common,1)

	Variable index,datalayernum
	
	String wave_path,wave_name
	Variable tempsel
	
	SVAR Waverebin_list=DFR_common:gs_sourcePathList
	Variable items=itemsinlist(Waverebin_list,";")
	
	if (items<2)
		SetDatafolder DF
		return 0
	endif
	
	Variable rebinnum
	String DFfolder=currentDF+"raw"
	
	Variable rebinflag=0
	
	prompt rebinflag,"Rebin by :",popup,"index;Tem;"
	prompt rebinnum,"Rebin_step:"
	prompt DFfolder,"Save Wave to "
	Doprompt "Input rebin parameters",rebinflag,rebinnum,DFfolder
	
	if (V_flag==1)
		SetDatafolder DF
		Return 0
	endif
	
	newDatafolder /o $DFfolder
	setdatafolder $currentDF
	//DFfolder=RemoveEnding(DFfolder, ":")
		
	//if (MakenewFolder(DFfolder)==0)
		//	DoAlert 0, "Sorry, "+DFfolder+" is no a legal DF name.\rPlease rename the folder!"
	//	SetDatafolder DF
	//	return 0
	//endif

	Make /o/n=(items) w_x0,w_x1,w_dx,w_y0,w_y1,w_dy
	
	index=0
	
	do
			wave_path=Stringfromlist(index,Waverebin_list,";")
	
			Wave data=$wave_path
			
			
			GetLayerimage(data,toplayernum)
			duplicate /o templayerimage,tempimage
			killwaves/Z templayerimage
	
			w_x0[index]=M_x0(tempimage)
			w_x1[index]=M_x1(tempimage)
			w_dx[index]=dimdelta(tempimage,0)
			w_y0[index]=M_y0(tempimage)
			w_y1[index]=M_y1(tempimage)
			w_dy[index]=dimdelta(tempimage,1)
		
		index+=1
	while (index<items)
	
	Variable x0,x1,dx,y0,y1,dy,nx,ny
	
	Variable interpflag=0
	
	x0=checkreturnwaveequal(w_x0,Nan,Nan)
	if (numtype(x0)==2)
		interpflag=1
		x0=wavemin(w_x0)
	endif
	
	x1=checkreturnwaveequal(w_x1,Nan,Nan)
	if (numtype(x1)==2)
		interpflag=1
		x1=wavemax(w_x1)
	endif
	
	dx=checkreturnwaveequal(w_dx,Nan,Nan)
	if (numtype(dx)==2)
		interpflag=1
		dx=wavemin(w_dx)
	endif
	
	y0=checkreturnwaveequal(w_y0,Nan,Nan)
	if (numtype(y0)==2)
		interpflag=1
		y0=wavemin(w_y0)
	endif
	
	y1=checkreturnwaveequal(w_y1,Nan,Nan)
	if (numtype(y1)==2)
		interpflag=1
		y1=wavemax(w_y1)
	endif
	
	dy=checkreturnwaveequal(w_dy,Nan,Nan)
	if (numtype(dy)==2)
		interpflag=1
		dy=wavemin(w_dy)
	endif
	
	if (interpflag==0)
		nx=dimsize(tempimage,0)
		ny=dimsize(tempimage,1)
		
	else
		Doalert /T="joinmultwave" 1,"Unequal range, Interp?"
		if (V_flag==2)
			SetDatafolder DF
			return 0
		endif
		
		nx=round((x1-x0)/dx)+1
		ny=round((y1-y0)/dy)+1
	
	endif
	
	Make /o/n=(nx,ny) T_spectra
	
	Setscale /I x,x0,x1,T_spectra
	Setscale /I y,y0,y1,T_spectra
	
	if (rebinflag==1)
	
	endif
		//Variable nz=floor(items/rebinnum)
		//if (nz==0)
		//	rebinnum=items
		//	nz=1
		//endif
		
	Make /o/n=(0), T_sweep,T_tem, T_I0
	
	
	Variable Zindex=0
	Variable binindex=0
	index=0
	do
		if (index>=items)
			break
		endif
			
		binindex=0
		T_spectra=0
		Variable Startindex=0
		Variable Lastindex=0
		
		redimension /N=0 T_sweep,T_tem,T_I0
		
		do
			wave_path=Stringfromlist(index,Waverebin_list,";")
			
			if (strlen(wave_path)==0)
				break
			endif
	
			Wave data=$wave_path
	
			GetLayerimage(data,toplayernum)
			duplicate /o templayerimage,tempimage
			killwaves/Z templayerimage
			
			if (binindex==0)
				string notestr=note(tempimage)
				string firstname=nameofwave(data)
				
				if (rebinflag==1)
					Startindex=0
				elseif(rebinflag==2)
					Startindex=return_xwave_info(tempimage,2)
				endif
			else
				if (rebinflag==1)
					Lastindex+=1
				elseif(rebinflag==2)
					Lastindex=return_xwave_info(tempimage,2)
				endif
				
				
				if (Lastindex>Startindex)
					if (Lastindex>=(Startindex+rebinnum))
						break
					endif
				else
					if (Lastindex<=(Startindex-rebinnum))
						break
					endif
				endif
			endif
			
			InsertPoints inf, 1, T_sweep,T_tem,T_I0
			
			T_sweep[binindex]=return_xwave_info(tempimage,6) //sweep
			T_tem[binindex]=return_xwave_info(tempimage,2)  //tem
			//added by sdc
			T_I0[binindex]=return_xwave_info(tempimage,7) //beamcurrent
			//sdc
			if (interpflag)
				T_spectra[][]+=interp2D(tempimage,x,y)*T_sweep[binindex]
			else
				T_spectra[][]+=tempimage[p][q]*T_sweep[binindex]
			endif

			string lastname=nameofwave(data)
			
			index+=1
			binindex+=1
		while (1)
		
		//edited by sdc
		
		duplicate/o T_tem T_tem_2
		duplicate/o T_I0 T_I0_2
		
		T_I0_2=T_I0[p]*T_sweep[p]
		T_tem_2=T_tem[p]*T_sweep[p]
		
		Variable sumsweep=sum(T_sweep)
		Variable meanTem=sum(T_tem_2)/sumsweep
		Variable meanI0=sum(T_I0_2)/sumsweep
		T_spectra/=sumsweep
		
		//
		notestr=replacenumberbykey("SampleTemperature",notestr,meantem,"=","\r")
		notestr=replacenumberbykey("BeamCurrent",notestr,meanI0,"=","\r")
		notestr=replacenumberbykey("NumberOfSweeps",notestr,sumsweep,"=","\r")
		
		Variable temppos=strsearch(firstname,"_",inf,1)
		Variable firstnum=str2num(firstname[temppos+1,inf])
		Variable lastnum=str2num(lastname[temppos+1,inf])
		String basename=firstname[0,temppos]
		
		if ((numtype(firstnum)==2)||(numtype(lastnum)==2))
			String savename=firstname
		else
			sprintf savename,"%s_%04.f_%04.f",basename,firstnum,lastnum
		endif
		
		Duplicate /o T_spectra,$savename
		Wave Savewave=$savename
		
		notestr=replacestringbykey("WaveName",notestr,savename,"=","\r")
		
		Note Savewave,notestr
		
		InitialprocNotestr2D(Savewave,"rawData")
		
		redimension /N=(nx,ny,1) Savewave
		
		Zindex+=1
	while (1)
	
	Killwaves /Z T_sweep,T_tem,T_spectra,w_x0,w_x1,w_dx,w_y0,w_y1,w_dy,tempimage
	
	index=0
	do
		wave_path=Stringfromlist(index,Waverebin_list,";")
		if(strlen(wave_path)==0)
			break
		endif
		wave data = $wave_path
		MoveWave data, $(DFfolder+":")
		index+=1
	while(1)
	
	
	
	SetDatafolder DF
	
End



Function wave_delfrompanel_proc(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderDFR()
	String panelname=winname(0,65)
	String DF_panel="root:internalUse:"+panelName
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	
	SVAR sourcePathlist=DFR_common:gs_sourcePathlist
	SVAR sourcenamelist=DFR_common:gs_sourcenamelist
	SVAR toppath=DFR_common:gs_TopItemPath
	SVAR topName = DFR_common:gs_TopItemName
	SVAR DFlist=DFR_common:gs_DFlist
	NVAR toplayernum=DFR_common:gv_toplayernum
	NVAR topwaverow=DFR_common:gv_topwaverow
	NVAR topdfrow=DFR_common:gv_topdfrow
	WAVE/t w_DF=DFR_common:w_DF
	WAVE/t w_sourceNames=DFR_common:w_sourceNames
	Wave/b w_sourceNamesSel=DFR_common:w_sourceNamesSel
	
	Variable index=0
	String wave_path,wave_name,dwave_name
	Variable tempsel
	
	Variable allflag=0

	do 
	
		if ((w_sourceNamesSel[index] == 1)||(w_sourceNamesSel[index] == 8)||(w_sourceNamesSel[index]==9))
			toppath=w_DF[topdfrow]+w_sourceNames[index]
			topname=w_sourceNames[index]
			tempsel=w_sourceNamesSel[index]
			w_sourceNamesSel[index]=0
	
			if (strlen(toppath)==0)
				break
			endif
			wave_path=toppath
	
			Wave data=$wave_path
		
			if (allflag!=1)
				doalert 2,"Delete "+topname+"?"
				IF (v_Flag==3)
					w_sourceNamesSel[index]=tempsel
					SetDatafolder DF
					return 0
				elseif (V_Flag==1)
					if (allflag!=-1)
						doalert 1,"Delete  all select waves?"
						if (V_flag==1)
							allflag=1
						else
							allflag=-1
						endif
					endif
					
					Killwaves /Z data
				endif
			else
				Killwaves /Z data
			endif
			
				w_sourceNamesSel[index]=tempsel
		endif
	
	index+=1
	while (index<numpnts(w_sourceNamesSel))
	
	source_Listbox_Proc("global_waves_list", topwaverow, 0, 4)
	
End

Function main_wave_save_proc(ctrlname)
	String Ctrlname
	String panelname=winname(0,65)
	String DFS_panel="root:internalUse:"+panelName
	String DFS_common="root:internalUse:"+panelName+":panel_common"
	DFREF DFR_common=$DFS_common
	DFREF DF_panel=$DFS_panel
	SetActiveSubwindow $winname(0,65)	
	
	SVAR sourcePathlist=DFR_common:gs_sourcePathlist
	SVAR sourcenamelist=DFR_common:gs_sourcenamelist
	SVAR toppath=DFR_common:gs_TopItemPath
	SVAR topName = DFR_common:gs_TopItemName
	SVAR DFlist=DFR_common:gs_DFlist
	NVAR toplayernum=DFR_common:gv_toplayernum
	NVAR topwaverow=DFR_common:gv_topwaverow
	NVAR topdfrow=DFR_common:gv_topdfrow
	WAVE/t w_DF=DFR_common:w_DF
	WAVE/t w_sourceNames=DFR_common:w_sourceNames
	Wave/b w_sourceNamesSel=DFR_common:w_sourceNamesSel
		
	initialdialogwindow()
	DFREF DF_userpanel=root:InternalUse:User_panel
	NVAR processallflag=DF_userpanel:gv_processallflag	
	NVAR autoprocessflag=DF_userpanel:gv_autoprocessflag
	SVAR suffix=DF_userpanel:gs_suffix
	SVAR new_wavename=DF_userpanel:gs_new_wavename
	
	
	if (stringmatch(ctrlname,"source_svbt0"))
		Variable moveflag=1
	else
		moveflag=0
	endif
		
	controlinfo source_pop3
	if (v_value>2)
		String saveDF="root:spectra:"+s_value
	else
		saveDF="root:"+s_value
	endif
	
	
	Variable index=0
	String wave_path,wave_name,dwave_name
	Variable tempsel
	Variable topsel=nan

	do 
	
		if ((w_sourceNamesSel[index] == 1)||(w_sourceNamesSel[index] == 8)||(w_sourceNamesSel[index]==9))
			toppath=w_DF[topdfrow]+w_sourceNames[index]
			topname=w_sourceNames[index]
			tempsel=w_sourceNamesSel[index]
			w_sourceNamesSel[index]=0
	
			topsel=(numtype(topsel)==2)?(index):(topsel)
	
			if (strlen(toppath)==0)
				break
			endif
			wave_path=toppath
	
			Wave data=$wave_path
			GetProList(DFR_common,data,NAN)
			Panelimageupdate(3)
	
			dwave_name=saveDF+topname
			Variable overwriteflag=1
			Variable processRawflag=0
			do
				if (waveexists($dwave_name))
					if (processallflag==0)
						Setdialogwindow(winname(0,65),data,s_value[0,(strlen(s_value)-2)])
						openautosavewindow(winname(0,65))
					endif
					switch (autoprocessflag)
						case 0:
							dwave_name=wave_path
							overwriteflag=0
							processRawflag=0
							break
						case 1:
							dwave_name=saveDF+topname
							overwriteflag=0
							processRawflag=0
							break
						case 2:
							dwave_name=saveDF+topname+"_"+suffix
							processRawflag=0
							break
						case 3:
							dwave_name=saveDF+new_wavename
							processRawflag=0
							break
						case 4:
							dwave_name=saveDF+topname
							overwriteflag=0
							processRawflag=1
							break
					endswitch
				else
					break
				endif
			while (overwriteflag)
			
			if (processRawflag)
				Wave newData=$(dwave_name)
				String rawnotestr=GetLayernotestr(note(newData),1,2)
				duplicate /o data,$(dwave_name)
				if (moveflag)
					killwaves /Z data
				endif
				Wave newData=$(dwave_name)
				set_proc_layer(newData,0) //reset to raw
				
				macro_autoprocess(dwave_name,rawnotestr,0,1,0)
			else
	
				if (stringmatch(wave_path,dwave_name)==0)
					duplicate /o data,$(dwave_name)
					if (moveflag)
						killwaves /Z data
					endif
				endif
			endif
	
			if (moveflag==0)
				w_sourceNamesSel[index]=tempsel
			endif
		endif
	
	index+=1
	while (index<numpnts(w_sourceNamesSel))
	
	topsel=(topsel<0)?(0):topsel
	if (moveflag==1)
		w_sourceNamesSel[topsel]=1
	endif
	
	
	source_Listbox_Proc("global_waves_list", topwaverow, 0, 4)
	
End











