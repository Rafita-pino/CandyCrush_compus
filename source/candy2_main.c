﻿	/*------------------------------------------------------------------------------

	$ candy2_main.c $

	Programa principal para la práctica de Computadores: candy-crash para NDS
	(2º curso de Grado de Ingeniería Informática - ETSE - URV)
	
	Analista-programador: santiago.romani@urv.cat


	Programador 1: rafael.pinor@estudiants.urv.cat
	Programador 2: oupman.miralles@estudiants.urv.cat
	Programador 3: arnau.faura@estudiants.urv.cat
	Programador	4: gerard.ros@estudiants.urv.cat


------------------------------------------------------------------------------*/
#include <nds.h>
#include <stdio.h>
#include <time.h>
#include "candy2_incl.h"



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



/* actualiza_contadores(lev,p,m,g): actualiza los contadores que se indican con
	los parámetros correspondientes:
		lev:	nivel (level)
		p:	puntos
		m:	movimientos
		g:	gelatinas
*/
void actualiza_contadores(unsigned char lev, short p, unsigned char m,
											unsigned char g)
{
	printf("\x1b[38m\x1b[1;8H %d", lev);
	printf("\x1b[39m\x1b[2;8H %d  ", p);
	printf("\x1b[38m\x1b[1;28H %d ", m);
	printf("\x1b[37m\x1b[2;28H %d ", g);
}



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
	actualiza_contadores(lev, *p, *m, *g);
	borra_puntuaciones();
	retardo(3);			// tiempo para ver matriz inicial
}



/* procesa_pulsacion(mat,p,*m,g): procesa la pulsación de la pantalla táctil
	y, en caso de que se genere alguna secuencia, decrementa el número de
	movimientos y retorna un código diferente de cero.
*/
unsigned char procesa_pulsacion(char mat[][COLUMNS], 
							short p, unsigned char *m, unsigned char g)
{
	unsigned char mX, mY, dX, dY;	// variables de posiciones de intercambio
	unsigned char result = 0;
	
	if (procesa_touchscreen(mat, &mX, &mY, &dX, &dY))
	{
		intercambia_posiciones(mat, mX, mY, dX, dY);
		escribe_matriz(mat);
		if (hay_secuencia(mat))
		{
			(*m)--;				// un movimiento utilizado
			borra_puntuaciones();
			result = 1;			// notifica que hay secuencia

		}
		else			// si no se genera secuencia,		
		{				// deshace el cambio
			intercambia_posiciones(mat, mX, mY, dX, dY);
			escribe_matriz(mat);
		}
	}
	while (keysHeld() & KEY_TOUCH)	// espera liberación
	{	swiWaitForVBlank();			// pantalla táctil
		scanKeys();
	}
	return(result);
}




/* procesa_rotura(mat,lev,*p,m,*g): procesa la eliminación de secuencias y
	actualiza el nuevo valor de puntos y gelatinas (parámetros pasados por
	referencia); utiliza la variable globla mat_mar[][]; también se pasan
	los parámetros lev (level) y m (moves) con el fin de llamar a la función
	de actualización de contadores.
*/
void procesa_rotura(char mat[][COLUMNS], unsigned char lev,
								short *p, unsigned char m, unsigned char *g)
{
	elimina_secuencias(mat, mat_mar);
	escribe_matriz(mat);
	*p += calcula_puntuaciones(mat_mar);
	if (*g > 0) *g = cuenta_gelatinas(matrix);
	actualiza_contadores(lev, *p, m, *g);
}



/* procesa_caida(mat,p,m,g): procesa la caída de elementos; la función devuelve
	un código que representa las siguientes situaciones:
		PC_FALLING (0):	ha habido caída de algún elemento
		PC_ENDNOSQ (1):	no ha habido caída y no se han formado nuevas secuencias
		PC_ENDSEQ  (2):	no ha habido caída y se han formado nuevas secuencias
*/
unsigned char procesa_caida(unsigned char f_init, char mat[][COLUMNS],
								short p, unsigned char m, unsigned char g)
{
	unsigned char result = PC_FALLING;

	if (baja_elementos(mat))
	{
		activa_timer0(f_init);		// activar timer de movimientos
		while (timer0_on) swiWaitForVBlank();	// espera final
		escribe_matriz(mat);
	}
	else
	{						// cuando ya no hay más bajadas
		if (hay_secuencia(matrix))
		{
			retardo(3);		// tiempo para ver la secuencia
			result = PC_ENDSEQ;
		}
		else result = PC_ENDNOSQ;
	}
	return(result);
}



/* comprueba_jugada(mat,*lev,p,m,g): comprueba las posibles situaciones que se
	pueden generar después de una jugada; la función devuelve un código que
	representa dichas situaciones:
		CJ_CONT   (0):	no ha pasado nada especial, seguir jugando en el mismo nivel
		CJ_LEVEL  (1):	el nivel se ha superado o no, hay que reiniciar nivel actual o siguiente
		CJ_RCOMB  (2):	se ha producido una recombinación y se han generado nuevas combinaciones
		CJ_RNOCMB (3):	se ha producido una recombinación pero no hay nuevas combinaciones
*/
unsigned char comprueba_jugada(char mat[][COLUMNS], unsigned char *lev,
								short p, unsigned char m, unsigned char g)
{
	unsigned char result = CJ_CONT;
	
	if (((p >= 0) && (g == 0)) || (m == 0) || !hay_combinacion(mat))
	{
		if ((p >= 0) && (g == 0)) 	printf("\x1b[39m\x1b[6;20H _SUPERADO_");
		else if (m == 0)			printf("\x1b[39m\x1b[6;20H _REPETIR_");
		else						printf("\x1b[39m\x1b[6;20H _BARAJAR_");
		
		printf("\x1b[39m\x1b[8;20H (pulse A)");
		while (!(keysHeld() & KEY_A))
		{	swiWaitForVBlank();
			scanKeys();						// espera pulsación 'A'
		}
		printf("\x1b[6;20H           ");
		printf("\x1b[8;20H           "); 	// borra mensajes
		borra_puntuaciones();
		if (((p >= 0) && (g == 0)) || (m == 0))
		{
			if ((p >= 0) && (g == 0))  			// si nivel superado
				*lev =	(*lev + 1) % MAXLEVEL;	 	// incrementa nivel
			printf("\x1b[2;8H      ");				// borra puntos anteriores
			result = CJ_LEVEL;
		}
		else					// si no hay combinaciones
		{
			recombina_elementos(mat);
			activa_timer0(1);		// activar timer de movimientos
			while (timer0_on) swiWaitForVBlank();	// espera final
			escribe_matriz(mat);
			if (!hay_combinacion(mat))  result = CJ_RNOCMB;
			else						result = CJ_RCOMB;
		}
	}
	return(result);
}



/* procesa_sugerencia(mat,lap): según el valor del parámetro lap (número de
	vertical blanks esperando a que el usuario realice un movimiento), esta
	función calcula una posible combinación guardando las coordenadas de los
	elementos involucrados sobre el vector global pos_sug[6]; además, cada
	cierto tiempo efectúa una visualización momentánea de caracteres '_' en
	dichas posiciones.
*/
void procesa_sugerencia(char mat[][COLUMNS], unsigned short lap)
{
	if (lap == T_INACT) 
	{				// activa el cálculo de posiciones de una combinación
		sugiere_combinacion(mat, pos_sug);
		borra_puntuaciones();
	}
	if ((lap % T_MOSUG) == 0)
	{							// activa mostrar elementos sugeridos
		oculta_elementos(mat, pos_sug);
		escribe_matriz(mat);
		muestra_elementos(mat, pos_sug);
		escribe_matriz(mat);
	}
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
	unsigned char level = 0;		// nivel del juego (nivel inicial = 0)
	short points = 0;				// contador de puntos
	unsigned char moves = 0;		// número de movimientos restantes
	unsigned char gelees = 0;		// número de gelatinas restantes
	
	unsigned char state = E_INIT;	// estado actual del programa
	unsigned short lapse = 0;		// contador VBLs inactividad del usuario
	unsigned char ret;				// código de retorno de funciones auxiliares
	unsigned char fall_init = 1;	// código de inicio de caída

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
		switch (state)
		{
			case E_INIT:		//////	ESTADO DE INICIALIZACIÓN	//////
						inicializa_nivel(matrix, level, &points, &moves, &gelees);
						lapse = 0;
						if (hay_secuencia(matrix))	state = E_BREAK;
						else if (!hay_combinacion(matrix))	state = E_CHECK;
						else	state = E_PLAY;
						break;
			case E_PLAY:		//////	ESTADO DE INTERACCIÓN CON USUARIO //////
						if (keysHeld() & KEY_TOUCH)		// detecta pulsación en pantalla
						{
							lapse = 0;				// reinicia tiempo de inactividad
							if (procesa_pulsacion(matrix, points, &moves, gelees))
								state = E_BREAK;	// si hay secuencia, pasa a romperla
						}
						else
						{	lapse++;				// cuenta tiempo (VBLs) de inactividad
							if (lapse >= T_INACT)	// a partir de cierto tiempo de inactividad,
								procesa_sugerencia(matrix, lapse);
						}
						procesa_botonY();
						break;
			case E_BREAK:		//////	ESTADO DE ROMPER SECUENCIAS	//////
						procesa_rotura(matrix, level, &points, moves, &gelees);
						fall_init = 1;
						lapse = 0;
						state = E_FALL;
						break;
			case E_FALL:		//////	ESTADO DE CAÍDA DE ELEMENTOS	//////
						ret = procesa_caida(fall_init, matrix, points, moves, gelees);
											// cuando ya no haya más bajadas,
						if (ret == PC_ENDNOSQ)	state = E_CHECK;		// comprueba situación del juego
						else if (ret == PC_ENDSEQ)	state = E_BREAK;	// o rompe secuencia (si la hay)
						else		// si ha habido algún movimiento de caída, sigue en estado E_FALL,
							fall_init = 0;		// pero desactiva inicio caída para permitir la caída con aceleración
						break;
			case E_CHECK:		//////	ESTADO DE VERIFICACIÓN	//////
						ret = comprueba_jugada(matrix, &level, points, moves, gelees);
						if (ret == CJ_LEVEL)	state = E_INIT;			// nuevo nivel o reiniciar nivel
						else if ((ret == CJ_CONT) || (ret == CJ_RCOMB))	// si no ha pasado nada especial o ha habido recombinación con posible secuencia,
							state = E_PLAY;		//  sigue jugando
						// si ha habido recombinación sin nueva combinación, sigue en estado E_CHECK
						break;
		}
	} while (1);				// bucle infinito
	
	return(0);					// nunca retornará del main
}