#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//The F word is fitting.
Function mfl_simu(peak_position, temperature)
	
	//0: impurity 
	//1: coupling_constant lambda =1
	//2: temperature coefficient a: a pi kb T =1
	//3: peak_height=1
	variable peak_position
	//5: constant_bkg=0
	variable temperature
	//7: cutoff_frequency=1
	make/o/n=9 simu_para={0,1,1,1,peak_position,0,temperature,1}
	make/o/n=1000 edc
	setscale/I x,-0.5,0.5,edc
	duplicate/o edc, edc_x,imse_temp, rese_temp
	edc_x=x
	
	mfl_peak(simu_para,edc,edc_x)
	
	
	string name=num2str(-peak_position*1000)+"_"+num2str(temperature)+"K"
	
	duplicate/o edc, $("edc_"+name)
	duplicate/o imse_temp, $("imse"+name)
	duplicate/o rese_temp,$("rese"+name)
end

function run_mfl_simu()
	variable temperature
	for(temperature=20;temperature<301;temperature+=40)
		mfl_simu(-0.5,temperature)
	endfor
	for(temperature=20;temperature<301;temperature+=40)
		mfl_simu(0,temperature)
	endfor
	for(temperature=20;temperature<301;temperature+=40)
		mfl_simu(-0.1,temperature)
	endfor
end




Function mfl_fd_reso(pw,yw,xw): FitFunc
	//Marginal Fermi liquid times Fermi Dirac convolve	Resolution
	//DOI: 10.1073/pnas.100118797
	Wave pw,yw,xw
	// wave parameters:

	//0: impurity 
	//1: coupling_constant lambda
	//2: temperature coefficient a: a pi kb T
	//3: peak_height
	//4: peak_position
	//5: constant_bkg
	//6: temperature
	//7: resolution
	//8: cutoff_frequency
	
	variable kb = 8.61733034e-5
	wave reso_temp
	
	
	variable gauss_sigma = 0.5*pw[7]/sqrt(2*ln(2))
	reso_temp =Gauss(x, 0, gauss_sigma)
	variable reso_temp_sum = sum(reso_temp)
	reso_temp/= reso_temp_sum
	
	wave fit_temp, imse_temp, fit_temp_x
	
	imse_temp = abs(pw[0])+abs(pw[1])*0.5*pi*sqrt((min(abs(x),abs(pw[8])))^2 + (pw[2]*pi*kb*pw[6])^2)
	
	fit_temp =(pw[5]+((pw[3]*pw[1]*imse_temp(x)/pi)/ ((x-pw[4])^2+(imse_temp(x))^2)))/(1+exp(x/(kb*pw[6])))
	//the pw[1] here is an extra just to balance the scaling.
	
	convolve/A reso_temp, fit_temp
	
	yw = interp(xw[p], fit_temp_x,fit_temp)
end

Function mfl_fd_reso_prepare(edc)
	//Prepare for fitting by creating a few relevent waves
	wave edc
	
	string edcname = nameofwave(edc)
	string fit_edcname = cropname("mflfit_"+edcname)
	string res_edcname = cropname("mflres_"+edcname)
	string para_edcname = cropname("mflpara_"+edcname)
	string err_edcname = cropname("mflerr_"+edcname)
	
	duplicate/o edc, $fit_edcname, $res_edcname
	make/o/n=9 $para_edcname, $err_edcname
	wave fit_edc = $fit_edcname
	wave res_edc = $res_edcname
	wave para_edc = $para_edcname
	fit_edc = NaN
	res_edc = NaN
	
	variable deltaE = dimdelta(edc,0)
	variable reso_numpnt = 2*floor(0.05/deltaE)+1
	variable padding_radius = floor(0.05/deltaE)*deltaE
	
	//resolution wave
	make/o/n=(reso_numpnt) reso_temp
	setscale/P x,-padding_radius, deltaE, reso_temp
	reso_temp = NaN
	
	//padding wave
	make/o/n=(reso_numpnt+numpnts(edc)) fit_temp
	setscale/P x,dimoffset(edc,0)-padding_radius,deltaE, fit_temp
	fit_temp = NaN
	
	duplicate/o fit_temp, imse_temp, fit_temp_x
	fit_temp_x = x
	wavestats/Q edc
	//Guess the parameters
	//0: impurity 
	para_edc[0]=0.1
	//1: coupling_constant lambda
	para_edc[1]=0.5
	//2: temperature coefficient a: a pi kb T
	para_edc[2]=1
	
	//4: peak_position
	para_edc[4]=0
	//5: constant_bkg
	para_edc[5]=edc(-0.8)
	//6: temperature
	para_edc[6]=get_info(edc,"SampleTemperature")
	//7: resolution
	para_edc[7]=0.010
	//3: peak_height
	para_edc[3]=V_max-para_edc[5]
	//8: peak_height
	para_edc[8]=1
	mfl_fd_reso(para_edc,fit_temp ,fit_temp_x)
end

Function mfl_peak(pw,yw,xw): FitFunc
	//Marginal Fermi liquid edc peak
	//DOI: 10.1073/pnas.100118797
	Wave pw,yw,xw
	// wave parameters:

	//0: impurity 
	//1: coupling_constant lambda
	//2: temperature coefficient a: a pi kb T
	//3: peak_height
	//4: peak_position
	//5: constant_bkg
	//6: temperature
	//7: cutoff_frequency
	
	variable kb = 8.61733034e-5
	
	wave imse_temp
	wave rese_temp
	wave edcx_temp
	
	imse_temp = abs(pw[0])+abs(pw[1])*0.5*pi*sqrt((min(abs(x),abs(pw[7])))^2 + (pw[2]*pi*kb*pw[6])^2)
	rese_temp =abs(pw[1])* x*ln(sqrt((min(abs(x),abs(pw[7])))^2 + (pw[2]*pi*kb*pw[6])^2)/pw[7])
	//kk_imag2real(imse_temp,rese_temp)
	//rese_temp*=-1
	yw =(pw[5]+((pw[3]*imse_temp(xw[p])/pi)/ ((xw[p]-pw[4]-rese_temp(xw[p]))^2+(imse_temp(xw[p]))^2)))
end

Function mfl_2peak(pw,yw,xw): FitFunc
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

Function mfl_2peak_fix(pw,yw,xw): FitFunc
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
	//9: bilayer splitting
	
	variable kb = 8.61733034e-5
	
	wave imse_temp
	wave rese_temp
	
	wave bkg_temp
	wave p1_temp
	wave p2_temp
	wave edcx_temp
	
	imse_temp =   abs(pw[0])+abs(pw[1])*0.5*pi*sqrt((min(abs(x),abs(pw[7])))^2 + (pw[2]*pi*kb*pw[6])^2)
	
	
	rese_temp =abs(pw[1])* x*ln(sqrt((min(abs(x),abs(pw[7])))^2 + (pw[2]*pi*kb*pw[6])^2)/pw[7])
	
//	p1_temp=((imse_temp(edcx_temp[p])/pi)/ ((x-pw[4]-rese_temp(edcx_temp[p]))^2+(imse_temp(edcx_temp[p]))^2))
	
//	p2_temp = ((imse_temp(edcx_temp[p])/pi)/ ((x-pw[9]-rese_temp(edcx_temp[p]))^2+(imse_temp(edcx_temp[p]))^2))
	bkg_temp=pw[5]
	
	
	
	yw =pw[5]+((pw[3]*imse_temp(xw[p])/pi)/ ((xw[p]-pw[4]-rese_temp(xw[p]))^2+(imse_temp(xw[p]))^2))
	yw +=((pw[3]*pw[8]*imse_temp(xw[p])/pi)/ ((xw[p]-pw[4]-pw[9]-rese_temp(xw[p]))^2+(imse_temp(xw[p]))^2))

end
//
//make/o/n=5000 imse_test,rese_test
//setscale/I x,-2.5,2.5, imse_test,rese_test
//imse_test = abs(pw[0])+abs(pw[1])*0.5*pi*sqrt((min(abs(x),abs(pw[7])))^2 + (pw[2]*pi*8.61733034e-5*pw[6])^2)
// kk_imag2real(root:kfEDC_node_correct:imse_test, root:kfEDC_node_correct:kk_rese_test)
//


Function mfl_imse(para,x): fitfunc
	wave para
	variable x
	
	
	//0: impurity 
	//1: coupling_constant lambda
	//2: temperature coefficient a: a pi kb T
	//3: temperature
	variable kb = 8.61733034e-5
	return para[0]+para[1]*sqrt(x^2+(para[2]*pi*kb*para[3])^2)
	
end



Function fl_imse(para,x): fitfunc
	wave para
	variable x
	
	
	//0: impurity 
	//1: coupling_constant lambda
	//2: temperature coefficient a: a pi kb T
	//3: temperature
	variable kb = 8.61733034e-5
	return para[0]+para[1]*(x^2+(para[2]*pi*kb*para[3])^2)
	
end

Function mfl_2peak_prepare(edc,pl)
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

	FuncFit/Q/H="0110011100"/NTHR=0 mfl_2peak para_edc  edc(-0.25,0.05) /D /R=res_edc//E=eps
//	Display
	//AppendToGraph edc, fit_edc
	//mfl_2peak(para_edc,fit_edc,edcx_temp)
end



Function mfl_2peak_fix_prepare(edc,pl)
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
	
	//8: intensity_ratio
	para_edc[8]=     0.829002
	//9: peak_position2
	para_edc[9]=-0.24873-para_edc[4]

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

	FuncFit/Q/H="0110011111"/NTHR=0 mfl_2peak_fix para_edc  edc(-0.25,0.05) /D /R=res_edc//E=eps
//	Display
	//AppendToGraph edc, fit_edc
	//mfl_2peak(para_edc,fit_edc,edcx_temp)
end






//mdc edge fit

	make/o/n=4 para={-0.16,3.8,0.16,0.157}


	FuncFit/Q/H="0000"/NTHR=0 lorentz_x1 para  NA_OD81_T250K_raw_m_f881_t881(-0.493,-0.1645) /D
//mdc edge fit end


Function mfl_peak_prepare(edc,pl)
	//Prepare for fitting by creating a few relevent waves
	wave edc
	string pl
	string edcname = nameofwave(edc)
	string fit_edcname = cropname("mflfit_"+edcname)
	string res_edcname = cropname("mflres_"+edcname)
	string para_edcname = cropname("mflpara_"+edcname)
	string err_edcname = cropname("mflerr_"+edcname)
	
	duplicate/o edc, $fit_edcname, $res_edcname
	make/o/n=8 $para_edcname, $err_edcname
	wave fit_edc = $fit_edcname
	wave res_edc = $res_edcname
	wave para_edc = $para_edcname
	fit_edc = NaN
	res_edc = NaN
	
	make/o/n=2000 imse_temp, edcx_temp,rese_temp, p1_temp, p2_temp, bkg_temp
	setscale/I x, -1,1, imse_temp, edcx_temp,rese_temp, p1_temp, p2_temp, bkg_temp
	
	edcx_temp = x
	
	wavestats/Q edc
	//Guess the parameters
	//0: impurity 
	para_edc[0]=0.05
	//1: coupling_constant lambda
	para_edc[1]=0.5
	//2: temperature coefficient a: a pi kb T
	para_edc[2]=1
	
	//4: peak_position
	para_edc[4]=0
	//5: constant_bkg
	para_edc[5]=0
	//6: temperature
	para_edc[6]=get_info(edc,"SampleTemperature")
	//3: peak_height
	para_edc[3]=V_max-para_edc[5]
	//8: cutoff_frequency
	para_edc[7]=0.5
	//mfl_peak(para_edc,fit_edc,edcx_temp)
	//0: impurity 
	//1: coupling_constant lambda
	//2: temperature coefficient a: a pi kb T
	//3: peak_height1
	//4: peak_position1
	//5: constant_bkg
	//6: temperature
	//7: cutoff_frequency
	//wave mflpara_OD81_kfedc
	//para_edc=mflpara_OD81_kfedc[p]
	FuncFit/Q/H="00100111"/NTHR=0 mfl_peak para_edc  edc(-0.1,0.05) /D /R=res_edc
	//Display
	//AppendToGraph edc, fit_edc
	
end










Function AN_edc_bkg_prepare(edc)
	wave edc
	//settings:
		variable poly1num = 3
		variable poly2num = 19
	//end settings

	make/o/n=(poly1num) poly1wave
	make/o/n=(poly2num) poly2wave
	make/o/n=(poly1num+poly2num+2) para
	
	para=0
	para[0]=edc(0.05)
	para[poly1num]=edc(-0.3)
	para[poly1num+poly2num] = 0
	para[poly1num+poly2num+1] = 100
end
	
	

//MFL peak/////////////////

Function pwl_lorentz_x2(pw,yw,xw): FitFunc
	Wave pw,yw,xw
	// wave parameters:

	//0: peak_width_1
	//1: peak_width_linear_1
	//2: peak_width_square_1
	//3: peak_position_1
	//4: peak_height_1
	
	//5: peak_width_2
	//6: peak_width_linear_2
	//7: peak_width_square_2
	//8: peak_position_2
	//9: peak_height_2
	
	
	//10: constant_bkg
	yw=pw[4]*(pw[0]+pw[1]*xw+pw[2]*xw^2)/ ((xw-pw[3])^2+(pw[0]+pw[1]*xw+pw[2]*xw^2)^2)
	
	yw+=pw[9]*(pw[5]+pw[6]*xw+pw[7]*xw^2)/ ((xw-pw[8])^2+(pw[5]+pw[6]*xw+pw[7]*xw^2)^2)

	yw+=pw[10]
end



Function fl_x1(pw,yw,xw): FitFunc
	Wave pw,yw,xw
	// wave parameters:

	//0: peak_width
	//1: peak_width_linear
	//2: peak_height
	//3: peak_position
	//4: constant_bkg
	//5: temperature
	
	variable kb = 8.61733034e-5
	yw=pw[2]*(abs(pw[0])+abs(pw[1])*(xw^2+(pi*kb*pw[5])^2))/((xw-pw[3])^2+(abs(pw[0])+abs(pw[1])*(xw^2+(pi*kb*pw[5])^2))^2)
	yw+=pw[4]
end

function mfl_fit(edc,pl,index)
	wave edc
	string pl
	variable index
	
	wave fitpara
	wave k0,k1,k2,k3,k4,k5,k6,k7,x_0
	FuncFit/Q/H="11000001"/NTHR=0 mfl_x2 fitpara  edc[pcsr(A),pcsr(B)] /D 
	
	string name = "para"
	variable innerindex
	  
	for(innerindex=0;innerindex<8;innerindex+=1)
		wave store = $(name+num2str(innerindex))
		store[index]=fitpara[innerindex]  	
	endfor
	wave x_0
	x_0[index]=Get_Info(edc,"Momentum")
end

function Get_fit_Info(spectrum,match_string)
	wave spectrum
	string match_string
	
	string note_string=note(spectrum)
	//print note_String
	string parawave = stringbykey(match_string,note_string,"=","\r")
	parawave =  parawave[1,strlen(parawave)-2]
	variable return_value=str2num(StringFromList(4, parawave,","))
	return return_value
End

Function phase_transition(pw,yw,xw): FitFunc
	Wave pw,yw,xw
	// wave parameters:

	//0: Tc
	//1: critical index
	//2: amplitude
	
	
	variable kb = 8.61733034e-5
	yw= pw[2]*(max(0,pw[0]-xw[p]))^pw[1]
end



Function norman_kfedc(w,delta,gamma1,gamma0)
	variable w,delta,gamma1,gamma0
	//w energy
	//delta gapsize
	//gamma1 single particle lifetime
	//gamma0 pair lifetime
	variable/C nse = cmplx(0,-gamma1)+delta^2/cmplx(w,gamma0)
	
	variable specfunc=-(imag(nse)/pi)/((w-real(nse))^2+(imag(nse))^2)
	
	return specfunc
end

Function norman_simu(delta,gamma1,gamma0,index)
	variable delta
	variable gamma1
	variable gamma0
	variable index
	string edcname = "edc_g"+num2str(round(1000*delta))+"s"+num2str(round(1000*gamma1))+"p"+num2str(round(1000*gamma0))+"i"+num2str(index)
	make/o/n=1000 $edcname
	wave edc=$edcname
	setscale/I x,-0.25,0.01,edc
	
	edc=norman_kfedc(x,delta,gamma1,gamma0)
	
	variable norm_num=area(edc,-0.25,0)
	edc/=norm_num
end


Function norman_simu_all()
	wave peakwidth
	wave gapsize
	
	variable index
	for(index=0;index<numpnts(gapsize);index+=1)
	norman_simu(abs(gapsize[index]),peakwidth[index],0.001,index)
	endfor
end


Function kondo_simu_all()
	wave singlescattering
	wave pairscattering
	wave gapsize
	
	variable index
	for(index=0;index<numpnts(gapsize);index+=1)
	norman_simu(abs(gapsize[index]),singlescattering[index],pairscattering[index],index)
	endfor
end


singlescattering=(5+temperature[p]*12/140)/1000

pairscattering=(temperature[p]>100)? 0.030: ((temperature[p]<60)? 0 : 0.03*(temperature[p]-60)/40)


Function shoulder_fit(pw,yw,xw): FitFunc
	Wave pw,yw,xw
	// wave parameters:

	//0: lorentzian position
	//1: lorentzian area
	//2: lorentizian width
	//3-5: polynomial 
	duplicate/o/R=[3,numpnts(pw)-1] pw,poly_temp
	yw=(pw[1]/pi)*(pw[2]/2)/((pw[0]-xw[p])^2+(pw[2]/2)^2)
	yw+=poly(poly_temp,xw[p])
end


Function edc_shoulder_fit(edc,disp)
	wave edc
	string disp//disp for display fitting
	variable efrom = -0.1
	variable eto =-0.01
	variable polypara = 3
	variable gapsize = -0.04
	
	variable index
	string name=nameofwave(edc)
	
	CurveFit/Q/NTHR=0 poly polypara,  edc(efrom,eto) /D 
	duplicate/o $("fit_"+name), $("polyfit_"+name)
	wave w_coef
	make/o/n=(3+polypara) $("coef_"+name)
	wave para=$("coef_"+name)
	
	para[0]=gapsize
	para[1]=0.062//used to be 5000
	para[2]=0.05
	for(index=0;index<polypara;index+=1)
		para[index+3]=w_coef[index]
	endfor
	Make/O/T/N=1 T_Constraints
	T_Constraints[0] = {"K1 > 0"}

	FuncFit/Q/NTHR=0 shoulder_fit para  edc(efrom,eto) /D/C=T_Constraints 
	wave w_sigma
	duplicate/o w_sigma, $("sigma_"+name)
	duplicate/o $("fit_"+name), $("bkg_"+name), $("shoulder_"+name)
	wave bkg=$("bkg_"+name)
	wave shoulder = $("shoulder_"+name)
	w_coef=para[p+3]
	bkg=poly(w_coef,x)
	shoulder=(para[1]/pi)*(para[2]/2)/((para[0]-x)^2+(para[2]/2)^2)
	if(stringmatch(disp,"disp"))
		Display/K=0  edc
		AppendToGraph $("fit_"+name), $("bkg_"+name), $("shoulder_"+name),$("polyfit_"+name)
		SetAxis bottom -0.12,0.01
		GP_DifferentColors()
		ModifyGraph width=72,height=144
		//ModifyGraph expand=2
	endif
end

Function get_shoulder_fit_result()
	string samples="OD92"
	string temperatures = "100;105;110;120;130;140;160;180"
	
	variable sample_index
	variable temperature_index
	string coef_name
	string sigma_name
	string sample_name
	string temperature_name
	variable temp_pnts=itemsinlist(temperatures)
	
	for(sample_index=0;sample_index<itemsinlist(samples);sample_index+=1)
		sample_name=stringfromlist(sample_index,samples)
		make/o/n=(temp_pnts) $(sample_name+"_sarea"),$(sample_name+"_sposition"),$(sample_name+"_swidth"),$(sample_name+"_sarea_r")
		make/o/n=(temp_pnts) $(sample_name+"_sarea_err"),$(sample_name+"_sposition_err"),$(sample_name+"_swidth_err"),$(sample_name+"_sarea_r_err")
		wave sarea=$(sample_name+"_sarea")
		wave sposition=$(sample_name+"_sposition")
		wave swidth=$(sample_name+"_swidth")
		wave sarea_r=$(sample_name+"_sarea_r")
		wave sarea_err=$(sample_name+"_sarea_err")
		wave sposition_err=$(sample_name+"_sposition_err")
		wave swidth_err=$(sample_name+"_swidth_err")
		wave sarea_r_err=$(sample_name+"_sarea_r_err")
		
		for(temperature_index=0;temperature_index<temp_pnts;temperature_index+=1)
			temperature_name=stringfromlist(temperature_index,temperatures)
			wave coefwave=$("coef_"+sample_name+"_T"+temperature_name+"K")
			wave errwave=$("sigma_"+sample_name+"_T"+temperature_name+"K")
			wave rawdata=$(sample_name+"_T"+temperature_name+"K")
			wave shoulderwave = $("shoulder_"+sample_name+"_T"+temperature_name+"K")
			
			if((numpnts(errwave)==6)&&(errwave[0]!=NaN))
				//0: lorentzian position
				//1: lorentzian area
				//2: lorentizian width
				//3-5: polynomial 
				sposition[temperature_index]=coefwave[0]
				sarea[temperature_index]=coefwave[1]
				swidth[temperature_index]=coefwave[2]
				sarea_r[temperature_index]=area(shoulderwave)/area(rawdata,-0.12,-0.01)
				
				sposition_err[temperature_index]=3*errwave[0]
				sarea_err[temperature_index]=3*errwave[1]
				swidth_err[temperature_index]=3*errwave[2]
				sarea_r_err[temperature_index]=sarea_err[temperature_index]*sarea_r[temperature_index]/sarea[temperature_index]
			else
				sposition[temperature_index]=nan
				sarea[temperature_index]=nan
				swidth[temperature_index]=nan
				sarea_r[temperature_index]=0
				
				sposition_err[temperature_index]=nan
				sarea_err[temperature_index]=nan
				swidth_err[temperature_index]=nan
				sarea_r_err[temperature_index]=nan
			endif
		endfor	
	endfor
	
end	

function t_star_twoline(w,x):fitfunc
	//w[0]: tstar
	//w[1]: slope
	
	wave w
	variable x
	
	return (x<w[0])?w[1]*(x-w[0]):0
end






function BCS_simple_fit(w, x):fitfunc
	wave w
	variable x
	
	variable gap = w[0]
	variable Tc = w[1]
	variable paraA = w[2]
	variable T = x
	
	if(T<Tc)
		return gap*tanh(paraA*sqrt((Tc-T)/T))
	else
		return 0
	endif
end







function mfl2D_simu(gamma0,lambda,temperature)
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


Function MFL_AN_2D(pw, yw, xw1, xw2) : FitFunc
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


Function MFL_AN_2D_reconstruct(pw, yw, xw1, xw2)
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




Function MFL_AN_2D_prepare(spec,pl)
	wave spec
	string pl
	
	make/o/n=10 para={250,0.092,0.5,-0.248,-0.0115,0.16,0.04,1.47,1.77,0.5}
	
	make/o/n=(dimsize(spec,0)) momentum
	make/o/n=(dimsize(spec,1)) energy
	
	make/o/n=2000 imse, rese
	
	setscale/P x, dimoffset(spec,0), dimdelta(spec,0), momentum
	setscale/P x, dimoffset(spec,1), dimdelta(spec,1), energy
	momentum = x
	energy = x
	
	setscale/I x,-1,1, imse, rese

	
	duplicate/o spec, spec_test, spec_fit
	MFL_AN_2D_reconstruct(para, spec_test,momentum, energy)
	
end


Function MFL_AN_EFMDC(pw, yw, xw):FitFunc
	WAVE pw, yw, xw
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
	//wave imse, rese
	
	//imse = abs( gamma0)+abs(lambda)*0.5*pi*sqrt((min(abs(x),abs(cutoff)))^2 + (pi*kb*temperature)^2)
	//rese = abs(lambda)*x*ln(sqrt((min(abs(x),abs(cutoff)))^2 + (pi*kb*temperature)^2)/cutoff)
	variable imse = abs( gamma0)+abs(lambda)*0.5*pi*sqrt((min(abs(0),abs(cutoff)))^2 + (pi*kb*temperature)^2)
	
	yw =abs(AB_weight)*((imse/pi)/ ((0-(AB_E0+(xw[p])^2/(2*AB_M0)))^2+(imse)^2))
	yw +=abs(BB_weight)*((imse/pi)/ ((0-(BB_E0+(xw[p])^2/(2*BB_M0)))^2+(imse)^2))
end

Function MDC_area_simu()
	variable gamma0 = 0.1
	variable lambda = 0.5
	variable vhs = -0.015
	variable kf = 0.06
	variable range =0.3
	
	make/o/n=6 temperature={300,250,200,170,160,150,140,100,50,10}
	make/o/n=10 para = {300,gamma0,lambda,-0.239129,vhs, 0.16,kf,0,1,0.5}
	
	string area_name = "g0"+num2str(gamma0*1000)+"vhs"+num2str(abs(vhs*1000))+"kf"+num2str(kf*100)+"kr"+num2str(range*10)
	duplicate/o temperature, $("T"+area_name),$("A"+area_name)
	wave result = $("A"+area_name)
	
	make/o/n=10000 mdc,mdc_x
	setscale/I x,-range, range,mdc,mdc_x
	mdc_x=x
	
	variable index
	for(index=0;index<numpnts(temperature);index+=1)
		duplicate/o mdc, $("MDC_T"+num2str(temperature[index]))
		wave mdc_T = $("MDC_T"+num2str(temperature[index]))
		para[0]=temperature[index]
		MFL_AN_EFMDC(para,mdc_T,mdc_x)
		result[index]=area(mdc_T)
	endfor
	
	note result, "g0+num2str(gamma0*1000)+vhs+num2str(abs(vhs*1000))+kf+num2str(kf*100)+kr+num2str(range*10)"
	
end

Function AN_2D_simu()
	variable gamma0 = 0.05
	variable lambda = 0.5
	variable vhs = -0.01
	variable kf = 0.06
	variable range =0.6
	
	make/o/n=6 temperature={300,250,200,170,150,140,100,50,10}
	make/o/n=10 para = {300,gamma0,lambda,-0.239129,vhs, 0.16,kf,0,1,0.5}
	
	string cut_name = "g0"+num2str(gamma0*1000)+"vhs"+num2str(abs(vhs*1000))+"kf"+num2str(kf*100)+"kr"+num2str(range*10)
	
	make/o/n=600 temp_E, temp_K
	
	make/o/n=2000 imse, rese

	setscale/I x,-1,1, imse, rese

	
	variable index
	for(index=0;index<numpnts(temperature);index+=1)
		make/o/n=(600,600) $("T"+num2str(temperature[index])+cut_name[0])
		wave cut= $("T"+num2str(temperature[index])+cut_name[0])
		setscale/I x, -range, range, cut
		setscale/I y, -0.4,0.2, cut
		
		setscale/I x, -range, range, temp_K
		setscale/I x, -0.4,0.2,temp_E
		
		temp_K = x
		temp_E = x
		
		para[0] = temperature[index]
		
		MFL_AN_2D_reconstruct(para, cut, temp_K, temp_E)
		
		note cut, "g0+num2str(gamma0*1000)+vhs+num2str(abs(vhs*1000))+kf+num2str(kf*100)+kr+num2str(range*10)"
	endfor
	
	
	
end




para[1] = 0.48;
FuncFit/H="1111100001"/NTHR=0 MFL_AN_EFMDC para  OD86_T250K_raw_m_f881_t881 /D /R /A=0 



FuncFit/H="1111100111"/NTHR=0 MFL_AN_EFMDC OD81_para  OD81_T250K_raw_m_f881_t881(-0.5,0) /D /R /A=0 



make/o/n=10 OD86_para={250,0.4907,0.5, -0.239129,-0.001909,0.16,0.04,4.3106,1.3011,0.5}
make/o/n=10 OD86_para={250,0.48136,0.5,   -0.323609,-0.086409,0.16,0.04,  2.53094,3.053,0.5}




FuncFit/H="1111100001"/NTHR=0 MFL_AN_EFMDC OD81_para  OD81_T250K_raw_m_f881_t881(-0.5,0) /D /R /A=0


 para={250,0.092,0.5,-0.248,-0.0115,0.16,0.04,1.47,1.77,0.5}
 

 
 function dynes_edc(gap,gamma0)
 	variable gap
 	variable gamma0
 	variable efrom = -0.3
 	variable eto = 0.3
 	
 	make/o/n=1000 edc
 	setscale/I x, efrom, eto, edc
 	
 	edc =abs(real(cmplx(x,-gamma0)/(sqrt(cmplx(x,-gamma0)^2 - gap^2))))
 end
 
 
 function dynes_gamma_dc(gap,energy)
 	variable gap
 	variable energy
 	variable gamma0
 	
 	make/o/n=500 gamma_dc
 	
 	setscale/I x,gap/1000,10*gap,gamma_dc
 	
 	gamma_dc =abs(real(cmplx(energy,-x)/(sqrt(cmplx(energy,-x)^2 - gap^2))))
 end
 
 
 Function norman_spec(w,delta,gamma1,gamma0,Ek)
	variable w,delta,gamma1,gamma0,Ek
	//w energy
	//delta gapsize
	//gamma1 single particle lifetime
	//gamma0 pair lifetime
	//E bare band energy
	variable/C nse = cmplx(0,-gamma1)+delta^2/cmplx(w+Ek,gamma0)
	
	variable specfunc=-(imag(nse)/pi)/((w-real(nse))^2+(imag(nse))^2)
	
	return specfunc
end






Function Norman_cut()
	
	//settings
	variable Gamma0=0.001//pair breaking
	variable gamma1=0.01
	variable delta=0.02
	variable E0=-0.1
	variable kf=0.2
	
	
	variable efrom = -0.1
	variable eto = 0.1
	
	variable kfrom = -0.4
	variable kto = 0
	
	variable kpnt = 500
	variable epnt = 500
	
	//end settings
	
	
	variable M0=abs( kf^2/(2*E0))
	
	make/o/n=(kpnt, epnt) norman_image
	setscale/I x, kfrom, kto,norman_image
	setscale/I y, efrom, eto, norman_image
	
	norman_image=norman_spec(y,delta,gamma1,gamma0,	E0+x^2/(2*M0))

end


function tb_sc(para,kx,ky):fitfunc
	wave para
	variable kx,ky
	
	variable a0=3.84
	
	kx*=a0/pi
	ky*=a0/pi
	
	variable t0 = para[0]//0.22
	variable t1 = para[1]//-0.0343
	variable t2 = para[2]//0.0359
	variable mu = para[3]//-0.23
	variable gap =  para[4]//0.04

	
	variable kb = 8.61733034e-5
	variable ek_nogap = -2*t0 * ( cos(pi*kx) + cos(pi*ky) ) -4* t1* ( cos(pi*kx) * cos(pi*ky) )-2*t2*(cos(2*pi*kx)+cos(2*pi*ky))-mu
	
	variable gap_k = gap*(cos(pi*kx)-cos(pi*ky))/2
	
	return -sqrt(ek_nogap^2+gap_k^2)
end



function tb_normal(para,kx,ky):fitfunc
	wave para
	variable kx,ky
	
	variable a0=3.84
	
	kx*=a0/pi
	ky*=a0/pi
	
	variable t0 = para[0]//0.22
	variable t1 = para[1]//-0.0343
	variable t2 = para[2]//0.0359
	variable mu = para[3]//-0.23

	
	variable kb = 8.61733034e-5
	variable ek_nogap = -2*t0 * ( cos(pi*kx) + cos(pi*ky) ) -4* t1* ( cos(pi*kx) * cos(pi*ky) )-2*t2*(cos(2*pi*kx)+cos(2*pi*ky))-mu
	
	
	return ek_nogap
end






make/o/n=5 para ={0.22,-0.0343,0.0359,-0.23,0.04}





function tb()
variable T0=0.22813
variable T1= -0.084
variable T2=0
variable T3=0
variable e0=-0.295

make/o/n=(200,200) tb_band
setscale/I x,-pi,pi,tb_band
setscale/I y,-pi,pi,tb_band

tb_band = -2*T0 * ( cos(x) + cos(y) ) -4* T1* ( cos(x) * cos(y) )-2*T2*(cos(2*x)+cos(2*y))-4*T3*(cos(2*x)*cos(y)+cos(x)*cos(2*y))-e0

make/o/n=200 tb_nodal
tb_nodal = tb_band[p][p]

end