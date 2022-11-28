
module ethernet_fmc_rocket_trace #(
    parameter ROCKET_TRACE_BASEADDR = 32'h00100000,
    parameter ROCKET_TRACE_SIZE     = 'h8000,  //1024 traces * 32 bytes per row
    parameter ROCKET_MEM_DATA_SIZE  = 128,
    parameter ROCKET_MEM_ADDR_SIZE  = 32
)(
    input  wire                            clk_i,
    input  wire                            reset_n_i,

    //settings from regfile
    input  wire                            trace_enabled_i,
    output wire [ROCKET_MEM_ADDR_SIZE-1:0] trace_ptr_o,
    output wire [ROCKET_MEM_ADDR_SIZE-1:0] trace_count_o,

    //trace interface
    input  wire                            trace_valid,
    input  wire                     [39:0] trace_iaddr,
    input  wire                     [31:0] trace_insn,
    input  wire                      [2:0] trace_priv,
    input  wire                            trace_exception,
    input  wire                            trace_interrupt,
    input  wire                     [63:0] trace_cause,
    input  wire                     [39:0] trace_tval,

    //memory interface
    input  wire                            trace_mem_en_i,
    input  wire [ROCKET_MEM_ADDR_SIZE-1:0] trace_mem_addr_i,
    output wire [ROCKET_MEM_DATA_SIZE-1:0] trace_mem_rdata_o
);

    
    localparam TRACEMEM_DATAWIDTH              = 32+32+3+1+1+64+40;  //173
    localparam TRACEMEM_DATAWIDTH_EXT          = 256;                //extended to next power of 2
    localparam TRACEMEM_DATAWIDTH_BYTE_EXT     = TRACEMEM_DATAWIDTH_EXT >> 3;    //in bytes
    localparam TRACEMEM_DATAWIDTH_BYTE_EXT_LOG = $clog2(TRACEMEM_DATAWIDTH_BYTE_EXT);
    localparam TRACEMEM_ADDRWIDTH              = $clog2(ROCKET_TRACE_SIZE/TRACEMEM_DATAWIDTH_BYTE_EXT);   //2^10 traces
    


    reg                             r_trace_en;
    reg    [TRACEMEM_ADDRWIDTH-1:0] r_trace_addr, rin_trace_addr;
    reg    [TRACEMEM_DATAWIDTH-1:0] r_trace_wdata;
    reg      [TRACEMEM_ADDRWIDTH:0] r_trace_count, rin_trace_count;

    reg                             r_trace_enabled;

    wire [ROCKET_MEM_ADDR_SIZE-1:0] trace_mem_addr_offset = trace_mem_addr_i - ROCKET_TRACE_BASEADDR;             //subtrace offset
    wire   [TRACEMEM_ADDRWIDTH-1:0] trace_mem_addr = trace_mem_addr_offset >> TRACEMEM_DATAWIDTH_BYTE_EXT_LOG;    //shift by 5 due to 256-bit rows

    reg                             r_trace_mem_addr_bsel;
    wire                            trace_mem_addr_bsel = trace_mem_addr_offset[TRACEMEM_DATAWIDTH_BYTE_EXT_LOG-1];  //if offset indicates upper half, shift read data
    wire   [TRACEMEM_DATAWIDTH-1:0] trace_mem_rdata;


    //only write trace to mem if something has changed
    wire [TRACEMEM_DATAWIDTH-1:0] trace_data = {trace_tval, trace_cause, trace_interrupt, trace_exception, trace_priv, trace_insn, trace_iaddr[31:0]};
    wire                          trace_data_new = (trace_data == r_trace_wdata) ? 1'b0 : 1'b1;
    wire                          trace_en = trace_valid && trace_data_new && trace_enabled_i;


    //shift mem output according to adress offset
    assign trace_mem_rdata_o = r_trace_mem_addr_bsel ?
                                {{(2*ROCKET_MEM_DATA_SIZE-TRACEMEM_DATAWIDTH){1'b0}}, trace_mem_rdata[TRACEMEM_DATAWIDTH-1:ROCKET_MEM_DATA_SIZE]} :
                                trace_mem_rdata[ROCKET_MEM_DATA_SIZE-1:0];


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

            r_trace_mem_addr_bsel <= 1'b0;
        end
        else begin
            r_trace_en <= trace_en;
            r_trace_addr <= rin_trace_addr;
            r_trace_wdata <= trace_data;
            r_trace_count <= rin_trace_count;

            r_trace_enabled <= trace_enabled_i;

            r_trace_mem_addr_bsel <= trace_mem_addr_bsel;
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
        .MEM_ADDRWIDTH (TRACEMEM_ADDRWIDTH)
    ) i_rocket_trace_mem (
        .clk    (clk_i),
        .reset  (~reset_n_i),

        .ena    (r_trace_en),
        .wea    ({((TRACEMEM_DATAWIDTH+7)/8){1'b1}}),
        .addra  (r_trace_addr),
        .dina   (r_trace_wdata),

        .enb    (trace_mem_en_i),
        .addrb  (trace_mem_addr),
        .doutb  (trace_mem_rdata)
    );


endmodule
