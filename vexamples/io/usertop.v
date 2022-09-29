module usertop (
	input CLOCK_50,
	input CLK_500Hz,
	input[3:0] RKEY,
	input[3:0] KEY,
	input[17:0] RSW,
	input[17:0] SW,
	output[17:0] LEDR,
	output[7:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7
	);

assign LEDR = SW;
assign HEX7 = 7'b1111111;
assign HEX6 = 7'b1111111;
assign HEX5 = 7'b1111111;
assign HEX4 = 7'b1111111;
assign HEX3 = 7'b0010010;
assign HEX2 = 7'b1111001;
assign HEX1 = 7'b1000000;
assign HEX0 = 7'b0010010;

endmodule
