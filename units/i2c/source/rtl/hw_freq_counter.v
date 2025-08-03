`timescale 1ps/1ps

module hw_freq_counter #(
    parameter REF_CYCLES      = 1000,
    parameter COUNTER_WIDTH   = 12
)(
    // --- Reference Clock Domain ---
    input                       ref_clk_i,
    input                       rst_n_i,
    input                       trigger_i,

    // --- Clock-Under-Test Domain ---
    input                       clk_to_measure_i,

    // --- Outputs ---
    output reg [COUNTER_WIDTH-1:0] count_result_o,
    output reg                  measurement_done_o
);

    // Internal State Machine (in ref_clk domain)
    reg [1:0] state = 0;
    localparam S_IDLE    = 2'b00;
    localparam S_RUNNING = 2'b01;
    localparam S_DONE    = 2'b10;

    // Counter for the reference clock
    reg [COUNTER_WIDTH-1:0] ref_counter;

    // Control signal to be passed to the other clock domain
    reg measurement_active_ref;

    // ** CDC Synchronizer **
    // Safely passes the 'measurement_active' signal from the ref_clk domain
    // to the clk_to_measure domain.
    reg measurement_active_sync1;
    reg measurement_active_sync2;

    // Counter for the clock-under-test
    reg [COUNTER_WIDTH-1:0] clk_to_measure_counter;

    // State machine and reference counter logic (all in ref_clk domain)
    always @(posedge ref_clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            state <= S_IDLE;
            ref_counter <= 0;
            measurement_active_ref <= 1'b0;
            measurement_done_o <= 1'b0;
            count_result_o <= 0;
        end else begin
            measurement_done_o <= 1'b0; // Default to low, pulse for one cycle
            case (state)
                S_IDLE: begin
                    if (trigger_i) begin
                        ref_counter <= 0;
                        measurement_active_ref <= 1'b1;
                        state <= S_RUNNING;
                    end
                end
                S_RUNNING: begin
                    if (ref_counter == REF_CYCLES - 1) begin
                        measurement_active_ref <= 1'b0; // Stop counting
                        state <= S_DONE;
                    end else begin
                        ref_counter <= ref_counter + 1;
                    end
                end
                S_DONE: begin
                    // Latch the final count and signal that we are done
                    count_result_o <= clk_to_measure_counter;
                    measurement_done_o <= 1'b1;
                    state <= S_IDLE; // Ready for another trigger
                end
                default: state <= S_IDLE;
            endcase
        end
    end

    // Clock-under-test counter logic (all in clk_to_measure domain)
    always @(posedge clk_to_measure_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            measurement_active_sync1 <= 1'b0;
            measurement_active_sync2 <= 1'b0;
            clk_to_measure_counter <= 0;
        end else begin
            // 2-Flop Synchronizer for the start/stop signal
            measurement_active_sync1 <= measurement_active_ref;
            measurement_active_sync2 <= measurement_active_sync1;

            // Only count when the synchronized control signal is active
            if (measurement_active_sync2) begin
                clk_to_measure_counter <= clk_to_measure_counter + 1;
            end else begin
                // Reset counter when measurement is not active
                clk_to_measure_counter <= 0;
            end
        end
    end

endmodule
