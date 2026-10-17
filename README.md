REPORTE TÉCNICO
ACTIVIDAD 4 - MEMORIAS E INSTRUCCIONES
ARQUITECTURA DE COMPUTADORAS 

INTEGRANTES (EQUIPO DINAMITA):
TORRES NAVARRO IVAN
FERNANDO GODINEZ CISNEROS
MIGUEL GABRIEL BIBIANO MENDOZA


-1. CONTEXTO GENERAL
--------------------

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



-2. ARCHIVOS
------------

 | Archivo             |  Módulo              | Tipo
  -------------------- | -------------------  |------------------------------
 | ROM_Instrucciones.v |  ROM_Instrucciones   | Diseño (memoria de solo lectura)
 | RORO_Supreme.v      |  RORO_Supreme        | Diseño (módulo superior)
 | RORO_Supreme_tb.v   |  RORO_Supreme_tb     | Testbench del sistema
 | RORO_tb.v           |  RORO_tb             | Testbench de RORO solo



-3. FORMATO DE INSTRUCCIÓN 
--------------------------

El testbench de RORO arma cada instrucción como:

      instruccion = { op[i], i[3:0], i[3:0] }     -> 4 + 4 + 4 = 12 bits

   bit:  11 10  9  8 | 7  6  5  4 | 3  2  1  0
        [   OPCODE   ] [  CAMPO A ] [  CAMPO B ]

  - Bits [11:8] = código de operación (4 bits).
  - Bits [7:4]  = campo A (4 bits).
  - Bits [3:0]  = campo B (4 bits).

Qué significan A y B (valor inmediato, dirección de registro, etc.)



-4 ANÁLISIS DE CÓDIGO
---------------------

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

------------------------------------------------------------------------------
-5. RESULTADOS ESPERADOS (definidos en los testbenches)
------------------------------------------------------------------------------
Instrucción = {op, i, i}. Estas 16 filas valen para ambos testbenches (en
RORO_tb se inyecta la instrucción; en RORO_Supreme_tb sale de la ROM).
 
 |i   |op   |Instrucción (bin)|   Hex   |DD esperado (dec)|   DD (hex)  | ZF  |
 |----|-----|-----------------|---------|-----------------|-------------|-----|
 |0   | 2   |0010 0000 0000   |  200    |17               |    00000011 |   0 |
 |----|-----|-----------------|---------|-----------------|-------------|-----|
 |1   | 2   |0010 0001 0001   |  211    |21               |    00000015 |   0 |
 |----|-----|-----------------|---------|-----------------|-------------|-----|
 |2   | 2   |0010 0010 0010   |  222    |35               |    00000023 |   0 |
 |----|-----|-----------------|---------|-----------------|-------------|-----|
 |3   | 2   |0010 0011 0011   |  233    |12               |    0000000C |   0 |
 |----|-----|-----------------|---------|-----------------|-------------|-----|
 |4   | 2   |0010 0100 0100   |  244    |60               |    0000003C |   0 |
 |----|-----|-----------------|---------|-----------------|-------------|-----|
 |5   | 2   |0010 0101 0101   |  255    |48               |    00000030 |   0 |
 |----|-----|-----------------|---------|-----------------|-------------|-----|
 |6   | 6   |0110 0110 0110   |  666    |0                |    00000000 |   1 |
 |----|-----|-----------------|---------|-----------------|-------------|-----|
 |7   | 6   |0110 0111 0111   |  677    |9                |    00000009 |   0 | 
 |----|-----|-----------------|---------|-----------------|-------------|-----|
 |8   | 6   |0110 1000 1000   |  688    |51               |    00000033 |   0 |
 |----|-----|-----------------|---------|-----------------|-------------|-----|
 |9   | 6   |0110 1001 1001   |  699    |-41 (compl. a 2) |    FFFFFFD7 |   0 |
 |----|-----|-----------------|---------|-----------------|-------------|-----|
 |10  | 6   |0110 1010 1010   |  6AA    |97               |    00000061 |   0 |
 |----|-----|-----------------|---------|-----------------|-------------|-----|
 |11  | 6   |0110 1011 1011   |  6BB    |0                |    00000000 |   1 |
 |----|-----|-----------------|---------|-----------------|-------------|-----|
 |12  | 7   |0111 1100 1100   |  7CC    |0                |    00000000 |   1 |
 |----|-----|-----------------|---------|-----------------|-------------|-----|
 |13  | 7   |0111 1101 1101   |  7DD    |0                |    00000000 |   1 |
 |----|-----|-----------------|---------|-----------------|-------------|-----|
 |14  | 7   |0111 1110 1110   |  7EE    |1                |    00000001 |   0 |
 |----|-----|-----------------|---------|-----------------|-------------|-----|
 |15  | 7   |0111 1111 1111   |  7FF    |0                |    00000000 |   1 |
 |----|-----|-----------------|---------|-----------------|-------------|-----|
 
-6 CONCLUSIONES
------------------------------------------------------------------------------
  - Los cuatro códigos forman un sistema combinacional de dos capas: una ROM
    de 16 x 12 bits que alimenta a la unidad RORO (12 bits de entrada, 32 bits
    de resultado, bandera ZF).
  - Los testbenches son autoverificables y usan la misma tabla de 16
    resultados esperados, lo que permite separar fallos de la unidad (RORO_tb)
    de fallos de integración o de carga de la ROM (RORO_Supreme_tb).
  - Los resultados esperados incluyen sumas, restas (con un resultado negativo,
    -41) y comparaciones, con ZF activo en 5 de los 16 casos.
