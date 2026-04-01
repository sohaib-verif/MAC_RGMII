/*-------------------------------------------------------------------------
File name   : eth_pkg.sv
Project     : eth
---------------------------------------------------------------------------*/

package eth_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"


    //////////////////////////////////////////////////
    //              Include files                   //
    //////////////////////////////////////////////////
    // Parameters
    

    typedef class eth_agent;
    typedef class eth_driver;
    typedef class eth_environment;
    typedef class eth_monitor;
    typedef class eth_sequencer;
    //typedef class eth_sequence_lib;
    typedef class eth_sequence_item;
    typedef class eth_ref_model;
    typedef class eth_scoreboard;
    



    `include "eth_sequence_item.sv"        // transaction class
    `include "eth_sequencer.sv"            // sequencer class
    `include "eth_driver.sv"               // driver class
    `include "eth_monitor.sv"              // drivmonitorer class
    `include "eth_agent.sv"                // agent class
    `include "eth_scoreboard.sv"           // scoreboard Class
    `include "eth_environment.sv"          // environment class
    `include "eth_sequence_lib.sv"             // sequence class
    `include "eth_ref_model.sv"            // reference model for expected packet
   
    
endpackage
    