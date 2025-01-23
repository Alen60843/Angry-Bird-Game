// (c) Technion IIT, Department of Electrical Engineering 2020 

// Implements a slow clock as an one-second counter
// Turbo input sets output 10 times faster
// Updated by Mor Dahan - January 2022
// Updated by Dudy BarOn - October 2023

 
 module one_sec_counter      	
	(
   // Input, Output Ports
	input  logic clk, 
	input  logic resetN, 
	input  logic turbo,
	output logic one_sec
   );
	
	int oneSecCount ;
	int sec ;		 // gets either one seccond or Turbo top value

	
//       ----------------------------------------------	counter limit setting
	parameter int oneSecVal= 32'd50_000_000; // for DE10 board un-comment this line
//       ----------------------------------------------	
	
	assign  sec = turbo ? oneSecVal/10 : oneSecVal;  // it is legal to devide by 10, as it is done by the complier not by logic (actual transistors) 


	
   always_ff @( posedge clk or negedge resetN )
   begin
	
		// asynchronous reset
		if ( !resetN ) begin
			one_sec <= 1'b0;
			oneSecCount <= 32'd0;
		end // if reset
		
		// executed once every clock 	
		else begin
			if (oneSecCount >= sec) begin
				one_sec <= 1'b1;
				oneSecCount <= 32'd0;
			end
			else begin
				oneSecCount <= oneSecCount + 1;
				one_sec		<= 1'b0;
			end
		end // else clk
		
	end // always
	
endmodule