
`timescale 1ps/1ps

module fpga_clk_gen_300 #(
    //Important! Input frequency value must be a divisor of 1000
    parameter CLKOUT0_MHZ = 100,
    parameter CLKOUT1_MHZ = 100,
    parameter CLKOUT2_MHZ = 100,
    parameter CLKOUT3_MHZ = 100,
    parameter CLKOUT4_MHZ = 100,
    parameter CLKOUT5_MHZ = 100,
    parameter CLKOUT6_MHZ = 100
)(
    output        clk0_out,
    output        clk1_out,
    output        clk2_out,
    output        clk3_out,
    output        clk4_out,
    output        clk5_out,
    output        clk6_out,
  
    // Status and control signals
    input         reset,
    output        locked,
    input         clk_in_300_p,
    input         clk_in_300_n
);

    localparam LOCAL_CLKOUT0_DIV = 1000/CLKOUT0_MHZ;
    localparam LOCAL_CLKOUT1_DIV = 1000/CLKOUT1_MHZ;
    localparam LOCAL_CLKOUT2_DIV = 1000/CLKOUT2_MHZ;
    localparam LOCAL_CLKOUT3_DIV = 1000/CLKOUT3_MHZ;
    localparam LOCAL_CLKOUT4_DIV = 1000/CLKOUT4_MHZ;
    localparam LOCAL_CLKOUT5_DIV = 1000/CLKOUT5_MHZ;
    localparam LOCAL_CLKOUT6_DIV = 1000/CLKOUT6_MHZ;

    //f_out = CLKIN1_PERIOD * CLKFBOUT_MULT_F / (DIVCLK_DIVIDE * LOCAL_CLKOUTX_DIV)
    //f_out = 300 * 10 / (3 * X) = 1000 / X


    // Input buffering
    //------------------------------------
    wire clk_in1_clk_wiz_0;
    wire clk_in2_clk_wiz_0;

    IBUFDS clkin1_ibufds (
        .O  (clk_in1_clk_wiz_0),
        .I  (clk_in_300_p),
        .IB (clk_in_300_n)
    );




    // Clocking PRIMITIVE
    //------------------------------------

    // Instantiation of the MMCM PRIMITIVE
    //    * Unused inputs are tied off
    //    * Unused outputs are labeled unused

    wire        clk0_wiz_0;
    wire        clk1_wiz_0;
    wire        clk2_wiz_0;
    wire        clk3_wiz_0;
    wire        clk4_wiz_0;
    wire        clk5_wiz_0;
    wire        clk6_wiz_0;

    wire [15:0] do_unused;
    wire        drdy_unused;
    wire        psdone_unused;
    wire        locked_int;
    wire        clkfbout_clk_wiz_0;
    wire        clkfboutb_unused;
    wire        clkout0b_unused;
    wire        clkout1b_unused;
    wire        clkout2b_unused;
    wire        clkout3b_unused;
    wire        clkfbstopped_unused;
    wire        clkinstopped_unused;
    wire        reset_high;



    MMCME4_ADV #(
        .BANDWIDTH            ("OPTIMIZED"),
        .CLKOUT4_CASCADE      ("FALSE"),
        .COMPENSATION         ("AUTO"),
        .STARTUP_WAIT         ("FALSE"),
        .DIVCLK_DIVIDE        (3),
        .CLKFBOUT_MULT_F      (10.000),
        .CLKFBOUT_PHASE       (0.000),
        .CLKFBOUT_USE_FINE_PS ("FALSE"),
        .CLKOUT0_DIVIDE_F     (LOCAL_CLKOUT0_DIV),
        .CLKOUT0_PHASE        (0.000),
        .CLKOUT0_DUTY_CYCLE   (0.500),
        .CLKOUT0_USE_FINE_PS  ("FALSE"),
        .CLKOUT1_DIVIDE       (LOCAL_CLKOUT1_DIV),
        .CLKOUT1_PHASE        (0.000),
        .CLKOUT1_DUTY_CYCLE   (0.500),
        .CLKOUT1_USE_FINE_PS  ("FALSE"),
        .CLKOUT2_DIVIDE       (LOCAL_CLKOUT2_DIV),
        .CLKOUT2_PHASE        (0.000),
        .CLKOUT2_DUTY_CYCLE   (0.500),
        .CLKOUT2_USE_FINE_PS  ("FALSE"),
        .CLKOUT3_DIVIDE       (LOCAL_CLKOUT3_DIV),
        .CLKOUT3_PHASE        (0.000),
        .CLKOUT3_DUTY_CYCLE   (0.500),
        .CLKOUT3_USE_FINE_PS  ("FALSE"),
        .CLKOUT4_DIVIDE       (LOCAL_CLKOUT4_DIV),
        .CLKOUT4_PHASE        (0.000),
        .CLKOUT4_DUTY_CYCLE   (0.500),
        .CLKOUT4_USE_FINE_PS  ("FALSE"),
        .CLKOUT5_DIVIDE       (LOCAL_CLKOUT5_DIV),
        .CLKOUT5_PHASE        (0.000),
        .CLKOUT5_DUTY_CYCLE   (0.500),
        .CLKOUT5_USE_FINE_PS  ("FALSE"),
        .CLKOUT6_DIVIDE       (LOCAL_CLKOUT6_DIV),
        .CLKOUT6_PHASE        (0.000),
        .CLKOUT6_DUTY_CYCLE   (0.500),
        .CLKOUT6_USE_FINE_PS  ("FALSE"),
        .CLKIN1_PERIOD        (3.333)
    ) mmcme4_adv_inst (
        // Output clocks
        .CLKFBOUT            (clkfbout_clk_wiz_0),
        .CLKFBOUTB           (clkfboutb_unused),
        .CLKOUT0             (clk0_wiz_0),
        .CLKOUT0B            (clkout0b_unused),
        .CLKOUT1             (clk1_wiz_0),
        .CLKOUT1B            (clkout1b_unused),
        .CLKOUT2             (clk2_wiz_0),
        .CLKOUT2B            (clkout2b_unused),
        .CLKOUT3             (clk3_wiz_0),
        .CLKOUT3B            (clkout3b_unused),
        .CLKOUT4             (clk4_wiz_0),
        .CLKOUT5             (clk5_wiz_0),
        .CLKOUT6             (clk6_wiz_0),
        // Input clock control
        .CLKFBIN             (clkfbout_clk_wiz_0),
        .CLKIN1              (clk_in1_clk_wiz_0),
        .CLKIN2              (1'b0),
        // Tied to always select the primary input clock
        .CLKINSEL            (1'b1),
        // Ports for dynamic reconfiguration
        .DADDR               (7'h0),
        .DCLK                (1'b0),
        .DEN                 (1'b0),
        .DI                  (16'h0),
        .DO                  (do_unused),
        .DRDY                (drdy_unused),
        .DWE                 (1'b0),
        .CDDCDONE            (),
        .CDDCREQ             (1'b0),
        // Ports for dynamic phase shift
        .PSCLK               (1'b0),
        .PSEN                (1'b0),
        .PSINCDEC            (1'b0),
        .PSDONE              (psdone_unused),
        // Other control and status signals
        .LOCKED              (locked_int),
        .CLKINSTOPPED        (clkinstopped_unused),
        .CLKFBSTOPPED        (clkfbstopped_unused),
        .PWRDWN              (1'b0),
        .RST                 (reset_high)
    );

    assign reset_high = reset; 

    assign locked = locked_int;



    // Clock Monitor clock assigning
    //--------------------------------------
    // Output buffering
    //-----------------------------------


    BUFG clkout0_buf (
        .O   (clk0_out),
        .I   (clk0_wiz_0)
    );

    BUFG clkout1_buf (
        .O   (clk1_out),
        .I   (clk1_wiz_0)
    );

    BUFG clkout2_buf (
        .O   (clk2_out),
        .I   (clk2_wiz_0)
    );

    BUFG clkout3_buf (
        .O   (clk3_out),
        .I   (clk3_wiz_0)
    );

    BUFG clkout4_buf (
        .O   (clk4_out),
        .I   (clk4_wiz_0)
    );

    BUFG clkout5_buf (
        .O   (clk5_out),
        .I   (clk5_wiz_0)
    );

    BUFG clkout6_buf (
        .O   (clk6_out),
        .I   (clk6_wiz_0)
    );


endmodule

