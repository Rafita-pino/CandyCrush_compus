﻿@;=                                                          	     	=
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
		push {r0-r2, lr}
@;Tareas 2Ea
		ldr r2, =update_spr			
		ldrb r3, [r2]				
		
		cmp r3, #1						@;si update_spr!=1 --> salta la actualizacion
		bne .L_notOne
			ldr r0, =0x07000000			@; cargamos direccion OAM (Sprites_sopos.s)
			mov r1, #128				@; limite de sprites para la funcion
			bl SPR_actualiza_sprites	
			ldr r2, =update_spr
			mov r0, #0					
			strb r0, [r2]				@; finalizamos actualizacion; update_spr=0
		.L_notOne:

@;Tarea 2Ga

		
@;Tarea 2Ha


		pop {r0-r2, pc}





@;TAREA 2Eb;
@;activa_timer0(init); rutina para activar el timer 0, inicializando o no el
@;	divisor de frecuencia según el parámetro init.
@;	Parámetros:
@;		R0 = init; si 1, restablecer divisor de frecuencia original divFreq0
	.global activa_timer0
activa_timer0:
		push {r1-r3, lr}
			cmp r0, #0					@; si init != 0; se copia
			beq .L_NoCopia
				ldr r1, =divFreq0		@; divFreq0 original
				ldrsh r2, [r1]			@; ldrSh --> S para guardar el simbolo
				ldr r1, =divF0			@; divFreq0 act
				strh r2, [r1]			
				
			.L_NoCopia:
			ldr r1, =timer0_on			
			mov r3, #1					@; timer0 en marcha
			strb r3, [r1]			
				
			ldr r1, =0x04000102			@; TIMER0_CR:
			mov r2, #0b11000001			@; 		Prescaler selection 	(1..0)	-->	01	(F/64)
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
		mov r2, #0b01000011					
		strh r2, [r1]				@; Desactivamos el timer
		
		ldr r1, =timer0_on
		mov r2, #0
		strb r2, [r1]				@; Desactivamos variable global timer0_on
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
		push {r0-r6, lr}

		ldr r5, =vect_elem			@; r5 = dir. vector
		ldr r3, =n_sprites
		ldrb r6, [r3]				@; r6 = numero de sprites
		mov r0, #0 					@; r0 = i
		
		.L_vect:
			ldrh r4, [r5, #ELE_II]	
			cmp r4, #0				@; si vect_elem.ii == -1 || 0 salto
			ble .Next_elem
			
			sub  r4, #1
			strh r4, [r5, #ELE_II]	@; vect_elem[i].ii -=1
			
			ldrsh r4, [r5, #ELE_VX]	
			cmp r4, #0				@; si velocidadX = 0, saltamos al vertical (Y)
			beq .Mov_vertical
			
			ldrh r3, [r5, #ELE_PX]
			add r3, r4				@; sumamos el movimiento en x a la posicion en x
			strh r3, [r5, #ELE_PX]
			
			.Mov_vertical:
			ldrsh r4, [r5, #ELE_VY]
			cmp r4, #0				@; si velocidadY = 0; acabamos movimientos
			beq .Fi_mov
			ldrh r3, [r5, #ELE_PY]
			add r3, r4				@; sino, sumamos posicion y velocidad en Y
			strh r3, [r5, #ELE_PY]	
			
			.Fi_mov:
			ldrh r1, [r5, #ELE_PX]	@; cargamos los valores para SPR_mueve_sprite
			ldrh r2, [r5, #ELE_PY]
									@; en r0 ya tenemos el indice del elemento (i)
			bl SPR_mueve_sprite		@; movemos el sprite
			
			ldr r1, =update_spr
			mov r2, #1
			strb r2, [r1]			@; update_spr actiu
			
			ldr r1, =divF0
			ldrsh r2, [r1]
			rsb r2, r2, #0			@; negamos divisor de frecuencia actual
			ldr r4, =1663			@; 523.656 * 0,1/32 = 1636; on 0,1 es el tiempo mas bajo de desplazamiento que aceptaremos, ponemos  1663 por seguridad
			
			cmp r2, r4				@; si divF0 > 1663 restamos y volvemos a negar
			subhi r2, #100			@; si añadimos 30 al divisor de frecuencia, tardara 136 repeticiones en llegar al limite (suficiente)
			rsb r2, r2, #0
			
			strh r2, [r1]			@; actualizamos divF0
			
			.Next_elem:
			add r0, #1				@; i++
			add r5, #ELE_TAM		@; incrementamos la direccion del elem_vect para pasar al siguiente elemento
			cmp r0, r6
			blo .L_vect
		
		ldr r1, =update_spr
		ldrb r2, [r1]
		cmp r2, #0 
		bLeq desactiva_timer0
		

		pop {r0-r6, pc}
.end	