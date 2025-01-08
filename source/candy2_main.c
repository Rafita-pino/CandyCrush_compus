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


void mostrar_timer0() {
	clear_line(10);
	//printf("\x1b[38m\x1b[10;0H  TIMER1_CR: \x1b[39m%x, \x1b[38mTIMER1_DATA \x1b[39m%x", TIMER1_CR, TIMER1_DATA);
	//printf("\x1b[38m\x1b[10;0H  escNum: \x1b[39m%d, \x1b[38mescFac: \x1b[39m%d", escNum, escFac);
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

void inicializa_interrupciones()
{
	irqSet(IRQ_VBLANK, rsi_vblank);
	TIMER0_CR = 0x00;  		// inicialmente los timers no generan interrupciones
	irqSet(IRQ_TIMER0, rsi_timer0);		// cargar direcciones de las RSI
	irqEnable(IRQ_TIMER0);				// habilitar la IRQ correspondiente
	TIMER1_CR = 0x00;
	irqSet(IRQ_TIMER1, rsi_timer1);
	irqEnable(IRQ_TIMER1);
	TIMER2_CR = 0x00;
	irqSet(IRQ_TIMER2, rsi_timer2);
	irqEnable(IRQ_TIMER2);
	TIMER3_CR = 0x00;
	irqSet(IRQ_TIMER3, rsi_timer3);
	irqEnable(IRQ_TIMER3);
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
	inicializa_nivel(matrix, level);
	
	do								// bucle principal del juego
	{
		
		swiWaitForVBlank();
		scanKeys();
		
		
		if(keysHeld() & KEY_B) { // Pulsar B para ver los diferentes niveles de la Tarea 2B
			level = (level > MAXLEVEL) ? 0:level;
			inicializa_nivel(matrix, level);
			level++;
		}	
				
		
	} while (1);				// bucle infinito
	
	return(0);					// nunca retornará del main
}