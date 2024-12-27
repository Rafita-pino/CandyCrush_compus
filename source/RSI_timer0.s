﻿@;=                                                          	     	=
@;=== RSI_timer0.s: rutinas para mover los elementos (sprites)		  ===
@;=                                                           	    	=
@;=== Programador tarea 2E: xxx.xxx@estudiants.urv.cat				  ===
@;=== Programador tarea 2G: rafael.pinor@estudiants.urv.cat				  ===
@;=== Programador tarea 2H: zzz.zzz@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.global update_spr
	update_spr:	.byte	0			@;1 -> actualiza sprites
		.global timer0_on
	timer0_on:	.byte	0 			@;1 -> timer0 en marcha, 0 -> apagado
			.align 1
	divFreq0: .hword	-5727		@; divisor de frecuencia inicial para timer 0
									@; divFreq = -(33.513.982/64)/(1/(0,35/32)) = -(33.513.982/64)*(0,35/32) = -5727
									@; cogemos 32 porque se indica que las interrupciones se hacen en 32 subpartes, 
									@; por lo tanto queremos la 32parte del tiempo.
									@; y cogemos 64 porque es el que mas se acerca a la frecuencia de entrada.


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
		push {r0-r3,lr}
		
@;Tareas 2Ea
		ldr r2, =update_spr			
		ldrh r3, [r2]				
		
		cmp r3, #1						@;si update_spr!=1 --> salta la actualizacion
		bne .I_notOne
			ldr r0, =0x7000000			@; cargamos direccion OAM (Sprites_sopos.s)
			mov r1, #128				@; limite de sprites para la funcion
			bl SPR_actualiza_sprites	
			mov r0, #0					
			strh r0, [r2]				@; finalizamos actualizacion; update_spr=0
		.I_notOne:
		
@;Tarea 2Ga
		
		
@;Tarea 2Ha
		
		
		pop {r0-r3,pc}




@;TAREA 2Eb;
@;activa_timer0(init); rutina para activar el timer 0, inicializando o no el
@;	divisor de frecuencia según el parámetro init.
@;	Parámetros:
@;		R0 = init; si 1, restablecer divisor de frecuencia original divFreq0
	.global activa_timer0
activa_timer0:
		push {r1-r3, lr}
			cmp r0, #0					@; si init != 0; se copia
			beq .I_NoCopia
				ldr r1, =divFreq0		@; divFreq0 original
				ldrsh r2, [r1]			@; ldrSh --> S para guardar el simbolo
				ldr r1, =divF0			@; divFreq0 act
				strh r2, [r1]			
				
			.I_NoCopia:
			ldr r1, =timer0_on			
			mov r3, #1					@; timer0 en marcha
			strh r3, [r1]			
			
			ldr r1, =0x04000100			@; TIMER0_DATA (direccion de memoria de teoria)
			strh r2, [r1]				@; TIMER0_DATA = divFreq0
				
			add r1, #0x02				@; TIMER0_CR:
			mov r2, #0b01000011			@; 		Prescaler selection 	(1..0)	-->	01	(F/64)
										@; 		Count-up Timing 		(2) 	--> 0 	(timer0 no se puede enlazar)
										@; 		Timer IRQ Enable 		(6)		--> 1 	(activado)
										@; 		Timer Start/Stop		(7)		--> 1 	(activado)
			strh r2, [r1]				
			
		pop {r1-r3, pc}


@;TAREA 2Ec;
@;desactiva_timer0(); rutina para desactivar el timer 0.
	.global desactiva_timer0
desactiva_timer0:
		push {r1-r2, lr}
		ldr r1, =0x04000102			@; TIMER0_CR
		mov r2, #0b01000010					
		strh r2, [r1]				@; Desactivamos el timer
		
		ldr r1, =timer0_on
		mov r2, #0
		strh r2, [r1]				@; Desactivamos variable global timer0_on
		pop {r1-r2, pc}



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
