module i2c_master (
    input           clk_sys,        // System clock (e.g., 100MHz)
    input           rst_n,          // Active-low reset
    input           start_i,        // Start a new transaction
    input  [6:0]    addr_i,         // 7-bit I2C slave address
    input           rw_i,           // 0 for Write, 1 for Read
    input  [7:0]    data_wr_i,      // Data to write
    output          busy_o,         // High when a transaction is in progress
    output          ack_error_o,    // High if a NACK is received when not expected
    output          scl_o,          // I2C clock line (open drain)
    inout           sda_io          // I2C data line (bidirectional, open drain)
);

//----------------------------------------------------------------------
// Parameters
//----------------------------------------------------------------------
// Set the I2C clock speed
parameter I2C_FREQ_KHZ = 400;
// Set the system clock frequency in kHz
parameter SYS_FREQ_KHZ = 100000; // 100 MHz

// Calculate the clock divider value. We need to count half periods.
localparam CLK_DIV = (SYS_FREQ_KHZ / (I2C_FREQ_KHZ * 2)); // Should calculate to 125

//----------------------------------------------------------------------
// Internal Signals
//----------------------------------------------------------------------
reg [3:0]  state;
localparam S_IDLE        = 4'd0;
localparam S_START       = 4'd1;
localparam S_ADDR        = 4'd2;
localparam S_ADDR_ACK    = 4'd3;
localparam S_DATA        = 4'd4;
localparam S_DATA_ACK    = 4'd5;
localparam S_STOP        = 4'd6;

reg [15:0] clk_div_cnt; // Counter register, needs to hold up to 124
reg        scl_reg;
reg        scl_ena;
reg        sda_reg;
reg        sda_ena_n;

reg [7:0]  data_reg;
reg [2:0]  bit_cnt;
reg        ack_error_reg;


assign scl_o = scl_reg ? 1'bz : 1'b0;
assign sda_io = sda_ena_n ? 1'bz : sda_reg;

assign busy_o = (state != S_IDLE);
assign ack_error_o = ack_error_reg;

//----------------------------------------------------------------------
// Clock Divider for SCL
//----------------------------------------------------------------------
always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        clk_div_cnt <= 0;
        scl_reg <= 1'b1;
    end else if (scl_ena) begin
        if (clk_div_cnt == CLK_DIV - 1) begin // Count from 0 to 124
            clk_div_cnt <= 0;
            scl_reg <= ~scl_reg;
        end else begin
            clk_div_cnt <= clk_div_cnt + 1;
        end
    end else begin
        clk_div_cnt <= 0;
        scl_reg <= 1'b1; // Keep SCL high when idle
    end
end

//----------------------------------------------------------------------
// Main State Machine
//----------------------------------------------------------------------
always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        state <= S_IDLE;
        sda_reg <= 1'b1;
        sda_ena_n <= 1'b1;
        scl_ena <= 1'b0;
        bit_cnt <= 0;
        ack_error_reg <= 1'b0;
    end else begin
            case (state)
                S_IDLE: begin
                    if (start_i) begin
                        data_reg <= {addr_i, rw_i};
                        state <= S_START;
                        ack_error_reg <= 1'b0;
                    end
                end

                S_START: begin
                    sda_reg <= 1'b0; // Generate START condition (SDA low while SCL high)
                    scl_ena <= 1'b1;
                    state <= S_ADDR;
                    bit_cnt <= 7;
                end

                S_ADDR: begin
                    if (scl_reg) begin // Change data when SCL is low
                        sda_reg <= data_reg[bit_cnt];
                        if (bit_cnt == 0) begin
                            state <= S_ADDR_ACK;
                        end else begin
                            bit_cnt <= bit_cnt - 1;
                        end
                    end
                end

                S_ADDR_ACK: begin
                    sda_ena_n <= 1'b1; // Release SDA for ACK
                    if (scl_reg) begin // Sample ACK when SCL is high
                        if (sda_io) begin
                            ack_error_reg <= 1'b1; // NACK received
                            state <= S_STOP; // Stop on NACK
                        end else begin
                            data_reg <= data_wr_i; // Load data for next stage
                            state <= S_DATA;
                        end
                        bit_cnt <= 7;
                        sda_ena_n <= 1'b0; // Take control of SDA again
                    end
                end

                S_DATA: begin
                    if (scl_reg) begin // Change data when SCL is low
                        sda_reg <= data_reg[bit_cnt];
                        if (bit_cnt == 0) begin
                            state <= S_DATA_ACK;
                        end else begin
                            bit_cnt <= bit_cnt - 1;
                        end
                    end
                end

                S_DATA_ACK: begin
                    sda_ena_n <= 1'b1; // Release SDA for ACK
                    if (scl_reg) begin // Sample ACK when SCL is high
                        if (sda_io) begin
                            ack_error_reg <= 1'b1;
                        end
                        state <= S_STOP;
                    end
                end

                S_STOP: begin
                    sda_reg <= 1'b0; // Ensure SDA is low
                    if (scl_reg) begin // Generate STOP (SDA high while SCL high)
                       sda_reg <= 1'b1;
                       state <= S_IDLE;
                       scl_ena <= 1'b0;
                    end
                end

                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end

endmodule
