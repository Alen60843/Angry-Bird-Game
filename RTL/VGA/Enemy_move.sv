// (c) Technion IIT, Department of Electrical Engineering 2023 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 
// update the hit and collision algoritm - Eyal Jan 2024

module	Enemy_move	(	
 
					input	 logic clk,
					input	 logic resetN,
					input	 logic startOfFrame,      //short pulse every start of frame 30Hz  		
					input    logic collision,         //collision if enemy hits an object
					
					input  logic [10:0] pigTLX,
					input  logic [10:0] pigTLY,
					
					
					input  logic timer,
					input  logic fire,      //the approval to fire
				   input  logic signed [4:0] randomValue, // random value input (0 to 15)
					input  logic preGame,
					output logic signed [10:0] topLeftX, // output the top left corner 
					output logic signed [10:0] topLeftY,  // can be negative , if the object is partliy outside 
					output logic shooting
					
					
);

parameter int INITIAL_X=500;
parameter int INITIAL_Y=300;

  
parameter int INITIAL_SPEED_X = 2;
parameter int INITIAL_SPEED_Y = 2;


parameter int MAX_SPEED_X = 40;
parameter int MAX_SPEED_Y = 40;

parameter int X_ACCEL = 10;
parameter int Y_ACCEL = 10;




const int	FIXED_POINT_MULTIPLIER = 64; // note it must be 2^n 
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions


// movement limits 
const int   OBJECT_WIDTH_X = 32;
const int   OBJECT_HIGHT_Y = 32;
const int	SafetyMargin   =  2;

const int	x_FRAME_LEFT	=	(SafetyMargin)* FIXED_POINT_MULTIPLIER; 
const int	x_FRAME_RIGHT	=	(639 - SafetyMargin - OBJECT_WIDTH_X)* FIXED_POINT_MULTIPLIER; 
const int	y_FRAME_TOP		=	(SafetyMargin) * FIXED_POINT_MULTIPLIER;
const int	y_FRAME_BOTTOM	=	(479 -SafetyMargin - OBJECT_HIGHT_Y ) * FIXED_POINT_MULTIPLIER; //- OBJECT_HIGHT_Y
const int   floor 			=    y_FRAME_BOTTOM - OBJECT_HIGHT_Y * FIXED_POINT_MULTIPLIER; // floor for the object to stop moving


enum  logic [3:0] {IDLE_ST,         	// initial state
						 MOVE_ST, 				// moving no colision 
						 WAIT_ST,
						 POSITION_CHANGE_ST, // position interpolate 
						 POSITION_LIMITS_ST  // check if inside the frame  
						}  SM_Motion ;

int Yspeed  ; // speed 
int Xspeed  ;
    
int Xposition ; //position   
int Yposition ;  
 

 //---------
 
always_ff @(posedge clk or negedge resetN)
begin : fsm_sync_proc

	if (resetN == 1'b0) begin 
		SM_Motion <= IDLE_ST ; 
		Yspeed <= 0   ;
		Xspeed <=0;	
   	Xposition <= 0; 
		Yposition <= 0; 
		shooting	<= 0 ;
	
	end 	
	
	else begin
	    
		case(SM_Motion)
			
		//------------
			IDLE_ST: begin
		//------------
		      shooting <= 0;
				Xspeed <= (randomValue * 3 ) - 48; 
				Yspeed <= INITIAL_SPEED_Y;

   			Xposition <= (pigTLX + 64) * FIXED_POINT_MULTIPLIER; 
				Yposition <= (pigTLY - 32) * FIXED_POINT_MULTIPLIER; 

				if (timer && fire && !preGame) begin 			
               		SM_Motion <= MOVE_ST ;
				end
			end
	
		//------------
			MOVE_ST:  begin     // moving no colision 
		//------------

       //collcting collisions 	
				if (collision) begin
					SM_Motion <= IDLE_ST ;
					shooting <= 0;
				end
				

				if (startOfFrame) begin
				     SM_Motion <= WAIT_ST ; 
				end	
				
		end 
		
		//------------
			WAIT_ST:  begin     // waiting for next clk 
		//------------
			shooting <= 1 ;
       		SM_Motion <= POSITION_CHANGE_ST ;
				
		end		
		

		//------------------------
			POSITION_CHANGE_ST : begin  // position interpolate 
		//------------------------
			 
				if (Xspeed <= MAX_SPEED_X && Xspeed >= -MAX_SPEED_X)
                    Xspeed <= Xspeed + ((Xspeed > 0) ? X_ACCEL : -X_ACCEL);

                if (Yspeed <= MAX_SPEED_Y)
                    Yspeed <= Yspeed + Y_ACCEL;

                Yposition <= Yposition - Yspeed;
                Xposition <= Xposition + Xspeed;

                SM_Motion <= POSITION_LIMITS_ST;
			end
		
		//------------------------
			POSITION_LIMITS_ST : begin  //check if still inside the frame 
		//------------------------
   	 
	    if (Yposition >= y_FRAME_BOTTOM || Xposition <= x_FRAME_LEFT ) begin

   				Xposition <= ( pigTLX  + 50 ) * FIXED_POINT_MULTIPLIER; 
					Yposition <= ( pigTLY  - 50 ) * FIXED_POINT_MULTIPLIER;
				
						SM_Motion <= IDLE_ST;
						shooting <= 0;
				    end
					 
			if(Xposition >= x_FRAME_RIGHT) begin
				Xspeed 	 <= -Xspeed;
				Xposition <=  x_FRAME_RIGHT;
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
 
