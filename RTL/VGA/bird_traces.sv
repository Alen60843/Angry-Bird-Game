module bird_traces (
    input logic clk,
    input logic resetN,
    input logic startOfFrame,        // Short pulse every start of frame (30Hz)
    input logic signed [10:0] X_position, // Bird's X position
    input logic signed [10:0] Y_position, // Bird's Y position
    input logic birdDR,              // Bird is active on screen
    input logic collision,           // Collision detected

    output logic signed [10:0] topLeftX, // Object's top-left X coordinate
    output logic signed [10:0] topLeftY, // Object's top-left Y coordinate
    output logic draw                 // Signal to draw the object
);

parameter int FIXED_POINT_MULTIPLIER = 64;  
parameter int OBJECT_WIDTH_X = 16;          // Object width in pixels
parameter int OBJECT_HEIGHT_Y = 16;         // Object height in pixels
parameter int SafetyMargin = 2;             // Safety margin for screen boundaries
parameter int DELAY_FRAMES = 10;            // Number of frames for trace delay

// Fixed-point screen boundaries
localparam int x_FRAME_LEFT = (SafetyMargin) * FIXED_POINT_MULTIPLIER; 
localparam int x_FRAME_RIGHT = (639 - SafetyMargin - OBJECT_WIDTH_X) * FIXED_POINT_MULTIPLIER; 
localparam int y_FRAME_TOP = (SafetyMargin) * FIXED_POINT_MULTIPLIER;
localparam int y_FRAME_BOTTOM = (479 - SafetyMargin - OBJECT_HEIGHT_Y) * FIXED_POINT_MULTIPLIER;

// FSM States
typedef enum logic [1:0] {
    IDLE_ST,             // Initial state
    MOVE_ST              // Moving state
} motion_state_t;

motion_state_t SM_Motion;

// Internal signals
logic signed [15:0] Xposition_FixedPoint;  // Object's X position in fixed-point
logic signed [15:0] Yposition_FixedPoint; // Object's Y position in fixed-point
logic signed [15:0] positionHistoryX[0:DELAY_FRAMES-1]; // History X
logic signed [15:0] positionHistoryY[0:DELAY_FRAMES-1]; // History Y
logic [3:0] historyIndex;                  

always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
        SM_Motion <= IDLE_ST;
        Xposition_FixedPoint <= 0;
        Yposition_FixedPoint <= 0;
        historyIndex <= 0;
        draw <= 0;
        for (int i = 0; i < DELAY_FRAMES; i++) begin
            positionHistoryX[i] <= X_position * FIXED_POINT_MULTIPLIER;
            positionHistoryY[i] <= Y_position * FIXED_POINT_MULTIPLIER;
        end
    end else begin
        case (SM_Motion)
        //----------------
            IDLE_ST: begin
        //----------------
                draw <= 0;
                for (int i = 0; i < DELAY_FRAMES; i++) begin
                    positionHistoryX[i] <= X_position * FIXED_POINT_MULTIPLIER;
                    positionHistoryY[i] <= Y_position * FIXED_POINT_MULTIPLIER;
                end
                historyIndex <= 0; 
                if (birdDR) begin
                    SM_Motion <= MOVE_ST;
                end
            end
         //----------------
            MOVE_ST: begin
         //----------------
                if (collision || !birdDR) begin
                    SM_Motion <= IDLE_ST; // Return to idle on collision or bird not active
                end else if (startOfFrame) begin // Update position history  
                    positionHistoryX[historyIndex] <= X_position * FIXED_POINT_MULTIPLIER;
                    positionHistoryY[historyIndex] <= Y_position * FIXED_POINT_MULTIPLIER;

                    historyIndex <= (historyIndex + 1) % DELAY_FRAMES;

                    Xposition_FixedPoint <= positionHistoryX[historyIndex];
                    Yposition_FixedPoint <= positionHistoryY[historyIndex];

                    draw <= 1;
                end
            end
        endcase
    end
end

// Assign output coordinates by converting back from fixed-point
assign topLeftX = Xposition_FixedPoint / FIXED_POINT_MULTIPLIER;
assign topLeftY = Yposition_FixedPoint / FIXED_POINT_MULTIPLIER;

endmodule