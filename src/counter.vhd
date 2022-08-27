----------------------------------------------------------------------------------
--Amjad Alsati  ID: 8205891
-- Email : amjad.alsati.92@gmail.com
-- AW: StepStone Bewerbung - ID: 8205891 - Amjad Alsati - Junior FPGA-Entwickler (m/w/d)
--solution: I impelemented 3 counters. The first counter is the 32-bit counter which counts from 1 to 4x10^9 then restart counting from 1.
--          The second counter is a 2-bit counter which counts from 1 to 3 and then goes back to 1. whenever this counter is at value 3, an output value called multiple_three goes high indicating that the 32-bit counter is multiple of 3.
--          The third counter is a 3-bit counter which counts from 1 to 5 and then goes back to 1. whenever this counter is at value 5, an output value called multiple_five goes high indicating that the 32-bit counter is multiple of 5.
--          If multiple_three and multiple_five are both high, then the 32-bit counter is multiple of fifteen. The output signal multiple_fifteen should be set to l for every time the 32-bit counter is NOT multiple of 15. 
--          i.e multiple_fifteen = NOT (multiple_three AND multiple_five)
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity counter_vhd is
    Port ( CLK : in STD_LOGIC;
           Reset: in STD_LOGIC;
           load : in std_logic;
           load_data : in std_logic_vector(31 downto 0);
           output : out STD_LOGIC_VECTOR (31 downto 0); -- 32-bit counter
           multiple_three: out STD_lOGIC;-- output value that goes to logic high when output is multiple of 3
           multiple_five: out STD_LOGIC; -- output value that goes to logic high when output is multiple of 5
           multiple_fifteen: out STD_LOGIC); -- output value that goes to logic high when output value is NOT multiple of 15
end counter_vhd;

architecture Behavioral of counter_vhd is
    signal count   : unsigned(31 downto 0) := X"00000001"; -- wire signal connected to output (32-bit counter)
    signal count_2_bit: unsigned (1 downto 0) := B"00"; -- two-bit counter
    signal count_3_bit: unsigned (2 downto 0) := B"000"; -- three-bit counter
    signal by_three: std_logic; -- wire signal connected to multiple_three. This signal goes high if the 32-bit counter is multiple of 3
    signal by_five: std_logic; -- wire signal connected to multiple_five. This signal goes high if the 32-bit counter is multiple of 5
    signal by_fifteen: std_logic; -- wire signal connected to multiple_fifteen. This signal goes high if the 32-bit counter is NOT multiple of 3 and 5 (multiple of 15).
    constant limit : unsigned(31 downto 0):=X"EE6B2800"; -- X"EE6B2800 = 4 x 10^9 (unsigned value representing when the 32-bit must restart counting). The count starts always from 1.
begin
    process(CLK,Reset,load)
    begin
        if (Reset='1') then
            count <= X"00000001"; -- start from one for three counters
            count_2_bit <= B"01";
            count_3_bit<= B"001";

        elsif (rising_edge(CLK)) then -- increment each counter by 1 at each clock cycle.
            if(load='1')then
                count <= unsigned(load_data);
            else        
                count <= count + 1; 
                count_2_bit <= count_2_bit+1;
                count_3_bit <= count_3_bit+1; 
                if (count = limit )then -- if limit is reached then restart the 32-bit counter to start counting from the decimal value of 1
                        count <= X"00000001";    
                end if;
                if(count_2_bit = 3) then -- if the 2-bit counter reaches value 3 then restart it to count from the decimal value of 1
                        count_2_bit <= B"01";
                end if;
                if(count_3_bit = 5) then -- if the 3-bit counter reaches value 5 then restart it to count from the decimal value of 1
                        count_3_bit <= B"001";
                end if;
            end if;
        
        
        end if;    
    end process;
    multiple_three <= count_2_bit(1) AND (count_2_bit(0)); -- by_three wire gets high if both bits of the 2-bit counter are both 1. i.e.  B"11"= 3
    multiple_five <=  count_3_bit(2) AND (NOT count_3_bit(1)) AND (count_3_bit(0)); -- by_five wire gets high if the 3 bit counter value in binary is B"101"=5
    multiple_fifteen <= NOT (multiple_three AND multiple_five); -- by_fifteen wire gets high if either by_three or by_five is logic 0
    output <= std_logic_vector (count); -- connect the count wire to the 32-bit output counter of the entity
    -- multiple_three <= by_three;  -- connect the by_three wire to the output signal  multiple_three
    -- multiple_five <= by_five;    -- connect the by_five wire to the output signal  multiple_five
    -- multiple_fifteen <= by_fifteen;  -- connect the by_fifteen wire to the output signal  multiple_fifteen
    
end Behavioral;
