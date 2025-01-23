module DualSerial2parallel (


//perofrm serial to parallel and parallel to serial on both channels,  
// designed to match the i2S protocol  of WM8731 device for terrasic DE10 board 
//  writen by David Bar-On 
// (c) Technion iit Feb 2023 


	//////////// CLOCK //////////
	input		logic	clock,
	input		logic	resetn,
 	input		logic	AUD_ADCDataIn,  //inpurt serial data 
              
	input	   logic	[15:0] DACDataIn_L,
	input 	logic	[15:0] DACDataIn_R,


	input	logic	AUD_DACLRCK,   //not used 
	input	logic	AUD_ADCLRCK,   //serial slow clock  - hig=Left , low = right 
	input	logic	AUD_BCLK, // serial fast clock sampled on rizing edge 

	output	logic	ADCDATA_VALID,
	output	logic	[15:0] ADCDataOut_L,
	output	logic	[15:0] ADCDataOut_R,
	output	logic	AUD_DACDataOut // output serial data 
);

// slave mode version 

integer serial_cnt;
logic [15:0] adcdata_fifo;
logic [15:0] DACdata_fifo;
logic AUD_BCLK_D;
logic AUD_ADCLRCK_D;

const int numbits = 16;


always_ff @(posedge clock or negedge resetn) begin
  if (!resetn) begin
			adcdata_fifo	<= 16'b0;
			AUD_BCLK_D <= 0 ; 
			AUD_ADCLRCK_D <= 0 ;
			serial_cnt <= 0;
			ADCDATA_VALID <= 1'b0;

	end
	else begin
		AUD_BCLK_D <= AUD_BCLK;  //delay  
	   AUD_ADCLRCK_D <= AUD_ADCLRCK;

		
	if (AUD_ADCLRCK_D ^ AUD_ADCLRCK ) begin   //toogle detected  
			ADCDATA_VALID <= 1'b0;
			serial_cnt <= 0;
			adcdata_fifo <= 0 ; 
			DACdata_fifo  <= (AUD_ADCLRCK) ? DACDataIn_L : DACDataIn_R   ; // lod one of the channels and invert  
		end 
		else 
			if ((AUD_BCLK_D) & !AUD_BCLK) begin // falling  edge of BCLK 
		
					if (serial_cnt == numbits) begin // all bits sent  / received  +1 ofr USB mode 
						AUD_DACDataOut <= 0 ; // transmit MSB bit to DAC 
						ADCDATA_VALID <= 1'b1;
							 if (AUD_ADCLRCK   ) 
									ADCDataOut_L <=  16'hffff -  adcdata_fifo ; //store fifo to Left channel  -inveret 
								else 
									ADCDataOut_R  <= 16'hffff -  adcdata_fifo ; //store fifo to Right channel  

					end
					else begin // send /recive one bit 
							serial_cnt <= serial_cnt + 1;
								adcdata_fifo <= { adcdata_fifo[14:0], AUD_ADCDataIn }; //shift left fill ADC Value 
								DACdata_fifo <= { DACdata_fifo[14:0], 1'b0}; //shift left 
								AUD_DACDataOut <= DACdata_fifo [15] ; // transmit MSB bit to DAC 
								ADCDATA_VALID <= 1'b0;
						end
			end
	end

end




  
endmodule