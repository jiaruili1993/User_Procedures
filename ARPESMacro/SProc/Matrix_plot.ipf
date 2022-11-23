#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function matrix_plot(m,n,spacem,spacen,xmin,xmax,ymin,ymax)
//this function create a matrix plot of m x n images (m raws, n columns)
//the space between these images are spacem and spacen
//the axis range are (xmin,xmax) and (ymin,ymax)
variable m,n,spacem,spacen,xmin,xmax,ymin,ymax
variable indexm,indexn
string xaxisname,yaxisname,mirror_xaxisname,mirror_yaxisname
display

for(indexm=0;indexm<m;indexm+=1)
	for(indexn=0;indexn<n;indexn+=1)
		xaxisname="xaxis_r"+num2str(indexm)+"c"+num2str(indexn)
		yaxisname="yaxis_r"+num2str(indexm)+"c"+num2str(indexn)
		mirror_xaxisname="mirror_"+xaxisname
		mirror_yaxisname="mirror_"+yaxisname
		
		newfreeaxis/B $xaxisname
		newfreeaxis/L $yaxisname
		newfreeaxis/T $mirror_xaxisname
		newfreeaxis/R $mirror_yaxisname
		
				
		SetAxis $xaxisname xmin,xmax
		SetAxis $yaxisname ymin,ymax

		ModifyFreeAxis $mirror_xaxisName, master=$xaxisname
		ModifyFreeAxis $mirror_yaxisName, master=$yaxisname

		
		ModifyGraph freePos($xaxisname)={ymin,$yaxisname},freePos($yaxisname)={xmin,$xaxisname}
		ModifyGraph freePos($mirror_xaxisname)={ymax,$yaxisname}, freePos($mirror_yaxisname)={xmax,$xaxisname}
		ModifyGraph axisEnab($xaxisname)={indexn/n,(indexn+1-spacen)/n}
		ModifyGraph axisEnab($mirror_xaxisname)={indexn/n,(indexn+1-spacen)/n}
		ModifyGraph axisEnab($yaxisname)={1- (indexm+1-spacem)/m, 1- indexm/m}
		ModifyGraph axisEnab($mirror_yaxisname)={1- (indexm+1-spacem)/m, 1- indexm/m}
		ModifyGraph noLabel($xaxisname)=1
		ModifyGraph noLabel($yaxisname)=1
		ModifyGraph noLabel($mirror_xaxisname)=2
		ModifyGraph noLabel($mirror_yaxisname)=2
		ModifyGraph tick($mirror_xaxisname)=3
		ModifyGraph tick($mirror_yaxisname)=3
endfor
endfor

end