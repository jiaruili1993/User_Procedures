#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//this file contains functions that are often used in ARPES data analysis.
//=============index===========


function ubi(batch_operation_list)
//batch_operation_list:
//result_wave_1,function1,para1,para2,para3,para4;NaW,function2,para1,para2,para3;...
//effect: result_wave_1[index]=function1(target_indexed,"para1,para2,para3,para4")
//			function2(target_indexed,"para1,par2,para3")
//			...
//placeholder indicating no result_saving_wave must be NaW
	string batch_operation_list
	
	variable index=0
	variable list_index
	string batch_operation_list_line, result_saving_wave_name, function_name, para_list
	do
		wave target=$(getbrowserselection(index))
		for(list_index=0;list_index<ItemsInList(batch_operation_list, ";");list_index+=1)
			batch_operation_list_line=StringFromList(list_index,batch_operation_list,";")
			result_saving_wave_name=StringFromList(0,batch_operation_list_line,",")
			function_name=StringFromList(1,batch_operation_list_line,",")
			para_list=removelistitem(0,removelistitem(0,batch_operation_list_line,","),",")
			if(stringmatch(result_saving_wave_name,"NaW"))
				FuncRef funcref_error_message_wi f=$function_name
				f(target,para_list,index)
			else
				wave result_saving_Wave=$result_saving_wave_name
				FuncRef funcref_error_message_wi f=$function_name
				result_saving_wave[index]=f(target,para_list,index)
			endif
		endfor
		index+=1
	while(strlen(getbrowserselection(index))!=0)
end

function funcref_error_message_wi(target,para_list,index)
	wave target
	string para_list
	variable index
	print "function reference not defined.\r"
end

function find_kf(spectrum,kfromkto)
//universial_batch("OD90_kf_L,find_kf,-8,-4")
	wave spectrum
	string kfromkto

	//settings
	variable smoothpoints = 2
	variable max_positions_smoothpoints = 10
	variable edcbin = 10
	string edc = "edc"
	string method = "maxintensity" //maxintensity, leadingedge
	//leadingedge method tends to overestimate kf
	//maxintensity seems to work well for symmetrized spectra with a gap (either PG or SC gap), but overestimates kf when there is no gap for electon bands
	string mode = "debug" //debug, normal 
	//end settings
	
	variable kfrom = str2num(stringfromlist(0,kfromkto,","))
	variable kto = str2num(stringfromlist(1,kfromkto,","))
	
	variable kfrom_pnt = round((kfrom-dimoffset(spectrum,0))/dimdelta(spectrum,0))
	variable kto_pnt = round((kto-dimoffset(spectrum,0))/dimdelta(spectrum,0))
	
	variable k_index = 0
	make/o/n=(dimsize(spectrum, 0)) edc_max_positions
	setscale/P x, dimoffset(spectrum,0),dimdelta(spectrum,0),edc_max_positions
	make/o/n=(dimsize(spectrum,1)) temp_edc
	setscale/P x, dimoffset(spectrum,1),dimdelta(spectrum,1),temp_edc
	edc_max_positions = NaN
	
	if(stringmatch(method, "maxintensity"))
		for(k_index=0; k_index<numpnts(edc_max_positions); k_index+=1)
			temp_edc = spectrum[k_index][p]
			smooth/E=3 smoothpoints,temp_edc
			WaveStats/Q/R=(-0.5,0.001) temp_edc
			edc_max_positions[k_index] = pnt2x(temp_Edc, V_maxRowLoc)
		endfor
	endif

	
	if(stringmatch(method, "leadingedge"))
		for(k_index=0; k_index<numpnts(edc_max_positions); k_index+=1)
			temp_edc = spectrum[k_index][p]
			smooth/E=3 smoothpoints,temp_edc
			WaveStats/Q/R=(-0.5,0.1) temp_edc
			variable ldedge_midpoint_intensity = V_max/2
			duplicate/o/R=(V_maxloc,0.1) temp_edc,temp_edc_y, temp_edc_x
			temp_edc_x = x
			variable ldedge_midpoint = interp(ldedge_midpoint_intensity, temp_edc_y, temp_edc_x)
			edc_max_positions[k_index] = ldedge_midpoint
		endfor
	endif
	
	duplicate/O edc_max_positions edc_max_positions_raw
	smooth/E=3 max_positions_smoothpoints, edc_max_positions
	smooth/E=3 max_positions_smoothpoints, edc_max_positions
	smooth/E=3 max_positions_smoothpoints, edc_max_positions

	WaveStats/Q/R=(kfrom,kto) edc_max_positions
	variable kf = V_maxRowLoc
	
	if(stringmatch(edc,"edc"))
		temp_edc = 0
		kfrom_pnt = kf-round((edcbin-1)/2)
		kto_pnt = kf+round((edcbin-1)/2)
		for(k_index=kfrom_pnt; k_index<(kto_pnt+1); k_index+=1)
			temp_edc +=  spectrum[k_index][p]
		endfor
		temp_edc /= (kto_pnt + 1 - kfrom_pnt)
		string edcname = nameofwave(spectrum)+"_edc_f"+num2str(kfrom_pnt)+"_t"+num2str(kto_pnt)
		variable edck = pnt2x(edc_max_positions, kf)
		string edcnote = "edck="+num2str(edck)+"\r"+note(spectrum)
		duplicate/O temp_edc, $edcname
		note/K $edcname, edcnote
	endif
	
	if(stringmatch(mode, "normal"))
		killwaves/Z edc_max_positions, edc_max_positions_raw, temp_edc,temp_edc_y, temp_edc_x
	endif
	return edck
	
end

function plot_selection()
	variable index=0
	do
		wave target=$(getbrowserselection(index))
		if(index==0)
			display target
		else
			appendtograph target
		endif
		index+=1
	while(strlen(getbrowserselection(index))!=0)
	geo()
end


function dplot_selection(foldername)
	string foldername
	variable index=0
	string newwave 
	do
		wave target=$(getbrowserselection(index))
		newwave= nameofwave(target)
		if(index==0)
			newdatafolder/o/s	$foldername
			duplicate/o target, $newwave
			display $newwave
		else
			duplicate/o target, $newwave
			appendtograph $newwave
		endif
		index+=1
	while(strlen(getbrowserselection(index))!=0)
	geo()
end


function append_selection()
	variable index=0
	do
		wave target=$(getbrowserselection(index))
		appendtograph target
		index+=1
	while(strlen(getbrowserselection(index))!=0)
	geo()
end




function align_selection()
	
	//settings:
	variable mdc_smooth_pnt = 30
	variable mdc_smooth_time =10
	variable mdc_efrom = -0.2
	variable mdc_eto = -0.1
	string crop = "crop"//crop, nocrop
	string method = "dk"//max, dk
	//max uses max intensity
	//dk uses peak/valley positions from mdc derivative
	//setting end
	
	string basewavename
	variable crop_kfrom
	variable crop_kto
	variable mdc_efrom_pnt
	variable mdc_eto_pnt
	
	variable basecenter
	variable currentcenter
	variable newdimoffset
	
	string notestr
	variable index=0
	variable i
	do
		wave spectrum=$(getbrowserselection(index))
		if(index==0)
			basewavename = nameofwave(spectrum)
			make/o/n=(dimsize(spectrum, 0)) temp_mdc
			setscale/P x, dimoffset(spectrum,0),dimdelta(spectrum,0),temp_mdc
			crop_kfrom = dimoffset(spectrum,0)
			crop_kto = dimoffset(spectrum,0) + dimdelta(spectrum,0)*(dimsize(spectrum,0)-1)
		endif
		
		wave temp_mdc = get_mdc(spectrum, num2str(mdc_efrom)+","+num2str(mdc_eto))

//		
//		make/o/n=(dimsize(spectrum, 0)) temp_mdc=0
//		setscale/P x, dimoffset(spectrum,0),dimdelta(spectrum,0),temp_mdc
//		mdc_efrom_pnt = round((mdc_efrom-dimoffset(spectrum,1))/dimdelta(spectrum,1))
//		mdc_eto_pnt = round((mdc_eto-dimoffset(spectrum,1))/dimdelta(spectrum,1))
//		
//		for(i=mdc_efrom_pnt;i<mdc_eto_pnt;i+=1)
//			temp_mdc += spectrum[p][i]
//		endfor
		
		//duplicate/o temp_mdc, $(nameofwave(spectrum)+"_beforesmooth")
		for(i=0;i<mdc_smooth_time;i+=1)
			smooth/E=3 mdc_smooth_pnt, temp_mdc
		endfor
		
		if(stringmatch(method, "max"))
			wavestats/Q temp_mdc
			currentcenter = V_maxloc
		else
			duplicate/o temp_mdc, temp_mdc_diff//,$(nameofwave(spectrum)+"_beforediff")
			
			Differentiate temp_mdc/D=temp_mdc_diff
			//duplicate temp_mdc_diff, $(nameofwave(spectrum)+"_diff")
			wavestats/Q temp_mdc_diff
			currentcenter=(V_maxloc+V_minloc)/2
		endif
			
		if(index==0)
			basecenter = currentcenter
		endif
		
		print nameofwave(spectrum)+":"+num2str(basecenter-currentcenter)
		newdimoffset = dimoffset(spectrum,0) + basecenter - currentcenter
		setscale/P x, newdimoffset,dimdelta(spectrum,0),spectrum
		notestr = note(spectrum)
		note/K spectrum, "Alignedwith="+basewavename+"\r"+notestr
		crop_kfrom = max(dimoffset(spectrum,0), crop_kfrom)
		crop_kto = min(dimoffset(spectrum,0) + dimdelta(spectrum,0)*(dimsize(spectrum,0)-1), crop_kto)
		index+=1
	while(strlen(getbrowserselection(index))!=0)
	
	//crop_kfrom +=dimsize(spectrum,0)
	//crop_kto -=dimsize(spectrum,0)
	
	if(stringmatch(crop,"crop"))
		index=0
		string newname
		string oldname
		do
			wave spectrum=$(getbrowserselection(index))
			oldname = nameofwave(spectrum)
			newname = oldname + "_C"
			duplicate/O/R=(crop_kfrom,crop_kto) spectrum, $newname
			index+=1
		while(strlen(getbrowserselection(index))!=0)
	endif
	killwaves/Z temp_mdc, temp_mdc_diff
end

function bkg_by_min(spectrum,pl)
	wave spectrum
	string pl
	
	//settings:
	variable min_pnts = 10
	//settings end
	variable bkg
	variable yindex = 0
	for(yindex=0; yindex<dimsize(spectrum,1);yindex+=1)
		make/o/n=(dimsize(spectrum,0)) tempmdc
		 tempmdc = spectrum[p][yindex]
		 duplicate/o tempmdc tempmdc_2
		 sort tempmdc, tempmdc_2
		 bkg = mean(tempmdc_2,0,10)
		 tempmdc -=bkg
		 spectrum[][yindex]=tempmdc[p]
	endfor
end




function lorentz_fit_process(name)
	string name
	wave intensity = $(name+"_Peak_intensity")
	wave bkg = $(name+"_Bkg_constant")
	wave FWHM = $(name+"_Peak_FWHM")
	wave tem = $(name+"_xtem")
	
	duplicate/o intensity  $(name+"_weight")
	wave weight = $(name+"_weight")
	weight = FWHM[p]*intensity[p]/bkg[p]
end

//universial_batch("NAW,rename_wave,OD81_")

function find_width(edc, ratio_string)
//universial_batch("width_050,find_width,0.5")
	wave edc
	string ratio_string
	//settings
	variable smooth_time = 30
	variable smooth_pnts = 20
	variable fit_time = 5
	variable fit_range = 0.05
	//settings end
	variable ratio = str2num(ratio_string)
	wavestats/Q/R=(-0.8,0) edc
	variable edcmax = V_max
	variable edcmax_loc = V_maxloc
	
	
	wavestats/Q/R=(-0.8,-0.01) edc
	variable edcmax_2 = V_max
	variable edcmax_loc_2 = V_maxloc
	
	if(abs(edcmax_loc_2-edcmax_loc)>0.02)
		edcmax_loc = edcmax_loc_2
		edcmax = edcmax_2
		print nameofwave(edc) + " peak at "+num2str(edcmax_loc)+"\r"
	endif
	
	
	
	
	wavestats/Q/R=(-0.6,-0.1) edc
	variable edcmin = 0
	variable edcmin_loc = V_minloc
	
	variable interp_y = (edcmax-edcmin)*ratio + edcmin

	variable i
	variable interp_x =NaN
	variable fit_from
	variable fit_to
	duplicate/O/R=(edcmin_loc, edcmax_loc) edc, edc_y, edc_x, edc_fit_y
	edc_x = x
	
	for(i=0;i<smooth_time;i+=1)
		smooth/E=3 smooth_pnts, edc_fit_y
	endfor
	
	interp_x = interp(interp_y, edc_fit_y, edc_x)

	for(i=0; i<fit_time; i+=1)
		fit_from = max(interp_x-fit_range, edcmin_loc)
		fit_to = min(interp_x+fit_range, edcmax_loc)
		duplicate/O/R=(fit_from, fit_to) edc, edc_y, edc_x, edc_fit_y
		edc_x = x
		CurveFit/M=2/Q poly 9, edc_y/x=edc_x/D=edc_fit_y
		interp_x = interp(interp_y, edc_fit_y, edc_x)
		//print  nameofwave(edc)+"  "+num2str(interp_x)
	endfor
	
	string edc_fit_name = cropname("fit"+cleanupname(ratio_string,0)+nameofwave(edc))
//
 	duplicate/o edc_fit_y $(edc_fit_name)
//
	killwaves/z edc_y, edc_x, edc_fit_y
	//wave edc_fit = $(edc_fit_name)
	//appendtograph edc, edc_fit
	//ModifyGraph lsize($(nameofwave(edc_fit)))=3
	//print interp_y
	return abs(interp_x)-abs(edcmax_loc)
end

function widthinterp(width,tem, doping)
	//first interp along doping, then interp along temperature. the result is not promising.
	wave width
	wave tem
	wave doping
	
	make/o/n=14 temp_width_tem
	make/o/n=5 temp_width_doping
	
	make/o/n=(100,14) width_interp_0
	setscale/I x, doping[0], doping[4],width_interp_0
	setscale/I y, tem[0], tem[13],width_interp_0
	
	variable index
	for(index=0;index<dimsize(width_interp_0,1);index+=1)
		temp_width_doping = width[p][index]
		width_interp_0[][index]=interp(x, doping, temp_width_doping)
	endfor
		
	make/o/n=(100,300) width_interp_1
	setscale/I x, doping[0], doping[4],width_interp_1
	setscale/I y, tem[0], tem[13],width_interp_1
	for(index=0;index<dimsize(width_interp_1,0);index+=1)
		temp_width_tem = width_interp_0[index][p]
		width_interp_1[index][]=interp(y, tem,  temp_width_tem)
	endfor
end

function sparse_plot(deltaT, deltaD)
// sparse_plot(1,0.002)
	variable deltaT
	variable deltaD
	
	make/o/n=(1000,1000) width_sparse
	setscale/I x, 0.16, 0.22, width_sparse
	setscale/I y, 0, 330, width_sparse
	
	width_sparse = NaN
	variable doping
	variable tcp
	variable index
	wave tc
	for(index=0;index<5;index+=1)
		tcp=tc[index]
		wave width = $("width_OD"+num2str(tcp))
		wave tem = temp
		doping = tc2doping(tcp)
		add_sparse_data(width_sparse, width, tem, doping,deltaT, deltaD)
	endfor
	
end

Function add_sparse_data(width_sparse, width, tem,doping, deltaT, deltaD)
	wave width_sparse
	wave width
	wave tem
	variable doping
	variable deltaT
	variable deltaD
	variable index
	variable width_p
	variable tem_p
	
	for(index=0;index<numpnts(tem);index+=1)
		width_p = width[index]
		tem_p = tem[index]
		width_sparse = ((abs(x-doping)<deltaD)&&(abs(y-tem_p)<deltaT))? width_p : width_sparse(x)(y)
	endfor
end


function carpet_edc_width(spectrum,ratio)
	wave spectrum
	string ratio
	
	//settings
	variable xindexfrom = 175
	variable xindexto = 465
	//endsettings
	
	string outputwavename = nameofwave(spectrum)+"_width"
	
	make/o/n=(dimsize(spectrum, 1)) temp_carpet_edc
	make/o/n=(dimsize(spectrum,0)) $(outputwavename)
	
	wave outputwave = $outputwavename
	setscale/P x, dimoffset(spectrum,1), dimdelta(spectrum, 1), temp_carpet_edc
	setscale/P x, dimoffset(spectrum,0), dimdelta(spectrum, 0), outputwave
	outputwave = NAN
	variable xindex
	for(xindex=xindexfrom;xindex<xindexto;xindex+=1)
		temp_carpet_edc = spectrum[xindex][p]
		outputwave[xindex]=find_width(temp_carpet_edc, ratio)
	endfor
end


function edc_width()
	make/o/n=14 width_060, width_070, width_080, width_090
	duplicate root:EDC:OD71:tem tem
//	display
//	universial_batch("width_040,find_width,0.40")
//	geo();offset2(3)
//	ModifyGraph width=216,height=432
//	SetAxis bottom -0.5,0.5
//	display
//	universial_batch("width_050,find_width,0.50")
//	geo();offset2(3)
//	ModifyGraph width=216,height=432
//	SetAxis bottom -0.5,0.5
	display
	universial_batch("width_060,find_width,0.60")
	geo();offset2(3)
	ModifyGraph width=216,height=432
	SetAxis bottom -0.5,0.5
	display
	universial_batch("width_070,find_width,0.70")
	geo();offset2(3)
	ModifyGraph width=216,height=432
	SetAxis bottom -0.5,0.5
	display
	universial_batch("width_080,find_width,0.80")
	geo();offset2(3)
	ModifyGraph width=216,height=432
	SetAxis bottom -0.5,0.5
	display
	universial_batch("width_090,find_width,0.90")
	geo();offset2(3)
	ModifyGraph width=216,height=432
	SetAxis bottom -0.5,0.5
	Display width_060,width_070,width_080,width_090 vs tem
end

function find_min(mdc,pl)
	wave mdc
	string pl
	wavestats/Q mdc
	//return V_min
	return V_minloc
end

function get_curvature(edc, error)
	wave edc
	string error
	//settings
	variable efrom=-0.06
	variable eto = 0.04
	//end settings
	CurveFit/Q poly 3, edc(efrom,eto)/D
	wave w_coef
	wave w_sigma
	variable curvature = w_coef[2]/(1+w_coef[1]^2)^(3/2)
	variable curvature_error =3* sqrt((w_sigma[2]/(1+w_coef[1]^2)^(3/2))^2+(w_sigma[1]*3*w_coef[2]*w_coef[1]/(1+w_coef[1]^2)^(5/2))^2)
	if(stringmatch(error, "error"))
		return curvature_error
	else
		return curvature
	endif
end

function get_sec_derivative(edc, error)
	wave edc
	string error
	//settings
	variable efrom=-0.035
	variable eto = 0.035
	//end settings
	CurveFit/Q poly 3, edc(efrom,eto)/D
	wave w_coef
	wave w_sigma
	//variable curvature = w_coef[2]/(1+w_coef[1]^2)^(3/2)
	//variable curvature_error =3* sqrt((w_sigma[2]/(1+w_coef[1]^2)^(3/2))^2+(w_sigma[1]*3*w_coef[2]*w_coef[1]/(1+w_coef[1]^2)^(5/2))^2)
	if(stringmatch(error, "error"))
		return 3*w_sigma[2]
	else
		return w_coef[2]
	endif
end

function get_depression(edc,pl)
	wave edc
	string pl
	print 1-2*edc(0)/(edc(-0.05)+edc(0.05))
end

make/o/n=6 OD86_curvature, OD86_curvature_error
ub("OD86_curvature,get_curvature,curvature;OD86_curvature_error,get_curvature,error")


function label_tc_tstar(tc,tstar)
	wave tc
	wave tstar
	wave temp
	variable index
	variable tcp
	string name
	for(index=0;index<numpnts(tc);index+=1)
		tcp = tc[index]
		name = "tstar"+num2str(tcp)
		make/o/n=1 $name
		setscale/P x,tstar[index],1,$name
		wave tempwave =$name
		wave widthwave=$("width_OD"+num2str(tcp))
		
		tempwave=interp(x,temp, widthwave)-0.01
		
		name = "tc"+num2str(tcp)
		make/o/n=1 $name
		setscale/P x,tcp,1,$name
		wave tempwave =$name
		tempwave=interp(x,temp, widthwave)-0.01
	endfor
end	

function norm_by_temp(target_curve,temwavename)
	wave target_curve
	string temwavename
	
	wave temwave = $temwavename
	
	string norm_curve_name = nameofwave(target_curve)+"_Tnorm"
	
	duplicate/o target_curve, $norm_curve_name
	wave newwave = $norm_curve_name
	newwave = target_curve[p]/(8.61733034e-5 *temwave[p])

end
	


function norm_edc_by_temp(edc,pl)
	wave edc
	string pl
	
	variable T = Get_Info(edc,"SampleTemperature")
	variable newoffset = dimoffset(edc,0)/(T* 8.61733034e-5)
	variable newdelta = dimdelta(edc,0)/(T* 8.61733034e-5)
	
	string norm_curve_name = nameofwave(edc)+"_Tn"
	duplicate/o edc, $norm_curve_name
	wave newwave = $norm_curve_name
	setscale/P x, newoffset, newdelta, newwave
end



function edc_width_test()
print "hellp"
end


function qpweight(edc,pl)
	wave edc
	string pl
	
	wavestats/Q/R=(-0.85,-0.65) edc
	variable bkg = V_avg
	
	duplicate/O edc temp_edc
	temp_edc -= bkg
	wavestats/Q/R=(-0.85,0) temp_edc
	variable qp = V_sum
	
	return qp/bkg
end

function min_norm(mdc)
	wave mdc
	variable dev=wavemin(mdc)
	mdc/=dev
	
end
	

function norm_by_intensity(image,pl)
//ub("naw,norm_by_intensity,pl")
	wave image
	string pl
	
	//settings
	variable Efrom= -0.85
	variable Eto=-0.65
	variable kfrom = -0.4
	variable kto = 0.4
	//
	
	imagestats/GS={kfrom, kto, efrom, eto} image
	
	image/=V_avg
end
	
	
	
function quick_dupicate()
	string name = getdatafolder(0)
	wave width_060
	wave width_070
	wave width_080
	wave width_090


	duplicate/o width_060, $("root:EDC:"+name+"_width_060")
	duplicate/o width_070, $("root:EDC:"+name+"_width_070")
	duplicate/o width_080, $("root:EDC:"+name+"_width_080")
	duplicate/o width_090, $("root:EDC:"+name+"_width_090")
end


function AN_bkg_rm(spectrum, pl)
	//this function removes bkg using edcs at the edge of image.
	//a fitting is done to smooth the edc. poly + FD* poly
	//ub("NAW,AN_bkg_rm,pl")
	wave spectrum
	string pl
	
	//settings:
	string kfrom_kto = "-0.6,-0.55"//for nodal cut, [-0.6,-0.55]
	//endsettings
	
	wave edc = get_edc(spectrum, kfrom_kto)
	string bkgname = nameofwave(spectrum)+"_bkg"
	string fitname = bkgname+"F"
	rename edc, $bkgname
	duplicate/o edc, $fitname
	AN_edc_bkg_prepare(edc)
	wave para
	FuncFit/Q/NTHR=0 AN_edc_bkg para  edc /D=$fitname 
	
	wave fitedc = $fitname
	
	spectrum[][]-=fitedc[q]
	
	string notestr="bkg removed using "+fitname+"\r" + note(spectrum)
	note/K spectrum, notestr
end



function gap_stat(image, kfromkto)
//universial_batch("NAW,gap_stat,202,214")
//make/n=14 gap_OD71,error_OD71, gap_OD81, error_OD81, gap_OD86,error_OD86,gap_OD87,error_OD87,gap_OD90,error_OD90,gap_OP91,error_OP91
//ub("gap_OP91,get_info,AveragePeakPosition;error_OP91,get_info,PeakPositionSigma;")
	wave image
	string kfromkto
	
	//settings
	variable smoothpoints = 0
	variable smoothtime = 0
	variable efrom = -0.5
	variable eto = 0.001
	variable tc = 100
	
	variable sample_temperature = get_info(image, "sampletemperature")
	if((smoothtime!=0) &&(sample_temperature<(tc+5)))
		smoothtime =1
	endif
	//end settings
	
	string imagename = nameofwave(image)
	variable kfrom = str2num(stringfromlist(0, kfromkto,","))
	variable kto = str2num(stringfromlist(1,kfromkto,","))

	variable index, sindex
	string maxwavename =imagename+ "_maxpos_s" +num2str(smoothpoints)+ "t" +num2str(smoothtime)
	make/o/n=(kto-kfrom+1) $maxwavename
	wave maxwave= $maxwavename
	for(index=kfrom;index<(kto+1);index+=1)
		wave tempedc =  slice_edc(image,num2str(index))
		if(smoothtime!=0)
			for(sindex=0;sindex<smoothtime;sindex+=1)
				smooth/E=3 smoothpoints, tempedc
			endfor
		endif
		wavestats/R=(-0.8,0.001)/Q tempedc
		maxwave[index-kfrom]=-abs(V_maxloc)
	endfor
	string notestr= note(image)
	wavestats/Q maxwave
	string newnote = "AveragePeakPosition="+num2str(V_avg)+"\r"
	newnote += "PeakPositionError= "+num2str(V_sem)+"\r"
	newnote +="PeakPositionSigma=" +num2str(V_sdev)+"\r"
	newnote +="kfromkto="+kfromkto+"\r"
	newnote +=notestr
	note/K maxwave, newnote
	killwaves/Z tempedc
end
	
	
	
function highlight_cartoon()
	variable ab_vhs=-0.0145
	variable bb_vhs=-0.118
	variable ab_invmass=3.2055
	variable bb_invmass=3.99
	variable bqp_ext = 1.4
	variable gap = 0.019

	make/o/n=1000 normal_disp_ab, sc_disp_ab_a,sc_disp_ab_b,normal_disp_bb, sc_disp_bb_a,sc_disp_bb_b
	setscale/I x, -0.2,0.2,normal_disp_ab, sc_disp_ab_a,sc_disp_ab_b,normal_disp_bb, sc_disp_bb_a,sc_disp_bb_b
	
	normal_disp_ab=ab_vhs+ab_invmass*x^2
	normal_disp_bb=bb_vhs+bb_invmass*x^2
	sc_disp_ab_a=sqrt(gap^2+normal_disp_ab[p]^2)
	sc_disp_bb_a=sqrt(gap^2+normal_disp_bb[p]^2)
	
	sc_disp_ab_b=-sqrt(gap^2+normal_disp_ab[p]^2)
	sc_disp_bb_b=-sqrt(gap^2+normal_disp_bb[p]^2)
	
	
	sc_disp_bb_a= ((abs(sc_disp_bb_a[p])>bqp_ext *gap)&&(normal_disp_bb[p]<0))? NaN : sc_disp_bb_a[p]
	sc_disp_bb_b= ((abs(sc_disp_bb_b[p])>bqp_ext *gap)&&(normal_disp_bb[p]>0))? NaN : sc_disp_bb_b[p]
	
	sc_disp_ab_a= ((abs(sc_disp_ab_a[p])>bqp_ext *gap)&&(normal_disp_ab[p]<0))? NaN : sc_disp_ab_a[p]
	sc_disp_ab_b= ((abs(sc_disp_ab_b[p])>bqp_ext *gap)&&(normal_disp_ab[p]>0))? NaN : sc_disp_ab_b[p]
	
end

make/o/n=(1000,1000) normal_img
setscale/I x,-5,5,normal_img
setscale/I y, -0.3,0.3,normal_img
normal_img=gauss(y,normal_disp_avg(x),0.3)



make/o/n=15 tem, SW05
universial_batch("NaW,intensity_normalization,-0.25,0,-inf,inf;tem,Get_info,sampletemperature;SW05,Averaged_Intensity,-0.005,0,-inf,inf;")

function universial_batch(batch_operation_list)
//batch_operation_list:
//result_wave_1,function1,para1,para2,para3,para4;NaW,function2,para1,para2,para3;...
//effect: result_wave_1[index]=function1(target_indexed,"para1,para2,para3,para4")
//			function2(target_indexed,"para1,par2,para3")
//			...
//placeholder indicating no result_saving_wave must be NaW
	string batch_operation_list
	
	variable index=0
	variable list_index
	string batch_operation_list_line, result_saving_wave_name, function_name, para_list
	do
		wave target=$(getbrowserselection(index))
		for(list_index=0;list_index<ItemsInList(batch_operation_list, ";");list_index+=1)
			batch_operation_list_line=StringFromList(list_index,batch_operation_list,";")
			result_saving_wave_name=StringFromList(0,batch_operation_list_line,",")
			function_name=StringFromList(1,batch_operation_list_line,",")
			para_list=removelistitem(0,removelistitem(0,batch_operation_list_line,","),",")
			if(stringmatch(result_saving_wave_name,"NaW"))
				FuncRef funcref_error_message f=$function_name
				f(target,para_list)
			else
				wave result_saving_Wave=$result_saving_wave_name
				FuncRef funcref_error_message f=$function_name
				result_saving_wave[index]=f(target,para_list)
			endif
		endfor
		index+=1
	while(strlen(getbrowserselection(index))!=0)
end


function funcref_error_message(target,para_list)
	wave target
	string para_list
	
	print "function reference not defined.\r"
end



function Averaged_Intensity(spectrum, Efrom_Eto_kfrom_kto)
//this function gives the average value of spectrum intensity within given energy and momentum window
	wave spectrum
	string Efrom_Eto_kfrom_kto
	
	variable energy_from=str2num(stringfromlist(0,Efrom_Eto_kfrom_kto,","))
	variable energy_to=str2num(stringfromlist(1,Efrom_Eto_kfrom_kto,","))
	variable momentum_from=str2num(stringfromlist(2,Efrom_Eto_kfrom_kto,","))
	variable momentum_to=str2num(stringfromlist(3,Efrom_Eto_kfrom_kto,","))
	
	variable index, return_value
	
	make/o/n=(dimsize(spectrum,0)) temp_mdc
	setscale/P x, dimoffset(spectrum,0),dimdelta(spectrum,0),temp_mdc
	make/o/n=(dimsize(spectrum,1)) temp_edc
	setscale/P x, dimoffset(spectrum,1),dimdelta(spectrum,1),temp_edc
	for(index=0;index<numpnts(temp_mdc);index+=1)
		temp_edc=spectrum[index][p]
		temp_mdc[index]=faverage(temp_edc,min(energy_from,energy_to),max(energy_from,energy_to))
	endfor
	return_value=faverage(temp_mdc,min(momentum_from,momentum_to),max(momentum_from,momentum_to))*abs(dimdelta(spectrum,1)*dimdelta(spectrum,0))
	killwaves/z temp_mdc, temp_edc
	return return_value
end

function Averaged_Intensity_DC(spectrum, Efrom_Eto)
//this function gives the average value of an 1D spectrum
wave spectrum
string Efrom_Eto

variable energy_from=str2num(stringfromlist(0,Efrom_Eto,","))
variable energy_to=str2num(stringfromlist(1,Efrom_Eto,","))
	
variable  return_value
return_value=faverage(spectrum,min(energy_from,energy_to),max(energy_from,energy_to))*abs(dimdelta(spectrum,0))

return return_value
end


function Get_Variance_0(spectrum,Efrom_Eto)
//This function returns the weighted variance of an 1D distribution.
//For example, for an edc, if the center of mass is at E0, the weighted variance gives Sum_E I(E)*(E-E0)^2/ Sum_E I(E)
//universial_batch("OD81_mass,get_variance,-0.8,0.1")
	wave spectrum
	string Efrom_Eto
	
	variable energy_from=str2num(stringfromlist(0,Efrom_Eto,","))
	variable energy_to=str2num(stringfromlist(1,Efrom_Eto,","))
	
	variable center_of_mass, weighted_variance
	
	duplicate/O spectrum spectrum_x, spectrum_variance
	variable bkg
	bkg=wavemin(spectrum_x,-0.8,-0.4)
	//spectrum_x-= bkg
	
	duplicate/O spectrum_x, spectrum_bkup
	spectrum_x*=x
	center_of_mass=faverage(spectrum_x,min(energy_from,energy_to),max(energy_from,energy_to))/faverage(spectrum_bkup,min(energy_from,energy_to),max(energy_from,energy_to))
	center_of_mass=0
	spectrum_variance*=(x-center_of_mass)^2
	weighted_variance=faverage(spectrum_variance,min(energy_from,energy_to),max(energy_from,energy_to))/faverage(spectrum,min(energy_from,energy_to),max(energy_from,energy_to))
	killwaves/z spectrum_variance, spectrum_x,spectrum_bkup
	//return center_of_mass
	return weighted_variance
End

function Get_center(spectrum,Efrom_Eto)
//This function returns the center of mass of an 1D distribution.
//universial_batch("OD81_mass,get_center,-0.8,0.1")
	wave spectrum
	string Efrom_Eto
	
	variable energy_from=str2num(stringfromlist(0,Efrom_Eto,","))
	variable energy_to=str2num(stringfromlist(1,Efrom_Eto,","))
	
	variable center_of_mass
	
	duplicate/O spectrum spectrum_x
	//variable bkg
	//bkg=wavemin(spectrum_x,-0.8,-0.4)
	//spectrum_x-= bkg
	spectrum_x*=x
	center_of_mass=faverage(spectrum_x,min(energy_from,energy_to),max(energy_from,energy_to))/faverage(spectrum,min(energy_from,energy_to),max(energy_from,energy_to))
	killwaves/z spectrum_x
	return center_of_mass
End


function Get_variance(spectrum,Efrom_Eto)
//This function returns the variance of an 1D distribution.
//universial_batch("OD81_mass,get_center,-0.8,0.1")
	wave spectrum
	string Efrom_Eto
	
	variable energy_from=str2num(stringfromlist(0,Efrom_Eto,","))
	variable energy_to=str2num(stringfromlist(1,Efrom_Eto,","))
	
	variable var
	
	
	//variable bkg
	//bkg=wavemin(spectrum_x,-0.8,-0.4)
	//spectrum_x-= bkg
	variable center=  Get_center(spectrum,Efrom_Eto)
	center=0
	duplicate/O spectrum spectrum_x
	spectrum_x*=(x-center)^2
	var=faverage(spectrum_x,min(energy_from,energy_to),max(energy_from,energy_to))/faverage(spectrum,min(energy_from,energy_to),max(energy_from,energy_to))
	killwaves/z spectrum_x
	return sqrt(var)
End

function fit_gold(spectrum, base)
// this function generate gold disp for all selected waves based on comparison with disp base.
// first ub("naw,fit_gold,root:gold:NormWaves:Au_0000_disp")
// then select the continuous one (should be without beam dump, change of photon energy , etc) interpolate_gold()
	wave spectrum
	string base
	
	string specname = nameofwave(spectrum)
	string savepath = "root:gold:NormWaves:"+specname+"_disp"
	
	wave edc = get_edc(spectrum, "-100,100")
	duplicate/o edc,$("edc_"+specname)
	killwaves/Z edc
	wave edc = $("edc_"+specname)
	fit_gold_initialize(edc)
	wave para
	wave para_epsilon
	variable efrom = para[4]-0.05
	variable eto = para[4]+0.05
	
	Make /o/T/n=2/Free ConstrainWave
	ConstrainWave[0]="K6 > 0"
	ConstrainWave[1]="K2 > 0"

	
	FuncFit/n/q/H="0000010"  gold_fit_function,para,edc(efrom,eto)/D /C=ConstrainWave/E=para_epsilon
	
	wave basewave=$base
	duplicate/O basewave, $savepath
	wave newwave = $savepath
	string newnote = "SourceFileName="+specname+".txt\r"
	newnote += "SourceWave="+specname+"\r"
	newnote += "Scaling=channels\r"

	variable base_fermienergy = get_info(basewave, "BaseFermiEnergy")
	newwave = basewave[p]+para[4]-base_fermienergy
	
	newnote += "FermiEnergy=0"+"\r"
	newnote += "PhotonEnergy="+num2str(Get_Info(edc,"PhotonEnergy"))+"eV\r"
	newnote +="PassEnergy="+num2str(Get_Info(edc,"PassEnergy"))+"eV\r"
	newnote +="EnergyStep="+num2str(1000*Get_Info(edc,"Energy Step"))+"meV\r"
	
	newnote=replacenumberbykey("FermiEnergy",newnote,mean(newwave),"=","\r")
	
	note/K newwave, newnote
	duplicate/o para, $("para_"+specname)
	wave w_sigma
	duplicate/o w_sigma, $("sigma_"+specname)
	killwaves/Z temp_edc,wGaussian,para, w_sigma, para_epsilon
end

function fit_gold_initialize(edc)
	wave edc

	duplicate/O edc, edc_guess
	
	make/d/o/n=7 para
	//pw[0]=constant bkg
	//pw[1]=slope bkg
	//pw[2]=FD Constant
	//pw[3]=FD slope
	//pw[4]=FD Chemical potential
	//pw[5]=FD temperature
	//pw[6]=analyzer resolution
	
	
	
	
	wavestats/Q edc
	Smooth 13, edc_guess
	Differentiate edc_guess
	CurveFit/q gauss edc_guess 
	WAVE w_coef
	
	
	duplicate/o para, para_epsilon
	para_epsilon=1e-3
	
	para[0] = v_min
	para[1]=0
	
	para[2] = v_max-v_min
	para[3]=0
	para[4]= w_coef[2]
	para[5]=get_info(edc,"SampleTemperature")
	para[6]=w_coef[3]
	
	if (numtype(para[6])==2)
		para[6]=0.01
	endif
	
	variable efrom = para[4]-0.55
	variable eto = para[4]+0.55
	make/o/n=2000 temp_edc
	setscale/I x,efrom, eto, temp_edc
	make/o/n=1001 wGaussian
	setscale/P x,-500*dimdelta(temp_edc,0),dimdelta(temp_edc,0), wGaussian
	KillWaves/ z edc_guess, w_coef
end

Function gold_fit_function(pw, yw, xw) : FitFunc
//pw[0]=constant bkg
//pw[1]=slope bkg
//pw[2]=FD Constant
//pw[3]=FD slope
//pw[4]=FD Chemical potential
//pw[5]=FD temperature
//pw[6]=analyzer resolution

	Wave pw, yw, xw

	Variable kB=8.617342e-5

	wave temp_edc, wGaussian

	temp_edc= pw[0]+pw[1]*x + (pw[2]+pw[3]*x)/(exp((x-pw[4]) / (kB*pw[5]))+1.0 )

	wGaussian= Gauss(x, 0, pw[6]/(2*(sqrt(2*ln(2)))))*DimDelta(wGaussian,0)

	convolve/A wGaussian, temp_edc

	yw=temp_edc(xw[p])
End

function interpolate_gold()
//this function interpolate gold disp based on time
	svar loadwavenotes=root:internalUse:global_panel:LoadWaveNotes
	svar loadwavelist=root:internalUse:global_panel:LoadWavelist
	
	string selected = ""
	string disp_name
	
	variable index=0
	do
		disp_name = getbrowserselection(index)
		selected+=disp_name+";"
		index+=1
	while(strlen(getbrowserselection(index))!=0)
	
	setdatafolder root:gold:NormWaves
	
	variable/D ef1,ef2,time1,time2,time_interp,ef_interp
	string source1, source2, notestr, createname, tempnote
	
	variable fromindex, toindex, createindex
	
	
	for(index=0;index<(itemsinlist(selected)-1);index+=1)
		wave disp1=$(stringfromlist(index,selected))
		wave disp2=$(stringfromlist(index+1,selected))
		
		ef1= Get_Info(disp1,"FermiEnergy")
		ef2= Get_Info(disp2,"FermiEnergy")
		
		source1=Get_Info_string(disp1,"SourceFileName")
		source2=Get_Info_string(disp2,"SourceFileName")
		
		fromindex=whichlistitem(source1,loadwavelist,"\r",0,0)
		toindex=whichlistitem(source2,loadwavelist,"\r",0,0)
		
		notestr=stringfromlist(fromindex,loadwavenotes,"\r")
		time1=get_time_sec(notestr)
		
		notestr=stringfromlist(toindex,loadwavenotes,"\r")
		time2=get_time_sec(notestr)
		
		for(createindex=(fromindex+1);createindex<toindex;createindex+=1)
			notestr=stringfromlist(createindex,loadwavenotes,"\r")
			createname=stringbykey("Filename",notestr,"=",";")
			tempnote=createname
			createname=ReplaceString(".txt", createname, "")+"_disp0"
			time_interp = get_time_sec(notestr)
			ef_interp= ef1+ (ef2-ef1)*(time_interp-time1)/(time2-time1)
			duplicate/o disp1, $createname
			wave create = $createname
			create +=ef_interp-ef1
			notestr=note(create)
			
			notestr=replacenumberbykey("FermiEnergy",notestr,ef_interp,"=","\r")
			//tempnote=stringbykey("SourceFileName",notestr,"=","\r")+"_create"
			notestr=replacestringbykey("SourceFileName",notestr,tempnote,"=","\r")
			tempnote=stringbykey("SourceWave",notestr,"=","\r")+"_create"
			notestr=replacestringbykey("SourceWave",notestr,tempnote,"=","\r")
			note/K create, notestr
		endfor
		
	endfor
end

function get_time_sec(notestr)
	string notestr
	variable month, day,year,hour, mintime, timesec
	string datestr,timestr,AMPM
	
	datestr=stringbykey("Date",notestr,"=",";")
	timestr=stringbykey("Time",notestr,"=",";")
	sscanf datestr,"%g/%g/%g",month,day,year
	sscanf timestr,"%g:%g %s",hour,mintime,AMPM
	if (hour!=12)
		timesec=date2secs(year,month,day)+hour*3600+mintime*60
		if (stringmatch(AMPM,"PM"))
			timesec+=12*3600
		endif
	else
		timesec=date2secs(year,month,day)+mintime*60
		if (stringmatch(AMPM,"PM"))
			timesec+=12*3600
		endif
	endif
	return timesec
end


function Get_Info(spectrum,match_string)
	wave spectrum
	string match_string
	
	string note_string=note(spectrum)
	variable return_value=numberbykey(match_string,note_string,"=","\r")
	return return_value
End


function/S Get_Info_string(spectrum,match_string)
	wave spectrum
	string match_string
	
	string note_string=note(spectrum)
	string return_value=stringbykey(match_string,note_string,"=","\r")
	return return_value
End


function Get_full_Info(spectrum,match_string)
	wave spectrum
	string match_string
	
	string note_string=note(spectrum)
	string leftnotes = stringbykey("LeftNotes", note_string,"=","\r")
	variable return_value=numberbykey(match_string,leftnotes,"=",";")
	return return_value
End




function/Wave slice_edc(spectrum,index_string)
	wave spectrum
	string index_string
	
	string note_string=note(spectrum)
	variable index=str2num(stringfromlist(0,index_string,","))
	make/o/n=(dimsize(spectrum,1)) temp_edc
	setscale/P x, dimoffset(spectrum,1),dimdelta(spectrum,1),temp_edc
	temp_edc=spectrum[index][p]
	note/K temp_edc,note_string
	return temp_edc
end

function/wave slice_mdc(spectrum,index_string)
	wave spectrum
	string index_string
	
	string note_string=note(spectrum)
	variable index=str2num(stringfromlist(0,index_string,","))
	make/o/n=(dimsize(spectrum,0)) temp_mdc
	setscale/P x, dimoffset(spectrum,0),dimdelta(spectrum,0),temp_mdc
	temp_mdc=spectrum[p][index]
	note/K temp_mdc,note_string
	return temp_mdc
end

function find_max(spectrum,Efrom_Eto_kfrom_kto)
	wave spectrum
	string Efrom_Eto_kfrom_kto
	
	variable energy_from=str2num(stringfromlist(0,Efrom_Eto_kfrom_kto,","))
	variable energy_to=str2num(stringfromlist(1,Efrom_Eto_kfrom_kto,","))
	variable momentum_from=str2num(stringfromlist(2,Efrom_Eto_kfrom_kto,","))
	variable momentum_to=str2num(stringfromlist(3,Efrom_Eto_kfrom_kto,","))
	
	variable energy_from_pnt=round((energy_from-dimoffset(spectrum,1))/dimdelta(spectrum,1))
	variable energy_to_pnt=round((energy_to-dimoffset(spectrum,1))/dimdelta(spectrum,1))
	variable index
	variable step=((energy_to_pnt-energy_from_pnt)>0)
	variable line_max,image_max
	image_max=0
	for(index=energy_from_pnt;index<energy_to_pnt+1;index+=step)
		slice_mdc(spectrum,num2str(index))
		wave temp_mdc
		line_max=wavemax(temp_mdc,momentum_from,momentum_to)
		if(line_max>image_max)
			image_max=line_max
		endif
	endfor
	killwaves/Z temp_mdc
	return image_max
end

function FD_regulator(spectrum, tolerance_string)
	wave spectrum
	string tolerance_string
	
	variable tolerance=str2num(stringfromlist(0,tolerance_string,","))
	variable image_max=tolerance*find_max(spectrum,"-0.15,0,-inf,inf")
	
	duplicate/O spectrum temp_spectrum
	spectrum=((temp_spectrum[p][q]>0)&&(temp_spectrum[p][q]<image_max))? temp_spectrum[p][q] : 0
	killwaves/Z temp_spectrum
end
	
function Intensity_normalization(spectrum, Efrom_Eto_kfrom_kto)
	wave spectrum
	string Efrom_Eto_kfrom_kto
	
	variable norm_value = Averaged_Intensity(spectrum, Efrom_Eto_kfrom_kto)
	if(numtype(norm_value)!=2)
		duplicate/o spectrum temp_spectrum
		spectrum=temp_spectrum[p][q]/norm_value
		killwaves/Z temp_spectrum
	else
		print "NaN in averaged area"
	endif
end
		
function rename_wave(spectrum,prefix_suffix)
	wave spectrum
	string prefix_suffix
	
	
	//settings:
	prefix_suffix = "T"+num2str(round(get_info(spectrum,"sampletemperature")))+"_"
	//endsettings
	variable index=strsearch(prefix_suffix,"_",0,2)
	string new_name=prefix_suffix[0,index-1]+"_"+nameofwave(spectrum)+prefix_suffix[index,inf]
	rename spectrum $new_name
end


function crop_EDC(edc,Efrom_Eto)
	wave edc
	string Efrom_Eto
	
	variable energy_from=str2num(stringfromlist(0,Efrom_Eto,","))
	variable energy_to=str2num(stringfromlist(1,Efrom_Eto,","))
	
	string name = cropname("C_"+nameofwave(EDC))
	duplicate/o/R=(energy_from, energy_to) edc, $name

end







function sparsedata_peak(y_wave,x_wave_name)
//this function get the peak position using the 4 data points closest to the peak. linear extrapolation and find the crossing point as peak position.
	wave y_wave
	string x_wave_name
	
	variable kill_tempwave=waveexists($x_wave_name)
	if(kill_tempwave)
		wave x_wave_temp=$x_wave_name
	else
		duplicate/o y_wave x_wave_temp
		x_wave_temp=x
	endif
	
	variable index
	variable max_value=wavemax(y_wave)
	variable max_index
	for(index=0;index<numpnts(y_wave);index+=1)
		if(y_wave[index]==max_value)
			max_index=index
			break
		endif
	endfor
	
	variable slope1, slope2, return_value
	
	index=max_index
	
	if(y_wave[index-1]>y_wave[index+1])
		slope1=(y_wave[index]-y_wave[index+1])/(x_wave_temp[index]-x_wave_temp[index+1])
		slope2=(y_wave[index-1]-y_wave[index-2])/(x_wave_temp[index-1]-x_wave_temp[index-2])
		return_value=(y_wave[index-1]-y_wave[index]-slope2*x_wave_temp[index-1]+slope1*x_wave_temp[index])/(slope1-slope2)
	else
		slope1=(y_wave[index]-y_wave[index-1])/(x_wave_temp[index]-x_wave_temp[index-1])
		slope2=(y_wave[index+1]-y_wave[index+2])/(x_wave_temp[index+1]-x_wave_temp[index+2])
		return_value=(y_wave[index+1]-y_wave[index]-slope2*x_wave_temp[index+1]+slope1*x_wave_temp[index])/(slope1-slope2)
	endif
	
	if(!kill_tempwave)
		killwaves/Z x_wave_temp
	endif
	
	return return_value
end

function MH()
	universial_batch("NaW,MH_Deconvolve_3D,pl;")
end

//
//function NLC_3D(spectra,I_channel_I0_str)
//	//This function works together with NLC_load(target,I_channel_I0,start_channel), on 3D data
//	//universial_batch("NaW,NLC_3D,I_channel_I0_str;")
//	wave spectra
//	string I_channel_I0_str
//	
//	wave I_channel_I0=$(I_channel_I0_str)
//	string wavenote = note(spectra)
//	
//	
//	variable dimsize0 = Dimsize(spectra, 0)
//	variable dimsize1 = Dimsize(spectra,1)
//	 
//	variable dimdelta0 = Dimdelta(spectra, 0)
//	variable dimdelta1 = Dimdelta(spectra,1)
//	
//	variable dimoffset0 = Dimoffset(spectra, 0)
//	variable dimoffset1 = Dimoffset(spectra,1)
//	
//	//if (abs(dimdelta1 - 0.001)>0.0001)
//	//return 0
//	//endif
//	make/o/n=(dimsize0,dimsize1) tempwave
//	setscale/P x,dimoffset0,dimdelta0, tempwave
//	setscale/P y,dimoffset1,dimdelta1, tempwave
//	
//	
//	
//	
//	tempwave = spectra[p][q][0]
//	NLC_load(target,I_channel_I0,start_channel)
//	wave tempwave_NLC
//	
//	spectra[][][0]=tempwave_NLC[p][q]
//	killwaves/Z tempwave, tempwave_NLC
//	
//	
//	string newwavenote = "U_Proc_NLCorrection using"+ I_channel_I0_str+"\r" +wavenote
//	note/K spectra, newwavenote
//	print nameofwave(spectra)+" correction completed."
//	return 1
//
//end




function MH_Deconvolve_3D(spectra,pl)
//This function works together with MH_Deconvolve, on 3D data
//universial_batch("NaW,MH_Deconvolve_3D,pl;")
wave spectra
string pl
string wavenote = note(spectra)
variable hv = numberbykey("PhotonEnergy",wavenote,"=","\r" )
string beam_profile_name = ""
if (abs(hv - 21) < 0.05)
	beam_profile_name = "root:gold:BeamProfile:wprofile_21eV_201903"
elseif (abs(hv - 18.4) < 0.05)
	beam_profile_name = "root:gold:BeamProfile:wprofile_184eV"
endif

if(strlen( beam_profile_name)!=0)
variable dimsize0 = Dimsize(spectra, 0)
variable dimsize1 = Dimsize(spectra,1)
 
variable dimdelta0 = Dimdelta(spectra, 0)
variable dimdelta1 = Dimdelta(spectra,1)

variable dimoffset0 = Dimoffset(spectra, 0)
variable dimoffset1 = Dimoffset(spectra,1)

//if (abs(dimdelta1 - 0.001)>0.0001)
//return 0
//endif
make/o/n=(dimsize0,dimsize1) tempwave
setscale/P x,dimoffset0,dimdelta0, tempwave
setscale/P y,dimoffset1,dimdelta1, tempwave

tempwave = spectra[p][q][0]
MH_Deconvolve(tempwave,beam_profile_name)
wave tempwave_MHD

spectra[][][0]=tempwave_MHD[p][q]
killwaves/Z tempwave, tempwave_MHD


string newwavenote = "U_Proc_MHCorrection using"+beam_profile_name+"\r" +wavenote
note/K spectra, newwavenote
print nameofwave(spectra)+" correction completed."
return 1
endif

end

	
function Reduce_curve(curve, reduce_value)
	wave curve
	string reduce_value
	
	variable reduce= str2num(reduce_value)
	
	string newwave= nameofwave(curve)+"_reduce"
	
	duplicate/O curve, $newwave
	
	wave reducedwave= $newwave
	reducedwave/=reduce

end


function norm_curve(curve, pl)
	wave curve
	string pl
	
	variable reduce= wavemax(curve)
	
	string newwave= nameofwave(curve)+"_reduce"
	
	duplicate/O curve, $newwave
	
	wave reducedwave= $newwave
	reducedwave/=reduce

end





function MH_Deconvolve(spectra, beam_profile_name)
//This function removes the bkg due to secondary beam with different photon energy. The beam profile is extracted from gold fitting in file bkg_above_Ef. 
//Makoto's deconvolve process is used to the 5th order to remove the contribution from beam_profile
//This function must be used after NLC correction. Recommended process: NLC, x-crop, TMF, MHD, Gold Fitting, Ef....
//universial_batch("NaW,MH_Deconvolve,wprofile;")
wave spectra
string beam_profile_name

wave beam_profile=$beam_profile_name

string spectra_name=nameofwave(spectra)
spectra_name+="_MHD"

duplicate/o spectra $spectra_name
wave spectra_MHD= $spectra_name

variable pnts=floor( (dimdelta(spectra,1)*dimsize(spectra,1)+0.5)/dimdelta(beam_profile,0))-1

make/o/n=(pnts) temp_edc
setscale/P x, (dimoffset(spectra,1)-0.5), dimdelta(beam_profile,0), temp_edc
duplicate/o temp_edc, temp_edc_2

variable index, convolve_index, pnt_index, pnt_x

for(index=0;index<dimsize(spectra,0);index+=1)
	for(pnt_index=0;pnt_index<dimsize(temp_edc,0);pnt_index+=1)
		pnt_x=pnt2x(temp_edc,pnt_index)
		if(pnt_x>dimoffset(spectra,1))
			temp_edc[pnt_index]=spectra[index](pnt_x)
		else
			temp_edc[pnt_index]=spectra[index][0]
		endif
	endfor
	temp_edc_2=temp_edc[p]
	for(convolve_index=1;convolve_index<6;convolve_index+=1)
		convolve/A beam_profile, temp_edc_2
		temp_edc+=((-1)^convolve_index)*temp_edc_2(x)
	endfor
	temp_edc_2=x
	
	for(pnt_index=0;pnt_index<dimsize(spectra_MHD,1);pnt_index+=1)
		pnt_x=pnt_index*dimdelta(spectra,1)+dimoffset(spectra,1)
		spectra_MHD[index][pnt_index]=interp(pnt_x, temp_edc_2, temp_edc)
	endfor
endfor
killwaves/Z temp_edc,temp_edc_2

string wavenote = note(spectra)
string newwavenote = "U_Proc_MHCorrection using "+beam_profile_name+"\r" +wavenote
note/K spectra_MHD, newwavenote


//print nameofwave(spectra_MHD)+" MH correction completed"
end


function mdc_fit_lorentzian(spectrum,energyfrom_to_para)
	wave spectrum
	string energyfrom_to_para
	
	initialize_lorentz_x2_fit()
	
	variable energyfrom=str2num(stringfromlist(0,energyfrom_to_para,","))
	variable energyto=str2num(stringfromlist(1,energyfrom_to_para,","))
	string para_string=stringfromlist(2,energyfrom_to_para,",")
	wave parameters=$para_string


	
	
	string note_string=note(spectrum)
	
	variable index,mdc_index
	string spectrum_name=nameofwave(spectrum)
	
	string parawave_name
	for(index=0;index<dimsize(parameters,0);index+=1)
		parawave_name=spectrum_name+"_"+num2str(index)		
		make/o/n=(dimsize(spectrum,1)) $parawave_name,$(parawave_name+"_err")
		
		wave para_temp=$parawave_name
		para_temp=NaN
		setscale/P x, dimoffset(spectrum,1),dimdelta(spectrum,1),para_temp
		note/K para_temp,note_string
		wave para_temp=$(parawave_name+"_err")
		para_temp=NaN
		setscale/P x, dimoffset(spectrum,1),dimdelta(spectrum,1),para_temp
		note/K para_temp,note_string
	endfor
	
	make/o/n=(dimsize(spectrum,0)) temp_mdc,fit_temp_mdc
	setscale/P x, dimoffset(spectrum,0),dimdelta(spectrum,0),temp_mdc,fit_temp_mdc
	
	variable mdc_from=round((energyfrom-dimoffset(spectrum,1))/dimdelta(spectrum,1))-1
	variable mdc_to=round((energyto-dimoffset(spectrum,1))/dimdelta(spectrum,1))+1
	
	if(mdc_from<0)
	mdc_from=0
	endif
	
	if(mdc_to+1>dimsize(spectrum,1))
	mdc_to=dimsize(spectrum,1)-1
	endif
	
	duplicate/O spectrum, $("fit_"+spectrum_name)
	wave fit_spectrum=$("fit_"+spectrum_name)
	fit_spectrum=NaN
	
	for(mdc_index=mdc_from;mdc_index<mdc_to;mdc_index+=1)
		temp_mdc=spectrum[p][mdc_index]
		
		funcfit/N/Q lorentz_x2, parameters,temp_mdc/D=fit_temp_mdc
		wave fit_temp_mdc
		fit_spectrum[][mdc_index]=fit_temp_mdc[p]
		
		for(index=0;index<dimsize(parameters,0);index+=1)
			parawave_name=spectrum_name+"_"+num2str(index)
			wave para_temp=$parawave_name
			para_temp[mdc_index]=parameters[index]
			
			parawave_name=spectrum_name+"_"+num2str(index)+"_err"
			wave para_temp=$parawave_name
			wave w_sigma
			para_temp[mdc_index]=w_sigma[index]
		endfor
		
		duplicate/O $(spectrum_name+"_2") $("FWHM_L_"+spectrum_name)
		duplicate/O $(spectrum_name+"_5") $("FWHM_R_"+spectrum_name)
		duplicate/O $(spectrum_name+"_2_err") $("FWHM_L_"+spectrum_name+"_err")
		duplicate/O $(spectrum_name+"_5_err") $("FWHM_R_"+spectrum_name+"_err")
		
		
	endfor
	killwaves/Z temp_mdc,w_sigma,fit_temp_mdc
end

Function get_value(fwhm, xvalue)
wave fwhm
string xvalue

variable xv=str2num(xvalue)

return fwhm(xv)

end


Function get_value_p(fwhm, pvalue)
wave fwhm
string pvalue

variable xv=str2num(pvalue)

return fwhm[xv]

end


function Get_Info_from_name(spectrum,stringfrom_to)
	wave spectrum
	string stringfrom_to
	
	variable stringfrom=str2num(stringfromlist(0,stringfrom_to,","))
	variable stringto=str2num(stringfromlist(1,stringfrom_to,","))
	
	string name_string=nameofwave(spectrum)
	variable return_value=str2num(name_string[stringfrom,stringto])
	return return_value
End




Function subtract_number(original, number)

wave original
string number

variable subtract=str2num(number)

subtract = wavemin(original)

string newwavename=nameofwave(original)+"_s"

duplicate/O original,$newwavename

wave newwave=$newwavename

newwave=original(x)-subtract

end



Function get_dip(sub_edc,efrom_eto)
wave sub_edc
string efrom_eto
variable efrom=str2num(stringfromlist(0,efrom_eto,","))
variable eto=str2num(stringfromlist(1,efrom_eto,","))


duplicate/o sub_edc edc_temp
edc_temp=(sub_edc[p]>0)?0:(sub_edc)

return -area(edc_temp,min(efrom,eto),max(efrom,eto))

end
//=================================
Function linear_fit(dispersion,return_coef_index)
//linear fit, k0+k1*x
//coef_index: 0 for k0, 1 for k1, 2 for k0 error, 3 for k1 error
wave dispersion

string return_coef_index
variable index=str2num(return_coef_index)
Curvefit/N/Q line,dispersion(-0.02,0.02)/D
wave w_coef
wave w_sigma
if(index<1.5)
return w_coef[index]
else
return w_sigma[index-2]
endif

end

Function name_index(dispersion, placeholder)
wave dispersion
string placeholder
string disp_name=nameofwave(dispersion)
variable num=str2num(disp_name[16,18])

return num
end

Function norm_fwhm(fwhm, name_slope_error_angle)
wave fwhm
string name_slope_error_angle

wave name_wave=$(stringfromlist(0,name_slope_error_angle,","))
wave slope_wave=$(stringfromlist(1,name_slope_error_angle,","))
wave error_wave=$(stringfromlist(2,name_slope_error_angle,","))
//wave angle_wave=$(stringfromlist(3,name_slope_error_angle,","))


string fwhm_name=nameofwave(fwhm)
variable specindex=str2num(fwhm_name[16,18])

variable index
for(index=0;index<dimsize(name_wave,0);index+=1)
if(name_Wave[index]==specindex)
print num2str(specindex)+" Found\r"
break
endif
endfor

variable slope=slope_wave[index]
variable error=error_wave[index]
//variable angle=angle_wave[index]

string norm_fwhm_name=fwhm_name+"_norm"//+num2str(round(angle))
string norm_fwhm_error_name=norm_fwhm_name+"_error"

duplicate/O fwhm $norm_fwhm_name
duplicate/O $(fwhm_name+"_error") $norm_fwhm_error_name
wave fwhm_error=$(fwhm_name+"_error") 

wave norm_fwhm=$norm_fwhm_name
wave norm_fwhm_error=$norm_fwhm_error_name

norm_fwhm=fwhm[p]/abs(slope)

norm_fwhm_error=0.5*abs((abs(fwhm[p])+abs(fwhm_error[p]))/(abs(slope)-abs(error))-(abs(fwhm[p])-abs(fwhm_error[p]))/(abs(slope)+abs(error)))

end

Function devide_number(fwhm, numberstring)
wave fwhm
string numberstring

variable num=str2num(numberstring)
string newwavename=nameofwave(fwhm)+"n"

duplicate/O fwhm $newwavename

wave newwave=$newwavename

newwave=fwhm[p]/num
end


Function devide_dedk(FWHM, bandbottom)
wave FWHM
string bandbottom

variable bb=str2num(bandbottom)

duplicate/o FWHM $(nameofwave(FWHM)+"_norm")
wave FWHM_norm=$(nameofwave(FWHM)+"_norm")
FWHM_norm*=sqrt(bb+x)

end

function Move_gold(spectrum,pl)
//universial_batch("naw,move_gold,pl")
//this function moves gold to the gold folder, and change gold temperature to cryo temperature.
	wave spectrum
	string pl
	
	string spectrum_name = nameofwave(spectrum)
	string note_string=note(spectrum)
	variable z_position=numberbykey("Z_Manipulator",note_string,"=","\r")
	if (z_position>17000)
		string LeftNotes = stringbykey("LeftNotes",note_string,"=","\r")
		variable temperature = numberbykey("CryoTemperature",LeftNotes,"=",";")
		if(numtype(temperature)!=2)
			string newnotestring = ReplaceStringByKey("SampleTemperature", note_string, num2str(temperature), "=", "\r")
			note/K spectrum, newnotestring
		endif
		duplicate/o spectrum $("root:gold:"+spectrum_name)
		killwaves/Z spectrum
	endif
End

function AdjustTemperature(spec,pl)
//universial_batch("naw,AdjustTemperature,pl")
	wave spec
	string pl
	
	string notestr = note(spec)
	string temperature = Stringbykey("SampleTemperature",notestr,"=","\r")
	variable len = strlen(temperature)
	variable newtemperature= str2num(replacestring("K",temperature,""))-1
	string new_notestr = ReplaceStringByKey("SampleTemperature",notestr,num2str(newtemperature)+"K","=","\r")
	note/K spec, new_notestr
end
	
function/wave get_edc(spectrum, kfrom_kto)
	wave spectrum
	string kfrom_kto
	
	
	variable k1=str2num(stringfromlist(0,kfrom_kto,","))
	variable k2=str2num(stringfromlist(1,kfrom_kto,","))
	
	string edc_name=nameofwave(spectrum)+"_edc"
	
	string notestr="EDC within " +kfrom_kto + "\r" + note(spectrum)
	
	make/o/n=(dimsize(spectrum,1)) $edc_name
	wave edc=$edc_name
	setscale/P x,dimoffset(spectrum,1),dimdelta(spectrum,1),edc
	make/o/n=(dimsize(spectrum,0)) MDC_temp
	setscale/P x, dimoffset(spectrum,0),dimdelta(spectrum,0),MDC_temp
	variable index
	for(index=0;index<numpnts(edc);index+=1)
		mDC_temp=spectrum[p][index]
		edc[index]=area(MDC_temp,k1,k2)
		mDC_temp=1
		edc[index]/=area(MDC_temp,k1,k2)
	endfor
	
	note/K edc, notestr
	
	killwaves/Z MDC_temp
	return edc
end




function get_edc0(spectrum, kfrom_kto)
	wave spectrum
	string kfrom_kto
	
	
	variable k1=str2num(stringfromlist(0,kfrom_kto,","))
	variable k2=str2num(stringfromlist(1,kfrom_kto,","))
	
	string edc_name=nameofwave(spectrum)+"_edc"
	
	string notestr="EDC within " +kfrom_kto + "\r" + note(spectrum)
	
	make/o/n=(dimsize(spectrum,1)) $edc_name
	wave edc=$edc_name
	setscale/P x,dimoffset(spectrum,1),dimdelta(spectrum,1),edc
	make/o/n=(dimsize(spectrum,0)) MDC_temp
	setscale/P x, dimoffset(spectrum,0),dimdelta(spectrum,0),MDC_temp
	variable index
	for(index=0;index<numpnts(edc);index+=1)
		mDC_temp=spectrum[p][index]
		edc[index]=area(MDC_temp,k1,k2)
		mDC_temp=1
		edc[index]/=area(MDC_temp,k1,k2)
	endfor
	
	note/K edc, notestr
	
	killwaves/Z MDC_temp
end




function/wave get_mdc(spectrum, efrom_eto)
	wave spectrum
	string efrom_eto
	
	
	variable e1=str2num(stringfromlist(0,efrom_eto,","))
	variable e2=str2num(stringfromlist(1,efrom_eto,","))
	
	string mdc_name=nameofwave(spectrum)+"_mdc"
	
	string notestr="MDC within " +efrom_eto + "\r" + note(spectrum)
	
	make/o/n=(dimsize(spectrum,0)) $mdc_name
	wave mdc=$mdc_name
	setscale/P x,dimoffset(spectrum,0),dimdelta(spectrum,0),mdc
	make/o/n=(dimsize(spectrum,1)) EDC_temp
	setscale/P x, dimoffset(spectrum,1),dimdelta(spectrum,1),EDC_temp
	variable index
	for(index=0;index<numpnts(mdc);index+=1)
		EDC_temp=spectrum[index][p]
		mdc[index]=area(EDC_temp,e1,e2)
		EDC_temp=1
		mdc[index]/=area(EDC_temp,e1,e2)
	endfor
	
	note mdc, notestr
	
	killwaves/Z EDC_temp
	return mdc
end




function get_mdc0(spectrum, efrom_eto)
	wave spectrum
	string efrom_eto
	
	
	variable e1=str2num(stringfromlist(0,efrom_eto,","))
	variable e2=str2num(stringfromlist(1,efrom_eto,","))
	
	string mdc_name=nameofwave(spectrum)+"_mdc"
	
	string notestr="MDC within " +efrom_eto + "\r" + note(spectrum)
	
	make/o/n=(dimsize(spectrum,0)) $mdc_name
	wave mdc=$mdc_name
	setscale/P x,dimoffset(spectrum,0),dimdelta(spectrum,0),mdc
	make/o/n=(dimsize(spectrum,1)) EDC_temp
	setscale/P x, dimoffset(spectrum,1),dimdelta(spectrum,1),EDC_temp
	variable index
	for(index=0;index<numpnts(mdc);index+=1)
		EDC_temp=spectrum[index][p]
		mdc[index]=area(EDC_temp,e1,e2)
		EDC_temp=1
		mdc[index]/=area(EDC_temp,e1,e2)
	endfor
	
	note mdc, notestr
	
	killwaves/Z EDC_temp
end


function map_symmetrize(map)
	wave map
	variable a=3.85
	
	
	string name=nameofwave(map)
	variable bz_size=pi/a
	
	variable pixelsize=dimdelta(map,0)/2
	
	variable pixels=round(bz_size*2/pixelsize)
	
	make/o/n=(pixels,pixels) $(name+"_sym")
	
	wave newmap=$(name+"_sym")
	
	setscale/I x, -bz_size,bz_size,newmap
	setscale/I y, -bz_size,bz_size,newmap
	
	newmap=(abs(x)>abs(y))? interp2D(map,-abs(x),-abs(y)): interp2D(map,-abs(y),-abs(x))
	
	newmap=(numtype(newmap[p][q])==2)? 0:newmap[p][q]
//	duplicate/o newmap, temp_map
//	
//	setscale/I x, 0,2*bz_size,temp_map
//	setscale/I y, 0,2*bz_size,temp_map
//	
//
//	
//	newmap=interp2D(temp_map,abs(x),abs(y))
//	killwaves/Z temp_map
end

duplicate/R=(0,inf)(-inf,inf) root:graphsave:Images:IMG_0:OD81_dev_sym;root:graphsave:Images:IMG_0:OD81_dev_sym_r


//===============

Universial_batch("NAW,devide_number,0.62632")

universial_batch("NN_name_L,name_index,pl;NN_offset_L,linear_fit,0;NN_slope_L,linear_fit,1;NN_offset_L_error,linear_fit,2;NN_slope_L_error,linear_fit,3")
universial_batch("name,name_index,pl;offset,linear_fit,0;slope,linear_fit,1;offset_error,linear_fit,2;slope_error,linear_fit,3")

universial_batch("NN_name_R,name_index,pl;NN_offset_R,linear_fit,0;NN_slope_R,linear_fit,1;NN_offset_R_error,linear_fit,2;NN_slope_R_error,linear_fit,3")


universial_batch("AN_name_R,name_index,pl;AN_offset_R,linear_fit,0;AN_slope_R,linear_fit,1;AN_offset_R_error,linear_fit,2;AN_slope_R_error,linear_fit,3")


universial_batch("NAW,norm_fwhm,root:NN_R_position_101_281K:NN_name_R,root:NN_R_position_101_281K:NN_slope_R,root:NN_R_position_101_281K:NN_slope_R_error")



universial_batch("NAW,norm_fwhm,root:AN_Position_111_311:AN_name_L,root:AN_Position_111_311:AN_slope_L,root:AN_Position_111_311:AN_slope_L_error")

universial_batch("NAW,norm_fwhm,root:OD90_AN_dispersion_R_159_228:AN_name_R,root:OD90_AN_dispersion_R_159_228:AN_slope_R,root:OD90_AN_dispersion_R_159_228:AN_slope_R_error")



universial_batch("tem,Get_info,sampletemperature;SW_Ef,Averaged_Intensity,-0.020,0.020,-inf,inf;SW_all,Averaged_Intensity,-0.25,0,-inf,inf")


universial_batch("NaW,mdc_fit_lorentzian,-0.02,0.02,para")

NN_kx_L=Angle2Momentum(-10.989-0.4,1,-7.1, NN_offset_L[p],0,16.88,1)
NN_ky_L=Angle2Momentum(-10.989-0.4,1,-7.1, NN_offset_L[p],0,16.88,2)

NN_angle_wrt_bz_boundary=atan(0.805537-abs(NN_kx_L[p]))/(0.805537-abs(NN_ky_L[p]))*180/pi


ModifyGraph gFont="Helvetica"
ModifyGraph tick(left)=3,mirror=2,nticks(left)=0,btLen(bottom)=2;DelayUpdate
Label bottom "k\\By\\M (1/Å)"

//=========================================================================================

Function lorentz_x1(pw,yw,xw): FitFunc
	Wave pw,yw,xw
	// wave parameters:
	//0: peak_position_L
	//1: peak_height_L
	//2: peak_width_L
	//3: constant_bkg
	yw=pw[1]*(pw[2]^2/4) / ((xw-pw[0])^2+pw[2]^2/4)
	yw+=pw[3]
end


Function lorentz_x2(pw,yw,xw): FitFunc
	Wave pw,yw,xw
	// wave parameters:
	//0: peak_position_L
	//1: peak_height_L
	//2: peak_width_L
	//3: peak_position_R
	//4: peak_height_R
	//5: peak_width_R
	//6: constant_bkg
	yw=pw[1]*(pw[2]^2/4) / ((xw-pw[0])^2+pw[2]^2/4)
	yw+=pw[4]*(pw[5]^2/4) / ((xw-pw[3])^2+pw[5]^2/4)
	yw+=pw[6]
end

Function initialize_lorentz_x2_fit()
make/o/n=7 para={-0.062,10.85,0.148125,0.062,18,0.152981,0}
end






function FWHM_plot()
SetAxis bottom -0.05,0.02
color_gradient_plot("geo",0.9,0,1,0)
ModifyGraph gFont="Helvetica"
ModifyGraph zero(bottom)=1,mirror=2,btLen=2,stLen=2;DelayUpdate
//Label left "AN MDC FWHM (1/Å)";DelayUpdate
Label left "MDC FWHM · V\\BF\\M (eV)"
Label bottom "E - E\\BF\\M (meV)"
Label bottom "\\u#2E - E\\BF\\M (meV)"
end



 Angle2Momentum(angle_theta[p]+0.4,-2.2,-3.5,angle_beta[p],0,16.6825,1)



 Angle2Momentum(angle_theta[p]-1.1,-20+1.8,-4.5,angle_beta[p],0,14.077+disp[p],1)
 duplicate disp_12, theta_12
duplicate disp_14, theta_14
•duplicate disp_6, theta_6
•duplicate disp_8, theta_8
•duplicate disp_10, theta_10
•duplicate disp_16, theta_16
•duplicate disp_18, theta_18
•duplicate disp1, theta1
theta_12=-12
•root:TB_fit_test1:theta_14=-14
•root:TB_fit_test1:theta_6=-6
•root:TB_fit_test1:theta_8=-8
•root:TB_fit_test1:theta_10=-10
•root:TB_fit_test1:theta_16=-16
•root:TB_fit_test1:theta_18=-18
•root:TB_fit_test1:theta1=1

Concatenate/NP  {theta1,theta_6,theta_8,theta_10,theta_12,theta_14,theta_16,theta_18}, angle_theta
•Concatenate/NP  {disp1,disp_6,disp_8,disp_10,disp_12,disp_14,disp_16,disp_18}, disp
•Concatenate/NP  {momentum1,momentum_6,momentum_8,momentum_10,momentum_12,momentum_14,momentum_16,momentum_18}, angle_beta
•duplicate/o angle_theta,kx,ky
• kx=Angle2Momentum(angle_theta[p]-1.1,-20+1.8,-4.5,angle_beta[p],0,14.077+disp[p],1)
• ky=Angle2Momentum(angle_theta[p]-1.1,-20+1.8,-4.5,angle_beta[p],0,14.077+disp[p],2)
•duplicate/o kx, kx2,ky2
•kx2=(kx+ky)/sqrt(2)
•ky2=(kx-ky)/sqrt(2)
•Display ky vs kx

kx2/=0.818123
ky2/=0.818123



duplicate/o disp, disp_fit
disp_fit= tb_sc(para,kx,ky)


Concatenate/NP  {theta_T23,theta_T22,theta_T20,theta_T19,theta_T17,theta_T16,theta_T14,theta_T13,theta_T11,theta_T10}, angle_theta
Concatenate/NP  {phi_T23,phi_T22,phi_T20,phi_T19,phi_T17,phi_T16,phi_T14,phi_T13,phi_T11,phi_T10}, angle_phi
Concatenate/NP {disp_T23,disp_T22,disp_T20,disp_T19,disp_T17,disp_T16,disp_T14,disp_T13,disp_T11,disp_T10}, disp

disp_fit= tb_normal(tb_para,kx,ky)

make/o/n=4 tb_para={0.16553,-0.041399,0.008216,-0.18166}


make/o/n=(401,401) tb_band

setscale/I x, -2,2,tb_band
setscale/I y, -2, 2, tb_band
tb_band=tb_normal(tb_para,x,y)



Function Angle2Momentum(theta,phi,azi,be_ta,ga_mma,energy,kxkykz)
//ga_mma=0 for SSRL and ALS setup
//return kx for kxkykz=1,ky for kxkykz=2, kz for kxkykz=3

variable theta,phi,azi,be_ta,ga_mma,energy
variable kxkykz

variable kvac=0.51231675*sqrt(energy)

theta*=pi/180
phi*=pi/180
azi*=pi/180
be_ta*=pi/180
ga_mma*=pi/180
make/o/n=(3,3) R1,R2,R3
make/o/n=(3,1) S_angle

R1[0][] = {{cos(azi)},{sin(azi)},{0}}
R1[1][]={{-sin(azi)},{cos(azi)},{0}}
R1[2][] ={{0},{0},{1}} 
	
R2[0][]= { {1},{0},{0}}
R2[1][]={{0},{cos(phi)},{sin(phi)}}
R2[2][]={{0},{-sin(phi)},{cos(phi)} }
	 
R3[0][]= { {cos(theta)},{0},{sin(theta)}}
R3[1][]={{0},{1},{0}}
R3[2][]={{-sin(theta)},{0},{cos(theta)} }
	
S_angle[][0]={sin(be_ta)*sin(ga_mma),sin(be_ta)*cos(ga_mma),cos(be_ta)}

MatrixMultiply R1,R2,R3,s_angle

wave M_product

make/o/n=3 Momentum

Momentum[]=M_product[p][0]*kvac
return Momentum[kxkykz-1]

End




//function dup_wave(prefix)
//string prefix
//wave tem
//wave SW_0_5
//wave SW_0_5_DIF
//duplicate tem $("root:Summary_For_Yu:DSW_DT_curves:"+prefix+"_tem")
//duplicate SW_0_5 $("root:Summary_For_Yu:DSW_DT_curves:"+prefix+"_SW_0_5")
//duplicate SW_0_5_DIF $("root:Summary_For_Yu:DSW_DT_curves:"+prefix+"_SW_0_5_DIF")
//end
//==================================
Function add_error_bar()

string tracelist=TraceNameList("", ";", 1)
variable index
variable num=itemsinlist( tracelist)
string trace,trace_error

for(index=0;index<num;index+=1)
	trace=StringFromList(index, tracelist)
	trace_error=trace+"_error"
	ErrorBars/T=0 $trace Y,wave=($trace_error,$trace_error)
endfor
end


Function color_gradient_plot(colortable_name,start_index,end_index, skip, loop)
//this function change the color of a plot using the given color table
//start and end index are between 0 and 1.
//color_gradient_plot("geo",0,0.8,0,14)
//color_gradient_plot("rainbow",0,1)
string colortable_name
variable start_index
variable end_index
variable skip//number of same-colored neighbour curves
variable loop
colortab2wave $colortable_name
wave M_colors

start_index*=dimsize(M_colors,0)
end_index*=dimsize(M_colors,0)

if(start_index>dimsize(M_colors,0)-1)
start_index=dimsize(M_colors,0)-1
endif

if(end_index>dimsize(M_colors,0)-1)
end_index=dimsize(M_colors,0)-1
endif

variable r,g,b,rgbindex
string tracelist=TraceNameList("", ";", 1)
variable index
variable num=itemsinlist( tracelist)
string trace

for(index=0;index<num;index+=1)
	if(mod(index, skip)==0)
		if(loop==0)
			rgbindex=round(start_index+index*(end_index-start_index)/(num-1))
		else
			rgbindex=round(start_index+mod(index, loop)*(end_index-start_index)/(loop-1))
		endif
	endif
	r=M_colors[rgbindex][0]
	g=M_colors[rgbindex][1]
	b=M_colors[rgbindex][2]
	trace=StringFromList(index, tracelist)
	modifygraph rgb($trace)=(r,g,b)
endfor
killwaves/Z M_colors
end

Function color_gradient_plot_sub(colortable_name,start_index,end_index, from,to)
//this function change the color of a plot using the given color table
//start and end index are between 0 and 1.
//change the fromth to the toth item on graph
string colortable_name
variable start_index
variable end_index
variable from
variable to
variable skip=1//number of same-colored neighbour curves
variable loopo=0
colortab2wave $colortable_name
wave M_colors

start_index*=dimsize(M_colors,0)
end_index*=dimsize(M_colors,0)

if(start_index>dimsize(M_colors,0)-1)
start_index=dimsize(M_colors,0)-1
endif

if(end_index>dimsize(M_colors,0)-1)
end_index=dimsize(M_colors,0)-1
endif

variable r,g,b,rgbindex
string tracelist=TraceNameList("", ";", 1)
variable index
variable num=itemsinlist( tracelist)
string trace

for(index=from-1;index<to;index+=1)
	if(mod(index, skip)==0)
		if(loopo==0)
			rgbindex=round(start_index+index*(end_index-start_index)/(num-1))
		else
			rgbindex=round(start_index+mod(index, loopo)*(end_index-start_index)/(loopo-1))
		endif
	endif
	r=M_colors[rgbindex][0]
	g=M_colors[rgbindex][1]
	b=M_colors[rgbindex][2]
	trace=StringFromList(index, tracelist)
	modifygraph rgb($trace)=(r,g,b)
endfor
killwaves/Z M_colors
end




function quick_plot(bulk,dif,sample)
variable bulk, dif
string sample

string Tc_bulk_name=sample+"_Tc_bulk"
string Tc_dif_name=sample+"_Tc_DIF"

make/o/n=2 $(Tc_bulk_name)
make/o/n=2 $(Tc_dif_name)

wave Tc_bulk=$(Tc_bulk_name)
wave Tc_dif=$(Tc_dif_name)

setscale/I x,-10,10,Tc_bulk,Tc_dif

Tc_bulk=bulk
Tc_dif=dif

string difwavename=sample+"_SW_0_5_DIF"
string swwavename=sample+"_SW_0_5"
string twavename=sample+"_tem"


wave difwave=$difwavename
wave swwave=$swwavename
wave twave=$twavename

Display difwave vs twave
AppendToGraph/R swwave vs twave
AppendToGraph/R/VERT Tc_bulk,Tc_dif
ModifyGraph btLen=2,stLen=2
SetAxis left 0,(1.05*wavemax(difwave))
SetAxis right 0,(1.05*wavemax(swwave));doupdate
ModifyGraph rgb($difwavename)=(65535,0,0)
ModifyGraph rgb($swwavename)=(21845,21845,21845)
ModifyGraph rgb($Tc_bulk_name)=(21845,21845,21845),lstyle($Tc_dif_name)=8,lstyle($Tc_bulk_name)=2;
ModifyGraph rgb($Tc_dif_name)=(65535,0,0)
ModifyGraph lsize($difwavename)=2,lsize($Tc_dif_name)=2

Label left "\\K(65535,0,0)dSW[0, 5meV]/dT"
Label bottom "Temperature (K)"
Label right "SW[0, 5meV]"
TextBox/C/N=text0/F=0/A=RC/X=56/Y=40 (sample+"\rOD"+num2str(bulk)+" Yu")

ModifyGraph mirror(bottom)=2
ModifyGraph width=108,height=108
ModifyGraph lblMargin(left)=18
ModifyGraph lstyle($Tc_dif_name)=7

end


function quick_batch(angle)
	string angle
	make/o/n=400 tem, SW_0_5, SW_0_70
	tem=NaN
	SW_0_5=NaN
	SW_0_70=NaN
	universial_batch("tem,Get_info,sampletemperature;SW_0_5,Averaged_Intensity,-0.005,0,-inf,inf;SW_0_70,Averaged_Intensity,-0.070,0,-inf,inf")
	Differentiate SW_0_5/X=tem/D=SW_0_5_DIF
	//Display SW_0_5_DIF vs tem
	wave SW_0_5
	wave SW_0_70
	wave tem
	wave SW_0_5_DIF
	rename SW_0_5 $(angle+"_SW_0_5")
	rename SW_0_70 $(angle+"_SW_0_70")
	rename tem $(angle+"_tem")
	rename SW_0_5_DIF $(angle+"_SW_0_5_DIF")
end

function norm_plot(x1,x2)
	variable x1,x2
	variable index
	string name
	do
		wave curve=waverefindexed("",index,1)
		name=nameofwave(curve)
		variable max_value=wavemax(curve,x1,x2)
		variable mul=1/max_value
		ModifyGraph muloffset($name)={0,mul}
		index+=1
	while(strlen(nameofwave(waverefindexed("",index,1))))
end

function norm_image(image, pl)
	wave image
	string pl
	//settings:
	variable E_from = -0.25
	variable E_to = -0.2
	variable k_from = -0.3
	variable k_to = 0.3
	//endsettings
	
	imagestats/GS={k_from,k_to, E_from, E_to} image
	image /=V_avg
end


function crop_image_sdc(image, pl)
	wave image
	string pl
	//settings:
	variable E_from = -0.25
	variable E_to = 0.03
	variable k_from = -0.4
	variable k_to = 0.4
	//endsettings
	
	string name=nameofwave(image)
	duplicate/o/R=(k_from,k_to)(e_from,e_to) image, $(name+"_crop")
	
	
	
	
	imagestats/GS={k_from,k_to, E_from, E_to} image
	
	print 2.8*v_avg
end


function symk_image_sdc(image,pl)
	wave image
	string pl
	
	
	string name=nameofwave(image)
	duplicate/o image, $(name+"_symk")
	wave new_image= $(name+"_symk")
	
	variable kfrom=dimoffset(image,0)
	variable kto = dim_to(image,0)
	
	variable klimit = min(abs(kfrom),abs(kto))
	
	
	
	new_image = (abs(x)<klimit)?((image(x)(y)+image(-x)(y))/2):NaN
	nan_crop(new_image,"20")

end

function dim_to(image,dimindex)
	wave image
	variable dimindex
	
	return dimoffset(image,dimindex)+dimdelta(image,dimindex)*(dimsize(image,dimindex)-1)
end

function find_intensity(image, pl)
	wave image
	string pl
	//settings:
	variable E_from = -0.070
	variable E_to = 0.0
	variable k_from = -0.4
	variable k_to = 0.4
	//endsettings
	
	imagestats/GS={k_from,k_to, E_from, E_to} image
	return V_avg
end








ModifyGraph offset(T01_SW_0_5_DIF)={0,1}


quick_batch("T2")

	universial_batch("NaW,rename_wave,OP98_;")
	universial_batch("NaW,FD_regulator,2")
	
	Tc=96*[1-82.6*(p-0.16)^2]
	
	doping_ddt_sdc=sqrt((1-(Tc_ddt_sdc/94.7449))/82.6)
	
	//NaW,intensity_normalization,-0.20,0,-inf,inf;
	
	
	ModifyGraph muloffset(T16_SW_0_5)={0,1}
	
	
	string tracelist=Tracenamelist("graph0",";","0")
	
	
	

Function sort_by_t()
	String gname=winname(0,1)
	String List,Trace1N,Trace2N

	list = TraceNameList(gname, ";",1)

	Variable items=ItemsInList(List,";")//number of traces
	Variable index=0
	//get temperature
	make/o/n=(items) temperatures
	make/o/T/n=(items) wavenames
	string tracename
	
	for(index=0;index<items;index+=1)
		tracename = stringfromlist(index, list, ";")
		wave trace = traceNametoWaveRef(gname, tracename)
		temperatures[index]=Get_Info(trace,"SampleTemperature")
		wavenames[index]=tracename
	endfor
	
	Sort temperatures, wavenames
	string trace1, trace2
	trace1=wavenames[0]
	for(index=1;index<items;index+=1)
		trace2 =wavenames[index]
		ReorderTraces/W=$gname $trace1,{$trace1,$trace2}
		trace1 = trace2
	endfor
	killwaves/Z temperatures, wavenames
End

Function sort_by_name()
	String gname=winname(0,1)
	String List,Trace1N,Trace2N

	list = TraceNameList(gname, ";",1)

	Variable items=ItemsInList(List,";")//number of traces
	Variable index=0
	//get temperature
	make/o/n=(items) temperatures
	make/o/T/n=(items) wavenames
	string tracename
	
	for(index=0;index<items;index+=1)
		tracename = stringfromlist(index, list, ";")
		wave trace = traceNametoWaveRef(gname, tracename)
		temperatures[index]=Get_Info(trace,"SampleTemperature")
		wavenames[index]=tracename
	endfor
	
	Sort/A wavenames, wavenames
	string trace1, trace2
	trace1=wavenames[0]
	for(index=1;index<items;index+=1)
		trace2 =wavenames[index]
		ReorderTraces/W=$gname $trace1,{$trace1,$trace2}
		trace1 = trace2
	endfor
	killwaves/Z temperatures, wavenames
End
	
function Tc2Doping(Tc)
	variable Tc
	variable doping = 0.16 + sqrt((1-Tc/98)/82.6)
	print doping
	return doping
end


	
function T2p(T)
	variable T
	if(T>91)
		T=91
	endif
	variable doping = 0.16 + sqrt((1-T/91)/82.6)
	//print doping
	return doping
end







function Doping2tc(doping)
	variable doping
	variable tc = 91*(1-82.6*(doping-0.16)^2)
	if(tc<0)
		tc=nan
	endif
	return tc
end

function YBCO_Doping2tc(doping)
	variable doping
	variable tc = 95*(1-82.6*(doping-0.16)^2)
	if(tc<0)
		tc=nan
	endif
	return tc
end

function geo()
	color_gradient_plot("geo",0.1,0.9,1,0)
end

function geo2()
	color_gradient_plot("geo",0.1,0.9,2,0)
end

function geoloop(loop)
	variable loop
	color_gradient_plot("geo",0.1,0.9,1,loop)
end

function offset1(offset_value)
	variable offset_value
	offset_plot(offset_value, 1,500)
end


function offset2(offset_value)
	variable offset_value
	offset_plot(offset_value, 2,500)
end

function/S cropname(name)
	string name
	if(strlen(name)>31)
		return name[0,30]
	else
		return name
	endif
end


function clean_name(spectrum,pl)
//universial_batch("NAW,clean_name,pl")
	wave spectrum
	string pl
	//settings:
	variable plen = 0 //length of prefix
	variable slen = 16//length of surfix
	//endsettings
	string name  = nameofwave(spectrum)
	variable namelen = strlen(name)
	
	string newname = name[plen, namelen -slen-1]
	rename spectrum $newname
end



function offset_plot(offset_value, skip,loop)
	variable offset_value
	variable skip
	variable loop
	variable index
	string name
	variable offset = 0
	do
		wave curve=waverefindexed("",index,1)
		name=nameofwave(curve)
		if(mod(index, skip)==0)
			offset=mod(index,loop)*offset_value/skip
		endif
		ModifyGraph offset($name)={0,offset}
		index+=1
	while(strlen(nameofwave(waverefindexed("",index,1))))
end

function conv_reso(edc, resolution_str)
	wave edc
	string resolution_str
	
	variable resolution = str2num(resolution_str)
	
	variable delta = dimdelta(edc,0)
	variable reso_half_length = round(5*resolution/delta)
	
	make/o/n=(2*reso_half_length+1) resowave_temp
	setscale/P x,-reso_half_length*delta, delta, resowave_temp
	
	resowave_temp= Gauss(x, 0, resolution/(2*(sqrt(2*ln(2))))
	
	variable nor= sum(resowave_temp)
	
	resowave_temp/=nor
	
	convolve/A resowave_temp, edc
end

function FD(w,T)
	variable w, T
	
	variable kb = 8.61733034e-5
	
	return 1/(1+exp(w/(kb*T)))
end

function FD_divide(edc, resolution_str)
	wave edc
	string resolution_str
	
	variable resolution = str2num(resolution_str)
	variable temperature = get_info(edc, "SampleTemperature")
	
	
	variable fdfrom = dimoffset(edc,0) - resolution*10
	variable fdto = dimoffset(edc,0)+dimdelta(edc,0)*dimsize(edc,0) +resolution*10
	variable fd_size = round((fdto-fdfrom)/dimdelta(edc,0))
	
	make/o/n=(fd_size) fd_temp
	setscale/P x, fdfrom, dimdelta(edc,0), fd_temp
	fd_temp = FD(x,temperature)
	conv_reso(fd_temp, resolution_str)
	fd_temp = (fd_temp[p]>1e-3)?fd_temp[p]:NaN
	
	
	
	string newedcname = cropname("FD"+nameofwave(edc))
	duplicate/o edc,$newedcname
	wave newedc = $newedcname
	newedc = edc(x)/fd_temp(x)
end

function divide_wave(edc, divide_path)
	wave edc
	string divide_path
	
	wave divide = $divide_path
	
	variable xfrom = dimoffset(divide,0)
	variable xto = dimoffset(divide,0) + dimdelta(divide,0)*dimsize(divide,0)
	
	edc = ((x>=xfrom)&&(x<=xto))? (edc(x)/divide(x)) : NAN
end

function divide_prev_wave()
	variable index=0
	string newwavename
	string dvd_wavepath
	do
		wave target=$(getbrowserselection(index))
		dvd_wavepath=getbrowserselection(index+1)
		if(strlen(dvd_wavepath)==0)
			break
		endif
		newwavename=nameofwave(target)+"_dnext"
		duplicate/o target, $newwavename
		wave newwave=$newwavename
		divide_wave(newwave, dvd_wavepath)
		index+=1
	while(1)	
end

function subtract_wave(edc, s_path)
	wave edc
	string s_path
	
	wave divide = $s_path
	
	variable xfrom = dimoffset(divide,0)
	variable xto = dimoffset(divide,0) + dimdelta(divide,0)*dimsize(divide,0)
	
	edc = ((x>=xfrom)&&(x<=xto))? (edc(x)-divide(x)) : NAN
end




function subtract_image(image,subtract_path)
	wave image
	string subtract_path
	
	wave sub = $subtract_path
	
	variable xfrom = dimoffset(sub,0)
	variable xto = dimoffset(sub,0) + dimdelta(sub,0)*dimsize(sub,0)
	
	variable yfrom = dimoffset(sub,1)
	variable yto = dimoffset(sub,1) + dimdelta(sub,1)*dimsize(sub,1)
	
	string imagename=nameofwave(image)
	
	duplicate/o image, $(imagename+"_sub")
	
	wave simage=$(imagename+"_sub")
	string note2= "subtracted by "+subtract_path+"\r"+note(image)
	
	Note/K simage,note2	
	
	simage = (((x>xfrom)&&(x<xto))&&((y>yfrom)&&(y<yto)))? (image(x)(y)-sub(x)(y)) : NAN
end

function mg()
	ub("NAW,move_gold,pl")
end

function ub(list)
	string list
	universial_batch(list)
end

function nan_crop(image, empty_edc)
// this function crop away all the NaNs on the edge of an image, while keeping the x and y scale.
//ub("naw,nan_crop,20")
	wave image
	string empty_edc
	
	variable empty_edc_num = str2num(empty_edc)
	
	variable deltak = dimdelta(image,0)
	variable deltaE = dimdelta(image, 1)
	
	variable kfrom = dimoffset(image,0)
	variable efrom = dimoffset(image, 1)
	
	variable kstart = dimoffset(image,0)
	variable estart = dimoffset(image, 1)
	
	variable new_start_e, new_end_e, new_start_k, new_end_k
	variable index
	
	for(index=0;index<dimsize(image,1);index+=1)
		if((nan_in_row(image,index,"num")==0)&&(nan_in_row(image,index,"first")< empty_edc_num))
			new_start_e = index
			break
		endif
	endfor
		
	for(index=dimsize(image,1)-1;index>-1;index-=1)
		if(nan_in_row(image,index,"num")==0)
			new_end_e = index
			break
		endif
	endfor
	
	new_start_k = max(nan_in_row(image, new_start_e, "first"),nan_in_row(image, new_end_e, "first"))
	new_end_k = min(nan_in_row(image, new_start_e, "last"),nan_in_row(image, new_end_e, "last"))
	
	//delete edcs
	deletepoints/M=0	0, new_start_k, image
	deletepoints/M=0	new_end_k-new_start_k+1, inf, image
	setscale/P x, kfrom+deltak*new_start_k, deltak, image
	
	//delete mdcs
	deletepoints/M=1	0, new_start_e, image
	deletepoints/M=1	new_end_e-new_start_e+1, inf, image
	setscale/P y, efrom+deltaE*new_start_e, deltaE, image

end

function nan_in_row(image, rownum, output)
	wave image
	variable rownum
	string output
	variable index=0

	variable first_number_index=NaN
	variable last_number_index=NaN
	variable nan_in_between=0
	
	for(index=0;index<dimsize(image,0);index+=1)
		if(numtype(image[index][rownum])!=2)
			first_number_index = index
			break
		endif
	endfor
	
	for(index=dimsize(image,0)-1;index>-1;index-=1)
		if(numtype(image[index][rownum])!=2)
			last_number_index = index
			break
		endif
	endfor
	
	if(numtype(first_number_index)!=2)
		for(index=first_number_index;index<last_number_index;index+=1)
			if(numtype(image[index][rownum])==2)
				nan_in_between +=1
			endif
		endfor
	else
		nan_in_between = dimsize(image,0)
	endif
	
	if(stringmatch(output, "first"))
		return first_number_index
	elseif(stringmatch(output,"last"))
		return last_number_index
	else
		return nan_in_between
	endif
end

function get_image_stats(image,pl)
	wave image
	string pl
	//settings
	variable xmin = -0.4
	variable xmax = 0.4
	variable ymin = -0.25
	variable ymax = 0.05
	//endsettings
	imagestats/GS={xmin, xmax, ymin, ymax} image
	return V_sdev/V_avg
end



function get_area(edc, efrom_eto)
	wave edc
	string efrom_eto
	
	
	variable efrom=str2num(stringfromlist(0,Efrom_Eto,","))
	variable eto=str2num(stringfromlist(1,Efrom_Eto,","))
	

	//settings:
	variable bkg = 0
	//endsettings
	
	duplicate/o edc, temp_edc
	temp_edc-=bkg
	return area(temp_edc, efrom, eto)
end

function get_stat(edc, pl)
	wave edc
	string pl
	

	//settings:
	variable efrom = -0.2
	variable eto = 0
	variable bkg = 0
	//endsettings
	
	wavestats/Q/R=(efrom,eto) edc
	return V_sdev/V_avg//edit return here
	
end




function norm_by_area(edc, pl)
	wave edc
	string pl
	

	//settings:
	variable efrom = -0.25
	variable eto =-0.2
	//endsettings
	
	variable div =  faverage(edc, efrom, eto)
	edc/=div
end


function get_edc_k(spectrum, kxkykz)
	wave spectrum
	string kxkykz
	
	//settings:
	//settings end
	
	variable theta = get_info(spectrum, "InitialThetaManipulator")+get_info(spectrum, "OffsetThetaManipulator")
	variable phi =get_info(spectrum, "InitialPhiManipulator") + get_info(spectrum, "OffsetPhiManipulator")
	variable azi = get_info(spectrum, "InitialAzimuthManipulator")+ get_info(spectrum, "OffsetAzimuthManipulator")
	
	variable EF = get_info(spectrum, "FermiEnergy")
	variable ky = get_info(spectrum, "Momentum")
	
	make/o/n=100 temp_kx, temp_ky
	setscale/P x, -15, 15, temp_kx, temp_ky
	
	temp_kx = Angle2Momentum(theta,phi,azi,x,0,EF,1)
	temp_ky = Angle2Momentum(theta,phi,azi,x,0,EF,2)
	
	variable kx = interp(ky, temp_ky, temp_kx)
	variable pipi = pi/3.82
	
	if(stringmatch(kxkykz, "kx"))
		return kx
	elseif(stringmatch(kxkykz, "ky"))
		return ky
	elseif(stringmatch(kxkykz, "angle"))//AN alignment fermi angle, 0 = AN direction
		return 90 - atan((pipi-abs(ky))/(pipi-abs(kx)))*180/pi
	elseif(stringmatch(kxkykz,"nodal")) //nodal alignment fermi angle, 0 = nodal direction
		return atan(ky/(sqrt(2)*pipi-abs(kx)))*180/pi
	elseif(stringmatch(kxkykz, "dwave"))
		return abs((cos(kx*pi/pipi)-cos(ky*pi/pipi))/2)
	else
		print "return nothing"
		return NAN
	endif
end	

function flip_selected_waves(newnamebase)
	string newnamebase
	variable numofwaves, index, index2
	index=0
	do
		wave target=$(getbrowserselection(index))
		index+=1
	while(strlen(getbrowserselection(index))!=0)
	numofwaves=index
	variable numofflipwaves = numpnts(target)
	string newname
	
	for(index=0;index<numofflipwaves;index+=1)
		newname = newnamebase +"_"+num2str(index)
		make/o/n=(numofwaves) $newname
		wave flipwave = $newname
		for(index2=0;index2<numofwaves;index2+=1)
			wave target = $(getbrowserselection(index2))
			flipwave[index2]=target[index]
		endfor
	endfor
end

function get_maxloc(edc, Efrom_Eto_smoothtime_smoothpnt)
//ub("maxloc_OD71,get_maxloc,pl")
	wave edc
	string Efrom_Eto_smoothtime_smoothpnt
	
	variable efrom=str2num(stringfromlist(0,Efrom_Eto_smoothtime_smoothpnt,","))
	variable eto=str2num(stringfromlist(1,Efrom_Eto_smoothtime_smoothpnt,","))
	variable smoothtime = str2num(stringfromlist(2,Efrom_Eto_smoothtime_smoothpnt,","))
	variable smoothpnt = str2num(stringfromlist(3,Efrom_Eto_smoothtime_smoothpnt,","))
	
	//settings:
	//variable smoothtime = 5
	//variable smoothpnt = 10
	//end settings
	variable index=0
	if(smoothtime!=0)
		duplicate/o edc temp_edc
		//smooth
		for(index=0;index<smoothtime; index+=1)
			smooth/E=3 smoothpnt,temp_edc
		endfor
		wavestats/R=(efrom,eto)/Q temp_edc
	else
		wavestats/R=(efrom,eto)/Q edc
	endif
	return V_maxloc
end

function get_minloc(edc, Efrom_Eto_smoothtime_smoothpnt)
//ub("maxloc_OD71,get_maxloc,pl")
	wave edc
	string Efrom_Eto_smoothtime_smoothpnt
	
	variable efrom=str2num(stringfromlist(0,Efrom_Eto_smoothtime_smoothpnt,","))
	variable eto=str2num(stringfromlist(1,Efrom_Eto_smoothtime_smoothpnt,","))
	variable smoothtime = str2num(stringfromlist(2,Efrom_Eto_smoothtime_smoothpnt,","))
	variable smoothpnt = str2num(stringfromlist(3,Efrom_Eto_smoothtime_smoothpnt,","))
	
	//settings:
	//variable smoothtime = 5
	//variable smoothpnt = 10
	//end settings
	variable index=0
	if(smoothtime!=0)
		duplicate/o edc temp_edc
		//smooth
		for(index=0;index<smoothtime; index+=1)
			smooth/E=3 smoothpnt,temp_edc
		endfor
		wavestats/R=(efrom,eto)/Q temp_edc
	else
		wavestats/R=(efrom,eto)/Q edc
	endif
	return V_minloc
end








function get_2nd_dev_max(edc, Efrom_Eto_smoothtime_smoothpnt)
//ub("maxloc_OD71,get_maxloc,pl")
	wave edc
	string Efrom_Eto_smoothtime_smoothpnt
	
	variable efrom=str2num(stringfromlist(0,Efrom_Eto_smoothtime_smoothpnt,","))
	variable eto=str2num(stringfromlist(1,Efrom_Eto_smoothtime_smoothpnt,","))
	variable smoothtime = str2num(stringfromlist(2,Efrom_Eto_smoothtime_smoothpnt,","))
	variable smoothpnt = str2num(stringfromlist(3,Efrom_Eto_smoothtime_smoothpnt,","))
	
	//settings:
	//variable smoothtime = 5
	//variable smoothpnt = 10
	//end settings
	variable index=0
	if(smoothtime!=0)
		duplicate/o edc temp_edc
		//smooth
		for(index=0;index<smoothtime; index+=1)
			smooth/E=3 smoothpnt,temp_edc
		endfor
		//2nd dev
		Differentiate temp_edc /D=temp_edc_dev
		Differentiate temp_edc_dev /D=temp_edc
		
		wavestats/R=(efrom,eto)/Q temp_edc
	else
		Differentiate temp_edc /D=temp_edc_dev
		Differentiate temp_edc_dev /D=temp_edc
		wavestats/R=(efrom,eto)/Q edc
	endif
	return V_minloc
end




function get_halfarea(edc, pl)
//ub("maxloc_OD71,get_maxloc,pl")
	wave edc
	string pl
	
	//settings:
	variable efrom = -0.6
	variable eto = 0
	//end settings
	duplicate/o/R=(efrom-0.01,eto+0.01) edc, edc_temp, edc_x
	edc_x=x
	edc_temp = area(edc,x,0)
	variable half_area = edc_temp(-0.6)/2
	return  interp(half_area,edc_temp,edc_x)
end




function normwidth(edc,pl)
	wave edc
	string pl
	
	variable width = find_width(edc,pl)
	print width 
	variable dimoff = dimoffset(edc,0)
	variable dimdel = dimdelta(edc,0)
	
	setscale/P x,dimoff/width, dimdel/width,edc
end 


function finddisp(image,pl)
	wave image
	string pl
	
	string dispname = nameofwave(image)+"_disp"
	wave disp = slice_mdc(image,"0")
	
	rename disp, $dispname
	
	variable index
	for(index=0;index<numpnts(disp);index+=1)
		wave edc = slice_edc(image,num2str(index))
		wavestats/Q/R=(-0.1,0) edc
		disp[index]=V_maxloc
	endfor
end

function eV2K(eV)
	variable eV
	
	variable kb = 8.61733034e-5
	return eV/kb
end

function s_plot()
	ModifyGraph lsize=0.5//,rgb=(0,0,0)
	ModifyGraph axThick=0.5,ZisZ=1,btLen=2,stLen=1
	ModifyGraph gFont="Helvetica"
	ModifyGraph gfSize=7
	ModifyGraph mirror=2
	//ModifyGraph tick=2
end


function add_suffix(spectrum,suffix)
//universial_batch("NAW,add_suffix,pl")
	wave spectrum
	string suffix
	string name  = nameofwave(spectrum)
	string newname = name+suffix
	rename spectrum $newname
end

function add_prefix(spectrum,suffix)
//universial_batch("NAW,add_prefix,pl")
	wave spectrum
	string suffix
	string name  = nameofwave(spectrum)
	string newname = suffix+name
	rename spectrum $newname
end

function plot_style()
	//GP_quickStyle()
	s_plot()
	//ModifyGraph manTick(left)={0,0.5,0,1},manMinor(left)={0,0}
	ModifyGraph height=144
	ModifyGraph width=108
	ModifyGraph manTick(bottom)={90,20,0,0},manMinor(bottom)={0,0};DelayUpdate
	SetAxis bottom 80,180
end	



MH_nmat_GapTF_ratio = 2*root:For_chess_plot_MH:MH_nmat_Gap[p]/(8.61733034e-5*root:For_chess_plot_MH:MH_nmat_Tgap[p])


root:For_chess_plot_MH:MH_nmat_GapTF_ratio_error_T =  2*root:For_chess_plot_MH:MH_nmat_Gap[p]*root:For_chess_plot_MH:MH_nmat_Tgap_error[p]/(8.61733034e-5*root:For_chess_plot_MH:MH_nmat_Tgap[p]^2)


root:For_chess_plot_MH:MH_nmat_GapTF_ratio_error_g = 2*MH_nmat_Gaperror[p]/(8.61733034e-5*root:For_chess_plot_MH:MH_nmat_Tgap[p])
root:For_chess_plot_MH:MH_nmat_GapTF_ratio_error = sqrt((MH_nmat_GapTF_ratio_error_g[p])^2 +(MH_nmat_GapTF_ratio_error_T[p])^2)



function sep_waves(temperature, thetaround, dos)
	wave temperature
	wave thetaround
	wave dos

	variable index=0
	variable subindex=0
	variable waveindex=0
	variable current_theta=nan
	
	make/o/n=10 startindex
	
		
	for(index=0;index<dimsize(thetaround, 0);index+=1)
		if(thetaround[index]!=current_theta)
			current_theta=thetaround[index]
			startindex[waveindex]=index
			waveindex+=1
		endif
	endfor
	duplicate/o startindex, endindex
	endindex[0,numpnts(endindex)-2]=startindex[p+1]-1
	endindex[numpnts(endindex)-1]=index-1
	
	string temname
	string dosname
	string notestr
	
	for(waveindex=0;waveindex<numpnts(startindex);waveindex+=1)
		temname="temperature_"+num2str(waveindex)
		dosname="dos_"+num2str(waveindex)
		notestr="theta="+num2str(thetaround[startindex[waveindex]])
		
		duplicate/O/R=[startindex[waveindex],endindex[waveindex]] temperature, $temname
		duplicate/O/R=[startindex[waveindex],endindex[waveindex]]  dos, $dosname
		
		wave tem_sub = $temname
		wave dos_sub = $dosname
		
		note/K tem_sub, notestr
		note/K dos_sub, notestr
		
	endfor
end




function diffwaves()
	string names="0;1;2;3;4;5;6;7;8;9;"
	
	variable index
	
	string dosname, temname, diff_dos_name
	
	for(index=0;index<itemsinlist(names);index+=1)
		dosname="dos_"+stringfromlist(index,names)
		temname="temperature_"+stringfromlist(index,names)+"n"
		diff_dos_name=dosname+"_DIF"
		
		Differentiate $dosname/X=$temname/D=$diff_dos_name
	endfor
end
		
		
ub("naw,norm_by_area,pl")
ub("temperature,get_info,sampletemperature")
•ub("theta,get_info,theta")
•ub("dos,get_area,-0.001,0.001")

ub("naw,devide_number,95")


function bin_theta_tem_dos(thetaround, tem, dos,thetamatch)
	wave thetaround, tem, dos
	//settings
	string thetamatch
	variable temstep = 5
	variable tfrom = 18
	variable tto = 141
	//end settings
	
	make/o/n=(round((tto-tfrom)/temstep)) tfrom_tto
	setscale/I x, tfrom, tto, tfrom_tto
	tfrom_tto=x
	
	make/o/n=(numpnts(tfrom_tto)-1) $(nameofwave(tem)+"_bin"+thetamatch[1,inf]), $(nameofwave(dos)+"_bin"+thetamatch[1,inf])
	wave tem_bin=$(nameofwave(tem)+"_bin"+thetamatch[1,inf])
	wave dos_bin= $(nameofwave(dos)+"_bin"+thetamatch[1,inf])
	
	//tem_bin=(tfrom_tto[p]+tfrom_tto[p+1])/2
	
	variable tindex, index, count, tem_sum, dos_sum
	for(tindex=0;tindex<numpnts(tem_bin);tindex+=1)
		count= 0
		tem_sum = 0
		dos_sum = 0
		tfrom = tfrom_tto[tindex]
		tto = tfrom_tto[tindex+1]
		for(index=0;index<numpnts(dos);index+=1)
			
			if((min(tem[index],tfrom)==tfrom)&&(tem[index]<tto)&&(whichlistitem(num2str(thetaround[index]),thetamatch)!=-1))
				count+=1
				tem_sum +=tem[index]
				dos_sum +=dos[index]
			endif
		endfor
		if(count>0)
			tem_sum/=count
			dos_sum/=count
			tem_bin[tindex]=tem_sum
			dos_bin[tindex]=dos_sum
		endif
	endfor
	 remove_zero(tem_bin,"")
	 remove_zero(dos_bin,"")
	 Differentiate dos_bin/X=tem_bin/D=$(nameofwave(dos)+"DIF"+thetamatch[1,inf])
end

function remove_zero(wave_zero,pl)
	wave wave_zero
	string pl
	
	variable index=0
	
	do
		if(wave_zero[index]==0)
			deletepoints index, 1, wave_zero
		else
			index+=1
		endif
	while(index<numpnts(wave_zero))
end


function reduce_dos_T()
	//settings
	string thetalist="0;3;5;7;9;11;13;15;17;19"
	variable tc = 95
	//settings
	
	variable index
	string theta
	
	variable dosnorm
	wave thetaround,tem, dos
	
	for(index=0;index<itemsinlist(thetalist);index+=1)
		theta=stringfromlist(index,thetalist)
		bin_theta_tem_dos(thetaround, tem, dos,"-"+theta)
	
		wave temwave = $("tem_bin_"+theta)
		wave doswave = $("dos_bin_DIF_"+theta)
		
		duplicate/O temwave, $("tem_bin_reduced_"+theta)
		duplicate/O doswave  $("dos_bin_DIF_reduced_"+theta)
		
		wave temwave = $("tem_bin_reduced_"+theta)
		wave doswave = $("dos_bin_DIF_reduced_"+theta)
		
		temwave/=tc
		dosnorm=areaXY(temwave, doswave, 0.67,1)
		doswave /=dosnorm
	endfor
end

print areaXY(tem_AN_reduced, dos_AN_DIF, 0.67,1)



function Convolve_Resolution(EDC, energy_resolution)
//This function convolves EDC with energy resoultion.
	wave EDC
	string energy_resolution //in eV
	
	variable resolution = str2num(stringfromlist(0,energy_resolution))
	
	string newEDCname = nameofwave(EDC) + "_"+ num2str(resolution*1000)+"meV"
	
	duplicate/O edc, $newEDCname
	wave newEDC = $newEDCname
	
	variable Estart = dimoffset(EDC,0)
	variable Eend = Estart + dimdelta(EDC,0)*(numpnts(EDC)-1)
	
	variable deltaE = dimdelta(EDC, 0)
	
	variable resolution_wave_half_size = round(3*resolution/deltaE)
	make/o/n=(2* resolution_wave_half_size +1) resolution_wave
	setscale/P x, -resolution_wave_half_size*deltaE, deltaE, resolution_wave
	
	resolution_wave = Gauss(x, 0, resolution/(2*(sqrt(2*ln(2)))))
	
	variable normvalue = sum(resolution_wave)
	
	resolution_wave/= normvalue
	
	make/o/n=(2* resolution_wave_half_size+dimsize(EDC,0)) edc_temp
	setscale/P x, Estart-resolution_wave_half_size*deltaE, deltaE, edc_temp
	
	edc_temp = ((x>Estart)&&(x<Eend))? edc(x) : ((x<Eend)? edc(Estart) : edc(Eend))
	
	convolve/A resolution_wave, edc_temp
	
	newEDC = edc_temp(x)

end

make/o/n=43 temperature_10meV, dos_10meV
ub("temperature_10meV,get_info,sampletemperature;dos_10meV,get_area,-0.001,0.001")
make/o/n=43 temperature_50meV, dos_50meV
ub("temperature_50meV,get_info,sampletemperature;dos_50meV,get_area,-0.001,0.001")

areaXY(XWaveName, YWaveName , x1, x2)




function get_reso_extrapolation_wave(edc, total_reso)
	wave edc
	string total_reso

	
	//settings
	variable energyfrom = -0.0005
	variable energyto = 0.0005
	variable reso_step = 0.002
	variable reso_pnts = 10
	//end settings
	
	wave total_reso_wave = $total_reso
	
	string edcname = nameofwave(EDC)
	string newedcname
	make/o/n=(reso_pnts) $(edcname+"_reso_extra")
	wave edc_reso_extra = $(edcname+"_reso_extra")
	
	edc_reso_extra[0]= area(edc, energyfrom, energyto)/(energyto-energyfrom)
	
	variable index
	variable energy_resolution
	
	for(index=1;index<reso_pnts;index+=1)
		energy_resolution= index*reso_step
		Convolve_Resolution(edc, num2str(energy_resolution))
		
		newEDCname = nameofwave(EDC) + "_"+ num2str(energy_resolution*1000)+"meV"
		wave edc_convolved = $newEDCname
		
		edc_reso_extra[index]= area(edc_convolved, energyfrom, energyto)/(energyto-energyfrom)
	endfor
	
	CurveFit/Q/NTHR=0 line edc_reso_extra /X=total_reso_wave /D 
	wave W_coef
	wave W_sigma
	//print w_coef[0]
	return W_coef[0]
	//return 3*w_sigma[0]
end



function set_info(cut, infostring_infovalue)
	wave cut
	string infostring_infovalue
	
	string infostring = StringFromList(0, infostring_infovalue,",")
	string infovalue = StringFromList(1,infostring_infovalue,",")

	string notestr = note(cut)
	//print StringByKey(infostring ,  notestr, "=", "\r")
	notestr = ReplaceStringByKey(infostring,notestr, infovalue, "=","\r")
	
	note/K cut, notestr
end





function get_gapsize(edc, returnstring)
//ub("gap,get_gapsize,pl;gap_error,get_gapsize,error")
//ub("temperature,get_info,SampleTemperature")
	wave edc
	string returnstring//stringmatch("error",pl) to return errorbar
	
	//settings:
	variable efrom = -0.1
	variable eto =0
	variable fit_range = 0.035
	variable poly_terms = 6
	//end settings
	variable index=0
	
	wavestats/Q/R=(efrom,eto)/Q edc
	
	variable fit_efrom =V_maxloc - fit_range/2
	variable fit_eto = V_maxloc + fit_range/2
	variable rawmax = V_maxloc
	
	CurveFit/Q/M=2/W=0 poly poly_terms, edc(fit_efrom, fit_eto)/D
	wave W_coef
	
	string fitnamewave = cropname("fit_"+nameofwave(edc))
	make/o/n=(fit_range/0.0001) $fitnamewave
	wave fitwave = $fitnamewave
	setscale/I x,fit_efrom, fit_eto,fitwave
	fitwave = poly(W_coef, x)
	
	wavestats/Q/R=(efrom,eto) fitwave
	variable return_value = V_maxloc
	
	variable errorbar=abs(V_maxloc - rawmax)
	if(stringmatch(returnstring,"error" ))
		return_value = errorbar
	endif
	return return_value
	
end


function add_error()
	wave gap_L
	wave gap_L_error
	wave gap_R
	wave gap_R_error
	
	duplicate/o gap_L, gap_2, gap_error_2
	
	make/o/n=2 value, error
	
	gap_2=(gap_L[p]+gap_R[p])/2
	
	gap_error_2=sqrt(0.001^2+((gap_L[p]-gap_R[p])^2)/4+((gap_L_error[p])^2+(gap_R_error[p])^2)/2)
	
	
	
//	variable index
//	for(index=0;index<numpnts(gap_L);index+=1)
//		value[0]=gap_L[index]
//		error[0]=gap_L_error[index]
//		value[1]=gap_R[index]
//		error[1]=gap_R_error[index]
//		CurveFit/Q/H="01"/NTHR=0 line  Value /W=error /I=1 /D
//		wave w_coef
//		wave w_sigma
//		
//		gap_2[index]=w_coef[0]
//		error_2[index]=w_sigma[0]
//		
//	endfor
end





function get_gapsize_2nddev(edc, returnstring)
//ub("gap,get_gapsize_2nddev,pl;gap_error,get_gapsize_2nddev,error")
//ub("temperature,get_info,SampleTemperature")
	wave edc
	string returnstring//stringmatch("error",pl) to return errorbar
	
	//settings:
	variable efrom = -0.2
	variable eto =0.05
	variable fit_range = 0.035
	variable poly_terms = 3
	//end settings
	variable index=0
	
	wavestats/Q/R=(efrom,eto)/Q edc
	
	variable fit_efrom =V_minloc - fit_range/2
	variable fit_eto = V_minloc + fit_range/2
	variable rawmax = V_minloc
	
	CurveFit/Q/M=2/W=0 poly poly_terms, edc(fit_efrom, fit_eto)/D
	wave W_coef
	
	string fitnamewave = cropname("fit_"+nameofwave(edc))
	make/o/n=(fit_range/0.0001) $fitnamewave
	wave fitwave = $fitnamewave
	setscale/I x,fit_efrom, fit_eto,fitwave
	fitwave = poly(W_coef, x)
	
	wavestats/Q/R=(-0.1,0) fitwave
	variable return_value = V_minloc
	
	variable errorbar=abs(V_minloc - rawmax)
	if(stringmatch(returnstring,"error" ))
		return_value = errorbar
	endif
	return return_value
	
end

 ddos_dt(root:Miguel_calculation:Closing_homogeneousgap, root:Miguel_calculation:error_0,root:Miguel_calculation:T_over_T_peak,"interp","norm")

function ddos_dt(dos, dos_error,temperature,method,normdos)
	wave dos
	wave dos_error
	wave temperature
	string method
	string normdos
	
	string name= nameofwave(dos)
	
	duplicate/o dos, $(name+"_ddT"),$(name+"_ddT_err")
	wave ddT=$(name+"_ddT")
	wave ddT_err=$(name+"_ddT_err")
	variable index, T_at, index_temp, index_search, intensity_at, error_at
	
	//settings
	//when "fit" is selected as method, data in T-T_range, T+T_range will be fitted to a 2nd order polynomal and dev will be calculated from fitting results.
	//when "range" is selected, data in T-T_range, T+T_range plus nearest neighbor will be used to calculate the derivative and averaged.
	//when "interp" is selected, data from T1 and T2 are used to generate derivative at (T2-T1)/2
	variable T_range = 15
	//end settings
	
	
	
	variable intensity1,intensity2, error1,error2, t1, t2
	
	if(stringmatch(normdos,"norm"))
		variable dvd = wavemax(dos)-wavemin(dos)
		dos/=dvd
	endif
	
	
	
	
	
	if(stringmatch(method,"interp"))
		duplicate/o dos, $(nameofwave(temperature)+"_ddT"), $(nameofwave(temperature)+"_ddT_error")
		wave tem_ddT = $(nameofwave(temperature)+"_ddT")
		wave tem_ddT_error = $(nameofwave(temperature)+"_ddT_error")
		
		deletepoints 0,1, ddT, ddT_err, tem_ddT, tem_ddT_error
		
		tem_ddT = (temperature[p]+temperature[p+1])/2
		tem_ddT_error = abs(temperature[p]-temperature[p+1])/2
		
		for(index=0;index<numpnts(temperature)-1;index+=1)
			ddT[index]=(dos[index+1]-dos[index])/(temperature[index+1]-temperature[index])
			error1=sqrt(dos_error[index+1]^2+dos_error[index]^2)/abs(temperature[index+1]-temperature[index])
			ddT_err[index]=error1
		endfor
	endif
	
	if(stringmatch(method,"nn"))
		index=numpnts(dos)-1
		
		ddT[0]=(dos[1]-dos[0])/(temperature[1]-temperature[0])
		ddT_err[0]=sqrt(dos_error[1]^2+dos_error[0]^2)/abs(temperature[1]-temperature[0])
		
		ddT[index]=(dos[index-1]-dos[index])/(temperature[index-1]-temperature[index])
		ddT_err[index]=sqrt(dos_error[index-1]^2+dos_error[index]^2)/abs(temperature[index-1]-temperature[index])
		

		
		for(index=1;index<numpnts(dos)-1;index+=1)
			ddT[index]=((dos[index-1]-dos[index])/(temperature[index-1]-temperature[index])+(dos[index+1]-dos[index])/(temperature[index+1]-temperature[index]))/2
			error1=sqrt(dos_error[index-1]^2+dos_error[index]^2)/abs(temperature[index-1]-temperature[index])
			error2=sqrt(dos_error[index+1]^2+dos_error[index]^2)/abs(temperature[index+1]-temperature[index])
			ddT_err[index]=sqrt((error1^2+error2^2)/2)
		endfor
	endif
	
	if(stringmatch(method,"range"))
		
		for(index=0;index<numpnts(dos);index+=1)
			index_temp = 0
			index_search = 0
			
			T_at = temperature[index]
			Intensity_at = dos[index]
			error_at = dos_error[index]
			
			make/o/n=100 dos_temp, T_temp, Dos_err_temp, dev_temp, dev_err_temp
			dos_temp = NaN
			T_temp = NaN
			Dos_err_temp = NaN
			dev_temp = NaN
			dev_err_temp = NaN
			
			for(index_search=0;index_search<numpnts(dos);index_search+=1)
				if(((temperature[index_search]>(T_at-T_range))&&(temperature[index_search]<(T_at))||(index-index_search)==1))
					dos_temp[index_temp]=dos[index_search]
					T_temp[index_temp]=temperature[index_search]
					dos_err_temp[index_temp]=dos_error[index_search]
					index_temp+=1
				endif
			endfor
			
			DeletePoints index_temp, inf, dos_temp, T_temp, Dos_err_temp, dev_temp, dev_err_temp
			
			if(index!=0)
				t1=mean(T_temp)
				intensity1=mean(dos_temp)
				wavestats/Q Dos_err_temp
				error1 = V_rms
			endif
			
			make/o/n=100 dos_temp, T_temp, Dos_err_temp, dev_temp, dev_err_temp
			dos_temp = NaN
			T_temp = NaN
			Dos_err_temp = NaN
			dev_temp = NaN
			dev_err_temp = NaN
			index_temp = 0
			index_search = 0
			
			for(index_search=0;index_search<numpnts(dos);index_search+=1)
				if(((temperature[index_search]>(T_at))&&(temperature[index_search]<(T_at+T_range))||(index-index_search)==-1))
					dos_temp[index_temp]=dos[index_search]
					T_temp[index_temp]=temperature[index_search]
					dos_err_temp[index_temp]=dos_error[index_search]
					index_temp+=1
				endif
			endfor
			
			DeletePoints index_temp, inf, dos_temp, T_temp, Dos_err_temp, dev_temp, dev_err_temp
			if ((index+1)!=numpnts(dos))
				t2=mean(T_temp)
				intensity2=mean(dos_temp)
				wavestats/Q Dos_err_temp
				error2 = V_rms
			endif
			
			if(index==0)
				ddt[index]=(intensity2-intensity_at)/(T2-T_at)
				ddt_err[index]=sqrt(error2^2+error_at^2)/abs(T2-T_at)
			elseif(index==(numpnts(dos)-1))
				ddt[index]=(intensity1-intensity_at)/(T1-T_at)
				ddt_err[index]=sqrt(error1^2+error_at^2)/abs(T1-T_at)
			else
				ddt[index]=((intensity1-intensity_at)/(T1-T_at)+(intensity2-intensity_at)/(T2-T_at))/2
				ddt_err[index]=sqrt(((sqrt(error2^2+error_at^2)/abs(T2-T_at))^2+(sqrt(error1^2+error_at^2)/abs(T1-T_at))^2)/2)
			endif
		endfor
	endif
	
	
	
	
	
	
	
	if(stringmatch(method,"fit"))
		make/o/n=100 dos_temp, T_temp, Dos_err_temp
		for(index=0;index<numpnts(dos);index+=1)
		
			dos_temp = NaN
			T_temp = NaN
			Dos_err_temp = NaN
			
			index_temp = 0
			index_search = 0
			
			T_at = temperature[index]
			
			for(index_search=0;index_search<numpnts(dos);index_search+=1)
				if((temperature[index_search]>(T_at-T_range))&&(temperature[index_search]<(T_at+T_range))||(abs(index-index_search)==1))
					dos_temp[index_temp]=dos[index_search]
					T_temp[index_temp]=temperature[index_search]
					dos_err_temp[index_temp]=dos_error[index_search]
					index_temp+=1
				endif
			endfor
			if(index_temp>2)
				CurveFit/Q/NTHR=0 poly 3,  dos_temp /X=T_temp /W=dos_err_temp /I=1 /D 
				wave w_coef, w_sigma
				ddt[index]=w_coef[1]+w_coef[2]*T_at
				ddt_err[index]=sqrt((w_sigma[1])^2+(w_sigma[2]*T_at)^2)
				
			else
				CurveFit/Q/NTHR=0 line  dos_temp /X=T_temp /W=dos_err_temp /I=1 /D 
				wave w_coef, w_sigma
				ddt[index]=w_coef[1]
				ddt_err[index]=sqrt((w_sigma[1])^2)
			endif	

		endfor
	endif
end



function get_noise_rms(edc,efrometo)
	wave edc
	string efrometo
	
	variable efrom=str2num(stringfromlist(0,efrometo,","))
	variable eto=str2num(stringfromlist(1,efrometo,","))
		
	duplicate/o edc temp_edc
	temp_edc = NaN
	
	CurveFit/Q/NTHR=0 poly 3, edc(efrom,eto) /D /R=temp_edc
	
	wavestats/Q/R=(efrom,eto) temp_edc
	return V_rms
end
	
	
		differentiate
		
		



make/o/n=16 sw_0,fd_error,noise_error,sw_0_error,temperature
ub("temperature,get_info,sampletemperature;sw_0,get_area,-0.0005,0.0005")
fd_Error=(fd(0,temperature[p])-fd(0.001,temperature[p]))
ub("noise_error,get_noise_rms,-0.25,-0.2")
sw_0_error=sqrt((sw_0[p]*fd_error[p])^2+(2*noise_error*sqrt(sw_0[p]/2))^2)


ddos_dt(sw_0, sw_0_error,temperature,"nn")


Display gap_2 vs temperature2; AppendToGraph/R sw_0 vs temperature
ModifyGraph muloffset(gap_2)={0,-1};DelayUpdate
ErrorBars/T=0 gap_2 Y,wave=(gap_error_2,gap_error_2)
ErrorBars/T=0 sw_0 Y,wave=(sw_0_error,sw_0_error)
ModifyGraph mode=3,marker(sw_0)=8,rgb(sw_0)=(0,43690,65535),marker(gap_2)=19;DelayUpdate
ModifyGraph rgb(gap_2)=(65535,21845,0)
s_plot()
ModifyGraph width=144,height=72,expand=2
ModifyGraph mirror(bottom)=2
ModifyGraph standoff(bottom)=0;DelayUpdate
•Label left "\\u#2Gap (meV)";DelayUpdate
•Label right "A\\B0\\M(arb. unit)";DelayUpdate
•SetAxis left 0,0.032;DelayUpdate
•SetAxis right 0,1.9



Display sw_0_ddT vs temperature
•ModifyGraph mode=3,marker=19,rgb=(65535,16385,16385);DelayUpdate
•ErrorBars/T=0 sw_0_ddT Y,wave=(sw_0_ddT_err,sw_0_ddT_err)
•ModifyGraph width=144,height=72,expand=2
•s_plot()
•ModifyGraph zero(left)=3;DelayUpdate
•Label left "\\u#2dA\\B0\\M/dT (10\\S-3\\M)"


•AppendToGraph/VERT tc
•ModifyGraph lsize=0.5,lstyle(tc)=2,rgb(tc)=(0,0,0)
•ModifyGraph rgb(tc)=(21845,21845,21845)
•ModifyGraph standoff(bottom)=0

make/o/n=2 Tc_10, Tc_90
setscale/P x,-5,10,Tc_10, Tc_90
Tc_10 = 79.7253
Tc_90 = 77.2241




ModifyGraph rgb(sw_0)=(  8192,36044,65535)