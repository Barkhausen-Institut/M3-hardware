module i2c_master (
    input           clk_sys,        // System clock (e.g., 100MHz)
    input           rst_n,          // Active-low reset
    input           start_i,        // Start a new transaction
    input  [6:0]    addr_i,         // 7-bit I2C slave address
    input  [7:0]    reg_addr_i,     // 8-bit internal register/byte address
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
localparam S_IDLE            = 4'd0;
localparam S_START           = 4'd1;
localparam S_TX_SLAVE_ADDR   = 4'd2;
localparam S_TX_ACK1         = 4'd3;
localparam S_TX_REG_ADDR     = 4'd4;
localparam S_TX_ACK2         = 4'd5;
localparam S_TX_DATA         = 4'd6;
localparam S_TX_ACK3         = 4'd7;
localparam S_STOP            = 4'd8;

reg [15:0] clk_div_cnt; // Counter register, needs to hold up to 124
reg        scl_reg;
reg        scl_ena;
reg        sda_reg;
reg        sda_ena_n;

reg [7:0]  data_reg;
reg [2:0]  bit_cnt;
reg        ack_error_reg;

wire       scl_posedge_sync;
wire       scl_negedge_sync;

assign scl_posedge_sync = (clk_div_cnt == CLK_DIV - 1);
assign scl_negedge_sync = (clk_div_cnt == (CLK_DIV * 2) - 1);


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
        if (scl_negedge_sync) begin
            clk_div_cnt <= 0;
            scl_reg <= ~scl_reg;
        end else if (scl_posedge_sync) begin
            scl_reg <= ~scl_reg;
            clk_div_cnt <= clk_div_cnt + 1;
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
        //busy_o <= 1'b0;
        sda_ena_n <= 1'b1;
        scl_ena <= 1'b0;
        bit_cnt <= 0;
        ack_error_reg <= 1'b0;
    end else begin
            case (state)
                S_IDLE: begin
                    if (start_i) begin
                        //busy_o <= 1'b1;
                        data_reg <= {addr_i, rw_i};
                        state <= S_START;
                        ack_error_reg <= 1'b0;
                    end
                end

                S_START: begin
                    sda_reg <= 1'b0; // Generate START condition (SDA low while SCL high)
                    scl_ena <= 1'b1;
                    state <= S_TX_SLAVE_ADDR;
                    bit_cnt <= 7;
                end

                S_TX_SLAVE_ADDR, S_TX_REG_ADDR, S_TX_DATA: begin
                    if (scl_negedge_sync) begin // Change data when SCLfalling edge
                        sda_reg <= data_reg[bit_cnt];
                        if (bit_cnt == 0) begin
                            sda_ena_n <= 1'b1; // Release SDA for ACK
                            case(state)
                                S_TX_SLAVE_ADDR: state <= S_TX_ACK1;
                                S_TX_REG_ADDR:   state <= S_TX_ACK2;
                                S_TX_DATA:       state <= S_TX_ACK3;
                            endcase
                        end else begin
                            bit_cnt <= bit_cnt - 1;
                        end
                    end
                end

                S_TX_ACK1, S_TX_ACK2, S_TX_ACK3: begin
                    if (scl_posedge_sync) begin
                        if (sda_io) begin // NACK received
                            ack_error_reg <= 1'b1;
                            state <= S_STOP; // Abort on NACK
                        end else begin // ACK received, decide next step
                            sda_ena_n <= 1'b0; // Master takes control of SDA
                            bit_cnt <= 7;
                            case(state)
                                S_TX_ACK1: begin
                                    data_reg <= reg_addr_i;
                                    state <= S_TX_REG_ADDR;
                                end
                                S_TX_ACK2: begin
                                    data_reg <= data_wr_i;
                                    state <= S_TX_DATA;
                                end
                                S_TX_ACK3: begin
                                    // Last ACK, transaction successful
                                    state <= S_STOP;
                                end
                            endcase
                        end
                    end
                end

                S_STOP: begin
                    sda_reg <= 1'b0; // Ensure SDA is low first
                    if (scl_posedge_sync) begin
                        sda_reg <= 1'b1; // Then raise SDA for STOP condition
                        scl_ena <= 1'b0; // Disable SCL clock
                        //busy_o <= 1'b0;
                        state <= S_IDLE;
                    end
                end

                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end

endmodule
