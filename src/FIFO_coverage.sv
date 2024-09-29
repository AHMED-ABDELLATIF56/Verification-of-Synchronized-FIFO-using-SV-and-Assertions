package FIFO_coverage_;

	import FIFO_transaction_::*;
	FIFO_transaction F_cvg_txn;

	class FIFO_coverage;
		covergroup cg;
			cross F_cvg_txn.wr_en , F_cvg_txn.rd_en , F_cvg_txn.wr_ack;
			cross F_cvg_txn.wr_en , F_cvg_txn.rd_en , F_cvg_txn.full;
			cross F_cvg_txn.wr_en , F_cvg_txn.rd_en , F_cvg_txn.empty;
			cross F_cvg_txn.wr_en , F_cvg_txn.rd_en , F_cvg_txn.almostfull;
			cross F_cvg_txn.wr_en , F_cvg_txn.rd_en , F_cvg_txn.almostempty;
			cross F_cvg_txn.wr_en , F_cvg_txn.rd_en , F_cvg_txn.overflow;
			cross F_cvg_txn.wr_en , F_cvg_txn.rd_en , F_cvg_txn.underflow;	
		endgroup : cg

		function void sample_data(FIFO_transaction F_txn);
			F_cvg_txn = F_txn;
			cg.sample();
		endfunction 

		function new();
			cg = new ;
		endfunction 
	endclass : FIFO_coverage
endpackage : FIFO_coverage_
