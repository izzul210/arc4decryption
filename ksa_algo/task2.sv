module task2(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

   // your code here

   logic[7:0] address, address_init, address_ksa;
   logic[7:0] data, data_init, data_ksa;
   logic[7:0] mem_out;

   logic wren, wren_init, wren_ksa, sel;
   logic en_init, en_ksa, rdy_init, rdy_ksa;

   logic[3:0] STATE;

    s_mem s( .address(address), .clock(CLOCK_50), .data(data), .wren(wren), .q(mem_out));
    init INIT( .clk(CLOCK_50), .rst_n(KEY[3]), .en(en_init), .rdy(rdy_init), .addr(address_init), .wrdata(data_init), .wren(wren_init));
    ksa KSA( .clk(CLOCK_50), .rst_n(KEY[3]), .en(en_ksa), .rdy(rdy_ksa), .key({14'b0, SW[9:0]}), .addr(address_ksa), .rddata(mem_out), .wrdata(data_ksa), .wren(wren_ksa));

    //assign muxes
    assign wren = sel ? wren_ksa : wren_init;
    assign address = sel ? address_ksa : address_init;
    assign data = sel ? data_ksa : data_init;

    always_ff@(posedge CLOCK_50, negedge KEY[3]) begin
      if(KEY[3] == 0) begin
          STATE <= 4'd0;
      end

      else begin
         case(STATE)
             //INIT START
             4'd0 : begin
                    if(rdy_init == 1'b1) begin
                       en_init <= 1'b1;
                       sel <= 1'b0;
                       
                       STATE <= 4'd1;
                     end

                    else 
                      STATE <= 4'd0;

                    end

            //INIT 
            4'd1 : begin
                   en_init <= 1'b0;
                   
                   STATE <= 4'd2;
                   end


            //KSA START (INIT STOP)
            4'd2 : begin
                   if(rdy_init == 1'b1) begin
                      en_ksa <= 1'b1; 
                      sel <= 1'b1;

                      STATE <= 4'd3;
                   end
                 end

             //KSA 
             4'd3 : begin
                    en_ksa <= 1'b0;
                   
                    STATE <= 4'd4;
                    end


             4'd4 : STATE <= 4'd5;

             //KSA STOP
             4'd5 : begin
                    if(rdy_ksa == 1'b1)
                       STATE <= 4'd6;
                    end

             
            //DONE
            4'd6 : STATE <= 4'd0;
              

            default: STATE <= 4'd0;
   endcase
end
end
                     
                   
                   
      
endmodule: task2
