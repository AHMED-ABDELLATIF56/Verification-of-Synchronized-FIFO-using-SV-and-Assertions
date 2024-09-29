vlib work
vlog FIFO_if.sv shared_package.sv FIFO_transaction.sv FIFO_scoreboard.sv FIFO_coverage.sv FIFO_test.sv FIFO_dut.sv  FIFO_monitor.sv FIFO_top.sv +cover -covercells
vsim -voptargs=+acc work.FIFO_top -cover -sv_seed random -l sim.log
add wave -position insertpoint sim:/FIFO_top/dut/F/*
coverage save FIFO_top.ucdb -onexit 
run -all