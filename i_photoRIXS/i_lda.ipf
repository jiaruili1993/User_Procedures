#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 2.00
#pragma ModuleName=lda
#pragma IgorVersion = 5.0


Static Function interp_bxsf(x, y, z, basetransform, src, fillBZ)
	Variable x, y, z
	String fillBZ
	WAVE basetransform
	WAVE src
	Make/O/N=(3,1) w_vec_tmp = {{x, y, z}}
	
	MatrixMultiply basetransform, w_vec_tmp
	WAVE M_product
	M_Product[][0] *= (DimSize(src, p) - 1)
	Variable vx = M_product[0][0], vy = M_product[1][0], vz = M_product[2][0]

	strswitch(fillBZ)
		case "translate":
		case "mirror":
			Variable ix
			for(ix = 0; vx < 0; vx += DimSize(src, 0)-1)
				ix += 1
			endfor
			if (ix == 0)
				for(ix = 0; vx >= DimSize(src, 0)-1; vx -= DimSize(src, 0)-1)
					ix += 1
				endfor
			endif
			Variable iy
			for(iy = 0; vy < 0; vy += DimSize(src, 1)-1)
				iy += 1
			endfor
			if (iy == 0)
				for(iy = 0; vy >= DimSize(src, 1)-1; vy -= DimSize(src, 1)-1)
					iy += 1
				endfor
			endif
			Variable iz
			for(iz = 0; vz < 0; vz += DimSize(src, 2)-1)
				iz += 1
			endfor
			if (iz == 0)
				for(iz = 0; vz >= DimSize(src, 2) - 1; vz -= DimSize(src, 2)-1)
					iz += 1
				endfor
			endif
			if (stringmatch("translate", fillBZ))
				break
			endif
			if (mod(ix,2) != 0)
				vx = DimSize(src, 0) - 1 - vx
			endif
			if (mod(iy,2) != 0)
				vy = DimSize(src, 1) - 1 - vy
			endif
			if (mod(iz,2) != 0)
				vz = DimSize(src, 2) - 1 - vz
			endif
			break
		default:
		case "none":
			break
	endswitch

	return interp3d(src, vx, vy, vz)
End

// Makes w_cube4col, a 4 column, 2D Wave, as described in Interp3D, and
// a wave w_cube, which is the interpolated wave, using interp3D.
//
// dimension 1-3 are kx, ky, kz
// nx, ny, nz are the sample points to be used.
// band is the band number to be used.
// options is a ";" separated list. NOTE that if an option is specified more than one time, 
// only the first of these is used and the rest will be ignored. is The following options are recognized:
// xlimits=x0,x1,nx
//	x0 is the start, x1 the end, and nx the amount of sample points in x-direction.
// 	If not given, x0 and x1 are determined from the data (i.e. determined minimum quadric in 
//	cartesian coordiantes needed to encompass the bxsf unit cell)
//	The default sampling is four times the average sampling used for the x,y,z directions in the 
//	bxsf segment.
// ylimits=y0,y1,ny
//	See xlimits.
// zlimits=z0,z1,nz
//	See xlimits.
// limits=p0, p1, np
//	(overridden by xlimits, ylimits, zlimits)
//	Convenience option, behaves the same as specifying 
//	"xlimits=p0,p1,np;ylimits=p0,p1,np;zlimits=p0,p1,np"
// autolimits=mode
//	(overridden by limits, xlimits, ylimits, zlimits) mode can be one of:
//	"bxsf": x/y/z limits are determined from the extent of the bxsf segment (i.e. the
//		minimum quadric in cartesian coordiantes needed to encompass the bxsf unit cell)
//	"fullbxsf": same as above, except the bxsf segment is replicated in all space directions
//	to yield a full BZ before determining limits.
//	a number: x/y/z limits are this number in each extent (e.g. you specified 1.3, then,
//		x, y, and z range from -1.3 to 1.3. This is the default, with the number 1.
// fillBZ=mode
//	determines the mode used to replicate the bxsf segment in order to fill the BZ. Can be
//	one of the following:
//	"none" no replication is performed.
//	"translate" translates the bxsf segment along the bxsf unit vectors in order to fill BZ.
//	"mirror" mirrors the bxsf segment along the bordering faces of the bxsf segment in
//		order to fill BZ.
// sampling=nx,ny,nz
//	(overridden by limits, xlimits, ylimits, zlimits)
//	specifies the sampling in the x, y, z direction. Same as nx, ny, nz in limits, but does
//	not set the x/y/z limits, i.e. they are still determined automatically if no additional limits
//	are specified.
//
// Produces the waves w_cube, which is a 3D cube containing the band energy vs. kx,ky,kz
// and w_cube4col, which is a 4-column wave: each row is a point, while column 0
// is the energy and column 1-3 are the corresponding kx, ky, kz. w_cube4col is not
// interpolated in any fashion; it simply is the input data of one band you select in another
// format that you can use for interp3d if you ever should need that.
Function lda_bxsf2cube(wbxsf, band, [options])
	WAVE wbxsf
	Variable band
	String options

	// default options:	
	if (ParamIsDefault(options) == 1)
		options = "fillBZ=translate;autolimits=1"
	else
		options = options+";fillBZ=translate;autolimits=1"
	endif
	

	String wnote = note(wbxsf)
	Variable originX = NumberByKey("OriginX", wnote, "=", "\r")
	Variable originY = NumberByKey("OriginY", wnote, "=", "\r")
	Variable originZ = NumberByKey("OriginZ", wnote, "=", "\r")
	Variable vec1X = NumberByKey("Vec1X", wnote, "=", "\r")
	Variable vec1Y = NumberByKey("Vec1Y", wnote, "=", "\r")
	Variable vec1Z = NumberByKey("Vec1Z", wnote, "=", "\r")
	Make/O/N=3 w_v1_tmp = {vec1X-originX, vec1Y-originY, vec1Z-originZ}

	Variable vec2X = NumberByKey("Vec2X", wnote, "=", "\r")
	Variable vec2Y = NumberByKey("Vec2Y", wnote, "=", "\r")
	Variable vec2Z = NumberByKey("Vec2Z", wnote, "=", "\r")
	Make/O/N=3 w_v2_tmp = {vec2X-originX, vec2Y-originY, vec2Z-originZ}

	Variable vec3X = NumberByKey("Vec3X", wnote, "=", "\r")
	Variable vec3Y = NumberByKey("Vec3Y", wnote, "=", "\r")
	Variable vec3Z = NumberByKey("Vec3Z", wnote, "=", "\r")
	Make/O/N=3 w_v3_tmp = {vec3X-originX, vec3Y-originY, vec3Z-originZ}

	Variable EF = NumberByKey("FermiEnergy", wnote, "=", "\r")
	
	Make/O/N=(3,3) w_cube2bxsf_tmp = { {w_v1_tmp[0], w_v1_tmp[1], w_v1_tmp[2]}, {w_v2_tmp[0], w_v2_tmp[1], w_v2_tmp[2]}, {w_v3_tmp[0], w_v3_tmp[1], w_v3_tmp[2]}}
	MatrixInverse w_cube2bxsf_tmp
	WAVE M_Inverse
	Duplicate/O M_Inverse, w_bxsf2cube_tmp; KillWaves M_Inverse
	KillWaves/Z w_v1_tmp, w_v2_tmp, w_v3_tmp
	// 1. make w_cube4col
	Make/O/N=((DimSize(wbxsf, 0) * DimSize(wbxsf, 1) * DimSize(wbxsf, 2)), 4) w_cube4col
	Make/O/N=(3,1) wv_tmp

	Variable minx, maxx, miny, maxy, minz, maxz
	String autolimits = StringByKey("autolimits", options, "=", ";")
	strswitch(autolimits)
		case "bxsf":
		case "fullbxsf":
			minx = inf; maxx = -inf; miny = inf; maxy = -inf; minz = inf; maxz = -inf
			Variable vx, vy, vz
			For(vx = 0; vx < 2; vx += 1)
			For(vy = 0; vy < 2; vy += 1)
			For(vz = 0; vz < 2; vz += 1)
				Make/O/N=(3,1) wv_tmp = {{vx,vy,vz}}
				MatrixMultiply w_cube2bxsf_tmp, wv_tmp
				WAVE M_product
				minx = min(minx, M_product[0][0])
				maxx = max(maxx, M_product[0][0])
				miny = min(miny, M_product[1][0])
				maxy = max(maxy, M_product[1][0])
				minz = min(minz, M_product[2][0])
				maxz = max(maxz, M_product[2][0])
			EndFor
			EndFor
			EndFor
			if (stringmatch("fullbxsf",autolimits) == 1)
				maxx = max(abs(minx), abs(maxx)); minx = -maxx
				maxy = max(abs(miny), abs(maxy)); miny = -maxy
				maxz = max(abs(minz), abs(maxz)); minz = -maxz
			endif
			break
		default:
			Variable j = str2num(autolimits)
			if (numtype(j) != 0)
				print "WARNING: unrecognized value for option autolimits, assuming 1 instead"
				j = 1
			endif
			minx = -j; miny = -j; minz = -j
			maxx = j; maxy = j; maxz = j
			break
	endswitch
	
	// Default sampling:
	j = trunc((DimSize(wbxsf,0) + DimSize(wbxsf,1) + DimSize(wbxsf,2)) / 3 * 4)
	Variable nx = j, ny = j, nz = j
	if (strlen(StringByKey("sampling", options, "=", ";")) != 0)
		String str = StringByKey("sampling", options, "=", ";")
		Variable x0 = str2num(StringFromList(0, str, ","))
		Variable x1 = str2num(StringFromList(1, str, ","))
		Variable x2 = str2num(StringFromList(2, str, ","))
		if ((numtype(x0) != 0) ||(numtype(x1) != 0)||(numtype(x2) != 0))
			print "WARNING: did not recognize the sampling specified. Ignoring."
		else
			nx = x0; ny = x1; nz = x2
		endif
	endif

	if (strlen(StringByKey("limits", options, "=", ";")) != 0)
		str = StringByKey("limits", options, "=", ";")
		x0 = str2num(StringFromList(0, str, ","))
		x1 = str2num(StringFromList(1, str, ","))
		x2 = str2num(StringFromList(2, str, ","))
		if ((numtype(x0) != 0) ||(numtype(x1) != 0)||(numtype(x2) != 0))
			print "WARNING: did not recognize the limits specified. Ignoring."
		else
			minx = x0; miny = x0; minz = x0
			maxx = x1; maxy = x1; maxz = x1
			nx = x2; ny = x2; nz = x2
		endif
	endif
	
	if (strlen(StringByKey("xlimits", options, "=", ";")) != 0)
		str = StringByKey("xlimits", options, "=", ";")
		x0 = str2num(StringFromList(0, str, ","))
		x1 = str2num(StringFromList(1, str, ","))
		x2 = str2num(StringFromList(2, str, ","))
		if ((numtype(x0) != 0) ||(numtype(x1) != 0)||(numtype(x2) != 0))
			print "WARNING: did not recognize the xlimits specified. Ignoring."
		else
			minx = x0
			maxx = x1
			nx = x2
		endif
	endif
	if (strlen(StringByKey("ylimits", options, "=", ";")) != 0)
		str = StringByKey("ylimits", options, "=", ";")
		x0 = str2num(StringFromList(0, str, ","))
		x1 = str2num(StringFromList(1, str, ","))
		x2 = str2num(StringFromList(2, str, ","))
		if ((numtype(x0) != 0) ||(numtype(x1) != 0)||(numtype(x2) != 0))
			print "WARNING: did not recognize the ylimits specified. Ignoring."
		else
			miny = x0
			maxy = x1
			ny = x2
		endif
	endif
	if (strlen(StringByKey("zlimits", options, "=", ";")) != 0)
		str = StringByKey("zlimits", options, "=", ";")
		x0 = str2num(StringFromList(0, str, ","))
		x1 = str2num(StringFromList(1, str, ","))
		x2 = str2num(StringFromList(2, str, ","))
		if ((numtype(x0) != 0) ||(numtype(x1) != 0)||(numtype(x2) != 0))
			print "WARNING: did not recognize the zlimits specified. Ignoring."
		else
			minz = x0
			maxz = x1
			nz = x2
		endif
	endif
	
	
	Make/O/N=(nx, ny, nz) w_cube = NaN
	SetScale/I x, minx, maxx, "kx", w_cube
	SetScale/I y, miny, maxy, "ky", w_cube
	SetScale/I z, minz, maxz, "kz", w_cube

	Variable idx
	For(vx = 0; vx < DimSize(wbxsf, 0); vx += 1)
	For(vy = 0; vy < DimSize(wbxsf, 1); vy += 1)
	For(vz = 0; vz < DimSize(wbxsf, 2); vz += 1)
		wv_tmp[0][0] = utils_pnt2x(wbxsf, vx)
		wv_tmp[1][0] = utils_pnt2y(wbxsf, vy)
		wv_tmp[2][0] = utils_pnt2z(wbxsf, vz)
		MatrixMultiply w_cube2bxsf_tmp, wv_tmp
		WAVE M_product
		w_cube4col[idx][0,2] = M_product[q][0]
		w_cube4col[idx][3] = wbxsf[vx][vy][vz][band]
		idx += 1
	EndFor
	EndFor
	EndFor
	
	// 2. make w_cube
	Make/O/N=(DimSize(wbxsf, 0), DimSize(wbxsf, 1), DimSize(wbxsf, 2)) w_bxsf_tmp
	w_bxsf_tmp = wbxsf[p][q][r][band]
	String fillBZ = StringByKey("fillBZ", options, "=", ";")
	w_cube[][][] = interp_bxsf(x, y, z, w_bxsf2cube_tmp, w_bxsf_tmp, fillBZ)
	
	wnote += "BandNumber="+num2istr(band)+"\r"
	wnote = ReplaceStringByKey("WaveFormat", wnote, "cube", "=", "\r")
	sprintf wnote, "%sSampling=%d,%d,%d\r", wnote, nx, ny, nz
	sprintf wnote, "%sXLimits=%f,%f\r", wnote, minx, maxx
	sprintf wnote, "%sYLimits=%f,%f\r", wnote, miny, maxy
	sprintf wnote, "%sZLimits=%f,%f\r", wnote, minz, maxz
	sprintf wnote, "%sFillBZMode=%s\r", wnote, fillBZ
	Note/K w_cube, wnote
	
	wnote = ReplaceStringByKey("WaveFormat", wnote, "cube4col", "=", "\r")
	Note/K w_cube4col, wnote
	
	KillWaves/Z w_bxsf_tmp, wv_tmp, w_bxsf2cube_tmp, w_cube2bxsf_tmp, M_product, w_vec_tmp
End



// Returns a ";" separated string list of numbers of all band that cross EF. If none 
// cross EF, returns an empty string.
//
// Parameters:
// 	wbxsf		a bxsf wave as loaded by fileloader_loadBxsf(). wbxsf is a 4D wave with the
//				dimensions (in that order) kx, ky, kz, bandNumber
// Optional Parameters:
//	EF			The Fermi energy to use. If not given, the Fermi energy that was supplied by the 
//				Metainfo (Wave Note) of the wbxsf wave is used.
//	separator	the list separator to use. Defaults to ";".
Function/S lda_bxsfCrossesEF(wbxsf, [EF, separator])
	WAVE wbxsf
	Variable EF
	String separator
	if (ParamIsDefault(separator))
		separator = ";"
	endif
	if(ParamIsDefault(EF))
		String wnote = note(wbxsf)
		EF = NumberByKey("FermiEnergy", wnote, "=", "\r")
		EF = (numtype(EF) == 0) ? EF : 0
	endif
	String ret = ""
	Variable i
	Make/O/N=(DimSize(wbxsf, 0), DimSize(wbxsf, 1), DimSize(wbxsf, 2)) w_bxsf_tmp
	For(i=0; i < DimSize(wbxsf, 3); i += 1)
		w_bxsf_tmp = wbxsf[p][q][r][i]
		WaveStats/Q w_bxsf_tmp
		if ((V_max > EF) && (V_min < EF))
			if (strlen(ret) > 0)
				ret += separator
			endif
			ret += num2istr(i)
		endif
	EndFor
	KillWaves/Z w_bxsf_tmp
	return ret
End




// Calls lda_bxsf2cube for all bands, and writes the cube and cube4col for each band 
// to a wave name specified by cubeprefix and cube4colprefix, respectively. 
//
// Parameters:
// 	wbxsf		a bxsf wave as loaded by fileloader_loadBxsf(). wbxsf is a 4D wave with the
//				dimensions (in that order) kx, ky, kz, bandNumber
// Optional Parameters:
//	EF			The Fermi energy to use. If not given, the Fermi energy that was supplied by the 
//				Metainfo (Wave Note) of the wbxsf wave is used.
//	FSOnly		If set to 1, only bands that cross EF will be considered. Defaults to 1. See also
//				lda_bxsfCrossesEF().
//	options		A list of options. These are passed on to lda_bxsf2cube(..., options=options)
// 	cubeprefix	the prefix to use for the individual waves generated for each band. If not given,
//				the default is "<bxsfName>_cube_b", where bxsfName is the name of the bxsf
//				wave supplied. The band index is appended.
// 	cube4colprefix	the prefix to use for the individual waves generated for each band. If not given,
//				the default is "<bxsfName>_cube4col_b", where bxsfName is the name of the bxsf
//				wave supplied. The band index is appended.
Function lda_bxsf2cubeAll(wbxsf, [FSonly, EF, options, cubeprefix, cube4colprefix])
	WAVE wbxsf
	Variable FSonly
	Variable EF
	String options
	String cubeprefix
	String cube4colprefix
	
	if(ParamIsDefault(cubeprefix))
		cubeprefix = NameOfWave(wbxsf) + "_cube_b"
	endif
	
	if(ParamIsDefault(cube4colprefix))
		cube4colprefix = NameOfWave(wbxsf) + "_cube4col_b"
	endif

	if(ParamIsDefault(FSonly))
		FSonly = 1
	endif
	String bands = ""
	if(FSonly)
		if(ParamIsDefault(EF))
			bands = lda_bxsfCrossesEF(wbxsf)
		else
			bands = lda_bxsfCrossesEF(wbxsf, EF=EF)
		endif
	else
		Variable i
		for(i=0; i < DimSize(wbxsf, 4); i += 1)
			bands = AddListItem(num2istr(i), bands)
		endfor
	endif
	for(i = 0; i < ItemsInList(bands); i+= 1)
		Variable bandNum = str2num(StringFromList(i, bands))
		if(ParamIsDefault(options))
			lda_bxsf2cube(wbxsf, bandNum)
		else
			lda_bxsf2cube(wbxsf, bandNum, options=options)
		endif
		WAVE w_cube
		WAVE w_cube4col
		String wname
		sprintf wname, "%s%02d", cubeprefix, bandNum
		Duplicate/O w_cube, $wname; KillWaves/Z w_cube
		sprintf wname, "%s%02d", cube4colprefix, bandNum
		Duplicate/O w_cube4col, $wname; KillWaves/Z w_cube4col

	endfor
End




// Initializes and creates a Gizmo to display the bands in their full glory.
Function lda_gizmoInit()
	Execute "NewGizmo"
	Execute "AppendToGizmo/D Axes=BoxAxes, name=axes0"
//	Execute "ModifyGizmo opName=enableBlend, operation=enable, data=\"GL_BLEND\""
//	Execute "AppendToGizmo/D attribute blendFunc={\"GL_SRC_ALPHA\", \"GL_ONE_MINUS_SRC_ALPHA\"}"
	Execute "ModifyGizmo opName=enableLighting, operation=enable, data=\"GL_LIGHTING\""
	Execute "ModifyGizmo opName=enableLight0, operation=enable, data=\"GL_LIGHT0\""
	Execute "AppendToGizmo/D light=Directional, name=light0"
	Execute "ModifyGizmo modifyObject=light0, property={ambient,0.3,0.3,0.3,1.0}"
	Execute "ModifyGizmo opName=enableLight1, operation=enable, data=\"GL_LIGHT1\""

End


// Appends the ";" separated string list of cube wave names to the top Gizmo.
//
// Parameters:
// 	cubeList		";" separated string list of cube wave names
// Optional Parameters:
// 	EFList		if supplied, it should be a ";" separated string list of Fermi Energy values for
//				each cube wave given in cubeList. Must have the same number of elements 
//				as cubeList.
//	colorRGBList		A ";" separated list of "," separated triples, specifying R, G, and B 
//				values for the cube waves specified by cubeList. Must have the same number 
//				of elements as cubeList. Example: suppose you have two cube wave names
//				specified in cubeList. Then colorRGBList could look like this:
//				"0,0.5,1;1,0,0.2" Note that the R, G, and B components are floating point numbers,
//				ranging from 0 to 1.
//				If not given, colorRGBList defaults to rainbow colors, i.e. colors taken from the 
//				Rainbow Igor ColorTable.
//	alphaList	A ";" separated list of alpha blending values for each cube wave given in
//				cubeList.  Must have the same number of elements as cubeList. Alpha
//				values range from 0 to 1, where 0 means completely transparent (invisible) and
//				1 completely opaque.
//				If not given, defaults to 0.3 for all given cube waves.
Function lda_gizmoFS(cubeList, [EFList, colorRGBList, alphaList])
	String cubeList
	String EFList
	String colorRGBList
	String alphaList
	
	Variable nCubes = ItemsInList(cubeList)
	Variable i
	
	if(ParamIsDefault(alphaList))
		alphaList = ""
		for(i=0; i < nCubes; i += 1)
			alphaList = AddListItem("0.3", alphaList) // make it semitransparent by default
		endfor
	endif
	
	if(ParamIsDefault(colorRGBList))
		colorRGBList = ""
		ColorTab2Wave Rainbow
		WAVE M_colors
		for(i=0; i < nCubes; i += 1)
			String str
			Variable j = i / nCubes * DimSize(M_colors, 0)
			sprintf str, "%e,%e,%e", M_colors[j][0]/65535, M_colors[j][1]/65535, M_colors[j][2]/65535
			colorRGBList = AddListItem(str, colorRGBList) // make it semitransparent by default
		endfor
	endif
	
	if(ParamIsDefault(EFList))
		EFList = ""
		for(i = 0; i < nCubes; i += 1)
			WAVE w = $(StringFromList(i, cubeList))
			String wnote = note(w)
			EFList = AddListItem(StringByKey("FermiEnergy", wnote, "=", "\r"), EFList)
		endfor
	endif
	
	for(i = 0; i < nCubes; i += 1)
		String cube = StringFromList(i, cubeList)
		Variable EF = str2num(StringFromList(i, EFlist))
		Variable r0 = str2num(StringFromList(0, StringFromList(i, colorRGBList), ","))
		Variable g0 = str2num(StringFromList(1, StringFromList(i, colorRGBList), ","))
		Variable b0 = str2num(StringFromList(2, StringFromList(i, colorRGBList), ","))
		Variable alpha = str2num(StringFromList(i, alphaList))
		String cmd
		sprintf cmd, "AppendToGizmo/D isosurface=%s, name=iso_%s", cube, cube
		Execute cmd
		sprintf cmd, "ModifyGizmo modifyObject=iso_%s, property={surfaceColorType,1}", cube
		Execute cmd
		sprintf cmd, "ModifyGizmo modifyObject=iso_%s, property={fillMode,2}", cube
		Execute cmd
		sprintf cmd, "ModifyGizmo modifyObject=iso_%s, property={frontColor,%e,%e,%e,%e}", cube, r0, g0, b0, alpha
		Execute cmd
		sprintf cmd, "ModifyGizmo modifyObject=iso_%s, property={backColor,%e,%e,%e,%e}", cube, r0, g0, b0, alpha
		Execute cmd
		sprintf cmd, "ModifyGizmo modifyObject=iso_%s, property={isovalue,%e}", cube, EF
		Execute cmd
		sprintf cmd, "ModifyGizmo modifyObject=iso_%s, property={calcNormals,1}", cube
		Execute cmd
	endfor
End
