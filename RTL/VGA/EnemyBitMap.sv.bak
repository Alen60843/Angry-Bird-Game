// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2021
// (c) Technion IIT, Department of Electrical Engineering 2021 



module	EnemyBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					input logic shooting,

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_NUMBER_OF_Y_BITS = 5;  // 2^5 = 32 
localparam  int OBJECT_NUMBER_OF_X_BITS = 5;  


localparam  int OBJECT_HEIGHT_Y = 1 <<  OBJECT_NUMBER_OF_Y_BITS ;
localparam  int OBJECT_WIDTH_X = 1 <<  OBJECT_NUMBER_OF_X_BITS;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_HEIGHT_Y_DIVIDER = OBJECT_NUMBER_OF_Y_BITS - 3; // -2; how many pixel bits are in every collision pixel
localparam  int OBJECT_WIDTH_X_DIVIDER =  OBJECT_NUMBER_OF_X_BITS - 3; // -2



localparam logic [7:0] TRANSPARENT_ENCODING = 8'h00 ;// RGB value in the bitmap representing a transparent pixel 

 
logic[0:31][0:31][7:0] object_colors = {
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h9d,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h84,8'h00,8'h00,8'h00,8'h00,8'h9d,8'h18,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h84,8'h00,8'h00,8'h84,8'h00,8'h00,8'h18,8'h0c,8'h10,8'h00,8'h00,8'h00,8'h0c,8'h14,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h84,8'h30,8'h18,8'h0c,8'h00,8'h18,8'h10,8'h18,8'h00,8'h00,8'h00,8'h18,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbd,8'h14,8'h18,8'h18,8'h1c,8'h18,8'h18,8'h18,8'h14,8'h0c,8'h00,8'h18,8'h10,8'h9d,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h0c,8'h18,8'h18,8'h18,8'h18,8'h14,8'h18,8'h18,8'h10,8'h70,8'h70,8'h18,8'h14,8'h0c,8'h3d,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h9d,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h30,8'h18,8'h18,8'h18,8'h18,8'h10,8'h18,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h9d,8'h10,8'h18,8'h18,8'h18,8'h10,8'h70,8'h70,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h0c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h98,8'h0c,8'h1c,8'h18,8'h18,8'h18,8'h70,8'h70,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h70,8'h6c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hbd,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h10,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h70,8'h70,8'h70,8'h70,8'h6c,8'h00,8'h60,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h90,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h70,8'h70,8'h70,8'h70,8'h0c,8'h24,8'h00,8'h60,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h0c,8'h70,8'h18,8'h18,8'h14,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h30,8'h70,8'h70,8'h70,8'h70,8'h70,8'h0c,8'h6c,8'h00,8'h20,8'h60,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'hb0,8'h1c,8'h18,8'h14,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h14,8'h70,8'h30,8'h70,8'h70,8'h70,8'h70,8'h70,8'h70,8'h0c,8'h04,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h2c,8'h70,8'h30,8'h18,8'h18,8'h18,8'h14,8'h14,8'h18,8'h18,8'h14,8'h14,8'h18,8'h18,8'h18,8'h14,8'h70,8'h70,8'h70,8'h70,8'h70,8'h70,8'h70,8'h70,8'h2c,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hb0,8'h70,8'h70,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h70,8'h70,8'h70,8'h18,8'h18,8'h18,8'h70,8'h6c,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h18,8'h18,8'h18,8'h18,8'h18,8'h1c,8'h10,8'h14,8'h18,8'h18,8'h18,8'h18,8'h18,8'h1c,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h6c,8'h0c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h18,8'h18,8'h10,8'hbd,8'h1c,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h1c,8'h04,8'h00,8'h00,8'h00,8'h00,8'h18,8'h18,8'h18,8'h15,8'h6c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h18,8'hbd,8'h1c,8'h1c,8'h1c,8'h3c,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h00,8'h00,8'h00,8'h00,8'h00,8'h18,8'h18,8'h18,8'h10,8'h2c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'hbd,8'hde,8'hff,8'hff,8'h14,8'h10,8'h1c,8'h0c,8'h1c,8'h3c,8'h1c,8'h1c,8'h18,8'h18,8'h18,8'h18,8'h18,8'h10,8'hda,8'hff,8'h0c,8'h18,8'h18,8'h18,8'h18,8'h2c,8'h0c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h9d,8'h10,8'hff,8'hff,8'h11,8'hbd,8'h0c,8'h00,8'h1c,8'h04,8'h00,8'h3c,8'h38,8'h18,8'h18,8'h1c,8'h18,8'h14,8'hff,8'hff,8'h10,8'h14,8'h18,8'h18,8'h14,8'h14,8'h6c,8'h0c,8'h00,8'h00},
	{8'h00,8'h00,8'hbd,8'h18,8'h11,8'hf9,8'h10,8'h1c,8'h04,8'h00,8'h1c,8'h0c,8'h00,8'h0c,8'h1c,8'h10,8'h18,8'h18,8'h18,8'h18,8'h10,8'h10,8'h11,8'h14,8'h18,8'h18,8'h14,8'h14,8'h11,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'hbd,8'h18,8'h18,8'hd9,8'h0c,8'h1c,8'h00,8'h0c,8'h1c,8'h0c,8'h00,8'h00,8'h1c,8'h14,8'h00,8'h00,8'h18,8'h14,8'h18,8'h10,8'h0c,8'h1c,8'h18,8'h18,8'h14,8'h14,8'h11,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'hbd,8'h18,8'h18,8'hfd,8'h10,8'h1c,8'h1c,8'h1c,8'h1c,8'h7d,8'h0c,8'hff,8'h18,8'h38,8'hfe,8'h20,8'h18,8'h18,8'h18,8'h18,8'h18,8'h14,8'h18,8'h14,8'h14,8'h14,8'h0c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h04,8'h18,8'h18,8'hfe,8'hf9,8'h10,8'h1c,8'h1c,8'h1c,8'h1c,8'h18,8'h9c,8'h18,8'h2c,8'hfd,8'h00,8'h18,8'h18,8'h18,8'h1c,8'h18,8'h18,8'h14,8'h14,8'h14,8'h15,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h10,8'h18,8'h00,8'hfe,8'hfe,8'hfe,8'hb9,8'h2c,8'h10,8'h10,8'hd9,8'hfe,8'hfe,8'hfe,8'h18,8'h18,8'h18,8'h99,8'h18,8'h14,8'h14,8'h14,8'h14,8'h0c,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h0c,8'h18,8'h18,8'h18,8'h00,8'h64,8'hfe,8'h18,8'h18,8'h04,8'h04,8'hfe,8'hfe,8'h18,8'h18,8'h18,8'h98,8'h14,8'h14,8'h14,8'h14,8'h0c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h0c,8'h0c,8'h14,8'h14,8'h18,8'h14,8'h18,8'h18,8'h18,8'h18,8'h18,8'h18,8'h14,8'h14,8'h14,8'h14,8'h14,8'h14,8'h0c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h0c,8'h14,8'h14,8'h14,8'h14,8'h14,8'h0c,8'h0c,8'h0c,8'h14,8'h14,8'h10,8'h0c,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h04,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
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

	end

	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default  
	
		if ((InsideRectangle == 1'b1) && (shooting)) 
		begin // inside an external bracket 
			RGBout <= object_colors[offsetY][offsetX];
			
		end  	
	end
		
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 

 assign drawingRequest = (RGBout != TRANSPARENT_ENCODING) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

	
	
endmodule