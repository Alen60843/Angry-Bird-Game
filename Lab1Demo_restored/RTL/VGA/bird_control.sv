// (c) Technion IIT, Department of Electrical Engineering 2023 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 
// update the hit and collision algoritm - Eyal Jan 2024

module	bird_control	(	


			    	input	 logic clk,
					input	 logic resetN,
					input	 logic fire_the_bird,      //shooting key in the game - enter	

               output logic [1:0] bird_shoot  // signals to each bird module to start shooting
);



logic [1:0] current_bird;  // 2 bits to represent 4 bullets
 
 
enum logic [1:0] {IDLE_ST,
                  DELAY_ST,
                  SHOOT_ST
                 } SM_Motion;

always_ff @(posedge clk or negedge resetN) 
begin : fsm_sync_proc	 
        
		  if (!resetN) begin
            SM_Motion <= IDLE_ST;
            current_bird <= 0;
            bird_shoot <= 2'b00;
          end
		  
		  
	else begin

         case (SM_Motion)
                
					 IDLE_ST: begin
                    
						  bird_shoot <= 2'b00;
                    if (fire_the_bird) 
                        SM_Motion <= SHOOT_ST;
						  
                end

                SHOOT_ST: begin
                    
						  bird_shoot[current_bird] <= 1'b1;
                    SM_Motion <= DELAY_ST;
                end

                
					 DELAY_ST: begin
                    bird_shoot <= 2'b00;
						  
						  if(!fire_the_bird) begin
						
                        if(current_bird == 2'b10)  
									current_bird <= 0;
								else
									current_bird <= current_bird + 1;
								SM_Motion <= IDLE_ST;
                    end  
                end

              default: SM_Motion <= IDLE_ST;
            endcase
        end
    end


endmodule	
