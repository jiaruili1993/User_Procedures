#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 0.01


//constant for 0.5c correction///
//40.107
constant angle_to_length=30//40.107//0.625/pi*180
constant slit_d=100///mm

////////////////////////Initial angle///////////////////

Function /C Checkmultivalue_cube(mappingmethodflag,multicubeflag,w_sourcepath_raw,w_c,w_f,w_azi_raw,w_ef_raw,nameA,nameB,nameC,nameD)
	Variable mappingmethodflag
	Variable multicubeflag
	Wave /T w_sourcepath_raw
	Wave w_c,w_f,w_azi_raw,w_ef_raw
	String NameA,NameB,NameC,NameD
	
	NameA="x"
	NameB="y"
	NameC="p"
	NameD="q"
	
	Duplicate /o w_c w_c_sort
	Duplicate /o w_f w_f_sort
	Duplicate /o /Free w_azi_raw w_azi
	Duplicate /o /Free w_ef_raw w_ef
	Duplicate /o /T /FREE w_sourcepath_raw w_sourcepath

	
	Variable /C returnval
	
	Variable phi_final=checkreturnwaveequal(w_f_sort,Nan,Nan)
	
	Variable cubenum
	String tempwavename
	
	
	
	if (multicubeflag==0)//((numtype(phi_final)!=2))//for single map or precise and no convert mode
		
		//if (mappingmethodflag!=2) //for raw interp, scatter mode do not sort follow the index of sourth path
			sort /A {w_c,w_f},w_f_sort,w_c_sort,w_azi,w_ef,w_sourcepath
		//endif
		
			cubenum=1
			tempwavename="w_Cube_"+NameA
			duplicate /o w_c_sort,$tempwavename
			tempwavename="w_Cube_"+NameB
			duplicate /o w_f_sort,$tempwavename
			tempwavename="w_Cube_"+NameC
			duplicate /o w_azi,$tempwavename
			tempwavename="w_Cube_"+NameD
			duplicate /o w_ef,$tempwavename
		
			tempwavename="w_intPathes"
			duplicate /o w_sourcepath,$tempwavename
		
			returnval=cmplx(cubenum,phi_final)
			//Killwaves /Z w_f_sort,w_c_sort
			return returnval		

	else
		//if  (mappingmethodflag==2) // raw interp scattermode
			sort /A {w_f,w_c},w_f_sort,w_c_sort,w_azi,w_ef,w_sourcepath
		//endif
	
			Variable index,cutnum=0,cubestart=0
			Variable tempw_f=w_f_sort[0]
	
			index=0
			do
				if (w_f_sort[index]==tempw_f)	
					cutnum+=1
				else
					if (cutnum>1)
						cubenum+=1
						tempwavename="w_Cube_"+NameB+"_"+num2str(cubenum)
						duplicate /o/R=[cubestart,index-1] w_F_sort,$tempwavename
						tempwavename="w_Cube_"+NameA+"_"+num2str(cubenum)
						duplicate /o/R=[cubestart,index-1] w_C_sort,$tempwavename
						tempwavename="w_Cube_"+NameC+"_"+num2str(cubenum)
						duplicate /o/R=[cubestart,index-1] w_azi,$tempwavename
						tempwavename="w_Cube_"+NameD+"_"+num2str(cubenum)
						duplicate /o/R=[cubestart,index-1] w_ef,$tempwavename
		
						tempwavename="w_intPathes_"+num2str(cubenum)
						duplicate /o/R=[cubestart,index-1] w_sourcepath,$tempwavename
						cutnum=1
						tempw_f=w_f_sort[index]
						cubestart=index
					else
						Killwaves /Z w_f_sort,w_c_sort
						return 0
					endif
				endif
				index+=1
			while (index<numpnts(w_f_sort))
	
			if (cutnum>1) ///last one cube
				cubenum+=1
				tempwavename="w_Cube_"+NameB+"_"+num2str(cubenum)
				duplicate /o/R=[cubestart,inf] w_F_sort,$tempwavename
				tempwavename="w_Cube_"+NameA+"_"+num2str(cubenum)
				duplicate /o/R=[cubestart,inf] w_C_sort,$tempwavename
				tempwavename="w_Cube_"+NameC+"_"+num2str(cubenum)
				duplicate /o/R=[cubestart,inf] w_azi,$tempwavename
				tempwavename="w_Cube_"+NameD+"_"+num2str(cubenum)
				duplicate /o/R=[cubestart,inf] w_ef,$tempwavename
		
				tempwavename="w_intPathes_"+num2str(cubenum)
				duplicate /o/R=[cubestart,inf] w_sourcepath,$tempwavename
				
			else
				Killwaves /Z w_f_sort,w_c_sort
				return 0
			endif
			Killwaves /Z w_f_sort,w_c_sort
	
			returnval=cmplx(cubenum, Nan)
			return returnval
	endif
	
	
End	

Checkmultivalue_cube

Function /C Checkmultivalue_cube_DA30(mappingmethodflag,multicubeflag,w_sourcepath_raw,w_c,w_f,w_azi_raw,w_ef_raw, w_DeflectorY, nameA,nameB,nameC,nameD,nameE)
	Variable mappingmethodflag
	Variable multicubeflag
	Wave /T w_sourcepath_raw
	Wave w_c,w_f,w_azi_raw,w_ef_raw,w_DeflectorY
	String NameA,NameB,NameC,NameD, NameE
	
	NameA="theta"
	NameB="phi"
	NameC="azi"
	NameD="EF"
	NameE="DY"
	
	Duplicate /o w_c w_c_sort
	Duplicate /o w_f w_f_sort
	Duplicate /o w_DeflectorY w_DeflectorY_sort
	Duplicate /o /Free w_azi_raw w_azi
	Duplicate /o /Free w_ef_raw w_ef
	Duplicate /o /T /FREE w_sourcepath_raw w_sourcepath

	
	Variable /C returnval
	
	Variable phi_final=checkreturnwaveequal(w_f_sort,Nan,Nan)
	Variable theta_final=checkreturnwaveequal(w_c_sort,Nan,Nan)
	Variable azi_final=checkreturnwaveequal(w_azi_raw,Nan,Nan)
	
	if(numtype(theta_final)==2)
		return cmplx(nan,nan)
	endif
	
	if(numtype(phi_final)==2)
		return cmplx(nan,nan)
	endif
	
	if(numtype(azi_final)==2)
		return cmplx(nan,nan)
	endif
	
	
	Variable cubenum
	String tempwavename
	

	if (multicubeflag==0)//((numtype(phi_final)!=2))//for single map or precise and no convert mode
		
		//if (mappingmethodflag!=2) //for raw interp, scatter mode do not sort follow the index of sourth path
			sort /A {w_DeflectorY},w_f_sort,w_c_sort,w_azi,w_DeflectorY_sort, w_ef,w_sourcepath
		//endif
		
			cubenum=1
			tempwavename="w_Cube_"+NameA
			duplicate /o w_c_sort,$tempwavename
			tempwavename="w_Cube_"+NameB
			duplicate /o w_f_sort,$tempwavename
			tempwavename="w_Cube_"+NameC
			duplicate /o w_azi,$tempwavename
			tempwavename="w_Cube_"+NameD
			duplicate /o w_ef,$tempwavename
			tempwavename="w_Cube_"+NameE
			duplicate /o w_DeflectorY_sort,$tempwavename
			
			tempwavename="w_intPathes"
			duplicate /o w_sourcepath,$tempwavename
		
			returnval=cmplx(cubenum,phi_final)
			//Killwaves /Z w_f_sort,w_c_sort
			return returnval		

	else
			return cmplx(nan, nan)
	endif
	
End	










Function checkparequal(cubenum,dimflag,mappingmethodflag)
	Variable cubenum,dimflag,mappingmethodflag
	
	DFREF df=getDatafolderDFR()
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetDatafolder $DF_panel
	
	 //flip check azi  //polar check theta and phi //kz check theta and phi
		String checkwavename="w_Cube_p"
		if (cubenum==1)
			Wave checkw=$ checkwavename
			Variable azi_final=checkreturnwaveequal(checkw,Nan,Nan) // can not map multi azi wave
			if (numtype(azi_final)==2)
				if (dimflag==1)
					doalert 0, "Flip mapping, azi multi-value error."
					SetDatafolder DF
					return 0
				elseif (dimflag==2)
					doalert 0, "Polar mapping, multi-angle error."
					SetDatafolder DF
					return 0
				elseif (Dimflag==3)
					doalert 0, "kz mapping, multi-angle error."
					SetDatafolder DF
					return 0
				endif
			endif
		else
			Variable index
			do
				checkwavename="w_Cube_p_"+num2str(index+1)
				Wave checkw=$ checkwavename
				azi_final=checkreturnwaveequal(checkw,Nan,Nan) // can not map multi azi wave
				if (numtype(azi_final)==2)
					if (dimflag==1)
						doalert 0, "Flip mapping, azi multi-value error."
						SetDatafolder DF
						return 0
					elseif (dimflag==2)
						doalert 0, "Polar mapping, multi-angle error."
						SetDatafolder DF
						return 0
					elseif (Dimflag==3)
						doalert 0, "kz mapping, multi-angle error."
						SetDatafolder DF
						return 0
					endif
				endif
				index+=1
			while (index<cubenum)
		endif
	
	if (dimflag==3) //kz check q
		checkwavename="w_Cube_q"
		if (cubenum==1)
			Wave checkw=$ checkwavename
			azi_final=checkreturnwaveequal(checkw,Nan,Nan) // can not map multi azi wave
			if (numtype(azi_final)==2)
				doalert 0, "kz mapping, multi-azi error."
				SetDatafolder DF
				return 0
			endif
		else
			index=0
			do
				checkwavename="w_Cube_q_"+num2str(index+1)
				Wave checkw=$ checkwavename
				azi_final=checkreturnwaveequal(checkw,Nan,Nan) // can not map multi azi wave
				if (numtype(azi_final)==2)
					doalert 0, "kz mapping, multi-azi error."
					SetDatafolder DF
					return 0
				endif
				index+=1
			while (index<cubenum)
		endif
	
	endif	
	
	
	SetDatafolder dF
	return 1
End

Function Initial_angle_wave(alertflag)
	Variable alertflag
	DFREF df=getDatafolderDFR()
	
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetDatafolder $DF_panel


	NVAR gammaA=gv_gammaA
	
	NVAR azi_final=gv_azi_final
	NVAR phi_final=gv_phi_final
	NVAR theta_final=gv_theta_final
	NVAR mergeflag=gv_mergeflag
	
	NVAR dimflag=gv_dimflag
	NVAR mappingmethodflag=gv_mappingmethodflag
	NVAR rawmethodflag=gv_rawmappingmethodflag

	if (numpnts(w_sourcePathes) < 2)
			DoAlert,0,"You need at least two source carpets."
			SetDatafolder DF	
			return 0
	endif
	
	NVAR hn = gv_hn
	NVAR EF = gv_EF
	NVAR workfunc = gv_workfunction
	
	NVAR Ascale=gv_Ascale
	NVAR dimflag=gv_dimflag
	NVAR innerE=gv_innerE
	NVAR multicubeflag=gv_multicubeflag
	
	if ((numtype(gammaA)==2)||(numtype(Ascale)==2))
		DoAlert,0,"Invalid gamma and scale Parameters"
		SetDatafolder DF
		return 0
	endif

	
	if(dimflag==3)
		if ((numtype(innerE)==2))
			DoAlert,0,"Invalid Inner Potential"
			SetDatafolder DF
			return 0
		endif
	endif
	
	
	Wave /T w_sourcePathes_O=w_sourcePathes
	duplicate /o/t w_sourcePathes_O, w_sourcePathes_sort
	Wave /T w_sourcePathes=w_sourcePathes_sort
	Wave w_Clist,w_Flist,w_Azilist,w_C_off,w_F_off,w_Azi_off,w_eF
	Duplicate /o w_Clist, w_c_Final, w_f_final, w_azi_final
	
	w_c_final=w_Clist+w_C_off
	w_F_final=w_Flist+w_F_off
	w_azi_final=w_azilist+w_Azi_off
	
	
	Variable cubenum
	Variable /C returnval
	
	
	
	If(dimflag==4)//DA30
		duplicate/o w_Clist, w_DeflectorY
		w_DeflectorY=NaN
		variable index_DA30, DeflectorY_DA30
		string wavenote_DA30
		for(index_DA30=0;index_DA30<numpnts(w_Clist);index_DA30 +=1)
			wave cut_DA30 = $(w_sourcePathes[index_DA30])
			wavenote_DA30 = note(cut_DA30)
			 DeflectorY_DA30=NumberByKey("DeflectorAngle", wavenote_DA30, "=", "\r")
			 if ((numtype(DeflectorY_DA30)==2))
				DoAlert,0,"Invalid Deflector Angle!"
				SetDatafolder DF
				return 0
			endif
			w_DeflectorY[index_DA30]=DeflectorY_DA30
		endfor
		
		mergeflag=0
		
		if (gammaA!=0)
			DoAlert,0,"Incompatible Gamma Angle!"
			SetDatafolder DF
			return 0
		endif
		
		returnval=Checkmultivalue_cube_DA30(mappingmethodflag,multicubeflag,w_sourcePathes,w_c_final,w_f_final,w_azi_final,w_ef,w_DeflectorY,"C","F","Azi","EF","DY")
		
		phi_final=imag(returnval)
		cubenum=real(returnval)
		if (cubenum!=1)
			DoAlert,0,"Incompatible setting or data."
			SetDatafolder DF
			return 0
		endif

		
	endif






	if (dimflag==1)  //kxky flip
		mergeflag=0
		
			
		if (gammaA==0)
			returnval=Checkmultivalue_cube(mappingmethodflag,multicubeflag,w_sourcePathes,w_c_final,w_f_final,w_azi_final,w_ef,"C","F","Azi","EF")
			phi_final=imag(returnval)
			cubenum=real(returnval)
			
		else
			returnval=Checkmultivalue_cube(mappingmethodflag,multicubeflag,w_sourcePathes,w_f_final,w_c_final,w_azi_final,w_ef,"C","F","Azi","EF")
			theta_final=imag(returnval)
			cubenum=real(returnval)
		
		endif
		
		if (cubenum==0)
			if (alertflag)
				doalert 1, "MultiCube error, Yes-->Change to Scatter method, No-->Cancel"
				switch(v_flag)
					case 1:
						mapperPanel#c_map_method("settings_ck04",1)
						break
					case 2:
						SetDatafolder DF
						return 0
						break
				endswitch
			else
				mapperPanel#c_map_method("settings_ck04",1)
			endif
		endif		
	endif
		

	if (dimflag==2)  //kxky polar
		mergeflag=0
		
		
	
		if (gammaA==0)
			returnval=Checkmultivalue_cube(mappingmethodflag,multicubeflag,w_sourcePathes,w_azi_final,w_f_final,w_c_final,w_ef,"azi","F","C","EF")
			phi_final=imag(returnval)
			cubenum=real(returnval)	
		else	
			returnval=Checkmultivalue_cube(mappingmethodflag,multicubeflag,w_sourcePathes,w_azi_final,w_c_final,w_f_final,w_ef,"azi","c","F","EF")
			theta_final=imag(returnval)
			cubenum=real(returnval)
		endif	
		
		if (cubenum==0)
			if (alertflag)
				doalert 1, "Multicube  error, Yes-->Change to Scatter method, No-->Cancel"
				switch(v_flag)
					case 1:
						mapperPanel#c_map_method("settings_ck04",1)
						break
					case 2:
						SetDatafolder DF
						return 0							
						break
				endswitch
			else
				mapperPanel#c_map_method("settings_ck04",1)
			endif
		endif		
		
		
		
	endif

	if (dimflag==3)  //kz
		mergeflag=0
		
		if (gammaA==0)
			
			returnval=Checkmultivalue_cube(mappingmethodflag,multicubeflag,w_sourcePathes,w_ef,w_f_final,w_c_final,w_azi_final,"EF","F","C","azi")
			phi_final=imag(returnval)
			cubenum=real(returnval)
		
		else

			returnval=Checkmultivalue_cube(mappingmethodflag,multicubeflag,w_sourcePathes,w_ef,w_c_final,w_f_final,w_azi_final,"EF","C","F","azi")
			theta_final=imag(returnval)
			cubenum=real(returnval)
			
		endif	
		
		if (cubenum==0)
			if (alertflag)
				doalert 1, "MultiCube error, Yes-->Change to Scatter method, No-->Cancel"
				switch(v_flag)
					case 1:
						mapperPanel#c_map_method("settings_ck04",1)
						break
					case 2:
						SetDatafolder DF
						return 0
						break
				endswitch
			else
					mapperPanel#c_map_method("settings_ck04",1)
			endif
		endif	
			
	endif
	
	Killwaves /Z w_sourcePathes_sort
//	
//	
//	if (mappingmethodflag==2)///for quick raw and quick interp
//		if (checkparequal(cubenum,dimflag,mappingmethodflag)==0)
//			SetDatafolder DF
//			return 0
//		endif
//	endif
		
	
	SetDatafolder DF

	return cubenum
End

//	if (mappingmethodflag==2)///for quick raw and quick interp
//			
//			
//		endif	




/////////////////////////Initial cubes///////////////////


//////////////////////////////////////cube/////////////////////////////////



///////////////////Make raw cube single////////////// Integrate along slice and normalize cuts

Function scalecube_for_kzmap(cube,w_EF)
	Wave cube
	Wave w_EF
	
	Variable EF_max=wavemax(w_EF)
	
	Variable angle0=asin(M_y0(cube)/sqrt(EF_max)/0.512)/pi*180
	Variable angle1=asin(M_y1(cube)/sqrt(EF_max)/0.512)/pi*180

	Make /o/Free/n=(dimsize(cube,1),dimsize(cube,2)) tempimage,tempimage_kz,tempimage_x
	Setscale /P y,M_z0(cube),dimdelta(cube,2),tempimage,tempimage_kz,tempimage_x
	Setscale /I x,angle0,angle1,tempimage_kz,tempimage_x
	Setscale /P x,M_y0(cube),dimdelta(cube,1),tempimage
	
	
	Variable index
	do
		tempimage=cube[index][p][q]
		tempimage_x=sqrt(w_EF[index])*0.512*sin(x/180*pi)
		
		tempimage_kz=interp2D(tempimage,tempimage_x,y)
		
		cube[index][][]=tempimage_kz[q][r]

		index+=1
	while (index<dimsize(cube,0))
	
	Setscale /I y,angle0,angle1,cube
End

Function scaleangle_for_kzmap(image,EF,flag)
	Wave image
	Variable EF
	variable flag
	
	variable k0=sqrt(EF)*0.512*sin(M_x0(image)/180*pi)
	variable k1=sqrt(EF)*0.512*sin(M_x1(image)/180*pi)
	
	Duplicate /Free Image, image_Temp,image_x
	Setscale /I x,k0,k1,image,image_x
	image_x=asin(x/sqrt(EF)/0.512)/pi*180
	
	image=Interp2D (image_temp,  image_x, y)	
End


Function make_cfe_rawCube_single(cubeindex,w_intPathes,w_cube_x,w_cube_y,gv_slicedensity,dimflag)
	Variable cubeindex
	WAVE/T w_intPathes
	Wave w_cube_x,w_cube_y
	Variable gv_slicedensity,dimflag
	
	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	
	NVAR toplayernum=DFR_common:gv_toplayernum
	NVAR topprocnum=DFR_common:gv_topprocnum
	NVAR autolayerflag=DFR_common:autolayerflag
	
	NVAR initialflag=DFR_panel:gv_initialflag
	SVAR gs_notestring=DFR_panel:gs_notestring
	
	SetDatafolder $DF_panel
	NVAR gammaA=gv_gammaA
	
	NVAR mappingmethodflag=gv_mappingmethodflag
	NVAR multicubeflag=gv_multicubeflag
	
	make_NormWave(cubeindex,w_intPathes)
	
	string rawcubename="cfe_rawCube"
	String normalwavename_smooth="Wave_normal_S"
	if (cubeindex>0)
		normalwavename_smooth+="_"+num2str(cubeindex)
		rawcubename+="_"+num2str(cubeindex)
	endif
	
	Wave w_normal_S=$normalwavename_smooth
	
	String newnotestring=Cube_note_wave_Raw_single(cubeindex,w_intPathes,w_cube_x,w_cube_y,w_normal_S,toplayernum,topprocnum,gv_slicedensity,dimflag)
		
		
	Wave/Z cfe_rawCube=$rawcubename
	if (waveexists(cfe_rawCube))
		String oldnotestring=note(cfe_rawCube)
		if (stringmatch(oldnotestring,newnotestring)==1)
			gs_notestring+=newnotestring
			Setdatafolder DF
			return 2
		endif
	endif
	
	Variable mean_cube_y=mean(w_cube_y)
	
	Variable  cn,fn,en

	Make /o/n=(numpnts(w_intPathes)) w_efrom, w_eto, w_dE, w_ffrom, w_fto, w_df
	
	cn = numpnts(w_intPathes)
	
	String notestr
	
	Variable index = 0
		do
			WAVE data = $w_intPathes[index]

			Variable datalayernum=Autolayer_wavelist(data,toplayernum,topprocnum,autolayerflag)
			
			Getlayerimage(data,datalayernum)	
			
			Wave temp_image=templayerimage
				
			if ((dimflag==3)&&(initialflag==0))  //for kz mapping  substract the EF value
				w_efrom[index] = M_y0(temp_image)-w_cube_x[index]
				w_eto[index] = M_y1(temp_image)-w_cube_x[index]		
			else
				w_efrom[index] = M_y0(temp_image)
				w_eto[index] = M_y1(temp_image)
			endif
						
			w_dE[index] = dimdelta(temp_image,1)
			
			if ((mappingmethodflag==2)&&(multicubeflag==0)) /// for single cube and quick method //// shift by mean phi value
				Variable shiftvalue=w_cube_y[index]-mean_cube_y
				w_ffrom[index] = M_x0(temp_image)+shiftvalue
				w_fto[index] =M_x1(temp_image)+shiftvalue
			else
				w_ffrom[index] = M_x0(temp_image)
				w_fto[index] =M_x1(temp_image)	
			endif
				w_df[index] = dimdelta(temp_image,0)
			
			index += 1
		while (index < cn)
		
		Killwaves /Z templayerimage
		
		// fe_waveform: point density and scaling (cropping is ignored here)
		
		Variable e_from = wavemin(w_efrom)
		Variable e_to = wavemax(w_eto)
		Variable dE = wavemin(w_dE)
		en = (e_to - e_from)/dE + 1
		
		
		Variable fine_from = wavemin(w_ffrom)
		Variable fine_to = wavemax(w_fto)
		
		if (numtype(gv_slicedensity)==2)
			Variable dfine = wavemin(w_df)
		else
			dfine=gv_slicedensity
		endif
		
		fn = round(abs(fine_to - fine_from)/dfine) + 1
		
		
		if (dimflag==3) //kz change angle scale to sqrt(E)(sin)
			Variable maxEF=wavemax(w_cube_x)
			fine_from=sqrt(maxEF)*0.512*sin(fine_from/180*pi)
			fine_to=sqrt(maxEF)*0.512*sin(fine_to/180*pi)
		endif

		Make/o/n=(fn,en) fe_waveform
		SetScale/I x fine_from, fine_to,"" fe_waveform
		SetScale/I y e_from, e_to,"" fe_waveform
		
		// make and fill the cube
		
		
		Make/o/n=(cn,fn,en) $rawcubename ///no x scaling for rawcube
		SetScale/I y fine_from, fine_to,""$rawcubename
		SetScale/I z e_from, e_to,"" $rawcubename
		
		Wave cfe_rawCube=$rawcubename
		
		note /K cfe_rawCube
	    	note cfe_rawCube,newnotestring
	    	gs_notestring+=newnotestring
		
		Killwaves /Z w_efrom, w_eto, w_dE, w_ffrom, w_fto, w_df

		Variable i = 0
		
		do	// loop over all carpets
			WAVE data = $w_intPathes[i]
			
			datalayernum=Autolayer_wavelist(data,toplayernum,topprocnum,autolayerflag)
			
			Getlayerimage(data,datalayernum)	
			
			Wave temp_image=templayerimage
			
			if ((mappingmethodflag==2)&&(multicubeflag==0)) /// for single cube and quick method //// shift by mean phi value
				shiftvalue=w_cube_y[i]-mean_cube_y
				setscale /I x, (M_x0(temp_image)+shiftvalue),(M_x1(temp_image)+shiftvalue),temp_image
			endif
		
			if (dimflag==3) //kz
				
				scaleangle_for_kzmap(temp_image,w_cube_x[i],0)
				
				if (initialflag==0) // not normalized
					setscale /I y, (M_y0(temp_image)-w_cube_x[i]),(M_y1(temp_image)-w_cube_x[i]),temp_image
				endif
			endif
			

			temp_image*=W_normal_S[i] //normal
			
			//fe_waveform=interp2D(temp_image,x,y)
			reduce_point_2D(fe_waveform,temp_image)
		
		
		
		
			fe_waveform = (numtype(fe_waveform) ==2)?(0):fe_waveform
			//fe_waveform = (fe_waveform>maxvalue)?(maxvalue):fe_waveform
			
			cfe_rawCube[i][][] = fe_waveform[q][r]

		i += 1	 
		while (i< cn) 
	//	Killwaves/Z fe_waveform,templayerimage
		
	SetDataFolder DF
	
	return 1
End

Function reduce_point_2D(reduced_cut,original_cut)
	wave reduced_cut
	wave original_cut
	
	
	make/o/n=(dimsize(reduced_cut,0),dimsize(original_cut, 1)) temp_cut_unique
	make/o/n=(dimsize(original_cut,0)) temp_DC_unique
	setscale/P x, dimoffset(original_cut, 0),dimdelta(original_cut, 0), temp_DC_unique
	
	variable index
	for(index=0;index<dimsize(original_cut, 1);index+=1)
		temp_DC_unique=original_cut[p][index]
		temp_cut_unique[][index]=area(temp_DC_unique,dimoffset(reduced_cut,0)+(p-0.5)*dimdelta(reduced_cut,0),dimoffset(reduced_cut,0)+(p+0.5)*dimdelta(reduced_cut,0))
	endfor
	
	
	make/o/n=(dimsize(original_cut,1)) temp_DC_unique
	setscale/P x, dimoffset(original_cut, 1),dimdelta(original_cut, 1), temp_DC_unique
	
	for(index=0;index<dimsize(reduced_cut, 0);index+=1)
		temp_DC_unique=temp_cut_unique[index][p]
		reduced_cut[index][]=area(temp_DC_unique,dimoffset(reduced_cut,1)+(q-0.5)*dimdelta(reduced_cut,1),dimoffset(reduced_cut,1)+(q+0.5)*dimdelta(reduced_cut,1))
	endfor
	
	
	reduced_cut/=dimdelta(reduced_cut,0)*dimdelta(reduced_cut,1)
	killwaves temp_cut_unique, temp_DC_unique
End

Function faverage2D(image, xfrom, xto, yfrom , yto)
	wave image
	variable xfrom, xto, yfrom ,yto
	
	
	
end




Function /S Cube_note_wave_Raw_single(cubeindex,w_PathList,w_cube_x,w_cube_y,w_normal_S,toplayernum,topprocnum,gv_slicedensity,dimflag)
	Variable cubeindex
	WAVE/T w_PathList
	wave w_Cube_X,w_cube_y
	Wave w_normal_S
	Variable toplayernum,topprocnum
	Variable gv_slicedensity
	Variable dimflag	

	String notestr
	notestr  ="Cubeindex="+num2str(cubeindex)+"\r"
	notestr +="PathList="+WaveToStringList(w_PathList,";",Nan,Nan)+"\r"
	notestr += "w_normal="+NumericWaveToStringList(w_normal_S,";",Nan,Nan)+"\r"
	notestr += "toplayer="+num2str(toplayernum)+"\r"
	notestr += "topproc="+num2str(topprocnum)+"\r"
	notestr += "slicedensity="+num2str(gv_slicedensity)+"\r"
	
	if (dimflag==3) //kz
		notestr +="w_ef="+NumericWaveToStringList(w_cube_x,";",Nan,Nan)+"\r"
	endif
	
	Variable cubey=checkreturnwaveequal(w_cube_y,Nan,Nan)
	

	if (numtype(cubey)==2)
		cubey=mean(w_cube_y)
		Make /o/Free/n=(numpnts(w_cube_y_sub)) cubeysub
		cubeysub=w_cube_y[p]-cubey
		notestr +="="+NumericWaveToStringList(cubeysub,";",Nan,Nan)+"\r"
	endif

	return notestr
End



Function /S Cube_Note_Wave_single(cubeindex,w_cube_x,w_Cube_y,w_cube_p,w_cube_q,e_center,dE,Energyrangeflag,mappingmethodflag,rawmethodflag,alwaysinterpflag,interptolerate,gv_angdensity, gv_Interpmethodflag,gv_InterpSF,dimflag)
	Variable cubeindex
	Wave w_cube_x,w_cube_y,w_cube_p,w_cube_q
	Variable e_center,dE
	Variable Energyrangeflag
	Variable mappingmethodflag
	Variable rawmethodflag,alwaysinterpflag,interptolerate
	Variable gv_angdensity
	Variable gv_Interpmethodflag,gv_InterpSF
	Variable dimflag
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetDatafolder $DF_panel
	
	NVAR gammaA=gv_gammaA
	NVAR gammaA=gv_gammaA


	String notestr
	
	notestr = ""
	
	notestr += "w_cube_x="+NumericWaveToStringList(w_cube_x,";",Nan,Nan)+"\r"
	notestr += "w_cube_y="+NumericWaveToStringList(w_cube_y,";",Nan,Nan)+"\r"
	
	notestr += "w_cube_p="+NumericWaveToStringList(w_cube_p,";",Nan,Nan)+"\r"
	notestr += "w_cube_q="+NumericWaveToStringList(w_cube_q,";",Nan,Nan)+"\r"
	//notestr += "Ecenter="+num2str(e_center)+"\r"
	//notestr += "dE="+num2str(dE)+"\r"
	notestr += "Energyrangeflag="+num2str(energyrangeflag)+"\r"
	notestr += "mappingmethodflag="+num2str(mappingmethodflag)+"\r"
	notestr += "rawflag="+num2str(rawmethodflag)+"\r"
	
	notestr += "alwaysInterpflag="+num2str(alwaysInterpflag)+"\r"
	if (alwaysinterpflag==0) //auto interp
		notestr += "Interptolerate="+num2str(Interptolerate)+"\r"
	endif
	
	notestr += "angdensity="+num2str(gv_angdensity)+"\r"
	notestr += "mappingmethod="+num2str(dimflag)+"\r"
	notestr += "Interpflag="+num2str(gv_Interpmethodflag)+"\r"
	notestr += "smoothflag="+num2str(gv_InterpSF)+"\r"
	SetDatafolder DF
	return notestr
End


Function /S Cube_Note_Wave_single_DA30(cubeindex,w_cube_x,w_Cube_y,w_cube_p,w_cube_q,w_cube_r,e_center,dE,Energyrangeflag,mappingmethodflag,rawmethodflag,alwaysinterpflag,interptolerate,gv_angdensity, gv_Interpmethodflag,gv_InterpSF,dimflag)
	Variable cubeindex
	Wave w_cube_x,w_cube_y,w_cube_p,w_cube_q,w_cube_r
	Variable e_center,dE
	Variable Energyrangeflag
	Variable mappingmethodflag
	Variable rawmethodflag,alwaysinterpflag,interptolerate
	Variable gv_angdensity
	Variable gv_Interpmethodflag,gv_InterpSF
	Variable dimflag
	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetDatafolder $DF_panel
	
	NVAR gammaA=gv_gammaA
	NVAR gammaA=gv_gammaA


	String notestr
	
	notestr = ""
	
	notestr += "w_cube_x="+NumericWaveToStringList(w_cube_x,";",Nan,Nan)+"\r"
	notestr += "w_cube_y="+NumericWaveToStringList(w_cube_y,";",Nan,Nan)+"\r"
	
	notestr += "w_cube_p="+NumericWaveToStringList(w_cube_p,";",Nan,Nan)+"\r"
	notestr += "w_cube_q="+NumericWaveToStringList(w_cube_q,";",Nan,Nan)+"\r"
	notestr += "w_cube_r="+NumericWaveToStringList(w_cube_r,";",Nan,Nan)+"\r"
	//notestr += "Ecenter="+num2str(e_center)+"\r"
	//notestr += "dE="+num2str(dE)+"\r"
	notestr += "Energyrangeflag="+num2str(energyrangeflag)+"\r"
	notestr += "mappingmethodflag="+num2str(mappingmethodflag)+"\r"
	notestr += "rawflag="+num2str(rawmethodflag)+"\r"
	
	notestr += "alwaysInterpflag="+num2str(alwaysInterpflag)+"\r"
	if (alwaysinterpflag==0) //auto interp
		notestr += "Interptolerate="+num2str(Interptolerate)+"\r"
	endif
	
	notestr += "angdensity="+num2str(gv_angdensity)+"\r"
	notestr += "mappingmethod="+num2str(dimflag)+"\r"
	notestr += "Interpflag="+num2str(gv_Interpmethodflag)+"\r"
	notestr += "smoothflag="+num2str(gv_InterpSF)+"\r"
	SetDatafolder DF
	return notestr
End


////////////////Make Interp Cube/////

/// for raw and raw+precisemodes  do not interp 
///for interp and interp+ precisemode do interp if w_cube_x is not the same, do interp for w_cube_y,w_cube_p and w_cube_q
/// for quick mode do interp is the interval of w_cube_X is no larger than 2.5*mindelta

Function make_cfe_InterpCube_single(rawcubedone,cubeindex,w_cube_x,w_cube_y,w_cube_p,w_cube_q,E_Center,dE,Energyrangeflag,mappingmethodflag,rawmethodflag,alwaysinterpflag,interptolerate,gv_angdensity,dimflag) //interpflag: 0-raw 1-interp
	Variable rawcubedone,cubeindex
	Wave w_cube_x,w_cube_y,w_cube_p,w_cube_q
	Variable e_center,dE,Energyrangeflag,mappingmethodflag,rawmethodflag,alwaysinterpflag,interptolerate,gv_angdensity,dimflag
		
	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF dfR_panel=$DF_panel
	
	SetDatafolder dfR_panel
	
	NVAR gv_Ascale
	
	SVAR gs_notestring=DFR_panel:gs_notestring
	
	string rawcubename="cfe_rawCube"
	string interpcubename="cfe_interpCube"
	if (cubeindex>0)
		rawcubename+="_"+num2str(cubeindex)
		interpcubename+="_"+num2str(cubeindex)
	endif
	
	WAVE cfe_rawCube=$rawcubename
	
	NVAR gv_Interpmethodflag=DFR_panel:gv_Interpmethodflag
	NVAR gv_InterpSF=DFR_panel:gv_InterpSF
	
	String newnotestring=Cube_Note_Wave_single(cubeindex, w_cube_x,w_cube_y,w_cube_p,w_cube_q,E_center,dE,Energyrangeflag,mappingmethodflag,rawmethodflag,alwaysinterpflag,interptolerate,gv_angdensity, gv_Interpmethodflag,gv_InterpSF,dimflag)
	Wave/Z cfe_InterpCube=$interpcubename
	
	Variable moveangleflag=0
	
	if (rawcubedone==1)
	
	else
	    if (waveexists(cfe_interpCube))
		String oldnotestring=note(cfe_interpCube)
		if (stringmatch(oldnotestring,newnotestring)==1)
			gs_notestring+=newnotestring
			Setdatafolder DF
			return 2
		else
			String oldnotestringcmp=removebykey("w_cube_p",oldnotestring,"=","\r")
			oldnotestringcmp=removebykey("w_cube_q",oldnotestringcmp,"=","\r")
			String newnotestringcmp=removebykey("w_cube_p",newnotestring,"=","\r")
			newnotestringcmp=removebykey("w_cube_q",newnotestringcmp,"=","\r")
			
			if (stringmatch(oldnotestringcmp,newnotestringcmp)==1)
				moveangleflag=1
			else
				String cube_x_list=stringbykey("w_cube_x",oldnotestring,"=","\r")
				String cube_y_list=stringbykey("w_cube_y",oldnotestring,"=","\r")
				oldnotestringcmp=removebykey("w_cube_x",oldnotestringcmp,"=","\r")
				oldnotestringcmp=removebykey("w_cube_y",oldnotestringcmp,"=","\r")
				newnotestringcmp=removebykey("w_cube_x",newnotestringcmp,"=","\r")
				newnotestringcmp=removebykey("w_cube_y",newnotestringcmp,"=","\r")
			
				if (stringmatch(oldnotestringcmp,newnotestringcmp)==1)
				
					Wave w_NumberList=StringListToNumWave(cube_x_list,0,";",Nan,Nan)
					w_NumberList-=w_cube_x
					w_NumberList=round(w_NumberList*1000)/1000
				
					Variable xoff=CheckReturnWaveequal(w_NumberList,Nan,Nan)
			 
					Wave w_NumberList=StringListToNumWave(cube_y_list,0,";",Nan,Nan)
					w_NumberList-=w_cube_y
					w_NumberList=round(w_NumberList*1000)/1000
					Variable yoff=CheckReturnWaveequal(w_NumberList,Nan,Nan)
					Waveclear w_NumberList
				
					if ((numtype(xoff)!=2)&&(numtype(yoff)!=2))
						moveangleflag=1
					else
						moveangleflag=0
					endif
				endif
			endif
		endif
	    endif
	endif
	
	
	
	
	
	NVAR gammaA=gv_gammaA
	NVAR gv_Interpmethodflag=DFR_panel:gv_Interpmethodflag
	NVAR gv_InterpSF=DFR_panel:gv_InterpSF
	
	Variable x0 = wavemin(w_cube_x)//cfe_rawCube_c_axis[0]
	Variable x1 = wavemax(w_cube_x)//cfe_rawCube_c_axis[numpnts(cfe_rawCube_c_axis)-1]
	variable dx=dimdelta(cfe_rawcube,0)
	Variable dy=dimdelta(cfe_rawcube,1)
	Variable y0 = M_y0(cfe_rawCube)
	Variable y1 = M_y1(cfe_rawCube)
	Variable xn= dimsize(cfe_rawcube,0)
	Variable yn= dimsize(cfe_rawcube,1)
	Variable e0=dimoffset(cfe_rawCube,2)
	Variable e1=dimoffset(cfe_rawCube,2)+(dimsize(cfe_rawCube,2)-1)*dimdelta(cfe_rawCube,2)
	Variable en=dimsize(cfe_rawcube,2)
	
	Variable Estart,eend
	if (Energyrangeflag==0)
		Estart=0
		Eend=dimsize(cfe_rawCube,2)-1
	else
		Variable w_e0,w_e1
		w_e0=e_center-dE/2000
		w_e1=e_center+dE/2000
 
   		Eend=x2pntsmult(cfe_rawCube,w_e1,2)+1
 		Estart=x2pntsmult(cfe_rawCube,w_e0,2)-1
 		
 		if (Estart<0)
			Estart=0
		elseif (Estart>(dimsize(cfe_rawCube,2)-1))
			Estart=dimsize(cfe_rawCube,1)-1
		endif
	
		if (eend<0)
			eend=0
		elseif  (Eend>(dimsize(cfe_rawCube,2)-1))
			Eend=dimsize(cfe_rawCube,2)-1
		endif
 	endif
	
	NVAR gv_multicubeflag
	
	Variable qn=yn //along the cut, the same as rawcube
	
	Variable pn=return_pn_interpcube(cubeindex,w_cube_x,w_cube_y,w_cube_p,w_cube_q,dy,mappingmethodflag,rawmethodflag,alwaysinterpflag,interptolerate,gv_angdensity)
	
	
	String interpflagname="w_cube_x_Interpflag"
	String interpxname="w_cube_x_Interp"
	String interpyname="w_cube_y_Interp"
	String interpnum="w_cube_x_Interpnum"
	
	if (cubeindex>0)
		interpflagname+="_"+num2str(cubeindex)
		interpxname+="_"+num2str(cubeindex)
		interpyname+="_"+num2str(cubeindex)
		interpnum+="_"+num2str(cubeindex)
	endif
	
	Wave w_cube_x_interp=$interpxname
	Wave w_cube_y_interp=$interpyname
	Wave /Z w_cube_x_interpflag=$interpflagname
	Wave /Z w_cube_x_interpnum=$interpnum
	
	NVAR gv_multiphiflag
	
	if (moveangleflag==1)
	
		if (gv_multiphiflag==0)
			x0=wavemin(w_cube_x_interp)
			x1=wavemax(w_cube_x_interp)
			SetScale/I x x0, x1, ""  $interpcubename
    		else
    			SetScale/P x 0,1, ""  $interpcubename
    		endif
    		
    		Wave cfe_interpCube=$interpcubename
    	
    		note /K cfe_interpCube
    		note cfe_interpCube,newnotestring
    		gs_notestring+=newnotestring
    		Setdatafolder DF
    		return 2
    	endif
	
	
	Make/o/n=(pn,qn,en) $interpcubename
	SetScale/I y y0, y1, ""  $interpcubename
	Setscale/I z e0, e1, ""  $interpcubename
	
	
	
	if (gv_multiphiflag==0)
		x0=wavemin(w_cube_x_interp)
		x1=wavemax(w_cube_x_interp)
		SetScale/I x x0, x1, ""  $interpcubename
    	else
    		SetScale/P x 0,1, ""  $interpcubename
    	endif
    	
    	Wave cfe_interpCube=$interpcubename
    	
    	note /K cfe_interpCube
    	note cfe_interpCube,newnotestring
    	gs_notestring+=newnotestring

    	
    	Variable Enum=(Eend-Estart)+1	
    	
    	if ((mappingmethodflag!=2)&&(rawmethodflag==0)) //raw+precise do not interp
    		cfe_interpCube[][][Estart,Eend]=cfe_rawcube[p][q][r]
    	else
    		Make /o/wave /n=(qn,Enum) Interpwavelist
    	
    		if (gv_interpmethodflag==0) //only linear can use multithread
    			Multithread Interpwavelist=cal_interp_cube_thread(p,q+Estart,cfe_rawcube,w_cube_x,w_cube_x_interp,w_cube_x_interpflag,w_cube_x_interpnum,mappingmethodflag,rawmethodflag)
    		else
    			Interpwavelist=cal_interp_cube(p,q+Estart,cfe_rawcube,w_cube_x,w_cube_x_interp,w_cube_x_interpflag,w_cube_x_interpnum,mappingmethodflag,rawmethodflag,gv_interpmethodflag,gv_InterpSF)
    		endif
    		//Make /o/n=(pn,qn)
		Variable Eindex=Estart,index,i
		do
			index=0
			do
				wave  coarse_DC=Interpwavelist[index][Eindex-Estart]//cal_interp_cube(index,Eindex,cfe_rawcube,w_cube_x,w_cube_x_interp,w_cube_x_interpflag,rawmethodflag,gv_interpmethodflag,gv_InterpSF)

				cfe_interpCube[][index][Eindex]=coarse_DC[p]//cf_waveform[p][q]
				index += 1
			while (index < qn)
			Eindex+=1
		while (Eindex<(Eend+1))
    	endif
    	
    	
    	if (dimflag==3) //kz, need to restore angle scale
    		scalecube_for_kzmap(cfe_interpCube,w_cube_x_interp)
    	endif
    
    
    	SetAscale(cubeindex,gv_Ascale)
    	
     	SetDatafolder DF
     	return 1

End


Function make_cfe_InterpCube_single_DA30(rawcubedone,cubeindex,w_cube_x,w_cube_y,w_cube_p,w_cube_q,w_cube_r,E_Center,dE,Energyrangeflag,mappingmethodflag,rawmethodflag,alwaysinterpflag,interptolerate,gv_angdensity,dimflag) //interpflag: 0-raw 1-interp
	Variable rawcubedone,cubeindex
	Wave w_cube_x,w_cube_y,w_cube_p,w_cube_q, w_cube_r
	Variable e_center,dE,Energyrangeflag,mappingmethodflag,rawmethodflag,alwaysinterpflag,interptolerate,gv_angdensity,dimflag
		
	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF dfR_panel=$DF_panel
	
	SetDatafolder dfR_panel
	
	NVAR gv_Ascale
	
	SVAR gs_notestring=DFR_panel:gs_notestring
	
	string rawcubename="cfe_rawCube"
	string interpcubename="cfe_interpCube"
	if (cubeindex>0)
		rawcubename+="_"+num2str(cubeindex)
		interpcubename+="_"+num2str(cubeindex)
	endif
	
	WAVE cfe_rawCube=$rawcubename
	
	NVAR gv_Interpmethodflag=DFR_panel:gv_Interpmethodflag
	NVAR gv_InterpSF=DFR_panel:gv_InterpSF

	String newnotestring=Cube_Note_Wave_single_DA30(cubeindex, w_cube_x,w_cube_y,w_cube_p,w_cube_q,w_cube_r,E_center,dE,Energyrangeflag,mappingmethodflag,rawmethodflag,alwaysinterpflag,interptolerate,gv_angdensity, gv_Interpmethodflag,gv_InterpSF,dimflag)
	Wave/Z cfe_InterpCube=$interpcubename
	
	Variable moveangleflag=0
	
	if (rawcubedone==1)
	
	else
	    if (waveexists(cfe_interpCube))
		String oldnotestring=note(cfe_interpCube)
		if (stringmatch(oldnotestring,newnotestring)==1)
			gs_notestring+=newnotestring
			Setdatafolder DF
			return 2
		else
			String oldnotestringcmp=removebykey("w_cube_p",oldnotestring,"=","\r")
			oldnotestringcmp=removebykey("w_cube_q",oldnotestringcmp,"=","\r")
			String newnotestringcmp=removebykey("w_cube_p",newnotestring,"=","\r")
			newnotestringcmp=removebykey("w_cube_q",newnotestringcmp,"=","\r")
			
			if (stringmatch(oldnotestringcmp,newnotestringcmp)==1)
				moveangleflag=1
			else
				String cube_x_list=stringbykey("w_cube_x",oldnotestring,"=","\r")
				String cube_y_list=stringbykey("w_cube_y",oldnotestring,"=","\r")
				oldnotestringcmp=removebykey("w_cube_x",oldnotestringcmp,"=","\r")
				oldnotestringcmp=removebykey("w_cube_y",oldnotestringcmp,"=","\r")
				newnotestringcmp=removebykey("w_cube_x",newnotestringcmp,"=","\r")
				newnotestringcmp=removebykey("w_cube_y",newnotestringcmp,"=","\r")
			
				if (stringmatch(oldnotestringcmp,newnotestringcmp)==1)
				
					Wave w_NumberList=StringListToNumWave(cube_x_list,0,";",Nan,Nan)
					w_NumberList-=w_cube_x
					w_NumberList=round(w_NumberList*1000)/1000
				
					Variable xoff=CheckReturnWaveequal(w_NumberList,Nan,Nan)
			 
					Wave w_NumberList=StringListToNumWave(cube_y_list,0,";",Nan,Nan)
					w_NumberList-=w_cube_y
					w_NumberList=round(w_NumberList*1000)/1000
					Variable yoff=CheckReturnWaveequal(w_NumberList,Nan,Nan)
					Waveclear w_NumberList
				
					if ((numtype(xoff)!=2)&&(numtype(yoff)!=2))
						moveangleflag=1
					else
						moveangleflag=0
					endif
				endif
			endif
		endif
	    endif
	endif
	
	
	
	
	
	NVAR gammaA=gv_gammaA
	NVAR gv_Interpmethodflag=DFR_panel:gv_Interpmethodflag
	NVAR gv_InterpSF=DFR_panel:gv_InterpSF
	
	Variable x0 = wavemin(w_cube_x)//cfe_rawCube_c_axis[0]
	Variable x1 = wavemax(w_cube_x)//cfe_rawCube_c_axis[numpnts(cfe_rawCube_c_axis)-1]
	variable dx=dimdelta(cfe_rawcube,0)
	Variable dy=dimdelta(cfe_rawcube,1)
	Variable y0 = M_y0(cfe_rawCube)
	Variable y1 = M_y1(cfe_rawCube)
	Variable xn= dimsize(cfe_rawcube,0)
	Variable yn= dimsize(cfe_rawcube,1)
	Variable e0=dimoffset(cfe_rawCube,2)
	Variable e1=dimoffset(cfe_rawCube,2)+(dimsize(cfe_rawCube,2)-1)*dimdelta(cfe_rawCube,2)
	Variable en=dimsize(cfe_rawcube,2)
	
	Variable Estart,eend
	if (Energyrangeflag==0)
		Estart=0
		Eend=dimsize(cfe_rawCube,2)-1
	else
		Variable w_e0,w_e1
		w_e0=e_center-dE/2000
		w_e1=e_center+dE/2000
 
   		Eend=x2pntsmult(cfe_rawCube,w_e1,2)+1
 		Estart=x2pntsmult(cfe_rawCube,w_e0,2)-1
 		
 		if (Estart<0)
			Estart=0
		elseif (Estart>(dimsize(cfe_rawCube,2)-1))
			Estart=dimsize(cfe_rawCube,1)-1
		endif
	
		if (eend<0)
			eend=0
		elseif  (Eend>(dimsize(cfe_rawCube,2)-1))
			Eend=dimsize(cfe_rawCube,2)-1
		endif
 	endif
	
	NVAR gv_multicubeflag
	
	Variable qn=yn //along the cut, the same as rawcube
	
	Variable pn=return_pn_interpcube_DA30(cubeindex,w_cube_x,w_cube_y,w_cube_p,w_cube_q,w_cube_r,dy,mappingmethodflag,rawmethodflag,alwaysinterpflag,interptolerate,gv_angdensity)
	
	String interpflagname="w_cube_x_Interpflag"
	String interpxname="w_cube_x_Interp"
	String interpyname="w_cube_y_Interp"
	String interpnum="w_cube_x_Interpnum"
	
	if (cubeindex>0)
		interpflagname+="_"+num2str(cubeindex)
		interpxname+="_"+num2str(cubeindex)
		interpyname+="_"+num2str(cubeindex)
		interpnum+="_"+num2str(cubeindex)
	endif
	
	Wave w_cube_x_interp=$interpxname
	Wave w_cube_y_interp=$interpyname
	Wave /Z w_cube_x_interpflag=$interpflagname
	Wave /Z w_cube_x_interpnum=$interpnum
	
	NVAR gv_multiphiflag
	
	if (moveangleflag==1)
	
		if (gv_multiphiflag==0)
			x0=wavemin(w_cube_x_interp)
			x1=wavemax(w_cube_x_interp)
			SetScale/I x x0, x1, ""  $interpcubename
    		else
    			SetScale/P x 0,1, ""  $interpcubename
    		endif
    		
    		Wave cfe_interpCube=$interpcubename
    	
    		note /K cfe_interpCube
    		note cfe_interpCube,newnotestring
    		gs_notestring+=newnotestring
    		Setdatafolder DF
    		return 2
    	endif
	
	
	Make/o/n=(pn,qn,en) $interpcubename
	SetScale/I y y0, y1, ""  $interpcubename
	Setscale/I z e0, e1, ""  $interpcubename
	
	
	
	if (gv_multiphiflag==0)
		x0=wavemin(w_cube_x_interp)
		x1=wavemax(w_cube_x_interp)
		SetScale/I x x0, x1, ""  $interpcubename
    	else
    		SetScale/P x 0,1, ""  $interpcubename
    	endif
    	
    	Wave cfe_interpCube=$interpcubename
    	
    	note /K cfe_interpCube
    	note cfe_interpCube,newnotestring
    	gs_notestring+=newnotestring

    	
    	Variable Enum=(Eend-Estart)+1	
    	
    	if ((mappingmethodflag!=2)&&(rawmethodflag==0)) //raw+precise do not interp
    		cfe_interpCube[][][Estart,Eend]=cfe_rawcube[p][q][r]
    	else
    		Make /o/wave /n=(qn,Enum) Interpwavelist
    	
    		if (gv_interpmethodflag==0) //only linear can use multithread
    			Multithread Interpwavelist=cal_interp_cube_thread(p,q+Estart,cfe_rawcube,w_cube_x,w_cube_x_interp,w_cube_x_interpflag,w_cube_x_interpnum,mappingmethodflag,rawmethodflag)
    		else
    			Interpwavelist=cal_interp_cube(p,q+Estart,cfe_rawcube,w_cube_x,w_cube_x_interp,w_cube_x_interpflag,w_cube_x_interpnum,mappingmethodflag,rawmethodflag,gv_interpmethodflag,gv_InterpSF)
    		endif
    		//Make /o/n=(pn,qn)
		Variable Eindex=Estart,index,i
		do
			index=0
			do
				wave  coarse_DC=Interpwavelist[index][Eindex-Estart]//cal_interp_cube(index,Eindex,cfe_rawcube,w_cube_x,w_cube_x_interp,w_cube_x_interpflag,rawmethodflag,gv_interpmethodflag,gv_InterpSF)

				cfe_interpCube[][index][Eindex]=coarse_DC[p]//cf_waveform[p][q]
				index += 1
			while (index < qn)
			Eindex+=1
		while (Eindex<(Eend+1))
    	endif
    	
    	
    	if (dimflag==3) //kz, need to restore angle scale
    		scalecube_for_kzmap(cfe_interpCube,w_cube_x_interp)
    	endif
    
    
    	SetAscale(cubeindex,gv_Ascale)
    	
     	SetDatafolder DF
     	return 1

End


Threadsafe Function /WAVE cal_interp_cube_thread(slicenum,energynum,rawcube,w_cube_x,w_cube_x_interp,w_cube_x_interpflag,w_cube_x_interpnum,mappingmethodflag,rawmethodflag)
	Variable slicenum, energynum
	Wave rawcube
	wave w_cube_x
	Wave w_cube_x_interp
	Wave w_cube_x_interpflag,w_cube_x_interpnum
	Variable mappingmethodflag,rawmethodflag
	
	DFREF DF=GetDatafolderDFR()
	
	DFREF newdf=newFreedatafolder()
	
	SetDatafolder newdf
	
	if (sum(w_cube_x_interpflag)==numpnts(w_cube_x_interpflag)) ///all interp
		Make /o/n= (dimsize(rawcube,0)) rawDC,rawDC_X
		Make /o/n=(numpnts(w_cube_x_interp)) InterpDC,InterpDC_X
		InterpDC_x=w_cube_x_interp[p]
		rawDC=rawcube[p][slicenum][energynum]
		rawDC_x=w_cube_x[p]
		
		Cal_interp_DC_thread(rawmethodflag,rawDC_x,rawDC,InterpDC_x,InterpDC)
		
		SetDatafolder DF
		
		return InterpDC
	else
		Make /o/n=(numpnts(w_cube_x_interp)) InterpDC_sum
		Variable index=0
		Variable cutnum=0,cutstart=0
		Variable Interpstart=0,Interpnum=0
		do
			if (w_cube_x_interpflag[index]==1)
				cutnum+=1
			else
				Make /o/n= (cutnum) rawDC,rawDC_x
				rawDC=rawcube[cutstart+p][slicenum][energynum]
				rawDC_x=w_cube_x[cutstart+p]
				
				Interpnum=w_cube_x_interpnum[index-1]-Interpstart
				Make /o/n=(Interpnum) InterpDC
				Make /o/n=(Interpnum) InterpDC_x
				InterpDC_x=w_cube_x_interp[Interpstart+p]
				
				Cal_interp_DC_thread(rawmethodflag,rawDC_x,rawDC,InterpDC_x,InterpDC)
				
				InterpDC_sum[Interpstart,w_cube_x_interpnum[index-1]-1]=InterpDC[p-Interpstart]
				
				cutnum=1
				cutstart=Index
				Interpstart=w_cube_x_interpnum[index]
			endif
			index+=1
		while (index<numpnts(w_cube_x_interpflag))
	
		Make /o/n= (cutnum) rawDC,rawDC_x
		rawDC=rawcube[cutstart+p][slicenum][energynum]
		rawDC_x=w_cube_x[cutstart+p]
				
		Interpnum=w_cube_x_interpnum[index-1]-Interpstart
		Make /o/n=(Interpnum) InterpDC
		Make /o/n=(Interpnum) InterpDC_x
		InterpDC_x=w_cube_x_interp[Interpstart+p]
		
		Cal_interp_DC_thread(rawmethodflag,rawDC_x,rawDC,InterpDC_x,InterpDC)
		
		InterpDC_sum[Interpstart,w_cube_x_interpnum[index-1]-1]=InterpDC[p-Interpstart]
		
		SetDatafolder DF
		
		return InterpDC_sum
	endif
	

End


Threadsafe Function /Wave Cal_interp_DC_thread(rawmethodflag,rawDC_x,rawDC,InterpDC_x,InterpDC)
	Variable rawmethodflag
	Wave rawDC_x,rawDC
	Wave InterpDC_x,InterpDC

	if (rawmethodflag) // interp
			InterpDC=interp(interpDC_x[p],rawDC_x,rawDC)
		else //select from raw
			Variable index,pindex
			Variable xtemp,xtempflag
			Variable mintheta=wave_mindelta(rawDC_x)	
			do
				xtemp=InterpDC_x[index]
				xtempflag=0
				pindex=0
				do 
					if (abs(xtemp-rawDC_x[pindex])<mintheta)
						xtempflag=1
						InterpDC[index]=rawDC[pindex]
						break
					endif
					pindex+=1
				while (pindex<numpnts(rawDC))
				if (xtempflag==0)
					InterpDC[index]=Nan
				endif
				index+=1
			while (index<numpnts(InterpDC))
		endif
		return InterpDC
End



Function /WAVE cal_interp_cube(slicenum,energynum,rawcube,w_cube_x,w_cube_x_interp,w_cube_x_interpflag,w_cube_x_interpnum,mappingmethodflag,rawmethodflag,gv_interpmethodflag,gv_InterpSF)
	Variable slicenum, energynum
	Wave rawcube
	wave w_cube_x
	Wave w_cube_x_interp
	Wave w_cube_x_interpflag,w_cube_x_interpnum
	Variable mappingmethodflag,rawmethodflag,gv_interpmethodflag,gv_interpSF
	
	DFREF DF=GetDatafolderDFR()
	
	DFREF newdf=newFreedatafolder()
	
	SetDatafolder newdf
	
	if (sum(w_cube_x_interpflag)==numpnts(w_cube_x_interpflag)) ///all interp
		Make /o/n= (dimsize(rawcube,0)) rawDC
		Make /o/n= (dimsize(rawcube,0)) rawDC_x
		Make /o/n=(numpnts(w_cube_x_interp)) InterpDC
		Make /o/n=(numpnts(w_cube_x_interp)) InterpDC_x
		InterpDC_x=w_cube_x_interp[p]
		rawDC=rawcube[p][slicenum][energynum]
		rawDC_x=w_cube_x[p]
		
		Wave InterpDC=Cal_interp_DC(rawmethodflag,rawDC_x,rawDC,InterpDC_x,InterpDC,gv_Interpmethodflag,gv_InterpSF)
		
		SetDatafolder DF
		return InterpDC
		
	else
		Make /FREE/n=(numpnts(w_cube_x_interp)) InterpDC_sum
		Variable index=0
		Variable cutnum=0,cutstart=0
		Variable Interpstart=0,Interpnum=0
		do
			if (w_cube_x_interpflag[index]==1)
				cutnum+=1
			else
				Make /o/n= (cutnum) rawDC,rawDC_x
				rawDC=rawcube[cutstart+p][slicenum][energynum]
				rawDC_x=w_cube_x[cutstart+p]
				
				Interpnum=w_cube_x_interpnum[index-1]-Interpstart
				Make /o/n=(Interpnum) InterpDC
				Make /o/n=(Interpnum) InterpDC_x
				InterpDC_x=w_cube_x_interp[Interpstart+p]
				
				Wave InterpDC=Cal_interp_DC(rawmethodflag,rawDC_x,rawDC,InterpDC_x,InterpDC,gv_Interpmethodflag,gv_InterpSF)
				
				InterpDC_sum[Interpstart,w_cube_x_interpnum[index-1]-1]=InterpDC[p-Interpstart]
				
				cutnum=1
				cutstart=Index
				Interpstart=w_cube_x_interpnum[index]
			endif
			index+=1
		while (index<numpnts(w_cube_x_interpflag))
		
		Make /o/n= (cutnum) rawDC,rawDC_x
		rawDC=rawcube[cutstart+p][slicenum][energynum]
		rawDC_x=w_cube_x[cutstart+p]
				
		Interpnum=w_cube_x_interpnum[index-1]-Interpstart
		Make /o/n=(Interpnum) InterpDC
		Make /o/n=(Interpnum) InterpDC_x
		InterpDC_x=w_cube_x_interp[Interpstart+p]
				
		Wave InterpDC=Cal_interp_DC(rawmethodflag,rawDC_x,rawDC,InterpDC_x,InterpDC,gv_Interpmethodflag,gv_InterpSF)
		
		InterpDC_sum[Interpstart,w_cube_x_interpnum[index-1]-1]=InterpDC[p-Interpstart]
		
		SetDatafolder DF
		
		return InterpDC_sum
	endif
	
End

Function /Wave Cal_interp_DC(rawmethodflag,rawDC_x,rawDC,InterpDC_x,InterpDC,Interpmethodflag,InterpSF)
	Variable rawmethodflag
	Wave rawDC_x,rawDC
	Wave InterpDC_x,InterpDC
	Variable interpmethodflag,InterpSF
	
	if (rawmethodflag) // interp
			if (numpnts(RawDC)<4)
					InterpDC=interp(InterpDC_x[p],rawDC_x,rawDC)//nan
			else
				switch(Interpmethodflag)
				case 0: //liner
					//InterpDC=interp(w_cube_x_interp[p],w_cube_x,rawDC)
					Interpolate2 /T=1 /I=3 /X=InterpDC_x /Y=InterpDC rawDC_x,rawDC
					break
				case 1:
					Interpolate2/T=2 /I=3 /X=InterpDC_x /Y=InterpDC rawDC_x,rawDC
					break
				case 2:
					Interpolate2/T=3 /F=(InterpSF) /I=3 /X=InterpDC_x /Y=InterpDC rawDC_x,rawDC
					break
				endswitch
			endif
	else //select from raw
			Variable index,pindex
			Variable xtemp,xtempflag
			Variable mintheta=wave_mindelta(rawDC_x)	
			do
				xtemp=InterpDC_x[index]
				xtempflag=0
				pindex=0
				do 
					if (abs(xtemp-rawDC_x[pindex])<mintheta)
						xtempflag=1
						InterpDC[index]=rawDC[pindex]
						break
					endif
					pindex+=1
				while (pindex<numpnts(rawDC))
				if (xtempflag==0)
					InterpDC[index]=Nan
				endif
				index+=1
			while (index<numpnts(InterpDC))
		endif
	return InterpDC
End


Function return_pn_interpcube(cubeindex,w_cube_x,w_cube_y,w_cube_p,w_cube_q,dy,mappingmethodflag,rawmethodflag,alwaysinterpflag,interptolerate,gv_angdensity)
	Variable cubeindex
	wave w_cube_y,w_cube_x,w_cube_p,w_cube_q
	Variable dy,mappingmethodflag,rawmethodflag,alwaysinterpflag,interptolerate,gv_angdensity
	
	String interpflagname="w_cube_x_Interpflag"
	String interpxname="w_cube_x_Interp"
	String interpyname="w_cube_y_Interp"
	String interppname="w_cube_p_Interp"
	String interpqname="w_cube_q_Interp"
	
	String interpnumname="w_cube_x_Interpnum"
	
	Variable /G gv_multiphiFlag
	
	if (cubeindex>0)
		interpflagname+="_"+num2str(cubeindex)
		interpxname+="_"+num2str(cubeindex)
		interpyname+="_"+num2str(cubeindex)
		interppname+="_"+num2str(cubeindex)
		interpqname+="_"+num2str(cubeindex)
		interpnumname+="_"+num2str(cubeindex)
	endif
	
	if ((mappingmethodflag!=2)&&(rawmethodflag==0))  //for raw and raw scatter mode  // do not interp
		gv_multiphiFlag=1
		Variable pn=numpnts(w_cube_x)
		
		Duplicate /o w_cube_x $interpflagname,$interpnumname
		Wave w_cube_x_Interpflag=$interpflagname
		w_cube_x_Interpflag=0
		Wave w_cube_x_Interpnum=$interpnumname
		w_cube_x_Interpnum=p
		
		Duplicate /o w_cube_x $interpxname
		Duplicate /o w_cube_y $interpyname
		Duplicate /o w_cube_p $interppname
		Duplicate /o w_cube_q $interpqname
		
		return pn
	endif
	
	if (rawmethodflag==0)
		Variable dtheta= wave_mindelta(w_cube_x)
	else
		if (numtype(gv_angdensity)==2)
			dtheta= min(wave_mindelta(w_cube_x), dy)
		else
			dtheta=gv_angdensity
		endif
	endif	
		
	Make /o/n=(numpnts(w_cube_x)) $interpflagname
	Wave w_cube_x_Interpflag=$interpflagname
	make /o/n=(numpnts(w_cube_x)) $interpnumname
	Wave w_cube_x_Interpnum=$interpnumname
	Variable mintheta=interptolerate*wave_mindelta(w_cube_x)	
	
	
	if (mappingmethodflag==2) //quick mode // single value for cube y,p,q
		Variable cubey=mean(w_cube_y)//checkreturnwaveequal(w_cube_y,Nan,Nan) 
		gv_multiphiFlag=0
		
		Variable x1=wavemax(w_cube_x)
		Variable x0=wavemin(w_cube_x)
		pn=round(abs(x1-x0 )/dtheta)+1
		
		Variable pnum=0
		make /o/n=(pn) $interpxname,$interpyname
		Wave w_cube_x_Interp=$interpxname
		wave w_cube_y_interp=$interpyname
		setscale /I x, x0,x1,w_cube_x_Interp
		w_cube_x_Interp=x
		w_cube_y_interp=cubey
		
		make /o/n=(pn) $interppname,$interpqname
		Wave w_cube_p_interp=$interppname
		Wave w_cube_q_interp=$interpqname
		w_cube_p_interp=mean(w_cube_p)//checkreturnwaveequal(w_cube_p,Nan,Nan) 
		w_cube_q_interp=mean(w_cube_q)//checkreturnwaveequal(w_cube_q,Nan,Nan) 
		
	
		
		w_cube_x_Interpflag[0]=1
		w_cube_x_Interpnum[0]=0
		
		
		Variable index
		index=1
		do
			if (alwaysinterpflag==1)
				w_cube_x_Interpflag[index]=1
			else
				if ((abs(w_cube_x[index]-w_cube_x[index-1])<mintheta)&&(abs(w_cube_x[index]-w_cube_x[index-1])>1e-5))
					w_cube_x_Interpflag[index]=1
				else
					w_cube_x_Interpflag[index]=0
				endif
			endif
			
			w_cube_x_Interpnum[index]=x2pnt(w_cube_x_Interp,w_cube_x[index])
			
			index+=1
		while (index<(numpnts(w_cube_y)))
		
	else  ///for interpmode and interp scatter mode,  also interp y,q,p 
		gv_multiphiFlag=1
		
		Variable tempdf
		
		pn=1
		pnum=0
		make /o/n=(1) $interpxname,$interpyname,$interppname,$interpqname
		Wave w_cube_x_Interp=$interpxname
		wave w_cube_y_interp=$interpyname
		wave w_cube_p_interp=$interppname
		Wave w_Cube_q_interp=$interpqname
		
		w_cube_x_interp[0]=w_cube_x[0]
		w_cube_y_interp[0]=w_cube_y[0]
		w_cube_p_interp[0]=w_cube_p[0]
		w_cube_q_interp[0]=w_cube_q[0]
		
		w_cube_x_Interpflag[0]=1
		w_cube_x_Interpnum[0]=0
		
		
		index=1
		do
			if (alwaysinterpflag==1)
				w_cube_x_Interpflag[index]=1
				pnum=round(abs(w_cube_x[index]-w_cube_x[index-1])/dtheta)
				Insertpoints inf, pnum,w_cube_x_interp,w_cube_y_interp,w_cube_p_interp,w_Cube_q_interp
				
				tempdf=(w_cube_x[index]-w_cube_x[index-1])/pnum
				w_cube_x_interp[pn,pn+pnum-1]=w_cube_x[index-1]+tempdf*(p-pn+1)
				
				tempdf=(w_cube_y[index]-w_cube_y[index-1])/pnum
				w_cube_y_interp[pn,pn+pnum-1]=w_cube_y[index-1]+tempdf*(p-pn+1)
				tempdf=(w_cube_p[index]-w_cube_p[index-1])/pnum
				w_cube_p_interp[pn,pn+pnum-1]=w_cube_p[index-1]+tempdf*(p-pn+1)
				tempdf=(w_cube_q[index]-w_cube_q[index-1])/pnum
				w_cube_q_interp[pn,pn+pnum-1]=w_cube_q[index-1]+tempdf*(p-pn+1)	
			else
				if ((abs(w_cube_x[index]-w_cube_x[index-1])<mintheta)&&(abs(w_cube_x[index]-w_cube_x[index-1])>1e-5))
					w_cube_x_Interpflag[index]=1
					pnum=round(abs(w_cube_x[index]-w_cube_x[index-1])/dtheta)
					Insertpoints inf, pnum,w_cube_x_interp,w_cube_y_interp,w_cube_p_interp,w_Cube_q_interp
				
					tempdf=(w_cube_x[index]-w_cube_x[index-1])/pnum
					w_cube_x_interp[pn,pn+pnum-1]=w_cube_x[index-1]+tempdf*(p-pn+1)
				
					tempdf=(w_cube_y[index]-w_cube_y[index-1])/pnum
					w_cube_y_interp[pn,pn+pnum-1]=w_cube_y[index-1]+tempdf*(p-pn+1)
					tempdf=(w_cube_p[index]-w_cube_p[index-1])/pnum
					w_cube_p_interp[pn,pn+pnum-1]=w_cube_p[index-1]+tempdf*(p-pn+1)
					tempdf=(w_cube_q[index]-w_cube_q[index-1])/pnum
					w_cube_q_interp[pn,pn+pnum-1]=w_cube_q[index-1]+tempdf*(p-pn+1)
				else
					w_cube_x_Interpflag[index]=0
					pnum=1
					Insertpoints inf, pnum,w_cube_x_interp,w_cube_y_interp,w_cube_p_interp,w_Cube_q_interp
					w_cube_x_interp[pn,pn+pnum-1]=w_cube_x[index]
					w_cube_y_interp[pn,pn+pnum-1]=w_cube_y[index]
					w_cube_p_interp[pn,pn+pnum-1]=w_cube_p[index]
					w_cube_q_interp[pn,pn+pnum-1]=w_cube_q[index]
				endif
			endif
			pn+=pnum
			w_cube_x_Interpnum[index]=pn-1
			
			index+=1
		while (index<(numpnts(w_cube_x)))		
		
	endif
	
	return pn
End


Function return_pn_interpcube_DA30(cubeindex,w_cube_x,w_cube_y,w_cube_p,w_cube_q,w_cube_r,dy,mappingmethodflag,rawmethodflag,alwaysinterpflag,interptolerate,gv_angdensity)
	Variable cubeindex
	wave w_cube_y,w_cube_x,w_cube_p,w_cube_q,w_cube_r
	Variable dy,mappingmethodflag,rawmethodflag,alwaysinterpflag,interptolerate,gv_angdensity
	
	String interpflagname="w_cube_x_Interpflag"
	String interpxname="w_cube_x_Interp"
	String interpyname="w_cube_y_Interp"
	String interppname="w_cube_p_Interp"
	String interpqname="w_cube_q_Interp"
	String interprname="w_cube_r_Interp"
	
	String interpnumname="w_cube_x_Interpnum"
	
	Variable /G gv_multiphiFlag
	
	if (cubeindex>0)
		interpflagname+="_"+num2str(cubeindex)
		interpxname+="_"+num2str(cubeindex)
		interpyname+="_"+num2str(cubeindex)
		interppname+="_"+num2str(cubeindex)
		interpqname+="_"+num2str(cubeindex)
		interprname+="_"+num2str(cubeindex)
		interpnumname+="_"+num2str(cubeindex)
	endif
	
	if ((mappingmethodflag!=2)&&(rawmethodflag==0))  //for raw and raw scatter mode  // do not interp
		gv_multiphiFlag=1
		Variable pn=numpnts(w_cube_x)
		
		Duplicate /o w_cube_x $interpflagname,$interpnumname
		Wave w_cube_x_Interpflag=$interpflagname
		w_cube_x_Interpflag=0
		Wave w_cube_x_Interpnum=$interpnumname
		w_cube_x_Interpnum=p
		
		Duplicate /o w_cube_x $interpxname
		Duplicate /o w_cube_y $interpyname
		Duplicate /o w_cube_p $interppname
		Duplicate /o w_cube_q $interpqname
		Duplicate /o w_cube_r $interprname
		
		return pn
	endif
	
	if (rawmethodflag==0)
		Variable d_deflectorY= wave_mindelta(w_cube_x)
	else
		if (numtype(gv_angdensity)==2)
			d_deflectorY= min(wave_mindelta(w_cube_x), dy)
		else
			d_deflectorY=gv_angdensity
		endif
	endif	
		
	Make /o/n=(numpnts(w_cube_x)) $interpflagname
	Wave w_cube_x_Interpflag=$interpflagname
	make /o/n=(numpnts(w_cube_x)) $interpnumname
	Wave w_cube_x_Interpnum=$interpnumname
	Variable min_deflectorY=interptolerate*wave_mindelta(w_cube_x)	
	
	
	if (mappingmethodflag==2) //quick mode // single value for cube y,p,q,r
		Variable cubey=mean(w_cube_y)//checkreturnwaveequal(w_cube_y,Nan,Nan) 
		gv_multiphiFlag=0
		
		Variable x1=wavemax(w_cube_x)
		Variable x0=wavemin(w_cube_x)
		pn=round(abs(x1-x0 )/d_deflectorY)+1
		
		Variable pnum=0
		make /o/n=(pn) $interpxname,$interpyname
		Wave w_cube_x_Interp=$interpxname
		wave w_cube_y_interp=$interpyname
		setscale /I x, x0,x1,w_cube_x_Interp
		w_cube_x_Interp=x
		w_cube_y_interp=cubey
		
		make /o/n=(pn) $interppname,$interpqname,$interprname
		Wave w_cube_p_interp=$interppname
		Wave w_cube_q_interp=$interpqname
		Wave w_cube_r_interp=$interprname
		w_cube_p_interp=mean(w_cube_p)//checkreturnwaveequal(w_cube_p,Nan,Nan) 
		w_cube_q_interp=mean(w_cube_q)//checkreturnwaveequal(w_cube_q,Nan,Nan) 
		w_cube_r_interp=mean(w_cube_r)//checkreturnwaveequal(w_cube_q,Nan,Nan) 
	
		
		w_cube_x_Interpflag[0]=1
		w_cube_x_Interpnum[0]=0
		
		
		Variable index
		index=1
		do
			if (alwaysinterpflag==1)
				w_cube_x_Interpflag[index]=1
			else
				if ((abs(w_cube_x[index]-w_cube_x[index-1])<min_deflectorY)&&(abs(w_cube_x[index]-w_cube_x[index-1])>1e-5))
					w_cube_x_Interpflag[index]=1
				else
					w_cube_x_Interpflag[index]=0
				endif
			endif
			
			w_cube_x_Interpnum[index]=x2pnt(w_cube_x_Interp,w_cube_x[index])
			
			index+=1
		while (index<(numpnts(w_cube_y)))
		
	else  ///for interpmode and interp scatter mode,  also interp y,q,p,r
		gv_multiphiFlag=1
		
		Variable tempdf
		
		pn=1
		pnum=0
		make /o/n=(1) $interpxname,$interpyname,$interppname,$interpqname
		Wave w_cube_x_Interp=$interpxname
		wave w_cube_y_interp=$interpyname
		wave w_cube_p_interp=$interppname
		Wave w_Cube_q_interp=$interpqname
		Wave w_Cube_r_interp=$interprname
		
		w_cube_x_interp[0]=w_cube_x[0]
		w_cube_y_interp[0]=w_cube_y[0]
		w_cube_p_interp[0]=w_cube_p[0]
		w_cube_q_interp[0]=w_cube_q[0]
		w_cube_r_interp[0]=w_cube_r[0]
		
		w_cube_x_Interpflag[0]=1
		w_cube_x_Interpnum[0]=0
		
		
		index=1
		do
			if (alwaysinterpflag==1)
				w_cube_x_Interpflag[index]=1
				pnum=round(abs(w_cube_x[index]-w_cube_x[index-1])/d_deflectorY)
				Insertpoints inf, pnum,w_cube_x_interp,w_cube_y_interp,w_cube_p_interp,w_Cube_q_interp,w_Cube_r_interp
				
				tempdf=(w_cube_x[index]-w_cube_x[index-1])/pnum
				w_cube_x_interp[pn,pn+pnum-1]=w_cube_x[index-1]+tempdf*(p-pn+1)
				
				tempdf=(w_cube_y[index]-w_cube_y[index-1])/pnum
				w_cube_y_interp[pn,pn+pnum-1]=w_cube_y[index-1]+tempdf*(p-pn+1)
				tempdf=(w_cube_p[index]-w_cube_p[index-1])/pnum
				w_cube_p_interp[pn,pn+pnum-1]=w_cube_p[index-1]+tempdf*(p-pn+1)
				tempdf=(w_cube_q[index]-w_cube_q[index-1])/pnum
				w_cube_q_interp[pn,pn+pnum-1]=w_cube_q[index-1]+tempdf*(p-pn+1)	
				tempdf=(w_cube_r[index]-w_cube_r[index-1])/pnum
				w_cube_r_interp[pn,pn+pnum-1]=w_cube_r[index-1]+tempdf*(p-pn+1)	
				
				
				
				
			else
				if ((abs(w_cube_x[index]-w_cube_x[index-1])<min_deflectorY)&&(abs(w_cube_x[index]-w_cube_x[index-1])>1e-5))
					w_cube_x_Interpflag[index]=1
					pnum=round(abs(w_cube_x[index]-w_cube_x[index-1])/d_deflectorY)
					Insertpoints inf, pnum,w_cube_x_interp,w_cube_y_interp,w_cube_p_interp,w_Cube_q_interp,w_Cube_r_interp
				
					tempdf=(w_cube_x[index]-w_cube_x[index-1])/pnum
					w_cube_x_interp[pn,pn+pnum-1]=w_cube_x[index-1]+tempdf*(p-pn+1)
				
					tempdf=(w_cube_y[index]-w_cube_y[index-1])/pnum
					w_cube_y_interp[pn,pn+pnum-1]=w_cube_y[index-1]+tempdf*(p-pn+1)
					tempdf=(w_cube_p[index]-w_cube_p[index-1])/pnum
					w_cube_p_interp[pn,pn+pnum-1]=w_cube_p[index-1]+tempdf*(p-pn+1)
					tempdf=(w_cube_q[index]-w_cube_q[index-1])/pnum
					w_cube_q_interp[pn,pn+pnum-1]=w_cube_q[index-1]+tempdf*(p-pn+1)
					tempdf=(w_cube_r[index]-w_cube_r[index-1])/pnum
					w_cube_r_interp[pn,pn+pnum-1]=w_cube_r[index-1]+tempdf*(p-pn+1)
				else
					w_cube_x_Interpflag[index]=0
					pnum=1
					Insertpoints inf, pnum,w_cube_x_interp,w_cube_y_interp,w_cube_p_interp,w_Cube_q_interp,w_Cube_r_interp
				
					w_cube_x_interp[pn,pn+pnum-1]=w_cube_x[index]
					w_cube_y_interp[pn,pn+pnum-1]=w_cube_y[index]
					w_cube_p_interp[pn,pn+pnum-1]=w_cube_p[index]
					w_cube_q_interp[pn,pn+pnum-1]=w_cube_q[index]
					w_cube_r_interp[pn,pn+pnum-1]=w_cube_r[index]
				endif
			endif
			pn+=pnum
			w_cube_x_Interpnum[index]=pn-1
			
			index+=1
		while (index<(numpnts(w_cube_x)))		
		
	endif
	
	return pn
End


////////////////////////////////////Core Function for mapping//////////////////////////

Function Cal_3D_FSM(cubeindex)
	Variable cubeindex
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	SetActiveSubwindow $winname(0,65)
	
	SetDatafolder DFR_panel
	
	DFREF DFR_global=$DF_global
	NVAR gv_sampleorientation=DFR_global:gv_sampleorientation
	
	String interpcubename="cfe_interpCube"
	String w_cube_xname="w_cube_x_interp" //theta
	String w_cube_yname="w_cube_y_interp" //phi
	String w_cube_pname="w_cube_p_interp" //azi
	String w_cube_qname="w_cube_q_interp" //ef
	
	
	if (cubeindex>0)
		interpcubename+="_"+num2str(cubeindex)
		w_cube_xname+="_"+num2str(cubeindex)
		w_cube_yname+="_"+num2str(cubeindex)
		w_cube_pname+="_"+num2str(cubeindex)
		w_cube_qname+="_"+num2str(cubeindex)
	endif
	
	WAVE interpCube=$interpcubename
	Wave w_cube_x=$w_cube_xname
	Wave w_cube_y=$w_cube_yname
	Wave w_cube_p=$w_cube_pname
	Wave w_cube_q=$w_cube_qname
	
	Variable w_e0, w_e1, w_de,w_f0, w_f1, w_df,w_c0,w_c1,w_dc
	
	w_e0=dimoffset(interpCube,2)
	w_e1=dimoffset(interpCube,2)+(dimsize(interpCube,2)-1)*dimdelta(interpCube,2)
	w_de=dimdelta(interpCube,2)
	
	w_f0=dimoffset(interpCube,1)
	w_f1=dimoffset(interpCube,1)+(dimsize(interpCube,1)-1)*dimdelta(interpCube,1)
	w_df=dimdelta(interpCube,1)
	
	w_c0=dimoffset(interpCube,0)
	w_c1=dimoffset(interpCube,0)+(dimsize(interpCube,0)-1)*dimdelta(interpCube,0)
	w_dc=dimdelta(interpCube,0)
	
	NVAR e_center = gv_centerE
	NVAR dE=gv_dE
	NVAR innerE=gv_innerE
	
	NVAR initialflag=gv_initialflag
	
	NVAR gammaA=gv_gammaA
	NVAR Mappingmethodflag=gv_mappingmethodflag
	NVAR dimflag=gv_dimflag
	
	NVAR gv_curveflag=gv_curveflag
	
	
	newdatafolder /o/s FSM3Dshow
	
	String kxname="cf_waveform_kx"
	String kyname="cf_waveform_ky"
	String kzname="cf_waveform_kz"
	String FSMname="cf_waveform"
	String FSM3Dname="cf_waveform3D"
		
	if (cubeindex>0)
		kxname+="_"+num2str(cubeindex)
		kyname+="_"+num2str(cubeindex)
		kzname+="_"+num2str(cubeindex)
		FSMname+="_"+num2str(cubeindex)
		FSM3Dname+="_"+num2str(cubeindex)
	endif
			
	make /o/d/n=(dimsize(interpCube,0),dimsize(interpCube,1)),$kxname,$kyname,$kzname
    	setScale/I y w_f0, w_f1, ""  $kxname,$kyname,$kzname
	SetScale/I x w_c0, w_c1, "" $kxname,$kyname,$kzname
		
	wave cf_waveform_kx=$kxname
	wave cf_waveform_ky=$kyname
	wave cf_waveform_kz=$kzname
		
			
	make /o/n=(dimsize(cf_waveform_kx,1)) tempcutang
	SetScale/I x w_f0, w_f1, "" tempcutang
	tempcutang=x
			
	e_center=(e_center<w_e0)?(w_e0):(e_center)
	e_center=(e_center>w_e1)?(w_e1):(e_center)
			
	Variable index=0
	Variable kvac1
		   
	do 
		if (dimflag==3) //kz
			kvac1=sqrt(e_center+w_cube_x[index])*0.5123
		else
			if (initialflag)
				kvac1=sqrt(e_center+w_cube_q[index])*0.5123
			else
		 		kvac1=sqrt(e_center)*0.5123	
			endif
		endif
		 		
		if (dimflag==1) 		
			if (gammaA==90)
		 		flip_to_k_wave(kvac1,innerE,w_Cube_y[index],w_Cube_x[index],w_cube_p[index]+gv_sampleorientation,tempcutang,gammaA,gv_curveflag)
			else
		  		flip_to_k_wave(kvac1,innerE,w_Cube_x[index],w_Cube_y[index],w_cube_p[index]+gv_sampleorientation,tempcutang,gammaA,gv_curveflag)
			endif
		elseif (dimflag==2)
			if (gammaA==90)
		 		flip_to_k_wave(kvac1,innerE,w_Cube_y[index],w_Cube_p[index],w_cube_x[index]+gv_sampleorientation,tempcutang,gammaA,gv_curveflag)
			else
		  		flip_to_k_wave(kvac1,innerE,w_Cube_p[index],w_Cube_y[index],w_cube_x[index]+gv_sampleorientation,tempcutang,gammaA,gv_curveflag)
			endif
		 	
		elseif (dimflag==3)
			if (gammaA==90)
		 		flip_to_k_wave(kvac1,innerE,w_Cube_y[index],w_Cube_p[index],w_cube_q[index]+gv_sampleorientation,tempcutang,gammaA,gv_curveflag)
			else
		  		flip_to_k_wave(kvac1,innerE,w_Cube_p[index],w_Cube_y[index],w_cube_q[index]+gv_sampleorientation,tempcutang,gammaA,gv_curveflag)
			endif	
		endif 
		  
		 Wave M_result
		 cf_waveform_kx[index][]=M_result[q][0]
		 cf_waveform_ky[index][]=M_result[q][1]
		 cf_waveform_kz[index][]=M_result[q][2]
		 
		 index+=1
	while (index<dimsize(interpCube,0))
	
	Concatenate /O/NP=3 {cf_waveform_kx,cf_waveform_ky,cf_waveform_kz},$FSM3Dname
	
	make_cf_waveform(interpCube,e_center,dE/1000)
	Wave cf_waveform
	if (cubeindex>0)
		duplicate /o cf_waveform $FSMname
	endif

	
	SetDatafolder DF
end


////////////////////////auto_k_grid/////////////////////////////////

Function auto_k_grid_kxky(cubeindex,cubeflag,dimflag)
	Variable cubeindex
	Variable cubeflag, dimflag
	
	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
		
	SetDatafolder DFR_panel
	
	String interpcubename="cfe_interpCube"
	String rawcubename="cfe_rawCube"
	String w_cube_xname="w_cube_x_interp" //theta
	String w_cube_yname="w_cube_y_interp" //phi
	String w_cube_pname="w_cube_p_interp" //azi
	String w_cube_qname="w_cube_q_interp" //ef
	String FSMname="FSM_kxky"
	
	String FSM_Fname="FSM_f"
	STring FSM_Cname="FSM_c"
	
	if (cubeindex>0)
		interpcubename+="_"+num2str(cubeindex)
		w_cube_xname+="_"+num2str(cubeindex)
		w_cube_yname+="_"+num2str(cubeindex)
		w_cube_pname+="_"+num2str(cubeindex)
		w_cube_qname+="_"+num2str(cubeindex)
		FSMname+="_"+num2str(cubeindex)
		FSM_Fname+="_"+num2str(cubeindex)
		FSM_Cname+="_"+num2str(cubeindex)
	endif
	
	WAVE interpCube=$interpcubename
	Wave w_cube_x=$w_cube_xname
	Wave w_cube_y=$w_cube_yname
	Wave w_cube_p=$w_cube_pname
	Wave w_cube_q=$w_cube_qname
	
	Variable w_e0, w_e1, w_de,w_f0, w_f1, w_df,w_c0,w_c1,w_dc
	
	w_e0=dimoffset(interpCube,2)
	w_e1=dimoffset(interpCube,2)+(dimsize(interpCube,2)-1)*dimdelta(interpCube,2)
	w_de=dimdelta(interpCube,2)
	
	w_f0=dimoffset(interpCube,1)
	w_f1=dimoffset(interpCube,1)+(dimsize(interpCube,1)-1)*dimdelta(interpCube,1)
	w_df=dimdelta(interpCube,1)
	
	w_c0=dimoffset(interpCube,0)//w_cube_x[0]//
	w_c1=dimoffset(interpCube,0)+(dimsize(interpCube,0)-1)*dimdelta(interpCube,0)//w_cube_x[inf]//
	w_dc=dimdelta(interpCube,0)
	
	NVAR auto_grid = gv_auto_grid
	NVAR kx0 = gv_kxfrom
	NVAR kx1 = gv_kxto
	NVAR ky0 = gv_kyfrom
	NVAR ky1 = gv_kyto
	NVAR dkx = gv_kxdensity
	NVAR dky = gv_kydensity
	
	Variable kvac1
	
	NVAR e_center = gv_centerE
	
	NVAR initialflag=gv_initialflag
	
	NVAR gammaA=gv_gammaA
	NVAR Mappingmethodflag=gv_mappingmethodflag
	NVAR gv_curveflag=gv_curveflag

	NVAR innerE=gv_innerE
	
	e_center=(e_center<w_e0)?(w_e0):(e_center)
	e_center=(e_center>w_e1)?(w_e1):(e_center)
	
	Variable azi_final=mean(w_cube_p)
	
	if ((auto_grid)&&(Mappingmethodflag==2)) ///quick mode
		if (initialflag)
			//NVAR i_EF=gv_EF
			Variable EF=mean(w_cube_q)//i_EF
		else
			EF=0
		endif

		if (cubeflag)
			kvac1 = sqrt(w_e1+EF) * 0.5123
		else	
			kvac1=sqrt(e_center+EF)*0.5123	
		endif

			make /o/n=(dimsize(interpCube,1)) tempCutkx,tempCutky,tempCutang
			Setscale /I x,w_f0,w_f1,tempCutkx,tempCutky,tempCutang
			tempcutang=x
			
			Variable w_cmax,w_cmin,w_fmin,w_fmax
			
			If (gammaA==0)
				dkx=kvac1*sin(pi*wave_mindelta(w_cube_x)/180)
				dky=kvac1*sin(pi*w_df/180)
				w_cmax=wavemax(w_cube_x)
				w_cmin=wavemin(w_cube_x)
				w_fmax=wavemax(w_cube_y)
				w_fmin=wavemax(w_cube_y)
			else
				dky=kvac1*sin(pi*wave_mindelta(w_cube_x)/180)
				dkx=kvac1*sin(pi*w_df/180)
				w_cmax=wavemax(w_cube_y)
				w_cmin=wavemin(w_cube_y)
				w_fmax=wavemax(w_cube_x)
				w_fmin=wavemin(w_cube_x)
			endif
		
			
			Make/N=12/O kx,ky
			
			flip_to_k_wave(kvac1,innerE,w_cmin,w_fmin,azi_final,tempcutang,gammaA,gv_curveflag)
				Wave M_result
				tempCutkx=M_result[p][0]//flip_to_k(kvac1,0,w_c0,0,azi_final,x,gammaA,0)
				tempCutky=M_result[p][1]//flip_to_k(kvac1,0,w_c0,0,azi_final,x,gammaA,1)
				kx[0]=wavemin(tempCutkx)
				kx[1]=wavemax(tempCutkx)
				ky[0]=wavemin(tempCutky)
				ky[1]=wavemax(tempCutky)
				
			flip_to_k_wave(kvac1,innerE,w_cmax,w_fmax,azi_final,tempcutang,gammaA,gv_curveflag)
				Wave M_result
				tempCutkx=M_result[p][0]
				tempCutky=M_result[p][1]
				kx[2]=wavemin(tempCutkx)
				kx[3]=wavemax(tempCutkx)
				ky[2]=wavemin(tempCutky)
				ky[3]=wavemax(tempCutky)
				
			flip_to_k_wave(kvac1,innerE,w_cmin,w_fmax,azi_final,tempcutang,gammaA,gv_curveflag)
				Wave M_result
				tempCutkx=M_result[p][0]
				tempCutky=M_result[p][1]
				kx[4]=wavemin(tempCutkx)
				kx[5]=wavemax(tempCutkx)
				ky[4]=wavemin(tempCutky)
				ky[5]=wavemax(tempCutky)
				
			flip_to_k_wave(kvac1,innerE,w_cmax,w_fmin,azi_final,tempcutang,gammaA,gv_curveflag)
				Wave M_result
				tempCutkx=M_result[p][0]
				tempCutky=M_result[p][1]
				kx[6]=wavemin(tempCutkx)
				kx[7]=wavemax(tempCutkx)
				ky[6]=wavemin(tempCutky)
				ky[7]=wavemax(tempCutky)
			If (gammaA==0)
				flip_to_k_wave(kvac1,innerE,0,w_fmin,azi_final,tempcutang,gammaA,gv_curveflag)
				Wave M_result
				tempCutkx=M_result[p][0]
				tempCutky=M_result[p][1]
				kx[6]=wavemin(tempCutkx)
				kx[7]=wavemax(tempCutkx)
				ky[6]=wavemin(tempCutky)
				ky[7]=wavemax(tempCutky)
				
				flip_to_k_wave(kvac1,innerE,0,w_fmax,azi_final,tempcutang,gammaA,gv_curveflag)
				Wave M_result
				tempCutkx=M_result[p][0]
				tempCutky=M_result[p][1]
				kx[6]=wavemin(tempCutkx)
				kx[7]=wavemax(tempCutkx)
				ky[6]=wavemin(tempCutky)
				ky[7]=wavemax(tempCutky)
			else	
				flip_to_k_wave(kvac1,innerE,w_cmax,0,azi_final,tempcutang,gammaA,gv_curveflag)
				Wave M_result
				tempCutkx=M_result[p][0]
				tempCutky=M_result[p][1]
				kx[8]=wavemin(tempCutkx)
				kx[9]=wavemax(tempCutkx)
				ky[8]=wavemin(tempCutky)
				ky[9]=wavemax(tempCutky)
				
				flip_to_k_wave(kvac1,0,w_cmin,0,azi_final,tempcutang,gammaA,gv_curveflag)
				Wave M_result
				tempCutkx=M_result[p][0]
				tempCutky=M_result[p][1]
				kx[10]=wavemin(tempCutkx)
				kx[11]=wavemax(tempCutkx)
				ky[10]=wavemin(tempCutky)
				ky[11]=wavemax(tempCutky)
			endif	

			kx0 = round(wavemin(kx)* 100) / 100
			kx1 = round(wavemax(kx) * 100) / 100
			ky0 = round(wavemin(ky) * 100) / 100
			ky1 = round(wavemax(ky) * 100) / 100
	
		//	KillWaves/Z kx, ky, tempCutkx,tempCutky,tempcutang,M_result
	
	endif
	
		
	if (Mappingmethodflag==3) //precise
			
			String kxname="cf_waveform_kx"
			String kyname="cf_waveform_ky"
			String kzname="cf_waveform_kz"
		
			if (cubeindex>0)
				kxname+="_"+num2str(cubeindex)
				kyname+="_"+num2str(cubeindex)
				kzname+="_"+num2str(cubeindex)
			endif
			
			make /o/d/n=(dimsize(interpCube,0),dimsize(interpCube,1)),$kxname,$kyname,$kzname
    			setScale/I y w_f0, w_f1, ""  $kxname,$kyname,$kzname
			SetScale/I x w_c0, w_c1, "" $kxname,$kyname,$kzname
		
			wave cf_waveform_kx=$kxname
			wave cf_waveform_ky=$kyname
			wave cf_waveform_kz=$kzname
		
			
			make /o/n=(dimsize(cf_waveform_kx,1)) tempcutang
			SetScale/I x w_f0, w_f1, "" tempcutang
			tempcutang=x
			
			e_center=(e_center<w_e0)?(w_e0):(e_center)
			e_center=(e_center>w_e1)?(w_e1):(e_center)
			
			Variable index=0
		   
		   	do 
		   		if (initialflag)
		 			kvac1=sqrt(e_center+w_cube_q[index])*0.5123
		 		else
		 			kvac1=sqrt(e_center)*0.5123	
		 		endif
		 		
		 		if (gammaA==90)
		 			flip_to_k_wave(kvac1,innerE,w_Cube_y[index],w_Cube_x[index],w_cube_p[index],tempcutang,gammaA,gv_curveflag)
		 		else
		  		 	 flip_to_k_wave(kvac1,innerE,w_Cube_x[index],w_Cube_y[index],w_cube_p[index],tempcutang,gammaA,gv_curveflag)
		 		endif
		 	
		   		Wave M_result
		 		cf_waveform_kx[index][]=M_result[q][0]
		   		cf_waveform_ky[index][]=M_result[q][1]
		   		cf_waveform_kz[index][]=M_result[q][2]
		  		index+=1
		   	while (index<dimsize(interpCube,0))
		   	
		   	If (gammaA==0)
				dkx=kvac1*sin(pi*wave_mindelta(w_cube_x)/180)
				dky=kvac1*sin(pi*w_df/180)
			else
				dky=kvac1*sin(pi*wave_mindelta(w_cube_x)/180)
				dkx=kvac1*sin(pi*w_df/180)
			endif
			
		if (auto_grid)
			
			//cf_waveform_kx=(numtype(cf_waveform_kx)==2)?(-10000):(cf_waveform_kx)
			//cf_waveform_ky=(numtype(cf_waveform_ky)==2)?(-10000):(cf_waveform_ky)
			ky1=my_wavemax(cf_waveform_ky)
			kx1=my_wavemax(cf_waveform_kx)
	
			//cf_waveform_kx=(cf_waveform_kx==-10000)?(10000):(cf_waveform_kx)
			//cf_waveform_ky=(cf_waveform_ky==-10000)?(10000):(cf_waveform_ky)
		
			kx0=my_wavemin(cf_waveform_kx)
			ky0=my_wavemin(cf_waveform_ky)
	
			//cf_waveform_kx=(cf_waveform_kx==10000)?(Nan):(cf_waveform_kx)
			//cf_waveform_ky=(cf_waveform_ky==10000)?(Nan):(cf_waveform_ky)
		endif
	
		//KillWaves/Z kx, ky, tempCutkx,tempCutky,tempcutang,M_result

	endif
	
	Variable nkx=abs(kx1-kx0) / dkx + 1
	variable nky = abs(ky1-ky0) / dky + 1
	
	Make/n=(nkx,nky)/o $FSMname
	
	Wave FSM_kxky=$FSMname
	
	SetScale/I x kx0,kx1,"" FSM_kxky
	SetScale/I y ky0,ky1,"" FSM_kxky
			
	Duplicate/o FSM_kxky $FSM_cname, $FSM_fname
	
	
	if (dimflag==1)
		index=0
		do 
			kvac1=1
		 	
		 	if (gammaA==90)
		 		flip_to_k_wave(kvac1,innerE,w_Cube_y[index],w_Cube_x[index],w_cube_p[index],tempcutang,gammaA,gv_curveflag)
		 	else
		  		flip_to_k_wave(kvac1,innerE,w_Cube_x[index],w_Cube_y[index],w_cube_p[index],tempcutang,gammaA,gv_curveflag)
		 	endif
		 	
			
			Wave M_result
		 	cf_waveform_kx[index][]=M_result[q][0]
		   	cf_waveform_ky[index][]=M_result[q][1]
		   	cf_waveform_kz[index][]=M_result[q][2]
		    	index+=1
		while (index<dimsize(interpCube,0))
	endif
	
	KillWaves/Z kx, ky, tempCutkx,tempCutky,tempcutang,M_result
	
	SetDatafolder DF
	
End


Function auto_k_grid_DA30(cubeindex,cubeflag,dimflag)
	Variable cubeindex
	Variable cubeflag, dimflag
	
	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
		
	SetDatafolder DFR_panel
	
	String interpcubename="cfe_interpCube"
	String rawcubename="cfe_rawCube"
	String w_cube_xname="w_cube_x_interp" //deflectorY
	String w_cube_yname="w_cube_y_interp" //phi
	String w_cube_pname="w_cube_p_interp" //azi
	String w_cube_qname="w_cube_q_interp" //ef
	String w_cube_rname="w_cube_r_interp" //ef
	String FSMname="FSM_kxky"
	
	String FSM_Fname="FSM_f"
	STring FSM_Cname="FSM_c"
	
	if (cubeindex>0)
		interpcubename+="_"+num2str(cubeindex)
		w_cube_xname+="_"+num2str(cubeindex)
		w_cube_yname+="_"+num2str(cubeindex)
		w_cube_pname+="_"+num2str(cubeindex)
		w_cube_qname+="_"+num2str(cubeindex)
		w_cube_rname+="_"+num2str(cubeindex)
		FSMname+="_"+num2str(cubeindex)
		FSM_Fname+="_"+num2str(cubeindex)
		FSM_Cname+="_"+num2str(cubeindex)
	endif
	
	WAVE interpCube=$interpcubename
	Wave w_cube_x=$w_cube_xname
	Wave w_cube_y=$w_cube_yname
	Wave w_cube_p=$w_cube_pname
	Wave w_cube_q=$w_cube_qname
	Wave w_cube_r=$w_cube_rname
	
	Variable w_e0, w_e1, w_de,w_f0, w_f1, w_df,w_c0,w_c1,w_dc
	
	w_e0=dimoffset(interpCube,2)
	w_e1=dimoffset(interpCube,2)+(dimsize(interpCube,2)-1)*dimdelta(interpCube,2)
	w_de=dimdelta(interpCube,2)
	
	w_f0=dimoffset(interpCube,1)
	w_f1=dimoffset(interpCube,1)+(dimsize(interpCube,1)-1)*dimdelta(interpCube,1)
	w_df=dimdelta(interpCube,1)
	
	w_c0=dimoffset(interpCube,0)//w_cube_x[0]//
	w_c1=dimoffset(interpCube,0)+(dimsize(interpCube,0)-1)*dimdelta(interpCube,0)//w_cube_x[inf]//
	w_dc=dimdelta(interpCube,0)
	
	NVAR auto_grid = gv_auto_grid
	NVAR kx0 = gv_kxfrom
	NVAR kx1 = gv_kxto
	NVAR ky0 = gv_kyfrom
	NVAR ky1 = gv_kyto
	NVAR dkx = gv_kxdensity
	NVAR dky = gv_kydensity
	
	Variable kvac1
	
	NVAR e_center = gv_centerE
	
	NVAR initialflag=gv_initialflag
	
	NVAR gammaA=gv_gammaA
	NVAR Mappingmethodflag=gv_mappingmethodflag
	NVAR gv_curveflag=gv_curveflag

	NVAR innerE=gv_innerE
	
	e_center=(e_center<w_e0)?(w_e0):(e_center)
	e_center=(e_center>w_e1)?(w_e1):(e_center)
	
	Variable azi_final=mean(w_cube_p)
	variable theta_final = mean(w_cube_r)
	
	if ((auto_grid)&&(Mappingmethodflag==2)) ///quick mode
		if (initialflag)
			//NVAR i_EF=gv_EF
			Variable EF=mean(w_cube_q)//i_EF
		else
			EF=0
		endif

		if (cubeflag)
			kvac1 = sqrt(w_e1+EF) * 0.5123
		else	
			kvac1=sqrt(e_center+EF)*0.5123	
		endif

		make /o/n=(dimsize(interpCube,1)) tempCutkx,tempCutky,tempCutang
		Setscale /I x,w_f0,w_f1,tempCutkx,tempCutky,tempCutang
		tempcutang=x
		
		Variable w_cmax,w_cmin,w_fmin,w_fmax
		
		If (gammaA==0)
			dkx=kvac1*sin(pi*wave_mindelta(w_cube_x)/180)
			dky=kvac1*sin(pi*w_df/180)
			w_cmax=wavemax(w_cube_x)
			w_cmin=wavemin(w_cube_x)
			w_fmax=wavemax(w_cube_y)
			w_fmin=wavemax(w_cube_y)
		else
			dky=kvac1*sin(pi*wave_mindelta(w_cube_x)/180)
			dkx=kvac1*sin(pi*w_df/180)
			w_cmax=wavemax(w_cube_y)
			w_cmin=wavemin(w_cube_y)
			w_fmax=wavemax(w_cube_x)
			w_fmin=wavemin(w_cube_x)
		endif
	
			
		Make/N=12/O kx,ky
		flip_to_k_wave_DA30(kvac1,innerE,theta_final,w_fmin,azi_final,w_cmin,tempcutang,gammaA,gv_curveflag)
			Wave M_result
			tempCutkx=M_result[p][0]//flip_to_k(kvac1,0,w_c0,0,azi_final,x,gammaA,0)
			tempCutky=M_result[p][1]//flip_to_k(kvac1,0,w_c0,0,azi_final,x,gammaA,1)
			kx[0]=wavemin(tempCutkx)
			kx[1]=wavemax(tempCutkx)
			ky[0]=wavemin(tempCutky)
			ky[1]=wavemax(tempCutky)
			
		flip_to_k_wave_DA30(kvac1,innerE,theta_final,w_fmax,azi_final,w_cmax,tempcutang,gammaA,gv_curveflag)
			Wave M_result
			tempCutkx=M_result[p][0]
			tempCutky=M_result[p][1]
			kx[2]=wavemin(tempCutkx)
			kx[3]=wavemax(tempCutkx)
			ky[2]=wavemin(tempCutky)
			ky[3]=wavemax(tempCutky)
			
		flip_to_k_wave_DA30(kvac1,innerE,theta_final,w_fmin,azi_final,w_cmax,tempcutang,gammaA,gv_curveflag)
			Wave M_result
			tempCutkx=M_result[p][0]
			tempCutky=M_result[p][1]
			kx[4]=wavemin(tempCutkx)
			kx[5]=wavemax(tempCutkx)
			ky[4]=wavemin(tempCutky)
			ky[5]=wavemax(tempCutky)
			
		flip_to_k_wave_DA30(kvac1,innerE,theta_final,w_fmax,azi_final,w_cmin,tempcutang,gammaA,gv_curveflag)
			Wave M_result
			tempCutkx=M_result[p][0]
			tempCutky=M_result[p][1]
			kx[6]=wavemin(tempCutkx)
			kx[7]=wavemax(tempCutkx)
			ky[6]=wavemin(tempCutky)
			ky[7]=wavemax(tempCutky)


			flip_to_k_wave_DA30(kvac1,innerE,theta_final,w_fmin,azi_final,0,tempcutang,gammaA,gv_curveflag)
			Wave M_result
			tempCutkx=M_result[p][0]
			tempCutky=M_result[p][1]
			kx[6]=wavemin(tempCutkx)
			kx[7]=wavemax(tempCutkx)
			ky[6]=wavemin(tempCutky)
			ky[7]=wavemax(tempCutky)
			
			flip_to_k_wave_DA30(kvac1,innerE,theta_final,w_fmax,azi_final,0,tempcutang,gammaA,gv_curveflag)
			Wave M_result
			tempCutkx=M_result[p][0]
			tempCutky=M_result[p][1]
			kx[6]=wavemin(tempCutkx)
			kx[7]=wavemax(tempCutkx)
			ky[6]=wavemin(tempCutky)
			ky[7]=wavemax(tempCutky)


			kx0 = round(wavemin(kx)* 100) / 100
			kx1 = round(wavemax(kx) * 100) / 100
			ky0 = round(wavemin(ky) * 100) / 100
			ky1 = round(wavemax(ky) * 100) / 100
	
		//	KillWaves/Z kx, ky, tempCutkx,tempCutky,tempcutang,M_result
	
	endif
	
		
	if (Mappingmethodflag==3) //precise
			
			String kxname="cf_waveform_kx"
			String kyname="cf_waveform_ky"
			String kzname="cf_waveform_kz"
		
			if (cubeindex>0)
				kxname+="_"+num2str(cubeindex)
				kyname+="_"+num2str(cubeindex)
				kzname+="_"+num2str(cubeindex)
			endif
			
			make /o/d/n=(dimsize(interpCube,0),dimsize(interpCube,1)),$kxname,$kyname,$kzname
    			setScale/I y w_f0, w_f1, ""  $kxname,$kyname,$kzname
			SetScale/I x w_c0, w_c1, "" $kxname,$kyname,$kzname
		
			wave cf_waveform_kx=$kxname
			wave cf_waveform_ky=$kyname
			wave cf_waveform_kz=$kzname
		
			
			make /o/n=(dimsize(cf_waveform_kx,1)) tempcutang
			SetScale/I x w_f0, w_f1, "" tempcutang
			tempcutang=x
			
			e_center=(e_center<w_e0)?(w_e0):(e_center)
			e_center=(e_center>w_e1)?(w_e1):(e_center)
			
			Variable index=0
		   
		   	do 
		   		if (initialflag)
		 			kvac1=sqrt(e_center+w_cube_q[index])*0.5123
		 		else
		 			kvac1=sqrt(e_center)*0.5123	
		 		endif

		  		flip_to_k_wave_DA30(kvac1,innerE,w_Cube_r[index],w_Cube_y[index],w_cube_p[index],w_Cube_x[index],tempcutang,gammaA,gv_curveflag)
		 	
		   		Wave M_result
		 		cf_waveform_kx[index][]=M_result[q][0]
		   		cf_waveform_ky[index][]=M_result[q][1]
		   		cf_waveform_kz[index][]=M_result[q][2]
		  		index+=1
		   	while (index<dimsize(interpCube,0))
		   	
		   	If (gammaA==0)
				dkx=kvac1*sin(pi*wave_mindelta(w_cube_x)/180)
				dky=kvac1*sin(pi*w_df/180)
			else
				dky=kvac1*sin(pi*wave_mindelta(w_cube_x)/180)
				dkx=kvac1*sin(pi*w_df/180)
			endif
			
		if (auto_grid)
			
			//cf_waveform_kx=(numtype(cf_waveform_kx)==2)?(-10000):(cf_waveform_kx)
			//cf_waveform_ky=(numtype(cf_waveform_ky)==2)?(-10000):(cf_waveform_ky)
			ky1=my_wavemax(cf_waveform_ky)
			kx1=my_wavemax(cf_waveform_kx)
	
			//cf_waveform_kx=(cf_waveform_kx==-10000)?(10000):(cf_waveform_kx)
			//cf_waveform_ky=(cf_waveform_ky==-10000)?(10000):(cf_waveform_ky)
		
			kx0=my_wavemin(cf_waveform_kx)
			ky0=my_wavemin(cf_waveform_ky)
	
			//cf_waveform_kx=(cf_waveform_kx==10000)?(Nan):(cf_waveform_kx)
			//cf_waveform_ky=(cf_waveform_ky==10000)?(Nan):(cf_waveform_ky)
		endif
	
		//KillWaves/Z kx, ky, tempCutkx,tempCutky,tempcutang,M_result

	endif
	
	Variable nkx=abs(kx1-kx0) / dkx + 1
	variable nky = abs(ky1-ky0) / dky + 1
	
	Make/n=(nkx,nky)/o $FSMname
	
	Wave FSM_kxky=$FSMname
	
	SetScale/I x kx0,kx1,"" FSM_kxky
	SetScale/I y ky0,ky1,"" FSM_kxky
			
	Duplicate/o FSM_kxky $FSM_cname, $FSM_fname
	
	
	if (dimflag==4)
		index=0
		do 
			kvac1=1
		 	
		 	flip_to_k_wave_DA30(kvac1,innerE,w_Cube_r[index],w_Cube_y[index],w_cube_p[index],w_Cube_x[index],tempcutang,gammaA,gv_curveflag)
		 	

			
			Wave M_result
		 	cf_waveform_kx[index][]=M_result[q][0]
		   	cf_waveform_ky[index][]=M_result[q][1]
		   	cf_waveform_kz[index][]=M_result[q][2]
		    	index+=1
		while (index<dimsize(interpCube,0))
	endif
	
	KillWaves/Z kx, ky, tempCutkx,tempCutky,tempcutang,M_result
	
	SetDatafolder DF
	
End



Function auto_k_grid_polar(cubeindex,cubeflag,dimflag)
	Variable cubeindex
	Variable cubeflag,dimflag

	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
		
	SetDatafolder $DF_panel

	NVAR e_center = gv_centerE
	NVAR dE = gv_dE
    	NVAR gammaA=gv_gammaA
	NVAR auto_grid = gv_auto_grid
	
	String interpcubename="cfe_interpCube"
	String rawcubename="cfe_rawCube"
	String w_cube_xname="w_cube_x_interp"
	String w_cube_yname="w_cube_y_interp"
	String FSMname="FSM_kxky"
	
	String w_cube_pname="w_cube_p_interp"
	String w_cube_qname="w_cube_q_interp"
	
	if (cubeindex>0)
		interpcubename+="_"+num2str(cubeindex)
		w_cube_xname+="_"+num2str(cubeindex)
		w_cube_yname+="_"+num2str(cubeindex)
		w_cube_pname+="_"+num2str(cubeindex)
		w_cube_qname+="_"+num2str(cubeindex)
		FSMname+="_"+num2str(cubeindex)
	endif
	
	WAVE interpCube=$interpcubename
	Wave w_cube_x=$w_cube_xname
	Wave w_cube_y=$w_cube_yname
	Wave w_cube_p=$w_cube_pname
	Wave w_cube_q=$w_cube_qname
	
	NVAR kx0 = gv_kxfrom
	NVAR kx1 = gv_kxto
	NVAR ky0 = gv_kyfrom
	NVAR ky1 = gv_kyto
	NVAR dkx = gv_kxdensity
	NVAR dky = gv_kydensity
	
	NVAR InnerE=gv_InnerE
	
	Variable kvac
	NVAR initialflag=gv_initialflag
	
	NVAR Mappingmethodflag=gv_mappingmethodflag
	
	NVAR gv_curveflag=gv_curveflag
	
	Variable w_e0, w_e1, w_de,w_f0, w_f1, w_df,w_c0,w_c1,w_dc
	
		w_e0=dimoffset(interpCube,2)
		w_e1=dimoffset(interpCube,2)+(dimsize(interpCube,2)-1)*dimdelta(interpCube,2)
		w_de=dimdelta(interpCube,2)
	
		w_f0=dimoffset(interpCube,1)
		w_f1=dimoffset(interpCube,1)+(dimsize(interpCube,1)-1)*dimdelta(interpCube,1)
		w_df=dimdelta(interpCube,1)
	
		w_c0=dimoffset(interpCube,0)
		w_c1=dimoffset(interpCube,0)+(dimsize(interpCube,0)-1)*dimdelta(interpCube,0)
		w_dc=dimdelta(interpCube,0)
		
		e_center=(e_center<w_e0)?(w_e0):(e_center)
		e_center=(e_center>w_e1)?(w_e1):(e_center)
		
	
	if ((auto_grid)||(Mappingmethodflag==3)) 
	
		
		
		String kxname="cf_waveform_kx"
		String kyname="cf_waveform_ky"
		String kzname="cf_waveform_kz"
		
		if (cubeindex>0)
			kxname+="_"+num2str(cubeindex)
			kyname+="_"+num2str(cubeindex)
			kzname+="_"+num2str(cubeindex)
		endif
			
		make /o/d/n=(dimsize(interpCube,0),dimsize(interpCube,1)),$kxname,$kyname,$kzname
    		setScale/I y w_f0, w_f1, ""  $kxname,$kyname,$kzname
		SetScale/I x w_c0, w_c1, "" $kxname,$kyname,$kzname
		
		wave cf_waveform_kx=$kxname
		wave cf_waveform_ky=$kyname
		wave cf_waveform_kz=$kzname
		
	
		variable kvac0
		
		make /o/n=(dimsize(cf_waveform_kx,1)) tempcutang
		 SetScale/I x w_f0, w_f1, "" tempcutang
		 tempcutang=x
	

		Variable index=0
		do 
			if (initialflag)
		 			kvac0=sqrt(e_center+w_cube_q[index])*0.5123
		 	else
		 			kvac0=sqrt(e_center)*0.5123	
		 	endif
		 	
			if (gammaA==90)
				flip_to_k_wave(kvac0,InnerE,w_cube_y[index],w_cube_p[index],w_cube_x[index],tempcutang,gammaA,gv_curveflag)
			else
				flip_to_k_wave(kvac0,InnerE,w_cube_p[index],w_cube_y[index],w_cube_x[index],tempcutang,gammaA,gv_curveflag)
			endif
			Wave M_result
		 	cf_waveform_kx[index][]=M_result[q][0]
		   	cf_waveform_ky[index][]=M_result[q][1]
		   	cf_waveform_kz[index][]=M_result[q][2]
		    	index+=1
		while (index<dimsize(interpCube,0))
		 
		if (auto_grid)
			//cf_waveform_kx=(numtype(cf_waveform_kx)==2)?(-10000):(cf_waveform_kx)
			//cf_waveform_ky=(numtype(cf_waveform_ky)==2)?(-10000):(cf_waveform_ky)
			ky1=my_wavemax(cf_waveform_ky)
			kx1=my_wavemax(cf_waveform_kx)
	
			//cf_waveform_kx=(cf_waveform_kx==-10000)?(10000):(cf_waveform_kx)
			//cf_waveform_ky=(cf_waveform_ky==-10000)?(10000):(cf_waveform_ky)
		
			kx0=my_wavemin(cf_waveform_kx)
			ky0=my_wavemin(cf_waveform_ky)
	
			//cf_waveform_kx=(cf_waveform_kx==10000)?(Nan):(cf_waveform_kx)
			//cf_waveform_ky=(cf_waveform_ky==10000)?(Nan):(cf_waveform_ky)
		
			w_dc=wave_mindelta(w_cube_x)
			
			dkx=kvac0*sin(pi*max(w_dc,w_df)/180)
			dky=kvac0*sin(pi*max(w_dc,w_df)/180)
		endif
	endif
	Variable nkx = abs(kx1-kx0) / dkx + 1
	Variable nky = abs(ky1-ky0) / dky + 1
	
	Make/n=(nkx,nky)/o FSM_kxky
	SetScale/I x kx0,kx1,"" FSM_kxky
	SetScale/I y ky0,ky1,"" FSM_kxky
		
	Duplicate/o FSM_kxky FSM_c, FSM_f,FSM_f1,FSM_c1
	
	if (dimflag==1)
		index=0
		do 
			kvac0=1
		 	
			if (gammaA==90)
				flip_to_k_wave(kvac0,InnerE,w_cube_y[index],w_cube_p[index],w_cube_x[index],tempcutang,gammaA,gv_curveflag)
			else
				flip_to_k_wave(kvac0,InnerE,w_cube_p[index],w_cube_y[index],w_cube_x[index],tempcutang,gammaA,gv_curveflag)
			endif
			Wave M_result
		 	cf_waveform_kx[index][]=M_result[q][0]
		   	cf_waveform_ky[index][]=M_result[q][1]
		   	cf_waveform_kz[index][]=M_result[q][2]
		    	index+=1
		while (index<dimsize(interpCube,0))
	endif
	
	KillWaves/Z kx, ky, tempCutkx,tempCutky,tempcutang,M_result
	
	Setdatafolder DF
End


Function auto_k_grid_kz(cubeindex,cubeflag,dimflag)
	Variable cubeindex
	Variable cubeflag, dimflag
	
	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
		
	SetDatafolder $DF_panel
	
	
	NVAR e_center = gv_centerE
	NVAR dE = gv_dE
    	NVAR gammaA=gv_gammaA
	NVAR auto_grid = gv_auto_grid
	
	String interpcubename="cfe_interpCube"
	String rawcubename="cfe_rawCube"
	String w_cube_xname="w_cube_x_interp"
	String w_cube_yname="w_cube_y_interp"
	String FSMname="FSM_kxky"
	
	String w_cube_pname="w_cube_p_interp"
	String w_cube_qname="w_cube_q_interp"
	
	if (cubeindex>0)
		interpcubename+="_"+num2str(cubeindex)
		w_cube_xname+="_"+num2str(cubeindex)
		w_cube_yname+="_"+num2str(cubeindex)
		w_cube_pname+="_"+num2str(cubeindex)
		w_cube_qname+="_"+num2str(cubeindex)
		FSMname+="_"+num2str(cubeindex)
	endif
	
	WAVE interpCube=$interpcubename
	Wave w_cube_x=$w_cube_xname
	Wave w_cube_y=$w_cube_yname
	Wave w_cube_p=$w_cube_pname
	Wave w_cube_q=$w_cube_qname
	
	NVAR kx0 = gv_kxfrom
	NVAR kx1 = gv_kxto
	NVAR ky0 = gv_kyfrom
	NVAR ky1 = gv_kyto
	NVAR dkx = gv_kxdensity
	NVAR dky = gv_kydensity
	
	NVAR InnerE=gv_InnerE
	
	Variable kvac
	NVAR initialflag=gv_initialflag
	
	NVAR Mappingmethodflag=gv_mappingmethodflag
	NVAR gv_curveflag=gv_curveflag
	
	Variable w_e0, w_e1, w_de,w_f0, w_f1, w_df,w_c0,w_c1,w_dc
	
	w_e0=dimoffset(interpCube,2)
	w_e1=dimoffset(interpCube,2)+(dimsize(interpCube,2)-1)*dimdelta(interpCube,2)
	w_de=dimdelta(interpCube,2)
	
	w_f0=dimoffset(interpCube,1)
	w_f1=dimoffset(interpCube,1)+(dimsize(interpCube,1)-1)*dimdelta(interpCube,1)
	w_df=dimdelta(interpCube,1)
	
	w_c0=dimoffset(interpCube,0)
	w_c1=dimoffset(interpCube,0)+(dimsize(interpCube,0)-1)*dimdelta(interpCube,0)
	w_dc=dimdelta(interpCube,0)
	
	e_center=(e_center<w_e0)?(w_e0):(e_center)
	e_center=(e_center>w_e1)?(w_e1):(e_center)
	
	if ((auto_grid)||(Mappingmethodflag==3)) 
	
		
		
		String kxname="cf_waveform_kx"
		String kyname="cf_waveform_ky"
		String kzname="cf_waveform_kz"
		
		if (cubeindex>0)
			kxname+="_"+num2str(cubeindex)
			kyname+="_"+num2str(cubeindex)
			kzname+="_"+num2str(cubeindex)
		endif
		
		make /o/d/n=(dimsize(interpCube,0),dimsize(interpCube,1)),$kxname,$kyname,$kzname
    		setScale/I y w_f0, w_f1, ""  $kxname,$kyname,$kzname
		SetScale/I x w_c0, w_c1, "" $kxname,$kyname,$kzname
		
		wave cf_waveform_kx=$kxname
		wave cf_waveform_ky=$kyname
		wave cf_waveform_kz=$kzname
		
		variable kvac0
		
	
		
		make /o/n=(dimsize(cf_waveform_kx,1)) tempcutang
		 SetScale/I x w_f0, w_f1, "" tempcutang
		 tempcutang=x
	

		Variable index=0
		do 
		
			kvac0=sqrt(e_center+w_cube_x[index])*0.5123
		 	
		 	if (gammaA==90)
				flip_to_k_wave(kvac0,InnerE,w_cube_y[index],w_cube_p[index],w_cube_q[index],tempcutang,gammaA,gv_curveflag)
			else
				flip_to_k_wave(kvac0,InnerE,w_cube_p[index],w_cube_y[index],w_cube_q[index],tempcutang,gammaA,gv_curveflag)
			endif
			
			
			Wave M_result
		 	cf_waveform_kx[index][]=M_result[q][0]
		   	cf_waveform_ky[index][]=M_result[q][1]
		   	cf_waveform_kz[index][]=M_result[q][2]
			
		    	index+=1
		while (index<dimsize(interpCube,0))
		
		
		 
		if (auto_grid)
			
			If (gammaA==90)
				//cf_waveform_kx=(numtype(cf_waveform_kx)==2)?(-10000):(cf_waveform_kx)
				//cf_waveform_kz=(numtype(cf_waveform_kz)==2)?(-10000):(cf_waveform_kz)	
				kx1=my_wavemax(cf_waveform_kx)
				ky1=my_wavemax(cf_waveform_kz)
	
				//cf_waveform_kx=(cf_waveform_kx==-10000)?(10000):(cf_waveform_kx)
				//cf_waveform_kz=(cf_waveform_kz==-10000)?(10000):(cf_waveform_kz)
		
				kx0=my_wavemin(cf_waveform_kx)
				ky0=my_wavemin(cf_waveform_kz)
	
				//cf_waveform_kx=(cf_waveform_kx==10000)?(Nan):(cf_waveform_kx)
				//cf_waveform_kz=(cf_waveform_kz==10000)?(Nan):(cf_waveform_kz)
			else
				//cf_waveform_ky=(numtype(cf_waveform_ky)==2)?(-10000):(cf_waveform_ky)
				//cf_waveform_kz=(numtype(cf_waveform_kz)==2)?(-10000):(cf_waveform_kz)	
				kx1=my_wavemax(cf_waveform_ky)
				ky1=my_wavemax(cf_waveform_kz)
	
				//cf_waveform_ky=(cf_waveform_ky==-10000)?(10000):(cf_waveform_ky)
				//cf_waveform_kz=(cf_waveform_kz==-10000)?(10000):(cf_waveform_kz)
		
				kx0=my_wavemin(cf_waveform_ky)
				ky0=my_wavemin(cf_waveform_kz)
	
				//cf_waveform_ky=(cf_waveform_ky==10000)?(Nan):(cf_waveform_ky)
			//	cf_waveform_kz=(cf_waveform_kz==10000)?(Nan):(cf_waveform_kz)
			endif
			
			dkx=kvac0*sin(pi*w_df/180)
			
			w_dc=wave_mindelta(w_cube_x)
			Variable hnnum=numpnts(w_cube_x)
			dky=0.5123*(sqrt(w_cube_x[inf])-sqrt(w_cube_x[inf]-w_dc))
			
		endif
	endif
	
	Variable nkx = abs(kx1-kx0) / dkx + 1
	Variable nky = abs(ky1-ky0) / dky + 1
	
	Make/n=(nkx,nky)/o FSM_kxky
	SetScale/I x kx0,kx1,"" FSM_kxky
	SetScale/I y ky0,ky1,"" FSM_kxky
		
	Duplicate/o FSM_kxky FSM_c, FSM_f
	
	
	
	if (dimflag==1)
		index=0
		do
			
			kvac0=1
			if (gammaA==90)
				flip_to_k_wave_precisemap(kvac0,InnerE,w_cube_y[index],w_cube_p[index],w_cube_q[index],tempcutang,gammaA,gv_curveflag)
			else
				flip_to_k_wave_precisemap(kvac0,InnerE,w_cube_p[index],w_cube_y[index],w_cube_q[index],tempcutang,gammaA,gv_curveflag)
			endif
		   	Wave M_result
		 	cf_waveform_kx[index][]=M_result[q][0]
		   	cf_waveform_ky[index][]=M_result[q][1]
		   	cf_waveform_kz[index][]=M_result[q][2]
			
		    	index+=1
		while (index<dimsize(interpCube,0))
	endif
	
	KillWaves/Z kx, ky, tempCutkx,tempCutky,tempcutang,M_result
	
	SetDatafolder DF
	
End

//////////////k_convert////

Threadsafe Function curve_slit_correction_quick(beta,gamma)
	Variable beta,gamma
	
	Variable slit_y=beta*angle_to_length
	Variable slit_x=slit_d-sqrt(slit_d^2-slit_y^2)
	Variable azi_angle_correct
	if (slit_y==0)
		azi_angle_correct=0
	else
		azi_angle_correct=atan(slit_x/slit_y)
	endif
	
	Variable slit_beta=sqrt(slit_x^2+slit_y^2)/angle_to_length
	
	if (beta<0)
		slit_beta=-slit_beta
	//	azi_angle_correct=-azi_angle_correct
	endif
	
	//if (Gamma!=0)
	//	azi_angle_correct=-azi_angle_correct
	//endif
	
	Variable x_raw=sin(slit_beta)*sin(gamma)
	variable y_raw=sin(slit_beta)*cos(gamma)
	Variable z_raw=cos(slit_beta)
	// electron emission in lab-system
	Variable x_rot=cos(-azi_angle_correct)*x_raw+sin(-azi_angle_correct)*y_raw
	Variable y_rot=cos(-azi_angle_correct)*y_raw-sin(-azi_angle_correct)*x_raw

	if (gamma==0)
		return asin(x_rot/(sqrt(x_rot^2+z_raw^2)))
	else
		return asin(y_rot/(sqrt(y_rot^2+z_raw^2)))
	endif
//	s_angle[0][0]=cos(-azi_angle_correct)*x_raw+sin(-azi_angle_correct)*y_raw
	//s_angle[1][0]=cos(-azi_angle_correct)*y_raw-sin(-azi_angle_correct)*x_raw
	//s_angle[2][0]= cos(slit_beta)
End

Threadsafe Function curve_slit_correction(beta,gamma,s_angle)
	Variable beta,gamma
	Wave s_angle
	
	if (beta==0)
		s_angle[0][0]=sin(beta)*sin(gamma)
		s_angle[1][0]=sin(beta)*cos(gamma)
		s_angle[2][0]= cos(beta)
		return 0
	endif
	
	Variable slit_y=beta*angle_to_length
	Variable slit_x=slit_d-sqrt(slit_d^2-slit_y^2)
	Variable azi_angle_correct=atan(slit_x/slit_y)
	Variable slit_beta=sqrt(slit_x^2+slit_y^2)/angle_to_length
	
	if (beta<0)
		slit_beta=-slit_beta
	endif
	
	//if (Gamma!=0)
	//	azi_angle_correct=-azi_angle_correct
	//endif
	
	Variable x_raw=sin(slit_beta)*sin(gamma)
	variable y_raw=sin(slit_beta)*cos(gamma)
	// electron emission in lab-system
	s_angle[0][0]=cos(-azi_angle_correct)*x_raw+sin(-azi_angle_correct)*y_raw
	s_angle[1][0]=cos(-azi_angle_correct)*y_raw-sin(-azi_angle_correct)*x_raw
	s_angle[2][0]= cos(slit_beta)
	
End



/////////////flip to k//////////////////////

ThreadSafe Function flip_to_k(kvac,innerE,th,ph,azi,beta,gamma,k_flag,curveflag)
	Variable kvac,innerE,th,ph,azi,beta,gamma,k_flag,curveflag
	
	Variable d2r = pi/180
	variable mass = 9.1095e-31
    	variable hbar = 1.05459e-34
    	Variable kztemp,EZ
	th *= d2r
	ph *= d2r
	azi *= d2r
	beta *= d2r
	gamma *= d2r
	Make/o/n=(3,3) R1,R2,R3
	Make/o/n=(3,1) k, s_angle
	
	// electron emission in lab-system
	
	if (curveflag)
		curve_slit_correction(beta,gamma,s_angle)
	else
		s_angle[0][0]=sin(beta)*sin(gamma)
		s_angle[1][0]=sin(beta)*cos(gamma)
		s_angle[2][0]= cos(beta)
	endif
	
	// rotation to sample-system
	R1[0][] = {{cos(azi)},{sin(azi)},{0}}
	R1[1][]={{-sin(azi)},{cos(azi)},{0}}
	R1[2][] ={{0},{0},{1}} 
	
	R2[0][]= { {1},{0},{0}}
	R2[1][]={{0},{cos(ph)},{sin(ph)}}
	R2[2][]={{0},{-sin(ph)},{cos(ph)} }
	 
	R3[0][]= { {cos(th)},{0},{sin(th)}}
	R3[1][]={{0},{1},{0}}
	R3[2][]={{-sin(th)},{0},{cos(th)} }
//
	MatrixMultiply R1,R2,R3,s_angle
	
	Wave M_product
	
	Variable kx = M_product[0][0]
	Variable ky = M_product[1][0]
	Variable kz = M_product[2][0]
	
	KillWaves/Z  s_angle,R1,R2,R3,M_product,k
	switch (k_flag)
	case 0:
		return kvac * kx
		break
	case 1:
		return kvac * ky
		break
	case 2:
		kztemp=kvac*kz*1e10
		EZ=(kztemp*kztemp)*hbar*hbar/(2*mass)+innerE*1.602e-19
		return sqrt((2*mass*EZ)/hbar^2)*1e-10
		break
	endswitch
	
End
/////////////////////////////DA30, 20190425, SDC/////////////////////////////////////
ThreadSafe Function flip_to_k_DA30(kvac,innerE,th,ph,azi, deflectorY, beta,gamma,k_flag,curveflag)
	Variable kvac,innerE,th,ph,azi,deflectorY, beta,gamma,k_flag,curveflag
	
	Variable d2r = pi/180
	variable mass = 9.1095e-31
    	variable hbar = 1.05459e-34
    	Variable kztemp,EZ
	th *= d2r
	ph *= d2r
	azi *= d2r
	beta *= d2r
	gamma *= d2r
	deflectorY *=d2r
	Make/o/n=(3,3) R1,R2,R3
	Make/o/n=(3,1) k, s_angle
	
	// electron emission in lab-system
	
	variable deflector_total= sqrt(beta^2+deflectorY^2)
	
	if(deflector_total!=0)	
		s_angle[0][0]=sin(deflector_total)*(deflectorY*cos(gamma)+beta*sin(gamma))/deflector_total// perpendicular to the slit in gamma = 0 configration
		s_angle[1][0]=sin(deflector_total)*(deflectorY*sin(gamma)+beta*cos(gamma))/deflector_total// along the slit in gamma=0 configration
		s_angle[2][0]= cos(deflector_total)
	else
		s_angle[0][0]=0
		s_angle[1][0]=0
		s_angle[2][0]=1
	endif
// 	R4000 config, with gamma = 0
//	s_angle[0][0]=sin(beta)*sin(gamma)
//	s_angle[1][0]=sin(beta)*cos(gamma)
//	s_angle[2][0]= cos(beta)

	// rotation to sample-system
	R1[0][] = {{cos(azi)},{sin(azi)},{0}}
	R1[1][]={{-sin(azi)},{cos(azi)},{0}}
	R1[2][] ={{0},{0},{1}} 
	
	R2[0][]= { {1},{0},{0}}
	R2[1][]={{0},{cos(ph)},{sin(ph)}}
	R2[2][]={{0},{-sin(ph)},{cos(ph)} }
	 
	R3[0][]= { {cos(th)},{0},{sin(th)}}
	R3[1][]={{0},{1},{0}}
	R3[2][]={{-sin(th)},{0},{cos(th)} }
//
	MatrixMultiply R1,R2,R3,s_angle
	
	Wave M_product
	
	Variable kx = M_product[0][0]
	Variable ky = M_product[1][0]
	Variable kz = M_product[2][0]
	
	KillWaves/Z  s_angle,R1,R2,R3,M_product,k
	switch (k_flag)
	case 0:
		return kvac * kx
		break
	case 1:
		return kvac * ky
		break
	case 2:
		kztemp=kvac*kz*1e10
		EZ=(kztemp*kztemp)*hbar*hbar/(2*mass)+innerE*1.602e-19
		return sqrt((2*mass*EZ)/hbar^2)*1e-10
		break
	endswitch
	
End



Function flip_to_k_wave_precisemap_DA30(kvac,innerE,th,ph,azi,deflectorY,betaw,gamma,curveflag)
	Variable kvac,innerE,th,ph,azi,deflectorY
	Wave Betaw
	Variable gamma
	Variable curveflag
	
	Variable d2r = pi/180
	variable mass = 9.1095e-31
      variable hbar = 1.05459e-34
      Variable kztemp,EZ
	th *= d2r
	ph *= d2r
	azi *= d2r
	gamma *= d2r
	deflectorY *=d2r
	Make/o/n=(3,3) R1,R2,R3
	//Make/o/n=3 k, s_angle
	
	Make /o/n=(numpnts(betaw),3) M_result
	
	R1[0][] = {{cos(azi)},{sin(azi)},{0}}
	R1[1][]={{-sin(azi)},{cos(azi)},{0}}
	R1[2][] ={{0},{0},{1}} 
	
	R2[0][]= { {1},{0},{0}}
	R2[1][]={{0},{cos(ph)},{sin(ph)}}
	R2[2][]={{0},{-sin(ph)},{cos(ph)} }
	 
	R3[0][]= { {cos(th)},{0},{sin(th)}}
	R3[1][]={{0},{1},{0}}
	R3[2][]={{-sin(th)},{0},{cos(th)} }
		
	//R1 = { {cos(azi),sin(azi),0}, {-sin(azi),cos(azi),0}, {0,0,1} }
	//R2 = { {1,0,0}, {0,cos(ph),-sin(ph)}, {0,sin(ph),cos(ph)} }
	//R3 = { {cos(th),0,-sin(th)}, {0,1,0}, {sin(th),0,cos(th)} }
	
	Variable index=0
	Variable beta
	
	Multithread  M_result[][]=Calculate_angle_to_K_DA30(kvac,R1,R2,R3,gamma,deflectorY,betaw[p],q,curveflag)
	
	//Multithread M_result[][2]=sqrt((2*mass*(((M_result[p][2]*1e10*hbar)^2/(2*mass))+innerE*1.602e-19))/hbar^2)*1e-10

	KillWaves/Z R1,R2,R3
End

threadsafe Function Calculate_Angle_to_K_DA30(kvac,R1,R2,R3,gamma,deflectorY,x,kxkykzflag,curveflag)
	Variable kvac
	Wave R1,R2,R3
	Variable gamma, deflectorY
	Variable x	
	Variable kxkykzflag
	Variable curveflag
	DFREF dfSav= GetDataFolderDFR()
	
	SetDataFolder NewFreeDataFolder()
	
	Make/o/FREE/n=3 s_angle
	
	variable beta=x*pi/180
	
	
	variable deflector_total= sqrt(beta^2+deflectorY^2)
	
	if(deflector_total!=0)	
		s_angle[0][0]=sin(deflector_total)*(deflectorY*cos(gamma)+beta*sin(gamma))/deflector_total// perpendicular to the slit in gamma = 0 configration
		s_angle[1][0]=sin(deflector_total)*(deflectorY*sin(gamma)+beta*cos(gamma))/deflector_total// along the slit in gamma=0 configration
		s_angle[2][0]= cos(deflector_total)
	else
		s_angle[0][0]=0
		s_angle[1][0]=0
		s_angle[2][0]=1
	endif
	
	//s_angle = {sin(beta)*sin(gamma),sin(beta)*cos(gamma),cos(beta)}
	
	MatrixMultiply R1,R2,R3,s_angle
	Wave M_product
	if (kxkykzflag==0)
		SetDataFolder dfSav
		return kvac*M_product[0][0]
	elseif (kxkykzflag==1)
		SetDataFolder dfSav
		return kvac*M_product[1][0]
	elseif (kxkykzflag==2)
		SetDataFolder dfSav
		return kvac*M_product[2][0]
	endif	
End



Function flip_to_k_wave_DA30(kvac,innerE,th,ph,azi,deflectorY, betaw,gamma,curveflag)
	Variable kvac,innerE,th,ph,azi, deflectorY
	Wave Betaw
	Variable gamma
	Variable curveflag
	
	Variable d2r = pi/180
	variable mass = 9.1095e-31
      variable hbar = 1.05459e-34
      Variable kztemp,EZ
	th *= d2r
	ph *= d2r
	azi *= d2r
	gamma *= d2r
	deflectorY*=d2r
	Make/o/n=(3,3) R1,R2,R3
	//Make/o/n=3 k, s_angle
	
	Make /o/n=(numpnts(betaw),3) M_result
	
	R1[0][] = {{cos(azi)},{sin(azi)},{0}}
	R1[1][]={{-sin(azi)},{cos(azi)},{0}}
	R1[2][] ={{0},{0},{1}} 
	
	R2[0][]= { {1},{0},{0}}
	R2[1][]={{0},{cos(ph)},{sin(ph)}}
	R2[2][]={{0},{-sin(ph)},{cos(ph)} }
	 
	R3[0][]= { {cos(th)},{0},{sin(th)}}
	R3[1][]={{0},{1},{0}}
	R3[2][]={{-sin(th)},{0},{cos(th)} }
		
	//R1 = { {cos(azi),sin(azi),0}, {-sin(azi),cos(azi),0}, {0,0,1} }
	//R2 = { {1,0,0}, {0,cos(ph),-sin(ph)}, {0,sin(ph),cos(ph)} }
	//R3 = { {cos(th),0,-sin(th)}, {0,1,0}, {sin(th),0,cos(th)} }
	
	Variable index=0
	Variable beta
	
	Multithread  M_result[][]=Calculate_angle_to_K_DA30(kvac,R1,R2,R3,gamma,deflectorY, betaw[p],q,curveflag)
	
	Multithread M_result[][2]=sqrt((2*mass*(((M_result[p][2]*1e10*hbar)^2/(2*mass))+innerE*1.602e-19))/hbar^2)*1e-10

	
	KillWaves/Z R1,R2,R3
	
End

ThreadSafe Function flip_DeflectorY_of_k_DA30(alpha,phi,theta,kvac,gammaA,kx,ky)
	//calculate deflectorY from kx, ky, kvac, alpha, phi, theta
	//alpha is azi
	Variable alpha, phi,theta,kvac, gammaA,  kx, ky

	
	if(gammaA!=0)
		print "Gamma error.\r"
		return nan
	endif
	
	Variable kx_R1= cos(alpha*pi/180)*kx - sin(alpha*pi/180)*ky
	Variable ky_R1=sin(alpha*pi/180)*kx + cos(alpha*pi/180)*ky 
	Variable kz_R1=sqrt(kvac^2-kx^2-ky^2)
	
	Variable kx_R2 = kx_R1
	variable ky_R2 = cos(phi*pi/180)*ky_R1-sin(phi*pi/180)*kz_R1
	variable kz_R2 = sin(phi*pi/180)*ky_R1+cos(phi*pi/180)*kz_R1
	
	Variable kx_R3 = cos(theta*pi/180)*kx_R2-sin(theta*pi/180)*kz_R2
	Variable ky_R3 = ky_R2
	Variable kz_R3 = sin(theta*pi/180)*kx_R2+cos(theta*pi/180)*kz_R2
	
	variable deflector_total = acos(kz_R3/kvac)
	
	if(sin(deflector_total)==0)
		return 0
	else
		return (180/pi)*deflector_total*((kx_R3/kvac)/sin(deflector_total))
	endif

End

ThreadSafe Function flip_beta_of_k_DA30(alpha,phi,theta,kvac,gammaA,kx,ky)
	//calculate deflectorX, aka beta, from kx, ky, kvac, alpha, phi, theta
	//alpha is azi
	Variable alpha, phi,theta,kvac, gammaA,  kx, ky

	
	if(gammaA!=0)
		print "Gamma error.\r"
		return nan
	endif
	
	Variable kx_R1= cos(alpha*pi/180)*kx - sin(alpha*pi/180)*ky
	Variable ky_R1=sin(alpha*pi/180)*kx + cos(alpha*pi/180)*ky 
	Variable kz_R1=sqrt(kvac^2-kx^2-ky^2)
	
	Variable kx_R2 = kx_R1
	variable ky_R2 = cos(phi*pi/180)*ky_R1-sin(phi*pi/180)*kz_R1
	variable kz_R2 = sin(phi*pi/180)*ky_R1+cos(phi*pi/180)*kz_R1
	
	Variable kx_R3 = cos(theta*pi/180)*kx_R2-sin(theta*pi/180)*kz_R2
	Variable ky_R3 = ky_R2
	Variable kz_R3 = sin(theta*pi/180)*kx_R2+cos(theta*pi/180)*kz_R2
	
	variable deflector_total = acos(kz_R3/kvac)
	
	if(sin(deflector_total)==0)
		return 0
	else
		return (180/pi)*deflector_total*((ky_R3/kvac)/sin(deflector_total))
	endif

End





ThreadSafe Function flip_theta_of_k_DA30(alpha,phi,kvac,deflectorY,betaA,gammaA,kx,ky)
	Variable alpha,phi,kvac,deflectorY,betaA,gammaA,kx,ky
	
	if(gammaA!=0)
		print "Gamma error.\r"
		return nan
	endif
	
	Variable kx_R1= cos(alpha*pi/180)*kx - sin(alpha*pi/180)*ky
	Variable ky_R1=sin(alpha*pi/180)*kx + cos(alpha*pi/180)*ky 
	Variable kz_R1=sqrt(kvac^2-kx^2-ky^2)
	
	Variable kx_R2 = kx_R1
	variable ky_R2 = cos(phi*pi/180)*ky_R1-sin(phi*pi/180)*kz_R1
	variable kz_R2 = sin(phi*pi/180)*ky_R1+cos(phi*pi/180)*kz_R1
	
	
	variable deflector_total = sqrt(betaA^2+deflectorY^2)
	variable sx, sy, sz
	if(deflector_total==0)
		sx=0
		sy=0
		sz=1
	else
		sx = sin(deflector_total*pi/180)*deflectorY/deflector_total
		sy = sin(deflector_total*pi/180)*betaA/deflector_total
		sz = cos(deflector_total*pi/180)
	endif
	
	variable costheta = (sx*kx_R2+sz*kz_R2)/(kvac*(sx^2+sz^2))
	
	return acos(costheta)
End




/////////////////////////////////DA30 END//////////////////////////////////



Function flip_to_k_wave_precisemap(kvac,innerE,th,ph,azi,betaw,gamma,curveflag)
	Variable kvac,innerE,th,ph,azi
	Wave Betaw
	Variable gamma
	Variable curveflag
	
	Variable d2r = pi/180
	variable mass = 9.1095e-31
      variable hbar = 1.05459e-34
      Variable kztemp,EZ
	th *= d2r
	ph *= d2r
	azi *= d2r
	gamma *= d2r
	Make/o/n=(3,3) R1,R2,R3
	//Make/o/n=3 k, s_angle
	
	Make /o/n=(numpnts(betaw),3) M_result
	
	R1[0][] = {{cos(azi)},{sin(azi)},{0}}
	R1[1][]={{-sin(azi)},{cos(azi)},{0}}
	R1[2][] ={{0},{0},{1}} 
	
	R2[0][]= { {1},{0},{0}}
	R2[1][]={{0},{cos(ph)},{sin(ph)}}
	R2[2][]={{0},{-sin(ph)},{cos(ph)} }
	 
	R3[0][]= { {cos(th)},{0},{sin(th)}}
	R3[1][]={{0},{1},{0}}
	R3[2][]={{-sin(th)},{0},{cos(th)} }
		
	//R1 = { {cos(azi),sin(azi),0}, {-sin(azi),cos(azi),0}, {0,0,1} }
	//R2 = { {1,0,0}, {0,cos(ph),-sin(ph)}, {0,sin(ph),cos(ph)} }
	//R3 = { {cos(th),0,-sin(th)}, {0,1,0}, {sin(th),0,cos(th)} }
	
	Variable index=0
	Variable beta
	
	Multithread  M_result[][]=Calculate_angle_to_K(kvac,R1,R2,R3,gamma,betaw[p],q,curveflag)
	
	//Multithread M_result[][2]=sqrt((2*mass*(((M_result[p][2]*1e10*hbar)^2/(2*mass))+innerE*1.602e-19))/hbar^2)*1e-10

	KillWaves/Z R1,R2,R3
End

Function flip_to_k_wave(kvac,innerE,th,ph,azi,betaw,gamma,curveflag)
	Variable kvac,innerE,th,ph,azi
	Wave Betaw
	Variable gamma
	Variable curveflag
	
	Variable d2r = pi/180
	variable mass = 9.1095e-31
      variable hbar = 1.05459e-34
      Variable kztemp,EZ
	th *= d2r
	ph *= d2r
	azi *= d2r
	gamma *= d2r
	Make/o/n=(3,3) R1,R2,R3
	//Make/o/n=3 k, s_angle
	
	Make /o/n=(numpnts(betaw),3) M_result
	
	R1[0][] = {{cos(azi)},{sin(azi)},{0}}
	R1[1][]={{-sin(azi)},{cos(azi)},{0}}
	R1[2][] ={{0},{0},{1}} 
	
	R2[0][]= { {1},{0},{0}}
	R2[1][]={{0},{cos(ph)},{sin(ph)}}
	R2[2][]={{0},{-sin(ph)},{cos(ph)} }
	 
	R3[0][]= { {cos(th)},{0},{sin(th)}}
	R3[1][]={{0},{1},{0}}
	R3[2][]={{-sin(th)},{0},{cos(th)} }
		
	//R1 = { {cos(azi),sin(azi),0}, {-sin(azi),cos(azi),0}, {0,0,1} }
	//R2 = { {1,0,0}, {0,cos(ph),-sin(ph)}, {0,sin(ph),cos(ph)} }
	//R3 = { {cos(th),0,-sin(th)}, {0,1,0}, {sin(th),0,cos(th)} }
	
	Variable index=0
	Variable beta
	
	Multithread  M_result[][]=Calculate_angle_to_K(kvac,R1,R2,R3,gamma,betaw[p],q,curveflag)
	
	Multithread M_result[][2]=sqrt((2*mass*(((M_result[p][2]*1e10*hbar)^2/(2*mass))+innerE*1.602e-19))/hbar^2)*1e-10

	
	KillWaves/Z R1,R2,R3
	
End

threadsafe Function Calculate_Angle_to_K(kvac,R1,R2,R3,gamma,x,kxkykzflag,curveflag)
	Variable kvac
	Wave R1,R2,R3
	Variable gamma
	Variable x	
	Variable kxkykzflag
	Variable curveflag
	DFREF dfSav= GetDataFolderDFR()
	
	SetDataFolder NewFreeDataFolder()
	
	Make/o/FREE/n=3 s_angle
	
	variable beta=x*pi/180
	
	if (curveflag==1)
		curve_slit_correction(beta,gamma,s_angle)
	else
		s_angle[0][0]=sin(beta)*sin(gamma)
		s_angle[1][0]=sin(beta)*cos(gamma)
		s_angle[2][0]= cos(beta)
	endif
	//s_angle = {sin(beta)*sin(gamma),sin(beta)*cos(gamma),cos(beta)}
	
	MatrixMultiply R1,R2,R3,s_angle
	Wave M_product
	if (kxkykzflag==0)
		SetDataFolder dfSav
		return kvac*M_product[0][0]
	elseif (kxkykzflag==1)
		SetDataFolder dfSav
		return kvac*M_product[1][0]
	elseif (kxkykzflag==2)
		SetDataFolder dfSav
		return kvac*M_product[2][0]
	endif	
End


//////////////////////////k to angle////////////////////////


ThreadSafe Function flip_coarseAngle_of_k_precise(alpha,phi,kvac,gammaA,kx,ky,curveflag)
	Variable alpha, phi,kvac, gammaA,kx, ky,curveflag
	
	//first rotate alpha back
	Variable kz=sqrt(kvac^2-kx^2-ky^2)
	Variable kx_rot= cos(alpha*pi/180)*kx - sin(alpha*pi/180)*ky
	Variable ky_rot=sin(alpha*pi/180)*kx + cos(alpha*pi/180)*ky 
	
	if (gammaA==0)
		Variable ky_rotphi=cos(phi*pi/180)*ky_rot-sin(phi*pi/180)*kz
		Variable kz_rotphi=sin(phi*pi/180)*ky_rot+cos(phi*pi/180)*kz
		if (curveflag==0)
			return atan(kx_rot/kz_rotphi) * 180/pi// this essentially returns theta
		else
			return (atan(kx_rot/kz_rotphi) - curve_slit_correction_quick(asin(ky_rotphi/kvac),gammaA*pi/180))* 180/pi
		endif
	else
		Variable phi_rot=atan(ky_rot/kz)*180/pi
		kz_rotphi=sin(phi_rot*pi/180)*ky_rot+cos(phi_rot*pi/180)*kz
		
		Variable kx_rottheta=cos(-phi*pi/180)*kx_rot+sin(-phi*pi/180)*kz_rotphi
		//Variable kz_rottheta=-sin(-phi*pi/180)*kx_rot+cos(-phi*pi/180)*kz_rotphi
		
		return asin(kx_rottheta/kvac)*180/pi
	endif
End

ThreadSafe Function flip_fineAngle_of_k_precise(alpha,phi,kvac,gammaA,kx,ky,curveflag)
	Variable alpha, phi,kvac, gammaA,kx, ky,curveflag
	
	Variable kz=sqrt(kvac^2-kx^2-ky^2)
	Variable kx_rot= cos(alpha*pi/180)*kx - sin(alpha*pi/180)*ky
	Variable ky_rot=sin(alpha*pi/180)*kx + cos(alpha*pi/180)*ky 
	
	if (gammaA==0)
		Variable ky_rotphi=cos(phi*pi/180)*ky_rot-sin(phi*pi/180)*kz
	//	Variable kz_rotphi=sin(phi*pi/180)*ky_rot+cos(phi*pi/180)*kz
		return asin(ky_rotphi/kvac)*180/pi// this returns beta
	else
		Variable phi_rot=atan(ky_rot/kz)*180/pi
		Variable kz_rotphi=sin(phi_rot*pi/180)*ky_rot+cos(phi_rot*pi/180)*kz
		
		Variable kx_rottheta=cos(-phi*pi/180)*kx_rot+sin(-phi*pi/180)*kz_rotphi
		//ky_rotphi=cos(phi*pi/180)*ky_rot-sin(phi*pi/180)*kz
		//Variable kx_rotphi=cos(-phi*pi/180)*kx_rot+sin(-phi*pi/180)*kz
		//kz_rotphi=-sin(-phi*pi/180)*kx_rot+cos(-phi*pi/180)*kz
		
		if (curveflag==0)
			return atan(ky_rot/kz)*180/pi
		else
			return (atan(ky_rot/kz)- curve_slit_correction_quick(asin(kx_rottheta/kvac),gammaA*pi/180))*180/pi
		endif
	endif
	
End

///////////////polar/////////////////

// correction for ph != 0 to be implemented
ThreadSafe Function Fadley_AzimuthalAngle_of_k(theta,phi,kvac,gammaA,kx,ky)	// fine angle has to be polar angle for Fadley-type
	Variable theta,phi,kvac
	Variable gammaA, kx, ky
	
	Variable kz=sqrt(kvac^2-kx^2-ky^2)
	
	if (gammaA==0)
	
		variable temp1=cos(-theta*pi/180)*kx+sin(-theta*pi/180)*sin(phi*pi/180)*ky
		Variable temp2=-cos(-theta*pi/180)*ky+sin(-theta*pi/180)*sin(phi*pi/180)*kx
		Variable temp3=sin(-theta*pi/180)*cos(phi*pi/180)*kz
		
		
	else
		temp1=ky
		temp2=kx
		temp3=-kz*sin(phi*pi/180)/cos(phi*pi/180)
	endif
	
	Variable A=temp1^2+temp2^2
	Variable B=2*temp1*temp3
	Variable C=temp3^2-temp2^2

	variable result1=(-B+sqrt(b^2-4*a*c))/2/A
	variable result2=(-B-sqrt(b^2-4*a*c))/2/A
	
	if (GammaA==0)
		if (kx*ky>=0)
			return acos(result1)/pi*180
		else
			return acos(result2)/pi*180
		endif
	else
		if (kx*ky>=0)
			return acos(result2)/pi*180
		else
			return acos(result1)/pi*180
		endif
	endif
		
	//return cmplx(acos(result1)/pi*180,acos(result2)/pi*180)
	//asin(sqrt(kx*kx+ky*ky)/kvac) * 180/pi
End


ThreadSafe Function /C Fadley_PolarAngle_of_k(theta,phi,kvac,gammaA,kx,ky)		// coarse angle has to be azimuthal angle for Fadley type
	Variable theta,phi,kvac
	Variable gammaA, kx, ky
	
	Variable  alpha_C=Fadley_AzimuthalAngle_of_k(theta,phi,kvac,gammaA,kx,ky)
	
	Make /o/Free/n=4 kx_rot,ky_rot,alpha,temp1,returnval
	
	alpha[0]=alpha_C
	alpha[1]=alpha_C+180
	alpha[2]=alpha_C-180
	alpha[3]=alpha_C-360
	
	Variable kz=sqrt(kvac^2-kx^2-ky^2)
	kx_rot= cos(alpha*pi/180)*kx - sin(alpha*pi/180)*ky
	ky_rot=sin(alpha*pi/180)*kx + cos(alpha*pi/180)*ky 
	
	if (gammaA==0)
		temp1=ky_rot*cos(phi*pi/180)-kz*sin(phi*pi/180)
		//Variable temp2=kx_rot*sin(-theta*pi/180)+cos(-theta*pi/180)*(ky_rot*sin(phi*pi/180)+kz*cos(phi*pi/180))
		returnval=asin(temp1/kvac)/pi*180
	else
		temp1=kx_rot*cos(-theta*pi/180)+sin(-theta*pi/180)*(ky_rot*sin(phi*pi/180)+kz*cos(phi*pi/180))
		returnval=asin(temp1/kvac)/pi*180
	endif
	Variable index
	do
		if (abs(returnval[index])<20)
		//if (alpha[index]<90)&&(alpha[index]>-90)
			return cmplx(returnval[index],alpha[index])
		endif
		index+=1
	while (index<4)
End


ThreadSafe Function /C Fadley_PolarAngle_of_k_BZ(theta,phi,kvac,gammaA,kx,ky)		// coarse angle has to be azimuthal angle for Fadley type
	Variable theta,phi,kvac
	Variable gammaA, kx, ky
	
	Variable  alpha_C=Fadley_AzimuthalAngle_of_k(theta,phi,kvac,gammaA,kx,ky)
	
	Make /o/Free/n=4 kx_rot,ky_rot,alpha,temp1,returnval
	
	alpha[0]=alpha_C
	alpha[1]=alpha_C+180
	alpha[2]=alpha_C-180
	alpha[3]=alpha_C-360
	
	Variable kz=sqrt(kvac^2-kx^2-ky^2)
	kx_rot= cos(alpha*pi/180)*kx - sin(alpha*pi/180)*ky
	ky_rot=sin(alpha*pi/180)*kx + cos(alpha*pi/180)*ky 
	
	if (gammaA==0)
		temp1=ky_rot*cos(phi*pi/180)-kz*sin(phi*pi/180)
		//Variable temp2=kx_rot*sin(-theta*pi/180)+cos(-theta*pi/180)*(ky_rot*sin(phi*pi/180)+kz*cos(phi*pi/180))
		returnval=asin(temp1/kvac)/pi*180
	else
		temp1=kx_rot*cos(-theta*pi/180)+sin(-theta*pi/180)*(ky_rot*sin(phi*pi/180)+kz*cos(phi*pi/180))
		returnval=asin(temp1/kvac)/pi*180
	endif
	Variable index
	do
		if (returnval[index]>0)
			return cmplx(returnval[index],alpha[index])
		endif
		index+=1
	while (index<4)
End


ThreadSafe Function /C Kxkz_EF_phi_of_k(e_center,ky,kz,theta,phi,azi,InnerE,gammaA)

	Variable e_center,ky,kz,theta,phi,azi,InnerE,gammaA

	Variable d2r = pi/180
	variable mass = 9.1095e-31
    	variable hbar = 1.05459e-34
    
	Variable kztemp
	variable EZ
	
	EZ=	(kz/1e-10)^2*hbar^2/(2*mass)
	EZ=(EZ-InnerE*1.602e-19)
	
	kztemp=sqrt(EZ*(2*mass)/hbar^2)*1e-10
	
	Variable temp1,temp2,temp3,temp4
	
	if (GammaA==0)
		temp1=sin(-theta*d2r)*sin(azi*d2r)*sin(phi*d2r)
		temp2=-cos(-theta*d2r)*cos(azi*d2r)
		temp3= kztemp*cos(phi*d2r)*sin(-theta*d2r)*sin(azi*d2r)
		temp4=cos(-theta*d2r)*ky
	
		variable ky_rot=(temp4-temp3)/(temp1-temp2)	
		
		temp1=-cos(-theta*d2r)*cos(azi*d2r)
		temp2=sin(-theta*d2r)*sin(azi*d2r)*sin(phi*d2r)
		
		temp3= kztemp*cos(phi*d2r)*sin(-theta*d2r)*cos(azi*d2r)
		temp4=sin(-theta*d2r)*ky*sin(phi*d2r)
		
		variable kx_rot=(-temp4-temp3)/(temp1+temp2)
		
		Variable kvac=sqrt(kx_rot^2+ky_rot^2+kztemp^2)
		
		Variable ky_final=ky_rot*cos(phi*d2r)-kztemp*sin(phi*d2r)
		
		Variable returnval=asin(ky_final/kvac)/d2r
		
		
	else
		ky_rot=kztemp*tan(phi*d2r)
		kx_rot=(ky-sin(azi*d2r)*ky_rot)/cos(azi*d2r)  //may have zero proberm
		kvac=sqrt(kx_rot^2+ky_rot^2+kztemp^2)
		
		Variable kx_Final=cos(-theta*d2r)*kx_rot+sin(-theta*d2r)*(ky_rot*sin(phi*d2r)+kztemp*cos(phi*d2r))
		
		returnval=asin(kx_final/kvac)/d2r
	endif
		
	Variable returnef=(kvac/0.5123)^2-e_center
	
	return cmplx(returnef,returnval)
//	Variable ky=kztemp*tan(ph_kz*d2r)
	
	//Variable kvac=sqrt(kx^2+ky^2+kztemp^2)
	
	//return asin(kx/kvac)/d2r

End








//////////////////////////normalize///////////////////////////


Function make_NormWave(cubeindex,w_sourcePathes)
	Variable cubeindex
	WAVE/T w_sourcePathes
	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	
	NVAR toplayernum=DFR_common:gv_toplayernum
	NVAR topprocnum=DFR_common:gv_topprocnum
	NVAR autolayerflag=DFR_common:autolayerflag
	
	SetDatafolder DFR_panel
	
	if (cubeindex==0)
		String normalwavename="Wave_normal"
		String normalwavename_smooth="Wave_normal_S"
	else
		normalwavename="Wave_normal"+"_"+num2str(cubeindex)
		normalwavename_smooth="Wave_normal_S"+"_"+num2str(cubeindex)
	endif
	
	NVAR normmethodflag=gv_normmethodflag
	NVAR normal_percentage=gv_normal_percentage
	NVAR smoothflag=gv_smoothflag
	NVAR smoothpnts=gv_smoothpnts
	NVAR smoothtimes=gv_smoothtimes
	NVAR E0=gv_tmf_e0
	NVAR E1=gv_tmf_e1
	controlinfo normal_c10
	Variable totalEnergyflag=v_Value
	
	controlinfo normal_c21
	Variable totalcorflag=v_value
	make /o/n=(numpnts(w_sourcePathes)) Wave_normal_temp
	Variable index,dE0,dE1
		
	Switch (normmethodflag)
	case 0:  //none
		Wave_normal_temp=1
		break
	case 1:  //percentage
		do
			Wave data=$w_sourcePathes[index]
			
			Variable datalayernum=Autolayer_wavelist(data,toplayernum,topprocnum,autolayerflag)
		
			Getlayerimage(data,datalayernum)	
			Wave w=templayerimage
			
			if (totalEnergyflag)
				duplicate /o w,w_temp
			else
				duplicate /o /R=[](min(E0,E1),max(E0,E1)) w,w_temp
			endif 
			Variable NORM_PERC_HISTO_SIZE=65535
			Make/O/N=(NORM_PERC_HISTO_SIZE), w_percHisto_tmp
			WaveStats/Q/Z w_temp
			SetScale/I x, V_min, V_max, w_percHisto_tmp
			Histogram/B=2 w_temp, w_percHisto_tmp
			Integrate/DIM=0  w_percHisto_tmp /D=w_percHistoInt_tmp
			Variable percentile = w_percHistoInt_tmp[NORM_PERC_HISTO_SIZE-1] * normal_percentage / 100
		
			Variable j
				// BUGFIX FOR:
				// FindValue/T=(percentile/1000)/V=(percentile) w_percHistoInt_tmp
			for(j = 0; j < NORM_PERC_HISTO_SIZE; j += 1)
				if (w_percHistoInt_tmp[j] >= percentile)
					break
				endif
			endfor
			Wave_normal_temp[index] = pnt2x(w_percHistoInt_tmp, j)
			index+=1
		while (index<numpnts(w_sourcePathes))
		killwaves /Z w_temp,w_percHistoInt_tmp,w_percHisto_tmp,templayerimage
		break
	case 2: //patial intensityu
		do
			Wave data=$w_sourcePathes[index]
		
			datalayernum=Autolayer_wavelist(data,toplayernum,topprocnum,autolayerflag)
			
			Getlayerimage(data,datalayernum)	
			Wave w=templayerimage
			
			if (totalEnergyflag)
				duplicate /o w,w_temp
			else
				duplicate /o /R=[](min(E0,E1),max(E0,E1)) w,w_temp
			endif 
			NORM_PERC_HISTO_SIZE=65535
			Make/O/N=(NORM_PERC_HISTO_SIZE), w_percHisto_tmp
			WaveStats/Q/Z w_temp
			SetScale/I x, V_min, V_max, w_percHisto_tmp
			Histogram/B=2 w_temp, w_percHisto_tmp
			duplicate /o w_percHisto_tmp,w_percHisto_tmp_x
			w_percHisto_tmp_x=w_percHisto_tmp*x
			//Integrate/DIM=0  w_percHisto_tmp /D=w_percHistoInt_tmp
			Wave_normal_temp[index]=sum(w_percHisto_tmp_x,V_min,(V_min+normal_percentage/100*(V_max-V_min)))//w_percHistoInt_tmp((normal_percentage/100*V_max))
			index+=1
		while (index<numpnts(w_sourcePathes))
		killwaves /Z w_temp,w_percHistoInt_tmp,w_percHisto_tmp,templayerimage
		break
	case 3:
		Wave /Z Wave_normal_S=$normalwavename_smooth
		if (Waveexists(Wave_normal_S))
			Wave wave_normal=$normalwavename
			
			Variable exists_num=numpnts(Wave_normal_S)
			if (numpnts(w_sourcePathes)!=exists_num)
				redimension /n=(numpnts(w_sourcePathes)) Wave_normal_S,wave_normal
				Wave_normal_S=(p>(exists_num-1))?(1):Wave_normal_S
				wave_normal=Wave_normal_S
			else
				wave_normal=Wave_normal_S
			endif
			
			SetDatafolder DF
			return 1
		else
			make /o/n=(numpnts(w_sourcePathes)) $normalwavename,$normalwavename_smooth
			Wave Wave_normal=$normalwavename
			Wave Wave_normal_S=$normalwavename_smooth
			Wave_normal=1
			Wave_normal_S=1
			SetDatafolder DF
			return 1
		endif
		break
	endswitch
	
	make /o/n=(numpnts(w_sourcePathes)) $normalwavename
	Wave Wave_normal=$normalwavename
	Wave_normal=1
	if (totalcorflag==0)
		index=0
		do 
		Wave_normal[index+1]=Wave_normal[index]*(Wave_normal_temp[index]/Wave_normal_temp[index+1])
		index+=1
		while (index<(numpnts(Wave_normal_temp)-1))
	else
		Wave_normal=1/Wave_normal_temp[p]*(mean(Wave_normal_temp))
	endif
	
	Killwaves/Z Wave_normal_temp
	
	make /o/n=(numpnts(w_sourcePathes)) $normalwavename_smooth
	Wave Wave_normal_S=$normalwavename_smooth
	Wave_normal_S=Wave_normal[p]
	if (smoothflag)
		M_smooth_times(Wave_normal_S,-1,smoothpnts,smoothtimes)
	endif
			
	SetDatafolder DF
	return 1
End

//////////////////make waveform/////////

Threadsafe Function /WAVE make_cf_waveform_thread(cube,centerE,dE)
	Wave cube
	Variable centerE,dE

	Variable e0,e1,deltaE,enum
	e0=centerE-dE/2
	e1=centerE+dE/2
	deltaE=dimdelta(cube,2)
	
	if (e0<M_z0(cube))
		e0=M_z0(cube)
	elseif (e0>M_z1(cube))
		e0=M_z1(cube)
	endif
	
	if (e1>M_z1(cube))
		e1=M_z1(cube)
	elseif (e1<M_z0(cube))
		e1=M_z0(cube)
	endif
	
	
	Enum=round((e1-e0)/deltaE+1)

	Variable x0 = M_x0(cube)
	Variable x1 = M_x1(cube)
	Variable y0 = M_y0(cube)
	Variable y1 = M_y1(cube)
	
	Make/o/FREE/n=(dimsize(cube,0),dimsize(cube,1)) cf_waveform	// x is 'coarse', y is 'fine'
	SetScale/I y y0, y1, ""  cf_waveform
	SetScale/I x x0, x1, "" cf_waveform

	cf_waveform=0
	variable index=0
	
	Variable startindex=round((e0-M_z0(cube))/deltaE)
	
	do
		Multithread cf_waveform+=cube[p][q][startindex+index]//(index*deltaE+e0)
		index+=1
	while (index<Enum)
	Multithread cf_waveform/=Enum
	
	return cf_waveform
End

Function make_cf_waveform(cube,centerE,dE)
	Wave cube
	Variable centerE,dE
	//print M_z0(cube),M_z1(cube)
	Variable e0,e1,deltaE,enum
	e0=centerE-dE/2
	e1=centerE+dE/2
	deltaE=dimdelta(cube,2)
	
	if (e0<M_z0(cube))
		e0=M_z0(cube)
	elseif (e0>M_z1(cube))
		e0=M_z1(cube)
	endif
	
	if (e1>M_z1(cube))
		e1=M_z1(cube)
	elseif (e1<M_z0(cube))
		e1=M_z0(cube)
	endif
	
	Enum=round((e1-e0)/deltaE+1)

	Variable x0 = M_x0(cube)
	Variable x1 = M_x1(cube)
	Variable y0 = M_y0(cube)
	Variable y1 = M_y1(cube)
	
	Make/o/n=(dimsize(cube,0),dimsize(cube,1)) cf_waveform	// x is 'coarse', y is 'fine'
	SetScale/I y y0, y1, ""  cf_waveform
	SetScale/I x x0, x1, "" cf_waveform

	cf_waveform=0
	variable index=0
	
	Variable startindex=round((e0-M_z0(cube))/deltaE)
	
	do
		Multithread cf_waveform+=cube[p][q][startindex+index]//(index*deltaE+e0)
		index+=1
	while (index<Enum)
	
	Multithread cf_waveform/=Enum
	
End





/////////////////////////////////////////////kxky mapping//////////////

Function kxky_quick_mapper(cubeindex,cubeflag)
	Variable cubeindex
	Variable cubeflag

	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel
	
	NVAR e_center = gv_centerE
	NVAR dE = gv_dE
	NVAR gammaA=gv_gammaA
	
	
	String interpcubename="cfe_InterpCube"
	String w_cube_xname="w_cube_x_interp"
	String w_cube_yname="w_cube_y_interp"
	String w_cube_pname="w_cube_p_interp"
	String w_cube_qname="w_cube_q_interp"
	
	String FSMname="FSM_kxky"
	String FSM_Fname="FSM_f"
	STring FSM_Cname="FSM_c"
	String cubekxkyname="cfe_kxkycube"
	if (cubeindex>0)
		interpcubename+="_"+num2str(cubeindex)
		
		w_cube_xname+="_"+num2str(cubeindex)
		w_cube_yname+="_"+num2str(cubeindex)
		w_cube_pname+="_"+num2str(cubeindex)
		w_cube_qname+="_"+num2str(cubeindex)
		
		FSMname+="_"+num2str(cubeindex)
		FSM_Fname+="_"+num2str(cubeindex)
		FSM_Cname+="_"+num2str(cubeindex)
		cubekxkyname+="_"+num2str(cubeindex)
	endif
		
	auto_k_grid_kxky(cubeindex,cubeflag,0)
	
	Wave cfe_InterpCube=$interpcubename
	Wave w_cube_x=$w_cube_xname
	Wave w_cube_y=$w_cube_yname
	Wave w_cube_p=$w_cube_pname
	Wave w_cube_q=$w_cube_qname
	
	Wave FSM_f=$FSM_Fname
	Wave FSM_c=$FSM_Cname
	Wave FSM_kxky=$FSMname
	
	Variable kvac
	NVAR initialflag=gv_initialflag
	NVAR curveflag=gv_curveflag
	if (initialflag)
		Variable EF=mean(w_cube_q)
	else
		EF=0
	endif
	
	Variable phi=mean(w_cube_y)
	Variable loc_alpha=mean(w_cube_p)
	//checkreturnwaveequal(w_cube_y,Nan,Nan)
	
	if (cubeflag)
		String newnote=note(cfe_InterpCube)
		
		Make /O/WAVE/N=(dimsize(cfe_InterpCube,2)) Temp_Interp_wave
		Setscale /P x,dimoffset(cfe_InterpCube,2),dimdelta(cfe_InterpCube,2),Temp_Interp_wave
		
		MultiThread Temp_Interp_wave=Cal_kxkyFSM_from_InterpCube(cfe_InterpCube,x,dE,EF,loc_alpha,phi,gammaA,FSM_f,FSM_c,curveflag)
				
		make /o/n=(dimsize(FSM_kxky,0),dimsize(FSM_kxky,1),dimsize(cfe_InterpCube,2)) $cubekxkyname
		Wave cfe_kxkycube=$cubekxkyname
		Setscale /P x,dimoffset(FSM_kxky,0),dimdelta(FSM_kxky,0),cfe_kxkycube
		Setscale /P y,dimoffset(FSM_kxky,1),dimdelta(FSM_kxky,1),cfe_kxkycube
		Setscale /P z,dimoffset(cfe_InterpCube,2),dimdelta(cfe_InterpCube,2),cfe_kxkycube
		Variable index=0//,eindex
		do
	
			 Wave FSM_temp=Temp_Interp_wave[index]
			 cfe_kxkycube[][][index]=FSM_temp[p][q]
		 	index+=1
		while (index<dimsize(cfe_InterpCube,2))
		note cfe_kxkycube newnote
		killwaves /Z Temp_Interp_wave
	else	
		
		Wave FSM_kxky_temp= Cal_kxkyFSM_from_InterpCube(cfe_InterpCube,e_center,dE,EF,loc_alpha,phi,gammaA,FSM_f,FSM_c,curveflag)
		
		Duplicate /o FSM_kxky_temp $FSMname
		
		//Killwaves /Z FSM_c,FSM_f
	endif
	
	SetDAtafolder DF
	
End

/////////////////////////////////Multithread calculate function////////////////
Threadsafe  Function /Wave Cal_kxkyFSM_from_InterpCube(cube,Energy,dE,EF,loc_alpha,phi,gammaA,FSM_f,FSM_c,curveflag)
	Wave cube
	Variable EF,dE,Energy
	Variable loc_alpha,phi,gammaA
	Wave FSM_f
	Wave FSM_c
	Variable curveflag
	
	Duplicate /o /FREE FSM_f,FSM_kxky_temp,FSM_f_temp,FSM_c_temp
	
	Variable kvac=sqrt(Energy+EF)* 0.5123
	
	multithread FSM_f_temp =  flip_fineAngle_of_k_precise(loc_alpha,phi,kvac,gammaA,x,y,curveflag) //flip_coarseAngle_of_k(-loc_alpha,kvac,x,y)
	multithread FSM_c_temp = flip_coarseAngle_of_k_precise(loc_alpha,phi,kvac,gammaA,x,y,curveflag) // flip_fineAngle_of_k(-loc_alpha,kvac,x,y)
	
	
	
	WAVE cf_waveform=make_cf_waveform_thread(cube,Energy,dE/1000)
	
	multithread cf_waveform = (cf_waveform ==0)?(NaN):cf_waveform
	
	if (gammaA == 0)
		//FSM_c_temp=FSM_c_temp[p][q]+curve_slit_correction_quick(FSM_f_temp[p][q],gammaA)
		Multithread FSM_kxky_temp = interp2D(cf_waveform,FSM_c_temp,FSM_f_temp)
	else
		//FSM_f_temp=FSM_f_temp[p][q]+curve_slit_correction_quick(FSM_c_temp[p][q],gammaA)
		Multithread FSM_kxky_temp = interp2D(cf_waveform,FSM_f_temp,FSM_c_temp)
	endif	
	
	Imagestats/M=1 cf_waveform
	multithread FSM_kxky_temp = (FSM_kxky_temp > v_max)?(NaN):FSM_kxky_temp
	multithread FSM_kxky_temp = (FSM_kxky_temp < v_min)?(NaN):FSM_kxky_temp
	
	WaveClear 	FSM_f_temp,FSM_c_temp,cf_waveform
	
	return FSM_kxky_temp	
End


Function kxky_precise_mapper(cubeindex,cubeflag)
	Variable cubeindex
	Variable cubeflag

	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel
	
	NVAR e_center = gv_centerE
	NVAR dE = gv_dE
	NVAR gammaA=gv_gammaA
	NVAR innerE=gv_innerE
	NVAR initialflag=gv_initialflag
	
	String interpcubename="cfe_interpCube"
	String rawcubename="cfe_rawCube"
	String cubekxkyname="cfe_kxkycube"
	String w_cube_xname="w_cube_x_interp"
	String w_cube_yname="w_cube_y_interp"
	String w_cube_pname="w_cube_p_interp"
	String w_cube_qname="w_cube_q_interp"
	String FSMname="FSM_kxky"

	if (cubeindex>0)
		interpcubename+="_"+num2str(cubeindex)
		rawcubename+="_"+num2str(cubeindex)
		cubekxkyname+="_"+num2str(cubeindex)
		w_cube_xname+="_"+num2str(cubeindex)
		w_cube_yname+="_"+num2str(cubeindex)
		w_cube_pname+="_"+num2str(cubeindex)
		w_cube_qname+="_"+num2str(cubeindex)
		FSMname+="_"+num2str(cubeindex)
	endif
	
	Wave cfe_InterpCube=$interpcubename
	Wave w_cube_x=$w_cube_xname
	Wave w_cube_y=$w_cube_yname
	Wave w_cube_p=$w_cube_pname
	Wave w_cube_q=$w_cube_qname
		
	auto_k_grid_kxky(cubeindex,cubeflag,1)
	
	Wave cfe_InterpCube=$interpcubename
	
	NVAR kx0 = gv_kxfrom
	NVAR kx1 = gv_kxto
	NVAR ky0 = gv_kyfrom
	NVAR ky1 = gv_kyto
	NVAR dkx=gv_kxdensity
	NVAR dky=gv_kydensity
	
	
	String waveformxName="cf_waveform_kx"
	String waveformyname="cf_waveform_ky"
	String waveformzname="cf_waveform_kz"
	if (cubeindex>0)
		waveformxName+="_"+num2str(cubeindex)
		waveformyName+="_"+num2str(cubeindex)
		waveformzname+="_"+num2str(cubeindex)
	endif
	
	Wave cf_waveform_kx=$waveformxName
	Wave cf_waveform_ky=$waveformyName
	Wave cf_waveform_kz=$waveformzName
	
	Wave FSM_kxky=$FSMname

	
	if (cubeflag)
	
		String newnote=note(cfe_InterpCube)
		
		Make /O/WAVE/N=(dimsize(cfe_InterpCube,2)) Temp_Interp_wave
		Setscale /P x,dimoffset(cfe_InterpCube,2),dimdelta(cfe_InterpCube,2),Temp_Interp_wave
		
		Temp_Interp_wave=Cal_PolarFSM_from_presize(cfe_InterpCube,cf_waveform_kx,cf_waveform_ky,cf_waveform_kz,kx0,dkx,kx1,ky0,dky,ky1,w_cube_q,x,dE,InnerE,gammaA,initialflag)
				
		Wave FSM_kxky=Temp_Interp_wave[dimsize(cfe_InterpCube,2)-1]		
				
		make /o/n=(dimsize(FSM_kxky,0),dimsize(FSM_kxky,1),dimsize(cfe_InterpCube,2)) $cubekxkyname
		Wave cfe_kxkycube=$cubekxkyname
		Setscale /P x,dimoffset(FSM_kxky,0),dimdelta(FSM_kxky,0),cfe_kxkycube
		Setscale /P y,dimoffset(FSM_kxky,1),dimdelta(FSM_kxky,1),cfe_kxkycube
		Setscale /P z,dimoffset(cfe_InterpCube,2),dimdelta(cfe_InterpCube,2),cfe_kxkycube
		Variable index=0//,eindex
		do
	
			 Wave FSM_temp=Temp_Interp_wave[index]
			 cfe_kxkycube[][][index]=FSM_temp[p][q]
		 	index+=1
		while (index<dimsize(cfe_InterpCube,2))
		note cfe_kxkycube newnote
		killwaves /Z Temp_Interp_wave

	else
		Wave FSM_kxky_temp=Cal_PolarFSM_from_presize(cfe_InterpCube,cf_waveform_kx,cf_waveform_ky,cf_waveform_kz,kx0,dkx,kx1,ky0,dky,ky1,w_cube_q,e_center,dE,InnerE,gammaA,initialflag)
		duplicate /o FSM_kxky_temp $FSMname
		
	endif	
	
	
End
	
///////////////////////////////Polar mapping////////////////////////////////////


Threadsafe Function /Wave Cal_PolarFSM_from_InterpCube(cube,Energy,dE,EF,theta,phi,gammaA,FSM_f,FSM_c)
	Wave cube
	Variable EF,dE,Energy
	Variable theta,phi,gammaA
	Wave FSM_f
	Wave FSM_c
	
	Duplicate /o /FREE FSM_f,FSM_kxky_temp,FSM_f_temp,FSM_c_temp
	
	Variable kvac=sqrt(Energy+EF)* 0.5123
	
	WAVE cf_waveform=make_cf_waveform_thread(cube,Energy,dE/1000)
	
	multithread cf_waveform = (cf_waveform ==0)?(NaN):cf_waveform
	
	Multithread FSM_f_temp = real(Fadley_PolarAngle_of_k(theta,phi,kvac,gammaA,x,y))//Fadley_PolarAngle_of_k(theta_final,phi_final,kvac,gammaA,x,y)
	Multithread FSM_c_temp = imag(Fadley_PolarAngle_of_k(theta,phi,kvac,gammaA,x,y))//Fadley_AzimuthalAngle_of_k(theta_final,phi_final,kvac,gammaA,x,y)
	
	Make /o/FREE/n=10 factor_x,factor_y
	factor_x[0]=0
	factor_x[1]=-180
	factor_x[2]=-360
	factor_x[3]=180
	factor_x[4]=360
	factor_x[5]=0
	factor_x[6]=-180
	factor_x[7]=-360
	factor_x[8]=180
	factor_x[9]=360
	factor_y[0]=1
	factor_y[1]=1
	factor_y[2]=1
	factor_y[3]=1
	factor_y[4]=1
	factor_y[5]=-1
	factor_y[6]=-1
	factor_y[7]=-1
	factor_y[8]=-1
	factor_y[9]=-1

	Variable indexX=0
	Variable indexY=0
	Variable tempkx,tempky
	Variable tempFSM=Nan
	do
		indexY=0
		do
			FSM_kxky_temp[indexX][indexY]=Nan
			Variable index=0
			do
				tempkx=FSM_c_temp[indexX][indexY]+factor_x[index]
				tempky=FSM_f_temp[indexX][indexY]*factor_y[index]
								
				TempFSM=interp2D(cf_waveform,tempkx,tempky)
				if (numtype(TempFSM)!=2)
					FSM_kxky_temp[indexX][indexY]=TempFSM
					break
				endif
				index+=1
			while (index<10)
			indexY+=1
		while (indexY<dimsize(FSM_kxky_temp,1))
		indexX+=1
	while (indexX<dimsize(FSM_kxky_temp,0))
		
	Imagestats/M=1 cf_waveform
	FSM_kxky_temp = (FSM_kxky_temp > v_max)?(NaN):FSM_kxky_temp
	FSM_kxky_temp = (FSM_kxky_temp < v_min)?(NaN):FSM_kxky_temp
	
	WaveClear 	FSM_f_temp,FSM_c_temp,cf_waveform
	
	//print FSM_kxky_temp
	return FSM_kxky_temp	
End



 Function /Wave Cal_PolarFSM_from_presize(interpCube,cf_waveform_kx,cf_waveform_ky,cf_waveform_kz,kx0,dkx,kx1,ky0,dky,ky1,w_cube_q,e_center,dE,InnerE,gammaA,initialflag)
	Wave interpCube
	Wave cf_waveform_kx
	Wave cf_waveform_ky
	Wave cf_waveform_kz
	
	Variable kx0,dkx,kx1,ky0,dky,ky1
	Wave w_cube_q
	Variable e_center,dE,InnerE
	Variable gammaA
	Variable initialflag
	
	Variable w_e0, w_e1, w_de//,w_f0, w_f1, w_df,w_c0,w_c1,w_dc
	
	w_e0=dimoffset(interpCube,2)
	w_e1=dimoffset(interpCube,2)+(dimsize(interpCube,2)-1)*dimdelta(interpCube,2)
	w_de=dimdelta(interpCube,2)
	
	e_center=(e_center<w_e0)?(w_e0):(e_center)
	e_center=(e_center>w_e1)?(w_e1):(e_center)
	
	duplicate /o /FREE cf_waveform_kx,cf_waveform_kx0
	duplicate /o /FREE cf_waveform_ky,cf_waveform_ky0
	duplicate /o /FREE cf_waveform_kz,cf_waveform_kz0

	
	Variable kvac0
	variable mass = 9.1095e-31
      variable hbar = 1.05459e-34
	
	Variable index=0
	do 
		if (initialflag)
		 	kvac0=sqrt(e_center+w_cube_q[index])*0.5123
		 else
		 	kvac0=sqrt(e_center)*0.5123	
		 endif
		
	
		 cf_waveform_kx0[index][]=kvac0*cf_waveform_kx[index][q]
		 cf_waveform_ky0[index][]=kvac0*cf_waveform_ky[index][q]
		 cf_waveform_kz0[index][]=kvac0*cf_waveform_kz[index][q]
		 
		 Multithread  cf_waveform_kz0[index][]=sqrt((2*mass*((( cf_waveform_kz0[index][q]*1e10*hbar)^2/(2*mass))+innerE*1.602e-19))/hbar^2)*1e-10
			
		 index+=1
	while (index<dimsize(interpCube,0))
	
	
	make_cf_waveform(cfe_InterpCube,e_center,dE/1000)
    	WAVE cf_waveform
    	cf_waveform = (numtype(cf_waveform)==2)?(0):cf_waveform
    		
  	
    	Make_tri_wave2D(cf_waveform_kx0,cf_waveform_ky0,cf_waveform)
  
	Wave triwave
	ImageInterpolate/S={kx0,dkx,kx1,ky0,dky,ky1} Voronoi triwave	
	Wave /D M_InterpolatedImage
   	duplicate /FREE/D/o  M_InterpolatedImage FSM_kxky_temp	
	Killwaves/Z triwave,M_InterpolatedImage 
	Imagestats/M=1 cf_waveform
	FSM_kxky_temp = (FSM_kxky_temp > v_max)?(NaN):FSM_kxky_temp	
	FSM_kxky_temp = (FSM_kxky_temp < v_min)?(NaN):FSM_kxky_temp	
	
	KillWaves/Z kx, ky, tempCutkx,tempCutky,tempcutang,M_result
	
	return FSM_kxky_temp	
End


Function Polar_quick_mapper(cubeindex,cubeflag)
	Variable cubeindex
	Variable cubeflag
	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel
	
	NVAR e_center = gv_centerE
	NVAR dE = gv_dE
    	NVAR gammaA=gv_gammaA
	
	String interpcubename="cfe_InterpCube"
	String w_cube_xname="w_cube_x_interp"
	String w_cube_yname="w_cube_y_interp"
	String w_cube_pname="w_cube_p_interp"
	String w_cube_qname="w_cube_q_interp"
	
	String FSMname="FSM_kxky"
	String cubekxkyname="cfe_kxkycube"
	if (cubeindex>0)
		interpcubename+="_"+num2str(cubeindex)
		
		w_cube_xname+="_"+num2str(cubeindex)
		w_cube_yname+="_"+num2str(cubeindex)
		w_cube_pname+="_"+num2str(cubeindex)
		w_cube_qname+="_"+num2str(cubeindex)
		
		FSMname+="_"+num2str(cubeindex)
		cubekxkyname+="_"+num2str(cubeindex)
	endif
		
	auto_k_grid_polar(cubeindex,cubeflag,0)
	
	Wave cfe_InterpCube=$interpcubename
	Wave w_cube_x=$w_cube_xname
	Wave w_cube_y=$w_cube_yname
	Wave w_cube_p=$w_cube_pname
	Wave w_cube_q=$w_cube_qname
	
	if (gammaA==0)
		Variable phi_final=mean(w_cube_y)
		Variable theta_final=mean(w_cube_p)
	else
		phi_final=mean(w_cube_p)
		theta_final=mean(w_cube_y)
	endif
	
	Variable kvac
	NVAR initialflag=gv_initialflag
	if (initialflag)
		Variable ef=mean(w_cube_q)
	else
		ef=0
	endif
		
	Wave FSM_kxky=$FSMname
	Wave FSM_c, FSM_f
	
		
	if (cubeflag)
	
		String newnote=note(cfe_InterpCube)
		
		Make /O/WAVE/N=(dimsize(cfe_InterpCube,2)) Temp_Interp_wave
		Setscale /P x,dimoffset(cfe_InterpCube,2),dimdelta(cfe_InterpCube,2),Temp_Interp_wave
		
		MultiThread Temp_Interp_wave=Cal_PolarFSM_from_InterpCube(cfe_InterpCube,x,dE,EF,theta_final,phi_final,gammaA,FSM_f,FSM_c)
				
		make /o/n=(dimsize(FSM_kxky,0),dimsize(FSM_kxky,1),dimsize(cfe_InterpCube,2)) $cubekxkyname
		Wave cfe_kxkycube=$cubekxkyname
		Setscale /P x,dimoffset(FSM_kxky,0),dimdelta(FSM_kxky,0),cfe_kxkycube
		Setscale /P y,dimoffset(FSM_kxky,1),dimdelta(FSM_kxky,1),cfe_kxkycube
		Setscale /P z,dimoffset(cfe_InterpCube,2),dimdelta(cfe_InterpCube,2),cfe_kxkycube
		Variable index=0//,eindex
		do
	
			 Wave FSM_temp=Temp_Interp_wave[index]
			 cfe_kxkycube[][][index]=FSM_temp[p][q]
		 	index+=1
		while (index<dimsize(cfe_InterpCube,2))
		note cfe_kxkycube newnote
		killwaves /Z Temp_Interp_wave
	
	else
		Wave FSM_kxky_temp=Cal_PolarFSM_from_InterpCube(cfe_InterpCube,e_center,dE,EF,theta_final,phi_final,gammaA,FSM_f,FSM_c)
		
		duplicate /o FSM_kxky_temp $FSMname
	endif
	
	SetDAtafolder DF
	
End




Function Polar_precise_mapper(cubeindex,cubeflag)
	Variable cubeindex
	Variable cubeflag

	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel
	
	NVAR e_center = gv_centerE
	NVAR dE = gv_dE
	NVAR gammaA=gv_gammaA
	NVAR innerE=gv_innerE
	NVAR initialflag=gv_initialflag
	
	String interpcubename="cfe_interpCube"
	String rawcubename="cfe_rawCube"
	String cubekxkyname="cfe_kxkycube"
	String w_cube_xname="w_cube_x_interp"
	String w_cube_yname="w_cube_y_interp"
	String w_cube_pname="w_cube_p_interp"
	String w_cube_qname="w_cube_q_interp"
	String FSMname="FSM_kxky"

	if (cubeindex>0)
		interpcubename+="_"+num2str(cubeindex)
		rawcubename+="_"+num2str(cubeindex)
		cubekxkyname+="_"+num2str(cubeindex)
		w_cube_xname+="_"+num2str(cubeindex)
		w_cube_yname+="_"+num2str(cubeindex)
		w_cube_pname+="_"+num2str(cubeindex)
		w_cube_qname+="_"+num2str(cubeindex)
		FSMname+="_"+num2str(cubeindex)
	endif
	
	Wave cfe_InterpCube=$interpcubename
	Wave w_cube_x=$w_cube_xname
	Wave w_cube_y=$w_cube_yname
	Wave w_cube_p=$w_cube_pname
	Wave w_cube_q=$w_cube_qname
		
	auto_k_grid_polar(cubeindex,cubeflag,1)
	
	Wave cfe_InterpCube=$interpcubename
	
	NVAR kx0 = gv_kxfrom
	NVAR kx1 = gv_kxto
	NVAR ky0 = gv_kyfrom
	NVAR ky1 = gv_kyto
	NVAR dkx=gv_kxdensity
	NVAR dky=gv_kydensity
	
	String waveformxName="cf_waveform_kx"
	String waveformyname="cf_waveform_ky"
	String waveformzname="cf_waveform_kz"
	if (cubeindex>0)
		waveformxName+="_"+num2str(cubeindex)
		waveformyName+="_"+num2str(cubeindex)
		waveformzname+="_"+num2str(cubeindex)
	endif
	
	Wave cf_waveform_kx=$waveformxName
	Wave cf_waveform_ky=$waveformyName
	Wave cf_waveform_kz=$waveformzName
	
	Wave FSM_kxky=$FSMname

	
	if (cubeflag)
	
		String newnote=note(cfe_InterpCube)
		
		Make /O/WAVE/N=(dimsize(cfe_InterpCube,2)) Temp_Interp_wave
		Setscale /P x,dimoffset(cfe_InterpCube,2),dimdelta(cfe_InterpCube,2),Temp_Interp_wave
		
		Temp_Interp_wave=Cal_PolarFSM_from_presize(cfe_InterpCube,cf_waveform_kx,cf_waveform_ky,cf_waveform_kz,kx0,dkx,kx1,ky0,dky,ky1,w_cube_q,x,dE,InnerE,gammaA,initialflag)
				
		Wave FSM_kxky=Temp_Interp_wave[dimsize(cfe_InterpCube,2)-1]		
				
		make /o/n=(dimsize(FSM_kxky,0),dimsize(FSM_kxky,1),dimsize(cfe_InterpCube,2)) $cubekxkyname
		Wave cfe_kxkycube=$cubekxkyname
		Setscale /P x,dimoffset(FSM_kxky,0),dimdelta(FSM_kxky,0),cfe_kxkycube
		Setscale /P y,dimoffset(FSM_kxky,1),dimdelta(FSM_kxky,1),cfe_kxkycube
		Setscale /P z,dimoffset(cfe_InterpCube,2),dimdelta(cfe_InterpCube,2),cfe_kxkycube
		Variable index=0//,eindex
		do
	
			 Wave FSM_temp=Temp_Interp_wave[index]
			 cfe_kxkycube[][][index]=FSM_temp[p][q]
		 	index+=1
		while (index<dimsize(cfe_InterpCube,2))
		note cfe_kxkycube newnote
		killwaves /Z Temp_Interp_wave

	else
		Wave FSM_kxky_temp=Cal_PolarFSM_from_presize(cfe_InterpCube,cf_waveform_kx,cf_waveform_ky,cf_waveform_kz,kx0,dkx,kx1,ky0,dky,ky1,w_cube_q,e_center,dE,InnerE,gammaA,initialflag)
		duplicate /o FSM_kxky_temp $FSMname
		
	endif	
	SetDAtafolder DF

	
End

//////////////////////////kz mapping////////////////////////

//Threadsafe

 Function /Wave Cal_kzFSM_from_InterpCube(cube,Energy,dE,InnerE,theta,phi,azi,gammaA,FSM_f,FSM_c)
	Wave cube
	Variable Energy,dE,InnerE
	Variable theta,phi,azi,gammaA
	Wave FSM_f
	Wave FSM_c
	
	Duplicate /o /FREE FSM_f,FSM_kxky_temp,FSM_f_temp,FSM_c_temp
	
	//Variable kvac=sqrt(Energy+EF)* 0.5123
	
	WAVE cf_waveform=make_cf_waveform_thread(cube,Energy,dE/1000)
	
	multithread cf_waveform = (cf_waveform ==0)?(NaN):cf_waveform
	
	Multithread FSM_c_temp = real(Kxkz_EF_phi_of_k(Energy,x,y,theta,phi,azi,InnerE,gammaA) )//Fadley_PolarAngle_of_k(theta_final,phi_final,kvac,gammaA,x,y)
	Multithread FSM_f_temp = imag(Kxkz_EF_phi_of_k(Energy,x,y,theta,phi,azi,InnerE,gammaA))//Fadley_AzimuthalAngle_of_k(theta_final,phi_final,kvac,gammaA,x,y)

	Multithread FSM_kxky_temp=interp2D(cf_waveform,FSM_c_temp,FSM_f_temp)
		
	Imagestats/M=1 cf_waveform
	FSM_kxky_temp = (FSM_kxky_temp > v_max)?(NaN):FSM_kxky_temp
	FSM_kxky_temp = (FSM_kxky_temp < v_min)?(NaN):FSM_kxky_temp
	
	WaveClear 	FSM_f_temp,FSM_c_temp,cf_waveform
	
	//print FSM_kxky_temp
	return FSM_kxky_temp	
End

 Function /Wave Cal_kzFSM_from_presize(interpCube,cf_waveform_kx,cf_waveform_ky,cf_waveform_kz,kx0,dkx,kx1,ky0,dky,ky1,w_cube_x,e_center,dE,InnerE,gammaA)
	Wave interpCube
	Wave cf_waveform_kx
	Wave cf_waveform_ky
	Wave cf_waveform_kz
	
	Variable kx0,dkx,kx1,ky0,dky,ky1
	Wave w_cube_x
	Variable e_center,dE,InnerE
	Variable gammaA
	
	Variable w_e0, w_e1, w_de//,w_f0, w_f1, w_df,w_c0,w_c1,w_dc
	
	w_e0=dimoffset(interpCube,2)
	w_e1=dimoffset(interpCube,2)+(dimsize(interpCube,2)-1)*dimdelta(interpCube,2)
	w_de=dimdelta(interpCube,2)
	
	e_center=(e_center<w_e0)?(w_e0):(e_center)
	e_center=(e_center>w_e1)?(w_e1):(e_center)
	
	duplicate /o /FREE cf_waveform_kx,cf_waveform_kx0
	duplicate /o /FREE cf_waveform_ky,cf_waveform_ky0
	duplicate /o /FREE cf_waveform_kz,cf_waveform_kz0

	
	Variable kvac0
	variable mass = 9.1095e-31
      variable hbar = 1.05459e-34
	
	Variable index=0
	do 
		
		 kvac0=sqrt(e_center+w_cube_x[index])*0.5123
	
		 cf_waveform_kx0[index][]=kvac0*cf_waveform_kx[index][q]
		 cf_waveform_ky0[index][]=kvac0*cf_waveform_ky[index][q]
		 cf_waveform_kz0[index][]=kvac0*cf_waveform_kz[index][q]
		 
		 Multithread  cf_waveform_kz0[index][]=sqrt((2*mass*((( cf_waveform_kz0[index][q]*1e10*hbar)^2/(2*mass))+innerE*1.602e-19))/hbar^2)*1e-10
			
		 index+=1
	while (index<dimsize(interpCube,0))
	
	
	make_cf_waveform(cfe_InterpCube,e_center,dE/1000)
    	WAVE cf_waveform
    	cf_waveform = (numtype(cf_waveform)==2)?(0):cf_waveform
    		
  	//	Wave cf_waveform_kz=$waveformzName
    	if (gammaA==0)
    		//Wave cf_waveform_ky=$waveformyName
    		Make_tri_wave2D(cf_waveform_ky0,cf_waveform_kz0,cf_waveform)
    	else
   		//	Wave cf_waveform_kx=$waveformxName
   		Make_tri_wave2D(cf_waveform_kx0,cf_waveform_kz0,cf_waveform)
   	endif

	Wave triwave
	ImageInterpolate/S={kx0,dkx,kx1,ky0,dky,ky1} Voronoi triwave	
	Wave /D M_InterpolatedImage
   	duplicate /FREE/D/o  M_InterpolatedImage FSM_kxky_temp	
	Killwaves/Z triwave,M_InterpolatedImage 
	Imagestats/M=1 cf_waveform
	FSM_kxky_temp = (FSM_kxky_temp > v_max)?(NaN):FSM_kxky_temp	
	FSM_kxky_temp = (FSM_kxky_temp < v_min)?(NaN):FSM_kxky_temp	
	
	KillWaves/Z kx, ky, tempCutkx,tempCutky,tempcutang,M_result
	
	return FSM_kxky_temp	
End


	
	
	
	
	


Function kz_quick_mapper(cubeindex,cubeflag)
	Variable cubeindex
	Variable cubeflag
	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel
	
	NVAR e_center = gv_centerE
	NVAR dE = gv_dE
    	NVAR gammaA=gv_gammaA
    	NVAR InnerE=gv_InnerE
    	
    	
    	String interpcubename="cfe_InterpCube"
	String w_cube_xname="w_cube_x_interp"
	String w_cube_yname="w_cube_y_interp"
	String w_cube_pname="w_cube_p_interp"
	String w_cube_qname="w_cube_q_interp"
	
	String FSMname="FSM_kxky"
	String cubekxkyname="cfe_kxkycube"
	if (cubeindex>0)
		interpcubename+="_"+num2str(cubeindex)
		
		w_cube_xname+="_"+num2str(cubeindex)
		w_cube_yname+="_"+num2str(cubeindex)
		w_cube_pname+="_"+num2str(cubeindex)
		w_cube_qname+="_"+num2str(cubeindex)
		
		FSMname+="_"+num2str(cubeindex)
		cubekxkyname+="_"+num2str(cubeindex)
	endif
		
	auto_k_grid_kz(cubeindex,cubeflag,0)
	
	Wave cfe_InterpCube=$interpcubename
	Wave w_cube_x=$w_cube_xname
	Wave w_cube_y=$w_cube_yname
	Wave w_cube_p=$w_cube_pname
	Wave w_cube_q=$w_cube_qname
    	
    	if (gammaA==0)
    		Variable phi_final=mean(w_cube_y)
    		Variable theta_final=mean(w_cube_p)
    		variable azi_final=mean(w_cube_q)
    	else
    		phi_final=mean(w_cube_p)
    		theta_final=mean(w_cube_y)
    		azi_final=mean(w_cube_q)
	endif
	
	Wave FSM_kxky=$FSMname
	Wave FSM_c, FSM_f

		
	if (cubeflag)
	
		String newnote=note(cfe_InterpCube)
		
		Make /O/WAVE/N=(dimsize(cfe_InterpCube,2)) Temp_Interp_wave
		Setscale /P x,dimoffset(cfe_InterpCube,2),dimdelta(cfe_InterpCube,2),Temp_Interp_wave
		
		Temp_Interp_wave=Cal_kzFSM_from_InterpCube(cfe_InterpCube,x,dE,InnerE,theta_final,phi_final,azi_final,gammaA,FSM_f,FSM_c)
				
		make /o/n=(dimsize(FSM_kxky,0),dimsize(FSM_kxky,1),dimsize(cfe_InterpCube,2)) $cubekxkyname
		Wave cfe_kxkycube=$cubekxkyname
		Setscale /P x,dimoffset(FSM_kxky,0),dimdelta(FSM_kxky,0),cfe_kxkycube
		Setscale /P y,dimoffset(FSM_kxky,1),dimdelta(FSM_kxky,1),cfe_kxkycube
		Setscale /P z,dimoffset(cfe_InterpCube,2),dimdelta(cfe_InterpCube,2),cfe_kxkycube
		Variable index=0//,eindex
		do
	
			 Wave FSM_temp=Temp_Interp_wave[index]
			 cfe_kxkycube[][][index]=FSM_temp[p][q]
		 	index+=1
		while (index<dimsize(cfe_InterpCube,2))
		note cfe_kxkycube newnote
		killwaves /Z Temp_Interp_wave
	
	else
		
		
		Wave FSM_kxky_temp=Cal_kzFSM_from_InterpCube(cfe_InterpCube,e_center,dE,InnerE,theta_final,phi_final,azi_final,gammaA,FSM_f,FSM_c)
		
		duplicate /o FSM_kxky_temp $FSMname
	endif
	
	SetDAtafolder DF
	
	
End

Function kz_precise_mapper(cubeindex,cubeflag)
	Variable cubeindex
	Variable cubeflag
		
	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel
	
	NVAR e_center = gv_centerE
	NVAR dE = gv_dE
	NVAR gammaA=gv_gammaA
	NVAR InnerE=gv_InnerE
	NVAR gv_curveflag=gv_curveflag
	
	String interpcubename="cfe_interpCube"
	String rawcubename="cfe_rawCube"
	String cubekxkyname="cfe_kxkycube"
	String w_cube_xname="w_cube_x_interp"
	String w_cube_yname="w_cube_y_interp"
	String w_cube_pname="w_cube_p_interp"
	String w_cube_qname="w_cube_q_interp"
	String FSMname="FSM_kxky"

	if (cubeindex>0)
		interpcubename+="_"+num2str(cubeindex)
		rawcubename+="_"+num2str(cubeindex)
		cubekxkyname+="_"+num2str(cubeindex)
		w_cube_xname+="_"+num2str(cubeindex)
		w_cube_yname+="_"+num2str(cubeindex)
		w_cube_pname+="_"+num2str(cubeindex)
		w_cube_qname+="_"+num2str(cubeindex)
		FSMname+="_"+num2str(cubeindex)
	endif
	
	Wave cfe_InterpCube=$interpcubename
	Wave w_cube_x=$w_cube_xname
	Wave w_cube_y=$w_cube_yname
	Wave w_cube_p=$w_cube_pname
	Wave w_cube_q=$w_cube_qname
	
		
	auto_k_grid_kz(cubeindex,cubeflag,1)
	
	NVAR kx0 = gv_kxfrom
	NVAR kx1 = gv_kxto
	NVAR ky0 = gv_kyfrom
	NVAR ky1 = gv_kyto
	NVAR dkx=gv_kxdensity
	NVAR dky=gv_kydensity
	
	String waveformxName="cf_waveform_kx"
	String waveformyname="cf_waveform_ky"
	String waveformzname="cf_waveform_kz"
	if (cubeindex>0)
		waveformxName+="_"+num2str(cubeindex)
		waveformyName+="_"+num2str(cubeindex)
		waveformzname+="_"+num2str(cubeindex)
	endif
	
	Wave cf_waveform_kx=$waveformxName
	Wave cf_waveform_ky=$waveformyName
	Wave cf_waveform_kz=$waveformzName
	
	Wave FSM_kxky=$FSMname

	
	if (cubeflag)
	
		String newnote=note(cfe_InterpCube)
		
		Make /O/WAVE/N=(dimsize(cfe_InterpCube,2)) Temp_Interp_wave
		Setscale /P x,dimoffset(cfe_InterpCube,2),dimdelta(cfe_InterpCube,2),Temp_Interp_wave
		
		Temp_Interp_wave=Cal_kzFSM_from_presize(cfe_InterpCube,cf_waveform_kx,cf_waveform_ky,cf_waveform_kz,kx0,dkx,kx1,ky0,dky,ky1,w_cube_x,x,dE,InnerE,gammaA)
				
		Wave FSM_kxky=Temp_Interp_wave[dimsize(cfe_InterpCube,2)-1]		
				
		make /o/n=(dimsize(FSM_kxky,0),dimsize(FSM_kxky,1),dimsize(cfe_InterpCube,2)) $cubekxkyname
		Wave cfe_kxkycube=$cubekxkyname
		Setscale /P x,dimoffset(FSM_kxky,0),dimdelta(FSM_kxky,0),cfe_kxkycube
		Setscale /P y,dimoffset(FSM_kxky,1),dimdelta(FSM_kxky,1),cfe_kxkycube
		Setscale /P z,dimoffset(cfe_InterpCube,2),dimdelta(cfe_InterpCube,2),cfe_kxkycube
		Variable index=0//,eindex
		do
	
			 Wave FSM_temp=Temp_Interp_wave[index]
			 cfe_kxkycube[][][index]=FSM_temp[p][q]
		 	index+=1
		while (index<dimsize(cfe_InterpCube,2))
		note cfe_kxkycube newnote
		killwaves /Z Temp_Interp_wave

	else
		Wave FSM_kxky_temp=Cal_kzFSM_from_presize(cfe_InterpCube,cf_waveform_kx,cf_waveform_ky,cf_waveform_kz,kx0,dkx,kx1,ky0,dky,ky1,w_cube_x,e_center,dE,InnerE,gammaA)
		duplicate /o FSM_kxky_temp $FSMname
		
	endif	
	SetDAtafolder DF
	
End

/////////////////////////////////////////Deflector Mapping DA30/////////////////////////////////


Function DY_mapper(cubeindex,cubeflag)
	Variable cubeindex
	Variable cubeflag

	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel
	
	NVAR e_center = gv_centerE
	NVAR dE = gv_dE
	NVAR gammaA=gv_gammaA
	
	
	String interpcubename="cfe_InterpCube"
	String w_cube_xname="w_cube_x_interp"
	String w_cube_yname="w_cube_y_interp"
	String w_cube_pname="w_cube_p_interp"
	String w_cube_qname="w_cube_q_interp"
	String w_cube_rname="w_cube_r_interp"
	
	String FSMname="FSM_kxky"
	String FSM_Fname="FSM_f"
	STring FSM_Cname="FSM_c"
	String cubekxkyname="cfe_kxkycube"
	if (cubeindex>0)
		interpcubename+="_"+num2str(cubeindex)
		
		w_cube_xname+="_"+num2str(cubeindex)
		w_cube_yname+="_"+num2str(cubeindex)
		w_cube_pname+="_"+num2str(cubeindex)
		w_cube_qname+="_"+num2str(cubeindex)
		w_cube_rname+="_"+num2str(cubeindex)
		
		FSMname+="_"+num2str(cubeindex)
		FSM_Fname+="_"+num2str(cubeindex)
		FSM_Cname+="_"+num2str(cubeindex)
		cubekxkyname+="_"+num2str(cubeindex)
	endif
		
		
		
	 auto_k_grid_DA30(cubeindex,cubeflag,0)
	 
	
	Wave cfe_InterpCube=$interpcubename
	Wave w_cube_x=$w_cube_xname
	Wave w_cube_y=$w_cube_yname
	Wave w_cube_p=$w_cube_pname
	Wave w_cube_q=$w_cube_qname
	Wave w_cube_r=$w_cube_rname
	
	Wave FSM_f=$FSM_Fname
	Wave FSM_c=$FSM_Cname
	Wave FSM_kxky=$FSMname
	
	Variable kvac
	NVAR initialflag=gv_initialflag
	NVAR curveflag=gv_curveflag
	if (initialflag)
		Variable EF=mean(w_cube_q)
	else
		EF=0
	endif
	
	Variable phi=mean(w_cube_y)
	Variable loc_alpha=mean(w_cube_p)
	Variable theta=mean(w_cube_r)
	//checkreturnwaveequal(w_cube_y,Nan,Nan)
	
	if (cubeflag)
		String newnote=note(cfe_InterpCube)
		
		Make /O/WAVE/N=(dimsize(cfe_InterpCube,2)) Temp_Interp_wave
		Setscale /P x,dimoffset(cfe_InterpCube,2),dimdelta(cfe_InterpCube,2),Temp_Interp_wave
		
		MultiThread Temp_Interp_wave=Cal_FSM_from_InterpCube_DA30(cfe_InterpCube,x,dE,EF,loc_alpha,phi,theta,gammaA,FSM_f,FSM_c,curveflag)
		make /o/n=(dimsize(FSM_kxky,0),dimsize(FSM_kxky,1),dimsize(cfe_InterpCube,2)) $cubekxkyname
		Wave cfe_kxkycube=$cubekxkyname
		Setscale /P x,dimoffset(FSM_kxky,0),dimdelta(FSM_kxky,0),cfe_kxkycube
		Setscale /P y,dimoffset(FSM_kxky,1),dimdelta(FSM_kxky,1),cfe_kxkycube
		Setscale /P z,dimoffset(cfe_InterpCube,2),dimdelta(cfe_InterpCube,2),cfe_kxkycube
		Variable index=0//,eindex
		do
	
			 Wave FSM_temp=Temp_Interp_wave[index]
			 cfe_kxkycube[][][index]=FSM_temp[p][q]
		 	index+=1
		while (index<dimsize(cfe_InterpCube,2))
		note cfe_kxkycube newnote
		killwaves /Z Temp_Interp_wave
	else	
		
		Wave FSM_kxky_temp= Cal_FSM_from_InterpCube_DA30(cfe_InterpCube,e_center,dE,EF,loc_alpha,phi,theta,gammaA,FSM_f,FSM_c,curveflag)
		
		Duplicate /o FSM_kxky_temp $FSMname
		
		//Killwaves /Z FSM_c,FSM_f
	endif
	
	SetDAtafolder DF
	
End

/////////////////////////////////Multithread calculate function////////////////
Threadsafe  Function /Wave Cal_FSM_from_InterpCube_DA30(cube,Energy,dE,EF,loc_alpha,phi,theta,gammaA,FSM_f,FSM_c,curveflag)
	Wave cube
	Variable EF,dE,Energy
	Variable loc_alpha,phi,theta,gammaA
	Wave FSM_f
	Wave FSM_c
	Variable curveflag
	
	Duplicate /o /FREE FSM_f,FSM_kxky_temp,FSM_f_temp,FSM_c_temp
	
	Variable kvac=sqrt(Energy+EF)* 0.5123
	
	multithread FSM_f_temp =  flip_beta_of_k_DA30(loc_alpha,phi,theta,kvac,gammaA,x,y) //flip_coarseAngle_of_k(-loc_alpha,kvac,x,y)
	multithread FSM_c_temp = flip_DeflectorY_of_k_DA30(loc_alpha,phi,theta,kvac,gammaA,x,y) // flip_fineAngle_of_k(-loc_alpha,kvac,x,y)
	
	
	
	WAVE cf_waveform=make_cf_waveform_thread(cube,Energy,dE/1000)
	
	multithread cf_waveform = (cf_waveform ==0)?(NaN):cf_waveform
	
	if (gammaA == 0)
		//FSM_c_temp=FSM_c_temp[p][q]+curve_slit_correction_quick(FSM_f_temp[p][q],gammaA)
		Multithread FSM_kxky_temp = interp2D(cf_waveform,FSM_c_temp,FSM_f_temp)
	else
		//FSM_f_temp=FSM_f_temp[p][q]+curve_slit_correction_quick(FSM_c_temp[p][q],gammaA)
		Multithread FSM_kxky_temp = interp2D(cf_waveform,FSM_f_temp,FSM_c_temp)
	endif	
	
	Imagestats/M=1 cf_waveform
	multithread FSM_kxky_temp = (FSM_kxky_temp > v_max)?(NaN):FSM_kxky_temp
	multithread FSM_kxky_temp = (FSM_kxky_temp < v_min)?(NaN):FSM_kxky_temp
	
	WaveClear 	FSM_f_temp,FSM_c_temp,cf_waveform
	
	return FSM_kxky_temp	
End







///////////////////////////////////////////Deflector Mapping DA30 End///////////////////////////








Function Cal_Mapping(cubeindex,gammaA,E_center,dE,flag3D,Energyrangeflag,mappingmethodflag,dimflag)
	Variable cubeindex
	Variable gammaA
	Variable E_center,dE
	Variable flag3D
	Variable Energyrangeflag
	Variable mappingmethodflag,dimflag

	String FSMname="FSM_kxky"
	String inpercubename="cfe_InterpCube"
	String rawcubename="cfe_rawCube"
	String kxkycubename="cfe_kxkyCube"
	if (cubeindex>0)
		FSMName+="_"+num2str(cubeindex)
		inpercubename+="_"+num2str(cubeindex)
		kxkycubename+="_"+num2str(cubeindex)
		rawcubename+="_"+num2str(cubeindex)
	endif
	
	if (mappingmethodflag==1)//no momentum conversion just angle
		Wave cfe_InterpCube=$inpercubename
		if (flag3D)
			Duplicate /o cfe_interpCube $kxkycubename
			Wave cfe_kxkycube=$kxkycubename
			if (dimflag==1)
				if ((gammaA)==90)
    					ImageRotate  /Q/W/O/S cfe_kxkycube
    				endif
    			endif
		else
			make_cf_waveform(cfe_InterpCube,e_center,dE/1000)
    			WAVE cf_waveform
    			if (dimflag==1)
    				if ((gammaA)==90)
    					ImageRotate  /Q/W/O/S cf_waveform
    				endif
    			endif
    			Duplicate /o cf_waveform,$FSMName
			Killwaves /Z cf_Waveform
			return 1
		endif
	endif
	
	Switch (dimflag)
		case 1: //kxky
			if (mappingmethodflag==2)
				kxky_quick_mapper(cubeindex,flag3D)
			else
				kxky_precise_mapper(cubeindex,flag3D)
			endif
		break
		
		case 2: //polar mapping
   			if (mappingmethodflag==2)
   				Polar_quick_mapper(cubeindex,flag3D)
			else
				Polar_precise_mapper(cubeindex,flag3D)
   			endif
   		break
   		
   		case 3://kz mapping
   			 if (mappingmethodflag==2)
   				kz_quick_mapper(cubeindex,flag3D)
			else
   				kz_precise_mapper(cubeindex,flag3D)
   			endif
		break
		
		case 4: //Deflector angle mapping
			if (mappingmethodflag==2)
   				DY_mapper(cubeindex,flag3D)
			else
   				Print "Mapping function not defined.\r"
   			endif
		break
	endswitch

End

Function SetAscale(cubeindex,gv_Ascale)
	Variable cubeindex,gv_Ascale
	
	String interpcubename="cfe_InterpCube"
	String RAWcubename="cfe_rawCube"
	if (cubeindex>0)
		interpcubename+="_"+num2str(cubeindex)
		RAWcubename+="_"+num2str(cubeindex)
	endif
	Wave cfe_InterpCube=$interpcubename
	Wave cfe_rawcube=$rawcubename
	
	Variable f0=M_y0(cfe_InterpCube)*gv_Ascale
	Variable f1=M_y1(cfe_InterpCube)*gv_Ascale
	
	Setscale /I y, f0,f1,cfe_InterpCube
End

Function master_mapper(ctrlName)
	String ctrlName

	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	
	String wname=winname(0,65)
	
	WAVE/T w_sourcePathes = DFR_panel:w_sourcePathes
	WAVE/T w_sourceNames = DFR_panel:w_sourceNames
	Wave/B w_sourceNamessel=DFR_panel:w_sourceNamessel

	NVAR toplayernum=DFR_common:gv_toplayernum
	NVAR topprocnum=DFR_common:gv_topprocnum
	NVAR autolayerflag=DFR_common:gv_autolayerflag
	
	Wave w_image=DFR_common:w_image
	
	SetDatafolder $DF_panel
	
	if (autolayerflag==1)
		if (Check_Autosimilar_layer_list(w_sourcePathes,w_sourceNamessel,toplayernum,topprocnum,0)==-1)
			doalert 0,"Not similar layer, change auto."
   			autolayerflag=0
   		endif
	endif
	
	Variable /G gv_cubenum=Initial_angle_wave(1)
	
	NVAR cubenum=DFR_panel:gv_Cubenum
		
	if (cubenum==0)
	  	SetDatafolder DF
	  	return 0
	endif
	
	NVAR dimflag=gv_dimflag
	nVAR gv_slicedensity
	NVAR e_center = gv_centerE
	NVAR dE = gv_dE
	NVAR gammaA=gv_gammaA
	NVAR mappingmethodflag=gv_mappingmethodflag
	NVAR rawmethodflag=gv_rawmappingmethodflag
	NVAR alwaysinterpflag=gv_alwaysinterpflag
	NVAR interptolerate=gv_interptolerate
	nVAR gv_angdensity
	NVAR gv_Ascale
	Variable Energyrangeflag=0
	Variable flag3D=0
	
	if (stringmatch(ctrlname,"Mapper_3D"))
		flag3D=1
	endif
	
	SVAR newnotestring=gs_notestring
	newnotestring=""
	
	
//		NameA="theta"
//	NameB="phi"
//	NameC="azi"
//	NameD="EF"
//	NameE="DY"
//	
//	
	
	Variable rawcubedone,interpcubedone
	
	if (cubenum==1)
		if(dimflag==4)
		//deflector mapping
			wave w_cube_theta,w_cube_phi, w_cube_azi, w_cube_EF, w_cube_DY
			Wave /T w_intPathes
			rawcubedone= make_cfe_rawCube_single(0,w_intPathes,w_cube_DY,w_cube_phi,gv_slicedensity,dimflag)
			if (rawcubedone==0)
		   		SetDatafolder DF
		    		Abort "Initial RawCube failed."
		    		return 0
			endif
			interpcubedone=make_cfe_InterpCube_single_DA30(rawcubedone,0,w_cube_DY,w_Cube_phi,w_cube_azi,w_cube_EF,w_cube_theta,e_center,dE,Energyrangeflag,mappingmethodflag,rawmethodflag,alwaysinterpflag,interptolerate,gv_angdensity,dimflag)
			if (interpcubedone==0)
				SetDatafolder DF
		    		Abort "Initial InterpCube failed."
		    		return 0
			endif
			//print "abc",rawcubedone,interpcubedone
			
	
			Cal_Mapping(0,gammaA,E_center,dE,flag3D,Energyrangeflag,mappingmethodflag,dimflag)
		
		else	
			Wave w_cube_x,w_cube_y,w_cube_p,w_cube_q
			Wave /T w_intPathes
		  	rawcubedone=make_cfe_rawCube_single(0,w_intPathes,w_cube_x,w_cube_y,gv_slicedensity,dimflag)
		  	if (rawcubedone==0)
		   		SetDatafolder DF
		    		Abort "Initial RawCube failed."
		    		return 0
			endif
			interpcubedone=make_cfe_InterpCube_single(rawcubedone,0,w_cube_x,w_Cube_y,w_cube_p,w_cube_q,e_center,dE,Energyrangeflag,mappingmethodflag,rawmethodflag,alwaysinterpflag,interptolerate,gv_angdensity,dimflag)
			if (interpcubedone==0)
				SetDatafolder DF
		    		Abort "Initial InterpCube failed."
		    		return 0
			endif
			//print "abc",rawcubedone,interpcubedone
			
	
			Cal_Mapping(0,gammaA,E_center,dE,flag3D,Energyrangeflag,mappingmethodflag,dimflag)	
		endif
	else
		Variable cubeindex=1
		do
			Wave w_cube_x=$("w_cube_x"+"_"+num2str(cubeindex))
			Wave w_cube_y=$("w_cube_y"+"_"+num2str(cubeindex))
			Wave w_cube_p=$("w_cube_p"+"_"+num2str(cubeindex))
			Wave w_cube_q=$("w_cube_q"+"_"+num2str(cubeindex))
			wave/T w_intPathes=$("w_intPathes"+"_"+num2str(cubeindex))
			
			rawcubedone=make_cfe_rawCube_single(cubeindex,w_intPathes,w_cube_x,w_cube_y,gv_slicedensity,dimflag)
	  		if (rawcubedone==0)
	   			SetDatafolder DF
	    			Abort "Initial RawCube failed."
	    			return 0
			endif
			
			Wave w_cube_x=$("w_cube_x"+"_"+num2str(cubeindex))
			Wave w_cube_y=$("w_cube_y"+"_"+num2str(cubeindex))
			Wave w_cube_p=$("w_cube_p"+"_"+num2str(cubeindex))
			Wave w_cube_q=$("w_cube_q"+"_"+num2str(cubeindex))
		
			interpcubedone=make_cfe_InterpCube_single(rawcubedone,cubeindex,w_cube_x,w_Cube_y,w_cube_p,w_cube_q,e_center,dE,Energyrangeflag,mappingmethodflag,rawmethodflag,alwaysinterpflag,interptolerate,gv_angdensity,dimflag)
			if (interpcubedone==0)
				SetDatafolder DF
	    			Abort "Initial InterpCube failed."
	    			return 0
			endif
			
			SetAscale(cubeindex,gv_Ascale)
			
			Cal_Mapping(cubeindex,gammaA,E_center,dE,flag3D,Energyrangeflag,mappingmethodflag,dimflag)
			
			cubeindex+=1
		while(cubeindex<(cubenum+1))
		
		/////Merge FSMs
		if (flag3D==0)
			Wave FSM_kxky_index=$("FSM_kxky_"+num2str(1))
			Duplicate /o FSM_kxky_index, FSM_kxky
		
			NVAR auto_linear=gv_lin_comb
			NVAR auto_z=gv_auto_z
		
			if (gammaA==90)
				Variable ydirectionflag=0
			else
				 ydirectionflag=1
			endif
		
			cubeindex=2
			do
				Wave FSM_kxky_index=$("FSM_kxky_"+num2str(cubeindex))
			
				Merge_waves(FSM_kxky,FSM_kxky_index,1,1,auto_linear,auto_z,ydirectionflag)
				Wave Merge_results_temp
				duplicate /o Merge_results_temp FSM_kxky
				
				cubeindex+=1
			while(cubeindex<(cubenum+1))
			Killwaves /Z Merge_results_temp
		else
			Wave cubekxky_index=$("cfe_kxkycube_"+num2str(1))
			Duplicate /o cubekxky_index,cfe_kxkycube
			
			NVAR auto_linear=gv_lin_comb
			NVAR auto_z=gv_auto_z
		
			controlinfo options_c2
			if (v_value)
				 ydirectionflag=1
			else
				 ydirectionflag=0
			endif
		
			cubeindex=2
			do
				Wave cubekxky_index=$("cfe_kxkycube_"+num2str(cubeindex))
			
				Merge_cube(cfe_kxkycube,cubekxky_index,1,1,auto_linear,auto_z,ydirectionflag)
				Wave Merge_cube_temp
				duplicate /o Merge_cube_temp cfe_kxkycube
				
				cubeindex+=1
			while(cubeindex<(cubenum+1))
			Killwaves /Z Merge_cube_temp
		endif
		
	endif	
		
	
	if (flag3D==0)
		note FSM_kxky  newnotestring
		duplicate /o FSM_kxky ,w_image	
		Panelimageupdate(-1)
		Adjustdisplayratio(2)
		update_global_offset(1)
		
		Wave w_image=DFR_common:w_image
	
		NVAR gv_proc_pnts=DFR_panel:gv_proc_pnts
		NVAR gv_proc_times=DFR_panel:gv_proc_times
	
		NVAR gv_proc_cfactor=DFR_panel:gv_proc_cfactor
		NVAR gv_proc_flag=DFR_panel:gv_proc_flag
		
		if (gv_proc_Flag>0)
			Proc_Map_process(w_image,gv_proc_times,gv_proc_pnts,gv_proc_cfactor,gv_proc_flag)
		endif
		
			
		NVAR gv_autoFSMflag=DFR_panel:gv_autoFSMflag
		SVAR gs_autoFSM_panellist=DFR_panel:gs_autoFSM_panellist
		
		//NVAR gv_autoFSMflag=DFR_global:gv_autoFSMflag
		//SVAR gs_autoFSMpath=DFR_global:gs_autoFSMpath
   		if  (gv_autoFSMflag>0)
   			Variable panelindex=0
   			Variable panelnum=itemsinlist(gs_autoFSM_panellist,";")
   			Variable index=0
   			do
   				String BZname=stringfromlist(index,gs_autoFSM_panellist,";")
   				String DF_BZ="root:internaluse:"+BZname
   				if (Datafolderexists(DF_BZ)==0)
   					gs_autoFSM_panellist=RemoveFromList(BZname, gs_autoFSM_panellist, ";")
   				else
   					DFREF DFR_BZ=$DF_BZ
   					
   					SetDatafolder DFR_BZ
   					
   					SVAR gs_autoFSMname=DFR_BZ:gs_autoFSMname
   					Variable temppos=WhichListItem(wname,gs_autoFSMname,";",0)
   					
   					String autoFSM_BZname="autoFSM_"+num2str(temppos)
	
					duplicate /o w_image $autoFSM_BZname
   					
   					Checkdisplayed /W=$BZname $autoFSM_BZname
	
					if (V_flag==0)
						appendimage  /W=$BZname  $autoFSM_BZname
					endif	
   		
   					panelindex+=1
   				endif
   				
   				index+=1
   			while (index<panelnum)
   			
   			if (panelindex==0)
   				gv_autoFSMflag=0
   			endif
    		
   		endif
	endif	
		
	Setdatafolder DF
	return 1
	

End



/////////////////control function///////

Function update_global_to_note(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel

		
	WAVE/T w_sourcePathes = DFR_panel:w_sourcePathes
	WAVE/T w_sourceNames = DFR_panel:w_sourceNames
	Wave/B w_sourceNamessel=DFR_panel:w_sourceNamessel
	
	
	String notestr
		
	if (stringmatch(ctrlname,"settings_sv2"))
		updata_mapping_par(1)
	else
		if (numpnts(w_sourcePathes)>0)
			controlinfo settings_ck10
			if (v_value==0)
				doalert 1,"Write global Variable to Wave notes?"
			endif
			if ((v_flag)||(v_value))
				SetDatafolder $DF_panel
				NVAR innerE = gv_innerE
				NVAR gammaA=gv_gammaA
				NVAR th_off=gv_th_off
				NVAR phi_off=gv_ph_off
				NVAR alpha_off=gv_alpha_off
				NVAR workfn=gv_workfunction
				
				Variable index=0
				Variable Automappingflag=0
				do
					Wave data=$w_sourcePathes[index]
					notestr=note(data)
					strswitch(ctrlname)
						case "settings_sv4"://workfn
							notestr=replacenumberbykey("WorkFunction",notestr,workfn,"=","\r")
							break
						case "settings_sv5": //innerE
							notestr=replacenumberbykey("InnerPotential",notestr,innerE,"=","\r")
							break
						case "settings_sv10": //Toff
							th_off=round(th_off*1000)/1000
							notestr=replacenumberbykey("OffsetThetaManipulator",notestr,th_off,"=","\r")
							Automappingflag=1
							break
						case "settings_sv11": //Foff
							phi_off=round(phi_off*1000)/1000
							notestr=replacenumberbykey("OffsetPhiManipulator",notestr,phi_off,"=","\r")
							Automappingflag=1
							break
						case "settings_sv12": //Azioff
							alpha_off=round(alpha_off*1000)/1000
							notestr=replacenumberbykey("OffsetAzimuthManipulator",notestr,alpha_off,"=","\r")
							Automappingflag=1
							break
						case "settings_sv13": //gammaA
							notestr=replacenumberbykey("ScientaOrientation",notestr,gammaA,"=","\r")
							break
				
						endswitch
					note /K data
					note data,notestr
					index+=1 
					Datapanel#Write_to_log_Datafolder(data)
				while (index<numpnts(w_sourcePathes))
				SetDAtafolder DF
				updata_mapping_par(0)
				
				if (automappingflag)
					Master_mapper("dummy")
				endif
			else
			return 1
			endif
		else
		return 1
		endif 
	endif
	SetDAtafolder DF
End





Function update_FSM_cross()
	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	SetActiveSubwindow $winname(0,65)
	
	SetDatafolder DFR_panel
	
	Wave w_image=DFR_common:w_image
	NVAR gv_FSMcrossflag=DFR_panel:gv_FSMcrossflag
	
	variable x0=M_x0(w_image)
	variable x1=M_x1(w_image)
	variable y0=M_y0(w_image)
	variable y1=M_y1(w_image)
	
	variable xcrossflag,ycrossflag
	
	if (sign(x0)!=sign(x1))
		//make /o/n=2 FSM_kxky_Vcross,FSM_kxky_Vcross_x
		//FSM_kxky_Vcross=0
		//FSM_kxky_Vcross_x[0]=x0
		//FSM_kxky_Vcross_x[1]=x1
		xcrossflag=1
	endif
	
	if (sign(y0)!=sign(y1))
		//make /o/n=2 FSM_kxky_Hcross,FSM_kxky_Hcross_x
		//FSM_kxky_Hcross_x=0
		///FSM_kxky_Hcross[0]=y0
		//FSM_kxky_Hcross[1]=y1
		ycrossflag=1
	endif
	
	if ((xcrossflag)&&(gv_FSMcrossflag))
		//checkdisplayed /W=$winName(0,65) FSM_kxky_Vcross
		//if (V_flag==0)
		///	appendtograph /W=$winName(0,65) /L=image_en /B=image_m FSM_kxky_Vcross
		//endif
		ModifyGraph zero(bottom)=4
	else
		ModifyGraph zero(bottom)=0
		//removefromgraph /Z FSM_kxky_Vcross
	endif
	
	if ((xcrossflag)&&(gv_FSMcrossflag))
		//checkdisplayed /W=$winName(0,65) FSM_kxky_Vcross
		//if (V_flag==0)
		//	appendtograph /W=$winName(0,65) /L=image_en /B=image_m FSM_kxky_Vcross
		//endif
		//ModifyGraph zero(bottom)=4
		ModifyGraph zero(edc_en)=4
	else
		//removefromgraph /Z FSM_kxky_Vcross
		ModifyGraph zero(edc_en)=0
	endif
	
	SetDatafolder DF
End

Function update_global_offset(flag) //0 for angle //1 plus innerE 
	Variable flag
	
    	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel
	
	DFREF dF_load=$DF_global
	
	NVAR th_off=DFR_panel:gv_th_off
	NVAR ph_off=DFR_panel:gv_ph_off
	NVAR azi_off=DFR_panel:gv_alpha_off
	NVAR mapInnerE=DFR_panel:gv_InnerE
	NVAR mapGammaA=DFR_panel:gv_gammaA
	
	NVAR mapworkfn=DFR_panel:gv_workfunction
	NVAR mapphotonE=DFR_panel:gv_hn
	
	NVAR samth_off=DF_load:gv_samthetaoff
	NVAR samph_off=DF_load:gv_samphioff
	NVAR samazi_off=DF_load:gv_samazioff
	NVAR InnerE=DF_load:gv_InnerE
	NVAR gammaA=DF_load:gv_gammaA
	NVAR photonE=DF_load:gv_photonE
	NVAR workfn=DF_load:gv_workfn
	
	
	
	samth_off=(numtype(th_off)==2)?(samth_off):(th_off)
	samph_off=(numtype(ph_off)==2)?(samph_off):(ph_off)
	samazi_off=(numtype(azi_off)==2)?(samazi_off):(azi_off)
	gammaA=(numtype(mapgammaA)==2)?(gammaA):(mapGammaA)
	
    	if (Flag==1)
     		InnerE=(numtype(mapInnerE)==2)?(InnerE):(mapInnerE)
     		photonE=(numtype(mapphotonE)==2)?(photonE):(mapphotonE)
     		workfn=(numtype(mapworkfn)==2)?(workfn):(mapworkfn)
    	endif
End





Function updata_mapping_List(flag)
    Variable flag
	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	
	Wave/T FSMList=DFR_panel:FSMs_Array
	Wave/T FSMPathList=DFR_panel:FSMsPath_Array
	
    	String FSMpanellist=winlist("mapper_panel*",";","WIN:65")
    	redimension /n=(itemsinlist(FSMpanellist)) FSMList,FSMPathList
    
    	Variable index=0
    	do
    		String fsmname=Stringfromlist(index,FSMpanellist,";")
    		GetWindow /Z  $FSMname wtitle
    		FSMlist[index]=S_value
    		FSMPathList[index]=fsmname
    		index+=1
    	while (index<itemsinlist(FSMpanellist))
    	sort /A FSMlist,FSMlist,FSMpathlist
End

Function updata_mapping_par(flag)
	Variable flag
	DFREF df=getDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_common=$(DF_panel+":panel_common")
	
	//SVAR sourcePathlist=DF_common:gs_sourcePathlist
	//SVAR sourcenamelist=DF_common:gs_sourcenamelist
	WAVE/T w_sourcePathes = DFR_panel:w_sourcePathes
	WAVE/T w_sourceNames = DFR_panel:w_sourceNames
	Wave/B w_sourceNamessel=DFR_panel:w_sourceNamessel
	
	String sourcePathlist=WaveToStringList(w_sourcePathes,";",Nan,Nan)
	String sourcenamelist=WaveToStringList(w_sourceNames,";",Nan,Nan)
	
	NVAR toplayernum=DFR_common:gv_toplayernum
	NVAR topprocnum=DFR_common:gv_topprocnum
	NVAR autolayerflag=DFR_common:gv_autolayerflag
	
	if (numpnts(w_sourcePathes)==0)
		doalert 0,"No Waves"
		SetDatafolder DF
		return 1
	endif
	
	if (autolayerflag==1)
		if (Check_Autosimilar_layer_list(w_sourcePathes,w_sourceNamessel,toplayernum,topprocnum,0)==-1)
			doalert 0,"Not similar layer, change auto."
   			autolayerflag=0
   		endif
	endif
	

	SetDatafolder $DF_panel
	
	make /o/n=(numpnts(w_sourcePathes)) w_Clist,w_Flist,w_C_off,w_F_off,w_Azilist,w_Azi_off,w_eF,w_hn,w_workfunc,w_innerE,w_gammaA,w_curveflag
	
	NVAR EF = gv_EF
	NVAR hn = gv_hn
	NVAR workfunc = gv_workfunction
	NVAR innerE = gv_innerE
	NVAR gammaA=gv_gammaA
	NVAR th_off=gv_th_off
	NVAR phi_off=gv_ph_off
	NVAR alpha_off=gv_alpha_off
	NVAR initialflag=gv_initialflag
	NVAR curveflag=gv_curveflag
	
	Variable index=0
		
	do 
		Wave data=$w_sourcePathes[index]
 
    		if (wavedims(data)>2)
			Variable datalayernum=Autolayer_wavelist(data,toplayernum,topprocnum,autolayerflag)
		else
			datalayernum=0
		endif

		ReadDetailWaveNote(data,datalayernum,1)
		Wave WaveVars
		w_Clist[index] =Wavevars[0]
		W_C_off[index]=Wavevars[1]
		W_Flist[index] = Wavevars[2]
		w_F_off[index]=Wavevars[3]
		w_azilist[index]= Wavevars[4]
		w_azi_off[index]=Wavevars[5]
		w_hn[index] = Wavevars[6]
		w_eF[index]=Wavevars[7]
		w_workfunc[index]=Wavevars[11]
		w_curveflag[index]=Wavevars[12]
	
		initialflag=Wavevars[10]

		w_InnerE[index]=Wavevars[8]
		w_gammaA[index] =Wavevars[9]
		Killwaves /Z WaveVars,WaveinfoL
		index+=1
	while (index<numpnts(w_sourcePathes))
	//Killwaves /Z WaveVars,WaveinfoL
	
	Ef=CheckReturnWaveequal(w_eF,Nan,Nan)
	hn=CheckReturnWaveequal(w_hn,Nan,Nan)
	workfunc=CheckReturnWaveequal(w_workfunc,Nan,Nan)
	innerE=CheckReturnWaveequal(w_innerE,Nan,Nan)
	th_off=CheckReturnWaveequal(w_C_off,Nan,Nan)
	phi_off=CheckReturnWaveequal(w_F_off,Nan,Nan)
	alpha_off=CheckReturnWaveequal(w_azi_off,Nan,Nan)
	gammaA=CheckReturnWaveequal(w_gammaA,Nan,Nan)
	
	//if ((numtype(th_off)==2)||(numtype(phi_off)==2)||(numtype(alpha_off)==2)||(numtype(gammaA)==2))
	//	checkbox settings_ck10,value=0
	//else
	//	checkbox settings_ck10,value=1
	//endif
	if (numtype(workfunc)==2)
		workfunc=4.35
	endif
	
	curveflag=CheckReturnWaveequal(w_curveflag,Nan,Nan)
	
	SetDatafolder DF
end

















//FSM symmetry 
//
//
//
//
//

Function /Wave Macro_sym_cube(DFR_panel,cube,symvalue,autokgridflag,overflag,startflag)
	DFREF DFR_panel
	Wave cube
	variable symvalue
	Variable autokgridflag,overflag,startflag
	
	
	DFREF DF=GetDatafolderDFR()
	
	SetDatafolder DFR_panel
	
	Variable en=dimsize(cube,2)
	
	Make /o/n=(dimsize(cube,0),dimsize(cube,1)) cube_FSM_temp
	CopyScales /I  cube, cube_FSM_temp
	
	Variable index=0
	do 
		cube_FSM_temp=cube[p][q][index]
		
		MoveFSMap(cube_FSM_temp,autokgridflag)
 		Wave FSM_temp
		RotateFSMap(FSM_temp,autokgridflag)
		//DeleteNanEdgeFSM(FSM_temp)
 		Wave FSM_temp
 		MirrorFSMap(FSM_temp,autokgridflag,overflag,startflag)
 	
 		switch(symvalue)
   		case 1:
   			break
   		case 2:
   			TwoFSMap(FSM_temp,autokgridflag,overflag,startflag)
   			break
   		Case 3:
   			ThreeFSMap(FSM_temp,autokgridflag,overflag,startflag)
   			break
   		case 4:
   			FourFSMap(FSM_temp,autokgridflag,overflag,startflag)
   			break
   		case 5:
   			SixFSMap(FSM_temp,autokgridflag,overflag,startflag)
   			break
  		endswitch
 		Wave FSM_temp
 		//DeleteNanEdgeFSM(FSM_temp)
 		wave /Z sym_cube=DFR_panel:sym_kxky_Cube
 		if (waveexists(sym_cube)==0)
 			make /o/n=(dimsize(FSM_temp,0),dimsize(FSM_temp,1),en) sym_kxky_cube
 			CopyScales /I  FSM_temp, sym_kxky_cube
 			setscale /I z, M_z0(cube),M_z1(cube),sym_kxky_cube	
 		endif
 		
 		wave /Z sym_cube=DFR_panel:sym_kxky_Cube
 		sym_cube[][][index]=FSM_temp[p][q]
 		
		index+=1
	while (index<en)
	
	
 	Killwaves /Z cube_FSM_temp,FSM_temp
 		
	SetDatafolder DF
	
	return sym_cube
End



Function /Wave Macro_sym_mapper(DFR_panel,FSM,symvalue,autokgridflag,overflag,startflag)
	DFREF DFR_panel
	Wave FSM
	variable symvalue
	Variable autokgridflag,overflag,startflag
	
	
	DFREF DF=GetDatafolderDFR()
	
	SetDatafolder DFR_panel
	
	MoveFSMap(FSM,autokgridflag)
 	Wave FSM_temp
	RotateFSMap(FSM_temp,autokgridflag)
	if (autokgridflag)
		DeleteNanEdgeFSM(FSM_temp)
	endif
	Wave FSM_temp
	FlipFSMap(FSM_temp,autokgridflag,overflag,startflag)
 	Wave FSM_temp
 	MirrorFSMap(FSM_temp,autokgridflag,overflag,startflag)
 	
 	switch(symvalue)
   	case 1:
   	break
   	case 2:
   		TwoFSMap(FSM_temp,autokgridflag,overflag,startflag)
   	break
   	Case 3:
   		ThreeFSMap(FSM_temp,autokgridflag,overflag,startflag)
   	break
   	case 4:
   		FourFSMap(FSM_temp,autokgridflag,overflag,startflag)
   	break
   	case 5:
   		SixFSMap(FSM_temp,autokgridflag,overflag,startflag)
   	break
  	endswitch
 	Wave FSM_temp
 	if (autokgridflag)
 		DeleteNanEdgeFSM(FSM_temp)
 	endif
 		
	SetDatafolder DF
	
	return FSM_temp
End

Function GenerateFSMXY(FSM,azi,rawFSM) //rawFSM for 1 left, 2 right 3 up 4 down
	Wave FSM
	Variable azi
	Variable rawFSM
	Variable d2r=pi/180
	duplicate /o FSM FSMX,FSMY,FSMA_temp,FSMB_temp
	
	if (rawFSM==1)
		FSMA_temp=(x>=0)?(pi-abs(atan(y/x))):(abs(atan(y/x)))
	elseif (rawFSM==2)
		FSMA_temp=(x>=0)?(abs(atan(y/x))):(pi-abs(atan(y/x)))
	elseif (rawFSM==3)
		FSMA_temp=(x>=0)?(pi/2-atan(y/x)):(pi/2+atan(y/x))
	elseif (rawFSM==4)
		FSMA_temp=(x>=0)?(atan(y/x)+pi/2):(pi/2-atan(y/x))
	endif
	
	FSMB_temp=floor((FSMA_temp[p][q]+(d2r*azi/2))/(d2r*azi))
	
	if (rawFSM==1)
		FSMB_temp=(y<0)?(-FSMB_temp):(FSMB_temp)
	elseif (rawFSM==2)
		FSMB_temp=(y>0)?(-FSMB_temp):(FSMB_temp)
	elseif (rawFSM==3)
		FSMB_temp=(x<0)?(-FSMB_temp):(FSMB_temp)
	elseif (rawFSM==4)
		FSMB_temp=(x>0)?(-FSMB_temp):(FSMB_temp)
	endif
	
	FSMX=x*cos(d2r*azi*FSMB_temp)-y*sin(d2r*azi*FSMB_temp)
	FSMy=x*sin(d2r*azi*FSMB_temp)+y*cos(d2r*azi*FSMB_temp)
	
	//Killwaves /Z FSMA_temp,FSMB_temp
		
End	

Function returnFSMrange(FSM,azi,fold)
	Wave FSM
	Variable azi,fold
	
	Variable x0=M_x0(FSM)
	Variable x1=M_x1(FSM)
	Variable y0=M_y0(FSM)
	Variable y1=M_y1(FSM)
	Variable d2r=pi/180
	
	if ((azi*fold)!=360)
		make /o /n=4 Px,Py
		Px[0]=(x0*cos(d2r*azi)-y0*sin(d2r*azi))
		Py[0]=(y0*cos(d2r*azi)+x0*sin(d2r*azi))
		Px[1]=(x0*cos(d2r*azi)-y1*sin(d2r*azi))
		Py[1]=(y1*cos(d2r*azi)+x0*sin(d2r*azi))
		Px[2]=(x1*cos(d2r*azi)-y0*sin(d2r*azi))
		Py[2]=(y0*cos(d2r*azi)+x1*sin(d2r*azi))
		Px[3]=(x1*cos(d2r*azi)-y1*sin(d2r*azi))
		Py[3]=(y1*cos(d2r*azi)+x1*sin(d2r*azi))
	
		make /o/n=4 RangeWave
		RangeWave[0]=Wavemin(px)
		RangeWave[1]=Wavemax(px)
		RangeWave[2]=Wavemin(py)
		RangeWave[3]=Wavemax(py)
		killwaves /Z px,py
		return 1
	else
		make /o/n=4 Pr
		pr[0]=sqrt(x0^2+y0^2)
		pr[1]=sqrt(x0^2+y1^2)
		pr[2]=sqrt(x1^2+y0^2)
		pr[3]=sqrt(x1^2+y1^2)
		Wavestats /Q pr
		Variable sx0,sy0
		switch (V_maxrowLoc)
		case 0:
			sx0=x0
			sy0=y0
		break
		case 1:
			sx0=x0
			sy0=y1
		break
		case 2:
			sx0=x1
			sy0=y0
		break
		case 3:
			sx0=x1
			sy0=y1
		break
		endswitch
		killwaves /Z pr
	
	make /o /n=(fold) Px,Py
	
	Variable index,sazi
	do 
		sazi=index*azi
		Px[index]=(sx0*cos(d2r*sazi)-sy0*sin(d2r*sazi))
		Py[index]=(sy0*cos(d2r*sazi)+sx0*sin(d2r*sazi))
	index+=1
	while (index<fold)
	
	make /o/n=4 RangeWave
	RangeWave[0]=Wavemin(px)
	RangeWave[1]=Wavemax(px)
	RangeWave[2]=Wavemin(py)
	RangeWave[3]=Wavemax(py)
	killwaves /Z px,py
	return 1
	endif
	
End

Function autoguessstart(FSM)
	Wave FSM
	Variable x0,x1,y0,y1
	Variable xrange,yrange

	x0=M_x0(FSM)
	x1=M_x1(FSM)
	y0=M_y0(FSM)
	y1=M_y1(FSM)
	
	if (max(abs(x0),abs(x1))>max(abs(y0),abs(y1)))
		if (x1/x0>0)
			if (x1>0)
				return 2
			else
				return 1
			endif
		else
			if (abs(x1)>abs(x0))
				return 2
			else
			 	return 1
			 endif
		endif
	else
		if (y1/y0>0)
			if (y1>0)
				return 3
			else
				return 4
			endif
		else
			if (abs(y1)>abs(y0))
				return 3
			else
			 	return 4
			 endif
		endif
	endif	
	
End


Function TwoFSMap(FSM,autokgridflag,overflag,startflag)
	Wave FSM 
	Variable autokgridflag,overflag,startflag
    	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel

	if (autokgridflag==0)
	
		NVAR kxM=Nc_kxM
		NVAR kyM=Nc_kyM
		NVAR dk=Nc_dk
			
		Variable i=0
		Variable j=0
		Variable Mi=trunc(kxM/dk)+1
		Variable Mj=trunc(kyM/dk)+1
		Make /o/n=((2*Mi-1),(2*Mj-1)) FSM_result
		Setscale/P x -kxM,dk,FSM_result
		Setscale/P y -kyM,dk,FSM_result
	
	else
	
		returnFSMrange(FSM,180,2)
	
		Wave Rangewave
		mi=round((Rangewave[1]-Rangewave[0])/dimdelta(FSM,0)+1)
		mj=round((Rangewave[3]-Rangewave[2])/dimdelta(FSM,1)+1)
		Make /o/n=(Mi,Mj) FSM_result
		Setscale /I x,Rangewave[0],Rangewave[1],FSM_result
		Setscale /I y,Rangewave[2],Rangewave[3],FSM_result
		Killwaves /Z Rangewave
	
	endif
	
	if (startflag==0)
		startflag=autoguessstart(FSM)
	endif
	
	GenerateFSMXY(FSM_result,180,startflag)
	Wave FSMX,FSMY
	if (overflag == 1)
		FSM_result=interp2D(FSM,FSMX,FSMY)
	elseif (overflag ==2)
		Duplicate /o/Free FSM_result,FSM_result_temp
		FSM_result_temp=interp2D(FSM,x,y)
		FSM_result=interp2D(FSM,FSMX,FSMY)
		FSM_result=((numtype(FSM_result_temp)!=2)&&(numtype(FSM_result)!=2))?((FSM_result+FSM_result_temp)/2):(FSM_result)
		FSM_result=((numtype(FSM_result_temp)!=2)&&(numtype(FSM_result)==2))?(FSM_result_temp):(FSM_result)
	elseif (overflag ==3)
		FSM_result=interp2D(FSM,x,y)
		FSM_result=(numtype(FSM_result)==2)?(interp2D(FSM,FSMX,FSMY)):(FSM_result)
	endif
	duplicate /o FSM_result FSM_temp
	Killwaves /Z FSM_result,FSMX,FSMY
	SetDataFolder DF
end


Function ThreeFSMap(FSM,autokgridflag,overflag,startflag)
	Wave FSM 
	Variable autokgridflag,overflag,startflag
    	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel

	if (autokgridflag==0)
	
	NVAR kxM=Nc_kxM
	NVAR kyM=Nc_kyM
	NVAR dk=Nc_dk
			
	Variable i=0
	Variable j=0
	Variable Mi=trunc(kxM/dk)+1
	Variable Mj=trunc(kyM/dk)+1
	Make /o/n=((2*Mi-1),(2*Mj-1)) FSM_result
	Setscale/P x -kxM,dk,FSM_result
	Setscale/P y -kyM,dk,FSM_result
	
	else
	
	returnFSMrange(FSM,120,3)
	
	Wave Rangewave
	mi=round((Rangewave[1]-Rangewave[0])/dimdelta(FSM,0)+1)
	mj=round((Rangewave[3]-Rangewave[2])/dimdelta(FSM,1)+1)
	Make /o/n=(Mi,Mj) FSM_result
	Setscale /I x,Rangewave[0],Rangewave[1],FSM_result
	Setscale /I y,Rangewave[2],Rangewave[3],FSM_result
	Killwaves /Z Rangewave
	
	endif
	
	if (startflag==0)
		startflag=autoguessstart(FSM)
	endif
	
	
	GenerateFSMXY(FSM_result,120,startflag)
	Wave FSMX,FSMY
	if (overflag ==1)
		FSM_result=interp2D(FSM,FSMX,FSMY)
	elseif (overflag ==2)
		Duplicate /o/Free FSM_result,FSM_result_temp
		FSM_result_temp=interp2D(FSM,x,y)
		FSM_result=interp2D(FSM,FSMX,FSMY)
		FSM_result=((numtype(FSM_result_temp)!=2)&&(numtype(FSM_result)!=2))?((FSM_result+FSM_result_temp)/2):(FSM_result)
		FSM_result=((numtype(FSM_result_temp)!=2)&&(numtype(FSM_result)==2))?(FSM_result_temp):(FSM_result)
	elseif (overflag ==3)
		FSM_result=interp2D(FSM,x,y)
		FSM_result=(numtype(FSM_result)==2)?(interp2D(FSM,FSMX,FSMY)):(FSM_result)
	endif
	duplicate /o FSM_result FSM_temp
	Killwaves /Z FSM_result,FSMX,FSMY
	SetDataFolder DF
end




Function FourFSMap(FSM,autokgridflag,overflag,startflag)
	Wave FSM 
	Variable autokgridflag,overflag,startflag
    	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel

	if (autokgridflag==0)
	
	NVAR kxM=Nc_kxM
	NVAR kyM=Nc_kyM
	NVAR dk=Nc_dk
			
	Variable i=0
	Variable j=0
	Variable Mi=trunc(kxM/dk)+1
	Variable Mj=trunc(kyM/dk)+1
	Make /o/n=((2*Mi-1),(2*Mj-1)) FSM_result
	Setscale/P x -kxM,dk,FSM_result
	Setscale/P y -kyM,dk,FSM_result
	
	else
	
	returnFSMrange(FSM,90,4)
	
	Wave Rangewave
	mi=round((Rangewave[1]-Rangewave[0])/dimdelta(FSM,0)+1)
	mj=round((Rangewave[3]-Rangewave[2])/dimdelta(FSM,1)+1)
	Make /o/n=(Mi,Mj) FSM_result
	Setscale /I x,Rangewave[0],Rangewave[1],FSM_result
	Setscale /I y,Rangewave[2],Rangewave[3],FSM_result
	Killwaves /Z Rangewave
	
	endif
	if (startflag==0)
		startflag=autoguessstart(FSM)
	endif
	
	
	GenerateFSMXY(FSM_result,90,startflag)
	Wave FSMX,FSMY
	if (overflag == 1)
		FSM_result=interp2D(FSM,FSMX,FSMY)
	elseif (overflag ==2)
		Duplicate /o/Free FSM_result,FSM_result_temp
		FSM_result_temp=interp2D(FSM,x,y)
		FSM_result=interp2D(FSM,FSMX,FSMY)
		FSM_result=((numtype(FSM_result_temp)!=2)&&(numtype(FSM_result)!=2))?((FSM_result+FSM_result_temp)/2):(FSM_result)
		FSM_result=((numtype(FSM_result_temp)!=2)&&(numtype(FSM_result)==2))?(FSM_result_temp):(FSM_result)
	elseif (overflag ==3)
		FSM_result=interp2D(FSM,x,y)
		FSM_result=(numtype(FSM_result)==2)?(interp2D(FSM,FSMX,FSMY)):(FSM_result)
	endif
	duplicate /o FSM_result FSM_temp
	Killwaves /Z FSM_result,FSMX,FSMY

	SetDataFolder DF
end

Function SixFSMap(FSM,autokgridflag,overflag,startflag)
	Wave FSM 
	Variable autokgridflag,overflag,startflag
    	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel

	if (autokgridflag==0)
	
		NVAR kxM=Nc_kxM
		NVAR kyM=Nc_kyM
		NVAR dk=Nc_dk
			
		Variable i=0
		Variable j=0
		Variable Mi=trunc(kxM/dk)+1
		Variable Mj=trunc(kyM/dk)+1
		Make /o/n=((2*Mi-1),(2*Mj-1)) FSM_result
		Setscale/P x -kxM,dk,FSM_result
		Setscale/P y -kyM,dk,FSM_result
	
	else
	
		returnFSMrange(FSM,60,6)
	
		Wave Rangewave
		mi=round((Rangewave[1]-Rangewave[0])/dimdelta(FSM,0)+1)
		mj=round((Rangewave[3]-Rangewave[2])/dimdelta(FSM,1)+1)
		Make /o/n=(Mi,Mj) FSM_result
		Setscale /I x,Rangewave[0],Rangewave[1],FSM_result
		Setscale /I y,Rangewave[2],Rangewave[3],FSM_result
		Killwaves /Z Rangewave
	
	endif
	
	if (startflag==0)
		startflag=autoguessstart(FSM)
	endif
	
	
	GenerateFSMXY(FSM_result,60,startflag)
	Wave FSMX,FSMY
	if (overflag ==1)
		FSM_result=interp2D(FSM,FSMX,FSMY)
	elseif (overflag ==2)
		Duplicate /o/Free FSM_result,FSM_result_temp
		FSM_result_temp=interp2D(FSM,x,y)
		FSM_result=interp2D(FSM,FSMX,FSMY)
		FSM_result=((numtype(FSM_result_temp)!=2)&&(numtype(FSM_result)!=2))?((FSM_result+FSM_result_temp)/2):(FSM_result)
		FSM_result=((numtype(FSM_result_temp)!=2)&&(numtype(FSM_result)==2))?(FSM_result_temp):(FSM_result)
		
		
	elseif (overflag ==3)
		FSM_result=interp2D(FSM,x,y)
		FSM_result=(numtype(FSM_result)==2)?(interp2D(FSM,FSMX,FSMY)):(FSM_result)
	endif
	duplicate /o FSM_result FSM_temp
	Killwaves /Z FSM_result,FSMX,FSMY
	SetDataFolder DF
end


Function FlipFSMap(FSM,autokgridflag,overflag,startflag)
    	Wave FSM 
	Variable autokgridflag,overflag,startflag
    	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel
	
     	Controlinfo FSMproc_c41
     	Variable flipYflag=V_Value
     	Controlinfo FSMproc_c42
     	Variable flipXflag=V_Value
    
    	if ((flipYflag||flipXflag)==1)
    	
    		duplicate /o FSM FSM_result
	
		//if (autokgridflag!=0)
			
			
		Variable x0,x1,y0,y1
		x0=M_x0(FSM)
		x1=M_x1(FSM)
		y0=M_y0(FSM)
		y1=M_y1(FSM)
	
		if (flipYflag&&flipXflag)
				//Make /o/n=((2*Mi-1),(2*Mj-1)) FSM_result
			Setscale/I x -x1,-x0,FSM_result
			Setscale/I  y -y1,-y0,FSM_result
			FSM_result=interp2D(FSM,-x,-y)
		elseif (flipYflag==1)
				//Make /o/n=((2*Mi-1),dimsize(FSM,1)) FSM_result
			Setscale/I  x -x1,-x0,FSM_result
			FSM_result=interp2D(FSM,-x,y)
		elseif (flipXflag==1)
				//Make /o/n=(dimsize(FSM,0),(2*Mj-1)) FSM_result
			Setscale/I  y -y1,-y0,FSM_result
			FSM_result=interp2D(FSM,x,-y)
		endif

		//endif
		
		//Variable rawxFSM,rawyFSM
	
		//
		
		
		duplicate /o FSM_result FSM_temp
	
		Killwaves/Z FSM_result
	
     else
     
	 SetDataFolder DF
   	 return 0
    endif
    
	SetDataFolder DF

End


Function MirrorFSMap(FSM,autokgridflag,overflag,startflag)
    	Wave FSM 
	Variable autokgridflag,overflag,startflag
    	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel
	
     	Controlinfo FSMproc_c0
     	Variable mirYflag=V_Value
     	Controlinfo FSMproc_c1
     	Variable mirXflag=V_Value
    
    	if ((mirYflag||mirXflag)==1)
    
	
		if (autokgridflag==0)
			duplicate /o FSM FSM_result	
		else
	
			Variable x0,x1,y0,y1,rkxM,rkyM,rdk
			x0=M_x0(FSM)
			x1=M_x1(FSM)
			y0=M_y0(FSM)
			y1=M_y1(FSM)
	
			if (mirYflag)
				rkxM=Max(abs(x0),abs(x1))
			endif
	
			if (mirXflag)
				rkyM=Max(abs(y0),abs(y1))
			endif
	
			rdk=min(dimdelta(FSM,0),dimdelta(FSM,1))
	
			Variable Mi=trunc(rkxM/rdk)+1
			Variable Mj=trunc(rkyM/rdk)+1
	
			if (mirYflag&&mirXflag)
				Make /o/n=((2*Mi-1),(2*Mj-1)) FSM_result
				Setscale/P x -rkxM,rdk,FSM_result
				Setscale/P y -rkyM,rdk,FSM_result
			elseif (mirYflag==1)
				Make /o/n=((2*Mi-1),dimsize(FSM,1)) FSM_result
				Setscale/P x -rkxM,rdk,FSM_result
				Setscale/I y y0,y1,FSM_result
			elseif (mirXflag==1)
				Make /o/n=(dimsize(FSM,0),(2*Mj-1)) FSM_result
				Setscale/I x x0,x1,FSM_result
				Setscale/P y -rkyM,rdk,FSM_result
			endif
	
			FSM_result=interp2D(FSM,x,y)
		endif
		
		Variable rawxFSM,rawyFSM
		
		if (mirYflag)
			if  (startflag==1) //left
				rawxFSM=-1
			elseif (startflag==2) //right
				rawxFSM=1
			else
				if ((x0/x1)>0)
					rawxFSM=(x0>0)?(1):(-1)
				else
					if (abs(x1)>abs(x0))
						rawxFSM=1
					else
						rawxFSM=-1
					endif
				endif
			endif
		endif
			
		if (mirXflag)
			if  (startflag==3) //up
				rawyFSM=1
			elseif (startflag==4)//down
				rawyFSM=-1
			else	
				if ((y0/y1)>0)
					rawyFSM=(y0>0)?(2):(-2)
				else
					if (abs(y1)>abs(y0))
						rawyFSM=1
					else
						rawyFSM=-1
					endif
				endif
			endif							
		endif
		
	
		if (mirYflag&&mirXflag)
			if (overflag == 1)
				FSM_result=interp2D(FSM,rawxFSM*abs(x),rawyFSM*abs(y))
			elseif (overflag ==2)
				Duplicate /o/Free FSM_result,FSM_result_temp
				FSM_result = interp2D(FSM,rawxFSM*abs(x),rawyFSM*abs(y))
				FSM_result=((numtype(FSM_result_temp)!=2)&&(numtype(FSM_result)!=2))?((FSM_result+FSM_result_temp)/2):(FSM_result)
				FSM_result=((numtype(FSM_result_temp)!=2)&&(numtype(FSM_result)==2))?(FSM_result_temp):(FSM_result)
			elseif (overflag == 3)
				FSM_result=(numtype(FSM_result)==2)?(interp2D(FSM,rawxFSM*abs(x),rawyFSM*abs(y))):(FSM_result)
			endif
		
		elseif (mirYflag==1)
			if (overflag == 1)
				FSM_result=interp2D(FSM,rawxFSM*abs(x),y)
			elseif (overflag ==2)
				Duplicate /o/Free FSM_result,FSM_result_temp
				FSM_result =interp2D(FSM,rawxFSM*abs(x),y)
				//FSM_result=(numtype(FSM_result)==2)?(interp2D(FSM,rawxFSM*abs(x),y)):((FSM_result+interp2D(FSM,rawxFSM*abs(x),y))/2)
				FSM_result=((numtype(FSM_result_temp)!=2)&&(numtype(FSM_result)!=2))?((FSM_result+FSM_result_temp)/2):(FSM_result)
				FSM_result=((numtype(FSM_result_temp)!=2)&&(numtype(FSM_result)==2))?(FSM_result_temp):(FSM_result)
			elseif (overflag == 3)
				FSM_result=(numtype(FSM_result)==2)?(interp2D(FSM,rawxFSM*abs(x),y)):(FSM_result)
			endif
		elseif (mirXflag==1)
			if (overflag ==1)
				FSM_result=interp2D(FSM,x,rawyFSM*abs(y))
			elseif (overflag ==2)
				Duplicate /o/Free FSM_result,FSM_result_temp
				FSM_result = interp2D(FSM,x,rawyFSM*abs(y))
				//FSM_result=(numtype(FSM_result)==2)?(interp2D(FSM,x,rawyFSM*abs(y))):((FSM_result+interp2D(FSM,x,rawyFSM*abs(y)))/2)
			       FSM_result=((numtype(FSM_result_temp)!=2)&&(numtype(FSM_result)!=2))?((FSM_result+FSM_result_temp)/2):(FSM_result)
				FSM_result=((numtype(FSM_result_temp)!=2)&&(numtype(FSM_result)==2))?(FSM_result_temp):(FSM_result)			
			elseif (overflag ==3)
				FSM_result=(numtype(FSM_result)==2)?(interp2D(FSM,x,rawyFSM*abs(y))):(FSM_result)
			endif
		endif
	
	
	duplicate /o FSM_result FSM_temp
	
	Killwaves/Z FSM_result
	
     else
	 SetDataFolder DF
   	 return 0
    endif
    
	SetDataFolder DF

End

Function RotateFSMap(FSM,autokgridflag)
    	Wave FSM 
	Variable autokgridflag
    	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel
	
	
	duplicate /o FSM FSM_result
	NVAR Azi=Nc_azi
	//if (sign(Azi)==1)
	ImageRotate /A=(Azi) /Q/O  FSM_result
	//else
	//ImageRotate /A=(Azi) /Q/O  FSM_result
	//endif
	
	returnFSMrange(FSM,azi,1)
	Wave Rangewave
	Setscale /I x,Rangewave[0],Rangewave[1],FSM_result
	Setscale /I y,Rangewave[2],Rangewave[3],FSM_result
	Killwaves /Z rangewave
	
	duplicate /o FSM_result FSM_temp
	//endif
	
	
	
	Killwaves/Z FSM_result
	
	SetDataFolder DF

End

Function MoveFSMap(FSM,autokgridflag)
    	Wave FSM 
    	Variable autokgridflag
    	
	DFREF DF=GetDatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_common=$(DF_panel+":panel_common")
	DFREF DFR_panel=$DF_panel
	
	SetDatafolder DFR_panel
	
	NVAR Dx=Nc_dx
	NVAR Dy=Nc_dy
		
	if (autokgridflag==0)
	
		NVAR kxM=Nc_kxM
		NVAR kyM=Nc_kyM
		NVAR dk=Nc_dk
			
		Variable i=0
		Variable j=0
		Variable Mi=trunc(kxM/dk)+1
		Variable Mj=trunc(kyM/dk)+1
		Make /o/n=((2*Mi-1),(2*Mj-1)) FSM_result
		Setscale/P x -kxM,dk,FSM_result
		Setscale/P y -kyM,dk,FSM_result
		FSM_result=interp2d(FSM,x-Dx,y-Dy)
	else
		duplicate /o FSM FSM_result
		Setscale /p x dimoffset(FSM,0)+dx,dimdelta(FSM,0),FSM_result
		Setscale /p y dimoffset(FSM,1)+dy,dimdelta(FSM,1),FSM_result
	endif
	
	
	duplicate /o FSM_result,FSM_temp
	
	Killwaves /Z FSM_result
	
	SetDataFolder DF

End







