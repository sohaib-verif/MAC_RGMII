class eth_tx_transaction extends uvm_sequence_item;
  `uvm_object_utils(eth_tx_transaction)

  rand byte unsigned dest_mac [6]        ;
  rand byte unsigned src_mac  [6]        ;
  rand byte unsigned eth_type [2]        ;
  rand byte unsigned payload  [$]        ; //Just Payload
  rand byte unsigned data     [$]        ; //Whole packet
  static int         global_id_count = 0 ;
  int                pkt_id              ;
  
  rand logic       [3:0]                                 phy_rxd          ;
  rand logic                                             phy_rx_ctl       ;
  logic                                                  phy_tx_clk       ;
  logic            [3:0]                                 phy_txd          ;
  logic                                                  phy_tx_ctl       ;
  logic                                                  phy_reset_n      ;
  rand logic                                             phy_int_n        ;
  rand logic                                             phy_pme_n        ;
  // MDI    ;
  rand logic                                             phy_mdio_i       ;
  logic                                                  phy_mdio_o       ;
  logic                                                  phy_mdio_oe      ;
  logic                                                  phy_mdc          ;

  // AXIS TX
  rand logic     [63:0]                                  tx_axis_tdata_i  ;
  rand logic     [7:0]                                   tx_axis_tstrb_i  ;
  rand logic     [7:0]                                   tx_axis_tkeep_i  ;
  rand logic                                             tx_axis_tlast_i  ;
  rand logic                                             tx_axis_tid_i    ;
  rand logic                                             tx_axis_tdest_i  ;
  rand logic                                             tx_axis_tuser_i  ;
  rand logic                                             tx_axis_tvalid_i ;
  logic                                                  tx_axis_tready_o ;
  // AXIS RX
  logic          [63:0]                                  rx_axis_tdata_o  ;
  logic          [7:0]                                   rx_axis_tstrb_o  ;
  logic          [7:0]                                   rx_axis_tkeep_o  ;
  logic                                                  rx_axis_tlast_o  ;
  logic                                                  rx_axis_tid_o    ;
  logic                                                  rx_axis_tdest_o  ;
  logic                                                  rx_axis_tuser_o  ;
  logic                                                  rx_axis_tvalid_o ;
  rand logic                                             rx_axis_tready_i ;

  // configuration (register interface)
  rand logic     [3:0]                                   reg_bus_addr_i   ;
  rand logic                                             reg_bus_write_i  ;
  rand logic     [31:0]                                  reg_bus_wdata_i  ;
  rand logic     [3:0]                                   reg_bus_wstrb_i  ;
  rand logic                                             reg_bus_valid_i  ;
  logic          [31:0]                                  reg_bus_rdata_o  ;
  logic                                                  reg_bus_error_o  ;
  logic                                                  reg_bus_ready_o  ;

  function new(string name = "eth_tx_transaction");
    super.new(name);
  endfunction: new

  constraint c_payload_size {soft payload.size() inside {[46:1500]};}
  constraint c_total_size_64_multiple {soft (14 + payload.size()) % 8 == 0;}

  function void post_randomize();
    global_id_count++;            // Increment the master
    pkt_id = global_id_count;
  endfunction

endclass: eth_tx_transaction
  
