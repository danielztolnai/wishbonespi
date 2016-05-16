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
reg [1:0] spi_mode;       // LSB: CPHA, MSB: CPOL
reg       spi_endianness; // 1'b0: MSB first, 1'b1: LSB first
reg [7:0] spi_baudrate;   // SCK frequency: (clk freq)/(2*(spi_baudrate+1))

always @ (posedge clk)
begin
   if(rst) begin
      spi_mode       <= 2'b0;
      spi_endianness <= 1'b0;
      spi_baudrate   <= 8'b0;
   end
   else if(cmd) begin
      spi_mode       <= din[ 1:0];
      spi_endianness <= din[ 2:2];
      spi_baudrate   <= din[10:3];
   end
end

// SCK frequency divider
wire sck_cntr_en;
assign sck_cntr_en = ~spi_ss;
reg [7:0] sck_cntr;
always @ (posedge clk)
begin
   if (rst)
      sck_cntr <= 8'b0;
   else if(sck_cntr == spi_baudrate)
      sck_cntr <= 8'b0;
   else if(sck_cntr_en)
      sck_cntr <= sck_cntr + 1'b1;
end

// SCK reg
reg spi_sck_reg;
always @ (posedge clk)
begin
   if (rst)
      spi_sck_reg <= 1'b0;
   else if(~sck_cntr_en)
      spi_sck_reg <= 1'b0;
   else if(sck_cntr == spi_baudrate)
      spi_sck_reg <= ~spi_sck_reg;
end

assign spi_sck = (spi_mode[1] == 1'b0) ? (spi_sck_reg & ~spi_ss) : (~spi_sck_reg & spi_ss);

wire spi_sck_rise, spi_sck_fall;
assign spi_sck_rise = (~spi_sck_reg) & (sck_cntr == spi_baudrate) & (sck_cntr_en);
assign spi_sck_fall = ( spi_sck_reg) & (sck_cntr == spi_baudrate) & (sck_cntr_en);

// State machine
reg [3:0] state;
parameter S_IDLE = 4'b0000;   // Idle
parameter S_DATA = 4'b0001;   // Start transmission
parameter S_ZERO = 4'b0010;   // 1st byte on output ...
parameter S_LAST = 4'b1001;   // ... 8th byte on output
parameter S_STOP = 4'b1010;   // Next state is IDLE
parameter S_WAIT = 4'b1011;   // Not stopped, waiting for data
// Conditions
wire start_tx, stop_tx, next_tx, read_rx, spi_load;
assign start_tx = ( (state == S_IDLE) & ~wr_fifo_empty & wr_fifo_dout[8] );
assign stop_tx  = (spi_mode[0]) ? ( (state == S_LAST) & spi_sck_rise & spi_tx_stop )
                                : ( (state == S_STOP) & spi_sck_rise );
assign next_tx  = (spi_mode[0]) ? ( (state == S_LAST) & spi_sck_rise & ~wr_fifo_empty & ~spi_tx_stop )
                                : ( (state == S_LAST) & spi_sck_fall & ~wr_fifo_empty & ~spi_tx_stop );
assign read_rx  = (spi_mode[0]) ? ( (state == S_LAST) & spi_sck_rise )
                                : ( (state == S_LAST) & spi_sck_fall );
assign spi_load = (start_tx | next_tx);
// Next-state logic
always @ (posedge clk)
begin
   if(rst)
      state <= S_IDLE;
   else begin
      case(state)
         S_IDLE: begin
            if( start_tx ) begin
               if (spi_mode[0] == 1'b0)
                  state <= S_ZERO;
               else
                  state <= S_DATA;
            end
         end
         
         S_LAST: begin
            // CPHA == 0
            if( spi_sck_fall & (spi_mode[0] == 1'b0) ) begin
               if ( ~wr_fifo_empty & ~spi_tx_stop )
                  state <= S_ZERO;
               else if ( wr_fifo_empty & ~spi_tx_stop )
                  state <= S_WAIT;
               else if ( spi_tx_stop )
                  state <= S_STOP;
            end
            // CPHA == 1
            else if( spi_sck_rise & (spi_mode[0] == 1'b1) ) begin
               if ( ~wr_fifo_empty & ~spi_tx_stop )
                  state <= S_ZERO;
               else if ( wr_fifo_empty & ~spi_tx_stop )
                  state <= S_WAIT;
               else if ( spi_tx_stop )
                  state <= S_IDLE;
            end
         end
         
         S_WAIT: begin
            if ( ~wr_fifo_empty )
               state <= S_ZERO;
         end
         
         S_STOP: begin
            if(spi_sck_rise)
               state <= S_IDLE;
         end
         
         default: begin
            if(( spi_sck_fall & (spi_mode[0] == 1'b0) ) |
               ( spi_sck_rise & (spi_mode[0] == 1'b1) )  )
               state <= state + 1'b1;
         end
      endcase
   end
end

// SPI shift signal
wire spi_shr_sh;
assign spi_shr_sh = (state >= S_ZERO) & (state < S_LAST) &
                    ( (spi_sck_fall) & (spi_mode[0] == 1'b0) | 
                      (spi_sck_rise) & (spi_mode[0] == 1'b1)  );

// Write FIFO
wire wr_fifo_wr, wr_fifo_empty, wr_fifo_full;
wire [10:0] wr_fifo_dout;
wire [ 7:0] wr_fifo_dout_ordered;
srl_fifo #(
   .WIDTH(11)
)
wr_fifo (
   .clk(clk),
   .rst(rst),
   .wr(wr_fifo_wr),
   .rd(spi_load),
   .din(din),
   .dout(wr_fifo_dout),
   .empty(wr_fifo_empty),
   .full(wr_fifo_full)
);

assign wr_fifo_wr = (wr & ~wr_fifo_full);
assign wr_fifo_dout_ordered = (spi_endianness) ? wr_fifo_dout[7:0]
                                               : {wr_fifo_dout[0], wr_fifo_dout[1],
                                                  wr_fifo_dout[2], wr_fifo_dout[3],
                                                  wr_fifo_dout[4], wr_fifo_dout[5],
                                                  wr_fifo_dout[6], wr_fifo_dout[7]};

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
wire rd_fifo_empty, rd_fifo_full;
wire [7:0] rd_fifo_dout;
wire rd_fifo_wr;
reg  rd_fifo_rd;
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

assign dout = (rd_fifo_rd) ? {1'b0, rd_fifo_dout} : {1'b1, 8'b0};
assign rd_fifo_wr = (read_rx & ~rd_fifo_full & spi_rx);
always @ (posedge clk)
begin
   if(rst)
      rd_fifo_rd <= 1'b0;
   else
      rd_fifo_rd <= (rd & ~rd_fifo_empty);
end

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
wire [7:0] spi_shr_dout;
shr spi_shr (
   .clk(clk),
   .rst(rst),
   .din(spi_miso),
   .sh(spi_shr_sh),
   .ld(spi_load),
   .ld_data(wr_fifo_dout_ordered),
   .dout(spi_mosi),
   .dstr(spi_shr_dout)
);

assign spi_shr_dout_ordered = (spi_endianness) ? spi_shr_dout[7:0]
                                               : {spi_shr_dout[0], spi_shr_dout[1],
                                                  spi_shr_dout[2], spi_shr_dout[3],
                                                  spi_shr_dout[4], spi_shr_dout[5],
                                                  spi_shr_dout[6], spi_shr_dout[7]};

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
