-----------------------------------------------------------------------------------------------------------------------
-- Author:
-- 
-- Create Date:		09/11/2016  -- dd/mm/yyyy
-- Module Name:		test_spi_side
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description: 
--
--      ...
--      
-----------------------------------------------------------------------------------------------------------------------

LIBRARY ieee ;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
LIBRARY lpm;
USE lpm.lpm_components.ALL;

ENTITY test_spi_side IS
	PORT(
	    m_clk : in std_logic;	-- master clock
	    m_reset : in std_logic;  -- master reset
		---- master_control interface ----
		di_1_i : in std_logic_vector(15 downto  0);
		do_1_o : out std_logic_vector(15 downto  0);
		wren_1_i : in std_logic;
		drdy_1_o : out std_logic;
		rdreq_1_i : in std_logic;
		di_2_i : in std_logic_vector(15 downto  0);
		do_2_o : out std_logic_vector(15 downto  0);
		wren_2_i : in std_logic;
		drdy_2_o : out std_logic;
		rdreq_2_i : in std_logic;
		---- fifo 1 interface ----
		f1_do_o : out std_logic_vector(15 downto  0);
		f1_wren_o : out std_logic;
		---- fifo 2 interface ----
		f2_do_o : out std_logic_vector(15 downto  0);
		f2_wren_o : out std_logic;
		---- serial interface 1 ----
        spi1_ssel_o : out std_logic;                                     -- spi bus slave select line
        spi1_sck_o : out std_logic;                                      -- spi bus sck
        spi1_mosi_o : out std_logic;                                     -- spi bus mosi output
        spi1_miso_i : in std_logic := 'X';                               -- spi bus spi_miso_i input
        ---- serial interface 2 ----
        spi2_ssel_o : out std_logic;                                     -- spi bus slave select line
        spi2_sck_o : out std_logic;                                      -- spi bus sck
        spi2_mosi_o : out std_logic;                                     -- spi bus mosi output
        spi2_miso_i : in std_logic := 'X'                               -- spi bus spi_miso_i input
	);
END test_spi_side;


ARCHITECTURE synth OF test_spi_side IS

---- COMPONENTS
COMPONENT interconnect IS
PORT (
	---- master_control interface ----
	di_1_i : in std_logic_vector(15 downto  0);
	do_1_o : out std_logic_vector(15 downto  0);
	wren_1_i : in std_logic;	--triggers spi cycle
	drdy_1_o : out std_logic;
	rdreq_1_i : in std_logic;
	di_2_i : in std_logic_vector(15 downto  0);
	do_2_o : out std_logic_vector(15 downto  0);
	wren_2_i : in std_logic;	--triggers spi cycle
	drdy_2_o : out std_logic;
	rdreq_2_i : in std_logic;
	---- spi 1 interface ----
	s1_do_o : out std_logic_vector(15 downto  0);
	s1_di_i : in std_logic_vector(15 downto  0);
	s1_wren_o : out std_logic;
	s1_drdy_i : in std_logic;
	---- spi 2 interface ----
	s2_do_o : out std_logic_vector(15 downto  0);
	s2_di_i : in std_logic_vector(15 downto  0);
	s2_wren_o : out std_logic;
	s2_drdy_i : in std_logic;
	---- fifo 1 interface ----
	f1_do_o : out std_logic_vector(15 downto  0);
	f1_wren_o : out std_logic;
	---- fifo 2 interface ----
	f2_do_o : out std_logic_vector(15 downto  0);
	f2_wren_o : out std_logic	
);
END COMPONENT;

COMPONENT spi_master IS
    Generic (   
        N : positive := 16;                                             -- 32bit serial word length is default
        CPOL : std_logic := '0';                                        -- SPI mode selection (mode 0 default)
        CPHA : std_logic := '0';                                        -- CPOL = clock polarity, CPHA = clock phase.
        PREFETCH : positive := 2;                                       -- prefetch lookahead cycles
        SPI_2X_CLK_DIV : positive := 2);                                -- for a 100MHz sclk_i, yields a 25MHz SCK
    Port (  
        sclk_i : in std_logic := 'X';                                   -- high-speed serial interface system clock
        pclk_i : in std_logic := 'X';                                   -- high-speed parallel interface system clock
        rst_i : in std_logic := 'X';                                    -- reset core
        ---- serial interface ----
        spi_ssel_o : out std_logic;                                     -- spi bus slave select line
        spi_sck_o : out std_logic;                                      -- spi bus sck
        spi_mosi_o : out std_logic;                                     -- spi bus mosi output
        spi_miso_i : in std_logic := 'X';                               -- spi bus spi_miso_i input
        ---- parallel interface ----
        di_req_o : out std_logic;                                       -- preload lookahead data request line
        di_i : in  std_logic_vector (N-1 downto 0) := (others => 'X');  -- parallel data in (clocked on rising spi_clk after last bit)
        wren_i : in std_logic := 'X';                                   -- user data write enable, starts transmission when interface is idle
        wr_ack_o : out std_logic;                                       -- write acknowledge
        do_valid_o : out std_logic;                                     -- do_o data valid signal, valid during one spi_clk rising edge.
        do_o : out  std_logic_vector (N-1 downto 0);                    -- parallel output (clocked on rising spi_clk after last bit)
        --- debug ports: can be removed or left unconnected for the application circuit ---
        sck_ena_o : out std_logic;                                      -- debug: internal sck enable signal
        sck_ena_ce_o : out std_logic;                                   -- debug: internal sck clock enable signal
        do_transfer_o : out std_logic;                                  -- debug: internal transfer driver
        wren_o : out std_logic;                                         -- debug: internal state of the wren_i pulse stretcher
        rx_bit_reg_o : out std_logic;                                   -- debug: internal rx bit
        state_dbg_o : out std_logic_vector (3 downto 0);                -- debug: internal state register
        core_clk_o : out std_logic;
        core_n_clk_o : out std_logic;
        core_ce_o : out std_logic;
        core_n_ce_o : out std_logic;
        sh_reg_dbg_o : out std_logic_vector (N-1 downto 0)              -- debug: internal shift register
    );                      
END COMPONENT;

----  SIGNALS
SIGNAL sg_pll_out_clk : std_logic;

SIGNAL sg_do_1, sg_di_1 : std_logic_vector(15 downto 0);
SIGNAL sg_wren_1, sg_drdy_1 : std_logic;
SIGNAL sg_do_2, sg_di_2 : std_logic_vector(15 downto 0);
SIGNAL sg_wren_2, sg_drdy_2 : std_logic;


BEGIN

---- INSTANCES
U0: interconnect PORT MAP (
	---- master_control interface ----
	di_1_i => di_1_i,
	do_1_o => do_1_o,
	wren_1_i => wren_1_i,
	drdy_1_o => drdy_1_o,
	rdreq_1_i => rdreq_1_i,
	di_2_i => di_2_i,
	do_2_o => do_2_o,
	wren_2_i => wren_2_i,
	drdy_2_o => drdy_2_o,
	rdreq_2_i => rdreq_2_i,
	---- spi 1 interface ----
	s1_do_o => sg_do_1,
	s1_di_i => sg_di_1,
	s1_wren_o => sg_wren_1,
	s1_drdy_i => sg_drdy_1,
	---- spi 2 interface ----
	s2_do_o => sg_do_2,
	s2_di_i => sg_di_2,
	s2_wren_o => sg_wren_2,
	s2_drdy_i => sg_drdy_2,
	---- fifo 1 interface ----
	f1_do_o => f1_do_o,
	f1_wren_o => f1_wren_o,
	---- fifo 2 interface ----
	f2_do_o => f2_do_o,
	f2_wren_o => f2_wren_o
);

SPI_1: spi_master PORT MAP (
     sclk_i => sg_pll_out_clk,
     pclk_i => sg_pll_out_clk,
     rst_i => m_reset,
     ---- serial interface ----
     spi_ssel_o => spi1_ssel_o,
     spi_sck_o => spi1_sck_o,
     spi_mosi_o => spi1_mosi_o,
     spi_miso_i => spi1_miso_i,
     ---- parallel interface ----
     di_i => sg_do_1,
     wren_i => sg_wren_1,
     do_valid_o => sg_drdy_1,
     do_o => sg_di_1
);                      

SPI_2: spi_master PORT MAP (
     sclk_i => sg_pll_out_clk,
     pclk_i => sg_pll_out_clk,
     rst_i => m_reset,
     ---- serial interface ----
     spi_ssel_o => spi2_ssel_o,
     spi_sck_o => spi2_sck_o,
     spi_mosi_o => spi2_mosi_o,
     spi_miso_i => spi2_miso_i,
     ---- parallel interface ----
     di_i => sg_do_2,
     wren_i => sg_wren_2,
     do_valid_o => sg_drdy_2,
     do_o => sg_di_2
);     


sg_pll_out_clk <= m_clk;

END synth;