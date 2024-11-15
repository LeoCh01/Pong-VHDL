library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity VideoGame is
  port (
    clk : in  std_logic;
    DAC_CLK : out std_logic;
    p1 : in std_logic;
    p2 : in std_logic;
	 reset : in std_logic;
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
      col : in std_logic_vector(11 downto 0);
      Rout : out std_logic_vector(7 downto 0);
      Bout : out std_logic_vector(7 downto 0);
      Gout : out std_logic_vector(7 downto 0)
    );
  end component;

---------------------------------------------------------
-- signals
---------------------------------------------------------
  signal col : std_logic_vector(11 downto 0);
  constant block_size : integer := 32;
  signal hpos : integer := 0;
  signal vpos : integer := 0;
  signal video_strb : std_logic := '0';
  signal clk2 : std_logic := '0';
  signal winner : integer := 1;
  signal sleep : integer := 0;
  signal test : std_logic := '0';

  -- ball
  constant br : integer := 7;
  constant vel : integer := 3;
  signal bx : integer := 320;
  signal by : integer := 240;
  signal bx_dir : integer := vel;
  signal by_dir : integer := vel;
  signal is_col : integer := 0;
  
  -- paddle
  constant pw : integer := 5;
  constant ph : integer := 40;
  constant p1x : integer := 75;
  signal p1y : integer := 240;
  constant p2x : integer := 565;
  signal p2y : integer := 240;

  type game_state is (START, RUN, FIN, GONE);
  signal current_state : game_state := START;

  type vec2 is array (14 downto 0, 19 downto 0) of integer;
  signal gx : integer := 0;
  signal gy : integer := 0;
  signal grid : vec2 := (
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0),
    (2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2),
    (2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2),
    (2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2),
    (2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2),
    (2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2),
    (2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2),
    (2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0),
    (0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0),
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
  );

  signal is_face : integer := 0;
  signal grid_face : vec2 := (
    (2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2),
    (2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2),
    (2, 2, 2, 2, 2, 3, 3, 3, 2, 2, 2, 2, 2, 3, 3, 3, 2, 2, 2, 2),
    (2, 2, 2, 2, 3, 2, 2, 2, 3, 2, 2, 2, 3, 2, 2, 2, 3, 2, 2, 2),
    (2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2),
    (2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2),
    (2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2),
    (2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2),
    (2, 2, 2, 3, 2, 2, 3, 3, 3, 2, 2, 3, 2, 2, 3, 3, 3, 2, 2, 2),
    (2, 2, 2, 3, 2, 2, 2, 2, 3, 2, 2, 3, 2, 2, 2, 2, 3, 2, 2, 2),
    (2, 2, 2, 3, 2, 2, 2, 2, 3, 2, 2, 3, 2, 2, 2, 2, 3, 2, 2, 2),
    (2, 2, 2, 2, 3, 2, 2, 2, 3, 2, 2, 2, 3, 2, 2, 2, 3, 2, 2, 2),
    (2, 2, 2, 2, 2, 3, 3, 3, 2, 2, 2, 2, 2, 3, 3, 3, 2, 2, 2, 2),
    (2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2),
    (2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2)
  );
  signal cell : integer := 0;

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
        hsync <= '0';
      else
        hsync <= '1';
      end if;
      
      if (((480 + 10) <= vpos) and (vpos < (480 + 10 + 2))) then
        vsync <= '0';
        test <= '1';
      else
        vsync <= '1';
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
        if (current_state = FIN) then
          col <= "111100000000";
        else
          col <= "111111110000";
        end if;
      elsif ((p1x - pw) <= hpos and hpos <= (p1x + pw) and (p1y - ph) <= vpos and vpos <= (p1y + ph)) then
        col <= "111100000000";
      elsif ((p2x - pw) <= hpos and hpos <= (p2x + pw) and (p2y - ph) <= vpos and vpos <= (p2y + ph)) then
        col <= "000000001111";
      else
        gx <= hpos / block_size;
        gy <= vpos / block_size;

        if (gx < 20 and gy < 15) then

          cell <= grid(gy, gx);
          if (is_face = 1) then
            cell <= grid_face(15 - 1 - gy, 20 - 1 - gx) * winner;
          end if;

          case cell is
            when 0 =>
              if ((gx + gy) mod 2 = 0) then
                col <= "000011110000";
              else
                col <= "000010110000";
              end if;
            when 1 => 
              col <= "111111111111";
            when 2 => 
              if ((gx + gy) mod 2 = 0) then
                col <= "000011110000";
              else
                col <= "000010110000";
              end if;
            when 3 => 
              col <= "000000001111";
            when 4 =>
              if ((gx + gy) mod 2 = 0) then
                col <= "000011110000";
              else
                col <= "000010110000";
              end if;
            when 6 =>
              col <= "111100000000";
            when others =>
              col <= "000000000000";
          end case;
        else 
          col <= "000000000000";
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
          p1y <= 240;
          p2y <= 240;
          is_face <= 0;
          
          if (sleep = 0) then
            sleep <= 50;
          else
            sleep <= sleep - 1;
            if (sleep = 1) then
              current_state <= RUN;
            end if;
          end if;

        when RUN =>

          -- reset 
          if (reset = '1') then
            current_state <= START;
          end if;

          -- paddle movement
          if (p1 = '1') then
            p1y <= p1y - vel;
          else
            p1y <= p1y + vel;
          end if;

          if (p2 = '1') then
            p2y <= p2y - vel;
          else
            p2y <= p2y + vel;
          end if;

          -- paddle restrictions
          if ((p1y + ph + vel) > 480 - (block_size * 2)) then
            p1y <= 480 - (block_size * 2) - ph - vel;
          elsif ((p1y - ph - vel) < (block_size * 2)) then
            p1y <= (block_size * 2) + ph + vel;
          end if;

          if ((p2y + ph + vel) > 480 - (block_size * 2)) then
            p2y <= 480 - (block_size * 2) - ph - vel;
          elsif ((p2y - ph - vel) < (block_size * 2)) then
            p2y <= (block_size * 2) + ph + vel;          
          end if;

          -- ball movement
          bx <= bx + bx_dir;
          by <= by + by_dir;
          
          -- ball-paddle collision
          if ((p1x - pw) <= (bx - br - vel) and (bx - br - vel) <= (p1x + pw) and (p1y - ph) <= (by + br + vel) and (by - br - vel) <= (p1y + ph)) then
            bx_dir <= vel;
            bx <= bx + vel;
          end if;

          if ((p2x - pw) <= (bx + br + vel) and (bx + br + vel) <= (p2x + pw) and (p2y - ph) <= (by + br + vel) and (by - br - vel) <= (p2y + ph)) then
            bx_dir <= -vel;
            bx <= bx - vel;
          end if;
                 
          -- ball-wall collision
          if (grid((by + br) / block_size, (bx - br - vel) / block_size) = 1 or grid((by - br) / block_size, (bx - br - vel) / block_size) = 1) then
            bx_dir <= vel;
            bx <= bx + vel;
          end if;
          if (grid((by + br) / block_size, (bx + br + vel) / block_size) = 1 or grid((by - br) / block_size, (bx + br + vel) / block_size) = 1) then
            bx_dir <= -vel;
            bx <= bx - vel;
          end if;
          if (grid((by - br - vel) / block_size, (bx + br) / block_size) = 1 or grid((by - br - vel) / block_size, (bx - br) / block_size) = 1) then
            by_dir <= vel;
            by <= by + vel;
          end if;
          if (grid((by + br + vel) / block_size, (bx + br) / block_size) = 1 or grid((by + br + vel) / block_size, (bx - br) / block_size) = 1) then
            by_dir <= -vel;
            by <= by - vel;
          end if;

          -- score
          if (grid((by + br) / block_size, (bx - br) / block_size) = 2 or grid((by - br) / block_size, (bx - br) / block_size) = 2) then
            current_state <= FIN;
            winner <= 1;
          end if;

          if (grid((by + br) / block_size, (bx + br) / block_size) = 2 or grid((by - br) / block_size, (bx + br) / block_size) = 2) then
            current_state <= FIN;
            winner <= 2;
          end if;

        when FIN =>
          bx <= bx + bx_dir;
          by <= by + by_dir;

          if (sleep = 0) then
            sleep <= 50;
          else
            sleep <= sleep - 1;
            if (sleep = 1) then
              current_state <= GONE;
            end if;
          end if;  
        
        when GONE =>
        is_face <= 1;
        if (sleep = 0) then
				bx_dir <= -bx_dir;
            by <= -100;
				p1y <= -100;
				p2y <= -100;
            sleep <= 25;
          else
            sleep <= sleep - 1;
            if (sleep = 1) then
              current_state <= START;
            end if;
          end if;
      end case;
    end if;
  end process;
end Behavioral;