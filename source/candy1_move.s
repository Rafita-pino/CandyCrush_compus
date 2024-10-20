@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos ===
@;=                                                          			=
@;=== Programador tarea 1E: arnau.faura@estudiants.urv.cat				  ===
@;=== Programador tarea 1F: arnau.faura@estudiants.urv.cat				  ===
@;=                                                         	      	=



.include "candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1E;
@; cuenta_repeticiones(*matriz, f, c, ori): rutina para contar el número de
@;	repeticiones del elemento situado en la posición (f,c) de la matriz, 
@;	visitando las siguientes posiciones según indique el parámetro de
@;	orientación ori.
@;	Restricciones:
@;		* solo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarán
@;			las marcas de gelatina (+8, +16)
@;		* la primera posición también se tiene en cuenta, de modo que el número
@;			mínimo de repeticiones será 1, es decir, el propio elemento de la
@;			posición inicial
@;	Parámetros:
@;		R0 = dirección base de la matriz
@;		R1 = fila f
@;		R2 = columna c
@;		R3 = orientación ori (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@;	Resultado:
@;		R0 = número de repeticiones detectadas (mínimo 1)
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
		mov r0, #1				@;R0 = número de repeticiones
		
		@;orientació check 
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
		add r4, #1				@;Desplaçament seg. column (este)
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
		add r4, #COLUMNS        @;Desplaçament seg. fila (sur, +9 pos.)
		mov r7, #ROWS
		sub r7, #1				@;r7 = ROWS (amb index - 1)
		cmp r1, r7				@;Comprovar si som al borde de la mat.
		bgt .Lconrep_fin		@;Si pos. fora matriu, ACABAR
	.Lbucle_sur:
		ldrb r6, [r4]
		and r6, #7				@;Mascara bits 0..2
		cmp r6, r5
		bne .Lconrep_fin		@;Si no iguals, ACABAR
		add r0, #1				@;Sino, INCREMENTAR repetició
		add r4, #COLUMNS		@;Avançar a la següent fila
		add r1, #1				@;Actualitzar index fila
		cmp r1, r7
		ble .Lbucle_sur			@;Si <= borde, REPETIR
		b .Lconrep_fin			@;Sino, ACABAR
		
	.Lconrep_oeste:
		sub r4, #1				@;Desplaçament seg. column (oest)
		mov r7, #0				@;r7 = borde esquerra (columna 0)
		cmp r2, r7				@;Comprovar si som al borde esquerra
		blt .Lconrep_fin		@;Si fora matriu, ACABAR
	.Lbucle_oeste:
		ldrb r6, [r4]
		and r6, #7				@;Mascara bits 0..2
		cmp r6, r5
		bne .Lconrep_fin		@;Si no iguals, ACABAR
		add r0, #1				@;Sino, INCREMENTAR repetició
		sub r4, #1				@;Retrocedir a la columna anterior
		sub r2, #1				@;Actualitzar index columna
		cmp r2, r7
		bge .Lbucle_oeste		@;Si >= borde, REPETIR
		b .Lconrep_fin			@;Sino, ACABAR
		
	.Lconrep_norte:
		sub r4, #COLUMNS		@;Desplaçament seg. fila (nord)
		mov r7, #0				@;r7 = borde superior (fila 0)
		cmp r1, r7				@;Comprovar si som al borde superior
		blt .Lconrep_fin		@;Si fora matriu, ACABAR
	.Lbucle_norte:
		ldrb r6, [r4]
		and r6, #7				@;Mascara bits 0..2
		cmp r6, r5
		bne .Lconrep_fin		@;Si no iguals, ACABAR
		add r0, #1				@;Sino, INCREMENTAR repetició
		sub r4, #COLUMNS		@;Retrocedir a la fila anterior
		sub r1, #1				@;Actualitzar index fila
		cmp r1, r7
		bge .Lbucle_norte		@;Si >= borde, REPETIR
		b .Lconrep_fin			@;Sino, ACABAR
	
	.Lconrep_fin:	
		pop {r1-r8, pc}


@;TAREA 1F;
@; baja_elementos(*matriz): rutina para bajar elementos hacia las posiciones
@;	vacías, primero en vertical y después en diagonal; cada llamada a la función
@;	baja múltiples elementos una posición y devuelve cierto (1) si se ha
@;	realizado algún movimiento, o falso (0) si no se ha movido ningún elemento.
@;	Restricciones:
@;		* para las casillas vacías de la primera fila se generarán nuevos
@;			elementos, invocando la rutina mod_random() (ver fichero
@;			'candy1_init.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica se ha realizado algún movimiento, de modo que pueden
@;				quedar movimientos pendientes; 0 si no ha movido nada 
	.global baja_elementos
baja_elementos:
		push {r4, lr}
		mov  r4, r0				@;r4 = dir. matriu joc
	
		bl baja_verticales 
		cmp r0, #1				@;Hi ha hagut moviment?
		beq .Lmoviment			@;Si hi ha hagut moviment, ACABAR
		
		bl baja_laterales		@;Sino, intentar baixar laterals
		cmp r0, #1				@;Hi ha hagut moviment?
		beq .Lmoviment			@;@;Si hi ha hagut moviment, ACABAR
		
		mov r0, #0				@;Asegurar 0 moviments
		
	.Lmoviment:					@;Hi han hagut moviments (r0 = 1)
		pop {r4, pc}



@;:::RUTINAS DE SOPORTE:::



@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en vertical; cada llamada a la función baja múltiples elementos una posición
@;	y devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento; 0 si no ha movido nada  
baja_verticales:
		push {lr}
		mov r0, #0				@;Indicador moviments a 0
		mov r5, #COLUMNS		@;r5 numero columnes
		mov r6, #ROWS			@;r6 numero de files
		
		sub r6, #1				@;ajustament fila [0..8]
	
	.Lbucle_filas:
		mov r7, r5				@;r7 = index columnes
	.Lbucle_columnas:
		cmp r7, #0				@;tota la fila recorreguda?
		beq .Lpuja_fila			@;sí, seguent fila
		
		sub r7, #1
		mla r1, r6, r5, r7		@;r1 = fila*num_COL+col
		add r1, r4				@;R1 apunta al element (f,c) de mat[][]->r1+dir.base
		ldrb r2, [r1]			@;r2 = valor de la casella
		
		and r2, #7				@;rentat de gelatines
		cmp r2, #0				@;casella buida?
		bne .Lbucle_columnas	@;Sino, seguent columna
		
		
	
	.Lpuja_fila:
		
		pop {pc}


@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función baja múltiples elementos una posición
@;	y devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento; 0 si no ha movido nada. 
baja_laterales:
		push {lr}
		
		
		pop {pc}


.end
