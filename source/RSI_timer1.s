@;=                                                          	     	=
@;=== RSI_timer1.s: rutinas para escalar los elementos (sprites)	  ===
@;=                                                           	    	=
@;=== Programador tarea 2F: xxx.xxx@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.global timer1_on
	timer1_on:	.byte	0 			@;1 -> timer1 en marcha, 0 -> apagado
		.align 1
	divFreq1: .hword	-5727,5			@;divisor de frecuencia para timer 1
	@; Div_Frec = -(Frec_Entrada/ Frec_Salida)
	@; 32 tics en 0.35s --> -(33513982/64)/(32/0.35)= -5727.48716 --> -5727.5

@;-- .bss. variables (globales) no inicializadas ---
.bss
	escSen: .space	1				@;sentido de escalado (0-> dec, 1-> inc)
	escNum: .space	1				@;número de variaciones del factor
		.align 1
	escFac: .space	2				@;factor actual de escalado


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Fb;
@;activa_timer1(init); rutina para activar el timer 1, inicializando el sentido
@;	de escalado según el parámetro init.
@;	Parámetros:
@;		R0 = init;  valor a trasladar a la variable global escSen (0/1)
	.global activa_timer1
activa_timer1:
		push {r1, r2, lr}
		
			ldr r1, =escSen
			strb r0, [r1]			@; escSEN = init
			
			cmp r0, #0
			bne .cicloInc
			
			@; cicloDec
			mov r0, #1
			mov r0, r0, lsl #8		@; 1,0 en coma fixa 0.8.8
			ldr r1, =escFac
			strh r0, [r1]			@; escFac = 1,0
			@; Trasladar factor a PA y PD grupo 0 y llamar SPR_fija_escalado
			mov r1, r0
			mov r2, r0
			mov r0, #0				@; Grup 0
			bl SPR_fija_escalado
			
			.cicloInc:
			mov r0, #0
			ldr r1, =escNum
			strb r0, [r1]			@; Poner escNum a 0
			
			mov r0, #1
			ldr r1, =timer1_on
			strb r0, [r1]			@; Activar timer1_on
			
			ldr r0, =divFreq1
			ldrh r0, [r0]
			orr r0, #0x00C10000		@; Mascara 1100 0001 para activar timer con divFreq1
			ldr r1, =0x04000104		@; Direccion del timer1_control
			str r0, [r1]			@; Guardar el calculo en el timer1
			
		pop {r1, r2, pc}


@;TAREA 2Fc;
@;desactiva_timer1(); rutina para desactivar el timer 1.
	.global desactiva_timer1
desactiva_timer1:
		push {r0, r1, lr}
			
			ldr r0, =0x04000104		@; Direccion del timer1_control
			ldrh r1, [r0]
			bic r1, #0x80			@; Poner bit 7 a 0 (mascara 1000 0000)
			strh r1, [r0]			@; Actualizar el valor
			
			ldr r0, =timer1_on
			mov r1, #0
			strb r1, [r0]			@; Desactivar timer1_on
		
		pop {r0, r1, pc}



@;TAREA 2Fd;
@;rsi_timer1(); rutina de Servicio de Interrupciones del timer 1: incrementa el
@;	número de escalados y, si es inferior a 32, actualiza factor de escalado
@;	actual según el código de la variable global escSen; cuando llega al máximo
@;	desactiva el timer1.
	.global rsi_timer1
rsi_timer1:
		push {r0-r2, lr}
		
			ldr r0, =escNum
			ldrb r1, [r0]
			add r1, #1
			strb r1, [r0] 			@; Incrementar escNum
			cmp r1, #32
			bleq desactiva_timer1	@; Desactivar timer si escNum = 32
			
			ldr r0, = escSen
			ldrb r0, [r0]			@; R0 = escSen
			ldr r1, =escFac
			ldrh r2, [r1]			@; R2 = escFac
			cmp r0, #0
			subeq r2, #2			@; Decrementar escFac si escSen = 0		
			addne r2, #2			@; Incrementar escFac si escSen = 1
			strh r2, [r1]			@; Actualizar escFac
			
			mov r0, #0				@; Grupo 0
			mov r1, r2				@; Parametro escalado
			bl SPR_fija_escalado
			
			ldr r0, =update_spr
			mov r1, #1
			strb r1, [r0]
		
		pop {r0-r2, pc}
		
.end
