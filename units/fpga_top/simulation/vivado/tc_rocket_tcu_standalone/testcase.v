


//----------------------------------------------------------------------------
// PM memory initialization
//----------------------------------------------------------------------------

//select if PMP is used
`define PMP

//select if virtual memory is used
//`define VM

//number of 8-byte lines in one memory block
`define MEM_BLOCK_SIZE   'h00040000

`define BOOM_CORE   0
`define ROCKET_CORE 1
`define NIC         2
`define Serial      3

`ifdef VM
`define PMP_SIZE    'h01000000
`define PE_DESC     (1 << 6) | (('h1 << `ROCKET_CORE) << 11)
`else
`define PMP_SIZE    'h04000000
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
`define MEM_START_ADDR  'h02000000
`define MEM_END_ADDR    (`MEM_START_ADDR + 'h40000)

//mem offset (8-byte address)
`define MEM_OFFSET   (`PMP_ADDR>>3)

reg [63:0] mem_content [`MEM_START_ADDR:`MEM_END_ADDR-1];
reg [63:0] mem_content_off [`MEM_START_ADDR:`MEM_END_ADDR+`MEM_OFFSET-1];
reg [63:0] addr;


`define DDR4_RAM_BLOCK_NUM        32
`define DDR4_RAM_BLOCK_NUM_LOG    $clog2(`DDR4_RAM_BLOCK_NUM)

`define DDR4_RAM_AWIDTH           18
`define DDR4_RAM_BLOCK_AWIDTH     (`DDR4_RAM_AWIDTH - `DDR4_RAM_BLOCK_NUM_LOG)
`define DDR4_RAM_BLOCK_SIZE       (1 << `DDR4_RAM_BLOCK_AWIDTH)
`define DDR4_RAM_BLOCK_SIZE_BYTE  (`DDR4_RAM_BLOCK_SIZE << 4) //128 bit memory data width

integer ddr4_ram_block;



initial begin

    //init memory arrays
    for(addr=`MEM_START_ADDR;addr<`MEM_END_ADDR;addr=addr+1) begin
        mem_content[addr] = 64'h0;
    end
    for(addr=`MEM_START_ADDR;addr<`MEM_END_ADDR+`MEM_OFFSET;addr=addr+1) begin
        mem_content_off[addr] = 64'h0;
    end


    $readmemh("targets/standalone.hex",mem_content);


    //use new array to consider offset and memory boundaries
    for(addr=`MEM_START_ADDR;addr<`MEM_END_ADDR;addr=addr+1) begin
        mem_content_off[addr+`MEM_OFFSET] = mem_content[addr];
    end


`ifdef NETLIST
    #1;
    #1;

`else

    #1;

`ifndef PMP

    for (addr=`MEM_START_ADDR; addr<`MEM_START_ADDR+`MEM_BLOCK_SIZE; addr=addr+2) begin
        tb_fpga_top.u_dut.PM0.i_pm_domain.rocket.i_pm_rocket.i_rocket_wrap.SPM.mem.i_xpm_tdp_ram.xpm_memory_tdpram_inst.xpm_memory_base_inst.uram_tdp_model.mem_col[addr[31:1]-(`MEM_START_ADDR>>1)] = {mem_content_off[addr+1], mem_content_off[addr]};
    end

`else

    //memory image does not occupy whole memory
    for (ddr4_ram_block=0; ddr4_ram_block<4; ddr4_ram_block=ddr4_ram_block+1) begin
        for (addr=`MEM_START_ADDR+ddr4_ram_block*(`DDR4_RAM_BLOCK_SIZE<<1); addr<`MEM_START_ADDR+ddr4_ram_block*(`DDR4_RAM_BLOCK_SIZE<<1)+(`DDR4_RAM_BLOCK_SIZE<<1); addr=addr+2) begin
            //index to generated code must be a constant
            case(ddr4_ram_block)
                 0: tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[0].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]] = {mem_content_off[addr+1], mem_content_off[addr]};
                 1: tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[1].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]] = {mem_content_off[addr+1], mem_content_off[addr]};
                 2: tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[2].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]] = {mem_content_off[addr+1], mem_content_off[addr]};
                 3: tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[3].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]] = {mem_content_off[addr+1], mem_content_off[addr]};
            endcase
        end
    end

`endif

    #1;


`endif


end


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


    //reset core
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, TCU_REGADDR_CORE_CFG_START, 64'h1);

    //set EP for PMP (EP0)
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, TCU_REGADDR_EP_START + (8 * 3) * 0, {HOME_CHIPID, MODID_DRAM1, TCU_MEMFLAG_RW, TCU_VPEID_INVALID, TCU_EP_TYPE_MEMORY});
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, TCU_REGADDR_EP_START + (8 * 3) * 0 + 8, `PMP_ADDR);
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, TCU_REGADDR_EP_START + (8 * 3) * 0 + 16, `PMP_SIZE);

    //load boot info to DRAM
    kenv_addr = 32'h0;
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, kenv_addr+'h0, 64'd2);     //mod count
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, kenv_addr+'h8, 64'd9);     //tile count
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, kenv_addr+'h10, 64'd1);    //mem count
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, kenv_addr+'h18, 64'd0);    //serv count

    //tile descriptors (only PM0 and DRAM)
    kenv_addr = 32'hC0;
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, kenv_addr+'h0, `PE_DESC);       //PM0
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, kenv_addr+'h100, `DRAM_DESC);   //DRAM1

    //mems
    kenv_addr = 32'h108;
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, kenv_addr+'h0, ((64'h4000 + `MEMTILE) << 49) | 64'h0304F000);                   //addr
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, kenv_addr+'h8, `DRAM_SIZE - (((64'h4000 + `MEMTILE) << 49) | 64'h0304F000));    //size



    //init environment
`ifndef PMP
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'d0, 64'h0000306f);     //j _start (+0x3000)
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h8, 64'h0);
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h10, 64'h0);
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h18, 64'h0);
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h20, 64'h0);
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h28, 64'h0);
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h30, 64'h0);
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h38, 64'h0);

    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h1000+'d0, 64'h1);            //platform = HW
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h1000+'d8, 64'h0);            //pe_id
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h1000+'d16, `PE_DESC);
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h1000+'d24, 64'd1);           //len(args)
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h1000+'d32, 32'h10001400);    //argv
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h1000+'d40, 64'h0);           //envp
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h1000+'d48, `KENV);
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h1000+'d56, 64'd9);           //raw tile count
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h1000+'d64,  {HOME_CHIPID, MODID_PM0});  //tile ids
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h1000+'d72,  {HOME_CHIPID, MODID_PM1});
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h1000+'d80,  {HOME_CHIPID, MODID_PM2});
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h1000+'d88,  {HOME_CHIPID, MODID_PM3});
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h1000+'d96,  {HOME_CHIPID, MODID_PM4});
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h1000+'d104, {HOME_CHIPID, MODID_PM5});
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h1000+'d112, {HOME_CHIPID, MODID_PM6});
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h1000+'d120, {HOME_CHIPID, MODID_PM7});
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h1000+'d128, {HOME_CHIPID, MODID_DRAM1});
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h1000+'h400, 64'h10001410);          //argument pointer
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h1000+'h408, 64'h0);
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, `DRAM_OFFSET+`PMP_ADDR+'h1000+'h410, 64'h6f6c61646e617473);  //"standalone"
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'h0F, `DRAM_OFFSET+`PMP_ADDR+'h1000+'h418, 64'h000000000000656e);
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'h0F, `DRAM_OFFSET+`PMP_ADDR+'h1000+'h420, 64'h0);
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'h0F, `DRAM_OFFSET+`PMP_ADDR+'h1000+'h428, 64'h0);
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'h0F, `DRAM_OFFSET+`PMP_ADDR+'h1000+'h430, 64'h0);
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'h0F, `DRAM_OFFSET+`PMP_ADDR+'h1000+'h438, 64'h0);
`else
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h0, 64'h0000306f);     //j _start (+0x3000)
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h8, 64'h0);
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h10, 64'h0);
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h18, 64'h0);
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h20, 64'h0);
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h28, 64'h0);
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h30, 64'h0);
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h38, 64'h0);

    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'d0, 64'h1);            //platform = HW
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'d8, 64'h0);            //pe_id
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'d16, `PE_DESC);
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'d24, 64'd1);           //len(args)
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'d32, 32'h10001400);    //argv
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'d40, 64'h0);           //envp
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'d48, `KENV);
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'d56, 64'd9);           //raw tile count
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'d64,  {HOME_CHIPID, MODID_PM0});  //tile ids
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'d72,  {HOME_CHIPID, MODID_PM1});
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'d80,  {HOME_CHIPID, MODID_PM2});
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'d88,  {HOME_CHIPID, MODID_PM3});
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'d96,  {HOME_CHIPID, MODID_PM4});
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'d104, {HOME_CHIPID, MODID_PM5});
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'d112, {HOME_CHIPID, MODID_PM6});
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'d120, {HOME_CHIPID, MODID_PM7});
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'d128, {HOME_CHIPID, MODID_DRAM1});
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'h400, 64'h10001410);          //argument pointer
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'h408, 64'h0);
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'h410, 64'h6f6c61646e617473);  //"standalone"
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'h0F, `PMP_ADDR+'h1000+'h418, 64'h000000000000656e);
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'h420, 64'h0);
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'h428, 64'h0);
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'h430, 64'h0);
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, `PMP_ADDR+'h1000+'h438, 64'h0);
`endif

    //trigger interrupt
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, TCU_REGADDR_CORE_CFG_START+'h8, 64'h1);



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


