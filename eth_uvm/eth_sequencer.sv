class eth_sequencer extends uvm_sequencer#(eth_sequence_item);
  `uvm_component_utils(eth_sequencer)
  
  
  function new(string name = "eth_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction: new
  

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);    
  endfunction: build_phase
  

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);    
  endfunction: connect_phase
  
endclass: eth_sequencer