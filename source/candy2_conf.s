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
	max_mov:	.byte 99, 99, 99, 99, 99, 99, 99, 99, 99, 99


@; objetivo de puntos para cada nivel;
@;	si el objetivo es cero, se supone que existe otro reto para superar el
@;	nivel, por ejemplo, romper todas las gelatinas.
@;	el objetivo de puntos debe ser un número menor que cero, que se irá
@;	incrementando a medida que se rompan elementos.
		.align 1
		.global pun_obj
	pun_obj:	.hword -1000, -1000, -1000, -1000, -1000,-1000, -1000, -1000, -1000, -1000



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
@; Mapa 0 - Sin combinaciones iniciales, contiene huecos, gelatinas y bloques sólidos. 
		.byte 1, 2, 3, 4, 13, 6, 1, 2
        .byte 2, 3, 20, 5, 6, 1, 2, 3
        .byte 3, 4, 5, 6, 1, 2, 3, 4
        .byte 4, 5, 6, 1, 18, 3, 4, 5
        .byte 5, 14, 1, 2, 3, 4, 5, 6
        .byte 6, 1, 2, 3, 4, 5, 6, 1



@; Mapa 1 - Contiene gelatinas simples y dobles, huecos y bloques sólidos. Sin combinaciones iniciales. 
		.byte 2, 19, 5, 15, 6, 9, 7, 3
		.byte 4, 15, 7, 4, 11, 5, 3, 1
		.byte 21, 14, 6, 15, 3, 7, 1, 6
		.byte 15, 3, 5, 18, 4, 15, 7, 2
		.byte 6, 4, 10, 15, 17, 6, 5, 7
		.byte 7, 15, 3, 1, 15, 14, 3, 15


@; Mapa 2 - Incluye gelatinas dobles y huecos. Sin combinaciones iniciales. 
        .byte 15, 6, 18, 3, 15, 6, 20, 5
        .byte 2, 15, 7, 5, 4, 19, 2, 6
        .byte 12, 7, 15, 6, 5, 7, 15, 4
        .byte 5, 3, 15, 9, 7, 15, 6, 15
        .byte 7, 6, 17, 4, 13, 15, 3, 6
        .byte 4, 5, 15, 6, 2, 7, 10, 15

@; Mapa 3 - Contiene huecos, bloques sólidos y gelatinas sin combinaciones iniciales.
        .byte 7, 4, 5, 15, 13, 15, 6, 3
        .byte 15, 3, 19, 6, 7, 15, 5, 4
        .byte 6, 14, 15, 7, 3, 6, 5, 15
        .byte 4, 7, 9, 6, 15, 1, 22, 7
        .byte 15, 6, 7, 22, 12, 4, 15, 6
        .byte 7, 4, 15, 3, 1, 18, 11, 15

@; Mapa 4 - Huecos, gelatinas dobles y bloques sólidos. No hay combinaciones iniciales. 
        .byte 5, 18, 7, 15, 6, 15, 17, 4
        .byte 7, 3, 15, 5, 11, 21, 15, 6
        .byte 4, 6, 21, 7, 15, 9, 3, 5
        .byte 7, 15, 4, 22, 6, 7, 15, 3
        .byte 15, 12, 7, 15, 19, 4, 7, 6
        .byte 3, 7, 15, 6, 14, 5, 15, 4

@; Mapa 5 - Huecos, bloques sólidos y gelatinas dobles distribuidos. Sin combinaciones iniciales. 
        .byte 15, 13, 17, 15, 4, 5, 7, 6
        .byte 22, 15, 6, 4, 15, 20, 3, 7
        .byte 5, 7, 15, 3, 18, 15, 12, 6
        .byte 3, 9, 15, 21, 7, 4, 15, 5
        .byte 15, 5, 11, 6, 15, 22, 7, 15
        .byte 4, 3, 7, 15, 14, 6, 15, 5
