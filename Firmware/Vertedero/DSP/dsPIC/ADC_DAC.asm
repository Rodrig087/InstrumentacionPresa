
_ObtenerTemperatura:
	LNK	#4

;calculo_velocidadsonido.c,2 :: 		float ObtenerTemperatura(){
;calculo_velocidadsonido.c,7 :: 		Ow_Reset(&PORTA, 0);                                                       //Onewire reset signal
	PUSH	W10
	PUSH	W11
	PUSH	W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Reset
;calculo_velocidadsonido.c,8 :: 		Ow_Write(&PORTA, 0, 0xCC);                                                 //Issue command SKIP_ROM
	MOV.B	#204, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;calculo_velocidadsonido.c,9 :: 		Ow_Write(&PORTA, 0, 0x44);                                                 //Issue command CONVERT_T
	MOV.B	#68, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;calculo_velocidadsonido.c,10 :: 		Delay_us(100);
	MOV	#1333, W7
L_ObtenerTemperatura0:
	DEC	W7
	BRA NZ	L_ObtenerTemperatura0
	NOP
;calculo_velocidadsonido.c,12 :: 		Ow_Reset(&PORTA, 0);
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Reset
;calculo_velocidadsonido.c,13 :: 		Ow_Write(&PORTA, 0, 0xCC);                                                 //Issue command SKIP_ROM
	MOV.B	#204, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;calculo_velocidadsonido.c,14 :: 		Ow_Write(&PORTA, 0, 0xBE);                                                 //Issue command READ_SCRATCHPAD
	MOV.B	#190, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;calculo_velocidadsonido.c,15 :: 		Delay_us(100);
	MOV	#1333, W7
L_ObtenerTemperatura2:
	DEC	W7
	BRA NZ	L_ObtenerTemperatura2
	NOP
;calculo_velocidadsonido.c,17 :: 		temperatura =  Ow_Read(&PORTA, 0);
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Read
; temperatura start address is: 10 (W5)
	ZE	W0, W5
;calculo_velocidadsonido.c,18 :: 		temperatura = (Ow_Read(&PORTA, 0) << 8) + temperatura;
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Read
	ZE	W0, W0
	SL	W0, #8, W0
	ADD	W0, W5, W0
; temperatura end address is: 10 (W5)
; temperatura start address is: 4 (W2)
	MOV	W0, W2
;calculo_velocidadsonido.c,20 :: 		if (temperatura & 0x8000) {
	BTSS	W0, #15
	GOTO	L__ObtenerTemperatura131
;calculo_velocidadsonido.c,21 :: 		temperatura = 0;                                                        //Si la temperatura es negativa la establece como cero.
	CLR	W2
; temperatura end address is: 4 (W2)
;calculo_velocidadsonido.c,22 :: 		}
	GOTO	L_ObtenerTemperatura4
L__ObtenerTemperatura131:
;calculo_velocidadsonido.c,20 :: 		if (temperatura & 0x8000) {
;calculo_velocidadsonido.c,22 :: 		}
L_ObtenerTemperatura4:
;calculo_velocidadsonido.c,24 :: 		temperatura_int = temperatura >> 4;                                        //Extrae la parte entera de la respuesta del sensor
; temperatura start address is: 4 (W2)
	LSR	W2, #4, W0
; temperatura_int start address is: 6 (W3)
	MOV	W0, W3
;calculo_velocidadsonido.c,25 :: 		temperatura_Frac = ((temperatura & 0x000F) * 625) / 10000.;                //Extrae la parte decimal de la respuesta del sensor
	AND	W2, #15, W1
; temperatura end address is: 4 (W2)
	MOV	#625, W0
	MUL.UU	W1, W0, W0
	PUSH	W3
	CLR	W1
	CALL	__Long2Float
	MOV	#16384, W2
	MOV	#17948, W3
	CALL	__Div_FP
	POP	W3
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
;calculo_velocidadsonido.c,26 :: 		temperatura_Float = temperatura_Int + temperatura_Frac;                    //Expresa la temperatura en punto flotante
	MOV	W3, W0
	CLR	W1
	CALL	__Long2Float
; temperatura_int end address is: 6 (W3)
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__AddSub_FP
;calculo_velocidadsonido.c,28 :: 		return  temperatura_Float;
;calculo_velocidadsonido.c,30 :: 		}
;calculo_velocidadsonido.c,28 :: 		return  temperatura_Float;
;calculo_velocidadsonido.c,30 :: 		}
L_end_ObtenerTemperatura:
	POP	W12
	POP	W11
	POP	W10
	ULNK
	RETURN
; end of _ObtenerTemperatura

_CalcularVelocidadSonido:

;calculo_velocidadsonido.c,32 :: 		float CalcularVelocidadSonido(){
;calculo_velocidadsonido.c,35 :: 		temperatura_Float = ObtenerTemperatura();
	PUSH	W10
	PUSH	W11
	CALL	_ObtenerTemperatura
;calculo_velocidadsonido.c,36 :: 		vSonido = 331.45 * sqrt(1+(temperatura_Float/273));
	MOV	#32768, W2
	MOV	#17288, W3
	CALL	__Div_FP
	MOV	#0, W2
	MOV	#16256, W3
	CALL	__AddSub_FP
	MOV.D	W0, W10
	CALL	_sqrt
	MOV	#47514, W2
	MOV	#17317, W3
	CALL	__Mul_FP
;calculo_velocidadsonido.c,37 :: 		return vSonido;
;calculo_velocidadsonido.c,39 :: 		}
;calculo_velocidadsonido.c,37 :: 		return vSonido;
;calculo_velocidadsonido.c,39 :: 		}
L_end_CalcularVelocidadSonido:
	POP	W11
	POP	W10
	RETURN
; end of _CalcularVelocidadSonido

_Pulso:
	LNK	#12

;ADC_DAC.c,137 :: 		void Pulso(){
;ADC_DAC.c,140 :: 		contp = 0;                                                                //Limpia la variable del contador de pulsos
	CLR	W0
	MOV	W0, _contp
;ADC_DAC.c,141 :: 		RB2_bit = 0;                                                              //Limpia el pin que produce los pulsos de exitacion del transductor
	BCLR	RB2_bit, BitPos(RB2_bit+0)
;ADC_DAC.c,142 :: 		T1CON.TON = 0;                                                            //Apaga el TMR1
	BCLR	T1CON, #15
;ADC_DAC.c,143 :: 		IEC0.T1IE = 0;                                                            //Desabilita la interrupcion por desborde del TMR1
	BCLR	IEC0, #3
;ADC_DAC.c,144 :: 		TMR2 = 0;                                                                 //Encera el TMR2
	CLR	TMR2
;ADC_DAC.c,145 :: 		IEC0.T2IE = 1;                                                            //Habilita la interrupcion por desborde del TMR2
	BSET	IEC0, #7
;ADC_DAC.c,146 :: 		T2CON.TON = 1;                                                            //Enciende el TMR2
	BSET	T2CON, #15
;ADC_DAC.c,147 :: 		i = 0;                                                                    //Limpia las variables asociadas al almacenamiento de la se�al muestreada
	CLR	W0
	MOV	W0, _i
;ADC_DAC.c,148 :: 		while(bm!=1);                                                             //Espera hasta que haya terminado de enviar y recibir todas las muestras
L_Pulso5:
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA NZ	L__Pulso159
	GOTO	L_Pulso6
L__Pulso159:
	GOTO	L_Pulso5
L_Pulso6:
;ADC_DAC.c,151 :: 		if (bm==1){
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__Pulso160
	GOTO	L_Pulso7
L__Pulso160:
;ADC_DAC.c,154 :: 		Mmax = Vector_Max(M, nm, &MIndexMax);
	MOV	#lo_addr(_MIndexMax), W0
	PUSH	W0
	MOV	#350, W0
	PUSH	W0
	MOV	#lo_addr(_M), W0
	PUSH	W0
	CALL	_Vector_Max
	SUB	#6, W15
	MOV	W0, _Mmax
;ADC_DAC.c,155 :: 		Mmin = Vector_Min(M, nm, &MIndexMin);
	MOV	#lo_addr(_MIndexMin), W0
	PUSH	W0
	MOV	#350, W0
	PUSH	W0
	MOV	#lo_addr(_M), W0
	PUSH	W0
	CALL	_Vector_Min
	SUB	#6, W15
	MOV	W0, _Mmin
;ADC_DAC.c,156 :: 		Mmed = Mmax-((Mmax-Mmin)/2);
	MOV	#lo_addr(_Mmax), W1
	SUBR	W0, [W1], W0
	LSR	W0, #1, W2
	MOV	#lo_addr(_Mmax), W1
	MOV	#lo_addr(_Mmed), W0
	SUBR	W2, [W1], [W0]
;ADC_DAC.c,158 :: 		for (k=0;k<nm;k++){
	CLR	W0
	MOV	W0, _k
L_Pulso8:
	MOV	_k, W1
	MOV	#350, W0
	CP	W1, W0
	BRA LTU	L__Pulso161
	GOTO	L_Pulso9
L__Pulso161:
;ADC_DAC.c,161 :: 		value = M[k]-Mmed;
	MOV	_k, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W3
	MOV	[W3], W2
	MOV	#lo_addr(_Mmed), W1
	MOV	#lo_addr(_value), W0
	SUB	W2, [W1], [W0]
;ADC_DAC.c,162 :: 		if (M[k]<Mmed){
	MOV	[W3], W1
	MOV	#lo_addr(_Mmed), W0
	CP	W1, [W0]
	BRA LTU	L__Pulso162
	GOTO	L_Pulso11
L__Pulso162:
;ADC_DAC.c,163 :: 		value = (M[k]+((Mmed-M[k])*2))-(Mmed);
	MOV	_k, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W1
	MOV	_Mmed, W0
	SUB	W0, [W1], W0
	SL	W0, #1, W0
	ADD	W0, [W1], W2
	MOV	#lo_addr(_Mmed), W1
	MOV	#lo_addr(_value), W0
	SUB	W2, [W1], [W0]
;ADC_DAC.c,164 :: 		}
L_Pulso11:
;ADC_DAC.c,168 :: 		for( f=O-1; f!=0; f-- ) XFIR[f]=XFIR[f-1];
	MOV	#20, W0
	MOV	W0, _f
L_Pulso12:
	MOV	_f, W0
	CP	W0, #0
	BRA NZ	L__Pulso163
	GOTO	L_Pulso13
L__Pulso163:
	MOV	_f, W0
	SL	W0, #2, W1
	MOV	#lo_addr(_XFIR), W0
	ADD	W0, W1, W2
	MOV	_f, W0
	DEC	W0
	SL	W0, #2, W1
	MOV	#lo_addr(_XFIR), W0
	ADD	W0, W1, W0
	MOV	[W0++], [W2++]
	MOV	[W0--], [W2--]
	MOV	#1, W1
	MOV	#lo_addr(_f), W0
	SUBR	W1, [W0], [W0]
	GOTO	L_Pulso12
L_Pulso13:
;ADC_DAC.c,170 :: 		XFIR[0] = (float)(value);
	MOV	_value, W0
	CLR	W1
	CALL	__Long2Float
	MOV	W0, _XFIR
	MOV	W1, _XFIR+2
;ADC_DAC.c,172 :: 		y0 = 0.0; for( f=0; f<O; f++ ) y0 += h[f]*XFIR[f];
	CLR	W0
	CLR	W1
	MOV	W0, _y0
	MOV	W1, _y0+2
	CLR	W0
	MOV	W0, _f
L_Pulso15:
	MOV	_f, W0
	CP	W0, #21
	BRA LTU	L__Pulso164
	GOTO	L_Pulso16
L__Pulso164:
	MOV	_f, W0
	SL	W0, #2, W2
	MOV	#lo_addr(_h), W0
	ADD	W0, W2, W1
	MOV	#___Lib_System_DefaultPage, W0
	MOV	WREG, 52
	MOV	[W1++], W3
	MOV	[W1--], W4
	MOV	#lo_addr(_XFIR), W0
	ADD	W0, W2, W2
	MOV.D	[W2], W0
	MOV	W3, W2
	MOV	W4, W3
	CALL	__Mul_FP
	MOV	_y0, W2
	MOV	_y0+2, W3
	CALL	__AddSub_FP
	MOV	W0, _y0
	MOV	W1, _y0+2
	MOV	#1, W1
	MOV	#lo_addr(_f), W0
	ADD	W1, [W0], [W0]
	GOTO	L_Pulso15
L_Pulso16:
;ADC_DAC.c,174 :: 		YY = (unsigned int)(y0);                                          //Reconstrucci�n de la se�al: y en 10 bits.
	MOV	_y0, W0
	MOV	_y0+2, W1
	CALL	__Float2Longint
	MOV	W0, _YY
;ADC_DAC.c,175 :: 		M[k] = YY;
	MOV	_k, W1
	SL	W1, #1, W2
	MOV	#lo_addr(_M), W1
	ADD	W1, W2, W1
	MOV	W0, [W1]
;ADC_DAC.c,158 :: 		for (k=0;k<nm;k++){
	MOV	#1, W1
	MOV	#lo_addr(_k), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,177 :: 		}
	GOTO	L_Pulso8
L_Pulso9:
;ADC_DAC.c,179 :: 		bm = 2;                                                               //Cambia el estado de la bandera bm para dar paso al c�lculo del pmax y TOF
	MOV	#lo_addr(_bm), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,181 :: 		}
L_Pulso7:
;ADC_DAC.c,184 :: 		if (bm==2){
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__Pulso165
	GOTO	L_Pulso18
L__Pulso165:
;ADC_DAC.c,186 :: 		yy1 = Vector_Max(M, nm, &maxIndex);                                    //Encuentra el valor maximo del vector R
	MOV	#lo_addr(_maxIndex), W0
	PUSH	W0
	MOV	#350, W0
	PUSH	W0
	MOV	#lo_addr(_M), W0
	PUSH	W0
	CALL	_Vector_Max
	SUB	#6, W15
	MOV	W0, _yy1
;ADC_DAC.c,187 :: 		i1b = maxIndex;                                                        //Asigna el subindice del valor maximo a la variable i1a
	MOV	_maxIndex, W0
	MOV	W0, _i1b
;ADC_DAC.c,188 :: 		i1a = 0;
	CLR	W0
	MOV	W0, _i1a
;ADC_DAC.c,190 :: 		while (M[i1a]<yy1){
L_Pulso19:
	MOV	_i1a, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W0
	MOV	[W0], W1
	MOV	#lo_addr(_yy1), W0
	CP	W1, [W0]
	BRA LTU	L__Pulso166
	GOTO	L_Pulso20
L__Pulso166:
;ADC_DAC.c,191 :: 		i1a++;
	MOV	#1, W1
	MOV	#lo_addr(_i1a), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,192 :: 		}
	GOTO	L_Pulso19
L_Pulso20:
;ADC_DAC.c,194 :: 		i1 = i1a+((i1b-i1a)/2);
	MOV	_i1b, W1
	MOV	#lo_addr(_i1a), W0
	SUB	W1, [W0], W0
	LSR	W0, #1, W1
	MOV	#lo_addr(_i1a), W0
	ADD	W1, [W0], W1
	MOV	W1, _i1
;ADC_DAC.c,195 :: 		i0 = i1 - dix;
	SUB	W1, #20, W0
	MOV	W0, _i0
;ADC_DAC.c,196 :: 		i2 = i1 + dix;
	ADD	W1, #20, W3
	MOV	W3, _i2
;ADC_DAC.c,198 :: 		yy0 = M[i0];
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W0
	MOV	[W0], W2
	MOV	W2, _yy0
;ADC_DAC.c,199 :: 		yy2 = M[i2];
	SL	W3, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W0
	MOV	[W0], W0
	MOV	W0, [W14+0]
	MOV	W0, _yy2
;ADC_DAC.c,201 :: 		yf0 = (float)(yy0);
	MOV	W2, W0
	ASR	W0, #15, W1
	SETM	W2
	CALL	__Long2Float
	MOV	W0, [W14+8]
	MOV	W1, [W14+10]
	MOV	W0, _yf0
	MOV	W1, _yf0+2
;ADC_DAC.c,202 :: 		yf1 = (float)(yy1);
	MOV	_yy1, W0
	ASR	W0, #15, W1
	SETM	W2
	CALL	__Long2Float
	MOV	W0, [W14+4]
	MOV	W1, [W14+6]
	MOV	W0, _yf1
	MOV	W1, _yf1+2
;ADC_DAC.c,203 :: 		yf2 = (float)(yy2);
	MOV	[W14+0], W0
	ASR	W0, #15, W1
	SETM	W2
	CALL	__Long2Float
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	PUSH.D	W0
	MOV	[W14+0], W0
	MOV	[W14+2], W1
	MOV	W0, _yf2
	MOV	W1, _yf2+2
	POP.D	W0
;ADC_DAC.c,205 :: 		nx = (yf0-yf2)/(2.0*(yf0-(2.0*yf1)+yf2));                              //Factor de ajuste determinado por interpolacion parabolica
	MOV	[W14+8], W0
	MOV	[W14+10], W1
	PUSH.D	W2
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__Sub_FP
	POP.D	W2
	MOV	[W14+4], W2
	MOV	[W14+6], W3
	MOV	W0, [W14+4]
	MOV	W1, [W14+6]
	MOV	#0, W0
	MOV	#16384, W1
	CALL	__Mul_FP
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	MOV	_yf0, W0
	MOV	_yf0+2, W1
	PUSH.D	W2
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__Sub_FP
	POP.D	W2
	MOV	_yf2, W2
	MOV	_yf2+2, W3
	CALL	__AddSub_FP
	MOV	#0, W2
	MOV	#16384, W3
	CALL	__Mul_FP
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	MOV	[W14+4], W0
	MOV	[W14+6], W1
	PUSH.D	W2
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__Div_FP
	POP.D	W2
	MOV	W0, _nx
	MOV	W1, _nx+2
;ADC_DAC.c,206 :: 		dx = nx*dix*tx;
	MOV	#0, W2
	MOV	#16800, W3
	CALL	__Mul_FP
	MOV	#0, W2
	MOV	#16544, W3
	CALL	__Mul_FP
	MOV	W0, _dx
	MOV	W1, _dx+2
;ADC_DAC.c,207 :: 		tmax = i1*tx;
	MOV	_i1, W0
	CLR	W1
	CALL	__Long2Float
	MOV	#0, W2
	MOV	#16544, W3
	CALL	__Mul_FP
	MOV	W0, _tmax
	MOV	W1, _tmax+2
;ADC_DAC.c,209 :: 		T2 = tmax+dx;
	MOV	_dx, W2
	MOV	_dx+2, W3
	CALL	__AddSub_FP
	MOV	W0, _T2
	MOV	W1, _T2+2
;ADC_DAC.c,211 :: 		}
L_Pulso18:
;ADC_DAC.c,213 :: 		}
L_end_Pulso:
	ULNK
	RETURN
; end of _Pulso

_Moda:

;ADC_DAC.c,215 :: 		int Moda(int VRpt[nd]){
;ADC_DAC.c,217 :: 		ME1=0;
	CLR	W0
	MOV	W0, _ME1
;ADC_DAC.c,218 :: 		ME2=0;
	CLR	W0
	MOV	W0, _ME2
;ADC_DAC.c,219 :: 		ME3=0;
	CLR	W0
	MOV	W0, _ME3
;ADC_DAC.c,220 :: 		Mb2=0;
	MOV	#lo_addr(_Mb2), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,221 :: 		Mb3=0;
	MOV	#lo_addr(_Mb3), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,222 :: 		Mc1=0;
	MOV	#lo_addr(_Mc1), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,223 :: 		Mc2=0;
	MOV	#lo_addr(_Mc2), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,224 :: 		Mc3=0;
	MOV	#lo_addr(_Mc3), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,226 :: 		ME1=VRpt[0];
	MOV	[W10], W0
	MOV	W0, _ME1
;ADC_DAC.c,228 :: 		for (mi=0;mi<nd;mi++){
	MOV	#lo_addr(_mi), W1
	CLR	W0
	MOV.B	W0, [W1]
L_Moda21:
	MOV	#lo_addr(_mi), W0
	MOV.B	[W0], W0
	CP.B	W0, #10
	BRA LTU	L__Moda168
	GOTO	L_Moda22
L__Moda168:
;ADC_DAC.c,229 :: 		if (VRpt[mi]==ME1){
	MOV	#lo_addr(_mi), W0
	ZE	[W0], W0
	SL	W0, #1, W0
	ADD	W10, W0, W0
	MOV	[W0], W1
	MOV	#lo_addr(_ME1), W0
	CP	W1, [W0]
	BRA Z	L__Moda169
	GOTO	L_Moda24
L__Moda169:
;ADC_DAC.c,230 :: 		Mc1++;
	MOV.B	#1, W1
	MOV	#lo_addr(_Mc1), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,231 :: 		}else{
	GOTO	L_Moda25
L_Moda24:
;ADC_DAC.c,232 :: 		if (Mb2==0){
	MOV	#lo_addr(_Mb2), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__Moda170
	GOTO	L_Moda26
L__Moda170:
;ADC_DAC.c,233 :: 		ME2=VRpt[mi];
	MOV	#lo_addr(_mi), W0
	ZE	[W0], W0
	SL	W0, #1, W0
	ADD	W10, W0, W0
	MOV	[W0], W0
	MOV	W0, _ME2
;ADC_DAC.c,234 :: 		Mb2=1;
	MOV	#lo_addr(_Mb2), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,235 :: 		}
L_Moda26:
;ADC_DAC.c,236 :: 		if (VRpt[mi]==ME2){
	MOV	#lo_addr(_mi), W0
	ZE	[W0], W0
	SL	W0, #1, W0
	ADD	W10, W0, W0
	MOV	[W0], W1
	MOV	#lo_addr(_ME2), W0
	CP	W1, [W0]
	BRA Z	L__Moda171
	GOTO	L_Moda27
L__Moda171:
;ADC_DAC.c,237 :: 		Mc2++;
	MOV.B	#1, W1
	MOV	#lo_addr(_Mc2), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,238 :: 		}else{
	GOTO	L_Moda28
L_Moda27:
;ADC_DAC.c,239 :: 		if (Mb3==0){
	MOV	#lo_addr(_Mb3), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__Moda172
	GOTO	L_Moda29
L__Moda172:
;ADC_DAC.c,240 :: 		ME3=VRpt[mi];
	MOV	#lo_addr(_mi), W0
	ZE	[W0], W0
	SL	W0, #1, W0
	ADD	W10, W0, W0
	MOV	[W0], W0
	MOV	W0, _ME3
;ADC_DAC.c,241 :: 		Mb3=1;
	MOV	#lo_addr(_Mb3), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,242 :: 		}
L_Moda29:
;ADC_DAC.c,243 :: 		if (VRpt[mi]==ME3){
	MOV	#lo_addr(_mi), W0
	ZE	[W0], W0
	SL	W0, #1, W0
	ADD	W10, W0, W0
	MOV	[W0], W1
	MOV	#lo_addr(_ME3), W0
	CP	W1, [W0]
	BRA Z	L__Moda173
	GOTO	L_Moda30
L__Moda173:
;ADC_DAC.c,244 :: 		Mc3++;
	MOV.B	#1, W1
	MOV	#lo_addr(_Mc3), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,245 :: 		}
L_Moda30:
;ADC_DAC.c,246 :: 		}
L_Moda28:
;ADC_DAC.c,247 :: 		}
L_Moda25:
;ADC_DAC.c,228 :: 		for (mi=0;mi<nd;mi++){
	MOV.B	#1, W1
	MOV	#lo_addr(_mi), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,249 :: 		}
	GOTO	L_Moda21
L_Moda22:
;ADC_DAC.c,251 :: 		if ((Mc1>Mc2)&&(Mc1>Mc3)){
	MOV	#lo_addr(_Mc1), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc2), W0
	CP.B	W1, [W0]
	BRA GTU	L__Moda174
	GOTO	L__Moda136
L__Moda174:
	MOV	#lo_addr(_Mc1), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc3), W0
	CP.B	W1, [W0]
	BRA GTU	L__Moda175
	GOTO	L__Moda135
L__Moda175:
L__Moda134:
;ADC_DAC.c,252 :: 		return ME1;
	MOV	_ME1, W0
	GOTO	L_end_Moda
;ADC_DAC.c,251 :: 		if ((Mc1>Mc2)&&(Mc1>Mc3)){
L__Moda136:
L__Moda135:
;ADC_DAC.c,254 :: 		if ((Mc2>Mc1)&&(Mc2>Mc3)){
	MOV	#lo_addr(_Mc2), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc1), W0
	CP.B	W1, [W0]
	BRA GTU	L__Moda176
	GOTO	L__Moda138
L__Moda176:
	MOV	#lo_addr(_Mc2), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc3), W0
	CP.B	W1, [W0]
	BRA GTU	L__Moda177
	GOTO	L__Moda137
L__Moda177:
L__Moda133:
;ADC_DAC.c,255 :: 		return ME2;
	MOV	_ME2, W0
	GOTO	L_end_Moda
;ADC_DAC.c,254 :: 		if ((Mc2>Mc1)&&(Mc2>Mc3)){
L__Moda138:
L__Moda137:
;ADC_DAC.c,257 :: 		if ((Mc3>Mc1)&&(Mc3>Mc2)){
	MOV	#lo_addr(_Mc3), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc1), W0
	CP.B	W1, [W0]
	BRA GTU	L__Moda178
	GOTO	L__Moda140
L__Moda178:
	MOV	#lo_addr(_Mc3), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc2), W0
	CP.B	W1, [W0]
	BRA GTU	L__Moda179
	GOTO	L__Moda139
L__Moda179:
L__Moda132:
;ADC_DAC.c,258 :: 		return ME3;
	MOV	_ME3, W0
	GOTO	L_end_Moda
;ADC_DAC.c,257 :: 		if ((Mc3>Mc1)&&(Mc3>Mc2)){
L__Moda140:
L__Moda139:
;ADC_DAC.c,261 :: 		if (Mc1==Mc2){
	MOV	#lo_addr(_Mc1), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc2), W0
	CP.B	W1, [W0]
	BRA Z	L__Moda180
	GOTO	L_Moda40
L__Moda180:
;ADC_DAC.c,262 :: 		return ME1;
	MOV	_ME1, W0
	GOTO	L_end_Moda
;ADC_DAC.c,263 :: 		}
L_Moda40:
;ADC_DAC.c,264 :: 		if (Mc1==Mc3){
	MOV	#lo_addr(_Mc1), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc3), W0
	CP.B	W1, [W0]
	BRA Z	L__Moda181
	GOTO	L_Moda41
L__Moda181:
;ADC_DAC.c,265 :: 		return ME1;
	MOV	_ME1, W0
	GOTO	L_end_Moda
;ADC_DAC.c,266 :: 		}
L_Moda41:
;ADC_DAC.c,267 :: 		if (Mc2==Mc3){
	MOV	#lo_addr(_Mc2), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc3), W0
	CP.B	W1, [W0]
	BRA Z	L__Moda182
	GOTO	L_Moda42
L__Moda182:
;ADC_DAC.c,268 :: 		return ME2;
	MOV	_ME2, W0
	GOTO	L_end_Moda
;ADC_DAC.c,269 :: 		}
L_Moda42:
;ADC_DAC.c,272 :: 		}
L_end_Moda:
	RETURN
; end of _Moda

_Distancia:

;ADC_DAC.c,275 :: 		int Distancia(){
;ADC_DAC.c,277 :: 		conts = 0;                               //Limpia el contador de secuencias
	PUSH	W10
	PUSH	W11
	PUSH	W12
	MOV	#lo_addr(_conts), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,278 :: 		T2sum = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _T2sum
	MOV	W1, _T2sum+2
;ADC_DAC.c,279 :: 		T2prom = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _T2prom
	MOV	W1, _T2prom+2
;ADC_DAC.c,280 :: 		T2a = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _T2a
	MOV	W1, _T2a+2
;ADC_DAC.c,281 :: 		T2b = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _T2b
	MOV	W1, _T2b+2
;ADC_DAC.c,283 :: 		while (conts<Nsm){
L_Distancia43:
	MOV	#lo_addr(_conts), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA LT	L__Distancia184
	GOTO	L_Distancia44
L__Distancia184:
;ADC_DAC.c,284 :: 		Pulso();                           //Inicia una secuencia de medicion
	CALL	_Pulso
;ADC_DAC.c,285 :: 		T2b = T2;
	MOV	_T2, W0
	MOV	_T2+2, W1
	MOV	W0, _T2b
	MOV	W1, _T2b+2
;ADC_DAC.c,286 :: 		if ((T2b-T2a)<=T2umb){             //Verifica si el T2 actual esta dentro de un umbral pre-establecido
	MOV	_T2, W0
	MOV	_T2+2, W1
	MOV	_T2a, W2
	MOV	_T2a+2, W3
	CALL	__Sub_FP
	MOV	#0, W2
	MOV	#16448, W3
	CALL	__Compare_Le_Fp
	CP0	W0
	CLR.B	W0
	BRA GT	L__Distancia185
	INC.B	W0
L__Distancia185:
	CP0.B	W0
	BRA NZ	L__Distancia186
	GOTO	L_Distancia45
L__Distancia186:
;ADC_DAC.c,287 :: 		T2sum = T2sum + T2b;            //Acumula la sumatoria de valores de T2 calculados por la funcion Pulso()
	MOV	_T2sum, W2
	MOV	_T2sum+2, W3
	MOV	_T2b, W0
	MOV	_T2b+2, W1
	CALL	__AddSub_FP
	MOV	W0, _T2sum
	MOV	W1, _T2sum+2
;ADC_DAC.c,288 :: 		conts++;                        //Aumenta el contador de secuencias
	MOV.B	#1, W1
	MOV	#lo_addr(_conts), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,289 :: 		}
L_Distancia45:
;ADC_DAC.c,290 :: 		T2a = T2b;
	MOV	_T2b, W0
	MOV	_T2b+2, W1
	MOV	W0, _T2a
	MOV	W1, _T2a+2
;ADC_DAC.c,291 :: 		}
	GOTO	L_Distancia43
L_Distancia44:
;ADC_DAC.c,293 :: 		T2prom = T2sum/Nsm;
	MOV	#0, W2
	MOV	#16448, W3
	MOV	_T2sum, W0
	MOV	_T2sum+2, W1
	CALL	__Div_FP
	MOV	W0, _T2prom
	MOV	W1, _T2prom+2
;ADC_DAC.c,295 :: 		vSonido = CalcularVelocidadSonido();     //Calcula la velocidad del sonido
	CALL	_CalcularVelocidadSonido
	MOV	W0, _vSonido
	MOV	W1, _vSonido+2
;ADC_DAC.c,298 :: 		TOF = (T1+T2prom-T2adj)/1.0e6;           //Calcula el TOF en seg
	MOV	#57344, W2
	MOV	#17579, W3
	MOV	_T2prom, W0
	MOV	_T2prom+2, W1
	CALL	__AddSub_FP
	MOV	_T2adj, W2
	MOV	_T2adj+2, W3
	CALL	__Sub_FP
	MOV	#9216, W2
	MOV	#18804, W3
	CALL	__Div_FP
	MOV	W0, _TOF
	MOV	W1, _TOF+2
;ADC_DAC.c,299 :: 		Dst = (vSonido*TOF/2.0) * 1000.0;           //Calcula la distancia en mm
	MOV	_vSonido, W2
	MOV	_vSonido+2, W3
	CALL	__Mul_FP
	MOV	#0, W2
	MOV	#16384, W3
	CALL	__Div_FP
	MOV	#0, W2
	MOV	#17530, W3
	CALL	__Mul_FP
	MOV	W0, _Dst
	MOV	W1, _Dst+2
;ADC_DAC.c,300 :: 		doub = modf(Dst, &iptr);
	MOV	#lo_addr(_iptr), W12
	MOV.D	W0, W10
	CALL	_modf
	MOV	W0, _doub
	MOV	W1, _doub+2
;ADC_DAC.c,301 :: 		if (doub>=0.5){
	MOV	#0, W2
	MOV	#16128, W3
	CALL	__Compare_Ge_Fp
	CP0	W0
	CLR.B	W0
	BRA LT	L__Distancia187
	INC.B	W0
L__Distancia187:
	CP0.B	W0
	BRA NZ	L__Distancia188
	GOTO	L_Distancia46
L__Distancia188:
;ADC_DAC.c,302 :: 		Dst=ceil(Dst);
	MOV	_Dst, W10
	MOV	_Dst+2, W11
	CALL	_ceil
	MOV	W0, _Dst
	MOV	W1, _Dst+2
;ADC_DAC.c,303 :: 		}else{
	GOTO	L_Distancia47
L_Distancia46:
;ADC_DAC.c,304 :: 		Dst=floor(Dst);
	MOV	_Dst, W10
	MOV	_Dst+2, W11
	CALL	_floor
	MOV	W0, _Dst
	MOV	W1, _Dst+2
;ADC_DAC.c,305 :: 		}
L_Distancia47:
;ADC_DAC.c,307 :: 		return Dst;
	MOV	_Dst, W0
	MOV	_Dst+2, W1
	CALL	__Float2Longint
;ADC_DAC.c,309 :: 		}
;ADC_DAC.c,307 :: 		return Dst;
;ADC_DAC.c,309 :: 		}
L_end_Distancia:
	POP	W12
	POP	W11
	POP	W10
	RETURN
; end of _Distancia

_Calcular:
	LNK	#4

;ADC_DAC.c,311 :: 		void Calcular(){
;ADC_DAC.c,313 :: 		for (vi=0;vi<nd;vi++){
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	MOV	#lo_addr(_vi), W1
	CLR	W0
	MOV.B	W0, [W1]
L_Calcular48:
	MOV	#lo_addr(_vi), W0
	MOV.B	[W0], W0
	CP.B	W0, #10
	BRA LTU	L__Calcular190
	GOTO	L_Calcular49
L__Calcular190:
;ADC_DAC.c,314 :: 		Vdistancia[vi] = Distancia();        //Toma 10 lecturas de la distancia calculada y las almacena en un vector
	MOV	#lo_addr(_vi), W0
	ZE	[W0], W0
	SL	W0, #1, W1
	MOV	#lo_addr(_Vdistancia), W0
	ADD	W0, W1, W0
	MOV	W0, [W14+0]
	CALL	_Distancia
	MOV	[W14+0], W1
	MOV	W0, [W1]
;ADC_DAC.c,313 :: 		for (vi=0;vi<nd;vi++){
	MOV.B	#1, W1
	MOV	#lo_addr(_vi), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,315 :: 		}
	GOTO	L_Calcular48
L_Calcular49:
;ADC_DAC.c,317 :: 		Cdistancia = Moda(Vdistancia);           //Calcula la Moda del vector de distancias
	MOV	#lo_addr(_Vdistancia), W10
	CALL	_Moda
	MOV	W0, _Cdistancia
;ADC_DAC.c,320 :: 		if ((Cdistancia>=268)&&(Cdistancia<=283)){
	MOV	#268, W1
	CP	W0, W1
	BRA GEU	L__Calcular191
	GOTO	L__Calcular143
L__Calcular191:
	MOV	_Cdistancia, W1
	MOV	#283, W0
	CP	W1, W0
	BRA LEU	L__Calcular192
	GOTO	L__Calcular142
L__Calcular192:
L__Calcular141:
;ADC_DAC.c,321 :: 		Cdistancia = Cdistancia - 3;
	MOV	#3, W1
	MOV	#lo_addr(_Cdistancia), W0
	SUBR	W1, [W0], [W0]
;ADC_DAC.c,322 :: 		} else {
	GOTO	L_Calcular54
;ADC_DAC.c,320 :: 		if ((Cdistancia>=268)&&(Cdistancia<=283)){
L__Calcular143:
L__Calcular142:
;ADC_DAC.c,323 :: 		Cdistancia = Cdistancia + 1;
	MOV	#1, W1
	MOV	#lo_addr(_Cdistancia), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,324 :: 		}
L_Calcular54:
;ADC_DAC.c,326 :: 		Cdistancia = Cdistancia + (float)(Kadj); //Ajusta el valor de la Distancia calculada segun el factor de calibracion Kadj
	MOV	_Kadj, W0
	ASR	W0, #15, W1
	SETM	W2
	CALL	__Long2Float
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	MOV	_Cdistancia, W0
	CLR	W1
	CALL	__Long2Float
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__AddSub_FP
	CALL	__Float2Longint
	MOV	W0, _Cdistancia
;ADC_DAC.c,327 :: 		Nivel = Altura - Cdistancia;             //Calcula el Nivel en mm
	MOV	#lo_addr(_Altura), W1
	SUBR	W0, [W1], W0
	MOV	W0, _Nivel
;ADC_DAC.c,328 :: 		FNivel = Nivel/1000.0;                   //Calcula el Nivel de liquido en metros
	CLR	W1
	CALL	__Long2Float
	MOV	#0, W2
	MOV	#17530, W3
	CALL	__Div_FP
	MOV	W0, _FNivel
	MOV	W1, _FNivel+2
;ADC_DAC.c,329 :: 		FCaudal = 4960440*pow(FNivel,2.5);       //Calcula el Caudal en litros/hora
	MOV	#0, W12
	MOV	#16416, W13
	MOV.D	W0, W10
	CALL	_pow
	MOV	#24944, W2
	MOV	#19095, W3
	CALL	__Mul_FP
	MOV	W0, _FCaudal
	MOV	W1, _FCaudal+2
;ADC_DAC.c,331 :: 		IDst = (unsigned int)(Cdistancia);       //Tranforma el dato de distancia de float a entero sin signo
	MOV	_Cdistancia, W2
	MOV	W2, _IDst
;ADC_DAC.c,332 :: 		Caudal = (unsigned int)(FCaudal);        //Tranforma el dato de Caudal de float a entero sin signo
	CALL	__Float2Longint
	MOV	W0, _Caudal
;ADC_DAC.c,333 :: 		ITOF = (unsigned int)(TOF*1.0e6);        //Tranforma el dato de TOF en us de float a entero sin signo
	MOV	_TOF, W0
	MOV	_TOF+2, W1
	MOV	#9216, W2
	MOV	#18804, W3
	CALL	__Mul_FP
	CALL	__Float2Longint
	MOV	W0, _ITOF
;ADC_DAC.c,335 :: 		}
L_end_Calcular:
	POP	W13
	POP	W12
	POP	W11
	POP	W10
	ULNK
	RETURN
; end of _Calcular

_Responder:

;ADC_DAC.c,338 :: 		void Responder(unsigned int Reg){
;ADC_DAC.c,340 :: 		vSonido = CalcularVelocidadSonido();                             //**Revisar: El programa necesita ejecutar esta funcion para armar la trama de datos de forma correcta, deconosco el porque
	PUSH	W10
	CALL	_CalcularVelocidadSonido
	POP	W10
	MOV	W0, _vSonido
	MOV	W1, _vSonido+2
;ADC_DAC.c,342 :: 		chIDst = (unsigned char *) & IDst;       //Asocia el valor calculado de IDst al puntero chDst
	MOV	#lo_addr(_IDst), W0
	MOV	W0, _chIDst
;ADC_DAC.c,343 :: 		chNivel = (unsigned char *) & Nivel;     //Asocia el valor calculado de Nivel al puntero chNivel
	MOV	#lo_addr(_Nivel), W0
	MOV	W0, _chNivel
;ADC_DAC.c,344 :: 		chCaudal = (unsigned char *) & Caudal;   //Asocia el valor calculado de Caudal al puntero chCaudal
	MOV	#lo_addr(_Caudal), W0
	MOV	W0, _chCaudal
;ADC_DAC.c,345 :: 		chTOF = (unsigned char *) & ITOF;        //Asocia el valor calculado de TOF al puntero chTOF
	MOV	#lo_addr(_ITOF), W0
	MOV	W0, _chTOF
;ADC_DAC.c,346 :: 		chAltura = (unsigned char *) & Altura;   //Asocia el valor de la variable Altura al puntero chAltura
	MOV	#lo_addr(_Altura), W0
	MOV	W0, _chAltura
;ADC_DAC.c,347 :: 		chTemp = (unsigned char *) & TemperaturaInt;//Asocia el valor calculado de Temperatura al puntero chTemp
	MOV	#lo_addr(_TemperaturaInt), W0
	MOV	W0, _chTemp
;ADC_DAC.c,349 :: 		switch(Reg){
	GOTO	L_Responder55
;ADC_DAC.c,350 :: 		case 1:    //Respuesta de Nivel
L_Responder57:
;ADC_DAC.c,351 :: 		for (ir=4;ir>=3;ir--){
	MOV	#lo_addr(_ir), W1
	MOV.B	#4, W0
	MOV.B	W0, [W1]
L_Responder58:
	MOV	#lo_addr(_ir), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA GEU	L__Responder194
	GOTO	L_Responder59
L__Responder194:
;ADC_DAC.c,352 :: 		Rspt[ir]=(*chNivel++);             //Rellena los bytes 3 y 4 de la trama de respuesta con el dato del Nivel calculado
	MOV	#lo_addr(_ir), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W1
	MOV	_chNivel, W0
	MOV.B	[W0], [W1]
	MOV	#1, W1
	MOV	#lo_addr(_chNivel), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,351 :: 		for (ir=4;ir>=3;ir--){
	MOV.B	#1, W1
	MOV	#lo_addr(_ir), W0
	SUBR.B	W1, [W0], [W0]
;ADC_DAC.c,353 :: 		}
	GOTO	L_Responder58
L_Responder59:
;ADC_DAC.c,354 :: 		Rspt[2]=Ptcn[2];                       //Rellena el byte 2 con el tipo de funcion de la trama de peticion
	MOV	#lo_addr(_Rspt+2), W1
	MOV	#lo_addr(_Ptcn+2), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,355 :: 		break;
	GOTO	L_Responder56
;ADC_DAC.c,357 :: 		case 2:    //Respuesta de Caudal
L_Responder61:
;ADC_DAC.c,358 :: 		for (ir=4;ir>=3;ir--){
	MOV	#lo_addr(_ir), W1
	MOV.B	#4, W0
	MOV.B	W0, [W1]
L_Responder62:
	MOV	#lo_addr(_ir), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA GEU	L__Responder195
	GOTO	L_Responder63
L__Responder195:
;ADC_DAC.c,359 :: 		Rspt[ir]=(*chCaudal++);            //Rellena los bytes 3 y 4 de la trama de respuesta con el dato del Caudal calculado
	MOV	#lo_addr(_ir), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W1
	MOV	_chCaudal, W0
	MOV.B	[W0], [W1]
	MOV	#1, W1
	MOV	#lo_addr(_chCaudal), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,358 :: 		for (ir=4;ir>=3;ir--){
	MOV.B	#1, W1
	MOV	#lo_addr(_ir), W0
	SUBR.B	W1, [W0], [W0]
;ADC_DAC.c,360 :: 		}
	GOTO	L_Responder62
L_Responder63:
;ADC_DAC.c,361 :: 		Rspt[2]=Ptcn[2];                       //Rellena el byte 2 con el tipo de funcion de la trama de peticion
	MOV	#lo_addr(_Rspt+2), W1
	MOV	#lo_addr(_Ptcn+2), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,362 :: 		break;
	GOTO	L_Responder56
;ADC_DAC.c,364 :: 		case 3:    //Respuesta de Distancia
L_Responder65:
;ADC_DAC.c,365 :: 		for (ir=4;ir>=3;ir--){
	MOV	#lo_addr(_ir), W1
	MOV.B	#4, W0
	MOV.B	W0, [W1]
L_Responder66:
	MOV	#lo_addr(_ir), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA GEU	L__Responder196
	GOTO	L_Responder67
L__Responder196:
;ADC_DAC.c,366 :: 		Rspt[ir]=(*chIDst++);              //Rellena los bytes 3 y 4 de la trama de respuesta con el dato del Distancia calculada
	MOV	#lo_addr(_ir), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W1
	MOV	_chIDst, W0
	MOV.B	[W0], [W1]
	MOV	#1, W1
	MOV	#lo_addr(_chIDst), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,365 :: 		for (ir=4;ir>=3;ir--){
	MOV.B	#1, W1
	MOV	#lo_addr(_ir), W0
	SUBR.B	W1, [W0], [W0]
;ADC_DAC.c,367 :: 		}
	GOTO	L_Responder66
L_Responder67:
;ADC_DAC.c,368 :: 		Rspt[2]=Ptcn[2];                       //Rellena el byte 2 con el tipo de funcion de la trama de peticion
	MOV	#lo_addr(_Rspt+2), W1
	MOV	#lo_addr(_Ptcn+2), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,369 :: 		break;
	GOTO	L_Responder56
;ADC_DAC.c,371 :: 		case 4:    //Respuesta de TOF
L_Responder69:
;ADC_DAC.c,372 :: 		for (ir=4;ir>=3;ir--){
	MOV	#lo_addr(_ir), W1
	MOV.B	#4, W0
	MOV.B	W0, [W1]
L_Responder70:
	MOV	#lo_addr(_ir), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA GEU	L__Responder197
	GOTO	L_Responder71
L__Responder197:
;ADC_DAC.c,373 :: 		Rspt[ir]=(*chTOF++);               //Rellena los bytes 3 y 4 de la trama de respuesta con el dato del TOF calculado
	MOV	#lo_addr(_ir), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W1
	MOV	_chTOF, W0
	MOV.B	[W0], [W1]
	MOV	#1, W1
	MOV	#lo_addr(_chTOF), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,372 :: 		for (ir=4;ir>=3;ir--){
	MOV.B	#1, W1
	MOV	#lo_addr(_ir), W0
	SUBR.B	W1, [W0], [W0]
;ADC_DAC.c,374 :: 		}
	GOTO	L_Responder70
L_Responder71:
;ADC_DAC.c,375 :: 		Rspt[2]=Ptcn[2];                       //Rellena el byte 2 con el tipo de funcion de la trama de peticion
	MOV	#lo_addr(_Rspt+2), W1
	MOV	#lo_addr(_Ptcn+2), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,376 :: 		break;
	GOTO	L_Responder56
;ADC_DAC.c,378 :: 		case 5:    //Respuesta de Temperatura
L_Responder73:
;ADC_DAC.c,379 :: 		for (ir=4;ir>=3;ir--){
	MOV	#lo_addr(_ir), W1
	MOV.B	#4, W0
	MOV.B	W0, [W1]
L_Responder74:
	MOV	#lo_addr(_ir), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA GEU	L__Responder198
	GOTO	L_Responder75
L__Responder198:
;ADC_DAC.c,380 :: 		Rspt[ir]=(*chTemp++);              //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la Temperatura calculada
	MOV	#lo_addr(_ir), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W1
	MOV	_chTemp, W0
	MOV.B	[W0], [W1]
	MOV	#1, W1
	MOV	#lo_addr(_chTemp), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,379 :: 		for (ir=4;ir>=3;ir--){
	MOV.B	#1, W1
	MOV	#lo_addr(_ir), W0
	SUBR.B	W1, [W0], [W0]
;ADC_DAC.c,381 :: 		}
	GOTO	L_Responder74
L_Responder75:
;ADC_DAC.c,382 :: 		break;
	GOTO	L_Responder56
;ADC_DAC.c,384 :: 		case 6:    //Respuesta de Altura de instalacion
L_Responder77:
;ADC_DAC.c,385 :: 		for (ir=4;ir>=3;ir--){
	MOV	#lo_addr(_ir), W1
	MOV.B	#4, W0
	MOV.B	W0, [W1]
L_Responder78:
	MOV	#lo_addr(_ir), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA GEU	L__Responder199
	GOTO	L_Responder79
L__Responder199:
;ADC_DAC.c,386 :: 		Rspt[ir]=(*chAltura++);            //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la Altura de instalacion
	MOV	#lo_addr(_ir), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W1
	MOV	_chAltura, W0
	MOV.B	[W0], [W1]
	MOV	#1, W1
	MOV	#lo_addr(_chAltura), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,385 :: 		for (ir=4;ir>=3;ir--){
	MOV.B	#1, W1
	MOV	#lo_addr(_ir), W0
	SUBR.B	W1, [W0], [W0]
;ADC_DAC.c,387 :: 		}
	GOTO	L_Responder78
L_Responder79:
;ADC_DAC.c,388 :: 		Rspt[2]=Ptcn[2];                       //Rellena el byte 2 con el tipo de funcion de la trama de peticion
	MOV	#lo_addr(_Rspt+2), W1
	MOV	#lo_addr(_Ptcn+2), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,389 :: 		break;
	GOTO	L_Responder56
;ADC_DAC.c,391 :: 		default:   Rspt[3]=0x00;                          //Rellena el campo de datos con el mensaje de error 0x00E2: Registro no disponible
L_Responder81:
	MOV	#lo_addr(_Rspt+3), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,392 :: 		Rspt[4]=0xE2;
	MOV	#lo_addr(_Rspt+4), W1
	MOV.B	#226, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,393 :: 		Rspt[2]=0xEE;                          //Rellena el byre 2 con el aviso de error 0xEE
	MOV	#lo_addr(_Rspt+2), W1
	MOV.B	#238, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,394 :: 		break;
	GOTO	L_Responder56
;ADC_DAC.c,395 :: 		}
L_Responder55:
	CP	W10, #1
	BRA NZ	L__Responder200
	GOTO	L_Responder57
L__Responder200:
	CP	W10, #2
	BRA NZ	L__Responder201
	GOTO	L_Responder61
L__Responder201:
	CP	W10, #3
	BRA NZ	L__Responder202
	GOTO	L_Responder65
L__Responder202:
	CP	W10, #4
	BRA NZ	L__Responder203
	GOTO	L_Responder69
L__Responder203:
	CP	W10, #5
	BRA NZ	L__Responder204
	GOTO	L_Responder73
L__Responder204:
	CP	W10, #6
	BRA NZ	L__Responder205
	GOTO	L_Responder77
L__Responder205:
	GOTO	L_Responder81
L_Responder56:
;ADC_DAC.c,397 :: 		RB5_bit = 1;                             //Establece el Max485 en modo de escritura
	BSET	RB5_bit, BitPos(RB5_bit+0)
;ADC_DAC.c,398 :: 		for (ir=0;ir<Rsize;ir++){
	MOV	#lo_addr(_ir), W1
	CLR	W0
	MOV.B	W0, [W1]
L_Responder82:
	MOV	#lo_addr(_ir), W0
	MOV.B	[W0], W0
	CP.B	W0, #6
	BRA LTU	L__Responder206
	GOTO	L_Responder83
L__Responder206:
;ADC_DAC.c,399 :: 		UART1_Write(Rspt[ir]);               //Envia la trama de respuesta
	MOV	#lo_addr(_ir), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W0
	PUSH	W10
	ZE	[W0], W10
	CALL	_UART1_Write
	POP	W10
;ADC_DAC.c,398 :: 		for (ir=0;ir<Rsize;ir++){
	MOV.B	#1, W1
	MOV	#lo_addr(_ir), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,400 :: 		}
	GOTO	L_Responder82
L_Responder83:
;ADC_DAC.c,401 :: 		while(UART1_Tx_Idle()==0);               //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_Responder85:
	CALL	_UART1_Tx_Idle
	CP	W0, #0
	BRA Z	L__Responder207
	GOTO	L_Responder86
L__Responder207:
	GOTO	L_Responder85
L_Responder86:
;ADC_DAC.c,402 :: 		RB5_bit = 0;                             //Establece el Max485 en modo de lectura;
	BCLR	RB5_bit, BitPos(RB5_bit+0)
;ADC_DAC.c,404 :: 		for (ipp=3;ipp<5;ipp++){
	MOV	#lo_addr(_ipp), W1
	MOV.B	#3, W0
	MOV.B	W0, [W1]
L_Responder87:
	MOV	#lo_addr(_ipp), W0
	MOV.B	[W0], W0
	CP.B	W0, #5
	BRA LTU	L__Responder208
	GOTO	L_Responder88
L__Responder208:
;ADC_DAC.c,405 :: 		Rspt[ipp]=0;;                        //Limpia la trama de respuesta
	MOV	#lo_addr(_ipp), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,404 :: 		for (ipp=3;ipp<5;ipp++){
	MOV.B	#1, W1
	MOV	#lo_addr(_ipp), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,406 :: 		}
	GOTO	L_Responder87
L_Responder88:
;ADC_DAC.c,408 :: 		}
L_end_Responder:
	RETURN
; end of _Responder

_UART1Interrupt:
	PUSH	52
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;ADC_DAC.c,412 :: 		void UART1Interrupt() iv IVT_ADDR_U1RXINTERRUPT {
;ADC_DAC.c,414 :: 		if (UART1_Data_Ready()==1){
	CALL	_UART1_Data_Ready
	CP	W0, #1
	BRA Z	L__UART1Interrupt210
	GOTO	L_UART1Interrupt90
L__UART1Interrupt210:
;ADC_DAC.c,415 :: 		Dato = UART1_Read();
	CALL	_UART1_Read
	MOV	#lo_addr(_Dato), W1
	MOV.B	W0, [W1]
;ADC_DAC.c,416 :: 		}
L_UART1Interrupt90:
;ADC_DAC.c,417 :: 		if ((Dato==Hdr)&&(ip==0)){                    //Verifica que el primer dato en llegar sea el identificador de inicio de trama
	MOV	#lo_addr(_Dato), W0
	MOV.B	[W0], W1
	MOV.B	#58, W0
	CP.B	W1, W0
	BRA Z	L__UART1Interrupt211
	GOTO	L__UART1Interrupt148
L__UART1Interrupt211:
	MOV	#lo_addr(_ip), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__UART1Interrupt212
	GOTO	L__UART1Interrupt147
L__UART1Interrupt212:
L__UART1Interrupt146:
;ADC_DAC.c,418 :: 		BanT = 1;                                 //Activa la bandera de trama
	MOV	#lo_addr(_BanT), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,419 :: 		Ptcn[ip] = Dato;                          //Almacena el Dato en la trama de peticion
	MOV	#lo_addr(_ip), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Ptcn), W0
	ADD	W0, W1, W1
	MOV	#lo_addr(_Dato), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,417 :: 		if ((Dato==Hdr)&&(ip==0)){                    //Verifica que el primer dato en llegar sea el identificador de inicio de trama
L__UART1Interrupt148:
L__UART1Interrupt147:
;ADC_DAC.c,421 :: 		if ((Dato!=Hdr)&&(ip==0)){                    //Verifica si el primer dato en llegar es diferente al identificador del inicio de trama
	MOV	#lo_addr(_Dato), W0
	MOV.B	[W0], W1
	MOV.B	#58, W0
	CP.B	W1, W0
	BRA NZ	L__UART1Interrupt213
	GOTO	L__UART1Interrupt150
L__UART1Interrupt213:
	MOV	#lo_addr(_ip), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__UART1Interrupt214
	GOTO	L__UART1Interrupt149
L__UART1Interrupt214:
L__UART1Interrupt145:
;ADC_DAC.c,422 :: 		ip=-1;                                    //Si es asi: reduce el subindice en una unidad
	MOV	#lo_addr(_ip), W1
	MOV.B	#255, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,421 :: 		if ((Dato!=Hdr)&&(ip==0)){                    //Verifica si el primer dato en llegar es diferente al identificador del inicio de trama
L__UART1Interrupt150:
L__UART1Interrupt149:
;ADC_DAC.c,424 :: 		if ((BanT==1)&&(ip!=0)){
	MOV	#lo_addr(_BanT), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__UART1Interrupt215
	GOTO	L__UART1Interrupt152
L__UART1Interrupt215:
	MOV	#lo_addr(_ip), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA NZ	L__UART1Interrupt216
	GOTO	L__UART1Interrupt151
L__UART1Interrupt216:
L__UART1Interrupt144:
;ADC_DAC.c,425 :: 		Ptcn[ip] = Dato;                          //Almacena el resto de datos en la trama de peticion si la bandera de trama esta activada
	MOV	#lo_addr(_ip), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Ptcn), W0
	ADD	W0, W1, W1
	MOV	#lo_addr(_Dato), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,424 :: 		if ((BanT==1)&&(ip!=0)){
L__UART1Interrupt152:
L__UART1Interrupt151:
;ADC_DAC.c,428 :: 		ip++;                                         //Aumenta el subindice una unidad
	MOV.B	#1, W1
	MOV	#lo_addr(_ip), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,429 :: 		if (ip==Psize){                               //Verifica que se haya terminado de llenar la trama de datos
	MOV	#lo_addr(_ip), W0
	MOV.B	[W0], W0
	CP.B	W0, #6
	BRA Z	L__UART1Interrupt217
	GOTO	L_UART1Interrupt100
L__UART1Interrupt217:
;ADC_DAC.c,430 :: 		BanP = 1;                                 //Habilita la bandera de lectura de datos
	MOV	#lo_addr(_BanP), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,431 :: 		BanT = 0;
	MOV	#lo_addr(_BanT), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,432 :: 		ip=0;                                     //Limpia el subindice de la trama de peticion para permitir una nueva secuencia de recepcion de datos
	MOV	#lo_addr(_ip), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,433 :: 		}
L_UART1Interrupt100:
;ADC_DAC.c,435 :: 		U1RXIF_bit = 0;                               //Limpia la bandera de interrupcion de UARTRX
	BCLR	U1RXIF_bit, BitPos(U1RXIF_bit+0)
;ADC_DAC.c,437 :: 		}
L_end_UART1Interrupt:
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	52
	RETFIE
; end of _UART1Interrupt

_Timer1Interrupt:
	PUSH	52
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;ADC_DAC.c,440 :: 		void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{
;ADC_DAC.c,442 :: 		SAMP_bit = 0;                                 //Limpia el bit SAMP para iniciar la conversion del ADC
	BCLR	SAMP_bit, BitPos(SAMP_bit+0)
;ADC_DAC.c,443 :: 		while (!AD1CON1bits.DONE);                    //Espera hasta que se complete la conversion
L_Timer1Interrupt101:
	BTSC	AD1CON1bits, #0
	GOTO	L_Timer1Interrupt102
	GOTO	L_Timer1Interrupt101
L_Timer1Interrupt102:
;ADC_DAC.c,444 :: 		if (i<nm){
	MOV	_i, W1
	MOV	#350, W0
	CP	W1, W0
	BRA LTU	L__Timer1Interrupt219
	GOTO	L_Timer1Interrupt103
L__Timer1Interrupt219:
;ADC_DAC.c,445 :: 		M[i] = ADC1BUF0;                           //Almacena el valor actual de la conversion del ADC en el vector M
	MOV	_i, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W1
	MOV	ADC1BUF0, WREG
	MOV	W0, [W1]
;ADC_DAC.c,446 :: 		i++;                                       //Aumenta en 1 el subindice del vector de Muestras
	MOV	#1, W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,447 :: 		} else {
	GOTO	L_Timer1Interrupt104
L_Timer1Interrupt103:
;ADC_DAC.c,448 :: 		bm = 1;                                    //Cambia el valor de la bandera bm para terminar con el muestreo y dar comienzo al procesamiento de la se�al
	MOV	#lo_addr(_bm), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,449 :: 		T1CON.TON = 0;                             //Apaga el TMR1
	BCLR	T1CON, #15
;ADC_DAC.c,450 :: 		IEC0.T1IE = 0;                             //Desabilita la interrupcion por desborde del TMR1
	BCLR	IEC0, #3
;ADC_DAC.c,451 :: 		}
L_Timer1Interrupt104:
;ADC_DAC.c,452 :: 		T1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,453 :: 		}
L_end_Timer1Interrupt:
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	52
	RETFIE
; end of _Timer1Interrupt

_Timer2Interrupt:
	PUSH	52
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;ADC_DAC.c,456 :: 		void Timer2Interrupt() iv IVT_ADDR_T2INTERRUPT{
;ADC_DAC.c,457 :: 		if (contp<10){                                //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (
	MOV	_contp, W0
	CP	W0, #10
	BRA LTU	L__Timer2Interrupt221
	GOTO	L_Timer2Interrupt105
L__Timer2Interrupt221:
;ADC_DAC.c,458 :: 		RB2_bit = ~RB2_bit;                      //Conmuta el valor del pin RB14
	BTG	RB2_bit, BitPos(RB2_bit+0)
;ADC_DAC.c,459 :: 		}else {
	GOTO	L_Timer2Interrupt106
L_Timer2Interrupt105:
;ADC_DAC.c,460 :: 		RB2_bit = 0;                            //Pone a cero despues de enviar todos los pulsos de exitacion.
	BCLR	RB2_bit, BitPos(RB2_bit+0)
;ADC_DAC.c,462 :: 		if (contp==110){
	MOV	#110, W1
	MOV	#lo_addr(_contp), W0
	CP	W1, [W0]
	BRA Z	L__Timer2Interrupt222
	GOTO	L_Timer2Interrupt107
L__Timer2Interrupt222:
;ADC_DAC.c,463 :: 		IEC0.T2IE = 0;                       //Desabilita la interrupcion por desborde del TMR2 para no interferir con las interrupciones por desborde de TMR1
	BCLR	IEC0, #7
;ADC_DAC.c,464 :: 		T2CON.TON = 0;                       //Apaga el TMR2
	BCLR	T2CON, #15
;ADC_DAC.c,465 :: 		IEC0.T1IE = 1;                       //Habilita la interrupcion por desborde del TMR1 para dar inicio al muestreo del ADC
	BSET	IEC0, #3
;ADC_DAC.c,466 :: 		TMR1 = 0;                            //Encera el TMR1
	CLR	TMR1
;ADC_DAC.c,467 :: 		T1IF_bit = 0;                        //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,468 :: 		T1CON.TON = 1;                       //Enciende el TMR1
	BSET	T1CON, #15
;ADC_DAC.c,469 :: 		bm=0;
	MOV	#lo_addr(_bm), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,470 :: 		}
L_Timer2Interrupt107:
;ADC_DAC.c,472 :: 		}
L_Timer2Interrupt106:
;ADC_DAC.c,473 :: 		contp++;                                      //Aumenta el contador en una unidad.
	MOV	#1, W1
	MOV	#lo_addr(_contp), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,474 :: 		T2IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;ADC_DAC.c,475 :: 		}
L_end_Timer2Interrupt:
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	52
	RETFIE
; end of _Timer2Interrupt

_Configuracion:

;ADC_DAC.c,479 :: 		void Configuracion(){
;ADC_DAC.c,482 :: 		CLKDIVbits.PLLPRE = 0;                                                     //PLLPRE<4:0> = 0  ->  N1 = 2    8MHz / 2 = 4MHz
	PUSH	W10
	PUSH	W11
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#224, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,483 :: 		PLLFBD = 38;                                                               //PLLDIV<8:0> = 38 ->  M = 40    4MHz * 40 = 160MHz
	MOV	#38, W0
	MOV	WREG, PLLFBD
;ADC_DAC.c,484 :: 		CLKDIVbits.PLLPOST = 0;                                                    //PLLPOST<1:0> = 0 ->  N2 = 2    160MHz / 2 = 80MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,487 :: 		AD1PCFGL = 0xFFFD;                                                         //Configura el puerto AN1 como entrada analogica y todas las demas como digitales
	MOV	#65533, W0
	MOV	WREG, AD1PCFGL
;ADC_DAC.c,488 :: 		TRISA1_bit = 1;                                                            //Establece el pin RA1 como entrada
	BSET	TRISA1_bit, BitPos(TRISA1_bit+0)
;ADC_DAC.c,489 :: 		TRISB = 0xFF40;                                                            //TRISB = 11111111 01000000
	MOV	#65344, W0
	MOV	WREG, TRISB
;ADC_DAC.c,492 :: 		AD1CON1.AD12B = 0;                                                         //Configura el ADC en modo de 10 bits
	BCLR	AD1CON1, #10
;ADC_DAC.c,493 :: 		AD1CON1bits.FORM = 0x00;                                                   //Formato de la canversion: 00->(0_1023)|01->(-512_511)|02->(0_0.999)|03->(-1_0.999)
	MOV	AD1CON1bits, W1
	MOV	#64767, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON1bits
;ADC_DAC.c,494 :: 		AD1CON1.SIMSAM = 0;                                                        //0 -> Muestrea m�ltiples canales individualmente en secuencia
	BCLR	AD1CON1, #3
;ADC_DAC.c,495 :: 		AD1CON1.ADSIDL = 0;                                                        //Continua con la operacion del modulo durante el modo desocupado
	BCLR	AD1CON1, #13
;ADC_DAC.c,496 :: 		AD1CON1.ASAM = 1;                                                          //Muestreo automatico
	BSET	AD1CON1, #2
;ADC_DAC.c,497 :: 		AD1CON1bits.SSRC = 0x00;                                                   //Conversion manual
	MOV	#lo_addr(AD1CON1bits), W0
	MOV.B	[W0], W1
	MOV.B	#31, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(AD1CON1bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,498 :: 		AD1CON2bits.VCFG = 0;                                                      //Selecciona AVDD y AVSS como fuentes de voltaje de referencia
	MOV	AD1CON2bits, W1
	MOV	#8191, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON2bits
;ADC_DAC.c,499 :: 		AD1CON2bits.CHPS = 0;                                                      //Selecciona unicamente el canal CH0
	MOV	AD1CON2bits, W1
	MOV	#64767, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON2bits
;ADC_DAC.c,500 :: 		AD1CON2.CSCNA = 0;                                                         //No escanea las entradas de CH0 durante la Muestra A
	BCLR	AD1CON2, #10
;ADC_DAC.c,501 :: 		AD1CON2.BUFM = 0;                                                          //Bit de selecci�n del modo de relleno del b�fer, 0 -> Siempre comienza a llenar el buffer desde el principio
	BCLR	AD1CON2, #1
;ADC_DAC.c,502 :: 		AD1CON2.ALTS = 0x00;                                                       //Utiliza siempre la selecci�n de entrada de canal para la muestra A
	BCLR	AD1CON2, #0
;ADC_DAC.c,503 :: 		AD1CON3.ADRC = 0;                                                          //Selecciona el reloj de conversion del ADC derivado del reloj del sistema
	BCLR	AD1CON3, #15
;ADC_DAC.c,504 :: 		AD1CON3bits.ADCS = 0x02;                                                   //Configura el periodo del reloj del ADC fijando el valor de los bits ADCS segun la formula: TAD = TCY*(ADCS+1) = 75ns  -> ADCS = 2
	MOV.B	#2, W0
	MOV.B	W0, W1
	MOV	#lo_addr(AD1CON3bits), W0
	XOR.B	W1, [W0], W1
	MOV.B	#255, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(AD1CON3bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(AD1CON3bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,505 :: 		AD1CON3bits.SAMC = 0x02;                                                   //Auto Sample Time bits, 2 -> 2*TAD (minimo periodo de muestreo para 10 bits)
	MOV	#512, W0
	MOV	W0, W1
	MOV	#lo_addr(AD1CON3bits), W0
	XOR	W1, [W0], W1
	MOV	#7936, W0
	AND	W1, W0, W1
	MOV	#lo_addr(AD1CON3bits), W0
	XOR	W1, [W0], W1
	MOV	W1, AD1CON3bits
;ADC_DAC.c,506 :: 		AD1CHS0.CH0NB = 0;                                                         //Channel 0 negative input is VREF-
	BCLR	AD1CHS0, #15
;ADC_DAC.c,507 :: 		AD1CHS0bits.CH0SB = 0x01;                                                  //Channel 0 positive input is AN1
	MOV	#256, W0
	MOV	W0, W1
	MOV	#lo_addr(AD1CHS0bits), W0
	XOR	W1, [W0], W1
	MOV	#7936, W0
	AND	W1, W0, W1
	MOV	#lo_addr(AD1CHS0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, AD1CHS0bits
;ADC_DAC.c,508 :: 		AD1CHS0.CH0NA = 0;                                                         //Channel 0 negative input is VREF-
	BCLR	AD1CHS0, #7
;ADC_DAC.c,509 :: 		AD1CHS0bits.CH0SA = 0x01;                                                  //Channel 0 positive input is AN1
	MOV.B	#1, W0
	MOV.B	W0, W1
	MOV	#lo_addr(AD1CHS0bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #31, W1
	MOV	#lo_addr(AD1CHS0bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(AD1CHS0bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,510 :: 		AD1CHS123 = 0;                                                             //AD1CHS123: ADC1 INPUT CHANNEL 1, 2, 3 SELECT REGISTER
	CLR	AD1CHS123
;ADC_DAC.c,511 :: 		AD1CSSL = 0x00;                                                            //Se salta todos los puertos ANx para los escaneos de entrada
	CLR	AD1CSSL
;ADC_DAC.c,512 :: 		AD1CON1.ADON = 1;                                                          //Enciende el modulo ADC
	BSET	AD1CON1, #15
;ADC_DAC.c,515 :: 		T1CON = 0x8000;                                                            //Habilita el TMR1, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
	MOV	#32768, W0
	MOV	WREG, T1CON
;ADC_DAC.c,516 :: 		IEC0.T1IE = 0;                                                             //Inicializa el programa con la interrupcion por desborde de TMR1 desabilitada para no interferir con la lectura del sensor de temperatura
	BCLR	IEC0, #3
;ADC_DAC.c,517 :: 		T1IF_bit = 0;                                                              //Limpia la bandera de interrupcion
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,518 :: 		PR1 = 200;                                                                 //Genera una interrupcion cada 5us (Fs=200KHz)
	MOV	#200, W0
	MOV	WREG, PR1
;ADC_DAC.c,521 :: 		T2CON = 0x8000;                                                            //Habilita el TMR2, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
	MOV	#32768, W0
	MOV	WREG, T2CON
;ADC_DAC.c,522 :: 		IEC0.T2IE = 0;                                                             //Inicializa el programa con la interrupcion por desborde de TMR2 desabilitada para no interferir con la lectura del sensor de temperatura
	BCLR	IEC0, #7
;ADC_DAC.c,523 :: 		T2IF_bit = 0;                                                              //Limpia la bandera de interrupcion
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;ADC_DAC.c,524 :: 		PR2 = 500;                                                                 //Genera una interrupcion cada 12.5us
	MOV	#500, W0
	MOV	WREG, PR2
;ADC_DAC.c,527 :: 		RPINR18bits.U1RXR = 0x06;                                                  //Asisgna Rx a RP6
	MOV.B	#6, W0
	MOV.B	W0, W1
	MOV	#lo_addr(RPINR18bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #31, W1
	MOV	#lo_addr(RPINR18bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(RPINR18bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,528 :: 		RPOR3bits.RP7R = 0x03;                                                     //Asigna Tx a RP7
	MOV	#768, W0
	MOV	W0, W1
	MOV	#lo_addr(RPOR3bits), W0
	XOR	W1, [W0], W1
	MOV	#7936, W0
	AND	W1, W0, W1
	MOV	#lo_addr(RPOR3bits), W0
	XOR	W1, [W0], W1
	MOV	W1, RPOR3bits
;ADC_DAC.c,529 :: 		IEC0.U1RXIE = 1;                                                           //Habilita la interrupcion por recepcion de dato por UART
	BSET	IEC0, #11
;ADC_DAC.c,530 :: 		U1RXIF_bit = 0;                                                            //Limpia la bandera de interrupcion de UARTRX
	BCLR	U1RXIF_bit, BitPos(U1RXIF_bit+0)
;ADC_DAC.c,531 :: 		UART1_Init(9600);                                                          //Inicializa el modulo UART a 9600 bps
	MOV	#9600, W10
	MOV	#0, W11
	CALL	_UART1_Init
;ADC_DAC.c,534 :: 		IPC0bits.T1IP = 0x06;                                                      //Nivel de prioridad de la interrupcion por desbordamiento del TMR1
	MOV	#24576, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC0bits
;ADC_DAC.c,535 :: 		IPC1bits.T2IP = 0x05;                                                      //Nivel de prioridad de la interrupcion por desbordamiento del TMR2
	MOV	#20480, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC1bits
;ADC_DAC.c,536 :: 		IPC2bits.U1RXIP = 0x07;                                                    //Nivel de prioridad de la interrupcion UARTRX
	MOV	IPC2bits, W1
	MOV	#28672, W0
	IOR	W1, W0, W0
	MOV	WREG, IPC2bits
;ADC_DAC.c,540 :: 		}
L_end_Configuracion:
	POP	W11
	POP	W10
	RETURN
; end of _Configuracion

_main:
	MOV	#2048, W15
	MOV	#6142, W0
	MOV	WREG, 32
	MOV	#1, W0
	MOV	WREG, 52
	MOV	#4, W0
	IOR	68

;ADC_DAC.c,544 :: 		void main() {
;ADC_DAC.c,546 :: 		Configuracion();
	PUSH	W10
	CALL	_Configuracion
;ADC_DAC.c,548 :: 		Delay_ms(100);                                                             //Espera hata que el modulo UART se estabilice
	MOV	#21, W8
	MOV	#22619, W7
L_main108:
	DEC	W7
	BRA NZ	L_main108
	DEC	W8
	BRA NZ	L_main108
;ADC_DAC.c,549 :: 		RB5_bit = 0;                                                               //Establece el Max485 en modo de lectura
	BCLR	RB5_bit, BitPos(RB5_bit+0)
;ADC_DAC.c,551 :: 		Id = (PORTB&0xFF00)>>8;                                                    //Lee el Id de esclavo establecido por el dipswitch
	MOV	PORTB, W1
	MOV	#65280, W0
	AND	W1, W0, W0
	LSR	W0, #8, W2
	MOV	W2, _Id
;ADC_DAC.c,552 :: 		T2adj = 460.0;                                                             //Factor de calibracion de T2: Con Temp=20 y Vsnd=343.2, reduce la medida 1mm por cada 3 unidades que se aumente a este factor
	MOV	#0, W0
	MOV	#17382, W1
	MOV	W0, _T2adj
	MOV	W1, _T2adj+2
;ADC_DAC.c,553 :: 		Altura = 275;                                                              //Fija la altura de instalacion del sensor en 275mm
	MOV	#275, W0
	MOV	W0, _Altura
;ADC_DAC.c,554 :: 		Kadj = 0;                                                                  //Fija la constante de ajuste en 0
	CLR	W0
	MOV	W0, _Kadj
;ADC_DAC.c,556 :: 		chDP = &DatoPtcn;                                                          //Asocia el valor de DatoPtcn al puntero chDP
	MOV	#lo_addr(_DatoPtcn), W0
	MOV	W0, _chDP
;ADC_DAC.c,557 :: 		ip=0;
	MOV	#lo_addr(_ip), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,560 :: 		Rspt[0] = Hdr;                                                             //Se rellena el primer byte de la trama de respuesta con el delimitador de inicio de trama
	MOV	#lo_addr(_Rspt), W1
	MOV.B	#58, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,561 :: 		Rspt[1] = Id;                                                              //Se rellena el segundo byte de la trama de repuesta con el Id del tipo de sensor
	MOV	#lo_addr(_Rspt+1), W0
	MOV.B	W2, [W0]
;ADC_DAC.c,562 :: 		Rspt[Rsize-1] = End;                                                       //Se rellena el ultimo byte de la trama de repuesta con el delimitador de final de trama
	MOV	#lo_addr(_Rspt+5), W1
	MOV.B	#13, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,564 :: 		Calcular();                                                                //Realiza una secuencia de calculo inicial para tener algo que responder cunado se le pida
	CALL	_Calcular
;ADC_DAC.c,566 :: 		while(1){
L_main110:
;ADC_DAC.c,577 :: 		if (BanP==1){                                                     //Verifica si se realizo una peticion
	MOV	#lo_addr(_BanP), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__main225
	GOTO	L_main112
L__main225:
;ADC_DAC.c,579 :: 		if ((Ptcn[1]==Id)&&(Ptcn[Psize-1]==End)){                      //Verifica el identificador de esclavo y el byte de final de trama
	MOV	#lo_addr(_Ptcn+1), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Id), W0
	CP	W1, [W0]
	BRA Z	L__main226
	GOTO	L__main155
L__main226:
	MOV	#lo_addr(_Ptcn+5), W0
	MOV.B	[W0], W0
	CP.B	W0, #13
	BRA Z	L__main227
	GOTO	L__main154
L__main227:
L__main153:
;ADC_DAC.c,581 :: 		Fcn = Ptcn[2];                                              //Almacena el tipo de funcion requerida
	MOV	#lo_addr(_Fcn), W1
	MOV	#lo_addr(_Ptcn+2), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,582 :: 		DatoPtcn = 0;                                               //Limpia la variable DatoPtcn
	CLR	W0
	MOV	W0, _DatoPtcn
;ADC_DAC.c,584 :: 		switch(Fcn){
	GOTO	L_main116
;ADC_DAC.c,585 :: 		case 1:    //01: Lee el registro principal (01:Nivel)
L_main118:
;ADC_DAC.c,586 :: 		Calcular();                                  //Realiza una secuencia de calculo
	CALL	_Calcular
;ADC_DAC.c,587 :: 		Responder(0x01);                             //Envia la trama de repuesta con el valor del registro principal
	MOV	#1, W10
	CALL	_Responder
;ADC_DAC.c,588 :: 		break;
	GOTO	L_main117
;ADC_DAC.c,590 :: 		case 2:    //02: Lee el registro especifico (01:Nivel, 02:Caudal, 03:Distancia, 04:TOF, 05:Temperatura, 06:Altura )
L_main119:
;ADC_DAC.c,591 :: 		*chDP = Ptcn[4];                             //Almacena el byte 4 de la trama de peticion en el LSB de la variable DatoPtcn
	MOV	#lo_addr(_Ptcn+4), W1
	MOV	_chDP, W0
	MOV.B	[W1], [W0]
;ADC_DAC.c,592 :: 		*(chDP+1) = Ptcn[3];                         //Almacena el byte 3 de la trama de peticion en el MSB de la variable DatoPtcn
	MOV	_chDP, W0
	ADD	W0, #1, W1
	MOV	#lo_addr(_Ptcn+3), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,593 :: 		Responder(DatoPtcn);                         //Envia la trama de repuesta con el valor del registro requerido
	MOV	_DatoPtcn, W10
	CALL	_Responder
;ADC_DAC.c,594 :: 		break;
	GOTO	L_main117
;ADC_DAC.c,596 :: 		case 3:    //03: Establece la altura de instalacion
L_main120:
;ADC_DAC.c,597 :: 		*chDP = Ptcn[4];                             //Almacena el byte 4 de la trama de peticion en el LSB de la variable DatoPtcn
	MOV	#lo_addr(_Ptcn+4), W1
	MOV	_chDP, W0
	MOV.B	[W1], [W0]
;ADC_DAC.c,598 :: 		*(chDP+1) = Ptcn[3];                         //Almacena el byte 3 de la trama de peticion en el MSB de la variable DatoPtcn
	MOV	_chDP, W0
	ADD	W0, #1, W1
	MOV	#lo_addr(_Ptcn+3), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,599 :: 		Altura =  DatoPtcn;                          //Almacena el valor de DatoPtcn en la variable Altura
	MOV	_DatoPtcn, W0
	MOV	W0, _Altura
;ADC_DAC.c,600 :: 		Calcular();                                  //Realiza una secuencia de calculo
	CALL	_Calcular
;ADC_DAC.c,601 :: 		Responder(0x06);                             //Envia la trama de repuesta con el valor de la Altura de instalacion
	MOV	#6, W10
	CALL	_Responder
;ADC_DAC.c,602 :: 		break;
	GOTO	L_main117
;ADC_DAC.c,604 :: 		case 4:    //04: Establece el factor de calibracion
L_main121:
;ADC_DAC.c,605 :: 		*chDP = Ptcn[4];                             //Almacena el byte 4 de la trama de peticion en el LSB de la variable DatoPtcn
	MOV	#lo_addr(_Ptcn+4), W1
	MOV	_chDP, W0
	MOV.B	[W1], [W0]
;ADC_DAC.c,606 :: 		Kadj = DatoPtcn;                             //Almacena el valor de DatoPtcn en la variable Kadj
	MOV	_DatoPtcn, W0
	MOV	W0, _Kadj
;ADC_DAC.c,607 :: 		if (Ptcn[3]==0x11){                          //Verifica si el byte 3 es igual a 0x11, de ser asi cambia el signo de la variable Kadj
	MOV	#lo_addr(_Ptcn+3), W0
	MOV.B	[W0], W0
	CP.B	W0, #17
	BRA Z	L__main228
	GOTO	L_main122
L__main228:
;ADC_DAC.c,608 :: 		Kadj = -Kadj;
	MOV	_Kadj, W1
	MOV	#lo_addr(_Kadj), W0
	SUBR	W1, #0, [W0]
;ADC_DAC.c,609 :: 		}
L_main122:
;ADC_DAC.c,610 :: 		Calcular();                                  //Realiza una secuencia de calculo
	CALL	_Calcular
;ADC_DAC.c,611 :: 		Responder(0x01);                             //Envia la trama de repuesta con el valor del Nivel calculado
	MOV	#1, W10
	CALL	_Responder
;ADC_DAC.c,612 :: 		break;
	GOTO	L_main117
;ADC_DAC.c,614 :: 		default:   Rspt[3]=0x00;                                //Rellena el campo de datos con el mensaje de error 0x00E1: Funcion no disponible
L_main123:
	MOV	#lo_addr(_Rspt+3), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,615 :: 		Rspt[4]=0xE1;
	MOV	#lo_addr(_Rspt+4), W1
	MOV.B	#225, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,616 :: 		Rspt[2]=0xEE;                                //Rellena el byte 2 con el aviso de error 0xEE
	MOV	#lo_addr(_Rspt+2), W1
	MOV.B	#238, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,617 :: 		break;
	GOTO	L_main117
;ADC_DAC.c,618 :: 		}
L_main116:
	MOV	#lo_addr(_Fcn), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA NZ	L__main229
	GOTO	L_main118
L__main229:
	MOV	#lo_addr(_Fcn), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA NZ	L__main230
	GOTO	L_main119
L__main230:
	MOV	#lo_addr(_Fcn), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA NZ	L__main231
	GOTO	L_main120
L__main231:
	MOV	#lo_addr(_Fcn), W0
	MOV.B	[W0], W0
	CP.B	W0, #4
	BRA NZ	L__main232
	GOTO	L_main121
L__main232:
	GOTO	L_main123
L_main117:
;ADC_DAC.c,620 :: 		for (ipp=0;ipp<Psize;ipp++){
	MOV	#lo_addr(_ipp), W1
	CLR	W0
	MOV.B	W0, [W1]
L_main124:
	MOV	#lo_addr(_ipp), W0
	MOV.B	[W0], W0
	CP.B	W0, #6
	BRA LTU	L__main233
	GOTO	L_main125
L__main233:
;ADC_DAC.c,621 :: 		Ptcn[ipp]=0;                                            //Limpia la trama de peticion
	MOV	#lo_addr(_ipp), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Ptcn), W0
	ADD	W0, W1, W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,620 :: 		for (ipp=0;ipp<Psize;ipp++){
	MOV.B	#1, W1
	MOV	#lo_addr(_ipp), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,622 :: 		}
	GOTO	L_main124
L_main125:
;ADC_DAC.c,624 :: 		BanP = 0;                                                   //Limpia la bandera de lectura de datos
	MOV	#lo_addr(_BanP), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,626 :: 		}else{
	GOTO	L_main127
;ADC_DAC.c,579 :: 		if ((Ptcn[1]==Id)&&(Ptcn[Psize-1]==End)){                      //Verifica el identificador de esclavo y el byte de final de trama
L__main155:
L__main154:
;ADC_DAC.c,627 :: 		for (ipp=0;ipp<Psize;ipp++){
	MOV	#lo_addr(_ipp), W1
	CLR	W0
	MOV.B	W0, [W1]
L_main128:
	MOV	#lo_addr(_ipp), W0
	MOV.B	[W0], W0
	CP.B	W0, #6
	BRA LTU	L__main234
	GOTO	L_main129
L__main234:
;ADC_DAC.c,628 :: 		Ptcn[ipp]=0;                                         //Limpia la trama de peticion
	MOV	#lo_addr(_ipp), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Ptcn), W0
	ADD	W0, W1, W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,627 :: 		for (ipp=0;ipp<Psize;ipp++){
	MOV.B	#1, W1
	MOV	#lo_addr(_ipp), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,629 :: 		}
	GOTO	L_main128
L_main129:
;ADC_DAC.c,630 :: 		BanP = 0;                                                //Limpia la bandera de lectura de datos
	MOV	#lo_addr(_BanP), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,631 :: 		}
L_main127:
;ADC_DAC.c,632 :: 		}
L_main112:
;ADC_DAC.c,634 :: 		}
	GOTO	L_main110
;ADC_DAC.c,636 :: 		}
L_end_main:
	POP	W10
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main
