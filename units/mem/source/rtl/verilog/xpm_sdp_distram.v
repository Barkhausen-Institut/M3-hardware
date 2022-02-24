
module xpm_sdp_distram #(
    parameter MEM_DATAWIDTH = 128,
    parameter MEM_ADDRWIDTH = 14
)
(
    input   wire                              clk,
    input   wire                              reset,

    input   wire                              ena,
    input   wire          [MEM_DATAWIDTH-1:0] wea,   //bit-wise select
    input   wire          [MEM_ADDRWIDTH-1:0] addra,
    input   wire          [MEM_DATAWIDTH-1:0] dina,

    input   wire                              enb,
    input   wire          [MEM_ADDRWIDTH-1:0] addrb,
    output  wire          [MEM_DATAWIDTH-1:0] doutb
);

    genvar i_gen;
    generate

    //combine multiple 1-bit memories to get bit-wise write enable
    for (i_gen=0; i_gen<MEM_DATAWIDTH; i_gen=i_gen+1) begin: xpm_bit

        wire doutb_bit;
        wire dina_bit = dina[i_gen];
        wire wea_bit = wea[i_gen];

        assign doutb[i_gen] = doutb_bit;


        // xpm_memory_sdpram: Simple Dual Port RAM
        // Xilinx Parameterized Macro, version 2019.1
        xpm_memory_sdpram #(
            .ADDR_WIDTH_A(MEM_ADDRWIDTH), // DECIMAL
            .ADDR_WIDTH_B(MEM_ADDRWIDTH), // DECIMAL
            .AUTO_SLEEP_TIME(0), // DECIMAL
            .BYTE_WRITE_WIDTH_A(1), // DECIMAL
            .CASCADE_HEIGHT(0), // DECIMAL
            .CLOCKING_MODE("common_clock"), // String
            .ECC_MODE("no_ecc"), // String
            .MEMORY_INIT_FILE("none"), // String
            .MEMORY_INIT_PARAM("0"), // String
            .MEMORY_OPTIMIZATION("true"), // String
            .MEMORY_PRIMITIVE("distributed"), // String
            .MEMORY_SIZE(1<<MEM_ADDRWIDTH), // DECIMAL
            .MESSAGE_CONTROL(0), // DECIMAL
            .READ_DATA_WIDTH_B(1), // DECIMAL
            .READ_LATENCY_B(1), // DECIMAL
            .READ_RESET_VALUE_B("0"), // String
            .RST_MODE_A("SYNC"), // String
            .RST_MODE_B("SYNC"), // String
            .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
            .USE_EMBEDDED_CONSTRAINT(0), // DECIMAL
            .USE_MEM_INIT(0), // DECIMAL
            .WAKEUP_TIME("disable_sleep"), // String
            .WRITE_DATA_WIDTH_A(1), // DECIMAL
            .WRITE_MODE_B("read_first") // String
        )
        xpm_memory_sdpram_inst (
            .dbiterrb(), // 1-bit output: Status signal to indicate double bit error occurrence
                        // on the data output of port B.
            .doutb(doutb_bit), // READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
            .sbiterrb(), // 1-bit output: Status signal to indicate single bit error occurrence
                        // on the data output of port B.
            .addra(addra), // ADDR_WIDTH_A-bit input: Address for port A write operations.
            .addrb(addrb), // ADDR_WIDTH_B-bit input: Address for port B read operations.
            .clka(clk), // 1-bit input: Clock signal for port A. Also clocks port B when
                        // parameter CLOCKING_MODE is "common_clock".
            .clkb(clk), // 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
                        // "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
            .dina(dina_bit), // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
            .ena(ena), // 1-bit input: Memory enable signal for port A. Must be high on clock
                    // cycles when write operations are initiated. Pipelined internally.
            .enb(enb), // 1-bit input: Memory enable signal for port B. Must be high on clock
                    // cycles when read operations are initiated. Pipelined internally.
            .injectdbiterra(1'b0), // 1-bit input: Controls double bit error injection on input data when
                                // ECC enabled (Error injection capability is not available in "decode_only" mode).
            .injectsbiterra(1'b0), // 1-bit input: Controls single bit error injection on input data when
                                // ECC enabled (Error injection capability is not available in
            .regceb(1'b1), // 1-bit input: Clock Enable for the last register stage on the output data path.
            .rstb(reset), // 1-bit input: Reset signal for the final port B output register stage.
                        // Synchronously resets output port doutb to the value specified by parameter READ_RESET_VALUE_B.
            .sleep(1'b0), // 1-bit input: sleep signal to enable the dynamic power saving feature.
            .wea(wea_bit) // WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input
            // data port dina. 1 bit wide when word-wide writes are used. In
            // byte-wide write configurations, each bit controls the writing one
            // byte of dina to address addra. For example, to synchronously write
            // only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be
            // 4'b0010.
        );

    end
    endgenerate


endmodule
