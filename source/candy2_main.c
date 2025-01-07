/*------------------------------------------------------------------------------

	$ candy2_main.c $

	Programa principal para la práctica de Computadores: candy-crash para NDS
	(2º curso de Grado de Ingeniería Informática - ETSE - URV)
	
	Analista-programador: santiago.romani@urv.cat
	Programador 1: xxx.xxx@estudiants.urv.cat
	Programador 2: yyy.yyy@estudiants.urv.cat
	Programador 3: zzz.zzz@estudiants.urv.cat
	Programador 4: gerard.ros@estudiants.urv.cat

------------------------------------------------------------------------------*/
#include <nds.h>
#include <stdio.h>
#include <time.h>
#include "candy2_incl.h"


/* ATENCIÓN: cuando el programa se considere terminado, hay que comentar la
			 línea '#define TRUCOS' y volver a compilar, con el fin de generar
			 un fichero ejecutable libre del código de trucos.
*/
#define TRUCOS		// si se define este símbolo se generará un ejectuable con
					// los trucos que permiten controlar el juego para testear
					// su funcionamiento, pulsando los siguientes botones:
					//	'B' 	 ->	pasa al siguiente nivel
					//	'START'	 ->	reinicia el nivel actual
					//	'<' 	 ->	pasa a modo backup, donde se puede ver
					//				el contenido del tablero y la información
					//				de juego (puntos, movimientos restantes,
					//				gelatinas) de momentos anteriores del juego,
					//				con los botones de flecha izquierda/derecha:
					//				 '<'	 ->	ver momento anterior
					//				 '>'	 ->	ver momento siguiente

/* definiciones del programa */
						// definiciones para el estado actual del juego
#define E_INIT		0		// inicializar nivel actual del juego
#define E_PLAY		1		// interacción con el usuario
#define E_BREAK		2		// romper secuencias y gelatinas
#define E_FALL		3		// caída de los elementos
#define E_CHECK		4		// comprobar condiciones de fin de nivel

						// definiciones para la función procesa_caida()
#define PC_FALLING	0		// todavía estan cayendo elementos
#define PC_ENDNOSQ	1		// ya no hay caídas y no se ha generado ninguna secuencia
#define PC_ENDSEQ	2		// ya no hay caídas y se han generado nuevas secuencias

						// definiciones para la función comprueba_jugada()
#define CJ_CONT		0		// no ha pasado nada especial, seguir jugando en el mismo nivel
#define	CJ_LEVEL	1		// el nivel se ha superado o no, hay que iniciar siguiente nivel o reiniciar nivel actual
#define	CJ_RCOMB	2		// se ha producido una recombinación y se han generado nuevas combinaciones
#define	CJ_RNOCMB	3		// se ha producido una recombinación pero no hay nuevas combinaciones

						// definiciones para la gestión de sugerencias
#define T_INACT		192		// tiempo de inactividad del usuario (3 seg. aprox.)
#define T_MOSUG		64		// tiempo entre mostrar sugerencias (1 seg. aprox.)


/* variables globales */
char matrix[ROWS][COLUMNS];		// matriz global de juego
char mat_mar[ROWS][COLUMNS];	// matriz de marcas
unsigned char pos_sug[6];		// posiciones de una sugerencia de combinación

unsigned int seed32;			// semilla de números aleatorios


#define MAXBACKUP	36			// memoria para el 'backup' de la evolución del
char b_mat[MAXBACKUP][ROWS][COLUMNS];	// tablero más la información de juego
unsigned int b_info[MAXBACKUP];			// (puntos, movimientos, gelatinas)
unsigned short b_last, b_num;			// último índice y número de backups/* inicializa_interrupciones(): configura las direcciones de las RSI y los bits

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

/* procesa_botonY(): comprueba la pulsación del botón 'Y' y activa o desactiva
	el desplazamiento del fondo gráfico. */
void procesa_botonY()
{
	if (keysHeld() & KEY_Y){	// activar o desactivar desplazam.
		if (timer3_on) desactiva_timer3();	// imagen del fondo 3
		else activa_timer3();
		printf("\x1b[38m\x1b[3;24H%s",(timer3_on ? "si" : "no"));
		while (keysHeld() & KEY_Y){		// esperar liberacion tecla Y
			swiWaitForVBlank();	
			scanKeys();		
		}
	}
}

/* Programa principal: control general del juego */
int main(void)
{

	seed32 = time(NULL);			// fija semilla inicial números aleatorios
	init_grafA();
	inicializa_interrupciones();

	consoleDemoInit();				// inicializa pantalla de texto
	printf("candyNDS (version 2: graficos)\n");
	printf("\x1b[38m\x1b[1;0H  nivel:");
	printf("\x1b[39m\x1b[2;0H puntos:");
	printf("\x1b[38m\x1b[1;15H movimientos:");
	printf("\x1b[37m\x1b[2;15H   gelatinas:");
	printf("\x1b[38m\x1b[3;0H despl.fondo (tecla Y): no");

	do								// bucle principal del juego
	{
		swiWaitForVBlank();
		scanKeys();
		procesa_botonY();
	} while (1);				// bucle infinito
	
	return(0);					// nunca retornará del main
}

