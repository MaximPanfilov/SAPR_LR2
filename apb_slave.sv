module apb_slave(apb_interface apb_if);

    // Device registers
    logic [31:0] data_reg;      // Data register (value to add)
    logic [31:0] control_reg;   // Control register
    logic [31:0] result_reg;    // Result register (current accumulated result)
    logic bitt; //[HACK:]

    // Register address definitions
    localparam DATA_ADDR    = 32'h0;
    localparam CONTROL_ADDR = 32'h4; 
    localparam RESULT_ADDR  = 32'h8;

    always_ff @(posedge apb_if.PCLK or negedge apb_if.PRESETn) begin
        if (!apb_if.PRESETn) begin
            // Reset registers
            data_reg <= 32'h0;
            control_reg <= 32'h0;
            result_reg <= 32'h0;
            apb_if.PREADY <= 1'b0;
            apb_if.PSLVERR <= 1'b0;
            apb_if.PRDATA <= 32'h0;
            bitt <= 1'b0;
        end
        else begin
            apb_if.PSLVERR <= 1'b0;
            apb_if.PREADY <= 1'b0;
            
            // Write operations
            if (apb_if.PSEL && apb_if.PENABLE && apb_if.PWRITE) begin
                apb_if.PREADY <= 1'b1;
                
                case (apb_if.PADDR)
                    DATA_ADDR: begin
                        data_reg <= apb_if.PWDATA;
                        $display("[APB_SLAVE] Write DATA register: %h", apb_if.PWDATA);
                    end
                    CONTROL_ADDR: begin
                        control_reg <= apb_if.PWDATA;
                        $display("[APB_SLAVE] Write CONTROL register: %h", apb_if.PWDATA);
                        
                        // If operation start bit is set (bit 0)
                        if (apb_if.PWDATA[0]) begin
                            // Perform OR accumulation operation
                            result_reg <= result_reg | data_reg;
                            $display("[APB_SLAVE] OR accumulation: result = %h | data = %h = new_result = %h", 
                                     result_reg, data_reg, (result_reg | data_reg));
                        end
                    end
                    RESULT_ADDR: begin
                        // Result register is read-only - error on write attempt
                        apb_if.PSLVERR <= 1'b1;
                        $display("[APB_SLAVE] ERROR: Attempt to write to read-only RESULT register");
                    end
                    default: begin
                        apb_if.PSLVERR <= 1'b1;
                        $display("[APB_SLAVE] ERROR: Invalid address %h", apb_if.PADDR);
                    end
                endcase
            end
            
            // Read operations
            if (apb_if.PSEL && apb_if.PENABLE && !apb_if.PWRITE) begin
                apb_if.PREADY <= 1'b1;
                
                case (apb_if.PADDR)
                    DATA_ADDR: begin
                        apb_if.PRDATA <= data_reg;
                        $display("[APB_SLAVE] Read DATA register: %h", data_reg);
                    end
                    CONTROL_ADDR: begin
                        apb_if.PRDATA <= control_reg;
                        $display("[APB_SLAVE] Read CONTROL register: %h", control_reg);
                    end
                    RESULT_ADDR: begin
                        apb_if.PRDATA <= result_reg;
                        $display("[APB_SLAVE] Read RESULT register: %h", result_reg);
                    end
                    default: begin
                        apb_if.PRDATA <= 32'h0;
                        apb_if.PSLVERR <= 1'b1;
                        $display("[APB_SLAVE] ERROR: Invalid address %h", apb_if.PADDR);
                    end
                endcase
            end
            
            // Logic for displaying operations after transaction completion
            if (!apb_if.PSEL) begin
                apb_if.PREADY <= 1'b0;
                if(apb_if.PWRITE) begin 
                    $display("[APB_SLAVE] Write completed: addr = %h, data = %h", apb_if.PADDR, apb_if.PWDATA);  
                    bitt <= 1; 
                end 
                if(!apb_if.PWRITE && bitt) begin 
                    $display("[APB_SLAVE] Read completed: addr = %h, data = %h", apb_if.PADDR, apb_if.PRDATA); 
                    bitt <= 0; 
                end
            end
        end
    end

endmodule
