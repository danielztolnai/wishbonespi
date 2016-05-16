`timescale 1ns / 1ps

module wishbone_if(
   input         clk,      // System clock
   input         rst,      // System reset
   
   // Wishbone side
   input  [31:0] wb_addr,  // Address
   input         wb_we,    // Write Enable
   input         wb_stb,   //
   input         wb_cyc,   //
   input  [31:0] wb_dout,  // Bus to slave
   
   output [31:0] wb_din,   // Slave to bus
   output        wb_ack,   // Acknowledge
   
   // Internal
   output [10:0] dout,     // Bus to slave
   output        cmd,      // Modify settings
   output        wr,       // Write data
   output        rd,       // Read data
   
   input  [ 8:0] din,      // Slave to bus
   input         ack       // Acknowledge
);

// Address decoder
parameter ADDR_DATA = 32'h0000_0010;
parameter ADDR_CMD  = 32'h0000_0020;

// Registers
reg [31:0] wb_din_reg;   // Slave to bus
reg        wb_ack_reg;   // Acknowledge
reg [10:0] dout_reg;     // Bus to slave
reg        cmd_reg;      // Modify settings
reg        wr_reg;       // Write data
reg        rd_reg;       // Read data

// Check for stb and cyc rising edge
wire select;
assign select = (wb_stb & wb_cyc);

reg [1:0] select_reg;
always @ (posedge clk)
begin
   if(rst)
      select_reg <= 2'b0;
   else
      select_reg <= {select_reg[0], select};
end

wire select_rise;
assign select_rise = ( select_reg == 2'b01 );

wire [31:0] din_ext;
assign din_ext = {23'b0, din};

assign wb_din = (select & ~wb_we & ack) ? din_ext : 32'bZ;
assign wb_ack = (select) ? ack : 1'bZ;
assign dout   = (select &  wb_we) ? wb_dout[10:0] : 11'bZ;
assign cmd    = ((wb_addr ^ ADDR_CMD)  == 32'b0) & (select_rise) & ( wb_we);
assign wr     = ((wb_addr ^ ADDR_DATA) == 32'b0) & (select_rise) & ( wb_we);
assign rd     = ((wb_addr ^ ADDR_DATA) == 32'b0) & (select_rise) & (~wb_we);

endmodule
