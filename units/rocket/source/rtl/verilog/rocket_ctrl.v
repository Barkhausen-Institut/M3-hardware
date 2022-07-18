
module rocket_ctrl
(
    input  wire           clk_i,
    output wire           clk_core_o,
    input  wire           core_en_i,
    output wire           reset_core_n_o,
    input  wire           reset_n_i
);


wire core_en_sync;


`ifndef XILINX_FPGA

util_clkgate i_util_clkgate_ctrl (
    .clk_i(clk_i),
    .clk_o(clk_core_o),
    .en_i(core_en_i),
    .testmode_i(1'b0)
);

`else

assign clk_core_o = clk_i;

`endif

util_sync i_util_sync_ctrl (
    .clk_i(clk_i),
    .data_i(core_en_i),
    .data_o(core_en_sync),
    .reset_n_i(reset_n_i)
);



    reg r_reset_n, rin_reset_n;
    reg [2:0] r_core_delay_count, rin_core_delay_count;

    always @(posedge clk_i or negedge reset_n_i) begin
        if(!reset_n_i) begin
            r_reset_n <= 1'b0;
            r_core_delay_count <= 3'd0;
        end else begin
            r_reset_n <= rin_reset_n;
            r_core_delay_count <= rin_core_delay_count;
        end
    end

    always @(*) begin
        rin_reset_n = 1'b0;
        rin_core_delay_count = r_core_delay_count;

        if(core_en_sync) begin
            if(r_core_delay_count == 3'd7) begin
                rin_reset_n = 1'b1;
            end else if(r_core_delay_count < 3'd7) begin
                rin_core_delay_count = r_core_delay_count + 3'd1;
            end
        end else begin
            rin_core_delay_count = 3'd0;
        end
    end


    assign reset_core_n_o = r_reset_n;


endmodule
