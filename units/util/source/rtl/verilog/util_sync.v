
module util_sync #(
    parameter WIDTH = 1
)(
    input  wire             clk_i,
    input  wire             reset_n_i,
    input  wire [WIDTH-1:0] data_i,
    output wire [WIDTH-1:0] data_o
);

`ifdef XILINX

    (* ASYNC_REG = "TRUE", KEEP = "TRUE" *)
    reg [WIDTH-1:0] data_sync0;
    (* ASYNC_REG = "TRUE", KEEP = "TRUE" *)
    reg [WIDTH-1:0] data_sync1;

    assign data_o = data_sync1;

    always @(posedge clk_i or negedge reset_n_i) begin
        if (reset_n_i == 1'b0) begin
            data_sync0 <= {WIDTH{1'b0}};
            data_sync1 <= {WIDTH{1'b0}};
        end else begin
            data_sync0 <= data_i;
            data_sync1 <= data_sync0;
        end
    end

`else

    reg [WIDTH-1:0] data_sync0;
    reg [WIDTH-1:0] data_sync1;

    assign data_o = data_sync1;

    always @(posedge clk_i or negedge reset_n_i) begin
        if (reset_n_i == 1'b0) begin
            data_sync0 <= {WIDTH{1'b0}};
            data_sync1 <= {WIDTH{1'b0}};
        end else begin
            data_sync0 <= data_i;
            data_sync1 <= data_sync0;
        end
    end

`endif

endmodule
