create_clock -name clk50 -period 20.000 [get_ports {clk}]
create_generated_clock -name pixel25 -source [get_ports {clk}] -divide_by 2 [get_registers {*video*clk25}]
create_generated_clock -name hdmi25 -source [get_registers {*video*clk25}] -divide_by 1 -invert [get_ports {clkout}]
create_generated_clock -name i2c20k -source [get_ports {clk}] -divide_by 2500 [get_registers {*i2c_ctrl_clk}]
derive_clock_uncertainty
