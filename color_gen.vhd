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
      case col is
        when "0000" =>
          Rout <= "00000000";
          Gout <= "11111111";
          Bout <= "00000000";

        when "0001" =>
          Rout <= "11111111";
          Gout <= "11111111";
          Bout <= "11111111";

        when "0010" =>
          Rout <= "11111111";
          Gout <= "00000000";
          Bout <= "00000000";

        when "0011" =>
          Rout <= "00000000";
          Gout <= "00000000";
          Bout <= "11111111";

        when "0100" =>
          Rout <= "11111111";
          Gout <= "11111111";
          Bout <= "00000000";

        when others =>
          Rout <= "00000000";
          Gout <= "00000000";
          Bout <= "00000000";
      end case;
    end if;
  end process;

end Behavioral;