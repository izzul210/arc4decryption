module task3(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here
   logic[7:0] ct_addr, ct_rddata, pt_addr, pt_wrdata, pt_rddata;
   logic pt_wren, en, rdy;

   logic[2:0] STATE;

    ct_mem ct( .address(ct_addr), .clock(CLOCK_50), .q(ct_rddata) );
    pt_mem pt( .address(pt_addr), .clock(CLOCK_50), .data(pt_wrdata), .wren(pt_wren), .q(pt_rddata) );
    arc4 a4( .clk(CLOCK_50), .rst_n(KEY[3]), .en(en), .rdy(rdy), .key({14'b0, SW[9:0]}),
             .ct_addr(ct_addr), .ct_rddata(ct_rddata), .pt_addr(pt_addr), .pt_rddata(pt_rddata), .pt_wrdata(pt_wrdata), .pt_wren(pt_wren) );

    // your code here

   always_ff@(posedge CLOCK_50, negedge KEY[3]) begin
     if(KEY[3] == 1'b0) begin
          STATE <= 3'd0;
     end

     else begin
          case(STATE)
             3'd0 : STATE <= 3'd1;
 
              //START WHEN ARC4 IS READY
              3'd1 : begin
                     if(rdy == 1'b1) begin
                        en <= 1'b1;
                      
                        STATE <= 3'd2;
                       end        
                     end

             
              3'd2 : begin
                     en <= 1'b0;
              
                     STATE <= 3'd3;
                     end

              //WAIT FOR ARC4 TO FINISH
              3'd3 : STATE <= 3'd4;

              //DONE
              3'd4 : begin
                     if(rdy == 1'b1) 
                          STATE <= 3'd5;
                     end

              3'd5 : STATE <= 3'd5; 


              default : STATE <= 3'd0;
 
          endcase
   end
end

endmodule: task3
