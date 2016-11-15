-----------------------------------------------------------------------------------------------------------------------
-- Author:
-- 
-- Create Date:		11/11/2016  -- dd/mm/yyyy
-- Module Name:		test_spi_de0
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description: 
--
--      ...
-----------------------------------------------------------------------------------------------------------------------

LIBRARY ieee ;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
LIBRARY lpm;
USE lpm.lpm_components.ALL;

ENTITY test_spi_de0 IS
	PORT(
	    m_clk : in std_logic;	-- master clock
	    m_reset : in std_logic;  -- master reset
	    boton2_set : in std_logic;
	    boton1_reset : in std_logic;
	    FULL_LED9 : out std_logic;
	    EMPTY_LED8 : out std_logic;
	    SW : in std_logic_vector(7 downto 0);
	    display0 : out std_logic_vector(0 to 6);
	    display1 : out std_logic_vector(0 to 6);
	    display2 : out std_logic_vector(0 to 6);
	    display3 : out std_logic_vector(0 to 6);
	    ---- master interface 1 ----
		spi1_ssel_o : out std_logic;                                     -- spi bus slave select line
		spi1_sck_o : out std_logic;                                      -- spi bus sck
		spi1_mosi_o : out std_logic;                                     -- spi bus mosi output
		spi1_miso_i : in std_logic := 'X';                               -- spi bus spi_miso_i input
		---- master interface 2 ----
		spi2_ssel_o : out std_logic;                                     -- spi bus slave select line
		spi2_sck_o : out std_logic;                                      -- spi bus sck
		spi2_mosi_o : out std_logic;                                     -- spi bus mosi output
		spi2_miso_i : in std_logic := 'X';                               -- spi bus spi_miso_i input
		---- slave interface 1 ----
        slave1_ssel_i : in std_logic := 'X';                              -- spi bus slave select line
        slave1_sck_i : in std_logic := 'X';                               -- spi bus sck
        slave1_mosi_i : in std_logic := 'X';                              -- spi bus mosi output
        slave1_miso_o : out std_logic := 'X';                             -- spi bus spi_miso_i input
        ---- slave interface 2 ----
        slave2_ssel_i : in std_logic := 'X';                              -- spi bus slave select line
        slave2_sck_i : in std_logic := 'X';                               -- spi bus sck
        slave2_mosi_i : in std_logic := 'X';                              -- spi bus mosi output
        slave2_miso_o : out std_logic := 'X';                              -- spi bus spi_miso_i input
        ---- dbg ---
		dbg_read_fifo_1 : out std_logic
		---- fifo 1 interface ----
		--f1_do_o : out std_logic_vector(15 downto  0);
		--f1_wren_o : out std_logic;
		---- fifo 2 interface ----
		--f2_do_o : out std_logic_vector(15 downto  0);
		--f2_wren_o : out std_logic
	);
END test_spi_de0;


ARCHITECTURE synth OF test_spi_de0 IS

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

COMPONENT Maquina_de_Control IS
   PORT(
	  CLK                       : IN  STD_LOGIC;                     --Reset activo por ALTO!
	  RESET                     : IN  STD_LOGIC;  -- @ff:No me gusta agrupar aca! jaja
	  --senales de trigger de funciones
	  reg_func_in               : IN  STD_LOGIC_VECTOR(7 downto 0);
	  reg_func_out              : OUT STD_LOGIC_VECTOR(7 downto 0);
	  ---- load_param
	  reg_load_param_1          : IN  STD_LOGIC_VECTOR(15 downto 0); -- @ff: Salida del banco de registros con configuracion del chip 1
	  selec_load_param_1        : OUT STD_LOGIC_VECTOR(7 downto 0);  -- @ff: Selector del banco de registros (18 registros) del chip 1
	  --send_command
	  reg_send_com_in           : IN  STD_LOGIC_VECTOR(15 downto 0);
	  --Senales de comunicacion con bloque convertidor a SPI
	  reg_envio_out             : OUT STD_LOGIC_VECTOR(15 downto 0); -- Registro donde mando el comando pronto para enviar.
	  ack_in                    : IN  STD_LOGIC;                     -- ACK de que llego el dato al convertidor SPI.  LO CONSIDERO UN PULSO DE UN CLK
	  WE_out                    : OUT STD_LOGIC                     -- Senal de control que indica que esta pronto para enviar el dato
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


component GEN_PULSO is
   port(
	  clk             : in std_logic; -- clk
	  reset           : in std_logic; -- reset
	  input           : in std_logic; -- input
	  edge_detected   : out std_logic   -- edge_detected: pulso a 1 cuando 
							 -- se detecta flanco en input
  );
end component;


component fifo_test_1
	PORT
	(
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
end component;

COMPONENT hex27seg IS
PORT(
	 hex_in     : IN  STD_LOGIC_VECTOR(3 downto 0);
	 seg_out    : OUT STD_LOGIC_VECTOR(6 downto 0)
	);
END COMPONENT;

   COMPONENT rebot_elim is
     PORT(
        Sn, Rn : in std_logic;
        Q   : out std_logic
        );
   END COMPONENT;

----  SIGNALS
signal sg_mc_do_1_o : std_logic_vector(15 downto  0);
signal sg_mc_wren_1_o : std_logic;
signal sg_drdy_1_o : std_logic;
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

signal sg_f1_do_o  : std_logic_vector(15 downto  0);
signal sg_f1_wren_o : std_logic;

signal sg_read_fifo_1 : std_logic;
signal q_sig : std_logic_vector(15 downto 0);

signal sg_flanco : std_logic;

BEGIN

---- INSTANCES
T_spi: test_spi_side port map (
        m_clk => m_clk,
		m_reset => m_reset,
		---- master_control interface ----
		di_1_i => sg_mc_do_1_o,
		wren_1_i => sg_mc_wren_1_o,
		drdy_1_o => sg_drdy_1_o,
		rdreq_1_i => '0',
		di_2_i => sg_mc_do_2_o,
		wren_2_i => sg_mc_wren_2_o,
		rdreq_2_i => '0',
		---- fifo 1 interface ----
		f1_do_o => sg_f1_do_o,
		f1_wren_o => sg_f1_wren_o,
		---- fifo 2 interface ----
		--f2_do_o => f2_do_o,
		--f2_wren_o => f2_wren_o,
		---- serial interface 1 ----
		spi1_ssel_o => spi1_ssel_o,
		spi1_sck_o => spi1_sck_o,
		spi1_mosi_o => spi1_mosi_o,
		spi1_miso_i => spi1_miso_i,
		---- serial interface 2 ----
		spi2_ssel_o => spi2_ssel_o,
		spi2_sck_o => spi2_sck_o,
		spi2_mosi_o => spi2_mosi_o,
		spi2_miso_i => spi2_miso_i
);

MC: Maquina_de_Control port map (
	    CLK => m_clk,
	    RESET => m_reset,
        --senales de trigger de funciones
        reg_func_in => SW,
        ---- load_param
        reg_load_param_1 => X"BEEF", 
        --send_command
        reg_send_com_in => X"AAAA",
        --Senales de comunicacion con bloque convertidor a SPI
        reg_envio_out => sg_mc_do_1_o,
        ack_in  => sg_drdy_1_o,
        WE_out => sg_mc_wren_1_o
);


T_slaves: test_spi_slaves port map (
	    m_clk => m_clk,
		m_reset => m_reset,
		---- serial interface 1 ----
        slave1_ssel_i => slave1_ssel_i,
        slave1_sck_i => slave1_sck_i,
        slave1_mosi_i => slave1_mosi_i,
        slave1_miso_o => slave1_miso_o,
        ---- serial interface 2 ----
        slave2_ssel_i => slave2_ssel_i,
        slave2_sck_i => slave2_sck_i,
        slave2_mosi_i => slave2_mosi_i,
        slave2_miso_o => slave2_miso_o
);

gen_pul : GEN_PULSO port map (
	  clk => m_clk,
	  reset  => m_reset,
	  input  => sg_flanco,
	  edge_detected => sg_read_fifo_1
);


fifo_test_1_inst : fifo_test_1 PORT MAP (
		clock	 => m_clk,
		data	 => sg_f1_do_o,
		rdreq	 => sg_read_fifo_1,
		wrreq	 => sg_f1_wren_o,
  		empty	 => EMPTY_LED8,
  		full	 => FULL_LED9,
		q	 => q_sig
);

hex0 : hex27seg port map (
	 hex_in => q_sig(3 downto 0),
	 seg_out => display0
);
hex1 : hex27seg port map (
	 hex_in => q_sig(7 downto 4),
	 seg_out => display1
);
hex2 : hex27seg port map (
	 hex_in => q_sig(11 downto 8),
	 seg_out => display2
);
hex3 : hex27seg port map (
	 hex_in => q_sig(15 downto 12),
	 seg_out => display3
);

RE: rebot_elim PORT map (
        Sn => boton2_set,
        Rn => boton1_reset,
        Q  => sg_flanco
);

dbg_read_fifo_1 <= sg_read_fifo_1;
   
END synth;


