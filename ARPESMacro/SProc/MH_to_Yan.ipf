#pragma rtGlobals=3		// Use modern global access method and strict wave access.



function MH_to_Yan_SW(spectrum)
	//this function transfer MH's NMat data format to Yan's format
	wave spectrum
	
	string wavenote=note(spectrum)
	string DF=getdatafolder(1)
	string waveDF=GetWavesDataFolder(spectrum,1)
	setdatafolder $waveDF
	wave/T WaveName2D
	wave Theta
	wave Phi
	wave Omega
	wave Temperature
	wave Mono
	
	variable index
	for(index=0;index<numpnts(WaveName2D);index+=1)
		if(stringmatch(nameofwave(spectrum), WaveName2D[index]))
			break
		endif
	endfor
	
	string spectrum_note=note(spectrum)
	spectrum_note=replacestringbykey("InitialThetaManipulator", spectrum_note, num2str(Theta[index]),"=","\r")
	spectrum_note=replacestringbykey("InitialPhiManipulator", spectrum_note, num2str(Phi[index]),"=","\r")
	spectrum_note=replacestringbykey("InitialAzimuthManipulator", spectrum_note, num2str(Omega[index]),"=","\r")
	spectrum_note=replacestringbykey("SampleTemperature", spectrum_note, num2str(Temperature[index]),"=","\r")
	spectrum_note=replacestringbykey("PhotonEnergy", spectrum_note, num2str(Mono[index]),"=","\r")
	setdatafolder $DF
	string spectrumname=nameofwave(spectrum)+"_Y"
	duplicate/o spectrum $spectrumname
	wave spectrum_yan=$spectrumname
	MatrixTranspose spectrum_yan
	note/K spectrum_yan, spectrum_note
	
end	


function MH_to_Yan_new(spectrum)
	//this function transfer MH's data format to Yan's format. the info are saved in wavenote instead of seperate waves.
	wave spectrum
	
	string wavenote=note(spectrum)
	string DF=getdatafolder(1)
	string waveDF=GetWavesDataFolder(spectrum,1)
	setdatafolder $waveDF
	
	
	string spectrum_note=note(spectrum)
	variable theta, phi,Temperature, Mono
	
	Mono=21
	Theta=numberbykey("T", spectrum_note, "=","\r")	
	phi=numberbykey("F", spectrum_note, "=","\r")
	temperature=numberbykey("Tflip", spectrum_note,"=","\r")
	spectrum_note+="\rInitialThetaManipulator="+num2str(theta)
	spectrum_note+="\rInitialPhiManipulator="+num2str(phi)
	spectrum_note+="\rSampleTemperature="+num2str(Temperature)
	spectrum_note+="\rPhotonEnergy="+num2str(Mono)
	
	setdatafolder $DF
	string spectrumname=nameofwave(spectrum)+"_Y"
	duplicate/o spectrum $spectrumname
	wave spectrum_yan=$spectrumname
	MatrixTranspose spectrum_yan
	note/K spectrum_yan, spectrum_note
	
end	


Function  MH_to_Yan_batch()
	variable index
	do
		wave spectrum=$(getbrowserselection(index))
		MH_to_Yan_new(spectrum)
		index+=1
	while(strlen(getbrowserselection(index))!=0)
end



Function slice_cube(cube, Efrom, Eto)
	wave cube
	variable Efrom, Eto
	
	string cubename = nameofwave(cube)
	variable kfrom = dimoffset(cube,1)
	variable kdelta = dimdelta(cube, 1)
	
	variable deflectorfrom = dimoffset(cube,2)
	variable deflectordelta = dimdelta(cube, 2)
	
	variable index
	
	string wavenote
	
	string cutname
	for(index=0;index<dimsize(cube, 2);index+=1)
		cutname = cubename+"_"+num2str(index)
		
		duplicate/o/R=(Efrom, Eto)[0,inf][index,index] cube, $cutname
		
		wave cut = $cutname
		
		
		redimension/N=(-1,-1) cut
		matrixtranspose cut
		
		wavenote = "DeflectorAngle="+num2str(deflectorfrom+deflectordelta*index)+"\r"
		note/K cut, wavenote
	endfor
end
	