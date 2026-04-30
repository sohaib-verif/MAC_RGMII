/*-------------------------------------------------------------------------
File name   : eth_rx_transaction.sv
Project     : SPI UVC
---------------------------------------------------------------------------*/

class eth_rx_transaction extends uvm_sequence_item;

    // rand variables
  
     rand byte unsigned dest_addr [6];
     rand byte unsigned src_addr [6];
     rand byte unsigned eth_type [6];
     rand byte unsigned payload  [$]        ; //Just Payload
     
    rand bit [3:0] reg_addr;
    rand bit [3:0] reg_wstrb;
    rand bit [31:0] reg_write_data;
    rand bit reg_write;
    rand bit reg_valid;
    rand bit regs_config_seq;
    // constraints
    /* for example
    constraint c_default_txmit_delay {transmit_delay >= 0; transmit_delay < 20; */
    constraint c_payload_size {soft payload.size() inside {[46:1500]};}
    `uvm_object_utils_begin(eth_rx_transaction)
	   	`uvm_field_int(reg_addr, UVM_DEFAULT)
        `uvm_field_int(reg_write_data, UVM_DEFAULT)
        `uvm_field_int(reg_write, UVM_DEFAULT)
        `uvm_field_int(reg_valid, UVM_DEFAULT)
    `uvm_object_utils_end
  
    function new(string name = "eth_rx_transaction");
        super.new(name);
    endfunction
  
  endclass
  
