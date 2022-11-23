#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//select all the nlc waves in data browser. Then excute NLImage().



function stack_spectrum(matchstring)
//this function stacks all the selected spectrum, along the layer axis.
//in the meantime, produce a wave as the layer-axis coordinate
	string matchstring //use "BeamCurrent"
	variable index
	variable rows, columns, layers
	make/o/n=200 layer_coordinates=NaN
	
	index=0
	do
		wave target=$(getbrowserselection(index))
		layer_coordinates[index] = get_info(target, matchstring)
		index+=1
	while(strlen(getbrowserselection(index))!=0)
	deletepoints index, inf, layer_coordinates
	
	rows= dimsize(target,0)
	columns = dimsize(target,1)
	layers = dimsize(layer_coordinates, 0)
	
	make/o/n=(rows, columns, layers) stack_spectra
	index =0
	
	setscale/P x, dimoffset(target,0), dimdelta(target,0),stack_spectra
	setscale/P y, dimoffset(target,1), dimdelta(target,1),stack_spectra
	
	do
		wave target =$(getbrowserselection(index))
		stack_spectra[][][index]=target[p][q]
		index+=1
	while(strlen(getbrowserselection(index))!=0)
end

function slice_3D(slice_dim,slice_index,spectra3D)
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
	
	
function NLImage()
//run in debug mode first to check fitting result
//then run for all
//results saved in I_channel_I0
	string mode = "normal"
	stack_spectrum("BeamCurrent")
	wave stack_spectra
	wave layer_coordinates
	make/o/n=(dimsize(stack_spectra,0),1000) I_channel_I0
	setscale/I y, 0,wavemax(layer_coordinates),I_channel_I0
	make/o/n=(dimsize(stack_spectra,0),6) para_saver
	make/o/n=6 para
	make/o/n=5 polycoef
	make/o/n=1000 Intensity_I0
	setscale/I x, 0,wavemax(layer_coordinates),Intensity_I0
	
	variable channel_index=0
	
	for(channel_index=0; channel_index<dimsize(stack_spectra,0);channel_index+=1)
		if(stringmatch(mode, "debug"))
			if(channel_index!=441)
				continue
			endif
		endif
			
		slice_3D(0,channel_index,stack_spectra)
		wave slice // a wave, x dimension energy, y dimension beamcurrent
		setscale/P x, 0,1,slice
		para={0,0,1,0,0,0}
		duplicate/o slice, slice_fit, slice_res
		
		FuncFitMD/Q/NTHR=0 NLC_fit2D para  slice /Y=layer_coordinates /D=slice_fit /R=slice_res

//		wave W_sigma
//		duplicate/o W_sigma, w_sigma_relative
//		w_sigma_relative[] = abs(w_sigma[p])/abs(para[p])
//		if(wavemax(w_sigma_relative)>0.15)
//			print "error in channel"+num2str(channel_index)
//		endif
//		
		
		polycoef = para[p+1]
		polycoef[0] =0
		Intensity_I0[] = poly(polycoef,x)
		I_channel_I0[channel_index][] = poly(polycoef,y)
		para_saver[channel_index][]=para[q]
		
		if(mod(channel_index,100)==0)
			print channel_index
		endif
	endfor
	
	duplicate/o I_channel_I0, I_channel_I0_relaxed
	
	make/o/n=(dimsize(stack_spectra,0)) para_1D_saver, error_v_channel
	para_1D_saver[]=para_saver[p][0]
	variable para0 = mean(para_1D_saver,200,700)
	para_1D_saver[]=para_saver[p][1]
	variable para1 = mean(para_1D_saver,200,700)
	
	variable fit_variance, wavemean
	
	for(channel_index=0; channel_index<dimsize(stack_spectra,0);channel_index+=1)
		if(stringmatch(mode, "debug"))
			return 0
		endif
			
		slice_3D(0,channel_index,stack_spectra)
		wave slice // a wave, x dimension energy, y dimension beamcurrent
		setscale/P x, 0,1,slice
		para={para0,para1,1,0,0,0}
		duplicate/o slice, slice_fit, slice_res
		
		FuncFitMD/H="110000"/Q/NTHR=0 NLC_fit2D para  slice /Y=layer_coordinates /D=slice_fit /R=slice_res
		imagestats/Q slice_res
		error_v_channel[channel_index]=V_rms
//		
//		wave W_sigma
//		duplicate/o W_sigma, w_sigma_relative
//		w_sigma_relative[] = abs(w_sigma[p])/abs(para[p])
//		if(wavemax(w_sigma_relative)>0.15)
//			print "error in channel"+num2str(channel_index)
//		endif
//		

		
		
		
		
		polycoef = para[p+1]
		polycoef[0] =0
		Intensity_I0[] = poly(polycoef,x)
		I_channel_I0[channel_index][] = poly(polycoef,y)
		para_saver[channel_index][]=para[q]
		
		if(mod(channel_index,100)==0)
			print channel_index
		endif
	endfor
	
end


function NLC_fit2D(pw, yw, xw1, xw2) : FitFunc
	wave pw, yw, xw1, xw2
	//pw[0,1]: a in 1+a0*E+a1*E^2: shape of EDC
	//pw[2,3,4,5]: 1*x + b*x^2 + c*x^3 + d*x^4
	
	//xw1 is energy, xw2 is beamcurrent
	wave polycoef
	polycoef[]=pw[p+1]
	polycoef[0]=0
	
	yw = poly(polycoef,(1+pw[0]*xw1[p]+pw[1]*xw1[p]^2)*xw2[p])
end

function NLC(target,I_channel_I0_str)
	wave target
	string I_channel_I0_str
	wave I_channel_I0 = $I_channel_I0_str
	variable start_channel= get_info(target,"CCDFirstYChannel")
	
	make/o/n=(dimsize(I_channel_I0,1)) temp_intensity, temp_beamcurrent
	setscale/P x, dimoffset(I_channel_I0,1), dimdelta(I_channel_I0,1), temp_intensity, temp_beamcurrent
	temp_beamcurrent = x
	
	duplicate/o target, $(nameofwave(target)+"_NLC")
	wave nlc_target = $(nameofwave(target)+"_NLC")
	nlc_target = NaN
	variable index
	for(index=0;index<dimsize(target,0);index+=1)
		temp_intensity[] = I_channel_I0[index+start_channel-1][p]
		nlc_target[index][] = interp(target[index][q], temp_intensity, temp_beamcurrent)
	endfor
end

//ub("NAW,NLC,root:I_channel_I0")
j