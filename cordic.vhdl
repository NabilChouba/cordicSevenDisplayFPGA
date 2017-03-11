library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_arith.all;  
use ieee.std_logic_signed.all; 

------------------------------------------------------------------------
-- entity                                                             --
------------------------------------------------------------------------

-- 1 bit sign
-- 2 bits apres la vergule
-- Wight -3 bits avant la vergule

entity CORDIC is
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
end CORDIC ;

------------------------------------------------------------------------
-- architecture                                                       --
------------------------------------------------------------------------
architecture RTL of CORDIC is

component   ATAN IS
    generic (Wight: integer); -- 16..31  Wight of data in Ballel_Shifter
    PORT (
        RESULT : OUT signed(Wight DOWNTO 0);
        INDEX : IN unsigned(4 DOWNTO 0)
		) ;
END component;

component  Ballel_Shifter  is
    generic (Wight: integer := 22); -- 16..31  Wight of data in Ballel_Shifter
    port(
	N_SHIFT        : in    unsigned(4 downto 0) ;    -- number of shift 
        INPUT_X        : in    signed(Wight downto 0); -- input that will be shifted
        OUTPUT_X       : out   signed(Wight downto 0)  -- output of Ballel_Shifter
    );
END component;

-----------------------------------------------------------
-- Signals                                               --
-----------------------------------------------------------

signal  z_reg       : signed(Wight downto 0) ;   -- Zn Register
signal  z_next      : signed(Wight downto 0) ;   -- Zn Register

signal  y_reg       : signed(Wight downto 0) ;   -- Zn Register
signal  y_next      : signed(Wight downto 0) ;   -- Zn Register

signal  x_reg       : signed(Wight downto 0) ;   -- Zn Register
signal  x_next      : signed(Wight downto 0) ;   -- Zn Register


signal  iteration_reg       : unsigned(4 downto 0)  ;   -- 0 to 22 counter
signal  iteration_next       : unsigned(4 downto 0)  ;   -- 0 to 22 counter

signal  DX          : signed(Wight downto 0) ;   -- Ballel Shift X
signal  DY          : signed(Wight downto 0) ;   -- Ballel Shift Y
signal  tab_z       : signed(Wight downto 0) ;   -- Table Select Z

signal  init_load_reg   : std_logic ;                       -- X,Y,Z Initialize
signal  init_load_next   : std_logic ;                      -- X,Y,Z Initialize

signal  now_convert_reg : std_logic ;                       -- Now Conveting for CORDIC
signal  now_convert_next : std_logic ;                      -- Now Conveting for CORDIC

signal  add_sub     : std_logic ;                       -- Next Calculate '1'=ADD/'0'=SUB
signal  add_sub_Y     : std_logic ;                       -- Next Calculate '1'=ADD/'0'=SUB
signal add_sub_Y_bus  : std_logic ;                       -- Next Calculate '1'=ADD/'0'=SUB


--signal for test
--signal  out_running_q     : std_logic ;
--signal  out_running_tmp     : std_logic ;

--signal  sin_cordic_sgn       : signed(Wight downto 0) ;   -- Table Select Z
--*************************

-----------------------------------------------------------
-- Architectures                                         --
-----------------------------------------------------------
begin
-----------------------------------------------------------
-- ADD/SUB Flag                                          --
-----------------------------------------------------------
SELECT_add_sub : add_sub <=   z_reg(z_reg'high) ;

SELECT_add_sub_Y :add_sub_Y_bus <=  add_sub;

-----------------------------------------------------------
-- Ballel Shifter  X & Y                                 --
-----------------------------------------------------------
BALLEL_X : Ballel_Shifter 
           generic map ( Wight => Wight)
           port map ( N_SHIFT  => iteration_reg,
                      INPUT_X  => x_reg,
					            OUTPUT_X => DX);
BALLEL_Y : Ballel_Shifter 
           generic map ( Wight => Wight)
           port map ( N_SHIFT  => iteration_reg,
                      INPUT_X  => y_reg,
					            OUTPUT_X => DY);
-----------------------------------------------------------
-- ATAN*epsilon lockup dable                             --
-----------------------------------------------------------		
TABLE_ATAN_EPS : ATAN
             generic map ( Wight => Wight)
             port map ( RESULT  => tab_z,
                        INDEX  => iteration_reg);

-----------------------------------------------------------
-- Flag Control                                          --
-----------------------------------------------------------

INIT_FLAG : process( soft_rst_cordic,in_start,init_load_reg, now_convert_reg )
    begin
      init_load_next <= init_load_reg;
      -- Soft Reset 
      if soft_rst_cordic ='1' then
        init_load_next <= '0' ; 
      elsif( in_start='1' and init_load_reg='0' and now_convert_reg='0' ) then         
	      init_load_next <= '1' ;
      else
         init_load_next <= '0' ;
      end if ;
    end process ;
		
CONVERT_FLAG : process(init_load_reg, now_convert_reg, iteration_reg )
    begin
		  now_convert_next <= now_convert_reg;
          if( init_load_reg='1' ) then
              now_convert_next <= '1' ;
          elsif( iteration_reg=  Wight-1 ) then
              now_convert_next <= '0' ;
          end if ;
    end process ;

-----------------------------------------------------------
-- Sequence Counter iteration namber                     --
-----------------------------------------------------------
COUNTER_GEN : process( iteration_reg, now_convert_reg )
    begin
		  iteration_next <= iteration_reg;
      
        if( now_convert_reg='1' ) then
           iteration_next <= iteration_reg + 1 ;
	     else
		     iteration_next <= (others=>'0')  ;
        end if ;
		  
    end process ;


-----------------------------------------------------------
-- Calculate                                             --
-----------------------------------------------------------
CALC_X : process( x_reg, init_load_reg, now_convert_reg, add_sub,x_next,DY,in_x,soft_rst_cordic)
    begin
		
     x_next <= x_reg;
     
       
      -- Soft Reset 
      if soft_rst_cordic ='1' then
        x_next <= (others =>'0') ;
       
          -- Initial Value
       elsif( init_load_reg = '1' ) then
              x_next  <= in_x ; 
			 --get the sine !
       elsif( now_convert_reg='1'  ) then
              if( add_sub='1' ) then
                  x_next <= x_reg + DY ;
              else
                  x_next <= x_reg - DY ;
              end if ;   
      end if ;
    end process ;

CALC_Y : process( init_load_reg, now_convert_reg,add_sub,y_reg,DX,add_sub_Y_bus,soft_rst_cordic)
    begin
      
      y_next <= y_reg;
      
      -- Soft Reset 
      if soft_rst_cordic ='1' then
        y_next <= (others =>'0') ;
 
          -- Initial Value
      elsif( init_load_reg = '1' ) then
              y_next <= (others =>'0') ;
    	  
	       --get the sine !
      elsif( now_convert_reg='1' ) then
	         
               if( add_sub_Y_bus='1' ) then
                  y_next <= y_reg - DX ;
               else
                  y_next <= y_reg + DX ;
               end if ;
	         
      end if ;
      
    end process ;

CALC_Z : process( init_load_reg,in_angle,now_convert_reg,add_sub,z_reg,tab_z)
    begin
      
      z_next <= z_reg ;
      
     
	
	-- Initial Value
        if( init_load_reg = '1' ) then
	  z_next <=  in_angle;
	
	--get the sine !
        elsif( now_convert_reg='1' ) then
          if( add_sub='1' ) then
            z_next <= z_reg + tab_z ;
          else
            z_next <= z_reg - tab_z ;
          end if ;    
        end if ;
    
    end process ;

out_running<=  (now_convert_reg or init_load_reg);
out_y      <= y_reg ; 
out_x      <= x_reg ; 

cloked_process : process( clk, rst )
    begin
        if( rst='1' ) then
          z_reg  <= (others=>'0') ;
			 y_reg  <= (others=>'0') ;
			 x_reg  <= (others=>'0') ;
			 iteration_reg  <= (others=>'0') ;
			 now_convert_reg <='0';
			 init_load_reg <= '0';
        elsif( clk'event and clk='1' ) then
		    z_reg  <= z_next;
			 y_reg  <= y_next;
			 x_reg  <= x_next;
			 iteration_reg <= iteration_next;
			 init_load_reg <= init_load_next;
			 now_convert_reg <= now_convert_next;
	end if;
end process ;


end RTL ;
------------------------------------------------------------------------
-- End of File                                                        --
------------------------------------------------------------------------

