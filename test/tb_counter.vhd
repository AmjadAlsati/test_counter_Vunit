-- Include VUnit functionality
library vunit_lib;
context vunit_lib.vunit_context;

library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std_unsigned.all;
use ieee.numeric_std.all;
library lib;

entity tb_counter is

    generic(
        runner_cfg : string;
        width      : positive:=32
        );
end;

architecture test of tb_counter is
    constant clk_period : time := 4 ns;

    signal clk          : std_logic :='0';
    signal rst          : std_logic;
    signal count        : std_logic_vector (width -1 downto 0);
    signal load         : std_logic;
    signal load_data    : std_logic_vector(width-1 downto 0);
    signal m_three      : std_logic;
    signal m_five       : std_logic;
    signal m_fifteen    : std_logic;
    constant limit : unsigned(width-1 downto 0):=X"EE6B2800"; -- X"EE6B2800 = 4 x 10^9 (unsigned value representing when the 32-bit must restart counting). The count starts always from 1.

    begin
    
        test_runner : process
        begin
            test_runner_setup(runner,runner_cfg);

            while test_suite loop
                rst <= '0';
                load <= '0';
                wait until rising_edge(clk);
                if run("Test counting") then
                    info("Testing if count passes");
                    for i in 1 to 10 loop
                        check_equal(count,i);
                        wait until rising_edge(clk);
                    end loop;

                elsif run("count data reached limit") then
                
                    load <= '1';
                    rst <= '0';
                    load_data <= std_logic_vector (limit - 10);
                    wait until rising_edge(clk);
                    --wait until rising_edge(clk);
                    load <= '0';
                    wait until rising_edge(clk);
                    for i in 0 to 9 loop
                        info("count is: "& to_string(count));
                        info("comparison is: "& to_string(limit-10 +i));

                        check_equal(count,limit-10 + i);
                        wait until rising_edge(clk);
                    end loop;
                elsif run("testing multiple of 3,5 and 15 signals") then
                    rst <= '1';
                    wait until rising_edge(clk);
                    rst<= '0';
                    wait until rising_edge(clk);
                    for i in 1 to 100 loop
                        info ("count is: "&to_string(count));
                        info ("i is:"& to_string(count));
                        if(i mod 3 =0 ) then
                            check_equal(m_three,'1');
                        end if;
                        -- if(to_integer(unsigned(count)) mod 5=0) then
                        --     check_equal(m_five,'1');
                        -- end if;
                        -- if(unsigned (count) mod 15/=0)then
                        --     check_equal(m_fifteen,'1');
                        -- end if;
                    wait until rising_edge(clk);
                    end loop;
                 end if;

            end loop;

             test_runner_cleanup(runner);
        end process;

        test_runner_watchdog(runner, 1 ms);


        counter_inst : entity lib.counter_vhd

            port map(
                CLK => clk,
                Reset => rst,
                load => load,
                load_data => load_data,
                output => count,
                multiple_three => m_three,
                multiple_five => m_five,
                multiple_fifteen => m_fifteen
                
            );

        clk <= not clk after clk_period/2;
    end;