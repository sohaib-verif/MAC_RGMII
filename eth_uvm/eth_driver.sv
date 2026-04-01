class eth_driver extends uvm_driver#(eth_sequence_item);
  `uvm_component_utils(eth_driver)
  
  uvm_analysis_port #(eth_sequence_item) ref_model_port;

  virtual eth_interface intf;
  eth_sequence_item     pkt;
  byte unsigned         temp_pkt[];
  int                   num_flits;
  int                   bytes_rem;
  // For Throughput
  real start_time_axi;
  bit  first_handshake_seen;
  
  function new(string name = "eth_driver", uvm_component parent);
    super.new(name, parent);
    ref_model_port = new("ref_model_port", this);
  endfunction: new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); 
    if(!(uvm_config_db #(virtual eth_interface)::get(this, "*", "intf", intf))) begin
      `uvm_error("DRIVER_CLASS", "Failed to get intf from config DB!")
    end
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);    
  endfunction: connect_phase
  
  
  task run_phase (uvm_phase phase);
    super.run_phase(phase);    
    forever begin
      pkt = eth_sequence_item::type_id::create("pkt"); 
      seq_item_port.get_next_item(pkt);
      `uvm_info(get_type_name(), $sformatf("Generated packet fields: %p", pkt), UVM_LOW)
      `uvm_info(get_type_name(), $sformatf("pkt_id %0d, payload_size = %0d", pkt.pkt_id, pkt.payload.size()), UVM_LOW);
      ref_model_port.write(pkt);
      wait (intf.rst_ni);
      first_handshake_seen = 0;
      drive(pkt);
      seq_item_port.item_done();
    end
  endtask: run_phase
  
  
  task drive(eth_sequence_item pkt);
    temp_pkt   = {pkt.dest_mac, pkt.src_mac, pkt.eth_type, pkt.payload};
    display_pkt(temp_pkt);

    num_flits  = (temp_pkt.size() + 7) / 8;
    bytes_rem  = temp_pkt.size();
    `uvm_info(get_type_name(), $sformatf("pkt_id %0d, packet size = %0d", pkt.pkt_id, temp_pkt.size()), UVM_LOW);

    for(int i=0; i<num_flits; i++) begin //Loop for one whole packet
      eth_sequence_item flit;
      flit = eth_sequence_item::type_id::create("flit");
      @(posedge intf.clk_i);
      flit.tx_axis_tdata_i  = 64'd0;
      
      if(i==num_flits-1) begin //Last flit
        for (int j = 0; j < bytes_rem; j++) begin
          flit.tx_axis_tdata_i[j*8 +: 8] = temp_pkt[i*8 + j];
        end
        `uvm_info(get_type_name(), $sformatf("pkt_id %0d, remaining bytes = %0d", pkt.pkt_id, bytes_rem), UVM_LOW);
        if(bytes_rem<8) begin
          flit.tx_axis_tstrb_i = ((2**bytes_rem) - 1);
          `uvm_info(get_type_name(), $sformatf("pkt_id %0d, tstrb = %0d", pkt.pkt_id, flit.tx_axis_tstrb_i), UVM_LOW);
        end
        else
          flit.tx_axis_tstrb_i  = 0;
        flit.tx_axis_tkeep_i  = flit.tx_axis_tstrb_i;
        flit.tx_axis_tlast_i  = 1;
      end

      else begin // Not last flit
        for(int j = 0; j < 8; j++) begin
          flit.tx_axis_tdata_i[j*8 +: 8] = temp_pkt[i*8 + j];
        end
        flit.tx_axis_tstrb_i  = 0;
        flit.tx_axis_tkeep_i  = 8'hFF;
        flit.tx_axis_tlast_i  = 0;
      end

      //Signals for every transaction
      flit.tx_axis_tid_i      = 0;
      flit.tx_axis_tdest_i    = 0;
      flit.tx_axis_tuser_i    = 0;
      flit.tx_axis_tvalid_i   = 1;
      flit.rx_axis_tready_i   = 1;
      bytes_rem = temp_pkt.size() - ((i+1)*8);

      // Drive on Interface
      intf.phy_int_n        = flit.phy_int_n         ;
      intf.phy_pme_n        = flit.phy_pme_n         ;
      intf.phy_mdio_i       = flit.phy_mdio_i        ;
      // Implementing AXIS Master
      intf.tx_axis_tdata_i  = flit.tx_axis_tdata_i   ;
      intf.tx_axis_tstrb_i  = flit.tx_axis_tstrb_i   ;
      intf.tx_axis_tkeep_i  = flit.tx_axis_tkeep_i   ;
      intf.tx_axis_tlast_i  = flit.tx_axis_tlast_i   ;
      intf.tx_axis_tid_i    = flit.tx_axis_tid_i     ;
      intf.tx_axis_tdest_i  = flit.tx_axis_tdest_i   ;
      intf.tx_axis_tuser_i  = flit.tx_axis_tuser_i   ;
      intf.tx_axis_tvalid_i = flit.tx_axis_tvalid_i  ;
      intf.rx_axis_tready_i = flit.rx_axis_tready_i  ;
      intf.reg_bus_addr_i   = flit.reg_bus_addr_i    ;
      intf.reg_bus_write_i  = flit.reg_bus_write_i   ;
      intf.reg_bus_wdata_i  = flit.reg_bus_wdata_i   ;
      intf.reg_bus_wstrb_i  = flit.reg_bus_wstrb_i   ;
      intf.reg_bus_valid_i  = flit.reg_bus_valid_i   ;

      if(intf.tx_axis_tvalid_i && intf.tx_axis_tready_o && !first_handshake_seen) begin
        start_time_axi = $realtime;
        first_handshake_seen = 1;
        `uvm_info("DRV_TIME", $sformatf("AXI start = %0t", start_time_axi), UVM_LOW)
      end


      do begin
        @(posedge intf.clk_i);
      end while (!intf.tx_axis_tready_o);
    end // End of loop, packet transfer complete

    //Deassert tlast when a packet ends
    @(posedge intf.clk_i);
    intf.tx_axis_tlast_i  = 0;
    intf.tx_axis_tvalid_i = 0;
    
  endtask: drive

  function void display_pkt(byte unsigned my_array[]);
    string msg = "\n";
    foreach (my_array[i]) begin
      msg = {msg, $sformatf("%02h ", my_array[i])};
      if ((i + 1) % 16 == 0) msg = {msg, "\n"};
    end
    `uvm_info("pkt_from_sequence", msg, UVM_LOW)
  endfunction
  
endclass: eth_driver