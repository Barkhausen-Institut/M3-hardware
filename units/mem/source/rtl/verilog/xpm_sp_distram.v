
module xpm_sp_distram #(
    parameter MEM_DATAWIDTH = 128,
    parameter MEM_ADDRWIDTH = 14
)
(
    input   wire                              clk,
    input   wire                              reset,

    input   wire                              en,
    input   wire          [MEM_DATAWIDTH-1:0] we,   //bit-wise select
    input   wire          [MEM_ADDRWIDTH-1:0] addr,
    input   wire          [MEM_DATAWIDTH-1:0] din,
    output  wire          [MEM_DATAWIDTH-1:0] dout
);

    genvar i_gen;
    generate

    //combine multiple 1-bit memories to get bit-wise write enable
    for (i_gen=0; i_gen<MEM_DATAWIDTH; i_gen=i_gen+1) begin: xpm_bit

        wire dout_bit;
        wire din_bit = din[i_gen];
        wire we_bit = we[i_gen];

        assign dout[i_gen] = dout_bit;


        // xpm_memory_spram: Single Port RAM
        // Xilinx Parameterized Macro, version 2019.1
        xpm_memory_spram #(
            .ADDR_WIDTH_A(MEM_ADDRWIDTH),   // DECIMAL
            .AUTO_SLEEP_TIME(0),            // DECIMAL
            .BYTE_WRITE_WIDTH_A(1),         // DECIMAL
            .CASCADE_HEIGHT(0),             // DECIMAL
            .ECC_MODE("no_ecc"),            // String
            .MEMORY_INIT_FILE("none"),      // String
            .MEMORY_INIT_PARAM("0"),        // String
            .MEMORY_OPTIMIZATION("true"),   // String
            .MEMORY_PRIMITIVE("distributed"),// String
            .MEMORY_SIZE(1<<MEM_ADDRWIDTH), // DECIMAL
            .MESSAGE_CONTROL(0),            // DECIMAL
            .READ_DATA_WIDTH_A(1),          // DECIMAL
            .READ_LATENCY_A(1),             // DECIMAL
            .READ_RESET_VALUE_A("0"),       // String
            .RST_MODE_A("SYNC"),            // String
            .SIM_ASSERT_CHK(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
            .USE_MEM_INIT(0),               // DECIMAL
            .WAKEUP_TIME("disable_sleep"),  // String
            .WRITE_DATA_WIDTH_A(1),         // DECIMAL
            .WRITE_MODE_A("read_first")     // String
        )
        xpm_memory_spram_inst (
            .dbiterra(),            // 1-bit output: Status signal to indicate double bit error occurrence
                                    // on the data output of port A.
            .douta(dout_bit),       // READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
            .sbiterra(),            // 1-bit output: Status signal to indicate single bit error occurrence
                                    // on the data output of port A.
            .addra(addr),           // ADDR_WIDTH_A-bit input: Address for port A write and read operations.
            .clka(clk),             // 1-bit input: Clock signal for port A.
            .dina(din_bit),         // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
            .ena(en),               // 1-bit input: Memory enable signal for port A. Must be high on clock
                                    // cycles when read or write operations are initiated. Pipelined
                                    // internally.
            .injectdbiterra(1'b0),  // 1-bit input: Controls double bit error injection on input data when
                                    // ECC enabled (Error injection capability is not available in
                                    // "decode_only" mode).
            .injectsbiterra(1'b0),  // 1-bit input: Controls single bit error injection on input data when
                                    // ECC enabled (Error injection capability is not available in
                                    // "decode_only" mode).
            .regcea(1'b1),          // 1-bit input: Clock Enable for the last register stage on the output data path.
            .rsta(reset),           // 1-bit input: Reset signal for the final port A output register stage.
                                    // Synchronously resets output port douta to the value specified by
                                    // parameter READ_RESET_VALUE_A.
            .sleep(1'b0),           // 1-bit input: sleep signal to enable the dynamic power saving feature.
            .wea(we_bit)            // WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input
                                    // data port dina. 1 bit wide when word-wide writes are used. In
                                    // byte-wide write configurations, each bit controls the writing one
                                    // byte of dina to address addra. For example, to synchronously write
                                    // only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be
                                    // 4'b0010.
        );

    end
    endgenerate


endmodule
