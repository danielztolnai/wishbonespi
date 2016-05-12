`timescale 1ns / 1ps

module spi_if(
   input         clk,      // System clock
   input         rst,      // System reset
   
   // Internal  
   input  [10:0] din,     // Data from bus
   input         cmd,     // Modify settings
   input         wr,      // Write data
   input         rd,      // Read data
   
   output [ 8:0] dout,    // Data to bus
   output        ack,     // Acknowledge
   
   // SPI side
   output        spi_mosi,
   output        spi_sck,
   output        spi_ss,
   input         spi_miso
);

// Preferences
reg [1:0] spi_mode;
reg       spi_endianness;
reg [7:0] spi_baudrate;

always @ (posedge clk)
begin
   if(rst) begin
      spi_mode       <=  2'b0;
      spi_endianness <=  1'b0;
      spi_baudrate   <= 12'b0;
   end
   else if(cmd) begin
      spi_mode       <= din[ 1:0];
      spi_endianness <= din[ 2:2];
      spi_baudrate   <= din[10:3];
   end
end

// SPI shift counter
reg [2:0] cntr;
always @ (posedge clk)
begin
   if(rst)
      cntr <= 3'b0;
   else if(spi_shr_sh)
      cntr <= cntr + 1'b1;
end

wire   spi_load;
assign spi_load = (cntr == 3'b111);

// Write FIFO
wire wr_fifo_wr, wr_fifo_empty, wr_fifo_full;
wire [10:0] wr_fifo_dout;
wire [ 7:0] wr_fifo_dout_ordered;
wire wr_fifo_rd;
srl_fifo #(
   .WIDTH(11)
)
wr_fifo (
   .clk(clk),
   .rst(rst),
   .wr(wr_fifo_wr),
   .rd(wr_fifo_rd),
   .din(din),
   .dout(wr_fifo_dout),
   .empty(wr_fifo_empty),
   .full(wr_fifo_full)
);

assign wr_fifo_wr = (wr & ~wr_fifo_full);
assign wr_fifo_rd = (~wr_fifo_empty & spi_load);
assign wr_fifo_dout_ordered = (spi_endianness) ? {wr_fifo_dout[0], wr_fifo_dout[1],
                                                  wr_fifo_dout[2], wr_fifo_dout[3],
                                                  wr_fifo_dout[4], wr_fifo_dout[5],
                                                  wr_fifo_dout[6], wr_fifo_dout[7]}
                                               : wr_fifo_dout[7:0];

// Save cmd bits on load
reg spi_tx_start, spi_tx_stop, spi_rx;
always @ (posedge clk)
begin
   if(rst) begin
      spi_tx_start <= 1'b0;
      spi_tx_stop  <= 1'b0;
      spi_rx       <= 1'b0;
   end
   else if(spi_load) begin
      spi_tx_start <= wr_fifo_dout[ 8];
      spi_tx_stop  <= wr_fifo_dout[ 9];
      spi_rx       <= wr_fifo_dout[10];
   end
end

// Read FIFO
wire [7:0] spi_shr_dout_ordered;
wire rd_fifo_rd, rd_fifo_empty, rd_fifo_full;
wire [7:0] rd_fifo_dout;
wire rd_fifo_wr;
srl_fifo #(
   .WIDTH(8)
)
rd_fifo (
   .clk(clk),
   .rst(rst),
   .wr(rd_fifo_wr),
   .rd(rd_fifo_rd),
   .din(spi_shr_dout_ordered),
   .dout(rd_fifo_dout),
   .empty(rd_fifo_empty),
   .full(rd_fifo_full)
);

assign rd_fifo_rd = (rd & ~rd_fifo_empty);
assign rd_fifo_wr = (~rd_fifo_full & spi_load & spi_rx);
assign dout = (rd_fifo_rd) ? {1'b0, rd_fifo_dout} : {1'b1, 8'b0};

// Acknowledge signal
reg ack_reg;
always @ (posedge clk)
begin
   if(rst)
      ack_reg <= 1'b0;
   else
      ack_reg <= wr_fifo_wr | rd | cmd;   
end

assign ack = ack_reg;

// SPI shift register
wire spi_shr_sh; // FIXME
wire [7:0] spi_shr_dout;
shr spi_shr (
   .clk(clk),
   .rst(rst),
   .din(spi_miso),
   .sh(spi_shr_sh), // FIXME
   .ld(spi_load),
   .ld_data(wr_fifo_dout_ordered),
   .dout(spi_mosi),
   .dstr(spi_shr_dout)
);

assign spi_shr_dout_ordered = (spi_endianness) ? {spi_shr_dout[0], spi_shr_dout[1],
                                                  spi_shr_dout[2], spi_shr_dout[3],
                                                  spi_shr_dout[4], spi_shr_dout[5],
                                                  spi_shr_dout[6], spi_shr_dout[7]}
                                               : spi_shr_dout[7:0];

// Slave select
reg spi_ss_reg; // active low
always @ (posedge clk)
begin
   if(rst)
      spi_ss_reg <= 1'b1;
   else if(spi_load & spi_tx_stop)
      spi_ss_reg <= 1'b1;
   else if(spi_load & spi_tx_start)
      spi_ss_reg <= 1'b0;
end

assign spi_ss = spi_ss_reg;

endmodule
