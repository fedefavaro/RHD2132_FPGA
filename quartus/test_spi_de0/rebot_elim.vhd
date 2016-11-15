---------------------------------------------------------
-- REBOT_ELIM
-- creacion 09/04/05
-- Circuito eliminador de rebotes
--
-- Circuito utilizado para generar pulsos mediante dos pulsadores.
-- Si la entrada Sn=0 ==> Q=0
-- Si la entrada Rn=0 ==> Q=1
-- Si Sn=Rn=1 se mantiene el valor de Q
-- Sn = 0 tiene prioridad sobre Rn = O
--
---------------------------------------------------------


---------------------------------------------------------
----- package PK_REBOT_ELIM
---------------------------------------------------------

LIBRARY ieee ;
USE ieee.std_logic_1164.all;

PACKAGE pk_rebot_elim IS
   COMPONENT rebot_elim is
     PORT(
        Sn, Rn : in std_logic;
        Q   : out std_logic
        );
   END COMPONENT;     
END PACKAGE;




-----------------------------------------------------------
----- ENTITY REBOT_ELIM
-----------------------------------------------------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all;

entity rebot_elim is
  port(
     Sn, Rn : in std_logic;
     Q   : out std_logic
     );
end rebot_elim;

architecture BEHAV of rebot_elim is

begin

---------------------------------------
eliminador_de_rebotes: process (Sn, Rn)
---------------------------------------
   begin
      if (Sn = '0') then
         Q <= '1';      
      elsif (Rn = '0') then
         Q <= '0';
      end if;
end process;   


end BEHAV; 