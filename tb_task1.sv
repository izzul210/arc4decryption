`timescale 1ps / 1ps
module tb_task1();

// Your testbench goes here.
 
//include: vsim -L altera_mf_ver work.tb_task1 (for tb)


 logic CLOCK_50;
 logic[3:0] KEY;
 logic[6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
 logic[9:0] LEDR, SW;

 task1 T1(.*);
 
  initial begin
    CLOCK_50 = 1;
    #50;
    
    forever begin
    CLOCK_50 = 0;
    #50;
    CLOCK_50 = 1;
    #50;
    end
  end

  
  initial begin
  KEY[3] = 0;
  #100;
  KEY[3] = 1; 
  #40000;
  
  $stop;
   
  end
 

endmodule: tb_task1
