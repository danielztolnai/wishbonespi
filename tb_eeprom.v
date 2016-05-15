`timescale 1ns / 10ps

module tb_eeprom;

	// Inputs
	reg SI;
	reg SCK;
	reg CS_N;
	reg WP_N;
	reg HOLD_N;
	reg RESET;

	// Outputs
	wire SO;

	// Instantiate the Unit Under Test (UUT)
	M25LC020A uut (
		.SI(SI), 
		.SO(SO), 
		.SCK(SCK), 
		.CS_N(CS_N), 
		.WP_N(WP_N), 
		.HOLD_N(HOLD_N), 
		.RESET(RESET)
	);

	initial begin
		// Initialize Inputs
		SI     = 1'b0;
		SCK    = 1'b0;
		CS_N   = 1'b1;
		WP_N   = 1'b1;
		HOLD_N = 1'b1;
		RESET  = 1'b0;

		/* RESET */
		#200;
      RESET = 1'b1;
      #200;
      RESET = 1'b0;
      
      /* WRITE-ENABLE */
		// Instruction
      #200;CS_N=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT0 // SS fall
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT1
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT2
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT3
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT4
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT5
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT6
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT7
      #200; SCK=1'b0;          #200; CS_N=1'b1;          // SS rise
      #1000;
      
      /* WRITE */
		// Instruction
      #200;CS_N=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT0 // SS fall
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT1
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT2
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT3
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT4
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT5
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT6
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT7
      
      // Address
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT0
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT1
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT2
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT3
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT4
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT5
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT6
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT7
      
      // Data
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT0
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT1
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT2
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT3
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT4
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT5
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT6
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT7
      #200; SCK=1'b0;          #200; CS_N=1'b1;          // SS rise
      #1000;
      
      /* READ STATUS */
		// Instruction
      #200;CS_N=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT0 // SS fall
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT1
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT2
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT3
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT4
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT5
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT6
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT7
      
      // Receive
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT0
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT1
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT2
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT3
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT4
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT5
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT6
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT7
      #200; SCK=1'b0;          #200; CS_N=1'b1;          // SS rise
      #1000;
      
      /* READ STATUS */
		// Instruction
      #200;CS_N=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT0 // SS fall
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT1
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT2
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT3
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT4
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT5
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT6
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT7
      
      // Receive
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT0
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT1
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT2
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT3
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT4
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT5
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT6
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT7
      #200; SCK=1'b0;          #200; CS_N=1'b1;          // SS rise
      #1000;
      
      /* READ */
		// Instruction
      #200;CS_N=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT0 // SS fall
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT1
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT2
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT3
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT4
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT5
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT6
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT7
      
      // Address
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT0
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT1
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT2
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT3
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT4
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT5
      #200; SCK=1'b0; SI=1'b1; #200; SCK=1'b1;   // BIT6
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT7
      
      // Receive
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT0
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT1
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT2
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT3
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT4
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT5
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT6
      #200; SCK=1'b0; SI=1'b0; #200; SCK=1'b1;   // BIT7
      #200; SCK=1'b0;          #200; CS_N=1'b1;          // SS rise
      #1000;
      
	end
      
endmodule

