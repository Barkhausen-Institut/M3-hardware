
module async_fifo_out #(
    parameter DATA_WIDTH          = 16, //data width
    parameter ADDR_WIDTH          = 3,  //adress width
    parameter ALMOST_EMPTY_BUFFER = 2   //number of written entries until almost_empty
)(
    input  wire                   aresetn_i,
    input  wire                   scan_mode_i,

    input  wire                   rclk_i,
    input  wire                   rd_en_i,
    output wire  [DATA_WIDTH-1:0] rdata_o,
    output wire    [ADDR_WIDTH:0] rd_ptr_o,         //to async_fifo_in
    output wire                   ralmost_empty_o,
    output wire                   rempty_o,

    input  wire    [ADDR_WIDTH:0] wr_ptr_i,         //from async_fifo_in
    input  wire  [DATA_WIDTH-1:0] rdata_i           //from async_fifo_in
);


    wire                rresetn;
    wire [ADDR_WIDTH:0] rsync_wr_ptr;

    assign rdata_o = rdata_i;

    util_reset_sync i_reset_sync_w2r (
        .clk_i          (rclk_i),
        .reset_q_i      (aresetn_i),
        .scan_mode_i    (scan_mode_i),
        .sync_reset_q_o (rresetn)
    );

    util_sync #(
        .WIDTH     (ADDR_WIDTH+1)
    ) i_sync_w2r (
        .clk_i     (rclk_i),
        .reset_n_i (rresetn),
        .data_i    (wr_ptr_i),
        .data_o    (rsync_wr_ptr)
    );

    async_fifo_rptr_empty_ctrl #(
        .ADDR_WIDTH          (ADDR_WIDTH),
        .ALMOST_EMPTY_BUFFER (ALMOST_EMPTY_BUFFER)
    ) i_rptr_empty_ctrl (
        .rclk_i              (rclk_i),
        .rresetn_i           (rresetn),
        .rd_en_i             (rd_en_i),
        .rsync_wr_ptr_i      (rsync_wr_ptr),
        .ralmost_empty_o     (ralmost_empty_o),
        .rempty_o            (rempty_o),
        .rd_ptr_o            (rd_ptr_o)
    );

endmodule
