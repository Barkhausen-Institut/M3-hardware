
module pm_domain #(
    `include "pm_types.vh"
    ,`include "noc_parameter.vh"
    ,parameter [NOC_MODID_SIZE-1:0] HOME_MODID = 0,
    parameter                       PM_CORE_SELECT = PM_TYPE_NONE,
    parameter                       PM_UART_ATTACHED = 0,
    parameter                       CLKFREQ_MHZ = 100
)
(
    input  wire                                     clk_pm_i,
    input  wire                                     reset_pm_n_i,
    input  wire    [NOC_CHIPID_SIZE-1:0]            home_chipid_i,
    input  wire    [NOC_CHIPID_SIZE-1:0]            host_chipid_i,
    input  wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_pm_in_data_i,
    output wire    [NOC_ASYNC_FIFO_AWIDTH:0]        noc_fifo_pm_in_raddr_o,
    input  wire    [NOC_ASYNC_FIFO_AWIDTH:0]        noc_fifo_pm_in_waddr_i,
    output wire    [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] noc_fifo_pm_out_data_o,
    input  wire    [NOC_ASYNC_FIFO_AWIDTH:0]        noc_fifo_pm_out_raddr_i,
    output wire    [NOC_ASYNC_FIFO_AWIDTH:0]        noc_fifo_pm_out_waddr_o,

    input wire                                      jtag_tck_i,
    input wire                                      jtag_tms_i,
    input wire                                      jtag_tdi_i,
    output wire                                     jtag_tdo_o,
    output wire                                     jtag_tdo_en_o,

    output wire                                     uart_tx_o,
    input  wire                                     uart_rx_i
);


generate
if (PM_CORE_SELECT == PM_TYPE_ROCKET) begin: rocket
    pm_rocket #(
        .HOME_MODID                 (HOME_MODID),
        .PM_UART_ATTACHED           (PM_UART_ATTACHED),
        .CLKFREQ_MHZ                (CLKFREQ_MHZ)
    ) i_pm_rocket (
        .clk_pm_i                   (clk_pm_i),
        .reset_pm_n_i               (reset_pm_n_i),
        .home_chipid_i              (home_chipid_i),
        .host_chipid_i              (host_chipid_i),
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
end
else if (PM_CORE_SELECT == PM_TYPE_BOOM) begin: boom
    pm_boom #(
        .HOME_MODID                 (HOME_MODID),
        .PM_UART_ATTACHED           (PM_UART_ATTACHED),
        .CLKFREQ_MHZ                (CLKFREQ_MHZ)
    ) i_pm_boom (
        .clk_pm_i                   (clk_pm_i),
        .reset_pm_n_i               (reset_pm_n_i),
        .home_chipid_i              (home_chipid_i),
        .host_chipid_i              (host_chipid_i),
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
end
else begin: none
    assign noc_fifo_pm_in_raddr_o = {NOC_ASYNC_FIFO_AWIDTH{1'b0}};
    assign noc_fifo_pm_out_data_o = {NOC_ASYNC_FIFO_PACKET_SIZE{1'b0}};
    assign noc_fifo_pm_out_waddr_o = {NOC_ASYNC_FIFO_AWIDTH{1'b0}};
    assign jtag_tdo_o = 1'b0;
    assign jtag_tdo_en_o = 1'b0;
    assign uart_tx_o = 1'b1;
end
endgenerate

endmodule
