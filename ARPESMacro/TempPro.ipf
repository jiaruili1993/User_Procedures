#pragma rtGlobals=1		// Use modern global access method.


Function Calself()

	Wave test,test1
	
	variable index,E
	do
		E=leftx(test)+deltax(test)*index
		
		test1=3*(1-1/(exp((x-0)/8.617385e-5/50)+1)+0.2)/(E-0.05-x)+(1/(exp((x-0)/8.617385e-5/50)+1)+0.2)/(E+0.05-x)
		test1=(numtype(test1)==1)?(0):(test1)
		Integrate test1 /D=test1
		test[index]=test1[inf]
		index+=1
	while (index<numpnts(test))
	
End

Function LoadLDA()
	Variable refnum
	Open /D/R refnum
	open /R refnum as S_fileName
	
	newDAtafolder /o/s root:band
	
	String readline,Basename
	
	display

	Variable index=0
	Variable kindex
	variable kx,ky,kz,E,k
	do
		FReadLine refNum, readline
		if (strlen(readline)==0)
			break
		endif
		if (stringmatch(readline,"*bandindex:*"))
			kindex=0
			
			
			
			Basename="Band"+num2str(index)
			Make /o/n=0 $(Basename+"_E")
			Make /o/n=0 $(Basename+"_kx")
			Make /o/n=0 $(Basename+"_ky")
			Make /o/n=0 $(Basename+"_kz")
			Make /o/n=0 $(basename+"_k")
			
			Wave w_E= $(Basename+"_E")
			Wave w_kx=$(Basename+"_kx")
			Wave w_ky=$(Basename+"_ky")
			Wave w_kz=$(Basename+"_kz")
			Wave w_k=$(Basename+"_k")
			
			appendtograph w_E vs w_k
			
			index+=1
		else
			InsertPoints  inf, 1, w_E,w_kx,w_ky,w_kz,w_k
			sscanf readline, "%g\t%g\t%g\t%g\t%g\r" ,kx,ky,kz,k,E
			w_E[kindex]=E
			w_kx[kindex]=kx
			w_ky[kindex]=ky
			w_kz[kindex]=kz
			w_k[kindex]=k
			Kindex+=1
		endif
		
		
	while (1)
	
	SetDrawLayer UserFront
	
	SetDrawEnv xcoord= bottom,ycoord= prel
	DrawLine 0.41156,0,0.41156,1
	SetDrawEnv xcoord= bottom,ycoord= prel
	DrawLine 0.82312,0,0.82312,1
	SetDrawEnv xcoord= bottom,ycoord= prel
	DrawLine 1.40516,0,1.40516,1
	SetDrawEnv xcoord= bottom,ycoord= prel
	DrawLine 1.99897,0,1.99897,1
	SetDrawEnv xcoord= bottom,ycoord= prel
	DrawLine 2.41054,0,2.41054,1
	SetDrawEnv xcoord= bottom,ycoord= prel
	DrawLine 2.83860,0,2.83860,1
	SetDrawEnv xcoord= prel,ycoord= left
	DrawLine 0,0,1,0
	close refnum
End


Function gapfit(cof,x):FitFunc
wave cof
Variable x
Wave kx_I

Variable temp1,temp2

temp1=cof[0]*cos(kx_I(x)/1.1363*pi)
temp2=cof[1]*cos((x/0.4742)*pi)

return temp1+temp2

End


Function displaypolgap(Cuta)
Wave CutA
Variable index=dimsize(cuta,0)
make /n=(index) gap_px
make /n=(index) gap_py
cutA[][4]=cutA[p][3]*cos(cutA[p][2]/180*pi)
cutA[][5]=cutA[p][3]*sin(cutA[p][2]/180*pi)
gap_px[]=CutA[p][4]
gap_py[]=CutA[p][5]
display gap_py vs gap_px

End



Function shortwavename(Snum)
Variable Snum
String WaveN,newN
String df=Getdatafolder(1)
Variable index=0
do
WaveN=GetindexedObjName(DF,1,index)
if (strlen(waveN)==0)
break
endif
Wave data=$WaveN
WaveN=nameofwave(data)
newN="root:"+WaveN[Snum,inf]
duplicate /o data,$newN
index+=1
while (1)
End


Function JoinMultWave1(JWave)
Wave Jwave
String DF=GetDatafolder(1)
Variable index=0
String WaveN
do
WaveN=GetindexedObjName(DF,1,index)
Wave Point=$WaveN
Jwave[index]=Point[0]
index+=1
while (index<numpnts(Jwave))
End


Function WaveSetSet(Wave1,Waveset)
Wave wave1
Wave/T waveset

Variable index=0

do 
Wave Data=$Waveset[index]
Wave1[][index]=data[p]
index+=1
while (index<(numpnts(Waveset)))

End

Function WavesetNormMDC(Waveset1, Waveset2)
Wave /T Waveset1
Wave /T Waveset2

Variable index=0

do 
Wave Data=$Waveset1[index]
Wave NMDC=$Waveset2[index]
Data*=NMDC[p]
index+=1
while (index<(numpnts(Waveset1)))
End



Function WavesetCal(Waveset,NormW)
Wave /T Waveset
Wave NormW
Variable index=0

do 
Wave Data=$Waveset[index]
Data*=NormW[index]
index+=1
while (index<(numpnts(Waveset)))
End


Function MakemovieCutCT()
String DF=Getdatafolder(1)
String Wlist,Wname,Wnote,TextL,Tlist,Tname,Tname1

Variable index=2,Wnum,Tem,Tnum

//Wlist=Wavelist("*",";","")
//Wnum=itemsinlist(Wlist,";")
Tlist=TraceNameList("",";",1)
Tnum=itemsinlist(Tlist,";")

Wave PeakArea=PeakAreaALL
Wave PeakX=PeakAreaX0
Wave MovieT=MovieT
Wave MovieI=MovieI

//display 
//Appendimage $Wname
//SetAxis left -0.16,0.03
//SetAxis bottom -0.6,1.45

//ModifyGraph width=283.465,height=113.386
//ModifyGraph manTick(left)={0,50,-3,0},manMinor(left)={1,0}
//ModifyGraph manTick(bottom)={0,0.5,0,1},manMinor(bottom)={1,0}
//ModifyGraph zero(left)=4
//Label left "\\u#2E-E\\BF \\M(meV)"
//Label bottom "\F'Arial'k\B//\M(Å\S-1\M)"
//TextBox/C/N=text0 

NewMovie /F=1 /O  /Z/L/I as "myMovie.mov"
ModifyGraph marker(MovieI)=17,rgb(MovieI)=(0,0,65280)
	index=0
	do
		MovieI=PeakArea[index]
       MovieT=PeakX[index]
        
		DoUpdate
		AddMovieFrame
		//Wname=Stringfromlist(index,Wlist,";")
		Tname=Stringfromlist(index,Tlist,";")
	//	Wnote=note($Wname)
      // Tem=Numberbykey("SampleTemperature",Wnote,"=","\r")
     //  TextL="\Z18"+num2str(Tem)+" K"
	//   TextBox/C/N=text0/F=0/A=LT/X=2/Y=4 TextL
	//	duplicate /o $Wname,root:MovieCut
	//	print Tname
		ModifyGraph rgb($Tname)=(0,0,0)
		ModifyGraph lsize($Tname)=1
		Tname=Stringfromlist((index+1),Tlist,";")
		ModifyGraph lsize($Tname)=2;DelayUpdate
        ModifyGraph rgb($Tname)=(0,0,65280)
      
		index+=1
	while (index < (12) )
	
	//index-=1
	ModifyGraph marker(MovieI)=16,rgb(MovieI)=(65280,0,0)
	ModifyGraph rgb($Tname)=(65280,0,0)
	do
		MovieI=PeakArea[index]
       MovieT=PeakX[index]
        
		DoUpdate
		AddMovieFrame
		//Wname=Stringfromlist(index,Wlist,";")
		Tname=Stringfromlist(index,Tlist,";")
	//	Wnote=note($Wname)
      // Tem=Numberbykey("SampleTemperature",Wnote,"=","\r")
     //  TextL="\Z18"+num2str(Tem)+" K"
	//   TextBox/C/N=text0/F=0/A=LT/X=2/Y=4 TextL
	//	duplicate /o $Wname,root:MovieCut
	//	print Tname
		ModifyGraph rgb($Tname)=(0,0,0)
		ModifyGraph lsize($Tname)=1
		Tname=Stringfromlist((index+1),Tlist,";")
		ModifyGraph lsize($Tname)=2;DelayUpdate
        ModifyGraph rgb($Tname)=(65280,0,0)
      
		index+=1
	while (index <20 )

CloseMovie
Setdatafolder $DF
end

Function MakemovieCutT1()
String DF=Getdatafolder(1)
String Wlist,Wname,Wnote,TextL,Tlist,Tname,Tname1

Variable index=2,Wnum,Tem,Tnum

Wlist=Wavelist("*",";","")
Wnum=itemsinlist(Wlist,";")
Tlist=TraceNameList("",";",1)
Tnum=itemsinlist(Tlist,";")

//display 
//Appendimage $Wname
//SetAxis left -0.16,0.03
//SetAxis bottom -0.6,1.45

//ModifyGraph width=283.465,height=113.386
//ModifyGraph manTick(left)={0,50,-3,0},manMinor(left)={1,0}
//ModifyGraph manTick(bottom)={0,0.5,0,1},manMinor(bottom)={1,0}
//ModifyGraph zero(left)=4
//Label left "\\u#2E-E\\BF \\M(meV)"
//Label bottom "\F'Arial'k\B//\M(Å\S-1\M)"
//TextBox/C/N=text0 

NewMovie /F=1 /O  /Z/L/I as "myMovie.mov" 
	index=0
	do
		Wname=Stringfromlist(index,Wlist,";")
		Tname=Stringfromlist(index,Tlist,";")
		Tname1=Stringfromlist(index+8,Tlist,";")
		Wnote=note($Wname)
       Tem=Numberbykey("SampleTemperature",Wnote,"=","\r")
       TextL="\Z18"+num2str(Tem)+" K"
	   TextBox/C/N=text0/F=0/A=LT/X=5/Y=85 TextL
		duplicate /o $Wname,root:MovieCut
	//	print Tname
		//ModifyGraph rgb=(0,0,0)
		ModifyGraph lsize=1
		ModifyGraph lsize($Tname)=2
	    ModifyGraph lsize($Tname1)=2
       // ModifyGraph rgb($Tname)=(65280,0,0)
		DoUpdate
		AddMovieFrame
		index+=1
	while (index < (Wnum) )
	
	index-=1
	do
		Wname=Stringfromlist(index,Wlist,";")
		Tname=Stringfromlist(index,Tlist,";")
		Tname1=Stringfromlist(index+8,Tlist,";")
		Wnote=note($Wname)
       Tem=Numberbykey("SampleTemperature",Wnote,"=","\r")
       TextL="\Z18"+num2str(Tem)+" K"
	   TextBox/C/N=text0/F=0/A=LT/X=5/Y=85 TextL
		duplicate /o $Wname,root:MovieCut
	//	print Tname
		//ModifyGraph rgb=(0,0,0)
		ModifyGraph lsize=1
		ModifyGraph lsize($Tname)=2
	    ModifyGraph lsize($Tname1)=2
       // ModifyGraph rgb($Tname)=(65280,0,0)
		DoUpdate
		AddMovieFrame
		index-=1
	while (index > (-1) )
	
CloseMovie
Setdatafolder $DF
end



Function AppendGraphHCH(Name,AllNum)
String Name
Variable AllNum
display
Variable index=0
String Wname,XWname,Rname,Gname,Bname,ColorName
Variable Rmax=0,Rmin=1,Gmax=0,Gmin=1,Bmax=0,Bmin=1
colortab2wave Red
wave M_colors
//DeletePoints 0,128,M_colors
duplicate /o M_colors M_color_R
Wave M_color_R
M_color_R=M_colors[255-p][q]
killwaves /Z M_colors

colortab2wave Green
wave M_colors
//DeletePoints 0,128,M_colors
duplicate /o M_colors M_color_G
Wave M_color_G
M_color_G=M_colors[255-p][q]
killwaves /Z M_colors

colortab2wave Blue
wave M_colors
//DeletePoints 0,128,M_colors
duplicate /o M_colors M_color_B
Wave M_color_B
M_color_B=M_colors[255-p][q]
killwaves /Z M_colors

do 
XWname=Name+"_X"+num2str(index)
Wname=Name+"_Y"+num2str(index)
Rname=Name+"_R"+num2str(index)
Gname=Name+"_G"+num2str(index)
Bname=Name+"_B"+num2str(index)
Wave Ywave=$Wname
Wave Xwave=$XWname
Wave Rwave=$Rname
Wave Gwave=$Gname
Wave Bwave=$Bname
wavestats /Q/Z Rwave
if ((1-V_min)>Rmax) 
   Rmax=1-V_min
endif   
if ((1-V_max)<Rmin)
   Rmin=1-V_max
endif
wavestats /Q/Z Gwave
if ((1-V_min)>Gmax) 
   Gmax=(1-V_min)
endif   
if ((1-V_max)<Gmin)
   Gmin=(1-V_max)
endif
wavestats /Q/Z Bwave
if ((1-V_min)>Bmax) 
   Bmax=(1-V_min)
endif   
if ((1-V_max)<Bmin)
   Bmin=(1-V_max)
endif

index+=1
while (index<AllNum)

setscale /I x, Rmin,Rmax,M_color_R
setscale /I x, Gmin,Gmax,M_color_G
setscale /I x, Bmin,Bmax,M_color_B

print Rmin,Rmax,Gmin,Gmax,Bmin,Bmax

index=0
do
XWname=Name+"_X"+num2str(index)
Wname=Name+"_Y"+num2str(index)
Rname=Name+"_R"+num2str(index)
Gname=Name+"_G"+num2str(index)
Bname=Name+"_B"+num2str(index)
Wave Ywave=$Wname
Wave Xwave=$XWname
Wave Rwave=$Rname
Wave Gwave=$Gname
Wave Bwave=$Bname

Colorname="Color"+num2str(index)
duplicate /o M_color_R, $colorname
wave ColorW=$Colorname
redimension /n=(numpnts(Ywave),3) ColorW

//ColorW[][]=M_color_R[x2pnt(M_color_R,Rwave[p])][q]+M_color_B[x2pnt(M_color_B,Bwave[p])][q]+M_color_G[x2pnt(M_color_G,Gwave[p])][q]
//ColorW[][]=M_color_R[x2pnt(M_color_R,Rwave[p])][q]+M_color_B[x2pnt(M_color_B,Bwave[p])][q]
//ColorW[][]=M_color_B[x2pnt(M_color_B,(1-Bwave[p]))][q]
ColorW[][]=M_color_R[x2pnt(M_color_R,(1-Rwave[p]))][q]

Appendtograph Ywave vs Xwave
ModifyGraph zColor($nameofwave(Ywave))={$nameofwave(ColorW),*,*,directRGB,0}
index+=1
while (index<AllNum)

end


Function RotateA(th,th_off,ph,ph_off,azi)
Variable th,th_off,ph,ph_off,azi


	Variable d2r = pi/180
	th *= d2r
	ph *= d2r
	th_off*=d2r
	ph_off*=d2r
	azi *= d2r
	Make/o/n=(3,3) R1,R2,R3,Rp1,Rp2,Ra1,Ra2,Ra3,Ra4
	Make/o/n=3 k, s_angle
	
	// electron emission in lab-system
	s_angle = {0,0,1}
	// rotation to sample-system
	
	
	R1 = { {cos(azi),sin(azi),0}, {-sin(azi),cos(azi),0}, {0,0,1} }
	R2 = { {1,0,0}, {0,cos(ph),-sin(ph)}, {0,sin(ph),cos(ph)} }
	R3 = { {cos(th),0,-sin(th)}, {0,1,0}, {sin(th),0,cos(th)} }
	Rp1= { {cos(th_off),sin(th_off),0}, {-sin(th_off),cos(th_off),0}, {0,0,1} }
	Rp2= { {cos(-th_off),sin(-th_off),0}, {-sin(-th_off),cos(-th_off),0}, {0,0,1} }
	Ra1= { {cos(th_off),0,-sin(th_off)}, {0,1,0}, {sin(th_off),0,cos(th_off)} }
	Ra2= { {cos(-th_off),0,-sin(-th_off)}, {0,1,0}, {sin(-th_off),0,cos(-th_off)} }
	Ra3= { {1,0,0}, {0,cos(ph_off),-sin(ph_off)}, {0,sin(ph_off),cos(ph_off)} }
	Ra4= { {1,0,0}, {0,cos(-ph_off),-sin(-ph_off)}, {0,sin(-ph_off),cos(-ph_off)} }
	//MatrixMultiply R2,R3,s_angle
	//Wave M_product
	//MatrixMultiply R1,R2,R3,s_angle
	
	MatrixMultiply Rp2,R2,Rp1,R3,s_angle
	Wave M_product
	s_angle=M_product[p][0]
	if (1)
	MatrixMultiply Ra2,Ra4,R1,Ra3,Ra1,s_angle
	else
	MatrixMultiply R1,s_angle
	endif
	Wave M_product
	Variable ky = M_product[1][0]
	Variable kx = M_product[0][0]
	//print Kvac,Kvac*M_product[2][0]
	print kx,ky,M_product[2][0]
	KillWaves/Z  s_angle,R1,R2,R3,M_product,k
	
	
End



Function DeConvolve(Data,rel)
Wave Data
Variable rel
Variable index=0,Dindex=0
Variable w,Inter,x0,x1,xpnts
Duplicate /o Data, DestData

do 
  Make /o/n=(dimsize(Data,1)),TempEDC,DestEDC
  Setscale /P x,dimoffset(Data,1),dimdelta(data,1),TempEDC,DestEDC
  TempEDC=Data[index][p]
//Make /o/n=(numpnts(Data)),TempEDC,DestEDC
//Setscale /P x,leftx(Data),deltax(Data),TempEDC,DestEDC

  TempEDC=Data[index][p]
  Dindex=0
  do 
  w=leftx(DestEDC)+deltax(DestEDC)*Dindex
  x0=leftx(TempEDC)-10*rel
  x1=rightx(TempEDC)+10*rel
  //print w
  GenerKer(w,rel,x0,x1)
  Wave KernelW
  //xpnts=round((x1-x0)/deltax(KernelW)/2)*2+1
  make /o/n=(1000) TempSEDC
  Setscale /I x,x0,x1,TempSEDC
  TempSEDC=TempEDC(x)
  TempSEDC*=KernelW
  //Convolve /C KernelW,TempSEDC
  Inter=area(TempSEDC)
  //print inter
  DestEDC[Dindex]=pi/2^0.25*Inter
  DestEDC[Dindex]=Inter
  Dindex+=1
  while (Dindex<(numpnts(DestEDC)))
DestData[index][]=DestEDC[q]
index+=1
while (index<dimsize(Data,0))
End


Function GenerKer(w,rel,x0,x1)
Variable w,rel,x0,x1
make /o/n=1000,KernelW
Setscale /I x,x0,x1,KernelW
KernelW=Kernel(abs((w-x)/rel))
Variable NormI=area(KernelW)
KernelW/=NormI
End 




Function Kernel(x)
Variable x
Variable temp1,temp2,temp3
temp1=pi/8
temp2=exp(-2^1.25*sin(temp1)*x)
temp3=cos(2^1.25*cos(temp1)*x-pi/8)
return temp2*temp3
End








































Function SumImage(Map)
Wave Map
Variable xindex,yindex
Variable Sum1=0
xindex=0
do 
yindex=0
 do
 if (Map[xindex][yindex]>0)
  Sum1+=Map[xindex][yindex]
  endif
 yindex+=1
 while (yindex<dimsize(Map,1))
 xindex+=1
while(xindex<dimsize(Map,0))
print sum1
end

Function FitDyneEDC(Data,W_coef)
Wave Data
Wave W_coef
String DF=GetDatafolder(1)
newDatafolder /o/s root:fitSymEDC
String Wname=nameofWave(Data)
newDatafolder /o/s $Wname
Variable x0,x1
x0=leftx(Data)
x1=rightx(Data)
DyneIntConv(W_coef[8],20,deltax(Data),x0,x1)
duplicate /o W_coef W_epsilon
//W_epsilon=1e-6
Variable KB=8.617385e-5

print x0,x1
FuncFit /n/q/H="000101111" FitDyneFuncEDC W_coef Data(x0,x1) //E=w_Epsilon ///W=w_Weight
Wave DyneEDC=DyneEDC
make /o/n=(dimsize(Data,0)) FittedDyneEDC,Peak,bkg,Fermbkg,FermPeak,Ferm
Setscale /I x,x0,x1,FittedDyneEDC,Peak,Ferm,FermPeak,Fermbkg
FittedDyneEDC=DyneEDC(x)
//Variable /C E
Variable /C Gap
variable /C GGamma
//E=cmplx(x,0)
Gap=cmplx(W_Coef[1],0)
GGamma=cmplx(0,W_Coef[2])

Peak=abs(W_coef[0]*real((cmplx(x,0)-GGamma)/(sqrt((cmplx(x,0)-GGamma)*(cmplx(x,0)-GGamma)-Gap*Gap))))
bkg=W_coef[3]+W_coef[4]*x+W_coef[5]*x*x
ferm=1/(exp((x-W_coef[6])/(kB*W_coef[7]))+1)
Fermbkg=bkg*ferm
FermPeak=abs(Peak)*ferm

//Peak2=(w_coef[1]*w_coef[2]^2/4) / ((x+w_coef[0])^2+w_coef[2]^2/4)
//Ferm1=1/(exp((x-w_coef[6])/(kB*w_coef[7]))+1)
//Ferm2=1/(exp((-x-w_coef[6])/(kB*w_coef[7]))+1)
//FMBkg1=(w_coef[3]+w_coef[4]*x+w_coef[5]*x*x)*Ferm1
//FMBkg2=(w_coef[3]-w_coef[4]*x+w_coef[5]*x*x)*Ferm2
//FMPeak1=(Peak1*Ferm1)
//FMPeak2=(Peak2*Ferm2)
display;
appendtograph /C=(0,0,0) Data
Appendtograph /C=(65280,0,0) fitteddyneEDC
duplicate /o w_Coef CoefWave
print coefwave[1],coefwave[2]
SetDatafolder $DF
end



Function DyneIntConv(fwhm,res,data_dx,x0,x1)
Variable fwhm,res,data_dx,x0,x1
  
  Variable gauss_from = 10 * fwhm
  Variable dx =  min(fwhm/res, abs(data_dx/2))		// needs to be smaller than the data-width!, not really sure...
  Variable y_xfrom = x0 - 4 * fwhm
  Variable y_xto = x1 + 4 * fwhm
		
  Variable gauss_pnts = round(gauss_from/dx) * 2 + 1
  Variable y_pnts = round((y_xto-y_xfrom)/dx/2)*2+1
		
   Make/o/d/n=(gauss_pnts) Conv_gauss = 0
   Make/o/d/n=(y_pnts) DyneEDC = 0
		
		SetScale/I x y_xfrom, y_xto, DyneEDC
		SetScale/I x -gauss_from, Gauss_from, Conv_Gauss
End


Function FitDyneFuncEDC(pw,yw,xw):FitFunc
Wave pw,yw,xw
   CalDyneconvEDC(pw)
   Wave DyneEDC=DyneEDC
   yw=DyneEDC(xw[p])
End

Function CalDyneconvEDC(pw)
Wave pw
Wave DyneEDC=DyneEDC
Wave Conv_Gauss=Conv_Gauss
DyneEDC=CalDyneEDC(pw,x)
Conv_Gauss=exp(-x^2*4*ln(2)/pw[8]^2)
Variable sumGauss=sum(Conv_Gauss,-inf,inf)
Conv_Gauss/=sumGauss
Convolve /A Conv_Gauss DyneEDC
//Duplicate /o DyneEDC DyneEDCTemp,OFitEDC
//DyneEDCTemp=DyneEDC[numpnts(DyneEDC)-p-1]
//SymEDC=SymEDC[p]+SymEDCTemp[p]
End

Function CalDyneEDC(coef,x)
Wave coef
Variable x
Variable /C E
Variable /C Gap
variable /C GGamma
//Variable /C I

E=cmplx(x,0)
Gap=cmplx(Coef[1],0)
GGamma=cmplx(0,Coef[2])

Variable Peak
Variable bkg
Variable Ferm

Variable KB=8.617385e-5
Peak=coef[0]*real((E-GGamma)/(sqrt((E-GGamma)*(E-GGamma)-Gap*Gap)))
//bkg=coef[3]+coef[4]*x+coef[5]*x*x
bkg=coef[3]+coef[4]*x+coef[5]*x*x
Ferm=1//ferm=1/(exp((x-coef[6])/(kB*coef[7]))+1)
return (abs(Peak)+bkg)*ferm
End












Function ChangeColorTable(SWave,CWave)
Wave SWave,CWave
make /o/n=(dimsize(CWave,0)) RCwave,GCwave,BCwave,Xwave
Setscale /P x,dimoffset(Cwave,0),dimdelta(Cwave,0),RCwave,GCwave,BCwave,Xwave
RCwave=CWave[p][0]
GCwave=CWave[p][1]
BCwave=CWave[p][2]
Xwave=dimoffset(Cwave,0)+p*dimdelta(Cwave,0)

Make /o/n=(dimsize(Swave,0),dimsize(Swave,1),4) SwaveC
Variable Xindex=0,Yindex=0
do
 Yindex=0
 do
 SwaveC[Xindex][Yindex][0]=interp(Swave[Xindex][Yindex],Xwave,RCwave)/65535//RCwave(Swave[Xindex][Yindex])//interp(Swave[Xindex][Yindex],Xwave,RCwave)
 SwaveC[Xindex][Yindex][1]=interp(Swave[Xindex][Yindex],Xwave,GCwave)/65535//GCwave(Swave[Xindex][Yindex])//interp(Swave[Xindex][Yindex],Xwave,GCwave)
 SwaveC[Xindex][Yindex][2]=interp(Swave[Xindex][Yindex],Xwave,BCwave)/65535//BCwave(Swave[Xindex][Yindex])//interp(Swave[Xindex][Yindex],Xwave,BCwave)
 Yindex+=1
 while (Yindex<dimsize(Swave,1))
Xindex+=1
while (Xindex<dimsize(Swave,0))
SwaveC[][][3]=1
//duplicate /O Swave,RSwaveC,GSwaveC,BSwaveC
//RSwaveC=SwaveC[p][q][0]
//GSwaveC=SwaveC[p][q][1]
//BSwaveC=SwaveC[p][q][2]
killwaves /Z BCwave,RCwave,GCwave,Xwave
End













Function InterponGraph(kx0,kx1,ky0,ky1,dk)
Variable kx0,kx1,ky0,ky1,dk

String TraceList=traceNameList("",";",1)
String TraceName,XTraceName
Variable Traceindex=0
Make /o/n=(1) MaxLinex,MinLinex,MaxLiney,MinLiney
Variable TempMax,TempMin
Variable index=0,Lineindex
do
	TraceName=stringfromlist(Traceindex,TraceList,";")
	if (strlen(TraceName)<=0)
	break
	endif
	wave tracey=TraceNametoWaveRef("",TraceName),tracex=XwaveRefFromTrace("",TraceName)
	
	index=0
	Lineindex=0
	TempMax=tracey[0]
	MaxLinex[0]=tracex[0]
	MaxLiney[0]=tracey[0]
	
	do
	if (index==(numpnts(tracey)-1))
	TempMin=tracey[index-1]
			if (TempMin<TempMax)
			MinLinex[Lineindex]=tracex[index-1]
			MinLiney[Lineindex]=tracey[index-1]
			else
			MinLinex[Lineindex]=MaxLinex[Lineindex]
			MinLiney[Lineindex]=MaxLiney[Lineindex]
			MaxLinex[Lineindex]=tracex[index-1]
			MaxLiney[Lineindex]=tracey[index-1]
			endif
	else
		if (numtype(tracey[index])==2)
		TempMin=tracey[index-1]
			if (TempMin<TempMax)
			MinLinex[Lineindex]=tracex[index-1]
			MinLiney[Lineindex]=tracey[index-1]
			else
			MinLinex[Lineindex]=MaxLinex[Lineindex]
			MinLiney[Lineindex]=MaxLiney[Lineindex]
			MaxLinex[Lineindex]=tracex[index-1]
			MaxLiney[Lineindex]=tracey[index-1]
			endif
		Lineindex+=1
		insertpoints /M=0 Lineindex,1,MaxLiney,MinLiney,MaxLinex,MinLinex
		TempMax=tracey[index+1]
		MaxLinex[Lineindex]=tracex[index+1]
		MaxLiney[Lineindex]=tracey[index+1]	
	    endif
	 endif   
	index+=1
	while (index<numpnts(tracey))
Traceindex+=1
while (1)
sort MaxLinex,MaxLinex,MaxLiney
sort MinLinex,MinLinex,MinLiney

Variable kxnum=round((kx1-kx0)/dk+1)
Variable kynum=round((ky1-ky0)/dk+1)
make /o/n=((kxnum),(kynum)) InterpImage
Setscale/I x,kx0,kx1,InterpImage
Setscale/I y,ky0,ky1,InterpImage
Variable Kxindex,Kyindex
Kxindex=0
Variable TempKx,TempKy,TempMaxkx,TempMinKx,disKx,TempMaxky,TempMinky
do
Kyindex=0
 TempKx=dimoffset(InterpImage,0)+Kxindex*Dimdelta(InterpImage,0)
  Lineindex=0
 
  TempMinKx=(MinLinex[0]<MaxLinex[0])?(MinLinex[0]):(MaxLinex(0))
  TempMaxKx=(MinLinex[numpnts(MinLinex)-1]<MaxLinex[numpnts(Maxlinex)-1])?(MaxLinex[numpnts(Maxlinex)-1]):(MinLinex[numpnts(MinLinex)-1])
  if ((TempKx<TempMaxKx)&&(TempKx>TempMinKx))
  TempMaxkx=1
  TempMinKx=1
  do 
	diskx=abs(TempKx-MinLinex(Lineindex))
	if (diskx<TempMinkx)
	TempMinkx=diskx
	TempMinky=MinLiney(Lineindex)
	endif
	diskx=abs(TempKx-MaxLinex(Lineindex))
	if (diskx<TempMaxkx)
	TempMaxkx=diskx
	TempMaxky=MaxLiney(Lineindex)
	endif
 	Lineindex+=1
 	while (Lineindex<numpnts(MaxLiney))
   
   TempMaxKx=(MinLinex[numpnts(MinLinex)-1]<MaxLinex[numpnts(Maxlinex)-1])?(MaxLinex[numpnts(Maxlinex)-1]):(MinLinex[numpnts(MinLinex)-1])
   InterpImage[Kxindex][]=(y<TempMaxky&&y>TempMinKy)?(1):(0)  
  else
  InterpImage[Kxindex][]=0
  endif
// do
 //TempKy=dimoffset(InterpImage,1)+Kyindex*Dimdelta(InterpImage,1)
 //
 //Kyindex+=1
 //while (Kyindex<dimsize(InterpImage,1))
Kxindex+=1
while (Kxindex<dimsize(InterpImage,0))

display;
AppendImage InterpImage


End



Function TransLineonGraph()
String Wname=winname(0,1)
String TraceList=traceNameList("",";",1)
String TraceName,XTraceName
Variable Traceindex=0
Make /o/n=0 SumTrace,XSumTrace
do
	TraceName=stringfromlist(Traceindex,TraceList,";")
	if (strlen(TraceName)<=0)
	break
	endif
	wave tracey=TraceNametoWaveRef("",TraceName),tracex=XwaveRefFromTrace("",TraceName)
	insertPoints /M=0 0,(numpnts(tracey)+1),SumTrace,XSumTrace
	Sumtrace[1,(numpnts(tracey))]=tracey[p-1]
	XSumtrace[1,(numpnts(tracey))]=tracex[p-1]
	SumTrace[0]=Nan
	XSumTrace[0]=Nan
Traceindex+=1
while (1)
deletePoints /M=0 0,1,SumTrace,XSumTrace
Variable index=0
make /o/n=2 Kv
make /o/n=(2,2) MultM
MultM={{1,0},{0,1}}
duplicate /o SumTrace OSumTrace,XOSumTrace,TSumTrace,XTSumTrace
XOSumTrace=XSumTrace
do
	if (numtype(SumTrace[index])==2)
	TSumTrace[index]=Nan
	XTSumTrace[index]=Nan
	else
	Kv[0]=XSumTrace[index]
	Kv[1]=SumTrace[index]
	matrixmultiply MultM,Kv
	Wave M_product
	TSumTrace[index]=M_product[1][0]
	XTSumTrace[index]=M_product[0][0]
	endif
index+=1
while (index<numpnts(SumTrace))
display;
appendtograph OSumTrace vs XOSumTrace;
Appendtograph TSumTrace vs XTSumTrace;
KillWaves /Z SumTrace,XSumTrace,M_Product,Kv,MultM
End








Function CalAKWSC(dK,KMax,dE,EMax,BosonE,BosonW,BosonL,Gap,T,fwhm)
Variable dK,KMax,dE,EMax,BosonE,BosonW,BosonL,Gap,T,fwhm
Variable EDatanum=abs(Emax)/dE+1
Variable KDatanum=abs(KMax)/dK+1
String DF=GetDatafolder(1)
NewDatafolder /o/s root:SimuAKWSC
make /o/n=(KDatanum,2*EDatanum) AKW,FMAKW
Make /o/n=(2*EDatanum) FermFn
Setscale /P x,0,dK,AKW,FMAKW
Setscale /I y,-EMax,EMax,AKW,FMAKW
Setscale /I x,-EMax,EMax,FermFn

GenerateBareBandSC(dK,KMax,Gap)
Wave BandDisp
CalSelfESC(dE,EMax,BosonE,BosonW,BosonL,Gap)
Wave ImSelfE
Wave ReSelfE
Variable index=0
Variable KTemp,ETemp
Variable kB=8.617385e-5*1000
Variable res=10
Variable data_dx,x0,x1,gauss_from=10*FWHM,dx
Variable y_xfrom,y_xto,gauss_pnts,y_pnts	  
 data_dx=dimdelta(AKW,1)
 x0=M_y0(AKW)
 x1=M_y1(AKW)
 dx=min(fwhm/res,abs(data_dx/2))
 y_xfrom=x0-4*fwhm
 y_xto=x1+4*fwhm
 gauss_pnts=round(gauss_from/dx)*2+1
 y_pnts=round((y_xto-y_xfrom)/dx)
 make /o/d/n=(gauss_pnts) w_conv_gauss = 0
 Make/o/d/n=(y_pnts) convAKW = 0
 SetScale/P x y_xfrom, dx, convAKW
 SetScale/P x -gauss_from, dx, w_conv_gauss
 w_conv_gauss= exp(-x^2*4*ln(2)/fwhm^2)
 Variable sumGauss = sum(w_conv_gauss, -inf,inf)
 w_conv_gauss /= sumGauss
 FermFN=1/(exp((x-0)/KB/T)+1)
Variable/C SelfE,Z
Variable Eindex=0,TempE
do
KTemp=dimoffset(AKW,0)+index*dimdelta(AKW,0)
Etemp=BandDisp(KTemp)
//AKW[index][]=1/pi*(abs(ImselfE(y)))/((y-Etemp-ReSelfE(y))^2+ImselfE(y)^2)
//AKW[index][]=1/pi*
Eindex=0
do
TempE=dimoffset(AKW,1)+Eindex*dimdelta(AKW,1)
SelfE=cmplx(ReSelfE(TempE),ImSelfE(TempE))
Z=1-SelfE/TempE
AKW[index][Eindex]=1/pi*imag((Z*TempE+Etemp)/(Z^2*(TempE^2-gap^2)-Etemp^2))
eindex+=1
while (Eindex<dimsize(AKW,1))
FMAKW[index][]=AKW[index][q]*FermFN[q]
convAKW=FMAKW[index][x2pnt(FermFN,x)]
Convolve/A w_conv_gauss convAKW
FMAKW[index][]=convAKW((pnt2x(FermFN,q)))
index+=1
while (index<(dimsize(AKW,0)))

// KillWaves /Z w_conv_gauss,convferm
SetDatafolder $DF
End

Function GenerateBareBandSC(dK,KMax,Gap)
Variable dK,KMax,Gap
Variable KDatanum=abs(KMax)/dK+1
Make /o/n=(KDatanum) BandDisp
SetScale /P x,0,dK,BandDisp
Variable Velocity=800
BandDisp=Velocity*(x-KMax/2)//
//BandDisp=-sqrt((Velocity*(x-KMax/2))^2+gap^2)
End

//Function GenerateA2FSC(dE,EMax,BosonE,BosonW,BosonL)
//Variable dE,EMax,BosonE,BosonW,BosonL
//Variable Datanum=abs(EMax)/dE+1
//make /o/n=(Datanum) A2F
//SetScale /P x,0,dE,A2F
//A2F=(BosonL*BosonW^2/4)/((x-BosonE)^2+BosonW^2/4)
//A2F[0,18]=0
//End

Function CalSelfESC(dE,EMax,BosonE,BosonW,BosonL,Gap)
Variable dE,EMax,BosonE,BosonW,BosonL,Gap
GenerateA2F(dE,EMax,BosonE,BosonW,BosonL)
Wave A2F
Variable Datanum=abs(EMax)/dE +1
Make /o/n=(2*Datanum) ImSelfE,ReSelfE
SetScale /I x,-EMax,EMax,ImSelfE
SetScale /I x,-EMax+0.01,EMax+0.01,ReSelfE
Variable hbar=1
Variable ImSelfEConst0
Variable ImSelfEConst1=0
Variable index=0
Variable TempX,TempX1
do
TempX=abs(pnt2x(ImSelfE,index))
ImSelfEConst0=15+0.40*TempX
if (TempX<=gap)
ImSelfE[index]=0
else
if (TempX<=(Gap+BosonE))
ImSelfE[index]=ImselfEConst0*Tempx/sqrt(TempX^2-gap^2)
else
ImSelfE[index]=ImselfEConst0*Tempx/sqrt(TempX^2-gap^2)+ImselfEConst1*(TempX-BosonE)/sqrt((TempX-BosonE)^2-gap^2)
endif
endif
index+=1
while (index<numpnts(ImSelfE))

index=0
Variable A,B,C,D
do
TempX1=(pnt2x(ReSelfE,index))
if (TempX1>0)
if (TempX1<=gap)
ReSelfE[index]=-(ImselfEConst1*(BosonE+TempX1)/sqrt((BosonE+TempX1)^2-gap^2)*ln(abs(BosonE+TempX1+sqrt((BosonE+TempX1)^2-gap^2))/Gap))
else
if (TempX1<=(Gap+BosonE))
ReSelfE[index]=(ImSelfEConst0*(-TempX1)/sqrt(TempX1^2-gap^2))*ln(abs(-TempX1+sqrt(TempX1^2-gap^2))/Gap)
ReSelfE[index]+=-(ImSelfEConst0*(TempX1)/sqrt(TempX1^2-gap^2))*ln(abs(TempX1+sqrt(TempX1^2-gap^2))/Gap)
ReSelfE[index]+=-(ImselfEConst1*(BosonE+TempX1)/sqrt((BosonE+TempX1)^2-gap^2)*ln(abs(BosonE+TempX1+sqrt((BosonE+TempX1)^2-gap^2))/Gap))
else
ReSelfE[index]=(ImSelfEConst0*(-TempX1)/sqrt(TempX1^2-gap^2))*ln(abs(-TempX1+sqrt(TempX1^2-gap^2))/Gap)
ReSelfE[index]+=(ImselfEConst1*(BosonE-TempX1)/sqrt((BosonE-TempX1)^2-gap^2)*ln(abs(BosonE-TempX1+sqrt((BosonE-TempX1)^2-gap^2))/Gap))
ReSelfE[index]+=-(ImSelfEConst0*(TempX1)/sqrt(TempX1^2-gap^2))*ln(abs(TempX1+sqrt(TempX1^2-gap^2))/Gap)
ReSelfE[index]+=-(ImselfEConst1*(BosonE+TempX1)/sqrt((BosonE+TempX1)^2-gap^2)*ln(abs(BosonE+TempX1+sqrt((BosonE+TempX1)^2-gap^2))/Gap))
endif
endif
else
if (abs(TempX1)<=gap)
ReSelfE[index]=(ImselfEConst1*(BosonE-TempX1)/sqrt((BosonE-TempX1)^2-gap^2)*ln(abs(BosonE-TempX1+sqrt((BosonE-TempX1)^2-gap^2))/Gap))
else
if (abs(TempX1)<=(Gap+BosonE))
ReSelfE[index]=(ImSelfEConst0*(-TempX1)/sqrt(TempX1^2-gap^2))*ln(abs(-TempX1+sqrt(TempX1^2-gap^2))/Gap)
ReSelfE[index]+=(ImselfEConst1*(BosonE-TempX1)/sqrt((BosonE-TempX1)^2-gap^2)*ln(abs(BosonE-TempX1+sqrt((BosonE-TempX1)^2-gap^2))/Gap))
ReSelfE[index]+=-(ImSelfEConst0*(TempX1)/sqrt(TempX1^2-gap^2))*ln(abs(TempX1+sqrt(TempX1^2-gap^2))/Gap)
else
ReSelfE[index]=(ImSelfEConst0*(-TempX1)/sqrt(TempX1^2-gap^2))*ln(abs(-TempX1+sqrt(TempX1^2-gap^2))/Gap)
ReSelfE[index]+=(ImselfEConst1*(BosonE-TempX1)/sqrt((BosonE-TempX1)^2-gap^2)*ln(abs(BosonE-TempX1+sqrt((BosonE-TempX1)^2-gap^2))/Gap))
ReSelfE[index]+=-(ImSelfEConst0*(TempX1)/sqrt(TempX1^2-gap^2))*ln(abs(TempX1+sqrt(TempX1^2-gap^2))/Gap)
ReSelfE[index]+=-(ImselfEConst1*(BosonE+TempX1)/sqrt((BosonE+TempX1)^2-gap^2)*ln(abs(BosonE+TempX1+sqrt((BosonE+TempX1)^2-gap^2))/Gap))
endif
endif
endif


A=(ImSelfEConst0*(-TempX1)/sqrt(TempX1^2-gap^2))*ln(abs(-TempX1+sqrt(TempX1^2-gap^2))/Gap)
B=(ImselfEConst1*(BosonE-TempX1)/sqrt((BosonE-TempX1)^2-gap^2)*ln(abs(BosonE-TempX1+sqrt((BosonE-TempX1)^2-gap^2))/Gap))
C=-(ImSelfEConst0*(TempX1)/sqrt(TempX1^2-gap^2))*ln(abs(TempX1+sqrt(TempX1^2-gap^2))/Gap)
D=-(ImselfEConst1*(BosonE+TempX1)/sqrt((BosonE+TempX1)^2-gap^2)*ln(abs(BosonE+TempX1+sqrt((BosonE+TempX1)^2-gap^2))/Gap))
A=(numtype(A)==2)?(0):(A)
B=(numtype(B)==2)?(0):(B)
C=(numtype(C)==2)?(0):(C)
D=(numtype(D)==2)?(0):(D)
ReSelfE[index]=A//+B+C+D

index+=1
while (index<numpnts(ReSelfE))
//ReSelfE=(ImSelfEConst0*(-x)/sqrt(x^2-gap^2))*ln(abs(-x+sqrt(x^2-gap^2))/Gap)
//ReSelfE=(ImselfEConst1*(BosonE-x)/sqrt((BosonE-x)^2-gap^2)*ln(abs(BosonE-x+sqrt((BosonE-x)^2-gap^2))/Gap))
//ReSelfE=-(ImSelfEConst0*(x)/sqrt(x^2-gap^2))*ln(abs(x+sqrt(x^2-gap^2))/Gap)
//ReSelfE=-(ImselfEConst1*(BosonE+x)/sqrt((BosonE+x)^2-gap^2)*ln(abs(BosonE+x+sqrt((BosonE+x)^2-gap^2))/Gap))
//ReSelfE=ln(abs(-x+sqrt(x^2-15^2))/15)+ln(abs(x+sqrt(x^2-15^2))/15)
//ReSelfE=ln(x)
//(hbar*pi*area(A2F,0,abs(x))+ImSelfEConst)
HilbertTransform /Dest=ReSelfE ImSelfE

SetScale /I x,-EMax,EMax,ReSelfE
KillWaves /Z CalReSelfETemp
End



Function CalAKW(dK,KMax,dE,EMax,BosonE,BosonW,BosonL,T,fwhm)
Variable dK,KMax,dE,EMax,BosonE,BosonW,BosonL,T,fwhm
Variable EDatanum=abs(Emax)/dE+1
Variable KDatanum=abs(KMax)/dK+1
String DF=GetDatafolder(1)
NewDatafolder /o/s root:SimuAKW
make /o/n=(KDatanum,2*EDatanum) AKW,FMAKW
Make /o/n=(2*EDatanum) FermFn
Setscale /P x,0,dK,AKW,FMAKW
Setscale /I y,-EMax,EMax,AKW,FMAKW
Setscale /I x,-EMax,EMax,FermFn

GenerateBareBand(dK,KMax)
Wave BandDisp
CalSelfE(dE,EMax,BosonE,BosonW,BosonL)
Wave ImSelfE
Wave ReSelfE
Variable index=0
Variable KTemp,ETemp
Variable kB=8.617385e-5*1000
Variable res=10
Variable data_dx,x0,x1,gauss_from=10*FWHM,dx
Variable y_xfrom,y_xto,gauss_pnts,y_pnts	  
 data_dx=dimdelta(AKW,1)
 x0=M_y0(AKW)
 x1=M_y1(AKW)
 dx=min(fwhm/res,abs(data_dx/2))
 y_xfrom=x0-4*fwhm
 y_xto=x1+4*fwhm
 gauss_pnts=round(gauss_from/dx)*2+1
 y_pnts=round((y_xto-y_xfrom)/dx)
 make /o/d/n=(gauss_pnts) w_conv_gauss = 0
 Make/o/d/n=(y_pnts) convAKW = 0
 SetScale/P x y_xfrom, dx, convAKW
 SetScale/P x -gauss_from, dx, w_conv_gauss
 w_conv_gauss= exp(-x^2*4*ln(2)/fwhm^2)
 Variable sumGauss = sum(w_conv_gauss, -inf,inf)
 w_conv_gauss /= sumGauss
 FermFN=1/(exp((x-0)/KB/T)+1)
do
KTemp=dimoffset(AKW,0)+index*dimdelta(AKW,0)
Etemp=BandDisp(KTemp)
AKW[index][]=1/pi*(abs(ImselfE(y)))/((y-Etemp-ReSelfE(y))^2+ImselfE(y)^2)
FMAKW[index][]=AKW[index][q]*FermFN[q]
convAKW=FMAKW[index][x2pnt(FermFN,x)]
Convolve/A w_conv_gauss convAKW
FMAKW[index][]=convAKW((pnt2x(FermFN,q)))
index+=1
while (index<(dimsize(AKW,0)))

// KillWaves /Z w_conv_gauss,convferm
SetDatafolder $DF
End

Function GenerateBareBand(dK,KMax)
Variable dK,KMax
Variable KDatanum=abs(KMax)/dK+1
Make /o/n=(KDatanum) BandDisp
SetScale /P x,0,dK,BandDisp
Variable Velocity=500
Variable Gap=18
BandDisp=Velocity*(x-KMax/2)//
//BandDisp=-sqrt((Velocity*x)^2+gap^2)
End

Function GenerateA2F(dE,EMax,BosonE,BosonW,BosonL)
Variable dE,EMax,BosonE,BosonW,BosonL
Variable Datanum=abs(EMax)/dE+1
make /o/n=(Datanum) A2F
SetScale /P x,0,dE,A2F
A2F=(BosonL*BosonW^2/4)/((x-BosonE)^2+BosonW^2/4)
//A2F[0,18]=0
End

Function CalSelfE(dE,EMax,BosonE,BosonW,BosonL)
Variable dE,EMax,BosonE,BosonW,BosonL
GenerateA2F(dE,EMax,BosonE,BosonW,BosonL)
Wave A2F
Variable Datanum=abs(EMax)/dE +1
Make /o/n=(2*Datanum) ImSelfE,ReSelfE
SetScale /I x,-EMax,EMax,ImSelfE,ReSelfE
Variable hbar=1
Variable ImSelfEConst=10
Variable ImSelfEConst2=0.002
ImSelfE=(hbar*pi*area(A2F,0,abs(x))+ImSelfEConst+ImSelfEConst2*x^2)
HilbertTransform /Dest=ReSelfE ImSelfE
SetScale /I x,-EMax,EMax,ReSelfE
KillWaves /Z CalReSelfETemp
End


Function IntData(Data,n,m)
Wave Data
variable n
variable m
String Wname=nameofwave(Data)
Wname=Wname+"Int"
make /o/n=((n*dimsize(Data,0)),(m*dimsize(Data,1))) $Wname
Wave IData=$Wname
Setscale /I x,M_x0(Data),M_x1(Data),IData
Setscale /I y,M_y0(Data),M_y1(Data),IData
IData=interp2D(Data,x,y)
End



Function IntFromGraph(StartP,EndP)
Variable StartP,EndP
String Winame=Winname(0,1)
String wlist=TraceNameList(Winame,";",0)
String Wname=StringFromList(0,wList,";")
Wave Line=TraceNametoWaveRef(Winame,Wname)
Variable i=StartP
Variable Summ=0
do
Summ+=Line[i]
i+=1
while (i<(EndP+1))
print Summ


End



Function FindPRFerm(HData,LData,HT,LT,StartK,EndK)
Wave HData,LData
Variable HT,LT
Variable StartK,EndK
String DF=GetDatafolder(1)

Variable FWHM=0.007
Variable EF=0
variable CBX1=0.02
Variable CBX2=0.035
Variable NAX1=-0.15
Variable NAX2=-0.1
Variable INTX1=-0.15
Variable INTX2=0.03



newDatafolder /o/s root:FindPRFerm
String Wname="FM_"+nameofwave(HData)
NewDatafolder /o/s $Wname
Variable Enum=dimsize(HData,1)

Duplicate/o LData,$Wname
Wave FHData=$Wname
Wname=nameofwave(LData)
Duplicate /o LData $Wname 
Wave NLData=$Wname
Duplicate /o LData PeakR
PeakR=0
Make /o/n=(Enum) HTempEDC,LTempEDC,HTFerm,LTFerm,TempPeakR
SetScale /P x,dimoffset(HData,1),dimdelta(HData,1),HTempEDC,LTempEDC,HTFerm,LTFerm,TempPeakR
String notestr=note(LData)
Make /o/n=(Dimsize(LData,0)) PeakRRec=0
note PeakRRec noteStr
note PeaKR noteStr

	   Variable data_dx=deltax(HTFerm)
       Variable res=10
       Variable x0=leftx(HTFerm)
       Variable x1=rightx(HTFerm)
		Variable gauss_from = 10 * fwhm
		Variable dx =  min(fwhm/res, abs(data_dx/2))		// needs to be smaller than the data-width!, not really sure...
		Variable y_xfrom = x0 - 4 * fwhm
		Variable y_xto = x1 + 4 * fwhm
		Variable KB=8.617385e-5
		Variable gauss_pnts = round(gauss_from/dx) * 2 + 1
		Variable y_pnts = round((y_xto-y_xfrom)/dx)
		
		Make/o/d/n=(gauss_pnts) w_conv_gauss = 0
		Make/o/d/n=(y_pnts) w_conv_y = 0
		SetScale/P x y_xfrom, dx, w_conv_y
		SetScale/P x -gauss_from, dx, w_conv_gauss
       
        w_conv_y=1/(exp((x-EF)/KB/HT)+1)//interp(x,xdata,data)
        w_conv_gauss= exp(-x^2*4*ln(2)/fwhm^2)
        Variable sumGauss = sum(w_conv_gauss, -inf,inf)
         w_conv_gauss /= sumGauss
        Convolve/A w_conv_gauss w_conv_y
        HTFerm=w_Conv_y(x)
        W_conv_y=1/(exp((x-EF)/KB/LT)+1)
        Convolve/A w_conv_gauss w_conv_y
        LTFerm=w_Conv_y(x)

        
variable index=StartK

Variable Normarea
Variable ConstBkg
Variable SpectInt

do
	HTempEDC=HData[index][p]
	LTempEDC=LData[index][p]
	ConstBkg=Area(HTempEDC,CBX1,CBX2)/(CBX2-CBX1)
	HTempEDC-=ConstBkg
	Normarea=Area(HTempEDC,NAX1,NAX2)
	HTempEDC/=NormArea
	ConstBkg=Area(LTempEDC,CBX1,CBX2)/(CBX2-CBX1)
	LTempEDC-=ConstBkg
	Normarea=Area(LTempEDC,NAX1,NAX2)
	LTempEDC/=NormArea

	HTempEDC/=HTFerm
	HTempEDC*=LTFerm
	
	SpectInt=Area(LTempEDC,IntX1,IntX2)
	
	TempPeakR=(LTempEDC[p]-HTempEDC[p])
	TempPeakR=(TempPeakR<0)?(0):TempPeakR
	PeakR[index][]=TempPeakR[q]//SpectInt
	//PeakRRec[index]=Area(LTempEDC,-0.05,0.02)-Area(HTempEDC,-0.05,0.02)
	PeakRRec[index]=Area(TempPeakR,-0.05,0.02)//SpectInt
	FHdata[index][]=HTempEDC[q]
	NLdata[index][]=LTempEDC[q]
   
	
index+=1
while (index<(EndK+1))        
SetDatafolder $DF
KillWaves /Z LTempEDC,HTempEDC,W_Conv_gauss,W_conv_y,TempPeakR

PeakRRec=(numtype(PeakR)==2)?(0):PeakRRec
Setscale /P x,-18.2295,0.25,PeakRRec


End






Function MirrorSEDCInt(Data,EF)
Wave Data
Variable EF
Variable Efn,En
Efn=round((EF-leftx(Data))/deltax(Data))
String MWaveName
String DF=GetDatafolder(1)
NewDatafolder /o/s root:MirrorInt
MwaveName=nameofwave(Data)+"MInt"
Make /o /n=((2*(Efn)+1)) $MwaveName,IntEDC1,IntEDC2
Wave MImage=$MwaveName
Setscale /I x,leftx(Data),(-leftx(Data)),MImage,IntEDC1,IntEDC2

Variable XMax=rightx(Data)

Make /o/n=(numpnts(Data)) XImage,TempEDc
Setscale /P x,leftx(Data),deltax(Data),XImage,TempEDC

XImage=x

TempEDC=Data[p]

IntEDC1=interp(x,XImage,TempEDC)
IntEDC1=(p>(x2pnt(IntEDC1,XMax)))?(0):IntEDC1
IntEDC2=IntEDC1[numpnts(IntEDC1)-p-1]

MImage=IntEDC1[p]+IntEDC2[p]


KillWaves /Z XIMage,TempEDC,IntEDC1,IntEDC2 
SetDatafolder $DF
End













Function FitotherSymEDC(Data,W_coef,Width,Width2)
Wave Data
Wave W_coef
Variable width
Variable Width2
String DF=GetDatafolder(1)
newDatafolder /o/s root:fitSymEDC
String Wname=nameofWave(Data)
newDatafolder /o/s $Wname
Variable x0,x1
x0=-width
x1=width
Variable Xs0,Xs1
Xs0=-Width2
Xs1=width2
otherIntConv(W_coef[8],20,deltax(Data),x0,x1)
duplicate /o W_coef W_epsilon
W_epsilon=1e-6
Duplicate /o Data W_Weight
W_Weight=1
Variable KB=8.617385e-5
Variable index=x2pnt(W_Weight,xS0)
do

W_Weight[index]=3
index+=1
while (index<(x2pnt(W_Weight,xS1)+1))

FuncFit /n/q/H="101000111" FitotherFuncSymEDC W_coef Data(x0,x1) /E=w_Epsilon /W=w_Weight
Wave SymEDC=SymEDC
make /o/n=((x2pnt(SymEDC,x1)-x2pnt(SymEDC,x0)+1)) FittedSymEDC,Peak1,Peak2,Ferm1,Ferm2,FMPeak1,FMPeak2,FMBkg1,FMBkg2
Setscale /I x,x0,x1,FittedSymEDC,Peak1,Peak2,Ferm1,Ferm2,FMPeak1,FMPeak2,FMBkg1,FMBkg2
FittedSymEDC=SymEDC(x)
Peak1=(w_coef[1]*w_coef[2]^2/4) / ((x-w_coef[0])^2+w_coef[2]^2/4)
Peak2=(w_coef[1]*w_coef[2]^2/4) / ((x+w_coef[0])^2+w_coef[2]^2/4)
Ferm1=1/(exp((x-w_coef[6])/(kB*w_coef[7]))+1)
Ferm2=1/(exp((-x-w_coef[6])/(kB*w_coef[7]))+1)
FMBkg1=(w_coef[3]+w_coef[4]*x+w_coef[5]*x*x)*Ferm1
FMBkg2=(w_coef[3]-w_coef[4]*x+w_coef[5]*x*x)*Ferm2
FMPeak1=(Peak1*Ferm1)
FMPeak2=(Peak2*Ferm2)
display;
appendtograph /C=(0,0,0) Data
Appendtograph /C=(65280,0,0) FitSymEDC
duplicate /o w_Coef CoefWave
print coefwave[1],coefwave[2]
SetDatafolder $DF
end



Function otherIntConv(fwhm,res,data_dx,x0,x1)
Variable fwhm,res,data_dx,x0,x1
  
  Variable gauss_from = 10 * fwhm
  Variable dx =  min(fwhm/res, abs(data_dx/2))		// needs to be smaller than the data-width!, not really sure...
  Variable y_xfrom = x0 - 4 * fwhm
  Variable y_xto = x1 + 4 * fwhm
		
  Variable gauss_pnts = round(gauss_from/dx) * 2 + 1
  Variable y_pnts = round((y_xto-y_xfrom)/dx/2)*2+1
		
   Make/o/d/n=(gauss_pnts) Conv_gauss = 0
   Make/o/d/n=(y_pnts) SymEDC = 0
		
		SetScale/I x y_xfrom, y_xto, SymEDC
		SetScale/I x -gauss_from, Gauss_from, Conv_Gauss
End


Function FitOtherFuncSymEDC(pw,yw,xw):FitFunc
Wave pw,yw,xw
   CalotherconvSymEDC(pw)
   Wave SymEDC=SymEDC
   yw=symEDC(xw[p])
End

Function CalotherconvSymEDC(pw)
Wave pw
Wave SymEDC=SymEDC
Wave Conv_Gauss=Conv_Gauss
SymEDC=CalotherSymEDC(pw,x)
Conv_Gauss=exp(-x^2*4*ln(2)/pw[8]^2)
Variable sumGauss=sum(Conv_Gauss,-inf,inf)
Conv_Gauss/=sumGauss
Convolve /A Conv_Gauss SymEDC
Duplicate /o SymEDC SymEDCTemp,OFitEDC
SymEDCTemp=SymEDC[numpnts(SymEDC)-p-1]
SymEDC=SymEDC[p]+SymEDCTemp[p]

End

Function CalotherSymEDC(coef,x)
Wave coef
Variable x
Variable Peak
Variable bkg
variable Ferm
Variable KB=8.617385e-5
Peak=(coef[1]*coef[2]^2/4) / ((x-coef[0])^2+coef[2]^2/4)
bkg=coef[3]+coef[4]*x+coef[5]*x*x
ferm=1/(exp((x-coef[6])/(kB*coef[7]))+1)
return (Peak+bkg)*ferm
End








Function CalSymEDCtest(cof,x):FitFunc
Wave cof
Variable x
Variable SelfEim,SelfERe,Aw
if (x==0)
return 0
else
SelfEIm=-cof[1]-cof[2]*cof[2]*cof[0]/(x*x+cof[0]*cof[0])
SelfERe=cof[2]*cof[2]*x/(x*x+cof[0]*cof[0])
Aw=1/pi*SelfEIm/((x-SelfERe)*(x-SelfERe)+SelfEIm*SelfEIm)
return cof[3]*Aw+cof[4]
endif

End




























Function GetSPRother(Data,StartK,EndK,CofWave)
Wave Data
Variable StartK,EndK
Wave CofWave
String DF=Getdatafolder(1)
newDatafolder /o/s root:SPR
String Wname=nameofwave(Data)
//make /o/n=((EndK-StartK+1)) $Wname
Make /o/n=(dimsize(Data,0)) $Wname
Wave SPRwave=$Wname
//Setscale/p x,(dimoffset(Data,0)+dimdelta(data,0)*StartK),dimdelta(data,0),SPRwave
Setscale/p x,dimoffset(Data,0),dimdelta(data,0),SPRwave
Variable Knum=(EndK-StartK+1)
String notestring=note(Data)
note SPRwave notestring

newDatafolder /o/s root:FitEDCbkg
newDatafolder /o/s $Wname

make /o/n=(dimsize(data,1)) TempEDC,TempBkg,TempPeak
Setscale /p x,dimoffset(Data,1),dimdelta(Data,1),TempEDC,TempBkg,TempPeak
Make /o/n=((Knum),(dimsize(data,1))) EDC,Peak,bkg
Setscale /p x,(dimoffset(Data,0)+dimdelta(data,0)*StartK),dimdelta(data,0),EDC,Peak,bkg
Setscale /p y,dimoffset(Data,1),dimdelta(Data,1),EDC,Peak,bkg
Variable KIndex=0
Variable fenm,fenz
Variable PeakInt,TotalInt
Variable En
En=round((-0.55-dimoffset(Data,1))/dimdelta(Data,1))
Variable aux0 = 2*sqrt(ln(2))
Variable i=0
do

TempEDC=Data[StartK+Kindex][p]
//display;
//Appendtograph TempEDC
//FuncFit /Q FitEDCbkg cofwave TempEDC[En,(dimsize(Data,1))]
Curvefit /Q line kwCWave=cofwave, TempEDC(-0.20,-0.1)
Tempbkg=cofwave[0]+cofwave[1]*x
i=0
do
if (TempEDC[(numpnts(TempEDC)-i-1)]>Tempbkg[(numpnts(TempEDC)-i-1)])
break
endif
i+=1
while (i<numpnts(TempEDC))
Tempbkg=(p>(numpnts(TempEDC)-i-1))?(TempEDC[p]):Tempbkg
bkg[Kindex][]=Tempbkg[q]
TempPeak=TempEDC-Tempbkg
Peak[Kindex][]=TempPeak[q]
EDC[Kindex][]=TempEDC[q]

PeakInt=area(TempPeak,-0.15,0.1)
TotalInt=area(TempEDC,-0.15,0.1)
SPRwave[(StartK+Kindex)]=PeakInt/TotalInt

Kindex+=1
while (Kindex<(EndK-StartK+1))
SPRwave=(SPRwave==0)?(Nan):(SPRwave)
Killwaves /Z TempEDC, TempPeak,Tempbkg
SetDatafolder $DF
End






Function GetSPRSingle(Data,Cofwave,ContsWave)
Wave Data
Wave CofWave
Wave ContsWave
String df=GetDatafolder(1)
newDatafolder /o/s root:SPR
String Wname=nameofwave(Data)
newDatafolder /o/s  $Wname
Duplicate /o Data Line,Peak,bkg,fitLine,PeakLine
Make /o/D/n=1 SPR
Variable PeakInt,TotalInt

Variable En
En=round((-0.5-leftx(Data))/deltax(Data))
Variable aux0 = 2*sqrt(ln(2))

FuncFit /Q/H="00000000" FitEDCbkg cofwave Data[En,345] /C=ContsWave

bkg=cofwave[0]*(1+cofwave[3]*(x-cofwave[4])*(x-cofwave[4]))/(exp((x-cofwave[1])/cofwave[2])+1)
Peak=cofwave[5]*exp(-((x-cofwave[6])/(cofwave[7]/aux0))^2)
FitLine=bkg+peak

PeakLine=Data-bkg

PeakInt=area(PeakLine,-0.17,0.007)
TotalInt=area(Data,-0.5,0.1)

SPR=PeakInt/TotalInt
display;
print SPR
appendtograph line,bkg,peak,fitline
SetDatafolder $DF

End





Function GetSPR(Data,StartK,EndK,Kstep,CofWave,ConstWave)
Wave Data
Variable StartK,EndK
Variable Kstep
Wave CofWave
Wave ConstWave

String DF=Getdatafolder(1)
newDatafolder /o/s root:SPR
String Wname=nameofwave(Data)
Make /o/n=(dimsize(Data,0)) $Wname
Wave SPRwave=$Wname
Setscale/p x,dimoffset(Data,0),dimdelta(data,0),SPRwave
//SPRwave=0
Variable Knum
if (Kstep<0)
Knum=(StartK-EndK+1)
else
Knum=(EndK-StartK+1)
endif
//make /o/n=((EndK-StartK+1)) $Wname
//Wave SPRwave=$Wname
//Setscale/p x,(dimoffset(Data,0)+dimdelta(data,0)*StartK),dimdelta(data,0),SPRwave
String notestring=note(Data)
note SPRwave notestring

newDatafolder /o/s root:FitEDCbkg
newDatafolder /o/s $Wname

make /o/n=(dimsize(data,1)) TempEDC,TempBkg,TempPeak,TempPeak1
Setscale /p x,dimoffset(Data,1),dimdelta(Data,1),TempEDC,TempBkg,TempPeak,TempPeak1
Make /o/n=((Knum),(dimsize(data,1))) EDC,Peak,bkg,FitEDC,FitPeaks
Setscale /p x,(dimoffset(Data,0)+dimdelta(data,0)*StartK),dimdelta(data,0),EDC,Peak,bkg,FitEDC,FitPeaks
Setscale /p y,dimoffset(Data,1),dimdelta(Data,1),EDC,Peak,bkg,FitEDC,FitPeaks
Variable KIndex=0
Variable fenm,fenz
Variable PeakInt,TotalInt
Variable En
En=round((-0.6-dimoffset(Data,1))/dimdelta(Data,1))
Variable aux0 = 2*sqrt(ln(2))
do
if (Kstep<0)
TempEDC=Data[StartK-Kindex][p]
else
TempEDC=Data[StartK+Kindex][p]
endif
TempEDC=TempEDC-area(TempEDC,0.04,0.07)/(0.07-0.04)



//cofwave[3]=1
//cofwave[4]=-0.5
///cofwave[5]=0.02
//cofwave[6]=-0.04
//cofwave[7]=0.02
FuncFit /Q FitEDCbkg cofwave TempEDC[En,(dimsize(Data,1))] /C=ConstWave

Tempbkg=cofwave[0]*(1+cofwave[3]*(x-cofwave[4])*(x-cofwave[4]))/(exp((x-cofwave[1])/cofwave[2])+1)
TempPeak1=cofwave[5]*exp(-((x-cofwave[6])/(cofwave[7]/aux0))^2)
FitPeaks[Kindex][]=TempPeak1[q]
bkg[Kindex][]=Tempbkg[q]
TempPeak=TempEDC-Tempbkg
Peak[Kindex][]=TempPeak[q]

EDC[Kindex][]=TempEDC[q]
FitEDC[Kindex][]=Tempbkg[q]+TempPeak1[q]
PeakInt=area(TempPeak,-0.20,0.1)
TotalInt=area(TempEDC,-0.50,0.1)

if (Kstep<0)
SPRwave[StartK-Kindex]=PeakInt/TotalInt
else
SPRwave[StartK+Kindex]=PeakInt/TotalInt
endif


Kindex+=1
while (abs(Kindex)<(Knum))

SPRwave=(SPRwave==0)?(Nan):(SPRwave)
Killwaves /Z TempEDC,TempPeak,Tempbkg,TempPeak1
cofwave[0]=0.01
cofwave[1]=-0.05
cofwave[2]=0.026
cofwave[3]=1
cofwave[4]=-0.5
cofwave[5]=0.02
cofwave[6]=-0.05
cofwave[7]=0.05
SetDatafolder $DF
End


Function FitEDCbkgLinear(cof,x):fitFunc
    Wave cof
    Variable x
    Variable Fenm
    Variable Fenz
    Variable Peak
    fenm=(exp((x-cof[1])/cof[2])+1)
    fenz=(1+cof[3]*(x-cof[4]))
    Variable aux0 = 2*sqrt(ln(2))
	peak= cof[5]*exp(-((x-cof[6])/(cof[7]/aux0))^2)
    return cof[0]*fenz/fenm+peak
    
End

Function Fitedcbkg(cof,x):fitFunc
    Wave cof
    Variable x
    Variable Fenm
    Variable Fenz
    Variable Peak
    fenm=(exp((x-cof[1])/cof[2])+1)
    fenz=(1+cof[3]*(x-cof[4])*(x-cof[4]))
    Variable aux0 = 2*sqrt(ln(2))
	peak= cof[5]*exp(-((x-cof[6])/(cof[7]/aux0))^2)
    return cof[0]*fenz/fenm+peak
    
End

 
Function FitBCSTdep(cof,x):fitFunc
    Wave cof
    Variable x
    if (x>cof[0])
    return 0
    else
    return cof[1]*sqrt(1-x/cof[0])
    endif
 
End
   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


Function ConvolveGuass(Data,EF,T,fwhm)
Wave Data
Variable EF
Variable T
Variable fwhm
String DF=GetDatafolder(1)
String NDF=GetWavesDatafolder(Data,1)+"Convolve"
newDatafolder /o /s $NDF
	
		if (fwhm == 0 || numtype(fwhm) != 0)
			fwhm = 0.002
		else
			fwhm =  abs(fwhm)
		endif
       Variable data_dx=deltax(data)
       Variable res=10
       Variable x0=leftx(data)
       Variable x1=rightx(data)
		Variable gauss_from = 10 * fwhm
		Variable dx =  min(fwhm/res, abs(data_dx/2))		// needs to be smaller than the data-width!, not really sure...
		Variable y_xfrom = x0 - 4 * fwhm
		Variable y_xto = x1 + 4 * fwhm
		Variable KB=8.617385e-5
		Variable gauss_pnts = round(gauss_from/dx) * 2 + 1
		Variable y_pnts = round((y_xto-y_xfrom)/dx)
		
		Make/o/d/n=(gauss_pnts) w_conv_gauss = 0
		Make/o/d/n=(y_pnts) w_conv_y = 0
		Make/o/d/n=(numpnts(data)) xdata
		xdata=x
		
		SetScale/P x y_xfrom, dx, w_conv_y
		SetScale/P x -gauss_from, dx, w_conv_gauss
        w_conv_y=1/(exp((x-EF)/KB/T)+1)//interp(x,xdata,data)
        w_conv_gauss= exp(-x^2*4*ln(2)/fwhm^2)
        Variable sumGauss = sum(w_conv_gauss, -inf,inf)
        Duplicate /o W_Conv_y OFM
    	 w_conv_gauss /= sumGauss
        //FFTConvolve(w_conv_gauss,w_conv_y)
    	
	    Convolve/A w_conv_gauss w_conv_y


SetDatafolder $DF
End
















Function FindLeadEdg(Data)
Wave Data
String DF=GetDatafolder(1)
String Dname="root:LeadEdg"
newDatafolder /O/s $Dname
Dname+=":"+nameofwave(Data)
newDatafolder /O/s $Dname

make /o/n=(dimsize(Data,1)) TempEDC
Setscale/p x,dimoffset(Data,1),dimdelta(Data,1),TempEDC
Make /o/n=(dimsize(Data,0)) PeakInt,LeadEdg
Setscale/p x,dimoffset(Data,0),dimdelta(Data,0),PeakInt,LeadEdg
Variable index=0
do
TempEDC=Data[index][p]
FindPeak /Q /R=(0,(dimoffset(Data,0))) TempEDC
PeakInt[index]=V_PeakVal
FindLevel /Q /EDGE=2 /R=(0,(dimoffset(Data,0))) TempEDC,(V_PeakVal/2)
LeadEdg[index]=V_LevelX
index+=1
while (index<Dimsize(Data,0))
SetDatafolder $DF
End


Function FSMFind3(FSM)
wave FSM
newDatafolder /o/s root:FSMFind
Variable IntS,IntE
Variable IntSnum,IntEnum
Variable Intnum,Finnum,FinnumX,FinnumY
make/o/n=(dimsize(FSM,0)) tempX,tempXD
setscale/P x dimoffset(FSM,0),dimdelta(FSM,0),tempX,tempXD
//tempX=dimoffset(FSM,0)+p*dimdelta(FSM,0)
make/o/n=(dimsize(FSM,1)) tempY,tempYD
setscale/P x dimoffset(FSM,1),dimdelta(FSM,1),tempY,tempYD
//tempY=dimoffset(FSM,1)+p*dimdelta(FSM,1)
FSM=(numtype(FSM)==2)?(0):FSM
Variable TempSum,TempMax,TempPo,TempFR
Variable IntInt
IntInt=0.8
make /o/n=0 FindX,FindY
FinnumX=0
Finnum=0


IntS=dimoffset(FSM,1)
IntE=M_y1(FSM)


do 
tempY=FSM[FinnumX][p]
Intnum=0//x2pnt(tempY,IntS)+2
//print IntS,IntE,Intnum,x2pnt(tempY,IntE)
TempMax=0
do
TempSum=tempY[Intnum]//tempY[Intnum-1]+tempY[Intnum]+tempY[Intnum+1]
if (TempMax<TempSum)
TempMax=TempSum
TempPo=pnt2x(TempY,Intnum)
endif
Intnum+=1
while (Intnum<(x2pnt(tempY,IntE)-2))
InsertPoints 0,1,FindX,FindY
FindY[0]=TempPo
FindX[0]=dimoffset(FSM,0)+dimdelta(FSM,0)*FinnumX
//FindY[Finnum]=area(tempYD,IntS,IntE)/area(tempY,IntS,IntE)
if (Finnum==0)
TempFR=TempPo
endif
IntS=TempPo-IntInt/2
IntE=TempPo+IntInt/2
Finnum+=1
FinnumX+=1
while (FinnumX<(dimsize(FSM,1)))
sort /A FindX,FindX,FindY
end



Function FSMFind2(FSM)
wave FSM
newDatafolder /o/s root:FSMFind
Variable IntS,IntE
Variable IntSnum,IntEnum
Variable Intnum,Finnum,FinnumX,FinnumY
make/o/n=(dimsize(FSM,0)) tempX,tempXD
setscale/P x dimoffset(FSM,0),dimdelta(FSM,0),tempX,tempXD
//tempX=dimoffset(FSM,0)+p*dimdelta(FSM,0)
make/o/n=(dimsize(FSM,1)) tempY,tempYD
setscale/P x dimoffset(FSM,1),dimdelta(FSM,1),tempY,tempYD
//tempY=dimoffset(FSM,1)+p*dimdelta(FSM,1)
FSM=(numtype(FSM)==2)?(0):FSM
Variable TempSum,TempMax,TempPo,TempFR
Variable IntInt
IntInt=0.8
make /o/n=0 FindX,FindY
FinnumX=x2pnt(tempX,(-abs((1-sin(pi/4))*M_y1(FSM))))
print FinnumX

Finnum=0


IntS=dimoffset(FSM,1)
IntE=M_y1(FSM)


do 
tempY=FSM[FinnumX][p]
Intnum=0//x2pnt(tempY,IntS)+2
//print IntS,IntE,Intnum,x2pnt(tempY,IntE)
TempMax=0
do
TempSum=tempY[Intnum]//tempY[Intnum-1]+tempY[Intnum]+tempY[Intnum+1]
if (TempMax<TempSum)
TempMax=TempSum
TempPo=pnt2x(TempY,Intnum)
endif
Intnum+=1
while (Intnum<(x2pnt(tempY,IntE)-2))
print TempMax,TempPo,FinnumX
InsertPoints 0,1,FindX,FindY
FindY[0]=TempPo
FindX[0]=dimoffset(FSM,0)+dimdelta(FSM,0)*FinnumX
//FindY[Finnum]=area(tempYD,IntS,IntE)/area(tempY,IntS,IntE)
if (Finnum==0)
TempFR=TempPo
endif
IntS=TempPo-IntInt/2
IntE=TempPo+IntInt/2
Finnum+=1
FinnumX-=1
while (FinnumX>0)


IntS=dimoffset(FSM,0)+(M_x1(FSM)-dimoffset(FSM,0))/2
IntE=M_x1(FSM)



FinnumY=x2pnt(tempY,TempFR)
make /o/n=(dimsize(FSM,1)) FindX,FindY
Finnum=0
do 
//if (((dimsize(FSM,1)-1-FinnumY)*dimdelta(FSM,1))<RS)
//IntS=dimoffset(FSM,0)+sqrt(RS*RS-((dimsize(FSM,1)-1-FinnumY)*dimdelta(FSM,1))*((dimsize(FSM,1)-1-FinnumY)*dimdelta(FSM,1)))
//else
//IntS=dimoffset(FSM,0)
//endif
//IntE=dimoffset(FSM,0)+sqrt(RE*RE-((dimsize(FSM,1)-1-FinnumY)*dimdelta(FSM,1))*((dimsize(FSM,1)-1-FinnumY)*dimdelta(FSM,1)))
//IntE=(IntE>(dimoffset(FSM,0)+(dimsize(FSM,0)-1)*dimdelta(FSM,0)))?((dimoffset(FSM,0)+(dimsize(FSM,0)-1)*dimdelta(FSM,0))):IntE

tempX=FSM[p][FinnumY]
//tempXD=FSM[p][Finnum]*(dimoffset(FSM,0)+p*dimdelta(FSM,0))
Intnum=x2pnt(tempX,IntS)+2
TempMax=0
do
TempSum=tempY[Intnum-2]+tempY[Intnum+2]+tempX[Intnum-1]+tempX[Intnum]+tempX[Intnum+1]
if (TempMax<TempSum)
TempMax=TempSum
TempPo=pnt2x(TempX,Intnum)
//FindX[Finnum]=pnt2x(TempX,Intnum)
endif
Intnum+=1
while (Intnum<(x2pnt(tempX,IntE)-2))
InsertPoints Finnum,1,FindX,FindY
FindY[Finnum]=dimoffset(FSM,1)+dimdelta(FSM,1)*FinnumY
FindX[Finnum]=TempPo
IntS=TempPo-IntInt/2
IntE=TempPo+IntInt/2
Finnum+=1
//FindX[Finnum]=area(tempXD,IntS,IntE)/area(tempX,IntS,IntE)

FinnumY+=1
while (FinnumY<dimsize(FSM,1))
sort /A FindX,FindX,FindY
end


Function FSMFind1(FSM)
wave FSM
newDatafolder /o/s root:FSMFind
Variable IntS,IntE
Variable IntSnum,IntEnum
Variable Intnum,Finnum,FinnumX,FinnumY
make/o/n=(dimsize(FSM,0)) tempX,tempXD
setscale/P x dimoffset(FSM,0),dimdelta(FSM,0),tempX,tempXD
//tempX=dimoffset(FSM,0)+p*dimdelta(FSM,0)
make/o/n=(dimsize(FSM,1)) tempY,tempYD
setscale/P x dimoffset(FSM,1),dimdelta(FSM,1),tempY,tempYD
//tempY=dimoffset(FSM,1)+p*dimdelta(FSM,1)
FSM=(numtype(FSM)==2)?(0):FSM
Variable TempSum,TempMax,TempPo
Variable RS,RE
RS=0.60
RE=0.80
make /o/n=0 FindX,FindY
FinnumX=0
Finnum=0
do 
if (FinnumX*dimdelta(FSM,0)<RS)
IntS=dimoffset(FSM,1)+(dimsize(FSM,1)-1)*dimdelta(FSM,1)-sqrt(RS*RS-(FinnumX*dimdelta(FSM,0))*(FinnumX*dimdelta(FSM,0)))
else
IntS=dimoffset(FSM,1)+(dimsize(FSM,1)-1)*dimdelta(FSM,1)
endif
IntE=dimoffset(FSM,1)+(dimsize(FSM,1)-1)*dimdelta(FSM,1)-sqrt(RE*RE-(FinnumX*dimdelta(FSM,0))*(FinnumX*dimdelta(FSM,0)))
IntE=(IntE<dimoffset(FSM,1))?(dimoffset(FSM,1)):IntE
tempY=FSM[FinnumX][p]
Intnum=x2pnt(tempY,IntE)+2
//print IntS,IntE,Intnum,x2pnt(tempY,IntE)
TempMax=0
do
TempSum=tempY[Intnum-2]+tempY[Intnum+2]+tempY[Intnum-1]+tempY[Intnum]+tempY[Intnum+1]
if (TempMax<TempSum)
TempMax=TempSum
TempPo=pnt2x(TempY,Intnum)
endif
Intnum+=1
while (Intnum<(x2pnt(tempY,IntS)-2))
//tempYD=FSM[Finnum][p]*(dimoffset(FSM,1)+p*dimdelta(FSM,1))
InsertPoints Finnum,1,FindX,FindY
FindY[Finnum]=TempPo
FindX[Finnum]=dimoffset(FSM,0)+dimdelta(FSM,0)*FinnumX
//FindY[Finnum]=area(tempYD,IntS,IntE)/area(tempY,IntS,IntE)
Finnum+=1
FinnumX+=1
while (FinnumX<(x2pnt(tempX,(-abs((1-sin(pi/4))*M_y1(FSM))))))
FinnumY=x2pnt(tempY,FindY[Finnum])
//make /o/n=(dimsize(FSM,1)) FindX,FindY
//Finnum=0
do 
if (((dimsize(FSM,1)-1-FinnumY)*dimdelta(FSM,1))<RS)
IntS=dimoffset(FSM,0)+sqrt(RS*RS-((dimsize(FSM,1)-1-FinnumY)*dimdelta(FSM,1))*((dimsize(FSM,1)-1-FinnumY)*dimdelta(FSM,1)))
else
IntS=dimoffset(FSM,0)
endif
IntE=dimoffset(FSM,0)+sqrt(RE*RE-((dimsize(FSM,1)-1-FinnumY)*dimdelta(FSM,1))*((dimsize(FSM,1)-1-FinnumY)*dimdelta(FSM,1)))
IntE=(IntE>(dimoffset(FSM,0)+(dimsize(FSM,0)-1)*dimdelta(FSM,0)))?((dimoffset(FSM,0)+(dimsize(FSM,0)-1)*dimdelta(FSM,0))):IntE

tempX=FSM[p][FinnumY]
//tempXD=FSM[p][Finnum]*(dimoffset(FSM,0)+p*dimdelta(FSM,0))
Intnum=x2pnt(tempX,IntS)+2
TempMax=0
do
TempSum=tempY[Intnum-2]+tempY[Intnum+2]+tempX[Intnum-1]+tempX[Intnum]+tempX[Intnum+1]
if (TempMax<TempSum)
TempMax=TempSum
TempPo=pnt2x(TempX,Intnum)
//FindX[Finnum]=pnt2x(TempX,Intnum)
endif
Intnum+=1
while (Intnum<(x2pnt(tempX,IntE)-2))
InsertPoints Finnum,1,FindX,FindY
FindY[Finnum]=dimoffset(FSM,1)+dimdelta(FSM,1)*FinnumY
FindX[Finnum]=TempPo
Finnum+=1
//FindX[Finnum]=area(tempXD,IntS,IntE)/area(tempX,IntS,IntE)

FinnumY+=1
while (FinnumY<dimsize(FSM,1))

end

Function FSMFind(FSM)
wave FSM
newDatafolder /o/s root:FSMFind
Variable IntS,IntE
Variable IntSnum,IntEnum
Variable Intnum,Finnum,FinnumX,FinnumY
make/o/n=(dimsize(FSM,0)) tempX,tempXD
setscale/P x dimoffset(FSM,0),dimdelta(FSM,0),tempX,tempXD
//tempX=dimoffset(FSM,0)+p*dimdelta(FSM,0)
make/o/n=(dimsize(FSM,1)) tempY,tempYD
setscale/P x dimoffset(FSM,1),dimdelta(FSM,1),tempY,tempYD
//tempY=dimoffset(FSM,1)+p*dimdelta(FSM,1)
FSM=(numtype(FSM)==2)?(0):FSM
Variable TempSum,TempMax,TempPo
Variable RS,RE
RS=0.60
RE=0.80
make /o/n=0 FindX,FindY
FinnumX=0
Finnum=0
do 
if (FinnumX*dimdelta(FSM,0)<RS)
IntS=dimoffset(FSM,1)+(dimsize(FSM,1)-1)*dimdelta(FSM,1)-sqrt(RS*RS-(FinnumX*dimdelta(FSM,0))*(FinnumX*dimdelta(FSM,0)))
else
IntS=dimoffset(FSM,1)+(dimsize(FSM,1)-1)*dimdelta(FSM,1)
endif
IntE=dimoffset(FSM,1)+(dimsize(FSM,1)-1)*dimdelta(FSM,1)-sqrt(RE*RE-(FinnumX*dimdelta(FSM,0))*(FinnumX*dimdelta(FSM,0)))
IntE=(IntE<dimoffset(FSM,1))?(dimoffset(FSM,1)):IntE
tempY=FSM[FinnumX][p]
tempYD=FSM[Finnum][p]*(dimoffset(FSM,1)+p*dimdelta(FSM,1))

InsertPoints Finnum,1,FindX,FindY
FindY[Finnum]=area(tempYD,IntS,IntE)/area(tempY,IntS,IntE)
FindX[Finnum]=dimoffset(FSM,0)+dimdelta(FSM,0)*FinnumX
Finnum+=1
FinnumX+=1
while (FinnumX<(x2pnt(tempX,(-abs((1-sin(pi/4))*M_y1(FSM))))))
FinnumY=x2pnt(tempY,FindY[Finnum])
//make /o/n=(dimsize(FSM,1)) FindX,FindY
//Finnum=0
do 
if (((dimsize(FSM,1)-1-FinnumY)*dimdelta(FSM,1))<RS)
IntS=dimoffset(FSM,0)+sqrt(RS*RS-((dimsize(FSM,1)-1-FinnumY)*dimdelta(FSM,1))*((dimsize(FSM,1)-1-FinnumY)*dimdelta(FSM,1)))
else
IntS=dimoffset(FSM,0)
endif
IntE=dimoffset(FSM,0)+sqrt(RE*RE-((dimsize(FSM,1)-1-FinnumY)*dimdelta(FSM,1))*((dimsize(FSM,1)-1-FinnumY)*dimdelta(FSM,1)))
IntE=(IntE>(dimoffset(FSM,0)+(dimsize(FSM,0)-1)*dimdelta(FSM,0)))?((dimoffset(FSM,0)+(dimsize(FSM,0)-1)*dimdelta(FSM,0))):IntE

tempX=FSM[p][FinnumY]
tempXD=FSM[p][Finnum]*(dimoffset(FSM,0)+p*dimdelta(FSM,0))

InsertPoints Finnum,1,FindX,FindY
FindY[Finnum]=dimoffset(FSM,1)+dimdelta(FSM,1)*FinnumY
FindX[Finnum]=area(tempXD,IntS,IntE)/area(tempX,IntS,IntE)
Finnum+=1
//FindX[Finnum]=

FinnumY+=1
while (FinnumY<dimsize(FSM,1))


end

Function WJ(xbkg,bkg,xdata,data)
wave xbkg,bkg,xdata,data
Sort/A xbkg,xbkg,bkg
Variable Temp,i
duplicate/o data,$nameofwave(data)+"_bkg"
Wave datab=$nameofwave(data)+"_bkg"
do 
Temp=interp(xdata[i],xbkg,bkg)
datab[i]=data[i]-temp
i+=1
while(i<dimsize(xdata,0))
End
//25th, Mar, 2007 (SSRL) BiBaCoO project

Function ContrastValue(FileName)
String FileName

Wave Data=$FileName
Variable P6,P4,PG
P6=InterP2D(Data,-0.58208,-0.017769)
P4=InterP2D(Data,-0.43958,-0.017769)
PG=InterP2D(Data,-0.73095,0.043431)

Print (P6-PG)/(P4-PG)
end







Function ManBkgRemove()

Variable Angle=0
Wave Rawdata=root:manual:CorWave1D
do
	String WName="CorWave1D_"+Num2str(Angle)
	Make/o/n=51 $WName
	Wave data=$WName
	data=Rawdata[Angle][p]
	Angle+=5
while (Angle<31)
end

Function ManExpFit(Angle,FitSta,FitEnd)
Variable Angle, FitSta, FitEnd

String WName="CorWave_"+Num2str(Angle)
Wave data=$WName
Curvefit exp data[FitSta,FitEnd] /D
Wave tempcof=w_coef
String WName2="Fit_exp_"+Num2str(Angle)
Make/o/n=1001 $WName2
setscale/p x,0,0.1,$WName2
Wave data2=$WName2
data2=tempcof[0]+tempcof[1]*exp(-tempcof[2]*x)+tempcof[1]*exp(-tempcof[2]*(100-x))
String WName3="CorWaveReal_"+Num2str(Angle)
Make/o/n=1001 $WName3
setscale/p x,0,0.1,$WName3
Wave data3=$WName3
data3=data-data2
end
   
   

Function FSweightedbyGapsize()

duplicate/o root:FSMs:SFS_original root:FSMs:SFS_gap
Wave FSM=root:FSMs:SFS_gap
Wave FSM2=root:FSMs:SFS_original
Wave Gap=root:Gapmap:gapmap
 Variable i=0,j
 	do
         	j=0
         	do
     			FSM[i][j]=FSM2[i][j]*InterP2D(Gap,(dimoffset(FSM,0)+i*dimdelta(FSM,0)),(dimoffset(FSM,1)+j*dimdelta(FSM,1)))
     			j+=1
     		 while (j<dimsize(FSM,1))
     		 i+=1
     	 while (i<dimsize(FSM,0))
  end


function BkgRemove(Degree,Length)
Variable Degree,length
newDatafolder /O/s root:Correlation2D

Make /O/n=((Degree),(length) )CorWave1D
Wave Corwave2D=CorWave2D
Variable i,j

i=0
do 
  j=0
  do
  CorWave1D[i][j]=Interp2D(CorWave2D,j*cos(i/180*pi),j*sin(i/180*pi))
   j+=1
  while (j<length)
 i+=1
 while (i<degree)
 //Duplicate /O Corwave1D ExpWave1D
 Make /o/n=(length) Temp
 MAke /o/n=((degree),101) ExpWave1D
 i=0
   
 do
 Temp=Corwave1D[i][p]
 Curvefit exp Temp[0,9] /D
 Wave tempcof=w_coef
  ExpWave1D[i][]=tempcof[0]+tempcof[1]*exp(-tempcof[2]*q)
 // ExpWave1D[i][]+=tempcof[1]*exp(-tempcof[2]*(100-q))
   i+=1
 while (i<degree)
  
  
  Make /o/n=(degree*length) DExpWave,X1DExpWave,Y1DExpWave
 Variable index=0
  i=0
  do
   j=0
   do
   DExpWave[index]=ExpWave1D[i][j]
   X1DExpWave[index]=j*cos(i/180*pi)
   Y1DExpWave[index]=j*sin(i/180*pi)
   index+=1
    j+=1
   while (j<length)
  
  i+=1
  while (i<degree)

display
AppendxyzContour DExpWave vs {X1DExpWave,Y1DExpWave}

Make /o/n=((length+1),(length+1)) CorWave2D_exp
SetScale /I x,-1,(length-1),CorWave2D_exp
SetScale /I y,-1,(length-1),CorWave2D_exp
CorWave2D_exp=ContourZ("","DExpWave",0,x,y)
CorWave2D_exp=(CorWave2D_exp==0)?(Nan):CorWave2D_exp
AppendImage CorWave2D_exp
CorWave2D_exp[1][]=ExpWave1D[90][q]
CorWave2D_exp[][1]=ExpWave1D[0][p]
Duplicate /O CorWave2D CorWave2D0
CorWave2D0-=CorWave2D_exp
Temp=ExpWave1D[0][p]
CorWave2D0[][0]=CorWave2D[p][0]-Temp[p]
temp=expWave1D[90][p]
CorWave2D0[0][]=CorWave2D[0][q]-Temp[q]

End

function BkgRemove1(Degree,Length)
Variable Degree,length
newDatafolder /O/s root:Correlation1D

Make /O/n=((Degree),(length) )CorWave1D
Wave Corwave2D=CorWave2D
Variable i,j

i=0
do 
  j=0
  do
  CorWave1D[i][j]=Interp2D(CorWave2D,j*cos(i/180*pi),j*sin(i/180*pi))
   j+=1
  while (j<length)
 i+=1
 while (i<degree)
 //Duplicate /O Corwave1D ExpWave1D
 Make /o/n=(length) Temp
 MAke /o/n=((degree),101) ExpWave1D
 i=0
 do
 Temp=Corwave1D[i][p]
 Curvefit exp Temp[0,12+i] /D
 Wave tempcof=w_coef
 ExpWave1D[i][]=tempcof[0]+tempcof[1]*exp(-tempcof[2]*q)
 ExpWave1D[i][]+=tempcof[1]*exp(-tempcof[2]*(100-q))
   i+=1
  while (i<3)
  
do
 Temp=Corwave1D[i][p]
 Curvefit exp Temp[0,15] /D
 Wave tempcof=w_coef
 ExpWave1D[i][]=tempcof[0]+tempcof[1]*exp(-tempcof[2]*q)
  ExpWave1D[i][]+=tempcof[1]*exp(-tempcof[2]*(100-q))
   i+=1
  while (i<23)
  
  do
 Temp=Corwave1D[i][p]
 Curvefit exp Temp[0,(10+0.625*abs(i-30))] /D
 Wave tempcof=w_coef
 ExpWave1D[i][]=tempcof[0]+tempcof[1]*exp(-tempcof[2]*q)
  ExpWave1D[i][]+=tempcof[1]*exp(-tempcof[2]*(100-q))
i+=1
 while (i<38)
  
  do
 Temp=Corwave1D[i][p]
 Curvefit exp Temp[0,15] /D
 Wave tempcof=w_coef
 ExpWave1D[i][]=tempcof[0]+tempcof[1]*exp(-tempcof[2]*q)
  ExpWave1D[i][]+=tempcof[1]*exp(-tempcof[2]*(100-q))
   i+=1
  while (i<58)
  
  do
 Temp=Corwave1D[i][p]
 Curvefit exp Temp[0,(12+abs(i-60))] /D
 Wave tempcof=w_coef
 ExpWave1D[i][]=tempcof[0]+tempcof[1]*exp(-tempcof[2]*q)
  ExpWave1D[i][]+=tempcof[1]*exp(-tempcof[2]*(100-q))
   i+=1
  while (i<63)
  
  do
 Temp=Corwave1D[i][p]
 Curvefit exp Temp[0,15] /D
 Wave tempcof=w_coef
 ExpWave1D[i][]=tempcof[0]+tempcof[1]*exp(-tempcof[2]*q)
  ExpWave1D[i][]+=tempcof[1]*exp(-tempcof[2]*(100-q))
   i+=1
  while (i<83)
  
do
 Temp=Corwave1D[i][p]
 Curvefit exp Temp[0,(10+0.625*abs(i-90))] /D
 Wave tempcof=w_coef
ExpWave1D[i][]=tempcof[0]+tempcof[1]*exp(-tempcof[2]*q)
  ExpWave1D[i][]+=tempcof[1]*exp(-tempcof[2]*(100-q))
   i+=1
 while (i<degree)
  
  
  Make /o/n=(degree*length) DExpWave,X1DExpWave,Y1DExpWave
 Variable index=0
  i=0
  do
   j=0
   do
   DExpWave[index]=ExpWave1D[i][j]
   X1DExpWave[index]=j*cos(i/180*pi)
   Y1DExpWave[index]=j*sin(i/180*pi)
   index+=1
    j+=1
   while (j<length)
  
  i+=1
  while (i<degree)

display
AppendxyzContour DExpWave vs {X1DExpWave,Y1DExpWave}

Make /o/n=((length),(length)) CorWave2D_exp
SetScale /I x,0,(length-1),CorWave2D_exp
SetScale /I y,0,(length-1),CorWave2D_exp
CorWave2D_exp=ContourZ("","DExpWave",0,x,y)
CorWave2D_exp=(CorWave2D_exp==0)?(Nan):CorWave2D_exp
AppendImage CorWave2D_exp

Duplicate /O CorWave2D CorWave2D0
CorWave2D0-=CorWave2D_exp
Temp=ExpWave1D[0][p]
CorWave2D0[][0]=CorWave2D[p][0]-Temp[p]
temp=expWave1D[90][p]
CorWave2D0[0][]=CorWave2D[0][q]-Temp[q]

End

Function SmoothBkg()

Make /o/n=(51,51) CorWave2D_exp
SetScale /I x,0,50,CorWave2D_exp
SetScale /I y,0,50,CorWave2D_exp
Wave Rawdata=root:Correlation1D:DExpWaveImage
Variable i,j
i=0
do
	j=0
	do
		CorWave2D_exp[i][j]=InterP2D(Rawdata,i,j)
		j+=1
	while (j<51)
	i+=1
while (i<51)

CorWave2D_exp=(CorWave2D_exp==0)?(Nan):CorWave2D_exp

end








Function LSMOfillMap(FSM)
Wave FSM
Variable i,j,kx,ky,kx1,ky1
Variable mi=(dimsize(FSM,0)-1)/2
Variable mj=(dimsize(FSM,1)-1)/2
i=mi-5
do 
j=mj-5
 do
// if ((numtype(FSM[i][j])==2)&&(kx<0.06))
 kx=dimoffset(FSM,0)+i*dimdelta(FSM,0)
 ky=dimoffset(FSM,1)+j*dimdelta(FSM,1)
 if ((kx<0.07)&&(ky<0.09))
 //if ((ky>((kx-0.03)*tan(89/180*pi)))&&(ky>0.05))
 //kx1=ky
 //ky1=kx
// FSM[i][j]=interp2D(FSM,kx1,ky1)
 FSM[i][j]=0.0006//interp2D(FSM,kx1,ky1)
 endif
 j+=1
 while (j<dimsize(FSM,1))
i+=1
while (i<dimsize(FSM,0))
End

Function LSMOSymMap(FSM)
Wave FSM
Variable i,j,kx,ky,kx1,ky1
Variable mi=(dimsize(FSM,0)-1)/2
Variable mj=(dimsize(FSM,1)-1)/2
i=mi-5
do 
j=mj-2
 do
// if ((numtype(FSM[i][j])==2)&&(kx<0.07))
 kx=dimoffset(FSM,0)+i*dimdelta(FSM,0)
 ky=dimoffset(FSM,1)+j*dimdelta(FSM,1)
 if ((kx<0.02)&&(ky>0))
 //if ((ky>((kx-0.03)*tan(89/180*pi)))&&(ky>0.05))
 kx1=ky
 ky1=kx
 FSM[i][j]=interp2D(FSM,kx1,ky1)
 endif
 j+=1
 while (j<dimsize(FSM,1))
i+=1
while (i<dimsize(FSM,0))
End



Function CountBZ()
Variable kx=-1.5,ky=-1.5,Count=0
do
 ky=-1.5
 do
 if (Judgethepoints1(kx, ky))
 Count+=1
 endif
 ky+=0.01
 while (ky<1.5)
 kx+=0.01	
while (kx<1.5)
print Count
End

Function Judgethepoints1(x, y) //See whether the point locates in the first BZ
	Variable x, y
	if  ((abs(x)<=1.0233)&&(abs(y)<=(1.1816-(1.0233-abs(x))/sqrt(3))))
		return 1
	else
		return 0
	endif
end


Function PrePare_Cut()
SetDrawLayer ProgFront
SetDrawEnv linefgc= (65535,65535,0),fillpat= 0,xcoord= bottom,ycoord= left, save
End



Function AutoFind(WidthLevel,PD)
Variable WidthLevel,PD
String WavesName
Variable i
do
WavesName="WPos_m_f"+num2indstr(i,3)+"_t"+num2indstr(i,3)
FindPP(PD,$WavesName)
i+=1
while(i<WidthLevel)
End

Function FindPP(PD,WaveN)
WAve WaveN
Variable PD
variable i,p1,p2,dp,p3
do 
FindLevel /P /R=[i]/Q WaveN,(WaveN[i]-0.095)
if (V_flag)
//print nameofwave(WaveN)+"noFound"
return 0
endif
p1=V_LevelX
dp=p1-i
p2=p1+PD/dimdelta(WaveN,0)/2
p3=p1+PD/dimdelta(WaveN,0)
//print p1,dp,p2,WaveN[p2-dp]-WaveN[p2]
if (((WaveN[p3-dp]-WaveN[p3])>0.04)&&((WaveN[p3-dp]-WaveN[p3])<0.06))
 if (((WaveN[p2-dp]-WaveN[p2])>0.071)&&((WaveN[p2-dp]-WaveN[p2])<0.084))
  print dimdelta(WaveN,0)*dp,dimdelta(WaveN,0)*p1,dimdelta(WaveN,0)*p2,dimdelta(WaveN,0)*p3,nameofwave(WaveN)
endif 
endif
i+=1
while (i<dimsize(WaveN,0))
End


Function PeakPositionEDC(Intensity,Width,T,WidthLevel)
Variable Intensity,width,T,WidthLevel
String df=GetDatafolder(1)
newDatafolder /o/s root:PeakPositionEDC
Make /O/n=1001 FermiFun
Make /O/n=(WidthLevel,1001) Peak,FM_Peak
SetScale /I y,-0.5,0.5,Peak,FM_peak
SetScale /I x,-0.05,0.05,Peak,FM_Peak
SetScale /I x,-1.5,1.5,FermiFun

Variable kB=8.617385e-5 	
FermiFun=1/(exp((x) / (kB*T))+1.0 )
Variable Position,i,j=0
String WavesName
do 
   Position=-0.05+i*dimdelta(Peak,0)
  // Peak[][j]=(intensity*width^2/4)/((x-position)^2+Width^2/4)
   //FM_Peak[][j]=Peak[p][j]*FerMiFun[p]
   Make /O/N=1000 tempPeak
   SetScale /I x,-0.5,0.5,TempPeak
   tempPeak=(intensity*width^2/4)/((x-position)^2+Width^2/4)
   Peak[i][]=TempPeak[q]
   tempPeak=tempPeak*fermiFun
   FM_Peak[i][]=tempPeak[q]
   
i+=1
while (i<WidthLevel)
SetDatafolder $Df
End


Function PeakPosition2D(Intensity,T,DeltaLevel,WidthLevel)
Variable Intensity,T,DeltaLevel,WidthLevel
String df=GetDatafolder(1)
newDatafolder /o/s root:PeakPosition2D
newDatafolder /o Peak
newDatafolder /o FMPeak
Make /O/n=1000 FermiFun
Make /O/n=(1000,WidthLevel) Peak,FM_Peak
Make /O/n=(DeltaLevel,WidthLevel) HPos,DeltaPos,WPos,PeakPos,PeakVal
SetScale /I x,-1.5,1.5,FermiFun,Peak,FM_peak
SetScale /I x,-0.5,0.5,HPos,DeltaPos,WPos,PeakPos,PeakVal
SetScale /I y,0.1,2,HPos,DeltaPos,WPos,PeakPos,PeakVal,Peak,FM_Peak

Variable kB=8.617385e-5 	
FermiFun=1/(exp((x) / (kB*T))+1.0 )
Variable Position,i,j=0,Width
String WavesName
do
i=0
 width=dimoffset(Hpos,1)+dimdelta(Hpos,1)*j
do 
   Position=dimoffset(Hpos,0)+i*dimdelta(Hpos,0)
  // Peak[][j]=(intensity*width^2/4)/((x-position)^2+Width^2/4)
   //FM_Peak[][j]=Peak[p][j]*FerMiFun[p]
   Make /O/N=1000 tempPeak
   SetScale /I x,-1.5,1.5,TempPeak
   tempPeak=(intensity*width^2/4)/((x-position)^2+Width^2/4)
   tempPeak=tempPeak*fermiFun
  // peak[i][j]=tempPeakp 
    FindPeak /Q TempPeak
    
	PeakVal[i][j]=V_PeakVal
	PeakPos[i][j]=V_PeaKLoc
	HPos[i][j]=(peakVal[i]-TempPeak(0))/PeakVal[i][j]
	tempPeak/=PeakVal[i][j]
	FindLevels /Q/N=2 /T=0.0001 TempPeak,1/2//PeakVal[i][j]/2
	Wave W_FindLevels
	Wpos[i][j]=W_FindLevels[1]-W_FindLevels[0]
	DeltaPos[i][j]=W_FindLevels[1]
i+=1
while (i<DeltaLevel)
j+=1
while (j<WidthLevel)
SetDatafolder $Df
End


Function PeakPosition(Intensity,W,T,DeltaLevel)
Variable Intensity,W,T,DeltaLevel
String df=GetDatafolder(1)
newDatafolder /o/s root:PeakPosition
newDatafolder /o Peak
newDatafolder /o FMPeak
Make /O/n=1000 FermiFun
Make /O/n=(DeltaLevel) HPos,LeadEdgePos,FWHMPos,PeakPos,PeakVal,W0Val
SetScale /I x,-0.2,0.2,FermiFun
SetScale /I x,-0.05,0.05,Hpos,LeadEdgePos,FWHMPos,PeakPos,PeakVal,W0Val
Variable kB=8.617385e-5 	
FermiFun=1/(exp((x) / (kB*T))+1.0 )
Variable Position,i
String WavesName
do
Position=dimoffset(Hpos,0)+i*dimdelta(Hpos,0)
WavesName="root:PeakPosition:Peak:Peak_e_f"+num2str(i)
Make /O/n=1000 $WavesName
Wave TempPeak1=$WavesName
SetScale /I x,-0.2,0.2,tempPeak1
TempPeak1=(intensity*w^2/4)/((x-position)^2+W^2/4)
WavesName="root:PeakPosition:FMPeak:FMPeak_e_f"+num2str(i)
Make /O/n=1000 $WavesName
Wave TempPeak=$WavesName
SetScale /I x,-0.2,0.2,tempPeak
TempPeak=TempPeak1*FermiFun
FindPeak /Q TempPeak
PeakVal[i]=V_PeakVal
PeakPos[i]=V_PeaKLoc
HPos[i]=(peakVal[i]-TempPeak(0))/PeakVal[i]
FindLevels /Q/N=2 /T=0.0001 TempPeak,PeakVal[i]/2
Wave W_FindLevels
FWHMpos[i]=W_FindLevels[1]-W_FindLevels[0]
LeadEdgePos[i]=W_FindLevels[1]
W0Val[i]=TempPeak(0)
i+=1
while (i<DeltaLevel)

SetDatafolder $df
End

Function AutoCutFerM(first,delta,T,Cutnum,Peak,XPeak)
Variable first,delta,T,Cutnum
Wave Peak,Xpeak
String DF=GetDatafolder(1)
//newDatafolder /O /S CutPeak
Variable i=0
String WaveN=""
Variable FE=0
Variable kB=8.617385e-5 	
display
do
FE=first+i*delta
WaveN="FMPeak"+num2str(i)
Make /O /N=(numpnts(Peak)) $WaveN
Wave TempW=$WaveN
//SetScale /P x,dimoffset(Peak,0),dimdelta(Peak,0),TempW
tempW=1/(exp((Xpeak[p]-FE) / (kB*T))+1.0 ) 
tempW=tempW*Peak

Appendtograph $WaveN vs XPeak
i+=1
while (i<Cutnum)


SetDatafolder $DF
End