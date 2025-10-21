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
        apb_master.read('h0); // Read DATA register
        apb_master.read('h4); // Read CONTROL register  
        apb_master.read('h8); // Read RESULT register
        #15;

        $display("\n\t=====[TEST] Test 2. First OR accumulation =====");
        apb_master.write('h0, 32'h0000000C); // Write to DATA register
        apb_master.write('h4, 32'h00000001); // Write to CONTROL register with start bit
        apb_master.read('h8); // Read RESULT register
        #15;

        $display("\n\t=====[TEST] Test 3. Second OR accumulation =====");
        apb_master.write('h0, 32'h000000B0); // Write new value to DATA
        apb_master.write('h4, 32'h00000001); // Start operation
        apb_master.read('h8); // Read RESULT register
        #15;

        $display("\n\t=====[TEST] Test 4. Third OR accumulation =====");
        apb_master.write('h0, 32'h00000A00); // Write new value to DATA
        apb_master.write('h4, 32'h00000001); // Start operation
        apb_master.read('h8); // Read RESULT register
        #15;

        $display("\n\t=====[TEST] Test 5. Read all registers =====");
        apb_master.read('h0); // DATA
        apb_master.read('h4); // CONTROL  
        apb_master.read('h8); // RESULT
        #15;

        $display("\n\t=====[TEST] Test 6. Invalid address =====");
        apb_master.write('hC, 32'h12345678); // Attempt to write to invalid address
        #15;

        // ?????????????? ????? ??? ???????? ???? ??????
        $display("\n\t=====[TEST] Test 7. Write to CONTROL without start bit =====");
        apb_master.write('h4, 32'h00000000); // Write to CONTROL without start bit
        apb_master.read('h4); // Verify CONTROL register
        #15;

        $display("\n\t=====[TEST] Test 8. Write to RESULT register (should error) =====");
        apb_master.write('h8, 32'hFFFFFFFF); // Attempt to write to read-only RESULT
        #15;

        $display("\n\t=====[TEST] Test 9. Multiple invalid addresses =====");
        apb_master.write('h10, 32'h11111111); // Invalid address
        apb_master.write('h14, 32'h22222222); // Invalid address  
        apb_master.write('h18, 32'h33333333); // Invalid address
        #15;

        $display("\n\t=====[TEST] Test 10. Read from invalid addresses =====");
        apb_master.read('h10); // Invalid address
        apb_master.read('h14); // Invalid address
        apb_master.read('h18); // Invalid address
        #15;

        $display("\n\t=====[TEST] Test 11. Test all bit patterns =====");
        // ????????? ????????? ??????? ????????
        apb_master.write('h0, 32'h55555555); // Alternating bits
        apb_master.write('h4, 32'h00000001); // Start operation
        apb_master.read('h8); // Read result
        
        apb_master.write('h0, 32'hAAAAAAAA); // Alternating bits (inverted)
        apb_master.write('h4, 32'h00000001); // Start operation
        apb_master.read('h8); // Read result
        
        apb_master.write('h0, 32'hFFFFFFFF); // All ones
        apb_master.write('h4, 32'h00000001); // Start operation
        apb_master.read('h8); // Read result
        
        apb_master.write('h0, 32'h00000000); // All zeros
        apb_master.write('h4, 32'h00000001); // Start operation
        apb_master.read('h8); // Read result
        #15;

        $display("\n\t=====[TEST] Test 12. Final state check =====");
        apb_master.read('h0); // DATA
        apb_master.read('h4); // CONTROL  
        apb_master.read('h8); // RESULT
        #15;

        $display("\n\t=====[ALL TESTS COMPLETED] =====");
        $finish;
    end

endmodule
