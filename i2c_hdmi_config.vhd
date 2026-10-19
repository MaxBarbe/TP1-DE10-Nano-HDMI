library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_hdmi_config is
    generic (
        CLK_FREQ : positive := 50_000_000;
        CTRL_CLK_FREQ : positive := 20_000
    );
    port (
        clk         : in  std_logic;
        reset_n     : in  std_logic;
        i2c_sda     : inout std_logic;
        i2c_scl     : out std_logic;
        hdmi_tx_int : in  std_logic;                    -- Interruption active a 0
        config_done : out std_logic                     -- 1 lorsque tous les registres sont acquittes
    );
end entity;

architecture rtl of i2c_hdmi_config is

    constant LUT_SIZE        : integer := 30;            -- Dernier indice : 31 registres au total

    type lut_array is array (0 to LUT_SIZE) of std_logic_vector(15 downto 0);
    constant LUT_DATA : lut_array := (
        0  => x"9803", 1  => x"0100", 2  => x"0218", 3  => x"0300",
        4  => x"1470", 5  => x"1520", 6  => x"1630", 7  => x"1846",
        8  => x"4080", 9  => x"4110", 10 => x"49A8", 11 => x"5510",
        12 => x"5608", 13 => x"96F6", 14 => x"7307", 15 => x"761F",
        16 => x"9803", 17 => x"9902", 18 => x"9AE0", 19 => x"9C30",
        20 => x"9D61", 21 => x"A2A4", 22 => x"A3A4", 23 => x"A504",
        24 => x"AB40", 25 => x"AF16", 26 => x"BA60", 27 => x"D1FF",
        28 => x"DE10", 29 => x"E460", 30 => x"FA7D"
    );

    signal i2c_ctrl_clk : std_logic := '0';
    signal clk_div      : unsigned(15 downto 0) := (others => '0');

    signal lut_index       : integer range 0 to LUT_SIZE + 1 := 0;
    signal setup_st        : integer range 0 to 3 := 0;
    signal i2c_go          : std_logic := '0';
    signal i2c_end         : std_logic;
    signal i2c_ack         : std_logic;
    signal i2c_data        : std_logic_vector(23 downto 0);
    signal config_done_reg : std_logic := '0';
    signal refresh_count   : integer range 0 to CTRL_CLK_FREQ - 1 := 0;

begin

    config_done <= config_done_reg;

    -- Horloge du controleur : 20 kHz. SCL utilise quatre cycles par bit.
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                clk_div      <= (others => '0');
                i2c_ctrl_clk <= '0';
            else
                if clk_div < (CLK_FREQ / CTRL_CLK_FREQ / 2 - 1) then
                    clk_div <= clk_div + 1;
                else
                    clk_div      <= (others => '0');
                    i2c_ctrl_clk <= not i2c_ctrl_clk;
                end if;
            end if;
        end if;
    end process;

    -- Ecriture des trois octets : adresse du circuit, registre, valeur.
    i2c_inst : entity work.i2c_controller
        port map (
            clk         => i2c_ctrl_clk,
            reset_n     => reset_n,
            i2c_frame   => i2c_data,
            i2c_sda     => i2c_sda,
            i2c_scl     => i2c_scl,
            i2c_RW      => '0',
            i2c_start   => i2c_go,
            i2c_stop    => i2c_end,
            i2c_ack     => i2c_ack,
            i2c_bit_cnt => open,
            i2c_sda_out => open
        );

    -- Envoi sequentiel des registres ; nouvelle tentative si NACK.
    process(i2c_ctrl_clk, reset_n)
    begin
        if reset_n = '0' then
            lut_index       <= 0;
            setup_st        <= 0;
            i2c_go          <= '0';
            config_done_reg <= '0';
            refresh_count   <= 0;
        elsif rising_edge(i2c_ctrl_clk) then
            if lut_index <= LUT_SIZE then
                case setup_st is
                    when 0 =>
                        i2c_data <= x"72" & LUT_DATA(lut_index);
                        i2c_go   <= '1';
                        setup_st <= 1;
                    when 1 =>
                        if i2c_end = '1' then
                            i2c_go <= '0';
                            if i2c_ack = '0' then
                                setup_st <= 2;
                            else
                                setup_st <= 0; -- NACK : recommencer ce registre.
                            end if;
                        end if;
                    when 2 =>
                        lut_index <= lut_index + 1;
                        setup_st  <= 0;
                    when others =>
                        setup_st <= 0;
                end case;
            else
                config_done_reg <= '1';
                -- HPD bas peut reinitialiser des registres de l'ADV7513.
                -- Rejouer la table apres un branchement tardif/debranchement,
                -- meme sans connecter HDMI_TX_INT a l'entite superieure.
                if hdmi_tx_int = '0' or refresh_count = CTRL_CLK_FREQ - 1 then
                    lut_index       <= 0;
                    setup_st        <= 0;
                    refresh_count   <= 0;
                    config_done_reg <= '0';
                else
                    refresh_count <= refresh_count + 1;
                end if;
            end if;
        end if;
    end process;
end architecture rtl;
