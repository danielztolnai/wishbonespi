`timescale 1ns / 1ps

module srl_fifo #(
   parameter WIDTH=8
   ) (
   input              clk,
   input              rst,
   
   input              wr,
   input              rd,
   input  [WIDTH-1:0] din,
   output [WIDTH-1:0] dout,
   output             empty,
   output             full
)/* synthesis syn_hier = "hard" */;

// Generate 16-deep shift register
integer i;
reg [WIDTH-1:0] srl_shr[15:0];

always @ (posedge clk)
begin
   if(wr) begin
      for (i=15; i>0; i=i-1) begin
         srl_shr[i] <= srl_shr[i-1];
      end
      srl_shr[0] <= din;
   end
end

// Data counter
reg [4:0] srl_dcnt;
always @ (posedge clk)
begin
   if (rst) begin
      srl_dcnt <= 0;
   end
   else begin
      if (wr & ~rd)
         srl_dcnt <= srl_dcnt + 1'b1;
      else if (~wr & rd)
         srl_dcnt <= srl_dcnt - 1'b1;
   end
end

// Read address for the SRL, 5 bit wide
reg [4:0] srl_addr;
always @ (posedge clk)
begin
   if (rst) begin
      srl_addr <= 5'h1F;
   end
   else begin
      if (wr & ~rd)
         srl_addr <= srl_addr + 1'b1;
      else if (~wr & rd)
         srl_addr <= srl_addr - 1'b1;
   end
end

// FIFO status signals
assign empty = srl_addr[4];
assign full  = srl_dcnt[4];

// Asyncronous data output
assign dout = srl_shr[srl_addr[3:0]];

endmodule
