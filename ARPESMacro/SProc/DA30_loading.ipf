#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function slice_3D_DA30(slice_dim,slice_index,spectra3D)
//given a 3D spectra, this function produce a 2D slice at slice_index of slice_dim
	variable slice_dim, slice_index
	wave spectra3D
	
	variable index
	variable index2
	make/o/n=2 temp_dimsize=NaN
	
	index2 = 0
	for(index=0;index<3; index+=1)
		if(index!=slice_dim)
			temp_dimsize[index2]=dimsize(spectra3D,index)
			index2+=1
		endif
	endfor
	
	make/o/n=(temp_dimsize[0],temp_dimsize[1]) slice
	
	switch(slice_dim)
		case 0:
			slice[][]=spectra3D[slice_index][p][q]
			setscale/P x,dimoffset(spectra3D,1), dimdelta(spectra3D,1), slice
			setscale/P y,dimoffset(spectra3D,2), dimdelta(spectra3D,2), slice
			break
		case 1:
			slice[][]=spectra3D[p][slice_index][q]
			setscale/P x,dimoffset(spectra3D,0), dimdelta(spectra3D,0), slice
			setscale/P y,dimoffset(spectra3D,2), dimdelta(spectra3D,2), slice
			break
		case 2:
			slice[][]=spectra3D[p][q][slice_index]
			setscale/P x,dimoffset(spectra3D,0), dimdelta(spectra3D,0), slice
			setscale/P y,dimoffset(spectra3D,1), dimdelta(spectra3D,1), slice
			break
	endswitch
	
	killwaves/Z temp_dimsize
end
	
function Convert_Yan_DA30(spectrum)
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


Function TestLoadDataset(datasetName)
	String datasetName	// Name of dataset to be loaded
	
	Variable fileID	// HDF5 file ID will be stored here

	Variable result = 0	// 0 means no error
	
	// Open the HDF5 file.
	HDF5OpenFile /P=HDF5Samples /R /Z fileID as "TOVSB1NF.h5"
	if (V_flag != 0)
		Print "HDF5OpenFile failed"
		return -1
	endif
	
	// Load the HDF5 dataset.
	HDF5LoadData /O /Z fileID, datasetName
	if (V_flag != 0)
		Print "HDF5LoadData failed"
		result = -1
	endif

	// Close the HDF5 file.
	HDF5CloseFile fileID

	return result
End