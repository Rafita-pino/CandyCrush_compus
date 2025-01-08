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
		push {lr}
		
		pop {pc}


@;TAREA 2Gc;
@;desactiva_timer2(); rutina para desactivar el timer 2.
	.global desactiva_timer2
desactiva_timer2:
		push {lr}
		
	
		pop {pc}



@;TAREA 2Gd;
@;rsi_timer2(); rutina de Servicio de Interrupciones del timer 2: recorre todas
@;	las posiciones de la matriz mat_gel[][] y, en el caso que el código de
@;	activación (ii) sea mayor o igual a 1, decrementa dicho código en una unidad
@;	y, en el caso que alguna llegue a 0, incrementa su código de metabaldosa y
@;	activa una variable global update_gel para que la RSI de VBlank actualice
@;	la visualización de dicha metabaldosa.
	.global rsi_timer2
rsi_timer2:
		push {lr}
	
		pop {pc}



.end
