/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 11/02/2019
Configuracion: PIC18F25k22 XT=20MHz
Observaciones:

---------------------------------------------------------------------------------------------------------------------------*/

/////////////////////////// Formato de la trama de datos //////////////////////////
//|                   Cabecera                  |      Datos     |      Fin      |
//|                    5 bytes                  |   2400 bytes   |    2 bytes    |
//|  3Ah   |   A�o   |   Dia  |  Hora  | Minuto |      DataN     |  0Dh  |  0Ah  |
//|   0    |    1    |    2   |    3   |   4    |     5-2404     |  2405 |  2406 |


//////////////////////////////////////////////////// Declaracion de variables //////////////////////////////////////////////////////////////
//Variables y contantes para la peticion y respuesta de datos
sbit AUX at RB3_bit;                                    //Definicion del pin de indicador auxiliar para hacer pruebas
sbit AUX_Direction at TRISB3_bit;
sbit P1 at RB4_bit;                                     //Definicion del pin P1
sbit P1_Direction at TRISB4_bit;
sbit P2 at RB5_bit;                                     //Definicion del pin P2
sbit P2_Direction at TRISB5_bit;

const short HDR = 0x3A;                                 //Constante de delimitador de inicio de trama
const short END1 = 0x0D;                                //Constante de delimitador 1 de final de trama
const short END2 = 0x0A;                                //Constante de delimitador 2 de final de trama
const unsigned short NUM_MUESTRAS = 199;                //Constantes para almacenar el numero de muestras que se van a enviar en la interrupcion P2

unsigned char cabecera[5];                              //Vector para almacenar los datos de la cabecera
unsigned char datos[10];                                //Vector para almacenar los datos de payload
unsigned char pduSPI[15];                               //Vector de trama de datos del puerto UART2

unsigned short i, x;
unsigned short  buffer;
unsigned short contMuestras;

unsigned short banTC, banTI, banTF;                     //Banderas de trama completa, inicio de trama y final de trama

unsigned short  banResp, banSPI, banLec, banEsc;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////// Declaracion de constantes /////////////////////////////////////////////////////////////
/*const char datosAcelerometro[]=
{
 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,1,
 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,2,
 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,3,
 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,4,
 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,5,
 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,6,
 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,7,
 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,8,
 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,9,
 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,10,
 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,11,
 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,12
};*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////// Funciones ////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Funcion para realizar la Configuracion de parametros
void ConfiguracionPrincipal(){

     ANSELA = 0;
     ANSELB = 0;                                        //Configura PORTB como digital
     ANSELC = 0;                                        //Configura PORTC como digital

     TRISB0_bit = 1;                                    //Configura el pin B1 como entrada
     TRISB3_bit = 0;                                    //Configura el pin B3 como salida
     TRISB4_bit = 0;                                    //Configura el pin B4 como salida
     TRISB5_bit = 0;                                    //Configura el pin B4 como salida

     RCON.IPEN = 0;                                     //Importante: Parece ser el origen del problema de que solo funcionaba cuando se reseteaba el PIC
     INTCON.GIE = 1;                                    //Habilita las interrupciones globales
     INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas

     //Configuracion del puerto SPI en modo Esclavo
     SPI1_Init_Advanced(_SPI_SLAVE_SS_ENABLE,_SPI_DATA_SAMPLE_END,_SPI_CLK_IDLE_HIGH,_SPI_HIGH_2_LOW);
     PIE1.SSP1IE = 1;                                   //Habilita la interrupcion por SPI
     PIR1.SSP1IF = 0;                                   //Limpia la bandera de interrupcion por SPI
     
     //Configuracion de la interrupcion externa (simula la una peticion)
     INTCON.INT0IE = 1;                                 //Habilita la interrupcion externa INT0
     INTCON.INT0IF = 0;                                 //Limpia la bandera de interrupcion externa INT0
     
     //Configuracion del TMR2 con un tiempo de 5ms
     //T2CON = 0x36;                                     //Timer2 Output Postscaler Select bits
     //PR2 = 223;
     T2CON = 0x36;                                      //Timer2 Output Postscaler Select bits
     PR2 = 222;
     PIR1.TMR2IF = 0;                                   //Limpia la bandera de interrupcion del TMR2
     PIE1.TMR2IE = 1;                                   //Habilita la interrupci�n de desbordamiento TMR2

     Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void pulsoAux(){

     AUX = 1;
     Delay_us(1);
     AUX = 0;

}


////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////
void interrupt(void){

//Interrupcion SPI
     if (PIR1.SSP1IF==1){

        PIR1.SSP1IF = 0;                                //Limpia la bandera de interrupcion por SPI
        buffer = SSP1BUF;                               //Guarda el contenido del bufeer (lectura)
        
        //Rutina para procesar la trama de solicitud de lectura desde la RPi
        if ((banTI==1)){                                //Verifica si la bandera de inicio de trama esta activa
           banLec = 1;                                  //Activa la bandera de lectura
           banTI = 0;
           i = 0;
           SSP1BUF = pduSPI[i];
        }
        if ((banLec==1)&&(buffer!=0xB1)){
           SSP1BUF = pduSPI[i];
           i++;
        }
        if ((banLec==1)&&(buffer==0xB1)){               //Si detecta el delimitador de final de trama:
           banLec = 0;                                  //Limpia la bandera de lectura
           banTI = 0;
           SSP1BUF = 0xFF;
        }
        

        
     }
     
//Interrupcion Externa 0

     if (INTCON.INT0IF==1){
        INTCON.INT0IF = 0;                              //Limpia la badera de interrupcion externa
        contMuestras = 0;                               //Limpia el contador de muestras
        datos[0] = contMuestras;                        //Carga el primer valor de la trama de datos con el valor de la muestra actual
        for (x=0;x<10;x++){
            pduSPI[x]=datos[x];                         //Carga el vector de salida de datos SPI con los datos de simulacion de muestreo
        }
        banTI = 1;                                      //Activa la bandera de inicio de trama
        P1 = 1;                                         //Genera el pulso P1 para producir la interrupcion en la RPi
        Delay_us(20);
        P1 = 0;
        T2CON.TMR2ON = 1;                               //Enciende el Timer2
        PR2 = 222;                                      //Se carga el valor del preload correspondiente al tiempo de 5ms
     }
     
//Interrupcion por TIMER2

     if (TMR2IF_bit==1){
        TMR2IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR2
        contMuestras++;                                 //Incrementa el contador de muestras
        datos[0] = contMuestras;                        //Carga el primer valor de la trama de datos con el valor de la muestra actual
        for (x=0;x<10;x++){
            pduSPI[x]=datos[x];                         //Carga el vector de salida de datos SPI con los datos de simulacion de muestreo
        }
        if (contMuestras==NUM_MUESTRAS){
           T2CON.TMR2ON = 0;                            //Apaga el Timer2
           for (x=10;x<15;x++){
               pduSPI[x]=cabecera[x-10];                //Carga el vector de salida de datos SPI con los datos de la cabecera
           }
        }
        banTI = 1;                                      //Activa la bandera de inicio de trama
        P2 = 1;                                         //Genera el pulso P2 para producir la interrupcion en la RPi
        Delay_us(20);
        P2 = 0;
     }

}


void main() {

     ConfiguracionPrincipal();
     
     cabecera[0] = 19;                                  //A�o
     cabecera[1] = 49;                                  //Dia
     cabecera[2] = 9;                                   //Hora
     cabecera[3] = 30;                                  //Minuto
     cabecera[4] = 0;                                   //Segundo
     
     datos[1] = 11;
     datos[2] = 12;
     datos[3] = 13;
     datos[4] = 21;
     datos[5] = 22;
     datos[6] = 23;
     datos[7] = 31;
     datos[8] = 32;
     datos[9] = 33;
     
     
     
     
     banTI = 0;
     banLec = 0;
     i = 0;
     x = 0;
     AUX = 0;
     
     contMuestras = 0;
     P1 = 0;
     P2 = 0;
     
     SSP1BUF = 0xFF;
     
     while(1){
    
              Delay_ms(500);
     
     }
     

}