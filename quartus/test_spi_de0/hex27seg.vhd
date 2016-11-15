---------------------------------------------------------
-- hex27seg
-- creacion 20/08/16
-- modificado de bcd27seg
-- seg_out(6 downto 0)= abcdefg
---------------------------------------------------------

-----------------------------------------------------------
----- PACKAGE pk_bcd27seg
-----------------------------------------------------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

PACKAGE pk_hex27seg IS
   COMPONENT hex27seg IS
   	PORT(
         hex_in     : IN  STD_LOGIC_VECTOR(3 downto 0);
   		 seg_out    : OUT STD_LOGIC_VECTOR(6 downto 0)
   		);
   END COMPONENT;
END PACKAGE;

-----------------------------------------------------------
----- ENTITY bcd27seg
-----------------------------------------------------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


ENTITY hex27seg IS
   	PORT(
         hex_in    : IN  STD_LOGIC_VECTOR(3 downto 0);
   		seg_out    : OUT STD_LOGIC_VECTOR(6 downto 0)
   		);
END hex27seg;


ARCHITECTURE synth of hex27seg IS

--constants

--                 "abcdefg"
CONSTANT cero   : std_logic_vector(6 DOWNTO 0):= "0000001";
CONSTANT uno	: std_logic_vector(6 DOWNTO 0):= "1001111";
CONSTANT dos	: std_logic_vector(6 DOWNTO 0):= "0010010";
CONSTANT tres	: std_logic_vector(6 DOWNTO 0):= "0000110";
CONSTANT cuatro : std_logic_vector(6 DOWNTO 0):= "1001100";
CONSTANT cinco	: std_logic_vector(6 DOWNTO 0):= "0100100";
CONSTANT seis	: std_logic_vector(6 DOWNTO 0):= "0100000";
CONSTANT siete	: std_logic_vector(6 DOWNTO 0):= "0001101";
CONSTANT ocho	: std_logic_vector(6 DOWNTO 0):= "0000000";
CONSTANT nueve	: std_logic_vector(6 DOWNTO 0):= "0000100";
CONSTANT A  : std_logic_vector(6 DOWNTO 0):= "0001000";
CONSTANT b	: std_logic_vector(6 DOWNTO 0):= "1100000";
CONSTANT C	: std_logic_vector(6 DOWNTO 0):= "0110001";
CONSTANT d	: std_logic_vector(6 DOWNTO 0):= "1000010";
CONSTANT E	: std_logic_vector(6 DOWNTO 0):= "0110000";
CONSTANT F	: std_logic_vector(6 DOWNTO 0):= "0111000";


BEGIN
 
--***********
seg_decoder:
--***********
PROCESS (hex_in)
BEGIN
   CASE hex_in IS
      WHEN X"0" => 
         seg_out <= cero;
      WHEN X"1" => 
         seg_out <= uno;
      WHEN X"2" => 
         seg_out <= dos;
      WHEN X"3" => 
         seg_out <= tres; 
      WHEN X"4" => 
         seg_out <= cuatro;
      WHEN X"5" => 
         seg_out <= cinco;
      WHEN X"6" => 
         seg_out <= seis;
      WHEN X"7" => 
         seg_out <= siete;
      WHEN X"8" => 
         seg_out <= ocho;
      WHEN X"9" => 
         seg_out <= nueve;
      WHEN X"A" => 
         seg_out <= A;
      WHEN X"B" => 
         seg_out <= b;
      WHEN X"C" => 
         seg_out <= C;
      WHEN X"D" => 
         seg_out <= d;
      WHEN X"E" => 
         seg_out <= E;
      WHEN X"F" => 
         seg_out <= F;   		 
   END CASE;
  
END PROCESS;

END synth;

