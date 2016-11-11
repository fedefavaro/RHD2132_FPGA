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
		---- master_control interface ----
		di_1_i : in std_logic_vector(15 downto  0);
		do_1_o : out std_logic_vector(15 downto  0);
		wren_1_i : in std_logic;
		drdy_1_o : out std_logic;
		rdreq_1_o : out std_logic;
		di_2_i : in std_logic_vector(15 downto  0);
		do_2_o : out std_logic_vector(15 downto  0);
		wren_2_i : in std_logic;
		drdy_2_o : out std_logic;
		rdreq_2_o : out std_logic
	);
END test_spi_side;


ARCHITECTURE synth OF test_spi_side IS

BEGIN



END synth;