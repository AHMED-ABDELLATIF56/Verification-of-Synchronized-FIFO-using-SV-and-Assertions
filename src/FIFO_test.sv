module FIFO_test (FIFO_if.TEST F);
	import shared_package::*;
	import FIFO_transaction_::*;

	FIFO_transaction t = new ;

	initial begin
		F.rst_n = 0;
		#10;
		F.rst_n = 1;
		
		repeat (1000) begin
			@(negedge F.clk);
			assert(t.randomize());
			F.data_in = t.data_in ;
			F.rst_n = t.rst_n ;
			F.wr_en = t.wr_en ;
			F.rd_en = t.rd_en;
			t.data_out = F.data_out ;
			t.wr_ack = F.wr_ack ;
			t.underflow = F.underflow ;
			t.overflow = F.overflow ;
			t.full = F.full ;
			t.empty = F.empty ;
			t.almostfull = F.almostfull ;
			t.almostempty = F.almostempty ;
		end
		test_finished = 1;
	end

endmodule : FIFO_test