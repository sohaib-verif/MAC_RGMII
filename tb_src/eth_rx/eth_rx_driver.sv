/*-------------------------------------------------------------------------
File name   : eth_rx_driver.sv
Project     : RX UVC
---------------------------------------------------------------------------*/

class eth_rx_driver extends uvm_driver #(eth_rx_transaction);

    // The virtual interface used to drive and view HDL signals.
    protected virtual eth_rx_interface eth_rx_vif;
  
    eth_rx_config cfg; 
    // Agent Id
	protected int agent_id;
	uvm_analysis_port #(eth_rx_transaction) item_derived_port;
	
    // Provide implmentations of virtual methods such as get_type_name and create
    `uvm_component_utils_begin(eth_rx_driver)
      `uvm_field_int(agent_id, UVM_ALL_ON)
    `uvm_component_utils_end
  
    // new - constructor
    function new (string name, uvm_component parent);
	  super.new(name, parent);
	  item_derived_port = new("item_derived_port", this);
    endfunction : new

	task send_byte(input [7:0] data);
		// LSB nibble (negedge)
		@(negedge eth_rx_vif.phy_rx_clk);
		eth_rx_vif.phy_rxd    <= data[3:0];
		// MSB nibble (posedge)
		@(posedge eth_rx_vif.phy_rx_clk);
		eth_rx_vif.phy_rxd    <= data[7:4];
	endtask  : send_byte

	function bit [31:0] calc_crc32(byte unsigned data[$]);

    bit [31:0] crc = 32'hFFFFFFFF;

    foreach(data[i]) begin
      crc ^= data[i];
      repeat(8) begin
        if(crc[0])
          crc = (crc >> 1) ^ 32'hEDB88320;
        else
          crc = crc >> 1;
      end
    end
    return ~crc;
  endfunction

      // Additional class methods
	extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual protected task get_and_drive();
    extern virtual protected task reset_signals();
    extern virtual protected task drive_transfer (eth_rx_transaction trans);
    extern virtual protected task regs_config (eth_rx_transaction trans);  
endclass : eth_rx_driver

// build
function void eth_rx_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    // get virtual interface
    if(!uvm_config_db#(virtual eth_rx_interface)::get(this, "", "eth_rx_vif", eth_rx_vif))
        `uvm_fatal(get_name(),"No eth_rx_vif is set for this instance")
endfunction

// run phase
task eth_rx_driver::run_phase(uvm_phase phase);
	fork
	get_and_drive();
	reset_signals();
	join
endtask
  
// get_and_drive
task eth_rx_driver::get_and_drive();
	eth_rx_transaction this_trans;
	@(posedge eth_rx_vif.rst_ni);
	`uvm_info(get_type_name(), "Reset Done", UVM_LOW)
	forever begin
		@(negedge eth_rx_vif.clk_i);	@(negedge eth_rx_vif.clk_i);
		seq_item_port.get_next_item(req);
		if (!$cast(this_trans, req))
			uvm_report_fatal("CASTFL", "Failed to cast req to this_trans in get_and_drive");
		`uvm_info(get_type_name(), $sformatf("RX Start Driving Transfer \n%s",this_trans.sprint()), UVM_NONE)
		// fork
			// begin : clk_gen
			// 	while (eth_rx_vif.rst_ni) begin
			// 		eth_rx_vif.phy_rx_clk <= ~eth_rx_vif.phy_rx_clk;
			// 		#(8/2);
			// 	end
			// end

			// begin : drive_data
				@(negedge eth_rx_vif.phy_rx_clk);	@(negedge eth_rx_vif.phy_rx_clk);	@(negedge eth_rx_vif.phy_rx_clk);	#2;
				if (this_trans.regs_config_seq)
					regs_config(this_trans);
				else
					drive_transfer(this_trans);
				item_derived_port.write(this_trans);
				repeat (3) @(posedge eth_rx_vif.clk_i);
			// end
		// join
		`uvm_info(get_type_name(), "\nEND of DRIVE TRANSFER\n", UVM_LOW)
		seq_item_port.item_done();
	end
endtask : get_and_drive
  
// reset_signals
task eth_rx_driver::reset_signals();
	@(negedge eth_rx_vif.rst_ni);
	`uvm_info(get_type_name(), "Reset Observed", UVM_LOW)
	// update 
	eth_rx_vif.phy_rxd <= 1'b0;
	eth_rx_vif.phy_rx_ctl <= 1'b0;
	
endtask : reset_signals
  
// drive_transfer
task eth_rx_driver::drive_transfer (eth_rx_transaction trans);
int frame_size;
bit [31:0] fcs_crc;
	eth_rx_vif.rx_axis_tready_i 		<=  1;
	eth_rx_vif.reg_bus_addr_i 		<=  'b0;
	eth_rx_vif.reg_bus_write_i 		<=  'b0;
	eth_rx_vif.reg_bus_wdata_i 		<=  'b0;
	eth_rx_vif.reg_bus_valid_i 		<=  'b0;
	eth_rx_vif.reg_bus_wstrb_i 		<=  'b0;
	repeat (3) @(negedge eth_rx_vif.phy_rx_clk);
	@(negedge eth_rx_vif.phy_rx_clk);
	eth_rx_vif.phy_rx_ctl 		<=  1;
	// Step.1: Send Preamble (7 Bytes)
	// Step.2: Send SFD (1 Byte)
	repeat (7) send_byte(8'h55); // preamble
	send_byte(8'hD5);            // SFD
	// Step.3: Send Destination Address (6 Bytes)
	send_byte(8'h32);            // 
	send_byte(8'h10);            // 
	send_byte(8'h00);            // 
	send_byte(8'h98);            // 
	send_byte(8'h70);            // 
	send_byte(8'h20);            // 
	// Step.3: Send Source Address (6 Bytes)
	send_byte(8'h32);            // 
	send_byte(8'h10);            // 
	send_byte(8'h00);            // 
	send_byte(8'h98);            // 
	send_byte(8'h70);            // 
	send_byte(8'h20);            // 
	// Step.4: Send Ethernet Type (2 Bytes)
	send_byte(trans.eth_type[0]);            // 
	send_byte(trans.eth_type[1]);            // 
	// Step.5: Send Ethernet Frame (2 Bytes)
	frame_size = trans.payload.size();
	while (frame_size > 0) begin
		send_byte(trans.payload[frame_size -1]);            // 
		frame_size = frame_size -1;
	end
	// Step.6: Send FCS (4 Bytes)
	fcs_crc = calc_crc32(trans.payload);
	send_byte(fcs_crc[31:24]);            // 
	send_byte(fcs_crc[23:16]);            // 
	send_byte(fcs_crc[15:8]);            // 
	send_byte(fcs_crc[7:0]);            // 

	// `uvm_info(get_name(), $sformatf("length = %01d", length), UVM_LOW)
	// `uvm_info(get_type_name(), $sformatf("\n \nTransfer data = %b \nmiso = %b\nmosi = %b\n",trans.trans_data, eth_rx_vif.miso_pad_i, eth_rx_vif.mosi_pad_o ), UVM_NONE)
	// item_derived_port.write(trans);
	// `uvm_info(get_type_name(),$sformatf(" Before triggering the event"),UVM_LOW)
	// do begin
		
	// @(posedge eth_rx_vif.clk_i);
	// end
	// while(rdata==1);
	// `uvm_info(get_type_name(),$sformatf("rdata after = %h",rdata),UVM_LOW)
endtask : drive_transfer

task eth_rx_driver::regs_config (eth_rx_transaction trans);
	eth_rx_vif.reg_bus_addr_i 		<=  trans.reg_addr;
	eth_rx_vif.reg_bus_write_i 		<=  trans.reg_write;
	eth_rx_vif.reg_bus_wdata_i 		<=  trans.reg_write_data;
	eth_rx_vif.reg_bus_valid_i 		<=  trans.reg_valid;
	eth_rx_vif.reg_bus_wstrb_i 		<=  trans.reg_wstrb;
	#8;
endtask : regs_config


