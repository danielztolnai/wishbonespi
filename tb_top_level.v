`timescale 1ns / 1ps

module tb_top_level;

	// Inputs
	reg clk;
	reg rst;
	reg [31:0] wb_addr;
	reg wb_we;
	reg wb_stb;
	reg wb_cyc;
	reg [31:0] wb_dout;

	// Outputs
	wire [31:0] wb_din;
	wire wb_ack;
   
   // Internal
	wire spi_mosi;
   wire spi_miso;
	wire spi_sck;
	wire spi_ss;

	// Instantiate the Unit Under Test (UUT)
	top_level uut (
		.clk(clk), 
		.rst(rst), 
		.wb_addr(wb_addr), 
		.wb_we(wb_we), 
		.wb_stb(wb_stb), 
		.wb_cyc(wb_cyc), 
		.wb_dout(wb_dout), 
		.wb_din(wb_din), 
		.wb_ack(wb_ack), 
		.spi_mosi(spi_mosi), 
		.spi_sck(spi_sck), 
		.spi_ss(spi_ss), 
		.spi_miso(spi_miso)
	);
   
   M25LC020A spi_eeprom (
      .SI(spi_mosi),
      .SO(spi_miso),
      .SCK(spi_sck),
      .CS_N(spi_ss),
      .WP_N(1'b1),
      .HOLD_N(1'b1),
      .RESET(rst)
   );

   // Initialize Inputs
	initial begin
		clk = 0;
		rst = 0;
		wb_addr = 0;
		wb_we = 0;
		wb_stb = 0;
		wb_cyc = 0;
		wb_dout = 0;
   end
   
   // Generate clock
   always #5 begin
      clk = ~clk;
   end
   
   initial begin
		/* RESET */
		#200;
      rst = 1'b1;
      #200;
      rst = 1'b0;
      #5;
        
      /* Push data */
      wb_addr = 32'h0000_0020;
      wb_dout = 32'h0000_0019; // Set baudrate (11'b0000_0011_0_01)
      wb_stb=1'b1; wb_cyc=1'b1; wb_we=1'b1;
      #20; wb_stb=1'b0; wb_cyc=1'b0; wb_we=1'b0; #10;
      
      wb_addr = 32'h0000_0010;
      wb_dout = 32'h0000_0306; // Write enable (11'b011_0000_0110)
      wb_stb=1'b1; wb_cyc=1'b1; wb_we=1'b1;
      #20; wb_stb=1'b0; wb_cyc=1'b0; wb_we=1'b0; #10;
      
      wb_addr = 32'h0000_0010;
      wb_dout = 32'h0000_0102; // Write instruction (11'b001_0000_0010)
      wb_stb=1'b1; wb_cyc=1'b1; wb_we=1'b1;
      #20; wb_stb=1'b0; wb_cyc=1'b0; wb_we=1'b0; #10;
      
      wb_addr = 32'h0000_0010;
      wb_dout = 32'h0000_00FE; // Write address (11'b000_1111_1110)
      wb_stb=1'b1; wb_cyc=1'b1; wb_we=1'b1;
      #20; wb_stb=1'b0; wb_cyc=1'b0; wb_we=1'b0; #10;
      
      wb_addr = 32'h0000_0010;
      wb_dout = 32'h0000_02D3; // Write data (11'b010_1101_0011)
      wb_stb=1'b1; wb_cyc=1'b1; wb_we=1'b1;
      #20; wb_stb=1'b0; wb_cyc=1'b0; wb_we=1'b0; #10;
      
      wb_addr = 32'h0000_0010;
      wb_dout = 32'h0000_0105; // Read status (11'b001_0000_0101)
      wb_stb=1'b1; wb_cyc=1'b1; wb_we=1'b1;
      #20; wb_stb=1'b0; wb_cyc=1'b0; wb_we=1'b0; #10;
      
      wb_addr = 32'h0000_0010;
      wb_dout = 32'h0000_0600; // Receive answer (11'b110_0000_0000)
      wb_stb=1'b1; wb_cyc=1'b1; wb_we=1'b1;
      #20; wb_stb=1'b0; wb_cyc=1'b0; wb_we=1'b0; #10;
      
      #4000;
      wb_addr = 32'h0000_0010; // Read answer
      wb_stb=1'b1; wb_cyc=1'b1; wb_we=1'b0;
      #20; wb_stb=1'b0; wb_cyc=1'b0; wb_we=1'b0; #10;
      
      #4000;
      wb_addr = 32'h0000_0010;
      wb_dout = 32'h0000_0103; // Read instruction (11'b001_0000_0011)
      wb_stb=1'b1; wb_cyc=1'b1; wb_we=1'b1;
      #20; wb_stb=1'b0; wb_cyc=1'b0; wb_we=1'b0; #10;
      
      wb_addr = 32'h0000_0010;
      wb_dout = 32'h0000_00FE; // Read address (11'b000_1111_1110)
      wb_stb=1'b1; wb_cyc=1'b1; wb_we=1'b1;
      #20; wb_stb=1'b0; wb_cyc=1'b0; wb_we=1'b0; #10;
      
      wb_addr = 32'h0000_0010;
      wb_dout = 32'h0000_0600; // Receive answer (11'b110_0000_0000)
      wb_stb=1'b1; wb_cyc=1'b1; wb_we=1'b1;
      #20; wb_stb=1'b0; wb_cyc=1'b0; wb_we=1'b0; #10;
      
      #1000;
      wb_addr = 32'h0000_0010; // Read answer
      wb_stb=1'b1; wb_cyc=1'b1; wb_we=1'b0;
      #20; wb_stb=1'b0; wb_cyc=1'b0; wb_we=1'b0; #10;
      
      #2000;
      wb_addr = 32'h0000_0010; // Read answer
      wb_stb=1'b1; wb_cyc=1'b1; wb_we=1'b0;
      #20; wb_stb=1'b0; wb_cyc=1'b0; wb_we=1'b0; #10;
	end
      
endmodule

