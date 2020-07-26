module arc4(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    // your code here

   logic[7:0] address, address_init, address_ksa, address_prga;
   logic[7:0] data, wrdata_init, wrdata_ksa, wrdata_prga;
   logic wren, wren_init, wren_ksa, wren_prga;
   logic en_init, en_ksa, en_prga;
   logic rdy_init, rdy_ksa, rdy_prga;

   logic[2:0] sel;
   logic[7:0] mem_out;
   logic[3:0] STATE;

    s_mem s( .address(address), .clock(clk), .data(data), .wren(wren), .q(mem_out));

    init i( .clk(clk), .rst_n(rst_n), .en(en_init), .rdy(rdy_init), .addr(address_init), .wrdata(wrdata_init), .wren(wren_init));

    ksa k( .clk(clk), .rst_n(rst_n), .en(en_ksa), .rdy(rdy_ksa), .key(key), .addr(address_ksa), .rddata(mem_out), .wrdata(wrdata_ksa), .wren(wren_ksa));

    prga p( .clk(clk), .rst_n(rst_n), .en(en_prga), .rdy(rdy_prga), .key(key), .s_addr(address_prga), .s_rddata(mem_out), .s_wrdata(wrdata_prga), .s_wren(wren_prga), 
            .ct_addr(ct_addr), .ct_rddata(ct_rddata), .pt_addr(pt_addr), .pt_rddata(pt_rddata), .pt_wrdata(pt_wrdata), .pt_wren(pt_wren) );

   
   Mux3 #(8) mux_addr(address_prga, address_ksa, address_init, sel, address);
   Mux3 #(8) mux_data(wrdata_prga, wrdata_ksa, wrdata_init, sel, data);
   Mux3 #(1) mux_wren(wren_prga, wren_ksa, wren_init, sel, wren);

   always_ff@(posedge clk, negedge rst_n) begin
      if(rst_n == 0) begin
      STATE <= 4'd0;
      end

      else begin
          case(STATE)
          4'd0 : begin
                 rdy <= 1'b1;
                 en_init <= 1'b0;
                 en_ksa <=  1'b0;
                 en_prga <= 1'b0;
                
                if(en == 1'b1) 
                   STATE <= 4'd1;        

                end

           //START INIT
           4'd1 : begin
                  rdy <= 1'b0;
                 
                  if(rdy_init == 1'b1) begin
                    en_init <= 1'b1; 
                    sel <= 3'b001;

                    STATE <= 4'd2;
                   end
               
                 end

            //SET EN_INIT TO 0
            4'd2 : begin
                   en_init <= 1'b0;
                   
                   STATE <= 4'd3;
                   end

 
           //START KSA 
           4'd3 : begin
                   //wait for init to finish
                   if((rdy_init == 1'b1) && (rdy_ksa == 1'b1)) begin
                    en_ksa <= 1'b1;
                    sel <= 3'b010;

                    STATE <= 4'd4;
                     end
                   end

            //SET EN_KSA TO 0
            4'd4 : begin
                     en_ksa <= 1'b0;

                     STATE <= 4'd5;
                     end


              //START PRGA
              4'd5 : begin
                    //wait for ksa to finish
                    if((rdy_ksa == 1'b1) && (rdy_prga == 1'b1)) begin

                    en_prga <= 1'b1;
                    sel <= 3'b100; 

                        STATE <= 4'd6;

                        end
                    end

               //SET EN_PRGA TO 0
               4'd6 : begin
                      en_prga <= 1'b0;
                   
                      STATE <= 4'd7;
                      end

               //DONE
               4'd7 : begin
                      //wait for prga to finish
                      if(rdy_prga == 1'b1) begin
                         rdy <= 1'b1;

                         STATE <= 4'd0;
                        end
                      end

               default : STATE <= 4'd0;

            endcase
   end
end

 

endmodule: arc4


module Mux3(a3, a2, a1, select, aout);
parameter k = 8;
input[k-1:0] a3, a2, a1;
input[2:0] select;
output logic[k-1:0] aout;


assign aout = ({k{select[0]}} & a1) | ({k{select[1]}} & a2) | ({k{select[2]}} & a3) ;

endmodule: Mux3