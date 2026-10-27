library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TP1_EXO2 is
    Port (
        clk : in std_logic;

        P1 : in integer range 0 to 255;
        P2 : in integer range 0 to 255;
        P3 : in integer range 0 to 255;
        P4 : in integer range 0 to 255;
        P5 : in integer range 0 to 255;
        P6 : in integer range 0 to 255;
        P7 : in integer range 0 to 255;
        P8 : in integer range 0 to 255;
        P9 : in integer range 0 to 255;

        pixel_out : out integer range 0 to 255
    );
end TP1_EXO2;

architecture simple of TP1_EXO2 is

    signal somme : integer range 0 to 2550;

begin

    somme <= P1 + P2 + P3 + P4
           + 2*P5
           + P6 + P7 + P8 + P9;

    process(clk)
    begin
        if rising_edge(clk) then
            pixel_out <= somme / 10;
        end if;
    end process;

end simple;