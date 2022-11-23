#pragma rtGlobals=3		// Use modern global access method and strict wave access.


	
///////////////////////////////Followup of Yu's simulation in his Science supporting materials//////
////use delta function approx with alpha = 0.01
threadsafe function tb_band(kx,ky)
	variable kx, ky//kx, ky are numbers within (-pi,pi)
	
	//settings
	variable t=1.26
	variable t_1=-0.53
	variable mu=-2.1
	//end settings
	
	variable ek=-2*t*(cos(kx)+cos(ky))
	ek-=4*t_1*cos(kx)*cos(ky)
	ek-=mu
	//ek*=1+14*(sin(sqrt((kx^2+ky^2)/8)))^6
	
	return ek
end

function tb_band_test()
	make/o/n=1000 cut_pi0,cut_pipi
	setscale/I x,-pi,pi,cut_pi0,cut_pipi
	cut_pi0=tb_band(pi,x)
	cut_pipi=tb_band(x,x)
	
	make/o/n=(1000,1000) FS_dos
	setscale/I x,-pi,pi,FS_dos
	setscale/I y,-pi,pi,FS_dos
	
	FS_dos=dirac_delta_approx(tb_band(x,y))
end

threadsafe function d_gap(kx,ky,gapmax)
	variable kx, ky,gapmax
	
	return gapmax*(cos(kx)-cos(ky))/2
end

function dos()
	variable kpnts=1000
	variable epnts=1000
	
	make/o/n=(kpnts,kpnts) temp_dos
	make/o/n=(epnts) dos_e
	
	setscale/I x,-pi,pi,temp_dos
	setscale/I y,-pi,pi,temp_dos
	setscale/I x,-0.5,0.5,dos_e
	
	variable index
	for(index=0;index<epnts;index+=1)
		multithread temp_dos=dirac_delta_approx(tb_band(x,y)-pnt2x(dos_e,index))
		dos_e[index]=mean(temp_dos)
		if(mod(index,100)==0)
			print index
		endif
	endfor
	
	duplicate/o dos_e, filling_e
	filling_e=area(dos_e,-inf,x)
end

threadsafe function gkq2_b1g(kx,ky,qx,qy,g)
//this function returns the matrix element of the electron-phonon interaction for the B1g phonon, 
//given by PRB 82,064513 equation 17
	variable kx, ky, qx, qy//wave vectors for the electron and the phonon, in units of 1/a
	//electron at k emits phonon q and becomes electron at k-q
	variable g
	
	variable gkq=g*(sin(kx/2)*sin((kx-qx)/2)*cos(qy/2)-sin(ky/2)*sin(ky/2-qy/2)*cos(qx/2))
	
	return gkq^2
end

function gkq2_test()

	variable g=0.5
	
	make/o/n=(1000,1000) gkq_test_pi0, gkq_test_00,gkq_test_pipi
	setscale/I x,-pi,pi,gkq_test_pi0, gkq_test_00,gkq_test_pipi
	setscale/I y,-pi,pi,gkq_test_pi0, gkq_test_00,gkq_test_pipi
	
	gkq_test_pi0=gkq2_b1g(pi,0,x,y,g)
	gkq_test_00=gkq2_b1g(0,0,x,y,g)
	gkq_test_pipi=gkq2_b1g(pi,pi,x,y,g)
end


threadsafe function wZ2(kx,ky,kxp,kyp,w,Ephonon,g,gap,T)
	variable kx,ky,kxp,kyp,w,Ephonon,g,gap,T
	
	variable qx=kx-kxp
	variable qy=ky-kyp
	
	variable Ekp=sqrt((tb_band(kxp,kyp))^2+(d_gap(kxp,kyp,gap))^2)
	variable g2=gkq2_b1g(kx,ky,qx,qy,g)
	
	variable dpp=dirac_delta_approx(w+Ephonon+Ekp)
	variable dmm=dirac_delta_approx(w-Ephonon-Ekp)
	variable dpm=dirac_delta_approx(w+Ephonon-Ekp)
	variable dmp=dirac_delta_approx(w-Ephonon+Ekp)
	
	variable wZ2_return=(be_f(Ephonon,T)+fd_f(Ekp,T))*(dpm+dmp)
	wZ2_return+=(be_f(Ephonon,T)+fd_f(-Ekp,T))*(dmm+dpp)
	wZ2_return*=pi*g2/2
	return wZ2_return
end


threadsafe function chi2(kx,ky,kxp,kyp,w,Ephonon,g,gap,T)
	variable kx,ky,kxp,kyp,w,Ephonon,g,gap,T
	
	variable qx=kx-kxp
	variable qy=ky-kyp
	
	variable epsilonkp=tb_band(kxp,kyp)
	variable gapkp=d_gap(kxp,kyp,gap)
	variable Ekp=sqrt(epsilonkp^2+gapkp^2)

	variable g2=gkq2_b1g(kx,ky,qx,qy,g)
	
	variable dpp=dirac_delta_approx(w+Ephonon+Ekp)
	variable dmm=dirac_delta_approx(w-Ephonon-Ekp)
	variable dpm=dirac_delta_approx(w+Ephonon-Ekp)
	variable dmp=dirac_delta_approx(w-Ephonon+Ekp)
	
	variable chi2_return=(be_f(Ephonon,T)+fd_f(Ekp,T))*(dpm-dmp)
	chi2_return+=(be_f(Ephonon,T)+fd_f(-Ekp,T))*(dmm-dpp)
	chi2_return*=-pi*g2*epsilonkp/(2*Ekp)
	return chi2_return
end


threadsafe function phi2(kx,ky,kxp,kyp,w,Ephonon,g,gap,T)
	variable kx,ky,kxp,kyp,w,Ephonon,g,gap,T
	
	variable qx=kx-kxp
	variable qy=ky-kyp
	
	variable epsilonkp=tb_band(kxp,kyp)
	variable gapkp=d_gap(kxp,kyp,gap)
	variable Ekp=sqrt(epsilonkp^2+gapkp^2)

	variable g2=gkq2_b1g(kx,ky,qx,qy,g)
	
	variable dpp=dirac_delta_approx(w+Ephonon+Ekp)
	variable dmm=dirac_delta_approx(w-Ephonon-Ekp)
	variable dpm=dirac_delta_approx(w+Ephonon-Ekp)
	variable dmp=dirac_delta_approx(w-Ephonon+Ekp)
	
	variable phi2_return=(be_f(Ephonon,T)+fd_f(Ekp,T))*(dpm-dmp)
	phi2_return+=(be_f(Ephonon,T)+fd_f(-Ekp,T))*(dmm-dpp)
	phi2_return*=pi*g2*gapkp/(2*Ekp)
	
	return phi2_return
end

function main_op(gapsize, temperature,gkq_prefactor)
	variable gapsize// = 0.001 //eV
	variable temperature //= 30 //K
	variable gkq_prefactor// = 0.5
	variable phonon_energy=0.035
	
	variable kx=pi
	variable ky=0.093

	variable kpnts=1000
	variable epnts=400
	
	string notestr="gapsize" +num2str(gapsize*1000)
	notestr+="T"+num2str(temperature)
	notestr+="g"+num2str(gkq_prefactor)
	string namestr=cleanupname(notestr,0)
	 
	
	newdatafolder/o/s $("root:"+namestr)
	
	
	
	notestr+="Ephonon"+num2str(phonon_energy)
	notestr+="kx"+num2str(kx)
	notestr+="ky"+num2str(ky)
	
	make/o/n=(kpnts,kpnts) temp_k
	make/o/n=(epnts) wZ2_ANkf
	
	setscale/I x,-pi,pi,temp_k
	setscale/I y,-pi,pi,temp_k
	setscale/I x,0.0005,0.4005,wZ2_Ankf
	duplicate/o wZ2_ANkf,Z2_ANkf, chi2_ANkf, phi2_ANkf
	
	
	make/o/n=(epnts*2) wZ2_ANkf_all
	setscale/I x,-0.4005,0.4005,wZ2_ANkf_all
	duplicate/o wZ2_ANkf_all, wZ1_ANkf_all,phi2_ANkf_all, phi1_ANkf_all,chi2_ANkf_all, chi1_ANkf_all,edc_all
	
	note/K edc_all,notestr
	
	
	variable index
	for(index=0;index<epnts;index+=1)
		multithread temp_k=wZ2(kx,ky,x,y,pnt2x(wZ2_ANkf,index),phonon_energy,gkq_prefactor,gapsize,temperature)
		wZ2_ANkf[index]=mean(temp_k)
		
		multithread temp_k=chi2(kx,ky,x,y,pnt2x(wZ2_ANkf,index),phonon_energy,gkq_prefactor,gapsize,temperature)
		chi2_ANkf[index]=mean(temp_k)
		if(gapsize!=0)
			multithread temp_k=phi2(kx,ky,x,y,pnt2x(wZ2_ANkf,index),phonon_energy,gkq_prefactor,gapsize,temperature)
			phi2_ANkf[index]=mean(temp_k)
		else
			phi2_ANkf[index]=0
		endif

		if(mod(index,20)==0)
			print index/400
		endif
	endfor	
	
	Z2_ANkf=wZ2_ANkf[p]/x
	
	wZ2_ANkf_all=(x>0)?wZ2_ANkf(x):wZ2_ANkf(-x)
	
	chi2_ANkf_all=(x>0)?chi2_ANkf(x):(-chi2_ANkf(-x))
	phi2_ANkf_all=(x>0)?phi2_ANkf(x):(-phi2_ANkf(-x))
	
	kk_imag2real(chi2_ANkf_all,chi1_ANkf_all)
	kk_imag2real(phi2_ANkf_all,phi1_ANkf_all)
	kk_imag2real(wZ2_ANkf_all,wZ1_ANkf_all)
	
	
	wZ1_ANkf_all+=x
	
	variable offset=chi1_ANkf_all(0)
	chi1_ANkf_all-=offset
	variable gapedge = d_gap(kx,ky,gapsize)
	//real part of the gap at the gapedge is gapk
	if(gapsize!=0)
		offset = phi1_ANkf_all(gapedge)-(wZ1_ANkf_all(gapedge)^2+wZ2_ANkf_all(gapedge)^2-phi2_ANkf_all(gapedge)*wZ2_ANkf_all(gapedge))/wZ1_ANkf_all(gapedge)
		phi1_ANkf_all-=offset
	else
		phi1_ANkf_all=0
		phi2_ANkf_all=0
	endif
	
	
	make/C/o/n=(epnts*2) g_cmplx,Z_cmplx,chi_cmplx,phi_cmplx
	setscale/I x,-0.4005,0.4005,g_cmplx,Z_cmplx,chi_cmplx,phi_cmplx
	
	Z_cmplx=cmplx(wZ1_ANkf_all[p]/x,wZ2_ANkf_all[p]/x)
	chi_cmplx=cmplx(chi1_ANkf_all,chi2_ANkf_all)
	phi_cmplx=cmplx(phi1_ANkf_all[p],phi2_ANkf_all[p])
	
	variable i0=0.001//without this we lose the pole.
	if(gapsize!=0)
		g_cmplx=(Z_cmplx[p]*cmplx(x,i0)+Chi_cmplx[p]+tb_band(kx,ky))/((Z_cmplx[p]*cmplx(x,i0))^2-(Chi_cmplx[p]+tb_band(kx,ky))^2-phi_cmplx[p]^2)
	else
		g_cmplx=1/(cmplx(wZ1_ANkf_all[p],wZ2_ANkf_all[p])-chi_cmplx[p])
	endif
	
	edc_all=-imag(g_cmplx[p])/pi
	rename edc_all, $namestr
end

function op_loop()
	variable gap=0
	variable temperature = 30
	variable g=0.2
	for(gap=0.005;gap<0.036;gap+=0.005)
		main_op(gap, temperature,g)
	endfor
	
end