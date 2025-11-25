library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SPI_Tx is
    generic(
        f_clk : integer := 100_000_000; -- 100 MHz
        spi_f_clk : integer := 8_000_000 -- 8MHZ
    )
    
    port (
        -- standard
        clk : in std_logic;
        rst : in std_logic;
        -- data
        d_in : in std_logic_vector(7 downto 0);
        d_valid : in std_logic;
        -- outputs
        busy : out std_logic; -- busy transmitting to handler
        clk_spi : out std_logic;
        spi_mosi : out std_logic; -- master out slave in 
        spi_CS : out std_logic; -- chip select
    );
end SPI_Tx;

architecture rtl of SPI_Tx is
    constant DIV : integer := f_clk / (2 * spi_f_clk); -- divides to 8M
    -- states
    type state_t is (IDLE, LOAD, TRANSMIT, FINISH);
    signal state : state_t := IDLE; 
    -- clk generator
    signal clk_ctr : integer range 0 to CLKDIV - 1 := 0;
    signal spi_en : std_logic := '0';
    signal s_spi_clk : std_logic := '0'; -- internal
    -- reg
    signal sr : std_logic_vector(7 downto 0) := (others => '0');
    
    signal bit_ctr : integer range 0 to 7 := 0;
    signal s_busy : std_logic := '0';
    signal s_cs: std_logic := '1';
begin

    -- spi clk generator
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                clk_ctr <= 0;
                s_spi_clk <= '0';
                spi_en <= '0';
            else
                spi_en <= '0';

                if (state = IDLE) then
                    clk_ctr <= 0;
                    s_spi_clk <= '0';
                elsif state = TRANSMIT then
                    if clk_ctr = (DIV - 1) then
                        clk_ctr = 0;
                        s_spi_clk <= not s_spi_clk;
                        spi_en <=  not s_spi_clk;
                    else
                        clk_ctr <= clk_ctr + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- SPI fsm
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
                sr <= (others => '0');
                bit_ctr <= 0;
                s_busy <= '0';
                s_cs <= '1';
            else
                case state is
                    when IDLE =>
                        busy <= '0';
                        s_cs <= '1';
                        bit_ctr <= 0;
                        
                        if data_valid = '1' then
                            sr <= d_in;
                            state <= LOAD;
                            s_busy <= '1';
                        end if;
                    
                    when LOAD =>
                        s_cs <= '0';  -- activate chip select
                        state <= TRANSMIT;
                    
                    when TRANSMIT =>
                        if spi_clk_en = '1' then
                            sr <= sr(6 downto 0) & '0';
                            
                            if bit_ctr = 7 then
                                state <= FINISH;
                            else
                                bit_ctr <= bit_ctr + 1;
                            end if;
                        end if;
                    
                    when FINISH =>
                        if clk_ctr = DIV - 1 then
                            s_cs <= '1';  -- Deactivate chip select
                            s_busy <= '0';
                            state <= IDLE;
                        end if;
                end case;
            end if;
        end if;
    end process;

    spi_mosi <= sr(7);
    spi_clk <= s_spi_clk;
    cs <= s_cs;
    busy <= s_busy;
    
end architecture;