library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity outenc is
port (
    -- Clock and Reset
    clk_i               : in  std_logic;
    reset_i             : in  std_logic;
    -- Encoder inputs from Bitbus
    a_ext_i             : in  std_logic;
    b_ext_i             : in  std_logic;
    z_ext_i             : in  std_logic;
    data_ext_i          : in  std_logic;
    posn_i              : in  std_logic_vector(31 downto 0);
    enable_i            : in  std_logic;
    -- Encoder I/O Pads
    A_OUT               : out std_logic;
    B_OUT               : out std_logic;
    Z_OUT               : out std_logic;
    DATA_OUT            : out std_logic;
    CLK_IN              : in  std_logic;
    -- Block parameters
    GENERATOR_ERROR     : in  std_logic;
    PROTOCOL            : in  std_logic_vector(2 downto 0);
    BITS                : in  std_logic_vector(7 downto 0);
    QPERIOD             : in  std_logic_vector(31 downto 0);
    QPERIOD_WSTB        : in  std_logic;
    HEALTH              : out std_logic_vector(31 downto 0);
    QSTATE              : out std_logic_vector(31 downto 0)
);
end entity;

architecture rtl of outenc is

constant c_ABZ_PASSTHROUGH  : std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(4,3));
constant c_DATA_PASSTHROUGH : std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(5,3));
constant c_BISS             : std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(2,3));
constant c_enDat            : std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(3,3));

signal quad_a            : std_logic;
signal quad_b            : std_logic;
signal sdat              : std_logic;
signal bdat              : std_logic;
signal health_biss_slave : std_logic_vector(31 downto 0);

begin

-- Assign outputs
A_OUT <= a_ext_i when (PROTOCOL = c_ABZ_PASSTHROUGH) else quad_a;
B_OUT <= b_ext_i when (PROTOCOL = c_ABZ_PASSTHROUGH) else quad_b;
Z_OUT <= z_ext_i when (PROTOCOL = c_ABZ_PASSTHROUGH) else '0';
DATA_OUT <= data_ext_i when (PROTOCOL = c_DATA_PASSTHROUGH) else
            bdat when (PROTOCOL = c_BISS) else sdat;

--
-- INCREMENTAL OUT
--
qenc_inst : entity work.qenc
port map (
    clk_i           => clk_i,
    reset_i         => reset_i,
    QPERIOD         => QPERIOD,
    QPERIOD_WSTB    => QPERIOD_WSTB,
    QSTATE          => QSTATE,
    enable_i        => enable_i,
    posn_i          => posn_i,
    a_o             => quad_a,
    b_o             => quad_b
);

--
-- SSI SLAVE
--
ssi_slave_inst : entity work.ssi_slave
port map (
    clk_i           => clk_i,
    reset_i         => reset_i,
    BITS            => BITS,
    posn_i          => posn_i,
    ssi_sck_i       => CLK_IN,
    ssi_dat_o       => sdat
);

--
-- BISS SLAVE
--
biss_slave_inst : entity work.biss_slave
port map (
    clk_i             => clk_i,
    reset_i           => reset_i,
    BITS              => BITS,
    enable_i          => enable_i,
    GENERATOR_ERROR   => GENERATOR_ERROR,
    health_o          => health_biss_slave,
    posn_i            => posn_i,
    biss_sck_i        => CLK_IN,
    biss_dat_o        => bdat
);

--------------------------------------------------------------------------
-- Position Data and STATUS readback multiplexer
--
--  Link status information is valid only for loopback configuration
--------------------------------------------------------------------------
process(clk_i)
begin
    if rising_edge(clk_i) then
        case (PROTOCOL) is
            when "000"  =>              -- INC
                HEALTH <= (others=>'0');

            when "001"  =>              -- SSI & Loopback
                HEALTH <= (others=>'0');

            when "010"  =>              -- BISS & Loopback
                HEALTH <= health_biss_slave;
                
            when c_enDat =>             -- enDat 
                HEALTH <= std_logic_vector(to_unsigned(2,32)); --ENDAT not implemented
                
            when others =>
                HEALTH <= (others=>'0');
                
        end case;
    end if;
end process;
end rtl;
