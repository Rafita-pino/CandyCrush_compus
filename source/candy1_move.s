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
		push {r1-r11, lr}
		mov r1, #COLUMNS				
		mov r2, #ROWS					
		mov r11, #0						@;index moviments = 0 (v. inicial)
		mla r3, r2, r1, r4				@;r3 = ROWS * COLUMNS + dir.matriu (ultima pos.)
		sub r3, #1						@;Ajustament byte de més 
		sub r2, #1						@;Ajust. contador a [0..8]
		
	.Lmain_loop:						@;Recorre matriu
		ldrb r5, [r3]					@;r5 = valor actual 
		and r6, r5, #7					@;Filtra mascara gelatina (0..2)
		cmp r6, #0						@;buit?
		bne .Lnext						@;Si no, next column
		and r5, #24						@;Guardem valor gelatina (3..4) pos. inferior
		cmp r2, #0						@;Primera fila?
		beq .Ltractar_superior			@;Sí, posible generació valor
		
		sub r7, r3, #COLUMNS			@;Sino, el. superior (r7 = @pos. adalt de la buida)
		mov r10, r2						@;r10 = cont. fila valor buit
		b .Lcomp_forat					@;Salta a la rutina de tractament de forats
		
	.Ltractar_forat:					@;Cas el. a baixar és forat
		sub r7, #COLUMNS				@;Posicionament casella superior
		sub r10, #1						@;Decrementar fila (counter)
		cmp r10, #0						@;Estem al borde superior?
		beq .Ltractar_superior			@;Sí, intentar generar nou valor
		
	.Lcomp_forat:						@;Determina el. d'adalt valid, forat o bloc
		ldrb r8, [r7]					@;r8 = el. d'adalt
		and r9, r8, #15					@;filtrem bits (0..3) per mirar si es forat
		cmp r9, #15						@;Es forat (15)?
		beq .Ltractar_forat				@;Sí, buscar amunt
		and r9, #7						@;No, veure si es buida (bits 0..2)
		cmp r9, #0						@;Buida?
		beq .Lnext						@;Sí,seguent columna
		cmp r9, #7						@;No, bloc solid?
		beq .Lnext						@;Sí, seguent columna
		
		and r8, #24						@;Si es element valid, agafar v. gelatina
		add r9, r5						@;Valor a baixar + gelatina del d'abaix
		strb r9, [r3]					@;Guarda el. baixat.
		strb r8, [r7]					@;Deixar nomès gelatina al d'adalt.
		
		mov r11, #1						@;Moviment++
		b .Lnext						@;Next position
		
	.Ltractar_superior:					@;Controla generacio primers elements 
		mov r0, #6						@;r0 = 6 (max. rang pel mod_random)
		bl mod_random					
		add r0, #1						@;Correcció (+1) xq. no torni 0 
		add r0, r5						@;Afegir gelatina al nou valor
		strb r0, [r3]					@;Act. memòria amb nou el.
		mov r11, #1						@;moviment++
	
	.Lnext:								@;Següent casella
		sub r1, #1						@;Columnes(contador)--
		cmp r1, #0						@;Primera columna?
		bgt .LnoAct_Fila				@;Si no, mateixa fila				
		sub r2, #1						@;Sí, files(contador) - 1 (pujem)
		mov r1, #COLUMNS				@;Posicionament al final de la fila
		
	.LnoAct_Fila:						@;Tractament de files i columnes.
		sub r3, #1						@;Mourens realment a la pos. anterior
		cmp r3, r4						@;Acabar matriu?
		bge .Lmain_loop					@;Si pos. >= 1 pos., continuar			
								
		mov r0, r11						@;Si no sortir, r0 = moviments
		pop {r1-r11, pc}				







@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función baja múltiples elementos una posición
@;	y devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento; 0 si no ha movido nada. 
baja_laterales:
		push {r1-r11,lr}
		mov r11, #0						@;Contador moviments = 0
		mov r1, #COLUMNS
		mov r2, #ROWS
		mla r3, r2, r1, r4				@;Ultima pos. matriu
		sub r3, #1						@;Ajustar (index 0)
		sub r2, #1						@;Rows(contador) --
		
	.Lmain_bucle:
		mov r10, #0						@;Possible baixada a 0 (reiniciar)
		cmp r2, #0						@;No volem tractar la primera fila
		beq .Lsaltar					
		ldrb r5, [r3]		
		and r6, r5, #7					@;Treure gelatina
		cmp r6, #7						@;Bloc sòlid?
		beq .Lsaltar					@;Si, saltar
		cmp r6, #0						@;No, buit?
		bne .Lsaltar					@;No, saltar
		and r6, r5, #24					@;Si, guardar gelatina posició
		@;SUPERIOR DRETA
		cmp r1, #COLUMNS				@;Podría adalt dreta?
		beq .Lseg						@;Si no, salta seg (mirar si es pot adalt esquerra)
		mov r7, r3						@;Sí, comprovar si v. valid
		sub r7, r3, #COLUMNS
		add r7, #1						@;r7 = Adalt dreta
		ldrb r8, [r7]
		and r8, #7						@;Traure gelatina
		cmp r8, #0						@;Buit?
		beq .Lseg						@;Mirar adalt esquerra
		cmp r8, #7						@;Bloc sòlid? -> el mateix				
		beq .Lseg
		mov r10, #1						@;Sino, r10 = Possible baixada adalt dreta
	@;SUPERIOR ESQUERRA	
	.Lseg:
		cmp r1, #1						@;Primera columna? (tampoc podría adalt esq.)
		beq .Ldecisio
		mov r7, r3						@;Si no esta a la primera columna, mirar adalt esq.
		sub r7, r3, #COLUMNS			
		sub r7, #1						@;Adalt esquerra
		ldrb r8, [r7]
		and r8, #7
		cmp r8, #0
		beq .Ldecisio	
		cmp r8, #7
		beq .Ldecisio
		add r10, #2						@;r10 = Possible moviment a esq.
	
	@;Saltar a següent, esquerra, dreta o triar
	@;r10 -> valor < 2, dreta. valor = 2, esquerra. valor > 2, poden ser els dos
	.Ldecisio:
		mov r7, r3
		cmp r10, #0						@;Moviments?
		beq .Lsaltar
		cmp r10, #2
		blt .Lright						
		beq .Lleft
		bgt .Lchoose
	
	.Lright:
		sub r7, #COLUMNS				
		add r7, #1						@;Posició adalt dreta actual
		b .Lbaixar_elem
		
	.Lleft:
		sub r7, #COLUMNS				
		sub r7, #1						@;Posició adalt esq. actual
	
	.Lbaixar_elem:
		ldrb r8, [r7]
		and r9, r8, #7
		add r9, r6						@;Afegir gelatina a casella a baixar
		and r8, #24						@;r8 = gelatina adalt dreta
		strb r9, [r3]					@;Guardar valor baixat amb gelatina corresponent
		strb r8, [r7]					@;Deixar nomès gelatina a la pos. baixada
		mov r11, #1						@;moviments++
		b .Lsaltar						@;Següent element
		
	.Lchoose:
		mov r0, #2						@;r0, rang mod_random (0..1)
		bl mod_random
		cmp r0, #0 						@;0 a left i 1 a right
		beq .Lleft
		b .Lright
	
	.Lsaltar:
		sub r1, #1						@;Contador columna --
		cmp r1, #0						@;Borde esquerra?
		bgt .Lsame_row					@;No, seguir mateixa fila
		sub r2, #1						@;Si no, canviar fila (contador)
		mov r1, #COLUMNS				@;Reiniciar a la ultima columna de la nova fila
	
	.Lsame_row:
		sub r3, #1						@;Retrocedir pos. real (@dir.)
		cmp r3, r4						@;Principi matriu?
		bge .Lmain_bucle				@;Si no, continuar				
		
		mov r0, r11						@;Retornar moviments per r0
		pop {r1-r11, pc}

.end
