library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_Rx is
    generic (
        f_clk : integer := 100_000_000; -- bordje werkt op 100 MHz
        baudrate : integer := 9600
    )

    port (
        clk : in std_logic;
        rst : in std_logic;
        rx : in std_logic;
        d_out : out std_logic_vector(7 downto 0);
        d_valid : out std_logic
    );
end UART_Rx;

architecture Rx of UART_Rx is
    -- divide clk to UART temmpo
    constant TICKS : int := f_clk/baudrate;

    -- synchronization
    signal rx_sync : std_logic_vector(7 downto 0) := (others => '1');
    signal rx_x : std_logic;

    -- count baud
    signal ctr_baud : natural range (0 to TICKS-1) := 0;
    signal s_sample : std_logic := '0';

    -- FSM initialisation
    type state is (IDLE, START, RXING, STOP);
    signal s_state : state := IDLE;

    -- data signals
    signal s_shift : std_logic_vector(7 downto 0) := (others => '0');
    signal s_count : integer range 0 to 7 := 0;
    --outputs
    signal s_data : std_logic_vector(7 downto 0) := (others => '0');
    signal s_d_valid : std_logic := '0';

begin
    -- synchronize
    process sync(clk) is
    begin
        if rising_edge(clk) then
            rx_sync <= rx_sync(0) & rx;
            rx_x <= rx_sync(1);
        end if;
    end sync;

    -- generate baud
    process baud(clk, rst)
    begin
        if rst = '1' then
            ctr_baud <= 0;
            s_sample <=  '0';
        elsif rising_edge(clk) then
            if (ctr_baud = TICKS - 1) then
                ctr_baud <= 0;
                s_sample <= '1';
            else
                ctr_baud <= ctr_baud + 1;
            end if;
        end if;
    end baud;
    
            

    end procedure;

end architecture;