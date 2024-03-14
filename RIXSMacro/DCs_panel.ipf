#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 0.01


Function /DF init_DC_Display()
	DFREF DF = GetDataFolderDFR()

	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	SetDatafolder DFR_panel
	//String/G panelDCsPath=DF_panel+":DCs:"
	//newDatafolder /o /s DCs
//	DFREF DFR_DCs=GetDataFolderDFR()	
	
	//String/G gs_saveNameBase
	Variable/G gv_first=0, gv_last=0, gv_step=1
	Variable/G gv_DCnum=1,gv_col=1
	Variable/G gv_csrstepnum=3
//	Variable/G gv_firstinterval, gv_lastinterval, gv_stepinterval
	Variable/G gv_autoPeak=0
	Variable/G gv_autoDCflag
	Variable/G gv_autodimflag=1
//	Variable/G gv_autogammaFlag=0
	Variable/G gv_autoposition=0
	//Variable/G gv_findpeakSP=0
	Variable/G gv_x_offset=0, gv_y_offset=0
    
    
	SetDataFolder DF
	return DFR_panel
End





Function add_Tab_DCs()
DFREF DF=GetDatafolderDFR()

String DF_panel="root:internalUse:"+winname(0,65)
DFREF DFR_panel=$DF_panel
DFREF DFR_common=$(DF_panel+":panel_common")
DFREF DFR_DCs=init_DC_Display()

	Variable r=57000, g=57000, b=57000	
	// raw DC tab
	Variable SC = ScreenSize(5)*1.5
	
	Groupbox DCs_gb0, pos={230*SC,30*SC}, size={150*SC,130*SC}, frame=0,title="define DC's",  disable=1
	CheckBox DCs_c0, pos={238*SC,45*SC}, title="EDC's",labelBack=(r,g,b), proc=Proc_checkbox_DCdimchange, value=1, disable=1
	CheckBox DCs_c1, pos={308*SC,45*SC}, title="MDC's", labelBack=(r,g,b), proc=Proc_checkbox_DCdimchange, disable=1
	
	SetVariable DCs_sv0,pos={238*SC,65*SC},size={78*SC,18*SC},limits={0,inf,1},title="first:",labelBack=(r,g,b), value= DFR_DCs:gv_first,proc=m_Cut ,disable=1
	SetVariable DCs_sv1,pos={238*SC,82*SC},size={78*SC,18*SC},limits={0,inf,1},title="last: ",labelBack=(r,g,b), value = DFR_DCs:gv_last,proc=m_Cut, disable=1
	SetVariable DCs_sv2,pos={238*SC,99*SC},size={78*SC,18*SC},limits={1,inf,1},title="num:",labelBack=(r,g,b),value = DFR_DCs:gv_DCnum, proc=m_cut,disable=1
	SetVariable DCs_sv15,pos={238*SC,116*SC},size={78*SC,18*SC},limits={-inf,inf,1},title="step:",labelBack=(r,g,b),value=DFR_DCs:gv_step,proc=m_Cut, disable=1
  	SetVariable DCs_sv16,pos={238*SC,133*SC},size={78*SC,18*SC},limits={1,inf,1},title="col:",labelBack=(r,g,b),value=DFR_DCs:gv_col,proc=m_Cut, disable=1
	
	Button DCs_b27,pos={322*SC,65*SC},size={50*SC,18*SC},title="Default", proc=red_and_green_DC, disable=1
	Button DCs_b22,pos={322*SC,82*SC},size={50*SC,18*SC},title="R + G", proc=red_and_green_DC, disable=1
	Button DCs_b42,pos={322*SC,99*SC},size={50*SC,18*SC},title="Single", proc=red_and_green_DC, disable=1
	Button DCs_b24,pos={322*SC,116*SC},size={50*SC,18*SC},title="R DCs", proc=red_and_green_DC, disable=1
    	Button DCs_b26,pos={322*SC,133*SC},size={50*SC,18*SC},title="G DCs", proc=red_and_green_DC, disable=1
    
         
      	Button DCs_b10,pos={230*SC,165*SC},size={55*SC,20*SC},title="display", proc=display_DC, disable=1
	Button DCs_b11,pos={290*SC,165*SC},size={35*SC,20*SC},title="add", proc=add_DC, disable=1
	Button DCs_b12,pos={330*SC,165*SC},size={45*SC,20*SC},title="remove", proc=remove_DC, disable=1
	
	Button DCs_b13,pos={390*SC,165*SC},size={80*SC,20*SC},title="Image disp", proc = carpet_display, disable=1
	//Button DCs_b14,pos={445*SC,165*SC},size={50*SC,20*SC},title="IMG add", proc = carpet_display, disable=1
	//Checkbox DCs_ck40,pos={445*SC,163*SC},size={50*SC,20*SC},title="App",value=0,disable=1
	//Checkbox DCs_ck41,pos={445*SC,177*SC},size={50*SC,20*SC},title="live",value=0,disable=1
	
	
	Groupbox DCs_gb2, pos={390*SC,30*SC}, size={240*SC,65*SC},frame=0, title="set offset:",disable=1
	Titlebox DCs_tb0, pos={400*SC,45*SC}, title="x:", frame=0, disable=1
	Titlebox DCs_tb1, pos={400*SC,62*SC}, title="y:", frame=0, disable=1
	Slider DCs_sl0,pos={412*SC,50*SC},size={100*SC,18*SC},limits={-1,1,0.005},variable=DFR_DCs:gv_x_offset,side= 0,vert= 0, side=2,labelBack=(r,g,b), thumbcolor=(2,2,2), proc=slider_offset, disable=1
	Slider DCs_sl1,pos={412*SC,67*SC},size={100*SC,18*SC},limits={-5,5,0.002},variable=DFR_DCs:gv_y_offset,side= 0,vert= 0, side=2,labelBack=(r,g,b), thumbcolor=(2,2,2), proc=slider_offset, disable=1
	SetVariable DCs_sv3, pos={520*SC,45*SC}, size={33*SC,15*SC}, value=DFR_DCs:gv_x_offset,limits={-inf,inf,0}, title=" ",labelBack=(r,g,b), proc=sv_offset, disable=1
	SetVariable DCs_sv4, pos={520*SC,62*SC}, size={33*SC,15*SC}, value=DFR_DCs:gv_y_offset,limits={-inf,inf,0}, title=" ",labelBack=(r,g,b), proc=sv_offset, disable=1
	checkbox DCs_offck0, pos={560*SC,45*SC}, size={60*SC,16*SC}, title="None",proc=Proc_checkbox_offset_proc,value=1,disable=1
	checkbox DCs_offck1, pos={560*SC,60*SC}, size={60*SC,16*SC}, title="Wave ind",proc=Proc_checkbox_offset_proc,disable=1
	checkbox DCs_offck2, pos={560*SC,75*SC}, size={60*SC,16*SC}, title="DCs Num",proc=Proc_checkbox_offset_proc,disable=1
	
	//PopupMenu DCs_p0,pos={460,108},bodyWidth=56,size={113,18}, title="",value="*COLORPOP*", proc=trace_color, disable=1
//	PopupMenu DCs_p1,pos={340,85},bodyWidth=56,size={113,18},title="",value="*COLORTABLEPOPNONAMES*", disable=1,mode=2
//	Button DCs_b3, pos={395,108}, size={100,18}, title="different Color", proc=rainbow_traces, disable=1
//	Checkbox DCs_clck0, pos={465,87}, size={60,18}, title="reverse", value=0,disable=1
	
	Groupbox DCs_gb3, pos={390*SC,95*SC}, size={240*SC,65*SC}, frame=0,title="Cursors Control",disable=1
	
	Button DCs_b20,pos={395*SC,135*SC},size={40*SC,18*SC},title="all", proc=all_DC, disable=1
	Button DCs_b25,pos={435*SC,135*SC},size={40*SC,18*SC},title="Align", proc=Align_DC, disable=1
	Button DCs_b21,pos={475*SC,135*SC},size={40*SC,18*SC},title="Green", proc=Align_DC, disable=1
	Button DCs_b23,pos={515*SC,135*SC},size={40*SC,18*SC},title="Red", proc=Align_DC, disable=1
	
	
	SetVariable DCs_sv5, pos={565*SC,135*SC}, size={60*SC,18*SC}, value=DFR_DCs:gv_csrstepnum,limits={1,inf,0}, title="DCs=",labelBack=(r,g,b), disable=1
	//Button DCs_b28,pos={395,165},size={40,18},title="Gamma", proc=Align_DC, disable=1
	//Button DCs_b29,pos={435,165},size={40,18},title="EF", proc=Align_DC, disable=1
	checkbox DCs_ck28,pos={425*SC,115*SC},size={40*SC,18*SC},title="x", value=1, proc=Proc_checkbox_csrctrl_dimchange, disable=1
	checkbox DCs_ck29,pos={395*SC,115*SC},size={40*SC,18*SC},title="y", value=0, proc=Proc_checkbox_csrctrl_dimchange, disable=1
	checkbox DCs_ck30,pos={455*SC,115*SC},size={45*SC,20*SC},title="auto", variable=DFR_DCs:gv_autoDCflag, proc=Proc_checkbox_Auto_Align_DC, value=0,disable=1
	SetVariable DCs_sv7, pos={505*SC,115*SC}, size={90*SC,18*SC}, title="value=", value=DFR_DCs:gv_autoposition,limits={-inf,inf,0}, title=" ",labelBack=(r,g,b), disable=1,proc=Proc_setvariable_Auto_Align_DC
	
	//checkbox DCs_ck31,pos={445,130},size={40,18},title="EDC", value=0, proc=Proc_checkbox_FPeak_dimchange, disable=1
//	checkbox DCs_ck32,pos={395,130},size={40,18},title="MDC", value=1, proc=Proc_checkbox_FPeak_dimchange, disable=1
	
// Commented out by WSL 05/17/2021

//	Button DCs_b30,pos={505*SC,165*SC},size={65*SC,20*SC},title="Find Peaks", proc=Find_Peak_DC, disable=1
//	Button DCs_b31,pos={575*SC,165*SC},size={25*SC,20*SC},title="<--", proc=Move_Peak_DC, disable=1
//	Button DCs_b32,pos={605*SC,165*SC},size={25*SC,20*SC},title="-->", proc=Move_Peak_DC, disable=1
	
	//SetVariable DCs_sv6, pos={560,165}, size={70,18}, value=DFR_DCs:gv_autoPeak,limits={0,inf,1}, title="Peaks=",labelBack=(r,g,b), proc=Proc_peak_change,disable=1
End





Function Proc_checkbox_offset_proc(name,value)
	String name
	Variable value
	SetActiveSubwindow $winname(0,65)
	Variable ckvalue
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
	endswitch
	CheckBox DCs_offck0, value=ckvalue==0
	CheckBox DCs_offck1, value=ckvalue==1
	CheckBox DCs_offck2, value=ckvalue==2
		

End	


Function Proc_checkbox_DCdimchange(name,value)
	String name
	Variable value
	
	String panelname=winname(0,65)
	String DF_panel="root:internalUse:"+panelName
	String DF_common="root:internalUse:"+panelName+":panel_common"
	DFREF DFR_common=$DF_common
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	NVAR first =DFR_panel:gv_first
	NVAR last = DFR_panel:gv_last
	NVAR step = DFR_panel:gv_step
	NVAR DCnum= DFR_panel:gv_DCnum
	WAVE w_image = DFR_common:w_image
	Variable bVal, d_limit
	strswitch (name)
		case "DCs_c0":
			bVal= 1
			first = pcsr(A)
			last = pcsr(B)
			d_limit = dimsize(w_image,0)-1
			break
		case "DCs_c1":
			first = qcsr(A)
			last = qcsr(B)
			bVal= 2
			d_limit = dimsize(w_image,1)-1
			break
	endswitch
	CheckBox DCs_c0,value= bVal==1
	CheckBox DCs_c1,value= bVal==2
	SetVariable DCs_sv0, limits={0,d_limit,1}
	SetVariable DCs_sv1, limits={0,d_limit,1}

	Cursor/P/I/H=1 A w_image pcsr(A),qcsr(A)
	Cursor/P/I/H=1 B w_image pcsr(B),qcsr(B)
	collapse_Proc("dummy",0)
	
End






Function Proc_checkbox_fpeak_dimchange(name,value)
	String name
	Variable value
	
	String panelname=winname(0,65)
	String DF_panel="root:internalUse:"+panelName
	String DF_common="root:internalUse:"+panelName+":panel_common"
	DFREF DFR_common=$DF_common
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	Variable bVal, d_limit
	strswitch (name)
		case "DCs_ck31":
			bVal= 1
			break
		case "DCs_ck32":
			bVal= 2
			break
	endswitch
	CheckBox DCs_ck31,value= bVal==1
	CheckBox DCs_ck32,value= bVal==2
	
End	


Function Proc_checkbox_csrctrl_dimchange(name,value)
	String name
	Variable value
	
	String panelname=winname(0,65)
	String DF_panel="root:internalUse:"+panelName
	String DF_common="root:internalUse:"+panelName+":panel_common"
	DFREF DFR_common=$DF_common
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	NVAR autodimflag=DFR_panel:gv_autodimflag
	
	Variable bVal, d_limit
	strswitch (name)
		case "DCs_ck29":
			bVal= 1
			autodimflag=0
			break
		case "DCs_ck28":
			autodimflag=1
			bVal= 2
			break
	endswitch
	CheckBox DCs_ck29,value= bVal==1
	CheckBox DCs_ck28,value= bVal==2
	CheckBox DCs_ck30,value=1
	Proc_checkbox_Auto_Align_DC("dummy",1)
	
	
End	


Function Proc_checkbox_Auto_Align_DC(ctrlName,value)
String ctrlname
Variable Value

DFREF DF=GetDatafolderDFR()

	String panelname=winname(0,65)
	String DF_panel="root:internalUse:"+panelName
	String DF_common="root:internalUse:"+panelName+":panel_common"
	DFREF DFR_common=$DF_common
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	NVAR csrstep=DFR_panel:gv_csrstepnum
	//NVAR autoEF=DFR_panel:gv_autoefflag
	//NVAR autogamma=DFR_panel:gv_autogammaflag
	NVAR autoposition=DFR_panel:gv_autoposition
	NVAR autodimflag=DFR_panel:gv_autodimflag
	NVAR autoDCflag=DFR_panel:gv_autoDCflag
	WAVE w_image = DFR_common:w_image
	autoDCflag=value
	
	Variable cval
	Variable setpoint
	if (autoDCflag)
	if (autodimflag==1)
	setpoint=x2pntsmult(w_image,autoposition,0)
	Cursor/P/I/H=1 B w_image trunc(setpoint-(csrstep-1)/2)+csrstep-1,qcsr(B)
	Cursor/P/I/H=1 A w_image trunc(setpoint-(csrstep-1)/2),qcsr(A)
	else
	setpoint=x2pntsmult(w_image,autoposition,1)
	Cursor/P/I/H=1 B w_image pcsr(B),trunc(setpoint-(csrstep-1)/2)+csrstep-1
	Cursor/P/I/H=1 A w_image pcsr(A),trunc(setpoint-(csrstep-1)/2)
	endif
				
	//checkbox DCs_ck28, value=((cval==1)&&value)
	//checkbox DCs_ck29, value=((cval==2)&&value)
	//collapse_Proc("Align",1)
	ControlUpdate DCs_sv0
	ControlUpdate DCs_sv1
	ControlUpdate DCs_sv2
	ControlUpdate DCs_sv15
	ControlUpdate DCs_sv16
	endif
	
    SetDatafolder DF	
end



Function Proc_setvariable_Auto_Align_DC(ctrlName,varNum,varStr,varName) : SetVariableControl 
	String ctrlName
	Variable varNum
	String varStr
	String varName
    DFREF DF=GetDatafolderDFR()
    
	String panelname=winname(0,65)
	String DF_panel="root:internalUse:"+panelName
	String DF_common="root:internalUse:"+panelName+":panel_common"
	DFREF DFR_common=$DF_common
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	NVAR csrstep=DFR_panel:gv_csrstepnum
	//NVAR autoEF=DFR_panel:gv_autoefflag
	//NVAR autogamma=DFR_panel:gv_autogammaflag
	NVAR autoposition=DFR_panel:gv_autoposition
	NVAR autodimflag=DFR_panel:gv_autodimflag
	NVAR autoDCflag=DFR_panel:gv_autoDCflag
	WAVE w_image = DFR_common:w_image
	
	autoposition=varNum
	
	
	if (autodimflag==1)
	Variable cval
	Variable setpoint
	if (autodimflag==1)
	setpoint=x2pntsmult(w_image,autoposition,0)
	Cursor/P/I/H=1 B w_image trunc(setpoint-(csrstep-1)/2)+csrstep-1,qcsr(B)
	Cursor/P/I/H=1 A w_image trunc(setpoint-(csrstep-1)/2),qcsr(A)
	else
	setpoint=x2pntsmult(w_image,autoposition,1)
	Cursor/P/I/H=1 B w_image pcsr(B),trunc(setpoint-(csrstep-1)/2)+csrstep-1
	Cursor/P/I/H=1 A w_image pcsr(A),trunc(setpoint-(csrstep-1)/2)
	endif
				
	
	//collapse_Proc("Align",1)
	ControlUpdate DCs_sv0
	ControlUpdate DCs_sv1
	ControlUpdate DCs_sv2
	ControlUpdate DCs_sv15
	ControlUpdate DCs_sv16
	endif
	SetDatafolder DF
End

Function Move_Peak_DC(ctrlname)
String ctrlName
String panelname=winname(0,65)
	String DF_panel="root:internalUse:"+panelName
	String DF_common="root:internalUse:"+panelName+":panel_common"
	DFREF DFR_common=$DF_common
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	
	NVAR autopeak=DFR_panel:gv_autopeak
	NVAR first =DFR_panel:gv_first
	NVAR last = DFR_panel:gv_last
	NVAR step = DFR_panel:gv_step
	NVAR DCnum= DFR_panel:gv_DCnum
	NVAR csrstep=DFR_panel:gv_csrstepnum
	WAVE w_image = DFR_common:w_image
	Wave AutoPeakposition=DFR_panel:AutoPeakposition
		
	strswitch (ctrlname)
	case "DCs_b31":
	autopeak-=1
	if (autopeak<0)
	autopeak=numpnts(AutoPeakposition)
	endif
	break
	case "DCs_b32":
	autopeak+=1
	if (autopeak==numpnts(AutoPeakposition))
	autopeak=0
	endif
	break
	endswitch
	
	Controlinfo DCs_c0
	Variable dimflag=v_value
	Variable setpoint
	setpoint=autopeakposition[autopeak]
	if (dimflag)
	Cursor/P/I/H=1 A w_image trunc(setpoint-(csrstep-1)/2)+csrstep-1,qcsr(A)
	Cursor/P/I/H=1 B w_image trunc(setpoint-(csrstep-1)/2),qcsr(B)
	else
	Cursor/P/I/H=1 A w_image pcsr(A),trunc(setpoint-(csrstep-1)/2)+csrstep-1
	Cursor/P/I/H=1 B w_image pcsr(B),trunc(setpoint-(csrstep-1)/2)
	endif
	
End

Function Find_Peak_DC(ctrlname)
String ctrlName
String panelname=winname(0,65)
	String DF_panel="root:internalUse:"+panelName
	String DF_common="root:internalUse:"+panelName+":panel_common"
	DFREF DFR_common=$DF_common
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	
	NVAR autopeak=DFR_panel:gv_autopeak
	NVAR first =DFR_panel:gv_first
	NVAR last = DFR_panel:gv_last
	NVAR step = DFR_panel:gv_step
	NVAR DCnum= DFR_panel:gv_DCnum
	NVAR csrstep=DFR_panel:gv_csrstepnum
	WAVE w_image = DFR_common:w_image
	Wave n_mdc=DFR_common:n_mdc
	Wave n_edc=DFR_common:n_edc
	
	Variable setpoint
	Controlinfo DCs_c0
	Variable dimflag=v_value
	
	if (dimflag)
	Variable Findpeaks=DC_findpeaks(n_mdc,dimsize(w_image,0),0)
	
	if (Findpeaks>=0)
	Wave W_AutoPeakInfo
	make /o/n=(Findpeaks) DFR_panel:AutoPeakposition
	Wave AutoPeakposition=DFR_panel:AutoPeakposition
	AutoPeakposition=W_AutoPeakInfo[p][0]
	Killwaves /Z w_autopeakinfo
	//Setvariable DCs_sv6,limits={0,Findpeaks-1,1}
	autopeak=0
	sort /A AutoPeakposition,AutoPeakposition
	setpoint=autopeakposition[0]
	Cursor/P/I/H=1 A w_image trunc(setpoint-(csrstep-1)/2)+csrstep-1,qcsr(A)
	Cursor/P/I/H=1 B w_image trunc(setpoint-(csrstep-1)/2),qcsr(B)
	else
	Killwaves /Z w_autopeakinfo
	endif
	
	else
	Findpeaks=DC_findpeaks(n_edc,0,dimsize(w_image,1))
	if (Findpeaks>=0)
	Wave W_AutoPeakInfo
	make /o/n=(Findpeaks)  DFR_panel:AutoPeakposition
	Wave AutoPeakposition= DFR_panel:AutoPeakposition
	AutoPeakposition=W_AutoPeakInfo[p][0]
	Killwaves /Z w_autopeakinfo
	sort /A AutoPeakposition,AutoPeakposition
	autopeak=0
	setpoint=autopeakposition[0]
	print setpoint
	Cursor/P/I/H=1 A w_image pcsr(A),trunc(setpoint-(csrstep-1)/2)+csrstep-1
	Cursor/P/I/H=1 B w_image pcsr(B),trunc(setpoint-(csrstep-1)/2)
	else
	Killwaves /Z w_autopeakinfo
	endif
	endif
End


Function DC_findpeaks(DCs,startP,endP)
Wave DCs
Variable startP,endP

Variable MaxPeaks=100
Variable minPeakPercent=3

Variable/C estimates= EstPeakNoiseAndSmfact(DCs,startP, endP)
Variable noiselevel=real(estimates)
Variable smoothingFactor=imag(estimates)
	
	Variable peaksFound= AutoFindPeaks(DCs,startP,endP,noiseLevel,smoothingFactor,maxPeaks)
	if( peaksFound > 0 )
		WAVE W_AutoPeakInfo
		// Remove too-small peaks
		peaksFound= TrimAmpAutoPeakInfo(W_AutoPeakInfo,minPeakPercent/100)
		if( peaksFound > 0 )
			
			return peaksFound
			
		endif
	endif
	if( peaksFound < 1 )
		DoAlert 0, "No Peaks found!"
	endif
	return peaksFound

End