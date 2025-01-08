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

	@; mapa 0: casillas vacias
		.byte 0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0
		
	@; mapa 1: bloques solidos
		.byte 7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7

	@; mapa 2: huecos
		.byte 15,15,15,15,15,15,15,15
		.byte 15,15,15,15,15,15,15,15
		.byte 15,15,15,15,15,15,15,15
		.byte 15,15,15,15,15,15,15,15
		.byte 15,15,15,15,15,15,15,15
		.byte 15,15,15,15,15,15,15,15
		
	@; mapa 3: elems sin gel
		.byte 1,1,1,1,1,1,1,1
		.byte 2,2,2,2,2,2,2,2
		.byte 3,3,3,3,3,3,3,3
		.byte 4,4,4,4,4,4,4,4
		.byte 5,5,5,5,5,5,5,5
		.byte 6,6,6,6,6,6,6,6

	@; mapa 4: elems con gel s
		.byte 9,9,9,9,9,9,9,9
		.byte 10,10,10,10,10,10,10,10
		.byte 11,11,11,11,11,11,11,11
		.byte 12,12,12,12,12,12,12,12
		.byte 13,13,13,13,13,13,13,13
		.byte 14,14,14,14,14,14,14,14
	
	@; mapa 5: elems con gel d
		.byte 17,17,17,17,17,17,17,17
		.byte 18,18,18,18,18,18,18,18
		.byte 19,19,19,19,19,19,19,19
		.byte 20,20,20,20,20,20,20,20
		.byte 21,21,21,21,21,21,21,21
		.byte 22,22,22,22,22,22,22,22
		
	@; mapa 6: huecos con elems
		.byte 1,1,1,1,1,1,1,1
		.byte 2,15,15,15,15,15,15,2
		.byte 3,15,15,1,1,15,15,3
		.byte 4,15,15,1,1,15,15,4
		.byte 5,15,15,15,15,15,15,5
		.byte 6,6,6,6,6,6,6,6
		
	@; mapa 7: prueba timer1
		.byte 0,0,0,0,0,0,0,0
		.byte 0,1,0,0,12,0,0,19
		.byte 0,1,0,0,12,0,0,19
		.byte 0,1,0,12,0,0,19,0
		.byte 0,1,0,0,12,0,0,19
		.byte 0,0,0,0,0,0,0,0
		
	@; etc.



.end
	
