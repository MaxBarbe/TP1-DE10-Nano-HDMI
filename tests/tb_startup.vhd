library ieee;
use ieee.std_logic_1164.all;
entity tb_startup is end;
architecture test of tb_startup is
    signal clk : std_logic := '0';
    signal r,g,b : std_logic_vector(7 downto 0);
    signal pclk,hs,vs,de,scl,sda,done : std_logic;
    signal active_pixels : natural := 0;
begin
    clk <= not clk after 10 ns;
    sda <= 'H'; -- Aucun esclave : NACK permanent.
    dut : entity work.HDMI_image
        port map(clk, '1', r,g,b,pclk,hs,vs,de,scl,sda,done);
    process(pclk)
    begin
        if rising_edge(pclk) and de = '1' then active_pixels <= active_pixels + 1; end if;
    end process;
    process
    begin
        wait for 9 ms;
        assert de = '0' and done = '0' report "Reset de demarrage absent" severity failure;
        wait for 19 ms;
        assert done = '0' report "NACK devrait empecher config_done" severity failure;
        assert active_pixels > 300000 report "Balayage bloque par config_done" severity failure;
        report "PASS: reset automatique SW0=1 et video continue malgre NACK";
        std.env.stop;
        wait;
    end process;
end architecture;
