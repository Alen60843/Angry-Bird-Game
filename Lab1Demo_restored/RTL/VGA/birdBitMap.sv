// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2021
// (c) Technion IIT, Department of Electrical Engineering 2021 



module	birdBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle1, //input that the pixel is within a bracket 
					input logic   enroll1,
					
					input logic	[10:0] offsetX_2,// offset from top left  position 
					input logic	[10:0] offsetY_2,
					input	logic	InsideRectangle2, //input that the pixel is within a bracket 
					input logic   enroll2,

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout,  //rgb value from the bitmap 
					output   logic [1:0] enroll_collision
 ) ;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_NUMBER_OF_Y_BITS = 5;  // 2^5 = 32 
localparam  int OBJECT_NUMBER_OF_X_BITS = 5;  // 2^5 = 32 


localparam  int OBJECT_HEIGHT_Y = 1 <<  OBJECT_NUMBER_OF_Y_BITS ;
localparam  int OBJECT_WIDTH_X = 1 <<  OBJECT_NUMBER_OF_X_BITS;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_HEIGHT_Y_DIVIDER = OBJECT_NUMBER_OF_Y_BITS - 3; // -2; how many pixel bits are in every collision pixel
localparam  int OBJECT_WIDTH_X_DIVIDER =  OBJECT_NUMBER_OF_X_BITS - 3; // -2

// generating a smiley bitmap

localparam logic [7:0] TRANSPARENT_ENCODING = 8'h00 ;// RGB value in the bitmap representing a transparent pixel 

logic [0:OBJECT_HEIGHT_Y-1] [0:OBJECT_WIDTH_X-1] [7:0] object_colors1 = {
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hc0,8'he0,8'he0,8'ha0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'h20,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h20,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'he0,8'he0,8'he0,8'he0,8'he0,8'h60,8'h80,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'ha0,8'h80,8'he0,8'he0,8'he0,8'ha0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'ha0,8'ha0,8'he0,8'he0,8'he0,8'he0,8'he0,8'ha0,8'hc0,8'he0,8'he0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'ha0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hc0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hc0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h80,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h60,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h20,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h20,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h60,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hc0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'ha0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'ha0,8'h00,8'hc0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h80,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h20,8'h00,8'h00,8'h00,8'h00,8'ha0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h80,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h60,8'h00,8'h00,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h60,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hfe,8'h6d,8'h00,8'h00,8'h00,8'h00,8'h6c,8'hb5,8'hd6,8'he0,8'he0,8'h20},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'h00,8'h24,8'h6d,8'h24,8'h24,8'hff,8'hff,8'hff,8'hc4,8'he0,8'h20},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'ha0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hff,8'hff,8'hff,8'h00,8'h24,8'h8d,8'hb1,8'h64,8'hff,8'hff,8'hfe,8'ha4,8'he0,8'h20},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'hc0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'h20,8'h8d,8'hfa,8'hfa,8'h6c,8'hf8,8'hf8,8'hac,8'hfe,8'hfa,8'h60,8'he0,8'he0,8'h20},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'hc0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hc0,8'h80,8'h60,8'h84,8'hf4,8'hf8,8'hf8,8'hf8,8'h64,8'h20,8'he0,8'he0,8'he0,8'h20},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'ha0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'ha0,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hcc,8'he0,8'he0,8'he0,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h20,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he5,8'he5,8'hed,8'h20,8'hf4,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hcc,8'he0,8'he0,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'hf1,8'hf6,8'hfa,8'hfa,8'hf5,8'h00,8'h64,8'hf0,8'hf4,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf4,8'hc0,8'he0,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'ha0,8'he0,8'he0,8'he0,8'he0,8'hf1,8'hfa,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h64,8'hf0,8'h84,8'h60,8'h60,8'h60,8'h60,8'he0,8'he0,8'he0,8'ha0,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'ha0,8'he0,8'he0,8'he5,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hd5,8'hcc,8'hf4,8'hf0,8'ha4,8'h84,8'h60,8'he0,8'he0,8'he0,8'h20,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'ha0,8'he5,8'hfa,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h8c,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h60,8'he0,8'h60,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h20,8'h8d,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfa,8'hf4,8'hf4,8'hf4,8'hac,8'hd5,8'hd1,8'h20,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h8d,8'hfa,8'hfa,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h20,8'hf4,8'h64,8'hfa,8'hf5,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h64,8'hd5,8'hf5,8'hfa,8'hfe,8'hfe,8'hfe,8'hfe,8'hb1,8'h24,8'hb1,8'h24,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};

	logic[0:OBJECT_HEIGHT_Y-1][0:OBJECT_WIDTH_X-1][7:0] object_colors2 = {
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h05,8'hbb,8'h05,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h05,8'h05,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h05,8'h05,8'h25,8'h05,8'h05,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h2e,8'h05,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'hfd,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h96,8'h05,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfe,8'hfd,8'hfd,8'hfd,8'hfe,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'hbb,8'h25,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfe,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfe,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'hbb,8'hfe,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfd,8'hfe,8'h6c,8'hfd,8'hfd,8'hfd,8'hfd,8'h25,8'h05,8'h05,8'h05,8'hfd,8'h05,8'h05,8'h05,8'hb5,8'hfd,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h05,8'h05,8'h05,8'hfe,8'hfe,8'h6c,8'hfd,8'hfd,8'hfd,8'h05,8'h05,8'h05,8'hfd,8'hfe,8'h05,8'h05,8'h04,8'hfd,8'hfd,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'hfd,8'hfd,8'hfd,8'hfd,8'hda,8'h05,8'h05,8'hfd,8'hfd,8'h05,8'h05,8'hb5,8'hfd,8'hfd,8'h25,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'hfd,8'hfd,8'hfd,8'hfd,8'h05,8'h05,8'hfd,8'hfd,8'hfe,8'h05,8'hfd,8'hfd,8'hfd,8'h05,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'hfe,8'hfd,8'hfd,8'h24,8'hfe,8'hfd,8'hfd,8'hfd,8'h05,8'hfd,8'hfd,8'hfe,8'hbb,8'h05,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'hfd,8'hfd,8'hd9,8'hfd,8'hfd,8'hfd,8'hfd,8'h6d,8'hfd,8'hfd,8'h05,8'h05,8'hbb,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'hfd,8'hfd,8'hfd,8'hf9,8'h05,8'hd9,8'hfd,8'hfd,8'h24,8'h05,8'h05,8'hbb,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'hfd,8'hfe,8'h05,8'hfd,8'hd9,8'hd5,8'h05,8'hd9,8'hd5,8'hfd,8'h05,8'h05,8'h05,8'hbb,8'h05,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h00,8'h00,8'h8c,8'hfd,8'hfd,8'h05,8'h05,8'h6c,8'hfd,8'hfd,8'h6c,8'hfe,8'h05,8'h05,8'h05,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfe,8'hfe,8'h00,8'h00,8'h00,8'h00,8'hfd,8'h05,8'h05,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h05,8'h00,8'h00,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfd,8'h05,8'h05,8'h05,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'hfd,8'h00,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfd,8'h05,8'h05,8'h05,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'h05,8'hda,8'h00,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h24,8'h00,8'h25,8'h05,8'h05,8'h92,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h05,8'h00,8'h05,8'h05,8'h05,8'h04,8'h2c,8'hfe,8'hfd,8'hfd,8'hfd,8'h00,8'h00,8'hff,8'hff,8'hfc,8'hf8,8'hf9,8'h6d,8'h00,8'h00,8'hda,8'h05,8'h05,8'h05,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h05,8'h00,8'h05,8'h91,8'hd5,8'hd9,8'hd9,8'h24,8'h00,8'h00,8'h60,8'h80,8'ha0,8'h80,8'h80,8'h00,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'h64,8'ha0,8'h60,8'h00,8'h00,8'hd9,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h6c,8'h00,8'h80,8'h80,8'hc5,8'hc5,8'hc5,8'hc5,8'hc5,8'hc5,8'hc5,8'hc5,8'hc5,8'hfc,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'h20,8'hc5,8'hc5,8'hc5,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h24,8'h00,8'h00,8'ha0,8'hc5,8'hc5,8'hc5,8'hc5,8'hc5,8'hc5,8'hc5,8'hc5,8'hc5,8'hc5,8'hfe,8'hfa,8'hf8,8'hf5,8'h00,8'h00,8'hd4,8'hf8,8'hf8,8'hc5,8'hc5,8'hc5,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h05,8'hd5,8'h00,8'h00,8'hc5,8'hc5,8'hc5,8'hc5,8'hc5,8'hc5,8'hc5,8'hc5,8'hc4,8'hfe,8'hfe,8'hfe,8'hfe,8'h00,8'hf4,8'hf4,8'hf9,8'hfe,8'hc4,8'hc5,8'hc5,8'hc5,8'h60,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h05,8'hd9,8'hd9,8'h00,8'h00,8'hc5,8'hc5,8'hc5,8'hc5,8'hc5,8'hf1,8'hf6,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfa,8'h00,8'h00,8'hfa,8'hfe,8'hc4,8'hc5,8'hc5,8'hc5,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h01,8'h05,8'h04,8'h00,8'h00,8'h00,8'hc5,8'hc5,8'hc4,8'hc5,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfa,8'hfa,8'hfe,8'hfe,8'hfe,8'hfa,8'hc5,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h05,8'h05,8'hb5,8'h05,8'h00,8'h00,8'h00,8'h00,8'hc5,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'hb1,8'hd5,8'hd5,8'h00,8'h05,8'hd5,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h91,8'hd9,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h20,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};

	
	
	
	
	
//};


//////////--------------------------------------------------------------------------------------------------------------=
//hit bit map has one bit per edge:  hit_colors[3:0] =   {Left, Top, Right, Bottom}	
//there is one bit per edge, in the corner two bits are set  

//each picture row and column divided to 8 sections 


logic [0:7] [0:7] [3:0] hit_colors = 
		  {32'hC4444446,     
			32'h8C444462,    
			32'h88C44622,    
			32'h888C6222,    
			32'h88893222,    
			32'h88911322,    
			32'h89111132,    
			32'h91111113};
 

 
 
// pipeline (ff) to get the pixel color from the array 	 

//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
		enroll_collision <= 2'b0;
	end

	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default  
		enroll_collision <= 2'b0;

		if (InsideRectangle1 == 1 && enroll1 ) 
		begin // inside an external bracket 
			RGBout <= object_colors1[offsetY][offsetX];
			enroll_collision[0]<=1;
		end  	
		
		else if (InsideRectangle2 == 1 && enroll2)
		begin
			RGBout <= object_colors2[offsetY_2][offsetX_2];
			enroll_collision[1]<=1;
		end
		
	end
		
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule