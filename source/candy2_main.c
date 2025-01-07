/*------------------------------------------------------------------------------

	$ candy2_main.c $

	Programa principal para la práctica de Computadores: candy-crash para NDS
	(2º curso de Grado de Ingeniería Informática - ETSE - URV)
	
	Analista-programador: santiago.romani@urv.cat

	Programador 2: oupman.miralles@estudiants.urv.cat

------------------------------------------------------------------------------*/
#include <nds.h>
#include <stdio.h>
#include <time.h>
#include "candy2_incl.h"
#include "candy1_incl.h"

/* variables globales */
char matrix[ROWS][COLUMNS];		// matriz global de juego
char mat_mar[ROWS][COLUMNS];	// matriz de marcas

unsigned int seed32;			// semilla de números aleatorios

const char* secus[] = {				// info sobre secuencias
	"casillas vacias",
	"bloques solidos",
	"huecos",
	"elems sin gel",
	"elems con gel s",
	"elems con gel d",
	"huecos con elems"
};

// Borra una linea
void clear_line(int row) {
    printf("\x1b[%d;0H                                ", row);
}

// Printea el nivel y su informacion
void level_info(unsigned char level) {
	clear_line(4);
    printf("\x1b[38m\x1b[4;0H  nivel: \x1b[39m%d", level);
	clear_line(6);
	printf("\x1b[38m\x1b[6;0H  Fondo: \x1b[39m%s", secus[level]);
}



void inicializa_nivel(char mat[][COLUMNS], unsigned char lev)
{
	level_info(lev);
	copia_matriz(mat, mapas[lev]);
	genera_sprites(mat);
	genera_mapa1(mat);
	genera_mapa2(mat);
	escribe_matriz(mat);
	retardo(3);			// tiempo para ver matriz inicial
}

// Espera que se pulse B
void wait_keyB() {
	do
	{
		swiWaitForVBlank();
		scanKeys();					// esperar tecla 'B'
	} while (!(keysHeld() & KEY_B));
	return;
}

/* Programa principal: control general del juego */
int main(void)
{
	unsigned char level = 0;		// nivel del juego (nivel inicial = 0)

	seed32 = time(NULL);			// fija semilla inicial números aleatorios
	init_grafA();

	consoleDemoInit();				// inicializa pantalla de texto
	printf("candyNDS (version 2: graficos)\n");
	printf("\nJuego de pruebas Tareas 2B \n");
	printf("\x1b[39m\x1b[8;0H  Pulse '\x1b[36mB\x1b[39m' para \x1b[32mpasar nivel\x1b[39m.");

	do								// bucle principal del juego
	{
		swiWaitForVBlank();
		scanKeys();
		level = (level > MAXLEVEL) ? 0:level;
		inicializa_nivel(matrix, level);
		wait_keyB();
		level++;	
		
		
	} while (1);				// bucle infinito
	
	return(0);					// nunca retornará del main
}