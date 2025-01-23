// (c) Technion IIT, Department of Electrical Engineering 2023 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 
// update the hit and collision algoritm - Eyal Jan 2024

module	plane_move	(	
 
					input	 logic clk,
					input	 logic resetN,
					input	 logic startOfFrame,     	 //short pulse every start of frame 30Hz 
					// input	 logic enable_sof,    	// if want to stop the smiley move
					
					input  logic speedDown, 		 	//decrease the speed (keyPad 4)
					input  logic speedUp,      		//increase the speed  (keyPad 6)
					
					input logic move_up, 				//move up (keyPad 8)
					input logic move_down, 				// move down (keyPad 2
					
					input  logic [3:0] HitEdgeCode, //one bit per edge
					input  logic collisionBird,         //collision if plane hits an object

					output logic signed 		 [10:0] topLeftX, // output the top left corner 
					output logic signed	    [10:0] topLeftY,  // can be negative , if the object is partliy outside 
					
					
					// data for the bird
					output logic unsigned	 [10:0] x_speed,
					output logic signed 		 [10:0] birdStartX,
					output logic signed 		 [10:0] birdStartY

					
					
);


// a module used to generate the  ball trajectory.  

parameter int INITIAL_X = 128;
parameter int INITIAL_Y = 185;
parameter int INITIAL_X_SPEED = 0;
parameter int INITIAL_Y_SPEED = 0;


const int   MAX_X_SPEED = 200;
const int	FIXED_POINT_MULTIPLIER = 64; // note it must be 2^n 
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions


// movement limits 
const int   OBJECT_WIDTH_X = 128;
const int   OBJECT_HIGHT_Y = 64;//WAS 128
const int	SafetyMargin   =	2;

const int	x_FRAME_LEFT	=	(SafetyMargin)* FIXED_POINT_MULTIPLIER; 
const int	x_FRAME_RIGHT	=	(639 - SafetyMargin - OBJECT_WIDTH_X)* FIXED_POINT_MULTIPLIER; 
const int	y_FRAME_TOP		=	(SafetyMargin) * FIXED_POINT_MULTIPLIER;
const int	y_FRAME_BOTTOM	=	(479 -SafetyMargin - OBJECT_HIGHT_Y ) * FIXED_POINT_MULTIPLIER; //- OBJECT_HIGHT_Y
const int   SPEED_INCREMENT = 25;
const int	Yposition_INCREMENT = 100;

enum  logic [2:0] {IDLE_ST,         	     // initial state
						 MOVE_ST,			    // moving no colision 
						 START_OF_FRAME_ST    // startOfFrame activity-after all data collected 
						 //POSITION_CHANGE_ST,  // position interpolate 
						 //POSITION_LIMITS_ST  // check if inside the frame  
						}  SM_Motion ;

int Xspeed  ; // speed    
int Ychagne  ; 
int Xposition ; //position   
int Yposition ;  
int speedUp_D;
int speedDown_D;

 

logic [15:0] hit_reg = 16'b00000;  // register to collect all the collisions in the frame. |corner|left|top|right|bottom|

 //---------
 
always_ff @(posedge clk or negedge resetN)
begin : fsm_sync_proc

	if ( !resetN ) begin 
	
		//SM_Motion <= IDLE_ST ;
		//Xspeed <= INITIAL_X_SPEED   ;
		//Yposition <= y_FRAME_TOP;
		//Xposition <= (OBJECT_WIDTH_X * FIXED_POINT_MULTIPLIER)/100 ; 
		
		SM_Motion <= IDLE_ST ; 
		Xspeed <= 0; 
		Ychagne <= 0; 
		Xposition <= 0; 
		Yposition <= 0; 
		speedUp_D <= 0;
		speedDown_D <= 0;

		
	end 	
	
	
	else begin
	

	
		case(SM_Motion)
		
		
		//------------
			IDLE_ST: begin
		//------------
				Xspeed  <= INITIAL_X_SPEED ; 
				Ychagne  <= INITIAL_Y_SPEED  ; 
				Xposition <= (OBJECT_WIDTH_X) ;
				Yposition <= y_FRAME_TOP; 
				
				if (startOfFrame) 
					SM_Motion <= MOVE_ST ;
					
			end
			
		//------------
			MOVE_ST: begin
		//------------
				if(speedDown && !speedDown_D && (Xspeed - SPEED_INCREMENT) >= 0) begin
               Xspeed <= Xspeed - SPEED_INCREMENT;

				end

            else if(speedUp && !speedUp_D && (Xspeed + SPEED_INCREMENT) <= MAX_X_SPEED) begin
					Xspeed <= Xspeed + SPEED_INCREMENT ;
					
				end
					
				if(move_up)
					Ychagne <= Yposition_INCREMENT;		
						
				else if(move_down)
					Ychagne <= -Yposition_INCREMENT;
						  
				if(collisionBird)
					hit_reg[HitEdgeCode] <= 1'b1;
					
					
				speedDown_D <= speedDown;
				speedUp_D <= speedUp;
				
				if(startOfFrame) 
					SM_Motion <= START_OF_FRAME_ST ; 
			end
				
		//------------
			START_OF_FRAME_ST: begin
		//------------
		
			Xposition <= Xposition + Xspeed; // Adjust scaling
			Yposition <= Yposition + Ychagne;
		
			if (Xposition < x_FRAME_LEFT) 
						Xposition <= x_FRAME_LEFT ; 
						
			if (Xposition > x_FRAME_RIGHT)		
						Xposition <= x_FRAME_LEFT ;
						
			if (Yposition < y_FRAME_TOP) 
						Yposition <= y_FRAME_TOP ; 
						
			if (Yposition > y_FRAME_BOTTOM/4) 
						Yposition <= y_FRAME_BOTTOM/4 ; 	
			
				hit_reg <= 16'b0;
				Ychagne <= 0;
				SM_Motion <= MOVE_ST ;

			end
			
		
		
	endcase  // case 

		
	end 

end // end fsm_sync




//return from FIXED point  trunc back to prame size parameters 
  
assign 	topLeftX = Xposition / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = Yposition / FIXED_POINT_MULTIPLIER ;   	

assign 	x_speed  = Xspeed  ;
assign 	birdStartX = topLeftX;
assign 	birdStartY = topLeftY;






endmodule	
//---------------















