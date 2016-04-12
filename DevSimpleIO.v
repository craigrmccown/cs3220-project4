module DevSimpleIO(CLK, RESET, ABUS, DBUS, WE, OUT);
	parameter DBITS;
	parameter IOBITS;
	parameter DEVADDR;
	parameter INIT;
	
	input CLK, RESET, WE;
	input [(DBITS - 1) : 0] ABUS;
	inout [(DBITS - 1) : 0] DBUS;
	output [(IOBITS - 1) : 0] OUT;
	
	reg [(IOBITS - 1) : 0] out;
	wire active = ABUS == DEVADDR;
	wire doRead = !WE && active;
	wire doWrite = WE && active;
	
	always @(posedge CLK or posedge RESET)
		if (RESET)
			out <= INIT;
		else if (doWrite)
			out <= DBUS[(IOBITS - 1) : 0];
		
	assign DBUS = doRead ? {{(DBITS - IOBITS){1'b0}}, out} : {DBITS{1'bz}};
	assign OUT = out;
endmodule
