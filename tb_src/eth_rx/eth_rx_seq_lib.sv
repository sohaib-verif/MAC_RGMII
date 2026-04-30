/*-------------------------------------------------------------------------
File name   : pt_seq_lib.sv
Project     : SPI UVC
---------------------------------------------------------------------------*/

    // Add more classes of sequences below
class eth_rx_basic_seq extends uvm_sequence#(eth_rx_transaction);

    `uvm_object_utils(eth_rx_basic_seq)

    function new(string name = "eth_rx_basic_seq");
        super.new(name);
    endfunction
    task body();  
        `uvm_do_with(req,{req.regs_config_seq == 1; req.reg_addr == 0;  req.reg_write == 1;   req.reg_valid == 1;  
        req.reg_wstrb == 4'hf; req.reg_write_data == 32'h9800_1032;})

        `uvm_do_with(req,{req.regs_config_seq == 1; req.reg_addr == 0;  req.reg_write == 0;   req.reg_valid == 0;  
        req.reg_wstrb == 4'h0; req.reg_write_data == 32'h0;})

        `uvm_do_with(req,{req.regs_config_seq == 1; req.reg_addr == 4;  req.reg_write == 1;   req.reg_valid == 1;  
        req.reg_wstrb == 4'hf; req.reg_write_data == 32'h2070;})

        `uvm_do_with(req,{req.regs_config_seq == 0; req.eth_type[0] == 8'h00;   req.eth_type[1] == 8'hE2;   req.payload.size() == 64;
        req.reg_wstrb == 4'hf; req.reg_write_data == 32'h2070;})
    endtask

endclass:eth_rx_basic_seq

