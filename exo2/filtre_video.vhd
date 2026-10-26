library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TP1 is
    Port (
        P1 : in  unsigned(7 downto 0);
        P2 : in  unsigned(7 downto 0);
        P3 : in  unsigned(7 downto 0);
        P4 : in  unsigned(7 downto 0);
        P5 : in  unsigned(7 downto 0);
        P6 : in  unsigned(7 downto 0);
        P7 : in  unsigned(7 downto 0);
        P8 : in  unsigned(7 downto 0);
        P9 : in  unsigned(7 downto 0);

        pixel_out : out unsigned(7 downto 0)
    );
end TP1;


architecture simple of TP1 is

    signal somme : unsigned(11 downto 0);

begin

    somme <= resize(P1,12)
           + resize(P2,12)
           + resize(P3,12)
           + resize(P4,12)
           + shift_left(resize(P5,12),1)
           + resize(P6,12)
           + resize(P7,12)
           + resize(P8,12)
           + resize(P9,12);

    pixel_out <= resize(somme / 10, 8);

end simple;