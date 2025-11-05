library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_Rx is
    generic (
        f_clk   : integer := 100_000_000;  -- 100 MHz
        baudrate: integer := 9600
    );

    port (
        clk : in  std_logic;
        rst : in  std_logic;
        rx : in  std_logic;
        d_out : out std_logic_vector(7 downto 0);
        d_valid : out std_logic
    );
end UART_Rx;

architecture Rx of UART_Rx is
    constant TICKS : integer := f_clk / baudrate;

    -- sync
    signal rx_sync : std_logic_vector(2 downto 0) := (others => '1');
    signal rx_x    : std_logic;

    -- sample signal
    signal ctr_baud : natural range 0 to TICKS - 1 := 0;
    signal sample   : std_logic := '0';

    -- FSM
    type state_t is (IDLE, START, RXING, STOP_s);
    signal s_state : state_t := IDLE;

    -- data 
    signal s_data   : std_logic_vector(7 downto 0) := (others => '0');
    signal s_count  : natural range 0 to 7 := 0;
    signal s_d_valid: std_logic := '0';

begin

    -- synchronize
    --- no metastability
    sync_proc : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                rx_sync <= (others => '1');
            else
                rx_sync <= rx_sync(1 downto 0) & rx;
            end if;
            rx_x <= rx_sync(2);
        end if;
    end process;

    -- baudrate generator
    --- when to sample
    baud_proc : process(clk, rst)
    begin
        if rst = '1' then
            ctr_baud <= 0;
            sample   <= '0';
        elsif rising_edge(clk) then
            sample <= '0';
            if s_state = IDLE then
                ctr_baud <= 0;
            elsif ctr_baud = TICKS - 1 then
                ctr_baud <= 0;
                sample   <= '1';
            else
                ctr_baud <= ctr_baud + 1;
            end if;
        end if;
    end process;

    -- FSM
    fsm_proc : process(clk, rst)
    begin
        if rst = '1' then
            s_state    <= IDLE;
            s_data     <= (others => '0');
            s_count    <= 0;
            s_d_valid  <= '0';
        elsif rising_edge(clk) then
            s_d_valid <= '0';  -- default

            case s_state is
                when IDLE =>
                    if rx_x = '0' then -- valid start
                        s_state <= START;
                    end if;

                when START =>
                    if sample = '1' then
                        if rx_x = '0' then -- start ok
                            s_state <= RXING;
                            s_count <= 0;
                            s_data  <= (others => '0');
                        else
                            s_state <= IDLE; -- start not ok
                        end if;
                    end if;

                when RXING =>
                    if sample = '1' then
                        s_data <= rx_x & s_data(7 downto 1);
                        if s_count = 7 then
                            s_state <= STOP_s;
                        else
                            s_count <= s_count + 1;
                        end if;
                    end if;

                when STOP_s =>
                    if sample = '1' then
                        if rx_x = '1' then -- valid stop
                            s_d_valid <= '1';
                        end if;
                        s_state <= IDLE;
                    end if;

            end case;
        end if;
    end process;

    -- out
    d_out   <= s_data;
    d_valid <= s_d_valid;

end architecture Rx;