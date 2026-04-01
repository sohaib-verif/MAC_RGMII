#vcs -sverilog -timescale=1ns/1ps -cm line+cond+tgl+fsm -f scripts/eth_files.f -top eth_tb +define+VERILATOR -full64 -debug_all -> log_compile_build.log
#./simv -cm line+cond+tgl+fsm -> log_simulation.log
vcs -lca -kdb -timescale=1ns/1ps -f ./eth_uvm/eth_uvm_files.f -top eth_testbench -ntb_opts uvm-1.2 -sverilog -cm line+cond+tgl+fsm -cm_hier config_covg.cfg -LDFLAGS -Wl,--no-as-needed -full64 -assert svaext -debug_all
./simv +UVM_TESTNAME=eth_test -cm line+cond+tgl+fsm +UVM_TIMEOUT=9200000 -> log_simulation.log
