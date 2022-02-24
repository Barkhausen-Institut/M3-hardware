
module tcu_ctrl_print #(
    `include "noc_parameter.vh"
    ,`include "tcu_parameter.vh"
)(
    input  wire                         clk_i,
    input  wire                         reset_n_i,

    //---------------
    //reg IF
    output reg                          print_reg_en_o,
    output reg  [TCU_REG_BSEL_SIZE-1:0] print_reg_wben_o,
    output wire [TCU_REG_ADDR_SIZE-1:0] print_reg_addr_o,
    input  wire [TCU_REG_DATA_SIZE-1:0] print_reg_rdata_i,
    input  wire                         print_reg_stall_i,

    //---------------
    //NoC IF
    input  wire                         noc_stall_i,
    output reg                          noc_wrreq_o,
    output reg                          noc_burst_o,
    output reg      [NOC_BSEL_SIZE-1:0] noc_bsel_o,
    output wire   [NOC_CHIPID_SIZE-1:0] noc_chipid_o,
    output wire    [NOC_MODID_SIZE-1:0] noc_modid_o,
    output reg      [NOC_DATA_SIZE-1:0] noc_data0_o,
    output reg      [NOC_DATA_SIZE-1:0] noc_data1_o,

    input  wire   [NOC_CHIPID_SIZE-1:0] print_chipid_i,
    input  wire    [NOC_MODID_SIZE-1:0] print_modid_i,

    //---------------
    //trigger
    input  wire                         print_start_i,
    output wire                         print_active_o
);

    `include "tcu_functions.v"

    localparam PRINT_BUF_MAX_SIZE = TCU_PRINT_REG_COUNT*TCU_PRINT_REG_SIZE;
    localparam PRINT_BUF_MAX_SIZE_LOG2 = $clog2(PRINT_BUF_MAX_SIZE);

    localparam CTRL_PRINT_STATES_SIZE          = 4;
    localparam S_CTRL_PRINT_IDLE               = 4'h0;
    localparam S_CTRL_PRINT_READ_PRINTREG1     = 4'h1;
    localparam S_CTRL_PRINT_READ_PRINTREG2     = 4'h2;
    localparam S_CTRL_PRINT_CHECK_SIZE         = 4'h3;
    localparam S_CTRL_PRINT_READ_DATA_NOBURST1 = 4'h4;
    localparam S_CTRL_PRINT_READ_DATA_NOBURST2 = 4'h5;
    localparam S_CTRL_PRINT_SEND_NOBURST       = 4'h6;
    localparam S_CTRL_PRINT_SEND_HD            = 4'h7;
    localparam S_CTRL_PRINT_READ_DATA_BURST1   = 4'h8;
    localparam S_CTRL_PRINT_READ_DATA_BURST2   = 4'h9;
    localparam S_CTRL_PRINT_READ_DATA_BURST3   = 4'hA;
    localparam S_CTRL_PRINT_SEND_PL            = 4'hB;
    localparam S_CTRL_PRINT_CLEAR_PRINTREG     = 4'hC;
    localparam S_CTRL_PRINT_FINISH             = 4'hF;

    reg  [CTRL_PRINT_STATES_SIZE-1:0] ctrl_print_state, next_ctrl_print_state;


    //size of print message
    reg [PRINT_BUF_MAX_SIZE_LOG2-1:0] r_size, rin_size;

    reg                               r_print_reg_en;
    reg       [TCU_REG_ADDR_SIZE-1:0] r_print_reg_addr, rin_print_reg_addr;
    reg       [TCU_REG_DATA_SIZE-1:0] r_print_reg_rdata0, rin_print_reg_rdata0;
    reg       [TCU_REG_DATA_SIZE-1:0] r_print_reg_rdata1, rin_print_reg_rdata1;



    //synopsys sync_set_reset "reset_n_i"
    always @(posedge clk_i) begin
        if (reset_n_i == 1'b0) begin
            ctrl_print_state <= S_CTRL_PRINT_IDLE;

            r_size <= 16'h0;

            r_print_reg_en <= 1'b0;
            r_print_reg_addr <= {TCU_REG_ADDR_SIZE{1'b0}};
            r_print_reg_rdata0 <= {TCU_REG_DATA_SIZE{1'b0}};
            r_print_reg_rdata1 <= {TCU_REG_DATA_SIZE{1'b0}};
        end
        else begin
            ctrl_print_state <= next_ctrl_print_state;

            r_size <= rin_size;

            r_print_reg_en <= print_reg_en_o && !print_reg_stall_i;
            r_print_reg_addr <= rin_print_reg_addr;
            r_print_reg_rdata0 <= rin_print_reg_rdata0;
            r_print_reg_rdata1 <= rin_print_reg_rdata1;
        end
    end




    //---------------
    //state machine to read initial ep for each command
    always @* begin
        next_ctrl_print_state = ctrl_print_state;

        rin_size = r_size;

        rin_print_reg_addr = r_print_reg_addr;
        rin_print_reg_rdata0 = r_print_reg_rdata0;
        rin_print_reg_rdata1 = r_print_reg_rdata1;

        noc_wrreq_o = 1'b0;
        noc_burst_o = 1'b0;
        noc_bsel_o = {NOC_BSEL_SIZE{1'b0}};
        noc_data0_o = {NOC_DATA_SIZE{1'b0}};
        noc_data1_o = {NOC_DATA_SIZE{1'b0}};


        case (ctrl_print_state)

            S_CTRL_PRINT_IDLE: begin
                rin_size = 'd0;

                if (print_start_i) begin
                    rin_print_reg_addr = TCU_REGADDR_PRINT;
                    next_ctrl_print_state = S_CTRL_PRINT_READ_PRINTREG1;
                end
            end

            //---------------
            //read number of bytes in print reg
            S_CTRL_PRINT_READ_PRINTREG1: begin
                if (!print_reg_stall_i) begin
                    next_ctrl_print_state = S_CTRL_PRINT_READ_PRINTREG2;
                end
            end

            S_CTRL_PRINT_READ_PRINTREG2: begin
                rin_size = print_reg_rdata_i;
                rin_print_reg_addr = TCU_REGADDR_PRINT_BUF;
                next_ctrl_print_state = S_CTRL_PRINT_CHECK_SIZE;
            end

            //check data size
            S_CTRL_PRINT_CHECK_SIZE: begin
                if (r_size > PRINT_BUF_MAX_SIZE) begin
                    rin_size = PRINT_BUF_MAX_SIZE;
                end

                //a lot of data, need NoC burst
                else if (r_size > 'd8) begin
                    next_ctrl_print_state = S_CTRL_PRINT_SEND_HD;
                end

                //no burst required
                else if (r_size > 'd0) begin
                    next_ctrl_print_state = S_CTRL_PRINT_READ_DATA_NOBURST1;
                end

                //size=0, something is wrong, do not send anything
                else begin
                    rin_print_reg_addr = TCU_REGADDR_PRINT;
                    next_ctrl_print_state = S_CTRL_PRINT_CLEAR_PRINTREG;
                end
            end

            //---------------
            //read data from print buf
            S_CTRL_PRINT_READ_DATA_NOBURST1: begin
                if (!print_reg_stall_i) begin
                    rin_print_reg_addr = r_print_reg_addr + 'd8;
                    next_ctrl_print_state = S_CTRL_PRINT_READ_DATA_NOBURST2;
                end
            end

            S_CTRL_PRINT_READ_DATA_NOBURST2: begin
                //write read data to local reg
                rin_print_reg_rdata0 = print_reg_rdata_i;
                next_ctrl_print_state = S_CTRL_PRINT_SEND_NOBURST;
            end

            S_CTRL_PRINT_SEND_NOBURST: begin
                noc_bsel_o = set_bsel8(3'h0, r_size[3:0]);  //input args: addr, size
                noc_data0_o = r_print_reg_rdata0;

                if (!noc_stall_i) begin
                    noc_wrreq_o = 1'b1;

                    rin_print_reg_addr = TCU_REGADDR_PRINT;
                    next_ctrl_print_state = S_CTRL_PRINT_CLEAR_PRINTREG;
                end
            end


            //---------------
            //prepare NoC header packet
            S_CTRL_PRINT_SEND_HD: begin
                noc_burst_o = 1'b1;
                noc_bsel_o = {(r_size[3:0] - 4'h1), {(NOC_BSEL_SIZE/2){1'b1}}};  //indicate addr of first and last valid byte: (size[3:0] mod 16) - 1
                noc_data0_o = r_size[PRINT_BUF_MAX_SIZE_LOG2-1:4] + |r_size[3:0];

                if (!noc_stall_i) begin
                    noc_wrreq_o = 1'b1;

                    next_ctrl_print_state = S_CTRL_PRINT_READ_DATA_BURST1;
                end
            end

            //read data from print buf for NoC burst
            S_CTRL_PRINT_READ_DATA_BURST1: begin
                noc_burst_o = 1'b1;

                if (!print_reg_stall_i) begin
                    if (r_size > 'd8) begin
                        rin_size = r_size - 'd8;
                    end else begin
                        rin_size = 'd0;
                    end
                    rin_print_reg_addr = r_print_reg_addr + 'd8;
                    next_ctrl_print_state = S_CTRL_PRINT_READ_DATA_BURST2;
                end
            end

            S_CTRL_PRINT_READ_DATA_BURST2: begin
                noc_burst_o = 1'b1;

                if (r_print_reg_en) begin
                    rin_print_reg_rdata0 = print_reg_rdata_i;
                end

                if (!print_reg_stall_i) begin
                    if (r_size > 'd8) begin
                        rin_size = r_size - 'd8;
                    end else begin
                        rin_size = 'd0;
                    end
                    rin_print_reg_addr = r_print_reg_addr + 'd8;
                    next_ctrl_print_state = S_CTRL_PRINT_READ_DATA_BURST3;
                end
            end

            S_CTRL_PRINT_READ_DATA_BURST3: begin
                noc_burst_o = 1'b1;

                rin_print_reg_rdata1 = print_reg_rdata_i;
                next_ctrl_print_state = S_CTRL_PRINT_SEND_PL;
            end

            S_CTRL_PRINT_SEND_PL: begin
                noc_burst_o = 1'b1;
                noc_bsel_o = {NOC_BSEL_SIZE{1'b1}};
                noc_data0_o = r_print_reg_rdata0;
                noc_data1_o = r_print_reg_rdata1;

                if (!noc_stall_i) begin
                    noc_wrreq_o = 1'b1;

                    //continue burst
                    if (r_size > 'd0) begin
                        next_ctrl_print_state = S_CTRL_PRINT_READ_DATA_BURST1;
                    end
                    else begin
                        noc_burst_o = 1'b0;
                        rin_print_reg_addr = TCU_REGADDR_PRINT;
                        next_ctrl_print_state = S_CTRL_PRINT_CLEAR_PRINTREG;
                    end
                end
            end


            //---------------
            //set PRINT reg to zero
            S_CTRL_PRINT_CLEAR_PRINTREG: begin
                if (!print_reg_stall_i) begin
                    next_ctrl_print_state = S_CTRL_PRINT_FINISH;
                end
            end


            //---------------
            S_CTRL_PRINT_FINISH: begin
                next_ctrl_print_state = S_CTRL_PRINT_IDLE;
            end

            default: next_ctrl_print_state = S_CTRL_PRINT_IDLE;
        endcase
    end


    //---------------
    //reg interface
    always @* begin
        print_reg_en_o = 1'b0;
        print_reg_wben_o = {TCU_REG_BSEL_SIZE{1'b0}};

        if ((ctrl_print_state == S_CTRL_PRINT_READ_PRINTREG1) ||
            (ctrl_print_state == S_CTRL_PRINT_READ_DATA_NOBURST1) ||
            (ctrl_print_state == S_CTRL_PRINT_READ_DATA_BURST1) ||
            (ctrl_print_state == S_CTRL_PRINT_READ_DATA_BURST2)) begin
            print_reg_en_o = 1'b1;
        end

        //write 0 to reg
        else if (ctrl_print_state == S_CTRL_PRINT_CLEAR_PRINTREG) begin
            print_reg_en_o = 1'b1;
            print_reg_wben_o = {TCU_REG_BSEL_SIZE{1'b1}};
        end
    end


    assign print_reg_addr_o = r_print_reg_addr;
    assign print_active_o = (ctrl_print_state != S_CTRL_PRINT_IDLE);
    assign noc_chipid_o = print_chipid_i;
    assign noc_modid_o = print_modid_i;

endmodule
