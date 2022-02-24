
module noc_link_pm_rf_phy #(
    `include "noc_parameter.vh"
    ,parameter SYNCHRONOUS = 0
)(
    input  wire                        clk_i,
    input  wire                        rst_q_i,
    input  wire                        testmode_i,
    input  wire [NOC_CHIPID_SIZE-1:0]  home_chipid_i,

    //noc_link tx
    input  wire                        tx_wrreq_i,
    input  wire [NOC_HEADER_SIZE-1:0]  tx_header_i,
    input  wire [NOC_PAYLOAD_SIZE-1:0] tx_payload_i,
    output wire                        tx_stall_o,

    //noc_if tx
    noc_link_if.tx                     tx_if_pm,
    noc_link_if.tx                     tx_if_rf,

    //noc_link rx
    input  wire                        rx_rdreq_i,
    output wire [NOC_HEADER_SIZE-1:0]  rx_header_o,
    output wire [NOC_PAYLOAD_SIZE-1:0] rx_payload_o,
    output wire                        rx_fifo_empty_o,

    //noc_if rx
    noc_link_if.rx                     rx_if_pm,
    noc_link_if.rx                     rx_if_rf
);

    localparam NOC_ADDR_RF_SEL_SIZE = 8;

    wire [NOC_HEADER_SIZE-1:0]  rx_header_pm, rx_header_rf;
    wire [NOC_PAYLOAD_SIZE-1:0] rx_payload_pm, rx_payload_rf;
    wire                        rx_fifo_empty_pm, rx_fifo_empty_rf;
    wire                        rx_rdreq_pm, rx_rdreq_rf;

    wire                        tx_wrreq_pm, tx_wrreq_rf;
    wire [NOC_ADDR_RF_SEL_SIZE-1:0] tx_addr_rf_sel;
    wire [NOC_CHIPID_SIZE-1:0]  tx_trg_chipid;
    wire                        tx_stall_pm, tx_stall_rf;
    wire                        tx_burst;

    wire                        pm_fifo_active, rf_fifo_active;

    reg                         r_tx_burst, rin_tx_burst;
    reg                         r_tx_wrreq_sel_rf, rin_tx_wrreq_sel_rf;


    reg [NOC_HEADER_SIZE-1:0]   rx_header_reg, rx_header_regin;
    reg [NOC_PAYLOAD_SIZE-1:0]  rx_payload_reg, rx_payload_regin;
    reg                         rx_fifo_empty_reg_pm, rx_fifo_empty_regin_pm;
    reg                         rx_fifo_empty_reg_rf, rx_fifo_empty_regin_rf;



    assign rx_header_o = rx_header_reg;
    assign rx_payload_o = rx_payload_reg;

    assign rx_fifo_empty_o = rx_fifo_empty_reg_pm && rx_fifo_empty_reg_rf;

    //pm has priority over rf
    assign pm_fifo_active = !rx_fifo_empty_reg_pm || !rx_fifo_empty_pm;
    assign rf_fifo_active = (!rx_fifo_empty_reg_rf || !rx_fifo_empty_rf) && !pm_fifo_active;

    assign rx_rdreq_pm = pm_fifo_active ? rx_rdreq_i || (rx_fifo_empty_reg_pm && !rx_fifo_empty_pm) : 1'b0;
    assign rx_rdreq_rf = rf_fifo_active ? rx_rdreq_i || (rx_fifo_empty_reg_rf && !rx_fifo_empty_rf) : 1'b0;


    always @(posedge clk_i or negedge rst_q_i) begin
        if (rst_q_i==1'b0) begin
            rx_fifo_empty_reg_pm <= 1'b1;
            rx_fifo_empty_reg_rf <= 1'b1;
            rx_header_reg        <= {NOC_HEADER_SIZE{1'b0}};
            rx_payload_reg       <= {NOC_PAYLOAD_SIZE{1'b0}};
        end
        else begin
            rx_fifo_empty_reg_pm <= rx_fifo_empty_regin_pm;
            rx_fifo_empty_reg_rf <= rx_fifo_empty_regin_rf;
            rx_header_reg        <= rx_header_regin;
            rx_payload_reg       <= rx_payload_regin;
        end
    end

    always @* begin
        rx_header_regin  = rx_header_reg;
        rx_payload_regin = rx_payload_reg;

        rx_fifo_empty_regin_pm = rx_fifo_empty_pm;
        rx_fifo_empty_regin_rf = rx_fifo_empty_rf;

        if (pm_fifo_active) begin

            //do not allow to set rx_fifo_empty_o due to the the other FIFO
            rx_fifo_empty_regin_rf = 1'b1;

            //if FIFO becomes empty, was not previously empty, but there is no read-req, then there is still something in the FIFO
            if (rx_rdreq_i==1'b0 && rx_fifo_empty_pm==1'b1 && rx_fifo_empty_reg_pm==1'b0) begin
                rx_fifo_empty_regin_pm = 1'b0;
            end

            if (rx_rdreq_pm) begin
                rx_header_regin  = rx_header_pm;
                rx_payload_regin = rx_payload_pm;
            end

        end
        else if (rf_fifo_active) begin
            rx_fifo_empty_regin_pm = 1'b1;

            if (rx_rdreq_i==1'b0 && rx_fifo_empty_rf==1'b1 && rx_fifo_empty_reg_rf==1'b0) begin
                rx_fifo_empty_regin_rf = 1'b0;
            end

            if (rx_rdreq_rf) begin
                rx_header_regin  = rx_header_rf;
                rx_payload_regin = rx_payload_rf;
            end
        end

    end





    //during burst, hold addr_sel to keep pm-rf mux correct
    assign tx_burst = tx_header_i[NOC_HEADER_SIZE-1];

    always @(posedge clk_i, negedge rst_q_i) begin
        if (rst_q_i == 1'b0) begin
            r_tx_wrreq_sel_rf <= 1'b0;
            r_tx_burst        <= 1'b0;
        end else begin
            r_tx_wrreq_sel_rf <= rin_tx_wrreq_sel_rf;
            r_tx_burst        <= rin_tx_burst;
        end
    end

    always @* begin
        rin_tx_burst = r_tx_burst;
        if (!tx_stall_o) begin
            if (tx_wrreq_i) begin
                if (tx_burst) begin
                    rin_tx_burst = 1'b1;
                end else begin
                    rin_tx_burst = 1'b0;
                end
            end
        end
    end


    assign tx_addr_rf_sel = tx_payload_i[NOC_DATA_SIZE+NOC_ADDR_SIZE-1:NOC_DATA_SIZE+NOC_ADDR_SIZE-NOC_ADDR_RF_SEL_SIZE];
    assign tx_trg_chipid  = tx_header_i[NOC_CHIPID_SIZE-1:0];

    //mux between pm and rf for tx
    always @* begin
        rin_tx_wrreq_sel_rf = r_tx_wrreq_sel_rf;

        if (r_tx_burst == 1'b0) begin
            if ((tx_addr_rf_sel == {NOC_ADDR_RF_SEL_SIZE{1'b1}}) && (tx_trg_chipid == home_chipid_i)) begin
                rin_tx_wrreq_sel_rf = 1'b1;
            end else begin
                rin_tx_wrreq_sel_rf = 1'b0;
            end
        end
    end

    assign tx_wrreq_pm = rin_tx_wrreq_sel_rf ? 1'b0 : tx_wrreq_i;
    assign tx_wrreq_rf = rin_tx_wrreq_sel_rf ? tx_wrreq_i : 1'b0;
    assign tx_stall_o  = tx_stall_rf | tx_stall_pm;     //prevent timing loop




    generate
    // ******** PARALLEL RX *********//

    if (SYNCHRONOUS == 1) begin: SYNCHRONOUS_PHY
        sync_fifo_in #(
            .ADDR_WIDTH(NOC_ASYNC_FIFO_AWIDTH),
            .DATA_WIDTH(NOC_ASYNC_FIFO_PACKET_SIZE)
        ) i_sync_fifo_in_pm (
            .clk_i(clk_i),
            .resetn_i(rst_q_i),
            .fifo_write_en_h_i(tx_wrreq_i),
            .fifo_write_data_i({tx_header_i, tx_payload_i}),
            .fifo_full_h_o(tx_stall_o),
            .read_addr_i(tx_if_pm.fifo_read_addr),
            .write_addr_o(tx_if_pm.fifo_write_addr),
            .read_data_o(tx_if_pm.fifo_read_data)
        );

        sync_fifo_out #(
            .ADDR_WIDTH(NOC_ASYNC_FIFO_AWIDTH),
            .DATA_WIDTH(NOC_ASYNC_FIFO_PACKET_SIZE)
        ) i_sync_fifo_out_pm (
            .fifo_empty_h_o(rx_fifo_empty_pm),
            .fifo_read_data_o({rx_header_pm, rx_payload_pm}),
            .fifo_read_en_h_i(rx_rdreq_pm),
            .clk_i(clk_i),
            .read_addr_o(rx_if_pm.fifo_read_addr),
            .read_data_i(rx_if_pm.fifo_read_data),
            .resetn_i(rst_q_i),
            .write_addr_i(rx_if_pm.fifo_write_addr)
        );

        sync_fifo_in #(
            .ADDR_WIDTH(NOC_ASYNC_FIFO_AWIDTH),
            .DATA_WIDTH(NOC_ASYNC_FIFO_PACKET_SIZE)
        ) i_sync_fifo_in_rf (
            .clk_i(clk_i),
            .resetn_i(rst_q_i),
            .fifo_write_en_h_i(tx_wrreq_i),
            .fifo_write_data_i({tx_header_i, tx_payload_i}),
            .fifo_full_h_o(tx_stall_o),
            .read_addr_i(tx_if_rf.fifo_read_addr),
            .write_addr_o(tx_if_rf.fifo_write_addr),
            .read_data_o(tx_if_rf.fifo_read_data)
        );

        sync_fifo_out #(
            .ADDR_WIDTH(NOC_ASYNC_FIFO_AWIDTH),
            .DATA_WIDTH(NOC_ASYNC_FIFO_PACKET_SIZE)
        ) i_sync_fifo_out_rf (
            .fifo_empty_h_o(rx_fifo_empty_rf),
            .fifo_read_data_o({rx_header_rf, rx_payload_rf}),
            .fifo_read_en_h_i(rx_rdreq_rf),
            .clk_i(clk_i),
            .read_addr_o(rx_if_rf.fifo_read_addr),
            .read_data_i(rx_if_rf.fifo_read_data),
            .resetn_i(rst_q_i),
            .write_addr_i(rx_if_rf.fifo_write_addr)
        );
    end

    else begin: ASYNCHRONOUS_PHY
        async_fifo_in #(
            .ADDR_WIDTH(NOC_ASYNC_FIFO_AWIDTH),
            .DATA_WIDTH(NOC_ASYNC_FIFO_PACKET_SIZE)
        ) i_async_fifo_in_pm (
            .wclk_i(clk_i),
            .aresetn_i(rst_q_i),
            .scan_mode_i(testmode_i),
            .wr_en_i(tx_wrreq_pm),
            .wdata_i({tx_header_i, tx_payload_i}),
            .rd_ptr_i(tx_if_pm.fifo_read_addr),
            .wfull_o(tx_stall_pm),
            .walmost_full_o(),
            .wr_ptr_o(tx_if_pm.fifo_write_addr),
            .rdata_o(tx_if_pm.fifo_read_data)
        );

        async_fifo_out #(
            .ADDR_WIDTH(NOC_ASYNC_FIFO_AWIDTH),
            .DATA_WIDTH(NOC_ASYNC_FIFO_PACKET_SIZE)
        ) i_async_fifo_out_pm (
            .rclk_i           (clk_i),
            .aresetn_i        (rst_q_i),
            .scan_mode_i      (testmode_i),
            .rd_en_i          (rx_rdreq_pm),
            .wr_ptr_i         (rx_if_pm.fifo_write_addr),
            .rdata_i          (rx_if_pm.fifo_read_data),
            .rempty_o         (rx_fifo_empty_pm),
            .ralmost_empty_o  (),
            .rdata_o          ({rx_header_pm, rx_payload_pm}),
            .rd_ptr_o         (rx_if_pm.fifo_read_addr)
        );

        async_fifo_in #(
            .ADDR_WIDTH(NOC_ASYNC_FIFO_AWIDTH),
            .DATA_WIDTH(NOC_ASYNC_FIFO_PACKET_SIZE)
        ) i_async_fifo_in_rf (
            .wclk_i(clk_i),
            .aresetn_i(rst_q_i),
            .scan_mode_i(testmode_i),
            .wr_en_i(tx_wrreq_rf),
            .wdata_i({tx_header_i, tx_payload_i}),
            .rd_ptr_i(tx_if_rf.fifo_read_addr),
            .wfull_o(tx_stall_rf),
            .walmost_full_o(),
            .wr_ptr_o(tx_if_rf.fifo_write_addr),
            .rdata_o(tx_if_rf.fifo_read_data)
        );

        async_fifo_out #(
            .ADDR_WIDTH(NOC_ASYNC_FIFO_AWIDTH),
            .DATA_WIDTH(NOC_ASYNC_FIFO_PACKET_SIZE)
        ) i_async_fifo_out_rf (
            .rclk_i           (clk_i),
            .aresetn_i        (rst_q_i),
            .scan_mode_i      (testmode_i),
            .rd_en_i          (rx_rdreq_rf),
            .wr_ptr_i         (rx_if_rf.fifo_write_addr),
            .rdata_i          (rx_if_rf.fifo_read_data),
            .rempty_o         (rx_fifo_empty_rf),
            .ralmost_empty_o  (),
            .rdata_o          ({rx_header_rf, rx_payload_rf}),
            .rd_ptr_o         (rx_if_rf.fifo_read_addr)
        );
    end

    // ******** PARALLEL RX *********//
    endgenerate

endmodule
