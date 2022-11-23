#pragma rtGlobals=1		// Use modern global access method.

#pragma ModuleName = RIXSSpec

// Name: RIXS.ipf
// Purpose: Provides easy way to shift RIXS spectra
// Author: Xiaoqiang Wang
// Created: Aug. 07, 2007
// Change Log:
//    May 04, 2016 --- Xiaoqiang Wang
//           . add possibility to load spectrum from HDF5
//	Sept. 02, 2007 --- Xiaoqiang Wang
//		. save summing information as wave notes
//		. StackGraph doesnt touch offset that is not given
//	Sept. 13, 2007 --- Xiaoqiang Wang
//		. re-organize UI
//		. shift now takes into account also src and dst original offsets
//		. shift has selectable mode to limit the ROI to zoomed 
//	Feb. 08, 2007 --- Xiaoqiang Wang
//		. clean up namespace by using keyword "static"
//		. save/restore user input in package preference file
//		. re-organize UI
//	Feb. 12,2007 --- Xiaoqiang Wang
//		. add option to load only photon counts
//		. add preliminary support for energy calibration
Menu "RIXS"
	"Load Spectra", RIXSLoadSpectra()
	"Shift Spectra", RIXSShiftSpectra()
	"Calib Energy", RIXSCalibSpectra()
	"About", DoAlert 0,"RIXS Spectra Analysis Procedure (Version 2.20 - Date 160504)\n\nAny suggestions or critiques? Direct to xiaoqiang.wang@psi.ch"
End

static StrConstant kPackageName = "RIXS Spectra Analysis"
static StrConstant kPreferencesFileName = "PanelPreferences.bin"
static Constant kLoadPrefsID = 0
static Constant kShiftPrefsID = 1

// NOTE: Variable, String, WAVE, NVAR, SVAR or FUNCREF fields can not be used in this structure
// because they reference Igor objects that cease to exist when you do New Experiment.

Structure RIXSSpecLoadPrefs
	uint32	version		// Preferences structure version number. 100 means 1.00.
	char pre[100] //size limited to be 100
	char suf[32]
	uint32 from_i
	uint32 to_i
	uint32 skip
EndStructure

Structure RIXSSpecShiftPrefs
	uint32 version
	char wave_sum[64]
	uint32 axes
	float shift
	float xoffset
	float yoffset
EndStructure

static Function SaveLoadPrefs()
	STRUCT RIXSSpecLoadPrefs prefs
	SetDF()
	SVAR pre=pre,suf=suf
	NVAR from_i=from_i,to_i=to_i,skip=skip
	prefs.pre=pre
	prefs.suf=suf
	prefs.from_i=from_i
	prefs.to_i=to_i
	prefs.skip=skip
	RestoreDF()
	//SavePackagePreferences kPackageName, kPreferencesFileName, kLoadPrefsID, prefs
End

static Function SaveShiftPrefs()
	STRUCT RIXSSpecShiftPrefs prefs
	SetDF()
	SVAR wave_sum=wave_sum
	NVAR shift=shift, xoffset=xoffset, yoffset=yoffset,axes=axes
	prefs.wave_sum=wave_sum
	prefs.shift=shift
	prefs.axes=axes
	prefs.xoffset=xoffset
	prefs.yoffset=yoffset
	RestoreDF()
	//SavePackagePreferences kPackageName, kPreferencesFileName, kShiftPrefsID, prefs
End


// Set DataFolder to rootRIXS for private variables
static Function SetDF()
	NewDataFolder/O root:RIXS 
	String/G root:RIXS:savDF= GetDataFolder(1) //save DF
	SetDataFolder root:RIXS //root:RIXS as default DF
End
// Restore DataFolder 
static Function RestoreDF()
	SVAR savDF=root:RIXS:savDF
	SetDataFolder savDF
End

static Function StackGraph([xoff, yoff])
	Variable xoff,yoff
	Variable i=0
	
	String traces=TraceNameList("",";",1)
	Do
		String traceName= StringFromList(i,traces)
		If( strlen(traceName) == 0 )
			Break
		EndIf
		// shift only when a number is given
		If (!(ParamIsDefault(xoff) || numtype(xoff)==2))
			ModifyGraph offset($traceName)={i*xoff,NaN}
		EndIf
		If (!(ParamIsDefault(yoff) || numtype(yoff)==2))
			ModifyGraph offset($traceName)={NaN,i*yoff}
		EndIf
		
		i+=1
	While(1)
End

// Assign different colors to waves on the graph, 4 colors in a row
static Function ColorGraph()
	String traces=TraceNameList("",";",1)
	Variable i=0,j=0
	Variable r,g,b
	String traceName
	Make/I/O/N=15 root:RIXS:color_group
	WAVE color_group=root:RIXS:color_group
	color_group[0]={65535,0,0} //Red
	color_group[3]={0,65535,0} //Green
	color_group[6]={0,0,65535} //Blue
	color_group[9]={0,0,0} //Black
	Do
		traceName= StringFromList(i,traces)
		If( strlen(traceName) == 0 )
			Break
		EndIf
		j=mod(i,4)
		r=color_group[j*3]
		g=color_group[j*3+1]
		b=color_group[j*3+2]
		ModifyGraph rgb($traceName)=(r,g,b)
		i+=1
	While(1)
End

// Try to figure out significant numbers after point
// FIXME: This only works for numbers with at most 6 decimal digits
static Function RIXSFindPrecision(num)
	Variable num
	Variable prec
	String str
	num=mod(num,1)
	If(num==0)
		prec=0
	Else
		prec=strlen(num2str(num)) - (num>0?2:3)
	EndIf
	return prec
End

// Shift the spectra under cursor B to be superimposed onto spectra A
Function ShiftSpectra(wA, wB, [Shift, XStart, XEnd])
	Variable Shift, XStart, XEnd
	WAVE wA,wB
	SetDF()
	Variable/G MaxLocX, delta
	Variable offset_a, offset_b, start_b, end_b, start_a, end_a
	offset_a=DimOffset(wA,0)
	delta=DimDelta(wA,0)
	offset_b=DimOffset(wB,0)
	// If no shift value given or NaN, find it out by correlation
	If (ParamIsDefault(Shift) || numtype(Shift)==2)
		// duplicate
		Duplicate/O wB, wave_corr
		Duplicate/O wA, wave_src

		// cut away outside regions
		If(!ParamIsDefault(XStart))
			start_b=x2pnt(wB,XStart);end_b=x2pnt(wB,XEnd)
			start_a=x2pnt(wA,XStart);end_a=x2pnt(wA,XEnd)
			
			wave_corr[,start_b]=0
			wave_corr[end_b,]=0
			
			wave_src[,start_a]=0
			wave_src[end_a,]=0
		EndIf

		// find correlation maximum, and then find the peak position
		Correlate wave_src, wave_corr
		WaveStats/Q wave_corr
		MaxLocX=V_maxloc
		Execute "FindAPeak  0,1,3, wave_corr (MaxLocX-10*delta,MaxLocX+10*delta)"
		NVAR pl=V_peakX
		// limit the shift to one digit more than delta
		// this is enough for most cases in RIXS spectra, not generally applicable!!!
		Variable prec=RIXSFindPrecision(abs(delta))+1
		pl=round(pl*10^prec)/10^prec
		Shift=offset_a-pl
	EndIf
	SetScale/P x  offset_b+Shift,delta,"",wB
	Print NameOfWave(wB), "Shifted By", Shift
	RestoreDF()
End

// sum all spectra in the graph, onto reference wave under cursor A
// output wave name is defined by user
static Function SumSpectraProc(ctrlName) : ButtonControl
	String ctrlName
	// check if cursors are set
	If(strlen(CsrWave(A))==0)
		Abort "Cursor A must be set onto the reference wave to be added on"
	EndIf

	// wave under cursor A is the reference
	WAVE wA = CsrWaveRef(A)	
	SVAR wave_sum=root:RIXS:wave_sum
	//  check existence of destination wave
	If(WaveExists($wave_sum))
		DoAlert 1,"Wave exists, It will be overwritten if continue"
		If(V_Flag!=1)
			Abort "User canceld"
			return 0
		EndIf
	EndIf
	Duplicate/O wA,$wave_sum
	WAVE wS=$wave_sum
	
	// if cursor B is not set, get all waves
	String traces
	If(strlen(CsrWave(B))==0)
		traces=TraceNameList("",";",1)
	Else
		traces=CsrWave(B)
	EndIf
	
	String notes=NameOfWave(wA)
	// Loop over all traces
	Variable i=0
	String traceName
	Do
		traceName= StringFromList(i,traces)
		i+=1
		If( strlen(traceName) == 0 )
			Break
		EndIf
		// skip the reference and the sum
		If(cmpstr(traceName,NameOfWave(wA))==0 || cmpstr(traceName,NameOfWave(wS))==0)
			Continue
		EndIf
		// sum
		WAVE wT=$traceName
		wS+=wT(x)
		notes=AddListItem(notes,traceName)
	While(1)
	// Put a note about from what this sum from
	Note/K  wS
	Note wS, notes
	// 
	SaveShiftPrefs()
End

static Function StackSpectraProc(ctrlName):ButtonControl
	String ctrlName
	NVAR xoffset=root:RIXS:xoffset
	NVAR yoffset=root:RIXS:yoffset
	StackGraph(xoff=xoffset,yoff=yoffset)
	SaveShiftPrefs()
End

static Function ColorGroupProc(ctrlName):ButtonControl
	String ctrlName
	ColorGraph()
End

// shift spectra by given value, if not, calc out by correlation
static Function ShiftSpectraProc(ctrlName):ButtonControl
	String ctrlName
	NVAR shift=root:RIXS:shift
	NVAR axes=root:RIXS:axes
	// check if  reference cursor A is set
	If(strlen(CsrWave(A))==0 ) 
		Abort "Cursors A must set onto reference wave"
	EndIf
	// if cursor B is not set, get all waves
	String traces
	If(strlen(CsrWave(B))==0)
		traces=TraceNameList("",";",1)
	Else
		traces=CsrWave(B)
	EndIf

	// spectra under cursor A is reference
	WAVE wA = CsrWaveRef(A)
	// loop over traces list
	Variable i=0
	String traceName
	Do
		traceName= StringFromList(i,traces)
		i+=1
		If( strlen(traceName) == 0 )
			Break
		EndIf
		// skip the reference
		If(cmpstr(traceName,NameOfWave(wA))==0)
			Continue
		EndIf
		If(axes==1) // extract only zoomed part
			GetAxis/Q 'bottom'
			ShiftSpectra(wA,$traceName,Shift=shift, XStart=V_min, XEnd=V_max)
		Else
			ShiftSpectra(wA,$traceName,Shift=shift)
		EndIf
	While(1)
	SaveShiftPrefs()
End

// load series of general text spectra
static Function LoadSpectraProc(ctrlName) : ButtonControl
	String ctrlName
	Variable i, cam, fid, n
	String wvName, fileName, baseName
	String columnInfo=""
	
	SetDF()
	NVAR from_i=from_i
	NVAR to_i=to_i
	SVAR pre=pre
	SVAR suf=suf
	NVAR skip=skip
	WAVE acquisitionMode=acquisitionMode
	WAVE expansionFactor=expansionFactor
	RestoreDF()

	n = ItemsInList(pre, ":")
	baseName = StringFromList(n-1, pre, ":")

	For(i=from_i;i<=to_i;i+=1)
		If (cmpstr(suf, ".txt") == 0)
			sprintf wvName,"%04d%s",i,suf
			wvName=pre+wvName
			If(skip==1)
				columnInfo="C=2, N='_skip_';"
			EndIf
			LoadWave/A/G/D/Q/W/B=columnInfo wvName
		ElseIf (cmpstr(suf, ".h5") == 0)
			For(cam=1;cam<=3;cam+=1)
				sprintf fileName, "%s_%04d_d%d%s",pre,i,cam,suf
				sprintf wvName, "%s_%04d_d%d",baseName, i,cam
				GetFileFolderInfo /Z=1 fileName
				If (V_isFile == 0)
					Abort "File does not exist!"
					break
				EndIf
				// read spectrum
				HDF5OpenFile /z/r fid as fileName
				HDF5LoadData /Q/O/N=$wvName fid, "/entry/analysis/spectrum"
				SetDF()
				HDF5LoadData /Q/O/N= acquisitionMode fid, "/entry/instrument/NDAttributes/AcquisitionMode"
				HDF5LoadData /Q/O/N=expansionFactor fid, "/entry/instrument/NDAttributes/ExpansionFactor"
				RestoreDF()
				HDF5CloseFile fid
				// set spectrum scaling based on expansion factor only if acqusition mode is 1 (XCAM mode)
				If (acquisitionMode[0] == 1)
					SetScale /P x,0,1/expansionFactor[0],"pixel",$wvName
				EndIf
			EndFor			
		EndIf
	EndFor
	SaveLoadPrefs()
End

Function RIXSShiftSpectra()
	DoWindow/F RIXSShiftPanel
	if (V_flag != 0)
		return 0
	endif

	SetDF()
	Variable/G shift=NaN
	Variable/G axes=0
	Variable/G xoffset=NaN, yoffset=NaN
	String/G wave_sum

	STRUCT RIXSSpecShiftPrefs prefs
	//LoadPackagePreferences kPackageName, kPreferencesFileName, kShiftPrefsID, prefs

	//If (V_flag==0 && V_bytesRead!=0)
	//	shift=prefs.shift
	//	axes=prefs.axes
	//	xoffset=prefs.xoffset
	//	yoffset=prefs.yoffset
	//	wave_sum=prefs.wave_sum
	//EndIf
	
	ShiftPanel()
	SetWindow kwTopWin,hook=RIXSSpec#ShiftPanelHook

	RestoreDF()
End

static Function ShiftPanel(): Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(600,240,810,450) /K=1 as "Shift Spectra"
	SetDrawLayer UserBack
	DrawLine 8,126,189,126
	DrawLine 98,133,98,211
	Button btnShift,pos={124,23},size={50,20},proc=RIXSSpec#ShiftSpectraProc,title="Shift"
	SetVariable valShift,pos={18,25},size={88,16},title="Shift By"
	SetVariable valShift,help={"NaN means find out by correlation"}
	SetVariable valShift,value= shift
	Button btnSum,pos={136,95},size={50,20},proc=RIXSSpec#SumSpectraProc,title="Sum"
	SetVariable valOutput,pos={8,97},size={118,16},title="Sum To"
	SetVariable valOutput,value= wave_sum
	Button btnColor,pos={122,185},size={61,20},proc=RIXSSpec#ColorGroupProc,title="Colorize"
	CheckBox chkAxes,pos={16,51},size={158,14},title="Only region defined by X axes"
	CheckBox chkAxes,variable=axes
	GroupBox group0,pos={6,2},size={190,79},title="Shift Spectra"
	SetVariable xshift,pos={5,136},size={85,16},title="X",value= xoffset
	SetVariable yshift,pos={5,158},size={85,16},title="Y",value= yoffset
	Button btnStack,pos={21,186},size={61,20},title="Stack",proc=RIXSSpec#StackSpectraProc
	DoWindow/C RIXSShiftPanel
End

static Function ShiftPanelHook(infoStr)
	String infoStr

	String event= StringByKey("EVENT",infoStr)
	strswitch(event)
		case "kill":
			SaveShiftPrefs()
			break
	endswitch
	
	return 0
End

Function RIXSLoadSpectra()
	DoWindow/F RIXSLoadPanel
	if (V_flag != 0)
		return 0
	endif

	SetDF()
	Make acquisitionMode
	Make expansionFactor
	Variable/G  from_i=001, to_i=002
	String/G pre="X:Jul2007:Cu"
	String/G suf=".txt"
	Variable/G skip=0

	STRUCT RIXSSpecLoadPrefs prefs
	//LoadPackagePreferences kPackageName, kPreferencesFileName, kLoadPrefsID, prefs

	//If (V_flag==0 && V_bytesRead!=0)
	//	from_i=prefs.from_i
	//	to_i=prefs.to_i
	//	pre=prefs.pre
	//	suf=prefs.suf
	//	skip=prefs.skip
	//EndIf
	
	LoadPanel()
	SetVariable prefix, value=pre
	SetVariable index_l,value= from_i
	SetVariable index_h,value=to_i
	SetVariable suffix,value=suf
	CheckBox skip, variable=skip
	SetWindow kwTopWin,hook=RIXSSpec#LoadPanelHook

	RestoreDF()
End

static Function LoadPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(600,80,810,210) /K=1 as "Load Spectra"
	SetVariable prefix,pos={10,10},size={180,16},title="prefix"
	SetVariable index_l,pos={10,40},size={93,16},title="From",format="%04d"
	SetVariable index_h,pos={110,40},size={80,16},title="To",format="%04d"
	SetVariable suffix, pos={10,70},size={70,16},title="suffix"
	CheckBox skip, pos={10, 100}, size={180, 16},title="Load only photon count column"
	Button load,pos={140,70},size={50,20},proc=RIXSSpec#LoadSpectraProc,title="Load"
	
	DoWindow/C RIXSLoadPanel
End

static Function LoadPanelHook(infoStr)
	String infoStr

	String event= StringByKey("EVENT",infoStr)
	strswitch(event)
		case "kill":
			SaveLoadPrefs()
			break
	endswitch
	
	return 0
End

Function RIXSCalibSpectra()
	DoWindow/F RIXSCalibPanel
	if (V_flag != 0)
		return 0
	endif
	
	SetDF()
	Variable /G pnt0=1000
	Variable /G de=0.012
	String/G wname=""
	CalibPanel()
	RestoreDF()
	
	DoWindow /C RIXSCalibPanel
End

static Function GetCursorProc(ctrlName) : ButtonControl
	String ctrlName
	If(strlen(CsrWave(A))==0)
		Abort "Cursor A must be set on to the target trace"
	EndIf

	SetDF()
	NVAR pnt0=pnt0
	pnt0=pcsr(A)	
	SVAR wname=wname
	wname=GetWavesDataFolder(CsrWaveRef(A),2)
	RestoreDF()
End

static Function CalibSpectraProc(ctrlName) : ButtonControl
	String ctrlName
	SetDF()
	NVAR pnt0=pnt0,de=de
	SVAR wname=wname
	RestoreDF()
	SetScale /P x,-pnt0*de,de,"",$wname
End

Function CalibPanel():Panel
	PauseUpdate;Silent 1
	NewPanel /W=(600,480,810,610) /K=1 as "Calibrate Energy"
	SetVariable wname, pos={10,10},size={195,20}
	SetVariable wname, title="Choose Wave",value=wname
	SetVariable pnt0, pos={10,40},size={140,20}	
	SetVariable pnt0, title="0 eV Position",value=pnt0
	Button csr,pos={160,40},size={45,20},title="Cursor",proc=RIXSSpec#GetCursorProc
	SetVariable de, pos={10,70},size={140,20}
	SetVariable de, title="eV per Point",value=de
	Button sete, pos={40,100},size={120,20},title="Set Energy Scale",proc=RIXSSpec#CalibSpectraProc
End
