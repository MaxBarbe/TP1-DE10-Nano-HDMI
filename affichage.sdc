create_clock -name clk50 -period 20.000 [get_ports {clk}]
create_generated_clock -name pixel25 -source [get_ports {clk}] -divide_by 2 [get_registers {*clk25}]
derive_clock_uncertainty
