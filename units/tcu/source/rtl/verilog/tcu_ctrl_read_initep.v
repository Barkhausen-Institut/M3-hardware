
module tcu_ctrl_read_initep #(
    `include "tcu_parameter.vh"
)(
    input  wire                         clk_i,
    input  wire                         reset_n_i,

    //---------------
    //reg IF
    output reg                          read_initep_reg_en_o,
    output wire [TCU_REG_ADDR_SIZE-1:0] read_initep_reg_addr_o,
    input  wire [TCU_REG_DATA_SIZE-1:0] read_initep_reg_rdata_i,
    input  wire                         read_initep_reg_stall_i,

    //---------------
    //EP data
    input  wire       [TCU_EP_SIZE-1:0] read_initep_epidx_i,
    input  wire       [TCU_EP_SIZE-1:0] read_initep_ext_epidx_i,
    output wire                  [63:0] read_initep_data_0_o,
    output wire                  [63:0] read_initep_data_1_o,
    output wire                  [63:0] read_initep_data_2_o,

    //---------------
    //trigger
    input  wire                         read_initep_start_i,
    input  wire                         read_initep_ext_start_i,
    output wire                         read_initep_active_o,
    output wire                         read_initep_done_o
);

    localparam READ_INITEP_STATES_SIZE = 3;
    localparam S_READ_INITEP_IDLE      = 3'h0;
    localparam S_READ_INITEP_READ1     = 3'h1;
    localparam S_READ_INITEP_READ2     = 3'h2;
    localparam S_READ_INITEP_READ3     = 3'h3;
    localparam S_READ_INITEP_FINISH    = 3'h4;

    reg [READ_INITEP_STATES_SIZE-1:0] read_initep_state, next_read_initep_state;


    reg                               r_read_initep_reg_en;
    reg       [TCU_REG_ADDR_SIZE-1:0] r_read_initep_reg_addr, rin_read_initep_reg_addr;


    reg [63:0] r_read_initep_data_0, rin_read_initep_data_0;
    reg [63:0] r_read_initep_data_1, rin_read_initep_data_1;
    reg [63:0] r_read_initep_data_2, rin_read_initep_data_2;



    //synopsys sync_set_reset "reset_n_i"
    always @(posedge clk_i) begin
        if (reset_n_i == 1'b0) begin
            read_initep_state <= S_READ_INITEP_IDLE;

            r_read_initep_reg_en <= 1'b0;
            r_read_initep_reg_addr <= {TCU_REG_ADDR_SIZE{1'b0}};

            r_read_initep_data_0 <= 64'h0;
            r_read_initep_data_1 <= 64'h0;
            r_read_initep_data_2 <= 64'h0;
        end
        else begin
            read_initep_state <= next_read_initep_state;

            r_read_initep_reg_en <= read_initep_reg_en_o;
            r_read_initep_reg_addr <= rin_read_initep_reg_addr;

            r_read_initep_data_0 <= rin_read_initep_data_0;
            r_read_initep_data_1 <= rin_read_initep_data_1;
            r_read_initep_data_2 <= rin_read_initep_data_2;
        end
    end




    //---------------
    //state machine to read initial ep for each command
    always @* begin
        next_read_initep_state = read_initep_state;

        read_initep_reg_en_o = 1'b0;
        rin_read_initep_reg_addr = r_read_initep_reg_addr;

        rin_read_initep_data_0 = r_read_initep_data_0;
        rin_read_initep_data_1 = r_read_initep_data_1;
        rin_read_initep_data_2 = r_read_initep_data_2;


        case (read_initep_state)

            S_READ_INITEP_IDLE: begin
                //from unpriv cmd
                if (read_initep_start_i) begin
                    rin_read_initep_reg_addr = TCU_REGADDR_EP_START + read_initep_epidx_i*TCU_EP_REG_SIZE;
                    next_read_initep_state = S_READ_INITEP_READ1;
                end

                //from ext cmd
                else if (read_initep_ext_start_i) begin
                    rin_read_initep_reg_addr = TCU_REGADDR_EP_START + read_initep_ext_epidx_i[TCU_EP_SIZE-1:0]*TCU_EP_REG_SIZE;
                    next_read_initep_state = S_READ_INITEP_READ1;
                end
            end

            S_READ_INITEP_READ1: begin
                if (!read_initep_reg_stall_i) begin
                    read_initep_reg_en_o = 1'b1;
                    rin_read_initep_reg_addr = r_read_initep_reg_addr + 'd8;
                    next_read_initep_state = S_READ_INITEP_READ2;
                end
            end

            S_READ_INITEP_READ2: begin
                if (r_read_initep_reg_en) begin
                    rin_read_initep_data_0 = read_initep_reg_rdata_i;
                end

                if (!read_initep_reg_stall_i) begin
                    read_initep_reg_en_o = 1'b1;
                    rin_read_initep_reg_addr = r_read_initep_reg_addr + 'd8;
                    next_read_initep_state = S_READ_INITEP_READ3;
                end
            end

            S_READ_INITEP_READ3: begin
                if (r_read_initep_reg_en) begin
                    rin_read_initep_data_1 = read_initep_reg_rdata_i;
                end

                if (!read_initep_reg_stall_i) begin
                    read_initep_reg_en_o = 1'b1;
                    rin_read_initep_reg_addr = r_read_initep_reg_addr + 'd8;
                    next_read_initep_state = S_READ_INITEP_FINISH;
                end
            end

            S_READ_INITEP_FINISH: begin
                rin_read_initep_data_2 = read_initep_reg_rdata_i;
                next_read_initep_state = S_READ_INITEP_IDLE;
            end

            default: next_read_initep_state = S_READ_INITEP_IDLE;
        endcase
    end



    assign read_initep_reg_addr_o = r_read_initep_reg_addr;

    assign read_initep_active_o = (read_initep_state != S_READ_INITEP_IDLE);
    assign read_initep_done_o = (read_initep_state == S_READ_INITEP_FINISH);

    assign read_initep_data_0_o = r_read_initep_data_0;
    assign read_initep_data_1_o = r_read_initep_data_1;
    assign read_initep_data_2_o = r_read_initep_data_2;

endmodule
