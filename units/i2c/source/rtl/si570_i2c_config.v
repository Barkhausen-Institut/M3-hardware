module si570_i2c_config (

    input            clk_sys,        // System clock (100MHz)
    input            rst_n,          // Active-low system reset
    output reg       config_done_o,  // Goes high when the configuration sequence is complete
    output reg       config_error_o, // Goes high if an I2C ACK error occurs
    output           i2c_scl_o,      // I2C Clock
    inout            i2c_sda_io      // I2C Data
);

//----------------------------------------------------------------------
// Parameters
//----------------------------------------------------------------------
// Si570 Device I2C Address
localparam SI570_ADDR      = 7'h5D;

// Register Addresses
localparam REG_FREEZE_DCO  = 8'd137;
localparam REG_NEW_FREQ    = 8'd135;
localparam REG_FREQ_START  = 8'd7;

// Register Values for 125 MHz (calculated for f_xtal = 114.285 MHz)
// Based on RFREQ = 0x2BC011EB8, HSDIV=4, N1=10
localparam VAL_REG7        = 8'h02;
localparam VAL_REG8        = 8'h42;
localparam VAL_REG9        = 8'hBC;
localparam VAL_REG10       = 8'h01;
localparam VAL_REG11       = 8'h1E;
localparam VAL_REG12       = 8'hB8;

// Command Values
localparam CMD_FREEZE      = 8'h10;
localparam CMD_UNFREEZE    = 8'h00;
localparam CMD_APPLY_FREQ  = 8'h40;

//----------------------------------------------------------------------
// Internal Signals
//----------------------------------------------------------------------
reg [4:0] state;
localparam S_IDLE              = 5'd0;
localparam S_WAIT_RESET        = 5'd1;
localparam S_FREEZE_DCO_START  = 5'd2;
localparam S_FREEZE_DCO_WRITE  = 5'd3;
localparam S_WRITE_REG7_START  = 5'd4;
localparam S_WRITE_REG7_DATA   = 5'd5;
localparam S_WRITE_REG8_DATA   = 5'd6;
localparam S_WRITE_REG9_DATA   = 5'd7;
localparam S_WRITE_REG10_DATA  = 5'd8;
localparam S_WRITE_REG11_DATA  = 5'd9;
localparam S_WRITE_REG12_DATA  = 5'd10;
localparam S_UNFREEZE_START    = 5'd11;
localparam S_UNFREEZE_WRITE    = 5'd12;
localparam S_APPLY_FREQ_START  = 5'd13;
localparam S_APPLY_FREQ_WRITE  = 5'd14;
localparam S_DONE              = 5'd15;
localparam S_ERROR             = 5'd16;

reg i2c_start;
reg [7:0] i2c_data_wr;

wire i2c_busy;
wire i2c_ack_error;

//----------------------------------------------------------------------
// Instantiate I2C Master
//----------------------------------------------------------------------
i2c_master #(
    // These parameters are passed to the instance to ensure it's configured correctly.
    .I2C_FREQ_KHZ(400),
    .SYS_FREQ_KHZ(100000)
) i_i2c_master (
    .clk_sys(clk_sys),
    .rst_n(rst_n),
    .start_i(i2c_start),
    .addr_i(SI570_ADDR),
    .rw_i(1'b0), // Always writing
    .data_wr_i(i2c_data_wr),
    .busy_o(i2c_busy),
    .ack_error_o(i2c_ack_error),
    .scl_o(i2c_scl_o),
    .sda_io(i2c_sda_io)
);

//----------------------------------------------------------------------
// Configuration State Machine
//----------------------------------------------------------------------
always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
        state <= S_IDLE;
        config_done_o <= 1'b0;
        config_error_o <= 1'b0;
        i2c_start <= 1'b0;
        i2c_data_wr <= 8'h00;
    end else begin
        // Default assignments
        i2c_start <= 1'b0;

        // Abort on I2C error
        if (i2c_ack_error) begin
            state <= S_ERROR;
        end

        case (state)
            S_IDLE: begin
                state <= S_WAIT_RESET;
            end

            S_WAIT_RESET: begin
                // A small delay after reset, can be extended with a counter if needed.
                state <= S_FREEZE_DCO_START;
            end

            //----- Sequence 1: Freeze DCO -----
            S_FREEZE_DCO_START: begin
                if (!i2c_busy) begin
                    i2c_data_wr <= REG_FREEZE_DCO;
                    i2c_start <= 1'b1;
                    state <= S_FREEZE_DCO_WRITE;
                end
            end
            S_FREEZE_DCO_WRITE: begin
                if (!i2c_busy) begin
                    i2c_data_wr <= CMD_FREEZE;
                    i2c_start <= 1'b1;
                    state <= S_WRITE_REG7_START;
                end
            end

            //----- Sequence 2: Write Frequency Registers 7-12 -----
            S_WRITE_REG7_START: begin
                if (!i2c_busy) begin
                    i2c_data_wr <= REG_FREQ_START;
                    i2c_start <= 1'b1;
                    state <= S_WRITE_REG7_DATA;
                end
            end
            // The Si570 supports auto-incrementing addresses, so we just send data bytes
            S_WRITE_REG7_DATA: begin
                if (!i2c_busy) begin
                    i2c_data_wr <= VAL_REG7;
                    i2c_start   <= 1'b1;
                    state       <= S_WRITE_REG8_DATA;
                end
            end

            S_WRITE_REG8_DATA: begin
                if (!i2c_busy) begin
                    i2c_data_wr <= VAL_REG8;
                    i2c_start   <= 1'b1;
                    state       <= S_WRITE_REG9_DATA;
                end
            end

            S_WRITE_REG9_DATA: begin
                if (!i2c_busy) begin
                    i2c_data_wr <= VAL_REG9;
                    i2c_start   <= 1'b1;
                    state       <= S_WRITE_REG10_DATA;
                end
            end

            S_WRITE_REG10_DATA: begin
                if (!i2c_busy) begin
                    i2c_data_wr <= VAL_REG10;
                    i2c_start   <= 1'b1;
                    state       <= S_WRITE_REG11_DATA;
                end
            end

            S_WRITE_REG11_DATA: begin
                if (!i2c_busy) begin
                    i2c_data_wr <= VAL_REG11;
                    i2c_start   <= 1'b1;
                    state       <= S_WRITE_REG12_DATA;
                end
            end

            S_WRITE_REG12_DATA: begin
                if (!i2c_busy) begin
                    i2c_data_wr <= VAL_REG12;
                    i2c_start   <= 1'b1;
                    state       <= S_UNFREEZE_START;
                end
            end
            //----- Sequence 3: Unfreeze DCO -----
            S_UNFREEZE_START: begin
                if (!i2c_busy) begin
                    i2c_data_wr <= REG_FREEZE_DCO;
                    i2c_start <= 1'b1;
                    state <= S_UNFREEZE_WRITE;
                end
            end
            S_UNFREEZE_WRITE: begin
                if (!i2c_busy) begin
                    i2c_data_wr <= CMD_UNFREEZE;
                    i2c_start <= 1'b1;
                    state <= S_APPLY_FREQ_START;
                end
            end

            //----- Sequence 4: Apply New Frequency -----
            S_APPLY_FREQ_START: begin
                if (!i2c_busy) begin
                    i2c_data_wr <= REG_NEW_FREQ;
                    i2c_start <= 1'b1;
                    state <= S_APPLY_FREQ_WRITE;
                end
            end
            S_APPLY_FREQ_WRITE: begin
                if (!i2c_busy) begin
                    i2c_data_wr <= CMD_APPLY_FREQ;
                    i2c_start <= 1'b1;
                    state <= S_DONE;
                end
            end

            S_DONE: begin
                if (!i2c_busy) begin
                    config_done_o <= 1'b1;
                end
            end

            S_ERROR: begin
                config_error_o <= 1'b1;
            end
        endcase
    end
end

endmodule
