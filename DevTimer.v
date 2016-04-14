module DevTimer(CLK, RESET, ABUS, DBUS_IN, DBUS_OUT, WE);
	parameter DBITS;
	parameter LIMADDR;
	parameter CNTADDR;
	parameter MSTICKS;
	
	input CLK, RESET, WE;
	input [(DBITS - 1) : 0] ABUS;
	input [(DBITS - 1) : 0] DBUS_IN;
	output [(DBITS - 1) : 0] DBUS_OUT;
	
	reg [(DBITS - 1) : 0] lim;
	reg [(DBITS - 1) : 0] cnt;
	reg [(DBITS - 1) : 0] ticks;
	
	wire limActive = ABUS == LIMADDR;
	wire cntActive = ABUS == CNTADDR;
	wire readLim = !WE && limActive;
	wire writeLim = WE && limActive;
	wire readCnt = !WE && cntActive;
	wire writeCnt = WE && cntActive;
	wire ticksReached = ticks == (MSTICKS - 1);
	wire limReached = cnt == (lim - 1) && lim != 0;
	
	always @(posedge CLK or posedge RESET) begin
		if (RESET) begin
			lim <= 0;
			cnt <= 0;
			ticks <= 0;
		end else begin
			if (writeLim) begin
				lim <= DBUS_IN;
				cnt <= 0;
				ticks <= 0;
			end else if (writeCnt) begin
				cnt <= DBUS_IN;
				ticks <= 0;
			end
			
			if (ticksReached) begin
				cnt <= cnt + 1;
				ticks <= 0;
			end else begin
				ticks <= ticks + 1;
			end
			
			if (limReached) begin
				cnt <= 0;
				ticks <= 0;
			end
		end
	end

	assign DBUS_OUT = readLim ? lim : (readCnt ? cnt : {DBITS{1'b0}});
endmodule
