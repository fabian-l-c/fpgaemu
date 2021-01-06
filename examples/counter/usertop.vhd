library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity usertop is
port(
	CLOCK_50:	in std_logic;
	CLK_500Hz:	in std_logic;
	RKEY:		in std_logic_vector(3 downto 0);
	KEY:		in std_logic_vector(3 downto 0);
	RSW:		in std_logic_vector(17 downto 0);
	SW:		in std_logic_vector(17 downto 0);
	LEDR:		out std_logic_vector(17 downto 0);
	HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7	: out std_logic_vector(6 downto 0)
	);
end usertop;

architecture rtl of usertop is
signal rst, clk, c1hz: std_logic;
signal t0: std_logic_vector(3 downto 0);
signal contador: std_logic_vector(11 downto 0);

begin

   P1: process(clk, rst, contador)
   begin
	if rst = '0' then
	   contador <= x"000";
	elsif clk'event and clk= '1' then
	   contador <= contador + 1;
	   if contador = x"1F3" then
		contador <= x"000";
		c1hz <= '1';
	   else
		c1hz <= '0';
	   end if;
	end if;
   end process;

   P2: process(c1hz,rst,t0)
   begin
	if rst = '0' then
	   t0 <= "0000";
	elsif rising_edge(c1hz) then
	   t0 <= t0 + 1;
	end if;
   end process;

clk <= CLK_500Hz;
rst <= KEY(0);
LEDR(3 downto 0) <= t0;

end rtl;
