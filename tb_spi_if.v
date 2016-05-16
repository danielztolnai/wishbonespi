`timescale 1ns / 10ps

module tb_spi_if;

	// Inputs
	reg clk;
	reg rst;
	reg [10:0] din;
	reg cmd;
	reg wr;
	reg rd;

	// Outputs
	wire [8:0] dout;
	wire ack;
	wire spi_mosi;
	wire spi_sck;
	wire spi_ss;
   wire spi_miso;

	// Instantiate the Unit Under Test (UUT)
	spi_if uut (
		.clk(clk), 
		.rst(rst), 
		.din(din), 
		.cmd(cmd), 
		.wr(wr), 
		.rd(rd), 
		.dout(dout), 
		.ack(ack), 
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
		din = 0;
		cmd = 0;
		wr  = 0;
		rd  = 0;
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
      
      /* Push data */
      cmd = 01'b1;
      din = 11'b0000_0011_0_01; #10;  // Set baudrate
      cmd = 01'b0;
      
      wr  = 01'b1;
      din = 11'b011_0000_0110; #10;   // Write enable (START, STOP)
      
      din = 11'b001_0000_0010; #10;   // Write instruction (START)
      din = 11'b000_1111_1110; #10;   // Write address
      din = 11'b010_1101_0011; #10;   // Write data (STOP)
      
      din = 11'b001_0000_0101; #10;   // Read status instruction (START)
      din = 11'b110_0000_0000; #10;   // Receive answer (RX, STOP)
      
      din = 11'b001_0000_0101; #10;   // Read status instruction (START)
      din = 11'b110_0000_0000; #10;   // Receive answer (RX, STOP)
      
      din = 11'b001_0000_0101; #10;   // Read status instruction (START)
      din = 11'b110_0000_0000; #10;   // Receive answer (RX, STOP)
      
      din = 11'b001_0000_0101; #10;   // Read status instruction (START)
      din = 11'b110_0000_0000; #10;   // Receive answer (RX, STOP)
      
      wr  = 01'b0; #1000; wr  = 01'b1;
      
      din = 11'b001_0000_0101; #10;   // Read status instruction (START)
      din = 11'b110_0000_0000; #10;   // Receive answer (RX, STOP)

      din = 11'b001_0000_0011; #10;   // Read instruction (START)
      din = 11'b000_1111_1110; #10;   // Write address
      din = 11'b110_0000_0000; #10;   // Receive answer (RX, STOP)
      
      wr  = 01'b0;
      din = 11'b0;
      rd  = 01'b1;
	end
      
endmodule

