#pragma rtGlobals=3		// Use modern global access method and strict wave access.

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
				handledOpen= Load_PPMS_File(fileName,path,refNum) // returns 1 if loaded OK
//			endif
//		endif
//	endif
	return handledOpen // 1 tells Igor not to open the file
End

Function Load_PPMS_File(fileName,path,refNum)
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
	
	String wavenote=""
	do
		FReadLine refNum, line
	while(StringMatch(line,"[Header]*")==0)
	do
		FReadLine refNum, line
		if(StringMatch(line,"[Data]*"))
			break
		endif
		wavenote+=line
	while(1)
	
	FReadLine refNum, line
	
	String nameList=""
	String nameString
	Variable index=0
	do
		nameString=StringFromList(index,line,",")
		if(strlen(nameString)==0)
			break
		endif
		nameString=CleanupName(nameString,0)
		//print nameString +"\r"
		if(stringmatch(nameString,"Comment"))
			Make/o/T/n=100000 $nameString
		else
			Make/o/n=100000 $nameString=Nan
		endif
		namelist+=nameString+";"
		index+=1
	while(1)
	
	Variable colNum=1
	Variable rawNum=0
	do
		FReadLine refNum, line
		if(strlen(line)==0)
			break
		endif	
		do
			nameString=StringFromList(colNum, namelist, ";")
			if(strlen(nameString)==0)
				break
			endif
			wave data=$nameString
			data[rawNum]=Str2Num(StringFromList(colNum, line, ","))
			colNum+=1
		while(1)
		
		colNum=1
		rawNum+=1
		
	while(1)
	Close refNum
	
	colNum=1
		
		//print namelist

	do
		nameString=StringFromList(colNum, namelist, ";")
		if(strlen(nameString)==0)
			break
		endif
		
		wave data=$nameString
		Redimension /N=(rawNum) data
		
		colNum+=1
	while(1)
	
		
	killwaves/z Comment
	
	colNum=1
	
	do
		nameString=StringFromList(colNum, namelist, ";")
		if(strlen(nameString)==0)
			break
		endif
		
		wave data=$nameString
		
		if(numtype(wavemax(data))==2)
			killwaves/z data
		endif
		colNum+=1
	while(1)

	return 1
End