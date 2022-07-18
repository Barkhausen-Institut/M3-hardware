
module ethernet_fpga_config #(
    `include "noc_parameter.vh"
    ,parameter FPGA_IP_BASE = {8'd192, 8'd168, 8'd42, 8'd240},
    parameter FPGA_MAC_BASE = 48'h080028_030405
)
(
    input  wire                 [3:0] switches_i,
    output wire                [31:0] fpga_ip_addr_o,
    output wire                [47:0] fpga_mac_addr_o,
    output wire [NOC_CHIPID_SIZE-1:0] home_chipid_o
);


assign fpga_ip_addr_o  = FPGA_IP_BASE + switches_i;
assign fpga_mac_addr_o = FPGA_MAC_BASE + switches_i;
assign home_chipid_o   = {{(NOC_CHIPID_SIZE-4){1'b0}}, switches_i};


endmodule
