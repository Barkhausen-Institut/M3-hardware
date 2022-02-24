
module async_fifo_wptr_full_ctrl #(
    parameter ADDR_WIDTH         = 4,
    parameter ALMOST_FULL_BUFFER = 2
)(
    input  wire                 wclk_i,
    input  wire                 wresetn_i,
    input  wire                 wr_en_i,
    input  wire  [ADDR_WIDTH:0] wsync_rd_ptr_i,  //gray coded
    output wire                 walmost_full_o,
    output wire                 wfull_o,
    output reg   [ADDR_WIDTH:0] wr_ptr_o        //gray coded
);


    // increment buffer to threshold so we can use < instead of <=
    localparam ALMOST_FULL_THRESHOLD = ALMOST_FULL_BUFFER[ADDR_WIDTH:0] + {{(ADDR_WIDTH){1'b0}}, 1'b1};

    reg [ADDR_WIDTH:0] wr_ptr_bin;
    reg [ADDR_WIDTH:0] next_wr_ptr;  //gray coded
    reg [ADDR_WIDTH:0] next_wr_ptr_bin;
    reg [ADDR_WIDTH:0] wsync_rd_ptr_bin;

    integer i;

    // calculate and assign next grey pointer
    always @(posedge wclk_i or negedge wresetn_i) begin
        if (wresetn_i == 1'b0) begin
            wr_ptr_o <= 0;
        end else begin
            wr_ptr_o <= next_wr_ptr;
        end
    end

    always @(wr_ptr_o or wr_en_i or wfull_o or wsync_rd_ptr_i) begin
        //gray to binary code conversion
        for (i=0; i<=ADDR_WIDTH; i=i+1) begin
            wr_ptr_bin[i] = ^(wr_ptr_o>>i);
            wsync_rd_ptr_bin[i] = ^(wsync_rd_ptr_i>>i);
        end

        //increment binary pointer
        next_wr_ptr_bin = wr_ptr_bin + {{(ADDR_WIDTH){1'b0}}, (wr_en_i & ~wfull_o)};

        //binary to gray code conversion
        next_wr_ptr = (next_wr_ptr_bin>>1) ^ next_wr_ptr_bin;
    end

    // full control signal
    wire wptr_msb = wr_ptr_o[ADDR_WIDTH] ^ wr_ptr_o[ADDR_WIDTH-1];
    wire rptr_msb = wsync_rd_ptr_i[ADDR_WIDTH] ^ wsync_rd_ptr_i[ADDR_WIDTH-1];
    wire f_condition1 = wr_ptr_o[ADDR_WIDTH] != wsync_rd_ptr_i[ADDR_WIDTH];
    wire f_condition2 = rptr_msb == wptr_msb;
    wire f_condition3;

    generate
        if (ADDR_WIDTH >= 2) begin: GEN_2PLUS
            assign f_condition3 = wr_ptr_o[ADDR_WIDTH-2:0] == wsync_rd_ptr_i[ADDR_WIDTH-2:0];
        end else begin: GEN_1
            assign f_condition3 = 1'b1;
        end
    endgenerate

    assign wfull_o = f_condition1 && f_condition2 && f_condition3;

    // almost_full control signal
    wire [ADDR_WIDTH:0] rd_wr_diff = wsync_rd_ptr_bin - wr_ptr_bin;
    wire                af_condition = {1'b0, rd_wr_diff[ADDR_WIDTH-1:0]} < ALMOST_FULL_THRESHOLD;
    wire                not_full_empty = rd_wr_diff[ADDR_WIDTH:0] != {(ADDR_WIDTH+1){1'b0}};

    assign walmost_full_o = (af_condition && not_full_empty);

endmodule
