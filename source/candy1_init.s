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
				b .L_llamaCuentaRepes
				
			.L_random:
				mov r0, #6			  @; pasamos rango maximo
				bl mod_random		  
				add r3, r7, r0		  @; sumamos al valor inicial el resultado y lo guardamos en r3
				strb r3, [r4, r6]	  @; subimos a la matriz de juego el resultado para cuenta_repeticiones
				.L_llamaCuentaRepes:
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
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
	.global recombina_elementos
recombina_elementos:
		push {lr}
		
		
		pop {pc}



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
