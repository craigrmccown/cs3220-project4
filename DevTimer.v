module DevTimer(CLK, RESET, ABUS, DBUS, WE);
	parameter DBITS;
	parameter LIMADDR;
	parameter CNTADDR;
	
	input CLK, RESET, WE;
	input [(DBITS - 1) : 0] ABUS;
	inout [(DBITS - 1) : 0] DBUS;
	
	reg [(DBITS - 1) : 0] lim;
	reg [(DBITS - 1) : 0] cnt;
	wire limActive = ABUS == LIMADDR;
	wire cntActive = ABUS == CNTADDR;
	wire readLim = !WE && limActive;
	wire writeLim = WE && limActive;
	wire readCnt = !WE && cntActive;
	wire writeCnt = WE && cntActive;
	wire limReached = cnt == (lim - 1) && lim != 0;
	
	always @(posedge CLK or posedge RESET) begin
		if (RESET) begin
			lim <= 0;
			cnt <= 0;
		end else begin
			if (writeLim) begin
				lim <= DBUS;
				cnt <= 0;
			end else if (writeCnt) begin
				cnt <= DBUS;
			end
			
			if (limReached) begin
				cnt <= 0;
			end else begin
				cnt <= cnt + 1;
			end
		end
	end

	assign DBUS = readLim ? lim : readCnt ? cnt : {DBITS{1'bz}};
endmodule
