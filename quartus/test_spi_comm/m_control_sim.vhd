-----------------------------------------------------------------------------------------------------------------------
-- Author:
-- 
-- Create Date:		12/11/2016  -- dd/mm/yyyy
-- Module Name:		m_control_sim
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description: 
--
--		Este bloque simula la operacion del bloque master_control en cuanto al envio de palabras a los spi.
--		Si recibe un flanco en la entrada send_1_i(send_2_i), en el proximo flanco de reloj carga un dato 
--		en la salida mc_do_1_o(mc_do_2_o) y en el siguiente flanco de reloj da un pulso de 1 Tclk en
--		la salida mc_wren_1_o(mc_wren_2_o).
--		Las entradas send_1_i y send_2_i no pueden estar activas a la vez.
--      
-----------------------------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
LIBRARY lpm;
USE lpm.lpm_components.ALL;

ENTITY m_control_sim IS
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
END m_control_sim;


ARCHITECTURE behav OF m_control_sim IS

-- regs
signal sg_do_1, sg_do_2 : std_logic_vector(15 downto 0);
signal sg_counter_1, sg_counter_2 : std_logic_vector(15 downto 0);

-- states
  --type state_type IS (st_init, st_wait0, st_wait1, st_delay1, st_send);
  type state_type IS (st_wait0, st_wait1, st_delay1, st_send);
  attribute enum_encoding : string;
  attribute enum_encoding of state_type : type is "one-hot";
  signal STATE, NXSTATE : state_type;
     
BEGIN

   state_machine:process (m_clk, m_reset, STATE, send_1_i, send_2_i)
   begin
      if m_reset = '1' then
         --STATE <= st_init;
         STATE <= st_wait1;
      elsif m_clk'event and m_clk = '1' then
        case STATE is
           --when st_init =>
              --sg_counter_1 <= X"A000";
              --sg_counter_2 <= X"B000";
              --STATE <= st_wait1;
              --mc_wren_1_o <= '0';
              --mc_wren_2_o <= '0';
           when st_wait1 =>
              if (send_1_i ='1' and send_2_i ='0') or (send_1_i ='0' and send_2_i ='1') then
                 STATE <= st_delay1;
                 --sg_do_1 <= sg_counter_1;
              --elsif send_1_i ='0' and send_2_i ='1' then
              --   STATE <= st_delay1;
                 --sg_do_2 <= sg_counter_2;
              else
                 STATE <= st_wait1;
              end if;
              --mc_wren_1_o <= '0';
              --mc_wren_2_o <= '0';
           when st_delay1 =>
              STATE <= st_send;
           when st_send =>
              STATE <= st_wait0;
              --if send_1_i ='1' and send_2_i ='0' then
                 --sg_counter_1 <= sg_counter_1 + 1;
                 --mc_wren_1_o <= '1';
                 --mc_wren_2_o <= '0';
              --elsif send_1_i ='0' and send_2_i ='1' then
                 --sg_counter_2 <= sg_counter_2 + 1;
                 --mc_wren_1_o <= '0';
                 --mc_wren_2_o <= '1';
              --else
                 --mc_wren_1_o <= '0';
                 --mc_wren_2_o <= '0';
              --end if;
           when st_wait0 =>
              if send_1_i ='1' or send_2_i ='1' then
                 STATE <= st_wait0;
              else
                 STATE <= st_wait1;
              end if;
              --mc_wren_1_o <= '0'; 
              --mc_wren_2_o <= '0';           
           when others =>     
             -- STATE <= st_init;
              STATE <= st_wait1;
              --mc_wren_1_o <= '0';
              --mc_wren_2_o <= '0';
         end case;
      end if;
   end process;
   
   
   counters:process (m_reset, m_clk, STATE, send_1_i, send_2_i)
   begin
      if m_reset = '1' then
         sg_counter_1 <= X"0000";
         sg_counter_2 <= X"0000";
      elsif m_clk'event and m_clk = '1' then
         if STATE = st_send and send_1_i ='1' and send_2_i ='0' then
            if sg_counter_1 = X"FFFF" then
			   sg_counter_1 <= X"0000";
			else
			   sg_counter_1 <= sg_counter_1 + 1;
			end if;
         elsif STATE = st_send and send_1_i ='0' and send_2_i ='1' then
            if sg_counter_2 = X"FFFF" then
			   sg_counter_2 <= X"0000";
			else
               sg_counter_2 <= sg_counter_2 + 1;
            end if;
         end if;
      end if;
   end process;
  
   
   output_registers:process (m_reset, m_clk, STATE, send_1_i, send_2_i)
   begin
      if m_reset = '1' then
         sg_do_1 <= X"0000";
         sg_do_2 <= X"0000";
      elsif m_clk'event and m_clk = '1' then
        if STATE = st_wait1 and send_1_i ='1' and send_2_i ='0' then
           sg_do_1 <= sg_counter_1;
        elsif STATE = st_wait1 and send_1_i ='0' and send_2_i ='1' then
           sg_do_2 <= sg_counter_2;
        end if;
      end if;
   end process;
   
   outputs:process (STATE, send_1_i, send_2_i)
   begin
        case STATE is
           when st_wait1 =>
              mc_wren_1_o <= '0';
              mc_wren_2_o <= '0';
           when st_delay1 =>
              mc_wren_1_o <= '0';
              mc_wren_2_o <= '0';
           when st_send =>
              if send_1_i ='1' and send_2_i ='0' then
                 mc_wren_1_o <= '1';
                 mc_wren_2_o <= '0';
              elsif send_1_i ='0' and send_2_i ='1' then
                 mc_wren_1_o <= '0';
                 mc_wren_2_o <= '1';
              else
                 mc_wren_1_o <= '0';
                 mc_wren_2_o <= '0';
              end if;
           when st_wait0 =>
              mc_wren_1_o <= '0'; 
              mc_wren_2_o <= '0';           
           when others =>     
              mc_wren_1_o <= '0';
              mc_wren_2_o <= '0';
         end case;
   end process;
   
   mc_do_1_o <= sg_do_1;
   mc_do_2_o <= sg_do_2;
   
   mc_rdreq_1_o <= '0';
   mc_rdreq_2_o <= '0';
	
END behav;