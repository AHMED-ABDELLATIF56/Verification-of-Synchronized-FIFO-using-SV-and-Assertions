module FIFO_dut (FIFO_if.DUT F);
	
	localparam max_fifo_addr = $clog2(F.FIFO_DEPTH);

	reg [F.FIFO_WIDTH-1:0] mem [F.FIFO_DEPTH-1:0];

	reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
	reg [max_fifo_addr:0] count;

	always @(posedge F.clk or negedge F.rst_n) begin
		if (!F.rst_n) begin
			wr_ptr <= 0;
			F.overflow <= 0;
		end
		else if (F.wr_en && count < F.FIFO_DEPTH) begin 
			mem[wr_ptr] <= F.data_in;
			wr_ptr <= wr_ptr + 1;
			F.wr_ack <= 1;
		end
		else begin 
			F.wr_ack <= 0; 
			if (F.full & F.wr_en)
				F.overflow <= 1;
			else
				F.overflow <= 0;
		end
	end

	always @(posedge F.clk or negedge F.rst_n) begin
		if (!F.rst_n) begin
			rd_ptr <= 0;
			F.underflow <= 0;
		end
		else if (F.rd_en && count != 0) begin
			F.data_out <= mem[rd_ptr];
			rd_ptr <= rd_ptr + 1;
		end else begin
			if (F.empty && F.rd_en)
				F.underflow <= 1;
			else
				F.underflow <= 0;
		end
	end

	always @(posedge F.clk or negedge F.rst_n) begin
		if (!F.rst_n) begin
			count <= 0;
		end
		else begin
			if	( ({F.wr_en, F.rd_en} == 2'b10) && !F.full) 
				count <= count + 1;
			else if ( ({F.wr_en, F.rd_en} == 2'b01) && !F.empty)
				count <= count - 1;
			else if (({F.wr_en, F.rd_en} == 2'b11) && F.empty) 
				count <= count + 1;
			else if (({F.wr_en, F.rd_en} == 2'b11) && F.full) 
				count <= count - 1;
		end
	end

	assign F.full = (count == F.FIFO_DEPTH)? 1 : 0;
	assign F.empty = (count == 0)? 1 : 0;
	assign F.almostfull = (count == F.FIFO_DEPTH-1)? 1 : 0; 
	assign F.almostempty = (count == 1)? 1 : 0;

	// Assertions
	// full flag
	assert property (@(posedge F.clk) (count == F.FIFO_DEPTH) |-> F.full );
	cover property (@(posedge F.clk) (count == F.FIFO_DEPTH) |-> F.full );
	// empty flag
	assert property (@(posedge F.clk) (count == 0) |-> F.empty );
	cover property (@(posedge F.clk) (count == 0) |-> F.empty );
	// almost full flag
	assert property (@(posedge F.clk) (count == F.FIFO_DEPTH-1) |-> F.almostfull );
	cover property (@(posedge F.clk) (count == F.FIFO_DEPTH-1) |-> F.almostfull);
	// almost empty flag
	assert property (@(posedge F.clk) (count == 1) |-> F.almostempty );
	cover property (@(posedge F.clk) (count == 1) |-> F.almostempty );
	// Over flow flag
	assert property (@(posedge F.clk) disable iff(!F.rst_n) (F.full && F.wr_en) |=> (F.overflow));
	cover property (@(posedge F.clk) disable iff(!F.rst_n) (F.full && F.wr_en) |=> (F.overflow));
	// Under flow flag
	assert property (@(posedge F.clk) disable iff(!F.rst_n) (F.empty && F.rd_en) |=> (F.underflow));
	cover property (@(posedge F.clk) disable iff(!F.rst_n) (F.empty && F.rd_en) |=> (F.underflow));
	// Write acknoledge flag
	assert property (@(posedge F.clk) disable iff(!F.rst_n) (F.wr_en && !F.full) |=> (F.wr_ack));
	cover property (@(posedge F.clk) disable iff(!F.rst_n) (F.wr_en && !F.full) |=> (F.wr_ack));
	// internal counters 
	// Write pointer
	assert property (@(posedge F.clk) disable iff(!F.rst_n) (F.wr_en && !F.full && wr_ptr!=7) |=> (wr_ptr==$past(wr_ptr)+1));
	cover property (@(posedge F.clk) disable iff(!F.rst_n) (F.wr_en && !F.full && wr_ptr!=7) |=> (wr_ptr==$past(wr_ptr)+1));
	// Write pointer if we wrote in the 8 places we will return to the beginning
	assert property (@(posedge F.clk) disable iff(!F.rst_n) (F.wr_en && !F.full && wr_ptr==7) |=> (wr_ptr==0));
	cover property (@(posedge F.clk) disable iff(!F.rst_n) (F.wr_en && !F.full && wr_ptr==7) |=> (wr_ptr==0));
	// Read pointer
	assert property (@(posedge F.clk) disable iff(!F.rst_n) (F.rd_en && !F.empty && rd_ptr!=7) |=> (rd_ptr==$past(rd_ptr)+1));
	cover property (@(posedge F.clk) disable iff(!F.rst_n) (F.rd_en && !F.empty && rd_ptr!=7) |=> (rd_ptr==$past(rd_ptr)+1));
	// Read pointer if we read the 8 places we will return to the beginning
	assert property (@(posedge F.clk) disable iff(!F.rst_n) (F.rd_en && !F.empty && rd_ptr==7) |=> (rd_ptr==0));
	cover property (@(posedge F.clk) disable iff(!F.rst_n) (F.rd_en && !F.empty && rd_ptr==7) |=> (rd_ptr==0));
	// counter
	assert property (@(posedge F.clk) disable iff(!F.rst_n) (F.wr_en && !F.full && !F.rd_en) |=> (count==$past(count)+1));
	cover property (@(posedge F.clk) disable iff(!F.rst_n) (F.wr_en && !F.full && !F.rd_en) |=> (count==$past(count)+1));
	assert property (@(posedge F.clk) disable iff(!F.rst_n) (F.rd_en && !F.empty && !F.wr_en) |=> (count==$past(count)-1));
	cover property (@(posedge F.clk) disable iff(!F.rst_n) (F.rd_en && !F.empty && !F.wr_en) |=> (count==$past(count)-1));
	assert property (@(posedge F.clk) disable iff(!F.rst_n) (F.wr_en && F.empty && F.rd_en) |=> (count==$past(count)+1));
	cover property (@(posedge F.clk) disable iff(!F.rst_n) (F.wr_en && F.empty && F.rd_en) |=> (count==$past(count)+1));
	assert property (@(posedge F.clk) disable iff(!F.rst_n) (F.wr_en && F.full && F.rd_en) |=> (count==$past(count)-1));
	cover property (@(posedge F.clk) disable iff(!F.rst_n) (F.wr_en && F.full && F.rd_en) |=> (count==$past(count)-1));
endmodule : FIFO_dut