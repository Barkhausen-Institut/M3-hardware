


//----------------------------------------------------------------------------
// PM memory initialization
//----------------------------------------------------------------------------

//select if PMP is used
`define PMP

//select if virtual memory is used
//`define VM

//size of each memory in bytes
`define MEM_SIZE         'h02000000

//number of 8-byte lines in one memory block
`define MEM_BLOCK_SIZE   'h00040000

//8-byte addresses
`define IMEM_START_ADDR  'h00000000
`define DMEM_START_ADDR  'h02000000
`define MEM_END_ADDR     'h02040000

`define IMEM_ADDR_WIDTH  17
`define DMEM_ADDR_WIDTH  17

`define BOOM_CORE   0
`define ROCKET_CORE 1
`define NIC         2
`define Serial      3

`ifdef VM
`define PMP_SIZE    'h800000
`define PE_DESC		(3 << 6) | (('h1 << `ROCKET_CORE) << 20)
`else
`define PMP_SIZE    `MEM_SIZE
`define PE_DESC		((`PMP_SIZE >> 12) << 28) | ((1 << 5) << 20) | (3 << 6) | (('h1 << `ROCKET_CORE) << 20)
`endif

`define MEMTILE     8
`define MAX_FS_SIZE (256*1024*1024)
`define KENV        ((64'h4000 + `MEMTILE) << 49 | (`MAX_FS_SIZE+8*`PMP_SIZE))


reg [63:0] mem_content [`DMEM_START_ADDR:`MEM_END_ADDR-1];
reg [63:0] addr;


`define DDR4_RAM_BLOCK_NUM        32
`define DDR4_RAM_BLOCK_NUM_LOG    $clog2(`DDR4_RAM_BLOCK_NUM)

`define DDR4_RAM_AWIDTH           18
`define DDR4_RAM_BLOCK_AWIDTH     (`DDR4_RAM_AWIDTH - `DDR4_RAM_BLOCK_NUM_LOG)
`define DDR4_RAM_BLOCK_SIZE       ((1 << `DDR4_RAM_BLOCK_AWIDTH) << 4) //128 byte memory data width

integer ddr4_ram_block;



initial begin

    //init memory array
    for(addr=`DMEM_START_ADDR;addr<`MEM_END_ADDR;addr=addr+1) begin
        mem_content[addr] = 64'h0;
    end


    $readmemh("targets/standalone.hex",mem_content);



`ifdef NETLIST
    #1;
    #1;

`else

    #1;

`ifndef PMP

    for (addr=`DMEM_START_ADDR; addr<`DMEM_START_ADDR+`MEM_BLOCK_SIZE; addr=addr+2) begin
        tb_fpga_top.u_dut.PM0.i_pm_domain.rocket.i_pm_rocket.i_rocket_wrap.SPM.mem.i_xpm_tdp_ram.xpm_memory_tdpram_inst.xpm_memory_base_inst.uram_tdp_model.mem_col[addr[31:1]-(`DMEM_START_ADDR>>1)] = {mem_content[addr+1], mem_content[addr]};
    end

`else

    for (ddr4_ram_block=0; ddr4_ram_block<`DDR4_RAM_BLOCK_NUM; ddr4_ram_block=ddr4_ram_block+1) begin
        for (addr=`DMEM_START_ADDR+ddr4_ram_block*(`DDR4_RAM_BLOCK_SIZE>>3); addr<`DMEM_START_ADDR+ddr4_ram_block*(`DDR4_RAM_BLOCK_SIZE>>3)+(`DDR4_RAM_BLOCK_SIZE>>3); addr=addr+2) begin
            //index to generated code must be a constant
            case(ddr4_ram_block)
                 0: tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[ 0].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]] = {mem_content[addr+1], mem_content[addr]};
                 1: tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[ 1].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]] = {mem_content[addr+1], mem_content[addr]};
                 2: tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[ 2].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]] = {mem_content[addr+1], mem_content[addr]};
                 3: tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[ 3].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]] = {mem_content[addr+1], mem_content[addr]};
                 4: tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[ 4].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]] = {mem_content[addr+1], mem_content[addr]};
                 5: tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[ 5].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]] = {mem_content[addr+1], mem_content[addr]};
                 6: tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[ 6].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]] = {mem_content[addr+1], mem_content[addr]};
                 7: tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[ 7].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]] = {mem_content[addr+1], mem_content[addr]};
                 8: tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[ 8].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]] = {mem_content[addr+1], mem_content[addr]};
                 9: tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[ 9].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]] = {mem_content[addr+1], mem_content[addr]};
                10: tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[10].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]] = {mem_content[addr+1], mem_content[addr]};
                11: tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[11].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]] = {mem_content[addr+1], mem_content[addr]};
                12: tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[12].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]] = {mem_content[addr+1], mem_content[addr]};
                13: tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[13].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]] = {mem_content[addr+1], mem_content[addr]};
                14: tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[14].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]] = {mem_content[addr+1], mem_content[addr]};
                15: tb_fpga_top.u_dut.i_ddr4_c1_domain.i_ddr4_wrap.NO_DDR4.SIM_RAM[15].i_ddr4_sim_ram.i_xpm_sp_ram.xpm_memory_spram_inst.xpm_memory_base_inst.mem[addr[`DDR4_RAM_BLOCK_AWIDTH:1]] = {mem_content[addr+1], mem_content[addr]};
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
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, TCU_REGADDR_EP_START + (8 * 3) * 0 + 16, `MEM_SIZE);

    //init environment
`ifndef PMP
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, 32'h10000000+'d0, 64'h0000106f);     //j _start (+0x1000)
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, 32'h10000000+'d8, 64'h1);            //platform = HW
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, 32'h10000000+'d16, 64'h0);           //pe_id
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, 32'h10000000+'d24, `PE_DESC);
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, 32'h10000000+'d32, 64'd1);           //len(args)
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, 32'h10000000+'d40, 32'h10000408);    //argv
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, 32'h10000000+'d48, 64'h0);           //envp
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, 32'h10000000+'d56, `KENV);
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, 32'h10000000+'d64, 64'd9);           //raw tile count
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, 32'h10000000+'d72,  {HOME_CHIPID, MODID_PM0});  //tile ids
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, 32'h10000000+'d80,  {HOME_CHIPID, MODID_PM1});
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, 32'h10000000+'d88,  {HOME_CHIPID, MODID_PM2});
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, 32'h10000000+'d96,  {HOME_CHIPID, MODID_PM3});
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, 32'h10000000+'d104, {HOME_CHIPID, MODID_PM4});
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, 32'h10000000+'d112, {HOME_CHIPID, MODID_PM5});
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, 32'h10000000+'d120, {HOME_CHIPID, MODID_PM6});
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, 32'h10000000+'d128, {HOME_CHIPID, MODID_PM7});
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, 32'h10000000+'d136, {HOME_CHIPID, MODID_DRAM1});
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, 32'h10000400+'d8, 64'h10000410);          //arguments
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'hFF, 32'h10000400+'d16, 64'h6f6c61646e617473); //"standalone"
    write8b_noc(HOME_CHIPID, MODID_PM0, 8'h0F, 32'h10000400+'d24, 64'h000000000000656e);
`else
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, 32'h00000000+'d0, 64'h0000106f);     //j _start (+0x1000)
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, 32'h00000000+'d8, 64'h1);            //platform = HW
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, 32'h00000000+'d16, 64'h0);           //pe_id
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, 32'h00000000+'d24, `PE_DESC);
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, 32'h00000000+'d32, 64'd1);           //len(args)
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, 32'h00000000+'d40, 32'h10000408);    //argv
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, 32'h00000000+'d48, 64'h0);           //envp
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, 32'h00000000+'d56, `KENV);
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, 32'h00000000+'d64, 64'd9);           //raw tile count
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, 32'h00000000+'d72,  {HOME_CHIPID, MODID_PM0});  //tile ids
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, 32'h00000000+'d80,  {HOME_CHIPID, MODID_PM1});
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, 32'h00000000+'d88,  {HOME_CHIPID, MODID_PM2});
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, 32'h00000000+'d96,  {HOME_CHIPID, MODID_PM3});
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, 32'h00000000+'d104, {HOME_CHIPID, MODID_PM4});
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, 32'h00000000+'d112, {HOME_CHIPID, MODID_PM5});
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, 32'h00000000+'d120, {HOME_CHIPID, MODID_PM6});
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, 32'h00000000+'d128, {HOME_CHIPID, MODID_PM7});
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, 32'h00000000+'d136, {HOME_CHIPID, MODID_DRAM1});
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, 32'h00000400+'d8, 64'h10000410);          //arguments
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'hFF, 32'h00000400+'d16, 64'h6f6c61646e617473); //"standalone"
    write8b_noc(HOME_CHIPID, MODID_DRAM1, 8'h0F, 32'h00000400+'d24, 64'h000000000000656e);
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


