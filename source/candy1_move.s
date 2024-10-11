@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos ===
@;=                                                          			=
@;=== Programador tarea 1E: arnau.faura@estudiants.urv.cat				  ===
@;=== Programador tarea 1F: arnau.faura@estudiants.urv.cat				  ===
@;=                                                         	      	=



.include "candy1_incl.i"



@;-- .text. cÃ³digo de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1E;
@; cuenta_repeticiones(*matriz, f, c, ori): rutina para contar el nÃºmero de
@;	repeticiones del elemento situado en la posiciÃ³n (f,c) de la matriz, 
@;	visitando las siguientes posiciones segÃºn indique el parÃ¡metro de
@;	orientaciÃ³n ori.
@;	Restricciones:
@;		* solo se tendrÃ¡n en cuenta los 3 bits de menor peso de los cÃ³digos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarÃ¡n
@;			las marcas de gelatina (+8, +16)
@;		* la primera posiciÃ³n tambiÃ©n se tiene en cuenta, de modo que el nÃºmero
@;			mÃ­nimo de repeticiones serÃ¡ 1, es decir, el propio elemento de la
@;			posiciÃ³n inicial
@;	ParÃ¡metros:
@;		R0 = direcciÃ³n base de la matriz
@;		R1 = fila f
@;		R2 = columna c
@;		R3 = orientaciÃ³n ori (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@;	Resultado:
@;		R0 = nÃºmero de repeticiones detectadas (mÃ­nimo 1)
	.global cuenta_repeticiones
cuenta_repeticiones:
		push {r1-r11,lr}
	
	@;SecciÃ³n ENTRADA
		mov r4, #1 					@;r4 = num. repeticions
		mov r10, #COLUMNS 			@;r10 COLUMNS
		mla r7, r1, r10, r2 		@;r7 = fila*COLUMNS+columna 
		add r6, r7, r0 				@;r6 = punter primer element matriu
		ldrb r8, [r6]				@;r8 = @r6 (element actual)
		and r5, r8, #7				@;r5 es el valor filtrat (no marcas de gel.)
		cmp r3, #1					
		bgt .Major					@; salt a Oest o Nort
		beq .Sur					@; sino, salt a Sud i sino a Est 
		
	@;EST
	.Este:
		mov r11, #COLUMNS
		sub r11, #1					@;r11 = COLUMNS - 1
		cmp r2, r11					
		bge .Exit					@;si borde (columna >= #COLUMNS-1) acaba
		add r6, #1 					@;moviment seguent casella
		add r2, #1					@;actualitzar columna
		ldrb r8, [r6]				@;r8 = @r6
		and r7, r8, #7				
		cmp r5, r7					@;comparaciÃ³ elements
		bne .Exit					@;si != exit
		add r4, #1					@;sino, sumar contador
		b .Este						
		
	@;SUR
	.Sur:
		mov r11, #ROWS				
		sub r11, #1					@;r11 = ROWS - 1
		cmp r1, r11					
		bge .Exit					@;si borde (i >= #ROWS-1) acaba 
		add r6, r10		 			@;moviment seguent casella (+9, desp. fila inferior)
		add r1, #1					@;actualitzar fila
		ldrb r8, [r6]				@;r8 = @r6 
		and r7, r8, #7				
		cmp r5, r7					@;comparaciÃ³ elements
		bne .Exit					
		add r4, #1					
		b .Sur						
		.Major:						
		cmp r3, #2					
		beq .Oeste					 
		
	@;NORTE
	.Norte:
		cmp r1, #0					@;r1 =? borde superior (fila 0)
		ble .Exit					@;si borde (i <= 0) acaba
		sub r6, r10					@;moviment seguent casella (-9, desp. fila superior)
		sub r1, #1					@;actualitzar fila
		ldrb r8, [r6]				@;r8 = @r6
		and r7, r8, #7				
		cmp r5, r7					
		bne .Exit					@;si elements !=, acabar
		add r4, #1					
		b .Norte				
		
	@;OESTE
	.Oeste:
		cmp r2, #0					@;r2 =? borde esquerra (columna 0)
		ble .Exit					@;si borde (j <= 0) acaba
		sub r6, #1 					@;moviment seguent casella (-1 columna)
		sub r2, #1					@;actualitzar columna
		ldrb r8, [r6]				@;r8 = @r6
		and r7, r8, #7				
		cmp r5, r7					@;comparacio elements
		bne .Exit					
		add r4, #1					
		b .Oeste					
		
	@;EXIT
	.Exit:
		mov r0, r4					@; r0 = r4 (retorn repeticions x r0)
		pop {r1-r11, pc}


@;TAREA 1F;
@; baja_elementos(*matriz): rutina para bajar elementos hacia las posiciones
@;	vacÃ­as, primero en vertical y despuÃ©s en diagonal; cada llamada a la funciÃ³n
@;	baja mÃºltiples elementos una posiciÃ³n y devuelve cierto (1) si se ha
@;	realizado algÃºn movimiento, o falso (0) si no se ha movido ningÃºn elemento.
@;	Restricciones:
@;		* para las casillas vacÃ­as de la primera fila se generarÃ¡n nuevos
@;			elementos, invocando la rutina mod_random() (ver fichero
@;			'candy1_init.s')
@;	ParÃ¡metros:
@;		R0 = direcciÃ³n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica se ha realizado algÃºn movimiento, de modo que pueden
@;				quedar movimientos pendientes; 0 si no ha movido nada 
	.global baja_elementos
baja_elementos:
		push {lr}
		
		
		pop {pc}



@;:::RUTINAS DE SOPORTE:::



@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vacÃ­as
@;	en vertical; cada llamada a la funciÃ³n baja mÃºltiples elementos una posiciÃ³n
@;	y devuelve cierto (1) si se ha realizado algÃºn movimiento.
@;	ParÃ¡metros:
@;		R4 = direcciÃ³n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algÃºn movimiento; 0 si no ha movido nada  
baja_verticales:
		push {lr}
		
		
		pop {pc}


@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacÃ­as
@;	en diagonal; cada llamada a la funciÃ³n baja mÃºltiples elementos una posiciÃ³n
@;	y devuelve cierto (1) si se ha realizado algÃºn movimiento.
@;	ParÃ¡metros:
@;		R4 = direcciÃ³n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algÃºn movimiento; 0 si no ha movido nada. 
baja_laterales:
		push {lr}
		
		
		pop {pc}


.end