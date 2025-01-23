
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	game_controller	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  
			
			input	logic	drawingRequest_plane,
			
			input	logic	drawing_request_boarders,
			
			input	logic	drawingRequest_Number, //output that the pixel should be dispalyed 		
			
			input logic drawingRequest_house,
			
			input logic drawingRequest_bird,
			
			input logic drawingRequest_enemy,

			
			//--------------------------------------------------------------------------------------
			
			output logic collision, // active in case of collision between two objects
			
			output logic SingleHitPulse, // critical code, generating A single pulse in a frame 
						
			output logic collision_bird_house,
			
			output logic collision_enemy_plane,
			
			output logic collision_enemy_bird 
			
	
			
			




);



assign collision = (drawingRequest_plane && drawing_request_boarders) || (drawingRequest_plane && drawingRequest_Number) ;

assign collision_bird_house = drawingRequest_bird && drawingRequest_house; 


logic flag ; // a semaphore to set the output only once per frame regardless of number of collisions 


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		flag	<= 1'b0;
		SingleHitPulse <= 1'b0 ;
		collision_enemy_plane <= 0;
		collision_enemy_bird <= 0 ;
		
		
	end 
	else begin 
			
			
			
			if(drawingRequest_enemy && drawingRequest_plane)
				collision_enemy_plane <= 1;
				
			if(drawingRequest_bird && drawingRequest_enemy)
				collision_enemy_bird <= 1;
	
		
			SingleHitPulse <= 1'b0 ; // default 
			if(startOfFrame) 
				flag <= 1'b0 ; // reset for next time 
				

			if ( (collision_enemy_plane && (flag == 1'b0)) || (collision_enemy_bird && (flag == 1'b0))  )begin 
					flag	<= 1'b1; // to enter only once 
					collision_enemy_plane <=0;
					collision_enemy_bird <= 0;
					SingleHitPulse <= 1'b1 ; 
					end 
 
			end 
end

endmodule
