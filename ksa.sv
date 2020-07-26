module ksa(input logic clk, input logic rst_n,
           input logic en, output logic rdy,
           input logic [23:0] key,
           output logic [7:0] addr, input logic [7:0] rddata, output logic [7:0] wrdata, output logic wren);

    // your code here

 logic[4:0] STATE;
 integer key_imod, keylength, i;
 logic[7:0] temp_i, temp_j, j;
 logic read_i, read_j; 

 assign keylength = 3;

 always_ff@(posedge clk, negedge rst_n)begin
   if(rst_n == 0) begin
     STATE <= 3'd0;
    end

   else begin
      case(STATE)
      //INIT  
      4'd0 : begin             
              j <= 0;
              i <= 0;
              wren <= 1'b0;
              rdy <= 1'b1;              
             
              STATE <= 4'd1;
              end
        
      //PRE-START
      4'd1 : begin            
             if(en == 1'b1) begin
             rdy <= 1'b0;

             STATE <= 4'd2;
             end              

             else
               STATE <= 4'd1;

             end
  
      //START
       4'd2 : begin              
              if( i < 256) begin
              key_imod <= (i%keylength);
              addr <= i;              
              wren <= 1'b0;
              
              STATE <= 4'd3;
              end

              //END OF LOOP
              else
              STATE <= 4'd0;
              

             end

      //WAIT FOR ADDRESS TO CHANGE   
      4'd3 : STATE <= 4'd4;

     //j = (j + s[i] + key[key_imod] ) mod 256
     4'd4 : begin

            if(key_imod == 2) begin
          // j_temp <= (j + rddata + key[7:0]);
            j <= ((j + rddata + key[7:0])%256);
          //  temp_i <= rddata;  //temp_i = s[i]

            end

            else if(key_imod == 1) begin
          //  j_temp <= (j + rddata + key[15:8]);
            j <= ((j + rddata + key[15:8])%256);
           // temp_i <= rddata;  //temp_i = s[i]

            end

            else if(key_imod == 0 )begin
           //j_temp <= (j + rddata + key[23:16]);
            j <= ((j + rddata + key[23:16])%256);
           // temp_i <= rddata;  //temp_i = s[i]
            
            end

            STATE <= 4'd5;
            end


     //address holds value of i
     //temp_i = s[i]     
      4'd5 : begin
             temp_i <= rddata; 
             read_i = 1'b1;

             STATE <= 4'd6;
             end

      //CHANGE ADDRESS i -> j
      4'd6 : begin
             addr <= j;
      
             STATE <= 4'd7;
             end

      //WAIT TO READ rddata
      4'd7 : STATE <= 4'd8;

      //address holds value of j
      //temp_j = s[j]
      4'd8 : begin
             temp_j <= rddata;
             read_j = 1'b1;

             STATE <= 4'd9;     
             end

      //s[j] = s[i]
      //write value s[i] into address j 
      4'd9 : begin
             wren <= 1'b1;
             wrdata <= temp_i;

             STATE <= 4'd10;
             end
 
//     4'd13 : STATE <= 4'd7;
        

      //CHANGE ADDRESS j -> i
      4'd10 : begin
             addr <= i;

             STATE <= 4'd11;
             end
  
      //WAIT 
      4'd11 : STATE <= 4'd12;

      //s[i] = s[j]
      ///write value s[j] into address i
      4'd12 : begin
             wren <= 1'b1;
             wrdata <= temp_j;
             i <= i + 1;          
           
             STATE <= 4'd2;
             end

 /*     4'd11 : begin
              i <= i + 1;
             
              STATE <= 4'd2;
              end
*/

      default : STATE <= 4'd0;
    endcase
  end
end
        
      
          

endmodule: ksa
