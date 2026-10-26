-- Adapte du TP de MASSE Noe et PASSOLUNGHI Alec (UNICE).
-- 640x480, image 420x280, noyau [1,1,1; 1,2,1; 1,1,1] / 10.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity affichage_image_filtre is
    generic (FILTER_ENABLE : boolean := true);
    port (
        clk : in std_logic;
        reset_n : in std_logic := '1';
        clk_out, en : out std_logic;
        R, G, B : out std_logic_vector(7 downto 0);
        hs, vs : out std_logic
    );
end entity;

architecture rtl of affichage_image_filtre is
    signal clk25 : std_logic := '0';
    signal h, h_rom, h_out : integer range 0 to 799 := 0;
    signal v, v_rom, v_out : integer range 0 to 524 := 0;
    signal adr_rom : std_logic_vector(16 downto 0);
    signal rgb : std_logic_vector(23 downto 0);
    type line_type is array (0 to 419) of std_logic_vector(23 downto 0);
    signal line_1, line_2 : line_type;
    signal a0, a1, b0, b1, c0, c1 : std_logic_vector(23 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then clk25 <= not clk25; end if;
    end process;
    -- Capture HDMI un demi-cycle apres la mise a jour des donnees.
    clk_out <= not clk25;
    adr_rom <= std_logic_vector(to_unsigned(v * 420 + h, 17))
        when h < 420 and v < 280 else (others => '0');
    image : entity work.vga_rom3
        port map (address => adr_rom, clock => clk25, q => rgb);

    process(clk25, reset_n)
    begin
        if reset_n = '0' then
            h <= 0; v <= 0;
            h_rom <= 0; v_rom <= 0;
            h_out <= 0; v_out <= 0;
        elsif rising_edge(clk25) then
            if h = 799 then
                h <= 0;
                if v = 524 then v <= 0; else v <= v + 1; end if;
            else
                h <= h + 1;
            end if;
            -- ROM : un cycle ; filtre/sorties : un autre cycle.
            h_rom <= h; v_rom <= v;
            h_out <= h_rom; v_out <= v_rom;
        end if;
    end process;

    -- Une case par ligne et par pixel : pas de copie de ligne complete.
    -- Les taps ne lisent jamais le pixel x+1 qui n'est pas encore arrive.
    process(clk25)
        variable older, previous, result_pixel : std_logic_vector(23 downto 0);
        variable lo, hi : integer;
        variable total : integer range 0 to 2550;
    begin
        if rising_edge(clk25) then
            result_pixel := (others => '0');
            if reset_n = '1' and h_rom < 420 and v_rom < 280 then
                previous := line_1(h_rom);
                older := line_2(h_rom);
                line_1(h_rom) <= rgb;
                line_2(h_rom) <= previous;
                a0 <= a1; a1 <= older;
                b0 <= b1; b1 <= previous;
                c0 <= c1; c1 <= rgb;
                result_pixel := rgb;
                -- Les deux premieres lignes/colonnes restent non filtrees.
                if FILTER_ENABLE and h_rom >= 2 and v_rom >= 2 then
                    for channel in 0 to 2 loop
                        lo := channel * 8; hi := lo + 7;
                        total := to_integer(unsigned(a0(hi downto lo)))
                            + to_integer(unsigned(a1(hi downto lo)))
                            + to_integer(unsigned(older(hi downto lo)))
                            + to_integer(unsigned(b0(hi downto lo)))
                            + 2 * to_integer(unsigned(b1(hi downto lo)))
                            + to_integer(unsigned(previous(hi downto lo)))
                            + to_integer(unsigned(c0(hi downto lo)))
                            + to_integer(unsigned(c1(hi downto lo)))
                            + to_integer(unsigned(rgb(hi downto lo)));
                        result_pixel(hi downto lo) := std_logic_vector(to_unsigned(total / 10, 8));
                    end loop;
                end if;
            end if;
            R <= result_pixel(23 downto 16);
            G <= result_pixel(15 downto 8);
            B <= result_pixel(7 downto 0);
        end if;
    end process;
    -- Fenetre causale : le centre (x-1,y-1) est affiche en (x,y).
    hs <= '0' when h_out >= 656 and h_out < 752 else '1';
    vs <= '0' when v_out >= 490 and v_out < 492 else '1';
    en <= '1' when reset_n = '1' and h_out < 640 and v_out < 480 else '0';
end architecture;
