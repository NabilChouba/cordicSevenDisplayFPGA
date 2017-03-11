----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:08:09 11/19/2009 
-- Design Name: 
-- Module Name:    CordicCalculator    - RTL 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--  out_x /20
--  disphex /11
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


entity CordicCalculator is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           kbclk : in  STD_LOGIC;
           kbdata : in  STD_LOGIC;
           sseg : out  STD_LOGIC_VECTOR (6 downto 0);
           an : out  STD_LOGIC_VECTOR (3 downto 0));
end CordicCalculator ;

architecture RTL of CordicCalculator is

COMPONENT displayer4x7 
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
end COMPONENT;


COMPONENT CORDIC 
   generic (Wight: integer :=22); -- 16..31  Wight of data in Ballel_Shifter
    port(
        clk        : in std_logic ;               -- System Clock
        rst        : in std_logic ;               -- Reset	
		  soft_rst_cordic: in    std_logic ;           -- Reset the X and Y registers
        in_start    : in std_logic ;              -- convert start				    
        in_x        : in signed(Wight downto 0) ; -- x0 : std_logic_vector(22 downto 0) := "0010011011011101" ; -- 0.607252935
        in_angle    : in signed(Wight downto 0) ; -- -pi/2 <angle<pi/2
        out_running : out std_logic ;             -- Convert end	  
        out_x       : out signed(Wight downto 0);   -- Calculate X sine !
		  out_y       : out signed(Wight downto 0)   -- Calculate Y cos !
    );
end COMPONENT ;

COMPONENT SpecialKey 
    Port ( kbdata : in  STD_LOGIC_VECTOR (7 downto 0);
	        kbdata_dec : out  STD_LOGIC_VECTOR (3 downto 0);
           negativeKey : out  STD_LOGIC;
           sinKey : out  STD_LOGIC;
           cosKey : out  STD_LOGIC);
end COMPONENT;

COMPONENT keyBuffer 
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
end COMPONENT;

COMPONENT keyPS2controller 
    Port ( clk : in  STD_LOGIC;    -- system clock signal 
           rst : in  STD_LOGIC;    -- system reset 
			  ack : in  STD_LOGIC;    -- data is readed (waiting for next char)
           kbdata : in  STD_LOGIC; -- input keyboard data 
           kbclk : in  STD_LOGIC;  -- input keyboard clock 
			  data_ready : out  STD_LOGIC; -- data is ready and stored on the register buffer
			  kbdatarx : out  STD_LOGIC_VECTOR (7 downto 0) --data value : key code : key that is pressed
  );
end COMPONENT;

COMPONENT ctr 
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
end COMPONENT;


   -- CORDIC signal
	SIGNAL cordic_soft_rst :  std_logic;
	SIGNAL cordic_start:  std_logic ;
	SIGNAL cordic_x0   :  signed(22 downto 0) ;
	SIGNAL cordic_angle:  signed(22 downto 0) ;
	SIGNAL cordic_ndone :  std_logic;
	SIGNAL cordic_xout :  signed(22 downto 0);
	SIGNAL cordic_yout :  signed(22 downto 0);		
	-- PS2 KeyBoard
	SIGNAL kb_ack : STD_LOGIC;    
	SIGNAL kb_data_ready : STD_LOGIC; 
	SIGNAL kb_kbdatarx : STD_LOGIC_VECTOR (7 downto 0);
	-- SpecialKey
	SIGNAL spkey_data_dec : STD_LOGIC_VECTOR (3 downto 0);
	SIGNAL spkey_negativeKey : STD_LOGIC;
   SIGNAL spkey_sinKey : STD_LOGIC;
   SIGNAL spkey_cosKey : STD_LOGIC;
   SIGNAL bkey_sign : STD_LOGIC;
   -- keyBuffer
   SIGNAL bkey_shift    : STD_LOGIC;
	SIGNAL sign :   STD_LOGIC;
	SIGNAL bkey_angle_sign :   STD_LOGIC;
	
   SIGNAL bkey_soft_rst : STD_LOGIC;
   SIGNAL bkey_swapcos: STD_LOGIC;
   SIGNAL bkey_angle    : signed (11 downto 0);
   --displayer4x7
   SIGNAL disp_sel_sin    : STD_LOGIC; 
   SIGNAL disp_sel_cos    : STD_LOGIC; 
   SIGNAL disp_sel_angel  : STD_LOGIC; 
   	SIGNAL bus_anglehex    : signed (11 downto 0);
	SIGNAL disp_bus_sin    : signed (11 downto 0);
	SIGNAL disp_bus_cos    : signed (11 downto 0);
	SIGNAL disp_sin_sign    : STD_LOGIC; 
	SIGNAL disp_cos_sign    : STD_LOGIC; 

			  
begin
				
   u_ctr: ctr
   PORT MAP(clk => clk,
            rst => rst,
			  -- cordic control signal
			  cordic_ndone   => cordic_ndone,
			  cordic_start   => cordic_start,
			  cordic_soft_rst=> cordic_soft_rst,
			  -- 7 segment x4 display control signal
			  disp_sin   => disp_sel_sin,
           disp_cos   => disp_sel_cos,
           disp_angel => disp_sel_angel,
			  -- Keyboard PS2 control signal
           kb_ack => kb_ack,
           kb_data_ready =>  kb_data_ready,
			  -- Special Key from keyboard control signal
			  skey_negative => spkey_negativeKey,
           skey_sin => spkey_sinKey,
           skey_cos => spkey_cosKey,
			  -- key buffer 
			  kbuffer_shift => bkey_shift,
			  kbuffer_sign  => bkey_sign,
           kbuffer_soft_rst => bkey_soft_rst
			  );

   disp_bus_cos <= (cordic_xout(20 downto 9)) when bkey_swapcos = '0' else
                   -(cordic_yout(20 downto 9));
		   
   disp_cos_sign <= cordic_xout(22)when bkey_swapcos = '0' else
                   not(cordic_yout(22));

		   
   disp_bus_sin <= (cordic_yout(20 downto 9)) when bkey_swapcos = '0' else
                   (cordic_xout(20 downto 9));
		   
   disp_sin_sign <= cordic_yout(22) when bkey_swapcos = '0' else
                   (cordic_xout(22));





   u_displayer4x7: displayer4x7
   PORT MAP(clk => clk,
            rst => rst,
	    bus_anglehex => bus_anglehex,
            bus_angle => bkey_angle,
            bus_sin =>disp_bus_sin,
            bus_cos => disp_bus_cos,
            angle_sign => bkey_angle_sign,
				sin_sign => disp_sin_sign,
				cos_sign => disp_cos_sign,
            sel_sin => disp_sel_sin,
            sel_cos => disp_sel_cos,
            sel_angel => disp_sel_angel,
            sseg => sseg,
            an =>an);


   u_keyBuffer: keyBuffer
   PORT MAP(clk => clk,
            rst => rst,
            shift => bkey_shift,
            soft_rst => bkey_soft_rst,
	    sign => bkey_sign,
            kbdata_dec => spkey_data_dec,
	    anglehex =>bus_anglehex,
	    angle_sign =>  bkey_angle_sign,
	    swapcos    =>  bkey_swapcos,
            angle => bkey_angle
				);


   u_SpecialKey: SpecialKey 
   PORT MAP(kbdata => kb_kbdatarx,
	         kbdata_dec => spkey_data_dec,
            negativeKey =>spkey_negativeKey,
            sinKey =>spkey_sinKey,
            cosKey =>spkey_cosKey
				);
   --				 sign    
	--           |  .
	     
   cordic_x0<= "00010011001100110011001" ; -- 0.607252935;
	cordic_angle <=  signed(  bkey_angle(7 downto 0)  & "000000000000000" );
	
	--90
	--cordic_angle <=  "00101101000000000000000";
   

	u_CORDIC: CORDIC PORT MAP(
		clk => clk,
		rst => rst,
		soft_rst_cordic => cordic_soft_rst,
		in_start => cordic_start,
		in_x => cordic_x0,
		in_angle => cordic_angle,
		out_running => cordic_ndone,
		out_x => cordic_xout,
		out_y => cordic_yout
	);

  u_keyPS2controller:  keyPS2controller 
  port map( 
	    clk => clk,
       rst => rst,
	    ack => kb_ack,
       kbdata =>kbdata,
       kbclk =>kbclk,
		 data_ready =>kb_data_ready,
		 kbdatarx =>kb_kbdatarx
  );
end RTL;

