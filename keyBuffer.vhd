----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:48:04 11/19/2009 
-- Design Name: 
-- Module Name:    keyBuffer - RTL 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity keyBuffer is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           shift : in  STD_LOGIC;
           soft_rst : in  STD_LOGIC;
			  sign : in  STD_LOGIC;
           kbdata_dec : in  STD_LOGIC_VECTOR (3 downto 0);			 
	   angle_sign    : out  STD_LOGIC;
	   swapcos    : out  STD_LOGIC;
           angle : out signed (11 downto 0);
	   anglehex : out signed (11 downto 0)
	   );
end keyBuffer;

architecture RTL of keyBuffer is


signal b10  : unsigned (7 downto 0);
signal a10  : unsigned (3 downto 0);
signal b100 : unsigned (11 downto 0);
signal a100 : unsigned (3 downto 0);

signal f1,f2  : unsigned (11 downto 0);
signal angle180  : unsigned (11 downto 0);
signal angle90  : unsigned (11 downto 0);


signal d10  : unsigned (3 downto 0):="1010";
signal d100  : unsigned (7 downto 0):="01100100";



signal angle_reg  : unsigned (11 downto 0);
signal angle_next : unsigned (11 downto 0);
signal sign_reg : STD_LOGIC;
signal sign_next: STD_LOGIC;
begin

sign_next   <= '0' when soft_rst = '1' else
               '1' when sign     = '1' else
               sign_reg;

angle_next <= (others=>'0')  when soft_rst = '1' else
              unsigned(STD_LOGIC_VECTOR(angle_reg(7 downto 0)) & kbdata_dec) when shift = '1' else
              angle_reg;
angle_sign <= sign_reg;
cloked_process : process( clk, rst )
    begin
      if( rst='1' ) then
          angle_reg  <= (others=>'0') ;
			 sign_reg   <= '0' ;
		elsif( clk'event and clk='1' ) then
		    angle_reg  <= angle_next;
			 sign_reg   <= sign_next;
	   end if;
end process ;
--work well with hex 
--angle <=   angle_reg  when sign_reg = '0' else
--        (- angle_reg);

-- 8 BITS <= 4BIT X 4BITS
a10 <=  angle_reg(7 downto 4) ;
b10 <=  d10  *  a10; -- 8bits

-- 16 BITS = 8BITS * 8BIST
a100 <= angle_reg( 11 downto 8);
b100 <=  d100  * a100;  --4 bit + 8 bit = 12bit


f1 <=  unsigned( "00000000" & STD_LOGIC_VECTOR(angle_reg( 3 downto 0))) ;
f2 <=  unsigned( "0000" & STD_LOGIC_VECTOR(b10));


angle180 <=  (f1+ f2 + b100);
angle90 <= angle180 - 90 when angle180 >= 90  else
	   angle180;
      
swapcos <= '1' when angle180 >= 90  else
	   '0';
	   
angle <= signed(angle90(11 downto 0)) when sign_reg = '0' else
         -signed(angle90(11 downto 0)) ;
	 
anglehex <= signed(angle_reg);

end RTL;

