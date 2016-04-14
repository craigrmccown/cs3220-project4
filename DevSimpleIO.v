module DevSimpleIO(CLK, RESET, ABUS, DBUS_IN, DBUS_OUT, WE, VAL);
	parameter DBITS;
	parameter IOBITS;
	parameter DEVADDR;
	parameter INIT;
	
	input CLK, RESET, WE;
	input [(DBITS - 1) : 0] ABUS;
	input [(DBITS - 1) : 0] DBUS_IN;
	output [(DBITS - 1) : 0] DBUS_OUT;
	output [(IOBITS - 1) : 0] VAL;
	
	reg [(IOBITS - 1) : 0] val;
	wire active = ABUS == DEVADDR;
	wire doRead = !WE && active;
	wire doWrite = WE && active;
	
	always @(posedge CLK or posedge RESET)
		if (RESET)
			val <= INIT;
		else if (doWrite)
			val <= DBUS_IN[(IOBITS - 1) : 0];
		
	assign DBUS_OUT = doRead ? {{(DBITS - IOBITS){1'b0}}, val} : {DBITS{1'b0}};
	assign VAL = val;
endmodule
