library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_arith.all;  
use ieee.std_logic_signed.all; 

entity  Ballel_Shifter  is
    generic (Wight: integer := 22); -- 16..31  Wight of data in Ballel_Shifter
    port(
				N_SHIFT        : in    unsigned(4 downto 0) ;    -- number of shift 
        INPUT_X        : in    signed(Wight downto 0); -- input that will be shifted
        OUTPUT_X       : out   signed(Wight downto 0)  -- output of Ballel_Shifter
    );
end Ballel_Shifter ;

------------------------------------------------------------------------
-- architecture                                                       --
------------------------------------------------------------------------
architecture RTL of Ballel_Shifter is

signal  STEP0_X          : signed(Wight downto 0) ;   -- Ballel Shift X
signal  STEP1_X          : signed(Wight downto 0) ;   -- Ballel Shift X
signal  STEP2_X          : signed(Wight downto 0) ;   -- Ballel Shift X
signal  STEP3_X          : signed(Wight downto 0) ;   -- Ballel Shift X

-----------------------------------------------------------
-- Architectures                                         --
-----------------------------------------------------------
begin
-----------------------------------------------------------
-- Ballel Shifter                                        --
-----------------------------------------------------------
BALLEL_STEP0_X : process( INPUT_X, N_SHIFT )
    begin
        if( N_SHIFT(4)='1' ) then
            STEP0_X <= INPUT_X(Wight) & INPUT_X(Wight) & INPUT_X(Wight) & INPUT_X(Wight) & INPUT_X(Wight) & INPUT_X(Wight) & INPUT_X(Wight) & INPUT_X(Wight) &INPUT_X(Wight) & INPUT_X(Wight) & INPUT_X(Wight) & INPUT_X(Wight) & INPUT_X(Wight) & INPUT_X(Wight) & INPUT_X(Wight) & INPUT_X(Wight) & INPUT_X(Wight downto 16);
        else
            STEP0_X <= INPUT_X ;
        end if ;
    end process ;
		
BALLEL_STEP1_X : process( N_SHIFT, STEP0_X )
    begin
        if( N_SHIFT(3)='1' ) then
            STEP1_X <= STEP0_X(Wight) & STEP0_X(Wight) & STEP0_X(Wight) & STEP0_X(Wight) & STEP0_X(Wight) & STEP0_X(Wight) & STEP0_X(Wight) & STEP0_X(Wight) & STEP0_X(Wight downto 8);
        else
            STEP1_X <= STEP0_X ;
        end if ;
    end process ;
		
BALLEL_STEP2_X : process( STEP1_X, N_SHIFT )
    begin
        if( N_SHIFT(2)='1' ) then
            STEP2_X <= STEP1_X(Wight) & STEP1_X(Wight) & STEP1_X(Wight) & STEP1_X(Wight) & STEP1_X(Wight downto 4);
        else
            STEP2_X <= STEP1_X ;
        end if ;
    end process ;
		
BALLEL_STEP3_X : process( STEP2_X, N_SHIFT )
    begin
        if( N_SHIFT(1)='1' ) then
            STEP3_X <= STEP2_X(Wight) & STEP2_X(Wight) & STEP2_X(Wight downto 2);
        else
            STEP3_X <= STEP2_X ;
        end if ;
    end process ;
		
BALLEL_OUTPUT_X : process( STEP3_X, N_SHIFT )
    begin
        if( N_SHIFT(0)='1' ) then
            OUTPUT_X <= STEP3_X(Wight) & STEP3_X(Wight downto 1);
        else
            OUTPUT_X <= STEP3_X ;
        end if ;
    end process ;

end RTL ;
------------------------------------------------------------------------
-- End of File                                                        --
------------------------------------------------------------------------

