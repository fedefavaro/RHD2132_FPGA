-----------------------------------------------------------------------------------------------------------------------
-- Author:
-- 
-- Create Date:		13/11/2016  -- dd/mm/yyyy
-- Module Name:		params_reg_bank
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description: 
--
--		Banco de registros para almacenar los parametros de configuracion de los chips.
--      Las entradas input_* son de 8 bits y permiten modificar el parametro a configurar
--      Las saludas output_* son de 16 bits y representan el comando que se debe enviar al
--      chip para cargar el parametro de confiuracion.
--      El comando a enviar es:
--         WRITE(R,D) – Write data D to register R
--
--          MSB                                                                                       LSB
--         | 15 |  14 |  13 |  12 |  11 |  10 |  9  |  8  |  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0   |
--         | 1  |  0  | R[5]| R[4]| R[3]| R[2]| R[1]| R[0]| D[7]| D[6]| D[5]| D[4]| D[3]| D[2]| D[1]| D[0] |
--      
--      
-----------------------------------------------------------------------------------------------------------------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY params_reg_bank IS
       PORT(
          clk                       : in  std_logic;
          rst                       : in  std_logic;
          -- chip 1 --
          input_chip_1              : in  std_logic_vector(7 downto 0);
          select_chip_1             : in  std_logic_vector(6 downto 0);
          output_chip_1             : out  std_logic_vector(15 downto 0);
          wren_chip_1               : in  std_logic;
          -- chip 2 --
          input_chip_2              : in  std_logic_vector(7 downto 0);
          select_chip_2             : in  std_logic_vector(6 downto 0);
          output_chip_2             : out  std_logic_vector(15 downto 0); 
          wren_chip_1               : in  std_logic  
       );
END test_maquina_control;


ARCHITECTURE behav of params_reg_bank IS

-- signals
signal chip_1_reg_00 : std_logic_vector(7 downto 0); --adr: 00
signal chip_1_reg_01 : std_logic_vector(7 downto 0); --adr: 01
signal chip_1_reg_02 : std_logic_vector(7 downto 0); --adr: 02
signal chip_1_reg_03 : std_logic_vector(7 downto 0); --adr: 03
signal chip_1_reg_04 : std_logic_vector(7 downto 0); --adr: 04
signal chip_1_reg_05 : std_logic_vector(7 downto 0); --adr: 05
signal chip_1_reg_06 : std_logic_vector(7 downto 0); --adr: 06
signal chip_1_reg_07 : std_logic_vector(7 downto 0); --adr: 07
signal chip_1_reg_08 : std_logic_vector(7 downto 0); --adr: 08
signal chip_1_reg_09 : std_logic_vector(7 downto 0); --adr: 09
signal chip_1_reg_10 : std_logic_vector(7 downto 0); --adr: 10
signal chip_1_reg_11 : std_logic_vector(7 downto 0); --adr: 11
signal chip_1_reg_12 : std_logic_vector(7 downto 0); --adr: 12
signal chip_1_reg_13 : std_logic_vector(7 downto 0); --adr: 13
signal chip_1_reg_14 : std_logic_vector(7 downto 0); --adr: 14
signal chip_1_reg_15 : std_logic_vector(7 downto 0); --adr: 15
signal chip_1_reg_16 : std_logic_vector(7 downto 0); --adr: 16
signal chip_1_reg_17 : std_logic_vector(7 downto 0); --adr: 17

signal chip_2_reg_00 : std_logic_vector(7 downto 0); --adr: 20
signal chip_2_reg_01 : std_logic_vector(7 downto 0); --adr: 21
signal chip_2_reg_02 : std_logic_vector(7 downto 0); --adr: 22
signal chip_2_reg_03 : std_logic_vector(7 downto 0); --adr: 23
signal chip_2_reg_04 : std_logic_vector(7 downto 0); --adr: 24
signal chip_2_reg_05 : std_logic_vector(7 downto 0); --adr: 25
signal chip_2_reg_06 : std_logic_vector(7 downto 0); --adr: 26
signal chip_2_reg_07 : std_logic_vector(7 downto 0); --adr: 27
signal chip_2_reg_08 : std_logic_vector(7 downto 0); --adr: 28
signal chip_2_reg_09 : std_logic_vector(7 downto 0); --adr: 29
signal chip_2_reg_10 : std_logic_vector(7 downto 0); --adr: 30
signal chip_2_reg_11 : std_logic_vector(7 downto 0); --adr: 31
signal chip_2_reg_12 : std_logic_vector(7 downto 0); --adr: 32
signal chip_2_reg_13 : std_logic_vector(7 downto 0); --adr: 33
signal chip_2_reg_14 : std_logic_vector(7 downto 0); --adr: 34
signal chip_2_reg_15 : std_logic_vector(7 downto 0); --adr: 35
signal chip_2_reg_16 : std_logic_vector(7 downto 0); --adr: 36
signal chip_2_reg_17 : std_logic_vector(7 downto 0); --adr: 37

BEGIN

   read_write_reg_bank_1 : process()
   begin
      if rst = '1' then
         -- default value --
         chip_1_reg_00 =>  X"DE";
         chip_1_reg_01 =>  X"60"; 
         chip_1_reg_02 =>  X"28";
         chip_1_reg_03 =>  X"00";
         chip_1_reg_04 =>  X"00";
         chip_1_reg_05 =>  X"00";
         chip_1_reg_06 =>  X"00";
         chip_1_reg_07 =>  X"00";
         chip_1_reg_08 =>  X"26";
         chip_1_reg_09 =>  X"1A";
         chip_1_reg_10 =>  X"05";
         chip_1_reg_11 =>  X"1F";
         chip_1_reg_12 =>  X"16";
         chip_1_reg_13 =>  X"7C";
         chip_1_reg_14 =>  X"FF";
         chip_1_reg_15 =>  X"FF";
         chip_1_reg_16 =>  X"FF";
         chip_1_reg_17 =>  X"FF";
      elsif m_clk'event and m_clk = '1' then
        if wren_chip_1 = '1' then
           case select_chip_1
        else
           
        end if;
      end if;
   end process;
   
   read_write_reg_bank_2 : process()
   begin
      if rst = '1' then
         -- default value --
         chip_2_reg_00 =>  X"DE";
         chip_2_reg_01 =>  X"60"; 
         chip_2_reg_02 =>  X"28";
         chip_2_reg_03 =>  X"00";
         chip_2_reg_04 =>  X"00";
         chip_2_reg_05 =>  X"00";
         chip_2_reg_06 =>  X"00";
         chip_2_reg_07 =>  X"00";
         chip_2_reg_08 =>  X"26";
         chip_2_reg_09 =>  X"1A";
         chip_2_reg_10 =>  X"05";
         chip_2_reg_11 =>  X"1F";
         chip_2_reg_12 =>  X"16";
         chip_2_reg_13 =>  X"7C";
         chip_2_reg_14 =>  X"FF";
         chip_2_reg_15 =>  X"FF";
         chip_2_reg_16 =>  X"FF";
         chip_2_reg_17 =>  X"FF";
      elsif m_clk'event and m_clk = '1' then
        if wren_chip_1 = '1' then
           case select_chip_1
        else
           
        end if;
      end if;
   end process;
   
END behav;


