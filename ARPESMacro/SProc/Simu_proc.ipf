#pragma rtGlobals=3		// Use modern global access method and strict wave access.


function reso_effect()
	//settings:
	variable edc_width = 0.0500
	variable resolution = 0.050
	variable temperature = 60
	variable bkg = 0
	string bilayer = ""
	//end settings
	
	string name = "edcw"+num2str(1000*edc_width)+"_reso"+num2str(1000*resolution)+"_T"+num2str(temperature)+"_bkg"+num2str(bkg)
	name+="_bi"+bilayer
	
	newdatafolder/o/s  $name
	
	make/o/n=1000 edc
	setscale/I x, -0.3,0.3,edc
	
	duplicate/o edc, edc_FD, edc_FD_conv, FD_original, FD_conv, edc_FD_conv_divFD
	
	edc = bkg + edc_width^2/(x^2+edc_width^2) 
	
	if(stringmatch(bilayer, "yes"))
		edc += edc_width^2/((x-0.170)^2+edc_width^2)
	endif
	
	edc_FD = edc[p]*FD(x, temperature)
	
	edc_FD_conv = edc_FD[p]
	conv_reso(edc_FD_conv, num2str(resolution))
	
	FD_original = FD(x, temperature)
	
	FD_conv = FD_original[p]
	conv_reso(FD_conv, num2str(resolution))
	
	edc_FD_conv_divFD = edc_FD_conv[p]/FD_conv[p]
	
	display;
	Appendtograph edc, edc_FD, edc_FD_conv, edc_FD_conv_divFD
	setaxis left 0, wavemax(edc)
	Legend/C/N=text0/F=0/A=MC
	GP_DifferentColors()
	TextBox/C/N=text1/F=0/A=MC name
	ModifyGraph zero(bottom)=1
	ModifyGraph width=288,height=576
	TextBox/C/N=text1/X=-10.00/Y=50.00
	Legend/C/N=text0/J/X=-20.00/Y=-40.00
	setdatafolder root:
end