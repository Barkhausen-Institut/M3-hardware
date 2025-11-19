
module ethernet_mdio_wrap #(
    parameter SIMULATION = 0
)
(
    input  wire               clk_eth_i,
    input  wire               rst_eth_n_i,

    output wire               mdio_mdc,
    input  wire               mdio_mdio_i,
    output wire               mdio_mdio_o,
    output wire               mdio_mdio_t
);

reg [25:0] delay_reg = 25'hfffff;
reg [4:0] mdio_cmd_phy_addr = 5'h03;
reg [4:0] mdio_cmd_reg_addr = 5'h00;
reg [15:0] mdio_cmd_data = 16'd0;
reg [1:0] mdio_cmd_opcode = 2'b01;
reg mdio_cmd_valid = 1'b0;
wire mdio_cmd_ready;
wire [15:0] mdio_data_out;
wire        mdio_data_out_valid;

wire [1:0] aux_mdio_cmd_opcode;

reg [4:0] state_reg = 5'd0;

assign  rst = !rst_eth_n_i;
// assign aux_mdio_cmd_opcode = (state_reg >= 5'd16) ? 2'b10 : 2'b01;


always @(posedge clk_eth_i) begin
    if (rst) begin
        state_reg <= 5'd0;
        delay_reg <= 25'hfffff;
        mdio_cmd_reg_addr <= 5'h00;
        mdio_cmd_data <= 16'h1140;
        mdio_cmd_valid <= 1'b0;
    end else begin
        mdio_cmd_valid <= mdio_cmd_valid & !mdio_cmd_ready;
        if (delay_reg > 0) begin
            delay_reg <= delay_reg - 1;
        end else if (!mdio_cmd_ready) begin
            // wait for ready
            state_reg <= state_reg;
        end else begin
            mdio_cmd_valid <= 1'b0;
            case (state_reg)
                // perform SW reset - 0x00 val: 0x8000
                5'd0: begin
                    mdio_cmd_reg_addr <= 5'h00;
                    mdio_cmd_data <= 16'h8000;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= state_reg + 5'd1;
                    delay_reg <= 25'd25000000; // 200 ms delay
                end
                // wait for delay to end
                5'd1: begin
                    mdio_cmd_valid <= 1'b0;
                    state_reg <= state_reg + 5'd1;
                end
                // reinit 0x00 register - 0x00 val: 0x0000
                5'd2: begin
                    mdio_cmd_reg_addr <= 5'h00;
                    mdio_cmd_data <= 16'h0000;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= state_reg + 5'd1;
                end
                // enable SGMII clock output: SPECIAL REG - 0x00D3 val: 0x4000
                // write 0x4000 to SGMIICTL1 (0x00D3) (special reg - 4 following states)
                5'd3: begin
                    // write to REGCR to load address
                    mdio_cmd_reg_addr <= 5'h0D;
                    mdio_cmd_data <= 16'h001F;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= state_reg + 5'd1;
                end
                5'd4: begin
                    // write address of SGMIICTL1 to ADDAR
                    mdio_cmd_reg_addr <= 5'h0E;
                    mdio_cmd_data <= 16'h00D3;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= state_reg + 5'd1;
                end
                5'd5: begin
                    // write to REGCR to load data
                    mdio_cmd_reg_addr <= 5'h0D;
                    mdio_cmd_data <= 16'h401F;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= state_reg + 5'd1;
                end
                5'd6: begin
                    // write data for SGMIICTL1 to ADDAR
                    mdio_cmd_reg_addr <= 5'h0E;
                    mdio_cmd_data <= 16'h4000;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= state_reg + 5'd1;
                end
                // enable speed and autonegotiation (REG 0x0 - val: 0x1300)
                5'd7: begin
                    // write to REGCR to load address
                    mdio_cmd_reg_addr <= 5'h00;
                    mdio_cmd_data <= 16'h1300;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= state_reg + 5'd1;
                end
                // enable SGMII (REG 0x10 - val: 0x5848)
                5'd8: begin
                    mdio_cmd_reg_addr <= 5'h10;
                    mdio_cmd_data <= 16'h5848;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= state_reg + 5'd1;
                end
                // enable 1000BASE-T speed (REG 0x9 - val: 0x0300)
                5'd9: begin
                    mdio_cmd_reg_addr <= 5'h9;
                    mdio_cmd_data <= 16'h0300;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= state_reg + 5'd1;
                end
                // enable speed optimization and SGMII autonegociation (REG 0x14 - val: 0x2BC0)
                5'd10: begin
                    mdio_cmd_reg_addr <= 5'h14;
                    mdio_cmd_data <= 16'h2BC0;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= state_reg + 5'd1;
                end
                // Set autonegociation timer to 11ms (REG 0x31 - val: 0x0070)
                // special register (4 states from here)
                5'd11: begin
                    // write to REGCR to load address
                    mdio_cmd_reg_addr <= 5'h0D;
                    mdio_cmd_data <= 16'h001F;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= state_reg + 5'd1;
                end
                5'd12: begin
                    // write address of CFG4 to ADDAR
                    mdio_cmd_reg_addr <= 5'h0E;
                    mdio_cmd_data <= 16'h0031;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= state_reg + 5'd1;
                end
                5'd13: begin
                    // write to REGCR to load data
                    mdio_cmd_reg_addr <= 5'h0D;
                    mdio_cmd_data <= 16'h401F;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= state_reg + 5'd1;
                end
                5'd14: begin
                    // write data for CFG4 to ADDAR
                    mdio_cmd_reg_addr <= 5'h0E;
                    mdio_cmd_data <= 16'h0070;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= state_reg + 5'd1;
                end
                // disable RGMII (REG 0x32 - val: 0x00)
                // special register (4 states from here)
                5'd15: begin
                    // write to REGCR to load address
                    mdio_cmd_reg_addr <= 5'h0D;
                    mdio_cmd_data <= 16'h001F;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= state_reg + 5'd1;
                end
                5'd16: begin
                    // write address of CFG4 to ADDAR
                    mdio_cmd_reg_addr <= 5'h0E;
                    mdio_cmd_data <= 16'h0032;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= state_reg + 5'd1;
                end
                5'd17: begin
                    // write to REGCR to load data
                    mdio_cmd_reg_addr <= 5'h0D;
                    mdio_cmd_data <= 16'h401F;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= state_reg + 5'd1;
                end
                5'd18: begin
                    // write data into register
                    mdio_cmd_reg_addr <= 5'h0E;
                    mdio_cmd_data <= 16'h0000;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= state_reg + 5'd1;
                end
                // end state
                5'd19: begin
                    state_reg <= 5'd19;
                end
            endcase
        end
    end
end

// reg [19:0] delay_reg = SIMULATION ? 20'h1a00 : 20'hfffff;
//
// reg [4:0] mdio_cmd_phy_addr = 5'h03;
// reg [4:0] mdio_cmd_reg_addr = 5'h00;
// reg [15:0] mdio_cmd_data = 16'd0;
// reg [1:0] mdio_cmd_opcode = 2'b01;
// reg mdio_cmd_valid = 1'b0;
// wire mdio_cmd_ready;
//
// reg [3:0] state_reg = 0;
//
//
// always @(posedge clk_eth_i) begin
//     if (rst_eth_n_i == 1'b0) begin
//         state_reg <= 0;
//         delay_reg <= SIMULATION ? 20'h1a00 : 20'hfffff;
//         mdio_cmd_reg_addr <= 5'h00;
//         mdio_cmd_data <= 16'd0;
//         mdio_cmd_valid <= 1'b0;
//     end else begin
//         mdio_cmd_valid <= mdio_cmd_valid & !mdio_cmd_ready;
//         if (delay_reg > 0) begin
//             delay_reg <= delay_reg - 1;
//         end else if (!mdio_cmd_ready) begin
//             // wait for ready
//             state_reg <= state_reg;
//         end else begin
//             mdio_cmd_valid <= 1'b0;
//             case (state_reg)
//                 // set SGMII autonegotiation timer to 11 ms
//                 // write 0x0070 to CFG4 (0x0031)
//                 4'd0: begin
//                     // write to REGCR to load address
//                     mdio_cmd_reg_addr <= 5'h0D;
//                     mdio_cmd_data <= 16'h001F;
//                     mdio_cmd_valid <= 1'b1;
//                     state_reg <= 4'd1;
//                 end
//                 4'd1: begin
//                     // write address of CFG4 to ADDAR
//                     mdio_cmd_reg_addr <= 5'h0E;
//                     mdio_cmd_data <= 16'h0031;
//                     mdio_cmd_valid <= 1'b1;
//                     state_reg <= 4'd2;
//                 end
//                 4'd2: begin
//                     // write to REGCR to load data
//                     mdio_cmd_reg_addr <= 5'h0D;
//                     mdio_cmd_data <= 16'h401F;
//                     mdio_cmd_valid <= 1'b1;
//                     state_reg <= 4'd3;
//                 end
//                 4'd3: begin
//                     // write data for CFG4 to ADDAR
//                     mdio_cmd_reg_addr <= 5'h0E;
//                     mdio_cmd_data <= 16'h0070;
//                     mdio_cmd_valid <= 1'b1;
//                     state_reg <= 4'd4;
//                 end
//                 // enable SGMII clock output
//                 // write 0x4000 to SGMIICTL1 (0x00D3)
//                 4'd4: begin
//                     // write to REGCR to load address
//                     mdio_cmd_reg_addr <= 5'h0D;
//                     mdio_cmd_data <= 16'h001F;
//                     mdio_cmd_valid <= 1'b1;
//                     state_reg <= 4'd5;
//                 end
//                 4'd5: begin
//                     // write address of SGMIICTL1 to ADDAR
//                     mdio_cmd_reg_addr <= 5'h0E;
//                     mdio_cmd_data <= 16'h00D3;
//                     mdio_cmd_valid <= 1'b1;
//                     state_reg <= 4'd6;
//                 end
//                 4'd6: begin
//                     // write to REGCR to load data
//                     mdio_cmd_reg_addr <= 5'h0D;
//                     mdio_cmd_data <= 16'h401F;
//                     mdio_cmd_valid <= 1'b1;
//                     state_reg <= 4'd7;
//                 end
//                 4'd7: begin
//                     // write data for SGMIICTL1 to ADDAR
//                     mdio_cmd_reg_addr <= 5'h0E;
//                     mdio_cmd_data <= 16'h4000;
//                     mdio_cmd_valid <= 1'b1;
//                     state_reg <= 4'd8;
//                 end
//                 // enable 10Mbps operation
//                 // write 0x0015 to 10M_SGMII_CFG (0x016F)
//                 4'd8: begin
//                     // write to REGCR to load address
//                     mdio_cmd_reg_addr <= 5'h0D;
//                     mdio_cmd_data <= 16'h001F;
//                     mdio_cmd_valid <= 1'b1;
//                     state_reg <= 4'd9;
//                 end
//                 4'd9: begin
//                     // write address of 10M_SGMII_CFG to ADDAR
//                     mdio_cmd_reg_addr <= 5'h0E;
//                     mdio_cmd_data <= 16'h016F;
//                     mdio_cmd_valid <= 1'b1;
//                     state_reg <= 4'd10;
//                 end
//                 4'd10: begin
//                     // write to REGCR to load data
//                     mdio_cmd_reg_addr <= 5'h0D;
//                     mdio_cmd_data <= 16'h401F;
//                     mdio_cmd_valid <= 1'b1;
//                     state_reg <= 4'd11;
//                 end
//                 4'd11: begin
//                     // write data for 10M_SGMII_CFG to ADDAR
//                     mdio_cmd_reg_addr <= 5'h0E;
//                     mdio_cmd_data <= 16'h0015;
//                     mdio_cmd_valid <= 1'b1;
//                     state_reg <= 4'd12;
//                 end
//                 4'd12: begin
//                     // done
//                     state_reg <= 4'd12;
//                 end
//             endcase
//         end
//     end
// end


mdio_master mdio_master_inst (
    .clk            (clk_eth_i),
    .rst            (~rst_eth_n_i),

    .cmd_phy_addr   (mdio_cmd_phy_addr),
    .cmd_reg_addr   (mdio_cmd_reg_addr),
    .cmd_data       (mdio_cmd_data),
    .cmd_opcode     (mdio_cmd_opcode),
    .cmd_valid      (mdio_cmd_valid),
    .cmd_ready      (mdio_cmd_ready),

    .data_out       (),
    .data_out_valid (),
    .data_out_ready (1'b1),

    .mdc_o          (mdio_mdc),
    .mdio_i         (mdio_mdio_i),
    .mdio_o         (mdio_mdio_o),
    .mdio_t         (mdio_mdio_t),

    .busy           (),

    .prescale       (8'd3)
);



endmodule
