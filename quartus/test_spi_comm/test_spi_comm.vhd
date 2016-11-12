-----------------------------------------------------------------------------------------------------------------------
-- Author:
-- 
-- Create Date:		11/11/2016  -- dd/mm/yyyy
-- Module Name:		test_spi_comm
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description: 
--
--      Prueba de comunicacion spi entre dos maestros y dos esclavos (1 a 1).
--		Si se da un flanco de subida en send_word_spi1_i(send_word_spi2_i) el bloque spi maestro 1(2) envia una dato a su
--		correspondiente esclavo.
--		El dato a enviar incremente en uno con cada envio.
--		El dato recibido por el escalvo es transferido al otro esclavo (a traves de la interfaz de datos paralelos).
--		Por lo tanto, si se da un flanco de subida en uno de los send_word y luego(*) se da un flanco en el otro, el dato
--		enviado por el primero es recibido por el segundo.
--		No se puede enviar datos por los dos spi maestro a la vez (restriccion del simulador de control maestro)
--      
--		(*) Se debe esperar que termine el ciclo spi!
-----------------------------------------------------------------------------------------------------------------------

LIBRARY ieee ;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
LIBRARY lpm;
USE lpm.lpm_components.ALL;

ENTITY test_spi_comm IS
	PORT(
	    m_clk : in std_logic;	-- master clock
	    m_reset : in std_logic;  -- master reset
		---- fifo 1 interface ----
		f1_do_o : out std_logic_vector(15 downto  0);
		f1_wren_o : out std_logic;
		---- fifo 2 interface ----
		f2_do_o : out std_logic_vector(15 downto  0);
		f2_wren_o : out std_logic;
		---- user interface ----
		send_word_spi1_i : in std_logic;
		send_word_spi2_i : in std_logic
	);
END test_spi_comm;


ARCHITECTURE synth OF test_spi_comm IS

---- COMPONENTS
COMPONENT test_spi_side IS
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
END COMPONENT;

COMPONENT m_control_sim IS
	PORT(
	    m_clk : in std_logic;	-- master clock
	    m_reset : in std_logic;  -- master reset
		---- master_control interface ----
		mc_di_1_i : in std_logic_vector(15 downto  0);
		mc_do_1_o : out std_logic_vector(15 downto  0);
		mc_wren_1_o : out std_logic;
		mc_drdy_1_i : in std_logic;
		mc_rdreq_1_o : out std_logic;
		mc_di_2_i : in std_logic_vector(15 downto  0);
		mc_do_2_o : out std_logic_vector(15 downto  0);
		mc_wren_2_o : out std_logic;
		mc_drdy_2_i : in std_logic;
		mc_rdreq_2_o : out std_logic;
		---- user interface ----
		send_1_i : in std_logic;
		send_2_i : in std_logic
	);
END COMPONENT;

COMPONENT test_spi_slaves IS
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
END COMPONENT;

----  SIGNALS
signal sg_mc_do_1_o : std_logic_vector(15 downto  0);
signal sg_mc_wren_1_o : std_logic;
signal sg_mc_rdreq_1_o : std_logic;

signal sg_mc_do_2_o : std_logic_vector(15 downto  0);
signal sg_mc_wren_2_o : std_logic;
signal sg_mc_rdreq_2_o : std_logic;

signal sg_spi1_ssel_o : std_logic;
signal sg_spi1_sck_o : std_logic;
signal sg_spi1_mosi_o : std_logic;
signal sg_spi1_miso_i : std_logic;
signal sg_spi2_ssel_o : std_logic;
signal sg_spi2_sck_o : std_logic;
signal sg_spi2_mosi_o : std_logic;
signal sg_spi2_miso_i : std_logic;

BEGIN

---- INSTANCES
T_spi: test_spi_side port map (
        m_clk => m_clk,
		m_reset => m_reset,
		---- master_control interface ----
		di_1_i => sg_mc_do_1_o,
		wren_1_i => sg_mc_wren_1_o,
		rdreq_1_i => sg_mc_rdreq_1_o,
		di_2_i => sg_mc_do_2_o,
		wren_2_i => sg_mc_wren_2_o,
		rdreq_2_i => sg_mc_rdreq_2_o,
		---- fifo 1 interface ----
		f1_do_o => f1_do_o,
		f1_wren_o => f1_wren_o,
		---- fifo 2 interface ----
		f2_do_o => f2_do_o,
		f2_wren_o => f2_wren_o,
		---- serial interface 1 ----
		spi1_ssel_o => sg_spi1_ssel_o,
		spi1_sck_o => sg_spi1_sck_o,
		spi1_mosi_o => sg_spi1_mosi_o,
		spi1_miso_i => sg_spi1_miso_i,
		---- serial interface 2 ----
		spi2_ssel_o => sg_spi2_ssel_o,
		spi2_sck_o => sg_spi2_sck_o,
		spi2_mosi_o => sg_spi2_mosi_o,
		spi2_miso_i => sg_spi2_miso_i
);

MC: m_control_sim port map (
	    m_clk => m_clk,
	    m_reset => m_reset,
		---- master_control interface ----
		mc_di_1_i => X"0000",
		mc_do_1_o => sg_mc_do_1_o,
		mc_wren_1_o => sg_mc_wren_1_o,
		mc_drdy_1_i => '0',
		mc_rdreq_1_o => sg_mc_rdreq_1_o,
		mc_di_2_i => X"0000",
		mc_do_2_o => sg_mc_do_2_o,
		mc_wren_2_o => sg_mc_wren_2_o,
		mc_drdy_2_i => '0',
		mc_rdreq_2_o => sg_mc_rdreq_2_o,
		---- user interface ----
		send_1_i => send_word_spi1_i,
		send_2_i => send_word_spi2_i
);

T_slaves: test_spi_slaves port map (
	    m_clk => m_clk,
		m_reset => m_reset,
		---- serial interface 1 ----
        slave1_ssel_i => sg_spi1_ssel_o,
        slave1_sck_i => sg_spi1_sck_o,
        slave1_mosi_i => sg_spi1_mosi_o,
        slave1_miso_o => sg_spi1_miso_i,
        ---- serial interface 2 ----
        slave2_ssel_i => sg_spi2_ssel_o,
        slave2_sck_i => sg_spi2_sck_o,
        slave2_mosi_i => sg_spi2_mosi_o,
        slave2_miso_o => sg_spi2_miso_i
);

END synth;