package FIFO_scoreboard_;
	import FIFO_transaction_::*;
	import shared_package::*;

	parameter FIFO_WIDTH = 16;
	parameter FIFO_DEPTH = 8;
	localparam max_fifo_addr = $clog2(FIFO_DEPTH);

	logic [FIFO_WIDTH-1:0] data_out_ref;
	logic wr_ack_ref, overflow_ref;
	logic full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;

	class FIFO_scoreboard;
			logic [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];
			logic [max_fifo_addr-1:0] wr_ptr, rd_ptr;
			logic [max_fifo_addr:0] count;

		function check_data(FIFO_transaction F_sb_txn);
	        if (F_sb_txn.data_out!=data_out_ref || F_sb_txn.wr_ack!=wr_ack_ref
	        || F_sb_txn.overflow!=overflow_ref || F_sb_txn.full!=full_ref 
	        || F_sb_txn.empty!=empty_ref || F_sb_txn.almostfull!=almostfull_ref
	        || F_sb_txn.almostempty!=almostempty_ref || F_sb_txn.underflow!=underflow_ref) begin
	            $display("Error where data_out_ref=%d,wr_ack_ref=%d,overflow_ref=%d,full_ref=%d,empty_ref=%d,almostfull_ref=%d,almostempty_ref=%d,underflow_ref=%d
	            	and 
	            	data_out=%d,wr_ack=%d,overflow=%d,full=%d,empty=%d,almostfull=%d,almostempty=%d,underflow=%d",
	            	data_out_ref,wr_ack_ref, overflow_ref,
	            	full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref,
	            	F_sb_txn.data_out,F_sb_txn.wr_ack,F_sb_txn.overflow,F_sb_txn.full, 
	            	F_sb_txn.empty,F_sb_txn.almostfull,F_sb_txn.almostempty,F_sb_txn.underflow);
	            $stop;
	            error_count++;
	        end else begin
	            correct_count++;
	        end
	        reference_model(F_sb_txn);
		endfunction 

		function reference_model(FIFO_transaction F_sb_txn);
				
				if (!F_sb_txn.rst_n) begin
					wr_ptr = 0;
					rd_ptr = 0;
					count = 0;
					underflow_ref = 0;
					overflow_ref = 0;
				end
				else begin
					/* Read operatio before write operation to read the right value 
					when read and write signals asserted together*/

					if (F_sb_txn.rd_en && count != 0) begin
						data_out_ref = mem[rd_ptr];
						rd_ptr = rd_ptr + 1;
						count = count - 1;
					end else begin
						if (empty_ref && F_sb_txn.rd_en)
							underflow_ref = 1;
						else
							underflow_ref = 0;
					end 

					if (F_sb_txn.wr_en && !full_ref) begin
						mem[wr_ptr] = F_sb_txn.data_in;
						wr_ack_ref = 1;
						wr_ptr = wr_ptr + 1;
						count = count + 1;
					end
					else begin 
						wr_ack_ref = 0; 
						if (full_ref & F_sb_txn.wr_en)
							overflow_ref = 1;
						else
							overflow_ref = 0;
					end
				end 
				
				
				if (count == FIFO_DEPTH) 
					full_ref = 1;
				else 
					full_ref = 0;
				
				if (count == 0)	
					empty_ref = 1;
				else 
					empty_ref = 0;

				if (count == FIFO_DEPTH-1)
					almostfull_ref = 1; 
				else
					almostfull_ref = 0;

				if (count == 1)
					almostempty_ref = 1;
				else 
					almostempty_ref = 0;
		endfunction 
	endclass : FIFO_scoreboard
endpackage : FIFO_scoreboard_