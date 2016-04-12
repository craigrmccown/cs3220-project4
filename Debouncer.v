module Debouncer(CLK, RESET, CUR, OUT);
	parameter BITS;
	parameter INIT;
	parameter DEBOUNCE;
	
	input CLK, RESET;
	input [(BITS - 1) : 0] CUR;
	output [(BITS - 1) : 0] OUT;
	
	reg [(BITS - 1) : 0] old;
	reg [31 : 0] debounce;
	wire bounce = CUR != old;
	
	always @(posedge CLK or posedge RESET)
		if (RESET) begin
			old <= INIT;
			debounce <= 0;
		end else if (debounce == DEBOUNCE - 1)
			old <= CUR;
		else if (bounce)
			debounce <= 0;
		else
			debounce <= debounce + 1;
			
	assign OUT = old;
endmodule
