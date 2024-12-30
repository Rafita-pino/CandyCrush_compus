@;=                                                          	     	=
@;=== RSI_timer2.s: rutinas para animar las gelatinas (metabaldosas)  ===
@;=                                                           	    	=
@;=== Programador tarea 2G: arnau.faura@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "candy2_incl.i"
#define TIMER2_DATA  0x04000108    @;dir. reg. datos timer 2
@;dir. reg. control timer 2 = 0x0400010A

@;-- .data. variables (globales) inicializadas ---
.data
		.global update_gel
	update_gel:	.byte	0			@;1 -> actualiza gelatinas
		.global timer2_on
	timer2_on:	.byte	0 			@;1 -> timer2 en marcha, 0 -> apagado
		.align 1
	divFreq2: .hword	-5237		@;divisor de frecuencia para timer 2
									@;F.salida = 10cambios x seg * 10 int por cambio (.im) = 100
									@;Divisor = -523655,97 (F. ent / 64) / 100Hz = -5236,55 -> -5237 



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Gb;
@;activa_timer2(); rutina para activar el timer 2.
@;con el valor de divFreq2
	.global activa_timer2
activa_timer2:
		push {r0-r2, lr}
		
	ldr r0, =timer2_on
	mov r1, #1
	strb r1, [r0]				@;guardar 1 en timer2_on (activar)
	
	ldr r0, =TIMER2_DATA
	ldr r1, =divFreq2
	ldrh r2, [r1]				@;r2 = (valor) divFreq2
	orr r2, #0x00C10000        	@;configurar bits superiores:
                                @; 0xC (IRQ enable y prescaler F/64)
                                @; 0x1 (activar timer)
	str r2, [r0]				@;escribir 32 bits en TIMER2_DATA (control incluido)
	
		pop {r0-r2, pc}


@;TAREA 2Gc;
@;desactiva_timer2(); rutina para desactivar el timer 2.
	.global desactiva_timer2
desactiva_timer2:
		push {r0-r2, lr}
		
	ldr r0, =timer2_on
	ldr r1, =TIMER2_DATA
	mov r2, #0
	strb r2, [r0]				@;desactivar timer2_on (posar valor a 0)
	
	ldr r2, [r1]				@;r2 = valor TIMER2_DATA
	
	bic r2, #0x00800000			@;TIMER2_CR (bit 7 = stop/start), a 0 
	str r2, [r1]
	
		pop {r0-r2, pc}



@;TAREA 2Gd;
@;rsi_timer2(); rutina de Servicio de Interrupciones del timer 2: recorre todas
@;	las posiciones de la matriz mat_gel[][] y, en el caso que el código de
@;	activación (ii) sea mayor o igual a 1, decrementa dicho código en una unidad
@;	y, en el caso que alguna llegue a 0, incrementa su código de metabaldosa y
@;	activa una variable global update_gel para que la RSI de VBlank actualice
@;	la visualización de dicha metabaldosa.
	.global rsi_timer2
rsi_timer2:
		push {r0-r3, lr}
	
	ldr r0, =mat_gel
	mov r1, #0				@;r1 = index bucle
	
	.L_loop:
	ldsb r2, [r0, #GEL_II]	@;r2 = valor mat_gel[][].ii
	cmp r2, #0
	beq .L_check_gel		@;si mat_gel[][].ii == 0, actualitzar .im (baldosa)
	tst r2, #0x80			@;comprovació nombre negatiu (-1)
	bne .L_end				@;si mat_gel[][].ii == -1, saltar posició
	sub r2, #1				
	strb r2, [r0, #GEL_II]	@;sino, si ii > 0, decrementar-la
	b .L_end   				@;següent element
	
	.L_check_gel:
	ldrb r2, [r0, #GEL_IM]	@;r2 = valor mat_gel[][].im
	add r2, #1				@;actualitzar .im (baldosa)
	cmp r2, #16				
	beq .L_reset_double		@;si .im == 16 (màxim index per gel. dobles), resetear a 8
	cmp r2, #8
	beq .L_reset_simple		@;sino, si .im == 8 (màxim index per gel. simple), resetar a 0
	
	strb r2, [r0, #GEL_IM]	@;sino, valor correcte i actualitzar mat_gel[][].im
	b .L_update_gel
	
	.L_reset_simple:
	mov r2, #0
	strb r2, [r0, #GEL_IM]	@;canvi de 8 -> 0 (restart)
	b .L_update_gel
	
	.L_reset_double:
	mov r2, #8
	strb r2, [r0, #GEL_IM]	@;canbi de 16 -> 8
	
	.L_update_gel:
	ldr r3, =update_gel
	mov r2, #1
	strb r2, [r3]			@;activar update_gel, =1 
	
	.L_end:
	add r1, #1				@;index bucle += 1
	add r0, #GEL_TAM		@;seguent gelatina
	ldr r3, =ROWS*COLUMNS	@;r3 = ROWS * COLUMNS (últim index matriu)			
	cmp r1, r3
	blt .L_loop				@;final matriu? **ble**
							@;si, acabar
		pop {r0-r3, pc}



.end
