#pragma rtGlobals=3		// Use modern global access method and strict wave access.


function fit2D_prepare()
	//settings
	variable polyorder=9
	//endsettings
	make/o/n=(polyorder+1) polywave = NaN
	make/o/n=(10+3*polyorder) para = NaN
end


Function MFL_AN_spec(pw, yw, xw1, xw2) : FitFunc
	WAVE pw, yw, xw1, xw2
	//pw: 8+3*polywavesize = 37
	wave polywave // a placeholder for poly coefficients
	variable polyorder = numpnts(polywave)-1
	
	variable kb = 8.61733034e-5
	
	//xw1: momentum
	//xw2: energy
	
	//pw[0] temperature
	//pw[1] MFL-offset, set to 0
	//pw[2] MFL-slope
	//pw[3] band bottom, bonding
	//pw[4] band bottom, antibonding
	//pw[5] invmass, bonding
	//pw[6] invmass, antibonding
	//pw[7] momentum offset
	
	//pw[8,8+polyorder] numbers for smooth bkg: a0+a1*x+a2*x^2+...
	//pw[9+polyorder,9+2*polyorder] numbers for smooth bonding band intensity
	//pw[10+2*polyorder,10+3*polyorder] numbers for smooth antibonding band intensity
	
	polywave = pw[8+p]
	yw = poly(polywave, xw1[p])
	
	polywave = pw[9+polyorder+p]
	yw +=poly(polywave,xw1[p])*(abs(pw[1])+abs(pw[2])*sqrt(xw2[p]^2+(pi*kb*pw[0])^2))/((xw2[p]-(pw[3]+pw[5]*(xw1[p]-pw[7])^2))^2 + (abs(pw[1])+abs(pw[2])*sqrt(xw2[p]^2+(pi*kb*pw[0])^2))^2)
	
	polywave = pw[10+2*polyorder+p]
	yw +=poly(polywave,xw1[p])*(abs(pw[1])+abs(pw[2])*sqrt(xw2[p]^2+(pi*kb*pw[0])^2))/((xw2[p]-(pw[4]+pw[6]*(xw1[p]-pw[7])^2))^2 + (abs(pw[1])+abs(pw[2])*sqrt(xw2[p]^2+(pi*kb*pw[0])^2))^2)
End


ab_disp = para[3]+(x-para[7])^2*para[5]
bb_disp = para[4]+(x-para[7])^2*para[6]

Function recreate(image)
	wave image
	duplicate/o image, $("recreate_"+nameofwave(image))
	wave reimage = $("recreate_"+nameofwave(image))
	
	wave pw = para_simu
	
	variable kb = 8.61733034e-5
	
	reimage = (abs(pw[1])+abs(pw[2])*sqrt(y^2+(pi*kb*pw[0])^2))/((y-(pw[3]+pw[5]*(x-pw[7])^2))^2 + (abs(pw[1])+abs(pw[2])*sqrt(y^2+(pi*kb*pw[0])^2))^2)
	reimage += (abs(pw[1])+abs(pw[2])*sqrt(y^2+(pi*kb*pw[0])^2))/((y-(pw[4]+pw[6]*(x-pw[7])^2))^2 + (abs(pw[1])+abs(pw[2])*sqrt(y^2+(pi*kb*pw[0])^2))^2)
	
	make/o/n=(dimsize(image,0)) matele_ab, matele_bb, bkg
	setscale/P x, dimoffset(image,0), dimdelta(image,0), matele_ab, matele_bb, bkg
	
	wave polywave
	variable polyorder = numpnts(polywave)-1
	
	polywave = pw[8+p]
	bkg = poly(polywave,x)
	
	polywave = pw[9+polyorder+p]
	 matele_ab +=poly(polywave,x)
	
	polywave = pw[10+2*polyorder+p]
	matele_bb +=poly(polywave,x)
end

//===============================================================================
//2 band MFL FD with resolution
Function MFL_FD_reso_2D_prepare(img)
	wave img
	
	string imgname = nameofwave(img)
	string fit_imgname = cropname("mflfit_"+imgname)
	string res_imgname = cropname("mflres_"+imgname)
	string para_imgname = cropname("mflpara_"+imgname)
	string err_imgname = cropname("mflerr_"+imgname)
	
	duplicate/o img, $fit_imgname, $res_imgname
	make/o/n=38 $para_imgname
	wave fit_img = $fit_imgname
	wave res_img = $res_imgname
	wave para_img = $para_imgname
	fit_img = NaN
	res_img = NaN
	
	variable deltaE = dimdelta(img,1)
	variable reso_numpnt_E = 2*floor(0.05/deltaE)+1
	variable padding_radius_E = floor(0.05/deltaE)*deltaE
	
	variable deltak = dimdelta(img,0)
	variable reso_numpnt_k = 101
	variable padding_radius_k = 50*deltak
	
	//resolution wave
	make/o/n=(reso_numpnt_k, reso_numpnt_E) reso_temp
	setscale/P x,-padding_radius_k, deltak, reso_temp
	setscale/P y,-padding_radius_E, deltaE, reso_temp
	reso_temp = NaN
	
	//padding wave
	make/o/n=(reso_numpnt_k+dimsize(img,0),reso_numpnt_E+dimsize(img,1)) fit_temp
	setscale/P x,dimoffset(img,0)-padding_radius_k,deltak, fit_temp
	setscale/P y,dimoffset(img,1)-padding_radius_E,deltaE, fit_temp
	fit_temp = NaN
	
	//im self energy
	make/o/n=(reso_numpnt_E+dimsize(img,1)) imse_temp
	setscale/P x,dimoffset(img,1)-padding_radius_E,deltaE, imse_temp
	
	//poly wave holder
	make/o/n=9 polywave
	polywave = NaN
	
	//bkg, matrix element holder
	make/o/n=(reso_numpnt_k+dimsize(img,0)) bkg_temp, intensity_bb, intensity_ab
	setscale/P x,dimoffset(img,0)-padding_radius_k,deltak, bkg_temp,intensity_bb, intensity_ab
	
	 bkg_temp = NaN
	intensity_bb = NaN
	intensity_ab = NaN
	
end





Function MFL_FD_reso_2D(pw, yw, xw1, xw2) : FitFunc
	WAVE pw, yw, xw1, xw2
	//xw1: momentum
	//xw2: energy
	
	//pw: 8+3*polywavesize = 38
	wave polywave // a placeholder for poly coefficients
	wave reso_temp, fit_temp, imse_temp, bkg_temp, intensity_bb, intensity_ab
	variable polyorder = numpnts(polywave)-1
	
	variable kb = 8.61733034e-5
	
	polywave = pw[9+p]
	bkg_temp= poly(polywave, x)
	
	polywave = pw[10+polyorder+p]
	intensity_bb = poly(polywave, x)
	
	polywave = pw[11+2*polyorder+p]
	intensity_ab = poly(polywave, x)
	
	
	
	
	
	
	
	//pw[0] temperature
	//pw[1] MFL impurity
	//pw[2] MFL lambda 	imse = lambda* (pi/2)*x
	//pw[3] MFL temperature coefficient a: a pi kb T
	//pw[4] band bottom, bonding
	//pw[5] band bottom, antibonding
	//pw[6] invmass, bonding
	//pw[7] invmass, antibonding
	//pw[8] momentum offset
	
	//pw[9,9+polyorder] numbers for smooth bkg: a0+a1*x+a2*x^2+...
	//pw[10+polyorder,10+2*polyorder] numbers for smooth bonding band intensity
	//pw[11+2*polyorder,11+3*polyorder] numbers for smooth antibonding band intensity
	
	

	
	polywave = pw[9+p]
	yw = poly(polywave, xw1[p])
	
	polywave = pw[10+polyorder+p]
	yw +=poly(polywave,xw1[p])*(abs(pw[1])+abs(pw[2])*sqrt(xw2[p]^2+(pi*kb*pw[0])^2))/((xw2[p]-(pw[3]+pw[5]*(xw1[p]-pw[7])^2))^2 + (abs(pw[1])+abs(pw[2])*sqrt(xw2[p]^2+(pi*kb*pw[0])^2))^2)
	
	polywave = pw[11+2*polyorder+p]
	yw +=poly(polywave,xw1[p])*(abs(pw[1])+abs(pw[2])*sqrt(xw2[p]^2+(pi*kb*pw[0])^2))/((xw2[p]-(pw[4]+pw[6]*(xw1[p]-pw[7])^2))^2 + (abs(pw[1])+abs(pw[2])*sqrt(xw2[p]^2+(pi*kb*pw[0])^2))^2)
	
	//Redimension/N=(num_k, num_E) yw
	//MatrixOP yw = 0
	//Redimension/N=(num_k*num_E) yw
	
	
	
	
	
	
	//yw =  interp2D(()
End

gauss2D