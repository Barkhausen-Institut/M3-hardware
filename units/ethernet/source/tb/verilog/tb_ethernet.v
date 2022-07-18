
`define FRAME_TYP [8*62+62+62+8*4+4+4+8*4+4+4+1:1]
`define FRAME_TYP_EXT [8*80+80+80+8*4+4+4+8*4+4+4+1:1]

parameter [47:0] HOST_MAC_ADDR = 48'h011b21_3A5046; //could be any addr, only for testbench
parameter [47:0] FPGA_MAC_ADDR = 48'h080028_030405;

parameter [31:0] HOST_IP = {8'd192, 8'd168, 8'd42, 8'd25};  //could be any addr, only for testbench
parameter [31:0] FPGA_IP = {8'd192, 8'd168, 8'd42, 8'd240};

parameter [15:0] HOST_PORT = 16'd1800;
parameter [15:0] FPGA_PORT = 16'd1800;

// The following parameter does not control the value the address filter is set to
// it is only used in the testbench
parameter [95:0] address_filter_value = {
    HOST_MAC_ADDR[ 7: 0],
    HOST_MAC_ADDR[15: 8],
    HOST_MAC_ADDR[23:16],
    HOST_MAC_ADDR[31:24],
    HOST_MAC_ADDR[39:32],
    HOST_MAC_ADDR[47:40],
    FPGA_MAC_ADDR[ 7: 0],
    FPGA_MAC_ADDR[15: 8],
    FPGA_MAC_ADDR[23:16],
    FPGA_MAC_ADDR[31:24],
    FPGA_MAC_ADDR[39:32],
    FPGA_MAC_ADDR[47:40]
};


reg  [9:0]  tenbit_data = 0;
reg  [9:0]  tenbit_data_rev = 0;

reg [7:0] tx_pdata;
reg tx_is_k;
reg stim_tx_clk_1000;
reg stim_tx_clk_100;
reg stim_tx_clk_10;
reg clock_enable;

reg  stim_tx_clk;
wire mon_tx_clk;

reg [7:0] rx_pdata;
reg rx_is_k;
reg rx_even;        // Keep track of the even/odd position
reg rx_rundisp_pos; // Indicates +ve running disparity
reg stim_rx_clk;    // Receiver clock (stimulus process).
reg  bitclock;      // clock running at Transceiver serial frequency

reg  management_config_finished;
reg  rx_stimulus_finished;

reg [1:0] mac_speed;

parameter UI = 800;
reg rxp, rxn;
wire txp;
wire speed_is_100;
wire speed_is_10_100;
wire [31:0] num_of_repeat;

integer arp_idx;

assign speed_is_100 = (mac_speed[0] == 1'b1 && mac_speed[1] == 1'b0) ? 1'b1 : 1'b0;
assign speed_is_10_100 = (mac_speed[1] == 1'b0) ? 1'b1 : 1'b0;

assign sgmii_rxp_dut = rxp;
assign sgmii_rxn_dut = rxn;

assign txp = sgmii_txp_dut;


initial                 // drives Rx stimulus clock at 125 MHz
begin
    stim_rx_clk <= 1'b0;
    forever
    begin
        stim_rx_clk <= 1'b0;
        #4000;
        stim_rx_clk <= 1'b1;
        #4000;
    end
end


initial                 // drives p_stim_tx_clk_1000 at 125 MHz
begin
    stim_tx_clk_1000 <= 1'b0;
    forever
    begin
        stim_tx_clk_1000 <= 1'b0;
        #4000;
        stim_tx_clk_1000 <= 1'b1;
        #4000;
    end
end

initial                 // drives stim_tx_clk_100 at 12.5 MHz
begin
    stim_tx_clk_100 <= 1'b0;
    forever
    begin
        stim_tx_clk_100 <= 1'b0;
        #40000;
        stim_tx_clk_100 <= 1'b1;
        #40000;
    end
end

initial                 // drives stim_tx_clk_10 at 12.5 MHz
begin
    stim_tx_clk_10 <= 1'b0;
    forever
    begin
        stim_tx_clk_10 <= 1'b0;
        #400000;
        stim_tx_clk_10 <= 1'b1;
        #400000;
    end
end
// Select between 10Mb/s, 100Mb/s and 1Gb/s Tx clock frequencies
always @ * begin
    if (speed_is_10_100 == 1'b0) begin
        stim_tx_clk <= stim_tx_clk_1000;
    end
    else begin
        if (speed_is_100) begin
        stim_tx_clk <= stim_tx_clk_100;
        end
        else begin
        stim_tx_clk <= stim_tx_clk_10;
        end
    end
end

initial                 // drives bitclock at 1.25GHz
begin
    bitclock <= 1'b0;
    forever
    begin
        bitclock <= 1'b0;
        #(UI/2);
        bitclock <= 1'b1;
        #(UI/2);
    end
end

// monitor clock
assign mon_tx_clk = stim_tx_clk_1000;


initial
begin : p_rx_init_stimulus

    // Initialise stimulus
    rx_rundisp_pos <= 0;      // Initialise running disparity
    rx_pdata       <= 8'hBC;  // /K28.5/
    rx_is_k        <= 1'b1;

    rx_stimulus_finished <= 0;
end

assign PHY1_MDIO = 1'bz;


//----------------------------------------------------------------------------
// types to support frame data
//----------------------------------------------------------------------------

axi_ethernet_xcvu9p_frame_typ rx_stimulus_working_frame();
axi_ethernet_xcvu9p_frame_typ_ext rx_stimulus_working_frame_ext();

axi_ethernet_xcvu9p_frame_typ frame_arp();
axi_ethernet_xcvu9p_frame_typ frame_noc();
axi_ethernet_xcvu9p_frame_typ_ext frame_noc_burst();

//----------------------------------------------------------------------------
// Stimulus - Frame data
//----------------------------------------------------------------------------
// The following constant holds the stimulus for the testbench. It is
// an ordered array of frames, with frame 0 the first to be injected
// into the core transmit interface by the testbench.
//----------------------------------------------------------------------------
initial
begin

    //-----------
    // Frame ARP, model broadcast from host
    //-----------
    frame_arp.data[0]  = 8'hFF; //dst MAC
    frame_arp.data[1]  = 8'hFF;
    frame_arp.data[2]  = 8'hFF;
    frame_arp.data[3]  = 8'hFF;
    frame_arp.data[4]  = 8'hFF;
    frame_arp.data[5]  = 8'hFF;
    frame_arp.data[6]  = HOST_MAC_ADDR[47:40]; //src MAC
    frame_arp.data[7]  = HOST_MAC_ADDR[39:32];
    frame_arp.data[8]  = HOST_MAC_ADDR[31:24];
    frame_arp.data[9]  = HOST_MAC_ADDR[23:16];
    frame_arp.data[10] = HOST_MAC_ADDR[15:8];
    frame_arp.data[11] = HOST_MAC_ADDR[7:0];
    frame_arp.data[12] = 8'h08; //protocol type: 0x0806 ARP, 0x0800 IPv4
    frame_arp.data[13] = 8'h06;
    frame_arp.data[14] = 8'h00; //HW address type (fixed)
    frame_arp.data[15] = 8'h01;
    frame_arp.data[16] = 8'h08; //protocol adress type (fixed)
    frame_arp.data[17] = 8'h00;
    frame_arp.data[18] = 8'h06; //HW size (fixed)
    frame_arp.data[19] = 8'h04; //protocol address size (fixed)
    frame_arp.data[20] = 8'h00; //ARP type: 1 ARP request, 2 ARP reply
    frame_arp.data[21] = 8'h01;
    frame_arp.data[22] = HOST_MAC_ADDR[47:40]; //src MAC
    frame_arp.data[23] = HOST_MAC_ADDR[39:32];
    frame_arp.data[24] = HOST_MAC_ADDR[31:24];
    frame_arp.data[25] = HOST_MAC_ADDR[23:16];
    frame_arp.data[26] = HOST_MAC_ADDR[15:8];
    frame_arp.data[27] = HOST_MAC_ADDR[7:0];
    frame_arp.data[28] = HOST_IP[31:24]; //src IP
    frame_arp.data[29] = HOST_IP[23:16];
    frame_arp.data[30] = HOST_IP[15:8];
    frame_arp.data[31] = HOST_IP[7:0];
    frame_arp.data[32] = 8'h00; //trg MAC (ignored for ARP request)
    frame_arp.data[33] = 8'h00;
    frame_arp.data[34] = 8'h00;
    frame_arp.data[35] = 8'h00;
    frame_arp.data[36] = 8'h00;
    frame_arp.data[37] = 8'h00;
    frame_arp.data[38] = FPGA_IP[31:24]; //trg IP
    frame_arp.data[39] = FPGA_IP[23:16];
    frame_arp.data[40] = FPGA_IP[15:8];
    frame_arp.data[41] = FPGA_IP[7:0];
    //actually unused
    frame_arp.data[42] = 8'h00;
    frame_arp.data[43] = 8'h00;
    frame_arp.data[44] = 8'h00;
    frame_arp.data[45] = 8'h00;
    frame_arp.data[46] = 8'h00;
    frame_arp.data[47] = 8'h00;
    frame_arp.data[48] = 8'h00;
    frame_arp.data[49] = 8'h00;
    frame_arp.data[50] = 8'h00;
    frame_arp.data[51] = 8'h00;
    frame_arp.data[52] = 8'h00;
    frame_arp.data[53] = 8'h00;
    frame_arp.data[54] = 8'h00;
    frame_arp.data[55] = 8'h00;
    frame_arp.data[56] = 8'h00;
    frame_arp.data[57] = 8'h00;
    frame_arp.data[58] = 8'h00;
    frame_arp.data[59] = 8'h00;
    frame_arp.data[60] = 8'h00;
    //unused
    frame_arp.data[61] = 8'h00;

    // No error in this frame
    frame_arp.bad_frame  = 1'b0;

    //frame type can hold 62 bytes, for NoC only 61 used
    for(arp_idx=0; arp_idx<61; arp_idx=arp_idx+1) begin
        frame_arp.valid[arp_idx] = 1'b1;
        frame_arp.error[arp_idx] = 1'b0;
    end

    for(arp_idx=61; arp_idx<62; arp_idx=arp_idx+1) begin
        frame_arp.valid[arp_idx] = 1'b0;
        frame_arp.error[arp_idx] = 1'b0;
    end

end


//----------------------------------------------------------------------------
// Simulate the MDIO -
// respond with sensible data to mdio reads and accept writes
//----------------------------------------------------------------------------
// expect mdio to try and read from reg addr 1 - return all 1's if we don't
// want any other mdio accesses
// if any other response then mdio will write to reg_addr 9 then 4 then 0
// (may check for expected write data?)
// finally mdio read from reg addr 1 until bit 5 is seen high
// NOTE - do not check any other bits so could drive all high again..
/*
reg [5:0] mdio_count;
reg       last_mdio;
reg       mdio_read;
reg       mdio_addr;
reg       mdio_fail;

reg [4:0] phy_addr = 5'd3;
reg [4:0] phy_addr_mdio = 0;
reg       mdio_addr_on_board = 1;
reg       mdio_addr_pcs_pma = 1;
reg       mdio_txn_found = 1'b0;
reg [4:0] pcs_pma_reg_addr = 1;

reg PHY1_MDIO_SYNC;
reg [15:0] mdio_rx_data;

// count through the mdio transfer
always @(posedge PHY1_MDC or negedge reset_l) begin
    if (!reset_l) begin
        mdio_count <= 0;
        last_mdio <= 1'b0;
    end
    else begin
        last_mdio <= PHY1_MDIO_SYNC;
        if (mdio_count >= 32) begin
            mdio_count <= 0;
        end
        else if (mdio_count != 0) begin
            mdio_count <= mdio_count + 1;
        end
        else begin // only get here if mdio state is 0 - now look for a start
            if ((PHY1_MDIO_SYNC === 1'b1) && (last_mdio === 1'b0)) begin
                mdio_count <= 1;
                mdio_txn_found <= 1'b1;
            end
        end
    end
end

always @(posedge PHY1_MDC or negedge reset_l) begin
    if (!reset_l) begin
        PHY1_MDIO_SYNC <= 0;
    end else begin
        PHY1_MDIO_SYNC <= PHY1_MDIO;
    end
end

//assign PHY1_MDIO = (mdio_read & (mdio_count >= 14) & (mdio_count <= 31)) ? 1'b0 : 1'bz;

// only respond to phy addr 7 and pcspma reg address
always @(posedge PHY1_MDC or negedge reset_l) begin
    if (!reset_l) begin
        mdio_read <= 1'b0;
        mdio_addr <= 1'b1; // this will go low if the address doesn't match required
        mdio_fail <= 1'b0;
    end
    else begin
        if (mdio_count == 2) begin
            mdio_addr <= 1'b1;    // new access so address needs to be revalidated
            mdio_addr_on_board <= 1'b1;
            mdio_addr_pcs_pma <= 1'b1;
            mdio_fail <= 1'b0;

            if ({last_mdio,PHY1_MDIO_SYNC} === 2'b10)
                mdio_read <= 1'b1;
            else // take a write as a default as won't drive at the wrong time
                mdio_read <= 1'b0;
        end
        else if (mdio_count <= 12) begin
            // check address is phy addr/reg addr are correct
            if (mdio_count <= 7 & mdio_count >= 5) begin
                if (PHY1_MDIO_SYNC !== 1'b1)
                    mdio_addr_on_board <= 1'b0;
            end
            if (mdio_count <= 7) begin
                phy_addr_mdio[7-mdio_count] <= PHY1_MDIO_SYNC;
            end else begin
                if(phy_addr_mdio != phy_addr) begin
                    mdio_addr_pcs_pma <= 1'b0;
                end
            end
            mdio_addr <= mdio_addr_on_board | mdio_addr_pcs_pma;
            if(mdio_addr==0) begin
                mdio_fail <= 1;
                $display("FAIL : ADDR phase is incorrect at %t ", $time);
            end
            if (mdio_count <= 12 & mdio_count >= 8) begin
                pcs_pma_reg_addr[12-mdio_count] <= PHY1_MDIO_SYNC;
            end
        end
        else if ((mdio_count == 14)) begin
            if (!mdio_read & (PHY1_MDIO_SYNC | !last_mdio)) begin
                $display("FAIL : Write TA phase is incorrect at %t ", $time);
            end
        end
        else if ((mdio_count >= 15) && (mdio_count <= 30)) begin
            mdio_rx_data[30-mdio_count] <= PHY1_MDIO_SYNC;
        end
        else if ((mdio_count >= 15) && (mdio_count <= 30) && mdio_addr && pcs_pma_reg_addr == 5'h00) begin
            if (!mdio_read) begin
                if (mdio_count == 20 && mdio_addr_pcs_pma) begin
                    if (PHY1_MDIO_SYNC) begin  // remove isolation
                        mdio_fail <= 1;
                        $display("FAIL : ISOLATION is not disabled at %t ", $time);
                    end
                end
                else if (mdio_count == 16) begin
                    if (PHY1_MDIO_SYNC && mdio_addr_on_board ) begin  // loopback not enabled
                        mdio_fail <= 1;
                        $display("FAIL : LOOP BACK is enabled for ON BOARD PHY in DEMO modeat %t ", $time);
                    end
                end
                else if (mdio_count == 18 && mdio_addr_pcs_pma) begin
                    if (PHY1_MDIO_SYNC) begin  // AN not disabled
                        mdio_fail <= 1;
                        $display("FAIL : AN not Disabled for pcspma at %t ", $time);
                    end
                end
                else if (mdio_count == 22) begin
                    if (!PHY1_MDIO_SYNC) begin  // Not in FULL Duplex
                        mdio_fail <= 1;
                        $display("FAIL : PHY Configured in HALF DUPLEX Mode at %t ", $time);
                    end
                end
            end
        end
    end
end
*/

//----------------------------------------------------------------------------
// Management process. This process waits for setup to complete by monitoring the mdio
// (the host always runs at gtx_clk so the setup after mdio accesses are complete
// doesn't take long) and then allows packets to be sent
//----------------------------------------------------------------------------
initial
begin : p_management

    mac_speed <= 2'b10;
    management_config_finished <= 0;

    #1000000;

    $display("Wait until ethernet link is up");

    while(eth_link_status == 1'b0)
        #1000;

    #1000000;

    management_config_finished <= 1;

end // p_management




//--------------------------------------------------------------------
// CRC engine
//--------------------------------------------------------------------
task calc_crc;
    input  [7:0]  data;
    inout  [31:0] fcs;

    reg [31:0] crc;
    reg        crc_feedback;
    integer    I;
begin

    crc = ~ fcs;

    for (I = 0; I < 8; I = I + 1)
    begin
        crc_feedback = crc[0] ^ data[I];

        crc[0]       = crc[1];
        crc[1]       = crc[2];
        crc[2]       = crc[3];
        crc[3]       = crc[4];
        crc[4]       = crc[5];
        crc[5]       = crc[6]  ^ crc_feedback;
        crc[6]       = crc[7];
        crc[7]       = crc[8];
        crc[8]       = crc[9]  ^ crc_feedback;
        crc[9]       = crc[10] ^ crc_feedback;
        crc[10]      = crc[11];
        crc[11]      = crc[12];
        crc[12]      = crc[13];
        crc[13]      = crc[14];
        crc[14]      = crc[15];
        crc[15]      = crc[16] ^ crc_feedback;
        crc[16]      = crc[17];
        crc[17]      = crc[18];
        crc[18]      = crc[19];
        crc[19]      = crc[20] ^ crc_feedback;
        crc[20]      = crc[21] ^ crc_feedback;
        crc[21]      = crc[22] ^ crc_feedback;
        crc[22]      = crc[23];
        crc[23]      = crc[24] ^ crc_feedback;
        crc[24]      = crc[25] ^ crc_feedback;
        crc[25]      = crc[26];
        crc[26]      = crc[27] ^ crc_feedback;
        crc[27]      = crc[28] ^ crc_feedback;
        crc[28]      = crc[29];
        crc[29]      = crc[30] ^ crc_feedback;
        crc[30]      = crc[31] ^ crc_feedback;
        crc[31]      =           crc_feedback;
    end

    // return the CRC result
    fcs = ~ crc;

end
endtask // calc_crc


//----------------------------------------------------------------------------
// Procedure to perform 8B10B decoding
//----------------------------------------------------------------------------

// Decode the 8B10B code. No disparity verification is performed, just
// a simple table lookup.
task decode_8b10b;
    input  [0:9] d10;
    output [7:0] q8;
    output       is_k;
    reg          k28;
    reg    [9:0] d10_rev;
    integer I;
begin
    // reverse the 10B codeword
    for (I = 0; I < 10; I = I + 1)
        d10_rev[I] = d10[I];
    case (d10_rev[5:0])
        6'b000110 : q8[4:0] = 5'b00000;   //D.0
        6'b111001 : q8[4:0] = 5'b00000;   //D.0
        6'b010001 : q8[4:0] = 5'b00001;   //D.1
        6'b101110 : q8[4:0] = 5'b00001;   //D.1
        6'b010010 : q8[4:0] = 5'b00010;   //D.2
        6'b101101 : q8[4:0] = 5'b00010;   //D.2
        6'b100011 : q8[4:0] = 5'b00011;   //D.3
        6'b010100 : q8[4:0] = 5'b00100;   //D.4
        6'b101011 : q8[4:0] = 5'b00100;   //D.4
        6'b100101 : q8[4:0] = 5'b00101;   //D.5
        6'b100110 : q8[4:0] = 5'b00110;   //D.6
        6'b000111 : q8[4:0] = 5'b00111;   //D.7
        6'b111000 : q8[4:0] = 5'b00111;   //D.7
        6'b011000 : q8[4:0] = 5'b01000;   //D.8
        6'b100111 : q8[4:0] = 5'b01000;   //D.8
        6'b101001 : q8[4:0] = 5'b01001;   //D.9
        6'b101010 : q8[4:0] = 5'b01010;   //D.10
        6'b001011 : q8[4:0] = 5'b01011;   //D.11
        6'b101100 : q8[4:0] = 5'b01100;   //D.12
        6'b001101 : q8[4:0] = 5'b01101;   //D.13
        6'b001110 : q8[4:0] = 5'b01110;   //D.14
        6'b000101 : q8[4:0] = 5'b01111;   //D.15
        6'b111010 : q8[4:0] = 5'b01111;   //D.15
        6'b110110 : q8[4:0] = 5'b10000;   //D.16
        6'b001001 : q8[4:0] = 5'b10000;   //D.16
        6'b110001 : q8[4:0] = 5'b10001;   //D.17
        6'b110010 : q8[4:0] = 5'b10010;   //D.18
        6'b010011 : q8[4:0] = 5'b10011;   //D.19
        6'b110100 : q8[4:0] = 5'b10100;   //D.20
        6'b010101 : q8[4:0] = 5'b10101;   //D.21
        6'b010110 : q8[4:0] = 5'b10110;   //D.22
        6'b010111 : q8[4:0] = 5'b10111;   //D/K.23
        6'b101000 : q8[4:0] = 5'b10111;   //D/K.23
        6'b001100 : q8[4:0] = 5'b11000;   //D.24
        6'b110011 : q8[4:0] = 5'b11000;   //D.24
        6'b011001 : q8[4:0] = 5'b11001;   //D.25
        6'b011010 : q8[4:0] = 5'b11010;   //D.26
        6'b011011 : q8[4:0] = 5'b11011;   //D/K.27
        6'b100100 : q8[4:0] = 5'b11011;   //D/K.27
        6'b011100 : q8[4:0] = 5'b11100;   //D.28
        6'b111100 : q8[4:0] = 5'b11100;   //K.28
        6'b000011 : q8[4:0] = 5'b11100;   //K.28
        6'b011101 : q8[4:0] = 5'b11101;   //D/K.29
        6'b100010 : q8[4:0] = 5'b11101;   //D/K.29
        6'b011110 : q8[4:0] = 5'b11110;   //D.30
        6'b100001 : q8[4:0] = 5'b11110;   //D.30
        6'b110101 : q8[4:0] = 5'b11111;   //D.31
        6'b001010 : q8[4:0] = 5'b11111;   //D.31
        default   : q8[4:0] = 5'b11110;    //CODE VIOLATION - return /E/
    endcase

    k28 = ~((d10[2] | d10[3] | d10[4] | d10[5] | ~(d10[8] ^ d10[9])));

    case (d10_rev[9:6])
        4'b0010 : q8[7:5] = 3'b000;       //D/K.x.0
        4'b1101 : q8[7:5] = 3'b000;       //D/K.x.0
        4'b1001 :
            if (!k28)
                q8[7:5] = 3'b001;             //D/K.x.1
            else
                q8[7:5] = 3'b110;             //K28.6
            4'b0110 :
                if (k28)
                    q8[7:5] = 3'b001;         //K.28.1
                else
                    q8[7:5] = 3'b110;         //D/K.x.6
                4'b1010 :
                    if (!k28)
                        q8[7:5] = 3'b010;         //D/K.x.2
                    else
                        q8[7:5] = 3'b101;         //K28.5
                    4'b0101 :
                        if (k28)
                            q8[7:5] = 3'b010;         //K28.2
                        else
                            q8[7:5] = 3'b101;         //D/K.x.5
                        4'b0011 : q8[7:5] = 3'b011;       //D/K.x.3
                        4'b1100 : q8[7:5] = 3'b011;       //D/K.x.3
                        4'b0100 : q8[7:5] = 3'b100;       //D/K.x.4
                        4'b1011 : q8[7:5] = 3'b100;       //D/K.x.4
                        4'b0111 : q8[7:5] = 3'b111;       //D.x.7
                        4'b1000 : q8[7:5] = 3'b111;       //D.x.7
                        4'b1110 : q8[7:5] = 3'b111;       //D/K.x.7
                        4'b0001 : q8[7:5] = 3'b111;       //D/K.x.7
                        default : q8[7:5] = 3'b111;   //CODE VIOLATION - return /E/
    endcase
    is_k = ((d10[2] & d10[3] & d10[4] & d10[5])
            | ~(d10[2] | d10[3] | d10[4] | d10[5])
            | ((d10[4] ^ d10[5]) & ((d10[5] & d10[7] & d10[8] & d10[9])
            | ~(d10[5] | d10[7] | d10[8] | d10[9]))));

end
endtask // decode_8b10b



//----------------------------------------------------------------------------
// Procedure to perform comma detection
//----------------------------------------------------------------------------

function is_comma;
    input [0:9] codegroup;
begin
    case (codegroup[0:6])
        7'b0011111 : is_comma = 1;
        7'b1100000 : is_comma = 1;
        default : is_comma = 0;
    endcase // case(codegroup[0:6])
end
endfunction // is_comma


//----------------------------------------------------------------------------
// Procedure to perform 8B10B encoding
//----------------------------------------------------------------------------

task encode_8b10b;
    input [7:0] d8;
    input is_k;
    output [0:9] q10;
    input disparity_pos_in;
    output disparity_pos_out;
    reg [5:0] b6;
    reg [3:0] b4;
    reg k28, pdes6, a7, l13, l31, a, b, c, d, e;
    integer I;

begin  // encode_8b10b
    // precalculate some common terms
    a = d8[0];
    b = d8[1];
    c = d8[2];
    d = d8[3];
    e = d8[4];

    k28 = is_k && d8[4:0] === 5'b11100;

    l13 = (((a ^ b) & !(c | d))
            | ((c ^ d) & !(a | b)));

    l31 = (((a ^ b) & (c & d))
            | ((c ^ d) & (a & b)));

    a7  = is_k | ((l31 & d & !e & disparity_pos_in)
                | (l13 & !d & e & !disparity_pos_in));

    // calculate the running disparity after the 5B6B block encode
    if (k28)                           //K.28
        if (!disparity_pos_in)
            b6 = 6'b111100;
        else
            b6 = 6'b000011;

    else
        case (d8[4:0])
            5'b00000 :                 //D.0
                if (disparity_pos_in)
                    b6 = 6'b000110;
                else
                    b6 = 6'b111001;
            5'b00001 :                 //D.1
                if (disparity_pos_in)
                    b6 = 6'b010001;
                else
                    b6 = 6'b101110;
            5'b00010 :                 //D.2
                if (disparity_pos_in)
                    b6 = 6'b010010;
                else
                    b6 = 6'b101101;
            5'b00011 :
                b6 = 6'b100011;              //D.3
            5'b00100 :                 //-D.4
                if (disparity_pos_in)
                    b6 = 6'b010100;
                else
                    b6 = 6'b101011;
            5'b00101 :
                b6 = 6'b100101;          //D.5
            5'b00110 :
                b6 = 6'b100110;          //D.6
            5'b00111 :                 //D.7
                if (!disparity_pos_in)
                    b6 = 6'b000111;
                else
                    b6 = 6'b111000;
            5'b01000 :                 //D.8
                if (disparity_pos_in)
                    b6 = 6'b011000;
                else
                    b6 = 6'b100111;
            5'b01001 :
                b6 = 6'b101001;          //D.9
            5'b01010 :
                b6 = 6'b101010;          //D.10
            5'b01011 :
                b6 = 6'b001011;          //D.11
            5'b01100 :
                b6 = 6'b101100;          //D.12
            5'b01101 :
                b6 = 6'b001101;          //D.13
            5'b01110 :
                b6 = 6'b001110;          //D.14
            5'b01111 :                 //D.15
                if (disparity_pos_in)
                    b6 = 6'b000101;
                else
                    b6 = 6'b111010;

            5'b10000 :                 //D.16
                if (!disparity_pos_in)
                    b6 = 6'b110110;
                else
                    b6 = 6'b001001;

            5'b10001 :
                b6 = 6'b110001;          //D.17
            5'b10010 :
                b6 = 6'b110010;          //D.18
            5'b10011 :
                b6 = 6'b010011;          //D.19
            5'b10100 :
                b6 = 6'b110100;          //D.20
            5'b10101 :
                b6 = 6'b010101;          //D.21
            5'b10110 :
                b6 = 6'b010110;          //D.22
            5'b10111 :                 //D/K.23
                if (!disparity_pos_in)
                    b6 = 6'b010111;
                else
                    b6 = 6'b101000;
            5'b11000 :                 //D.24
                if (disparity_pos_in)
                    b6 = 6'b001100;
                else
                    b6 = 6'b110011;
            5'b11001 :
                b6 = 6'b011001;          //D.25
            5'b11010 :
                b6 = 6'b011010;          //D.26
            5'b11011 :                 //D/K.27
                if (!disparity_pos_in)
                    b6 = 6'b011011;
                else
                    b6 = 6'b100100;
            5'b11100 :
                b6 = 6'b011100;          //D.28
            5'b11101 :                 //D/K.29
                if (!disparity_pos_in)
                    b6 = 6'b011101;
                else
                    b6 = 6'b100010;
            5'b11110 :                 //D/K.30
                if (!disparity_pos_in)
                    b6 = 6'b011110;
                else
                    b6 = 6'b100001;
            5'b11111 :                 //D.31
                if (!disparity_pos_in)
                    b6 = 6'b110101;
                else
                    b6 = 6'b001010;
            default :
                b6 = 6'bXXXXXX;
        endcase // case(d8[4:0])

    // reverse the bits
    for (I = 0; I < 6; I = I + 1)
        q10[I] = b6[I];


    // calculate the running disparity after the 5B6B block encode
    if (k28)
        pdes6 = !disparity_pos_in;
    else
        case (d8[4:0])
            5'b00000 : pdes6 = !disparity_pos_in;
            5'b00001 : pdes6 = !disparity_pos_in;
            5'b00010 : pdes6 = !disparity_pos_in;
            5'b00011 : pdes6 = disparity_pos_in;
            5'b00100 : pdes6 = !disparity_pos_in;
            5'b00101 : pdes6 = disparity_pos_in;
            5'b00110 : pdes6 = disparity_pos_in;
            5'b00111 : pdes6 = disparity_pos_in;
            5'b01000 : pdes6 = !disparity_pos_in;
            5'b01001 : pdes6 = disparity_pos_in;
            5'b01010 : pdes6 = disparity_pos_in;
            5'b01011 : pdes6 = disparity_pos_in;
            5'b01100 : pdes6 = disparity_pos_in;
            5'b01101 : pdes6 = disparity_pos_in;
            5'b01110 : pdes6 = disparity_pos_in;
            5'b01111 : pdes6 = !disparity_pos_in;
            5'b10000 : pdes6 = !disparity_pos_in;
            5'b10001 : pdes6 = disparity_pos_in;
            5'b10010 : pdes6 = disparity_pos_in;
            5'b10011 : pdes6 = disparity_pos_in;
            5'b10100 : pdes6 = disparity_pos_in;
            5'b10101 : pdes6 = disparity_pos_in;
            5'b10110 : pdes6 = disparity_pos_in;
            5'b10111 : pdes6 = !disparity_pos_in;
            5'b11000 : pdes6 = !disparity_pos_in;
            5'b11001 : pdes6 = disparity_pos_in;
            5'b11010 : pdes6 = disparity_pos_in;
            5'b11011 : pdes6 = !disparity_pos_in;
            5'b11100 : pdes6 = disparity_pos_in;
            5'b11101 : pdes6 = !disparity_pos_in;
            5'b11110 : pdes6 = !disparity_pos_in;
            5'b11111 : pdes6 = !disparity_pos_in;
            default  : pdes6 = disparity_pos_in;
        endcase // case(d8[4:0])

    case (d8[7:5])
        3'b000 :                     //D/K.x.0
            if (pdes6)
                b4 = 4'b0010;
            else
                b4 = 4'b1101;
        3'b001 :                     //D/K.x.1
            if (k28 && !pdes6)
            b4 = 4'b0110;
            else
            b4 = 4'b1001;
    3'b010 :                     //D/K.x.2
            if (k28 && !pdes6)
            b4 = 4'b0101;
            else
            b4 = 4'b1010;
    3'b011 :                     //D/K.x.3
            if (!pdes6)
            b4 = 4'b0011;
            else
            b4 = 4'b1100;
    3'b100 :                     //D/K.x.4
            if (pdes6)
            b4 = 4'b0100;
            else
            b4 = 4'b1011;
    3'b101 :                     //D/K.x.5
            if (k28 && !pdes6)
            b4 = 4'b1010;
            else
            b4 = 4'b0101;
    3'b110 :                     //D/K.x.6
            if (k28 && !pdes6)
            b4 = 4'b1001;
            else
            b4 = 4'b0110;
    3'b111 :                     //D.x.P7
            if (!a7)
            if (!pdes6)
    b4 = 4'b0111;
            else
    b4 = 4'b1000;
            else                   //D/K.y.A7
            if (!pdes6)
    b4 = 4'b1110;
            else
    b4 = 4'b0001;
    default :
            b4 = 4'bXXXX;
    endcase

    // Reverse the bits
    for (I = 0; I < 4; I = I + 1)
        q10[I+6] = b4[I];

    // Calculate the running disparity after the 4B group
    case (d8[7:5])
        3'b000  : disparity_pos_out = ~pdes6;
        3'b001  : disparity_pos_out = pdes6;
        3'b010  : disparity_pos_out = pdes6;
        3'b011  : disparity_pos_out = pdes6;
        3'b100  : disparity_pos_out = ~pdes6;
        3'b101  : disparity_pos_out = pdes6;
        3'b110  : disparity_pos_out = pdes6;
        3'b111  : disparity_pos_out = ~pdes6;
        default : disparity_pos_out = pdes6;
    endcase
end
endtask // encode_8b10b



// Set the expected data rate: sample the data on every clock at
// 1Gbps, every 10 clocks at 100Mbps, every 100 clocks at 10Mbps
integer sample_count;

initial
    sample_count = 0;

always @(posedge stim_rx_clk)
begin : gen_clock_enable
    if (speed_is_10_100 == 1'b0) begin
        sample_count  = 0;
        clock_enable <= 1'b1;                            // sample on every clock
    end
    else begin
        if ((speed_is_100 &&  sample_count == 9) ||      // sample every 10 clocks
            (!speed_is_100 &&  sample_count == 99)) begin // sample every 100 clocks
                sample_count  = 0;
                clock_enable <= 1'b1;
            end
            else begin
                if (sample_count == 99) begin
                    sample_count = 0;
                end
                else begin
                    sample_count = sample_count + 1;
                end
                clock_enable <= 1'b0;
            end
    end
end

// A task to create an Idle /I1/ code group
task send_I1;
    begin
        rx_pdata  <= 8'hBC;  // /K28.5/
        rx_is_k   <= 1'b1;
        @(posedge stim_rx_clk);
        rx_pdata  <= 8'hC5;  // /D5.6/
        rx_is_k   <= 1'b0;
        @(posedge stim_rx_clk);
    end
endtask // send_I1;

// A task to create an Idle /I2/ code group
task send_I2;
    begin
        rx_pdata  <= 8'hBC;  // /K28.5/
        rx_is_k   <= 1'b1;
        @(posedge stim_rx_clk);
        rx_pdata  <= 8'h50;  // /D16.2/
        rx_is_k   <= 1'b0;
        @(posedge stim_rx_clk);
    end
endtask // send_I2;

// A task to create a Start of Packet /S/ code group
task send_S;
    begin
        rx_pdata  <= 8'hFB;  // /K27.7/
        rx_is_k   <= 1'b1;
        @(posedge stim_rx_clk);
    end
endtask // send_S;

// A task to create a Start of Packet SFD code group
task send_SFD;
    begin
        rx_pdata  <= 8'hD5;  // /D21.6/
        rx_is_k   <= 1'b1;
        @(posedge stim_rx_clk);
    end
endtask // send_SFD;

// A task to send Preamble
task send_preamble;
    integer i;
begin
    for(i=0;i<7;i=i+1) begin
        rx_pdata  <= 8'h55;  // /D21.6/
        rx_is_k   <= 1'b1;
        @(posedge stim_rx_clk);
    end
end
endtask // send_preamble;

// A task to create a Terminate /T/ code group
task send_T;
    begin
        rx_pdata  <= 8'hFD;  // /K29.7/
        rx_is_k   <= 1'b1;
        @(posedge stim_rx_clk);
    end
endtask // send_T;

// A task to create a Carrier Extend /R/ code group
task send_R;
    begin
        rx_pdata  <= 8'hF7;  // /K23.7/
        rx_is_k   <= 1'b1;
        @(posedge stim_rx_clk);
    end
endtask // send_R;

// A task to create an Error Propogation /V/ code group
task send_V;
    begin
        rx_pdata  <= 8'hFE;  // /K30.7/
        rx_is_k   <= 1'b1;
        @(posedge stim_rx_clk);
    end
endtask // send_V;


task send_frame;
    input   `FRAME_TYP frame;
    integer column_index;
    integer I;
    reg [31:0] fcs;

begin
    // import the frame into scratch space
    rx_stimulus_working_frame.frombits(frame);
    fcs = 32'h0;

    //----------------------------------
    // Send a Start of Packet code group
    //----------------------------------
    send_S;

    //----------------------------------
    // Send Preamble
    //----------------------------------
    repeat(num_of_repeat)
        send_preamble;

    //----------------------------------
    // Send a SFD
    //----------------------------------
    repeat(num_of_repeat)
        send_SFD;

    //----------------------------------
    // Send frame data
    //----------------------------------
    column_index = 0;

    // loop over columns in frame
    while (rx_stimulus_working_frame.valid[column_index] != 1'b0) begin
        if (rx_stimulus_working_frame.error[column_index] == 1'b1) begin
            repeat(num_of_repeat)
                send_V; // insert an error propogation code group
        end
        else
        begin
            repeat(num_of_repeat) begin
                rx_pdata <= rx_stimulus_working_frame.data[column_index];
                rx_is_k  <= 1'b0;
                @(posedge stim_rx_clk);
            end
            calc_crc(rx_stimulus_working_frame.data[column_index],fcs);
        end
        column_index = column_index + 1;
    end // while

    //send CRC
    for(I=1;I<=4;I=I+1) begin
        repeat(num_of_repeat) begin
            rx_pdata <= fcs[((I*8)-1)-:8];
            rx_is_k  <= 1'b0;
            @(posedge stim_rx_clk);
        end
    end

    //----------------------------------
    // Send a frame termination sequence
    //----------------------------------
    send_T;    // Terminate code group
    send_R;    // Carrier Extend code group

    // An extra Carrier Extend code group should be sent to end the frame
    // on an even boundary.
    if (rx_even == 1'b1)
        send_R;  // Carrier Extend code group

    //----------------------------------
    // Send an Inter Packet Gap.
    //----------------------------------
    // The initial Idle following a frame should be chosen to ensure
    // that the running disparity is returned to -ve.
    if (rx_rundisp_pos == 1'b1)
        send_I1;  // /I1/ will flip the running disparity
    else
        send_I2;  // /I2/ will maintain the running disparity

    // The remainder of the IPG is made up of /I2/ 's.
    // NOTE: the number 4 in the following calculations is made up
    //      from 2 bytes of the termination sequence and 2 bytes from
    //      the initial Idle.

    // 1Gb/s: 4 /I2/'s = 8 clock periods (12 - 4)
    if (!speed_is_10_100) begin
        for (I = 0; I < 4; I = I + 1)
            send_I2;
    end

    else begin
    // 100Mb/s: 58 /I2/'s = 116 clock periods (120 - 4)
        if (speed_is_100) begin
            for (I = 0; I < 58; I = I + 1)
                send_I2;
        end

    // 10Mb/s: 598 /I2/'s = 1196 clock periods (1200 - 4)
        else begin
            for (I = 0; I < 598; I = I + 1)
                send_I2;
        end
    end

end
endtask // send_frame;



task send_frame_ext;
    input   `FRAME_TYP_EXT frame;
    integer column_index;
    integer I;
    reg [31:0] fcs;

begin
    // import the frame into scratch space
    rx_stimulus_working_frame_ext.frombits(frame);
    fcs = 32'h0;

    //----------------------------------
    // Send a Start of Packet code group
    //----------------------------------
    send_S;

    //----------------------------------
    // Send Preamble
    //----------------------------------
    repeat(num_of_repeat)
        send_preamble;

    //----------------------------------
    // Send a SFD
    //----------------------------------
    repeat(num_of_repeat)
        send_SFD;

    //----------------------------------
    // Send frame data
    //----------------------------------
    column_index = 0;

    // loop over columns in frame
    while (rx_stimulus_working_frame_ext.valid[column_index] != 1'b0) begin
        if (rx_stimulus_working_frame_ext.error[column_index] == 1'b1) begin
            repeat(num_of_repeat)
                send_V; // insert an error propogation code group
        end
        else
        begin
            repeat(num_of_repeat) begin
                rx_pdata <= rx_stimulus_working_frame_ext.data[column_index];
                rx_is_k  <= 1'b0;
                @(posedge stim_rx_clk);
            end
            calc_crc(rx_stimulus_working_frame_ext.data[column_index],fcs);
        end
        column_index = column_index + 1;
    end // while

    //send CRC
    for(I=1;I<=4;I=I+1) begin
        repeat(num_of_repeat) begin
            rx_pdata <= fcs[((I*8)-1)-:8];
            rx_is_k  <= 1'b0;
            @(posedge stim_rx_clk);
        end
    end

    //----------------------------------
    // Send a frame termination sequence
    //----------------------------------
    send_T;    // Terminate code group
    send_R;    // Carrier Extend code group

    // An extra Carrier Extend code group should be sent to end the frame
    // on an even boundary.
    if (rx_even == 1'b1)
        send_R;  // Carrier Extend code group

    //----------------------------------
    // Send an Inter Packet Gap.
    //----------------------------------
    // The initial Idle following a frame should be chosen to ensure
    // that the running disparity is returned to -ve.
    if (rx_rundisp_pos == 1'b1)
        send_I1;  // /I1/ will flip the running disparity
    else
        send_I2;  // /I2/ will maintain the running disparity

    // The remainder of the IPG is made up of /I2/ 's.
    // NOTE: the number 4 in the following calculations is made up
    //      from 2 bytes of the termination sequence and 2 bytes from
    //      the initial Idle.

    // 1Gb/s: 4 /I2/'s = 8 clock periods (12 - 4)
    if (!speed_is_10_100) begin
        for (I = 0; I < 4; I = I + 1)
            send_I2;
    end

    else begin
    // 100Mb/s: 58 /I2/'s = 116 clock periods (120 - 4)
        if (speed_is_100) begin
            for (I = 0; I < 58; I = I + 1)
                send_I2;
        end

    // 10Mb/s: 598 /I2/'s = 1196 clock periods (1200 - 4)
        else begin
            for (I = 0; I < 598; I = I + 1)
                send_I2;
        end
    end

end
endtask // send_frame_ext;




// A task to serialise a single 10-bit code group
task rx_stimulus_send_10b_column;
    input [0:9] d;
    integer I;
begin
    for (I = 0; I < 10; I = I + 1)
    begin
        @(posedge bitclock)
        rxp <= d[I];
        rxn <= ~d[I];
    end // I
end
endtask // rx_stimulus_send_10b_column



task calc_ip_checksum;
    input [7:0] data [0:19];
    output [15:0] checksum;

    integer i;
    reg [19:0] tmp_cs;
begin
    tmp_cs = 20'h0;
    for (i=0; i<20; i=i+2) begin
        tmp_cs = tmp_cs + {data[i], data[i+1]};
    end

    tmp_cs = tmp_cs[15:0] + tmp_cs[19:16];  //add carry
    tmp_cs = tmp_cs[15:0] + tmp_cs[19:16];  //add carry if there is a new one
    checksum = ~tmp_cs[15:0];   //one's complement
end
endtask //calc_ip_checksum


// task to send a single NoC WRITE packet via ethernet
task write8b_noc;
    input [NOC_MODID_SIZE-1:0] trg_modid;
    input [NOC_BSEL_SIZE-1:0] bsel;
    input [NOC_ADDR_SIZE-1:0] addr;
    input [NOC_DATA_SIZE-1:0] data;
begin
    send_noc({NOC_CHIPID_SIZE{1'b0}}, trg_modid, MODE_WRITE_POSTED, bsel, 1'b0, addr, data);
end
endtask //write8b_noc


// task to send a single NoC WRITE packet via ethernet with given chipid
task write8b_noc_chip;
    input [NOC_CHIPID_SIZE-1:0] trg_chipid;
    input [NOC_MODID_SIZE-1:0] trg_modid;
    input [NOC_BSEL_SIZE-1:0] bsel;
    input [NOC_ADDR_SIZE-1:0] addr;
    input [NOC_DATA_SIZE-1:0] data;
begin
    send_noc(trg_chipid, trg_modid, MODE_WRITE_POSTED, bsel, 1'b0, addr, data);
end
endtask //write8b_noc_chip


// task to send a single NoC WRITE packet via ethernet with ARQ enabled
task write8b_arq_noc;
    input [NOC_MODID_SIZE-1:0] trg_modid;
    input [NOC_BSEL_SIZE-1:0] bsel;
    input [NOC_ADDR_SIZE-1:0] addr;
    input [NOC_DATA_SIZE-1:0] data;
begin
    send_noc({NOC_CHIPID_SIZE{1'b0}}, trg_modid, MODE_WRITE_POSTED, bsel, 1'b1, addr, data);
end
endtask //write8b_noc


// task to read 8 bytes via ethernet
task read8b_noc;
    input [NOC_MODID_SIZE-1:0] trg_modid;
    input [NOC_ADDR_SIZE-1:0] trg_addr;
begin
    read_noc({NOC_CHIPID_SIZE{1'b0}}, trg_modid, trg_addr, 32'd8, 0);
end
endtask //read8b_noc


// task to read 8 bytes via ethernet with given chipid
task read8b_noc_chip;
    input [NOC_CHIPID_SIZE-1:0] trg_chipid;
    input [NOC_MODID_SIZE-1:0] trg_modid;
    input [NOC_ADDR_SIZE-1:0] trg_addr;
begin
    read_noc(trg_chipid, trg_modid, trg_addr, 32'd8, 0);
end
endtask //read8b_noc_chip


// task to send a NoC READ request packet via ethernet
task read_noc;
    input [NOC_CHIPID_SIZE-1:0] trg_chipid;
    input [NOC_MODID_SIZE-1:0] trg_modid;
    input [NOC_ADDR_SIZE-1:0] trg_addr;
    input [31:0] size; //in bytes
    input [NOC_ADDR_SIZE-1:0] src_addr;
begin
    send_noc(trg_chipid, trg_modid, MODE_READ_REQ, {NOC_BSEL_SIZE{1'b1}}, 1'b0, trg_addr, (size<<32) | src_addr);
end
endtask //read_noc


// task to send a single NoC packet via ethernet
task send_noc;
    input [NOC_CHIPID_SIZE-1:0] trg_chipid;
    input [NOC_MODID_SIZE-1:0] trg_modid;
    input [NOC_MODE_SIZE-1:0] mode;
    input [NOC_BSEL_SIZE-1:0] bsel;
    input [NOC_ARQ_SIZE-1:0] arq;
    input [NOC_ADDR_SIZE-1:0] addr;
    input [NOC_DATA_SIZE-1:0] data;
    integer i;

    reg [NOC_MODID_SIZE-1:0] src_modid;
    reg [NOC_CHIPID_SIZE-1:0] src_chipid;
    reg [NOC_BURST_SIZE-1:0] burst;

    reg [15:0] ip_checksum;
begin

    src_modid = MODID_ETH;
    src_chipid = CHIPID_HOST;
    burst = 0;

    ip_checksum = 16'h0;

    //Ethernet header
    frame_noc.data[0]  = FPGA_MAC_ADDR[47:40]; // Destination Address (DA)
    frame_noc.data[1]  = FPGA_MAC_ADDR[39:32];
    frame_noc.data[2]  = FPGA_MAC_ADDR[31:24];
    frame_noc.data[3]  = FPGA_MAC_ADDR[23:16];
    frame_noc.data[4]  = FPGA_MAC_ADDR[15: 8];
    frame_noc.data[5]  = FPGA_MAC_ADDR[ 7: 0];
    frame_noc.data[6]  = HOST_MAC_ADDR[47:40]; // Source Address  (5A)
    frame_noc.data[7]  = HOST_MAC_ADDR[39:32];
    frame_noc.data[8]  = HOST_MAC_ADDR[31:24];
    frame_noc.data[9]  = HOST_MAC_ADDR[23:16];
    frame_noc.data[10] = HOST_MAC_ADDR[15: 8];
    frame_noc.data[11] = HOST_MAC_ADDR[ 7: 0];
    frame_noc.data[12] = 8'h08; //protocol type: 0x0806 ARP, 0x0800 IPv4
    frame_noc.data[13] = 8'h00;

    //IP header (20 byte)
    frame_noc.data[14] = 8'h45; //version | header length (32-bit words)
    frame_noc.data[15] = 8'h00; //service type
    frame_noc.data[16] = 8'h00; //total length, incl. header (bytes) - here: 46
    frame_noc.data[17] = 8'h2E;
    frame_noc.data[18] = 8'h4B; //id
    frame_noc.data[19] = 8'h12;
    frame_noc.data[20] = 8'h40; //flags, fragment offset
    frame_noc.data[21] = 8'h00;
    frame_noc.data[22] = 8'h40; //time to live
    frame_noc.data[23] = 8'h11; //protocol
    frame_noc.data[24] = 8'h00; //header checksum (will be calculated below)
    frame_noc.data[25] = 8'h00;
    frame_noc.data[26] = HOST_IP[31:24]; //source IP
    frame_noc.data[27] = HOST_IP[23:16];
    frame_noc.data[28] = HOST_IP[15: 8];
    frame_noc.data[29] = HOST_IP[ 7: 0];
    frame_noc.data[30] = FPGA_IP[31:24]; //dest IP
    frame_noc.data[31] = FPGA_IP[23:16];
    frame_noc.data[32] = FPGA_IP[15: 8];
    frame_noc.data[33] = FPGA_IP[ 7: 0];

    calc_ip_checksum(frame_noc.data[14:33], ip_checksum);
    frame_noc.data[24] = ip_checksum[15:8]; //header checksum
    frame_noc.data[25] = ip_checksum[7:0];

    //UDP header (8 byte)
    frame_noc.data[34] = HOST_PORT[15:8]; //src port
    frame_noc.data[35] = HOST_PORT[ 7:0];
    frame_noc.data[36] = FPGA_PORT[15:8]; //dest port
    frame_noc.data[37] = FPGA_PORT[ 7:0];
    frame_noc.data[38] = 8'h00; //length header+data (bytes) - here: 26
    frame_noc.data[39] = 8'h1A;
    frame_noc.data[40] = 8'h00; //checksum (unused)
    frame_noc.data[41] = 8'h00;

    //payload (here 18 byte)
    frame_noc.data[42] = {6'h0, burst, arq}; //data (NoC packet)
    frame_noc.data[43] = bsel;
    frame_noc.data[44] = src_modid;
    frame_noc.data[45] = {src_chipid, trg_modid[7:6]};
    frame_noc.data[46] = {trg_modid[5:0], trg_chipid[5:4]};
    frame_noc.data[47] = {trg_chipid[3:0], mode};
    frame_noc.data[48] = addr[31:24];
    frame_noc.data[49] = addr[23:16];
    frame_noc.data[50] = addr[15: 8];
    frame_noc.data[51] = addr[ 7: 0];
    frame_noc.data[52] = data[63:56];
    frame_noc.data[53] = data[55:48];
    frame_noc.data[54] = data[47:40];
    frame_noc.data[55] = data[39:32];
    frame_noc.data[56] = data[31:24];
    frame_noc.data[57] = data[23:16];
    frame_noc.data[58] = data[15: 8];
    frame_noc.data[59] = data[ 7: 0];

    // No error in this frame
    frame_noc.bad_frame = 1'b0;

    //frame type can hold 62 bytes, for NoC only 60 used
    for(i=0; i<60; i=i+1) begin
        frame_noc.valid[i] = 1'b1;
        frame_noc.error[i] = 1'b0;
    end

    for(i=60; i<62; i=i+1) begin
        frame_noc.valid[i] = 1'b0;
        frame_noc.error[i] = 1'b0;
    end

    send_frame(frame_noc.tobits(0));

end
endtask //send_noc


//----------------------------------------------------------------------------
// A process to keep track of the even/odd code group position for the
// injected receiver code groups.
//----------------------------------------------------------------------------
initial
begin : p_rx_even_odd
    rx_even <= 1'b0;
    forever
        begin
            @(posedge stim_rx_clk)
            rx_even <= ! rx_even;
        end
end // p_rx_even_odd


// 8B10B encode the Rx stimulus
initial
begin : p_rx_encode
    reg [0:9] encoded_data;

    // Get synced up with the Rx clock
    @(posedge stim_rx_clk)

    // Perform 8B10B encoding of the data stream
    forever
        begin
            encode_8b10b(
                rx_pdata,
                rx_is_k,
                encoded_data,
                rx_rundisp_pos,
            rx_rundisp_pos);

            rx_stimulus_send_10b_column(encoded_data);
        end // forever
end // p_rx_encode

initial
begin : p_tx_decode

    reg [0:9] code_buffer;
    reg [7:0] decoded_data;
    integer bit_count;
    reg is_k_var;
    reg initial_sync;

    bit_count = 0;
    initial_sync = 0;

    forever
begin
    @(negedge bitclock);
    code_buffer = {code_buffer[1:9], txp};
    // comma detection
    if (is_comma(code_buffer))
    begin
        bit_count = 0;
        initial_sync = 1;
    end

    if (bit_count == 0 && initial_sync)
    begin
    // Perform 8B10B decoding of the data stream
        tenbit_data = code_buffer;
        decode_8b10b(code_buffer,
        decoded_data,
    is_k_var);

    // drive the output signals with the results
    tx_pdata <= decoded_data;

    if (is_k_var)
        tx_is_k <= 1'b1;
    else
        tx_is_k <= 1'b0;
    end

    if (initial_sync)
    begin
        bit_count = bit_count + 1;
        if (bit_count == 10)
            bit_count = 0;
    end

end // forever
end // p_tx_decode



assign num_of_repeat = (mac_speed == 2'b10 ? 1 :
                        mac_speed == 2'b01 ? 10 :
                        (mac_speed == 2'b00 ? 100:1));


task check_frame;
    //input integer frame_size;   //in bytes
    input last_was_burst;
    output last_is_burst;

    integer frame_size;
    integer min_frame_size;
    integer column_index;
    integer I;
    reg [31:0] fcs;

    reg [NOC_MODE_SIZE-1:0] mode;
    reg [NOC_ADDR_SIZE-1:0] addr;
    reg [NOC_DATA_SIZE-1:0] data, b_data0, b_data1;
    reg [NOC_MODID_SIZE-1:0] trg_modid;
    reg [NOC_MODID_SIZE-1:0] src_modid;
    reg [NOC_CHIPID_SIZE-1:0] src_chipid;
    reg [NOC_CHIPID_SIZE-1:0] trg_chipid;
    reg [NOC_BURST_SIZE-1:0] burst;
    reg [NOC_ARQ_SIZE-1:0] arq;
    reg [NOC_BSEL_SIZE-1:0] bsel;

    reg [47:0] src_mac;
    reg [47:0] dst_mac;
    reg [31:0] src_IP;
    reg [31:0] dst_IP;
    reg [15:0] src_port;
    reg [15:0] dst_port;
    reg [15:0] protocol;
    reg [15:0] udp_length;
    reg [15:0] checksum;

begin
    $timeformat(-9, 0, "ns", 7);
    column_index = 0;
    min_frame_size = 60;
    frame_size = 60;
    fcs = 32'h0;

    mode = 0;
    addr = 0;
    data = 0;
    trg_modid = 0;
    src_modid = 0;
    src_chipid = 0;
    trg_chipid = 0;
    burst = 0;
    arq = 0;
    bsel = 0;

    src_mac = 0;
    dst_mac = 0;
    src_IP = 0;
    dst_IP = 0;
    src_port = 0;
    dst_port = 0;
    protocol = 0;
    checksum = 0;



    // Detect the Start of Frame
    while (tx_pdata !== 8'hFB) begin
        @(posedge mon_tx_clk);
        #1;
    end

    // Move past the Start of Frame code to the 1st byte of preamble
    repeat (num_of_repeat) begin
        @(posedge mon_tx_clk);
        #1;
    end
    // tx_pdata should now hold the SFD.  We need to move to the SFD of the injected frame.
    while(tx_pdata !== 8'hD5) begin
        repeat (num_of_repeat) begin
            @(posedge mon_tx_clk);
            #1;
        end
    end

    // Start reading the received frame
    repeat (num_of_repeat) begin
        @(posedge mon_tx_clk);
        #1;
    end



    // frame has started, loop over columns of frame until the frame termination is detected
    while (column_index < min_frame_size) begin
        calc_crc(tx_pdata,fcs);
        //$display("%d: %h", column_index, tx_pdata);

        //read dst MAC
        if (column_index < 6) begin
            case(column_index)
                0: dst_mac[47:40] = tx_pdata;
                1: dst_mac[39:32] = tx_pdata;
                2: dst_mac[31:24] = tx_pdata;
                3: dst_mac[23:16] = tx_pdata;
                4: dst_mac[15: 8] = tx_pdata;
                5: dst_mac[ 7: 0] = tx_pdata;
            endcase
        end

        //read src MAC
        else if (column_index < 12) begin
            case(column_index-6)
                0: src_mac[47:40] = tx_pdata;
                1: src_mac[39:32] = tx_pdata;
                2: src_mac[31:24] = tx_pdata;
                3: src_mac[23:16] = tx_pdata;
                4: src_mac[15: 8] = tx_pdata;
                5: src_mac[ 7: 0] = tx_pdata;
            endcase
        end

        //read protocol type
        else if (column_index < 14) begin
            case(column_index-12)
                0: protocol[15: 8] = tx_pdata;
                1: protocol[ 7: 0] = tx_pdata;
            endcase
        end

        //read src IP addr
        else if (column_index >= 26 && column_index < 30) begin
            case(column_index-26)
                0: src_IP[31:24] = tx_pdata;
                1: src_IP[23:16] = tx_pdata;
                2: src_IP[15: 8] = tx_pdata;
                3: src_IP[ 7: 0] = tx_pdata;
            endcase
        end

        //read dst IP addr
        else if (column_index >= 30 && column_index < 34) begin
            case(column_index-30)
                0: dst_IP[31:24] = tx_pdata;
                1: dst_IP[23:16] = tx_pdata;
                2: dst_IP[15: 8] = tx_pdata;
                3: dst_IP[ 7: 0] = tx_pdata;
            endcase
        end

        //read src port
        else if (column_index >= 34 && column_index < 36) begin
            case(column_index-34)
                0: src_port[15:8] = tx_pdata;
                1: src_port[ 7:0] = tx_pdata;
            endcase
        end

        //read dst port
        else if (column_index >= 36 && column_index < 38) begin
            case(column_index-36)
                0: dst_port[15:8] = tx_pdata;
                1: dst_port[ 7:0] = tx_pdata;
            endcase
        end

        //UDP packet length
        else if (column_index >= 38 && column_index < 40) begin
            case(column_index-38)
                0: udp_length[15:8] = tx_pdata;
                1: begin
                    udp_length[ 7:0] = tx_pdata;
                    frame_size = frame_size + udp_length - 16'd26;  //min UDP length: 26 (1 NoC packet)
                end
            endcase
        end

        //UDP checksum
        else if (column_index >= 40 && column_index < 42) begin
            case(column_index-40)
                0: checksum[15:8] = tx_pdata;
                1: checksum[ 7:0] = tx_pdata;
            endcase
        end


        //read NoC packet
        else if (column_index == 42) begin
            burst = tx_pdata[1];
            arq = tx_pdata[0];
        end else if (column_index == 43) begin
            bsel = tx_pdata;
        end else if (column_index == 44) begin
            src_modid = tx_pdata;
        end else if (column_index == 45) begin
            src_chipid = tx_pdata[7:2];
            trg_modid[7:6] = tx_pdata[1:0];
        end else if (column_index == 46) begin
            trg_modid[5:0] = tx_pdata[7:2];
            trg_chipid[5:4] = tx_pdata[1:0];
        end else if (column_index == 47) begin
            trg_chipid[3:0] = tx_pdata[7:4];
            mode = tx_pdata[3:0];
        end else if (column_index == 48) begin
            addr[31:24] = tx_pdata;
        end else if (column_index == 49) begin
            addr[23:16] = tx_pdata;
        end else if (column_index == 50) begin
            addr[15:8] = tx_pdata;
        end else if (column_index == 51) begin
            addr[7:0] = tx_pdata;
        end else if (column_index == 52) begin
            data[63:56] = tx_pdata;
        end else if (column_index == 53) begin
            data[55:48] = tx_pdata;
        end else if (column_index == 54) begin
            data[47:40] = tx_pdata;
        end else if (column_index == 55) begin
            data[39:32] = tx_pdata;
        end else if (column_index == 56) begin
            data[31:24] = tx_pdata;
        end else if (column_index == 57) begin
            data[23:16] = tx_pdata;
        end else if (column_index == 58) begin
            data[15:8] = tx_pdata;
        end else if (column_index == 59) begin
            data[7:0] = tx_pdata;
        end

        column_index = column_index + 1;
        repeat (num_of_repeat) begin
            @(posedge mon_tx_clk);
            #1;
        end
    end


    //print everything
    if (protocol == 16'h0806) begin //ARP frame
        $display("Received ARP frame from MAC 0x%h\n", src_mac);
        frame_size = min_frame_size;
        //...
    end else if (protocol == 16'h0800) begin //IP frame
        //check dst info
        if (dst_mac != HOST_MAC_ADDR || dst_IP != HOST_IP || dst_port != HOST_PORT) begin
            $display("ERROR: Recevied IP frame is not addressed to this host! MAC 0x%h, IP %0d.%0d.%0d.%0d:%0d", dst_mac, dst_IP[31:24], dst_IP[23:16], dst_IP[15:8], dst_IP[7:0], dst_port);
            $display("ERROR: Expected: MAC 0x%h, IP %0d.%0d.%0d.%0d:%0d", HOST_MAC_ADDR, HOST_IP[31:24], HOST_IP[23:16], HOST_IP[15:8], HOST_IP[7:0], HOST_PORT);
        end else begin
            $display("Received IP frame from MAC 0x%h, IP: %0d.%0d.%0d.%0d:%0d, checksum: 0x%h", src_mac, src_IP[31:24], src_IP[23:16], src_IP[15:8], src_IP[7:0], src_port, checksum);

            if (burst == 0) begin
                $display("NoC packet from modid 0x%h:", src_modid);
                $display("burst: %d", burst);
                $display("arq: %d", arq);
                $display("bsel: 0x%h", bsel);
                $display("mode: %0d", mode);
                $display("addr: 0x%h", addr);
                $display("data: 0x%8h_%8h\n", data[63:32], data[31:0]);
            end else begin
                if (last_was_burst) begin
                    $display("burst: %d", burst);
                    $display("bsel: 0x%h", bsel);
                    $display("data0: 0x%8h_%8h", data[63:32], data[31:0]);
                    $display("data1: 0x%8h_%8h\n", {src_modid, src_chipid, trg_modid, trg_chipid, mode}, addr);
                end else begin
                    $display("NoC packet from modid 0x%h:", src_modid);
                    $display("burst: %d", burst);
                    $display("arq: %d", arq);
                    $display("bsel: 0x%h", bsel);
                    $display("mode: %0d", mode);
                    $display("addr: 0x%h", addr);
                    $display("data: 0x%8h_%8h\n", data[63:32], data[31:0]);
                end
            end
        end
    end else begin
        $display("ERROR: Received frame with protocol type 0x%h not supported!", protocol);
        frame_size = min_frame_size;
    end


    column_index = 0;
    last_is_burst = burst;

    //detect further NoC burst packets in this frame (18 bytes per packet)
    while (column_index < (frame_size-min_frame_size)) begin
        calc_crc(tx_pdata,fcs);

        case (column_index)
            0: begin
                burst = tx_pdata[1];
                arq = tx_pdata[0];
            end
            1: bsel = tx_pdata;
            2: b_data1[63:56] = tx_pdata;
            3: b_data1[55:48] = tx_pdata;
            4: b_data1[47:40] = tx_pdata;
            5: b_data1[39:32] = tx_pdata;
            6: b_data1[31:24] = tx_pdata;
            7: b_data1[23:16] = tx_pdata;
            8: b_data1[15: 8] = tx_pdata;
            9: b_data1[ 7: 0] = tx_pdata;
            10: b_data0[63:56] = tx_pdata;
            11: b_data0[55:48] = tx_pdata;
            12: b_data0[47:40] = tx_pdata;
            13: b_data0[39:32] = tx_pdata;
            14: b_data0[31:24] = tx_pdata;
            15: b_data0[23:16] = tx_pdata;
            16: b_data0[15: 8] = tx_pdata;
            17: b_data0[ 7: 0] = tx_pdata;
        endcase


        if (column_index < 17) begin
            column_index = column_index + 1;
        end else begin
            //check is packet still belongs to burst
            if (last_is_burst) begin
                $display("burst: %d", burst);
                $display("bsel: 0x%h", bsel);
                $display("data0: 0x%h_%h", b_data0[63:32], b_data0[31:0]);
                $display("data1: 0x%h_%h\n", b_data1[63:32], b_data1[31:0]);
            end else begin
                $display("NoC packet from modid 0x%h:", b_data1[63:56]);
                $display("burst: %d", burst);
                $display("arq: %d", arq);
                $display("bsel: 0x%h", bsel);
                $display("mode: %0d", b_data1[35:32]);
                $display("addr: 0x%h", b_data1[31:0]);
                $display("data: 0x%8h_%8h\n", b_data0[63:32], b_data0[31:0]);
            end

            //remember burst for next packet
            last_is_burst = burst;

            column_index = 0;
            frame_size = frame_size - 18;
        end

        repeat (num_of_repeat) begin
            @(posedge mon_tx_clk);
            #1;
        end
    end


    //when payload is finished, read FCS
    for(I=0;I<4;I=I+1) begin
        case(I)
            0 :  if (tx_pdata !== fcs[7:0]) begin
                $display("** ERROR: gmii_txd incorrect during frame FCS field at %t txdata = %h fcs = %h",$realtime,tx_pdata,fcs);
            end
            1 :  if (tx_pdata !== fcs[15:8]) begin
                $display("** ERROR: gmii_txd incorrect during frame FCS field at %t txdata = %h fcs = %h",$realtime,tx_pdata,fcs);
            end
            2 :  if (tx_pdata !== fcs[23:16]) begin
                $display("** ERROR: gmii_txd incorrect during frame FCS field at %t txdata = %h fcs = %h",$realtime,tx_pdata,fcs);
            end
            3 :  if (tx_pdata !== fcs[31:24]) begin
                $display("** ERROR: gmii_txd incorrect during frame FCS field at %t txdata = %h fcs = %h",$realtime,tx_pdata,fcs);
            end
        endcase
        repeat (num_of_repeat) begin
            @(posedge mon_tx_clk);
            #1;
        end
    end

end
endtask // check_frame
