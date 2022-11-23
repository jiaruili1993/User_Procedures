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
				handledOpen= Load_Raman_File(fileName,path,refNum) // returns 1 if loaded OK
//			endif
//		endif
//	endif
	return handledOpen // 1 tells Igor not to open the file
End

Function Load_Raman_File(fileName,path,refNum)
	String fileName
	String path
	Variable refNum
	String line
	
	print "Loading " + fileName
	DFREF DFR = GetDataFolderDFR()
	setDataFolder root:
	String curvename =fileName[0,6]+fileName[strlen(fileName)-12,strlen(fileName)-5]
	curvename= CleanupName(curvename,0)
	
	
	String wavenote=""
	do
		FReadLine refNum, line
	while(StringMatch(line,"#*")==1)
	
	make/o/n=5000 $(curvename+"_x"), $(curvename+"_y")
	wave xwave=$(curvename+"_x")
	wave ywave=$(curvename+"_y")
	
	Variable rawNum=0
	string foo
	do
		
		if(strlen(line)==0)
			break
		endif
		
		line=ReplaceString("\r",line,"")
		xwave[rawNum]=str2num(StringFromList(0,line,"\t"))
		foo=stringfromlist(1, line, "\t")
		ywave[rawNum]=str2num(foo)
		
		rawNum+=1
		
		FReadLine refNum, line
	while(1)
	Close refNum
	
	redimension/N=(rawNum) xwave, ywave
	return 1
End