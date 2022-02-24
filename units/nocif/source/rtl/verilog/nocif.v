
// synopsys translate_off
`timescale 1 ns / 1 ps
// synopsys translate_on

module nocif #(
    `include "noc_parameter.vh"
    ,parameter ENABLE_ARQ = 1
)
(
    input  wire                        clk_i,
    input  wire                        reset_q_i,

    // input from the NoC
    input  wire [NOC_HEADER_SIZE-1:0]  header_i,
    input  wire [NOC_PAYLOAD_SIZE-1:0] payload_i,
    output wire                        rdreq_o,
    input  wire                        flit_avail_q_i,

    // output to the NoC
    output wire [NOC_HEADER_SIZE-1:0]  header_o,
    output wire [NOC_PAYLOAD_SIZE-1:0] payload_o,
    output wire                        wrreq_o,
    input  wire                        stall_i,

    // interface to module
    output wire                         mod_wrreq_o,
    output wire [CHIP_X_COORD_SIZE-1:0] src_chip_x_coord_o,
    output wire [CHIP_Y_COORD_SIZE-1:0] src_chip_y_coord_o,
    output wire [CHIP_Z_COORD_SIZE-1:0] src_chip_z_coord_o,
    output wire [MOD_X_COORD_SIZE-1:0]  src_mod_x_coord_o,
    output wire [MOD_Y_COORD_SIZE-1:0]  src_mod_y_coord_o,
    output wire [MOD_Z_COORD_SIZE-1:0]  src_mod_z_coord_o,

    output wire [CHIP_X_COORD_SIZE-1:0] trg_chip_x_coord_o,
    output wire [CHIP_Y_COORD_SIZE-1:0] trg_chip_y_coord_o,
    output wire [CHIP_Z_COORD_SIZE-1:0] trg_chip_z_coord_o,
    output wire [MOD_X_COORD_SIZE-1:0]  trg_mod_x_coord_o,
    output wire [MOD_Y_COORD_SIZE-1:0]  trg_mod_y_coord_o,
    output wire [MOD_Z_COORD_SIZE-1:0]  trg_mod_z_coord_o,

    output wire                         mod_burst_o,
    output wire                         mod_arq_o,
    output wire [NOC_BSEL_SIZE-1:0]     mod_bsel_o,
    output wire [NOC_DATA_SIZE-1:0]     mod_data0_o,
    output wire [NOC_DATA_SIZE-1:0]     mod_data1_o,
    output wire [NOC_ADDR_SIZE-1:0]     mod_addr_o,
    output wire [NOC_MODE_SIZE-1:0]     mod_mode_o,
    input  wire                         mod_stall_i,

    // interface from module
    input wire                          mod_wrreq_i,
    input wire [CHIP_X_COORD_SIZE-1:0]  src_chip_x_coord_i,
    input wire [CHIP_Y_COORD_SIZE-1:0]  src_chip_y_coord_i,
    input wire [CHIP_Z_COORD_SIZE-1:0]  src_chip_z_coord_i,
    input wire [MOD_X_COORD_SIZE-1:0]   src_mod_x_coord_i,
    input wire [MOD_Y_COORD_SIZE-1:0]   src_mod_y_coord_i,
    input wire [MOD_Z_COORD_SIZE-1:0]   src_mod_z_coord_i,

    input wire [CHIP_X_COORD_SIZE-1:0]  trg_chip_x_coord_i,
    input wire [CHIP_Y_COORD_SIZE-1:0]  trg_chip_y_coord_i,
    input wire [CHIP_Z_COORD_SIZE-1:0]  trg_chip_z_coord_i,
    input wire [MOD_X_COORD_SIZE-1:0]   trg_mod_x_coord_i,
    input wire [MOD_Y_COORD_SIZE-1:0]   trg_mod_y_coord_i,
    input wire [MOD_Z_COORD_SIZE-1:0]   trg_mod_z_coord_i,

    input wire                          mod_burst_i,
    input wire                          mod_arq_i,
    input wire [NOC_BSEL_SIZE-1:0]      mod_bsel_i,
    input wire [NOC_DATA_SIZE-1:0]      mod_data0_i,
    input wire [NOC_DATA_SIZE-1:0]      mod_data1_i,
    input wire [NOC_ADDR_SIZE-1:0]      mod_addr_i,
    input wire [NOC_MODE_SIZE-1:0]      mod_mode_i,
    output wire                         mod_stall_o
);

    wire  [NOC_MODID_SIZE-1:0] noc_src_modID_out;
    wire [NOC_CHIPID_SIZE-1:0] noc_src_chipID_out;
    wire  [NOC_MODID_SIZE-1:0] noc_trg_modID_out;
    wire [NOC_CHIPID_SIZE-1:0] noc_trg_chipID_out;

    wire                       rx_stall_out;

    reg  [NOC_HEADER_SIZE-1:0] tx_header_arq_in;
    reg [NOC_PAYLOAD_SIZE-1:0] tx_payload_arq_in;

    wire  [NOC_HEADER_SIZE-1:0] rx_header_arq_out;
    wire [NOC_PAYLOAD_SIZE-1:0] rx_payload_arq_out;

    reg                        r_mod_burst, rin_mod_burst;

    reg                        r_noc_burst, rin_noc_burst;
    reg [NOC_MODE_SIZE-1:0]    r_mod_mode, rin_mod_mode;
    reg [NOC_ADDR_SIZE-1:0]    r_mod_addr, rin_mod_addr;


    assign rdreq_o = !flit_avail_q_i && !rx_stall_out;


    //burst is already active, flit structure will change
    always @(posedge clk_i or negedge reset_q_i) begin
        if(reset_q_i == 1'b0) begin
            r_mod_burst <= 1'b0;
        end else begin
            r_mod_burst <= rin_mod_burst;
        end
    end

    //burst from module
    always @* begin
        rin_mod_burst = r_mod_burst;
        if (mod_wrreq_i && !mod_stall_o) begin
             if (mod_burst_i) begin
                rin_mod_burst      = 1'b1;
            end else begin
                rin_mod_burst      = 1'b0;
            end
        end
    end

    //Header: burst(1)+arq+bsel+srcX+srcY+srcZ(mod)+srcX+srcY+srcZ(chip)+trgX+trgY+trgZ(mod)+trgX+trgY+trgZ(chip)
    //Payload: mode+address+data

    // combine signals out to NoC into Flit
    assign noc_src_modID_out  = {src_mod_x_coord_i,src_mod_y_coord_i,src_mod_z_coord_i};
    assign noc_src_chipID_out = {src_chip_x_coord_i,src_chip_y_coord_i,src_chip_z_coord_i};
    assign noc_trg_modID_out  = {trg_mod_x_coord_i,trg_mod_y_coord_i,trg_mod_z_coord_i};
    assign noc_trg_chipID_out = {trg_chip_x_coord_i,trg_chip_y_coord_i,trg_chip_z_coord_i};


    always@* begin
        //no burst active i.e. first flit of burst or non-burst flit
        if (r_mod_burst == 1'b0) begin
            tx_header_arq_in = {mod_burst_i, mod_arq_i, mod_bsel_i, noc_src_modID_out, noc_src_chipID_out, noc_trg_modID_out, noc_trg_chipID_out};
            tx_payload_arq_in = {mod_mode_i, mod_addr_i, mod_data0_i};
        end

        // burst continuation from last cycle
        else begin
            tx_header_arq_in = {mod_burst_i, mod_arq_i, mod_bsel_i, mod_data1_i[NOC_DATA_SIZE-1:NOC_DATA_SIZE-2*NOC_MODID_SIZE-2*NOC_CHIPID_SIZE]};
            tx_payload_arq_in = {mod_data1_i[NOC_DATA_SIZE-2*NOC_MODID_SIZE-2*NOC_CHIPID_SIZE-1:0], mod_data0_i};
        end
    end



    // split Flit into input signals to module
    assign mod_burst_o        = rx_header_arq_out[NOC_HEADER_SIZE-1];
    assign mod_arq_o          = rx_header_arq_out[NOC_HEADER_SIZE-NOC_BURST_SIZE-1 :
                                                    NOC_HEADER_SIZE-NOC_BURST_SIZE-NOC_ARQ_SIZE];
    assign mod_bsel_o         = rx_header_arq_out[NOC_HEADER_SIZE-NOC_BURST_SIZE-1 :
                                                    NOC_HEADER_SIZE-NOC_BURST_SIZE-NOC_ARQ_SIZE-NOC_BSEL_SIZE];
    assign src_mod_x_coord_o  = rx_header_arq_out[NOC_HEADER_SIZE-NOC_BURST_SIZE-NOC_ARQ_SIZE-NOC_BSEL_SIZE-1 :
                                                    NOC_HEADER_SIZE-NOC_BURST_SIZE-NOC_ARQ_SIZE-NOC_BSEL_SIZE-MOD_X_COORD_SIZE];
    assign src_mod_y_coord_o  = rx_header_arq_out[NOC_HEADER_SIZE-NOC_BURST_SIZE-NOC_ARQ_SIZE-NOC_BSEL_SIZE-MOD_X_COORD_SIZE-1 :
                                                    NOC_HEADER_SIZE-NOC_BURST_SIZE-NOC_ARQ_SIZE-NOC_BSEL_SIZE-MOD_X_COORD_SIZE-MOD_Y_COORD_SIZE];
    assign src_mod_z_coord_o  = rx_header_arq_out[NOC_HEADER_SIZE-NOC_BURST_SIZE-NOC_ARQ_SIZE-NOC_BSEL_SIZE-MOD_X_COORD_SIZE-MOD_Y_COORD_SIZE-1 :
                                                    NOC_HEADER_SIZE-NOC_BURST_SIZE-NOC_ARQ_SIZE-NOC_BSEL_SIZE-MOD_X_COORD_SIZE-MOD_Y_COORD_SIZE-MOD_Z_COORD_SIZE];
    assign src_chip_x_coord_o = rx_header_arq_out[NOC_HEADER_SIZE-NOC_BURST_SIZE-NOC_ARQ_SIZE-NOC_BSEL_SIZE-MOD_X_COORD_SIZE-MOD_Y_COORD_SIZE-MOD_Z_COORD_SIZE-1 :
                                                    NOC_HEADER_SIZE-NOC_BURST_SIZE-NOC_ARQ_SIZE-NOC_BSEL_SIZE-MOD_X_COORD_SIZE-MOD_Y_COORD_SIZE-MOD_Z_COORD_SIZE-CHIP_X_COORD_SIZE];
    assign src_chip_y_coord_o = rx_header_arq_out[NOC_HEADER_SIZE-NOC_BURST_SIZE-NOC_ARQ_SIZE-NOC_BSEL_SIZE-MOD_X_COORD_SIZE-MOD_Y_COORD_SIZE-MOD_Z_COORD_SIZE-CHIP_X_COORD_SIZE-1 :
                                                    NOC_HEADER_SIZE-NOC_BURST_SIZE-NOC_ARQ_SIZE-NOC_BSEL_SIZE-MOD_X_COORD_SIZE-MOD_Y_COORD_SIZE-MOD_Z_COORD_SIZE-CHIP_X_COORD_SIZE-CHIP_Y_COORD_SIZE];
    assign src_chip_z_coord_o = rx_header_arq_out[MOD_X_COORD_SIZE+MOD_Y_COORD_SIZE+MOD_Z_COORD_SIZE+CHIP_X_COORD_SIZE+CHIP_Y_COORD_SIZE+2*CHIP_Z_COORD_SIZE-1 :
                                                    MOD_X_COORD_SIZE+MOD_Y_COORD_SIZE+MOD_Z_COORD_SIZE+CHIP_X_COORD_SIZE+CHIP_Y_COORD_SIZE+CHIP_Z_COORD_SIZE];
    assign trg_mod_x_coord_o  = rx_header_arq_out[MOD_X_COORD_SIZE+MOD_Y_COORD_SIZE+MOD_Z_COORD_SIZE+CHIP_X_COORD_SIZE+CHIP_Y_COORD_SIZE+CHIP_Z_COORD_SIZE-1 :
                                                    MOD_Y_COORD_SIZE+MOD_Z_COORD_SIZE+CHIP_X_COORD_SIZE+CHIP_Y_COORD_SIZE+CHIP_Z_COORD_SIZE];
    assign trg_mod_y_coord_o  = rx_header_arq_out[MOD_Y_COORD_SIZE+MOD_Z_COORD_SIZE+CHIP_X_COORD_SIZE+CHIP_Y_COORD_SIZE+CHIP_Z_COORD_SIZE-1 :
                                                    MOD_Z_COORD_SIZE+CHIP_X_COORD_SIZE+CHIP_Y_COORD_SIZE+CHIP_Z_COORD_SIZE];
    assign trg_mod_z_coord_o  = rx_header_arq_out[MOD_Z_COORD_SIZE+CHIP_X_COORD_SIZE+CHIP_Y_COORD_SIZE+CHIP_Z_COORD_SIZE-1 :
                                                    CHIP_X_COORD_SIZE+CHIP_Y_COORD_SIZE+CHIP_Z_COORD_SIZE];
    assign trg_chip_x_coord_o = rx_header_arq_out[CHIP_X_COORD_SIZE+CHIP_Y_COORD_SIZE+CHIP_Z_COORD_SIZE-1 : CHIP_Y_COORD_SIZE+CHIP_Z_COORD_SIZE];
    assign trg_chip_y_coord_o = rx_header_arq_out[CHIP_Y_COORD_SIZE+CHIP_Z_COORD_SIZE-1 : CHIP_Z_COORD_SIZE];
    assign trg_chip_z_coord_o = rx_header_arq_out[CHIP_Z_COORD_SIZE-1 : 0];


    assign mod_data0_o = rx_payload_arq_out[NOC_DATA_SIZE-1:0];
    assign mod_data1_o = {rx_header_arq_out[NOC_HEADER_SIZE-NOC_BURST_SIZE-NOC_BSEL_SIZE-1:0], rx_payload_arq_out[NOC_PAYLOAD_SIZE-1:NOC_DATA_SIZE]};


    //burst from NoC
    always @(posedge clk_i, negedge reset_q_i) begin
        if(reset_q_i == 1'b0) begin
            r_mod_mode  <= {NOC_MODE_SIZE{1'b0}};
            r_mod_addr  <= {NOC_ADDR_SIZE{1'b0}};
            r_noc_burst <= 1'b0;
        end else begin
            r_mod_mode  <= rin_mod_mode;
            r_mod_addr  <= rin_mod_addr;
            r_noc_burst <= rin_noc_burst;
        end
    end

    always @* begin
        rin_noc_burst = r_noc_burst;
        if (mod_wrreq_o && !mod_stall_i) begin
            if (mod_burst_o) begin
                rin_noc_burst = 1'b1;
            end else begin
                rin_noc_burst = 1'b0;
            end
        end
    end

    always@* begin
        rin_mod_mode = r_mod_mode;
        rin_mod_addr = r_mod_addr;

        //only read from payload when first flit of burst or non-burst flit
        if (r_noc_burst == 1'b0) begin
            rin_mod_mode = rx_payload_arq_out[NOC_PAYLOAD_SIZE-1 : NOC_PAYLOAD_SIZE-NOC_MODE_SIZE];
            rin_mod_addr = rx_payload_arq_out[NOC_DATA_SIZE+NOC_ADDR_SIZE-1 : NOC_DATA_SIZE];
        end
    end

    assign mod_mode_o = rin_mod_mode;
    assign mod_addr_o = rin_mod_addr;


    generate
    if (ENABLE_ARQ) begin: ARQ

        noc_arq i_noc_arq (
            .clk_i            (clk_i),
            .reset_q_i        (reset_q_i),

            //from module to NoC
            .mod_tx_wrreq_i   (mod_wrreq_i),
            .mod_tx_header_i  (tx_header_arq_in),
            .mod_tx_payload_i (tx_payload_arq_in),
            .mod_tx_stall_o   (mod_stall_o),
            .noc_tx_wrreq_o   (wrreq_o),
            .noc_tx_header_o  (header_o),
            .noc_tx_payload_o (payload_o),
            .noc_tx_stall_i   (stall_i),

            //from NoC to module
            .noc_rx_wrreq_i   (!flit_avail_q_i),
            .noc_rx_header_i  (header_i),
            .noc_rx_payload_i (payload_i),
            .noc_rx_stall_o   (rx_stall_out),
            .mod_rx_wrreq_o   (mod_wrreq_o),
            .mod_rx_header_o  (rx_header_arq_out),
            .mod_rx_payload_o (rx_payload_arq_out),
            .mod_rx_stall_i   (mod_stall_i)
        );

    end
    else begin: NO_ARQ

        assign wrreq_o = mod_wrreq_i;
        assign header_o = tx_header_arq_in;
        assign payload_o = tx_payload_arq_in;
        assign mod_stall_o = stall_i;

        assign mod_wrreq_o = !flit_avail_q_i;
        assign rx_header_arq_out = header_i;
        assign rx_payload_arq_out = payload_i;
        assign rx_stall_out = mod_stall_i;

    end
    endgenerate

endmodule // nocif
