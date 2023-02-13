
module tcu_priv_tlb #(
    `include "tcu_parameter.vh"
    ,parameter TLB_DEPTH          = 32, //if changed, code below must be adapted
    parameter TCU_ENABLE_VIRT_PES = 0
)(
    input  wire                          clk_i,
    input  wire                          reset_n_i,

    input  wire                          tcu_features_virt_pes_i,

    input  wire                          tlb_en_i,
    input  wire   [TCU_TLB_CMD_SIZE-1:0] tlb_cmd_i,
    input  wire  [TCU_TLB_DATA_SIZE-1:0] tlb_wdata_i,   //wdata comes from reg
    output wire  [TCU_TLB_DATA_SIZE-1:0] tlb_rdata_o,   //rdata is valid when done=1
    output wire                          tlb_active_o,
    output wire                          tlb_done_o,
    output wire     [TCU_ERROR_SIZE-1:0] tlb_error_o
);

    localparam TLB_ADDR_WIDTH = $clog2(TLB_DEPTH);

    localparam TLB_STATES_SIZE       = 4;
    localparam S_TLB_IDLE            = 4'h0;
    localparam S_TLB_WRITE_START     = 4'h1;
    localparam S_TLB_WRITE_CHECK     = 4'h2;
    localparam S_TLB_WRITE_NEW       = 4'h3;
    localparam S_TLB_WRITE_OCCUP     = 4'h4;
    localparam S_TLB_WRITE_OVERWRITE = 4'h5;
    localparam S_TLB_READ_START      = 4'h6;
    localparam S_TLB_READ_CHECK      = 4'h7;
    localparam S_TLB_DEL_START       = 4'h8;
    localparam S_TLB_DEL_CHECK       = 4'h9;
    localparam S_TLB_DEL_REMOVE      = 4'hA;
    localparam S_TLB_CLEAR_START     = 4'hB;
    localparam S_TLB_CLEAR_CHECK     = 4'hC;
    localparam S_TLB_CLEAR_REMOVE    = 4'hD;
    localparam S_TLB_FINISH          = 4'hF;

    reg [TLB_STATES_SIZE-1:0] tlb_state, next_tlb_state;

    //function to count trailing zeros of 8-bit value
    function automatic [3:0] ctz8;
        input [7:0] data;
        begin
            casex(data)
                8'bxxxx_xxx1: ctz8 = 3'd0;
                8'bxxxx_xx10: ctz8 = 3'd1;
                8'bxxxx_x100: ctz8 = 3'd2;
                8'bxxxx_1000: ctz8 = 3'd3;
                8'bxxx1_0000: ctz8 = 3'd4;
                8'bxx10_0000: ctz8 = 3'd5;
                8'bx100_0000: ctz8 = 3'd6;
                8'b1000_0000: ctz8 = 3'd7;
                default: ctz8 = 8'd8;
            endcase
        end
    endfunction

    //function to count leading zeros of 8-bit value
    function automatic [3:0] clz8;
        input [7:0] data;
        begin
            casex(data)
                8'b1xxx_xxxx: clz8 = 3'd0;
                8'b01xx_xxxx: clz8 = 3'd1;
                8'b001x_xxxx: clz8 = 3'd2;
                8'b0001_xxxx: clz8 = 3'd3;
                8'b0000_1xxx: clz8 = 3'd4;
                8'b0000_01xx: clz8 = 3'd5;
                8'b0000_001x: clz8 = 3'd6;
                8'b0000_0001: clz8 = 3'd7;
                default: clz8 = 8'd8;
            endcase
        end
    endfunction


    //hold already used entries in reg (todo: store permission flags in reg and use them instead)
    reg [TLB_DEPTH-1:0] r_tlb_valid_entry, rin_tlb_valid_entry;

    reg    [TLB_ADDR_WIDTH-1:0] r_tlb_mem_addr, rin_tlb_mem_addr;
    reg [TCU_TLB_DATA_SIZE-1:0] r_tlb_mem_rdata, rin_tlb_mem_rdata;

    reg [TLB_ADDR_WIDTH-1:0] first_valid_entry;
    reg [TLB_ADDR_WIDTH-1:0] last_valid_entry;

    reg r2_tlb_valid_entry_bit;

    reg tlb_mem_en;
    reg tlb_mem_we;

    //error code
    reg [TCU_ERROR_SIZE-1:0] r_tlb_error, rin_tlb_error;


    //split TLB data (input wire comes from reg which keeps data)
    wire    [TCU_TLB_VPEID_SIZE-1:0] tlb_wdata_vpeid    = tlb_wdata_i[TCU_TLB_VPEID_SIZE-1 : 0];
    wire [TCU_TLB_VIRTPAGE_SIZE-1:0] tlb_wdata_virtpage = tlb_wdata_i[TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE-1 : TCU_TLB_VPEID_SIZE];
    wire [TCU_TLB_PHYSPAGE_SIZE-1:0] tlb_wdata_physpage = tlb_wdata_i[TCU_TLB_PHYSPAGE_SIZE+TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE-1 : TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE];
    wire     [TCU_TLB_PERM_SIZE-1:0] tlb_wdata_perm     = tlb_wdata_i[TCU_TLB_PERM_SIZE+TCU_TLB_PHYSPAGE_SIZE+TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE-1 : TCU_TLB_PHYSPAGE_SIZE+TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE];


    wire [TCU_TLB_DATA_SIZE-1:0] tlb_mem_rdata;

    wire    [TCU_TLB_VPEID_SIZE-1:0] tlb_rdata_vpeid    = tlb_mem_rdata[TCU_TLB_VPEID_SIZE-1 : 0];
    wire [TCU_TLB_VIRTPAGE_SIZE-1:0] tlb_rdata_virtpage = tlb_mem_rdata[TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE-1 : TCU_TLB_VPEID_SIZE];
    wire [TCU_TLB_PHYSPAGE_SIZE-1:0] tlb_rdata_physpage = tlb_mem_rdata[TCU_TLB_PHYSPAGE_SIZE+TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE-1 : TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE];
    wire     [TCU_TLB_PERM_SIZE-1:0] tlb_rdata_perm     = tlb_mem_rdata[TCU_TLB_PERM_SIZE+TCU_TLB_PHYSPAGE_SIZE+TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE-1 : TCU_TLB_PHYSPAGE_SIZE+TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE];


    wire tlb_empty = !r_tlb_valid_entry;

    wire [TLB_ADDR_WIDTH-1:0] last_valid_entry_incr = last_valid_entry + 1;

    wire [3:0] ctz_valid_entry_0 = ctz8(r_tlb_valid_entry[ 7: 0]);
    wire [3:0] ctz_valid_entry_1 = ctz8(r_tlb_valid_entry[15: 8]);
    wire [3:0] ctz_valid_entry_2 = ctz8(r_tlb_valid_entry[23:16]);
    wire [3:0] ctz_valid_entry_3 = ctz8(r_tlb_valid_entry[31:24]);

    wire [3:0] clz_valid_entry_0 = clz8(r_tlb_valid_entry[ 7: 0]);
    wire [3:0] clz_valid_entry_1 = clz8(r_tlb_valid_entry[15: 8]);
    wire [3:0] clz_valid_entry_2 = clz8(r_tlb_valid_entry[23:16]);
    wire [3:0] clz_valid_entry_3 = clz8(r_tlb_valid_entry[31:24]);



    //synopsys sync_set_reset "reset_n_i"
    always @(posedge clk_i) begin
        if (reset_n_i == 1'b0) begin
            tlb_state <= S_TLB_IDLE;

            r_tlb_valid_entry <= {TLB_DEPTH{1'b0}};
            r2_tlb_valid_entry_bit <= 1'b0;

            r_tlb_mem_addr <= {TLB_ADDR_WIDTH{1'b0}};
            r_tlb_mem_rdata <= {TCU_TLB_DATA_SIZE{1'b0}};

            r_tlb_error <= TCU_ERROR_NONE;
        end
        else begin
            tlb_state <= next_tlb_state;

            r_tlb_valid_entry <= rin_tlb_valid_entry;
            r2_tlb_valid_entry_bit <= r_tlb_valid_entry[r_tlb_mem_addr];

            r_tlb_mem_addr <= rin_tlb_mem_addr;
            r_tlb_mem_rdata <= rin_tlb_mem_rdata;

            r_tlb_error <= rin_tlb_error;
        end
    end



    //find first valid entry in TLB
    //if TLB is empty, first_valid_entry=0
    always @* begin
        //if it is <8, first 1 is in first 8 bits
        if (!ctz_valid_entry_0[3]) begin
            first_valid_entry = ctz_valid_entry_0[2:0];
        end
        else if (!ctz_valid_entry_1[3]) begin
            first_valid_entry = {1'b1, ctz_valid_entry_1[2:0]};
        end
        else if (!ctz_valid_entry_2[3]) begin
            first_valid_entry = {2'h2, ctz_valid_entry_2[2:0]};
        end
        else if (!ctz_valid_entry_3[3]) begin
            first_valid_entry = {2'h3, ctz_valid_entry_3[2:0]};
        end
        else begin
            first_valid_entry = {TLB_ADDR_WIDTH{1'b0}};
        end
    end

    //find last valid entry in TLB
    //if TLB is empty, last_valid_entry=0
    always @* begin
        //if it is <8, first 1 is in last 8 bits
        if (!clz_valid_entry_3[3]) begin
            last_valid_entry = TLB_DEPTH - clz_valid_entry_3[2:0] - 1;
        end
        else if (!clz_valid_entry_2[3]) begin
            last_valid_entry = TLB_DEPTH - {1'b1, clz_valid_entry_2[2:0]} - 1;
        end
        else if (!clz_valid_entry_1[3]) begin
            last_valid_entry = TLB_DEPTH - {2'h2, clz_valid_entry_1[2:0]} - 1;
        end
        else if (!clz_valid_entry_0[3]) begin
            last_valid_entry = TLB_DEPTH - {2'h3, clz_valid_entry_0[2:0]} - 1;
        end
        else begin
            last_valid_entry = {TLB_ADDR_WIDTH{1'b0}};
        end
    end



    //---------------
    //state machine
    always @* begin
        next_tlb_state = tlb_state;

        rin_tlb_valid_entry = r_tlb_valid_entry;

        rin_tlb_mem_addr = r_tlb_mem_addr;
        rin_tlb_mem_rdata = {TCU_TLB_DATA_SIZE{1'b0}};

        tlb_mem_en = 1'b0;
        tlb_mem_we = 1'b0;

        rin_tlb_error = r_tlb_error;


        case(tlb_state)

            S_TLB_IDLE: begin
                if (tlb_en_i) begin
                    rin_tlb_error = TCU_ERROR_NONE;

                    case(tlb_cmd_i)
                        TCU_TLB_CMD_WRITE_ENTRY: begin
                            if (tlb_empty) begin
                                rin_tlb_mem_addr = {TLB_ADDR_WIDTH{1'b0}};
                                next_tlb_state = S_TLB_WRITE_OVERWRITE;
                            end else begin
                                rin_tlb_mem_addr = first_valid_entry;
                                next_tlb_state = S_TLB_WRITE_START;
                            end
                        end

                        TCU_TLB_CMD_READ_ENTRY: begin
                            rin_tlb_mem_addr = last_valid_entry;
                            next_tlb_state = S_TLB_READ_START;
                        end

                        TCU_TLB_CMD_DEL_ENTRY: begin
                            rin_tlb_mem_addr = last_valid_entry;
                            next_tlb_state = S_TLB_DEL_START;
                        end

                        TCU_TLB_CMD_CLEAR: begin
                            rin_tlb_mem_addr = first_valid_entry;
                            next_tlb_state = S_TLB_CLEAR_START;
                        end
                    endcase
                end
            end


            //---------------
            //create new entry
            S_TLB_WRITE_START: begin
                tlb_mem_en = 1'b1;
                rin_tlb_mem_addr = r_tlb_mem_addr + 1;
                next_tlb_state = S_TLB_WRITE_CHECK;
            end

            //check if there is already an entry with this virt. page
            S_TLB_WRITE_CHECK: begin
                //only load next entry if there is one
                if (r_tlb_valid_entry[r_tlb_mem_addr]) begin
                    tlb_mem_en = 1'b1;
                end

                //check vpeid and virt addr
                if (r2_tlb_valid_entry_bit &&
                    (!(TCU_ENABLE_VIRT_PES && tcu_features_virt_pes_i) || (tlb_rdata_vpeid == tlb_wdata_vpeid)) &&
                    (tlb_rdata_virtpage == tlb_wdata_virtpage)) begin
                    //TLB hit - update entry
                    rin_tlb_mem_addr = r_tlb_mem_addr - 1;    //decr because we already incr the addr
                    next_tlb_state = S_TLB_WRITE_OVERWRITE;
                end

                //check next entry within range of valid entries
                //first valid entry is always checked first, this stops wrapping around
                else if ((r_tlb_mem_addr > first_valid_entry) && (r_tlb_mem_addr <= last_valid_entry)) begin
                    rin_tlb_mem_addr = r_tlb_mem_addr + 1;
                end

                //entry not found, create new one
                else begin
                    rin_tlb_mem_addr = last_valid_entry_incr;
                    next_tlb_state = S_TLB_WRITE_NEW;
                end
            end

            S_TLB_WRITE_NEW: begin
                tlb_mem_en = 1'b1;

                //start with the (most likely) first free entry in TLB
                if (!r_tlb_valid_entry[r_tlb_mem_addr]) begin
                    tlb_mem_we = 1'b1;
                    rin_tlb_valid_entry[r_tlb_mem_addr] = 1'b1;
                    next_tlb_state = S_TLB_FINISH;
                end

                //entry is not free, check if we can evict it
                else begin
                    rin_tlb_mem_addr = r_tlb_mem_addr + 1;
                    next_tlb_state = S_TLB_WRITE_OCCUP;
                end
            end

            S_TLB_WRITE_OCCUP: begin
                //already read next entry in case we need it
                tlb_mem_en = 1'b1;

                //FIXED bit is set
                if (tlb_rdata_perm[TCU_TLB_PERM_SIZE-1]) begin
                    //look for next entry if we are not already wrapped around
                    if (r_tlb_mem_addr == last_valid_entry_incr) begin
                        rin_tlb_error = TCU_ERROR_TLB_FULL;
                        next_tlb_state = S_TLB_FINISH;
                    end

                    //there is a next entry, check FIXED bit for that entry
                    else if (r_tlb_valid_entry[r_tlb_mem_addr]) begin
                        rin_tlb_mem_addr = r_tlb_mem_addr + 1;
                    end

                    //next entry is free, use that
                    else begin
                        next_tlb_state = S_TLB_WRITE_OVERWRITE;
                    end
                end

                //can be evicted
                else begin
                    rin_tlb_mem_addr = r_tlb_mem_addr - 1;    //decr because we already incr the addr
                    next_tlb_state = S_TLB_WRITE_OVERWRITE;
                end
            end

            S_TLB_WRITE_OVERWRITE: begin
                tlb_mem_en = 1'b1;
                tlb_mem_we = 1'b1;
                rin_tlb_valid_entry[r_tlb_mem_addr] = 1'b1;
                next_tlb_state = S_TLB_FINISH;
            end


            //---------------
            //read an entry
            S_TLB_READ_START: begin
                tlb_mem_en = 1'b1;

                //read if there is an entry at last valid entry
                if (r_tlb_valid_entry[r_tlb_mem_addr]) begin
                    rin_tlb_mem_addr = r_tlb_mem_addr - 1;
                    next_tlb_state = S_TLB_READ_CHECK;
                end

                //TLB miss, if there is no entry at last valid entry
                else begin
                    rin_tlb_error = TCU_ERROR_TLB_MISS;
                    next_tlb_state = S_TLB_FINISH;
                end
            end

            //check if this the entry we are looking for
            S_TLB_READ_CHECK: begin
                rin_tlb_mem_rdata = tlb_mem_rdata;

                //only load next entry if there is one
                if (r_tlb_valid_entry[r_tlb_mem_addr]) begin
                    tlb_mem_en = 1'b1;
                end

                //check vpeid and virt addr
                if (r2_tlb_valid_entry_bit &&
                    (!(TCU_ENABLE_VIRT_PES && tcu_features_virt_pes_i) || (tlb_rdata_vpeid == tlb_wdata_vpeid)) &&
                    (tlb_rdata_virtpage == tlb_wdata_virtpage)) begin

                    //check permission bits (only r+w)
                    if (tlb_rdata_perm[1:0] & tlb_wdata_perm[1:0]) begin
                        //TLB hit - read entry
                        next_tlb_state = S_TLB_FINISH;
                    end

                    //no permission
                    else begin
                        rin_tlb_error = TCU_ERROR_NO_PERM;
                        next_tlb_state = S_TLB_FINISH;
                    end
                end

                //no hit, check next entry ahead which must be within range of valid entries
                else if ((r_tlb_mem_addr >= first_valid_entry) && (r_tlb_mem_addr < last_valid_entry)) begin
                    rin_tlb_mem_addr = r_tlb_mem_addr - 1;
                end

                //TLB miss, no hit and no other entry
                else begin
                    rin_tlb_error = TCU_ERROR_TLB_MISS;
                    next_tlb_state = S_TLB_FINISH;
                end
            end


            //---------------
            //remove an entry
            S_TLB_DEL_START: begin
                tlb_mem_en = 1'b1;

                //remove if there is an entry at last valid entry
                if (r_tlb_valid_entry[r_tlb_mem_addr]) begin
                    rin_tlb_mem_addr = r_tlb_mem_addr - 1;
                    next_tlb_state = S_TLB_DEL_CHECK;
                end

                //no entry to remove
                else begin
                    rin_tlb_error = TCU_ERROR_TLB_MISS;
                    next_tlb_state = S_TLB_FINISH;
                end
            end

            //check if this the entry we are looking for
            S_TLB_DEL_CHECK: begin
                //only load entry if there is one
                if (r_tlb_valid_entry[r_tlb_mem_addr]) begin
                    tlb_mem_en = 1'b1;
                end

                //check vpeid, virt addr
                if (r2_tlb_valid_entry_bit &&
                    (!(TCU_ENABLE_VIRT_PES && tcu_features_virt_pes_i) || (tlb_rdata_vpeid == tlb_wdata_vpeid)) &&
                    (tlb_rdata_virtpage == tlb_wdata_virtpage)) begin
                    //TLB hit - remove entry
                    rin_tlb_mem_addr = r_tlb_mem_addr + 1;  //incr again because we decr it already
                    next_tlb_state = S_TLB_DEL_REMOVE;
                end

                //no hit, check next entry ahead within range of valid entries
                else if ((r_tlb_mem_addr >= first_valid_entry) && (r_tlb_mem_addr < last_valid_entry)) begin
                    rin_tlb_mem_addr = r_tlb_mem_addr - 1;
                end

                //no entry to remove
                else begin
                    rin_tlb_error = TCU_ERROR_TLB_MISS;
                    next_tlb_state = S_TLB_FINISH;
                end
            end

            S_TLB_DEL_REMOVE: begin
                rin_tlb_valid_entry[r_tlb_mem_addr] = 1'b0;
                next_tlb_state = S_TLB_FINISH;
            end


            //---------------
            //clear TLB: delete TLB except entries marked as FIXED
            S_TLB_CLEAR_START: begin
                tlb_mem_en = 1'b1;
                rin_tlb_mem_addr = r_tlb_mem_addr + 1;
                next_tlb_state = S_TLB_CLEAR_CHECK;
            end

            //check if this entry can be evicted
            S_TLB_CLEAR_CHECK: begin
                //only load next entry if there is one
                if (r_tlb_valid_entry[r_tlb_mem_addr]) begin
                    tlb_mem_en = 1'b1;
                end

                //remove entry if FIXED bit is not set
                if (r2_tlb_valid_entry_bit && !tlb_rdata_perm[TCU_TLB_PERM_SIZE-1]) begin
                    rin_tlb_mem_addr = r_tlb_mem_addr - 1;  //decr again because we incr it already
                    next_tlb_state = S_TLB_CLEAR_REMOVE;
                end

                //check next entry within range of valid entries
                else if ((r_tlb_mem_addr >= first_valid_entry) && (r_tlb_mem_addr < last_valid_entry)) begin
                    rin_tlb_mem_addr = r_tlb_mem_addr + 1;
                end

                //no entry to remove anymore
                else begin
                    next_tlb_state = S_TLB_FINISH;
                end
            end

            S_TLB_CLEAR_REMOVE: begin
                rin_tlb_mem_addr = r_tlb_mem_addr + 1;
                rin_tlb_valid_entry[r_tlb_mem_addr] = 1'b0;
                next_tlb_state = S_TLB_CLEAR_START;
            end

            //---------------
            S_TLB_FINISH: begin
                next_tlb_state = S_TLB_IDLE;
            end

            //---------------
            default: next_tlb_state = tlb_state;
        endcase
    end


    assign tlb_rdata_o = r_tlb_mem_rdata;
    assign tlb_active_o = (tlb_state != S_TLB_IDLE);
    assign tlb_done_o = (tlb_state == S_TLB_FINISH);
    assign tlb_error_o = r_tlb_error;


    mem_sp_wrap #(
        .MEM_TYPE("distributed"),
        .MEM_DATAWIDTH(TCU_TLB_DATA_SIZE),
        .MEM_ADDRWIDTH(TLB_ADDR_WIDTH)
    ) tlb_mem (
        .clk    (clk_i),
        .reset  (~reset_n_i),
        .en     (tlb_mem_en),
        .we     ({((TCU_TLB_DATA_SIZE+7)/8){tlb_mem_we}}),
        .addr   (r_tlb_mem_addr),
        .din    (tlb_wdata_i),
        .dout   (tlb_mem_rdata)
    );



endmodule
