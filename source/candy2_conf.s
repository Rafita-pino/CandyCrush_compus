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
	@; Mapa 0 - Contiene elementos distribuidos aleatoriamente sin combinaciones iniciales. 
@;         Los movimientos pueden crear combinaciones de 3 o más elementos iguales.
        .byte 1, 2, 3, 4, 5, 6, 1, 2
        .byte 2, 3, 4, 5, 6, 1, 2, 3
        .byte 3, 4, 5, 6, 1, 2, 3, 4
        .byte 4, 5, 6, 1, 2, 3, 4, 5
        .byte 5, 6, 1, 2, 3, 4, 5, 6
        .byte 6, 1, 2, 3, 4, 5, 6, 1

@; Mapa 1 - Contiene una disposición similar a la anterior, sin combinaciones iniciales. 
@;         Al mover los elementos, se podrán formar combinaciones.
        .byte 3, 4, 5, 6, 1, 2, 3, 4
        .byte 5, 6, 1, 2, 3, 4, 5, 6
        .byte 2, 3, 4, 5, 6, 1, 2, 3
        .byte 4, 5, 6, 1, 2, 3, 4, 5
        .byte 6, 1, 2, 3, 4, 5, 6, 1
        .byte 3, 4, 5, 6, 1, 2, 3, 4

@; Mapa 2 - El mapa sigue la misma lógica que los anteriores, sin combinaciones iniciales. 
@;         Puede generar combinaciones con intercambios.
        .byte 1, 2, 3, 4, 5, 6, 1, 2
        .byte 3, 4, 5, 6, 1, 2, 3, 4
        .byte 5, 6, 1, 2, 3, 4, 5, 6
        .byte 2, 3, 4, 5, 6, 1, 2, 3
        .byte 4, 5, 6, 1, 2, 3, 4, 5
        .byte 6, 1, 2, 3, 4, 5, 6, 1

@; Mapa 3 - Disposición sin combinaciones iniciales, pero con potencial para formarlas.
        .byte 2, 3, 4, 5, 6, 1, 2, 3
        .byte 4, 5, 6, 1, 2, 3, 4, 5
        .byte 6, 1, 2, 3, 4, 5, 6, 1
        .byte 3, 4, 5, 6, 1, 2, 3, 4
        .byte 5, 6, 1, 2, 3, 4, 5, 6
        .byte 2, 3, 4, 5, 6, 1, 2, 3

@; Mapa 4 - Elementos dispuestos de manera que no hay combinaciones al principio.
@;         Se permiten combinaciones con movimientos.
        .byte 4, 5, 6, 1, 2, 3, 4, 5
        .byte 6, 1, 2, 3, 4, 5, 6, 1
        .byte 2, 3, 4, 5, 6, 1, 2, 3
        .byte 5, 6, 1, 2, 3, 4, 5, 6
        .byte 3, 4, 5, 6, 1, 2, 3, 4
        .byte 6, 1, 2, 3, 4, 5, 6, 1

@; Mapa 5 - No tiene combinaciones iniciales. Al hacer movimientos, se pueden formar.
        .byte 5, 6, 1, 2, 3, 4, 5, 6
        .byte 1, 2, 3, 4, 5, 6, 1, 2
        .byte 4, 5, 6, 1, 2, 3, 4, 5
        .byte 6, 1, 2, 3, 4, 5, 6, 1
        .byte 2, 3, 4, 5, 6, 1, 2, 3
        .byte 5, 6, 1, 2, 3, 4, 5, 6

@; Mapa 6 - Contiene una estructura similar a la anterior, sin combinaciones al inicio.
        .byte 3, 4, 5, 6, 1, 2, 3, 4
        .byte 5, 6, 1, 2, 3, 4, 5, 6
        .byte 2, 3, 4, 5, 6, 1, 2, 3
        .byte 4, 5, 6, 1, 2, 3, 4, 5
        .byte 6, 1, 2, 3, 4, 5, 6, 1
        .byte 3, 4, 5, 6, 1, 2, 3, 4

@; Mapa 7 - Sin combinaciones iniciales, pero con las posibilidades de generarlas por movimientos.
        .byte 6, 1, 2, 3, 4, 5, 6, 1
        .byte 3, 4, 5, 6, 1, 2, 3, 4
        .byte 5, 6, 1, 2, 3, 4, 5, 6
        .byte 2, 3, 4, 5, 6, 1, 2, 3
        .byte 4, 5, 6, 1, 2, 3, 4, 5
        .byte 6, 1, 2, 3, 4, 5, 6, 1

@; Mapa 8 - Sin combinaciones iniciales, pero con las posibilidades de generarlas.
        .byte 3, 4, 5, 6, 1, 2, 3, 4
        .byte 5, 6, 1, 2, 3, 4, 5, 6
        .byte 2, 3, 4, 5, 6, 1, 2, 3
        .byte 4, 5, 6, 1, 2, 3, 4, 5
        .byte 6, 1, 2, 3, 4, 5, 6, 1
        .byte 3, 4, 5, 6, 1, 2, 3, 4





.end
	
