
module ddr4_regfile #(
    `include "ddr4_user_parameter.vh"
    ,`include "tcu_parameter.vh"
)
(
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
    input  wire   [DDR4_STATUS_SIZE-1:0] ddr4_status_i,
    input  wire                          ddr4_init_calib_complete_i
);

    //---------------
    //addr parameter
    localparam REG_DDR4_STATUS              = 32'h00000000;
    localparam REG_DDR4_INIT_CALIB_COMPLETE = 32'h00000008;


    //---------------
    //register
    reg   [DDR4_STATUS_SIZE-1:0] r_ddr4_status;
    reg                          r_ddr4_init_calib_complete;

    reg [63:0] r_config_rdata, rin_config_rdata;


    wire reg_w_en = (config_en_i &&  (|config_wben_i));
    wire reg_r_en = (config_en_i && !(|config_wben_i));



    always @(posedge clk_i or negedge reset_n_i) begin
        if (reset_n_i == 1'b0) begin
            r_ddr4_status <= {DDR4_STATUS_SIZE{1'b0}};
            r_ddr4_init_calib_complete <= 1'b0;

            r_config_rdata <= 64'h0;
        end
        else begin
            r_ddr4_status <= ddr4_status_i;
            r_ddr4_init_calib_complete <= ddr4_init_calib_complete_i;

            r_config_rdata <= rin_config_rdata;
        end
    end


    

    always @* begin
        rin_config_rdata = 64'h0;
        

        //---------------
        //register write (nothing to write)
        //if (reg_w_en) begin
        //end

        //---------------
        //register read
        if (reg_r_en) begin
            case (config_addr_i)
                REG_DDR4_STATUS: begin
                    rin_config_rdata = r_ddr4_status;
                end

                REG_DDR4_INIT_CALIB_COMPLETE: begin
                    rin_config_rdata = r_ddr4_init_calib_complete;
                end

                default: begin
                    rin_config_rdata = 64'h0;
                end
            endcase
        end
    end



    assign config_rdata_o = r_config_rdata;


endmodule
