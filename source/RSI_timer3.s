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
	divFreq3: .hword	-3273 	@;divisor de frecuencia para timer 3
	@; divFreq3 = -(32728,498046875 / 10)
	


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Hb;
@;activa_timer3(); rutina para activar el timer 3.
	.global activa_timer3
activa_timer3:
		push {r0-r4, lr}
			ldr r0, =timer3_on
			mov r1, #1
			strb r1, [r0]		@; variable global timer3_on = 1
			
			ldr r2, =divFreq3	
			ldrsh r3, [r2]			@; r3 = divFreq3 (signed half)
			ldr	r4, =0x0400010C		@; 0x0400010C -> REG_TM3D
			orr r3, #0x00C20000
			strh r3, [r4]			@; copiar registro divFreq3 en REG_TM3D
			
			ldr r0, =0x0400010E		@; 0x0400010E -> REG_TM3CNT
			mov r1, #0xC3			@; activar timer3
			strb r1, [r0]
			
		pop {r0-r4, pc}

@;TAREA 2Hc;
@;desactiva_timer3(); rutina para desactivar el timer 3.
	.global desactiva_timer3
desactiva_timer3:
		push {r0-r1, lr}
			ldr r0, =timer3_on
			mov r1, #0
			strb r1, [r0]		@; variable global timer3_on = 0
			
			ldr r0, =0x0400010E		@;0x0400010E -> REG_TM3CNT
			ldrb r1, [r0]
			bic r1, #128			@; bit 7 de REG_TM3CNT a 0
			strb r1, [r0]
			
		pop {r0-r1, pc}



@;TAREA 2Hd;
@;rsi_timer3(); rutina de Servicio de Interrupciones del timer 3: detecta el
@;	sentido de movimiento del fondo gráfico según el valor de sentidBG3X,
@;	actualiza su posición (incrementa o decrementa) en offsetBG3X y activa
@;	una variable global update_bg3 para que la RSI de VBlank actualice la
@;	posición de dicho fondo.
	.global rsi_timer3
rsi_timer3:
		push {r0-r5, lr}
			ldr r0, =sentidBG3X
			ldrb r1, [r0]			@; r1 = sentidBG3X
			ldr r2, =offsetBG3X
			ldrh r3, [r2]			@; r3 = offsetBG3X
			
			cmp r3, #0				@; si offsetBG3X es troba al limit superior,
			moveq r1, #0			@; girar sentidBG3X
			
			cmp r3, #255			@; si offsetBG3X es troba al limit inferior,
			moveq r1, #1			@; girar sentidBG3X
			
			strb r1, [r0]
			
			cmp r1, #0				@; sentidBG3X = 0?
			addeq r3, #1			@; sí -> offsetBG3X++;
			subne r3, #1 			@; no -> offsetBG3X--;
			
			strh r3, [r2]
			
			ldr r4, =update_bg3		@; activar update_bg3
			mov r5, #1
			strb r5, [r4]
		
		pop {r0-r5, pc}



.end
