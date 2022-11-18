.8086
.model small
.stack 100h
.data
	varX 				db 39 dup (20h),24h,24h,24h,24h,24h
	vec0				dw 360 dup (20h),24h,24h
	FIL					db 19
	quit				db 10h
	vec24h				db 80 dup (24h)
	imprimeIgualeVar 	db "si son iguales", 24h
	counter 			db 0
	fail				db 0
 
.code
	main proc
		extrn ESPERA:proc
		;extrn iniciarTer:proc
		extrn movX:proc
		extrn extremos:proc
		extrn RANDOM:proc
		extrn cursorX:proc
		extrn imp:proc
		extrn scanCode:proc
		extrn initialPosition:proc
		extrn regToAscii:proc
		extrn victoria:proc
		extrn mensajeFinal:proc
		extrn gOver:proc

		mov ax, @data
		mov ds, ax
 
		;call iniciarTer
		int 80h
 
		mov bx, 20       	;se determina la posicion de inicial de X en el medio de la pantalla 
		mov varX[bx],"X"
 
		lea si,vec0   					;la primera roca caerá sobre la linea media siempre
		jmp otra
 
		;Coloca el cursor en la fila y columna del vec X (0, 23) -> abajo a la izquierda
		mov cl, FIL
		call cursorX;		
		lea dx,varX		
		call imp	
		ciclo:
			cmp si, 840 ; 
			jae otra
			call initialPosition
 
			;imprimo x
			mov cl, FIL
			call cursorX
			lea dx,varX		
			call imp
 
			;imrprimo vector base
			mov cl, 0
			call cursorX
			lea dx,vec0
			call imp			
 
			;comparamos si estamos en el extremo, y nos vamos al ante-ultimo del otro extremo de ser necesario 
			mov di, 0
			lea di, varX
			push di
			call extremos
			cmp di, 123
			je ciclo
 
			;checamos si hay letra
			call scanCode
 
			;fin del juego (q)
			cmp al, quit
			je lo_lamento_any
 
			;Muevo la X en caso de aplicar
			lea dx, varX
			push dx
			call movX
			mov ah, 0
			mov al, 5
			call ESPERA
			cmp di, 321
			je siga
 
			mov di, 231
			jmp siga
 
		siga:
			mov word ptr [si],20h   ;borro la roca anterior
			add si,40 				;salto a la siguiente linea
 
			cmp si, 840
			jae otra
 
			cmp di, 231
			je addFifteen
			mov al, 5
			jmp subProcess
 
			addFifteen:
				mov al, 5
 
			subProcess:
				mov word ptr[si],"O"
				mov ah, 0
				call ESPERA
		jmp ciclo

		lo_lamento_any:
			jmp fin
 
		otra:
			mov cx, si
			sub cx, 848
			cmp bx, cx 
			jne fallo  
			add counter, 1
			cmp counter, 9
			ja win
			lea dx, counter
			push dx
			call regToAscii
 			jmp acierto

			fallo: ;si no son no la atrapa
			add fail,1
			cmp fail,9
			ja over
			
			acierto:
			call RANDOM
			cmp al, 0 ; para que no se rompa en el lateral
			je acierto
			cmp al, 1 ; para que no se rompa en el lateral
			je acierto
			mov si, ax
			mov word ptr [si],"O"
			jmp siga
 
			win:
			call victoria
			jmp fin
			over:
			call gOver

 
		fin:
			call mensajeFinal
			mov ax,4c00h
			int 21h
	main endp
end