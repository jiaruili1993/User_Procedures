#pragma rtGlobals=1		// Use modern global access method.

Function /S removeSpace(DataS)
	String DataS
	String SS=""
	String SumS=""
	Variable index=0
	if (strlen(DataS)==0)
		return ""
	endif
	do
		SS=DataS[index]
		if (cmpstr(SS," ")==0)
		else
		SumS+=SS
		endif
	index+=1
	while (index<strlen(DataS))
	return SumS
end

Function /S checkwavename(wname,flag)
	String wname
	variable flag
	Variable slen=strlen(wname)
	
	String newWname
	if (slen>32)
		if (flag==0)
				Variable temppos=strsearch(wname,"_e_",0)
				if (temppos==-1)
					temppos=strsearch(wname,"_m_",0)
					if (temppos==-1)
						return wname[0,31]
					endif
				endif
				String basename=wname[0,temppos-1]
				String addname=wname[temppos,inf]
				newWname=cleanupname(basename[strlen(basename)-5,strlen(basename)-1]+addname,0)
			return newWname
		else
			return wname[0,31]
		endif
	else
		return wname
	endif
end

Function/S num2indstr(n,strnum)
	variable n
	Variable strnum
	string s="0000"+num2str(n)
	variable l=strlen(s)-1
	return s[l-strnum+1,l]
End


Function /S returnGraphlist_dim(list,dim)
	String list
	Variable dim
	
	if (strlen(list)==0)
		return list
	endif
	
	Variable index
	String graphname,graphlist,tracelist
	graphlist=""
	do
		graphname=stringfromlist(index,list,";")
		if (dim==1)
			tracelist=tracenamelist(graphname,";",1)
		else
			tracelist=imagenamelist(graphname,";")
		endif
		if (strlen(tracelist)>0)
			graphlist+=graphname+";"
		endif
		index+=1
	while (index<itemsinlist(list,";"))
	
	return graphlist
End

Function/S DotReplace(str)	
	String str
	
	Variable length = strlen(str)
	Variable pnt = 0, strange
	do
		strange = 0
		strange += stringmatch(str[pnt],".")
		strange += stringmatch(str[pnt],"-")
		strange += stringmatch(str[pnt]," ")
		if (strange >= 1)
			str = str[0,pnt-1]+"_"+str[pnt+1,inf]
		endif
	pnt += 1	
	while(pnt < length)	
	
	return str
End

Function/S noSpace(str)	
	String str
	
	Variable length = strlen(str)
	Variable pnt = 0
	do
		if (stringmatch(str[pnt]," "))
			str = str[-inf,pnt-1]+str[pnt+1,inf]
			length -= 1
		else
			pnt += 1
		endif	
	while(pnt < length)	
	
	return str
End

// reduce a StringList to items matching to 'matchStr'

Function /s match_WaveList(matchStr,List,separator)
	String matchStr,List,separator
	
	String item, mList=""
	if (strlen(separator)==0)
		separator = ";"
	endif
	
	Variable index = 0
	do
		item = StringFromList(index,List,separator)
		if (strlen(item)==0)
			break
		endif
		Wave /z data=$item
		if(stringmatch(nameofwave(data), matchStr))
			mList += item+separator 
		endif
	index += 1
	while(1)
	
	return mList[0,strlen(mList)-strlen(separator)-1]
end
Function/S match_StringList(matchStr,List,separator)
	String matchStr,List,separator
	
	String item, mList=""
	if (strlen(separator)==0)
		separator = ";"
	endif
	
	Variable index = 0
	do
		item = StringFromList(index,List,separator)
		if (strlen(item)==0)
			break
		endif
		if(stringmatch(item, matchStr))
			mList += item+separator 
		endif
	index += 1
	while(1)
	
	return mList[0,strlen(mList)-strlen(separator)-1]
End

// returns 1 if all items in the list are identical. Used to check consistency of wave-notes			FB 11/07/03
Function ConstantStringList(list)
	String list
	
	Variable n = itemsinlist(list)
	if (n == 1)
		return 1
	endif
	
	Variable index = 0
	
	String item0, item1
	do
		item0 = StringFromList(index,list)
		item1 = StringFromList(index+1,list)
		if(stringmatch(item0,item1) !=1)
			return 0
		endif
	index += 1
	while(index < n-1)
	
	return 1
End

// returns 1 if all items in the list are identical with 'match'. Used to check consistency of wave-notes			FB 19/07/03
Function ConstantStringListMatch(list,match,separator)
	String list, match, separator
	
	if (strlen(separator) == 0)
		separator = ";"
	endif
	
	Variable n = itemsinlist(list)
	Variable index = 0
	
	String item0
	do
		item0 = StringFromList(index,list)
		if(stringmatch(item0,match) !=1)
			return 0
		endif
	index += 1
	while(index < n)
	
	return 1
End

// returns '1' if guess is identical to at least one item of the (semicolon separated) list
// modified to recognize "" as a valid entry		FB 11/07/03
Function string_List_check(guess,List,separator)
	String guess, List, separator
	
	if (strlen(separator) == 0)
		separator = ";"
	endif

	String item
	Variable n = itemsinlist(List)
	
	Variable counter = 0
	do
		item = StringFromList(counter, List,separator)
		if(stringmatch(item,guess))
			return 1
		endif
	counter += 1
	while (counter < n)
	
	return 0
End


Function SearchNumInWave(data,value)
Wave data
Variable value
	Variable index=0
	
	do
	if (data[index]==value)
		return index
	endif
	index+=1
	while (index<(numpnts(data)))
	return -1
End


Function SearchStringInWave(data,sstring)
	Wave /T data
	String sstring
	Variable index=0
	
	do
	if (stringmatch(data[index],sstring)==1)
	return index
	endif
	index+=1
	while (index<(numpnts(data)))
	return -1
End

// replace all NaN's in a wave with any number
Function replace_NaNs(w,value)
	WAVE w;Variable value
	
	Wavestats/Q w
	if (v_numNaNs == 0)
		return 0
	else
		w = ((w/w) ==1)?(w):value
	endif
//	Variable index = 0
//	do
//		if (stringmatch(num2str(w[index]),"NaN"))
//			w[index]=value
//		endif
//	index += 1
//	while (index < numpnts(w))
End



Function AppendstringtoList_norepeat(List,wavepath,sortopt,norepeat)
	WAVE/T List
	string wavepath
	Variable sortopt
	Variable norepeat
	
	
	String strlist=WaveToStringlist(List,";",Nan,Nan)
	
	//if (strlen(wavepath)==0)
		
	
	if (norepeat)
		if (FindListItem(wavepath,strlist,";",0)<0)
			strlist=AddListItem(wavepath,strlist,";",inf)
			SListToWave(strList,sortopt,";",Nan,Nan)
			Wave /T w_StringList
			duplicate /o /T w_Stringlist, List
			Killwaves /Z w_Stringlist
			return 1
		else
			return 0
		endif
	else
		strlist=AddListItem(wavepath,strlist,";",inf)
		SListToWave(strList,sortopt,";",Nan,Nan)
		Wave /T w_StringList
		duplicate /o /T w_Stringlist, List
		Killwaves /Z w_Stringlist
		return 1
	endif
End

Function RemovestringfromList_norepeat(List,wavepath,sortopt)
	WAVE/T List
	string wavepath
	Variable sortopt

	String strlist=WaveToStringlist(List,";",Nan,Nan)

	if (FindListItem(wavepath,strlist,";",0)<0)
		return Nan
	else
		Variable removeindex=WhichListItem(wavepath,strlist,";",0)
		strlist=RemoveFromList(wavepath,strlist,";")
		SListToWave(strList,sortopt,";",Nan,Nan)
		Wave /T w_StringList
		duplicate /o /T w_Stringlist, List
		Killwaves /Z w_Stringlist
		return removeindex
	endif

End


Function/S WaveToStringList(w,sep,from,to)
	WAVE/T w
	String sep
	Variable from,to
	
	from=(numtype(from)==2)?(0):(from)
	to=(numtype(to)==2)?(numpnts(w)):(to+1)
	
	String List=""
	Variable index = from
	if (numpnts(w)>0)
		do
			List += w[index]+sep
			index += 1
		while (index <to)
		return List
	else
		return ""
	endif
End

Function/S NumericWaveToStringList(w,sep,from,to)
	WAVE w
	String sep
	Variable from,to
	
	from=(numtype(from)==2)?(0):(from)
	to=(numtype(to)==2)?(numpnts(w)):(to+1)
	
	String List=""
	Variable index =from
	if (numpnts(w)>0)
		do
			List += num2str(w[index])+sep
			index += 1
		while (index <to)
		return List
	else
		return ""
	endif
End


Function /Wave StringListToNumWave(List,sortopt,sep,from,to)
	String list
	Variable sortopt
	
	String sep
	Variable from,to
	Variable num = itemsinlist(list)
	from=(numtype(from)==2)?(0):(from)
	to=(numtype(to)==2)?(num):(to+1)
	
	Make/FREE/n=(to-from)/o w_NumberList
	String item
	Variable index = from
	Variable itemnum
	do
		item = Stringfromlist(index,list,sep)
		sscanf item,"%f",itemnum
		w_NumberList[index-from]=itemnum
	index += 1
	while (index < to)
	if (sortopt)
		sort /A w_NumberList w_NumberList
	endif
	return w_NumberList
End



Function SListToWave(List,sortopt,sep,from,to)
	String list
	Variable sortopt
	
	String sep
	Variable from,to
	Variable num = itemsinlist(list,sep)
	from=(numtype(from)==2)?(0):(from)
	to=(numtype(to)==2)?(num):(to+1)
	
	
	Make/n=(to-from)/o/t w_StringList
	String item
	Variable index = from
	do
		item = stringfromlist(index,list,sep)
		w_StringList[index-from]=item
		index += 1
	while (index < to)
	if (sortopt)
		sort /A w_StringList w_StringList
	endif
End

Function numberbykey_reverse(keystr,liststr,sepstr,endstr)
	String keystr,liststr,sepstr,endstr

	Variable temp1,temp2
	temp1=inf
	do
		temp1=strsearch(liststr,keystr,temp1,1)
		if (temp1==-1)
			return Nan
		else
			String tempstr
			tempstr=liststr[temp1,inf]
			Variable tempval= numberbykey(keystr,tempstr,sepstr,endstr)
			if (numtype(tempval)!=2)
				return tempval
			else
				temp1-=1
			endif
		endif
	while (1)
End


Function /S removeStringfromlist(list,matchstring,sepstr,flag)
	String list,matchstring,sepstr
	Variable flag
	if (flag)
		return removefromlist(matchstring,list,sepstr)
	else
		String itemstring,removestring,listr=""
		Variable index=0
		do
			itemstring=stringfromlist(index,list,sepstr)
			if (strlen(itemstring)==0)
				break
			endif
			if (strsearch(itemstring,matchstring,0)>=0)
				if (strsearch(itemstring,matchstring,0)>0)
					removestring=itemstring[0,strsearch(itemstring,matchstring,0)-1]+itemstring[strsearch(itemstring,matchstring,0)+strlen(matchstring),inf]
				else
					removestring=itemstring[strsearch(itemstring,matchstring,0)+strlen(matchstring),inf]
				endif
				if (strlen(removestring)>0)
					listr+=removestring+sepstr
				endif
			else
				listr+=itemstring+sepstr
			endif
		index+=1
		while (1)
		return listr
endif

End


Function/S FoldertoList(in_DF,match,dim)
	DFREF in_DF
	String match
	Variable dim

	String list="", item=""
	Variable index=0
	Variable DF_num=CountObjectsDFR(in_DF, 4)
	
	
	String DF_name
	DFREF DF_temp
   	do
	if (index>=DF_num)
	break
	endif
	DF_name=GetIndexedObjNameDFR(in_Df, 4, index)
	if ((stringmatch(DF_name,match)==0)||(stringmatch(DF_name,"Packages")==1))
		index+=1
		continue
	endif
	item=GetDatafolder(1,in_DF)+DF_name
	DF_temp=$item
	
	List+=FoldertoList(DF_temp,match,dim)
	//if (strlen(item)>0)
	//	List+=item
   //endif
	index+=1
	while (index<DF_num)
	setDatafolder in_DF
	if (dim==0)
		item=GetDatafolder(0,in_DF)
		if (is_liberal(item))
		DoAlert 0, "Sorry, "+item+" is no a legal DF name.\rPlease rename the folder!"
		else
		list+=GetDatafolder(1,in_DF)+";"
		endif
	return list
	else
		if (strlen(wavelist("*",";","DIMS:"+num2str(dim))) == 0)
			return list
		else
			item=GetDatafolder(0,in_DF)
			if (is_liberal(item))
			DoAlert 0, "Sorry, "+item+" is no a legal DF name.\rPlease rename the folder!"
			else
			list+=GetDatafolder(1,in_DF)+";"
			endif
		return list
		endif	
	endif
End

Function text_to_FP_wave(wt)
	WAVE/t wt
	
	Make/o/n=(numpnts(wt)) FP_wave
	String str
	
	Variable index = 0
	do
		str = wt[index]
		FP_wave[index] = str2num(str)	
	index += 1
	while (index < numpnts(wt))
End

Function/S waves_path_List(in_DF,match,dim)
	String in_DF, match;Variable dim
	
	if (!stringmatch(in_DF[strlen(in_DF)-1],":" ) )
		in_DF += ":"
	endif
	
	String fList = FoldertoList(in_DF,match,dim)
	String path_list=""
	String folder,name,  w_list
	
	Variable items = ItemsInList(fList)
	Variable ii = 0
	Variable jj = 0
	
	SetDataFolder $in_DF
		w_list = wavelist("*",";","DIMS:2")
		jj = 0
		do
			name = StringFromList(jj, w_list)
			if (strlen(name)>0)
				path_list += in_DF+name+";"
			endif
		jj+=1
		while (jj < itemsinlist(w_list))
		
	jj = 0
	do
		folder = StringFromList(ii,fList)
		if (strlen(folder) ==0)
			break
		else
			SetDataFolder $folder
			w_list = wavelist("*",";","DIMS:2")
			jj = 0
			do
				name = StringFromList(jj, w_list)
				if (strlen(name) == 0)
					break
				else
					path_list += folder+name+";"
				endif
			jj+=1
			while (1)
		endif
		
	ii += 1
	while (ii < items)
	
	return path_list
End	



Function is_liberal(name)
	String name
	return stringmatch(PossiblyQuoteName(name), name) == 0
End