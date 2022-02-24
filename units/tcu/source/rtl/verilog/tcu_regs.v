
module tcu_regs #(
    `include "tcu_parameter.vh"
    ,parameter TCU_ENABLE_CMDS      = 1,
    parameter TCU_ENABLE_PRIV_CMDS  = 0,
    parameter TCU_ENABLE_LOG        = 0,
    parameter TCU_ENABLE_PRINT      = 0,
    parameter CLKFREQ_MHZ           = 100
)(
    input  wire                          clk_i,
    input  wire                          reset_n_i,

    //---------------
    //reg IF from tcu_ctrl
    input  wire                    [2:0] reg_en_i,      //Bit 0: standard enable, Bit 1: enable from extern, Bit 2: enable from core
    input  wire  [TCU_REG_DATA_SIZE-1:0] reg_wben_i,    //bit-wise select
    input  wire  [TCU_REG_ADDR_SIZE-1:0] reg_addr_i,
    input  wire  [TCU_REG_DATA_SIZE-1:0] reg_wdata_i,
    output wire  [TCU_REG_DATA_SIZE-1:0] reg_rdata_o,
    output wire                          reg_stall_o,   //unused

    //---------------
    //triggers to tcu_ctrl
    output wire                    [2:0] tcu_fire_o,    //Bit 0: fire TCU (unpriv cmd), Bit 1: ext cmd, Bit 3: priv cmd
    output wire                   [63:0] tcu_fire_cmd_o,
    output wire                   [63:0] tcu_fire_data_o,
    output wire                   [63:0] tcu_fire_arg1_o,
    output wire                   [63:0] tcu_fire_cur_vpe_o,

    //---------------
    //Log IF
    input  wire                          tcu_log_en_i,
    input  wire  [TCU_LOG_DATA_SIZE-1:0] tcu_log_data_i,
    output wire  [TCU_LOG_DATA_SIZE-1:0] tcu_log_cur_vpe_o,

    //---------------
    //global TCU reset and time
    output wire                          tcu_reset_o,
    output wire                   [63:0] tcu_cur_time_o,

    //---------------
    //TCU feature settings
    output wire                          tcu_features_virt_addr_o,
    output wire                          tcu_features_virt_pes_o,

    //---------------
    //TCU print
    output wire                          tcu_print_valid_o,

    //---------------
    //config IF for special core regs
    output reg                           config_en_o,
    output reg   [TCU_REG_BSEL_SIZE-1:0] config_wben_o,
    output reg   [TCU_REG_ADDR_SIZE-1:0] config_addr_o,
    output reg   [TCU_REG_DATA_SIZE-1:0] config_wdata_o,
    input  wire  [TCU_REG_DATA_SIZE-1:0] config_rdata_i,

    //---------------
    //other TCU status inputs
    input  wire    [TCU_STATUS_SIZE-1:0] tcu_status_i,
    input  wire [TCU_FLITCOUNT_SIZE-1:0] noc1_rx_flit_count_i,
    input  wire [TCU_FLITCOUNT_SIZE-1:0] noc2_rx_flit_count_i,
    input  wire [TCU_FLITCOUNT_SIZE-1:0] noc1_tx_flit_count_i,
    input  wire [TCU_FLITCOUNT_SIZE-1:0] noc2_tx_flit_count_i,
    input  wire [TCU_FLITCOUNT_SIZE-1:0] noc_error_flit_count_i,
    input  wire [TCU_FLITCOUNT_SIZE-1:0] noc_drop_flit_count_i
);

    integer i;

    localparam TIMER_SCALE = 10;                        //x1024 to get higher precision
    localparam TIMER_FACTOR = 1000*(1<<TIMER_SCALE)/CLKFREQ_MHZ;

    localparam TMP_EP_SIZE = $clog2(TCU_EP_REG_COUNT);
    localparam EP_MEM_ADDRWIDTH = $clog2(TCU_EP_REG_COUNT*3);
    localparam PRINT_BUF_ADDRWIDTH = $clog2(TCU_PRINT_REG_COUNT);


    reg [63:0] r_reg_rdata, rin_reg_rdata;

    reg r_tcu_reset, rin_tcu_reset;

    //registered enable of config interface
    reg r_config_en;


    //sync reset
    //synopsys sync_set_reset "reset_sync_n"
    wire reset_sync_n;


    wire [63:0] cur_time_s;

    wire reg_w_en = (reg_en_i[0] &&  (|reg_wben_i));
    wire reg_r_en = (reg_en_i[0] && !(|reg_wben_i));

    wire reg_ext_en = reg_en_i[1];
    wire reg_core_en = reg_en_i[2];

    wire                         log_reg_en;
    wire [TCU_REG_DATA_SIZE-1:0] log_reg_rdata;


    always @(posedge clk_i) begin
        if (reset_sync_n == 1'b0) begin
            r_reg_rdata <= 64'h0;
            r_tcu_reset <= 1'b0;
            r_config_en <= 1'b0;
        end else begin
            r_reg_rdata <= rin_reg_rdata;
            r_tcu_reset <= rin_tcu_reset;
            r_config_en <= config_en_o;
        end
    end



    //---------------
    //memory for eps
    generate
    if (TCU_ENABLE_CMDS) begin: EP_MEM

        reg                          r_ep_mem_en, rin_ep_mem_en;
        reg   [EP_MEM_ADDRWIDTH-1:0] rin_ep_mem_addr;

        wire [TCU_REG_DATA_SIZE-1:0] ep_mem_rdata;


        always @(posedge clk_i) begin
            if (reset_sync_n == 1'b0) begin
                r_ep_mem_en <= 1'b0;
            end else begin
                r_ep_mem_en <= rin_ep_mem_en;
            end
        end

        mem_sp_bit_wrap #(
            .MEM_TYPE("distributed"),
            .MEM_DATAWIDTH(TCU_REG_DATA_SIZE),
            .MEM_ADDRWIDTH(EP_MEM_ADDRWIDTH)
        ) i_tcu_ep_mem (
            .clk    (clk_i),
            .reset  (~reset_n_i),
            .en     (rin_ep_mem_en),
            .we     (reg_wben_i),
            .addr   (rin_ep_mem_addr),
            .din    (reg_wdata_i),
            .dout   (ep_mem_rdata)
        );

    end
    endgenerate



    //---------------
    //TCU print
    reg                            rin_print_buf_en;
    reg  [PRINT_BUF_ADDRWIDTH-1:0] rin_print_buf_addr;

    wire                           print_buf_en;
    wire   [TCU_REG_DATA_SIZE-1:0] print_buf_rdata;


    //memory for prints
    generate
    if (TCU_ENABLE_CMDS && TCU_ENABLE_PRINT) begin: PRINT_BUF

        reg r_print_buf_en;

        always @(posedge clk_i) begin
            if (reset_sync_n == 1'b0) begin
                r_print_buf_en <= 1'b0;
            end else begin
                r_print_buf_en <= rin_print_buf_en;
            end
        end

        mem_sp_bit_wrap #(
            .MEM_TYPE("distributed"),
            .MEM_DATAWIDTH(TCU_REG_DATA_SIZE),
            .MEM_ADDRWIDTH(PRINT_BUF_ADDRWIDTH)
        ) i_tcu_print_buf (
            .clk    (clk_i),
            .reset  (~reset_n_i),
            .en     (rin_print_buf_en),
            .we     (reg_wben_i),
            .addr   (rin_print_buf_addr),
            .din    (reg_wdata_i),
            .dout   (print_buf_rdata)
        );

        assign print_buf_en = r_print_buf_en;

    end
    else begin: NO_PRINT_BUF
        assign print_buf_en = 1'b0;
        assign print_buf_rdata = {TCU_REG_DATA_SIZE{1'b0}};
    end
    endgenerate




    generate
    if (TCU_ENABLE_CMDS && !TCU_ENABLE_PRIV_CMDS) begin: TCU_UNPRIV_REGS
        integer i, i_ep;

        //---------------
        //register
        reg [63:0] r_tcu_reg_features, rin_tcu_reg_features;
        reg [63:0] r_tcu_reg_ext_cmd, rin_tcu_reg_ext_cmd;

        reg [63:0] r_tcu_reg_command, rin_tcu_reg_command;
        reg [63:0] r_tcu_reg_data, rin_tcu_reg_data;
        reg [63:0] r_tcu_reg_arg1, rin_tcu_reg_arg1;
        reg [64+TIMER_SCALE-1:0] r_tcu_reg_cur_time;
        reg [63:0] r_tcu_reg_print, rin_tcu_reg_print;

        reg  [2:0] r_tcu_fire, rin_tcu_fire;
        reg [63:0] r_tcu_fire_cmd, rin_tcu_fire_cmd;
        reg [63:0] r_tcu_fire_data, rin_tcu_fire_data;
        reg [63:0] r_tcu_fire_arg1, rin_tcu_fire_arg1;

        wire tcu_features_kernel = r_tcu_reg_features[0];

        wire [TMP_EP_SIZE-1:0] tmp_ep = reg_wdata_i[TCU_EP_SIZE+TCU_OPCODE_SIZE-1 : TCU_OPCODE_SIZE];
        wire [TMP_EP_SIZE-1:0] tmp_ext_ep = reg_wdata_i[TCU_EP_SIZE+TCU_ERROR_SIZE+TCU_OPCODE_SIZE-1 : TCU_ERROR_SIZE+TCU_OPCODE_SIZE];

        //time [ns] = cycles * 1000 / freq [MHz]
        wire [64+TIMER_SCALE-1:0] cur_time = r_tcu_reg_cur_time + ({{TIMER_SCALE{1'b0}}, 64'h1} * TIMER_FACTOR);


        //global reset: do not reset features reg and cur_time
        always @(posedge clk_i or negedge reset_n_i) begin
            if (reset_n_i == 1'b0) begin
                r_tcu_reg_features <= 64'h1;
                r_tcu_reg_cur_time <= {(64+TIMER_SCALE){1'b0}};
            end
            else begin
                r_tcu_reg_features <= rin_tcu_reg_features;
                r_tcu_reg_cur_time <= cur_time;
            end
        end

        //TCU local reset
        always @(posedge clk_i) begin
            if (reset_sync_n == 1'b0) begin
                r_tcu_reg_ext_cmd <= 64'h0;

                r_tcu_reg_command <= 64'h0;
                r_tcu_reg_data    <= 64'h0;
                r_tcu_reg_arg1    <= 64'h0;
                r_tcu_reg_print   <= 64'h0;

                r_tcu_fire      <= 3'h0;
                r_tcu_fire_cmd  <= 64'h0;
                r_tcu_fire_data <= 64'h0;
                r_tcu_fire_arg1 <= 64'h0;
            end
            else begin
                r_tcu_reg_ext_cmd <= rin_tcu_reg_ext_cmd;

                r_tcu_reg_command <= rin_tcu_reg_command;
                r_tcu_reg_data    <= rin_tcu_reg_data;
                r_tcu_reg_arg1    <= rin_tcu_reg_arg1;
                r_tcu_reg_print   <= rin_tcu_reg_print;

                r_tcu_fire      <= rin_tcu_fire;
                r_tcu_fire_cmd  <= rin_tcu_fire_cmd;
                r_tcu_fire_data <= rin_tcu_fire_data;
                r_tcu_fire_arg1 <= rin_tcu_fire_arg1;
            end
        end

        

        always @* begin
            rin_tcu_fire = 3'h0;
            rin_tcu_fire_cmd = r_tcu_fire_cmd;
            rin_tcu_fire_data = r_tcu_fire_data;
            rin_tcu_fire_arg1 = r_tcu_fire_arg1;           
            EP_MEM.rin_ep_mem_en = 1'b0;
            EP_MEM.rin_ep_mem_addr = {EP_MEM_ADDRWIDTH{1'b0}};

            rin_print_buf_en = 1'b0;
            rin_print_buf_addr = {PRINT_BUF_ADDRWIDTH{1'b0}};

            rin_tcu_reg_features = r_tcu_reg_features;
            rin_tcu_reg_ext_cmd = r_tcu_reg_ext_cmd;
            
            rin_tcu_reg_command = r_tcu_reg_command;
            rin_tcu_reg_data = r_tcu_reg_data;
            rin_tcu_reg_arg1 = r_tcu_reg_arg1;
            rin_tcu_reg_print = r_tcu_reg_print;

            rin_reg_rdata = 64'h0;
            rin_tcu_reset = 1'b0;

            config_en_o = 1'b0;
            config_wben_o = {TCU_REG_BSEL_SIZE{1'b0}};
            config_addr_o = {TCU_REG_ADDR_SIZE{1'b0}};
            config_wdata_o = {TCU_REG_DATA_SIZE{1'b0}};
            

            //---------------
            //register write
            if (reg_w_en) begin
                
                case (reg_addr_i)
                    TCU_REGADDR_FEATURES: begin
                        if (reg_ext_en) begin
                            for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                                if(reg_wben_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE]) begin
                                    rin_tcu_reg_features[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = reg_wdata_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE];
                                end
                            end
                        end
                    end

                    //ext_cmd reg can be written from external or from this TCU
                    TCU_REGADDR_EXT_CMD: begin
                        if (!reg_core_en || reg_ext_en) begin
                            for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                                if(reg_wben_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE]) begin
                                    rin_tcu_reg_ext_cmd[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = reg_wdata_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE];
                                end
                            end

                            //command is started when lower 32 bit of ext cmd reg are written with valid opcode
                            if (reg_wdata_i[3:0] != TCU_OPCODE_EXT_IDLE) begin
                                if (reg_wben_i == {{(TCU_REG_DATA_SIZE/2){1'b0}}, {(TCU_REG_DATA_SIZE/2){1'b1}}}) begin
                                    rin_tcu_fire = 3'b11;
                                    rin_tcu_fire_cmd = {r_tcu_reg_ext_cmd[63:32], reg_wdata_i[31:0]};
                                end
                                else if (reg_wben_i == {{(TCU_REG_DATA_SIZE/2){1'b1}}, {(TCU_REG_DATA_SIZE/2){1'b0}}}) begin
                                    rin_tcu_fire_cmd = {reg_wdata_i[63:32], r_tcu_reg_ext_cmd[31:0]};
                                end
                                else if (reg_wben_i == {TCU_REG_DATA_SIZE{1'b1}}) begin
                                    rin_tcu_fire = 3'b11;
                                    rin_tcu_fire_cmd = reg_wdata_i;
                                end
                            end
                        end
                    end
                    
                    TCU_REGADDR_COMMAND: begin
                        if (!reg_ext_en) begin
                            for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                                if(reg_wben_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE]) begin
                                    rin_tcu_reg_command[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = reg_wdata_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE];
                                end
                            end

                            rin_tcu_fire_data = r_tcu_reg_data;
                            rin_tcu_fire_arg1 = r_tcu_reg_arg1;

                            //command is started when lower 32 bit of cmd reg are written with valid opcode
                            if (reg_wdata_i[3:0] != TCU_OPCODE_IDLE) begin
                                if (reg_wben_i == {{(TCU_REG_DATA_SIZE/2){1'b0}}, {(TCU_REG_DATA_SIZE/2){1'b1}}}) begin
                                    rin_tcu_fire = 3'b01;
                                    rin_tcu_fire_cmd = {r_tcu_reg_command[63:32], reg_wdata_i[31:0]};
                                end
                                else if (reg_wben_i == {{(TCU_REG_DATA_SIZE/2){1'b1}}, {(TCU_REG_DATA_SIZE/2){1'b0}}}) begin
                                    rin_tcu_fire_cmd = {reg_wdata_i[63:32], r_tcu_reg_command[31:0]};
                                end
                                else if (reg_wben_i == {TCU_REG_DATA_SIZE{1'b1}}) begin
                                    rin_tcu_fire = 3'b01;
                                    rin_tcu_fire_cmd = reg_wdata_i;
                                end
                            end
                        end
                    end

                    TCU_REGADDR_DATA: begin
                        if (!reg_ext_en) begin
                            for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                                if(reg_wben_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE]) begin
                                    rin_tcu_reg_data[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = reg_wdata_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE];
                                end
                            end
                        end
                    end

                    TCU_REGADDR_ARG1: begin
                        if (!reg_ext_en) begin
                            for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                                if(reg_wben_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE]) begin
                                    rin_tcu_reg_arg1[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = reg_wdata_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE];
                                end
                            end
                        end
                    end

                    TCU_REGADDR_PRINT: begin
                        if (!reg_ext_en) begin
                            for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                                if(reg_wben_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE]) begin
                                    rin_tcu_reg_print[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = reg_wdata_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE];
                                end
                            end
                        end
                    end

                    TCU_REGADDR_TCU_RESET: begin
                        if (reg_ext_en) begin
                            rin_tcu_reset = 1'b1;
                        end
                    end

                    //default:
                endcase

                //EPs can always be written except from a User-PE
                if (!reg_core_en || tcu_features_kernel) begin
                    for (i_ep=0; i_ep<TCU_EP_REG_COUNT; i_ep=i_ep+1) begin
                        if (reg_addr_i == (TCU_REGADDR_EP_START+i_ep*TCU_EP_REG_SIZE)) begin
                            EP_MEM.rin_ep_mem_en = 1'b1;
                            EP_MEM.rin_ep_mem_addr = i_ep*3;
                        end
                        if (reg_addr_i == (TCU_REGADDR_EP_START+i_ep*TCU_EP_REG_SIZE+8)) begin
                            EP_MEM.rin_ep_mem_en = 1'b1;
                            EP_MEM.rin_ep_mem_addr = i_ep*3 + 1;
                        end
                        if (reg_addr_i == (TCU_REGADDR_EP_START+i_ep*TCU_EP_REG_SIZE+16)) begin
                            EP_MEM.rin_ep_mem_en = 1'b1;
                            EP_MEM.rin_ep_mem_addr = i_ep*3 + 2;
                        end
                    end
                end

                //write to print memory
                if (TCU_ENABLE_PRINT && !reg_ext_en && (reg_addr_i >= TCU_REGADDR_PRINT_BUF) && (reg_addr_i < (TCU_REGADDR_PRINT_BUF+TCU_PRINT_REG_COUNT*TCU_PRINT_REG_SIZE))) begin
                    rin_print_buf_en = 1'b1;
                    rin_print_buf_addr = (reg_addr_i - TCU_REGADDR_PRINT_BUF) >> 3;
                end

                //write to core-specific regs
                if ((reg_addr_i >= TCU_REGADDR_CORE_CFG_START) && (reg_addr_i < (TCU_REGADDR_CORE_CFG_START+TCU_CFG_REG_COUNT*TCU_CFG_REG_SIZE))) begin
                    config_en_o = 1'b1;
                    config_addr_o = reg_addr_i - TCU_REGADDR_CORE_CFG_START;
                    config_wdata_o = reg_wdata_i;
                    for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                        if (reg_wben_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE]) config_wben_o[i] = 1'b1;
                    end
                end
            end

            //---------------
            //register read
            else if (reg_r_en) begin
                case (reg_addr_i)
                    TCU_REGADDR_FEATURES: begin
                        rin_reg_rdata = r_tcu_reg_features;
                    end

                    TCU_REGADDR_EXT_CMD: begin
                        rin_reg_rdata = r_tcu_reg_ext_cmd;
                    end
                    
                    TCU_REGADDR_COMMAND: begin
                        rin_reg_rdata = r_tcu_reg_command;
                    end

                    TCU_REGADDR_DATA: begin
                        rin_reg_rdata = r_tcu_reg_data;
                    end

                    TCU_REGADDR_ARG1: begin
                        rin_reg_rdata = r_tcu_reg_arg1;
                    end

                    TCU_REGADDR_PRINT: begin
                        rin_reg_rdata = r_tcu_reg_print;
                    end

                    TCU_REGADDR_CUR_TIME: begin
                        rin_reg_rdata = r_tcu_reg_cur_time[64+TIMER_SCALE-1:TIMER_SCALE];
                    end

                    TCU_REGADDR_TCU_STATUS: begin
                        rin_reg_rdata = tcu_status_i;
                    end

                    TCU_REGADDR_TCU_CTRL_FLIT_COUNT: begin
                        rin_reg_rdata = {noc1_tx_flit_count_i, noc1_rx_flit_count_i};
                    end

                    TCU_REGADDR_TCU_BYP_FLIT_COUNT: begin
                        rin_reg_rdata = {noc2_tx_flit_count_i, noc2_rx_flit_count_i};
                    end

                    TCU_REGADDR_TCU_DROP_FLIT_COUNT: begin
                        rin_reg_rdata = {noc_error_flit_count_i, noc_drop_flit_count_i};
                    end

                    default: begin
                        rin_reg_rdata = 64'h0;
                    end
                endcase

                for (i_ep=0; i_ep<TCU_EP_REG_COUNT; i_ep=i_ep+1) begin
                    if (reg_addr_i == (TCU_REGADDR_EP_START+i_ep*TCU_EP_REG_SIZE)) begin
                        EP_MEM.rin_ep_mem_en = 1'b1;
                        EP_MEM.rin_ep_mem_addr = i_ep*3;
                    end
                    if (reg_addr_i == (TCU_REGADDR_EP_START+i_ep*TCU_EP_REG_SIZE+8)) begin
                        EP_MEM.rin_ep_mem_en = 1'b1;
                        EP_MEM.rin_ep_mem_addr = i_ep*3 + 1;
                    end
                    if (reg_addr_i == (TCU_REGADDR_EP_START+i_ep*TCU_EP_REG_SIZE+16)) begin
                        EP_MEM.rin_ep_mem_en = 1'b1;
                        EP_MEM.rin_ep_mem_addr = i_ep*3 + 2;
                    end
                end

                if (TCU_ENABLE_PRINT && (reg_addr_i >= TCU_REGADDR_PRINT_BUF) && (reg_addr_i < (TCU_REGADDR_PRINT_BUF+TCU_PRINT_REG_COUNT*TCU_PRINT_REG_SIZE))) begin
                    rin_print_buf_en = 1'b1;
                    rin_print_buf_addr = (reg_addr_i - TCU_REGADDR_PRINT_BUF) >> 3;
                end

                if ((reg_addr_i >= TCU_REGADDR_CORE_CFG_START) && (reg_addr_i < (TCU_REGADDR_CORE_CFG_START+TCU_CFG_REG_COUNT*TCU_CFG_REG_SIZE))) begin
                    config_en_o = 1'b1;
                    config_wben_o = {TCU_REG_BSEL_SIZE{1'b0}};
                    config_addr_o = reg_addr_i - TCU_REGADDR_CORE_CFG_START;
                end
            end
        end


        assign tcu_fire_o         = r_tcu_fire;
        assign tcu_fire_cmd_o     = r_tcu_fire_cmd;
        assign tcu_fire_data_o    = r_tcu_fire_data;
        assign tcu_fire_arg1_o    = r_tcu_fire_arg1;
        assign tcu_fire_cur_vpe_o = TCU_VPEID_INVALID;

        assign tcu_log_cur_vpe_o = TCU_LOG_NONE;

        assign cur_time_s = r_tcu_reg_cur_time[64+TIMER_SCALE-1:TIMER_SCALE];

        assign tcu_features_virt_addr_o = 1'b0;
        assign tcu_features_virt_pes_o = 1'b0;

        assign tcu_print_valid_o = (TCU_ENABLE_PRINT && (r_tcu_reg_print != 'h0)) ? 1'b1 : 1'b0;
    end


    else if (TCU_ENABLE_CMDS && TCU_ENABLE_PRIV_CMDS) begin: TCU_PRIV_REGS
        integer i, i_ep;

        //---------------
        //register
        reg [63:0] r_tcu_reg_features, rin_tcu_reg_features;
        reg [63:0] r_tcu_reg_ext_cmd, rin_tcu_reg_ext_cmd;

        reg [63:0] r_tcu_reg_command, rin_tcu_reg_command;
        reg [63:0] r_tcu_reg_data, rin_tcu_reg_data;
        reg [63:0] r_tcu_reg_arg1, rin_tcu_reg_arg1;
        reg [64+TIMER_SCALE-1:0] r_tcu_reg_cur_time;
        reg [63:0] r_tcu_reg_print, rin_tcu_reg_print;

        reg [63:0] r_tcu_reg_core_req, rin_tcu_reg_core_req;
        reg [63:0] r_tcu_reg_priv_cmd, rin_tcu_reg_priv_cmd;
        reg [63:0] r_tcu_reg_priv_cmd_arg, rin_tcu_reg_priv_cmd_arg;
        reg [63:0] r_tcu_reg_cur_vpe, rin_tcu_reg_cur_vpe;
        reg [63:0] r2_tcu_reg_cur_vpe;

        reg  [2:0] r_tcu_fire, rin_tcu_fire;
        reg [63:0] r_tcu_fire_cmd, rin_tcu_fire_cmd;
        reg [63:0] r_tcu_fire_data, rin_tcu_fire_data;
        reg [63:0] r_tcu_fire_arg1, rin_tcu_fire_arg1;

        wire tcu_features_kernel = r_tcu_reg_features[0];
        wire tcu_features_virt_addr = r_tcu_reg_features[1];
        wire tcu_features_virt_pes = r_tcu_reg_features[2];

        wire [TMP_EP_SIZE-1:0] tmp_ep = reg_wdata_i[TCU_EP_SIZE+TCU_OPCODE_SIZE-1 : TCU_OPCODE_SIZE];
        wire [TMP_EP_SIZE-1:0] tmp_ext_ep = reg_wdata_i[TCU_EP_SIZE+TCU_ERROR_SIZE+TCU_OPCODE_SIZE-1 : TCU_ERROR_SIZE+TCU_OPCODE_SIZE];

        //time [ns] = cycles * 1000 / freq [MHz]
        wire [64+TIMER_SCALE-1:0] cur_time = r_tcu_reg_cur_time + ({{TIMER_SCALE{1'b0}}, 64'h1} * TIMER_FACTOR);


        //global reset: do not reset features reg and cur_time
        always @(posedge clk_i or negedge reset_n_i) begin
            if (reset_n_i == 1'b0) begin
                r_tcu_reg_features <= 64'h1;
                r_tcu_reg_cur_time <= {(64+TIMER_SCALE){1'b0}};
            end
            else begin
                r_tcu_reg_features <= rin_tcu_reg_features;
                r_tcu_reg_cur_time <= cur_time;
            end
        end

        //TCU local reset
        always @(posedge clk_i) begin
            if (reset_sync_n == 1'b0) begin
                r_tcu_reg_ext_cmd <= 64'h0;

                r_tcu_reg_command <= 64'h0;
                r_tcu_reg_data    <= 64'h0;
                r_tcu_reg_arg1    <= 64'h0;
                r_tcu_reg_print   <= 64'h0;

                r_tcu_reg_core_req     <= 64'h0;
                r_tcu_reg_priv_cmd     <= 64'h0;
                r_tcu_reg_priv_cmd_arg <= 64'h0;
                r_tcu_reg_cur_vpe      <= TCU_VPEID_INVALID;
                r2_tcu_reg_cur_vpe     <= TCU_VPEID_INVALID;

                r_tcu_fire      <= 3'h0;
                r_tcu_fire_cmd  <= 64'h0;
                r_tcu_fire_data <= 64'h0;
                r_tcu_fire_arg1 <= 64'h0;
            end
            else begin
                r_tcu_reg_ext_cmd <= rin_tcu_reg_ext_cmd;

                r_tcu_reg_command <= rin_tcu_reg_command;
                r_tcu_reg_data    <= rin_tcu_reg_data;
                r_tcu_reg_arg1    <= rin_tcu_reg_arg1;
                r_tcu_reg_print   <= rin_tcu_reg_print;

                r_tcu_reg_core_req     <= rin_tcu_reg_core_req;
                r_tcu_reg_priv_cmd     <= rin_tcu_reg_priv_cmd;
                r_tcu_reg_priv_cmd_arg <= rin_tcu_reg_priv_cmd_arg;
                r_tcu_reg_cur_vpe      <= rin_tcu_reg_cur_vpe;
                r2_tcu_reg_cur_vpe     <= r_tcu_reg_cur_vpe;

                r_tcu_fire      <= rin_tcu_fire;
                r_tcu_fire_cmd  <= rin_tcu_fire_cmd;
                r_tcu_fire_data <= rin_tcu_fire_data;
                r_tcu_fire_arg1 <= rin_tcu_fire_arg1;
            end
        end

        

        always @* begin
            rin_tcu_fire = 3'h0;
            rin_tcu_fire_cmd = r_tcu_fire_cmd;
            rin_tcu_fire_data = r_tcu_fire_data;
            rin_tcu_fire_arg1 = r_tcu_fire_arg1;
            EP_MEM.rin_ep_mem_en = 1'b0;
            EP_MEM.rin_ep_mem_addr = {EP_MEM_ADDRWIDTH{1'b0}};

            rin_print_buf_en = 1'b0;
            rin_print_buf_addr = {PRINT_BUF_ADDRWIDTH{1'b0}};

            rin_tcu_reg_features = r_tcu_reg_features;
            rin_tcu_reg_ext_cmd = r_tcu_reg_ext_cmd;
            
            rin_tcu_reg_command = r_tcu_reg_command;
            rin_tcu_reg_data = r_tcu_reg_data;
            rin_tcu_reg_arg1 = r_tcu_reg_arg1;
            rin_tcu_reg_print = r_tcu_reg_print;

            rin_tcu_reg_core_req     = r_tcu_reg_core_req;
            rin_tcu_reg_priv_cmd     = r_tcu_reg_priv_cmd;
            rin_tcu_reg_priv_cmd_arg = r_tcu_reg_priv_cmd_arg;
            rin_tcu_reg_cur_vpe      = r_tcu_reg_cur_vpe;

            rin_reg_rdata = 64'h0;
            rin_tcu_reset = 1'b0;

            config_en_o = 1'b0;
            config_wben_o = {TCU_REG_BSEL_SIZE{1'b0}};
            config_addr_o = {TCU_REG_ADDR_SIZE{1'b0}};
            config_wdata_o = {TCU_REG_DATA_SIZE{1'b0}};
            

            //---------------
            //register write
            if (reg_w_en) begin
                
                case (reg_addr_i)
                    TCU_REGADDR_FEATURES: begin
                        if (reg_ext_en) begin
                            for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                                if(reg_wben_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE]) begin
                                    rin_tcu_reg_features[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = reg_wdata_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE];
                                end
                            end
                        end
                    end

                    //ext_cmd reg can be written from external or from this TCU
                    TCU_REGADDR_EXT_CMD: begin
                        if (!reg_core_en || reg_ext_en) begin
                            for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                                if(reg_wben_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE]) begin
                                    rin_tcu_reg_ext_cmd[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = reg_wdata_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE];
                                end
                            end

                            //command is started when lower 32 bit of ext cmd reg are written with valid opcode
                            if (reg_wdata_i[3:0] != TCU_OPCODE_EXT_IDLE) begin
                                if (reg_wben_i == {{(TCU_REG_DATA_SIZE/2){1'b0}}, {(TCU_REG_DATA_SIZE/2){1'b1}}}) begin
                                    rin_tcu_fire = 3'b11;
                                    rin_tcu_fire_cmd = {r_tcu_reg_ext_cmd[63:32], reg_wdata_i[31:0]};
                                end
                                else if (reg_wben_i == {{(TCU_REG_DATA_SIZE/2){1'b1}}, {(TCU_REG_DATA_SIZE/2){1'b0}}}) begin
                                    rin_tcu_fire_cmd = {reg_wdata_i[63:32], r_tcu_reg_ext_cmd[31:0]};
                                end
                                else if (reg_wben_i == {TCU_REG_DATA_SIZE{1'b1}}) begin
                                    rin_tcu_fire = 3'b11;
                                    rin_tcu_fire_cmd = reg_wdata_i;
                                end
                            end
                        end
                    end

                    TCU_REGADDR_COMMAND: begin
                        if (!reg_ext_en) begin
                            for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                                if(reg_wben_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE]) begin
                                    rin_tcu_reg_command[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = reg_wdata_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE];
                                end
                            end
                            
                            rin_tcu_fire_data = r_tcu_reg_data;
                            rin_tcu_fire_arg1 = r_tcu_reg_arg1;

                            //command is started when lower 32 bit of cmd reg are written with valid opcode
                            if (reg_wdata_i[3:0] != TCU_OPCODE_IDLE) begin
                                if (reg_wben_i == {{(TCU_REG_DATA_SIZE/2){1'b0}}, {(TCU_REG_DATA_SIZE/2){1'b1}}}) begin
                                    rin_tcu_fire = 3'b01;
                                    rin_tcu_fire_cmd = {r_tcu_reg_command[63:32], reg_wdata_i[31:0]};
                                end
                                else if (reg_wben_i == {{(TCU_REG_DATA_SIZE/2){1'b1}}, {(TCU_REG_DATA_SIZE/2){1'b0}}}) begin
                                    rin_tcu_fire_cmd = {reg_wdata_i[63:32], r_tcu_reg_command[31:0]};
                                end
                                else if (reg_wben_i == {TCU_REG_DATA_SIZE{1'b1}}) begin
                                    rin_tcu_fire = 3'b01;
                                    rin_tcu_fire_cmd = reg_wdata_i;
                                end
                            end
                        end
                    end

                    TCU_REGADDR_DATA: begin
                        if (!reg_ext_en) begin
                            for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                                if(reg_wben_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE]) begin
                                    rin_tcu_reg_data[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = reg_wdata_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE];
                                end
                            end
                        end
                    end

                    TCU_REGADDR_ARG1: begin
                        if (!reg_ext_en) begin
                            for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                                if(reg_wben_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE]) begin
                                    rin_tcu_reg_arg1[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = reg_wdata_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE];
                                end
                            end
                        end
                    end

                    TCU_REGADDR_PRINT: begin
                        if (!reg_ext_en) begin
                            for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                                if(reg_wben_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE]) begin
                                    rin_tcu_reg_print[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = reg_wdata_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE];
                                end
                            end
                        end
                    end

                    TCU_REGADDR_CORE_REQ: begin
                        if (tcu_features_virt_addr || tcu_features_virt_pes) begin
                            for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                                if(reg_wben_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE]) begin
                                    rin_tcu_reg_core_req[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = reg_wdata_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE];
                                end
                            end
                        end
                    end

                    TCU_REGADDR_PRIV_CMD: begin
                        if (tcu_features_virt_addr || tcu_features_virt_pes) begin
                            for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                                if(reg_wben_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE]) begin
                                    rin_tcu_reg_priv_cmd[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = reg_wdata_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE];
                                end
                            end

                            rin_tcu_fire_arg1 = r_tcu_reg_priv_cmd_arg;

                            //command is started when lower 32 bit of cmd reg are written with valid opcode
                            if (reg_wdata_i[3:0] != TCU_OPCODE_IDLE) begin
                                if (reg_wben_i == {{(TCU_REG_DATA_SIZE/2){1'b0}}, {(TCU_REG_DATA_SIZE/2){1'b1}}}) begin
                                    rin_tcu_fire = 3'b101;
                                    rin_tcu_fire_cmd = {r_tcu_reg_priv_cmd[63:32], reg_wdata_i[31:0]};
                                end
                                else if (reg_wben_i == {{(TCU_REG_DATA_SIZE/2){1'b1}}, {(TCU_REG_DATA_SIZE/2){1'b0}}}) begin
                                    rin_tcu_fire_cmd = {reg_wdata_i[63:32], r_tcu_reg_priv_cmd[31:0]};
                                end
                                else if (reg_wben_i == {TCU_REG_DATA_SIZE{1'b1}}) begin
                                    rin_tcu_fire = 3'b101;
                                    rin_tcu_fire_cmd = reg_wdata_i;
                                end
                            end
                        end
                    end

                    TCU_REGADDR_PRIV_CMD_ARG: begin
                        if (tcu_features_virt_addr || tcu_features_virt_pes) begin
                            for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                                if(reg_wben_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE]) begin
                                    rin_tcu_reg_priv_cmd_arg[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = reg_wdata_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE];
                                end
                            end
                        end
                    end

                    TCU_REGADDR_CUR_VPE: begin
                        if (tcu_features_virt_pes) begin
                            for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                                if(reg_wben_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE]) begin
                                    rin_tcu_reg_cur_vpe[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = reg_wdata_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE];
                                end
                            end
                        end
                    end

                    TCU_REGADDR_TCU_RESET: begin
                        if (reg_ext_en) begin
                            rin_tcu_reset = 1'b1;
                        end
                    end

                    //default:
                endcase

                //EPs can always be written except from a User-PE
                if (!reg_core_en || tcu_features_kernel) begin
                    for (i_ep=0; i_ep<TCU_EP_REG_COUNT; i_ep=i_ep+1) begin
                        if (reg_addr_i == (TCU_REGADDR_EP_START+i_ep*TCU_EP_REG_SIZE)) begin
                            EP_MEM.rin_ep_mem_en = 1'b1;
                            EP_MEM.rin_ep_mem_addr = i_ep*3;
                        end
                        if (reg_addr_i == (TCU_REGADDR_EP_START+i_ep*TCU_EP_REG_SIZE+8)) begin
                            EP_MEM.rin_ep_mem_en = 1'b1;
                            EP_MEM.rin_ep_mem_addr = i_ep*3 + 1;
                        end
                        if (reg_addr_i == (TCU_REGADDR_EP_START+i_ep*TCU_EP_REG_SIZE+16)) begin
                            EP_MEM.rin_ep_mem_en = 1'b1;
                            EP_MEM.rin_ep_mem_addr = i_ep*3 + 2;
                        end
                    end
                end

                //write to print memory
                if (TCU_ENABLE_PRINT && !reg_ext_en && (reg_addr_i >= TCU_REGADDR_PRINT_BUF) && (reg_addr_i < (TCU_REGADDR_PRINT_BUF+TCU_PRINT_REG_COUNT*TCU_PRINT_REG_SIZE))) begin
                    rin_print_buf_en = 1'b1;
                    rin_print_buf_addr = (reg_addr_i - TCU_REGADDR_PRINT_BUF) >> 3;
                end

                //write to core-specific regs
                if ((reg_addr_i >= TCU_REGADDR_CORE_CFG_START) && (reg_addr_i < (TCU_REGADDR_CORE_CFG_START+TCU_CFG_REG_COUNT*TCU_CFG_REG_SIZE))) begin
                    config_en_o = 1'b1;
                    config_addr_o = reg_addr_i - TCU_REGADDR_CORE_CFG_START;
                    config_wdata_o = reg_wdata_i;
                    for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                        if (reg_wben_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE]) config_wben_o[i] = 1'b1;
                    end
                end
            end

            //---------------
            //register read
            else if (reg_r_en) begin
                case (reg_addr_i)
                    TCU_REGADDR_FEATURES: begin
                        rin_reg_rdata = r_tcu_reg_features;
                    end

                    TCU_REGADDR_EXT_CMD: begin
                        rin_reg_rdata = r_tcu_reg_ext_cmd;
                    end
                    
                    TCU_REGADDR_COMMAND: begin
                        rin_reg_rdata = r_tcu_reg_command;
                    end

                    TCU_REGADDR_DATA: begin
                        rin_reg_rdata = r_tcu_reg_data;
                    end

                    TCU_REGADDR_ARG1: begin
                        rin_reg_rdata = r_tcu_reg_arg1;
                    end

                    TCU_REGADDR_PRINT: begin
                        rin_reg_rdata = r_tcu_reg_print;
                    end

                    TCU_REGADDR_CUR_TIME: begin
                        rin_reg_rdata = r_tcu_reg_cur_time[64+TIMER_SCALE-1:TIMER_SCALE];
                    end

                    TCU_REGADDR_CORE_REQ: begin
                        rin_reg_rdata = r_tcu_reg_core_req;
                    end

                    TCU_REGADDR_PRIV_CMD: begin
                        rin_reg_rdata = r_tcu_reg_priv_cmd;
                    end

                    TCU_REGADDR_PRIV_CMD_ARG: begin
                        rin_reg_rdata = r_tcu_reg_priv_cmd_arg;
                    end

                    TCU_REGADDR_CUR_VPE: begin
                        rin_reg_rdata = r_tcu_reg_cur_vpe;
                    end

                    TCU_REGADDR_TCU_STATUS: begin
                        rin_reg_rdata = tcu_status_i;
                    end

                    TCU_REGADDR_TCU_CTRL_FLIT_COUNT: begin
                        rin_reg_rdata = {noc1_tx_flit_count_i, noc1_rx_flit_count_i};
                    end

                    TCU_REGADDR_TCU_BYP_FLIT_COUNT: begin
                        rin_reg_rdata = {noc2_tx_flit_count_i, noc2_rx_flit_count_i};
                    end

                    TCU_REGADDR_TCU_DROP_FLIT_COUNT: begin
                        rin_reg_rdata = {noc_error_flit_count_i, noc_drop_flit_count_i};
                    end

                    default: begin
                        rin_reg_rdata = 64'h0;
                    end
                endcase

                for (i_ep=0; i_ep<TCU_EP_REG_COUNT; i_ep=i_ep+1) begin
                    if (reg_addr_i == (TCU_REGADDR_EP_START+i_ep*TCU_EP_REG_SIZE)) begin
                        EP_MEM.rin_ep_mem_en = 1'b1;
                        EP_MEM.rin_ep_mem_addr = i_ep*3;
                    end
                    if (reg_addr_i == (TCU_REGADDR_EP_START+i_ep*TCU_EP_REG_SIZE+8)) begin
                        EP_MEM.rin_ep_mem_en = 1'b1;
                        EP_MEM.rin_ep_mem_addr = i_ep*3 + 1;
                    end
                    if (reg_addr_i == (TCU_REGADDR_EP_START+i_ep*TCU_EP_REG_SIZE+16)) begin
                        EP_MEM.rin_ep_mem_en = 1'b1;
                        EP_MEM.rin_ep_mem_addr = i_ep*3 + 2;
                    end
                end

                if (TCU_ENABLE_PRINT && (reg_addr_i >= TCU_REGADDR_PRINT_BUF) && (reg_addr_i < (TCU_REGADDR_PRINT_BUF+TCU_PRINT_REG_COUNT*TCU_PRINT_REG_SIZE))) begin
                    rin_print_buf_en = 1'b1;
                    rin_print_buf_addr = (reg_addr_i - TCU_REGADDR_PRINT_BUF) >> 3;
                end

                if ((reg_addr_i >= TCU_REGADDR_CORE_CFG_START) && (reg_addr_i < (TCU_REGADDR_CORE_CFG_START+TCU_CFG_REG_COUNT*TCU_CFG_REG_SIZE))) begin
                    config_en_o = 1'b1;
                    config_wben_o = {TCU_REG_BSEL_SIZE{1'b0}};
                    config_addr_o = reg_addr_i - TCU_REGADDR_CORE_CFG_START;
                end
            end
        end


        assign tcu_fire_o         = r_tcu_fire;
        assign tcu_fire_cmd_o     = r_tcu_fire_cmd;
        assign tcu_fire_data_o    = r_tcu_fire_data;
        assign tcu_fire_arg1_o    = r_tcu_fire_arg1;
        assign tcu_fire_cur_vpe_o = tcu_features_virt_pes ? r_tcu_reg_cur_vpe : TCU_VPEID_INVALID;

        assign tcu_log_cur_vpe_o = (r_tcu_reg_cur_vpe[31:0] != r2_tcu_reg_cur_vpe[31:0]) ?
                                    {r2_tcu_reg_cur_vpe[31:0], r_tcu_reg_cur_vpe[31:0], TCU_LOG_PRIV_CUR_VPE_CHANGE} :
                                    TCU_LOG_NONE;

        assign cur_time_s = r_tcu_reg_cur_time[64+TIMER_SCALE-1:TIMER_SCALE];

        assign tcu_features_virt_addr_o = tcu_features_virt_addr;
        assign tcu_features_virt_pes_o = tcu_features_virt_pes;

        assign tcu_print_valid_o = (TCU_ENABLE_PRINT && (r_tcu_reg_print != 'h0)) ? 1'b1 : 1'b0;
    end


    else begin: TCU_CONFIG_REGS

        always @* begin
            rin_reg_rdata = 64'h0;
            rin_tcu_reset = 1'b0;

            rin_print_buf_en = 1'b0;
            rin_print_buf_addr = {PRINT_BUF_ADDRWIDTH{1'b0}};

            config_en_o = 1'b0;
            config_wben_o = {TCU_REG_BSEL_SIZE{1'b0}};
            config_addr_o = {TCU_REG_ADDR_SIZE{1'b0}};
            config_wdata_o = {TCU_REG_DATA_SIZE{1'b0}};

            //---------------
            //register write
            if (reg_w_en) begin
                if ((reg_addr_i == TCU_REGADDR_TCU_RESET) && reg_ext_en) begin
                    rin_tcu_reset = 1'b1;
                end
                else if ((reg_addr_i >= TCU_REGADDR_CORE_CFG_START) && (reg_addr_i < (TCU_REGADDR_CORE_CFG_START+TCU_CFG_REG_COUNT*TCU_CFG_REG_SIZE))) begin
                    config_en_o = 1'b1;
                    config_addr_o = reg_addr_i - TCU_REGADDR_CORE_CFG_START;
                    config_wdata_o = reg_wdata_i;
                    for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                        if (reg_wben_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE]) config_wben_o[i] = 1'b1;
                    end
                end
            end

            //---------------
            //register read
            else if (reg_r_en) begin
                case (reg_addr_i)
                    TCU_REGADDR_TCU_STATUS: begin
                        rin_reg_rdata = tcu_status_i;
                    end

                    TCU_REGADDR_TCU_CTRL_FLIT_COUNT: begin
                        rin_reg_rdata = {noc1_tx_flit_count_i, noc1_rx_flit_count_i};
                    end

                    TCU_REGADDR_TCU_BYP_FLIT_COUNT: begin
                        rin_reg_rdata = {noc2_tx_flit_count_i, noc2_rx_flit_count_i};
                    end

                    TCU_REGADDR_TCU_DROP_FLIT_COUNT: begin
                        rin_reg_rdata = {noc_error_flit_count_i, noc_drop_flit_count_i};
                    end

                    default: begin
                        rin_reg_rdata = 64'h0;
                    end
                endcase

                if ((reg_addr_i >= TCU_REGADDR_CORE_CFG_START) && (reg_addr_i < (TCU_REGADDR_CORE_CFG_START+TCU_CFG_REG_COUNT*TCU_CFG_REG_SIZE))) begin
                    config_en_o = 1'b1;
                    config_wben_o = {TCU_REG_BSEL_SIZE{1'b0}};
                    config_addr_o = reg_addr_i - TCU_REGADDR_CORE_CFG_START;
                end
            end
        end


        assign tcu_fire_o         = 3'h0;
        assign tcu_fire_cmd_o     = 64'h0;
        assign tcu_fire_data_o    = 64'h0;
        assign tcu_fire_arg1_o    = 64'h0;
        assign tcu_fire_cur_vpe_o = TCU_VPEID_INVALID;

        assign tcu_log_cur_vpe_o = TCU_LOG_NONE;

        assign cur_time_s = {(64+TIMER_SCALE){1'b0}};

        assign tcu_features_virt_addr_o = 1'b0;
        assign tcu_features_virt_pes_o = 1'b0;

        assign tcu_print_valid_o = 1'b0;
    end
    endgenerate


    generate
    if (TCU_ENABLE_LOG) begin: LOGGING
        reg r_log_reg_en, rin_log_reg_en;

        always @(posedge clk_i) begin
            if (reset_sync_n == 1'b0) begin
                r_log_reg_en <= 1'b0;
            end else begin
                r_log_reg_en <= rin_log_reg_en;
            end
        end

        always @* begin
            rin_log_reg_en = 1'b0;

            //max. addr is TCU_LOG_REG_COUNT+2 because log count and log select take first two addresses
            if (reg_en_i[0] && (reg_addr_i >= TCU_REGADDR_TCU_LOG) && (reg_addr_i < (TCU_REGADDR_TCU_LOG+(TCU_LOG_REG_COUNT+2)*8))) begin
                rin_log_reg_en = 1'b1;
            end
        end

        assign log_reg_en = r_log_reg_en;

        tcu_log i_tcu_log (
            .clk_i               (clk_i),
            .reset_n_i           (reset_sync_n),

            .tcu_log_en_i        (tcu_log_en_i),
            .tcu_log_data_i      (tcu_log_data_i),
            .tcu_log_cur_time_i  (cur_time_s),

            .tcu_log_reg_en_i    (rin_log_reg_en),
            .tcu_log_reg_wben_i  (reg_wben_i),
            .tcu_log_reg_addr_i  (reg_addr_i),
            .tcu_log_reg_wdata_i (reg_wdata_i),
            .tcu_log_reg_rdata_o (log_reg_rdata)
        );
    end
    else begin: NO_LOGGING
        assign log_reg_en = 1'b0;
        assign log_reg_rdata = {TCU_REG_DATA_SIZE{1'b0}};
    end
    endgenerate


    generate
    if (TCU_ENABLE_CMDS) begin
        assign reg_rdata_o = r_config_en ? config_rdata_i :
                                EP_MEM.r_ep_mem_en ? EP_MEM.ep_mem_rdata :
                                (TCU_ENABLE_PRINT && print_buf_en) ? print_buf_rdata :
                                (TCU_ENABLE_LOG && log_reg_en) ? log_reg_rdata :
                                r_reg_rdata;
    end
    else begin
        assign reg_rdata_o = r_config_en ? config_rdata_i :
                                (TCU_ENABLE_LOG && log_reg_en) ? log_reg_rdata :
                                r_reg_rdata;
    end
    endgenerate

    assign reg_stall_o = 1'b0;
    assign tcu_reset_o = r_tcu_reset;

    assign tcu_cur_time_o = cur_time_s;


    tcu_ctrl_reset i_tcu_regs_reset (
        .clk_i           (clk_i),
        .reset_n_i       (reset_n_i),
        .reset_sync_n_o  (reset_sync_n),
        .tcu_reset_i     (r_tcu_reset)
    );


endmodule
