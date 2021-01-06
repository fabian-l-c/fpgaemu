-- fpgatest.vhd -  GHDL testbench for fpga board emulator
-- Author: Fabian L. Cabrera

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library work;
use work.fpgaemu.all;

entity fpgatest is
end fpgatest;

architecture archtest of fpgatest is
signal ckbyte: unsigned(31 downto 0) := x"00000000";
signal inbytes: std_logic_vector(31 downto 0) := x"00000000";
signal part1: bit_vector(7 downto 0) := x"FF";
signal part0: bit_vector(23 downto 0) := x"000000";
signal outbytes0,outbytes1,outbytes2: bit_vector(31 downto 0) := x"00000000";
signal CLOCK_50:       std_logic := '0';
signal CLK_500Hz:      std_logic := '0';
signal endsim:	       std_logic := '0';
signal RKEY:           std_logic_vector(3 downto 0) := "1111";
signal KEY:            std_logic_vector(3 downto 0) := "1111";
signal RSW:            std_logic_vector(17 downto 0) := "000000000000000000";
signal SW:             std_logic_vector(17 downto 0):= "000000000000000000";
signal LEDR:           std_logic_vector(17 downto 0):= "000000000000000000" ;
signal HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7 : std_logic_vector(6 downto 0) := "1111111";

component usertop is port (
        CLOCK_50:       in std_logic;
        CLK_500Hz:      in std_logic;
        RKEY:           in std_logic_vector(3 downto 0);
        KEY:            in std_logic_vector(3 downto 0);
        RSW:            in std_logic_vector(17 downto 0);
        SW:             in std_logic_vector(17 downto 0);
        LEDR:           out std_logic_vector(17 downto 0);
        HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7 : out std_logic_vector(6 downto 0)
        );
end component;


begin

   process
   begin
	wait for 250 ns;
	ckbyte <= to_unsigned(vhdlck(0),32);
	CLK_500Hz <= ckbyte(0);
	endsim <= ckbyte(1);
	vhdlout(0) := to_integer(signed(to_stdlogicvector(outbytes0)));
	vhdlout(1) := to_integer(signed(to_stdlogicvector(outbytes1)));
	vhdlout(2) := to_integer(signed(to_stdlogicvector(outbytes2)));
	inbytes <= std_logic_vector(to_unsigned(vhdlin(0),32));
	assert (endsim = '0') report "SUCCESFUL EMULATION!!" severity failure;
   end process;

   CLOCK_50 <= '0';
   RSW <= inbytes(17 downto 0); 
   SW <= inbytes(17 downto 0); 
   RKEY <= inbytes(23 downto 20); 
   KEY <= inbytes(23 downto 20);
   part1 <= to_bitvector('0' & HEX7,'1');
   part0 <= to_bitvector("000000" & LEDR,'0');
   outbytes0 <= part1 & part0;
   outbytes1 <= to_bitvector('0' & HEX3 & '0' & HEX4 & '0' & HEX5 & '0' & HEX6,'1');
   outbytes2 <= to_bitvector(x"00" & '0' & HEX0 & '0' & HEX1 & '0' & HEX2,'1');

   udut : usertop
   port map(CLOCK_50, CLK_500Hz, RKEY, KEY, RSW, SW, LEDR,
	HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7);

end archtest;
