#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


//
//<h3>Nonequilibrium lattice-driven dynamics of stripes in nickelates using time-resolved x-ray scattering</h3>
//	<p><span class="descriptor">W. S. Lee, Y. F. Kung, B. Moritz, G. Coslovich, R. A. Kaindl, Y. D. Chuang, R. G. Moore, D. H. Lu, P. S. Kirchmann, J. S. Robinson, M. P. Minitti, G. Dakovski, W. F. Schlotter, J. J. Turner, S. Gerber, T. Sasagawa, Z. Hussain, <b>Z. X. Shen</b>, and T. P. Devereaux</span><br/><i>Physical Review B</i> <b>95</b>, 121105R(2017)</p>
//<hr/>

Function publication_file()
	Variable refNum
	String author, author2, title, journal, hold

	// Open file for read.
	Open/R/Z=2 refNum as ""

	// Store results from Open in a safe place.
	Variable err = V_flag
	String fullPath = S_fileName
	
	make/T/n=1000/o pub_wave
	
	variable index=0
	
	do
		author = ""
		FReadLine refNum, author
		author=replacestring("Z.-X. Shen", author, "<b>Z.-X. Shen</b>")
		author= replacestring("Z.X. Shen", author, "<b>Z.-X. Shen</b>")
		author= replacestring("Z. X. Shen", author, "<b>Z.-X. Shen</b>")
		author= replacestring("Z. -X. Shen", author, "<b>Z.-X. Shen</b>")
		author= replacestring("Z.X.Shen", author, "<b>Z.-X. Shen</b>")
		
		FReadLine refNum, title	
		FReadLine refNum, journal
		FReadLine refNum, hold
		hold = ""
		hold+="<h3>"+ReplaceString("\r", title, "")+"</h3>\r<p><span class=\"descriptor\">"
		hold+=ReplaceString("\r",author[4,inf] , "")
		hold+="</span><br/><i>"+ReplaceString("\r", journal, "")+"</p>"+"\r<hr/>\r"


		pub_wave[index]=hold
		index+=1
	while(strlen(author)!=0)
	close refNum
	
	Open/Z=2 refNum as ""
	variable index2
	for(index2=index-1;index2>-1;index2-=1)
		fprintf refNum, pub_wave[index2]
	endfor

	Close refNum
	
	
	
	
	
	return 0
End