@;=                                                               		=
@;=== candy1_comb.s: rutinas para detectar y sugerir combinaciones    ===
@;=                                                               		=
@;=== Programador tarea 1G: gerard.ros@estudiants.urv.cat				  ===
@;=== Programador tarea 1H: gerard.ros@estudiants.urv.cat				  ===
@;=                                                             	 	=



.include "candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1G;
@; hay_combinacion(*matriz): rutina para detectar si existe, por lo menos, una
@;	combinación entre dos elementos (diferentes) consecutivos que provoquen
@;	una secuencia válida, incluyendo elementos con gelatinas simples y dobles.
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
@;		R1 = index de les files
@;		R2 = index de les columnes
@;		R3 = index del desplaçament
@;		R4 = direcció base de la matriu de joc
@;		R5 = número de columnes
@;		R6 = número de files
@;		R7 = casella actual del recorregut
@;		R8 = auxiliar 
@;		R9 = auxiliar columnes
@;		R10 = auxiliar casella horitzontal
@;		R11 = auxiliar casella vertical

	.global hay_combinacion
hay_combinacion:
	push {r1-r11, lr}
	
		mov r1, #0 			@; r1 = index de files
		mov r2, #0 			@; r2 = index de columnes
		mov r3, #0 			@; r3 = index de desplaçament
		mov r4, r0 			@; r4 = direcció base de la matriu de joc
		mov r5, #COLUMNS	@; r5 = columnes
		mov r6, #ROWS		@; r6 = files
		
		b .Lif_es_valid
		
		.Lwhile:
			add r1, #1
			
			.Lif_es_valid:
				ldrb r7, [r4, r3] 	@; r7 = casella actual
				and r8, r7, #0x07
				cmp r8, #0x07		@; si r7 es un bloc solid o un forat no es valid
				beq .Lendwhile
				cmp r8, #0x00		@; si r7 es un bloc buit no es valid
				beq .Lendwhile
			.Lendif_es_valid:
		
			.Lif_ultima_columna:
				sub r9, r5, #1		@; r9 = penúltima columna
				cmp r2, r9			@; si encara no estem a la última posició comprovem si és l'ulima fila
				bge .Lif_es_ultima_fila
			.Lendif_ultima_columna:
			
			.Lif_igual_posterior_horitzontal:
				add r3, #1 			@; r3++
<<<<<<< HEAD
				ldrb r10, [r4, r3] 	@; r10 = casella posterior horitzontal
=======
				ldrb r10, [r4, r3] 	@; r10 = casella posterior horizontal
>>>>>>> prog2
				sub r3, #1			@; r3--
				cmp r7, r10			@; si casella actual i post. horitzontal són iguals comprovem si estem a la ult. fila
				beq .Lif_es_ultima_fila
			.Lendif_igual_posterior_horitzontal:

			.Lif_posterior_horitzontal_valida:
				and r8, r10, #0x07
				cmp r8, #0x07		@; si r10 es un bloc solid o un forat no es valid
				beq .Lif_es_ultima_fila	
				cmp r8, #0x00		@; si r10 es un bloc buit no es valid
				beq .Lif_es_ultima_fila
			.Lendif_posterior_horitzontal_valida:
			
			@; fem un intercanvi horitzontal
				strb r10, [r4, r3]
				add r3, #1
				strb r7, [r4, r3]
				sub r3, #1
				
			@; comprovem si hi ha una combinació a la primera casella
				bl detecta_orientacion
				cmp r0, #6
				bne .Lif_sequencia_horitzontal
				
			@; comprovem si hi ha una combinació a la segona casella
				add r2, #1
				bl detecta_orientacion
				sub r2, #1
				cmp r0, #6
				bne .Lif_sequencia_horitzontal
				
			@; desfem l'intercanvi horitzontal
				strb r7, [r4, r3]
				add r3, #1
				strb r10, [r4, r3]
				sub r3, #1
			
			.Lif_es_ultima_fila:
				sub r9, r6, #1 		@; r9 = files - 1
				cmp r1, r9
				bge .Lendwhile
			.Lendif_es_ultima_fila:
			
			.Lif_posterior_vertical_igual:
				add r3, r5 			@; r3 = r3 + columnes
				ldrb r11, [r4, r3] 	@; r11 = casilla posterior vertical
				sub r3, r5
				cmp r7, r11
				beq .Lendwhile
			.Lendif_posterior_vertical_igual:
			
			.Lif_posterior_vertical_valida:
				and r8, r11, #0x07
				cmp r8, #0x07
				beq .Lendwhile
				cmp r8, #0x00
				beq .Lendwhile
			.Lendif_posterior_vertical_valida:
			
			@; Intercanvi vertical
				strb r11, [r4, r3]
				add r3, r5
				strb r7, [r4, r3]
				sub r3, r5 @; r3 = r3 - columnes
				
				
			@; Comprovar primera casella
				bl detecta_orientacion
				cmp r0, #6
				bne .Lif_sequencia_vertical
				
				
			@; Comprovar segona casella
				add r1, #1
				bl detecta_orientacion
				sub r1, #1
				cmp r0, #6
				bne .Lif_sequencia_vertical
				
			@; Desfer intercanvi vertical
				strb r7, [r4, r3]
				add r3, r5 @; r3 = r3 + columnes
				strb r11, [r4, r3]
				sub r3, r5 @; r3 = r3 - columnes
			b .Lendwhile
			
			.Lif_sequencia_horitzontal:
				@; Desfer intercanvi horitzontal
				strb r7, [r4, r3]
				add r3, #1
				strb r10, [r4, r3]
				sub r3, #1
				
				mov r0, #1
				b .Lfi
			.Lifend_sequencia_horitzontal:
			
			.Lif_sequencia_vertical:
				@; Desfer intercanvi vertical
				strb r7, [r4, r3]
				add r3, r5 @; r3 = r3 + columnes
				strb r11, [r4, r3]
				sub r3, r5
				
				mov r0, #1
				b .Lfi
			.Lendif_sequencia_horitzontal:
			
		.Lendwhile:
		mov r0, #0
		add r3, #1	@; incrementem el desplaçament
		add r2, #1	@; incrementem l'index de les columnes
		
		sub r9, r5, #1	@; r9 = columnes - 1
		cmp r2, r9
		ble .Lif_es_valid
		
		mov r2, #0
		
		sub r9, r6, #1
		cmp r1, r9
		blt .Lwhile
		
	.Lfi:
		pop {r1-r11, pc}



@;TAREA 1H;
@; sugiere_combinacion(*matriz, *psug): rutina para detectar una combinación
@;	entre dos elementos (diferentes) consecutivos que provoquen una secuencia
@;	válida, incluyendo elementos con gelatinas simples y dobles, y devolver
@;	las coordenadas de las tres posiciones de la combinación (por referencia).
@;	Restricciones:
@;		* se asume que existe por lo menos una combinación en la matriz
@;			 (se debe verificar antes con la rutina hay_combinacion())
@;		* la combinación sugerida tiene que ser escogida aleatoriamente de
@;			 entre todas las posibles, es decir, no tiene que ser siempre
@;			 la primera empezando por el principio de la matriz (o por el final)
@;		* para obtener posiciones aleatorias, se invocará la rutina mod_random()
@;			 (ver fichero 'candy1_init.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección del vector de posiciones (unsigned char *), donde se
@;				guardarán las coordenadas (x1,y1,x2,y2,x3,y3), consecutivamente.
@;	Resultado:
@;		R2 = index de les columnes
@;		R3 = auxiliar
@;		R4 = direcció base de la matriu de joc
@;		R5 = direcció del vector de les posicions
@;		R6 = index de desplaçament
@;		R7 = index fila*columnes
@;		R8 = auxiliar 
@;		R9 = auxiliar casella horitzontal
@;		R10 = auxiliar 
@;		R11 = files
@; 		R12 = columnes

	.global sugiere_combinacion
sugiere_combinacion:
		push {r2-r12, lr}
		
<<<<<<< HEAD
			mov r4, r0		@; r4 = direcció base de la matriu
			mov r5, r1		@; r5 = auxiliar que guarda r1
			mov r6, #0		@; r6 = index de desplaçament
			mov r11, #ROWS
			mov r12, #COLUMNS
			
			@;generem fila i columna aleatoria
			.Lindex_aleatori:
				mov r0, r11
				bl mod_random	@;generar fila aleatoria
				mov r1, r0		@; r1 = fila aleatoria
					
				mov r0, r12
				bl mod_random	@;generar columna aleatoria
				mov r2, r0		@; r2 = columna aleatoria
				
				mul r7, r1, r12	@; r7 = index fila * columnes
				add r6, r7, r2	@; r6 = r7 + index columna	
			.Lendindex_aleatori:
			
			.Lwhile2:
				@;COmprovem la casella actual
				.Lif_actual_valida:
					ldrb r8, [r4, r6]	@; r8 = valor de la casella actual
					and r3, r8, #0x07	
					cmp r3, #0x07		@; si r8 es un bloc solid o un forat no es valid
					beq .Lindex
					cmp r3, #0x00		@; si r8 es un bloc buit no es valid
					beq .Lindex
				.Lendif_actual_valida:
				
				@;Comprovem si som a l'última columna
=======
			mov r4, r0	@; r4 = direcció base de la matriu
			mov r5, r1	@; r5 = auxiliar que guarda r1
			mov r6, #0	@; r6 = index de desplaçament
			mov r11, #ROWS
			mov r12, #COLUMNS
			
			.Lindex_aleatori:
				mov r0, r11
				bl mod_random
				mov r1, r0	@; r1 = fila aleatoria
				
				mov r0, r12
				bl mod_random
				mov r2, r0 @; r2 = columna aleatoria
				
				mul r7, r1, r12	@; r7 = index fila * columnes
				add r6, r7, r2	@; r6 = r7 + index columna
				
			.Lendindex_aleatori:
			
			.Lwhile2:
			
				.Lif_actual_valida:
					ldrb r8, [r4, r6]	@; r8 = casella actual
					and r3, r8, #0x07
					cmp r3, #0x07
					beq .Lindex
					cmp r3, #0x00
					beq .Lindex
				.Lendif_actual_valida:
				
>>>>>>> prog2
				.Lif_ultima_columna2:
					sub r7, r12, #1
					cmp r2, r7
					bge .Lif_ultima_fila
				.Lendif_ultima_columna2:
				
<<<<<<< HEAD
				@; Comprovem si la casella posterior horitzontal és igual
				.Lif_posterior_horitzontal_igual:
					add r6, #1				@; Incrementem per a accedir a la casella posterior
					ldrb r9, [r4, r6]		@; r9 = casilla posterior horitzontal
					sub r6, #1				@; Tornem al desplaçament original
					cmp r8, r9
					beq .Lif_ultima_fila	@; Si són iguals, sortim
				.Lendif_posterior_horitzontal_igual:
				
				@; Comprovem si la casella posterior horitzontal és vàlida
				.Lif_posterior_horitzontal_valida2:
					and r3, r9, #0x07
					cmp r3, #0x07		@; si r9 es un bloc solid o un forat no es valid
					beq .Lif_ultima_fila
					cmp r3, #0x00		@; si r8 es un bloc buit no es valid
					beq .Lif_ultima_fila
				.Lendif_posterior_horitzontal_valida2:
				
				@; Intercanviem les caselles horitzontals
				.Lintercanvi_horitzontal:
					add r6, #1
					strb r8, [r4, r6]	@; Guardem el valor original de la casella
					sub r6, #1
					strb r9, [r4, r6]	@; Guardem el valor intercanviat
				.Lendintercanvi_horitzontal:
				
				 @; Comprovem si la combinació resultant és vàlida horitzontalment
				.Lcomprovar_horitzontal:
					@; Primera casella
					bl detecta_orientacion
					mov r3, r0		@; r3 = c.ori
					mov r10, r4		@; r10 = auxiliar que guarda r4
					mov r4, #0		@; r4 = cpi
					cmp r3, #6
					bne .Lsugerencia_horitzontal
					mov r4, r10		@; r4 torna al seu valor
					
					@; Seguona casella
					add r2, #1		@; index columna++
					bl detecta_orientacion
					mov r3, r0		@; r3 = c.ori
					mov r10, r4		@; r10 = auxiliar que guarda r4
					mov r4, #1		@; r4 = cpi
					cmp r3, #6
					bne .Lsugerencia_horitzontal
					mov r4, r10		@; r4 torna al seu valor
					sub r2, #1		@; index columna--
				.Lendcomprovar_horitzontal:
				
				@; Tornem a l'estat inicial si no és vàlid
				.Ldesfer_intercanvi_horitzontal:
=======
				.Lif_posterior_horizontal_igual:
					add r6, #1
					ldrb r9, [r4, r6]	@; r9 = casilla posterior horizontal
					sub r6, #1
					cmp r8, r9
					beq .Lif_ultima_fila
				.Lendif_posterior_horizontal_igual:
				
				.Lif_posterior_horitzontal_valida2:
					and r3, r9, #0x07
					cmp r3, #0x07
					beq .Lif_ultima_fila
					cmp r3, #0x00
					beq .Lif_ultima_fila
				.Lendif_posterior_horitzontal_valida2:
				
				.Lintercanvi_horizontal:
					add r6, #1
					strb r8, [r4, r6]
					sub r6, #1
					strb r9, [r4, r6]
				.Lendintecanvi_horizontal:
				
				.Lcomprovar_horizontal:
					@; Primera casilla
					bl detecta_orientacion
					mov r3, r0	@; r3 = c.ori
					mov r10, r4	@; r10 = auxiliar que guarda r4
					mov r4, #0	@; r4 = c.p.i
					cmp r3, #6
					bne .Lsugerencia_horizontal
					mov r4, r10	@; r4 vuelve a su valor
					
					@; Segunda casilla
					add r2, #1	@; índice columna++
					bl detecta_orientacion
					mov r3, r0	@; r3 = c.ori
					mov r10, r4	@; r10 = auxiliar que guarda r4
					mov r4, #1	@; r4 = c.p.i
					cmp r3, #6
					bne .Lsugerencia_horizontal
					mov r4, r10	@; r4 vuelve a su valor
					sub r2, #1	@; índice columna--
				.Lendcomprovar_horizontal:
				
				.Ldesfer_intercanvi_horizontal:
>>>>>>> prog2
					add r6, #1
					strb r9, [r4, r6]
					sub r6, #1
					strb r8, [r4, r6]
<<<<<<< HEAD
				.Lenddesfer_intercanvi_horitzontal:
				
				@; Comprovem si som a l'última fil
				.Lif_ultima_fila:
					sub r7, r11, #1	@; r7 = filas--
=======
				.Lenddesfer_intercanvi_horizontal:
				
				.Lif_ultima_fila:
					sub r7, r11, #1	@; r7 = filas - 1
>>>>>>> prog2
					cmp r1, r7
					bge .Lindex
				.Lendif_ultima_fila:
				
<<<<<<< HEAD
				@; Comprovem si les caselles verticals són iguals
				.Lif_posterior_vertical_igual2:
					add r6, r12			@; r6 = desplaçament + columnes
					ldrb r9, [r4, r6]	@; r9 = casella posterior vertical
=======
				.Lif_posterior_vertical_igual2:
					add r6, r12		@; r6 = desplazamiento + columnas
					ldrb r9, [r4, r6]	@; r9 = casilla posterior vertical
>>>>>>> prog2
					sub r6, r12
					cmp r8, r9
					beq .Lindex
				.Lendif_posterior_vertical_igual2:
				
				.Lposterior_vertical_valida:
					and r3, r9, #0x07
<<<<<<< HEAD
					cmp r3, #0x07		@; si r9 es un bloc solid o un forat no es valid
					beq .Lindex
					cmp r3, #0x00		@; si r9 es un bloc solid o un forat no es valid
					beq .Lindex
				.Lendposterior_vertical_valida:
				
				@; Intercanvi vertical
				.Lintercanvi_verticalSC:
					add r6, r12			@; r6 = desplaçament + columnes
					strb r8, [r4, r6]
					sub r6, r12
					strb r9, [r4, r6]
				.Lendintercanvi_verticalSC:
				
				@; Comprovem combinació vertical
				.Lcomprovar_vertical:
					@; Primera casella
					bl detecta_orientacion
					mov r3, r0		@; r3 = c.ori
					mov r10, r4		@; r10 = auxiliar que guarda r4
					mov r4, #2		@; r4 = c.p.i
					cmp r3, #6
					bne .Lsugerencia_vertical
					mov r4, r10		@; r4 torna al seu valor
					
					@; Segona casella
					add r1, #1		@; index fila++
					bl detecta_orientacion
					mov r3, r0		@; r3 = c.ori
					mov r10, r4		@; r10 = auxiliar que guarda r4
					mov r4, #3		@; r4 = c.p.i
					cmp r3, #6
					bne .Lsugerencia_vertical
					mov r4, r10		@; r4 torna al seu valor
					sub r1, #1		@; index fila--
				.Lendcomprovar_vertical:
				
				@; Tornem a l'estat original
				.Ldesfer_intercanvi_vertical:
					add r6, r12			@; r6 = desplaçament + columnes
=======
					cmp r3, #0x07
					beq .Lindex
					cmp r3, #0x00
					beq .Lindex
				.Lendposterior_vertical_valida:
				
				.Lintercambio_verticalSC:
					add r6, r12	@; r6 = desplazamiento + columnas
					strb r8, [r4, r6]
					sub r6, r12
					strb r9, [r4, r6]
				.Lendintercambio_verticalSC:
				
				.Lcomprovar_vertical:
					@; Primera casilla
					bl detecta_orientacion
					mov r3, r0	@; r3 = c.ori
					mov r10, r4	@; r10 = auxiliar que guarda r4
					mov r4, #2	@; r4 = c.p.i
					cmp r3, #6
					bne .Lsugerencia_vertical
					mov r4, r10	@; r4 vuelve a su valor
					
					@; Segunda casilla
					add r1, #1	@; índice fila++
					bl detecta_orientacion
					mov r3, r0	@; r3 = c.ori
					mov r10, r4	@; r10 = auxiliar que guarda r4
					mov r4, #3	@; r4 = c.p.i
					cmp r3, #6
					bne .Lsugerencia_vertical
					mov r4, r10	@; r4 vuelve a su valor
					sub r1, #1	@; índice fila--
				.Lendcomprovar_vertical:
				
				.Ldesfer_intercanvi_vertical:
					add r6, r12	@; r6 = desplazamiento + columnas
>>>>>>> prog2
					strb r9, [r4, r6]
					sub r6, r12
					strb r8, [r4, r6]
				.Lenddesfer_intercanvi_vertical:
				
				b .Lindex
				
				.Lsugerencia_vertical:
<<<<<<< HEAD
					mov r0, r5				@; r0 = direccio vector
					bl genera_posiciones	@; Generem la posició suggerida
					mov r4, r10
					
					@; Desfem l'intercanvi
					add r6, r12				@; r6 = desplaçament + columnes
					strb r9, [r4, r6]
					sub r6, r12
					strb r8, [r4, r6]
					b .Lendwhile2
				.Lendsugerencia_vertical:
				
				.Lsugerencia_horitzontal:
					mov r0, r5			@; r0 = direccio vector
					bl genera_posiciones
					mov r4, r10
					
					@; Desfer intercanvi
=======
					mov r0, r5	@; r0 = direccion vector
					bl genera_posiciones
					mov r4, r10
					
					@; Deshacer intercambio
					add r6, r12	@; r6 = desplazamiento + columnas
					strb r9, [r4, r6]
					sub r6, r12
					strb r8, [r4, r6]
					b .Lendwhile
				.Lendsugerencia_vertical:
				
				.Lsugerencia_horizontal:
					mov r0, r5	@; r0 = direccion vector
					bl genera_posiciones
					mov r4, r10
					
					
					@; Deshacer intercambio
>>>>>>> prog2
					add r6, #1
					strb r9, [r4, r6]
					sub r6, #1
					strb r8, [r4, r6]
<<<<<<< HEAD
					b .Lendwhile2
				.Lendgenerar_sugerencia_horitzontal:
				
				.Lindex:
					mul r7, r11, r12	@; r7 = files * columnas
=======
					b .Lendwhile
				.Lendgenerar_sugerencia_horizontal:
				
				.Lindex:
					mul r7, r11, r12	@; r7 = filas * columnas
>>>>>>> prog2
					sub r7, #1
					cmp r6, r7
					bge .Lreiniciar
					
					add r2, #1
					add r6, #1
					
					sub r7, r12, #1		@; r7 = columnas - 1
					cmp r2, r7
<<<<<<< HEAD
					ble .Lwhile2
					
					mov r2, #0
					
					sub r7, r11, #1		@; r7 = files - 1
					cmp r1, r7
					bge .Lreiniciar
					
					add r1, #1			@; index fila++
					b .Lwhile2
					
					.Lreiniciar:
						mov r1, #0		@; fila = 0
						mov r2, #0		@; columna = 0
						mov r6, #0		@; desplaçament = 0
						b .Lwhile2
=======
					ble .Lwhile
					
					mov r2, #0
					
					sub r7, r11, #1		@; r7 = filas - 1
					cmp r1, r7
					bge .Lreiniciar
					
					add r1, #1	@; índice fila++
					b .Lwhile
					
					.Lreiniciar:
						mov r1, #0	@; fila = 0
						mov r2, #0	@; columna = 0
						mov r6, #0	@; desplazamiento = 0
						b .Lwhile
>>>>>>> prog2
					.Lendreiniciar:
				.Lendindex:
				
				.Lendwhile2:
			
<<<<<<< HEAD
			mov r1, r0 					@; r1 = direcció vector
			mov r0, r4 					@; r0 = direcció matriu
=======
			mov r1, r0 @; r1 = dirección vector
			mov r0, r4 @; r0 = dirección matriz
>>>>>>> prog2
		
		pop {r2-r12, pc}




@;:::RUTINAS DE SOPORTE:::

@; genera_posiciones(vect_pos, f, c, ori, cpi): genera las posiciones de 
@;	sugerencia de combinación, a partir de la posición inicial (f,c), el código
@;	de orientación ori y el código de posición inicial cpi, dejando las
@;	coordenadas en el vector vect_pos[].
@;	Restricciones:
@;		* se asume que la posición y orientación pasadas por parámetro se
@;			corresponden con una disposición de posiciones dentro de los
@;			límites de la matriz de juego
@;	Parámetros:
@;		R0 = dirección del vector de posiciones vect_pos[]
@;		R1 = fila inicial f
@;		R2 = columna inicial c
@;		R3 = código de orientación ori:
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
<<<<<<< HEAD
@;				en medio de secuencia: 4 -> horitzontal, 5 -> vertical
=======
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
>>>>>>> prog2
@;		R4 = código de posición inicial cpi:
@;				0 -> izquierda, 1 -> derecha, 2 -> arriba, 3 -> abajo
@;	Resultado:
@;		vector de posiciones (x1,y1,x2,y2,x3,y3), devuelto por referencia
genera_posiciones:
<<<<<<< HEAD
		push {r0-r4,lr}
				
			cmp r4, #0		@; Compara cpi amb 0 (esquerra)
			beq .Lcpi0		
			cmp r4, #1		@; Compara cpi amb 1 (dreta)
			beq .Lcpi1		
			cmp r4, #2		@; Compara cpi amb 2 (amunt)
			beq .Lcpi2
			cmp r4, #3		@; Compara cpi amb 3 (avall)
			beq .Lcpi3
			
			b .Lfin			@; Si no coincideix amb cap, finalitza la rutina

		.Lcpi0:
			add r2, #1		@; Incrementa la columna 
			strb r2, [r0]	@; Guarda la columna en vect_pos[]
			sub r2, #1		@; Restaura el valor original de la columna
			add r0, #1		@; Incrementa l'índex del vector
			strb r1, [r0]	@; Guarda la fila en vect_pos[]
			add r0, #1		@; Incrementa l'índex del vector
			
			b .Lcori		@; Salta per seleccionar orientació

		.Lcpi1:
			sub r2, #1		@; Decrementa la columna 
			strb r2, [r0]
			add r2, #1
			add r0, #1
			strb r1, [r0]
			add r0, #1
			
			b .Lcori

		
		.Lcpi2:
			add r1, #1
			strb r2, [r0]
			add r0, #1
			strb r1, [r0]
			sub r1, #1
			add r0, #1
			
			b .Lcori

		.Lcpi3:
			sub r1, #1
			strb r2, [r0]
			add r0, #1
			strb r1, [r0]
			add r1, #1
			add r0, #1
			
		.Lcori:
			cmp r3, #0		@; Compara ori amb 0 (Est)
			beq .Lcori0
			cmp r3, #1		@; Compara ori amb 1 (Sud)
			beq .Lcori1
			cmp r3, #2		@; Compara ori amb 2 (Oest)
			beq .Lcori2
			cmp r3, #3		@; Compara ori amb 3 (Nord)
			beq .Lcori3
			cmp r3, #4		@; Compara ori amb 4 (horitzontal)
			beq .Lcori4
			cmp r3, #5		@; Compara ori amb 5 (vertical)
			beq .Lcori5
			
			b .Lfin
			
		.Lcori0:
			add r2, #1                       @; Incrementa la columna (c + 1)
			strb r2, [r0]                    @; Guarda la columna en vect_pos[]
			add r0, #1                       @; Incrementa l'índex del vector
			strb r1, [r0]                    @; Guarda la fila en vect_pos[]
			add r2, #1                       @; Incrementa la columna de nou
			add r0, #1                       @; Incrementa l'índex del vector
			strb r2, [r0]                    @; Guarda la columna incrementada en vect_pos[]
			add r0, #1                       @; Incrementa l'índex del vector
			strb r1, [r0]                    @; Guarda la fila en vect_pos[]
		
			b .Lfin

		.Lcori1:
			strb r2, [r0]                    @; Guarda la columna en vect_pos[]
			add r0, #1                       @; Incrementa l'índex del vector
			add r1, #1                       @; Incrementa la fila (f + 1)
			strb r1, [r0]                    @; Guarda la fila incrementada en vect_pos[]
			add r0, #1                       @; Incrementa l'índex del vector
			strb r2, [r0]                    @; Guarda la columna en vect_pos[]
			add r0, #1                       @; Incrementa l'índex del vector
			add r1, #1                       @; Incrementa la fila de nou
			strb r1, [r0]                    @; Guarda la fila incrementada en vect_pos[]
	
			b .Lfin
			
		.Lcori2:
			strb r2, [r0]                    @; Guarda la columna en vect_pos[]
			add r0, #1                       @; Incrementa l'índex del vector
			add r1, #1                       @; Incrementa la fila (f + 1)
			strb r1, [r0]                    @; Guarda la fila incrementada en vect_pos[]
			add r0, #1                       @; Incrementa l'índex del vector
			strb r2, [r0]                    @; Guarda la columna en vect_pos[]
			add r0, #1                       @; Incrementa l'índex del vector
			add r1, #1                       @; Incrementa la fila de nou
			strb r1, [r0]                    @; Guarda la fila incrementada en vect_pos[]
		
			b .Lfin

		.Lcori3:
			strb r2, [r0]                    @; Guarda la columna en vect_pos[]
			add r0, #1                       @; Incrementa l'índex del vector
			sub r1, #1                      @; Disminueix la fila (f - 1)
			strb r1, [r0]                    @; Guarda la fila disminuïda en vect_pos[]
			add r0, #1                       @; Incrementa l'índex del vector
			strb r2, [r0]                    @; Guarda la columna en vect_pos[]
			add r0, #1                       @; Incrementa l'índex del vector
			sub r1, #1                      @; Disminueix la fila de nou
			strb r1, [r0]                    @; Guarda la fila disminuïda en vect_pos[]

			b .Lfin
		
		.Lcori4:
			sub r2, #1                      @; Disminueix la columna (c - 1)
			strb r2, [r0]                    @; Guarda la columna en vect_pos[]
			add r0, #1                       @; Incrementa l'índex del vector
			strb r1, [r0]                    @; Guarda la fila en vect_pos[]
			add r2, #2                       @; Incrementa la columna dues vegades
			add r0, #1                       @; Incrementa l'índex del vector
			strb r2, [r0]                    @; Guarda la columna incrementada en vect_pos[]
			add r0, #1                       @; Incrementa l'índex del vector
			strb r1, [r0]                    @; Guarda la fila en vect_pos[]
			
			b .Lfin
			
		.Lcori5:
			strb r2, [r0]                    @; Guarda la columna en vect_pos[]
			add r0, #1                       @; Incrementa l'índex del vector
			sub r1, #1                      @; Disminueix la fila (f - 1)
			strb r1, [r0]                    @; Guarda la fila disminuïda en vect_pos[]
			add r0, #1                       @; Incrementa l'índex del vector
			strb r2, [r0]                    @; Guarda la columna en vect_pos[]
			add r1, #2                       @; Incrementa la fila dues vegades
			add r0, #1                       @; Incrementa l'índex del vector
			strb r1, [r0]                    @; Guarda la fila incrementada en vect_pos[]

		.Lfin:


			pop {r0-r4,pc}
=======
		push {r1-r5, lr}
		
		.Lprimer_punt:
			cmp r4, #0
			beq .Lcpi_0
			cmp r4, #1
			beq .Lcpi_1
			cmp r4, #2
			beq .Lcpi_2
			cmp r4, #3
			beq .Lcpi_3
			
			.Lcpi_0:
				add r5, r2, #1		@; p.i a la derecha
				strb r5, [r0, #0]	@; r5 = x1
				strb r1, [r0, #1]	@; r1 = y1
				b .Lendprimer_punt
			.Lendcpi_0:
			.Lcpi_1:
				sub r5, r2, #1		@; p.i a la izquierda
				strb r5, [r0, #0]	@; r5 = x1
				strb r1, [r0, #1]	@; r1 = y1
				b .Lendprimer_punt
			.Lendcpi_1:
			.Lcpi_2:
				add r5, r1, #1		@; p.i hacia abajo
				strb r5, [r0, #1]	@; r5 = y1
				strb r2, [r0, #0]	@; r2 = x1
				b .Lendprimer_punt
			.Lendcpi_2:
			.Lcpi_3:
				sub r5, r1, #1		@; p.i hacia arriba
				strb r5, [r0, #1]	@; r5 = y1
				strb r2, [r0, #0]	@; r2 = x1
			.Lendcpi_3:
		.Lendprimer_punt:
		
		.Laltres_punts:
			cmp r3, #0
			beq .Lcori_0
			cmp r3, #1
			beq .Lcori_1
			cmp r3, #2
			beq .Lcori_2
			cmp r3, #3
			beq .Lcori_3
			cmp r3, #4
			beq .Lcori_4
			cmp r3, #5
			beq .Lcori_5
			
			.Lcori_0:
				add r5, r2, #1	@; p.i al este (1)
				strb r5, [r0, #2]	@; r5 = x2
				strb r1, [r0, #3]	@; r1 = y2
				add r5, #1	@; p.i al este (2)
				strb r5, [r0, #4]	@; r5 = x2
				strb r1, [r0, #5]	@; r1 = y2
				b .Lendaltres_punts
			.Lendcori_0:
			.Lcori_1:
				add r5, r1, #1	@; p.i al sur (1)
				strb r5, [r0, #3]	@; r5 = y2
				strb r2, [r0, #2]	@; r2 = x2
				add r5, #1	@; p.i al sur (2)
				strb r5, [r0, #5]	@; r5 = y3
				strb r2, [r0, #4]	@; r2 = x3
				b .Lendaltres_punts
			.Lendcori_1:
			.Lcori_2:
				sub r5, r2, #1	@; p.i al oeste (1)
				strb r5, [r0, #2]	@; r5 = x2
				strb r1, [r0, #3]	@; r1 = y2
				sub r5, #1	@; p.i al oeste (2)
				strb r5, [r0, #4]	@; r5 = x2
				strb r1, [r0, #5]	@; r1 = y2
				b .Lendaltres_punts
			.Lendcori_2:
			.Lcori_3:
				sub r5, r1, #1	@; p.i al norte (1)
				strb r5, [r0, #3]	@; r5 = y2
				strb r2, [r0, #2]	@; r2 = x2
				sub r5, #1	@; p.i al norte (2)
				strb r5, [r0, #5]	@; r5 = y3
				strb r2, [r0, #4]	@; r2 = x3
				b .Lendaltres_punts
			.Lendcori_3:
			.Lcori_4:
				sub r5, r2, #1	@; p.i al oeste (1)
				strb r5, [r0, #2]	@; r5 = x2
				strb r1, [r0, #3]	@; r1 = y2
				add r5, #2	@; p.i al este (1)
				strb r5, [r0, #4]	@; r5 = x3
				strb r1, [r0, #5]	@; r1 = y3 
				b .Lendaltres_punts
			.Lendcori_4:
			.Lcori_5:
				sub r5, r1, #1	@; p.i al sur (1)
				strb r5, [r0, #3]	@; r5 = y2
				strb r2, [r0, #2]	@; r1 = x2
				add r5, #2	@; p.i al norte (1)
				strb r5, [r0, #5]	@; r5 = y3
				strb r2, [r0, #4]	@; r1 = x3
			.Lendcori_5:
		.Lendaltres_punts:
	pop {r1-r5, pc}
>>>>>>> prog2



@; detecta_orientacion(f, c, mat): devuelve el código de la primera orientación
@;	en la que detecta una secuencia de 3 o más repeticiones del elemento de la
@;	matriz situado en la posición (f,c).
@;	Restricciones:
@;		* para proporcionar aleatoriedad a la detección de orientaciones en las
@;			que se detectan secuencias, se invocará la rutina mod_random()
@;			(ver fichero 'candy1_init.s')
@;		* para detectar secuencias se invocará la rutina cuenta_repeticiones()
@;			(ver fichero 'candy1_move.s')
@;		* solo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarán
@;			las marcas de gelatina (+8, +16)
@;	Parámetros:
@;		R1 = fila f
@;		R2 = columna c
@;		R4 = dirección base de la matriz
@;	Resultado:
@;		R0 = código de orientación;
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
<<<<<<< HEAD
@;				en medio de secuencia: 4 -> horitzontal, 5 -> vertical
=======
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
>>>>>>> prog2
@;				sin secuencia: 6 
detecta_orientacion:
		push {r3, r5, lr}
		
		mov r5, #0				@;R5 = índice bucle de orientaciones
		mov r0, #4
		bl mod_random
		mov r3, r0				@;R3 = orientación aleatoria (0..3)
	.Ldetori_for:
		mov r0, r4
		bl cuenta_repeticiones
		cmp r0, #1
		beq .Ldetori_cont		@;no hay inicio de secuencia
		cmp r0, #3
		bhs .Ldetori_fin		@;hay inicio de secuencia
		add r3, #2
		and r3, #3				@;R3 = salta dos orientaciones (módulo 4)
		mov r0, r4
		bl cuenta_repeticiones
		add r3, #2
		and r3, #3				@;restituye orientación (módulo 4)
		cmp r0, #1
		beq .Ldetori_cont		@;no hay continuación de secuencia
		tst r3, #1
		bne .Ldetori_vert
<<<<<<< HEAD
		mov r3, #4				@;detección secuencia horitzontal
=======
		mov r3, #4				@;detección secuencia horizontal
>>>>>>> prog2
		b .Ldetori_fin
	.Ldetori_vert:
		mov r3, #5				@;detección secuencia vertical
		b .Ldetori_fin
	.Ldetori_cont:
		add r3, #1
		and r3, #3				@;R3 = siguiente orientación (módulo 4)
		add r5, #1
		cmp r5, #4
		blo .Ldetori_for		@;repetir 4 veces
		
		mov r3, #6				@;marca de no encontrada
		
	.Ldetori_fin:
		mov r0, r3				@;devuelve orientación o marca de no encontrada
		
		pop {r3, r5, pc}



.end
