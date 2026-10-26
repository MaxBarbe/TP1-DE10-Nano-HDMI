library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

package image_data is
    type pixels_type is array (0 to 117599) of std_logic_vector(23 downto 0);
    impure function load_image return pixels_type;
    constant pixels : pixels_type;
end package;

package body image_data is
    impure function load_image return pixels_type is
        file input : text open read_mode is "brom24b.mif";
        variable row : line;
        variable result : pixels_type;
        variable address, value : integer;
        variable separator : character;
    begin
        for header in 1 to 5 loop readline(input, row); end loop;
        for i in result'range loop
            readline(input, row);
            read(row, address);
            read(row, separator); -- espace
            read(row, separator); -- deux-points
            read(row, value);
            assert address = i report "Adresse MIF incorrecte" severity failure;
            assert value >= 0 and value < 16777216 severity failure;
            result(i) := std_logic_vector(to_unsigned(value, 24));
        end loop;
        return result;
    end function;
    constant pixels : pixels_type := load_image;
end package body;
