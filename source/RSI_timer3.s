	@;=                                                          	     	=
@;=== RSI_timer3.s: rutinas para desplazar el fondo 3 (imagen bitmap) ===
@;=                                                           	    	=
@;=== Programador tarea 2H: gerard.ros@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.global update_bg3
	update_bg3:	.byte	0			@;1 -> actualizar fondo 3
		.global timer3_on
	timer3_on:	.byte	0 			@;1 -> timer3 en marcha, 0 -> apagado
	sentidBG3X:	.byte	0			@;sentido desplazamiento (0-> inc / 1-> dec)
		.align 1
		.global offsetBG3X
	offsetBG3X: .hword	0			@;desplazamiento vertical fondo 3
	divFreq3: .hword	-13091		@; div_freq = -(freq_entrada / freq_salida) = -(130.913,99/10) = -13.091,39
	


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Hb;
@;activa_timer3(); rutina para activar el timer 3.
	.global activa_timer3
activa_timer3:
		push {r0-r1, lr}
			ldr r1, =timer3_on
			mov r0, #1
			strb r0, [r1]		@; variable global timer3_on = 1
			
			ldr r1, =divFreq3	
			ldrh r0, [r1]			@; r3 = divFreq3
			ldr	r1, =0x0400010C		@; 0x0400010C -> REG_TM3D
			strh r0, [r1]			@; copiar registro divFreq3 en REG_TM3D
			
			ldr r1, =0x0400010E		@; 0x0400010E -> REG_TM3CNT
			mov r0, #0xC2			@; activar timer3
			strh r0, [r1]
			
		pop {r0-r1, pc}

@;TAREA 2Hc;
@;desactiva_timer3(); rutina para desactivar el timer 3.
	.global desactiva_timer3
desactiva_timer3:
		push {r0-r1, lr}
			ldr r1, =timer3_on
			mov r0, #0
			strb r0, [r1]		@; variable global timer3_on = 0
			
			ldr r1, =0x0400010E		@;0x0400010E -> REG_TM3CNT
			ldrh r0, [r1]
			bic r0, #0x80			@; bit 7 de REG_TM3CNT a 0
			strh r0, [r1]
			
		pop {r0-r1, pc}



@;TAREA 2Hd;
@;rsi_timer3(); rutina de Servicio de Interrupciones del timer 3: detecta el
@;	sentido de movimiento del fondo gráfico según el valor de sentidBG3X,
@;	actualiza su posición (incrementa o decrementa) en offsetBG3X y activa
@;	una variable global update_bg3 para que la RSI de VBlank actualice la
@;	posición de dicho fondo.
	.global rsi_timer3
rsi_timer3:
		push {r0-r3, lr}
			ldr r0, =sentidBG3X
			ldrb r1, [r0]			@; r1 = sentidBG3X
			ldr r2, =offsetBG3X
			ldrh r3, [r2]			@; r3 = offsetBG3X
			
			cmp r1, #0				@; si sentidBG3X es troba al limit,
			addeq r3, #1
			subne r3, #1
			
			strh r3, [r2]
			
			cmp r3, #320			@; si offsetBG3X es troba al limit inferior,
			moveq r1, #1			@; girar sentidBG3X
			cmp r3, #0				@; offsetBG3X al limit superior
			moveq r1, #0
			
			strb r1, [r0]
			
			ldr r1, =update_bg3		@; activar update_bg3
			mov r0, #1
			strb r0, [r1]
		
		pop {r0-r3, pc}



.end
