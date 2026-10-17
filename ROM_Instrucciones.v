// ROM de instrucciones: 16 posiciones x 12 bits
module ROM_Instrucciones(
	input [3:0]Dir,
	output [11:0]Instruccion
);

reg [11:0] mem [0:15];

assign Instruccion = mem[Dir];

initial
begin
	$readmemb("instrucciones.txt", mem);
end

endmodule
