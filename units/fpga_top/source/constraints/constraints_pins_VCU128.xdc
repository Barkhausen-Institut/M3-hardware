
#LOC constraints for 8 cores
#place cores connected to same NoC router in same SLR
#set_property USER_SLR_ASSIGNMENT SLR2 [get_cells PM2.i_pm_domain]
#set_property USER_SLR_ASSIGNMENT SLR0 [get_cells PM3.i_pm_domain]


#clocks
#QDR4 CLK 100 MHz
set_property PACKAGE_PIN BJ4         [get_ports "SYSCLK1_100_P"];
set_property IOSTANDARD  LVDS        [get_ports "SYSCLK1_100_P"];
set_property PACKAGE_PIN BK3         [get_ports "SYSCLK1_100_N"];
set_property IOSTANDARD  LVDS        [get_ports "SYSCLK1_100_N"];

#RLD3 CLK 100 MHz
set_property PACKAGE_PIN F35         [get_ports "SYSCLK2_100_P"];
set_property IOSTANDARD  LVDS        [get_ports "SYSCLK2_100_P"];
set_property PACKAGE_PIN F36         [get_ports "SYSCLK2_100_N"];
set_property IOSTANDARD  LVDS        [get_ports "SYSCLK2_100_N"];


#define I/O for LEDs and buttons
set_property PACKAGE_PIN B17      [get_ports {GPIO_DIP_SW[0]}];
set_property PACKAGE_PIN G16      [get_ports {GPIO_DIP_SW[1]}];
set_property PACKAGE_PIN J16      [get_ports {GPIO_DIP_SW[2]}];
set_property PACKAGE_PIN D21      [get_ports {GPIO_DIP_SW[3]}];
set_property IOSTANDARD  LVCMOS12 [get_ports {GPIO_DIP_SW[*]}];
set_false_path -from              [get_ports {GPIO_DIP_SW[*]}];
set_input_delay 0                 [get_ports {GPIO_DIP_SW[*]}];

#set_property PACKAGE_PIN BB24     [get_ports {GPIO_SW_N}];
#set_property IOSTANDARD  LVCMOS18 [get_ports {GPIO_SW_N}];
set_property PACKAGE_PIN BF22     [get_ports {GPIO_SW_W}];
set_property IOSTANDARD  LVCMOS18 [get_ports {GPIO_SW_W}];
#set_property PACKAGE_PIN BE22     [get_ports {GPIO_SW_S}];
#set_property IOSTANDARD  LVCMOS18 [get_ports {GPIO_SW_S}];
#set_property PACKAGE_PIN BE23     [get_ports {GPIO_SW_E}];
#set_property IOSTANDARD  LVCMOS18 [get_ports {GPIO_SW_E}];
#set_property PACKAGE_PIN BD23     [get_ports {GPIO_SW_C}];
#set_property IOSTANDARD  LVCMOS18 [get_ports {GPIO_SW_C}];

set_property PACKAGE_PIN BM29     [get_ports {CPU_RESET}];
set_property IOSTANDARD  LVCMOS12 [get_ports {CPU_RESET}];
set_false_path -from              [get_ports {CPU_RESET}];
set_input_delay 0                 [get_ports {CPU_RESET}];

set_property PACKAGE_PIN BH24     [get_ports {GPIO_LED[0]}];
set_property PACKAGE_PIN BG24     [get_ports {GPIO_LED[1]}];
set_property PACKAGE_PIN BG25     [get_ports {GPIO_LED[2]}];
set_property PACKAGE_PIN BF25     [get_ports {GPIO_LED[3]}];
set_property PACKAGE_PIN BF26     [get_ports {GPIO_LED[4]}];
set_property PACKAGE_PIN BF27     [get_ports {GPIO_LED[5]}];
set_property PACKAGE_PIN BG27     [get_ports {GPIO_LED[6]}];
set_property PACKAGE_PIN BG28     [get_ports {GPIO_LED[7]}];
set_property IOSTANDARD  LVCMOS18 [get_ports {GPIO_LED[*]}];
set_property SLEW        SLOW     [get_ports {GPIO_LED[*]}];
set_property DRIVE       8        [get_ports {GPIO_LED[*]}];
set_false_path -to                [get_ports {GPIO_LED[*]}];
set_output_delay 0                [get_ports {GPIO_LED[*]}];


#UART
set_property PACKAGE_PIN BJ28     [get_ports "UART_TX"]
set_property IOSTANDARD  LVCMOS18 [get_ports "UART_TX"]
set_property PACKAGE_PIN BK28     [get_ports "UART_RX"]
set_property IOSTANDARD  LVCMOS18 [get_ports "UART_RX"]
