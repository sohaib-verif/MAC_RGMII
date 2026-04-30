typedef class eth_64B_pkt;
typedef class eth_1000_pkt;
typedef class eth_rand_pkt;
typedef class eth_padding;
typedef class eth_1514B_pkt;
typedef class eth_throughput;
typedef class eth_tx_tuser_error;
typedef class tstrb_issue_pkt;
typedef class padding_issue_pkt;

class eth_tx_sequence_lib extends uvm_sequence;
  `uvm_object_utils(eth_tx_sequence_lib)
  
  eth_64B_pkt        eth_64B          ;
  eth_1000_pkt       eth_1000         ;
  eth_rand_pkt       eth_rand         ;
  eth_padding        eth_pad          ;
  eth_1514B_pkt      eth_1514B        ;
  eth_throughput     eth_thrpt        ;
  eth_tx_tuser_error eth_tuser_err    ;
  tstrb_issue_pkt    tstrb_issue      ;
  padding_issue_pkt  padding_issue    ;
  function new(string name= "eth_tx_sequence_lib");
    super.new(name);
  endfunction

  task body();

    eth_64B       = eth_64B_pkt::type_id::create("eth_64B");
    eth_1000      = eth_1000_pkt::type_id::create("eth_1000");
    eth_rand      = eth_rand_pkt::type_id::create("eth_rand");
    eth_pad       = eth_padding::type_id::create("eth_pad");
    eth_1514B     = eth_1514B_pkt::type_id::create("eth_1514B");
    eth_thrpt     = eth_throughput::type_id::create("eth_thrpt");
    eth_tuser_err = eth_tx_tuser_error::type_id::create("eth_tuser_err");
    tstrb_issue   = tstrb_issue_pkt::type_id::create("tstrb_issue");
    padding_issue = padding_issue_pkt::type_id::create("padding_issue");

    eth_64B.start(m_sequencer);
    // eth_1000.start(m_sequencer);
    // eth_rand.start(m_sequencer);
    // eth_pad.start(m_sequencer);
    // eth_1514B.start(m_sequencer);
    // eth_thrpt.start(m_sequencer);
    // eth_tuser_err.start(m_sequencer);
    // tstrb_issue.start(m_sequencer);
    // padding_issue.start(m_sequencer);
    
  endtask: body
  
endclass: eth_tx_sequence_lib


class eth_64B_pkt extends uvm_sequence;
  `uvm_object_utils(eth_64B_pkt)
  
  eth_tx_transaction pkt;

  function new(string name= "eth_64B_pkt");
    super.new(name);
  endfunction

  task body();
    pkt = eth_tx_transaction::type_id::create("pkt");
    `uvm_do_with(pkt,{
      pkt.eth_type[0]      == 8'h00;
      pkt.eth_type[1]      == 8'hE2;
      pkt.payload.size()   == 50;
      pkt.tx_axis_tuser_i  == 0; // No error
    })
  endtask: body
  
endclass: eth_64B_pkt


class eth_1000_pkt extends uvm_sequence;
  `uvm_object_utils(eth_1000_pkt)
  
  eth_tx_transaction pkt;

  function new(string name= "eth_1000_pkt");
    super.new(name);
  endfunction

  task body();
    repeat(1000) begin
      pkt = eth_tx_transaction::type_id::create("pkt");
      `uvm_do_with(pkt,{
        pkt.eth_type[0]      == 8'h00;
        pkt.eth_type[1]      == 8'hE2;
        pkt.payload.size()   == 50;
        pkt.tx_axis_tuser_i  == 0; // No error
      })
    end
  endtask: body
  
endclass: eth_1000_pkt


class eth_rand_pkt extends uvm_sequence;
  `uvm_object_utils(eth_rand_pkt)
  
  eth_tx_transaction pkt;

  function new(string name= "eth_rand_pkt");
    super.new(name);
  endfunction

  task body();
    pkt = eth_tx_transaction::type_id::create("pkt");
    `uvm_do_with(pkt,{
      pkt.eth_type[0]      == 8'h00;
      pkt.eth_type[1]      == 8'hE2;
      pkt.payload.size()   inside {[46:1500]}; 
      pkt.tx_axis_tuser_i  == 0; // No error
    })
  endtask: body
  
endclass: eth_rand_pkt


class eth_padding extends uvm_sequence;
  `uvm_object_utils(eth_padding)
  
  eth_tx_transaction pkt;

  function new(string name= "eth_padding");
    super.new(name);
  endfunction

  task body();
  repeat(100) begin
    pkt = eth_tx_transaction::type_id::create("pkt");
      `uvm_do_with(pkt,{
        pkt.eth_type[0]      == 8'h00;
        pkt.eth_type[1]      == 8'hE2;
        pkt.payload.size()   < 50;
        pkt.tx_axis_tuser_i  == 0; // No error
      })
  end
  endtask: body
  
endclass: eth_padding


class eth_1514B_pkt extends uvm_sequence;
  `uvm_object_utils(eth_1514B_pkt)
  
  eth_tx_transaction pkt;

  function new(string name= "eth_1514B_pkt");
    super.new(name);
  endfunction

  task body();
  //repeat(100) begin
    pkt = eth_tx_transaction::type_id::create("pkt");
      `uvm_do_with(pkt,{
        pkt.eth_type[0]      == 8'h00;
        pkt.eth_type[1]      == 8'hE2;
        //------------------------------------------------
        // Cannot send max payload due to tstrb issue, dest_mac + src_mac + eth_type + payld should be 8 byte aligned
        // So max payload that we can send is 1498B
        // 6 + 6 + 2 + 1498 = 1512 which is less than max frame(1518)
        //------------------------------------------------
        pkt.payload.size()   == 1498;
        pkt.tx_axis_tuser_i  == 0; // No error
      })
  //end
  endtask: body
  
endclass: eth_1514B_pkt


class eth_throughput extends uvm_sequence;
  `uvm_object_utils(eth_throughput)
  
  eth_tx_transaction pkt;

  function new(string name= "eth_throughput");
    super.new(name);
  endfunction

  task body();
    repeat(20000) begin
      pkt = eth_tx_transaction::type_id::create("pkt");
      `uvm_do_with(pkt,{
        pkt.eth_type[0]      == 8'h00;
        pkt.eth_type[1]      == 8'hE2;
        pkt.payload.size()   == 50;
        pkt.tx_axis_tuser_i  == 0; // No error
      })
    end
  endtask: body
  
endclass: eth_throughput


class eth_tx_tuser_error extends uvm_sequence;
  `uvm_object_utils(eth_tx_tuser_error)
  
  eth_tx_transaction pkt;
  function new(string name="eth_tx_tuser_error"); super.new(name); endfunction
  
  task body();
    pkt = eth_tx_transaction::type_id::create("pkt");
    `uvm_do_with(pkt,{
      pkt.eth_type[0] == 8'h00;
      pkt.eth_type[1] == 8'hE2;
      pkt.payload.size() == 50;
      pkt.tx_axis_tuser_i == 1; // Set error flag
    })
  endtask
endclass: eth_tx_tuser_error


class tstrb_issue_pkt extends uvm_sequence;
  `uvm_object_utils(tstrb_issue_pkt)
  
  eth_tx_transaction pkt;
  function new(string name="tstrb_issue_pkt"); super.new(name); endfunction
  
  task body();
    pkt = eth_tx_transaction::type_id::create("pkt");
    `uvm_do_with(pkt,{
      pkt.eth_type[0] == 8'h00;
      pkt.eth_type[1] == 8'hE2;
      pkt.payload.size() == 52; // Payload size that causes tstrb issue
      pkt.tx_axis_tuser_i  == 0; // No error
    })
  endtask
endclass: tstrb_issue_pkt


class padding_issue_pkt extends uvm_sequence;
  `uvm_object_utils(padding_issue_pkt)
  
  eth_tx_transaction pkt;
  function new(string name="padding_issue_pkt"); super.new(name); endfunction
  
  task body();
    pkt = eth_tx_transaction::type_id::create("pkt");
    `uvm_do_with(pkt,{
      pkt.eth_type[0] == 8'h00;
      pkt.eth_type[1] == 8'hE2;
      pkt.payload.size() == 46; // P4 bytes will be pad, according to spec no need of padding
      pkt.tx_axis_tuser_i  == 0; // No error
    })
  endtask
endclass: padding_issue_pkt
