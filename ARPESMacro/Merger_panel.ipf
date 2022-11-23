#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 0.01
#pragma ModuleName = Mergepanel


/////////////////////////////////global panel Function ////////////////////////////////////////



Threadsafe Function /Wave Merge_cube_thread(Eindex,basecube,cube,baseZF,ZF,linearflag,autoIntflag,ydirectionflag)
	Variable Eindex
	Wave basecube,cube
	Variable baseZF,ZF
	Variable linearflag
	Variable autoIntflag
	Variable ydirectionflag
	
	DFREF df=Getdatafolderdfr()
	
	DFREF newdf=NewFreeDataFolder() 
	
	SetDatafolder newDF
	
	Variable b_x0=M_x0(basecube)
	Variable b_x1=M_x1(basecube)
	Variable b_y0=M_y0(basecube)
	Variable b_y1=M_y1(basecube)
	Variable b_xn=dimsize(basecube,0)
	Variable b_yn=dimsize(basecube,1)
	
	Make /O/FREE /n=(b_xn,b_yn) basedata
	Setscale /I x,b_x0,b_x1,basedata
	Setscale /I y,b_y0,b_y1,basedata
	if (Eindex>(dimsize(basecube,2)-1))
		basedata=Nan//basecube[p][q][Eindex]
	else
		basedata=basecube[p][q][Eindex]
	endif
	Variable x0=M_x0(cube)
	Variable x1=M_x1(cube)
	Variable y0=M_y0(cube)
	Variable y1=M_y1(cube)
	Variable xn=dimsize(cube,0)
	Variable yn=dimsize(cube,1)
	
	Make /O/FREE /n=(xn,yn) data
	Setscale /I x,x0,x1,data
	Setscale /I y,y0,y1,data
	if (Eindex>(dimsize(cube,2)-1))
		data=Nan//basecube[p][q][Eindex]
	else
		data=cube[p][q][Eindex]
	endif
	Merge_Waves(basedata,data,baseZF,ZF,linearflag,autoIntflag,ydirectionflag)
	
	Wave Merge_results_temp
	SetDatafolder DF
	
	return Merge_results_temp
End

Function Merge_cube(basecube,cube,baseZF,ZF,linearflag,autoIntflag,ydirectionflag)
	Wave basecube,cube
	Variable baseZF,ZF
	Variable linearflag
	Variable autoIntflag
	Variable ydirectionflag
	
	
	Variable z00=M_Z0(basecube)
	Variable z01=M_Z1(basecube)
	Variable z10=M_Z0(cube)
	Variable z11=M_Z1(cube)
	
	if  ((z00!=z10)||(z01!=z11))
		Variable z0=max(z00,z10)
		variable z1=min(z01,z11)
		Variable dz=min(dimdelta(basecube,2),dimdelta(cube,2))
	

		Variable Enum=round((z1-z0)/dz)+1//dimsize(basecube,2)
	
		Make /o/FREE/n=(dimsize(basecube,0),dimsize(basecube,1),Enum) basecube_interp
		Make /o/FREE/n=(dimsize(cube,0),dimsize(cube,1),Enum) cube_interp
		copyscales /I basecube,basecube_interp
		copyscales /I cube,cube_interp
		 
		Setscale /P z, z0,dz,basecube_interp,cube_interp
		
		basecube_interp=basecube[p][q](z)
		cube_interp=cube[p][q](z)
		
	else
		Enum=dimsize(basecube,2)
		z0=z00
		z1=z01
		Duplicate /o/FREE basecube,basecube_interp
		Duplicate /o/FREE cube,cube_interp
	endif
	
	Make /o/WAVE /n=(Enum) Temp_merge_panel
	
	Multithread Temp_merge_panel=Merge_cube_thread(p,basecube_interp,cube_interp,baseZF,ZF,linearflag,autoIntflag,ydirectionflag)
	
	Wave Merge_results_temp=Temp_merge_panel[0]
	
	Variable x0=M_x0(Merge_results_temp)
	Variable x1=M_x1(Merge_results_temp)
	Variable y0=M_y0(Merge_results_temp)
	Variable y1=M_y1(Merge_results_temp)
	Variable xn=dimsize(Merge_results_temp,0)
	Variable yn=dimsize(Merge_results_temp,1)
	
	Make /o/n=(xn,yn,Enum) Merge_cube_temp
	Setscale /I x, x0,x1,Merge_cube_temp
	Setscale /I y,y0,y1,Merge_cube_temp
	Setscale /I z,z0,z1,Merge_cube_temp
	Variable Eindex=0
	do
		Wave Merge_results_temp=Temp_merge_panel[Eindex]
		Merge_cube_temp[][][Eindex]=Merge_results_temp[p][q]
		Eindex+=1
	while (Eindex<Enum)
End


Function Merge_waves_1D(basedata,data,baseZF,ZF,linearflag,autoIntflag,ydirectionflag)
	Wave basedata,data
	Variable baseZF,ZF
	Variable linearflag
	Variable autoIntflag
	Variable ydirectionflag

	Variable b_x0=M_x0(basedata)
	Variable b_x1=M_x1(basedata)
	Variable b_dx=dimdelta(basedata,0)
	Variable x0=M_x0(data)
	Variable x1=M_x1(data)
	Variable dx=dimdelta(data,0)
	
	Variable d_x0=min(b_x0,x0)
	Variable d_x1=max(b_x1,x1)
	Variable d_dx=min(b_dx,dx)
	
	Variable xn=round((d_x1-d_x0)/d_dx)+1
	
	make /o/n=(xn) Merge_results_temp
	Setscale /I x,d_x0,d_x1,Merge_results_temp
	
	
	Duplicate /o Merge_results_temp, Basedata_interp,data_interp,Basedata_mask,data_mask,Mergedata_Mask,crossdata_mask,temp_mergedata
		
	basedata_interp=((x<=b_x1)&&(x>=b_x0))?(basedata(x)):(nan)
	data_interp=((x<=x1)&&(x>=x0))?(data(x)):(nan)
	Basedata_mask=(numtype(basedata_interp)==2)?(0):(1)//((x<=b_x1)&&(x>=b_x0)&&(y<=b_y1)&&(y>=b_y0))?(1):(0)
	data_mask=(numtype(data_interp)==2)?(0):(1)//((x<=x1)&&(x>=x0)&&(y<=y1)&&(y>=y0))?(1):(0)

	Mergedata_mask=basedata_mask+data_mask
	
	crossdata_mask=(Mergedata_mask==2)?(1):(0)
	
	if (autoIntflag)
		
		temp_mergedata=crossdata_mask*basedata_interp
		temp_mergedata=(numtype(temp_mergedata)==2)?(0):(temp_mergedata)
		Variable baseZsum=sum(temp_mergedata)
		temp_mergedata=crossdata_mask*data_interp
		temp_mergedata=(numtype(temp_mergedata)==2)?(0):(temp_mergedata)
		Variable Zsum=sum(temp_mergedata)
		
		if (Zsum==0)
		//	doalert 0, "No overlap area, use old style"
			Basedata_interp*=baseZF
			data_interp*=ZF
			//Killwaves /Z Merge_results_temp, Basedata_interp,data_interp,Basedata_mask,data_mask,Mergedata_Mask,crossdata_mask,temp_mergedata
			//return 0
		else
			baseZF=1
			ZF=baseZsum/Zsum
			data_interp*=ZF
		endif
		
	else
		Basedata_interp*=baseZF
		data_interp*=ZF
	endif
	
	if (linearflag)

		make /o/n=(xn) crossdata_mask_DC_temp
			
		crossdata_mask_DC_temp=crossdata_mask[p]
		if (sum(crossdata_mask_DC_temp)>0)
			Variable leftedge=detect_merge_edge(crossdata_mask_DC_temp,1,0)
			Variable rightedge=detect_merge_edge(crossdata_mask_DC_temp,1,1)
			if (rightedge>leftedge)
				Basedata_mask[leftedge,rightedge]=1-(p-leftedge)/(rightedge-leftedge)
				data_mask[leftedge,rightedge]=(p-leftedge)/(rightedge-leftedge)
			else
				Basedata_mask[leftedge,rightedge]=1/2
				data_mask[leftedge,rightedge]=1/2
			endif
		endif
			

		Killwaves /Z crossdata_mask_DC_temp
		basedata_interp*=basedata_mask[p]
		data_interp*=data_mask[p]
		basedata_mask=(numtype(basedata_interp)==2)?(numtype(data_interp)):(basedata_interp)
		data_mask=(numtype(data_interp)==2)?(numtype(basedata_interp)):(data_interp)
		Merge_results_temp=((numtype(data_interp)==2)&&(numtype(basedata_interp)==2))?(Nan):(basedata_mask+data_mask)		
	else
		Basedata_mask=(crossdata_mask==1)?(1/2):(Basedata_mask)
		data_mask=(crossdata_mask==1)?(1/2):(data_mask)
		
		basedata_interp*=basedata_mask[p]
		data_interp*=data_mask[p]
		basedata_mask=(numtype(basedata_interp)==2)?(numtype(data_interp)):(basedata_interp)
		data_mask=(numtype(data_interp)==2)?(numtype(basedata_interp)):(data_interp)
		Merge_results_temp=((numtype(data_interp)==2)&&(numtype(basedata_interp)==2))?(Nan):(basedata_mask+data_mask)
	endif	
	
	Killwaves /Z Basedata_interp,data_interp,Basedata_mask,data_mask,Mergedata_Mask,crossdata_mask,temp_mergedata
		
	return 1
End
	
Threadsafe Function Merge_Waves(basedata,data,baseZF,ZF,linearflag,autoIntflag,ydirectionflag)
	Wave basedata,data
	Variable baseZF,ZF
	Variable linearflag
	Variable autoIntflag
	Variable ydirectionflag
	
	
	Variable b_x0=M_x0(basedata)
	Variable b_x1=M_x1(basedata)
	Variable b_y0=M_y0(basedata)
	Variable b_y1=M_y1(basedata)
	Variable b_dy=dimdelta(basedata,1)
	Variable b_dx=dimdelta(basedata,0)
	Variable x0=M_x0(data)
	Variable x1=M_x1(data)
	Variable y0=M_y0(data)
	Variable y1=M_y1(data)
	Variable dy=dimdelta(data,1)
	Variable dx=dimdelta(data,0)
	
	Variable d_x0=min(b_x0,x0)
	Variable d_x1=max(b_x1,x1)
	Variable d_dx=min(b_dx,dx)
	Variable d_y0=min(b_y0,y0)
	Variable d_y1=max(b_y1,y1)
	Variable d_dy=min(b_dy,dy)
	
	Variable xn=round((d_x1-d_x0)/d_dx)+1
	Variable yn=round((d_y1-d_y0)/d_dy)+1
	
	make /o/n=(xn,yn) Merge_results_temp
	Setscale /I x,d_x0,d_x1,Merge_results_temp
	Setscale /I y,d_y0,d_y1, Merge_results_temp
	
	Duplicate /o Merge_results_temp, Basedata_interp,data_interp,Basedata_mask,data_mask,Mergedata_Mask,crossdata_mask,temp_mergedata
		
	basedata_interp=((x<=b_x1)&&(x>=b_x0)&&(y<=b_y1)&&(y>=b_y0))?(basedata(x)(y)):(nan)
	data_interp=((x<=x1)&&(x>=x0)&&(y<=y1)&&(y>=y0))?(data(x)(y)):(nan)
	Basedata_mask=(numtype(Basedata_interp)==2)?(0):(1)//((x<=b_x1)&&(x>=b_x0)&&(y<=b_y1)&&(y>=b_y0))?(1):(0)
	data_mask=(numtype(data_interp)==2)?(0):(1)//((x<=x1)&&(x>=x0)&&(y<=y1)&&(y>=y0))?(1):(0)

	Mergedata_mask=basedata_mask+data_mask
	
	crossdata_mask=(Mergedata_mask==2)?(1):(0)
	
	if (autoIntflag)
		
		
		temp_mergedata=crossdata_mask*basedata_interp
		temp_mergedata=(numtype(temp_mergedata)==2)?(0):(temp_mergedata)
		Variable baseZsum=sum(temp_mergedata)
		temp_mergedata=crossdata_mask*data_interp
		temp_mergedata=(numtype(temp_mergedata)==2)?(0):(temp_mergedata)
		Variable Zsum=sum(temp_mergedata)
		
		
		if (Zsum==0)
		//	doalert 0, "No overlap area, use old style"
			Basedata_interp*=baseZF
			data_interp*=ZF
			//Killwaves /Z Merge_results_temp, Basedata_interp,data_interp,Basedata_mask,data_mask,Mergedata_Mask,crossdata_mask,temp_mergedata
			//return 0
		else
			baseZF=1
			ZF=baseZsum/Zsum
			data_interp*=ZF
		endif
		
	else
		Basedata_interp*=baseZF
		data_interp*=ZF
	endif
	
	if (linearflag)
		if (ydirectionflag)
			make /o/n=(yn) crossdata_mask_DC_temp
			Variable index,leftedge,rightedge
			do
				crossdata_mask_DC_temp=crossdata_mask[index][p]
				if (sum(crossdata_mask_DC_temp)>0)
					leftedge=detect_merge_edge(crossdata_mask_DC_temp,1,0)
					rightedge=detect_merge_edge(crossdata_mask_DC_temp,1,1)
					if (rightedge>leftedge)
						Basedata_mask[index][leftedge,rightedge]=1-(q-leftedge)/(rightedge-leftedge)
						data_mask[index][leftedge,rightedge]=(q-leftedge)/(rightedge-leftedge)
					else
						Basedata_mask[index][leftedge,rightedge]=1/2
						data_mask[index][leftedge,rightedge]=1/2
					endif
				endif
			index+=1
			while(index<xn)
		else
			make /o/n=(xn) crossdata_mask_DC_temp
			do
				crossdata_mask_DC_temp=crossdata_mask[p][index]
				if (sum(crossdata_mask_DC_temp)>0)
					leftedge=detect_merge_edge(crossdata_mask_DC_temp,1,0)
					rightedge=detect_merge_edge(crossdata_mask_DC_temp,1,1)
					if (rightedge>leftedge)
						Basedata_mask[leftedge,rightedge][index]=1-(p-leftedge)/(rightedge-leftedge)
						data_mask[leftedge,rightedge][index]=(p-leftedge)/(rightedge-leftedge)
					else
						Basedata_mask[leftedge,rightedge][index]=1/2
						data_mask[leftedge,rightedge][index]=1/2
					endif
				endif
			index+=1
			while(index<yn)
		endif
		Killwaves /Z crossdata_mask_DC_temp
		basedata_interp*=basedata_mask[p][q]
		data_interp*=data_mask[p][q]
		basedata_mask=(numtype(basedata_interp)==2)?(numtype(data_interp)):(basedata_interp)
		data_mask=(numtype(data_interp)==2)?(numtype(basedata_interp)):(data_interp)
		Merge_results_temp=((numtype(data_interp)==2)&&(numtype(basedata_interp)==2))?(Nan):(basedata_mask+data_mask)		
	else
		Basedata_mask=(crossdata_mask==1)?(1/2):(Basedata_mask)
		data_mask=(crossdata_mask==1)?(1/2):(data_mask)
		
		basedata_interp*=basedata_mask[p][q]
		data_interp*=data_mask[p][q]
		basedata_mask=(numtype(basedata_interp)==2)?(numtype(data_interp)):(basedata_interp)
		data_mask=(numtype(data_interp)==2)?(numtype(basedata_interp)):(data_interp)
		Merge_results_temp=((numtype(data_interp)==2)&&(numtype(basedata_interp)==2))?(Nan):(basedata_mask+data_mask)
	endif	
	
	Killwaves /Z Basedata_interp,data_interp,Basedata_mask,data_mask,Mergedata_Mask,crossdata_mask,temp_mergedata
		
	return 1
End

Threadsafe Function detect_merge_edge(data,value,directionflag)
	Wave data
	Variable value,directionflag
	Variable index
	if (directionflag==0)
		index=0
		do
			if (data[index]==value)
			return index
			endif
		index+=1
		while (index<numpnts(data))
	elseif (directionflag==1)
		index=numpnts(data)-1
		do
			if (data[index]==value)
			return index
			endif
		index-=1
		while (index>=0)
	endif
	
	return Nan
End

/////////////////////////////////static Function ////////////////////////////////////////




Function update_merge_selwave()
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_merge=$(DF_panel+":merge")
	SetActiveSubwindow $winname(0,65)
	SetDatafolder DFR_panel
	
	
	WAVE/T w_sourcePathes = DFR_panel:FitWavePath_list
	WAVE/T w_sourceNames = DFR_panel:FitWavename_list
	Wave/B w_sourceNamessel=DFR_panel:FitWaveName_list_sel
	
	Wave/T Mergelist=DFR_merge:Mergelist
	Wave/B Mergelist_sel=DFR_merge:Mergelist_sel
	
	Variable listboxnum=dimsize(w_sourceNames,0)
	redimension /n=((listboxnum),4) Mergelist,Mergelist_sel
	
	Variable index
	do 
		if (strlen(Mergelist[index][0])==0)
				Mergelist[index][1]="0"
				Mergelist[index][2]="0"
				Mergelist[index][3]="1"
				Mergelist_sel[index][0]=0
				Mergelist_sel[index][1,3]=2
		endif
		Mergelist[index][0]=w_sourceNames[index]
		index+=1
	while (index<listboxnum)
End



static Function Listbox_merge_update_Proc(ctrlName,row,col,event) : ListboxControl
	String ctrlName     // name of this control
	Variable row        // row if click in interior, -1 if click in title
	Variable col        // column number
	Variable event      // event code
	
	DFREF Df = getdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	SetDataFolder $DF_panel
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetDatafolder DFR_panel
	
	if (((event==1)||(event==4)||(event==5))&&(col==0))
	
		WAVE/t w_sourceNames=DFR_panel:FitWaveName_list//; WAVE/b w_sourceNamesSel
		Wave/T w_sourcePathes=DFR_panel:FitWavePath_list
		Wave/T w_sourcePathesX=DFR_panel:FitWavePathX_list
		
		NVAR gv_dimflag=DFR_panel:gv_dimflag
	
		SVAR topPath = DFR_common:gs_TopItemPath
		SVAR topXPath = DFR_common:gs_TopItemPathX
		SVAR topName = DFR_common:gs_TopItemName
		NVAR topwaverow=DFR_common:gv_topwaverow
		
		Variable toprow=row
		
		//String DFList=FoldertoList(root:spectra,"*",0)
		//DFlist=removeStringfromlist(DFlist,"root:spectra:",";",0)
		//if (strlen(gs_DFlist)<2)
		//gs_DFlist="process:;gold:;"
		//else
		//gs_DFlist="process:;gold:;"+DFlist
		//endif
		
		topwaverow=toprow
		Wave /Z Data=$ w_sourcePathes[toprow]
		topPath = GetWavesDataFolder(Data, 2 )
		
		Wave /Z xdata=$w_sourcePathesX[toprow]
		if (waveexists(xdata))
			topXPath= w_sourcePathesX[toprow]
		else
			topXPath=""
		endif
		
		topName = w_sourceNames[toprow]//StringFromList(0,nList)
				
							
		update_select_data(gv_dimflag)
	//	panelimageupdate(-1)
		
	endif
	if (event==7)
		update_merge_wave(ctrlname)
	endif
	
	SetDatafolder DF
	
	return 0            // other return values reserved
End



static Function plot_merge_wave(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	
	
	
	NVAR gv_dimflag=DFR_panel:gv_dimflag
	
	SetDatafolder DFR_panel
	
	String MergeDataname="Merge"
	prompt MergeDataname, "Input a wave name:"
	doprompt "Plot the Mergedata", MergeDataname
	
	if (V_flag==1)
		SetDatafolder DF
		return 0
	endif
	
	if (gv_dimflag==2)
		Wave w_image=DFR_common:w_image
	
		duplicate /o w_image, $MergeDataname
	else
		Wave w_trace=DFR_common:w_trace
		duplicate /o w_trace, $MergeDataname
	endif
	
	Wave Data=$MergeDataname
	display_wave(Data,0,1)
	Killwaves /Z Data
	
	SetDatafolder DF

End

static Function update_merge_wave(ctrlname)
	String ctrlname
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_merge=$(DF_panel+":merge")
	
	SetActiveSubwindow $winname(0,65)
	
	SetDatafolder DFR_panel
	
	WAVE/T w_sourcePathes = DFR_panel:FitWavePath_list
	WAVE/T w_sourceNames = DFR_panel:FitWavename_list
	
	NVAR gv_dimflag=DFR_panel:gv_dimflag
	//Wave/B w_sourceNamessel=DFR_panel:MergeWaveName_list_sel
	
	Wave/T Mergelist=DFR_merge:Mergelist
	
	
	
	NVAR gv_autogridflag=DFR_merge:gv_autogridflag
	
	NVAR gv_linearflag=DFR_merge:gv_linearflag
	NVAR gv_autoIntflag=DFR_merge:gv_autoIntflag
	NVAR gv_ydirectionflag=DFR_merge:gv_ydirectionflag
	
	NVAR gv_y0=DFR_merge:gv_y0
	NVAR gv_y1=DFR_merge:gv_y1
	NVAR gv_dy=DFR_merge:gv_dy
	NVAR gv_x0=DFR_merge:gv_x0
	NVAR gv_x1=DFR_merge:gv_x1
	NVAR gv_dx=DFR_merge:gv_dx
	
	Variable wavenum=numpnts(w_sourcePathes)
	
	if (wavenum<2)
		SetDatafolder dF
		return 0
	endif
	
	Make /o/n=(wavenum) Merge_x0,Merge_x1,Merge_y0,Merge_y1,Merge_dx,Merge_dy,Merge_Zfactor
	
	Variable index,temp
	do
		Wave data=$w_sourcePathes[index]
		Merge_x0[index]=M_x0(data)
		Merge_x1[index]=M_x1(data)
		Merge_dx[index]=dimdelta(data,0)
		Merge_y0[index]=M_y0(data)
		Merge_y1[index]=M_y1(data)
		Merge_dy[index]=dimdelta(data,1)
		
		temp=str2num(Mergelist[index][1])
		if (numtype(temp)==2)
			doalert 0,"Invalid offset values!"
			SetDatafolder DF
			return 0
		else
			Merge_x0[index]+=temp
			Merge_x1[index]+=temp
		endif
		temp=str2num(Mergelist[index][2])
		if (numtype(temp)==2)
			doalert 0,"Invalid offset values!"
			SetDatafolder DF
			return 0
		else
			Merge_y0[index]+=temp
			Merge_y1[index]+=temp
		endif
		
		temp=str2num(Mergelist[index][3])
		if (numtype(temp)==2)
			doalert 0,"Invalid offset values!"
			SetDatafolder DF
			return 0
		else
			Merge_Zfactor[index]=temp
		endif
		
		index+=1
	while (index<wavenum)
	
	Duplicate /o/t w_sourcePathes,w_sourcePathes_sort
	
	NVAR gv_ydirectionflag=DFR_panel:gv_ydirectionflag
		
	if (gv_ydirectionflag)
		sort /A Merge_y0,Merge_x0,Merge_x1,Merge_dx,Merge_y0,Merge_y1,Merge_dy,Merge_Zfactor,w_sourcePathes_sort
	else
		sort /A Merge_x0,Merge_x0,Merge_x1,Merge_dx,Merge_y0,Merge_y1,Merge_dy,Merge_Zfactor,w_sourcePathes_sort
	endif
	
	if (gv_autogridflag)
		gv_x0=wavemin(Merge_x0)
		gv_x1=wavemax(Merge_x1)
		gv_dx=wavemin(Merge_dx)
		gv_y0=wavemin(Merge_y0)
		gv_y1=wavemax(Merge_y1)
		gv_dy=wavemin(Merge_dy)
	endif
	
	if (gv_dimflag==2) //image
		Wave w_image=DFR_common:w_image
		
		Wave basedata=$w_sourcePathes_sort[0]
		duplicate /o basedata Merge_basedata_temp
		Setscale /I x,Merge_x0[0],Merge_x1[0],Merge_basedata_temp
		Setscale /I y,Merge_y0[0],Merge_y1[0],Merge_basedata_temp
		Variable baseZF=Merge_Zfactor[0]
		Variable ZF
	
		String notestr=note(basedata)
		//notestr=GetLayernotestr(notestr,0,3)
		Variable xn=round((gv_x1-gv_x0)/gv_dx)+1
		Variable yn=round((gv_y1-gv_y0)/gv_dy)+1
	
		make /o/n=(xn,yn) Merge_results
		Setscale /I x,gv_x0,gv_x1,Merge_results
		Setscale /I y,gv_y0,gv_y1, Merge_results
		gv_dx=dimdelta(Merge_results,0)
		gv_dy=dimdelta(Merge_results,1)
	
		index=1
		do
			Wave Merge_basedata_temp
			Wave data=$w_sourcePathes_sort[index]
			duplicate /o data, Merge_data_temp
			Setscale /I x,Merge_x0[index],Merge_x1[index],Merge_data_temp
			Setscale /I y,Merge_y0[index],Merge_y1[index],Merge_data_temp
			ZF=Merge_Zfactor[index]
		
			if (Merge_waves(Merge_basedata_temp,Merge_data_temp,baseZF,ZF,gv_linearflag,gv_autoIntflag,gv_ydirectionflag)==0)
				SetDatafolder DF
				return 0
			endif
		
			Wave Merge_results_temp
		
			duplicate /o Merge_results_temp Merge_basedata_temp
		
			index+=1
		while (index<wavenum)
	
		Wave Merge_results_temp
		Merge_results=interp2D(Merge_results_temp,x,y)
	
		duplicate /o Merge_results,w_image
		note w_image,notestr
	else
		Wave w_trace=DFR_common:w_trace
		
		Wave basedata=$w_sourcePathes_sort[0]
		duplicate /o basedata Merge_basedata_temp
		Setscale /I x,Merge_x0[0],Merge_x1[0],Merge_basedata_temp
		//Setscale /I y,Merge_y0[0],Merge_y1[0],Merge_basedata_temp
		baseZF=Merge_Zfactor[0]
	
		notestr=note(basedata)
		//notestr=GetLayernotestr(notestr,0,3)
		xn=round((gv_x1-gv_x0)/gv_dx)+1
		//Variable yn=round((gv_y1-gv_y0)/gv_dy)+1
	
		make /o/n=(xn) Merge_results
		Setscale /I x,gv_x0,gv_x1,Merge_results
		//Setscale /I y,gv_y0,gv_y1, Merge_results
		gv_dx=dimdelta(Merge_results,0)
		//gv_dy=dimdelta(Merge_results,1)
	
		index=1
		do
			Wave Merge_basedata_temp
			Wave data=$w_sourcePathes_sort[index]
			duplicate /o data, Merge_data_temp
			Setscale /I x,Merge_x0[index],Merge_x1[index],Merge_data_temp
			//Setscale /I y,Merge_y0[index],Merge_y1[index],Merge_data_temp
			ZF=Merge_Zfactor[index]
			
		
			if (Merge_waves_1D(Merge_basedata_temp,Merge_data_temp,baseZF,ZF,gv_linearflag,gv_autoIntflag,gv_ydirectionflag)==0)
				SetDatafolder DF
				return 0
			endif
		
			Wave Merge_results_temp
		
			duplicate /o Merge_results_temp Merge_basedata_temp
		
			index+=1
		while (index<wavenum)
	
		Wave Merge_results_temp
		Merge_results=Merge_results_temp(x)
	
		duplicate /o Merge_results,w_trace
		note w_trace,notestr
	
	
	endif
	
	
	Killwaves /Z Merge_x0,Merge_x1,Merge_y0,Merge_y1,Merge_dx,Merge_dy,Merge_Zfactor,Merge_results_temp,Merge_results,Merge_data_temp,Merge_basedata_temp
	SetDatafolder DF
end









