module DevReadonlyIO(CLK, RESET, ABUS, DBUS_OUT, IN);
	parameter DBITS;
	parameter IOBITS;
	parameter DEVADDR;
	parameter INIT;
	parameter DEBOUNCE;
	
	input CLK, RESET;
	input [(DBITS - 1) : 0] ABUS;
	input [(IOBITS - 1) : 0] IN;
	output [(DBITS - 1) : 0] DBUS_OUT;
	
	wire doRead = ABUS == DEVADDR;
	wire [(IOBITS - 1) : 0] debounced;
	reg [(IOBITS - 1) : 0] out;
	
	Debouncer #(
		.BITS(IOBITS),
		.INIT(INIT),
		.DEBOUNCE(DEBOUNCE)
	) debouncer (
		.CLK(CLK),
		.RESET(RESET),
		.CUR(IN),
		.OUT(debounced)
	);
	
	always @(debounced)
		out <= debounced;
		
	assign DBUS_OUT = doRead ? {{(DBITS - IOBITS){1'b0}}, out} : {DBITS{1'b0}};
endmodule
