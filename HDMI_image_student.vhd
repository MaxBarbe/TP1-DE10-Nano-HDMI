library ieee;
use ieee.std_logic_1164.all;

entity HDMI_image is
    port (
        clk : in std_logic;              -- 50 MHz
        reset_n : in std_logic;          -- SW0 : 0 = reset, 1 = marche
        R, G, B : out std_logic_vector(7 downto 0);
        clkout, HS, VS, EN : out std_logic;
        scl : out std_logic;
        sda : inout std_logic;
        Init_config : out std_logic      -- LED0
    );
end entity;

architecture rtl of HDMI_image is
    signal clk25 : std_logic := '0';
    signal done : std_logic;
    signal ready_meta, ready : std_logic := '0';
    signal h : integer range 0 to 799 := 0;
    signal v : integer range 0 to 524 := 0;
begin
    config : entity work.i2c_hdmi_config
        port map (clk => clk, reset_n => reset_n,
                  i2c_scl => scl, i2c_sda => sda, hdmi_tx_int => '1',
                  config_done => done);
    Init_config <= done;

    process(clk)
    begin
        if rising_edge(clk) then
            clk25 <= not clk25;
        end if;
    end process;

    -- Les donnees changent au front montant ; le HDMI les capture
    -- un demi-cycle plus tard sur son horloge inversee.
    clkout <= not clk25;

    process(clk25, reset_n)
    begin
        if reset_n = '0' then
            ready_meta <= '0'; ready <= '0';
            h <= 0; v <= 0;
        elsif rising_edge(clk25) then
            ready_meta <= done;
            ready <= ready_meta;
            if ready = '0' then
                h <= 0; v <= 0;
            elsif h = 799 then
                h <= 0;
                if v = 524 then v <= 0;
                else v <= v + 1;
                end if;
            else h <= h + 1;
            end if;
        end if;
    end process;

    HS <= '0' when h >= 656 and h < 752 else '1';
    VS <= '0' when v >= 490 and v < 492 else '1';
    EN <= '1' when h < 640 and v < 480 and ready = '1' else '0';

    process(h, v, ready)
    begin
        R <= (others => '0');
        G <= (others => '0');
        B <= (others => '0');
        if ready = '1' and h < 640 and v < 480 then
            if h < 320 then R <= (others => '1');
            else G <= (others => '1');
            end if;
        end if;
    end process;
end architecture;
