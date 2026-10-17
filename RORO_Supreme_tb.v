`timescale 1ns/1ns
module RORO_Supreme_tb;

reg  [3:0]DirInst;
wire [31:0]DD;
wire ZF;

reg [31:0] esperado [0:15];
integer i, errores;

RORO_Supreme uut(.DirInst(DirInst), .DD(DD), .ZF(ZF));

initial
begin
	esperado[0]=17;  esperado[1]=21;  esperado[2]=35;  esperado[3]=12;
	esperado[4]=60;  esperado[5]=48;  esperado[6]=0;   esperado[7]=9;
	esperado[8]=51;  esperado[9]=32'hFFFFFFD7; esperado[10]=97; esperado[11]=0;
	esperado[12]=0;  esperado[13]=0;  esperado[14]=1;  esperado[15]=0;

	errores = 0;
	for (i=0; i<16; i=i+1)
	begin
		DirInst = i[3:0];
		#10;
		if (DD === esperado[i] && ZF === (esperado[i]==0))
			$display("Instr %0d: PASS  DD=%0d ZF=%b", i, DD, ZF);
		else
		begin
			$display("Instr %0d: FAIL  DD=%0d (esperado %0d) ZF=%b", i, DD, esperado[i], ZF);
			errores = errores + 1;
		end
	end
	if (errores==0) $display("RORO_Supreme_tb: 16/16 PASS");
	else $display("RORO_Supreme_tb: %0d FAIL", errores);
	$finish;
end

endmodule
