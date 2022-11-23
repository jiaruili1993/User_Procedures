#pragma rtGlobals=1		// Use modern global access method.
#pragma version=0.01
#pragma ModuleName = BZpanel

/////////////////////////////////global panel Function ////////////////////////////////////////

Function MyBZpanelHook(s)
	STRUCT WMWinHookStruct &s
	
	Variable hookResult = 0	// 0 if we do not handle event, 1 if we handle it.
   	String wname=s.winName
	switch(s.eventCode)
		case 5:
			Variable VP=s.mouseLoc.v
			Variable HP=s.mouseLoc.h
			if (VP>0)
				Variable Ky=AxisValFromPixel(wname, "left", VP)
				Variable Kx=AxisValFromPixel(wname, "bottom", HP)
				String trname=SelectPossibleCuts(wname,kx,ky)
				if (strlen(trname)>0)
					DFREF DFR_panel=$("root:internaluse:"+wname)
					SVAR gs_Cuts_selname=DFR_panel:gs_Cuts_selname
					gs_Cuts_selname=trname
					BZpanel#update_Cutskxky_sel(3)
				endif
			endif
			break
		case 2:
			String DF_panel="root:internaluse:"+wname
			Deleteallingraph(wname,0)
			KillDatafolder /Z $DF_panel
			break
		case 17:
			DF_panel="root:internalUse:"+wname
			DFREF DFR_panel=$DF_panel
			NVAR killflag=DFR_panel:gv_killflag
			if (killflag)
				return 0
			else
				print "Hide window "+wname
				Dowindow /HIDE=1 $wname
				return 2
			endif
			break
		case 11:
			if (s.keycode==99)
				String new_wname,based_wname
				Variable temp=strsearch(wname,"panel_",0,2)
				based_wname=wname[0,temp+5]
				new_wname=wname[temp+6,inf]
						
				prompt new_wname,"Save panel as name: "+based_wname
				Doprompt "Save panel as:",new_wname
				if (V_flag==0)
					new_wname=based_wname+new_wname
					if (whichlistitem(new_wname,WinList("*",";",""),";",0)>=0)
						doalert 0, "Error: ilegal graph name." 
						hookResult=0
						break
					endif
					
					if (ChangeGraphDatafolder(wname,new_wname,1))
						dowindow /C /W=$wname $new_wname
						dowindow /T $new_wname new_wname
					else
						doalert 0,"Waves not in the same DF!"
						hookResult=0
						break
					endif
				endif
			endif
			
			if (s.keycode==104)
				Dowindow /HIDE=1 $wname
				print "Hide window "+wname
			endif
		break
	endswitch
	return hookResult	// If non-zero, we handled event and Igor will ignore it.
End


Function /DF Init_BZ_panel()
	DFREF DF=GetDataFolderDFR()

	String DF_panel="root:internalUse:"+winname(0,65)
	NewDataFolder/O/S $DF_panel
	newDatafolder /o CutKxky
	DFREF DFR_panel=$DF_panel

	Variable /G gv_killflag=0

	Variable /G gv_A1,gv_B1,gv_C1
	Variable /G gv_PL
	Variable /G gv_BZh,gv_BZl,gv_BZk
	Variable /G gv_BZ_3d_dk=0.03
	Variable /G gv_CutangleF=-15
	Variable /G gv_CutangleT=15
	Variable /G gv_sliceF,gv_sliceT,gv_slicenum=1
	Variable /G gv_th,gv_ph,gv_azi,gv_deflectorY
	
	Variable /G gv_BZ_rotate
	//Variable /G gv_photonE=21.2
	//Variable /G gv_wf=4.4
	Variable /G gv_angmodeflag=1
	Variable /G gv_angIntflag=0
	
	/////for add multi cuts
	String /G gs_theta
	String /G gs_phi
	String /G gs_azi
	String /G gs_photonE
	Variable /G gv_angdelta=2
	
	Variable /G gv_curveflag
	
	Variable /G gv_autoFSMflag=0
	String /G gs_autoFSMname=""
	
	
	///tightbinding////
	
	String/G gs_BZ_equal
	gs_BZ_equal="Txx * ( cos(x) + cos(y) ) + Txy * ( cos(x) * cos(y) )"
	//gs_BZ_equal="2.8 * sqrt(3+ 2*cos(sqrt(3)*x) + 4*cos(sqrt(3)/2*x)*cos(1.5*y)) - 0.1* (2*cos(sqrt(3)*x) + 4*cos(sqrt(3)/2*x)*cos(1.5*y))"
	
	Variable/G gv_BZ_tig_ES=0
	Variable/G gv_BZ_tig_EE=1
	Variable/G gv_BZ_tig_steps=4
	Variable/G gv_num_tightBind=0
	Variable/G gv_BZ_tig_VEF=0
	Variable /G gv_BZ_tig_kxpi=1
	Variable /G gv_BZ_tig_kypi=1
	Variable /G gv_BZ_tig_kzpi=1
	
	Variable /G gv_BZ_tig_kxrange=1
	Variable /G gv_BZ_tig_kyrange=1
	Variable /G gv_BZ_tig_kzrange=1
	Variable /G gv_BZ_tig_kdensity=0.01
	
	gv_A1=0
	gv_B1=0
	gv_C1=1
	gv_PL=0
	gv_Bzh=0
	gv_BZl=0
	gv_BZk=0
	Make /o/n=(1,3) BZlist
	BZlist=0
	Make /o/T/n=1 BZ_displist
	Make /o/n=1 BZ_displist_sel
	BZ_displist="0,0,0"
	BZ_displist_sel=0
	
	Make /o/n=1 YCuts_sel
	Make /o/n=1 XCuts_sel
	String /G gs_Cuts_selname
	
	Make /o/T/n=1 BZ_tig_bandlist
	Make /o/T/n=2 BZ_tig_parlist
	Make /o/B/n=1 BZ_tig_bandlist_sel
	Make /o/B/n=2 BZ_tig_parlist_sel
	
	BZ_tig_bandlist[0]=gs_BZ_equal
	BZ_tig_parlist[0]="Txx=-0.707"
	BZ_tig_parlist[1]="Txy=0.48"
	
	BZ_tig_parlist_sel=2
	BZ_tig_bandlist_sel=2
	
	Setdatafolder DF
	return DFR_panel
	
End

Function close_BZ_panel(ctrlname)
	String ctrlName
	String wname=winName(0,65)
	String DF_panel="root:internalUse:"+wname
		DFREF DFR_panel=$DF_panel
		NVAR killflag=DFR_panel:gv_killflag
		killflag=1
	dowindow/K $wname
End


Function open_BZ_panel(ctrlName)
	String ctrlName
	
	DFREF DF = GetDataFolderDFR()
		
	Variable SC = ScreenSize(5)
	//Variable SR = ScreenSize(3) * SC
	//Variable ST = ScreenSize(2) * SC
	//Variable SL = ScreenSize(1) * SC
   // Variable SB = ScreenSize(4) * SC
    	Variable SR = Igorsize(3) 
	Variable ST = Igorsize(2)
	Variable SL = Igorsize(1)
  	  Variable SB = Igorsize(4)
  	  	
    	DFREF DFR_prefs=$DF_prefs
    	NVAR panelscale=DFR_prefs:gv_panelscale
    	NVAR macscale=DFR_prefs:gv_macscale
    	
	Variable Width = 540 *panelscale*macscale		// panel size  
	Variable height = 500*panelscale*macscale		// * SC
	Variable xOffset = (SR-SL)/2-width/2
	Variable yOffset = (SB-ST)/2-height/2
	
	String panelnamelist=winlist("BZ_panel_*",";","WIN:65")
	
	if (stringmatch(ctrlname,"recreate_window")==0)
	
		if (strlen(panelnamelist)>0)
			if (stringmatch(ctrlname,"global_duplicate_panel"))
				String spwinname=UniqueName("BZ_panel_", 9, 0)
 				display /W=(xOffset, yOffset,xOffset+width,Height+yOffset) as spwinname
				DoWindow/C $spwinname
   				Setwindow $spwinname hook(MyHook) = MyBZpanelHook
			else
				 BringUP_Allthepanel(panelnamelist,0)
				//Proc_bt_readfrommap("DrawCuts_bt1")
				SetDatafolder DF
				return 1
			endif
		else
			spwinname=UniqueName("BZ_panel_", 9, 0)
 			display /W=(xOffset, yOffset,xOffset+width,Height+yOffset) as spwinname
			DoWindow/C $spwinname
   			Setwindow $spwinname hook(MyHook) = MyBZpanelHook
   		endif
   		
   		 DFREF DFR_panel=init_BZ_panel()
	else
		BringUP_thefirstpanel(panelnamelist)
   		DFREF DFR_panel=$("root:internalUse:"+winname(0,65))
   		SetActiveSubwindow $winname(0,65)
   	endif
    
    	controlbar 270*SC
    
  
    	DFREF DFR_load=$DF_global
    
    
   	NVAR gv_BZtype=DFR_load:gv_BZtype
   
   	NVAR gV_uca=DFR_load:gv_uca
   	NVAR gV_ucb=DFR_load:gv_ucb
   	NVAR gV_ucc=DFR_load:gv_ucc
   
   	NVAR gV_alphaA=DFR_load:gv_alphaA
   	NVAR gv_betaA=DFR_load:gv_betaA
   	NVAR gv_gammaAA=DFR_load:gv_gammaAA
 	//  NVAR gv_sampleOrientation=DFR_load:gv_sampleOrientation
    
   	NVAR gv_gammaA=DFR_load:gv_gammaA
   	NVAR gv_innerE=DFR_load:gv_innerE
   	NVAR gv_samthetaoff=DFR_load:gv_samthetaoff
   	NVAR gv_samphioff=DFR_load:gv_samphioff
   	NVAR gv_samazioff=DFR_load:gv_samazioff
   
   	NVAR gv_photonE=DFR_load:gv_photonE
   	NVAR gv_workfn=DFR_load:gv_workfn
   
   	NVAR gv_autosynflag=DFR_load:gv_autosynflag
   
   	//NVAR gv_angintflag=DFR_panel:gv_angintflag
   
    	SetDatafolder DFR_panel
    	String DF_panel=Getdatafolder(1)
    
	Variable r=57000, g=57000, b=57000
	ModifyGraph cbRGB=(54428,54428,54428)
	ModifyGraph wbRGB=(48896,59904,65280), gbRGB=(48896,59904,65280)
	//ModifyGraph wbRGB=(48896,65280,57344),gbRGB=(48896,65280,57344)
	Button global_bt0,pos={500*SC,4*SC},size={80*SC,18*SC},title="close",labelBack=(r,g,b),proc=close_BZ_panel
	Button global_duplicate_panel, pos={590*SC,4*SC},size={70*SC,18*SC},title="duplicate", proc=Open_BZ_Panel
	
	Button global_gold, size={40*SC,20*SC},pos={670*SC,25*SC}, title="gold", proc=open_gold_panel
	Button global_main, size={40*SC,20*SC},pos={670*SC,55*SC}, title="main", proc= Open_main_Panel
	Button global_map, size={40*SC,20*SC},pos={670*SC,85*SC}, title="map", proc= open_mapper_panel
	//Button global_BZ, size={40,20},pos={665,115}, title="BZ", proc=open_bz_panel
   // Button global_opdt,labelBack=(r,g,b),pos={665,145},size={40,20},fsize=12,title="DataT",proc=open_data_table
	Button global_Anal, size={40*SC,20*SC},pos={670*SC,115*SC}, title="Anal", proc=Open_Analysis_Panel
	Button global_Merge, size={40*SC,20*SC},pos={670*SC,145*SC}, title="Merge", proc=Open_Merge_Panel
	Button global_Fit, size={40*SC,20*SC},pos={670*SC,175*SC}, title="Fit", proc=open_fit_panel
	
	CheckBox global_ck10, pos={20*SC,250*SC}, title="lock aspect",value=1,proc=lock_aspect
	
	TabControl BZpanel,proc=BZpanel#BZ_panel_AutoTab_proc, pos={8*SC,6*SC},size={655*SC,240*SC},value=0,labelBack=(r,g,b)
    
    	TabControl BZpanel,tabLabel(0)="DrawBZ"
	
   	Groupbox DrawBZ_gb2,frame=0,pos={30*SC,30*SC},size={210*SC,210*SC},title="sample settings:"
   	SetVariable DrawBZ_sv1,pos={40*SC,50*SC},size={80*SC,15*SC},labelBack=(r,g,b),title="a:", value = gv_uca,limits={0,Inf,0},proc=Check_BZ_par
   	SetVariable DrawBZ_sv2,pos={40*SC,80*SC},size={80*SC,15*SC},labelBack=(r,g,b),title="b:", value = gv_ucb,limits={0,Inf,0},proc=Check_BZ_par
   	SetVariable DrawBZ_sv3,pos={40*SC,110*SC},size={80*SC,15*SC},labelBack=(r,g,b),title="c:", value = gv_ucc,limits={0,Inf,0},proc=Check_BZ_par
   	SetVariable DrawBZ_sv4,pos={130*SC,50*SC},size={100*SC,15*SC},labelBack=(r,g,b),title="alpha:", value = gv_alphaA,limits={0,90,0},proc=Check_BZ_par
   	SetVariable DrawBZ_sv14,pos={130*SC,80*SC},size={100*SC,15*SC},labelBack=(r,g,b),title="beta:", value = gv_betaA,limits={0,90,0},proc=Check_BZ_par
   	SetVariable DrawBZ_sv15,pos={130*SC,110*SC},size={100*SC,15*SC},labelBack=(r,g,b),title="gamma:", value = gv_gammaAA,limits={0,90,0},proc=Check_BZ_par
  	SetVariable DrawBZ_sv6,pos={40*SC,140*SC},size={80*SC,15*SC},labelBack=(r,g,b),title="BZ_Rot:", value = gv_BZ_rotate,limits={-Inf,Inf,1},Proc=BZpanel#Updata_BZ_SV
   	PopupMenu DrawBZ_pp6,pos={130*SC,137*SC},size={70*SC,15*SC},labelBack=(r,g,b),mode=gv_BZtype,title="type:",value="Simple;BCC;FCC;TCC",Proc=BZpanel#SetBZtype
   	Button DRawBZ_bt0,pos={40*SC,180*SC},size={80*SC,20*SC},labelBack=(r,g,b),title="Bz_update",Proc=BZpanel#Proc_bt_updateBZ_proc
   	Button DRawBZ_bt01,pos={40*SC,205*SC},size={80*SC,20*SC},labelBack=(r,g,b),title="Plot BZ",Proc=BZpanel#Proc_bt_displayBZ_proc
 	Button DRawBZ_bt02,pos={130*SC,205*SC},size={80*SC,20*SC},labelBack=(r,g,b),title="Append BZ",Proc=BZpanel#Proc_bt_displayBZ_proc
   	Checkbox DRawBZ_bck0,pos={140*SC,183*SC},size={40*SC,20*SC},value=0,title="D1", proc=BZpanel#Proc_ck_updateCrossBZ
   	Checkbox DRawBZ_bck1,pos={180*SC,183*SC},size={40*SC,20*SC},value=0,title="D2", proc=BZpanel#Proc_ck_updateCrossBZ
   
   

   	Groupbox DrawBZ_gb1,frame=0,pos={250*SC,30*SC},size={230*SC,210*SC},title="BZ settings:"
   	SetVariable DrawBZ_sv7,pos={260*SC,50*SC},size={60*SC,15*SC},labelBack=(r,g,b),title="H:", value = gv_A1,limits={-Inf,Inf,1}
  	SetVariable DrawBZ_sv8,pos={330*SC,50*SC},size={60*SC,15*SC},labelBack=(r,g,b),title="L:", value = gv_B1,limits={-Inf,Inf,1}
   	SetVariable DrawBZ_sv9,pos={400*SC,50*SC},size={60*SC,15*SC},labelBack=(r,g,b),title="K:", value = gv_C1,limits={-Inf,Inf,1}
   	SetVariable DrawBZ_sv10,pos={260*SC,80*SC},size={60*SC,15*SC},labelBack=(r,g,b),title="PL:", value = gv_PL,limits={0,inf,0}
   	slider  DrawBZ_sl0,pos={330*SC,80*SC},size={140*SC,15*SC},labelBack=(r,g,b),vert=0,title="",ticks=0,limits={0,2*pi/gv_ucc,0.005},variable=gv_PL,Proc=BZpanel#Updata_BZ_SL
   
   	SetVariable DrawBZ_sv11,pos={260*SC,110*SC},size={60*SC,15*SC},labelBack=(r,g,b),title="i:", value = gv_BZh,limits={-Inf,Inf,1}
   	SetVariable DrawBZ_sv12,pos={330*SC,110*SC},size={60*SC,15*SC},labelBack=(r,g,b),title="j:", value = gv_BZl,limits={-Inf,Inf,1}
   	SetVariable DrawBZ_sv13,pos={400*SC,110*SC},size={60*SC,15*SC},labelBack=(r,g,b),title="k:", value = gv_BZk,limits={-Inf,Inf,1} 
   	Listbox DrawBZ_lb0,pos={260*SC,140*SC},size={80*SC,90*SC},labelBack=(r,g,b),mode=2,listWave=BZ_displist,selwave=BZ_displist_sel,proc=BZpanel#proc_lb_SelBZdisp
   	Button DRawBZ_bt1,pos={360*SC,150*SC},size={80*SC,20*SC},labelBack=(r,g,b),title="Add",Proc=BZpanel#Proc_bt_AddPointBZ
   	Button DRawBZ_bt2,pos={360*SC,180*SC},size={80*SC,20*SC},labelBack=(r,g,b),title="Del",Proc=BZpanel#Proc_bt_delPointBZ
       Button DRawBZ_adddc,pos={360*SC,210*SC},size={80*SC,20*SC},labelBack=(r,g,b),title="Show DC",Proc=BZpanel#add_BZ_DCs
   
   	Groupbox DrawBZ_gb3,frame=0,pos={500*SC,30*SC},size={140*SC,170*SC},title="Default settings:"
   	Button DRawBZ_bt3,pos={510*SC,50*SC},size={120*SC,20*SC},labelBack=(r,g,b),title="kxky(001)_gamma",Proc=BZpanel#Proc_bt_SetDefaultBZ
   	Button DRawBZ_bt7,pos={510*SC,80*SC},size={120*SC,20*SC},labelBack=(r,g,b),title="kxky(001)_Z",Proc=BZpanel#Proc_bt_SetDefaultBZ
   
   	Button DRawBZ_bt4,pos={510*SC,110*SC},size={120*SC,20*SC},labelBack=(r,g,b),title="kxkz(010)_--",Proc=BZpanel#Proc_bt_SetDefaultBZ
   	Button DRawBZ_bt5,pos={510*SC,140*SC},size={120*SC,20*SC},labelBack=(r,g,b),title="kykz(100)_|",Proc=BZpanel#Proc_bt_SetDefaultBZ
   	Button DRawBZ_bt6,pos={510*SC,170*SC},size={120*SC,20*SC},labelBack=(r,g,b),title="kxky-kz(110)_/",Proc=BZpanel#Proc_bt_SetDefaultBZ
   	
  	SetVariable DrawBZ_sv16,pos={500*SC,210*SC},size={60*SC,20*SC},labelBack=(r,g,b),title="dk:", value = gv_BZ_3d_dk,limits={0,Inf,0} 
  
   	Button DRawBZ_bt8,pos={565*SC,208*SC},size={80*SC,20*SC},labelBack=(r,g,b),title="3D plot",Proc=BZpanel#Proc_bt_3DplotBZ
   
   	TabControl BZpanel,tabLabel(1)="DrawCuts"
   
   	Groupbox DrawCuts_gb1, frame=0,pos={30*SC,30*SC}, size={230*SC,135*SC}, disable=1,title="Range setup"
   	Checkbox DrawCuts_ck01,pos={40*SC,50*SC},size={90*SC,18*SC}, disable=1,title="Angle",value=1,proc=BZpanel#Proc_ck_Changerangemode
   	SetVariable DrawCuts_sv01,pos={40*SC,75*SC},size={100*SC,18*SC}, disable=1,limits={-inf,inf,1},title="AngleF",value=gv_CutangleF,proc=BZpanel#Proc_sv_checkangerror_BZ
   	SetVariable DrawCuts_sv02,pos={40*SC,97.5*SC},size={100*SC,18*SC}, disable=1,limits={-inf,inf,1},title="AngleT",value=gv_CutangleT,proc=BZpanel#Proc_sv_checkangerror_BZ
   	popupmenu  DrawCuts_pp1,pos={40*SC,140*SC},size={90*SC,15*SC},disable=1,title="Mode:",mode=1,value="Ang30;Ang14;", proc=BZpanel#Proc_angmodechange
   	Button DrawCuts_bt01,pos={40*SC,120*SC},size={90*SC,15*SC},disable=1,title="Read Range",Proc=BZpanel#Proc_bt_ReadCSR_BZ

   	Button DrawCuts_bt0,pos={140*SC,140*SC},size={110*SC,20*SC},disable=1,title="Read CSR_MainP",Proc=BZpanel#Proc_bt_ReadCSR_BZ
   	Checkbox DrawCuts_ck02,pos={150*SC,50*SC},size={90*SC,18*SC}, disable=1,title="Slice",proc=BZpanel#Proc_ck_Changerangemode
   	Checkbox DrawCuts_ck03,pos={220*SC,50*SC},size={20*SC,18*SC},title="I",disable=1,variable=gv_angintflag
   	SetVariable DrawCuts_sv03,pos={150*SC,75*SC},size={100*SC,18*SC}, disable=1,limits={0,inf,1},title="SliceF",value=gv_SliceF,Proc=BZpanel#Proc_sv_checksliceerror_BZ
   	SetVariable DrawCuts_sv04,pos={150*SC,97.5*SC},size={100*SC,18*SC}, disable=1,limits={0,inf,1},title="SliceT",value=gv_SliceT,Proc=BZpanel#Proc_sv_checksliceerror_BZ
   	SetVariable DrawCuts_sv15,pos={150*SC,120*SC},size={100*SC,18*SC}, disable=1,limits={1,inf,1},title="SliceNum",value=gv_slicenum,Proc=BZpanel#Proc_sv_checksliceerror_BZ
   	Groupbox DrawCuts_gb3, frame=0,pos={30*SC,170*SC}, size={230*SC,70*SC}, disable=1,title="Energy setup"
   	SetVariable DrawCuts_sv10,pos={40*SC,190*SC},size={120*SC,18*SC},disable=1,limits={0,inf,1},title="PhotonE:", value= gv_PhotonE//,proc=BZpanel#Auto_AddCuts
	SetVariable DrawCuts_sv11,pos={160*SC,190*SC},size={90*SC,18*SC},disable=1,limits={0,inf,1},title="WF:", value= gv_workfn 
   	SetVariable DrawCuts_sv09,pos={40*SC,215*SC},size={120*SC,18*SC},disable=1,limits={0,inf,1},title="InnerE(eV):",Value=gv_innerE
	
   
   	Groupbox DrawCuts_gb2,frame=0, pos={270*SC,30*SC}, size={210*SC,210*SC}, disable=1,title="Cuts setup"
    	SetVariable DrawCuts_sv05,pos={280*SC,50*SC},size={90*SC,18*SC}, disable=1,limits={-inf,inf,1},title="Theta:", value= gv_th//,proc=BZpanel#Auto_AddCuts
	SetVariable DrawCuts_sv06,pos={280*SC,70*SC},size={90*SC,18*SC}, disable=1,limits={-inf,inf,1},title="Phi:", value= gv_ph//,proc=BZpanel#Auto_AddCuts
	SetVariable DrawCuts_sv07,pos={280*SC,90*SC},size={90*SC,18*SC}, disable=1,limits={-inf,inf,1},title="Azi:", value= gv_azi//,proc=BZpanel#Auto_AddCuts
	SetVariable DrawCuts_sv08,pos={280*SC,130*SC},size={90*SC,18*SC}, disable=1,limits={0,inf,1},title="Gamma:", value= gv_gammaA//,proc=AddDataVar
	
	
	SetVariable DrawCuts_sv256,pos={280*SC,110*SC},size={90*SC,18*SC}, disable=1,limits={-inf,inf,1},title="Deflector:", value= gv_DeflectorY//,proc=AddDataVar
	
	
	
	SetVariable DrawCuts_sv12,pos={380*SC,50*SC},size={90*SC,18*SC},disable=1,limits={-inf,inf,1},title="ThetaOff",value=gv_SamThetaOff
	SetVariable DrawCuts_sv13,pos={380*SC,70*SC},size={90*SC,18*SC},disable=1,limits={-inf,inf,1},title="PhiOff",value=gv_SamPhiOff
	SetVariable DrawCuts_sv14,pos={380*SC,90*SC},size={90*SC,18*SC},disable=1,limits={-inf,inf,1},title="AziOff",value=gv_SamAziOff
	Button DrawCuts_bt1,pos={425*SC,110*SC},size={50*SC,18*SC},disable=1,title="Re_Map", proc=BZpanel#Proc_bt_readfrommap
	Button DrawCuts_bt111,pos={375*SC,110*SC},size={50*SC,18*SC},disable=1,title="Re_Sel", proc=BZpanel#Proc_bt_readfrommap
	
	Button DrawCuts_FSMremove size={60*SC,18*SC},pos={415*SC,135*SC}, disable=1,title="Del FSM",  proc=BZpanel#Proc_removeFSM_to_BZ
	//titlebox DrawCuts_tb2,pos={340*SC,140*SC},size={40*SC,20*SC},disable=1,title="Sync",frame=0
	Checkbox DrawCuts_ck04,pos={370*SC,130*SC},size={130*SC,18*SC},title="kxky",disable=1,value=0,proc=BZpanel#Proc_ck_autosynck
	Checkbox DrawCuts_ck05,pos={370*SC,145*SC},size={130*SC,18*SC},title="kz",disable=1,value=0,proc=BZpanel#Proc_ck_autosynck
	
	Checkbox DrawCuts_ck08,pos={280*SC,188*SC},size={90*SC,18*SC},title="3D",disable=1,value=0
	Button DrawCuts_BZremoveall size={60*SC,20*SC},pos={410*SC,185*SC}, disable=1,title="RemoveAll",  proc=BZpanel#Proc_remove_to_BZ
	Button DrawCuts_BZremove size={60*SC,20*SC},pos={343*SC,185*SC}, disable=1,title="Remove",  proc=BZpanel#Proc_remove_to_BZ
	
	Button DrawCuts_BZAddCut size={60*SC,20*SC},pos={275*SC,162*SC}, disable=1,title="Add_kxky",  proc=BZpanel#Proc_add_cut_to_BZ
	Button DrawCuts_BZAddZCut size={60*SC,20*SC},pos={343*SC,162*SC},disable=1, title="Add_kz", proc=BZpanel#Proc_add_cut_to_BZ
	Button DrawCuts_BZAddMapCut size={60*SC,20*SC},pos={410*SC,162*SC},disable=1, title="Add_map", proc=BZpanel#Proc_add_cut_to_BZ
	
	
	Checkbox DrawCuts_ck09,pos={280*SC,215*SC},size={90*SC,18*SC},title="Curve",disable=1,variable =gv_curveflag
	
	//titlebox DrawCuts_tb5,pos={280*SC,215*SC},size={40*SC,20*SC},disable=1,title="Disp Cuts:",frame=0
	Button DrawCuts_BZAppendCut size={60*SC,20*SC},pos={343*SC,213*SC}, disable=1,title="App Sel",  proc=BZpanel#Proc_bt_appendCuts
	Button DrawCuts_BZAppendAllCut size={60*SC,20*SC},pos={410*SC,213*SC},disable=1, title="App all", proc=BZpanel#Proc_bt_appendCuts
	
  	 Groupbox DrawCuts_gb4,frame=0, pos={490*SC,30*SC}, size={165*SC,210*SC}, disable=1,title="Auto Cut"
   	titlebox DrawCuts_tb0,pos={505*SC,55*SC}, size={40*SC,20*SC},disable=1, title="kx-ky BZ",frame=0
   	Button DrawCuts_bt2,pos={555*SC,75*SC}, size={40*SC,20*SC}, disable=1,title="(000)",proc=BZpanel#Proc_bt_AutoCut_BZ
   	Button DrawCuts_bt3,pos={510*SC,75*SC}, size={40*SC,20*SC}, disable=1,title="(-100)",proc=BZpanel#Proc_bt_AutoCut_BZ
   	Button DrawCuts_bt4,pos={600*SC,75*SC}, size={40*SC,20*SC}, disable=1,title="(100)",proc=BZpanel#Proc_bt_AutoCut_BZ
   	Button DrawCuts_bt5,pos={555*SC,50*SC}, size={40*SC,20*SC},disable=1, title="(010)",proc=BZpanel#Proc_bt_AutoCut_BZ
   	Button DrawCuts_bt6,pos={555*SC,100*SC}, size={40*SC,20*SC},disable=1, title="(0-10)",proc=BZpanel#Proc_bt_AutoCut_BZ
   
   	titlebox DrawCuts_tb1,pos={505*SC,125*SC}, size={40*SC,20*SC},disable=1, title="kz BZ",frame=0
   	Button DrawCuts_bt7,pos={555*SC,162*SC}, size={40*SC,20*SC}, disable=1,title="(000)",proc=BZpanel#Proc_bt_AutoCutZ_BZ
   	Button DrawCuts_bt8,pos={555*SC,140*SC}, size={40*SC,20*SC}, disable=1,title="(001)",proc=BZpanel#Proc_bt_AutoCutZ_BZ
   	Button DrawCuts_bt9,pos={600*SC,162*SC}, size={40*SC,20*SC}, disable=1,title="(100)",proc=BZpanel#Proc_bt_AutoCutZ_BZ
   	Button DrawCuts_bt10,pos={600*SC,140*SC}, size={40*SC,20*SC}, disable=1,title="(101)",proc=BZpanel#Proc_bt_AutoCutZ_BZ
   	Button DrawCuts_bt13,pos={510*SC,162*SC}, size={40*SC,20*SC}, disable=1,title="(-100)",proc=BZpanel#Proc_bt_AutoCutZ_BZ
   	Button DrawCuts_bt14,pos={510*SC,140*SC}, size={40*SC,20*SC}, disable=1,title="(-101)",proc=BZpanel#Proc_bt_AutoCutZ_BZ
   	Button DrawCuts_bt15,pos={555*SC,185*SC}, size={40*SC,20*SC}, disable=1,title="(00-1)",proc=BZpanel#Proc_bt_AutoCutZ_BZ
   	Button DrawCuts_bt16,pos={510*SC,185*SC}, size={40*SC,20*SC}, disable=1,title="(-10-1)",proc=BZpanel#Proc_bt_AutoCutZ_BZ
   	Button DrawCuts_bt17,pos={600*SC,185*SC}, size={40*SC,20*SC}, disable=1,title="(10-1)",proc=BZpanel#Proc_bt_AutoCutZ_BZ
  
  
    	titlebox DrawCuts_tb3,pos={495*SC,220*SC}, size={40*SC,20*SC},disable=1, title="Csr:",frame=0
  
    	Button DrawCuts_bt11,pos={520*SC,215*SC}, size={40*SC,20*SC}, disable=1,title="Flip",proc=BZpanel#Proc_bt_AutoCut_CSR_BZ
    
    	Button DrawCuts_bt18,pos={565*SC,215*SC}, size={40*SC,20*SC}, disable=1,title="Polar",proc=BZpanel#Proc_bt_AutoCut_CSR_BZ
 
    	Button DrawCuts_bt12,pos={610*SC,215*SC}, size={40*SC,20*SC}, disable=1,title="kz",proc=BZpanel#Proc_bt_AutoCut_CSR_BZ
 
  // Button DrawCuts_bt4,pos={500,110}, size={90,20}, title="kx_ky_Gamma(100)"
  
  
  	TabControl BZpanel,tabLabel(2)="tightbinding"
	
	SetVariable tightbinding_sv0,pos={20*SC,30*SC},size={630*SC,30*SC},title="E(kx,ky)=",frame=1,value=gs_BZ_equal,disable=1
	ListBox tightbinding_lb0,pos={20*SC,50*SC},size={450*SC,70*SC},mode=2,title="Bands:",listwave=BZ_tig_bandlist,selwave=BZ_tig_bandlist_sel,disable=1
	ListBox tightbinding_lb1,pos={480*SC,50*SC},size={170*SC,70*SC},mode=2,title="Pars:",listwave=BZ_tig_parlist,selwave=BZ_tig_parlist_sel,disable=1
	Button tightbinding_bt0,pos={270*SC,125*SC},size={100*SC,18*SC},title="Add band",disable=1,proc=BZpanel#tightbinding_Addband
	Button tightbinding_bt1,pos={370*SC,125*SC},size={100*SC,18*SC},title="Del Band",disable=1,proc=BZpanel#tightbinding_Delband
	
	Button tightbinding_bt2,pos={490*SC,125*SC},size={80*SC,18*SC},title="Add",disable=1,proc=BZpanel#tightbinding_Addpar
	Button tightbinding_bt3,pos={570*SC,125*SC},size={80*SC,18*SC},title="Remove", disable=1,proc=BZpanel#tightbinding_Delpar
	
	SetVariable tightbinding_sv1,pos={20*SC,170*SC},size={120*SC,18*SC},limits={-inf,inf,1},title="Energy_start:", value=gv_BZ_tig_ES,disable=1
	SetVariable tightbinding_sv2,pos={20*SC,190*SC},size={120*SC,18*SC},limits={-inf,inf,1},title="Energy_end:", value=gv_BZ_tig_EE,disable=1
	SetVariable tightbinding_sv3,pos={20*SC,210*SC},size={120*SC,18*SC},limits={-inf,inf,1},title="E_steps:", value=gv_BZ_tig_steps,disable=1
	CheckBox tightbinding_ck0,pos={20*SC,230*SC},size={290*SC,18*SC},title="automatic contours",value=1, disable=1
	
	
	
	SetVariable tightbinding_sv4,pos={170*SC,170*SC},size={120*SC,18*SC},limits={-inf,inf,1},title="kx_pi:", value=gv_BZ_tig_kxpi,disable=1
	SetVariable tightbinding_sv5,pos={170*SC,190*SC},size={120*SC,18*SC},limits={-inf,inf,1},title="ky_pi:", value=gv_BZ_tig_kypi,disable=1
	SetVariable tightbinding_sv6,pos={170*SC,210*SC},size={120*SC,18*SC},limits={-inf,inf,1},title="kz_pi:", value=gv_BZ_tig_kzpi,disable=1
	
	
	SetVariable tightbinding_sv8,pos={300*SC,170*SC},size={120*SC,18*SC},limits={-inf,inf,1},title="kx(pi):", value=gv_BZ_tig_kxrange,disable=1
	SetVariable tightbinding_sv9,pos={300*SC,190*SC},size={120*SC,18*SC},limits={-inf,inf,1},title="ky(pi):", value=gv_BZ_tig_kyrange,disable=1
	SetVariable tightbinding_sv10,pos={300*SC,210*SC},size={120*SC,18*SC},limits={-inf,inf,1},title="kz(pi):", value=gv_BZ_tig_kzrange,disable=1
	SetVariable tightbinding_sv7,pos={300*SC,150*SC},size={120*SC,18*SC},limits={-inf,inf,1},title="kdensity:", value=gv_BZ_tig_kdensity,disable=1

	
	Button tightbinding_addContour, pos={430*SC,170*SC},size={80*SC,18*SC},proc=BZpanel#AddTightBinding,title="Display",disable=1
	Button tightbinding_clearContours, pos={430*SC,190*SC},size={80*SC,18*SC},proc=ClearTightBinding,title="Clear",disable=1
	Button tightbinding_saveContours,pos={430*SC,210*SC},size={80*SC,18*SC},proc=saveTightBinding,title="Plot",disable=1
	slider tightbinding_slider,pos={600*SC,170*SC},size={30*SC,70*SC},limits={-1,1,0.01},vert=1,disable=1,proc=updateTightBinding,variable=gv_BZ_tig_VEF
	SetVariable tightbinding_value,pos={560*SC,150*SC},size={90*SC,20*SC},limits={-1,1,0.01},title= "EF",value=gv_BZ_tig_VEF,disable=1,proc=updateTightBindingSet
	
	Checkbox tightbinding_ck1,pos={430*SC,150*SC},size={50*SC,18*SC},title="3D ISO",value=0, disable=1
   
   	popupmenu tightbinding_pp0,pos={20*SC,125*SC},size={90*SC,20*SC},title="Default:",mode=1,value="cuprates;graphine;iron;",disable=1,proc=DefaultTightBindingSet
   
   
   	Proc_bt_updateBZ("dummy")
   	
   	Checkdisplayed BZ_all_y
   	
   	if (V_flag==0)
  		Appendtograph BZ_All_y vs BZ_All_x
   		Appendtograph Gamma_All_y vs Gamma_All_x
   		ModifyGraph mode(Gamma_All_y)=3,marker(Gamma_All_y)=19 
   		Adjustdisplayratio(4)
   	endif
  	proc_lb_SelBZdisp("dummy",0,0,4)
   	//Proc_bt_readfrommap("DrawCuts_bt1")
   	


   	
   	SetDatafolder DF
	
End	




/////////////////////////////////global Function ////////////////////////////////////////



Function /S SelectPossibleCuts(wname,kx,ky)
	String wname
	Variable kx,ky
	DFREF DF=GetDatafolderDFR()
	DFREF DF_panel=$("root:Internaluse:"+wname)
	SetDatafolder DF_panel
	SetDatafolder Cutkxky
	String Cutlist=wavelist("YCuts*",";","DIMS:1")
	if (strlen(Cutlist)==0)	
		SetDatafolder DF
		return ""
	endif
	String YCutname,XCutname
	Variable index
	do
		YCutname=stringfromlist(index,Cutlist,";")
		if (strsearch(YCutname,"Auto",0,2)==-1)
		
		XCutname="X"+YCutname[1,inf]
		Wave YCut=$YCutname
		Wave XCut=$XCutname
		duplicate /o XCut,XCuttemp
		duplicate /o YCut,Ycuttemp
		XCuttemp-=kx
		YCuttemp-=ky
		YCuttemp=(XCuttemp[p]^2+YCuttemp[p]^2)
		if (Wavemin(YCuttemp)<1e-3)
			Killwaves /Z XCuttemp
			Killwaves /Z YCuttemp
			SetDatafolder DF
			return YCutname
		endif
		
		endif
		index+=1
	while (index<itemsinlist(Cutlist,";"))
	Killwaves /Z XCuttemp
	Killwaves /Z YCuttemp
	SetDatafolder DF
	return ""

End

Function autosynBZCuts(DF_common)
	DFREF DF_common

	DFREF dfR_load=$DF_global

	NVAR autosynflag=dfR_load:gv_autosynflag

	if (autosynflag==0)
		return 0
	endif

	String BZwin=winname(1,65)
	if (stringmatch(BZwin,"BZ_panel*")==0)
		return 0
	endif

        NVAR gv_hn=DF_common:gv_hn
	 NVAR gv_workfunc=DF_common:gv_workfunc
	 NVAR gv_innerE=DF_common:gv_innerE
	 NVAR gv_th=DF_common:gv_th
	 NVAR gv_ph=DF_common:gv_ph
	 NVAR gv_alpha=DF_common:gv_alpha
	 NVAR gv_gamma=DF_common:gv_gamma
	 NVAR gv_thoff=DF_common:gv_thoff
	 NVAR gv_phoff=DF_common:gv_phoff
	 NVAR gv_azioff=DF_common:gv_azioff
	 NVAR gv_curveflag=DF_common:gv_curveflag
	 NVAR gv_deflectorY = DF_common:gv_deflectorY
		
	wave w_image=DF_common:w_image
	NVAR Apos=DF_common:gv_pA
	NVAR Bpos=DF_common:gv_pB
		
	//open_bz_panel("dummy")
	String DF_panel="root:internalUse:"+BZwin
	DFREF DFR_panel=$DF_panel
	
	NVAR angmin=DFR_panel:gv_CutangleF
	NVAR angmax=DFR_panel:gv_cutangleT
	NVAR slicemin=DFR_panel:gv_sliceF
	NVAR slicemax=DFR_panel:gv_sliceT
	NVAR slicenum=DFR_panel:gv_slicenum
	
	NVAR gv_angmodeflag=DFR_panel:gv_angmodeflag
	
	if (gv_angmodeflag==1)
	
		angMax=M_x1(w_image)//dimoffset(w_image,0)+max(Apos,Bpos)*dimdelta(w_image,0)
		angMin=M_x0(w_image)//dimoffset(w_image,0)+min(Apos,Bpos)*dimdelta(w_image,0)
	
	elseif (gv_angmodeflag==2)

		sliceMax=max(Apos,Bpos)
		slicemin=min(Apos,Bpos)
		slicenum=dimsize(w_image,0)
	
	endif
		
	NVAR curveflag=DFR_panel:gv_curveflag
		
	NVAR gv_photonE=DFR_load:gv_photonE
 	NVAR gv_workfn=DFR_load:gv_workfn
	
	NVAR th_Bz=DFR_panel:gv_th
	NVAR ph_bz=DFR_panel:gv_ph
	NVAR azi_bz=DFR_panel:gv_azi
	NVAR gv_SamthetaOff=DFR_load:gv_SamthetaOff
	NVAR gv_Samphioff=DFR_load:gv_Samphioff
	NVAR gv_SamAzioff=DFR_load:gv_SamAzioff
	NVAR gv_gammaA=DFR_load:gv_gammaA
	
	curveflag=gv_curveflag
	
	gv_photonE=(numtype(gv_hn)==2)?(gv_photonE):(gv_hn)
	gv_workfn=(numtype(gv_workfunc)==2)?(gv_workfn):(gv_workfunc)
	gv_gammaA=(numtype(gv_gamma)==2)?(gv_gammaA):(gv_gamma)
	th_Bz=gv_th
	ph_bz=gv_ph
	azi_bz=gv_alpha
	gv_SamthetaOff= gv_thoff
	gv_Samphioff=gv_phoff
	gv_SamAzioff=gv_azioff
	
	NVAR /Z DeflectorY_bz = DFR_panel:gv_DeflectorY		// /Z prevents debugger from flagging bad NVAR
	if (!NVAR_Exists(DeflectorY_BZ))	// No such global numeric variable?
		Variable/G 	DFR_panel:gv_DeflectorY// Create and initialize it
		NVAR DeflectorY_bz = DFR_panel:gv_DeflectorY
	endif
	
	DeflectorY_BZ = gv_DeflectorY
	
	
	
	
    	if (autosynflag==1)
        	Add_autosynCuts(DFR_panel,0,0)
    	else
    	 	Add_autosynCuts(DFR_panel,1,0)
   	 endif
	
End

Function Check_BZ_par(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel

	DFREF DFR_global=$DF_global
			
	NVAR gv_BZtype=DFR_global:gv_BZtype
   
    NVAR gV_uca=DFR_global:gv_uca
    NVAR gV_ucb=DFR_global:gv_ucb
    NVAR gV_ucc=DFR_global:gv_ucc
   
    NVAR gV_alphaA=DFR_global:gv_alphaA
    NVAR gv_betaA=DFR_global:gv_betaA
    NVAR gv_gammaAA=DFR_global:gv_gammaAA
    Variable temp
    
    NVAR gv_BZ_tig_kxpi=DFR_panel: gv_BZ_tig_kxpi
    NVAR gv_BZ_tig_kypi=DFR_panel: gv_BZ_tig_kypi
    NVAR gv_BZ_tig_kzpi=DFR_panel: gv_BZ_tig_kzpi
          
    
    gv_BZ_tig_kxpi=pi/gV_uca
     gv_BZ_tig_kypi=pi/gV_ucb
     gv_BZ_tig_kzpi=pi/gV_ucc
    
    
    
   if (gv_BZtype>1)
   		if  ((gV_alphaA!=90)||(gV_betaA!=90)||(gV_gammaAA!=90))
   			doalert 0, "ALL angle must be 90 for BCC,FCC,TCC."
   			gV_alphaA=90
   			gV_betaA=90
   			gV_gammaAA=90
   			return 0
		endif  
	else
		if ((gv_betaA+gv_gammaAA)<=gv_alphaA)
		doalert 0,"Angle error!"
		return 0
		endif
	endif
	
		make /o/n=3 a_ck,b_ck,c_ck
		Variable d2r=pi/180
		Variable ckvalue=0
		
   		a_ck={gv_uca,0,0}
		b_ck={gv_ucb*cos(gv_alphaA*d2r),gv_ucb*sin(gv_alphaA*d2r),0}
		temp=(gv_ucc*(cos(gv_gammaAA*d2r)-cos(gv_betaA*d2r)*cos(gv_alphaA*d2r))/sin(gv_alphaA*d2r))
		c_ck={gv_ucc*cos(gv_betaA*d2r),temp, sqrt((gv_ucc*sin(gv_betaA*d2r))^2-temp^2)}
		
		
		do 
			if (b_ck[0]<=a_ck[0])
				break
			else
				b_ck-=a_ck
				ckvalue=1
			endif  		
   		while (1)
		
		do 
			if (c_ck[0]<=a_ck[0])
				break
			else
				c_ck-=a_ck
				ckvalue=1
			endif  		
   		while (1)
   		
   		do 
			if (c_ck[1]<=b_ck[1])
				break
			else
				c_ck-=b_ck
				ckvalue=1
			endif
			if (c_ck[0]<0)
				c_ck+=a_ck
				ckvalue=1
			endif
		while (1)
		
		if (ckvalue)
		
			doalert 0,"Not the best unit cell. Auto change."
			//if (v_flag==2) 
			//return 0
			//endif
		gv_ucb=matrixsum(b_ck)
		gv_ucc=matrixsum(c_ck)
		gv_alphaA=asin(b_ck[1]/gv_ucb)
		gv_betaA=acos(c_ck[0]/gv_ucc)
		gv_gammaAA=acos(c_ck[1]*sin(gv_alphaA)/gv_ucc+cos(gv_betaA)*cos(gv_alphaA))
		
		gv_alphaA/=d2r
		gv_betaA/=d2r
		gv_gammaAA/=d2r
		endif
   		
		Killwaves /Z a_ck,b_ck,c_ck
   		   
End


Function AutoSetangle_polar(kx,ky,gammaA)
	Variable kx,ky,gammaA
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel

	DFREF DFR_load=$DF_global
		
	NVAR gv_th=DFR_panel:gv_th
	NVAR gv_ph=DFR_panel:gv_ph
	NVAR gv_azi=DFR_panel:gv_azi
	NVAR gv_SamthetaOff=DFR_load:gv_SamthetaOff
   	NVAR gv_SamphiOff=DFR_load:gv_Samphioff
   	NVAR gv_SamaziOff=DFR_load:gv_SamaziOff

	 NVAR gv_photonE=DFR_load:gv_photonE
 	 NVAR gv_wf=DFR_load:gv_workfn
	
	
	Variable kvac=sqrt(gv_photonE-gv_wf)* 0.5123
	Variable /C returnangle=Fadley_PolarAngle_of_k_BZ(0,0,kvac,gammaA,kx,ky)
	if (gammaA==90)
		gv_th  = real(returnangle)-gv_samthetaoff
		gv_azi =imag(returnangle)-gv_samazioff
		gv_ph=-gv_samphioff
	else

		gv_ph=	real(returnangle)-gv_samphioff
		gv_azi = imag(returnangle)-gv_samazioff
		gv_th=-gv_samthetaoff
	endif

End


function AutoSetAngle(kx,ky,gammaA)
	Variable kx,ky,gammaA
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_load=$DF_global
		
	NVAR gv_th=DFR_panel:gv_th
	NVAR gv_ph=DFR_panel:gv_ph
	NVAR gv_azi=DFR_panel:gv_azi
	NVAR gv_SamthetaOff=DFR_load:gv_SamthetaOff
   	NVAR gv_SamphiOff=DFR_load:gv_Samphioff
   	NVAR gv_SamaziOff=DFR_load:gv_SamaziOff
	
	 NVAR gv_photonE=DFR_load:gv_photonE
 	 NVAR gv_wf=DFR_load:gv_workfn
 	 
 	 NVAR curveflag=DFR_panel:gv_curveflag
	
	 Variable kvac=sqrt(gv_photonE-gv_wf)* 0.5123
	 
	 
	
	 gv_th = flip_coarseAngle_of_k_BZ((gv_azi+gv_samazioff),0,kvac,gammaA,kx,ky,curveflag)-gv_samthetaoff
	 gv_ph =flip_fineAngle_of_k_BZ((gv_azi+gv_samazioff),0,kvac,gammaA,kx,ky,curveflag)-gv_samphioff
	
//		if (gammaA == 90)
	//		gv_th = flip_coarseAngle_of_k(-(gv_azi+gv_samazioff),kvac,kx,ky)-gv_samthetaoff//asin(FSM_tempkx/kvac) * 180/pi//flip_coarseAngle_of_k(-loc_alpha,kvac,x,y)
	//		gv_ph = flip_fineAngle_of_k(-(gv_azi+gv_samazioff),kvac,kx,ky)-gv_samphioff//atan(FSM_tempky/sqrt(kvac^2-(FSM_tempkx^2+FSM_tempky^2))) * 180/pi//flip_fineAngle_of_k(-loc_alpha,kvac,x,y)
	//	elseif (gammaA == 0)
			//FSM_c = flip_coarseAngle_of_k(-loc_alpha,kvac,x,y)//asin(FSM_tempkx/kvac) * 180/pi
			//FSM_f = flip_fineAngle_of_k(-loc_alpha,kvac,x,y)//atan(FSM_tempky/sqrt(kvac^2-(FSM_tempkx^2+FSM_tempky^2))) * 180/pi
	//	    	gv_th = flip_coarseAngle_of_k_precise((gv_azi+gv_samazioff),0,kvac,gammaA,kx,ky)-gv_samthetaoff
	//		gv_ph =flip_fineAngle_of_k_precise((gv_azi+gv_samazioff),0,kvac,gammaA,kx,ky)-gv_samphioff// flip_coarseAngle_of_k((gv_azi+gv_samazioff),kvac,ky,kx)-gv_samphioff//flip_fineAngle_of_k(-loc_alpha,kvac,y,x)
	//	endif

End

//////////////////////////k to angle////////////////////////

Function flip_coarseAngle_of_k_BZ(alpha,deta,kvac,gammaA,kx,ky,curveflag)
	Variable alpha, deta,kvac, gammaA,kx, ky,curveflag
	
	//first rotate alpha back
	Variable kz=sqrt(kvac^2-kx^2-ky^2)
	Variable kx_rot= cos(alpha*pi/180)*kx - sin(alpha*pi/180)*ky
	Variable ky_rot=sin(alpha*pi/180)*kx + cos(alpha*pi/180)*ky 
	
	if (gammaA==0)
		Variable phi=atan(ky_rot/kz)*180/pi
		
		Variable ky_rotphi=cos(phi*pi/180)*ky_rot-sin(phi*pi/180)*kz
		Variable kz_rotphi=sin(phi*pi/180)*ky_rot+cos(phi*pi/180)*kz
		//if (curveflag==0)
			return atan(kx_rot/kz_rotphi) * 180/pi
		//else
		//	return (atan(kx_rot/kz_rotphi) - curve_slit_correction_quick(asin(ky_rotphi/kvac),gammaA*pi/180))* 180/pi
		//endif
	else
		Variable phi_rot=atan(ky_rot/kz)*180/pi
		kz_rotphi=sin(phi_rot*pi/180)*ky_rot+cos(phi_rot*pi/180)*kz
		
		//Variable kx_rottheta=cos(-phi*pi/180)*kx_rot+sin(-phi*pi/180)*kz_rotphi
		//Variable kz_rottheta=-sin(-phi*pi/180)*kx_rot+cos(-phi*pi/180)*kz_rotphi
		
		return  atan(kx_rot/kz_rotphi) * 180/pi//asin(kx_rottheta/kvac)*180/pi
	endif
End
Function flip_fineAngle_of_k_BZ(alpha,deta,kvac,gammaA,kx,ky,curveflag)
	Variable alpha, deta,kvac, gammaA,kx, ky,curveflag
	
	Variable kz=sqrt(kvac^2-kx^2-ky^2)
	Variable kx_rot= cos(alpha*pi/180)*kx - sin(alpha*pi/180)*ky
	Variable ky_rot=sin(alpha*pi/180)*kx + cos(alpha*pi/180)*ky 
	
	if (gammaA==0)
		return atan(ky_rot/kz)*180/pi
	//	Variable ky_rotphi=cos(phi*pi/180)*ky_rot-sin(phi*pi/180)*kz
	//	Variable kz_rotphi=sin(phi*pi/180)*ky_rot+cos(phi*pi/180)*kz
	//	return asin(ky_rotphi/kvac)*180/pi
	else
	
		Variable phi_rot=atan(ky_rot/kz)*180/pi
		return phi_rot
		//Variable kz_rotphi=sin(phi_rot*pi/180)*ky_rot+cos(phi_rot*pi/180)*kz
		
		//Variable kx_rottheta=cos(-phi*pi/180)*kx_rot+sin(-phi*pi/180)*kz_rotphi
		//ky_rotphi=cos(phi*pi/180)*ky_rot-sin(phi*pi/180)*kz
		//Variable kx_rotphi=cos(-phi*pi/180)*kx_rot+sin(-phi*pi/180)*kz
		//kz_rotphi=-sin(-phi*pi/180)*kx_rot+cos(-phi*pi/180)*kz
		
		//if (curveflag==0)
		//	return atan(ky_rot/kz)*180/pi
		//else
		//	return (atan(ky_rot/kz)- curve_slit_correction_quick(asin(kx_rottheta/kvac),gammaA*pi/180))*180/pi
		//endif
	endif
	
End



Function AutoSetanglePh(kx,kz,gammaA)
	Variable kx,kz,gammaA
	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_load=$DF_global
	
	NVAR gv_th=DFR_panel:gv_th
	NVAR gv_ph=DFR_panel:gv_ph
	NVAR gv_azi=DFR_panel:gv_azi
	NVAR gv_SamthetaOff=DFR_load:gv_SamthetaOff
   	NVAR gv_SamphiOff=DFR_load:gv_Samphioff
   	NVAR gv_SamaziOff=DFR_load:gv_SamaziOff
	
	 NVAR gv_photonE=DFR_load:gv_photonE
 	 NVAR gv_wf=DFR_load:gv_workfn
	NVAR gv_innerE=DFR_load:gv_innerE

	Variable ph=imag(Kxkz_EF_phi_of_k(0,kx,kz,0,0,0,gv_InnerE,gammaA))
	gv_photonE=real(Kxkz_EF_phi_of_k(0,kx,kz,0,0,0,gv_InnerE,gammaA))+gv_wf
	//Kxkz_phi_of_k(kx,kz,0,gv_InnerE)//atan2(kx,kz)/pi*180

	//gv_photonE=Kxkz_Energy_of_k(kx,kz,0,gv_InnerE)+gv_wf
	
	if (gammaA==0)
		gv_th=-gv_samthetaoff
		gv_ph=ph-gv_samphioff
		gv_azi=-gv_samazioff
	else
		gv_th=ph-gv_samthetaoff
		gv_ph=-gv_samphioff
		gv_azi=-gv_samazioff
	endif	
End






/////////////////////////////////static Function ////////////////////////////////////////


static Function SetBZtype (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	
  	 String DF_panel="root:internalUse:"+winname(0,65)
  	 DFREF DFR_panel=$DF_panel
   	DFREF DFR_global=$DF_global
   	SetActivesubwindow $winname(0,65)
   
  	 NVAR gv_BZtype=DFR_global:gv_BZtype
   
  	 NVAR gV_uca=DFR_global:gv_uca
  	 NVAR gV_ucb=DFR_global:gv_ucb
  	 NVAR gV_ucc=DFR_global:gv_ucc
   
   	NVAR gV_alphaA=DFR_global:gv_alphaA
   	NVAR gv_betaA=DFR_global:gv_betaA
  	 NVAR gv_gammaAA=DFR_global:gv_gammaAA
   	Variable temp1,temp2
          
   	if (popnum>1)
   		if  ((gV_alphaA!=90)||(gV_betaA!=90)||(gV_gammaAA!=90))
   		doalert 0, "angle must be 90"  
   		PopupMenu DrawBZ_pp6,mode=1
   		gv_BZtype=1
   		else
   		gv_BZtype=popnum
   		endif
   	else
   		gv_BZtype=popnum
   	endif	 
   		   
  
   
End


static Function Proc_ck_autosynck(ctrlname,checked)
	String ctrlname
	Variable checked
	String DF_panel="root:internalUse:"+winname(0,65)

	DFREF DFR_panel=$DF_panel
	DFREF DFR_global=$DF_global
	SetActivesubwindow $winname(0,65)

	NVAR gv_autosynflag=DFR_global:gv_autosynflag

	Variable ckvalue
	strswitch(ctrlname)
	case "DrawCuts_ck04":
	if (checked)
		ckvalue=1
	else
		ckvalue=0
		Add_autosynCuts(DFR_panel,0,2)
	endif

	break
	case "DrawCuts_ck05":
	if (checked)
		ckvalue=2
	else
		ckvalue=0
		Add_autosynCuts(DFR_panel,1,2)
	endif
	break
	endswitch
	
	checkbox DrawCuts_ck04, value=ckvalue==1
	checkbox DrawCuts_ck05, value=ckvalue==2

	if (gv_autosynflag>0)
		if (gv_autosynflag!=ckvalue)
			Add_autosynCuts(DFR_panel,(gv_autosynflag-1),2)
		endif
	endif

	gv_autosynflag=ckvalue

	if (gv_autosynflag==1)
		Add_autosynCuts(DFR_panel,0,1)
		open_main_panel("dummy")
	elseif (gv_autosynflag==2)
		Add_autosynCuts(DFR_panel,1,1)
		open_main_panel("dummy")
	endif

End



static Function Add_autosynCuts(DF_panel,kz_flag,disp_flag)
	DFREF DF_panel 
	Variable kz_flag,disp_flag
	DFREF dF=GetDatafolderDFR()

	DFREF DFR_load=$DF_global
	SetActivesubwindow $winname(0,65)
	SetDatafolder DF_panel

	NVAR gv_th, gv_ph, gv_azi,gv_deflectorY

	// in inverse angstoms
	NVAR gv_gammaA=DFR_load:gv_gammaA
	NVAR gv_InnerE=DFR_load:gv_InnerE
	NVAR gv_SamthetaOff=DFR_load:gv_SamthetaOff
	NVAR gv_SamphiOff=DFR_load:gv_Samphioff
	NVAR gv_SamaziOff=DFR_load:gv_SamaziOff
	
	 NVAR gv_photonE=DFR_load:gv_photonE
 	 NVAR gv_wf=DFR_load:gv_workfn
	
	Variable  Ef=gv_photonE-gv_wf
	Variable E = Ef*1.602e-19
	variable mass = 9.1095e-31
	variable hbar = 1.05459e-34
	variable kvac = sqrt((2*mass*E)/hbar^2)*1e-10

	NVAR gv_CutangleT=DF_panel:gv_CutangleT
	NVAR gv_CutangleF=DF_panel:gv_CutangleF
	NVAR slicemin=DF_panel:gv_sliceF
	NVAR slicemax=DF_panel:gv_sliceT
	NVAR slicenum=DF_panel:gv_slicenum
	
	NVAR gv_angmodeflag=DF_panel:gv_angmodeflag
	NVAR gv_angintflag=DF_panel:gv_angintflag
	
	NVAR gv_curveflag=DFR_panel:gv_curveflag

	String Wnamex,Wnamey,SampleTemp_x,SampleTemp_y,notestr
	variable m,n,kxtemp,kytemp,kztemp,EZ
	Variable CutangleF,CutangleT,Cutanglenum

	if (gv_angmodeflag==1)
		CutangleF=gv_CutangleF
		CutangleT=gv_CutangleT
	elseif (gv_angmodeflag==2)
		CutangleF=slicemin*(gv_CutangleT-gv_CutangleF)/slicenum+gv_CutangleF
		CutangleT=slicemax*(gv_CutangleT-gv_CutangleF)/slicenum+gv_CutangleF
	endif

	if (kz_flag)
		wnamex="XCuts_Autosyn_kz"
		wnamey="YCuts_Autosyn_kz"
	else
		wnamex="XCuts_Autosyn_kxky"
		wnamey="YCuts_Autosyn_kxky"
	endif

	newDatafolder /o/s CutKxKy

	if  (gv_angintflag==1)

	Cutanglenum=1

	sampletemp_x = wnamex//uniquename(wnamex,1,0)
	sampletemp_y = wnamey//uniquename(wnamey,1,0)
	make/o/n=(Cutanglenum)  $sampletemp_x, $sampletemp_y
	wave stx = $sampletemp_x
	wave sty = $sampletemp_y

	Setscale /P x, (CutangleF+CutangleT)/2,0.1,stx,sty

	else

	Cutanglenum=round((CutangleT-CutangleF)/1)+1

	sampletemp_x = wnamex//uniquename(wnamex,1,0)
	sampletemp_y = wnamey//uniquename(wnamey,1,0)
	make/o/n=(Cutanglenum)  $sampletemp_x, $sampletemp_y
	wave stx = $sampletemp_x
	wave sty = $sampletemp_y
	Setscale /I x, CutangleF,CutangleT,stx,sty
	endif

	if (disp_flag==2)
		removefromgraph /Z $sampleTemp_y
		Killwaves /Z $sampleTemp_y
		Killwaves /Z $sampleTemp_x
		SetDatafolder DF
		return 1
	endif


	if (kz_flag)
		if (gv_gammaA==0)
		stx=flip_to_k(kvac,gv_innerE,gv_th+gv_samthetaoff,gv_ph+gv_samphioff,gv_azi+gv_samazioff,x,gv_gammaA,1,gv_curveflag)
		sty=flip_to_k(kvac,gv_innerE,gv_th+gv_samthetaoff,gv_ph+gv_samphioff,gv_azi+gv_samazioff,x,gv_gammaA,2,gv_curveflag)
		else
		stx=flip_to_k(kvac,gv_innerE,gv_th+gv_samthetaoff,gv_ph+gv_samphioff,gv_azi+gv_samazioff,x,gv_gammaA,0,gv_curveflag)
		sty=flip_to_k(kvac,gv_innerE,gv_th+gv_samthetaoff,gv_ph+gv_samphioff,gv_azi+gv_samazioff,x,gv_gammaA,2,gv_curveflag)
		endif
	else	
		if((numtype(gv_deflectorY)==2)||(gv_deflectorY ==0))
			stx=flip_to_k(kvac,gv_innerE,gv_th+gv_samthetaoff,gv_ph+gv_samphioff,gv_azi+gv_samazioff,x,gv_gammaA,0,gv_curveflag)
			sty=flip_to_k(kvac,gv_innerE,gv_th+gv_samthetaoff,gv_ph+gv_samphioff,gv_azi+gv_samazioff,x,gv_gammaA,1,gv_curveflag)
		else		
			stx=flip_to_k_DA30(kvac,gv_innerE,gv_th+gv_samthetaoff,gv_ph+gv_samphioff,gv_azi+gv_samazioff,gv_deflectorY,x,gv_gammaA,0,gv_curveflag)
			sty=flip_to_k_DA30(kvac,gv_innerE,gv_th+gv_samthetaoff,gv_ph+gv_samphioff,gv_azi+gv_samazioff,gv_deflectorY,x,gv_gammaA,1,gv_curveflag)
		endif
	endif

	if (disp_flag)
		removefromgraph /Z $sampleTemp_y
		AppendToGraph  sty vs stx 
		ModifyGraph  mode($sampletemp_y )=3,marker($sampletemp_y )=7
		ModifyGraph  rgb($sampletemp_y )=(1,4,52428)
	endif

	//ModifyGraph height={Aspect,1}
	KillWaves/Z R1,R2,R3,s_angle,k,M_Product
	SetDataFolder DF

End




static Function Proc_bt_AutoCut_CSR_BZ(ctrlname)
	String ctrlname
	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_load=$DF_global
	SetActivesubwindow $winname(0,65)
	
	NVAR gammaA=DFR_load:gv_gammaA
	
	Variable bExists= strlen(CsrInfo(B)) > 0
	String Imagelist=ImageNameList(winname(0,65),";")
	
	if (strlen(imagelist)==-1)
		Imagelist=tracenamelist(winname(0,65),";",1)
		String waveN=stringfromlist(0,imagelist,";")
		
		if (bExists == 0)
			ShowInfo; Cursor/P/H=1 /F B $waveN,0,0
		endif
	else
		waveN=stringfromlist(0,imagelist,";")
		if (bExists == 0)
			ShowInfo; Cursor/P/I/H=1 /F B $waveN 10,10
		endif
		
	endif
	
	
	Variable tempx,tempy
	tempx=hcsr(B,winname(0,65))
	tempy=Vcsr(B,winname(0,65))
	
	if (stringmatch(ctrlname,"DrawCuts_bt11"))
		AutoSetangle(tempx,tempy,gammaA)
		Proc_add_to_BZ("DrawCuts_BZAddCut")
	elseif (stringmatch(ctrlname,"DrawCuts_bt18"))
		AutoSetangle_Polar(tempx,tempy,gammaA)
		Proc_add_to_BZ("DrawCuts_BZAddCut")
	else
		AutoSetanglePh(tempx,tempy,gammaA)
		Proc_add_to_BZ("DrawCuts_BZAddZCut")
	endif
	
	
	
End

static Function Proc_bt_AutoCutZ_BZ(ctrlname)
	String ctrlname
	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_load=$DF_global
	SetActivesubwindow $winname(0,65)
	
	NVAR gv_gammaA=DFR_load:gv_gammaA
	
	Wave BZ_sel_y=DFR_panel:BZ_sel_y
	Wave BZ_sel_x=DFR_panel:BZ_sel_x
	
	Variable kx,kz
	
	
	Wave gamma_all_x=DFR_panel:gamma_all_x
	Wave gamma_all_y=DFR_panel:gamma_all_y
	Variable kx0,kz0
	controlinfo DrawBZ_lb0
	kx0=gamma_all_x[v_value*2]
	kz0=gamma_all_y[v_value*2]
	
	Strswitch(ctrlname)
	case "DrawCuts_bt7":
		kx=kx0
		kz=kz0
		break
	case "DrawCuts_bt8":
		kx=kx0
		kz=wavemax(BZ_sel_y)
		break
	case "DrawCuts_bt9":
		kx=wavemax(BZ_sel_x)
		kz=kz0
		break
	case "DrawCuts_bt10":
		kx=wavemax(BZ_sel_x)
		kz=wavemax(BZ_sel_y)
		break
	case "DrawCuts_bt13":
		kx=wavemin(BZ_sel_x)
		kz=kz0
		break
	case "DrawCuts_bt14":
		kx=wavemin(BZ_sel_x)
		kz=wavemax(BZ_sel_y)
		break
	case "DrawCuts_bt15":
		kx=kx0
		kz=wavemin(BZ_sel_y)
		break
	case "DrawCuts_bt16":
		kx=wavemin(BZ_sel_x)
		kz=wavemin(BZ_sel_y)
		break
	case "DrawCuts_bt17":
		kx=wavemax(BZ_sel_x)
		kz=wavemin(BZ_sel_y)
		break
	endswitch

	
	AutoSetanglePh(kx,kz,gv_gammaA)
       Proc_add_to_BZ("DrawCuts_BZAddZCut")
	
End

Static Function Proc_bt_AutoCut_BZ(ctrlname)
	String ctrlname
	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_load=$DF_global
	SetActivesubwindow $winname(0,65)
	NVAR gv_gammaA=DFR_load:gv_gammaA
	
	Wave BZ_sel_y=DFR_panel:BZ_sel_y
	Wave BZ_sel_x=DFR_panel:BZ_sel_x
	
	
	Wave gamma_all_x=DFR_panel:gamma_all_x
	Wave gamma_all_y=DFR_panel:gamma_all_y
	Variable kx0,ky0
	controlinfo DrawBZ_lb0
	kx0=gamma_all_x[v_value*2]
	ky0=gamma_all_y[v_value*2]
	
	Variable kx,ky
	
	Strswitch(ctrlname)
	case "DrawCuts_bt2":
		kx=kx0
		ky=ky0
		break
	case "DrawCuts_bt3":
		kx=wavemin(BZ_sel_x)
		ky=ky0
		break
	case "DrawCuts_bt4":
		kx=wavemax(BZ_sel_x)
		ky=ky0
		break
	case "DrawCuts_bt5":
		kx=kx0
		ky=wavemax(BZ_sel_y)
		break
	case "DrawCuts_bt6":
		kx=kx0
		ky=wavemin(BZ_sel_y)
		break
	endswitch
	
	AutoSetAngle(kx,ky,gv_gammaA)
	Proc_add_to_BZ("dummy")
	
End


static Function Bz_panel_AutoTab_proc( name, tab )
	String name
	Variable tab
	
	DFREF DF = GetDataFolderDFR()
	SetActivesubwindow $winname(0,65)
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
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetDataFolder DFR_panel
		
	SetDatafolder DF
	
End


Static Function Proc_sv_checkangerror_BZ(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetActivesubwindow $winname(0,65)
	
    NVAR angMax=DFR_panel:gv_CutangleT
	NVAR angMin=DFR_panel:gv_CutangleF
	
	if (stringmatch(ctrlname,"DrawCuts_sv02"))
		if (angMax<angmin)
		angMax=angmin
		endif
	else
		if (angmin>angmax)
		angmin=angMax
		endif
	endif
	
End

static Function Proc_sv_checksliceerror_BZ(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	 DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetActivesubwindow $winname(0,65)
	
	NVAR sliceMax=DFR_panel:gv_sliceT
	NVAR sliceMin=DFR_panel:gv_sliceF
	NVAR slicenum=DFR_panel:gv_slicenum
	
	
	
	
	if (stringmatch(ctrlname,"DrawCuts_sv04"))
		if (sliceMax>slicenum)
		sliceMax=slicenum
		endif
		if (slicemax<slicemin)
		slicemax=slicemin
		endif
	elseif (stringmatch(ctrlname,"DrawCuts_sv03"))
	
		if (slicemin>sliceMax)
		slicemin=sliceMax
		endif
	else
		if (slicenum<sliceMax)
		slicenum=sliceMax
		endif
		
	endif
	
End

static Function Proc_bt_readfrommap(ctrlName)
	String ctrlName
	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
 	DFREF DFR_panel=$DF_panel
	SetActivesubwindow $winname(0,65)
 
	 DFREF dF_load=$DF_global
	
	NVAR thetaoff=dF_load:gv_samthetaoff
	NVAR phioff=dF_load:gv_samphioff
	NVAR azioff=dF_load:gv_samazioff
	
	NVAR theta=DFR_panel:gv_th
	NVAR phi=DFR_panel:gv_ph
	NVAR azi=DFR_panel:gv_azi
	
	
	NVAR gv_photonE=DFR_load:gv_photonE
 	NVAR gv_workfn=DFR_load:gv_workfn
	NVAR gV_innerE=DFR_load:gV_innerE
	NVAR gv_gammaA=DFR_load:gv_gammaA
	
	
	NVAR mapthetaoff=DFR_map:gv_th_off
	NVAR mapphioff=DFR_map:gv_ph_off
	NVAR mapazioff=DFR_map:gv_alpha_off
	NVAR mapphotonE=DFR_map:gv_hn
	NVAR mapworkfn=DFR_map:gv_workfunction
	NVAR mapinnerE=DFR_map:gv_innerE
	
	
	if (stringmatch(ctrlname,"DrawCuts_bt1"))
	
		String win_map=winname(1,65)
		if (stringmatch(win_map,"mapper_panel*")==1)
			String DF_map="root:internalUse:"+win_map
			DFREF DFR_map=$DF_map
	
			thetaoff=mapthetaoff
			phioff=mapphioff
			azioff=mapazioff
		
			gv_photonE=(numtype(mapphotonE)==2)?(gv_photonE):(mapphotonE)
			gv_workfn=(numtype(mapworkfn)==2)?(gv_workfn):(mapworkfn)
			gV_innerE=(numtype(mapinnerE)==2)?(gV_innerE):(mapinnerE)

		else
			SetDatafolder DF
			return 1
		endif
	else
		Wave YCuts_sel=DFR_panel:YCuts_sel
		String notestr=note(YCuts_sel)
		Read_cuts_note(notestr)
		Wave WaveinfoVal
		
		gv_photonE=WaveinfoVal[0]
		gv_workfn=WaveinfoVal[1]
		gv_innerE=WaveinfoVal[2]
		theta=WaveinfoVal[3]
		thetaoff=WaveinfoVal[4]
		phi=WaveinfoVal[5]
		phioff=WaveinfoVal[6]
		azi=WaveinfoVal[7]
		azioff=WaveinfoVal[8]
		
		gv_gammaA=WaveinfoVal[9]

	endif
	SetDatafolder DF

End

static Function Proc_bt_ReadCSR_BZ(ctrlname)
	String ctrlname
	 DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetActivesubwindow $winname(0,65)
	
	DFREF DFR_load=$DF_global
	
	NVAR angMax=DFR_panel:gv_CutangleT
	NVAR angMin=DFR_panel:gv_CutangleF
	
	NVAR sliceMax=DFR_panel:gv_sliceT
	NVAR sliceMin=DFR_panel:gv_sliceF
	NVAR slicenum=DFR_panel:gv_slicenum
	
	//open_main_panel("dummy")
	String win_main=winname(1,65)
	if (stringmatch(win_main,"main_panel*")==1)
		String DF_main="root:internalUse:"+win_main
		DFREF DFR_mian=$DF_main
		String DF_Maincommon="root:internalUse:"+win_main+":panel_common:"
		DFREF DFR_maincommon=$DF_Maincommon
		wave w_image=DFR_maincommon:w_image
		
		NVAR gv_hn=DFR_maincommon:gv_hn
	 	NVAR gv_workfunc=DFR_maincommon:gv_workfunc
	 	NVAR map_innerE=DFR_maincommon:gv_innerE
	 	NVAR gv_th=DFR_maincommon:gv_th
	 	NVAR gv_ph=DFR_maincommon:gv_ph
	 	NVAR gv_alpha=DFR_maincommon:gv_alpha
	 	NVAR gv_gamma=DFR_maincommon:gv_gamma
	 	NVAR gv_thoff=DFR_maincommon:gv_thoff
		NVAR gv_phoff=DFR_maincommon:gv_phoff
		NVAR gv_azioff=DFR_maincommon:gv_azioff
		
		
		NVAR gv_photonE=DFR_load:gv_photonE
 		NVAR gv_workfn=DFR_load:gv_workfn
		NVAR gV_innerE=DFR_load:gV_innerE
		NVAR th_Bz=DFR_panel:gv_th
		NVAR ph_bz=DFR_panel:gv_ph
		NVAR azi_bz=DFR_panel:gv_azi
		NVAR gv_SamthetaOff=DF_load:gv_SamthetaOff
		NVAR gv_Samphioff=DF_load:gv_Samphioff
		NVAR gv_SamAzioff=DF_load:gv_SamAzioff
	
		
		Variable Apos=pcsr(A, win_main)
		Variable Bpos=pcsr(B, win_main)
		
		if (stringmatch(ctrlname,"DrawCuts_bt01"))
			controlinfo DrawCuts_ck01
			if (v_value)
				angMax=M_x1(w_image)//+max(Apos,Bpos)*dimdelta(w_image,0)
				angMin=M_x0(w_image)//+min(Apos,Bpos)*dimdelta(w_image,0)
			else
				sliceMax=dimsize(w_image,0)//max(Apos,Bpos)
				slicemin=0//min(Apos,Bpos)
				slicenum=dimsize(w_image,0)
			endif
		else
			gv_photonE=(numtype(gv_hn)==2)?(gv_photonE):(gv_hn)
			gv_workfn=(numtype(gv_workfunc)==2)?(gv_workfn):(gv_workfunc)
			gv_innerE=(numtype(map_innerE)==2)?(gv_innerE):(map_innerE)
			th_Bz=gv_th
			ph_bz=gv_ph
			azi_bz=gv_alpha
			gv_SamthetaOff= gv_thoff
			gv_Samphioff=gv_phoff
	   		gv_SamAzioff=gv_azioff

			controlinfo DrawCuts_ck01
			if (v_value)
				angMax=max(Apos,Bpos)*dimdelta(w_image,0)
				angMin=min(Apos,Bpos)*dimdelta(w_image,0)
			else
				sliceMax=max(Apos,Bpos)
				slicemin=min(Apos,Bpos)
				slicenum=dimsize(w_image,0)
			endif
		endif
	else
		SetDatafolder DF
		return 1
	endif
	SetDatafolder DF
End


static Function Proc_angmodechange(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr
	
	 DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetActivesubwindow $winname(0,65)
	
	NVAR angMax=DFR_panel:gv_CutangleT
	NVAR angMin=DFR_panel:gv_CutangleF
	
	if (popnum==1)
		angmax=15
		angmin=-15
	elseif (popnum==2) 
		angmax=7
		angmin=-7
	endif
End

static Function Proc_ck_Changerangemode(ctrlname,checked)
String ctrlname
Variable checked

 	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetActivesubwindow $winname(0,65)
	NVAR gv_angmodeflag=DFR_panel:gv_angmodeflag
	
	Variable ckvalue
	strswitch(ctrlname)
	case "DrawCuts_ck01":
	ckvalue=1
	break
	case "DrawCuts_ck02":
	ckvalue=2
	break
	endswitch
	
	Checkbox DrawCuts_ck01,value=ckvalue==1
	Checkbox DrawCuts_ck02,value=ckvalue==2

	gv_angmodeflag=ckvalue
	
End

static Function Proc_ck_updateCrossBZ(ctrlname,Checked)
	String ctrlname
	variable checked

	 DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
    DFREF DFR_load=$DF_global
   SetActivesubwindow $winname(0,65)
   SetDatafolder DFR_panel
   NVAR gv_BZtype=DFR_load:gv_BZtype
   
   NVAR gV_uca=DFR_load:gv_uca
   NVAR gV_ucb=DFR_load:gv_ucb
   NVAR gV_ucc=DFR_load:gv_ucc
   
   NVAR gV_alphaA=DFR_load:gv_alphaA
   NVAR gv_betaA=DFR_load:gv_betaA
   NVAR gv_gammaAA=DFR_load:gv_gammaAA
   NVAR gv_sampleOrientation=DFR_panel:gv_BZ_rotate//DFR_load:gv_sampleOrientation
   
   NVAR gv_A1=DFR_panel:gv_A1
   NVAR gv_B1=DFR_panel:gv_B1
   NVAR gv_C1=DFR_panel:gv_C1
   NVAR gv_PL=DFR_panel:gv_PL
   Variable d2r=pi/180
   
   
  	if (checked==0)
  		if (stringmatch(ctrlname,"DRawBZ_bck0"))
  			Removefromgraph /Z BZ_D1_y
  			SetDatafolder DF
  			return 1
  		endif
  		if (stringmatch(ctrlname,"DRawBZ_bck1"))
  			Removefromgraph /Z BZ_D2_y
  			SetDatafolder DF
  			return 1
  		endif
  	endif
  	 
   
   Wave BZlist
	
	
   Wave BZ_All_x,BZ_All_y,Gamma_all_x,Gamma_all_y
   Make /o/n=(3*(numpnts(BZ_all_x)-2*dimsize(BZlist,0))) BZ_D1_x,BZ_D1_y,BZ_D2_x,BZ_D2_y
  	Variable index=0,Pindex,Gindex
  	Do
  		if (index>=numpnts(BZ_All_x))
  		break
  		endif
  		
  		if (numtype(BZ_all_x[index+1])==2)
  		index+=2
  		Gindex+=2
  		continue
  		endif
  		BZ_D2_x[3*Pindex]=BZ_All_x[index]
  		BZ_D2_y[3*Pindex]=BZ_All_y[index]
  		BZ_D2_x[3*Pindex+1]=-(BZ_All_x[index]-Gamma_all_x[Gindex])+Gamma_all_x[Gindex]
  		BZ_D2_y[3*Pindex+1]=-(BZ_All_y[index]-Gamma_all_y[Gindex])+Gamma_all_y[Gindex]
  		BZ_D2_x[3*Pindex+2]=Nan
  		BZ_D2_y[3*Pindex+2]=Nan
  		
  		BZ_D1_x[3*Pindex]=(BZ_All_x[index]+BZ_All_x[index+1])/2
  		BZ_D1_y[3*Pindex]=(BZ_All_y[index]+BZ_All_y[index+1])/2
  		BZ_D1_x[3*Pindex+1]=-((BZ_All_x[index]+BZ_All_x[index+1])/2-Gamma_all_x[Gindex])+Gamma_all_x[Gindex]
  		BZ_D1_y[3*Pindex+1]=-((BZ_All_y[index]+BZ_All_y[index+1])/2-Gamma_all_y[Gindex])+Gamma_all_y[Gindex]
  		BZ_D1_x[3*Pindex+2]=Nan
  		BZ_D1_y[3*Pindex+2]=Nan
  		Pindex+=1
  		
  	index+=1
  	while (index<numpnts(BZ_All_x))
  	
  	if (stringmatch(ctrlname,"DRawBZ_bck0"))
   		if (traceexist(winname(0,65),"BZ_D1_y",1)==0)
  		  		Appendtograph BZ_D1_y vs BZ_D1_x
  		  		ModifyGraph lstyle(BZ_D1_y)=2
  		endif
  	endif
  	
   	if (stringmatch(ctrlname,"DRawBZ_bck1"))
  	
   		if (traceexist(winname(0,65),"BZ_D2_y",1)==0)
  		Appendtograph BZ_D2_y vs BZ_D2_x
  		ModifyGraph lstyle(BZ_D2_y)=8
  		endif
   	endif
   	
  SetDatafolder DF

End

static Function Proc_bt_displayBZ_proc(ctrlname)
	String ctrlname
	
    	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
   	SetActivesubwindow $winname(0,65)
   	SetDatafolder DFR_panel
   
   	String wname=winname(0,65)
   
   	Wave BZ_all_y
   	Wave BZ_all_x
   	Wave gamma_all_y
   	Wave gamma_all_x
   	Wave Bz_D1_y
   	Wave BZ_D1_x
  	 Wave BZ_D2_y
  	 Wave BZ_D2_x
   
  	 Variable appendflag
   
  	 if (stringmatch(ctrlname,"DRawBZ_bt01"))
   			appendflag=0
  	 else
   			appendflag=1
   			String gn=winname(1,1)
   			Dowindow /F $gn
   	endif
   	
 	Variable temppos=strsearch(wname,"_",inf,1)
 	String suffix=wname[temppos,inf]
 	
 	duplicate /o BZ_all_y, $("BZ_all_y"+suffix)
 	duplicate /o BZ_all_x, $("BZ_all_x"+suffix)
  	Wave y_copy=$("BZ_all_y"+suffix)
  	Wave x_copy=$("BZ_all_x"+suffix)
  	display_XYwave(y_copy,x_copy,appendflag,0)
  	Killwaves /Z y_copy,x_copy
  	
   	appendflag=1
   	
   	duplicate /o gamma_all_y, $("gamma_all_y"+suffix)
 	duplicate /o gamma_all_x, $("gamma_all_x"+suffix)
 	Wave y_copy=$("gamma_all_y"+suffix)
  	Wave x_copy=$("gamma_all_x"+suffix)
  	display_XYwave(y_copy,x_copy,appendflag,0)
  	Killwaves /Z y_copy,x_copy
  	ModifyGraph mode($("gamma_all_y"+suffix))=3,marker($("gamma_all_y"+suffix))=19
  	
  	
   	checkdisplayed  /W=$wname Bz_D1_y
  	 if (v_flag>0)
  	 	duplicate /o BZ_D1_y, $("BZ_D1_y"+suffix)
 		duplicate /o BZ_D1_x, $("BZ_D1_x"+suffix)
 		Wave y_copy=$("BZ_D1_y"+suffix)
  		Wave x_copy=$("BZ_D1_x"+suffix)
  		display_XYwave(y_copy,x_copy,appendflag,0)
  		Killwaves /Z y_copy,x_copy
   		//display_XYwave(BZ_D1_y,BZ_D1_x,appendflag,0)
 	 endif
   	checkdisplayed  /W=$wname Bz_D2_y
  	 if (v_flag>0)
  	 	duplicate /o BZ_D2_y, $("BZ_D2_y"+suffix)
 		duplicate /o BZ_D2_x, $("BZ_D2_x"+suffix)
 		Wave y_copy=$("BZ_D2_y"+suffix)
  		Wave x_copy=$("BZ_D2_x"+suffix)
  		display_XYwave(y_copy,x_copy,appendflag,0)
  		Killwaves /Z y_copy,x_copy
   		//display_XYwave(BZ_D2_y,BZ_D2_x,appendflag,0)
  	 endif
   
   setDatafolder DF	
End

static Function Proc_bt_updateBZ_proc(ctrlname)
	string ctrlname

    Proc_bt_updateBZ("dummy")  
    controlinfo DrawBZ_lb0
    proc_lb_SelBZdisp("dummy",v_value,0,4)  
    controlinfo DRawBZ_bck0
    if (v_value)
    Proc_ck_updateCrossBZ("DRawBZ_bck0",v_value)
    endif
     controlinfo DRawBZ_bck1
    if (v_value)
    Proc_ck_updateCrossBZ("DRawBZ_bck1",v_value)
    endif  
End


Static Function Proc_bt_3DplotBZ(ctrlname)
	String ctrlname

    	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
    	DFREF DFR_load=$DF_global
    	SetActivesubwindow $winname(0,65)
   	SetDatafolder DFR_panel
   	NVAR gv_BZtype=DFR_load:gv_BZtype
   
   	NVAR gV_uca=DFR_load:gv_uca
   	NVAR gV_ucb=DFR_load:gv_ucb
   	NVAR gV_ucc=DFR_load:gv_ucc
   
   	NVAR gV_alphaA=DFR_load:gv_alphaA
   	NVAR gv_betaA=DFR_load:gv_betaA
   	NVAR gv_gammaAA=DFR_load:gv_gammaAA
   	NVAR gv_sampleOrientation=DFR_panel:gv_BZ_rotate//DFR_load:gv_sampleOrientation
   
   	NVAR gv_A1=DFR_panel:gv_A1
   	NVAR gv_B1=DFR_panel:gv_B1
   	NVAR gv_C1=DFR_panel:gv_C1
   	NVAR gv_PL=DFR_panel:gv_PL
   	NVAR gv_BZ_3d_dk=DFR_panel:gv_BZ_3d_dk
   
  	 Wave BZlist=DFR_panel:BZlist
   
   	Make /o/n=3 a,b,c,temp1,temp2,temp3,astar_3D,bstar_3D,cstar_3D,BZPoint_temp,Point
   	
   
   	Variable temp,d2r=pi/180
   	Variable betaA,gammaA,alphaA
   	betaA=gv_betaA*d2r
   	gammaA=gv_gammaAA*d2r
   	alphaA=gv_alphaA*d2r
   
	if ((betaA+gammaA)<=alphaA)
		doalert 0,"Parameter error!"
		return 0
	endif

	if ((betaA>pi/2)||(alphaA>pi/2)||(gammaA>pi/2))
		doalert 0,"Parameter error!"
		return 0
	endif

	switch(gv_Bztype)
	case 1:
		a={gv_uca,0,0}
		b={gv_ucb*cos(alphaA),gv_ucb*sin(alphaA),0}
		temp=(gv_ucc*(cos(gammaA)-cos(betaA)*cos(alphaA))/sin(alphaA))
		c={gv_ucc*cos(betaA),temp, sqrt((gv_ucc*sin(betaA))^2-temp^2)}
		break
	case 2://bcc
		a={gv_uca,0,0}
		b={gv_ucb*cos(alphaA),gv_ucb*sin(alphaA),0}
		c={gv_uca/2,gv_ucb/2,gv_ucc/2}
		break
	case 3://fcc
		a={gv_uca/2,0,gv_ucc/2}
		b={0,gv_ucb/2,gv_ucc/2}
		c={gv_uca/2,gv_ucb/2,0}
		break
	case 4://Tcc
		a={gv_uca,0,0}
		b={gv_ucb*cos(alphaA),gv_ucb*sin(alphaA),0}
		c={gv_uca/2,0,gv_ucc/2}
		break
	endswitch

	Matrixcross(a,b)
	Wave w_result
	temp1=w_result
	Matrixcross(b,c)
	Wave w_result
	temp2=w_result
	Matrixcross(c,a)
	Wave w_result
	temp3=w_result

	astar_3D=2*pi/matrixdot(a,temp2)*temp2
	bstar_3D=2*pi/matrixdot(b,temp3)*temp3
	cstar_3D=2*pi/matrixdot(c,temp1)*temp1 //Cal K*

	astar_3D=(abs(astar_3D[p])<1e-6)?(0):(astar_3D[p])
	bstar_3D=(abs(bstar_3D[p])<1e-6)?(0):(bstar_3D[p])
	cstar_3D=(abs(cstar_3D[p])<1e-6)?(0):(cstar_3D[p])
   
    	killwaves/Z w_result,a,b,c,temp1,temp2,temp3
    

	
    
   	Variable Zkz
 	zKz=matrixsum(astar_3D)/2
 
 	Variable A1,B1,C1


 	A1=astar_3D[0]/zkz/2

	B1=astar_3D[1]/zkz/2

	C1=astar_3D[2]/zkz/2

   
  	Variable  temp_PL=-zkz+gv_BZ_3d_dk
 
   	Variable index,Pnum,PnumALL,Pindex
   	Variable Bzh,BZl,BZk
   	
   	
   
   	Make /o/n=1 BZ_3D_x,BZ_3D_y,BZ_3D_z
   
  	do
   
   		if (Bz_Create_All(gv_uca,gv_ucb,gv_ucc,gv_alphaA*d2r,gv_betaA*d2r,gv_gammaAA*d2r,gv_Bztype,0,A1,B1,C1,temp_PL,0,0,0,1)==0)
  			 SetDatafolder DF
   			return 1
  		 endif
   	
  		 Point={temp_PL*A1,temp_PL*B1,temp_PL*C1}
   
  		Wave BZ_x,BZ_y
   		Wave Rx,Rz
   
   		Pnum=numpnts(BZ_x)
   
   		Insertpoints inf,Pnum, BZ_3D_x,BZ_3D_y,BZ_3D_z
   		PnumALL=numpnts(BZ_3D_x)
   		Pindex=0
   	 	do 
   	 		BZPoint_temp={BZ_x[Pindex],BZ_y[pindex],0}
   	 		MatrixMultiply Rz,Rx,BZPoint_temp
   	 		Wave M_product
   	 		
   	 		if ((M_product[0]<zkz*2)&&(M_product[1]<zkz*2)&&(M_product[2]<zkz*2))
   	 			BZ_3D_x[PnumALL-1-Pnum+Pindex]=M_product[0]+Point[0]
  				BZ_3D_y[PnumALL-1-Pnum+Pindex]=M_product[1]+Point[1]
   				BZ_3D_z[PnumALL-1-Pnum+Pindex]=M_product[2]+Point[2]
   	 		endif
   	 		
   	 		
   	 		Pindex+=1
   	 	while (Pindex<pnum)
   	
  		 temp_PL+=gv_BZ_3d_dk
   while (temp_PL<(Zkz-gv_BZ_3d_dk))
   
  
   zKz=matrixsum(bstar_3D)/2
  
   A1=bstar_3D[0]/zkz/2
   B1=bstar_3D[1]/zkz/2
   C1=bstar_3D[2]/zkz/2
  // slider  DrawBZ_sl0,limits={0,Zkz,0.005}
   temp_PL=-zkz+gv_BZ_3d_dk
   
   do 
   

   if (Bz_Create_All(gv_uca,gv_ucb,gv_ucc,gv_alphaA*d2r,gv_betaA*d2r,gv_gammaAA*d2r,gv_Bztype,0,A1,B1,C1,temp_PL,0,0,0,1)==0)
  	 SetDatafolder DF
  	 return 1
   endif
   
   Point={temp_PL*A1,temp_PL*B1,temp_PL*C1}
   
   Wave BZ_x,BZ_y
   Pnum=numpnts(BZ_x)
    
   Insertpoints inf,Pnum, BZ_3D_x,BZ_3D_y,BZ_3D_z
   PnumALL=numpnts(BZ_3D_x)
    Pindex=0
   	 	do 
   	 	BZPoint_temp={BZ_x[Pindex],BZ_y[pindex],0}
   	 	MatrixMultiply RZ,Rx,BZPoint_temp
   	 	Wave M_product
   	 	if ((M_product[0]<zkz*2)&&(M_product[1]<zkz*2)&&(M_product[2]<zkz*2))
   	 		BZ_3D_x[PnumALL-1-Pnum+Pindex]=M_product[0]+Point[0]
  			BZ_3D_y[PnumALL-1-Pnum+Pindex]=M_product[1]+Point[1]
   			BZ_3D_z[PnumALL-1-Pnum+Pindex]=M_product[2]+Point[2]
   	 	endif
   	 	Pindex+=1
   	 	while (Pindex<pnum)
        
   temp_PL+=gv_BZ_3d_dk
   while (temp_PL<(Zkz-gv_BZ_3d_dk))
   
    zKz=matrixsum(cstar_3D)/2
  // if (gv_BZtype==3)
   //Zkz=2*pi/gV_ucb
  // else
  // Zkz=pi/gV_ucb
  // endif
  
  //  gv_A1=0
  // gv_B1=0
   //gv_C1=1
   A1=cstar_3D[0]/zkz/2
   B1=cstar_3D[1]/zkz/2
   C1=cstar_3D[2]/zkz/2
  // slider  DrawBZ_sl0,limits={0,Zkz,0.005}
   temp_PL=-zkz+gv_BZ_3d_dk
   
   do 
  
   if (Bz_Create_All(gv_uca,gv_ucb,gv_ucc,gv_alphaA*d2r,gv_betaA*d2r,gv_gammaAA*d2r,gv_Bztype,0,A1,B1,C1,temp_PL,0,0,0,1)==0)
   SetDatafolder DF
   return 1
   endif
   Point={temp_PL*A1,temp_PL*B1,temp_PL*C1}
   Wave BZ_x,BZ_y
   
   Pnum=numpnts(BZ_x)
   Insertpoints inf,Pnum, BZ_3D_x,BZ_3D_y,BZ_3D_z
   PnumALL=numpnts(BZ_3D_x)
   Pindex=0
   	 	do 
   	 	BZPoint_temp={BZ_x[Pindex],BZ_y[pindex],0}
   	 	MatrixMultiply RZ,Rx,BZPoint_temp
   	 	Wave M_product
   	 	if ((M_product[0]<zkz*2)&&(M_product[1]<zkz*2)&&(M_product[2]<zkz*2))
   	 		BZ_3D_x[PnumALL-1-Pnum+Pindex]=M_product[0]+Point[0]
  			BZ_3D_y[PnumALL-1-Pnum+Pindex]=M_product[1]+Point[1]
   			BZ_3D_z[PnumALL-1-Pnum+Pindex]=M_product[2]+Point[2]
   	 	endif
   	 	Pindex+=1
   	 	while (Pindex<pnum)
   
     
   temp_PL+=gv_BZ_3d_dk
   while (temp_PL<(Zkz-gv_BZ_3d_dk))
   
  
	//Pnum=dimsize(BZ_3D_x,0)/3
	
	index=0
	Variable Bindex,Vtemp1,Vtemp2,Vtemp3
	String indexlist=""
	do 
	  Bindex=index+1
	  do
	  	if (Bindex>=(numpnts(BZ_3D_x)-1))
	  		break
	  	endif
	  
	 	 Vtemp1=abs(BZ_3D_x[index]-BZ_3D_x[Bindex])
	 	 Vtemp2=abs(BZ_3D_y[index]-BZ_3D_y[Bindex])
	 	 Vtemp3=abs(BZ_3D_z[index]-BZ_3D_z[Bindex])
	  
	  	if ((Vtemp1^2+Vtemp2^2+Vtemp3^2)<1e-4)
	  		deletepoints Bindex,1,BZ_3D_x,BZ_3D_y,BZ_3D_z
	 		continue
	 	 endif

	 	 if (abs(BZ_3D_x[Bindex]^2+BZ_3D_y[Bindex]^2+BZ_3D_z[Bindex]^2)<1e-5)
	 	 	deletepoints Bindex,1,BZ_3D_x,BZ_3D_y,BZ_3D_z
	 		continue
	 	 endif
	  	  
	  Bindex+=1
	  while (Bindex<numpnts(BZ_3D_x))
	index+=1
    while (index<numpnts(BZ_3D_x))
    
   // print Bindex,BZ_3D_x[Bindex]^2+BZ_3D_y[Bindex]^2+BZ_3D_z[Bindex]^2
    
     if (abs(BZ_3D_x[Bindex]^2+BZ_3D_y[Bindex]^2+BZ_3D_z[Bindex]^2)<1e-5)
	 	 redimension /N= (numpnts(BZ_3D_x)-1) ,BZ_3D_x,BZ_3D_y,BZ_3D_z
     endif
    
    
   make /o/n=(0,3),BZ_tripletWave
   Make /o/n=3 RT
    
    index=0
    do
    RT=BZList[index][0]*astar_3D+BZList[index][1]*bstar_3D+BZList[index][2]*cstar_3D
   
    duplicate /o BZ_3D_x,BZ_3D_xtemp
    duplicate /o BZ_3D_y,BZ_3D_ytemp
    duplicate /o BZ_3D_z,BZ_3D_ztemp
    
    BZ_3D_xtemp+=RT[0]
    BZ_3D_ytemp+=RT[1]
    BZ_3D_ztemp+=RT[2]
    
    Concatenate /o {BZ_3D_xtemp,BZ_3D_ytemp,BZ_3D_ztemp}, BZ_tripletWave_temp
    
    Pnum=dimsize(BZ_tripletWave_temp,0)
    Insertpoints inf,Pnum, BZ_tripletWave
    PnumALL=dimsize(BZ_tripletWave,0)
    BZ_tripletWave[PnumALL-Pnum,PnumALL-1][]=BZ_tripletWave_temp[p-Pnumall+Pnum][q]
      
   index+=1
   while (index<dimsize(BZlist,0))
   
   
   
  // Killwaves/Z BZ_3D_x,BZ_3D_y,BZ_3D_z,a,b,c,astar_3D,bstar_3D,cstar_3D,BZPoint_temp,RT,temp1,temp2,temp3,BZ_3D_xtemp,BZ_3D_ytemp,BZ_3D_ztemp,BZ_tripletWave_temp
   
   String winame=winname(0,4096)
   if (strlen(winame)==0)
  	 	string cmd="newGizmo /N=BZ_3D_show"
  		Execute cmd
   		cmd= "ModifyGizmo aspectRatio=1"
   		Execute cmd
   		cmd="modifyGizmo showAxisCue=1"
   		Execute cmd
   		//cmd=
   else
   		if (stringmatch(winame,"BZ_3D_show")==0)
   			cmd="newGizmo /N=BZ_3D_show"
  		 	Execute cmd
   			cmd= "ModifyGizmo aspectRatio=1"
   			Execute cmd
   		endif
   endif
   Dowindow /F BZ_3D_show
   cmd="RemoveFromGizmo /Z /N=BZ_3D_show object=BZ_3D"
   Execute cmd
   cmd="AppendToGizmo /N=BZ_3D_show/D scatter=BZ_tripletWave name=BZ_3D"
   
  // Defaultscatter
   Execute cmd
   cmd= "ModifyGizmo modifyObject=BZ_3D, property={size, 0.1}"
  Execute cmd
  cmd= "ModifyGizmo modifyObject=BZ_3D, property={shape, 1}"
 Execute cmd
   
   SetDatafolder DF
End


Static Function proc_lb_SelBZdisp(ctrlName,row,col,event) : ListboxControl
	String ctrlName     // name of this control
	Variable row        // row if click in interior, -1 if click in title
	Variable col        // column number
	Variable event      // event code
	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
    	DFREF DFR_load=$DF_global
 	SetActivesubwindow $winname(0,65)
  	 SetDatafolder DFR_panel
   	NVAR gv_BZtype=DFR_load:gv_BZtype
   
   	NVAR gV_uca=DFR_load:gv_uca
   	NVAR gV_ucb=DFR_load:gv_ucb
   	NVAR gV_ucc=DFR_load:gv_ucc
   
   	NVAR gV_alphaA=DFR_load:gv_alphaA
   	NVAR gv_betaA=DFR_load:gv_betaA
   	NVAR gv_gammaAA=DFR_load:gv_gammaAA
   	NVAR gv_sampleOrientation=DFR_panel:gv_BZ_rotate//DFR_load:gv_sampleOrientation
   
   	NVAR gv_A1=DFR_panel:gv_A1
   	NVAR gv_B1=DFR_panel:gv_B1
   	NVAR gv_C1=DFR_panel:gv_C1
   	NVAR gv_PL=DFR_panel:gv_PL
   
   	Wave BZlist=DFR_panel:BZlist
   
   	if (event==4)
   		Variable d2r=pi/180
	
  		 Variable index,gammaindex,Pnum,PnumALL
   			Variable Bzh,BZl,BZk
  		 //Make /o/n=1 BZAll_x,BZAll_y,GammaA_x,GammaA_y
  		 index=row
   		BZh=BZlist[index][0]
  		 BZl=BZlist[index][1]
  		 BZk=BZlist[index][2]
   
   		if (Bz_Create_All(gv_uca,gv_ucb,gv_ucc,gv_alphaA*d2r,gv_betaA*d2r,gv_gammaAA*d2r,gv_Bztype,gv_sampleOrientation,gv_A1,gv_B1,gv_C1,gv_PL,BZh,BZl,BZk,0)==0)
  			 SetDatafolder DF
   			return 1
   		endif
   
 	 Wave BZ_x,BZ_y,Gamma_x,Gamma_y
 	  duplicate /o BZ_y,BZ_sel_y
  	 duplicate /o BZ_x,BZ_sel_x
  	 if (traceexist(winname(0,65),"BZ_sel_y",1)==0)
   	appendtograph BZ_sel_y vs BZ_sel_x
   	//appendtograph ,Gamma_x,Gamma_y
   	ModifyGraph lsize(BZ_sel_y)=2,rgb(BZ_sel_y)=(0,0,52224)
   else
   
   endif
   
   endif
   
   SetDatafolder DF
   return 0            // other return values reserved
End

Static Function Updata_BZ_SL(name, value, event) : SliderControl
		String name	// name of this slider control
		Variable value	// value of slider
		Variable event	// bit field: bit 0: value set; 1: mouse down, 
					//   2: mouse up, 3: mouse moved
		Proc_bt_updateBZ_proc("dummy") 						
	 	
		return 0	// other return values reserved
	End

Static Function Proc_bt_SetDefaultBZ(ctrlname)
	String ctrlname
	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
   	 DFREF DFR_load=$DF_global
    	SetActivesubwindow $winname(0,65)
   	 SetDatafolder DFR_panel
  	 NVAR gv_BZtype=DFR_load:gv_BZtype
   
  	NVAR gV_uca=DFR_load:gv_uca
   	NVAR gV_ucb=DFR_load:gv_ucb
   	NVAR gV_ucc=DFR_load:gv_ucc
   
   	NVAR gV_alphaA=DFR_load:gv_alphaA
   	NVAR gv_betaA=DFR_load:gv_betaA
   	NVAR gv_gammaAA=DFR_load:gv_gammaAA
   	NVAR gv_sampleOrientation=DFR_panel:gv_BZ_rotate//DFR_load:gv_sampleOrientation
   
   	NVAR gv_A1=DFR_panel:gv_A1
   	NVAR gv_B1=DFR_panel:gv_B1
   	NVAR gv_C1=DFR_panel:gv_C1
   	NVAR gv_PL=DFR_panel:gv_PL
   
   	Variable Zkz
   	if (gv_BZtype==1)
   		Zkz=pi/gV_ucc
  	 else
  		 Zkz=2*pi/gV_ucc
   	endif
   
   	strswitch(ctrlname)
   	case "DRawBZ_bt3": //kxky_Gamma
   		gv_A1=0
  		 gv_B1=0
  		 gv_C1=1
  		 gv_PL=0
   		slider  DrawBZ_sl0,limits={0,Zkz,0.005}
  		break
   	case "DRawBZ_bt7": //kxky_Z
  		 gv_A1=0
  		 gv_B1=0
   		gv_C1=1
   		gv_PL=Zkz
   		slider  DrawBZ_sl0,limits={0,Zkz,0.005}
   		break
   	case "DRawBZ_bt4":// kxkz 010
   		gv_A1=0
   		gv_B1=1
   		gv_C1=0
   		gv_PL=0
   		slider  DrawBZ_sl0,limits={0,pi/gv_ucb,0.005}
   		break
   	case "DRawBZ_bt5":// kxkz 010
   		gv_A1=1
  		 gv_B1=0
  		 gv_C1=0
   		gv_PL=0
   		slider  DrawBZ_sl0,limits={0,pi/gv_uca,0.005}
   		break
  	 case "DRawBZ_bt6":// kxkz 010
   		gv_A1=1
		gv_B1=1
   		gv_C1=0
   		gv_PL=0
   		slider  DrawBZ_sl0,limits={0,sqrt((pi/gv_uca)^2+(pi/gv_ucb)^2),0.005}
   		break
   
   Endswitch 
   
   Proc_bt_updateBZ_proc("dummy") 		
  // Wave BZlist=DFR_panel:BZlist
  
  SetDatafolder DF
End

Static Function Updata_BZ_SV(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	Proc_bt_updateBZ_proc("dummy") 		
End

Static Function Proc_bt_delPointBZ(ctrlname)
	String ctrlname
	
	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
    DFREF DFR_load=$DF_global
    SetActivesubwindow $winname(0,65)
    Wave BZlist=DFR_panel:BZlist
    Wave /T BZ_displist=DFR_panel:BZ_displist
    Wave BZ_displist_sel=DFR_panel:BZ_displist_sel
    
  	controlinfo  DrawBZ_lb0   
  	Variable delnum=V_Value
  	
  	Variable pnt=numpnts(BZ_displist)
  	if (pnt==1) 
  	BZ_displist="0,0,0"
  	BZlist=0
  	BZ_displist_sel=0
  	Proc_bt_updateBZ("dummy")  
  	ListBox DrawBZ_lb0,selRow=0
    proc_lb_SelBZdisp("dummy",0,0,4)     
  	return 1
  	Endif
    deletepoints delnum,1,BZlist,BZ_displist,BZ_displist_sel
    Proc_bt_updateBZ_proc("dummy") 		
End

Static Function Proc_bt_AddPointBZ(ctrlname)
	String ctrlname
	
	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
    DFREF DFR_load=$DF_global
    SetActivesubwindow $winname(0,65)
    Wave BZlist=DFR_panel:BZlist
    Wave /T BZ_displist=DFR_panel:BZ_displist
    Wave BZ_displist_sel=DFR_panel:BZ_displist_sel
    
    NVAR gv_BZh=DFR_panel:gv_BZh
    NVAR gv_BZl=DFR_panel:gv_BZl
    NVAR gv_BZk=DFR_panel:gv_BZk
    
    Variable pnt=numpnts(BZ_displist)
    
    Insertpoints 0,1,BZlist,BZ_displist,BZ_displist_sel
    BZlist[0][0]=gv_BZh
    BZlist[0][1]=gv_BZl
    BZlist[0][2]=gv_BZk
    
    BZ_displist[0]=num2str(gv_BZh)+","+num2str(gv_BZl)+","+num2str(gv_BZk)
    BZ_displist_sel[0]=0
    Proc_bt_updateBZ("dummy")  
    ListBox DrawBZ_lb0,selRow=0
    proc_lb_SelBZdisp("dummy",0,0,4) 
    Proc_bt_updateBZ_proc("dummy") 		
    
End



Function Proc_bt_updateBZ(ctrlname)
 	string ctrlname
 	
 	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
    DFREF DFR_load=$DF_global
    SetActivesubwindow $winname(0,65)
    SetDatafolder DFR_panel
   NVAR gv_BZtype=DFR_load:gv_BZtype
   
   NVAR gV_uca=DFR_load:gv_uca
   NVAR gV_ucb=DFR_load:gv_ucb
   NVAR gV_ucc=DFR_load:gv_ucc
   
   NVAR gV_alphaA=DFR_load:gv_alphaA
   NVAR gv_betaA=DFR_load:gv_betaA
   NVAR gv_gammaAA=DFR_load:gv_gammaAA
   NVAR gv_sampleOrientation=DFR_panel:gv_BZ_rotate//DFR_load:gv_sampleOrientation
   
   NVAR gv_A1=DFR_panel:gv_A1
   NVAR gv_B1=DFR_panel:gv_B1
   NVAR gv_C1=DFR_panel:gv_C1
   NVAR gv_PL=DFR_panel:gv_PL
   
   Wave BZlist=DFR_panel:BZlist
   
   Variable d2r=pi/180
   Variable index,gammaindex,Pnum,PnumALL
   Variable Bzh,BZl,BZk
   Make /o/n=1 BZ_All_x,BZ_All_y,Gamma_All_x,Gamma_All_y
   do
   
   BZh=BZlist[index][0]
   BZl=BZlist[index][1]
   BZk=BZlist[index][2]
   
   if (Bz_Create_All(gv_uca,gv_ucb,gv_ucc,gv_alphaA*d2r,gv_betaA*d2r,gv_gammaAA*d2r,gv_Bztype,gv_sampleOrientation,gv_A1,gv_B1,gv_C1,gv_PL,BZh,BZl,BZk,0)==0)
   SetDatafolder DF
   return 1
   endif
   
   Wave BZ_x,BZ_y,Gamma_x,Gamma_y
   Pnum=numpnts(BZ_x)
   
   Insertpoints inf,Pnum+1, BZ_All_x,BZ_All_y
   PnumALL=numpnts(BZ_All_x)
   BZ_All_x[PnumALL-2-Pnum,PnumALL-3]=BZ_x[p-Pnumall+2+Pnum]
   BZ_All_y[PnumALL-2-Pnum,PnumALL-3]=BZ_y[p-Pnumall+2+Pnum]
   BZ_All_x[PnumALL-2]=Nan
   BZ_All_y[PnumALL-2]=Nan
   
   Insertpoints inf,2, Gamma_All_x,Gamma_All_y
   Gamma_All_x[GammaIndex*2]=Gamma_x[0]
   Gamma_All_y[GammaIndex*2]=Gamma_y[0]
   Gamma_All_x[GammaIndex*2+1]=Nan
   Gamma_All_y[GammaIndex*2+1]=Nan
   Gammaindex+=1
   
   index+=1
   while (index<dimsize(BZlist,0))
   
   PnumALL=numpnts(BZ_All_x)
   Deletepoints PnumALL-1,1,BZ_All_x,BZ_All_y
   PnumALL=numpnts(Gamma_All_x)
   Deletepoints PnumALL-1,1,Gamma_All_x,Gamma_All_y
  
   
   SetDatafolder DF
End



static Function rotate_BZ_proc(azi, point_x, point_y, flag)
Variable azi
Variable point_x, point_y
Variable flag

DFREF DF = GetDataFolderdfr()
//SetDataFolder root:internaluse:planner

	Variable d2r = pi/180
	Make/o/n=3  vertex
	Make/o/n=(3,3) R1

	vertex = {point_x, point_y, 0}
	R1 = { {cos(d2r*azi),sin(d2r*azi),0}, {-sin(d2r*azi),cos(d2r*azi),0}, {0,0,1} }
	MatrixMultiply R1,vertex

	WAVE M_product
	if (flag==1)
	Killwaves /Z Vertex,R1
	SetDataFolder DF
	return M_product[1][0]
	else
	Killwaves /Z Vertex,R1
	SetDataFolder DF
	return M_product[0][0]
	endif
    
end



static Function Proc_add3D_to_BZ(ctrlname):ButtonControl
	String ctrlname
	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_load=$DF_global
	SetDatafolder DFR_panel
	SetActivesubwindow $winname(0,65)
	NVAR gv_th, gv_ph, gv_azi,gv_deflectorY
	NVAR gv_InnerE=DFR_load:gv_InnerE
 	NVAR gv_photonE=DFR_load:gv_photonE
 	NVAR gv_wf=DFR_load:gv_workfn
 	
	Variable  Ef=gv_photonE-gv_wf
	Variable E = Ef*1.602e-19
	variable mass = 9.1095e-31
	variable hbar = 1.05459e-34
	variable kvac = sqrt((2*mass*E)/hbar^2)*1e-10

	// in inverse angstoms
	NVAR gv_gammaA=DFR_load:gv_gammaA
	NVAR gv_InnerE=DFR_load:gv_InnerE
	NVAR gv_SamthetaOff=DFR_load:gv_SamthetaOff
	NVAR gv_SamphiOff=DFR_load:gv_Samphioff
	NVAR gv_SamaziOff=DFR_load:gv_SamaziOff
	NVAR gv_SampleOrientation=DFR_load:gv_sampleorientation
	
	Wave XCuts_sel=DFR_panel:XCuts_sel
	Wave YCuts_sel=DFR_panel:YCuts_sel

	NVAR gv_CutangleT,gv_CutangleF
	NVAR gv_curveflag=DFR_panel:gv_curveflag

	String Wnamex,Wnamey,WnameZ,SampleTemp_x,SampleTemp_y,SampleTemp_z
	variable m,n,kxtemp,kytemp,kztemp,EZ
	Variable CutangleF,CutangleT,Cutanglenum
	
	
	Controlinfo DrawCuts_ck01
	if (v_value)
		CutangleF=gv_CutangleF
		CutangleT=gv_CutangleT
	else
		NVAR gv_sliceF,gv_sliceT,gv_slicenum

		CutangleF=gv_sliceF*(gv_CutangleT-gv_CutangleF)/gv_slicenum+gv_CutangleF
		CutangleT=gv_sliceT*(gv_CutangleT-gv_CutangleF)/gv_slicenum+gv_CutangleF
	endif
	String kzstr=replacestring(".",num2str(gv_photonE),"_",0,1)
	
	wnamex="X3DCuts_T"+num2str(gv_th+gv_Samthetaoff)+"P"+num2str(gv_ph+gv_samphioff)+"A"+num2str(gv_azi+gv_samazioff)+"Ph"+kzstr
	wnamey="Y3DCuts_T"+num2str(gv_th+gv_Samthetaoff)+"P"+num2str(gv_ph+gv_samphioff)+"A"+num2str(gv_azi+gv_samazioff)+"Ph"+kzstr
	wnamez="Z3DCuts_T"+num2str(gv_th+gv_Samthetaoff)+"P"+num2str(gv_ph+gv_samphioff)+"A"+num2str(gv_azi+gv_samazioff)+"Ph"+kzstr
	String wname3D="Cuts3D_T"+num2str(gv_th+gv_Samthetaoff)+"P"+num2str(gv_ph+gv_samphioff)+"A"+num2str(gv_azi+gv_samazioff+gv_SampleOrientation)+"Ph"+kzstr
	
	String notestr=new_cuts_note(gv_photonE,gv_wf,gv_InnerE,gv_th,gv_samthetaoff,gv_ph,gv_samphioff,gv_azi,gv_samazioff,gv_deflectorY,gv_gammaA,CutangleF,CutangleT)



	newDatafolder /o/s CutKxKy

	Controlinfo DrawCuts_ck03

	if (v_value)

		Cutanglenum=1

		sampletemp_x = cleanupname(wnamex,0)//uniquename(wnamex,1,0)
		sampletemp_y = cleanupname(wnamey,0)//uniquename(wnamey,1,0)
		sampletemp_z = cleanupname(wnamez,0)//uniquename(wnamey,1,0)
		make/o/n=(Cutanglenum)  $sampletemp_x, $sampletemp_y,$sampletemp_z
		wave stx = $sampletemp_x
		wave sty = $sampletemp_y
		Wave stz = $sampletemp_z

		Setscale /P x, (CutangleF+CutangleT)/2,0.1,stx,sty,stz

	else

		Cutanglenum=round((CutangleT-CutangleF)/0.3)+1

		sampletemp_x = cleanupname(wnamex,0)//uniquename(wnamex,1,0)
		sampletemp_y = cleanupname(wnamey,0)//uniquename(wnamey,1,0)
		sampletemp_z = cleanupname(wnamez,0)
		make/o/n=(Cutanglenum)  $sampletemp_x, $sampletemp_y,$sampletemp_z
		wave stx = $sampletemp_x
		wave sty = $sampletemp_y
		Wave stz = $sampletemp_z
		Setscale /I x, CutangleF,CutangleT,stx,sty,stz

	endif
	
	stx=flip_to_k(kvac,gv_innerE,gv_th+gv_samthetaoff,gv_ph+gv_samphioff,gv_azi+gv_samazioff+gv_SampleOrientation,x,gv_gammaA,0,gv_curveflag)
	sty=flip_to_k(kvac,gv_innerE,gv_th+gv_samthetaoff,gv_ph+gv_samphioff,gv_azi+gv_samazioff+gv_SampleOrientation,x,gv_gammaA,1,gv_curveflag)
	stz=flip_to_k(kvac,gv_innerE,gv_th+gv_samthetaoff,gv_ph+gv_samphioff,gv_azi+gv_samazioff+gv_SampleOrientation,x,gv_gammaA,2,gv_curveflag)
	
	note sty,notestr
	note stx,notestr
	note stz,notestr
	
	wname3D= cleanupname(wname3D,0)

	Concatenate /o {stx,sty,stz}, $wname3D
	
	Killwaves /Z stx,sty,stz
    	
    	Wave Cut3D=$wname3D
  

	String winame=winname(0,4096)
	if (strlen(winame)==0)
		Proc_bt_3DplotBZ("dummy")
  	endif
  	string  cmd="removefromGizmo /Z/N=BZ_3D_show  object="+wname3D
  	Execute cmd
  	
  	cmd="AppendToGizmo /N=BZ_3D_show/D  path="+wname3D+", name="+wname3D
   	Execute cmd
   	
   	cmd="ModifyGizmo/N=BZ_3D_show modifyObject="+wname3D+",property={pathcolor,65525,0,0,1}"
   	Execute cmd
   	
   	//cmd="ModifyGizmo/N=BZ_3D_show modifyObject="+wname3D+",property={linewidth,10}"
   	//Execute cmd
   //	 linewidth=2, 
  	// cmd= "ModifyGizmo modifyObject=Scatter0, property={size, 0.1}"
   	//Execute cmd
		
	KillWaves/Z R1,R2,R3,s_angle,k,M_Product
	SetDataFolder DF
End


static Function  Proc_add_Cut_to_BZ(ctrlName) : ButtonControl
	String ctrlname
	
	SetActivesubwindow $winname(0,65)
	
	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_load=$DF_global
	
	String winame=winname(0,65)
	
	controlinfo DrawCuts_ck08
	Variable plot3Dflag= v_value
	
	
	
	if (stringmatch(Ctrlname,"DrawCuts_BZAddCut"))
		if (plot3Dflag)
			Proc_add3D_to_BZ(ctrlname)
		else
			Proc_add_to_BZ(ctrlName) 
		endif
	elseif (stringmatch(Ctrlname,"DrawCuts_BZAddZCut"))
		if (plot3Dflag)
			Proc_add3D_to_BZ(ctrlname)
		else
			Proc_add_to_BZ(ctrlName) 
		endif
	else
		SVAR gs_theta=DFR_panel:gs_theta
		SVAR gs_phi=DFR_panel:gs_phi
		SVAR gs_azi=DFR_panel:gs_azi
		SVAR gs_photonE=DFR_panel:gs_photonE
		NVAR gv_angdelta=DFR_panel:gv_angdelta
		string theta,phi,azi,photonE
		Variable angdelta
		
		theta=gs_theta
		phi=gs_phi
		azi=gs_azi
		photonE=gs_photonE
		angdelta=gv_angdelta
		
		prompt theta,"Input theta range:"
		prompt phi,"Input phi range:"
		prompt azi,"Input azi range:"
		prompt photonE,"Input photonE range:"
		prompt angdelta,"Input delta size:"
		
		doprompt "Input for add multiple cuts",theta,phi,azi,photonE,angdelta
		
		if (V_flag==1)
			return 0
		endif
		
		Variable index,mapflag
		variable angfrom,angto,angnum
		
		if (strsearch(theta,",",0)>0)
			mapflag=1
			sscanf theta,"%g,%g",angfrom,angto
			NVAR changeval=DFR_panel:gv_th
		elseif (strsearch(phi,",",0)>0)	
			mapflag=2
			sscanf phi,"%g,%g",angfrom,angto
			NVAR changeval=DFR_panel:gv_ph
		elseif (strsearch(azi,",",0)>0)	
			mapflag=3
			sscanf azi,"%g,%g",angfrom,angto
			NVAR changeval=DFR_panel:gv_azi
		elseif (strsearch(photonE,",",0)>0)
			mapflag=4
			sscanf photonE,"%g,%g",angfrom,angto
			NVAR changeval=DFR_load:gv_photonE
		else 
			return 0
		endif			 
		
		if ((numtype(angfrom)==2)||(numtype(angto)==2))
			return 0
		endif
		
		angnum=abs(angfrom-angto)/abs(angdelta)+1
		if (angto>angfrom)
			angdelta=abs(angdelta)
		else
			angdelta=-abs(angdelta)
		endif
		
		do
			changeval=angfrom+angdelta*index
			dowindow /F $winame
			if (plot3Dflag)
				Proc_add3D_to_BZ(ctrlname)
			else
				if (mapflag==4)
					Proc_add_to_BZ("DrawCuts_BZAddZCut")
				else
					Proc_add_to_BZ("DrawCuts_BZAddCut")
				endif
			endif
			index+=1
		while (index<angnum)
		
		gs_theta=theta
		gs_phi=phi
		gs_azi=azi
		gs_photonE=photonE
		gv_angdelta=angdelta
		
	endif
	
	SetDatafolder DF
End

static Function Proc_add_to_BZ(ctrlName) : ButtonControl
	String ctrlName
    	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_load=$DF_global
	SetDatafolder DFR_panel
	SetActivesubwindow $winname(0,65)
	NVAR gv_th, gv_ph, gv_azi, gv_deflectorY
	NVAR gv_InnerE=DFR_load:gv_InnerE
 	NVAR gv_photonE=DFR_load:gv_photonE
 	NVAR gv_wf=DFR_load:gv_workfn
 	
	Variable  Ef=gv_photonE-gv_wf
	Variable E = Ef*1.602e-19
	variable mass = 9.1095e-31
	variable hbar = 1.05459e-34
	variable kvac = sqrt((2*mass*E)/hbar^2)*1e-10

	// in inverse angstoms
	NVAR gv_gammaA=DFR_load:gv_gammaA
	NVAR gv_InnerE=DFR_load:gv_InnerE
	NVAR gv_SamthetaOff=DFR_load:gv_SamthetaOff
	NVAR gv_SamphiOff=DFR_load:gv_Samphioff
	NVAR gv_SamaziOff=DFR_load:gv_SamaziOff
	
	Wave XCuts_sel=DFR_panel:XCuts_sel
	Wave YCuts_sel=DFR_panel:YCuts_sel

	NVAR gv_CutangleT,gv_CutangleF

	String Wnamex,Wnamey,WnameZ,SampleTemp_x,SampleTemp_y
	variable m,n,kxtemp,kytemp,kztemp,EZ
	Variable CutangleF,CutangleT,Cutanglenum
	
	
	Variable kz_flag=0
	if (stringmatch(ctrlName,"DrawCuts_BZAddCut"))
		kz_flag=0
	endif
	if (stringmatch(ctrlName,"DrawCuts_BZAddZCut"))
		kz_flag=1
	endif
	
	
	Controlinfo DrawCuts_ck01
	if (v_value)
		CutangleF=gv_CutangleF
		CutangleT=gv_CutangleT
		wnamex="XCuts_T"+num2str(gv_th+gv_Samthetaoff)+"P"+num2str(gv_ph+gv_samphioff)+"A"+num2str(gv_azi+gv_samazioff)+"D"+num2str(gv_deflectorY)
		wnamey="YCuts_T"+num2str(gv_th+gv_Samthetaoff)+"P"+num2str(gv_ph+gv_samphioff)+"A"+num2str(gv_azi+gv_samazioff)+"D"+num2str(gv_deflectorY)
	else
		NVAR gv_sliceF,gv_sliceT,gv_slicenum

		CutangleF=gv_sliceF*(gv_CutangleT-gv_CutangleF)/gv_slicenum+gv_CutangleF
		CutangleT=gv_sliceT*(gv_CutangleT-gv_CutangleF)/gv_slicenum+gv_CutangleF
		if (gv_gammaA==0)
			wnamex="XCuts_T"+num2str(gv_th+gv_Samthetaoff)+"F"+num2str(floor(gv_SliceF))+"T"+num2str(floor(gv_SliceT))+"D"+num2str(gv_deflectorY)
			wnamey="YCuts_T"+num2str(gv_th+gv_Samthetaoff)+"F"+num2str(floor(gv_SliceF))+"T"+num2str(floor(gv_SliceT))+"D"+num2str(gv_deflectorY)
		else
			wnamex="XCuts_P"+num2str(gv_ph+gv_samphioff)+"F"+num2str(floor(gv_SliceF))+"T"+num2str(floor(gv_SliceT))+"D"+num2str(gv_deflectorY)
			wnamey="YCuts_P"+num2str(gv_ph+gv_samphioff)+"F"+num2str(floor(gv_SliceF))+"T"+num2str(floor(gv_SliceT))+"D"+num2str(gv_deflectorY)
		endif

	endif
	
	String notestr=new_cuts_note(gv_photonE,gv_wf,gv_InnerE,gv_th,gv_samthetaoff,gv_ph,gv_samphioff,gv_azi,gv_samazioff,gv_deflectorY,gv_gammaA,CutangleF,CutangleT)


	if (kz_flag)
		String kzstr=replacestring(".",num2str(gv_photonE),"_",0,1)
		wnamex+="_"+kzstr
		wnamey+="_"+kzstr
	endif

	newDatafolder /o/s CutKxKy

	Controlinfo DrawCuts_ck03

	if (v_value)

		Cutanglenum=1

		sampletemp_x = cleanupname(wnamex,0)//uniquename(wnamex,1,0)
		sampletemp_y = cleanupname(wnamey,0)//uniquename(wnamey,1,0)
		make/o/n=(Cutanglenum)  $sampletemp_x, $sampletemp_y
		wave stx = $sampletemp_x
		wave sty = $sampletemp_y

		Setscale /P x, (CutangleF+CutangleT)/2,0.1,stx,sty

	else

		Cutanglenum=round((CutangleT-CutangleF)/0.3)+1

		sampletemp_x = cleanupname(wnamex,0)//uniquename(wnamex,1,0)
		sampletemp_y = cleanupname(wnamey,0)//uniquename(wnamey,1,0)
		make/o/n=(Cutanglenum)  $sampletemp_x, $sampletemp_y
		wave stx = $sampletemp_x
		wave sty = $sampletemp_y
		Setscale /I x, CutangleF,CutangleT,stx,sty

	endif
	
	NVAR gv_curveflag=DFR_panel:gv_curveflag
	
	
	if (kz_flag)
		if (gv_gammaA==0)
			stx=flip_to_k(kvac,gv_innerE,gv_th+gv_samthetaoff,gv_ph+gv_samphioff,gv_azi+gv_samazioff,x,gv_gammaA,1,gv_curveflag)
			sty=flip_to_k(kvac,gv_innerE,gv_th+gv_samthetaoff,gv_ph+gv_samphioff,gv_azi+gv_samazioff,x,gv_gammaA,2,gv_curveflag)
		else
			stx=flip_to_k(kvac,gv_innerE,gv_th+gv_samthetaoff,gv_ph+gv_samphioff,gv_azi+gv_samazioff,x,gv_gammaA,0,gv_curveflag)
			sty=flip_to_k(kvac,gv_innerE,gv_th+gv_samthetaoff,gv_ph+gv_samphioff,gv_azi+gv_samazioff,x,gv_gammaA,2,gv_curveflag)
		endif
	else
		if((numtype(gv_deflectorY)==2)||(gv_deflectorY ==0))
			stx=flip_to_k(kvac,gv_innerE,gv_th+gv_samthetaoff,gv_ph+gv_samphioff,gv_azi+gv_samazioff,x,gv_gammaA,0,gv_curveflag)
			sty=flip_to_k(kvac,gv_innerE,gv_th+gv_samthetaoff,gv_ph+gv_samphioff,gv_azi+gv_samazioff,x,gv_gammaA,1,gv_curveflag)
		else		
			stx=flip_to_k_DA30(kvac,gv_innerE,gv_th+gv_samthetaoff,gv_ph+gv_samphioff,gv_azi+gv_samazioff,gv_deflectorY,x,gv_gammaA,0,gv_curveflag)
			sty=flip_to_k_DA30(kvac,gv_innerE,gv_th+gv_samthetaoff,gv_ph+gv_samphioff,gv_azi+gv_samazioff,gv_deflectorY,x,gv_gammaA,1,gv_curveflag)
		endif
	endif
	

	removefromgraph /Z $sampleTemp_y
	AppendToGraph  sty vs stx 
	note sty,notestr
	note stx,notestr

	Controlinfo DrawCuts_ck03 //Integrate ,only one point
	if (v_value)
		ModifyGraph mode($sampletemp_y)=3,marker($sampletemp_y)=7,msize($sampletemp_y)=2
		ModifyGraph rgb($sampletemp_y )=(1,4,52428)
	else
		ModifyGraph  mode($sampletemp_y )=3,marker($sampletemp_y )=8,msize($sampletemp_y)=2
		ModifyGraph  rgb($sampletemp_y )=(1,4,52428)
	endif
	
	SVAR gs_Cuts_selname=DFR_panel:gs_Cuts_selname
	gs_Cuts_selname=sampleTemp_y
	duplicate /o sty DFR_panel:YCuts_sel
	duplicate /o stx DFR_panel:XCuts_sel
	update_CutsKxky_sel(1)
	KillWaves/Z R1,R2,R3,s_angle,k,M_Product
	SetDataFolder DF
End


static Function /S new_cuts_note(gv_photonE,gv_wf,gv_InnerE,gv_th,gv_samthetaoff,gv_ph,gv_samphioff,gv_azi,gv_samazioff,gv_deflectorY,gv_gammaA,CutangleF,CutangleT)
	Variable gv_photonE,gv_wf,gv_innerE,gv_th,gv_samthetaoff,gv_ph,gv_samphioff,gv_azi,gv_samazioff,gv_deflectorY
	Variable gv_gammaA,CutangleF,CutangleT
	String notestr
	
	notestr="Cutsnote\r"
	notestr+="PhotonEnergy=\r"
	notestr+="WorkFunction=\r"
	notestr+="InnerE=\r"
	notestr+="theta=\r"
	notestr+="theta_off=\r"
	notestr+="phi=\r"
	notestr+="phi_off=\r"
	notestr+="azi=\r"
	notestr+="azi_off=\r"
	notestr+="deflectorY=\r"
	notestr+="gammaA=\r"
	notestr+="CutangleFrom=\r"
	notestr+="CutangleTo=\r"
	
	notestr=replacenumberbykey("PhotonEnergy",notestr,gv_photonE,"=","\r")
	notestr=replacenumberbykey("WorkFunction",notestr,gv_wf,"=","\r")
	notestr=replacenumberbykey("InnerE",notestr,gv_innerE,"=","\r")
	notestr=replacenumberbykey("theta",notestr,gv_th,"=","\r")
	notestr=replacenumberbykey("theta_off",notestr,gv_samthetaoff,"=","\r")
	notestr=replacenumberbykey("phi",notestr,gv_ph,"=","\r")
	notestr=replacenumberbykey("phi_off",notestr,gv_samphioff,"=","\r")
	notestr=replacenumberbykey("azi",notestr,gv_azi,"=","\r")
	notestr=replacenumberbykey("azi_off",notestr,gv_samazioff,"=","\r")
	notestr=replacenumberbykey("deflectorY",notestr,gv_deflectorY,"=","\r")
	notestr=replacenumberbykey("gammaA",notestr,gv_gammaA,"=","\r")
	notestr=replacenumberbykey("CutangleFrom",notestr,CutangleF,"=","\r")
	notestr=replacenumberbykey("CutangleTo",notestr,CutangleT,"=","\r")
	return notestr
End

static Function read_cuts_note(notestr)
	string notestr
	
	Variable gv_photonE,gv_wf,gv_innerE,gv_th,gv_samthetaoff,gv_ph,gv_samphioff,gv_azi,gv_samazioff
	Variable gv_gammaA,CutangleF,CutangleT
	
	gv_photonE=numberbykey("PhotonEnergy",notestr,"=","\r")
	gv_wf=numberbykey("WorkFunction",notestr,"=","\r")
	gv_innerE=numberbykey("InnerE",notestr,"=","\r")
	gv_th=numberbykey("theta",notestr,"=","\r")
	gv_samthetaoff=numberbykey("theta_off",notestr,"=","\r")
	gv_ph=numberbykey("phi",notestr,"=","\r")
	gv_samphioff=numberbykey("phi_off",notestr,"=","\r")
	gv_azi=numberbykey("azi",notestr,"=","\r")
	gv_samazioff=numberbykey("azi_off",notestr,"=","\r")
	gv_gammaA=numberbykey("gammaA",notestr,"=","\r")
	CutangleF=numberbykey("CutangleFrom",notestr,"=","\r")
	CutangleT=numberbykey("CutangleTo",notestr,"=","\r")
	
	Make /o/n=12 WaveinfoVal
	
	WaveinfoVal[0]=gv_photonE
	WaveinfoVal[1]=gv_wf
	WaveinfoVal[2]=gv_innerE
	WaveinfoVal[3]=gv_th
	WaveinfoVal[4]=gv_samthetaoff
	WaveinfoVal[5]=gv_ph
	WaveinfoVal[6]=gv_samphioff
	WaveinfoVal[7]=gv_azi
	WaveinfoVal[8]=gv_samazioff
	WaveinfoVal[9]=gv_gammaA
	WaveinfoVal[10]=CutangleF
	WaveinfoVal[11]=CutangleT
	
End

static Function update_CutsKxky_sel(flag)
	Variable flag
	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel	
	SetDatafolder DFR_panel
	SetActivesubwindow $winname(0,65)
	SetDatafolder Cutkxky
	Wave XCuts_sel=DFR_panel:XCuts_sel
	Wave YCuts_sel=DFR_panel:YCuts_sel
	SVAR gs_Cuts_selname=DFR_panel:gs_Cuts_selname
	
	String wname=winname(0,65)
	switch(flag)
	case 1: //new append
		Removefromgraph /z YCuts_sel
		appendtograph YCuts_sel vs XCuts_sel
		ModifyGraph  mode(YCuts_sel)=3,marker(YCuts_sel)=8, msize(YCuts_sel)=2
		ModifyGraph  rgb(YCuts_sel)=(52428,0,0)
	break
	case 2: //remove auto
		Removefromgraph /z YCuts_sel
		String trlist=tracenamelist(wname,";",1)
		String trname
		Variable temp1,temp2
		if	(strlen(trlist)==0)
			SetDatafolder DF
			return 0
		endif
		Variable index=itemsinlist(trlist,";")-1
		Variable findflag=0
		do
			trname=Stringfromlist(index,trlist,";")
			if (stringmatch(trname,"YCuts_*"))
				if (strsearch(trname,"Auto",0,2)==-1)
				findflag=1
				break
				endif 
			endif
		index-=1
		while (index>-1)
		
		if (findflag)
			Wave Ycut=Tracenametowaveref(wname,trname)
			Wave Xcut=XWaveRefFromTrace(wname,trname)
			gs_Cuts_selname=nameofwave(Ycut)
			Duplicate /o YCut DFR_panel:YCuts_sel
			Duplicate /o Xcut DFR_panel:XCuts_sel
		else
			gs_Cuts_selname=""
			SetDatafolder DF
			return 0
		endif
		
		appendtograph YCuts_sel vs XCuts_sel
		ModifyGraph  mode(YCuts_sel)=3,marker(YCuts_sel)=8, msize(YCuts_sel)=2
		ModifyGraph  rgb(YCuts_sel)=(52428,0,0)
	break
	case 3: //selct
		Removefromgraph /z YCuts_sel
		Wave Ycut=$gs_Cuts_selname
		Wave XCut=$("X"+gs_Cuts_selname[1,inf])
		Duplicate /o YCut DFR_panel:YCuts_sel
		Duplicate /o Xcut DFR_panel:XCuts_sel
		appendtograph YCuts_sel vs XCuts_sel
		ModifyGraph  mode(YCuts_sel)=3,marker(YCuts_sel)=8, msize(YCuts_sel)=2
		ModifyGraph  rgb(YCuts_sel)=(52428,0,0)
	break
	endswitch
	
	Wave YCuts_sel=DFR_panel:YCuts_sel
	
	String notestr=note(YCuts_sel)
	
	read_cuts_note(notestr)
	wave WaveinfoVal
	
	Variable SD=Screensize(6)
		
	DFREF DFR_prefs=$DF_prefs
    	NVAR panelscale=DFR_prefs:gv_panelscale
    	NVAR Dfontsize=DFR_prefs:gv_Dfontsize
	
	String insertline
	sprintf insertline,"PhotonE: \f01%g\f00eV, WorkFn: %geV, InnerE: %geV\r",WaveinfoVal[0],WaveinfoVal[1],WaveinfoVal[2]
	String poltline="\Z"+num2indstr(round(DFontsize*SD),2)+insertline
	sprintf insertline,"Theta: \f01%.4g \f00(%.4g), Phi: \f01%.4g\f00(%.4g), Azi: \f01%4g \f00(%.4g)\r",WaveinfoVal[3],WaveinfoVal[4],WaveinfoVal[5],WaveinfoVal[6],WaveinfoVal[7],WaveinfoVal[8]
	poltline+=insertline
	sprintf insertline,"Gamma: %g, CutAngleFrom: %g, CutAngleTo: %g\r",WaveinfoVal[9],WaveinfoVal[10],WaveinfoVal[11]
	poltline+=insertline
	
	Killwaves /Z WaveinfoVal
	TextBox/W=$winname(0,65)/B=3/C/N=text0/F=0/A=RB/LS=3/Z=1/X=0/Y=0 poltline
	//TextBox/C/N=text1/F=0/B=2/A=RB poltline
	SetDatafolder DF
	return 0
End

static Function Proc_removeFSM_to_BZ(ctrlName) : ButtonControl
	String ctrlName
	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_load=$DF_global
	SetActivesubwindow $winname(0,65)
	String List=ImageNameList("",";")
	String TraceN
	Variable Tracenum=itemsinlist(List,";")
	Variable index=Tracenum-1
	do
		TraceN=Stringfromlist(index,list,";")
		if (stringmatch(TraceN,"*autoFSM*"))
 			removeimage $TraceN
		endif
		index-=1
	while (index>-1)
	
	HideInfo
	
	NVAR autoFSMflag=DFR_panel:gv_autoFSMflag
	SVAR autoFSMname=DFR_panel:gs_autoFSMname
	
	if ((autoFSMflag==0)||(strlen(autoFSMname)==0))
		autoFSMflag=0
		autoFSMname=""
		SetDatafolder DF
		return 0
	endif
	
	String DF_mapper="root:internalUse:"+autoFSMname
	DFREF DFR_mapper=$DF_mapper
	
	autoFSMflag=0
	autoFSMname=""
	
	if (Datafolderexists(DF_mapper)==0)
		SetDatafolder DF
		return 0
	endif
	
	NVAR gv_autoFSMflag=DFR_mapper:gv_autoFSMflag
	SVAR gs_autoFSM_panellist=DFR_mapper:gs_autoFSM_panellist
	
	gs_autoFSM_panellist=RemoveFromList(winname(0,65), gs_autoFSM_panellist, ";" )
	
	if (itemsinlist(gs_autoFSM_panellist,";")<1)
		gv_autoFSMflag=0
	endif
	
	
	
	SetDatafolder DF
End


static Function Proc_bt_appendCuts(ctrlname)
	String ctrlname
	
	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_Cuts=$(DF_panel+":Cutkxky")
	SetActivesubwindow $winname(0,65)
	
	String wname=winname(0,65)
	
	SVAR gs_Cuts_selname=DFR_panel:gs_Cuts_selname
	
	if (stringmatch(ctrlname,"DrawCuts_BZAppendCut"))
		Wave trace=DFR_Cuts:$gs_Cuts_selname
		Wave Xtrace=DFR_Cuts:$("X"+gs_Cuts_selname[1,inf])
		
		String gn=winname(1,1)
		dowindow /F $gn
		display_XYwave(trace,xtrace,1,0)
	else
		String trlist=tracenamelist(wname,";",1)
		String trname
		Variable temp1,temp2
		if	(strlen(trlist)==0)
			SetDatafolder DF
			return 0
		endif
		Variable index=itemsinlist(trlist,";")-1
		String displist=""
		do
			trname=Stringfromlist(index,trlist,";")
			if (stringmatch(trname,"YCuts_*"))
				if ((strsearch(trname,"Auto",0,2)==-1)&&(strsearch(trname,"_sel",0,2)==-1))
				displist+=trname+";"
				endif 
			endif
		index-=1
		while (index>-1)
		
		if (strlen(displist)>0)
			gn=winname(1,1)
			dowindow /F $gn
			index=0
			do
				trname=Stringfromlist(index,displist,";")
				Wave Ycut=Tracenametowaveref(wname,trname)
				Wave Xcut=XWaveRefFromTrace(wname,trname)
				display_XYwave(Ycut,xCut,1,0)
			index+=1
			while (index<itemsinlist(displist))
		endif
	endif
	
	
	
end


static Function Proc_remove_to_BZ(ctrlName) : ButtonControl
	String ctrlName
	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_load=$DF_global
	SetActivesubwindow $winname(0,65)
	
	controlinfo DrawCuts_ck08
	Variable plot3D_flag=V_value
	
	if (plot3D_flag)
		DFREF DFR_Cut=$(DF_panel+":Cutkxky")
		//setdatafolder DFR_panel
		//SetDatafolder Cutkxky
		String cmd=""
		Variable wavenum=CountObjectsDFR(DFR_Cut,1)
		Variable index=wavenum-1
		String objectname
		do 
			objectname=GetIndexedObjNameDFR(DFR_cut,1,index)
			if (strsearch(objectname,"Cuts3D",0)!=-1)
				cmd="Removefromgizmo /Z /N=BZ_3D_show object="+objectname
				execute cmd
				cmd="ModifyGizmo /Z /N=BZ_3D_show update=0"
				execute cmd
				
				Wave cut3D=DFR_cut:$objectname
				Killwaves /Z cut3D
				if (Stringmatch(ctrlName,"DrawCuts_BZremove"))
					break
				endif
			endif
			index-=1
		while (index>=0)
		
		
	else
	
		String TraceN
		SVAR gs_Cuts_selname=DFR_panel:gs_Cuts_selname
	
		do
	
			TraceN=gs_Cuts_selname
		
			if (strlen(TraceN)==0)
				break
			endif
	
			if (Stringmatch(ctrlName,"DrawCuts_BZremove"))
 				Wave TempTrace=TraceNameToWaveRef("",TraceN)
				Wave XtempTrace=XWaveRefFromTrace("",TraceN)
				removefromgraph $TraceN
 				killwaves /Z TempTrace,XtempTrace
 				update_Cutskxky_sel(2)
 				break
			else
				 Wave TempTrace=TraceNameToWaveRef("",TraceN)
				 Wave XtempTrace=XWaveRefFromTrace("",TraceN)
 				 removefromgraph $TraceN
 				 Killwaves /Z TempTrace,XtempTrace
 			 	update_Cutskxky_sel(2)
 			endif
		while (1)
	endif
	 	
	SetDatafolder DF
End


/////////////////////////////////Core Function ////////////////////////////////////////
Function Cal_momentum_vector(uca,ucb,ucc,alphaA,betaA,gammaA,BZtype)
	Variable uca,ucb,ucc,alphaA,betaA,gammaA
	Variable BZtype
	Variable temp
	
	Make /o/n=3 a,b,c,temp1,temp2,temp3,astar,bstar,cstar,a_base,b_base,c_base
	
	a_base={uca,0,0}
	b_base={ucb*cos(alphaA),ucb*sin(alphaA),0}
	temp=(ucc*(cos(gammaA)-cos(betaA)*cos(alphaA))/sin(alphaA))
	c_base={ucc*cos(betaA),temp, sqrt((ucc*sin(betaA))^2-temp^2)}
	
	switch(Bztype) //cal lattice vector
	case 1:
		a={uca,0,0}
		b={ucb*cos(alphaA),ucb*sin(alphaA),0}
		temp=(ucc*(cos(gammaA)-cos(betaA)*cos(alphaA))/sin(alphaA))
		c={ucc*cos(betaA),temp, sqrt((ucc*sin(betaA))^2-temp^2)}
		break
	case 2://bcc
		a={uca,0,0}
		b={ucb*cos(alphaA),ucb*sin(alphaA),0}
		c={uca/2,ucb/2,ucc/2}
		break
	case 3://fcc
		a={uca/2,0,ucc/2}
		b={0,ucb/2,ucc/2}
		c={uca/2,ucb/2,0}
		break
	case 4://Tcc
		a={uca,0,0}
		b={ucb*cos(alphaA),ucb*sin(alphaA),0}
		c={uca/2,0,ucc/2}
		break
	endswitch

	Matrixcross(a,b)
	Wave w_result
	temp1=w_result
	Matrixcross(b,c)
	Wave w_result
	temp2=w_result
	Matrixcross(c,a)
	Wave w_result
	temp3=w_result

	killwaves/Z w_result
	
	//Cal K*
	astar=2*pi/matrixdot(a,temp2)*temp2
	bstar=2*pi/matrixdot(b,temp3)*temp3
	cstar=2*pi/matrixdot(c,temp1)*temp1 

	astar=(abs(astar[p])<1e-6)?(0):(astar[p])
	bstar=(abs(bstar[p])<1e-6)?(0):(bstar[p])
	cstar=(abs(cstar[p])<1e-6)?(0):(cstar[p])
	
End

Function Cal_plane_vector(a,b,c,A1_L,B1_L,C1_L)
	Wave a,b,c
	Variable A1_L,B1_L,C1_L
	
	Make /o/n=3 /Free Vecter1,Vecter2,Vecter3,VecterP1,VecterP2
	Make /o/n=3 VecterP3
	
	Variable zeroflag=0
	if (A1_L==0)
		zeroflag+=1
	endif
	if (B1_L==0)
		zeroflag+=2
	endif
	if (C1_L==0)
		zeroflag+=4
	endif
	
	switch(zeroflag)
		case 0:
			Vecter1=a/A1_L
			Vecter2=b/B1_L
			Vecter3=c/C1_L
			
			VecterP1=Vecter2-Vecter1
			VecterP2=Vecter3-Vecter1
			
			break
		case 1:
			Vecter2=b/B1_L
			Vecter3=c/C1_L
			Matrixcross(Vecter2,Vecter3)
			Wave w_result
			VecterP1=w_result
			VecterP2=Vecter2-Vecter3
			break
		case 2:
			Vecter2=a/A1_L
			Vecter3=c/C1_L
			Matrixcross(Vecter2,Vecter3)
			Wave w_result
			VecterP1=w_result
			VecterP2=Vecter2-Vecter3
			break
		case 3:
			Vecter3=c/C1_L
			VecterP3=Vecter3
			return 0
			break
		case 4:
			Vecter2=a/A1_L
			Vecter3=b/B1_L
			Matrixcross(Vecter2,Vecter3)
			Wave w_result
			VecterP1=w_result
			VecterP2=Vecter2-Vecter3
			break
		case 5:
			Vecter2=b/B1_L
			VecterP3=Vecter2
			return 0
			break
		case 6:
			Vecter1=a/A1_L
			VecterP3=Vecter1
			return 0
			break
		
	endswitch
	
	VecterP3[0]=(VecterP1[1]*VecterP2[2])-(VecterP1[2]*VecterP2[1])
	VecterP3[1]=(VecterP1[2]*VecterP2[0])-(VecterP1[0]*VecterP2[2])
	VecterP3[2]=(VecterP1[0]*VecterP2[1])-(VecterP1[1]*VecterP2[0])
	
	
	
End

Function Bz_Create_All(uca,ucb,ucc,alphaA,betaA,gammaA,Bztype,Bzazi,A1_L,B1_L,C1_L,PL,BZh,BZl,BZk,flag)
	Variable uca,ucb,ucc,alphaA,betaA,gammaA,BZazi,Bztype
	Variable A1_L,B1_L,C1_L,Pl
	Variable BZh,BZl,BZk
	Variable flag

	Make /o/n=3 a,b,c,temp1,temp2,temp3,astar,bstar,cstar,Point,Ptemp1,Ptemp2,GammaPoint,GammaPointtemp


	Variable temp

	if ((betaA+gammaA)<=alphaA)
		doalert 0,"Parameter error!"
		return 0
	endif

	if ((betaA>pi/2)||(alphaA>pi/2)||(gammaA>pi/2))
		doalert 0,"Parameter error!"
		return 0
	endif
	
	Cal_momentum_vector(uca,ucb,ucc,alphaA,betaA,gammaA,BZtype)
	Wave astar,bstar,cstar
	
	Variable A1,B1,C1
	
	if (flag==0)
		Wave a_base,b_base,c_base
		Cal_plane_vector(a_base,b_base,c_base,A1_L,B1_L,C1_L)
		//Cal rotate Matrix 
	
		Wave VecterP3

		A1=VecterP3[0]
		B1=VecterP3[1]
		C1=VecterP3[2]
	else
		A1=A1_L
		B1=B1_L
		C1=C1_L
	endif
	
	
	temp=sqrt(A1^2+B1^2+C1^2)

	A1/=temp
	B1/=temp
	C1/=temp

	A1=round(A1*1000)/1000
	B1=round(B1*1000)/1000
	C1=round(C1*1000)/1000

	Variable Px,Py,Pz

	Px=Pl*A1//-BZh*astar
	Py=Pl*B1//-BZl*bstar
	Pz=Pl*C1//-BZk*cstar


	Point={Px,Py,Pz}
	GammaPoint=BZh*astar+BZl*bstar+BZk*cstar
	GammaPointtemp=GammaPoint

	temp1={A1,B1,C1}
	temp2={0,0,1}
	
	variable thetaz,thetax

	if ((A1==0)&&(B1==0)&&(C1==1))
		thetaz=0
	else

		Matrixcross(temp2,temp1)//?
		Wave w_result
		temp3=w_result/MatrixSum(w_result)
		if (temp3[1]<0)
			thetaz=acos(temp3[0])
		else
			thetaz=2*pi-acos(temp3[0])
		endif
	endif


	Make /o/n=(3,3) Rz,Rx,RzI,RxI
	Make /o/n=2 RT

	Rz={{cos(thetaz),-sin(thetaz),0}, {sin(thetaz),cos(thetaz),0}, {0,0,1}}
	thetaz=-thetaz
	RzI={{cos(thetaz),-sin(thetaz),0}, {sin(thetaz),cos(thetaz),0}, {0,0,1}}

	MatrixMultiply RZI,temp1
	Wave M_product
	temp1=M_product[p]
	if (M_product[1]>=0)
		thetax=acos(M_product[2])
	else
		thetax=2*pi-acos(M_product[2])
	endif

	Rx={ {1,0,0}, {0,cos(thetax),-sin(thetax)}, {0,sin(thetax),cos(thetax)} }
	thetax=-thetax
	RxI= { {1,0,0}, {0,cos(thetax),-sin(thetax)}, {0,sin(thetax),cos(thetax)} }

	RxI=(abs(RxI[p][q])<1e-6)?(0):(RxI[p][q])
	RzI=(abs(RzI[p][q])<1e-6)?(0):(RzI[p][q])
	Rx=(abs(Rx[p][q])<1e-6)?(0):(Rx[p][q])
	Rz=(abs(Rz[p][q])<1e-6)?(0):(Rz[p][q])

	GammaPointtemp-=point
	MatrixMultiply RxI,RZI,GammaPointtemp
	Wave M_product

	point={A1*-M_product[2],B1*-M_product[2],C1*-M_product[2]}
	RT={M_product[0],M_product[1]}


	Variable hindex,lindex,kindex
	Variable totalnum=1
	Variable lineindex

	Make /o/n=(1,3) Linelist

	hindex=-totalnum
	do
		lindex=-totalnum
		do
			kindex=-totalnum
			do 
		
				if (kindex>totalnum)
					break
				endif
		
				if ((hindex==0)&&(lindex==0)&&(kindex==0))
					kindex+=1
					continue
				endif
				ptemp1=hindex*astar+lindex*bstar+kindex*cstar
				ptemp1/=2
				ptemp2=ptemp1/matrixsum(ptemp1)
		
				MatrixMultiply RxI,RZI,ptemp2
				Wave M_product
				ptemp2=M_product[p] //vector
		
				ptemp1-=point
				
				MatrixMultiply RxI,RZI,ptemp1
				Wave M_product
				ptemp1=M_product[p] // point
				ptemp2=(abs(ptemp2[p])<1e-6)?(0):(ptemp2[p])//round(ptemp2[p]*1000)/1000
				//ptemp2/=10
		
		
				if ((ptemp2[0]==0)&&(ptemp2[1]==0))
					kindex+=1
					continue
				endif
		
				insertpoints inf,1,Linelist
				Linelist[Lineindex][0]=ptemp2[0]
				Linelist[lineindex][1]=ptemp2[1]
				linelist[lineindex][2]=-ptemp2[0]*ptemp1[0]-ptemp2[1]*ptemp1[1]-ptemp2[2]*ptemp1[2]
		
				Linelist[Lineindex][]/=sqrt(ptemp2[0]^2+ptemp2[1]^2)
		
				if (Linelist[Lineindex][0]<0)
					Linelist[Lineindex][]=-Linelist[Lineindex][q]
				elseif  (Linelist[Lineindex][0]==0)
					 if (Linelist[Lineindex][1]<0)
					 	Linelist[Lineindex][]=-Linelist[Lineindex][q]
					 endif
				endif
		
				Lineindex+=1		
				kindex+=1
			while (kindex<(totalnum+1))
			lindex+=1
		while (lindex<(totalnum+1))
		hindex+=1
	while (hindex<(totalnum+1))

	Deletepoints Lineindex,1,Linelist

	Linelist=(abs(Linelist[p][q])<1e-8)?(0):(Linelist[p][q])

	//Linelist=round(Linelist[p][q]*1e8)/1000000000

	//Lineindex-=1

	Variable Atemp1,Btemp1,Ctemp1,Atemp2,Btemp2,Ctemp2

	Variable Aindex,Bindex,pointindex
	Make /o/n=1 Pointlist_x,Pointlist_y
	Make /o/n=1 Pointangle

	Do
		Bindex=Aindex+1
	
		do
			if (Bindex>=lineindex)
				break
			endif
	
			Atemp1=Linelist[Aindex][0]
			Btemp1=Linelist[Aindex][1]
			Ctemp1=Linelist[Aindex][2]
	
			Atemp2=Linelist[Bindex][0]
			Btemp2=Linelist[Bindex][1]
			Ctemp2=Linelist[Bindex][2]
	
			if ((abs(Atemp1-Atemp2)<1e-6)&&(abs(Btemp1-Btemp2)<1e-6))
				Bindex+=1
				continue
			endif
	
			Insertpoints inf,1,pointlist_x,pointlist_y,Pointangle
			pointlist_x[pointindex]=(Ctemp2*Btemp1-Ctemp1*Btemp2)/(Atemp1*Btemp2-Atemp2*Btemp1)
			pointlist_y[pointindex]=(Ctemp2*Atemp1-Ctemp1*Atemp2)/(Btemp1*Atemp2-Btemp2*Atemp1)
			Pointangle[pointindex]=atan2(pointlist_y[pointindex],pointlist_x[pointindex])
	
			if (numtype(Pointangle[pointindex])==2)
			//print Atemp1,Btemp1,Ctemp1,Atemp2,Btemp2,Ctemp2
			//print Atemp1-Atemp2,Btemp1-Btemp2
			endif
			if (Pointangle[pointindex]<0)
				Pointangle[pointindex]+=2*pi
			endif
	
			pointindex+=1
	
			Bindex+=1
		while (Bindex<lineindex)

		Aindex+=1
	while (Aindex<Lineindex)

	Deletepoints pointindex,1,pointlist_y,pointlist_x,Pointangle

	sort /A Pointangle,Pointangle,pointlist_x,pointlist_y

	pointlist_x=(abs(pointlist_x[p])<1e-6)?(0):(pointlist_x[p])
	pointlist_y=(abs(pointlist_y[p])<1e-6)?(0):(pointlist_y[p])

	//pointlist_x=round(pointlist_x*100)/100
	//pointlist_y=round(pointlist_y*100)/100

	Variable index=0

	Make /o/n=1 BZ_y,BZ_x
	Variable BZindex,CPtempx,CPtempy,BZcheck=0

	do 
	
		temp=sqrt(Pointlist_y[index]^2+Pointlist_x[index]^2)
	
		BZcheck=0
	
		Atemp1=Pointlist_y[index]/temp
		Btemp1=-Pointlist_x[index]/temp
		Ctemp1=0
	
		Atemp1=(abs(atemp1)<1e-6)?(0):(atemp1)//round(Atemp1*1000)/1000
		Btemp1=(abs(Btemp1)<1e-6)?(0):(btemp1)//round(Btemp1*1000)/1000
		
		if (Atemp1<0)
			Atemp1=-Atemp1
			Btemp1=-Btemp1
		elseif (Atemp1==0)
			if (Btemp1<0)
				Btemp1=-Btemp1
			endif
		endif
	
		Aindex=0
		do
	
			if (Aindex==lineindex)
				break
			endif
	
			Atemp2=Linelist[Aindex][0]
			Btemp2=Linelist[Aindex][1]
			Ctemp2=Linelist[Aindex][2]
	
			if ((abs(Atemp1-Atemp2)<1e-6)&&(abs(Btemp1-Btemp2)<1e-6))
				Aindex+=1
				continue
			endif
	
			CPtempx=(Ctemp2*Btemp1)/(Atemp1*Btemp2-Atemp2*Btemp1)
			CPtempy=(Ctemp2*Atemp1)/(Btemp1*Atemp2-Btemp2*Atemp1)
	
			CPtempx=(Abs(Cptempx)<1e-6)?(0):(Cptempx)
			CPtempy=(Abs(Cptempy)<1e-6)?(0):(Cptempy)
	
			if ((sign(CPtempx)==sign(Pointlist_x[index]))&&(sign(CPtempy)==sign(Pointlist_y[index])))
				if (((Pointlist_y[index]^2+Pointlist_x[index]^2)-(CPtempx^2+CPtempy^2))>(1e-4))
					BZcheck=1
					break
				endif
			endif

			Aindex+=1
		while (Aindex<lineindex)

		if (BZcheck==0)
			//print index
			Insertpoints inf,1,BZ_x,BZ_y
			BZ_x[BZindex]=Pointlist_x[index]
			BZ_y[BZindex]=Pointlist_y[index]
			BZindex+=1
		endif
	
		index+=1
	while (index<pointindex)

	BZ_x[BZindex]=BZ_x[0]
	BZ_y[BZindex]=BZ_y[0]


	//Deletepoints BZindex,1,BZ_x,BZ_y

	//display
	BZ_x+=RT[0]
	BZ_y+=RT[1]

	index=0
	Variable Vtemp1,Vtemp2,Vtemp3
	
	do 
	 	Bindex=index+1
		 do
			if (Bindex>=(numpnts(BZ_y)-1))
	  			break
	 		endif
	  
	  		Vtemp1=abs(BZ_x[index]-BZ_x[Bindex])
	  		Vtemp2=abs(BZ_y[index]-BZ_y[Bindex])
		  
			if ((Vtemp1^2+Vtemp2^2)<1e-8)
				 deletepoints Bindex,1,BZ_x,BZ_y
				 // bindex+=1
				continue
	 		 endif
	  	  
	 		 Bindex+=1
	 	 while (Bindex<(numpnts(BZ_y)-1))
		index+=1
   	 while (index<(numpnts(BZ_y)-1))

	Make /o/n=1 Gamma_x,Gamma_y
	Gamma_x=RT[0]
	Gamma_y=RT[1]

	duplicate /o BZ_x,BZtemp_x
	duplicate /o BZ_y,BZtemp_y
	duplicate /o Gamma_x,Gtemp_x
	duplicate /o Gamma_y,Gtemp_y

	Gamma_x=rotate_BZ_proc(bzazi,Gtemp_x,Gtemp_y,0)
	Gamma_y=rotate_BZ_proc(bzazi,Gtemp_x,Gtemp_y,1)
	BZ_x=rotate_BZ_proc(bzazi,BZtemp_x[p],BZtemp_y[p],0)
	BZ_y=rotate_BZ_proc(bzazi,BZtemp_x[p],BZtemp_y[p],1)
	//appendtograph pointlist_y vs pointlist_x
	//appendtograph BZ_y vs BZ_x
	Killwaves /Z a,b,c,astar,bstar,cstar,temp1,temp2,temp3,RTI,RXI,RZI,RT,M_product,ptemp1,ptemp2,Linelist,a_Base,b_Base,c_Base,VectorP3
	Killwaves /Z pointangle,pointlist_y,pointlist_x,Gammapoint,gammapointtemp,Gtemp_y,Gtemp_x,BZtemp_x,BZtemp_y

	return 1

End

Function MatrixSum(WaveA)
	Wave WaveA
	return sqrt(WaveA[0]^2+WaveA[1]^2+WaveA[2]^2)
End


Function Matrixcross(waveA,WaveB)
	Wave waveA,waveB
	variable a1,b1,c1,a2,b2,c2
	a1=waveA[0]
	b1=waveA[1]
	c1=waveA[2]
	a2=waveB[0]
	b2=waveB[1]
	c2=waveB[2]

	make /o/n=3 w_result

	w_result={(b1*c2-b2*c1),(c1*a2-a1*c2),(a1*b2-a2*b1)} 
	return 1
End










////////////////////////tight binding///////////


Function saveTightBinding(ctrlName)
	String ctrlName
	DFREF dF=GetDatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_tight=$(DF_panel+":tight_binding")
	

  	NVAR VEF=DFR_panel:gv_BZ_tig_VEF
  	String notestr
  	NVAR gv_num_tightBind=DFR_panel:gv_num_tightBind
    
   	Variable index
   	do
   		String wname="w_tightbind_plot_"+num2str(index)
   		Wave w=DFR_tight:$wname
   		if (index==0)
   			display /K=1
   			String gN=uniquename("tightbind",6,0)
   			String w_df="root:graphsave:Others:"
   			Dowindow /C $gN
			SetWindow $gN, hook(MyHook) = MygraphHook
			newDatafolder /o/s $(w_df+gN)
   		endif
   		
   		duplicate /o w, $wname
   		Wave w_plot=$wname
   		AppendMatrixContour /W=$gn w_plot
   		ModifyContour  /W=$gn $wname, manLevels= {VEF, VEF, 1}
   	
   		index+=1
   	while (index<gv_num_tightBind)
	
	SetDatafolder DF
	
End

Function updateTightbinding_EF()

	DFREF dF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_tight=$(DF_panel+":tight_binding")

	SetDATAFolder DFR_tight
	
	controlinfo tightbinding_ck1
	
	NVAR gv_num_tightBind=DFR_panel:gv_num_tightBind
	NVAR EF_Value=DFR_panel:gv_BZ_tig_VEF
	if (V_value) //gizmo display
		
		Variable index=0
		do
			String wname = "w_tightbind_"+num2str(index)
		
			String gzname=winname(0,4096)
	   		if (strlen(gzname)==0)
	   			SetDAtafolder DF
	   			return 1
  	 			//string cmd="newGizmo /N=BZ_3D_show"
  				///Execute cmd
   				//cmd= "ModifyGizmo aspectRatio=1"
   				//Execute cmd
   				//cmd="modifyGizmo showAxisCue=1"
   				//Execute cmd
   		
		  	 else
   				if (stringmatch(gzname,"BZ_3D_show")==0)
   					SetDAtafolder DF
	   				return 1
   				endif
  			 endif
   			//Dowindow /F BZ_3D_show
   			//cmd="RemoveFromGizmo /Z /N=BZ_3D_show object="+wname
   			//Execute cmd
   			//cmd="AppendToGizmo /N=BZ_3D_show/D isosurface="+wname+" name="+wname
  			//Execute cmd
   			//cmd= "ModifyGizmo modifyObject="+wname+", property={surfaceColorType, 1}"
 			//Execute cmd
  			String cmd= "ModifyGizmo modifyObject="+wname+", property={isovalue, "+num2str(EF_Value)+"}"
			Execute cmd
			
			index+=1
		while(index<gv_num_tightbind)
	
		SetDatafolder DF
		return 1
	else
		Variable i
		 String contours = ContourNameList("", ";" )
		
		for (i = 0; i < ItemsInList(contours); i += 1)
			String contour = StringFromList(i,contours)
			ModifyContour $contour, manLevels= {EF_Value, EF_Value, 1}
	 	 endfor
	 	 SetDatafolder DF
		return 1
	endif
End

Function DefaultTightBindingSet (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	
	DFREF dF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel
	
	switch(popnum)
//	case 1: //cuprates
//		Make /o/T/n=1 BZ_tig_bandlist
//		Make /o/T/n=2 BZ_tig_parlist
//		Make /o/B/n=1 BZ_tig_bandlist_sel
//		Make /o/B/n=2 BZ_tig_parlist_sel
//
//		BZ_tig_bandlist[0]="Txx * ( cos(x) + cos(y) ) + Txy * ( cos(x) * cos(y) )"
//		BZ_tig_parlist[0]="Txx=-0.707"
//		BZ_tig_parlist[1]="Txy=0.48"
//	
//		BZ_tig_parlist_sel=2
//		BZ_tig_bandlist_sel=2
//		break

	case 1: //cuprates
		Make /o/T/n=1 BZ_tig_bandlist
		Make /o/T/n=3 BZ_tig_parlist
		Make /o/B/n=1 BZ_tig_bandlist_sel
		Make /o/B/n=3 BZ_tig_parlist_sel

		BZ_tig_bandlist[0]="-2*T0 * ( cos(x) + cos(y) ) -4* T1* ( cos(x) * cos(y) )-2*T2*(cos(2*x)+cos(2*y))"
		BZ_tig_parlist[0]="T0=0.22"
		BZ_tig_parlist[1]="T1=-0.0343"
		BZ_tig_parlist[2]="T2=0.0359"
	
		BZ_tig_parlist_sel=2
		BZ_tig_bandlist_sel=2
		break


	case 2:
		Make /o/T/n=2 BZ_tig_bandlist
		Make /o/T/n=1 BZ_tig_parlist
		Make /o/B/n=2 BZ_tig_bandlist_sel
		Make /o/B/n=1 BZ_tig_parlist_sel

		BZ_tig_bandlist[0]="Txx* sqrt(1+4*cos(y/2)*cos(y/2)+4*cos(y/2)*cos(sqrt(3)/2*x))"
		BZ_tig_bandlist[1]="-Txx* sqrt(1+4*cos(y/2)*cos(y/2)+4*cos(y/2)*cos(sqrt(3)/2*x))"
		BZ_tig_parlist[0]="Txx=2.8"
		//BZ_tig_parlist[1]="Txy=0.48"
	
		BZ_tig_parlist_sel=2
		BZ_tig_bandlist_sel=2
	
		//gs_BZ_equal="Txx* sqrt(1+4*cos(y/2)*cos(y/2)+4*cos(y/2)*cos(sqrt(3)/2*x))
	
	
		break
	case 3:
		break
	endswitch
	
	SetDatafolder DF
End

Function updateTightBindingSet(ctrlName,varNum,varStr,varName)
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	DFREF dF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	

	updateTightbinding_EF()

	 
	SetDatafolder DF
End

Function updateTightBinding(name, value, event)
	String name	// name of this slider control
	Variable value	// value of slider
	Variable event	// bit field: bit 0: value set; 1: mouse down, 
					//   2: mouse up, 3: mouse moved
	DFREF dF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	
	updateTightbinding_EF()
	
	SetDatafolder DF		
End

	
Function ClearTightBinding(ctrlname) 
	String ctrlname

	DFREF dF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	
	NVAR gv_num_tightBind=DFR_panel:gv_num_tightBind

	Variable i
	String contours = ContourNameList( "", ";" )
	for (i = 0; i < ItemsInList(contours); i += 1)
		String contour = StringFromList(i,contours)
		RemoveContour/W=$winname(0,65) $contour
	endfor

	DFREF DFR_tight=$(DF_panel+":tight_binding")
	SetDAtafolder DFR_tight
	//SetDatafolder DFR_panel
	String wname
	for( i = 0; i < gv_num_tightBind; i += 1 )
		if (exists("w_tightbind_"+num2str(i)))
			wname = "w_tightbind_"+num2str(i)
			String wname_plot = "w_tightbind_plot_"+num2str(i)
				KillWaves/Z $wname, $wname_plot
		endif
	endfor

	SetDataFolder DF

End

static Function tightbinding_Addband(ctrlname)
	String ctrlname
	
	DFREF dF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	Setactivesubwindow $winname(0,65)
	
    	SVAR BZ_equal=DFR_panel:gs_BZ_equal
    	
    	Wave /T BZ_tig_bandlist=DFR_panel:BZ_tig_bandlist
    	Wave /B BZ_tig_bandlist_sel=DFR_panel:BZ_tig_bandlist_sel
    	
    	controlinfo tightbinding_lb0
    	Variable selrow=V_Value
    	Insertpoints selrow,1, BZ_tig_bandlist,BZ_tig_bandlist_sel
    	BZ_tig_bandlist[selrow]=BZ_equal
    	BZ_tig_bandlist_sel[selrow]=2
   //Wave/T BZ_tig_parlist
    	
End

static Function tightbinding_Delband(ctrlname)
	String ctrlname
	
	DFREF dF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	Setactivesubwindow $winname(0,65)
	
	Wave /T BZ_tig_bandlist=DFR_panel:BZ_tig_bandlist
	Wave /B BZ_tig_bandlist_sel=DFR_panel:BZ_tig_bandlist_sel
    	
    	controlinfo tightbinding_lb0
    	Variable selrow=V_Value
   	Deletepoints selrow,1, BZ_tig_bandlist,BZ_tig_bandlist_sel
    	//BZ_tig_bandlist[selrow]=BZ_equal
End


static Function tightbinding_Addpar(ctrlname)
	String ctrlname
	
	DFREF dF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	Setactivesubwindow $winname(0,65)
	
	Wave /T BZ_tig_parlist=DFR_panel:BZ_tig_parlist
	Wave /B BZ_tig_parlist_sel=DFR_panel:BZ_tig_parlist_sel
    	
    	controlinfo tightbinding_lb1
    	Variable selrow=V_Value
   	Insertpoints selrow,1, BZ_tig_parlist,BZ_tig_parlist_sel
   	BZ_tig_parlist_sel[selrow]=2
    	//BZ_tig_bandlist[selrow]=BZ_equal
End

static Function tightbinding_Delpar(ctrlname)
	String ctrlname
	
	DFREF dF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	Setactivesubwindow $winname(0,65)
	
	Wave /T BZ_tig_parlist=DFR_panel:BZ_tig_parlist
	Wave /B BZ_tig_parlist_sel=DFR_panel:BZ_tig_parlist_sel
    	
    	controlinfo tightbinding_lb1
    	Variable selrow=V_Value
   	Deletepoints selrow,1, BZ_tig_parlist,BZ_tig_parlist_sel
    	//BZ_tig_bandlist[selrow]=BZ_equal
End



static Function AddTightBinding(ctrlname)
	String ctrlname
	
	DFREF dF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	Setactivesubwindow $winname(0,65)
	
    	SVAR BZ_equal=DFR_panel:gs_BZ_equal
	
	NVAR gv_num_tightBind=DFR_panel:gv_num_tightBind
	
	Wave /T BZ_tig_bandlist=DFR_panel:BZ_tig_bandlist
	Wave /T BZ_tig_parlist=DFR_panel:BZ_tig_parlist
	
	String parlist=WaveToStringList(BZ_tig_parlist,";",Nan,Nan)
	
	//DFREF DFR_tightbinding=$(DF_panel+"tightbinding")
	//SetDatafolder DFR_tightbindng
	SetDatafolder DFR_panel
	newDatafolder /o/s tight_binding
	
	gv_num_tightBind=numpnts(BZ_tig_bandlist)
	
	//Variable i
	//for( i = 0; exists("w_tightbind"+num2str(i)); i += 1 )
	//endfor
	//String wname = "w_tightbind"+num2str(i)
	//gv_num_tightBind = max(gv_num_tightBind, i + 1)
	
	
	controlinfo DrawBZ_lb0 // get select BZ
	Wave BZList=DFR_panel:BZlist
	Variable bzh=BZList[v_value][0]
	Variable bzi=BZList[v_value][1]
	Variable bzk=BZlist[v_Value][2]
	
	 DFREF DFR_load=$DF_global

   	NVAR gv_BZtype=DFR_load:gv_BZtype
   
   	NVAR gV_uca=DFR_load:gv_uca
   	NVAR gV_ucb=DFR_load:gv_ucb
   	NVAR gV_ucc=DFR_load:gv_ucc
   
   	NVAR gV_alphaA=DFR_load:gv_alphaA
   	NVAR gv_betaA=DFR_load:gv_betaA
   	NVAR gv_gammaAA=DFR_load:gv_gammaAA
	
	Cal_momentum_vector(gV_uca,gV_ucb,gV_ucc,gV_alphaA/180*pi,gv_betaA/180*pi,gv_gammaAA/180*pi,gv_BZtype)
	
	Wave astar,bstar,cstar
		
	Variable kx0=bzh*astar[0]+bzi*bstar[0]+bzk*cstar[0]
	Variable ky0=bzh*astar[1]+bzi*bstar[1]+bzk*cstar[1]
	Variable kz0=bzh*astar[2]+bzi*bstar[2]+bzk*cstar[2]

	Killwaves /Z a,b,c,astar,bstar,cstar,temp1,temp2,temp3
	
	NVAR gv_A1=DFR_panel:gv_A1
	NVAR gv_B1=DFR_panel:gv_B1
	NVAR gv_C1=DFR_panel:gv_C1
	NVAR gv_PL=DFR_panel:gv_PL
	
	NVAR gv_BZ_tig_kxrange=DFR_panel:gv_BZ_tig_kxrange
	NVAR gv_BZ_tig_kyrange=DFR_panel:gv_BZ_tig_kyrange
	NVAR gv_BZ_tig_kzrange=DFR_panel:gv_BZ_tig_kzrange
	
	NVAR gv_BZ_tig_kxpi=DFR_panel:gv_BZ_tig_kxpi
	NVAR gv_BZ_tig_kypi=DFR_panel:gv_BZ_tig_kypi
	NVAR gv_BZ_tig_kzpi=DFR_panel:gv_BZ_tig_kzpi
	
	NVAR gv_BZ_tig_kdensity=DFR_panel:gv_BZ_tig_kdensity
	
	Variable xn=2*round(gv_BZ_tig_kxpi*gv_BZ_tig_kxrange/gv_BZ_tig_kdensity)+1
	Variable yn=2*round(gv_BZ_tig_kypi*gv_BZ_tig_kyrange/gv_BZ_tig_kdensity)+1
	Variable zn=2*round(gv_BZ_tig_kzpi*gv_BZ_tig_kzrange/gv_BZ_tig_kdensity)+1
	
	Variable index
	
	do
		String wname = "w_tightbind_"+num2str(index)
		make /o/n=(xn,yn,zn) $wname
		Setscale /I x, -gv_BZ_tig_kxrange*pi,gv_BZ_tig_kxrange*pi, $wname
		Setscale /I y, -gv_BZ_tig_kyrange*pi,gv_BZ_tig_kyrange*pi, $wname
		Setscale /I z, -gv_BZ_tig_kzrange*pi,gv_BZ_tig_kzrange*pi, $wname
		Wave w=$wname
		String bandstr=BZ_tig_bandlist[index]
		if (Cal_Tight_binding(w,bandstr,parlist)==0)
			SetDatafolder DF
			return 0
		endif
		index+=1
	while (index<gv_num_tightBind)
	
	
	
	controlinfo tightbinding_ck1
	if (V_value) //gizmo display
		NVAR EF_Value=DFR_panel:gv_BZ_tig_VEF
		index=0
		do
			wname = "w_tightbind_"+num2str(index)
			Wave w=$wname
			
			Setscale /I x, -gv_BZ_tig_kxpi*gv_BZ_tig_kxrange+kx0,gv_BZ_tig_kxpi*gv_BZ_tig_kxrange+kx0, w
			Setscale /I y, -gv_BZ_tig_kypi*gv_BZ_tig_kyrange+ky0,gv_BZ_tig_kypi*gv_BZ_tig_kyrange+ky0, w
			Setscale /I z, -gv_BZ_tig_kzpi*gv_BZ_tig_kzrange+kz0,gv_BZ_tig_kzpi*gv_BZ_tig_kzrange+kz0, w
			
			
			
			String gzname=winname(0,4096)
	   		if (strlen(gzname)==0)
  	 			string cmd="newGizmo /N=BZ_3D_show"
  				Execute cmd
   				cmd= "ModifyGizmo aspectRatio=1"
   				Execute cmd
   				cmd="modifyGizmo showAxisCue=1"
   				Execute cmd
   		
		  	 else
   				if (stringmatch(gzname,"BZ_3D_show")==0)
   					cmd="newGizmo /N=BZ_3D_show"
  		 			Execute cmd
   					cmd= "ModifyGizmo aspectRatio=1"
   					Execute cmd
   					cmd="modifyGizmo showAxisCue=1"
   					Execute cmd
   				endif
  			 endif
   			Dowindow /F BZ_3D_show
   			cmd="RemoveFromGizmo /Z /N=BZ_3D_show object="+wname
   			Execute cmd
   			cmd="AppendToGizmo /N=BZ_3D_show/D isosurface="+wname+" name="+wname
  			Execute cmd
   			cmd= "ModifyGizmo modifyObject="+wname+", property={surfaceColorType, 1}"
 			Execute cmd
  			cmd= "ModifyGizmo modifyObject="+wname+", property={isovalue, "+num2str(EF_Value)+"}"
			Execute cmd
			
			index+=1
		while(index<gv_num_tightbind)
	
		SetDatafolder DF
		return 1
	endif
	
	
	Wave a_base,b_base,c_base

	Cal_plane_vector(a_base,b_base,c_base,gv_A1,gv_B1,gv_C1)
	
	Wave VecterP3
	
	Variable A1,B1,C1,Pl
	A1=VecterP3[0]
	B1=VecterP3[1]
	C1=VecterP3[2]
	PL=gv_PL
	
	Variable temp
	Make /o/n=3 Point,temp1,temp2,temp3,GammaPointtemp
	
	temp=sqrt(A1^2+B1^2+C1^2)

	A1/=temp
	B1/=temp
	C1/=temp

	A1=round(A1*1000)/1000
	B1=round(B1*1000)/1000
	C1=round(C1*1000)/1000

	Variable Px,Py,Pz

	Px=Pl*A1//-BZh*astar
	Py=Pl*B1//-BZl*bstar
	Pz=Pl*C1//-BZk*cstar

	Point={Px,Py,Pz}
	
	temp1={A1,B1,C1}
	temp2={0,0,1}
	GammaPointtemp=0
	
	variable thetaz,thetax

	if ((A1==0)&&(B1==0)&&(C1==1))
		thetaz=0
	else
		Matrixcross(temp2,temp1)//?
		Wave w_result
		temp3=w_result/MatrixSum(w_result)
		if (temp3[1]<0)
			thetaz=acos(temp3[0])
		else
			thetaz=2*pi-acos(temp3[0])
		endif
	endif

	Make /o/n=(3,3) Rz,Rx,RzI,RxI
	Make /o/n=2 RT

	Rz={{cos(thetaz),-sin(thetaz),0}, {sin(thetaz),cos(thetaz),0}, {0,0,1}}
	thetaz=-thetaz
	RzI={{cos(thetaz),-sin(thetaz),0}, {sin(thetaz),cos(thetaz),0}, {0,0,1}}

	MatrixMultiply RZI,temp1
	Wave M_product
	temp1=M_product[p]
	if (M_product[1]>=0)
		thetax=acos(M_product[2])
	else
		thetax=2*pi-acos(M_product[2])
	endif

	Rx={ {1,0,0}, {0,cos(thetax),-sin(thetax)}, {0,sin(thetax),cos(thetax)} }
	thetax=-thetax
	RxI= { {1,0,0}, {0,cos(thetax),-sin(thetax)}, {0,sin(thetax),cos(thetax)} }
	
	thetax/=pi/180
	thetaz/=pi/180
	
	thetaz=-thetaz
	thetax=-thetax
	
	RxI=(abs(RxI[p][q])<1e-6)?(0):(RxI[p][q])
	RzI=(abs(RzI[p][q])<1e-6)?(0):(RzI[p][q])
	Rx=(abs(Rx[p][q])<1e-6)?(0):(Rx[p][q])
	Rz=(abs(Rz[p][q])<1e-6)?(0):(Rz[p][q])
	
	Variable cubexn,cubeyn,cubezn
	index=0
	do 
		wname = "w_tightbind_"+num2str(index)
		wave w=$wname
		
		make /o/n=(dimsize(w,0),dimsize(w,1),dimsize(w,2)),temp_w 
		temp_w=w[p][q][r]
		Setscale /I x, -gv_BZ_tig_kxpi*gv_BZ_tig_kxrange,gv_BZ_tig_kxpi*gv_BZ_tig_kxrange, temp_w
		Setscale /I y, -gv_BZ_tig_kypi*gv_BZ_tig_kyrange,gv_BZ_tig_kypi*gv_BZ_tig_kyrange, temp_w
		Setscale /I z, -gv_BZ_tig_kzpi*gv_BZ_tig_kzrange,gv_BZ_tig_kzpi*gv_BZ_tig_kzrange, temp_w
		
		returnFSMrange(temp_w,thetaz,1)
		Wave Rangewave
		
		if (sign(thetaz)==1)
			ImageRotate /A=(thetaz) /Q/O temp_w
		else
			ImageRotate /A=(360+thetaz) /Q/O  temp_w
		endif

		Setscale /I x,Rangewave[0],Rangewave[1],temp_w
		Setscale /I y,Rangewave[2],Rangewave[3],temp_w
		Killwaves /Z rangewave
		
		
		make /o/n=(dimsize(temp_w,1),dimsize(temp_w,2),dimsize(temp_w,0)),temp_w2 
		temp_w2=temp_w[r][p][q]
		Setscale /I z, M_x0(temp_w),M_x1(temp_w), temp_w2
		Setscale /I x, M_y0(temp_w),M_y1(temp_w),  temp_w2
		Setscale /I y, M_z0(temp_w),M_z1(temp_w),  temp_w2
		
		returnFSMrange(temp_w2,thetax,1)
		Wave Rangewave
		
		if (sign(thetax)==1)
			ImageRotate /A=(thetax) /Q/O temp_w2
		else
			ImageRotate /A=(360+thetax) /Q/O  temp_w2
		endif

		Setscale /I x,Rangewave[0],Rangewave[1],temp_w2
		Setscale /I y,Rangewave[2],Rangewave[3],temp_w2
		Killwaves /Z rangewave
		
		make /o/n=(dimsize(temp_w2,2),dimsize(temp_w2,0),dimsize(temp_w2,1)),temp_w3
		Setscale /I x, M_z0(temp_w2),M_z1(temp_w2), temp_w3
		Setscale /I y, M_x0(temp_w2),M_x1(temp_w2), temp_w3
		Setscale /I z, M_y0(temp_w2),M_y1(temp_w2),temp_w3
		Wave w_plot=temp_w3
		w_plot=temp_w2[q][r][p]

		
		Variable zpos=x2pntsmult(w_plot,PL,2)
		if (zpos<0)
			zpos=0
		endif
	
		if (zpos>dimsize(w_plot,2))
			zpos=dimsize(w_plot,2)
		endif
		
		
		
		Imagetransform /PTYP=0 /P=(zpos) getPlane w_plot///X={plotn,plotn, x0,y0,z0,x1,y1,z1,x2,y2,z2} extractsurface w
		Wave M_imageplane
		wname = "w_tightbind_plot_"+num2str(index)
		Duplicate /o M_imageplane $wname
		Setscale /I x,M_x0(w_plot),M_x1(w_plot), $wname
		Setscale /I y,M_y0(w_plot),M_y1(w_plot), $wname
		drawTightBinding(wname,kx0, ky0)
		index+=1
	while (index<gv_num_tightbind)
	
	
	//Killwaves /Z temp_w,temp_w2,temp_w3,M_RotatedImage,M_ImagePlane,a_base,b_base,c_base,VectorP3
	//Killwaves /Z temp1,temp2,temp3,Point,RxI,Rx,RzI,RZ,RT,M_product,GammaPointtemp

	SetDatafolder DF
End


	
	
Function Cal_Tight_binding(w,bandstr,parlist)
	Wave w
	String bandstr
	String parlist
	
	Note w, "Model: E = " +  bandstr+"\r"+"Parlist:"+parlist
	
	Variable tempos1,tempos2
	do
		tempos1=strsearch(bandstr,"T",0)
		if (tempos1==-1)
			break
		endif
		tempos2=strsearch(bandstr,"*",tempos1)
		
		String parname=removespace(bandstr[tempos1,tempos2-1])
		Variable parvalue=numberbykey(parname,parlist,"=")
		if (numtype(parvalue)==2)
			doalert 0, "par not found"
			return 0
		else
			bandstr=replacestring(parname,bandstr,num2str(parvalue))
		endif
		
	while (1)
	
	
	String execFormula = nameofwave(w)+"="+ bandstr
	Execute execFormula
	return 1
	
End


Function drawTightBinding(wname,kx0,ky0)
	String wname
	Variable kx0,ky0

	DFREF dF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_tight=$(DF_panel+":tight_binding")

	SetDatafolder DFR_panel
	
	DFREF  DFR_global=$DF_global
	
	NVAR azi=DFR_panel:gv_BZ_rotate//DFR_global:gv_SampleOrientation
	WAVE w = DFR_tight:$wname
	NVAR gv_BZ_tig_ES, gv_BZ_tig_EE, gv_BZ_tig_steps
	
	controlinfo tightbinding_ck0
	Variable autocontour=v_value
	
	String waven=nameofwave(w)
	SetDatafolder DFR_tight
	
	returnFSMrange(w,azi,1)
	Wave Rangewave
		
	if (sign(azi)==1)
		ImageRotate /A=(azi) /Q/O w
	else
		ImageRotate /A=(360+azi) /Q/O  w
	endif
	
	Setscale /I x,Rangewave[0],Rangewave[1],w
	Setscale /I y,Rangewave[2],Rangewave[3],w
	Killwaves /Z rangewave
	
	//waven+="_rot"
	//ImageRotate/Q/O/S/A=(azi)/E=(NaN) w
	
	WAVE w_rot = $waven	// ImageRotate does not preserve the image scaling. -> apply the following bugfix:
	
	Variable x0,x1,y0,y1

	x0=M_x0(w_rot)
	x1=M_x1(w_rot)
	y0=M_y0(w_rot)
	y1=M_y1(w_rot)
	
	Setscale /I x, x0+kx0,x1+kx0,w_rot
	Setscale /I y, y0+ky0,y1+ky0,w_rot

	checkdisplayed /W=$winname(0,65) $waven
	if (V_flag==0)
		AppendMatrixContour w_rot
	endif
		if (autocontour == 0)
			ModifyContour $waven, manLevels= {gv_BZ_tig_ES, gv_BZ_tig_EE, gv_BZ_tig_steps}
		endif
	SetDataFolder DF
End





/////////////sdc 20150605////////////////
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function add_BZ_DCs(panelName)
	String panelName
	DFREF Df = getdatafolderDFR()
	
	String DF_panel="root:internalUse:"+winname(0,65)
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetDataFolder DFR_panel
	DFREF DFR_common=$DF_panel+":panel_common"
	SetDatafolder DFR_common
	
	String panelcommonPath=GetDatafolder(1,DFR_common) 
	
	String imagename=stringfromlist(0,Imagenamelist(winname(0,65),";"),";")
	
	wave w_image=ImageNameToWaveRef(winname(0,65), imagename)
	
	Make/N=(dimsize(w_image,0))/O n_mdc, n_mdc2
		Make/N=(dimsize(w_image,1))/O n_edc, n_edc2// n_edc_x
		SetScale/I x, M_x0(w_image),M_x1(w_image), n_mdc, n_mdc2
		SetScale/I x, M_y0(w_image),M_y1(w_image), n_edc, n_edc2//, n_edc_x
		//n_edc_x = x
		
		ShowInfo;
		Cursor/P/I/H=1 A $imagename dimsize(w_image,0)/3,dimsize(w_image,1)/3
		Cursor/P/I/H=1 B $imagename dimsize(w_image,0)/2,dimsize(w_image,1)/2
	
	WAVE n_mdc; WAVE n_edc//; WAVE n_edc_x
	Wave n_mdc2; Wave n_edc2
	
	n_mdc=w_image[p][qcsr(A)]
	n_mdc2=w_image[p][qcsr(B)]
	
	n_edc=w_image[pcsr(A)][p]
	n_edc2=w_image[pcsr(B)][p]
	
	Checkdisplayed /W=$winname(0,65) n_edc
	if (V_flag==0)
		AppendToGraph/Q/VERT/L=edc_en/B=edc_int n_edc//n_edc_x vs n_edc
	endif
	
	Checkdisplayed /W=$winname(0,65) n_edc2
	if (V_flag==0)
		AppendToGraph/Q/VERT/L=edc_en/B=edc_int n_edc2
	endif
	
		Checkdisplayed /W=$winname(0,65) n_mdc
	if (V_flag==0)
		AppendToGraph/Q/L=mdc_int/B=mdc_angle n_mdc
	endif

		Checkdisplayed /W=$winname(0,65) n_mdc2
	if (V_flag==0)
		AppendToGraph/Q/L=mdc_int/B=mdc_angle n_mdc2
	endif

	
	ModifyGraph freePos(edc_en)={-inf,edc_int}
	ModifyGraph freePos(edc_int)={-inf,edc_en}
       ModifyGraph axisEnab(edc_en)={0,0.55},axisEnab(edc_int)={0.65,1}
       ModifyGraph axisEnab(left)={0,0.55},axisEnab(bottom)={0,0.55}
       ModifyGraph freePos(mdc_int)={-inf,mdc_angle}
       ModifyGraph freePos(mdc_angle)={-inf,mdc_int}
       ModifyGraph axisEnab(mdc_int)={0.65,1},axisEnab(mdc_angle)={0,0.55}
       ModifyGraph rgb(n_edc)=(52428,1,1), rgb(n_mdc)=(52428,1,1)
       ModifyGraph rgb(n_mdc2)=(1,26214,0),rgb(n_edc2)=(1,26214,0)
       
       getaxis/Q left
       SetAxis edc_en,V_min,V_max
       
       getaxis/Q bottom
       SetAxis mdc_angle,V_min,V_max

	setwindow $winname(0,65), hook(cursorhook)=updatecursorHook


	SetDataFolder DF
End






Function updatecursorHook(s)


	STRUCT WMWinHookStruct &s
variable rval=0
	if(s.eventCode==6||s.eventCode==7||s.eventCode==8)
		
		DFREF Df = getdatafolderDFR()
	
	String DF_panel="root:internalUse:"+s.winName
//	SetActiveSubwindow $winName
	DFREF DFR_panel=$DF_panel
	SetDataFolder DFR_panel
	DFREF DFR_common=$DF_panel+":panel_common"
	SetDatafolder DFR_common
	
	String panelcommonPath=GetDatafolder(1,DFR_common) 
	
	String imagename=stringfromlist(0,Imagenamelist(winname(0,65),";"),";")
	
	wave w_image=ImageNameToWaveRef(winname(0,65), imagename)
	
		Make/N=(dimsize(w_image,0))/O n_mdc, n_mdc2
		Make/N=(dimsize(w_image,1))/O n_edc, n_edc2// n_edc_x
		SetScale/I x, M_x0(w_image),M_x1(w_image), n_mdc, n_mdc2
		SetScale/I x, M_y0(w_image),M_y1(w_image), n_edc, n_edc2//, n_edc_x
	
	WAVE n_mdc; WAVE n_edc//; WAVE n_edc_x
	Wave n_mdc2; Wave n_edc2
	//print num2str(qcsr(A,s.winName))
	n_mdc=w_image[p][qcsr(A,s.winName)]
	n_mdc2=w_image[p][qcsr(B,s.winName)]
	
	n_edc=w_image[pcsr(A,s.winName)][p]
	n_edc2=w_image[pcsr(B,s.winName)][p]
	
	Checkdisplayed /W=$s.winName n_edc
	if (V_flag==0)
		AppendToGraph/Q/VERT/L=edc_en/B=edc_int n_edc//n_edc_x vs n_edc
	endif
	
	Checkdisplayed /W=$s.winName n_edc2
	if (V_flag==0)
		AppendToGraph/Q/VERT/L=edc_en/B=edc_int n_edc2
	endif
	
		Checkdisplayed /W=$s.winName n_mdc
	if (V_flag==0)
		AppendToGraph/Q/L=mdc_int/B=mdc_angle n_mdc
	endif

		Checkdisplayed /W=$s.winName n_mdc2
	if (V_flag==0)
		AppendToGraph/Q/L=mdc_int/B=mdc_angle n_mdc2
	endif

	
	ModifyGraph/W=$s.winName freePos(edc_en)={-inf,edc_int}
	ModifyGraph/W=$s.winName freePos(edc_int)={-inf,edc_en}
       ModifyGraph/W=$s.winName axisEnab(edc_en)={0,0.55},axisEnab(edc_int)={0.65,1}
       ModifyGraph/W=$s.winName axisEnab(left)={0,0.55},axisEnab(bottom)={0,0.55}
       ModifyGraph/W=$s.winName freePos(mdc_int)={-inf,mdc_angle}
       ModifyGraph/W=$s.winName freePos(mdc_angle)={-inf,mdc_int}
       ModifyGraph/W=$s.winName axisEnab(mdc_int)={0.65,1},axisEnab(mdc_angle)={0,0.55}
       ModifyGraph/W=$s.winName rgb(n_edc)=(52428,1,1), rgb(n_mdc)=(52428,1,1)
       ModifyGraph/W=$s.winName rgb(n_mdc2)=(1,26214,0),rgb(n_edc2)=(1,26214,0)
       
       getaxis/W=$s.winName/Q left
       SetAxis/W=$s.winName edc_en,V_min,V_max
       
       getaxis/W=$s.winName/Q bottom
       SetAxis/W=$s.winName mdc_angle,V_min,V_max


	SetDataFolder DF
rval=1
	Endif

	return rval
End
























































