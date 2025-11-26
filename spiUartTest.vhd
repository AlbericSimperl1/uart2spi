library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Simple_UART_SPI_Top is
    port (
        clk : in  std_logic;
        rst : in  std_logic;
        
        -- UART interface
        rx : in  std_logic;
        
        -- SPI interface
        clk_spi  : out std_logic;
        spi_mosi : out std_logic;
        cs       : out std_logic;
        
        -- Debug LEDs
        led : out std_logic_vector(7 downto 0);
        led_uart_valid : out std_logic;
        led_spi_busy : out std_logic
    );
end Simple_UART_SPI_Top;

architecture Behavioral of Simple_UART_SPI_Top is
    
    -- UART signals
    signal uart_data : std_logic_vector(7 downto 0);
    signal uart_valid : std_logic;
    
    -- SPI signals
    signal spi_busy : std_logic;
    
begin

    -- UART Receiver instantie
    uart_rx_inst : entity work.UART_Rx
        generic map (
            f_clk    => 100_000_000,
            baudrate => 9600
        )
        port map (
            clk     => clk,
            rst     => rst,
            rx      => rx,
            d_out   => uart_data,
            d_valid => uart_valid
        );
    
    -- SPI Transmitter instantie
    spi_tx_inst : entity work.SPI_Tx
        generic map (
            f_clk     => 100_000_000,
            spi_f_clk => 8_000_000
        )
        port map (
            clk      => clk,
            rst      => rst,
            d_in     => uart_data,
            d_valid  => uart_valid,
            busy     => spi_busy,
            clk_spi  => clk_spi,
            spi_mosi => spi_mosi,
            cs       => cs
        );
    
    -- Debug outputs
    led <= uart_data;           -- Toon ontvangen UART byte
    led_uart_valid <= uart_valid;  -- Knippert bij UART ontvangst
    led_spi_busy <= spi_busy;      -- Brandt tijdens SPI transmissie

end architecture Behavioral;