#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//This file deals with simulations using various green's functions

function/C selfenergy_error_message(k,w)
	variable k,w
	print "function reference not defined.\r"
end

function bandstructure_error_message(k)
	variable k
	print "band structure not defined.\r"
end





Function/C mfl_se(k,w)
	variable k,w
	
	variable kb = 8.61733034e-5
	//settings
	variable lambda = 0.5 //coupling constant
	variable T = 10 //K
	variable T_coef = 1 //temperature coefficient a pi kb T
	variable cutoff_energy = 1 //eV
	//endsettings
	
	variable mflx=sqrt(w^2+(T_coef*pi*kb*T)^2)
	
	return lambda*cmplx(w*ln(mflx/cutoff_energy), pi*mflx/2)
end

Function AN_AB_band(k)
	variable k
	
	//settings
	variable bandbot = -0.02 //eV
	variable kf= 0.05 //1/A
	//endsettings
	
	return bandbot-bandbot*(k/kf)^2
end

Function normal_specfunc(selfE_function, band_function,k,w)
	string selfE_function, band_function
	variable k,w
	
	FuncRef selfenergy_error_message selfE=$selfE_function
	FuncRef bandstructure_error_message ek=$band_function
	
	variable/C se=selfE(k,w)
	variable spec=-(imag(se)/pi)/((w-ek(k)-real(se))^2+(imag(se))^2)
	
	return spec
end


Function nambu_G11(selfE_function, band_function, gap,k,w)
	string selfE_function, band_function
	variable gap,k,w
	
	FuncRef selfenergy_error_message selfE=$selfE_function
	FuncRef bandstructure_error_message ek=$band_function
	
	variable/C se=selfE(k,w)
	
	variable order=(1- real(se)/w)*gap
	
	variable/C G11=(w-se+ek(k))/((w-se)^2-(ek(k))^2-order^2)
	
	return -imag(G11)/pi
	
end