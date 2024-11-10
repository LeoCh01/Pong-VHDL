library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity VideoGame is
  port (
    clk : in  std_logic;
    DAC_CLK : out std_logic;
    p1 : in std_logic;
    p2 : in std_logic;
    hsync : out std_logic;
    vsync : out std_logic;
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
  constant block_size : integer := 32;
  signal hpos : integer := 0;
  signal vpos : integer := 0;
  signal video_strb : std_logic := '0';
  signal clk2 : std_logic;

  -- ball
  constant br : integer := 10;
  constant vel : integer := 2;
  constant offset : integer := 4;
  signal bx : integer := 320;
  signal by : integer := 240;
  signal bx_dir : integer := 2;
  signal by_dir : integer := 2;
  
  -- paddle
  constant pw : integer := 5;
  constant ph : integer := 40;
  signal p1x : integer := 75;
  signal p1y : integer := 240;
  signal p2x : integer := 565;
  signal p2y : integer := 240;

  type game_state is (START, RUN, FIN);
  signal current_state : game_state := START;

  type vec2 is array (14 downto 0, 19 downto 0) of integer;
  signal gx : integer := 0;
  signal gy : integer := 0;
  signal grid : vec2 := (
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0),
    (0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0),
    (0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0),
    (0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0),
    (0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0),
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
      col => col,
      Rout => Rout, 
      Bout => Bout,
      Gout => Gout
    );

---------------------------------------------------------
-- process
---------------------------------------------------------

  process(clk)
  begin
    if (clk'Event and clk='1') then
      clk2 <= not clk2;
    DAC_CLK <= clk2;
    end if;
  end process;


  process(clk2)
  begin
    if (clk2'Event and clk2='1') then

      if (((640 + 16) <= hpos) and (hpos < (640 + 16 + 96))) then
        hsync <= '1';
      else
        hsync <= '0';
      end if;
      
      if (((480 + 10) <= vpos) and (vpos < (480 + 10 + 2))) then
        vsync <= '1';
      else
        vsync <= '0';
      end if;

      if (hpos = (640 + 16 + 96 + 48)) then
        hpos <= 0;
      else
        hpos <= hpos + 1;
      end if;
    
      if (vpos = (480 + 10 + 2 + 33)) then
        vpos <= 0;
        video_strb <= '1';
      elsif (hpos = (640 + 16 + 96 + 48)) then
        vpos <= vpos + 1;
        video_strb <= '0';
      end if;


      if ((bx - br) <= hpos and hpos <= (bx + br) and (by - br) <= vpos and vpos <= (by + br)) then
        col <= "110";
      elsif ((p1x - pw) <= hpos and hpos <= (p1x + pw) and (p1y - ph) <= vpos and vpos <= (p1y + ph)) then
        col <= "100";
      elsif ((p2x - pw) <= hpos and hpos <= (p2x + pw) and (p2y - ph) <= vpos and vpos <= (p2y + ph)) then
        col <= "001";
      else
        gx <= hpos / block_size;
        gy <= vpos / block_size;

        if (gx <= 20 and gy <= 15) then
          if (grid(gy, gx) = 1) then
            col <= "111";
          else
            col <= "010";
          end if;
        else 
          col <= "000";
        end if;
      end if;
    end if;
  end process;
  
  process(video_strb)
  begin
    if (video_strb'Event and video_strb='1') then
      case current_state is
        when START =>
          bx <= 320;
          by <= 240;
          current_state <= RUN;

        when RUN =>
          if (grid((by + br) / block_size, (bx - br - offset) / block_size) = 1 or grid((by - br) / block_size, (bx - br - offset) / block_size) = 1) then
            bx_dir <= vel;
            bx <= vel;
          end if;
          if (grid((by + br) / block_size, (bx + br + offset) / block_size) = 1 or grid((by - br) / block_size, (bx + br + offset) / block_size) = 1) then
            bx_dir <= -vel;
            bx <= -vel;
          end if;
          if (grid((by - br - offset) / block_size, (bx + br) / block_size) = 1 or grid((by - br - offset) / block_size, (bx - br) / block_size) = 1) then
            by_dir <= vel;
            by <= vel;
          end if;
          if (grid((by + br + offset) / block_size, (bx + br) / block_size) = 1 or grid((by + br + offset) / block_size, (bx - br) / block_size) = 1) then
            by_dir <= -vel;
            by <= -vel;
          end if;
          
          bx <= bx + bx_dir;
          by <= by + by_dir;
        when FIN =>
      end case;
    end if;
  end process;
end Behavioral;