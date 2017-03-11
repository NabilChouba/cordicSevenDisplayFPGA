
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:44:51 11/19/2009
-- Design Name:   CordicCalculator
-- Module Name:   C:/Xilinx92i/CordicCalculator/testbench.vhd
-- Project Name:  CordicCalculator
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: CordicCalculator
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY testbench_vhd IS
END testbench_vhd;

ARCHITECTURE behavior OF testbench_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT CordicCalculator
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		kbclk : IN std_logic;
		kbdata : IN std_logic;          
		sseg : OUT std_logic_vector(6 downto 0);
		an : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;

	--Inputs
	SIGNAL clk :  std_logic := '0';
	SIGNAL rst :  std_logic := '1';
	SIGNAL kbclk :  std_logic := '0';
	SIGNAL kbdata :  std_logic := '0';

	--Outputs
	SIGNAL sseg :  std_logic_vector(6 downto 0);
	SIGNAL an :  std_logic_vector(3 downto 0);
	
	type ram_type is array (0 to 10) of std_logic_vector( 7 downto 0);

	SIGNAL sendkey :  ram_type;
	
	SIGNAL key :  std_logic_vector(7 downto 0);
	

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: CordicCalculator PORT MAP(
		clk => clk,
		rst => rst,
		kbclk => kbclk,
		kbdata => kbdata,
		sseg => sseg,
		an => an
	);

  rst<='0' AFTER 100 ns;
  clk <= not clk AFTER 50 ns;


	tb : PROCESS
	BEGIN
    
		-- Wait 100 ns for global reset to finish
	  
		
		wait for 100 ns;
		
		--key <= x"05"; -- sin
		--key <= x"06"; -- cos
		--key <= x"74"; --6
		
	sendkey (0) <= x"16";-- '1'	
	sendkey (1) <= x"26";-- '3'
	--sendkey (2) <= x"45";-- '0'
	sendkey (2) <= x"0E";-- '-'
	sendkey (3) <= x"06";-- cos
	
	for j in 0 to 3 loop 
	
                  key <= x"F0"; 
		-- start bit
		  kbdata <= '0' ;
		  kbclk <= '0';
		  wait for 5000 ns;
		  kbclk <= '1';
		  wait for 5000 ns;
	         -- data send 
		for i in 0 to 7 loop
		  kbdata <= key (i) ;
		  kbclk <= '0';
		  wait for 5000 ns;
		  kbclk <= '1';
		  wait for 5000 ns;
		end loop;
		-- parity bit & stop bit
		  kbdata <= '1' ;
		  kbclk <= '0';
		  wait for 5000 ns;
		  kbclk <= '1';
		  wait for 5000 ns;		
		  kbclk <= '0';
		  wait for 5000 ns;
		  kbclk <= '1';
		  wait for 5000 ns;		

		
		 key <= sendkey(j); 
		-- start bit
		  kbdata <= '0' ;
		  kbclk <= '0';
		  wait for 5000 ns;
		  kbclk <= '1';
		  wait for 5000 ns;
		  -- data send 
		for i in 0 to 7 loop
		  kbdata <= key (i) ;
		  kbclk <= '0';
		  wait for 5000 ns;
		  kbclk <= '1';
		  wait for 5000 ns;
	        end loop;
		
		-- parity bit & stop bit
		  kbdata<= '1' ;
		  kbclk <= '0';
		  wait for 5000 ns;
		  kbclk <= '1';
		  wait for 5000 ns;		
		  kbclk <= '0';
		  wait for 5000 ns;
		  kbclk <= '1';
		  wait for 5000 ns;
		  
		  wait for 5000 ns;
		  
	end loop;


		-- Place stimulus here

		wait; -- will wait forever
	END PROCESS;

END;
