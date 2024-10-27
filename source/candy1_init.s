@;=                                                          	     	=
@;=== candy1_init.s: rutinas para inicializar la matriz de juego	  ===
@;=                                                           	    	=
@;=== Programador tarea 1A: rafael.pinor@estudiants.urv.cat			  ===
@;=== Programador tarea 1B: rafael.pinor@estudiants.urv.cat			  ===
@;=                                                       	        	=



.include "candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; matrices de recombinación: matrices de soporte para generar una nueva matriz
@;	de juego recombinando los elementos de la matriz original.
	mat_recomb1:	.space ROWS*COLUMNS
	mat_recomb2:	.space ROWS*COLUMNS



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1A;
@; inicializa_matriz(*matriz, num_mapa): rutina para inicializar la matriz de
@;	juego, primero cargando el mapa de configuración indicado por parámetro (a
@;	obtener de la variable global mapas[][]) y después cargando las posiciones
@;	libres (valor 0) o las posiciones de gelatina (valores 8 o 16) con valores
@;	aleatorios entre 1 y 6 (+8 o +16, para gelatinas)
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			mod_random()
@;		* para evitar generar secuencias se invocará la rutina
@;			cuenta_repeticiones() (ver fichero 'candy1_move.s')
@;	Parmetros:
@;		R0 = direccion base de la matriz de juego
@;		R1 = numero de mapa de configuracion (para copiar)
@;	Registros:
@;		R0 = Valores para otras rutinas
@;		R1 = Filas (i)
@;		R2 = Columnas (j)
@;		R3 = num mapa config // Bits 0..2 // Direccion cuenta repeticiones
@;		R4 = Direccion base matriz juego
@;		R5 = Direccion base del mapa config
@;		R6 = Desplazamiento de posiciones
@;		R7 = Valor de la casilla (R1,R2) 
@;		R8 = valor per accedir a mapa config // Bits 4..3
	.global inicializa_matriz
inicializa_matriz:
	push {r0-r8, lr}		@;guardar registros utilizados
		mov r4, r0				@; r0 = direccion base de la matriz
		mov r3, r1				@; r3 = num mapa config				
		ldr r5, =mapas
		mov r8, #COLUMNS*ROWS	@; multiplicamos columnas por filas
		mul r8, r3					@;multiplicamos el resultado anterior por el numero de mapa de configuracion
		add r5, r8					@;accedemos al mapa
		mov r6, #0		@; desplazamiento de posiciones
		mov r1, #0		@; desplazamiento de filas (i)
		.L_fori:
			mov r2, #0	@; desplazamiento de columnas (j)
			.L_forj:
				ldrb r7, [r5, r6] @; r7= valor de la casilla (R1,R2) de mapa config
				mov r3, r7
				and r3, #0x07	  @; procesamos los bits 2..0 del contenido de r3 (R1,R2)
				tst r3, #0x07
				beq .L_random
				strb r7, [r4, r6] @; guardamos el resultado en la matriz de juego si r3=! 000
				b .L_fi
				
			.L_random:
				mov r0, #6			  @; pasamos rango maximo
				bl mod_random		 
				tst r0, #0x00
				addeq r0, #1			@; si es 0, sumamos 1
				add r3, r7, r0		  @; sumamos al valor inicial el resultado y lo guardamos en r3
				strb r3, [r4, r6]	  @; subimos a la matriz de juego el resultado para cuenta_repeticiones
				
				mov r0, r4			   @; volvemos a poner la direccion base de la matriz de juego en r0
				mov r3, #2			   @; direccion 2
				bl cuenta_repeticiones @; llamamos a cuenta_repeticiones para comprovar que no tenemos secuencias
				cmp r0, #3			   @; comparamos el resultado de cuenta_repeticiones con 3
				bge .L_random 		   @; si >= 3, es que tenemos secuencia de >= 3
				
				mov r0, r4			   @; volvemos a poner la direccion base de la matriz de juego en r0
				mov r3, #3			   @; direccion 3 (REPETIMOS PROCESO EN DIRECCION 3)
				bl cuenta_repeticiones 
				cmp r0, #3			   
				bge .L_random 		   
				
			.L_fi:
				add r6, #1 @; avanza desplazamiento de posiciones						   
				add r2, #1 
				cmp r2, #COLUMNS @; comparamos con el numero de columnas para recorerlas todas
				blo .L_forj
			add r1, #1
			cmp r1, #ROWS @;comparamos con el numero de filas para recorerlas todas
			blo .L_fori
	pop {r0-r8, pc}

@;TAREA 1B;
@; recombina_elementos(*matriz): rutina para generar una nueva matriz de juego
@;	mediante la reubicación de los elementos de la matriz original, para crear
@;	nuevas jugadas.
@;	Inicialmente se copiará la matriz original en mat_recomb1[][], para luego ir
@;	escogiendo elementos de forma aleatoria y colocándolos en mat_recomb2[][],
@;	conservando las marcas de gelatina.
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			mod_random()
@;		* para evitar generar secuencias se invocará la rutina
@;			cuenta_repeticiones() (ver fichero 'candy1_move.s')
@;		* para determinar si existen combinaciones en la nueva matriz, se
@;			invocará la rutina hay_combinacion() (ver fichero 'candy1_comb.s')
@;		* se puede asumir que siempre existirá una recombinación sin secuencias
@;			y con posibles combinaciones
Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;	Regitros:
@;		R1 = indice de fila
@;		R2 = indice de columna
@;		R3 = valor casilla matriz
@;		R4 = direccion base de la matriz de juego
@;		R5 = temporal
@;		R6 = puntero
@;		R7 = mat_recomb1
@;		R8 = mat_recomb2
@;		R9 = iteraciones
@;		R10= posicion aleatoria de mat_recomb1 
@;		R11= temporal
@;		R12= indice filas * columnas
	.global recombina_elementos
recombina_elementos:
		push {r0-r12, lr}
		mov r4, r0					@;direccion base de la matriz
		ldr r7, =mat_recomb1		@;cargamos mat_recomb1
		ldr r8, =mat_recomb2		@;cargamos mat_recomb2
		@; RECORREMOS MATRIZ DE JUEGO
	.L_IniMatJoc:
		mov r6, #0					@;inicializamos puntero
		mov r1, #0					@;inicializamos filas
		.L_FilaMatJoc:
			mov r2, #0					@;inicializamos columnas
			mov r3, #COLUMNS			@;guardamos max COLUMNS en r3
			mul r12, r1, r3				@;r12 = fila * COLUMNS
			.L_colMatJoc:
				ldrb r3, [r4, r6]			@; r3 = contenido mat_joc[r1][r2]
				cmp r3, #0					@; comparamos con vacio (0)
				beq .L_copia				@; lo copiamos directamente a mat_recomb2
				mov r5, r3					@; copiamos el mat_joc[r1][r2] en r5 para no perderlo
				and r5, #0x07				@; mascara para bits 2..0
				cmp r5, #0x07				@; comparamos con bloque solido (7) i con hueco (15) bits 2..0 = 111
				beq .L_copia2				@; lo copiamos directamente a mat_recomb2 y a mat_recomb1
				cmp r5, #0x00				@; comparamos con gelatinas vacias (8,16) bits 2..0 = 000
				beq .L_copia2
				
				@;MASCARA DE BITS 4..3 PARA OTROS CASOS
				mov r5, r3, lsr#3			
				and r5, #0x03				@; nos quedan los bits (4..3)
				cmp r5, #0x01				@; comparamos con gelatina simple (01)
				beq .L_gSimple				@; si r5, bucle gelatina simple
				cmp r5, #0x02				@; comparamos con gelatina doble (10)
				beq .L_gDoble				@; si r5, bucle gelatina doble
				cmp r5, #0x00				@; comparamos con elemento simple (00)
				beq .L_copia				@; si r5, elemento simple 
				b .L_FiMatJoc				@; sino es ninguno pasamos de casilla
				.L_gSimple:		@; bule para gelatina simple (01)
					strb r3, [r8, r6]			@; guardamos valor exacto en a mat_recomb2 (misma posicion)
					sub r5, r3, #8				@; r5 = elemento simple (r5 = gel. simple - 8)
					strb r5, [r7, r6]			@; guardamos en mat_recomb1 (misma posicion)
					b .L_FiMatJoc				@; final
				.L_gDoble:		@; bule para gelatina doble (10)
					strb r3, [r8, r6]			@; guardamos valor exacto en a mat_recomb2 (misma posicion)
					sub r5, r3, #16				@; r5 = elemento doble (r5 = gel.doble - 16)
					strb r5, [r7, r6]			@; guardamos en mat_recomb1 (misma posicion)				
					b .L_FiMatJoc				@; final 
				.L_copia:		@; bule para copiar en mat_recomb1 y mat_recomb2
					strb r3, [r7, r6]			@; guardamos valor en mat_recomb1 en la posicion actual
					strb r3, [r8, r6]			@; guardamos valor exacto en a mat_recomb2 (misma posicion)
					b .L_FiMatJoc				@; final
				.L_copia2:		@; bule para copiar en mat_recomb2
					strb r3, [r8, r6]			@; copio el valor de la matriz de juego directo a mat_recomb2
					mov r3, #0					@; bloque solido (7), hueco (15), gelatinas vacias (8,16) = 0
					strb r3, [r7, r6]			@; guardamos en mat_recomb1 un 0 en la posicion del bloque solido/hueco/gel.vacia
				.L_FiMatJoc:
				add r6, #1 					@; siguiente posicion
				add r2, #1					@; avanza columna
				cmp r2, #COLUMNS			@; miramos si estamos en final de fila
				blo .L_colMatJoc			@; avanza al siguiente elemento si esta al final de fila
				
			add r1, #1					@; avanza fila
			cmp r1, #ROWS				@; miramos si estamos en final de columna
			blo .L_FilaMatJoc		@; avanza al siguiente elemento siempre que no este al final
			
	@;UNA VEZ ACABADA LAS COPIAS, EMPEZAMOS LA RECOMBINACION :)		
	
	.L_IniRecomb2:
		mov r6, #0					@; inicializamos puntero
		mov r1, #0					@; inicializamos filas
		.L_FilaRecomb2:
			mov r2, #0					@;inicializamos columnas
			mov r3, #COLUMNS			@;guardamos max COLUMNS en r3
			mul r12, r1, r3				@;r12 = fila * COLUMNS
			.L_ColRecomb2:
			
				ldrb r3, [r4, r6]			@; r3 = contenido mat_joc[r1][r2]
				
				mov r5, r3					@; copiamos en r5 el contenido de r3 para no perderlo
				and r5, #0x07	  			@; procesamos los bits 2..0 del contenido de r5 (R1,R2)
				cmp r5, #0x00
				beq .L_FiRecomb2			@; si el codigo es 0, 8 o 16, pasamos al siguiente
				cmp r5, #0x07				@; comparamos con bloque solido (7) i con hueco (15) bits 2..0 = 111
				beq .L_FiRecomb2
				mov r9, #0					@; inicializamos el contador de interaciones				
				
				.L_Random:
					mov r0, #COLUMNS*ROWS
					bl mod_random				@; numero aleatorio de la matriz

					add r9, #1					@; incrementamos el contador de iteraciones maximas
					mov r10, r0
					ldrb r5, [r7, r10]			@; r5 = valor de mat_recomb1 de la casilla aleatoria
					
					cmp r9, #MAX_ITERACIONES	@; MAX_ITERACIONES definido en candy1_incl.i
					
					movhs r0, r4				@; si tenemos que volver a empezar, cargamos direccion matjoc en r0
					bhs recombina_elementos		@; podria crearse un bucle infinito, pero como el enunciado dice que se asume
												@; que siempre puede haber una posible reordenacion, pues... (a veces genera bucles infinitos)
					
					cmp r5, #0					@; comparamos con un elemento ya usado (mat_recomb1 = 0)
					beq .L_Random				@; si esta usado repetimos proceso de random
					
					strb r5, [r8, r6]			@; cargamos valor (r5) en mat_recomb2					
					mov r0, r8					@; direccion base de la matriz
					mov r3, #2					@; direccion 2 para cuenta_repeticiones
					bl cuenta_repeticiones
					cmp r0, #3					@; si r0>=3 tenemos secuencia
					bge .L_Random				@; repetimos proceso para evitar secuencias
					

					mov r0, r8					@; direccion base de la matriz
					mov r3, #3					@; direccion 3 para cuenta_repeticiones
					bl cuenta_repeticiones		
					cmp r0, #3					@; si r0>=3 tenemos secuencia
					bge .L_Random				@; si r0, repetimos proceso para evitar secuencias

					
				ldrb r5, [r8, r6]			@; volvemos a coger los valores de la matriz de juego y de mat_recomb2 porque no se donde algun registro se modifica
											@; y produce errores 											
				ldrb r3, [r4, r6]
			

				

				mov r3, r3, lsr#3			
				and r3, #0x03				@; nos quedan los bits (4..3)
				cmp r3, #0x01				@; comparamos con gelatina simple (01)
				beq .CopiaGelatina8			@; si r5, bucle gelatina simple
				cmp r3, #0x02				@; comparamos con gelatina doble (10)
				beq .CopiaGelatina16		@; si r5, bucle gelatina doble 	
				b .SubstituirRecomb1
				
				.CopiaGelatina8:

					add r5, #8			@; añadimos codigo de gelatina de mat_joc a mat_recomb2
					strb r5, [r8, r6]		@; subimos a mat_recomb2 el codigo final
					b .SubstituirRecomb1
				.CopiaGelatina16:
					add r5, #16			@; añadimos codigo de gelatina de mat_joc a mat_recomb2
					strb r5, [r8, r6]		@; subimos a mat_recomb2 el codigo final	
				.SubstituirRecomb1:			@; sino tenemos gelatina, el codigo ya esta copiado y substituimos en recomb1
					mov r5, #0					@; preparamos el 0 para sustituir en mat_recomb1
					strb r5, [r7, r10]			@; si no hay secuencia sustituimos el valor de mat_recomb1 por 0 (ya utilizado)

					

		.L_FiRecomb2:
			add r6, #1					@; avanzamos posicion
			add r2, #1					@; avanza columna
			cmp r2, #COLUMNS			@; miramos si estamos en final de fila
			blo .L_ColRecomb2		@; avanza al siguiente elemento
		
		add r1, #1					@; avanza fila
		cmp r1, #ROWS				@; miramos si estamos en final columna
		blo .L_FilaRecomb2			@; avanza al siguiente elemento
		
	.L_FINAL:

		mov r6, #0					@; inicializamos puntero
		mov r1, #0					@; inicializamos filas
		.L_buclefilasFIN:
			mov r2, #0					@; inicializamos columnas
			mov r3, #COLUMNS			@; r3 = COLUMNS
			mul r12, r1, r3				@; r12 = index files * COLUMNS
			add r6, r12, r2				@; preparamos puntero (i*COLUMNS +j)
			.L_buclecolFIN:
				ldrb r3, [r8, r6]			@; R3 = valor casilla (r1, r2) mat_recomb2
				strb r3, [r4, r6]			@; guardamos en la matriz de juego el valor de mat_recomb2
			.L_finalFIN:
			add r6, #1					@; avanza posicion
			add r2, #1					@; avanza columna
			cmp r2, #COLUMNS			@; miramos si estamos en final de la fila
			blo .L_buclecolFIN			@; avanza al siguiente elemento
		add r1, #1					@; avanza fila
		cmp r1, #ROWS				@; miramos si estamos en final columna
		blo .L_buclefilasFIN		@; avanza al siguiente elemento

		pop {r0-r12, pc}



@;:::RUTINAS DE SOPORTE:::


@; mod_random(n): rutina para obtener un número aleatorio entre 0 y n-1,
@;	utilizando la rutina random()
@;	Restricciones:
@;		* el parámetro n tiene que ser un natural entre 2 y 255, de otro modo,
@;		  la rutina lo ajustará automáticamente a estos valores mínimo y máximo
@;	Parámetros:
@;		R0 = el rango del número aleatorio (n)
@;	Resultado:
@;		R0 = el número aleatorio dentro del rango especificado (0..n-1)

@;=                                                               		=
@;=== candy1_init.s: rutinas para inicializar la matriz de juego	  ===
@;=                                                               		=

	.global mod_random
mod_random:
		push {r2-r4, lr}
		cmp r0, #2				@;compara el rango de entrada con el mínimo
		movlo r0, #2			@;si menor, fija el rango mínimo
		and r0, #0xFF			@;filtra los 8 bits de menos peso
		sub r2, r0, #1			@;R2 = R0-1 (número más alto permitido)
		mov r3, #1				@;R3 = máscara de bits
	.Lmodran_forbits:
		cmp r3, r2				@;genera una máscara superior al rango requerido
		bhs .Lmodran_loop
		mov r3, r3, lsl #1
		orr r3, #1				@;inyecta otro bit
		b .Lmodran_forbits
		
	.Lmodran_loop:
		bl random				@;R0 = número aleatorio de 32 bits
		and r4, r0, r3			@;filtra los bits de menos peso según máscara
		cmp r4, r2				@;si resultado superior al permitido,
		bhi .Lmodran_loop		@; repite el proceso
		mov r0, r4
		
		pop {r2-r4, pc}


@; random(): rutina para obtener un número aleatorio de 32 bits, a partir de
@;	otro valor aleatorio almacenado en la variable global seed32 (declarada
@;	externamente)
@;	Restricciones:
@;		* el valor anterior de seed32 no puede ser 0
@;	Resultado:
@;		R0 = el nuevo valor aleatorio (también se almacena en seed32)
random:
	push {r1-r5, lr}
		
	ldr r0, =seed32				@;R0 = dirección de la variable seed32
	ldr r1, [r0]				@;R1 = valor actual de seed32
	ldr r2, =0x0019660D
	ldr r3, =0x3C6EF35F
	umull r4, r5, r1, r2
	add r4, r3					@;R5:R4 = nuevo valor aleatorio (64 bits)
	str r4, [r0]				@;guarda los 32 bits bajos en seed32
	mov r0, r5					@;devuelve los 32 bits altos como resultado
		
	pop {r1-r5, pc}	



.end
