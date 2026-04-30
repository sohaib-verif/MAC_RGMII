/*-------------------------------------------------------------------------
File name   : scoreboard.sv
Project     : SPI VIP
---------------------------------------------------------------------------*/
import eth_rx_pkg::eth_rx_transaction;

`uvm_analysis_imp_decl(_wb_drv)
`uvm_analysis_imp_decl(_wb_mon)
`uvm_analysis_imp_decl(_eth_rx_drv)
`uvm_analysis_imp_decl(_eth_rx_mon)

class scoreboard extends uvm_scoreboard;
	int i=0;
	  
  `uvm_component_utils(scoreboard)

	// Analysis imports
	uvm_analysis_imp_wb_mon#(wb_transaction, scoreboard) wb_mon_export;
	uvm_analysis_imp_eth_rx_mon#(eth_rx_transaction, scoreboard) eth_rx_mon_export;
	uvm_analysis_imp_wb_drv#(wb_transaction, scoreboard) wb_drv_export;
	uvm_analysis_imp_eth_rx_drv#(eth_rx_transaction, scoreboard) eth_rx_drv_export;
	// tlm fifos
	uvm_tlm_fifo #(wb_transaction) wb_outfifo;
	uvm_tlm_fifo #(wb_transaction) wb_expfifo;
	uvm_tlm_fifo #(eth_rx_transaction) eth_rx_outfifo;
	uvm_tlm_fifo #(eth_rx_transaction) eth_rx_expfifo;
	// temporary memories
	bit [31:0] wb_mem [0:255];
	bit [31:0] eth_rx_mem [0:255];
	//int num_pass, num_fail;
	
	function new(string name, uvm_component parent);
		super.new(name,parent);
		wb_mon_export = new("wb_mon_export", this);
		wb_drv_export = new("wb_drv_export", this);
		eth_rx_drv_export = new("eth_rx_drv_export", this);
		eth_rx_mon_export = new("eth_rx_mon_export", this);

		wb_outfifo = new("wb_outfifo", this);
		wb_expfifo = new("wb_expfifo", this);
		eth_rx_outfifo = new("eth_rx_outfifo", this);
		eth_rx_expfifo = new("eth_rx_expfifo", this);
	endfunction
	
	// write functions
	extern function void write_wb_mon(wb_transaction tr);
	extern function void write_eth_rx_mon(eth_rx_transaction t);
	extern function void write_wb_drv(wb_transaction tr);
	extern function void write_eth_rx_drv(eth_rx_transaction t);
	extern function void report_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	extern function void update_wb_mem(wb_transaction tr);
	extern function void update_eth_rx_mem(wb_transaction tr);
	extern virtual task compare(wb_transaction tr1,eth_rx_transaction tr2,int a);
	extern virtual task compare_miso(wb_transaction tr1,eth_rx_transaction tr2,int a);
endclass:scoreboard


  function void scoreboard::write_wb_mon(wb_transaction tr);
	
	`uvm_info(get_type_name(), $sformatf("write wb_mon: \n%s",tr.sprint()), UVM_LOW) 
	if(wb_outfifo.is_empty()) begin
		`uvm_info(get_type_name(), $sformatf("write wb_mon: wb_outfifo is empty put %d ",i), UVM_LOW) 
	end
	else begin
		`uvm_info(get_type_name(), $sformatf("write wb_mon: wb_outfifo is not empty put %d ",i), UVM_LOW) 
	end
	`uvm_info(get_type_name(), $sformatf("write wb_mon: wb_outfifo size put %d",wb_outfifo.size()), UVM_LOW) 

	void'(wb_outfifo.try_put(tr));
	update_eth_rx_mem(tr);
	i++;
  endfunction 

  function void scoreboard::write_eth_rx_mon(eth_rx_transaction t);
	`uvm_info(get_type_name(), $sformatf("write eth_rx_mon: \n%s",t.sprint()), UVM_LOW)
	void'(eth_rx_outfifo.try_put(t));
  endfunction 

  function void scoreboard::write_wb_drv(wb_transaction tr);
	`uvm_info(get_type_name(), $sformatf("write wb_drv: \n%s",tr.sprint()), UVM_LOW)
	void'(wb_expfifo.try_put(tr));
	update_wb_mem(tr);
  endfunction 
  function void scoreboard::write_eth_rx_drv(eth_rx_transaction t);
	`uvm_info(get_type_name(), $sformatf("write eth_rx_drv: \n%s",t.sprint()), UVM_LOW)
	void'(eth_rx_expfifo.try_put(t));
  endfunction
	function void scoreboard::update_wb_mem(wb_transaction tr);
		if(tr.wb_write==1) begin
			`uvm_info(get_type_name(), $sformatf("\n wb_mem[%h]: = %h \n",tr.wb_addr,tr.wb_data), UVM_LOW)
			wb_mem[tr.wb_addr] = tr.wb_data;
		end
	endfunction
	function void scoreboard::update_eth_rx_mem(wb_transaction tr);
		if(tr.wb_write==0) begin
			`uvm_info(get_type_name(), $sformatf("\n eth_rx_mem[%h]: = %h \n",tr.wb_addr,tr.wb_data), UVM_LOW)

			eth_rx_mem[tr.wb_addr] = tr.wb_data;
			`uvm_info(get_type_name(), $sformatf("\n eth_rx_mem[%h]: = %h \n",tr.wb_addr,eth_rx_mem[tr.wb_addr]), UVM_LOW)
		end
		endfunction
	 task scoreboard::compare(wb_transaction tr1,eth_rx_transaction tr2,int a);
		bit [127:0] expected_data;
		int length;
		//if(tr1.wb_write==0) begin
		expected_data = {wb_mem['hc],wb_mem['h8],wb_mem['h4],wb_mem['h0]};

		if(a[6:0]==0)
		length = 128;
		else
		length = a[6:0];

		for(int i=0; i <length; i++) begin
			if (tr2.rec_data[i] == expected_data[i]) begin
				`uvm_info (get_type_name(),$sformatf("\nData Match [MOSI] \nExpected 0x%h \nActual 0x%h", expected_data, tr2.rec_data),UVM_NONE)
			end
			else begin
				`uvm_error (get_type_name(),$sformatf("\nData MisMatch [MOSI] \nExpected: 0x%h \nActual: 0x%h \n Char_length: 0x%h", expected_data, tr2.rec_data, length))
			end
		end
		//end 
		/*else begin 
			if (tr1.wb_data == tr2.wb_data) begin
				`uvm_info (get_type_name(),$sformatf("\nData Match [WRITE] \nExpected %h \nActual %h", tr1.wb_data, tr2.wb_data), UVM_NONE)
			end
			else begin
				`uvm_error (get_type_name(),$sformatf("\nData MisMatch \nExpected %h \nActual %h", tr1.wb_data, tr2.wb_data))
			end
		//end*/
		
	 endtask
	 task scoreboard::compare_miso(wb_transaction tr1,eth_rx_transaction tr2,int a);
		bit [31:0] actual_data;
		bit [31:0] actual_data1;
		bit [31:0] actual_data2;
		bit [31:0] actual_data3;
		int j=0;
		int length;
		//if(tr1.wb_write==0) begin
		actual_data = eth_rx_mem[0]; //eth_rx_mem[0][i]
		actual_data1 = eth_rx_mem['h4];
		actual_data2 = eth_rx_mem['h8];
		actual_data3 = eth_rx_mem['hc];
		//if (a [6:0] >=1 && a[6:0] <=32 ) begin
		if(a[6:0]==0)
		length = 128;
		else
		length = a[6:0];

			for(int i=0; i <length; i++) begin
				if (tr2.trans_data[i] == eth_rx_mem[(i/32)*4][j]) begin
					`uvm_info (get_type_name(),$sformatf("\nData Match [MISO] \nActual (eth_rx_mem[%0d]) 0x%h \nExpected 0x%h", (i/32)*4,eth_rx_mem[(i/32)*4], tr2.trans_data),UVM_NONE)
					`uvm_info(get_type_name(), $sformatf("\n eth_rx_mem[%0d][%0d] = 0x%h: trans2[%0d]= 0x%h \n",(i/32)*4,j,eth_rx_mem[(i/32)*4][j],i,tr2.trans_data[i]), UVM_LOW)
				end
					else begin
					`uvm_error (get_type_name(),$sformatf("\nData MisMatch [MISO] \nActual ((eth_rx_mem[%0d])) 0x%h \nExpected 0x%h \n Char_length: 0x%h", (i/32)*4,eth_rx_mem[(i/32)*4], tr2.trans_data, length[6:0]))
					`uvm_info(get_type_name(), $sformatf("\n eth_rx_mem[%0d][%0d] = 0x%h: trans2[%0d]= 0x%h \n",(i/32)*4,j,eth_rx_mem[(i/32)*4][j],i,tr2.trans_data[i]), UVM_LOW)
				end
				j++;
				if (j==32)
					j=0;
				
			end
		//end
		/*else if (a [6:0] >=33 && a[6:0] <=64 ) begin
			for(int i=0; i <a[6:0]-32; i++) begin
				if (tr2.trans_data[i] == actual_data[i]) begin
					`uvm_info (get_type_name(),$sformatf("\nData Match [MISO] \nActual %h \nExpected %h", actual_data, tr2.trans_data),UVM_NONE)
				end
				else begin
					`uvm_error (get_type_name(),$sformatf("\nData MisMatch [MISO] \nActual %h \nExpected %h", actual_data, tr2.trans_data))
				end
			end
			for(int i=32; i <a[6:0]; i++) begin
				if (tr2.trans_data[i] == actual_data1[i-32]) begin
					`uvm_info (get_type_name(),$sformatf("\nData Match [MISO] \nActual1 %h \nExpected %h", actual_data1, tr2.trans_data),UVM_NONE)
				end
				else begin
					`uvm_error (get_type_name(),$sformatf("\nData MisMatch [MISO] \nActual1 %h \nExpected %h", actual_data1, tr2.trans_data))
				end
			end
		end*/
	 endtask
  task scoreboard::run_phase(uvm_phase phase);
	
	int wb_data;
	int length;
	int j=0;
	wb_transaction wb_exp_tr, wb_out_tr;
	eth_rx_transaction eth_rx_out_tr, eth_rx_exp_tr ;
	super.run_phase(phase);
	`uvm_info(get_type_name(),"scoreboard run phase",UVM_NONE)
	forever begin

	`uvm_info(get_type_name(),"00",UVM_NONE)
		wb_expfifo.get(wb_exp_tr); // wb trans collected in driver
	`uvm_info(get_type_name(),"01",UVM_NONE)
		eth_rx_expfifo.get(eth_rx_exp_tr); // spi trans collected in driver
		
	`uvm_info(get_type_name(),"02",UVM_NONE)
		eth_rx_outfifo.get(eth_rx_out_tr); // spi trans collected in monitor
	`uvm_info(get_type_name(),"03",UVM_NONE)
	// if (!uvm_resource_db#(int)::read_by_name("uvm_test_top.env.scb", "wb_data", wb_data))begin
	// 	//wb_data = -1;
	// 	`uvm_error (get_type_name(), "ERROR")
	// 	end
	// 	else begin
	// 	`uvm_info(get_name(), $sformatf("wb_data = %01h", wb_data), UVM_LOW)
	// end

	if(!uvm_config_db#(int)::get(this, "", "wb_data", wb_data))
	`uvm_fatal(get_name(),"No wb_data is set for this instance")
	else 
	`uvm_info(get_name(), $sformatf("wb_data = %01h", wb_data), UVM_LOW)

	if(wb_data[6:0]==0)
	 	length =128;
	else 
		length = wb_data[6:0];
	for(int i=0; i<=3; i++) begin
		if(wb_outfifo.is_empty()) begin
			`uvm_info(get_type_name(), $sformatf("write wb_mon: wb_outfifo is empty befor get "), UVM_LOW) 
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("write wb_mon: wb_outfifo is not empty befor get"), UVM_LOW) 
		end
		wb_outfifo.get(wb_out_tr); // wb trans collected in monitor
		`uvm_info(get_type_name(),"04",UVM_NONE)
		if(wb_outfifo.is_empty()) begin
			`uvm_info(get_type_name(), $sformatf("write wb_mon: wb_outfifo is empty after get %0d ",j), UVM_LOW) 
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("write wb_mon: wb_outfifo is not empty after get %0d ",j), UVM_LOW) 
		end
	    `uvm_info(get_type_name(), $sformatf("wb_out_tr: \n%s",wb_out_tr.sprint()), UVM_LOW) 


	end
	`uvm_info(get_name(), $sformatf("Before compare"), UVM_LOW)
	
	
		compare(wb_exp_tr,eth_rx_out_tr,wb_data); 
	`uvm_info(get_name(), $sformatf("After compare"), UVM_LOW)

		
		compare_miso(wb_out_tr,eth_rx_exp_tr,wb_data);
		//eth_rx_outfifo.get(out_tr);		// SPI trans collected in driver
		//if (eth_rx_exp_tr.wb_data == eth_rx_out_tr.wb_data) begin
		//	`uvm_info (get_type_name(),$sformatf("Data Match %s",eth_rx_out_tr.sprint()),UVM_NONE)
		//end
		
	end
	
  endtask   

//   function void scoreboard::report_phase(uvm_phase phase);
// 	//`uvm_info(get_type_name(), $sformatf("Report: Number of tests passed: %0d", num_pass), UVM_LOW);
//   endfunction
  

  function void scoreboard::report_phase(uvm_phase phase);
    uvm_report_server svr;
    super.report_phase(phase);
     svr = uvm_report_server::get_server();
//`uvm_info(get_type_name(), "----------TEST PASS------------------", UVM_NONE)
if(svr.get_severity_count(UVM_FATAL)+svr.get_severity_count(UVM_ERROR)>0)
 begin
        `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
        `uvm_info(get_type_name(), "----            TEST FAIL          ----", UVM_NONE)
        `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
     end
   else
 begin
        `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
        `uvm_info(get_type_name(), "----           TEST PASS           ----", UVM_NONE)
        `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
     end
 endfunction