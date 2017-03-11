----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:17:38 11/19/2009 
-- Design Name: 
-- Module Name:    displayer4x7 - RTL 
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity displayer4x7 is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
	   bus_anglehex : in signed (11 downto 0);
           bus_angle : in signed (11 downto 0);
           bus_sin   : in signed (11 downto 0);
           bus_cos   : in signed (11 downto 0);
           angle_sign : in  STD_LOGIC;
			  sin_sign : in  STD_LOGIC;
			  cos_sign : in  STD_LOGIC;
           sel_sin : in  STD_LOGIC;
           sel_cos : in  STD_LOGIC;
           sel_angel : in  STD_LOGIC;
           sseg : out  STD_LOGIC_VECTOR (6 downto 0);
           an : out  STD_LOGIC_VECTOR (3 downto 0));
end displayer4x7;

architecture RTL of displayer4x7 is
signal hex_led : STD_LOGIC_VECTOR (3 downto 0);
signal hex_display : signed (11 downto 0);
signal count_reg,count_next : STD_LOGIC_VECTOR (9 downto 0);
signal sign : STD_LOGIC;
begin

hex_display <= bus_anglehex when sel_angel = '1' else
               bus_sin   when sel_sin = '1' and sin_sign ='0' else
	       -bus_sin   when sel_sin = '1' and sin_sign ='1' else
	       bus_cos   when sel_cos = '1' and cos_sign = '0' else
	       -bus_cos   when sel_cos = '1' and cos_sign = '1' else
			      (others=>'0') ;

sign <=  angle_sign when sel_angel = '1' else
			sin_sign when sel_sin = '1' else
			cos_sign  when sel_cos = '1' else
			'0';
          
cloked_process : process( clk, rst )
    begin
      if( rst='1' ) then
          count_reg  <= (others=>'0') ;
			   elsif( clk'event and clk='1' ) then
		    count_reg  <= count_next;
	   end if;
end process ;

count_next <= count_reg +1;
		  
  process( count_reg, hex_display ) 
    begin
	
    hex_led <= (others=>'0') ;
    an <= "0000"; 
    case count_reg(8 downto 7) is
      when "00" =>
        hex_led<=STD_LOGIC_VECTOR(hex_display(3 downto 0));
        an <= "1110";
      when "01" =>
        hex_led <=STD_LOGIC_VECTOR(hex_display(7 downto 4));
        an <= "1101"; 
      when "10" =>
        hex_led <=STD_LOGIC_VECTOR(hex_display(11 downto 8));
        an <= "1011"; 
      when "11" =>
        hex_led <="----";
        an <= "0111"; 
      when others =>

    end case;
	 
  end process;

  
	 --Seven segment decoder
sseg <= "0111111" when sign = '1' and count_reg(8 downto 7)= "11" else
        "1111111" when sign = '0' and count_reg(8 downto 7)= "11" else
        "1000000" when hex_led = "0000" else
		  "1111001" when hex_led = "0001" else
		  "0100100" when hex_led = "0010" else
		  "0110000" when hex_led = "0011" else
		  "0011001" when hex_led = "0100" else
		  "0010010" when hex_led = "0101" else
		  "0000010" when hex_led = "0110" else
		  "1111000" when hex_led = "0111" else
		  "0000000" when hex_led = "1000" else
		  "0010000" when hex_led = "1001" else
		  "0001000" when hex_led = "1010" else
		  "0000011" when hex_led = "1011" else
		  "1000110" when hex_led = "1100" else
		  "0100001" when hex_led = "1101" else
		  "0000110" when hex_led = "1110" else
		  "0001110" when hex_led = "1111" else
		  "1111111";
  
end RTL;

