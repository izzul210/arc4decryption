module task1(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here

   logic[7:0] address, data, mem_out;
   logic wren, en, rdy;
   logic[2:0] next_state, present_state;
   

    s_mem s( .address(address), .clock(CLOCK_50), .data(data), .wren(wren), .q(mem_out));
    init INIT( .clk(CLOCK_50), .rst_n(KEY[3]), .en(en), .rdy(rdy), .addr(address), .wrdata(data), .wren(wren));

    // your code here

    always_ff@(posedge CLOCK_50, negedge KEY[3]) begin
    if(KEY[3] == 0)
    present_state <= 2'b00;
    
    else
        begin
     case(present_state)
  
    2'b00 : begin
            if(rdy == 1) begin
            en <= 1'b1;
            next_state <= 2'b01;
            end

            else
            next_state <= 2'b00;
            end

     2'b01 : begin
             en <= 1'b0; 
             next_state <= 2'b01;
             end
      endcase
   end
	end
 

endmodule: task1
