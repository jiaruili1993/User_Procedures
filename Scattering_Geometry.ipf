#pragma rtGlobals=1		// Use modern global access method.

Function Initial_Scattering_geometry()

	String DF = GetDataFolder (1)
	
	SetdataFolder root:internalUse
	NewDatafolder/o/s Scattering_Geometry
	

	Variable/G Lattice_a, Lattice_b, Lattice_c, PhotonEnergy, DetectorTheta, DetectorPhi, SampleTheta1, SampleTheta2
	Variable/G Ra, Rb, Rc, RQa, RQb, RQc, Qa, Qb, Qc, RQ, Q, SampleSurface_a, SampleSurface_b, SampleSurface_c, DetectorAngle
	Variable/G Detector_Off, Sample_Off, Energy_Off, E_i, E_f, dE
	String /G DataList, Flag1, Flag2
	
	SetDataFolder $DF
	DataList = WaveList ("*", ";","")
End

Function Open_Scattering_Geometry_Panel()
	
	String DF = GetDataFolder (1)
	Initial_Scattering_geometry()
	SetdataFolder root:internalUse:Scattering_Geometry
	
	Variable SC = ScreenSize(5)
	Variable SR = ScreenSize(3) * SC
	Variable ST = ScreenSize(2) * SC
	Variable Width = 510*SC		
	Variable height = 565 * SC
	Variable xOffset = 3 * SC
	Variable yOffset = 0 * SC 
	
	DoWindow/K Scattering_Geometry
	Display /W=(SR-Width-xOffset, ST+yOffset,SR-xOffset,ST+Height+yOffset) as "Scattering Geometry "
	DoWindow/C Scattering_Geometry
	//String cmd = "ControlBar 213"
	//execute cmd
	NVAR Lattice_a, Lattice_b, Lattice_c, PhotonEnergy, DetectorTheta, DetectorPhi, SampleTheta, SamplePhi, SampleAzimuth
	NVAR Ra, Rb, Rc, RQa, RQb, RQc, Qa, Qb, Qc , RQ, Q, SampleSurface_a, SampleSurface_b, SampleSurface_c, DetectorAngle
	NVAR Detector_Off, Sample_Off, Energy_Off, E_i, E_f, dE
	SVAR Flag1, Flag2
	
	Titlebox CrystalTitle, pos = {10,5}, frame = 3, size={78, 18}, title="Latice Constant", fsize = 14
	SetVariable La,  pos = {10, 30}, size={78,18}, title ="a =", limits={0,inf,0}, fsize=12, value = Lattice_a, noproc
	SetVariable Lb,  pos = {95, 30}, size={78,18}, title ="b =", limits={0,inf,0}, fsize=12, value = Lattice_b, noproc
	SetVariable Lc,  pos = {180, 30}, size={78,18}, title ="c =", limits={0,inf,0}, fsize=12, value = Lattice_c, noproc
	
	SetVariable Ra,  pos = {10, 50}, size={78,18}, title ="a* =", limits={0,inf,0}, fsize=12, value = Ra, noedit=1, noproc
	SetVariable Rb,  pos = {95, 50}, size={78,18}, title ="b* =", limits={0,inf,0}, fsize=12, value = Rb, noedit=1, noproc
	SetVariable Rc,  pos = {180, 50}, size={78,18}, title ="c* =", limits={0,inf,0}, fsize=12, value = Rc, noedit=1, noproc
	
	Titlebox OrderingVector, pos = {10,70}, frame = 3, size={78, 18}, title="Ordering Vector", fsize = 14
	
	SetVariable RQa,  pos = {10, 90}, size={90,18}, title ="RQa =", limits={0,inf,0}, fsize=12, value = RQa, noproc
	SetVariable RQb,  pos = {105, 90}, size={90,18}, title ="RQb", limits={0,inf,0}, fsize=12, value = RQb, noproc
	SetVariable RQc,  pos = {200, 90}, size={90,18}, title ="RQc=", limits={0,inf,0}, fsize=12, value = RQc, noproc
	SetVariable RQ,  pos = {295, 90}, size={90,18}, title ="RQ =", limits={0,inf,0}, fsize=12, value = RQ, noedit=1, noproc
	
	SetVariable Qa,  pos = {10, 110}, size={78,18}, title ="Qa =", limits={0,inf,0}, fsize=12, value = Qa, noedit=1, noproc
	SetVariable Qb,  pos = {95, 110}, size={78,18}, title ="Qb =", limits={0,inf,0}, fsize=12, value = Qb, noedit=1, noproc
	SetVariable Qc,  pos = {180, 110}, size={78,18}, title ="Qc =", limits={0,inf,0}, fsize=12, value = Qc, noedit=1, noproc
	SetVariable Q,  pos = {265, 110}, size={78,18}, title ="Q =", limits={0,inf,0}, fsize=12, value = Q, noedit=1, noproc
	Button QuickUpdate,pos={300,30},size={78,18},title="QuickUpdate.", proc=QuickUpdate
	
	Titlebox Scattering_Conf, pos = {10,130}, frame = 3, size={100, 18}, title="Scattering geometry", fsize = 14
	Titlebox SampleSurafce, pos = {10,150}, frame = 4, size={78, 18}, title="Sample Surface", fsize = 14
	
	SetVariable Sa,  pos = {10, 180}, size={78,18}, title ="Sa =", limits={0,inf,0}, fsize=12, value = SampleSurface_a, noproc
	SetVariable Sb,  pos = {95, 180}, size={78,18}, title ="Sb", limits={0,inf,0}, fsize=12, value = SampleSurface_b, noproc
	SetVariable Sc,  pos = {180, 180}, size={78,18}, title ="Sc=", limits={0,inf,0}, fsize=12, value = SampleSurface_c, noproc
	
	SetVariable PhtonEnergy,  pos = {10, 210}, size={150,18}, title ="PhotonEnergy (eV)=", limits={0,inf,0.}, fsize=12, value = PhotonEnergy , noproc
	SetVariable DetectorAngle, pos={180, 210}, size = {200,18}, title = "Required Detector Angle = ", limits={0,inf,0}, fsize=12, noedit=1, value = DetectorAngle, noproc
	
	Titlebox DetectorPos, pos = {10,230}, frame = 4, size={78, 18}, title="Sample Position Setup", fsize = 14
	
	SetVariable SampleTheta1,  pos = {10, 260}, size={150,18}, title ="Theta1", limits={0,inf,0.}, fsize=12, value = SampleTheta1 , noproc
	SetVariable SampleAngleFlag1, pos = {10, 280}, size={150, 18}, title ="Workable? ", fsize=12, value = Flag1, noproc
	SetVariable SampleTheta2, pos={180, 260}, size = {150,18}, title = "Theta2 ", limits={0,inf,0}, fsize=12, noedit=1, value = SampleTheta2, noproc
	SetVariable SampleAngleFlag2, pos = {180, 280}, size={150, 18}, title ="Workable? ", fsize=12, value = Flag2, noproc
	
	Titlebox CreateRP, pos = {10, 310}, size={18,18}, title="Creat file for Resonant Profile Scan", fsize = 14
	
	Setvariable DetOff, pos = {10, 340}, size={150,18}, title="Detector Offset", fsize=12, value = Detector_Off, noproc
	Setvariable SampleOff, pos = {10, 360}, size={150,18}, title="Sample Offset", fsize=12, value = Sample_Off, noproc
	Setvariable EnergyOff, pos={10, 380}, size={150,18}, title = "Enenrgy Offset", fsize=12, value = Energy_Off, noproc
	SetVariable E_i, pos={10, 400}, size = {150, 18}, title = "Start E", fsize=12, value = E_i, noproc
	SetVariable E_f, pos={10, 420}, size = {150, 18} ,title = "End E", fsize = 12, value = E_f, noproc
	SetVariable E_setp pos={10, 440}, size = {150, 18}, title = "Step E", fsize = 12, value = dE, noproc
	
	Button CreateFile,pos={300,310},size={78,18},title="Create.", proc=CreatFile
	
	SetdataFolder $DF
End

Function QuickUpdate(ctrlName)
	String ctrlName
	Variable VarNum
	String DF = GetDataFolder (1)
	SetdataFolder root:internalUse:Scattering_Geometry
	

	NVAR Lattice_a, Lattice_b, Lattice_c, PhotonEnergy, DetectorTheta, DetectorPhi, SampleTheta1, SampleTheta2
	NVAR Ra, Rb, Rc, RQa, RQb, RQc, Qa, Qb, Qc, RQ, Q, SampleSurface_a, SampleSurface_b, SampleSurface_c, DetectorAngle
	SVAR Flag1, Flag2
	
	Variable AngleToSurfaceNormal, NormS, AngleToSurface, RSa, RSb, RSc
	
	
	Ra =  2*pi/Lattice_a
	Rb =  2*pi/Lattice_b
	Rc =  2 *pi/Lattice_c
	
	RQ = sqrt(RQa^2 + RQb^2 + RQc^2)
	
	Qa= Ra * RQa
	Qb = Rb * Rqb
	Qc = Rc * RQc
	
	RSa = SampleSurface_a * Ra
	RSb = SampleSurface_b * Rb
	RSc = SampleSurface_c * Rc
	
	Q = sqrt(Qa^2 + Qb^2+Qc^2)
	
	DetectorAngle = 2 * asin(Q/(1.013 * PhotonEnergy * 0.001 ))  * 180/pi
	
	NormS = sqrt(RSa^2 + Rsb^2 + RSc^2)
	
	AngleToSurfaceNormal = (180 * acos ( (Qa *  RSa + Qb * RSb + Qc * RSc) / (Q*NormS) ) )/pi
	//AngleToSurfaceNormal = 180 * asin(Qc / Q) /pi
	print AngleToSurfaceNormal 
	//print AngleToSurfaceNormal
	//Using the convention of Yi-De's chamber. Assuming the Sample angle is only in theta direction (Top Seal)
	//SampleTheta1 = 90 + 0.5 * DetectorAngle + AngleToSurfaceNormal
	//SampleTheta2 = 90 + 0.5 * DetectorAngle - AngleToSurfaceNormal
	//The following need double checked (Yi_De convention)
//	if( (SampleTheta1 > 90) && (SampleTheta1 < (DetectorAngle + 90)))
//		Flag1 = "Yes"
//	else
//		Flag1 = "No"
//	endif
//	
//	if( (SampleTheta2 > 90) && (SampleTheta2 < (DetectorAngle + 90)))
//		Flag2 = "Yes"
//	else
//		Flag2 = "No"
//	endif
	
	//Using the regular convention 
	SampleTheta1 =  0.5 * DetectorAngle + AngleToSurfaceNormal
	SampleTheta2 =  0.5 * DetectorAngle - AngleToSurfaceNormal
	//The following need double checked
	if( (SampleTheta1 > 0) && (SampleTheta1 < (DetectorAngle )))
		Flag1 = "Yes"
	else
		Flag1 = "No"
	endif
	
	if( (SampleTheta2 > 0) && (SampleTheta2 < (DetectorAngle )))
		Flag2 = "Yes"
	else
		Flag2 = "No"
	endif
		
	SetdataFolder $DF
End

Function CreatFile(ctrlName)
	String ctrlName
	Variable VarNum
	String DF = GetDataFolder (1)
	SetdataFolder root:internalUse:Scattering_Geometry
	

	NVAR Lattice_a, Lattice_b, Lattice_c
	NVAR Ra, Rb, Rc, RQa, RQb, RQc, Qa, Qb, Qc, RQ, Q, SampleSurface_a, SampleSurface_b, SampleSurface_c
	NVAR Detector_Off, Sample_Off, Energy_Off, E_i, E_f, dE
	Variable AngleToSurfaceNormal, NormS, AngleToSurface,  RSa, RSb, RSc
	Variable Num_point, counter
	//SVAR Flag1, Flag2
	
	Ra =  2*pi/Lattice_a
	Rb =  2*pi/Lattice_b
	Rc =  2 *pi/Lattice_c
	
	RQ = sqrt(RQa^2 + RQb^2 + RQc^2)
	
	Qa= Ra * RQa
	Qb = Rb * Rqb
	Qc = Rc * RQc
	
	Q = sqrt(Qa^2 + Qb^2+Qc^2)
	
	RSa = SampleSurface_a * Ra
	RSb = SampleSurface_b * Rb
	RSc = SampleSurface_c * Rc
	
	Num_point = round((E_f - E_i)/dE) +1

	Make /O /N=(Num_point) PhotonEnergy_wave, DetectorAngle_wave, SampleTheta1_wave, SampleTheta2_wave 
	
	for(counter = 0; counter < Num_point; counter = counter + 1)
	
	PhotonEnergy_wave[counter] = E_i + counter*dE //Don't add the Energy offset yet!
	DetectorAngle_wave[counter] = 2 * asin(Q/(1.013 * PhotonEnergy_wave[counter] * 0.001 ))  * 180/pi
	
	NormS = sqrt(RSa^2 + Rsb^2 + RSc^2)
	
	AngleToSurfaceNormal = (180 * acos ( (Qa *  RSa + Qb * RSb + Qc * RSc) / (Q*NormS) ) )/pi
	
	//print AngleToSurfaceNormal 
	
	//Using the convention of Yi-De's chamber. Assuming the Sample angle is only in theta direction (Top Seal)
	//SampleTheta1_wave[counter] = 90 + 0.5 * DetectorAngle_wave[counter] + AngleToSurfaceNormal + Sample_Off
	//SampleTheta2_wave[counter] = 90 + 0.5 * DetectorAngle_wave[counter] - AngleToSurfaceNormal + Sample_Off
	
	// Using regular scattering convention
	
	SampleTheta1_wave[counter] = 0.5 * DetectorAngle_wave[counter] + AngleToSurfaceNormal + Sample_Off
	SampleTheta2_wave[counter] = 0.5 * DetectorAngle_wave[counter] - AngleToSurfaceNormal + Sample_Off
	
	DetectorAngle_wave[counter] = 2 * asin(Q/(1.013 * PhotonEnergy_wave[counter] * 0.001 ))  * 180/pi + Detector_Off
		
	PhotonEnergy_wave[counter] = E_i + counter*dE + Energy_Off //Now add the energy offset
	endfor
	
		
	SetdataFolder $DF
End

Function ScreenSize(num)
	Variable num

		String dumstr
		Variable from,to
		Variable SL,ST,SR,SB, SC
		
		dumstr	= StringByKey("SCREEN1",IgorInfo(0))
	
		from	=	strsearch(dumstr,"RECT=",0)+5	// screen-left
		to		=	strsearch(dumstr,",",from)
		SL		=	str2num(dumstr[from,to-1])	
		from	=	to+1
	
		to		=	strsearch(dumstr,",",from)		// screen-top
		ST		=	str2num(dumstr[from,to-1])	
		from	=	to+1
	
		to		=	strsearch(dumstr,",",from)		// screen-right
		SR		=	str2num(dumstr[from,to-1])
		from	=	to+1
	
		to		=	strlen(dumstr)						// screen-bottom
		SB		=	str2num(dumstr[from,to-1])
		
		SC = 72 / screenresolution 						// size correction
		
		if (num==1)
			return SL
		elseif (num==2)
			return ST
		elseif (num==3)
			return SR
		elseif (num==4)
			return SB
		elseif (num==5)
			return SC
		endif
End