library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity color_gen is
  port (
    clk : in std_logic;
    col : in std_logic_vector(3 downto 0);
    Rout : out std_logic_vector(7 downto 0);
    Bout : out std_logic_vector(7 downto 0);
    Gout : out std_logic_vector(7 downto 0)
  );
end color_gen;

architecture Behavioral of color_gen is
begin
  process(clk)
  begin
    if (clk'Event and clk = '1') then
      Rout <= (others => col(3));
      Gout <= (others => col(2));
      Bout <= (others => col(1));
        end if;
  end process;

end Behavioral;