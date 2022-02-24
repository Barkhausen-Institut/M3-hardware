
module sync_fifo_out #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 4
)(
    input  wire                   clk_i,
    input  wire                   resetn_i,

    input  wire    [ADDR_WIDTH:0] write_addr_i,
    output wire    [ADDR_WIDTH:0] read_addr_o,
    input  wire  [DATA_WIDTH-1:0] read_data_i,

    input  wire                   fifo_read_en_h_i,
    output wire  [DATA_WIDTH-1:0] fifo_read_data_o,
    output reg                    fifo_empty_h_o
);

    localparam DEPTH = (1 << ADDR_WIDTH);

    wire [ADDR_WIDTH:0] wr_ptr;
    reg  [ADDR_WIDTH:0] rd_ptr;

    assign wr_ptr = write_addr_i;
    assign read_addr_o = rd_ptr;

    always @(posedge clk_i or negedge resetn_i) begin
        if (resetn_i == 1'b0) begin
            rd_ptr <= 'h0;
        end else if (fifo_read_en_h_i & (~fifo_empty_h_o)) begin
            rd_ptr <= rd_ptr + {{ADDR_WIDTH{1'b0}}, 1'b1};
        end
    end

    always @(rd_ptr or wr_ptr) begin
        fifo_empty_h_o = 1'b0;
        if ((rd_ptr[ADDR_WIDTH-1:0] == wr_ptr[ADDR_WIDTH-1:0]) &&
            (rd_ptr[ADDR_WIDTH] == wr_ptr[ADDR_WIDTH])) begin
            fifo_empty_h_o = 1'b1;
        end
    end

    assign fifo_read_data_o = read_data_i;

endmodule
