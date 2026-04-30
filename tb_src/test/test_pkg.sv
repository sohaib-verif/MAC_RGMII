/*-------------------------------------------------------------------------
File name   : test_pkg.sv
Project     : SPI VIP
---------------------------------------------------------------------------*/
package test_pkg;
    `include "uvm_macros.svh"
    //-----------------Importing uvm package-------------------
    import uvm_pkg::*;
    
    //---------------------Import agents' pkgs---------------------
    import top_env_pkg::*;

    //---------------------Files Inclusion---------------------
    //
    `include "eth_tx_test.sv" 
    `include "eth_rx_test.sv" 
    `include "eth_tx_rx_test.sv" 
    // `include "transfer_test_writing_while_tip.sv"
    // `include "transfer_test_64_msb.sv"
    // `include "transfer_test_96_msb.sv"
	// `include "transfer_test_127_msb.sv"
    // `include "transfer_test_128_msb.sv"
    // `include "transfer_test_32_lsb.sv" 
    // `include "transfer_test_64_lsb.sv"
    // `include "transfer_test_128_lsb.sv" 
    // `include "transfer_test_128_lsb_negedge.sv" 
    // `include "transfer_test_128_msb_negedge.sv" 

endpackage:test_pkg
