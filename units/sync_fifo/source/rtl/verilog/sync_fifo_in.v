
module sync_fifo_in #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 4
)(
    input  wire                   clk_i,
    input  wire                   resetn_i,

    input  wire                   fifo_write_en_h_i,
    input  wire  [DATA_WIDTH-1:0] fifo_write_data_i,
    output reg                    fifo_full_h_o,

    input  wire    [ADDR_WIDTH:0] read_addr_i,
    output wire    [ADDR_WIDTH:0] write_addr_o,
    output wire  [DATA_WIDTH-1:0] read_data_o
);

    localparam DEPTH = (1 << ADDR_WIDTH);

    wire   [ADDR_WIDTH:0] rd_ptr;
    reg    [ADDR_WIDTH:0] wr_ptr;
    wire [ADDR_WIDTH-1:0] waddr;
    wire [ADDR_WIDTH-1:0] raddr;

    reg  [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    assign waddr = wr_ptr[ADDR_WIDTH-1:0];
    assign raddr = read_addr_i[ADDR_WIDTH-1:0];
    assign write_addr_o = wr_ptr;
    assign rd_ptr = read_addr_i[ADDR_WIDTH:0];

    always @(posedge clk_i or negedge resetn_i) begin
        if (resetn_i == 1'b0) begin
            wr_ptr <= 'h0;
        end else if (fifo_write_en_h_i & (~fifo_full_h_o)) begin
            wr_ptr <= wr_ptr + {{ADDR_WIDTH{1'b0}}, 1'b1};
        end
    end

    always @(rd_ptr or wr_ptr) begin
        fifo_full_h_o = 1'b0;
        if ((rd_ptr[ADDR_WIDTH-1:0] == wr_ptr[ADDR_WIDTH-1:0]) &&
            (rd_ptr[ADDR_WIDTH] != wr_ptr[ADDR_WIDTH])) begin
            fifo_full_h_o  = 1'b1;
        end
    end

    always @(posedge clk_i) begin
        if (fifo_write_en_h_i && (~fifo_full_h_o)) begin
            mem[waddr] <= fifo_write_data_i;
        end
    end

    assign read_data_o = mem[raddr];

endmodule
