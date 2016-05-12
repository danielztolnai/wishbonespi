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

always @ (posedge clk)
begin
   if(rst) begin
      wb_din_reg <= 32'b0;
      wb_ack_reg <=  1'b0;
      
      dout_reg   <= 11'b0;
      cmd_reg    <=  1'b0;
      wr_reg     <=  1'b0;
      rd_reg     <=  1'b0;
   end
   else begin
      wb_din_reg <= {23'b0, din};
      wb_ack_reg <= ack;
      
      dout_reg   <= wb_dout[10:0];
      cmd_reg    <= ((wb_addr ^ ADDR_CMD)  == 32'b0) & (wb_stb & wb_cyc) & ( wb_we);
      wr_reg     <= ((wb_addr ^ ADDR_DATA) == 32'b0) & (wb_stb & wb_cyc) & ( wb_we);
      rd_reg     <= ((wb_addr ^ ADDR_DATA) == 32'b0) & (wb_stb & wb_cyc) & (~wb_we);
   end
end

assign wb_din = wb_din_reg;
assign wb_ack = wb_ack_reg;
assign dout   = dout_reg;
assign cmd    = cmd_reg;
assign wr     = wr_reg;
assign rd     = rd_reg;

endmodule
