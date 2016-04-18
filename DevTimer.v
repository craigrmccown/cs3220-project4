module DevTimer(CLK, RESET, ABUS, WE, DBUS_IN, DBUS_OUT);
	parameter DBITS;
	parameter LIMADDR;
	parameter CNTADDR;
	parameter CTRLADDR;
	parameter MSTICKS;
	
	input CLK, RESET, WE;
	input [(DBITS - 1) : 0] ABUS;
	input [(DBITS - 1) : 0] DBUS_IN;
	output [(DBITS - 1) : 0] DBUS_OUT;
	
	reg [(DBITS - 1) : 0] lim;
	reg [(DBITS - 1) : 0] cnt;
	reg [(DBITS - 1) : 0] ticks;
	reg ready, overflow;
	
	wire [(DBITS - 1) : 0] ctrl = {{(DBITS - 2){1'b0}}, overflow, ready};
	
	wire limActive = ABUS == LIMADDR;
	wire cntActive = ABUS == CNTADDR;
	wire ctrlActive = ABUS == CTRLADDR;
	
	wire readLim = !WE && limActive;
	wire writeLim = WE && limActive;
	wire readCnt = !WE && cntActive;
	wire writeCnt = WE && cntActive;
	wire readCtrl = !WE && ctrlActive;
	wire writeCtrl = WE && ctrlActive;
	
	wire ticksReached = ticks == (MSTICKS - 1);
	wire limReached = cnt == (lim - {{(DBITS - 1){1'b0}}, 1'b1});
	
	always @(posedge CLK or posedge RESET) begin
		if (RESET) begin
			lim <= {DBITS{1'b0}};
			cnt <= {DBITS{1'b0}};
			ticks <= {DBITS{1'b0}};
			ready <= 1'b0;
			overflow <= 1'b0;
		end else begin
			if (writeLim) begin
				lim <= DBUS_IN;
				cnt <= {DBITS{1'b0}};
				ticks <= {DBITS{1'b0}};
			end else if (writeCnt) begin
				cnt <= DBUS_IN;
				ticks <= {DBITS{1'b0}};
			end else if (writeCtrl)
				{overflow, ready} <= DBUS_IN[1 : 0];
			else if (ticksReached) begin
				ticks <= {DBITS{1'b0}};
				
				if (limReached)
					cnt <= {DBITS{1'b0}};
					ready <= 1'b1;
					
					if (ready)
						overflow <= 1'b1;
				else
					cnt <= cnt + {{(DBITS - 1){1'b0}}, 1'b1};
			end else
				ticks <= ticks + {{(DBITS - 1){1'b0}}, 1'b1};
		end
	end

	assign DBUS_OUT =
		readLim ? lim :
		readCnt ? cnt :
		readCtrl ? ctrl : {DBITS{1'b0}};
endmodule
