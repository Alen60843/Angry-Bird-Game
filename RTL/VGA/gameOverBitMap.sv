// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2021
// (c) Technion IIT, Department of Electrical Engineering 2021 



module	GameOverBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket
					input logic GAMEOVER,

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ;



localparam logic [7:0] TRANSPARENT_ENCODING = 8'hff ;// RGB value in the bitmap representing a transparent pixel 

 
logic[0:31][0:31][7:0] object_colors = {
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00},
	{8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00},
	{8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00},
	{8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00},
	{8'h1c,8'h1c,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00},
	{8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00},
	{8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00},
	{8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00},
	{8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00},
	{8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00},
	{8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00},
	{8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h00},
	{8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00},
	{8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00},
	{8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h1c,8'h00,8'h00},
	{8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h00},
	{8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};



//};


//////////--------------------------------------------------------------------------------------------------------------= 
  
 
// pipeline (ff) to get the pixel color from the array 	 

//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
	 end

	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default  

		if ((InsideRectangle == 1'b1) && (GAMEOVER == 1'b1)) 
		begin // inside an external bracket 
			RGBout <= object_colors[offsetY][offsetX];  
			
		end  	
	end
		
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule