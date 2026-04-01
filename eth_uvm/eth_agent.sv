class eth_agent extends uvm_agent;
  `uvm_component_utils(eth_agent)
  
  eth_driver eth_drv;
  eth_monitor eth_mon;
  eth_sequencer eth_seqr;  

  function new(string name = "eth_agent", uvm_component parent);
    super.new(name, parent);
  endfunction: new
  

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    eth_drv  = eth_driver::type_id::create("eth_drv", this);
    eth_mon  = eth_monitor::type_id::create("eth_mon", this);
    eth_seqr = eth_sequencer::type_id::create("eth_seqr", this);
  endfunction: build_phase
  
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);    
    eth_drv.seq_item_port.connect(eth_seqr.seq_item_export); //Connection Between driver and sequencer
  endfunction: connect_phase
  

  task run_phase (uvm_phase phase);
    super.run_phase(phase);
  endtask: run_phase
  
endclass: eth_agent