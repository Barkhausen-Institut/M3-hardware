
//function to bsel according to data size and addr shift
function automatic [7:0] set_bsel8;
    input [2:0] addr;
    input [3:0] size;
    reg [7:0] tmp;
    begin
        case(size)
            4'd1: tmp = 8'b0000_0001;
            4'd2: tmp = 8'b0000_0011;
            4'd3: tmp = 8'b0000_0111;
            4'd4: tmp = 8'b0000_1111;
            4'd5: tmp = 8'b0001_1111;
            4'd6: tmp = 8'b0011_1111;
            4'd7: tmp = 8'b0111_1111;
            4'd8: tmp = 8'b1111_1111;
            default: tmp = 8'b0000_0000;  //should not happen
        endcase
        set_bsel8 = tmp << addr;
    end
endfunction


//function to determine number of set bits in bsel
//assumption: ones in bsel are always contiguous
function automatic [3:0] count_ones8;
    input [7:0] data;
    begin
        case(data)
            8'b0000_0001: count_ones8 = 4'd1;
            8'b0000_0010: count_ones8 = 4'd1;
            8'b0000_0100: count_ones8 = 4'd1;
            8'b0000_1000: count_ones8 = 4'd1;
            8'b0001_0000: count_ones8 = 4'd1;
            8'b0010_0000: count_ones8 = 4'd1;
            8'b0100_0000: count_ones8 = 4'd1;
            8'b1000_0000: count_ones8 = 4'd1;
            8'b0000_0011: count_ones8 = 4'd2;
            8'b0000_0110: count_ones8 = 4'd2;
            8'b0000_1100: count_ones8 = 4'd2;
            8'b0001_1000: count_ones8 = 4'd2;
            8'b0011_0000: count_ones8 = 4'd2;
            8'b0110_0000: count_ones8 = 4'd2;
            8'b1100_0000: count_ones8 = 4'd2;
            8'b0000_0111: count_ones8 = 4'd3;
            8'b0000_1110: count_ones8 = 4'd3;
            8'b0001_1100: count_ones8 = 4'd3;
            8'b0011_1000: count_ones8 = 4'd3;
            8'b0111_0000: count_ones8 = 4'd3;
            8'b1110_0000: count_ones8 = 4'd3;
            8'b0000_1111: count_ones8 = 4'd4;
            8'b0001_1110: count_ones8 = 4'd4;
            8'b0011_1100: count_ones8 = 4'd4;
            8'b0111_1000: count_ones8 = 4'd4;
            8'b1111_0000: count_ones8 = 4'd4;
            8'b0001_1111: count_ones8 = 4'd5;
            8'b0011_1110: count_ones8 = 4'd5;
            8'b0111_1100: count_ones8 = 4'd5;
            8'b1111_1000: count_ones8 = 4'd5;
            8'b0011_1111: count_ones8 = 4'd6;
            8'b0111_1110: count_ones8 = 4'd6;
            8'b1111_1100: count_ones8 = 4'd6;
            8'b0111_1111: count_ones8 = 4'd7;
            8'b1111_1110: count_ones8 = 4'd7;
            8'b1111_1111: count_ones8 = 4'd8;
            default: count_ones8 = 8'd0;    //should not happen
        endcase
    end
endfunction



//function to determine index of first set bit in bsel (seen from LSB)
//assumption: ones in bsel are always contiguous
function automatic [2:0] get_firstone8;
    input [7:0] data;
    begin
        casex(data)
            8'bxxxx_xxx1: get_firstone8 = 3'd0;
            8'bxxxx_xx10: get_firstone8 = 3'd1;
            8'bxxxx_x100: get_firstone8 = 3'd2;
            8'bxxxx_1000: get_firstone8 = 3'd3;
            8'bxxx1_0000: get_firstone8 = 3'd4;
            8'bxx10_0000: get_firstone8 = 3'd5;
            8'bx100_0000: get_firstone8 = 3'd6;
            8'b1000_0000: get_firstone8 = 3'd7;
            default: get_firstone8 = 8'd0;    //should not happen
        endcase
    end
endfunction



//function to set access bits according to unpriv. cmd
//bit 0: read from local mem, bit 1: write to local mem
function [1:0] set_access;
    input [TCU_OPCODE_SIZE-1:0] cmd;
    begin
        if ((cmd == TCU_OPCODE_WRITE) ||
            (cmd == TCU_OPCODE_SEND) ||
            (cmd == TCU_OPCODE_REPLY)) begin
            set_access = 2'b01;
        end
        else if (cmd == TCU_OPCODE_READ) begin
            set_access = 2'b10;
        end
        //should not happen
        else begin
            set_access = 2'b00;
        end
    end
endfunction
