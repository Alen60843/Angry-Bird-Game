
//=======================================================
// Alex. Grinshpun May 2018
//  Supports Wolfson WM8731 codec


//  changed to smaller latency - David Bar-On 
// (c) Technion IIT Feb 2023 


module audio_codec_controller(
	//////////// CLOCK //////////
	input		logic	CLOCK31_5,
	input		logic	resetN,
   input 	logic AUD_ADCDAT,
   input 	logic AUD_ADCLRCK, //inout	
	input	   logic AUD_BCLK,   //inout
	input 	logic AUD_DACLRCK,  //inout
	input		logic	[15:0]	dacdata_left,
	input		logic	[15:0]	dacdata_right,
	
	output	logic    AUD_DACDAT,
	output	logic    AUD_XCK,
	output	logic    AUD_I2C_SCLK,
	inout 	logic    AUD_I2C_SDAT,
	output	logic	[15:0]	adcdata_left,
	output	logic	[15:0]	adcdata_right

);



///=======================================================
//  REG/WIRE declarations
//=======================================================

logic			 	NEXT_WORD;
logic	[23:0] 	AUD_I2C_DATA;
logic         	TRANSACTION_REQ;


logic				CLOCK_500;
logic				CLOCK_SDAT;
logic				SDO;

localparam  logic [5:0] C_12P5MHZ_DIV_32 = 6'd32;

assign AUD_XCK	= CLOCK31_5 ; // AUD_XCK BYPASS 

   
//=======================================================
//  Structural coding
//=======================================================


//I2C output data
CLOCK_500		CLOCK_500_inst(
	.CLOCK31_5(CLOCK31_5),
	.rst_n(resetN),					 
	.NEXT_WORD(NEXT_WORD),
	.CLOCK_500_ena(CLOCK_500_ena),	
	.CLOCK_500(CLOCK_500),
	.CLOCK_SDAT_ena(CLOCK_SDAT_ena),
	.TRANSACTION_REQ(TRANSACTION_REQ), 
	.DATA(AUD_I2C_DATA),

	);
	
assign AUD_I2C_SDAT = SDO?1'bz:0 ;
	
//i2c controller
i2c				i2c_inst( 
	// Host Side
	.CLOCK31_5(CLOCK31_5),
	.CLOCK_500(CLOCK_500),
	.CLOCK_500_ena(CLOCK_500_ena),
	.CLOCK_SDAT_ena(CLOCK_SDAT_ena),

	.RESET(resetN),
	// I2C Side
	.SDO(SDO),
	.I2C_SDAT(AUD_I2C_SDAT),
	.I2C_DATA(AUD_I2C_DATA),
	.FPGA_I2C_SCLK(AUD_I2C_SCLK),
	// Control Signals
	.TRANSACTION_REQ(TRANSACTION_REQ),
	.NEXT_WORD(NEXT_WORD)
	);
					 

//---------------------------------------------------
//  serial to parallel 

DualSerial2parallel				DualSerial2parallel_inst( 
	
	
	.clock (CLOCK31_5),
	.resetn (resetN),
 	.AUD_ADCDataIn (AUD_ADCDAT),  //inpurt serial data 
	.DACDataIn_L(dacdata_left),
	.DACDataIn_R(dacdata_right),
	.AUD_DACLRCK(AUD_DACLRCK),
	.AUD_ADCLRCK(AUD_ADCLRCK),
	.AUD_BCLK(AUD_BCLK),
	.ADCDATA_VALID(),
	.ADCDataOut_L(adcdata_left),
	.ADCDataOut_R(adcdata_right),
	.AUD_DACDataOut(AUD_DACDAT)
  	);

endmodule                                             