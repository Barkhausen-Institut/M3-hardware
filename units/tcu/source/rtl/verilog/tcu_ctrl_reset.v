
module tcu_ctrl_reset
(
    input  wire clk_i,
    input  wire reset_n_i,
    output wire reset_sync_n_o,
    input  wire tcu_reset_i
);


    reg       r_tcu_reset, rin_tcu_reset;
    reg [3:0] r_tcu_reset_count, rin_tcu_reset_count;


    always @(posedge clk_i or negedge reset_n_i) begin
        if(reset_n_i == 1'b0) begin
            r_tcu_reset <= 1'b0;
            r_tcu_reset_count <= 4'd0;
        end else begin
            r_tcu_reset <= rin_tcu_reset;
            r_tcu_reset_count <= rin_tcu_reset_count;
        end
    end
    
    always @* begin
        rin_tcu_reset = 1'b0;
        rin_tcu_reset_count = r_tcu_reset_count;
        
        //tcu_reset_i is valid for only 1 cycle
        //when counter overflows to 0, tcu_reset_all turns off
        if (tcu_reset_i || (r_tcu_reset_count > 4'd0)) begin
            rin_tcu_reset_count = r_tcu_reset_count + 4'd1;
            rin_tcu_reset = 1'b1;
        end
    end


    util_reset_sync i_reset_sync_tcu_ctrl (
        .clk_i           (clk_i),
        .reset_q_i       (reset_n_i & (~r_tcu_reset)),
        .scan_mode_i     (1'b0),
        .sync_reset_q_o  (reset_sync_n_o)
    );


endmodule
