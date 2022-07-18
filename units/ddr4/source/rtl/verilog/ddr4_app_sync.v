
module ddr4_app_sync #(
    `include "ddr4_user_parameter.vh"
)
(
    //TCU clk
    input  wire                             mem_clk_i,
    input  wire                             mem_rst_i,

    //input from bridge: synchronous to mem_clk
    input  wire   [DDR4_APP_ADDR_WIDTH-1:0] bridge_app_addr_i,
    input  wire    [DDR4_APP_CMD_WIDTH-1:0] bridge_app_cmd_i,
    input  wire                             bridge_app_en_i,
    input  wire   [DDR4_APP_DATA_WIDTH-1:0] bridge_app_wdf_data_i,
    input  wire                             bridge_app_wdf_end_i,
    input  wire [DDR4_APP_DATA_WIDTH/8-1:0] bridge_app_wdf_mask_i,
    input  wire                             bridge_app_wdf_wren_i,
    output wire                             bridge_app_rdy_o,
    output wire                             bridge_app_wdf_rdy_o,

    //output to bridge: synchronous to mem_clk
    output wire   [DDR4_APP_DATA_WIDTH-1:0] bridge_app_rd_data_o,
    output wire                             bridge_app_rd_data_end_o,
    output wire                             bridge_app_rd_data_valid_o,

    //DDR4 clk
    input  wire                             ddr4_ui_clk_i,
    input  wire                             ddr4_ui_rst_i,

    //output to DDR4
    output wire   [DDR4_APP_ADDR_WIDTH-1:0] ddr4_app_addr_o,
    output reg     [DDR4_APP_CMD_WIDTH-1:0] ddr4_app_cmd_o,
    output reg                              ddr4_app_en_o,
    output wire   [DDR4_APP_DATA_WIDTH-1:0] ddr4_app_wdf_data_o,
    output reg                              ddr4_app_wdf_end_o,
    output wire [DDR4_APP_DATA_WIDTH/8-1:0] ddr4_app_wdf_mask_o,
    output reg                              ddr4_app_wdf_wren_o,
    input  wire                             ddr4_app_rdy_i,
    input  wire                             ddr4_app_wdf_rdy_i,

    //input from DDR4
    input  wire   [DDR4_APP_DATA_WIDTH-1:0] ddr4_app_rd_data_i,
    input  wire                             ddr4_app_rd_data_end_i,
    input  wire                             ddr4_app_rd_data_valid_i
);


    localparam [DDR4_APP_CMD_WIDTH-1:0] APP_CMD_WRITE = 0;
    localparam [DDR4_APP_CMD_WIDTH-1:0] APP_CMD_READ  = 1;

    localparam RD_WR_THRESHOLD = 20;     //max 20 (TCU) cycles read latency

    reg bridge2ddr_pop;


    wire bridge2ddr_fifo_full;
    wire bridge2ddr_empty;

    wire ddr2bridge_pop;
    wire ddr2bridge_fifo_full;
    wire ddr2bridge_fifo_almost_full;
    wire ddr2bridge_empty;

    wire        [DDR4_APP_CMD_WIDTH-1:0] ddr4_app_cmd;      //unused
    wire                                 ddr4_app_wdf_wren;
    wire                                 ddr4_app_wdf_end;  //unused
    wire [DDR4_APP_DATA_CUT_WIDTH/8-1:0] ddr4_app_wdf_mask;
    wire   [DDR4_APP_DATA_CUT_WIDTH-1:0] ddr4_app_wdf_data;
    wire   [DDR4_APP_DATA_CUT_WIDTH-1:0] bridge_app_rd_data;



    async_fifo #(
        .DATA_WIDTH         (DDR4_APP_DATA_CUT_WIDTH+
                             1+1+(DDR4_APP_DATA_CUT_WIDTH/8)+
                             DDR4_APP_ADDR_WIDTH+DDR4_APP_CMD_WIDTH),
        .ADDR_WIDTH         (2)
    ) bridge2ddr_fifo (
        .rclk_i             (ddr4_ui_clk_i),
        .wclk_i             (mem_clk_i),
        .aresetn_i          (~ddr4_ui_rst_i),
        .scan_mode_i        (1'b0),

        .wr_en_i            (bridge_app_en_i),
        .wdata_i            ({bridge_app_wdf_data_i[DDR4_APP_DATA_CUT_WIDTH-1:0],
                              bridge_app_wdf_end_i, bridge_app_wdf_wren_i, bridge_app_wdf_mask_i[DDR4_APP_DATA_CUT_WIDTH/8-1:0],
                              bridge_app_addr_i, bridge_app_cmd_i}),
        .wfull_o            (bridge2ddr_fifo_full),
        .walmost_full_o     (),

        .rd_en_i            (bridge2ddr_pop),
        .rdata_o            ({ddr4_app_wdf_data,
                              ddr4_app_wdf_end, ddr4_app_wdf_wren, ddr4_app_wdf_mask,
                              ddr4_app_addr_o, ddr4_app_cmd}),
        .rempty_o           (bridge2ddr_empty),
        .ralmost_empty_o    ()
    );


    always @* begin
        ddr4_app_en_o = 1'b0;
        ddr4_app_cmd_o = APP_CMD_WRITE;
        ddr4_app_wdf_wren_o = 1'b0;
        ddr4_app_wdf_end_o = 1'b0;

        bridge2ddr_pop = 1'b0;


        if (!bridge2ddr_empty && ddr4_app_rdy_i) begin

            //write to DDR4
            if (ddr4_app_wdf_wren) begin
                if (ddr4_app_wdf_rdy_i) begin
                    ddr4_app_en_o = 1'b1;
                    ddr4_app_cmd_o = APP_CMD_WRITE;
                    ddr4_app_wdf_wren_o = 1'b1;
                    ddr4_app_wdf_end_o = 1'b1;

                    bridge2ddr_pop = 1'b1;
                end
            end

            //read from DDR4
            else if (!ddr2bridge_fifo_full && !ddr2bridge_fifo_almost_full) begin
                ddr4_app_en_o = 1'b1;
                ddr4_app_cmd_o = APP_CMD_READ;

                bridge2ddr_pop = 1'b1;
            end
        end
    end


    assign ddr4_app_wdf_mask_o = {{((DDR4_APP_DATA_WIDTH-DDR4_APP_DATA_CUT_WIDTH)/8){1'b1}}, ddr4_app_wdf_mask};
    assign ddr4_app_wdf_data_o = {{(DDR4_APP_DATA_WIDTH-DDR4_APP_DATA_CUT_WIDTH){1'b0}}, ddr4_app_wdf_data};

    assign bridge_app_rdy_o = !bridge2ddr_fifo_full;
    assign bridge_app_wdf_rdy_o = !bridge2ddr_fifo_full;



    async_fifo #(
        .DATA_WIDTH         (DDR4_APP_DATA_CUT_WIDTH),
        .ADDR_WIDTH         (5),
        .ALMOST_FULL_BUFFER (RD_WR_THRESHOLD)
    ) ddr2bridge_fifo (
        .rclk_i             (mem_clk_i),
        .wclk_i             (ddr4_ui_clk_i),
        .aresetn_i          (~mem_rst_i),
        .scan_mode_i        (1'b0),

        .wr_en_i            (ddr4_app_rd_data_valid_i && ddr4_app_rd_data_end_i),
        .wdata_i            (ddr4_app_rd_data_i[DDR4_APP_DATA_CUT_WIDTH-1:0]),
        .wfull_o            (ddr2bridge_fifo_full),
        .walmost_full_o     (ddr2bridge_fifo_almost_full),

        .rd_en_i            (ddr2bridge_pop),
        .rdata_o            (bridge_app_rd_data),
        .rempty_o           (ddr2bridge_empty),
        .ralmost_empty_o    ()
    );

    assign ddr2bridge_pop = !ddr2bridge_empty;

    assign bridge_app_rd_data_o = {{(DDR4_APP_DATA_WIDTH-DDR4_APP_DATA_CUT_WIDTH){1'b0}}, bridge_app_rd_data};
    assign bridge_app_rd_data_end_o = ddr2bridge_pop;
    assign bridge_app_rd_data_valid_o = ddr2bridge_pop;


endmodule
