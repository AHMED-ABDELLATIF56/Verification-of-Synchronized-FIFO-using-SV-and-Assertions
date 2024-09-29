module FIFO_monitor (FIFO_if.monitor F);
	import FIFO_transaction_::*;
	import FIFO_scoreboard_::*;
	import FIFO_coverage_::*;
	import shared_package::*;
	

	FIFO_transaction tr = new;
	FIFO_scoreboard sb = new;
	FIFO_coverage cv = new ;

	initial begin
		forever begin
			@(negedge F.clk);
			tr.data_in = F.data_in ;
			tr.rst_n = F.rst_n ;
			tr.wr_en = F.wr_en ;
			tr.rd_en = F.rd_en ;
			tr.data_out = F.data_out ;
			tr.wr_ack = F.wr_ack ;
			tr.overflow = F.overflow ;
			tr.underflow = F.underflow ;
			tr.full = F.full ;
			tr.empty = F.empty ;
			tr.almostfull = F.almostfull ;
			tr.almostempty = F.almostempty ;

			fork
				begin
					cv.sample_data(tr);
				end
				begin
					sb.check_data(tr);
				end
			join

			if (test_finished) begin
				$display("errors=%d and correct=%d",error_count,correct_count);
				$stop;
			end
		end
	end
endmodule : FIFO_monitor