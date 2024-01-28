#pragma rtGlobals=1		// Use modern global access method.#pragma version = 0.01Function InitSVar(name,intsvar)	String name	String intsvar	SVAR /Z Stemp=$name	if (!SVAR_Exists(Stemp))		String /G $name=intsvar	endifEndFunction InitVar(name,intvar)	String name	Variable intvar		NVAR /Z temp=$name	if (!NVAR_Exists(temp))		Variable /G $name=intvar	endif	EndFunction return_selected(selwave,colflag)	Wave selwave	Variable colflag	variable rownum=dimsize(selwave,0)	variable colnum=dimsize(selwave,1)		duplicate /o selwave selwave_temp	Wave selwave_temp	selwave_temp=(selwave_temp>=2)?(selwave_temp-2):(selwave_temp)		Variable index	if (colflag)		make /o/n=(rownum) tempcol		do			tempcol=selwave_temp[p][index]			if (sum(tempcol)>0)				Killwaves /Z tempcol,selwave_temp				return index			endif		index+=1		while(index<colnum)		Killwaves /Z tempcol,selwave_temp		return -1	else		make /o/n=(colnum) tempcol		do			tempcol=selwave_temp[index][p]			if (sum(tempcol)>0)				Killwaves /Z tempcol,selwave_temp				return index			endif		index+=1		while(index<rownum)		Killwaves /Z tempcol,selwave_temp		return -1	endifEndFunction BringUP_thefirstpanel(panelnamelist)	string panelnamelist	Variable itemnum=itemsinlist(panelnamelist,";")	Variable index=0	String wname	wname=StringFromList(index, panelnamelist,";")	Dowindow /HIDE=0 /F $wnameEndFunction BringUP_Allthepanel(panelnamelist,SCcenterflag)	string panelnamelist	Variable SCcenterflag	Variable itemnum=itemsinlist(panelnamelist,";")	Variable index	String wname		Variable SC = ScreenSize(5)	Variable SR = ScreenSize(3) * SC	Variable ST = ScreenSize(2) * SC	Variable SL = ScreenSize(1) * SC    	Variable SB = ScreenSize(4) * SC		do		wname=StringFromList(index, panelnamelist,";")		if (strlen(wname)==0)			break		endif		Dowindow /HIDE=0 /F $wname		if (SCcenterflag==1)			 Attachtobottom("",wname,4)		elseif(SCcenterflag==2)			Attachtobottom("",wname,5)		endif		index+=1	while (index<itemnum)EndFunction Hidedown_Allthepanel(panelnamelist)	string panelnamelist	Variable itemnum=itemsinlist(panelnamelist,";")	Variable index	String wname	do		wname=StringFromList(index, panelnamelist,";")		Dowindow /HIDE=1 $wname		index+=1	while (index<itemnum)EndFunction Attachtobottom(Swname,Twname,flag)	String Swname,Twname	Variable flag	//Variable SC = ScreenSize(5)	Variable SR = Igorsize(3) 	Variable ST = Igorsize(2)	Variable SL = Igorsize(1)    Variable SB = Igorsize(4)		if (strlen(Swname)>0)		GetWindow /Z $Swname wsize 		Variable Sleft,sright,sbottom,stop		Sleft=V_left		Sright=V_right		Sbottom=V_bottom		Stop=V_top	endif		if (strlen(Twname)>0)		GetWindow /Z $Twname wsize 		Variable Tleft,Tright,Tbottom,Ttop		Tleft=V_left		Tright=V_right		Tbottom=V_bottom		Ttop=V_top	else		return 0	endif		Variable wwidth=Tright-Tleft	Variable wheight=Tbottom-Ttop	if (flag==1) //bottom center		Tleft=(Sleft+Sright)/2-wwidth/2		Tright=(Sleft+Sright)/2+wwidth/2		Ttop=Sbottom		Tbottom=Sbottom+wheight	endif		if (flag==2) //top center		Tleft=(Sleft+Sright)/2-wwidth/2		Tright=(Sleft+Sright)/2+wwidth/2		Ttop=Stop-wheight		Tbottom=Stop	endif	if (flag==3) //left top		Tleft=Sleft-wwidth		Tright=Sleft		Ttop=Stop		Tbottom=Stop+wheight	endif		if (flag==4) //Screen center		Tleft=(SL+SR)/2-wwidth/2		Tright=(SL+SR)/2+wwidth/2		Ttop=(ST+SB)/2-wheight/2		Tbottom=(ST+SB)/2+wheight/2	endif		if (flag==5) //Screep top right		Tleft=SR-wwidth		Tright=SR		Ttop=ST		Tbottom=ST+wheight	endif	Variable temp	if (Tleft<SL)		temp=SL-Tleft		Tleft+=temp		Tright+=temp	endif	if (Tright>SR)		temp=Tright-SR		Tleft-=temp		Tright-=temp	endif	if (Ttop<ST)		temp=ST-Ttop		Ttop+=temp		Tbottom+=temp	endif	if (Tbottom>SB)		temp=Tbottom-SB		Ttop-=temp		Tbottom-=temp	endif	Movewindow /W=$twname Tleft,Ttop,Tright,TbottomEndFunction /S DuplicateGraphDatafolder(wname,newwname,panelflag)	String wname	string newwname	Variable panelflag		String GraphDF,GraphDFcmp,newGraphDF	string wlist,trname	variable traceflag=1		if (panelflag)		GraphDF="root:internalUse:"+wname		//newGraphDF="root:internalUse:"+newwname	else		Wlist=tracenamelist(wname,";",1)		if (strlen(wList)==0)			Wlist=imagenamelist(wname,";")			traceflag=0		endif		Variable index		do			trname=stringfromlist(index,Wlist,";")			if (traceflag)				Wave data=TracenametoWaveref(wname,trname)			else				Wave data=Imagenametowaveref(wname,trname)			endif						if (index==0)				GraphDF=GetWavesDatafolder(data,1)			else				GraphDFcmp=GetWavesDatafolder(data,1)				if (stringmatch(GraphDFcmp,GraphDF)==0)					return ""				endif			endif		index+=1		while (index<itemsinlist(Wlist))		GraphDF=removeending(graphDF,":")		//newGraphDF=GraphDF[0,temp]+newwname	endif		Variable temp=strsearch(GraphDF,":",inf,1)	newGraphDF=GraphDF[0,temp]+newwname	if (datafolderexists(newGraphDF))		return ""	else		duplicateDatafolder $GraphDF $newGraphDF		return GraphDF	endifEndFunction ChangeGraphDatafolder(wname,newwname,panelflag)	String wname	string newwname	Variable panelflag		String GraphDF,GraphDFcmp,newGraphDF	string wlist,trname	variable traceflag=1		if (panelflag)		GraphDF="root:internalUse:"+wname		//newGraphDF="root:internalUse:"+newwname	else		Wlist=tracenamelist(wname,";",1)		if (strlen(wList)==0)			Wlist=imagenamelist(wname,";")			traceflag=0		endif		Variable index		do			trname=stringfromlist(index,Wlist,";")			if (traceflag)				Wave data=TracenametoWaveref(wname,trname)			else				Wave data=Imagenametowaveref(wname,trname)			endif						if (index==0)				GraphDF=GetWavesDatafolder(data,1)			else				GraphDFcmp=GetWavesDatafolder(data,1)				if (stringmatch(GraphDFcmp,GraphDF)==0)					return 0				endif			endif		index+=1		while (index<itemsinlist(Wlist))		GraphDF=removeending(graphDF,":")		Variable temp=strsearch(GraphDF,":",inf,1)		//newGraphDF=GraphDF[0,temp]+newwname	endif		renameDatafolder $GraphDF $newwname	return 1EndFunction MyGraphHook(s)	STRUCT WMWinHookStruct &s		Variable hookResult = 0	// 0 if we do not handle event, 1 if we handle it.	String wname=s.winName		switch(s.eventCode)		case 2:			Deleteallingraph(wname,0)		break		case 17:			doalert 2,"Hide the graph? Yes: Hide, No: Kill"			if (V_flag==1)				Dowindow /HIDE=1 $wname				print "Hide window "+wname				return 2			elseif (V_flag==2)				return 0			elseif (V_flag==3)				return 2			endif		break		case 11:			if (s.keycode==99)				String new_wname,based_wname				if (strsearch(wname,"EDC_",0)==0)					based_wname="EDC_"					new_wname=wname[4,inf]				elseif (strsearch(wname,"MDC_",0)==0)					based_wname="MDC_"					new_wname=wname[4,inf]				elseif (strsearch(wname,"IMG_",0)==0)					based_wname="IMG_"					new_wname=wname[4,inf]				elseif (strsearch(wname,"FSM_",0)==0)					based_wname="FSM_"					new_wname=wname[4,inf]					else					based_wname=""					new_wname=wname				endif								prompt new_wname,"Change Graphname as: "+based_wname				Doprompt "Change Graph Name:",new_wname				if (V_flag==0)					new_wname=based_wname+new_wname					if (whichlistitem(new_wname,WinList("",";",""),";",0)==-1)						if (ChangeGraphDatafolder(wname,new_wname,0))							dowindow /C /W=$wname $new_wname						else							doalert 0,"Waves not in the same DF!"						endif					endif				endif				hookResult=1			endif						if  (s.keycode==100)				if (strsearch(wname,"EDC_",0)==0)					based_wname="EDC_"					new_wname=wname[4,inf]				elseif (strsearch(wname,"MDC_",0)==0)					based_wname="MDC_"					new_wname=wname[4,inf]				elseif (strsearch(wname,"IMG_",0)==0)					based_wname="IMG_"					new_wname=wname[4,inf]				elseif (strsearch(wname,"FSM_",0)==0)					based_wname="FSM_"					new_wname=wname[4,inf]					else					based_wname=""					new_wname=wname				endif								prompt new_wname,"Change Graphname as: "+based_wname				Doprompt "Change Graph Name:",new_wname				if (V_flag==0)					new_wname=based_wname+new_wname					//print WinList("*",";","")					if (whichlistitem(new_wname,WinList("*",";",""),";",0)==-1)						String GraphDF=DuplicateGraphDatafolder(wname,new_wname,0)						if (strlen(graphdf)>0)														Variable temp=strsearch(GraphDF,":",inf,1)							String newGraphDF=GraphDF[0,temp]+new_wname														string winrec= WinRecreation(wname, 0)							winrec=ReplaceString(graphdf[4,inf],winrec,newGraphDF[4,inf])							ExecutewinRecreation_all(winrec,new_wname,0)							dowindow /C $new_wname						else							doalert 0,"Waves not in the same DF!"						endif					endif				endif				hookResult=1						endif						if (s.keycode==107)				doalert 1,"Kill all the waves in the graph?"				if (V_flag==1)					Deleteallingraph(wname,0)					Dowindow /K $wname				endif				hookResult=1			endif						if (s.keycode==104)				Dowindow /HIDE=1 $wname				print "Hide window "+wname				hookResult=1			endif					break		case 8:			String Cwnamelist=ChildWindowList(wname)			if (Findlistitem("Create_movie",Cwnamelist,";",0)!=-1) 				//DFREF DFR_movie=$(DF_GP+wname+":CreateMovie")				//NVAR gv_addtextflag=DFR_movie:gv_addtextflag				//SVAR gs_formatstr=DFR_movie:gs_formatstr								update_addtext(wname)			endif		break	endswitch	return hookResult	// If non-zero, we handled event and Igor will ignore it.EndFunction MyCrossCursorHook(s)STRUCT WMWinHookStruct &sVariable hookResult = 0	String wname=s.winName	switch(s.eventCode)		case 2:			String new_wname=winname(0,65)			DeleteBasednamegraph(new_wname,"HairY*",0)			//removefromgraph /Z /W=$new_wname HairCrossY			DFREF DF_HCP=$(DF_GP+new_wname)			NVAR AExists=DF_HCP:AExists			NVAR BExists=DF_HCP:BExists			if (AExists==0)				Cursor /W=$new_wname /K A			endif			if (BExists==0)				Cursor /W=$new_wname/K B				endif			String DF=DF_GP+new_wname			KillDatafolder /Z $DF							break	endswitch	return hookResultEndFunction MyMakeDiffHook(s)	STRUCT WMWinHookStruct &s		Variable hookResult = 0	String wname=s.winName	switch(s.eventCode)		case 0:			String new_wname=winname(1,65)							if (strsearch(new_wname,"panel",0)==-1)				//	ShowKBColorizePanel()				else					DoWindow/K KBColorizePanel				endif		break	endswitch	return hookResultEndFunction MypanelDataTableHook(s)	STRUCT WMWinHookStruct &s		Variable hookResult = 0	// 0 if we do not handle event, 1 if we handle it.    	String wname=s.winName	switch(s.eventCode)		case 2:			if (strsearch(wname,"mapper3D_panel",0)!=-1)				String basename=winname(0,65)				Variable temp=strsearch(basename,"panel_",inf,1)				basename="Plot_"+basename[temp+5,inf]				String winnamelist=winlist(basename+"*", ";","")				Variable index=0				do					String graphname=stringfromlist(index,winnamelist,";")					if (strlen(graphname)==0)						break					endif										Dowindow /K $graphname					index+=1				while (1)			endif			String DF_panel="root:internaluse:"+wname			Deleteallingraph(wname,0)			KillDatafolder /Z $DF_panel			break		case 6:			GetWindow /Z $wname wsizeDC						Variable windowwidth=V_right-V_left			Variable windowheight=V_bottom-V_top			//print windowwidth,windowheight			Variable SC=ScreenSize(5)			Listbox global_lb0, win=$wname,size={(windowwidth-20)*SC,(windowheight-190)*SC}			break	endswitch	return hookResult	// If non-zero, we handled event and Igor will ignore it.EndFunction MypanelDELHook(s)	STRUCT WMWinHookStruct &s		Variable hookResult = 0	// 0 if we do not handle event, 1 if we handle it.    	String wname=s.winName	switch(s.eventCode)		case 2:			if (strsearch(wname,"mapper3D_panel",0)!=-1)				String basename=winname(0,65)				Variable temp=strsearch(basename,"panel_",inf,1)				basename="Plot_"+basename[temp+5,inf]				String winnamelist=winlist(basename+"*", ";","")				Variable index=0				do					String graphname=stringfromlist(index,winnamelist,";")					if (strlen(graphname)==0)						break					endif					Dowindow /K $graphname					index+=1				while (1)											String winname3D=wname+"_gizmo"					if (strlen(winlist(winname3D,";","Win:4096"))>0)					Dowindow /K $winname3D					//String cmd="ModifyGizmo /N="+winname3D+" update=2"					//Execute /Q/Z cmd				endif			endif			String DF_panel="root:internaluse:"+wname			Deleteallingraph(wname,0)			KillDatafolder /Z $DF_panel		break	endswitch	return hookResult	// If non-zero, we handled event and Igor will ignore it.EndFunction MypanelHook(s)	STRUCT WMWinHookStruct &s		Variable hookResult = 0	// 0 if we do not handle event, 1 if we handle it.    	String wname=s.winName    	    	    		switch(s.eventCode)		case 2:			if (strsearch(wname,"mapper3D_panel",0)!=-1)				String basename=winname(0,65)				Variable temp=strsearch(basename,"panel_",inf,1)				basename="Plot_"+basename[temp+5,inf]				String winnamelist=winlist(basename+"*", ";","")				Variable index=0				do					String graphname=stringfromlist(index,winnamelist,";")					if (strlen(graphname)==0)						break					endif					Dowindow /K $graphname					index+=1				while (1)											String winname3D=wname+"_gizmo"					if (strlen(winlist(winname3D,";","Win:4096"))>0)					Dowindow /K $winname3D					//String cmd="ModifyGizmo /N="+winname3D+" update=2"					//Execute /Q/Z cmd				endif			endif					String DF_panel="root:internaluse:"+wname			Deleteallingraph(wname,0)			KillDatafolder /Z $DF_panel		break		case 17:			DF_panel="root:internalUse:"+wname			DFREF DFR_panel=$DF_panel			NVAR killflag=DFR_panel:gv_killflag			if (killflag)				return 0			else				Dowindow /HIDE=1 $wname				print "Hide window "+wname				return 2			endif		break				case 11:			if (s.keycode==99)				String new_wname,based_wname				 temp=strsearch(wname,"panel_",0,2)				based_wname=wname[0,temp+5]				new_wname=wname[temp+6,inf]										prompt new_wname,"Save panel as name: "+based_wname				Doprompt "Save panel as:",new_wname				if (V_flag==0)					new_wname=based_wname+new_wname					if (whichlistitem(new_wname,WinList("*",";",""),";",0)>=0)						doalert 0, "Error: ilegal graph name." 						hookResult=0						break					endif										if (ChangeGraphDatafolder(wname,new_wname,1))						dowindow /C /W=$wname $new_wname						dowindow /T $new_wname new_wname					else						doalert 0,"Waves not in the same DF!"						hookResult=0						break					endif				endif				hookResult=1			endif						if (s.keycode==104)				Dowindow /HIDE=1 $wname				print "Hide window "+wname				hookResult=1			endif		break	endswitch	return hookResult	// If non-zero, we handled event and Igor will ignore it.EndFunction traceexist(graphname,matchstring,dim)	String graphname,matchstring	Variable dim	String namelist	if (dim==1)		namelist=tracenamelist(graphname,";",1)	else		namelist=imagenamelist(graphname,";")	endif	if (findlistitem(matchstring,namelist,";",0)==-1)		return 0	else		return 1	endifEndFunction DeleteBasednamegraph(wname,basedname,flag)String wname,basednameVariable flagString trace_name,DF_name,image_nameString tracelist,imagelistdo 	tracelist=tracenamelist(wname,";",1)	tracelist=match_StringList(basedname,tracelist,";")	if (strlen(tracelist)==0)		break	endif	trace_name=Stringfromlist(0,tracelist,";")	Wave data=tracenametoWaveRef(wname,trace_name)	if (Waveexists(data))		DF_name=GetwavesDatafolder(data,1)		RemoveFromGraph /W=$wname /Z $trace_name		if (flag) 			Killwaves /Z data			KillDatafolder /Z $DF_name		endif	endifwhile (1)do	imagelist=imagenamelist(wname,";")	imagelist=match_StringList(basedname,imagelist,";")	if (strlen(imagelist)==0)		break	endif	image_name=Stringfromlist(0,imagelist,";")	Wave data=ImageNameToWaveRef(wname,image_name)	if (Waveexists(data))		DF_name=GetwavesDatafolder(data,1)		Removeimage /W=$wname /Z $image_name		if (flag) 			Killwaves /Z data			KillDatafolder /Z $DF_name		endif	endifwhile (1)EndFunction Deleteallingraph(wname,flag)	String wname	Variable flag		String trace_name,DF_name,image_name	String tracelist,imagelist	do 		tracelist=tracenamelist(wname,";",1)		if (strlen(tracelist)==0)			break		endif		trace_name=Stringfromlist(0,tracelist,";")		Wave data=tracenametoWaveRef(wname,trace_name)		if (Waveexists(data))			DF_name=GetwavesDatafolder(data,1)			RemoveFromGraph /W=$wname $trace_name			Killwaves /Z data			KillDatafolder /Z $DF_name		endif	while (1)		do 		tracelist=ContourNameList(wname,";")		if (strlen(tracelist)==0)			break		endif		trace_name=Stringfromlist(0,tracelist,";")		Wave data=ContourNameToWaveRef(wname,trace_name)		if (Waveexists(data))			DF_name=GetwavesDatafolder(data,1)			RemoveContour /W=$wname $trace_name			Killwaves /Z data			KillDatafolder /Z $DF_name		endif	while (1)	do		imagelist=imagenamelist(wname,";")		if (strlen(imagelist)==0)			break		endif		image_name=Stringfromlist(0,imagelist,";")		Wave data=ImageNameToWaveRef(wname,image_name)		if (Waveexists(data))			DF_name=GetwavesDatafolder(data,1)			Removeimage /W=$wname /Z $image_name			Killwaves /Z data			KillDatafolder /Z $DF_name		endif	while (1)EndFunction channels_per_slice(w,dim)	WAVE w; Variable dim		String notestr = note(w)	Variable firstYchannel = NumberByKey("CCDFirstYChannel",notestr,"=","\r")	Variable lastYchannel = NumberByKey("CCDLastYChannel",notestr,"=","\r")	Variable firstXchannel = NumberByKey("CCDFirstXChannel",notestr,"=","\r")	Variable lastXchannel = NumberByKey("CCDLastXChannel",notestr,"=","\r")	Variable NumberOfSlices = NumberByKey("NumberOfSlices", notestr,"=","\r")	Variable NumberOfEnergies = NumberByKey("NumberOfEnergies", notestr,"=","\r")		if(dim==0)		return (lastYchannel-firstYchannel+1)/NumberOfSlices	else		return (lastXchannel-firstXchannel+1)/NumberOfEnergies	endifEnd// return the center channels of the first or last slice of a Scienta carpetFunction scienta_ch(w,flag)	WAVE w;Variable flag	String notestr = note(w)		Variable firstYchannel = numberbykey_reverse("CCDFirstYChannel",notestr,"=","\r")	Variable lastYchannel = numberbykey_reverse("CCDLastYChannel",notestr,"=","\r")	Variable NumberOfSlices = numberbykey_reverse("NumberOfSlices", notestr,"=","\r")	Variable channel_slice = (lastYchannel-firstYchannel+1)/NumberOfSlices	Variable ch0 = firstYchannel + channel_slice/2// -0.5	// 04-22-04 corrected by 0.5	Variable ch1 = lastYchannel - channel_slice/2// + 0.5	if (numtype(firstYchannel)==2)		ch0=0		ch1=dimsize(w,0)-1	endif	if (flag == 1)		return ch1	else		return ch0	endifEnd