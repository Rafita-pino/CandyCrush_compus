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
@;		R8 = auxiliar casella horitzontal
@;		R9 = auxiliar columnes
@;		R10 = auxiliar casella vertical
@;		R11 = auxiliar

	.global hay_combinacion
hay_combinacion:
	push {r1-r11, lr}
	
		mov r4, r0 @; r4 = direcció base de la matriu de joc
		mov r1, #0 @; r1 = index de files
		mov r2, #0 @; r2 = index de columnes
		mov r3, #0 @; r3 = index de desplaçament
		mov r5, #COLUMNS
		mov r6, #ROWS
		
		b .Lif_es_valid
		
		.Lwhile:
			add r1, #1
			
			.Lif_es_valid:
				ldrb r7, [r4, r3] 	@; r7 = casella actual
				and r11, r7, #0x07
				cmp r11, #0x07		@; si r7 es un bloc solid o un forat no es valid
				beq .Lendwhile
				cmp r11, #0x00		@; si r7 es un bloc buit no es valid
				beq .Lendwhile
			.Lendif_es_valid:
		
			.Lif_ultima_columna:
				sub r9, r5, #1
				cmp r2, r9
				bge .Lif_es_ultima_fila
			.Lendif_ultima_columna:
			
			.Lif_igual_posterior_horitzontal:
				add r3, #1 @; r3 = r3 + 1
				ldrb r8, [r4, r3] @; r8 = casilla posterior horizontal
				sub r3, #1
				cmp r7, r8
				beq .Lif_es_ultima_fila
			.Lendif_igual_posterior_horitzontal:

			.Lif_posterior_horitzontal_valida:
				and r11, r8, #0x07
				cmp r11, #0x07
				beq .Lif_es_ultima_fila
				cmp r11, #0x00
				beq .Lif_es_ultima_fila
			.Lendif_posterior_horitzontal_valida:
			
			@; Intercanvi horitzontal
				strb r8, [r4, r3]
				add r3, #1
				strb r7, [r4, r3]
				sub r3, #1
				
			@; Comprovar primera casella
				bl detecta_orientacion
				cmp r0, #6
				bne .Lif_sequencia_trobada_horitzontal
				
			@; Comprovar segona casella
				add r2, #1
				bl detecta_orientacion
				sub r2, #1
				cmp r0, #6
				bne .Lif_sequencia_trobada_horitzontal
				
			@; Desfer intercanvi horitzontal
				strb r7, [r4, r3]
				add r3, #1
				strb r8, [r4, r3]
				sub r3, #1
			
			.Lif_es_ultima_fila:
				sub r9, r6, #1 @; r9 = files - 1
				cmp r1, r9
				bge .Lendwhile
			.Lendif_es_ultima_fila:
			
			.Lif_posterior_vertical_igual:
				add r3, r5 @; r3 = r3 + columnes
				ldrb r10, [r4, r3] @; r10 = casilla posterior vertical
				sub r3, r5
				cmp r7, r10
				beq .Lendwhile
			.Lendif_posterior_vertical_igual:
			
			.Lif_posterior_vertical_valida:
				and r11, r10, #0x07
				cmp r11, #0x07
				beq .Lendwhile
				cmp r11, #0x00
				beq .Lendwhile
			.Lendif_posterior_vertical_valida:
			
			@; Intercanvi vertical
				strb r10, [r4, r3]
				add r3, r5
				strb r7, [r4, r3]
				sub r3, r5 @; r3 = r3 - columnes
				
				
			@; Comprovar primera casella
				bl detecta_orientacion
				cmp r0, #6
				bne .Lif_sequencia_trobada_vertical
				
				
			@; Comprovar segona casella
				add r1, #1
				bl detecta_orientacion
				sub r1, #1
				cmp r0, #6
				bne .Lif_sequencia_trobada_vertical
				
			@; Desfer intercanvi vertical
				strb r7, [r4, r3]
				add r3, r5 @; r3 = r3 + columnes
				strb r10, [r4, r3]
				sub r3, r5 @; r3 = r3 - columnes
			b .Lendwhile
			
			.Lif_sequencia_trobada_horitzontal:
				@; Desfer intercanvi horitzontal
				strb r7, [r4, r3]
				add r3, #1
				strb r8, [r4, r3]
				sub r3, #1
				
				mov r0, #1
				b .Lfi
			.Lifend_sequencia_trobada_horitzontal:
			
			.Lif_sequencia_trobada_vertical:
				@; Desfer intercanvi vertical
				strb r7, [r4, r3]
				add r3, r5 @; r3 = r3 + columnes
				strb r10, [r4, r3]
				sub r3, r5
				
				mov r0, #1
				b .Lfi
			.Lendif_sequencia_trobada_horitzontal:
			
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

	.global sugiere_combinacion
sugiere_combinacion:
		push {lr}
		
		
		pop {pc}




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
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;		R4 = código de posición inicial cpi:
@;				0 -> izquierda, 1 -> derecha, 2 -> arriba, 3 -> abajo
@;	Resultado:
@;		vector de posiciones (x1,y1,x2,y2,x3,y3), devuelto por referencia
genera_posiciones:
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
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
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
		mov r3, #4				@;detección secuencia horizontal
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
