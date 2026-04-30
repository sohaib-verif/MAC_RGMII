/*-------------------------------------------------------------------------
File name   : eth_rx_monitor.sv
Project     : SPI UVC
---------------------------------------------------------------------------*/

// Modified by WHDL to make UVM 1.2 compliant

class eth_rx_monitor extends uvm_monitor;

    // This property is the virtual interfaced needed for this component to
    // view HDL signals.
    protected virtual eth_rx_interface eth_rx_vif;

    eth_rx_config cfg;
  
    // Agent Id
    protected int agent_id;
  
    // Property indicating the number of transactions occuring on the pt.
	  protected int unsigned num_transactions = 0;

    // The following bit is used to control whether coverage is
    // done both in the monitor class and the interface.
    bit coverage_enable = 1;
  
    uvm_analysis_port #(eth_rx_transaction) item_collected_port;
  
    // The following property holds the transaction information currently
    // begin captured (by the collect_receive_data and collect_transmit_data methods).
    protected eth_rx_transaction trans_collected;
  
    // Provide implementations of virtual methods such as get_type_name and create
    `uvm_component_utils_begin(eth_rx_monitor)
      `uvm_field_int(agent_id, UVM_ALL_ON)
      `uvm_field_int(coverage_enable, UVM_ALL_ON)
    `uvm_component_utils_end
  
    // new - constructor
    function new (string name = "", uvm_component parent = null);
      super.new(name, parent);
      item_collected_port = new("item_collected_port", this);
    endfunction : new

    // Additional class methods
	  extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual protected task collect_transactions();
    extern virtual protected task reset_signals();

endclass : eth_rx_monitor

// build
function void eth_rx_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	// get virtual interface
	if(!uvm_config_db#(virtual eth_rx_interface)::get(this, "", "eth_rx_vif", eth_rx_vif))
		`uvm_fatal(get_name(),"No eth_rx_vif is set for this instance")
endfunction

// run phase
task eth_rx_monitor::run_phase(uvm_phase phase);
  trans_collected = eth_rx_transaction::type_id::create("trans_collected",this);
    reset_signals();
    collect_transactions(); 
endtask
  
// reset_signals
task eth_rx_monitor::reset_signals();
	@(negedge eth_rx_vif.rst_ni);
	`uvm_info(get_type_name(), "Reset Observed", UVM_LOW)
endtask : reset_signals

task eth_rx_monitor::collect_transactions();
  // int rdata;
  int wb_data;
  int length;
  uvm_event ev2;
  
  @(posedge eth_rx_vif.rst_ni);
  `uvm_info(get_type_name(), "Reset DONE", UVM_LOW)

  ev2 = uvm_event_pool::get_global("ev2_seq2mon");
  




  forever begin
    `uvm_info(get_type_name(),$sformatf(" waiting for the event trigger"),UVM_LOW)        
    ev2.wait_trigger;           
    `uvm_info(get_type_name(),$sformatf(" event got triggerd"),UVM_LOW)
    if(!uvm_config_db#(int)::get(this, "", "wb_data", wb_data))
		  `uvm_fatal(get_name(),"No wb_data is set for this instance")
    else 
      `uvm_info(get_name(), $sformatf("wb_data = %01h", wb_data), UVM_LOW)

    if(wb_data[6:0]==0)
      length = 128;
    else
      length = wb_data[6:0];
    for (int i = 0; i<length; i++) begin
      if((wb_data[9] == 1) && (wb_data[10] == 0))
		    @(negedge eth_rx_vif.sclk_pad_o);
	    else
		    @(posedge eth_rx_vif.sclk_pad_o);
      if(wb_data[11] == 1'b0)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
        trans_collected.rec_data 			<= {trans_collected.rec_data[126:0], eth_rx_vif.mosi_pad_o};
      else
        trans_collected.rec_data[i] 	<= eth_rx_vif.mosi_pad_o; 
      #1
      `uvm_info (get_type_name (), $sformatf ("\n \nTransfer data at spi mon = %h \nmosi = %b\n",trans_collected.rec_data, eth_rx_vif.mosi_pad_o ), UVM_NONE)
    end 
	  item_collected_port.write(trans_collected);
    // num_transactions++;
  end
endtask : collect_transactions
