
Function Circular_Correlation(ctrlname)
	String ctrlname
	DFREF DF=GetdatafolderDFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_cor=$(DF_panel+":Correlation")
	DFREF DFR_SC=$(DF_panel+":SC_gap")
	SetDataFolder DFR_cor
	DFREF DFR_common=$(DF_panel+":panel_common")
		
	NVAR gv_Cordimflag=DFR_cor:gv_Cordimflag
	//NVAR gv_CorQ0=DFR_panel:gv_CorQ0
	//NVAR gv_CorQ1=DFR_panel:gv_CorQ1
	//NVAR gv_CordQ=DFR_panel:gv_CordQ
	NVAR gv_CorKBZ=DFR_cor:gv_CorKBZ
	NVAR gv_CorKBZx=DFR_cor:gv_CorKBZx
	NVAR gv_CorKBZy=DFR_cor:gv_CorKBZy
	NVAR gv_Corthreshold=DFR_cor:gv_Corthreshold
	
	NVAR gv_dimflag=DFR_panel:gv_dimflag
			
	Variable index
	if (gv_cordimflag==0)
		if (gv_dimflag==2)
			WAVE w_image = DFR_common:w_image
		
			if (dimdelta(w_image,0)<0)
				duplicate /o/Free w_image,w_image_free
				Setscale /P x ,M_x1(w_image),(-dimdelta(w_image,0)),w_image
				w_image[][]=w_image_free[dimsize(w_image,0)-p-1][q]
			endif
			
			NVAR gv_Corstep=DFR_cor:gv_Corstep
			Variable En=floor(dimsize(w_image,1)/gv_Corstep)
			Variable Fn=2*round(gv_CorKBZ/dimdelta(w_image,0))
			Make /o/n=(Fn,En) Correlation_result	
			Make /o/n=(Fn) TempDC
			Setscale /I x, -gv_CorKBZ,gv_CorKBZ,TempDC
			Setscale /I x, 0,2*gv_CorKBZ,Correlation_result ////?need check
			Setscale /P y, M_y0(w_image),dimdelta(w_image,1)*gv_Corstep,Correlation_result
			//
			//duplicate /o/R=(-gv_CorKBZ,gv_CorKBZ)[] w_image Correlation_result	
			Variable i,Eindex=0
			do
				TempDC=0
				for (i=0;i<gv_Corstep;i+=1)
					TempDC+=w_image(x)[index]
					index+=1
				endfor
				
				TempDC/=gv_Corstep
			
				TempDC=(numtype(TempDC)==2)?(0):(TempDC)
				TempDC=(TempDC>gv_Corthreshold)?(TempDC):(0)
			
				MatrixOp /O Temp_result=correlate(TempDC,TempDC,0) 
				Correlation_result[][Eindex]=Temp_result[p]
				Eindex+=1
			while ((index+gv_corstep-1)<dimsize(w_image,1))
			Killwaves /Z tempDC,Temp_result
		
		else
			WAVE w_trace = DFR_common:w_trace
			
			if (dimdelta(w_trace,0)<0)
				duplicate /o/Free w_trace,w_trace_free
				Setscale /P x ,M_x1(w_trace),(-dimdelta(w_trace,0)),w_trace
				w_trace[]=w_trace_free[dimsize(w_trace,0)-p-1]
			endif
	
			Fn=2*round(gv_CorKBZ/dimdelta(w_trace,0))
			Make /o/n=(Fn) Correlation_result	
			Make /o/n=(Fn) TempDC
			Setscale /I x, -gv_CorKBZ,gv_CorKBZ,TempDC
			Setscale /I x, 0,2*gv_CorKBZ,Correlation_result
		
			TempDC=w_trace(x)
			TempDC=(numtype(TempDC)==2)?(0):(TempDC)
			TempDC=(TempDC>gv_Corthreshold)?(TempDC):(0)
		
			MatrixOp /O Temp_result=correlate(TempDC,TempDC,0) 
			Correlation_result[][Eindex]=Temp_result[p]
			Killwaves /Z tempDC,Temp_result
		
		endif
		
	elseif (gv_cordimflag==1)
		if (gv_dimflag==1)
			SetDatafolder DF
			return 0
		endif
		
		WAVE w_image = DFR_common:w_image
		
		if (dimdelta(w_image,0)<0)
			duplicate /o/Free w_image,w_image_free
			Setscale /P x ,M_x1(w_image),(-dimdelta(w_image,0)),w_image
			w_image[][]=w_image_free[dimsize(w_image,0)-p-1][q]
		endif
		
		
		Fn=2*round(gv_CorKBZ/dimdelta(w_image,0))
		Make /o/n=(Fn) Correlation_result	
		Setscale /I x, 0,2*gv_CorKBZ,Correlation_result
		Make /o/n=(Fn,dimsize(w_image,1)) TempImage
		Setscale /I x, -gv_CorKBZ,gv_CorKBZ,TempImage
		Setscale /I y, M_y0(w_image),M_y1(w_image),TempImage
		TempImage=interp2d(w_image,x,y)
		
		Tempimage=(numtype(Tempimage)==2)?(0):(TempImage)
		Tempimage=(Tempimage>gv_Corthreshold)?(TempImage):(0)
		
		//Duplicate /o Tempimage, Temp_result
		//Correlate /Auto Tempimage,Temp_result
		MatrixOp /O Temp_result=correlate(TempImage,TempImage,0) 
		copyscales Tempimage,Temp_result
		Correlation_result=Temp_result[p](0)
		Killwaves /Z tempImage,Temp_result
	elseif (gv_cordimflag==2)
		if (gv_dimflag==1)
			SetDatafolder DF
			return 0
		endif
		WAVE w_image = DFR_common:w_image
		
		
		if (dimdelta(w_image,0)<0)
			duplicate /o/Free w_image,w_image_free
			Setscale /P x ,M_x1(w_image),(-dimdelta(w_image,0)),w_image
			w_image[][]=w_image_free[dimsize(w_image,0)-p-1][q]
		endif
		
		if (dimdelta(w_image,1)<0)
			duplicate /o/Free w_image,w_image_free
			Setscale /P x ,M_y1(w_image),(-dimdelta(w_image,1)),w_image
			w_image[][]=w_image_free[p][dimsize(w_image,1)-q-1]
		endif
		
		Variable xn=2*round(gv_CorKBZx/dimdelta(w_image,0))
		variable yn=2*round(gv_CorKBZy/dimdelta(w_image,1))
		Make /o/n=(xn,yn) TempImage
		Setscale /I x, -gv_CorKBZx,gv_CorKBZx,TempImage
		Setscale /I y, -gv_CorKBZy,gv_CorKBZy,TempImage
		
		TempImage=interp2d(w_image,x,y)
		Tempimage=(numtype(Tempimage)==2)?(0):(TempImage)
		Tempimage=(Tempimage>gv_Corthreshold)?(TempImage):(0)
		
		MatrixOp /O Temp_result=correlate(TempImage,TempImage,0) 
		Duplicate /o Temp_result, Correlation_result
		Setscale /I x, 0,2*gv_CorKBZx,Correlation_result
		SEtscale /I y,0,2*gv_CorKBZy,Correlation_result
		Killwaves /Z tempImage,Temp_result
	endif
	display_wave(Correlation_result,0,0)  
	
	SetDatafolder DF
end


Function Correlation(ctrlName)
	String ctrlname
	DFREF DF=GetDatafolderdFR()
	String DF_panel="root:internalUse:"+winname(0,65)
	DFREF DFR_panel=$DF_panel
	DFREF DFR_cor=$(DF_panel+":Correlation")
	DFREF DFR_SC=$(DF_panel+":SC_gap")
	SetDataFolder DFR_cor
	DFREF DFR_common=$(DF_panel+":panel_common")
	
	WAVE w_image = DFR_common:w_image
	
	NVAR gv_Cordimflag=DFR_cor:gv_Cordimflag
	NVAR gv_CorQ0=DFR_cor:gv_CorQ0
	NVAR gv_CorQ1=DFR_cor:gv_CorQ1
	NVAR gv_CordQ=DFR_cor:gv_CordQ
	//NVAR gv_CorKBZ=DFR_panel:gv_CorKBZ
	//NVAR gv_CorKBZx=DFR_panel:gv_CorKBZx
	//NVAR gv_CorKBZy=DFR_panel:gv_CorKBZy
	NVAR gv_Corthreshold=DFR_cor:gv_Corthreshold
	NVAR gv_pnumflag=DFR_cor:gv_pnumflag
			
	NVAR gv_dimflag=DFR_panel:gv_dimflag
	
			
	Variable index
	if (gv_cordimflag==0)
		if (gv_dimflag==2)
			WAVE w_image = DFR_common:w_image
		
			if (dimdelta(w_image,0)<0)
				duplicate /o/Free w_image,w_image_free
				Setscale /P x ,M_x1(w_image),(-dimdelta(w_image,0)),w_image
				w_image[][]=w_image_free[dimsize(w_image,0)-p-1][q]
			endif
			
			
			NVAR gv_Corstep=DFR_cor:gv_Corstep
			Variable En=floor(dimsize(w_image,1)/gv_Corstep)
			Variable Fn=round(abs(gv_CorQ1-gv_CorQ0)/gv_CordQ)///2*round(gv_CorKBZ/dimdelta(w_image,0))
			Make /o/n=(Fn,En) Correlation_result	
			Make /o/n=(dimsize(w_image,0)) TempDC
			Setscale /I x, M_x0(w_image),M_x1(w_image),TempDC
		
			Setscale /P x, gv_CorQ0,gv_CordQ,Correlation_result
			Setscale /P y, M_y0(w_image),dimdelta(w_image,1)*gv_Corstep,Correlation_result
		
			Variable i,Eindex=0
			do
				TempDC=0
				for (i=0;i<gv_Corstep;i+=1)
					TempDC+=w_image[p][index]
					index+=1
				endfor
			
			//TempDC=(numtype(TempDC)==2)?(0):(TempDC)
				TempDC=(TempDC>gv_Corthreshold)?(TempDC):(nan)
			
				Correlation1D(TempDC,gv_CorQ0,gv_CorQ1,gv_CordQ,gv_pnumflag)
				Wave Temp_result
			//MatrixOp /O Temp_result=correlate(TempDC,TempDC,0) 
				Correlation_result[][Eindex]=Temp_result[p]
				Eindex+=1
			while ((index+gv_corstep-1)<dimsize(w_image,1))
			Killwaves /Z tempDC,Temp_result
		
		else
		
			WAVE w_trace = DFR_common:w_trace
			
			if (dimdelta(w_trace,0)<0)
				duplicate /o/Free w_trace,w_trace_free
				Setscale /P x ,M_x1(w_trace),(-dimdelta(w_trace,0)),w_trace
				w_trace[]=w_trace_free[dimsize(w_trace,0)-p-1]
			endif
			
			Fn=round(abs(gv_CorQ1-gv_CorQ0)/gv_CordQ)
			Make /o/n=(Fn) Correlation_result	
			Setscale /P x, gv_CorQ0,gv_CordQ,Correlation_result
			duplicate /o w_trace,TempDC
			
			//TempDC=w_trace(x)
			TempDC=(numtype(TempDC)==2)?(0):(TempDC)
			TempDC=(TempDC>gv_Corthreshold)?(TempDC):(0)
		
			Correlation1D(TempDC,gv_CorQ0,gv_CorQ1,gv_CordQ,gv_pnumflag)
			Wave Temp_result
			Correlation_result[]=Temp_result[p]
			Killwaves /Z tempDC,Temp_result
		
		endif
		
	elseif (gv_cordimflag==1)
		if (gv_dimflag==1)
			SetDatafolder DF
			return 0
		endif
		WAVE w_image = DFR_common:w_image
		
		
		if (dimdelta(w_image,0)<0)
			duplicate /o/Free w_image,w_image_free
			Setscale /P x ,M_x1(w_image),(-dimdelta(w_image,0)),w_image
			w_image[][]=w_image_free[dimsize(w_image,0)-p-1][q]
		endif		
		
		Fn=round(abs(gv_CorQ1-gv_CorQ0)/gv_CordQ)
		Make /o/n=(Fn) Correlation_result	
		Setscale /P x, gv_CorQ0,gv_CordQ,Correlation_result
		
		duplicate /o w_image TempImage
		
		//Tempimage=(numtype(Tempimage)==2)?(0):(TempImage)
		Tempimage=(Tempimage>gv_Corthreshold)?(TempImage):(nan)
		
		Correlation2D(TempImage,gv_CorQ0,gv_CorQ1,gv_CordQ,gv_pnumflag)
		Wave Temp_result
		Correlation_result=Temp_result[p]
		Killwaves /Z Tempimage,Temp_result
	elseif (gv_cordimflag==2)
		if (gv_dimflag==1)
			SetDatafolder DF
			return 0
		endif
		WAVE w_image = DFR_common:w_image
		
		
		if (dimdelta(w_image,0)<0)
			duplicate /o/Free w_image,w_image_free
			Setscale /P x ,M_x1(w_image),(-dimdelta(w_image,0)),w_image
			w_image[][]=w_image_free[dimsize(w_image,0)-p-1][q]
		endif
		
		if (dimdelta(w_image,1)<0)
			duplicate /o/Free w_image,w_image_free
			Setscale /P x ,M_y1(w_image),(-dimdelta(w_image,1)),w_image
			w_image[][]=w_image_free[p][dimsize(w_image,1)-q-1]
		endif
	
		
		Fn=round(abs(gv_CorQ1-gv_CorQ0)/gv_CordQ)
		Make /o/n=(Fn,Fn) Correlation_result	
		Setscale /P x, gv_CorQ0,gv_CordQ,Correlation_result
		Setscale /P y, gv_CorQ0,gv_CordQ,Correlation_result
		
		duplicate /o w_image TempImage
		
		Tempimage=(Tempimage>gv_Corthreshold)?(TempImage):(nan)
		Correlation2D_2D(TempImage,gv_CorQ0,gv_CorQ1,gv_CordQ,gv_pnumflag)
		Wave Temp_result
		Correlation_result=Temp_result[p][q]
		Killwaves /Z Tempimage,Temp_result
	endif	
	display_wave(Correlation_result,0,0)  	//
	SetDatafolder DF
End

Function Correlation2D_2D(data,q0,q1,dq,pnumflag)
	Wave data
	Variable q0,q1,dq,pnumflag
	
	Variable QNum=round((Q1-Q0)/dQ)

	Make /o/n=(Qnum,Qnum) Temp_result
	Setscale /P x,Q0,dQ,Temp_result
	Setscale /P y,Q0,dQ,Temp_result
	
	Variable x0=M_x0(data)
	Variable x1=M_x1(data)
	Variable xn=dimsize(data,0)
	Variable dx=dimdelta(data,0)
	Variable y0=M_y0(data)
	Variable y1=M_y1(data)
	Variable yn=dimsize(data,1)
	Variable dy=dimdelta(data,1)
	
	Variable QX,QY,KXindex,KYindex,Qint,NormNum,Kx,Ky,QXindex,QYindex
	QXindex=0
	do
		Qx=(Q0+dQ*QXindex)
		QYindex=0
		do
			QY=(Q0+dQ*QYindex)
			KXindex=0
			Qint=0
			NormNum=0
			
			do 
				if (Kxindex==xn)
					break
				endif
				Kx=x0+KXindex*dx+QX
				if ((Kx<(x0))||(Kx>(x1)))
					Kx=x0+KXindex*dx-QX
					if ((Kx<(x0))||(Kx>(x1)))			
						Kxindex+=1
						continue
					endif
				endif
				
				KYindex=0
				do
					if (Kyindex==xn)
						break
					endif
					
					K1=data[KXindex][KYindex]
					if (numtype(K1)==2)
						KYindex+=1
						continue
					endif
					
					ky=y0+KYindex*dy+QY
					if ((Ky<(y0))||(Ky>(y1)))
						Ky=y0+KYindex*dy-QY
						if ((Ky<(y0))||(Ky>(y1)))			
							KYindex+=1
							continue
						endif
					endif
					
					K2=interp2D(data,kx,ky)
					if (numtype(K2)==2)
						KYindex+=1
						continue
					endif	
					QInt+=K1*K2
					NormNum+=1
					KYindex+=1
				while (Kyindex<yn)
				KXindex+=1
			while (KXindex<xn)

			if (NormNum>0)
				if (pnumflag)
					Temp_result[QXindex][QYindex]=QInt/NormNum
				else
					Temp_result[QXindex][QYindex]=QInt
				endif
			else
				Temp_result[QXindex][QYindex]=0
			endif
		QYindex+=1
		while (QYindex<Qnum)
	QXindex+=1
	while (QXindex<Qnum)		
			
End
Function Correlation2D(data,q0,q1,dq,pnumflag)
	Wave data
	Variable q0,q1,dq,pnumflag

	Variable QNum=round((Q1-Q0)/dQ)

	Make /o/n=(Qnum) Temp_result
	Setscale /P x,Q0,dQ,Temp_result
	
	//duplicate /o data data_x
	Variable x0=M_x0(data)
	Variable x1=M_x1(data)
	Variable xn=dimsize(data,0)
	Variable dx=dimdelta(data,0)
	Variable y0=M_y0(data)
	Variable y1=M_y1(data)
	Variable yn=dimsize(data,1)
	Variable dy=dimdelta(data,1)

		
	Variable Q,KXindex,KYindex,Qint,NormNum,Kx,Ky,Qindex=0
	do
		Q=(Q0+dQ*Qindex)
		KXindex=0
		Qint=0
		NormNum=0
	
		do 
			if (Kxindex==xn)
				break
			endif
			Kx=x0+KXindex*dx+Q
			if ((Kx<(x0))||(Kx>(x1)))
				Kx=x0+KXindex*dx-Q
				if ((Kx<(x0))||(Kx>(x1)))			
					Kxindex+=1
					continue
				endif
			endif
			
			KYindex=0
			do
				if (Kyindex==xn)
					break
				endif
				K1=data[KXindex][KYindex]
				if (numtype(K1)==2)
					KYindex+=1
					continue
				endif
				ky=y0+KYindex*dy
				K2=interp2D(data,kx,ky)
				if (numtype(K2)==2)
					KYindex+=1
					continue
				endif	
				QInt+=K1*K2
				NormNum+=1
				KYindex+=1
			while (Kyindex<yn)
		KXindex+=1
		while (KXindex<xn)

		if (NormNum>0)
			if (pnumflag)
				Temp_result[Qindex]=QInt/NormNum
			else
				Temp_result[Qindex]=QInt
			endif
		else
			Temp_result[Qindex]=0
		endif
	Qindex+=1
	while (Qindex<Qnum)

End


Function Correlation1D(data,q0,q1,dq,pnumflag)
	Wave data
	Variable q0,q1,dq,pnumflag

	Variable QNum=round((Q1-Q0)/dQ)

	Make /o/n=(Qnum) Temp_result
	duplicate /o data data_x
	Variable x0=leftx(data)
	Variable x1=rightx(data)
	Variable xn=numpnts(data)

	data_x=x

	Setscale /P x,Q0,dQ,Temp_result
	Variable Q,Kindex,Qint,NormNum,K,Qindex=0
	do
		Q=(Q0+dQ*Qindex)
		Kindex=0
		Qint=0
		NormNum=0
	
		do 
			if (Kindex==xn)
				break
			endif
			K1=data[Kindex]
			if (numtype(K1)==2)
				Kindex+=1
				continue
			endif
			K=data_x[Kindex]+Q
			if ((K<(x0))||(K>(x1)))
				K=data_x[Kindex]-Q
				if ((K<(x0))||(K>(x1)))
					Kindex+=1
					continue
				endif
			endif	
				
			K2=interp(K,data_x,data)
			if (numtype(K1)==2)
				Kindex+=1
				continue
			endif	
			QInt+=K1*K2
			NormNum+=1
			
			Kindex+=1
		while (Kindex<xn)

		if (NormNum>0)
			if (pnumflag)
				Temp_result[Qindex]=QInt/NormNum
			else
				Temp_result[Qindex]=QInt
			endif
		else
			Temp_result[Qindex]=0
		endif
	Qindex+=1
	while (Qindex<Qnum)
	Killwaves /Z data_x

End






