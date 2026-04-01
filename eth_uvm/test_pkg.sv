/*-------------------------------------------------------------------------
File name   : test_pkg.sv
Project     : DDS VIP
---------------------------------------------------------------------------*/
package test_pkg;
    `include "uvm_macros.svh"
    //-----------------Importing uvm package-------------------
    import uvm_pkg::*;
    import eth_pkg::*;
    
    //---------------------Import agents' pkgs---------------------
    import top_env_pkg::*;
    //---------------------Files Inclusion---------------------

    `include "eth_test.sv"
        
endpackage:test_pkg
