module init(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            output logic [7:0] addr, output logic [7:0] wrdata, output logic wren);

// your code here
//init module = follows the read/enable microprotocol
//init is activated ONCE every time reset is deasserted

logic[1:0] STATE;
integer i, max;

assign max = 256;


always_ff@(posedge clk, negedge rst_n) begin
 if(rst_n == 0)
 STATE <= 2'b00; 

 else begin
 case(STATE)

 //INITIALIZE 
 2'b00 : begin
         i <= 0;
         rdy <= 1'b1;
         wren <= 1'b0;

         STATE <= 2'b01;
         end

 2'b01 : begin
         if (en == 1'b1) begin
         rdy <= 1'b0;

         STATE <= 2'b10; //GO TO LOOP
         end
         
         else begin
         rdy <= 1'b1;
         wren <= 1'b0;       
         end
      end

 //LOOP
 2'b10 : begin
         if(i < max ) begin
         wren <= 1'b1;
         addr <= i;   
         wrdata <= i;
         i <= i + 1;

         STATE <= 2'b10;
         end
           
         else begin
         wren <= 1'b0;
         rdy <= 1'b1;
         STATE <= 2'b00;
         end
 

      end
   endcase
end
end
         

         
        
                
        
         
                  
         

 

endmodule: init