#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function self_Re(form, w, T, a, b)
	//return the real part of the self energy
	string form
	variable w, T, a, b
	
	variable kb = 8.61733034e-5
	
	if(stringmatch(form, "FL"))
		return a*w
	endif
	
	//in case of mfl, a is lambda, b is wc
	if(stringmatch(form,"MFL"))
		return a*w*ln(max(abs(w),kb*T)/b)
	endif
end

function self_Im(form, w, T, a, b)
	//return the real part of the self energy
	string form
	variable w, T, a, b
	
	variable kb = 8.61733034e-5
	
	if(stringmatch(form, "FL"))
		return -b*(w^2 + (pi*kb*T)^2)
	endif
	
	//in case of mfl, a is lambda, b is wc
	if(stringmatch(form,"MFL"))
		return -a*pi*max(abs(w),kb*T)/2
	endif
end

function band(a,b,k)
	//return e_k
	variable a,b,k
	return a*(k^2)+b
end



function spectra(k,w,T)
	variable k,w,T
	//begin settings
	variable bandbottom = -0.2
	variable invmass = -bandbottom/(3^2)
	
	variable fl_a = 1
	variable fl_b = 2
	string form = "MFL"
	
	variable defect = 0.01
	//end settings
	
	variable re = 0//self_Re(form, w, T, fl_a, fl_b)
	variable im = self_Im(form, w, T, fl_a, fl_b)
	variable ek = band(invmass,bandbottom,k)
	
	variable intensity = (1/pi)*(abs(im) + defect)/((w-ek-re)^2+(abs(im) + defect)^2)//*fd(w,T)
	
	return intensity
end


function simu_main()
	make/o/n=(400,1000) AN_spec
	setscale/I x,-10,10, AN_spec
	setscale/I y,-0.85,0.2, AN_spec
	
	AN_spec = spectra(x,y,300)
end