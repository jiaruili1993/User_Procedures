#pragma rtGlobals=1		// Use modern global access method.
#pragma Version=0.01	

/////////////FOR F9 FUNCTIONS ////////////////////////////////

Function MyImageProcessHook(s)
	STRUCT WMWinHookStruct &s
	Variable hookResult = 0
	String wname=s.winName
	switch(s.eventCode)
		case 2:
			String new_wname=winname(0,1)
			//DeleteBasednamegraph(new_wname,"HairY*",0)
			DFREF DF=GetDatafolderDFR()
			DFREF DFR_imgpro=$(DF_GP+new_wname+":ImageProcess:")
			//SVAR gs_Imageinfo=DFR_imgpro:gs_Imageinfo
			//SVAR gs_topimage=DFR_imgpro:gs_topimage
			//gs_imageinfo=Imageinfo(new_wname,gs_topimage,0)
			//KillDatafolder /Z $DF
			
			proc_update_image(4,0)
			
			SetDatafolder DFR_imgpro
			String colorwavelist=WaveList("Color_lookup*", ";", "")
			variable index
			do
				Wave /Z colorwave=$StringFromList(index,colorwavelist,";")
				Setformula colorwave,""
				index+=1
			while (index<itemsinlist(colorwavelist,";"))
			
			SetDatafolder DF
			break
	endswitch
	return hookResult
End


Function GP_ImageProcess()
	String wname=winname(0,1)
	if (strlen(wname)==0)
		return 1
	endif
	Dowindow /F $wname
	//if (strsearch(wname,"panel",0)==-1)
	open_Imageproc_panel()
	//endif
End



Function /DF init_imageproc_panel()
	DFREF DF=GetDatafolderDFR()

	String wname=winname(0,1)
	DFREF DFR_GP=$DF_GP
	SetDatafolder DFR_GP

	String imglist=ImageNameList(wname,";")
	
	if (strlen(imglist)==0)
		Doalert 0,"There is no Image on the graph!"
		DFREF DFR_imgpro=$(DF_GP)
		return DFR_imgpro
	endif

	Variable initialflag=1
	
	if (initialflag)
		newDatafolder /o/s $wname
		newDatafolder /o/s	ImageProcess
		DFREF DFR_imgpro=GetDatafolderDFR()
		
		String /G gs_IMGname=winname(0,1)
		String topimage=Stringfromlist(0,imglist,";")
		String /G gs_topimage=topimage
		Wave tempimage=ImageNameToWaveRef(wname,topimage)
		duplicate /o tempimage w_image_backup
		//appendimage /W=$wname w_image_showup
		String /G gs_topimagePath=GetWavesDatafolder(tempimage,2)
		
		String/G gs_imagelist=imglist
		Variable /G gv_imagenum=itemsinlist(imglist,";")
		
		SListToWave(imglist,0,";",Nan,Nan)
		Wave /T w_StringList
		Duplicate /o w_StringList w_ImageList
		Killwaves /Z w_StringList
		if (gv_imagenum>1)
			String/G gs_imageselList=imglist+"All_image;"
		else
			String/G gs_imageselList=imglist
		endif
	
		Variable /G gv_allimageflag=0
		
		
		Variable/G d_low = 0
		Variable/G d_high = 1
		Variable/G g_low = 0
		Variable/G g_high = 1
		Variable/G sv0=1
		Variable/G sv1=1
		
		Variable /G ctabreverseflag
		
		Variable/G gv_Contrastmode = 1
		String /G gs_Contrastname="Linear"
		Variable/G gv_ColorTabnum=0
		Variable/G gv_Image_Vmax
		Variable/G gv_Image_Vmin
		Wavestats /Q  tempimage
		gv_Image_Vmax=V_max
		gv_Image_Vmin=V_min
		Variable/G gv_leftx=V_min	
		Variable/G gv_rightx=V_max
		Variable/G gv_slider_min
		Variable/G gv_slider_max
		
		Variable /G gv_relativerangeflag=1
		
		gv_slider_min=(gv_Image_Vmin-(gv_Image_Vmax+gv_Image_Vmin)/2)*1.5+(gv_Image_Vmax+gv_Image_Vmin)/2
		gv_slider_max=(gv_Image_Vmax-(gv_Image_Vmax+gv_Image_Vmin)/2)*3+(gv_Image_Vmax+gv_Image_Vmin)/2
		
		string colorleft,colorright
		String tempstr
		String /G gs_Imageinfo=Imageinfo(wname,gs_topimage,0)
		Variable temp=strsearch(gs_Imageinfo,"ctab=",0)
		Variable temp1=strsearch(gs_imageinfo,"}",temp)
		String Cbstr=nospace(gs_Imageinfo[temp,temp1])
	
		temp=strsearch(Cbstr,"{",0)
		temp1=strsearch(Cbstr,",",temp)
		temp=temp1+1
		temp1=strsearch(Cbstr,",",temp)
		tempstr=cbstr[temp,temp1-1]
		temp=temp1+1
		temp1=strsearch(Cbstr,",",temp)
		tempstr=cbstr[temp,temp1-1]
		String ctblist=CTabList()
		gv_ColorTabnum=WhichListItem(tempstr, ctblist,";",0)+1
	
		temp=temp1+1
		temp1=inf
		tempstr=cbstr[temp,temp1]
		sscanf tempstr,"%g",ctabreverseflag

		make /o/n=100 hist
		Setscale /I x,V_min,V_max,hist
		Histogram/B=2 tempimage,hist

		Make /o/n=2,LeftHist,RightHist,XleftHist,XrightHist
		LeftHist={-inf,inf}
		RightHist={-inf,inf}
		XleftHist=gv_leftx
		XrightHist=gv_rightx
		
		Setformula XleftHist,"gv_leftx"
		Setformula XrightHist,"gv_rightx"//,"gv_rightx"

		Make /o/n=3 userY,userX
		userX={0,0.5,1}
		userY={0,0.5,1}

		Make /o/n=1000 Color_lookup
		Setscale /I x,0,1,Color_lookup
		Color_lookup = set_w_look_panel(x,d_low,d_high,g_low,g_high,sv0,sv1,gv_Contrastmode)
		Setformula Color_lookup, "set_w_look_panel(x,d_low,d_high,g_low,g_high,sv0,sv1,gv_Contrastmode)"
	
		
		//ModifyImage /W=$wname  $gs_topimage,lookup= Color_lookup
		//gs_Imageinfo=Imageinfo(wname,gs_topimage,0)
	else
		SetDatafolder $wname
		SetDatafolder ImageProcess
		DFREF DFR_imgpro=GetDatafolderDFR()
	endif
	
	SetDatafolder DF
	return DFR_imgpro
End

Function open_Imageproc_panel()
	DFREF DF=GetDatafolderDFR()
	DFREF DFR_GP=$DF_GP
		
	SetDatafolder DFR_GP

	String wname=winname(0,1)

	String Cwnamelist=ChildWindowList(wname)
 	
	if (Findlistitem("Image_Process",Cwnamelist,";",0)!=-1)
 		KillWindow $wname#Image_Process
 		SetDatafolder DF
 		return 0
	endif
	
 	DFREF DFR_imgpro=init_imageproc_panel()
	if (DataFolderRefsEqual(DFR_GP,DFR_imgpro))
		SetDatafolder DF
		return 0
	else
		SetDatafolder DFR_imgpro
	endif

	String DFS_imgpro=GetDatafolder(1)
	SVAR Img_name= DFR_imgPro:gs_IMGname
	SVAR Topimg_name=DFR_imgpro:gs_topimage
	SVAR gs_Imagelist=DFR_imgpro:gs_Imagelist
	NVAR gv_ColorTabnum
	NVAR gv_Contrastmode
	
	Variable SC=ScreenSize(5)
	Variable r=57000, g=57000, b=57000
	Variable width=430*SC,Height=553*SC

	NewPanel /Host=$wname/EXT=0/K=1/W=(0,0,width,Height)/N=Image_Process as "Image_Process"
	Modifypanel /W=$wname#Image_Process cbRGB=(52428,52428,52428)
	ModifyPanel /W=$wname#Image_Process noEdit=1, fixedSize=1
	SetWindow $wname#Image_Process hook(MyHook) = MyImageProcessHook
	
	groupbox Image_contrast, labelBack=(r,g,b),pos={10*SC,10*SC},size={240*SC,280*SC},title="Image Contrast"
	Wave Color_lookup
	Display/W=(20*SC,90*SC,240*SC,280*SC)/HOST=$wname#Image_Process/N=Lookupdisp Color_lookup
	ModifyGraph /W=$wname#Image_Process#Lookupdisp grid=1
	PopupMenu ContFctn,pos={20*SC,30*SC},size={152*SC,24*SC},proc=PMContFctnPopMenuProc,title="Function:"
	PopupMenu ContFctn,mode=gv_Contrastmode,value= #"\"Linear;Invert;Gamma;Logarithmic;Exponential;Uniform;Posterize;Ramps;Colorized;User Drawn\""
	//Controlinfo /W=$wname#Image_Process ContFcTn
	//PMContFctnPopMenuProc("ContFctn",gv_Contrastmode,S_Value) 

	titlebox GraphnameT,pos={260*SC,10*SC},size={80*SC,20*SC},title="Graph Name:",frame=0
	titlebox Graphname,pos={330*SC,10*SC},size={80*SC,20*SC},variable= DFR_imgPro:gs_IMGname,frame=0
	titlebox imagenameT,pos={260*SC,30*SC},size={80*SC,20*SC},title="Image Name:",frame=0
	titlebox imagename,pos={330*SC,30*SC},size={80*SC,20*SC},variable=DFR_imgpro:gs_topimage,frame=0

	Listbox imagelist,pos={260*SC,130*SC},size={100*SC,120*SC},mode=2, title="Image List:",listwave=DFR_imgpro:w_Imagelist,proc=proc_listbox_Imagelist
	
	Checkbox imageall,pos={260*SC,260*SC},size={100*SC,20*SC},title="All image",proc=proc_ck_imagelist

	//popupMenu imagelist,pos={260*SC,130*SC},size={100*SC,20*SC},mode=1,title="Image List:",value=#(DFS_imgpro+"gs_imageselList"),proc=Proc_popup_Imagelist

	titlebox tb0,pos={260*SC,55*SC},size={80*SC,20*SC},title="Color Table:",frame=0
	PopupMenu DCs_p1,pos={295*SC,70*SC},bodyWidth=150*SC,size={113*SC,18*SC},title="",value="*COLORTABLEPOPNONAMES*", mode=gv_ColorTabnum+1
	popupMenu DCs_p1,proc=Proc_colortab_PopMenuProc
	
	Checkbox Reverseck,pos={260*SC,95*SC},size={80*SC,20*SC},title="Revserse",variable=ctabreverseflag,proc=Proc_ck_ctabreversechange

	//groupbox Image_hist0, labelBack=(r,g,b),pos={255*SC,215*SC},size={170*SC,75*SC},title="Hist Adjust"
	//Button UpdateSvar,pos={265*SC,235*SC},size={70*SC,20*SC},title="Update Hist",proc=Proc_bt_update_imgpvar
	//Button InitSvar,pos={345*SC,235*SC},size={70*SC,20*SC},title="Initial",proc=Proc_bt_Initial_imgpvar
	//Button Image_histbt0,pos={265*SC,260*SC},size={70*SC,20*SC},title="Equalize",proc=Proc_bt_Equhist
	//Button Image_histbt1,pos={345*SC,260*SC},size={70*SC,20*SC},title="Undo",proc=Proc_bt_undohist


	groupbox Image_hist, labelBack=(r,g,b),pos={10*SC,300*SC},size={400*SC,240*SC},title="Image Hist"
	Wave hist
	Wave LeftHist
	Wave RightHist
	Wave XleftHist
	Wave XRightHist
	NVAR gv_leftx
	NVAR gv_rightx
	NVAR gv_slider_min
	NVAR gv_slider_max
	
	Display/W=(20*SC,320*SC,395*SC,495*SC)/HOST=$wname#Image_Process/N=histdisp hist
	ModifyGraph  /W=$wname#Image_Process#histdisp mode(hist)=1
	ModifyGraph /W=$wname#Image_Process#histdisp  rgb(hist)=(0,0,0)
	appendtograph /W=$wname#Image_Process#histdisp LeftHist vs XleftHist
	appendtograph /W=$wname#Image_Process#histdisp rightHist vs XrightHist
	//ModifyGraph/W=Image_Process#histdisp quickdrag(rightHist)=1,live(rightHist)=1
	//ModifyGraph/W=Image_Process#histdisp quickdrag(leftHist)=1,live(leftHist)=1
	ModifyGraph /W=$wname#Image_Process#histdisp lsize(LeftHist)=2,rgb(LeftHist)=(0,0,52224)
	ModifyGraph /W=$wname#Image_Process#histdisp lsize(RightHist)=2,rgb(RightHist)=(0,65280,0)
	SetVariable Xleft,pos={20*SC,500*SC},size={80*SC,20*SC},limits={-inf,inf,0},value=gv_leftx,title="Left",proc=Proc_IMGrange_SVchange
	SetVariable Xright,pos={20*SC,520*SC},size={80*SC,20*SC},limits={-inf,inf,0},value=gv_rightx,title="Right",proc=Proc_IMGrange_SVchange
	Slider leftslider,pos={110*SC,505*SC},size={180*SC,13*SC},limits={gv_slider_min,gv_slider_max,0},variable=gv_leftx,side= 0,vert= 0,proc=Proc_IMGrange_change
	Slider rightslider,pos={110*SC,525*SC},size={180*SC,13*SC},limits={gv_slider_min,gv_slider_max,0},variable=gv_rightx,side= 0,vert= 0,proc=Proc_IMGrange_change
	Button DefaultHist,pos={300*SC,500*SC},size={50*SC,20*SC},title="Default",proc=proc_bt_histchange
	Button AutoHist,pos={300*SC,520*SC},size={50*SC,20*SC},title="Auto",proc=proc_bt_histchange
	Button ExpandHist,pos={355*SC,500*SC},size={50*SC,20*SC},title="Expand",proc=proc_bt_histchange
	Button shrinkHist,pos={355*SC,520*SC},size={50*SC,20*SC},title="Shrink",proc=proc_bt_histchange
	Checkbox Rangeck,pos={310*SC,298*SC},size={80*SC,20*SC},title="Relative Range",variable=gv_relativerangeflag,proc=Proc_ck_relativerange

	Proc_update_imgpvar(Topimg_name)
	

	SetDatafolder DF
End

Function proc_ck_imagelist(ctrlname,value)
	String ctrlname
	Variable value
	
	String wname=winname(0,1)
	DFREF DF=GetDatafolderDFR()
	DFREF DFR_imgpro=$(DF_GP+wname+":ImageProcess:")
	NVAR gv_allimageflag=DFR_imgpro:gv_allimageflag
	
	controlinfo /W=$wname#Image_Process imagelist
	
	proc_listbox_Imagelist("dummy",V_Value,value,4)
	
End

Function proc_listbox_Imagelist(ctrlName,row,col,event) : ListboxControl
	String ctrlName     // name of this control
	Variable row        // row if click in interior, -1 if click in title
	Variable col        // column number
	Variable event      // event code
	
	String wname=winname(0,1)
	DFREF DF=GetDatafolderDFR()
	DFREF DFR_imgpro=$(DF_GP+wname+":ImageProcess:")
	SVAR topGraph=DFR_imgpro:gs_topimage
	SVAR topGraphpath=DFR_imgpro:gs_topimagePath
	Wave /T w_imagelist=DFR_imgpro:w_imagelist
	NVAR gv_allimageflag=DFR_imgpro:gv_allimageflag
	
	if (Stringmatch(ctrlname,"dummy"))
		proc_update_image(4,0)
		gv_allimageflag=col
	else
		if (event==4)
			if (gv_allimageflag==0)
				proc_update_image(4,0)
			endif
		endif
	endif
	
	if (event==4)
		topgraph=w_imagelist[row]
	
		Wave Image=ImageNameToWaveRef(wname, topgraph)
		topgraphpath=GetWavesDataFolder(image,2)
	
		Proc_update_imgpvar(topgraph)
	endif
	
	SetDatafolder DF
End




Function proc_update_image(flag,controlflag)
	Variable flag
	Variable controlflag
	String wname=winname(0,1)
	DFREF DF=GetDatafolderDFR()
	DFREF DFR_imgpro=$(DF_GP+wname+":ImageProcess:")
	
	NVAR gv_allimageflag=DFR_imgpro:gv_allimageflag
	SVAR gs_Imagelist=DFR_imgpro:gs_Imagelist
	NVAR gv_imagenum=DFR_imgpro:gv_imagenum
	
	NVAR gv_relativerangeflag=DFR_imgpro:gv_relativerangeflag
	
	if (gv_allimageflag)
		
		Variable index
		do
			String tempname=Stringfromlist(index,gs_Imagelist,";")
			if (gv_relativerangeflag) ///update image max and min
				NVAR gv_image_Vmax=DFR_imgpro:gv_image_Vmax
				NVAR gV_image_vmin=DFR_imgpro:gv_image_Vmin
				
				Wave w_image=ImageNameToWaveRef(wname, tempname )
				Wavestats /Q w_image
				gv_Image_Vmax=V_max
				gv_Image_Vmin=V_min
			endif
			switch (flag)
				case 0: //change lookup
					Proc_update_lookup(tempname)
					break
				case 1://change colortab
					Proc_update_colortab(tempname)
					break
				case 2:// change min max
					Proc_update_Imagehist(tempname,controlflag)
					break
				case 3://change reverse
					Proc_update_reverse(tempname)
					break
				case 4:// lock lookup
					 Proc_Lock_lookup(tempname)
					break
			endswitch
			
			index+=1
		while (index<gv_imagenum)
	else
		SVAR topGraph=DFR_imgpro:gs_topimage
		switch (flag)
				case 0: //change lookup
					Proc_update_lookup(topGraph)
					break
				case 1://change colortab
					Proc_update_colortab(topGraph)
					break
				case 2:// change min max
					Proc_update_Imagehist(topGraph,controlflag)
					break
				case 3://change reverse
					Proc_update_reverse(topGraph)
					break
				case 4:// lock lookup
					Proc_Lock_lookup(topGraph)
					break
		endswitch
	endif	
	
	proc_update_imginfo()
End

Function Proc_Lock_lookup(topimagename)
	String topimagename
	DFREF DF=GetDatafolderDFR()
	String wname=winname(0,1)
	DFREF DFR_imgpro=$(DF_GP+wname+":ImageProcess:")
	
	SetDatafolder DFR_imgpro
	SVAR gs_Imagelist=DFR_imgpro:gs_Imagelist
	
	Wave Color_lookup=DFR_imgpro:Color_lookup
	Variable colorindex=WhichListItem(topimagename,gs_Imagelist,";",0)
	String colorname="Color_lookup"+num2str(colorindex)
	duplicate /o Color_lookup $colorname
	Setformula $colorname,""
	ModifyImage /W=$wname  $topimagename,lookup= $colorname
	
	NVAR sv0=DFR_imgpro:sv0
	NVAR sv1=DFR_imgpro:sv1
	
	NVAR gv_Contrastmode=DFR_imgpro:gv_Contrastmode
	SVAR gs_Contrastname=DFR_imgpro:gs_Contrastname
	String notestr="Contrastmode=\r"
	notestr="Contrastname=\r"
	notestr+="sv0=\r"
	notestr+="sv1=\r"
	
	notestr=ReplaceStringByKey("Contrastname", notestr, gs_Contrastname  , "="  , "\r" )
	notestr=Replacenumberbykey("sv0",notestr,sv0,"=","\r")
	notestr=Replacenumberbykey("sv1",notestr,sv1,"=","\r")
	notestr=Replacenumberbykey("Contrastmode",notestr,gv_Contrastmode,"=","\r")
	
	note /K $colorname
	note $colorname,notestr
	
	
	SetDAtafolder DF
End

Function Proc_update_lookup(topimagename)
	String topimagename
	DFREF DF=GetDatafolderDFR()
	String wname=winname(0,1)
	DFREF DFR_imgpro=$(DF_GP+wname+":ImageProcess:")
	
	SetDatafolder DFR_imgpro
	SVAR gs_Imagelist=DFR_imgpro:gs_Imagelist
	
	Wave Color_lookup=DFR_imgpro:Color_lookup
	Variable colorindex=WhichListItem(topimagename,gs_Imagelist,";",0)
	String colorname="Color_lookup"+num2str(colorindex)
	duplicate /o Color_lookup $colorname
	Setformula $colorname,"Color_lookup"
	ModifyImage /W=$wname  $topimagename,lookup= $colorname
	
	SetDAtafolder DF
End

Function Proc_update_reverse(topimage)
	String topimage
	DFREF DF=GetDatafolderDFR()
	String wname=winname(0,1)
	DFREF DFR_imgpro=$(DF_GP+wname+":ImageProcess:")
	
	NVAR ctabreverseflag=DFR_imgpro:ctabreverseflag
	
	update_image_color(wname,topimage,0,0,"",ctabreverseflag,4)
	
End

Function Proc_update_colortab(topimage)
	String topimage
	DFREF DF=GetDatafolderDFR()
	String wname=winname(0,1)
	DFREF DFR_imgpro=$(DF_GP+wname+":ImageProcess:")
	
	NVAR gv_ColorTabnum=DFR_imgpro:gv_ColorTabnum
	
	String ctabstr=Stringfromlist(gv_ColorTabnum,CTabList(),";")
	
	update_image_color(wname,topimage,0,0,ctabstr,0,3)

End

Function Proc_update_Imagehist(topimage, controlflag)
	String topimage
	Variable controlflag
	DFREF DF=GetDatafolderDFR()
	String wname=winname(0,1)
	DFREF DFR_imgpro=$(DF_GP+wname+":ImageProcess:")
		
		
	NVAR gv_leftx=DFR_imgpro:gv_leftx
	NVAR gv_rightx=DFR_imgpro:gv_rightx
	NVAR gv_Image_Vmax=DFR_imgpro:gv_Image_Vmax
	NVAR gv_Image_Vmin=DFR_imgpro:gv_Image_Vmin
	
	NVAR gv_relativerangeflag=DFR_imgpro:gv_relativerangeflag
	
	
	if (gv_relativerangeflag==1)
		variable leftrange=gv_leftx*(gv_Image_Vmax-gv_Image_Vmin)+gv_Image_Vmin
		variable rightrange=gv_rightx*(gv_Image_Vmax-gv_Image_Vmin)+gv_Image_Vmin
		
		if (controlflag==0)
			update_image_color(wname,topimage,leftrange,rightrange,"",0,0)
		elseif (controlflag==1)
			update_image_color(wname,topimage,leftrange,rightrange,"",0,5)
		endif
	else
		if (controlflag==0)
			update_image_color(wname,topimage,gv_leftx,gv_rightx,"",0,0)
		elseif (controlflag==1)
			update_image_color(wname,topimage,gv_leftx,gv_rightx,"",0,5)
		endif
	endif
End	


Function update_image_color(topgraph,topimage,leftvalue,rightvalue,ctabstring,reverseflag,controlflag)
	String topgraph,topimage
	Variable leftvalue,rightvalue
	String ctabstring
	Variable reverseflag
	Variable controlflag
	
	Variable ColorTableft,ColorTabright,ColorTabreverse

	Variable colortabflag
	
	String SImageinfo=Imageinfo(topgraph,topimage,0)
	Variable temp=strsearch(SImageinfo,"ctab=",0)
	Variable temp1=strsearch(Simageinfo,"}",temp)
	String Cbstr=nospace(SImageinfo[temp,temp1])
	String tempstr
	temp=strsearch(Cbstr,"{",0)
	temp1=strsearch(Cbstr,",",temp)
	tempstr=cbstr[temp+1,temp1-1]
	if (grepstring(tempstr,"\*"))
		Colortabflag+=1
	else
		sscanf tempstr,"%g",ColorTableft
	endif
	temp=temp1+1
	temp1=strsearch(Cbstr,",",temp)
	tempstr=cbstr[temp,temp1-1]
	if (grepstring(tempstr,"\*"))
		Colortabflag+=2
	else
	 	sscanf tempstr,"%g",ColorTabright
	endif
	temp=temp1+1
	temp1=strsearch(Cbstr,",",temp)
	tempstr=cbstr[temp,temp1-1]
	String ctblist=tempstr//CTabList()
	//gv_ColorTabnum=WhichListItem(tempstr, ctblist,";",0)+1
	temp=temp1+1
	temp1=inf
	tempstr=cbstr[temp,temp1]
	sscanf tempstr,"%g",ColorTabreverse
	
	//print "*"+ctblist+"*"
	if (controlflag==0) //change auto
		ModifyImage /W=$topgraph $topimage ctab={*,*,$ctblist,ColorTabreverse}
	elseif (controlflag==1) //change left
		if ((Colortabflag==1)||(colortabflag==3))
			ModifyImage /W=$topgraph $topimage ctab={leftvalue,*,$ctblist,ColorTabreverse}
		elseif ((colortabflag==0)||(colortabflag==2))
			ModifyImage /W=$topgraph $topimage ctab={leftvalue,ColorTabright,$ctblist,ColorTabreverse}
		endif
	elseif (controlflag==2) //change right
		if ((Colortabflag==2)||(colortabflag==3))
			ModifyImage /W=$topgraph $topimage ctab={*,rightvalue,$ctblist,ColorTabreverse}
		elseif ((colortabflag==0)||(colortabflag==1))
			ModifyImage /W=$topgraph $topimage ctab={ColorTableft,rightvalue,$ctblist,ColorTabreverse}
		endif
	elseif (controlflag==3)// change ctab
		if (Colortabflag==0)
			ModifyImage /W=$topgraph $topimage ctab={ColorTableft,ColorTabright,$ctabstring,ColorTabreverse}
		elseif (colortabflag==1)
			ModifyImage /W=$topgraph $topimage ctab={ColorTableft,*,$ctabstring,ColorTabreverse}
		elseif (Colortabflag==2)
			ModifyImage /W=$topgraph $topimage ctab={*,ColorTabright,$ctabstring,ColorTabreverse}
		elseif (colorTabflag==3)
			ModifyImage /W=$topgraph $topimage ctab={*,*,$ctabstring,ColorTabreverse}
		endif	
	elseif (controlflag==4) //change revserse
		if (Colortabflag==0)
			ModifyImage /W=$topgraph $topimage ctab={ColorTableft,ColorTabright,$ctblist,reverseflag}
		elseif (colortabflag==1)
			ModifyImage /W=$topgraph $topimage ctab={ColorTableft,*,$ctblist,reverseflag}
		elseif (Colortabflag==2)
			ModifyImage /W=$topgraph $topimage ctab={*,ColorTabright,$ctblist,reverseflag}
		elseif (colorTabflag==3)
			ModifyImage /W=$topgraph $topimage ctab={*,*,$ctblist,reverseflag}
		endif
	elseif (controlflag==5) ///changeboth
		ModifyImage /W=$topgraph $topimage ctab={leftvalue,rightvalue,$ctblist,ColorTabreverse}
	endif
	
End


Function proc_update_imginfo()
	String wname=winname(0,1)
	DFREF DFR_imgpro=$(DF_GP+wname+":ImageProcess:")
	SVAR gs_Imageinfo=DFR_imgpro:gs_Imageinfo
	
	NVAR gv_imagenum=DFR_imgpro:gv_imagenum
	SVAR gs_Imagelist=DFR_imgpro:gs_Imagelist
	
	gs_imageinfo=""
	
	Variable index
	do
		String tempname=Stringfromlist(index,gs_Imagelist,";")
		gs_imageinfo+=Imageinfo(wname,tempname,0)	
		index+=1
	while (index<gv_imagenum)
End
	
Function proc_update_imgpvar_forpanel(topimagename)
	String topimagename
	String wname=winname(0,1)
	DFREF DFR_imgpro=$(DF_GP+wname+":ImageProcess:")
	
	NVAR gv_relativerangeflag=DFR_imgpro:gv_relativerangeflag
	
	NVAR gv_slider_min=DFR_imgpro:gv_slider_min
	NVAR gv_slider_max=DFR_imgpro:gv_slider_max
	
	NVAR gv_Image_Vmax=DFR_imgpro:gv_Image_Vmax
	NVAR gv_Image_Vmin=DFR_imgpro:gv_Image_Vmin
	
	Wave w_image=ImageNameToWaveRef(wname, topimagename )
	
	Wavestats /Q w_image
	gv_Image_Vmax=V_max
	gv_Image_Vmin=V_min
	
	Wave hist=DFR_imgpro:hist

	Setscale /I x,gv_image_Vmin,gv_Image_Vmax,hist

	Histogram/B=2 w_image,hist
	
	if (gv_relativerangeflag==1)
		Setscale /I x, 0, 1, hist
		gv_slider_min=-0.5
		gv_slider_max=2
	else
		gv_slider_min=(gv_Image_Vmin-(gv_Image_Vmax+gv_Image_Vmin)/2)*2+(gv_Image_Vmax+gv_Image_Vmin)/2
		gv_slider_max=(gv_Image_Vmax-(gv_Image_Vmax+gv_Image_Vmin)/2)*3+(gv_Image_Vmax+gv_Image_Vmin)/2
	endif
	
	Slider leftslider, win=$wname#Image_Process,limits={gv_slider_min,gv_slider_max,0}
	Slider rightslider,win=$wname#Image_Process,limits={gv_slider_min,gv_slider_max,0}
	
	String Simageinfo=Imageinfo(wname,topimagename,0)
	
	Variable Colortabflag,ColorTableft,ColorTabright,ColorTabreverse
	
	Variable temp=strsearch(SImageinfo,"ctab=",0)
	Variable temp1=strsearch(Simageinfo,"}",temp)
	String Cbstr=nospace(SImageinfo[temp,temp1])
	String tempstr
	temp=strsearch(Cbstr,"{",0)
	temp1=strsearch(Cbstr,",",temp)
	tempstr=cbstr[temp+1,temp1-1]
	if (grepstring(tempstr,"\*"))
		Colortabflag+=1
	else
		sscanf tempstr,"%g",ColorTableft
	endif
	temp=temp1+1
	temp1=strsearch(Cbstr,",",temp)
	tempstr=cbstr[temp,temp1-1]
	if (grepstring(tempstr,"\*"))
		Colortabflag+=2
	else
	 	sscanf tempstr,"%g",ColorTabright
	endif
	temp=temp1+1
	temp1=strsearch(Cbstr,",",temp)
	tempstr=cbstr[temp,temp1-1]
	String ctblist=tempstr//CTabList()
	//gv_ColorTabnum=WhichListItem(tempstr, ctblist,";",0)+1
	temp=temp1+1
	temp1=inf
	tempstr=cbstr[temp,temp1]
	sscanf tempstr,"%g",ColorTabreverse
	
	NVAR gv_leftx=DFR_imgpro:gv_leftx
	NVAR gv_rightx=DFR_imgpro:gv_rightx
	
	if (gv_relativerangeflag==1)
		if (Colortabflag==0) //by Default
			//gv_leftx=ColorTableft
			//gv_rightx=ColorTabright
			proc_update_image(2,5)
		elseif (Colortabflag==1)
			gv_leftx=0
			//gv_rightx=ColorTabright
			proc_update_image(2,2)
		elseif (Colortabflag==2)
			proc_update_image(2,1)
			//gv_leftx=ColorTableft
			gv_rightx=1
		elseif (Colortabflag==3)
			gv_leftx=0//(gv_leftx<gv_image_Vmin)?(gv_image_Vmin):(gv_leftx)
			gv_rightx=1//(gv_rightx>gv_image_Vmax)?(gv_image_Vmax):(gv_rightx)

		endif	
	else
		if (Colortabflag==0) //by Default
			gv_leftx=ColorTableft
			gv_rightx=ColorTabright
		elseif (Colortabflag==1)
			gv_leftx=gv_image_Vmin
			gv_rightx=ColorTabright
		elseif (Colortabflag==2)
			gv_leftx=ColorTableft
			gv_rightx=gv_image_Vmax
		elseif (Colortabflag==3)
			gv_leftx=gv_image_Vmin//(gv_leftx<gv_image_Vmin)?(gv_image_Vmin):(gv_leftx)
			gv_rightx=gv_image_Vmax//(gv_rightx>gv_image_Vmax)?(gv_image_Vmax):(gv_rightx)
		endif	
	endif
	
	
	
	NVAR ctabreverseflag=DFR_imgpro:ctabreverseflag
	ctabreverseflag=ColorTabreverse
	
	NVAR gv_ColorTabnum=DFR_imgpro:gv_ColorTabnum
	gv_ColorTabnum=WhichListItem(ctblist, CtabList()  , ";"  , 0 )
	
	PopupMenu DCs_p1,win=$wname#Image_Process,mode=gv_ColorTabnum+1
	
	temp=strsearch(SImageinfo,"lookup=",0)
	temp1=strsearch(SImageinfo,";",temp)
	String lookupstr=SImageinfo[temp+7,temp1-1]
	temp=strsearch(lookupstr,":",inf,1)
	if (temp==-1)
		temp=0
	endif
	
	String lookupwavename=lookupstr[temp+1,inf]
	Wave /Z lookupwave=DFR_imgpro:$lookupwavename
	NVAR gV_Contrastmode=DFR_imgpro:gV_Contrastmode
	SVAR gs_Contrastname=DFR_imgpro:gs_Contrastname
	NVAR sv0=DFR_imgpro:sv0
	NVAR sv1=DFR_imgpro:sv1
	
	if (waveexists(lookupwave))
		//Duplicate /o lookupwave, Color_lookup
		
		String notestr=note(lookupwave)
		if (strlen(notestr)>0)
		
			
		
			gV_Contrastmode=numberbykey("Contrastmode",notestr,"=","\r")
			sv0=numberbykey("sv0",notestr,"=","\r")
			sv1=numberbykey("sv1",notestr,"=","\r")
			gs_Contrastname=Stringbykey("Contrastname",notestr,"=","\r")
		
			PopupMenu ContFctn,win=$wname#Image_Process,mode=gv_Contrastmode
			PMContFctnPopMenuProc("ContFctn",gv_Contrastmode,gs_Contrastname)
		endif
	else
		gV_Contrastmode=1
		gs_Contrastname="Linear"
		sv0=1
		sv1=1
		PopupMenu ContFctn,win=$wname#Image_Process,mode=gv_Contrastmode
		PMContFctnPopMenuProc("ContFctn",gv_Contrastmode,gs_Contrastname)
	endif
	
	
	
End

Function proc_update_imgpvar(topimagename)
	String topimagename
	String wname=winname(0,1)
	DFREF DFR_imgpro=$(DF_GP+wname+":ImageProcess:")
	
	NVAR gv_relativerangeflag=DFR_imgpro:gv_relativerangeflag
	
	NVAR gv_slider_min=DFR_imgpro:gv_slider_min
	NVAR gv_slider_max=DFR_imgpro:gv_slider_max
	
	NVAR gv_Image_Vmax=DFR_imgpro:gv_Image_Vmax
	NVAR gv_Image_Vmin=DFR_imgpro:gv_Image_Vmin
	
	Wave w_image=ImageNameToWaveRef(wname, topimagename )
	
	Wavestats /Q w_image
	gv_Image_Vmax=V_max
	gv_Image_Vmin=V_min
	
	Wave hist=DFR_imgpro:hist

	Setscale /I x,gv_image_Vmin,gv_Image_Vmax,hist

	Histogram/B=2 w_image,hist
	
	if (gv_relativerangeflag==1)
		Setscale /I x, 0, 1, hist
		gv_slider_min=-0.5
		gv_slider_max=2
	else
		gv_slider_min=(gv_Image_Vmin-(gv_Image_Vmax+gv_Image_Vmin)/2)*2+(gv_Image_Vmax+gv_Image_Vmin)/2
		gv_slider_max=(gv_Image_Vmax-(gv_Image_Vmax+gv_Image_Vmin)/2)*3+(gv_Image_Vmax+gv_Image_Vmin)/2
	endif
	
	Slider leftslider, win=$wname#Image_Process,limits={gv_slider_min,gv_slider_max,0}
	Slider rightslider,win=$wname#Image_Process,limits={gv_slider_min,gv_slider_max,0}
	
	String Simageinfo=Imageinfo(wname,topimagename,0)
	
	Variable Colortabflag,ColorTableft,ColorTabright,ColorTabreverse
	
	Variable temp=strsearch(SImageinfo,"ctab=",0)
	Variable temp1=strsearch(Simageinfo,"}",temp)
	String Cbstr=nospace(SImageinfo[temp,temp1])
	String tempstr
	temp=strsearch(Cbstr,"{",0)
	temp1=strsearch(Cbstr,",",temp)
	tempstr=cbstr[temp+1,temp1-1]
	if (grepstring(tempstr,"\*"))
		Colortabflag+=1
	else
		sscanf tempstr,"%g",ColorTableft
	endif
	temp=temp1+1
	temp1=strsearch(Cbstr,",",temp)
	tempstr=cbstr[temp,temp1-1]
	if (grepstring(tempstr,"\*"))
		Colortabflag+=2
	else
	 	sscanf tempstr,"%g",ColorTabright
	endif
	temp=temp1+1
	temp1=strsearch(Cbstr,",",temp)
	tempstr=cbstr[temp,temp1-1]
	String ctblist=tempstr//CTabList()
	//gv_ColorTabnum=WhichListItem(tempstr, ctblist,";",0)+1
	temp=temp1+1
	temp1=inf
	tempstr=cbstr[temp,temp1]
	sscanf tempstr,"%g",ColorTabreverse
	
	NVAR gv_leftx=DFR_imgpro:gv_leftx
	NVAR gv_rightx=DFR_imgpro:gv_rightx
	
	if (Colortabflag==0) //auto
		gv_leftx=ColorTableft
		gv_rightx=ColorTabright
	elseif (Colortabflag==1)
		gv_leftx=gv_image_Vmin
		gv_rightx=ColorTabright
	elseif (Colortabflag==2)
		gv_leftx=ColorTableft
		gv_rightx=gv_image_Vmax
	elseif (Colortabflag==3)
		gv_leftx=gv_image_Vmin//(gv_leftx<gv_image_Vmin)?(gv_image_Vmin):(gv_leftx)
		gv_rightx=gv_image_Vmax//(gv_rightx>gv_image_Vmax)?(gv_image_Vmax):(gv_rightx)
	endif	
	
	if (gv_relativerangeflag==1)
		gv_leftx=(gv_leftx-gv_image_Vmin)/(gv_image_Vmax-gv_image_Vmin)
		gv_rightx=(gv_rightx-gv_image_Vmin)/(gv_image_Vmax-gv_image_Vmin)
	endif
	
	NVAR ctabreverseflag=DFR_imgpro:ctabreverseflag
	ctabreverseflag=ColorTabreverse
	
	NVAR gv_ColorTabnum=DFR_imgpro:gv_ColorTabnum
	gv_ColorTabnum=WhichListItem(ctblist, CtabList()  , ";"  , 0 )
	
	PopupMenu DCs_p1,win=$wname#Image_Process,mode=gv_ColorTabnum+1
	
	temp=strsearch(SImageinfo,"lookup=",0)
	temp1=strsearch(SImageinfo,";",temp)
	String lookupstr=SImageinfo[temp+7,temp1-1]
	temp=strsearch(lookupstr,":",inf,1)
	if (temp==-1)
		temp=0
	endif
	
	String lookupwavename=lookupstr[temp+1,inf]
	Wave /Z lookupwave=DFR_imgpro:$lookupwavename
	NVAR gV_Contrastmode=DFR_imgpro:gV_Contrastmode
	SVAR gs_Contrastname=DFR_imgpro:gs_Contrastname
	NVAR sv0=DFR_imgpro:sv0
	NVAR sv1=DFR_imgpro:sv1
	
	if (waveexists(lookupwave))
		//Duplicate /o lookupwave, Color_lookup
		
		String notestr=note(lookupwave)
		if (strlen(notestr)>0)
		
			
		
			gV_Contrastmode=numberbykey("Contrastmode",notestr,"=","\r")
			sv0=numberbykey("sv0",notestr,"=","\r")
			sv1=numberbykey("sv1",notestr,"=","\r")
			gs_Contrastname=Stringbykey("Contrastname",notestr,"=","\r")
		
			PopupMenu ContFctn,win=$wname#Image_Process,mode=gv_Contrastmode
			PMContFctnPopMenuProc("ContFctn",gv_Contrastmode,gs_Contrastname)
		endif
	else
		gV_Contrastmode=1
		gs_Contrastname="Linear"
		sv0=1
		sv1=1
		PopupMenu ContFctn,win=$wname#Image_Process,mode=gv_Contrastmode
		PMContFctnPopMenuProc("ContFctn",gv_Contrastmode,gs_Contrastname)
	endif
End



Function proc_bt_histchange(ctrlname) 
	String ctrlname
	String wname=winname(0,1)
	DFREF DFR_imgpro=$(DF_GP+wname+":ImageProcess:")
		
	NVAR gv_relativerangeflag=DFR_imgpro:gv_relativerangeflag
	
	NVAR gv_Image_Vmax=DFR_imgpro:gv_Image_Vmax
	NVAR gv_Image_Vmin=DFR_imgpro:gv_Image_Vmin
		
	NVAR gv_leftx=DFR_imgpro:gv_leftx
	NVAR gv_rightx=DFR_imgpro:gv_rightx	
	
	Wave hist=DFR_imgpro:hist
	
	Variable center=(gv_rightx+gv_leftx)/2
	Variable controlflag
		
	strswitch(ctrlname)
	case "DefaultHist":
		gv_leftx=gv_Image_Vmin
		gv_rightx=gv_Image_Vmax
		controlflag=1
		if (gv_relativerangeflag)
			gv_leftx=(gv_leftx-gv_Image_Vmin)/(gv_Image_Vmax-gv_Image_Vmin)
			gv_rightx=(gv_rightx-gv_Image_Vmin)/(gv_Image_Vmax-gv_Image_Vmin)
		endif
		break
	case "AutoHist":
		gv_leftx=gv_Image_Vmin
		gv_rightx=gv_Image_Vmax
		controlflag=0
		if (gv_relativerangeflag)
			gv_leftx=(gv_leftx-gv_Image_Vmin)/(gv_Image_Vmax-gv_Image_Vmin)
			gv_rightx=(gv_rightx-gv_Image_Vmin)/(gv_Image_Vmax-gv_Image_Vmin)
		endif
		break
	case "ExpandHist":
		gv_leftx=(gv_leftx-center)*1.1+center
		gv_rightx=(gv_rightx-center)*1.1+center
		controlflag=1
		break
	case "ShrinkHist":
		gv_leftx=(gv_leftx-center)*0.9+center	
		gv_rightx=(gv_rightx-center)*0.9+center
		controlflag=1
		break
	endswitch
	
	
	
	Proc_update_image(2,controlflag)
	
End


 
Function Proc_IMGrange_SVchange (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	Proc_update_image(2,1)
	return 0	// other return values reserved
End


Function Proc_IMGrange_change(name, value, event) : SliderControl
	String name	// name of this slider control
	Variable value	// value of slider
	Variable event	// bit field: bit 0: value set; 1: mouse down, 
					//   2: mouse up, 3: mouse moved
	
	Proc_update_image(2,1)
											
	return 0	// other return values reserved
End

Function Proc_ck_ctabreversechange(ctrlname,value)
	String ctrlname
	Variable value
	
	 proc_update_image(3,0)
ENd


Function Proc_ck_relativerange(ctrlname,value)
	String ctrlname
	Variable value
	String wname=winname(0,1)
	DFREF DFR_imgpro=$(DF_GP+wname+":ImageProcess:")
	
	SVAR topimg_name=DFR_imgpro:gs_topimage
	
	Proc_update_imgpvar(Topimg_name)
End


Function Proc_colortab_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String wname=winname(0,1)
	DFREF DFR_imgpro=$(DF_GP+wname+":ImageProcess:")
	
	NVAR gv_colorTabnum=DFR_imgpro:gv_colorTabnum
	
	gv_colorTabnum=popNum-1
	
	proc_update_image(1,0)
	
End

Function PMContFctnPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	String wname=winname(0,1)
	DFREF DFR_imgpro=$(DF_GP+wname+":ImageProcess:")
	
	//SVAR topGraph=DFR_imgpro:gs_IMGname
	NVAR m_mode= DFR_imgpro:gv_Contrastmode
	SVAR gs_Contrastname=DFR_imgpro:gs_Contrastname
	NVAR sv0=DFR_imgpro:sv0
	NVAR sv1=DFR_imgpro:sv1
	
	Wave userY=  DFR_imgpro:userY
	Wave userX=  DFR_imgpro:userX
	RemoveFromGraph/Z /W=$wname#Image_Process#Lookupdisp userY
	Variable SC=Screensize(5)
	if( CmpStr(popStr,"Gamma") == 0 )
		//sv0=1
		SetVariable Gamma,win=$wname#Image_Process,pos={20*SC,60*SC},size={80*SC,20*SC},title="Gamma:",limits={-Inf,Inf,0.1},value= sv0//DFR_imgpro:gv_Contrastgamma
		Slider Gslider0,win=$wname#Image_Process,pos={110*SC,65*SC},size={120*SC,13*SC},limits={0,10,0.1},variable=sv0,side= 0,vert= 0
	else
		KillControl /W=$wname#Image_Process Gamma
		KillControl /W=$wname#Image_Process Gslider0
	endif
	
	if(( CmpStr(popStr,"Logarithmic") == 0 )||( CmpStr(popStr,"Exponential") == 0 ))
	//	sv0=1
		SetVariable alpha,win=$wname#Image_Process,pos={20*SC,60*SC},size={80*SC,20*SC},title="Alpha:",limits={0,Inf,0.1},value= sv0//DFR_imgpro:gv_Contrastgamma
		slider Aslider0,win=$wname#Image_Process,pos={110*SC,65*SC},size={120*SC,13*SC},limits={0,10,0.1},variable=sv0,side= 0,vert= 0
	else
		KillControl /W=$wname#Image_Process alpha
		KillControl /W=$wname#Image_Process Aslider0
	endif
	
	
	if( (CmpStr(popStr,"Posterize") == 0) %| (CmpStr(popStr,"Ramps") == 0) )
	//	sv0=5
		SetVariable Levels,win=$wname#Image_Process,pos={20*SC,60*SC},size={80*SC,20*SC},title="Levels",format="%d",limits={2,100,1},value= sv0// DFR_imgpro:gv_Contrastlevels
	else
		KillControl /W=$wname#Image_Process Levels
	endif
	
	if ( CmpStr(popStr,"Colorized") == 0 )
		//sv0=1
		//sv1=0
		SetVariable period,win=$wname#Image_Process,pos={20*SC,53*SC},size={80*SC,15*SC},title="period:",limits={1,20,1},value=sv0
		SetVariable center,win=$wname#Image_Process,pos={20*SC,70*SC},size={80*SC,15*SC},title="center:",limits={0,1,0.02},value=sv1
		Slider slider0,win=$wname#Image_Process,pos={110*SC,58*SC},size={120*SC,13*SC},limits={1,20,1},variable=sv0,side= 0,vert= 0,title="period"
		Slider slider1,win=$wname#Image_Process,pos={110*SC,75*SC},size={120*SC,13*SC},limits={0,1,0.02},variable= sv1,side= 0,vert= 0,title="center"
	else
		KillControl /W=$wname#Image_Process period
		KillControl /W=$wname#Image_Process center
		KillControl /W=$wname#Image_Process slider0
		KillControl /W=$wname#Image_Process slider1
	endif
	
	if( CmpStr(popStr,"User Drawn") == 0 )
		AppendToGraph /W=$wname#Image_Process#Lookupdisp userY vs userX
		ModifyGraph /W=$wname#Image_Process#Lookupdisp rgb(userY)=(0,0,65535)
		GraphWaveEdit /W=$wname#Image_Process#Lookupdisp /M userY
	endif
	
	m_mode=popNum
	gs_Contrastname=popstr
	
	proc_update_image(0,0)
	
End


Function set_w_look_panel(x,d_low,d_high,g_low,g_high,sv0,sv1,m_mode)
	Variable x,d_low,d_high,g_low,g_high,sv0,sv1,m_mode
	Variable returnvalue
	
	Variable x0 = d_low
	Variable x1 = d_high
	Variable y0 = g_low
	Variable y1 = g_high
	
	String wname=winname(0,1)
	
	if (m_mode==1)
		returnvalue = my_line(x,x0,x1,y0,y1)
	endif
	if (m_mode==2)
		returnvalue = my_line(1-x,x0,x1,y0,y1)
	endif
	
	if (m_mode==3)	// does not work with inverted contrast
		returnvalue = my_gamma(x,x0,x1,y0,y1,sv0)
	endif
		
	if (m_mode==4)
		returnvalue = my_ln(x,x0,x1,y0,y1,sv0)
	endif
	
	if (m_mode == 5)
		returnvalue = my_exp(x,x0,x1,y0,y1,sv0)
	endif
	
	if (m_mode == 6) //uniform
		
		DFREF DFR_imgpro=$(DF_GP+wname+":ImageProcess:")
		Wave w=DFR_IMGpro:w_image_backup//$WMGetImageWave(ImGrfName)
		
		Make/O/N=999 contY,contX
		Histogram/B=1 w,contY

		InsertPoints 0,1,contY,contX	// force integral to start from 0

		Integrate contY
		contY= contY/contY[999]
		contX= p/999
		//AppendToGraph contY vs contX
		//ModifyGraph rgb(contY)=(0,0,65535)
		returnvalue=interp(x,contX,contY)
		//Killwaves/Z contX,ContY
	endif
	
	if (m_mode==7)
		Variable levels= sv0
		variable npts= 2*(levels-1)+2		// 2 vertices each interior point + start and end
		Make /N=(npts) contY,contX

		contX= floor((p/(npts-1))*levels+0.5)/levels
		contY= floor((p/(npts-1))*(levels-1)+0.5)/(levels-1)
	
		returnvalue=interp(x,contX,contY)
		Killwaves/Z contX,ContY
	endif
	if (m_mode==8)
		levels= sv0
		npts= 2*(levels-1)+2		// 2 vertices each interior point + start and end
		Make /N=(npts) contY,contX

		contX= floor((p/(npts-1))*levels+0.5)/levels
		contY= mod(p,2)
		returnvalue=interp(x,contX,contY)
		Killwaves/Z contX,ContY
	endif
	
	if (m_mode == 9) //Colorized
		returnvalue=0.5*(1+sin(pi*(x-sv1)*sv0))
	endif
	
	
	if (m_mode == 10) //User
		DFREF DFR_imgpro=$(DF_GP+wname+":ImageProcess:")
		Wave UserY=DFR_IMGpro:UserY
		Wave UserX=DFR_IMGpro:UserX
		
		returnvalue=interp(x,UserX,UserY)
	endif
	
	
	return returnvalue
End


//	connect two points with [lin., exp, ln, power]- functions						FB 27.11 01
/////////////////////////////////////////////////////////////////////////
Function my_exp(x,x0,x1,y0,y1,alpha)
	Variable x,x0,x1,y0,y1, alpha
	
	Variable a0= (y1-y0) / (exp(alpha*(x1-x0)) -1)
	Variable b0 = y0-a0	

	return b0+a0*exp(alpha*(x-x0))
End
/////////////////////////////////////////////////////////////////////////
Function my_line(x,x0,x1,y0,y1)
	Variable x,x0,x1,y0,y1
	
	Variable a0= (y1-y0) / (x1-x0)
	Variable b0 = y0-a0*x0	

		return b0+a0*x
End
//	alpha > 0
/////////////////////////////////////////////////////////////////////////
Function my_ln(x,x0,x1,y0,y1, alpha)
	Variable x,x0,x1,y0,y1,alpha
	
	Variable a0= (y1-y0) / ( ln(x1-x0+alpha) - ln(alpha)  )
	Variable b0 = y0 - a0 * ln(alpha)	

	return b0+a0*ln(alpha+x-x0)
End
/////////////////////////////////////////////////////////////////////////
Function my_gamma(x,x0,x1,y0,y1, Gamma)
	Variable x,x0,x1,y0,y1,Gamma
	
	Variable a0 = (y1-y0) / ( (x1-x0)^(1/Gamma) )
	Variable b0 = y0
	
	if (x <= x0)
		return y0
	endif
	if (x >= x1)
		return y1
	else
		return  b0+a0*(x-x0)^(1/Gamma)
	endif
End











///////////////////////Create ROI/////////////////////


Function MyCreate_ROIHook(s)
	STRUCT WMWinHookStruct &s
	Variable hookResult = 0
	String wname=s.winName
	switch(s.eventCode)
		case 2:
			String graphname=winname(0,1)
			removeimage /Z /W=$graphname w_threshold
			break
	endswitch
	return hookResult
End

Function GP_CreateROI()
	open_ROI_panel()
End

Function /DF init_createROI_panel()

	String wname=winname(0,1)

	DFREF DFR_GP=$DF_GP
	SetDatafolder DFR_GP

	String imglist=ImageNameList(wname,";")
	
	if (strlen(imglist)==0)
		Doalert 0,"There is no Image on the graph!"
		DFREF DFR_imgpro=$(DF_GP)
		return DFR_imgpro
	endif

	newDatafolder /o/s $wname
	newDatafolder /o/s	CreateROI
	
	String /G gs_imagename=Stringfromlist(0,imglist,";")
	Wave w_image=ImageNameToWaveRef(wname, gs_imagename)
	String /G gs_imagepath=GetwavesDatafolder(w_image,2)
	Wavestats /Q w_image
	Variable /G gv_imagemax=V_max
	Variable /G gv_imagemin=V_min
	
	Variable /G gv_Low=V_min
	Variable /G gv_high=V_max
	
	Duplicate /o w_image, w_threshold
	
	redimension /B /U w_threshold
	
	w_threshold=0
	
	Return GetDatafolderdfr()
End

Function open_ROI_panel()
	DFREF DF=GetDatafolderDFR()
	DFREF DFR_GP=$DF_GP
		
	SetDatafolder DFR_GP

	String wname=winname(0,1)

	String Cwnamelist=ChildWindowList(wname)
 	
	if (Findlistitem("Create_ROI",Cwnamelist,";",0)!=-1)
 		KillWindow $wname#Create_ROI
 		SetDatafolder DF
 		return 0
	endif
	
 	DFREF DFR_ROI=init_createROI_panel()
	if (DataFolderRefsEqual(DFR_GP,DFR_ROI))
		SetDatafolder DF
		return 0
	else
		SetDatafolder DFR_ROI
	endif
	
	Variable SC=ScreenSize(5)
	Variable r=57000, g=57000, b=57000
	Variable width=380*SC,Height=150*SC

	NewPanel /Host=$wname/EXT=0/K=1/W=(0,0,width,Height)/N=Create_ROI as "Create_ROI"
	Modifypanel /W=$wname#Create_ROI cbRGB=(52428,52428,52428)
	ModifyPanel /W=$wname#Create_ROI noEdit=1, fixedSize=1
	SetWindow $wname#Create_ROI  hook(MyHook) = MyCreate_ROIHook
	
	
	groupbox ROI_gb0, pos={10*SC,5*SC},size={120*SC,100*SC},title="Drawing",frame=0
	Button StartROI,pos={20*SC,25*SC},size={100*SC,20*SC},proc=RoiDrawButtonProc,title="Start ROI Draw"
	Button StartROI,help={"Adds drawing tools to top image graph. Use rectangle, circle or polygon."}
	Button clearROI,pos={20*SC,75*SC},size={100*SC,20*SC},proc=RoiDrawButtonProc,title="Erase ROI"
	Button clearROI,help={"Erases previous ROI. Not undoable."}
	Button FinishROI,pos={20*SC,50*SC},size={100*SC,20*SC},proc=RoiDrawButtonProc,title="Finish ROI"
	Button FinishROI,help={"Click after you are finished editing the ROI"}
	
	NVAR gv_imagemin
	NVAR gv_imagemax
	
	groupbox ROI_gb1, pos={140*SC,5*SC},size={220*SC,100*SC},title="Threshold",frame=0
	slider ROI_sl0,pos={150*SC,25*SC},size={150*SC,20*SC},variable=gv_low,title="Lower:",vert=0,ticks=0,limits= {gv_imagemin,gv_imagemax,(gv_imagemax-gv_imagemin)/1000 }	
	slider ROI_sl0,proc=proc_Thresholdslider
	Setvariable ROI_sv0,pos={310*SC,25*SC},size={45*SC,20*SC},variable=gv_low,title=" ",limits={gv_imagemin,gv_imagemax,0},proc=proc_Thresholdsv
	slider ROI_sl1,pos={150*SC,50*SC},size={150*SC,20*SC},variable=gv_high,title="Upper:",vert=0,ticks=0,limits= {gv_imagemin,gv_imagemax,(gv_imagemax-gv_imagemin)/1000 }	
	slider ROI_sl1,proc=proc_Thresholdslider
	Setvariable ROI_sv1,pos={310*SC,50*SC},size={45*SC,20*SC},variable=gv_high,title=" ",limits={gv_imagemin,gv_imagemax,0},proc=proc_Thresholdsv
	
	Button ROI_bt0,pos={150*SC,75*SC},size={60*SC,20*SC},title="Show",proc=proc_bt_showthreshold
	Button ROI_bt1,pos={220*SC,75*SC},size={60*SC,20*SC},title="Remove",proc=proc_bt_showthreshold
	
	Button saveROICopy,pos={135*SC,124*SC},size={110*SC,20*SC},proc=saveRoiCopyProc,title="Create ROI Image"
	Button saveROIAppend,pos={260*SC,124*SC},size={110*SC,20*SC},proc=saveRoiCopyProc,title="Append ROI Image"
	
	CheckBox zeroRoiCheck,pos={15*SC,124*SC},size={94*SC,14*SC},title="Zero ROI select",value= 1
	//Button roiPanelHelp,pos={15*SC,145*SC},size={150*SC,20*SC},proc=roiPanelButtonProc,title="Help"	

	//Groupbox 

	SetDatafolder DF
End

Function proc_Thresholdsv (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	update_threshold()
End

Function proc_Thresholdslider(name, value, event) : SliderControl
	String name	// name of this slider control
	Variable value	// value of slider
	Variable event	// bit field: bit 0: value set; 1: mouse down, 
					//   2: mouse up, 3: mouse moved
	update_threshold()
							
	return 0	// other return values reserved
End

function update_threshold()
	String wname=winname(0,1)
	DFREF DF=GetDatafolderDFR()
	DFREF DFR_GP=$DF_GP
	
	DFREF DFR_ROI=$(DF_GP+wname+":CreateROI")
	
	SVAR imagename=DFR_ROI:gs_imagename
	
	Wave w= Imagenametowaveref(wname,imagename)
	Wave w_threshold=DFR_ROI:w_threshold
	NVAR gv_low=DFR_ROI:gv_low
	NVAR gv_high=DFR_ROI:gv_high
	
	if (gv_low<gv_high)
		w_threshold=((w>gv_low)&&(w<gv_high))?(0):(1)
	else
		w_threshold=((w<gv_low)||(w>gv_high))?(0):(1)
	endif
	
End

Function proc_bt_showthreshold(ctrlname)
	String ctrlname
	String wname=winname(0,1)
	DFREF DF=GetDatafolderDFR()
	DFREF DFR_GP=$DF_GP
	
	DFREF DFR_ROI=$(DF_GP+wname+":CreateROI")

	
	SVAR imagename=DFR_ROI:gs_imagename
	
	
	Wave w_threshold=DFR_ROI:w_threshold
	
	if (stringmatch(ctrlname,"ROI_bt1"))
		removeimage /Z /W=$wname w_threshold
		SetDatafolder DF
		return 0
	endif
	
	CheckDisplayed /W=$wname w_threshold
	if(V_flag)
		SetDatafolder DF
		return 0
	endif
	
	appendimage /W=$wname w_threshold
	ModifyImage  /W=$wname w_threshold ctab= {0.5,0.6,Grays,0},minRGB=(65535,0,0),maxRGB=NaN
	
	SetDatafolder DF
End

Function saveRoiCopyProc(ctrlname)
	String ctrlname
	String wname=winname(0,1)
	DFREF DF=GetDatafolderDFR()
	DFREF DFR_GP=$DF_GP
	
	DFREF DFR_ROI=$(DF_GP+wname+":CreateROI")
	
	SVAR imagename=DFR_ROI:gs_imagename
	
	Wave ww= Imagenametowaveref(wname,imagename)
	Wave w_threshold=DFR_ROI:w_threshold

	String waveDF=GetWavesDataFolder(ww,1 )
	SetDataFolder waveDF
	
	if (stringmatch(ctrlname,"saveROIAppend"))
		Wave /Z M_ROIMask
		if (waveexists(M_ROIMask)==0)
			doalert 0, "ROI wave not found"
			SetDatafolder DF
			return 0
		endif
		Duplicate /o /Free M_ROIMask M_ROIMask_backup
	endif
	
	ControlInfo /W=$wname#Create_ROI zeroRoiCheck
	if(V_value)
		ImageGenerateROIMask/W=$wname/E=1/I=0 $imagename
	else
		ImageGenerateROIMask/W=$wname $imagename		
	endif

	
	Wave M_ROIMask
	
	checkdisplayed /W=$wname w_threshold
	if (V_flag)
		M_ROIMask=M_ROIMask&&w_threshold
		removeimage /Z /W=$wname w_threshold
	endif
	
	if (stringmatch(ctrlname,"saveROIAppend"))
		M_ROIMask=M_ROIMask&&M_ROIMask_backup
	endif
	
	newimage /F  M_ROIMask
	
	SetDatafolder DF
End

Function RoiDrawButtonProc(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderDFR()
	DFREF DFR_GP=$DF_GP
	String wname=winname(0,1)
	
	DFREF DFR_ROI=$(DF_GP+wname+":CreateROI")
	
	SVAR imagename=DFR_ROI:gs_imagename
	
	if( CmpStr(ctrlName,"StartROI") == 0 )
		ShowTools/A /W=$wname rect
		SetDrawLayer /W=$wname ProgFront
		Wave w= Imagenametowaveref(wname,imagename)
		String iminfo= ImageInfo(wname, nameofwave(w), 0)
		String xax= StringByKey("XAXIS",iminfo)
		String yax= StringByKey("YAXIS",iminfo)
		SetDrawEnv /W=$wname linefgc= (3,52428,1),fillpat= 0,xcoord=$xax,ycoord=$yax,save
	endif
	if( CmpStr(ctrlName,"FinishROI") == 0 )
		GraphNormal/W=$wname
		HideTools/A/W=$wname
		SetDrawLayer /W=$wname UserFront
		//DoWindow/F WMImageROIPanel
	endif
	if( CmpStr(ctrlName,"clearROI") == 0 )
		GraphNormal /W=$wname
		SetDrawLayer/K/W=$wname ProgFront
		SetDrawLayer /W=$wname UserFront
		//DoWindow/F WMImageROIPanel
	endif
	
	SetDatafolder DF
End




/////////////////////ROI related Function //////////////////////////

Function GP_imagestats()
	
	String wname=winname(0,1)
	DFREF DF=GetDatafolderDFR()
	
	
	Variable ROIflag
	
	prompt ROIflag,"Select:", popup,"All;ROI;Marquee"
	Doprompt "Select for Image stats",ROIflag
	if (V_flag)
		SetDatafolder DF
		return 0
	endif
	
	DFREF DFR_GP=$DF_GP
	SetDatafolder DFR_GP
	newDatafolder /o/s $wname
	newDatafolder /o/s IP
	
	String imagelist=Imagenamelist(wname,";")
	String imagename=Stringfromlist(0,imagelist,";")
	Wave w= Imagenametowaveref(wname,imagename)
	
	DFREF DFR_image=GetWavesDataFolderDFR(w)
	
	String iminfo= ImageInfo(wname, nameofwave(w), 0)
	String xax= StringByKey("XAXIS",iminfo)
	String yax= StringByKey("YAXIS",iminfo)
	
	switch (ROIflag)
		case 1:
			Imagestats w
			break
		case 2:
			Wave /Z ROIwave=DFR_image:M_ROIMask
			if (waveexists(ROIwave)==0)
				doalert 0,"ROI wave not found."
				SetDatafolder DF
				return 0
			endif
			Imagestats /R=ROIwave w
			break
		case 3:
			GetMarquee $xax,$yax
			Variable xp0=x2pntsmult(w,v_left,0)
			Variable xp1=x2pntsmult(w,v_right,0)
			Variable yq0=x2pntsmult(w,v_top,1)
			Variable yq1=x2pntsmult(w,v_bottom,1)
			
			Imagestats /G={min(xp0,xp1),max(xp0,xp1),min(yq0,yq1),max(yq0,yq1)} w
	endswitch

	Make /o/t/n=13 Imagestats_title
	Make /o/n=13 Imagestats_value
	
	Imagestats_title={"V_avg","V_min","V_max","V_minRowLoc","V_minColLoc","V_maxRowLoc","V_maxColLoc","V_npnts","V_adev","V_rms","V_sdev","V_skew","V_kurt"}
		
	Imagestats_value[0]=V_avg
	Imagestats_value[1]=V_min
	Imagestats_value[2]=V_max
	Imagestats_value[3]=V_minRowLoc
	Imagestats_value[4]=V_minColLoc
	Imagestats_value[5]=V_maxRowLoc
	Imagestats_value[6]=V_maxColLoc
	Imagestats_value[7]=V_npnts
	Imagestats_value[8]=V_adev
	Imagestats_value[9]=V_rms
	Imagestats_value[10]=V_sdev
	Imagestats_value[11]=V_skew
	Imagestats_value[12]=V_kurt
	
	edit Imagestats_title,Imagestats_value
	
	SetDatafolder DF
End

Function GP_imageHistogram()
	
	String wname=winname(0,1)
	DFREF DF=GetDatafolderDFR()
	
	
	Variable ROIflag
	
	prompt ROIflag,"Select:", popup,"All;ROI;"
	Doprompt "Select for Image Hist",ROIflag
	if (V_flag)
		SetDatafolder DF
		return 0
	endif
	
	DFREF DFR_GP=$DF_GP
	SetDatafolder DFR_GP
	newDatafolder /o/s $wname
	newDatafolder /o/s IP
	
	String imagelist=Imagenamelist(wname,";")
	String imagename=Stringfromlist(0,imagelist,";")
	Wave w= Imagenametowaveref(wname,imagename)
	
	DFREF DFR_image=GetWavesDataFolderDFR(w)
	
	String iminfo= ImageInfo(wname, nameofwave(w), 0)
	String xax= StringByKey("XAXIS",iminfo)
	String yax= StringByKey("YAXIS",iminfo)
	
	switch (ROIflag)
		case 1:
			ImageHistogram w
			break
		case 2:
			Wave /Z ROIwave=DFR_image:M_ROIMask
			if (waveexists(ROIwave)==0)
				doalert 0,"ROI wave not found."
				SetDatafolder DF
				return 0
			endif
			ImageHistogram /R=ROIwave w
			break
	endswitch
	
	Wave W_ImageHist
	display_wave(w_ImageHist,0,0)

	Killwaves /Z w_ImageHist
	SetDatafolder DF
	return 0
End

Function GP_2DbkgfromROI()
	String wname=winname(0,1)
	DFREF DF=GetDatafolderDFR()
	
	Variable polypnts=1
	
	prompt polypnts,"Input bkg poly pnts"
	doprompt "Select for Remove bkg",polypnts
	if (V_flag)
		SetDatafolder DF
		return 0
	endif
	
	DFREF DFR_GP=$DF_GP
	SetDatafolder DFR_GP
	newDatafolder /o/s $wname
	newDatafolder /o/s IP
	
	String imagelist=Imagenamelist(wname,";")
	String imagename=Stringfromlist(0,imagelist,";")
	Wave w= Imagenametowaveref(wname,imagename)
	
	DFREF DFR_image=GetWavesDataFolderDFR(w)
	
	String iminfo= ImageInfo(wname, nameofwave(w), 0)
	String xax= StringByKey("XAXIS",iminfo)
	String yax= StringByKey("YAXIS",iminfo)
	
	Wave /Z ROIwave=DFR_image:M_ROIMask
	if (waveexists(ROIwave)==0)
		doalert 0,"ROI wave not found."
		SetDatafolder DF
		return 0
	endif
	
	ImageRemoveBackground /F/R=ROIwave /P=(polypnts)  w
	Wave M_RemovedBackground
	
	Duplicate /o M_RemovedBackground, $(nameofwave(w)+"_rbkg")
	Wave w_bkg=$(nameofwave(w)+"_rbkg")
	
	copyscales  w,w_bkg
	
	display_wave(w_bkg,0,0)
	
	Killwaves /Z M_RemovedBackground,w_bkg
	SetDatafolder DF
	return 0
End

Function GP_RemoveBkg()
	String wname=winname(0,1)
	DFREF DF=GetDatafolderDFR()
	
	Variable polypnts=1
	
	prompt polypnts,"Input bkg poly pnts"
	doprompt "Select for Remove bkg",polypnts
	if (V_flag)
		SetDatafolder DF
		return 0
	endif
	
	DFREF DFR_GP=$DF_GP
	SetDatafolder DFR_GP
	newDatafolder /o/s $wname
	newDatafolder /o/s IP
	
	String imagelist=Imagenamelist(wname,";")
	String imagename=Stringfromlist(0,imagelist,";")
	Wave w= Imagenametowaveref(wname,imagename)
	
	DFREF DFR_image=GetWavesDataFolderDFR(w)
	
	String iminfo= ImageInfo(wname, nameofwave(w), 0)
	String xax= StringByKey("XAXIS",iminfo)
	String yax= StringByKey("YAXIS",iminfo)
	
	Wave /Z ROIwave=DFR_image:M_ROIMask
	if (waveexists(ROIwave)==0)
		doalert 0,"ROI wave not found."
		SetDatafolder DF
		return 0
	endif
	
	ImageRemoveBackground /R=ROIwave /P=(polypnts)  w
	Wave M_RemovedBackground
	
	Duplicate /o M_RemovedBackground, $(nameofwave(w)+"_rbkg")
	Wave w_bkg=$(nameofwave(w)+"_rbkg")
	
	CopyScales /P w, w_bkg
	
	display_wave(w_bkg,0,1)
	
	Killwaves /Z M_RemovedBackground,w_bkg
	SetDatafolder DF
	return 0
End

Function GP_imageFilter()
	String wname=winname(0,1)
	DFREF DF=GetDatafolderDFR()
	
	
	Variable ROIflag
	Variable filtertype,filterpnts=3,filtertimes=1
	
	prompt ROIflag,"Select region:", popup,"All;ROI;"
	prompt filtertype,"Select filter:",popup,"avg;FindEdges;gauss;sharpen;sharpenmore;gradN;gradNW;gradW;gradSW;gradS;gradSE;gradE;gradNE;max;median;min;NanZapMedian;point;thin;"
	prompt filterpnts,"input filterpnts:"
	prompt filtertimes,"input filtertimes:"
	Doprompt "Select for Image filter",ROIflag,filtertype,filterpnts,filtertimes
	if (V_flag)
		SetDatafolder DF
		return 0
	endif
	
	DFREF DFR_GP=$DF_GP
	SetDatafolder DFR_GP
	newDatafolder /o/s $wname
	newDatafolder /o/s IP
	
	String imagelist=Imagenamelist(wname,";")
	String imagename=Stringfromlist(0,imagelist,";")
	Wave w_raw= Imagenametowaveref(wname,imagename)
	
	DFREF DFR_image=GetWavesDataFolderDFR(w)
	
	String iminfo= ImageInfo(wname, nameofwave(w), 0)
	String xax= StringByKey("XAXIS",iminfo)
	String yax= StringByKey("YAXIS",iminfo)
	
	
	if (ROIflag==2)
		Wave /Z ROIwave=DFR_image:M_ROIMask
		if (waveexists(ROIwave)==0)
			doalert 0,"ROI wave not found."
			SetDatafolder DF
			return 0
		endif
	endif
	
	Duplicate /o w_raw, $(nameofwave(w_raw)+"_filter")
	Wave w=$(nameofwave(w_raw)+"_filter")
		
	switch (filtertype)
		case 1:
			if (ROIflag==1)
				MatrixFilter /N=(filterpnts)/P=(filtertimes) avg w
			else
				MatrixFilter /N=(filterpnts)/P=(filtertimes) /R=ROIwave avg w
			endif
			break
		case 2:
			if (ROIflag==1)
				MatrixFilter /N=(filterpnts)/P=(filtertimes) FindEdges w
			else
				MatrixFilter /N=(filterpnts)/P=(filtertimes) /R=ROIwave FindEdges w
			endif
			break
		case 3:
			if (ROIflag==1)
				MatrixFilter /N=(filterpnts)/P=(filtertimes) gauss w
			else
				MatrixFilter /N=(filterpnts)/P=(filtertimes) /R=ROIwave gauss w
			endif
			break
		case 4:
			if (ROIflag==1)
				MatrixFilter /N=(filterpnts)/P=(filtertimes) sharpen w
			else
				MatrixFilter /N=(filterpnts)/P=(filtertimes) /R=ROIwave sharpen w
			endif
			break
		case 5:
			if (ROIflag==1)
				MatrixFilter /N=(filterpnts)/P=(filtertimes) sharpenmore w
			else
				MatrixFilter /N=(filterpnts)/P=(filtertimes) /R=ROIwave sharpenmore w
			endif
			break
		case 6:
			if (ROIflag==1)
				MatrixFilter /N=(filterpnts)/P=(filtertimes) gradN w
			else
				MatrixFilter /N=(filterpnts)/P=(filtertimes) /R=ROIwave gradN w
			endif
			break
		case 7:
			if (ROIflag==1)
				MatrixFilter /N=(filterpnts)/P=(filtertimes) gradNW w
			else
				MatrixFilter /N=(filterpnts)/P=(filtertimes) /R=ROIwave gradNW w
			endif
			break
		case 8:
			if (ROIflag==1)
				MatrixFilter /N=(filterpnts)/P=(filtertimes) gradW w
			else
				MatrixFilter /N=(filterpnts)/P=(filtertimes) /R=ROIwave gradW w
			endif
			break
		case 9:
			if (ROIflag==1)
				MatrixFilter /N=(filterpnts)/P=(filtertimes) gradSW w
			else
				MatrixFilter /N=(filterpnts)/P=(filtertimes) /R=ROIwave gradSW w
			endif
			break
		case 10:
			if (ROIflag==1)
				MatrixFilter /N=(filterpnts)/P=(filtertimes) gradS w
			else
				MatrixFilter /N=(filterpnts)/P=(filtertimes) /R=ROIwave gradS w
			endif
			break
		case 11:
			if (ROIflag==1)
				MatrixFilter /N=(filterpnts)/P=(filtertimes) gradSE w
			else
				MatrixFilter /N=(filterpnts)/P=(filtertimes) /R=ROIwave gradSE w
			endif
			break
		case 12:
			if (ROIflag==1)
				MatrixFilter /N=(filterpnts)/P=(filtertimes) gradE w
			else
				MatrixFilter /N=(filterpnts)/P=(filtertimes) /R=ROIwave gradE w
			endif
			break
		case 13:
			if (ROIflag==1)
				MatrixFilter /N=(filterpnts)/P=(filtertimes) gradNE w
			else
				MatrixFilter /N=(filterpnts)/P=(filtertimes) /R=ROIwave gradNE w
			endif
			break
		case 14:
			if (ROIflag==1)
				MatrixFilter /N=(filterpnts)/P=(filtertimes) max w
			else
				MatrixFilter /N=(filterpnts)/P=(filtertimes) /R=ROIwave max w
			endif
			break
		case 15:
			if (ROIflag==1)
				MatrixFilter /N=(filterpnts)/P=(filtertimes) median w
			else
				MatrixFilter /N=(filterpnts)/P=(filtertimes) /R=ROIwave median w
			endif
			break
		case 16:
			if (ROIflag==1)
				MatrixFilter /N=(filterpnts)/P=(filtertimes) min w
			else
				MatrixFilter /N=(filterpnts)/P=(filtertimes) /R=ROIwave min w
			endif
			break
		case 17:
			if (ROIflag==1)
				MatrixFilter /N=(filterpnts)/P=(filtertimes) NanZapMedian w
			else
				MatrixFilter /N=(filterpnts)/P=(filtertimes) /R=ROIwave NanZapMedian w
			endif
			break
		case 18:
			if (ROIflag==1)
				MatrixFilter /N=(filterpnts)/P=(filtertimes) point w
			else
				MatrixFilter /N=(filterpnts)/P=(filtertimes) /R=ROIwave point w
			endif
			break
		case 19:
			if (ROIflag==1)
				MatrixFilter /N=(filterpnts)/P=(filtertimes) thin w
			else
				MatrixFilter /N=(filterpnts)/P=(filtertimes) /R=ROIwave thin w
			endif
			break
	endswitch
	
	
	display_wave(w,0,1)

	Killwaves /Z w
	SetDatafolder DF
	return 0
End



////Analyze nolinearity


Function GP_AnalyzeNolinearity()
	String wname=winname(0,1)
	DFREF DF=GetDatafolderDFR()
	DFREF DFR_procwave=$(DFS_global+"proc_wave")
	DFREF DFR_GP=$DF_GP
	SetDatafolder DFR_GP
	newDatafolder /o/s $wname
	newDatafolder /o/s IP
	Variable/G V_FitOptions=4	
	
	
	String imagelist=Imagenamelist(wname,";")
	
	if (strlen(imagelist)==0)
		SetDatafolder DF
		return 0
	endif
	
	variable/D/C rr=DefaultRange()
	Variable x1=real(rr),x2=Imag(rr)
	variable xrangeflag=1
	
	prompt xrangeflag,"Use (E1,E2) below", popup,"Use (E1,E2) below;(-inf, inf);All pixels"
	prompt x1,"E1"
	prompt x2,"E2"
	
	DoPrompt "Analyze Nolinearity", xrangeflag,x1,x2
	
	if (V_flag)
		SetDatafolder DF
		return 0
	endif
	Variable items=itemsinlist(imagelist)
	
	
	if (xrangeflag<3) //EDC correction

	
		String imagename=stringfromlist(0,imagelist,";")
		Wave data=ImageNameToWaveRef(wname, imagename )
		Variable xpnts=dimsize(data,0)
		Variable m0=M_x0(data)
		Variable m1=M_x1(data)
		
		Make /o/n=(xpnts,items+1) CurveTemp
		Make /o/n=(items+1) w_beam
		
		CurveTemp[][0]=0
		w_beam[0]=0
		
		Variable index=0
	
	
		do
			imagename=stringfromlist(index,imagelist,";")
			Wave data=ImageNameToWaveRef(wname, imagename )
			String notestr=note(data)
			Variable beamcurrent=NumberByKey("BeamCurrent", notestr,"=","\r")
		
		
			if (xrangeflag==1)
				m_avg_subrange(data,0,x1,x2)
			else
				m_avg(data,0)
			endif
			Wave w_avg
		
			Duplicate /o w_avg,Inttemp
			//TMFtemp/=mean(Inttemp)
			//TMFtemp=beamcurrent
		
			CurveTemp[][index+1]=Inttemp[p]
			w_beam[index+1]=beamcurrent
		
			index+=1
		while (index<items)
	

	
	
		Make /o/n=(items) Colcurve_y//,Dcurve_x,Dcurve_y
	
		Variable  maxI=wavemax(w_beam)

		maxI=wavemax(CurveTemp)
		Make /o/n=(xpnts,5000) CorCurve_R
		Setscale /I y, 0,maxI,CorCurve_R
		Setscale /I x, m0,m1,CorCurve_R
			
		Make /o/n=3 w_coef
		Make /o/n=2 w_coef1	
	
		index=0
		do
			ColCurve_y=CurveTemp[index][p]
	
			//w_coef=0
			//CurveFit/Q/M=2/W=0 exp, w_beam/X=Colcurve_y
			//w_coef1[1]=w_coef[2]
			//w_coef1[0]=w_coef[1]
			//Funcfit /NTHR=0 /Q expfit_nonlinearity w_coef1  w_beam /X=Colcurve_y
			//CorCurve_R[index][]=expfit_nonlinearity(w_coef1,y)
	
			CorCurve_R[index][]=interp(y, ColCurve_y, w_beam)
	
			index+=1
		while (index<xpnts)
	
	
		SetDatafolder DFR_procwave
		
		String procwavename="NonLinear_image"
		prompt procwavename,"Input proc wave name"
		Doprompt "Save as proc wave",procwavename
		if (strlen(procwavename)>25)
			procwavename=nameofwave(procwave)[0,24]
		endif
		
		procwavename=Uniquename(procwavename,1,0)
		Duplicate /o CorCurve_R $procwavename
		notestr=""
		notestr+="\rType=EDC\r"
		Wave procwave=$procwavename
		note /K procwave
		note procwave,notestr
		
		procwave=(procwave<0)?(0):(procwave)
		
		SetDatafolder DFR_GP
		SetDatafolder $wname
		SetDatafolder IP
		
		Killwaves /Z ColCurve_y,CorCurve_R,CurveTemp,w_Beam
	else
		imagename=stringfromlist(0,imagelist,";")
		Wave data=ImageNameToWaveRef(wname, imagename)
		xpnts=dimsize(data,0)
		Variable ypnts=dimsize(data,1)
		
		m0=M_x0(data)
		 m1=M_x1(data)
		Variable y0=M_y0(data)
		Variable y1=M_y1(data)
		
		Make /o/n=(xpnts,ypnts,items) Cube_Temp
		Make /o/n=(items) w_beam
		
		index=0
		do
			imagename=stringfromlist(index,imagelist,";")
			Wave data=ImageNameToWaveRef(wname, imagename )
			notestr=note(data)
			beamcurrent=NumberByKey("BeamCurrent", notestr,"=","\r")
		
		
			w_beam[index]=beamcurrent
			cube_Temp[][][index]=data[p][q]
			
			index+=1
		while (index<items)
		
		
		Make /o/n=(items) Colcurve_y
		Make /o/n=(xpnts,ypnts,500) Cube_Cor
		Setscale /I z,0,wavemax(cube_Temp),Cube_Cor
		Setscale /I x,m0,m1,Cube_cor
		Setscale /I y,y0,y1,Cube_cor
		
		
		Make /o/n=3 w_coef
		Make /o/n=2 w_coef1
		
		Variable xindex=0
		Variable yindex=0
		do
			yindex=0
			do
				Colcurve_y=cube_Temp[xindex][yindex][p]
				//w_coef=0
				
				//CurveFit/Q/M=2/W=0 exp, w_beam/X=Colcurve_y
				//w_coef1[1]=w_coef[2]
				//w_coef1[0]=w_coef[1]
				//Funcfit /Q/NTHR=0 expfit_nonlinearity w_coef1  w_beam /X=Colcurve_y
				//Cube_Cor[xindex][yindex][]=expfit_nonlinearity(w_coef1,z)
				Cube_Cor[xindex][yindex][]=interp(z, Colcurve_y, w_beam )
				
				yindex+=1
			while (yindex<ypnts)
			xindex+=1
		while (xindex<xpnts)
		
		
		SetDatafolder DFR_procwave
		
		procwavename="NonLinear_cube"
		prompt procwavename,"Input proc wave name"
		Doprompt "Save as proc wave",procwavename
		if (strlen(procwavename)>25)
			procwavename=nameofwave(procwave)[0,24]
		endif
		
		procwavename=Uniquename(procwavename,1,0)
		Duplicate /o Cube_Cor $procwavename
		notestr=""
		notestr+="\rType=2D\r"
		Wave procwave=$procwavename
		note /K procwave
		note procwave,notestr
		
		procwave=(procwave<0)?(0):(procwave)
	
		SetDatafolder DFR_GP
		SetDatafolder $wname
		SetDatafolder IP
		
		//Killwaves /Z ColCurve_y,Cube_Cor,cube_Temp,w_Beam
	
	endif

	
	setdatafolder DF
End

Function expfit_nonlinearity(coef,x): FitFunc
	Wave coef
	Variable x
	
	return coef[0]-coef[0]*exp(-coef[1]*(x))
End

//Function expfit_nonlinearity(coef,x): FitFunc
//	Wave coef
//	Variable x
	
//	return coef[0]*exp(-coef[1]*(-coef[2]))-coef[0]*exp(-coef[1]*(x-coef[2]))
//End