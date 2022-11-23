#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 2.00
#pragma ModuleName = globals
#pragma IgorVersion = 5.0

//////////////////////////////////
//
// Physical constants usually not present in Igor.
//
//////////////////////////////////

Constant globals_kb = 1.3806504e-23 // J K^-1
Constant globals_kb_eV = 8.617343e-5 // eV K^-1

Constant globals_h = 6.62606896e-34 // J s
Constant globals_hbar = 1.054571628e-34 // J s / 2 pi
Constant globals_h_eV = 4.13566733e-15 // eV s
Constant globals_hbar_eV = 6.58211899e-16 // eV s

Constant globals_G = 6.67428e-11 // m^3 kg^-1 s^-2

Constant globals_c = 299792458 // m s^-1

Constant globals_epsilon0 = 8.854187817e-12 // F m^-1

Constant globals_mu0 = 12.556370614e-7 // N A-2

Constant globals_e = 1.602176487e-19 // C

Constant globals_amu = 1.660538782e-27 // kg



// Does a transformation from our Manipulator degrees of freedom to 
// k-space. This is the slow but legible version.
//
// theta(t): polar angle
// alpha(a): another polar angle; the rotation of the analyzer around the sample. 
//      This is used only for ALS and is equivalent to theta, really.
// phi(p): flip stage
// omega(o): azimuthal orientation
// beta(b): Scienta-angle
// gamma(g): orientation of parallel detection
// signs (optional): bitwise parameter that determines the sign convention of the angles.
//     This is needed since our experimental setups do not all follow the same sign 
//     convention of the angles. This is a bitwise mask, where the angles above have the 
//     following bits: t=1, a=2, p=4, o=8, b=16, g=32. By default, all angles are defined
//     counterclockwise according to the right-hand rule in a standard cartesian coordinate 
//     system. So, for example, if you want to invert the direction of (a)lpha and (o)mega,
//     you would set signs=10, since 10 = 8 + 2
//
// writes output to angles2k_Result
// the result is in units of k_vacuum, so you need to multiply the result by k_vacuum.
Function globals_flip_ang2kSLOW(t,a,p,o,b,g, [signs])
	Variable t,a,p,o,b,g
	Variable signs
	
	Abort "Yo. Don't you have anything better to do with your time? You really want to use fsmap_flip_ang2k instead."
	
	Variable d2r = pi/180
	t *= (signs & 1 != 0) ? -d2r : d2r
	a *= (signs & 2 != 0) ? -d2r : d2r
	p *= (signs & 4 != 0) ? -d2r : d2r
	o *= (signs & 8 != 0) ? -d2r : d2r
	b *= (signs & 16 != 0) ? -d2r : d2r
	g *= (signs & 32 != 0) ? -d2r : d2r
	Make/o/n=(3,3) Rom,Rphi,Rtheta,Ralpha,Rgamma,Rbeta
	Make/o/n=(3,1) emission

	// Lab emission is in the z direction.
	emission = {0, 0, 1}

	// First rotation is in beta, the angle parallel to the slit direction of the analyzer. (e.g. +-7 degrees for the old analyzers)
	// Second rotation is around gamma, the azimuthal angle of the analyzer slit wrt the manip. (gamma = 0 means slit parallel to manip)\
	// third rotation is around theta and alpha, the rotation of the manip along its long axis and/or the Analyzer around sample.
	// fourth rotation is around phi, the rotation angle of the flip stage.
	// fifth rotation is around omega, the sample azimuthal angle (rotation of sample within the flip stage).
	// N.B. The reason why I write this this way, and not R={{1,0,0}, {0,c,-s}, {0,s,c}} ?
	// Because Igor is fucked up, and the dimensions are in that order row, column, layer, chunk.
	// So, contrary to what you would write down when you write down a matrix in _ANY_ reasonable
	// mathematical language, Igor of course has to do it its own and very fucked up way. So, need
	// to tell Igor that the columns come first, otherwise, all the matrices are wrong... Nasty bug, this
	Rbeta[0][]	= {	{1},		{0},		{0}		}
	Rbeta[1][]	= {	{0},		{cos(b)},	{-sin(b)}	}
	Rbeta[2][]	= {	{0},		{sin(b)},	{cos(b)}	}

	Rgamma[0][]	= {	{cos(g)},	{-sin(g)},	{0}		}
	Rgamma[1][]	= {	{sin(g)},	{cos(g)},	{0}		}
	Rgamma[2][]	= {	{0},		{0},		{1}		}

	Rtheta[0][]	= {	{cos(t)},	{0},		{sin(t)}	}
	Rtheta[1][]	= {	{0},		{1},		{0}		}
	Rtheta[2][]	= {	{-sin(t)},	{0},		{cos(t)}	}

	Ralpha[0][]	= {	{cos(a)},	{0},		{sin(a)}	}
	Ralpha[1][]	= {	{0},		{1},		{0}		}
	Ralpha[2][]	= {	{-sin(a)},	{0},		{cos(a)}	}
	
	Rphi[0][]		= {	{1},		{0},		{0}		}
	Rphi[1][]		= {	{0},		{cos(p)},	{-sin(p)}	}
	Rphi[2][]		= {	{0},		{sin(p)},	{cos(p)}	}
	
	Rom[0][]		= {	{cos(o)},	{-sin(o)},	{0}		}
	Rom[1][]		= {	{sin(o)},	{cos(o)},	{0}		}
	Rom[2][]		= {	{0},		{0},		{1}		}
	MatrixMultiply Rom, Rphi, Rtheta, Ralpha, Rgamma, Rbeta, emission
	WAVE M_product

	Variable/G V_kx = M_product[0][0]
	Variable/G V_ky = M_product[1][0]

//	KillWaves M_product, Rom, Rphi, Rtheta, Ralpha, Rgamma, Rbeta, emission
End


// Does a transformation from our Manipulator degrees of freedom to 
// k-space. This is the fast and completely illegible version.
// I had several options in speeding this up:
// 1. try and make it all into an XOP, in C
// 2. make it illegible.
// I chose 2., since 1. would mean that it is even further from the action, and 
// fixing e.g. a sign error would mean to edit and recompile some external XOP code.
// Also, the C code probably would be heavily optimized anyway and therefore also
// illegible. I got the equation below from a symbolic manipulation program, after
// sticking the above equations in there and doing some hand optimization. Why did
// I do it? Because the code below runs about 20-40 times faster.
Function globals_flip_ang2k(t,a,p,o,b,g, [signs])
	Variable t,a,p,o,b,g
	Variable signs
	
	Variable/G V_kx
	Variable/G V_ky

	if (numtype(signs) != 0)
		V_kx = NaN
		V_ky = NaN
		return 0
	endif
		
	Variable d2r = pi/180
	t = ((signs & 1) != 0) ? -t*d2r : t*d2r
	a = ((signs & 2) != 0) ? -a*d2r : a*d2r
	p = ((signs & 4) != 0) ? -p*d2r : p*d2r
	o = ((signs & 8) != 0) ? -o*d2r : o*d2r
	b = ((signs & 16) != 0) ? -b*d2r : b*d2r
	g = ((signs & 32) != 0) ? -g*d2r : g*d2r
	Variable ct = cos(t)
	Variable st = sin(t)
	Variable ca = cos(a)
	Variable sa = sin(a)
	Variable cp = cos(p)
	Variable sp = sin(p)
	Variable co = cos(o)
	Variable so = sin(o)
	Variable cb = cos(b)
	Variable sb = sin(b)
	Variable cg = cos(g)
	Variable sg = sin(g)
	Variable ca_cb = ca * cb
	Variable sa_cb = sa * cb
	Variable sa_sb_sg = sa * sb * sg
	Variable ca_sb_sg = ca * sb * sg

	Variable const1 = ( ca_cb - sa_sb_sg ) * st + ( ca_sb_sg + sa_cb ) * ct
	Variable const2 = -sp * ( ( ca_cb - sa_sb_sg ) * ct - ( ca_sb_sg + sa_cb ) * st ) - sb * cg * cp

	V_kx = co * const1
	V_kx += -so * const2
	V_ky = so * const1
	V_ky += co * const2
End




// TODO: maybe put this into another file?
// theta(t): polar angle
// omega(o): azimuthal orientation
// sigma(s): tilt of the sample surface normal against the radial top post axis
// mu(m): rotation of the sample BZ against the tilt sigma
// writes output to angles2k_Result
// the result is in units of k_vacuum, so you need to multiply the result by k_vacuum.
Function globals_berlin_ang2k(t,o,s,m)
	Variable t,o,s,m
		
	Variable d2r = pi/180
	t *= d2r
	o *= d2r
	s *= d2r
	m *= d2r
	Make/o/n=(3,3) Rtheta, Rom, Rsigma,Rmu
	Make/o/n=3 emission

	// Lab emission is in the z direction.
	emission = {0, 0, 1}

	// First rotation is in beta, the angle parallel to the slit direction of the analyzer. (e.g. +-7 degrees for the old analyzers)
	// Second rotation is around gamma, the azimuthal angle of the analyzer slit wrt the manip. (gamma = 0 means slit parallel to manip)
	// third rotation is around theta, the rotation of the manip along its long axis.
	// fourth rotation is around phi, the rotation angle of the flip stage.
	// fifth rotation is around omega, the sample azimuthal angle (rotation of sample within the flip stage).
	Rtheta		= { {	cos(t),	0,		-sin(t)	}, {	0,		1,		0		}, {	sin(t),	0,		cos(t)	} }
	Rom		= { {	cos(o),	sin(o),	0		}, {	-sin(o),	cos(o),	0		}, {	0,		0,		1		} }
	Rsigma		= { {	cos(s),	0,		-sin(s)	}, {	0,		1,		0		}, {	sin(s),	0,		cos(s)	} }
	Rmu		= { {	cos(m),	sin(m),	0		}, {	-sin(m),	cos(m),	0		}, {	0,		0,		1		} }
	MatrixMultiply Rmu, Rsigma, Rom, Rtheta, emission
	WAVE M_product
	
	Variable/G V_kx = M_product[0][0]
	Variable/G V_ky = M_product[1][0]
	
	KillWaves M_product, Rtheta, Rom, Rsigma, Rmu, emission
End



StrConstant globals_knownExperiments = "ALS;Basement;SSRL"
Static StrConstant experimentGamma = "ALS:0;Basement:90;SSRL:0"
Static StrConstant experimentWorkFn = "ALS:4.35;Basement:4.22;SSRL:4.35"
Static StrConstant experimentManipType = "ALS:flip;Basement:flip;SSRL:flip"
Static StrConstant experimentSigns = "ALS:4;Basement:0;SSRL:4"
Static StrConstant experimentStartBeta = "ALS:-15;Basement:-7;SSRL:-15"
Static StrConstant experimentEndBeta = "ALS:15;Basement:7;SSRL:15"

Function globals_getGamma(experiment)
	String experiment
	return NumberByKey(experiment, experimentGamma)
End

Function globals_getWorkFn(experiment)
	String experiment
	return NumberByKey(experiment, experimentWorkFn)
End

Function/S globals_getManipType(experiment)
	String experiment
	return StringByKey(experiment, experimentManipType)
End

Function globals_getSigns(experiment)
	String experiment
	return round(NumberByKey(experiment, experimentSigns))
End

Function globals_getStartBeta(experiment)
	String experiment
	return round(NumberByKey(experiment, experimentStartBeta))
End

Function globals_getEndBeta(experiment)
	String experiment
	return round(NumberByKey(experiment, experimentEndBeta))
End

