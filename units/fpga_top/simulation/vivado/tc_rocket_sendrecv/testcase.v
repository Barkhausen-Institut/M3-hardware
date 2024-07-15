
//----------------------------------------------------------------------------
// PM memory initialization
//----------------------------------------------------------------------------

//select if virtual memory is used
//`define VM

`define BOOM_CORE   0
`define ROCKET_CORE 1
`define NIC         2
`define Serial      3

`ifdef VM
`define PMP_SIZE    'h00100000
`define PE_DESC     (1 << 6) | (('h1 << `ROCKET_CORE) << 11)
`else
`define PMP_SIZE    'h00200000
`define PE_DESC     ((`PMP_SIZE >> 12) << 28) | ((1 << 4) << 11) | (1 << 6) | (('h1 << `ROCKET_CORE) << 11)
`endif

`define PMP_ADDR    'h2000
`define MEMTILE     8

`define DRAM_OFFSET 'h10000000
`define DRAM_START  ((64'h4000 + `MEMTILE) << 49) | (`PMP_ADDR + 8*`PMP_SIZE)
`define DRAM_SIZE   'h80000000
`define DRAM_DESC   ((`DRAM_SIZE >> 12) << 28) | ((1 << 4) << 11) | 1

`define KENV        ((64'h4000 + `MEMTILE) << 49)
reg [31:0] kenv_addr;

//8-byte addresses
`define MEM_START_ADDR  'h02000600
`define MEM_END_ADDR    (`MEM_START_ADDR + 'h40000)

//mem offset (16-byte address)
`define MEM_OFFSET      (`PMP_ADDR>>4)

reg [63:0] mem_content [`MEM_START_ADDR:`MEM_END_ADDR-1];
reg [63:0] addr;


`define DDR4_RAM_BLOCK_NUM        32
`define DDR4_RAM_BLOCK_NUM_LOG    $clog2(`DDR4_RAM_BLOCK_NUM)

`define DDR4_RAM_AWIDTH           18
`define DDR4_RAM_BLOCK_AWIDTH     (`DDR4_RAM_AWIDTH - `DDR4_RAM_BLOCK_NUM_LOG)
`define DDR4_RAM_BLOCK_SIZE       (1 << `DDR4_RAM_BLOCK_AWIDTH)
`define DDR4_RAM_BLOCK_SIZE_BYTE  (`DDR4_RAM_BLOCK_SIZE << 4) //128 bit memory data width

integer ddr4_ram_block;



initial begin

    //init memory array
    for(addr=`MEM_START_ADDR;addr<`MEM_END_ADDR;addr=addr+1) begin
        mem_content[addr] = 64'h0;
    end

    $readmemh("targets/standalone-receiver.hex",mem_content);

    #1;


    //first 16 blocks contain memory for PM0 (16x 128kB = 2MB)
    for (addr=`MEM_START_ADDR; addr<`MEM_START_ADDR+(`DDR4_RAM_BLOCK_SIZE<<1); addr=addr+2) begin
        tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[0].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]+`MEM_OFFSET] = {mem_content[addr+1], mem_content[addr]};
    end


    #1;

    $readmemh("targets/standalone-sender.hex",mem_content);

    #1;


    //second 16 blocks contain memory for PM1 (16x 128kB = 2MB)
    for (addr=`MEM_START_ADDR; addr<`MEM_START_ADDR+(`DDR4_RAM_BLOCK_SIZE<<1); addr=addr+2) begin
        tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[16].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]+`MEM_OFFSET] = {mem_content[addr+1], mem_content[addr]};
    end

    #1;

end

integer idx;
integer pm;
localparam PM_NUM = 2;
reg [NOC_MODID_SIZE-1:0] modid [PM_NUM];

//----------------------------------------------------------------------------
// Stimulus process. This process will inject frames of data into the
// PHY side of the receiver.
//----------------------------------------------------------------------------
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


    modid[0] = MODID_PM0;
    modid[1] = MODID_PM1;

    for(pm=0; pm<PM_NUM; pm=pm+1) begin
        //reset core
        write8b_noc(HOME_CHIPID, modid[pm], 8'hFF, TCU_REGADDR_CORE_CFG_START, 64'h1);

        //set EP for PMP (EP0)
        write8b_noc(HOME_CHIPID, modid[pm], 8'hFF, TCU_REGADDR_EP_START + (8 * 3) * 0, {HOME_CHIPID, MODID_DRAM1, TCU_MEMFLAG_RW, TCU_VPEID_INVALID, TCU_EP_TYPE_MEMORY});
        write8b_noc(HOME_CHIPID, modid[pm], 8'hFF, TCU_REGADDR_EP_START + (8 * 3) * 0 + 8, `PMP_ADDR + pm*`PMP_SIZE);
        write8b_noc(HOME_CHIPID, modid[pm], 8'hFF, TCU_REGADDR_EP_START + (8 * 3) * 0 + 16, `PMP_SIZE);

`ifdef VM
        //enable VM and CTXSW in FEATURES reg
        write8b_noc(HOME_CHIPID, modid[pm], 8'hFF, TCU_REGADDR_FEATURES, 64'b111);
`endif
    end

    //load boot info to DRAM
    kenv_addr = 32'h0;
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, kenv_addr+'h0, 64'd2);     //mod count
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, kenv_addr+'h8, 64'd9);     //tile count
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, kenv_addr+'h10, 64'd1);    //mem count
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, kenv_addr+'h18, 64'd0);    //serv count

    //mods - skipped
    //write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, kenv_addr+'h20, ((64'h4000 + `MEMTILE) << 49) | `PMP_ADDR);
    //write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, kenv_addr+'h28, 64'h0);
    //write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, kenv_addr+'h30, 64'h6C6D782E746F6F62); //boot.xml
    //write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, kenv_addr+'h38, 64'h0);

    //tile descriptors
    kenv_addr = 32'hC0;
    for(pm=0; pm<PM_NUM; pm=pm+1) begin
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, kenv_addr+pm*8, `PE_DESC);     //PM
    end
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, kenv_addr+'h100, `DRAM_DESC);   //DRAM1

    //mems
    kenv_addr = 32'h108;
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, kenv_addr+'h0, ((64'h4000 + `MEMTILE) << 49) | 64'h0304F000);                   //addr
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, kenv_addr+'h8, `DRAM_SIZE - (((64'h4000 + `MEMTILE) << 49) | 64'h0304F000));    //size


    //init environment
    for(pm=0; pm<PM_NUM; pm=pm+1) begin
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+pm*`PMP_SIZE+'h0, 64'h0000306f);     //j _start (+0x3000)
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+pm*`PMP_SIZE+'h8, 64'h0);
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+pm*`PMP_SIZE+'h10, 64'h0);
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+pm*`PMP_SIZE+'h18, 64'h0);
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+pm*`PMP_SIZE+'h20, 64'h0);
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+pm*`PMP_SIZE+'h28, 64'h0);
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+pm*`PMP_SIZE+'h30, 64'h0);
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+pm*`PMP_SIZE+'h38, 64'h0);

        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'d0, 64'h1);            //platform = HW
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'d8, pm);               //pe_id
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'d16, `PE_DESC);
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'d24, 64'd1);           //len(args)
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'d32, 32'h10001400);    //argv
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'d40, 64'h0);           //envp
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'d48, (pm == 0) ? `KENV : 'h0);
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'d56, 64'd9);           //raw tile count
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'d64,  {HOME_CHIPID, MODID_PM0});  //tile ids
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'d72,  {HOME_CHIPID, MODID_PM1});
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'d80,  {HOME_CHIPID, MODID_PM2});
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'d88,  {HOME_CHIPID, MODID_PM3});
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'d96,  {HOME_CHIPID, MODID_PM4});
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'d104, {HOME_CHIPID, MODID_PM5});
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'d112, {HOME_CHIPID, MODID_PM6});
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'d120, {HOME_CHIPID, MODID_PM7});
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'d128, {HOME_CHIPID, MODID_DRAM1});
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'h400, 64'h10001410);      //argument pointer
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'h408, 64'h0);
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'h410, 64'h6F69727061647473);  //"stdaprio"
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'h418, 64'h0);
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'h420, 64'h0);
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'h428, 64'h0);
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'h430, 64'h0);
        write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+pm*`PMP_SIZE+'h438, 64'h0);
    end

    //trigger interrupt
    for(pm=0; pm<PM_NUM; pm=pm+1) begin
        write8b_noc(HOME_CHIPID, modid[pm], 8'hFF, TCU_REGADDR_CORE_CFG_START+'h8, 64'h1);
    end


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

    // wait for the reset to complete before starting monitor
    @(negedge reset_h);

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


