module DevReadonlyIO(CLK, RESET, ABUS, DBUS_OUT, IN);
	parameter DBITS;
	parameter IOBITS;
	parameter DEVADDR;
	parameter CTRLADDR;
	parameter INIT;
	parameter DEBOUNCE;
	
	input CLK, RESET;
	input [(DBITS - 1) : 0] ABUS;
	input [(IOBITS - 1) : 0] IN;
	output [(DBITS - 1) : 0] DBUS_OUT;
	
	reg [(DBITS - 1) : 0] debounceCount;
	reg [(IOBITS - 1) : 0] debounced;
	reg ready, overflow;
	
	wire [(DBITS - 1) : 0] data = {{(DBITS - IOBITS){1'b0}}, debounced};
	wire [(DBITS - 1) : 0] ctrl = {{(DBITS - 2){1'b0}}, overflow, ready};
	
	wire bounce = debounced != IN;
	wire dataActive = ABUS == DEVADDR;
	wire ctrlActive = ABUS == CTRLADDR;
	wire readData = !WE && dataActive;
	wire readCtrl = !WE && ctrlActive;
	wire writeCtrl = WE && ctrlActive;
	
	always @(posedge CLK or posedge RESET)
		if (RESET) begin
			debounced <= INIT;
			debounceCount <= 0;
			ready = 1'b0;
			overflow = 1'b0;
		end else begin
			if (debounceCount == DEBOUNCE - 1) begin
				debounced <= IN;
				ready = 1'b1;
				
				if (ready)
					overflow <= 1'b1;
			end else if (bounce)
				debounceCount <= 0;
			else
				debounceCount <= debounceCount + 1;
			
			if (readData) begin
				ready = 1'b0;
				overflow = 1'b0;
			end else if (writeCtrl)
				if (!DBUS_IN[1])
					overflow = 1'b0
		end

	assign DBUS_OUT = readData ? data : readCtrl ? ctrl : {DBITS{1'b0}};
endmodule
