@;=                                                               		=
@;=== candy1_secu.s: rutinas para detectar y elimnar secuencias 	  ===
@;=                                                             	  	=
@;=== Programador tarea 1C: xxx.xxx@estudiants.urv.cat				  ===
@;=== Programador tarea 1D: yyy.yyy@estudiants.urv.cat				  ===
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
@;		R7 = num files
@;		R8 = num columnes
	.global hay_secuencia
hay_secuencia:
		push {r1-r10, lr}
			
			mov r1, #0							@; index fila
			mov r4, r0							@; copia direccio base matriu
			mov r0, #0							@; inicialitzar en 0 en cas de mai executarse cuenta_repeticiones
			mov r6, #0							@; posicio matriu
			mov r7, #ROWS						@; numero de files
			mov r8, #COLUMNS					@; numero de columnes
			sub r9, r7, #2						@; r9 = delimitador filas (penultima)
			sub r10, r8, #2						@; r10 = delimitador columnas (penultima)
			
			.LwhileF:
				cmp r1, r7
				beq .LfiwhileF					@; sortir al acabar la ultima fila
				mov r2, #0						@; index columna
				
				.LwhileC:						@; recorrer linealment les columnes
					cmp r2, r8
					beq .LfiwhileC				@; Cambiar de fila al acabar la ultima columna
					mla  r6, r1, r8, r2			@; R6 = posicio matriu -> R6 = R1 * R9 + R2
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
					
					cmp r2, r10
					bge .LcheckVertical			@; nomes comprovar verticals si columna es penultima
					
					@; Contar repeticions horitzontals
					mov r3, #0					@; R3 = orientacio est(0)
					mov r0, r4					@; R0 = direccio matriu
					bl cuenta_repeticiones		@; retorna a R0 les repeticion
					cmp r0, #3			
					bhs .LfiwhileF				@; Sortir del bucle si repeticions >=3
					
					cmp r1, r9					@; Fi de columna si es penultima
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
		pop {r1-r10, pc}


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
		push {lr}
		
		
		pop {pc}


	
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
		push {lr}
		
		
		pop {pc}



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
		push {lr}
		
		
		pop {pc}



.end
