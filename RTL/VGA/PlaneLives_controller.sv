// (c) Technion IIT, Department of Electrical Engineering 2023 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 
// update the hit and collision algoritm - Eyal Jan 2024

module	PlaneLives_controller	(	


			    	input	 logic clk,
					input	 logic resetN,
					input	 logic collision,      
					
					output logic [3:0] digit,
					output logic no_life

);


logic [3:0] counter;

logic collision_d;

 
enum logic [1:0] {IDLE_ST,
                  PLUS_ST,
                  UPDATE_ST
                 } state;
					

				

always_ff @(posedge clk or negedge resetN) 
begin : fsm_sync_proc	 
        
		  if (!resetN) begin
            state <= IDLE_ST;
            digit <= 4'b0011;
				counter <= 4'b0011;
				no_life <=0;
				collision_d <= 0;
          end
		  
		  
	else begin
	
	collision_d <= collision; 
	
	 case (state)
	 
	   IDLE_ST: begin
		  
	       if(collision && !collision_d)
					state <= PLUS_ST;	
			end
			
			
		PLUS_ST: begin
		
		   if(counter == 0)
			   counter <= counter;

			else if(counter==1)begin
				counter <= counter - 1;
            no_life <= 1;
				end				
				
		   else begin
			   counter <= counter - 1; 	 	
		      state <= UPDATE_ST;
			end
			
			end
			
	    UPDATE_ST: begin
		 
          digit <= counter;
			 
			 state <= IDLE_ST;
			 
			end
		
	    default: state <= IDLE_ST;
		 
     endcase	
 
			  
	
		
        end
    end


endmodule	

