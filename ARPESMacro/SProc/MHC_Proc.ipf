#pragma rtGlobals=3		// Use modern global access method and strict wave access.


Function InitializeMHExpansionFit(edc)
wave edc

duplicate/O edc edc_x,edc_d,edc_log
edc_x=x
edc_d=NaN
edc_log=log(edc[p])
make/o/n=2000 wFit
setscale/I x,-0.5,0.5, wFit
duplicate/O wFit, wtFit

wtFit=interp(x, edc_x, edc)
make/o/n=1001 wGaussian, wLorentz,wprofile
setscale/P x,-500*dimdelta(wFit,0),dimdelta(wFit,0), wGaussian, wLorentz,wprofile

make/o/n=14 para={0.0385666,-0.146241,0,10,0.01,0.0036,		0.033,0.041,0.03,0.02,0, 	0.00,0.015,0.005}
make/T/o/n=14 T_para={"FDConstant","FDSlope","FDChemicalPotential","FDTemperature","Resolution","Constantbkg","LGIntensity","LGPosition","LGWidthL","LGWidthG","LGAsymmetry",  "2nd_intensity","2nd_position","2nd_width"}

para[0]=2*wtfit(-0.1)-wtfit(-0.2)
para[1]=-(wtfit(-0.2)-wtfit(-0.1))/0.1
para[2]=0
para[3]=get_info(edc,"SampleTemperature")
para[5]=wtfit(0.2)
end



Function MHExpansionFunction(pw, yw, xw) : FitFunc
//pw[0]=FD Constant
//pw[1]=FD slope
//pw[2]=FD Chemical potential
//pw[3]=FD temperature

//pw[4]=analyzer resolution
//pw[5]=constant bkg

//pw[6]= Lor+Gauss BG intensity
//pw[7]= Lor+Gauss BG position
//pw[8]= Lor+Gauss BG Lor width
//pw[9]= Lor+Gauss BG  Gauss width
//pw[10]= LG asymmetry

//pw[11]= 2nd Gauss intensity
//pw[12]= 2nd Gauss position
//pw[13]= 2nd Gauss width
//==========these parameters are not used==========
//pw[13]= 3rd Gauss intensity
//pw[14]= 3rd Gauss position
//pw[15]= 3rd Gauss width

//pw[16]= 4th Gauss intensity
//pw[17]= 4th Gauss position
//pw[18]= 4th Gauss width

//pw[19]= 4th Gauss intensity
//pw[20]= 4th Gauss position
//pw[21]= 4th Gauss width

//pw[22]= 4th Gauss intensity
//pw[23]= 4th Gauss position
//pw[24]= 4th Gauss width
//==========these parameters are not used==========

Wave pw, yw, xw

Wave wFit
Wave wtFit
Wave wGaussian
Wave wLorentz
Wave wProfile
Variable kB=8.617342e-5

wFit= (pw[0] + pw[1] * x)/(exp((x-pw[2])/(kB*pw[3]))+1)+pw[5]



wGaussian= Gauss(x, 0, pw[4]/(2*(sqrt(2*ln(2)))))*DimDelta(wGaussian,0)
convolve/A wGaussian, wFit


wGaussian=Gauss(x, 0, pw[9]/(2*(sqrt(2*ln(2)))))*DimDelta(wGaussian,0)
wLorentz=pw[6]*(pw[8]/(2*pi)) / ((x-pw[7])^2+pw[8]^2/4)*DimDelta(wLorentz,0)
convolve/A wGaussian, wLorentz

wLorentz*=(1+pw[10]*(x-pw[7]))


wProfile=wLorentz(x)

wGaussian=pw[11]*Gauss(x, pw[12], pw[13]/(2*(sqrt(2*ln(2)))))*DimDelta(wGaussian,0)
wProfile+=wGaussian[p]
////
//wGaussian=pw[13]*Gauss(x, pw[14], pw[15]/(2*(sqrt(2*ln(2)))))*DimDelta(wGaussian,0)
//wProfile+=wGaussian[p]
//
//wGaussian=pw[16]*Gauss(x, pw[17], pw[18]/(2*(sqrt(2*ln(2)))))*DimDelta(wGaussian,0)
//wProfile+=wGaussian[p]
//
//wGaussian=pw[19]*Gauss(x, pw[20], pw[21]/(2*(sqrt(2*ln(2)))))*DimDelta(wGaussian,0)
//wProfile+=wGaussian[p]
//
//wGaussian=pw[22]*Gauss(x, pw[23], pw[24]/(2*(sqrt(2*ln(2)))))*DimDelta(wGaussian,0)
//wProfile+=wGaussian[p]

variable index
duplicate/o wtFit wtFit_temp
wave wtFit_temp


for(index=0;index<5;index+=1)
	convolve/A wProfile, wtFit_temp
	wFit+=((-1)^index)*wtFit_temp(x)
endfor

yw=wFit(xw[p])
//yw=log(wFit(xw[p]))
End



//plot curve generated by parameters in para
MHExpansionFunction(para,edc_d ,edc_x)



///////////////procedure////////////////

//edit first and last point of edc to make the interp smooth
//rename the wave to "edc"
InitializeMHExpansionFit(edc)
//fill in all NaN in wtfit by extrapolating the gold edc
//remember to check if wtfit agrees with edc

//change para wave according to edc, especially temperature

//fit with wprofile=0
//"FDConstant","FDSlope","FDChemicalPotential","FDTemperature","Resolution","Constantbkg","LGIntensity","LGPosition","LGWidthL","LGWidthG","LGAsymmetry",  "2nd_intensity","2nd_position","2nd_width"




FuncFit/n/q/H="00110011111111"  MHExpansionFunction,para,edc(-0.05,0.05)/D=edc_d
//fit wprofile between -0.01 and 0.15, with log or weight
FuncFit/n/q/H="00110000001111"  MHExpansionFunction,para,edc(-0.05,0.15)/W=edc/I=1/D=edc_d
FuncFit/n/q/H="00110000001111"  MHExpansionFunction,para,edc(-0.05,0.15)/W=edc/I=1/D=edc_d
//FuncFit/n/q/H="0011000000"  MHExpansionFunction_log,para,edc_log(-0.05,0.15)/D=edc_d