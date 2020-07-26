module tb_init();

// Your testbench goes here.
 
 logic clk, rst_n, en, rdy, wren;
 logic[7:0] addr, wrdata;
 
 init INIT(.*);

 initial begin
 clk = 1; #50;
 
 forever begin
 clk = 0; #50;
 clk = 1; #50;
 end
end

 initial begin
 en = 1;
 rst_n = 0;
 #100;

 
 rst_n = 1;
 #20000;

  $stop;
 end

endmodule: tb_init
