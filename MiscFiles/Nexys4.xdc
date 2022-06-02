# clock and reset signals
set_property PACKAGE_PIN E3 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 11.20 -waveform {0 5} [get_ports clk]
set_property PACKAGE_PIN U9 [get_ports rst]					
	set_property IOSTANDARD LVCMOS33 [get_ports rst]
    
# buttons
set_property PACKAGE_PIN T16 [get_ports start]						
	set_property IOSTANDARD LVCMOS33 [get_ports start]
set_property PACKAGE_PIN R10 [get_ports stop]						
	set_property IOSTANDARD LVCMOS33 [get_ports stop]
    
# anode connection of seven segment
set_property PACKAGE_PIN N5 [get_ports {anode[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anode[0]}]
set_property PACKAGE_PIN M3 [get_ports {anode[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anode[1]}]
set_property PACKAGE_PIN M6 [get_ports {anode[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anode[2]}]
set_property PACKAGE_PIN N6 [get_ports {anode[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anode[3]}]
set_property PACKAGE_PIN N2 [get_ports {anode[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anode[4]}]
set_property PACKAGE_PIN N4 [get_ports {anode[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anode[5]}]
set_property PACKAGE_PIN L1 [get_ports {anode[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anode[6]}]
set_property PACKAGE_PIN M1 [get_ports {anode[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anode[7]}]
    
# connections to seven segment catodes  
set_property PACKAGE_PIN L3 [get_ports {seven_segment[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seven_segment[0]}]
set_property PACKAGE_PIN N1 [get_ports {seven_segment[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seven_segment[1]}]
set_property PACKAGE_PIN L5 [get_ports {seven_segment[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seven_segment[2]}]
set_property PACKAGE_PIN L4 [get_ports {seven_segment[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seven_segment[3]}]
set_property PACKAGE_PIN K3 [get_ports {seven_segment[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seven_segment[4]}]
set_property PACKAGE_PIN M2 [get_ports {seven_segment[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seven_segment[5]}]
set_property PACKAGE_PIN L6 [get_ports {seven_segment[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seven_segment[6]}]

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]