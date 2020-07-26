module cracking_arc4(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here
    logic en_crack, rdy_crack, key_valid;
    logic[7:0] ct_addr, ct_rddata;
    logic[2:0] STATE;
    logic[23:0] key;
    logic[3:0] val0,val1,val2, val3, val4, val5;

    ct_mem ct( .address(ct_addr), .clock(CLOCK_50), .q(ct_rddata));
    crack c( .clk(CLOCK_50), .rst_n(KEY[3]), .en(en_crack), .rdy(rdy_crack), 
	      .key(key), .key_valid(key_valid), .ct_addr(ct_addr), .ct_rddata(ct_rddata));

    // your code here
    always_ff@(posedge CLOCK_50, negedge KEY[3]) begin
          if(KEY[3] == 1'b0) begin
              STATE <= 3'd0;
          end

          else begin
             case(STATE)
             //INIT
              3'd0: begin
                    en_crack <= 1'b0;
                    val0 <= 0;
                    val1 <= 0;
                    val2 <= 0;
                    val3 <= 0;
                    val4 <= 0;
                    val5 <= 0;

                    STATE <= 3'd1;
                    end

              //START CRACK
              3'd1 : begin 
                     if(rdy_crack == 1'b1) 
                        en_crack <= 1'b1;
                         
                        STATE <= 3'd2;
                      end
               //WAIT FOR CRACK TO FINISH
               3'd2 : begin
                      en_crack <= 1'b0;
                      STATE <= 3'd3;
                      end

                3'd3 : begin
                        if(rdy_crack == 1'b1)
                            STATE <= 3'd4;
                      end

                //READ VALUE OF KEY
                3'd4 : begin
                        if(key_valid == 1'b1) begin
                          val0 <= key[3:0];
                          val1 <= key[7:4];
                          val2 <= key[11:8];
                          val3 <= key[15:12];
                          val4 <= key[19:16];
                          val5 <= key[23:20];
        
                         end

                       STATE <= 3'd5;
                       end

               
               3'd5 : STATE <= 3'd5;

               default : STATE <= 3'd0;
                      

         endcase
  end
end     
	
		
					

            
                  

                    
                                 
             

endmodule: task4
