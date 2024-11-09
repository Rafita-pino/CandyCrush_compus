﻿/*------------------------------------------------------------------------------

	$ candy2_graf.c $

	Funciones de inicialización de gráficos (ver 'candy2_main.c')

	Analista-programador: santiago.romani@urv.cat
	Programador tarea 2A: xxx.xxx@estudiants.urv.cat
	Programador tarea 2B: yyy.yyy@estudiants.urv.cat
	Programador tarea 2C: zzz.zzz@estudiants.urv.cat
	Programador tarea 2D: uuu.uuu@estudiants.urv.cat

------------------------------------------------------------------------------*/
#include <nds.h>
#include "candy2_incl.h"
#include "Graphics_data.h"
#include "Sprites_sopo.h"


/* variables globales */
unsigned char n_sprites = 0;		// número total de sprites creados
elemento vect_elem[ROWS*COLUMNS];	// vector de elementos
gelatina mat_gel[ROWS][COLUMNS];	// matriz de gelatinas



// TAREA 2Ab
/* genera_sprites(): inicializar los sprites con prioridad 1, creando la
	estructura de datos y las entradas OAM de los sprites correspondiente a la
	representación de los elementos de las casillas de la matriz que se pasa
	por parámetro (independientemente de los códigos de gelatinas).*/
void genera_sprites(char mat[][COLUMNS])
{


}



// TAREA 2Bb
/* genera_mapa2(*mat): generar un mapa de baldosas (en la segunda base para
	mapas de baldosas) como un tablero ajedrezado de metabaldosas de 32x32
	píxeles (4x4 baldosas), en las posiciones de la matriz donde haya que
	visualizar elementos con o sin gelatina, bloques sólidos o espacios vacíos
	sin elementos, excluyendo solo los huecos.*/
void genera_mapa2(char mat[][COLUMNS])
{


}



// TAREA 2Cb
/* genera_mapa1(*mat): generar un mapa de baldosas (a partir del inicio de la
	memoria gráfica) correspondiente a la representación de las casillas de la
	matriz que se pasa por parámetro, utilizando metabaldosas de 32x32 píxeles
	(4x4 baldosas), visualizando las gelatinas simples y dobles, los bloques
	sólidos y los huecos con las metabaldosas correspondientes (para las
	gelatinas, elegir una metabaldosa aleatoria de la animación).*/
void genera_mapa1(char mat[][COLUMNS])
{


}



// TAREA 2Db
/* ajusta_imagen3(unsigned char ibg): rotar 90 grados a la derecha la imagen del
	fondo cuyo identificador se pasa por parámetro (fondo 3 del procesador
	gráfico principal) y desplazarla para que se visualize en vertical a partir
	del primer píxel de la pantalla. */
void ajusta_imagen3(unsigned char ibg)
{


}




// TAREAS 2Aa,2Ba,2Ca,2Da
/* init_grafA(): inicializaciones generales del procesador gráfico principal,
				reserva de bancos de memoria y carga de información gráfica,
				generando el fondo 3 y fijando la transparencia entre fondos.*/
void init_grafA()
{
	int bg1A, bg2A, bg3A;

	videoSetMode(MODE_3_2D | DISPLAY_SPR_1D_LAYOUT | DISPLAY_SPR_ACTIVE);
	
// Tarea 2Aa:
	// reservar banco F para sprites, a partir de 0x06400000

// Tareas 2Ba y 2Ca:
	// reservar banco E para fondos 1 y 2, a partir de 0x06000000

// Tarea 2Da:
	// reservar bancos A y B para fondo 3, a partir de 0x06020000




// Tarea 2Aa:
	// cargar las baldosas de la variable SpritesTiles[] a partir de la
	// dirección virtual de memoria gráfica para sprites, y cargar los colores
	// de paleta asociados contenidos en la variable SpritesPal[]



// Tareas 2Ba y 2Ca:
	// descomprimir (y cargar) las baldosas de la variable BaldosasTiles[] a
	// partir de la dirección virtual correspondiente al primer bloque de
	// memoria gráfica (+16 Kbytes), cargar los colores de paleta asociados
	// contenidos en la variable BaldosasPal[]


	
// Tarea 2Ca:
	//inicializar el fondo 1 con prioridad 0



// Tarea 2Ba:
	// inicializar el fondo 2 con prioridad 2


	
// Tarea 2Da:
	// descomprimir (y cargar) la imagen de la variable FondoBitmap[] a partir
	// de la dirección virtual de vídeo correspondiente al banco de vídeoRAM A

	// inicializar el fondo 3 con prioridad 3



	lcdMainOnBottom();

	/* transparencia fondos:
		//	bit 1 = 1 		-> 	BG1 1st target pixel
		//	bit 2 = 1 		-> 	BG2 1st target pixel
		//	bits 7..6 = 01	->	Alpha Blending
		//	bit 11 = 1		->	BG3 2nd target pixel
		//	bit 12 = 1		->	OBJ 2nd target pixel
	*/
	*((u16 *) 0x04000050) = 0x1846;	// 0001100001000110
	/* factor de "blending" (mezcla):
		//	bits  4..0 = 01001	-> EVA coefficient (1st target)
		//	bits 12..8 = 00111	-> EVB coefficient (2nd target)
	*/
	*((u16 *) 0x04000052) = 0x0709;
}

