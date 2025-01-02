@;=                                                               		=
@;== candy2_supo.s: rutinas de soporte a la práctia CandyNDS (fase 2) ===
@;=                                                         			=
@;=== Analista-programador: santiago.romani@urv.cat			 		  ===
@;=                                                         	      	=

.include "candy2_incl.i"


@;-- .text. Program code ---
.text	
		.align 2
		.arm


@;busca_elemento(unsigned char fil, unsigned char col);
@;	busca un elemento dentro del vector de elementos, a partir de las
@;	coordenadas de fila y columna del elemento, que se tienen que contrastar
@;	con las coordenadas (px,py) de cada sprite;
@;	devuelve el índice del elemento, o ROWS*COLUMNS si no lo ha encontrado.
@;	Parámetros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
@;	Resultado:
@;		R0 :	índice del elemento encontrado, o ROWS*COLUMNS 
	.global busca_elemento
busca_elemento:
		push {r2-r6, lr}
		
		ldr r6, =n_sprites
		ldr r6, [r6]			@;R6 = número de sprites creados
		mov r2, r1, lsl #5		@;R2 = px (columna * 32)
		mov r3, r0, lsl #5		@;R3 = py (fila * 32)
		mov r0, #0				@;R0 es índice de elementos
		ldr r4, =vect_elem		@;R4 es dirección base del vector elementos
	.Lbe_bucle:
		ldsh r5, [r4, #ELE_II]
		cmp r5, #-1
		beq .Lbe_cont			@;continua si vect_elem[i].ii == -1
		ldsh r5, [r4, #ELE_PX]
		cmp r5, r2
		bne .Lbe_cont			@;continua si vect_elem[i].px != posición px
		ldsh r5, [r4, #ELE_PY]
		cmp r5, r3
		beq .Lbe_finbucle		@;salir si vect_elem[i].py == posición py
		
	.Lbe_cont:
		add r4, #ELE_TAM
		add r0, #1				@;repetir para todos los sprites creados
		cmp r0, r6
		blo .Lbe_bucle
		mov r0, #ROWS*COLUMNS	@;código de no encontrado (>= n_sprites)
		
	.Lbe_finbucle:
		
		pop {r2-r6, pc}
	
	
@;crea_elemento(unsigned char tipo, unsigned char fil, unsigned char col,
@;															unsigned char prio);
@;	crea un nuevo elemento de juego, buscando un sprite libre (ii = -1) y
@;	le asigna el índice de baldosa correspondiente al tipo de elemento que
@;	se pasa por parámetro, además de la posición inicial según la fila y
@;	columna en la matriz de juego;
@;	devuelve como resultado el índice del sprite/elemento que se ha reservado,
@;	o bien el total de posiciones del tablero de juego (ROWS*COLUMNS)
@;	si no ha encontrado ninguno libre.
@;	Parámetros:
@;		R0 :	tipo de elemento
@;		R1 :	fila del elemento
@;		R2 :	columna del elemento
@;		R3 :	prioridad del elemento
@;	Resultado:
@;		R0 :	índice del elemento encontrado, o ROWS*COLUMNS 
	.global crea_elemento
crea_elemento:
		push {r1-r5,lr}
		
		mov r3, r0					@;R3 = tipo de elemento
	@;	int i = 0;
		mov r0, #0					@;R0 es Ã­ndice de elementos (i)
		
	@;	while ((vect_elem[i].ii != -1) && (i < ROWS*COLUMNS))
	@;		i++;
		ldr r4, =vect_elem			@;R4 es direcciÃ³n base del vector elementos
	.Lce_bucle:
		ldsh r5, [r4, #ELE_II]
		cmp r5, #-1
		beq .Lce_finbucle			@;salir si vect_elem[i].ii == -1
		add r4, #ELE_TAM
		add r0, #1
		cmp r0, #ROWS*COLUMNS
		blo .Lce_bucle				@;repetir para todos los sprites posibles
		b .Lce_fin
	.Lce_finbucle:
	@;	if (i < ROWS*COLUMNS)		// si lo ha encontrado
	@;	{							// inicializar sus campos principales
		mov r5, #0
		strh r5, [r4, #ELE_II]		@;vect_elem[i].ii = 0;
		mov r5, r2, lsl #5
		strh r5, [r4, #ELE_PX]		@;vect_elem[i].px = col*MTWIDTH;
		mov r5, r1, lsl #5
		strh r5, [r4, #ELE_PY]		@;vect_elem[i].py = fil*MTHEIGHT;
		
	@;		SPR_crea_Sprite(i, 0, 2, 'indice metabaldosa');
		sub r1, r3, #1
		mov r2, #MTOTAL
		mul r3, r1, r2				@;indice metabaldosa = (tipo-1)*MTOTAL
		mov r1, #0
		mov r2, #2
		bl SPR_crea_sprite
	@;		SPR_ueve_sprite(i, vect_elem[i].px, vect_elem[i].py);
		ldsh r5, [r4, #ELE_PX]
		mov r1, r5
		ldsh r5, [r4, #ELE_PY]
		mov r2, r5
		bl SPR_mueve_sprite
	@;		SPR_fija_Prioridad(i, 1);
		mov r1, #1
		bl SPR_fija_prioridad
	@;		SPR_muestra_Sprite(i);
		bl SPR_muestra_sprite
	@;	}
	.Lce_fin:
		pop {r1-r5, pc}



@;elimina_elemento(unsigned char fil, unsigned char col);
@;	elimina un elemento de juego, a partir de sus coordenadas fila y columna
@;	actuales; si se encuentra dicho elemento, se libera la posición del vector
@;	y se oculta el sprite asociado;
@;	devuelve el índice del elemento eliminado, o bien el total de posiciones
@;	del tablero de juego (ROWS*COLUMNS) si no lo ha encontrado.
@;	Parámetros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
@;	Resultado:
@;		R0 :	índice del elemento encontrado, o ROWS*COLUMNS
	.global elimina_elemento
elimina_elemento:
		push {r1, r3-r4, lr}
		
	@;	unsigned char i = busca_elemento(fil, col);
		bl busca_elemento
		
	@;	if (i < ROWS*COLUMNS)			// si lo ha encontrado
		cmp r0, #ROWS*COLUMNS
		beq .Lee_fin
	@;	{
	@;		vect_elem[i].ii = -1;		// libera la entrada en el vector
		ldr r4, =vect_elem
		mov r3, #ELE_TAM
		mla r4, r0, r3, r4				@;R4 = @vect_elem + i * TAMELEM;
		mov r1, #-1
		strh r1, [r4, #ELE_II]
	@;		SPR_oculta_sprite(i);		// oculta el sprite asociado
		bl SPR_oculta_sprite
	@;	}
	.Lee_fin:
		pop {r1, r3-r4, pc}



@;activa_elemento(unsigned char fil, unsigned char col,
@;											unsigned char f2, unsigned char c2);
@;	activa la animación del movimiento de un elemento/sprite a partir
@;	de sus coordenadas fila y columna actuales, así como la posición
@;	del tablero donde se tiene que mover dicho elemento;
@;	devuelve el índice del elemento activado, o bien el total de posiciones
@;	del tablero de juego (ROWS*COLUMNS) si no lo ha encontrado.
@;	Parámetros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
@;		R2 :	fila destino
@;		R3 :	columna destino
@;	Resultado:
@;		R0 :	índice del elemento encontrado, o ROWS*COLUMNS
	.global activa_elemento
activa_elemento:
		push {lr}
		
		
		@; /* código extra para que funcionen las tareas 2E */
		
		
	@;	unsigned char i = busca_elemento(fil, col);
		
	@;	if (i < ROWS*COLUMNS)			// si lo ha encontrado
	@;	{
	@;		vect_elem[i].vx = c2 - col;	// fija la velocidad como la diferencia
	@;		vect_elem[i].vy = f2 - fil;	// de posiciones a desplazarse
	@;		vect_elem[i].ii = 32;		// activa el movimiento (32 interrups.)
	@;	}
		
		pop {pc}



@;activa_escalado(unsigned char fil, unsigned char col);
@;	activa la animación de escalado de un elemento/sprite a partir de sus
@;	sus coordenadas fila y columna actuales;
@;	devuelve el índice del elemento activado, o bien el total de posiciones
@;	del tablero (ROWS*COLUMNS) si no lo ha encontrado.
@;	Parámetros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
@;	Resultado:
@;		R0 :	índice del elemento encontrado, o ROWS*COLUMNS
	.global activa_escalado
activa_escalado:
		push {r1, lr}
		
	@;	unsigned char i = busca_elemento(fil, col);
		bl busca_elemento
		
	@;	if (i < ROWS*COLUMNS)			// si lo ha encontrado
		cmp r0, #ROWS*COLUMNS
	@;	{								// activa escalado del sprite (grupo 0)
	@;		SPR_activa_rotacionEscalado(i, 0);
		movlo r1, #0
		bllo SPR_activa_rotacionEscalado
	@;	}
		
		pop {r1, pc}



@;desactiva_escalado(unsigned char fil, unsigned char col);
@;	desactiva la animación de escalado de un elemento/sprite a partir de sus
@;	coordenadas fila y columna actuales;
@;	devuelve el índice del elemento activado, o bien el total de posiciones
@;	del tablero (ROWS*COLUMNS) si no lo ha encontrado.
@;	Parámetros:
@;		R0 :	fila del elemento
@;		R1 :	columna del elemento
@;	Resultado:
@;		R0 :	índice del elemento encontrado, o ROWS*COLUMNS
	.global desactiva_escalado
desactiva_escalado:
		push {lr}
		
	@;	unsigned char i = busca_elemento(fil, col);
		bl busca_elemento
		
	@;	if (i < ROWS*COLUMNS)			// si lo ha encontrado
		cmp r0, #ROWS*COLUMNS
	@;	{								// desactiva escalado del sprite
	@;		SPR_desactiva_rotacionEscalado(i);
		bllo SPR_desactiva_rotacionEscalado
	@;	}
		
		pop {pc}




@;fija_metabaldosa(u16 *mapbase, unsigned char fil, unsigned char col,
@;														unsigned char imeta);
@;	guarda, en el mapa de baldosas cuya dirección base se pasa por
@;	parámetro, los índices de las baldosas correspondientes a una metabaldosa
@;	de MTROWS x MTCOLS (MTWIDTH x MTHEIGHT píxeles), a partir de la posición
@;	(fil, col) del espacio de juego y del índice de la metabaldosa.
@;	Parámetros:
@;		R0 :	dirección base del mapa de baldosas (mapbase)
@;		R1 :	fila del elemento
@;		R2 :	columna del elemento
@;		R3 :	índice de metabaldosa (imeta)
	.global fija_metabaldosa
fija_metabaldosa:
		push {r1-r9, lr}
		
		
		@; /* código extra para que funcionen las tareas 2Bb, 2Cb y 2G */
		
		
	@;	i_baldosa = imeta*MTOTAL;
			mov r4, #MTOTAL
			mul r5, r3, r4
			
			mov r3, r5				@; R3 = i_baldosa
			
			mov r4, #MTROWS
			mul r5, r1, r4
			mov r1, r5				@; R1 = fil*MTROWS
			
			mov r5, #MTCOLS
			mul r6, r2, r5
			mov r2, r6				@; R2 = col*MTCOLS
			
			mov r6, #0				@; R6 = df
			
	@;	for (df = 0; df < MTROWS; df++)
			.Lfor_df:
	@;	{								// dir. base en mapa de fila actual
	@;		base_fila = mapbase + (fil*MTROWS + df)*32;
				add r7, r1, r6			@; R7 = fil*MTROWS + df
				add r8, r0, r7, lsl #6	@; R8 = mapbase + (fil*MTROWS + df)*32;
										@; lsl #6 (2^6 = 64) pq 32 columnas * 2 bytes
				mov r9, #0 				@; R9 = dc
	@;		for (dc = 0; dc < MTCOLS; dc++)
				.Lfor_dc:
	@;		{
	@;			*(base_fila + col*MTCOLS + dc) = i_baldosa;
					add r7, r2, r9			@; R7 = col*MTCOLS + dc
					add r7, r8, r7, lsl #1	@; R7 = base_fila + (col*MTCOLS + dc)*2 bytes
					strh r3, [r7]			@; Guardem en R3 (i_baldosa)

	@;			i_baldosa++;
					add r3, #1
					add r9, #1				@; dc++
					cmp r9, #MTCOLS
					blo .Lfor_dc			@; continuar for si dc < MTCOLS
	@;		}
				add r6, #1				@; df++
				cmp r6, #MTROWS
				blo .Lfor_df
	@;	}
		
		pop {r1-r9, pc}

@;elimina_gelatina(u16 * mapaddr, unsigned char fil, unsigned char col);
@;	elimina una gelatina del tablero de juego, a partir de la dirección base
@;	del mapa de baldosas que contiene las gelatinas y de las coordenadas
@;	de fila y columna de la gelatina a eliminar.
@;	Parámetros:
@;		R0 :	dirección base del mapa de baldosas (mapbase) para gelatinas
@;		R1 :	fila del elemento
@;		R2 :	columna del elemento
	.global elimina_gelatina
elimina_gelatina:
		push {r3-r5, lr}
		
		ldr r4, =mat_gel
		mov r3, #COLUMNS
		mla r5, r1, r3, r2
		mov r3, #GEL_TAM
		mla r4, r5, r3, r4				@;R4 += (fil * COLUMNS + col) * GEL_TAM;
	@;	imeta = mat_gel[fil,col].im;
		ldrb r3, [r4, #GEL_IM]
	@;	if (imeta > 8)
	@;	{								// si código animación gelatina doble
		cmp r3, #8
		blo .Leligel_else
	@;		imeta -= 8;					// pasar a animación gelatina simple
		sub r3, #8
	@;		mat_gel[fil,col].im = imeta
		strb r3, [r4, #GEL_IM]
		b .Leligel_finif
	@;	}
	@;	else
	@;	{								// si código animación gelatina simple
	.Leligel_else:
	@;		mat_gel[fil,col].ii = -1	// desactiva gelatina
		mov r5, #-1
		strh r5, [r4, #GEL_II]
	@;		imeta = 19;					// índice metabaldosa transparente
		mov r3, #19
	@;	}
	.Leligel_finif:
		bl fija_metabaldosa			@;//fija_metabaldosa(mapbase,fil,col,imeta);
		
		pop {r3-r5, pc}

