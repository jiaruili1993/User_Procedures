#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 0.01
#pragma ModuleName = LoadPanel




////////////////////////////////////////Global panel Function///////////////////////////////

Function /DF init_Loadfile_panel()
	
	DFREF DF=GetDataFolderDFR()

	String DF_panel="root:internalUse:"+winname(0,65)
	NewDataFolder/O/S $DF_panel
	DFREF DFR_panel=$DF_panel
	variable /G gv_killflag=0

	NewDataFolder/o/s $DF_global
	
	Variable /G gv_MacroVersion=constant_Macro_Version

	String /G gs_filefolder=""
	Variable /G gv_gammaA=Nan
	String /G gs_AnalyzerSlit=""
	String /G gs_polarization=""
	String /G gs_Filetype=".txt"


	Variable /G gv_uca=3.9
	Variable /G gv_ucb=3.9
	Variable /G gv_ucc=7
	Variable /G gv_InnerE=15
	Variable /G gv_alphaA=90
	Variable /G gv_betaA=90
	Variable /G gv_gammaAA=90
	variable /G gv_BZtype=1
	Variable /G gv_SampleOrientation=45
	
	//not modify by user/ just for function to access
	
	Variable /G gv_photonE=21.2
	Variable /G gv_workfn=4.35


	Variable /G gv_SamthetaOff
	Variable /G gv_Samphioff
	Variable /G	 gv_SamAzioff

	Variable /G gv_autosynflag=0
	//Variable /G gv_autoFSMflag=0
	//String /G gs_autoFSMpath=""
	
	Variable /G gv_copydfflag
	Variable /G gv_macroflag
	Variable /G gv_overflag=0
	Variable /G gv_Automapflag=0
	Variable /G gv_autoprocflag=0
	Variable /G gv_AutoLoadflag=0
	

	String /G gv_datafolder
	String /G gs_DFlist="process:;gold:;"
	String /G gs_selDF="process:"
	Variable /G gv_selDFnum=1

	Make /o/n=1/T WavePathlist,WaveNameList
	
	if (exists("gv_rawwaveexists")==0)
   	 	Variable /G gv_rawwaveexists=0
   	endif
   	if (exists("gs_rawnotestr")==0)
		String /G gs_rawnotestr=""
	endif
	if (exists("gv_Logfileflag")==0)
		Variable /G gv_Logfileflag=0
	endif
	if (exists("gv_LogDataflag")==0)
		Variable /G gv_LogDataflag=0
	endif
	if (exists("LoadWaveNotes")==0)
		String /G LoadWaveNotes=""
	endif
	if (exists("LoadWaveList")==0)
		String /G LoadWaveList=""
	endif
	
	if (exists("Experimentlog")==0)
		Make /o/n=(0,2)/T Experimentlog
		Make /o/n=(0,2) /B Experimentlog_sel
		Make /o/n=(2) /T Experimentlog_Title
		Experimentlog_Title={"Time","Log"}
		Experimentlog_sel[][]=2
	endif
	
	Make /o/n=1/T w_Macrolist1,w_Macrolist2
	Make /o/n=0/T MacroListstr
	String /G gs_procstr1=""
	String /G gs_procstr2=""
	
	newDatafolder /o Proc_wave
	
	newDatafolder /o/s Data_Log
	
	String /G Datatable_Strkey_to_num="dataname=0;WaveN=1;rawWaveN=2;Filename=3;FilePath=4;User=5;Sample=6;"
	Datatable_Strkey_to_num+="instrument=7;measurementsoftware=8;AnalyzerSlit=9;Region=10;Sdate=11;Stime=12;LensMode=13;AcMode=14;Polarization=15;EnergyScale=16;"
	Datatable_Strkey_to_num+="Comment=17;Leftnotes=18;tmfname=19;dispname=20;"
	
	String /G Datatable_Varkey_to_num="LatticeA=0;LatticeB=1;LatticeC=2;LatticeAlpha=3;LatticeBeta=4;Latticegamma=5;LatticeType=6;InnerE=7;"
	Datatable_Varkey_to_num+="gammaA=8;fYchannel=9;lYchannel=10;fXchannel=11;lXchannel=12;DegreeperChannel=13;EvperChannel=14;DwellTime=15;"
	Datatable_Varkey_to_num+="PassE=16;Sweeps=17;SampleOrientation=18;Tem=19;PhotonE=20;WorkFn=21;BeamCurrent=22;AreaI=23;"
	Datatable_Varkey_to_num+="LowEnergy=24;HighEnergy=25;NumEnergy=26;Estep=27;firstslice=28;lastslice=29;numslices=30;Degreeslices=31;"
	Datatable_Varkey_to_num+="theta=32;thetaoff=33;phi=34;phioff=35;azi=36;azioff=37;ManiX=38;ManiY=39;ManiZ=40;"
	Datatable_Varkey_to_num+="FermiN=41;Initialflag=42;DeflectorAngle=43;"
	
	
	Make /o/n=21/T Datatable_display
	Make /o/n=43/T Datatable_left
	
	Datatable_display[0,11]={"WaveN","theta","thetaoff","phi","phioff","azi","azioff", "ManiX","ManiY","ManiZ","Tem","Comment"}
	Datatable_display[12,20]={"PhotonE","Polarization","PassE","Estep","LowEnergy","HighEnergy","Sweeps","Sdate","Stime"}
	
	Datatable_left[0,10]={"BeamCurrent","AreaI","Region","AnalyzerSlit","EnergyScale","Initialflag","WorkFn","FermiN","tmfname","dispname","gammaA"}
	Datatable_left[11,20]={"NumEnergy","firstslice","lastslice","numslices","Degreeslices","fYchannel","lYChannel","fXChannel","lXChannel","DegreeperChannel"}
	Datatable_left[21,30]={"EvperChannel","DwellTime","SampleOrientation","LatticeA","LatticeB","LatticeC","LatticeAlpha","LatticeBeta","Latticegamma", "Latticetype"}
	Datatable_left[31,42]={"InnerE","dataname","RawWaveN","Filename","FilePath","User","Sample","instrument","measurementsoftware","LensMode","Acmode","Leftnotes"}
	
	
	Make /T/o/n=21 titleStrs
	Make /T/o/n=44 titleVars
	titleStrs[0,10]={"dataname","WaveN","RawWaveN","Filename","FilePath","User","Sample", "instrument","measurementsoftware","AnalyzerSlit","Region"}
	titleStrs[11,20]={"Sdate","Stime","LensMode","Acmode","Polarization","EnergyScale","Comment","Leftnotes","tmfname","dispname"}
	titleVars[0,9]={"LatticeA","LatticeB","LatticeC","LatticeAlpha","LatticeBeta","Latticegamma", "Latticetype","InnerE","gammaA","fYchannel"}
	titleVars[10,19]={"lYChannel","fXChannel","lXChannel","DegreeperChannel","EvperChannel","DwellTime","PassE","Sweeps","SampleOrientation","Tem"}
	titleVars[20,29]={"PhotonE","WorkFn","BeamCurrent","AreaI","LowEnergy","HighEnergy","NumEnergy","Estep","firstslice","lastslice"}
	titleVars[30,39]={"numslices","Degreeslices","theta","thetaoff","phi","phioff","azi","azioff","ManiX","ManiY"}
	titleVars[40,43]={"ManiZ","FermiN","Initialflag","DeflectorAngle"}
		
	Make /T /o/n=21 KeywordStrs
	Make /T /o/n=44 KeywordVars
		
	KeywordStrs[0,10]={"","WaveName","RawWaveName","FileName","FilePath","User","Sample","Instrument","MeasurementSoftware","AnalyzerSlit","RegionName"}
	KeywordStrs[11,20]={"StartDate","StartTime","LensMode","AcquisitionMode","Polarization","EnergyScale","Comments","LeftNots","tmfwave","dispwave"}
		
	KeywordVars[0,9]={"LatticeA","LatticeB","LatticeC","LatticeAlpha","LatticeBeta","Latticegamma", "Latticetype","InnerPotential","ScientaOrientation","CCDFirstYchannel"}
	KeywordVars[10,19]={"CCDLastYChannel","CCDFirstXChannel","CCDLastXChannel","CCDDegreeperChannel","CCDeVperChannel","DwellTime","PassEnergy","NumberOfSweeps","SampleOrientation","SampleTemperature"}
	KeywordVars[20,29]={"PhotonEnergy","WorkFunction","BeamCurrent","AreaIntensity","FirstEnergy","LastEnergy","NumberOfEnergies","Energy Step","FirstSlice","LastSlice"}
	KeywordVars[30,39]={"NumberofSlices","DegreeSlices","InitialThetaManipulator","OffsetThetaManipulator","InitialPhiManipulator","OffsetPhiManipulator","InitialAzimuthManipulator","OffsetAzimuthManipulator","X_Manipulator","Y_Manipulator"}
	KeywordVars[40,43]={"Z_Manipulator","FermiEnergy","Initialflag","DeflectorAngle"}
		
	String /G gs_samplename=""
	String /G gs_samplecomment=""
	String /G gs_previewcomment=""
	String /G gs_location=""
	String /G gs_user=""
	String /G gs_expDate=""
	variable /G gv_saveNBflag=0
	
	String /G gs_Expcklist="Map=0;Tdep=0;Gap=0;kz=0;Cut=0;Sum=0;"
	Variable /G gv_commentflag=0

	Setdatafolder DF
	return DFR_panel
End

Function close_loadfile_panel(ctrlname)
	String ctrlName
	String wname=winName(0,65)
	String DF_panel="root:internalUse:"+wname
	DFREF DFR_panel=$DF_panel
	NVAR killflag=DFR_panel:gv_killflag
	killflag=1
	dowindow/K $wname
End

Function Open_loadfile_Panel_start()

	Open_loadfile_Panel("dfdf")

end



Function Open_loadfile_Panel(ctrlName)
	String ctrlName
	
	DFREF DF = GetDataFolderDFR()
		
	Variable SC = ScreenSize(5)
  
	Variable SR = Screensize(3) 
	Variable ST = Screensize(2)
	Variable SL = Screensize(1)
       Variable SB = Screensize(4)
    
	Variable Width = 495*SC 	// panel size  
	Variable height = 400*SC 
	Variable xOffset = SR-width//(SR-SL)/2-width/2
	Variable yOffset = ST-width//(SB-ST)/2-height/2
	
	
	String panelnamelist=winlist("loadfile_panel_*",";","WIN:65")
	
	if (stringmatch(ctrlname,"recreate_window")==0)
	
		if (strlen(panelnamelist)>0)
			BringUP_Allthepanel(panelnamelist,2)
			SetDatafolder DF
			return 1
		else
			String spwinname=UniqueName("loadfile_panel_", 9, 0)
 			NewPanel /W=(xOffset, yOffset,xOffset+width,Height+yOffset) as spwinname
			DoWindow/C $spwinname
   			Setwindow $spwinname hook(MyHook) = MypanelHook
			Modifypanel cbRGB=(52428,52428,52428)
    		endif
    		
    		 DFREF DFR_panel=init_Loadfile_panel()
    	else
    		BringUP_Allthepanel(panelnamelist,2)
    		DFREF DFR_panel=$("root:internalUse:"+winname(0,65))
    		SetActiveSubwindow $winname(0,65)
    	endif
    
    	SetDatafolder DFR_panel
   	 DFREF DFR_global=$DF_global
    
    	NVAR gv_selDFnum=DFR_global:gv_selDFnum
    	NVAR gv_copydfflag=DFR_global:gv_copydfflag
    	NVAR gv_macroflag=DFR_global:gv_macroflag
    	NVAR gv_Automapflag=DFR_global:gv_Automapflag
    	NVAR gv_autoprocflag=DFR_global:gv_autoprocflag
    
    	Wave /T MacroListstr=DFR_global:MacroListstr
	
	//SVAR gs_DFlist= DFR_panel:gs_DFlist
	
	Variable r=54998, g=54998, b=54998
	
	Button global_bt0,pos={510*SC,3*SC},size={80*SC,18*SC},title="close",labelBack=(r,g,b),proc=close_loadfile_panel
	Button global_gold, size={40*SC,20*SC},pos={450*SC,25*SC}, title="gold", proc=open_gold_panel
	Button global_main, size={40*SC,20*SC},pos={450*SC,55*SC}, title="main", proc= Open_main_Panel
	Button global_map, size={40*SC,20*SC},pos={450*SC,85*SC}, title="map", proc= open_mapper_panel
	Button global_BZ, size={40*SC,20*SC},pos={450*SC,115*SC}, title="BZ", proc=open_bz_panel
	Button global_Anal, size={40*SC,20*SC},pos={450*SC,145*SC}, title="Anal", proc=Open_Analysis_Panel
	Button global_Fit, size={40*SC,20*SC},pos={450*SC,175*SC}, title="Fit", proc=open_fit_panel
	
	TabControl loadfile,proc=LoadPanel#loadfile_AutoTab_proc, pos={8*SC,6*SC},size={435*SC,370*SC},value=0,labelBack=(r,g,b)
    
    	TabControl loadfile,tabLabel(0)="SetAllVar"
    
    	SetVariable SetAllVar_sv0,pos={20*SC,30*SC},size={410*SC,20*SC},title="File folder:",value=DFR_global:gs_filefolder,limits={-Inf,Inf,0}
   	Button SetAllVar_bt0,pos={300*SC,50*SC},size={80*SC,20*SC},title="Open Browser",proc=LoadPanel#Proc_loadfile_SetFolder
  	//  Button SetAllVar_bt1,pos={380,50},size={80,20},title="Auto Load", proc=Proc_Loadfile_autoload
    
   	 Groupbox SetAllVar_gb1,pos={20*SC,80*SC},size={180*SC,180*SC},frame=0,title="global settings:"

    	SetVariable SetAllVar_sv13, pos={30*SC,140*SC}, size={95*SC,15*SC},labelBack=(r,g,b),title="Slit gamma", value = DFR_global:gv_gammaA,limits={-Inf,Inf,0}
    	PopupMenu SetAllVar_pp1,pos={135*SC,137*SC},size={90*SC,15*SC},labelBack=(r,g,b),mode=1,title="",value="None;0;90;", Proc=LoadPanel#SetGamma
	SetVariable SetAllVar_sv18, pos={30*SC,170*SC}, size={95*SC,15*SC},labelBack=(r,g,b),title="Anal slit", value = DFR_global:gs_AnalyzerSlit,limits={-Inf,Inf,0} 
    	PopupMenu SetAllVar_pp2,pos={135*SC,167*SC},size={70,15},labelBack=(r,g,b),mode=1,title="",value="None;0.5s;0.5c;0.3s;0.3c;0.2s;0.2c",Proc=LoadPanel#Setanaslit
    	SetVariable SetAllVar_sv17, pos={30*SC,200*SC}, size={100*SC,15*SC},labelBack=(r,g,b),title="Polarization", value = DFR_global:gs_polarization,limits={-Inf,Inf,0} 
    	PopupMenu SetAllVar_pp3,pos={135*SC,197*SC},size={70*SC,15*SC},labelBack=(r,g,b),mode=1,title="",value="None;Mix;LH;LV;C+;C-;",Proc=LoadPanel#SetPolar
  	PopupMenu SetAllVar_pp4,pos={30*SC,110*SC},size={70*SC,15*SC},labelBack=(r,g,b),mode=1,title="Location:",value="None;Fudan;SSRL;ALS;Hisor;SLS;",Proc=LoadPanel#SetDefaultLocation
    	PopupMenu SetAllVar_pp5,pos={30*SC,230*SC},size={70*SC,15*SC},labelBack=(r,g,b),mode=1,title="FileType:",value="SES;SPECS;BL10",Proc=LoadPanel#SetFiletype
  
  
   	Groupbox SetAllVar_gb2,pos={220*SC,80*SC},size={210*SC,150*SC},frame=0,title="BZ settings:"
   	SetVariable SetAllVar_sv1,pos={230*SC,110*SC},size={80*SC,15*SC},labelBack=(r,g,b),title="a:", value = DFR_global:gv_uca,limits={0,Inf,0}
   	SetVariable SetAllVar_sv2,pos={230*SC,140*SC},size={80*SC,15*SC},labelBack=(r,g,b),title="b:", value = DFR_global:gv_ucb,limits={0,Inf,0}
   	SetVariable SetAllVar_sv3,pos={230*SC,170*SC},size={80*SC,15*SC},labelBack=(r,g,b),title="c:", value = DFR_global:gv_ucc,limits={0,Inf,0}
   	SetVariable SetAllVar_sv4,pos={320*SC,110*SC},size={100*SC,15*SC},labelBack=(r,g,b),title="alpha:", value = DFR_global:gv_alphaA,limits={0,90,0}
   	SetVariable SetAllVar_sv7,pos={320*SC,140*SC},size={100*SC,15*SC},labelBack=(r,g,b),title="beta:", value = DFR_global:gv_betaA,limits={0,90,0}
   	SetVariable SetAllVar_sv8,pos={320*SC,170*SC},size={100*SC,15*SC},labelBack=(r,g,b),title="gamma:", value = DFR_global:gv_gammaAA,limits={0,90,0}

   	PopupMenu SetAllVar_pp6,pos={230*SC,197*SC},size={70*SC,15*SC},labelBack=(r,g,b),mode=1,title="type:",value="Simple;BCC;FCC;TCC",Proc=LoadPanel#SetBZtype

	
   	Groupbox SetAllVar_gb3,pos={220*SC,240*SC},size={210*SC,120*SC},frame=0,title="sample settings:"
   	SetVariable SetAllVar_sv9,pos={230*SC,265*SC},size={130*SC,15*SC},labelBack=(r,g,b),title="theta_offset:", value = DFR_global:gv_samthetaoff,limits={-Inf,Inf,0}
   	SetVariable SetAllVar_sv10,pos={230*SC,290*SC},size={130*SC,15*SC},labelBack=(r,g,b),title="phi_offset:", value = DFR_global:gv_samphioff,limits={-Inf,Inf,0}
   	SetVariable SetAllVar_sv11,pos={230*SC,315*SC},size={130*SC,15*SC},labelBack=(r,g,b),title="azi_offset:", value = DFR_global:gv_samazioff,limits={-Inf,Inf,0}
   
   	SetVariable SetAllVar_sv6,pos={230*SC,340*SC},size={90*SC,15*SC},labelBack=(r,g,b),title="Orintation:", value = DFR_global:gv_SampleOrientation,limits={-Inf,Inf,0}
 
   	SetVariable SetAllVar_sv5,pos={330*SC,340*SC},size={90*SC,15*SC},labelBack=(r,g,b),title="InnerE(eV):", value = DFR_global:gv_InnerE,limits={-Inf,Inf,0}
  
   	TabControl loadfile,tabLabel(1)="AutoProc"
  
    	//Checkbox AutoProc_ck4,labelBack=(r,g,b),pos={30,40},size={100,18},title="Auto Proc?",fsize=16,variable=DFR_global:gv_autoprocflag,disable=1
    
    	Popupmenu AutoProc_pop1,labelBack=(r,g,b),pos={130*SC,100*SC},bodywidth=150*SC,size={150*SC,18*SC},disable=1,mode=gv_selDFnum,title="DF:",value=#(DFS_global+"gs_DFlist"),proc=LoadPanel#pop_DFlist_update_proc_lf
	//Checkbox  AutoProc_ck4,labelBack=(r,g,b),pos={190,100},size={100,18},title="Reload All?",variable=DFR_global:gv_overflag//,proc=proc_checkbox_copyfile
	Checkbox  AutoProc_ck0,labelBack=(r,g,b),pos={30*SC,90*SC},size={100*SC,18*SC},title="Copy to:",disable=1,value=gv_copydfflag==1,proc=LoadPanel#proc_checkbox_copyfile
	Checkbox  AutoProc_ck1,labelBack=(r,g,b),pos={30*SC,115*SC},size={100*SC,18*SC},title="Move to:",disable=1,value=gv_copydfflag==2,proc=LoadPanel#proc_checkbox_copyfile
   	// Checkbox  AutoProc_ck5,labelBack=(r,g,b),pos={250,60},size={100,18},title="OverWrite:",value=1,disable=1,variable=gv_overflag//,proc=//proc_checkbox_copyfile
    
	Groupbox AutoProc_gb2,pos={20*SC,150*SC},size={220*SC,90*SC},disable=1,frame=0,title="Macro Proc:"
	Checkbox  AutoProc_ck2,pos={30*SC,175*SC},size={100*SC,18*SC},title="Macro1?",disable=1,value=gv_macroflag==1,proc=LoadPanel#proc_checkbox_ProcMacro
	Checkbox  AutoProc_ck3,pos={30*SC,200*SC},size={100*SC,18*SC},title="Macro2?",disable=1,value=gv_macroflag==2,proc=LoadPanel#proc_checkbox_ProcMacro
	Listbox AutoProc_lb0,pos={130*SC,170*SC},size={100*SC,60*SC},disable=1,mode=0,listWave=MacroListstr
    
   	Checkbox  AutoProc_ck5,labelBack=(r,g,b),disable=1,pos={30*SC,40*SC},size={100*SC,18*SC},title="OverWrite All?",variable=DFR_global:gv_overflag//,proc=proc_checkbox_copyfile
	Checkbox  AutoProc_ck6,labelBack=(r,g,b),disable=1,pos={130*SC,60*SC},size={100*SC,18*SC},title="Ignore Log Data?",variable=DFR_global:gv_LogDataflag//,proc=proc_checkbox_copyfile
	Checkbox  AutoProc_ck7,labelBack=(r,g,b),disable=1,pos={130*SC,40*SC},size={100*SC,18*SC},title="Ignore Log file?",variable=DFR_global:gv_Logfileflag//,proc=proc_checkbox_copyfile
	
	TabControl loadfile,tabLabel(2)="ExpLog"
	titlebox Explog_tb0,disable=1,pos={30*SC,40*SC},size={400*SC,20*SC}, title="Experiment Log:",frame=0
	Listbox ExpLog_lb0,disable=1,pos={30*SC,60*SC},size={400*SC,200*SC},mode=1,listWave=DFR_global:Experimentlog,selwave=DFR_global:Experimentlog_Sel,titlewave=DFR_global:Experimentlog_Title
	Listbox ExpLog_lb0,widths={80,200}
	Button ExpLog_bt0,disable=1,pos={340*SC,270*SC},size={80*SC,20*SC},title="Add log",proc=LoadPanel#AddExpLog
	Button ExpLog_bt1,disable=1,pos={340*SC,300*SC},size={80*SC,20*SC},title="Del log",proc=LoadPanel#DelExpLog
	Button ExpLog_bt2,disable=1,pos={340*SC,330*SC},size={80*SC,20*SC},title="Write logfile",proc=LoadPanel#WriteExpLog
	PopupMenu ExpLog_pp0,disable=1,pos={220*SC,270*SC},size={100*SC,20*SC},title="Default Event:",mode=0,proc=LoadPanel#PopupExplog
    	PopupMenu ExpLog_pp0, value="Cleave Sample;Laser alignment?;Degasing, Vaccum?;Optimize Beam;Change Slit;Rotate Sample to?;Finish;"
	Button ExpLog_bt3,disable=1,pos={250*SC,300*SC},size={60*SC,20*SC},title="UP",proc=LoadPanel#reorderExpLog
	Button ExpLog_bt4,disable=1,pos={250*SC,330*SC},size={60*SC,20*SC},title="DOWN",proc=LoadPanel#reorderExpLog
	
	if (stringmatch(ctrlname,"recreate_window")==1)
		SetDrawLayer /K UserBack
	endif
	
	SetDrawLayer UserBack
	
	DrawPICT /W=$winname(0,65)  /RABS 20*SC,265*SC, 210*SC, 370*SC,ProcGlobal#Iconpic2
	SetDrawEnv textrgb= (52224,0,0)//fstyle= 1,fsize=12,
	String printstr
	
	
	sprintf printstr, "ARPES Macro Ver. %.2f ",constant_Macro_Version/100
	
	DrawText 30*SC,397*SC,printstr+Secs2Date(DateTime,-2)
	
	SVAR gs_expdate=DFR_panel:gs_expdate
	
	gs_expdate=Secs2Date(DateTime,-2)
	
	Button global_about,labelBack=(r,g,b),pos={350*SC,380*SC},size={40*SC,20*SC},title="About",Proc=LoadPanel#proc_bt_openaboutpanel
	
	Button global_pref,labelBack=(r,g,b),pos={400*SC,380*SC},size={40*SC,20*SC},title="Prefs",Proc=open_Prefs_panel
	
	
	SetDatafolder DF
	return 1
End


///////////////////////////////////Add Exp log///////////////

static Function reorderExpLog(ctrlname)
	String ctrlname
	DFREF DF = GetDataFolderDFR()
	DFREF DFR_global=$DF_global
	
	SetActiveSubwindow $winname(0,65)
	
	Wave /T Experimentlog=DFR_global:Experimentlog
	Wave /B Experimentlog_sel=DFR_global:Experimentlog_sel
	
	controlinfo ExpLog_lb0
	
	Variable pos=v_Value
	if (pos==-1)
		return 0
	endif
	
	if (stringmatch(ctrlname,"ExpLog_bt3"))
		Variable upflag=1
		Variable fpos=pos-1
		if (fpos<0)
			fpos=0
			return 0
		endif
		
	else
		upflag=0
		fpos=pos+1
		if (fpos>(dimsize(Experimentlog,0)-1))
			fpos=dimsize(Experimentlog,0)-1
			return 0
		endif
	endif
	
	String tempstr1=Experimentlog[fpos][0]
	string tempstr2=Experimentlog[fpos][1]
	Variable tempvar1=Experimentlog_sel[fpos][0]
	Variable tempvar2=Experimentlog_sel[fpos][1]
	
	Experimentlog[fpos][]=Experimentlog[pos][q]
	Experimentlog_sel[fpos][]=Experimentlog_sel[pos][q]
	
	Experimentlog[pos][0]=tempstr1
	Experimentlog[pos][1]=tempstr2
	Experimentlog_sel[pos][0]=tempvar1
	Experimentlog_sel[pos][1]=tempvar2
	

	Listbox ExpLog_lb0,selRow=fpos
	
end

static Function WriteExpLog(ctrlname)
	String ctrlname
	
	DFREF DF = GetDataFolderDFR()
	DFREF DFR_global=$DF_global
	
	SetActiveSubwindow $winname(0,65)
	
	Wave /T Experimentlog=DFR_global:Experimentlog
	Wave /B Experimentlog_sel=DFR_global:Experimentlog_sel
	
	SVAR gs_filefolder=DFR_global:gs_filefolder
	
	newpath/O /Q/Z Datafolderpath, gs_filefolder
	if (V_flag>0)
		newpath/O /Q/Z Datafolderpath
	endif
	
	if (dimsize(Experimentlog,0)==0)
		return 0
	endif
	
	Variable refnum
	
	Open /Z/P=Datafolderpath refnum as "Experiment_Write.Log"
	if (refnum==0)
		return 0
	endif
	

	variable index=0
	do
		String writestr=Experimentlog[index][0]+"\t"
		fprintf refnum,"%s",writestr
		writestr=Experimentlog[index][1]+"\r"
		fprintf refnum,"%s",writestr
		index+=1
	while (index<dimsize(Experimentlog,0))
	
	Close refnum
End

static Function PopupExplog (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	DFREF DF = GetDataFolderDFR()
	DFREF DFR_global=$DF_global
	AddExplog("dummy")
	
	Wave /T Experimentlog=DFR_global:Experimentlog
	Wave /B Experimentlog_sel=DFR_global:Experimentlog_sel
	
	Experimentlog[inf][1]=popStr
End

static Function AddExplog(ctrlname)
	String ctrlname
	DFREF DF = GetDataFolderDFR()
	DFREF DFR_global=$DF_global
	
	SetActiveSubwindow $winname(0,65)
	
	Wave /T Experimentlog=DFR_global:Experimentlog
	Wave /B Experimentlog_sel=DFR_global:Experimentlog_sel
	
	//controlinfo ExpLog_lb0
	
	//Variable pos=v_Value
	//if (pos==-1)
	//	pos=0
	//endif
	Insertpoints /M=0 inf,1,Experimentlog,Experimentlog_sel
	
	Experimentlog[inf][0]=Secs2Date(DateTime,0)+" "+time()
	Experimentlog[inf][1]=""
	Experimentlog_sel[inf][]=2
End

static Function DelExplog(ctrlname)
	String ctrlname
	
	DFREF DF = GetDataFolderDFR()
	DFREF DFR_global=$DF_global
	
	SetActiveSubwindow $winname(0,65)
	
	Wave /T Experimentlog=DFR_global:Experimentlog
	Wave /B Experimentlog_sel=DFR_global:Experimentlog_sel
	controlinfo ExpLog_lb0
	
	Variable pos=v_Value
	if (pos==-1)
		return 0
	endif
	
	if (dimsize(Experimentlog,0)==1)
		redimension /n=(0,2) Experimentlog
		redimension /n=(0,2)  Experimentlog_sel
	else
		Deletepoints /M=0 pos,1,Experimentlog,Experimentlog_sel
	endif
End

//////////////////////////////static function ///////////////////////////////////////////

static Function Proc_bt_openaboutpanel(ctrlname)
	String ctrlname
	
	Variable SC = ScreenSize(5)
	Variable SR = Screensize(3) 
	Variable ST = Screensize(2)
	Variable SL = Screensize(1)
    	Variable SB = Screensize(4)
	//Variable SC = ScreenSize(5)
	//Variable SR = ScreenSize(3) * SC
	//Variable ST = ScreenSize(2) * SC
	//Variable SL = ScreenSize(1) * SC
	//Variable SB = ScreenSize(4) * SC
	
	Variable Width = 600*SC		// panel size  
	Variable height = 300*SC

	Variable xoff=(SR-SL)/2-Width/2
	Variable yoff=(SB-ST)/2-height/2

	Variable r=57000, g=57000, b=57000

	NewPanel /K=1 /W=(xoff,yoff,xoff+Width,yoff+height) as "About ARPES Macro"
	ModifyPanel noEdit=1
	DoWindow/K/Z  AboutARPESMacro		
	DoWindow/C AboutARPESMacro				// Set to an unlikely name
	//DrawPICT /W=$winname(0,65)  0, 0, 1, 1, Iconpic
	SetDrawLayer UserBack
	DrawPICT /W=$winname(0,65)  /RABS 0,0, Width, height,ProcGlobal#Iconpic
	//SetDrawEnv fname= "Geneva"
	
	SetDrawEnv fstyle= 1,textrgb= (65535,65535,65535)
	String printstr
	sprintf printstr, "ARPES Macro Ver. %.2f is coded by Yan ZHANG.", constant_Macro_Version/100
	DrawText 175*SC,35*SC,printstr
	
	SetDrawEnv fstyle= 1,textrgb= (65535,65535,65535)
	DrawText 185*SC,75*SC,"The system UI and graph Proc are inspired by i_photo and  Ino_macro."
	
	SetDrawEnv fstyle= 1,textrgb= (65535,65535,65535)
	DrawText 335*SC,140*SC,"Bug report to Y.Zhang86@gmail.com"

	SetDrawEnv fstyle= 1,textrgb= (65535,65535,65535)
	DrawText 335*SC,170*SC,"All right reserved. Please do not distribute."
	
	
	
end


static Function loadfile_AutoTab_proc( name, tab )
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
		
	SetDatafolder DF
	
End

static Function SetDefaultLocation(ctrlName,popNum,popStr) : PopupMenuControl
    	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string

	DFREF DF=GetDAtafolderdfR()	
  	String DF_panel="root:internalUse:"+winname(0,65)
  	DFREF DFR_panel=$DF_panel
   
   	DFREF DFR_global=$DF_global
   
   	NVAR gv_gammaA=DFR_global:gv_gammaA
   
   	SVAR gs_Polarization=DFR_global:gs_Polarization
   	SVAR gs_filetype=DFR_global:gs_filetype 
   
   
   	strswitch(popstr)
   		case "None":
   			break
 		 case "Fudan":
   			gv_gammaA=0
   			PopupMenu SetAllVar_pp1,mode=2
   			gs_Polarization="Mix"
   			PopupMenu SetAllVar_pp3,mode=2
   			gs_filetype=".txt"
   			PopupMenu SetAllVar_pp5,mode=1
   			break
   		case "ALS":
   			gv_gammaA=0
   			PopupMenu SetAllVar_pp1,mode=3
   			gs_Polarization=""
   			PopupMenu SetAllVar_pp3,mode=1
   			gs_filetype=".fits"
   			PopupMenu SetAllVar_pp5,mode=3
   			doalert 1,"Load default gold file?"
   			if (v_flag==1)
   				Loadwave /O /Q/T/P=ipath "gold_ALS.itx"
   			endif
   			break
  		 case "SSRL":
   			gv_gammaA=0
   			PopupMenu SetAllVar_pp1,mode=2
   			gs_Polarization="Mix"
   			PopupMenu SetAllVar_pp3,mode=2
   			gs_filetype=".txt"
   			PopupMenu SetAllVar_pp5,mode=1
   			doalert 1,"Load default gold file?"
   			if (v_flag==1)
   				Loadwave /O /Q/T/P=ipath "gold_SSRL.itx"
   			endif
   			break
   		case "SLS":
   			gv_gammaA=90
   			PopupMenu SetAllVar_pp1,mode=3
   			gs_Polarization=""
   			PopupMenu SetAllVar_pp3,mode=1
   			gs_filetype=".txt"
   			PopupMenu SetAllVar_pp5,mode=1
   			break
   		case "Hisor":
   			gv_gammaA=90
   			PopupMenu SetAllVar_pp1,mode=3
   			gs_Polarization=""
   			PopupMenu SetAllVar_pp3,mode=1
   			gs_filetype=".txt"
   			PopupMenu SetAllVar_pp5,mode=1
   			break
   		endswitch
   
   SetDatafolder DF
End


static Function SetBZtype (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	
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
   	Variable temp1,temp2
          
   	if (popnum>1)
   		if  ((gV_alphaA!=90)||(gv_betaA!=90)||(gv_gammaAA!=90))
   			doalert 0, "angle must be 90"  
   			PopupMenu SetAllVar_pp6,mode=1
   			gv_BZtype=1
   		else
   			gv_BZtype=popnum
   		endif
   	endif	 
   		   
   	gv_BZtype=popnum
   
End

static Function Proc_loadfile_SetFolder(ctrlname)
	String ctrlname

	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_global=$DF_global
 
	SVAR gs_filefolder=DFR_global:gs_filefolder

	NewPath /O/Q/Z/M="Select a file" FilefolderPath
	PathInfo  FilefolderPath
	gs_filefolder=S_Path

End

static Function SetGamma (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	
	String DF_panel="root:internalUse:"+winname(0,65)
    	DFREF DFR_panel=$DF_panel
    	DFREF DFR_global=$DF_global
    
    	NVAR gv_gammaA=DFR_global:gv_gammaA
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
	
   	String DF_panel="root:internalUse:"+winname(0,65)
   	DFREF DFR_panel=$DF_panel
   	DFREF DFR_global=$DF_global
    
  	 SVAR gs_AnalyzerSlit=DFR_global:gs_AnalyzerSlit   
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
	
   	String DF_panel="root:internalUse:"+winname(0,65)
   	DFREF DFR_panel=$DF_panel
   	DFREF DFR_global=$DF_global
    
   	SVAR gs_Polarization=DFR_global:gs_Polarization 
    	 if (popnum==1)  
    		 gs_Polarization=""
    	 else
    		gs_Polarization=popstr
    	endif
End

static Function SetFiletype (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	
	String DF_panel="root:internalUse:"+winname(0,65)
   	DFREF DFR_panel=$DF_panel
    	DFREF DFR_global=$DF_global
    
    	SVAR gs_filetype=DFR_global:gs_filetype
     
     	switch(popnum)
     	case 1:
    		gs_filetype=".txt"
     		break
     	case 2:
    	 	gs_filetype=".dat"
     		break
     	case 3:
     		gs_filetype=".fits"
     		break
    	 endswitch
End





///////////////////////////////////global Function /////////////////////////




static Function proc_checkbox_ProcMacro(ctrlname,value)
	String ctrlname
	variable value
	String DF_panel="root:internalUse:"+winname(0,65)
   	DFREF DFR_panel=$DF_panel
   	DFREF DFR_global=$DF_global
   
    	NVAR gv_macroflag= DFR_global:gv_macroflag
    	Wave /T macroliststr= DFR_global:macroliststr
    	Wave /T w_Macrolist1=  DFR_global:w_Macrolist1
    	Wave /T w_Macrolist2=  DFR_global:w_Macrolist2
   
   	Variable ckvalue
    
	StrSwitch (ctrlname)
	case "AutoProc_ck2":
		ckvalue=(value==1)?(1):(0)
		break
	case "AutoProc_ck3":
		ckvalue=(value==1)?(2):(0)
		break
	endswitch

	gv_macroflag=ckvalue

	checkbox AutoProc_ck2, value= ckvalue==1
	checkbox AutoProc_ck3, value= ckvalue==2

	if (ckvalue==1)
		duplicate /t/o w_Macrolist1 macroliststr
	elseif (ckvalue==2)
		duplicate /t/o w_Macrolist2 macroliststr
	else
		redimension /n=0 macroliststr
	endif

End


static Function  proc_checkbox_copyfile(ctrlname,value)
	String ctrlname
	variable value
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_global=$DF_global
	
    	NVAR gv_copydfflag=DFR_global:gv_copydfflag
   
   	Variable ckvalue
    
	StrSwitch (ctrlname)
	case "AutoProc_ck0":
		ckvalue=(value==1)?(1):(0)
		break
	case "AutoProc_ck1":
		ckvalue=(value==1)?(2):(0)
		break
	endswitch

	gv_copydfflag=ckvalue

	checkbox AutoProc_ck0, value= ckvalue==1
	checkbox AutoProc_ck1, value= ckvalue==2

end





static Function pop_DFlist_update_proc_lf(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_global=$DF_global

	
	SVAR gs_DFlist=DFR_global:gs_DFlist
	sVAR gs_selDF=DFR_global:gs_selDF
	NVAR gv_selDFnum=DFR_global:gv_selDFnum
	
	String DFList=FoldertoList(root:spectra:,"*",0)
	DFlist=removeStringfromlist(DFlist,"root:spectra:",";",0)
	if (strlen(gs_DFlist)<2)
		gs_DFlist="process:;gold:;"
	else
		gs_DFlist="process:;gold:;"+DFlist
	endif	
	if (strsearch(gs_DFlist,popStr,0)<0)
		popupmenu AutoProc_pop1,mode=1
		ControlUpdate AutoProc_pop1
		gv_selDFnum=1
		gs_selDF="process:"
	else
		if (popnum>2)
	    		gs_selDF="spectra:"+popstr
	    	else
	   		 gs_selDF=popstr
	    	endif
	    	gv_selDFnum=popnum
	endif
	
End

////////////////////////auto proc auto load function //////////////////


Function /S SingleWave_autoproc_proc(wpath,wname)
	String wpath
	String wname
	DFREF DF=GetDatafolderdFR()
	//DFREF DFR_global=$DF_global
	//SetDatafolder DFR_global
	
	String wavepath=Smain_wave_save_autoproc(wpath,wname)
	wavepath=SApply_proc_macro_Autoproc(wavepath,wname)
	
	SetDatafolder DF
	return wavepath
End






Function Wave_autoproc_proc(wpath,wname)
	String wpath
	String wname
	DFREF DF=GetDatafolderdFR()
	DFREF DFR_global=$DF_global
	SetDatafolder DFR_global
	Wave /T WavePathlist= DFR_global:WavePathlist
	Wave /T Wavenamelist= DFR_global:Wavenamelist
	
	Make /o/n=1/T WavePathlist,WaveNamelist
	WavePathlist[0]=wpath
	WaveNamelist[0]=wname
	
	main_wave_save_autoproc(WavePathlist,Wavenamelist)
	Apply_proc_macro_Autoproc(WavePathlist,Wavenamelist)
	
	SetDatafolder DF
End


Function  wave_autoload_proc(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderDFR()

	//NVAR topwaverow=DF_common:gv_topwaverow

	String panelname=winname(0,65)
	String DFS_panel="root:internalUse:"+panelName
	String DFS_common="root:internalUse:"+panelName+":panel_common"
	DFREF DF_common=$DFS_common
	DFREF DF_panel=$DFS_panel
	DFREF DFR_global=$DF_global

	//openautoloadwindow(panelname)

	NVAR gv_autoloadflag=DFR_global:gv_autoloadflag
	NVAR gv_overflag=DFR_global:gv_overflag
	gv_autoloadflag=1
	
	if (gV_overflag==1)
		doalert 2, "Overwrite all the waves?"
		if (V_flag==1)
		elseif (V_flag==2)
			gV_overflag=0
		elseif (v_flag==3)
			SetDatafolder DF
			return 0
		endif
	endif

	SetDatafolder  DFR_global

	SVAR gs_filetype=DFR_global:gs_filetype

	Make /o/n=1/T WavePathlist,WaveNamelist

	GetFileFolderInfo /D /P=FilefolderPath /Q /Z
	if (V_flag==0)
		String Filelist=IndexedFile(FilefolderPath,-1,gs_filetype)
		Variable index=0
		String filename,NickName
		PathInfo  FilefolderPath
		String sympath=S_path
		do
			filename=Stringfromlist(index,filelist,";")
			if (strlen(filename)==0)
				break
			endif
			
			if (stringmatch(gs_filetype,".txt"))
				load_SES_txt_file("FilefolderPath",filename)
			elseif (stringmatch(gs_filetype,".fits"))
				Load_fits_file("FilefolderPath",filename)
			elseif (stringmatch(gs_filetype,".itx"))
				load_SIS_itx_file("FilefolderPath", filename)
			else
				return 0
			endif
			index+=1
		while (index<itemsinlist(Filelist))

		Wave /T WavePathlist=DFR_global:WavePathlist
		Wave /T WaveNamelist=DFR_global:WaveNamelist
		DeletePoints (numpnts(WavePathlist)-1),1,WavePathlist
		DeletePoints (numpnts(WaveNamelist)-1),1,WaveNamelist

		if (numpnts(WaveNamelist)==0)
			SetDatafolder DF
			gv_autoloadflag=0
			return 0
		endif

		//main_wave_save_autoproc(WavePathlist,Wavenamelist)
		//Apply_proc_macro_Autoproc(WavePathlist,Wavenamelist)

		if (stringmatch(panelname,"mapper_panel*"))
		 	AddmainpanelSel_autoproc(WavePathlist,Wavenamelist)
		 	updata_mapping_par(0)
		 	mapperPanel#proc_bt_update_cube("dummy")
		 	master_mapper("settings_b30")
		else
			controlinfo /W=$panelname source_lb1
			source_Listbox_Proc("source_lb1", V_Value, 0, 4)
		endif
		SetDatafolder DF
		gv_autoloadflag=0
	else
		SetDatafolder DF
		gv_autoloadflag=0
		return 0
	endif

End



static Function /S SApply_proc_macro_Autoproc(Wave_Path,Wave_name)
	String Wave_path,wave_name

	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_global=$DF_global

	NVAR gv_macroflag=DFR_global:gv_macroflag
	NVAR gv_rawwaveexists=DFR_global:gv_rawwaveexists
	SVAR gs_rawnotestr=DFR_global:gs_rawnotestr
	
	String tempprocstr=""
	Variable tempvar=0
	
	if (gv_rawwaveexists==2)
		if (gv_macroflag>0)
			//if (gv_macroflag==1)
			//	SVAR procstr=DFR_global:gs_procstr1
			//else
			//	SVAR procstr=DFR_global:gs_procstr2
			//endif
			//string tempprocstr_remove="*"+RemoveallLayernum(procstr,0)+"*"
			//string rawprocstr_remove=RemoveallLayernum(gs_rawnotestr,0)
			//if (stringmatch(rawprocstr_remove,tempprocstr_remove))
				tempprocstr=gs_rawnotestr
				tempvar=1
			//else
			//	tempprocstr=procstr
			//	tempvar=0
			//endif
		else
			tempprocstr=gs_rawnotestr
			tempvar=1
		endif
	else
	
		if (gv_macroflag==0)
			SetDatafolder DF
			return wave_path
		elseif (gv_macroflag==1)
			Wave /T w_Macrolist= DFR_global:w_Macrolist1
			SVAR procstr=DFR_global:gs_procstr1
			tempprocstr=procstr
			tempvar=0
		elseif (gv_macroflag==2)
			Wave /T w_Macrolist= DFR_global:w_Macrolist2
			SVAR procstr=DFR_global:gs_procstr2
			tempprocstr=procstr
			tempvar=0
		endif
	endif
	
    	Variable datalayernum,procdone
	
	Wave data=$wave_path
	
	datalayernum=dimsize(data,2)-1 //toplayer
	procdone=macro_autoprocess(wave_path,tempprocstr,datalayernum,tempvar,0)

	SetDatafolder DF
	return wave_path
End


static Function /S Smain_wave_save_autoproc(Wave_Path,Wave_name)
	String Wave_Path,Wave_Name

	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_global=$DF_global
	
	NVAR gv_copydfflag=DFR_global:gv_copydfflag
	SVAR selDF=DFR_global:gs_selDF
	//NVAR gv_overflag=DF_load:gv_overflag
	NVAR gv_rawwaveexists=DFR_global:gv_rawwaveexists
	SVAR gs_rawnotestr=DFR_global:gs_rawnotestr
	
	if (gv_copydfflag==0)
		SetDatafolder DF
		return Wave_path
	endif
	
	if (gv_copydfflag==1)
		Variable moveflag=0
	else
		moveflag=1
	endif
	
	String saveDF="root:"+selDF
	Variable index=0
	String dwave_name
	
	dwave_name=saveDF+wave_name
	
	Wave data=$wave_path
	
	if (stringmatch(wave_path,dwave_name)==0)
		if (gv_rawwaveexists==1)
			Wave /Z rawdata=$(saveDF+wave_name)
			if (waveexists(rawdata))
				gv_rawwaveexists=2
				gs_rawnotestr=GetLayernotestr(note(rawdata),1,2)
			endif
		endif	
		duplicate /o data,$(dwave_name)
		if (moveflag)
			killwaves /Z data
		endif
	endif
	
	SetDatafolder DF
	return dwave_name
End






static Function AddmainpanelSel_autoproc(WavePathlist,Wavenamelist)
	Wave /T WavePathlist,WaveNamelist

    	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_global=$DF_global
	
	WAVE/T w_sourcePathes_map = DFR_panel:w_sourcePathes
	WAVE/T w_sourceNames_map = DFR_panel:w_sourceNames
	Wave/B w_sourceNamessel_map=DFR_panel:w_sourceNamessel

	String objpathlist=WavetoStringlist(WavePathlist,";",Nan,Nan)
	String objnamelist=WavetoStringlist(WaveNamelist,";",Nan,Nan)

	Variable index=0
	Variable add_pnts
		
	do
		if (itemsinlist(objpathlist)==0)
			break
		endif
				
		if (AppendstringtoList_norepeat(w_sourcePathes_map,Stringfromlist(index,objpathlist),0,1))
			AppendstringtoList_norepeat(w_sourceNames_map,Stringfromlist(index,objnamelist),0,0)
		endif
			
		index+=1	
	while (index<itemsinlist(objpathlist))
			
	add_pnts = numpnts(w_sourcePathes_map)
	Redimension/N=(add_pnts) w_sourceNamessel_map
	w_sourceNamessel_map=0
	sort /A w_sourceNames_map,w_sourceNames_map,w_sourcePathes_map,w_sourceNamessel_map
			
	SetDatafolder DF
End


Function Auto_load_quickFn()

	Open_main_Panel("dummy")

	wave_autoload_proc("dummy")

End

Function Auto_map_quickFn()

	Open_mapper_Panel("dummy")

	wave_autoload_proc("dummy")

End
   
  
  
















////////////backup fn/////////////




static Function Apply_proc_macro_Autoproc(WavePathlist,Wavenamelist) //may remove
	Wave /T WavePathlist,WaveNamelist

	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_global=$DF_global

	NVAR gv_macroflag=DFR_global:gv_macroflag
	NVAR gv_rawwaveexists=DFR_global:gv_rawwaveexists
	

	if (gv_macroflag==0)
		SetDatafolder DF
		return 0
	endif

	if (gv_macroflag==1)
		Wave /T w_Macrolist= DFR_global:w_Macrolist1
		SVAR procstr=DFR_global:gs_procstr1
	else
		Wave /T w_Macrolist= DFR_global:w_Macrolist2
		SVAR procstr=DFR_global:gs_procstr2
	endif

    	Variable index=0
    	Variable datalayernum,procdone
	String wave_path,wave_name
	
	do 
	
		wave_name=WaveNamelist[index]
		wave_path=WavePathlist[index]
	//dwave_name=saveDF+wave_name
	
		Wave data=$wave_path
	
		datalayernum=dimsize(data,2)-1 //toplayer
		procdone=macro_autoprocess(wave_path,procstr,datalayernum,0,0)
	
		index+=1
	while (index<numpnts(WaveNamelist))
	
	SetDatafolder DF
End


static Function main_wave_save_autoproc(WavePathlist,Wavenamelist) //remove?
	Wave /T WavePathlist,WaveNamelist

	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_global=$DF_global
	
	NVAR gv_copydfflag=DFR_global:gv_copydfflag
	SVAR selDF=DFR_global:gs_selDF
	//NVAR gv_overflag=DF_load:gv_overflag
	NVAR gv_rawwaveexists=DFR_global:gv_rawwaveexists
	SVAR gs_rawnotestr=DFR_global:gs_rawnotestr
	
	if (gv_copydfflag==0)
		SetDatafolder DF
		return 0
	endif
	
	if (gv_copydfflag==1)
		Variable moveflag=0
	else
		moveflag=1
	endif
	
	String saveDF="root:"+selDF
	Variable index=0
	String wave_path,wave_name,dwave_name
	
	do 
	
		wave_name=WaveNamelist[index]
		wave_path=WavePathlist[index]
		dwave_name=saveDF+wave_name
	
		Wave data=$wave_path
		if (stringmatch(wave_path,dwave_name)==0)
			if (gv_rawwaveexists==1)
				Wave /Z rawdata=$(saveDF+wave_name)
				if (waveexists(rawdata))
					gv_rawwaveexists=2
					gs_rawnotestr=GetLayernotestr(note(rawdata),1,2)
				endif
			endif	
			duplicate /o data,$(dwave_name)
			if (moveflag)
				killwaves /Z data
			endif
		endif
		WavePathlist[index]=dwave_name
		
		index+=1
	while (index<numpnts(WaveNamelist))
		
	//AutoselectWave(saveDF,Wavenamelist)
	
	//source_Listbox_Proc("global_waves_list", topwaverow, 0, 4)
	SetDatafolder DF
End