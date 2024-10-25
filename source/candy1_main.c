/*------------------------------------------------------------------------------

	$ candy1_main.c $

	Programa principal para la práctica de Computadores: candy-crash para NDS
	(2º curso de Grado de Ingeniería Informática - ETSE - URV)
	
	Analista-programador: santiago.romani@urv.cat
	Programador 1: rafael.pinor@estudiants.urv.cat
	Programador 2: oupman.miralles@estudiants.urv.cat
	Programador 3: arnau.faura@estudiants.urv.cat
	Programador 4: gerard.ros@estudiants.urv.cat

------------------------------------------------------------------------------*/
#include <nds.h>
#include <stdio.h>
#include <time.h>
#include "candy1_incl.h"


/* variables globales */
char matrix[ROWS][COLUMNS];		// matriz global de juego
unsigned int seed32;			// semilla de numeros aleatorios
/* ---------------------------------------------------------------- */
/* candy1_main.c : función principal main() para test de tarea 1E 	*/
/* ---------------------------------------------------------------- */
#define NUMTESTS 26
short nmap[] = {0, 1, 2, 2, 2, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 8, 14, 14, 9, 10, 11, 12, 13};
short posX[] = {1, 0, 8, 0, 4, 0, 0, 0, 0, 4, 4, 4, 0, 0, 5, 4, 1, 1, 1, 0, 0, 1, 4, 2, 0, 8};
short posY[] = {0, 2, 0, 8, 0, 2, 2, 2, 2, 4, 4, 4, 0, 0, 0, 4, 3, 3, 5, 0, 7, 4, 5, 2, 0, 0};
short cori[] = {1, 2, 0, 1, 3, 0, 1, 2, 3, 0, 1, 2, 0, 3, 0, 0, 1, 3, 0, 1, 3, 0, 3, 2, 0, 2};
short resp[] = {9, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 3, 1, 3, 5, 2, 4, 2, 8, 8, 2, 1, 3, 9, 9};

int main(void)
{
	unsigned char level;			// nivel del juego
	unsigned char ntest = 0;		// número de test
	unsigned char result;			// resultado de cuenta_repeticiones()
	int errors = 0;
	
	consoleDemoInit();			// inicialización de pantalla de texto
	printf("candyNDS (prueba tarea 1E)\n");
	level = nmap[0];
	printf("\x1b[38m\x1b[1;0H  nivel: %d", level);
	copia_matriz(matrix, mapas[level]);
	escribe_matriz_testing(matrix);
	do							// bucle principal de pruebas
	{
		printf("\x1b[39m\x1b[2;0H test %d: posXY (%d, %d), c.ori %d",
									ntest, posX[ntest], posY[ntest], cori[ntest]);
		printf("\x1b[39m\x1b[3;0H resultado esperado: %d", resp[ntest]);
		
		result = cuenta_repeticiones(matrix, posY[ntest], posX[ntest], cori[ntest]);
		
		printf("\x1b[39m\x1b[4;0H resultado obtenido: %d", result);
		if (result != resp[ntest]) errors++; //incrementar num. errors si n'hi ha hagut
		
		retardo(2);
		printf("\x1b[38m\x1b[5;19H (pulse A/B)");
		do
		{	swiWaitForVBlank();
			scanKeys();					// esperar pulsación tecla 'A' o 'B'
		} while (!(keysHeld() & (KEY_A | KEY_B)));
		printf("\x1b[2;0H                               ");
		printf("\x1b[3;0H                               ");
		printf("\x1b[4;0H                               ");
		printf("\x1b[38m\x1b[5;19H            ");
		retardo(2);
		if (keysHeld() & KEY_A)		// si pulsa 'A',
		{
			ntest++;				// siguiente test
			if ((ntest < NUMTESTS) && (nmap[ntest] != level))
			{				// si número de mapa del siguiente test diferente
				level = nmap[ntest];		// del número de mapa actual,
				printf("\x1b[1;8H                               ");
				printf("\x1b[38m\x1b[1;8H %d", level); // cambiar el mapa actual
				copia_matriz(matrix, mapas[level]);
				escribe_matriz_testing(matrix);
			}
		}
		if (keysHeld() & KEY_B)     // si pitja 'B', tornar test anterior
		{
			if (ntest > 0) ntest--;
			level = nmap[ntest];
			printf("\x1b[38m\x1b[1;8H %d", level);
			copia_matriz(matrix, mapas[level]);
			escribe_matriz(matrix);
		}
		
		
	} while (ntest < NUMTESTS);		// bucle de pruebas
	//netejar missatges
	printf("\x1b[1;8H                               ");
	printf("\x1b[1;0H                               ");
	printf("\x1b[2;0H                               ");
	printf("\x1b[3;0H                               ");
	printf("\x1b[4;0H                               ");
	printf("\x1b[38m\x1b[5;19H            ");
	printf("\x1b[38m\x1b[4;0H Fi tests; Num errors: %d", errors); //mostrar errors
	do { swiWaitForVBlank(); } while(1);	// bucle infinito
	return(0);
}

