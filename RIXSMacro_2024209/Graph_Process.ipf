#pragma rtGlobals=1		// Use modern global access method.
#pragma Version=0.01	

override StrConstant DF_GP="root:internalUse:GP_Macro:"

Menu "GP Macros"
	Initialize_GP_Macro()
	//"Duplicate Window"
	//"Display Waveset...",Display;AppendWaveset()
	//"Append Waveset..."
	"Show Graph Proc Tools/5",GP_Tools("")
	Submenu "Draw Tools<B"
		//"Replace Waves..."
		//"-"
		"Edit mode",GraphWaveEdit
		"Normal mode",GraphNormal
		"-"
		"Draw New Wave",GraphWaveDraw
		"Draw Freehand Wave",GraphWaveDraw/F=3
	End
	Submenu "Graph Tools Shortcut<B"
		"Display Waves/9",EasyAppend(1)
		"Append Waves/0",EasyAppend(0)
		"Different Colors/1",GP_DifferentColors()
		"Legend Name/2",GP_LegendName()
	//	"Add Tags/3",GP_AddTags()
		"Draw Zero Line/3",GP_DrawZeroLine()
		"-"
		"Undo Analysis",GP_UndoAnalysis()
		"-"
		"Open data table/8",GP_opendatatable()
		"-"
		"Seperate Append/4",/q, GP_SepAppend()
		"Import graph",/q,GP_ImportGraph()
		"Append graph",/q,GP_AppendGraph()
		//"Save Graph Waves/6",GP_SaveGraphWaves()
		//"Save to Process/7",GP_SaveGraphWaves_toprocess()
		"Save To Quick Style/6",GP_SavetoQuickStyle()
		"Quick Style/7",GP_quickStyle()
		"-"
		"Standard Style/OF2",GP_StandardStyle()
		//"Save Graph/8",GP_saveGraph()
	End
	submenu "GP Panel Shortcut<B"
		"Offset Trace/F2",GP_OffsetTraces()
		"Add Tags/F3",GP_AddTags()
		"Color Markers Lines/F4",GP_ColorMarkersLines()
		"-"
		"Image Process/F9",GP_ImageProcess()
		"Hair Cursor/F10",CrosslineCursorPanel()
		"Graph Browser/F11",GP_NewGraphBrowser()
		
	end
End


Function GP_newgraphBrowser()
	DoWindow/F GraphBrowserPanel
	if( V_Flag )
		return 0
	endif
	
	WM_GrfBrowser#NewGraphBrowserPanel("GraphBrowserPanel",0,0)
	WM_GrfBrowser#UpdateGraphList("GraphBrowserPanel")
End
//
//	Initialization
//
Function/S Initialize_GP_Macro()
	//variable p0, k
	//string cf=GetDataFolder(1),f="Load_FG_General;", pw
	DFREF DF=GetDatafolderDFR()
	
	NewDataFolder/O/S root:InternalUse:GP_Macro
	DFREF DFR_gp=$"root:InternalUse:GP_Macro"
	
	String /G Tracemenu="Normalize Area;Normalize Height;Const Background;-;Peak Area;Wave Max;Mean Value;-;Find Level;Find Peak;Find Maximum;Find Center;-;"
	Tracemenu+="Fermi Function;Convolve Guass;Sym EDC;Crop DCs;Shift Xoffset;Shift Yoffset;SubBackground;Smoothpnts;Derivative;FlipY;-;Undo Analysis;-;Reverse order;Join Slices;-;Sep Append;"
	String /G Imagemenu="Image Process;Convert Image Process;Create ROI;Join Cube;Analyze No Linearity;-;Imagestats;ImageHistogram;ImageFilter;RemoveBkg;-;2D Bkg From ROI;Cal Bkg From Min;"
	String /G Graphmenu="Draw Zero Line;Show Label;Reverse axis;Autoticks;-;Different Colors;Legend Name;Add Tags;-;Offset Traces;Color Markers Lines;Standard Style;-;Save to QuickStyle;Quick Style;"
	String /G processmenu="Open datatable;Open Movie;Save Graph txt;Save Graph Waves;Save As ProcWaves;-;Import Graph;Append Graph;-;Release GraphHook;Apply GraphHook;Seperate Graph;-;Make Waveset;WaveSet Command;-;Edit mode;Normal mode;Draw New Wave;Draw Freehand Wave;"
	
	Make /O Color_New10={{65535,13106,0,59604,52428,0,51655,53173,869,12135,65535},{0,0,48704,35614,0,38659,52875,524,34359,62866,0},{0,65535,25731,394,65535,43342,174,28486,65535,289,0}}
	ColorTab2Wave Rainbow
	Wave M_Colors
	Duplicate /o M_colors Color_Rainbow
	//Make /O Color_Rainbow6={{65535,65535,0,0,0,65535,65535},{0,65535,65535,65535,0,0,0},{0,0,0,65535,65535,65535,0}}
	Make /O Color_Trad10={{65535,0,459,38874,0,52191,45625,30160,0,46673,65535},{0,0,46847,439,37087,32343,0,30533,44408,56152,0},{0,65535,2815,24479,37087,118,59011,708,61977,0,0}}
	Make /O Color_BlueRedGreen3={{0,65535,0,0},{0,0,65535,0},{65535,0,0,65535}}
	//for color
	Variable /G gv_colorIndex
	Killwaves /Z M_Colors
	SetDataFolder DF
End

Function GP_Tools(ctrlName): ButtonControl
	String ctrlName
	ControlInfo GraphMenu
	Variable Pos=19
	if (!V_flag)
		ControlBar 30
		Button hide,pos={2,4},size={14,20},title="X",proc=GP_Tools
		pos+=5
		//PopupMenu FolderMenu,pos={19,4},size={83,19},proc=SetYFolder,mode=0,title="f",value=InoFolderList()
		PopupMenu GraphMenu,pos={pos,4},size={45,19},proc=ExecMenu,mode=0,title="Graph",value=#"root:InternalUse:GP_Macro:GraphMenu"
		pos+=65
		if (strlen(TraceNameList("",";",1)))
		PopupMenu TraceMenu,pos={pos,4},size={45,19},proc=ExecMenu,mode=0,title="Trace",value=#"root:InternalUse:GP_Macro:TraceMenu"
		pos+=65
		endif
		if (strlen(ImageNameList("",";")))
		PopupMenu ImageMenu,pos={pos,4},size={45,19},proc=ExecMenu,mode=0,title="Image",value=#"root:InternalUse:GP_Macro:ImageMenu"
		pos+=65
		endif
		popupMenu ProcessMenu,pos={pos,4},size={55,19},proc=ExecMenu,mode=0,title="Process",value=#"root:InternalUse:GP_Macro:ProcessMenu"
		ModifyGraph cbRGB=(65535,65533,55049)
		//WriteFolders()
	else
		ModifyGraph cbRGB=(65535,65533,65533)
		Button hide,pos={2,4},size={14,20},title="@",proc=GP_Tools
		KillControl GraphMenu; KillControl TraceMenu; KillControl ProcessMenu; KillControl ImageMenu
		ControlBar 0
	endif
End

Function ExecMenu(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName,popStr
	Variable popNum
	
	String cmd
	if (stringmatch(popstr,"-")==0)
		cmd="GP_"+ReplaceString(" ",popStr,"")+"()"
		Execute cmd;	print cmd
	endif
		
End

Function/C DefaultRange()
	//NVAR/C rr=root:InternalUse:InoMacro:V_range
	Variable /C rr
	GetMarquee/K left, bottom
	if (V_flag)
		if (strlen(ImageNameList("","")))
			rr=cmplx(V_bottom,V_top)
		else
			rr=cmplx(V_left,V_right)
		endif	
		//variable/G root:InternalUse:InoMacro:V_graphinput=1
	elseif (WaveExists(CsrWaveRef(A)) %& WaveExists(CsrWaveRef(B)))
		rr=cmplx(hcsr(A),hcsr(B))
	endif
	if (real(rr)>imag(rr))
		rr=cmplx(imag(rr),real(rr))
	endif
	return rr
End



Function PrintMarq() : GraphMarquee
	GetMarquee left, bottom
	printf "\r(left, right)=(%g, %g)\r(right-left)=(%g)\r(H center)=(%g)\r\r(top, bottom)=(%g, %g)\r(top-bottom)=(%g)\r(V center)=(%g)\r",V_left,V_right,(V_right-V_left),(V_left+V_right)/2,V_top,V_bottom,(V_top-V_bottom),(V_top+V_bottom)/2
    String  list=ImageNameList("",";")
    if (strlen(list)==0)
    return 1
    endif
    String tr=StringFromList(0,list,";")
    Wave imagen=ImageNameToWaveRef("",tr)
    Variable x0,x1,y0,y1
    x0=round((V_left - DimOffset(imagen, 0))/DimDelta(imagen,0))
    x1=round((V_right - DimOffset(imagen, 0))/DimDelta(imagen,0))
    y0=round((V_top - DimOffset(imagen, 1))/DimDelta(imagen,1))
    y1=round((V_bottom - DimOffset(imagen, 1))/DimDelta(imagen,1))
    
    Variable x2,x3,y2,y3
    
    x2=min(x0,x1)
    x3=max(x0,x1)+1
    y2=min(y0,y1)
    y3=max(y0,y1)+1
    Variable xindex,yindex,sumall
    xindex=x2
    do
     yindex=0
     do
     sumall+=imagen[xindex][yindex]
     yindex+=1
     while (yindex<y3)
    xindex+=1
    while (xindex<x3)
    printf "sumarea= %g",sumall
End

Function return_xwave_info(trace,xwaveflag)
	Wave trace
	Variable xwaveflag
	String notestr=note(trace)
	
	Variable tempvar

	switch (xwaveflag)
		case 1://index
			return Nan
			break
		case 2:
			tempvar=numberbykey("SampleTemperature", notestr, "=","\r")
			return tempvar
		case 3://
			tempvar=numberbykey("PhotonEnergy", notestr, "=","\r")
			return tempvar
		case 4://angle
			tempvar=numberbykey("Momentum", notestr, "=","\r")
			return tempvar
		case 5://energy
			tempvar=numberbykey("Energy", notestr, "=","\r")
			return tempvar
		case 6://sweep
			tempvar=numberbykey("NumberOfSweeps",notestr,"=","\r")
			return tempvar
		case 7://
			tempvar=numberbykey("BeamCurrent", notestr, "=","\r")
			return tempvar
	endswitch
end	


Function Proc_trace_all_New(graphname,Procnum,prefix_str,xrangeflag,x1,x2,autorangeflag,multiflag,directionflag,xwaveflag,sv1,sv2,sv3,sv4)
	string graphname
	Variable procnum
	String prefix_str
	Variable xrangeflag,x1,x2,autorangeflag,multiflag,directionflag,xwaveflag,sv1,sv2,sv3,sv4

	if (xrangeflag==2)
		x1=-inf
		x2=inf
		autorangeflag=1
	endif
	
	String tracelist=TraceNameList(graphname,";",1)	
	Variable index
	Variable tracenum=itemsinlist(tracelist,";")
	String tracename,tracename_new,notestr
	DFREF tracepath
	
	if (autorangeflag==2)
		Variable autocenter=(x1+x2)/2
		Variable autoleft=x1-autocenter
		Variable autoright=x2-autocenter
	endif
			
	string waveN,waveNN,formatstr,Basename
	variable temppos,waveindex,Multi_ck_flag=1,avg_value,wavenameindex=0
	
	tracename=Stringfromlist(0,tracelist,";")
	if (strsearch(tracename,"_e_",0)>0)
		formatstr= "_e_"
	elseif (strsearch(tracename,"_m_",0)>0)
		formatstr= "_m_"
	else
		formatstr= ""
		multiflag=0
	endif
	
	if (procnum>3)
		switch(procnum)
		case 4:
		Basename="Peak_Area"
		break
		case 5:
		Basename="Wave_Max"
		break
		case 6:
		Basename="Mean_Value"
		break
		case 7:
		Basename="Level_Pos"
		break
		case 8:
		Basename="Peak_Pos"
		break
		case 9:
		Basename="Max_Pos"
		break
		case 10:
		Basename="Center_Pos"
		break
		endswitch
	endif
		
	Wave trace=TraceNameToWaveRef(graphname,tracename)
	tracepath=GetwavesdatafolderDFR(trace)
	SetDatafolder tracePath
	newDatafolder /o/s Graph_Proc
	
	Make /o/n=1 area_track
	Make /o/T/n=1 trace_name
	Make/o/n=1 xwave_info
		
	Wave area_track
	Wave /T trace_name
	Wave xwave_info
	
	temppos=strsearch(tracename,formatstr,0)
	waveNN=tracename[0,temppos-1]
	
	do
		tracename=Stringfromlist(index,tracelist,";")
		
		if (strlen(formatstr)==0)
			temppos=strlen(tracename)
		else
			temppos=strsearch(tracename,formatstr,0)
		endif
		
		waveN=tracename[0,temppos-1]
				
		Wave trace=TraceNameToWaveRef(graphname,tracename)
		tracepath=GetwavesdatafolderDFR(trace)
		
		SetDatafolder tracePath
		newDatafolder /o/s Graph_Proc
		
		Wave /Z Xtrace=XWaveRefFromTrace(graphname,tracename)
		
		if (Procnum<4)
			Wave trace_proc=$tracename
			if (!WaveExists(trace_proc))
				Make /o/n=(numpnts(trace),1) $tracename
				Wave trace_proc=$tracename
				trace_proc[][1]=trace[p]
				Add_graph_proc_notestr(trace,0,"",0,0,0,0)
			else
				redimension /n=((max(numpnts(trace),dimsize(trace_proc,0))),(dimsize(trace_proc,1)+1)) trace_proc
				trace_proc[][(dimsize(trace_proc,1)-1)]=trace[p]
			endif
			
			if (strlen(tracename)>29)
				tracename_new=prefix_str+tracename[0,28]
			else
				tracename_new=prefix_str+tracename
			endif
		
			rename trace, $tracename_new
			rename trace_proc, $tracename_new
			notestr=note(trace)
			notestr=replacestringbykey("WaveName",notestr,tracename_new,"=","\r")
			note /K trace
			note trace notestr
			
			notestr=note(trace)
			note /K trace_proc
			note trace_proc,notestr
		
		
			if 	(multiflag==2)
				if (Multi_ck_flag)
					if (stringmatch(waveN,waveNN))
						Insertpoints inf,1,area_track
						avg_value=Proc_trace_macro(trace,Xtrace,x1,x2,Procnum,1,sv1,sv2,directionflag)	
						trace*=avg_value
						area_track[waveindex]=avg_value
						waveindex+=1
					else
						waveNN=waveN
						Multi_ck_flag=0
						deletepoints waveindex,1,area_track
						waveindex=0
					endif
				endif
				if (Multi_ck_flag==0)
					avg_value=Proc_trace_macro(trace,Xtrace,x1,x2,Procnum,1,sv1,sv2,directionflag)	
					if (stringmatch(waveN,waveNN))
						trace*=area_track[waveindex]	
						waveindex+=1
					else
						waveindex=0
						waveNN=waveN
						trace*=area_track[waveindex]
						waveindex+=1
					endif
				endif
			else
				Insertpoints inf,1,area_track
				avg_value=Proc_trace_macro(trace,Xtrace,x1,x2,Procnum,1,sv1,sv2,directionflag)
				area_track[waveindex]=avg_value	
				waveindex+=1
			endif
			
			Add_graph_proc_notestr(trace,dimsize(trace_proc,1),prefix_str,x1,x2,procnum,avg_value)
		else
			
			
			
			if 	(multiflag==2)
				if (stringmatch(waveN,waveNN))
					Insertpoints inf,1,area_track,trace_name,xwave_info
					if (autorangeflag==2)
						x1=autocenter+autoleft
						x2=autocenter+autoright
					endif
					avg_value=Proc_trace_macro(trace,Xtrace,x1,x2,Procnum-3,0,sv1,sv2,directionflag)	
					area_track[waveindex]=avg_value
					trace_name[waveindex]=tracename
					xwave_info[waveindex]=(numtype(return_xwave_info(trace,xwaveflag))==2)?(waveindex):(return_xwave_info(trace,xwaveflag))
					if (numtype(avg_Value)!=2)
						autocenter=avg_value
					endif
					waveindex+=1
				else
					deletepoints waveindex,1,area_track,trace_name,xwave_info
					SetDatafolder tracePath
					newDatafolder /o/s $basename
					duplicate /o Trace_name $("Trace_name"+num2str(wavenameindex))
					duplicate /o area_track $(basename+num2str(wavenameindex))
					duplicate /o xwave_info $("xwave_"+num2str(wavenameindex))
					waveNN=waveN
					Waveindex=0
					Wavenameindex+=1
					redimension /N=1 area_track,trace_name,xwave_info
					continue
					
				endif
			else
				Insertpoints inf,1,area_track,trace_name,xwave_info
				if (autorangeflag==2)
					x1=autocenter+autoleft
					x2=autocenter+autoright
				endif
				avg_value=Proc_trace_macro(trace,Xtrace,x1,x2,Procnum-3,0,sv1,sv2,directionflag)
				area_track[waveindex]=avg_value
				trace_name[waveindex]=tracename
				xwave_info[waveindex]=(numtype(return_xwave_info(trace,xwaveflag))==2)?(waveindex):(return_xwave_info(trace,xwaveflag))
				if (numtype(avg_Value)!=2)
					autocenter=avg_value
				endif	
				waveindex+=1
			endif
		endif
					
	index+=1
	while (index<tracenum)
		
	if (procnum>3)
	
		
		deletepoints waveindex,1,area_track,trace_name,xwave_info
		SetDatafolder tracePath
		newDatafolder /o/s $basename
		duplicate /o Trace_name $("Trace_name"+num2str(wavenameindex))
		duplicate /o area_track $(basename+num2str(wavenameindex))
		duplicate /o xwave_info $("xwave_"+num2str(wavenameindex))
		Wavenameindex+=1
		//SetDatafolder tracePath
		//newDatafolder /o/s $basename
		String Wavename_list=Wavelist(basename+"*",";","")
		String Trname_list=Wavelist("Trace_name*",";","")
		String plotname,Trplotname,PlottbN,plotgN
		index=0
		do 
			Plotname=basename+num2str(index)//stringfromlist(index,Wavename_list,";")
			Trplotname="Trace_name"+num2str(index)//=stringfromlist(index,Trname_list,";")
			Wave tracen=$trplotname
			Wave plotn=$plotname
			Wave plotx=$("xwave_"+num2str(index))
			if (index==0)
				edit  tracen,plotx,plotn
				ModifyTable width(tracen)=150,width(plotn)=70
				PlottbN=winname(0,2)
				
				if (xwaveflag>1)
					display_XYwave(plotn,plotx,0,0)
				else
					display_wave(plotn,0,0)
				endif
				plotgN=winname(0,1)
			else
				AppendToTable /W=$PlottbN tracen,plotn
				ModifyTable width(tracen)=150,width(plotn)=70
				dowindow /F $plotgN
				if (xwaveflag>1)
					display_XYwave(plotn,plotx,1,0)
				else
					display_wave(plotn,1,0)
				endif
			endif
			index+=1
		while (index<wavenameindex)
	endif
		
	Killwaves /Z Trace_name,area_track
End


Function prompt_All(procnum,Prefix_str,xrangeflag,x1,x2,autorangeflag,multiflag,directionflag,xwaveflag,sv1,sv2,sv3,sv4)
	Variable &procnum
	String &Prefix_str
	Variable &xrangeflag,&x1,&x2,&autorangeflag,&multiflag,&directionflag,&xwaveflag,&sv1,&sv2,&sv3,&sv4
	
	String Prefix_str_b
	Variable xrangeflag_b,x1_b,x2_b,autorangeflag_b,multiflag_b,directionflag_b,xwaveflag_b,sv1_b,sv2_b,sv3_b,sv4_b
	
	Prefix_str_b=Prefix_str
	xrangeflag_b=xrangeflag
	x1_b=x1
	x2_b=x2
	autorangeflag_b=autorangeflag
	multiflag_b=multiflag
	directionflag_b=directionflag
	xwaveflag_b=xwaveflag
	sv1_b=sv1
	sv2_b=sv2
	sv3_b=sv3
	sv4_b=sv4
	
	prompt Prefix_str_b,"Prefix of Outputwave"
	prompt xrangeflag_b,"Use (x1,x2) below", popup,"Use (x1,x2) below;(-inf, inf);"
	prompt x1_b,"x1"
	prompt x2_b,"x2"
	prompt autorangeflag_b,"Auto range?",popup,"No;Yes;"
	Prompt multiflag_b,"Multiple Cuts or Single Cuts",popup,"Single;Multiple;"
	prompt directionflag_b,"Direction",popup,"-->;<--;"
	prompt xwaveflag_b,"Use x wave",popup,"index;Tem;PhE;Angle;Energy;"
	
	switch (procnum)
		case 1:  //NormArea
			DoPrompt "Normalize Area", Prefix_str_b,xrangeflag_b,x1_b,x2_b,multiflag_b
			break
		case 2:  //NormHeight
			prompt sv1_b,"Max or Min",popup,"Max;Min;"
			prompt sv2_b,"smoothpnts?"
			DoPrompt "Normalize Height", Prefix_str_b,xrangeflag_b,x1_b,x2_b,multiflag_b,sv1_b,sv2_b
			break
		case 3:  //Constbkg
			DoPrompt "Const. Background", Prefix_str_b,xrangeflag_b,x1_b,x2_b
			break
		case 4://Peakarea
			DoPrompt "Peak Area",xrangeflag_b,x1_b,x2_b,multiflag_b,xwaveflag_b
			break
		case 5://Wavemax
			prompt sv1_b,"Max or Min",popup,"Max;Min;"
			prompt sv2_b,"smoothpnts?"
			DoPrompt "Wave Max", xrangeflag_b,x1_b,x2_b,multiflag_b,xwaveflag_b,sv1_b,sv2_b
			break
		case 6://meanvalue
			DoPrompt "Mean Value",xrangeflag_b,x1_b,x2_b,multiflag_b,xwaveflag_b
			break
		case 7://finelevel	
			prompt sv1_b,"Level value"
			prompt sv2_b,"smoothpnts?"
			DoPrompt "Find Level", xrangeflag_b,x1_b,x2_b,autorangeflag_b,multiflag_b,directionflag_b,xwaveflag_b,sv1_b,sv2_b
			break
		case 8://findpeak
			prompt sv1_b,"Max or Min",popup,"Max;Min;"
			prompt sv2_b,"smoothpnts?"
			DoPrompt "Find Peak",xrangeflag_b,x1_b,x2_b,autorangeflag_b,multiflag_b,directionflag_b,xwaveflag_b,sv1_b,sv2_b
			break
		case 9://finemax
			prompt sv1_b,"Max or Min",popup,"Max;Min;"
			prompt sv2_b,"smoothpnts?"
			DoPrompt "Find Maximum", xrangeflag_b,x1_b,x2_b,autorangeflag_b,multiflag_b,xwaveflag_b,sv1_b,sv2_b
			break
		case 10://finecenter
			DoPrompt "Find Center of Gravity",xrangeflag_b,x1_b,x2_b,autorangeflag_b,multiflag_b,xwaveflag_b
			break
			
	endswitch
	
	if (V_flag)
		return 0
	else
		Prefix_str=Prefix_str_b
		xrangeflag=xrangeflag_b
		x1=x1_b
		x2=x2_b
		autorangeflag=autorangeflag_b
		multiflag=multiflag_b
		directionflag=directionflag_b
		xwaveflag=xwaveflag_b
		sv1=sv1_b
		sv2=sv2_b
		sv3=sv3_b
		sv4=sv4_b
		return 1
	endif
	
	
	
End
	

Function proc_all_graphprocess(Prefix_str,procnum)
	String prefix_str
	Variable procnum
	
	variable/D/C rr=DefaultRange()
	Variable x1=real(rr),x2=Imag(rr)
	String graphname=winname(0,1)
	
	Variable xrangeflag,autorangeflag,multiflag,directionflag,xwaveflag,sv1,sv2,sv3,sv4
	
	if (prompt_All(procnum,Prefix_str,xrangeflag,x1,x2,autorangeflag,multiflag,directionflag,xwaveflag,sv1,sv2,sv3,sv4)==0)
		return 0
	endif
	
	Proc_trace_all_New(graphname,Procnum,prefix_str,xrangeflag,x1,x2,autorangeflag,multiflag,directionflag,xwaveflag,sv1,sv2,sv3,sv4)

End

Function GP_NormalizeArea(): GraphMarquee
	DFREF dF=GetDatafolderDFR()
	
	proc_all_graphprocess("NA_",1)

	SetDatafolder DF
End


Function GP_NormalizeHeight(): GraphMarquee
	DFREF dF=GetDatafolderDFR()
	
	proc_all_graphprocess("NH_",2)
	
	SetDatafolder DF

End

Function GP_ConstBackground(): GraphMarquee
	DFREF dF=GetDatafolderDFR()
	
	proc_all_graphprocess("CB_",3)
	
	SetDatafolder DF
End


Function GP_PeakArea(): GraphMarquee
	DFREF dF=GetDatafolderDFR()
	
	proc_all_graphprocess("",4)
	
	SetDatafolder DF
	
End

Function GP_WaveMax(): GraphMarquee
	DFREF dF=GetDatafolderDFR()
	
	proc_all_graphprocess("",5)
	
	SetDatafolder DF
End

Function GP_MeanValue(): GraphMarquee
	DFREF dF=GetDatafolderDFR()
	
	proc_all_graphprocess("",6)
	
	SetDatafolder DF
End

Function GP_FindLevel(): GraphMarquee
	DFREF dF=GetDatafolderDFR()
	
	proc_all_graphprocess("",7)
	
	SetDatafolder DF
End

Function GP_FindPeak(): GraphMarquee
	DFREF dF=GetDatafolderDFR()
	
	proc_all_graphprocess("",8)
	
	SetDatafolder DF
End

Function GP_FindMaximum(): GraphMarquee
	DFREF dF=GetDatafolderDFR()
	
	proc_all_graphprocess("",9)
	
	SetDatafolder DF
End


Function GP_FindCenter():GraphMarquee
	DFREF dF=GetDatafolderDFR()
	
	proc_all_graphprocess("",10)
	
	SetDatafolder DF
End


Function GP_UndoAnalysis():GraphMarquee
	DFREF DF=GetDatafolderDFR()
	
	String graphname=winname(0,1)
	
  	String tracelist=TraceNameList(graphname,";",1)	
	Variable index
	Variable tracenum=itemsinlist(tracelist,";")
	
	String tracename,tracename_new,notestr,notestr_new,notestr_cut
	Variable temppos
	
	tracename=Stringfromlist(0,tracelist,";")
	Wave trace=TraceNameToWaveRef(graphname,tracename)
	DFREF tracepath=GetwavesdatafolderDFR(trace)
		
	do
		tracename=Stringfromlist(index,tracelist,";")
		
		Wave trace=TraceNameToWaveRef(graphname,tracename)
		DFREF tracepath=GetwavesdatafolderDFR(trace)
		SetDatafolder tracePath
		if (Datafolderexists("Graph_Proc"))
			SetDatafolder Graph_Proc
		else
			SetDatafolder DF
			return 0
		endif
		
		Wave trace_proc=$tracename
			if (!WaveExists(trace_proc))
				SetDatafolder DF
				return 0
			else
				
				notestr=note(trace_proc)
				
				temppos=strsearch(notestr,"Procindex=",inf,1)
				
				notestr_cut=notestr[temppos,inf]
				notestr_new=notestr[0,temppos-3]
				
				Variable Tr_numpnts,Tr_x0,Tr_x1,Tr_dx
				tracename_new=stringbykey("tracename",notestr_cut,"=","\r")
				if (strlen(tracename_new)==0)
					temppos=strsearch(tracename,"_",0)
					tracename_new=tracename[temppos+1,inf]
				endif
					
				Tr_numpnts=numberbykey("numpnts",notestr_cut,"=","\r")
				tr_x0=numberbykey("leftx",notestr_cut,"=","\r")
				tr_x1=numberbykey("rightx",notestr_cut,"=","\r")
				tr_dx=numberbykey("deltax",notestr_cut,"=","\r")
				
				redimension /n=(tr_numpnts) trace
				trace=trace_proc[p][inf]
				if (numtype(tr_dx)==2)
					Setscale /I x,tr_x0,tr_x1,trace
				else
					Setscale /P x, tr_x0,tr_dx,trace
				endif
				rename trace, $tracename_new
				
				
				if (dimsize(trace_proc,1)==1)
					Killwaves /Z trace_proc
					
					note /K trace
					note trace, notestr_new
								
					index+=1
					continue
				else
					deletepoints /M=1 (dimsize(trace_proc,1)-1),1,trace_proc
					note /K trace_proc
					note trace_proc, notestr_new
					rename trace_proc, $tracename_new
					
					note /K trace
					note trace, notestr
				endif
					
			endif
			
	index+=1
	while (index<tracenum)	
	
	SetDatafolder DF
End




Function Proc_trace_all(graphname,prefix_str,Procnum,x1,x2,sv,sv1,directionflag,Multiflag,autorange)
	string graphname,prefix_str
	Variable Procnum,x1,x2,sv,sv1
	Variable directionflag
	Variable Multiflag,autorange
	
	String tracelist=TraceNameList(graphname,";",1)	
	Variable index
	Variable tracenum=itemsinlist(tracelist,";")
	String tracename,tracename_new,notestr
	DFREF tracepath
	
	Variable autocenter=(x1+x2)/2
	Variable autoleft=x1-autocenter
	Variable autoright=x2-autocenter
			
	string waveN,waveNN,formatstr,Basename
	variable temppos,waveindex,Multi_ck_flag=1,avg_value,wavenameindex=0
	
	tracename=Stringfromlist(0,tracelist,";")
	if (strsearch(tracename,"_e_",0)>0)
		formatstr= "_e_"
	elseif (strsearch(tracename,"_m_",0)>0)
		formatstr= "_m_"
	else
		formatstr= ""
		multiflag=0
	endif
	
	if (procnum>3)
		switch(procnum)
		case 4:
		Basename="Peak_Area"
		break
		case 5:
		Basename="Wave_Max"
		break
		case 6:
		Basename="Mean_Value"
		break
		case 7:
		Basename="Level_Pos"
		break
		case 8:
		Basename="Peak_Pos"
		break
		case 9:
		Basename="Max_Pos"
		break
		case 10:
		Basename="Center_Pos"
		break
		endswitch
	endif
		
	Wave trace=TraceNameToWaveRef(graphname,tracename)
	tracepath=GetwavesdatafolderDFR(trace)
	SetDatafolder tracePath
	newDatafolder /o/s Graph_Proc
	
	Make /o/n=1 area_track
	Make /o/T/n=1 trace_name
	Wave area_track
	Wave /T trace_name
	
	temppos=strsearch(tracename,formatstr,0)
	waveNN=tracename[0,temppos-1]
	
	do
		tracename=Stringfromlist(index,tracelist,";")
		
		if (strlen(formatstr)==0)
			temppos=strlen(tracename)
		else
			temppos=strsearch(tracename,formatstr,0)
		endif
		
		waveN=tracename[0,temppos-1]
				
		Wave trace=TraceNameToWaveRef(graphname,tracename)
		tracepath=GetwavesdatafolderDFR(trace)
		
		SetDatafolder tracePath
		newDatafolder /o/s Graph_Proc
		
		Wave /Z Xtrace=XWaveRefFromTrace(graphname,tracename)
		
		if (Procnum<4)
			Wave trace_proc=$tracename
			if (!WaveExists(trace_proc))
				Make /o/n=(numpnts(trace),1) $tracename
				Wave trace_proc=$tracename
				trace_proc[][1]=trace[p]
				Add_graph_proc_notestr(trace,0,"",0,0,0,0)
			else
				redimension /n=((max(numpnts(trace),dimsize(trace_proc,0))),(dimsize(trace_proc,1)+1)) trace_proc
				trace_proc[][(dimsize(trace_proc,1)-1)]=trace[p]
			endif
			
			if (strlen(tracename)>29)
				tracename_new=prefix_str+tracename[0,28]
			else
				tracename_new=prefix_str+tracename
			endif
		
			rename trace, $tracename_new
			rename trace_proc, $tracename_new
			notestr=note(trace)
			notestr=replacestringbykey("WaveName",notestr,tracename_new,"=","\r")
			note /K trace
			note trace notestr
			
			notestr=note(trace)
			note /K trace_proc
			note trace_proc,notestr
		
		
			if 	(multiflag)
				if (Multi_ck_flag)
					if (stringmatch(waveN,waveNN))
					Insertpoints inf,1,area_track
					avg_value=Proc_trace_macro(trace,Xtrace,x1,x2,Procnum,1,sv,sv1,directionflag)	
					trace*=avg_value
					area_track[waveindex]=avg_value
					waveindex+=1
					else
					waveNN=waveN
					Multi_ck_flag=0
					deletepoints waveindex,1,area_track
					waveindex=0
					endif
				endif
				if (Multi_ck_flag==0)
					avg_value=Proc_trace_macro(trace,Xtrace,x1,x2,Procnum,1,sv,sv1,directionflag)	
					if (stringmatch(waveN,waveNN))
						trace*=area_track[waveindex]	
						waveindex+=1
					else
						waveindex=0
						waveNN=waveN
						trace*=area_track[waveindex]
						waveindex+=1
					endif
				endif
			else
				Insertpoints inf,1,area_track
				avg_value=Proc_trace_macro(trace,Xtrace,x1,x2,Procnum,1,sv,sv1,directionflag)
				area_track[waveindex]=avg_value	
				waveindex+=1
			endif
			
			Add_graph_proc_notestr(trace,dimsize(trace_proc,1),prefix_str,x1,x2,procnum,avg_value)
		else
			if 	(multiflag)
				if (stringmatch(waveN,waveNN))
					Insertpoints inf,1,area_track,trace_name
					if (autorange==1)
						x1=autocenter+autoleft
						x2=autocenter+autoright
					endif
					avg_value=Proc_trace_macro(trace,Xtrace,x1,x2,Procnum-3,0,sv,sv1,directionflag)	
					area_track[waveindex]=avg_value
					trace_name[waveindex]=tracename
					if (numtype(avg_Value)!=2)
						autocenter=avg_value
					endif
					waveindex+=1
				else
					deletepoints waveindex,1,area_track,trace_name
					SetDatafolder tracePath
					newDatafolder /o/s $basename
					duplicate /o Trace_name $("Trace_name"+num2str(wavenameindex))
					duplicate /o area_track $(basename+num2str(wavenameindex))
					waveNN=waveN
					Waveindex=0
					Wavenameindex+=1
					redimension /N=1 area_track,trace_name
					continue
					
				endif
			else
				Insertpoints inf,1,area_track,trace_name
				if (autorange==1)
					x1=autocenter+autoleft
					x2=autocenter+autoright
				endif
				avg_value=Proc_trace_macro(trace,Xtrace,x1,x2,Procnum-3,0,sv,sv1,directionflag)
				area_track[waveindex]=avg_value
				trace_name[waveindex]=tracename
				if (numtype(avg_Value)!=2)
					autocenter=avg_value
				endif	
			waveindex+=1
			endif
		endif
					
	index+=1
	while (index<tracenum)
		
	if (procnum>3)
	
		if (multiflag==0)
			deletepoints waveindex,1,area_track,trace_name
			SetDatafolder tracePath
			newDatafolder /o/s $basename
			duplicate /o Trace_name $("Trace_name"+num2str(wavenameindex))
			duplicate /o area_track $(basename+num2str(wavenameindex))
		endif
		
		SetDatafolder tracePath
		SetDatafolder $basename
		String Wavename_list=Wavelist(basename+"*",";","")
		String Trname_list=Wavelist("Trace_name*",";","")
		String plotname,Trplotname,PlottbN,plotgN
		index=0
		do 
			Plotname=basename+num2str(index)//stringfromlist(index,Wavename_list,";")
			Trplotname="Trace_name"+num2str(index)//=stringfromlist(index,Trname_list,";")
			Wave tracen=$trplotname
			Wave plotn=$plotname
			if (index==0)
				edit  tracen,plotn
				ModifyTable width(tracen)=150,width(plotn)=70
				PlottbN=winname(0,2)
				
				display_wave(plotn,0,0)
				plotgN=winname(0,1)
			else
				AppendToTable /W=$PlottbN tracen,plotn
				ModifyTable width(tracen)=150,width(plotn)=70
				dowindow /F $plotgN
				display_wave(plotn,1,0)
			endif
			index+=1
		while (index<wavenameindex)
	endif
		
	Killwaves /Z Trace_name,area_track
End

Function Proc_trace_macro(trace,xtrace,x1,x2,Procnum,flag,sv1,sv2,directionflag)
	wave trace
	Wave/Z xtrace
	Variable x1,x2,procnum,flag
	Variable sv1,sv2,directionflag

	Variable avg_value,Peak_value,area_value
	
	if (waveexists(xtrace))
		x1=(x1<wavemin(xtrace))?(wavemin(xtrace)):(x1)
		x2=(x2>wavemax(xtrace))?(wavemax(xtrace)):(x2)
		
		trace=(numtype(trace)==2)?(0):(trace)
		
		switch(procnum)
		case 1: //norm area
			avg_value=areaXY(xtrace,trace,x1,x2)
			if (flag)
				trace/=avg_value
			endif
		break
		case 2: //norm height
			avg_value=OurWaveMax(xtrace,trace,x1,x2,sv2,sv1)
			if (flag)
				trace/=avg_value
			endif
		break
		case 3:// constbkg
			avg_value=faverageXY(xtrace,trace,x1,x2)
			if (flag)
				trace/=avg_value
			endif
		break
		case 4: //find level
			 avg_value=OurFindLevel(xtrace,trace,x1,x2,sv2,sv1,directionflag)
		break
		case 5: //find peak
			 avg_value=OurFindPeak(xtrace,trace,x1,x2,sv2,sv1,directionflag)
		break
		case 6:	//findemax
			 avg_value=OurFindWaveMax(xtrace,trace,x1,x2,sv2,sv1)
		break
		case 7: //find center
			avg_value=OurFindCenter(xtrace,trace,x1,x2)
		break 
		endswitch
		return avg_value
	else
	
		x1=(x1<leftx(trace))?(leftx(trace)):(x1)
		x2=(x2>rightx(trace))?(rightx(trace)):(x2)
	
		trace=(numtype(trace)==2)?(0):(trace)
	
		switch(procnum)
		case 1: //norm area
			avg_value=area(trace,x1,x2)
			if (flag)
				trace/=abs(avg_value)
			endif
		break
		case 2: //norm height
			duplicate /O /Free trace trace_smth
			if (sv2>1)
				smooth sv2,trace_smth
			endif
			if (sv1==1)
				avg_value=wavemax(trace_smth,x1,x2)
			else
				avg_value=wavemin(trace_smth,x1,x2)
			endif
			if (flag)
				trace/=abs(avg_value)
			endif
		break
		case 3: //const bkg
			avg_value=mean(trace,x1,x2)
			if (flag)
			trace-=avg_value
			endif
		break	
		case 4: //find level
			if (directionflag==1)
				FindLevel /B=(sv2)/Q/R=(x1,x2) trace, sv1
			else
				FindLevel /B=(sv2)/Q/R=(x2,x1) trace, sv1
			endif
			if (v_flag==0)
				avg_value=V_LevelX
			else
				avg_value=Nan
			endif
		break
		case 5: //find peak
			//Variable min_value=min(trace(x1),trace(x2))
			if (sv1==1)
				if (directionflag==1)
					FindPeak /B=(sv2)/Q/R=(x1,x2) trace
				else
					FindPeak /B=(sv2)/Q/R=(x2,x1) trace
				endif
			else
				if (directionflag==1)
					FindPeak /N/B=(sv2)/Q/R=(x1,x2) trace
				else
					FindPeak /N/B=(sv2)/Q/R=(x2,x1) trace
				endif
			endif
			avg_value=V_PeakLoc
		break
		case 6: //find Max
			Duplicate /o/Free trace,trace_smth
			if (sv2>1)
				smooth sv2,trace_smth
			endif
			
			WaveStats /Q/R=(x1,x2) trace_smth
			if (sv1==1)
				avg_value=V_maxloc
			else
				avg_value=V_minloc
			endif
		break
		case 7: //find center of gravity
			duplicate /o trace,trace_temp
			trace_temp*=x
			avg_value=sum(trace_temp,x1,x2)/sum(trace,x1,x2)
			killwaves/Z trace_temp
			//	avg_value=mean
			break
		endswitch
		return avg_value
	endif
end

Function /D OurFindCenter(wx,wy,x1,x2)
	Wave/D wx,wy
	Variable/D x1,x2
	
	duplicate /o wy, temp_wave
	temp_wave=wy[p]*wx[p]
	
	Variable p1=Binarysearch(wx,x1),p2=Binarysearch(wx,x2),p3=max(p1,p2),p0=min(p1,p2)
	variable /D sum1,sum2
	do
		sum1+=temp_wave[p0]
		sum2+=wy[p0]
		p0+=1
	while (p0<=p3)
	
	return sum1/sum2
End

Function/D OurFindWaveMax(wx,wy,x1,x2,smth,Maxflag)
	Wave/D wx,wy
	Variable/D x1,x2
	Variable smth,maxflag
		
	Variable p1=Binarysearch(wx,x1),p2=Binarysearch(wx,x2),p3=max(p1,p2),p0=min(p1,p2)
	duplicate /o/Free wy wy_smth
	if (smth>1)
		smooth smth,wy_smth
	endif
	variable /D height=wy_smth[p0]
	variable index
	do
		if (maxflag==1) //max
			if (wy_smth[p0]>height)
				index=p0
				height=wy_smth[p0]
			endif
		else //minimun
			if (wy_smth[p0]<height)
				index=p0
				height=wy_smth[p0]
			endif
		endif
		//height=max(height,wy[p0])
		p0+=1
	while (p0<=p3)
	
	return wx[index]
End

Function/D OurFindPeak(wx,wy,x1,x2,smth,Maxflag,directionflag)
	Wave/D wx,wy
	Variable/D x1,x2
	Variable smth,Maxflag
	Variable directionflag
	
	if (maxflag==1)
		if (directionflag==1)
			FindPeak /B=(smth)/P/Q/R=[BinarySearch(wx,x1),BinarySearch(wx,x2)] wy
		else
			FindPeak /B=(smth)/P/Q/R=[BinarySearch(wx,x2),BinarySearch(wx,x1)] wy
		endif
	else
		if (directionflag==1)
			FindPeak /N/B=(smth)/P/Q/R=[BinarySearch(wx,x1),BinarySearch(wx,x2)] wy
		else
			FindPeak /N/B=(smth)/P/Q/R=[BinarySearch(wx,x2),BinarySearch(wx,x1)] wy
		endif
	endif
	if (V_flag)
		return Nan
	else
		return wx[V_PeakLoc]
	endif
	//Wavestats /Q/R=[BinarySearch(wx,x1),BinarySearch(wx,x2)] wy
	//if (V_flag)
	//	return nan
	//else
	//	return wx[V_PeakLoc]
	//endif
End

Function/D OurFindLevel(wx,wy,x1,x2,smth,level,directionflag)
	Wave/D wx,wy
	Variable/D x1,x2,smth,level
	Variable directionflag
	
	print "function to be developed"
//	
//	if (directionflag==1)
//		FindLevel/B=(smth)/P/Q/R=[BinarySearch(wx,x1),BinarySearch(wx,x2)] wy, level
//	else
//		FindLevel/B=(smth)/P/Q/R=[BinarySearch(wx,x2),BinarySearch(wx,x1)] wy, level
//	endif
//	if (V_flag)
//		return nan
//	else
//		return wx[V_levelX]
//	endif
//	return r
return 0
End

Function/D OurWaveMax(wx,wy,x1,x2,smth,Maxflag)
	wave/D wx,wy
	variable/D x1,x2
	Variable smth,maxflag

	Variable p1=Binarysearch(wx,x1),p2=Binarysearch(wx,x2),p3=max(p1,p2),p0=min(p1,p2)
	duplicate /o/Free wy wy_smth
	if (smth>1)
		smooth smth,wy_smth
	endif
	
	variable /D height=wy_smth[p0]
	do
		if (maxflag==1)
			height=max(height,wy_smth[p0])
		else
			height=min(height,wy_smth[p0])
		endif
		p0+=1
	while (p0<=p3)
	//killwaves/Z wd	
	return height
End



Function Add_graph_proc_notestr(trace,procindex,prefix_str,x1,x2,procnum,avg_value)
	
	wave trace
	Variable procindex
	String prefix_str
	Variable x1,x2,procnum,avg_value
	String addstr
	string notestr
	
		addstr="\rProcindex="+num2str(procindex)+"\r"
		addstr+="prefix="+prefix_str+"\r"
		addstr+="tracename="+nameofwave(trace)+"\r"
		addstr+="x1=\r"
		addstr+="x2=\r"
		addstr+="Procnum="+num2str(procnum)+"\r"
		addstr+="avgvalue=\r"
		addstr+="numpnts="+num2str(numpnts(trace))+"\r"
		addstr+="leftx=\r"
		addstr+="rightx=\r"
		addstr+="deltax=\r"
	
		addstr=replacenumberbykey("avgvalue",addstr,avg_value,"=","\r")
		addstr=replacenumberbykey("x1",addstr,x1,"=","\r")
		addstr=replacenumberbykey("x2",addstr,x2,"=","\r")
		addstr=replacenumberbykey("leftx",addstr,leftx(trace),"=","\r")
		addstr=replacenumberbykey("rightx",addstr,rightx(trace),"=","\r")
		addstr=replacenumberbykey("deltax",addstr,deltax(trace),"=","\r")
		
		notestr=note(trace)
		//print strlen(notestr),nameofwave(trace)
		notestr+=addstr
		note /K trace
		note trace, notestr
End

Function GP_FermiFunction()
	DFREF dF=GetDatafolderDFR()
	String Prefix_str="FM_"
	Variable EF=0,T=300,m,g,fwhm=0.005
	Variable Tflag=1
	prompt EF,"Fermi Energy (eV)="
	prompt Tflag,"Temperature",popup,"Auto;Manual;"
	prompt T,"Temperature (K)="
	prompt m,"Mode",popup,"Devide;Multiply;"
	prompt g,"Convolve?",popup,"Yes;No;"
	prompt fwhm,"Gauss FWHM (eV)="
	prompt prefix_str,"Prefix of Outputwave"
	Doprompt "Fermi Function",prefix_str,EF,Tflag,T,m,g,fwhm
	
	if(v_flag)
		return 0
	endif
	
	if (Tflag==1)
		T=Nan
	endif
	
	String graphname=winname(0,1)
	Cal_trace_all(graphname,prefix_str,11,EF,T,m,fwhm,g,"")
	
	SetDatafolder DF
End

Function GP_ConvolveGuass()
	DFREF dF=GetDatafolderDFR()
	String Prefix_str="CG_"
	Variable fwhm=0.005
	//prompt EF,"EF="
	//prompt T,"Temperature="
	//prompt m,"Mode",popup,"Devide;Multiply;"
	//prompt g,"Convolve?",popup,"Yes;No;"
	prompt fwhm,"Gauss FWHM (eV)="
	prompt prefix_str,"Prefix of Outputwave"
	Doprompt "Convolve Guass",prefix_str,fwhm
	
	if(v_flag)
		return 0
	endif
	
	String graphname=winname(0,1)
	Cal_trace_all(graphname,prefix_str,12,0,0,0,fwhm,0,"")
	
	SetDatafolder DF
End

Function GP_SymEDC()
	DFREF dF=GetDatafolderDFR()
	String Prefix_str="SYM_"
	Variable EF//fwhm=0.005
	prompt EF,"Fermi Energy (eV)="
	//prompt T,"Temperature="
	//prompt m,"Mode",popup,"Devide;Multiply;"
	//prompt g,"Convolve?",popup,"Yes;No;"
	//prompt fwhm,"Gauss FWHM"
	prompt prefix_str,"Prefix of Outputwave"
	Doprompt "Symmetrize EDC",prefix_str,EF
	
	if(v_flag)
		return 0
	endif
	
	String graphname=winname(0,1)
	Cal_trace_all(graphname,prefix_str,13,EF,0,0,0,0,"")
	
	SetDatafolder DF
End

Function GP_CropDCs()
	DFREF dF=GetDatafolderDFR()
	String Prefix_str="CR_"
	Variable x0,x1
	x0=Nan
	x1=Nan
	prompt x0,"x0="
	prompt x1,"x1="
	//prompt T,"Temperature="
	//prompt m,"Mode",popup,"Devide;Multiply;"
	//prompt g,"Convolve?",popup,"Yes;No;"
	//prompt fwhm,"Gauss FWHM"
	//prompt prefix_str,"Prefix of Outputwave"
	Doprompt "Crop DCs",x0,x1

	if(v_flag)
		return 0
	endif
	
	String graphname=winname(0,1)
	Cal_trace_all(graphname,prefix_str,14,x0,x1,0,0,0,"")
	
	SetDatafolder DF
End

Function GP_ShiftXoffset()
	DFREF dF=GetDatafolderDFR()
	
	String Prefix_str="Sx_"
	
	String graphname=winname(0,1)
	
	Cal_trace_all(graphname,prefix_str,15,0,0,0,0,0,"")
	SetDatafolder DF
End


Function GP_ShiftYoffset()
	DFREF dF=GetDatafolderDFR()
	String Prefix_str="Sy_"
	
	String graphname=winname(0,1)
	
	Cal_trace_all(graphname,prefix_str,16,1,0,0,0,0,"")
	SetDatafolder DF
End

Function  GP_SubBackground()
	DFREF dF=GetDatafolderDFR()
	String Prefix_str="SB_"
	
	String graphname=winname(0,1)
	String tracelist=TraceNameList(graphname,";",1)	
	
	String cmd="CreateBrowser prompt=\"Select Waves to for bkg\"" 
	Execute /Q cmd

	SVAR S_BrowserList
	
	String bkgpath=stringfromlist(0,S_BrowserList,";")//GetWavesDataFolder(trace, 1 )

	Cal_trace_all(graphname,prefix_str,17,0,0,0,0,0,bkgpath)
	SetDatafolder DF
End

Function GP_Smoothpnts()
	DFREF dF=GetDatafolderDFR()
	String Prefix_str="SM_"
	String graphname=winname(0,1)
	
	Variable pnts,smttime
	pnts=2
	smttime=1
	prompt pnts,"Input smooth pnts"
	prompt smttime,"Input smooth times"
	
	doprompt "Input for Smooth",pnts,smttime
	if (V_flag)
		SetDatafolder DF
		return 0
	endif
	
	Cal_trace_all(graphname,prefix_str,18,pnts,smttime,0,0,0,"")
	SetDatafolder DF
	
End


Function GP_Derivative()
	DFREF dF=GetDatafolderDFR()
	String Prefix_str="DR_"
	String graphname=winname(0,1)
	
	Variable pnts,difftime
	difftime=1
	prompt difftime,"Input Diff times"
	
	doprompt "Input for Derivative",difftime
	if (V_flag)
		SetDatafolder DF
		return 0
	endif
	
	Cal_trace_all(graphname,prefix_str,19,difftime,0,0,0,0,"")
	SetDatafolder DF
	
End

Function GP_FlipY()
	DFREF dF=GetDatafolderDFR()
	String Prefix_str="FY_"
	String graphname=winname(0,1)
	
	Variable gv_absflag=1
	prompt gv_absflag,"Y axis:",popup,"Flip;ABS;"
	
	
	doprompt "Input for FlipY",gv_absflag
	if (V_flag)
		SetDatafolder DF
		return 0
	endif

	Cal_trace_all(graphname,prefix_str,20,gv_absflag,0,0,0,0,"")
	SetDatafolder DF
	
end



Function Cal_Trace_all(graphname,prefix_str,Procnum,sv1,sv2,sv3,sv4,flag,ss1)
	String graphname
	String prefix_str
	Variable procnum,sv1,sv2,sv3,sv4,flag
	String ss1

	if (procnum==17)
		Wave bkg=$ss1
		duplicate /o/Free bkg bkg_Temp
	endif

	String tracelist=TraceNameList(graphname,";",1)	
	Variable index
	Variable tracenum=itemsinlist(tracelist,";")
	String tracename,tracename_new,notestr
	DFREF tracepath
			
	string waveN,waveNN,formatstr,Basename
	variable temppos,waveindex,Multi_ck_flag=1,avg_value,wavenameindex=0
	
	tracename=Stringfromlist(0,tracelist,";")
		
	Wave trace=TraceNameToWaveRef(graphname,tracename)
	tracepath=GetwavesdatafolderDFR(trace)
	SetDatafolder tracePath
	newDatafolder /o/s Graph_Proc
	
	do
		tracename=Stringfromlist(index,tracelist,";")
		
		Wave trace=TraceNameToWaveRef(graphname,tracename)
		tracepath=GetwavesdatafolderDFR(trace)
		Wave /Z xtrace=XWaveRefFromTrace(graphname,tracename)
		SetDatafolder tracePath
		newDatafolder /o/s Graph_Proc
		
		
		Wave trace_proc=$tracename
			if (!WaveExists(trace_proc))
				Make /o/n=(numpnts(trace),1) $tracename
				Wave trace_proc=$tracename
				trace_proc[][1]=trace[p]
				Add_graph_proc_notestr(trace,0,"",0,0,0,0)
			else
				redimension /n=((max(numpnts(trace),dimsize(trace_proc,0))),(dimsize(trace_proc,1)+1)) trace_proc
				trace_proc[][(dimsize(trace_proc,1)-1)]=trace[p]	
			endif
			
			notestr=note(trace)
			note /K trace_proc
			note trace_proc,notestr
		
			if (strlen(tracename)>29)
				tracename_new=prefix_str+tracename[0,28]
			else
				tracename_new=prefix_str+tracename
			endif
		
			rename trace, $tracename_new
			rename trace_proc, $tracename_new
			
			
			switch(procnum)
			case 11: //Fermi Function
				Variable EF=sv1
				Variable T
				Variable m=sv3
				Variable fwhm=sv4
				Variable g=flag
				if (numtype(sv2)==2)
					T=numberbykey("SampleTemperature",notestr,"=","\r")
				else
					T=sv2
				endif
				Cal_trace_FermiFunction(trace,xtrace,ef,T,m,fwhm,g)	
				break
			case 12: //Convolve
				fwhm=sv4
				Cal_trace_ConvolveGuass(trace,xtrace,fwhm)	
				break
			case 13: //Symmetrize
				EF=sv1
				Cal_trace_Symmetrize(trace,xtrace,EF)
				break
			case 14: //crop DCs
				Cal_Crop_trace(trace,xtrace,sv1,sv2)
				break
			case 15: //shift xoffset
			case 16: //shift xoffset
				Variable xoffset,yoffset
				String traceInfostr=TraceInfo(graphname, tracename_new, 0 )
				String offsetstr=stringbykey("offset(x)",traceInfostr,"=",";")
				offsetstr=offsetstr[1,strlen(offsetstr)-2]
				sscanf offsetstr,"%g,%g",xoffset,yoffset
				if (sv1==0)
					Cal_Shift_trace_offset(trace,xtrace,xoffset,sv1)
				else
					Cal_Shift_trace_offset(trace,xtrace,yoffset,sv1)
				endif
				break
			case 17: //sub bkg
				Cal_trace_subbkg(trace,xtrace,bkg_Temp)
				break
			case 18: //smooth
				Cal_trace_smooth(trace,xtrace,sv1,sv2)
				break
			case 19: //derivative
				Cal_trace_derivative(trace,xtrace,sv1)
				break
			case 20://
				Cal_trace_flipY(trace,xtrace,sv1)
				break
			endswitch
			
			
			Add_graph_proc_notestr(trace,dimsize(trace_proc,1),prefix_str,0,0,procnum,0)
				
					
	index+=1
	while (index<tracenum)

End

Function Cal_trace_flipY(trace,xtrace,absflag)
	Wave trace
	Wave /Z xtrace
	Variable absflag
	if (waveexists(xtrace))

	else
		if (absflag==1)
			trace=-trace
		else	
			trace=abs(trace)
		endif
	endif
End

Function Cal_trace_derivative(trace,xtrace,dertimes)
	Wave trace
	Wave /Z xtrace
	Variable dertimes
	if (waveexists(xtrace))

	else
		Variable index=0
		do
			Differentiate  trace
		index += 1
		while(index < dertimes)
	endif
End

Function Cal_trace_smooth(trace,xtrace,pnts,smttime)
	Wave trace
	Wave /Z xtrace
	Variable pnts,smttime
	if (waveexists(xtrace))

	else
		M_smooth_times(trace,0,pnts,smttime)
	endif
End


Function Cal_trace_subbkg(trace,xtrace,bkgtrace)
	Wave trace
	Wave /Z xtrace
	Wave bkgtrace
	
	
	if (waveexists(xtrace))

	else
		trace-=bkgtrace(x)
		
	endif
End


Function Cal_Shift_trace_offset(trace,xtrace,offset,dimflag)
	Wave trace
	Wave /Z xtrace
	variable offset
	Variable dimflag
	if (waveexists(xtrace))

	else
		if (dimflag==0)
			Variable x0=leftx(trace)
			Variable x1=rightx(Trace)
			Setscale /I x,x0+offset,x1+offset,trace
		else
			trace+=offset
		endif
	endif
End



Function Cal_Crop_trace(trace,xtrace,x0,x1)
	Wave trace
	Wave /Z  xtrace
	Variable x0,x1

	
	Variable p0,p1,x01,x11
	
	if (waveexists(xtrace))
	
	else
		if (numtype(x0)==2)
			x0=leftx(trace)
		endif
		
		if (numtype(x1)==2)
			x1=rightx(trace)
		endif
		
		duplicate /O/R=(x0,x1) trace  trace_temp
		duplicate /O trace_temp trace
		Killwaves /Z trace
	endif
End

Function Cal_trace_FermiFunction(trace,xtrace,ef,T,m,fwhm,g)	
	Wave trace
	Wave /Z xtrace
	Variable ef,T,m,fwhm,g

	Variable kB=8.617385e-5
   	 if (fwhm == 0 || numtype(fwhm) != 0)
			fwhm = 0.002
	else
			fwhm =  abs(fwhm)
	endif
	  
	Variable res=10
	Variable data_dx,x0,x1,gauss_from=10*fwhm,dx
	Variable y_xfrom,y_xto,gauss_pnts,y_pnts	  
	  
	Duplicate /o trace tempF
	if (g-1)
		tempF=1/(exp((x-EF)/KB/T)+1)
		if (m-1)
		trace*=TempF
		else
		trace/=tempF
		endif
	else
	data_dx=deltax(Trace)
	x0=leftx(Trace)
	x1=rightx(Trace)
	dx=min(fwhm/res,abs(data_dx/2))
	y_xfrom=x0-4*fwhm
	y_xto=x1+4*fwhm
	gauss_pnts=round(gauss_from/dx)*2+1
	y_pnts=round((y_xto-y_xfrom)/dx)
	make /o/d/n=(gauss_pnts) w_conv_gauss = 0
	Make/o/d/n=(y_pnts) convFerm = 0
	SetScale/P x y_xfrom, dx, convFerm
	SetScale/P x -gauss_from, dx, w_conv_gauss
   	 convFerm=1/(exp((x-EF)/KB/T)+1)//interp(x,xdata,data)
   	 w_conv_gauss= exp(-x^2*4*ln(2)/fwhm^2)
    	Variable sumGauss = sum(w_conv_gauss, -inf,inf)
   	 w_conv_gauss /= sumGauss
       //FFTConvolve(w_conv_gauss,w_conv_y)
    	Convolve/A w_conv_gauss convFerm
	  
	  tempF=convFerm(x)
	    if (m-1)
	    trace*=TempF
		else
		trace/=tempF
		endif
	
	endif
	  
	killWaves /Z tempF,w_conv_gauss,convFerm

End

Function Cal_trace_ConvolveGuass(trace,xtrace,fwhm)
Wave trace
Wave /Z xtrace
Variable fwhm

	Variable kB=8.617385e-5
    if (fwhm == 0 || numtype(fwhm) != 0)
			fwhm = 0.002
	else
			fwhm =  abs(fwhm)
	endif
	  
	Variable res=10
	Variable data_dx,x0,x1,gauss_from=10*fwhm,dx
	Variable y_xfrom,y_xto,gauss_pnts,y_pnts	  
	
	data_dx=deltax(trace)
	x0=leftx(trace)
	x1=rightx(trace)
	dx=min(fwhm/res,abs(data_dx/2))
	y_xfrom=x0-4*fwhm
	y_xto=x1+4*fwhm
	gauss_pnts=round(gauss_from/dx)*2+1
	y_pnts=round((y_xto-y_xfrom)/dx)
	make /o/d/n=(gauss_pnts) w_conv_gauss = 0
	Make/o/d/n=(y_pnts) convData
	SetScale/P x y_xfrom, dx, convData
	SetScale/P x -gauss_from, dx, w_conv_gauss
    ConvData=Trace(x)
    w_conv_gauss= exp(-x^2*4*ln(2)/fwhm^2)
    Variable sumGauss = sum(w_conv_gauss, -inf,inf)
    	w_conv_gauss /= sumGauss
       //FFTConvolve(w_conv_gauss,w_conv_y)
    	Convolve/A w_conv_gauss convData
	 Trace=convData(x)
	 
	 killWaves /Z tempF,w_conv_gauss,convData

End


Function Cal_trace_Symmetrize(trace,xtrace,EF)
	Wave trace
	Wave /Z xtrace
	Variable EF
	
	Variable Efn,En,XMax
	Efn=round((EF-leftx(trace))/deltax(trace))
	Make /o /n=((2*(Efn)+1)) TempSym,IntEDC1,IntEDC2
	Setscale /I x,leftx(trace),(EF*2-leftx(trace)),TempSym,IntEDC1,IntEDC2
	XMax=pnt2x(trace, (numpnts(trace)-1))
    	Make /o/n=(numpnts(trace)) XImage,TempEDc
    	Setscale /P x,leftx(trace),deltax(trace),XImage,TempEDC
   	 XImage=x
   	 IntEDC1=interp(x,XImage,trace)
   	 IntEDC1=(p>(x2pnt(IntEDC1,XMax)))?(0):IntEDC1
   	 IntEDC2=IntEDC1[numpnts(IntEDC1)-p-1]
    	TempSym=IntEDC1[p]+IntEDC2[p]
    	String notestr=note(trace)
    	Duplicate /o TempSym trace
    	note /K trace
    	note trace,notestr
   	 KillWaves /Z XIMage,Tempsym,TempEDC,IntEDC1,IntEDC2 
	
End



Function GP_ImportGraph() // import all or select wave from the next graph
	DFREF DF=GetdatafolderDFR()
	String Wname=winname(0,1)
	String nextgraph=winname(1,1)
	
	String tracelist=TraceNameList(nextgraph,";",1)
	String imagelist=imagenamelist(nextgraph,";")
	
	String popuptracelist="All;"+tracelist
	String popupimagelist="All;"+imagelist
	
	Variable importtrace=0
	Variable importimage=0
	
	prompt importtrace,"Select tracename",popup, popuptracelist
	prompt importimage,"Select imagename",popup, popupimagelist
	
	doprompt "Select wave for import",importtrace,importimage
	if (V_flag)
		return 0
	endif
	
	importtrace-=2
	importimage-=2
	
	
   	String TraceName
   	Variable items=Itemsinlist(tracelist,";")
   	Variable index=0
   	Variable temppos,temppos1
   	if (strlen(tracelist)>0)
   		do
   			tracename=Stringfromlist(index,tracelist)
   			if (strlen(tracename)==0)
   				break
   			endif
   			if (importtrace>=0)
   				if (importtrace!=index)
   					index+=1
   					continue
   				endif
   			endif
   			Wave data=tracenametowaveref(nextgraph,tracename)
   			Wave/Z xdata=XWaveRefFromTrace(nextgraph,tracename)
   			String infostr=Traceinfo(nextgraph,tracename,0)
   			temppos=strsearch(infostr,"RECREATION:",0)
   			String recreatestr=infostr[temppos+11,inf]
   			recreatestr=ReplaceString("(x)", recreatestr, "("+tracename+")")
   			if (Waveexists(xdata))
   				Wname=display_XYwave(data,xdata,1,0)
   			else
   				Wname=display_wave(data,1,0)
   			endif	
   		
   			ExecuteLongstr("Modifygraph /W="+wname+" ",recreatestr,";",0)
   		
   			index+=1
   		while (index<items)
   	endif
   	
   	index=0
   	if (strlen(imagelist)>0)
   		items=Itemsinlist(imagelist,";")
   		do
   			tracename=stringfromlist(index,imagelist)
   			if (strlen(tracename)==0)
   				break
   			endif
   			if (importimage>=0)
   				if (importimage!=index)
   					index+=1
   					continue
   				endif
   			endif
   			Wave data=imagenametowaveref(nextgraph,tracename)
   			infostr=Imageinfo(nextgraph,tracename,0)
   		
   			temppos=strsearch(infostr,"RECREATION:",0)
   			recreatestr=infostr[temppos+11,inf]
   			//recreatestr=ReplaceString("(x)", recreatestr, "("+tracename+")")
   			
   			Wname=display_wave(data,1,0)
   		
   			ExecuteLongstr("Modifyimage /W="+wname+" "+tracename+" ",recreatestr,";",0)
   			index+=1
   		while (index<items)
   	endif
   	
	
End

Function GP_AppendGraph() //Append all or selectwave in this graph  to the next graph
	DFREF DF=GetdatafolderDFR()
	String Wname=winname(0,1)
	String nextgraph=winname(1,1)
	
	String tracelist=TraceNameList(Wname,";",1)
	String imagelist=imagenamelist(Wname,";")
	
	String popuptracelist="All;"+tracelist
	String popupimagelist="All;"+imagelist
	
	Variable importtrace=0
	Variable importimage=0
	
	prompt importtrace,"Select tracename",popup, popuptracelist
	prompt importimage,"Select imagename",popup, popupimagelist
	
	doprompt "Select wave for append",importtrace,importimage
	if (V_flag)
		return 0
	endif
	
	importtrace-=2
	importimage-=2
	
   	String TraceName
   	Variable items=Itemsinlist(tracelist,";")
   	Variable index=0
   	Variable temppos,temppos1
   	if (strlen(tracelist)>0)
   		do
   			tracename=Stringfromlist(index,tracelist)
   			if (strlen(tracename)==0)
   				break
   			endif
   			if (importtrace>=0)
   				if (importtrace!=index)
   					index+=1
   					continue
   				endif
   			endif
   			
   			Wave data=tracenametowaveref(wname,tracename)
   			Wave/Z xdata=XWaveRefFromTrace(wname,tracename)
   			String infostr=Traceinfo(wname,tracename,0)
   			temppos=strsearch(infostr,"RECREATION:",0)
   			String recreatestr=infostr[temppos+11,inf]
   			recreatestr=ReplaceString("(x)", recreatestr, "("+tracename+")")
   			if (Waveexists(xdata))
   				nextgraph=display_XYwave(data,xdata,2,0)
   			else
   				nextgraph=display_wave(data,2,0)
   			endif	
   		
   			ExecuteLongstr("Modifygraph /W="+nextgraph+" ",recreatestr,";",0)
   		
   			index+=1
   		while (index<items)
   	endif
   	
   	index=0

   	if (strlen(imagelist)>0)
   		items=Itemsinlist(imagelist,";")
   		do
   			tracename=stringfromlist(index,imagelist)
   			if (strlen(tracename)==0)
   				break
   			endif
   			if (importimage>=0)
   				if (importimage!=index)
   					index+=1
   					continue
   				endif
   			endif
   			Wave data=imagenametowaveref(wname,tracename)
   			infostr=Imageinfo(wname,tracename,0)
   		
   			temppos=strsearch(infostr,"RECREATION:",0)
   			recreatestr=infostr[temppos+11,inf]
   			//recreatestr=ReplaceString("(x)", recreatestr, "("+tracename+")")
   			
   			nextgraph=display_wave(data,2,0)
   		
   			ExecuteLongstr("Modifyimage /W="+nextgraph+" "+tracename+" ",recreatestr,";",0)
   			index+=1
   		while (index<items)
   	endif
   	
End

Function ExecuteLongstr(headstr,endstring,sepstr,flag)
	String headstr,endstring,sepstr
	Variable flag
	
	String tempstr
	Variable temppos,temppos1
	String cmd
	temppos=strsearch(endstring,sepstr,0)
	if (temppos==-1)
		return 0
	endif
	temppos1=0
	do
		tempstr=endstring[temppos1,temppos-1]
		
		cmd=headstr+tempstr
		execute  cmd
		temppos1=temppos+1
		temppos=strsearch(endstring,sepstr,temppos1)
		if (temppos==-1)
			return 0
		endif	
	while (1)
end	






Function GP_SeperateGraph()
   	DFREF df=GetDatafolderDFR()
    	String Wname=winname(0,1)
	String list=TraceNameList(Wname,";",1)
   	 String TraceName
   	list=SortList(list,";",16)
   	Variable items=ItemsInList(list,";")
	String FTraceName="",TTraceName="",s
	Variable index=0,p2,m,Tracenum=0,i=0
	do
		TraceName=StringFromlist(index,list)
		p2=Strsearch(TraceName,"_e",inf,1)
		if (p2==-1)
			p2=Strsearch(TraceName,"_m",inf,1)
		endif
		if (p2==-1)
			abort
		endif
		TTraceName=traceName[0,p2-1]
		if (!!cmpstr(TTraceName,FTraceName))
			m+=1
			Tracenum=0
		endif
		Tracenum+=1
		index+=1
		FTraceName=TTraceName
	while (index<items)
	
	if ((items/m)!=tracenum)
		abort
	endif
	index=0
	do
	   TraceName=StringFromlist((index),list)
	   Wave Trace=TraceNameToWaveRef(Wname, TraceName)
	   display_wave(Trace,0,1) 
	   i=1
	   do
	   		if (i>=m)
	   			break
	   		endif
	   		TraceName=StringFromlist((i*tracenum+index),list)
	   		Wave Trace=TraceNameToWaveRef(Wname, TraceName)
	   		display_wave(Trace,1,1) 
	   i+=1
	   while (i<m)
	   //Execute "DifferentColors()"
       //Execute "DoUpdateLegend()"
	index+=1
	while (index<tracenum)
SetDatafolder DF
End

Function /S display_XYwave(data,xdata,appendflag,styleflag)
	Wave data,xdata
	Variable appendflag,styleflag

//sdc check here
	DFREF DF=GetDatafolderdfR()

	String graphname=winname(0,65)
	String wname,Xwname

	if (appendflag==0) //new window
		display /K=1
		String w_base,gN,w_df="root:graphsave:"
		w_df+="Others:"
		w_base="tTrace_"
				
		gN=uniquename(w_base,6,0)
		Dowindow /C $gN
		SetWindow $gN, hook(MyHook) = MygraphHook
		newDatafolder /o/s $(w_df+gN)
		
	elseif (appendflag==1) //self
	
		gN=winname(0,65)
		
		Wave data_gn=WaveRefIndexed(gN, 0, 1)
		if (WaveExists(data_gN)==0)
			Wave data_gn=ImageNameToWaveRef(gN,stringfromlist(0,ImageNameList(gN, ";")))
		endif
			
		w_df=GetWavesDatafolder(data_gn,1)
		SetDatafolder $w_df
	else //below
		gN=winname(1,65)
		
		Wave data_gn=WaveRefIndexed(gN, 0, 1)
		if (WaveExists(data_gN)==0)
			Wave data_gn=ImageNameToWaveRef(gN,stringfromlist(0,ImageNameList(gN, ";")))
		endif
			
		w_df=GetWavesDatafolder(data_gn,1)
		SetDatafolder $w_df	
	endif
	
		wname=nameofwave(Data)
		Xwname=nameofwave(XData)
		
		Checkdisplayed /W=$gN $wname
		
		if (V_Flag==0)
		
			duplicate /o data, $wname
			duplicate /o Xdata,$Xwname
		
			Wave data_plot=$wname
			Wave Xdata_plot=$Xwname
			AppendToGraph /W=$gN data_plot vs Xdata_plot
			
			if (styleflag==1)
				GP_standardstyle()
			endif
			
			SetDatafolder DF	
			return gN
		else
			SetDatafolder DF
			return ""
		endif	
	
//	
end




Function /S display_wave(data,appendflag,styleflag)
	Wave data
	Variable appendflag,styleflag
	
	print "function to be developed"
	
	DFREF DF=GetDatafolderdfR()

	String graphname=winname(0,65)
	String wname

	if (appendflag==0) //display
		display /K=1
		String w_base,gN,w_df="root:graphsave:"
		wname=nameofwave(data)
		switch(WaveDims(data))
		case 1:
			if (stringmatch(wname,"*_e_*"))
				w_df+="EDCs:"
				w_base="EDC_"
			elseif (stringmatch(wname,"*_m_*"))
				w_df+="MDCs:"
				w_base="MDC_"
			else
				w_df+="Others:"
				w_base=wname
			endif
		break
		case 2:
			if ((strsearch(wname,"FSM",0)>-1)||(strsearch(wname,"mapper",0)>-1))
				w_df+="FSMs:"
				w_base="FSM_"
			else
				w_df+="Images:"
				w_base="IMG_"
			endif
		break
		case 3:
			w_df+="Others:"
			w_base=wname
		endswitch
		gN=uniquename(w_base,6,0)
		Dowindow /C $gN
		SetWindow $gN, hook(MyHook) = MygraphHook
		newDatafolder /o/s $(w_df+gN)
		if (WaveDims(data)==3)
			Getlayerimage(data,dimsize(data,2)-1)
			Wave templayerimage
			Duplicate/o templayerimage $wname
			Killwaves /Z templayerimage
		else
			
			duplicate /o data, $wname
		endif
		Wave data_plot=$wname
		if (WaveDims(data)==1)
			AppendToGraph /W=$gN data_plot
		else
			Appendimage /W=$gN data_plot
		endif
		SetDatafolder DF
		if (styleflag==1)
			GP_standardstyle()
		endif
		return gN
	elseif (appendflag==1) //append self 
		gN=winname(0,65)
		Wave data_gn=WaveRefIndexed(gN, 0, 1)
		if (WaveExists(data_gN)==0)
			Wave data_gn=ImageNameToWaveRef(gN,stringfromlist(0,ImageNameList(gN, ";")))
		endif
			
		w_df=GetWavesDatafolder(data_gn,1)
		SetDatafolder $w_df
		
	elseif 	(appendflag==2)  //append below
		gN=winname(1,65)
		//String tracelist=tracenamelist(gN,";",1)
		//String tracename=stringfromlist(0,tracelist,";")
		Wave data_gn=WaveRefIndexed(gN, 0, 1)
		if (WaveExists(data_gN)==0)
			Wave data_gn=ImageNameToWaveRef(gN,stringfromlist(0,ImageNameList(gN, ";")))
		endif
			
		w_df=GetWavesDatafolder(data_gn,1)
		SetDatafolder $w_df
		
	endif
	
	wname=nameofwave(data)
	
	checkdisplayed /W=$gN $wname
		
	if (V_flag==0)
		duplicate /o data, $wname
		Wave data_plot=$wname
		if (WaveDims(data)==1)
			AppendToGraph /W=$gN data_plot
		else
			Appendimage /W=$gN data_plot
		endif
			
		if (styleflag==1)
			GP_standardstyle()
		endif
	
		SetDatafolder DF	
		return gn
	else	
		wname=uniquename(wname,1,0)
		
		duplicate /o data, $wname
		Wave data_plot=$wname
		if (WaveDims(data)==1)
			AppendToGraph /W=$gN data_plot
		else
			Appendimage /W=$gN data_plot
		endif
			
		if (styleflag==1)
			GP_standardstyle()
		endif
	
		SetDatafolder DF	
		return gn
	endif

end


Function GP_ApplyGraphHook()
	String wname=WinName(0,1)
	String Wlist,trname,GraphDF,GraphDFcmp
	Variable traceflag=1
	
	Wlist=tracenamelist(wname,";",1)
		if (strlen(wList)==0)
			Wlist=imagenamelist(wname,";")
			traceflag=0
		endif
		Variable index
		do
			trname=stringfromlist(index,Wlist,";")
			if (traceflag)
				Wave data=TracenametoWaveref(wname,trname)
			else
				Wave data=Imagenametowaveref(wname,trname)
			endif
			
			if (index==0)
				GraphDF=GetWavesDatafolder(data,1)
			else
				GraphDFcmp=GetWavesDatafolder(data,1)
				if (stringmatch(GraphDFcmp,GraphDF)==0)
					doalert 0,"Wave not in the same DF."
					return 0
				endif
			endif
		index+=1
		while (index<itemsinlist(Wlist))
	
	SetWindow $wname, hook(MyHook) = MygraphHook
End

Function GP_ReleaseGraphHook()
	String gN=WinName(0,1)

	if (strsearch(gN,"panel",0)!=-1)
		return 0
	endif

	String wname=gN
	prompt wname,"Name of the Graph"
	doprompt "Save Graph",wname
	if (V_flag)
		return 0
	endif
	SetWindow $gN, hook(MyHook) = $""
	Dowindow /T $gN,wname
end

Function GP_ConvertImageprocess()
	DFREF df=Getdatafolderdfr()
	
	String Wname=winname(0,1)
	Variable index=0
	Variable items
	String list=ImageNameList(Wname,";")
	if (Strlen(list)==0)
		Setdatafolder DF
		return 0
	endif
	
	initialdialogwindow()
	DFREF DF_userpanel=root:InternalUse:User_panel
	NVAR processallflag=DF_userpanel:gv_processallflag	
	NVAR autoprocessflag=DF_userpanel:gv_autoprocessflag
	SVAR suffix=DF_userpanel:gs_suffix
	SVAR new_wavename=DF_userpanel:gs_new_wavename
	
	String SaveWname,Savepath
	if (strsearch(Wname,"FSM",0)>=0)
		SaveWname=Wname
  		Savepath="FSMs"
  	elseif (strsearch(Wname,"IMG",0)>=0)
  		SaveWname=Wname
  		Savepath="Images"
  	else
  		SaveWname=Wname
  		Savepath="Others"
  	endif 
  		
  	SetDatafolder root:spectra//$Savepath
  	newDatafolder /o/s $savepath
  	
  	String DFfolder=SaveWname
  	prompt DFfolder,"Save Wave to Process: root:spectra:"+Savepath
  	DoPrompt "Save Datafolder",DFfolder
  	if (V_flag==1)
		SetDatafolder DF
		return 0
	endif
	
	DFfolder=RemoveEnding(DFfolder, ":")
		
	if (MakenewFolder(DFfolder)==0)
		//	DoAlert 0, "Sorry, "+DFfolder+" is no a legal DF name.\rPlease rename the folder!"
		SetDatafolder DF
		return 0
	endif
	
	savepath="root:spectra:"+savepath+":"+RemoveEnding(DFfolder, ":")
	
	String TraceName,WaveN,notestr,dwave_name
	Variable overwriteflag=1
 
   	list=SortList(list,";",16)
  	items=ItemsInList(list,";")
  	index=0
	do
		TraceName=StringFromlist(index,list)
		Wave Trace=ImageNameToWaveRef(Wname, TraceName)
		WaveN=nameofwave(trace)
		NoteStr=note(Trace)
		
		dwave_name=savepath+":"+WaveN
		do
		if (waveexists($dwave_name))
			if (processallflag==0)
				Setdialogwindow(winname(0,65),trace,"Proc")
				openautosavewindow(winname(0,65))
			else
				break
			endif
			
			switch (autoprocessflag)
			case 0:
				dwave_name=savepath
				overwriteflag=0
			break
			case 1:
				dwave_name=savepath+":"+WaveN
				overwriteflag=0
			break
			case 2:
				dwave_name=savepath+":"+WaveN+"_"+suffix
			break
			case 3:
				dwave_name=savepath+":"+new_wavename
			break
			endswitch
		else
			break
		endif
		while (overwriteflag)
		
		if (stringmatch(savepath,dwave_name)==0)
			newDatafolder /o/s $savepath
			Duplicate/o Trace $dwave_name
			Wave dataprc=$dwave_name
			InitialprocNotestr2D(dataprc,"rawData")
			//Note /K dataprc notestr
			redimension /N=(dimsize(trace,0),dimsize(trace,1),1) dataprc
		endif	
  	index+=1
  while (index<items)
 	
SetDatafolder Df
End



///////////// proc wave////////////////////////////

Function GP_CalBkgFromMin()
	DFREF df=Getdatafolderdfr()
	DFREF DFR_procwave=$(DFS_global+"proc_wave")
	String wname=winname(0,1)	
	
	String imagelist=ImageNameList(wname, ";")
	
	if (strlen(imagelist)>0)
		Variable savetype=1
		Variable meanpnts=10
		prompt savetype,"Proc Type",popup,"EDC;MDC;"
		prompt meanpnts,"Add pnts"
		doprompt "Save as proc wave",savetype,meanpnts
		if (V_flag)
			return 0
		endif
		Variable zn=itemsinlist(imagelist,";")
		
		Variable DCflag=(savetype==1)?(1):(0)
		
		Make /o/n=(zn)/free w_x0,w_x1,w_dx
		Variable yn=0
		
		variable index
		do 
			String imagename=stringfromlist(index,imagelist,";")
			Wave w_image=imageNameToWaveRef(wname, imagename)
			
			if (DCflag)
				w_x0[index]=M_y0(w_image)
				w_x1[index]=M_y1(w_image)
				w_dx[index]=abs(dimdelta(w_image,DCflag))
				yn+=dimsize(w_image,0)
			else
				w_x0[index]=M_x0(w_image)
				w_x1[index]=M_x1(w_image)
				w_dx[index]=abs(dimdelta(w_image,DCflag))
				yn+=dimsize(w_image,1)
			endif
			
			
			index+=1
		while (index<zn)
		
		Variable x0,x1,dx
		x0=min(wavemin(w_x0),wavemin(w_x1))
		x1=max(wavemax(w_x0),wavemax(w_x1))
		dx=wavemin(w_dx)
		
		Variable xn
		xn=round((x1-x0)/dx)+2	
		
		Make /o/free/n=(xn,yn) cubes
		Setscale /P x, x0,dx,cubes
		
		Variable Allindex=0
		index=0		
		do 
			imagename=stringfromlist(index,imagelist,";")
			Wave w_image=imageNameToWaveRef(wname, imagename)
			
			if (DCflag)
				cubes[][Allindex,Allindex+dimsize(w_image,0)-1]=w_image[q-Allindex](x)
				Allindex+=dimsize(w_image,0)
			else
				cubes[][Allindex,Allindex+dimsize(w_image,1)-1]=w_image(x)[q-Allindex]
				Allindex+=dimsize(w_image,1)
			endif
	
			index+=1
		while (index<zn)
		
		
		
		Make /o/free/n=(yn) tempwave
		
		Make /o/n=(xn) procwave
		Setscale /P x,x0,dx,procwave
				
		index=0
		do
			Multithread tempwave=cubes[index][p]
			sort /A tempwave,tempwave
			Variable tempvalue=sum(tempwave,0,meanpnts-1)/meanpnts
			
			procwave[index]=tempvalue
			index+=1
		while (index<dimsize(cubes,0))
		
		String notestr=""
		notestr+="imagelist="+imagelist+"\r"
		notestr+="meanpnts="+num2str(meanpnts)+"\r"
		notestr+="DCflag="+num2str(DCflag)+"\r"
		//if (DCflag)
		//	notestr+="Type=EDC\r"
		//else
		//	notestr+="Type=MDC\r"
		//endif
		
		note procwave,notestr
		
		display_wave(procwave,0,0)
		Killwaves /Z procwave
	endif
End

Function GP_SaveAsProcWaves()
	
	DFREF df=Getdatafolderdfr()
	DFREF DFR_procwave=$(DFS_global+"proc_wave")

	String wname=winname(0,1)	
	String tracelist=TraceNameList(wname, ";", 1 )
	
	variable normalflag=1
	
	if (strlen(tracelist)>0)
		Variable savetype=1
		variable selectwave=1
		prompt savetype,"Proc Type",popup,"EDC;MDC;"
		prompt selectwave,"Select Wave",popup,tracelist
		prompt normalflag,"Normalize?",popup,"No;Yes;"
		doprompt "Save as proc wave",selectwave,savetype,normalflag
		if (V_flag)
			return 0
		endif
		
		String tracename=stringfromlist(selectwave-1,tracelist,";")
		
		Wave procwave=TraceNameToWaveRef(wname, tracename)
		
		SetDatafolder DFR_procwave
		
		String procwavename=nameofwave(procwave)
		prompt procwavename,"Input proc wave name"
		Doprompt "Save as proc wave",procwavename
		if (strlen(procwavename)>25)
			procwavename=nameofwave(procwave)[0,24]
		endif
		
		procwavename=procwavename+"_proc"
		
		procwavename=Uniquename(procwavename,1,0)
		
		Duplicate /o procwave $procwavename
		String notestr=note(procwave)
		if (savetype==1)
			notestr+="\rType=EDC\r"
		else
			notestr+="\rType=MDC\r"
		endif
		Wave procwave=$procwavename
		note /K procwave
		note procwave,notestr
		
		if (normalflag==2)
			Wavestats /Q procwave
			procwave/=v_avg
		endif
		
		SetDatafolder DF
		return 0
	endif
	
	String imagelist=ImageNameList(wname, ";")
	
	if (strlen(imagelist)>0)
		selectwave=1
		prompt selectwave,"Select Wave",popup,imagelist
		prompt normalflag,"Normalize?",popup,"No;Yes;"
		doprompt "Save as proc wave",selectwave,normalflag
		if (V_flag)
			return 0
		endif
		
		String imagename=stringfromlist(selectwave-1,imagelist,";")
		
		Wave procwave=imageNameToWaveRef(wname, imagename)
		
		SetDatafolder DFR_procwave
		
		procwavename=nameofwave(procwave)
		prompt procwavename,"Input proc wave name"
		Doprompt "Save as proc wave",procwavename
		if (strlen(procwavename)>25)
			procwavename=nameofwave(procwave)[0,24]
		endif
		
		procwavename=Uniquename(procwavename,1,0)
		Duplicate /o procwave $procwavename
		notestr=note(procwave)
		notestr+="\rType=2D\r"
		Wave procwave=$procwavename
		note /K procwave
		note procwave,notestr
		
		if (normalflag==2)
			Wavestats /Q procwave
			procwave/=v_avg
		endif
	
		SetDatafolder DF
		return 0
	endif
End

Function GP_SaveGraphWaves()
	DFREF df=Getdatafolderdfr()
 
 //NewDatafolder/o/s root:GraphSave:Others
	String Wname=winname(0,1)
	Variable index=0
	Variable items
	String TraceName,NoteStr
	String SaveWname,Savepath
	if (strsearch(Wname,"FSM",0)>=0)
		SaveWname=Wname
  		Savepath="root:GraphSave:FSMs:"
  		SetDatafolder root:GraphSave:FSMs:
	elseif (strsearch(Wname,"EDC",0)>=0)
  		SaveWname=Wname
  		Savepath="root:GraphSave:EDCs:"
  		SetDatafolder root:GraphSave:EDCs:
	elseif (strsearch(Wname,"MDC",0)>=0)
  		SaveWname=Wname
  		Savepath="root:GraphSave:MDCs:"
  		SetDatafolder root:GraphSave:MDCs:
	elseif (strsearch(Wname,"IMG",0)>=0)
  		SaveWname=Wname
  		Savepath="root:GraphSave:Images:"
  		SetDatafolder root:GraphSave:Images:
	 else
  		SaveWname=Wname
  		Savepath="root:GraphSave:Others:"
  		SetDatafolder root:GraphSave:others:
	endif 
  	
  	if (Datafolderexists(Savewname))
  	Savewname=uniquename(Savewname,11,0)
  	endif
  
  	String DFfolder=Savewname
  	prompt DFfolder,"Save Wave to Datafolder: "+Savepath
  	DoPrompt "Save Datafolder",DFfolder
  	if (V_flag==1)
		SetDatafolder DF
		return 0
	endif
	
	//SetDatafolder root:
	
	DFfolder=RemoveEnding(DFfolder, ":")
	
	if (MakenewFolder(DFfolder)==0)
		//	DoAlert 0, "Sorry, "+DFfolder+" is no a legal DF name.\rPlease rename the folder!"
		SetDatafolder DF
		return 0
	endif
	
	savepath+=RemoveEnding(DFfolder, ":")
  
  	String list,WaveN
	 if (strlen(TraceNamelist(Wname,";",1)))
  		list=TraceNameList(Wname,";",1)
  		list=SortList(list,";",16)
  		items=ItemsInList(list,";")
  		index=0
  
  		do
  			TraceName=StringFromlist(index,list)
  			Wave Trace=TraceNameToWaveRef(Wname, TraceName)
  			Wave Xtrace=XWaveRefFromTrace(Wname, TraceName)
  			if (waveexists(Xtrace)==1)
  				Duplicate /o Xtrace,$(nameofwave(Xtrace))
  			endif
  			WaveN=nameofwave(trace)
  			//WaveN=UniqueName(WaveN, 1, 0)
  			NoteStr=note(trace)
  			Duplicate/o Trace $WaveN
  			Wave trace=$WaveN
 			note /K Trace notestr
  			index+=1
		 while (index<items)
 	 endif
 	 if (Strlen(ImageNamelist(wName,";")))
  		list=ImageNameList(Wname,";")
  		list=SortList(list,";",16)
  		items=ItemsInList(list,";")
  		index=0
 		do
 	 		TraceName=StringFromlist(index,list)
 	 		Wave Trace=ImageNameToWaveRef(Wname, TraceName)
 	 		WaveN=nameofwave(trace)
			NoteStr=note(Trace)
  			Duplicate/o Trace $WaveN
  			Wave Trace=$WaveN
  			Note /K Trace notestr
  			index+=1
 		while (index<items)
	  endif

	SetDatafolder Df
End



////////////////////wave set cmd/////////////////////



Function GP_MakeWaveset()
	String Wavesetname
	String gn=winname(0,65)
	
	String tracelist=TraceNameList(gn, ";", 1)
	if (strlen(tracelist)==0)
		tracelist=ImageNameList(gn, ";")
		if (strlen(tracelist)==0)
			doalert 0,"No Wave found."
			return 0
		else
			Variable dimflag=1
		endif
	else
		dimflag=0
	endif
	
	Variable tracenum=itemsinlist(Tracelist,";")
	Variable index=0
	String Wpathlist=""
	do
		String tracename=StringFromList(index, tracelist , ";")
		if (dimflag==0)
			Wave trace=TraceNameToWaveRef(gn, tracename)
		else
			Wave trace=imagenametowaveref(gn,Tracename)
		endif
		Wpathlist+=GetWavesdatafolder(trace,2)+";"
		index+=1
	while (index<tracenum)
	
	DFREF DF=GetDAtafolderDFR()
	DFREF DFR_global=$DF_global
	
	SetDatafolder DFR_global
	if (exists("WavesetNamelist")>0)
		SVAR /Z WavesetNamelist=DFR_global:WavesetNamelist
		prompt Wavesetname,WavesetNamelist+"\r Name of the Waveset:"
	else
		prompt Wavesetname,"Name of the Waveset:"
	endif
	
	//prompt Wavesetname,"Name of the Waveset:"
	Doprompt "Input the Name of the Waveset",Wavesetname
	if (V_flag==1)
		return 0
	else
		Save_WaveSet(WPathlist,Wavesetname,1)
	endif
	SetDatafolder DF
End


Function GP_WaveSetCommand()
	String Calcmdstr
	DFREF DF=GetDAtafolderDFR()
	DFREF DFR_global=$DF_global
	
	SVAR Wavesetlist=DFR_global:Wavesetlist
	
	SetDatafolder DFR_global
	if (exists("WavesetNamelist")>0)
		SVAR /Z WavesetNamelist=DFR_global:WavesetNamelist
		prompt Calcmdstr,WavesetNamelist+"\r Name of the Waveset:"
	else
		prompt Calcmdstr,"Name of the Waveset:"
	endif
	
	Doprompt "Input the Name of the Waveset",Calcmdstr
	if (V_flag==1)
		return 0
	else
		 Cal_WaveSet(Calcmdstr,WaveSetList,0)
	endif
	
	SetDatafolder DF
End




Function Check_experission(char) //for 0-9 a-z return 1 else 0
	String char
	
	if (GrepString(char,"[0-9]+"))
		return 1
	else
		if (GrepString(char,"[A-Za-z]"))
			return 1
		else
			return 0
		endif
	endif
End
Function Cal_WaveSet(Calcmdstr,WaveSetList,flag)
	String Calcmdstr
	String WaveSetList
	Variable flag
	
	DFREF DF=GetDatafolderDFR()
	DFREF DFR_global=$DF_global
	
	SetDatafolder DFR_global
	
	Variable index
	String char
	String Wavesetname=""
	String Wavesetnamelist=""
	String FinalCalstr=""
	calcmdstr+="$"
	do
		if (index<strlen(Calcmdstr))
			char=Calcmdstr[index]
		else
			break
		endif
		
		if  (Check_experission(char)==1)
			Wavesetname+=char
		else
			if (strlen(Wavesetname)>0)
				if (GrepString(Wavesetname,"[A-Za-z]")==1)
					if (strsearch(WaveSetList,Wavesetname,0)!=-1)
						Wavesetnamelist+=	Wavesetname+";"
						FinalCalstr+="#"+Wavesetname+"#"
					else
						FinalCalstr+=Wavesetname
					endif
				else
					FinalCalstr+=Wavesetname
				endif
			endif
			Wavesetname=""
			FinalCalstr+=char
		endif
		index+=1
	while (1)
	
	FinalCalstr=FinalCalstr[0,strlen(FinalCalstr)-2]
	
	Variable WaveSetnum=itemsinlist(Wavesetnamelist,";")
	if (WaveSetnum==0)
		return 0
	endif
	
	Variable wavenum=-1
	Variable Wavenum_max=-1
	
	index=0
	do
		Wavesetname=Stringfromlist(index,Wavesetnamelist,";")
		Variable findnum=strsearch(WaveSetList, Wavesetname+"=", 0)
		Variable findnum1=strsearch(WaveSetList, "\r", findnum)
		String Wpathlist=WaveSetList[findnum+strlen(Wavesetname)+1,findnum1-1]
		SListToWave(Wpathlist,0,";",Nan,Nan)
		Wave /T w_StringList
		Duplicate /o w_StringList,$Wavesetname
		Wave data=$Wavesetname
		if (wavenum==-1)
			wavenum=numpnts(data)
			Wavenum_max=wavenum
		else
			Wavenum=numpnts(data)
			if (wavenum>Wavenum_max)
				Wavenum_max=wavenum
			endif
		endif
		index+=1
	while (index<WaveSetnum)
	Killwaves/Z w_stringlist
	
	Make /o/T/n=(Wavenum_max) CalstrWave
	CalstrWave=Create_calstr(finalcalstr,p)
	
	index=0
	do
		string cmd=Calstrwave[index]
		print cmd
		Execute /Z cmd
		index+=1
	while (index<Wavenum_max)
	
	Killwaves /Z CalstrWave
	
	index=0
	do
		Wavesetname=Stringfromlist(index,Wavesetnamelist,";")
		
		Killwaves /Z $Wavesetname
		index+=1
	while (index<WaveSetnum)
	
	SetDatafolder DF
	return 1
End

Function /S Create_Calstr(finalcalstr,pathnum)
	String Finalcalstr
	Variable pathnum
	String calstr=Finalcalstr
	
	Variable temppos=0
	Variable temppos1=-1
	do
		temppos=strsearch(finalcalstr,"#",temppos1+1)
		temppos1=strsearch(finalcalstr,"#",temppos+1)
		
		if (temppos==-1)
			break
		endif
		
		String wavesetname=finalcalstr[temppos+1,temppos1-1]
		Wave /T data=$wavesetname
		if (pathnum>(numpnts(data)-1))
			pathnum=(numpnts(data)-1)
		endif
		calstr=ReplaceString("#"+wavesetname+"#", calstr, data[pathnum] ,1,1 )
	while (1)
	return calstr
End

Function Save_WaveSet(WPathlist,Setname,flag)
	String WPathlist
	String Setname
	Variable flag
	
	DFREF DF=GetDatafolderDFR()
	DFREF DFR_global=$DF_global
	
	SetDatafolder DFR_global
	String /G WaveSetList
	String /G WavesetNamelist
	
	String Savestr=Setname+"="+Wpathlist
	
	if (flag==1) //add waveset
		if (strlen(WaveSetlist)==0)
			WaveSetList=Savestr+"\r"
			WavesetNamelist=Setname+";"
		else
			Variable findnum=strsearch(WaveSetList, Setname+"=", 0)
			if (findnum!=-1)
				Variable findnum1=strsearch(WaveSetList, "\r", findnum)
				String findstr=WaveSetList[findnum,findnum1-1]
				findnum=WhichListItem(Savestr, WaveSetList  , "\r" )
				doalert 1, "Yes: Overwrite, No: Cancel"
				if (V_Flag==1)
					WaveSetList=RemoveListItem(findnum, WaveSetList,"\r")	
					WaveSetList=AddListItem(Savestr, WaveSetList,"\r", inf)
					WaveSetNamelist=RemoveListItem(findnum, WaveSetNamelist,";")	
					WaveSetNameList=AddListitem(Setname,WaveSetNamelist,";",inf)
				else
					SetDatafolder DF
					return 0
				endif
			else
				WaveSetList=AddListItem(Savestr, WaveSetList,"\r", inf)
				WaveSetNameList=AddListItem(Setname, WaveSetNameList,";", inf)
			endif	
		endif
	elseif (flag==0) //del
		findnum=strsearch(WaveSetList, Setname+"=", 0)
		if (findnum!=-1)
		 	findnum1=strsearch(WaveSetList, "\r", findnum)
			findstr=WaveSetList[findnum,findnum1-1]
			findnum=WhichListItem(findstr, WaveSetList  , "\r" )
			WaveSetList=RemoveListItem(findnum, WaveSetList,"\r")	
			WaveSetNamelist=RemoveListItem(findnum, WaveSetNamelist,";")	
		endif
	endif
	
	SetDatafolder DF
End



// SaveGraph 1.2
//
//	NOTE: As of Igor Pro 5, for most purposes, you should use the built-in SaveGraphCopy operation
//	instead of this procedure file.
//
//  Creates an Igor Text file that will be able to recreate the target graph (including the data)
//  in another experiment.
//
// To use, simply bring the graph you wish to save to the front and select "Save Graph"
// from the Macros menu.  You will be presented with a save dialog. 
// Later, in another experiment, you can use the "Load Igor Text..." item from the Data menu 
// to load the file. The data will be loaded and the graph will be regenerated. 
//
// "Save Graph" makes an Igor Text file that, when later loaded,  will load the data into a data folder
// of the same name as your graph.  If there are conflicts in the wave names, subfolders called
// data1 etc will be created for any subsequent waves.
//
// No data folders or waves are created by the Save Graph macros in the experiment where
// the graph was first created.  All new folders and waves are generated by loading the Igor
// Text file that recreates the graph.  The new folders and waves are in the destination experiment.
//
// NOTE:  The data folder hierarchy from the original experiment is not preserved by Save Graph.
//
// Version 1.2 supports commands in the graph recreation macro that exceed 256 characters.
// Version 1.1 differs from the first version as follows:
//	Supports Igor 3.0's Data Folders, liberal wave names
//	Supports contour and image graphs.

Function GP_SaveGraphtxt()
	DoSaveGraphToFile()
End
Function DoSaveGraphToFile()
	
	Variable numWaves
	Variable refnum
	Variable i
	Variable pos0, pos1
	Variable FolderLevel=1

	String TopFolder, FolderName
	String WinRecStr
	String fileName
	String wname=  WinName(0,1)
	
	if( strlen(wname) == 0 )
		DoAlert 0,"No graph!"
		return 0
	else
		DoWindow/F $wname
	endif
	
	TopFolder= wname
	
	
	GetWindow kwTopWin, wavelist
	Wave/T wlist=W_WaveList
	numWaves = DimSize(wlist, 0)
	
	Redimension/N=(-1,5) wlist
	
	MakeUniqueFolders(wlist, "data")
	
	Open/D refnum as wname
	filename=S_filename
	
	if (strlen(filename) == 0)
		DoAlert 0, "You cancelled the Save Graph operation"
		KillWaves/Z wlist
		return 0
	endif
	
	Open refnum as filename
	fprintf refnum, "%s", "IGOR\r"
	fprintf refnum, "%s", "X NewDataFolder/S/O "+TopFolder+"\r"
	close refnum
	
	i = 0
	do
		if (strlen(wlist[i][3]) != 0)
			Open/A refnum as filename
			if (FolderLevel > 1)
				fprintf refnum, "%s", "X SetDataFolder ::\r"
			endif
			fprintf refnum, "%s", "X NewDataFolder/S "+wlist[i][3]+"\r"
			FolderLevel=2
			close refnum
		endif
		Execute "Save/A/T "+wlist[i][1]+" as \""+FileName+"\""

		i += 1
	while (i < numWaves)

	if (FolderLevel > 1)
		Open/A refnum as filename
		fprintf refnum, "%s", "X SetDataFolder ::\r"
		close refnum
	endif

	WinRecStr = WinRecreation(wname, 2)
	i = 0
	FolderName = ""
	do
		pos0=0
		if (strlen(wlist[i][3]) != 0)
			FolderName = ":"+wlist[i][3]+":"
		endif
		do
			pos0=strsearch(WinRecStr, wlist[i][2], pos0+1)
			if (pos0 < 0)
				break
			endif
			WinRecStr[pos0,pos0+strlen(wlist[i][2])-1] = FolderName+PossiblyQuoteName(wlist[i][0])
	
		while (1)
		i += 1
	while (i<numWaves)
	
	Open/A refnum as filename
	
	pos0= strsearch(WinRecStr, "\r", 0)
	pos0= strsearch(WinRecStr, "\r", pos0+1)+1
	fprintf refnum,"X Preferences 0\r"
	String str
	do
		pos1= strsearch(WinRecStr, "\r", pos0)
		if( (pos1 == -1) %| (cmpstr(WinRecStr[pos0,pos0+2],"End") == 0 ) )
			break
		endif
//		fprintf refnum,"X%s%s",WinRecStr[pos0,pos1-1],";DelayUpdate\r"	// has 256 character limit
		str= "X"+WinRecStr[pos0,pos1-1]+";DelayUpdate\r"					// Version 1.2, 2/2/99
		FBinWrite refnum, str
		pos0= pos1+1
	while(1)
	
	fprintf refnum, "%s", "X SetDataFolder ::\r"
	fprintf refnum,"X Preferences 1\r"
	fprintf refnum,"X KillStrings S_waveNames\r"
	close refnum
	
	KillWaves/Z wlist
	return 0
	
end

Function MakeUniqueFolders(wlist, FBaseName)
	Wave/T wlist
	String FBaseName
	
	Variable i,j, endi = DimSize(wlist, 0), startj = 0
	Variable FolderNum = 0
	
	wlist[0][3] = ""
	
	i = 1
	do
	
		j = startj
		do
			if (cmpstr(wlist[i][0], wlist[j][0]) == 0)
				FolderNum +=1
				wlist[i][3] = FBaseName+num2istr(FolderNum)
				startj = i
				break
			endif
		
			j += 1
		while (j < i)
	
	
		i += 1
	while (i < endi)
end
	
	