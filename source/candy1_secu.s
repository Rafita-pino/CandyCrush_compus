@;=                                                               		=
@;=== candy1_secu.s: rutinas para detectar y elimnar secuencias 	  ===
@;=                                                             	  	=
@;=== Programador tarea 1C: oupman.miralles@estudiants.urv.cat				  ===
@;=== Programador tarea 1D: oupman.miralles@estudiants.urv.cat				  ===
@;=                                                           		   	=



.include "candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
@; número de secuencia: se utiliza para generar números de secuencia únicos,
@;	(ver rutinas marcar_horizontales() y marcar_verticales()) 
	num_sec:	.space 1



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1C;
@; hay_secuencia(*matriz): rutina para detectar si existe, por lo menos, una
@;	secuencia de tres elementos iguales consecutivos, en horizontal o en
@;	vertical, incluyendo elementos en gelatinas simples y dobles.
@;	Restricciones:
@;		* para detectar secuencias se invocará la rutina cuenta_repeticiones()
@;			(ver fichero 'candy1_move.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
@; -------------------------------------------------------------------------		
@; 		R1 = index fila
@; 		R2 = index columna
@; 		R3 = registre reservat per la crida de funcions
@; 		R4 = copia de direccio base matriu
@; 		R5 = valor casella (R1, R2)
@; 		R6 = posicio matriu
@;		R7 = num columnes
	.global hay_secuencia
hay_secuencia:
		push {r1-r7, lr}
			
			mov r1, #0							@; index fila
			mov r4, r0							@; copia direccio base matriu
			mov r0, #0							@; inicialitzar en 0 en cas de mai executarse cuenta_repeticiones
			mov r6, #0							@; posicio matr1iu
			mov r7, #COLUMNS					@; numero de columnes
			
			.LwhileF:
				cmp r1, #ROWS
				beq .LfiwhileF					@; sortir al acabar la ultima fila
				mov r2, #0						@; index columna
				
				.LwhileC:						@; recorrer linealment les columnes
					cmp r2, #COLUMNS
					beq .LfiwhileC				@; Cambiar de fila al acabar la ultima columna
					mla  r6, r1, r7, r2			@; R6 = posicio matriu -> R6 = R1 * R9 + R2
					ldrb r5, [r4, r6]			@; R5 = valor en la posicio
					
					@; Comparar i ignorar:
						@; Casella buida (0, 8, 16)
						@; Bloc solit (7)
						@; Forat (15)
						@; No utilitzat (23)
						
					and r5, #0x07				@; filtrar els bits 2..0 (3 bits baixos)
					tst r5, #0x07				@; FZ true si 2..0 son 0
					beq .Lignore				@; ignorar si espai buit, gel.s vacia, gel.d. vacia
					cmp r5, #0x07				@; mirar si bits 2..0 son tots 1
					beq .Lignore				@; ignorar si bloque solido, forat, no utilizado
					
					cmp r2, #COLUMNS-2
					bge .LcheckVertical			@; no comprovar horitzontals si columna es penultima
					
					@; Contar repeticions horitzontals
					mov r3, #0					@; R3 = orientacio est(0)
					mov r0, r4					@; R0 = direccio matriu
					bl cuenta_repeticiones		@; retorna a R0 les repeticion
					cmp r0, #3			
					bhs .LfiwhileF				@; Sortir del bucle si repeticions >=3
					
					cmp r1, #ROWS-2				@; Fi de fila si es penultima
					bge .Lignore				@; no comprovar verticals si fila es penultima
					
					.LcheckVertical:			
						@; Contar repeticions verticals
						mov r3, #1				@; R3 = orientacio sud(1)
						mov r0, r4				@; R0 = direccio matriu
						bl cuenta_repeticiones	@; retorna a R0 les repeticions
						cmp r0, #3
						bhs .LfiwhileF			@; Sortir del bucle si repeticions >=3
					
					.Lignore:
					
					add r2, #1					@; incrementar index columna
					b .LwhileC					@; seguir recorrent columnes
					
				.LfiwhileC:
				
				add r1, #1						@; incrementar index fila
				b .LwhileF						@; seguir recorrent files
			
			.LfiwhileF:
			
			cmp r0, #3							@; comprovar num repeticions
			bge .LhaySecu						@; saltar si hi ha secuencia (rep >= 3)
			b .LnoSecu							@; saltar si no hi ha secuencia (rep < 3)
			
			.LhaySecu:
				mov r0, #1						@; R0 = 1 si repeticions >= 3
				b .Lend
			
			.LnoSecu: 							
				mov r0, #0						@; R0 = 0 si repeticions < 3
						
			.Lend:
		pop {r1-r7, pc}


@;TAREA 1D;
@; elimina_secuencias(*matriz, *marcas): rutina para eliminar todas las
@;	secuencias de 3 o más elementos repetidos consecutivamente en horizontal,
@;	vertical o cruzados, así como para reducir el nivel de gelatina en caso
@;	de que alguna casilla se encuentre en dicho modo; 
@;	además, la rutina marca todos los conjuntos de secuencias sobre una matriz
@;	de marcas que se pasa por referencia, utilizando un identificador único para
@;	cada conjunto de secuencias (el resto de las posiciones se inicializan a 0). 
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
	.global elimina_secuencias
elimina_secuencias:
		push {r6, r8, lr}
		
		mov r6, #0							@; valor per la matriu de marques a 0
		mov r8, #0							@; R8 es desplazamiento posiciones matriz
				
		.Lelisec_for0:
			strb r6, [r1, r8]				@; matriu de marques a 0
			add r8, #1						@; seguent posicio de la matriu
			cmp r8, #ROWS*COLUMNS
			blo .Lelisec_for0				@; seguir fins a omplir tota la matriu
			
		bl marca_horizontales       		@; marcar secuencias horizontals
		bl marca_verticales         		@; marcar secuencias verticals
		
		mov r6, #0							@; posicio matriu
		mov r4, r0							@; copia dir mat joc
		mov r5, r1							@; copia dir mat marques
		.LreduceLevel:
			ldrb r8, [r5, r6]				@; carregar valor matriu marques
			cmp r8, #0
			beq .Lignore3					@; ignorar si no hi ha marca
			@; reduir nivell
			ldrb r8, [r4, r6]				@; carregar valor matriu joc
			and r8, r8, #0x18				@; filtrar els bits 4..3 (2 bits alts)
			
			@; --- 2IB ---
			cmp r8, #0
			beq .LskipGel					@; Si els bits 4..3 son 0 no hi ha gelatina
			
			mov r0, #0x06000000				@; direccio mpbase del fondo de baldosas
			mov r1, r6, lsr #3				@; R1 = fila -> index / COLUMNS
			and r2, r6, #7					@; R2 = columna -> index % COLUMNS-1
			bl elimina_gelatina
			
			.LskipGel:
			mov r8, r8, lsr #1				@; reduir gelatina ( >> 1 bit)
			and r8, r8, #0x18				@; espai buit amb nivell de gelatina reduida (bits 2..0 a 0)
			strb r8, [r4, r6] 				@; guardar element reduit a la matriu joc
			bl elimina_elemento
			
			ldr r0, =update_spr
			mov r1, #1
			strb r1, [r0]
			@; --- 2IB ---
			
			.Lignore3:
			add r6, #1						@; seguent posicio
			cmp r6, #ROWS*COLUMNS
			blo .LreduceLevel
					
		pop {r6, r8, pc}


	
@;:::RUTINAS DE SOPORTE:::



@; marca_horizontales(mat): rutina para marcar todas las secuencias de 3 o más
@;	elementos repetidos consecutivamente en horizontal, con un número identifi-
@;	cativo diferente para cada secuencia, que empezará siempre por 1 y se irá
@;	incrementando para cada nueva secuencia, y cuyo último valor se guardará en
@;	la variable global num_sec; las marcas se guardarán en la matriz que se
@;	pasa por parámetro mat[][] (por referencia).
@;	Restricciones:
@;		* se supone que la matriz mat[][] está toda a ceros
@;		* para detectar secuencias se invocará la rutina cuenta_repeticiones()
@;			(ver fichero 'candy1_move.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
marca_horizontales:
		push {r2-r10, lr}
		
		mov r4, r0							@; copia direccio matriu base
		mov r8, r1							@; copia direccio matriu marques
		mov r9, #0							@; index de marques
		mov r7, #COLUMNS
		mov r1, #0							@; index fila
		
		.LwhileF1:
			cmp r1, #ROWS
			beq .LfiwhileF1					@; sortir al acabar la ultima fila
			mov r2, #0						@; index columna
			
			.LwhileC1:						@; recorrer linealment les columnes
				cmp r2, #COLUMNS
				beq .LfiwhileC1				@; Cambiar de fila al acabar la ultima columna
				mla  r6, r1, r7, r2			@; R6 = posicio matriu -> R6 = R1 * R9 + R2
				ldrb r5, [r4, r6]			@; R5 = valor en la posicio
				
				@; Comparar i ignorar:
					@; Casella buida (0, 8, 16)
					@; Bloc solit (7)
					@; Forat (15)
					@; No utilitzat (23)
					
				and r5, #0x07				@; filtrar els bits 2..0 (3 bits baixos)
				tst r5, #0x07				@; FZ true si 2..0 son 0
				beq .Lignore1				@; ignorar si espai buit, gel.s vacia, gel.d. vacia
				cmp r5, #0x07				@; mirar si bits 2..0 son tots 1
				beq .Lignore1				@; ignorar si bloque solido, forat, no utilizado
				
				cmp r2, #COLUMNS-2
				bge .LfiwhileC1				@; no comprovar horitzontals si columna es penultima
					
				@; Contar repeticions horitzontals
				mov r3, #0					@; R3 = orientacio est(0)
				mov r0, r4					@; R0 = direccio matriu
				bl cuenta_repeticiones		@; retorna a R0 les repeticion
				cmp r0, #3			
				blo .LnextCol				@; Saltar tantes columnes com repeticions
				
				add r9, #1					@; incrementar index marques
				mov r10, #0					@; index bucle
				.LmarkSecu:					@; for (r10 = 0, r10 < repeticions, r10++)
					strb r9, [r8, r6]		@; marcar la secuencia amb index de marques
					add r6, #1				@; seguent posicio matriu
					add r10, #1				@; incrementar index bucle
					cmp r10, r0				@; comparar index bucle amb repetecions
					blo .LmarkSecu			@; seguir el bucle si index < repeticions
					
				.LnextCol:
				add r2, r0
				b .LwhileC1					@; seguir recorrent columnes saltant les caselles marcades
				
				.Lignore1:
				
				add r2, #1					@; incrementar index columna
				b .LwhileC1					@; seguir recorrent columnes
				
			.LfiwhileC1:
			
			add r1, #1						@; incrementar index fila
			b .LwhileF1						@; seguir recorrent files
			
		.LfiwhileF1:
		
		ldrb r2, =num_sec					@; carregar num_sec
		strb r9, [r2]						@; guardar index de marques actual
		mov r0, r4							@; retornar direccio matriu base
		mov r1, r8							@; retornar direccio matriu marques
		
		pop {r2-r10, pc}



@; marca_verticales(mat): rutina para marcar todas las secuencias de 3 o más
@;	elementos repetidos consecutivamente en vertical, con un número identifi-
@;	cativo diferente para cada secuencia, que seguirá al último valor almacenado
@;	en la variable global num_sec; las marcas se guardarán en la matriz que se
@;	pasa por parámetro mat[][] (por referencia);
@;	sin embargo, habrá que preservar los identificadores de las secuencias
@;	horizontales que intersecten con las secuencias verticales, que se habrán
@;	almacenado en la matriz de referencia con la rutina anterior.
@;	Restricciones:
@;		* se supone que la matriz mat[][] está marcada con los identificadores
@;			de las secuencias horizontales
@;		* la variable num_sec contendrá el siguiente identificador (>=1)
@;		* para detectar secuencias se invocará la rutina cuenta_repeticiones()
@;			(ver fichero 'candy1_move.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
marca_verticales:
		push {r2-r10, lr}
		
		ldrb r2, =num_sec					@; carregar num_sec
		ldrb r9, [r2]						@; carregar index de marques actual
		mov r4, r0							@; copia direccio matriu base
		mov r8, r1							@; copia direccio matriu marques
		mov r7, #COLUMNS
		mov r1, #0							@; index fila
		
		.LwhileF2:
			cmp r1, #ROWS
			beq .LfiwhileF2					@; sortir al acabar la ultima fila
			mov r2, #0						@; index columna
			
			.LwhileC2:						@; recorrer linealment les columnes
				cmp r2, #COLUMNS
				beq .LfiwhileC2				@; Cambiar de fila al acabar la ultima columna
				mla  r6, r1, r7, r2			@; R6 = posicio matriu -> R6 = R1 * R9 + R2
				ldrb r5, [r4, r6]			@; R5 = valor en la posicio
				
				@; Comparar i ignorar:
					@; Casella buida (0, 8, 16)
					@; Bloc solit (7)
					@; Forat (15)
					@; No utilitzat (23)
					
				and r5, #0x07				@; filtrar els bits 2..0 (3 bits baixos)
				tst r5, #0x07				@; FZ true si 2..0 son 0
				beq .Lignore2				@; ignorar si espai buit, gel.s vacia, gel.d. vacia
				cmp r5, #0x07				@; mirar si bits 2..0 son tots 1
				beq .Lignore2				@; ignorar si bloque solido, forat, no utilizado
				
				cmp r1, #ROWS-2
				bge .LfiwhileF2				@; no comprovar verticals si fila es penultima
					
				@; Contar repeticions verticals
				mov r3, #1					@; R3 = orientacio sud(1)
				mov r0, r4					@; R0 = direccio matriu
				bl cuenta_repeticiones		@; retorna a R0 les repeticion
				cmp r0, #3			
				blo .Lignore2				@; Saltar a la seguent columna si reps < 3
				
				mov r10, #0					@; index bucle
				.LcheckMarks:
					ldrb r5, [r8, r6]		@; carregar el valor de la matriu de marques en la posicio
					cmp r5, #0
					bne .LsameMark			@; utilitzar la mateixa marca si interseccio
					add r6, #COLUMNS		@; seguent posicio vertical
					add r10, #1				@; incrementar index bucle
					cmp r10, r0				
					blo .LcheckMarks		@; seguir el bucle si index < repeticions
					
				b .LnewMark
				.LsameMark:
					mul r3, r10, r7		@; calcular el desplacament fet en LcheckMarks (n posicions * COLUMNS)
					sub r6, r3				@; tornar a la posicio inicial de la secuencia
					mov r10, #0				@; index bucle
					.LmarkSecu1:
						strb r5, [r8, r6]	@; posar marca de la interseccio
						add r6, #COLUMNS	@; seguent posicio vertical
						add r10, #1			@; incrementar index bucle
						cmp r10, r0			
						blo .LmarkSecu1		@; seguir el bucle si index < repeticions
					b .Lignore2
					
				.LnewMark:
					mul r3, r10, r7		@; calcular el desplacament fet en LcheckMarks (n posicions * COLUMNS)
					sub r6, r3				@; tornar a la posicio inicial de la secuencia
					mov r10, #0				@; index bucle
					add r9, #1				@; incrementar index marques
					.LmarkSecu2:			@; for (r10 = 0, r10 < repeticions, r10++)
						strb r9, [r8, r6]	@; marcar la secuencia amb index de marques
						add r6, #COLUMNS	@; seguent posicio matriu
						add r10, #1			@; incrementar index bucle
						cmp r10, r0			@; comparar index bucle amb repetecions
						blo .LmarkSecu2		@; seguir el bucle si index < repeticions
						
				.Lignore2:
				
				add r2, #1					@; incrementar index columna
				b .LwhileC2					@; seguir recorrent columnes
				
			.LfiwhileC2:
			
			add r1, #1						@; incrementar index fila
			b .LwhileF2						@; seguir recorrent files
			
		.LfiwhileF2:
		mov r0, r4							@; retornar direccio matriu base
		mov r1, r8							@; retornar direccio matriu marques
		
		pop {r2-r10, pc}


.end
