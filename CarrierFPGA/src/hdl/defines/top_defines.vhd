library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package top_defines is

--------------------------------------------------------------------------
-- Memory Setup Parameters
-- Total of 128KByte memory is divided into 32 pages of 4K each.
-- Each page can address 16 design blocks
-- Each block can hold 64 DWORD registers

-- Number of total pages = 2**CSW
constant PAGE_NUM               : natural := 5;
-- Number of DWORDs per page = 2**PAGE_AW
constant PAGE_AW                : natural := 10;
-- Number of DWORS per block = 2**BLK_AW
constant BLK_AW                 : natural := 6;
-- Number of total block's bit width
constant BLK_NUM                : natural := PAGE_AW - BLK_AW;
--------------------------------------------------------------------------

-- Block instantiation numbers--------------------------------------------
constant TTLIN_NUM          : natural := 6;
constant TTLOUT_NUM         : natural := 10;
constant LVDSIN_NUM         : natural := 2;
constant LVDSOUT_NUM        : natural := 2;
constant LUT_NUM            : natural := 8;
constant SRGATE_NUM         : natural := 4;
constant DIV_NUM            : natural := 4;
constant PULSE_NUM          : natural := 4;
constant QDEC_NUM           : natural := 4;
constant ADDER_NUM          : natural := 2;
constant COUNTER_NUM        : natural := 8;
constant PGEN_NUM           : natural := 2;
constant POSENC_NUM         : natural := 4;
constant ENC_NUM            : natural := 4;
constant PCOMP_NUM          : natural := 4;
constant SEQ_NUM            : natural := 4;
constant BITS_NUM           : natural := 1;
--------------------------------------------------------------------------

-- Block instantiation numbers--------------------------------------------
constant LUT_INST           : boolean := true;
constant SRGATE_INST        : boolean := true;
constant DIV_INST           : boolean := true;
constant PULS_INST          : boolean := true;
constant COUNTER_INST       : boolean := true;
constant SEQ_INST           : boolean := true;
constant PGEN_INST          : boolean := true;

-- Bit Bus Width, Multiplexer Select Width -------------------------------
constant SBUSW              : natural := 128;
constant SBUSBW             : natural := 7;

-- Position Bus Width, Multiplexer Select Width.
constant PBUSW              : natural := 32;
constant PBUSBW             : natural := 5;

-- Extended Position Bus Width.
constant EBUSW              : natural := 12;
--------------------------------------------------------------------------

constant DCARD_NORMAL       : std_logic_vector(2 downto 0) := "000";
constant DCARD_LOOPBACK     : std_logic_vector(2 downto 0) := "111";

--
-- TYPEs :
--
type seq_t is
record
    repeats     : unsigned(31 downto 0);
    trig_mask   : std_logic_vector(3 downto 0);
    trig_cond   : std_logic_vector(3 downto 0);
    outp_ph1    : std_logic_vector(5 downto 0);
    outp_ph2    : std_logic_vector(5 downto 0);
    ph1_time    : unsigned(31 downto 0);
    ph2_time    : unsigned(31 downto 0);
end record;

type slow_packet is
record
    strobe      : std_logic;
    address     : std_logic_vector(PAGE_AW-1 downto 0);
    data        : std_logic_vector(31 downto 0);
end record;
type slow_packet_array is array(natural range <>) of slow_packet;

subtype std3_t is std_logic_vector(2 downto 0);
type std3_array is array(natural range <>) of std3_t;

subtype std4_t is std_logic_vector(3 downto 0);
type std4_array is array(natural range <>) of std4_t;

subtype std8_t is std_logic_vector(7 downto 0);
type std8_array is array(natural range <>) of std8_t;

subtype std16_t is std_logic_vector(15 downto 0);
type std16_array is array(natural range <>) of std16_t;

subtype std32_t is std_logic_vector(31 downto 0);
type std32_array is array(natural range <>) of std32_t;

subtype page_t is std_logic_vector(PAGE_AW-1 downto 0);
type page_array is array(natural range <>) of page_t;

subtype seq_out_t is std_logic_vector(5 downto 0);
type seq_out_array is array(natural range <>) of seq_out_t;

subtype sysbus_t is std_logic_vector(SBUSW-1 downto 0);
subtype posbus_t is std32_array(PBUSW-1 downto 0);
subtype extbus_t is std32_array(EBUSW-1 downto 0);

--
-- FUNCTIONs :
--

-- Return selected System Bus bit
function SBIT(sbus, sel : std_logic_vector)
    return std_logic;
function PFIELD(pbus : std32_array; sel : std_logic_vector)
    return std_logic_vector;

end top_defines;

package body top_defines is

-- Return selected System Bus bit
function SBIT(sbus, sel : std_logic_vector)
    return std_logic is
begin
    return sbus(to_integer(unsigned(sel)));
end SBIT;

-- Return selected Position Bus field
function PFIELD(pbus : std32_array; sel : std_logic_vector)
    return std_logic_vector is
begin
    return pbus(to_integer(unsigned(sel)));
end PFIELD;

end top_defines;

