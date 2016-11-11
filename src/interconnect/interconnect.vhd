-----------------------------------------------------------------------------------------------------------------------
-- Author:
-- 
-- Create Date:		09/11/2016  -- dd/mm/yyyy
-- Module Name:		interconnect
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

ENTITY interconnect IS
	PORT(
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
END interconnect;


ARCHITECTURE behav OF interconnect IS

BEGIN

	-- If rdreq_1_o is high data is feed to the master control, if it is low
	-- data is stored in the corresponding fifo.
	switch_data_1: process(rdreq_1_i, s1_di_i, s1_drdy_i)
	begin
		if rdreq_1_i = '1' then
			do_1_o <= s1_di_i;
			f1_do_o <= X"0000";
			f1_wren_o <= '0';
		else
			do_1_o <=  X"0000";
			f1_do_o <= s1_di_i;
			f1_wren_o <= s1_drdy_i;
		end if;
	end process;
	
	switch_data_2: process(rdreq_2_i, s2_di_i, s2_drdy_i)
	begin
		if rdreq_2_i = '1' then
			do_2_o <= s2_di_i;
			f2_do_o <= X"0000";
			f2_wren_o <= '0';
		else
			do_2_o <=  X"0000";
			f2_do_o <= s2_di_i;
			f2_wren_o <= s2_drdy_i;
		end if;
	end process;

	-- fixed signals
	drdy_1_o <= s1_drdy_i;
	drdy_2_o <= s2_drdy_i;

	s1_do_o <= di_1_i;
	s1_wren_o <= wren_1_i;

	s2_do_o <= di_2_i;
	s2_wren_o <= wren_2_i;

END behav;