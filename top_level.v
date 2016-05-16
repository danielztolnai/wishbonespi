`timescale 1ns / 1ps

module top_level(
   input         clk,
   input         rst,
   
   // Wishbone
   input  [31:0] wb_addr,  // Address
   input         wb_we,    // Write Enable
   input         wb_stb,   //
   input         wb_cyc,   //
   input  [31:0] wb_dout,  // Bus to slave
   output [31:0] wb_din,   // Slave to bus
   output        wb_ack,   // Acknowledge
   
   // SPI
   output        spi_mosi,
   output        spi_sck,
   output        spi_ss,
   input         spi_miso
);

wire [10:0] dout;
wire [ 8:0] din;
wire cmd, wr, rd, ack;

wishbone_if wishbone_interface (
   .clk(clk), 
   .rst(rst), 
   .wb_addr(wb_addr), 
   .wb_we(wb_we), 
   .wb_stb(wb_stb), 
   .wb_cyc(wb_cyc), 
   .wb_dout(wb_dout), 
   .wb_din(wb_din), 
   .wb_ack(wb_ack), 
   .dout(dout), 
   .cmd(cmd), 
   .wr(wr), 
   .rd(rd), 
   .din(din), 
   .ack(ack)
);

spi_if spi_interface (
   .clk(clk),
   .rst(rst),
   .din(dout),
   .cmd(cmd),
   .wr(wr),
   .rd(rd),
   .dout(din),
   .ack(ack),
   .spi_mosi(spi_mosi),
   .spi_sck(spi_sck),
   .spi_ss(spi_ss),
   .spi_miso(spi_miso)
);

endmodule
