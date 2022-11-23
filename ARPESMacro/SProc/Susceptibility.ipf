#pragma rtGlobals=3		// Use modern global access method and strict wave access.


function suscep()

//wave Temperature__K_
//wave AC_X____emu_Oe_


	wave temperature = Temperature__K_
	wave chi = AC_X____emu_Oe_

	//wave temperature = root:MPMS:OD80_MH_DC:OD80_Temperature
	//wave chi = root:MPMS:OD80_MH_DC:OD80_Long_Moment

	variable pfrom
	if(wavemin(temperature)>50)
		pfrom = 0
	else
		pfrom = 0
		do
			if(temperature[pfrom]>50)
				break
			endif
			pfrom+=1
		while(pfrom <1000)
	endif
	
	duplicate/o/R=[pfrom, inf] temperature, T_temp
	duplicate/o/R=[pfrom, inf] chi, chi_temp
	
	variable dvd = wavemin(chi_temp)
	chi_temp/=dvd
	
	variable transition_5 = interp(0.05, chi_temp,T_temp)
	variable transition_10 = interp(0.1, chi_temp,T_temp)
	variable transition_20 = interp(0.2, chi_temp,T_temp)
	variable transition_50 = interp(0.5, chi_temp,T_temp)
	variable transition_80 = interp(0.8, chi_temp,T_temp)
	variable transition_90 = interp(0.9, chi_temp,T_temp)
	variable transition_95 = interp(0.95, chi_temp,T_temp)
	
	print transition_5
	print transition_10
	print transition_20
	print transition_50
	print transition_80
	print transition_90
	print transition_95
end
