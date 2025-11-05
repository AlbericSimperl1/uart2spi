----------------------------------------------------------------------------
--  uart_rx_tb.vhd
--  test bench for UART RX operation
--  Version 1.0
--
--  Copyright (C) 2019 Fares Mehanna
--
--  This program is free software: you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation, either version
--  2 of the License, or (at your option) any later version.
--
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uartRX_tb is
end uartRX_tb;

architecture Behavioral of uartRX_tb is

    constant c_CLOK_PERIOD : time := 1 sec / 100000000;     -- 100 MHZ
    constant c_UART_CLOK_PERIOD : time := 1 sec / 9600;     -- baud rate
    
    signal r_clk : std_logic := '0';
    signal r_rst : std_logic := '0';
    signal r_rx : std_logic := '1';
    signal r_d_out : std_logic_vector (7 downto 0);
    signal r_d_valid : std_logic;
    
    component uartRX is
        Port (
            clk   : in std_logic;
            rst : in std_logic;
$            rx : in std_logic;
            d_out  : out std_logic_vector (7 downto 0);
            d_valid : out std_logic := '0'
        );
    end component uartRX;
    
begin

    UUT : uartRX
    port map (
        clk => r_clk,
        rst => r_rst,
        rx => r_rx,
        d_out => r_d_out,
        d_valid => r_d_valid
    );

    p_clk_generation : process is
    begin
        wait for c_CLOK_PERIOD / 2;
            r_clk <= not r_clk;
    end process;

    
    tb : process is
    begin
        
        -- start bit
        r_rx <= '0';
        wait for c_UART_CLOK_PERIOD;
 
        -- will send 10010110
        -- data bits
        r_rx <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx <= '1';
        wait for c_UART_CLOK_PERIOD;
        r_rx <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx <= '0';
        wait for c_UART_CLOK_PERIOD;
        r_rx <= '1';
        wait for c_UART_CLOK_PERIOD;
        
        -- stop bit
        r_rx <= '1';
        wait for c_UART_CLOK_PERIOD;
        
        -- wait a cycle
        wait for c_UART_CLOK_PERIOD;            
    end process;
end Behavioral;