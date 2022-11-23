#pragma rtGlobals = 1
#pragma ModuleName = help
#pragma IgorVersion = 5
#pragma version = 2.00













/////////////////////////////////////////
//
// Public Functions
//
/////////////////////////////////////////













Function help_open(ctrlname)
	String ctrlname
	String DF = GetDataFolder(1)
	NewDataFolder/O/S root:internalUse
	String/G gs_search
	
	DoWindow/K help_panel
	NewPanel /K=1 /W=(0,0,340,440)
	DoWindow/C help_panel
	utils_autoPosWindow("help_panel", win=127)

	GroupBox    gb0, pos={10,10}, size={320,160}, title="Browse Functions"
	CheckBox cbUserDef, pos={20,40},size={300,15}, title="Only search user def. functions", value = 1
	CheckBox cbShortOutput, pos={20,60},size={300,15}, title="Only output function headers", value = 0
	Button bUserFunc, pos={20,80},size={300,15},proc=help#buttonBrowseFuncs,title="All functions"
	Button biPhotoFunc, pos={20,100},size={300,15},proc=help#buttonBrowseFuncs,title="Functions of i_photo package"
	PopupMenu pmiPhotoModule, pos={20,120},size={200,15},title="i_photo module:",value=i_photo_modules
	Button biPhotoModuleFunc, pos={220,120},size={100,15},proc=help#buttonBrowseFuncs,title="--> Browse"
	Button bSearchFunc, pos={20,140},size={200,15},proc=help#buttonBrowseFuncs,title="Functions containing in their name:"
	SetVariable sv0, pos={230,140},size={90,15}, value=gs_search, title=" "

	GroupBox    gb1, pos={10,180}, size={320,80}, title="Help"
	Button bAbout, pos={20,210},size={300,15},proc=help#buttonAbout,title="About i_photo"
	Button bOpenHelp, pos={20,230},size={300,15},proc=help#buttonOpenHelp,title="Load & open manual"
	DrawText 20, 290, "To browse the complete list of topics and subtopics of"
	DrawText 20, 310, "the manual, go to Help -> Igor Help Browser, and in"
	DrawText 20, 330, "the Help Topics tab, select i_help.ihf in the Show Topics"
	DrawText 20, 350, "dropdown menu. You first need to load the help file by"
	DrawText 20, 370, "clicking on above button though."
	SetDataFolder $DF
End




Function help_functionList([match,kind,add,shortOutput])
	String match
	Variable kind
	Variable add
	Variable shortOutput
	
	if (ParamIsDefault(match))
		match = "*"
	endif
	if (ParamIsDefault(add))
		add = 0
	endif
	if (ParamIsDefault(shortOutput))
		shortOutput = 0
	endif

	String flist = FunctionList(match, ";", "")
	if (! ParamIsDefault(kind))
		flist = FunctionList(match, ";", "KIND:"+num2str(kind)) 
	endif

	flist = SortList(flist)
	
	if (WinType("FunctionListNotebook") == 0 || add == 0)
		DoWindow/K FunctionListNotebook
		NewNotebook/F=1/K=1/N=FunctionListNotebook 
		Notebook FunctionListNotebook, showRuler=0,statusWidth=0
		SetWindow FunctionListNotebook, hookEvents=1, hook=help#functionListHook
	endif
	
	PauseUpdate
	
	Variable i
	for(i = 0; i < ItemsInList(flist); i+=1)
		String fn = FunctionInfo(StringFromList(i, flist))
		if (strlen(fn)==0)
			if (!shortOutput)
				addFnText(StringFromList(i, flist)+": No info available (try Igor cmd help).\r",14,1)
				addFnText("\r\r",-1,0)
			else
				addFnText(StringFromList(i, flist)+": UNKNOWN/INTERNAL\r\r",-1,1)
			endif
			continue
		endif
		String s = StringByKey("NAME", fn) + "("
		Variable j
		for (j = 0; j < NumberByKey("N_PARAMS", fn); j += 1)
			s += interpretParamType(NumberByKey("PARAM_"+num2str(j)+"_TYPE", fn))
			if (j < NumberByKey("N_PARAMS", fn) - 1)
				s+=", "
			endif
		endfor
		s+=")"
		if (shortOutput)
			addFnText(s+" ", -1, 1)
			addFnText(" (returns "+interpretParamType(NumberByKey("RETURNTYPE", fn))+")\r\r", -1, 2)
			continue
		endif
		s+="\r"
		addFnText(s, 14, 1)
		addFnText("returns: ", -1, 1)
		addFnText(interpretParamType(NumberByKey("RETURNTYPE", fn))+"\r", -1, 0)
		addFnText("type: ", -1, 1)
		addFnText(StringByKey("TYPE", fn)+"\r", -1, 0)
		strswitch(StringByKey("TYPE", fn))
			case "UserDefined":
				if (!stringmatch(StringByKey("N_OPT_PARAMS", fn),"0"))
					addFnText("\t# opt params: "+ StringByKey("N_OPT_PARAMS", fn)+"\r", -1, 0)
				endif
				if (strlen(StringByKey("MODULE", fn)) != 0)
					addFnText("\tModule: "+ StringByKey("MODULE", fn)+"\r", -1, 0)
				endif
				addFnText("\tProcedure window: "+ StringByKey("PROCWIN", fn)+"\r", -1, 0)
				// Yet again, Igor chose to do things in the least useful way:
				// Don't know what PROCLINE is, but it's definitely NOT the line number
				// in the ipf file. Maybe the line number in Igor's global procedure stack?
				// Who cares about that?! If they really HAVE to return some obscure 
				// number as an inner reference to some internal stack, why is there
				// no option anywhere to return the line number in the ipf file, which would
				// have been actually USEFUL? Who decides those things at Igor?!
//				addFnText("\tline: "+ StringByKey("PROCLINE", fn)+"\r", -1, 0)
				if (! stringmatch(StringByKey("SUBTYPE", fn),"NONE"))
					addFnText("\tSubtype: "+ StringByKey("SUBTYPE", fn)+"\r", -1, 0)
				endif
				if (! stringmatch(StringByKey("SPECIAL", fn), "No"))
					addFnText("\tSpecial: "+ StringByKey("SPECIAL", fn)+"\r", -1, 0)
				endif
				break
			case "XFunc":
				addFnText("\tExternal module: "+ StringByKey("XOP", fn)+"\r", -1, 0)
				break
		endswitch
		s = ProcedureText(StringFromList(i, flist), -1)
		Variable idx
		for (idx = strsearch(s, "Function", 0, 2); idx != -1; idx = strsearch(s, "Function", idx, 2))
			idx += 8
			for(;stringmatch(s[idx,idx], " "); idx += 1)
			endfor
			if (strsearch(s,"/C",idx,2)==idx || strsearch(s,"/S",idx,2)==idx || strsearch(s,"/D",idx,2)==idx)
				idx += 2
			endif
			for(;stringmatch(s[idx,idx], " "); idx += 1)
			endfor
			if (strsearch(s, StringFromList(i, flist), idx, 2) == idx)
				idx = strsearch(s, "\r", idx, 2)
				break
			endif
		endfor
		if (idx != -1)
			addFnText("comment:\r", -1, 1)
			addFnText(s[0,idx], -1, 2)
		endif
		addFnText("\r\r", -1, 0)
	endfor
	
	ResumeUpdate
	
End















/////////////////////////////////////////
//
// Private Functions
//
/////////////////////////////////////////












Static Function buttonOpenHelp(ctrlname)
	String ctrlname
	DisplayHelpTopic "i_photo User's manual Table of Contents"
End


Static Function buttonAbout(ctrlname)
	String ctrlname
	DoWindow/K help_About
	NewPanel/K=1/N=help_About/W=(0,0,400,360)
	utils_autoPosWindow("help_About")
	SetDrawEnv fsize=18,fstyle=1; DrawText 20, 30, "Igor Pro"
	String txt
	sprintf txt, "Version %d.%d, Date %s", i_photo_version_major, i_photo_version_minor, i_photo_date
	SetDrawEnv fsize=14,fstyle=2; DrawText 20, 50, txt
	SetDrawEnv fstyle=2; DrawText 20, 110, "Inspired by K. Shen's ULTRA routines"
	SetDrawEnv fstyle=2; DrawText 20, 130, "Original code by F. Baumberger, 2004"
	SetDrawEnv fstyle=2; DrawText 20, 150, "Complete revision and partial rewrite by F. Schmitt, 2007"
	SetDrawEnv fstyle=2; DrawText 20, 200, "With contributions from:\r"
	DrawText 50, 220, "W.-S. Lee"
	DrawText 50, 240, "N. Ingle"
	DrawText 50, 260, "W. Meevasana"
	DrawLine 0, 300, 400, 300
	DrawText 20, 330, "This software is the mental property of the authors and the"
	DrawText 20, 350, "shen group. Please do not distribute outside the Shen group."
	
End





Static Function buttonBrowseFuncs(ctrlname)
	String ctrlname
	ControlInfo/W=help_panel cbShortOutput
	Variable short = V_Value
	ControlInfo/W=help_panel cbUserDef
	Variable kind = V_Value ? 6 : 7
	strswitch(ctrlname)
		case "bUserFunc":
			help_functionList(kind=kind,shortOutput=short)
			break
		case "biPhotoFunc":
			Variable i
			help_functionList(match=StringFromList(0, i_photo_modules)+"_*",kind=kind,shortOutput=short)
			for(i = 1; i < ItemsInList(i_photo_modules); i+=1)
				help_functionList(match=StringFromList(i, i_photo_modules)+"_*",kind=kind,add=1,shortOutput=short)
			endfor
			break
		case "biPhotoModuleFunc":
			ControlInfo/W=help_panel pmiPhotoModule
			help_functionList(match=S_Value+"_*",kind=kind,shortOutput=short)
			break
		case "bSearchFunc":
			SVAR s = root:internalUse:gs_search
			help_functionList(match="*"+s+"*",shortOutput=short,kind=kind)	
			break
	endswitch
End




Static Function/S interpretParamType(ptype)
	Variable ptype
	
	String typeStr = ""
	if (ptype & 0x1000)		// test for PASS BY REFERENCE bit
		typeStr += "(reference)"
	endif
	if (ptype & 0x4000)		// test for WAVE bit set
		typeStr += "WAVE"
		if (ptype == 0x4000)
			typeStr += "/T"
		elseif (ptype & 1)			// test for COMPLEX bit
			typeStr += "/C"
		endif
	elseif (ptype & 0x2000)	// test for STRING bit set
		typeStr += "String"
	elseif (ptype & 4)			// test for VARIABLE bit
		typeStr += "Variable"
		if (ptype & 1)			// test for COMPLEX bit
			typeStr += "/C"
		endif
	elseif (ptype & 0x400)		// test for FUNCREF bit
		typeStr += "FuncRef "
	endif
	if(strlen(typeStr) == 0)
		typeStr = "UNKNOWN"
	endif
	return typeStr
End




Static Function addFnText(text, fSize, fStyle)
	String text
	Variable fSize, fStyle
	Notebook FunctionListNotebook, fSize=fSize, fStyle=fStyle, text=text
End




Static Function functionListHook(infoStr)
	String infoStr

	String event= StringByKey("EVENT",infoStr)

	if (cmpstr(event,"mouseup")==0)
		GetSelection notebook, FunctionListNotebook, 2
		if (strlen(S_Selection) == 0) // is something selected?
			return 0
		endif
		if (strlen(FunctionInfo(S_Selection)) != 0) // Try to see if it is a function with info available
			DisplayProcedure(S_Selection)
			return 1
		endif
		if (strlen(FunctionList(S_Selection,";","")) != 0) // try to see if it exists at all ...
			DisplayHelpTopic(S_Selection) // ... and try Igor help as a last resort
			return 1
		endif
	endif
	return 0				// 0 if nothing done, else 1 or 2
End

