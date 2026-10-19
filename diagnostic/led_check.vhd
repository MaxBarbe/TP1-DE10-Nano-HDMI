library ieee;
use ieee.std_logic_1164.all;

entity led_check is
    port (
        clk : in std_logic;
        sw0 : in std_logic;
        led : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of led_check is
    signal count : integer range 0 to 24999999 := 0;
    signal heartbeat : std_logic := '0';
begin
    -- Aucun reset : le clignotement ne depend pas de la position de SW0.
    process(clk)
    begin
        if rising_edge(clk) then
            if count = 24999999 then
                count <= 0;
                heartbeat <= not heartbeat;
            else
                count <= count + 1;
            end if;
        end if;
    end process;
    led(0) <= sw0;       -- Reponse directe, meme si l'horloge ne fonctionne pas.
    led(1) <= heartbeat; -- 0,5 seconde allumee / 0,5 seconde eteinte.
    led(2) <= not sw0;
    led(3) <= '1';
end architecture;
