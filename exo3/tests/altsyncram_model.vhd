-- Modele limite a la ROM utilisee ici ; ne remplace pas la lib Intel en synthese.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.image_data.all;
entity altsyncram is
    generic (
        address_aclr_a, clock_enable_input_a, clock_enable_output_a : string;
        init_file, intended_device_family, lpm_hint, lpm_type : string;
        numwords_a : natural;
        operation_mode, outdata_aclr_a, outdata_reg_a : string;
        widthad_a, width_a, width_byteena_a : natural
    );
    port (clock0 : in std_logic;
        address_a : in std_logic_vector(16 downto 0);
        q_a : out std_logic_vector(23 downto 0));
end entity;
architecture model of altsyncram is
begin
    assert numwords_a = 117600 and width_a = 24 and widthad_a = 17 severity failure;
    assert operation_mode = "ROM" and outdata_reg_a = "UNREGISTERED"
        report "Le pipeline attend une ROM a un cycle" severity failure;
    process(clock0)
    begin
        if rising_edge(clock0) then
            q_a <= pixels(to_integer(unsigned(address_a)));
        end if;
    end process;
end architecture;
