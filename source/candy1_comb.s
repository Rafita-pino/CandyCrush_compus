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
@;		R9 = auxiliar columnes
@;		R11 = auxiliar

	.global hay_combinacion
hay_combinacion:
	push {r1-r12, lr}
	
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
			
		.Lendwhile:
		mov r0, #0
		add r3, #1	@; incrementem el desplaçament
		add r2, #1	@; incrementem l'index de les columnes
		
		sub r9, r5, #1	@; r9 = columnes - 1
		cmp r2, r9
		ble .Lif_actual_es_valida
		
		mov r2, #0
		
		sub r9, r6, #1
		cmp r1, r9
		blt .Lwhile
		
	.Lfi:
		pop {r1-r12, pc}



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
		push {lr}
		
		
		pop {pc}



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
		push {lr}
		
		
		pop {pc}



.end
