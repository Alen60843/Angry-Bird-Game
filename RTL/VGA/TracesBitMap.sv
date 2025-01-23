module TracesBitMap (
    input logic clk,
    input logic resetN,
    input logic [10:0] offsetX1, // First trace for bird 1
    input logic [10:0] offsetY1,
    
    input logic [10:0] offsetX2, // First trace for bird 2
    input logic [10:0] offsetY2,
    
    
    
    input logic InsideRectangle1, // Indicates if the pixel is within the rectangle for bird 1
    input logic InsideRectangle2, // Indicates if the pixel is within the rectangle for bird 2
    
    input logic trace1,
    input logic trace2,
    output logic drawingRequest,  // Output indicating the pixel should be displayed
    output logic [7:0] RGBout     // RGB value from the bitmap
);

localparam int OBJECT_HEIGHT_Y = 16; // Bitmap height
localparam int OBJECT_WIDTH_X = 16;  // Bitmap width
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hff; // Transparent pixel RGB value

// Object colors (16x16 bitmap)
logic[0:31][0:31][7:0] object_colors = {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hbe,8'hbe,8'hbe,8'hba,8'hb9,8'hba,8'hbe,8'hff,8'hff,8'hff,8'hff,8'hde,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hff,8'hff,8'hff,8'hff,8'hde,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hff},
	{8'hff,8'hbe,8'hbe,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hbe,8'hbe,8'hff,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hff,8'hbe,8'hbe,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hbe,8'hbe,8'hff},
	{8'hff,8'hff,8'hbe,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'h9d,8'hbe,8'hbe,8'h79,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hf2,8'hf1,8'hf1,8'hf1,8'hf1,8'hda,8'hbe,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hbe,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hbe,8'hbe,8'h20,8'h20,8'hfa,8'hbe,8'hbe,8'hbe,8'hbe,8'hfa,8'h20,8'h20,8'hbe,8'hbe,8'hf1,8'hf1,8'hf1,8'hf2,8'hf2,8'hbe,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hbe,8'hbe,8'hf1,8'hf1,8'hf1,8'hf1,8'hbe,8'hbe,8'h20,8'h20,8'h20,8'h20,8'hbe,8'hbe,8'h20,8'h20,8'h20,8'h20,8'hbe,8'hba,8'hf2,8'hf1,8'hf2,8'hf2,8'hbe,8'hbe,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hbe,8'hbe,8'hf1,8'hf1,8'hf1,8'hba,8'hb9,8'h20,8'h20,8'h20,8'hbe,8'h20,8'h20,8'hbe,8'h20,8'h20,8'h20,8'hbe,8'hbe,8'hf2,8'hf2,8'hf2,8'hbe,8'hbe,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hbe,8'hbe,8'hde,8'hbe,8'hba,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hba,8'hbe,8'hde,8'hde,8'hbe,8'hbe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hd9,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hd5,8'hd5,8'hf5,8'hd5,8'hde,8'hbe,8'hbe,8'hbe,8'hbe,8'hbe,8'hd5,8'hf5,8'hf5,8'hf5,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hd5,8'hd5,8'hd5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf9,8'hb0,8'hf5,8'hf5,8'hf5,8'hfa,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hd5,8'hd5,8'hd5,8'hd5,8'hf5,8'hf5,8'hd5,8'hf5,8'hd5,8'hd5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hac,8'hd5,8'hd5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hb0,8'h00,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hff,8'h00,8'hac,8'hbe,8'hbe,8'hbe,8'hb1,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hf5,8'hb5,8'hbe,8'hbe,8'h99,8'h64,8'h24,8'hff,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hda,8'hda,8'hda,8'hbe,8'hbe,8'hbe,8'h9a,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h79,8'h79,8'h9e,8'hbe,8'hda,8'hda,8'hda,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hda,8'hb6,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hfb,8'hfe,8'hfe,8'hfe,8'hda,8'hfa,8'hda,8'hda,8'hda,8'hb6,8'hb6,8'hda,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hfa,8'hfa,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hda,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hda,8'hfa,8'hfa,8'hfa,8'hfa,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hda,8'hda,8'hda,8'hda,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hda,8'hda,8'hda,8'hfa,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hda,8'hda,8'hda,8'hda,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hda,8'hda,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hda,8'hda,8'hda,8'hda,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hda,8'hda,8'hda,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hda,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hda,8'hda,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hda,8'hda,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hfa,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}};
	


// RGB Output and Pixel Drawing Logic
always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
        RGBout <= TRANSPARENT_ENCODING;
    end else begin
        RGBout <= TRANSPARENT_ENCODING; // Default transparent
        
        if (trace1 && InsideRectangle1) 
            RGBout <= object_colors[offsetY1][offsetX1];    
                
        else if (trace2 && InsideRectangle2) 
            RGBout <= object_colors[offsetY2][offsetX2];
                
        
    end
end

// Drawing Request Signal
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING);

endmodule
