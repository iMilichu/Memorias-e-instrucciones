// Modulo superior: ROM de instrucciones + RORO
// La direccion de instruccion la controla el testbench (sin contador de programa)
module RORO_Supreme(
	input [3:0]DirInst,
	output [31:0]DD,
	output ZF
);

wire [11:0]instr;

ROM_Instrucciones ROMi(
	.Dir(DirInst),
	.Instruccion(instr)
);

RORO R(
	.instruccion(instr),
	.resultado(DD),
	.ZF(ZF)
);

endmodule
