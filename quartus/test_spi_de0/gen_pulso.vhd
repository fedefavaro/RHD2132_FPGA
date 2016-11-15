LIBRARY ieee ;
USE ieee.std_logic_1164.all;

package PK_GEN_PULSO is
	component GEN_PULSO is
	   port(
		  clk             : in std_logic; -- clk
		  reset           : in std_logic; -- reset
		  input           : in std_logic; -- input
		  edge_detected   : out std_logic   -- edge_detected: pulso a 1 cuando 
								 -- se detecta flanco en input
	  );
	end component;
end PK_GEN_PULSO;

LIBRARY ieee ;
USE ieee.std_logic_1164.all;
entity GEN_PULSO is
   port(
      clk             : in std_logic; -- clk
      reset           : in std_logic; -- reset
      input           : in std_logic; -- input
      edge_detected   : out std_logic   -- edge_detected: pulso a 1 cuando
                                 -- se detecta flanco en input
      );
end;
architecture BEHAV of GEN_PULSO is
-- states
      type state_type IS
        (st_espero0, st_espero1, st_flanco_detectado);
      attribute enum_encoding : string;
      attribute enum_encoding of state_type : type is "one-hot"; -- "default", "sequential", "gray", "johnson", or "one-hot"
      signal STATE, NXSTATE : state_type;
      -- info sobre codificación: http://quartushelp.altera.com/13.0/mergedProjects/hdl/vhdl/vhdl_file_dir_enum_encoding.htm
        
      --- CONSTANT st_espero0 : std_logic_vector(1 DOWNTO 0):= "00";
      --- CONSTANT st_espero1 : std_logic_vector(1 DOWNTO 0):= "01";
      --- CONSTANT st_flanco_detectado : std_logic_vector(1 DOWNTO 0):= "11";
      --- signal STATE, NXSTATE : std_logic_vector(1 DOWNTO 0);
      
begin

 -- Process donde se genera la salida
 -- dependiente de estado y entrada
 -- y proximo estado.
   combin: process (STATE, input)
   begin
      case STATE is
         when st_espero0 =>
            if input ='1' then
               NXSTATE <= st_espero0;
            else
               NXSTATE <= st_espero1;
            end if;
            edge_detected <= '0';

         when st_espero1 =>
            if input ='0' then
               NXSTATE <= st_espero1;
            else
               NXSTATE <= st_flanco_detectado;
            end if;
            edge_detected <= '0';            

         when st_flanco_detectado =>
            if input ='0' then
               NXSTATE <= st_espero1;
            else
               NXSTATE <= st_espero0;
            end if;
            edge_detected <= '1';

        when others =>     
            NXSTATE <= st_espero1;
            edge_detected <= '0';

      end case;
   end process;
   
   -- Process donde se generan los FF
   -- sensibles a flanco
   -- de subida de la mÃ¡quina de estado
   sync:process (clk,reset,STATE)
   begin
     if reset = '1' then
       STATE <= st_espero1;
     elsif clk'event and clk = '1' then
       STATE <= NXSTATE;
     end if;
   end process;
end BEHAV;
