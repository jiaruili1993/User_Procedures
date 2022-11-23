#pragma rtGlobals=3		// Use modern global access method and strict wave access.


Function read_color_bar(color_bar, xfrom, xto)
	wave color_bar
	variable xfrom, xto
	
	variable length = dimsize(color_bar,0)
	variable width = dimsize(color_bar,1)
	
	
	make/o/n=(length)  colorbar_R, colorbar_G, colorbar_B, colorbar_x
	make/o/n=(10*length)  colorbar_RL, colorbar_GL, colorbar_BL, colorbar_xL
	
	make/o/n=(length, width) colorbar_R2D, colorbar_G2D, colorbar_B2D
	
	
	
	
	setscale/I x, xfrom, xto, colorbar_R, colorbar_G, colorbar_B, colorbar_x, colorbar_R2D, colorbar_G2D, colorbar_B2D
	
	setscale/I x, xfrom, xto, colorbar_RL, colorbar_GL, colorbar_BL, colorbar_xL
	
	variable mid = round(width/2)
	
	colorbar_R = color_bar[p][mid][0]
	colorbar_G = color_bar[p][mid][1]
	colorbar_B = color_bar[p][mid][2]
	colorbar_x = x
	
	colorbar_R2D = color_bar[p][q][0]
	colorbar_G2D = color_bar[p][q][1]
	colorbar_B2D = color_bar[p][q][2]
	
	colorbar_RL=interp(x, colorbar_x, colorbar_R)
	colorbar_GL=interp(x, colorbar_x, colorbar_G)
	colorbar_BL=interp(x, colorbar_x, colorbar_B)
	colorbar_xL = x
	
	
end

Function image2x(image,colorbar, xfrom, xto)
	wave image
	wave colorbar
	variable xfrom, xto
	
	read_color_bar(colorbar, xfrom, xto)
	wave colorbar_RL, colorbar_GL, colorbar_BL, colorbar_xL
	
	variable xsize = dimsize(image, 0)
	variable ysize = dimsize(image,1)
	
	make/o/n=(xsize, ysize) image_value, color_error
	
	variable xindex, yindex, colorindex
	variable color_distance_min, color_distance_min_index
	variable color_distance
	variable pixel_r, pixel_g, pixel_b
	
	for(xindex=0; xindex<xsize; xindex+=1)
		for(yindex = 0; yindex<ysize; yindex+=1)

			
			pixel_r =  image[xindex][yindex][0]
			pixel_g =  image[xindex][yindex][1]
			pixel_b =  image[xindex][yindex][2]
			
			color_distance_min=pixel_r^2+pixel_g^2+pixel_b^2
			color_distance_min_index=NaN
			
			for(colorindex=0; colorindex<dimsize(colorbar_xL,0); colorindex+=1)
				color_distance =  (pixel_r-colorbar_RL[colorindex])^2
				color_distance +=  (pixel_g-colorbar_GL[colorindex])^2
				color_distance +=  (pixel_b-colorbar_BL[colorindex])^2
				
				if(color_distance<color_distance_min)
					color_distance_min = color_distance
					color_distance_min_index = colorindex
				endif
			endfor
			if(numtype(color_distance_min_index)!=2)
				image_value[xindex][yindex]=colorbar_xL[color_distance_min_index]
				color_error[xindex][yindex]=color_distance_min
			else
				image_value[xindex][yindex]=NaN
				color_error[xindex][yindex]=color_distance_min
			endif
		endfor
	endfor
end

make/o/n=40 unitcell_norm_histo
setscale/I x, 0,2,unitcell_norm_histo
histogram/B={0,0.2,40} gap_unitcell_norm,gap_unitcell_norm_histo



setscale/I x, 0, 400, gap_024
setscale/I y, 0, 400, gap_024

print 400/3.84

make/o/n= (104,104) gap_unitcell






Function unit_cell_average(reduced_cut,original_cut)

	wave reduced_cut
	wave original_cut
	
	variable a = 3.84/sqrt(2)
	
	make/o/n=(dimsize(reduced_cut,0),dimsize(original_cut, 1)) temp_cut_unique
	make/o/n=(dimsize(original_cut,0)) temp_DC_unique
	setscale/P x, dimoffset(original_cut, 0),dimdelta(original_cut, 0), temp_DC_unique
	
	variable index
	for(index=0;index<dimsize(original_cut, 1);index+=1)
		temp_DC_unique=original_cut[p][index]
		temp_cut_unique[][index]=area(temp_DC_unique,a*p,a*(p+1))
	endfor
	
	
	make/o/n=(dimsize(original_cut,1)) temp_DC_unique
	setscale/P x, dimoffset(original_cut, 1),dimdelta(original_cut, 1), temp_DC_unique
	
	for(index=0;index<dimsize(reduced_cut, 0);index+=1)
		temp_DC_unique=temp_cut_unique[index][p]
		reduced_cut[index][]=area(temp_DC_unique,a*q,a*(q+1))
	endfor
	
	
	reduced_cut/=a^2
	killwaves temp_cut_unique, temp_DC_unique
End