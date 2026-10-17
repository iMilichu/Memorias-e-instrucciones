`timescale 1ns/1ns
module RORO_tb;

reg  [11:0]instruccion;
wire [31:0]resultado;
wire ZF;

reg [31:0] esperado [0:15];
reg [3:0]  op [0:15];
integer i, errores;

RORO uut(.instruccion(instruccion), .resultado(resultado), .ZF(ZF));

initial
begin
	esperado[0]=17;  esperado[1]=21;  esperado[2]=35;  esperado[3]=12;
	esperado[4]=60;  esperado[5]=48;  esperado[6]=0;   esperado[7]=9;
	esperado[8]=51;  esperado[9]=32'hFFFFFFD7; esperado[10]=97; esperado[11]=0;
	esperado[12]=0;  esperado[13]=0;  esperado[14]=1;  esperado[15]=0;
	for (i=0; i<6;  i=i+1) op[i]=4'd2;
	for (i=6; i<12; i=i+1) op[i]=4'd6;
	for (i=12;i<16; i=i+1) op[i]=4'd7;

	errores = 0;
	for (i=0; i<16; i=i+1)
	begin
		instruccion = {op[i], i[3:0], i[3:0]};
		#10;
		if (resultado === esperado[i] && ZF === (esperado[i]==0))
			$display("Caso %0d: PASS  DD=%0d ZF=%b", i, resultado, ZF);
		else
		begin
			$display("Caso %0d: FAIL  DD=%0d (esperado %0d) ZF=%b", i, resultado, esperado[i], ZF);
			errores = errores + 1;
		end
	end
	if (errores==0) $display("RORO_tb: TODOS PASS");
	else $display("RORO_tb: %0d FAIL", errores);
	$finish;
end

endmodule
