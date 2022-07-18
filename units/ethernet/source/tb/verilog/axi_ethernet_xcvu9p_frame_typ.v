`timescale 1 ps/1 ps

`define FRAME_TYP [8*62+62+62+8*4+4+4+8*4+4+4+1:1]
`define FRAME_TYP_EXT [8*80+80+80+8*4+4+4+8*4+4+4+1:1]

module axi_ethernet_xcvu9p_frame_typ;
    //data field
    reg [7:0] data  [0:61];
    reg       valid [0:61];
    reg       error [0:61];

    //Indicate to the testbench that the frame contains an error
    reg  bad_frame;
    reg `FRAME_TYP bits;

    function `FRAME_TYP tobits;
        input dummy;
    begin
        bits = {data[ 0],  data[ 1],  data[ 2],  data[ 3],  data[ 4],
                data[ 5],  data[ 6],  data[ 7],  data[ 8],  data[ 9],
                data[10],  data[11],  data[12],  data[13],  data[14],
                data[15],  data[16],  data[17],  data[18],  data[19],
                data[20],  data[21],  data[22],  data[23],  data[24],
                data[25],  data[26],  data[27],  data[28],  data[29],
                data[30],  data[31],  data[32],  data[33],  data[34],
                data[35],  data[36],  data[37],  data[38],  data[39],
                data[40],  data[41],  data[42],  data[43],  data[44],
                data[45],  data[46],  data[47],  data[48],  data[49],
                data[50],  data[51],  data[52],  data[53],  data[54],
                data[55],  data[56],  data[57],  data[58],  data[59],
                data[60],  data[61],
                valid[ 0], valid[ 1], valid[ 2], valid[ 3], valid[ 4],
                valid[ 5], valid[ 6], valid[ 7], valid[ 8], valid[ 9],
                valid[10], valid[11], valid[12], valid[13], valid[14],
                valid[15], valid[16], valid[17], valid[18], valid[19],
                valid[20], valid[21], valid[22], valid[23], valid[24],
                valid[25], valid[26], valid[27], valid[28], valid[29],
                valid[30], valid[31], valid[32], valid[33], valid[34],
                valid[35], valid[36], valid[37], valid[38], valid[39],
                valid[40], valid[41], valid[42], valid[43], valid[44],
                valid[45], valid[46], valid[47], valid[48], valid[49],
                valid[50], valid[51], valid[52], valid[53], valid[54],
                valid[55], valid[56], valid[57], valid[58], valid[59],
                valid[60], valid[61],
                error[ 0], error[ 1], error[ 2], error[ 3], error[ 4],
                error[ 5], error[ 6], error[ 7], error[ 8], error[ 9],
                error[10], error[11], error[12], error[13], error[14],
                error[15], error[16], error[17], error[18], error[19],
                error[20], error[21], error[22], error[23], error[24],
                error[25], error[26], error[27], error[28], error[29],
                error[30], error[31], error[32], error[33], error[34],
                error[35], error[36], error[37], error[38], error[39],
                error[40], error[41], error[42], error[43], error[44],
                error[45], error[46], error[47], error[48], error[49],
                error[50], error[51], error[52], error[53], error[54],
                error[55], error[56], error[57], error[58], error[59],
                error[60], error[61],

                bad_frame
        };

        tobits = bits;
    end
    endfunction

    task frombits;
        input `FRAME_TYP frame;
    begin
        bits = frame;
        {data[ 0],  data[ 1],  data[ 2],  data[ 3],  data[ 4],
        data[ 5],  data[ 6],  data[ 7],  data[ 8],  data[ 9],
        data[10],  data[11],  data[12],  data[13],  data[14],
        data[15],  data[16],  data[17],  data[18],  data[19],
        data[20],  data[21],  data[22],  data[23],  data[24],
        data[25],  data[26],  data[27],  data[28],  data[29],
        data[30],  data[31],  data[32],  data[33],  data[34],
        data[35],  data[36],  data[37],  data[38],  data[39],
        data[40],  data[41],  data[42],  data[43],  data[44],
        data[45],  data[46],  data[47],  data[48],  data[49],
        data[50],  data[51],  data[52],  data[53],  data[54],
        data[55],  data[56],  data[57],  data[58],  data[59],
        data[60],  data[61],
        valid[ 0], valid[ 1], valid[ 2], valid[ 3], valid[ 4],
        valid[ 5], valid[ 6], valid[ 7], valid[ 8], valid[ 9],
        valid[10], valid[11], valid[12], valid[13], valid[14],
        valid[15], valid[16], valid[17], valid[18], valid[19],
        valid[20], valid[21], valid[22], valid[23], valid[24],
        valid[25], valid[26], valid[27], valid[28], valid[29],
        valid[30], valid[31], valid[32], valid[33], valid[34],
        valid[35], valid[36], valid[37], valid[38], valid[39],
        valid[40], valid[41], valid[42], valid[43], valid[44],
        valid[45], valid[46], valid[47], valid[48], valid[49],
        valid[50], valid[51], valid[52], valid[53], valid[54],
        valid[55], valid[56], valid[57], valid[58], valid[59],
        valid[60], valid[61],
        error[ 0], error[ 1], error[ 2], error[ 3], error[ 4],
        error[ 5], error[ 6], error[ 7], error[ 8], error[ 9],
        error[10], error[11], error[12], error[13], error[14],
        error[15], error[16], error[17], error[18], error[19],
        error[20], error[21], error[22], error[23], error[24],
        error[25], error[26], error[27], error[28], error[29],
        error[30], error[31], error[32], error[33], error[34],
        error[35], error[36], error[37], error[38], error[39],
        error[40], error[41], error[42], error[43], error[44],
        error[45], error[46], error[47], error[48], error[49],
        error[50], error[51], error[52], error[53], error[54],
        error[55], error[56], error[57], error[58], error[59],
        error[60], error[61],
        bad_frame
        } = bits;
    end
    endtask

endmodule


module axi_ethernet_xcvu9p_frame_typ_ext;
    //data field
    reg [7:0] data  [0:79];
    reg       valid [0:79];
    reg       error [0:79];

    //Indicate to the testbench that the frame contains an error
    reg bad_frame;
    reg `FRAME_TYP_EXT bits;

    function `FRAME_TYP_EXT tobits;
        input dummy;
    begin
        bits = {data[ 0],  data[ 1],  data[ 2],  data[ 3],  data[ 4],
                data[ 5],  data[ 6],  data[ 7],  data[ 8],  data[ 9],
                data[10],  data[11],  data[12],  data[13],  data[14],
                data[15],  data[16],  data[17],  data[18],  data[19],
                data[20],  data[21],  data[22],  data[23],  data[24],
                data[25],  data[26],  data[27],  data[28],  data[29],
                data[30],  data[31],  data[32],  data[33],  data[34],
                data[35],  data[36],  data[37],  data[38],  data[39],
                data[40],  data[41],  data[42],  data[43],  data[44],
                data[45],  data[46],  data[47],  data[48],  data[49],
                data[50],  data[51],  data[52],  data[53],  data[54],
                data[55],  data[56],  data[57],  data[58],  data[59],
                data[60],  data[61],  data[62],  data[63],  data[64],
                data[65],  data[66],  data[67],  data[68],  data[69],
                data[70],  data[71],  data[72],  data[73],  data[74],
                data[75],  data[76],  data[77],  data[78],  data[79],
                valid[ 0], valid[ 1], valid[ 2], valid[ 3], valid[ 4],
                valid[ 5], valid[ 6], valid[ 7], valid[ 8], valid[ 9],
                valid[10], valid[11], valid[12], valid[13], valid[14],
                valid[15], valid[16], valid[17], valid[18], valid[19],
                valid[20], valid[21], valid[22], valid[23], valid[24],
                valid[25], valid[26], valid[27], valid[28], valid[29],
                valid[30], valid[31], valid[32], valid[33], valid[34],
                valid[35], valid[36], valid[37], valid[38], valid[39],
                valid[40], valid[41], valid[42], valid[43], valid[44],
                valid[45], valid[46], valid[47], valid[48], valid[49],
                valid[50], valid[51], valid[52], valid[53], valid[54],
                valid[55], valid[56], valid[57], valid[58], valid[59],
                valid[60], valid[61], valid[62], valid[63], valid[64],
                valid[65], valid[66], valid[67], valid[68], valid[69],
                valid[70], valid[71], valid[72], valid[73], valid[74],
                valid[75], valid[76], valid[77], valid[78], valid[79],
                error[ 0], error[ 1], error[ 2], error[ 3], error[ 4],
                error[ 5], error[ 6], error[ 7], error[ 8], error[ 9],
                error[10], error[11], error[12], error[13], error[14],
                error[15], error[16], error[17], error[18], error[19],
                error[20], error[21], error[22], error[23], error[24],
                error[25], error[26], error[27], error[28], error[29],
                error[30], error[31], error[32], error[33], error[34],
                error[35], error[36], error[37], error[38], error[39],
                error[40], error[41], error[42], error[43], error[44],
                error[45], error[46], error[47], error[48], error[49],
                error[50], error[51], error[52], error[53], error[54],
                error[55], error[56], error[57], error[58], error[59],
                error[60], error[61], error[62], error[63], error[64],
                error[65], error[66], error[67], error[68], error[69],
                error[70], error[71], error[72], error[73], error[74],
                error[75], error[76], error[77], error[78], error[79],
                bad_frame
        };

        tobits = bits;
    end
    endfunction

    task frombits;
        input `FRAME_TYP_EXT frame;
    begin
        bits = frame;
        {data[ 0],  data[ 1],  data[ 2],  data[ 3],  data[ 4],
        data[ 5],  data[ 6],  data[ 7],  data[ 8],  data[ 9],
        data[10],  data[11],  data[12],  data[13],  data[14],
        data[15],  data[16],  data[17],  data[18],  data[19],
        data[20],  data[21],  data[22],  data[23],  data[24],
        data[25],  data[26],  data[27],  data[28],  data[29],
        data[30],  data[31],  data[32],  data[33],  data[34],
        data[35],  data[36],  data[37],  data[38],  data[39],
        data[40],  data[41],  data[42],  data[43],  data[44],
        data[45],  data[46],  data[47],  data[48],  data[49],
        data[50],  data[51],  data[52],  data[53],  data[54],
        data[55],  data[56],  data[57],  data[58],  data[59],
        data[60],  data[61],  data[62],  data[63],  data[64],
        data[65],  data[66],  data[67],  data[68],  data[69],
        data[70],  data[71],  data[72],  data[73],  data[74],
        data[75],  data[76],  data[77],  data[78],  data[79],
        valid[ 0], valid[ 1], valid[ 2], valid[ 3], valid[ 4],
        valid[ 5], valid[ 6], valid[ 7], valid[ 8], valid[ 9],
        valid[10], valid[11], valid[12], valid[13], valid[14],
        valid[15], valid[16], valid[17], valid[18], valid[19],
        valid[20], valid[21], valid[22], valid[23], valid[24],
        valid[25], valid[26], valid[27], valid[28], valid[29],
        valid[30], valid[31], valid[32], valid[33], valid[34],
        valid[35], valid[36], valid[37], valid[38], valid[39],
        valid[40], valid[41], valid[42], valid[43], valid[44],
        valid[45], valid[46], valid[47], valid[48], valid[49],
        valid[50], valid[51], valid[52], valid[53], valid[54],
        valid[55], valid[56], valid[57], valid[58], valid[59],
        valid[60], valid[61], valid[62], valid[63], valid[64],
        valid[65], valid[66], valid[67], valid[68], valid[69],
        valid[70], valid[71], valid[72], valid[73], valid[74],
        valid[75], valid[76], valid[77], valid[78], valid[79],
        error[ 0], error[ 1], error[ 2], error[ 3], error[ 4],
        error[ 5], error[ 6], error[ 7], error[ 8], error[ 9],
        error[10], error[11], error[12], error[13], error[14],
        error[15], error[16], error[17], error[18], error[19],
        error[20], error[21], error[22], error[23], error[24],
        error[25], error[26], error[27], error[28], error[29],
        error[30], error[31], error[32], error[33], error[34],
        error[35], error[36], error[37], error[38], error[39],
        error[40], error[41], error[42], error[43], error[44],
        error[45], error[46], error[47], error[48], error[49],
        error[50], error[51], error[52], error[53], error[54],
        error[55], error[56], error[57], error[58], error[59],
        error[60], error[61], error[62], error[63], error[64],
        error[65], error[66], error[67], error[68], error[69],
        error[70], error[71], error[72], error[73], error[74],
        error[75], error[76], error[77], error[78], error[79],
        bad_frame
        } = bits;
    end
    endtask

endmodule
