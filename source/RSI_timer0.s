@;=                                                          	     	=
@;=== RSI_timer0.s: rutinas para mover los elementos (sprites)		  ===
@;=                                                           	    	=
@;=== Programador tarea 2E: rafael.pinor@estudiants.urv.cat				  ===
@;=== Programador tarea 2G: arnau.faura@estudiants.urv.cat				  ===
@;=== Programador tarea 2H: gerard.ros@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.global update_spr
	update_spr:	.byte	0			@;1 -> actualiza sprites
		.global timer0_on
	timer0_on:	.byte	0 			@;1 -> timer0 en marcha, 0 -> apagado
			.align 1
	divFreq0: .hword	-5727			@;divisor de frecuencia inicial para timer 0


@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 1
	divF0: .space	2			@;divisor de frecuencia actual


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm

@;TAREAS 2Ea,2Ga,2Ha;
@;rsi_vblank(); Rutina de Servicio de Interrupciones del retroceso vertical;
@;Tareas 2E,2F: actualiza la posición y forma de todos los sprites
@;Tarea 2G: actualiza las metabaldosas de todas las gelatinas
@;Tarea 2H: actualiza el desplazamiento del fondo 3
	.global rsi_vblank
rsi_vblank:
		push {r0-r5, lr}
		
@;Tareas 2Ea
		
		
@;Tarea 2Ga
	ldr r6, =update_gel		@;r0 = @update_gel (declarada RSI_timer2.s com a byte)
	ldrb r1, [r6] 			@;r1 = valor update_gel
	cmp r1, #0				@;update_gel desactivat?
	beq .L_ignore			@;sí, no actualitzar gelatines
	
	ldr r3, =mat_gel		@;r3 = @mat_gel
	mov r1, #0				@;r1 = index files
	.L_row_loop:
	mov r2, #0				@;r2 = index columnes
	.L_col_loop:
	ldsb r4, [r3, #GEL_II]	@;r4 = mat_gel[r1][r2].ii
	cmp r4, #0	
	bgt .L_end				@;si > 0, seguent posició
	tst r4, #0x80			@;comparació bit mes alt (Ca2)
	bne .L_end				@; si no es 0 (es negatiu), seguent posició
	
	@;si valor valid, fijar_metabaldosa
	ldr r0, =0x06000000		@;r0 = (u16) map_base 	
	ldrb r3, [r3, #GEL_IM]	@;r3 = mat_gel[r1][r2].im
	bl fija_metabaldosa		@;r0;r1;r2;r3 com parametres
	
	ldr r3, =mat_gel		@;r3 = @mat_gel de nou
	mov r5, #10				
	strb r5, [r4]			@;reiniciar camp mat_gel[r1][r2].ii = 10
	
	@; ACTUALITZACIÓ BUCLE
	.L_end:	
	add r2, #1				@;index col += 1
	add r3, #GEL_TAM		@;desplaçament seg. gelatina mapa
	cmp r2, #COLUMNS
	blo .L_col_loop			@;si index col < MAX_COLS, continuar
	add r1, #1				@;sino index fila += 1 (next fila)
	cmp r1, #ROWS
	blo .L_row_loop			@;si index files < MAX_ROWS, continuar
	
	mov r1, #0
	strb r1, [r6]				@;sino, desactivar update_gel
	.L_ignore:					@;acabar actualitzat gelatines
		
@;Tarea 2Ha
		pop {r0-r5, pc}




@;TAREA 2Eb;
@;activa_timer0(init); rutina para activar el timer 0, inicializando o no el
@;	divisor de frecuencia según el parámetro init.
@;	Parámetros:
@;		R0 = init; si 1, restablecer divisor de frecuencia original divFreq0
	.global activa_timer0
activa_timer0:
		push {lr}
		
		
		pop {pc}


@;TAREA 2Ec;
@;desactiva_timer0(); rutina para desactivar el timer 0.
	.global desactiva_timer0
desactiva_timer0:
		push {lr}
		
		
		pop {pc}



@;TAREA 2Ed;
@;rsi_timer0(); rutina de Servicio de Interrupciones del timer 0: recorre todas
@;	las posiciones del vector vect_elem y, en el caso que el código de
@;	activación (ii) sea mayor o igual a 0, decrementa dicho código y actualiza
@;	la posición del elemento (px, py) de acuerdo con su velocidad (vx,vy),
@;	además de mover el sprite correspondiente a las nuevas coordenadas.
@;	Si no se ha movido ningún elemento, se desactivará el timer 0. En caso
@;	contrario, el valor del divisor de frecuencia se reducirá para simular
@;  el efecto de aceleración (con un límite).
	.global rsi_timer0
rsi_timer0:
		push {lr}
		
		
		pop {pc}



.end
