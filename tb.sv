`timescale 1ns/1ps
`include "apb_interface.sv"
`include "apb_master.sv"

module tb_apb();
    logic clk, reset;
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
        #10;

        $display("\n\t=====[TEST] Test 1. Reset values =====");
        apb_master.read(8'h00); // Read DATA register
        apb_master.read(8'h04); // Read CONTROL register  
        apb_master.read(8'h08); // Read RESULT register
        #15;

        $display("\n\t=====[TEST] Test 2. First OR accumulation =====");
        apb_master.write(8'h00, 32'h0000000C); // Write to DATA register
        apb_master.write(8'h04, 32'h00000001); // Write to CONTROL register with start bit (01)
        apb_master.read(8'h08); // Read RESULT register
        #15;

        $display("\n\t=====[TEST] Test 3. Second OR accumulation =====");
        apb_master.write(8'h00, 32'h000000B0); // Write new value to DATA
        apb_master.write(8'h04, 32'h00000001); // Start operation (01)
        apb_master.read(8'h08); // Read RESULT register
        #15;

        $display("\n\t=====[TEST] Test 4. Test control_reg[1] - reset bit =====");
        apb_master.write(8'h04, 32'h00000002); // Set reset bit (10)
        apb_master.read(8'h08); // Read RESULT register - should be 0
        #15;

        $display("\n\t=====[TEST] Test 5. Third OR accumulation after reset =====");
        apb_master.write(8'h00, 32'h00000A00); // Write new value to DATA
        apb_master.write(8'h04, 32'h00000001); // Start operation (01)
        apb_master.read(8'h08); // Read RESULT register
        #15;

        $display("\n\t=====[TEST] Test 6. Test both bits set (11) =====");
        apb_master.write(8'h00, 32'h12345678); // Write some data
        apb_master.write(8'h04, 32'h00000003); // Set both start and reset bits (11)
        apb_master.read(8'h08); // Read RESULT register - reset should have priority
        #15;

        $display("\n\t=====[TEST] Test 7. Read all registers =====");
        apb_master.read(8'h00); // DATA
        apb_master.read(8'h04); // CONTROL  
        apb_master.read(8'h08); // RESULT
        #15;

        $display("\n\t=====[TEST] Test 8. Invalid address =====");
        apb_master.write(8'h0C, 32'h12345678); // Attempt to write to invalid address
        #15;

        $display("\n\t=====[TEST] Test 9. Write to CONTROL without operation bits =====");
        apb_master.write(8'h04, 32'h00000000); // Write to CONTROL without any bits (00)
        apb_master.read(8'h04); // Verify CONTROL register
        #15;

        $display("\n\t=====[TEST] Test 10. Write to RESULT register (should error) =====");
        apb_master.write(8'h08, 32'hFFFFFFFF); // Attempt to write to read-only RESULT
        #15;

        $display("\n\t=====[TEST] Test 11. Multiple operations with reset =====");
        apb_master.write(8'h00, 32'h11111111);
        apb_master.write(8'h04, 32'h00000001); // OR accumulation
        apb_master.read(8'h08);
        
        apb_master.write(8'h00, 32'h22222222);
        apb_master.write(8'h04, 32'h00000001); // OR accumulation
        apb_master.read(8'h08);
        
        apb_master.write(8'h04, 32'h00000002); // Reset result
        apb_master.read(8'h08);
        
        apb_master.write(8'h00, 32'h33333333);
        apb_master.write(8'h04, 32'h00000001); // OR accumulation from zero
        apb_master.read(8'h08);
        #15;

        $display("\n\t=====[TEST] Test 12. Test all bit patterns with reset =====");
        apb_master.write(8'h00, 32'h55555555);
        apb_master.write(8'h04, 32'h00000001);
        apb_master.read(8'h08);
        
        apb_master.write(8'h00, 32'hAAAAAAAA);
        apb_master.write(8'h04, 32'h00000001);
        apb_master.read(8'h08);
        
        apb_master.write(8'h04, 32'h00000002); // Reset
        apb_master.read(8'h08);
        
        apb_master.write(8'h00, 32'hFFFFFFFF);
        apb_master.write(8'h04, 32'h00000001);
        apb_master.read(8'h08);
        #15;

        $display("\n\t=====[TEST] Test 13. Final state check =====");
        apb_master.read(8'h00); // DATA
        apb_master.read(8'h04); // CONTROL  
        apb_master.read(8'h08); // RESULT
        #15;

        $display("\n\t=====[ALL TESTS COMPLETED] =====");
        $finish;
    end

endmodule
