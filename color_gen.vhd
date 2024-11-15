library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity color_gen is
  port (
    clk : in std_logic;
    col : in std_logic_vector(11 downto 0);
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
      Rout <= col(11) & col(11) & col(10) & col(10) & col(9) & col(9) & col(8) & col(8);
      Gout <= col(7) & col(7) & col(6) & col(6) & col(5) & col(5) & col(4) & col(4);
      Bout <= col(3) & col(3) & col(2) & col(2) & col(1) & col(1) & col(0) & col(0);
    end if;
  end process;

end Behavioral;