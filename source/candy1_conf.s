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
<<<<<<< HEAD
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


=======
	@; mapa 0: sin secuencias
		.byte 1, 3, 5, 2, 4, 6, 1, 2, 3
		.byte 4, 6, 1, 5, 3, 2, 4, 6, 1
		.byte 3, 2, 6, 1, 4, 5, 3, 1, 2
		.byte 5, 4, 2, 6, 3, 1, 2, 4, 6
		.byte 1, 6, 3, 5, 2, 4, 1, 3, 5
		.byte 6, 2, 4, 3, 1, 5, 6, 3, 4
		.byte 2, 1, 6, 4, 3, 5, 2, 1, 6
		.byte 3, 4, 5, 1, 6, 2, 3, 5, 1
		.byte 5, 3, 2, 6, 4, 1, 5, 2, 3

	@; mapa 1: con secuencias horizontales (facilmente visibles)
		.byte 3, 3, 3, 7, 7, 7, 7, 7, 7
		.byte 7, 7, 7, 12, 12, 12, 7, 7, 7
		.byte 7, 7, 7, 7, 7, 7, 20, 20, 20
		.byte 7, 7, 7, 7, 7, 7, 7, 7, 7
		.byte 7, 7, 7, 7, 7, 7, 7, 7, 7
		.byte 7, 7, 7, 7, 7, 7, 7, 7, 7
		.byte 7, 7, 7, 7, 7, 7, 7, 7, 7
		.byte 7, 7, 7, 7, 7, 7, 7, 7, 7
		.byte 7, 7, 7, 7, 7, 7, 7, 7, 7

	@; mapa 2: con secuencias verticales (facilmente visibles)
		.byte 5, 0, 0, 0, 0, 0, 0, 0, 0
		.byte 5, 0, 0, 0, 0, 0, 0, 0, 0
		.byte 5, 0, 0, 0, 0, 0, 0, 0, 0
		.byte 0, 13, 0, 0, 0, 0, 0, 0, 0
		.byte 0, 13, 0, 0, 0, 0, 0, 0, 0
		.byte 0, 13, 0, 0, 0, 0, 0, 0, 0
		.byte 0, 0, 21, 0, 0, 0, 0, 0, 0
		.byte 0, 0, 21, 0, 0, 0, 0, 0, 0
		.byte 0, 0, 21, 0, 0, 0, 0, 0, 0
		
	@; mapa 3: con secuencias verticales y horizontales sin cruce (facilmente visibles)
		.byte 7, 7, 7, 0, 0, 0, 0, 0, 0
		.byte 0, 0, 0, 8, 8, 8, 0, 0, 0
		.byte 0, 0, 0, 0, 0, 0, 9, 9, 9
		.byte 10, 0, 0, 0, 0, 0, 0, 0, 0
		.byte 10, 0, 0, 0, 0, 0, 0, 0, 0
		.byte 10, 0, 0, 0, 0, 0, 0, 0, 0
		.byte 0, 0, 11, 0, 0, 0, 0, 0, 0
		.byte 0, 0, 11, 0, 0, 0, 0, 0, 0
		.byte 0, 0, 11, 0, 0, 0, 0, 0, 0
		
	@; mapa 4: con secuencias verticales con cruce de diferentes numeros (facilmente visibles)
>>>>>>> prog2
	
		.byte 12, 12, 12, 0, 0, 0, 0, 0, 0
		.byte 0, 0, 0, 13, 13, 13, 0, 0, 0
		.byte 14, 0, 0, 0, 0, 0, 0, 0, 0
		.byte 14, 0, 0, 15, 15, 15, 0, 0, 0
		.byte 14, 0, 0, 0, 0, 0, 0, 0, 0
		.byte 0, 16, 0, 0, 0, 0, 0, 0, 0
		.byte 0, 16, 0, 0, 0, 0, 0, 0, 0
		.byte 0, 16, 17, 17, 17, 0, 0, 0, 0
		.byte 0, 0, 0, 0, 0, 0, 0, 0, 0

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

	@; mapa 9: secuencias en horizontal de 3, 4 y 5 elementos
		.byte 1,1,1,15,2,2,2,2,7
		.byte 3,3,3,3,3,15,7,7,15
		.byte 4,1,4,4,4,4,15,7,15
		.byte 1,4,4,2,6,3,7,0,15
		.byte 5,2,2,15,5,5,5,5,5
		.byte 6,5,5,2,5,6,6,6,15
		.byte 15,7,6,6,6,7,7,7,7
		.byte 7,7,7,15,7,7,7,15,15
		.byte 15,15,7,15,15,15,7,15,15

	@; mapa 10: secuencias en vertical de 3, 4 y 5 elementos
		.byte 1,3,4,1,5,6,2,15,15
		.byte 1,3,1,4,2,5,7,15,15
		.byte 1,3,4,4,2,5,15,7,15
		.byte 2,3,4,2,6,15,2,7,15
		.byte 2,3,4,15,6,6,5,7,15
		.byte 2,7,4,3,5,15,6,7,15
		.byte 2,7,15,6,6,5,6,7,7
		.byte 7,15,15,7,7,5,6,7,15
		.byte 15,15,7,15,15,5,7,15,15

	@; mapa 11: combinaciones cruzadas (hor/ver) de 5, 6 y 7 elementos
		.byte 15,15,7,15,15,7,15,15,15
		.byte 1,2,3,3,4,3,7,0,15
		.byte 1,2,7,5,3,7,7,0,15
		.byte 4,1,1,2,3,8,7,0,15
		.byte 1,4,4,2,6,3,7,0,15
		.byte 4,2,2,5,2,2,7,0,15
		.byte 4,5,5,2,5,5,7,0,15
		.byte 7,8,1,5,4,6,8,0,15
		.byte 8,8,8,8,8,8,8,0,15
		
	@; mapa 12: no hay combinaciones ni secuencias
		.byte 15,15,15,15,15,15,15,15,15
		.byte 15,15,15,15,15,15,15,15,15
		.byte 1,2,3,3,7,3,15,15,15
		.byte 1,2,7,5,3,7,15,15,15
		.byte 7,1,1,2,3,9,15,15,15
		.byte 1,4,20,10,9,6,15,15,15
		.byte 6,18,22,5,6,2,15,15,15
		.byte 12,5,4,3,11,5,15,15,15
		.byte 7,7,17,19,4,6,15,15,15

<<<<<<< HEAD
	@; mapa 9 anterior1: paredes horizontales y verticales
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,7,7,7,7,7,0,0,0
		.byte 0,7,0,0,0,0,0,0,0
		.byte 0,7,0,0,0,7,7,7,7
		.byte 0,7,0,0,0,0,0,0,7
		.byte 0,0,0,0,0,0,0,0,7
		.byte 0,0,7,7,7,7,0,0,7
		.byte 0,0,0,0,0,0,0,0,7
	@; mapa 10 anterior1: paredes horizontales y verticales
		.byte 0,1,2,3,4,5,9,7,8
		.byte 9,10,11,12,13,14,15,16,17
		.byte 18,19,20,21,22,0,1,2,3
		.byte 4,5,6,7,8,9,10,11,12
		.byte 13,12,13,14,15,16,17,18,19
		.byte 20,21,22,0,1,2,3,4,5
		.byte 6,7,8,9,10,11,12,13,14
		.byte 15,16,17,18,19,20,21,22,0
		.byte 1,2,3,4,5,6,7,8,9
		

=======
>>>>>>> prog2
	@; etc.



.end
	
