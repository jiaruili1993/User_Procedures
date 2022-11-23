#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function inv_mfl_2peak(pw,yw,xw): FitFunc
	//Marginal Fermi liquid edc peak
	//DOI: 10.1073/pnas.100118797
	Wave pw,yw,xw
	// wave parameters:

	//0: impurity 
	//1: coupling_constant lambda
	//2: temperature coefficient a: a pi kb T
	//3: peak_height1
	//4: peak_position1
	//5: constant_bkg
	//6: temperature
	//7: cutoff_frequency
	//8: peak_height2
	//9: peak_position2
	
	variable kb = 8.61733034e-5
	
	wave imse_temp
	wave rese_temp
	
	wave bkg_temp
	wave p1_temp
	wave p2_temp
	
	
	imse_temp = abs(pw[0])+abs(pw[1])*0.5*pi*sqrt((min(abs(x),abs(pw[7])))^2 + (pw[2]*pi*kb*pw[6])^2)
				
	
	rese_temp =abs(pw[1])* x*ln(sqrt((min(abs(x),abs(pw[7])))^2 + (pw[2]*pi*kb*pw[6])^2)/pw[7])
				
//	p1_temp=((pw[3]*pw[1]*imse_temp(xw[p])/pi)/ ((xw[p]-pw[4]-rese_temp(xw[p]))^2+(imse_temp(xw[p]))^2))
	
	//p2_temp = ((pw[8]*pw[1]*imse_temp(xw[p])/pi)/ ((xw[p]-pw[9]-rese_temp(xw[p]))^2+(imse_temp(xw[p]))^2))
//	bkg_temp=pw[5]
	
	
	
	yw =pw[5]+((pw[3]*imse_temp(xw[p])/pi)/ ((xw[p]-pw[4]-rese_temp(xw[p]))^2+(imse_temp(xw[p]))^2))
	yw +=((pw[8]*imse_temp(xw[p])/pi)/ ((xw[p]-pw[9]-rese_temp(xw[p]))^2+(imse_temp(xw[p]))^2))
	

	
	//the pw[1] here is an extra just to balance the scaling.
end
//





Function inv_mfl_2peak_prepare(edc,pl)
	//Prepare for fitting by creating a few relevent waves
	wave edc
	string pl
	string edcname = nameofwave(edc)
	string fit_edcname = cropname("mflfit_"+edcname)
	
	string res_edcname = cropname("mflres_"+edcname)
	string para_edcname = cropname("mflpara_"+edcname)
	string err_edcname = cropname("mflerr_"+edcname)
	

	duplicate/o edc, $fit_edcname, $res_edcname
	make/o/n=10 $para_edcname, $err_edcname, eps
	wave fit_edc = $fit_edcname
	wave res_edc = $res_edcname
	wave para_edc = $para_edcname
	wave err_edc = $err_edcname
	fit_edc = NaN
	res_edc = NaN
	
	
	make/o/n=2000 imse_temp, edcx_temp,rese_temp, p1_temp, p2_temp, bkg_temp
	setscale/I x, -1,1, imse_temp, edcx_temp,rese_temp, p1_temp, p2_temp, bkg_temp
	
	edcx_temp = x
	
	wavestats/Q edc
	//Guess the parameters
	//0: impurity 
	para_edc[0]=0.1
	//1: coupling_constant lambda
	para_edc[1]=0.5
	//2: temperature coefficient a: a pi kb T
	para_edc[2]=1
	
	//4: peak_position
	para_edc[4]=-0.011528
	//5: constant_bkg
	para_edc[5]=0
	//6: temperature
	para_edc[6]=get_info(edc,"SampleTemperature")
	//3: peak_height
	para_edc[3]=V_max-para_edc[5]
	//8: cutoff_frequency
	para_edc[7]=0.5
	
	//8: peak_height2
	para_edc[8]=   para_edc[3]
	//9: peak_position2
	para_edc[9]=-0.24873

		//0: impurity 
	//1: coupling_constant lambda
	//2: temperature coefficient a: a pi kb T
	//3: peak_height1
	//4: peak_position1
	//5: constant_bkg
	//6: temperature
	//7: cutoff_frequency
	//8: peak_height2
	//9: peak_position2

	FuncFit/Q/H="0110011100"/NTHR=0 mfl_2peak para_edc  edc(-0.25,0.05) /D /F={0.950000,4,ErrorBar}/R=res_edc//E=eps
	wave W_sigma
	err_edc = W_sigma[p]
	killwaves/Z fit_edc 
	
//	Display
	//AppendToGraph edc, fit_edc
	//mfl_2peak(para_edc,fit_edc,edcx_temp)
end


make/o/n=20 momentum_ky, ab_E, ab_W, bb_E, bb_W, impurity
ub("impurity,get_value_p,0;ab_E,get_value_p,4;ab_W,get_value_p,3;bb_E,get_value_p,9;bb_W,get_value_p,8;")

ub("momentum_ky,get_info,Momentum")
Display ab_E,bb_E vs momentum_ky

Display impurity vs momentum_ky
Display ab_W, bb_W vs momentum_ky




function inv_mfl2D_simu(gamma0,lambda,temperature)
	variable gamma0//=0.09
	variable lambda//=0.5
	variable temperature //
	
	variable cutoff=0.5
	variable AB_E0=-0.011528//*5
	variable BB_E0=-0.24873//*5
	
	variable BB_kf = 0.16
	variable AB_kf  = 0.04
	
	variable AB_M0=abs( AB_kf^2/(2*AB_E0))
	variable BB_M0=abs(BB_kf^2/(2*BB_E0))
	
	variable int_ratio = 1
	
	string spectra_name="spec_G"+num2str(1000*gamma0)+"_L"+num2str(10*lambda)
	string bare_AB_name = "Bare_AB"+num2str(1000*gamma0)+"_L"+num2str(10*lambda)
	string bare_BB_name = "Bare_BB"+num2str(1000*gamma0)+"_L"+num2str(10*lambda)
	make/o/n=(400,500) $spectra_name
	wave spectra = $spectra_name
	setscale/I x,-0.4,0.4,spectra
	setscale/I y,-0.4,0.1,spectra
	
	make/o/n=500 imse,rese
	setscale/I x,-0.4,0.1,imse,rese
	
	
	make/o/n=400 $bare_AB_name, $bare_BB_name
	wave bareAB =  $bare_AB_name
	wave bareBB= $bare_BB_name
	
	setscale/I x, -0.4,0.4, bareAB, bareBB
	
	variable kb = 8.61733034e-5
	
	imse =  abs( gamma0)+abs(lambda)*0.5*pi*sqrt((min(abs(x),abs(cutoff)))^2 + (pi*kb*temperature)^2)
	rese = abs(lambda)* x*ln(sqrt((min(abs(x),abs(cutoff)))^2 + (pi*kb*temperature)^2)/cutoff)
	
	bareAB=AB_E0+x^2/(2*AB_M0)
	bareBB=BB_E0+x^2/(2*BB_M0)
	
	spectra =((imse(y)/pi)/ ((y-(AB_E0+x^2/(2*AB_M0))-rese(y))^2+(imse(y))^2))
	spectra+=  int_ratio *((imse(y)/pi)/ ((y-(BB_E0+x^2/(2*BB_M0))-rese(y))^2+(imse(y))^2))
end



//=========================================================
//All the X waves are 1D waves with the same number of points as the Y wave, yw, even if your input data
//is in the form of a matrix wave. If you use FuncFitMD to fit an N row by M column matrix, Igor unrolls the
//matrix to form a 1D Y wave containing NxM points. This is passed to your function as the Y wave parameter.
//The X wave parameters are 1D waves containing NxM points with values that repeat for each column.


Function inv_MFL_AN_2D(pw, yw, xw1, xw2) : FitFunc
	WAVE pw, yw, xw1, xw2
	variable kb = 8.61733034e-5
	
	//xw1: momentum
	//xw2: energy
	
	//pw[0] temperature
	variable temperature = pw[0]
	//pw[1] Gamma0
	variable Gamma0=pw[1]
	//pw[2] lambda
	variable lambda = pw[2]
	//pw[3] band bottom, bonding
	variable BB_E0 = pw[3]
	//pw[4] band bottom, antibonding
	variable AB_E0= pw[4]
	//pw[5] kf, bonding
	variable BB_kf = pw[5]
	//pw[6] kf, antibonding
	variable AB_kf = pw[6]
	//pw[7] intensity,bonding
	variable BB_weight = pw[7]
	//pw[8] intensity, antibonding
	variable AB_weight = pw[8]
	//pw[9] cutoff
	variable cutoff = pw[9]	
	
	
	variable AB_M0=abs( AB_kf^2/(2*AB_E0))
	variable BB_M0=abs(BB_kf^2/(2*BB_E0))
	wave imse, rese
	
	imse = abs( gamma0)+abs(lambda)*0.5*pi*sqrt((min(abs(x),abs(cutoff)))^2 + (pi*kb*temperature)^2)
	rese = abs(lambda)*x*ln(sqrt((min(abs(x),abs(cutoff)))^2 + (pi*kb*temperature)^2)/cutoff)
	
	
	yw =abs(AB_weight)*((imse(xw2[p])/pi)/ ((xw2[p]-(AB_E0+(xw1[p])^2/(2*AB_M0))-rese(xw2[p]))^2+(imse(xw2[p]))^2))
	yw +=abs(BB_weight)*((imse(xw2[p])/pi)/ ((xw2[p]-(BB_E0+xw1[p]^2/(2*BB_M0))-rese(xw2[p]))^2+(imse(xw2[p]))^2))
	
end


Function inv_MFL_AN_2D_reconstruct(pw, yw, xw1, xw2)
	WAVE pw, yw, xw1, xw2
	variable kb = 8.61733034e-5
	
	//xw1: momentum
	//xw2: energy
	
	//pw[0] temperature
	variable temperature = pw[0]
	//pw[1] Gamma0
	variable Gamma0=pw[1]
	//pw[2] lambda
	variable lambda = pw[2]
	//pw[3] band bottom, bonding
	variable BB_E0 = pw[3]
	//pw[4] band bottom, antibonding
	variable AB_E0= pw[4]
	//pw[5] kf, bonding
	variable BB_kf = pw[5]
	//pw[6] kf, antibonding
	variable AB_kf = pw[6]
	//pw[7] intensity,bonding
	variable BB_weight = pw[7]
	//pw[8] intensity, antibonding
	variable AB_weight = pw[8]
	//pw[9] cutoff
	variable cutoff = pw[9]	
	
	
	variable AB_M0=abs( AB_kf^2/(2*AB_E0))
	variable BB_M0=abs(BB_kf^2/(2*BB_E0))
	wave imse, rese
	
	imse = abs( gamma0)+abs(lambda)*0.5*pi*sqrt((min(abs(x),abs(cutoff)))^2 + (pi*kb*temperature)^2)
	rese = abs(lambda)*x*ln(sqrt((min(abs(x),abs(cutoff)))^2 + (pi*kb*temperature)^2)/cutoff)
	
	
	yw =abs(AB_weight)*((imse(xw2[q])/pi)/ ((xw2[q]-(AB_E0+(xw1[p])^2/(2*AB_M0))-rese(xw2[q]))^2+(imse(xw2[q]))^2))
	yw +=abs(BB_weight)*((imse(xw2[q])/pi)/ ((xw2[q]-(BB_E0+xw1[p]^2/(2*BB_M0))-rese(xw2[q]))^2+(imse(xw2[q]))^2))
	
end




Function inv_MFL_AN_2D_prepare(spec,pl)
	wave spec
	string pl
	
	make/o/n=10 para={250,0.092,0.5,-0.248,-0.0115,0.16,0.04,1.47,1.77,0.5}
	
	//pw[0] temperature
	para[0]=250
	//pw[1] Gamma0
	para[1]=0.092
	//pw[2] lambda
	para[2]=0.5
	//pw[3] band bottom, bonding
	para[3]=-0.248
	//pw[4] band bottom, antibonding
	para[4]=-0.0115
	//pw[5] kf, bonding
	para[5]=0.16
	//pw[6] kf, antibonding
	para[6]=0.04
	//pw[7] intensity,bonding
	para[7]=1.47
	//pw[8] intensity, antibonding
	para[8]=1.77
	//pw[9] cutoff
	para[9]=0.5
	
	
	
	
	make/o/n=(dimsize(spec,0)) momentum
	make/o/n=(dimsize(spec,1)) energy
	
	make/o/n=2000 imse, rese
	
	setscale/P x, dimoffset(spec,0), dimdelta(spec,0), momentum
	setscale/P x, dimoffset(spec,1), dimdelta(spec,1), energy
	momentum = x
	energy = x
	
	setscale/I x,-1,1, imse, rese

	
	duplicate/o spec, spec_test, spec_fit
	inv_MFL_AN_2D_reconstruct(para, spec_test,momentum, energy)
	
end


FuncFitMD/H="1010000001"/NTHR=0 inv_MFL_AN_2D para  OD81_T250K_symk /X=momentum /Y=energy /D /F={0.950000, 4}
inv_MFL_AN_2D_reconstruct(para, spec_fit,momentum, energy)
offset_plot(1, 1,20)



display
appendImage/L/B root:graphsave:Images:IMG_1:OD81_T250K_symk

//==================================================================



Function inv_MFL_AN_2D_reso_reconstruct(pw, yw, xw1, xw2) : FitFunc
	WAVE pw, yw, xw1, xw2
	variable kb = 8.61733034e-5
	variable kconvert = pi/0.818123
	//xw1: momentum
	//xw2: energy
	
	//pw[0] temperature
	variable temperature = pw[0]
	//pw[1] Gamma0
	variable Gamma0=pw[1]
	//pw[2] lambda
	variable lambda = pw[2]
	//pw[3] band bottom, bonding
	variable BB_E0 = pw[3]
	//pw[4] band bottom, antibonding
	variable AB_E0= pw[4]
	//pw[5] mass, bonding
	variable BB_M0 = pw[5]
	//pw[6] mass, antibonding
	variable AB_M0 = pw[6]
	//pw[7] intensity,bonding
	variable BB_weight = pw[7]
	//pw[8] intensity, antibonding
	variable AB_weight = pw[8]
	//pw[9] cutoff
	variable cutoff = pw[9]	
	//pw[10] k reso
	variable k_reso = pw[10]
	//pw[11] matrix element bonding  1+a*cos(k)
	variable matrix_element_BB=pw[11]
	//pw[12] matrix_element antibonding  1+a*cos(k)
	variable matrix_element_AB=pw[12]
	//pw[13] matrix element bonding 1+a*cos(2k)
	variable matrix_element_BBD=pw[13]
	//pw[14] matrix_element antibonding 1+a*cos(2k)
	variable matrix_element_ABD=pw[14]
	
	
	
	
	variable Gamma0_add=0
	
	
	wave imse, rese, momentum_L, energy_L, spec_fit_L
	
	imse = abs( gamma0)+abs(lambda)*0.5*pi*sqrt((min(abs(x),abs(cutoff)))^2 + (pi*kb*temperature)^2)
	rese = abs(lambda)*x*ln(sqrt((min(abs(x),abs(cutoff)))^2 + (pi*kb*temperature)^2)/cutoff)
	
	
	spec_fit_L =(1+matrix_element_AB*cos(kconvert*momentum_L[p])+matrix_element_ABD*cos(2*kconvert*momentum_L[p]))*abs(AB_weight)*(((imse(energy_L[q])+Gamma0_add)/pi)/ ((energy_L[q]-(AB_E0+(momentum_L[p])^2/(2*AB_M0))-rese(energy_L[q]))^2+((imse(energy_L[q])+Gamma0_add))^2))
	spec_fit_L +=(1+matrix_element_BB*cos(kconvert*momentum_L[p])+matrix_element_BBD*cos(2*kconvert*momentum_L[p]))*abs(BB_weight)*((imse(energy_L[q])/pi)/ ((energy_L[q]-(BB_E0+momentum_L[p]^2/(2*BB_M0))-rese(energy_L[q]))^2+(imse(energy_L[q]))^2))
	spec_fit_L *=1/(1+exp(energy_L[q]/(kb*temperature)))
	
	//duplicate/o xw1 fit_xw1
	//duplicate/o xw2 fit_xw2
	wave mdc_temp
	wave edc_temp
	wave resolution_wave //resolution wave for convolution.
	wave fd_reso
	
	variable index
	for(index=0;index<dimsize(spec_fit_L,0);index+=1)
		edc_temp = spec_fit_L[index][p]
		convolve/A resolution_wave, edc_temp
		spec_fit_L[index][]=edc_temp[q]
		//get edc and convolve, continue here.
	endfor
	
		
	wave k_resolution_wave
	
	
	k_resolution_wave = Gauss(x, 0, k_reso/(2*(sqrt(2*ln(2)))))
	
	variable normvalue = sum(k_resolution_wave)
	k_resolution_wave/=normvalue
	
	for(index=0;index<dimsize(spec_fit_L,1);index+=1)
		mdc_temp = spec_fit_L[p][index]
		convolve/A k_resolution_wave, mdc_temp
		spec_fit_L[][index]=mdc_temp[p]
		//get edc and convolve, continue here.
	endfor
	
	
	
	yw=interp2D(spec_fit_L,xw1[p],xw2[q])/fd_reso(xw2[q])
end


Function inv_MFL_AN_2D_reso(pw, yw, xw1, xw2) : FitFunc
	WAVE pw, yw, xw1, xw2
	variable kb = 8.61733034e-5
	variable kconvert = pi/0.818123
	//xw1: momentum
	//xw2: energy
	
	//pw[0] temperature
	variable temperature = pw[0]
	//pw[1] Gamma0
	variable Gamma0=pw[1]
	//pw[2] lambda
	variable lambda = pw[2]
	//pw[3] band bottom, bonding
	variable BB_E0 = pw[3]
	//pw[4] band bottom, antibonding
	variable AB_E0= pw[4]
	//pw[5] mass, bonding
	variable BB_M0 = pw[5]
	//pw[6] mass, antibonding
	variable AB_M0 = pw[6]
	//pw[7] intensity,bonding
	variable BB_weight = pw[7]
	//pw[8] intensity, antibonding
	variable AB_weight = pw[8]
	//pw[9] cutoff
	variable cutoff = pw[9]	
	//pw[10] k_resolution
	variable k_reso = pw[10]
	//pw[11] matrix element bonding 1+a*cos(k)
	variable matrix_element_BB=pw[11]
	//pw[12] matrix_element antibonding 1+a*cos(k)
	variable matrix_element_AB=pw[12]
	//pw[13] matrix element bonding 1+a*cos(2k)
	variable matrix_element_BBD=pw[13]
	//pw[14] matrix_element antibonding 1+a*cos(2k)
	variable matrix_element_ABD=pw[14]
	
	
	variable Gamma0_add=0
	
	
	wave imse, rese, momentum_L, energy_L, spec_fit_L
	
	imse = abs( gamma0)+abs(lambda)*0.5*pi*sqrt((min(abs(x),abs(cutoff)))^2 + (pi*kb*temperature)^2)
	rese = abs(lambda)*x*ln(sqrt((min(abs(x),abs(cutoff)))^2 + (pi*kb*temperature)^2)/cutoff)
	
	
	spec_fit_L =(1+matrix_element_AB*cos(kconvert*momentum_L[p])+matrix_element_ABD*cos(2*kconvert*momentum_L[p]))*abs(AB_weight)*(((imse(energy_L[q])+Gamma0_add)/pi)/ ((energy_L[q]-(AB_E0+(momentum_L[p])^2/(2*AB_M0))-rese(energy_L[q]))^2+((imse(energy_L[q])+Gamma0_add))^2))
	spec_fit_L +=(1+matrix_element_BB*cos(kconvert*momentum_L[p])+matrix_element_BBD*cos(2*kconvert*momentum_L[p]))*abs(BB_weight)*((imse(energy_L[q])/pi)/ ((energy_L[q]-(BB_E0+momentum_L[p]^2/(2*BB_M0))-rese(energy_L[q]))^2+(imse(energy_L[q]))^2))
	spec_fit_L *=1/(1+exp(energy_L[q]/(kb*temperature)))
	
	//duplicate/o xw1 fit_xw1
	//duplicate/o xw2 fit_xw2
	
	wave mdc_temp
	wave edc_temp
	wave resolution_wave //resolution wave for convolution.
	wave fd_reso
	
	variable index
	for(index=0;index<dimsize(spec_fit_L,0);index+=1)
		edc_temp = spec_fit_L[index][p]
		convolve/A resolution_wave, edc_temp
		spec_fit_L[index][]=edc_temp[q]
		//get edc and convolve, continue here.
	endfor
	
	wave k_resolution_wave
	
	
	k_resolution_wave = Gauss(x, 0, k_reso/(2*(sqrt(2*ln(2)))))
	
	variable normvalue = sum(k_resolution_wave)
	k_resolution_wave/=normvalue
	
	for(index=0;index<dimsize(spec_fit_L,1);index+=1)
		mdc_temp = spec_fit_L[p][index]
		convolve/A k_resolution_wave, mdc_temp
		spec_fit_L[][index]=mdc_temp[p]
		//get edc and convolve, continue here.
	endfor
	
	
	
	yw=interp2D(spec_fit_L,xw1[p],xw2[p])/fd_reso(xw2[p])
end







Function inv_MFL_AN_2D_reso_prepare(spec,pl)
	wave spec
	string pl
	
	
	
	//settings
	variable momentum_padding = 0.1
	variable energy_padding = 0.1
	variable resolution = 0.01 //resolution is 10 meV
	//end settings
	
	make/o/n=15 para
	
	//pw[0] temperature
	para[0]=250
	//pw[1] Gamma0
	para[1]=0.0954667
	//pw[2] lambda
	para[2]=0.5
	//pw[3] band bottom, bonding
	para[3]=-0.2546
	//pw[4] band bottom, antibonding
	para[4]=-0.0166541
	//pw[5] mass, bonding
	para[5]=0.08
	//pw[6] mass, antibonding
	para[6]=0.08
	//pw[7] intensity,bonding
	para[7]=1.47
	//pw[8] intensity, antibonding
	para[8]=1.77
	//pw[9] cutoff
	para[9]=0.5
	//pw[10] momentum resolution
	para[10]=0.005//correspond to 0.13 degree resolution at 21 eV
	//pw[11] matrix element bonding  1+a*cos(k)
	para[11]=0
	//pw[12] matrix_element antibonding  1+a*cos(k)
	para[12]=0
	//pw[13] matrix element bonding 1+a*cos(2k)
	para[13]=0
	//pw[14] matrix_element antibonding 1+a*cos(2k)
	para[14]=0
	
	make/o/n=(dimsize(spec,0)) momentum
	make/o/n=(dimsize(spec,1)) energy
	
	make/o/n=2000 imse, rese
	
	setscale/P x, dimoffset(spec,0), dimdelta(spec,0), momentum
	setscale/P x, dimoffset(spec,1), dimdelta(spec,1), energy
	momentum = x
	energy = x
	
	setscale/I x,-1,1, imse, rese

	
	duplicate/o spec, spec_test, spec_fit
	
	variable momentum_L_from = dimoffset(spec,0)-momentum_padding
	variable momentum_L_to = dim_to(spec,0)+momentum_padding
	variable energy_L_from = dimoffset(spec, 1)- energy_padding
	variable energy_L_to = dim_to(spec, 1)+ energy_padding
	
	variable momentum_L_pnts=round(abs(momentum_L_to - momentum_L_from) /dimdelta(spec, 0))
	variable energy_L_pnts=round(abs(energy_L_to - energy_L_from) /dimdelta(spec, 1))
	
	make/o/n=(momentum_L_pnts, energy_L_pnts) spec_fit_L
	make/o/n=(momentum_L_pnts) momentum_L, mdc_temp
	make/o/n=(energy_L_pnts) energy_L, edc_temp, fd_reso
	
	setscale/I x, momentum_L_from, momentum_L_to, spec_fit_L,momentum_L
	setscale/I y, energy_L_from, energy_L_to, spec_fit_L
	
	setscale/I x, momentum_L_from, momentum_L_to, momentum_L, mdc_temp
	setscale/I x, energy_L_from, energy_L_to, energy_L,edc_temp, fd_reso

	momentum_L = x
	energy_L = x
	
	variable deltaE = dimdelta(energy_L, 0)
	
	variable resolution_wave_half_size = round(3*resolution/deltaE)
	make/o/n=(2* resolution_wave_half_size +1) resolution_wave
	setscale/P x, -resolution_wave_half_size*deltaE, deltaE, resolution_wave
	
	resolution_wave = Gauss(x, 0, resolution/(2*(sqrt(2*ln(2)))))
	
	variable normvalue = sum(resolution_wave)
	
	resolution_wave/= normvalue
	
	fd_reso=fd(x,para[0])
	duplicate/o fd_reso, fd_original
	convolve/A resolution_wave, fd_reso
	
	variable deltaK = dimdelta(momentum_L,0)
	variable k_resolution_wave_half_size = round(momentum_padding/deltaK)
	make/o/n=(2*k_resolution_wave_half_size+1) k_resolution_wave
	setscale/P x, -k_resolution_wave_half_size*deltaK, deltaK, k_resolution_wave
	
	
	
	
	
	
	 inv_MFL_AN_2D_reso_reconstruct(para, spec_test,momentum, energy)
	 //inv_MFL_AN_2D_reso_reconstruct(para, spec_fit_L,momentum_L, energy_L)
end

	
	//pw[0] temperature
	//para[0]=250
	//pw[1] Gamma0
	//para[1]=0.092
	//pw[2] lambda
	//para[2]=0.5
	//pw[3] band bottom, bonding
	//para[3]=-0.248
	//pw[4] band bottom, antibonding
	//para[4]=-0.012
	//pw[5] mass, bonding
	//para[5]=0.08
	//pw[6] mass, antibonding
	//para[6]=0.08
	//pw[7] intensity,bonding
	//para[7]=1.47
	//pw[8] intensity, antibonding
	//para[8]=1.77
	//pw[9] cutoff
	//para[9]=0.5
	//pw[10] momentum resolution
	//para[10]=0.005//correspond to 0.13 degree resolution at 21 eV
	//pw[11] matrix element BB 1+a*cos(k)
	//para[11]=1
	//pw[12] matrix element AB in 1+a*cos(k)
	//para[12]=1
	//pw[13] matrix element bonding 1+a*cos(2k)
	//pw[13]=0
	//pw[14] matrix_element antibonding 1+a*cos(2k)
	//pw[14]=0
	
	
 inv_MFL_AN_2D_reso_prepare(OD81_T250K_symk,"pl")
FuncFitMD/H="100111111111111"/NTHR=0 inv_MFL_AN_2D_reso para  OD81_T250K_symk /X=momentum /Y=energy /D /F={0.950000, 4}
			  //012345678901234
			  //100111100110000



Function reproduce()
	wave para
	wave spec_fit
	wave momentum
	wave energy
	wave OD70_T250K_symk
	wave spec_fit
	inv_MFL_AN_2D_reso_reconstruct(para, spec_fit,momentum, energy)
 	
 	duplicate/O momentum matrix_element_BB, matrix_element_AB, bare_AB, bare_BB
 	matrix_element_BB = (1+para[11]*cos(x*pi/0.818123)+para[13]*cos(2*x*pi/0.818123))*para[7]
 	matrix_element_AB = (1+para[12]*cos(x*pi/0.818123)+para[14]*cos(2*x*pi/0.818123))*para[8]
 	
 	Bare_BB =para[3]+x^2/(2*para[5])
 	Bare_AB =para[4]+x^2/(2*para[6])
 	
 	duplicate/O spec_fit, spec_fit_res
 	spec_fit_res= OD70_T250K_symk-spec_fit
 	
	display
	appendImage/L/B  OD70_T250K_symk
	ModifyGraph width=72,height=72
	ModifyImage OD70_T250K_symk ctab= {-7.5,7.5,RedWhiteBlue,0}
//
	display
	appendImage/L/B  spec_fit
	ModifyGraph width=72,height=72
	ModifyImage spec_fit ctab= {-7.5,7.5,RedWhiteBlue,0}

	display
	appendImage/L/B spec_fit_res
	ModifyGraph width=72,height=72
	ModifyImage spec_fit_res ctab= {-7.5,7.5,RedWhiteBlue,0}
 end


 

 
ub("naw,symk_image_sdc,pl")






function ME_test()
	variable BZedge = 0.818123
	variable kconvert = pi/0.818123
	make/o/n=1000 ME
	setscale/I x, -pi, pi, ME
	ME = 2 - cos(x)
end