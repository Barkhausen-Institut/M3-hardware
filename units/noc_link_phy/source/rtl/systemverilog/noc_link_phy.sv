
module noc_link_phy #(
    `include "noc_parameter.vh"
    ,parameter SYNCHRONOUS = 0
)(
    input  wire                        clk_i,
    input  wire                        rst_q_i,
    input  wire                        testmode_i,

    // transmitter in/out
    input  wire                        tx_wrreq_i,
    input  wire [NOC_HEADER_SIZE-1:0]  tx_header_i,
    input  wire [NOC_PAYLOAD_SIZE-1:0] tx_payload_i,
    output wire                        tx_stall_o,

    noc_link_if.tx                     tx_if,

    // receiver in/out
    input  wire                        rx_rdreq_i,
    output wire [NOC_HEADER_SIZE-1:0]  rx_header_o,
    output wire [NOC_PAYLOAD_SIZE-1:0] rx_payload_o,
    output wire                        rx_fifo_empty_o,

    noc_link_if.rx                     rx_if
);

    wire [NOC_HEADER_SIZE-1:0]  rx_header;
    wire [NOC_PAYLOAD_SIZE-1:0] rx_payload;
    wire                        rx_fifo_empty;
    wire                        rx_rdreq;

    reg [NOC_HEADER_SIZE-1:0]   rx_header_reg;
    reg [NOC_PAYLOAD_SIZE-1:0]  rx_payload_reg;
    reg                         rx_fifo_empty_reg;
    reg                         is_empty_reg;

    assign rx_header_o = rx_header_reg;
    assign rx_payload_o = rx_payload_reg;
    assign rx_fifo_empty_o = rx_fifo_empty_reg;
    assign rx_rdreq = rx_rdreq_i || (is_empty_reg & (!rx_fifo_empty));


    always @(posedge clk_i) begin
        if (rx_rdreq_i==1'b1 || (is_empty_reg==1'b1 && rx_fifo_empty==1'b0)) begin
            rx_header_reg <= rx_header;
            rx_payload_reg <= rx_payload;
        end
    end

    always @(posedge clk_i or negedge rst_q_i) begin
        if (rst_q_i==1'b0) begin
            rx_fifo_empty_reg <= 1'b1;
            is_empty_reg <= 1'b1;
        end
        else begin
            if (rx_rdreq_i==1'b1 || (is_empty_reg==1'b1 && rx_fifo_empty==1'b0)) begin
                rx_fifo_empty_reg <= rx_fifo_empty;
            end
            if ((rx_rdreq_i==1'b1 || is_empty_reg==1'b1) && rx_fifo_empty==1'b1) begin
                is_empty_reg <= 1'b1;
            end
            else begin
                is_empty_reg <= 1'b0;
            end
        end
    end


    generate
    // ******** PARALLEL RX *********//

    if (SYNCHRONOUS == 1) begin: SYNCHRONOUS_PHY
        sync_fifo_in #(
            .ADDR_WIDTH(NOC_ASYNC_FIFO_AWIDTH),
            .DATA_WIDTH(NOC_ASYNC_FIFO_PACKET_SIZE)
        ) i_sync_fifo_in (
            .clk_i(clk_i),
            .resetn_i(rst_q_i),
            .fifo_write_en_h_i(tx_wrreq_i),
            .fifo_write_data_i({tx_header_i, tx_payload_i}),
            .fifo_full_h_o(tx_stall_o),
            .read_addr_i(tx_if.fifo_read_addr),
            .write_addr_o(tx_if.fifo_write_addr),
            .read_data_o(tx_if.fifo_read_data)
        );

        sync_fifo_out #(
            .ADDR_WIDTH(NOC_ASYNC_FIFO_AWIDTH),
            .DATA_WIDTH(NOC_ASYNC_FIFO_PACKET_SIZE)
        ) i_sync_fifo_out (
            .fifo_empty_h_o(rx_fifo_empty),
            .fifo_read_data_o({rx_header, rx_payload}),
            .fifo_read_en_h_i(rx_rdreq),
            .clk_i(clk_i),
            .read_addr_o(rx_if.fifo_read_addr),
            .read_data_i(rx_if.fifo_read_data),
            .resetn_i(rst_q_i),
            .write_addr_i(rx_if.fifo_write_addr)
        );
    end

    else begin: ASYNCHRONOUS_PHY
        async_fifo_in #(
            .ADDR_WIDTH(NOC_ASYNC_FIFO_AWIDTH),
            .DATA_WIDTH(NOC_ASYNC_FIFO_PACKET_SIZE)
        ) i_async_fifo_in(
            .wclk_i(clk_i),
            .aresetn_i(rst_q_i),
            .scan_mode_i(testmode_i),
            .wr_en_i(tx_wrreq_i),
            .wdata_i({tx_header_i, tx_payload_i}),
            .rd_ptr_i(tx_if.fifo_read_addr),
            .wfull_o(tx_stall_o),
            .walmost_full_o(),
            .wr_ptr_o(tx_if.fifo_write_addr),
            .rdata_o(tx_if.fifo_read_data)
        );

        async_fifo_out #(
            .ADDR_WIDTH(NOC_ASYNC_FIFO_AWIDTH),
            .DATA_WIDTH(NOC_ASYNC_FIFO_PACKET_SIZE)
        ) i_async_fifo_out (
            .rclk_i           (clk_i),
            .aresetn_i        (rst_q_i),
            .scan_mode_i      (testmode_i),
            .rd_en_i          (rx_rdreq),
            .wr_ptr_i         (rx_if.fifo_write_addr),
            .rdata_i          (rx_if.fifo_read_data),
            .rempty_o         (rx_fifo_empty),
            .ralmost_empty_o  (),
            .rdata_o          ({rx_header, rx_payload}),
            .rd_ptr_o         (rx_if.fifo_read_addr)
        );
    end

    // ******** PARALLEL RX *********//
    endgenerate

endmodule
