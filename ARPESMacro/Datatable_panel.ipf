#pragma rtGlobals=1		// Use modern global access method.
#pragma version=0.01
#pragma ModuleName = Datapanel

////////////////open data table for a graph ////////////////////

Function GP_opendatatable()
	DFREF DF=GetDatafolderDFR()
	String wname=winname(0,1)
	
	if (stringmatch (wname,"*_panel*"))
		open_data_table("global_opdt")
	
	else
	
		String trlist=TraceNameList(Wname,";",1)
		String imglist=ImageNamelist(Wname,";")
	
		String trname,imgname
		
		String wavepathlist=""
		
		if (strlen(trlist)>0)
			Variable index=0
			do 
				trname=Stringfromlist(index,trlist,";")
				Wave /Z trace=TraceNametowaveref(wname,trname)
				if (waveexists(trace))
					wavepathlist+=GetWavesDatafolder(trace,2)+";"
				endif	
			index+=1
			while (index<itemsinlist(trlist,";"))
		endif
	
		if (strlen(imglist)>0)
			index=0
			do 
				imgname=Stringfromlist(index,imglist,";")
				Wave /Z Image=ImageNametowaveref(wname,trname)
				if (waveexists(Image))
					wavepathlist+=GetWavesDatafolder(Image,2)+";"
				endif	
			index+=1
			while (index<itemsinlist(imglist,";"))
		endif
	
		if (strlen(wavepathlist)>0)
			Open_datatb_Panel(wavepathlist,2)
		endif
	
	endif
	
	
		
End

///////////////////////////////////open data table with Datafolder //////

Function DF_opendatatable()
	DFREF DF=GetDatafolderDFR()
	
	Variable index=0
	String Oname,Oname1,win,OnameList
	String tracelist
	String tracename
	Variable m=0
	
	OnameList=MakeWlist()
	if (strlen(Onamelist)==0)
		SetDatafolder DF
		return 0
	endif
	
	string wavepathlist=""
	
	Oname=Stringfromlist(0,Onamelist)
	if (Waveexists($Oname)==0)
		 SetDatafolder $Oname
		 tracelist= WaveList("*", ";", "" )
		 if (strlen(tracelist)>0)
		 	do
		 		tracename=Stringfromlist(index,tracelist,";")
		 		Wave trace=$tracename
		 		wavepathlist+=GetWavesDatafolder(trace,2)+";"
		 		index+=1
		 	while (index<itemsinlist(tracelist,";"))
		 endif
		 if (strlen(wavepathlist)>0)
			Open_datatb_Panel(wavepathlist,1)
		endif
	else
		wavepathlist=Onamelist
		if (strlen(wavepathlist)>0)
			Open_datatb_Panel(wavepathlist,1)
		endif
	endif
End



Function/S MakeWlist()
	String Wlist="",wname
	String windowname=winname(0,2)
	Variable index
 	index=0
 	do
 		Wname=GetBrowserSelection(index)
 		if (strlen(Wname)==0)
 			break
 		endif
 		Wlist+=Wname+";"
 		index+=1
 	while(1)
 	return Wlist
   	//else
   	//return Wlist
   	//endif
End


/////////////////////////////open data table for panel commo////////////

Function open_data_table(ctrlname)
	String ctrlname
	String panelname=winname(0,65)
	String DF_panel="root:internalUse:"+panelName
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	
	Open_datatb_Panel(ctrlName,0)
End




/////////////////////////////////Datatable panel Function ////////////////////////////////////////


Function close_datatb_panel(ctrlname)
	String ctrlName
	String wname=winName(0,65)
	String DF_panel="root:internalUse:"+wname
	DFREF DFR_panel=$DF_panel
	NVAR killflag=DFR_panel:gv_killflag
	killflag=1
	dowindow/K $wname
End



Function Open_datatb_Panel(ctrlName,controlflag)
	String ctrlName
	Variable controlflag
	
	DFREF DF = GetDataFolderDFR()
	
	if (strsearch(ctrlname,";",0)>0)
		DFREF DFR_panel=Initial_datatb_Pathlist(ctrlname,controlflag) // for pathlist
	else 
		DFR_panel=Initial_datatb_Panelcommon() // for panelcommon of panels
	endif
	
	SetDatafolder DFR_panel
	
	Variable r=57000, g=57000, b=57000
	Variable SC=ScreenSize(5)
     	Button global_bt0,pos={410*SC,3*SC},size={80*SC,18*SC},title="close",labelBack=(r,g,b),proc=close_datatb_panel
     	Listbox global_lb0,pos={8*SC,180*SC},userColumnResize=1,size={980*SC,230*SC},mode=7,frame=2,listWave=DFR_panel:Listwave, selWave=DFR_panel:Listwavesel,titleWave=DFR_panel:titlewave,Proc=Datapanel#Datatable_Listbox_proc
     	TabControl Datatb,proc=Datapanel#datatb_AutoTab_proc, pos={8*SC,6*SC},size={480*SC,170*SC},value=0,labelBack=(r,g,b)//,widths={100*SC,50*SC}
   	 //widths={100*SC,50*SC}
      TabControl datatb,tabLabel(0)="SetVar"
      
     	Groupbox SetVar_gb4,frame=0,pos={30*SC,30*SC},size={330*SC,130*SC},title="Wave Note:"
     	Button SetVar_bt4, pos={40*SC,50*SC}, size={130*SC,40*SC},labelBack=(r,g,b),title="View & Edit (c)", Proc=Datapanel#Datatable_button_editandlock
     	Checkbox SetVar_ck0,pos={190*SC,50*SC}, size={130*SC,40*SC},labelBack=(r,g,b),title="Auto Write Log File?",variable=gv_autowritelogflag
     	Button SetVar_bt10, pos={190*SC,70*SC}, size={100*SC,20*SC},labelBack=(r,g,b),title="Clear Selection", Proc=Datapanel#Datatable_button_Clearselection
      
     	Button SetVar_bt8, pos={40*SC,110*SC}, size={130*SC,40*SC},labelBack=(r,g,b),title="Write Notes to Log File", Proc=UpdateExperiment_LogFile
     	//Button SetVar_bt10, pos={40*SC,110*SC}, size={130*SC,30*SC},labelBack=(r,g,b),title="Write Notes to Exp File", Proc=UpdateExperiment_LogFile
  
     	Button SetVar_bt9, pos={190*SC,110*SC}, size={65*SC,20*SC},labelBack=(r,g,b),title="Disp file", Proc=Datapanel#Datatable_button_Dispfiles
     	Button SetVar_bt11, pos={265*SC,110*SC}, size={80*SC,20*SC},labelBack=(r,g,b),title="update paths", Proc=Datapanel#Datatable_button_updatepaths
    
     	Button SetVar_bt7, pos={190*SC,130*SC}, size={155*SC,20*SC},labelBack=(r,g,b),title="Disp WaveNotes", Proc=Datapanel#Datatable_button_DispNotes
    
    	Groupbox SetVar_gb5,frame=0,pos={365*SC,30*SC},size={110*SC,130*SC},title="Auto Fill:"
    	SetVariable SetVar_sv0, pos={375*SC,50*SC},size={90*SC,15*SC},labelBack=(r,g,b),title="StartRow:",limits={0,inf,1}, variable = gv_startRow,limits={-Inf,Inf,0}
    	SetVariable SetVar_sv1, pos={375*SC,70*SC},size={90*SC,15*SC},labelBack=(r,g,b),title="EndRow:", limits={0,inf,1} ,variable = gv_endRow,limits={-Inf,Inf,0}
    	SetVariable SetVar_sv2, pos={375*SC,95*SC},size={90*SC,15*SC},labelBack=(r,g,b),title="AutoFill:", limits={-inf,inf,0},variable = gv_autofillstep,limits={-Inf,Inf,0}
    	
    	Button SetVar_bt12, pos={375*SC,116*SC}, size={90*SC,20*SC},labelBack=(r,g,b),title="x0 dx step Fill", Proc=Datapanel#Datatable_button_autofill
    	Button SetVar_bt13, pos={375*SC,138*SC}, size={90*SC,20*SC},labelBack=(r,g,b),title="x0 x1 Fill", Proc=Datapanel#Datatable_button_autofill
    
    
    	
    	
    	TabControl datatb,tabLabel(1)="Rename"
 	//   Groupbox Rename_gb0,frame=0,pos={20*SC,30*SC},size={400*SC,140*SC},disable=1,title="Rename with:"
    	Groupbox Rename_gb1,frame=0,pos={30*SC,30*SC},size={170*SC,70*SC},disable=1,title="Auto Rename with:"
    	PopupMenu Rename_pp1,pos={40*SC,50*SC},size={80*SC,15*SC},labelBack=(r,g,b),mode=1,disable=1,title="Auto with",value="Tem;PhotonE;theta;phi;azi;Index;"
      Button  Rename_bt0,pos={40*SC,73*SC},size={90*SC,20*SC},title="Auto_Rename",disable=1,Proc=Datapanel#DT_Wave_rename_panel
      
     	Groupbox Rename_gb2,frame=0,pos={30*SC,100*SC},size={170*SC,70*SC},disable=1,title="Rename with:"
   	SetVariable rename_sv1, pos={40*SC,120*SC}, disable=1,size={140*SC,15*SC},labelBack=(r,g,b),title="Add string", value = gs_AddStr,limits={-Inf,Inf,0}
    	Button  Rename_bt1,pos={40*SC,143*SC},size={90*SC,20*SC},title="Rename",disable=1,Proc=Datapanel#DT_Wave_rename_panel
      
    	Checkbox Rename_ck1,pos={240*SC,50*SC},size={80*SC,15*SC},title="suffix",value=1,disable=1,Proc=Datapanel#Proc_checkbox_rename
    	Checkbox Rename_ck2,pos={320*SC,50*SC},size={80*SC,15*SC},title="prefix",value=0,disable=1,Proc=Datapanel#Proc_checkbox_rename
    	Checkbox Rename_ck3,pos={240*SC,80*SC},size={80*SC,15*SC},title="basename",value=0,disable=1//,Proc=Datapanel#Proc_checkbox_basename
    	SetVariable rename_sv2, pos={320*SC,80*SC}, disable=1,size={140*SC,15*SC},labelBack=(r,g,b),title="BaseName", value = gs_BaseNameStr,limits={-Inf,Inf,0}
    
    
    	Button  Rename_bt2,pos={240*SC,110*SC},size={90*SC,20*SC},title="Undo",disable=1,Proc=Datapanel#DT_Wave_rename_undo
     	Button  Rename_bt3,pos={240*SC,140*SC},size={90*SC,20*SC},title="Reset",disable=1,Proc=Datapanel#DT_Wave_rename_undo
    
    	TabControl datatb,tabLabel(2)="Sort"
    
    	Groupbox Sort_gb1,frame=0,pos={20*SC,30*SC},size={190*SC,140*SC},disable=1,title="Auto Sort with:"
    	PopupMenu Sort_pp1,pos={30*SC,60*SC},size={70*SC,20*SC},labelBack=(r,g,b),mode=1,title="First:",disable=1,value="None;WaveN;suffix;Tem;PhotonE;Theta;Phi;Azi;",Proc=Datapanel#DataTableSort_pop
    	PopupMenu Sort_pp2,pos={30*SC,85*SC},size={70*SC,20*SC},labelBack=(r,g,b),mode=1,title="Second:",disable=1,value="None;WaveN;suffix;Tem;PhotonE;Theta;Phi;Azi;",Proc=Datapanel#DataTableSort_pop
    	PopupMenu Sort_pp3,pos={30*SC,110*SC},size={70*SC,20*SC},labelBack=(r,g,b),mode=1,title="Third:",disable=1,value="None;WaveN;suffix;Tem;PhotonE;Theta;Phi;Azi;",Proc=Datapanel#DataTableSort_pop
    	PopupMenu Sort_pp4,pos={30*SC,135*SC},size={70*SC,20*SC},labelBack=(r,g,b),mode=1,title="Forth:",disable=1,value="None;WaveN;suffix;Tem;PhotonE;Theta;Phi;Azi;",Proc=Datapanel#DataTableSort_pop
    	Checkbox Sort_ck0,pos={130*SC,60*SC},size={70*SC,20*SC},labelBack=(r,g,b),title="Reverse",value=0,disable=1,Proc=Datapanel#Proc_checkbox_reverse
    	NVAR gv_sw1,gv_sw2,gv_sw3,gv_sw4
     	gv_sw1=1
    	gv_sw2=1
     	gv_sw3=1
     	gv_sw4=1
     
     
     Groupbox Sort_gb2,frame=0,pos={220*SC,30*SC},size={160*SC,80*SC},disable=1,title="Manual Sort:"
     Button Sort_bt0,pos={240*SC,55*SC},size={90*SC,20*SC},title="Up",disable=1,Proc=Datapanel#DataTableSort_Manual
     Button Sort_bt1,pos={240*SC,80*SC},size={90*SC,20*SC},title="Down",disable=1,Proc=Datapanel#DataTableSort_Manual
     
    NVAR gv_controlflag
    if (gv_controlflag==0)
    		Button Sort_bt2,pos={230*SC,140*SC},size={140*SC,20*SC},title="Reorder Wave in Panel",disable=1,Proc=Datapanel#reorder_waves_in_Datafolder
    elseif (gv_controlflag==1)
    		Button Sort_bt2,pos={230*SC,140*SC},size={140*SC,20*SC},title="Reorder Wave in DF",disable=1,Proc=Datapanel#reorder_waves_in_Datafolder
    else
    		Button Sort_bt2,pos={230*SC,140*SC},size={140*SC,20*SC},title="Reorder Wave in Graph",disable=1,Proc=Datapanel#reorder_waves_in_Graph
    endif
    
    DFREF DFR_log=$(DF_global+":Data_log")
	
	Wave /T titleStrs=DFR_log:titleStrs
	Wave /T titleVars=DFR_log:titleVars
	Wave /T KeywordStrs=DFR_log:KeywordStrs
	Wave /T KeywordVars=DFR_log:KeywordVars
	
	Wave /T Datatable_display=DFR_log:Datatable_display
	Wave /T Datatable_left=DFR_log:Datatable_left
    
    	TabControl datatb,tabLabel(3)="Display"
    	Titlebox display_tb0,pos={20*SC,30*SC},size={100*SC,20*SC},title="Display:",frame=0,disable=1
    	Listbox display_lb0, pos={20*SC,50*SC},mode=1,size={100*SC,120*SC},listwave=Datatable_display,disable=1
    	Button display_bt0,pos={125*SC,50*SC},size={50*SC,20*SC},title="<--",disable=1,proc=Datapanel#proc_change_tb_display
    	Button display_bt1,pos={125*SC,75*SC},size={50*SC,20*SC},title="-->",disable=1,proc=Datapanel#proc_change_tb_display
    	Button display_bt2,pos={125*SC,100*SC},size={50*SC,20*SC},title="up",disable=1,proc=Datapanel#proc_change_tb_display
    	Button display_bt3,pos={125*SC,125*SC},size={50*SC,20*SC},title="down",disable=1,proc=Datapanel#proc_change_tb_display
    
    	Titlebox display_tb1,pos={180*SC,30*SC},size={100*SC,20*SC},title="Left:",frame=0,disable=1
    	Listbox display_lb1, pos={180*SC,50*SC},mode=1,size={100*SC,120*SC},listwave=Datatable_Left,disable=1
    
   	String DFS_panel=GetDatafolder(1)
    	groupbox display_gp0,pos={290*SC,30*SC},size={180*SC,140*SC},frame=0,title="Display graph",disable=1
    	//Titlebox display_tb2,pos={300*SC,50*SC},size={100*SC,20*SC},title="Display X Wave:",disable=1,frame=0
    	PopupMenu display_pp0,pos={300*SC,50*SC},size={100*SC,20*SC},title="Display X Wave:",disable=1,value=#(DFS_panel+"gs_popstr")
  	//  Titlebox display_tb3,pos={300*SC,100*SC},size={100*SC,20*SC},title="Display Y Wave:",disable=1,frame=0
   	PopupMenu display_pp1,pos={300*SC,90*SC},size={100*SC,20*SC},title="Display Y Wave:",disable=1,value=#(DFS_panel+"gs_popstr")
    
    	Button display_bt4,pos={300*SC,145*SC},size={70*SC,20*SC},title="Display",disable=1,proc=Datapanel#proc_tablepar_display
    
    	Button display_bt5,pos={380*SC,145*SC},size={70*SC,20*SC},title="Append",disable=1,proc=Datapanel#proc_tablepar_display
    
    	TabControl datatb, tablabel(4)="WaveSet"
    	Titlebox WaveSet_tb0,pos={20*SC,30*SC},size={100*SC,20*SC},title="WaveSets:",frame=0,disable=1
    	Listbox WaveSet_lb0, pos={20*SC,45*SC},mode=1,size={100*SC,100*SC},widths={120},listwave=WavesetNamelist_disp,disable=1,proc=Datapanel#Waveset_sel
    	Titlebox WaveSet_tb1,pos={230*SC,30*SC},size={150*SC,20*SC},title="WavePath:",frame=0,disable=1
    	Listbox WaveSet_lb1, pos={230*SC,45*SC},mode=1,size={200*SC,100*SC},widths={300},listwave=WavesetPathlist_disp,disable=1
    
    	Button Waveset_bt0,pos={130*SC,45*SC},size={70*SC,18*SC},title="Add Sets",disable=1,proc=Datapanel#Waveset_add
    	Button Waveset_bt1,pos={130*SC,70*SC},size={70*SC,18*SC},title="Del Sets",disable=1,proc=Datapanel#Waveset_add
    	
    	Button Waveset_bt2,pos={130*SC,105*SC},size={70*SC,18*SC},title="To Calcmd",disable=1,proc=Datapanel#Waveset_addcmd
    	
    	setvariable Waveset_Sv0,pos={20*SC,150*SC},size={330*SC,18*SC},title="Cmd",disable=1,variable=gs_calcmdstr
    	Button Waveset_bt3,pos={360*SC,150*SC},size={70*SC,18*SC},title="Cal cmd",disable=1,proc=Datapanel#Waveset_Calcmd
    	
    	
    	DefineGuide UGH0={FT,30*SC},UGH1={FT,160*SC}
    	DefineGuide UGH2={FR,-400*SC},UGH3={FR,-30*SC}
    	Display   /FG=(UGH2,UGH0,UGH3,UGH1)/Host=$winname(0,65) /N=DataTableInsetImage as "DataTableInsetImage"
    
   	 
   	 
    SetDatafolder DF
End







Function /DF Initial_datatb_Pathlist(pathslist,controlflag) ////////Load sepcial pathlist
	String pathslist
	Variable controlflag
	
	Variable SC = ScreenSize(5)
	Variable SR = ScreenSize(3)//* SC
	Variable ST = ScreenSize(2)// * SC
	Variable SL = ScreenSize(1)// * SC
    	Variable SB = ScreenSize(4)// * SC
	Variable Width = 1000 * SC		// panel size  
	Variable height = 410 * SC
	Variable xOffset = (SR-SL)/2-width/2
	Variable yOffset = 0//(SB-ST)/2-height/2
	DFREF DF=GetDatafolderDFR()
	
	Variable toplayernum=1
	Variable topprocnum=1
	Variable autolayerflag=0
	
	String panelname=winname(0,65)
	
	String panelnamelist=winlist("datatable_panel_*",";","WIN:65")
	if (strlen(panelnamelist)>0)
		Dowindow /K $Stringfromlist(0,panelnamelist)
	endif
	
	string spwinname=UniqueName("datatable_panel_", 9, 0)
 	NewPanel /W=(xOffset, yOffset,xOffset+width,Height+yOffset) as spwinname
	DoWindow/C $spwinname
    	Setwindow $spwinname hook(MyHook) = MypanelDelHook
    	
    	String DF_panel="root:internalUse:"+winname(0,65)
   	NewDataFolder/O/S $DF_panel
   	String /G gs_DFS_common=""
		
	DFREF DFR_panel=init_datatb_panel(Pathslist,toplayernum,topprocnum,autolayerflag,controlflag)
	
	if (controlflag==1) //databrowser
		SetDatafolder DFR_panel
		String /G gs_panelname="Data Browser"
	elseif  (controlflag==2) 
		SetDatafolder DFR_panel
		String /G gs_panelname=panelname
	endif
	
	SetDatafolder DF
	
	return DFR_panel
End

Function /DF Initial_datatb_Panelcommon() ////////////load pathlist from panel common////////////////
	Variable SC = ScreenSize(5)
	Variable SR = ScreenSize(3) //* SC
	Variable ST = ScreenSize(2) //* SC
	Variable SL = ScreenSize(1) //* SC
   	 Variable SB = ScreenSize(4) //* SC
	Variable Width = 1000 * SC		// panel size  
	Variable height = 410 * SC
	Variable xOffset = (SR-SL)/2-width/2
	Variable yOffset = 0//(SB-ST)/2-height/2
	
	DFREF DF=GetDatafolderDFR()
	String panelname=winname(0,65)
	String DFS_panel="root:internalUse:"+panelName
	String DFS_common="root:internalUse:"+panelName+":panel_common"
	DFREF DF_common=$DFS_common
	DFREF DFR_Opanel=$DFS_panel
	
	
		
	String panelnamelist=winlist("datatable_panel_*",";","WIN:65")
	if (strlen(panelnamelist)>0)
		Dowindow /K $Stringfromlist(0,panelnamelist)
	endif
	
	string spwinname=UniqueName("datatable_panel_", 9, 0)
	
 	NewPanel /W=(xOffset, yOffset,xOffset+width,Height+yOffset) as spwinname
	DoWindow/C $spwinname
   	Setwindow $spwinname hook(MyHook) = MypanelDataTableHook
   	
   	String DF_panel="root:internalUse:"+winname(0,65)
   	NewDataFolder/O/S $DF_panel
   	String /G gs_DFS_common=DFS_common
   	
   	Check_Autosimilar_layer(DF_common,0)
	
	WAVE/T w_sourcePathes = DF_common:w_sourcePathes
	
	String sourcePathlist=WavetoStringlist(w_sourcePathes,";",Nan,Nan)
	NVAR toplayernum=DF_common:gv_toplayernum
	NVAR topprocnum=DF_common:gv_topprocnum
	NVAR autolayerflag=DF_common:gv_autolayerflag
		
	DFREF DFR_panel=init_datatb_panel(sourcePathlist,toplayernum,topprocnum,autolayerflag,0)
	SetDatafolder DFR_panel
	String /G gs_panelname=panelname
	
	SetDatafolder DF
	
	return DFR_panel
End


//////////////////Read wave notes to different waves///////////////////

Function /DF init_datatb_panel(Wavepathlist,toplayernum,topprocnum,autolayerflag,controlflag)
 	//String DF_common
 	String Wavepathlist
	Variable toplayernum,topprocnum,autolayerflag
	Variable controlflag
	
	DFREF DF=GetDataFolderDFR()
	
   	String DF_panel="root:internalUse:"+winname(0,65)
 	DFREF DFR_panel=$DF_panel
 	SetDatafolder DFR_panel
 	
 	SVAR gs_DFS_common=gs_DFS_common
   
   	String Datalist=Wavepathlist
	
	Variable num=itemsinList(Datalist,";")
	
   	String notestr=""
	Variable index=0	
	String /G CopyFolderName
	Variable /G gv_killflag=0
	Variable /G gv_toplayernum=toplayernum
	Variable /G gv_autolayerflag=autolayerflag
	Variable /G gv_topprocnum=topprocnum
	Variable /G gv_controlflag=controlflag //////0 for panelcommon /////1 for DF ///////2 for graph
	Variable /G gv_sw1
	Variable /G gv_sw2
	Variable /G gv_sw3
	Variable /G gv_sw4
	Variable /G gv_dw=0
	
	Variable /G gv_startrow
	Variable /G gv_endrow
	
	Variable /G gv_autofillstep
	
	/////Waveset cmd///////
	
	Make /o/n=0 /T WaveSetnamelist_disp
	Make /o/n=0 /T WaveSetPathlist_disp
	
	String /G gs_Calcmdstr
	
	////wave info //////
	
	DFREF DFR_log=$(DF_global+":Data_log")
	
	Wave /T titleStrs=DFR_log:titleStrs
	Wave /T titleVars=DFR_log:titleVars
	Wave /T KeywordStrs=DFR_log:KeywordStrs
	Wave /T KeywordVars=DFR_log:KeywordVars
	
	Wave /T Datatable_display=DFR_log:Datatable_display
	Wave /T Datatable_left=DFR_log:Datatable_left
	
	String /G gs_popstr=WaveToStringList(Datatable_display,";",Nan,Nan)+WaveToStringList(Datatable_left,";",Nan,Nan)
	
	//Make /o/B/n=(numpnts(Datatable_display)) Datatable_dis_sel
	
	Variable /G gv_autowritelogflag=0
	
	Variable keyindex=0
	do
		
		make /T/o/n=(num) $(titlestrs[keyindex])//WaveInfoStrings[index]=Stringbykey(KeywordStrs[index],notestr,"=","\r")
		keyindex+=1
	while (keyindex<21)
	
	keyindex=0
	do
		make /o/n=(num) $(titleVars[keyindex])//WaveInfoVars[index]=Numberbykey(KeywordVars[index],notestr,"=","\r")
		keyindex+=1
	while (keyindex<43)
	
	
	index=0
	do 
	
		Wave data=$(Stringfromlist(index,Datalist,";"))
		
		if (wavedims(data)>2)
			Variable datalayernum=Autolayer_wavelist(data,toplayernum,topprocnum,autolayerflag)
		else
			datalayernum=0
		endif
		
		ReadDetailWaveNote(data,datalayernum,0)

		Wave WaveInfoVars
		Wave/T WaveInfoStrings
		DFREF DFR_prefs=$DF_prefs
		NVAR gv_chineseflag=DFR_prefs:gv_chineseflag
		
		keyindex=0
		do
			Wave /T Strdata=$(titlestrs[keyindex])
			if (stringmatch(titlestrs[keyindex],"Comment"))
				if (gv_chineseflag)
					Strdata[index]="\F'·ÂËÎ'"+WaveInfoStrings[Keyindex]
				else
					Strdata[index]=WaveInfoStrings[Keyindex]
				endif
				
			elseif (stringmatch(titlestrs[keyindex],"WaveN"))
				Strdata[index]=WaveInfoStrings[Keyindex]
				if (stringmatch(Strdata[index],nameofwave(data))!=1)
					Strdata[index]=nameofwave(data)
					notestr=note(data)
					notestr=replacestringbykey("WaveName",notestr,nameofwave(data),"=","\r")
					note /K data
					note data,notestr
				endif
			else
				Strdata[index]=WaveInfoStrings[Keyindex]
			endif
			keyindex+=1
		while (keyindex<21)
	
		keyindex=0
		do
			Wave Vardata=$(titleVars[keyindex])
			Vardata[index]=WaveInfoVars[Keyindex]
			keyindex+=1
		while (keyindex<43)
	index+=1
	while (index<(num))
   
   
   	String /G gs_BaseNameStr
   	String /G gs_AddStr
   	String /G gs_liststr=WaveToStringList(Datatable_display,";",Nan,Nan)
   	//"WaveN;theta;thetaoff;phi;phioff;azi;azioff;gammaa;tem;Polarization;PhotonE;WorkFn;FermiN;Sweeps;PassE;EnergyScale;Estep;lowEnergy;highEnergy;Sdate;Stime;comment;"
  	
  	if (waveexists(Listwavesel)==0)
  		Make /o/T /n=(1,1) Listwave
   		Make /o /n=(1,1) Listwavesel
  		Make /o/T /n=1 titleWave
  	endif
   
	
   
   	WavesToListWave(DFR_panel,gs_liststr,Listwave,Listwavesel,titlewave)
     
  	SetDatafolder DF
   	return DFR_panel
End





Function ReadDetailWaveNote(tImage,toplayernum,outputflag)
	wave tImage
	Variable toplayernum
	Variable outputflag
	
	String dataname
	
	dataname=GetWavesDataFolder(timage,2)//Stringfromlist(index,Datalist,";")
	//Wave data=$dataname[index]
	String notestr=note(timage)
	
	DFREF DFR_log=$(DF_global+":Data_log")
	
	Wave /T titleStrs=DFR_log:titleStrs
	Wave /T titleVars=DFR_log:titleVars
	Wave /T KeywordStrs=DFR_log:KeywordStrs
	Wave /T KeywordVars=DFR_log:KeywordVars
	
	
	Make /T/o/n=21 WaveInfoStrings
	Make /o/n=44 WaveInfoVars

	WaveInfoStrings[0]=dataname
	
	Variable index
	String keyword
	
	index=1
	do
		WaveInfoStrings[index]=Stringbykey(KeywordStrs[index],notestr,"=","\r")
		index+=1
	while (index<19)
	
	index=0
	do
		WaveInfoVars[index]=Numberbykey(KeywordVars[index],notestr,"=","\r")
		index+=1
	while (index<41)
	
	WaveInfoVars[43]=Numberbykey(KeywordVars[43],notestr,"=","\r")
		
	//////////////Get the Fermi energy and initial flag for perticular layer//////////////
	Variable FermiN, initialflag
	
	if (numtype(toplayernum)==2)
		String notestrFermi=notestr
	else
		notestrFermi=Getlayernotestr(Notestr,toplayernum,0)
	endif
	//print notestrFermi
	initialflag=numberbykey_reverse("initialflag",notestrFermi,"=","\r")
	
	String EnergyScale=WaveInfoStrings[16]
	Variable photonE=WaveInfoVars[20]
	Variable WorkFn=WaveInfoVars[21]
	
	if (numtype(initialflag)==2) //// did not find initial flag, use energy scale photonE workfn
		if (stringmatch(EnergyScale,"Initial"))
			initialflag=1
		else
			initialflag=0
		endif
		FermiN=PhotonE-WorkFn
	else
		if (initialflag==1)
			FermiN=numberbykey_reverse("FermiEnergy",notestrFermi,"=","\r")
		else
			FermiN=PhotonE-WorkFn
		endif	
	endif	
	
	
	WaveInfoVars[41]=FermiN
	WaveInfoVars[42]=Initialflag
	/////////////////////// dispersion wave, tmf wave///////
	
	Variable  str0
	
	String tmfpath=Stringbykey("tmfwave",notestr,"=","\r")
	str0=strsearch(tmfpath,":",inf,1)
	if (str0>=0)
		String tmfname=tmfpath[str0+1,inf]
	else
		tmfname=""
	endif
			
	String disppath=Stringbykey("dispwave",notestr,"=","\r")
	str0=strsearch(disppath,":",inf,1)
	if (str0>=0)
		String dispname=disppath[str0+1,inf]
	else
		dispname=""
	endif
					
	WaveInfoStrings[19]=tmfname
	WaveInfoStrings[20]=dispname
	
	if (outputflag==1)// output wavenotes for panel
		Make /T/o/n=6 WaveInfoL
		Make /o/n=15 WaveVars
		
		String filename=WaveInfoStrings[3]
		Variable PassE=WaveInfoVars[16]
		Variable Estep=WaveInfoVars[27]*1000
		Variable sweeps=WaveInfoVars[17]
		Variable tem=WaveInfoVars[19]
		Variable theta=WaveInfoVars[32]
		Variable thetaoff=WaveInfoVars[33]
		Variable phi=WaveInfoVars[34]
		Variable phioff=WaveInfoVars[35]
		Variable azi=WaveInfoVars[36]
		Variable azioff=WaveInfoVars[37]
		Variable gammaA=WaveInfoVars[8]
		String comment=WaveInfoStrings[17]
		Variable innerE=WaveInfoVars[7]
		Variable DeflectorY = WaveInfoVars[43]
		workfn=WaveInfoVars[21]
		
		String analslit=WaveInfoStrings[9]
		Variable curveflag=0
		if (Strsearch(analslit,"c",0)!=-1)
			curveflag=1
		endif
		
		
		String line0
		sprintf line0,"Waveinfo: %s, %geV %gmeV, %g sweeps",filename,PassE,Estep,sweeps
		
		String line1
		sprintf line1,"PhotonE=%geV, EF=%g, T=%gK",photonE,FermiN,Tem
		
		String line2
		sprintf line2,"Theta \f01%g\f00(\f01%g\f00), Phi \f01%g\f00(\f01%g\f00), Azi \f01%g\f00(\f01%g\f00),DflY \f01%g\f00,Gm \f01%g\f00",(theta),(thetaoff),(phi),(phioff),(azi),(azioff),DeflectorY,gammaa
		
		String line3
		sprintf line3,"TMF: %s, Disp: %s", tmfname,dispname
		
		String line4="Comments: "
		
		DFREF DFR_pref=$DF_prefs
		NVAR /Z gv_chineseflag=DFR_pref:gv_chineseflag
		
		if (gv_chineseflag)
			line4="Comments: \F'·ÂËÎ'"
		endif
		
		index=0
		String tempstr
		do 
			tempstr=stringfromlist(index,comment,";")
			if ((strsearch(tempstr,"T=",0,2)>-1)||(strsearch(tempstr,"theta",0,2)>-1)||(strsearch(tempstr,"phi",0,2)>-1))
			else
				if (strlen(tempstr)>0)
					if (index==0)
						line4+=tempstr
					else
						line4+=", "+tempstr
					endif
				endif		
			endif				
			index+=1
		while (index<itemsinlist(comment,";"))
		
//		if (strlen(line4)>40)
//			line4=line4[0,40]
//		endif
		
		WaveInfoL[0]=line0
		WaveInfoL[1]=line1
		WaveinfoL[2]=line2
		WaveinfoL[3]=line3
		WaveinfoL[4]=line4
		WaveVars[0]=theta
		WaveVars[1]=thetaoff
		WaveVars[2]=phi
		WaveVars[3]=phioff
		WaveVars[4]=azi
		WaveVars[5]=azioff
		WaveVars[6]=photonE
		WaveVars[7]=FermiN
		WaveVars[8]=InnerE
		WaveVars[9]=gammaa
		WaveVars[10]=initialflag
		WaveVars[11]=workfn
		WaveVars[12]=curveflag
		WaveVars[13]=tem
		WaveVars[14]=DeflectorY
		killWaves /Z WaveInfoStrings,WaveinfoVars
		
		return 1
	endif

End



static function proc_tablepar_display(ctrlname)
	String ctrlname
	
	DFREF DF=GetdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
     
    // 	SetDatafolder DFR_panel
     	controlinfo display_pp0
     	String XwaveN=S_Value
     	controlinfo display_pp1
     	String YwaveN=S_Value
     	
     	Wave Xwave=DFR_panel:$XwaveN
     	Wave Ywave=DFR_panel:$YwaveN
  	
  	if (stringmatch(ctrlname,"display_bt4"))
  		display_XYwave(Ywave,Xwave,0,0)
  	elseif (stringmatch(ctrlname,"display_bt5"))
  		display_XYwave(Ywave,Xwave,2,0)
  	endif
	
End


/////////////////change datatable display//////////////

static function proc_change_tb_display(ctrlname)
	String ctrlname
	
	DFREF DFR_log=$(DF_global+":Data_log")
	
	//Wave /T titleStrs=DFR_log:titleStrs
	//Wave /T titleVars=DFR_log:titleVars
	//Wave /T KeywordStrs=DFR_log:KeywordStrs
	//Wave /T KeywordVars=DFR_log:KeywordVars
	
	Wave /T Datatable_display=DFR_log:Datatable_display
	Wave /T Datatable_left=DFR_log:Datatable_left
	
	controlinfo display_lb1
	Variable leftrow=V_Value
	controlinfo display_lb0
	Variable displayrow=V_Value
	
	String leftstring=Datatable_left[leftrow]
	String dispstring=Datatable_display[displayrow]
	
	if (stringmatch(Ctrlname,"display_bt0")) ///add display
		
		deletepoints leftrow,1,Datatable_left
		InsertPoints displayrow,1,Datatable_display
		Datatable_display[displayrow]=leftstring
	elseif (stringmatch(Ctrlname,"display_bt1")) // remove display
		deletepoints displayrow,1,Datatable_display
		InsertPoints leftrow,1,Datatable_left
		Datatable_left[leftrow]=dispstring
	elseif (stringmatch(Ctrlname,"display_bt2"))  //up
		if (displayrow>0)
			Datatable_display[displayrow]=Datatable_display[displayrow-1]
			Datatable_display[displayrow-1]=dispstring
			Listbox display_lb0,selrow=displayrow-1
		endif
	elseif (stringmatch(Ctrlname,"display_bt3"))  //down
		if (displayrow<(numpnts(Datatable_display)-1))
			Datatable_display[displayrow]=Datatable_display[displayrow+1]
			Datatable_display[displayrow+1]=dispstring
			Listbox display_lb0,selrow=displayrow+1
		endif
	endif 
	
	DFREF DF=GetdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
     
     	SetDatafolder DFR_panel
     	
     	SVAR gs_liststr
   	gs_liststr=WaveToStringList(Datatable_display,";",Nan,Nan)
   	//"WaveN;theta;thetaoff;phi;phioff;azi;azioff;gammaa;tem;Polarization;PhotonE;WorkFn;FermiN;Sweeps;PassE;EnergyScale;Estep;lowEnergy;highEnergy;Sdate;Stime;comment;"
  	
  	//if (waveexists(Listwavesel)==0)
  	//	Make /o/T /n=(1,1) Listwave
   	//	Make /o /n=(1,1) Listwavesel
  	//	Make /o/T /n=1 titleWave
  	//endif
   	Wave /T Listwave,titleWave
   	Wave /B Listwavesel
	
   
   	WavesToListWave(DFR_panel,gs_liststr,Listwave,Listwavesel,titlewave)
   	
   	SetDatafolder DF
	
	return 0
End


//////////////////////Wave notes to listwave making tables//////////////////////

Static Function returnListboxwidth(data,factor)
	Wave data
	
	variable factor
	
	if (WaveType(data)>0)
		Make /o/T/Free/n=(numpnts(data)) datastr
		datastr=num2str(data[p])
	else
		duplicate /o/T/Free data, datastr
	endif
	
	Variable maxwidth=strlen(datastr[0])
	
	Variable index
	do
		Variable cmpwidth=strlen(datastr[index])
		if (cmpwidth>maxwidth)
			maxwidth=cmpwidth
		endif
		index+=1
	while (index<numpnts(datastr))
	
	Variable width=maxwidth*factor
	if (width<40)
		width=35
	endif
	if (width>200)
		width=200
	endif
	return width
	
End

//Listbox global_lb0,pos={8*SC,180*SC},userColumnResize=1,size={980*SC,230*SC},mode=7,frame=2,widths={100*SC,50*SC},listWave=DFR_panel:Listwave, selWave=DFR_panel:Listwavesel,titleWave=DFR_panel:titlewave,Proc=Datapanel#Datatable_Listbox_proc
     

Static Function WavesToListWave(DF_data,Waveslist,Listwave,Listwavesel,titlewave)
	DFREF DF_data
	String WavesList
	Wave /T Listwave
	Wave Listwavesel
	Wave /T titlewave
	
	DFREF DF=GetDataFolderDFR()
	SetDatafolder DF_data
	
	String gn=winname(0,65)
	if (strsearch(gn,"datatable",0)==-1)
		 gn=winname(1,65)
	endif
	
	Variable SC=ScreenSize(5)

	String wavesname
	wavesname=stringfromlist(0,Waveslist,";")
	Wave /T data1=$Wavesname

	redimension /N=((numpnts(data1)),itemsinlist(waveslist)) Listwave,Listwavesel
	redimension /N=(itemsinlist(waveslist)) titleWave
	Variable index
	do 
		wavesname=stringfromlist(index,Waveslist,";")
	
		titlewave[index]=wavesname//nameofwave(data)
		if (WaveType($Wavesname,1)==1)
			Wave data=$Wavesname
			Listwave[][index]=num2str(data[p])
			Variable listboxwidth=returnListboxwidth(data,8)
		else
			wave /T data1=$Wavesname
			Listwave[][index]=data1[p]
			listboxwidth=returnListboxwidth(data1,8)
		endif
		
		if (index==0)
			Listbox global_lb0,win=$gn,widths={listboxwidth*SC}
		else
			Listbox global_lb0,win=$gn,widths+={listboxwidth*SC}
		endif
		index+=1
	while (index<itemsinlist(waveslist))
	//Listwavesel=0
	SetDatafolder DF
End


////////////////////////Edit var panel function////////////////////////////////


Function /C ListWavesel_to_rowandcol(ListWavesel, dimflag,controlflag)
	Wave Listwavesel
	Variable dimflag
	Variable controlflag //0 zero selection// 1 alert zero selection
	
	Variable index,V_startrow,V_endrow,Selwidth,tempsum
	 
	duplicate /o listwavesel,tempsel
	V_startrow=-1
	V_endrow=-1
		
	if (wavemax(tempsel)>1)
		tempsel-=2
	endif	
		
	tempsel=(tempsel<0)?(0):(tempsel)
	
	if (dimflag==0)
		make /o/n=(dimsize(tempsel,1)) tempsel1
		index=0
		Selwidth=-1
		do
			tempsel1=tempsel[index][p]
			tempsum=sum(tempsel1)
			if ((selwidth==-1)&&(tempsum>0))
				V_startrow=index
				selwidth=0
			endif
			if (tempsum>0)
				selwidth+=1
			endif
			
			if ((tempsum==0)&&(selwidth>0))
				V_endrow=index-1
				break
			endif				
		index+=1
		while (index<(dimsize(tempsel,0)))
	else
		make /o/n=(dimsize(tempsel,0)) tempsel1
		index=0
		Selwidth=-1
		do
			tempsel1=tempsel[p][index]
			tempsum=sum(tempsel1)
			if ((selwidth==-1)&&(tempsum>0))
				V_startrow=index
				selwidth=0
			endif
			if (tempsum>0)
				selwidth+=1
			endif
			
			if ((tempsum==0)&&(selwidth>0))
				V_endrow=index-1
				break
			endif				
		index+=1
		while (index<(dimsize(tempsel,1)))
	
	endif
		
	V_startrow=(V_startrow==-1)?(0):(V_startrow)
	if (V_endrow==-1)
		V_endrow=(dimflag)?(dimsize(tempsel,1)-1):(dimsize(tempsel,0)-1)
	endif

	if (selwidth>(V_endrow-V_startrow+1))
		doalert 0, "Multi section selection."
	endif
	
	Killwaves /Z tempsel1,tempsel
			
	
	if (controlflag)
		if (selwidth==-1)
			doalert 0, "No section selected."
			return cmplx(Nan,Nan)
		else
			return cmplx(V_startrow,V_endrow)
		endif
	else
		return cmplx(V_startrow,V_endrow)
	endif
End

static Function init_val_FromNotewavelist(startrow,endrow)
	Variable startrow,endrow
	
	DFREF DFR_log=$(DF_global+":Data_log")
	
	Wave /T titleStrs=DFR_log:titleStrs
	Wave /T titleVars=DFR_log:titleVars
	Wave /T KeywordStrs=DFR_log:KeywordStrs
	Wave /T KeywordVars=DFR_log:KeywordVars
	
	
	Variable index
	String Notewavename,Notevalname
	index=0
	do
		Notewavename=titleVars[index]
		Wave data=$NoteWavename
		notevalname="gv_"+notewavename
		Variable /G $notevalname=CheckReturnWaveequal(data,startrow,endrow)
		index+=1
	while(index<43)	
	
	index=0
	do
		Notewavename=titleStrs[index]
		wave /T data1=$NoteWavename
		notevalname="gs_"+notewavename
		String /G $notevalname=CheckReturnStringequal(data1,startrow,endrow)
		if (stringmatch(Notewavename,"Comment"))
			SVAR SComment= $notevalname
			SComment=SComment[8,inf]
		endif
		
		index+=1
	while(index<21)
	
End


static Function init_editandlock(DFR_panel,startrow,endrow)
	DFREF DFR_panel
	Variable startrow,endrow
	
	DFREF DF=GetdatafolderDFR()
	SetDatafolder DFR_panel
	
	Variable /G gv_startrow=startrow
	Variable /G gv_endrow=endrow
	
	Init_val_fromNotewavelist(startrow,endrow)
  	 
  	 String/G gs_theta,gs_phi,gs_azi
  	 Wave theta,phi,azi
  	 
  	 gs_theta=FormatanglefromWave(theta,startrow,endrow)
  	 gs_phi=FormatanglefromWave(phi,startrow,endrow)
  	 gs_azi=FormatanglefromWave(azi,startrow,endrow)

	Wave /T WaveN
	
	String/G gs_EditWaveList=WaveToStringList(WaveN,",",startrow,endrow)
	gs_EditWaveList=removeending(gs_EditWaveList,",")

  	 SetDatafolder DF
End


static Function Datatable_button_Clearselection(ctrlname)
	String ctrlname
	DFREF DF=GetdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
     
	Wave listwavesel=DFR_panel:listwavesel
	
	Listwavesel=0
End

static Function Datatable_button_autofill(ctrlname)
	String ctrlname
	
	DFREF DF=GetdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	
	Wave listwavesel=DFR_panel:listwavesel
	
	Variable /C selectposition=ListWavesel_to_rowandcol(listwavesel,1,1)
	
	Variable startcol=real(selectposition)
	Variable endcol=imag(selectposition)
	
	if (numtype(startcol)==2)
		return 0
	endif
	
	DFREF DFR_data=$(DF_global+":Data_log")
	
	Wave /T Datatable_display=DFR_data:Datatable_display
	
	NVAR gv_startrow=DFR_panel:gv_startrow
	NVAR gv_endrow=DFR_panel:gv_endrow
	
	NVAR gv_autofillstep=DFR_panel:gv_autofillstep
	
	
	Variable index=startcol
	do
		Wave tablewave=DFR_panel:$Datatable_display[index]
		Variable tempstart=tablewave[gv_startrow]
		if (stringmatch(ctrlname,"SetVar_bt12"))
			Variable tempstep=gv_autofillstep
		else
			tempstep=(gv_autofillstep-tempstart)/(gv_endrow-gv_startrow)
		endif
		variable waveindex=gv_startrow
		
		if (gv_startrow<gv_endrow)
			do
				tablewave[waveindex]=tempstart+(waveindex-gv_startrow)*tempstep
				waveindex+=1
			while (waveindex<(gv_endrow+1))
		else
			do
				tablewave[waveindex]=tempstart+(gv_startrow-waveindex)*tempstep
				waveindex-=1
			while (waveindex>(gv_endrow-1))
		endif
	
		index+=1
	while (index<(endcol+1))
	
	Datatable_updateListwave()
	notewave_to_datanote()
end


static Function Datatable_button_editandlock(ctrlname)
	String ctrlname

	DFREF DF=GetdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
     
	Wave listwavesel=DFR_panel:listwavesel
	
	Variable /C selectposition=ListWavesel_to_rowandcol(listwavesel,0,0)
	
	Variable startrow=real(selectposition)
	Variable endrow=imag(selectposition)
	
	Init_editandlock(DFR_panel,startrow,endrow)
	open_editVars_panel(DFR_panel, startrow,endrow)
	
	SetDatafolder DF	
End

Static Function open_editVars_panel(DFR_panel,startrow,endrow)
	DFREF DFR_panel
	Variable startrow,endrow
	
	DFREF DF=GetDAtafolderdfr()

	SetDatafolder DFR_panel
	
	Variable /G Multieditflag=endrow-startrow
	String graphname=winname(0,65)
	
	Variable SC= Screensize(5)
	
	Variable SR = ScreenSize(3) //* SC
	Variable ST = ScreenSize(2)// * SC
	Variable SL = ScreenSize(1)//* SC
       Variable SB = ScreenSize(4)
    
    	Variable Width = 515*SC 	// panel size  
	Variable height = 500*SC
	
	Variable xOffset = (SR-SL)/2-width/2
	Variable yOffset = (SB-ST)/2-height/2
	NewPanel /K=2 /W=(xoffset, yoffset,xOffset+width,Height+yOffset) as "Pause for Edit Variables"
	DoWindow/K/Z  PauseforEditVars		
	DoWindow/C PauseforEditVars					// Set to an unlikely name
	
	Variable r=57000, g=57000, b=57000
	
	Button Complete, pos={20*SC,465*SC},size={230*SC,30*SC}, title="Complete",proc=DataPanel#EditVars_close
	Button Cancel, pos={270*SC,465*SC},size={230*SC,30*SC}, title="Cancel",proc=DataPanel#EditVars_close
	
	TabControl Datatb,proc=Datapanel#datatb_AutoTab_proc, pos={8*SC,10*SC},size={500*SC,450*SC},value=0,labelBack=(r,g,b)
    
      TabControl datatb,tabLabel(0)="SetVar"
      
      titlebox Wavenamedisp,frame=0,pos={140*SC,10*SC},size={120*SC,20*SC},variable=gs_EditWaveList
      
     // Usefulinfo_
	Groupbox SetVar_gb1,frame=0,pos={250*SC,35*SC},size={120*SC,100*SC},title="global Angle offset:"
	SetVariable SetVar_sv10, pos={260*SC,55*SC}, size={100*SC,15*SC},labelBack=(r,g,b),title="theta_off", value = gv_thetaoff,limits={-Inf,Inf,0}
	SetVariable SetVar_sv11, pos={260*SC,80*SC}, size={100*SC,15*SC},labelBack=(r,g,b),title="phi_off", value = gv_phioff,limits={-Inf,Inf,0}
	SetVariable SetVar_sv12, pos={260*SC,105*SC}, size={100*SC,15*SC},labelBack=(r,g,b),title="azi_off", value = gv_azioff,limits={-Inf,Inf,0}
	
	Groupbox SetVar_gb2,frame=0,pos={380*SC,35*SC},size={120*SC,100*SC},title="global Manipulator:"
	SetVariable SetVar_sv13, pos={390*SC,55*SC}, size={100*SC,15*SC},labelBack=(r,g,b),title="X", value = gv_maniX,limits={-Inf,Inf,0}
	SetVariable SetVar_sv14, pos={390*SC,80*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="Y", value = gv_maniY,limits={-Inf,Inf,0}
	SetVariable SetVar_sv15, pos={390*SC,105*SC}, size={80*SC,15*SC},labelBack=(r,g,b),title="Z", value = gv_maniZ,limits={-Inf,Inf,0}
	
	Groupbox SetVar_gb3,frame=0,pos={20*SC,35*SC},size={220*SC,100*SC},title="Manipulator Angle:"
	SetVariable SetVar_sv16, pos={30*SC,55*SC}, size={200*SC,15*SC},labelBack=(r,g,b),title="Theta", value = gs_theta,proc=DataPanel#AutoFill_angle
	SetVariable SetVar_sv17, pos={30*SC,80*SC}, size={200*SC,15*SC},labelBack=(r,g,b),title="Phi", value = gs_phi,proc=DataPanel#AutoFill_angle
	SetVariable SetVar_sv18, pos={30*SC,105*SC}, size={200*SC,15*SC},labelBack=(r,g,b),title="Azi", value = gs_azi,proc=DataPanel#AutoFill_angle
	//Button SetVar_bt0, pos={30*SC,130*SC}, size={100*SC,20*SC},labelBack=(r,g,b),title="Set to All ", Proc=Datapanel#SetVarToAll
	
	
   	Groupbox SetVar_gb4,frame=0,pos={20*SC,140*SC},size={170*SC,80*SC},title="global Experiment paremeter:"
	SetVariable SetVar_sv21, pos={30*SC,165*SC}, size={95*SC,15*SC},labelBack=(r,g,b),title="Slit gamma", value = gv_gammaA,limits={-Inf,Inf,0}
   	PopupMenu SetVar_pp1,pos={130*SC,163*SC},size={90*SC,15*SC},labelBack=(r,g,b),mode=1,title="",value="None;0;90;", Proc=DataPanel#SetGamma
	SetVariable SetVar_sv22, pos={30*SC,195*SC}, size={95*SC,15*SC},labelBack=(r,g,b),title="Anal slit", value = gs_AnalyzerSlit,limits={-Inf,Inf,0} 
      PopupMenu SetVar_pp2,pos={130*SC,193*SC},size={70*SC,15*SC},labelBack=(r,g,b),mode=1,title="",value="None;0.5s;0.5c;0.3s;0.3c;0.2s;0.2c",Proc=DataPanel#Setanaslit
  	
  	
  	
	Groupbox SetVar_gb5,frame=0,pos={200*SC,140*SC},size={300*SC,140*SC},title="Data Experiment paremeter:"
	SetVariable SetVar_sv23, pos={210*SC,165*SC}, size={90*SC,15*SC},labelBack=(r,g,b),title="Region", value = gs_Region,limits={-Inf,Inf,0}
	SetVariable SetVar_sv24, pos={305*SC,165*SC}, size={90*SC,15*SC},labelBack=(r,g,b),title="Date", value = gs_SDate,limits={-Inf,Inf,0}
	SetVariable SetVar_sv25, pos={400*SC,165*SC}, size={90*SC,15*SC},labelBack=(r,g,b),title="Time", value = gs_STime,limits={-Inf,Inf,0}
	SetVariable SetVar_sv26, pos={210*SC,195*SC}, size={120*SC,15*SC},labelBack=(r,g,b),title="LensMode", value = gs_LensMode,limits={-Inf,Inf,0}
	SetVariable SetVar_sv27, pos={335*SC,195*SC}, size={95*SC,15*SC},labelBack=(r,g,b),title="AcMode", value = gs_AcMode,limits={-Inf,Inf,0}
	PopupMenu SetVar_pp3,pos={435*SC,193*SC},size={70*SC,15*SC},labelBack=(r,g,b),mode=1,title="",value="None;Swept;Fix;Dithered",Proc=DataPanel#SetAcMode
  	SetVariable SetVar_sv28, pos={210*SC,225*SC}, size={120*SC,15*SC},labelBack=(r,g,b),title="EnergyScale", value = gs_EnergyScale,limits={-Inf,Inf,0}
	PopupMenu SetVar_pp4,pos={335*SC,223*SC},size={70*SC,15*SC},labelBack=(r,g,b),mode=1,title="",value="None;Kinetic;Initial",Proc=DataPanel#SetEnergyScale
  	SetVariable SetVar_sv29, pos={210*SC,255*SC}, size={120*SC,15*SC},labelBack=(r,g,b),title="PassE", value = gv_PassE,limits={-Inf,Inf,0}
  	SetVariable SetVar_sv30, pos={335*SC,255*SC}, size={120*SC,15*SC},labelBack=(r,g,b),title="Sweeps", value = gv_sweeps,limits={-Inf,Inf,0}
  	
	Groupbox SetVar_gb6,frame=0,pos={20*SC,225*SC},size={170*SC,130*SC},title="BeamLine paremeter:"
	SetVariable SetVar_sv31, pos={30*SC,245*SC}, size={90*SC,15*SC},labelBack=(r,g,b),title="PhotonE", value = gv_PhotonE,limits={-Inf,Inf,0}
	SetVariable SetVar_sv33, pos={125*SC,245*SC}, size={60*SC,15*SC},labelBack=(r,g,b),title="Wf", value = gv_WorkFn,limits={-Inf,Inf,0}
	SetVariable SetVar_sv32, pos={30*SC,270*SC}, size={100*SC,15*SC},labelBack=(r,g,b),title="Polarization", value = gs_Polarization,limits={-Inf,Inf,0}
	PopupMenu SetVar_pp5,pos={130*SC,268*SC},size={60*SC,15*SC},labelBack=(r,g,b),mode=1,title="",value="None;Mix;LH;LV;C+;C-;",Proc=DataPanel#SetPolar
	
	SetVariable SetVar_sv34, pos={30*SC,295*SC}, size={120*SC,15*SC},labelBack=(r,g,b),title="BeamCurrent", value = gv_BeamCurrent,limits={-Inf,Inf,0}
	SetVariable SetVar_sv35, pos={30*SC,320*SC}, size={95*SC,15*SC},labelBack=(r,g,b),title="Area Intensity", value = gv_AreaI,limits={-Inf,Inf,0}
	
	Groupbox SetVar_gb7,frame=0,pos={200*SC,285*SC},size={300*SC,70*SC},title="Sample paremeter:"
	SetVariable SetVar_sv37, pos={210*SC,305*SC}, size={140*SC,15*SC},labelBack=(r,g,b),title="SampleOrientation", value = gv_SampleOrientation,limits={-Inf,Inf,0} 
	SetVariable SetVar_sv36, pos={360*SC,305*SC}, size={130*SC,15*SC},labelBack=(r,g,b),title="Inner Potential(eV)", value = gv_InnerE,limits={-Inf,Inf,0} 
  	SetVariable SetVar_sv38, pos={210*SC,330*SC}, size={100*SC,15*SC},labelBack=(r,g,b),title="Temperature", value = gv_Tem,limits={-Inf,Inf,0} 
	
  	Groupbox SetVar_gb8,frame=0,pos={20*SC,365*SC},size={480*SC,70*SC},title="Comments:"
   //Button SetVar_bt1, pos={160*SC,130*SC}, size={100*SC,20*SC},labelBack=(r,g,b),title="Set to All ",Proc=Datapanel#SetVarToAll
   	DFREF DFR_prefs=$DF_prefs
   	NVAR gv_chineseflag=DFR_prefs:gv_chineseflag
   	if (gv_chineseflag)
		titlebox SetVar_tb41,pos={30*SC,410*SC}, size={465*SC,15*SC},labelBack=(r,g,b),font="·ÂËÎ",variable=gs_Comment,limits={-Inf,Inf,0},frame=0
	endif
	SetVariable 	SetVar_sv41,pos={30*SC,390*SC}, size={465*SC,15*SC},labelBack=(r,g,b),title=" ", value = gs_Comment,limits={-Inf,Inf,0}
	
	
	TabControl datatb,tabLabel(1)="Detail"
	
	Groupbox Detail_gb1,frame=0,pos={20*SC,35*SC},size={250*SC,130*SC},title="Sample:",disable=1
	SetVariable Detail_sv10, pos={30*SC,55*SC}, size={100*SC,15*SC},labelBack=(r,g,b),title="Sample", value = gs_sample,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv11, pos={30*SC,80*SC}, size={100*SC,15*SC},labelBack=(r,g,b),title="LatticeA", value = gv_LatticeA,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv12, pos={30*SC,105*SC}, size={100*SC,15*SC},labelBack=(r,g,b),title="LatticeB", value = gv_LatticeB,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv13, pos={30*SC,130*SC}, size={100*SC,15*SC},labelBack=(r,g,b),title="LatticeC", value = gv_LatticeC,limits={-Inf,Inf,0},disable=1
	
	NVAR gv_LatticeType=DFR_panel:gv_LatticeType
	PopupMenu Detail_pp6,pos={150*SC,55*SC},size={100*SC,15*SC},labelBack=(r,g,b),mode=(gv_LatticeType),title="type:",value="Simple;BCC;FCC;TCC",Proc=DataPanel#SetBZtype,disable=1

	//SetVariable Detail_sv14, pos={150*SC,55*SC}, size={100*SC,15*SC},labelBack=(r,g,b),title="LatticeType", value = gv_LatticeType,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv15, pos={150*SC,80*SC}, size={100*SC,15*SC},labelBack=(r,g,b),title="Alpha", value = gv_LatticeAlpha,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv16, pos={150*SC,105*SC}, size={100*SC,15*SC},labelBack=(r,g,b),title="Beta", value = gv_LatticeBeta,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv17, pos={150*SC,130*SC}, size={100*SC,15*SC},labelBack=(r,g,b),title="Gamma", value = gv_LatticeGamma,limits={-Inf,Inf,0},disable=1
	
	Groupbox Detail_gb2,frame=0,pos={280*SC,35*SC},size={220*SC,130*SC},title="Instrument:",disable=1
	SetVariable Detail_sv18, pos={300*SC,55*SC}, size={140*SC,15*SC},labelBack=(r,g,b),title="User", value = gs_user,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv19, pos={300*SC,80*SC}, size={140*SC,15*SC},labelBack=(r,g,b),title="Instrument", value = gs_Instrument,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv20, pos={300*SC,105*SC}, size={140*SC,15*SC},labelBack=(r,g,b),title="Software", value = gs_measurementsoftware,limits={-Inf,Inf,0},disable=1
	
	
	Groupbox Detail_gb3,frame=0,pos={20*SC,175*SC},size={180*SC,200*SC},title="SES Parameters:",disable=1
	SetVariable Detail_sv21, pos={30*SC,195*SC}, size={140*SC,15*SC},labelBack=(r,g,b),title="YChannel0", value = gv_fychannel,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv22, pos={30*SC,220*SC}, size={140*SC,15*SC},labelBack=(r,g,b),title="YChannel1", value = gv_lychannel,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv23, pos={30*SC,245*SC}, size={140*SC,15*SC},labelBack=(r,g,b),title="XChannel0", value = gv_fxchannel,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv24, pos={30*SC,270*SC}, size={140*SC,15*SC},labelBack=(r,g,b),title="XChannel1", value = gv_lxchannel,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv25, pos={30*SC,295*SC}, size={140*SC,15*SC},labelBack=(r,g,b),title="Degree per Channel", value = gv_DegreeperChannel,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv26, pos={30*SC,320*SC}, size={140*SC,15*SC},labelBack=(r,g,b),title="eV per Channel", value = gv_evperchannel,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv27, pos={30*SC,345*SC}, size={140*SC,15*SC},labelBack=(r,g,b),title="DwellTime", value = gv_DwellTime,limits={-Inf,Inf,0},disable=1
	
	Groupbox Detail_gb4,frame=0,pos={220*SC,175*SC},size={280*SC,200*SC},title="Range Parameters:",disable=1
	SetVariable Detail_sv31, pos={230*SC,195*SC}, size={120*SC,15*SC},labelBack=(r,g,b),title="LowEnergy", value = gv_LowEnergy,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv32, pos={230*SC,220*SC}, size={120*SC,15*SC},labelBack=(r,g,b),title="HighEnergy", value = gv_HighEnergy,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv33, pos={230*SC,245*SC}, size={120*SC,15*SC},labelBack=(r,g,b),title="NumEnergy", value = gv_numEnergy,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv34, pos={230*SC,270*SC}, size={120*SC,15*SC},labelBack=(r,g,b),title="EnergyStep", value = gv_Estep,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv35, pos={370*SC,195*SC}, size={120*SC,15*SC},labelBack=(r,g,b),title="FirstSlice", value = gv_Firstslice,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv36, pos={370*SC,220*SC}, size={120*SC,15*SC},labelBack=(r,g,b),title="LastSlice", value = gv_lastslice,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv37, pos={370*SC,245*SC}, size={120*SC,15*SC},labelBack=(r,g,b),title="NumSlices", value = gv_numslices,limits={-Inf,Inf,0},disable=1
	SetVariable Detail_sv38, pos={370*SC,270*SC}, size={120*SC,15*SC},labelBack=(r,g,b),title="DegreeStep", value = gv_Degreeslices,limits={-Inf,Inf,0},disable=1
	
	PauseForUser  PauseforEditVars//,$graphName
	
	
	SetDatafolder DF
End


Static Function EditVars_close(ctrlname)
	String ctrlname
	strswitch(ctrlname)
	case "Complete":
		EditVars_write_note()	
		Datatable_updateListwave()
		notewave_to_datanote()
		//datatonote_listwave()
		break
	case "Cancel":
		break
	endswitch
	
	DoWindow/K PauseforEditVars	
End


static Function AutoFill_angle (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	DFREF DF=GetdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(1,65)
	DFREF DFR_panel=$DF_panel
	
	NVAR gv_startrow=DFR_panel:gv_Startrow
	NVAR gv_endrow=DFR_panel:gv_endrow
	SVAR gs_theta=DFR_panel:gs_theta
	SVAR gs_phi=DFR_panel:gs_phi
	SVAR gs_azi=DFR_panel:gs_azi
	
	String tempstr
	Variable startval,deltaval,endval
	
	Variable  tempos=strsearch(varStr,	",",0)
	
	if (tempos==-1)
		 tempos=strsearch(varStr,	"_",0)
		 if (tempos==-1)
		 	tempos=strsearch(varStr,	";",0)
		 	if (tempos==-1)
		 		Variable tempval=str2num(varStr)
		 		if (numtype(tempval)==2)
		 			return 1
		 		else
		 			startval=tempval
		 			deltaval=0
		 		endif
		 	else
		 		return 1
		 	endif		 	
		 else
		 	sscanf varstr,"%g_%g",startval,endval
		 	deltaval= (endval-startval)/(gv_endrow-gv_startrow)
		 endif
	else
		sscanf varstr,"%g,%g",startval,deltaval	 
	endif
	
	tempstr=""
	variable index=0
	do
		tempstr+=num2str(startval+deltaval*index)+";"
		 index+=1
	while (index<(gv_endrow-gv_Startrow+1))
	
	strswitch(ctrlname)
	case "SetVar_sv16":
		gs_theta=tempstr
		break
	case "SetVar_sv17":
		gs_phi=tempstr
		break
	case "SetVar_sv18":
		gs_azi=tempstr
		break
	endswitch
		
End

static Function SetEnergyScale (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	
	String DF_panel="root:internalUse:"+winname(1,65)
    	DFREF DFR_panel=$DF_panel
    //	print DF_panel
    	SVAR gs_EnergyScale=DFR_panel:gs_EnergyScale
    	
    	//NVAR gv_gammaA=DFR_panel:gv_gammaA
    	if (popnum==1)
   	 	gs_EnergyScale=""
   	 else
   	 	gs_EnergyScale=popstr
   	 endif
End


static Function SetAcmode (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	
	String DF_panel="root:internalUse:"+winname(1,65)
    	DFREF DFR_panel=$DF_panel
    //	print DF_panel
    	SVAR gs_Acmode=DFR_panel:gs_Acmode
    	if (popnum==1)
   	 	gs_Acmode=""
   	 else
   	 	gs_Acmode=popstr
   	 endif
End

static Function SetGamma (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	
	String DF_panel="root:internalUse:"+winname(1,65)
    	DFREF DFR_panel=$DF_panel
    //	print DF_panel
    	NVAR gv_gammaA=DFR_panel:gv_gammaA
	if (popnum==1)
		gv_gammaA=NAN
	else
		gv_gammaA=str2num(popstr)
	endif
End

static Function Setanaslit (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	
	String DF_panel="root:internalUse:"+winname(1,65)
	DFREF DFR_panel=$DF_panel
	SVAR gs_AnalyzerSlit=DFR_panel:gs_AnalyzerSlit   
	if (popnum==1)
		gs_AnalyzerSlit=""
	else
		gs_AnalyzerSlit=popstr
	endif
End

static Function SetPolar (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	
   	String DF_panel="root:internalUse:"+winname(1,65)
  	DFREF DFR_panel=$DF_panel
   	SVAR gs_Polarization=DFR_panel:gs_Polarization 
	if (popnum==1)  
   		gs_Polarization=""
    	 else
 		gs_Polarization=popstr
    	endif
End

static Function SetBZtype (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	
   	String DF_panel="root:internalUse:"+winname(1,65)
   	DFREF DFR_panel=$DF_panel
   	DFREF DFR_global=$DF_global
   
   	NVAR gv_LatticeType=DFR_panel:gv_LatticeType
   
   	NVAR gV_LatticeA=DFR_panel:gV_LatticeA
   	NVAR gV_LatticeB=DFR_panel:gV_LatticeB
   	NVAR gV_LatticeC=DFR_panel:gV_LatticeC
   
   	NVAR gV_Latticealpha=DFR_panel:gv_Latticealpha
   	NVAR gv_Latticebeta=DFR_panel:gv_Latticebeta
   	NVAR gv_Latticegamma=DFR_panel:gv_Latticegamma
   	Variable temp1,temp2
          
   	if (popnum>1)
   		if  ((gV_Latticealpha!=90)||(gv_Latticebeta!=90)||(gv_Latticegamma!=90))
   			doalert 0, "angle must be 90"  
   			PopupMenu Detail_pp6,mode=1
   			gv_LatticeType=1
   		else
   			gv_LatticeType=popnum
   		endif
   	endif	 
   		   
   	gv_LatticeType=popnum
   
End


/////////////////////write Variable to note////////////////


Function EditVars_write_note()
	
	DFREF DF=GetdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(1,65)
    	DFREF DFR_panel=$DF_panel
	SetDatafolder DFR_panel
	
	NVAR gv_startrow=DFR_panel:gv_startrow
	NVAR gv_endrow=DFR_panel:gv_endrow
	
	Write_val_fromNotewavelist(gv_startrow,gv_endrow)
	
	SVAR gs_theta,gs_phi,gs_azi
  	
  	Wave theta,phi,azi
  	 
  	FormatangletoWave(gs_theta,theta,gv_startrow,gv_endrow)
  	FormatangletoWave(gs_phi,phi,gv_startrow,gv_endrow)
  	FormatangletoWave(gs_azi,azi,gv_startrow,gv_endrow)
  	 
	SetDatafolder DF
End

Function formatangletowave(notestr,data,startrow,endrow)
	String notestr
	Wave data
	Variable startrow,endrow
	
	
	Wave w_NumberList=StringListToNumWave(notestr,0,";",Nan,Nan)
	data[startrow,endrow]=w_NumberList[p-startrow]
	Killwaves /Z w_NumberList
End


Function Write_val_fromNotewavelist(startrow,endrow)
	Variable startrow,endrow
	
	DFREF DFR_log=$(DF_global+":Data_log")
	
	Wave /T titleStrs=DFR_log:titleStrs
	Wave /T titleVars=DFR_log:titleVars
	Wave /T KeywordStrs=DFR_log:KeywordStrs
	Wave /T KeywordVars=DFR_log:KeywordVars
	
	
	Variable index
	String Notewavename,Notevalname
	index=0
	do
		Notewavename=titleVars[index]
		Wave data=$NoteWavename
		notevalname="gv_"+notewavename
		NVAR noteval=$notevalname
		if (numtype(noteval)!=2)
			data[startrow,endrow]=noteval
		endif
		index+=1
	while(index<43)	
	
	index=0
	do
		Notewavename=titleStrs[index]
		
		wave /T data1=$NoteWavename
		notevalname="gs_"+notewavename
		SVAR notestr=$notevalname
			if (strlen(notestr)>0)
				if (stringmatch(Notewavename,"Comment"))
					data1[startrow,endrow]="\F'·ÂËÎ'"+notestr
				else
					data1[startrow,endrow]=notestr
				endif
			endif
		index+=1
	while(index<21)

End

static Function Datatable_updateListwave()
	DFREF DF=GetdatafolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
 	 DFREF DFR_panel=$DF_panel
  
 	 SVAR gs_liststr=DFR_panel:gs_liststr
  	Wave /T Listwave=DFR_panel:Listwave
  	Wave Listwavesel=DFR_panel:Listwavesel
  	Wave /T titlewave=DFR_panel:titlewave
  
  	WavesToListWave(DFR_panel,gs_liststr,Listwave,Listwavesel,titlewave)

	SetDatafolder DF
End

static Function notewave_to_datanote()
	DFREF DF = GetDataFolderDFR()
 	String DF_panel="root:internalUse:"+winname(0,65)
 	DFREF DFR_panel=$DF_panel
 	 
 	SetDatafolder DFR_panel 
 	
 	DFREF DFR_log=$(DF_global+":Data_log")
	
	Wave /T titleStrs=DFR_log:titleStrs
	Wave /T titleVars=DFR_log:titleVars
	Wave /T KeywordStrs=DFR_log:KeywordStrs
	Wave /T KeywordVars=DFR_log:KeywordVars
 	
 	Wave /T dataname
 	
	Variable keyindex
	String Notewavename,Notevalname
	
 	 String M=""	
	 String notestr
	 Variable index = 0
	 do
		M =Dataname[index]
		Wave temp=$M
		notestr = note(temp)
		Note/K temp
		
		keyindex=0 // miss Fermi Eenrgy Initialflag
		do
			Notewavename=titleVars[keyindex]
			Wave data=$NoteWavename
			notestr=replacenumberbykey(KeywordVars[Keyindex],notestr,data[index],"=","\r")
			keyindex+=1
		while(keyindex<41)	
	
		keyindex=1 //miss dataname
		do
			Notewavename=titleStrs[keyindex]
			wave /T data1=$NoteWavename
			if (stringmatch(Notewavename,"Comment"))
					String commenttemp=data1[index]
					
					//print commenttemp,commenttemp[8,inf]
					notestr=replaceStringbykey(KeywordStrs[Keyindex],notestr,commenttemp[8,inf],"=","\r")
			else
					notestr=replaceStringbykey(KeywordStrs[Keyindex],notestr,data1[index],"=","\r")
			endif
			
			keyindex+=1			
		while(keyindex<19)

		Note temp, notestr
		Write_to_log_Datafolder(temp)
	       index += 1
	  while (index < numpnts(Dataname))
	  
	 NVAR gv_autowritelogflag=DFR_panel:gv_autowritelogflag
	
	if (gv_autowritelogflag)
		UpdateExperiment_LogFile("dummy")
	endif
 	SetDatafolder DF	
	
End


static Function Write_to_log_Datafolder(data)
	Wave data
	DFREF DF=GetDatafolderDFR()
	
	DFREF DFR_global=$DF_global
	SetDatafolder DFR_global
	newDatafolder /o/s Data_Log
	DFREF DFR_log=GetDatafolderDFR()
	
	Wave /T titleStrs=DFR_log:titleStrs
	Wave /T titleVars=DFR_log:titleVars
	Wave /T KeywordStrs=DFR_log:KeywordStrs
	Wave /T KeywordVars=DFR_log:KeywordVars

	
	ReadDetailWaveNote(data,Nan,0)
	Wave /T WaveInfoStrings
	Wave WaveInfoVars
	
	String filenamestr=WaveInfoStrings[3]
	String filePathstr=WaveInfoStrings[4]
	String RawWaveNamestr=WaveInfoStrings[2]
	
	if (waveexists(filename))
		Wave /T filename
		Wave /T filePath
		Wave /T RawwaveN
		Wave /T WaveInfoStringsList
		Wave  WaveInfoVarsList
		
		Variable filepos= SearchStringInWave(filename,filenamestr)
		Variable WaveNpos= SearchStringInWave(RawwaveN,RawWaveNamestr)
		
		if (filepos>-1)
			if  (WaveNpos>-1)
				filename[WaveNpos]=filenamestr
				RawWaveN[WaveNpos]=RawWaveNamestr
				filePath[WaveNpos]=filePathstr
				WaveInfoStringsList[WaveNPos][]=WaveInfoStrings[q]
				WaveInfoVarsList[WaveNPos][]=WaveInfoVars[q]
				
				SetDatafolder DF
				return 1
			endif
		endif
	endif
	SetDatafolder DF
End




//////////////////////write log file function//////////////////////

Function UpdateExperiment_LogFile(ctrlname)
	String ctrlname
	DFREF DF = GetDataFolderDFR()

	DFREF DFR_global=$DF_global
	SetDatafolder DFR_global
	newDatafolder /o/s Data_Log
	DFREF DFR_log=GetDatafolderDFR()
	
	Wave /T titleStrs=DFR_log:titleStrs
	Wave /T titleVars=DFR_log:titleVars
	Wave /T KeywordStrs=DFR_log:KeywordStrs
	Wave /T KeywordVars=DFR_log:KeywordVars
	
	Wave /T Datatable_display=DFR_log:Datatable_display
	Wave /T Datatable_left=DFR_log:Datatable_left
	
	String temptitle_disp=WaveToStringList(Datatable_display,"\t",Nan,Nan)
	String temptitle_left=WaveToStringList(Datatable_left,"\t",Nan,Nan)
	String tempwritetitle=temptitle_disp+temptitle_left
	
	SVAR Datatable_Strkey_to_num=DFR_log:Datatable_Strkey_to_num
	SVAR Datatable_Varkey_to_num=DFR_log:Datatable_Varkey_to_num
	
	Wave /T filename_raw=DFR_log:filename
	Wave /T filePath_raw=DFR_log:filePath
	Wave /T RawwaveN_raw=DFR_log:RawwaveN
	Wave /T WaveInfoStringsList_raw=DFR_log:WaveInfoStringsList
	Wave  WaveInfoVarsList_raw=DFR_log:WaveInfoVarsList

	Duplicate /o /Free /T filename_raw filename
	Duplicate /o /Free /T filePath_raw filePath
	Duplicate /o /Free /T RawwaveN_raw RawwaveN
	Duplicate /o /Free /T WaveInfoStringsList_raw WaveInfoStringsList
	Duplicate /o /Free  WaveInfoVarsList_raw WaveInfoVarsList
	Make /o/Free/n=(numpnts(filename)) Fileindex
	Fileindex=p
	
	sort /A {RawwaveN,filename},filename,filePath,fileindex,RawwaveN//,WaveInfoStringsList,WaveInfoVarsList
     	
	Variable index=0,refnum,refnum1
	String tempstrlist,tempvarlist,tempwritestr
	Variable temppos
	Do
		Make /T/o/n=21 WaveInfoStrings
		Make /o/n=43 WaveInfoVars
		
		WaveInfoVars=WaveInfoVarsList[fileindex[index]][p]
		WaveInfoStrings=WaveInfoStringsList[fileindex[index]][p]
		
		Variable keyindex=0
		tempwritestr=""
		do
			String keyname=Stringfromlist(keyindex,tempwritetitle,"\t")
			variable keynum=numberbykey(keyname,Datatable_Strkey_to_num,"=",";")
			if (numtype(keynum)==2)
				 	keynum=numberbykey(keyname,Datatable_Varkey_to_num,"=",";")
				 	tempwritestr+=num2str(WaveInfoVars[keynum])+"\t"
			else
				 tempwritestr+=WaveInfoStrings[keynum]+"\t"
			endif
			
			keyindex+=1
		while (keyindex<(numpnts(Datatable_display)+numpnts(Datatable_left)))

		//tempstrlist=WaveToStringList(WaveInfoStrings,"\t",Nan,Nan)
		//tempvarlist=NumericWaveToStringList(WaveInfoVars,"\t",Nan,Nan)
		
		
		//tempwritestr=tempstrlist+tempvarlist
		//print tempwritestr
		
		newPath /Z/O/Q Datafolderpath, filepath[index] 
		if (V_flag>0)
			doalert 0,"Data folder not found"
			return 0
		endif
		Open /Z/R/P=Datafolderpath refnum as "Experiment.Log"
		if (refnum==0)
			Open /P=Datafolderpath refnum as "Experiment.Log"
		endif
		
		Open /P=Datafolderpath refnum1 as "Experiment_temp.Log"
		fprintf refnum1,"%s",tempwritetitle+"\r"
		
		
		Temppos=-1
		
		Variable readindex=1
		String fline
		freadline refnum,fline	
		do 
			freadline refnum,fline
			if (strlen(fline)==0)
				break
			endif
			if (strsearch(fline,filename[index]+"\t",0)>-1)
				if (strsearch(fline,RawWaveN[index]+"\t",0)>-1)
					temppos=readindex
					fprintf refnum1,"%s",tempwritestr+"\r"
					readindex+=1
					continue
				endif
			endif
			fprintf refnum1,"%s",fline
			//flinelist+=fline+"\r"
			readindex+=1
		while (1)		
		close refnum
		
		
		if (temppos==-1)  ///file not in the log file
			//Open /P=Datafolderpath refnum as "Experiment.Log"
			fprintf refnum1,"%s",tempwritestr+"\r"
		endif
		close refnum1
		MoveFile /O /P=Datafolderpath "Experiment_temp.Log" as "Experiment.Log"
		
		index+=1	
	while(index<numpnts(filename))
	//close /A refnum
	
	SetDatafolder DF
	
End
/////////////////////////////////static Function ////////////////////////////////////////


static Function datatb_AutoTab_proc( name, tab )
	String name
	Variable tab
	
	DFREF DF = GetDataFolderDFR()
	
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
	
	if (stringmatch(tabstr,"Waveset"))
	
		Waveset_sel("dummy",0,0,4)
	endif
		
	SetDatafolder DF
	
End





/////////////////////////////control Function/////////////////////////////////////////////

static Function Datatable_Listbox_proc(ctrlName,row,col,event) : ListboxControl

   	String ctrlName     // name of this control
	Variable row        // row if click in interior, -1 if click in title
	Variable col        // column number
	Variable event      // event code
	
	DFREF DF=GetdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
     	DFREF DFR_panel=$DF_panel
     
     	Wave listwavesel=DFR_panel:listwavesel
     	Wave /T titlewave=DFR_panel:titlewave
     
     	Variable index=0,V_startrow,V_endrow,Selwidth
	if (event==3)
		Datatable_button_editandlock("dummy")
	endif
	
	
	if (event==4)
		NVAR gv_startrow=DFR_panel:gv_startrow
		gv_startrow=row
	endif
	if (event==5)
		NVAR gv_endrow=DFR_panel:gv_endrow
		gv_endrow=row
	endif
	
	if (event==12)
		if (row==99)
			Datatable_button_editandlock("dummy")
		endif
	endif
	
	if ((event==4)||(event==5))
		Display_Insertimage(row)
	endif

	SetDatafolder DF	
End

static Function Display_InsertImage(row)
	Variable row
	
	DFREF DF = GetDataFolderDFR()
	if (strsearch(winname(0,65),"datatable_",0)==-1)
		SetDatafolder DF
		return 0
	endif
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetDatafolder DFR_panel
	Removefromgraph/Z /W=$winname(0,65)#DataTableInsetImage  DataTable_InsertImage
	RemoveImage /Z /W=$winname(0,65)#DataTableInsetImage DataTable_InsertImage
	Killwaves /Z DataTable_InsertImage
	
	Wave /T dataname=DFR_panel:dataname
	Wave data=$dataname[row]
	
	NVAR toplayernum=DFR_panel:gv_toplayernum
	NVAR topprocnum=DFR_panel:gv_topprocnum
	NVAR autolayerflag=DFR_panel:gv_autolayerflag
	
	if (wavedims(data)>2)
		variable plotlayer=Autolayer_wavelist(data,toplayernum,topprocnum,autolayerflag)
		duplicate /o /R=[][][plotlayer] data DataTable_InsertImage
	else
		duplicate /o  data DataTable_InsertImage
	endif
	
	if (wavedims(DataTable_InsertImage)>1)
		Appendimage /W=$winname(0,65)#DataTableInsetImage  DataTable_InsertImage
	else
		Appendtograph /W=$winname(0,65)#DataTableInsetImage  DataTable_InsertImage
	endif
		
	SetDatafolder DF
End


/////////////////update filepath////////////////////


static Function Datatable_button_updatepaths(ctrlname)
	String ctrlname
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	
	Wave /T filePath=DFR_panel:filepath
	
	newPath /O /Q /M="Select new Datafolder " DataFolderpath
	
	if (V_flag!=0)
		return 0
	endif
	
	Pathinfo DataFolderpath
	String Newfilepath=S_path
	
	doalert 1,"update all logs in igor?'"
	if (V_flag==2)
		return 0
	endif
	
	DFREF DFR_log=$(DF_global+":Data_log")
	
	Wave /T filepath=DFR_log:filepath
	filepath=Newfilepath
	
	
	Wave /T Datatable_display=DFR_log:Datatable_display
	Wave /T Datatable_left=DFR_log:Datatable_left
	
	Wave /T WaveInfoStringsList_raw=DFR_log:WaveInfoStringsList

	WaveInfoStringsList_raw[][4]=Newfilepath
	
End
///////////////////display note and file content///////////////////////
static Function Datatable_button_Dispfiles(ctrlname)
	String ctrlname
	DFREF DF = GetDataFolderDFR()

	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
     
	 Wave listwavesel=DFR_panel:listwavesel
     	 Wave /T titlewave=DFR_panel:titlewave
     	 Wave /T Filename=DFR_panel:filename
     
	 Variable index=0,V_startrow,V_endrow,Selwidth
	 
	Variable /C tempposition=ListWavesel_to_rowandcol(Listwavesel,0,1)
	V_startrow=real(tempposition)
	
	Wave /T filePath=DFR_panel:filepath
	
	newPath /O/Q Datafolderpath, filepath[V_startrow] 
	
	GetFileFolderInfo /D /P=Datafolderpath/Q 
		
	if (V_flag==0)
		OpenNotebook /R/K=1/N=nb0/P=Datafolderpath /W=(36,36,393,306) filename[V_startrow]
	else
		Killwaves /Z tempsel,tempsel1
		SetDatafolder DF
		return 0
	endif		

	Killwaves /Z tempsel,tempsel1		

	SetDatafolder DF
End


static Function Datatable_button_DispNotes(ctrlname)
	String ctrlname
	DFREF DF = GetDataFolderDFR()

	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
     
	Wave listwavesel=DFR_panel:listwavesel
      Wave /T titlewave=DFR_panel:titlewave
      Wave /T dataname=DFR_panel:dataname
     
	 Variable index=0,V_startrow,V_endrow,Selwidth
	 
	Variable /C tempposition=ListWavesel_to_rowandcol(Listwavesel,0,1)
	V_startrow=real(tempposition)
			
	
	Wave data=$dataname[V_startrow]
	String notestr= note(data)
		
	NewNotebook /N=nb0 /K=1 /W=(36,36,393,306)
	Notebook nb0 text=notestr
	Killwaves /Z tempsel,tempsel1

	SetDatafolder DF
End


//////////////////////reName Function/////////////////////

static Function Proc_checkbox_rename(ctrlname,value)
	String ctrlname
	Variable value
	DFREF df=getDatafolderDFR()

	Variable checkVal
	strswitch (ctrlname)
	case "Rename_ck1":
	checkVal= 1
	break
	case "Rename_ck2":
	CheckVal= 2
	break
	endswitch
	
	CheckBox Rename_ck1,value= checkVal==1
	CheckBox Rename_ck2,value= checkVal==2
	SetDatafolder DF
end


static Function DT_Wave_rename_panel(ctrlname)
	String ctrlname
	DFREF DF = GetDataFolderDFR()
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel
     
	Wave listwavesel=DFR_panel:listwavesel
	Variable index=0,V_startrow,V_endrow,Selwidth
	
	Variable /C tempposition=ListWavesel_to_rowandcol(Listwavesel,0,1)
	V_startrow=real(tempposition)
	V_endrow=imag(tempposition)

	Wave /T DataName=DFR_panel:Dataname	
	Wave /T WaveN=DFR_panel:WaveN
	
	SVAR gs_addstr=DFR_panel:gs_Addstr
	SVAR gs_basenamestr=DFR_panel:gs_basenamestr
		
	controlinfo Rename_pp1
	Variable sw1=V_Value
	IF (sw1<5)
		Wave Addnum=$(S_Value)
	endif
	
	controlinfo Rename_ck2  //pre or suffix
	Variable prefixflag=V_value
	
	controlinfo Rename_ck3 ////basename
	Variable basenameflag=V_Value
	
	index=V_startrow
	String newname
	String Addname,basename
	do 
		Wave data=$DataName[index]
		//SaveDF=Getwavesdatafolder(data,1)
		
		if (stringmatch(ctrlname,"Rename_bt0"))
			switch (sw1-1)
			case 0:
				sprintf Addname,"T%gK",round(addnum[index])
				break
			case 1:
				sprintf Addname,"P%geV",addnum[index]
				break
			case 2:
				sprintf Addname,"T%g",round(addnum[index])
				break
			case 3:
				sprintf Addname,"F%g",round(addnum[index])
				break
			case 4:
				sprintf Addname,"A%g",round(addnum[index])
				break
			case 5:
				sprintf Addname,"%g",round(index)
				break
			endswitch
			Addname=replacestring(".",Addname,"_")
			
			if (basenameflag)
				basename=gs_basenamestr
			else	
				basename=nameofwave(data)
			endif
		endif
		
		if (stringmatch(ctrlname,"Rename_bt1"))
			Addname=gs_addstr
			Addname=cleanupname(Addname,0)
			basename=nameofwave(data)
		endif

		if (prefixflag)
			newname=Addname+"_"+basename
		else
			newname=basename+"_"+Addname
		endif
		
		newname=ReplaceString("-", newname, "_")
		
		rename data $newname
		dataname[index]=GetWavesDataFolder(data,2)
		WaveN[index]=newname
		index+=1
	while (index<(V_endrow+1))
	
	Datatable_updateListwave()
	notewave_to_datanote()
	
	SetDatafolder DF	
End



static Function DT_Wave_rename_undo(ctrlname)
	String ctrlname
	DFREF DF = GetDataFolderDFR()

	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel
     
	Wave listwavesel=DFR_panel:listwavesel

	Variable index=0,V_startrow,V_endrow,Selwidth
	
	Variable /C tempposition=ListWavesel_to_rowandcol(Listwavesel,0,1)
	V_startrow=real(tempposition)
	V_endrow=imag(tempposition)

	Wave /T DataName=DFR_panel:Dataname	
	Wave /T WaveN=DFR_panel:WaveN
	
	index=V_startrow


	controlinfo Rename_ck2
	Variable prefixflag=V_value
	
	String newname,notestr,rawname
	Variable tempvalue
	
	do 
		Wave data=$DataName[index]
		
		notestr=note(data)
		rawname=Stringbykey("RawWaveName",notestr,"=","\r")
		
		if (stringmatch(ctrlname,"Rename_bt3"))/////reset
			newname=rawname
		
		else  //undo
		
		if (prefixflag)
			tempvalue=strsearch(nameofwave(data),"_",0)
			if (tempvalue<0)
				SetDatafolder DF
    				Return 0
    			else
    				newname=nameofwave(data)[tempvalue+1,inf]
    				if (strlen(newname)<strlen(rawname))
    					SetDatafolder DF
    					Return 0
    				endif
    			endif
		else
			tempvalue=strsearch(nameofwave(data),"_",inf,1)
			if (tempvalue<0)
				SetDatafolder DF
    				Return 0
   			else
    				newname=nameofwave(data)[0,tempvalue-1]
    				if (strlen(newname)<strlen(rawname))
    					SetDatafolder DF
    					Return 0
    				endif
   			endif
		endif
	
		endif
		
		rename data $newname
		dataname[index]=GetWavesDataFolder(data,2)
		WaveN[index]=newname
		index+=1
	while (index<(V_endrow+1))
	
	Datatable_updateListwave()
	notewave_to_datanote()

	SetDatafolder DF	

End


///////////////////datatable sort Function ///////////////////////

static Function DataTableSort_pop(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		
	// contents of current popup item as string
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetDatafolder DFR_panel
	
	NVAR gv_sw1
	NVAR gv_sw2
	NVAR gv_sw3
	NVAR gv_sw4
	
	StrSwitch (ctrlname)
	case "Sort_pp1":
		gv_sw1=popnum
		break
	case "Sort_pp2":
		gv_sw2=popnum
		break
	case "Sort_pp3":
		gv_sw3=popnum
		break
	case "Sort_pp4":
		gv_sw4=popnum
		break
	Endswitch
	
	DataTableSort()
	SetDatafolder DF
End	
	
static Function DataTableSort()	

	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetDatafolder DFR_panel
	
	NVAR gv_toplayernum
	NVAR gv_autolayerflag
	NVAR gV_topprocnum
	
	NVAR sw1=DFR_panel:gv_sw1
	NVAR sw2=DFR_panel:gv_sw2
	NVAR sw3=DFR_panel:gv_sw3
	NVAR sw4=DFR_panel:gv_sw4
	
	NVAR dw=DFR_panel:gv_dw
	
	String ExStr="Sort /A"
	String SortWave="None;WaveN;suffix;Tem;PhotonE;Theta;Phi;Azi;"
	
	Wave /T WaveN
	Duplicate /o /T WaveN suffix
	variable index=0
	do
		String tempstr=waveN[index]
		Variable temppos=strsearch(tempstr,"_",inf,1)
		if (temppos!=-1)
			suffix[index]=tempstr[temppos+1,inf]
		else
			suffix[index]=tempstr
		endif
		index+=1
	while (index<numpnts(waveN))
	if (dw) 
		Exstr+="/R"
	endif
	Exstr+="{"
	
	if ((sw1+sw2+sw3+sw4)>4)
		if (sw1>1)
			Exstr+=Stringfromlist(sw1-1,SortWave)+","
		endif
		if (sw2>1)
			Exstr+=Stringfromlist(sw2-1,SortWave)+","
		endif
		if (sw3>1)
			Exstr+=Stringfromlist(sw3-1,SortWave)+","
		endif
		if (sw4>1)
			Exstr+=Stringfromlist(sw4-1,SortWave)+","
		endif
	else
		SetDatafolder DF
		return 0
	endif
	Exstr=removeending(Exstr,",")+"} "

	
	Exstr+="dataname"
	Execute Exstr
	wave /T dataname
	
	NVAR gv_controlflag=DFR_panel:gv_controlflag
	String pathslist=WaveToStringList(dataname,";",Nan,Nan)
	DFREF DFR_panel=init_datatb_panel(Pathslist,gv_toplayernum,gV_topprocnum,gv_autolayerflag,gv_controlflag)
	
	SetDatafolder DF
End

static Function Proc_checkbox_reverse(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked	
		
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetDatafolder DFR_panel	
	
	NVAR dw=DFR_panel:gv_dw
	dw=checked
	
	DataTableSort()
   	//Datatable_updateListwave()
	SetDatafolder DF	
	
End


static Function DataTableSort_Manual(ctrlname)
	String ctrlname
	
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel
	
	NVAR gv_toplayernum
	NVAR gv_autolayerflag
	NVAR gv_topprocnum
	
	wave /T dataname
	
	Wave listwavesel=DFR_panel:listwavesel

	Variable index=0,V_startrow,V_endrow,Selwidth
	
	Variable /C tempposition=ListWavesel_to_rowandcol(Listwavesel,0,1)
	V_startrow=real(tempposition)
	V_endrow=imag(tempposition)
	
	if (stringmatch(ctrlname,"Sort_bt0"))
		Variable directionflag=0 //up
	else
		directionflag=1//down
	endif
	
	if ((directionflag==0)&&(V_startrow==0))
		SetDatafolder DF
		return 0
	endif
	
	if ((directionflag==1)&&(V_endrow==(numpnts(dataname)-1)))
		SetDatafolder DF
		return 0
	endif
	
	Duplicate /T /o dataname,dataname_temp
	
	Duplicate /o listwavesel, listwavesel_temp
	
	if (directionflag==0)
		if (V_startrow>1)
			dataname[0,V_startrow-2]=dataname_temp[p]
			listwavesel[0,V_startrow-2][]=listwavesel_temp[p][q]
		endif
		dataname[V_startrow-1,V_endrow-1]=dataname_temp[p+1]
		dataname[V_endrow]=dataname_temp[V_startrow-1]
		listwavesel[V_startrow-1,V_endrow-1][]=listwavesel_temp[p+1][q]
		listwavesel[V_endrow][]=listwavesel_temp[V_startrow-1][q]
		
		if (V_endrow<(numpnts(dataname)-1))
			dataname[V_endrow+1,inf]=dataname_temp[p]
			listwavesel[V_endrow+1,inf][]=listwavesel_temp[p][q]
		endif
		
		
	else
		dataname[0,V_startrow-1]=dataname_temp[p]
		dataname[V_startrow]=dataname_temp[V_endrow+1]
		dataname[V_startrow+1,V_endrow+1]=dataname_temp[p-1]
		listwavesel[0,V_startrow-1][]=listwavesel_temp[p][q]
		listwavesel[V_startrow][]=listwavesel_temp[V_endrow+1][q]
		listwavesel[V_startrow+1,V_endrow+1][]=listwavesel_temp[p-1][q]
	endif	
		
	
	NVAR gv_controlflag=DFR_panel:gv_controlflag
	String pathslist=WaveToStringList(dataname,";",Nan,Nan)
	DFREF DFR_panel=init_datatb_panel(Pathslist,gv_toplayernum,gV_topprocnum,gv_autolayerflag,gv_controlflag)
	
	Killwaves /Z dataname_temp,ListWavesel_Temp
	
	SetDatafolder DF
End

static Function reorder_waves_in_Datafolder(ctrlname)
	String ctrlname
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel	
	
	Wave /T dataname,WaveN
	
	Wave data=$dataname[0]
	String DF_Data=GetWavesDatafolder(data,1)
	DuplicateDatafolder $DF_data :temp
	Variable index
	String path,path1
	do
		path=dataname[index]
		path1=":temp:"+WaveN[index]
		Killwaves /Z $path
		movewave $path1, $path
		index+=1
	while (index<numpnts(dataname))
	
	Killdatafolder :temp
	
	SetDatafolder DF
End
	


static Function reorder_waves_in_Graph(ctrlname)
	String ctrlname
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetDatafolder DFR_panel	
	
	SVAR gname=gs_panelname
	
	Wave /T dataname,WaveN
	Wave data=$dataname[0]

	String List,TraceLast
	TraceLast=WaveN[inf]
		
	List=WaveToStringList(WaveN,";",0,numpnts(WaveN)-1)
	//List=removeending(list,";")
		
	//print list	
	Variable item=itemsinlist(list,";")
	
	String Trace1N
	
	Variable index=0
	do
		Trace1N=Stringfromlist(index,List,";")
		ReorderTraces /W=$gname $TraceLast,{$Trace1N}
		index+=1
	while (index<(item-1))
	
	
	SetDatafolder DF
End


//////////////////wave set function /////////////////

static Function Waveset_Calcmd(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderdFR()
	String DF_panel="root:internalUse:"+winname(0,65)
   	DFREF DFR_panel=$DF_panel
   	SVAR calcmdstr=DFR_panel:gs_calcmdstr
   	
   	DFREF DFR_global=$DF_global
   	SVAR WaveSetlist=DFR_global:WaveSetList
   	
   	Cal_WaveSet(Calcmdstr,WaveSetList,0)
End
static Function Waveset_addcmd(ctrlname)
	String ctrlname
	
	DFREF DF=GetDatafolderdFR()
	String DF_panel="root:internalUse:"+winname(0,65)
   	DFREF DFR_panel=$DF_panel
   	
   	controlinfo WaveSet_lb0
	Variable selrow=v_value
   	
	Wave /T WaveSetNameList_disp=DFR_panel:WaveSetNameList_disp
	SVAR calcmdstr=DFR_panel:gs_calcmdstr
	String Wavesetname=WaveSetNameList_disp[selrow]
	
	calcmdstr+=Wavesetname
End

static Function Waveset_add(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderdFR()
	String DF_panel="root:internalUse:"+winname(0,65)
   	DFREF DFR_panel=$DF_panel
   	
	Variable Addflag=stringmatch(ctrlname,"Waveset_bt0")
	controlinfo WaveSet_lb0
	Variable selrow=v_value
	
	String Wavesetname
	if (Addflag==1)
		prompt  Wavesetname,"Name of Wavesets:"
		doprompt "Input Name of Wavesets", Wavesetname
		if (V_flag==1)
			return 0
		endif
	else
		Wave /T WaveSetNameList_disp=DFR_panel:WaveSetNameList_disp
		Wavesetname=WaveSetNameList_disp[selrow]
	endif	
	
	Wave listwavesel=DFR_panel:listwavesel

	Variable startrow,endrow
	
	Variable /C tempposition=ListWavesel_to_rowandcol(Listwavesel,0,0)
	startrow=real(tempposition)
	endrow=imag(tempposition)

	Wave /T DataName=DFR_panel:Dataname	
	
	String WPathlist=WaveToStringList(DataName,";",startrow,endrow)
	Save_WaveSet(WPathlist,WaveSetname,Addflag)
	 
	 WaveSet_sel("dummy",selrow,0,4)
End

static Function Waveset_sel(ctrlName,row,col,event) : ListboxControl
	String ctrlName     // name of this control
	Variable row        // row if click in interior, -1 if click in title
	Variable col        // column number
	Variable event      // event code
	
	DFREF DF=GetDatafolderdFR()
	String DF_panel="root:internalUse:"+winname(0,65)
   	DFREF DFR_panel=$DF_panel
	
	DFREF DFR_global=$(DF_global)
	
	if ((event==4)||(event==5))
	
		SetDatafolder DFR_global
	
		if (exists("WaveSetNameList")>0)
			SVAR WaveSetNameList=DFR_global:WaveSetNameList
			SVAR WaveSetList=DFR_global:WaveSetList
			if (strlen(wavesetlist)==0)
				SetDatafolder DFR_panel
				Make /o/T/n=0 WaveSetnamelist_disp,WaveSetPathlist_disp
				SetDatafolder DF
				return 0
			endif
			SlistTowave(WaveSetNamelist,0,";",Nan,Nan)
			Wave /T w_stringList
			duplicate /o /T w_stringList,DFR_panel:WaveSetnamelist_disp
	
			Wave /T WaveSetnamelist_disp=DFR_panel:WaveSetnamelist_disp
			String Wavesetname=WaveSetnamelist_disp[row]
	
			Variable findnum=strsearch(WaveSetList, Wavesetname+"=", 0)
			Variable findnum1=strsearch(WaveSetList, "\r", findnum)
			String Wpathlist=WaveSetList[findnum+strlen(Wavesetname)+1,findnum1-1]
			SListToWave(Wpathlist,0,";",Nan,Nan)
			Wave /T w_StringList
			Duplicate /o w_StringList,DFR_panel:WaveSetPathlist_disp
			Killwaves /Z w_sTringlist
		endif
	
	endif
	
	SetDatafolder DF	
	return 0            // other return values reserved
End



//Function 




/////////////////////////////////////////////edit button for mapper//////////////////////////////////////



Function MakeData_table_list(Wavepathlist,toplayernum,topprocnum,autolayerflag) //for mapper edit
	String Wavepathlist
	Variable toplayernum,topprocnum,autolayerflag
	DFREF DF=GetDataFolderDFR()
	String Datalist=Wavepathlist
		
	Variable num=itemsinList(Datalist,";")
	if ((num)==0)
		SetDatafolder DF
		return 0
	endif
	
	Newdatafolder/o/s root:internalUse:Data_table
	String notestr=""
	Variable index=0	
	String /G CopyFolderName
	//Variable /G gv_killflag=0
	Variable /G gv_toplayernum=toplayernum
	Variable /G gv_autolayerflag=autolayerflag
	Variable /G gv_topprocnum=topprocnum
	
	Make/T/o/n=(num) dataname
	//make/T/o/n=0 SelwavePaths
	Make/T/o/n=(num) WaveN
	Make /o/n=(num) theta,th_off,phi,ph_off,azi,azi_off,gammaA,PhotonE,WorkFn,FermiEnergy,tem
	
	index=0
	do 
	
		dataname[index]=Stringfromlist(index,Datalist,";")
		Wave data=$dataname[index]
		
		if (wavedims(data)>2)
			Variable datalayernum=Autolayer_wavelist(data,toplayernum,topprocnum,autolayerflag)
		else
			datalayernum=0
		endif
	
		ReadDetailWaveNote(data,datalayernum,0)
		
		Wave /T WaveInfoStrings	
		Wave WaveInfoVars
		

		WaveN[index] =WaveInfoStrings[1]
		theta[index] =WaveInfoVars[32]
		th_off[index]=WaveInfoVars[33]
		phi[index] = WaveInfoVars[34]
		ph_off[index]=WaveInfoVars[35]
		azi[index]= WaveInfoVars[36]
		azi_off[index]=WaveInfoVars[37]
		PhotonE[index] = WaveInfoVars[20]
		WorkFn[index]=WaveInfoVars[21]
		FermiEnergy[index]=WaveInfoVars[41]
		//InnerE[index]=Wavevars[8]
		GammaA[index] =WaveInfoVars[8]
		tem[index]=WaveInfoVars[19]
	
	index+=1
	while (index<(num))
	
	String panelnamelist=winlist("Data_table",";","WIN:2") 
	
	if (strlen(panelnamelist)==0)
		Edit/w=(0,0,700,250)/k=1 WaveN,theta,th_off,phi,ph_off,azi,azi_off,gammaa,tem,PhotonE,Workfn,FermiEnergy as "Data_table"
		DoWindow/C Data_table
		SetWindow kwTopWin, hook(test) = DataTable_to_WaveNote
		execute "ModifyTable size=9"
		execute "ModifyTable width=50"
		execute "ModifyTable width(Point)=25,width(WaveN)=70"
	else
		DoWindow /F Data_table
	endif
	
	Setdatafolder DF
End	



	
	
Function DataTable_to_WaveNote(s)
	STRUCT WMWinHookStruct &s
	Variable r=0
	Variable i=0
	Variable delta
	
	DFREF DFR_tb=$"root:internalUse:Data_Table"
	switch(s.eventcode)
		case 11:
		 	if (s.keycode==32)
		 		String WinN=winname(0,2)
	    			Getselection table,$winN,3
	     			if (strsearch(S_selection,"theta",0)!=-1)
	    				 WAVE theta=DFR_tb:theta
	     				SetVariables(V_startrow,V_endrow,theta)
	     				r=1
	    			 endif
	    			 
	     			if (strsearch(S_selection,"th_off",0)!=-1)
	    				 WAVE th_off=DFR_tb:th_off
	     				SetVariables(V_startrow,V_endrow,th_off)
	     				r=1
	    			 endif
	    			 
	    			 if (strsearch(S_selection,"phi",0)!=-1)
	     				WAVE phi=DFR_tb:phi
	     				SetVariables(V_startrow,V_endrow,phi)
	     				r=1
	    			 endif
	    			 
	    			 if (strsearch(S_selection,"ph_off",0)!=-1)
	     				WAVE ph_off=DFR_tb:ph_off
	    				SetVariables(V_startrow,V_endrow,ph_off)
	     				r=1
	     			endif
	     			
	    			if (strsearch(S_selection,"azi",0)!=-1)
	     				WAVE azi=DFR_tb:azi
	     				SetVariables(V_startrow,V_endrow,azi)
	     				r=1
	     			endif
	     			
	     			if (strsearch(S_selection,"azi_off",0)!=-1)
	     				WAVE azi_off=DFR_tb:azi_off
	    				 SetVariables(V_startrow,V_endrow,azi_off)
	    				 r=1
	     			endif
	     			
	     			if (strsearch(S_selection,"gammaA",0)!=-1)
	     				WAVE gammaA=DFR_tb:gammaA
	     				SetVariables(V_startrow,V_endrow,gammaA)
	     				r=1
	     			endif
	     			
	     			if (strsearch(S_selection,"PhotonE",0)!=-1)
	     				WAVE PhotonE=DFR_tb:PhotonE
	     				SetVariables(V_startrow,V_endrow,PhotonE)
	     				r=1
	     			endif
	     			
	     			if (strsearch(S_selection,"WorkFn",0)!=-1)
	     				WAVE WorkFn=DFR_tb:WorkFn
	     				SetVariables(V_startrow,V_endrow,WorkFn)
	     				r=1
	     			endif
	     			
				if (strsearch(S_selection,"Tem",0)!=-1)
	     				WAVE Tem=DFR_tb:Tem
	    				 SetVariables(V_startrow,V_endrow,Tem)
	     				r=1
	    			 endif
	    
	    			 if (r==1)
		 			datatonote()
				 endif
		 	endif
			break
		case 2:
		 	datatonote()
		 	WinN=winname(0,2)
		 	String DF_panel="root:internaluse:"+WinN
		 	KillDatafolder /Z $DF_panel
		 	r=1
			break
		case 0:
		 	datatonote()
		 	r=1
			break
		case 1:
		 	datatonote()
		 	r=1
		break
 	 endswitch
  	return r
End



Function SetVariables(startRow,endRow,Col)
	Variable StartRow,endrow
	Wave col
	Variable i,delta=col[startrow+1]-col[startrow] 
	for (i=startRow+2;i<(endRow+1);i+=1)
 		col[i]=col[i-1]+delta
	endfor
End


static Function datatonote() 
	DFREF DF = GetDataFolderDFR()
	DFREF DF_dataT=root:internalUse:Data_Table
	
	WAVE/T Dataname=DF_dataT:Dataname
	WAVE theta=DF_dataT:theta
	Wave th_off=DF_dataT:th_off
	WAVE phi=DF_dataT:phi
	Wave ph_off=DF_dataT:ph_off
	Wave azi=DF_dataT:azi
	Wave azi_off=DF_dataT:azi_off
	Wave PhotonE=DF_dataT:PhotonE
	Wave WorkFn=DF_dataT:WorkFn
	Wave Tem=DF_dataT:Tem
	Wave gammaA=DF_dataT:GammaA
	 
	 String M=""	
	 String notestr
	 Variable index = 0
	 do
		M =Dataname[index]
		Wave temp=$M
		notestr = note(temp)
		Note/K temp
		notestr = ReplaceNumberByKey("InitialThetaManipulator",notestr,theta[index],"=", "\r")
		notestr = ReplaceNumberByKey("InitialPhiManipulator",notestr,phi[index],"=", "\r")
		notestr = ReplaceNumberByKey("InitialAzimuthManipulator",notestr,azi[index],"=", "\r")
		notestr = ReplaceNumberByKey("OffsetThetaManipulator",notestr,th_off[index],"=", "\r")
		notestr = ReplaceNumberByKey("OffsetPhiManipulator",notestr,ph_off[index],"=", "\r")
		notestr = ReplaceNumberByKey("OffsetAzimuthManipulator",notestr,azi_off[index],"=", "\r")
		notestr = ReplaceNumberByKey("ScientaOrientation",notestr,gammaA[index],"=", "\r")
	
		notestr = ReplaceNumberByKey("PhotonEnergy",notestr,PhotonE[index],"=","\r")
		notestr = ReplaceNumberbykey("SampleTemperature",noteStr,Tem[index],"=","\r")
		notestr = ReplaceNumberbykey("WorkFunction",noteStr,WorkFn[index],"=","\r")	
		
		Note temp, notestr
		
		Write_to_log_Datafolder(temp)
	    index += 1
	    while (index < numpnts(Dataname))
       SetDataFolder DF
End


