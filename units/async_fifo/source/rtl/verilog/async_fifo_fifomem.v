
module async_fifomem #(
    parameter DATA_WIDTH       = 16,
    parameter ADDR_WIDTH       = 4,
    parameter WRITE_BLOCK_SIZE = DATA_WIDTH  //number of bits for individual write enable
)(
    input  wire                   wclk_i,
    input  wire                   wr_en_i,
    input  wire  [DATA_WIDTH-1:0] wdata_i,
    input  wire  [ADDR_WIDTH-1:0] waddr_i,

    input  wire  [ADDR_WIDTH-1:0] raddr_i,
    output wire  [DATA_WIDTH-1:0] rdata_o
);


    reg [DATA_WIDTH-1:0] reg_array [0:(1<<ADDR_WIDTH)-1];

    assign rdata_o = reg_array[raddr_i];

    always @(posedge wclk_i) begin
        if (wr_en_i == 1'b1) begin
            reg_array[waddr_i] <= wdata_i;
        end
    end

endmodule
