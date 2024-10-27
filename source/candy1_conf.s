@;=                                                        				=
@;=== candy1_conf.s: variables globales de configuración del juego    ===
@;=                                                       	        	=
@;=== Analista-programador: santiago.romani@urv.cat				  	  ===
@;=                                                       	        	=


@;-- .data. variables (globales) inicializadas ---
.data


@; límites de movimientos para cada nivel;
@;	los límites corresponderán a los niveles 0, 1, 2, ..., hasta MAXLEVEL-1
@;						(MAXLEVEL está definida en 'include/candy1_incl.h')
@;	cada límite debe ser un número entre 3 y 99.
		.global max_mov
	max_mov:	.byte 100, 20, 27, 31, 45, 52, 32, 21, 90, 50, 20 


@; objetivo de puntos para cada nivel;
@;	si el objetivo es cero, se supone que existe otro reto para superar el
@;	nivel, por ejemplo, romper todas las gelatinas.
@;	el objetivo de puntos debe ser un número menor que cero, que se irá
@;	incrementando a medida que se rompan elementos.
		.align 1
		.global pun_obj
	pun_obj:	.hword 0, -1000, -830, -500, 0, -240, -500, -200, -900, 0, 0



@; mapas de configuración de la matriz;
@;	cada mapa debe contener tantos números como posiciones tiene la matriz,
@;	con el siguiente significado para cada posicion:
@;		0:		posición vacía (a rellenar con valor aleatorio)
@;		1-6:	elemento concreto
@;		7:		bloque sólido (irrompible)
@;		8+:		gelatina simple (a sumarle código de elemento)
@;		16+:	gelatina doble (a sumarle código de elemento)
		.global mapas
	mapas:
	@; mapa 0: probar recomb x2
		.byte 8,16,8,16,8,16,8,16,8
		.byte 8,16,8,16,8,16,8,16,8
		.byte 8,16,8,16,8,16,8,16,8
		.byte 8,16,8,16,8,16,8,16,8
		.byte 8,16,8,16,8,16,8,16,8
		.byte 8,16,8,16,8,16,8,16,8
		.byte 8,16,8,16,8,16,8,16,8
		.byte 8,16,8,16,8,16,8,16,8
		.byte 8,16,8,16,8,16,8,16,8
		
	@; mapa 1: todo aleatorio
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0

	@; mapa 2: probar recomb
		.byte 15,15,15,15,15,15,15,15,15
		.byte 15,15,15,15,15,15,15,15,15
		.byte 15,15,15,15,15,15,15,15,15
		.byte 15,15,15,15,15,15,15,15,15
		.byte 15,15,15,15,15,15,15,15,15
		.byte 15,15,15,15,15,15,15,15,15
		.byte 15,15,15,15,15,15,15,15,15
		.byte 8,9,15,15,15,15,15,15,15
		.byte 20,22,15,15,15,15,15,15,15

	@; mapa 5: con secuencias verticales con cruce de mismos numeros (facilmente visibles)
		.byte 18, 18, 18, 0, 0, 0, 0, 0, 0
		.byte 0, 0, 0, 18, 18, 18, 0, 0, 0
		.byte 18, 0, 0, 18, 0, 0, 0, 0, 0
		.byte 18, 0, 0, 18, 18, 18, 0, 0, 0
		.byte 18, 0, 0, 0, 0, 0, 0, 0, 0
		.byte 0, 18, 0, 0, 0, 0, 0, 0, 0
		.byte 0, 18, 0, 0, 0, 0, 0, 0, 0
		.byte 0, 18, 18, 18, 0, 0, 0, 0, 0
		.byte 0, 0, 0, 0, 0, 0, 0, 0, 0

	@; mapa 6: con bloques sólidos y huecos
		.byte 1, 7, 1, 2, 4, 7, 1, 15, 6
		.byte 2, 15, 3, 3, 15, 6, 4, 5, 7
		.byte 6, 7, 7, 1, 15, 1, 3, 2, 4
		.byte 15, 1, 1, 4, 3, 15, 6, 1, 3
		.byte 7, 6, 3, 5, 7, 4, 6, 7, 15
		.byte 15, 2, 1, 3, 3, 3, 2, 15, 4
		.byte 4, 3, 7, 6, 5, 7, 4, 3, 15
		.byte 5, 15, 5, 1, 15, 6, 3, 1, 4
		.byte 6, 7, 2, 1, 6, 5, 15, 7, 6

	
	@; mapa 7: con gelatinas simples y dobles
		.byte 9, 10, 11, 2, 17, 18, 1, 3, 6
		.byte 2, 4, 3, 14, 14, 6, 4, 5, 19
		.byte 6, 5, 6, 11, 1, 1, 3, 2, 4
		.byte 12, 1, 1, 4, 3, 5, 6, 20, 3
		.byte 2, 6, 3, 18, 2, 4, 6, 21, 6
		.byte 3, 22, 1, 3, 13, 3, 2, 5, 4
		.byte 4, 3, 4, 17, 5, 2, 4, 3, 1
		.byte 5, 19, 5, 1, 2, 6, 3, 1, 4
		.byte 6, 4, 2, 1, 22, 5, 6, 6, 6


	@; mapa 8: secuencias en los límites
		.byte 1, 2, 3, 4, 5, 6, 1, 1, 1
		.byte 4, 5, 6, 1, 2, 3, 6, 6, 6
		.byte 3, 2, 1, 4, 5, 6, 4, 4, 4
		.byte 6, 5, 4, 3, 2, 1, 3, 2, 2
		.byte 1, 3, 4, 5, 6, 1, 2, 3, 3
		.byte 5, 6, 1, 2, 3, 4, 5, 6, 1
		.byte 4, 5, 2, 1, 3, 6, 2, 2, 2
		.byte 6, 3, 4, 1, 5, 1, 6, 3, 1
		.byte 3, 2, 1, 6, 6, 6, 5, 4, 3

	@; mapa 9: el d'exemple del enunciat per a baja_laterales -> MODIFICAT PER COMPROVAR COMPTATGE GELATINES
		.byte 15,3,4,7,2,7,7,7,7
		.byte 12,2,15,15,3,0,7,7,7
		.byte 7,7,15,8,12,9,7,7,7
		.byte 0,5,5,6,3,4,7,7,7
		.byte 3,2,18,1,4,9,7,7,7
		.byte 7,7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7,7
	
	@; mapa 10: Oportunitats per a diagonals (amb i sense forats)
		.byte 3,15,4,0,7,2,1,7,7
		.byte 5,6,15,15,0,4,0,7,7
		.byte 7,2,18,8,12,9,7,7,7
		.byte 0,5,5,6,3,0,7,7,7
		.byte 2,3,18,1,4,9,7,7,7
		.byte 7,7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7,7
	
	@; mapa 11: Combinacions diagonals en les bandes
		.byte 15,3,4,7,2,7,7,7,0
		.byte 12,0,15,15,3,0,0,0,4
		.byte 7,7,15,0,12,9,0,0,0
		.byte 0,5,5,6,0,4,0,0,0
		.byte 2,3,0,1,4,0,7,7,7
		.byte 7,7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7,7
	
	@; mapa 12: Elements en el centre (no pot generar cap nou baja_verticales)
		.byte 7,7,7,7,7,7,7,7,7
		.byte 7,0,5,3,1,2,4,0,7
		.byte 7,0,6,15,8,12,9,0,7
		.byte 7,0,5,5,6,3,4,0,7
		.byte 7,0,2,3,18,1,4,0,7
		.byte 7,7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7,7
	
	@; mapa 13: Aleatori
		.byte 15,15,15,7,7,7,7,7,7
		.byte 0,0,15,15,15,0,0,0,0
		.byte 0,0,15,15,15,9,0,0,0
		.byte 0,5,5,6,3,4,0,0,0
		.byte 2,3,0,1,4,9,0,0,0
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0
	
	@; mapa 14: Ruta diagonal (per a provar baja_laterales en un sol sentit)
		.byte 15,7,7,7,7,7,7,7,0
		.byte 7,15,7,7,7,7,7,0,7
		.byte 7,7,15,7,7,7,0,7,7
		.byte 7,7,7,15,7,0,7,7,7
		.byte 7,7,7,7,0,7,7,7,7
		.byte 7,7,7,0,7,7,7,7,7
		.byte 7,7,0,7,7,7,7,7,7
		.byte 7,0,7,7,7,7,7,7,7
		.byte 0,7,7,7,7,7,7,7,7
	@; etc.

.end
