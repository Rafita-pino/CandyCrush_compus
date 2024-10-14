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
		push {r1-r8, lr} 		@;!! GUARDO DE R1 HASTA R8, AUNQUE NO USE
								@;TANTOS REGISTROS, PARA EVITAR CONFLICTOS CON 
								@;LA IMPLE. DE INI._MATRIZ  !!!
		
		mov r5, #COLUMNS
		mla r6, r1, r5, r2		@;fila*num_COL+col
		add r4, r0, r6			@;R4 apunta al elemento (f,c) de mat[][]->r6+dir.base
		ldrb r5, [r4]			
		and r5, #7				@;R5 es el valor filtrado (sin marcas de gel.)
		mov r0, #1				@;R0 = nÃºmero de repeticiones
		
		@;orientaciÃ³ check 
		cmp r3, #0
		beq .Lconrep_este
		cmp r3, #1
		beq .Lconrep_sur
		cmp r3, #2
		beq .Lconrep_oeste
		cmp r3, #3
		beq .Lconrep_norte
		b .Lconrep_fin
		
	.Lconrep_este:
		add r4, #1				@;DesplaÃ§ament seg. column (este)
		mov r7, #COLUMNS
		sub r7, #1				@;r7 = COLUMNS (amb index - 1)	
		cmp r2, r7				@;Comprovar si som al borde de la mat.
		bgt .Lconrep_fin		@;Si pos. fora matriu ACABAR
	.Lbucle_este:
		ldrb r6, [r4]
		and r6, #7				@;Mascara bits 0..2
		cmp r6, r5				
		bne .Lconrep_fin		@;Si no son iguals ACABAR
		add r0, #1				@;Sino INCREMENTAR rep.
		add r4, #1
		add r2, #1              @;Actualitzar index col.
		cmp r2, r7
		ble .Lbucle_este		@;Si pos <= borde, REPETIR
		b .Lconrep_fin			@;Sino ACABAR
			
	.Lconrep_sur:
		add r4, #COLUMNS        @;DesplaÃ§ament seg. fila (sur, +9 pos.)
		mov r7, #ROWS
		sub r7, #1				@;r7 = ROWS (amb index - 1)
		cmp r1, r7				@;Comprovar si som al borde de la mat.
		bgt .Lconrep_fin		@;Si pos. fora matriu, ACABAR
	.Lbucle_sur:
		ldrb r6, [r4]
		and r6, #7				@;Mascara bits 0..2
		cmp r6, r5
		bne .Lconrep_fin		@;Si no iguals, ACABAR
		add r0, #1				@;Sino, INCREMENTAR repeticiÃ³
		add r4, #COLUMNS		@;AvanÃ§ar a la segÃ¼ent fila
		add r1, #1				@;Actualitzar index fila
		cmp r1, r7
		ble .Lbucle_sur			@;Si <= borde, REPETIR
		b .Lconrep_fin			@;Sino, ACABAR
		
	.Lconrep_oeste:
		sub r4, #1				@;DesplaÃ§ament seg. column (oest)
		mov r7, #0				@;r7 = borde esquerra (columna 0)
		cmp r2, r7				@;Comprovar si som al borde esquerra
		blt .Lconrep_fin		@;Si fora matriu, ACABAR
	.Lbucle_oeste:
		ldrb r6, [r4]
		and r6, #7				@;Mascara bits 0..2
		cmp r6, r5
		bne .Lconrep_fin		@;Si no iguals, ACABAR
		add r0, #1				@;Sino, INCREMENTAR repeticiÃ³
		sub r4, #1				@;Retrocedir a la columna anterior
		sub r2, #1				@;Actualitzar index columna
		cmp r2, r7
		bge .Lbucle_oeste		@;Si >= borde, REPETIR
		b .Lconrep_fin			@;Sino, ACABAR
		
	.Lconrep_norte:
		sub r4, #COLUMNS		@;DesplaÃ§ament seg. fila (nord)
		mov r7, #0				@;r7 = borde superior (fila 0)
		cmp r1, r7				@;Comprovar si som al borde superior
		blt .Lconrep_fin		@;Si fora matriu, ACABAR
	.Lbucle_norte:
		ldrb r6, [r4]
		and r6, #7				@;Mascara bits 0..2
		cmp r6, r5
		bne .Lconrep_fin		@;Si no iguals, ACABAR
		add r0, #1				@;Sino, INCREMENTAR repeticiÃ³
		sub r4, #COLUMNS		@;Retrocedir a la fila anterior
		sub r1, #1				@;Actualitzar index fila
		cmp r1, r7
		bge .Lbucle_norte		@;Si >= borde, REPETIR
		b .Lconrep_fin			@;Sino, ACABAR
	
	.Lconrep_fin:	
		pop {r1-r8, pc}


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