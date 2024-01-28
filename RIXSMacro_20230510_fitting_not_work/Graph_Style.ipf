#pragma rtGlobals=1		// Use modern global access method.


Function GP_DifferentColors() //ctrl+1
	PauseUpdate; Silent 1
	DFREF DF=GetDatafolderDFR()
	
	DFREF DFR_GP=$DF_GP
	
	SetDatafolder DFR_GP
	
	NVAR colorIndex=gv_colorIndex
	
	String Wname=winname(0,1)
	
	if (strsearch(wname,"_panel",0)>0)
		SetDatafolder DF
		return 0
	endif
	
	String Colorwavelist=wavelist("Color_*",";","")
	
	wave w=$Stringfromlist(colorIndex,ColorWavelist,";")
	Variable colornum=dimsize(w,0)

	String list=TraceNameList(Wname,";",1)
    	String TraceName
   	Variable items=ItemsInList(list,";")
	String FTraceName="",TTraceName=""
	Variable index=0,p2,m_num
	
	Variable Multiwaveflag=0
	
	String ti1,ti2,ti3
	
	TraceName=StringFromlist(0,list)
	ti1=Traceinfo(wname,Tracename,0)
	p2=Strsearch(ti1,"rgb(x)",0)
	ti1=ti1[p2,inf]
	p2=Strsearch(ti1,")",6)
	ti1=ti1[0,p2]
	
	TraceName=StringFromlist(1,list)
	ti2=Traceinfo(wname,Tracename,0)
	p2=Strsearch(ti2,"rgb(x)",0)
	ti2=ti2[p2,inf]
	p2=Strsearch(ti2,")",6)
	ti2=ti2[0,p2]
	
	TraceName=StringFromlist(items-1,list)
	ti3=Traceinfo(wname,Tracename,0)
	p2=Strsearch(ti3,"rgb(x)",0)
	ti3=ti3[p2,inf]
	p2=Strsearch(ti3,")",6)
	ti3=ti3[0,p2]
	
	if ((stringmatch(ti2,ti1)==0)||(stringmatch(ti3,ti1)==0)||(stringmatch(ti3,ti2)==0)) //change to all the same color
		Modifygraph /Z rgb=(0,0,0)
		SetDatafolder DF
		return 0
	endif
	
	Variable dimflag=-1
	
	Variable r,g,b
	
	TraceName=StringFromlist(0,list)
	p2=Strsearch(TraceName,"_e_",inf,1)
	if (p2==-1)
		p2=Strsearch(TraceName,"_m_",inf,1)
		if (p2==-1)
			Multiwaveflag=0
		else
			dimflag=0
		endif
	else
		dimflag=1
	endif
	
	if (dimflag!=-1)
		if (dimflag==1)
			p2=Strsearch(TraceName,"_e_",inf,1)
		else
			p2=Strsearch(TraceName,"_m_",inf,1)
		endif
		FTraceName=traceName[0,p2]
		index=1
		do
			TraceName=StringFromlist(index,list)
			if (strlen(TraceName)==0)
				break
			endif
			if (dimflag==1)
				p2=Strsearch(TraceName,"_e_",inf,1)
			else
				p2=Strsearch(TraceName,"_m_",inf,1)
			endif
			TTraceName=traceName[0,p2]
			if (stringmatch(TTraceName,FTraceName))
				index+=1
				continue
			else
				FTraceName=TTraceName
				Multiwaveflag+=1
			endif
			 
		index+=1
		while (index<items)
	 endif
	 
	 Variable waveindex=0
	
	 if (Multiwaveflag>0)
	  	TraceName=StringFromlist(0,list)
	  	if (dimflag==1)
			p2=Strsearch(TraceName,"_e_",inf,1)
		else
			p2=Strsearch(TraceName,"_m_",inf,1)
		endif
		FTraceName=traceName[0,p2]
		index=0
		m_num=0
	 	do
			TraceName=StringFromlist(index,list)
			if (dimflag==1)
				p2=Strsearch(TraceName,"_e_",inf,1)
			else
				p2=Strsearch(TraceName,"_m_",inf,1)
			endif
			TTraceName=traceName[0,p2]
			if (stringmatch(TTraceName,FTraceName))
			else
				m_num+=1
				if (m_num==colornum)
					m_num=0
				endif
			FTraceName=TTraceName
			endif
			if (colorIndex==1) //rainbow
				Variable colorpos=colornum-m_num/Multiwaveflag*colornum
			else
				colorpos=m_num
			endif
			r=w[colorpos][0]
			g=w[colorpos][1]
			b=w[colorpos][2]
			ModifyGraph rgb($TraceName) = (r,g,b)
			index+=1
		while (index<items)
		
	else
		variable m1
		index=0
		do
		    TraceName=StringFromlist(index,list)
		    if (strlen(TraceName)==0)
				break
		    endif
		    
		    if (colorIndex==1) //rainbow
				colorpos=colornum-index/items*colornum
			else
				colorpos=mod(index,colornum)
			endif
			r=w[colorpos][0]
			g=w[colorpos][1]
			b=w[colorpos][2]
		    	Modifygraph /Z rgb($TraceName) = (r,g,b)
		index+=1
		while (index<items)
	endif
	SetDatafolder DF
End


Function FSM_Style(gN,flag)
	String gN
	Variable flag
    	ModifyGraph /W=$gN width={Plan,1,bottom,left}
	ModifyGraph/Z /W=$gN mirror=2
	ModifyGraph/Z /W=$gN standoff=0
	ModifyGraph/Z /W=$gN minor=1
	//ModifyGraph/Z /W=$gN sep=8
	ModifyGraph/Z /W=$gN btLen=4,stLen=2
	Label /Z/W=$gN Left "k\By"
	Label /Z/W=$gN Bottom "k\Bx"
End


Function image_Style(gN,flag)
	String gN
	Variable flag
	ModifyGraph/Z /W=$gN mirror=2
	ModifyGraph/Z /W=$gN standoff=0
	ModifyGraph/Z /W=$gN minor=1
	//ModifyGraph/Z /W=$gN sep=8
	ModifyGraph/Z /W=$gN btLen=4,stLen=2
	Label /Z/W=$gN Left "Energy Loss (eV)"
	Label /Z/W=$gN Bottom "q"
End

Function DC_Style(graphname,edc_flag)
	String graphname
	Variable edc_flag
	if (stringmatch(graphname,"*panel*"))
	return 1
	endif
	ModifyGraph/Z /W=$graphname lSize = 0.5
	ModifyGraph/Z /W=$graphname rgb=(0,0,0)
		
	ModifyGraph/Z /W=$graphname mirror=2
	//ModifyGraph/Z /W=$graphname tick(left)=3,noLabel(left)=1,lblPosMode(left)=3,lblPos(left)=20
	Label /Z/W=$graphname Left "Intensity (arb. units)"
	ModifyGraph/Z /W=$graphname stLen(bottom)=2, btLen=5
	ModifyGraph/Z /W=$graphname minor=1
	
	if (edc_flag)
		Label /Z/W=$graphname bottom "Energy Loss (eV)"
	else
		Label /Z/W=$graphname bottom "q"
	endif

End

Function other_Style(graphname,flag)
	String graphname
	Variable flag
	
	ModifyGraph/Z /W=$graphname mirror=2
End



Function GP_StandardStyle() 
	PauseUpdate; Silent 1
	String wname=winname(0,1)
	if (strsearch(wname,"EDC",0)!=-1)
		DC_Style(wname,1)
	elseif (strsearch(wname,"MDC",0)!=-1)
		DC_Style(wname,0)
	elseif (strsearch(wname,"FSM",0)!=-1)
		FSM_Style(wname,0)
	elseif (strsearch(wname,"IMG",0)!=-1)
		image_Style(wname,0)
	else 
		other_Style(wname,0)
	endif
End

Function GP_QuickStyle() //ctrl+2
	String s
	String wname=winname(0,1)
	if (strsearch(wname,"panel",0)!=-1)
	return 0
	endif
	
	ModifyGraph/Z  rgb=(65535,0,0)
	s="quickStyle()"
	Execute /P /Q/Z s
	
End


Function GP_SavetoQuickStyle()
	String wname
	wname=winname(0,1)
	String s
	sprintf s,"Dowindow /R/S=quickStyle %s",wname
 	Execute /P /Q/Z s
 	doalert 0,"Save to QuickStyle. Ctrl+7 to apply QuickStyle."
End

Function /S ReadSingleWaveNote(tImage,notenum)
Wave timage
	Variable notenum
	String notestr=note(timage)
	String returnstr
	
	switch(notenum)
	case 2:
		returnstr=StringBykey("PhotonEnergy",notestr,"=","\r")
		if (strlen(returnstr)>5)
			returnstr=returnstr[0,4]
		endif
		returnstr+=" eV"
	break
	case 3:
		returnstr=StringBykey("SampleTemperature",notestr,"=","\r")
		if (strlen(returnstr)>5)
			returnstr=returnstr[0,4]
		endif
		returnstr+="K"
	break
	case 4:
		returnstr=StringBykey("WaveName",notestr,"=","\r")
	break
	case 5:
		Variable theta=NumberBykey("InitialThetaManipulator",notestr,"=","\r")
		Variable thetaoff=NumberBykey("OffsetThetaManipulator",notestr,"=","\r")
		Variable phi=NumberBykey("InitialPhiManipulator",notestr,"=","\r")
		Variable phioff=NumberBykey("OffsetPhiManipulator",notestr,"=","\r")
		Variable Azi=NumberBykey("InitialAzimuthManipulator",notestr,"=","\r")
		Variable azioff=NumberBykey("OffsetAzimuthManipulator",notestr,"=","\r")
		sprintf returnstr,"T_%.2gP_%.2gA_%.2g",(theta+thetaoff),(phi+phioff),(azi+azioff)
	break
	endswitch
	return returnstr
End

Function GP_LegendName() //ctrl+2
	DFREF df=GetDataFolderDFR()
	
	String Wname=winname(0,1)
	String list=TraceNameList(Wname,";",1)
    String TraceName
   	Variable items=ItemsInList(list,";")
	String FTraceName="",TTraceName="",s
	Variable index=0,p2
	Variable popname
	Variable Multiwaveflag=0
	prompt popname "Plot Vars",popup,"Trace Name;Photon Energy;Temperature;Wave Name;Angle;Number;"
	doprompt "Append Legend",popname
	
	if (V_Flag==1)
	return 0
	endif
		
	TraceName=StringFromlist(0,list)
	
	p2=Strsearch(TraceName,"_e_",inf,1)
	if (p2==-1)
		p2=Strsearch(TraceName,"_m_",inf,1)
	endif
	if (p2==-1)
		Multiwaveflag=0
	else
		FTraceName=traceName[0,p2]
		index=1
		do
			TraceName=StringFromlist(index,list)
			if (strlen(TraceName)==0)
				break
			endif
			TTraceName=traceName[0,p2]
			if (stringmatch(TTraceName,FTraceName))
				index+=1
				continue
			else
				FTraceName=TTraceName
				Multiwaveflag+=1
			endif
			 
		index+=1
		while (index<items)
	 endif
	
	Legend/J/C/N=Legend/F=0 ""
	
	s=""
	Variable Windex=1
	if (Multiwaveflag>0)
	  	TraceName=StringFromlist(0,list)
		FTraceName=traceName[0,p2]
		if (popname==1)
			s+="\\s("+TraceName+")"+traceName+"\r"
		elseif (popname==6)
			s+="\\s("+TraceName+")"+"#"+num2str(Windex)+"\r"
			Windex+=1
		else
			Wave timage=TracenametoWaveref(Wname,TraceName)
			s+="\\s("+TraceName+")"+ReadSingleWaveNote(tImage,popname)+"\r"
		endif
		
		index=0
		do
		TraceName=StringFromlist(index,list)
		TTraceName=traceName[0,p2]
		if (stringmatch(TTraceName,FTraceName))
		else
			if (popname==1)
			s+="\\s("+TraceName+")"+traceName+"\r"
			elseif (popname==6)
			s+="\\s("+TraceName+")"+"#"+num2str(Windex)+"\r"
			Windex+=1
			else
			Wave timage=TracenametoWaveref(Wname,TraceName)
			s+="\\s("+TraceName+")"+ReadSingleWaveNote(tImage,popname)+"\r"
			endif
			FTraceName=TTraceName
		endif
		index+=1
		while (index<items)
	
	else
		index=0
		do
		    TraceName=StringFromlist(index,list)
		    if (strlen(TraceName)==0)
				break
			endif
		    if (popname==1)
			s+="\\s("+TraceName+")"+traceName+"\r"
			elseif (popname==6)
			s+="\\s("+TraceName+")"+"#"+num2str(index)+"\r"
			else
			Wave timage=TracenametoWaveref(Wname,TraceName)
			s+="\\s("+TraceName+")"+ReadSingleWaveNote(tImage,popname)+"\r"
			endif
		index+=1
		while (index<items)
	endif
	
	s=removeending(s,"\r")
	
	Legend /C/N=Legend1/F=0/A=MC s
	
	SetDatafolder DF
	
End


Function GP_AddTags()
	DFREF df=GetDataFolderDFR()
	openAddTagwindow()
End

Function /DF Initial_Addtag_panel(graphname)
String graphname

	DFREF DFR_GP=$DF_GP
	SetDatafolder DFR_GP
	
	newDatafolder /o/s $graphname
	
	String /G gs_CurveString
	String /G gs_tagformatstr="%s"
	Variable /G gv_tagindex=1
	Variable /G gv_tagpos=1
	Variable /G gv_tagX=0
	Variable /G gv_tagY=-5
	Variable /G gv_tagcolorflag=1
	Variable /G gv_tagXval
	
	gs_CurveString ="                                 \r"
	gs_CurveString+="                 +  +        \r"
	gs_CurveString+="+++++++        +             \r"
	gs_CurveString+="        +    +          +       \r"
	gs_CurveString+="          ++             +        \r"
	gs_CurveString+="                                +++++++      \r"
	gs_CurveString+="                                       \r"
	
	DFREF DFR_panel=GetDatafolderDFR()
	
	return DFR_panel 
End

Function openAddTagwindow()
	DFREF DF=getdatafolderDFR()

	DFREF DFR_GP=$DF_GP
	
	SetDatafolder DFR_GP
	
	
	Variable r=57000, g=57000, b=57000
	Variable SC=Screensize(5)
	Variable width=320*SC,Height=300*SC
 	String graphname=winname(0,65)
 
  	if (stringmatch(graphname,"*panel*")==1)
 	SetDatafolder DF
 	Return 0
 	endif
 	
 	String Cwnamelist=ChildWindowList(graphname)
 	
 	if (Findlistitem("Add_Tag_Panel",Cwnamelist,";",0)!=-1)
 	KillWindow $graphname#Add_Tag_panel
 	SetDatafolder DF
 	return 0
 	else
 	NewPanel /K=1/Host=$graphname/EXT=0/N=Add_Tag_Panel/W=(0,0,width,height) as "Add Tag Panel"
 	endif
 	//DoWindow/C AddTag	
 //   DoWindow/C $(graphname+"Add_tag_panel")
	DFREF DF_Addtag=Initial_Addtag_panel(graphname)
	SetDatafolder DF_Addtag
	
	SVAR str_curve=gs_CurveString
	SVAR Tag_formatstr=gs_tagformatstr
	NVAR tagindex=gv_tagindex
	NVAR tagX=gv_tagX
	NVAR tagY=gv_tagY
	NVAR tag_pos=gv_tagpos
	NVAR tagcolorflag=gv_tagcolorflag
		  
		//  str_curve="\r\r\r\r\r\r\r"
	Groupbox Addtag_gp0,pos={10*SC,10*SC},size={300*SC,130*SC},title="Tag Position",frame=0
	titlebox Addtag_tb0, frame=0,pos={70*SC,30*SC},size={400*SC,300*SC},Variable=str_curve
	Checkbox Addtag_ck0,pos={40*SC,35*SC},size={50*SC,18*SC},title="Tag1",Value=tag_pos==1,proc=Proc_ck_AddtagPos  
	Checkbox Addtag_ck1,pos={40*SC,70*SC},size={50*SC,18*SC},title="Tag2",Value=tag_pos==2,proc=Proc_ck_AddtagPos	
	Checkbox Addtag_ck2,pos={240*SC,85*SC},size={50*SC,18*SC},title="Tag3",Value=tag_pos==3,proc=Proc_ck_AddtagPos	  
	Checkbox Addtag_ck3,pos={240*SC,115*SC},size={50*SC,18*SC},title="Tag4"	,Value=tag_pos==4,proc=Proc_ck_AddtagPos
	Checkbox Addtag_ck5,pos={140*SC,35*SC},size={50*SC,18*SC},title="Tag5",Value=tag_pos==5,proc=Proc_ck_AddtagPos	  
	Checkbox Addtag_ck6,pos={140*SC,115*SC},size={50*SC,18*SC},title="Tag6"	,Value=tag_pos==6,proc=Proc_ck_AddtagPos
	Checkbox Addtag_ck7,pos={210*SC,35*SC},size={50*SC,18*SC},title="Tag7:"	,Value=tag_pos==6,proc=Proc_ck_AddtagPos
	SetVariable Addtag_sv3,pos={260*SC,35*SC},size={40*SC,18*SC},title=" ",limits={-inf,inf,0},variable=gv_tagXval,proc=Proc_sv_AddtagPos
	
	Groupbox Addtag_gp1,pos={10*SC,150*SC},size={300*SC,140*SC},title="Tag Value",frame=0
	 
	Popupmenu Addtag_pp0,pos={20*SC,180*SC},size={150*SC,18*SC},title="Tag:",mode=tagindex,value="Tracename;Photon_Energy;Temperature;Index",proc=proc_pp_ChangeTag
	SetVariable Addtag_sv0,pos={160*SC,182*SC},size={130*SC,18*SC},title="Format Str:",variable=Tag_formatstr
	titlebox Addtag_tb1,pos={20*SC,210*SC},size={60*SC,18*SC},title="Tag preview",frame=0
	Button Addtag_bt0,pos={20*SC,260*SC},size={80*SC,20*SC},title="Add Tag",Proc=proc_bt_AddTag
	Button addTag_bt1,pos={110*SC,260*SC},size={80*SC,20*SC},title="Remove Tag",Proc=proc_bt_AddTag
	Checkbox AddTag_ck4,pos={200*SC,260*SC},size={80*SC,20*SC},title="Color Tag",value=tagcolorflag,proc=proc_ck_Tagcolor
	SetVariable Addtag_sv1,pos={160*SC,210*SC},size={90*SC,18*SC},title="X:",variable=TagX,proc=Proc_sv_AddtagPos
	SetVariable Addtag_sv2,pos={160*SC,230*SC},size={90*SC,18*SC},title="Y:",variable=TagY,proc=Proc_sv_AddtagPos
	SetDatafolder DF
End

Function proc_ck_Tagcolor(ctrlname,value)
String ctrlname
Variable value
	DFREF DF=getdatafolderDFR()
	String graphname=winname(0,65)
	DFREF DFR_GP=$(DF_GP+graphname)
	SetActivesubwindow $winname(0,1)#Add_Tag_Panel

	SetDatafolder DFR_GP
	NVAR tagcolorflag=gv_tagcolorflag
	tagcolorflag=value

	proc_bt_AddTag("Addtag_bt0")

	SetDatafolder DF
End

Function proc_bt_AddTag(ctrlname)
	String ctrlname
	DFREF DF=getdatafolderDFR()
	String graphname=winname(0,65)
	DFREF DFR_GP=$(DF_GP+graphname)
	SetActivesubwindow $winname(0,1)#Add_Tag_Panel
	SetDatafolder DFR_GP
	
	SVAR Tag_formatstr=gs_tagformatstr
	NVAR tagindex=gv_tagindex
	NVAR tagpos=gv_tagpos
	NVAR tagX=gv_tagX
	NVAR tagY=gv_tagY
	NVAR tagcolorflag=gv_tagcolorflag
	
	String tagstr,previewstr
		
	Variable index
	
	String Wname=winname(0,1)
	String list=TraceNameList(Wname,";",1)
   	 String TraceName
   	Variable items=ItemsInList(list,";")
   	
   	do
   		TraceName=StringFromlist(index,list)
		if (strlen(TraceName)==0)
			break
		endif
		Wave trace=TraceNameToWaveRef(graphname, tracename)
		
		if (stringmatch(Ctrlname,"Addtag_bt1"))
			Tag /W=$graphname /K/N=$tracename
			index+=1
			continue
		endif
		
		Variable r,g,b
		if (tagcolorflag)
			String tracecolor=traceinfo(graphname,tracename,0)
			Variable temp=strsearch(tracecolor,"rgb",0)
			Variable temp1=strsearch(tracecolor,";",temp)
			tracecolor=tracecolor[temp,temp1-1]
			sscanf tracecolor,"rgb(x)=(%g,%g,%g)",r,g,b
		else
			r=0
			g=0
			b=0
		endif
		tagstr=readTag_from_graph(graphname,index,tagindex)
   		sprintf previewstr, Tag_formatstr, tagstr
   		switch(tagpos)
   			case 1:
   				Tag /W=$graphname /C/N=$tracename/G=(r,g,b)/L=0/F=0/X=(tagX)/Y=(tagY) $tracename,leftx(trace),previewstr
   				break
   			case 2:
   				Tag /W=$graphname /C/N=$tracename/G=(r,g,b)/L=0/F=0/X=(tagX)/Y=(tagY) $tracename,leftx(trace),previewstr
   				break
   			case 3:
   				Tag /W=$graphname /C/N=$tracename/G=(r,g,b)/L=0/F=0/X=(tagX)/Y=(tagY) $tracename,rightx(trace),previewstr
   				break
   			case 4:
   				Tag /W=$graphname /C/N=$tracename/G=(r,g,b)/L=0/F=0/X=(tagX)/Y=(tagY) $tracename,rightx(trace),previewstr
   				break
   			case 5:
   				Tag /W=$graphname /C/N=$tracename/G=(r,g,b)/L=0/F=0/X=(tagX)/Y=(tagY) $tracename,0,previewstr
   				break
   			case 6:
   				Tag /W=$graphname /C/N=$tracename/G=(r,g,b)/L=0/F=0/X=(tagX)/Y=(tagY) $tracename,0,previewstr
   				break	
   			case 7:
   				NVAR tagXval=gv_tagxval
   				Tag /W=$graphname /C/N=$tracename/G=(r,g,b)/L=0/F=0/X=(tagX)/Y=(tagY) $tracename,tagxval,previewstr
   				break		
   		endswitch
   		
   		
   	index+=1
   	while (index<items)
   	
SetDatafolder DF
End

Function proc_pp_ChangeTag (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	
	DFREF DF=getdatafolderDFR()
	String graphname=winname(0,65)
	DFREF DFR_GP=$(DF_GP+graphname)
	SetActivesubwindow $winname(0,1)#Add_Tag_Panel
	SetDatafolder DFR_GP
	
	SVAR Tag_formatstr=gs_tagformatstr
	NVAR tagindex=gv_tagindex
	
	
	String tagstr,previewstr
		
	tagindex=popnum
	switch(tagindex)
	case 0:
		Tag_formatstr="%s"
	break
	case 1: //tracename
		Tag_formatstr="%s"
	break
	case 2:
		Tag_formatstr="%s eV"
	break
	case 3:
		Tag_formatstr="%s K"
	break
	case 4:
		Tag_formatstr="#%s"
	break
	endswitch
	
	tagstr=readTag_from_graph(graphname,0,tagindex)
	sprintf previewstr, Tag_formatstr, tagstr
	
	titlebox  Addtag_tb1,title=previewstr,win=$graphname#Add_tag_panel
	
	SetDatafolder DF
End

Function /S readTag_from_graph(graphname,traceindex,tagindex)
String graphname
Variable traceindex,tagindex
	SetActivesubwindow $winname(0,1)#Add_Tag_Panel
	Wave trace=WaveRefIndexed(graphname,traceindex,1) 
	
	if	(waveexists(trace)==0)
	return "0"
	endif
	
	String notestr,returnstr=""
	notestr=note(trace)
	
	switch (tagindex)
	case 1:
		returnstr=nameofwave(trace)
	break
	case 2:
		returnstr=Stringbykey("PhotonEnergy",notestr,"=","\r")
	break
	case 3:
		returnstr=Stringbykey("SampleTemperature",notestr,"=","\r")
		//returnstr=returnstr[0,(strlen(returnstr)-2)]
		if (strlen(returnstr)>5)
			returnstr=returnstr[0,4]
		endif
	break
	case 4:
		returnstr=num2str(traceindex+1)
	break	
	endswitch
	return returnstr
end

Function Proc_sv_AddtagPos (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	proc_bt_AddTag("Addtag_bt0")
End

Function Proc_ck_AddtagPos(ctrlname,Value)
	String ctrlname
	Variable value
	DFREF DF=GetDatafolderDFR()
	String graphname=winname(0,65)
	DFREF DFR_GP=$(DF_GP+graphname)
	SetActivesubwindow $winname(0,1)#Add_Tag_Panel
	SetDatafolder DFR_GP
	
	NVAR gv_tagpos
	NVAR tagX=gv_tagX
	NVAR tagY=gv_tagY
	
	Variable ckvalue
	strswitch(ctrlname)
	case "Addtag_ck0":
		ckvalue=1
		tagX=0
		tagY=5
	break
	case "Addtag_ck1":
		ckvalue=2
		tagX=0
		tagY=-5
	break
	case "Addtag_ck2":
		ckvalue=3
		tagX=-5
		tagY=5
	break
	case "Addtag_ck3":
		ckvalue=4
		tagX=-5
		tagY=-5
	break
	case "Addtag_ck5":
		ckvalue=5
		tagX=0
		tagY=5
	break
	case "Addtag_ck6":
		ckvalue=6
		tagX=0
		tagY=-5
	break
	case "Addtag_ck7":
		ckvalue=7
		tagX=0
		tagY=0
	break
	endswitch
	
	Checkbox Addtag_ck0,win=$graphname#Add_Tag_Panel,value=ckvalue==1
	Checkbox Addtag_ck1,win=$graphname#Add_Tag_Panel,value=ckvalue==2
	Checkbox Addtag_ck2,win=$graphname#Add_Tag_Panel,value=ckvalue==3
	Checkbox Addtag_ck3,win=$graphname#Add_Tag_Panel,value=ckvalue==4
	Checkbox Addtag_ck5,win=$graphname#Add_Tag_Panel,value=ckvalue==5
	Checkbox Addtag_ck6,win=$graphname#Add_Tag_Panel,value=ckvalue==6
	Checkbox Addtag_ck7,win=$graphname#Add_Tag_Panel,value=ckvalue==7
	
	gv_tagpos=ckvalue
	
	proc_bt_AddTag("Addtag_bt0")
	SetDatafolder DF
End





Function GP_OffsetTraces() //ctrl+4
DFREF df=GetDataFolderDFR()
	 Open_Offset_Panel()
End


Function /DF init_Offset_panel()
	DFREF DF=GetDatafolderDFR()
	DFREF DFR_GP=$DF_GP
	SetDatafolder DFR_GP
	//newDatafolder /o/s Offset
	String wn=winname(0,1)
	newDatafolder /o/s $wn
	Variable /G gv_x_offset
	Variable /G gv_y_offset
	Variable /G gv_offindex
	Variable /G gv_deltaflag
	Return GetDatafolderDFR()
End

Function Open_Offset_Panel()
   DFREF Df= GetDatafolderDFR()
 
  // SetDataFolder root:internaluse:disp

   Variable SC=ScreenSize(5)
   Variable Width=270*SC
   Variable Height=150*SC
   Variable r=57000, g=57000, b=57000
   String wn=winname(0,65)
   
   if (stringmatch(wn,"*panel*")==1)
 	SetDatafolder DF
 	Return 0
 	endif
	
	String Cwnamelist=ChildWindowList(wn)
 	
 	if (Findlistitem("Offset_panel",Cwnamelist,";",0)!=-1)
 	KillWindow $wn#Offset_panel
 	SetDatafolder DF
 	return 0
 	else
	NewPanel /K=1 /Host=$wn/EXT=0/N=Offset_panel/W=(0,0,width,height) as "offset traces Panel"
   //DoWindow/C $(wn+"offset_traces_Panel")
   	endif
   	
   	DFREF DFR_panel=init_Offset_panel()
    SetDatafolder DFR_panel
    String DF_Panel=GetDatafolder(0)
    NVAR gv_offindex
    NVAR gv_deltaflag
     
    Groupbox DCs_gb2, frame=0,pos={10*SC,17*SC}, size={255*SC,125*SC}, title="modify graph:"
	Titlebox DCs_tb0, pos={20*SC,45*SC}, title="x:", frame=0
	Titlebox DCs_tb1, pos={20*SC,72*SC}, title="y:", frame=0
	Slider DCs_sl0,pos={32*SC,50*SC},size={100*SC,18*SC},limits={-1,1,0.005},variable=gv_x_offset,side= 0,vert= 0, side=2,labelBack=(r,g,b), thumbcolor=(2,2,2), proc=slider_offset_panel
	Slider DCs_sl1,pos={32*SC,77*SC},size={100*SC,18*SC},limits={-5,5,0.002},variable=gv_y_offset,side= 0,vert= 0, side=2,labelBack=(r,g,b), thumbcolor=(2,2,2), proc=slider_offset_panel
	SetVariable DCs_sv3, pos={140*SC,45*SC}, size={33*SC,15*SC}, value=gv_x_offset,limits={-inf,inf,0}, title=" ",labelBack=(r,g,b), proc=sv_offset_panel
	SetVariable DCs_sv4, pos={140*SC,72*SC}, size={33*SC,15*SC}, value=gv_y_offset,limits={-inf,inf,0}, title=" ",labelBack=(r,g,b), proc=sv_offset_panel
	checkbox DCs_offck0, pos={180*SC,40*SC}, size={60*SC,16*SC}, title="None",proc=Proc_checkbox_offsetsel,value=gv_offindex==0
	checkbox DCs_offck1, pos={180*SC,60*SC}, size={60*SC,16*SC}, title="Wave Index",proc=Proc_checkbox_offsetsel,value=gv_offindex==1
	checkbox DCs_offck2, pos={180*SC,80*SC}, size={60*SC,16*SC}, title="DCs Num",proc=Proc_checkbox_offsetsel,value=gv_offindex==2
	checkbox DCs_offck3, pos={180*SC,100*SC}, size={60*SC,16*SC}, title="Mark disp",proc=Proc_checkbox_offsetsel,value=gv_offindex==3
	checkbox DCs_offck4, pos={180*SC,120*SC}, size={60*SC,16*SC}, title="Name Index",proc=Proc_checkbox_offsetsel,value=gv_offindex==4
	
	checkbox DCs_offck5, pos={30*SC,100*SC}, size={60*SC,16*SC}, title="Equal Shift",proc=Proc_checkbox_deltasel,value=gv_deltaflag==0
	checkbox DCs_offck6, pos={30*SC,120*SC}, size={60*SC,16*SC}, title="Ajust AVG",proc=Proc_checkbox_deltasel,value=gv_deltaflag==1
	checkbox DCs_offck7, pos={105*SC,120*SC}, size={60*SC,16*SC}, title="Ajust Max",proc=Proc_checkbox_deltasel,value=gv_deltaflag==2
	//PopupMenu DCs_p0,pos={80,108},bodyWidth=56,size={113,18}, title="",value="*COLORPOP*", proc=trace_color
	//PopupMenu DCs_p1,pos={-40,85},bodyWidth=56,size={113,18},title="",value="*COLORTABLEPOPNONAMES*", mode=2
	//Button DCs_b3, pos={15,108}, size={100,18}, title="different Color", proc=rainbow_traces
	//Checkbox DCs_clck0, pos={85,87}, size={60,18}, title="reverse", value=0
	
   SetDatafolder df
End 

Function sv_offset_panel(ctrlName,varNum,varStr,varName)
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	DFREF Df= GetDatafolderDFR()
	
	String wn=winname(0,1)
	SetActivesubwindow $winname(0,1)#Offset_panel
	SetDatafolder $(DF_GP+wn)
	
	NVAR x_offset=gv_x_offset
	NVAR y_offset=gv_y_offset
	
	ControlInfo DCs_sv3
	x_offset = v_value
	ControlInfo DCs_sv4
	y_offset = v_value
	
	Slider DCs_sl1, value=y_offset
	Slider DCs_sl0, value=x_offset
	slider_offset_panel("dum", NaN, 1)
	
	SetDatafolder DF
End


Function slider_offset_panel(name, value, event)
	String name			// name of this slider control
	Variable value		// value of slider
	Variable event		// bit field: bit 0: value set; 1: mouse down, 2: mouse up, 3: mouse moved
	
	DFREF Df= GetDatafolderDFR()
	SetActivesubwindow $winname(0,1)#Offset_panel
	String wn=winname(0,1)
	
	SetDatafolder $(DF_GP+wn)
	
	NVAR x_offset = gv_x_offset
	NVAR y_offset = gv_y_offset
	
	ControlUpdate DCs_sv3
	ControlUpdate DCs_sv4
	
	String gN = WinName(0,1)
	
	String List = TraceNameList(gN, ";",1)
	String TraceName,WaveN0,WaveN1
	Variable lookup
	Variable items = ItemsInList(List,";")
	Variable default_y_offset=0, default_x_offset=0
	Variable from, to, comp, from0, num_off,num0
	String str0, str1
	
	NVAR gv_deltaflag
	
	
	
	Variable index = 0
	do
		TraceName = StringFromList(index,List)
		WAVE temp = TraceNameToWaveRef(gN, TraceName)
		Duplicate /o/Free temp temp_abs
		temp_abs=abs(temp)
		WaveStats/Q temp_abs
		if (numtype(v_avg)==0)
			default_y_offset=(v_avg>default_y_offset)?(v_avg):(default_y_offset)
		endif
		index += 1
	while (index < items)	
		
	default_y_offset = default_y_offset
	default_x_offset = numpnts(temp)*deltax(temp)/10

		// offset the traces
	Variable delta_y = y_offset * default_Y_offset
	Variable delta_x = x_offset * default_x_offset
	
    
	controlinfo DCs_offck0
	Variable c_none=v_value
	controlinfo DCs_offck1
	Variable c_wn=v_value
	controlinfo DCs_offck2
	Variable c_dc=v_value
	controlinfo DCs_offck3
	Variable c_markdisp=v_value
	controlinfo DCs_offck4
	Variable c_nameindex=v_value
	
	
	Variable offset_x_value=0
	Variable offset_y_value=0
	default_y_offset=0
	
	Variable offindex=0
	
	Variable edc_flag=0
	
	if (c_nameindex) //nameindex
		TraceName = StringFromList(0,List)
		from = Strsearch(Tracename, "_", inf,1)
		if(from==-1)
			from = inf
		endif
		
		WaveN0=TraceName[0,(from-1)]
		
		if (gv_deltaflag>0)
			WAVE temp = TraceNameToWaveRef(gN, TraceName)
			Duplicate /o/Free temp Wave_abs
			Wave_abs=abs(Wave_abs)
			WaveStats/Q Wave_abs
			if (gv_deltaflag==1)
				if (numtype(v_avg)==0)
					default_y_offset=(v_avg>default_y_offset)?(v_avg):(default_y_offset)
				endif
			else
				if (numtype(v_max)==0)
					default_y_offset=(v_max>default_y_offset)?(v_max):(default_y_offset)
				endif
			endif
		endif
			
		index = 0
		offindex=0
		do	
			TraceName = StringFromList(index,List)
			from = Strsearch(Tracename, "_", inf,1)
			if (from==-1)
				from = inf
			endif
			
			WaveN1=TraceName[0,(from-1)]
			
			if (gv_deltaflag>0)
				WAVE temp = TraceNameToWaveRef(gN, TraceName)
				Duplicate /o/Free temp Wave_abs
				Wave_abs=abs(Wave_abs)
				WaveStats/Q Wave_abs
				if (gv_deltaflag==1)
					if (numtype(v_avg)==0)
						default_y_offset=(v_avg>default_y_offset)?(v_avg):(default_y_offset)
					endif
				else
					if (numtype(v_max)==0)
						default_y_offset=(v_max>default_y_offset)?(v_max):(default_y_offset)
					endif
				endif
			endif
			
			if (stringmatch(WaveN0,WaveN1)!=1)
				offindex+=1
				if (gv_deltaflag==0)
					offset_x_value+=delta_x
					offset_y_value+=delta_y
				else
					offset_x_value+=delta_x
					offset_y_value+=y_offset *default_y_offset
					default_y_offset=0
				endif
				WaveN0=WaveN1
			endif
			
			
			ModifyGraph/w=$gn offset($TraceName)={offset_x_value,offset_y_value}
		
			index += 1
		while (index < items)
		SetDatafolder DF
		return 0
	endif
	
	if (c_markdisp)  //markindex
		TraceName = StringFromList(0,List)
		from = Strsearch(Tracename, "_e_", inf,1)
		if (from == -1)
			from = Strsearch(Tracename, "_m_", inf,1)
			if (from == -1)
				from = inf
			endif
		endif
		
		Make /o/Free /n=(items) Offindex_wave
		
		//WaveN0=TraceName[0,(from-1)]
		index = 0
		offindex=0
		Variable scanindex=0
		String posname
		do	
			TraceName = StringFromList(index,List)
			
			if (strsearch(tracename,"_Pos_",0)!=-1)
				break
			endif
		
			from = Strsearch(Tracename, "_e_", inf,1)
			if (from == -1)
				from = Strsearch(Tracename, "_m_", inf,1)
				if (from == -1)
					from = inf
				endif
			endif
			WaveN0=TraceName[0,(from+6)]
			Offindex_wave[index]=offindex
			scanindex=index
				do 
					posname=StringFromList(scanindex,List)
					if (strsearch(posname,"_Pos_",0)!=-1)
						from = Strsearch(posname, "_Pos", inf,1)
						WaveN1=posname[0,(from-1)]
						WaveN0=TraceName[0,(from-1)]
						if  (stringmatch(WaveN0,WaveN1)==1)
							Offindex_wave[scanindex]=offindex
						endif
					endif
					scanindex+=1
				while (scanindex<items)
			offindex+=1
			index += 1
		while (index < items)
		
		index=0
		do
			TraceName = StringFromList(index,List)
			offindex=Offindex_wave[index]
			ModifyGraph/w=$gn offset($TraceName)={delta_x*(offindex),delta_y*(offindex)}
			index+=1
		while (index<items)
		
		//print offindex_wave
		
		
		SetDatafolder DF
		return 0	
	endif
	

	if (c_none) //none
		index = 0
		do	
			TraceName = StringFromList(index,List)
			
			
			ModifyGraph/w=$gn offset($TraceName)={offset_x_value,offset_y_value}
			
			if (gv_deltaflag>0)
				WAVE temp = TraceNameToWaveRef(gN, TraceName)
				Duplicate /o/Free temp Wave_abs
				Wave_abs=abs(Wave_abs)
				WaveStats/Q Wave_abs
				if (gv_deltaflag==1)
					if (numtype(v_avg)==0)
						default_y_offset=(v_avg>default_y_offset)?(v_avg):(default_y_offset)
					endif
				else
					if (numtype(v_max)==0)
						default_y_offset=(v_max>default_y_offset)?(v_max):(default_y_offset)
					endif
				endif
			endif
			
			if (gv_deltaflag==0)
				offset_x_value+=delta_x
				offset_y_value+=delta_y
			else
				offset_x_value+=delta_x
				offset_y_value+=default_y_offset*y_offset
				default_y_offset=0
			endif
			
			index += 1
		while (index < items)
		SetDatafolder DF
		return 0
	endif
	
	if (c_wn) //wavename
		TraceName = StringFromList(0,List)
		from = Strsearch(Tracename, "_e_", inf,1)
		if (from == -1)
			from = Strsearch(Tracename, "_m_", inf,1)
			if (from == -1)
				from = inf
			endif
		endif
		WaveN0=TraceName[0,(from-1)]
		
		if (gv_deltaflag>0)
			WAVE temp = TraceNameToWaveRef(gN, TraceName)
			Duplicate /o/Free temp Wave_abs
			Wave_abs=abs(Wave_abs)
			WaveStats/Q Wave_abs
			if (gv_deltaflag==1)
				if (numtype(v_avg)==0)
					default_y_offset=(v_avg>default_y_offset)?(v_avg):(default_y_offset)
				endif
			else
				if (numtype(v_max)==0)
					default_y_offset=(v_max>default_y_offset)?(v_max):(default_y_offset)
				endif
			endif
		endif
		
		index = 0
		offindex=0
		do	
			TraceName = StringFromList(index,List)
		
			from = Strsearch(Tracename, "_e_", inf,1)
			if (from == -1)
				from = Strsearch(Tracename, "_m_", inf,1)
				if (from == -1)
					from = inf
				endif
			endif
			WaveN1=TraceName[0,(from-1)]
			if (stringmatch(WaveN0,WaveN1)==0)
				offindex=0
				WaveN0=WaveN1
				
				if (gv_deltaflag>0)
					WAVE temp = TraceNameToWaveRef(gN, TraceName)
					Duplicate /o/Free temp Wave_abs
					Wave_abs=abs(Wave_abs)
					WaveStats/Q Wave_abs
					if (gv_deltaflag==1)
						if (numtype(v_avg)==0)
							default_y_offset=(v_avg>default_y_offset)?(v_avg):(default_y_offset)
						endif
					else
						if (numtype(v_max)==0)
							default_y_offset=(v_max>default_y_offset)?(v_max):(default_y_offset)
						endif
					endif
				endif
			else
				if (gv_deltaflag==0)
					offset_x_value+=delta_x
					offset_y_value+=delta_y
				else
					offset_x_value+=delta_x
					offset_y_value+=default_y_offset*y_offset
					default_y_offset=0
				endif
			endif
			ModifyGraph/w=$gn offset($TraceName)={offset_x_value,offset_y_value}
		
			offindex+=1
			index += 1
		while (index < items)
		SetDatafolder DF
		return 0
	endif
	
	if (c_dc) //DCs
	
		TraceName = StringFromList(0,List)
		from = Strsearch(Tracename, "_e_", inf,1)
		if (from == -1)
			from = Strsearch(Tracename, "_m_", inf,1)
			if (from == -1)
				doalert 0,"Error DCs in the Graph!"
				return 0
			else
			lookup=0
			endif
		else
			lookup=1
		endif
		from0=from
		from = Strsearch(Tracename, "_", (from0+3),0)
		num0=str2num(Tracename[(from0+4),(from-1)])
	
		index = 1
		Variable nummax=0,nummin=10000,numdelta=10000
		do
			TraceName = StringFromList(index,List)
			if (lookup)
				from= Strsearch(Tracename, "_e_", inf,1)
			else
				from = Strsearch(Tracename, "_m_", inf,1)
			endif
			from0=from
			from = Strsearch(Tracename, "_", (from0+3),0)
			num_off=str2num(Tracename[(from0+4),(from-1)])
	 
			if (numtype(num_off)==0)
				nummax=(num_off>nummax)?(num_off):(nummax)
				nummin=(num_off<nummin)?(num_off):(nummin)
				numdelta=(abs(num_off-num0)<numdelta)?(abs(num_off-num0)):(numdelta)
				num0=num_off
			else
				doalert 0,"Error DCs in the Graph!"
				return 0
			endif
		
			index += 1
		while (index < items)	
	
		index = 0
		offindex=0
		do	
			TraceName = StringFromList(index,List)
		
			if (lookup)
				from= Strsearch(Tracename, "_e_", inf,1)
			else
				from = Strsearch(Tracename, "_m_", inf,1)
			endif
			from0=from
			from = Strsearch(Tracename, "_", (from0+3),0)
			num_off=str2num(Tracename[(from0+4),(from-1)])
		
			offindex=(num_off-nummin)/numdelta
	
			ModifyGraph/w=$gn offset($TraceName)={delta_x*(offindex),delta_y*(offindex)}
			index += 1
		while (index < items)
		SetDatafolder DF
		return 0
	endif
	
	SetDatafolder DF
End


Function Proc_checkbox_deltasel(name,value)
	String name
	Variable value
	Variable ckvalue
	DFREF Df= GetDatafolderDFR()
	
	String wn=winname(0,1)
	SetActivesubwindow $winname(0,1)#Offset_panel
	//wn="Style_"+wn
	SetDatafolder $(DF_GP+wn)
	
	NVAR gv_deltaflag
	
	strswitch (name)
		case "DCs_offck5":
			ckvalue=0
			break
		case "DCs_offck6":
			ckvalue=1
			break	
		case "DCs_offck7":
			ckvalue=2
			break
	endswitch
	CheckBox DCs_offck5, value=ckvalue==0
	CheckBox DCs_offck6, value=ckvalue==1
	CheckBox DCs_offck7, value=ckvalue==2
	gv_deltaflag=ckvalue
		
	SetDatafolder df
End	

Function Proc_checkbox_offsetsel(name,value)
	String name
	Variable value
	Variable ckvalue
	DFREF Df= GetDatafolderDFR()
	
	String wn=winname(0,1)
	SetActivesubwindow $winname(0,1)#Offset_panel
	//wn="Style_"+wn
	SetDatafolder $(DF_GP+wn)
	
	NVAR gv_offindex
	
	strswitch (name)
		case "DCs_offck0":
			ckvalue=0
			break
		case "DCs_offck1":
			ckvalue=1
			break
		case "DCs_offck2":
			ckvalue=2
			break	
		case "DCs_offck3":
			ckvalue=3
			break	
		case "DCs_offck4":
			ckvalue=4
			break	
	endswitch
	CheckBox DCs_offck0, value=ckvalue==0
	CheckBox DCs_offck1, value=ckvalue==1
	CheckBox DCs_offck2, value=ckvalue==2
	CheckBox DCs_offck3, value=ckvalue==3
	CheckBox DCs_offck4, value=ckvalue==4	
	
	gv_offindex=ckvalue
		
	SetDatafolder df
End	



Function GP_ColorMarkersLines()
	CreateKBColorizePanel_ARPES()
	//ShowKBColorizePanel()
End


Function GP_autoTicks()
	PauseUpdate; Silent 1
	
	String wname=winname(0,1)
	
	GetAxis /Q /W=$wname bottom
	if (V_flag==1)
		return 0
	endif
	
	Variable bottom_min=V_min
	Variable bottom_max=V_max
	
	GetAxis /Q /W=$wname left
	if (V_flag==1)
		return 0
	endif
	
	Variable left_min=V_min
	Variable left_max=V_max
	
	
	String bottomAxisinfo=axisinfo(wname,"bottom")
	String leftAxisinfo=axisinfo(wname,"left")
	
	Variable bottomtickflag=NumberByKey("tick(x)", bottomAxisinfo  , "="  , ";")
	Variable lefttickflag=NumberByKey("tick(x)", leftAxisinfo  , "="  , ";")
	
	if  ((bottomtickflag!=3)&&(lefttickflag!=3))
		GetWindow /Z $wname,gsize
		Variable aspect=(V_right-V_left)/(V_bottom-V_top)
		if (aspect>1)
			Variable leftticknum=3
			Variable botticknum=trunc(3*aspect)
		else
			botticknum=3
			leftticknum=trunc(3/aspect)
		endif
	elseif (bottomtickflag==3)
		leftticknum=3
		botticknum=0
	elseif (lefttickflag==3)
		leftticknum=0
		botticknum=3
	endif
	
	Variable left_minorticknum=1
	Variable bot_minorticknum=1
	
	prompt 	leftticknum,"Left tick Num:"
	prompt 	botticknum,"Bottom tick Num:"
	prompt 	left_minorticknum,"Left minor tick Num:"
	prompt 	bot_minorticknum,"Bottom minor tick Num:"
	
	doprompt "Auto tick",leftticknum,left_minorticknum,botticknum,bot_minorticknum
	if (V_flag==1)
		return 0
	endif
	
	Variable leftdp,botdp
	
	if  ((bottomtickflag!=3)&&(lefttickflag!=3))
		Variable lefttickInt=returntickint(leftticknum,left_max,left_min,leftdp)
		Variable bottickint=returntickint(botticknum,bottom_max,bottom_min,botdp)
		ModifyGraph manTick(bottom)={0,bottickint,0,botdp},manMinor(bottom)={bot_minorticknum,0}
		ModifyGraph manTick(left)={0,lefttickint,0,leftdp},manMinor(left)={left_minorticknum,0}
	elseif (bottomtickflag==3)
		lefttickInt=returntickint(leftticknum,left_max,left_min,leftdp)
		ModifyGraph manTick(left)={0,lefttickint,0,leftdp},manMinor(left)={left_minorticknum,0}
	elseif (lefttickflag==3)
		bottickint=returntickint(botticknum,bottom_max,bottom_min,botdp)
		ModifyGraph manTick(bottom)={0,bottickint,0,botdp},manMinor(bottom)={bot_minorticknum,0}
	endif
	

	
	//ModifyGraph manTick(bottom)={0,1,0,0},manMinor(bottom)={left_minorticknum,0}
	
	
	
End

Function returntickint(leftticknum,left_max,left_min,dp)
	Variable leftticknum
	Variable left_max
	Variable left_min
	Variable &dp
	
	Variable data=abs(left_max-left_min)/(leftticknum-1)
	
	Variable tempdata=data
	variable factor=100000000
	do 
	
		tempdata=trunc(tempdata*factor)/factor
		if (tempdata==0)
			tempdata=1/factor
		endif
		
		if  (floor(abs(left_max-left_min)/tempdata)<(leftticknum-1)) 
			factor*=10
			break
		else
			factor/=10
		endif
	while (1)
	
	if (1/factor>=1)
		dp=0//strlen(num2str(1/factor))-1
	else
		dp=strlen(num2str(1/factor))-2
	endif
	
	return trunc(data*factor)/factor
	
End

Function GP_ReverseAxis()
	string s
	
	String axisname="bottom"
	
	prompt 	axisname,"Axis name",popup,"bottom;left;both"
	
	doprompt "Reverse Axis", axisname
	
	if (V_flag==1)
		return 0
	endif
	
	if (stringmatch(axisname,"bottom"))
		GetAxis/Q bottom
		sprintf s,"SetAxis%s bottom,%.15g,%.15g","/R"[0,3*(V_max>V_min)-1],V_max,V_min
		Execute s
	elseif (stringmatch(axisname,"left"))
		GetAxis/Q left
		sprintf s,"SetAxis%s left,%.15g,%.15g","/R"[0,3*(V_max>V_min)-1],V_max,V_min
		Execute s
	else
		GetAxis/Q bottom
		sprintf s,"SetAxis%s bottom,%.15g,%.15g","/R"[0,3*(V_max>V_min)-1],V_max,V_min
		Execute s
		GetAxis/Q left
		sprintf s,"SetAxis%s left,%.15g,%.15g","/R"[0,3*(V_max>V_min)-1],V_max,V_min
		Execute s
	endif
End

Function GP_DrawZeroLine()
	Variable/D Ef
	Variable m,lineflag=0
	Prompt Ef,"Value"
	prompt m,"axis",popup,"Bottom;Left;"
	prompt lineflag,"LineType",popup,"- - -;----;"
	doprompt "DrawZeroLine",ef,m,lineflag
	if (V_flag)
		return 0
	endif
	SetDrawLayer UserFront
	
	if (lineflag==1)
		SetDrawEnv dash= 3
	endif
	
	if (m-1)
		SetDrawEnv xcoord=prel,ycoord=left,dash= 3
		DrawLine 0,ef,1,ef
	else
		SetDrawEnv xcoord= bottom,ycoord= prel
		DrawLine Ef,0,Ef,1
	endif
	
	
End

Function GP_LeftLabel()
	Variable labelflag
	String wname=winname(0,1)
	labelflag=Numberbykey("noLabel(x)",Axisinfo(wname,"left"),"=",";")
	if (labelflag)
	ModifyGraph noLabel(left)=0
	ModifyGraph tick(left)=0
	else
	ModifyGraph noLabel(left)=1
	ModifyGraph tick(left)=3
	endif
End

Function GP_showLabel()
	Variable labelflag
	Variable Axisflag
	prompt Labelflag,"Display",popup,"Show;Off;"
	prompt Axisflag,"Axis name",popup,"Left;Bottom;All;"
	Doprompt "Show Label",axisflag,labelflag
	
	if (V_flag==1)
		return 0
	endif
	
	if ((Axisflag==1)||(Axisflag==3))
		if (labelflag==1)
		ModifyGraph noLabel(left)=0
		ModifyGraph tick(left)=0
		else
		ModifyGraph noLabel(left)=1
		ModifyGraph tick(left)=3
		endif
	endif
	
	if ((Axisflag==2)||(Axisflag==3))
		if (labelflag==1)
		ModifyGraph noLabel(bottom)=0
		ModifyGraph tick(bottom)=0
		else
		ModifyGraph noLabel(bottom)=1
		ModifyGraph tick(bottom)=3
		endif
	endif
End

Function GP_ReverseOrder()
	DFREF DF=GetDatafolderDFR()
	String gname=winname(0,1)
	String List,Trace1N,Trace2N

	list = TraceNameList(gname, ";",1)

	Variable item=ItemsInList(List,";")
	Variable index=0
	do 
		Trace1N=Stringfromlist(index,List,";")
		Trace2N=Stringfromlist((item-1),List,";")
		ReorderTraces /W=$gname $Trace1N,{$Trace2N}
		List= TraceNameList(gname, ";",1)
		index+=1
	while (index<item)
	SetDatafolder DF
End






Function GP_JoinSlices()
	DFREF DF=GetDatafolderDFR()

	String Wname=winname(0,1)
	String Tracename="",Tlist=TraceNamelist(Wname,";",1)
	//Tlist=SortList(Tlist,";",16)
	Variable items=itemsInlist(Tlist,";")

	Variable y0,y1,yscaleflag,reverseflag
	y0=0
	y1=1
	yscaleflag=1
	reverseflag=1
	prompt y0,"y0"
	prompt y1,"y1"
	prompt yscaleflag,"Set Y scale",popup,"Start_Interval;Start_End;"
	prompt reverseflag,"ReverseXY",popup,"Yes;No;"
	Doprompt "Set Y axis",y0,y1,yscaleflag,reverseflag
	
	if (V_flag==1)
	Return 0
	endif
	
	Variable index=0
	String WaveN
	WaveN=Stringfromlist(0,Tlist,";")//GetBrowserSelection(0)
	Wave Point=TraceNameToWaveRef(wname,WaveN)//$WaveN
	DFREF Trace_path=GetWavesDataFolderDFR(Point)

	Variable x1=0,x2=0,dx=1,tempx1,tempx2,tempdx,interflag1=0,interflag2=0
	x1=leftx(point)
	x2=pnt2x(point,numpnts(point)-1)
	dx=dimdelta(point,0)
	index=1

	do
		WaveN=Stringfromlist(index,Tlist,";")//GetBrowserSelection(index)
		if (strlen(WaveN)==0)
		break
		endif

 		Wave Point=TraceNameToWaveRef(wname,WaveN) //$WaveN
		
 		tempx1=leftx(point)
		tempx2=pnt2x(point,numpnts(point)-1)
 		tempdx=dimdelta(point,0)
 
 		if ((interflag1==0)&&((tempx1!=x1)||(tempx2!=x2)))
 			interflag1=1
 		endif
   
 		if ((interflag2==0)&&(tempdx!=dx))
			interflag2=1	
 		endif	
 
		if  (tempdx<dx)
			 dx=tempdx
 		endif
 		if (tempx1<x1)
 			x1=tempx1
		 endif
 		if (tempx2>x2)
 			x2=tempx2
 		endif 
		index+=1 
	while (1)

	if (interflag1==1)
	Doalert /T="joinmultwave" 1,"Unequal range, Interp?"
		if (V_flag==1)
		else
		SetDatafolder DF
		return 1
		endif
	endif
	if (interflag2==1) 
		Doalert /T="joinmultwave" 1,"Unequal steps, Interp?"
		if (V_flag==1)
		else
		SetDatafolder DF
		return 1
		endif
	endif

	index=0
	Variable Pnum
	if (x2>x1)
		Pnum=floor((x2-x1)/dx)+1
	else
		Pnum=1
	endif
	
	SetDatafolder Trace_path
	newDatafolder /o/s Graph_Proc
	make /o /n=(Pnum,1) JoinWave
	setscale /I x,x1,x2,JoinWave
	
	
	do

		WaveN=Stringfromlist(index,Tlist,";")//GetBrowserSelection(index)
		if (strlen(WaveN)==0)
		break
		endif

 		Wave Point=TraceNameToWaveRef(wname,WaveN) //$WaveN

		redimension /N=(Pnum,(index+1)) JoinWave
		JoinWave[][index]=Point(x)
	index+=1
	while (1)
	
	if (yscaleflag==1)
		setscale /P y,y0,y1,JoinWave
	else
		Setscale /I y,y0,y1,JoinWave
	Endif
	
	if (reverseflag)
		MatrixTranspose Joinwave
	endif
	
	//display_wave(JoinWave,0,1)

SetDatafolder DF
End



Function GP_Editmode()
GraphWaveEdit
End


Function GP_Normalmode()
GraphNormal
End

Function GP_DrawNewWave()
GraphWaveDraw
End

Function GP_DrawFreehandWave()
GraphWaveDraw/F=3
End


Function EasyAppend(new)
	Variable new
	DFREF df=GetdatafolderDFR()
	Variable index=0
	String Oname,Oname1,win,OnameList
	String tracelist
	Variable m=0
	
	Variable imageflag=0
	
	OnameList=MakeWlist()
	if (strlen(Onamelist)==0)
		SetDatafolder DF
		return 0
	endif
	
	
	Oname=Stringfromlist(0,Onamelist)
	if (Waveexists($Oname)==0)
		if (new)
			prompt m,"Disaply Mode",popup,"All;Seperate;Cutkxky;XYPairs"
		else
			prompt m,"Disaply Mode",popup,"All;N/A;Cutkxky;XYPairs"
		endif
		doprompt "Display MultiWave",m
		if (V_flag)
	    	SetDatafolder DF
	   		return 0
	   	endif
	   	
	   	SetDatafolder $Oname
	   
	   	if (m==3)
	   	   	tracelist= WaveList("YCuts_*", ";", "DIMS:1" )
	   	elseif (m==4)
	   			tracelist= WaveList("*y*", ";", "DIMS:1" )
	   			if (strlen(tracelist)==0)
	   				tracelist= WaveList("*Y*", ";", "DIMS:1" )
	   			endif
	   			if (strlen(tracelist)==0)
	   				doalert 0,"Can't find Ywave"
	   				setDatafolder DF
	   				return 0
	   			endif
	   	else
	  		tracelist= WaveList("*", ";", "DIMS:1" )
	  		if (strlen(tracelist)==0)
	  			tracelist= WaveList("*", ";", "DIMS:2" )
	  			imageflag=1
	  		endif
	  	 endif
	 	   	
	else
		
		if (itemsinlist(Onamelist,";")>1)
			if (new)
				prompt m,"Disaply Mode",popup,"All;Seperate;Cutkxky;XYPairs"
			else
				prompt m,"Disaply Mode",popup,"All;N/A;Cutkxky;XYPairs"
			endif
			doprompt "Display MultiWave",m	
			if (V_flag)
	    		SetDatafolder DF
	   			return 0
	   		endif
	   	else
	   		m=1
		endif
		
		if (m==3)
			tracelist=Match_StringList("*YCuts_*",Onamelist,";")
		 elseif (m==4)
	   		tracelist= Match_StringList("*y*",Onamelist,";")
	   		if (strlen(tracelist)==0)
	   			tracelist= Match_StringList("*Y*",Onamelist,";")
	   		endif
	   		if (strlen(tracelist)==0)
	   			doalert 0,"Can't find Ywave"
	   			setDatafolder DF
	   			return 0
	   		endif
		else
			tracelist=Onamelist
		endif
		
	endif
	
	index=0
	 		
	do
		Oname=Stringfromlist(index,tracelist)
		if (strlen(Oname)==0)
			break
		endif
	
		WAVE Wtemp=$Oname
	 	
	 		if (m==3)
	 			Wave Ycut=$Oname
	 			Wave Xcut=$(replacestring("YCuts_",Oname,"XCuts_"))
	 			if (new)
	 				if (index==0)
	 					display_XYwave(Ycut,Xcut,0,1)
	 				else
	 					display_XYwave(Ycut,Xcut,1,1)
	 				endif
	 			else
	 				display_XYwave(Ycut,Xcut,1,1)
	 			endif
	 		elseif (m==4)
	 			Wave Ycut=$Oname
	 			Wave Xcut=$(replacestring("Y",Oname,"X"))
	 			if (new)
	 				if (index==0)
	 					display_XYwave(Ycut,Xcut,0,1)
	 				else
	 					display_XYwave(Ycut,Xcut,1,1)
	 				endif
	 			else
	 				display_XYwave(Ycut,Xcut,1,1)
	 			endif
	 		else
	 			if (new)
	 				if (m==1)
	 					if (index==0)
	 						display_wave(Wtemp,0,1)
	 					else
	 						display_wave(Wtemp,1,1)
	 					endif
	 			elseif (m==2)
	 				display_wave(Wtemp,0,1)
	 			endif
	 		else
	 			display_wave(Wtemp,1,1)
	 		endif
	 	endif
	index+=1
	while (1)
	SetDatafolder DF
	
End





//////////////////Add Cursor cross///////////////////////

Function  /DF Initial_CrossCursorPanel()
	String wname=winname(0,1)
	DFREF DFR_GP=$DF_GP
	SetDatafolder DFR_GP
	//NewDataFolder/O/S root:WinGlobals:HairlineCursorPanel
	newDatafolder /o/s $wname
	
	//Variable/G curXtra=2
	//String/G csrgraph0="<no value>"
	//String/G csrgraph1="<no value>"
	//String/G csrgraphn="<no value>"
	//String/G expression="X1-X0"
	Variable /G gv_MagnifierX=3
	Variable /G gv_Magflag=0
	//Variable /G gv_Hairnum=0
	//Variable /G gV_Hairmovestep=0.5
	//Variable /G gv_crossHairflag=0
	Variable /G gv_crossHairflag=0
	variable /G X0
	variable /G X1
	variable /G Y0
	variable /G Y1
	variable /G Z0
	variable /G Z1
	variable /G DX
	variable /G DY
	variable /G DZ
	variable /G CX
	variable /G CY
	variable /G CZ
	
	
	Make /o/n=5 HairYCross,HairXCross
	
	Variable /G AExists= strlen(CsrInfo(A,wname)) > 0	
	Variable /G BExists= strlen(CsrInfo(B,wname)) > 0
	
	String Datalist=imagenamelist(wname,";")
	Variable dimflag=0
	if (strlen(Datalist)==0)
		Datalist=Tracenamelist(wname,";",1)
		dimflag=1
	else
		dimflag=2
	endif
	if (strlen(Datalist)==0)
		return DFR_GP
	else
		String tracename=Stringfromlist(0,Datalist,";")
	endif
	
	if (AExists==0)
	//ShowInfo /W=$wname
		if (dimflag==1)
			Cursor/W=$wname/P/H=1 A $tracename 10
		else
			Cursor/I /W=$wname /P/H=1 A $tracename 10,10
		endif
	endif
	
	if (BExists==0)
	//ShowInfo /W=$wname
		if (dimflag==1)
			Cursor/W=$wname/P/H=1 B $tracename 10
		else
			Cursor/I/W=$wname/P/H=1 B $tracename 10,10
		endif
	endif
	
	
	Return GetDatafolderDFR()
end

Function	CrosslineCursorPanel() //: Panel
	DFREF DF=GetDatafolderDFR()
	String wname=Winname(0,1)
	if (strlen(wname)==0)
		return 1
	endif
	String Cwnamelist=ChildWindowList(wname)
 	Dowindow /F $wname
 	if (Findlistitem("CrossCursor_panel",Cwnamelist,";",0)!=-1)
 	KillWindow $wname#CrossCursor_panel
 	//SetDatafolder DF
 	return 0
	endif
	
	DFREF DFR_HCP=Initial_CrossCursorPanel()
	SetDatafolder DFR_HCP
	String DFS_HCP=GetDatafolder(1)
	NVAR gv_crossHairflag=DFR_HCP:gv_crossHairflag
	NVAR X0,X1,Y0,Y1,Z0,Z1,DX,DY,DZ,CX,CY,CZ
	
	Variable SC=screensize(5)
	Variable width=380*SC
	Variable height=160*SC
	
	NewPanel/K=1 /Host=$wname/EXT=0 /W=(0,44,width,44+height)/N=CrossCursor_panel
	SetWindow $wname#CrossCursor_panel hook(myhook)=MyCrossCursorHook
	SetDrawLayer UserBack
	SetDrawEnv fname= "Geneva"
	DrawText 33*SC,18*SC,"Cursor:"
	SetDrawEnv fstyle= 1,fsize=18*SC,textrgb= (52224,0,0)
	DrawText 49*SC,42*SC,"A"
	SetDrawEnv fname= "Geneva",fstyle= 1,fsize=18*SC,textrgb= (3,52428,1)
	DrawText 49*SC,82*SC,"B"
	SetDrawEnv fname= "Geneva",textrgb= (52224,0,0)
	DrawText 106*SC,18*SC,"X_A"
	//DrawLine 17,17,466,17
	SetDrawEnv fname= "Geneva",textrgb= (52224,0,0)
	DrawText 189*SC,18*SC,"Y_A"
	SetDrawEnv fname= "Geneva",textrgb= (52224,0,0)
	DrawText 280*SC,18*SC,"Z_A"
	
	SetDrawEnv fname= "Geneva",textrgb= (0,52224,0)
	DrawText 106*SC,62*SC,"X_B"
	SetDrawEnv fname= "Geneva",textrgb= (0,52224,0)
	DrawText 189*SC,62*SC,"Y_B"
	SetDrawEnv fname= "Geneva",textrgb= (0,52224,0)
	DrawText 280*SC,62*SC,"Z_B"
	//SetDrawEnv fname= "Geneva",fsize= 14,textxjust= 2,textyjust= 1
	//DrawText 107,107,"delta (1-0):"
	SetDrawEnv fname= "Geneva"
	
	ValDisplay valdispX0,pos={105*SC,25*SC},size={77*SC,20*SC}
	ValDisplay valdispX0,limits={0,0,0},barmisc={0,1000},value= #(DFS_HCP+"X0")
	ValDisplay valdispY0,pos={188*SC,25*SC},size={77*SC,20*SC}
	ValDisplay valdispY0,limits={0,0,0},barmisc={0,1000},value= #(DFS_HCP+"Y0")
	ValDisplay valdispZ0,pos={271*SC,25*SC},size={76*SC,20*SC}
	ValDisplay valdispZ0,limits={0,0,0},barmisc={0,1000},value= #(DFS_HCP+"Z0")
	ValDisplay valdispX1,pos={105*SC,65*SC},size={77*SC,20*SC}
	ValDisplay valdispX1,limits={0,0,0},barmisc={0,1000},value= #(DFS_HCP+"X1")
	ValDisplay valdispY1,pos={188*SC,65*SC},size={77*SC,20*SC}
	ValDisplay valdispY1,limits={0,0,0},barmisc={0,1000},value= #(DFS_HCP+"Y1")
	ValDisplay valdispZ1,pos={271*SC,65*SC},size={77*SC,20*SC}
	ValDisplay valdispZ1,limits={0,0,0},barmisc={0,1000},value= #(DFS_HCP+"Z1")
	
	titlebox XDtb,pos={105*SC,95*SC},size={77*SC,20*SC},title="X1-X0",frame=0
	ValDisplay valdispXD,pos={105*SC,110*SC},size={77,20*SC}
	ValDisplay valdispXD,limits={0,0,0},barmisc={0,1000},value=  #(DFS_HCP+"DX")
	titlebox YDtb,pos={188*SC,95*SC},size={77*SC,20*SC},title="Y1-Y0",frame=0
	ValDisplay valdispYD,pos={188*SC,110*SC},size={77,20*SC}
	ValDisplay valdispYD,limits={0,0,0},barmisc={0,1000},value=  #(DFS_HCP+"DY")
	titlebox ZDtb,pos={271*SC,95*SC},size={77*SC,20*SC},title="Z1-Z0",frame=0
	ValDisplay valdispZD,pos={271*SC,110*SC},size={77,20}
	ValDisplay valdispZD,limits={0,0,0},barmisc={0,1000},value=  #(DFS_HCP+"DZ")
	
	Checkbox FreeCursor,pos={130*SC,178*SC},size={70*SC,20*SC},title="Free Pos",proc=proc_bt_freeCursor,value=1
	Checkbox Appendcross,pos={195*SC,178*SC},size={40*SC,20*SC},proc=CkCrossCursor,title="Cross",variable=gv_crossHairflag
	
	Checkbox Acursor,pos={300*SC,178*SC},size={40*SC,20*SC},title="A",proc=Cursor_disp_change
	Checkbox Bcursor,pos={330*SC,178*SC},size={40*SC,20*SC},title="B",proc=Cursor_disp_change
	
	Button AddLV,pos={250*SC,168*SC},size={40*SC,15*SC},title="LV",proc=Cursor_zeroline
	Button AddLH,pos={250*SC,185*SC},size={40*SC,15*SC},title="LH",proc=Cursor_zeroline
	
	titlebox XCtb,pos={105*SC,135*SC},size={77*SC,20*SC},title="(X1+X0)/2",frame=0
	ValDisplay valdispXC,pos={105*SC,150*SC},size={77*SC,20*SC}
	ValDisplay valdispXC,limits={0,0,0},barmisc={0,1000},value=  #(DFS_HCP+"CX")
	
	titlebox YCtb,pos={188*SC,135*SC},size={77*SC,20*SC},title="(Y1+Y0)/2",frame=0
	ValDisplay valdispYC,pos={188*SC,150*SC},size={77*SC,20*SC}
	ValDisplay valdispYC,limits={0,0,0},barmisc={0,1000},value=  #(DFS_HCP+"CY")
	
	titlebox Zsumtb,pos={271*SC,135*SC},size={77*SC,20*SC},title="(Z1+Z0)/2",frame=0
	ValDisplay valdispZC,pos={271*SC,150*SC},size={70*SC,20*SC}
	ValDisplay valdispZC,limits={0,0,0},barmisc={0,1000},value=  #(DFS_HCP+"CZ")
	
	
	//SetVariable setvarGrf0,pos={392,25},size={76,17},title=" ",fSize=12
	//SetVariable setvarGrf0,limits={-INF,INF,1},value= DFR_HCP:csrgraph0
	//SetVariable setvarGrf1,pos={392,50},size={76,17},title=" ",fSize=12
	//SetVariable setvarGrf1,limits={-INF,INF,1},value= DFR_HCP:csrgraph1
	//SetVariable setvarGrf2,pos={392,75},size={76,17},title=" ",fSize=12
	//SetVariable setvarGrf2,limits={-INF,INF,1},value= DFR_HCP:csrgraphn
	//SetVariable setvarExpression,pos={275,178},size={190,15},title=" "
	//SetVariable setvarExpression,limits={-INF,INF,1},value= DFR_HCP:expression
	//Button buttonPrint,pos={218,175},size={50,20},proc=ButtonProcPrintExpr,title="Print:"
	
	//Button buttommagnifier,pos={20,175},size={70,20},proc=ButtonCursorMagnifier,title="Magnifier"
	SetVariable setvarmag,pos={20*SC,178*SC},size={100*SC,20*SC},title="MagnifierX:",limits={1,inf,1},value=DFR_HCP:gv_MagnifierX

	//ValDisplay valdispX0,value= #"no value"
	//ValDisplay valdispY0,value= #"no value"
	//ValDisplay valdispZ0,value= #"no value"
	//ValDisplay valdispX1,value= #"no value"
	//ValDisplay valdispY1,value= #"no value"
	//ValDisplay valdispZ1,value= #"no value"
	//ValDisplay valdispXD,value= #"no value"
	//ValDisplay valdispYD,value= #"no value"
	//ValDisplay valdispZD,value= #"no value"
	
	//ButtonProcSetn("Set0")
	//ButtonProcSetn("Set1")
	ButtonCursorMagnifier("dummy")
	proc_bt_freeCursor("dummy",1)
	Update_CrossCursor_panel(wname)
	UpdateCursorMagnifier(wname,2)
	
	SetDatafolder DF
end

Function Cursor_zeroline(ctrlname)
	String ctrlname
	
	DFREF DF=GetDatafolderDFR()
	String wname=winname(0,1)
	DFREF DFR_HCP=$(DF_GP+wname)
	
	SetDatafolder DFR_HCP
	
	NVAR X0,X1,Y0,Y1
		
	Variable/D Ef
	Variable m,lineflag=0
	
	controlinfo /W=$wname#CrossCursor_panel ACursor
	if (V_value)
		Variable Aflag=1
	else
		Aflag=0
	endif
	
	if (Stringmatch(ctrlname,"AddLV"))
		m=1
		Ef=(Aflag)?(X0):(X1)
	else
		m=2
		Ef=(Aflag)?(Y0):(Y1)
	endif
	
	prompt m,"axis",popup,"Bottom;Left;"
	Prompt Ef,"Value"
	prompt lineflag,"LineType",popup,"- - -;----;"
	doprompt "DrawZeroLine",ef,m,lineflag

	if (V_flag)
		return 0
	endif
	SetDrawLayer UserFront
	
	if (lineflag==1)
		SetDrawEnv dash= 3
	endif
	
	if (m-1)
		SetDrawEnv xcoord=prel,ycoord=left,dash= 3
		DrawLine 0,ef,1,ef
	else
		SetDrawEnv xcoord= bottom,ycoord= prel
		DrawLine Ef,0,Ef,1
	endif
	
	
	SetDatafolder DF
	
End
Function Cursor_disp_change(ctrlname,value)
	String ctrlname
	variable value
	String wname=winname(0,1)
	
	Variable ckvalue
	strswitch(ctrlname)
	case "Acursor":
		ckvalue=1
	break
	case "Bcursor":
		ckvalue=2
	break
	endswitch
	
	checkbox Acursor, win=$wname#CrossCursor_panel,value=ckvalue==1
	checkbox Bcursor, win=$wname#CrossCursor_panel,value=ckvalue==2
	
	UpdateCursorMagnifier(wname,ckvalue)
end

Function proc_bt_freeCursor(ctrlname,value)
	String ctrlname
	variable value
	DFREF DF=GetDatafolderDFR()
	String wname=winname(0,1)
	DFREF DFR_HCP=$(DF_GP+wname)
	//if (Stringmatch(wname,"*panel*"))
	//	Checkbox FreeCursor, win=$wname#CrossCursor_panel,value=0
	//	return 0
	//endif
	
	Variable AExists= strlen(CsrInfo(A,wname)) > 0	
	Variable BExists= strlen(CsrInfo(B,wname)) > 0
	Variable dimflag
	
	if (AExists)
		String Acsrinfo=csrinfo(A,wname)
		String tracenameA=stringbykey("TNAME",Acsrinfo,":",";")
		if (strlen(traceinfo(wname,tracenameA,0))>0)
			dimflag=1
		else
			dimflag=2
		endif
	else
		String Datalist=Tracenamelist(wname,";",1)
		if (strlen(Datalist)==0)
			Datalist=Imagenamelist(wname,";")
			dimflag=2
		else
			dimflag=1
		endif
		if (strlen(Datalist)==0)
			return 0
		else
			tracenameA=Stringfromlist(0,Datalist,";")
		endif
	
	endif
	
	if (BExists)
		String Bcsrinfo=csrinfo(A,wname)
		String tracenameB=stringbykey("TNAME",Bcsrinfo,":",";")
		if (strlen(traceinfo(wname,tracenameB,0))>0)
			dimflag=1
		else
			dimflag=2
		endif
	else
		Datalist=Tracenamelist(wname,";",1)
		if (strlen(Datalist)==0)
			Datalist=Imagenamelist(wname,";")
			dimflag=2
		else
			dimflag=1
		endif
		if (strlen(Datalist)==0)
			return 0
		else
			tracenameB=Stringfromlist(0,Datalist,";")
		endif
	
	endif
			
	if (value==0)
		if (dimflag==1)
			Cursor/W=$wname/P/H=1 A $tracenameA 10
			Cursor/W=$wname/P/H=1 B $tracenameB 10
		else
			Cursor/W=$wname/P/I/H=1 A $tracenameA 10,10
			Cursor/W=$wname/P/I/H=1 B $tracenameB 10,10
		endif
	else
		if (dimflag==1)
			Cursor/W=$wname/F/P/H=1 A $tracenameA 0.5,0.5
			Cursor/W=$wname/F/P/H=1 B $tracenameB 0.5,0.5
		else
			Cursor/W=$wname/F/P/I/H=1 A $tracenameA 0.5,0.5
			Cursor/W=$wname/F/P/I/H=1 B $tracenameB 0.5,0.5
		endif
	endif
end

Function ButtonCursorMagnifier(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderDFR()
	String graphname=winname(0,1)
	DFREF DFR_HCP=$(DF_GP+graphname)
	SetDatafolder DFR_HCP

	//String/G MagnifiedGraph = graphName
	//String/G MagnifiedHAxis = "A"//HAxis
	//String/G MagnifiedVAxis = "B"//1VAxis
	Variable/G hasInfoShowing = 0
	Make /o/n=5 XMagHair
	Make /o/n=5 YMagHair
	Variable /G xyswapflag=0
	
	Variable SC=Screensize(5)
	Variable width=380*SC
	Variable height=160*SC
		
	String Chwnamelist=childwindowlist(Graphname+"#CrossCursor_Panel")
	if (strsearch(Chwnamelist,"Magnifier",0)>=0)
		Killwindow $graphname#CrossCursor_Panel#Magnifier
		MoveSubwindow /W=$graphname#CrossCursor_Panel,fnum=(0,44,width,44+height)
		SetDatafolder DF
		return 0
	else
		height=516*SC
		MoveSubwindow /W=$graphname#CrossCursor_Panel,fnum=(0,44,width,44+height)
		//if (stringmatch(graphname,"*p2323anel*")&&(stringmatch(graphname,"BZ_panel*")==0))
		//	String imglist=Imagenamelist(graphname,";")
		//	string imgname=Stringfromlist(0,imglist,";")
		//	String tinfo=Imageinfo(graphname,imgname,0)
		//	Wave w_image=Imagenametowaveref(graphname,imgname)
		//	String xaxname,yaxname
	
		//	if( StrLen(tinfo) != 0 )
		//	xaxname=  StringByKey("XAXIS",tinfo)
		//	yaxname=  StringByKey("YAXIS",tinfo)
		//	endif

		//	Variable x0,x1,y0,y1
		//	GetAxis/Q $yaxname; y0= V_min; y1= V_max
		//	GetAxis/Q $xaxname; x0= V_min; x1= V_max
		//	if( StrLen(tinfo) != 0 )
		//	String 	axinfo= StringByKey("AXISFLAGS",tinfo)+" "
		//	endif
			
		//	Variable temp=strsearch(tinfo,"RECREATION",0)
		//	String recreationstr=tinfo[temp+11,inf]
		//	recreationstr=replacestring(";",recreationstr,",")
		//	recreationstr=recreationstr[0,strlen(recreationstr)-2]
		//	print recreationstr
			
		//	display /w=(0,0,200,200) /n=tempimage
		//	Execute "Appendimage /W=tempimage "+axinfo+GetWavesDatafolder(w_image,2)
		//	ModifyGraph /W=tempimage freePos=0
		//	//appendimage /W=tempimage w_image
		//	Setaxis /W=tempimage $yaxname,y0,y1
		//	Setaxis /W=tempimage $xaxname,x0,x1
		//	Execute "ModifyImage /W=tempimage w_image "+recreationstr
		//	String winrec=WinRecreation("tempimage", 0)
		//	String controls = ControlNameList("tempimage")
		//	DoWindow /K /Z tempimage
		//else
		String winrec= WinRecreation(graphName, 0)
		String 	controls = ControlNameList(graphName)
		//endif
		
		//print winrec
		
		if (strsearch(winrec, "\tShowInfo", 0) >= 0)
			hasInfoShowing = 1
		endif
		ExecuteWinRecreation_CC(winrec, controls)
	endif
	SetDatafolder DF
	
	
	//display /Host=$graphname#HairCursor_Panel /W=(50,200,400,550)/N=Magnifier
//	autopositionwindow /M=1 /R=$graphname Magnifier
	
End

Function ExecutewinRecreation_all(winrec,newwinname,flag)
	String winrec
	String newwinname
	Variable flag
	
	variable beginline=0, endline
	Variable nchars = strlen(winrec)
	String aCommand
		
	String saveDF = GetDataFolder(1)
	SetDataFolder root:
		
	Variable temp
	do
		endline = strsearch(winrec, "\r", beginLine)
		if (endline < 0)
			break
		endif
		
		aCommand = winrec[beginLine, endLine]
		beginLine = endLine+1
		//if (strsearch(aCommand, "\tSetWindow", 0) >= 0)
		
		//	continue
		//endif
		if (strsearch(aCommand, "/EXT=0", 0) >= 0)
			break
		endif
		if (strsearch(aCommand, "Window", 0) == 0)
			continue
		endif
		if (strsearch(aCommand, "PauseUpdate", 0) >= 0)
			continue
		endif
		//if (strsearch(aCommand, "\tControlBar ", 0) >= 0)
		//	continue
		//endif
		if (strsearch(aCommand, "\tCursor", 0) >= 0)
			continue
		endif
		if (strsearch(aCommand, "\tShowInfo", 0) >= 0)
			continue
		endif
		//if (strsearch(aCommand, "axisEnab", 0) >= 0)
		//	continue
		//endif
		//if (strsearch(aCommand, "height", 0) >= 0)
		//	continue
		//endif
		if (CmpStr(aCommand, "EndMacro\r") == 0)
			continue
		endif
		
		
		// fldrSav0 is a (local) string variable created by a graph recreation macro for a graph that uses
		// waves from a non-root data folder. If "String fldrSav0= GetDataFolder(1)" is executed by Execute, it makes
		// a global string. We don't need the saved data folder because we save it above, and the existence of the global in
		// the user's data folder will cause an error if the graph magnifier is shut down and re-started again later.
		// This line will also skip the line in which the recreation macro tries to restore the user's CDF using
		// "SetDataFolder fldrSav0"
		if (strsearch(aCommand, "fldrSav0", 0) >= 0)
			continue
		endif
	//	if (isControlCommand_AP(aCommand, cList))
		//	continue
		//endif
		//Variable displayPos = strsearch(aCommand, "\tDisplay ", 0)
		//if (displayPos >= 0)
		//	String tempStr = aCommand
		//	aCommand = "Display/K=1 "
		//	aCommand += tempStr[displayPos+9, strlen(tempStr)-1]
		//endif
		
		//if (strsearch(aCommand, "Display",0) >= 0)
		//	temp=strsearch(aCommand, "Display",0)
		//	aCommand=acommand[0,temp+6]+acommand[temp+7,inf]
		//endif
		
		Execute aCommand

	while (1)
	
	SetDataFolder saveDF
end

Function ExecuteWinRecreation_CC(winrec, cList)
	String winrec
	String cList		// list of controls in original window. We don't want to execute commands that create controls
	
	variable beginline=0, endline
	Variable nchars = strlen(winrec)
	String aCommand
	
	String graphname=winname(0,1)
	
	DFREF DFR_HCP=$(DF_GP+graphname)
	NVAR xyswapflag=DFR_HCP:xyswapflag
	
	xyswapflag=0
	// window recreation macro should run (at least to start with) in the root data folder
	String saveDF = GetDataFolder(1)
	SetDataFolder root:
	Variable temp
	do
		endline = strsearch(winrec, "\r", beginLine)
		if (endline < 0)
			break
		endif
		
		aCommand = winrec[beginLine, endLine]
		beginLine = endLine+1
		if (strsearch(aCommand, "\tSetWindow", 0) >= 0)
			continue
		endif
		if (strsearch(aCommand, "/EXT=0", 0) >= 0)
			break
		endif
		if (strsearch(aCommand, "Window", 0) >= 0)
			continue
		endif
		if (strsearch(aCommand, "PauseUpdate", 0) >= 0)
			continue
		endif
		if (strsearch(aCommand, "\tControlBar ", 0) >= 0)
			continue
		endif
		if (strsearch(aCommand, "\tCursor", 0) >= 0)
			continue
		endif
		if (strsearch(aCommand, "\tShowInfo", 0) >= 0)
			continue
		endif
		//if (strsearch(aCommand, "axisEnab", 0) >= 0)
		//	continue
		//endif
		//if (strsearch(aCommand, "height", 0) >= 0)
		//	continue
		//endif
		if (CmpStr(aCommand, "EndMacro\r") == 0)
			continue
		endif
		
		
		// fldrSav0 is a (local) string variable created by a graph recreation macro for a graph that uses
		// waves from a non-root data folder. If "String fldrSav0= GetDataFolder(1)" is executed by Execute, it makes
		// a global string. We don't need the saved data folder because we save it above, and the existence of the global in
		// the user's data folder will cause an error if the graph magnifier is shut down and re-started again later.
		// This line will also skip the line in which the recreation macro tries to restore the user's CDF using
		// "SetDataFolder fldrSav0"
		if (strsearch(aCommand, "fldrSav0", 0) >= 0)
			continue
		endif
		if (isControlCommand_AP(aCommand, cList))
			continue
		endif
		Variable displayPos = strsearch(aCommand, "\tDisplay ", 0)
		if (displayPos >= 0)
			String tempStr = aCommand
			aCommand = "Display/K=1 "
			aCommand += tempStr[displayPos+9, strlen(tempStr)-1]
		endif
		
		if (strsearch(aCommand, "Display",0) >= 0)
			temp=strsearch(aCommand, "Display",0)
			aCommand=acommand[0,temp+6]+" /Host="+graphname+"#CrossCursor_Panel /N=Magnifier "+acommand[temp+7,inf]
		endif
		
		if (strsearch(aCommand,"swapXY",0)>=0)
			xyswapflag=1
		endif
		
		Execute aCommand
		//print aCommand
	while (1)
	//print ChildWindowList(graphname+"#HairCursor_Panel")
	Variable SC=ScreenSize(5)
	MoveSubwindow /W=$(graphname)#CrossCursor_Panel#Magnifier fnum=(20*SC,210*SC,370*SC,550*SC)
	DeleteBasednamegraph(graphname+"#CrossCursor_Panel#Magnifier","HairY*",0)
	DeleteBasednamegraph(graphname+"#CrossCursor_Panel#Magnifier","HairCross*",0)
	SetDataFolder saveDF
end


Function isControlCommand_AP(aCommand, cList)
	string aCommand, cList
	
	Variable spacePos = strsearch(aCommand, " ", 1)		// "1" skips the tab character at the beginning
	if (spacePos < 0)
		return 0
	endif
	Variable commaPos = strsearch(aCommand, ",", spacePos)
	if (commaPos < 0)
		return 0
	endif
	String cName = aCommand[spacePos+1, commaPos-1]
	if (FindListItem(cName, cList) < 0)
		return 0
	endif
	
	return 1
end

Function UpdateCursorMagnifier(Graphname,CursorNum)
String graphname
Variable Cursornum

	DFREF DF=GetDatafolderDFR()
	DFREF DFR_HCP=$(DF_GP+graphname)
	
	String Chwnamelist=childwindowlist(Graphname+"#CrossCursor_Panel")

	if (strsearch(Chwnamelist,"Magnifier",0)==-1)
	return 0
	endif
	
	SetDatafolder DFR_HCP
		
	Wave XMagHair
	Wave YMagHair
	NVAR magx=DFR_HCP:gv_magnifierX
	String Yname,CSRname
	if (CursorNum==1)
		Yname=stringbykey("TNAME",csrinfo(A),":",";")
		NVAR offsetX=DFR_HCP:X0
		NVAR offsetY=DFR_HCP:Y0
		checkbox Acursor,win=$graphname#CrossCursor_Panel,value=1
		checkbox bcursor,win=$graphname#CrossCursor_Panel,value=0
		CSRname="A"
	else
		Yname=stringbykey("TNAME",csrinfo(B),":",";")
		NVAR offsetX=DFR_HCP:X1
		NVAR offsetY=DFR_HCP:Y1
		checkbox Acursor,win=$graphname#CrossCursor_Panel,value=0
		checkbox bcursor,win=$graphname#CrossCursor_Panel,value=1
		CSRname="B"
	endif
	
	String tinfo=  TraceInfo(Graphname, Yname, 0)
	if (strlen(tinfo)==0)
		tinfo=Imageinfo(Graphname,Yname,0)
	endif
	
	String xaxname,yaxname
	
	if( StrLen(tinfo) != 0 )
		xaxname=  StringByKey("XAXIS",tinfo)
		yaxname=  StringByKey("YAXIS",tinfo)
	endif

	Variable x0,x1,y0,y1
	GetAxis/Q $yaxname; y0= V_min; y1= V_max
	GetAxis/Q $xaxname; x0= V_min; x1= V_max
	
	Variable HaxisMin,HaxisMax,Vaxismin,Vaxismax
	
	HaxisMin=offsetx-(x1-x0)/2/MagX
	HaxisMax=offsetx+(x1-x0)/2/MagX
	VaxisMin=offsetY-(y1-y0)/2/MagX
	VaxisMax=offsetY+(y1-y0)/2/MagX
	
	CheckDisplayed /W=$Graphname#CrossCursor_Panel#Magnifier YMagHair
	Wave YMagHair=DFR_HCP:YMagHair
	Wave XMagHair=DFR_HCP:XMagHair
	String tbstr=""
	if (V_flag==0)
		if( StrLen(tinfo) != 0 )
			String 	axinfo= StringByKey("AXISFLAGS",tinfo)+" "
		endif
		Execute "AppendToGraph /W="+Graphname+"#CrossCursor_Panel#Magnifier "+axinfo+" YMagHair"+" vs "+"XMagHair"
		sprintf tbstr,"\Z14"+CSRname+":(%.4f, %.4f)",offsetx,offsety
		if ( Cursornum==1 )
		TextBox /W=$Graphname#CrossCursor_Panel#Magnifier /A=MC/B=1/F=0/N=TB_CR/G=(52224,0,0 )/X=-4 tbstr
		else
		TextBox /W=$Graphname#CrossCursor_Panel#Magnifier /A=MC/B=1/F=0/N=TB_CR/G=(0,52224,0 )/X=-4 tbstr
		endif
		
	else
		sprintf tbstr,"\Z14"+CSRname+":(%.4f, %.4f)",offsetx,offsety
		if ( Cursornum==1 )
		TextBox /W=$Graphname#CrossCursor_Panel#Magnifier /C/A=MC/B=1/F=0/N=TB_CR/G=(52224,0,0)/X=-4  tbstr
		else
		TextBox /W=$Graphname#CrossCursor_Panel#Magnifier /C/A=MC/B=1/F=0/N=TB_CR/G=(0,52224,0)/X=-4  tbstr
		endif
	endif
	
	XMagHair={x0,x1,Nan,offsetx,offsetx}
	YMagHair={offsety,offsety,Nan,y1,y0}
	
	if( Cursornum==1 )
			Modifygraph /W=$Graphname#CrossCursor_Panel#Magnifier rgb(YMagHair)=(52224,0,0)	// red
	elseif( Cursornum==2 )
			Modifygraph /W=$Graphname#CrossCursor_Panel#Magnifier rgb(YMagHair)=(0,52224,0)	
	endif
	//	
	
	SetAxis	/W=$graphname#CrossCursor_Panel#Magnifier $xaxname,Haxismin,Haxismax
	SetAxis	/W=$graphname#CrossCursor_Panel#Magnifier $yaxname,Vaxismin,Vaxismax
	
	SetDatafolder DF
End
Function CkCrossCursor(ctrlname,value)
	String ctrlname
	variable value
	String wname=winname(0,65)
		
	Update_CrossCursor_panel(wname)
	
end


Function Update_CrossCursor_panel(graphname)
String graphname
	DFREF DF=GetdatafolderdFR()
	DFREF DFR_HCP=$(DF_GP+graphname)
	SetActivesubwindow $graphname
	SetDatafolder DFR_HCP
	NVAR X0,X1,Y0,Y1,Z0,Z1,DX,DY,DZ,CX,CY,CZ
	
	NVAR xyswapflag

	Variable AExists= strlen(CsrInfo(A,graphname)) > 0	
	Variable BExists= strlen(CsrInfo(B,graphname)) > 0

	if ((AExists+BExists)==0)
		SetDatafolder DF
		return 0
	endif
	
	variable dimflag=0
		
	if (AExists)
		String Ainfo=CsrInfo(A)
		Variable p0,q0
		
		String tracenameA=stringbykey("TNAME",Ainfo,":",";")
		Variable freeflag=numberbykey("ISFREE",Ainfo,":",";")
		Wave/Z data=imagenametowaveref(graphname,tracenameA)
		if (Waveexists(data))
			dimflag=2
		else
			Wave/Z data=Tracenametowaveref(graphname,tracenameA)
			if (Waveexists(data))
				Wave/Z Xdata=XWaveRefFromTrace(graphname,tracenameA)
				if (Waveexists(Xdata))
				dimflag=3
				endif
			dimflag=1
			endif
		endif
		
		if (dimflag==0)
			SetDatafolder DF
			return 0
		endif
		
		if (freeflag)
			String tinfo=  TraceInfo(Graphname, tracenameA, 0)
			if (strlen(tinfo)==0)
			tinfo=Imageinfo(Graphname,tracenameA,0)
			endif
	
			String xaxname,yaxname
	
			if( StrLen(tinfo) != 0 )
				xaxname=  StringByKey("XAXIS",tinfo)
				yaxname=  StringByKey("YAXIS",tinfo)
			endif

			Variable x_0,x_1,y_0,y_1
			GetAxis/Q $yaxname; y_0= V_min; y_1= V_max
			GetAxis/Q $xaxname; x_0= V_min; x_1= V_max
		
				X0=x_0+(x_1-x_0)*pcsr(A)
				Y0=y_0+(y_1-y_0)*(1-qcsr(A))

			
		else
			switch(dimflag)
			case 1:
				p0=pcsr(A)
				X0=pnt2x(data,p0)
				Y0=data[p0]
			break
			case 2:
				X0=xcsr(A)
				Y0=vcsr(A)
				Z0=zcsr(A)
			break
			case 3:
				p0=pcsr(A)
				X0=Xdata[p0]
				Y0=data[p0]
			break
			endswitch
		endif
	endif
	
	if (BExists)
		String Binfo=CsrInfo(B)
		Variable p1,q1
		
		String tracenameB=stringbykey("TNAME",Binfo,":",";")
		freeflag=numberbykey("ISFREE",Binfo,":",";")
		Wave/Z data=imagenametowaveref(graphname,tracenameB)
		if (Waveexists(data))
			dimflag=2
		else
			Wave/Z data=Tracenametowaveref(graphname,tracenameB)
			if (Waveexists(data))
				Wave/Z Xdata=XWaveRefFromTrace(graphname,tracenameB)
				if (Waveexists(Xdata))
				dimflag=3
				endif
			dimflag=1
			endif
		endif
		
		if (dimflag==0)
			SetDatafolder DF
			return 0
		endif
		
		
		if (freeflag)
			tinfo=  TraceInfo(Graphname, tracenameB, 0)
			if (strlen(tinfo)==0)
			tinfo=Imageinfo(Graphname,tracenameB,0)
			endif
	
			if( StrLen(tinfo) != 0 )
				xaxname=  StringByKey("XAXIS",tinfo)
				yaxname=  StringByKey("YAXIS",tinfo)
			endif

			GetAxis/Q $yaxname; y_0= V_min; y_1= V_max
			GetAxis/Q $xaxname; x_0= V_min; x_1= V_max
			
			X1=x_0+(x_1-x_0)*pcsr(B)
			Y1=y_0+(y_1-y_0)*(1-qcsr(B))
		else
			switch(dimflag)
			case 1:
				p1=pcsr(B)
				X1=pnt2x(data,p1)
				Y1=data[p1]
			break
			case 2:
				X1=xcsr(B)
				Y1=vcsr(B)
				Z1=zcsr(B)
			break
			case 3:
				p1=pcsr(B)
				X1=Xdata[p1]
				Y1=data[p1]
			break
			endswitch
		endif
	endif
	
	if ((AExists+BExists)==2)
	DX=X1-X0
	DY=Y1-Y0
	DZ=Z1-Z0
	CX=(X1+X0)/2
	CY=(Y1+Y0)/2
	CZ=(Z1+Z0)/2
		if (stringmatch(tracenameA,tracenameB))
		NVAR gv_crossHairflag=DFR_HCP:gv_crossHairflag
		if (gv_crossHairflag)
			Wave HairYCross
			Wave HairXCross
			HairYCross={CY,CY,nan,inf,-inf}
			HairXCross={-inf,inf,nan,CX,CX}
			checkdisplayed /W=$graphname HairYCross
			
			
			if (v_flag==0)
						
			if (dimflag==2)
			tinfo= ImageInfo(graphname, tracenameA, 0)
			else
			tinfo= traceInfo(graphname, tracenameA, 0)
			endif
			
			String axinfo=" "
			if( StrLen(tinfo) != 0 )
				axinfo= StringByKey("AXISFLAGS",tinfo)+" "
			endif

			Execute "AppendToGraph"+axinfo+"HairYCross"+" vs "+"HairXCross"
			Modifygraph rgb(HairYCross)=(65535,0,0),lstyle(HairYCross)=3
			endif
			
			Doupdate /W=$graphname
		else
			removefromgraph /Z HairYCross
		endif
		endif
	endif
	
	
SetDatafolder DF
End




Function GP_OpenMovie()
	open_movie_panel()
End

Function /DF init_createmovie_panel()
	String wname=winname(0,65)

	DFREF DFR_GP=$DF_GP
	SetDatafolder DFR_GP
	
	String /G gs_moviewname=wname

	newDatafolder /o/s $wname
	newDatafolder /o/s	CreateMovie
	
	InitVar("gv_Tinterval",1)
	InitSVar("gs_moviepath","")
	InitVar("gv_stopflag",0)
	
	Initvar("gv_circleflag",0)
	Initvar("gv_circlenum",1)
	Initvar("gv_directionflag",0)
	
	Initvar("gv_circleindex",0)
	Initvar("gv_replaceindex",0)
	Initvar("gv_itemsnum",0)
	
	initSvar("gs_startwavename","")
	
	String /G gs_imagelist=imagenamelist(wname,";")
	String /G gs_tracelist=tracenamelist(wname,";",1)
	Variable /G gv_dimflag
	
	if (strlen(gs_imagelist)==0)
		gv_dimflag=0
	else
		gv_dimflag=1
	endif
	
	Variable /G gv_addtextflag=0
	String /G gs_formatstr=""
	
	Return GetDatafolderdfr()
End

Function open_movie_panel()
	DFREF DF=GetDatafolderDFR()
	DFREF DFR_GP=$DF_GP
		
	SetDatafolder DFR_GP

	String wname=winname(0,65)

	String Cwnamelist=ChildWindowList(wname)
	
	if (Findlistitem("Create_movie",Cwnamelist,";",0)!=-1)
 		KillWindow $wname#Create_movie
 		SetDatafolder DF
 		return 0
	endif
	
	DFREF DFR_movie=init_createmovie_panel()
	if (DataFolderRefsEqual(DFR_GP,DFR_movie))
		SetDatafolder DF
		return 0
	else
		SetDatafolder DFR_movie
	endif
	Variable SC=ScreenSize(5)
	Variable r=57000, g=57000, b=57000
	Variable width=280*SC,Height=370*SC
	
	NewPanel /Host=$wname/EXT=0/K=1/W=(0,0,width,Height)/N=Create_movie as "Create_movie"
	Modifypanel /W=$wname#Create_movie cbRGB=(52428,52428,52428)
	ModifyPanel /W=$wname#Create_movie noEdit=1, fixedSize=1
	SetWindow $wname#Create_movie  hook(MyHook) = MyCreate_movieHook
	
	groupbox movie_gb0, pos={10*SC,5*SC},size={260*SC,80*SC},title="Setting",frame=0
	SetVariable movie_sv1,pos={20*SC,25*SC},size={240*SC,20*SC},title="FilePath:",Limits={1,60,1},variable=DFR_movie:gs_moviepath
	Button movie_bt3,pos={220*SC,45*SC},size={40*SC,20*SC},title="New",proc=Proc_bt_newmovie
	
	SetVariable movie_sv0,pos={20*SC,50*SC},size={140*SC,20*SC},title="FrameperSecond:",Limits={1,60,1},variable=DFR_movie:gv_Tinterval
	
	NVAR gv_dimflag=DFR_movie:gv_dimflag
	NVAR gv_directionflag=DFR_movie:gv_directionflag
	
	groupbox movie_gb3,pos={10*SC,90*SC},size={260*SC,90*SC},title="Flow Control",frame=0
	Checkbox movie_ck2,pos={20*SC,115*SC},size={60*SC,20*SC},title="Trace",proc=proc_ck_moviedimflag,value=gv_dimflag==0
	Checkbox movie_ck3,pos={80*SC,115*SC},size={60*SC,20*SC},title="Image",proc=proc_ck_moviedimflag,value=gv_dimflag==1
	Checkbox movie_ck4,pos={20*SC,135*SC},size={60*SC,20*SC},title="Replace -->",proc=proc_ck_moviedirectionflag,value=gv_directionflag==1
	Checkbox movie_ck5,pos={120*SC,135*SC},size={60*SC,20*SC},title="Replace <--",proc=proc_ck_moviedirectionflag,value=gv_directionflag==2
	Checkbox movie_ck6,pos={20*SC,155*SC},size={60*SC,20*SC},title="Circle",variable=DFR_movie:gv_circleflag
	Setvariable movie_sv3,pos={120*SC,155*SC},size={120*SC,20*SC},title="RepeatNum",variable=DFR_movie:gv_circlenum,limits={1,inf,1}
	//Checkbox movie_ck5,pos={80*SC,115*SC},size={60*SC,20*SC},title="<--",proc=proc_ck_addtext
	
	
	groupbox movie_gb1, pos={10*SC,190*SC},size={260*SC,80*SC},title="Control",frame=0
	Button movie_bt0,pos={20*SC,215*SC},size={40*SC,40*SC},title="Start",proc=Proc_bt_controlmovie
	Button movie_bt1,pos={70*SC,215*SC},size={40*SC,40*SC},title="Pause",proc=Proc_bt_controlmovie
	Button movie_bt2,pos={120*SC,215*SC},size={40*SC,40*SC},title="Stop",proc=Proc_bt_controlmovie
	
	groupbox movie_gb2, pos={10*SC,275*SC},size={260*SC,70*SC},title="Add Info",frame=0
	
	Checkbox movie_ck0,pos={20*SC,295*SC},size={60*SC,20*SC},title="Tem",proc=proc_ck_addtext
	Checkbox movie_ck1,pos={80*SC,295*SC},size={60*SC,20*SC},title="PhE",proc=proc_ck_addtext
	//Checkbox movie_ck2,pos={140*SC,195*SC},size={60*SC,20*SC},title="PhE"
	Button movie_bt4,pos={20*SC,315*SC},size={60*SC,20*SC},title="Add text",proc=Proc_bt_Addtext
	
	SetDatafolder DF
End

Function MyCreate_movieHook(s)
	STRUCT WMWinHookStruct &s
	Variable hookResult = 0
	String wname=winname(0,1)
	switch(s.eventCode)
		case 2:
			finishmovie(wname)
			break
		case 5:
			DFREF DFR_GP=$DF_GP
			SVAR gs_moviewname=DFR_GP:gs_moviewname
			gs_moviewname=wname
			break
	endswitch
	return hookResult
End



Function proc_ck_moviedimflag(ctrlname,value)
	String ctrlname
	Variable value
	String wname=winname(0,65)
	DFREF DFR_movie=$(DF_GP+wname+":CreateMovie")
	
	NVar gv_dimflag=DFR_movie:gv_dimflag
	
	strswitch(ctrlname)
	case "movie_ck2":
		gv_dimflag=0
		break
	case "movie_ck3":
		gv_dimflag=1
		break
	endswitch
	
	Checkbox movie_ck2,win=$wname#Create_movie,value=gv_dimflag==0
	Checkbox movie_ck3,win=$wname#Create_movie,value=gv_dimflag==1
End


Function proc_ck_moviedirectionflag(ctrlname,value)
	String ctrlname
	Variable value
	String wname=winname(0,65)
	DFREF DFR_movie=$(DF_GP+wname+":CreateMovie")
	
	NVar gv_directionflag=DFR_movie:gv_directionflag
	gv_directionflag=0
	
	strswitch(ctrlname)
	case "movie_ck4":
		if (value)
			gv_directionflag=1
		endif
		break
	case "movie_ck5":
		if (value)
			gv_directionflag=2
		endif
		break
	endswitch
	
	Checkbox movie_ck4,win=$wname#Create_movie,value=gv_directionflag==1
	Checkbox movie_ck5,win=$wname#Create_movie,value=gv_directionflag==2
End

Function proc_ck_addtext(ctrlname,value)
	String ctrlname
	Variable value
	String wname=winname(0,65)
	DFREF DFR_movie=$(DF_GP+wname+":CreateMovie")
	
	NVAR gv_addtextflag=DFR_movie:gv_addtextflag
	SVAR gs_formatstr=DFR_movie:gs_formatstr
	
	gv_addtextflag=0
	gs_formatstr=""
	
	Controlinfo /W=$wname#Create_movie movie_ck0
	if (v_value)
		gv_addtextflag+=1
		gs_formatstr+="%.2fK\r"
	endif
	
	Controlinfo /W=$wname#Create_movie movie_ck1
	if (V_value)
		gv_addtextflag+=2
		gs_formatstr+="%.2feV\r"
	endif
	
	gs_formatstr=RemoveEnding(gs_formatstr,"\r")
End

Function update_addtext(wname)
	String wname
	DFREF DFR_movie=$(DF_GP+wname+":CreateMovie")
	
	NVAR gv_dimflag=DFR_movie:gv_dimflag
	
	if (gv_dimflag==1)
		String imagelist=ImageNameList(wname, ";" )
		Variable items=itemsinlist(imagelist,";")
		String imagename=StringFromList(items-1,imagelist,";")
		Wave w_image=ImageNameToWaveRef(wname, imagename )
		String notestr=note(w_image)
	else
		String tracelist=TraceNameList(wname, ";",1)
		items=itemsinlist(Tracelist,";")
		String tracename=Stringfromlist(items-1,tracelist,";")
		Wave w_trace=TraceNameToWaveRef(wname, tracename )
		notestr=note(w_trace)
	endif
	
	Variable tem=NumberByKey("SampleTemperature", notestr, "=","\r")
	Variable phoneE=NumberByKey("PhotonEnergy", notestr, "=","\r")
	
	String textstr

	NVAR gv_addtextflag=DFR_movie:gv_addtextflag
	SVAR gs_formatstr=DFR_movie:gs_formatstr
	
	switch(gv_addtextflag)
		case 0:
			TextBox/W=$wname/K/N=Movieinfo 
			return 0
		case 1:
			sprintf textstr, gs_formatstr,tem
			break
		case 2:
			sprintf textstr, gs_formatstr,phoneE
			break
		case 3:
			sprintf textstr, gs_formatstr,tem,phoneE
			break
	endswitch	
	
	TextBox/W=$wname/C/N=Movieinfo textstr	
End

Function Proc_bt_Addtext(ctrlname)
	String ctrlname
	String wname=winname(0,65)
	
	update_addtext(wname)
End

Function initialmoviepar()
	String wname=winname(0,65)
	DFREF DFR_movie=$(DF_GP+wname+":CreateMovie")
	
	NVAR gv_dimflag=DFR_movie:gv_dimflag
	NVAR gv_circleindex=DFR_movie:gv_circleindex
	NVAR gv_replaceindex=DFR_movie:gv_replaceindex
	NVAR gv_directionflag=DFR_movie:gv_directionflag
	
	//SVAR gs_startwavename=DFR_movie:gs_startwavename
	
	gv_circleindex=0
	gv_replaceindex=0
	
	if (gv_dimflag==0)
		changeTracestyle_TN(wname,"",0)	
			
	endif
		
End

Function finishmovie(wname)
	String wname
	DFREF DFR_movie=$(DF_GP+wname+":CreateMovie")
	
	NVAR gv_dimflag=DFR_movie:gv_dimflag
	SVAR gs_imagelist=DFR_movie:gs_imagelist
	SVAR gs_tracelist=DFR_movie:gs_tracelist
	
	if (gv_dimflag==1)
		
		Variable items=itemsinlist(gs_imagelist,";")
		Variable index=items-1
		do
			String image=Stringfromlist(index,gs_imagelist,";")
			String imagelist=Imagenamelist(wname,";")
			String archimage=Stringfromlist(0,imagelist,";")
			reorderimages /W=$wname $archimage,{$image}
			index-=1
		while (index>=0)
	else
		items=itemsinlist(gs_tracelist,";")
		index=items-1
		do
			String trace=Stringfromlist(index,gs_tracelist,";")
			String tracelist=Tracenamelist(wname,";",1)
			String archtrace=Stringfromlist(0,tracelist,";")
			reordertraces /W=$wname $archtrace,{$trace}
			index-=1
		while (index>=0)
		
		changeTracestyle_TN(wname,"",1)	
	endif	
End

Function Proc_bt_controlmovie(ctrlname)
	String ctrlname
	String wname=winname(0,65)
	DFREF DFR_movie=$(DF_GP+wname+":CreateMovie")
	
	SVAR gs_moviepath=DFR_movie:gs_moviepath
	NVAR gv_Tinterval=DFR_movie:gv_Tinterval
	NVAR gV_stopflag=DFR_movie:gv_stopflag
	
	strswitch(ctrlname)
		case "movie_bt0":
			NewMovie /Z/F=(gv_Tinterval)/O /I as gs_moviepath
			
			if (v_flag!=0)
				return 0
			endif
			
			Initialmoviepar()
			print "Start Recording"
			StartRecordingTask()
			break
		case "movie_bt1":
			StopRecordingTask()
			break
		case "movie_bt2":
			 finishmovie(wname)
			 gV_stopflag=0
			 StopRecordingTask()
			 CloseMovie
			 print "Stop Recording"
			
			break
	endswitch
End
Function Proc_bt_newmovie(ctrlname)
	string ctrlname
	Variable refnum
	Open /D refnum
	
	if (Strlen(S_fileName)==0)
		return 0
	endif
	
	String wname=winname(0,65)
	DFREF DFR_movie=$(DF_GP+wname+":CreateMovie")
	
	SVAR gs_moviepath=DFR_movie:gs_moviepath
	gs_moviepath=S_fileName
end

Function TestTask(s)		// This is the function that will be called periodically
	STRUCT WMBackgroundStruct &s
	
	Printf "Task %s called, ticks=%d\r", s.name, s.curRunTicks
	return 0	// Continue background task
End

Function StartRecordingTask()
	String wname=winname(0,65)
	DFREF DFR_movie=$(DF_GP+wname+":CreateMovie")
	
	SVAR gs_moviepath=DFR_movie:gs_moviepath
	NVAR gv_Tinterval=DFR_movie:gv_Tinterval
	NVAR gV_stopflag=DFR_movie:gv_stopflag
	
	gv_stopflag=0
	Variable numTicks = 60/gv_Tinterval	// Run every two seconds (120 ticks)
	CtrlNamedBackground Recording, period=numTicks, proc=RecordingBkg
	CtrlNamedBackground Recording, start
End

Function StopRecordingTask()
	String wname=winname(0,65)
	DFREF DFR_movie=$(DF_GP+wname+":CreateMovie")
	NVAR gV_stopflag=DFR_movie:gv_stopflag
	
	if (gv_stopflag)
		CtrlNamedBackground Recording, start
		print "Start Recording"
	else
		CtrlNamedBackground Recording, stop
		gV_stopflag=1
		print "Pause Recording"
	endif
	
End

function RecordingBkg(s)
	STRUCT WMBackgroundStruct &s
	
	DFREF DFR_GP=$DF_GP
	SVAR wname=DFR_GP:gs_moviewname
	
	DFREF DFR_movie=$(DF_GP+wname+":CreateMovie")
	NVAR gv_dimflag=DFR_movie:gv_dimflag
	NVAR gv_circleflag=DFR_movie:gv_circleflag
	NVAR gv_circleindex=DFR_movie:gv_circleindex
	NVAR gv_circlenum=DFR_movie:gv_circlenum
	NVAR gv_replaceindex=DFR_movie:gv_replaceindex
	NVAR gv_directionflag=DFR_movie:gv_directionflag
	
	if (gv_directionflag>0)
		if (gv_dimflag==1)
		
			String imagelist=imagenamelist(wname,";")
			Variable items=itemsinlist(imagelist,";")
		
		
			if (gv_replaceindex>=items)
				if (gv_circleflag)
					gv_replaceindex=1
					if (gv_directionflag==1)
						gv_directionflag=2
					else
						gv_directionflag=1
					endif
				else
					gv_replaceindex=0
				endif
				gv_circleindex+=1
			endif
		
		
			if (gv_circleindex>=gv_circlenum)
				Proc_bt_controlmovie("movie_bt2")
				return 0
			endif
			
			String image1=Stringfromlist(0,imagelist,";")
			String image2=Stringfromlist(items-1,imagelist,";")
			String image3=Stringfromlist(items-2,imagelist,";")
			
			if (gv_directionflag==1)
				if (gv_replaceindex>0)
					reorderimages /W=$wname $image1,{$image2}
					gv_replaceindex+=1
				else
					gv_replaceindex+=1
				endif
			else
				if (gv_replaceindex>0)
					reorderimages /W=$wname $image2,{$image2,$image1}
					gv_replaceindex+=1
				else
					reorderimages /W=$wname $image2,{$image2,$image1}
					gv_replaceindex+=1
				endif
			endif
		else
		
			String tracelist=tracenamelist(wname,";",1)
			items=itemsinlist(tracelist,";")
			
			if (gv_replaceindex>=items)
				if (gv_circleflag)
					gv_replaceindex=0
					if (gv_directionflag==1)
						gv_directionflag=2
					else
						gv_directionflag=1
					endif
				else
					gv_replaceindex=0
				endif
				gv_circleindex+=1
				changeTracestyle_TN(wname,"",0)	
			endif
	
			if (gv_circleindex>=gv_circlenum)
				Proc_bt_controlmovie("movie_bt2")
				return 0
			endif
			
			String trace1=returntracename(stringfromlist(0,tracelist,";"))
			String trace2=returntracename(stringfromlist(items-1,tracelist,";"))
			
			if (gv_directionflag==1)
				if (gv_replaceindex>0)
					gv_replaceindex+=reorderTrace_TN(wname,trace2,1)
				else	
					if ((gv_circleflag==0)&&(gv_circleindex>0))
						gv_replaceindex+=reorderTrace_TN(wname,trace2,1)
					else	
						gv_replaceindex+=reorderTrace_TN(wname,trace2,2)
					endif
				
				endif		
			else
				if (gv_replaceindex>0)
					gv_replaceindex+=reorderTrace_TN(wname,trace1,2)
				else
					if ((gv_circleflag==0)||(gv_circleindex==0))
						gv_replaceindex+=reorderTrace_TN(wname,trace1,2)
					else
						gv_replaceindex+=reorderTrace_TN(wname,trace2,2)
					endif
				endif
				
			endif
			
			tracelist=tracenamelist(wname,";",1)
			trace2=returntracename(stringfromlist(items-1,tracelist,";"))
			changeTracestyle_TN(wname,trace2,1)	
	
		endif
	endif
	
	
	Dowindow /F $wname
	doupdate;
	AddMovieFrame
	//print "Recording"
	return 0
End


Function changeTracestyle_TN(wname,Tname,flag)
	String wname
	String Tname
	Variable flag
	
	if (strlen(Tname)==0)
		Modifygraph lsize=flag
		return 0
	endif
	
	String tracelist=Tracenamelist(wname,";",1)
	Variable items=itemsinlist(tracelist,";")
	
	 Variable traceindex=0
	do
	 	String Tracename=stringfromlist(traceindex,tracelist,";")
		String TN=returntracename(Tracename)			
		if (stringmatch(TN,Tname))
			Modifygraph lsize($Tracename)=flag
		endif
			
		 traceindex+=1
	while (traceindex<items)
	
End	

Function reorderTrace_TN(wname,Tname,flag)
	String wname
	String Tname
	Variable flag
	
	String tracelist=Tracenamelist(wname,";",1)
	Variable items=itemsinlist(tracelist,";")
	
	Variable replacecount=0
	
	if (flag==1)
		Variable traceindex=items-1
		do
			String Tracename=stringfromlist(traceindex,tracelist,";")
			String TN=returntracename(Tracename)
		
			if (stringmatch(TN,Tname))
				String temptracelist=Tracenamelist(wname,";",1)
				String tempTracename=stringfromlist(0,temptracelist,";")
				reordertraces /W=$wname $tempTracename,{$Tracename}
				replacecount+=1
			endif

			traceindex-=1
		while (traceindex>=0)
	else
		 traceindex=0
		 do
		 	Tracename=stringfromlist(traceindex,tracelist,";")
			TN=returntracename(Tracename)
			
			if (stringmatch(TN,Tname))
				temptracelist=Tracenamelist(wname,";",1)
				tempTracename=stringfromlist(items-1,temptracelist,";")
				if (stringmatch(tempTracename,Tracename)==0)
					reordertraces /W=$wname $tempTracename,{$tempTracename,$Tracename}
				endif
				replacecount+=1
			endif
			
		 	traceindex+=1
		while (traceindex<items)
	endif
	return replacecount
End

Function /S returntracename(tracename)
	String tracename
	Variable temp
	
	temp=strsearch(tracename,"_e_",0)
	if (temp==-1)
		temp=strsearch(tracename,"_m_",temp+1)
		if (temp==-1)
			return tracename
		else
			return tracename[0,temp-1]
		endif
	else
		return tracename[0,temp-1]
	endif
	
End


//Folloing fuctions were recycle from Datatable_panel.ipf 12/23/2022

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

Function SetVariables(startRow,endRow,Col)
	Variable StartRow,endrow
	Wave col
	Variable i,delta=col[startrow+1]-col[startrow] 
	for (i=startRow+2;i<(endRow+1);i+=1)
 		col[i]=col[i-1]+delta
	endfor
End










