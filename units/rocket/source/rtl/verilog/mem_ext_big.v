
module data_arrays_0_ext(
  input  [8:0]   RW0_addr,
  input          RW0_clk,
  input  [255:0] RW0_wdata,
  output [255:0] RW0_rdata,
  input          RW0_en,
  input          RW0_wmode,
  input  [31:0]  RW0_wmask
);

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(256),
        .MEM_ADDRWIDTH(9)
    ) data_arrays_0_ext_256x512 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({32{RW0_wmode}} & RW0_wmask),
        .addr   (RW0_addr),
        .din    (RW0_wdata),
        .dout   (RW0_rdata)
    );

endmodule


module tag_array_ext(
  input  [5:0]  RW0_addr,
  input         RW0_clk,
  input  [87:0] RW0_wdata,
  output [87:0] RW0_rdata,
  input         RW0_en,
  input         RW0_wmode,
  input  [3:0]  RW0_wmask
);

    wire [21:0] tmp_rdata0;
    wire [21:0] tmp_rdata1;
    wire [21:0] tmp_rdata2;
    wire [21:0] tmp_rdata3;
    assign RW0_rdata = {tmp_rdata3, tmp_rdata2, tmp_rdata1, tmp_rdata0};

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(22),
        .MEM_ADDRWIDTH(6)
    ) tag_array_ext_22x64_0 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({3{RW0_wmode & RW0_wmask[0]}}),
        .addr   (RW0_addr),
        .din    (RW0_wdata[21:0]),
        .dout   (tmp_rdata0)
    );

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(22),
        .MEM_ADDRWIDTH(6)
    ) tag_array_ext_22x64_1 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({3{RW0_wmode & RW0_wmask[1]}}),
        .addr   (RW0_addr),
        .din    (RW0_wdata[43:22]),
        .dout   (tmp_rdata1)
    );

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(22),
        .MEM_ADDRWIDTH(6)
    ) tag_array_ext_22x64_2 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({3{RW0_wmode & RW0_wmask[2]}}),
        .addr   (RW0_addr),
        .din    (RW0_wdata[65:44]),
        .dout   (tmp_rdata2)
    );

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(22),
        .MEM_ADDRWIDTH(6)
    ) tag_array_ext_22x64_3 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({3{RW0_wmode & RW0_wmask[3]}}),
        .addr   (RW0_addr),
        .din    (RW0_wdata[87:66]),
        .dout   (tmp_rdata3)
    );

endmodule


module tag_array_0_ext(
  input  [5:0]  RW0_addr,
  input         RW0_clk,
  input  [83:0] RW0_wdata,
  output [83:0] RW0_rdata,
  input         RW0_en,
  input         RW0_wmode,
  input  [3:0]  RW0_wmask
);

    wire [20:0] tmp_rdata0;
    wire [20:0] tmp_rdata1;
    wire [20:0] tmp_rdata2;
    wire [20:0] tmp_rdata3;
    assign RW0_rdata = {tmp_rdata3, tmp_rdata2, tmp_rdata1, tmp_rdata0};

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(21),
        .MEM_ADDRWIDTH(6)
    ) tag_array_0_ext_21x64_0 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({3{RW0_wmode & RW0_wmask[0]}}),
        .addr   (RW0_addr),
        .din    (RW0_wdata[20:0]),
        .dout   (tmp_rdata0)
    );

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(21),
        .MEM_ADDRWIDTH(6)
    ) tag_array_0_ext_21x64_1 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({3{RW0_wmode & RW0_wmask[1]}}),
        .addr   (RW0_addr),
        .din    (RW0_wdata[41:21]),
        .dout   (tmp_rdata1)
    );

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(21),
        .MEM_ADDRWIDTH(6)
    ) tag_array_0_ext_21x64_2 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({3{RW0_wmode & RW0_wmask[2]}}),
        .addr   (RW0_addr),
        .din    (RW0_wdata[62:42]),
        .dout   (tmp_rdata2)
    );

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(21),
        .MEM_ADDRWIDTH(6)
    ) tag_array_0_ext_21x64_3 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({3{RW0_wmode & RW0_wmask[3]}}),
        .addr   (RW0_addr),
        .din    (RW0_wdata[83:63]),
        .dout   (tmp_rdata3)
    );

endmodule


module data_arrays_0_0_ext(
  input  [8:0]   RW0_addr,
  input          RW0_clk,
  input  [127:0] RW0_wdata,
  output [127:0] RW0_rdata,
  input          RW0_en,
  input          RW0_wmode,
  input  [3:0]   RW0_wmask
);

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(128),
        .MEM_ADDRWIDTH(9)
    ) data_array_0_0_128x512 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({16{RW0_wmode}} &
                    {{4{RW0_wmask[3]}}, {4{RW0_wmask[2]}}, {4{RW0_wmask[1]}}, {4{RW0_wmask[0]}}}),
        .addr   (RW0_addr),
        .din    (RW0_wdata),
        .dout   (RW0_rdata)
    );

endmodule


module l2_tlb_ram_ext(
  input  [9:0]  RW0_addr,
  input         RW0_clk,
  input  [43:0] RW0_wdata,
  output [43:0] RW0_rdata,
  input         RW0_en,
  input         RW0_wmode
);

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(44),
        .MEM_ADDRWIDTH(10)
    ) l2_tlb_ram_ext_44x1024 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({6{RW0_wmode}}),
        .addr   (RW0_addr),
        .din    (RW0_wdata),
        .dout   (RW0_rdata)
    );

endmodule


module cc_dir_ext(
  input  [9:0]   RW0_addr,
  input          RW0_clk,
  input  [159:0] RW0_wdata,
  output [159:0] RW0_rdata,
  input          RW0_en,
  input          RW0_wmode,
  input  [7:0]   RW0_wmask
);

    wire [63:0] tmp_rdata0;
    wire [63:0] tmp_rdata1;
    wire [63:0] tmp_rdata2;
    assign RW0_rdata = {tmp_rdata2[59:40], tmp_rdata2[35:16], tmp_rdata2[11:0],
                        tmp_rdata1[63:56], tmp_rdata1[51:32], tmp_rdata1[27:8], tmp_rdata1[3:0],
                        tmp_rdata0[63:48], tmp_rdata0[43:24], tmp_rdata0[19:0]};

    //one bit in wmask includes 20 bit data
    //need 4 bits empty space to map to byte select
    wire [63:0] tmp_wdata0 = {RW0_wdata[55:40], 4'h0, RW0_wdata[39:20], 4'h0, RW0_wdata[19:0]};
    wire [63:0] tmp_wdata1 = {RW0_wdata[107:100], 4'h0, RW0_wdata[99:80], 4'h0, RW0_wdata[79:60], 4'h0, RW0_wdata[59:56]};
    wire [63:0] tmp_wdata2 = {4'h0, RW0_wdata[159:140], 4'h0, RW0_wdata[139:120], 4'h0, RW0_wdata[119:108]};

    wire [7:0] tmp_wmask0 = {RW0_wmask[2], RW0_wmask[2],
                             RW0_wmask[1], RW0_wmask[1],
                             RW0_wmask[1], RW0_wmask[0],
                             RW0_wmask[0], RW0_wmask[0]};
    wire [7:0] tmp_wmask1 = {RW0_wmask[5], RW0_wmask[4],
                             RW0_wmask[4], RW0_wmask[4],
                             RW0_wmask[3], RW0_wmask[3],
                             RW0_wmask[3], RW0_wmask[2]};
    wire [7:0] tmp_wmask2 = {RW0_wmask[7], RW0_wmask[7],
                             RW0_wmask[7], RW0_wmask[6],
                             RW0_wmask[6], RW0_wmask[6],
                             RW0_wmask[5], RW0_wmask[5]};

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(64),
        .MEM_ADDRWIDTH(10)
    ) cc_dir_ext_64x1024_0 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({8{RW0_wmode}} & tmp_wmask0),
        .addr   (RW0_addr),
        .din    (tmp_wdata0),
        .dout   (tmp_rdata0)
    );

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(64),
        .MEM_ADDRWIDTH(10)
    ) cc_dir_ext_64x1024_1 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({8{RW0_wmode}} & tmp_wmask1),
        .addr   (RW0_addr),
        .din    (tmp_wdata1),
        .dout   (tmp_rdata1)
    );

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(64),
        .MEM_ADDRWIDTH(10)
    ) cc_dir_ext_64x1024_2 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({8{RW0_wmode}} & tmp_wmask2),
        .addr   (RW0_addr),
        .din    (tmp_wdata2),
        .dout   (tmp_rdata2)
    );

endmodule


module cc_banks_0_ext(
  input  [13:0] RW0_addr,
  input         RW0_clk,
  input  [63:0] RW0_wdata,
  output [63:0] RW0_rdata,
  input         RW0_en,
  input         RW0_wmode
);

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(64),
        .MEM_ADDRWIDTH(14)
    ) cc_banks_0_ext_64x16384 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({8{RW0_wmode}}),
        .addr   (RW0_addr),
        .din    (RW0_wdata),
        .dout   (RW0_rdata)
    );

endmodule
