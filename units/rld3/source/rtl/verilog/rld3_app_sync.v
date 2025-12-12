module rld3_app_sync #(
    // Part: MT44K32M36RB-107E (1.125Gb, x36) x 2 Components
    // Physical Data Width = 72 bits. Burst Length = 4.

    // BRIDGE SIDE WIDTHS (Single Atomic Request)
    parameter BRIDGE_ADDR_WIDTH   = 20,  // 20 bits per command
    parameter BRIDGE_BANK_WIDTH   = 4,   // 4 bits per command
    parameter BRIDGE_CMD_WIDTH    = 2,   // 2 bits (Wr/Rd)
    parameter BRIDGE_DATA_WIDTH   = 288, // 72 bit phy * BL4 = 288 bits
    parameter BRIDGE_MASK_WIDTH   = 16,  // 288 bits / 18-bit-granularity = 16 bits

    // IP SIDE PARAMETERS (Aggregated User Interface)
    parameter CMD_PER_CLK         = 2,   // From .xci "C0.RLD3_CMD_PER_CLK"

    // Calculated IP Widths
    parameter IP_ADDR_WIDTH       = BRIDGE_ADDR_WIDTH * CMD_PER_CLK, // 40
    parameter IP_BANK_WIDTH       = BRIDGE_BANK_WIDTH * CMD_PER_CLK, // 8
    parameter IP_CMD_WIDTH        = 4,                               // 2 bits * 2 slots = 4
    parameter IP_DATA_WIDTH       = 576,                             // From .xci [575:0]
    parameter IP_MASK_WIDTH       = 32,                              // From .xci [31:0]
    parameter IP_VALID_WIDTH      = 2                                // From .xci [1:0]
)
(
    // =========================================================================
    // 1. TCU / System Domain (mem_clk)
    // =========================================================================
    input  wire                             mem_clk_i,
    input  wire                             mem_rst_i,

    // Input from Bridge (Single Command Request)
    input  wire [BRIDGE_ADDR_WIDTH-1:0]     bridge_app_addr_i,
    input  wire [BRIDGE_BANK_WIDTH-1:0]     bridge_app_ba_i,
    input  wire [BRIDGE_CMD_WIDTH-1:0]      bridge_app_cmd_i,
    input  wire                             bridge_app_en_i,
    input  wire                             bridge_app_wr_en_i,
    input  wire [BRIDGE_DATA_WIDTH-1:0]     bridge_app_wdf_data_i,
    input  wire [BRIDGE_MASK_WIDTH-1:0]     bridge_app_wdf_mask_i,

    output wire                             bridge_app_rdy_o,
    output wire                             bridge_app_wdf_rdy_o,

    // Output to Bridge (Read Data Return)
    output wire [BRIDGE_DATA_WIDTH-1:0]     bridge_app_rd_data_o,
    output wire                             bridge_app_rd_data_valid_o,

    // =========================================================================
    // 2. RLDRAM 3 UI Domain (rld3_ui_clk)
    // =========================================================================
    input  wire                             rld3_ui_clk_i,
    input  wire                             rld3_ui_rst_i,

    // Outputs to RLDRAM 3 IP
    output wire [IP_ADDR_WIDTH-1:0]         rld3_user_addr_o,
    output wire [IP_BANK_WIDTH-1:0]         rld3_user_ba_o,
    output reg  [IP_CMD_WIDTH-1:0]          rld3_user_cmd_o,
    output reg                              rld3_user_cmd_en_o,
    output reg                              rld3_user_wr_en_o,
    output wire [IP_DATA_WIDTH-1:0]         rld3_user_wr_data_o,
    output wire [IP_MASK_WIDTH-1:0]         rld3_user_wr_dm_o,

    // Status Inputs from RLDRAM 3 IP
    input  wire                             rld3_user_afifo_full_i,
    input  wire                             rld3_user_wdfifo_full_i,

    // Read Data Inputs from RLDRAM 3 IP
    input  wire [IP_DATA_WIDTH-1:0]         rld3_user_rd_data_i,
    input  wire [IP_VALID_WIDTH-1:0]        rld3_user_rd_valid_i
);

    // =========================================================================
    // Parameters & Signals
    // =========================================================================
    localparam [BRIDGE_CMD_WIDTH-1:0] CMD_WRITE = 2'b00;
    localparam [BRIDGE_CMD_WIDTH-1:0] CMD_READ  = 2'b01;
    localparam [BRIDGE_CMD_WIDTH-1:0] CMD_NOP   = 2'b10; // or 2'b11

    localparam RD_WR_THRESHOLD = 20;

    // Bridge -> RLD3 FIFO Signals
    reg  bridge2rld_pop;
    wire bridge2rld_fifo_full;
    wire bridge2rld_empty;

    // FIFO Output Wires (Single Command Width)
    wire [BRIDGE_DATA_WIDTH-1:0]    fifo_wdf_data;
    wire [BRIDGE_MASK_WIDTH-1:0]    fifo_wdf_mask;
    wire [BRIDGE_ADDR_WIDTH-1:0]    fifo_addr;
    wire [BRIDGE_BANK_WIDTH-1:0]    fifo_ba;
    wire [BRIDGE_CMD_WIDTH-1:0]     fifo_cmd;
    wire                            fifo_wr_en_flag;

    // RLD3 -> Bridge FIFO Signals
    wire rld2bridge_pop;
    wire rld2bridge_fifo_full;
    wire rld2bridge_fifo_almost_full;
    wire rld2bridge_empty;

    // =========================================================================
    // 1. Bridge to RLD3 FIFO (Request Path)
    // =========================================================================
    async_fifo #(
        .DATA_WIDTH (BRIDGE_DATA_WIDTH +
                     BRIDGE_MASK_WIDTH +
                     BRIDGE_ADDR_WIDTH +
                     BRIDGE_BANK_WIDTH +
                     BRIDGE_CMD_WIDTH +
                     1),
        .ADDR_WIDTH (4)
    ) bridge2rld_fifo (
        .rclk_i          (rld3_ui_clk_i),
        .wclk_i          (mem_clk_i),
        .aresetn_i       (~rld3_ui_rst_i),
        .scan_mode_i     (1'b0),

        .wr_en_i         (bridge_app_en_i),
        .wdata_i         ({bridge_app_wdf_data_i,
                           bridge_app_wdf_mask_i,
                           bridge_app_addr_i,
                           bridge_app_ba_i,
                           bridge_app_cmd_i,
                           bridge_app_wr_en_i}),
        .wfull_o         (bridge2rld_fifo_full),
        .walmost_full_o  (),

        .rd_en_i         (bridge2rld_pop),
        .rdata_o         ({fifo_wdf_data,
                           fifo_wdf_mask,
                           fifo_addr,
                           fifo_ba,
                           fifo_cmd,
                           fifo_wr_en_flag}),
        .rempty_o        (bridge2rld_empty),
        .ralmost_empty_o ()
    );

    // =========================================================================
    // 2. MAPPING LOGIC (Single Request -> Slot 0)
    // =========================================================================

    // ------------------------------------
    // Slot 0 Mapping (Active Request)
    // ------------------------------------
    wire [BRIDGE_ADDR_WIDTH-1:0] slot0_addr = fifo_addr;
    wire [BRIDGE_BANK_WIDTH-1:0] slot0_ba   = fifo_ba;
    wire [BRIDGE_CMD_WIDTH-1:0]  slot0_cmd  = fifo_cmd;

    // ------------------------------------
    // Slot 1 Mapping (Always NOP / Zero)
    // ------------------------------------
    wire [BRIDGE_ADDR_WIDTH-1:0] slot1_addr = {BRIDGE_ADDR_WIDTH{1'b0}};
    wire [BRIDGE_BANK_WIDTH-1:0] slot1_ba   = {BRIDGE_BANK_WIDTH{1'b0}};
    wire [BRIDGE_CMD_WIDTH-1:0]  slot1_cmd  = CMD_NOP; // NOP unused slot

    // ------------------------------------
    // Aggregated Outputs to IP
    // ------------------------------------
    // Address/Bank: Concatenate {Slot1, Slot0}
    assign rld3_user_addr_o = {slot1_addr, slot0_addr};
    assign rld3_user_ba_o   = {slot1_ba,   slot0_ba};

    // Data: Map FIFO data to Lower bits (Slot 0), Zero Upper bits
    assign rld3_user_wr_data_o = {{(IP_DATA_WIDTH - BRIDGE_DATA_WIDTH){1'b0}}, fifo_wdf_data};
    assign rld3_user_wr_dm_o   = {{(IP_MASK_WIDTH - BRIDGE_MASK_WIDTH){1'b0}}, fifo_wdf_mask};

    // ------------------------------------
    // Drive Logic
    // ------------------------------------
    always @* begin
        // Default: No command, Drive NOPs
        rld3_user_cmd_en_o = 1'b0;
        rld3_user_wr_en_o  = 1'b0;
        // Default Command Bus: {NOP, NOP} (assuming NOP=2'b10 or 2'b11)
        rld3_user_cmd_o    = {CMD_NOP, CMD_NOP};

        bridge2rld_pop     = 1'b0;

        if (!bridge2rld_empty) begin
            // If FIFO has a request, we map it to Slot 0

            if (fifo_cmd == CMD_WRITE) begin
                if (!rld3_user_afifo_full_i && !rld3_user_wdfifo_full_i) begin
                    rld3_user_cmd_en_o = 1'b1;
                    rld3_user_wr_en_o  = 1'b1;
                    rld3_user_cmd_o    = {CMD_NOP, slot0_cmd}; // Slot1=NOP, Slot0=Write
                    bridge2rld_pop     = 1'b1;
                end
            end
            else begin // READ
                // Check backpressure on Read Return FIFO as well
                if (!rld3_user_afifo_full_i && !rld2bridge_fifo_full && !rld2bridge_fifo_almost_full) begin
                    rld3_user_cmd_en_o = 1'b1;
                    rld3_user_wr_en_o  = 1'b0;
                    rld3_user_cmd_o    = {CMD_NOP, slot0_cmd}; // Slot1=NOP, Slot0=Read
                    bridge2rld_pop     = 1'b1;
                end
            end
        end
    end

    assign bridge_app_rdy_o     = !bridge2rld_fifo_full;
    assign bridge_app_wdf_rdy_o = !bridge2rld_fifo_full;

    // =========================================================================
    // 3. RLD3 to Bridge FIFO (Read Return Path)
    // =========================================================================
    // We only care about data returning for Slot 0.
    // user_rd_valid[0] indicates data for Slot 0.
    // Data for Slot 0 is in the lower bits of user_rd_data.

    async_fifo #(
        .DATA_WIDTH         (BRIDGE_DATA_WIDTH),
        .ADDR_WIDTH         (5),
        .ALMOST_FULL_BUFFER (RD_WR_THRESHOLD)
    ) rld2bridge_fifo (
        .rclk_i             (mem_clk_i),
        .wclk_i             (rld3_ui_clk_i),
        .aresetn_i          (~mem_rst_i),
        .scan_mode_i        (1'b0),

        // Write Enable: Asserted if Valid[0] is high
        .wr_en_i            (rld3_user_rd_valid_i[0]),
        // Data: Capture lower 288 bits
        .wdata_i            (rld3_user_rd_data_i[BRIDGE_DATA_WIDTH-1:0]),

        .wfull_o            (rld2bridge_fifo_full),
        .walmost_full_o     (rld2bridge_fifo_almost_full),

        .rd_en_i            (rld2bridge_pop),
        .rdata_o            (bridge_app_rd_data_o),
        .rempty_o           (rld2bridge_empty),
        .ralmost_empty_o    ()
    );

    assign rld2bridge_pop             = !rld2bridge_empty;
    assign bridge_app_rd_data_valid_o = rld2bridge_pop;

endmodule
