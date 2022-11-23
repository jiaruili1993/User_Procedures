#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 0.01
#pragma ModuleName = Mapper3Dpanel


StrConstant DFS_cubesave="root:graphsave:cubes"

////////////////////////////////////3Dshow//////////////////////////////////////////////
Function Initial_3DCuts(plotcube)

Wave plotcube
print "function to be developed"
//	
//	DFREF DF=GetDatafolderDFR()
//	String DFS_panel="root:internalUse:"+winname(0,65)
//	DFREF DFR_panel=$DFS_panel
//	
//	
//	SetDatafolder DFR_panel
//	
//	NVAR gv_Estart=DFR_panel:gv_Estart
//	NVAR gv_Eend=DFR_panel:gv_Eend
//	NVAR gv_DeltaE=DFR_panel:gv_deltaE
//	
//	gv_Estart=dimoffset(plotcube,2)
//	gv_deltaE=dimdelta(plotcube,2)
//	gv_Eend=gv_Estart+(dimsize(plotcube,2)-1)*gv_deltaE
//	
//	
//	SetVariable mapper3D_sv0,limits= {gv_Estart,gv_Eend,gv_deltaE}
//	Slider mapper3D_s0,limits= {gv_Estart,gv_Eend,gv_deltaE}
//
//	
//	Variable xnum,x0,x1,ynum,y0,y1,znum,z0,z1
//	
//	xnum=dimsize(plotcube,0)
//	x0=M_x0(plotcube)
//	x1=M_x1(plotcube)
//	
//	ynum=dimsize(plotcube,1)
//	y0=M_y0(plotcube)
//	y1=M_y1(plotcube)
//	
//	znum=dimsize(plotcube,2)
//	z0=dimoffset(plotcube,2)
//	z1=dimoffset(plotcube,2)+(dimsize(plotcube,2)-1)*dimdelta(plotcube,2)
//
//	make /o/n=(xnum,ynum) xyFSM
//	make /o/n=(xnum,znum) xzimage
//	make /o/n=(ynum,znum) yzimage
//	make /o/n=(znum,ynum) yzimage_rot
//	make /o/n=(1,znum) Lineimage
//	
//	make /o/n=(xnum,ynum,3) xyFSM3D
//	make /o/n=(xnum,znum,3) xzimage3D
//	make /o/n=(ynum,znum,3) yzimage3D
//	
//	Setscale /I x,x0,x1,xyFSM,xzimage,xyFSM3D,xzimage3D
//	Setscale /I y,z0,z1,xzimage,xzimage3D,Lineimage,yzimage3D
//	Setscale /I y,y0,y1,xyFSM,xyFSM3D
//	Setscale /I x,y0,t, yzimage,yzimage3D
//
//	Setscale /I x,z0,z1,yzimage_rot
//	Setscale /I y,y0,y1,yzimage_rot
//	
//	NVAR Energyratio=gv_gizmoEnergyration
//	Energyratio=Max(abs(x0-x1),abs(y0-y1))/abs(z0-z1) ///for gizmo display, aspect issue
//
//	xyFSM3D[][][0]=x
//	xyFSM3D[][][1]=y
//	xzimage3D[][][0]=x
//	xzimage3D[][][2]=y*Energyratio
//	yzimage3D[][][1]=x
//	yzimage3D[][][2]=y*Energyratio
	
	

end

Function close_mapper_3D_panel(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderDFR()
	String DFS_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DFS_panel
	
	NVAR  gv_Killflag=DFR_panel:gv_Killflag
	
	gv_Killflag=1
		
	Dowindow /K $winname(0,65)

end

Function Proc_bt_Del_cube(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderDFR()
	String DFS_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DFS_panel
	
	SVAR currentCube=DFR_panel:gs_currentCubeSource
	
	Wave cube=$currentCube
	
	Doalert 1,"Delete select cube?"
	if (V_flag==2)
		return 0
	endif
	
	Killwaves /Z cube
	update_cube_list()
End

Function /DF Initial_FSM3Dshow()//(DF_mapper3D,cube,mappername)
	DFREF DF = GetDataFolderDFR()
  	String DF_panel="root:internalUse:"+winname(0,65)
    	NewDataFolder/O/S $DF_panel
    	
	DFREF DF_mapper3D=GetDatafolderDFR()
	
	//Wave cube
	//String mappername

	//SetDatafolder DF_mapper3D
	
	Variable /G gv_Killflag=0

	Variable /G gv_plotEnergy=0
	Variable /G gv_Estart=0
	Variable /G gv_Eend=1
	Variable /G gv_deltaE=1
	Variable /G xpos=0,ypos=0,zpos=0//x2pntsmult(plotcube,gv_plotEnergy,2)
	Variable /G xvalue=0,yvalue=0
	Variable /G xApos=0,yApos=0
	Variable /G xAvalue=0,yAvalue=0
	Variable /G gv_rotateangle=0
	Variable /G gv_dirflag=0
	Variable /G gv_smthpnts=2
	Variable /G gv_smthtimes=5
	//String/G gs_mappername=mappername
	Variable /G gv_curveflag=0
	Variable /G gv_Cfactor=0.01
	
	
	
	Variable /G gv_Elineflag=0
	
	Variable /G gv_gizmoflag=0
	Variable /G gv_gizmoEnergyration
	
	String /G gs_GizmoCtabname="Grays"
	Variable /G gv_GizmoCtabInverse=0
	Variable /G gv_GizmoCtabMax=Nan
	Variable /G gv_GizmoCtabMin=Nan
	Variable /G gv_GizmoCtabgamma=1
	Variable /G gv_sliderleft=0
	Variable /G gv_sliderright=0
	Variable /G gv_GizmoCtabnum=0
	
	String /G gs_gizmodispstr="1111111111"
	
	
	Variable /G gv_autoFSMflag=0
	String /G gs_autoFSM_panellist=""
	

	Variable /G gv_P1_x
	Variable /G gv_P1_y


	Make /o/T/n=0 ManualCuts
	
	Make /o/n=2 Energyline_x,Energyline_y
	
	Energyline_x[0]=-inf
	Energyline_x[1]=inf
	
	Make /o/n=2 Energyline1_x,Energyline1_y
	Energyline1_y[0]=-inf
	Energyline1_y[1]=inf
	
	Make /o/n=2 Lineprofile_x,Lineprofile_y
	
	
	make /o/n=(100,100) xyFSM
	make /o/n=(100,100) xzimage
	make /o/n=(100,100) yzimage_rot
	make /o/n=(1,100) Lineimage
	
	newDatafolder /o $DFS_cubesave
	
	Variable /G gv_sortopt=1
	String /G gs_currentCubeSource=""
	String /G gs_currentCubeName=""
	Make /o/n=0/T CubeName_list
	Make /o/n=0/B CubeName_list_sel
	
	update_cube_list()
	
	
	SetDatafolder DF
	return DF_mapper3D
	
	//SetFormula zpos, "x2pntsmult(plotcube,gv_plotEnergy,2)"
End

Function FSM_initialCube(ctrlname)
	String ctrlname
	
	DFREF DF=GetDatafolderDFR()
	String DFS_panel="root:internalUse:"+winname(0,65)
	DFREF DF_panel=$DFS_panel
	DFREF DF_common=$(dFS_panel+":panelcommonPath")
	NVAR toplayernum=DF_common:gv_toplayernum
	
	
	String mappername=winname(0,65)
	String suffix=mappername[strsearch(mappername,"panel_",inf,1)+6,inf]
	String cubename="Cube_"+suffix
	
	prompt cubename,"Input Cube name"
	doprompt "Input Cube name",cubename
	
	if (V_flag)
		return 0
	endif
	
	
	master_mapper("Mapper_3D")
	
	Wave cube=DF_panel:cfe_kxkyCube
	
	DFREF DF_save=$DFS_cubesave
	
	Duplicate /o cube,DF_save:$cubename
	
	Killwaves/Z cube
end

Function FSM_enable3DShow(ctrlname)
	String ctrlname

	DFREF DF=GetDatafolderDFR()

	Variable SC = Screensize(5)
	Variable SR = Igorsize(3) 
	Variable ST = Igorsize(2)
	Variable SL = Igorsize(1)
       Variable SB = Igorsize(4)
	
	DFREF DFR_prefs=$DF_prefs
    	NVAR panelscale=DFR_prefs:gv_panelscale
    	NVAR macscale=DFR_prefs:gv_macscale
    	
    	Variable Width = 545*panelscale*macscale //* SC		// panel size  
	Variable height = 500*panelscale*macscale //* SC
	Variable xOffset = (SR-SL)/2-width/2
	Variable yOffset = (SB-ST)/2-height/2
	
	
	String panelnamelist=winlist("mapper3D_panel_*",";","WIN:65")

	if (stringmatch(ctrlname,"recreate_window")==0)
		if (strlen(panelnamelist)==0)
			string spwinname=UniqueName("mapper3D_panel_", 9, 0)
			Display /W=(xOffset, yOffset,xOffset+width,Height+yOffset) as spwinname
			DoWindow/C $spwinname
   			Setwindow $spwinname hook(MyHook) =  MypanelHook
		else
	
			if (stringmatch(ctrlname,"global_duplicate_panel"))
				//Hidedown_Allthepanel(panelnamelist)
				spwinname=UniqueName("mapper3D_panel_", 9, 0)
				Display /W=(xOffset, yOffset,xOffset+width,Height+yOffset) as spwinname
				DoWindow/C $spwinname
   				Setwindow $spwinname hook(MyHook) = MypanelHook
			else
				BringUP_thefirstpanel(panelnamelist)
				SetDataFolder DF 
				return 1
			endif
		endif
		
		DFREF DFR_mapper3D=Initial_FSM3Dshow()
	else
		BringUP_thefirstpanel(panelnamelist)
		DFREF DFR_mapper=$("root:internalUse:"+winname(0,65))
		DFREF DFR_common=$("root:internalUse:"+winname(0,65)+":panel_common")
		SetActiveSubwindow $winname(0,65)
	endif
	

	
	SetDatafolder DFR_mapper3D//=GetDatafolderDFR()
	//(DF_mapper3D,cube,mappername)

	controlbar  240*SC
	Variable r=57000, g=57000, b=57000
	modifygraph wbRGB=(65280,48896,48896), gbRGB=(65280,48896,48896)
	ModifyGraph cbRGB=(52428,52428,52428)
	
	TabControl map,proc=mapper3DPanel#map_AutoTab,pos={8*SC,6*SC},size={665*SC,210*SC},value=0,labelBack=(r,g,b)
	
	groupbox global_gp0,pos={20*SC,30*SC},frame=0,size={145*SC,180*SC},title="Source"
	Listbox global_lb0,pos={30*SC,50*SC},size={130*SC,150*SC},listwave=DFR_mapper3D:CubeName_list,mode=9,selwave=DFR_mapper3D:CubeName_list_sel,proc=mapper3DPanel#Cube_list_sel
	Checkbox global_ck0, pos={100*SC,30*SC},size={50*SC,20*SC},variable=DFR_mapper3D:gv_sortopt,title="sort"
	
	
	CheckBox global_ck5, pos={10*SC,220*SC}, title="Lock FSM scale", proc=lock_intensity
	CheckBox global_ck2, pos={120*SC,220*SC}, title="lock csr pos"
	CheckBox global_ck10, pos={210*SC,220*SC}, title="lock aspect",value=1,proc=lock_aspect


	Button global_gold, size={40*SC,20*SC},pos={680*SC,25*SC}, title="gold", proc=open_gold_panel
	Button global_main, size={40*SC,20*SC},pos={680*SC,55*SC}, title="main", proc= Open_main_Panel
	//Button global_map, size={40,20},pos={640,85}, title="map", proc= open_mapper_panel
	Button global_BZ, size={40*SC,20*SC},pos={680*SC,85*SC}, title="BZ", proc=open_bz_panel
	Button global_Anal, size={40*SC,20*SC},pos={680*SC,115*SC}, title="Anal", proc=Open_Analysis_Panel
	Button global_Merge, size={40*SC,20*SC},pos={680*SC,145*SC}, title="Merge", proc=Open_Merge_Panel
	
	TabControl map, tabLabel(0)="mapper3D"
	button global_delbt,pos={410*SC,3*SC},size={80*SC,18*SC},title="Del Cube",proc=Proc_bt_Del_cube
	button Global_bt0,pos={510*SC,3*SC},size={80*SC,18*SC},title="close",proc=close_mapper_3D_panel
	Button global_duplicate_panel, pos={600*SC,3*SC},size={70*SC,18*SC},title="duplicate", proc=FSM_enable3DShow
	
	NVAR gv_Estart,gv_Eend,gv_deltaE

	groupbox mapper3D_tb0,pos={173*SC,30*SC},frame=0,size={85*SC,180*SC},title="Energy"
	SetVariable mapper3D_sv0,pos={177*SC,50*SC},size={80*SC,15*SC},limits= {-inf,inf,0.01},variable=gv_plotEnergy,title=" ",proc=mapper3D_Energychange
	//Slider mapper3D_s0,appearance={os9, Win},pos={177*SC,75*SC},size={20*SC,100*SC},limits= {-inf,inf,0.001},variable=gv_plotEnergy,vert=1,ticks=10,proc=mapper3D_sliderchange
	Checkbox mapper3D_ck3,pos={180*SC,185*SC},frame=0,size={100*SC,18*SC},title="Plot Line", variable=gv_Elineflag,proc=mapper3DPanel#proc_ck_plotEline
	

	groupbox mapper3D_tb1,pos={265*SC,30*SC},frame=0,size={80*SC,45*SC},title="Rotate"
	SetVariable mapper3D_sv1,pos={270*SC,50*SC},size={70*SC,15*SC},limits= {-inf,inf,1},variable=gv_rotateangle,title="Ang:",proc=mapper3D_angchange

	groupbox mapper3D_tb2,pos={265*SC,80*SC},frame=0,size={80*SC,130*SC},title="D2nd & Curve"
	SetVariable mapper3D_sv2,pos={270*SC,100*SC},size={70*SC,15*SC},limits= {1,inf,1},variable=gv_smthpnts,title="pnts:",proc=mapper3D_smthchange
	SetVariable mapper3D_sv3,pos={270*SC,120*SC},size={70*SC,15*SC},limits= {0,inf,1},variable=gv_smthtimes,title="times:",proc=mapper3D_smthchange
	checkbox mapper3D_ck0,pos={270*SC,140*SC},size={70*SC,15*SC},title="D2nd",variable=gv_dirflag,proc=mapper3D_Dirchange
	
	SetVariable mapper3D_sv5,pos={270*SC,160*SC},size={70*SC,15*SC},limits= {0,inf,0.01},variable=gv_Cfactor,title="A0:",proc=mapper3D_smthchange
	//SetVariable mapper3D_sv6,pos={130*SC,180*SC},size={70*SC,15*SC},limits= {0,inf,1},variable=gv_smthtimes,title="times:",proc=mapper3D_Energychange
	checkbox mapper3D_ck01,pos={270*SC,180*SC},size={70*SC,15*SC},title="Curve",variable=gv_curveflag,proc=mapper3D_Dirchange


	groupbox mapper3D_tb3,pos={355*SC,30*SC},frame=0,size={310*SC,75*SC},title="Display"
	//SetVariable mapper3D_sv4,pos={200,25},frame=1,size={70,18},title=" ",limits= {-inf,inf,0},value=gs_SaveName
	Button mapper3D_b0,pos={360*SC,75*SC},frame=0,size={70*SC,18*SC},title="H Cut",proc=mapper3DPanel#mapper3D_SaveIM
	Button mapper3D_b1,pos={435*SC,50*SC},frame=0,size={70*SC,18*SC},title="V Cut",proc=mapper3DPanel#mapper3D_SaveIM
	Button mapper3D_b2,pos={360*SC,50*SC},frame=0,size={70*SC,18*SC},title="FSM_kxky",proc=mapper3DPanel#mapper3D_SaveIM
	Button mapper3D_b6,pos={435*SC,75*SC},frame=0,size={70*SC,18*SC},title="Line Cut",proc=mapper3DPanel#mapper3D_SaveIM
	Button mapper3D_b8,pos={585*SC,50*SC},frame=0,size={70*SC,18*SC},title="FSM sum",proc=mapper3DPanel#plotcubesum
	Checkbox mapper3D_ck1,pos={510*SC,77*SC},frame=0,size={70*SC,18*SC},title="Save"
	Checkbox mapper3D_ck2,pos={560*SC,77*SC},frame=0,size={100*SC,18*SC},title="Gizmo", variable=gv_gizmoflag
	Button mapper3D_b4,pos={510*SC,50*SC},frame=0,size={70*SC,18*SC},title="Plot in BZ",proc=mapper3DPanel#mapper3D_PlotinBZ
	
	
	//Button mapper3D_b5,pos={220*SC,150*SC},frame=0,size={100*SC,18*SC},title="Plot Gizmo",proc=mapper3DPanel#mapper3D_Plot3D
	
	groupbox mapper3D_tb4,pos={355*SC,110*SC},frame=0,size={130*SC,100*SC},title="Gizmo Crop"
	Checkbox mapper3D_ck4,pos={360*SC,155*SC},frame=0,size={30*SC,18*SC},title="1",value=1,proc=mapper3DPanel#mapper3D_updatedispstr
	Checkbox mapper3D_ck5,pos={390*SC,155*SC},frame=0,size={30*SC,18*SC},title="2",value=1,proc=mapper3DPanel#mapper3D_updatedispstr
	Checkbox mapper3D_ck6,pos={420*SC,155*SC},frame=0,size={30*SC,18*SC},title="3",value=1,proc=mapper3DPanel#mapper3D_updatedispstr
	Checkbox mapper3D_ck7,pos={360*SC,172*SC},frame=0,size={30*SC,18*SC},title="4",value=1,proc=mapper3DPanel#mapper3D_updatedispstr
	Checkbox mapper3D_ck8,pos={420*SC,172*SC},frame=0,size={30*SC,18*SC},title="5",value=1,proc=mapper3DPanel#mapper3D_updatedispstr
	Checkbox mapper3D_ck9,pos={360*SC,190*SC},frame=0,size={30*SC,18*SC},title="6",value=1,proc=mapper3DPanel#mapper3D_updatedispstr
	Checkbox mapper3D_ck10,pos={390*SC,190*SC},frame=0,size={30*SC,18*SC},title="7",value=1,proc=mapper3DPanel#mapper3D_updatedispstr
	Checkbox mapper3D_ck11,pos={420*SC,190*SC},frame=0,size={30*SC,18*SC},title="8",value=1,proc=mapper3DPanel#mapper3D_updatedispstr
	
	Checkbox mapper3D_ck12,pos={375*SC,130*SC},frame=0,size={30*SC,18*SC},title="U",value=1,proc=mapper3DPanel#mapper3D_updatedispstr
	Checkbox mapper3D_ck13,pos={405*SC,130*SC},frame=0,size={30*SC,18*SC},title="D",value=1,proc=mapper3DPanel#mapper3D_updatedispstr
	
	Checkbox mapper3D_ck14,pos={455*SC,160*SC},frame=0,size={30*SC,18*SC},title="I",value=1,proc=mapper3DPanel#mapper3D_updatedispstr
	Checkbox mapper3D_ck15,pos={455*SC,180*SC},frame=0,size={30*SC,18*SC},title="O",value=1,proc=mapper3DPanel#mapper3D_updatedispstr
	
	groupbox mapper3D_tb5,pos={490*SC,110*SC},frame=0,size={175*SC,100*SC},title="Gizmo Color"
	Checkbox mapper3D_ck16,pos={495*SC,130*SC},frame=0,size={60*SC,18*SC},title="Global",value=0,proc=mapper3DPanel#mapper3D_ck_updatecolor
	Checkbox mapper3D_ck18,pos={550*SC,130*SC},frame=0,size={60*SC,18*SC},title="All",value=0,proc=mapper3DPanel#mapper3D_ck_updatecolor
	
	SetVariable mapper3D_sv4,pos={585*SC,129*SC},size={70*SC,18*SC},limits={0,10,0},title="Gamma",variable=gv_GizmoCtabgamma,proc=mapper3DPanel#Proc_IMGrange_SVchange
	NVAR gv_GizmoCtabnum=gv_GizmoCtabnum
	PopupMenu mapper3D_p1,pos={465*SC,150*SC},bodyWidth=80*SC,size={113*SC,18*SC},title="",value="*COLORTABLEPOPNONAMES*", mode=gv_GizmoCtabnum
	popupMenu mapper3D_p1,proc=mapper3DPanel#Proc_colortab_PopMenuProc
	
	Checkbox mapper3D_ck17,pos={590*SC,150*SC},frame=0,size={50*SC,18*SC},title="Reverse",variable=gv_GizmoCtabInverse,proc=mapper3DPanel#mapper3D_ck_updatecolor
	
	SetVariable mapper3D_Xleft,pos={495*SC,170*SC},size={40*SC,18*SC},limits={-inf,inf,0},value=gv_GizmoCtabMin,title=" ",proc=mapper3DPanel#Proc_IMGrange_SVchange
	SetVariable mapper3D_Xright,pos={495*SC,190*SC},size={40*SC,18*SC},limits={inf,inf,0},value=gv_GizmoCtabMax,title=" ",proc=mapper3DPanel#Proc_IMGrange_SVchange
	Slider mapper3D_leftslider,pos={537*SC,173*SC},size={80*SC,13*SC},limits={-1,2,0},variable=gv_sliderleft,side= 0,vert= 0,proc=mapper3DPanel#Proc_IMGrange_change
	Slider mapper3D_rightslider,pos={537*SC,193*SC},size={80*SC,13*SC},limits={-1,2,0},variable=gv_sliderright,side= 0,vert= 0,proc=mapper3DPanel#Proc_IMGrange_change
	Button mapper3D_DefaultHist,pos={620*SC,170*SC},size={40*SC,18*SC},title="Default",proc=mapper3DPanel#proc_bt_histchange
	Button mapper3D_AutoHist,pos={620*SC,190*SC},size={40*SC,18*SC},title="Auto",proc=mapper3DPanel#proc_bt_histchange
	
	
	TabControl map, tabLabel(1)="ManualCut"
	
	Groupbox ManualCut_gb0,frame=0,pos={180*SC,30*SC},size={270*SC,80*SC},title="Add Points",disable=1
	Setvariable ManualCut_sv0,pos={190*SC,50*SC},size={120*SC,20*SC},limits={-inf,inf,0},title="Point X:",value=gv_P1_x,disable=1
	Setvariable ManualCut_sv1,pos={310*SC,50*SC},size={80*SC,20*SC},limits={-inf,inf,0},title="Y:",value=gv_P1_y,disable=1
	button ManualCut_bt9,pos={400*SC,50*SC},size={40*SC,20*SC},title="Csr",disable=1,proc=mapper3DPanel#proc_bt_ReadCsrManualPoint
	
	//Setvariable ManualCut_sv2,pos={30,70},size={120,20},limits={-inf,inf,0},title="Point2 X:",value=gv_P2_x,disable=1
	//Setvariable ManualCut_sv3,pos={150,70},size={80,20},limits={-inf,inf,0},title="Y:",value=gv_P2_y,disable=1
	//button ManualCut_bt10,pos={235,70},size={40,20},title="Csr",disable=1,proc=mapper3DPanel#proc_bt_ReadCsrManualPoint
	
	button ManualCut_bt0,pos={190*SC,75*SC},size={100*SC,20*SC},title="Add Points",disable=1,proc=mapper3DPanel#proc_bt_AddManualPoint
	button ManualCut_bt1,pos={295*SC,75*SC},size={100*SC,20*SC},title="Remove Points",disable=1,proc=mapper3DPanel#proc_bt_RemoveManualPoint
	button ManualCut_bt2,pos={400*SC,75*SC},size={40*SC,20*SC},title="Clear",disable=1,proc=mapper3DPanel#proc_bt_RemoveManualPoint
	
	Groupbox ManualCut_gb1,frame=0,pos={180*SC,125*SC},size={270*SC,60*SC},title="Defaut Points",disable=1
	
	button ManualCut_bt3,pos={190*SC,145*SC},size={80*SC,20*SC},title="Gamma",disable=1,proc=mapper3DPanel#proc_bt_DefaultManualPoint
	button ManualCut_bt4,pos={275*SC,145*SC},size={80*SC,20*SC},title="M",disable=1,proc=mapper3DPanel#proc_bt_DefaultManualPoint
	button ManualCut_bt5,pos={360*SC,145*SC},size={80*SC,20*SC},title="X",disable=1,proc=mapper3DPanel#proc_bt_DefaultManualPoint
	
	Listbox ManualCut_lb0,pos={460*SC,40*SC},size={190*SC,100*SC},title="Cut List",disable=1,mode=2,listwave=ManualCuts
	Button ManualCut_bt6,pos={460*SC,145*SC},size={150*SC,20*SC},title="Creat Interp Cuts",disable=1,proc=mapper3DPanel#proc_bt_CreatManualPoint_Interp
	Button ManualCut_bt7,pos={460*SC,170*SC},size={150*SC,20*SC},title="Creat Raw Cuts",disable=1,proc=mapper3DPanel#proc_bt_CreatManualPoint_raw
	
	
	
	appendimage /T=image_m/L=image_en xyFSM
	appendimage /L=edc_en/T=edc_int yzimage_rot
	appendimage xzimage
	
	appendimage /L=lineimage_e /B=Lineimage_m lineimage

	//ModifyGraph freePos(edc_int)={0,edc_en}
//	ModifyGraph freePos(edc_int)={Inf,edc_en}
	//ModifyGraph freePos(image_en)=0
	//ModifyGraph freePos(image_m)={0,image_en}
	//ModifyGraph axisEnab(lineimage_m)={0.65,1}
//	ModifyGraph axisEnab(lineimage_e)={0,0.38}
	ModifyGraph freePos(lineimage_e)={-inf,Lineimage_m}
	ModifyGraph freePos(Lineimage_m)={-inf,lineimage_e}
	
	ModifyGraph freePos(edc_en)={inf,edc_int}
	ModifyGraph freePos(edc_int)={inf,edc_en}
	ModifyGraph freePos(image_en)=0
	ModifyGraph freePos(image_m)=0
//	ModifyGraph axisEnab(left)={0,0.38},axisEnab(bottom)={0,0.55}
//	ModifyGraph axisEnab(edc_en)={0.42,1},axisEnab(edc_int)={0.65,1}
//	ModifyGraph axisEnab(image_en)={0.42,1},axisEnab(image_m)={0,0.55}
	
	appendtograph /T=image_m /L=image_en lineprofile_y vs lineprofile_x
	Modifygraph lstyle(lineprofile_y)=2
		
	ModifyGraph mirror(bottom)=0,mirror(left)=0
	
	SetAxis /A/R edc_int
	
	ModifyGraph height={Aspect,0.7}
	
	ModifyGraph btLen=4,stLen=2
	
	Adjustdisplayratio(3)
	
    	Cube_list_sel("dummy",0,0,4) 
	SetDatafolder DF

End

static Function update_cube_list()
	DFREF Df = getdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	
	Wave /T CubeName_list=DFR_panel:CubeName_list
	Wave /B CubeName_list_sel=DFR_panel:CubeName_list_sel
	NVAR gv_sortopt=DFR_panel:gv_sortopt
	
	DFREF DF_save=$DFS_cubesave
	
	SetDAtafolder DF_save
	String /G cubelist=WaveList("*",";","DIMS:3")
	SListToWave(cubelist,gv_sortopt,";",Nan,Nan)
	
	Wave /T w_StringList
	duplicate /o w_Stringlist DFR_panel:CubeName_list
	
	Killwaves /Z w_Stringlist
	
	redimension /n=(numpnts(CubeName_list)) CubeName_list_sel
	if (sum(CubeName_list_sel)==0)
		CubeName_list_sel[0]=1
	endif
	
	SetDatafolder DF
End


static function Cube_list_sel(ctrlName,row,col,event) : ListboxControl
	String ctrlName     // name of this control
	Variable row        // row if click in interior, -1 if click in title
	Variable col        // column number
	Variable event      // event code
	
	DFREF Df = getdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	
	Wave /T CubeName_list=DFR_panel:CubeName_list
	Wave /B CubeName_list_sel=DFR_panel:CubeName_list_sel
	
	SVAR  gs_currentCubeSource=DFR_panel:gs_currentCubeSource
	SVAR gs_currentCubeName=DFR_panel:gs_currentCubeName
	NVAR gv_Estart = DFR_panel:gv_Estart
	NVAR gv_Eend = DFR_panel:gv_Eend
	NVAR gv_deltaE = DFR_panel:gv_deltaE
	
	
	DFREF DFR_save=$DFS_cubesave
	
	if ((event==4)||(event==5))
		update_cube_list()
		variable index=0
		do 
			if (CubeName_list_sel[index]==1)
				gs_currentCubeName=CubeName_list[index]
				gs_currentCubeSource=DFS_cubesave+":"+gs_currentCubeName
	
				Wave cube=$gs_currentCubeSource
				
				Duplicate /o cube, DFR_panel:plotcube,DFR_panel:plotcubebackup
				
				Wave plotcube=DFR_panel:plotcube
				
				Mapper3D_dirangeupdate()
				
				gv_Estart = DimOffset(cube,2)
				
				gv_deltaE = Dimdelta(cube,2)
				
				gv_Eend = dimsize(cube, 2)*gv_deltaE+gv_Estart
				
	
				Initial_3DCuts(plotcube)
				
				if (strlen(Csrinfo(B,winname(0,65)))==0)
					ShowInfo;Cursor/P/I/H=1 B xyFSM 0,0// Cursor
				endif
		
				if (strlen(Csrinfo(A,winname(0,65)))==0)
					ShowInfo;Cursor/P/I/H=0 A xyFSM 10,10
				endif
				
				
				
				controlinfo global_ck2
				if (v_value)
					NVAR xvalue=DFR_panel:xvalue
					NVAR yvalue=DFR_panel:yvalue
					NVAR xAvalue=DFR_panel:xAvalue
					NVAR yAvalue=DFR_panel:yAvalue
					
					Wave plotcube=DFR_panel:plotcube
					
					variable tempXpos=x2pntsmult(plotcube,xvalue,0)
					variable tempYpos=x2pntsmult(plotcube,yvalue,1)
					variable tempXApos=x2pntsmult(plotcube,xAvalue,0)
					variable tempYApos=x2pntsmult(plotcube,yAvalue,1)
					Cursor/P/I/H=1 B xyFSM tempXpos,tempYpos
					Cursor/P/I/H=0 A xyFSM tempXApos,tempYApos
				else
					NVAR xpos=DFR_panel:xpos
					NVAR ypos=DFR_panel:ypos
					NVAR zpos=DFR_panel:zpos
					NVAR xApos=DFR_panel:xApos
					NVAR yApos=DFR_panel:yApos
					
					xpos=(xpos>(dimsize(plotcube,0)-1))?(dimsize(plotcube,0)-1):(xpos)
					ypos=(ypos>(dimsize(plotcube,1)-1))?(dimsize(plotcube,1)-1):(ypos)
					xApos=(xApos>(dimsize(plotcube,0)-1))?(dimsize(plotcube,0)-1):(xApos)
					yApos=(yApos>(dimsize(plotcube,1)-1))?(dimsize(plotcube,1)-1):(yApos)
					
					Cursor/P/I/H=1 B xyFSM xpos,ypos
					Cursor/P/I/H=0 A xyFSM xApos,yApos
				endif
		
				//update3Dlayers()
				
				
				break
			endif
			index+=1
		while (index<numpnts(CubeName_list_sel))
	endif
	
	SetDatafolder DF
	return 0            // other return values reserved
End


////////////gizmo color///////////////////

static Function proc_bt_histchange(ctrlname)
	string ctrlname
	DFREF Df = getdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	
	NVAR gv_GizmoCtabMax=DFR_panel:gv_GizmoCtabMax
	NVAR gv_GizmoCtabMin=DFR_panel:gv_GizmoCtabMin
	
	NVAR  gv_sliderleft=DFR_panel:gv_sliderleft
	NVAR gv_sliderright=DFR_panel:gv_sliderright
	
	if (stringmatch(ctrlname,"mapper3D_DefaultHist"))
		Wave xyFSM=DFR_panel:xyFSM
		Wave xzimage=DFR_panel:xzimage
		Wave yzimage=DFR_panel:yzimage
		Wave lineimage=DFR_panel:lineimage
		
		Variable minvalue1=min(my_wavemin(xyFSM),my_wavemin(xzimage))
		Variable minvalue2=min(my_wavemin(yzimage),my_wavemin(lineimage))
		gv_GizmoCtabMin=min(minvalue1,minvalue2)
		
		Variable maxvalue1=max(my_wavemax(xyFSM),my_wavemax(xzimage))
		Variable maxvalue2=max(my_wavemax(yzimage),my_wavemax(lineimage))
		gv_GizmoCtabMax=max(maxvalue1,maxvalue2)
		
		gv_sliderleft=0
		gv_sliderright=0
		
	else
		gv_GizmoCtabMax=Nan
		gv_GizmoCtabMin=Nan
		
		gv_sliderleft=0
		gv_sliderright=0
	endif
	
	update3Dlayers()
end

static Function Proc_IMGrange_change(name, value, event) : SliderControl
	String name	// name of this slider control
	Variable value	// value of slider
	Variable event	// bit field: bit 0: value set; 1: mouse down, 
					//   2: mouse up, 3: mouse moved
	DFREF Df = getdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)

				
	update3Dlayers()					
	return 0	// other return values reserved
End


static Function Proc_IMGrange_SVchange(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	update3Dlayers()
End

End

static Function mapper3D_ck_updatecolor(ctrlname,value)
	String ctrlname
	Variable value
	
	update3Dlayers()
End

static Function Proc_colortab_PopMenuProc (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	DFREF Df = getdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	
	NVAR gv_GizmoCtabnum=DFR_panel:gv_GizmoCtabnum
	SVAR gs_GizmoCtabname=DFR_panel:gs_GizmoCtabname
	
	gv_GizmoCtabnum=popNum-1
	
	gs_GizmoCtabname=Stringfromlist(gv_GizmoCtabnum,ctablist(),";")
	
	update3Dlayers()
	
End




static Function proc_ck_plotEline(ctrlname,value)
	String ctrlname
	Variable value
	DFREF Df = getdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	NVAR gv_Elineflag=DFR_panel:gv_Elineflag
	
	Wave Energyline_y=DFR_panel:Energyline_y
	Wave Energyline_x=DFR_panel:Energyline_x
	Wave Energyline1_y=DFR_panel:Energyline1_y
	Wave Energyline1_x=DFR_panel:Energyline1_x
	
	if (gv_Elineflag==0)
		removefromgraph /Z Energyline_y,Energyline1_y,Energyline_y#1
	else
		removefromgraph /Z Energyline_y,Energyline1_y
		appendtograph /W=$winname(0,65) /L=left /B=bottom Energyline_y vs Energyline_x
		appendtograph /W=$winname(0,65) /L=edc_en /T=edc_int Energyline1_y vs Energyline1_x
		appendtograph /W=$winname(0,65) /L=lineimage_e /B=lineimage_m Energyline_y vs Energyline_x
		ModifyGraph  /W=$winname(0,65) lstyle(Energyline_y)=3
		ModifyGraph  /W=$winname(0,65) lstyle(Energyline_y#1)=3
		ModifyGraph  /W=$winname(0,65) lstyle(Energyline1_y)=3
	endif
End



static Function map_AutoTab( name, tab )
	String name
	Variable tab
	
	DFREF DF=GetDatafolderDFR()
	
	String DFS_panel="root:internalUse:"+winname(0,65)
	DFREF DF_panel=$DFS_panel
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
	ModifyControlList controlsglobalcontrols disable=0	// show.
	
SetDatafolder DF
	
End

static Function mapper3D_SaveIM(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderDFR()
	String DFS_panel="root:internalUse:"+winname(0,65)
	SetActiveSubwindow $winname(0,65)	
	DFREF DFR_panel=$DFS_panel
	SetDatafolder DFR_panel
	Wave xzimage,yzimage,xyFSM
	
	String winame=winname(0,65)

	Wave /T CubeName_List=DFR_panel:CubeName_List
	Wave /B CubeName_list_Sel=DFR_panel:CubeName_list_Sel
	

	
	SVAR gs_currentCubeName=DFR_panel:gs_currentCubeName

	String gn
	
	Controlinfo mapper3D_ck1
	Variable saveflag=V_Value
	
	NVAR gv_gizmoflag=DFR_panel:gv_gizmoflag
	
	if ((gv_gizmoflag==0)&&(saveflag==1))
		Duplicate /FREE CubeName_list_Sel,Temp_sel
		CubeName_list_Sel=0
		Variable count=0
		Variable index=0
		do
			if ((Temp_sel[index]==1)||(Temp_sel[index]==8))
				CubeName_list_Sel[index]=1
				Cube_list_Sel("dummy",index,0,4)
				
				Strswitch(ctrlname)
					case "mapper3D_b0":
						String plotname="xzimage_"+gs_currentCubeName
						duplicate /o xzimage,$plotname
						InitialprocNotestr2D($plotname,"HCut")
						break
					case "mapper3D_b1":
						plotname="yzimage_"+gs_currentCubeName
						duplicate /o yzimage,$plotname
						//matrixtranspose $plotname
						InitialprocNotestr2D($plotname,"VCut")
						break
					case "mapper3D_b2":
						plotname="xyFSM_"+gs_currentCubeName
						duplicate /o xyFSM,$plotname
						InitialprocNotestr2D($plotname,"FSM")
						break
					case "mapper3D_b6":
						plotname="lineimage_"+gs_currentCubeName
						duplicate /o lineimage,$plotname
						InitialprocNotestr2D($plotname,"Lineimage")
						break
					endswitch
				
					Wave plotwave=$plotname
					if (count==0)
						gN=display_wave(plotwave,0,0)
						dowindow /F $winame
						count+=1
						if (stringmatch(ctrlname,"mapper3D_b2"))
							FSM_Style(gN,0)
						else
							image_Style(gN,0)
						endif
					else
						gN=display_wave(plotwave,2,0)
						count+=1
					endif
					
					
					
					Killwaves /Z plotwave
					CubeName_list_Sel=0
			endif
			
			index+=1
		while (index<numpnts(CubeName_list_Sel))
		
		CubeName_list_Sel=Temp_sel
		SetDatafolder DF
		return 0
	endif
	

	
	if (saveflag)
		Strswitch(ctrlname)
		case "mapper3D_b0":
			plotname="xzimage_"+gs_currentCubeName
			duplicate /o xzimage,$plotname
			InitialprocNotestr2D($plotname,"HCut")
		break
		case "mapper3D_b1":
			plotname="yzimage_"+gs_currentCubeName
			duplicate /o yzimage,$plotname
			InitialprocNotestr2D($plotname,"VCut")
		break
		case "mapper3D_b2":
			plotname="xyFSM_"+gs_currentCubeName
			duplicate /o xyFSM,$plotname
			InitialprocNotestr2D($plotname,"FSM")
		break
		case "mapper3D_b6":
			plotname="lineimage_"+gs_currentCubeName
			duplicate /o lineimage,$plotname
			InitialprocNotestr2D($plotname,"Lineimage")
		break
		endswitch
	else
		
		Strswitch(ctrlname)
		case "mapper3D_b0":
			Wave plotwave=xzimage
			break
		case "mapper3D_b1":
			Wave plotwave=yzimage
			break
		case "mapper3D_b2":
			Wave plotwave=xyFSM
			break
		case "mapper3D_b6":
			Wave plotwave= lineimage
			break
		endswitch	
	endif
	
	

	
	if (gv_gizmoflag==1) ///update 3D layer and color wave
		String winname3D=winame+"_gizmo"
	
		if (strlen(winlist(winname3D,";","Win:4096"))==0)
			String cmd="newGizmo /N="+winname3D
			Execute /Q/Z cmd
			cmd="modifyGizmo /N="+winname3D+" aspectRatio=1"
			Execute /Q/Z cmd
		endif
		
		update3Dlayers()
		
		Wave xyFSM3D,xzimage3D,yzimage3D,lineimage3D
		Wave xyFSM_color,xzimage_color,yzimage_color,lineimage_color
		
		if (saveflag)
		
			newDatafolder /o/s SaveGizmo
			
			String savename3D
			
			Strswitch(ctrlname)
			case "mapper3D_b0":
				savename3D=UniqueName("xzimage",1,0)
				duplicate  /o xzimage $(savename3D)
				duplicate /o xzimage3D $(savename3D+"3D")
				duplicate /o xzimage_color $(savename3D+"_color")
				UpdatePlotCubeslice(winname3D,savename3D,1)
				break
			case "mapper3D_b1":
				savename3D=UniqueName("yzimage",1,0)
				duplicate  /o yzimage $(savename3D)
				duplicate /o yzimage3D $(savename3D+"3D")
				duplicate /o yzimage_color $(savename3D+"_color")
				UpdatePlotCubeslice(winname3D,savename3D,1)
				break
			case "mapper3D_b2":
				savename3D=UniqueName("xyFSM",1,0)
				duplicate  /o xyFSM $(savename3D)
				duplicate /o xyFSM3D $(savename3D+"3D")
				duplicate /o xyFSM_color $(savename3D+"_color")
				UpdatePlotCubeslice(winname3D,savename3D,1)
				break
			case "mapper3D_b6":
				savename3D=UniqueName("lineimage",1,0)
				duplicate  /o lineimage $(savename3D)
				duplicate /o lineimage3D $(savename3D+"3D")
				duplicate /o lineimage_color $(savename3D+"_color")
				UpdatePlotCubeslice(winname3D,savename3D,1)
				break
			endswitch
			
		else
			NVAR gv_gizmoflag=DFR_panel:gv_gizmoflag
			gv_gizmoflag=1
			
			Strswitch(ctrlname)
			case "mapper3D_b0":
				UpdatePlotCubeslice(winname3D,"xzimage",1)
				break
			case "mapper3D_b1":
				UpdatePlotCubeslice(winname3D,"yzimage",1)
				break
			case "mapper3D_b2":
				UpdatePlotCubeslice(winname3D,"xyFSM",1)
				break
			case "mapper3D_b6":
				UpdatePlotCubeslice(winname3D,"lineimage",1)
				break
			endswitch
	
			cmd="ModifyGizmo /N="+winname3D+" update=2"
			Execute /Q/Z cmd
		endif
	else
			String basename=winname(0,65)
			Variable temp=strsearch(basename,"panel_",inf,1)
			
			plotname="Plot_"+basename[temp+5,inf]
			plotname=uniquename(plotname,6,0)
			display /W=(0,0,300,200) /N=$plotname  as plotname
			Appendimage /W=$plotname plotwave
			if (stringmatch(ctrlname,"mapper3D_b2"))
				FSM_Style(winname(0,1),0)
			else
				image_Style(winname(0,1),0)
			endif
			
			Attachtobottom(winname(1,65),plotname,3)
		//endif
	endif
	//autopositionwindow /E/M=1 /R=$winame $winname(0,1)
	SetDatafolder DF

End

Function Mapper3D_dirangeupdate()
	DFREF DF=GetDatafolderDFR()
	String DFS_panel="root:internalUse:"+winname(0,65)
	SetActivesubwindow $winname(0,65)
	DFREF DF_panel=$DFS_panel
	SetDatafolder DF_panel
	
	WAve plotcube
	Wave plotcubebackup
	
	NVAR dirflag=gv_dirflag
	NVAR curveflag=gv_curveflag
	NVAR cfactor=gv_cfactor
	NVAR smthpnts=gv_smthpnts
	NVAR smthtimes=gv_smthtimes
	NVAR rotateang=gv_rotateangle
	
		
	if (dirflag)
		mapper3D_angrot("dummy",rotateang,"","")
		M_smooth_times_fast(plotcube,2,smthpnts,smthtimes)
		Differentiate /Dim=2 plotcube
		Differentiate /Dim=2 plotcube
	elseif (curveflag)
		mapper3D_angrot("dummy",rotateang,"","")
		M_smooth_times_fast(plotcube,2,smthpnts,smthtimes)
		Duplicate /o/Free plotcube, plotcubeDiff1,plotcubeDiff2
		Differentiate/DIM = 2 plotcubeDiff1
		Differentiate/DIM = 2 plotcubeDiff1 /D=plotcubeDiff2
		Variable normI=abs(wavemin(plotcubeDiff1))
		Multithread plotcube=plotcubeDiff2/(CFactor*normI*normI+plotcubeDiff1*plotcubeDiff1)^1.5
	else
		mapper3D_angrot("dummy",rotateang,"","")
	endif
	
	SetDatafolder DF
	
End
Function mapper3D_Dirchange(ctrlname,value)
	String ctrlname
	Variable value	
	
	DFREF DF=GetDatafolderDFR()
	String DFS_panel="root:internalUse:"+winname(0,65)
	SetActivesubwindow $winname(0,65)
	DFREF DF_panel=$DFS_panel
	SetDatafolder DF_panel
	
	WAve plotcube
	Wave plotcubebackup
	
	NVAR dirflag=gv_dirflag
	NVAR curveflag=gv_curveflag
	NVAR cfactor=gv_cfactor
	NVAR smthpnts=gv_smthpnts
	NVAR smthtimes=gv_smthtimes
	NVAR rotateang=gv_rotateangle
	
	if (value==1)
		if (stringmatch(Ctrlname,"mapper3D_ck0"))
			dirflag=1
			curveflag=0
		else
			dirflag=0
			curveflag=1
		endif
	endif
	
	
	Mapper3D_dirangeupdate()
	
	Initial_3DCuts(plotcube)
	update3Dlayers()
	SetDatafolder DF
	
End

Function mapper3D_angrot(ctrlName,varNum,varStr,varName)
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	DFREF DF=GetDatafolderDFR()
	String DFS_panel="root:internalUse:"+winname(0,65)
	DFREF DF_panel=$DFS_panel
	SetDatafolder DF_panel
	NVAR rotateang=gv_rotateangle
	NVAR dirflag=gv_dirflag
	
	Wave plotcube
	Wave plotcubebackup
	duplicate /o plotcubebackup plotcube
	
	if (rotateang==0)
		SetDatafolder DF
		return 1
	endif
	
	if (sign(rotateang)==1)
		ImageRotate /A=(rotateang) /Q/O plotcube
	else
		ImageRotate /A=(360+rotateang) /Q/O  plotcube
	endif
	
	returnFSMrange(plotcubebackup,rotateang,1)
	Wave Rangewave
	Setscale /I x,Rangewave[0],Rangewave[1],plotcube
	Setscale /I y,Rangewave[2],Rangewave[3],plotcube
	Killwaves /Z rangewave
	
	SetDatafolder DF
End	

Function mapper3D_angchange(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	DFREF DF=GetDatafolderDFR()
	String DFS_panel="root:internalUse:"+winname(0,65)
	DFREF DF_panel=$DFS_panel
	SetDatafolder DF_panel
	NVAR rotateang=gv_rotateangle
	NVAR dirflag=gv_dirflag
	
	mapper3D_Dirchange("dummy",Nan)
	SetDatafolder DF
End	

Function mapper3D_smthchange(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	mapper3D_Dirchange("dummy",Nan)

End


Function mapper3D_auto_update()
	String DFS_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DFS_panel
	DFREF DF_load=$DF_global
	String wname=winname(0,65)
	Wave w_image=DFR_panel:xyFSM
	
	NVAR gv_autoFSMflag=DFR_panel:gv_autoFSMflag
	SVAR gs_autoFSM_panellist=DFR_panel:gs_autoFSM_panellist
		

		//NVAR gv_autoFSMflag=DFR_global:gv_autoFSMflag
		//SVAR gs_autoFSMpath=DFR_global:gs_autoFSMpath
   		if  (gv_autoFSMflag>0)
   			Variable panelindex=0
   			Variable panelnum=itemsinlist(gs_autoFSM_panellist,";")
   			Variable index=0
   			do
   				String BZname=stringfromlist(index,gs_autoFSM_panellist,";")
   				String DF_BZ="root:internaluse:"+BZname
   				if (Datafolderexists(DF_BZ)==0)
   					gs_autoFSM_panellist=RemoveFromList(BZname, gs_autoFSM_panellist, ";")
   				else
   					DFREF DFR_BZ=$DF_BZ	
   					SetDatafolder DFR_BZ
   					
   					
   					SVAR gs_autoFSMname=DFR_BZ:gs_autoFSMname
   					Variable temppos=WhichListItem(wname,gs_autoFSMname,";",0)
   					
   					String autoFSM_BZname="autoFSM_"+num2str(temppos)
	
					duplicate /o w_image $autoFSM_BZname
   					
   					Checkdisplayed /W=$BZname $autoFSM_BZname
	
					if (V_flag==0)
						appendimage  /W=$BZname  $autoFSM_BZname
					endif	
					
   					panelindex+=1
   				endif
   				
   				index+=1
   			while (index<panelnum)
   			
   			if (panelindex==0)
   				gv_autoFSMflag=0
   			endif
    		
   		endif
End	

Function mapper3D_Energychange(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	
	DFREF DF=GetDatafolderDFR()
	String DFS_panel="root:internalUse:"+winname(0,65)
	SetActivesubwindow $winname(0,65)
	DFREF DF_panel=$DFS_panel
	SetDatafolder DF_panel
	
	NVAR gv_Estart,gv_Eend,gv_plotEnergy
	
	if(gv_plotEnergy>max(gv_Estart,gv_Eend))
		gv_plotEnergy= max(gv_Estart,gv_Eend)
	endif
	
	if(gv_plotEnergy<min(gv_Estart,gv_Eend))
		gv_plotEnergy= min(gv_Estart,gv_Eend)
	
	endif
	
	update3Dlayers()
	
	mapper3D_auto_update()
	
End


Function mapper3D_sliderchange(name, value, event) : SliderControl
		String name	// name of this slider control
		Variable value	// value of slider
		Variable event
		
		update3Dlayers()
		
	 	mapper3D_auto_update()
End



Function update3Dlayers()

	DFREF DF=GetDatafolderDFR()
	String DFS_panel="root:internalUse:"+winname(0,65)
	SetActivesubwindow $winname(0,65)
	DFREF DF_panel=$DFS_panel
	SetDatafolder DF_panel
	NVAR xpos,ypos,zpos
	NVAR xApos,yApos
	WAve plotcube
	
	
	Wave xyFSM,xzimage,yzimage,lineimage
	Wave xyFSM_cw,xzimage_cw,yzimage_cw
	NVAR dirflag=gv_dirflag
	NVAR smthpnts=gv_smthpnts
	NVAR smthtimes=gv_smthtimes
	NVAR plotEnergy=gv_plotEnergy
	
	NVAR Gizmogamma=gs_GizmoCtabgamma
	
	Wave Energyline_y=DF_panel:Energyline_y
	Wave Energyline_x=DF_panel:Energyline_x
	Wave Energyline1_y=DF_panel:Energyline1_y
	Wave Energyline1_x=DF_panel:Energyline1_x
	Wave lineprofile_x=DF_panel:lineprofile_x
	Wave lineprofile_y=DF_panel:lineprofile_y
	
	lineprofile_x[0]=DimOffset(plotcube,0)+dimdelta(plotcube,0)*xpos
	lineprofile_x[1]=DimOffset(plotcube,0)+dimdelta(plotcube,0)*xApos
	lineprofile_y[0]=DimOffset(plotcube,1)+dimdelta(plotcube,1)*ypos
	lineprofile_y[1]=DimOffset(plotcube,1)+dimdelta(plotcube,1)*yApos
	
	Energyline_y=plotEnergy
	Energyline1_x=plotEnergy
	
	zpos=x2pntsmult(plotcube,plotEnergy,2)
	if (zpos<0)
		zpos=0
		plotEnergy=dimoffset(plotcube,2)
	endif
	
	if (zpos>dimsize(plotcube,2))
		zpos=dimsize(plotcube,2)
		plotEnergy=dimoffset(plotcube,2)+dimdelta(plotcube,2)*(dimsize(plotcube,2)-1)
	endif
	
	ypos=(ypos<(dimsize(plotcube,1)))?(ypos):(dimsize(plotcube,1))
	xpos=(xpos<(dimsize(plotcube,0)))?(xpos):(dimsize(plotcube,0))

	imagelineprofile /P=-2 /S xWave=lineprofile_x,yWave=lineprofile_y,srcwave=plotcube,width=0//dimsize(plotcube,2)
	Wave M_ImageLineProfile
	
	Variable linek1=sqrt((lineprofile_x[1]-lineprofile_x[0])^2+(lineprofile_y[1]-lineprofile_y[0])^2)
	Setscale /I x,0, linek1,M_ImageLineProfile
	Setscale /P y,dimoffset(plotcube,2),dimdelta(plotcube,2),M_ImageLineProfile
	Duplicate /o M_imagelineprofile lineimage
	

	imagetransform /PTYP=0 /P=(zpos) getPlane plotcube
	Wave M_imageplane
	duplicate /o M_imageplane xyFSM
	//xyFSM=M_ImagePlane
	
	imagetransform /PTYP=1 /P=(ypos) getPlane plotcube
	duplicate /o M_imageplane xzimage
	//xzimage=M_ImagePlane
	
	imagetransform /PTYP=2 /P=(xpos) getPlane plotcube
	duplicate /o M_imageplane yzimage
	
	//yzimage=M_ImagePlane
	
	Adjustdisplayratio(3)
	
	killwaves /Z M_ImagePlane
	
	SVAR gs_gizmodispstr=DF_panel:gs_gizmodispstr
	
	Crop_3D_layers(xyFSM,xzimage,yzimage,lineimage,gs_gizmodispstr,xpos,ypos,zpos,xApos,yApos)
	
	NVAR gv_gizmoflag=DF_panel:gv_gizmoflag
	
	if (gv_gizmoflag==1) ///update 3D layer and color wave
		NVAR Energyratio=gv_gizmoEnergyration
		
		Make /o/n=(dimsize(xyFSM,0),dimsizE(xyFSM,1),3) xyFSM3D
		copyscales xyFSM,xyFSM3D
		xyFSM3D[][][0]=x
		xyFSM3D[][][1]=y
		xyFSM3D[][][2]=plotEnergy*Energyratio
		
		xyFSM3D[][][]=(numtype(xyFSM[p][q])==2)?(Nan):(xyFSM3D)
		
		Make /o/n=(dimsize(xzimage,0),dimsizE(xzimage,1),3) xzimage3D
		copyscales xzimage,xzimage3D
		Variable yvalue=M_y0(plotcube)+ypos*dimdelta(plotcube,1)
		xzimage3D[][][0]=x
		xzimage3D[][][1]=yvalue
		xzimage3D[][][2]=y*Energyratio
		
		xzimage3D[][][]=(numtype(xzimage[p][q])==2)?(Nan):(xzimage3D)
		
		Make /o/n=(dimsize(yzimage,0),dimsizE(yzimage,1),3) yzimage3D
		copyscales yzimage,yzimage3D
		Variable xvalue=M_x0(plotcube)+xpos*dimdelta(plotcube,0)
		yzimage3D[][][0]=xvalue
		yzimage3D[][][1]=x
		yzimage3D[][][2]=y*Energyratio
	
		yzimage3D[][][]=(numtype(yzimage[p][q])==2)?(Nan):(yzimage3D)
		
		Make /o/n=(dimsize(lineimage,0),dimsizE(lineimage,1),3) lineimage3D
		copyscales lineimage,lineimage3D
		
		lineimage3D[][][0]=Lineprofile_x[0]+p*(Lineprofile_x[1]-Lineprofile_x[0])/(dimsize(lineimage,0)-1)//W_lineProfileX[p]
		lineimage3D[][][1]=Lineprofile_y[0]+p*(Lineprofile_y[1]-Lineprofile_y[0])/(dimsize(lineimage,0)-1)//W_lineProfileY[p]
		lineimage3D[][][2]=y*Energyratio
		
		lineimage3D[][][]=(numtype(lineimage[p][q])==2)?(Nan):(lineimage3D)
		
		update_3D_Layers_color()
		
	Endif
	
	Duplicate /o yzimage,yzimage_rot
	Matrixtranspose yzimage_rot

	
	Doupdate;
	SetDatafolder DF
End	





static Function update_3D_Layers_color()
	DFREF DF=GetDatafolderDFR()
	String DFS_panel="root:internalUse:"+winname(0,65)
	SetActivesubwindow $winname(0,65)
	DFREF DFR_panel=$DFS_panel
	SetDatafolder DFR_panel
	
	Wave xyFSM,yzimage,xzimage
	
	SVAR gs_GizmoCtabname=DFR_panel:gs_GizmoCtabname
	NVAR gv_GizmoCtabInverse=DFR_panel:gv_GizmoCtabInverse
	NVAR gv_GizmoCtabMax=DFR_panel:gv_GizmoCtabMax
	NVAR gv_GizmoCtabMin=DFR_panel:gv_GizmoCtabMin
	
	NVAR gv_GizmoCtabgamma=DFR_panel:gv_GizmoCtabgamma
	NVAR gv_sliderleft=DFR_panel:gv_sliderleft
	NVAR gv_sliderright=DFR_panel:gv_sliderright
	NVAR gv_GizmoCtabnum=DFR_panel:gv_GizmoCtabnum
	
	controlinfo 	mapper3D_ck16
	Variable glolbalflag=v_Value
	controlinfo 	mapper3D_ck18
	Variable allflag=v_Value
	
	if (glolbalflag==0)
		String imageinfostring=Imageinfo(winname(0,65),"xyFSM",0)
		Variable temppos0=strsearch(imageinfostring,"ctab=",0)
		Variable temppos1=strsearch(imageinfostring,"}",temppos0)
		String colortabstr=imageinfostring[temppos0,temppos1]
		
		Cal_colorwave_from_Image(xyFSM,Colortabstr,1,gv_GizmoCtabgamma,4)
		
		imageinfostring=Imageinfo(winname(0,65),"xzimage",0)
		temppos0=strsearch(imageinfostring,"ctab=",0)
		temppos1=strsearch(imageinfostring,"}",temppos0)
		colortabstr=imageinfostring[temppos0,temppos1]
		
		Cal_colorwave_from_Image(xzimage,Colortabstr,1,gv_GizmoCtabgamma,4)
		
		imageinfostring=Imageinfo(winname(0,65),"yzimage_rot",0)
		temppos0=strsearch(imageinfostring,"ctab=",0)
		temppos1=strsearch(imageinfostring,"}",temppos0)
		colortabstr=imageinfostring[temppos0,temppos1]

		Cal_colorwave_from_Image(yzimage,Colortabstr,1,gv_GizmoCtabgamma,4)
		
		imageinfostring=Imageinfo(winname(0,65),"lineimage",0)
		temppos0=strsearch(imageinfostring,"ctab=",0)
		temppos1=strsearch(imageinfostring,"}",temppos0)
		colortabstr=imageinfostring[temppos0,temppos1]
		
		Cal_colorwave_from_Image(lineimage,Colortabstr,1,gv_GizmoCtabgamma,4)
		
	else
		colortabstr="ctab= {"
	
		if (numtype(gv_GizmoCtabMin)==2)
			Variable minvalue1=min(my_wavemin(xyFSM),my_wavemin(xzimage))
			Variable minvalue2=min(my_wavemin(yzimage),my_wavemin(lineimage))
			Variable mincolorvalue=min(minvalue1,minvalue2)
			colortabstr+=num2str(mincolorvalue)+","
		else
			colortabstr+=num2str(gv_GizmoCtabMin*(1+gv_sliderleft))+","
		endif
		
		if (numtype(gv_GizmoCtabMax)==2)
			Variable maxvalue1=max(my_wavemax(xyFSM),my_wavemax(xzimage))
			Variable maxvalue2=max(my_wavemax(yzimage),my_wavemax(lineimage))
			Variable maxcolorvalue=max(maxvalue1,maxvalue2)
			colortabstr+=num2str(maxcolorvalue)+","
		else
			colortabstr+=num2str(gv_GizmoCtabMax*(1+gv_sliderright))+","
		endif
		
		colortabstr+=gs_GizmoCtabname+","
		
		colortabstr+=num2str(gv_GizmoCtabInverse)+"}"
		
		Cal_colorwave_from_Image(xyFSM,Colortabstr,1,gv_GizmoCtabgamma,4)
		Cal_colorwave_from_Image(xzimage,Colortabstr,1,gv_GizmoCtabgamma,4)
		Cal_colorwave_from_Image(yzimage,Colortabstr,1,gv_GizmoCtabgamma,4)
		Cal_colorwave_from_Image(lineimage,Colortabstr,1,gv_GizmoCtabgamma,4)
		
		if (allflag)
			SetDatafolder SaveGizmo
			Variable index=0
			String list3d=WaveList("*",";","DIMS:2")
			do
				String planename=stringfromlist(index,list3d,";")
				if (strlen(planename)==0)
					break
				endif
				Wave plane=$planename
				Cal_colorwave_from_Image(plane,Colortabstr,1,gv_GizmoCtabgamma,4)
				index+=1
			while (1)
		
		endif
	endif
		
	String winame=winname(0,65)
	String winname3D=winame+"_gizmo"
	
	if (strlen(winlist(winname3D,";","Win:4096"))>0)
		String cmd="ModifyGizmo /N="+winname3D+" update=2"
		Execute /Q/Z cmd
	endif
		
	SetDatafolder DF
End

static Function Crop_3D_layers(xyFSM,xzimage,yzimage,lineimage,dispstr,xpos,ypos,zpos,Axpos,Aypos)
	Wave xyFSM,xzimage,yzimage,lineimage
	String dispstr
	Variable xpos,ypos,zpos
	Variable Axpos,Aypos
	
	if (stringmatch(dispstr[9],"0"))// crop down part
		duplicate /o/Free/R=[][zpos-1,inf] xzimage xzimage_temp
		duplicate /o/Free/R=[][zpos-1,inf] yzimage yzimage_temp
		duplicate /o/Free/R=[][zpos-1,inf] lineimage lineimage_temp

		duplicate /o xzimage_temp,xzimage
		duplicate /o yzimage_temp,yzimage
		duplicate /o lineimage_temp,lineimage
		
	elseif (stringmatch(dispstr[8],"0"))// crop upper part
		duplicate /o/Free/R=[][0,zpos] xzimage xzimage_temp
		duplicate /o/Free/R=[][0,zpos] yzimage yzimage_temp
		duplicate /o/Free/R=[][0,zpos] lineimage lineimage_temp
		
		duplicate /o xzimage_temp,xzimage
		duplicate /o yzimage_temp,yzimage
		duplicate /o lineimage_temp,lineimage

	endif
		
	
	if (stringmatch(dispstr[1],"0"))// crop up line
		duplicate /o/Free/R=[0,ypos][] yzimage yzimage_temp
		duplicate /o yzimage_temp,yzimage
	elseif (stringmatch(dispstr[6],"0")) // crop down line
		duplicate /o/Free/R=[ypos,inf][] yzimage yzimage_temp
		duplicate /o yzimage_temp,yzimage
	endif
	
	if (stringmatch(dispstr[3],"0"))// crop left line
		duplicate /o/Free/R=[xpos,inf][] xzimage xzimage_temp
		duplicate /o xzimage_temp,xzimage
	elseif (stringmatch(dispstr[4],"0")) // crop right line
		duplicate /o/Free/R=[0,xpos][] xzimage xzimage_temp
		duplicate /o xzimage_temp,xzimage
	endif
	
	if (stringmatch(dispstr[0],"0"))
		xyFSM[0,xpos-1][ypos+1,inf]=Nan
	endif
	if (stringmatch(dispstr[2],"0"))
		xyFSM[xpos+1,inf][ypos+1,inf]=Nan
	endif
	if (stringmatch(dispstr[5],"0"))
		xyFSM[0,xpos-1][0,ypos-1]=Nan
	endif
	if (stringmatch(dispstr[7],"0"))
		xyFSM[xpos+1,inf][0,ypos-1]=Nan
	endif
	
	
	variable Linetheta=atan2((Aypos-ypos),(Axpos-xpos))//returnlinetheta((Aypos-ypos),(Axpos-xpos))
	if ((Aypos-ypos)>0)
		if ((Axpos-xpos)>0)
			variable linethetaf=0
			variable linethetat=pi/2
		else
			linethetaf=pi/2
			linethetat=pi
		endif
	else
		if ((Axpos-xpos)>0)
			linethetaf=-pi/2
			linethetat=0
		else
			linethetaf=-pi
			linethetat=-pi/2
		endif
	endif

	
	if (stringmatch(dispstr[10],"0"))
		Linetheta-=0.03
		xyFSM=(((atan2((q-ypos),(p-xpos))>linethetaf)&&(atan2((q-ypos),(p-xpos))<Linetheta)))?(Nan):(xyFSM)
	elseif  (stringmatch(dispstr[11],"0"))
		Linetheta+=0.03
		xyFSM=(((atan2((q-ypos),(p-xpos))>linetheta)&&(atan2((q-ypos),(p-xpos))<Linethetat)))?(Nan):(xyFSM)
	endif
	
End



static Function UpdatePlotCubeslice(GizmoName,surfaceBaseName,initialflag)
	String GizmoName
	String surfaceBaseName
	Variable initialflag
	
	String cmd
	String surfacename=surfaceBaseName+"3D"
	String surfacecolor=surfaceBaseName+"_color"
	
	if (initialflag)
		sprintf cmd,"AppendtoGizmo /D/N=%s Surface=%s,name=%s",GizmoName,surfaceName,surfaceName
		Execute cmd
	
		sprintf cmd,"ModifyGizmo ModifyObject=%s property={ srcMode,%d}",surfaceName,4
		Execute cmd
	
		sprintf cmd,"ModifyGizmo modifyObject=%s property={surfaceColorType,3}",surfaceName
		Execute cmd
	
		sprintf cmd,"ModifyGizmo modifyObject=%s property={surfaceColorWave,%s}",surfaceName,surfacecolor
		Execute cmd
		
		sprintf cmd,"ModifyGizmo modifyObject=%s property={calcNormals,1}",surfaceName
		Execute cmd
	
	endif
		
	//sprintf cmd, "ModifyGizmo /N=%s ModifyObject=%s, property={plane,%d}",GizmoName,surfaceName,slicenum
	//Execute cmd
	
End






Function mapper3D_updatedispstr(ctrlname,value)
	String ctrlname
	Variable value
	DFREF DF=GetDatafolderDFR()
	String DFS_panel="root:internalUse:"+winname(0,65)
	SetActivesubwindow $winname(0,65)
	DFREF DF_panel=$DFS_panel
	SetDatafolder DF_panel
	
	SVAR gs_gizmodispstr
	
	gs_gizmodispstr=""
	
	Variable index=0
	do 
		controlinfo $("mapper3D_ck"+num2str(4+index))
		if (v_Value)
			gs_gizmodispstr+="1"
		else
			gs_gizmodispstr+="0"
		endif
		index+=1
	while (index< 12)
	
	update3Dlayers()
	
	SetDatafolder DF
End





///////////////Manual Cut////////////////////////////

static Function proc_bt_CreatManualPoint_Interp(ctrlname)
	String ctrlname
	DFREF Df = getdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	SetDatafolder DFR_panel

	Wave /T CubeName_List=DFR_panel:CubeName_List
	Wave /B CubeName_list_Sel=DFR_panel:CubeName_list_Sel

	String gn
	String winame=winname(0,65)

	Duplicate /FREE CubeName_list_Sel,Temp_sel
	CubeName_list_Sel=0
	Variable count=0
	Variable index=0
	do
		if ((Temp_sel[index]==1)||(Temp_sel[index]==8))
			CubeName_list_Sel[index]=1
			Cube_list_Sel("dummy",index,0,4)
				
			String plotname=CreatManualPoint_Interp()
				
			Wave plotwave=DFR_panel:$plotname
			if (count==0)
				gN=display_wave(plotwave,0,0)
				dowindow /F $winame
				count+=1
			else
				gN=display_wave(plotwave,2,0)
				count+=1
			endif
					
			Killwaves /Z plotwave
			CubeName_list_Sel=0
		endif
			
		index+=1
	while (index<numpnts(CubeName_list_Sel))
		
	CubeName_list_Sel=Temp_sel
	SetDatafolder DF
	return 0

End


static Function /S CreatManualPoint_Interp()

	DFREF Df = getdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_global=$DF_Global
	
	Wave ManualCuts_Y=DFR_panel:ManualCuts_Y
	Wave ManualCuts_X=DFR_panel:ManualCuts_X
	Wave plotcube=DFR_panel:plotcube
	
	SetDatafolder DFR_panel
	Variable dx=dimdelta(plotcube,0)
	Variable dy=dimdelta(plotcube,1)
	Variable dk=max(dx,dy)
	
	make /o/n=1,InterpCuts_Y,InterpCuts_X
	
	Variable CP,pn,CY,CX,xn,yn,xn1,yn1
		
	variable index=0,pindex=0
	do
		CY=(ManualCuts_Y[index+1]-ManualCuts_Y[index])
		CX=(ManualCuts_X[index+1]-ManualCuts_X[index])
		CP=sqrt(CY^2+CX^2)
		pn=round(CP/dk)+1
		insertpoints inf,pn,InterpCuts_Y,InterpCuts_X
		if (pn==1)
			InterpCuts_Y[pindex,pindex+pn-1]=ManualCuts_Y[index+1]
			InterpCuts_X[pindex,pindex+pn-1]=ManualCuts_X[index+1]
		else
			InterpCuts_Y[pindex,pindex+pn-1]=(p-pindex)*CY/(pn-1)+ManualCuts_Y[index]
			InterpCuts_X[pindex,pindex+pn-1]=(p-pindex)*CX/(pn-1)+ManualCuts_X[index]
		endif
		pindex+=pn
	index+=1
	while (index<(numpnts(ManualCuts_Y)-1))
	deletepoints pindex,1,InterpCuts_Y,InterpCuts_X
	imagelineprofile /P=-2 /V xWave=InterpCuts_X,yWave=InterpCuts_Y,srcwave=plotcube,width=0//dimsize(plotcube,2)
	Wave M_ImageLineProfile
	Setscale /P x,0,dk,M_ImageLineProfile
	Setscale /P y,dimoffset(plotcube,2),dimdelta(plotcube,2),M_ImageLineProfile
	
	SVAR basename=DFR_panel:gs_currentcubename
	
	Duplicate /o M_ImageLineProfile, $("Line_"+basename)
	
	//display_wave(M_ImageLineProfile,0,1)
	Killwaves /Z M_ImageLineProfile
	
	SetDatafolder DF
	
	return "Line_"+basename
end


static Function proc_bt_DefaultManualPoint(ctrlname)
	String ctrlname
	DFREF Df = getdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	DFREF DFR_global=$DF_Global
	
	NVAR gv_uca=DFR_global:gv_uca
	NVAR gv_ucb=DFR_global:gv_ucb
	NVAR gv_ucc=DFR_global:gv_ucc
	
	NVAR gV_BZazi=DFR_global:gV_BZazi
	
	NVAR gv_P1_x=DFR_panel:gv_P1_x
	NVAR gv_P1_y=DFR_panel:gv_P1_y
	
	strswitch(ctrlname)
	case "ManualCut_bt3": //gamma
		gv_P1_x=0
		gv_P1_y=0
	break
	case "ManualCut_bt4": //M
		gv_P1_x=sqrt((pi/gv_uca)^2+(pi/gv_ucb)^2)*cos(pi/180*(gv_BZazi-45))
		gv_P1_y=sqrt((pi/gv_uca)^2+(pi/gv_ucb)^2)*sin(pi/180*(gv_BZazi-45))
	break
	case "ManualCut_bt5": //X
		gv_P1_x=(pi/gv_uca)*cos(pi/180*(gv_BZazi))
		gv_P1_y=(pi/gv_uca)*sin(pi/180*(gv_BZazi))
	break
	endswitch
	
	//proc_bt_AddManualPoint("dummy")
	 
End
static Function update_ManualCut()
	DFREF Df = getdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	removefromgraph /Z ManualCuts_Y
	Wave /T ManualCuts=DFR_panel:ManualCuts
	if (numpnts(ManualCuts)==0)
		return 0
	endif
	
	SetDAtafolder DFR_panel
	make /o/n=(numpnts(ManualCuts)) ManualCuts_Y,ManualCuts_X
	Variable index=0
	String tempstr
	Variable X,Y
	do
		sscanf ManualCuts[index],"(%g,%g)",X,Y
		ManualCuts_X[index]=X
		ManualCuts_Y[index]=Y
		index+=1
	while (index<numpnts(ManualCuts))
	
	Appendtograph /L=image_en /B=image_m ManualCuts_Y vs ManualCuts_X
	ModifyGraph mode(ManualCuts_Y)=4,marker(ManualCuts_Y)=8
	SetDatafolder DF
End

static Function proc_bt_AddManualPoint(ctrlname)
	String ctrlname
	DFREF Df = getdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	NVAR gv_P1_x=DFR_panel:gv_P1_x
	NVAR gv_P1_y=DFR_panel:gv_P1_y
	Wave /T ManualCuts=DFR_panel:ManualCuts
	redimension /n=(numpnts(ManualCuts)+1),ManualCuts
	String tempstr
	sprintf tempstr,"(%g,%g)",gv_P1_x,gv_P1_y
	ManualCuts[inf]=tempstr
	update_ManualCut()
End

static Function proc_bt_RemoveManualPoint(ctrlname)
String ctrlname
	DFREF Df = getdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	//NVAR gv_P1_x=DFR_panel:gv_P1_x
	//NVAR gv_P1_y=DFR_panel:gv_P1_y
	Wave /T ManualCuts=DFR_panel:ManualCuts
	
	if (stringmatch(ctrlname,"ManualCut_bt2"))
	redimension /n=0 ManualCuts
	else
	Controlinfo ManualCut_lb0
	Deletepoints V_Value,1,ManualCuts
	endif
	update_ManualCut()
End

static Function proc_bt_ReadCsrManualPoint(ctrlname)
String ctrlname
	DFREF Df = getdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	NVAR gv_P1_x=DFR_panel:gv_P1_x
	NVAR gv_P1_y=DFR_panel:gv_P1_y
		
	Variable X=xcsr(B,winname(0,65))
	Variable y=vcsr(B,winname(0,65))
	
	 gv_P1_x=x
	 gv_P1_y=y
	 
	proc_bt_AddManualPoint("dummy")
end

static function mapper3D_plotinBZ(ctrlname)
	String ctrlname
	DFREF Df = getdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	
	
	String wname=winname(0,65)
	
	NVAR gv_autoFSMflag=DFR_panel:gv_autoFSMflag
	SVAR gs_autoFSM_panellist=DFR_panel:gs_autoFSM_panellist
	
	Wave w_image=DFR_panel:xyFSM
	
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
	
	
	Checkdisplayed /W=$BZpanelname autoFSM
	
	if (V_flag==0)
		appendimage   /W=$BZpanelname  $autoFSM_BZname
	endif
	
	
end


static Function plotcubesum(ctrlname)
	String ctrlname
	DFREF Df = getdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	
	//string wname=winname(0,65)
	
	SVAR Cubename=DFR_panel:gs_currentCubeName
	
	Variable temppos=strsearch(Cubename,"Cube_",0)
	
	String basename="FSM_sum_"+Cubename[temppos+5,inf]
	
	NVAR xpos=DFR_panel:xpos
	NVAR ypos=DFR_panel:ypos
	NVAR xApos=DFR_panel:xApos
	NVAR yApos=DFR_panel:yApos
	
	Wave plotcube=DFR_panel:plotcube
	
	Make /o/n=(dimsize(plotcube,2)) $basename
	Setscale /P x, (M_z0(plotcube)),(dimdelta(plotcube,2)),$basename
	
	Wave tempresult=$basename
	
	Variable index=0
	do
	
		Duplicate /o/Free /R=[xpos,xApos][ypos,yApos][index] plotcube tempwave
		WaveStats /Q tempwave
		tempresult[index]=V_avg
		index+=1
	while (index<dimsize(plotcube,2))
	
	display_wave(tempresult,0,0)
	Killwaves /Z tempresult
	
End





Function GP_JoinCube()
	DFREF DF=GetDatafolderDFR()

	String Wname=winname(0,1)
	String Imagename="",Tlist=ImageNamelist(Wname,";")
	//Tlist=SortList(Tlist,";",16)
	Variable items=itemsInlist(Tlist,";")

	Variable z0,z1,zscaleflag,directionflag
	z0=0
	z1=1
	zscaleflag=1
	directionflag=1
	prompt z0,"z0"
	prompt z1,"z1"
	prompt zscaleflag,"Set Z scale",popup,"Start_Interval;Start_End;"
	prompt directionflag,"Cubedirection",popup,"E;M;"
	Doprompt "Set cube parameters",z0,z1,zscaleflag,directionflag
	
	if (V_flag==1)
		Return 0
	endif
	
	Make /o/n=(items) w_x0,w_x1,w_dx,w_y0,w_y1,w_dy
	
	
	
	Variable index=0
	do
		String WaveN=Stringfromlist(index,Tlist,";")//GetBrowserSelection(index)
		if (strlen(WaveN)==0)
			break
		endif
		
		Wave Point=ImageNameToWaveRef(wname,WaveN) //$WaveN
		
		w_x0[index]=M_x0(Point)
		w_x1[index]=M_x1(Point)
		w_dx[index]=dimdelta(Point,0)
		w_y0[index]=M_y0(Point)
		w_y1[index]=M_y1(Point)
		w_dy[index]=dimdelta(Point,1)
		
		index+=1 
	while (1)
	
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
		nx=dimsize(Point,0)
		ny=dimsize(point,1)
		
	else
		Doalert /T="joinmultwave" 1,"Unequal range, Interp?"
		if (V_flag==2)
			SetDatafolder DF
			return 0
		endif
		
		nx=round((x1-x0)/dx)+1
		ny=round((y1-y0)/dy)+1
	
	endif

 	if (directionflag==1)
		make /o/n=(nx,ny,items) cubetemp
		Setscale /P x,x0,dx,cubetemp
		Setscale /P y,y0,dy,cubetemp
		if (zscaleflag==1)
			Setscale /P z,z0,z1,cubetemp
		else
			Setscale /I z,z0,z1,cubetemp
		endif
	else
		make /o/n=(nx,items,ny) cubetemp
		Setscale /P x,x0,dx,cubetemp
		Setscale /P z,y0,dy,cubetemp
		if (zscaleflag==1)
			Setscale /P y,z0,z1,cubetemp
		else
			Setscale /I y,z0,z1,cubetemp
		endif
	endif		
		
 		
	index=0
	
	do

		WaveN=Stringfromlist(index,Tlist,";")//GetBrowserSelection(index)
		if (strlen(WaveN)==0)
			break
		endif

 		Wave Point=ImageNameToWaveRef(wname,WaveN) //$WaveN
		
		if (directionflag==1)
			if (interpflag)
				cubetemp[][][index]=interp2D(point,x,y)
			else
				cubetemp[][][index]=point[p][q]
			endif
		else
			if (interpflag)
				cubetemp[][index][]=interp2D(point,x,z)
			else
				cubetemp[][index][]=point[p][r]
			endif
		endif
		
	index+=1
	while (1)
	
	DFREF DF_save=$DFS_cubesave
	
	String savename=wname
	prompt savename,"Input cube name"
	doprompt "Input cubename",savename
	
	if (V_flag)
		SetDatafolder DF
		return 0
	endif
	
	Duplicate /o Cubetemp,DF_save:$savename
	
	Killwaves /Z Cubetemp,w_x0,w_x1,w_dx,w_y0,w_y1,w_dy

	SetDatafolder DF
End













