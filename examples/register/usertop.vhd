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
signal rst, clk, en: std_logic;
signal t0: std_logic_vector(3 downto 0);

begin

   P1: process(clk,rst,en,SW)
   begin
	if rst = '0' then
	   t0 <= "0000";
	elsif rising_edge(clk) and en='0' then
	   t0 <= SW(3 downto 0);
	end if;
   end process;

clk <= CLK_500Hz;
rst <= KEY(0);
en <= KEY(1);
LEDR(3 downto 0) <= t0;

end rtl;
