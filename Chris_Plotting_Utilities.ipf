#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
Function KillAllGraphs()
  // Kill all graphs in an experiment
  // Nuke them from orbit, only way to be sure
  string fulllist = WinList("*", ";","WIN:1")
  string name, cmd
  variable i
  for(i=0; i<itemsinlist(fulllist); i +=1)
    name= stringfromlist(i, fulllist)
    sprintf  cmd, "Dowindow/K %s", name
    execute cmd		
  endfor
end
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
function LoadCustomColorScales()
  // For this to work the python colorscales need to be in the subfolder "Colorscales"
  //in the Igor Pro User Files folder.  Loads the following colorscales and labels with prefix _CW
  // Python >> Magma, Inferno, Plasma, Viridis, Cividis, Aggrnyl
  // Custom >> KSA
  
  NewPath/O/Q ColorPath, SpecialDirPath("Igor Pro User Files",0,0,0)+"Colorscales"
  // Save all of these in a special folder under root
  string FolderName = "root:ChrisCW"; string TheName
  NewDataFolder/O $FolderName  // Make it if it doesn't already exist
  
  // Build Python's Magma colorscale   
  loadwave/O/P=ColorPath/Q/G/N='xtempx' "Magma.txt"
  wave xtempx0, xtempx1, xtempx2
  TheName = FolderName + ":CW_Magma"; make/O/W/U/N=(256,3) $TheName; wave CW_Magma = $TheName
  CW_Magma[][0]=xtempx0[p]*65535; CW_Magma[][1]=xtempx1[p]*65535; CW_Magma[][2]=xtempx2[p]*65535
  // Build Python's Inferno colorscale
  loadwave/O/P=ColorPath/Q/G/N='xtempx' "Inferno.txt"
  TheName = FolderName + ":CW_Inferno"; make/O/W/U/N=(256,3) $TheName; wave CW_Inferno = $TheName
  CW_Inferno[][0]=xtempx0[p]*65535; CW_Inferno[][1]=xtempx1[p]*65535; CW_Inferno[][2]=xtempx2[p]*65535
  // Build Python's Plasma colorscale
  loadwave/O/P=ColorPath/Q/G/N='xtempx' "Plasma.txt"
  TheName = FolderName + ":CW_Plasma"; make/O/W/U/N=(256,3) $TheName; wave CW_Plasma = $TheName
  CW_Plasma[][0]=xtempx0[p]*65535; CW_Plasma[][1]=xtempx1[p]*65535; CW_Plasma[][2]=xtempx2[p]*65535
  // Build Python's Viridis colorscale
  loadwave/O/P=ColorPath/Q/G/N='xtempx' "Viridis.txt"
  TheName = FolderName + ":CW_Viridis"; make/O/W/U/N=(256,3) $TheName; wave CW_Viridis = $TheName
  CW_Viridis[][0]=xtempx0[p]*65535; CW_Viridis[][1]=xtempx1[p]*65535; CW_Viridis[][2]=xtempx2[p]*65535
  // Build Plotly's Cividis colorscale  
  loadwave/O/P=ColorPath/Q/G/N='xtempx' "Cividis.txt"
  TheName = FolderName + ":CW_Cividis"; make/O/W/U/N=(256,3) $TheName; wave CW_Cividis = $TheName
  xtempx0=xtempx0*65535/256; xtempx1=xtempx1*65535/256; xtempx2=xtempx2*65535/256
  CW_Cividis[][0]=xtempx0[p]; CW_Cividis[][1]=xtempx1[p]; CW_Cividis[][2]=xtempx2[p]
  // Build Plotly's Thermal colorscale  
  loadwave/O/P=ColorPath/Q/G/N='xtempx' "Thermal.txt"
  TheName = FolderName + ":CW_Thermal"; make/O/W/U/N=(256,3) $TheName; wave CW_Thermal = $TheName
  xtempx0=xtempx0*65535/256; xtempx1=xtempx1*65535/256; xtempx2=xtempx2*65535/256
  CW_Thermal[][0]=xtempx0[p]; CW_Thermal[][1]=xtempx1[p]; CW_Thermal[][2]=xtempx2[p]  
  // Build Plotly's Aggrnyl colorscale  
  loadwave/O/P=ColorPath/Q/G/N='xtempx' "Aggrnyl.txt"
  TheName = FolderName + ":CW_Aggrnyl"; make/O/W/U/N=(256,3) $TheName; wave CW_Aggrnyl = $TheName
  xtempx0=xtempx0*65535/256; xtempx1=xtempx1*65535/256; xtempx2=xtempx2*65535/256
  CW_Aggrnyl[][0]=xtempx0[p]; CW_Aggrnyl[][1]=xtempx1[p]; CW_Aggrnyl[][2]=xtempx2[p]   
  // Build the custom color scale "KSA"
  loadwave/O/P=ColorPath/Q/G/N='xtempx' "KSA.txt"
  TheName = FolderName + ":CW_KSA"; make/O/W/U/N=(256,3) $TheName; wave CW_KSA = $TheName
  CW_KSA[][0]=xtempx0[p]; CW_KSA[][1]=xtempx1[p]; CW_KSA[][2]=xtempx2[p]
  // Build the custom color scale "Phil"
  loadwave/O/P=ColorPath/Q/G/N='xtempx' "Phil.txt"
  TheName = FolderName + ":CW_Phil"; make/O/W/U/N=(256,3) $TheName; wave CW_Phil = $TheName
  CW_Phil[][0]=xtempx0[p]; CW_Phil[][1]=xtempx1[p]; CW_Phil[][2]=xtempx2[p]
  // Clean Up
  KillWaves/Z xtempx0, xtempx1, xtempx2  
End
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
Function MakeADifference([colorscalename,thickness,backwards])
  string colorscalename
  variable thickness   // Also can set the thickness of the traces to improve visibility
  variable backwards   // default zero, set to 1 to reverse the color order of the traces
  if(paramIsDefault(colorscalename))
    colorscalename =  "Turbo"
  endif
  backwards = paramIsDefault(backwards) ? 0   : backwards
  thickness = paramIsDefault(thickness) ? 1.5 : thickness  // By default use 1.5 point
  // Stolen and modified from this forum post: https://www.wavemetrics.com/forum/igor-pro-wish-list/automatically-color-traces-multi-trace-graph
  String Traces  = TraceNameList("",";",1)  // get all the traces from the graph
  Variable Items = ItemsInList(Traces)      // count the traces
  
  // Pick a colorscale, then make a reduced version of it.  Uses blueredgreen256 by default 
  colortab2wave $colorscalename
  wave M_colors
  Make/FREE/N=(Items,3) clrwv
  if(backwards > 0)
    clrwv = M_colors[round((Items-p-1)*(dimsize(M_colors,0))/(Items))][q]  
  else
    clrwv = M_colors[round(p*dimsize(M_colors,0)/Items)][q]
  endif
  killwaves/Z M_colors
  variable i 
  for(i=0; i<Items; i++)
    ModifyGraph rgb($StringFromList(i,Traces))=(clrwv[i][0],clrwv[i][1],clrwv[i][2])
  endfor
  // By default let's use 1.5 thickness, easier to see on the screen
  SetTraceThickness(thickness)
END
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
Function SetTraceThickness(thickness)
  variable thickness
  if(thickness < 0 || thickness > 10)
    Print "Thickness out of bounds, won't work"
    return -1
  endif
  // If reasonable, proceed through the traces
  String Traces  = TraceNameList("",";",1)  // get all the traces from the graph
  Variable Items = ItemsInList(Traces)      // count the traces 
  variable i 
  for(i=0; i<Items; i++)
    ModifyGraph lsize($StringFromList(i,Traces)) = thickness
  endfor 
END
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
Function MakePlotNormal([logx,logy,same])
  variable logx, logy, same
  logx = paramIsDefault(logx) ? 0 : logx // X axis log? 1 or 0
  logy = paramIsDefault(logy) ? 0 : logy // Y axis log? 1 or 0
  same = paramIsDefault(same) ? 0 : same // Keep all trace colors the same? 1 or 0
  // Do all the usual things I like to do when I make an igor plot
  ModifyGraph mirror=2,axisOnTop=1,standoff=0,tick=2
  if(logy == 1 && logx == 1)
    ModifyGraph log=1
  elseif(logy == 1)
    ModifyGraph log(left)=1
  elseif(logx == 1)
    ModifyGraph log(bottom)=1
  endif
  // 0.5 pt axes
  ModifyGraph axThick=0.5
  if(same == 0)
    MakeADifference()
  endif
END
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
Function SetTraceOffsets([VerticalOffset,HorizontalOffset])
  // Offset all traces on a graph by a fixed amount, thus making a waterfall.
  variable VerticalOffset, HorizontalOffset  
  String Traces  = TraceNameList("",";",1)  // get all the traces from the graph
  Variable Items = ItemsInList(Traces)      // count the traces
  // By default do nothing
  VerticalOffset   = paramisdefault(VerticalOffset) ? NaN : VerticalOffset
  HorizontalOffset = paramisdefault(HorizontalOffset) ? NaN : HorizontalOffset
  variable i 
  for(i=0; i<Items; i++)
    if(numtype(VerticalOffset)==2 && numtype(HorizontalOffset)==2)
      // Do Nothing
    elseif(numtype(VerticalOffset)==0 && numtype(HorizontalOffset)==2)
      ModifyGraph/Z offset[i]={*,i*VerticalOffset}
    elseif(numtype(VerticalOffset)==2 && numtype(HorizontalOffset)==0)
      ModifyGraph/Z offset[i]={i*HorizontalOffset,*}
    elseif(numtype(VerticalOffset)==0 && numtype(HorizontalOffset)==0)
      ModifyGraph/Z offset[i]={i*HorizontalOffset,i*VerticalOffset}
    endif
  endfor
END
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Igor can display waterfall plots using the NewWaterfall operation (choose Windows->New->Packages->Waterfall Plot).
// This requires storing your data in a 2D wave. You can also create a 3D waterfall plot using Gizmo.
// However, for the common case of displaying a series of spectra, you may find that a "fake waterfall plot"
// is more convenient and works with your original waveform or XY data.
// A fake waterfall plot is a regular graph with multiple waveform or XY traces where you use Igor's X and Y
// trace display offset feature to create the waterfall effect. This is simple and also gives you a regular
// Igor graph with regular traces that you can format and annotate using familiar techniques.
// The ApplyFakeWaterfall function converts a regular graph to a fake waterfall plot.
// The RemoveFakeWaterfall function converts it back to a regular graph.
Function ApplyFakeWaterfall(graphName, dx, dy, hidden)		// e.g., ApplyFakeWaterfall("Graph0", 2, 100, 1)
	String graphName	// Name of graph or "" for top graph
	Variable dx, dy		// Used to offset traces to create waterfall effect
	Variable hidden		// If true, apply hidden line removal
	
	String traceList = TraceNameList(graphName, ";", 1)
	Variable numberOfTraces = ItemsInLIst(traceList)

	Variable traceNumber
	for(traceNumber=0; traceNumber<numberOfTraces; traceNumber+=1)
		String trace = StringFromList(traceNumber, traceList)
		Variable offsetX = (numberOfTraces-traceNumber-1) * dx
		Variable offsetY = (numberOfTraces-traceNumber-1) * dy
		ModifyGraph/W=$graphName offset($trace)={offsetX,offsetY}
		ModifyGraph/W=$graphName plusRGB($trace)=(65535,65535,65535)	// Fill color is white
		if (hidden)
			ModifyGraph/W=$graphName mode($trace)=7, hbFill($trace)=1		// Fill to zero, erase mode
		else
			ModifyGraph/W=$graphName mode($trace)=0						// Lines between points
		endif
	endfor
End
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
Function RemoveFakeWaterfall(graphName)		// e.g., RemoveFakeWaterfall("Graph0")
	String graphName	// Name of graph or "" for top graph
	
	String traceList = TraceNameList(graphName, ";", 1)
	Variable numberOfTraces = ItemsInLIst(traceList)

	Variable traceNumber
	for(traceNumber=0; traceNumber<numberOfTraces; traceNumber+=1)
		String trace = StringFromList(traceNumber, traceList)
		ModifyGraph/W=$graphName offset($trace)={0,0}
		ModifyGraph/W=$graphName mode($trace)=0							// Lines between points
		ModifyGraph/W=$graphName plusRGB($trace)=(65535,65535,65535)	// Fill color is white
	endfor
End
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
Function Make2DColorPlot(InputWaves,Xaxis,[interpmethod,Xdelta,Outname,plot])
  wave/T InputWaves  // Text wave of strings which has the names of the waves to use
  wave   Xaxis       // Wave of floats which define the "x-axis" values corresponding to InputWaves
  // Because I am lazy this assumes that InputWaves and Xaxis are both sorted in increasing order of X
  // It also assumes all of the InputWaves have similar ranges so they can be commonly gridded
  variable interpmethod // 0 for "nearest" interpolation and 1 for linear interpolation, 1 default
  variable Xdelta       // Spacing of points in the interpolated image
  string   Outname      // Name of output, if desired
  variable plot         // Default 0, set to 1 if you want a nice-ish plot
  interpmethod = paramisdefault(interpmethod) ? 1 : interpmethod
  plot = paramisdefault(plot) ? 0 : plot  // set to 1 if you want to make a plot
  make/FREE/N=(dimsize(Xaxis,0)-1) TempDiffs
  TempDiffs=Xaxis[P+1]-Xaxis[p]  // By default use min difference between steps / 5
  Xdelta = paramisdefault(Xdelta) ? wavemin(TempDiffs)/5.0 : Xdelta
  if(dimsize(Xaxis,0) != dimsize(InputWaves,0))
    print "Size Mismatch between supplied waves. Aborting"
    return 0;
  endif  
  if(paramIsDefault(Outname))
    Outname = "Output2D"
  endif
  // Ok, now we start setting up our waves
  // First step is deciding the range of "x-values"
  // Using interp method 0 we extend the top and botom "pixels" symetrically 
  // Using interp method 1 we use the min and max vals and don't extrapolate
  variable Xmin, Xmax
  if(interpmethod == 0)
    Xmin = Xaxis[0]-0.5*(Xaxis[1]-Xaxis[0])
    Xmax = Xaxis[dimsize(Xaxis,0)-1]+0.5*(Xaxis[dimsize(Xaxis,0)-1]-Xaxis[dimsize(Xaxis,0)-2])
  elseif(interpmethod == 1)
    Xmin = Xaxis[0]
    Xmax = Xaxis[dimsize(Xaxis,0)-1]
    if(!(Xmin < Xmax))
      Print "Xaxis is not sorted properly. Aborting"
      return 0;
    endif
  else
    print "Not a valid interpolation method, use 0 or 1. Aborting"
    return 0;
  endif
  // Next step is allocating the space for the waves
  string TheWaveName = InputWaves[0]; wave TempWave = $TheWaveName
  Variable Nx = dimsize(Xaxis,0)
  Variable Ny = dimsize(TempWave,0)
  Variable NxNew = ceil((Xmax-Xmin)/Xdelta)
  string TmpStr = Outname+"_Base"
  make/O/N=(Nx,Ny)  $TmpStr
  wave OutputBase = $TmpStr
  TmpStr = Outname+"_Interp"
  make/O/N=(NxNew,Ny)  $TmpStr
  wave OutputInterp = $TmpStr
  // Set the scales on the output waves
  setscale/I x, Xmin, Xmax, OutputInterp
  setscale/P y, dimoffset(TempWave,0), dimdelta(TempWave,0), OutputInterp
  setscale/P y, dimoffset(TempWave,0), dimdelta(TempWave,0), OutputBase
  make/O/FREE/N=(Ny)  TempStorage
  setscale/P x, dimoffset(TempWave,0), dimdelta(TempWave,0), TempStorage
  // Fill in the 2D wave of "Base" data
  variable i
  for(i=0; i<Nx; i++)
    TheWaveName = InputWaves[i]
    wave TempWave = $TheWaveName
    OutputBase[i][] = TempWave(dimoffset(OutputBase,1)+q*dimdelta(OutputBase,1))
  endfor
  // Finally, interpolate using the desired method
  variable xx, a
  if(interpmethod == 1)   
    for(i=0; i<NxNew; i++)
      xx = dimoffset(OutputInterp,0)+i*dimdelta(OutputInterp,0)
      a = FindIndexAbove(Xaxis,xx)
      TempStorage = (Xaxis[a]-xx)*OutputBase[a-1][p]/(Xaxis[a]-Xaxis[a-1]) + (xx-Xaxis[a-1])*OutputBase[a][p]/(Xaxis[a]-Xaxis[a-1])
      OutputInterp[i][] = TempStorage(dimoffset(OutputInterp,1)+q*dimdelta(OutputInterp,1))
    endfor
  elseif(interpmethod == 0)
    for(i=0; i<NxNew; i++)
      xx = dimoffset(OutputInterp,0)+i*dimdelta(OutputInterp,0)
      a = FindClosest1D(Xaxis,xx)
      TempStorage = OutputBase[a][p]
      OutputInterp[i][] = TempStorage(dimoffset(OutputInterp,1)+q*dimdelta(OutputInterp,1))
    endfor  
  endif
  // If Desired, make a plot
  if(plot>0)
    display;
    appendimage OutputInterp
    TmpStr = nameofwave(OutputInterp)
    ModifyImage $TmpStr ctab= {*,*,Turbo,1}
    SetAxis/R left -20,1
    ModifyGraph tick=2,mirror=2,axThick=0.5,axisOnTop=1,standoff=0,manTick(left)={0,5,0,0},manMinor(left)={4,0}
    Label left "Energy Loss (ev)"
    Label bottom "Incident Energy (eV)"
    ModifyGraph width=226.772,height=368.504
    ModifyGraph fSize=9,lblMargin(left)=10,lblMargin(bottom)=8
  endif
END