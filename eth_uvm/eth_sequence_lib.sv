typedef class eth_64B_pkt;
typedef class eth_1000_pkt;
typedef class eth_rand_pkt;
typedef class eth_padding;
typedef class eth_1514B_pkt;
typedef class eth_throughput;

class eth_sequence_lib extends uvm_sequence;
  `uvm_object_utils(eth_sequence_lib)
  
  eth_64B_pkt        eth_64B        ;
  eth_1000_pkt       eth_1000       ;
  eth_rand_pkt       eth_rand       ;
  eth_padding        eth_pad        ;
  eth_1514B_pkt      eth_1514B      ;
  eth_throughput     eth_thrpt      ;

  function new(string name= "eth_sequence_lib");
    super.new(name);
  endfunction

  task body();

    eth_64B       = eth_64B_pkt::type_id::create("eth_64B");
    eth_1000      = eth_1000_pkt::type_id::create("eth_1000");
    eth_rand      = eth_rand_pkt::type_id::create("eth_rand");
    eth_pad       = eth_padding::type_id::create("eth_pad");
    eth_1514B     = eth_1514B_pkt::type_id::create("eth_1514B");
    eth_thrpt     = eth_throughput::type_id::create("eth_thrpt");

    eth_64B.start(m_sequencer);
    // eth_1000.start(m_sequencer);
    // eth_rand.start(m_sequencer);
    // eth_pad.start(m_sequencer);
    // eth_1514B.start(m_sequencer);
    // eth_thrpt.start(m_sequencer);
    
  endtask: body
  
endclass: eth_sequence_lib


class eth_64B_pkt extends uvm_sequence;
  `uvm_object_utils(eth_64B_pkt)
  
  eth_sequence_item pkt;

  function new(string name= "eth_64B_pkt");
    super.new(name);
  endfunction

  task body();
    pkt = eth_sequence_item::type_id::create("pkt");
    `uvm_do_with(pkt,{
      pkt.eth_type[0]      == 8'h00;
      pkt.eth_type[1]      == 8'hE2;
      pkt.payload.size()   == 50;
      pkt.phy_int_n        == 1;
      pkt.phy_pme_n        == 1;
      pkt.phy_mdio_i       == 0;
      pkt.reg_bus_addr_i   == 0;
      pkt.reg_bus_write_i  == 0;
      pkt.reg_bus_wdata_i  == 0;
      pkt.reg_bus_wstrb_i  == 0;
      pkt.reg_bus_valid_i  == 0;
    })
  endtask: body
  
endclass: eth_64B_pkt


class eth_1000_pkt extends uvm_sequence;
  `uvm_object_utils(eth_1000_pkt)
  
  eth_sequence_item pkt;

  function new(string name= "eth_1000_pkt");
    super.new(name);
  endfunction

  task body();
    repeat(1000) begin
      pkt = eth_sequence_item::type_id::create("pkt");
      `uvm_do_with(pkt,{
        pkt.eth_type[0]      == 8'h00;
        pkt.eth_type[1]      == 8'hE2;
        pkt.payload.size()   == 50;
        //pkt.phy_int_n        == 1;
        //pkt.phy_pme_n        == 1;
        //pkt.phy_mdio_i       == 0;
        pkt.reg_bus_addr_i   == 0;
        pkt.reg_bus_write_i  == 0;
        pkt.reg_bus_wdata_i  == 0;
        pkt.reg_bus_wstrb_i  == 0;
        pkt.reg_bus_valid_i  == 0;
      })
    end
  endtask: body
  
endclass: eth_1000_pkt


class eth_rand_pkt extends uvm_sequence;
  `uvm_object_utils(eth_rand_pkt)
  
  eth_sequence_item pkt;

  function new(string name= "eth_rand_pkt");
    super.new(name);
  endfunction

  task body();
    pkt = eth_sequence_item::type_id::create("pkt");
    `uvm_do_with(pkt,{
      pkt.eth_type[0]      == 8'h00;
      pkt.eth_type[1]      == 8'hE2;
      pkt.payload.size()   inside {[46:1500]}; 
      pkt.phy_int_n        == 1;
      pkt.phy_pme_n        == 1;
      pkt.phy_mdio_i       == 0;
      pkt.reg_bus_addr_i   == 0;
      pkt.reg_bus_write_i  == 0;
      pkt.reg_bus_wdata_i  == 0;
      pkt.reg_bus_wstrb_i  == 0;
      pkt.reg_bus_valid_i  == 0;
    })
  endtask: body
  
endclass: eth_rand_pkt


class eth_padding extends uvm_sequence;
  `uvm_object_utils(eth_padding)
  
  eth_sequence_item pkt;

  function new(string name= "eth_padding");
    super.new(name);
  endfunction

  task body();
  repeat(100) begin
    pkt = eth_sequence_item::type_id::create("pkt");
      `uvm_do_with(pkt,{
        pkt.eth_type[0]      == 8'h00;
        pkt.eth_type[1]      == 8'hE2;
        pkt.payload.size()   < 50;
        pkt.phy_int_n        == 1;
        pkt.phy_pme_n        == 1;
        pkt.phy_mdio_i       == 0;
        pkt.reg_bus_addr_i   == 0;
        pkt.reg_bus_write_i  == 0;
        pkt.reg_bus_wdata_i  == 0;
        pkt.reg_bus_wstrb_i  == 0;
        pkt.reg_bus_valid_i  == 0;
      })
  end
  endtask: body
  
endclass: eth_padding


class eth_1514B_pkt extends uvm_sequence;
  `uvm_object_utils(eth_1514B_pkt)
  
  eth_sequence_item pkt;

  function new(string name= "eth_1514B_pkt");
    super.new(name);
  endfunction

  task body();
  //repeat(100) begin
    pkt = eth_sequence_item::type_id::create("pkt");
      `uvm_do_with(pkt,{
        pkt.eth_type[0]      == 8'h00;
        pkt.eth_type[1]      == 8'hE2;
        //------------------------------------------------
        // Cannot send max payload due to tstrb issue, dest_mac + src_mac + eth_type + payld should be 8 byte aligned
        // So max payload that we can send is 1498B
        // 6 + 6 + 2 + 1498 = 1512 which is less than max frame(1518)
        //------------------------------------------------
        pkt.payload.size()   == 1498;
        pkt.phy_int_n        == 1;
        pkt.phy_pme_n        == 1;
        pkt.phy_mdio_i       == 0;
        pkt.reg_bus_addr_i   == 0;
        pkt.reg_bus_write_i  == 0;
        pkt.reg_bus_wdata_i  == 0;
        pkt.reg_bus_wstrb_i  == 0;
        pkt.reg_bus_valid_i  == 0;
      })
  //end
  endtask: body
  
endclass: eth_1514B_pkt


class eth_throughput extends uvm_sequence;
  `uvm_object_utils(eth_throughput)
  
  eth_sequence_item pkt;

  function new(string name= "eth_throughput");
    super.new(name);
  endfunction

  task body();
    repeat(20000) begin
      pkt = eth_sequence_item::type_id::create("pkt");
      `uvm_do_with(pkt,{
        pkt.eth_type[0]      == 8'h00;
        pkt.eth_type[1]      == 8'hE2;
        pkt.payload.size()   == 50;
        pkt.phy_int_n        == 1;
        pkt.phy_pme_n        == 1;
        pkt.phy_mdio_i       == 0;
        pkt.reg_bus_addr_i   == 0;
        pkt.reg_bus_write_i  == 0;
        pkt.reg_bus_wdata_i  == 0;
        pkt.reg_bus_wstrb_i  == 0;
        pkt.reg_bus_valid_i  == 0;
      })
    end
  endtask: body
  
endclass: eth_throughput
