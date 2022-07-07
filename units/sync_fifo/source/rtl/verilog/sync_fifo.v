
module sync_fifo #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 4,
    parameter USE_MEM = 0
)(
    input wire                    clk_i,
    input wire                    resetn_i,

    input  wire                   wr_en_i,
    input  wire  [DATA_WIDTH-1:0] wdata_i,
    output reg                    wfull_o,

    input  wire                   rd_en_i,
    output wire  [DATA_WIDTH-1:0] rdata_o,
    output wire                   rempty_o
);

    localparam DEPTH = (1 << ADDR_WIDTH);

    generate
    if (USE_MEM) begin: SYNC_FIFO_MEM

        reg    [ADDR_WIDTH:0] r_rd_ptr, rin_rd_ptr;
        reg    [ADDR_WIDTH:0] r_wr_ptr, rin_wr_ptr;
        reg                   rin_rempty;
        reg                   r_rempty2, rin_rempty2;

        wire [ADDR_WIDTH-1:0] waddr = r_wr_ptr[ADDR_WIDTH-1:0];
        wire [ADDR_WIDTH-1:0] raddr = rin_rd_ptr[ADDR_WIDTH-1:0];

        wire [ADDR_WIDTH:0] rd_ptr2 = r_rd_ptr + 1;

        wire wr_en_s = wr_en_i & !wfull_o;
        wire rd_en_s = rd_en_i & !rempty_o;

        //rempty2 indicates if last element in FIFO will be access
        //if so, set FIFO to empty because mem-based FIFO needs one cycle more to release the next element
        //in other words: if (rin_rempty2 && !r_rempty2) == 1, the last element in FIFO is the next element to be released,
        //wait a cycle because it wasn't read from mem yet
        assign rempty_o = rin_rempty || (rin_rempty2 && !r_rempty2);


        always @(posedge clk_i or negedge resetn_i) begin
            if (resetn_i == 1'b0) begin
                r_rd_ptr <= 'h0;
                r_wr_ptr <= 'h0;
            end else begin
                r_rd_ptr <= rin_rd_ptr;
                r_wr_ptr <= rin_wr_ptr;
            end
        end

        always @* begin
            rin_wr_ptr = r_wr_ptr;
            if (wr_en_s) begin
                rin_wr_ptr = r_wr_ptr + {{ADDR_WIDTH{1'b0}}, 1'b1};
            end
        end

        always @* begin
            rin_rd_ptr = r_rd_ptr;
            if (rd_en_s) begin
                rin_rd_ptr = r_rd_ptr + {{ADDR_WIDTH{1'b0}}, 1'b1};
            end
        end

        always @(r_rd_ptr or r_wr_ptr) begin
            wfull_o = 1'b0;
            if ((r_rd_ptr[ADDR_WIDTH-1:0] == r_wr_ptr[ADDR_WIDTH-1:0]) &&
                (r_rd_ptr[ADDR_WIDTH] != r_wr_ptr[ADDR_WIDTH])) begin
                wfull_o = 1'b1;
            end
        end

        always @(posedge clk_i or negedge resetn_i) begin
            if (resetn_i == 1'b0) begin
                r_rempty2 <= 1'b0;
            end else begin
                r_rempty2 <= wr_en_s ? 1'b0 : rin_rempty2;
            end
        end

        always @(r_rd_ptr or r_wr_ptr) begin
            rin_rempty = 1'b0;
            if ((r_rd_ptr[ADDR_WIDTH-1:0] == r_wr_ptr[ADDR_WIDTH-1:0]) &&
                (r_rd_ptr[ADDR_WIDTH] == r_wr_ptr[ADDR_WIDTH])) begin
                rin_rempty = 1'b1;
            end
        end

        always @* begin
            rin_rempty2 = 1'b0;
            if ((rd_ptr2[ADDR_WIDTH-1:0] == r_wr_ptr[ADDR_WIDTH-1:0]) &&
                (rd_ptr2[ADDR_WIDTH] == r_wr_ptr[ADDR_WIDTH])) begin
                rin_rempty2 = 1'b1;
            end
        end


        mem_tp_wrap #(
            .MEM_TYPE("auto"),
            .MEM_DATAWIDTH(DATA_WIDTH),
            .MEM_ADDRWIDTH(ADDR_WIDTH)
        ) fifo_mem (
            .clk    (clk_i),
            .reset  (~resetn_i),

            .ena    (wr_en_s),
            .wea    ({((DATA_WIDTH+7)/8){1'b1}}),
            .addra  (waddr),
            .dina   (wdata_i),

            .enb    (!rin_rempty),
            .addrb  (raddr),
            .doutb  (rdata_o)
        );


    end
    else begin: SYNC_FIFO

        reg    [ADDR_WIDTH:0] rd_ptr;
        reg    [ADDR_WIDTH:0] wr_ptr;
        wire [ADDR_WIDTH-1:0] waddr;
        wire [ADDR_WIDTH-1:0] raddr;
        reg                   rin_rempty;

        reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

        assign waddr = wr_ptr[ADDR_WIDTH-1:0];
        assign raddr = rd_ptr[ADDR_WIDTH-1:0];

        assign rempty_o = rin_rempty;


        always @(posedge clk_i or negedge resetn_i) begin
            if (resetn_i == 1'b0) begin
                wr_ptr <= 'h0;
            end else if (wr_en_i & (~wfull_o)) begin
                wr_ptr <= wr_ptr + {{ADDR_WIDTH{1'b0}}, 1'b1};
            end
        end

        always @(posedge clk_i or negedge resetn_i) begin
            if (resetn_i == 1'b0) begin
                rd_ptr <= 'h0;
            end else if (rd_en_i & (~rempty_o)) begin
                rd_ptr <= rd_ptr + {{ADDR_WIDTH{1'b0}}, 1'b1};
            end
        end

        always @(rd_ptr or wr_ptr) begin
            wfull_o = 1'b0;
            if ((rd_ptr[ADDR_WIDTH-1:0] == wr_ptr[ADDR_WIDTH-1:0]) &&
                (rd_ptr[ADDR_WIDTH] != wr_ptr[ADDR_WIDTH])) begin
                wfull_o = 1'b1;
            end
        end

        always @(rd_ptr or wr_ptr) begin
            rin_rempty = 1'b0;
            if ((rd_ptr[ADDR_WIDTH-1:0] == wr_ptr[ADDR_WIDTH-1:0]) &&
                (rd_ptr[ADDR_WIDTH] == wr_ptr[ADDR_WIDTH])) begin
                rin_rempty = 1'b1;
            end
        end

        always @(posedge clk_i) begin
            if (wr_en_i & (~wfull_o)) begin
                mem[waddr] <= wdata_i;
            end
        end

        assign rdata_o = mem[raddr];

    end
    endgenerate


endmodule
