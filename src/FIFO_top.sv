module FIFO_top ();
	bit clk;
	initial begin
		clk=0;
		forever begin
			#2 clk=~clk;
		end 
	end

	FIFO_if F (clk);
	FIFO_test test (F);
	FIFO_dut dut (F);
	FIFO_monitor mon (F);

endmodule : FIFO_top