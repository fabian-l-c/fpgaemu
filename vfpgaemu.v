module main;


reg[30:0] ckbyte, inbytes;
reg[30:0] ckcopy,inbytescopy;
wire[30:0] outbytes0, outbytes1, outbytes2;
wire CLOCK_50, CLK_500Hz;
wire[3:0] RKEY, KEY;
wire[17:0] RSW, SW, LEDR;
wire[7:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;


initial
begin
assign ckbyte = 31'h00000000;
assign inbytes = 31'h00f00000;
$vinp(ckbyte,inbytes);
end

always
begin
	#250;
	ckcopy <= ckbyte;
	inbytescopy <= inbytes;
	$voutp(outbytes0,outbytes1,outbytes2);
	if (ckbyte[1]) #1000000 $finish;
end

assign  CLK_500Hz = ckcopy[0];
assign  CLOCK_50 = 1'b0;
assign  RSW = inbytescopy[17:0]; 
assign  SW = inbytescopy[17:0]; 
assign  RKEY = inbytescopy[23:20]; 
assign  KEY = inbytescopy[23:20];
assign  outbytes0 = {HEX7,6'b000000,LEDR};
assign  outbytes1 = {3'b000,HEX3,HEX4,HEX5,HEX6};
assign  outbytes2 = {8'h00,2'b00,HEX0,HEX1,HEX2};

usertop udut (CLOCK_50, CLK_500Hz, RKEY, KEY, RSW, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);


endmodule
