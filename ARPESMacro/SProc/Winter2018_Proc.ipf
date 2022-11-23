#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function AN_matrix_plot()
//this function create a matrix plot of m x n images (m raws, n columns)
//the space between these images are spacem and spacen
//the axis range are (xmin,xmax) and (ymin,ymax)

//settings:
string samplelist = "OP91;OD90;OD88;OD86;OD81;OD70" //n-list
string temperaturelist = "250" //m-list
variable spacem = 0
variable spacen = 0.1
variable xmin = -0.35
variable xmax = 0.35
variable ymin = -0.25
variable ymax = 0.05
//end settings

variable n = itemsinlist(samplelist)
variable m = itemsinlist(temperaturelist)


variable indexm,indexn
string xaxisname,yaxisname,mirror_xaxisname,mirror_yaxisname
string imagename

display

for(indexm=0;indexm<m;indexm+=1)
	for(indexn=0;indexn<n;indexn+=1)
		
		imagename = stringfromlist(indexn,samplelist)+"_T"+stringfromlist(indexm,temperaturelist)+"K"
		xaxisname="xaxis_r"+num2str(indexm)+"c"+num2str(indexn)
		yaxisname="yaxis_r"+num2str(indexm)+"c"+num2str(indexn)
		mirror_xaxisname="mirror_"+xaxisname
		mirror_yaxisname="mirror_"+yaxisname
		
		newfreeaxis/B $xaxisname
		newfreeaxis/L $yaxisname
		newfreeaxis/T $mirror_xaxisname
		newfreeaxis/R $mirror_yaxisname
		
				
		SetAxis $xaxisname xmin,xmax
		SetAxis $yaxisname ymin,ymax

		ModifyFreeAxis $mirror_xaxisName, master=$xaxisname
		ModifyFreeAxis $mirror_yaxisName, master=$yaxisname

		Appendimage/L=$yaxisname/B=$xaxisname $imagename
		//Imagestats/GS={-0.4,0.4,-0.2, 0.1} $imagename
		ModifyImage $imagename ctab= {*,*,grays,0} //ctab={zMin, zMax, ctName, reverse }
		
		
		ModifyGraph freePos($xaxisname)={ymin,$yaxisname},freePos($yaxisname)={xmin,$xaxisname}
		ModifyGraph freePos($mirror_xaxisname)={ymax,$yaxisname}, freePos($mirror_yaxisname)={xmax,$xaxisname}
		ModifyGraph axisEnab($xaxisname)={indexn/n,(indexn+1-spacen)/n}
		ModifyGraph axisEnab($mirror_xaxisname)={indexn/n,(indexn+1-spacen)/n}
		ModifyGraph axisEnab($yaxisname)={1- (indexm+1-spacem)/m, 1- indexm/m}
		ModifyGraph axisEnab($mirror_yaxisname)={1- (indexm+1-spacem)/m, 1- indexm/m}
		ModifyGraph noLabel($xaxisname)=1
		ModifyGraph noLabel($yaxisname)=1
		ModifyGraph noLabel($mirror_xaxisname)=2
		ModifyGraph noLabel($mirror_yaxisname)=2
		ModifyGraph tick($mirror_xaxisname)=3
		ModifyGraph tick($mirror_yaxisname)=3
		ModifyGraph zero($yaxisname)=8,zeroThick($yaxisname)=0.5
		//ModifyGraph userticks(bottom)={inva_value,pi_label}
endfor
endfor

ModifyGraph btLen=2,stLen=2

end





function AN_matrix_plot_flip()
//this function create a matrix plot of m x n images (m raws, n columns)
//the space between these images are spacem and spacen
//the axis range are (xmin,xmax) and (ymin,ymax)

//settings:
string samplelist = "OD70;OD81;OD86;OD88;OD90;OP91;" //m-list
string temperaturelist = "60;75;90;110;130;150;170;190;210;230;250;270;290;310" //n-list
variable spacem = 0
variable spacen = 0
variable xmin = -0.4
variable xmax = 0.4
variable ymin = -0.3
variable ymax = 0.1
//end settings

variable n = itemsinlist(temperaturelist)
variable m = itemsinlist(samplelist)


variable indexm,indexn
string xaxisname,yaxisname,mirror_xaxisname,mirror_yaxisname
string imagename

display

for(indexm=0;indexm<m;indexm+=1)
	for(indexn=0;indexn<n;indexn+=1)
		
		imagename = stringfromlist(indexm,samplelist )+"_T"+stringfromlist(indexn,temperaturelist)+"K"
		xaxisname="xaxis_r"+num2str(indexm)+"c"+num2str(indexn)
		yaxisname="yaxis_r"+num2str(indexm)+"c"+num2str(indexn)
		mirror_xaxisname="mirror_"+xaxisname
		mirror_yaxisname="mirror_"+yaxisname
		
		newfreeaxis/B $xaxisname
		newfreeaxis/L $yaxisname
		newfreeaxis/T $mirror_xaxisname
		newfreeaxis/R $mirror_yaxisname
		
				
		SetAxis $xaxisname xmin,xmax
		SetAxis $yaxisname ymin,ymax

		ModifyFreeAxis $mirror_xaxisName, master=$xaxisname
		ModifyFreeAxis $mirror_yaxisName, master=$yaxisname

		Appendimage/L=$yaxisname/B=$xaxisname $imagename
		//Imagestats/GS={-0.4,0.4,-0.2, 0.1} $imagename
		ModifyImage $imagename ctab= {0,4.5,terrain,1} //ctab={zMin, zMax, ctName, reverse }
		
		
		ModifyGraph freePos($xaxisname)={ymin,$yaxisname},freePos($yaxisname)={xmin,$xaxisname}
		ModifyGraph freePos($mirror_xaxisname)={ymax,$yaxisname}, freePos($mirror_yaxisname)={xmax,$xaxisname}
		ModifyGraph axisEnab($xaxisname)={indexn/n,(indexn+1-spacen)/n}
		ModifyGraph axisEnab($mirror_xaxisname)={indexn/n,(indexn+1-spacen)/n}
		ModifyGraph axisEnab($yaxisname)={1- (indexm+1-spacem)/m, 1- indexm/m}
		ModifyGraph axisEnab($mirror_yaxisname)={1- (indexm+1-spacem)/m, 1- indexm/m}
		ModifyGraph noLabel($xaxisname)=1
		ModifyGraph noLabel($yaxisname)=1
		ModifyGraph noLabel($mirror_xaxisname)=2
		ModifyGraph noLabel($mirror_yaxisname)=2
		ModifyGraph tick($mirror_xaxisname)=3
		ModifyGraph tick($mirror_yaxisname)=3
		ModifyGraph zero($yaxisname)=8,zeroThick($yaxisname)=0.5
		
endfor
endfor

ModifyGraph btLen=2,stLen=2

end

function shoulder_fit_plot()
//this function create a matrix plot of m x n images (m raws, n columns)
//the space between these images are spacem and spacen
//the axis range are (xmin,xmax) and (ymin,ymax)

//settings:
string samplelist =  "OP91;OD90;OD88;OD86;" //m-list
string temperaturelist = "90;110;130;150;170;" //n-list
variable spacem = 0.05
variable spacen = 0.1
variable xmin = -0.12
variable xmax = 0.01
variable ymin = -0.05
variable ymax = 1.6
//end settings

variable n = itemsinlist(temperaturelist)
variable m = itemsinlist(samplelist)


variable indexm,indexn
string xaxisname,yaxisname,mirror_xaxisname,mirror_yaxisname
string edcname,fit_edcname,shoulder_edcname,poly_edcname,bkg_edcname

display

for(indexm=0;indexm< m;indexm+=1)
	for(indexn=0;indexn<n;indexn+=1)
	
		edcname = stringfromlist(indexm,samplelist)+"_T"+stringfromlist(indexn,temperaturelist)+"K_edc"
		fit_edcname="fit_"+edcname
		shoulder_edcname="shoulder_"+edcname
		poly_edcname="polyfit_"+edcname
		bkg_edcname="bkg_"+edcname
		
		xaxisname="xaxis_r"+num2str(indexm)+"c"+num2str(indexn)
		yaxisname="yaxis_r"+num2str(indexm)+"c"+num2str(indexn)
		mirror_xaxisname="mirror_"+xaxisname
		mirror_yaxisname="mirror_"+yaxisname
		
		newfreeaxis/B $xaxisname
		newfreeaxis/L $yaxisname
		newfreeaxis/T $mirror_xaxisname
		newfreeaxis/R $mirror_yaxisname
		
				
		SetAxis $xaxisname xmin,xmax
		SetAxis $yaxisname ymin,ymax

		ModifyFreeAxis $mirror_xaxisName, master=$xaxisname
		ModifyFreeAxis $mirror_yaxisName, master=$yaxisname

		Appendtograph/L=$yaxisname/B=$xaxisname $edcname,$shoulder_edcname,$bkg_edcname,$fit_edcname//,$poly_edcname
		ModifyGraph lsize($fit_edcname)=0.5
		ModifyGraph lsize($shoulder_edcname)=0.5
		//ModifyGraph lsize($poly_edcname)=0.5
		ModifyGraph lsize($bkg_edcname)=0.5
		
		ModifyGraph rgb($edcname)=(32768,40777,65535)
		ModifyGraph rgb($fit_edcname)=(0,0,0)
		ModifyGraph rgb($shoulder_edcname)=(0,0,65535)
		ModifyGraph rgb($bkg_edcname)=(65535,0,0)
		//ModifyGraph  rgb($poly_edcname)=(0,0,0)
		
		ModifyGraph freePos($xaxisname)={ymin,$yaxisname},freePos($yaxisname)={xmin,$xaxisname}
		ModifyGraph freePos($mirror_xaxisname)={ymax,$yaxisname}, freePos($mirror_yaxisname)={xmax,$xaxisname}
		ModifyGraph axisEnab($xaxisname)={indexn/n,(indexn+1-spacen)/n}
		ModifyGraph axisEnab($mirror_xaxisname)={indexn/n,(indexn+1-spacen)/n}
		ModifyGraph axisEnab($yaxisname)={1- (indexm+1-spacem)/m, 1- indexm/m}
		ModifyGraph axisEnab($mirror_yaxisname)={1- (indexm+1-spacem)/m, 1- indexm/m}
		ModifyGraph noLabel($xaxisname)=1
		ModifyGraph noLabel($yaxisname)=1
		ModifyGraph noLabel($mirror_xaxisname)=2
		ModifyGraph noLabel($mirror_yaxisname)=2
		ModifyGraph tick($mirror_xaxisname)=3
		ModifyGraph tick($mirror_yaxisname)=3
		//ModifyGraph zero($yaxisname)=8,zeroThick($yaxisname)=0.5
		ModifyGraph manTick($xaxisname)={0,0.1,0,1},manMinor($xaxisname)={5,0}
		ModifyGraph manTick($yaxisname)={0,0.5,0,1},manMinor($yaxisname)={0,0}
		ModifyGraph stLen($yaxisname)=1
		ModifyGraph stLen($xaxisname)=1
		ModifyGraph btLen($yaxisname)=2
		ModifyGraph btLen($xaxisname)=2
		ModifyGraph ZisZ($xaxisname)=1
		ModifyGraph axThick=0.5
		
	endfor
endfor

ModifyGraph noLabel(yaxis_r0c0)=0
ModifyGraph noLabel(yaxis_r1c0)=0
ModifyGraph noLabel(yaxis_r2c0)=0
ModifyGraph noLabel(yaxis_r3c0)=0
ModifyGraph noLabel(xaxis_r3c0)=0
ModifyGraph noLabel(xaxis_r3c1)=0
ModifyGraph noLabel(xaxis_r3c2)=0
ModifyGraph noLabel(xaxis_r3c3)=0
ModifyGraph noLabel(xaxis_r3c4)=0

end



function sym_edc_plot()
	string plotname = "OD71_symEDC"
	dplot_selection(plotname)
	SetAxis bottom -0.1,0.1
	offset1(1)
End



function kfedc_plot()
	plot_selection()
	setAxis bottom -0.2,0.05
	offset1(2)
	ModifyGraph width=72,height=216
	ModifyGraph expand=2
	s_plot()
	ModifyGraph zero(bottom)=3
end


function sym_edc_plot2(sample)
//make/n=14 tem
//ub("tem,get_info,sampletemperature")
	string sample
	
	//settings
	variable offsety = 1.2
	//settings
	
	//plot_selection()
	//SetAxis bottom -0.1,0.1
	offset1(offsety)
	string gapwavename = "gap_"+sample
	string ywavename ="gap_"+sample+"_appoffset"
	wave gapwave = $gapwavename
	wave tem = tem
	make/o/n=(14) $ywavename
	wave ywave = $ywavename
	string edcname
	
	variable index
	for(index=0;index<14;index+=1)
		edcname =sample+"_T"+num2str(tem[index])+"K"+"_Sym_e_f206_t216"
		wave edc = $edcname
		ywave[index]=wavemax(edc)+ offsety*index
	endfor
	
	AppendToGraph ywave vs gapwave
	
	ModifyGraph mode($ywavename)=3,marker($ywavename)=8
End

function sep()
	ModifyGraph width=144,height=576
	//SetAxis left 0,15
	SetAxis/A
	SetAxis bottom -0.2,0.2
	ModifyGraph zero(bottom)=4
	ModifyGraph nticks(bottom)=3,ZisZ(bottom)=1
	ModifyGraph mirror=2,btLen=2,stLen=2
	Label left "Intensity (arb. unit)";DelayUpdate
	Label bottom "E - E\\BF\\M (eV)"
	ModifyGraph gFont="Helvetica"
	ModifyGraph standoff(left)=0
	ModifyGraph manTick(bottom)={-0.15,0.15,0,2},manMinor(bottom)={0,0}
end	

function coh()
	plot_selection()
	SetAxis bottom -0.8,0.8
	color_gradient_plot("geo",0,0.9,1,0)
	ModifyGraph mirror(left)=2,mirror(bottom)=1
	SetAxis left 0,*
	Label left "Intensity (arb. unit)"
	Label bottom "E - E\\BF\\M (eV)"
	ModifyGraph width=216,height=216
	ModifyGraph gFont="Helvetica"
	wave target=$(getbrowserselection(0))
	string tex = num2str(round(get_info(target,"sampletemperature")))+" K"
	
	
	TextBox/C/N=text0/F=0/A=MC tex
	TextBox/C/N=text0/X=40.00/Y=40.00
end	

function phasediagram()
	wave tstar, tc, fit_tstar, tc_curve, doping_rev
	AppendToGraph fit_tstar,tc_curve
	SetAxis bottom 0,0.3
	SetAxis left 0,320
	ModifyGraph gFont="Helvetica"
	ModifyGraph lstyle=3
	ModifyGraph rgb(tc_curve)=(0,0,0)
	AppendToGraph tc vs doping_rev
	AppendToGraph tstar vs doping_rev
	ModifyGraph mode(tc)=3,marker(tc)=8,rgb(tc)=(0,0,0),mode(tstar)=3,marker(tstar)=8;DelayUpdate
	ErrorBars tstar Y,const=20
	Label bottom "p"
	Label left "Temperature (K)"
end


	
function split_wave(wave84, pl)
	wave wave84
	string pl
	
	//settings:
	variable length = 124
	string namelist = "T30;T50;T60;T70;T75;T80;T83;T86;T90;T94;T98;T102;T106;T110;T115;T120;T130;T140;T150;T160;T170"
	//endsettings
	
	string namebase = nameofwave(wave84)+"_"
	variable index
	
	for(index=0;index*length<numpnts(wave84);index+=1)
		make/o/n=(length) $(namebase+StringFromList(index, namelist))
		wave newwave =  $(namebase+StringFromList(index, namelist))
		newwave = wave84[length*index+p]
	endfor
end

function plot6()
	variable index=0
	wave tem
	do
		wave target=$(getbrowserselection(index))
		if(index==0)
			display target vs tem
		else
			appendtograph target vs tem
		endif
		index+=1
	while(strlen(getbrowserselection(index))!=0)
	geo()
	SetAxis left 0,*
	SetAxis bottom 50,320
	Legend/C/N=text0/F=0/A=MC
	ModifyGraph gFont="Helvetica"
	Label bottom "Temperature (K)"
end




function image_diff()
	variable index=0
	do
		wave lowt=$(getbrowserselection(index))
		wave hight =$(getbrowserselection(index+1))
		lowt -=hight(x)(y)
		index+=1
	while(strlen(getbrowserselection(index+1))!=0)
end


function fdpi0plot_fig2()
	plot_selection()
	modifygraph rgb=(0,0,0)
	offset1(1)
	SetAxis bottom -0.25,0.1
	ModifyGraph mirror=2
	ModifyGraph zero(bottom)=4
	
	//Label left "Intensity (arb. unit)";DelayUpdate
	//Label bottom "E - E\\BF\\M (eV)"
	ModifyGraph gFont="Helvetica"
	ModifyGraph standoff(left)=0
	ModifyGraph btLen=2,stLen=1
	ep()
	ModifyGraph axThick=0.5
	ModifyGraph lsize=0.5
	ModifyGraph tick(left)=3,nticks(left)=0
	ModifyGraph ZisZ(bottom)=1
	ModifyGraph manTick(bottom)={-0.2,0.1,0,1},manMinor(bottom)={1,0}
	ModifyGraph width=56,height=288
end


function fdpi0plotdoping()
	//plot_selection()
	//SetAxis bottom -0.6,0.6
	ModifyGraph mirror=2
	ModifyGraph zero(bottom)=4
	ModifyGraph ZisZ(bottom)=1
	SetAxis left 0,*
	//TextBox/C/N=text0/F=0/H=30/A=MC "60 K"
	//TextBox/C/N=text0/X=-40.00/Y=-40.00
	Label left "Intensity (arb. unit)";DelayUpdate
	//Label bottom "E - E\\BF\\M (eV)"
	ModifyGraph gFont="Helvetica"
	ModifyGraph gfSize=7
	ModifyGraph width=108,height=108
	ModifyGraph lsize=0.5
	ModifyGraph axThick=0.5
	ModifyGraph nticks(bottom)=4,btLen=2,stLen(left)=2,stLen(bottom)=1;DelayUpdate
	ModifyGraph manTick(bottom)={0,0.4,0,1},manMinor(bottom)={1,0}
	ModifyGraph expand=2
end

function appendguide(feature, append01)
	wave feature
	string append01
	//settings:
	variable offset = 1
	variable markoffset = 0.2
	variable smoothtime = 0.1
	//endsettings
	
	string fname = nameofwave(feature)+"_y"
	duplicate/o feature, $fname
	wave feature_y = $fname
	feature_y = nan
	
	variable index, indexs
	for(index=0;index<dimsize(feature,0);index+=1)
		wave curve=waverefindexed("",index,1)
		if(numtype(feature[index])!=2)
			duplicate/o curve, temp_curve
			for(indexs=0;indexs<smoothtime;indexs+=1)
				Smooth 10, temp_curve
			endfor
			feature_y[index]=temp_curve(feature[index])+offset*index+markoffset
		endif
	endfor
	if(stringmatch(append01,"1"))
		appendtograph feature_y vs feature
		//ModifyGraph mode($fname)=3,marker($fname)=22
	endif
	killwaves/Z temp_curve
end

function ep()
	ModifyGraph expand=2
	ModifyGraph gFont="Helvetica",gfSize=7
end

function cut_edc(image,pl)
	wave image
	string pl
	
	//settings:
	variable kfrom = -0.3
	variable kto = 0.3
	variable dk = 0.04
	//end settings
	
	wave edc = get_edc(image,"-0.02,0.02")
	variable normvalue = faverage(edc,-0.6,-0.5)
	
	string name = nameofwave(image)
	variable numofedcs=round((kto-kfrom)/dk)
	variable index
	for(index=0;index<=numofedcs;index+=1)
		pl = num2str(kfrom+index*dk)+","+num2str(kfrom+index*dk+dk)
		wave edc =get_edc(image,pl)
		edc/=normvalue
		rename edc, $(name+"_"+num2str(index))
	endfor
end

function inva2pi(inva)
	variable inva
	variable a = 3.82
	variable piovera = pi/a
	return inva/piovera
end

function pi2inva(pratio)
	variable pratio
	variable a = 3.82
	variable piovera = pi/a
	return pratio*piovera
end


function makelabel()
	make/o/T/n=(5,2) pi_label={{"-0.4","","0","","0.4"},{"major","minor","major","minor","major"}}
	string typelabel= "Tick Type"
	SetDimLabel 1,1,$typelabel, pi_label
	variable len = dimsize(pi_label,0)
	variable delta = (str2num(pi_label[len-1][0])-str2num(pi_label[0][0]))/(len-1)
	make/o/n=(len) inva_value
	inva_value =pi2inva(str2num(pi_label[0][0])+delta*p)
end

function animage()
	wave target=$(getbrowserselection(0))
	Display;AppendImage target
	wave inva_value
	wave pi_label
	ModifyGraph userticks(bottom)={inva_value,pi_label}
	SetAxis bottom -0.3,0.3
	ModifyGraph btLen=2,stLen=1
	setaxis left -0.25,0.03
	ModifyGraph ZisZ(left)=1
	ModifyGraph manTick(left)={0,0.1,0,1},manMinor(left)={1,0}
	//Label left "E - E\\BF\\M (eV)";DelayUpdate
	//Label bottom "k\\By\\M (¹/a)"
	ModifyGraph standoff=0
	ModifyGraph axThick=0.5
	ModifyGraph width=72,height=72
	s_plot()
	ModifyGraph expand=2
	ModifyGraph tick=2
end	

(62,138,239)//  (15872,35327,61183)
(232,70,62)
(250,186,57)
(63,165,89)

function pi0_60_300_plot()
	plot_selection()
	SetAxis bottom -0.6,0
	ModifyGraph mirror=2
	ModifyGraph width=72,height=72
	Label left "Intensity (arb. unit)";DelayUpdate
	Label bottom "E - E\\BF\\M (eV)"
	ModifyGraph gFont="Helvetica"
	ModifyGraph standoff(left)=0
	ModifyGraph btLen=2,stLen=1
	ep()
	//ModifyGraph manTick(bottom)={-0.2,0.1,0,1},manMinor(bottom)={0,0};DelayUpdate
	ModifyGraph axThick=0.5
	ModifyGraph lsize=0.5
	ModifyGraph zero(left)=0
	ModifyGraph ZisZ(bottom)=1,standoff=0;DelayUpdate
	ModifyGraph manTick(left)={0,2,0,0},manMinor(left)={1,0};DelayUpdate
	ModifyGraph manTick(bottom)={-0.6,0.2,0,1},manMinor(bottom)={1,0}
	ModifyGraph expand=4
end

function kfedc_Akfef_error(image, parastring)
	wave image
	string parastring
	
	variable channelfrom = str2num(stringfromlist(0,parastring,","))
	variable channelto = str2num(stringfromlist(1,parastring,","))
	
	string intname = nameofwave(image)+"_Akfef"
	
	make/o/n=(abs(channelto-channelfrom+1)) $intname
	
	wave akfef = $intname
	
	variable index
	
	for(index=channelfrom;index<(channelto+1);index+=1)
		wave tempedc = slice_edc(image,num2str(index))
		norm_by_area(tempedc,"pl")
		akfef[index-channelfrom]=tempedc(0)
	endfor
	
	string notestr = note(image)
	wavestats/Q akfef
	notestr+="\ravg="+num2str(V_avg)+"\r"
	notestr+="sem="+num2str(V_sem)+"\r"
	note/K akfef, notestr
end

function take_aefkf_value(sample)
	string sample
	string aefkf_name=sample+"_Aefkf"
	string aefkferr_name = sample+"_Aefkf_err"
	
	make/o/n=14 $aefkf_name,  $aefkferr_name
	ub(aefkf_name+",get_info,avg")
	ub(aefkferr_name+",get_info,sem")
	
	wave aefkf = $aefkf_name
	wave aefkferr = $aefkferr_name
	wave ef_relative_error
	aefkferr = sqrt(aefkferr[p]^2+(aefkf[p]*ef_relative_error[p])^2)
end
	
function get_ef_relative_error(eferror)
	variable eferror
	wave tem
	duplicate/o tem, ef_relative_error
	variable index
	make/o/n=1000 fd_temp
	setscale/I x,-0.1,0.1,fd_temp
	for(index=0;index<numpnts(tem);index+=1)
		fd_temp = fd(x,tem[index])
		conv_reso(fd_temp,"0.01")
		ef_relative_error[index] = abs((fd_temp(0)/fd_temp(eferror))-1)
	endfor 
end

function kfedc_width_error(image, parastring)
	wave image
	string parastring
	
	variable channelfrom = str2num(stringfromlist(0,parastring,","))
	variable channelto = str2num(stringfromlist(1,parastring,","))
	
	string intname = nameofwave(image)+"_width"
	
	make/o/n=(abs(channelto-channelfrom+1)) $intname
	
	wave width = $intname
	
	variable index
	
	for(index=channelfrom;index<(channelto+1);index+=1)
		wave tempedc = slice_edc(image,num2str(index))
		norm_by_area(tempedc,"pl")
		
		width[index-channelfrom]= find_width(tempedc,"0.5")
	endfor
	
	string notestr = note(image)
	wavestats/Q width
	notestr+="\ravg="+num2str(V_avg)+"\r"
	notestr+="sem="+num2str(V_sem)+"\r"
	notestr+="width_to_0"+"\r"
	note/K width, notestr
end


function take_width_value(sample)
	string sample
	string width_name=sample+"_width"
	string widtherr_name = sample+"_width_err"
	
	make/o/n=14 $width_name,  $widtherr_name
	ub(width_name+",get_info,avg")
	ub(widtherr_name+",get_info,sem")
	
	wave width = $width_name
	wave widtherr = $widtherr_name
end
	




//ub("naw,kfedc_akfef_error,202,212")
//ub("naw,kfedc_width_error,202,212")

//310K, 250K, 130, 110, 60

function tappend()
TextBox/C/N=text0/F=0/A=MC "60"
TextBox/C/N=text0/B=1/G=(65535,65535,65535)
TextBox/C/N=text0/X=40.00/Y=-40.00
end


function finalerror(samplename)
	string samplename
	string errname_1 = samplename + "_width_err"
	string errname_2 = "net_width_int_err_"+samplename
	string finalerr = samplename+"_width_errf"
	wave err1 = $errname_1
	wave err2 = $errname_2
	
	duplicate/o err1, $finalerr
	wave errf = $finalerr
	errf = sqrt(err1[p]^2+err2[p]^2)
end


function fig3()
	SetAxis bottom 50,320
	ModifyGraph gFont="Helvetica",gfSize=7
	ModifyGraph width=144,height=288,expand=2
	//Label left "A(k\\BF\\M, E\\BF\\M) (arb. unit)"
	ModifyGraph mirror=2,axThick=0.5,standoff=0,btLen=2,stLen=1;DelayUpdate
	ModifyGraph manTick(bottom)={50,50,0,0},manMinor(bottom)={1,0};DelayUpdate
	Label bottom "Temperature (K)";DelayUpdate
end


function AN_triple_plot_loop()
	string samplelist = "OP91;OD90;OD88;OD86;OD81;OD70" 
	string edcfromlist = "222;186;193;206;215;202"
	string edctolist = "232;196;203;216;225;212"
	
	string samplename
	variable edcfrom
	variable edcto
	
	
	variable index
	for(index=0;index<itemsinlist(samplelist);index+=1)
		samplename=stringfromlist(index,samplelist)
		edcfrom=str2num(stringfromlist(index,edcfromlist))
		edcto=str2num(stringfromlist(index,edctolist))
		// AN_triple_plot_int(samplename, edcfrom, edcto)
		 AN_triple_plot(samplename, edcfrom, edcto)
	endfor
	
	make/o/n=6 firstmoment_310K_all, EFratio_130K_all, dpratio_60K_all
	make/o/n=6 firstmoment_310K_error_all, EFratio_130K_error_all, dpratio_60K_error_all
	
	for(index=0;index<itemsinlist(samplelist);index+=1)
		samplename=stringfromlist(index,samplelist)
		wave firstmoment = $(samplename+"_firstmoment_310K")
		wave EFratio = $(samplename+"_EFratio_130K")
		wave dpratio = $(samplename+"_pdratio_60K")
		
		wavestats/Q firstmoment
		firstmoment_310K_all[index]=V_avg
		firstmoment_310K_error_all[index]=V_sdev
		
		wavestats/Q EFratio
		EFratio_130K_all[index]=V_avg
		EFratio_130K_error_all[index]=V_sdev
		
		wavestats/Q dpratio
		dpratio_60K_all[index]=V_avg
		dpratio_60K_error_all[index]=V_sdev
		
	endfor
	
	
	
end	

function AN_triple_plot(samplename, edcfrom, edcto)
	string samplename
	variable edcfrom
	variable edcto
	
	wave spec_60K=$(samplename+"_T60K")
	wave spec_90K=$(samplename+"_T90K")
	wave spec_130K=$(samplename+"_T130K")
	wave spec_310K=$(samplename+"_T310K")
	
	make/o/n=(edcto-edcfrom+1) $(samplename+"_firstmoment_310K"),$(samplename+"_EFratio_130K")
	
	make/o/n=(edcto-edcfrom+1) $(samplename+"_dipfrom"),$(samplename+"_dpmid"), $(samplename+"_peakto"),$(samplename+"_pdratio_60K")
	
	
	wave first_moment_310K = $(samplename+"_firstmoment_310K")
	wave EFratio_130K = $(samplename+"_EFratio_130K")
	
	wave Dipfrom_60K=$(samplename+"_dipfrom")
	wave dpmid_60K = $(samplename+"_dpmid")
	wave peakto_60K =$(samplename+"_peakto")
	wave pdratio_60K = $(samplename+"_pdratio_60K")
	
	variable index, energy
	variable dipfrom, dpmid, peakto
	for(index=edcfrom;index<edcto+1;index+=1)
		wave edc = slice_edc(spec_310K,num2str(index))
		rename edc, $("edc_310K_"+num2str(index))
		wave edc = slice_edc(spec_130K,num2str(index))
		rename edc, $("edc_130K_"+num2str(index))
		wave edc = slice_edc(spec_90K,num2str(index))
		rename edc, $("edc_90K_"+num2str(index))
		wave edc = slice_edc(spec_60K,num2str(index))
		rename edc, $("edc_60K_"+num2str(index))
		wave edc_310K=$("edc_310K_"+num2str(index))
		wave edc_130K=$("edc_130K_"+num2str(index))
		wave edc_90K=$("edc_90K_"+num2str(index))
		wave edc_60K=$("edc_60K_"+num2str(index))
		

		
		norm_by_area(edc_310K,"")
		norm_by_area(edc_130K,"")
		norm_by_area(edc_90K,"")
		norm_by_area(edc_60K,"")
		
		
		duplicate/O edc_60K, $("edc_60K_sub_"+num2str(index))
		wave edc_60K_sub = $("edc_60K_sub_"+num2str(index))
		
		first_moment_310K[index-edcfrom]=get_center(edc_310K,"-0.6,0")
		EFratio_130K[index-edcfrom]=1 - (edc_130K(0)/edc_310K(0))
		

		subtract_wave(edc_60K_sub, "edc_90K_"+num2str(index))
		
		for(energy=-0.20; energy<0;energy+=0.0005)
			if(find_noisy_crossing(edc_60K_sub,energy,-1))
				dipfrom=energy
				Dipfrom_60K[index-edcfrom]=energy
				break
			endif
		endfor
		
		for(energy=dipfrom; energy<0;energy+=0.0005)
			if(find_noisy_crossing(edc_60K_sub,energy,1))
				dpmid=energy
				Dpmid_60K[index-edcfrom]=energy
				break
			endif
		endfor
		
		for(energy=dpmid; energy<0;energy+=0.0005)
			if(find_noisy_crossing(edc_60K_sub,energy,-1))
				peakto=energy
				 peakto_60K[index-edcfrom]=energy
				break
			endif
		endfor		
		
		dipfrom= -0.12
		
		pdratio_60K[index-edcfrom]=area(edc_60K_sub,dipfrom,dpmid)/area(edc_60K_sub,dpmid,peakto)
		
		
		
		killwaves/Z edc_310K, edc_130K, edc_90K, edc_60K, edc_60K_sub, temp_edc
	endfor
end


function find_noisy_crossing(edc, energy, aboveorbelow)
	wave edc
	variable energy
	variable aboveorbelow//-1 means <0, 1 means >0
	variable crossing = 1
	
	variable index
	
	for(index=0;index<15;index+=1)
		if(edc(energy+index*0.001)*aboveorbelow<0)
			crossing = 0
			break
		endif
	endfor
	
	return crossing
end
	
	

function AN_triple_plot_int(samplename, edcfrom, edcto)
	string samplename
	variable edcfrom
	variable edcto
	
	wave spec_60K=$(samplename+"_T60K")
	wave spec_90K=$(samplename+"_T90K")
	wave spec_130K=$(samplename+"_T130K")
	wave spec_310K=$(samplename+"_T310K")
	
	make/o/n=1 $(samplename+"_firstmoment_310K"),$(samplename+"_EFratio_130K")
	
	make/o/n=1 $(samplename+"_dipfrom"),$(samplename+"_dpmid"), $(samplename+"_peakto"),$(samplename+"_pdratio_60K")
	
	
	wave first_moment_310K = $(samplename+"_firstmoment_310K")
	wave EFratio_130K = $(samplename+"_EFratio_130K")
	
	wave Dipfrom_60K=$(samplename+"_dipfrom")
	wave dpmid_60K = $(samplename+"_dpmid")
	wave peakto_60K =$(samplename+"_peakto")
	wave pdratio_60K = $(samplename+"_pdratio_60K")
	
	variable index, energy
	variable dipfrom, dpmid, peakto
	
	variable kfrom = dimoffset(spec_60K,0)+dimdelta(spec_60K,0)*edcfrom
	variable kto = dimoffset(spec_60K,0)+dimdelta(spec_60K,0)*(edcto+1)
	
	index=0
		wave edc = get_edc(spec_310K,num2str(kfrom)+","+num2str(kto))
		rename edc, $("edc_310K_"+num2str(index))
		wave edc =get_edc(spec_130K,num2str(kfrom)+","+num2str(kto))
		rename edc, $("edc_130K_"+num2str(index))
		wave edc = get_edc(spec_90K,num2str(kfrom)+","+num2str(kto))
		rename edc, $("edc_90K_"+num2str(index))
		wave edc = get_edc(spec_60K,num2str(kfrom)+","+num2str(kto))
		rename edc, $("edc_60K_"+num2str(index))
		wave edc_310K=$("edc_310K_"+num2str(index))
		wave edc_130K=$("edc_130K_"+num2str(index))
		wave edc_90K=$("edc_90K_"+num2str(index))
		wave edc_60K=$("edc_60K_"+num2str(index))
		

		
		norm_by_area(edc_310K,"")
		norm_by_area(edc_130K,"")
		norm_by_area(edc_90K,"")
		norm_by_area(edc_60K,"")
		
		
		duplicate/O edc_60K, $("edc_60K_sub_"+num2str(index))
		wave edc_60K_sub = $("edc_60K_sub_"+num2str(index))
		
		first_moment_310K[index]=get_center(edc_310K,"-0.6,0")
		EFratio_130K[index]=1 - (edc_130K(0)/edc_310K(0))
		

		subtract_wave(edc_60K_sub, "edc_90K_"+num2str(index))
		
		for(energy=-0.20; energy<0;energy+=0.0005)
			if(find_noisy_crossing(edc_60K_sub,energy,-1))
				dipfrom=energy
				Dipfrom_60K[index]=energy
				break
			endif
		endfor
		
		for(energy=dipfrom; energy<0;energy+=0.0005)
			if(find_noisy_crossing(edc_60K_sub,energy,1))
				dpmid=energy
				Dpmid_60K[index]=energy
				break
			endif
		endfor
		
		for(energy=dpmid; energy<0;energy+=0.0005)
			if(find_noisy_crossing(edc_60K_sub,energy,-1))
				peakto=energy
				 peakto_60K[index]=energy
				break
			endif
		endfor		
		dipfrom = -0.12
		print dipfrom, dpmid, peakto,"\r"
		

		pdratio_60K[index]=area(edc_60K_sub,dipfrom,dpmid)/area(edc_60K_sub,dpmid,peakto)
		
		
		killwaves/Z temp_edc
		killwaves/Z edc_310K, edc_130K, edc_90K, edc_60K, edc_60K_sub, temp_edc
	
end



function AN_triple_plot_v2(samplename, edcfrom, edcto)
	string samplename
	variable edcfrom
	variable edcto
	
	wave spec_60K=$(samplename+"_T60K")
	wave spec_90K=$(samplename+"_T90K")
	wave spec_130K=$(samplename+"_T130K")
	wave spec_310K=$(samplename+"_T310K")
	
	make/o/n=1 $(samplename+"_secondmoment_310K"),$(samplename+"_pg_130K"),$(samplename+"_gap_90K"),$(samplename+"_gap_60K")
	
	
	
	wave second_moment_310K = $(samplename+"_secondmoment_310K")
	wave pg_130K = $(samplename+"_pg_130K")
	wave gap_90K = $(samplename+"_gap_90K")
	wave gap_60K = $(samplename+"_gap_60K")
	
	variable index, energy

	
	variable kfrom = dimoffset(spec_60K,0)+dimdelta(spec_60K,0)*edcfrom
	variable kto = dimoffset(spec_60K,0)+dimdelta(spec_60K,0)*(edcto+1)
	
	index=0
		wave edc = get_edc(spec_310K,num2str(kfrom)+","+num2str(kto))
		rename edc, $("edc_310K_"+num2str(index))
		wave edc =get_edc(spec_130K,num2str(kfrom)+","+num2str(kto))
		rename edc, $("edc_130K_"+num2str(index))
		wave edc = get_edc(spec_90K,num2str(kfrom)+","+num2str(kto))
		rename edc, $("edc_90K_"+num2str(index))
		wave edc = get_edc(spec_60K,num2str(kfrom)+","+num2str(kto))
		rename edc, $("edc_60K_"+num2str(index))
		wave edc_310K=$("edc_310K_"+num2str(index))
		wave edc_130K=$("edc_130K_"+num2str(index))
		wave edc_90K=$("edc_90K_"+num2str(index))
		wave edc_60K=$("edc_60K_"+num2str(index))
		

		
		norm_by_area(edc_310K,"")
		norm_by_area(edc_130K,"")
		norm_by_area(edc_90K,"")
		norm_by_area(edc_60K,"")
		
		
		second_moment_310K[index]=get_variance(edc_310K,"-0.2,0")
		pg_130K[index]=get_maxloc(edc_130K,"-0.2,-0.01,5,10")
		gap_90K[index]=get_maxloc(edc_90K,"-0.2,0,5,10")
		gap_60K[index]=get_maxloc(edc_60K,"-0.2,0,5,10")
		
		
	
		killwaves/Z temp_edc
		killwaves/Z edc_310K, edc_130K, edc_90K, edc_60K, edc_60K_sub, temp_edc
	
end


function AN_triple_plot_singles_v2(samplename, edcfrom, edcto)
	string samplename
	variable edcfrom
	variable edcto
	
	wave spec_60K=$(samplename+"_T60K")
	wave spec_90K=$(samplename+"_T90K")
	wave spec_130K=$(samplename+"_T130K")
	wave spec_310K=$(samplename+"_T310K")
	
	
	make/o/n=(edcto-edcfrom+1) $(samplename+"_secondmoment_310K"),$(samplename+"_pg_130K"),$(samplename+"_gap_90K"),$(samplename+"_gap_60K")
	
	
	
	wave second_moment_310K = $(samplename+"_secondmoment_310K")
	wave pg_130K = $(samplename+"_pg_130K")
	wave gap_90K = $(samplename+"_gap_90K")
	wave gap_60K = $(samplename+"_gap_60K")
	
	
	variable index, energy

	for(index=edcfrom;index<edcto+1;index+=1)
		wave edc = slice_edc(spec_310K,num2str(index))
		rename edc, $("edc_310K_"+num2str(index))
		wave edc = slice_edc(spec_130K,num2str(index))
		rename edc, $("edc_130K_"+num2str(index))
		wave edc = slice_edc(spec_90K,num2str(index))
		rename edc, $("edc_90K_"+num2str(index))
		wave edc = slice_edc(spec_60K,num2str(index))
		rename edc, $("edc_60K_"+num2str(index))
		wave edc_310K=$("edc_310K_"+num2str(index))
		wave edc_130K=$("edc_130K_"+num2str(index))
		wave edc_90K=$("edc_90K_"+num2str(index))
		wave edc_60K=$("edc_60K_"+num2str(index))
		

		
		norm_by_area(edc_310K,"")
		norm_by_area(edc_130K,"")
		norm_by_area(edc_90K,"")
		norm_by_area(edc_60K,"")
		
		second_moment_310K[index-edcfrom]=get_variance(edc_310K,"-0.2,0")
		pg_130K[index-edcfrom]=get_maxloc(edc_130K,"-0.2,-0.01,0,0")
		gap_90K[index-edcfrom]=get_maxloc(edc_90K,"-0.2,0,0,0")
		gap_60K[index-edcfrom]=get_maxloc(edc_60K,"-0.2,0,0,0")
		
		
		killwaves/Z edc_310K, edc_130K, edc_90K, edc_60K, edc_60K_sub, temp_edc
	endfor
end



function AN_triple_plot_loop_v2()
	string samplelist = "OP91;OD90;OD88;OD86;OD81;OD70" 
	string edcfromlist = "222;186;193;206;215;202"
	string edctolist = "232;196;203;216;225;212"
	
	string samplename
	variable edcfrom
	variable edcto
	
	
	variable index
	for(index=0;index<itemsinlist(samplelist);index+=1)
		samplename=stringfromlist(index,samplelist)
		edcfrom=str2num(stringfromlist(index,edcfromlist))
		edcto=str2num(stringfromlist(index,edctolist))
		//AN_triple_plot_v2(samplename, edcfrom, edcto)
		 AN_triple_plot_singles_v2(samplename, edcfrom, edcto)
	endfor
	
	make/o/n=6 secondmoment_310K_all, pg_130K_all, gap_90K_all,gap_60K_all
	make/o/n=6 secondmoment_310K_error_all, pg_130K_error_all, gap_90K_error_all,gap_60K_error_all
	
	for(index=0;index<itemsinlist(samplelist);index+=1)
		samplename=stringfromlist(index,samplelist)
		wave second_moment_310K = $(samplename+"_secondmoment_310K")
		wave pg_130K = $(samplename+"_pg_130K")
		wave gap_90K = $(samplename+"_gap_90K")
		wave gap_60K = $(samplename+"_gap_60K")
	
		wavestats/Q second_moment_310K
		secondmoment_310K_all[index]=V_avg
		secondmoment_310K_error_all[index]=V_sdev
		
		wavestats/Q pg_130K
		pg_130K_all[index]=V_avg
		pg_130K_error_all[index]=V_sdev
		
		wavestats/Q gap_90K
		gap_90K_all[index]=V_avg
		gap_90K_error_all[index]=V_sdev
		
		wavestats/Q gap_60K
		gap_60K_all[index]=V_avg
		gap_60K_error_all[index]=V_sdev
	endfor
	
end	

function fullerror(errorwave,pl)
	wave errorwave
	string pl
	
	//settings:
	variable golderror = 0.001
	variable stepsize = 0.001
	//end settings
	string errorwave_name=nameofwave(errorwave)+"_full"
	duplicate/o errorwave $errorwave_name
	wave fullerror = $errorwave_name
	
	fullerror = sqrt((errorwave[p])^2+golderror^2+stepsize^2)
end


duplicate/o tfluc, gap_tfluc_ratio, gap_tfluc_ratio_error_T, gap_tfluc_ratio_error_g, gap_tfluc_ratio_error_all

gap_tfluc_ratio=eV2K(gap_60K_all[p]*2)/tfluc[p] 
gap_tfluc_ratio_error_T=eV2K(gap_60K_all[p]*2)/tfluc[p] - eV2K(gap_60K_all[p]*2)/(tfluc[p]+20)
gap_tfluc_ratio_error_g = eV2K(gap_60K_error_all_full[p])/tfluc[p]
gap_tfluc_ratio_error_all = sqrt(gap_tfluc_ratio_error_T[p]^2+gap_tfluc_ratio_error_g[p]^2)







ModifyGraph mode(shoulder_OD86_T90K_edc)=7,hbFill(shoulder_OD86_T90K_edc)=5;DelayUpdate
¥ModifyGraph useNegPat(shoulder_OD86_T90K_edc)=1
¥ModifyGraph mode(shoulder_OD86_T110K_edc)=7,hbFill(shoulder_OD86_T110K_edc)=5;DelayUpdate
¥ModifyGraph useNegPat(shoulder_OD86_T90K_edc)=1
¥ModifyGraph useNegPat(shoulder_OD86_T110K_edc)=1
¥ModifyGraph mode(shoulder_OD86_T130K_edc)=7,hbFill(shoulder_OD86_T130K_edc)=5;DelayUpdate
¥ModifyGraph useNegPat(shoulder_OD86_T130K_edc)=1,mode(shoulder_OD86_T150K_edc)=7;DelayUpdate
¥ModifyGraph hbFill(shoulder_OD86_T150K_edc)=5;DelayUpdate
¥ModifyGraph useNegPat(shoulder_OD86_T150K_edc)=1,mode(shoulder_OD86_T170K_edc)=7;DelayUpdate
¥ModifyGraph hbFill(shoulder_OD86_T170K_edc)=5;DelayUpdate
¥ModifyGraph useNegPat(shoulder_OD86_T170K_edc)=1


function shoulder_plot_v2(sample)
	string sample
	Display
	appendtograph $(sample+"_T90K_edc"),$(sample+"_T110K_edc"),$(sample+"_T130K_edc"),$(sample+"_T150K_edc"),$(sample+"_T170K_edc")
	appendtograph  $("bkg_"+sample+"_T90K_edc"),$("bkg_"+sample+"_T110K_edc"),$("bkg_"+sample+"_T130K_edc"),$("bkg_"+sample+"_T150K_edc"),$("bkg_"+sample+"_T170K_edc")
	appendtograph  $("fit_"+sample+"_T90K_edc"),$("fit_"+sample+"_T110K_edc"),$("fit_"+sample+"_T130K_edc"),$("fit_"+sample+"_T150K_edc"),$("fit_"+sample+"_T170K_edc")
	appendtograph  $("shoulder_"+sample+"_T90K_edc")
	wave range_10,range_120
	AppendToGraph/VERT range_10,range_120
	s_plot()
	
end	


//intensity2D()
	
temperature2D=(tem[p-1]+tem[p])/2
temperature2D[0]=temperature2D[1]*2-temperature2D[2]
doping2D=(doping[p-1]+doping[p])/2

doping2D[0]=doping2D[1]*2-doping2D[2]
