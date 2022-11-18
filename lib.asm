.8086
.model small
.stack 100h
.data
	tfinal		db 4 dup (30) 		;inicializa la hora final
	FIL			db 19
	derecha		db 4Dh
	izquierda 	db 4Bh
	vec24h		db 80 dup (24h)
	msj			db "Cantidad de rocas: "
	contar		db "000",24h,24h,24h,24h,24h,24h
	vacio       dw 500 dup (20h),24h
	msjVict     db "felicitaciones, llegaste a los 10 puntos",0dh,0ah,24h
	msjGO		db "GAME OVER",0dh,0ah,24h
	msjAux		db "Gracias por jugar",0dh,0ah
	creadores   db "Creadores:",0dh,0ah
		        db " Diaz, Matias",0dh,0ah
	  	        db " Narmontas Theo",0dh,0ah
				db " Pabon Anyair",0dh,0ah
	           	db " Perez Adrian",0dh,0ah,24h
 
.code
public ESPERA
public RANDOM
public cursorX
public imp
public extremos
public movX
public scanCode
public initialPosition
public regToAscii
public victoria
public mensajeFinal
public gOver
 
	;vamos a estar en modo vídeo, y el cursor será a modo de texto
	iniciarTer proc
		push ax
 
		mov ah, 00h
		mov al, 01h
		int 10h
 
		pop ax
		ret
	iniciarTer endp
 
	;-------------------------------------------------------------------------------------------------
	;Función cursorX - 			Coloca el cursor en la fila y columna del vec X
	;		Recibe: 			recibe en dh Fil
	;		Devuelve: 			Nada
	;-------------------------------------------------------------------------------------------------
	cursorX proc
		mov ah,02h  	;funcion de posicion del cursor donde dibujar
		mov bh,00h  	;pag de trabajo
		mov dh, cl		;coordenada fila
		mov dl,0    	;coordenada col
		int 10h
 
		ret
	cursorX endp
 
	;funcion que imprime
	imp proc
		mov ah,09h
		int 21h
 
		ret
	imp endp
 
	;ESTA FUNCION MUEVE LOS EXTREMOS
	;[bp+4] -> VARIABLE DONDE ESTÁ LA X
	extremos proc
		push bp
		mov bp, sp
 
		mov di, ss:[bp+4]
		add di, bx
 
		cmp bx, 0
		je lateral_izq
		cmp bx, 37
		jne finisExtremos
 
		lateral_der:
			mov byte ptr[di], 20h
			mov bx,1
			mov di, 123
		jmp finisExtremos
 
		lateral_izq:
			mov byte ptr[di], 20h
			mov bx,36
			mov di, 123
 
		finisExtremos:
			pop bp
			ret 2
	extremos endp
 
	;Mueve la x
	;[bp+4] -> offset de varX
	movX proc
		push bp
		mov bp,sp 
 
		push ax
		push cx
		push dx
		push si
		pushf
 
		mov si,ss:[bp+4] 			;offset varX
		add si,bx
 
 
		cmp al, derecha
		je moveToRight
		cmp al, izquierda
		je moveToLeft
		jmp nada
 
		moveToRight:
			mov byte ptr [si],20h		;pinto espacio
			inc si
			inc bx						;muevo a la izquierda
			jmp continueMoveX
 
		moveToLeft:
			mov byte ptr [si],20h		;pinto espacio
			dec si
			dec bx	
 
		continueMoveX:
			mov byte ptr [si],"X"		;pinto X
			mov di, 321
 
		mov cl, FIL
		call cursorX;	
		mov dx, ss:[bp+4] 
		call imp
 
		nada:
			popf
			pop si
			pop dx
			pop cx 
			pop ax
			pop bp
 
		ret 2
	movX endp
 
	;-------------------------------------------------------------------------------------------------
	;Función ESPERA 
	;		Realiza: 		Muestra los scores de los dos jugadores en pantalla, espera un tiempo parametrizable y los borra
	;		Recibe: 		AH un número entero con la cantidad de segundos a esperar
	;		Devuelve: 	Nada
	;----------------------------------------------------------------------------------------------------------------------------
	ESPERA proc
		push ax		; guardo los registros que ateraré
		push bx
		push cx
		push dx
 
		mov bh, ah	; paso por BH la cantidad de segundos de espera
		mov bl, al	; paso por BH la cantidad de segundos de espera
 
		call tiempo  	;llamado a seteo de tiempos
		call terminal	;llamado hasta obtener los segundos de espera
 
		pop dx	;restauro registros
		pop cx
		pop bx
		pop ax
 
		ret
	ESPERA endp
 
	;-------------------------------------------------------------------------------------------------
	;Función TIEMPO - 	Guarda la hora de inicio de la espera y la hora final 
	;								que es la de inicio más los segundos de espera que
	;								se reciben por BH
	;		Recibe: 		BH un número entero con la cantidad de segundos a esperar
	;		Devuelve: 	Nada
	;-------------------------------------------------------------------------------------------------
	tiempo proc
		mov ah, 2ch	; Funcion del D.O.S. para obtener la hora actual
		int 21h
 
		add dl,bl 					;EN DL SE DEVUELVE 1/100 segundos, no los 60 seg
		cmp dl,63h	;63h		; Si la suma supera 59 significa que pasa al minuto siguiente -> ACA CAPAZ DEBA IR
		jle step0			; Como no supera los 59 segundos, salto
		sub dl,64h			; Superó los 59 segundos, resto 60 segundos
		inc dh				; Sumo 1 minuto
 
	step0:
		add dh, bh			; Sumo los segundos de la hora actual los segundos de espera recibidos en el parámetro
 
		cmp dh, 3Bh			; Si la suma supera 59 significa que pasa al minuto siguiente
		jle step1			; Como no supera los 59 segundos, salto
		sub dh, 3Ch			; Superó los 59 segundos, resto 60 segundos
		inc cl				; Sumo 1 minuto
 
	step1:
		cmp cl, 3Bh			; Hago la misma comparación de los minutos con 59 para ver si se pasa de hora
		jle step2
		sub cl, 3Ch			; Resto 60 minutos
		inc ch				; Sumo 1 hora
 
	step2:
		cmp ch, 17h	; 		Lo mismo pero con las horas si se pasan de 23
		jle step3
		sub ch, 18h			; Resto 24 horas
 
	step3:
		mov byte ptr [offset tfinal], cl		; Cargo el vector con la hora final (con la espera sumada)
		mov byte ptr [offset tfinal + 1], ch
		mov byte ptr [offset tfinal + 2], dl
		mov byte ptr [offset tfinal + 3], dh
 
		ret
	tiempo endp
 
	;-------------------------------------------------------------------------------------------------
	;Función TERMINAL - 	Compara la hora del computador con la hora final
	;		Recibe: 		BH un número entero con la cantidad de segundos a esperar
	;		Devuelve: 	Nada
	;-------------------------------------------------------------------------------------------------
	terminal proc
	tick:
		mov ah,2ch		; Hora actual
		int 21h
		mov bx, word ptr [offset tfinal]
		cmp cx,bx		; Comparo HS:MIN actuales con la HS:MIN finales
		jl tick				; Si no llegaron aún, epiezo de nuevo
 
		mov bx, word ptr [offset tfinal +2]
		cmp dx,bx		; Comparo SS:CENTESIMAS DE SEG actuales con la SEG:CENTESIMAS DE SEG finales
		jl tick
 
	final:
		ret		; Se alcanzó la hora final, vuelvo
	terminal endp
 
	RANDOM proc
		push cx
		push dx
		mov ah, 2ch
		int 21h
		xor ax, ax
		mov al, dl
		mov cl, 03h ;0ah    -----> ELIMINE DIV VA DE 0 A 99
		div cl
		xor ah, ah
		pop dx
		pop cx
		ret
	RANDOM endp
 
	scanCode proc
		in al,60h
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
 
		ret 
	scanCode endp
 
 
	initialPosition proc
		mov cl, 21
		call cursorX;
 
		lea dx, vec24h
		call imp
 
		mov cl, 23
		call cursorX;
 
		lea dx, msj
		call imp
 
		mov cl, 19
		call cursorX;
 
		ret
	initialPosition endp
 
	regToAscii proc
	;
	;RECIBE POR STACK - SEGUNDA** OFFSET DEL VALOR EN DECIMAL
	;MODIFICA EL "000" AL VALOR DE LA VARIABLE EN DECIMAL
		push bp
		mov bp, sp
 
		push ax
		push bx
		push cx
		push dx
		push si
		pushf
 
		xor ax,ax
 
		lea bx, contar
		add bx, 2         
		mov si, ss:[bp+4] ;offset del numero
		mov al, byte ptr[si] 
		mov dl, 10
		mov cx, 3
 
convierte:
		div dl
		add ah, 30h
		mov byte ptr[bx], ah 
		xor ah, ah
		dec bx 
	loop convierte
 
		popf
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		pop bp
 
		ret 2
	regToAscii endp
 
	victoria proc

	mov cl,0
	call cursorX; ;imprime vacio
	lea dx,vacio
	call imp
	mov cl,5
	call cursorX;
	lea dx,msjVict ;imprime un mensaje
	call imp
	ret
 
	victoria endp

	gOver proc
	
	mov cl,0
	call cursorX; ;imprime vacio
	lea dx,vacio
	call imp
	mov cl,5
	call cursorX;
	lea dx,msjGO ;imprime un mensaje
	call imp
	ret
 
	gOver endp
 
	mensajeFinal proc
	xor ax,ax
	xor dx,dx
 
	lea dx,msjAux
	call imp
 
	xor ax,ax
	xor dx,dx
	mensajeFinal endp
end