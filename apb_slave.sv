module apb_slave(apb_interface apb_if);

    // Device registers
    logic [31:0] data_reg;      // Data register (value to add)
    logic [1:0] control_reg;   // Control register
    logic [31:0] result_reg;    // Result register (current accumulated result)
    logic display_flag;         // Flag to control display

    // Register address definitions
    localparam DATA_ADDR    = 8'h00;  // ???????? ?? 8 ???
    localparam CONTROL_ADDR = 8'h04;   // ???????? ?? 8 ???
    localparam RESULT_ADDR  = 8'h08;   // ???????? ?? 8 ???

    always_ff @(posedge apb_if.PCLK or negedge apb_if.PRESETn) begin
        if (!apb_if.PRESETn) begin
            // Reset registers
            data_reg <= 32'h0;
            control_reg <= 2'b00;     // ???????? ?? 2 ????
            result_reg <= 32'h0;
            apb_if.PREADY <= 1'b0;
            apb_if.PSLVERR <= 1'b0;
            apb_if.PRDATA <= 32'h0;
            display_flag <= 1'b0;
        end
        else begin
            apb_if.PSLVERR <= 1'b0;
            apb_if.PREADY <= 1'b0;
            
            // Write operations
            if (apb_if.PSEL && apb_if.PENABLE && apb_if.PWRITE) begin
                apb_if.PREADY <= 1'b1;
                display_flag <= 1'b1; // Set flag for display
                
                case (apb_if.PADDR)
                    DATA_ADDR: begin
                        data_reg <= apb_if.PWDATA;
                    end
                    CONTROL_ADDR: begin
                        control_reg <= apb_if.PWDATA[1:0];  // ????? ?????? ??????? 2 ????
                        
                        // If operation start bit is set (bit 0)
                        if (apb_if.PWDATA[0]) begin
                            // Perform OR accumulation operation
                            result_reg <= result_reg | data_reg;
                        end
                    end
                    RESULT_ADDR: begin
                        // Result register is read-only - error on write attempt
                        apb_if.PSLVERR <= 1'b1;
                    end
                    default: begin
                        apb_if.PSLVERR <= 1'b1;
                    end
                endcase
            end
            
            // Read operations
            if (apb_if.PSEL && apb_if.PENABLE && !apb_if.PWRITE) begin
                apb_if.PREADY <= 1'b1;
                display_flag <= 1'b1; // Set flag for display
                
                case (apb_if.PADDR)
                    DATA_ADDR: begin
                        apb_if.PRDATA <= data_reg;
                    end
                    CONTROL_ADDR: begin
                        apb_if.PRDATA <= {30'b0, control_reg};  // ????????? ?? 32 ???
                    end
                    RESULT_ADDR: begin
                        apb_if.PRDATA <= result_reg;
                    end
                    default: begin
                        apb_if.PRDATA <= 32'h0;
                        apb_if.PSLVERR <= 1'b1;
                    end
                endcase
            end
            
            // Display operations after transaction completion
            if (!apb_if.PSEL && display_flag) begin
                apb_if.PREADY <= 1'b0;
                display_flag <= 1'b0; // Reset flag
                
                if(apb_if.PWRITE) begin 
                    // Write operation display
                    case (apb_if.PADDR)
                        DATA_ADDR: begin
                            $display("[APB_SLAVE] Write DATA register: %h", data_reg);
                        end
                        CONTROL_ADDR: begin
                            $display("[APB_SLAVE] Write CONTROL register: %h", control_reg);
                            if (control_reg[0]) begin
                                $display("[APB_SLAVE] OR accumulation: result = %h", result_reg);
                            end
                        end
                        RESULT_ADDR: begin
                            $display("[APB_SLAVE] ERROR: Attempt to write to read-only RESULT register");
                        end
                        default: begin
                            $display("[APB_SLAVE] ERROR: Invalid address %h", apb_if.PADDR);
                        end
                    endcase
                end 
                else begin 
                    // Read operation display
                    case (apb_if.PADDR)
                        DATA_ADDR: begin
                            $display("[APB_SLAVE] Read DATA register: %h", data_reg);
                        end
                        CONTROL_ADDR: begin
                            $display("[APB_SLAVE] Read CONTROL register: %h", control_reg);
                        end
                        RESULT_ADDR: begin
                            $display("[APB_SLAVE] Read RESULT register: %h", result_reg);
                        end
                        default: begin
                            $display("[APB_SLAVE] ERROR: Invalid address %h", apb_if.PADDR);
                        end
                    endcase
                end
            end
        end
    end

endmodule
