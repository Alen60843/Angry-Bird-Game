// (c) Technion IIT, Department of Electrical Engineering 2023 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 
// update the hit and collision algoritm - Eyal Jan 2024

module	bird_move	(	
 
					input	 logic clk,
					input	 logic resetN,
					input	 logic startOfFrame,     	 //short pulse every start of frame 30Hz 
					// input	 logic enable_sof,    	// if want to stop the smiley move
					input  logic  [10:0] initialX_speed,
					input  logic signed [10:0] initial_X,
					input	 logic signed [10:0] initial_Y,
					input logic   fire_the_bird,
					input logic   DR, //check if there is another bird on the screen
					input logic   collision,

					output logic signed 		 [10:0] topLeftX, // output the top left corner 
					output logic signed	    [10:0] topLeftY,  // can be negative , if the object is partliy outside
					output logic enroll
					
					
);


// a module used to generate the  ball trajectory.  


parameter int INITIAL_Y_SPEED = 0;
parameter int Y_ACCEL = 10;


logic signed [10:0] start_bird_x;
logic signed [10:0] start_bird_y;



const int   MAX_Y_SPEED = 200;
const int	FIXED_POINT_MULTIPLIER = 64; // note it must be 2^n 
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions


// movement limits 
const int   OBJECT_WIDTH_X = 32;
const int   OBJECT_HIGHT_Y = 32;//WAS 128
const int	SafetyMargin   =	2;

const int	x_FRAME_LEFT	=	(SafetyMargin)* FIXED_POINT_MULTIPLIER; 
const int	x_FRAME_RIGHT	=	(639 - SafetyMargin - OBJECT_WIDTH_X)* FIXED_POINT_MULTIPLIER; 
const int	y_FRAME_TOP		=	(SafetyMargin) * FIXED_POINT_MULTIPLIER;
const int	y_FRAME_BOTTOM	=	(479 -SafetyMargin - OBJECT_HIGHT_Y ) * FIXED_POINT_MULTIPLIER; //- OBJECT_HIGHT_Y


enum  logic [2:0] {IDLE_ST,         	     // initial state
						 MOVE_ST,			    // moving no colision 
						 POSITION_CHANGE_ST,  // position interpolate 
						 POSITION_LIMITS_ST  // check if inside the frame  
						}  SM_Motion ;

int Xspeed  ; // speed    
int Yspeed  ; 
int Xposition ; //position   
int Yposition ;
 
 
logic fire_the_bird_prev;
logic fire_the_bird_rise;
 


 
always_ff @(posedge clk or negedge resetN)
begin : fsm_sync_proc

	if ( !resetN ) begin 
	
		SM_Motion <= IDLE_ST ;
	
		Xspeed <= initialX_speed  ; 
		Yspeed <= 0  ; 
		Xposition <= 0 ; 
		Yposition <= 0 ; 
		fire_the_bird_prev <= 0;
		enroll <= 0;

		
	end 	
	
	
	else begin
			
			
			start_bird_x <= initial_X + OBJECT_WIDTH_X/2 ;
			start_bird_y <= initial_Y + OBJECT_WIDTH_X/2 ;
			
			
			fire_the_bird_prev <= fire_the_bird;
			fire_the_bird_rise <= fire_the_bird & !fire_the_bird_prev;
		
		
		
		
		case(SM_Motion)
				
		//------------
			IDLE_ST: begin
		//------------
				
				Xspeed <= initialX_speed *2 ;
				Yspeed <= INITIAL_Y_SPEED;
				
				Xposition <= start_bird_x * FIXED_POINT_MULTIPLIER; 
				Yposition <= start_bird_y * FIXED_POINT_MULTIPLIER;
				
				if(fire_the_bird_rise) begin
					SM_Motion <= MOVE_ST;	
					enroll <= 1;
					end
			end
			
				
		//------------
			MOVE_ST: begin
		//------------
				
				//	if(DR && collision)begin
				//		SM_Motion <= IDLE_ST;
				//		enroll <= 0;
				//		end
						
					if (startOfFrame )
						SM_Motion <= POSITION_CHANGE_ST ;
				end		
					
				
		//------------
			POSITION_CHANGE_ST: begin
		//------------
		
		
				if (Yspeed < MAX_Y_SPEED ) 
   				Yspeed <= Yspeed + Y_ACCEL ; 
					
				Xposition <= Xposition  + Xspeed ;
				Yposition <= Yposition 	+ Yspeed ;
				
		
				SM_Motion <= POSITION_LIMITS_ST ; 
	
			end
			
				
		//------------
			POSITION_LIMITS_ST: begin
		//------------
				
			if (Xposition < x_FRAME_LEFT) 
						Xspeed <= -Xspeed ; 
						
			 if (Xposition > x_FRAME_RIGHT)		
						Xspeed <= -Xspeed ;
	 
						
			 if (Yposition > y_FRAME_BOTTOM) begin
				Yposition <= start_bird_y * FIXED_POINT_MULTIPLIER;
				Xposition <= start_bird_x * FIXED_POINT_MULTIPLIER;
				SM_Motion <= IDLE_ST;
			   enroll <= 0;	
			end
			
			else
				SM_Motion <= MOVE_ST ;
	
		end
			
		
	endcase  // case 

		
	end 

end // end fsm_sync


//return from FIXED point  trunc back to prame size parameters 
  
assign 	topLeftX = Xposition / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = Yposition / FIXED_POINT_MULTIPLIER ;   	

endmodule	
//---------------
 
