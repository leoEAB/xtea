-------------------------------------------------------------------------------
-- xtea-project
-- -> encipher_comp
--	-> Addierer
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- Entity declaration
-------------------------------------------------------------------------------

entity add is
	port(rst, en, clk : in std_logic;
	     rdy : out std_logic;
	     A, B  : in unsigned(31 downto 0);
	     Y : out unsigned(31 downto 0));
end add;

-------------------------------------------------------------------------------
-- Architecture description
-------------------------------------------------------------------------------

architecture behavioral of add is

	-- Signal desclaration
	-----------------------------------------------------------------------

	signal s_Y : unsigned(31 downto 0) := (others => '0');

begin
	
	s_Y <= A + B;
	
	process(en, rst, clk)
	begin
		if rst = '1' then
			Y <= (others => '0');
			rdy <= '0';
		elsif clk'event and clk = '1' and en = '1' then
			Y <= s_Y;
			rdy <= '1';
		end if;
	end process;
end behavioral;


