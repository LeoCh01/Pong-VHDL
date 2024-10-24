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
  type vec2 is array (31 downto 0, 25 downto 0) of INTEGER;
  signal grid : array_2d := (
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0),
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0),
    (0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0),
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  );
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

  -- hpos counter
  process(clk)
    begin
      if (clk'Event and clk='1') then
        if (pos = HD + HFP + HSP + HBP) then
          hpos <= hpos + 1;
        else
          hpos = 0;
        end if;
      end if;
  end process;

  -- horizontal synch
  process(clk)
    begin
      if (clk'Event and clk='1') then
        if ((pos <= HD + HFP) || (hpos >= HD + HFP + HSP)) then
          hsync <= '1';
        else
          hsync = '0';
        end if;
      end if;
  end process;

  -- vpos counter
  -- vertical synch

  -- video_on process
  process(clk)
    begin
      if (clk'Event and clk='1') then
        if (hpos <= HD and vpos <= VD) then
          video_on <= '1';
        else
          video_on = '0';
        end if;
      end if;
  end process;

  -- draw
  process(clk)
    begin
      if (clk'Event and clk='1') then
      end if;
  end process;

end Behavioral;