#pragma rtGlobals=1		// Use modern global access method.

Function init_special_function() // This function is used to creat a folder to store related waves and variable generate when evaluating the special function
							//It will be called in "i_init"

	String DF = GetDataFolder (1)
	
	SetdataFolder root:internalUse
	NewDatafolder/o/s Special_Function
	
	//The following are for cEllipK(m) , the Complete elliptic integral of the first type
	make/O/C/N=100 K_wave                // change N to change the precission,
	make /O/N=100 Re, Im
	
	SetDataFolder $DF
End

// The Complete Elliptic Function of the first type K.
// The accuracy is not very good up to 2 or 3 decimal. Compared to the value given by Mathematica 5
//This is written in a somewhat stipid way. It look for a better way to calculate it

Function/C EllipK(n)
variable n
	
	String DF = GetDataFolder (1)
	SetdataFolder root:internalUse:Special_Function
	
	variable m=n
	variable Re, Im, TINY=1e-6        // This might be the reason of the inaccuracy
	variable x_c=asin(sqrt(1/m))
	if (m<1)
 		Re = integrate1D(Ellip_ReK,0,pi/2,1)
 		Im=0
 	elseif (m-1 < 1.0e-3)
 		m=1-abs(m-1) // when m~1, Re(K) is symmetric with respect to m=1 and IGor seems to be more tolorable in the m<1 side. This is assuming Mathematica 5 is correct!
 		Re = integrate1D(Ellip_ReK, 0,pi/2,1)
 		m=n
 		Im = 1.570  //Use the value calculate from Mathematica 5
 	else
		Re = integrate1D(Ellip_ReK, 0, x_c-TINY,1)
		Im = integrate1D(Ellip_ImK,x_c+TINY,pi/2,1)
	endif
	
	SetDataFolder $DF
	return cmplx(Re, Im)
	
End 

Function Ellip_ReK(x)  // The real part of the Elliptic function K
variable x
	
	String DF = GetDataFolder (1)
	SetdataFolder root:internalUse:Special_Function
	
	NVAR m
	variable result 
	result = 1 / sqrt(1 - m*sin(x)*sin(x))
	
	SetDataFolder $DF
	return result
	
End

Function Ellip_ImK(x) // The Imaginary part of Elliptic function K
variable x

	String DF = GetDataFolder (1)
	SetdataFolder root:internalUse:Special_Function
	
	NVAR m
	variable result
	result = 1/ sqrt(m*sin(x)*sin(x) -1)
	
	SetDataFolder $DF
	return result
	
End

// The following two function is just using the wave to evaluate the Elliptic function K(m), 
//In this case,  it also works for complex m.

Function/C cEllipK_wave(m,x)
variable/C m
variable x
	
	variable/C result

	result = 1/sqrt(1-m*sin(x)*sin(x))
	return result
	
End

Function/C cEllipK(m)                 // Evaluation of the Elliptic function K for general m including complex number. The accuracy for Re(m)>1 && Im(m)=0 is not great because of the singularity
variable /C m

	String DF = GetDataFolder (1)
	SetdataFolder root:internalUse:Special_Function
	
	wave/C K_wave                // created in init_special_function()
	wave Re, Im
	SetScale /I x, 0, pi/2, K_wave, Re, Im 
	
	K_wave=cEllipK_wave(m,x)
	Re=real(K_wave)
	Im = imag(K_wave)
	
	SetDataFolder $DF
	
	return cmplx(area(Re), area(Im))
	
End