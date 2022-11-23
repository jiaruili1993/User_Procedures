#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version = 0.01
#pragma ModuleName = SelfEnergy


////Bare band function
////Panel control


static Function proc_ck_changedim(ctrlname,value)
	String ctrlname
	variable value
	
	String name_panel=winname(0,65)
	
	Variable ckvalue
	
	strswitch(ctrlname)
		case "RealSelf_fnck0":
			String curTabMatch= "RealSelf_fn"+"*"
			String controlsInATab= ControlNameList(name_panel,";","*_*")
			String controlsInCurTab= ListMatch(controlsInATab, curTabMatch)
			curTabMatch= "RealSelf_wv"+"*"
			String controlsInOtherTabs= ListMatch(controlsInATab, curTabMatch)
			ModifyControlList  controlsInOtherTabs win=$name_panel,disable=2	// hide
			ModifyControlList  controlsInCurTab win=$name_panel,disable=0
			ckvalue=1		
			break
		case "RealSelf_wvck0":
			curTabMatch= "RealSelf_wv"+"*"
			controlsInATab= ControlNameList(name_panel,";","*_*")
			controlsInCurTab= ListMatch(controlsInATab, curTabMatch)
			curTabMatch= "RealSelf_fn"+"*"
			controlsInOtherTabs= ListMatch(controlsInATab, curTabMatch)
			ModifyControlList  controlsInOtherTabs win=$name_panel,disable=2	// hide
			ModifyControlList  controlsInCurTab win=$name_panel,disable=0
			ckvalue=2
			break
	endswitch

	checkbox RealSelf_fnck0,value=ckvalue==1,disable=0
	checkbox RealSelf_wvck0,value=ckvalue==2,disable=0
End

static Function proc_initial_coefwave()
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$(DF_panel)
	DFREF DFR_selfE=$(DF_panel+":SelfEnergy")
	
	Wave /T coeflist=DFR_selfE:selfE_bareband_coeflist
	Wave /B coefsel=DFR_selfE:selfE_bareband_coef_sel
	
	
	Wave w_sourceNamesSel=DFR_panel:FitWaveName_list_sel//DFR_common:w_sourceNamesSel
	Wave /T w_sourceNames=DFR_panel:FitWaveName_list//DFR_common:w_sourceNames
	Wave /T w_sourcePathes=DFR_panel:FitWavePath_list//DFR_common:w_sourcePathes
	
	if (dimsize(w_sourceNames,0)>0)
		redimension /n=(dimsize(w_sourceNames,0),-1),coeflist,coefsel
		coefsel[][1,dimsize(coefsel,1)-1]=2
		coefsel[][0]=0
		
		variable index=0
		do
			String savename=w_sourceNames[index]
			coeflist[index][0]=savename[strlen(savename)-5,strlen(savename)-1]
			index+=1
		while (index<dimsize(w_sourceNames,0))
	endif
	
end

static Function proc_pp_selectfn(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_selfE=$(DF_panel+":SelfEnergy")
	
	Wave /T titlewave2=DFR_selfE:w_title2
	
	//Wave /T pointlist=DFR_selfE:selfE_bareband_pointlist
	//Wave /B pointsel=DFR_selfE:selfE_bareband_point_sel
	Wave /T coeflist=DFR_selfE:selfE_bareband_coeflist
	Wave /B coefsel=DFR_selfE:selfE_bareband_coef_sel
	
	Variable functionflag=popnum
	
	switch(functionflag)
		case 1:
			//redimension /n=(2,-1) pointlist,pointsel
			redimension /n=(-1,3) coeflist,coefsel
			//pointsel=2
			coefsel[][1,dimsize(coefsel,1)-1]=2
			coefsel[][0]=0
			redimension /n=(3) titlewave2
			titlewave2={"Name","Constant","A"}
			break
		case 2:
			//redimension /n=(3,-1) pointlist,pointsel
			redimension /n=(-1,4) coeflist,coefsel
			//pointsel=2
			coefsel[][1,dimsize(coefsel,1)-1]=2
			coefsel[][0]=0
			redimension /n=(4) titlewave2
			titlewave2={"Name","Constant","A","x0"}
			break
		case 3:
			//redimension /n=(2,-1) pointlist,pointsel
			redimension /n=(-1,5) coeflist,coefsel
			//pointsel=2
			coefsel[][1,dimsize(coefsel,1)-1]=2
			coefsel[][0]=0
			redimension /n=(5) titlewave2
			titlewave2={"Name","Constant","A","Gap","kF"}
			break
		case 4:
			//redimension /n=(3,-1) pointlist,pointsel
			redimension /n=(-1,6) coeflist,coefsel
			//pointsel=2
			coefsel[][1,dimsize(coefsel,1)-1]=2
			coefsel[][0]=0
			redimension /n=(6) titlewave2
			titlewave2={"Name","Constant","A","x0","Gap","kF"}
			break
	endswitch
	
	
End



static Function proc_bt_readcsr(ctrlname)
	String ctrlname
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_selfE=$(DF_panel+":SelfEnergy")
	DFREF DFR_common= $(DF_panel+":panel_common")
	
	Wave /T pointlist=DFR_selfE:selfE_bareband_pointlist
	Wave /B pointsel=DFR_selfE:selfE_bareband_point_sel
	Wave /T coeflist=DFR_selfE:selfE_bareband_coeflist
	Wave /B coefsel=DFR_selfE:selfE_bareband_coef_sel
	
	
	controlinfo RealSelf_fnlb0
	pointlist[v_Value][0]=num2str(hcsr(B))
	pointlist[v_Value][1]=num2str(vcsr(B))
	
	
End

static Function proc_bt_fitbareband(ctrlname)
	String ctrlname
	
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$(DF_panel)
	DFREF DFR_selfE=$(DF_panel+":SelfEnergy")
	DFREF DFR_common= $(DF_panel+":panel_common")
	
	Wave /T coeflist=DFR_selfE:selfE_bareband_coeflist
	Wave /B coefsel=DFR_selfE:selfE_bareband_coef_sel
	
	Wave /B w_sourceNamesSel=DFR_panel:FitWaveName_list_sel
	
	controlinfo RealSelf_fnpp0
	Variable functionflag=v_value
	
	Variable selrow=return_selected(w_sourceNamesSel,0)
	
	if (stringmatch(ctrlname, "Realself_fnbt2"))
		if ((functionflag==3)||(functionflag==4))
			coeflist[][1,dimsize(coeflist,1)-3]=coeflist[selrow][q]
			coeflist[][dimsize(coeflist,1)-1]=coeflist[selrow][q]
		else
			coeflist[][1,dimsize(coeflist,1)-1]=coeflist[selrow][q]
		endif
		SetDatafolder DF
		return 0
	endif
	
	Make /o/Free/n=(2) wave_X,wave_Y
	
	controlinfo RealSelf_ck0
	if (v_value)
		wave_y[0]=hcsr(B)//str2num(pointlist[p][0])
		wave_x[0]=vcsr(B)//str2num(pointlist[p][1])
		wave_y[1]=hcsr(A)//str2num(pointlist[p][0])
		wave_x[1]=vcsr(A)//str2num(pointlist[p][1])
	else
		wave_y[0]=vcsr(B)//str2num(pointlist[p][0])
		wave_x[0]=hcsr(B)//str2num(pointlist[p][1])
		wave_y[1]=vcsr(A)//str2num(pointlist[p][0])
		wave_x[1]=hcsr(A)//str2num(pointlist[p][1])
	endif
	SetDatafolder DFR_selfE
	
	
	
	
	
	switch(functionflag)
		case 1:	
			Make /o/n=2 w_coef
			w_coef=0
			CurveFit /Q line, kwCWave=w_coef,wave_Y /X=wave_x
			Wave w_coef
			coeflist[selrow][1,2]=num2str(w_coef[q-1])
			break
		case 2:
			Make /o/n=3 w_coef
			w_coef=0
			CurveFit /Q /H="010" poly 3, kwCWave=w_coef,wave_Y /X=wave_x
			Wave w_coef
			coeflist[selrow][2]=num2str(w_coef[2])
			coeflist[selrow][3]=num2str(w_coef[1]/(-2*w_coef[2]))
			coeflist[selrow][1]=num2str(w_coef[0]-w_coef[2]*str2num(coeflist[2])^2)
			break
		case 3:	
			Make /o/n=2 w_coef
			w_coef=0
			CurveFit /Q line, kwCWave=w_coef,wave_Y /X=wave_x
			Wave w_coef
			coeflist[selrow][1,2]=num2str(w_coef[q-1])
			coeflist[selrow][3,4]="0"
			break
		case 4:
			Make /o/n=3 w_coef
			w_coef=0
			CurveFit /Q /H="010" poly 3, kwCWave=w_coef,wave_Y /X=wave_x
			Wave w_coef
			//print w_coef
			coeflist[selrow][2]=num2str(w_coef[2])
			coeflist[selrow][3]=num2str(w_coef[1]/(-2*w_coef[2]))
			coeflist[selrow][1]=num2str(w_coef[0]-w_coef[2]*str2num(coeflist[selrow][3])^2)
			coeflist[selrow][4,5]="0"
			//print coeflist[selrow][2]
			break
	endswitch

	
	SetDatafolder DF
end

static Function proc_bt_updatebareband(ctrlname)
	String ctrlname
	
	strswitch (ctrlname)
		case "Realself_fnbt0":
			update_barebands(1)
			break
		case "Realself_fnbt1":
			update_barebands(0)
			break
	endswitch
	
End

static Function proc_lb_changecoef(ctrlName,row,col,event) : ListboxControl
	String ctrlName     // name of this control
	Variable row        // row if click in interior, -1 if click in title
	Variable col        // column number
	Variable event      // event code
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_selfE=$(DF_panel+":SelfEnergy")
	DFREF DFR_common= $(DF_panel+":panel_common")
	
	Wave /Z w_bareband=DFR_common:w_bareband
	
	if (event==7)
		CheckDisplayed /w=$winname(0,65) w_bareband
		if (v_flag!=0)
			update_barebands(1)
		endif
	endif
	
End

Function update_barebands(ctrlflag)
	Variable ctrlflag
	
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_selfE=$(DF_panel+":SelfEnergy")
	DFREF DFR_common= $(DF_panel+":panel_common")
	
	Wave /T coeflist=DFR_selfE:selfE_bareband_coeflist
	Wave /B coefsel=DFR_selfE:selfE_bareband_coef_sel
	
	Wave /B w_sourceNamesSel=DFR_panel:FitWaveName_list_sel
	
	Variable selrow=return_selected(w_sourceNamesSel,0)
	
	controlinfo RealSelf_fnpp0
	Variable functionflag=v_value
	controlinfo RealSelf_ck0
	Variable vertflag=v_value
	
	Wave w_trace=DFR_common:w_trace
	
	SetDatafolder DFR_common
	Make /o/n=(1000) w_bareband
	if (vertflag)
		Setscale /I x,wavemin(w_trace),wavemax(w_trace),w_bareband
	else
		Setscale /I x, leftx(w_trace),rightx(w_trace),w_bareband
	endif
	
	//Duplicate /o w_trace, w_bareband
	
	switch (ctrlflag)
		case 0: //remove
			removefromgraph /Z/w=$winname(0,65) w_bareband
			break
		case 1: //from coef
			CheckDisplayed /w=$winname(0,65) w_bareband
			if (V_flag==0)
				if (vertflag)
					appendtograph  /VERT/W=$winname(0,65) w_bareband
				else
					appendtograph /W=$winname(0,65) w_bareband
				endif
			endif
			Calfromcoef(w_bareband,functionflag,coeflist,selrow)
			break
	endswitch
	
	SetDatafolder DF
End

Function Calfromcoef(w_bareband,functionflag,coeflist,selrow)
	Wave w_bareband
	Variable functionflag
	Wave /T coeflist
	Variable selrow
	
	Make /o/n=(dimsize(coeflist,1)-1)/Free w_coef
	
	w_coef=str2num(coeflist[selrow][p+1])
	
	switch(functionflag)
		case 1: //linear
			w_bareband=w_coef[0]+w_coef[1]*x
			break
		case 2:
			w_bareband=w_coef[0]+w_coef[1]*(x-w_coef[2])^2
			break
		case 3: //linear
			w_bareband=-sqrt((w_coef[0]+w_coef[1]*x)^2+w_coef[2]^2)
			if (w_coef[1]>0)
				w_bareband=(x>w_coef[3])?(Nan):(w_bareband)
			else
				w_bareband=(x<w_coef[3])?(Nan):(w_bareband)
			endif
			break
		case 4:
			w_bareband=-sqrt((w_coef[0]+w_coef[1]*(x-w_coef[2])^2)^2+w_coef[3]^2)
			Variable Vf=2*w_coef[1]*w_coef[4]-2*w_coef[2]*w_coef[1]
			if (Vf>0)
				w_bareband=(x>w_coef[4])?(Nan):(w_bareband)
			else
				w_bareband=(x<w_coef[4])?(Nan):(w_bareband)
			endif
			break
	endswitch
	
End


static Function proc_bt_displayselfE(ctrlname)
	String ctrlname
	
	DFREF DF = GetDataFolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_selfE=$(DF_panel+":SelfEnergy")
	DFREF DFR_common= $(DF_panel+":panel_common")
	
	String panelname=Winname(0,65)
	
	SetDataFolder DFR_panel
	
	Wave w_sourceNamesSel=DFR_panel:FitWaveName_list_sel//DFR_common:w_sourceNamesSel
	Wave /T w_sourceNames=DFR_panel:FitWaveName_list//DFR_common:w_sourceNames
	Wave /T w_sourcePathes=DFR_panel:FitWavePath_list//DFR_common:w_sourcePathes
	Wave /T coeflist=DFR_selfE:selfE_bareband_coeflist
	
	Wave /Z w_bareband=DFR_common:w_bareband
	If (waveexists(w_bareband)==0)
		SetDatafolder DF
		return 0
	endif
	
	Duplicate /o  w_bareband,w_bareband_x,w_bareband_VF
	w_bareband_x=x
	
	Controlinfo RealSelf_fnck0
	if (V_value)
		Controlinfo RealSelf_fnpp0
		Variable funcflag=V_value
	else
		Funcflag=0
	endif
	
	controlinfo RealSelf_ck0
	Variable vertflag=v_value
	
	if (stringmatch(ctrlname,"Realself_bt0"))
		Variable appendflag=0
	else
		appendflag=1
	endif
	
	Variable displayindex=0
	
	Duplicate /o/Free w_sourceNamesSel,w_sourceNamesSel_backup
	
	Variable index=0
	do
	
		if ((w_sourceNamesSel[index]==1)||(w_sourceNamesSel[index]==8))
			Wave Point=$w_sourcePathes[index]
			w_sourceNamesSel=0
			w_sourceNamesSel[index]=1
			update_barebands(1)
			Duplicate /o  Point, Bareband_point,Bareband_vF,Point_x,w_SelfEnergy
			Point_x=x
			
			Make /o/n=(dimsize(coeflist,1)-1)/Free w_coef
	
			w_coef=str2num(coeflist[index][p+1])
		
			switch(Funcflag)
				case 0:
					break
				case 1:
					w_bareband_VF=w_coef[1]
					break
				case 2:
					w_bareband_VF=2*w_coef[1]*x-2*w_coef[1]*w_coef[2]
					break
				case 3:
					w_bareband_VF=-0.5/sqrt((w_coef[1]*x+w_coef[0])^2+w_coef[2]^2)*(2*w_coef[1]*(w_coef[1]*x+w_coef[0]))
					
					break
				case 4:
					w_bareband_VF=-0.5/sqrt((w_coef[0]+w_coef[1]*(x-w_coef[2])^2)^2+w_coef[3]^2)*(4*w_coef[1]^2*(x-w_coef[2])^3+4*w_coef[0]*w_coef[1]*(x-w_coef[2]))
					break
			endswitch
		
			if (vertflag)
				Bareband_point=interp(x,w_bareband, w_bareband_x)
				Bareband_vF=interp(x,w_bareband,w_bareband_VF)
				w_SelfEnergy=(Point[p]-Bareband_point[p])*Bareband_vF[p]
				//w_selfEnergy=(x>wavemax(w_bareband))?(Nan):w_selfenergy
				//w_selfEnergy=(x>wavemin(w_bareband))?(Nan):w_selfenergy
			else
				Bareband_point=interp(point[p],w_bareband, w_bareband_x)
				Bareband_vF=interp(point[p],w_bareband,w_bareband_VF)
				w_SelfEnergy=(Point_x[p]-Bareband_point[p])*Bareband_vF[p]
			endif
		
			switch(Funcflag)
				case 3:
					w_SelfEnergy=(abs(x)<abs(w_coef[2]))?(Nan):(w_SelfEnergy)
					break
				case 4:
					w_SelfEnergy=(abs(x)<abs(w_coef[3]))?(Nan):(w_SelfEnergy)
					break
			endswitch
		
		
			String outputname="Re_"+nameofwave(point)
			Duplicate /o w_selfenergy $outputname
			Wave outputwave=$outputname
			
				if (displayindex==0)
					if (appendflag==0)
						display_wave(outputwave,appendflag,0)
					else
						display_wave(outputwave,2,0)
					endif
				else
					display_wave(outputwave,2,0)
				endif
			
			displayindex+=1
			Killwaves /Z outputwave
		
		endif
		w_sourceNamesSel=w_sourceNamesSel_backup[p]
		Dowindow /F $panelname
		index+=1
	while (index<numpnts(w_sourceNamesSel))
	
	SetDatafolder DF
End