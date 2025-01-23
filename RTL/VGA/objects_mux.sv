
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
		   // plane 
					
				input		logic	planeDrawingRequest, // two set of inputs per unit
				input		logic	[7:0] planeRGB, 
				     
		  // add the box here 
				input		logic	squareDrawingRequest, // two set of inputs per unit
				input		logic	[7:0] squareRGB, 
		  
		  
		  //bird
				input		logic	birdDrawingRequest, 
				input		logic	[7:0] birdRGB, 
				
			//lives
				input    logic livesDrawingRequest,
				input		logic	[7:0] livesRGB,
				
				
				
				
		  ////////////////////////
		  // background 
				input    logic HouseDrawingRequest, // box of numbers
				input		logic	[7:0] houseRGB, 
					
				input		logic	[7:0] RGB_MIF, 
					
				input 	logic EnemyDrawingRequest,
				input 	logic [7:0] enemyRGB,
					
			//GAME OVER
				
				input gameoverDrawingRequest,
				input [7:0] gameoverRGB,
				
			// BLACK SCREEN
				input BlackScreenDrawingRequest,
				input [7:0] blackRGB,
			
			// VICTORY
				
				input victoryDrawingRequest,
				input [7:0] victoryRGB,
				
				input victory1DrawingRequest,
				input [7:0] victory1RGB,
				
				input victory2DrawingRequest,
				input [7:0] victory2RGB,
				
				//Lives heart
				
				input heartDrawingRequest,
				input [7:0] heartRGB,
				
				
				//TRACES
				input tracesDrawingRequest,
				input [7:0] tracesRGB,
				
				// SCORE WITH NUMBERS
				input highDrawingRequest,    // HIGH
				input [7:0]highRGB,
				
				input midDrawingRequest,    // MID
				input [7:0]midRGB,
				
				input lowDrawingRequest,    // LOW
				input [7:0]lowRGB,
					
				input scoreDrawingRequest, //score
				input [7:0] scoreRGB,
				
				input preGameDrawingRequest,//Pre Game Screen
				input [7:0] preGame,
				
		
			   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
	
		if (victoryDrawingRequest == 1'b1 )  //first priority 
			RGBOut <= victoryRGB;  
			
		else if(preGameDrawingRequest == 1'b1)
			RGBOut <= preGame;	
	
		else if (gameoverDrawingRequest == 1'b1 )   
			RGBOut <= gameoverRGB;
			
		else if(victory1DrawingRequest ==1'b1)
			RGBOut <= victory1RGB;
			
		else if(victory2DrawingRequest ==1'b1)
			RGBOut <= victory2RGB;
			
		else if (lowDrawingRequest == 1'b1)
				RGBOut <= lowRGB;
				
		else if (midDrawingRequest == 1'b1)
				RGBOut <= midRGB;
		
      else if (highDrawingRequest == 1'b1)
				RGBOut <= highRGB;	
			
      else if (scoreDrawingRequest == 1'b1)
				RGBOut <= scoreRGB;	
			
		else if (BlackScreenDrawingRequest == 1'b1)
				RGBOut <= blackRGB;	
				
		else if (planeDrawingRequest == 1'b1 )   
			RGBOut <= planeRGB;  //first priority 
		
		else if(birdDrawingRequest == 1'b1)
			RGBOut <= birdRGB;
		 
		 // add logic for box here 
		 
//--------------------------------------------------------------------------------------------		
		
		//else if (squareDrawingRequest == 1'b1)
		//		RGBOut <= squareRGB;
		
		else if (EnemyDrawingRequest == 1'b1)
			RGBOut <= enemyRGB;
			
		else if(tracesDrawingRequest == 1'b1)
			RGBOut <= tracesRGB;

 		else if (HouseDrawingRequest == 1'b1)
			RGBOut <= houseRGB;
			
		else if (livesDrawingRequest == 1'b1)
			RGBOut <= livesRGB;
			
		else if(heartDrawingRequest == 1'b1)
			RGBOut <= heartRGB;
			
				
		else RGBOut <= RGB_MIF ;// last priority 
		end ; 
	end

endmodule


