library ieee;
use ieee.std_logic_1164.all;

-- Controleur attendu par i2c_hdmi_config.vhd.
-- Horloge du controleur : 20 kHz ; horloge du bus SCL : 5 kHz.
entity i2c_controller is
    port (
        clk, reset_n : in std_logic;
        i2c_frame : in std_logic_vector(23 downto 0);
        i2c_sda : inout std_logic;
        i2c_scl : out std_logic;
        i2c_RW, i2c_start : in std_logic;
        i2c_stop, i2c_ack : out std_logic;
        i2c_bit_cnt : out std_logic_vector(5 downto 0);
        i2c_sda_out : out std_logic
    );
end entity;

architecture rtl of i2c_controller is
    type state_type is (idle, start_a, start_b, start_c,
        bit_low, bit_high, bit_hold, bit_end,
        ack_low, ack_high, ack_sample, ack_end,
        stop_a, stop_b, stop_c, finished);
    signal state : state_type := idle;
    signal frame : std_logic_vector(23 downto 0) := (others => '0');
    signal byte_index : integer range 0 to 2 := 0;
    signal bit_index : integer range 0 to 7 := 7;
    signal scl_reg : std_logic := '1';
    signal sda_low : std_logic := '0';
    signal failed : std_logic := '0';
begin
    i2c_scl <= scl_reg;
    i2c_sda <= '0' when sda_low = '1' else 'Z';
    i2c_sda_out <= not sda_low;
    i2c_ack <= failed;
    -- Sortie de diagnostic inutilisee par le sequenceur.
    i2c_bit_cnt <= (others => '0');

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            state <= idle;
            frame <= (others => '0');
            byte_index <= 0;
            bit_index <= 7;
            scl_reg <= '1';
            sda_low <= '0';
            failed <= '0';
            i2c_stop <= '0';
        elsif rising_edge(clk) then
            case state is
                when idle =>
                    i2c_stop <= '0';
                    if i2c_start = '1' then
                        frame <= i2c_frame;
                        failed <= '0';
                        byte_index <= 0;
                        bit_index <= 7;
                        state <= start_a;
                    end if;
                when start_a =>
                    scl_reg <= '1';
                    sda_low <= '0';
                    state <= start_b;
                when start_b =>
                    sda_low <= '1';
                    state <= start_c;
                when start_c =>
                    scl_reg <= '0';
                    state <= bit_low;
                when bit_low =>
                    sda_low <= not frame(23 - byte_index * 8 - (7 - bit_index));
                    state <= bit_high;
                when bit_high =>
                    scl_reg <= '1';
                    state <= bit_hold;
                when bit_hold =>
                    state <= bit_end;
                when bit_end =>
                    scl_reg <= '0';
                    if bit_index = 0 then
                        state <= ack_low;
                    else
                        bit_index <= bit_index - 1;
                        state <= bit_low;
                    end if;
                when ack_low =>
                    sda_low <= '0';
                    state <= ack_high;
                when ack_high =>
                    scl_reg <= '1';
                    state <= ack_sample;
                when ack_sample =>
                    if i2c_sda /= '0' and i2c_sda /= 'L' then
                        failed <= '1';
                    end if;
                    state <= ack_end;
                when ack_end =>
                    scl_reg <= '0';
                    if failed = '1' or byte_index = 2 then
                        state <= stop_a;
                    else
                        byte_index <= byte_index + 1;
                        bit_index <= 7;
                        state <= bit_low;
                    end if;
                when stop_a =>
                    sda_low <= '1';
                    state <= stop_b;
                when stop_b =>
                    scl_reg <= '1';
                    state <= stop_c;
                when stop_c =>
                    sda_low <= '0';
                    state <= finished;
                when finished =>
                    i2c_stop <= '1';
                    if i2c_start = '0' then
                        i2c_stop <= '0';
                        state <= idle;
                    end if;
            end case;
        end if;
    end process;
    -- Seules les ecritures (i2c_RW = '0') sont utilisees dans ce TP.
end architecture;
