
module async_fifo_rptr_empty_ctrl #(
    parameter ADDR_WIDTH          = 4,
    parameter ALMOST_EMPTY_BUFFER = 2
)(
    input  wire                 rclk_i,
    input  wire                 rresetn_i,
    input  wire                 rd_en_i,
    input  wire  [ADDR_WIDTH:0] rsync_wr_ptr_i,   //gray coded
    output wire                 ralmost_empty_o,
    output wire                 rempty_o,
    output reg   [ADDR_WIDTH:0] rd_ptr_o         //gray coded
);


    // increment buffer to threshold so we can use < instead of <=
    localparam ALMOST_EMPTY_THRESHOLD = ALMOST_EMPTY_BUFFER[ADDR_WIDTH:0] + {{(ADDR_WIDTH){1'b0}}, 1'b1};

    reg [ADDR_WIDTH:0] rd_ptr_bin;
    reg [ADDR_WIDTH:0] next_rd_ptr;      //gray coded
    reg [ADDR_WIDTH:0] next_rd_ptr_bin;
    reg [ADDR_WIDTH:0] rsync_wr_ptr_bin;

    wire do_read;
    wire [ADDR_WIDTH:0] wr_rd_diff = rsync_wr_ptr_bin - rd_ptr_bin;

    integer i;

    // calculate and assign next grey pointer
    always @(posedge rclk_i or negedge rresetn_i) begin
        if (rresetn_i == 1'b0) begin
            rd_ptr_o <= 0;
        end else begin
            rd_ptr_o <= next_rd_ptr;
        end
    end

    // read
    assign do_read = rd_en_i & (~rempty_o);

    always @(rd_ptr_o or do_read or rsync_wr_ptr_i) begin
        //gray to binary code conversion
        for (i=0; i<=ADDR_WIDTH; i=i+1) begin
            rd_ptr_bin[i] = ^(rd_ptr_o>>i);
            rsync_wr_ptr_bin[i] = ^(rsync_wr_ptr_i>>i);
        end

        //increment binary rd pointer
        next_rd_ptr_bin = rd_ptr_bin + {{(ADDR_WIDTH){1'b0}}, do_read};

        //binary to gray code conversion
        next_rd_ptr = (next_rd_ptr_bin>>1) ^ next_rd_ptr_bin;
    end


    // empty control signal
    assign rempty_o = (rd_ptr_o == rsync_wr_ptr_i) ? 1'b1 : 1'b0;

    // almost_empty control signal
    assign ralmost_empty_o = wr_rd_diff < ALMOST_EMPTY_THRESHOLD;

endmodule
