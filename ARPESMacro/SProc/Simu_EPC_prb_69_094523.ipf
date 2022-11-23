#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function Simu_EPC_set_parameters()
	variable/G gap = 0.040 //eV
	variable/G temperature = 25 //K
	variable/G kf = 0.2 //1/a, range is (0-pi)
	variable/G bandbot = -0.02 //eV
	variable/G epc_prefactor = 1
	variable/G Ephonon=0.035
end


function/C gkq_b1g(kx,ky,qx,qy)
//this function returns the matrix element of the electron-phonon interaction for the B1g phonon, 
//given by PRB 82,064513 equation 17
	variable kx, ky, qx, qy//wave vectors for the electron and the phonon, in units of 1/a
	
	variable prefactor
	
	nvar epc_prefactor
	
	prefactor = epc_prefactor
	
	
	variable Nq2=4*(cos(qx/2)^2+cos(qy/2)^2)
	if(Nq2==0)
		prefactor*=0
	else
		prefactor*=(Nq2^(-0.25))*(sin(kx/2)*sin((kx-qx)/2)*cos(qy/2)-sin(ky/2)*sin(ky/2-qy/2)*cos(qx/2))
	endif
	variable/C gkq=cmplx(cos(qx/2+qy/2),-sin(qx/2+qy/2))
	return gkq*prefactor
end

function gkqtest()
	make/o/n=(100,100) gkq_pi0
	setscale/I x,-pi,pi,gkq_pi0
	setscale/I y,-pi,pi,gkq_pi0
	duplicate/o gkq_pi0, gkq_00
	gkq_pi0=(cmplx_r(gkq_b1g(pi,0,x,y)))^2
	gkq_00=(cmplx_r(gkq_b1g(0,0,x,y)))^2
end

	
///////////////////////////////PHYSICAL REVIEW B 69, 094523 (2004)//////
////use delta function approx with alpha = 0.01
threadsafe function tb_band(kx,ky)
	variable kx, ky//kx, ky are numbers within (-pi,pi)
	
	//settings
	variable t=1
	variable t_1=-0.3*t
	variable mu=-1*t
	//end settings
	
	variable ek=-2*t*(cos(kx)+cos(ky))
	ek-=4*t_1*cos(kx)*cos(ky)
	ek-=mu
	
	return ek
end

threadsafe function d_gap(kx,ky)
	variable kx, ky
	
	//settings
	variable gapmax=0.2
	//end settings
	
	return gapmax*(cos(kx)-cos(ky))/2
end

function dos()
	variable kpnts=1000
	variable epnts=1000
	
	make/o/n=(kpnts,kpnts) temp_dos
	make/o/n=(epnts) dos_e
	
	setscale/I x,-pi,pi,temp_dos
	setscale/I y,-pi,pi,temp_dos
	setscale/I x,-2.5,6.5,dos_e
	
	variable index
	for(index=0;index<epnts;index+=1)
		multithread temp_dos=dirac_delta_approx(tb_band(x,y)-pnt2x(dos_e,index))
		dos_e[index]=mean(temp_dos)
		if(mod(index,100)==0)
			print index
		endif
	endfor
end

threadsafe function gk2_buckling(qx,qy)
	variable qx,qy
	
	variable g2=0.05
	
	return g2*((cos(qx/2))^2+(cos(qy/2))^2)
end
	
threadsafe function wZ2_0(kx,ky,kxp,kyp,w,Ephonon)
	variable kx,ky,kxp,kyp,w,Ephonon
	
	variable Ekp=sqrt((tb_band(kxp,kyp))^2+(d_gap(kxp,kyp))^2)
	variable dpm=dirac_delta_approx(Ekp+Ephonon-w)
	variable dpp=dirac_delta_approx(Ekp+Ephonon+w)
	
	return pi/2*gk2_buckling(kx-kxp,ky-kyp)*(dpm-dpp)
end

threadsafe function Chi2_0(kx,ky,kxp,kyp,w,Ephonon)
	variable kx,ky,kxp,kyp,w,Ephonon
	
	variable gapkp=d_gap(kxp,kyp)
	variable tbkp=tb_band(kxp,kyp)
	variable Ekp=sqrt(gapkp^2+tbkp^2)
	variable dpm=dirac_delta_approx(Ekp+Ephonon-w)
	variable dpp=dirac_delta_approx(Ekp+Ephonon+w)
	
	return -pi/2*gk2_buckling(kx-kxp,ky-kyp)*(dpm+dpp)*tbkp/Ekp
end

threadsafe function phi2_0(kx,ky,kxp,kyp,w,Ephonon)
	variable kx,ky,kxp,kyp,w,Ephonon
	
	variable gapkp=d_gap(kxp,kyp)
	variable tbkp=tb_band(kxp,kyp)
	variable Ekp=sqrt(gapkp^2+tbkp^2)
	variable dpm=dirac_delta_approx(Ekp+Ephonon-w)
	variable dpp=dirac_delta_approx(Ekp+Ephonon+w)
	
	return pi/2*gk2_buckling(kx-kxp,ky-kyp)*(dpm+dpp)*gapkp/Ekp
end



function main_op()
	variable kpnts=1000
	variable epnts=200
	
	make/o/n=(kpnts,kpnts) temp_k
	make/o/n=(epnts) wZ2_AN
	
	setscale/I x,-pi,pi,temp_k
	setscale/I y,-pi,pi,temp_k
	setscale/I x,0.001,2,wZ2_AN
	duplicate/o wZ2_AN,Z2_AN, chi2_AN, phi2_AN
	
	
	variable kx=0.35536
	variable ky=pi
	variable Ephonon=0.3
	
	variable index
	for(index=0;index<epnts;index+=1)
		multithread temp_k=wZ2_0(kx,ky,x,y,pnt2x(wZ2_AN,index),Ephonon)
		wZ2_AN[index]=mean(temp_k)
		
		multithread temp_k=chi2_0(kx,ky,x,y,pnt2x(chi2_AN,index),Ephonon)
		chi2_AN[index]=mean(temp_k)
		
		multithread temp_k=phi2_0(kx,ky,x,y,pnt2x(phi2_AN,index),Ephonon)
		phi2_AN[index]=mean(temp_k)
		
		if(mod(index,10)==0)
			print index
		endif
	endfor
	
	Z2_AN=wZ2_AN[p]/x
	
	make/o/n=(epnts*2) wZ2_full
	setscale/I x,-2,2,wZ2_full
	
	duplicate/o wZ2_full, chi2_full, phi2_full,chi1_full, phi1_full,wZ1_full
	wZ2_full=(x>0)?wZ2_AN(x):wZ2_AN(-x)
	
	chi2_full=(x>0)?chi2_AN(x):(-chi2_AN(-x))
	phi2_full=(x>0)?phi2_AN(x):(-phi2_AN(-x))
	kk_imag2real(chi2_full,chi1_full)
	kk_imag2real(phi2_full,phi1_full)
	kk_imag2real(wZ2_full,wZ1_full)
	
	wZ1_full+=x
	duplicate/o wZ1_full Z1m1_full
	Z1m1_full=wZ1_full[p]/x-1
	//offset the chemical potential shift in chi
	variable offset=chi1_full(0)
	chi1_full-=offset
	//real part of the gap at the gapedge is gapk
	variable gapedge = d_gap(kx,ky)
	offset = phi1_full(gapedge)-(wZ1_full(gapedge)^2+wZ2_full(gapedge)^2-phi2_full(gapedge)*wZ2_full(gapedge))/wZ1_full(gapedge)
	phi1_full-=offset
	
	make/C/o/n=(epnts*2) g_cmplx,Z_cmplx,chi_cmplx,phi_cmplx
	setscale/I x,-2,2,g_cmplx,Z_cmplx,chi_cmplx,phi_cmplx
	
	Z_cmplx=cmplx(wZ1_full[p]/x,wZ2_full[p]/x)
	chi_cmplx=cmplx(chi1_full,chi2_full)
	phi_cmplx=cmplx(phi1_full[p],phi2_full[p])
	
	variable i0=0.01//without this we lose the pole.
	
	g_cmplx=(Z_cmplx[p]*cmplx(x,i0)+Chi_cmplx[p]+tb_band(kx,ky))/((Z_cmplx[p]*cmplx(x,i0))^2-(Chi_cmplx[p]+tb_band(kx,ky))^2-phi_cmplx[p]^2)
	
	duplicate/o wZ1_full, spec_full
	spec_full=-Imag(g_cmplx[p])/pi
end