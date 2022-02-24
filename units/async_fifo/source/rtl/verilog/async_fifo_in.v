
module async_fifo_in #(
    parameter DATA_WIDTH         = 16, //data width
    parameter ADDR_WIDTH         = 3,  //adress width
    parameter ALMOST_FULL_BUFFER = 2   //number of free entries until almost_full
)(
    input  wire                   aresetn_i,
    input  wire                   scan_mode_i,

    output wire    [ADDR_WIDTH:0] wr_ptr_o,       //to async_fifo_out
    output wire  [DATA_WIDTH-1:0] rdata_o,        //to async_fifo_out

    input  wire                   wclk_i,
    input  wire                   wr_en_i,
    input  wire  [DATA_WIDTH-1:0] wdata_i,
    input  wire    [ADDR_WIDTH:0] rd_ptr_i,       //from async_fifo_out
    output wire                   walmost_full_o,
    output wire                   wfull_o
);


    wire                wresetn;
    wire [ADDR_WIDTH:0] wsync_rd_ptr;

    util_reset_sync i_reset_sync_r2w (
        .clk_i          (wclk_i),
        .reset_q_i      (aresetn_i),
        .scan_mode_i    (scan_mode_i),
        .sync_reset_q_o (wresetn)
    );

    util_sync #(
        .WIDTH     (ADDR_WIDTH+1)
    ) i_sync_r2w (
        .clk_i     (wclk_i),
        .reset_n_i (wresetn),
        .data_i    (rd_ptr_i),
        .data_o    (wsync_rd_ptr)
    );

    async_fifo_wptr_full_ctrl #(
        .ADDR_WIDTH         (ADDR_WIDTH),
        .ALMOST_FULL_BUFFER (ALMOST_FULL_BUFFER)
    ) i_wptr_full_ctrl (
        .wclk_i             (wclk_i),
        .wresetn_i          (wresetn),
        .wr_en_i            (wr_en_i),
        .wsync_rd_ptr_i     (wsync_rd_ptr),
        .walmost_full_o     (walmost_full_o),
        .wfull_o            (wfull_o),
        .wr_ptr_o           (wr_ptr_o)
    );


    // calculate adresses out of grey code pointer
    wire raddr_msb = rd_ptr_i[ADDR_WIDTH] ^ rd_ptr_i[ADDR_WIDTH-1];
    wire waddr_msb = wr_ptr_o[ADDR_WIDTH] ^ wr_ptr_o[ADDR_WIDTH-1];

    wire [ADDR_WIDTH-1:0] raddr;
    wire [ADDR_WIDTH-1:0] waddr;

    generate
        if (ADDR_WIDTH >= 2) begin: GEN_2PLUS
            assign raddr = {raddr_msb, rd_ptr_i[ADDR_WIDTH-2:0]};
            assign waddr = {waddr_msb, wr_ptr_o[ADDR_WIDTH-2:0]};
        end else begin: GEN_1
            assign raddr = raddr_msb;
            assign waddr = waddr_msb;
        end
    endgenerate


    async_fifomem #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) i_async_fifomem (
        .wclk_i     (wclk_i),
        .waddr_i    (waddr),
        .raddr_i    (raddr),
        .wr_en_i    (wr_en_i && ~wfull_o),
        .wdata_i    (wdata_i),
        .rdata_o    (rdata_o)
    );

endmodule
