//
// coding convention dudy December 2018
// (c) Technion IIT, Department of Electrical Engineering 2021
// generating a number bitmap 



module BlackScreenBitMap	(	
					input		logic	clk,
					input		logic	resetN,
					input    logic startOfFrame,
					input 	logic	[10:0] offsetX,// offset from top left  position 
					input 	logic	[10:0] offsetY,
					input		logic	InsideRectangle, //input that the pixel is within a bracket 
					input 	logic	[3:0] digit, // digit to display
					input    logic levelChange,
					input		logic GAMEOVER,
					
					output	logic	 BLACKdrawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0]	blackRGBout
);

parameter  logic	[7:0] digit_color = 8'hff ; //set the color of the digit 


parameter int SCREEN_ON_DURATION = 100000;  // Number of clock cycles the screen stays on after levelChange

// State machine states
enum logic [1:0] {
    SCREEN_ON_ST,  // Screen is on
    SCREEN_OFF_ST  // Screen is off
} SM_Motion;

int counter; // Counter to control the screen-on duration

// FSM logic
always_ff @(posedge clk or negedge resetN) begin : fsm_sync_proc
    if (!resetN) begin
        BLACKdrawingRequest <= 1'b0;
        SM_Motion <= SCREEN_ON_ST;
        counter <= 0;
    end else begin
        case (SM_Motion)
            SCREEN_ON_ST: begin
                if ((InsideRectangle == 1'b1) && GAMEOVER) begin
                    BLACKdrawingRequest <= 1;
                end else if ((InsideRectangle == 1'b1) && levelChange) begin
                    BLACKdrawingRequest <= 1;
                    counter <= SCREEN_ON_DURATION; // Load the counter
                    SM_Motion <= SCREEN_OFF_ST;
                end
            end
            
            SCREEN_OFF_ST: begin
                if (counter > 0) begin
                    counter <= counter - 1; // Decrement the counter
                    BLACKdrawingRequest <= 1; // Keep the screen on
                end else begin
                    BLACKdrawingRequest <= 0; // Turn the screen off
                    SM_Motion <= SCREEN_ON_ST; // Return to SCREEN_ON_ST
                end
            end
        endcase
    end
end

// Output color assignment
assign blackRGBout = digit_color; // This is a fixed color

endmodule



