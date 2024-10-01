#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 0.01

// dim is the remaining dimension. Creates the wave 'w_avg' containing the mean values

// simpler version of M_xScale()
Threadsafe Function M_x0(w)
	Wave w
		return DimOffset(w, 0)
End
Threadsafe Function M_x1(w)
	Wave w
		return DimOffset(w, 0) + (dimsize(w,0)-1) *DimDelta(w,0)
End
Threadsafe Function M_y0(w)
	Wave w
		return DimOffset(w, 1)
End
Threadsafe Function M_y1(w)
	Wave w
		return DimOffset(w, 1) + (dimsize(w,1)-1) *DimDelta(w,1)
End


Threadsafe Function M_z0(w)
	Wave w
		return DimOffset(w, 2)
End
Threadsafe Function M_z1(w)
	Wave w
		return DimOffset(w, 2) + (dimsize(w,2)-1) *DimDelta(w,2)
End

Function x2pntsmult(data,value,dim)
	wave data
	Variable value,dim
	
	Variable pnts= round((value-dimoffset(data,dim))/dimdelta(data,dim))
	pnts=(pnts<0)?(0):(pnts)
	pnts=(pnts>(dimsize(data,dim)-1))?(dimsize(data,dim)-1):(pnts)
	return pnts
End


Function My_wavemin(data)
	wave data
	duplicate /o/Free data,datamin
	datamin=(numtype(datamin)==2)?(1e10):(datamin)
	return wavemin(datamin)
End

Function My_wavemax(data)
	wave data
	duplicate /o/Free data,datamax
	datamax=(numtype(datamax)==2)?(-1e10):(datamax)
	return wavemax(datamax)
End

Function M_avg_subRange(w,dim,xy0,xy1)
	WAVE w
	Variable dim, xy0,xy1
	
	Variable pnt2 = dimsize(w,abs(dim-1))
	Variable pnt = dimsize(w,dim)
	
	Variable sf = dimoffset(w,dim)
	Variable st = dimoffset(w,dim) + (dimsize(w,dim)-1)*dimdelta(w,dim)
	Variable DC_sf = dimoffset(w,abs(dim-1))
	Variable DC_st = dimoffset(w,abs(dim-1)) + (dimsize(w,abs(dim-1))-1)*dimdelta(w,abs(dim-1))
	Make/O/N=(pnt) w_avg
	SetScale/I x sf,st,"", w_avg
	Make/O/N=(pnt2) w_DC
	SetScale/I x DC_sf,DC_st,"", w_DC
	
	if (dim == 0)		// 'e-average'
	Variable index = 0
		do
			w_DC = w[index][p]
			w_avg[index] = mean(w_DC,xy0,xy1)
			//print w_avg[index]
		index += 1
		while (index < pnt)
	endif
	
	if (dim == 1)		// 'k-average'
	index = 0
		do
			w_DC = w[p][index]
			w_avg[index] = mean(w_DC,xy0,xy1)
		index += 1
		while (index < pnt)
	endif
	KillWaves/Z w_DC
End

// dim is the collapsing dimension. Creates the wave 'w_avg' containing the mean values
Function M_avg(w,dim)
	WAVE w
	Variable dim
	
	//Variable TimerRefNum = StartMSTimer
	//Variable microseconds
	
	Variable pnt2 = dimsize(w,abs(dim-1))
	Variable pnt = dimsize(w,dim)
	
	Variable sf = dimoffset(w,dim)
	Variable st = dimoffset(w,dim) + (dimsize(w,dim)-1)*dimdelta(w,dim)
	Variable DC_sf = dimoffset(w,abs(dim-1))
	Variable DC_st = dimoffset(w,abs(dim-1)) + (dimsize(w,abs(dim-1))-1)*dimdelta(w,abs(dim-1))
	Make/O/N=(pnt) w_avg
	SetScale/I x sf,st,"", w_avg
	Make/O/N=(pnt2) w_DC
	SetScale/I x DC_sf,DC_st,"", w_DC
		
	if (dim == 0)		// 'k-average'
	Variable index = 0
		do
			w_DC = w[index][p]
			w_avg[index] = mean(w_DC,-inf,inf)
		index += 1
		while (index < pnt)
	endif
	
	if (dim == 1)		// 'e-average'
	index = 0
		do
			w_DC = w[p][index]
			w_avg[index] = mean(w_DC,-inf,inf)
		index += 1
		while (index < pnt)
	endif
	
	KillWaves/Z w_DC
	//microseconds = StopMSTimer(timerRefNum)
	//Print microSeconds, "microseconds"
End


Function M_smooth_times_fast(image,dim,pnts,times)
	Wave image 
	Variable dim
	Variable pnts,times
	
	Duplicate /o/Free Image,Image_zero
	Multithread Image_zero=(numtype(image)==2)?(0):(image)
	Variable ii=0
	if (times<=0)
	return 1
	endif
	do
		smooth /Dim=(dim)/F pnts,Image_zero 
	ii += 1
	while(ii < times)
	Multithread image=(numtype(image)==2)?(Nan):(image_zero)
End


Function M_smooth_times(image,dim,pnts,times)
	Wave image 
	Variable dim
	Variable pnts,times
	
	Duplicate /o/Free Image,Image_zero
	Multithread Image_zero=(numtype(image)==2)?(0):(image)
	Variable ii=0
	if (times<=0)
	return 1
	endif
	do
		smooth /Dim=(dim) pnts,Image_zero 
	ii += 1
	while(ii < times)
	Multithread image=(numtype(image)==2)?(Nan):(image_zero)
End


Function M_smooth_x(M)
	WAVE M
	
	Duplicate/o M M_s
	Make/o/n=(dimsize(M,0)) cut
	
	Variable ii=0
	do
		cut = M[p][ii]
		smooth/E=3 2,  cut
		
		M_s[][ii] = cut[p]
	ii += 1
	while(ii < dimsize(M,1))

End



Threadsafe Function wave_mindelta(data_O)
	Wave data_O
	Variable w_dc=inf
	duplicate /o/FREE data_O data
	sort /A data_O,data
	Variable index=0
	do 
		if ((abs(data[index+1]-data[index])<w_dc)&&(abs(data[index+1]-data[index])>1e-5))
			w_dc=abs(data[index+1]-data[index])
		endif
	index+=1
	while (index<(numpnts(data)-1))
	return w_dc
End


Function Make_tri_wave2D(xwave,ywave,zwave)
Wave xwave,ywave,zwave
Variable xn=dimsize(xwave,0)
Variable yn=dimsize(xwave,1)
Make /o/n=((xn*yn),3) Triwave
Variable xindex,yindex,index
xindex=0
index=0
do
	yindex=0
	do
	Triwave[index][0]=xwave[xindex][yindex]
	Triwave[index][1]=ywave[xindex][yindex]
	Triwave[index][2]=zwave[xindex][yindex]
	index+=1
	yindex+=1
	while (yindex<yn)
xindex+=1
while (xindex<xn)

End


Function rotate_2D(wx,wy,angle)
	WAVE wx,wy; Variable angle
	
	duplicate/o wx t_wx
	duplicate/o wy t_wy
	t_wx = cos(angle*pi/180)*wx - sin(angle*pi/180)*wy
	t_wy = sin(angle*pi/180)*wx + cos(angle*pi/180)*wy
	wx=t_wx
	wy=t_wy
End




Function CheckWavemono(data)
	Wave data
	Variable index
	Variable Set=0
	do
		if (abs(set)==1)
			if (set==1)
				if (data[index+1]<data[index])
					return 0
				endif
			elseif (set==-1)
				if (data[index+1]>data[index])
					return 0
				endif
			endif
		else
			if (data[index+1]>data[index])
				Set=1
			endif
	
			if (data[index+1]<data[index])
				Set=-1
			endif
		endif
		index+=1
	while (index<(numpnts(data)-1))
	return 1

End

Function /S FormatanglefromWave(data,x0,x1)
	Wave data
	Variable x0,x1
	Variable index,endindex,startindex
	startindex=(numtype(x0)==2)?(0):(x0)
	endindex=(numtype(x1)==2)?(numpnts(data)):(x1+1)
	
	String returnstr=""
	if (numpnts(data)>1)
		index=startindex
		do
			returnstr+=num2str(data[index])+";"
			
			index+=1
		while (index<endindex)	
		return returnstr
	else
		return num2str(data[0])
	endif
End



Function CheckReturnWaveequal(data,x0,x1)
	Wave data
	Variable x0,x1
	Variable index,endindex,startindex
	startindex=(numtype(x0)==2)?(0):(x0)
	endindex=(numtype(x1)==2)?(numpnts(data)):(x1+1)
	
	Variable tempx
	
	if (numpnts(data)>1)
   		index=startindex
   		tempx=data[index]
		do
			if (tempx!=data[index])
				return Nan
			endif
			index+=1
		while (index<endindex)
		return tempx
	else
		tempx=data[0]
		return tempx
	endif
	
End

Function /S CheckReturnStringequal(data,x0,x1)
	Wave /T data
	Variable x0,x1
	Variable index,endindex,startindex
	startindex=(numtype(x0)==2)?(0):(x0)
	endindex=(numtype(x1)==2)?(numpnts(data)):(x1+1)
	
	String tempx
		
	if (numpnts(data)>1)
 	 	index=startindex
 	 	tempx=data[index]
		do
			if (stringmatch(tempx,data[index])==0)
				return ""
			endif
			index+=1
		while (index<endindex)
		return tempx
	else
		tempx=data[index]
		return tempx
	endif

End



// kill all waves that match a BaseName
Function KillWaves_withBase(baseName)
	String baseName
	
	String str0 = Wavelist(baseName,",","")
	String str1 = str0[0,strlen(str0)-2]
	
	if (strlen(str1) > 0)
		execute "KillWaves/Z "+str1
	endif
End


Function Cal_colorwave_from_Image(Image,Colortabstr,alphascale,gammascale,dimflag)
	Wave image
	String colortabstr
	Variable alphascale
	Variable gammascale
	Variable dimflag
	
	Variable xn=dimsize(image,0)
	Variable yn=dimsize(image,1)
	String colorname=nameofwave(image)+"_Color"
	
	Make /o/n=(xn,yn,dimflag) $colorname
	Wave colorwave= $colorname
	
	WaveStats /Q image
	Variable from,to,reverseflag
	String colortablename
	Variable temp,temp1
	String tempstr
	temp=strsearch(Colortabstr,"{",0)
	temp1=strsearch(Colortabstr,",",temp)
	tempstr=Colortabstr[temp+1,temp1-1]
	if (grepstring(tempstr,"\*"))
		from=V_min
	else
		sscanf tempstr,"%g",from
	endif
	temp=temp1+1
	temp1=strsearch(Colortabstr,",",temp)
	tempstr=Colortabstr[temp,temp1-1]
	if (grepstring(tempstr,"\*"))
		to=V_max
	else
	 	sscanf tempstr,"%g",to
	endif
	temp=temp1+1
	temp1=strsearch(Colortabstr,",",temp)
	tempstr=Colortabstr[temp,temp1-1]
	colortablename=tempstr//CTabList()
	temp=temp1+1
	temp1=inf
	tempstr=Colortabstr[temp,temp1]
	sscanf tempstr,"%g",reverseflag
	
	ColorTab2Wave $colortablename
	
	Wave M_colors
	
	
	Make /o/n=(dimsize(M_colors,0)) M_Colors_r,M_Colors_x
	//duplicate /o /R=[][0] M_colors M_Colors_r,M_Colors_x
	
	
	if (reverseflag)
		Setscale /I x, to,from,M_Colors_r,M_Colors_x
	else
		Setscale /I x, from,to,M_Colors_r,M_Colors_x
	endif
	
	
	M_Colors_x=x
	
	Make /o/n=100,Gamma_line
	Setscale /I x, 0,1,gamma_Line
	
	Gamma_line=my_gamma(x,0,1,0,1,gammascale)
	
	Duplicate /o image,image_proc,image_sub
	Multithread image_sub=(image[p][q]-V_min)/(V_max-V_min)
	image_Sub=(image_sub>1)?(1):(image_sub)
	image_sub=(image_sub<0)?(0):(image_sub)
	image_sub=(numtype(image_sub)==2)?(0):(image_sub)
	
	Multithread image_proc=(V_max-V_min)*gamma_line(image_sub[p][q])+V_min
	
	Variable index=0
	do
		M_Colors_r=M_colors[p][index]/65535
		Multithread colorwave[][][index]=interp(image_proc[p][q],M_Colors_x,M_Colors_r)
		index+=1
	while (index<3)
	
	
	if (dimflag==4)
		colorwave[][][3]=alphascale
		//colorwave[][][]=(numtype(image[p][q])==2)?(Nan):(colorwave)
		//colorwave[][][3]=(numtype(image[p][q])==2)?(0):(colorwave)
	endif
	
	
	
	Killwaves /Z Image_proc,gamma_line,M_colors,M_colors_x,M_colors_r
//	65535
	
End