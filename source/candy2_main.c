/*------------------------------------------------------------------------------

	$ candy2_main.c $

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
#include "candy2_incl.h"


/* ATENCIÓN: cuando el programa se considere terminado, hay que comentar la
			 lÃ­nea '#define TRUCOS' y volver a compilar, con el fin de generar
			 un fichero ejecutable libre del cÃ³digo de trucos.
*/
#define TRUCOS		// si se define este sÃ­mbolo se generarÃ¡ un ejectuable con
					// los trucos que permiten controlar el juego para testear
					// su funcionamiento, pulsando los siguientes botones:
					//	'B' 	 ->	pasa al siguiente nivel
					//	'START'	 ->	reinicia el nivel actual
					//	'<' 	 ->	pasa a modo backup, donde se puede ver
					//				el contenido del tablero y la informaciÃ³n
					//				de juego (puntos, movimientos restantes,
					//				gelatinas) de momentos anteriores del juego,
					//				con los botones de flecha izquierda/derecha:
					//				 '<'	 ->	ver momento anterior
					//				 '>'	 ->	ver momento siguiente

/* definiciones del programa */
						// definiciones para el estado actual del juego
#define E_INIT		0		// inicializar nivel actual del juego
#define E_PLAY		1		// interacciÃ³n con el usuario
#define E_BREAK		2		// romper secuencias y gelatinas
#define E_FALL		3		// caÃ­da de los elementos
#define E_CHECK		4		// comprobar condiciones de fin de nivel

						// definiciones para la funciÃ³n procesa_caida()
#define PC_FALLING	0		// todavÃ­a estan cayendo elementos
#define PC_ENDNOSQ	1		// ya no hay caÃ­das y no se ha generado ninguna secuencia
#define PC_ENDSEQ	2		// ya no hay caÃ­das y se han generado nuevas secuencias

						// definiciones para la funciÃ³n comprueba_jugada()
#define CJ_CONT		0		// no ha pasado nada especial, seguir jugando en el mismo nivel
#define	CJ_LEVEL	1		// el nivel se ha superado o no, hay que iniciar siguiente nivel o reiniciar nivel actual
#define	CJ_RCOMB	2		// se ha producido una recombinaciÃ³n y se han generado nuevas combinaciones
#define	CJ_RNOCMB	3		// se ha producido una recombinaciÃ³n pero no hay nuevas combinaciones

						// definiciones para la gestiÃ³n de sugerencias
#define T_INACT		192		// tiempo de inactividad del usuario (3 seg. aprox.)
#define T_MOSUG		64		// tiempo entre mostrar sugerencias (1 seg. aprox.)


/* variables globales */
char matrix[ROWS][COLUMNS];		// matriz global de juego
char mat_mar[ROWS][COLUMNS];	// matriz de marcas
unsigned char pos_sug[6];		// posiciones de una sugerencia de combinaciÃ³n

unsigned int seed32;			// semilla de nÃºmeros aleatorios


#ifdef TRUCOS

#define MAXBACKUP	36			// memoria para el 'backup' de la evoluciÃ³n del
char b_mat[MAXBACKUP][ROWS][COLUMNS];	// tablero más la información de juego
char b_mat[MAXBACKUP][ROWS][COLUMNS];	// tablero más la información de juego
unsigned int b_info[MAXBACKUP];			// (puntos, movimientos, gelatinas)
unsigned short b_last, b_num;			// Ãºltimo Ã­ndice y nÃºmero de backups

#endif


/* inicializa_interrupciones(): configura las direcciones de las RSI y los bits
	de habilitación (enable) del controlador de interrupciones para que se
	puedan generar las interrupciones requeridas.*/ 
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


/* inicializa_nivel(mat,lev,*p,*m,*g): inicializa un nivel de juego a partir
	del parámetro lev (level), modificando la matriz y la información de juego
	(puntos, movimientos, gelatinas) que se pasan por referencia.
*/
void inicializa_nivel(char mat[][COLUMNS], unsigned char lev,
							short *p, unsigned char *m, unsigned char *g)
{
	inicializa_matriz(mat, lev);
	genera_sprites(mat);
	genera_mapa1(mat);
	genera_mapa2(mat);
	escribe_matriz(mat);
	*p = pun_obj[lev];
	*m = max_mov[lev];
	*g = cuenta_gelatinas(mat);
	//actualiza_contadores(lev, *p, *m, *g);
	borra_puntuaciones();
	retardo(3);			// tiempo para ver matriz inicial
}



void prueba_tarea_2Ca();
void prueba_tarea_2Cb(unsigned char *state, unsigned char *level);
void mostrarTIMER2();
void prueba_tarea_2Gc();
void prueba_tarea_2Gb();
void prueba_fija_metabaldosa();
int mod_random(int random);

//borra les lineas de text de la pantalla de instruccions
void clear_instructions() {
    for (int i = 0; i < 9; i++) {
        printf("\x1b[%d;0H%.*s", i, 32, "                                "); // 32 espacios
    }
}

//restaura las instruccionns principals de pantalla
void restore_instructions() {
    printf("\x1b[0;0H Joc proves prog3 (versio 2: grafics)\n");
	printf("\x1b[3;0H Click 'Q' Specs. BG1 (2Ca)");
	printf("\x1b[4;0H Click 'W' activa timer2 (2Gb)");
	printf("\x1b[5;0H Click 'B' para timer2 (2Gc)");
	printf("\x1b[6;0H Click 'A' pasar nivell (2Cb)");
	printf("\x1b[7;0H Click 'X' mostrar matriu (2Jc)");
}


/* Programa principal: Proves prog3 Arnau Faura i Ciré */
int main(void)
{
	unsigned char level = 0;		// nivel del juego (nivel inicial = 0)
	short points = 0;				// contador de puntos
	unsigned char moves = 0;		// nÃºmero de movimientos restantes
	unsigned char gelees = 0;		// nÃºmero de gelatinas restantes
	
	unsigned char state = E_INIT;	// estado actual del programa

	seed32 = time(NULL);			// fija semilla inicial nÃºmeros aleatorios
	init_grafA();
	inicializa_interrupciones();

	consoleDemoInit();				// inicializa pantalla de texto
	printf("\x1b[0;0H Joc proves prog3 (versio 2: grafics)\n");
	printf("\x1b[3;0H Click 'Q' Specs. BG1 (2Ca)");
	printf("\x1b[4;0H Click 'W' activa timer2 (2Gb)");
	printf("\x1b[5;0H Click 'B' para timer2 (2Gc)");
	printf("\x1b[6;0H Click 'A' pasar nivell (2Cb)");
	printf("\x1b[7;0H Click 'X' mostrar matriu (2Jc)");
	do								// bucle principal del juego
	{
		swiWaitForVBlank();
		scanKeys();
		
		mostrarTIMER2();		//Mostrar valors del timer 2
		
		if (keysHeld() & KEY_L) {
            prueba_tarea_2Ca();  // Mostrar especificaciones del fondo 1
        }
	
        if (keysHeld() & KEY_R) {
            prueba_tarea_2Gb();   //Activar timer2
        }
		
        if (keysHeld() & KEY_B) {
            prueba_tarea_2Gc();  //Parar timer2
        }
		
        if (keysHeld() & KEY_A) {
            prueba_tarea_2Cb(&state, &level);  //Pasar nivell
        }
		
		if (keysHeld() & KEY_X) { 
			prueba_fija_metabaldosa();  // Probar fija_metabaldosa
		}
		
        if (state == E_INIT) {
            inicializa_nivel(matrix, level, &points, &moves, &gelees);	//mostrar gelatines, 2Ga i 2Gd
            state = E_PLAY;
        }
	} while (1);				// bucle infinito
	
	return(0);
}

void prueba_tarea_2Ca() {
    clear_instructions();  //borra instrucciones
    // Dirección del registro de control del fondo 1
    volatile unsigned short* bg1cnt = (volatile unsigned short*)0x0400000A;
    unsigned short bg1cnt_val = *bg1cnt;

    // Extraer y mostrar los valores relevantes
    printf("\x1b[3;0H Fondo 1:");
    printf("\x1b[4;0H Prioritat: %d", bg1cnt_val & 0x03); // Bits 1..0
    printf("\x1b[5;0H Base de baldoses: %d", (bg1cnt_val >> 2) & 0x0F); // Bits 5..2
    printf("\x1b[6;0H Base del mapa: %d", (bg1cnt_val >> 8) & 0x1F); // Bits 12..8
    retardo(50);  //pausa per observar
    restore_instructions();  // Volver a mostrar las instrucciones
}

void mostrarTIMER2() {
    printf("\x1b[8;0H TIMER2: Control = %x, Data = %x",
           TIMER2_CR, TIMER2_DATA);
}

void prueba_tarea_2Gc() {
    clear_instructions();  //borra instrucciones
    desactiva_timer2();
    printf("\x1b[3;0H Timer2 STOPPED.");
    retardo(10);  //pausa per observar
    restore_instructions(); //borrar resultats
}

void prueba_tarea_2Cb(unsigned char *state, unsigned char *level) {
    if (*level > MAXLEVEL) {
        *level = 0;
    } 
	(*level)++;
    *state = E_INIT;
}

void prueba_tarea_2Gb() {
    clear_instructions();  ////borra instrucciones
    activa_timer2();
    printf("\x1b[3;0H Timer2 ACTIVE");
    retardo(10);  //pausa per observar
    restore_instructions(); //borrar resultats
}

//nomès les mostra de manera visual, al mapa no s'actualitzen perque no
//es crida a crea elemento ni activa elemento
void prueba_fija_metabaldosa() {
    clear_instructions();  //borrar instruccions

    //conf. inicial
    unsigned short* mapbase = (u16 *) bgGetMapPtr(1); //direcció base del mapa
	if (mapbase == NULL) {
        printf("\x1b[3;0H Error: mapa no trobat.");
        retardo(200);
        restore_instructions(); //borrar resultats
        return;
    }
	
    unsigned char fil = mod_random(6);  //fila inicial aleatoria (0..ROWS)
    unsigned char col = mod_random(8);  //columna inicial (0..COLUMNS)
	unsigned char imeta = mod_random(20); //index de metabaldosa aleatori
	//especificar valor que s'està mostrant
	printf("\x1b[3;0H Bal. %d fil. %d, col. %d:", imeta, fil, col);
    //ficar la gelatina trucant a fija_metabaldosa
    fija_metabaldosa(mapbase, fil, col, imeta);

    retardo(75);  //pausa per observar
    restore_instructions();  //borrar resultats
}

