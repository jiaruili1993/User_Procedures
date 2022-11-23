#pragma rtGlobals=3		// Use modern global access method and strict wave access.


Function BCS_gap_function(T, A, B)
//takes temperature and gives gap size
	variable T
	variable A	//1/N(0)V
	variable B	//hbar wc debye frequency
	
	
	//integration steps
	variable n = 1000
	variable m = 1000//gap steps
	variable gap_max =200*B
	
	make/o/n=(n) int_wave
	setscale/P x, B/n, B/n, int_wave
	
	variable gap, integration
	variable solution_exist = 0

	for(gap=0; gap<gap_max; gap+=gap_max/m)
		int_wave = tanh(sqrt(x^2+gap^2)/(2*T))/sqrt(x^2+gap^2)
		integration = sum(int_wave)*(B/n)/A
		if(integration<1)
			solution_exist = 1
			break
		endif
	endfor
	if(solution_exist)
		return gap
	else
		return NaN
	endif
end

duplicate gap_vs_T_B15, gap_vs_T_2


