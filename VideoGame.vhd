library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity VideoGame is
  port (
    clk : in  std_logic;
    DAC_CLK : in std_logic;
    p1 : in std_logic;
    p2 : in std_logic;
    h_sync : out std_logic;
    v_sync : out std_logic;
    Rout : out std_logic_vector(7 downto 0);
    Bout : out std_logic_vector(7 downto 0);
    Gout : out std_logic_vector(7 downto 0)
  );
end VideoGame;

architecture Behavioral of VideoGame is
---------------------------------------------------------
-- Components
---------------------------------------------------------
  component color_gen is
    port (
      clk : in std_logic;
      col : in std_logic_vector(3 downto 0);
      Rout : out std_logic_vector(7 downto 0);
      Bout : out std_logic_vector(7 downto 0);
      Gout : out std_logic_vector(7 downto 0)
    );
  end component;

---------------------------------------------------------
-- signals
---------------------------------------------------------
  signal col : std_logic_vector(3 downto 0);
  signal block_size : integer := 32;
  signal bx : integer := 0;
  signal by : integer := 0;
  signal bx_dir : integer := 0;
  signal by_dir : integer := 0;
  signal hpos : integer := 0;
  signal vpos : integer := 0;

  type game_state is (START, RUN, FIN);
  signal current_state : game_state := START;

  type vec2 is array (19 downto 0, 14 downto 0) of integer;
  signal gx : integer := 0;
  signal gy : integer := 0;
  signal grid : vec2 := (
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
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
  );
---------------------------------------------------------
-- port maps
---------------------------------------------------------
  begin
    color_gen_inst : color_gen port map (
      clk => clk,
      col => col;
      Rout => Rout; 
      Bout => Bout; 
      Gout => Gout;
    );

---------------------------------------------------------
-- process
---------------------------------------------------------
  process(clk)
  begin
    if (clk'Event and clk='1') then

      if ((640 + 16 <= hpos) && (hpos < 640 + 16 + 96)) then
        hsync <= '1';
      else
        hsync <= '0';
      end if;
      
      if ((480 + 10 <= vpos) && (vpos < 480 + 10 + 2)) then
        hsync <= '1';
      else
        hsync <= '0';
      end if;

      if (hpos = 640 + 16 + 96 + 48) then
        hpos <= 0;
      else
        hpos <= hpos + 1;
      end if;

      if (vpos = 480 + 10 + 2 + 33) then
        vpos <= 0;
      else
        vpos <= vpos + 1;
      end if;

      gx <= hpos / block_size;
      gy <= vpos / block_size;
      if (gx <= 20 && gy <= 15) then
        col <= std_logic_vector(to_unsigned(grid(gx, gy), 4));
      else 
        col <= "0000";
      end if;

      case game_state is
        when START =>
        when RUN =>
        when FIN =>
      end case;

    end if;
  end process;

end Behavioral;