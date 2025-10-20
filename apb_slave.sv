module apb_slave(apb_interface apb_if);

    logic [7:0] memory [0:15]; 
    logic bitt;  //[HACK: ] fixes endless display in the end

    always_ff @(posedge apb_if.PCLK or negedge apb_if.PRESETn) begin
        if (!apb_if.PRESETn) begin
            apb_if.PREADY <= 1'b0; 
            apb_if.PSLVERR <= 1'b0;
	    foreach (memory[i]) memory[i] = 0;
		
        end
	if (apb_if.PSEL && apb_if.PENABLE && apb_if.PWRITE) begin
	    	apb_if.PSLVERR <= 1'b0; 
		apb_if.PREADY <= 1'b1;

		if(apb_if.PADDR!=0 && apb_if.PADDR!=4 && apb_if.PADDR!=8 && apb_if.PADDR!=12) begin
			$display("[APB_SLAVE] ERROR: addr isn't in range");
			apb_if.PSLVERR <= 1;
		end

		memory[apb_if.PADDR][7:0] <= apb_if.PWDATA[7:0];
		memory[apb_if.PADDR+1][7:0] <= apb_if.PWDATA[15:8];
		memory[apb_if.PADDR+2][7:0] <= apb_if.PWDATA[23:16];
		memory[apb_if.PADDR+3][7:0] <= apb_if.PWDATA[31:24];

            end // PSEL && PENABLE && PWRITE
            

            if (apb_if.PSEL && apb_if.PENABLE && !apb_if.PWRITE) begin
		apb_if.PREADY <= 1'b1;
		apb_if.PRDATA[7:0] <= memory[apb_if.PADDR][7:0]; 
		apb_if.PRDATA[15:8] <= memory[apb_if.PADDR+1][7:0]; 
		apb_if.PRDATA[23:16] <= memory[apb_if.PADDR+2][7:0]; 
		apb_if.PRDATA[31:24] <= memory[apb_if.PADDR+3][7:0]; 

            end // PSEL && PENABLE && !PWRITE

	if (!apb_if.PSEL) begin 
		apb_if.PREADY <= 1'b0;
		if(apb_if.PWRITE) begin $display("[APB_SLAVE] write in adr = %h data = %h", apb_if.PADDR, apb_if.PWDATA);  bitt <= 1; end 
		if(!apb_if.PWRITE && bitt) begin $display("[APB_SLAVE] read from adr = %h data = %h", apb_if.PADDR, apb_if.PRDATA); bitt <= 0; end
	end
    end //always
endmodule 

