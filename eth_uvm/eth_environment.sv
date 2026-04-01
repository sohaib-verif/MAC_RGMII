class eth_environment extends uvm_env;
  `uvm_component_utils(eth_environment)
  
  eth_agent      eth_agnt;
  eth_scoreboard eth_scb;
  
  
  function new(string name = "eth_env", uvm_component parent);
    super.new(name, parent);
    `uvm_info("ENV_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new
  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("ENV_CLASS", "Build Phase!", UVM_HIGH)
    
    eth_agnt = eth_agent::type_id::create("eth_agnt", this);
    eth_scb = eth_scoreboard::type_id::create("eth_scb", this);
  endfunction: build_phase
  

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("ENV_CLASS", "Connect Phase!", UVM_HIGH)
    eth_agnt.eth_mon.dut_pkt_port.connect(eth_scb.dut_pkt_imp);
  endfunction: connect_phase
  
  
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
  endtask: run_phase
  
endclass: eth_environment