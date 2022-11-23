#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


function rescale_edcs()
	variable i
	for (i=0;i<60;i+=1)
		string index
		sprintf index, "%03d", i
		string line_cut_path = "root:rawData:NNO_emap_"+index+"_energy"
		string energyline_cut_path = "root:rawData:NNO_emap_"+index+"_intensity"
		wave line_cut = $line_cut_path
		wave energyline_cut = $energyline_cut_path
		if (waveexists(line_cut))
			print index
			SetScale/p x energyline_cut[0],-0.00584,"", line_cut
		endif
	endfor
	print "done"
end

function reverse_edcs()
	variable i
	for (i=0;i<1000;i+=1)
		string index
		sprintf index, "%03d", i
		string line_cut_path = "root:rawData:NNO_emap"+index+"_energy"
		wave line_cut = $line_cut_path
		if (waveexists(line_cut))
			print index 
			Reverse/DIM=-1 line_cut
		endif
	endfor
end