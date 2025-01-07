@;=                                                        				=
@;=== candy2_conf: variables globales de configuración del juego  	  ===
@;=                                                       	        	=
@;=== Analista-programador: santiago.romani@urv.cat				  	  ===
@;=                                                       	        	=


@;-- .data. variables (globales) inicializadas ---
.data


@; límites de movimientos para cada nivel;
@;	los límites corresponderán a los niveles 0, 1, 2, ..., hasta MAXLEVEL-1
@;								(MAXLEVEL está definida en "include/candy1.h")
@;	cada límite debe ser un número entre 3 y 99.
		.global max_mov
	max_mov:	.byte 20, 27, 11, 25, 24, 8, 21, 30, 25


@; objetivo de puntos para cada nivel;
@;	si el objetivo es cero, se supone que existe otro reto para superar el
@;	nivel, por ejemplo, romper todas las gelatinas.
@;	el objetivo de puntos debe ser un número menor que cero, que se irá
@;	incrementando a medida que se rompan elementos.
		.align 1
		.global pun_obj
	pun_obj:	.hword -1000, -330, -500, 0, -240, -500, -200, -900, 0



@; mapas de configuración de la matriz;
@;	cada mapa debe contener tantos números como posiciones tiene la matriz,
@;	con el siguiente significado para cada posicion:
@;		0:		posición vacía (a rellenar con valor aleatorio)
@;		1-6:	elemento concreto
@;		7:		bloque sólido (irrompible)
@;		8+:		gelatinas simple (a sumarle código de elemento)
@;		16+:	gelatina doble (a sumarle código de elemento)
		.global mapas
	mapas:

	@; mapa 0: todo aleatorio
		.byte 0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0

	@; mapa 1: paredes horizontales y verticales
		.byte 0,0,7,7,0,0,0,0
		.byte 0,0,0,0,0,0,0,0
		.byte 0,7,7,7,7,7,0,0
		.byte 0,7,0,0,0,0,0,0
		.byte 0,7,0,0,0,7,7,7
		.byte 0,7,0,0,0,0,0,0

	@; mapa 2: huecos y bloques sólidos
		.byte 15,15,7,15,0,0,0,0
		.byte 0,15,15,7,15,0,0,0
		.byte 0,0,0,0,0,15,0,0
		.byte 0,0,0,0,0,0,7,7
		.byte 0,0,0,0,2,1,2,15
		.byte 15,0,15,15,1,2,1,1
	
	@; mapa 3: gelatinas simples
		.byte 0,0,0,8,8,8,0,0
		.byte 0,0,0,0,8,0,0,0
		.byte 0,0,8,8,8,8,0,0
		.byte 0,0,8,0,8,0,0,0
		.byte 0,0,8,0,8,0,0,0
		.byte 0,0,8,0,8,0,0,0

	@; mapa 4: gelatinas dobles (+ elementos prefijados)
		.byte 0,15,0,15,0,7,0,15
		.byte 0,0,7,0,0,7,0,0
		.byte 10,3,8,1,1,8,3,3
		.byte 10,1,9,0,0,20,3,4
		.byte 17,2,15,15,3,19,4,3
		.byte 3,2,10,0,0,20,0,15

	@; mapa 5: secuencias en horizontal de 3, 4 y 5 elementos
		.byte 1,1,1,15,2,2,2,2
		.byte 3,3,3,3,3,15,7,7
		.byte 4,1,4,4,4,4,15,7
		.byte 1,4,4,2,6,3,7,0
		.byte 5,2,2,15,5,5,5,5
		.byte 6,5,5,2,5,6,6,6

	@; mapa 6: secuencias en vertical de 3, 4 y 5 elementos
		.byte 1,3,4,1,5,6,2,15
		.byte 1,3,1,4,2,5,7,15
		.byte 1,3,4,4,2,5,15,7
		.byte 2,3,4,2,6,15,2,7
		.byte 2,3,4,15,6,6,5,7
		.byte 2,7,4,3,5,15,6,7

	@; mapa 7: combinaciones cruzadas (hor/ver) de 5, 6 y 7 elementos
		.byte 1,2,3,3,4,3,7,0
		.byte 1,2,7,5,3,7,7,0
		.byte 4,1,1,2,3,16,7,0
		.byte 1,4,4,2,6,3,7,0
		.byte 4,2,2,5,2,2,7,0
		.byte 4,5,5,2,5,5,7,0
		
	@; mapa 8: no hay combinaciones ni secuencias
		.byte 1,2,3,3,7,3,15,15
		.byte 1,2,7,5,3,7,15,15
		.byte 7,1,1,2,3,9,15,15
		.byte 1,4,20,10,9,6,15,15
		.byte 6,18,22,5,6,2,15,15
		.byte 12,5,4,3,11,5,15,15
	
	@; mapa 9: mapa amb tot de gelatines de diferent tipus (simples o dobles)
		.byte 9, 10, 17, 22, 9, 12, 11, 18
		.byte 18, 20, 11, 17, 14, 9, 10, 19
		.byte 19, 13, 12, 9, 18, 20, 17, 9
		.byte 10, 22, 11, 18, 12, 13, 9, 10
		.byte 17, 19, 20, 22, 11, 14, 17, 10
		.byte 18, 13, 10, 9, 12, 14, 19, 17

	@; mapa 10: mapa amb nomès baldoses transparents de tipus 16..19
		.byte 6, 15, 1, 15, 2, 15, 4, 15
		.byte 15, 4, 15, 3, 15, 1, 15, 2
		.byte 6, 15, 6, 15, 6, 15, 6, 15
		.byte 15, 1, 15, 1, 15, 1, 15, 1
		.byte 2, 15, 3, 15, 4, 15, 6, 15
		.byte 15, 3, 15, 6, 15, 2, 15, 6

	@; mapa 11: mapa amb nomès gelatines simples (baldoses 0..7)
		.byte 8, 9, 10, 11, 12, 13, 14, 8
		.byte 9, 10, 11, 12, 13, 14, 8, 9
		.byte 10, 11, 12, 13, 14, 8, 9, 10
		.byte 11, 12, 13, 14, 8, 9, 10, 11
		.byte 12, 13, 14, 8, 9, 10, 11, 12
		.byte 13, 14, 8, 9, 10, 11, 12, 13

	@; mapa 12: mapa amb nomès gelatines dobles (baldoses 8..15)
		.byte 16, 17, 18, 19, 20, 21, 22, 16
		.byte 17, 18, 19, 20, 21, 22, 16, 17
		.byte 18, 19, 20, 21, 22, 16, 17, 18
		.byte 19, 20, 21, 22, 16, 17, 18, 19
		.byte 20, 21, 22, 16, 17, 18, 19, 20
		.byte 21, 22, 16, 17, 18, 19, 20, 21

	@; mapa 13: mapa amb tot ple de baldoses de diferent tipus (0..19)
	    .byte 0, 1, 2, 3, 4, 5, 6, 7
		.byte 8, 9, 10, 11, 12, 13, 14, 15
		.byte 16, 17, 18, 19, 20, 21, 22, 0
		.byte 1, 2, 3, 4, 5, 6, 7, 8
		.byte 9, 10, 11, 12, 13, 14, 15, 16
		.byte 17, 18, 19, 20, 21, 22, 0, 1

	

	@; etc.



.end
	
