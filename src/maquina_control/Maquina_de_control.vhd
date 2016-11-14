LIBRARY ieee ;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

PACKAGE pk_Maquina_de_Control IS
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
END PACKAGE;

-----------------------------------------------------------
----- Primer nivel de maquina de estado
-----------------------------------------------------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


ENTITY Maquina_de_Control IS
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
          WE_out                    : OUT STD_LOGIC;                     -- Senal de control que indica que esta pronto para enviar el dato
      
          --- debug signals ---
          dbg_cont_CLK              : OUT STD_LOGIC_vector (7 downto 0);
          dbg_cont_comand           : OUT STD_LOGIC_vector (7 downto 0)
      );
END Maquina_de_Control;


ARCHITECTURE func of Maquina_de_Control IS

constant cte_end_cont_CLK: integer := 14;                        --Constate que me indica el numero de pulsos final del ciclo de envio al SPI
constant cte_comando_dummy: std_logic_vector (15 downto 0):= X"0E80"; --Dummy: Read(40) --> 11RRRRRR00000000 --> 40d = 101000


signal sg_cont_CLK                  : STD_LOGIC_vector (7 downto 0);--:="00000"; -- @ff: No es necesario inicilizar
signal sg_cont_comand               : STD_LOGIC_vector (7 downto 0);--:="00000"; -- @ff: Cambio a 8 bits por comodidad
--signal sg_proceso                   : STD_LOGIC:='0'; --Senal que me indica que estoy recorriendo una rama de la maquina de estados

signal sg_reg_envio_out             : STD_LOGIC_VECTOR(15 downto 0);

-- Declaracion de estados
      type state_type IS
        (st_IDLE,
         st_LOAD_PARAM, st_LOAD_PARAM_wren,  st_LOAD_PARAM_waitACK, st_LOAD_PARAM_cuento,
         st_START,
         st_STOP,
         st_SEND_COMMAND, st_SEND_COMMAND_wren,  st_SEND_COMMAND_waitACK, st_SEND_COMMAND_cuento,
         st_CALIBRATE); --st_GET_TEMP por el momento no lo pongo
      attribute enum_encoding : string;
      attribute enum_encoding of state_type : type is "one-hot"; -- @ff: hot hot hot
      signal STATE, NXSTATE : state_type; -- @ff: inicializo con reset!! := st_IDLE; --Inicializo en IDLE
      
BEGIN

----------------------------------------------------------------------------------------------------------
---- MAQUINA DE ESTADOS ----------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
-- Proceso que asocia senales de salida a los estados
Maquina_de_estados:process (STATE, ack_in, reg_func_in, sg_cont_CLK, sg_cont_comand,reg_send_com_in )
begin
    --reg_func_out <= "11111111";   -- @ff: Esto no tiene sentido aca adentro
    --if sg_proceso='0' then        -- @ff: Esto me parece que no se necesita, por ahora lo saco
    -- case reg_func_in is          -- @ff: Se diferencia primero segun el estado actual
    case STATE is
       ----------------------------------------------------------------------------------------------------------
       ---- Estado PADRE/MADRE ----------------------------------------------------------------------------------
       ----------------------------------------------------------------------------------------------------------
       when st_IDLE =>
          case reg_func_in is       -- @ff: Ahora si puedo saltar de estado segun el valor del registro
             when X"00" =>          -- @ff: Lo pongo es hexa es mas entendible
               NXSTATE <= st_IDLE;
               --sg_proceso<='0';
             when X"01" =>
               NXSTATE <= st_LOAD_PARAM;
               --sg_proceso<='1';
             when X"02" =>
               NXSTATE <= st_START;
               --sg_proceso<='1';
             when X"04" =>
               NXSTATE <= st_STOP;
               --sg_proceso<='1';  
             when X"08" =>
               NXSTATE <= st_SEND_COMMAND;
               --sg_proceso<='1';  
             when X"10" =>
               NXSTATE <= st_CALIBRATE;
               --sg_proceso<='1';    
             when others =>
               NXSTATE <= st_IDLE;  --En transiciones o casos no especificados vuelvo a idle
               --sg_proceso<='0';
          end case;
          -- outputs
          WE_out <= '0';   -- @ff: Las salidas tienen que tener valor en todos los estados sino las latchea! 
    
    --else --sg_proceso='1'
    --case STATE is
    
    ----- @ff: Aca continua el case STATE inicial (agrego un estado) -----
       ----------------------------------------------------------------------------------------------------------
       ---- Rama SEND_COMMAND -----------------------------------------------------------------------------------
       ----------------------------------------------------------------------------------------------------------
       -- @ff: Creo que no es sano cargar el dato a la salida al mismo tiempo que mandas
       --      el wren. Tenes que mandar el wren por lo menos un flanco despues. Por esto
       --      cargo el dato en el estado Idle y doy el wren en el siguiente estado.
       --
       --      Ademas, por lo que te dije de los contadores y los registros cambie un poco
       --      la cosa. Es muy tentador hacer esto: "sg_cont_CLK <= "00000" pero asi nomas
       --      no significa nada. Hay que definir los registros y demas, lo hago mas abajo.
       
       -- @ff: Este estado me da el delay que necesito entre cargar el dato y el wren.
       --      En este estado se reinicia el contador de comandos enviados.
       when st_SEND_COMMAND =>
          NXSTATE <= st_SEND_COMMAND_wren;
          -- outputs
          WE_out <= '0';
       
       -- @ff: Este estado manda el pulso en WE_out
       --      En este estado se reinicia el contador clocks
       when st_SEND_COMMAND_wren =>
          --reg_envio_out <= reg_send_com_in;      
          --sg_cont_CLK <= "00000";                -- Inicio los contadores
          --sg_cont_comand <= "00000";
          --if ack_in = '1' then                   -- Cuando llega ACK 
          --   NXSTATE <= st_SEND_COMMAND_cuento;   
          --else
          --   NXSTATE <= st_SEND_COMMAND;
          --end if;
          NXSTATE <= st_SEND_COMMAND_waitACK;
          -- outputs
          WE_out <= '1';
       
       -- @ff: Este estado espera por el ack del bloque spi. Si el ack que llega es el ultimo
       --      entonces vuelve al estado IDLE.
       when st_SEND_COMMAND_waitACK =>
          if ack_in='1' then 
             if sg_cont_comand < 3 then      -- Si me llega a contar y todavia no termine con los dummys vuelvo a contar
                NXSTATE <= st_SEND_COMMAND_cuento;
             else
                NXSTATE <= st_IDLE;          -- @ff: Para volver a idle alguien tiene que limpiar el contenido de reg_func_in
             end if;
          else -- ack_in='0'                 -- Espero hasta que llegue ACK
             NXSTATE <= st_SEND_COMMAND_waitACK;
          end if;
          -- outputs
          WE_out <= '0';  
       
       -- @ff: Este estado espera 
       --      En este estado se reinicia el contador clocks
       when st_SEND_COMMAND_cuento =>
          --sg_cont_CLK <= sg_cont_CLK + 1;                
          if (sg_cont_CLK < cte_end_cont_CLK) then    --Si es menor a los CLKS q indica la cte sigo contando
             NXSTATE <= st_SEND_COMMAND_cuento;
          else
             --sg_cont_comand <= sg_cont_comand + 1;    -- Incremento el contador de datos enviados
             NXSTATE <= st_SEND_COMMAND_wren;
          end if;
          -- outputs
          WE_out <= '0';
        
  --     when st_SEND_COMMAND_envio => 
  --        reg_envio_out<= cte_comando_dummy;                         -- Envio el comando al registro de envio y reinicio el contador de CLK SPI
  --        WE_out<='1';  
  --        if (ack_in='1')and (sg_cont_comand<2) then                   -- Si me llega a contar y todavia no termine con los dummys vuelvo a contar
  --           NXSTATE <= st_SEND_COMMAND_cuento;
  --           sg_cont_CLK<="00000";
  --        elsif (ack_in='0')and (sg_cont_comand<2) then               -- Espero hasta q me llegue el ACK
  --           NXSTATE <= st_SEND_COMMAND_envio;
  --        elsif (ack_in='1')and (sg_cont_comand=2) then               -- Una vez haya mandado los dummys vuelvo a idle
  --           NXSTATE <= st_idle;
  --           reg_func_out<="00000000";
  --           sg_proceso<='0';
  --        else
  --          NXSTATE <= st_SEND_COMMAND_envio;
  --         end if;

       ----------------------------------------------------------------------------------------------------------
       ---- Rama st_LOAD_PARAM ----------------------------------------------------------------------------------
       ----------------------------------------------------------------------------------------------------------
       when st_LOAD_PARAM =>
          NXSTATE <= st_LOAD_PARAM_wren;
          -- outputs
          WE_out <= '0';

       when st_LOAD_PARAM_wren =>
          NXSTATE <= st_LOAD_PARAM_waitACK;
          -- outputs
          WE_out <= '1';
       
       when st_LOAD_PARAM_waitACK =>
          if ack_in='1' then 
             if sg_cont_comand < X"14" then
                NXSTATE <= st_LOAD_PARAM_cuento;
             else
                NXSTATE <= st_IDLE;
             end if;
          else -- ack_in='0'
             NXSTATE <= st_LOAD_PARAM_waitACK;
          end if;
          -- outputs
          WE_out <= '0';  
       
       when st_LOAD_PARAM_cuento =>
          if (sg_cont_CLK < cte_end_cont_CLK) then
             NXSTATE <= st_LOAD_PARAM_cuento;
          else
             NXSTATE <= st_LOAD_PARAM_wren;
          end if;
          -- outputs
          WE_out <= '0';
       
       ----------------------------------------------------------------------------------------------------------
       ---- Others ----------------------------------------------------------------------------------------------
       ----------------------------------------------------------------------------------------------------------
       when others =>
          NXSTATE <= st_IDLE;
          -- outputs
          WE_out <= '0';
          --reg_func_out<= "00000001";
         
    end case;
    --end if;
    
end process;
 
-- Proceso que sincroniza los estados
sincronismo:process (clk, reset, STATE, NXSTATE)   
   begin
     if reset = '1' then
       STATE <= st_IDLE;
     elsif clk'event and clk = '1' then
       STATE <= NXSTATE;
     end if;
   end process;
      
--Boton de Reset -- @ff: Que es esto?

----------------------------------------------------------------------------------------------------------
---- Salidas -------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
reg_envio_out <= sg_reg_envio_out;
reg_func_out <= X"00"; -- @ff: Esto iria conectado al registro que guarda el valor de retorno del coamndo enviado, por ahora lo manod a cero.

-- @ff: Los registros estan ordenados del 0 al 17 y luego de enviar un comando se incrementa el contador
--      de comandos en uno. Por lo tanto el selector del comandos coincide con el contador de comandos.
selec_load_param_1 <= sg_cont_comand;

--- dbg ---
dbg_cont_CLK <= sg_cont_CLK;
dbg_cont_comand <= sg_cont_comand;
--- dbg ---

----------------------------------------------------------------------------------------------------------
---- registros -------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

-- Contador de flancos de reloj
p_cont_CLK : process (reset, clk, STATE)
begin
  if reset = '1' then
     sg_cont_CLK <= X"00";
  elsif clk'event and clk = '1' then
     if (STATE = st_SEND_COMMAND_wren) or (STATE = st_LOAD_PARAM_wren) then
        sg_cont_CLK <= X"00";
     elsif (STATE = st_SEND_COMMAND_cuento) or (STATE = st_LOAD_PARAM_cuento)then
        sg_cont_CLK <= sg_cont_CLK + 1;
     --elsif --otros estados en lsoq ue uso el contador...
     end if;
  end if;
end process;

-- Contador de comandos enviados
p_cont_comand : process (reset, clk, STATE)
begin
  if reset = '1' then
     sg_cont_comand <= X"00";
  elsif clk'event and clk = '1' then
     if (STATE = st_SEND_COMMAND) or (STATE = st_LOAD_PARAM) then
        sg_cont_comand <= X"00";
     elsif (STATE = st_SEND_COMMAND_wren) or (STATE = st_LOAD_PARAM_wren) then
        sg_cont_comand <= sg_cont_comand + 1;
     --elsif --otros estados en los que uso el contador...
     end if;
  end if;
end process;

-- Registro que guarda el comando a enviar
p_reg_envio_out : process (reset, clk, STATE, NXSTATE)
begin
  if reset = '1' then
     sg_reg_envio_out <= X"0000";
  elsif clk'event and clk = '1' then
     --- Send command ---
     if (STATE = st_IDLE) and (reg_func_in = X"08") then
        sg_reg_envio_out <= reg_send_com_in;
     elsif (STATE = st_SEND_COMMAND_waitACK) and (ack_in = '1') then -- @ff: cargo el dummy antes de empezar a contar clks
        sg_reg_envio_out <= cte_comando_dummy;
     --- Load param ---
     elsif (STATE = st_IDLE) and (reg_func_in = X"01") then
        sg_reg_envio_out <= reg_load_param_1;
     elsif (STATE = st_LOAD_PARAM_waitACK) and (ack_in = '1') and (sg_cont_comand < X"12") then
        sg_reg_envio_out <= reg_load_param_1;
     elsif (STATE = st_LOAD_PARAM_waitACK) and (ack_in = '1') and (sg_cont_comand >= X"11") then
        sg_reg_envio_out <= cte_comando_dummy;
     --elsif --otros estados en los que uso el registro...
     end if;
  end if;
end process;
    
end func;
