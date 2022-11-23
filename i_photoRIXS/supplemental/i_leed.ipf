#pragma rtGlobals=1		// Use modern global access method.#pragma version = 1.00#pragma ModuleName = leed#pragma IgorVersion = 5.0// scale a LEED image from pixels to �-1Function leed_scale(M)	WAVE M	Variable Ekin = 173							// acceleration voltage in V	Variable field_of_view_pix = 585				// field of view in pixels	Variable x0 = 382								// center of screen	Variable y0 = 295	Variable corr_factor = 0.87						// LEED patterns in the basement are always too large	Variable reziprocal_lattice_const = 2*pi/5.37 	// rez. lattice constant in �-1. Use 1 for �-units	// Cu(111): 2*pi/3.61*sqrt(8/3)	// Ca-327: 2*pi/5.37		Variable delta_work	 = 2.3			// difference of sample and filament workfunction in eV	Variable field_of_view = 100 		// opening angle in degrees			Variable dx = sqrt(Ekin-delta_work) * 0.5123 * sin(field_of_view/2 *pi/180) / (field_of_view_pix/2)	dx *= corr_factor	dx /= reziprocal_lattice_const		//print dx	//abort		Variable x0_scale = -x0 * dx	Variable y0_scale = -y0 * dx		SetScale/P x x0_scale,dx,"" M	SetScale/P y y0_scale,dx,"" MEnd