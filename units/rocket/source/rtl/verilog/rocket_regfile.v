
module rocket_regfile #(
    `include "noc_parameter.vh"
    ,`include "tcu_parameter.vh"
    ,`include "mod_ids.vh"
    ,parameter ROCKET_MEM_ADDR_SIZE = 32
)(
    input  wire                            clk_i,
    input  wire                            reset_n_i,

    //---------------
    //reg IF
    input  wire                            config_en_i,
    input  wire    [TCU_REG_BSEL_SIZE-1:0] config_wben_i,
    input  wire    [TCU_REG_ADDR_SIZE-1:0] config_addr_i,
    input  wire    [TCU_REG_DATA_SIZE-1:0] config_wdata_i,
    output wire    [TCU_REG_DATA_SIZE-1:0] config_rdata_o,

    //---------------
    //core-specific signals
    output wire                            rocket_en_o,
    output wire                            rocket_ext_int1_o, //int1 boots core after enable
    output wire                            rocket_ext_int2_o,
    input  wire                     [31:0] tcu_mem_axi4_error_i,
    input  wire                     [31:0] axi4_mem_bridge_error_i,
    output wire                            rocket_trace_enabled_o,
    input  wire [ROCKET_MEM_ADDR_SIZE-1:0] rocket_trace_ptr_i,
    input  wire [ROCKET_MEM_ADDR_SIZE-1:0] rocket_trace_count_i
);

    //---------------
    //addr parameter
    localparam REG_ROCKET_EN             = 32'h00000000;
    localparam REG_ROCKET_EXT_INT1       = 32'h00000008;
    localparam REG_ROCKET_EXT_INT2       = 32'h00000010;

    localparam REG_TCU_MEM_AXI4_ERROR    = 32'h00000030;
    localparam REG_AXI4_MEM_BRIDGE_ERROR = 32'h00000038;

    localparam REG_ROCKET_TRACE_ENABLED  = 32'h00000040;
    localparam REG_ROCKET_TRACE_PTR      = 32'h00000048;
    localparam REG_ROCKET_TRACE_COUNT    = 32'h00000050;


    //---------------
    //register

    //core reset
    reg        r_rocket_en, rin_rocket_en;
    
    //core interrupts
    reg        r_rocket_ext_int1, rin_rocket_ext_int1;
    reg        r_rocket_ext_int2, rin_rocket_ext_int2;

    //traces
    reg        r_rocket_trace_enabled, rin_rocket_trace_enabled;

    reg [63:0] r_config_rdata, rin_config_rdata;


    wire reg_w_en = (config_en_i &&  (|config_wben_i));
    wire reg_r_en = (config_en_i && !(|config_wben_i));



    always @(posedge clk_i or negedge reset_n_i) begin
        if (reset_n_i == 1'b0) begin
            r_rocket_en <= 1'b0;

            r_rocket_ext_int1 <= 1'b0;
            r_rocket_ext_int2 <= 1'b0;

            r_rocket_trace_enabled <= 1'b0;

            r_config_rdata <= 64'h0;
        end
        else begin
            r_rocket_en <= rin_rocket_en;

            r_rocket_ext_int1 <= rin_rocket_ext_int1;
            r_rocket_ext_int2 <= rin_rocket_ext_int2;

            r_rocket_trace_enabled <= rin_rocket_trace_enabled;

            r_config_rdata <= rin_config_rdata;
        end
    end




    always @* begin

        rin_rocket_en = r_rocket_en;

        rin_rocket_ext_int1 = r_rocket_ext_int1;
        rin_rocket_ext_int2 = r_rocket_ext_int2;

        rin_rocket_trace_enabled = r_rocket_trace_enabled;

        rin_config_rdata = r_config_rdata;



        //---------------
        //register write
        if (reg_w_en) begin
            case (config_addr_i)
                REG_ROCKET_EN: begin
                    if(config_wben_i[0]) rin_rocket_en = config_wdata_i[0];
                end

                REG_ROCKET_EXT_INT1: begin
                    if(config_wben_i[0]) rin_rocket_ext_int1 = config_wdata_i[0];
                end

                REG_ROCKET_EXT_INT2: begin
                    if(config_wben_i[0]) rin_rocket_ext_int2 = config_wdata_i[0];
                end

                REG_ROCKET_TRACE_ENABLED: begin
                    if(config_wben_i[0]) rin_rocket_trace_enabled = config_wdata_i[0];
                end

                //default:
            endcase
        end

        //---------------
        //register read
        else if (reg_r_en) begin
            case (config_addr_i)
                REG_ROCKET_EN: begin
                    rin_config_rdata = r_rocket_en;
                end

                REG_ROCKET_EXT_INT1: begin
                    rin_config_rdata = r_rocket_ext_int1;
                end

                REG_ROCKET_EXT_INT2: begin
                    rin_config_rdata = r_rocket_ext_int2;
                end

                REG_TCU_MEM_AXI4_ERROR: begin
                    rin_config_rdata = tcu_mem_axi4_error_i;
                end

                REG_AXI4_MEM_BRIDGE_ERROR: begin
                    rin_config_rdata = axi4_mem_bridge_error_i;
                end

                REG_ROCKET_TRACE_ENABLED: begin
                    rin_config_rdata = r_rocket_trace_enabled;
                end

                REG_ROCKET_TRACE_PTR: begin
                    rin_config_rdata = rocket_trace_ptr_i;
                end

                REG_ROCKET_TRACE_COUNT: begin
                    rin_config_rdata = rocket_trace_count_i;
                end

                default: begin
                    rin_config_rdata = 64'h0;
                end
            endcase
        end
    end



    assign config_rdata_o = r_config_rdata;

    assign rocket_en_o = r_rocket_en;

    assign rocket_ext_int1_o = r_rocket_ext_int1;
    assign rocket_ext_int2_o = r_rocket_ext_int2;

    assign rocket_trace_enabled_o = r_rocket_trace_enabled;

endmodule
