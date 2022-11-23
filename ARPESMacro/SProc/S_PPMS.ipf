#pragma rtGlobals=1		// Use modern global access method.

///////////////////////////////////////////////////Load Files/////////////////////////////////////////////////////
Function BeforeFileOpenHook(refNum,fileName,path,type,creator,kind)
	Variable refNum,kind
	String fileName,path,type,creator
	Variable handledOpen=0
//	if( CmpStr(type,"TEXT")==0 ) // text files only
//		String line1, line2
//		FReadLine refNum, line1 // First line (and carriage return)
//		FReadLine refNum, line2
//		if(StringMatch(line1,"[Header]*")==1)
//			if( StringMatch(line2,"*AC Transport Data File*") == 1 ) // My special file
//				FSetPos refNum, 0 // rewind to start of file
				handledOpen= Load_PPMS_ACT_File(fileName,path,refNum) // returns 1 if loaded OK
//			endif
//		endif
//	endif
	return handledOpen // 1 tells Igor not to open the file
End

Function Load_PPMS_ACT_File(fileName,path,refNum)
	String fileName
	String path
	Variable refNum
	String line
	
	print "Loading " + fileName
	DFREF DFR = GetDataFolderDFR()
	setDataFolder root:
	String folderName =fileName[0,strlen(fileName)-5]
	folderName= CleanupName(folderName,0)
	newdatafolder/o/s $folderName
	
//	String wavenote=""
//	do
//		FReadLine refNum, line
//	while(StringMatch(line,"[Header]*")==0)
//	do
//		FReadLine refNum, line
//		if(StringMatch(line,"[Data]*"))
//			break
//		endif
//		wavenote+=line
//	while(1)
	
	//FReadLine refNum, line

	//LoadWave/G/M/Q/O/A=MM /P=$path fileName
	String nameList=""
	String nameString
	Variable index=0
	line="temp,amp,phase"
	do
		nameString=StringFromList(index,line,",")
		if(strlen(nameString)==0)
			break
		endif
		nameString=CleanupName(nameString,0)
		if(stringmatch(nameString,"Comment"))
			Make/o/T/n=100000 $nameString
		else
			Make/o/n=1000000 $nameString=Nan
		endif
		namelist+=nameString+";"
		index+=1
	while(1)
	
	Variable colNum=0
	Variable rawNum=0
	String commentstring
	do
		FReadLine refNum, line
		if(strlen(line)==0)
			break
		endif
		
//		wave/T Comment
//		
//		commentstring = StringFromList(0,line,",")
//		if(strlen(commentstring)!=0)
//			print "raw " + num2str(rawNum)+" : " + commentstring
//		endif
//		
//		Comment[rawNum]=commentstring
		
		do
			nameString=StringFromList(colNum, namelist, ";")
			if(strlen(nameString)==0)
				break
			endif
			wave data=$nameString
			data[rawNum]=Str2Num(StringFromList(colNum, line, ","))
			colNum+=1
		while(1)
		
		colNum=0
		rawNum+=1
		
	while(1)
	Close refNum
	
	//Redimension /N=(rawNum) comment
	//note comment,wavenote
		
	do
		nameString=StringFromList(colNum, namelist, ";")
		if(strlen(nameString)==0)
			break
		endif
		wave data=$nameString
		Redimension /N=(rawNum) data
		//note data, wavenote
		if(numtype(wavemax(data))==2)
			killwaves/z data
		endif
		colNum+=1
	while(1)
	
	//no need to keep comment
	killwaves/z Comment
	
	Display amp vs temp; AppendToGraph/R phase vs temp
	ModifyGraph rgb(phase)=(1,16019,65535)
	Label left "Signal Amplitude (Arb. Units)";DelayUpdate
       Label bottom "Temperature (K)";DelayUpdate
       Label right "Signal Phase (Degree)"
	TextBox/C/N=text0/F=0/A=MC filename
	SetDataFolder DFR
	Print "File Loaded."
	return 1
End
///////////////////////////////////////////////////////////////////////////////////////////////////Load Files ///


/////////////////////////////////////////////////////GUI main////////////////////////////////////////////////////////
Function initialize_S_PPMS()
	string df=getdatafolder(1)
	newdatafolder/o/s internalUse
	make/o x_wave
	make/o y_wave
	make/o w_foldernamesSel
	make/o/T w_foldernames
	make/o/T w_datanames
	
	string folderlist= Get_Data_Folder_List()
	list2wave(folderlist,"root:internalUse:w_foldernames")
	wave/T w_foldernames=  root:internalUse:w_foldernames
	redimension/n=(numpnts(w_foldernames)) root:internalUse:w_foldernamesSel
	
	newdatafolder/o/s cutdata
	string/G newfoldername
	variable/G startpoint
	variable/G endpoint
	
	setdatafolder $df
end
	


Function PPMS_Data_Browser()
	initialize_S_PPMS()
	Dowindow/K mainpanel
	Display/W=(200,0,750,450) as "PPMS Data Browser"
	DoWindow/C mainpanel
	variable r=60000
	variable g=60000
	variable b=60000
	Controlbar 275
	TabControl MainPanelTab, labelBack=(r,g,b), pos={0,0}, size={1000,280}, tabLabel(0)="Data Selection", proc=MainPanelTabProc
	Groupbox Box_selectdatafolder, pos={5,20}, size={405,114}, title="Select Data Folder",labelBack=(r,g,b)
	Listbox select_data_folder, pos={9,35}, size={397,95}, listwave=root:internalUse:w_foldernames, selwave=root:internalUse:w_foldernamesSel, frame=2,mode=9, proc=data_source_proc
	Groupbox Box_selectxdata, pos={5,140}, size={200,130}, title="Select x Data",labelBack=(r,g,b)
	Listbox select_x_data, pos={9,155}, size={191,111}, listwave=root:internalUse:w_datanames, frame=2, mode=2, proc=data_source_proc
	Groupbox Box_selectydata, pos={210,140}, size={200,130}, title="Select y Data",labelBack=(r,g,b)
	Listbox select_y_data, pos={214,155}, size={191,111},listwave=root:internalUse:w_datanames, frame=2, mode=2, proc=data_source_proc
	
	Groupbox extractdata, title="Extract Data",labelBack=(r,g,b),size={235,114},pos={440,20}
	setvariable new_folder_name title="Subfolder Name", pos={450,40}, size={210,20}, value=root:internalUse:cutdata:newfoldername
	setvariable data_start_point title="From Point",pos={450,75}, size={150,20}, value=root:internalUse:cutdata:startpoint
	setvariable data_end_point title="To Point  ",pos={450,110}, size={150,20}, value=root:internalUse:cutdata:endpoint
	button data_cut title="Cut", pos={610,75}, size={50,50}, proc=cut_data
	button showdata,title="Show Data Table", size={150,30},pos={450,150}, proc=table_selected_data
	button closedata,title="Close Data Table", size={150,30},pos={450,190}, proc=close_DataTable
	
	//
	TabControl MainPanelTab, tabLabel(1)="tbd",proc=MainPanelTabProc
	Button tbd1,disable=1
	
	AppendToGraph/Q  root:internalUse:y_wave vs root:internalUse:x_wave
	ModifyGraph axisEnab(left)={0,1},axisEnab(bottom)={0,0.5}	
	
end

Function MainPanelTabProc(name,tab)
	String name
	Variable tab

	Groupbox Box_selectdatafolder,disable= (tab!=0)
	Listbox select_data_folder,disable= (tab!=0)
	Groupbox Box_selectxdata,disable= (tab!=0)
	Listbox select_x_data,disable= (tab!=0)
	Groupbox Box_selectydata,disable= (tab!=0)
	Listbox select_y_data,disable= (tab!=0)
	Groupbox extractdata, disable= (tab!=0)
	setvariable new_folder_name, disable= (tab!=0)
	setvariable data_start_point, disable= (tab!=0)
	setvariable data_end_point, disable= (tab!=0)
	button data_cut, disable= (tab!=0)
	button showdata, disable= (tab!=0)
	button closedata, disable= (tab!=0)
	
	
	Button tbd1,disable= (tab!=1)
	
End

Function cut_data(ctrlName) : ButtonControl
	String ctrlName
	
	string df=getdatafolder(1)
	
	SVAR name=root:internalUse:cutdata:newfoldername
	NVAR from=root:internalUse:cutdata:startpoint
	NVAR to=root:internalUse:cutdata:endpoint
	
	wave/T w_foldernames= root:internalUse:w_foldernames
	wave w_foldernamesSel= root:internalUse:w_foldernamesSel
	if(sum(w_foldernamesSel)==0)
		return 0
	endif
	variable index=0
	do
		if(w_foldernamesSel[index]!=0)
			break
		endif
		index+=1
	while(1)
	string folder=w_foldernames[index]

	wave/T datanames=root:internalUse:w_datanames
	controlinfo select_x_data
	wave x_wave=$(folder+datanames[v_value])
	controlinfo select_y_data
	wave y_wave=$(folder+datanames[v_value])
	string x_subwavename=nameofwave(x_wave)
	string y_subwavename=nameofwave(y_wave)
	
	variable tail=strsearch(folder,":",inf,1)
	folder=folder[0,tail-1]
	tail=strsearch(folder,":",inf,1)
	folder=folder[0,tail]
	
	setdatafolder $folder
	newdatafolder/o/s $name
	duplicate/o/R=[from,to] x_wave $x_subwavename
	duplicate/o/R=[from,to] y_wave $y_subwavename
	
	variable j=0
	wave xwave=$x_subwavename
	wave ywave=$y_subwavename
	do
		if(numtype(ywave[j])==2)
			deletepoints j,1,xwave
			deletepoints j,1,ywave
		else
			j+=1
		endif
	while(j<numpnts(ywave))
	
	setdatafolder $df
End

Function close_DataTable(ctrlname): ButtonControl
	string ctrlname
	dowindow/K DataTable
end


Function table_selected_data(ctrlname): ButtonControl
	string ctrlname
	wave xwave=Get_selected_wave("x")
	wave ywave=Get_selected_wave("y")
	string existingtables=WinList("*", ";","WIN:2")
	
	if(FindListItem("DataTable", existingtables)!=-1)
		appendtotable/W=DataTable xwave,ywave
	else
		edit/N=DataTable xwave,ywave
	endif
End

Function data_source_proc(ctrlName,row,col,event) : ListboxControl
	String ctrlName     // name of this control
	Variable row        // row if click in interior, -1 if click in title
	Variable col        // column number
	Variable event      // event code
	string folderlist=Get_Data_Folder_List()
	string folderlist_2 = SortList(folderlist)	
	list2wave(folderlist_2, "root:internalUse:w_foldernames")
	wave/T w_foldernames= root:internalUse:w_foldernames
	wave w_foldernamesSel= root:internalUse:w_foldernamesSel
	redimension/n=(numpnts(w_foldernames)) w_foldernamesSel
	if(sum(w_foldernamesSel)==0)
		return 0
	endif
	variable index=0
	do
		if(w_foldernamesSel[index]!=0)
			break
		endif
		index+=1
	while(1)
	string folder=w_foldernames[index]
	string datalist=Get_Wave_List(folder)
	list2wave(datalist, "root:internalUse:w_datanames")
	wave/T datanames=root:internalUse:w_datanames
	if(numpnts(datanames)==2)
		if(stringmatch(ctrlname,"select_x_data"))
			controlinfo select_x_data
			listbox select_y_data selRow= (1-v_value)
		endif
	endif
	
	controlinfo select_x_data
	wave x_wave=$(folder+datanames[v_value])
	controlinfo select_y_data
	wave y_wave=$(folder+datanames[v_value])
	
	SVAR name=root:internalUse:cutdata:newfoldername
	name=nameofwave(y_wave)[0,2]+"_vs_"+nameofwave(x_wave)[0,2]
	
	duplicate/o x_wave root:internalUse:x_wave
	duplicate/o y_wave root:internalUse:y_wave
	
	variable j=0
	wave xwave=root:internalUse:x_wave
	wave ywave=root:internalUse:y_wave
	do
		if((numtype(ywave[j])==2)||(numtype(xwave[j])==2))
			deletepoints j,1,xwave
			deletepoints j,1,ywave
		else
			j+=1
		endif
	while(j<numpnts(ywave))
	
	return 0            // other return values reserved
End

///////////////////////////////////////////////////////////////////////////////////////////////////GUI main//////


/////////////////////////////////////////////////////////GUI support/////////////////////////////////////////////////////
Function list2wave(list, w_name)
	string list
	string w_name
	variable num=itemsinlist(list)
	make/n=(num)/T/o $w_name
	wave/T w=$w_name
	redimension/n=(num) w
	variable index
	for(index=0;index<num;index+=1)
		w[index]=stringfromlist(index,list)
	endfor
end

Function/T Get_Wave_List(folder)
	string folder
	string objName
	string list=""
	variable index=0
	do
		objName=GetIndexedObjName(folder,1,index)
		if(strlen(objName)==0)
			break
		endif
		list+=objName+";"
		index+=1
	while(1)
	return list
End


Function/T Get_Data_Folder_List()

	string datafolders=""
	string name0,name1,name2,name3,name4,name5,name6
	variable i0,i1,i2,i3,i4,i5
	
	
	name0 = "root:"
	if(ContainWavesOrNot(name0))
		datafolders+=name0+";"
	endif
	i0=0
	do
		name1 = GetIndexedObjName(name0, 4, i0)
		if(strlen(name1)==0)
			break
		endif
		
		name1 = name0+name1+":"
		if(ContainWavesOrNot(name1))
			datafolders+=name1+";"
		endif
				i1=0
				do
					name2 = GetIndexedObjName(name1, 4, i1)
					if(strlen(name2)==0)
						break
					endif
		
					name2 = name1+name2+":"
					if(ContainWavesOrNot(name2))
						datafolders+=name2+";"
					endif
					
						i2=0
						do
							name3 = GetIndexedObjName(name2, 4, i2)
							if(strlen(name3)==0)
								break
							endif
		
							name3 = name2+name3+":"
							if(ContainWavesOrNot(name3))
								datafolders+=name3+";"
							endif
								i3=0
								do
									name4 = GetIndexedObjName(name3, 4, i3)
									if(strlen(name4)==0)
										break
									endif
									name4 = name3+name4+":"
									if(ContainWavesOrNot(name4))
										datafolders+=name4+";"
									endif
										i4=0
										do
											name5 = GetIndexedObjName(name4, 4, i4)
											if(strlen(name5)==0)
												break
											endif
											name5 = name4+name5+":"
											if(ContainWavesOrNot(name5))
												datafolders+=name5+";"
											endif
												i5=0
												do
													name6 = GetIndexedObjName(name5, 4, i5)
													if(strlen(name6)==0)
														break
													endif
													name6 = name5+name6+":"
													if(ContainWavesOrNot(name6))
														datafolders+=name6+";"
													endif	
													i5+=1
												while(1)
										i4+=1
									while(1)
									i3+=1
								while(1)
							i2+=1
						while(1)
					i1+=1
				while(1)
		i0+=1
	while(1)
	return datafolders
End

Function ContainWavesOrNot(foldername)
	string foldername
	if(stringmatch(foldername,"*internalUse*"))
		return 0
	endif
	String objname=GetIndexedObjName(foldername,1,0)
	if(Strlen(objname)==0)
		return 0
	else
		return 1
	endif
end

Function/WAVE Get_Selected_wave(xory)
	string xory
	wave/T w_foldernames= root:internalUse:w_foldernames
	wave w_foldernamesSel= root:internalUse:w_foldernamesSel
	variable index=0
	do
		if(w_foldernamesSel[index]!=0)
			break
		endif
		index+=1
	while(index<(numpnts(w_foldernamesSel)+1))
	string folder=w_foldernames[index]

	wave/T datanames=root:internalUse:w_datanames
	if(stringmatch(xory,"x"))
		controlinfo select_x_data
		wave re_wave=$(folder+datanames[v_value])
	else
		controlinfo select_y_data
		wave re_wave=$(folder+datanames[v_value])
	endif
	
	return re_wave
end

//////////////////////////////////////////////////////////////////////////////////////////////////GUI support//////////////////////////////////
///ÕÒÕâÀï
/////////////////////////////calculation///////////////////////////////////////////////////////////////////////////////////////
Function Get_InverseB_Wave(RvB,fromT,toT,smoothfactor,point)
	wave RvB
	variable fromT
	variable toT
	variable smoothfactor
	variable point
	
	string name="s"+num2str(smoothfactor)+"f"+num2str(fromT)
	newdatafolder/o/s $name
	name="Res_"+name
	Duplicate/O RvB,$name
	wave smoothedwave=$name
	if(smoothfactor!=0)
	Smooth smoothfactor, smoothedwave
	endif
	
	
	Duplicate/D smoothedwave,$(nameofwave(smoothedwave)+"_res")
	variable from,to
	wave residual_wave=$(nameofwave(smoothedwave)+"_res")
	from=x2pnt(smoothedwave,fromT*10000)
	to=x2pnt(smoothedwave,toT*10000)
	CurveFit/Q/NTHR=0/TBOX=768 poly 3,  smoothedwave[from,to] /D /R=residual_wave
	
	
	name=nameofwave(residual_wave)+"_interp"
	make/o/n=4096 $name
	wave interpw=$name
	setscale/I x,1/toT,1/fromT,"",interpw
	duplicate/o residual_wave residual_wave_x
	residual_wave_x[]=x
	interpw[]=interp(10000/x, residual_wave_x,residual_wave)
	name=nameofwave(interpw)+"_fft"
	FFT/OUT=3/PAD={4096}/WINF=Hanning/DEST=$name interpw
end


///////////////////////////////////////////////////////////////Redundancy///////////////////////////////////////////////////////////
//======================================================================

//======================================================================
//	wave T = Temperature__K_
//	wave M = Magnetic_Field__Oe_
//	wave P = Sample_Position__deg_
//	
//	variable cutparaT,cutparaM, cutparaP
//	string cutlist=""
//	for(index=1;index<rawNum-1;index+=1)
//		cutparaT=(T[index+1]-T[index]+1e-2)/(T[index]-T[index-1]+1e-2)
//		cutparaM=(M[index+1]-M[index]+1e-3)/(M[index]-M[index-1]+1e-3)
//		cutparaP=(P[index+1]-P[index]+1e-3)/(P[index]-P[index-1]+1e-3)
//		if((cutparaT<0.1)||(cutparaM<0)||(cutparaP<0)||(cutparaT>10)||(cutparaM>10)||(cutparaP>10))
//			cutlist+=num2str(index)+";"
//		endif
//	endfor
//	print cutlist
//	variable cutpnt1=0, cutpnt2=0
//	variable testpnt
//	variable vsT=1
//	variable vsB=1
//	variable vsA=1
//	string vspara
//	string subfoldername
//	index=0
//	do
//		cutpnt2=str2num(stringfromlist(index,cutlist,";"))
//		if(numtype(cutpnt2)==2)
//			break
//		endif
//		testpnt=round(cutpnt1+cutpnt2)/2
//		if(T[testpnt]-T[testpnt-1]>0.1)
//			vspara="vsTemperature_"+num2str(vsT)
//			vsT+=1
//		elseif(M[testpnt]-M[testpnt-1]>3)
//			vspara="vsField_"+num2str(vsB)
//			vsB+=1
//		else
//			vspara="vsAngle_"+num2str(vsA)
//			vsA+=1
//		endif
//		subfoldername="root:"+foldername+":"+vspara
//		newdatafolder/o $subfoldername
//		//duplicate
//		
//	index+=1
//	while(1)