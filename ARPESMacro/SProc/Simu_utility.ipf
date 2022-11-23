#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function kk_imag2real(imag_wave, real_wave)
	//this function performs kk transformation of the imag_wave
	//results are saved in real_wave
	//the two waves must have the same size and scale
	//real(w)=1/pi*int(imag(x)/(x-w)dx)
	
	wave imag_wave, real_wave
	variable total_pnts=numpnts(imag_wave)
	
	variable index, sum_index, sum_value
	
	for(index=0;index<total_pnts;index+=1)
		sum_value=0
		if(mod(index,2)==0)
			for(sum_index=0;sum_index<floor(total_pnts/2);sum_index+=1)
				sum_value+=2*imag_wave[sum_index*2+1]/(sum_index*2+1-index)
			endfor
			real_wave[index]=sum_value/pi
		else
			for(sum_index=0;sum_index<floor((total_pnts-0.1)/2);sum_index+=1)
				sum_value+=2*imag_wave[sum_index*2]/(sum_index*2-index)
			endfor
			real_wave[index]=sum_value/pi
		endif
	endfor
end	

function kk_real2imag(real_wave, imag_wave)
	wave real_wave,imag_wave
	kk_imag2real(real_Wave,imag_wave)
	imag_wave*=-1
end



function kktest()
	make/o/n=2001 kk_imag
	setscale/I x,-1,1,kk_imag
	kk_imag=(abs(x)<0.035)?0:-58
	duplicate/o kk_imag,kk_real_1,kk_imag_2,kk_real_3,kk_imag_4,kk_real_5,kk_imag_6,kk_real_7,kk_imag_8,kk_real_9
	
	kk_imag2real(kk_imag,kk_real_1)
	kk_real2imag(kk_real_1,kk_imag_2)
	kk_imag2real(kk_imag_2,kk_real_3)


	kk_real2imag(kk_real_3,kk_imag_4)
	kk_imag2real(kk_imag_4,kk_real_5)
	kk_real2imag(kk_real_5,kk_imag_6)
	kk_imag2real(kk_imag_6,kk_real_7)
	kk_real2imag(kk_real_7,kk_imag_8)
	kk_imag2real(kk_imag_8,kk_real_9)
end	

ThreadSafe function cmplx_r(cmplx_num)
	variable/C cmplx_num
	return sqrt(magsqr(cmplx_num))
end

ThreadSafe function dirac_delta_approx(w)
//this function approximates the dirac delta function.
//alpha should be much larger than the grid interval but much smaller than other relevent physical quantities
//alpha too small: noise
//alpha too large: broadening
//alpha~edc delta
	variable w
	variable alpha=0.01
	return (1/(sqrt(pi)*alpha))*exp(-w^2/alpha^2)
end


ThreadSafe function dirac_delta_a(w,a)
//this function approximates the dirac delta function.
//alpha should be much larger than the grid interval but much smaller than other relevent physical quantities
	variable w
	variable a
	variable return_value
	if((w==a/2||(w<a/2))&&(w>-a/2))
		return_value=1/a
	else
		return_value=0
	endif
	return return_value
end

ThreadSafe function fd_f(w,T)
//fermi function
	variable w,T
	variable kb = 8.61733034e-5
	return 1/(exp(w/(kb*T))+1)
end

ThreadSafe function be_f(w,T)
//Bose-Einstein function
//w>0
	variable w,T
	variable kb = 8.61733034e-5
	return 1/(exp(w/(kb*T))-1)
end