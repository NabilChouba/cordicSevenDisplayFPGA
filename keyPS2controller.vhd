----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:17:02 11/15/2009 
-- Design Name: 
-- Module Name:    keyPS2controller - Behavioral 
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


entity keyPS2controller is
    Port ( clk : in  STD_LOGIC;    -- system clock signal 
           rst : in  STD_LOGIC;    -- system reset 
			  ack : in  STD_LOGIC;    -- data is readed (waiting for next char)
           kbdata : in  STD_LOGIC; -- input keyboard data 
           kbclk : in  STD_LOGIC;  -- input keyboard clock 
			  data_ready : out  STD_LOGIC; -- data is ready and stored on the register buffer
			  kbdatarx : out  STD_LOGIC_VECTOR (7 downto 0) --data value : key code : key that is pressed
  );
end keyPS2controller;

architecture RTL of keyPS2controller is

  -- pulse signal when keyboard clock is rising
  signal bautrate : std_logic ; 
  -- same as kbdata
  signal rx : std_logic ; 
  
  -- shift data signal 
  signal save_data : std_logic ;
  signal run_shift  : std_logic ;
  signal data_shift_reg,data_shift_next : std_logic_vector(7 downto 0);
  signal data_save_reg, data_save_next : std_logic_vector(15 downto 0);
  
  -- clock keyboard filter : noise filter
  signal filter_reg, filter_next : std_logic_vector(7 downto 0);
  
  -- clock keyboard register to detect the rising event 
  signal kbclk_reg, kbclk_next : std_logic ; 

  -- FSM States
   type state_type is (idle,b_start,b_0,b_1,b_2,b_3,b_4,b_5,b_6,b_7,b_parity,b_stop);
  -- FSM registers
  signal state_reg : state_type;
  signal state_next: state_type;

  
begin
  -- rx is the same as kbdata
  rx <= kbdata;
  
  -- clock keyboard filter : noise filter
  filter_next <= kbclk & filter_reg (7 downto 1);
  kbclk_next <= '1' when filter_reg = "11111111" else
                '0' when filter_reg = "00000000" else
				    kbclk_reg;

  -- pulse signal when keyboard clock is rising
  bautrate <= '1' when kbclk_reg  = '0' and  kbclk_next  = '1'  else
              '0';
				  
  -- register declaration
  cloked_process : process( clk, rst )
  begin
    if( rst='1' ) then
      state_reg <=  idle ;
      data_shift_reg <= (others =>'0') ;
      data_save_reg <= (others =>'0') ;
		filter_reg <= (others =>'0') ;
		kbclk_reg <= '0';
    elsif( clk'event and clk='1' ) then
      state_reg<= state_next ;
      data_shift_reg <= data_shift_next;		
      data_save_reg <= data_save_next ;
		filter_reg <= filter_next;
		kbclk_reg <= kbclk_next;
    end if;
  end process ;

-- shift operation
comb_shift:process(data_shift_reg,run_shift,rx)
begin
    data_shift_next<= data_shift_reg;
    if run_shift ='1'  then
      data_shift_next <= rx & data_shift_reg(7 downto 1);
    end if;
end process;

-- save shift value or clear when ack is resived 
data_save_next <= (others =>'0') when ack = '1' else
                  data_save_reg(7 downto 0) & data_shift_reg when save_data = '1' else
                  data_save_reg;
						
-- resived data : key pressed
kbdatarx   <= data_save_reg(7 downto 0);

-- data is ready to be used
data_ready <= '1' when data_save_reg(15 downto 8) = x"F0" else
              '0';
				  
-- parity signal generation
-- parity<=data_shift_reg(0)xor data_shift_reg(1)xor data_shift_reg(2)xor data_shift_reg(3)xor data_shift_reg(4)xor data_shift_reg(5)xor data_shift_reg(6)xor data_shift_reg(7);


  --next state processing state machine
  combinatory_FSM_next : process(state_reg,bautrate,rx)
  begin
    state_next<= state_reg;
    save_data <= '0';
    run_shift <='0';
	  
    case state_reg is
    when idle =>
      if rx = '0' then
        state_next <= b_start;  
      end if;

    when b_start =>
      if bautrate = '1' then
        state_next <= b_0;
      end if;

    when b_0 =>
      if bautrate  = '1' then
        state_next <= b_1;
        run_shift <='1';
      end if;

    when b_1 =>
      if bautrate  = '1' then
        state_next <= b_2;
        run_shift <='1';
      end if;

    when b_2 =>     
      if bautrate  = '1' then
        state_next <= b_3;
        run_shift <='1';
      end if;

    when b_3 =>
      if bautrate  = '1' then
        state_next <= b_4;
        run_shift <='1';
      end if;

    when b_4 =>
      if bautrate  = '1' then
        state_next <= b_5;
        run_shift <='1';
      end if;

    when b_5 =>
      if bautrate  = '1' then
        state_next <= b_6;
        run_shift <='1';
      end if;

    when b_6 =>
      if bautrate  = '1' then
        state_next <= b_7;
        run_shift <='1';
      end if;

    when b_7 =>
      if bautrate  = '1' then
        state_next <= b_parity;
        run_shift <='1';
      end if;

    when b_parity =>
      if bautrate = '1' then
        state_next <= b_stop;
      end if;

    when b_stop =>
      if bautrate = '1' then
        state_next <= idle;
        save_data <= '1';
        
      end if;		
		
    when others =>
    end case;
  end process;


end RTL;

