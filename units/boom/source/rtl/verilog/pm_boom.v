
module pm_boom #(
    `include "noc_parameter.vh"
    ,parameter HOME_MODID = {NOC_MODID_SIZE{1'b0}},
    parameter CLKFREQ_MHZ = 100
)
(
    input  wire                                     clk_pm_i,
    input  wire                                     reset_pm_n_i,
    input  wire               [NOC_CHIPID_SIZE-1:0] home_chipid_i,
    input  wire               [NOC_CHIPID_SIZE-1:0] host_chipid_i,
    input  wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_pm_in_data_i,
    output wire           [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_pm_in_raddr_o,
    input  wire           [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_pm_in_waddr_i,
    output wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_pm_out_data_o,
    input  wire           [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_pm_out_raddr_i,
    output wire           [NOC_ASYNC_FIFO_AWIDTH:0] noc_fifo_pm_out_waddr_o,

    input wire                                      jtag_tck_i,
    input wire                                      jtag_tms_i,
    input wire                                      jtag_tdi_i,
    output wire                                     jtag_tdo_o,
    output wire                                     jtag_tdo_en_o,

    output wire                                     uart_tx_o,
    input  wire                                     uart_rx_i
);

    wire reset_sync_n_s;

    wire [NOC_CHIPID_SIZE-1:0] home_chipid_s;
    wire [NOC_CHIPID_SIZE-1:0] host_chipid_s;



boom_wrap #(
    .HOME_MODID                 (HOME_MODID),
    .CLKFREQ_MHZ                (CLKFREQ_MHZ)
) i_boom_wrap (
    .clk_pm_i                   (clk_pm_i),
    .reset_pm_n_i               (reset_sync_n_s),
    .home_chipid_i              (home_chipid_s),
    .host_chipid_i              (host_chipid_s),
    .noc_fifo_pm_in_data_i      (noc_fifo_pm_in_data_i),
    .noc_fifo_pm_in_raddr_o     (noc_fifo_pm_in_raddr_o),
    .noc_fifo_pm_in_waddr_i     (noc_fifo_pm_in_waddr_i),
    .noc_fifo_pm_out_data_o     (noc_fifo_pm_out_data_o),
    .noc_fifo_pm_out_raddr_i    (noc_fifo_pm_out_raddr_i),
    .noc_fifo_pm_out_waddr_o    (noc_fifo_pm_out_waddr_o),

    .jtag_tck_i                 (jtag_tck_i),
    .jtag_tms_i                 (jtag_tms_i),
    .jtag_tdi_i                 (jtag_tdi_i),
    .jtag_tdo_o                 (jtag_tdo_o),
    .jtag_tdo_en_o              (jtag_tdo_en_o),

    .uart_tx_o                  (uart_tx_o),
    .uart_rx_i                  (uart_rx_i)
);

util_reset_sync i_util_reset_sync_ref (
    .clk_i(clk_pm_i),
    .reset_q_i(reset_pm_n_i),
    .scan_mode_i(1'b0),
    .sync_reset_q_o(reset_sync_n_s)
);

util_sync #(
    .WIDTH(NOC_CHIPID_SIZE)
) i_util_sync_host_chipid (
    .clk_i(clk_pm_i),
    .reset_n_i(reset_sync_n_s),
    .data_i(host_chipid_i),
    .data_o(host_chipid_s)
);

util_sync #(
    .WIDTH(NOC_CHIPID_SIZE)
) i_util_sync_home_chipid (
    .clk_i(clk_pm_i),
    .reset_n_i(reset_sync_n_s),
    .data_i(home_chipid_i),
    .data_o(home_chipid_s)
);


endmodule
