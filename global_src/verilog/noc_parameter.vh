

parameter ON_CHIP_NOC_DIM_X          = 5,  // X-axis 5
parameter ON_CHIP_NOC_DIM_Y          = 5,  // Y-axis 5
parameter ON_CHIP_NOC_DIM_Z          = 4,  // total number of module (only Z axis) - 1
parameter MOD_X_COORD_SIZE           = 3,  //3bit
parameter MOD_Y_COORD_SIZE           = 3,  //3bit
parameter MOD_Z_COORD_SIZE           = 2,  //2bit

parameter CHIP_X_COORD_SIZE          = 2,
parameter CHIP_Y_COORD_SIZE          = 2,
parameter CHIP_Z_COORD_SIZE          = 2,
parameter NOC_CHIPID_SIZE            = CHIP_X_COORD_SIZE + CHIP_Y_COORD_SIZE + CHIP_Z_COORD_SIZE,
parameter NOC_MODID_SIZE             = MOD_X_COORD_SIZE + MOD_Y_COORD_SIZE + MOD_Z_COORD_SIZE,
parameter NOC_DATA_SIZE              = 64,
parameter NOC_ADDR_SIZE              = 32,
parameter NOC_MODE_SIZE              = 4,
parameter NOC_BSEL_SIZE              = 8,
parameter NOC_BURST_SIZE             = 1,
parameter NOC_ARQ_SIZE               = 1,
parameter NOC_HEADER_SIZE            = 2*MOD_X_COORD_SIZE + 2*MOD_Y_COORD_SIZE + 2*MOD_Z_COORD_SIZE + 2*CHIP_X_COORD_SIZE + 2*CHIP_Y_COORD_SIZE + 2*CHIP_Z_COORD_SIZE + NOC_BSEL_SIZE + NOC_ARQ_SIZE + NOC_BURST_SIZE,
parameter NOC_PAYLOAD_SIZE           = NOC_DATA_SIZE + NOC_ADDR_SIZE + NOC_MODE_SIZE,
parameter NOC_ASYNC_FIFO_PACKET_SIZE = NOC_PAYLOAD_SIZE + NOC_HEADER_SIZE,
parameter NOC_ASYNC_FIFO_AWIDTH      = 3,

parameter SERIAL                     = 0,
parameter X_COORD_MAX                = 1 << MOD_X_COORD_SIZE,
parameter Y_COORD_MAX                = 1 << MOD_Y_COORD_SIZE,
parameter Z_COORD_MAX                = 1 << MOD_Z_COORD_SIZE,

parameter CNT_SIZE                   = 48,

parameter MAX_BURST_LENGTH           = 32,     //number of 16-byte packets
parameter MAX_BURST_LENGTH_MSG       = 128+1,  //number of 16-byte packets for TCU messages (128 msg payload + 1 msg header)

parameter MODE_READ_REQ              = 4'h0,
parameter MODE_READ_RSP              = 4'h1,
parameter MODE_WRITE_POSTED          = 4'h2,
parameter MODE_TCU_MSG               = 4'h3,
parameter MODE_TCU_ACK               = 4'h4,
parameter MODE_READ_REQ_2            = 4'h5,    //special modes for NoC TCU bypass interface
parameter MODE_READ_RSP_2            = 4'h6,
parameter MODE_WRITE_POSTED_2        = 4'h7,
parameter MODE_ERROR                 = 4'h8,    //something went wrong
parameter MODE_ARQ_ACK               = 4'h9,
parameter MODE_ARQ_READ_REQ          = 4'hA,
parameter MODE_ARQ_READ_RSP          = 4'hB,
parameter MODE_ARQ_WRITE_POSTED      = 4'hC,

parameter NOC_COORD_SIZE             = 3,
parameter NOC_MODULE_QUANT           = 21,

parameter NOC_ARQ_ENABLE_OFF         = 2'h0,
parameter NOC_ARQ_ENABLE_ON          = 2'h1,
parameter NOC_ARQ_ENABLE_BIT         = 2'h2,



parameter FIFO_SIZEWID				 = 2,
parameter FIFO_SIZE					 = 1<<FIFO_SIZEWID,

parameter LUT_SIZE					 = 8

