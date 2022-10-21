
module cc_dir_ext_boom(
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
    ) cc_dir_ext_boom_64x1024_0 (
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
    ) cc_dir_ext_boom_64x1024_1 (
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
    ) cc_dir_ext_boom_64x1024_2 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({8{RW0_wmode}} & tmp_wmask2),
        .addr   (RW0_addr),
        .din    (tmp_wdata2),
        .dout   (tmp_rdata2)
    );

endmodule

module cc_banks_0_ext_boom(
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
    ) cc_banks_0_ext_boom_64x16384 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({8{RW0_wmode}}),
        .addr   (RW0_addr),
        .din    (RW0_wdata),
        .dout   (RW0_rdata)
    );

endmodule

module tag_array_ext_boom(
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
    ) tag_array_ext_boom_22x64_0 (
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
    ) tag_array_ext_boom_22x64_1 (
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
    ) tag_array_ext_boom_22x64_2 (
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
    ) tag_array_ext_boom_22x64_3 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({3{RW0_wmode & RW0_wmask[3]}}),
        .addr   (RW0_addr),
        .din    (RW0_wdata[87:66]),
        .dout   (tmp_rdata3)
    );

endmodule

module array_0_0_ext_boom(
  input  [8:0]  W0_addr,
  input         W0_clk,
  input  [63:0] W0_data,
  input         W0_en,
  input         W0_mask,
  input  [8:0]  R0_addr,
  input         R0_clk,
  output [63:0] R0_data,
  input         R0_en
);

    mem_tp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(64),
        .MEM_ADDRWIDTH(9)
    ) array_0_0_ext_boom_64x512 (
        .clk    (W0_clk),
        .reset  (1'b0),
        .ena    (W0_en),
        .wea    ({8{W0_mask}}),
        .addra  (W0_addr),
        .dina   (W0_data),
        .enb    (R0_en),
        .addrb  (R0_addr),
        .doutb  (R0_data)
    );

endmodule

module tag_array_0_ext_boom(
  input  [5:0]  RW0_addr,
  input         RW0_clk,
  input  [79:0] RW0_wdata,
  output [79:0] RW0_rdata,
  input         RW0_en,
  input         RW0_wmode,
  input  [3:0]  RW0_wmask
);

    wire [19:0] tmp_rdata0;
    wire [19:0] tmp_rdata1;
    wire [19:0] tmp_rdata2;
    wire [19:0] tmp_rdata3;
    assign RW0_rdata = {tmp_rdata3, tmp_rdata2, tmp_rdata1, tmp_rdata0};

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(20),
        .MEM_ADDRWIDTH(6)
    ) tag_array_0_ext_boom_20x64_0 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({3{RW0_wmode & RW0_wmask[0]}}),
        .addr   (RW0_addr),
        .din    (RW0_wdata[19:0]),
        .dout   (tmp_rdata0)
    );

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(20),
        .MEM_ADDRWIDTH(6)
    ) tag_array_0_ext_boom_20x64_1 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({3{RW0_wmode & RW0_wmask[1]}}),
        .addr   (RW0_addr),
        .din    (RW0_wdata[39:20]),
        .dout   (tmp_rdata1)
    );

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(20),
        .MEM_ADDRWIDTH(6)
    ) tag_array_0_ext_boom_20x64_2 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({3{RW0_wmode & RW0_wmask[2]}}),
        .addr   (RW0_addr),
        .din    (RW0_wdata[59:40]),
        .dout   (tmp_rdata2)
    );

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(20),
        .MEM_ADDRWIDTH(6)
    ) tag_array_0_ext_boom_20x64_3 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({3{RW0_wmode & RW0_wmask[3]}}),
        .addr   (RW0_addr),
        .din    (RW0_wdata[79:60]),
        .dout   (tmp_rdata3)
    );

endmodule

module dataArrayWay_0_ext_boom(
  input  [8:0]  RW0_addr,
  input         RW0_clk,
  input  [63:0] RW0_wdata,
  output [63:0] RW0_rdata,
  input         RW0_en,
  input         RW0_wmode
);

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(64),
        .MEM_ADDRWIDTH(9)
    ) dataArrayWay_0_ext_boom_64x512 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({8{RW0_wmode}}),
        .addr   (RW0_addr),
        .din    (RW0_wdata),
        .dout   (RW0_rdata)
    );

endmodule

module hi_us_ext_boom(
  input  [6:0] W0_addr,
  input        W0_clk,
  input  [3:0] W0_data,
  input        W0_en,
  input  [3:0] W0_mask,
  input  [6:0] R0_addr,
  input        R0_clk,
  output [3:0] R0_data,
  input        R0_en
);

    mem_tp_bit_wrap #(
        .MEM_TYPE("distributed"),
        .MEM_DATAWIDTH(4),
        .MEM_ADDRWIDTH(7)
    ) hi_us_ext_boom_4x128 (
        .clk    (W0_clk),
        .reset  (1'b0),
        .ena    (W0_en),
        .wea    (W0_mask),
        .addra  (W0_addr),
        .dina   (W0_data),
        .enb    (R0_en),
        .addrb  (R0_addr),
        .doutb  (R0_data)
    );

endmodule

module table_ext_boom(
  input  [6:0]  W0_addr,
  input         W0_clk,
  input  [43:0] W0_data,
  input         W0_en,
  input  [3:0]  W0_mask,
  input  [6:0]  R0_addr,
  input         R0_clk,
  output [43:0] R0_data,
  input         R0_en
);

    wire [43:0] tmp_wmask = {{11{W0_mask[3]}}, {11{W0_mask[2]}}, {11{W0_mask[1]}}, {11{W0_mask[0]}}};

    mem_tp_bit_wrap #(
        .MEM_TYPE("distributed"),
        .MEM_DATAWIDTH(44),
        .MEM_ADDRWIDTH(7)
    ) table_ext_boom_44x128 (
        .clk    (W0_clk),
        .reset  (1'b0),
        .ena    (W0_en),
        .wea    (tmp_wmask),
        .addra  (W0_addr),
        .dina   (W0_data),
        .enb    (R0_en),
        .addrb  (R0_addr),
        .doutb  (R0_data)
    );

endmodule

module hi_us_0_ext_boom(
  input  [7:0] W0_addr,
  input        W0_clk,
  input  [3:0] W0_data,
  input        W0_en,
  input  [3:0] W0_mask,
  input  [7:0] R0_addr,
  input        R0_clk,
  output [3:0] R0_data,
  input        R0_en
);

    mem_tp_bit_wrap #(
        .MEM_TYPE("distributed"),
        .MEM_DATAWIDTH(4),
        .MEM_ADDRWIDTH(8)
    ) hi_us_0_ext_boom_4x256 (
        .clk    (W0_clk),
        .reset  (1'b0),
        .ena    (W0_en),
        .wea    (W0_mask),
        .addra  (W0_addr),
        .dina   (W0_data),
        .enb    (R0_en),
        .addrb  (R0_addr),
        .doutb  (R0_data)
    );

endmodule

module table_0_ext_boom(
  input  [7:0]  W0_addr,
  input         W0_clk,
  input  [47:0] W0_data,
  input         W0_en,
  input  [3:0]  W0_mask,
  input  [7:0]  R0_addr,
  input         R0_clk,
  output [47:0] R0_data,
  input         R0_en
);

    wire [47:0] tmp_wmask = {{12{W0_mask[3]}}, {12{W0_mask[2]}}, {12{W0_mask[1]}}, {12{W0_mask[0]}}};

    mem_tp_bit_wrap #(
        .MEM_TYPE("distributed"),
        .MEM_DATAWIDTH(48),
        .MEM_ADDRWIDTH(8)
    ) table_0_ext_boom_48x256 (
        .clk    (W0_clk),
        .reset  (1'b0),
        .ena    (W0_en),
        .wea    (tmp_wmask),
        .addra  (W0_addr),
        .dina   (W0_data),
        .enb    (R0_en),
        .addrb  (R0_addr),
        .doutb  (R0_data)
    );

endmodule

module table_1_ext_boom(
  input  [6:0]  W0_addr,
  input         W0_clk,
  input  [51:0] W0_data,
  input         W0_en,
  input  [3:0]  W0_mask,
  input  [6:0]  R0_addr,
  input         R0_clk,
  output [51:0] R0_data,
  input         R0_en
);

    wire [51:0] tmp_wmask = {{13{W0_mask[3]}}, {13{W0_mask[2]}}, {13{W0_mask[1]}}, {13{W0_mask[0]}}};

    mem_tp_bit_wrap #(
        .MEM_TYPE("distributed"),
        .MEM_DATAWIDTH(52),
        .MEM_ADDRWIDTH(7)
    ) table_1_ext_boom_52x128 (
        .clk    (W0_clk),
        .reset  (1'b0),
        .ena    (W0_en),
        .wea    (tmp_wmask),
        .addra  (W0_addr),
        .dina   (W0_data),
        .enb    (R0_en),
        .addrb  (R0_addr),
        .doutb  (R0_data)
    );

endmodule

module meta_0_ext_boom(
  input  [6:0]   W0_addr,
  input          W0_clk,
  input  [123:0] W0_data,
  input          W0_en,
  input  [3:0]   W0_mask,
  input  [6:0]   R0_addr,
  input          R0_clk,
  output [123:0] R0_data,
  input          R0_en
);

    wire  [15:0] tmp_wmask = {{4{W0_mask[3]}}, {4{W0_mask[2]}}, {4{W0_mask[1]}}, {4{W0_mask[0]}}};
    wire [127:0] tmp_wdata = {1'b0, W0_data[123:93],
                              1'b0, W0_data[ 92:62],
                              1'b0, W0_data[ 61:31],
                              1'b0, W0_data[ 30: 0]};
    wire [127:0] tmp_rdata;
    assign R0_data = {tmp_rdata[123:93], tmp_rdata[92:62], tmp_rdata[61:31], tmp_rdata[30:0]};

    mem_tp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(128),
        .MEM_ADDRWIDTH(7)
    ) meta_0_ext_boom_128x128 (
        .clk    (W0_clk),
        .reset  (1'b0),
        .ena    (W0_en),
        .wea    (tmp_wmask),
        .addra  (W0_addr),
        .dina   (tmp_wdata),
        .enb    (R0_en),
        .addrb  (R0_addr),
        .doutb  (tmp_rdata)
    );

endmodule

module btb_0_ext_boom(
  input  [6:0]  W0_addr,
  input         W0_clk,
  input  [55:0] W0_data,
  input         W0_en,
  input  [3:0]  W0_mask,
  input  [6:0]  R0_addr,
  input         R0_clk,
  output [55:0] R0_data,
  input         R0_en
);

    wire [55:0] tmp_wmask = {{14{W0_mask[3]}}, {14{W0_mask[2]}}, {14{W0_mask[1]}}, {14{W0_mask[0]}}};

    mem_tp_bit_wrap #(
        .MEM_TYPE("distributed"),
        .MEM_DATAWIDTH(56),
        .MEM_ADDRWIDTH(7)
    ) btb_0_ext_boom_56x128 (
        .clk    (W0_clk),
        .reset  (1'b0),
        .ena    (W0_en),
        .wea    (tmp_wmask),
        .addra  (W0_addr),
        .dina   (W0_data),
        .enb    (R0_en),
        .addrb  (R0_addr),
        .doutb  (R0_data)
    );

endmodule

module ebtb_ext_boom(
  input  [6:0]  W0_addr,
  input         W0_clk,
  input  [39:0] W0_data,
  input         W0_en,
  input  [6:0]  R0_addr,
  input         R0_clk,
  output [39:0] R0_data,
  input         R0_en
);

    mem_tp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(40),
        .MEM_ADDRWIDTH(7)
    ) ebtb_ext_boom_40x128 (
        .clk    (W0_clk),
        .reset  (1'b0),
        .ena    (W0_en),
        .wea    (5'h1F),
        .addra  (W0_addr),
        .dina   (W0_data),
        .enb    (R0_en),
        .addrb  (R0_addr),
        .doutb  (R0_data)
    );

endmodule

module data_ext_boom(
  input  [10:0] W0_addr,
  input         W0_clk,
  input  [7:0]  W0_data,
  input         W0_en,
  input  [3:0]  W0_mask,
  input  [10:0] R0_addr,
  input         R0_clk,
  output [7:0]  R0_data,
  input         R0_en
);

    wire [7:0] tmp_wmask = {{2{W0_mask[3]}}, {2{W0_mask[2]}}, {2{W0_mask[1]}}, {2{W0_mask[0]}}};

    mem_tp_bit_wrap #(
        .MEM_TYPE("distributed"),
        .MEM_DATAWIDTH(8),
        .MEM_ADDRWIDTH(11)
    ) data_ext_boom_8x2048 (
        .clk    (W0_clk),
        .reset  (1'b0),
        .ena    (W0_en),
        .wea    (tmp_wmask),
        .addra  (W0_addr),
        .dina   (W0_data),
        .enb    (R0_en),
        .addrb  (R0_addr),
        .doutb  (R0_data)
    );

endmodule

module meta_ext_boom(
  input  [4:0]   W0_addr,
  input          W0_clk,
  input  [119:0] W0_data,
  input          W0_en,
  input  [4:0]   R0_addr,
  input          R0_clk,
  output [119:0] R0_data,
  input          R0_en
);

    mem_tp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(120),
        .MEM_ADDRWIDTH(5)
    ) meta_ext_boom_120x32 (
        .clk    (W0_clk),
        .reset  (1'b0),
        .ena    (W0_en),
        .wea    (15'h7FFF),
        .addra  (W0_addr),
        .dina   (W0_data),
        .enb    (R0_en),
        .addrb  (R0_addr),
        .doutb  (R0_data)
    );

endmodule

module ghist_0_ext_boom(
  input  [4:0]  W0_addr,
  input         W0_clk,
  input  [71:0] W0_data,
  input         W0_en,
  input  [4:0]  R0_addr,
  input         R0_clk,
  output [71:0] R0_data,
  input         R0_en
);

    mem_tp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(72),
        .MEM_ADDRWIDTH(5)
    ) ghist_0_ext_boom_72x32 (
        .clk    (W0_clk),
        .reset  (1'b0),
        .ena    (W0_en),
        .wea    (9'h1FF),
        .addra  (W0_addr),
        .dina   (W0_data),
        .enb    (R0_en),
        .addrb  (R0_addr),
        .doutb  (R0_data)
    );

endmodule

module rob_debug_inst_mem_ext_boom(
  input  [4:0]  W0_addr,
  input         W0_clk,
  input  [63:0] W0_data,
  input         W0_en,
  input  [1:0]  W0_mask,
  input  [4:0]  R0_addr,
  input         R0_clk,
  output [63:0] R0_data,
  input         R0_en
);

    mem_tp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(64),
        .MEM_ADDRWIDTH(5)
    ) rob_debug_inst_mem_ext_boom_64x32 (
        .clk    (W0_clk),
        .reset  (1'b0),
        .ena    (W0_en),
        .wea    ({{4{W0_mask[1]}}, {4{W0_mask[0]}}}),
        .addra  (W0_addr),
        .dina   (W0_data),
        .enb    (R0_en),
        .addrb  (R0_addr),
        .doutb  (R0_data)
    );

endmodule

module l2_tlb_ram_ext_boom(
  input  [8:0]  RW0_addr,
  input         RW0_clk,
  input  [44:0] RW0_wdata,
  output [44:0] RW0_rdata,
  input         RW0_en,
  input         RW0_wmode
);

    mem_sp_wrap #(
        .MEM_TYPE("block"),
        .MEM_DATAWIDTH(45),
        .MEM_ADDRWIDTH(9)
    ) l2_tlb_ram_ext_boom_45x512 (
        .clk    (RW0_clk),
        .reset  (1'b0),
        .en     (RW0_en),
        .we     ({6{RW0_wmode}}),
        .addr   (RW0_addr),
        .din    (RW0_wdata),
        .dout   (RW0_rdata)
    );

endmodule
