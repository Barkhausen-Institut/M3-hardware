
/*
 * Reg IF1 has priority over Reg IF2 and IF3,
 * Reg IF2 has priority over Reg IF3
 *
 * 3-bit reg enable:
 *  Bit 0: standard enable
 *  Bit 1: from extern
 *  Bit 2: from core
 */

module tcu_reg_mux #(
    `include "tcu_parameter.vh"
)(
    input  wire                          clk_i,
    input  wire                          reset_n_i,

    //---------------
    //Reg IF1 (in)
    input  wire                    [2:0] reg_in1_en_i,
    input  wire  [TCU_REG_BSEL_SIZE-1:0] reg_in1_wben_i,    //byte-wise select
    input  wire  [TCU_REG_ADDR_SIZE-1:0] reg_in1_addr_i,
    input  wire  [TCU_REG_DATA_SIZE-1:0] reg_in1_wdata_i,
    output wire  [TCU_REG_DATA_SIZE-1:0] reg_in1_rdata_o,
    output wire                          reg_in1_stall_o,

    //---------------
    //reg IF2 (in)
    input  wire                    [2:0] reg_in2_en_i,
    input  wire  [TCU_REG_DATA_SIZE-1:0] reg_in2_wben_i,    //bit-wise select
    input  wire  [TCU_REG_ADDR_SIZE-1:0] reg_in2_addr_i,
    input  wire  [TCU_REG_DATA_SIZE-1:0] reg_in2_wdata_i,
    output wire  [TCU_REG_DATA_SIZE-1:0] reg_in2_rdata_o,
    output wire                          reg_in2_stall_o,

    //---------------
    //Reg IF3 (in)
    input  wire                    [2:0] reg_in3_en_i,
    input  wire  [TCU_REG_DATA_SIZE-1:0] reg_in3_wben_i,    //bit-wise select
    input  wire  [TCU_REG_ADDR_SIZE-1:0] reg_in3_addr_i,
    input  wire  [TCU_REG_DATA_SIZE-1:0] reg_in3_wdata_i,
    output wire  [TCU_REG_DATA_SIZE-1:0] reg_in3_rdata_o,
    output wire                          reg_in3_stall_o,

    //---------------
    //reg IF (out) to tcu_regs
    output wire                    [2:0] reg_out_en_o,
    output wire  [TCU_REG_DATA_SIZE-1:0] reg_out_wben_o,    //bit-wise select
    output wire  [TCU_REG_ADDR_SIZE-1:0] reg_out_addr_o,
    output wire  [TCU_REG_DATA_SIZE-1:0] reg_out_wdata_o,
    input  wire  [TCU_REG_DATA_SIZE-1:0] reg_out_rdata_i,
    input  wire                          reg_out_stall_i    //unconnected
);

    integer i;

//include egister and hence one cycle delay
`ifdef REGISTERED

    reg                   [2:0] r_reg_out_en, rin_reg_out_en;
    reg [TCU_REG_DATA_SIZE-1:0] r_reg_out_wben, rin_reg_out_wben;
    reg [TCU_REG_ADDR_SIZE-1:0] r_reg_out_addr, rin_reg_out_addr;
    reg [TCU_REG_DATA_SIZE-1:0] r_reg_out_wdata, rin_reg_out_wdata;


    //---------------
    //reg IF out

    always @(posedge clk_i or negedge reset_n_i) begin
        if (reset_n_i == 1'b0) begin
            r_reg_out_en    <= 3'h0;
            r_reg_out_wben  <= {TCU_REG_DATA_SIZE{1'b0}};
            r_reg_out_addr  <= {TCU_REG_ADDR_SIZE{1'b0}};
            r_reg_out_wdata <= {TCU_REG_DATA_SIZE{1'b0}};
        end else begin
            r_reg_out_en    <= rin_reg_out_en;
            r_reg_out_wben  <= rin_reg_out_wben;
            r_reg_out_addr  <= rin_reg_out_addr;
            r_reg_out_wdata <= rin_reg_out_wdata;
        end
    end


    always @* begin
        rin_reg_out_en    = 3'h0;
        rin_reg_out_wben  = {TCU_REG_DATA_SIZE{1'b0}};
        rin_reg_out_addr  = r_reg_out_addr;
        rin_reg_out_wdata = r_reg_out_wdata;

        //IF1 has prio
        if (reg_in1_en_i[0]) begin
            rin_reg_out_en = reg_in1_en_i;
            for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                rin_reg_out_wben[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = {TCU_REG_BSEL_SIZE{reg_in1_wben_i[i]}};
            end
            rin_reg_out_addr = reg_in1_addr_i;
            rin_reg_out_wdata = reg_in1_wdata_i;
        end
        //else if (!reg_out_stall_i && reg_in2_en_i[0]) begin
        else if (reg_in2_en_i[0]) begin
            rin_reg_out_en = reg_in2_en_i;
            rin_reg_out_wben = reg_in2_wben_i;
            rin_reg_out_addr = reg_in2_addr_i;
            rin_reg_out_wdata = reg_in2_wdata_i;
        end
        //else if (!reg_out_stall_i && reg_in3_en_i[0]) begin
        else if (reg_in3_en_i[0]) begin
            rin_reg_out_en = reg_in3_en_i;
            rin_reg_out_wben = reg_in3_wben_i;
            rin_reg_out_addr = reg_in3_addr_i;
            rin_reg_out_wdata = reg_in3_wdata_i;
        end
    end

    assign reg_out_en_o = r_reg_out_en;
    assign reg_out_wben_o = r_reg_out_wben;
    assign reg_out_addr_o = r_reg_out_addr;
    assign reg_out_wdata_o = r_reg_out_wdata;

    assign reg_in1_rdata_o = reg_out_rdata_i;
    //assign reg_in1_stall_o = reg_out_stall_i;
    assign reg_in1_stall_o = 1'b0;  //IF1 has prio and thus is not stalled

    assign reg_in2_rdata_o = reg_out_rdata_i;
    //assign reg_in2_stall_o = reg_out_stall_i || reg_in1_en_i;
    assign reg_in2_stall_o = reg_in1_en_i;   //IF2 is stalled when IF1 has access

    assign reg_in3_rdata_o = reg_out_rdata_i;
    //assign reg_in3_stall_o = reg_out_stall_i || reg_in1_en_i || reg_in2_en_i;
    assign reg_in3_stall_o = reg_in1_en_i || reg_in2_en_i;   //IF3 is stalled when IF1 or IF2 has access


//no register
`else

    reg                   [2:0] rin_reg_out_en;
    reg [TCU_REG_DATA_SIZE-1:0] rin_reg_out_wben;
    reg [TCU_REG_ADDR_SIZE-1:0] rin_reg_out_addr;
    reg [TCU_REG_DATA_SIZE-1:0] rin_reg_out_wdata;

    always @* begin
        rin_reg_out_en    = 3'h0;
        rin_reg_out_wben  = {TCU_REG_DATA_SIZE{1'b0}};
        rin_reg_out_addr  = {TCU_REG_ADDR_SIZE{1'b0}};
        rin_reg_out_wdata = {TCU_REG_DATA_SIZE{1'b0}};

        //IF1 has prio
        if (reg_in1_en_i[0]) begin
            rin_reg_out_en = reg_in1_en_i;
            for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                rin_reg_out_wben[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = {TCU_REG_BSEL_SIZE{reg_in1_wben_i[i]}};
            end
            rin_reg_out_addr = reg_in1_addr_i;
            rin_reg_out_wdata = reg_in1_wdata_i;
        end
        //else if (!reg_out_stall_i && reg_in2_en_i[0]) begin
        else if (reg_in2_en_i[0]) begin
            rin_reg_out_en = reg_in2_en_i;
            rin_reg_out_wben = reg_in2_wben_i;
            rin_reg_out_addr = reg_in2_addr_i;
            rin_reg_out_wdata = reg_in2_wdata_i;
        end
        //else if (!reg_out_stall_i && reg_in3_en_i[0]) begin
        else if (reg_in3_en_i[0]) begin
            rin_reg_out_en = reg_in3_en_i;
            rin_reg_out_wben = reg_in3_wben_i;
            rin_reg_out_addr = reg_in3_addr_i;
            rin_reg_out_wdata = reg_in3_wdata_i;
        end
    end

    assign reg_out_en_o = rin_reg_out_en;
    assign reg_out_wben_o = rin_reg_out_wben;
    assign reg_out_addr_o = rin_reg_out_addr;
    assign reg_out_wdata_o = rin_reg_out_wdata;

    assign reg_in1_rdata_o = reg_out_rdata_i;
    //assign reg_in1_stall_o = reg_out_stall_i;
    assign reg_in1_stall_o = 1'b0;  //IF1 has prio and thus is not stalled

    assign reg_in2_rdata_o = reg_out_rdata_i;
    //assign reg_in2_stall_o = reg_out_stall_i || reg_in1_en_i;
    assign reg_in2_stall_o = reg_in1_en_i;   //IF2 is stalled when IF1 has access

    assign reg_in3_rdata_o = reg_out_rdata_i;
    //assign reg_in3_stall_o = reg_out_stall_i || reg_in1_en_i || reg_in2_en_i;
    assign reg_in3_stall_o = reg_in1_en_i || reg_in2_en_i;   //IF3 is stalled when IF1 or IF2 has access


`endif

endmodule
