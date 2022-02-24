
module noc_arq_regfile #(
    `include "noc_parameter.vh"
)(
    input  wire                        clk_i,
    input  wire                        reset_q_i,

    //input
    input  wire                        wrreq_i,
    input  wire  [NOC_HEADER_SIZE-1:0] header_i,
    input  wire [NOC_PAYLOAD_SIZE-1:0] payload_i,
    output wire                        stall_o,

    //output
    output wire                        wrreq_o,
    output wire  [NOC_HEADER_SIZE-1:0] header_o,
    output wire [NOC_PAYLOAD_SIZE-1:0] payload_o,
    input  wire                        stall_i,

    //regfile values
    output wire                  [1:0] arq_enable_o,
    output wire                 [31:0] arq_timeout_rx_cycles_o,
    input  wire                 [31:0] noc_rx_count_i,
    input  wire                 [31:0] noc_rx_drop_i,
    input  wire                 [31:0] arq_tx_bvt_mod_wr_ptr_i,
    input  wire                 [31:0] arq_tx_bvt_ack_wr_ptr_i,
    input  wire                 [31:0] arq_tx_bvt_occ_ptr_i,
    input  wire                 [31:0] arq_tx_bvt_rd_ptr_i,
    input  wire                 [31:0] arq_rx_status_i
);

    integer i;


    //addr parameter
    localparam REGADDR_ARQ_ENABLE            = 32'h00000000;
    localparam REGADDR_ARQ_TIMEOUT_RX_CYCLES = 32'h00000008;
    localparam REGADDR_NOC_RX_COUNT          = 32'h00000010;
    localparam REGADDR_NOC_RX_DROP           = 32'h00000018;

    localparam REGADDR_ARQ_TX_BVT_MOD_WR_PTR = 32'h00000020;
    localparam REGADDR_ARQ_TX_BVT_ACK_WR_PTR = 32'h00000028;
    localparam REGADDR_ARQ_TX_BVT_OCC_PTR    = 32'h00000030;
    localparam REGADDR_ARQ_TX_BVT_RD_PTR     = 32'h00000038;

    localparam REGADDR_ARQ_RX_STATUS         = 32'h00000040;
    


    //0: ARQ off, ARQ bit in NoC packet is forced to 0
    //1: ARQ on, ARQ bit in NoC packet is forced to 1 (default)
    //2: ARQ follows ARQ bit in packet
    reg  [1:0] r_arq_enable, rin_arq_enable;

    //number of cycles for timeout in receiver
    //default: 10000 (0.1ms at 100MHz)
    reg [31:0] r_arq_timeout_rx_cycles, rin_arq_timeout_rx_cycles;

    //todo: add regs to read status of TX and RX buffers/signals


    reg  [NOC_MODID_SIZE-1:0] r_reg_src_modid;
    reg [NOC_CHIPID_SIZE-1:0] r_reg_src_chipid;
    reg  [NOC_MODID_SIZE-1:0] r_reg_trg_modid;
    reg [NOC_CHIPID_SIZE-1:0] r_reg_trg_chipid;
    reg   [NOC_ADDR_SIZE-1:0] r_reg_ret_addr;

    reg        r_reg_r_en, rin_reg_r_en;
    reg [63:0] r_reg_rdata, rin_reg_rdata;


    wire   [NOC_BSEL_SIZE-1:0] reg_bsel = header_i[NOC_BSEL_SIZE+2*NOC_MODID_SIZE+2*NOC_CHIPID_SIZE-1 : 2*NOC_MODID_SIZE+2*NOC_CHIPID_SIZE];
    wire  [NOC_MODID_SIZE-1:0] reg_src_modid = header_i[2*NOC_MODID_SIZE+2*NOC_CHIPID_SIZE-1 : NOC_MODID_SIZE+2*NOC_CHIPID_SIZE];
    wire [NOC_CHIPID_SIZE-1:0] reg_src_chipid = header_i[NOC_MODID_SIZE+2*NOC_CHIPID_SIZE-1 : NOC_MODID_SIZE+NOC_CHIPID_SIZE];
    wire  [NOC_MODID_SIZE-1:0] reg_trg_modid = header_i[NOC_MODID_SIZE+NOC_CHIPID_SIZE-1 : NOC_CHIPID_SIZE];
    wire [NOC_CHIPID_SIZE-1:0] reg_trg_chipid = header_i[NOC_CHIPID_SIZE-1 : 0];

    wire [NOC_MODE_SIZE-1:0] reg_mode = payload_i[NOC_MODE_SIZE+NOC_ADDR_SIZE+NOC_DATA_SIZE-1 : NOC_ADDR_SIZE+NOC_DATA_SIZE];
    wire [NOC_ADDR_SIZE-1:0] reg_addr = payload_i[NOC_ADDR_SIZE+NOC_DATA_SIZE-1 : NOC_DATA_SIZE];
    wire [NOC_DATA_SIZE-1:0] reg_data = payload_i[NOC_DATA_SIZE-1 : 0];

    wire reg_w_en = wrreq_i && (reg_mode == MODE_ARQ_WRITE_POSTED);
    wire reg_r_en = wrreq_i && (reg_mode == MODE_ARQ_READ_REQ);



    always @(posedge clk_i or negedge reset_q_i) begin
        if (reset_q_i == 1'b0) begin
            r_arq_enable <= NOC_ARQ_ENABLE_ON;
            r_arq_timeout_rx_cycles <= 32'd10000;

            r_reg_src_modid <= {NOC_MODID_SIZE{1'b0}};
            r_reg_src_chipid <= {NOC_CHIPID_SIZE{1'b0}};
            r_reg_trg_modid <= {NOC_MODID_SIZE{1'b0}};
            r_reg_trg_chipid <= {NOC_CHIPID_SIZE{1'b0}};
            r_reg_ret_addr <= {NOC_ADDR_SIZE{1'b0}};

            r_reg_r_en <= 1'b0;
            r_reg_rdata <= 64'h0;
        end
        else begin
            r_arq_enable <= rin_arq_enable;
            r_arq_timeout_rx_cycles <= rin_arq_timeout_rx_cycles;

            r_reg_src_modid <= (wrreq_i && !stall_o) ? reg_src_modid : r_reg_src_modid;
            r_reg_src_chipid <= (wrreq_i && !stall_o) ? reg_src_chipid : r_reg_src_chipid;
            r_reg_trg_modid <= (wrreq_i && !stall_o) ? reg_trg_modid : r_reg_trg_modid;
            r_reg_trg_chipid <= (wrreq_i && !stall_o) ? reg_trg_chipid : r_reg_trg_chipid;
            r_reg_ret_addr <= (wrreq_i && !stall_o) ? reg_data[NOC_ADDR_SIZE-1:0] : r_reg_ret_addr; //address of response

            r_reg_r_en <= rin_reg_r_en;
            r_reg_rdata <= rin_reg_rdata;
        end
    end


    always @* begin
        rin_arq_enable = r_arq_enable;
        rin_arq_timeout_rx_cycles = r_arq_timeout_rx_cycles;

        rin_reg_rdata = r_reg_rdata;


        //register write
        if (reg_w_en) begin
            case (reg_addr)
                REGADDR_ARQ_ENABLE: begin
                    if (reg_bsel[0]) rin_arq_enable = reg_data[1:0];
                end

                REGADDR_ARQ_TIMEOUT_RX_CYCLES: begin
                    for (i=0; i<4; i=i+1) begin
                        if (reg_bsel[i]) begin
                            rin_arq_timeout_rx_cycles[i*NOC_BSEL_SIZE +: NOC_BSEL_SIZE] = reg_data[i*NOC_BSEL_SIZE +: NOC_BSEL_SIZE];
                        end
                    end
                end

                //default:
            endcase
        end

        //register read
        else if (reg_r_en) begin
            case (reg_addr)
                REGADDR_ARQ_ENABLE: begin
                    rin_reg_rdata = r_arq_enable;
                end

                REGADDR_ARQ_TIMEOUT_RX_CYCLES: begin
                    rin_reg_rdata = r_arq_timeout_rx_cycles;
                end

                REGADDR_NOC_RX_COUNT: begin
                    rin_reg_rdata = noc_rx_count_i;
                end

                REGADDR_NOC_RX_DROP: begin
                    rin_reg_rdata = noc_rx_drop_i;
                end

                REGADDR_ARQ_TX_BVT_MOD_WR_PTR: begin
                    rin_reg_rdata = arq_tx_bvt_mod_wr_ptr_i;
                end

                REGADDR_ARQ_TX_BVT_ACK_WR_PTR: begin
                    rin_reg_rdata = arq_tx_bvt_ack_wr_ptr_i;
                end

                REGADDR_ARQ_TX_BVT_OCC_PTR: begin
                    rin_reg_rdata = arq_tx_bvt_occ_ptr_i;
                end

                REGADDR_ARQ_TX_BVT_RD_PTR: begin
                    rin_reg_rdata = arq_tx_bvt_rd_ptr_i;
                end

                REGADDR_ARQ_RX_STATUS: begin
                    rin_reg_rdata = arq_rx_status_i;
                end

                default: begin
                    rin_reg_rdata = 64'h0;
                end
            endcase
        end
    end


    //hold read enable as long as read data can be send
    always @* begin
        rin_reg_r_en = r_reg_r_en;

        if (reg_r_en) begin
            rin_reg_r_en = 1'b1;
        end

        if (r_reg_r_en && !stall_i) begin
            rin_reg_r_en = 1'b0;
        end
    end


    //send read reponse
    assign wrreq_o = r_reg_r_en;
    assign header_o = {1'b0,                    //burst
                        1'b0,                   //arq
                        {NOC_BSEL_SIZE{1'b1}},  //bsel
                        r_reg_trg_modid,        //swap src and trg because we send the response
                        r_reg_trg_chipid,
                        r_reg_src_modid,
                        r_reg_src_chipid};
    assign payload_o = {MODE_ARQ_READ_RSP, r_reg_ret_addr, r_reg_rdata};

    //as long as read is ongoing we cannot take the next packets
    assign stall_o = r_reg_r_en;


    assign arq_enable_o = r_arq_enable;
    assign arq_timeout_rx_cycles_o = r_arq_timeout_rx_cycles;


endmodule
