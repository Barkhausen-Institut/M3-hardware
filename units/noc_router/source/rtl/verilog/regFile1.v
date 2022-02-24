`ifndef _REGFILE1
`define _REGFILE1

module regFile1
    (   rstq_i,
        clk_i,
        data_i,
        rdreq_i,
        wrreq_i,
        empty_o,
        full_o,
        data_o,
        usedw_o
    );

    parameter FLIT_SIZE  = 6+12 + 68;
    parameter USEDW_SIZE = 2;
    parameter FIFO_SIZE  = 1 << USEDW_SIZE;

    input  wire                      rstq_i;
    input  wire                      clk_i;
    input  wire [FLIT_SIZE-1:0]      data_i;
    input  wire                      rdreq_i;
    input  wire                      wrreq_i;
    output wire                      empty_o;
    output wire                      full_o;
    output wire [FLIT_SIZE-1:0]      data_o;
    output wire [USEDW_SIZE-1:0]     usedw_o;


    reg         [FLIT_SIZE-1:0]      data_array[0:FIFO_SIZE-1];
    reg         [USEDW_SIZE:0]       r_usedw;
    reg         [USEDW_SIZE-1:0]     r_wrPointer;
    reg         [USEDW_SIZE-1:0]     r_rdPointer;

    integer                          i;

    assign full_o  = r_usedw [USEDW_SIZE];
    assign empty_o = (r_usedw == {USEDW_SIZE+1{1'b0}});
    assign data_o  = data_array[r_rdPointer];
    assign usedw_o = r_usedw[USEDW_SIZE-1:0];

    always@(posedge clk_i or negedge rstq_i) begin
        if(!rstq_i) begin
            for(i=0; i<FIFO_SIZE; i=i+1) data_array[i] <= {FLIT_SIZE{1'b0}};
            r_usedw     <= 'd0;
            r_wrPointer <= 'd0;
            r_rdPointer <= 'd0;
        end else begin
            if(wrreq_i) begin
                data_array[r_wrPointer] <= data_i;
                r_wrPointer             <= r_wrPointer + 1'b1;
            end
            if(rdreq_i) begin
                r_rdPointer             <= r_rdPointer + 1'b1;
            end
            if(rdreq_i && wrreq_i) r_usedw <= r_usedw;
            else if(wrreq_i)       r_usedw <= r_usedw + 1'b1;
            else if(rdreq_i)       r_usedw <= r_usedw - 1'b1;
            else                   r_usedw <= r_usedw;
        end
    end

endmodule // regFile

`endif
