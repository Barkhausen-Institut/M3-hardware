
//----------------------------------------------------------------------------
// PM memory initialization
//----------------------------------------------------------------------------

//8-byte addresses
`define ASM_IMEM_START_ADDR  'h00000000
`define ASM_DMEM_START_ADDR  'h00002000
`define ASM_MEM_END_ADDR     'h00002800

reg [63:0] mem_content [`ASM_IMEM_START_ADDR:`ASM_MEM_END_ADDR-1];
reg [63:0] addr;


initial begin

    //init memory array
    for(addr=`ASM_IMEM_START_ADDR; addr<`ASM_MEM_END_ADDR; addr=addr+1) begin
        mem_content[addr] = 64'h0;
    end

    $readmemh("targets/main.hex",mem_content);

    #1;

    for (addr=`ASM_IMEM_START_ADDR; addr<`ASM_MEM_END_ADDR; addr=addr+2) begin
        tb_fpga_top.u_dut.PM0.i_pm_domain.acc.i_pm_acc.i_acc_wrap.asm_mem.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[31:1]-(`ASM_IMEM_START_ADDR>>1)] = {mem_content[addr+1], mem_content[addr]};
    end
end



//----------------------------------------------------------------------------
// Stimulus process. This process will inject frames of data into the
// PHY side of the receiver.
//----------------------------------------------------------------------------
localparam TEST_ADDR = 'h00010500;
localparam TEST_DATA = 'hE;

initial
begin : testcase

    // 1 Gb/s speed
    // wait for the internal resets to settle before staring to send traffic
    @(posedge stim_rx_clk);
    while (management_config_finished !== 1)
        send_I2;

    $display("ETH config finished");

    repeat(100)
        send_I2;

    $display("Start Rx Stimulus, sending frames at 1G ... ");
    $display("Send ARP frame to init UDP/IP stack");
    send_frame(frame_arp.tobits(0));

    rx_stimulus_finished = 1;


    //---------------
    //start testcase-specific stimulus here


    //start ASM
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, TCU_REGADDR_CORE_CFG_START, 64'h1);

    //wait until core has finished
    repeat(1000)
        send_I2;

    //check output of core at test address
    read8b_noc(HOME_CHIPID, MODID_PM0, TEST_ADDR);



    forever
        send_I2;


end // testcase



//----------------------------------------------------------------------------
// Monitor process. This process checks the data coming out of the
// transmitter.
//----------------------------------------------------------------------------

reg last_is_burst;

initial
begin : p_tx_monitor
    last_is_burst = 1'b0;

    while(rx_stimulus_finished != 1) begin
        @(posedge mon_tx_clk);
        #1;
    end

    $display("Check ETH frames");

    forever
        check_frame(last_is_burst, last_is_burst);

    #20_000_000;
    $stop;

end


