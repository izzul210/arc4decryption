module prga(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] s_addr, input logic [7:0] s_rddata, output logic [7:0] s_wrdata, output logic s_wren,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    // your code here
    logic[5:0] STATE;
    integer i,j,pad; 
    integer k, message_length;
    logic[7:0] temp_i, temp_j;
    

    always_ff@(posedge clk, negedge rst_n) begin
       if(rst_n == 0) begin
         STATE <= 5'd0;
       end

       else begin
         case(STATE)
            //INITIALIZE 
            6'd0 : begin
                   i <= 0;
                   j <= 0;
                   pad <= 0;
                   k <= 0; 

                   s_addr <= 8'b0;
                   s_wrdata <= 8'b0;
                   s_wren <= 1'b0;

                   ct_addr <= 8'b0;

                   pt_addr <= 8'b0;
                   pt_wrdata <= 8'b0;
                   pt_wren <= 1'b0;
                   
                   rdy <= 1'b1;
                   

                   STATE <= 6'd1;
                   end

            //START
            6'd1 : begin
                   if(en == 1'b1) begin
		   rdy <= 1'b0;
                   STATE <= 6'd2;
                   end
						 
                   else
                   STATE <= 6'd1;
                 //STATE <= 5'd0;
                   end

            //READ MESSAGE_LENGTH
            6'd2 : begin                   
                   message_length <= ct_rddata; //read message length from index 0 of CT
 
                   STATE <= 6'd4;
                   end

            //LOOP (k < message_length)
            6'd4 : begin                   
                   if (k < message_length ) begin
                       i <= (i + 1)%256;
                       
                       STATE <= 6'd5;
                   end

                   //END OF LOOP
                   else 
                   STATE <= 6'd0;

                   end
             
             //INITIALIZE s[i]
             6'd5 : begin
                    s_addr <= i;
              
                    STATE <= 6'd6;
                    end

             //WAIT TO READ
             6'd6 : STATE <= 6'd7;

             //SAVE s[i] value into temp_i
             6'd7 : begin 
                    temp_i <= s_rddata;
                   
                    STATE <= 6'd8;
                    end


             //COMPUTE j = (j + s[i]) mod 256        
             6'd8 : begin
                    j <= (j + temp_i)%256;
                     
                    STATE <= 6'd9;
                    end
             
             //CHANGE ADDRESS TO j
             6'd9 : begin
                    s_addr <= j;

                    STATE <= 6'd20;
                   end
             
             //WAIT TO READ
             6'd20 : STATE <= 6'd10;
         
             
             //SAVE s[j] VALUE TO temp_j
             6'd10 : begin
                     temp_j <= s_rddata;
 
                     STATE <= 6'd11;
                     end      

             //WRITE s[i] INTO ADDRESS j
             6'd11 : begin 
                     s_wren <= 1'b1;
                     s_wrdata <= temp_i;
                     
                     STATE <= 6'd12;
                     end

             //CHANGE ADDRESS to i
             6'd12 : begin
                     s_addr <= i;
                     s_wren <= 1'b0;
                  
                     STATE <= 6'd19;
                     end

             //WAIT TO READ 
             6'd19 : STATE <= 6'd13;


             //INITIALIZE pad
             6'd13 : begin
                     pad <= (temp_i + temp_j) % 256;

                     STATE <= 6'd14;
                     end

             //SWAP s[i] as s[j] 
             //WRITE s[j] INTO ADDRESS i
             6'd14 : begin
                     s_wrdata <= temp_j;
                     s_wren <= 1'b1;
                                      
                     ct_addr <= k + 1; //skip address 0 since address 0 contain the length only                 

                     STATE <= 6'd21;
                     end

               6'd21 : begin
                       s_addr <= pad; //for pad[k] = s[(s[i] + s[j])%256]
                       s_wren <= 1'b0;

                       STATE <= 6'd15;
                       end     


              //WAIT TO READ s_rddata & ct_rddata 
              6'd15 :  begin
                       STATE <= 6'd16;
                       end

             //COMPUTE plaintext[k] = pad[k] xor ciphertext[k] 
              6'd16 : begin
                      pt_addr <= k ; //for plaintext[k]
                      pt_wren <= 1'b1;
                      pt_wrdata <= s_rddata ^ ct_rddata; 
                      
                      STATE <= 6'd17;
                      end

              6'd17 : begin
                      pt_wren <= 1'b0;
                      k <= k + 1;
                    
                      STATE <= 6'd18;
                      end

              6'd18 : STATE <= 6'd4;

              default : STATE <= 6'd0;

     endcase
  end
end
                      

                
                                       
  
endmodule: prga
