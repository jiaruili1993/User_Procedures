#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function dip_subtraction(lowT,highT_name)	
	wave lowT
	string highT_name
	
	wave highT=$highT_name
	string newname="dip_"+nameofwave(lowT)
	duplicate/o lowT $newname
	wave dipwave=$newname
	
	dipwave=lowT[p]-highT[p]
end

function dip_area(dipwave,pl)
	wave dipwave
	string pl
	
	duplicate/o dipwave,tempwave
	tempwave=(dipwave[p]>0)?(0):(dipwave[p])
	wavestats/q/R=(-0.2,-0.001) dipwave
	variable gapedge=V_maxloc
	return -1*area(tempwave,-0.2,gapedge)
end

make/o/n=8 dipsw_g0_5gap_dep,gap
gap=5*p+5
