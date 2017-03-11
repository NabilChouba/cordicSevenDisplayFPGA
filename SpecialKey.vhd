----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:39:15 11/19/2009 
-- Design Name: 
-- Module Name:    SpecialKey - RTL 
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



entity SpecialKey is
    Port ( kbdata : in  STD_LOGIC_VECTOR (7 downto 0);
	        kbdata_dec : out  STD_LOGIC_VECTOR (3 downto 0);
           negativeKey : out  STD_LOGIC;
           sinKey : out  STD_LOGIC;
           cosKey : out  STD_LOGIC);
end SpecialKey;

architecture RTL of SpecialKey is

begin
 -- key '-'
 negativeKey <= '1' when kbdata = x"0E" else 
                '0';
 -- key 'F1' is the sin key
 sinKey <= '1' when kbdata = x"05" else
                '0';
 -- key 'F2' is the cos key
 cosKey <= '1' when kbdata = x"06" else
                '0';
p_ltable: process(kbdata)
     
  begin
    case (kbdata) is
       when x"45"   => kbdata_dec <=  "0000"  ; -- KEY 0
		 when x"16"   => kbdata_dec <=  "0001"  ; -- KEY 1
		 when x"1E"   => kbdata_dec <=  "0010"  ; -- KEY 2
		 when x"26"   => kbdata_dec <=  "0011"  ; -- KEY 3
		 when x"25"   => kbdata_dec <=  "0100"  ; -- KEY 4
		 when x"2E"   => kbdata_dec <=  "0101"  ; -- KEY 5
		 when x"36"   => kbdata_dec <=  "0110"  ; -- KEY 6
		 when x"3D"   => kbdata_dec <=  "0111"  ; -- KEY 7
		 when x"3E"   => kbdata_dec <=  "1000"  ; -- KEY 8
		 when x"46"   => kbdata_dec <=  "1001"  ; -- KEY 9
       when others  => kbdata_dec <=   (others => '-');
     end case;
  end process;     
  
end RTL;

