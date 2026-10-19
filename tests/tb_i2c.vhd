library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity tb_i2c is end;
architecture test of tb_i2c is
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal scl, sda, done : std_logic;
    signal slave_low : boolean := false;
    type table_type is array(0 to 30) of std_logic_vector(15 downto 0);
    constant table_data : table_type := (
        x"9803",x"0100",x"0218",x"0300",x"1470",x"1520",x"1630",x"1846",
        x"4080",x"4110",x"49A8",x"5510",x"5608",x"96F6",x"7307",x"761F",
        x"9803",x"9902",x"9AE0",x"9C30",x"9D61",x"A2A4",x"A3A4",x"A504",
        x"AB40",x"AF16",x"BA60",x"D1FF",x"DE10",x"E460",x"FA7D");
begin
    clk <= not clk after 10 ns;
    sda <= 'H';
    sda <= '0' when slave_low else 'Z';
    dut : entity work.i2c_hdmi_config
        generic map(CLK_FREQ => 200000, CTRL_CLK_FREQ => 20000)
        port map(clk, rst, sda, scl, '1', done);
    process
        variable received : std_logic_vector(23 downto 0);
        variable bytes : integer;
    begin
        wait for 100 ns; rst <= '1';
        -- Premier essai NACK, puis les 31 registres, puis le premier refresh.
        for transaction in 0 to 32 loop
            wait until sda'event and sda = '0' and scl = '1';
            received := (others => '0');
            if transaction = 0 then bytes := 1; else bytes := 3; end if;
            for byte in 0 to bytes-1 loop
                for bit in 7 downto 0 loop
                    wait until rising_edge(scl);
                    received(23-byte*8-(7-bit)) := to_x01(sda);
                end loop;
                wait until falling_edge(scl);
                if transaction /= 0 then slave_low <= true; end if;
                wait until rising_edge(scl);
                wait until falling_edge(scl);
                slave_low <= false;
            end loop;
            -- Attendre STOP, sans confondre le prochain START.
            wait until scl = '1';
            wait until sda'event and to_x01(sda) = '1';
            if transaction = 0 then
                assert received(23 downto 16) = x"72" severity failure;
                assert done = '0' report "NACK ignore" severity failure;
            else
                assert received = x"72" & table_data((transaction-1) mod 31)
                    report "Registre saute/duplique ou trame I2C incorrecte" severity failure;
            end if;
            if transaction = 31 then
                wait until done = '1';
            end if;
        end loop;
        report "PASS: adresse 0x72, 31 ecritures, reprise NACK, configuration et refresh";
        std.env.stop;
        wait;
    end process;
    process
    begin
        wait for 10 ms;
        assert false report "Timeout I2C" severity failure;
    end process;
end architecture;
