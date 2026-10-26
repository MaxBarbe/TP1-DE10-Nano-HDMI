library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.image_data.all;

entity tb_video is end;
architecture test of tb_video is
    signal clk : std_logic := '0';
    signal reset_n : std_logic := '0';
    signal pclk, de, hs, vs, raw_clk, raw_de, raw_hs, raw_vs : std_logic;
    signal r, g, b, raw_r, raw_g, raw_b : std_logic_vector(7 downto 0);
    function expected(x, y : integer; filtered : boolean) return std_logic_vector is
        variable result : std_logic_vector(23 downto 0) := (others => '0');
        variable sum, weight : integer;
    begin
        if x < 420 and y < 280 then
            result := pixels(y * 420 + x);
            if filtered and x >= 2 and y >= 2 then
                for c in 0 to 2 loop
                    sum := 0;
                    for dy in 0 to 2 loop
                        for dx in 0 to 2 loop
                            weight := 1;
                            if dx = 1 and dy = 1 then weight := 2; end if;
                            sum := sum + weight * to_integer(unsigned(
                                pixels((y-dy)*420+x-dx)(c*8+7 downto c*8)));
                        end loop;
                    end loop;
                    result(c*8+7 downto c*8) := std_logic_vector(to_unsigned(sum / 10, 8));
                end loop;
            end if;
        end if;
        return result;
    end function;
begin
    clk <= not clk after 10 ns;
    dut : entity work.affichage_image_filtre
        port map(clk, reset_n, pclk, de, r, g, b, hs, vs);
    bypass : entity work.affichage_image_filtre
        generic map(FILTER_ENABLE => false)
        port map(clk, reset_n, raw_clk, raw_de, raw_r, raw_g, raw_b, raw_hs, raw_vs);
    process
        variable x : integer := 0;
        variable y : integer := 490;
        variable active_pixels : integer := 0;
    begin
        wait for 200 ns;
        reset_n <= '1';
        -- Reference connue : debut de VS bas = (0,490).
        wait until falling_edge(vs);
        for sample in 0 to 800*525-1 loop
            wait until rising_edge(pclk);
            assert (hs = '0') = (x >= 656 and x < 752) report "HS incorrect" severity failure;
            assert (vs = '0') = (y >= 490 and y < 492) report "VS incorrect" severity failure;
            assert (de = '1') = (x < 640 and y < 480) report "DE incorrect" severity failure;
            assert raw_hs = hs and raw_vs = vs and raw_de = de and raw_clk = pclk severity failure;
            assert (r & g & b) = expected(x,y,true)
                report "Filtre/alignement incorrect x=" & integer'image(x) & " y=" & integer'image(y) severity failure;
            assert (raw_r & raw_g & raw_b) = expected(x,y,false)
                report "ROM/alignement incorrect" severity failure;
            if de = '1' then active_pixels := active_pixels + 1; end if;
            if x = 799 then
                x := 0;
                if y = 524 then y := 0; else y := y + 1; end if;
            else x := x + 1; end if;
        end loop;
        assert active_pixels = 640*480 severity failure;
        report "PASS: trame complete, pixels MIF, convolution, bypass, HS/VS/DE et blanking";
        std.env.stop;
        wait;
    end process;
end architecture;
