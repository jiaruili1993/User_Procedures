#pragma rtGlobals=3		// Use modern global access method and strict wave access.


function quickbatch()
//this function gets the center of mass for every spectrum selected in the data browser.
	variable index
	variable norm_value
	variable npnts
	wave tem
	
	variable imgindex
	variable tstart=0
	variable tend=-1
	
	for(imgindex=0;imgindex<10;imgindex+=1)
		
		wave spectrum=$(getbrowserselection(imgindex*20+1))
		tstart=tend+1
		tend+=numpnts(spectrum)
		duplicate/R=[tstart,tend] Tem $("Tem"+num2str(imgindex))
		display
		for(index=0;index<20;index+=1)
			wave spectrum=$(getbrowserselection(imgindex*20+index))
			npnts=numpnts(spectrum)
			norm_value=spectrum[npnts-1]
			spectrum/=norm_value
			appendtograph spectrum vs $("Tem"+num2str(imgindex))
		endfor
	
	endfor
end

ModifyGraph width=216,height=108
ModifyGraph lstyle(Tc)=2,rgb(Tc)=(0,0,0)


function quickbatch2()
	variable index=0
	wave W_coef
	make/o/n=20 Ef=NaN
	do
	
			wave spectrum=$(getbrowserselection(index))
			FuncFit/Q/H="10111" Photonenergy_drift W_coef spectrum[278,404]
			 Ef[index]=W_coef[1]
			index+=1
	while(strlen(getbrowserselection(index))!=0)
end