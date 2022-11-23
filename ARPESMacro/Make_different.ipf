#pragma rtGlobals=1		// Use modern global access method.
#pragma moduleName=KBColorizeTraces_Panel
#pragma version=0.01	// shipped with Igor 6.22

// Modified by Yan Zhang to fit the ARPES macro

// Written by Kevin Boyce with tweaks by Howard Rodstein and Jim Prouty.
//
// Version 6.03, JP:	Added Markers and Line Styles Quick Sets
//						Added image plots and value readouts for the Color Wheel sliders.
//						Added Linear Hue checkbox.
//						Now Desaturated colors no longer tend towards pink.
//						Made most functions static.
//
// Version 6.04, JP:	Restored KBColorizeTraces_panel_panel to lightness, saturation, startingHue parameters only (as per Igor 6.02A and earlier),
//						and added KBColorizeTraces_panelLinearHue() with same parameters,
//						and KBColorizeTraces_panelOptLinear(lightness, saturation, startingHue,[useLinearHue]).
//
// Version 6.041, JP:	Works correctly if the current data folder isn't root. Fixes thanks to  "Marcel Graf" <marcel.graf@gmx.ch>
// Version 6.1, JP:		Slider pointers don't overlap the image plots on Windows.
// Version 6.22, JP:		Fixed lstyle wrapping to not skip style 17
//
// Colorize the waves in the top graph, with given lightness and saturation starting hue.
// Lightness, saturation and starting hue vary between 0 and 1.
// NOTE: lightness and saturation are really cheap approximations.
// For that matter, so is hue, which is a real simple rgb circle.
// Colors are evenly distributed in "hue", except around
// green-blue, where they move more quickly, since color perception
// isn't as good there.  I generally call it with lightness=0.9 and 
// saturation=1.


//------------- Public Routines ----------------------------

//Menu "Graph"
//	"Make Traces Different", /Q, ShowKBColorizePanel()
//End


Function /DF InitialKBColorizePanel(graphname)
	String graphname

	DFREF DFR_GP=$DF_GP
	SetDatafolder DFR_GP
	
	newDatafolder /o/s $graphname
	newDatafolder /o/s KBColorize
	
	Variable /G gv_linesize=0.5
	
	
	return GetDatafolderDFR()
End 

Function CreateKBColorizePanel_ARPES()
	DFREF DF=getdatafolderDFR()
	String wname=winname(0,1)
	if (strlen(wname)==0)
		return 1
	endif
	
	DoWindow /F $wname
	
	DFREF DFR_GP=$DF_GP
	
	SetDatafolder DFR_GP
	
		
	if (stringmatch(wname,"*panel*")==1)
		SetDatafolder DF
		return 0
	endif
		
	String Cwnamelist=ChildWindowList(wname)
 	
 	if (Findlistitem("KBColorizePanel",Cwnamelist,";",0)!=-1)
 		KillWindow $wname#KBColorizePanel
 		SetDatafolder DF
 		return 0
 	endif
	
	DFREF DFR_color=InitialKBColorizePanel(wname)
	
	SetDatafolder DFR_color
	String DFS_color=GetDatafolder(1)
	//DoWindow/K KBColorizePanel
	//	newDatafolder /o root:Packages
	//	newDatafolder /o root:Packages:KBColorize
		
	//
	
	Variable r=57000, g=57000, b=57000
	Variable SC=Screensize(5)
	Variable width=303*SC,Height=553*SC
	//DoWindow/K KBColorizePanel
	NewPanel /Host=$wname/EXT=0/K=1/W=(0,0,width,Height)/N=KBColorizePanel as "Make Traces Different"
	ModifyPanel/W=$wname#KBColorizePanel noEdit=1, fixedSize=1
	//DefaultGuiFont/W=#/Mac popup={"_IgorMedium",12,0},all={"_IgorMedium",12,0}
	//DefaultGuiFont/W=#/Win popup={"_IgorMedium",0,0},all={"_IgorMedium",0,0}
	//String topGraph=WinName(0,1)
	//if( strlen(topGraph) )
	//	AutoPositionWindow/M=0/R=$topGraph KBColorizePanel
	//endif
	
	
	GroupBox markersGroup,pos={10*SC,9*SC},size={280*SC,78*SC},title="Markers Quick Set"
	PopupMenu allMarkers,pos={25*SC,33*SC},size={169*SC,20*SC},proc=KBColorizeTraces_panel#AllMarkersPopMenuProc,title="Reset All Traces To:"
	PopupMenu allMarkers,mode=20,popvalue="",value= #"\"*MARKERPOP*\""
	Checkbox SetMarkers0, pos={235*SC,25*SC},size={60*SC,20*SC},proc=KBColorizeTraces_panel#AllLinemarkmode,title="Line"
	Checkbox SetMarkers1, pos={235*SC,45*SC},size={60*SC,20*SC},proc=KBColorizeTraces_panel#AllLinemarkmode,title="Marker"
	Checkbox SetMarkers2, pos={235*SC,65*SC},size={60*SC,20*SC},proc=KBColorizeTraces_panel#AllLinemarkmode,title="L+M"
	
	PopupMenu markersSeries,pos={23*SC,60*SC},size={199*SC,20*SC},proc=KBColorizeTraces_panel#UniqueMarkersPopMenuProc,title="Unique Markers:"
	PopupMenu markersSeries,mode=1,popvalue="All Sequential",value= #"\"All Sequential;All Random;Only Filled;Only Outlined;Only Lines;Only Round;Only Square;Only Diamond;Only Triangle;Only Crosses;\""
	GroupBox lineStylesGroup,pos={10*SC,99*SC},size={280*SC,78*SC},title="Line Styles Quick Set"

	PopupMenu allLineStyles,pos={20*SC,122*SC},size={170*SC,24*SC},proc=KBColorizeTraces_panel#AllLineStylesPopMenuProc,title="Reset All Traces To:"
	PopupMenu allLineStyles,mode=1,bodyWidth= 70*SC,popvalue="",value= #"\"*LINESTYLEPOP*\""
	Button uniqueLineStyles,pos={20*SC,150*SC},size={140*SC,20*SC},proc=KBColorizeTraces_panel#UniqueLineStylesButtonProc,title="Sequential Line Styles"
	Button editLinestyle,pos={170*SC,150*SC},size={100*SC,20*SC},proc=KBColorizeTraces_panel#EditAppearances,title="Edit Style"
	
	Setvariable allLineSize,pos={205*SC,122*SC},size={70*SC,24*SC},limits={0,inf,0},proc=KBColorizeTraces_panel#AllLineSizeProc,title="Size:"
	Setvariable allLineSize,variable=DFR_color:gv_linesize
	//PopupMenu allLineSize,mode=1,bodyWidth= 60*SC,popvalue="",value= #"\"*LINESTYLEPOP*\""
	
	
	GroupBox colorsQuickSetGroup,pos={10*SC,185*SC},size={280*SC,117*SC},title="Colors Quick Set"
	PopupMenu ColorPop,pos={20*SC,210*SC},size={178*SC,24*SC},proc=KBColorizeTraces_panel#ColorizePopMenuProc,title="Reset All Traces To:"
	PopupMenu ColorPop,help={"Sets all traces in the active graph to the color you choose."}
	PopupMenu ColorPop,mode=1,bodyWidth= 60*SC,popColor= (0,0,0),value= #"\"*COLORPOP*\""
	PopupMenu ColorTablePop,pos={15*SC,238*SC},size={244*SC,24*SC},proc=KBColorizeTraces_panel#KBColorTablePopMenuProc,title="Set Traces To:"
	PopupMenu ColorTablePop,help={"Sets all traces in the active graph using the entire range of the color table you choose."}
	PopupMenu ColorTablePop,mode=56,bodyWidth= 150*SC,popvalue="",value= #"\"*COLORTABLEPOP*\""
	Button commonColorsButton,pos={15*SC,270*SC},size={154*SC,20*SC},proc=CommonColorsButtonProc,title="Commonly-Used Colors"
	Button commonColorsButton,help={"Sets all traces in the active graph to a range of commonly-used colors. The colors repeat every 10 traces."}
	checkbox ColorTableck,pos={185*SC,273*SC},size={80*SC,20*SC},proc=KBColorizeTraces_panel#KBColorTableCheckboxMenuProc,title="Reverse",value=0
	//Button commonColorsButton1,pos={160,270},size={135,20},proc=CommonColorsButtonProc,title="Set Color Wheel"
	
	GroupBox colorWheelGroup,pos={10*SC,307*SC},size={280*SC,190*SC},title="Color Wheel"
	TitleBox hueTitle,pos={26*SC,328*SC},size={73*SC,16*SC},title="Starting Point",frame=0
	TitleBox saturationTitle,pos={123*SC,328*SC},size={60*SC,16*SC},title="Saturation",frame=0
	TitleBox lightnessTitle,pos={210*SC,328*SC},size={57*SC,16*SC},title="Lightness",frame=0
	// the global variables don't exist until RestoreKBColorizePanelSettings is called, so they're set there, not here
	Slider hueSlider,pos={24*SC,348*SC},size={25*SC,123*SC},proc=KBColorizeTraces_panel#KBJPColorizeSliderProc
	Slider hueSlider,help={"Sets the hue for the first trace. Other trace colors are distributed around the color wheel."}
	Slider hueSlider,limits={0,1,0.01},ticks= 0		// ,variable= root:Packages:KBColorize:gStartingHue
	Slider satSlider,pos={120*SC,348*SC},size={25*SC,123*SC},proc=KBColorizeTraces_panel#KBJPColorizeSliderProc
	Slider satSlider,help={"Sets the hue for the first trace. Other trace colors are distributed around the color wheel."}
	Slider satSlider,limits={0.2,1,0.01},ticks= 0	// ,variable= root:Packages:KBColorize:gSaturation
	Slider lightSlider,pos={207*SC,348*SC},size={25*SC,123*SC},proc=KBColorizeTraces_panel#KBJPColorizeSliderProc
	Slider lightSlider,help={"Sets the hue for the first trace. Other trace colors are distributed around the color wheel."}
	Slider lightSlider,limits={0.2,0.9,0.01},ticks= 0	// ,variable= root:Packages:KBColorize:gLightness
	CheckBox linearHue,pos={31*SC,502*SC},size={86*SC,16*SC},proc=KBColorizeTraces_panel#LinearCheckProc,title="Linear Hue "
	CheckBox linearHue,variable= DFR_color:gLinearHue,disable=1//root:Packages:KBColorize:

	GroupBox colorIndexGroup,pos={10*SC,497*SC},size={280*SC,50*SC},title="Set for Ctrl+1"
	DFREF DFR_GP=$DF_GP
	NVAR colorIndex=DFR_GP:gv_colorIndex
	PopupMenu ColorIndexPop,pos={20*SC,517*SC},size={178*SC,24*SC},proc=KBColorizeTraces_panel#Set_ColorIndex_proc,title="Default Color:"
	PopupMenu ColorIndexPop,mode=(colorIndex+1),value="Color_New10;Color_Rainbow;Color_Trad10;Color_BlueRedGreen3;"
		
	// restore control settings and create globals
	// RestoreKBColorizePanelSettings needs controls, creates the global variables
	RestoreKBColorizePanelSettings()

	ValDisplay hueReadout,pos={46*SC,476*SC},size={33*SC,17*SC},format="%.2f",frame=5
	ValDisplay hueReadout,limits={0,0,0},barmisc={0,1000}
	ValDisplay hueReadout,value= #(DFS_color+"gStartingHue")
	ValDisplay hueReadout1,pos={144*SC,476*SC},size={33*SC,17*SC},format="%.2f",frame=5
	ValDisplay hueReadout1,limits={0,0,0},barmisc={0,1000}
	ValDisplay hueReadout1,value= #(DFS_color+"gSaturation")
	ValDisplay hueReadout2,pos={232*SC,476*SC},size={33*SC,17*SC},format="%.2f",frame=5
	ValDisplay hueReadout2,limits={0,0,0},barmisc={0,1000}
	ValDisplay hueReadout2,value= #(DFS_color+"gLightness")
	
	// UpdateHueTicks needs globals, creates images
	UpdateHueTicks()

	// Create image subwindows

	DefineGuide UGH0={FT,357*SC},UGH1={FT,462*SC}
	DefineGuide UGH2={FL,47*SC},UGH3={FL,77*SC}
	Display/W=(52,172,82,295)/FG=(UGH2,UGH0,UGH3,UGH1)/HOST=$wname#KBColorizePanel
	AppendImage/T DFR_color:hueRGBImage
	ModifyImage hueRGBImage ctab= {*,*,Grays,0}
	ModifyGraph userticks(left)={DFR_color:hueTicks,DFR_color:hueTickLabels}
	ModifyGraph userticks(top)={DFR_color:hueTicks,DFR_color:hueTickLabels}
	ModifyGraph margin(left)=-1,margin(bottom)=-1,margin(top)=-1,margin(right)=-1
	ModifyGraph tick=2
	ModifyGraph mirror=0
	ModifyGraph nticks=10
	ModifyGraph noLabel=2
	ModifyGraph standoff=0
	ModifyGraph axThick(left)=0
	SetAxis/A/R left
	ModifyGraph swapXY=1
	RenameWindow #,G0
	SetActiveSubwindow ##
	DefineGuide UGH4={FL,145*SC},UGH5={FL,175*SC}
	Display/W=(147,172,177,293)/FG=(UGH4,UGH0,UGH5,UGH1)/HOST=$wname#KBColorizePanel 
	AppendImage/T DFR_color:satRGBImage
	ModifyImage satRGBImage ctab= {*,*,Grays,0}
	ModifyGraph margin(left)=-1,margin(bottom)=-1,margin(top)=-1,margin(right)=-1
	ModifyGraph mirror=0
	ModifyGraph nticks=0
	ModifyGraph noLabel=2
	ModifyGraph standoff=0
	ModifyGraph axThick=0
	SetAxis/A/R left
	ModifyGraph swapXY=1
	RenameWindow #,G1
	SetActiveSubwindow ##
	DefineGuide UGH6={FL,233*SC},UGH7={FL,263*SC}
	Display/W=(233,173,261,295)/FG=(UGH6,UGH0,UGH7,UGH1)/HOST=# 
	AppendImage/T DFR_color:lightRGBImage
	ModifyImage lightRGBImage ctab= {*,*,Grays,0}
	ModifyGraph margin(left)=-1,margin(bottom)=-1,margin(top)=-1,margin(right)=-1
	ModifyGraph mirror=0
	ModifyGraph nticks=0
	ModifyGraph noLabel=2
	ModifyGraph standoff=0
	ModifyGraph axThick=0
	SetAxis/A/R left
	ModifyGraph swapXY=1
	RenameWindow #,G2
	SetActiveSubwindow ##
	
	SetWindow $wname#KBColorizePanel,hook(KBColorize)=KBColorizeTraces_panel#KBColorizePanelHook
	
	SetDatafolder DF
End


//-------------- Private (static) Routines ---------------------------

static Function Set_ColorIndex_proc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	DFREF DF=GetDatafolderDFR()
	
	DFREF DFR_GP=$DF_GP
	
	SetDatafolder DFR_GP
	
	NVAR colorIndex=gv_colorIndex
	colorIndex=popNum-1
	
	SetDatafolder DF
End

static Function AllLinemarkmode(ctrlname,value)
String ctrlname
Variable value
	Variable ckvalue
	String wname=winname(0,1)
	strswitch(ctrlname)
	case "SetMarkers0":
	Modifygraph /W=$wname mode=0
	ckvalue=0
	break
	case "SetMarkers1":
	modifygraph /W=$wname mode=3
	ckvalue=1
	break
	case "SetMarkers2":
	modifygraph /W=$wname mode=4
	ckvalue=2
	break
	endswitch
	
	Checkbox SetMarkers0,win=$wname#KBColorizePanel, value=ckvalue==0
	Checkbox SetMarkers1,win=$wname#KBColorizePanel, value=ckvalue==1
	Checkbox SetMarkers2,win=$wname#KBColorizePanel, value=ckvalue==2
	
	
End

static Function KBColorizePanelHook(s)
	STRUCT WMWinHookStruct &s

	Variable statusCode= 0
	strswitch(s.eventName)
		case "kill":
			StoreKBColorizeSettings()
			Execute/P "DELETEINCLUDE <KBColorizeTraces>"
			Execute/P "COMPILEPROCEDURES "
			break
		//case "activate":
		//	UpdateHueTicks()
		//	break
	endswitch
	return statusCode		// 0 if nothing done, else 1
End


Function KBColorizeTracesOptLinear(lightness, saturation, startingHue,[useLinearHue])
	Variable lightness, saturation, startingHue	// 0-1
	Variable useLinearHue		// optional boolean. If false, use "warped" hue, new parameter for 6.03
	
	if( ParamIsDefault(useLinearHue) )
		useLinearHue= 0
	endif
	
	Variable traceIndex, numTraces
	
	numTraces = KBTracesInGraph("")
	if (numTraces <= 0)
		return 0
	endif
	
	for( traceIndex= 0; traceIndex < numTraces; traceIndex += 1 )
		Variable hue= mod(startingHue + traceIndex/numTraces, 1)	// 0-1
		if( !useLinearHue )
			hue= GetKBHueFromLinearHue(hue)	// 0-1
		endif
			
		Variable red, green, blue
		//GetRGBfromColorTab(1,red, green, blue)
		//KBHSLToRGB(hue*65535, saturation*65535, lightness*65535, red, green, blue)
		KBHSLToRGB_panel(hue, saturation, lightness, red, green, blue)
		ModifyGraph/Z rgb[traceIndex]=(red, green, blue)
	endfor

	return numTraces
End

Function KBColorizeTraces(lightness, saturation, startingHue)
	Variable lightness, saturation, startingHue	// 0-1

	return KBColorizeTracesOptLinear(lightness, saturation, startingHue)
End


Function KBColorizeTracesLinearHue(lightness, saturation, startingHue)
	Variable lightness, saturation, startingHue	// 0-1
	
	return KBColorizeTracesOptLinear(lightness, saturation, startingHue, useLinearHue=1)
End

static Constant ksNumDemoColors= 100

static Function CreateHSLImages(useLinearHue, startHue, sat, light)
	Variable useLinearHue		// boolean. If false, use "warped" hue
	Variable startHue, sat, light	// 0...1, startHue is a linear index into the HSL space
	DFREF DF=GetDatafolderDFR()
	String graphName = WinName(0, 65)
	DFREF DFR_Color=$(DF_GP+graphName+":KBColorize:")
	
	SetDatafolder DFR_Color
	//NewDataFolder/O  root:Packages
	//NewDataFolder/O  root:Packages:KBColorize
	
	Wave w_selectColortab=DFR_Color:w_selectColortab
	Wave w_selectColorTab_hsl=DFR_Color:w_selectColortab_hsl
	
	// make hue image
	Make/O/N=(ksNumDemoColors,1,3)/U/W DFR_Color:hueRGBImage
	WAVE/U/W hueRGBImage= DFR_Color:hueRGBImage
	SetScale x, 0, 1, "", hueRGBImage
	//hueRGBImage[][][0]=w_selectcolortab(x)[0][0]
	//hueRGBImage[][][1]=w_selectcolortab(x)[0][1]
	//hueRGBImage[][][2]=w_selectcolortab(x)[0][2]
	//if( useLinearHue )
		//hueRGBImage[][][0] = mod(0+p*65535/ksNumDemoColors, 65535)	// varying hues. since we distribute them differently, we should modify this as per KB
	//else
		// Colors are evenly distributed in "hue", except around
		// green-blue, where they move more quickly, since color perception isn't as good there. 
		// those colors are centered at Hue = 0.7 and Hue=0.35
		//hueRGBImage[][][0] = limit(GetKBHueFromLinearHue(p/ksNumDemoColors)*65535,0,65535)// varying hues. since we distribute them differently, we should modify this as per KB
	//endif
	//hueRGBImage[][][1] = limit(sat*65535,0,65535)		// constant saturation
	//hueRGBImage[][][2] = limit(light*65535,0,65535)	// constant lightness
	hueRGBImage[][][0]=w_selectcolortab_hsl(x)[0][0]
	hueRGBImage[][][1]=w_selectcolortab_hsl(x)[0][1]
	hueRGBImage[][][2]=w_selectcolortab_hsl(x)[0][2]
	ImageTransform/O hsl2rgb hueRGBImage		// converts 0...65535 HSL values to 0...65535 /U/W RGB values
	
	// NOTE: ONLY the Hue image is capable of showing the colors of all the traces 
	// (since only that image has both saturation and lightness held constant).
	
	// Add user-defined ticks to the image plot #G0 right axis (remember the X and Y axes are swapped)
	// to indicate the chosen colors.
	Variable numTraces = KBTracesInGraph("")
	Make/O/N=(numTraces) DFR_Color:hueTicks= mod(startHue+p/numTraces,1)
	Make/O/N=(numTraces)/T DFR_Color:hueTickLabels= ""	// to make user ticks happy
	
	if( !useLinearHue )
		startHue= GetKBHueFromLinearHue(startHue)
	endif
	// make saturation image from 0.2 to 1
	Make/O/N=(ksNumDemoColors,1,3)/U/W DFR_Color:satRGBImage
	WAVE/U/W satRGBImage= DFR_Color:satRGBImage
	satRGBImage[][][0] =  w_selectcolortab_hsl(startHue)[0][0]//mod(startHue*65535, 65535)	// constant hue
	satRGBImage[][][1] = (0.2 + 0.8*p/ksNumDemoColors)*65535		// increasing saturation
	satRGBImage[][][2] =  w_selectcolortab_hsl(startHue)[0][2]//limit(light*65535,0,65535)	// constant lightness
	ImageTransform/O hsl2rgb satRGBImage	

	// make lightness image	range from 0.2 to 0.9
	Make/O/N=(ksNumDemoColors,1,3)/U/W DFR_Color:lightRGBImage
	WAVE/U/W lightRGBImage= DFR_Color:lightRGBImage
	lightRGBImage[][][0] = w_selectcolortab_hsl(startHue)[0][0]// mod(startHue*65535, 65535)	// constant hue
	lightRGBImage[][][1] = w_selectcolortab_hsl(startHue)[0][1]// limit(sat*65535,0,65535)		// constant saturation
	lightRGBImage[][][2] = (0.2 +0.7*p/ksNumDemoColors)*65535	// increasing lightness
	ImageTransform/O hsl2rgb lightRGBImage	
	
	SetDatafolder DF
End


// Find the number of traces on the top graph
static Function KBTracesInGraph(win)	// "" for top graph
	String win
	
	if( strlen(win) == 0 )
		win= WinName(0,1)
		if( strlen(win) == 0 )
			return 0
		endif
	endif
	return ItemsInList(TraceNameList(win,";",3))
End


// GetKBHueFromLinearHue warps the hue space to accomplish this goal:
// Colors are evenly distributed in "hue", except around
// green-blue, where they move more quickly, since color perception isn't as good there. 
// those colors are centered at Hue = 0.7 and Hue=0.35

static Function GetKBHueFromLinearHue(linearHue)
	Variable linearHue // 0-1
	
	Variable red, green, blue
	KBGetColorRGB( 0.5, 1, linearHue, red, green, blue)

	Variable warpedHue, sat, light
	
	KBRGBToHSL(red, green, blue, warpedHue, sat, light)

	return warpedHue/65535	// 0-1
End

// convert RGB to HSL
static Function KBRGBToHSL(red, green, blue, hue, sat, light)
	Variable red, green, blue	// inputs, 0-65535
	Variable &hue, &sat, &light	// outputs, 0-65535
	DFREF DF=GetDatafolderDFR()
	String graphName = WinName(0, 65)
	DFREF DFR_Color=$(DF_GP+graphName+":KBColorize:")
	SetDatafolder DFR_color
	
	Make/O/N=(1,1,3)/U/W DFR_color:rgbhsl
	WAVE rgbhsl=DFR_color:rgbhsl
	rgbhsl[0][0][0]= round(red)
	rgbhsl[0][0][1]= round(green)
	rgbhsl[0][0][2]= round(blue)
	
	ImageTransform/O rgb2hsl rgbhsl
	
	hue=rgbhsl[0][0][0]*257		// 0-65535
	sat=rgbhsl[0][0][1]*257		// 0-65535
	light= rgbhsl[0][0][2]*257	// 0-65535
	
	SetDatafolder DF
End

// convert HSL to RGB:

static Function KBHSLToRGB_panel(hue, sat, light, red, green, blue)
	Variable hue, sat, light	// inputs, 0-1.0
	Variable &red, &green, &blue	// outputs, 0-65535
	
	DFREF DF=GetDatafolderDFR()
	String graphName = WinName(0, 65)
	DFREF DFR_Color=$(DF_GP+graphName+":KBColorize:")
	SetDatafolder DFR_color

	Wave /U/W W_selectColorTab_hsl=DFR_color:W_selectColorTab_hsl
	
	Make/O/N=(1,1,3)/U/W DFR_color:rgbhsl
	WAVE rgbhsl= DFR_color:rgbhsl
	rgbhsl[0][0][0]= W_selectColorTab_hsl(hue)[0][0]
	rgbhsl[0][0][1]= W_selectColorTab_hsl(hue)[0][1]*sat
	rgbhsl[0][0][2]= (light<0.5)?(W_selectColorTab_hsl(hue)[0][2]*(light/0.5)):((65535-W_selectColorTab_hsl(hue)[0][2])*((light-0.5)/0.5)+W_selectColorTab_hsl(hue)[0][2])
	ImageTransform/O hsl2rgb rgbhsl
	red=rgbhsl[0][0][0]	// 0-65535
	green=rgbhsl[0][0][1]	// 0-65535
	blue= rgbhsl[0][0][2]	// 0-65535
	SetDatafolder DF
End

static Function KBHSLToRGB(hue, sat, light, red, green, blue)
	Variable hue, sat, light	// inputs, 0-65535
	Variable &red, &green, &blue	// outputs, 0-65535
	
	DFREF DF=GetDatafolderDFR()
	String graphName = WinName(0, 65)
	DFREF DFR_Color=$(DF_GP+graphName+":KBColorize:")
	SetDatafolder DFR_color
	
	Make/O/N=(1,1,3)/U/W DFR_color:rgbhsl
	WAVE rgbhsl= DFR_color:rgbhsl
	rgbhsl[0][0][0]= hue
	rgbhsl[0][0][1]= sat
	rgbhsl[0][0][2]= light
	ImageTransform/O hsl2rgb rgbhsl
	red=rgbhsl[0][0][0]	// 0-65535
	green=rgbhsl[0][0][1]	// 0-65535
	blue= rgbhsl[0][0][2]	// 0-65535
	SetDatafolder DF
End

static Function GetRGBfromColorTab(Tabindex,red,green,blue)
	Variable Tabindex
	Variable &red,&green,&blue
	
	DFREF DF=GetDatafolderDFR()
	String graphName = WinName(0, 65)
	DFREF DFR_Color=$(DF_GP+graphName+":KBColorize:")
	SetDatafolder DFR_color

	Wave W_selectColorTab
	
	//ColorTab2Wave $ctabname	// creates M_colors
	Wave M_colors
	duplicate /o M_colors W_selectColorTab
	SetDatafolder DF
End


static Function KBGetColorRGB( lightness, saturation, ratio, red, green, blue )
	Variable lightness, saturation	// 0-1
	Variable ratio // 0-1, really a hue
	Variable &red, &green, &blue	// outputs, 0-65535
	
	Variable rmin, rmax, gmin, gmax, bmin,bmax, phi, r,g,b

	bmax = 65535*lightness
	bmin = 65535*max(min((lightness-saturation), 1), 0)
	
	// Reduce red and green maximum values, since red is brighter
	// than blue, and green is brighter still.  This started out using
	// CIE values, but that didn't look good, so it's just empirical now.
	rmin = bmin/1; rmax = bmax/1
	gmin = bmin/1.5; gmax = bmax/1.5
	
	phi= ratio * ((2*PI)-1)		// phi will determine the "hue".
	
	// Make phi move faster between 1.5 and 2.5, since color
	// sensitivity is less in that region.
	if( phi > 2.5 )
		phi += 1
	else
		if( phi > 1.5 )
			phi += (phi-1.5)
		endif
	endif
	
	// Calculate r, g, and b
	if( phi < 2*PI/3 ) 
		red= rmin + (rmax-rmin)*(1+cos(phi))/2
		green=  gmin + (gmax-gmin)*(1+cos(phi-2*PI/3))/2
		blue= bmin
	else
		if( phi < 4*PI/3 )
			red= rmin
			green= gmin + (gmax-gmin)*(1+cos(phi-2*PI/3))/2
			blue= bmin + (bmax-bmin)*(1+cos(phi-4*PI/3))/2
		else
			red= rmin + (rmax-rmin)*(1+cos(phi))/2
			green= gmin
			blue= bmin + (bmax-bmin)*(1+cos(phi-4*PI/3))/2
		endif
	endif
End

static Function UpdateColors()

	UpdateHueTicks()

	String graphName = WinName(0, 65)
	DFREF DFR_Color=$(DF_GP+graphName+":KBColorize:")
	
	if ( strlen(graphName))
		NVAR saturation = DFR_Color:gSaturation
		NVAR lightness = DFR_Color:gLightness
		NVAR startingHue = DFR_Color:gStartingHue
		NVAR linearHue = DFR_Color:gLinearHue
		KBColorizeTracesOptLinear(lightness, saturation, startingHue,useLinearHue=linearHue)
	endif
End

Static Function UpdateHueTicks()
	String graphName = WinName(0, 65)
	DFREF DFR_Color=$(DF_GP+graphName+":KBColorize:")
	
	NVAR saturation =  DFR_Color:gSaturation
	NVAR lightness =  DFR_Colore:gLightness
	NVAR startingHue =  DFR_Color:gStartingHue
	NVAR linearHue =  DFR_Color:gLinearHue
	
	CreateHSLImages(linearHue, startingHue, saturation, lightness)
End

static Function KBJPColorizeSliderProc(name, value, event) : SliderControl
	String name
	Variable value
	Variable event
	
	UpdateColors()
End

static Function LinearCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	UpdateColors()
End

//	StoreKBColorizeSettings()
//	Stores the state of the control panel settings in global variables in the
//	KBColorizePanel data folder.
static Function StoreKBColorizeSettings()

	String savedDataFolder = GetDataFolder(1)
	
	String graphName = WinName(0, 65)
	DFREF DFR_Color=$(DF_GP+graphName+":KBColorize:")
	SetDatafolder DFR_color
	
	String wname=Winname(0,1)
	// Markers Quick Set
	ControlInfo/W=$wname#KBColorizePanel allMarkers
	Variable/G gAllMarkersMenuItem= V_Value

	ControlInfo/W=$wname#KBColorizePanel markersSeries
	Variable/G gUniqueMarkersMenuItem= V_Value

	// Line Styles Quick Set
	ControlInfo/W=$wname#KBColorizePanel allLineStyles
	Variable/G gAllLineStylesMenuItem= V_Value
	
	// Colors Quick Set
	
	ControlInfo/W=$wname#KBColorizePanel ColorPop
	Variable/G gPopRed = V_red
	Variable/G gPopGreen = V_green
	Variable/G gPopBlue = V_blue

	ControlInfo/W=$wname#KBColorizePanel ColorTablePop
	String/G gColorTableName= S_value
	
	// Color Wheel
	// gStartingHue, gSaturation, gLightness and gLinearHue
	// global variables are set directly by their controls.

	SetDataFolder savedDataFolder
End

static Function RestoreKBColorizePanelSettings()
	DFREF savedDataFolder = GetDataFolderDFR()
	
	String wname=winname(0,1)
	
	DFREF DFR_Color=$(DF_GP+wname+":KBColorize:")
	SetDatafolder DFR_color
	//NewDataFolder/O/S root:Packages
	//NewDataFolder/O/S :KBColorize

	// Markers Quick Set
	NVAR/Z menuItem = gAllMarkersMenuItem
	if (NVAR_Exists(menuItem))
		PopupMenu allMarkers,win=$wname#KBColorizePanel, mode=menuItem
	endif

	NVAR/Z menuItem = gUniqueMarkersMenuItem
	if (NVAR_Exists(menuItem))
		PopupMenu markersSeries,win=$wname#KBColorizePanel, mode=menuItem
	endif

	// Line Styles Quick Set
	NVAR/Z menuItem = gAllLineStylesMenuItem
	if (NVAR_Exists(menuItem))
		PopupMenu allLineStyles,win=$wname#KBColorizePanel, mode=menuItem
	endif

	// Colors Quick Set
	NVAR/Z popRed = gPopRed
	NVAR/Z popGreen = gPopGreen
	NVAR/Z popBlue = gPopBlue
	if (NVAR_Exists(popRed))
		PopupMenu colorPop,win=$wname#KBColorizePanel, popColor=(popRed,popGreen,popBlue)
	endif

	SVAR/Z colorTableName = gColorTableName
	if (SVAR_Exists(colorTableName))
	else
		String /G gColorTableName="Rainbow"
	endif
	
	NVAR/Z gv_ctabreverseflag=gv_Ctabreverseflag
	if (NVAR_Exists(gv_Ctabreverseflag))
		checkbox colorTableck, value=gv_ctabreverseflag
	else
		Variable /G gv_ctabreverseflag=0
	endif
		
	SVAR colorTableName=gColorTableName	
		Variable ctableMenuItem= 1+WhichListItem(colorTableName, CTabList())
		PopupMenu colorTablePop,win=$wname#KBColorizePanel, mode=ctableMenuItem
		colortab2wave $colorTableName
		Wave M_colors
		if (gv_ctabreverseflag)
		Reverse /DIM=0 M_colors
		endif
		make /o/n=(dimsize(M_colors,0),1,3)/U/W W_selectColorTab,W_selectColorTab_hsl
		W_selectColorTab[][][]=M_colors[p][r]
		W_selectColorTab_hsl[][][]=M_colors[p][r]
		Setscale /I x,0,1,W_selectColorTab,W_selectColorTab_hsl
		WAVE/U/W w_selectColorTab_hsl
		Imagetransform /O/U rgb2hsl w_selectColorTab_hsl
	// Color Wheel
	NVAR/Z startingHue = gStartingHue
	if (!NVAR_Exists(startingHue))
		Variable/G gStartingHue= 0
	endif
	Slider hueSlider,win=$wname#KBColorizePanel,variable= DFR_color:gStartingHue
	
	NVAR/Z linearHue= gLinearHue
	if (!NVAR_Exists(linearHue))
		Variable/G gLinearHue= 0
	endif
	CheckBox linearHue,win=$wname#KBColorizePanel,variable= DFR_color:gLinearHue

	NVAR/Z saturation = gSaturation
	if (!NVAR_Exists(saturation))
		Variable/G gSaturation= 1
	endif
	Slider satSlider,win=$wname#KBColorizePanel,variable= DFR_color:gSaturation
	
	NVAR/Z lightness = gLightness
	if (!NVAR_Exists(lightness))
		Variable/G gLightness= 0.5
	endif
	Slider lightSlider,win=$wname#KBColorizePanel,variable=DFR_color:gLightness
	
	ControlUpdate/W=$wname#KBColorizePanel/A
	
	SetDataFolder savedDataFolder
End

Static Function ColorizePopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String graphName = WinName(0, 1)
	if (strlen(graphName) == 0)
		return -1
	endif
	
	StoreKBColorizeSettings()	

	ControlInfo $ctrlName				// Another way: sets V_Red, V_Green, V_Blue
	ModifyGraph rgb=(V_Red, V_Green, V_Blue)
End

Function CommonColorsButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	String graphName = WinName(0, 1)
	if (strlen(graphName) == 0)
		return -1
	endif
	
	Variable numTraces = KBTracesInGraph("")

	if (numTraces <= 0)
		return -1
	endif

	Variable red, green, blue
	Variable i, index
	for(i=0; i<numTraces; i+=1)
		index = mod(i, 10)				// Wrap after 10 traces.
		switch(index)
			case 0:
				red = 0; green = 0; blue = 0;
				break

			case 1:
				red = 65535; green = 16385; blue = 16385;
				break
				
			case 2:
				red = 2; green = 39321; blue = 1;
				break
				
			case 3:
				red = 0; green = 0; blue = 65535;
				break
				
			case 4:
				red = 39321; green = 1; blue = 31457;
				break
				
			case 5:
				red = 48059; green = 48059; blue = 48059;
				break
				
			case 6:
				red = 65535; green = 32768; blue = 32768;
				break
				
			case 7:
				red = 0; green = 65535; blue = 0;
				break
				
			case 8:
				red = 16385; green = 65535; blue = 65535;
				break
				
			case 9:
				red = 65535; green = 32768; blue = 58981;
				break
		endswitch
		ModifyGraph rgb[i]=(red, green, blue)
	endfor
End

static Function/S KBColorTabWave(ctabName)
	String ctabName
	
	DFREF savedDataFolder= GetDatafolderDFR()
	
	String wname=winname(0,1)
	
	DFREF DFR_Color=$(DF_GP+wname+":KBColorize:")
	SetDatafolder DFR_color
	
	NVAR gv_ctabreverseflag=gv_ctabreverseflag
	
	ColorTab2Wave $ctabname	// creates M_colors
	Wave M_colors
	if (gv_ctabreverseflag)
		Reverse /DIM=0 M_colors
	endif
	make /o/n=(dimsize(M_colors,0),1,3)/U/W W_selectColorTab,W_selectColorTab_hsl
	W_selectColorTab[][][]=M_colors[p][r]
	W_selectColorTab_hsl[][][]=M_colors[p][r]
	Setscale /I x,0,1,W_selectColorTab,W_selectColorTab_hsl
	WAVE/U/W w_selectColorTab_hsl
	Imagetransform /O/U rgb2hsl w_selectColorTab_hsl
	//ColorTab2Wave $ctabname	// creates M_colors
	//Wave M_colors
	SetDataFolder savedDataFolder
	return GetWavesDataFolder(M_colors,2)
End

static Function KBColorTableCheckboxMenuProc(ctrlName,value) 
	String ctrlName
	Variable value
	
	StoreKBColorizeSettings()	
	
	String graphName = WinName(0, 65)
	if (strlen(graphName) == 0)
		return -1
	endif
	
	Variable numTraces =KBTracesInGraph(graphName)
	if (numTraces <= 0)
		return -1
	endif
	
	if( numTraces < 2 )
		numTraces= 2	// avoid divide by zero, use just the first color for 1 trace
	endif
	
	DFREF DFR_Color=$(DF_GP+graphName+":KBColorize:")
		
	NVAR gv_ctabreverseflag=DFR_color:gv_ctabreverseflag
	gv_ctabreverseflag=value
	
	controlinfo /W=$graphname#KBColorizePanel ColorTablePop
	Wave rgb_cb= $KBColorTabWave(S_Value)
	Variable numRows= DimSize(rgb_cb,0)
	Variable red, green, blue
	Variable i, index
	for(i=0; i<numTraces; i+=1)
		index = round(i/(numTraces-1) * (numRows-1))	// spread entire color range over all traces.
		ModifyGraph rgb[i]=(rgb_cb[index][0], rgb_cb[index][1], rgb_cb[index][2])
	endfor
	
	DFREF DFR_Color=$(DF_GP+graphname+":KBColorize:")
	
	NVAR saturation = DFR_Color:gSaturation
	NVAR lightness = DFR_Color:gLightness
	NVAR startingHue = DFR_Color:gStartingHue
	NVAR linearHue = DFR_Color:gLinearHue
	
	startingHue=0
	saturation=0.99
	lightness=0.5
	//linearHue=1
	
	UpdateColors()
	
End

static Function KBColorTablePopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	StoreKBColorizeSettings()	

	String graphName = WinName(0, 65)
	if (strlen(graphName) == 0)
		return -1
	endif

	Variable numTraces =KBTracesInGraph(graphName)
	if (numTraces <= 0)
		return -1
	endif
	
	if( numTraces < 2 )
		numTraces= 2	// avoid divide by zero, use just the first color for 1 trace
	endif

	

	Wave rgb_cb= $KBColorTabWave(popStr)
	//Variable numRows= DimSize(rgb_cb,0)
	//Variable red, green, blue
	//Variable i, index
	//for(i=0; i<numTraces; i+=1)
	//	index = round(i/(numTraces-1) * (numRows-1))	// spread entire color range over all traces.
	//	ModifyGraph rgb[i]=(rgb_cb[index][0], rgb_cb[index][1], rgb_cb[index][2])
	//endfor
	
	DFREF DFR_Color=$(DF_GP+graphname+":KBColorize:")
	
	NVAR saturation = DFR_Color:gSaturation
	NVAR lightness = DFR_Color:gLightness
	NVAR startingHue = DFR_Color:gStartingHue
	NVAR linearHue = DFR_Color:gLinearHue
	
	startingHue=0
	saturation=0.99
	lightness=0.5
	//linearHue=0
	
	//UpdateHueTicks()
	
	UpdateColors()
	

	
End

static Function AllMarkersPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	StoreKBColorizeSettings()	
	ModifyGraph marker=(popNum-1)
End

static Function UniqueMarkersPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	StoreKBColorizeSettings()	

	Variable numTraces = KBTracesInGraph("")
	if (numTraces <= 0)
		return -1
	endif

//value= #"\"All;Only Filled;Only Outlined;Only Lines;Only Round;Only Square;Only Diamond;Only Triangle;Only Crosses;Random;\""

	DFREF df= GetDataFolderDFR()
	String graphName = WinName(0, 65)
	DFREF DFR_Color=$(DF_GP+graphname+":KBColorize:")
	SetDatafolder DFR_color
	
	strswitch(popStr)
		case "All Sequential":
				Make/O/N=51 markers=p
				break
		case "All Random":
				Make/O/N=51 markers=p, key=enoise(1)
				Sort key, markers
				break
		case "Only Filled":
				Make/O markers={19,16,17,23,46,49,26,29,18,32,34,36,38,15,14}
				break
		case "Only Outlined":
				Make/O markers={8,5,6,22,45,48,25,28,7,41,13,44,24,47,50,27,30,40,42,11,31,33,4,3,43,12,35,37}
				break
		case "Only Lines":
				Make/O markers={0,1,2,9,10,20,21,39}
				break
		case "Only Round":
				Make/O markers={8,19,41,42,43}
				break
		case "Only Square":
				Make/O markers={5,16,13,11,12}
				break
		case "Only Diamond":
				Make/O markers={7,18,40,25,26,27,28,29,30}
				break
		case "Only Triangle":
				Make/O markers={6,22,45,48,17,23,46,46,44,24,47,50}
				break
		case "Only Crosses":
				Make/O markers={1,0,2,39,12,11,43,42}
				break
	endswitch
	Wave markers
	Variable numMarkers= numpnts(markers)
	SetDataFolder df

	Variable i, row
	for(i=0; i<numTraces; i+=1)
		row = mod(i, numMarkers)	// repeat if we run out of markers
		ModifyGraph marker[i]=markers[row]
	endfor

End

static Function AllLineSizeProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	String wname=winname(0,1)
	DFREF DFR_GP=$DF_GP+wname+":KBColorize"
	
	NVAR linesize=DFR_GP:gv_linesize
	
	ModifyGraph /w=$wname lsize=linesize
End

static Function AllLineStylesPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	StoreKBColorizeSettings()	

	Variable numTraces = KBTracesInGraph("")
	if (numTraces <= 0)
		return -1
	endif
	Variable i
	for(i=0; i<numTraces; i+=1)
		ModifyGraph lstyle[i]=popNum-1
	endfor

End

static Function UniqueLineStylesButtonProc(ctrlName) : ButtonControl
	String ctrlName

	StoreKBColorizeSettings()	

	Variable numTraces = KBTracesInGraph("")
	if (numTraces <= 0)
		return -1
	endif
	Variable i
	for(i=0; i<numTraces; i+=1)
		Variable lstyle= mod(i,18)
		ModifyGraph lstyle[i]=lstyle
	endfor
End





static Function EditAppearances(ctrlname)
	String Ctrlname
	string tl,tn,ti
	DFREF Df=GetDataFolderDFR()
	variable k,p0,p1,p2,p3,p4,p5
	NewDataFolder/O/S root:internalUse:GP_Macro:EditApp
	String/G win=""
	win=WinName(0,1)
	Make/B/U/O/N=0 mode,marker
	Make/O/N=0 lsize,msize
	Make/W/U/O/N=0 red,green,blue
	Make/D/O/N=0 xoffset,yoffset
	Make/T/O/N=0 tracenames
	tl=TraceNameList("",";",3)
	do
		p1=strsearch(tl,";",p0)+1
		if (!p1)
			break
		endif
		tn=tl[p0,p1-2]
		tracenames[k]={tn}
		ti=TraceInfo("",tn, 0)
		p2=strsearch(ti,"mode(x)",0)+8
		p3=strsearch(ti,";",p2)-1
		mode[k]={str2num(ti[p2,p3])}
		p2=strsearch(ti,"marker(x)",p3+2)+10
		p3=strsearch(ti,";",p2)-1
		marker[k]={str2num(ti[p2,p3])}
		p2=strsearch(ti,"lSize(x)",p3+2)+9
		p3=strsearch(ti,";",p2)-1
		lsize[k]={str2num(ti[p2,p3])}	
		p2=strsearch(ti,"rgb(x)",p3+2)+8
		p3=strsearch(ti,",",p2)
		p4=strsearch(ti,",",p3+1)
		p5=strsearch(ti,")",p4+1)-1
		red[k]={str2num(ti[p2,p3-1])}
		green[k]={str2num(ti[p3+1,p4-1])}
		blue[k]={str2num(ti[p4+1,p5])}
		p2=strsearch(ti,"msize(x)",p5+2)+9
		p3=strsearch(ti,";",p2)-1
		msize[k]={str2num(ti[p2,p3])}
		p2=strsearch(ti,"offset(x)",p3+2)+11
		p3=strsearch(ti,",",p2)+1
		p4=strsearch(ti,"}",p2)-1
		xoffset[k]={str2num(ti[p2,p3-2])}
		yoffset[k]={str2num(ti[p3,p4])}
		p0=p1; k+=1
	while (1)
	if (!WinType("AppearancesTable"))
		Edit tracenames,xoffset,yoffset,mode,marker,lsize,msize,red,green,blue as "Appearances of \""+win+"\""
		Execute "ModifyTable width=30,width(point)=0,style(tracenames)=1,width(tracenames)=90,width(xoffset)=60,width(yoffset)=60"
		DoWindow/C AppearancesTable
		SetWindow kwTopWin, hook(s) = GetAppearances
	else
		DoWindow/F AppearancesTable
		SetWindow kwTopWin, hook(s) = GetAppearances
	endif
	SetDataFolder Df
End


Function GetAppearances(s)
STRUCT WMWinHookStruct &s
Variable r=0
Variable i=0
Variable delta
DFREF DFR_APP=$"root:internalUse:GP_Macro:EditApp"
Switch(s.eventcode)
		case 11:
		 if (s.keycode==32)
		 String WinN=winname(0,2)
	     Getselection table,$winN,3
	     if (strsearch(S_selection,"xoffset",0)!=-1)
	     WAVE xoffset=DFR_APP:xoffset
	     SetVariables(V_startrow,V_endrow,xoffset)
	     r=1
	     endif
	     if (strsearch(S_selection,"yoffset",0)!=-1)
	     WAVE yoffset=DFR_APP:yoffset
	     SetVariables(V_startrow,V_endrow,yoffset)
	     r=1
	     endif
	     if (strsearch(S_selection,"mode",0)!=-1)
	     WAVE mode=DFR_APP:mode
	     SetVariables(V_startrow,V_endrow,mode)
	     r=1
	     endif
	     if (strsearch(S_selection,"marker",0)!=-1)
	     WAVE marker=DFR_APP:marker
	     SetVariables(V_startrow,V_endrow,marker)
	     r=1
	     endif
	     if (strsearch(S_selection,"lsize",0)!=-1)
	     WAVE lsize=DFR_APP:lsize
	     SetVariables(V_startrow,V_endrow,lsize)
	     r=1
	     endif
	     if (strsearch(S_selection,"msize",0)!=-1)
	     WAVE msize=DFR_APP:msize
	     SetVariables(V_startrow,V_endrow,msize)
	     r=1
	     endif
	     if (strsearch(S_selection,"red",0)!=-1)
	     WAVE red=DFR_APP:red
	     SetVariables(V_startrow,V_endrow,red)
	     r=1
	     endif
	     if (strsearch(S_selection,"green",0)!=-1)
	     WAVE green=DFR_APP:green
	     SetVariables(V_startrow,V_endrow,green)
	     r=1
	     endif
	     if (strsearch(S_selection,"blue",0)!=-1)
	     WAVE blue=DFR_APP:blue
	     SetVariables(V_startrow,V_endrow,blue)
	     r=1
	     endif
	     if (r==1)
		 SetAppearances()
		 endif
		 endif
		break
		case 2:
		 SetAppearances()
		 r=1
		break
		case 0:
		 SetAppearances()
		 r=1
		break
		case 1:
		 SetAppearances()
		 r=1
		break
  endswitch
  return r
End



Function SetAppearances()
	string Df=GetDataFolder(1)
	SetDataFolder root:InternalUse:GP_Macro:EditApp
	SVAR win=root:InternalUse:GP_Macro:EditAPP:win
	wave/B/U md=mode,mk=marker,ls=lsize,ms=msize,r=red,g=green,b=blue
	wave/D xo=xoffset,yo=yoffset
	wave/T wt=tracenames
	variable k=numpnts(wt)+1
	do
		k-=1
		ModifyGraph/Z /W=$win mode($wt[k])=md[k],marker($wt[k])=mk[k],lsize($wt[k])=ls[k],msize($wt[k])=ms[k],offset($wt[k])={xo[k],yo[k]},rgb($wt[k])=(r[k],g[k],b[k])
	while (k)
	SetDataFolder Df
End


