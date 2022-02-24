
module noc_arq_2to1mux #(
    `include "noc_parameter.vh"
)(
    input  wire                        clk_i,
    input  wire                        reset_q_i,

    //input 1 (has prio over input 2)
    input  wire                        wrreq1_i,
    input  wire  [NOC_HEADER_SIZE-1:0] header1_i,
    input  wire [NOC_PAYLOAD_SIZE-1:0] payload1_i,
    output wire                        stall1_o,

    //input 2
    input  wire                        wrreq2_i,
    input  wire  [NOC_HEADER_SIZE-1:0] header2_i,
    input  wire [NOC_PAYLOAD_SIZE-1:0] payload2_i,
    output wire                        stall2_o,

    //output
    output reg                         wrreq_o,
    output reg   [NOC_HEADER_SIZE-1:0] header_o,
    output reg  [NOC_PAYLOAD_SIZE-1:0] payload_o,
    input  wire                        stall_i
);

    localparam IN0 = 2'h0;
    localparam IN1 = 2'h1;
    localparam IN2 = 2'h2;

    reg  [1:0] r_arbiter_result, rin_arbiter_result;
    reg        r_burst_active, rin_burst_active;
    reg        stall1;
    reg        stall2;

    wire noc_burst_out = header_o[NOC_HEADER_SIZE-1];
    


    always @(posedge clk_i or negedge reset_q_i) begin
        if (reset_q_i == 1'b0) begin
            r_arbiter_result <= IN0;
            r_burst_active <= 1'b0;
        end
        else begin
            r_arbiter_result <= rin_arbiter_result;
            r_burst_active <= rin_burst_active;
        end
    end


    //select input
    always @* begin
        rin_arbiter_result = r_arbiter_result;
        stall1 = 1'b0;
        stall2 = 1'b0;

        //only change arbiter when there is no burst ongoing
        if (!r_burst_active) begin
            if (wrreq1_i) begin
                rin_arbiter_result = IN1;
                stall2 = 1'b1;
            end
            else if (wrreq2_i) begin
                rin_arbiter_result = IN2;
            end
            else begin
                rin_arbiter_result = IN0;
            end
        end

        //keep stall when burst is active
        else if (r_arbiter_result == IN1) begin
            stall2 = 1'b1;
        end
        else if (r_arbiter_result == IN2) begin
            stall1 = 1'b1;
        end
    end


    //set output
    always @* begin
        case(rin_arbiter_result)
            IN1: begin
                wrreq_o = wrreq1_i;
                header_o = header1_i;
                payload_o = payload1_i;
            end

            IN2: begin
                wrreq_o = wrreq2_i;
                header_o = header2_i;
                payload_o = payload2_i;
            end

            default: begin
                wrreq_o = 1'b0;
                header_o = {NOC_HEADER_SIZE{1'b0}};
                payload_o = {NOC_PAYLOAD_SIZE{1'b0}};
            end
        endcase
    end


    //check if burst
    always @* begin
        rin_burst_active = r_burst_active;
        if (!stall_i && wrreq_o) begin
            if (noc_burst_out) begin
                rin_burst_active = 1'b1; //on during burst
            end else begin
                rin_burst_active = 1'b0; //off when last flit
            end
        end
    end

    assign stall1_o = stall_i || stall1;
    assign stall2_o = stall_i || stall2;


endmodule



module noc_arq_1to2mux #(
    `include "noc_parameter.vh"
)(
    input  wire                        clk_i,
    input  wire                        reset_q_i,

    //input
    input  wire                        wrreq_i,
    input  wire  [NOC_HEADER_SIZE-1:0] header_i,
    input  wire [NOC_PAYLOAD_SIZE-1:0] payload_i,
    output reg                         stall_o,

    //output 1 (for ACKs)
    output reg                         ack_wrreq_o,
    output reg   [NOC_HEADER_SIZE-1:0] ack_header_o,
    output reg  [NOC_PAYLOAD_SIZE-1:0] ack_payload_o,
    input  wire                        ack_stall_i,

    //output 2
    output reg                         wrreq_o,
    output reg   [NOC_HEADER_SIZE-1:0] header_o,
    output reg  [NOC_PAYLOAD_SIZE-1:0] payload_o,
    input  wire                        stall_i
);

    localparam OUT0 = 2'h0;
    localparam OUT1 = 2'h1;
    localparam OUT2 = 2'h2;

    reg  [1:0] r_arbiter_result, rin_arbiter_result;
    reg        r_burst_active, rin_burst_active;

    wire                     noc_burst_in = header_i[NOC_HEADER_SIZE-1];
    wire [NOC_MODE_SIZE-1:0] noc_mode_in = payload_i[NOC_PAYLOAD_SIZE-1:NOC_PAYLOAD_SIZE-NOC_MODE_SIZE];
    


    always @(posedge clk_i or negedge reset_q_i) begin
        if (reset_q_i == 1'b0) begin
            r_arbiter_result <= OUT0;
            r_burst_active <= 1'b0;
        end
        else begin
            r_arbiter_result <= rin_arbiter_result;
            r_burst_active <= rin_burst_active;
        end
    end


    //select output
    always @* begin
        rin_arbiter_result = r_arbiter_result;

        //only change arbiter when there is no burst ongoing
        if (!r_burst_active) begin
            if (wrreq_i) begin
                if (noc_mode_in == MODE_ARQ_ACK) begin
                    rin_arbiter_result = OUT1;
                end else begin
                    rin_arbiter_result = OUT2;
                end
            end
            else begin
                rin_arbiter_result = OUT0;
            end
        end
    end


    //set output
    always @* begin
        case(rin_arbiter_result)
            OUT1: begin
                ack_wrreq_o = wrreq_i;
                ack_header_o = header_i;
                ack_payload_o = payload_i;

                wrreq_o = 1'b0;
                header_o = {NOC_HEADER_SIZE{1'b0}};
                payload_o = {NOC_PAYLOAD_SIZE{1'b0}};

                stall_o = ack_stall_i;
            end

            OUT2: begin
                ack_wrreq_o = 1'b0;
                ack_header_o = {NOC_HEADER_SIZE{1'b0}};
                ack_payload_o = {NOC_PAYLOAD_SIZE{1'b0}};

                wrreq_o = wrreq_i;
                header_o = header_i;
                payload_o = payload_i;

                stall_o = stall_i;
            end

            default: begin
                ack_wrreq_o = 1'b0;
                ack_header_o = {NOC_HEADER_SIZE{1'b0}};
                ack_payload_o = {NOC_PAYLOAD_SIZE{1'b0}};

                wrreq_o = 1'b0;
                header_o = {NOC_HEADER_SIZE{1'b0}};
                payload_o = {NOC_PAYLOAD_SIZE{1'b0}};

                stall_o = 1'b1;
            end
        endcase
    end


    //check if burst
    always @* begin
        rin_burst_active = r_burst_active;
        if (!stall_o && wrreq_i) begin
            if (noc_burst_in) begin
                rin_burst_active = 1'b1; //on during burst
            end else begin
                rin_burst_active = 1'b0; //off when last flit
            end
        end
    end


endmodule
