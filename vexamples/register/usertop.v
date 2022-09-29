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

wire rst, en, clk;
reg[3:0] t0;

always @(posedge clk or posedge rst)
begin
  if (rst==1'b1)
	t0 <= 4'b0000;
  else if (en)
	t0 <= SW[3:0];
end

assign clk = CLK_500Hz;
assign en = ~KEY[1];
assign rst = ~KEY[0];
assign LEDR[3:0] = t0;

endmodule
