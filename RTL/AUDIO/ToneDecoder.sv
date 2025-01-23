/// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- This module  generate the correet prescaler tones for a single ocatave 

//-- Dudy Feb 12 2019 
//-- Eyal Lev --change values to 31.5 MHz   Apr 2023
//-- Eyal Lev --change values to OCTAVA  6   Nov 2024
module	ToneDecoder	(	
					input	logic [3:0] tone, 
					output	logic [9:0]	preScaleValue
		);

logic [0:15] [9:0]	preScaleValueTable = { 


//---------------VALUES for 31.5MHz  Octava  4------------------------

//10'h1D6,   // decimal =470.32      Hz =261.62  do    31_500_000/256/<FREQ_Hz>
//10'h1BC,   // decimal =443.92      Hz =277.18  doD
//10'h1A3,   // decimal =419.00      Hz =293.66  re
//10'h18B,   // decimal =395.49      Hz =311.12  reD
//10'h175,   // decimal =373.29      Hz =329.62  mi
//10'h160,   // decimal =352.35      Hz =349.22  fa
//10'h14D,   // decimal =332.55      Hz =370    faD
//10'h13A,   // decimal =313.89      Hz =392    sol
//10'h128,   // decimal =296.28      Hz =415.3  solD
//10'h118,   // decimal =279.64      Hz =440    La
//10'h108,   // decimal =263.96      Hz =466.16  laD
//10'h0F9, // decimal =249.14      Hz =493.88  si
//10'h0EB,   // decimal =235.15      Hz =523.25  do   Next OCTAV
//10'h0DD,   // decimal =221.96      Hz =554.36  doD  Next OCTAV 
//10'h0D1,   // decimal =209.50      Hz =587.33  reD  Next OCTAV
//10'h0C5} ;   // decimal =197.74      Hz =622.25  reD  Next OCTAV
//10'h1A2,   // decimal =418.98      Hz =233.08  laD
//10'h18B} ; // decimal =395.46      Hz =246.94  si

//---------------VALUES for 31.5MHz   ocatave   6------------------------





10'h75,   // decimal =117.58      Hz =1046.5  do    31_500_000/256/<FREQ_Hz>
10'h6E,   // decimal =110.98      Hz =1108.73  doD
10'h68,   // decimal =104.75      Hz =1174.66  re
10'h62,   // decimal =98.87       Hz =1244.51  reD
10'h5D,   // decimal =93.32       Hz =1318.51  mi
10'h48,   // decimal =72.51       Hz =1696.91  fa
10'h53,   // decimal =83.14       Hz =1479.98 faD
10'h4E,   // decimal =78.47       Hz =1567.98 sol
10'h4A,   // decimal =74.07       Hz =1661.22 solD
10'h45,   // decimal =69.91       Hz =1760 La
10'h41,   // decimal =65.99       Hz =1864.66  laD
10'h3E,   // decimal =62.29       Hz =1975.53  si
10'h3A,   // decimal =58.79       Hz =2093  do   Next OCTAV - 7
10'h37,   // decimal =55.49       Hz =2217.46  doD  Next OCTAV - 7
10'h34,   // decimal =52.38       Hz =2349.02  reD  Next OCTAV - 7
10'h31} ; // decimal =49.44       Hz =2489.02  reD  Next OCTAV - 7 








assign 	preScaleValue = preScaleValueTable [tone] ; 

endmodule






















































