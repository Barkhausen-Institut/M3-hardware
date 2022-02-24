
module tcu_log #(
    `include "tcu_parameter.vh"
    ,parameter TCU_LOG_MEM_DATAWIDTH = 128, //do not edit
    parameter TCU_LOG_MEM_ADDRWIDTH  = $clog2(TCU_LOG_REG_COUNT/2)
)(
    input  wire                         clk_i,
    input  wire                         reset_n_i,

    input  wire                         tcu_log_en_i,
    input  wire [TCU_LOG_DATA_SIZE-1:0] tcu_log_data_i,

    input  wire                  [63:0] tcu_log_cur_time_i,

    input  wire                         tcu_log_reg_en_i,
    input  wire [TCU_REG_DATA_SIZE-1:0] tcu_log_reg_wben_i, //bit-wise select
    input  wire [TCU_REG_ADDR_SIZE-1:0] tcu_log_reg_addr_i,
    input  wire [TCU_REG_DATA_SIZE-1:0] tcu_log_reg_wdata_i,
    output wire [TCU_REG_DATA_SIZE-1:0] tcu_log_reg_rdata_o
);

    localparam TCU_REG_LOG2_DATA_SIZE = $clog2(TCU_REG_DATA_SIZE);

    integer i;

    reg                              r_log_mem_en;
    reg                       [31:0] r_log_mem_addr, rin_log_mem_addr;
    reg  [TCU_LOG_MEM_DATAWIDTH-1:0] r_log_mem_wdata;

    reg      [TCU_REG_ADDR_SIZE-1:0] r_log_reg_addr;

    reg      [TCU_REG_DATA_SIZE-1:0] r_log_select, rin_log_select;

    //shift by 4 due to 128-bit rows, -16 to provide space for number of logs and log selection
    wire [TCU_LOG_MEM_ADDRWIDTH-1:0] log_mem_reg_addr = (tcu_log_reg_addr_i-TCU_REGADDR_TCU_LOG-16) >> 4;
    wire [TCU_LOG_MEM_DATAWIDTH-1:0] log_mem_reg_rdata;

    wire [TCU_REG_LOG2_DATA_SIZE-1:0] log_id_decr = tcu_log_data_i[TCU_LOG_ID_SIZE-1:0] - 1;
    wire                              log_valid = r_log_select[log_id_decr];


    //first addr contains number of log messages (number of occupied 128-bit rows)
    //second addr contains mask of selected logs
    //decide according to addr alignment to take lower or upper rdata
    assign tcu_log_reg_rdata_o = (r_log_reg_addr == TCU_REGADDR_TCU_LOG) ? r_log_mem_addr :
                                    (r_log_reg_addr == (TCU_REGADDR_TCU_LOG+8)) ? r_log_select :
                                    (r_log_reg_addr[3:0] == 4'h0) ? log_mem_reg_rdata[63:0] : log_mem_reg_rdata[127:64];


    //sync reset
    always @(posedge clk_i) begin
        if (reset_n_i == 1'b0) begin
            r_log_mem_en <= 1'b0;
            r_log_mem_addr <= 32'h0;
            r_log_mem_wdata <= {TCU_LOG_MEM_DATAWIDTH{1'b0}};

            r_log_reg_addr <= {TCU_REG_ADDR_SIZE{1'b0}};

            r_log_select <= {TCU_REG_DATA_SIZE{1'b1}};
        end
        else begin
            r_log_mem_en <= tcu_log_en_i && log_valid;
            r_log_mem_addr <= rin_log_mem_addr;
            r_log_mem_wdata <= {tcu_log_data_i, tcu_log_cur_time_i[35:4]};  //ignore lower 4 Bits for higher time range

            r_log_reg_addr <= tcu_log_reg_addr_i;

            r_log_select <= rin_log_select;
        end
    end

    always @* begin
        rin_log_mem_addr = r_log_mem_addr;

        //incr addr in subsequent cycle due to registered wdata
        //if memory is full overwrite first logs again
        if (r_log_mem_en) begin
            rin_log_mem_addr = r_log_mem_addr + 1;
        end
    end

    //set log select
    always @* begin
        rin_log_select = r_log_select;

        if (tcu_log_reg_en_i && (tcu_log_reg_addr_i == (TCU_REGADDR_TCU_LOG+8))) begin
            for (i=0; i<TCU_REG_BSEL_SIZE; i=i+1) begin
                if(tcu_log_reg_wben_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE]) begin
                    rin_log_select[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = tcu_log_reg_wdata_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE];
                end
            end
        end
    end


    mem_tp_wrap #(
        .MEM_TYPE     ("ultra"),
        .MEM_DATAWIDTH(TCU_LOG_MEM_DATAWIDTH),
        .MEM_ADDRWIDTH(TCU_LOG_MEM_ADDRWIDTH)
    ) i_tcu_log_mem (
        .clk    (clk_i),
        .reset  (~reset_n_i),

        .ena    (r_log_mem_en),
        .wea    ({((TCU_LOG_MEM_DATAWIDTH+7)/8){1'b1}}),
        .addra  (r_log_mem_addr[TCU_LOG_MEM_ADDRWIDTH-1:0]),    //upper bits of addr are used to count total number of logs
        .dina   (r_log_mem_wdata),

        .enb    (tcu_log_reg_en_i),
        .addrb  (log_mem_reg_addr),
        .doutb  (log_mem_reg_rdata)
    );


endmodule
