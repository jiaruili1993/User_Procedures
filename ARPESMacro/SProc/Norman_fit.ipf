#pragma rtGlobals=3		// Use modern global access method and strict wave access.



Function Initialize_norman_fit(edc)

wave edc
make/o/n=7 para={0.04,0,0,0.01,0.0003,0.01,0.003,61}
make/T/o/n=7 T_para={"gap","Ek","G0","G1","intensity","resolution","bkg","tem"}
duplicate/O edc edc_x,edc_d
edc_x=x
edc_d=NaN
make/o/n=2000 wFit
setscale/I x,-0.5,0.5,wFit
duplicate/o wFit, Re_Sigma,Im_Sigma

wFit=interp(x, edc_x, edc)

make/o/n=601 wGaussian
setscale/P x,-300*dimdelta(wFit,0),dimdelta(wFit,0), wGaussian

end

Function Norman_bqp_fit(pw,yw,xw): FitFunc
//pw[0]=gap
//pw[1]=Ek
//pw[2]=G0
//pw[3]=G1
//pw[4]=intensity
//pw[5]=resolution
//pw[6]=bkg
//pw[7]=tem
wave pw,yw,xw
wave wFit
wave wGaussian
wave Re_sigma,Im_Sigma
variable kB=8.617342e-5


wGaussian= Gauss(x, 0, pw[5]/(2*(sqrt(2*ln(2)))))*DimDelta(wGaussian,0)
Re_sigma=pw[0]^2*(x+pw[1])/((x+pw[1])^2+pw[2]^2)
Im_sigma=-pw[3]-pw[0]^2*pw[2]/((x+pw[1])^2+pw[2]^2)

wFit=(-pw[4]*pi*Im_sigma[p]/((x-pw[1]-Re_sigma[p])^2+Im_sigma[p]^2)+pw[6])/(exp(x/(kB*pw[7]))+1)
convolve/A wGaussian, wFit

yw=wFit(xw[p])

end


Norman_bqp_fit(para,edc_d,edc_x)
FuncFit/n/q/H="10100101"  Norman_bqp_fit,para,edc(-0.08,0.08)/D=edc_d

Function norman_fit_batch(edc,placeholder)
wave edc
string placeholder

wave para
wave edc_d
Initialize_norman_fit(edc)
FuncFit/n/q/H="00100101"  Norman_bqp_fit,para,edc(-0.08,0.08)/D=edc_d

return para[0]
end