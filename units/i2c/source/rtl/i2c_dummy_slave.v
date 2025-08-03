`timescale 1ps/1ps

module i2c_dummy_slave (
    inout i2c_sda,
    input i2c_scl
);

    reg [3:0] bit_count;
    reg sda_out_reg;
    reg sda_ena_reg;
    reg seen_start;

    // Drive the SDA line when enabled (emulates open-drain)
    assign i2c_sda = sda_ena_reg ? sda_out_reg : 1'bz;

    // Detect START and STOP conditions by watching SDA while SCL is high
    always @(negedge i2c_sda or posedge i2c_sda) begin
        if (i2c_scl) begin
            if (i2c_sda == 1'b0) begin // START condition: SDA goes low while SCL is high
                seen_start <= 1'b1;
                bit_count  <= 0;
            end else begin               // STOP condition: SDA goes high while SCL is high
                seen_start <= 1'b0;
            end
        end
    end

    // Main ACK logic: count 8 bits, then ACK on the 9th SCL pulse
    always @(negedge i2c_scl) begin
        if (seen_start) begin
            if (bit_count == 8) begin
                // This is the 9th clock pulse (the ACK cycle).
                // Force SDA low to send the ACK signal.
                sda_out_reg <= 1'b0;
                sda_ena_reg <= 1'b1;
                bit_count   <= 0; // Reset for the next byte
            end else begin
                // This is a regular data bit, so release SDA
                // so the master can drive it.
                sda_ena_reg <= 1'b0;
                bit_count   <= bit_count + 1;
            end
        end
    end

endmodule
