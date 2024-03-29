-----------------------------------------------------------------------------------------------------------------------
-- Author:
-- 
-- Create Date:		09/11/2016  -- dd/mm/yyyy
-- Module Name:		test_spi_slaves
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description: 
--
--      Este bloque instancia dos bloques spi escalvos tal que la salida de datos de uno esta conectada a la entrada
--		de datos del otro. Lo mismo sucede con la salida que indica un dato valido y la entrada write enable. Por lo tanto,
--		si un bloque recibe un dato, en el proximo ciclo spi ese dato sera enviado por el otro bloque spi.
--      
-----------------------------------------------------------------------------------------------------------------------

LIBRARY ieee ;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
LIBRARY lpm;
USE lpm.lpm_components.ALL;

ENTITY test_spi_slaves IS
	PORT(
	    m_clk : in std_logic;	-- master clock
	    m_reset : in std_logic;  -- master reset
		---- serial interface 1 ----
        slave1_ssel_i : in std_logic := 'X';                              -- spi bus slave select line
        slave1_sck_i : in std_logic := 'X';                               -- spi bus sck
        slave1_mosi_i : in std_logic := 'X';                              -- spi bus mosi output
        slave1_miso_o : out std_logic := 'X';                             -- spi bus spi_miso_i input
        ---- serial interface 2 ----
        slave2_ssel_i : in std_logic := 'X';                              -- spi bus slave select line
        slave2_sck_i : in std_logic := 'X';                               -- spi bus sck
        slave2_mosi_i : in std_logic := 'X';                              -- spi bus mosi output
        slave2_miso_o : out std_logic := 'X'                              -- spi bus spi_miso_i input
	);
END test_spi_slaves;


ARCHITECTURE synth OF test_spi_slaves IS

---- COMPONENTS
COMPONENT spi_slave IS
    Generic (   
        N : positive := 16;                                             -- 32bit serial word length is default
        CPOL : std_logic := '0';                                        -- SPI mode selection (mode 0 default)
        CPHA : std_logic := '0';                                        -- CPOL = clock polarity, CPHA = clock phase.
        PREFETCH : positive := 2);                                      -- prefetch lookahead cycles
    Port (  
        clk_i : in std_logic := 'X';                                    -- internal interface clock (clocks di/do registers)
        spi_ssel_i : in std_logic := 'X';                               -- spi bus slave select line
        spi_sck_i : in std_logic := 'X';                                -- spi bus sck clock (clocks the shift register core)
        spi_mosi_i : in std_logic := 'X';                               -- spi bus mosi input
        spi_miso_o : out std_logic := 'X';                              -- spi bus spi_miso_o output
        di_req_o : out std_logic;                                       -- preload lookahead data request line
        di_i : in  std_logic_vector (N-1 downto 0) := (others => 'X');  -- parallel load data in (clocked in on rising edge of clk_i)
        wren_i : in std_logic := 'X';                                   -- user data write enable
        wr_ack_o : out std_logic;                                       -- write acknowledge
        do_valid_o : out std_logic;                                     -- do_o data valid strobe, valid during one clk_i rising edge.
        do_o : out  std_logic_vector (N-1 downto 0);                    -- parallel output (clocked out on falling clk_i)
        --- debug ports: can be removed for the application circuit ---
        do_transfer_o : out std_logic;                                  -- debug: internal transfer driver
        wren_o : out std_logic;                                         -- debug: internal state of the wren_i pulse stretcher
        rx_bit_next_o : out std_logic;                                  -- debug: internal rx bit
        state_dbg_o : out std_logic_vector (3 downto 0);                -- debug: internal state register
        sh_reg_dbg_o : out std_logic_vector (N-1 downto 0)              -- debug: internal shift register
    );                      
END COMPONENT;

----  SIGNALS
SIGNAL sg_slave1_di, sg_slave2_di : std_logic_vector(15 downto 0);
SIGNAL sg_slave1_wren, sg_slave2_wren : std_logic;

BEGIN

---- INSTANCES
SLAVE_1: spi_slave PORT MAP (
	clk_i => m_clk,
    spi_ssel_i => slave1_ssel_i,
    spi_sck_i => slave1_sck_i,
    spi_mosi_i => slave1_mosi_i,
    spi_miso_o => slave1_miso_o,
    di_i => sg_slave1_di,
    wren_i => sg_slave1_wren,
    do_valid_o => sg_slave2_wren,
    do_o => sg_slave2_di
);                      

SLAVE_2: spi_slave PORT MAP (
	clk_i => m_clk,
    spi_ssel_i => slave2_ssel_i,
    spi_sck_i => slave2_sck_i,
    spi_mosi_i => slave2_mosi_i,
    spi_miso_o => slave2_miso_o,
    di_i => sg_slave2_di,
    wren_i => sg_slave2_wren,
    do_valid_o => sg_slave1_wren,
    do_o => sg_slave1_di
);     

END synth;