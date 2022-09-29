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

wire rst, clk;
reg c1hz;
reg[3:0] t0;
reg[11:0] contador;

always @(posedge clk or posedge rst)
begin
  if (rst==1'b1)
	contador <= 12'h000;
  else begin
	contador <= contador + 1;
	if (contador == 12'h1F3) begin
		contador <= 12'h000;
		c1hz <= 1'b1;
	end else
		c1hz <= 1'b0;
  end
end

always @(posedge c1hz or posedge rst)
begin
  if (rst==1'b1)
	t0 <= 4'h0;
  else
	t0 <= t0 + 1;
end

assign clk = CLK_500Hz;
assign rst = ~KEY[0];
assign LEDR[3:0] = t0;

endmodule
