// ============================================================================
// Copyright (c) 2012 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altrea Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL or Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//
//
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// ============================================================================
//
// Major Functions:i2c controller
//
// ============================================================================
//
// Revision History :
// ============================================================================
//   Ver  :| Author              :| Mod. Date :| Changes Made:
//   V1.0 :| Allen Wang          :| 03/25/10  :|      Initial Revision
//   V3.0 :| Young               :| 01/05/10  :|  vision 12.1
// ============================================================================
// Jan 2018 Alex Grinshpun - algrin
module i2c (
			input logic  CLOCK31_5,
			input logic  RESET,
			input logic  CLOCK_500_ena,
			input logic  CLOCK_500,
			input logic  CLOCK_SDAT_ena,
			input logic  TRANSACTION_REQ,      		//GO transfor
			output	logic  NEXT_WORD, 				//			
			output	logic  I2C_SCLK,					//I2C CLOCK
			output	logic  FPGA_I2C_SCLK,
			output	logic	 SDO,
			input  	logic  I2C_SDAT, 					//I2C DATA out
			input		logic [23:0]	 I2C_DATA		//DATA:[SLAVE_ADDR,SUB_ADDR,DATA]

			);//,




logic 			 SCLK;

logic 	[23:0]	 SD;
logic 	[5:0]	 SD_COUNTER;



logic ACK1,ACK2,ACK3;
logic ACK ;
logic SDO_FF_1, SDO_FF_2, SDO_FF_3; // algrin
integer i= 0;
assign ACK = ACK1 | ACK2 | ACK3;
//=============================================================================
// Structural coding algrin
//=============================================================================


//==============================I2C COUNTER====================================
logic NEXT_WORD_del;
logic NEXT_WORD_cyc;
logic I2C_clk_en;
logic I2C_clk_0;
logic I2C_clk_1;
logic I2C_clk_0_clk;
logic FPGA_I2C_SCLK_clk;

always_ff @(posedge CLOCK31_5 or negedge RESET ) //algrin) 
begin
	if ( !RESET ) //algrin
	begin
		NEXT_WORD_del	<=0;
	end
	else
        begin
		NEXT_WORD_del	<= NEXT_WORD_cyc;
	end
end

//algrin
assign FPGA_I2C_SCLK	= (I2C_clk_en | (CLOCK_500)) & I2C_clk_0;
assign FPGA_I2C_SCLK_clk	= (I2C_clk_1 | (CLOCK_500)) & I2C_clk_0_clk;
assign NEXT_WORD	= NEXT_WORD_cyc && (! NEXT_WORD_del);

always_ff @(negedge RESET or posedge CLOCK31_5 ) 
	begin
		if (!RESET)
			begin
				SD_COUNTER	<= 6'b000000;
			end
		else begin
				if (NEXT_WORD ==1 ) begin
					SD_COUNTER	<= 6'b000000;
				end else begin
				 if ((CLOCK_SDAT_ena == 1) && (TRANSACTION_REQ == 1)) begin
					if (SD_COUNTER < 6'b111111)
							begin
								SD_COUNTER	<= SD_COUNTER+1;
							end	
					 end		
			          end	
				end
	end
//==============================I2C COUNTER====================================


always_ff @(negedge RESET or  posedge CLOCK31_5 ) 
	begin

		if (~RESET) 
			begin 
				I2C_clk_en	<=	1'b1 ;
				I2C_clk_0	<=	1'b1 ;
				SDO			<= 1; 
				ACK1		<= 0;
				ACK2		<= 0;
				ACK3		<= 0; 
				NEXT_WORD_cyc  <= 0; 
			end
		else
			case (SD_COUNTER)
					6'd0  : begin 
								ACK1 <= 0 ;
								ACK2 <= 0 ;
								ACK3 <= 0 ; 
								SDO  <=	1  ; 
								I2C_clk_en	<=	1'b1 ;
								I2C_clk_0	<=	1'b1 ;
							end
					//=========start===========
					6'd1  : 	begin 
								SD  <= I2C_DATA;
								SDO <= 0;
								NEXT_WORD_cyc  <= 0 ;
														
							end
						
					6'd2  : 	begin 
								SD  		<= I2C_DATA;
								I2C_clk_en	<=	1'b0 ;
								I2C_clk_0	<=	1'b0 ;
							end
	
					6'd3  : 	 begin
								I2C_clk_0	<=1'b1 ;
								SDO			<= SD[23];
							end
					//======SLAVE ADDR=========
					
					6'd4  : 	begin
									SDO		<= SD[22];
						end
					6'd5  : 	SDO 		<= SD[21];
					6'd6  : 	begin
									SDO		<= SD[20];
					end
					6'd7  : 	SDO			<= SD[19];
					6'd8  : 	SDO			<= SD[18];
					6'd9  :		SDO			<= SD[17];
					6'd10 : 	SDO			<= SD[16];	
					6'd11 : 	SDO			<= 1'b1;//ACK

					//========SUB ADDR==========
					6'd12  : 	begin 
								SDO			<= SD[15]; 
								ACK1		<= I2C_SDAT; 
							 end
					6'd13  : 	SDO			<= SD[14];
					6'd14  : 	SDO			<= SD[13];
					6'd15  : 	SDO			<= SD[12];
					6'd16  : 	SDO			<= SD[11];
					6'd17  : 	SDO			<= SD[10];
					6'd18  : 	SDO			<= SD[9];
					6'd19  : 	SDO			<= SD[8];	
					6'd20  : 	SDO			<= 1'b1;//ACK

					//===========DATA============
					6'd21  : begin 
								SDO			<= SD[7]; 
								ACK2		<= I2C_SDAT; 
							 end
					6'd22  : 	SDO			<= SD[6];
					6'd23  : 	SDO			<= SD[5];
					6'd24  : 	SDO			<= SD[4];
					6'd25  : 	SDO			<= SD[3];
					6'd26  : 	SDO			<= SD[2];
					6'd27  : 	SDO			<= SD[1];
					6'd28  : 	SDO			<= SD[0];	
					6'd29  : 	begin 
								SDO			<= 1'b1;//ACK
							end

	
					//stop
					6'd30 : begin 
								SDO			<= 1'b0;	
								I2C_clk_en	<=1'b1 ;
								ACK3		<= I2C_SDAT;
								NEXT_WORD_cyc  <= 0 ;	
							end	
					6'd31 : 	begin
								
								NEXT_WORD_cyc <= 1; 
								end
					6'd32 : 	begin 
								SDO				<=	1'b1;
								I2C_clk_0		<=	1'b1 ; 
								NEXT_WORD_cyc	<=	0; 
								
							end 

			endcase
		end



endmodule
