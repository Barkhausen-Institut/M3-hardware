
module tcu_memmap #(
    `include "tcu_parameter.vh"
    ,parameter TCU_ENABLE_MEM_ADDR_ALIGN = 1,
    parameter CORE_DMEM_DATA_SIZE        = 32,
    parameter CORE_DMEM_ADDR_SIZE        = 32,
    parameter CORE_DMEM_BSEL_SIZE        = CORE_DMEM_DATA_SIZE/8,
    parameter CORE_IMEM_DATA_SIZE        = 32,
    parameter CORE_IMEM_ADDR_SIZE        = 32,
    parameter CORE_IMEM_BSEL_SIZE        = CORE_IMEM_DATA_SIZE/8,
    parameter DMEM_DATA_SIZE             = 128,
    parameter DMEM_ADDR_SIZE             = 14,
    parameter DMEM_BSEL_SIZE             = DMEM_DATA_SIZE/8,
    parameter IMEM_DATA_SIZE             = 128,
    parameter IMEM_ADDR_SIZE             = 14,
    parameter IMEM_BSEL_SIZE             = IMEM_DATA_SIZE/8,
    parameter DMEM_START_ADDR            = 32'h00040000,
    parameter DMEM_SIZE                  = 'h40000,
    parameter IMEM_START_ADDR            = 32'h00000000,
    parameter IMEM_SIZE                  = 'h40000
)(
    input  wire                           clk_i,
    input  wire                           reset_n_i,

    //---------------
    //DMEM from core
    input  wire                           core_dmem_in_en_i,
    input  wire [CORE_DMEM_BSEL_SIZE-1:0] core_dmem_in_wben_i,
    input  wire [CORE_DMEM_ADDR_SIZE-1:0] core_dmem_in_addr_i,
    input  wire [CORE_DMEM_DATA_SIZE-1:0] core_dmem_in_wdata_i,
    output reg  [CORE_DMEM_DATA_SIZE-1:0] core_dmem_in_rdata_o,
    output wire                           core_dmem_in_stall_o,

    //---------------
    //IMEM from core
    input  wire                           core_imem_in_en_i,
    input  wire [CORE_IMEM_BSEL_SIZE-1:0] core_imem_in_wben_i,
    input  wire [CORE_IMEM_ADDR_SIZE-1:0] core_imem_in_addr_i,
    input  wire [CORE_IMEM_DATA_SIZE-1:0] core_imem_in_wdata_i,
    output reg  [CORE_IMEM_DATA_SIZE-1:0] core_imem_in_rdata_o,
    output wire                           core_imem_in_stall_o,

    //---------------
    //DMEM to core
    output reg                            core_dmem_out_en_o,
    output reg       [DMEM_BSEL_SIZE-1:0] core_dmem_out_wben_o,
    output reg       [DMEM_ADDR_SIZE-1:0] core_dmem_out_addr_o,
    output reg       [DMEM_DATA_SIZE-1:0] core_dmem_out_wdata_o,
    input  wire      [DMEM_DATA_SIZE-1:0] core_dmem_out_rdata_i,
    input  wire                           core_dmem_out_stall_i,

    //---------------
    //IMEM to core
    output wire                           core_imem_out_en_o,
    output reg       [IMEM_BSEL_SIZE-1:0] core_imem_out_wben_o,
    output wire      [IMEM_ADDR_SIZE-1:0] core_imem_out_addr_o,
    output reg       [IMEM_DATA_SIZE-1:0] core_imem_out_wdata_o,
    input  wire      [IMEM_DATA_SIZE-1:0] core_imem_out_rdata_i,
    input  wire                           core_imem_out_stall_i,

    //---------------
    //reg IF (out) to tcu_regs
    output reg                            core_reg_out_en_o,
    output reg    [TCU_REG_BSEL_SIZE-1:0] core_reg_out_wben_o,
    output reg    [TCU_REG_ADDR_SIZE-1:0] core_reg_out_addr_o,
    output reg    [TCU_REG_DATA_SIZE-1:0] core_reg_out_wdata_o,
    input  wire   [TCU_REG_DATA_SIZE-1:0] core_reg_out_rdata_i,
    input  wire                           core_reg_out_stall_i,

    //---------------
    //TCU mem IF
    input  wire                           tcu_mem_en_i,
    input  wire                           tcu_mem_req_i,
    input  wire   [TCU_MEM_BSEL_SIZE-1:0] tcu_mem_wben_i,
    input  wire   [TCU_MEM_ADDR_SIZE-1:0] tcu_mem_addr_i,
    input  wire   [TCU_MEM_DATA_SIZE-1:0] tcu_mem_wdata_i,
    output reg    [TCU_MEM_DATA_SIZE-1:0] tcu_mem_rdata_o,
    output reg                            tcu_mem_rdata_avail_o,
    output reg                            tcu_mem_wdata_infifo_o,
    input  wire                           tcu_mem_wabort_i,
    output wire                           tcu_mem_wstall_o,
    output wire                           tcu_mem_rstall_o,

    //---------------
    //TCU to DMEM
    output reg                            tcu_dmem_en_o,
    output reg                            tcu_dmem_req_o,
    output reg       [DMEM_BSEL_SIZE-1:0] tcu_dmem_wben_o,
    output reg       [DMEM_ADDR_SIZE-1:0] tcu_dmem_addr_o,
    output reg       [DMEM_DATA_SIZE-1:0] tcu_dmem_wdata_o,
    input  wire      [DMEM_DATA_SIZE-1:0] tcu_dmem_rdata_i,
    input  wire                           tcu_dmem_rdata_avail_i,
    input  wire                           tcu_dmem_wdata_infifo_i,
    output reg                            tcu_dmem_wabort_o,
    input  wire                           tcu_dmem_wstall_i,
    input  wire                           tcu_dmem_rstall_i,

    //---------------
    //TCU to IMEM
    output reg                            tcu_imem_en_o,
    output reg                            tcu_imem_req_o,
    output reg       [IMEM_BSEL_SIZE-1:0] tcu_imem_wben_o,
    output reg       [IMEM_ADDR_SIZE-1:0] tcu_imem_addr_o,
    output reg       [IMEM_DATA_SIZE-1:0] tcu_imem_wdata_o,
    input  wire      [IMEM_DATA_SIZE-1:0] tcu_imem_rdata_i,
    input  wire                           tcu_imem_rdata_avail_i,
    input  wire                           tcu_imem_wdata_infifo_i,
    output reg                            tcu_imem_wabort_o,
    input  wire                           tcu_imem_wstall_i,
    input  wire                           tcu_imem_rstall_i
);


`ifndef SYNTHESIS
    initial begin
        if ( !((CORE_DMEM_DATA_SIZE == 32) || (CORE_DMEM_DATA_SIZE == 64) || (CORE_DMEM_DATA_SIZE == 128))) begin
            $display("tcu_memmap: CORE_DMEM_DATA_SIZE of %d not supported!", CORE_DMEM_DATA_SIZE);
        end
        if ( !((CORE_IMEM_DATA_SIZE == 32) || (CORE_IMEM_DATA_SIZE == 64) || (CORE_IMEM_DATA_SIZE == 128))) begin
            $display("tcu_memmap: CORE_IMEM_DATA_SIZE of %d not supported!", CORE_IMEM_DATA_SIZE);
        end
    end
`endif


    localparam LOG_DMEM_DATA_BYTES = TCU_ENABLE_MEM_ADDR_ALIGN ? $clog2(DMEM_BSEL_SIZE) : 0;
    localparam LOG_IMEM_DATA_BYTES = TCU_ENABLE_MEM_ADDR_ALIGN ? $clog2(IMEM_BSEL_SIZE) : 0;


    reg [1:0] r_core_dmem_addr_sel;
    reg [1:0] r_core_imem_addr_sel;

    reg core_reg_stall_tmp;
    reg core_dmem_stall_tmp;

    reg tcu_dmem_wstall_tmp, tcu_dmem_rstall_tmp;
    reg tcu_imem_wstall_tmp, tcu_imem_rstall_tmp;

    reg r_core_sel_tcu_reg;
    wire core_sel_tcu_reg;

    reg r_tcu_sel_dmem;
    reg r_tcu_sel_imem;
    wire tcu_sel_dmem;
    wire tcu_sel_imem;


    always @(posedge clk_i or negedge reset_n_i) begin
        if (reset_n_i == 1'b0) begin
            r_core_dmem_addr_sel <= 1'b0;
            r_core_imem_addr_sel <= 1'b0;
            r_core_sel_tcu_reg   <= 1'b0;

            r_tcu_sel_dmem <= 1'b0;
            r_tcu_sel_imem <= 1'b0;
        end else begin
            r_core_dmem_addr_sel <= core_dmem_in_addr_i[3:2];
            r_core_imem_addr_sel <= core_imem_in_addr_i[3:2];
            r_core_sel_tcu_reg   <= core_sel_tcu_reg;

            r_tcu_sel_dmem <= tcu_sel_dmem;
            r_tcu_sel_imem <= tcu_sel_imem;
        end
    end



    //---------------
    //DMEM is mapped to TCU regs
    assign core_sel_tcu_reg = (core_dmem_in_addr_i[31:28] == TCU_REGADDR_START[31:28]);
    assign core_dmem_in_stall_o = core_reg_stall_tmp | core_dmem_stall_tmp;


    generate
    if (CORE_DMEM_DATA_SIZE == 32) begin

        always @* begin
            core_reg_out_en_o    = 1'b0;
            core_reg_out_wben_o  = {TCU_REG_BSEL_SIZE{1'b0}};
            core_reg_out_addr_o  = {TCU_REG_ADDR_SIZE{1'b0}};
            core_reg_out_wdata_o = {TCU_REG_DATA_SIZE{1'b0}};
            core_reg_stall_tmp   = 1'b0;

            core_dmem_out_en_o    = 1'b0;
            core_dmem_out_wben_o  = {DMEM_BSEL_SIZE{1'b0}};
            core_dmem_out_addr_o  = {DMEM_ADDR_SIZE{1'b0}};
            core_dmem_out_wdata_o = {DMEM_DATA_SIZE{1'b0}};
            core_dmem_stall_tmp   = 1'b0;


            if (core_sel_tcu_reg) begin
                core_reg_out_en_o   = core_dmem_in_en_i;
                core_reg_out_addr_o = {core_dmem_in_addr_i[TCU_REG_ADDR_SIZE-1:3], 3'h0};   //byte address, but TCU regs only take 8-byte addresses
                core_reg_stall_tmp  = core_reg_out_stall_i;
                
                case (core_dmem_in_addr_i[2])
                    1'b0: begin
                        core_reg_out_wben_o = {{(TCU_REG_BSEL_SIZE-CORE_DMEM_BSEL_SIZE){1'b0}}, core_dmem_in_wben_i};
                        core_reg_out_wdata_o = {{(TCU_REG_DATA_SIZE-CORE_DMEM_DATA_SIZE){1'b0}}, core_dmem_in_wdata_i};
                    end
                    1'b1: begin
                        core_reg_out_wben_o = {core_dmem_in_wben_i, {(TCU_REG_BSEL_SIZE-CORE_DMEM_BSEL_SIZE){1'b0}}};
                        core_reg_out_wdata_o = {core_dmem_in_wdata_i, {(TCU_REG_DATA_SIZE-CORE_DMEM_DATA_SIZE){1'b0}}};
                    end
                endcase
            end
            else begin
                core_dmem_out_en_o   = core_dmem_in_en_i;
                core_dmem_out_addr_o = core_dmem_in_addr_i[(DMEM_ADDR_SIZE-1)+LOG_DMEM_DATA_BYTES:LOG_DMEM_DATA_BYTES];   //byte addr to mem adjusted byte addr, e.g.: 1 byte->16 bytes: shift 4
                core_dmem_stall_tmp  = core_dmem_out_stall_i;

                case (core_dmem_in_addr_i[3:2])
                    2'b00: begin
                        core_dmem_out_wben_o = {{(DMEM_BSEL_SIZE-CORE_DMEM_BSEL_SIZE){1'b0}}, core_dmem_in_wben_i};
                        core_dmem_out_wdata_o = {{(DMEM_DATA_SIZE-CORE_DMEM_DATA_SIZE){1'b0}}, core_dmem_in_wdata_i};
                    end
                    2'b01: begin
                        core_dmem_out_wben_o = {{(DMEM_BSEL_SIZE-2*CORE_DMEM_BSEL_SIZE){1'b0}}, core_dmem_in_wben_i, {(DMEM_BSEL_SIZE-3*CORE_DMEM_BSEL_SIZE){1'b0}}};
                        core_dmem_out_wdata_o = {{(DMEM_DATA_SIZE-2*CORE_DMEM_DATA_SIZE){1'b0}}, core_dmem_in_wdata_i, {(DMEM_DATA_SIZE-3*CORE_DMEM_DATA_SIZE){1'b0}}};
                    end
                    2'b10: begin
                        core_dmem_out_wben_o = {{(DMEM_BSEL_SIZE-3*CORE_DMEM_BSEL_SIZE){1'b0}}, core_dmem_in_wben_i, {(DMEM_BSEL_SIZE-2*CORE_DMEM_BSEL_SIZE){1'b0}}};
                        core_dmem_out_wdata_o = {{(DMEM_DATA_SIZE-3*CORE_DMEM_DATA_SIZE){1'b0}}, core_dmem_in_wdata_i, {(DMEM_DATA_SIZE-2*CORE_DMEM_DATA_SIZE){1'b0}}};
                    end
                    2'b11: begin
                        core_dmem_out_wben_o = {core_dmem_in_wben_i, {(DMEM_BSEL_SIZE-CORE_DMEM_BSEL_SIZE){1'b0}}};
                        core_dmem_out_wdata_o = {core_dmem_in_wdata_i, {(DMEM_DATA_SIZE-CORE_DMEM_DATA_SIZE){1'b0}}};
                    end
                endcase
            end
        end

    end
    else if (CORE_DMEM_DATA_SIZE == 64) begin

        always @* begin
            core_reg_out_en_o    = 1'b0;
            core_reg_out_wben_o  = {TCU_REG_BSEL_SIZE{1'b0}};
            core_reg_out_addr_o  = {TCU_REG_ADDR_SIZE{1'b0}};
            core_reg_out_wdata_o = {TCU_REG_DATA_SIZE{1'b0}};
            core_reg_stall_tmp   = 1'b0;

            core_dmem_out_en_o    = 1'b0;
            core_dmem_out_wben_o  = {DMEM_BSEL_SIZE{1'b0}};
            core_dmem_out_addr_o  = {DMEM_ADDR_SIZE{1'b0}};
            core_dmem_out_wdata_o = {DMEM_DATA_SIZE{1'b0}};
            core_dmem_stall_tmp   = 1'b0;


            if (core_sel_tcu_reg) begin
                core_reg_out_en_o   = core_dmem_in_en_i;
                core_reg_out_addr_o = {core_dmem_in_addr_i[TCU_REG_ADDR_SIZE-1:3], 3'h0};   //byte address, but TCU regs only take 8-byte addresses
                core_reg_stall_tmp  = core_reg_out_stall_i;
                core_reg_out_wben_o = core_dmem_in_wben_i;
                core_reg_out_wdata_o = core_dmem_in_wdata_i;
            end
            else begin
                core_dmem_out_en_o   = core_dmem_in_en_i;
                core_dmem_out_addr_o = core_dmem_in_addr_i[(DMEM_ADDR_SIZE-1)+LOG_DMEM_DATA_BYTES:LOG_DMEM_DATA_BYTES];   //byte addr to mem adjusted byte addr, e.g.: 1 byte->16 bytes: shift 4
                core_dmem_stall_tmp  = core_dmem_out_stall_i;

                case (core_dmem_in_addr_i[3])
                    1'b0: begin
                        core_dmem_out_wben_o = {{(DMEM_BSEL_SIZE-CORE_DMEM_BSEL_SIZE){1'b0}}, core_dmem_in_wben_i};
                        core_dmem_out_wdata_o = {{(DMEM_DATA_SIZE-CORE_DMEM_DATA_SIZE){1'b0}}, core_dmem_in_wdata_i};
                    end
                    1'b1: begin
                        core_dmem_out_wben_o = {core_dmem_in_wben_i, {(DMEM_BSEL_SIZE-CORE_DMEM_BSEL_SIZE){1'b0}}};
                        core_dmem_out_wdata_o = {core_dmem_in_wdata_i, {(DMEM_DATA_SIZE-CORE_DMEM_DATA_SIZE){1'b0}}};
                    end
                endcase
            end
        end

    end
    else begin  //CORE_DMEM_DATA_SIZE == 128

        always @* begin
            core_reg_out_en_o    = 1'b0;
            core_reg_out_wben_o  = {TCU_REG_BSEL_SIZE{1'b0}};
            core_reg_out_addr_o  = {TCU_REG_ADDR_SIZE{1'b0}};
            core_reg_out_wdata_o = {TCU_REG_DATA_SIZE{1'b0}};
            core_reg_stall_tmp   = 1'b0;

            core_dmem_out_en_o    = 1'b0;
            core_dmem_out_wben_o  = {DMEM_BSEL_SIZE{1'b0}};
            core_dmem_out_addr_o  = {DMEM_ADDR_SIZE{1'b0}};
            core_dmem_out_wdata_o = {DMEM_DATA_SIZE{1'b0}};
            core_dmem_stall_tmp   = 1'b0;


            if (core_sel_tcu_reg) begin
                core_reg_out_en_o   = core_dmem_in_en_i;
                core_reg_out_addr_o = {core_dmem_in_addr_i[TCU_REG_ADDR_SIZE-1:3], 3'h0};   //byte address, but TCU regs only take 8-byte addresses
                core_reg_stall_tmp  = core_reg_out_stall_i;

                case (core_dmem_in_addr_i[3])
                    1'b0: begin
                        core_reg_out_wben_o  = core_dmem_in_wben_i[(CORE_DMEM_BSEL_SIZE-TCU_REG_BSEL_SIZE-1):0];
                        core_reg_out_wdata_o = core_dmem_in_wdata_i[(CORE_DMEM_DATA_SIZE-TCU_REG_DATA_SIZE-1):0];
                    end
                    1'b1: begin
                        core_reg_out_wben_o  = core_dmem_in_wben_i[(CORE_DMEM_BSEL_SIZE-1):(CORE_DMEM_BSEL_SIZE-TCU_REG_BSEL_SIZE)];
                        core_reg_out_wdata_o = core_dmem_in_wdata_i[(CORE_DMEM_DATA_SIZE-1):(CORE_DMEM_DATA_SIZE-TCU_REG_DATA_SIZE)];
                    end
                endcase
            end
            else begin
                core_dmem_out_en_o    = core_dmem_in_en_i;
                core_dmem_out_wben_o  = core_dmem_in_wben_i;
                core_dmem_out_addr_o  = core_dmem_in_addr_i[(DMEM_ADDR_SIZE-1)+LOG_DMEM_DATA_BYTES:LOG_DMEM_DATA_BYTES];   //byte addr to mem adjusted byte addr, e.g.: 1 byte->16 bytes: shift 4
                core_dmem_out_wdata_o = core_dmem_in_wdata_i;
                core_dmem_stall_tmp   = core_dmem_out_stall_i;
            end
        end

    end
    endgenerate


    generate
    if (CORE_DMEM_DATA_SIZE == 32) begin

        always @* begin
            core_dmem_in_rdata_o = {CORE_DMEM_DATA_SIZE{1'b0}};

            if (r_core_sel_tcu_reg) begin
                case (r_core_dmem_addr_sel[0])
                    1'b0: begin
                        core_dmem_in_rdata_o = core_reg_out_rdata_i[(TCU_REG_DATA_SIZE-CORE_DMEM_DATA_SIZE-1):0];
                    end
                    1'b1: begin
                        core_dmem_in_rdata_o = core_reg_out_rdata_i[(TCU_REG_DATA_SIZE-1):(TCU_REG_DATA_SIZE-CORE_DMEM_DATA_SIZE)];
                    end
                endcase
            end
            else begin
                case (r_core_dmem_addr_sel)
                    2'b00: begin
                        core_dmem_in_rdata_o = core_dmem_out_rdata_i[(DMEM_DATA_SIZE-3*CORE_DMEM_DATA_SIZE-1):0];
                    end
                    2'b01: begin
                        core_dmem_in_rdata_o = core_dmem_out_rdata_i[(DMEM_DATA_SIZE-2*CORE_DMEM_DATA_SIZE-1):(DMEM_DATA_SIZE-3*CORE_DMEM_DATA_SIZE)];
                    end
                    2'b10: begin
                        core_dmem_in_rdata_o = core_dmem_out_rdata_i[(DMEM_DATA_SIZE-CORE_DMEM_DATA_SIZE-1):(DMEM_DATA_SIZE-2*CORE_DMEM_DATA_SIZE)];
                    end
                    2'b11: begin
                        core_dmem_in_rdata_o = core_dmem_out_rdata_i[(DMEM_DATA_SIZE-1):(DMEM_DATA_SIZE-CORE_DMEM_DATA_SIZE)];
                    end
                endcase
            end
        end

    end
    else if (CORE_DMEM_DATA_SIZE == 64) begin

        always @* begin
            core_dmem_in_rdata_o = {CORE_DMEM_DATA_SIZE{1'b0}};

            if (r_core_sel_tcu_reg) begin
                core_dmem_in_rdata_o = core_reg_out_rdata_i[CORE_DMEM_DATA_SIZE-1:0];
            end
            else begin
                case (r_core_dmem_addr_sel[1])
                    1'b0: begin
                        core_dmem_in_rdata_o = core_dmem_out_rdata_i[CORE_DMEM_DATA_SIZE-1:0];
                    end
                    1'b1: begin
                        core_dmem_in_rdata_o = core_dmem_out_rdata_i[DMEM_DATA_SIZE-1:DMEM_DATA_SIZE-CORE_DMEM_DATA_SIZE];
                    end
                endcase
            end
        end

    end
    else begin //CORE_DMEM_DATA_SIZE == 128

        always @* begin
            core_dmem_in_rdata_o = {CORE_DMEM_DATA_SIZE{1'b0}};

            if (r_core_sel_tcu_reg) begin
                case (r_core_dmem_addr_sel[1])
                    1'b0: begin
                        core_dmem_in_rdata_o = {{(CORE_DMEM_DATA_SIZE-TCU_REG_DATA_SIZE){1'b0}}, core_reg_out_rdata_i};
                    end
                    1'b1: begin
                        core_dmem_in_rdata_o = {core_reg_out_rdata_i, {(CORE_DMEM_DATA_SIZE-TCU_REG_DATA_SIZE){1'b0}}};
                    end
                endcase
            end
            else begin
                core_dmem_in_rdata_o = core_dmem_out_rdata_i;
            end
        end

    end
    endgenerate




    //---------------
    //IMEM is not mapped to any reg
    assign core_imem_out_en_o = core_imem_in_en_i;
    assign core_imem_out_addr_o = core_imem_in_addr_i[(IMEM_ADDR_SIZE+LOG_IMEM_DATA_BYTES-1):LOG_IMEM_DATA_BYTES];   //byte addr to mem adjusted byte addr, e.g.: 1 byte->16 bytes: shift 4
    assign core_imem_in_stall_o = core_imem_out_stall_i;

    generate
    if (CORE_IMEM_DATA_SIZE == 32) begin

        always @* begin
            case (core_imem_in_addr_i[3:2])
                2'b00: begin
                    core_imem_out_wben_o = {{(IMEM_BSEL_SIZE-CORE_IMEM_BSEL_SIZE){1'b0}}, core_imem_in_wben_i};
                    core_imem_out_wdata_o = {{(IMEM_DATA_SIZE-CORE_IMEM_DATA_SIZE){1'b0}}, core_imem_in_wdata_i};
                end
                2'b01: begin
                    core_imem_out_wben_o = {{(IMEM_BSEL_SIZE-2*CORE_IMEM_BSEL_SIZE){1'b0}}, core_imem_in_wben_i, {(IMEM_BSEL_SIZE-3*CORE_IMEM_BSEL_SIZE){1'b0}}};
                    core_imem_out_wdata_o = {{(IMEM_DATA_SIZE-2*CORE_IMEM_DATA_SIZE){1'b0}}, core_imem_in_wdata_i, {(IMEM_DATA_SIZE-3*CORE_IMEM_DATA_SIZE){1'b0}}};
                end
                2'b10: begin
                    core_imem_out_wben_o = {{(IMEM_BSEL_SIZE-3*CORE_IMEM_BSEL_SIZE){1'b0}}, core_imem_in_wben_i, {(IMEM_BSEL_SIZE-2*CORE_IMEM_BSEL_SIZE){1'b0}}};
                    core_imem_out_wdata_o = {{(IMEM_DATA_SIZE-3*CORE_IMEM_DATA_SIZE){1'b0}}, core_imem_in_wdata_i, {(IMEM_DATA_SIZE-2*CORE_IMEM_DATA_SIZE){1'b0}}};
                end
                2'b11: begin
                    core_imem_out_wben_o = {core_imem_in_wben_i, {(IMEM_BSEL_SIZE-CORE_IMEM_BSEL_SIZE){1'b0}}};
                    core_imem_out_wdata_o = {core_imem_in_wdata_i, {(IMEM_DATA_SIZE-CORE_IMEM_DATA_SIZE){1'b0}}};
                end
            endcase
        end

    end
    else if (CORE_IMEM_DATA_SIZE == 64) begin

        always @* begin
            case (core_imem_in_addr_i[3])
                1'b0: begin
                    core_imem_out_wben_o = {{(IMEM_BSEL_SIZE-CORE_IMEM_BSEL_SIZE){1'b0}}, core_imem_in_wben_i};
                    core_imem_out_wdata_o = {{(IMEM_DATA_SIZE-CORE_IMEM_DATA_SIZE){1'b0}}, core_imem_in_wdata_i};
                end
                1'b1: begin
                    core_imem_out_wben_o = {core_imem_in_wben_i, {(IMEM_BSEL_SIZE-CORE_IMEM_BSEL_SIZE){1'b0}}};
                    core_imem_out_wdata_o = {core_imem_in_wdata_i, {(IMEM_DATA_SIZE-CORE_IMEM_DATA_SIZE){1'b0}}};
                end
            endcase
        end

    end
    else begin  //CORE_IMEM_DATA_SIZE == 128

        always @* begin
            core_imem_out_wben_o  = core_imem_in_wben_i;
            core_imem_out_wdata_o = core_imem_in_wdata_i;
        end

    end
    endgenerate


    generate
    if (CORE_IMEM_DATA_SIZE == 32) begin

        always @* begin
            case (r_core_imem_addr_sel)
                2'b00: begin
                    core_imem_in_rdata_o = core_imem_out_rdata_i[(IMEM_DATA_SIZE-3*CORE_IMEM_DATA_SIZE-1):0];
                end
                2'b01: begin
                    core_imem_in_rdata_o = core_imem_out_rdata_i[(IMEM_DATA_SIZE-2*CORE_IMEM_DATA_SIZE-1):(IMEM_DATA_SIZE-3*CORE_IMEM_DATA_SIZE)];
                end
                2'b10: begin
                    core_imem_in_rdata_o = core_imem_out_rdata_i[(IMEM_DATA_SIZE-CORE_IMEM_DATA_SIZE-1):(IMEM_DATA_SIZE-2*CORE_IMEM_DATA_SIZE)];
                end
                2'b11: begin
                    core_imem_in_rdata_o = core_imem_out_rdata_i[(IMEM_DATA_SIZE-1):(IMEM_DATA_SIZE-CORE_IMEM_DATA_SIZE)];
                end
            endcase
        end

    end
    else if (CORE_IMEM_DATA_SIZE == 64) begin

        always @* begin
            case (r_core_imem_addr_sel[1])
                1'b0: begin
                    core_imem_in_rdata_o = core_imem_out_rdata_i[CORE_IMEM_DATA_SIZE-1:0];
                end
                1'b1: begin
                    core_imem_in_rdata_o = core_imem_out_rdata_i[IMEM_DATA_SIZE-1:IMEM_DATA_SIZE-CORE_IMEM_DATA_SIZE];
                end
            endcase
        end

    end
    else begin //CORE_IMEM_DATA_SIZE == 128

        always @* begin
            core_imem_in_rdata_o = core_imem_out_rdata_i;
        end

    end
    endgenerate



    //---------------
    //TCU mem is only mapped to DMEM and IMEM
    assign tcu_sel_dmem = (tcu_mem_addr_i >= DMEM_START_ADDR) && (tcu_mem_addr_i < (DMEM_START_ADDR+DMEM_SIZE));
    assign tcu_sel_imem = (tcu_mem_addr_i >= IMEM_START_ADDR) && (tcu_mem_addr_i < (IMEM_START_ADDR+IMEM_SIZE));
    assign tcu_mem_wstall_o = tcu_dmem_wstall_tmp | tcu_imem_wstall_tmp;
    assign tcu_mem_rstall_o = tcu_dmem_rstall_tmp | tcu_imem_rstall_tmp;


    always @* begin
        tcu_dmem_en_o       = 1'b0;
        tcu_dmem_req_o      = 1'b0;
        tcu_dmem_wben_o     = {DMEM_BSEL_SIZE{1'b0}};
        tcu_dmem_addr_o     = {DMEM_ADDR_SIZE{1'b0}};
        tcu_dmem_wdata_o    = {DMEM_DATA_SIZE{1'b0}};
        tcu_dmem_wabort_o   = 1'b0;
        tcu_dmem_wstall_tmp = 1'b0;
        tcu_dmem_rstall_tmp = 1'b0;

        tcu_imem_en_o       = 1'b0;
        tcu_imem_req_o      = 1'b0;
        tcu_imem_wben_o     = {IMEM_BSEL_SIZE{1'b0}};
        tcu_imem_addr_o     = {IMEM_ADDR_SIZE{1'b0}};
        tcu_imem_wdata_o    = {IMEM_DATA_SIZE{1'b0}};
        tcu_imem_wabort_o   = 1'b0;
        tcu_imem_wstall_tmp = 1'b0;
        tcu_imem_rstall_tmp = 1'b0;

        if (tcu_sel_dmem) begin
            tcu_dmem_en_o       = tcu_mem_en_i;
            tcu_dmem_req_o      = tcu_mem_req_i;
            tcu_dmem_wben_o     = tcu_mem_wben_i;
            tcu_dmem_addr_o     = tcu_mem_addr_i[(DMEM_ADDR_SIZE+LOG_DMEM_DATA_BYTES-1):LOG_DMEM_DATA_BYTES];    //byte address to mem adjusted byte address
            tcu_dmem_wdata_o    = tcu_mem_wdata_i;
            tcu_dmem_wabort_o   = tcu_mem_wabort_i;
            tcu_dmem_wstall_tmp = tcu_dmem_wstall_i;
            tcu_dmem_rstall_tmp = tcu_dmem_rstall_i;
        end
        else if (tcu_sel_imem) begin
            tcu_imem_en_o       = tcu_mem_en_i;
            tcu_imem_req_o      = tcu_mem_req_i;
            tcu_imem_wben_o     = tcu_mem_wben_i;
            tcu_imem_addr_o     = tcu_mem_addr_i[(IMEM_ADDR_SIZE+LOG_IMEM_DATA_BYTES-1):LOG_IMEM_DATA_BYTES];    //byte address to mem adjusted byte address
            tcu_imem_wdata_o    = tcu_mem_wdata_i;
            tcu_imem_wabort_o   = tcu_mem_wabort_i;
            tcu_imem_wstall_tmp = tcu_imem_wstall_i;
            tcu_imem_rstall_tmp = tcu_imem_rstall_i;
        end
    end


    always @* begin
        tcu_mem_rdata_o = {TCU_MEM_DATA_SIZE{1'b0}};
        tcu_mem_rdata_avail_o = 1'b0;
        tcu_mem_wdata_infifo_o = 1'b0;

        if (r_tcu_sel_dmem) begin
            tcu_mem_rdata_o = tcu_dmem_rdata_i;
            tcu_mem_rdata_avail_o = tcu_dmem_rdata_avail_i;
            tcu_mem_wdata_infifo_o = tcu_dmem_wdata_infifo_i;
        end
        else if (r_tcu_sel_imem) begin
            tcu_mem_rdata_o = tcu_imem_rdata_i;
            tcu_mem_rdata_avail_o = tcu_imem_rdata_avail_i;
            tcu_mem_wdata_infifo_o = tcu_imem_wdata_infifo_i;
        end
    end


endmodule
