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
/* candy1_main.c : función principal main() para test de tarea 1F 	*/
/* ---------------------------------------------------------------- */
#define NUMTESTS 15
short nmap[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14};

int main(void)
{
    unsigned char level;          //nivell joc
    unsigned char ntest = 0;      //nombre test
    bool original_viewed = false;  //flag, controla repr. matriu original
    char matrix_copy[ROWS][COLUMNS];  //per copiar la mat. original
	char moviments;
	
    consoleDemoInit();            // inicialització de pantalla de text
	
    //carregar nivell inicial
    level = nmap[0];
    printf("\x1b[38m\x1b[0;0H Nivell: %d", level);

    //inicialitzo matriu joc i faig una copia
    copia_matriz(matrix, mapas[level]);
    copia_matriz(matrix_copy, matrix);  
    escribe_matriz(matrix); 

    do  // bucle principal
    {
        printf("\x1b[39m\x1b[1;0H Test %d: Nivell %d", ntest, nmap[ntest]);
        //instruccions per pantalla
        printf("\x1b[38m\x1b[2;0H (A:aplica 1F, B:mat. orig, Right:next)");
	
        //wait a les tecles
        do
        {
            swiWaitForVBlank();
            scanKeys();
        } while (!(keysHeld() & (KEY_A | KEY_B | KEY_RIGHT)));

        //'A', aplicar baja_elementos
        if (keysHeld() & KEY_A)
        {
			copia_matriz(matrix_copy, matrix);
            moviments = baja_elementos(matrix);  // Executar rutina
            escribe_matriz(matrix);
            original_viewed = true;  // Marca que s'ha aplicat la rutina
			printf("\x1b[4;0H                               ");
			printf("\x1b[39m\x1b[4;0H Hi han moviments: %s", moviments ? "Si" : "No");
        }

        //'B', mostrar mat. anterior al ultim moviment.
        if ((keysHeld() & KEY_B) && original_viewed)
        {
            escribe_matriz(matrix_copy);
			printf("\x1b[39m\x1b[4;0H Mostrant matriu anterior");
        }

        //'Right' next test
        if (keysHeld() & KEY_RIGHT)
        {
            ntest++;  
			//canviar necessari
            if ((ntest < NUMTESTS) && (nmap[ntest] != level))
            {
                level = nmap[ntest];  //canvi de mapa
                printf("\x1b[38m\x1b[0;8H %d", level);
                copia_matriz(matrix, mapas[level]);
                copia_matriz(matrix_copy, matrix);
                escribe_matriz(matrix);  //mostrar nova matriu
                original_viewed = false;  //reset flag -> matriu no vista
				//esborrar les línies de text després de cada acció
				printf("\x1b[4;0H                               ");
				printf("\x1b[1;0H                               ");
            }
        }
        
        retardo(2);  //aplicar retard (visual)

    } while (ntest < NUMTESTS);

    printf("\x1b[38m\x1b[8;0H (fi proves)");
    do { swiWaitForVBlank(); } while(1);  //bucle joc infinit 

    return 0;
}

