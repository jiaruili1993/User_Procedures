#pragma rtGlobals=2		// Use modern global access method.#pragma version = 2.00#pragma IgorVersion = 5.0	// According to the help, this only works for Igor >= 4. This is why there is a second check in this file./////////////////////////// i_photo///////////////////////////// a collection of igor procedures to handle angular resolved photoemission data. // Written in Zurich & Stanford by Felix Baumberger, Felix Schmitt, Wei-Sheng Lee, // Nik Ingle and Non Meevasana//// Some of the ideas are stolen from Kyle's ULTRA.// Thanks to Nik for all the discussions and the feed-back.////                                                                     PLEASE DO NOT DISTRIBUTE// in case of problems contact Felix Schmitt, fschmitt@stanford.edu////////////////////////// first igor opens and compiles this file. After this the hook-function is executedConstant i_photo_version_major = 2	Constant i_photo_version_minor = 23StrConstant i_photo_date = "20jul09"			// used as annotation onlyStrConstant i_photo_modules = "bzplanner;DC;fileloader;filetable;fit;fsmap;globals;gold;help;marquee;merger;norm;panelcommon;prefs;process;utils;prettypretty;lda"//// This is used by the i_photo_upgrade() function in order to close the panels. This is a list of modules and//// their respective panels.//StrConstant i_photo_modules_panels = "bzplanner_panel;DC_panel;filetable_panel;filetable_table;fit_panel;fsmap_panel;gold_panel;help_panel;merger_panel;norm_panel;prefs_panel;process_panel;prettypretty_panel"// symbolic path: i_photo_path// symbolic path: i_photo_supplementalPath (see i_photo() below for definition)// NOTE:// The procedure file names, the ModuleName pragmas, and the // words in the list i_photo_modules HAVE TO BE THE SAME.// -->procedure file names, the i_photo_modules, and the #pragma ModuleName // inside the procedure files must be changed at the same time.#include ":User procedures:i_photoRIXS:i_bzplanner", version>=3.00#include ":User procedures:i_photoRIXS:i_DC", version>=3.00#include ":User procedures:i_photoRIXS:i_fileloader", version>=2.00#include ":User procedures:i_photoRIXS:i_filetable", version>=3.00#include ":User procedures:i_photoRIXS:i_fit", version>=2.00#include ":User procedures:i_photoRIXS:i_fsmap", version>=3.00#include ":User procedures:i_photoRIXS:i_globals", version>=2.00#include ":User procedures:i_photoRIXS:i_gold", version>=2.00#include ":User procedures:i_photoRIXS:i_help", version>=2.00#include ":User procedures:i_photoRIXS:i_marquee", version>=2.00#include ":User procedures:i_photoRIXS:i_merger", version>=2.00#include ":User procedures:i_photoRIXS:i_norm", version>=2.00#include ":User procedures:i_photoRIXS:i_panelcommon", version>=1.00#include ":User procedures:i_photoRIXS:i_prefs", version>=3.00#include ":User procedures:i_photoRIXS:i_process", version>=3.00#include ":User procedures:i_photoRIXS:i_utils", version>=2.00#include ":User procedures:i_photoRIXS:i_prettypretty", version>=2.00#include ":User procedures:i_photoRIXS:i_lda", version>=2.00#include ":User procedures:Special Functions Add On"Function AfterFileOpenHook(refnum, filename, symPath, type, creator, kind)	Variable	refnum, kind	String 		filename, symPath, type, creator		if (stringmatch(filename,"*.pxt") || stringmatch(filename,"*.pxp"))		execute/P/Q "i_photo()"	else		execute/P/Q "print \"Opened file is not an experiment file: '"+filename+"'. Not re-initializing i_photo.\""	endif	return 0EndMenu "i_photo", dynamic	// this tricks Igor into initializing i_photo whenever somebody clicks on the i_photo menu	i_photo(initOnlyIfNeeded=1)	"load Scienta.pxt",/q, fileloader_loadSESpxt()	"-"	"Cut-planner/1",/q, bzplanner_open("")	"Display/2",/q, DC_open("")	"Filetable/3",/q, filetable_open("")	"Fit/4",/q, fit_open("")	"FS Map/5",/q, fsmap_open("")	"Gold/6",/q, gold_open("")	"Merger/7",/q, merger_open("")	"Normalize/8",/q, norm_open("")	"Process/9",/q, process_open("")	"Make It Pretty/0",/q, prettypretty_open("")	"-"	"Help",/q, help_open("")	"-"	"Preferences",/q, prefs_openPanel()	"-"	"re-init i_photo",/q, i_photo()	"upgrade or fix pxp",/q, i_photo_upgrade()EndStatic Function upgrade_checkWindow(w)	String w	String list	Variable i	switch(WinType(w))		case 1: // graph			// check for traces			list = TraceNameList(w, ";", 1)			for (i = 0; i < ItemsInList(list); i += 1)				WAVE wv = TraceNameToWaveRef(w, StringFromList(i, list))				if (stringmatch(GetWavesDataFolder(wv, 1), "root:internalUse:*"))					return 1				endif			endfor			// check for images			list = ImageNameList(w, ";")			for (i = 0; i < ItemsInList(list); i += 1)				WAVE wv = ImageNameToWaveRef(w, StringFromList(i, list))				if (stringmatch(GetWavesDataFolder(wv, 1), "root:internalUse:*"))					return 1				endif			endfor			// check for contours			list = ContourNameList(w, ";")			for (i = 0; i < ItemsInList(list); i += 1)				WAVE wv = ContourNameToWaveRef(w, StringFromList(i, list))				if (stringmatch(GetWavesDataFolder(wv, 1), "root:internalUse:*"))					return 1				endif			endfor			// next, check for subwindows			list = ChildWindowList(w)			for(i = 0; i < ItemsInList(list); i += 1)				if (upgrade_checkWindow(w+"#"+StringFromList(i, list)))					return 1				endif			endfor			// Also, we need to check for controls, i.e. buttons, etc. linked to variables in root:internalUse:		case 7: // panel			list = ControlNameList(w)			for(i = 0; i < ItemsInList(list); i += 1)				String S_DataFolder = ""				ControlInfo/W=$w $(StringFromList(i, list))				if (stringmatch(S_DataFolder, "root:internalUse*"))					return 1				endif			endfor			break		case 2: // table			for(i=0; i < NumberByKey("COLUMNS", TableInfo(w, -2)) - 1; i += 1)				if(stringmatch(StringByKey("WAVE", TableInfo(w, i)), "root:internalUse*"))					return 1				endif			endfor		case 3: // layout			// next, check for subwindows			list = ChildWindowList(w)			for(i = 0; i < ItemsInList(list); i += 1)				if (upgrade_checkWindow(w+"#"+StringFromList(i, list)))					return 1				endif			endfor			for(i=0; i < NumberByKey("NUMOBJECTS", LayoutInfo(w, "Layout")); i+=1)				String info = LayoutInfo(w, num2istr(i))				strswitch(StringByKey("TYPE", info))					case "Graph":					case "Table":						if (upgrade_checkWindow(StringByKey("NAME", info)))							return 1						endif						break				endswitch			endfor		break	endswitch	return 0EndFunction i_photo_upgrade()	strswitch(i_photo_checkNeedsUpgrade())		case "noFolder":		case "pxpUpToDate":			DoAlert 1, "Your pxp seems up-to-date. Do you want to proceed anyway? (Sometimes useful as it may fix i_photo if sth got screwed up and not working properly anymore)"			if(V_flag == 2)				return 0			endif			break		case "pxpNeedsUpgrade":			break		case "pxpNewerVersion":			DoAlert 1, "Your pxp is newer than your installed i_photo. It is *highly* recommended you install the newest i_photo. Proceed anyway? (Don't whine if nothing works afterwards)"			if(V_flag == 2)				return 0			endif			break	endswitch	NVAR gv_iphoto_version_major = root:internalUse:gv_iphoto_version_major	NVAR gv_iphoto_version_minor = root:internalUse:gv_iphoto_version_minor	DoAlert 1, "Upgrading involves deleting the entire root:internalUse folder. All info enered into any i_photo panel will be gone, but all other user-generated info (like graphs etc.) will be retained. Shall I go ahead?"	if(V_Flag == 2)		DoAlert 0, "Not upgrading can lead to problems like buttons in panels not working or other random errors. Make sure to upgrade once you have saved all your stuff from the root:internalUse folder."		return 0	endif	DoAlert 1, "Do you want me to try and close all windows that use data from the root:internalUse folder? (If you click no, I assume you already closed all these windows yourself)"	if (V_Flag == 1)		Variable i		String wlist = WinList("*", ";", "WIN:71")		for(i = 0; i < ItemsInList(wlist); i += 1)			if (upgrade_checkWindow(StringFromList(i, wlist)))				DoWindow/F $StringFromList(i, wlist)				DoAlert 1, "Found window '" + StringFromList(i, wlist) + "'. Proceed and close? Press No if you want to abort; you can save your stuff and try upgrading again."				if (V_Flag == 2)					return 0				endif				DoWindow/K $StringFromList(i, wlist)			endif		endfor	endif	KillDataFolder/Z root:internalUse	if (V_flag != 0)		DoAlert 0, "Could not delete root:internalUse, probably because there is still some window open that uses this folder. You need to find the window and close it."		return 0	endif	// Successfully killed root:internalUse.	NewDataFolder/O/S root:internalUse	// Set the version to the latest one...	Variable/G gv_iphoto_version_major = i_photo_version_major	Variable/G gv_iphoto_version_minor = i_photo_version_minor	// ...and do a full reinit.	i_photo(initOnlyIfNeeded = 0)	DoAlert 0, "Successfully upgraded pxp to version "+num2istr(i_photo_version_major)+"."+num2istr(i_photo_version_minor)+"."	return 1End// Checks if the current pxp is up-to-date or not. // Returns:// "noFolder" - root:internalUse does not exist. No upgrade needed/possible.// "pxpNeedsUpgrade" - pxp is of an earlier version. Needs upgrading.// "pxpUpToDate" - pxp is up-to-date.// "pxpNewerVersion" - pxp is of a newer version than the i_photo macros. This is bad.Function/S i_photo_checkNeedsUpgrade()	if (DataFolderExists("root:internalUse") == 0)		return "noFolder"	endif 	// our data folder exists. So, there is the possibility of an earlier i_photo version.	// Version numbers were first introduced in version 2.23. If there are no version number 	// variables, then this is for sure older than the current version, and we need to update.	NVAR gv_iphoto_version_major = root:internalUse:gv_iphoto_version_major	NVAR gv_iphoto_version_minor = root:internalUse:gv_iphoto_version_minor	if (NVAR_Exists(gv_iphoto_version_major) == 0 || NVAR_Exists(gv_iphoto_version_minor) == 0)		return "pxpNeedsUpgrade"	endif		// Version numbers exist. Check if they are current.	if (gv_iphoto_version_major < i_photo_version_major)		return "pxpNeedsUpgrade"	endif		if (gv_iphoto_version_major == i_photo_version_major)		if (gv_iphoto_version_minor < i_photo_version_minor)			return "pxpNeedsUpgrade"		endif		if (gv_iphoto_version_minor == i_photo_version_minor) // PANIC NOW!			return "pxpUpToDate"		endif		return "pxpNewerVersion"	endif	return "pxpNewerVersion"EndFunction/S i_photo([initOnlyIfNeeded])	Variable initOnlyIfNeeded		if (ParamIsDefault(initOnlyIfNeeded))		initOnlyIfNeeded = 0	endif		Variable internalUse_exists = DataFolderExists("root:internalUse")	strswitch(i_photo_checkNeedsUpgrade())		case "noFolder":			// This is a new experiment. -> Set the version numbers up-to-date so that the upgrade checker doesn't complain			NewDataFolder/O/S root:internalUse			// Set the version to the latest one...			Variable/G gv_iphoto_version_major = i_photo_version_major			Variable/G gv_iphoto_version_minor = i_photo_version_minor		case "pxpUpToDate":			break		case "pxpNeedsUpgrade":			if (initOnlyIfNeeded == 0) // Only show this dialogue when i_photo is first called after opening an experiment.				DoAlert 0, "Since version 2.23, upgrading the pxp files to the newest i_photo version is supported. Your pxp file seems not up-to-date which can lead to problems. Click on upgrade in the i_photo menu to fix this."			endif			break		case "pxpNewerVersion":			if (initOnlyIfNeeded == 0) // Only show this dialogue when i_photo is first called after opening an experiment.				DoAlert 0, "Your pxp file seems to be generated with a newer version of i_photo than the one you have installed. Please install the newest i_photo macros to avoid random errors & problems."			endif			break	endswitch	if (internalUse_exists && initOnlyIfNeeded)		String DF = GetDataFolder(1)		SetDataFolder root:internalUse		// If the user programs something and if the background task comes along and tries to		// execute the autosave function, it tries to compile all procedure windows. If it fails,		// the autosave is broken. So, as soon as the user has fixed his stuff and everything is		// recompiled, we need to set up the autosave task again. I wish there was an Igor		// hook that gets executed everytime something is compiled successfully, but alas		// that is not available. So, instead, we check everytime the user clicks on the i_photo		// menu if the background task is actually running and restart it if neccessary.		BackgroundInfo		if (V_flag != 2)			printf "WARNING: Autosave task was not running. Trying to reinitialize.\r"			prefs_initAutosaveTask()		endif		SetDataFolder $DF				return ""	endif	// generate a symbolic path ('i_photo_path', 'i_photo_pathSupplemental') to the i_photo 	// folder on the local HD	PathInfo Igor	// symbolic path to the i_photo Folder, where all ipf files should go:	NewPath/Q/C/O i_photo_path S_Path+"User Procedures:i_photoRIXS"	// symbolic path to the i_photo supplemental Folder, where all stuff other 	// than ipf files should go:	NewPath/Q/C/O i_photo_pathSupplemental S_Path+"User Procedures:i_photoRIXS:supplemental"		// generate the basic DF-Structure	NewDataFolder/O/S root:internalUse	NewDataFolder/O normalize	NewDataFolder/O panelcommon	NewDataFolder/O/S Prefs		NewDataFolder/O/S root:carpets	NewDataFolder/O rawData	NewDataFolder/O/S normalized	NewDataFolder/O NormWaves		// load the generic NormWaves:	SetDataFolder root:carpets:normalized:NormWaves	LoadWave/O/Q/T/P=i_photo_pathSupplemental/O "NormWaves.itx"		// load the prefs:		SetDataFolder root:InternalUse:prefs	LoadWave/O/Q/T/P = i_photo_pathSupplemental "Pref_waves.itx"			WAVE/T strNames = Pref_strNames	WAVE/T varNames = Pref_varNames	WAVE/T strValues = Pref_strValues	WAVE varValues = Pref_varValues		Variable i	for (i = 0; i < numpnts(varNames); i += 1)		Variable/G $varNames[i]=varValues[i]		String/G $strNames[i]=strValues[i]	endfor				SetDataFolder root:			printf "%s, %s. Starting i_photo.\r", date(), time()		// Install the i_photo package in the procedure window:	Execute/Q/P "INSERTINCLUDE \":User procedures:i_photoRIXS:i_photo\", version>=2.00"		Execute/Q/P "COMPILEPROCEDURES "	Execute/Q/P "HideProcedures"		// Install the autosave background task:	prefs_initAutosaveTask()	return ""End