
module picorv32_trace #(
    parameter TRACE_BASEADDR     = 32'h00100000,
    parameter TRACE_SIZE         = 'h2000,  //1024 traces * 8 bytes per trace (one mem row contains 16 byte = 2 traces)
    parameter PICO_MEM_ADDR_SIZE = 32,
    parameter ASM_MEM_DATA_SIZE  = 128
)(
    input  wire                          clk_i,
    input  wire                          reset_n_i,

    //settings from regfile
    input  wire                          trace_enabled_i,
    output wire [PICO_MEM_ADDR_SIZE-1:0] trace_ptr_o,
    output wire [PICO_MEM_ADDR_SIZE-1:0] trace_count_o,

    //trace interface
    input  wire                          trace_valid_i,
    input  wire                   [35:0] trace_data_i,

    //memory interface
    input  wire                          trace_mem_en_i,
    input  wire [PICO_MEM_ADDR_SIZE-1:0] trace_mem_addr_i,
    output wire  [ASM_MEM_DATA_SIZE-1:0] trace_mem_rdata_o
);

    
    localparam TRACEMEM_DATAWIDTH              = 36;
    localparam TRACEMEM_DATAWIDTH_BYTE         = 8;     //data width rounded up to next power of 2
    localparam TRACEMEM_DATAWIDTH_EXT          = 128;   //adapted to 128-bit memory interface for TCU
    localparam TRACEMEM_DATAWIDTH_EXT_BYTE     = TRACEMEM_DATAWIDTH_EXT >> 3;    //in bytes
    localparam TRACEMEM_DATAWIDTH_EXT_BYTE_LOG = $clog2(TRACEMEM_DATAWIDTH_EXT_BYTE);
    localparam TRACEMEM_ADDRWIDTH              = $clog2(TRACE_SIZE/TRACEMEM_DATAWIDTH_BYTE);      //2^10 traces
    localparam TRACEMEM_ADDRWIDTH_PERMEM       = TRACEMEM_ADDRWIDTH - 1;                          //2^9 traces per memory
    

    //insert traces from core
    reg                             r_trace_en;
    reg    [TRACEMEM_ADDRWIDTH-1:0] r_trace_addr, rin_trace_addr;
    reg                      [35:0] r_trace_wdata;
    reg      [TRACEMEM_ADDRWIDTH:0] r_trace_count, rin_trace_count;

    reg                             r_trace_enabled;

    wire                                 trace_en1 = r_trace_en && ~r_trace_addr[0];    //even trace addresses in mem1
    wire                                 trace_en2 = r_trace_en && r_trace_addr[0];
    wire [TRACEMEM_ADDRWIDTH_PERMEM-1:0] trace_addr1 = r_trace_addr[TRACEMEM_ADDRWIDTH-1:1];
    wire [TRACEMEM_ADDRWIDTH_PERMEM-1:0] trace_addr2 = r_trace_addr[TRACEMEM_ADDRWIDTH-1:1];


    //access from memory interface
    wire        [PICO_MEM_ADDR_SIZE-1:0] trace_mem_addr_offset = trace_mem_addr_i - TRACE_BASEADDR;             //subtract offset
    wire [TRACEMEM_ADDRWIDTH_PERMEM-1:0] trace_mem_addr = trace_mem_addr_offset >> TRACEMEM_DATAWIDTH_EXT_BYTE_LOG;    //shift by 4 due to virtual 128-bit rows

    wire   [TRACEMEM_DATAWIDTH-1:0] trace_mem_rdata1;
    wire   [TRACEMEM_DATAWIDTH-1:0] trace_mem_rdata2;

    //assign read data of both memories to output
    assign trace_mem_rdata_o = {{((ASM_MEM_DATA_SIZE/2)-TRACEMEM_DATAWIDTH){1'b0}}, trace_mem_rdata2,
                                {((ASM_MEM_DATA_SIZE/2)-TRACEMEM_DATAWIDTH){1'b0}}, trace_mem_rdata1};


    //current address
    assign trace_ptr_o = r_trace_addr;
    assign trace_count_o = r_trace_count;



    always @(posedge clk_i or negedge reset_n_i) begin
        if (reset_n_i == 1'b0) begin
            r_trace_en <= 1'b0;
            r_trace_addr <= {TRACEMEM_ADDRWIDTH{1'b0}};
            r_trace_wdata <= {TRACEMEM_DATAWIDTH{1'b0}};
            r_trace_count <= {(TRACEMEM_ADDRWIDTH+1){1'b0}};

            r_trace_enabled <= 1'b0;
        end
        else begin
            r_trace_en <= trace_valid_i && trace_enabled_i;
            r_trace_addr <= rin_trace_addr;
            r_trace_wdata <= trace_data_i;
            r_trace_count <= rin_trace_count;

            r_trace_enabled <= trace_enabled_i;
        end
    end

    always @* begin
        rin_trace_addr = r_trace_addr;
        rin_trace_count = r_trace_count;

        //incr addr in subsequent cycle due to registered wdata
        if (r_trace_en) begin
            rin_trace_addr = r_trace_addr + 1;

            //stop counting when mem full
            if (r_trace_count <= {TRACEMEM_ADDRWIDTH{1'b1}}) begin
                rin_trace_count = r_trace_count + 1;
            end
        end

        //reset trace count when tracing starts
        if (trace_enabled_i && !r_trace_enabled) begin
            rin_trace_count = {(TRACEMEM_ADDRWIDTH+1){1'b0}};
        end
    end



    mem_tp_wrap #(
        .MEM_TYPE      ("auto"),
        .MEM_DATAWIDTH (TRACEMEM_DATAWIDTH),
        .MEM_ADDRWIDTH (TRACEMEM_ADDRWIDTH_PERMEM)
    ) i_picorv32_trace_mem1 (
        .clk    (clk_i),
        .reset  (~reset_n_i),

        .ena    (trace_en1),
        .wea    ({((TRACEMEM_DATAWIDTH+7)/8){1'b1}}),
        .addra  (trace_addr1),
        .dina   (r_trace_wdata),

        .enb    (trace_mem_en_i),
        .addrb  (trace_mem_addr),
        .doutb  (trace_mem_rdata1)
    );

    mem_tp_wrap #(
        .MEM_TYPE      ("auto"),
        .MEM_DATAWIDTH (TRACEMEM_DATAWIDTH),
        .MEM_ADDRWIDTH (TRACEMEM_ADDRWIDTH_PERMEM)
    ) i_picorv32_trace_mem2 (
        .clk    (clk_i),
        .reset  (~reset_n_i),

        .ena    (trace_en2),
        .wea    ({((TRACEMEM_DATAWIDTH+7)/8){1'b1}}),
        .addra  (trace_addr1),
        .dina   (r_trace_wdata),

        .enb    (trace_mem_en_i),
        .addrb  (trace_mem_addr),
        .doutb  (trace_mem_rdata2)
    );


endmodule
