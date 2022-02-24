
module async_fifo #(
    parameter DATA_WIDTH          = 16, //data width
    parameter ADDR_WIDTH          = 2,  //adress width
    parameter ALMOST_FULL_BUFFER  = 2,  //number free entries until almost_full
    parameter ALMOST_EMPTY_BUFFER = 2   //number written entries until almost_empty
)(
    input  wire                   aresetn_i,
    input  wire                   scan_mode_i,

    input  wire                   rclk_i,
    input  wire                   rd_en_i,
    output wire  [DATA_WIDTH-1:0] rdata_o,
    output wire                   ralmost_empty_o,
    output wire                   rempty_o,

    input  wire                   wclk_i,
    input  wire                   wr_en_i,
    input  wire  [DATA_WIDTH-1:0] wdata_i,
    output wire                   walmost_full_o,
    output wire                   wfull_o
);


    wire   [ADDR_WIDTH:0] wr_ptr;   //wr pointer, source wclk
    wire   [ADDR_WIDTH:0] rd_ptr;   //rd pointer, source rclk
    wire [DATA_WIDTH-1:0] rdata;    //read data


    async_fifo_in #(
        .DATA_WIDTH         (DATA_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .ALMOST_FULL_BUFFER (ALMOST_FULL_BUFFER)
    ) i_async_fifo_in (
        .aresetn_i          (aresetn_i),
        .scan_mode_i        (scan_mode_i),

        .wr_ptr_o           (wr_ptr),
        .rdata_o            (rdata),

        .wclk_i             (wclk_i),
        .wr_en_i            (wr_en_i),
        .wdata_i            (wdata_i),
        .rd_ptr_i           (rd_ptr),
        .walmost_full_o     (walmost_full_o),
        .wfull_o            (wfull_o)
    );

    async_fifo_out #(
        .DATA_WIDTH          (DATA_WIDTH),
        .ADDR_WIDTH          (ADDR_WIDTH),
        .ALMOST_EMPTY_BUFFER (ALMOST_EMPTY_BUFFER)
    ) i_async_fifo_out (
        .aresetn_i           (aresetn_i),
        .scan_mode_i         (scan_mode_i),

        .rclk_i              (rclk_i),
        .rd_en_i             (rd_en_i),
        .rdata_o             (rdata_o),
        .rd_ptr_o            (rd_ptr),
        .ralmost_empty_o     (ralmost_empty_o),
        .rempty_o            (rempty_o),

        .wr_ptr_i            (wr_ptr),
        .rdata_i             (rdata)
    );


endmodule
