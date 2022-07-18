// This module establishes a JTAG tunnel from one of the BSCAN Tunnels of the Xilinx FPGA.
// There are two BSCANE instances used:
// One for the tunnel itself, its channel number configured via JTAG_TUNNEL_USER_CHAIN = {1-4}
// One for tunnel configuration, its channel number configured via JTAG_CONFIG_USER_CHAIN = {1-4}


module jtag_tunnel_mc8( 
        output wire jtag_c0_tck_o, 
        output wire jtag_c0_tms_o, 
        output wire jtag_c0_tdi_o, 
        input  wire jtag_c0_tdo_i,
        input  wire jtag_c0_tdo_en_i,
        output wire jtag_c0_sel_o,

        output wire jtag_c1_tck_o, 
        output wire jtag_c1_tms_o, 
        output wire jtag_c1_tdi_o, 
        input  wire jtag_c1_tdo_i,
        input  wire jtag_c1_tdo_en_i,
        output wire jtag_c1_sel_o,

        output wire jtag_c2_tck_o, 
        output wire jtag_c2_tms_o, 
        output wire jtag_c2_tdi_o, 
        input  wire jtag_c2_tdo_i,
        input  wire jtag_c2_tdo_en_i,
        output wire jtag_c2_sel_o,

        output wire jtag_c3_tck_o, 
        output wire jtag_c3_tms_o, 
        output wire jtag_c3_tdi_o, 
        input  wire jtag_c3_tdo_i,
        input  wire jtag_c3_tdo_en_i,
        output wire jtag_c3_sel_o,
       
	output wire jtag_c4_tck_o, 
        output wire jtag_c4_tms_o, 
        output wire jtag_c4_tdi_o, 
        input  wire jtag_c4_tdo_i,
        input  wire jtag_c4_tdo_en_i,
        output wire jtag_c4_sel_o,
	
        output wire jtag_c5_tck_o, 
        output wire jtag_c5_tms_o, 
        output wire jtag_c5_tdi_o, 
        input  wire jtag_c5_tdo_i,
        input  wire jtag_c5_tdo_en_i,
        output wire jtag_c5_sel_o,

        output wire jtag_c6_tck_o, 
        output wire jtag_c6_tms_o, 
        output wire jtag_c6_tdi_o, 
        input  wire jtag_c6_tdo_i,
        input  wire jtag_c6_tdo_en_i,
        output wire jtag_c6_sel_o,
        
	output wire jtag_c7_tck_o, 
        output wire jtag_c7_tms_o, 
        output wire jtag_c7_tdi_o, 
        input  wire jtag_c7_tdo_i,
        input  wire jtag_c7_tdo_en_i,
        output wire jtag_c7_sel_o
 
); 
        
      parameter JTAG_TUNNEL_USER_CHAIN=4;
      parameter JTAG_CONFIG_USER_CHAIN=3;
      
        wire [3:0] debug_o;

        //------------------------------------------------------------
        // JTAG Tunnel configuration
        //------------------------------------------------------------

        reg [7:0] tunnel_addr;
        reg [7:0] tunnel_addr_shiftreg;



        wire cfg_capture;
        wire cfg_reset;
        wire cfg_drck; 
        wire cfg_sel; 
        wire cfg_shift; 
        wire cfg_update;
        wire cfg_tck;
        wire cfg_tdi;
        wire cfg_tdo;

        BSCANE2 #( 
          .JTAG_CHAIN(JTAG_CONFIG_USER_CHAIN) // Value for USER command. 
        ) 
        BSCANE2_config_inst ( 
          .CAPTURE(cfg_capture), // 1-bit output: CAPTURE output from TAP controller. 
          .DRCK(cfg_drck), // 1-bit output: Gated TCK output. When SEL is asserted, DRCK toggles when CAPTURE or 
          // SHIFT are asserted. 
            .RESET(cfg_reset), // 1-bit output: Reset output for TAP controller. 
            .RUNTEST(), // 1-bit output: Output asserted when TAP controller is in Run Test/Idle state. 
            .SEL(cfg_sel), // 1-bit output: USER instruction active output. 
            .SHIFT(cfg_shift), // 1-bit output: SHIFT output from TAP controller. 
            .TCK(cfg_tck), // 1-bit output: Test Clock output. Fabric connection to TAP Clock pin. 
            .TDI(cfg_tdi), // 1-bit output: Test Data Input (TDI) output from TAP controller. 
            .TMS(), // 1-bit output: Test Mode Select output. Fabric connectiwire jtag_c0_tdo_en;on to TAP. 
            .UPDATE(cfg_update), // 1-bit output: UPDATE output from TAP controller 
            .TDO(cfg_tdo) // 1-bit input: Test Data Output (TDO) input for USER function. 
          ); 
        
        assign cfg_tdo = tunnel_addr_shiftreg[0];

        always @ (posedge cfg_drck) begin
                if (cfg_reset) begin
                        tunnel_addr_shiftreg <= 8'd0;        
                end else begin
                         if (cfg_shift) begin
                                tunnel_addr_shiftreg <= {cfg_tdi, tunnel_addr_shiftreg[7:1]};
                        end else if (cfg_capture) begin
                                tunnel_addr_shiftreg <= tunnel_addr;
                        end                    
                end
        end

        always @ (negedge cfg_tck) begin
                tunnel_addr <= tunnel_addr;
                if (cfg_sel && cfg_update) begin
                        tunnel_addr <= tunnel_addr_shiftreg;
                end
        end


        //------------------------------------------------------------
        // JTAG Tunnel
        //------------------------------------------------------------

        // Jtag master signals from the tunnel

        reg  jtag_tms;    // output
        wire jtag_tdi;    // output
        wire jtag_tdo;    // input
        wire jtag_tdo_en; // input

        wire TCK;  
        wire SEL; 
        wire SHIFT; 
        wire TDI;
        wire TDO; 

        reg [6:0] shiftreg_cnt; 
        reg [7:0] counter_neg; 
        reg [7:0] counter_pos; 
        reg         TDI_REG; 
        
        BSCANE2 #( 
          .JTAG_CHAIN(JTAG_TUNNEL_USER_CHAIN) // Value for USER command. 
        ) 
        BSCANE2_inst ( 
          .CAPTURE(), // 1-bit output: CAPTURE output from TAP controller. 
          .DRCK(), // 1-bit output: Gated TCK output. When SEL is asserted, DRCK toggles when CAPTURE or 
          // SHIFT are asserted. 
            .RESET(), // 1-bit output: Reset output for TAP controller. 
            .RUNTEST(), // 1-bit output: Output asserted when TAP controller is in Run Test/Idle state. 
            .SEL(SEL), // 1-bit output: USER instruction active output. 
            .SHIFT(SHIFT), // 1-bit output: SHIFT output from TAP controller. 
            .TCK(TCK), // 1-bit output: Test Clock output. Fabric connection to TAP Clock pin. 
            .TDI(TDI), // 1-bit output: Test Data Input (TDI) output from TAP controller. 
            .TMS(), // 1-bit output: Test Mode Select output. Fabric connection to TAP. 
            .UPDATE(), // 1-bit output: UPDATE output from TAP controller 
            .TDO(TDO) // 1-bit input: Test Data Output (TDO) input for USER function. 
          ); 
      
        
        assign jtag_tdi = TDI; 
        assign TDO = jtag_tdo; 
        
        always@(*) begin 
                if (counter_neg == 8'h04) begin 
                        jtag_tms = TDI_REG; 
                end else if (counter_neg == 8'h05) begin 
                        jtag_tms = 1'b1; 
                end else if ((counter_neg == (8'h08 + shiftreg_cnt)) || (counter_neg == (8'h08 + shiftreg_cnt - 8'h01))) begin 
                        jtag_tms = 1'b1; 
                end else begin 
                        jtag_tms = 1'b0; 
                end 
        end 
        
        always@(posedge TCK) begin 
                if (~SHIFT) begin 
                        shiftreg_cnt <= 7'b0000000; 
                end else if ((counter_pos >= 8'h01) && (counter_pos <= 8'h07))  begin 
                        shiftreg_cnt <= {{TDI, shiftreg_cnt[6:1]}}; 
                end else begin 
                        shiftreg_cnt <= shiftreg_cnt; 
                end 
        end 
        
        always@(posedge TCK) begin 
                if (~SHIFT) begin 
                        TDI_REG <= 1'b0; 
                end else if (counter_pos == 8'h00) begin 
                        TDI_REG <= ~TDI; 
                end else begin 
                        TDI_REG <= TDI_REG; 
                end 
        end 
        
        always@(negedge TCK) begin 
                if (~SHIFT) begin 
                        counter_neg <= 8'b00000000; 
                end else begin 
                        counter_neg <= counter_neg + 1; 
                end 
        end 

        always@(posedge TCK) begin 
                if (~SHIFT) begin 
                        counter_pos <= 8'b00000000; 
                end else begin 
                        counter_pos <= counter_pos + 1; 
                end 
        end


        //------------------------------------------------------------
        // JTAG Tunnel Mux
        //------------------------------------------------------------
        wire [2:0] tunnel_sel;
        reg [7:0] tunnel_sel_oh;
        assign tunnel_sel = tunnel_addr[2:0];

        always @* begin
                case (tunnel_sel) 
                       3'b000: begin tunnel_sel_oh = 8'b00000001; end
                       3'b001: begin tunnel_sel_oh = 8'b00000010; end
                       3'b010: begin tunnel_sel_oh = 8'b00000100; end
                       3'b011: begin tunnel_sel_oh = 8'b00001000; end
                       3'b100: begin tunnel_sel_oh = 8'b00010000; end
                       3'b101: begin tunnel_sel_oh = 8'b00100000; end
                       3'b110: begin tunnel_sel_oh = 8'b01000000; end
                       3'b111: begin tunnel_sel_oh = 8'b10000000; end
                endcase
        end

        wire tunnel_sel0;
        wire tunnel_sel1;
        wire tunnel_sel2;
        wire tunnel_sel3;
        wire tunnel_sel4;
        wire tunnel_sel5;
        wire tunnel_sel6;
        wire tunnel_sel7;


        assign tunnel_sel0 = tunnel_sel_oh[0];
        assign tunnel_sel1 = tunnel_sel_oh[1];
        assign tunnel_sel2 = tunnel_sel_oh[2];
        assign tunnel_sel3 = tunnel_sel_oh[3];
        assign tunnel_sel4 = tunnel_sel_oh[4];
        assign tunnel_sel5 = tunnel_sel_oh[5];
        assign tunnel_sel6 = tunnel_sel_oh[6];
        assign tunnel_sel7 = tunnel_sel_oh[7];

        // TCK
        BUFGCE clkbuf_0 ( 
          .O(jtag_c0_tck_o), // 1-bit output: Clock output 
          .CE(tunnel_sel0 & SEL), // 1-bit input: Clock enable input for I0 
          .I(TCK) // 1-bit input: Primary clock 
        ); 

        BUFGCE clkbuf_1 ( 
          .O(jtag_c1_tck_o), // 1-bit output: Clock output 
          .CE(tunnel_sel1 & SEL), // 1-bit input: Clock enable input for I0 
          .I(TCK) // 1-bit input: Primary clock 
        ); 

        BUFGCE clkbuf_2 ( 
          .O(jtag_c2_tck_o), // 1-bit output: Clock output 
          .CE(tunnel_sel2 & SEL), // 1-bit input: Clock enable input for I0 
          .I(TCK) // 1-bit input: Primary clock 
        ); 

        BUFGCE clkbuf_3 ( 
          .O(jtag_c3_tck_o), // 1-bit output: Clock output 
          .CE(tunnel_sel3 & SEL), // 1-bit input: Clock enable input for I0 
          .I(TCK) // 1-bit input: Primary clock 
        ); 

        BUFGCE clkbuf_4 ( 
          .O(jtag_c4_tck_o), // 1-bit output: Clock output 
          .CE(tunnel_sel4 & SEL), // 1-bit input: Clock enable input for I0 
          .I(TCK) // 1-bit input: Primary clock 
        ); 

        BUFGCE clkbuf_5 ( 
          .O(jtag_c5_tck_o), // 1-bit output: Clock output 
          .CE(tunnel_sel5 & SEL), // 1-bit input: Clock enable input for I0 
          .I(TCK) // 1-bit input: Primary clock 
        ); 

        BUFGCE clkbuf_6 ( 
          .O(jtag_c6_tck_o), // 1-bit output: Clock output 
          .CE(tunnel_sel6 & SEL), // 1-bit input: Clock enable input for I0 
          .I(TCK) // 1-bit input: Primary clock 
        ); 

        BUFGCE clkbuf_7 ( 
          .O(jtag_c7_tck_o), // 1-bit output: Clock output 
          .CE(tunnel_sel7 & SEL), // 1-bit input: Clock enable input for I0 
          .I(TCK) // 1-bit input: Primary clock 
        ); 
        
        // TMS
        assign jtag_c0_tms_o = (tunnel_sel0) ? jtag_tms : 1'b1;
        assign jtag_c1_tms_o = (tunnel_sel1) ? jtag_tms : 1'b1;
        assign jtag_c2_tms_o = (tunnel_sel2) ? jtag_tms : 1'b1;
        assign jtag_c3_tms_o = (tunnel_sel3) ? jtag_tms : 1'b1;
        assign jtag_c4_tms_o = (tunnel_sel4) ? jtag_tms : 1'b1;
        assign jtag_c5_tms_o = (tunnel_sel5) ? jtag_tms : 1'b1;
        assign jtag_c6_tms_o = (tunnel_sel6) ? jtag_tms : 1'b1;
        assign jtag_c7_tms_o = (tunnel_sel7) ? jtag_tms : 1'b1;

        // TDI
        assign jtag_c0_tdi_o = (tunnel_sel0) ? jtag_tdi : 1'b1;
        assign jtag_c1_tdi_o = (tunnel_sel1) ? jtag_tdi : 1'b1;
        assign jtag_c2_tdi_o = (tunnel_sel2) ? jtag_tdi : 1'b1;
        assign jtag_c3_tdi_o = (tunnel_sel3) ? jtag_tdi : 1'b1;
        assign jtag_c4_tdi_o = (tunnel_sel4) ? jtag_tdi : 1'b1;
        assign jtag_c5_tdi_o = (tunnel_sel5) ? jtag_tdi : 1'b1;
        assign jtag_c6_tdi_o = (tunnel_sel6) ? jtag_tdi : 1'b1;
        assign jtag_c7_tdi_o = (tunnel_sel7) ? jtag_tdi : 1'b1;

        // TDO
        assign jtag_c0_tdo = (tunnel_sel0 && jtag_c0_tdo_en_i) ? jtag_c0_tdo_i : 1'b1;
        assign jtag_c1_tdo = (tunnel_sel1 && jtag_c1_tdo_en_i) ? jtag_c1_tdo_i : 1'b1;
        assign jtag_c2_tdo = (tunnel_sel2 && jtag_c2_tdo_en_i) ? jtag_c2_tdo_i : 1'b1;
        assign jtag_c3_tdo = (tunnel_sel3 && jtag_c3_tdo_en_i) ? jtag_c3_tdo_i : 1'b1;
        assign jtag_c4_tdo = (tunnel_sel4 && jtag_c4_tdo_en_i) ? jtag_c4_tdo_i : 1'b1;
        assign jtag_c5_tdo = (tunnel_sel5 && jtag_c5_tdo_en_i) ? jtag_c5_tdo_i : 1'b1;
        assign jtag_c6_tdo = (tunnel_sel6 && jtag_c6_tdo_en_i) ? jtag_c6_tdo_i : 1'b1;
        assign jtag_c7_tdo = (tunnel_sel7 && jtag_c7_tdo_en_i) ? jtag_c7_tdo_i : 1'b1;

        assign jtag_tdo = jtag_c0_tdo & jtag_c1_tdo & jtag_c2_tdo & jtag_c3_tdo & jtag_c4_tdo & jtag_c5_tdo & jtag_c6_tdo & jtag_c7_tdo;

        // Debug
        assign jtag_c0_sel_o = tunnel_sel0;
        assign jtag_c1_sel_o = tunnel_sel1;
        assign jtag_c2_sel_o = tunnel_sel2;
        assign jtag_c3_sel_o = SEL;

endmodule 
