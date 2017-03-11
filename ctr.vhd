----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:33:20 11/19/2009 
-- Design Name: 
-- Module Name:    ctr - RTL 
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

entity ctr is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  -- cordic control signal
			  cordic_ndone   : in  STD_LOGIC;
			  cordic_start   : out  STD_LOGIC;
			  cordic_soft_rst: out  STD_LOGIC;
			  -- 7 segment x4 display control signal
			  disp_sin   : out  STD_LOGIC;
           disp_cos   : out  STD_LOGIC;
           disp_angel : out  STD_LOGIC;
			  -- Keyboard PS2 control signal
           kb_ack : out  STD_LOGIC;
           kb_data_ready : in  STD_LOGIC;
			  -- Special Key from keyboard control signal
			  skey_negative : in  STD_LOGIC;
           skey_sin : in  STD_LOGIC;
           skey_cos : in  STD_LOGIC;
			  -- key buffer 
			  kbuffer_shift    : out  STD_LOGIC;
			  kbuffer_sign    : out  STD_LOGIC;
           kbuffer_soft_rst : out  STD_LOGIC
			  );
end ctr;

architecture RTL of ctr is
 -- FSM States
   type state_type is (idle, wait_ky_pressed,detected_sin,detected_cos,detected_negative,detected_number,wait_cordic_sin,wait_cordic_cos ,show_sin,show_cos);
  -- FSM registers
  signal state_reg : state_type;
  signal state_next: state_type;

begin

cloked_process : process( clk, rst )
    begin
      if( rst='1' ) then
          state_reg  <= idle ;
		elsif( clk'event and clk='1' ) then
		    state_reg  <= state_next;
	   end if;
end process ;


  combinatory_FSM_next : process(state_reg,kb_data_ready,skey_negative,skey_sin,skey_cos,cordic_ndone)
  begin
    state_next<= state_reg;
    case state_reg is
    when idle =>
        state_next <= wait_ky_pressed;

    --wait for key to be pressed   
    when wait_ky_pressed =>
      if kb_data_ready = '1' then
		  if skey_negative = '1' then
		    state_next <= detected_negative;
		  elsif skey_sin = '1' then
		    state_next <= detected_sin;
		  elsif skey_cos = '1' then
		    state_next <= detected_cos;
        else		  
         state_next <= detected_number;
		  end if;
      end if;

	 when  detected_number =>
	    state_next <= wait_ky_pressed;
	 		
    when  detected_negative =>
	    state_next <= wait_ky_pressed;
	 
	 when  detected_sin =>
	   state_next <= wait_cordic_sin;
	 
	 when  detected_cos =>
	   state_next <= wait_cordic_cos;
	 
	 when  wait_cordic_sin =>
	   if cordic_ndone = '0' then
		  state_next <= show_sin;
		end if;
		
	 when  wait_cordic_cos =>
	   if cordic_ndone = '0' then
		  state_next <= show_cos;
		end if;
		
	 when  show_sin =>
	   if kb_data_ready = '1' then
		  state_next <= idle;
		end if;
		
	 when  show_cos =>
	   if kb_data_ready = '1' then
		  state_next <= idle;
		end if;	 

    when others =>

    end case;
  end process;


  combinatory_output_processing : process(state_reg)
  begin
    -- cordic control signal
	 cordic_start   <= '0';
	 cordic_soft_rst<= '0';
	 -- 7 segment x4 display control signal
	 disp_sin   <= '0';
	 disp_cos   <= '0';
	 disp_angel <= '0';
	 -- Keyboard PS2 control signal
	 kb_ack <= '0';
	-- key buffer 
	kbuffer_shift    <= '0';
   kbuffer_soft_rst <= '0';
	kbuffer_sign <= '0';

    case state_reg is
    when idle =>
	   cordic_soft_rst  <= '1';
		kbuffer_soft_rst <= '1';
    
    when wait_ky_pressed =>
      disp_angel <= '1';
		
	 when  detected_number =>
	 	disp_angel <= '1';
      kb_ack <= '1';	
      kbuffer_shift <= '1';		
		
    when  detected_negative =>
	 	disp_angel <= '1';
      kb_ack <= '1';	
      kbuffer_sign <= '1';
		
	 when  detected_sin =>
	   cordic_start   <= '1';
		kb_ack <= '1';
	 
	 when  detected_cos =>
	   cordic_start   <= '1';
		kb_ack <= '1';	
	 
	 when  wait_cordic_sin =>
	 	
	 when  wait_cordic_cos =>
	 	
	 when  show_sin =>
	   disp_sin   <= '1';
	 	
	 when  show_cos =>
	   disp_cos   <= '1';
	 
    when others =>

    end case;
  end process;


end RTL;

