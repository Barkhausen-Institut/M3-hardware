
//---------------
//TCU Mem IF
parameter TCU_MEM_ADDR_SIZE = 32,
parameter TCU_MEM_DATA_SIZE = 128,
parameter TCU_MEM_BSEL_SIZE = TCU_MEM_DATA_SIZE/8,


//---------------
//Reg IF
parameter TCU_REG_ADDR_SIZE = 32,
parameter TCU_REG_DATA_SIZE = 64,
parameter TCU_REG_BSEL_SIZE = TCU_REG_DATA_SIZE/8,


//---------------
//Log IF
parameter TCU_LOG_DATA_SIZE = 128-32,   //32 bit already taken by time stamp


//---------------
//registers
parameter TCU_VERSION          = 8'h1,
parameter TCU_EP_REG_COUNT     = 'd128,
parameter TCU_CFG_REG_COUNT    = 'd32,  //max count, could be less
parameter TCU_STATUS_REG_COUNT = 'd5,
parameter TCU_LOG_REG_COUNT    = 1<<17, //do not edit, fixed block RAM
parameter TCU_PRINT_REG_COUNT  = 'd32,

parameter TCU_EP_REG_SIZE      = 'h18,
parameter TCU_HD_REG_SIZE      = 'h20,
parameter TCU_CFG_REG_SIZE     = 'h8,
parameter TCU_STATUS_REG_SIZE  = 'h8,
parameter TCU_PRINT_REG_SIZE   = 'h8,

parameter TCU_REGADDR_START    = 32'hF000_0000,

//ext regs
parameter TCU_REGADDR_FEATURES  = TCU_REGADDR_START + 32'h0000_0000,
parameter TCU_REGADDR_EXT_CMD   = TCU_REGADDR_START + 32'h0000_0008,

//unpriv. regs
parameter TCU_REGADDR_COMMAND   = TCU_REGADDR_START + 32'h0000_0010,
parameter TCU_REGADDR_DATA_ADDR = TCU_REGADDR_START + 32'h0000_0018,
parameter TCU_REGADDR_DATA_SIZE = TCU_REGADDR_START + 32'h0000_0020,
parameter TCU_REGADDR_ARG1      = TCU_REGADDR_START + 32'h0000_0028,
parameter TCU_REGADDR_CUR_TIME  = TCU_REGADDR_START + 32'h0000_0030,
parameter TCU_REGADDR_PRINT     = TCU_REGADDR_START + 32'h0000_0038,

//ep regs
parameter TCU_REGADDR_EP_START = TCU_REGADDR_START + 32'h0000_0040,

//print buffer
parameter TCU_REGADDR_PRINT_BUF = TCU_REGADDR_EP_START + TCU_EP_REG_COUNT*TCU_EP_REG_SIZE,

//priv. regs
parameter TCU_REGADDR_CORE_REQ     = TCU_REGADDR_START + 32'h0000_2000,
parameter TCU_REGADDR_PRIV_CMD     = TCU_REGADDR_START + 32'h0000_2008,
parameter TCU_REGADDR_PRIV_CMD_ARG = TCU_REGADDR_START + 32'h0000_2010,
parameter TCU_REGADDR_CUR_VPE      = TCU_REGADDR_START + 32'h0000_2018,

//TCU status vector
parameter TCU_REGADDR_TCU_STATUS          = TCU_REGADDR_START + 32'h0000_3000,
parameter TCU_REGADDR_TCU_RESET           = TCU_REGADDR_START + 32'h0000_3008,
parameter TCU_REGADDR_TCU_CTRL_FLIT_COUNT = TCU_REGADDR_START + 32'h0000_3010,
parameter TCU_REGADDR_TCU_BYP_FLIT_COUNT  = TCU_REGADDR_START + 32'h0000_3018,
parameter TCU_REGADDR_TCU_DROP_FLIT_COUNT = TCU_REGADDR_START + 32'h0000_3020,

//core-specific config regs
parameter TCU_REGADDR_CORE_CFG_START = TCU_REGADDR_TCU_STATUS + TCU_STATUS_REG_COUNT*TCU_STATUS_REG_SIZE,

//addr of log mem
parameter TCU_REGADDR_TCU_LOG = TCU_REGADDR_START + 32'h0100_0000,

//---------------
//unprivileged commands
parameter TCU_OPCODE_SIZE    = 4,
parameter TCU_OPCODE_IDLE    = 4'd0,
parameter TCU_OPCODE_SEND    = 4'd1,
parameter TCU_OPCODE_REPLY   = 4'd2,
parameter TCU_OPCODE_READ    = 4'd3,
parameter TCU_OPCODE_WRITE   = 4'd4,
parameter TCU_OPCODE_FETCH   = 4'd5,
parameter TCU_OPCODE_ACK_MSG = 4'd6,

//internal opcodes
parameter TCU_OPCODE_WRITE_RSP   = 4'd7,
parameter TCU_OPCODE_WRITE_RSP_2 = 4'd8,
parameter TCU_OPCODE_WRITE_ERROR = 4'd9,

//external opcodes
parameter TCU_OPCODE_EXT_IDLE  = 4'd0,
parameter TCU_OPCODE_EXT_INVEP = 4'd1,

//privileged commands
parameter TCU_OPCODE_PRIV_IDLE      = 4'd0,
parameter TCU_OPCODE_PRIV_INV_PAGE  = 4'd1,
parameter TCU_OPCODE_PRIV_INV_TLB   = 4'd2,
parameter TCU_OPCODE_PRIV_INS_TLB   = 4'd3,
parameter TCU_OPCODE_PRIV_XCHG_VPE  = 4'd4,
parameter TCU_OPCODE_PRIV_SET_TIMER = 4'd5,
parameter TCU_OPCODE_PRIV_ABORT_CMD = 4'd6,

//ep types
parameter TCU_EP_TYPE_SIZE    = 3,
parameter TCU_EP_TYPE_INVALID = 3'd0,
parameter TCU_EP_TYPE_SEND    = 3'd1,
parameter TCU_EP_TYPE_RECEIVE = 3'd2,
parameter TCU_EP_TYPE_MEMORY  = 3'd3,

//hd flags
parameter TCU_HD_FLAG_SIZE  = 1,
parameter TCU_HD_FLAG_REPLY = 1'b1,

//permission flags
parameter TCU_MEMFLAG_SIZE = 4,
parameter TCU_MEMFLAG_R    = 4'b0001,
parameter TCU_MEMFLAG_W    = 4'b0010,
parameter TCU_MEMFLAG_RW   = 4'b0011,

//error types
parameter TCU_ERROR_SIZE               = 5,
parameter TCU_ERROR_NONE               = 5'd0,
parameter TCU_ERROR_NO_MEP             = 5'd1,
parameter TCU_ERROR_NO_SEP             = 5'd2,
parameter TCU_ERROR_NO_REP             = 5'd3,
parameter TCU_ERROR_FOREIGN_EP         = 5'd4,
parameter TCU_ERROR_SEND_REPLY_EP      = 5'd5,
parameter TCU_ERROR_RECV_GONE          = 5'd6,
parameter TCU_ERROR_RECV_NO_SPACE      = 5'd7,
parameter TCU_ERROR_REPLIES_DISABLED   = 5'd8,
parameter TCU_ERROR_OUT_OF_BOUNDS      = 5'd9,
parameter TCU_ERROR_NO_CREDITS         = 5'd10,
parameter TCU_ERROR_NO_PERM            = 5'd11,
parameter TCU_ERROR_INV_MSG_OFF        = 5'd12,
parameter TCU_ERROR_TRANSLATION_FAULT  = 5'd13,
parameter TCU_ERROR_ABORT              = 5'd14,
parameter TCU_ERROR_UNKNOWN_CMD        = 5'd15,
parameter TCU_ERROR_RECV_OUT_OF_BOUNDS = 5'd16,
parameter TCU_ERROR_RECV_INV_RPL_EPS   = 5'd17,
parameter TCU_ERROR_SEND_INV_CRD_EP    = 5'd18,
parameter TCU_ERROR_SEND_INV_MSG_SZ    = 5'd19,
parameter TCU_ERROR_TIMEOUT_MEM        = 5'd20,
parameter TCU_ERROR_TIMEOUT_NOC        = 5'd21,
parameter TCU_ERROR_PAGE_BOUNDARY      = 5'd22,
parameter TCU_ERROR_MSG_UNALIGNED      = 5'd23,
parameter TCU_ERROR_TLB_MISS           = 5'd24,
parameter TCU_ERROR_TLB_FULL           = 5'd25,
parameter TCU_ERROR_CRITICAL           = 5'd31,

//TLB commands (internal)
parameter TCU_TLB_CMD_SIZE        = 2,
parameter TCU_TLB_CMD_WRITE_ENTRY = 2'h0,
parameter TCU_TLB_CMD_READ_ENTRY  = 2'h1,
parameter TCU_TLB_CMD_DEL_ENTRY   = 2'h2,
parameter TCU_TLB_CMD_CLEAR       = 2'h3,

//Log IDs
parameter TCU_LOG_ID_SIZE                     = 8,
parameter TCU_LOG_NONE                        = 8'd0,
parameter TCU_LOG_CMD_SEND                    = 8'd1,
parameter TCU_LOG_CMD_REPLY                   = 8'd2,
parameter TCU_LOG_CMD_READ                    = 8'd3,
parameter TCU_LOG_CMD_WRITE                   = 8'd4,
parameter TCU_LOG_CMD_FETCH                   = 8'd5,
parameter TCU_LOG_CMD_ACK_MSG                 = 8'd6,
parameter TCU_LOG_CMD_FINISH                  = 8'd7,
parameter TCU_LOG_RECV_FINISH                 = 8'd8,
parameter TCU_LOG_CMD_EXT_INVEP               = 8'd9,
parameter TCU_LOG_CMD_EXT_FINISH              = 8'd10,
parameter TCU_LOG_NOC_REG_WRITE_ERR           = 8'd11,
parameter TCU_LOG_NOC_REG_WRITE               = 8'd12,
parameter TCU_LOG_NOC_READ_RSP                = 8'd13,
parameter TCU_LOG_NOC_READ_RSP_ERR            = 8'd14,
parameter TCU_LOG_NOC_READ_RSP_DONE           = 8'd15,
parameter TCU_LOG_NOC_WRITE                   = 8'd16,
parameter TCU_LOG_NOC_READ_ERR                = 8'd17,
parameter TCU_LOG_NOC_READ                    = 8'd18,
parameter TCU_LOG_NOC_MSG                     = 8'd19,
parameter TCU_LOG_NOC_MSG_INV                 = 8'd20,
parameter TCU_LOG_NOC_WRITE_ACK               = 8'd21,
parameter TCU_LOG_NOC_MSG_ACK                 = 8'd22,
parameter TCU_LOG_NOC_ACK_ERR                 = 8'd23,
parameter TCU_LOG_NOC_ERROR                   = 8'd24,
parameter TCU_LOG_NOC_ERROR_UNEXP             = 8'd25,
parameter TCU_LOG_NOC_INVMODE                 = 8'd26,
parameter TCU_LOG_NOC_INVFLIT                 = 8'd27,
parameter TCU_LOG_CMD_PRIV_INV_PAGE           = 8'd28,
parameter TCU_LOG_CMD_PRIV_INV_TLB            = 8'd29,
parameter TCU_LOG_CMD_PRIV_INS_TLB            = 8'd30,
parameter TCU_LOG_CMD_PRIV_XCHG_VPE           = 8'd31,
parameter TCU_LOG_CMD_PRIV_SET_TIMER          = 8'd32,
parameter TCU_LOG_CMD_PRIV_ABORT              = 8'd33,
parameter TCU_LOG_CMD_PRIV_FINISH             = 8'd34,
parameter TCU_LOG_PRIV_CORE_REQ_FORMSG        = 8'd35,
parameter TCU_LOG_PRIV_CORE_REQ_FORMSG_FINISH = 8'd36,
parameter TCU_LOG_PRIV_TLB_WRITE_ENTRY        = 8'd37,
parameter TCU_LOG_PRIV_TLB_READ_ENTRY         = 8'd38,
parameter TCU_LOG_PRIV_TLB_DEL_ENTRY          = 8'd39,
parameter TCU_LOG_PRIV_CUR_VPE_CHANGE         = 8'd40,
parameter TCU_LOG_PRIV_TIMER_INTR             = 8'd41,
parameter TCU_LOG_PMP_ACCESS_DENIED           = 8'd42,



//---------------
//constants

parameter TCU_EP_SIZE = 16,
parameter TCU_ARG0_SIZE = 32,
parameter TCU_EXT_ARG_SIZE = 64-TCU_ERROR_SIZE-TCU_OPCODE_SIZE,  //55
parameter TCU_PRIV_ARG_SIZE = 64-TCU_ERROR_SIZE-TCU_OPCODE_SIZE, //55

parameter TCU_CHIPID_SIZE = 6,
parameter TCU_PEID_SIZE = 8,
parameter TCU_CRD_SIZE = 6,

parameter TCU_VPEID_SIZE = 16,
parameter TCU_VPE_MSGS_SIZE = 16,
parameter TCU_VPEID_INVALID = {TCU_VPEID_SIZE{1'b1}},

parameter TCU_SLOT_SIZE = 6,
parameter TCU_RSIZE_SIZE = 4,
parameter TCU_MSGLEN_SIZE = 13,

parameter TCU_STATUS_SIZE = 64,

parameter TCU_FLITCOUNT_SIZE = 32,

parameter TCU_VIRTADDR_SIZE = 64,
parameter TCU_PHYSADDR_SIZE = 32,

parameter TCU_TLB_VPEID_SIZE    = TCU_VPEID_SIZE,
parameter TCU_TLB_VIRTPAGE_SIZE = 52,
parameter TCU_TLB_PHYSPAGE_SIZE = 20,
parameter TCU_TLB_PERM_SIZE     = 3,
parameter TCU_TLB_DATA_SIZE     = TCU_TLB_PERM_SIZE+TCU_TLB_PHYSPAGE_SIZE+TCU_TLB_VIRTPAGE_SIZE+TCU_TLB_VPEID_SIZE,

parameter TCU_TLB_PERM_READ  = TCU_MEMFLAG_R[TCU_TLB_PERM_SIZE-1:0],
parameter TCU_TLB_PERM_WRITE = TCU_MEMFLAG_W[TCU_TLB_PERM_SIZE-1:0],
parameter TCU_TLB_PERM_FIXED = 3'b100,

parameter TCU_PAGE_SIZE_4KB       = 32'h1000, //4096
parameter TCU_PAGEOFFSET_SIZE_4KB = TCU_PHYSADDR_SIZE-TCU_TLB_PHYSPAGE_SIZE,    //12 (same for virt. addr.)

//data width of core request, without type field
parameter TCU_CORE_REQ_FORMSG_SIZE = TCU_VPEID_SIZE+TCU_EP_SIZE  //32
