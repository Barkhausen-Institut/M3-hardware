

module ethernet_regfile #(
    `include  "noc_parameter.vh"
    ,`include "tcu_parameter.vh"
    ,`include "chip_ids.vh"
    ,parameter HOST_IP  = {8'd192, 8'd168, 8'd42, 8'd25},
    parameter HOST_PORT = 16'd1800,
    parameter FPGA_PORT = 16'd1800
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
    input  wire                          trigger_system_reset_i,
    output wire                          eth_system_reset_o,
    input  wire                   [15:0] eth_status_vector_i,
    output wire                   [31:0] eth_config_vector_o,
    input  wire                          eth_an_complete_i,
    input  wire                    [1:0] eth_pll_lock_i,
    input  wire                   [31:0] udp_status_i,
    input  wire                   [31:0] rx_udp_error_i,
    input  wire                   [31:0] mac_status_i,
    input  wire                   [31:0] fpga_ip_addr_i,
    output wire                   [15:0] fpga_port_o,
    input  wire                   [47:0] fpga_mac_addr_i,
    input  wire                          set_host_ip_i,
    input  wire                   [31:0] host_ip_addr_i,
    output wire                   [31:0] host_ip_addr_o,
    output wire                   [15:0] host_port_o,
    output wire    [NOC_CHIPID_SIZE-1:0] host_chipid_o
);

    integer i;

    //---------------
    //addr parameter
    localparam REG_ETH_SYSTEM_RESET  = 32'h00000000;
    localparam REG_ETH_STATUS_VECTOR = 32'h00000008;
    localparam REG_ETH_UDP_STATUS    = 32'h00000010;
    localparam REG_ETH_RX_UDP_ERROR  = 32'h00000018;
    localparam REG_ETH_MAC_STATUS    = 32'h00000020;
    localparam REG_ETH_FPGA_IP       = 32'h00000028;
    localparam REG_ETH_FPGA_PORT     = 32'h00000030;
    localparam REG_ETH_FPGA_MAC      = 32'h00000038;
    localparam REG_ETH_HOST_IP       = 32'h00000040;
    localparam REG_ETH_HOST_PORT     = 32'h00000048;
    localparam REG_ETH_HOST_CHIPID   = 32'h00000050;
    localparam REG_ETH_CONFIG_VECTOR = 32'h00000058;
    localparam REG_ETH_AN_COMPLETE   = 32'h00000060;
    localparam REG_ETH_PLL_LOCK      = 32'h00000068;

    localparam [4:0] PCSPMA_CONFIG_VECTOR = {
        1'b1, // autonegotiation enable
        1'b0, // isolate
        1'b0, // power down
        1'b0, // loopback enable
        1'b0  // unidirectional enable
    };

    localparam [15:0] PCSPMA_AN_CONFIG_VECTOR = {
        1'b1,    // SGMII link status
        1'b1,    // SGMII Acknowledge
        2'b01,   // full duplex
        2'b10,   // SGMII speed
        1'b0,    // reserved
        2'b00,   // pause frames - SGMII reserved
        1'b0,    // reserved
        1'b0,    // full duplex - SGMII reserved
        4'b0000, // reserved
        1'b1     // SGMII
    };


    //---------------
    //register
    reg                       r_eth_system_reset, rin_eth_system_reset;
    reg                [21:0] r_eth_config_vector, rin_eth_config_vector;
    reg                [15:0] r_eth_fpga_port, rin_eth_fpga_port;
    reg                [31:0] r_eth_host_ip, rin_eth_host_ip;
    reg                [15:0] r_eth_host_port, rin_eth_host_port;
    reg [NOC_CHIPID_SIZE-1:0] r_eth_host_chipid, rin_eth_host_chipid;

    reg [63:0] r_config_rdata, rin_config_rdata;


    wire reg_w_en = (config_en_i &&  (|config_wben_i));
    wire reg_r_en = (config_en_i && !(|config_wben_i));



    always @(posedge clk_i or negedge reset_n_i) begin
        if (reset_n_i == 1'b0) begin
            r_eth_system_reset <= 1'b0;
            r_eth_config_vector <= {1'b0, PCSPMA_CONFIG_VECTOR, PCSPMA_AN_CONFIG_VECTOR};
            r_eth_fpga_port <= FPGA_PORT;
            r_eth_host_ip <= HOST_IP;
            r_eth_host_port <= HOST_PORT;
            r_eth_host_chipid <= CHIPID_HOST;   //default is 0x3F

            r_config_rdata <= 64'h0;
        end
        else begin
            r_eth_system_reset <= rin_eth_system_reset;
            r_eth_config_vector <= rin_eth_config_vector;
            r_eth_fpga_port <= rin_eth_fpga_port;
            r_eth_host_ip <= rin_eth_host_ip;
            r_eth_host_port <= rin_eth_host_port;
            r_eth_host_chipid <= rin_eth_host_chipid;

            r_config_rdata <= rin_config_rdata;
        end
    end




    always @* begin
        rin_eth_system_reset = r_eth_system_reset || trigger_system_reset_i;
        rin_eth_config_vector = r_eth_config_vector;
        rin_eth_fpga_port = r_eth_fpga_port;
        rin_eth_host_ip = set_host_ip_i ? host_ip_addr_i : r_eth_host_ip;
        rin_eth_host_port = r_eth_host_port;
        rin_eth_host_chipid = r_eth_host_chipid;

        rin_config_rdata = r_config_rdata;


        //---------------
        //register write
        if (reg_w_en) begin
            case (config_addr_i)
                REG_ETH_SYSTEM_RESET: begin
                    if (config_wben_i == {TCU_REG_BSEL_SIZE{1'b1}}) begin
                        rin_eth_system_reset = 1'b1;
                    end
                end

                REG_ETH_FPGA_PORT: begin
                    for (i=0; i<2; i=i+1) begin
                        if (config_wben_i[i]) begin
                            rin_eth_fpga_port[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = config_wdata_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE];
                        end
                    end
                end

                REG_ETH_HOST_IP: begin
                    for (i=0; i<4; i=i+1) begin
                        if (config_wben_i[i]) begin
                            rin_eth_host_ip[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = config_wdata_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE];
                        end
                    end
                end

                REG_ETH_HOST_PORT: begin
                    for (i=0; i<2; i=i+1) begin
                        if (config_wben_i[i]) begin
                            rin_eth_host_port[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE] = config_wdata_i[i*TCU_REG_BSEL_SIZE +: TCU_REG_BSEL_SIZE];
                        end
                    end
                end

                REG_ETH_HOST_CHIPID: begin
                    if (config_wben_i[0]) begin
                        rin_eth_host_chipid = config_wdata_i[NOC_CHIPID_SIZE-1:0];
                    end
                end

                REG_ETH_CONFIG_VECTOR: begin
                    if (config_wben_i[0]) begin
                        rin_eth_config_vector[7:0] = config_wdata_i[7:0];
                    end
                    if (config_wben_i[1]) begin
                        rin_eth_config_vector[15:8] = config_wdata_i[15:8];
                    end
                    if (config_wben_i[2]) begin
                        rin_eth_config_vector[21:16] = config_wdata_i[21:16];
                    end
                end
            endcase
        end

        //---------------
        //register read
        else if (reg_r_en) begin
            case (config_addr_i)
                REG_ETH_STATUS_VECTOR: begin
                    rin_config_rdata = eth_status_vector_i;
                end

                REG_ETH_UDP_STATUS: begin
                    rin_config_rdata = udp_status_i;
                end

                REG_ETH_RX_UDP_ERROR: begin
                    rin_config_rdata = rx_udp_error_i;
                end

                REG_ETH_MAC_STATUS: begin
                    rin_config_rdata = mac_status_i;
                end

                REG_ETH_FPGA_IP: begin
                    rin_config_rdata = fpga_ip_addr_i;
                end

                REG_ETH_FPGA_PORT: begin
                    rin_config_rdata = r_eth_fpga_port;
                end

                REG_ETH_FPGA_MAC: begin
                    rin_config_rdata = fpga_mac_addr_i;
                end

                REG_ETH_HOST_IP: begin
                    rin_config_rdata = r_eth_host_ip;
                end

                REG_ETH_HOST_PORT: begin
                    rin_config_rdata = r_eth_host_port;
                end

                REG_ETH_HOST_CHIPID: begin
                    rin_config_rdata = r_eth_host_chipid;
                end

                REG_ETH_CONFIG_VECTOR: begin
                    rin_config_rdata = r_eth_config_vector;
                end

                REG_ETH_AN_COMPLETE: begin
                    rin_config_rdata = eth_an_complete_i;
                end

                REG_ETH_PLL_LOCK: begin
                    rin_config_rdata = eth_pll_lock_i;
                end

                default: begin
                    rin_config_rdata = 64'h0;
                end
            endcase
        end
    end



    assign config_rdata_o = r_config_rdata;

    assign eth_system_reset_o = r_eth_system_reset;
    assign eth_config_vector_o = {10'h0, r_eth_config_vector};
    assign fpga_port_o = r_eth_fpga_port;
    assign host_ip_addr_o = r_eth_host_ip;
    assign host_port_o = r_eth_host_port;
    assign host_chipid_o = r_eth_host_chipid;


endmodule
