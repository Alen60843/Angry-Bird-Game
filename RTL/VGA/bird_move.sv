module Bird_move (
    input logic clk,
    input logic resetN,
    input logic startOfFrame, // short pulse every start of frame 30Hz
    // input logic enable_sof, // if want to stop the smiley move
    input logic unsigned [10:0] Bird_InitialX, // initial X location
    input logic unsigned [10:0] Bird_InitialY, // initial Y location
    input logic unsigned [10:0] initial_x_speed, // initial speed on X axis
    input logic Fire_The_Bird, // command to fire the bird
    input logic collision, // collision if smiley hits an object
    input logic [3:0] HitEdgeCode, // one bit per edge
    input logic DR,
    input logic levelChange,
    output logic signed [10:0] topLeftX, // output the top left corner
    output logic signed [10:0] topLeftY, // can be negative, if the object is partly outside
    output logic shoot
);

// a module used to generate the ball trajectory.

parameter int initial_y_speed = 0;
parameter int Y_ACCEL = -10;

const int MAX_Y_SPEED = 400;
const int FIXED_POINT_MULTIPLIER = 64; // note it must be 2^n
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calculations,
// we divide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions

// movement limits
const int OBJECT_WIDTH_X = 32;
const int OBJECT_HIGHT_Y = 32;
const int SafetyMargin = 2;

const int x_FRAME_LEFT = (SafetyMargin) * FIXED_POINT_MULTIPLIER;
const int x_FRAME_RIGHT = (639 - SafetyMargin - OBJECT_WIDTH_X) * FIXED_POINT_MULTIPLIER;
const int y_FRAME_TOP = (SafetyMargin) * FIXED_POINT_MULTIPLIER;
const int y_FRAME_BOTTOM = (479 - SafetyMargin - OBJECT_HIGHT_Y) * FIXED_POINT_MULTIPLIER; // - OBJECT_HIGHT_Y

logic signed [10:0] start_bird_x;
logic signed [10:0] start_bird_y;

enum logic [2:0] {
    IDLE_ST, // initial state
    MOVE_ST, // moving no collision
    START_OF_FRAME_ST, // startOfFrame activity-after all data collected
    POSITION_CHANGE_ST, // position interpolate
    POSITION_LIMITS_ST // check if inside the frame
} SM_Motion;

logic signed [10:0] Xspeed; // speed
logic signed [10:0] Yspeed;
int Xposition; // position
int Yposition;

logic Fire_The_Bird_D;

logic [15:0] hit_reg = 16'b00000; // register to collect all the collisions in the frame. |corner|left|top|right|bottom|

//---------

always_ff @(posedge clk or negedge resetN) begin : fsm_sync_proc
    if (resetN == 1'b0) begin
        SM_Motion <= IDLE_ST;
        Xspeed <= 0;
        Yspeed <= 0;
        Xposition <= 0;
        Yposition <= 0;
        Fire_The_Bird_D <= 0;
        hit_reg <= 16'b0;
        shoot <= 0;
    end else begin
        Fire_The_Bird_D <= Fire_The_Bird; // shift register to detect edge

        start_bird_x <= Bird_InitialX + OBJECT_WIDTH_X;
        start_bird_y <= Bird_InitialY;

        case (SM_Motion)
            //------------
            IDLE_ST: begin
                //------------
                Xspeed <= 2 * initial_x_speed;
                Yspeed <= initial_y_speed;
                Xposition <= start_bird_x * FIXED_POINT_MULTIPLIER;
                Yposition <= start_bird_y * FIXED_POINT_MULTIPLIER;

                // if (startOfFrame && enable_sof) if want to stop the smiley move
                if (Fire_The_Bird && !Fire_The_Bird_D && Xposition <= 320 * FIXED_POINT_MULTIPLIER) begin
                    SM_Motion <= MOVE_ST;
                    shoot <= 1;
                end
            end

            //------------
            MOVE_ST: begin // moving no collision
                //------------
                // collecting collisions
                if (collision && DR) begin
                    hit_reg[HitEdgeCode] <= 1'b1;
                end

                if (levelChange)
                    SM_Motion <= IDLE_ST;

                if (startOfFrame)
                    SM_Motion <= START_OF_FRAME_ST;
            end

            //------------
            START_OF_FRAME_ST: begin // check if any collision was detected
                //------------
                case (hit_reg)
                    16'h0000: // no collision in the frame
                        begin
                            Yspeed <= Yspeed;
                            Xspeed <= Xspeed;
                        end
                    // CH 6H 3H 9H
                    16'h0040, 16'h0008, 16'h0200, 16'h1000: // one of the four corners
                        begin
                            Yspeed <= -Yspeed;
                            Xspeed <= -Xspeed;
                        end
                    // 8H ; (CH & 8H) ; (8H & 9H) ; (cH & 9H) ;(cH & 9H & 8H)
                    16'h0100, 16'h1100, 16'h0300, 16'h1200, 16'h1300: // left side
                        begin
                            if (Xspeed < 0)
                                Xspeed <= -Xspeed;
                        end
                    // 4H (CH & 4H) (4H & 6H) (CH & 6H) (CH & 4H & 6H)
                    16'h0010, 16'h1010, 16'h0050, 16'h1040, 16'h1050: // top side
                        begin
                            if (Yspeed < 0)
                                Yspeed <= -Yspeed;
                        end
                    // 2H (2H & 6H) (2H & 3H) (6H & 3H ) (6H & 2H &3H )
                    16'h0004, 16'h0044, 16'h000C, 16'h0048, 16'h004C: // right side
                        begin
                            if (Xspeed > 0)
                                Xspeed <= -Xspeed;
                        end
                    // 1H (1H & 9H) (1H & 3H) (3H & 9H ) (3H & 1H & 9H )
                    16'h0002, 16'h0202, 16'h000A, 16'h0028, 16'h002A: // bottom side
                        begin
                            if (Yspeed > 0)
                                Yspeed <= -Yspeed;
                        end
                    default: // complex corner
                        begin
                            Yspeed <= -Yspeed;
                            Xspeed <= -Xspeed;
                        end
                endcase

                hit_reg <= 16'h0000; // clear for next time

                SM_Motion <= POSITION_CHANGE_ST;
            end

            //------------------------
            POSITION_CHANGE_ST: begin // position interpolate
                //------------------------
                Xposition <= Xposition + Xspeed;
                Yposition <= Yposition + Yspeed;

                // accelerate
                if (Yspeed < MAX_Y_SPEED) // limit the speed while going down
                    Yspeed <= Yspeed - Y_ACCEL; // deAccelerate: slow the speed down every clock tick

                SM_Motion <= POSITION_LIMITS_ST;
            end

            //------------------------
            POSITION_LIMITS_ST: begin // check if still inside the frame
                //------------------------
                if (Xposition < x_FRAME_LEFT) begin
                    SM_Motion <= IDLE_ST;
                    shoot <= 0;
                end
                if (Xposition > x_FRAME_RIGHT) begin
                    SM_Motion <= IDLE_ST;
                    shoot <= 0; 
						  
                end
                if ((Yposition > y_FRAME_BOTTOM - 2 * OBJECT_HIGHT_Y * FIXED_POINT_MULTIPLIER) && (Xspeed == 0)) begin
                    SM_Motion <= IDLE_ST;
                    Xspeed <= initial_x_speed;
                    Yspeed <= initial_y_speed;
                    Xposition <= Bird_InitialX * FIXED_POINT_MULTIPLIER;
                    Yposition <= Bird_InitialY * FIXED_POINT_MULTIPLIER;
                end else if (Yposition > y_FRAME_BOTTOM - 2 * OBJECT_HIGHT_Y * FIXED_POINT_MULTIPLIER) begin
                    Yposition <= y_FRAME_BOTTOM - 2 * OBJECT_HIGHT_Y * FIXED_POINT_MULTIPLIER;
                    Yspeed <= -(2 * Yspeed) / 3;
                    Xspeed <= Xspeed / 2;
                end else
                    SM_Motion <= MOVE_ST;
            end
        endcase // case
    end
end // end fsm_sync

// return from FIXED point trunc back to frame size parameters

assign topLeftX = Xposition / FIXED_POINT_MULTIPLIER; // note it must be 2^n
assign topLeftY = Yposition / FIXED_POINT_MULTIPLIER;

endmodule