library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity VideoGame is
  port (
    clk : in  STD_LOGIC;
  );
end VideoGame;

architecture Behavioral of VideoGame is
---------------------------------------------------------
-- Components
---------------------------------------------------------
  -- component SDRAM
  --   port (
  --     clka : in STD_LOGIC;
  --   );
  -- end component;

---------------------------------------------------------
-- signals
---------------------------------------------------------
  signal fps : integer := 0;
  signal Rout : STD_LOGIC_VECTOR(7 downto 0);
  signal Gout : STD_LOGIC_VECTOR(7 downto 0);
  signal Bout : STD_LOGIC_VECTOR(7 downto 0);

  signal ballX : integer := 0;
  signal ballY : integer := 0;
  signal ballXdir : integer := 0;
  signal ballYdir : integer := 0;

  type game_state is (START, RUN, FIN);
  signal current_state : game_state := START;
---------------------------------------------------------
-- port maps
---------------------------------------------------------
  -- begin
  -- SDRAM_inst : SDRAM port map (
  --   clka => clk,
  -- );

---------------------------------------------------------
-- process
---------------------------------------------------------
  process(clk)
    begin
    if (clk'Event and clk='1') then
      if (fps = 60) then
        fps <= 0;

        case game_state is
          when START =>
          when RUN =>
          when FIN =>
        end case;

      else
        fps <= fps + 1;
      end if;
    end if;

  end process;

end Behavioral;