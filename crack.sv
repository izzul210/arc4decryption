module crack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

    // your code here

    logic[7:0] pt_addr, pt_rddata, pt_wrdata;
    logic[7:0] pt_addr_arc4, pt_rddata_arc4, pt_wrdata_arc4;
    logic[23:0] key_temp;
    logic en_arc4, key_yes, pt_wren, pt_wren_arc4;

    integer message_length, k;

    logic[4:0] STATE;

    // this memory must have the length-prefixed plaintext if key_valid
    pt_mem pt( .address(pt_addr), .clock(clk), .data(pt_wrdata), .wren(pt_wren), .q(pt_rddata));
    arc4 a4( .clk(clk), .rst_n(rst_n), .en(en_arc4), .rdy(rdy_arc4), .key(key_temp), .ct_addr(ct_addr), .ct_rddata(ct_rddata),
             .pt_addr(pt_addr_arc4), .pt_rddata(pt_rddata_arc4), .pt_wrdata(pt_wrdata_arc4), .pt_wren(pt_wren_arc4) );

    // your code here

    always_ff@(posedge clk, negedge rst_n) begin
          if(rst_n == 1'b0) begin
              STATE <= 5'd0;
          end

          else begin
              case(STATE)
                //INITIALIZE
                 5'd0 : begin
                        key_valid <= 1'b0;
                        key_temp <= 24'b0;
                        rdy <= 1'b1;
                        message_length <= 0;
                        k <= 0;
                        en_arc4 <= 1'b0;

                        STATE <= 5'd1;
                        end
 
                //START
                5'd1 : begin
                       if(en == 1'b1) begin
                           rdy <= 1'b0;

                           STATE <= 5'd2;
                         end 

                       end

                //START ARC4
                5'd2 : begin
                        if(rdy_arc4 == 1'b1) begin
                             en_arc4 <= 1'b1;                             
                             pt_addr <= pt_addr_arc4; 
                             pt_rddata_arc4 <= pt_rddata;
                             pt_wrdata <= pt_wrdata_arc4;
                             pt_wren <= pt_wren_arc4;                             

                             STATE <= 5'd3;
                           end

                        end  
                 
                 //WAIT TO READ ADDRESS
                 5'd3 : begin
                        en_arc4 <= 1'b0;

                        STATE <= 5'd15;
                        end

                5'd15 : STATE <= 5'd4;
                 

                 //WAIT FOR ARC4 TO FINISH & START MEASURE MESSAGE LENGTH
                 5'd4 : begin
                             pt_addr <= pt_addr_arc4; 
                             pt_rddata_arc4 <= pt_rddata;
                             pt_wrdata <= pt_wrdata_arc4;
                             pt_wren <= pt_wren_arc4;

                        //once ARC4 is done writing pt_mem 
                        if(rdy_arc4 == 1'b1) begin                           
                           pt_addr <= 8'b0;

                           STATE <= 5'd5;
                        end
                    
                        end

                
                 //SKIP 1 CLK CYCLE 
                 5'd5 : STATE <= 5'd6;

                //MEASURE LENGTH
                5'd6 : begin
                       message_length <= ct_rddata;
                       k <= 0;

                       STATE <= 5'd7;
                       end

                //READ VALUE AT ADDRESS K 
                5'd7 : begin 
                      if(k < message_length) begin                       
                       pt_addr <= k; 

                       STATE <= 5'd8;                       
                       end

                      else 
                       STATE <= 5'd11; 
                      end

                 //WAIT TO READ ADDRESS
                 5'd8 : STATE <= 5'd9;
 
                 5'd9 : begin
                        
                        //garbage value if outside the range of h20 - h7e (d32 - d126)
                        if((pt_rddata < 32) || (pt_rddata > 126)) begin                      
                          key_yes <= 1'b0;

                          STATE <= 5'd12;
                        end

                        else begin
                          key_yes <= 1'b1;

                          STATE <= 5'd10;
                        end

                         end

                  //IF PT_RDDATA WITHIN RANGE 
                   5'd10: begin                          
                          k <= k + 1;  //increase k to check the pt_rddata at the next address 
                        
                          STATE <= 5'd7;
                          end
                  
                  //CHECK KEY AFTER DONE LOOPING
                   5'd11 : begin
                           if(key_yes <= 1'b1) //if key exist
                            STATE <= 5'd14; //found key!
                           
                           else
                             STATE <= 5'd12; //key is not valid. change key at the next state 
                            end
     
                  //CHANGE KEY 
                  5'd12 : begin
                          key_yes <= 1'b1;
                          key_temp <= key_temp + 1; //change key

                          //reaching the last key                           
                          if(key_temp == 24'd16777214) 
                             STATE <= 5'd13; //key is not found

                          STATE <= 5'd2; //go back to ARC4 with different key
                          end

                  //KEY NOT FOUND
                   5'd13 : begin
                           rdy <= 1'b1;
                           key_valid <= 0;
                           end 

                 //KEY IS FOUND
                  5'd14 : begin
                          rdy <= 1'b1;
                          key_valid <= 1;
                          key <= key_temp;
                          end

                  default : STATE <= 5'd0;

           endcase
       end
 end
                  
                       
                        
                        
 
                      
                           

  
                        

endmodule: crack
