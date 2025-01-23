// (c) Technion IIT, Department of Electrical Engineering 2023 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 
// update the hit and collision algoritm - Eyal Jan 2024

module score_controller (
    input logic clk,
    input logic resetN,
    input logic BirdFire,
	 input logic level1Victory,
	 input logic level2Victory,
	 input logic  preGame,
	 
    output logic [3:0] digitLOW,
    output logic [3:0] digitMID,
    output logic [3:0] digitHIGH,
    
    output logic [10:0] lowX,
    output logic [10:0] lowY,
    
    output logic [10:0] midX,
    output logic [10:0] midY,
    
    output logic [10:0] highX,
    output logic [10:0] highY,
    
    output logic [10:0] scoreX,
    output logic [10:0] scoreY
);

logic [3:0] countLOW;
logic [3:0] countHIGH;
logic [3:0] countMID;
logic BirdFire_D;
const int correction = 22;
parameter int topY = 300;

assign scoreX = 3;
assign scoreY = topY;

assign highX = 70;
assign highY = topY;

assign midX = 70 + correction;
assign midY = topY;

assign lowX = 70 + 2 * correction;
assign lowY = topY;

enum logic [1:0] {
    IDLE_ST,
    MINUS_ST,
    UPDATE_ST
} state;

always_ff @(posedge clk or negedge resetN) begin : fsm_sync_proc
    if (!resetN) begin
        state <= IDLE_ST;
        digitLOW <= 4'b0000;
        digitMID <= 4'b0000;
        digitHIGH <= 4'b0001;
        countLOW <= 0;
        countMID <= 0;
        countHIGH <= 1;
        BirdFire_D <= 0;
    end else begin
        BirdFire_D <= BirdFire;

        case (state)
            IDLE_ST: begin
                if (BirdFire && !BirdFire_D && !level1Victory && !level2Victory && !preGame) 
                    state <= MINUS_ST;
            end

            MINUS_ST: begin
               
			   if(countHIGH == 0) begin
					if(countMID != 0) begin
						if(countLOW != 0) 
							countLOW <= countLOW - 1;
						else if(countLOW == 0) begin
							countMID <= countMID - 1;
							countLOW <= 4'b1001;
							end 
					end
					else begin
						if(countLOW != 0)
							countLOW <= countLOW - 1; 
						end
			   end
					else begin
						countHIGH <= countHIGH - 1;
						countMID <= 4'b1001;
						countLOW <= 4'b1001;
					end
					 state <= UPDATE_ST;

			   end
            
            UPDATE_ST: begin
                // Update output digits
                digitLOW <= countLOW;
                digitMID <= countMID;
                digitHIGH <= countHIGH;
                state <= IDLE_ST;
            end

            default: state <= IDLE_ST;
        endcase
    end
end

endmodule
