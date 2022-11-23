#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function returnsum(edc,pl)
	wave edc
	string pl
	
	duplicate/o edc tempedc,tempedc2
	tempedc = (edc[p]-3.777)*(x^2)
	tempedc2-=3.777
	return sqrt(sum(tempedc,-0.8,0.8)/sum(tempedc2,-0.8,0.8))
	//return sum(edc)//,-0.2,0.1)
end

function devide(edc,dev)
	wave edc
	string dev
	
	wave devedc = $dev
	edc/=devedc(x)
	//return sum(edc)//,-0.2,0.1)
end
