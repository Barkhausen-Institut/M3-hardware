
module tcu_priv_timer #(
    parameter TIMER_SIZE  = 32,
    parameter CLKFREQ_MHZ = 100
)(
    input  wire                     clk_i,
    input  wire                     reset_n_i,

    input  wire                     timer_value_valid_i,
    input  wire    [TIMER_SIZE-1:0] timer_value_i,

    input  wire                     timer_int_stall_i,
    output reg                      timer_int_valid_o  //trigger interrupt when not stalled
);

    localparam TIMER_FACTOR = 1000/CLKFREQ_MHZ;

    localparam TIMER_STATES_SIZE = 2;
    localparam S_TIMER_CTRL_IDLE = 2'h0;
    localparam S_TIMER_CTRL_RUN  = 2'h1;
    localparam S_TIMER_CTRL_STOP = 2'h2;

    reg [TIMER_STATES_SIZE-1:0] timer_ctrl_state, next_timer_ctrl_state;


    //timer in ns
    reg [TIMER_SIZE-1:0] r_timer, rin_timer;


    //time [ns] = cycles * 1000 / freq [MHz]
    wire [TIMER_SIZE-1:0] timer_incr = {{(TIMER_SIZE-1){1'b0}}, 1'b1} * TIMER_FACTOR;



    //synopsys sync_set_reset "reset_n_i"
    always @(posedge clk_i) begin
        if (reset_n_i == 1'b0) begin
            timer_ctrl_state <= S_TIMER_CTRL_IDLE;
            r_timer <= {TIMER_SIZE{1'b0}};
        end
        else begin
            timer_ctrl_state <= next_timer_ctrl_state;
            r_timer <= rin_timer;
        end
    end



    //---------------
    //state machine to trigger timer
    always @* begin
        next_timer_ctrl_state = timer_ctrl_state;

        rin_timer = r_timer;
        timer_int_valid_o = 1'b0;

        case (timer_ctrl_state)

            S_TIMER_CTRL_IDLE: begin
                if (timer_value_valid_i && (timer_value_i != {TIMER_SIZE{1'b0}})) begin
                    //set timer
                    rin_timer = timer_value_i;
                    next_timer_ctrl_state = S_TIMER_CTRL_RUN;
                end
            end

            S_TIMER_CTRL_RUN: begin
                //stop when timer is unset, or reset it with new value
                if (timer_value_valid_i) begin
                    if (timer_value_i == {TIMER_SIZE{1'b0}}) begin
                        next_timer_ctrl_state = S_TIMER_CTRL_IDLE;
                    end else begin
                        rin_timer = timer_value_i;
                    end
                end

                //otherwise count down
                else if (r_timer > timer_incr) begin
                    rin_timer = r_timer - timer_incr;
                end else begin
                    next_timer_ctrl_state = S_TIMER_CTRL_STOP;
                end
            end

            S_TIMER_CTRL_STOP: begin
                //time is over
                timer_int_valid_o = 1'b1;

                if (!timer_int_stall_i) begin
                    next_timer_ctrl_state = S_TIMER_CTRL_IDLE;
                end
            end

            default: begin
                next_timer_ctrl_state = S_TIMER_CTRL_IDLE;
            end
        endcase
    end


endmodule
