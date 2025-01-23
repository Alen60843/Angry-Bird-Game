
// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021

module	objects_mux	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
		   // smiley 
					
					input		logic	smileyDrawingRequest, // two set of inputs per unit
					input		logic	[7:0] smileyRGB, 
					     
		  // add the box here 
					input		logic	squareDrawingRequest, // two set of inputs per unit
					input		logic	[7:0] squareRGB, 
		  
		  
		  //bird
				input		logic	birdDrawingRequest, 
				input		logic	[7:0] birdRGB, 
				
				
				
				
				
				
		  ////////////////////////
		  // background 
					input    logic HouseDrawingRequest, // box of numbers
					input		logic	[7:0] houseRGB,   
					input		logic	[7:0] backGroundRGB, 
					input		logic	BGDrawingRequest, 
					input		logic	[7:0] RGB_MIF, 
			  
				   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
		if (smileyDrawingRequest == 1'b1 )   
			RGBOut <= smileyRGB;  //first priority 
		
		else if(birdDrawingRequest == 1'b1)
			RGBOut <= birdRGB;
		 
		 // add logic for box here 
		 
//--------------------------------------------------------------------------------------------		
		
		//else if (squareDrawingRequest == 1'b1)
		//		RGBOut <= squareRGB;

 		else if (HouseDrawingRequest == 1'b1)
			RGBOut <= houseRGB;
				
		else if (BGDrawingRequest == 1'b1)
				RGBOut <= backGroundRGB ;
				
		else RGBOut <= RGB_MIF ;// last priority 
		end ; 
	end

endmodule


