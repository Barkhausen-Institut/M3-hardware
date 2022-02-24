
module noc_link_par_async_phy #(
    `include "noc_parameter.vh"
)
(
    input  wire                        clk_rx_i,
    input  wire                        clk_tx_i,
    input  wire                        rst_q_i,
    input  wire                        testmode_i,

    //noc_link tx
    input  wire                        tx_wrreq_i,
    input  wire [NOC_HEADER_SIZE-1:0]  tx_header_i,
    input  wire [NOC_PAYLOAD_SIZE-1:0] tx_payload_i,
    output wire                        tx_stall_o,

    //fifo tx
    input  wire [NOC_ASYNC_FIFO_AWIDTH:0]        tx_fifo_read_addr_i,
    output wire [NOC_ASYNC_FIFO_AWIDTH:0]        tx_fifo_write_addr_o,
    output wire [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] tx_fifo_read_data_o,

    //noc_link rx
    input  wire                        rx_rdreq_i,
    output wire [NOC_HEADER_SIZE-1:0]  rx_header_o,
    output wire [NOC_PAYLOAD_SIZE-1:0] rx_payload_o,
    output wire                        rx_fifo_empty_o,

    //fifo rx
    output wire [NOC_ASYNC_FIFO_AWIDTH:0]        rx_fifo_read_addr_o,
    input  wire [NOC_ASYNC_FIFO_AWIDTH:0]        rx_fifo_write_addr_i,
    input  wire [NOC_ASYNC_FIFO_PACKET_SIZE-1:0] rx_fifo_read_data_i
);

    wire [NOC_HEADER_SIZE-1:0]  rx_header;
    wire [NOC_PAYLOAD_SIZE-1:0] rx_payload;
    wire                        rx_fifo_empty;
    wire                        rx_rdreq;

    reg [NOC_HEADER_SIZE-1:0]   rx_header_reg, rx_header_regin;
    reg [NOC_PAYLOAD_SIZE-1:0]  rx_payload_reg, rx_payload_regin;

    reg                         rx_fifo_empty_reg, rx_fifo_empty_regin;


    assign rx_header_o     = rx_header_reg;
    assign rx_payload_o    = rx_payload_reg;

    assign rx_fifo_empty_o = rx_fifo_empty_reg;
    assign rx_rdreq        = rx_rdreq_i || (rx_fifo_empty_reg & (!rx_fifo_empty));



    always @(posedge clk_rx_i or negedge rst_q_i) begin
        if (rst_q_i==1'b0) begin
            rx_fifo_empty_reg <= 1'b1;
            rx_header_reg     <= {NOC_HEADER_SIZE{1'b0}};
            rx_payload_reg    <= {NOC_PAYLOAD_SIZE{1'b0}};
        end
        else begin
            rx_fifo_empty_reg <= rx_fifo_empty_regin;
            rx_header_reg     <= rx_header_regin;
            rx_payload_reg    <= rx_payload_regin;
        end
    end

    always @* begin
        rx_fifo_empty_regin = rx_fifo_empty;

        rx_header_regin     = rx_header_reg;
        rx_payload_regin    = rx_payload_reg;

        //if FIFO becomes empty, was not previously empty, but there is no read-req, then there is still something in the FIFO
        if (rx_rdreq_i==1'b0 && rx_fifo_empty==1'b1 && rx_fifo_empty_reg==1'b0) begin
            rx_fifo_empty_regin = 1'b0;
        end

        //only take the values from the FIFO when they are requested
        if (rx_rdreq) begin
            rx_header_regin  = rx_header;
            rx_payload_regin = rx_payload;
        end
    end



    async_fifo_in #(
        .ADDR_WIDTH(NOC_ASYNC_FIFO_AWIDTH),
        .DATA_WIDTH(NOC_ASYNC_FIFO_PACKET_SIZE)
    ) i_async_fifo_in(
        .wclk_i(clk_tx_i),
        .aresetn_i(rst_q_i),
        .scan_mode_i(testmode_i),
        .wr_en_i(tx_wrreq_i),
        .wdata_i({tx_header_i, tx_payload_i}),
        .rd_ptr_i(tx_fifo_read_addr_i),
        .wfull_o(tx_stall_o),
        .walmost_full_o(),
        .wr_ptr_o(tx_fifo_write_addr_o),
        .rdata_o(tx_fifo_read_data_o)
    );

    async_fifo_out #(
        .ADDR_WIDTH(NOC_ASYNC_FIFO_AWIDTH),
        .DATA_WIDTH(NOC_ASYNC_FIFO_PACKET_SIZE)
    ) i_async_fifo_out (
        .rclk_i           (clk_rx_i),
        .aresetn_i        (rst_q_i),
        .scan_mode_i      (testmode_i),
        .rd_en_i          (rx_rdreq),
        .wr_ptr_i         (rx_fifo_write_addr_i),
        .rdata_i          (rx_fifo_read_data_i),
        .rempty_o         (rx_fifo_empty),
        .ralmost_empty_o  (),
        .rdata_o          ({rx_header, rx_payload}),
        .rd_ptr_o         (rx_fifo_read_addr_o)
    );


endmodule
