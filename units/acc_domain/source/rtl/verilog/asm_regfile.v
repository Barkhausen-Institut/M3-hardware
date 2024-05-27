
module asm_regfile #(
    `include "tcu_parameter.vh"
    ,parameter PICO_STACKADDR = 'h40000,
    parameter ASM_CORE_ADDR_SIZE = 32
)(
    input  wire                          clk_i,
    input  wire                          reset_n_i,

    //---------------
    //reg IF
    input  wire                          config_en_i,
    input  wire  [TCU_REG_BSEL_SIZE-1:0] config_wben_i,
    input  wire  [TCU_REG_ADDR_SIZE-1:0] config_addr_i,
    input  wire  [TCU_REG_DATA_SIZE-1:0] config_wdata_i,
    output wire  [TCU_REG_DATA_SIZE-1:0] config_rdata_o,

    //---------------
    //core-specific signals
    output wire                          asm_en_o,
    output wire                          acc_en_o,
    input  wire                          pico_trap_i,
    output wire                   [31:0] pico_irq_o,
    input  wire                   [31:0] pico_eoi_i,
    output wire                   [31:0] pico_stackaddr_o,

    output wire                          asm_trace_enabled_o,
    input  wire [ASM_CORE_ADDR_SIZE-1:0] asm_trace_ptr_i,
    input  wire [ASM_CORE_ADDR_SIZE-1:0] asm_trace_count_i
);

    integer i;

    //---------------
    //addr parameter
    localparam REG_ASM_EN         = 32'h00000000;
    localparam REG_ACC_EN         = 32'h00000008;
    localparam REG_PICO_TRAP      = 32'h00000010;
    localparam REG_PICO_IRQ       = 32'h00000018;
    localparam REG_PICO_EOI       = 32'h00000020;
    localparam REG_PICO_STACKADDR = 32'h00000028;

    localparam REG_ASM_TRACE_ENABLED  = 32'h00000050;
    localparam REG_ASM_TRACE_PTR      = 32'h00000058;
    localparam REG_ASM_TRACE_COUNT    = 32'h00000060;


    //---------------
    //register

    //core reset and system call identicator
    reg        r_asm_en, rin_asm_en;
    reg        r_acc_en, rin_acc_en;
    reg        r_pico_trap;
    
    //Core interrupt
    reg [31:0] r_pico_irq, rin_pico_irq;
    reg [31:0] r_pico_eoi;
    
    //stack addr
    reg [31:0] r_pico_stackaddr, rin_pico_stackaddr;

    //traces
    reg        r_asm_trace_enabled, rin_asm_trace_enabled;

    reg [63:0] r_config_rdata, rin_config_rdata;


    wire reg_w_en = (config_en_i &&  (|config_wben_i));
    wire reg_r_en = (config_en_i && !(|config_wben_i));



    always @(posedge clk_i or negedge reset_n_i) begin
        if (reset_n_i == 1'b0) begin
            r_asm_en <= 1'b0;
            r_acc_en <= 1'b0;
            r_pico_trap <= 32'h0;
            r_pico_irq <= 32'h0;
            r_pico_eoi <= 32'h0;
            r_pico_stackaddr <= PICO_STACKADDR;

            r_asm_trace_enabled <= 1'b0;

            r_config_rdata <= 64'h0;
        end
        else begin
            r_asm_en <= rin_asm_en;
            r_acc_en <= rin_acc_en;
            r_pico_trap <= pico_trap_i;
            r_pico_irq <= rin_pico_irq;
            r_pico_eoi <= pico_eoi_i;
            r_pico_stackaddr <= rin_pico_stackaddr;

            r_asm_trace_enabled <= rin_asm_trace_enabled;

            r_config_rdata <= rin_config_rdata;
        end
    end


    

    always @* begin

        rin_asm_en = r_asm_en;
        rin_acc_en = r_acc_en;
        rin_pico_irq = r_pico_irq;
        rin_pico_stackaddr = r_pico_stackaddr;

        rin_asm_trace_enabled = r_asm_trace_enabled;

        rin_config_rdata = r_config_rdata;

        

        //---------------
        //register write
        if (reg_w_en) begin
            case (config_addr_i)
                REG_ASM_EN: begin
                    if(config_wben_i[0]) rin_asm_en = config_wdata_i[0];
                end

                REG_ACC_EN: begin
                    if(config_wben_i[0]) rin_acc_en = config_wdata_i[0];
                end

                REG_PICO_IRQ: begin
                    for (i=0; i<4; i=i+1) if(config_wben_i[i]) rin_pico_irq[i*8 +: 8] = config_wdata_i[i*8 +: 8];
                end

                REG_PICO_STACKADDR: begin
                    for (i=0; i<4; i=i+1) if(config_wben_i[i]) rin_pico_stackaddr[i*8 +: 8] = config_wdata_i[i*8 +: 8];
                end

                REG_ASM_TRACE_ENABLED: begin
                    if(config_wben_i[0]) rin_asm_trace_enabled = config_wdata_i[0];
                end

                //default:
            endcase
        end

        //---------------
        //register read
        else if (reg_r_en) begin
            case (config_addr_i)
                REG_ASM_EN: begin
                    rin_config_rdata = r_asm_en;
                end

                REG_ACC_EN: begin
                    rin_config_rdata = r_acc_en;
                end

                REG_PICO_TRAP: begin
                    rin_config_rdata = r_pico_trap;
                end

                REG_PICO_IRQ: begin
                    rin_config_rdata = r_pico_irq;
                end

                REG_PICO_EOI: begin
                    rin_config_rdata = r_pico_eoi;
                end

                REG_PICO_STACKADDR: begin
                    rin_config_rdata = r_pico_stackaddr;
                end

                REG_ASM_TRACE_ENABLED: begin
                    rin_config_rdata = r_asm_trace_enabled;
                end

                REG_ASM_TRACE_PTR: begin
                    rin_config_rdata = asm_trace_ptr_i;
                end

                REG_ASM_TRACE_COUNT: begin
                    rin_config_rdata = asm_trace_count_i;
                end

                default: begin
                    rin_config_rdata = 64'h0;
                end
            endcase
        end
    end



    assign config_rdata_o = r_config_rdata;

    assign asm_en_o = r_asm_en;
    assign acc_en_o = r_acc_en;
    assign pico_irq_o = r_pico_irq;
    assign pico_stackaddr_o = r_pico_stackaddr;

    assign asm_trace_enabled_o = r_asm_trace_enabled;

endmodule
