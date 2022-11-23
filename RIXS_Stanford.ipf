#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#pragma ModuleName = RIXSStanford

Menu "RIXS Analysis"
	"Load Files", RIXSLoadFiles()
	"Set Scaling", RIXSSetScaling()
	"Align Zero Energy", RIXSAlignZeroEnergy()
	"Self Absorption Correction", RIXSSelfAbsorptionCorrection
	"About", DoAlert 0,"RIXS Analysis Macro (Version 1.00 - Date 05.22.2019)\n\nContact: hylu@stanford.edu"
End

// Set DataFolder to root:RIXS_Analysis_Macro_System_File for private variables
static Function SetDF()
	NewDataFolder/O root:RIXS_Analysis_Macro_System_File
	String/G root:RIXS_Analysis_Macro_System_File:savDF= GetDataFolder(1) //save DF
	SetDataFolder root:RIXS_Analysis_Macro_System_File //root:RIXS as default DF
End
// Restore DataFolder 
static Function RestoreDF()
	SVAR savDF=root:RIXS_Analysis_Macro_System_File:savDF
	SetDataFolder savDF
End

static Function SaveLoadPrefs()
	STRUCT RIXSFileLoadPrefs prefs
	SetDF()
	SVAR source_path=source_path,target_path=target_path
	SVAR target_name=target_name
	SVAR extension=extension
	SVAR preload_parameters=preload_parameters
	NVAR from_i=from_i,to_i=to_i,precision=precision
	NVAR overwrite=overwrite,doublePrecision=doublePrecision,loadAll=loadAll
	NVAR numColumn=numColumn,totalNumColumn=totalNumColumn
	prefs.source_path=source_path
	prefs.target_path=target_path
	prefs.target_name=target_name
	prefs.extension=extension
	prefs.from_i=from_i
	prefs.to_i=to_i
	prefs.precision=precision
	prefs.overwrite=overwrite
	prefs.doublePrecision=doublePrecision
	prefs.loadAll=loadAll
	prefs.numColumn=numColumn
	prefs.totalNumColumn=totalNumColumn
	prefs.preload_parameters=preload_parameters 
	RestoreDF()
End

Structure RIXSFileLoadPrefs
	uint32	version		// Preferences structure version number. 100 means 1.00.
	char source_path[100] //Source folder name length limited to be 100 chars
	char target_path[100] //Targer folder name length limited to be 100 chars
	char target_name[100] //Target file name length limited to be 100 chars
	char extension[32]
	uint32 from_i
	uint32 to_i
	uint32 precision
	uint32 overwrite
	uint32 doublePrecision
	uint32 loadAll
	uint32 numColumn
	uint32 totalNumColumn
	char preload_parameters[100]
EndStructure

Function RIXSLoadFiles()
	//Bring RIXSLoadPanel window to the front. If it does not exist,create a new window.
	DoWindow/F RIXSLoadPanel
	If (V_flag != 0)
		return 0
	EndIf
	
	SetDF()
	Variable/G  from_i=000, to_i=001
	String/G source_path=""
	String/G target_path=""
	String/G target_name=""
	String/G extension="    "
	String/G preload_parameters=""
	Variable/G overwrite=0,doublePrecision=1,loadAll=1,numColumn=0,totalNumColumn=0,precision=3
	Make/O/T/N=(numColumn,2) listbox_listWave
	listbox_listWave[][]=""
	Make/O/N=(numColumn,2) listbox_selWave = 2
	Make/O/T listbox_tilteWave = {"Column index\n(0-based)", "User-defined\nColumn name"}

	STRUCT RIXSFileLoadPrefs prefs
	
	LoadPanel()
	SetVariable source_folder_name, value=source_path
	SetVariable target_folder_name, value=target_path
	SetVariable target_file_name, value=target_name
	CheckBox overwrite, variable=overwrite
	CheckBox doublePrecision, variable=doublePrecision
	CheckBox loadAll, variable=loadAll
	SetVariable numColumn, value=numColumn
	SetVariable totalNumColumn, value=totalNumColumn
	SetWindow kwTopWin,hook=RIXSStanford#LoadPanelHook
	RestoreDF()
End

static Function LoadPanel() : Panel
	PauseUpdate; Silent 1		// building window...	
	NewPanel /W=(600,80,1220,520) /K=1 as "Load Files"
	
	Groupbox source,pos={10,10},size={600,90},frame=0,fsize=16,title="Source settings:"
	SetVariable source_folder_name,pos={20,40},size={500,20},fsize=14,title="Source folder name"
	Button browse_source,pos={540,40},size={60,20},fColor=(0,0,65535),valueColor=(65535,65535,65535),fsize=14,proc=RIXSStanford#BrowseFileProc,title="\y+15Browse"
//	SetVariable source_file_name,pos={20,70},size={240,20},fsize=14,title="Source file name"
	PopupMenu file_extension,pos={20,70},size={420,20},fsize=14,mode=1,Proc=RIXSStanford#LoadFileExtensionProc,title="Load all files in the selected folder with extension, e.g., .txt.   ( ???? for any type) ",value=".txt;.dat;.xas;????",popvalue="        "
	
	Groupbox column,pos={10,110},size={600,165},frame=0,fsize=16,title="Column info settings:"
	Titlebox column_info,pos={30,140},size={220,30},fsize=14,frame=4,title="Input index/name for columns\nto be loaded. Skip the others."
	SetVariable totalNumColumn,disable=2,pos={20,185},size={225, 20},fsize=14,limits={0,999,1},noproc,title="Total # of columns in files",format="%03d"
	SetVariable numColumn,pos={20, 215},size={225,20},fsize=14,limits={0,999,1},proc=RIXSStanford#LoadFileColumnProc,title="# of columns to be loaded",format="%03d"
	PopupMenu preload_parameters,pos={20,245},size={80,60},fsize=14,mode=1,Proc=RIXSStanford#LoadParameterProc,title="Pre-loaded templates",value="ALS XAS;ALS RIXS;ESRF XAS;ESRF RIXS",popvalue="          "
	wave/T listbox_listWave,listbox_tilteWave
	wave listbox_selWave
	ListBox Set_column, pos={250, 140},size={305, 125},fsize=14,listwave=listbox_listWave,titleWave=listbox_tilteWave,mode=5,selWave=listbox_selWave,editStyle=1,userColumnResize=1,widths={60,80},setEditCell={0,1,0,200}
	Button add_row,pos={565,140},size={40,35},labelBack=0,fsize=30,proc=RIXSStanford#AddRowProc,title="\y+18\JC\K(2,39321,1)+"
	Button delete_row,pos={565,185},size={40,35},labelBack=0,fsize=30,proc=RIXSStanford#DeleteRowProc,title="\y+18\JC\K(65535,0,0)-"
	Button clear,pos={565,230},size={40,35},labelBack=0,fsize=14,proc=RIXSStanford#ClearProc,title="Clear"
	
	Groupbox target,pos={10,280},size={600,150},frame=0,fsize=16,title="Target settings:"
	SetVariable target_folder_name,pos={20,310},size={440,20},fsize=14,title="Target folder name"
	Button create_target,pos={470,310},size={60,20},fColor=(0,0,65535),valueColor=(65535,65535,65535),fsize=14,proc=RIXSStanford#CreateTargetDFProc,title="\y+15Create"
	Button Browse_target,pos={540,310},size={60,20},fColor=(0,0,65535),valueColor=(65535,65535,65535),fsize=14,proc=RIXSStanford#BrowseTargetDFProc,title="\y+15Browse"
	SetVariable target_file_name,pos={20,340},size={580,20},fsize=14,title="Target file name prefix (leave blank to use original name)"
	CheckBox loadAll, pos={20, 370},size={100, 20},fsize=14,title="Load all files?",proc=RIXSStanford#LoadAllDFProc
	SetVariable index_l,disable=2,value=from_i,pos={150,370},size={90,20},fsize=14,limits={000,999,001},proc=RIXSStanford#FromIProc,title="from",format="%03d"
	SetVariable index_h,disable=2,value=to_i,pos={250,370},size={80,20},fsize=14,limits={000,999,001},proc=RIXSStanford#ToIProc,title="to",format="%03d"
	PopupMenu precision,disable=2,pos={340,370},size={50,60},fsize=14,mode=1,proc=RIXSStanford#PrecisionProc,title="with ",value="2;3;4;5;6;7",popvalue="3"
	Titlebox degits,disable=2,pos={415,370},size={50,60},fsize=14,frame=0,title="digits"
	Button load,pos={480,370},size={120,55},fColor=(0,0,65535),labelBack=0,fsize=20,proc=RIXSStanford#LoadFileProc,title="Import"
	CheckBox doublePrecision, pos={20,400},size={40, 20},fsize=14,title="Double precision"
	CheckBox overwrite, pos={200,400},size={180, 20},fsize=14,title="Overwrite existing waves"
	
	DoWindow/C RIXSLoadPanel
End

static Function/D GetTotalColumnNum()
	Variable num=0,err
	String message
	SetDF()
	SVAR source_path=source_path
	SVAR extension=extension
	RestoreDF()
	
	newpath/O/Q symbolic_source_path source_path
	String filelist_unsorted= IndexedFile(symbolic_source_path,-1,extension)
	String filelist = SortList(filelist_unsorted, ";", 64)
	Variable numItems=ItemsInList(filelist)
	If (numItems==0)
		DoAlert 0,"Do not find any "+extension+" file in the selected folder."
		return 0
   EndIf
   do
   	String fname = stringfromlist(num,filelist)
   	SetDF()
   	LoadWave/A=loadedColumn/G/Q/D/P=symbolic_source_path/O/L={0,0,0,0,0} fname
   	err = GetRTError(0)
		If (err != 0)
			message = GetErrMessage(err)
			Printf "All files with extension "+extension+" contain no data."
			DoAlert 0, "All files with extension "+extension+" contain no data. \rNotice: Files with only one line of data can not be handled."
			err = GetRTError(1)			// Clear error state
			Print "Continuing execution"
		EndIf
   	num+=1
   while (V_flag==0 && num<numItems)
   RestoreDF()  
   If (V_flag==-1)
   	return 0
   Else
		return V_flag
	EndIf
End

static Function BrowseFileProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	If (B_Struct.eventCode!=2)
		return 0
	EndIf
	
	SetDF()
	SVAR source_path=source_path
	SVAR extension=extension
	NVAR totalNumColumn=totalNumColumn
	RestoreDF()
	
	do
		//Ask the user to identify a folder on the computer
		getfilefolderinfo/D/Q/Z=2
		//If user cancelled the Open Folder dialog
		If (V_Flag==-1)
			print "User cancelled to open folder dialog."
			return 0
		//If the selected folder is found
		ElseIf (V_Flag==0 && V_isFolder)
			print "Selected folder is found."
			//Store the folder that the user has selected as a new symbolic path in IGOR
			source_path = S_path
			SetVariable source_folder_name, value=source_path
			If (cmpstr(extension, ".txt")==0 || cmpstr(extension, ".dat")==0 || cmpstr(extension, ".xas")==0 || cmpstr(extension, "????")==0)	
				totalNumColumn=GetTotalColumnNum()
				SetVariable totalNumColumn,disable=2,value=totalNumColumn
				return 0
			EndIf
		//If the selected folder is not found
		Else 
			DoAlert 1, "Selected folder is not found. Do you want to select again?"
			If (V_Flag!=1)
				break
			EndIf
		EndIf
	while (V_Flag!=-1 && V_Flag!=0)
	return 0
End

static Function LoadFileExtensionProc (PU_Struct) : PopupMenuControl
	STRUCT WMPopupAction &PU_Struct
	
	If (PU_Struct.eventCode!=2)
		return 0
	EndIf
	
	SetDF()
	SVAR source_path=source_path
	SVAR extension=extension
	NVAR totalNumColumn=totalNumColumn
	RestoreDF()
	
	extension=PU_Struct.popStr
	
	If (cmpstr(source_path,"")!=0)	
		totalNumColumn=GetTotalColumnNum()
		SetVariable totalNumColumn,disable=2,value=totalNumColumn
	EndIf
	return 0
End

static Function PrecisionProc (PU_Struct) : PopupMenuControl
	STRUCT WMPopupAction &PU_Struct
	
	If (PU_Struct.eventCode!=2)
		return 0
	EndIf
	
	SetDF()
	NVAR precision=precision
	RestoreDF()
	
	precision=str2num(PU_Struct.popStr)
	
	return 0
End

static Function LoadParameterProc (PU_Struct) : PopupMenuControl
	STRUCT WMPopupAction &PU_Struct
	
	If (PU_Struct.eventCode!=2)
		return 0
	EndIf
	
	String path_listWave = "root:RIXS_Analysis_Macro_System_File:listbox_listWave"
	String path_selWave = "root:RIXS_Analysis_Macro_System_File:listbox_selWave"
	
	SetDF()
	SVAR preload_parameters=preload_parameters
	NVAR numColumn=numColumn
	NVAR totalNumColumn=totalNumColumn
	wave listbox_list

	preload_parameters=PU_Struct.popStr
	strswitch(preload_parameters)
		case "ALS XAS":
			If (4>totalNumColumn)
				DoAlert 0,"More columns to be loaded than the total number of columns in the files."
				return 0
			EndIf
			numColumn = 4
			SetVariable numColumn, value=numColumn
			Make/O/T/N=(numColumn,2) listbox_listWave={{"1","3","5","6"},{"BL_energy","AI0","AI2","AI1"}}
			break	
		case "ALS RIXS":
			
			If (1>totalNumColumn)
				DoAlert 0,"More columns to be loaded than the total number of columns in the files."
				return 0
			EndIf
			numColumn = 1
			SetVariable numColumn, value=numColumn
			Make/O/T/N=(numColumn,2) listbox_listWave={{"1"},{"intensity"}}
			break	
		case "ESRF XAS":
			If (2>totalNumColumn)
				DoAlert 0,"More columns to be loaded than the total number of columns in the files."
				return 0
			EndIf
			numColumn = 2
			SetVariable numColumn, value=numColumn
			Make/O/T/N=(numColumn,2) listbox_listWave={{"0","1"},{"BL_energy","intensity"}}
			break	
		case "ESRF RIXS":
			If (2>totalNumColumn)
				DoAlert 0,"More columns to be loaded than the total number of columns in the files."
				return 0
			EndIf
			numColumn = 2
			SetVariable numColumn, value=numColumn
			Make/O/T/N=(numColumn,2) listbox_listWave={{"0","1"},{"BL_energy","intensity"}}
			break	
	EndSwitch
	Make/O/N=(numColumn,2) listbox_selWave = 2
	RestoreDF()
	wave/T listbox_listWave = $path_listWave
	wave listbox_selWave = $path_selWave
	ListBox Set_column, listwave=listbox_listWave,selWave=listbox_selWave
	return 0
End

static Function AddRowProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	If (B_Struct.eventCode!=1)
		return 0
	EndIf
	SetDF()
	NVAR numColumn=numColumn
	NVAR totalNumColumn=totalNumColumn
	If (numColumn+1>totalNumColumn)
		DoAlert 0,"Maximum number of columns reached."
		RestoreDF()
		return 0
	Else
		numColumn+=1
		SetVariable numColumn, value=numColumn,limits={0,totalNumColumn,1}
		wave/T listbox_listWave
		If (!waveexists(listbox_listWave))
			Make/T/N=(numColumn,2) listbox_listWave
			listbox_listWave[][]=""
		Else
			Redimension/N=(numColumn,2) listbox_listWave
		EndIf
		Make/O/N=(numColumn,2) listbox_selWave = 2
		RestoreDF()
		String path_listWave = "root:RIXS_Analysis_Macro_System_File:listbox_listWave"
		String path_selWave = "root:RIXS_Analysis_Macro_System_File:listbox_selWave"
		wave/T listbox_listWave = $path_listWave
		wave listbox_selWave = $path_selWave
		ListBox Set_column, listwave=listbox_listWave,selWave=listbox_selWave
		return 0
	EndIf
End

static Function DeleteRowProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	If (B_Struct.eventCode!=1)
		return 0
	EndIf
	SetDF()
	NVAR numColumn=numColumn
	NVAR totalNumColumn=totalNumColumn
	If (numColumn==0)
		RestoreDF()
		return 0
	Else
		numColumn-=1
		SetVariable numColumn, value=numColumn,limits={0,totalNumColumn,1}
		wave/T listbox_listWave
		If (!waveexists(listbox_listWave))
			Make/T/N=(numColumn,2) listbox_listWave
			listbox_listWave[][]=""
		Else
			Redimension/N=(numColumn,2) listbox_listWave
		EndIf
		Make/O/N=(numColumn,2) listbox_selWave = 2
		RestoreDF()
		String path_listWave = "root:RIXS_Analysis_Macro_System_File:listbox_listWave"
		String path_selWave = "root:RIXS_Analysis_Macro_System_File:listbox_selWave"
		wave/T listbox_listWave = $path_listWave
		wave listbox_selWave = $path_selWave
		ListBox Set_column, listwave=listbox_listWave,selWave=listbox_selWave
		return 0
	EndIf
End

static Function ClearProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	If (B_Struct.eventCode!=1)
		return 0
	EndIf
	
	SetDF()
	NVAR numColumn=numColumn
	NVAR totalNumColumn=totalNumColumn
	numColumn=0
	SetVariable numColumn, value=numColumn,limits={0,totalNumColumn,1}
	wave/T listbox_listWave
	Make/O/T/N=(numColumn,2) listbox_listWave
	listbox_listWave[][]=""
	Make/O/N=(numColumn,2) listbox_selWave = 2
	RestoreDF()
	String path_listWave = "root:RIXS_Analysis_Macro_System_File:listbox_listWave"
	String path_selWave = "root:RIXS_Analysis_Macro_System_File:listbox_selWave"
	wave/T listbox_listWave = $path_listWave
	wave listbox_selWave = $path_selWave
	ListBox Set_column, listwave=listbox_listWave,selWave=listbox_selWave
	return 0
End

static Function CreateTargetDFProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	If (B_Struct.eventCode!=1)
		return 0
	EndIf
	
	SetDF()
	SVAR target_path=target_path
	RestoreDF()
	
	If (cmpstr(target_path,"")==0)
		DoAlert 0,"Please specify the target data folder name."
		return 0
	EndIf
	NewDataFolder/S/O $target_path
	return 0
End

static Function BrowseTargetDFProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	If (B_Struct.eventCode!=1)
		return 0
	EndIf
	
	Variable n
	
	setDF()
	SVAR target_path=target_path
	setDataFolder root:
	do
		createbrowser prompt="Select Data Folder" ,expandall, showwaves=0, showvars=0, showstrs=0
		n = ItemsInList(S_BrowserList, ";")
		If (V_Flag==0)
			break
		EndIf
		If (n==0)
			DoAlert 0,"Please select at least one folder."
		EndIf
		If (n>1)
			DoAlert 0,"Please only select one folder."
		EndIf
	while (n!=1)
	target_path=stringfromlist(0,S_BrowserList)
	target_path=target_path[0,strlen(target_path)-2]
	RestoreDF()
	return 0
End

static Function LoadAllDFProc(CB_Struct) : CheckBoxControl
	STRUCT WMCheckboxAction &CB_Struct

	If (CB_Struct.checked==1)
		SetVariable index_l,disable=2
		SetVariable index_h,disable=2
		PopupMenu precision,disable=2
		Titlebox degits,disable=2
	ElseIf (CB_Struct.checked==0)
		SetVariable index_l,disable=0
		SetVariable index_h,disable=0
		PopupMenu precision,disable=0
		Titlebox degits,disable=0
	Else
		DoAlert 0,"Check box is in undefined status."
	EndIf
	return 0
End

static Function FromIProc(SV_Struct) : SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	SetDF()
	NVAR from_i=from_i
	NVAR to_i=to_i
	RestoreDF()
	SetVariable index_l,limits={000,to_i,001}
	return 0
End

static Function ToIProc(SV_Struct) : SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	SetDF()
	NVAR from_i=from_i
	NVAR to_i=to_i
	RestoreDF()
	SetVariable index_h,limits={from_i,999,001}
	return 0
End

static Function TotalNumColumnProc(SV_Struct) : SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	SetDF()
	NVAR numColumn=numColumn
	NVAR totalNumColumn=totalNumColumn
	RestoreDF()
	If (totalNumColumn<numColumn)
		SetDF()
		numColumn=totalNumColumn
		SetVariable numColumn, value=numColumn
		Make/O/T/N=(numColumn,2) listbox_listWave
		listbox_listWave[][]=""
		Make/O/N=(numColumn,2) listbox_selWave = 2
		RestoreDF()
		String path_listWave = "root:RIXS_Analysis_Macro_System_File:listbox_listWave"
		String path_selWave = "root:RIXS_Analysis_Macro_System_File:listbox_selWave"
		wave/T listbox_listWave = $path_listWave
		wave listbox_selWave = $path_selWave
		ListBox Set_column, listwave=listbox_listWave,selWave=listbox_selWave
	EndIf
	return 0
End

static Function LoadFileColumnProc(SV_Struct) : SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	
	SetDF()
	NVAR numColumn=numColumn
	NVAR totalNumColumn=totalNumColumn
	SetVariable numColumn, value=numColumn,limits={0,totalNumColumn,1}
	wave/T listbox_listWave
	If (!waveexists(listbox_listWave))
		Make/T/N=(numColumn,2) listbox_listWave
		listbox_listWave[][]=""
	Else
		Redimension/N=(numColumn,2) listbox_listWave
	EndIf
	Make/O/N=(numColumn,2) listbox_selWave = 2
	RestoreDF()
	String path_listWave = "root:RIXS_Analysis_Macro_System_File:listbox_listWave"
	String path_selWave = "root:RIXS_Analysis_Macro_System_File:listbox_selWave"
	wave/T listbox_listWave = $path_listWave
	wave listbox_selWave = $path_selWave
	ListBox Set_column, listwave=listbox_listWave,selWave=listbox_selWave
	return 0
End

static Function LoadPanelHook(infoStr)
	String infoStr
	
	String event= StringByKey("EVENT",infoStr)
	strswitch(event)
		case "kill":
			SaveLoadPrefs()
			break
	endswitch
	return 0
End

static Function/S GenerateColumnInfo(wname)
	String wname
	String cname
	String columnInfoStr="",column_name=""
	Variable i,column_num
	SetDF()
	NVAR numColumn=numColumn
	NVAR totalNumColumn=totalNumColumn
	Wave/T listbox_listWave
	Make/T/O/N=(totalNumColumn) dulWv="'_skip_'"
	For (i=0;i<=numColumn-1;i+=1)
		If (cmpstr(listbox_listWave[i][0],"")!=0)
			dulWv[str2num(listbox_listWave[i][0])]=listbox_listWave[i][1]
		EndIf
	EndFor
	For (i=0;i<=dimsize(dulWv,0)-1;i+=1)
		cname=dulWv[i]
		If (cmpstr(cname,"'_skip_'")==0)
			columnInfoStr+="C=1,N='_skip_';"
		Else
			columnInfoStr+="C=1,N="+wname+"_"+cname+";"
		EndIf
	EndFor
	RestoreDF()
	return columnInfoStr
End

static Function/S isIntegerNumber(str)
	String str
	Variable i
	For (i=0;i<=strlen(str)-1;i+=1)
		If (numtype(str2num(str[i]))==2)
			return "False"
		EndIf
	EndFor
	return "True"
End

static Function/S FileNameInRange(fname)
	String fname
	String file_name_index
	SetDF()
	NVAR from_i=from_i
	NVAR to_i=to_i
	NVAR precision=precision
	RestoreDF()
	Variable i=from_i
	do
		Sprintf file_name_index, "%0"+num2str(precision)+"d",i
		If (strsearch(ParseFilePath(3, fname, ":", 0, 0),file_name_index,Inf,1)!=-1)
			return file_name_index
		EndIf
		i+=1
	while (i<=to_i)
	return "False"
End

// load series of general text spectra
static Function LoadFileProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	If (B_Struct.eventCode!=1)
		return 0
	EndIf
	
	Variable i,j,k,num=0,err
	String columnInfoStr,temp_wname="",cname="",message
	SetDF()
	SVAR source_path=source_path
	SVAR target_path=target_path
	SVAR target_name=target_name
	SVAR extension=extension
	NVAR overwrite=overwrite
	NVAR doublePrecision=doublePrecision
	NVAR loadAll=loadAll
	NVAR from_i=from_i
	NVAR to_i=to_i
	NVAR totalNumColumn=totalNumColumn
	RestoreDF()
	
	If (cmpstr(source_path,"")==0)
		DoAlert 0,"Please specify the source data folder name."
		return 0
	EndIf
	If (cmpstr(extension,"")==0 || cmpstr(extension, "    ")==0)
		DoAlert 0,"Please specify the source file extension."
	ElseIf (cmpstr(extension, ".txt")!=0 && cmpstr(extension, ".dat")!=0 && cmpstr(extension, ".xas")!=0 && cmpstr(extension, "????")!=0)
		DoAlert 0,"Only accept .txt, .dat, .xas, ???? type."
	return 0
	EndIf
	If (cmpstr(target_path,"")==0)
		DoAlert 0, "Please specify the target data folder name."
		return 0
	EndIf
	SetDF()
	Wave/T listbox_listWave
	String column_index,column_name
	For (i=0;i<=dimsize(listbox_listWave,0)-1;i+=1)
		column_index=listbox_listWave[i][0]
		column_name=listbox_listWave[i][1]
		If (cmpstr(column_index,"")!=0)
			If (cmpstr(isIntegerNumber(column_index),"False")==0)
				RestoreDF()
				DoAlert 0,"Column index must be a nonnegative integer number"
				return 0
			Else
				If (str2num(column_index)>=totalNumColumn)
					RestoreDF()
					DoAlert 0,"Column index exceeds range"
					return 0
				EndIf
			EndIf
			If (cmpstr(column_name,"")==0)
				RestoreDF()
				DoAlert 0,"Missing column name."
				return 0
			EndIf
			num+=1
		Else
			If (cmpstr(column_name,"")!=0)
				RestoreDF()
				DoAlert 0,"Missing column index."
				return 0
			EndIf
		EndIf
	EndFor
	RestoreDF()
	If (num==0)
		DoAlert 0,"Please specify the column information."
		return 0
	EndIf

	//Create a list of all files that are files with a specific extension in the folder. -1 parameter addresses all files.
	newpath/O/Q symbolic_source_path source_path
	String filelist_unsorted= IndexedFile(symbolic_source_path,-1,extension)
	String filelist = SortList(filelist_unsorted, ";", 64)
	String fname,wname_prefix,file_name_index
	Variable numItems=ItemsInList(filelist)
	If (numItems==0)
		DoAlert 1,"Do not find any "+extension+" file.\nContinue to load "+extension+" files?"
		If (V_Flag!=1)
      	return 0       // User canceled
      EndIf 	
   EndIf
   
	NewDataFolder/S/O $target_path
	For(i=0;i<=numItems-1;i+=1)
		//store the ith name in the list into wname_prefix.
		fname = stringfromlist(i,filelist)
		file_name_index = FileNameInRange(fname)
		If (loadAll!=1 && cmpstr(file_name_index,"False")==0)
			continue
		Endif
		//use original file name as prefix
 		If (cmpstr(target_name,"")==0)
   		//strip away extension
			wname_prefix = ParseFilePath(3, fname, ":", 0, 0)
		//user-defined file name prefix
		Else
			wname_prefix = target_name+"_"+file_name_index
		EndIf
		wname_prefix = ReplaceString("-",wname_prefix,"_")
				
		//reference a wave with the name of the wname_prefix
		Wave w = $wname_prefix
		
		columnInfoStr=GenerateColumnInfo(wname_prefix)
		
		//load .txt, .dat, .xas, ???? type of file
		If (cmpstr(extension, ".txt")==0 || cmpstr(extension, ".dat")==0 || cmpstr(extension, ".xas")==0 || cmpstr(extension, "????")==0)		
			If (overwrite!=1)
				SetDF()
				wave/T dulWv
				Duplicate/T/O dulWv, newWv
				RestoreDF()
				For (j=0;j<=dimsize(newWv,0)-1;j+=1)
					If (cmpstr(newWv[j],"'_skip_'")!=0)
						temp_wname=wname_prefix+"_"+newWv[j]
						If (waveexists($temp_wname))
							print "Skip "+temp_wname+". Already exists."	
							newWv[j]="'_skip_'"
						Else
							print "Load "+temp_wname+"."
						EndIf
					EndIf
				EndFor
				String new_columnInfoStr=""
				For (k=0;k<=dimsize(newWv,0)-1;k+=1)
					cname=newWv[k]
					If (cmpstr(cname,"'_skip_'")==0)
						new_columnInfoStr+="C=1,N='_skip_';"
					Else
						new_columnInfoStr+="C=1,N="+wname_prefix+"_"+cname+";"
					EndIf
				EndFor
				LoadWave/A/G/Q/D/P=symbolic_source_path/B=new_columnInfoStr fname
			Else
				SetDF()
				wave/T dulWv
				Duplicate/T/O dulWv, newWv
				RestoreDF()
				For (j=0;j<=dimsize(newWv,0)-1;j+=1)
					If (cmpstr(newWv[j],"'_skip_'")!=0)
						temp_wname=wname_prefix+"_"+newWv[j]
						If (waveexists($temp_wname))
							print "Overwrite "+temp_wname+"."	
						Else
							print "Load "+temp_wname+"."
						EndIf
					EndIf
				EndFor
				If (doublePrecision==1)
					LoadWave/A/G/Q/D/P=symbolic_source_path/O/B=columnInfoStr fname
				Else
					LoadWave/A/G/Q/P=symbolic_source_path/O/B=columnInfoStr fname
				EndIf
 			EndIf
 			err = GetRTError(0)
			If (err != 0)
				message = GetErrMessage(err)
				Printf "When loading file: %s, following error occurs: %s", fname, message
				DoAlert 0, "When loading file: "+fname+", following error occurs: "+message+". \rContinuing execution."
				err = GetRTError(1)			// Clear error state
				Print "Continuing execution"
			EndIf
 		//handle other type of file
		Else
			print "Does not support format other than txt/dat/xas now."
		EndIf
	EndFor
	SaveLoadPrefs()
	return 0
End