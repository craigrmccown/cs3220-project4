module DevTimer(CLK, RESET, ABUS, WE, DBUS_IN, DBUS_OUT);
	parameter DBITS;
	parameter LIMADDR;
	parameter CNTADDR;
	parameter CTRLADDR;
	parameter MSTICKS;
	
	input CLK, RESET, WE;
	input [(DBITS - 1) : 0] ABUS, DBUS_IN;
	output [(DBITS - 1) : 0] DBUS_OUT;
	
	reg [(DBITS - 1) : 0] limit, count, ticks;
	reg ready, overflow;
	
	wire [(DBITS - 1) : 0] ctrl = {{(DBITS - 2){1'b0}}, overflow, ready};
	
	wire limitActive = ABUS == LIMADDR;
	wire countActive = ABUS == CNTADDR;
	wire ctrlActive = ABUS == CTRLADDR;
	
	wire readLimit = !WE && limitActive;
	wire writeLimit = WE && limitActive;
	wire readCount = !WE && countActive;
	wire writeCount = WE && countActive;
	wire readCtrl = !WE && ctrlActive;
	wire writeCtrl = WE && ctrlActive;
	
	always @(posedge CLK or posedge RESET) begin
		if (RESET) begin
			ticks <= 0;
			count <= 0;
			limit <= 0;
			ready <= 1'b0;
			overflow <= 1'b0;
		end else begin
			if (writeLimit) begin
				limit <= DBUS_IN;
				count <= 0;
				ticks <= 0;
			end else if (writeCount) begin
				count <= DBUS_IN;
				ticks <= 0;
			end else begin
				if (ticks == (MSTICKS - 1)) begin
					ticks <= 0;
					
					if (count == (limit - 1) && limit != 0) begin
						count <= 0;
						ready <= 1'b1;
						
						if (ready)
							overflow <= 1'b1;
					end else begin
						count <= count + 1;
					end
				end else begin
					ticks <= ticks + 1;
				end
				
				if (writeCtrl) begin
					if (!DBUS_IN[0])
						ready <= 1'b0;
						
					if (!DBUS_IN[1])
						overflow <= 1'b0;
				end else if (readCount) begin
					ready <= 1'b0;
					overflow <= 1'b0;
				end
			end
		end
	end

	assign DBUS_OUT =
		readLimit ? limit :
		readCount ? count :
		readCtrl ? ctrl : {DBITS{1'b0}};
endmodule
