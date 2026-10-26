library ieee;
use ieee.std_logic_1164.all;

entity HDMI_image is
    port (
        clk : in std_logic;     -- FPGA_CLK1_50
        reset_n : in std_logic; -- SW0 : 0 = reset, 1 = marche
        R, G, B : out std_logic_vector(7 downto 0);
        clkout, HS, VS, EN : out std_logic;
        scl : out std_logic;
        sda : inout std_logic;
        Init_config : out std_logic
    );
end entity;

architecture rtl of HDMI_image is
    signal startup : integer range 0 to 500000 := 0;
    signal run_n : std_logic := '0';
    signal done : std_logic;
begin
    -- Reset automatique pendant 10 ms, meme si SW0 est deja sur 1.
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            startup <= 0;
            run_n <= '0';
        elsif rising_edge(clk) then
            if startup < 500000 then
                startup <= startup + 1;
                run_n <= '0';
            else
                run_n <= '1';
            end if;
        end if;
    end process;

    config : entity work.i2c_hdmi_config
        port map (clk => clk, reset_n => run_n,
            i2c_scl => scl, i2c_sda => sda,
            hdmi_tx_int => '1', config_done => done);
    Init_config <= done;

    -- Le balayage continue pendant les ecritures I2C, meme en cas de NACK.
    video : entity work.affichage_image_filtre
        port map (clk => clk, reset_n => run_n,
            clk_out => clkout, en => EN, R => R, G => G, B => B,
            hs => HS, vs => VS);
end architecture;
