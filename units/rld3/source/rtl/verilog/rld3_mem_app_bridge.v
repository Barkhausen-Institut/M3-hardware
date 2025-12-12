module rld3_mem_app_bridge #(
    // Default Parameters (Override these or use .vh files)
    parameter TCU_MEM_ADDR_SIZE   = 40,
    parameter TCU_MEM_DATA_SIZE   = 512, // Example System Width
    parameter TCU_MEM_BSEL_SIZE   = 64,  // 512/8

    // RLDRAM 3 Specifics (Based on MT44K32M36RB-107E x 2)
    parameter RLD3_APP_ADDR_WIDTH = 20,
    parameter RLD3_APP_BANK_WIDTH = 4,
    parameter RLD3_APP_CMD_WIDTH  = 2,
    parameter RLD3_APP_DATA_WIDTH = 288, // 72-bit * BL4
    parameter RLD3_ADDR_SHIFT     = 5    // 2^5 = 32 bytes (effective addressing)
)(
    input  wire                              mem_clk_i,
    input  wire                              mem_reset_n_i,

    // -------------------------------------------------------------------------
    // TCU / Memory Interface
    // -------------------------------------------------------------------------
    input  wire                              mem_en_i,
    input  wire                              mem_req_i,          // Read Request
    input  wire [TCU_MEM_BSEL_SIZE-1:0]      mem_wben_i,
    input  wire [TCU_MEM_ADDR_SIZE-1:0]      mem_addr_i,
    input  wire [TCU_MEM_DATA_SIZE-1:0]      mem_wdata_i,
    output wire [TCU_MEM_DATA_SIZE-1:0]      mem_rdata_o,
    output wire                              mem_rdata_avail_o,
    output wire                              mem_wstall_o,
    output wire                              mem_rstall_o,
    input  wire                              mem_access_i,       // Access ongoing

    // -------------------------------------------------------------------------
    // RLDRAM 3 APP Interface (Synchronous to mem_clk)
    // -------------------------------------------------------------------------
    output reg  [RLD3_APP_ADDR_WIDTH-1:0]    rld3_app_addr_o,
    output reg  [RLD3_APP_BANK_WIDTH-1:0]    rld3_app_ba_o,      // Explicit Bank Port
    output reg  [RLD3_APP_CMD_WIDTH-1:0]     rld3_app_cmd_o,
    output reg                               rld3_app_en_o,
    output reg                               rld3_app_wr_en_o,   // Explicit Write Data En
    output wire [RLD3_APP_DATA_WIDTH-1:0]    rld3_app_wdf_data_o,
    output wire [RLD3_APP_DATA_WIDTH/8-1:0]  rld3_app_wdf_mask_o,

    // Inputs from Sync Module
    input  wire [RLD3_APP_DATA_WIDTH-1:0]    rld3_app_rd_data_i,
    input  wire                              rld3_app_rd_data_valid_i,
    input  wire                              rld3_app_rdy_i,     // Command Ready
    input  wire                              rld3_app_wdf_rdy_i, // Write Data Ready

    output wire [2:0]                        rld3_status_o
);

    // =========================================================================
    // Functions for Data Alignment
    // =========================================================================

    // FIX for Synth 8-524: Use a temporary wide vector to handle bit slicing safely.
    // This allows us to index up to bit 575 even if input 'data' is only 512 bits.

    function [RLD3_APP_DATA_WIDTH-1:0] shift_data_to_mem;
        input [1:0] addr_lsb;
        input [TCU_MEM_DATA_SIZE-1:0] data;
        // Create a temporary container large enough to hold the max potential shift
        reg [2*RLD3_APP_DATA_WIDTH-1:0] temp_data;
        begin
            temp_data = 0;
            // Place input data into the lower part of the temp container
            // If data is 512 bits, bits [575:512] of temp_data remain 0.
            temp_data[TCU_MEM_DATA_SIZE-1:0] = data;

            case(addr_lsb)
                2'd0: shift_data_to_mem = temp_data[1*RLD3_APP_DATA_WIDTH-1 -: RLD3_APP_DATA_WIDTH];
                2'd1: shift_data_to_mem = temp_data[2*RLD3_APP_DATA_WIDTH-1 -: RLD3_APP_DATA_WIDTH];
                default: shift_data_to_mem = temp_data[RLD3_APP_DATA_WIDTH-1:0];
            endcase
        end
    endfunction

    function [RLD3_APP_DATA_WIDTH/8-1:0] shift_bsel_to_mem;
        input [1:0] addr_lsb;
        input [TCU_MEM_BSEL_SIZE-1:0] bsel;
        reg [2*(RLD3_APP_DATA_WIDTH/8)-1:0] temp_bsel;
        begin
            temp_bsel = 0;
            temp_bsel[TCU_MEM_BSEL_SIZE-1:0] = bsel;

            case(addr_lsb)
                2'd0: shift_bsel_to_mem = temp_bsel[1*(RLD3_APP_DATA_WIDTH/8)-1 -: (RLD3_APP_DATA_WIDTH/8)];
                2'd1: shift_bsel_to_mem = temp_bsel[2*(RLD3_APP_DATA_WIDTH/8)-1 -: (RLD3_APP_DATA_WIDTH/8)];
                default: shift_bsel_to_mem = temp_bsel[(RLD3_APP_DATA_WIDTH/8)-1:0];
            endcase
        end
    endfunction

    function [TCU_MEM_DATA_SIZE-1:0] sel_data_to_tcu;
        input [1:0] addr_lsb;
        input [RLD3_APP_DATA_WIDTH-1:0] mem_chunk;
        begin
            // Standard alignment: Place chunk at LSB, TCU handles higher level alignment
            // Zero-pad the upper bits
            sel_data_to_tcu = { {(TCU_MEM_DATA_SIZE-RLD3_APP_DATA_WIDTH){1'b0}}, mem_chunk };
        end
    endfunction

    // =========================================================================
    // Constants & Parameters
    // =========================================================================
    localparam [RLD3_APP_CMD_WIDTH-1:0] APP_CMD_WRITE = 2'b00;
    localparam [RLD3_APP_CMD_WIDTH-1:0] APP_CMD_READ  = 2'b01;

    localparam AUXMEM_ADDR_WIDTH = 9;
    localparam [AUXMEM_ADDR_WIDTH-1:0] RD_WR_THRESHOLD = 40;

    // Amount of data transferred per RLD3 command (in bytes, approx 32 or 36)
    localparam BYTES_PER_CMD = 32; // Assuming effective addressing power of 2

    // State Machine
    localparam NUM_STATES        = 3;
    localparam S_IDLE            = 3'h0;
    localparam S_READ            = 3'h1;
    localparam S_READ_WAIT       = 3'h2;
    localparam S_READ_WAIT_FETCH = 3'h3;
    localparam S_FINISH          = 3'h7;

    reg [NUM_STATES-1:0] state, next_state;

    // =========================================================================
    // Internal Registers & Wires
    // =========================================================================
    reg  [RLD3_APP_DATA_WIDTH-1:0]   rld3_app_wdf_data_reg;
    reg  [RLD3_APP_DATA_WIDTH/8-1:0] rld3_app_wdf_mask_reg;

    reg  [TCU_MEM_ADDR_SIZE-1:0]     r_mem_addr;
    reg  [TCU_MEM_ADDR_SIZE-1:0]     r_mem_addr_out, rin_mem_addr_out;

    // Aux Memory Pointers
    reg  [AUXMEM_ADDR_WIDTH-1:0]     r_auxmem_waddr, rin_auxmem_waddr;
    reg  [AUXMEM_ADDR_WIDTH-1:0]     r_auxmem_raddr, rin_auxmem_raddr;
    reg                              rin_auxmem_ren;
    reg  [15:0]                      r_auxmem_wloops, rin_auxmem_wloops;
    reg  [15:0]                      r_auxmem_rloops, rin_auxmem_rloops;

    reg  [31:0]                      r_req_size, rin_req_size;
    reg  [32-RLD3_ADDR_SHIFT-1:0]    r_req_count, rin_req_count;

    reg                              req_wfifo_pop;
    reg                              req_rfifo_pop;
    reg                              r_read_stall;

    wire [TCU_MEM_BSEL_SIZE-1:0]     mem_wben_wout;
    wire [TCU_MEM_ADDR_SIZE-1:0]     mem_addr_wout;
    wire [TCU_MEM_DATA_SIZE-1:0]     mem_wdata_wout;
    wire [TCU_MEM_ADDR_SIZE-1:0]     mem_addr_rout;
    wire [31:0]                      mem_wdata_rout; // Read size field

    wire [RLD3_APP_DATA_WIDTH-1:0]   auxmem_data_out;

    wire req_wfifo_full, req_wfifo_empty;
    wire req_rfifo_full, req_rfifo_empty;

    // Push conditions
    wire req_wfifo_push = (mem_en_i && |mem_wben_i); // Write request
    wire req_rfifo_push = (mem_req_i && !mem_wben_i); // Read request

    // Aux Memory Management logic
    wire [32-RLD3_ADDR_SHIFT-1:0] tmp_req_count = rin_auxmem_waddr + {rin_auxmem_wloops, {AUXMEM_ADDR_WIDTH{1'b0}}};
    wire wloops_greater_rloops = (r_auxmem_wloops > r_auxmem_rloops);
    wire auxmem_overflow = ((r_auxmem_raddr - r_auxmem_waddr) <= RD_WR_THRESHOLD) && (r_auxmem_raddr != r_auxmem_waddr);
    wire mem_rdata_avail = ((r_auxmem_waddr > r_auxmem_raddr) || wloops_greater_rloops) && mem_access_i;
    wire auxmem_wen      = rld3_app_rd_data_valid_i; // Write on Valid
    wire [AUXMEM_ADDR_WIDTH-1:0] auxmem_raddr_incr = rin_auxmem_raddr + 1;
    wire read_stall      = (rin_auxmem_waddr == auxmem_raddr_incr) && (tmp_req_count < r_req_count);

    // =========================================================================
    // Modules
    // =========================================================================

    // 1. Auxiliary Memory (Read Buffer)
    mem_tp_wrap #(
        .MEM_TYPE      ("block"),
        .MEM_DATAWIDTH (RLD3_APP_DATA_WIDTH),
        .MEM_ADDRWIDTH (AUXMEM_ADDR_WIDTH)
    ) rld3_auxmem (
        .clk    (mem_clk_i),
        .reset  (~mem_reset_n_i),
        .ena    (auxmem_wen),
        .wea    ({(RLD3_APP_DATA_WIDTH/8){1'b1}}),
        .addra  (r_auxmem_waddr),
        .dina   (rld3_app_rd_data_i),
        .enb    (rin_auxmem_ren),
        .addrb  (rin_auxmem_raddr),
        .doutb  (auxmem_data_out)
    );

    // 2. Write Request FIFO
    sync_fifo #(
        .DATA_WIDTH (TCU_MEM_BSEL_SIZE + TCU_MEM_ADDR_SIZE + TCU_MEM_DATA_SIZE),
        .ADDR_WIDTH (2)
    ) req_wfifo (
        .clk_i    (mem_clk_i),
        .resetn_i (mem_reset_n_i),
        .wr_en_i  (req_wfifo_push),
        .wdata_i  ({mem_wben_i, mem_addr_i, mem_wdata_i}),
        .wfull_o  (req_wfifo_full),
        .rd_en_i  (req_wfifo_pop),
        .rdata_o  ({mem_wben_wout, mem_addr_wout, mem_wdata_wout}),
        .rempty_o (req_wfifo_empty)
    );

    // 3. Read Request FIFO
    sync_fifo #(
        .DATA_WIDTH (TCU_MEM_ADDR_SIZE + 32),
        .ADDR_WIDTH (2)
    ) req_rfifo (
        .clk_i    (mem_clk_i),
        .resetn_i (mem_reset_n_i),
        .wr_en_i  (req_rfifo_push),
        .wdata_i  ({mem_addr_i, mem_wdata_i[31:0]}), // Store Addr + Size
        .wfull_o  (req_rfifo_full),
        .rd_en_i  (req_rfifo_pop),
        .rdata_o  ({mem_addr_rout, mem_wdata_rout}),
        .rempty_o (req_rfifo_empty)
    );

    // =========================================================================
    // Registers Update
    // =========================================================================
    always @(posedge mem_clk_i or negedge mem_reset_n_i) begin
        if (!mem_reset_n_i) begin
            state           <= S_IDLE;
            r_mem_addr      <= {TCU_MEM_ADDR_SIZE{1'b0}};
            r_mem_addr_out  <= {TCU_MEM_ADDR_SIZE{1'b0}};
            r_auxmem_waddr  <= {AUXMEM_ADDR_WIDTH{1'b0}};
            r_auxmem_raddr  <= {AUXMEM_ADDR_WIDTH{1'b0}};
            r_auxmem_wloops <= 16'h0;
            r_auxmem_rloops <= 16'h0;
            r_req_size      <= 32'h0;
            r_req_count     <= 0;
            r_read_stall    <= 1'b0;
        end else begin
            state           <= next_state;
            r_mem_addr      <= mem_addr_i;
            r_mem_addr_out  <= rin_mem_addr_out;
            r_auxmem_waddr  <= rin_auxmem_waddr;
            r_auxmem_raddr  <= rin_auxmem_raddr;
            r_auxmem_wloops <= rin_auxmem_wloops;
            r_auxmem_rloops <= rin_auxmem_rloops;
            r_req_size      <= rin_req_size;
            r_req_count     <= rin_req_count;
            r_read_stall    <= read_stall;
        end
    end

    // =========================================================================
    // Aux Mem Control Logic
    // =========================================================================
    always @* begin
        rin_auxmem_ren    = 1'b0;
        rin_auxmem_raddr  = r_auxmem_raddr;
        rin_auxmem_rloops = r_auxmem_rloops;

        if (state == S_FINISH) begin
            rin_auxmem_raddr  = {AUXMEM_ADDR_WIDTH{1'b0}};
            rin_auxmem_rloops = 16'h0;
        end
        else if (mem_en_i && !mem_wben_i) begin
            rin_auxmem_ren = 1'b1;
            rin_auxmem_raddr = mem_addr_i[TCU_MEM_ADDR_SIZE-1:RLD3_ADDR_SHIFT] -
                               mem_addr_rout[TCU_MEM_ADDR_SIZE-1:RLD3_ADDR_SHIFT];

            if ((r_auxmem_raddr == {AUXMEM_ADDR_WIDTH{1'b0}}) && wloops_greater_rloops) begin
                rin_auxmem_rloops = r_auxmem_rloops + 1;
            end
        end
    end

    always @* begin
        rin_auxmem_waddr  = r_auxmem_waddr;
        rin_auxmem_wloops = r_auxmem_wloops;

        if (auxmem_wen) begin
            rin_auxmem_waddr = r_auxmem_waddr + 1;
            if (r_auxmem_waddr == {AUXMEM_ADDR_WIDTH{1'b1}}) begin
                rin_auxmem_wloops = r_auxmem_wloops + 1;
            end
        end else if (state == S_FINISH) begin
            rin_auxmem_waddr  = {AUXMEM_ADDR_WIDTH{1'b0}};
            rin_auxmem_wloops = 16'h0;
        end
    end

    // =========================================================================
    // Main State Machine
    // =========================================================================
    always @* begin
        next_state = state;

        req_wfifo_pop = 1'b0;
        req_rfifo_pop = 1'b0;

        rin_req_size  = r_req_size;
        rin_req_count = r_req_count;

        // RLD3 Outputs Defaults
        rld3_app_en_o         = 1'b0;
        rld3_app_wr_en_o      = 1'b0;
        rld3_app_cmd_o        = APP_CMD_WRITE;
        rld3_app_addr_o       = {RLD3_APP_ADDR_WIDTH{1'b0}};
        rld3_app_ba_o         = {RLD3_APP_BANK_WIDTH{1'b0}};
        rld3_app_wdf_data_reg = {RLD3_APP_DATA_WIDTH{1'b0}};
        rld3_app_wdf_mask_reg = {(RLD3_APP_DATA_WIDTH/8){1'b1}};

        rin_mem_addr_out      = r_mem_addr_out;

        // WRITE LOGIC
        if (rld3_app_rdy_i && rld3_app_wdf_rdy_i && !req_wfifo_empty &&
            ((state != S_READ) || ((state == S_READ) && auxmem_overflow))) begin

            req_wfifo_pop = 1'b1;
            rld3_app_en_o    = 1'b1;
            rld3_app_wr_en_o = 1'b1;
            rld3_app_cmd_o   = APP_CMD_WRITE;

            // Address Translation
            rld3_app_addr_o  = mem_addr_wout[RLD3_ADDR_SHIFT +: RLD3_APP_ADDR_WIDTH];
            rld3_app_ba_o    = mem_addr_wout[RLD3_ADDR_SHIFT + RLD3_APP_ADDR_WIDTH +: RLD3_APP_BANK_WIDTH];

            rld3_app_wdf_data_reg = shift_data_to_mem(mem_addr_wout[RLD3_ADDR_SHIFT-1:RLD3_ADDR_SHIFT-2], mem_wdata_wout);
            rld3_app_wdf_mask_reg = shift_bsel_to_mem(mem_addr_wout[RLD3_ADDR_SHIFT-1:RLD3_ADDR_SHIFT-2], ~mem_wben_wout);
        end

        // READ STATE MACHINE
        case (state)
            S_IDLE: begin
                if (!req_rfifo_empty) begin
                    rin_mem_addr_out = mem_addr_rout;
                    rin_req_size     = mem_wdata_rout;
                    next_state       = S_READ;
                end
            end

            S_READ: begin
                if (rld3_app_rdy_i && !auxmem_overflow) begin
                    rld3_app_en_o     = 1'b1;
                    rld3_app_cmd_o    = APP_CMD_READ;

                    rld3_app_addr_o  = r_mem_addr_out[RLD3_ADDR_SHIFT +: RLD3_APP_ADDR_WIDTH];
                    rld3_app_ba_o    = r_mem_addr_out[RLD3_ADDR_SHIFT + RLD3_APP_ADDR_WIDTH +: RLD3_APP_BANK_WIDTH];

                    rin_mem_addr_out = r_mem_addr_out + BYTES_PER_CMD;
                    rin_req_count    = r_req_count + 1;

                    if ((r_req_size + mem_addr_rout[RLD3_ADDR_SHIFT-1:0]) > BYTES_PER_CMD) begin
                        rin_req_size = r_req_size - BYTES_PER_CMD;
                        next_state   = S_READ;
                    end else begin
                        rin_req_size = 0;
                        if (mem_rdata_avail) next_state = S_READ_WAIT_FETCH;
                        else                 next_state = S_READ_WAIT;
                    end
                end
            end

            S_READ_WAIT: begin
                if (mem_rdata_avail) next_state = S_READ_WAIT_FETCH;
            end

            S_READ_WAIT_FETCH: begin
                if (!mem_rdata_avail) begin
                    req_rfifo_pop = 1'b1;
                    next_state    = S_FINISH;
                end
            end

            S_FINISH: begin
                rin_req_count = 0;
                next_state    = S_IDLE;
            end

            default: next_state = S_IDLE;
        endcase
    end

    // Final Assignments
    assign rld3_app_wdf_data_o = rld3_app_wdf_data_reg;
    assign rld3_app_wdf_mask_o = rld3_app_wdf_mask_reg;

    assign mem_rdata_o         = sel_data_to_tcu(r_mem_addr[RLD3_ADDR_SHIFT-1:RLD3_ADDR_SHIFT-2], auxmem_data_out);
    assign mem_rdata_avail_o   = mem_rdata_avail;
    assign mem_wstall_o        = req_wfifo_full;
    assign mem_rstall_o        = req_rfifo_full || (r_read_stall && mem_rdata_avail);
    assign rld3_status_o       = state;

endmodule
