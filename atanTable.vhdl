library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_arith.all;  
use ieee.std_logic_signed.all; 

-- 1 bit sign 
-- (0),(Wight-1 , 0)


ENTITY  ATAN IS
    generic (Wight: integer); -- 16..31  Wight of data in Ballel_Shifter
    PORT (
        RESULT : OUT signed(Wight DOWNTO 0);
        INDEX : IN unsigned(4 DOWNTO 0)
) ;    
END ATAN;


architecture rtl of ATAN is

constant ATAN0 : signed(30 downto 0) := "0010110100000000000000000000100" ;-- eps*atan(1/1)= 45.00000052527620653109 
constant ATAN1 : signed(30 downto 0) := "0001101010010000101001110011011" ;-- eps*atan(1/2)= 26.56505148716664166386 
constant ATAN2 : signed(30 downto 0) := "0000111000001001010001110100001" ;-- eps*atan(1/4)= 14.03624363176880684989 
constant ATAN3 : signed(30 downto 0) := "0000011100100000000000010001001" ;-- eps*atan(1/8)= 7.12501643207072188346 
constant ATAN4 : signed(30 downto 0) := "0000001110010011100010101010011" ;-- eps*atan(1/16)= 3.57633441674320362580 
constant ATAN5 : signed(30 downto 0) := "0000000111001010001101111001010" ;-- eps*atan(1/32)= 1.78991062913934628753 
constant ATAN6 : signed(30 downto 0) := "0000000011100101001010100001101" ;-- eps*atan(1/64)= 0.89517372066026223987 
constant ATAN7 : signed(30 downto 0) := "0000000001110010100101101101011" ;-- eps*atan(1/128)= 0.44761417608546588687 
constant ATAN8 : signed(30 downto 0) := "0000000000111001010010111010010" ;-- eps*atan(1/256)= 0.22381050298103433160 
constant ATAN9 : signed(30 downto 0) := "0000000000011100101001011101100" ;-- eps*atan(1/512)= 0.11190567837246000182 
constant ATAN10 : signed(30 downto 0) := "0000000000001110010100101110110" ;-- eps*atan(1/1024)= 0.05595289254693085190 
constant ATAN11 : signed(30 downto 0) := "0000000000000111001010010111011" ;-- eps*atan(1/2048)= 0.02797645294356734466 
constant ATAN12 : signed(30 downto 0) := "0000000000000011100101001011101" ;-- eps*atan(1/4096)= 0.01398822730554685929 
constant ATAN13 : signed(30 downto 0) := "0000000000000001110010100101110" ;-- eps*atan(1/8192)= 0.00699411375699384146 
constant ATAN14 : signed(30 downto 0) := "0000000000000000111001010010111" ;-- eps*atan(1/16384)= 0.00349705689152447242 
constant ATAN15 : signed(30 downto 0) := "0000000000000000011100101001011" ;-- eps*atan(1/32768)= 0.00174852844739068034 
constant ATAN16 : signed(30 downto 0) := "0000000000000000001110010100101" ;-- eps*atan(1/65536)= 0.00087426422389889566 
constant ATAN17 : signed(30 downto 0) := "0000000000000000000111001010010" ;-- eps*atan(1/131072)= 0.00043713211197489226 
constant ATAN18 : signed(30 downto 0) := "0000000000000000000011100101001" ;-- eps*atan(1/262144)= 0.00021856605599062669 
constant ATAN19 : signed(30 downto 0) := "0000000000000000000001110010100" ;-- eps*atan(1/524288)= 0.00010928302799571091 
constant ATAN20 : signed(30 downto 0) := "0000000000000000000000111001010" ;-- eps*atan(1/1048576)= 0.00005464151399790515 
constant ATAN21 : signed(30 downto 0) := "0000000000000000000000011100101" ;-- eps*atan(1/2097152)= 0.00002732075699895879 
constant ATAN22 : signed(30 downto 0) := "0000000000000000000000001110010" ;-- eps*atan(1/4194304)= 0.00001366037849948017 
constant ATAN23 : signed(30 downto 0) := "0000000000000000000000000111001" ;-- eps*atan(1/8388608)= 0.00000683018924974018 
constant ATAN24 : signed(30 downto 0) := "0000000000000000000000000011100" ;-- eps*atan(1/16777216)= 0.00000341509462487010 
constant ATAN25 : signed(30 downto 0) := "0000000000000000000000000001110" ;-- eps*atan(1/33554432)= 0.00000170754731243505 
constant ATAN26 : signed(30 downto 0) := "0000000000000000000000000000111" ;-- eps*atan(1/67108864)= 0.00000085377365621753 
constant ATAN27 : signed(30 downto 0) := "0000000000000000000000000000011" ;-- eps*atan(1/134217728)= 0.00000042688682810876 
constant ATAN28 : signed(30 downto 0) := "0000000000000000000000000000001" ;-- eps*atan(1/268435456)= 0.00000021344341405438 
constant ATAN29 : signed(30 downto 0) := "X000000000000000000000000000000" ;-- eps*atan(1/536870912)= 0.00000010672170702719 



begin
  p_ltable: process(INDEX)
     
  begin
    case (INDEX) is
       when "00000" => RESULT <=  ATAN0 (30 downto 30-Wight)  ;
       when "00001" => RESULT <=  ATAN1 (30 downto 30-Wight) ;
       when "00010" => RESULT <=  ATAN2 (30 downto 30-Wight) ;
       when "00011" => RESULT <=  ATAN3 (30 downto 30-Wight) ;
       when "00100" => RESULT <=  ATAN4 (30 downto 30-Wight) ;
       when "00101" => RESULT <=  ATAN5 (30 downto 30-Wight) ;
       when "00110" => RESULT <=  ATAN6 (30 downto 30-Wight) ;
       when "00111" => RESULT <=  ATAN7 (30 downto 30-Wight) ;
       when "01000" => RESULT <=  ATAN8 (30 downto 30-Wight) ;
       when "01001" => RESULT <=  ATAN9 (30 downto 30-Wight) ;
       when "01010" => RESULT <=  ATAN10(30 downto 30-Wight) ;
       when "01011" => RESULT <=  ATAN11(30 downto 30-Wight) ;
       when "01100" => RESULT <=  ATAN12(30 downto 30-Wight) ;
       when "01101" => RESULT <=  ATAN13(30 downto 30-Wight) ;
       when "01110" => RESULT <=  ATAN14(30 downto 30-Wight) ;
       when "01111" => RESULT <=  ATAN15(30 downto 30-Wight) ;
       when "10000" => RESULT <=  ATAN16(30 downto 30-Wight) ;
       when "10001" => RESULT <=  ATAN17(30 downto 30-Wight) ;
       when "10010" => RESULT <=  ATAN18(30 downto 30-Wight) ;
       when "10011" => RESULT <=  ATAN19(30 downto 30-Wight) ;
       when "10100" => RESULT <=  ATAN20(30 downto 30-Wight) ;
       when "10101" => RESULT <=  ATAN21(30 downto 30-Wight) ;
       when "10110" => RESULT <=  ATAN22(30 downto 30-Wight) ;
       when "10111" => RESULT <=  ATAN23(30 downto 30-Wight) ;
       when "11000" => RESULT <=  ATAN24(30 downto 30-Wight) ;
       when "11001" => RESULT <=  ATAN25(30 downto 30-Wight) ;
       when "11010" => RESULT <=  ATAN26(30 downto 30-Wight) ;
       when "11011" => RESULT <=  ATAN27(30 downto 30-Wight) ;
       when "11100" => RESULT <=  ATAN29(30 downto 30-Wight) ;
       when others => RESULT <=   (others => '-');
      end case;
  end process;

 end rtl;

