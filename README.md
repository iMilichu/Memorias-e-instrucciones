REPORTE TÉCNICO
ACTIVIDAD 4 - MEMORIAS E INSTRUCCIONES
ARQUITECTURA DE COMPUTADORAS 

INTEGRANTES:
TORRES NAVARRO IVAN
FERNANDO GODINEZ CISNEROS
MIGUEL GABRIEL BIBIANO MENDOZA


1. CONTEXTO GENERAL

Los cuatro códigos forman un pequeño sistema de ejecución de instrucciones sin
reloj (puramente combinacional), construido en dos niveles:

  Nivel 1 (unidad funcional): RORO
      Recibe una instrucción de 12 bits y produce un resultado de 32 bits y
      una bandera de cero (ZF).

  Nivel 2 (sistema): RORO_Supreme
      Antepone una memoria ROM de 16 instrucciones. Con solo una dirección
      de 4 bits se "lee" una instrucción y se ejecuta en RORO.

Verificación en dos pasos:
  - RORO_tb         prueba RORO de forma aislada, inyectando las instrucciones
                    directamente.
  - RORO_Supreme_tb prueba el sistema completo, leyendo las MISMAS 16
                    instrucciones desde la ROM, y compara contra la MISMA
                    tabla de resultados esperados.

Idea de fondo: si RORO_tb pasa, RORO es correcto; si además RORO_Supreme_tb
pasa, la ROM está bien cargada y bien conectada.



2. ARCHIVOS

  Archivo               Módulo               Tipo
  --------------------  -------------------  ------------------------------
  ROM_Instrucciones.v   ROM_Instrucciones    Diseño (memoria de solo lectura)
  RORO_Supreme.v        RORO_Supreme         Diseño (módulo superior)
  RORO_Supreme_tb.v     RORO_Supreme_tb      Testbench del sistema
  RORO_tb.v             RORO_tb              Testbench de RORO solo



3. FORMATO DE INSTRUCCIÓN 

El testbench de RORO arma cada instrucción como:

      instruccion = { op[i], i[3:0], i[3:0] }     -> 4 + 4 + 4 = 12 bits

   bit:  11 10  9  8 | 7  6  5  4 | 3  2  1  0
        [   OPCODE   ] [  CAMPO A ] [  CAMPO B ]

  - Bits [11:8] = código de operación (4 bits).
  - Bits [7:4]  = campo A (4 bits).
  - Bits [3:0]  = campo B (4 bits).

Qué significan A y B (valor inmediato, dirección de registro, etc.)



4. ANÁLISIS DE CÓDIGO


4.1 ROM_Instrucciones.v
-----------------------
Propósito: memoria de solo lectura de 16 posiciones x 12 bits que almacena el
"programa" de prueba.

Estructura:
  - Entrada  Dir[3:0]          : dirección (2^4 = 16 posiciones, cubre todo
                                 el arreglo, sin direcciones fuera de rango).
  - Salida   Instruccion[11:0] : palabra almacenada en esa dirección.
  - reg [11:0] mem [0:15]      : arreglo de 16 palabras de 12 bits.
  - assign Instruccion = mem[Dir]
                               : lectura ASÍNCRONA y combinacional (sin reloj;
                                 la salida cambia en cuanto cambia Dir).
  - initial $readmemb("instrucciones.txt", mem)
                               : al iniciar la simulación carga el contenido
                                 desde un archivo de texto en BINARIO
                                 ($readmemb = binario; $readmemh = hexadecimal).

4.2 RORO_Supreme.v
------------------
Propósito: módulo superior que conecta la ROM con RORO.

Estructura:
  - Entrada  DirInst[3:0] : dirección de instrucción (la controla el testbench).
  - Salida   DD[31:0]     : resultado de la ejecución (nombre "DD" tal como
                            aparece en el código).
  - Salida   ZF           : bandera de cero.
  - wire [11:0] instr     : cable interno ROM -> RORO.
  - Instancia ROMi (ROM_Instrucciones): .Dir(DirInst), .Instruccion(instr)
  - Instancia R    (RORO)             : .instruccion(instr), .resultado(DD),
                                        .ZF(ZF)


4.3 RORO_tb.v  (testbench de la unidad RORO)
--------------------------------------------
Propósito: probar RORO de forma aislada, sin ROM.

Estructura:
  - timescale 1ns/1ns.
  - Instancia uut = RORO.
  - Arreglo esperado[0:15] (32 bits): resultado correcto de cada caso.
  - Arreglo op[0:15] (4 bits): código de operación de cada caso:
        casos  0 a  5  -> op = 2   (6 casos)
        casos  6 a 11  -> op = 6   (6 casos)
        casos 12 a 15  -> op = 7   (4 casos)
  - Ciclo for i = 0..15:
        instruccion = {op[i], i[3:0], i[3:0]};
        #10;                       (espera 10 ns a que se estabilice)
        compara y muestra PASS o FAIL.
  - Criterio de acierto (operador === para detectar también X y Z):
        resultado === esperado[i]  &&  ZF === (esperado[i] == 0)
    Es decir, verifica el valor Y que ZF sea 1 exactamente cuando el resultado
    es cero.
  - Cierre: "RORO_tb: TODOS PASS" o "RORO_tb: N FAIL"; luego $finish.


4.4 RORO_Supreme_tb.v  (testbench del sistema completo)
-------------------------------------------------------
Propósito: probar ROM + RORO integrados.

Diferencias con RORO_tb:
  - Instancia RORO_Supreme (uut) con .DirInst(DirInst), .DD(DD), .ZF(ZF).
  - El estímulo es la DIRECCIÓN (DirInst = i), no la instrucción: la
    instrucción sale de la ROM.
  - Misma tabla esperado[0:15] y mismo criterio === que RORO_tb.
  - Mensajes con "Instr N" en lugar de "Caso N"; resumen final
    "RORO_Supreme_tb: 16/16 PASS" o "RORO_Supreme_tb: N FAIL".

Cualquier X en DD o ZF (por ejemplo, ROM sin cargar) hace fallar la
comparación con ===, por lo que el testbench detecta ese error.


5. CONCLUSIONES
------------------------------------------------------------------------------
  - Los cuatro códigos forman un sistema combinacional de dos capas: una ROM
    de 16 x 12 bits que alimenta a la unidad RORO (12 bits de entrada, 32 bits
    de resultado, bandera ZF).
  - Los testbenches son autoverificables y usan la misma tabla de 16
    resultados esperados, lo que permite separar fallos de la unidad (RORO_tb)
    de fallos de integración o de carga de la ROM (RORO_Supreme_tb).
  - Los resultados esperados incluyen sumas, restas (con un resultado negativo,
    -41) y comparaciones, con ZF activo en 5 de los 16 casos.
