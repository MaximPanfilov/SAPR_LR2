`timescale 1ns/1ps
`include "apb_interface.sv"
`include "apb_master.sv"

module tb_apb();
    logic clk, reset, rdata;
    apb_interface apb_if();

    initial begin
        clk = 0;
        reset = 0;
        #20 reset = 1;
        forever #5 clk = ~clk;
    end

    assign apb_if.PCLK = clk;
    assign apb_if.PRESETn = reset;

    apb_slave apb_slave (apb_if.slave_mp);
    apb_master apb_master (apb_if.master_mp);
    
   initial begin
	@(posedge reset);

	$display("\n\t=====[TEST] test 1. Write and Read position in group list =====");
	apb_master.write('h0, 9);
	apb_master.read(0);
	#15;
	$display("\n\t=====[TEST] test 2. Write and Read date =====");
	apb_master.write('h4, 'h19102025); //19.10.2025
	apb_master.read('h4);
	#15;
	$display("\n\t=====[TEST] test 3. Write and Read second name =====");
	apb_master.write('h8, 'h666E6150); //Panf
	apb_master.read('h8);
	#15;
	$display("\n\t=====[TEST] test 4. Write and Read first name =====");
	apb_master.write('hC, 'h736B614D); //Maks
	apb_master.read('hC);
	#15;
    end

endmodule

