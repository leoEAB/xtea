------------------------------------------------------------------------
-- xtea-project
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity xtea is
	port(clk: in std_logic;
	     rst: in std_logic;
	     rdy : out std_logic;
	     op : in std_logic; --0 : encipher, 1 : decipher
	     v0_in,v1_in : in std_logic_vector(31 downto 0);
	     key0, key1, key2, key3 : in std_logic_vector(31 downto 0);
	     sum_in, delta : in std_logic_vector(31 downto 0);
	     v0_out, v1_out : out std_logic_vector(31 downto 0));
end xtea;


architecture behavioral of xtea is
	component encipher_pipeline is
	port(clk,rst : in std_logic;
	     rdy : out std_logic;
             v0_in, v1_in : in std_logic_vector(31 downto 0);
	     key0, key1, key2, key3: in std_logic_vector(31 downto 0);
	     sum_in,delta : in std_logic_vector(31 downto 0);
	     v0_out, v1_out: out std_logic_vector(31 downto 0));
	end component;
	component decipher_pipeline is
	port(clk,rst : in std_logic;
	     rdy : out std_logic;
             v0_in, v1_in : in std_logic_vector(31 downto 0);
	     key0, key1, key2, key3: in std_logic_vector(31 downto 0);
	     sum_in,delta : in std_logic_vector(31 downto 0);
	     v0_out, v1_out: out std_logic_vector(31 downto 0));
	end component;
signal s_rdy, e_rdy, d_rdy : std_logic;
signal s_v0_out, s_v1_out, e_v0_out, e_v1_out, d_v0_out, d_v1_out : std_logic_vector(31 downto 0);
begin

	comp_e : encipher_pipeline
		port map(clk => clk, rst => rst, rdy => e_rdy, v0_in => v0_in, v1_in => v1_in, key0 => key0, key1 => key1, key2 => key2, key3 => key3, sum_in => sum_in, delta => delta, v0_out => e_v0_out, v1_out => e_v1_out);
	comp_d : decipher_pipeline
                port map(clk => clk, rst => rst, rdy => d_rdy, v0_in => v0_in, v1_in => v1_in, key0 => key0, key1 => key1, key2 => key2, key3 => key3, sum_in => sum_in, delta => delta, v0_out => d_v0_out, v1_out => d_v1_out);

	
	s_v0_out <= e_v0_out when op = '0' else
	    	    d_v0_out;
	s_v1_out <= e_v1_out when op = '0' else
                    d_v1_out;
	s_rdy <= e_rdy when op = '0' else
		 d_rdy;
	process(clk)
	begin
		if rst = '1' then
			v0_out <= (others => '0');
			v1_out <= (others => '0');
			rdy <= '0';
		elsif clk'event and clk = '1' and s_rdy = '1' then
			v0_out <= s_v0_out;
			v1_out <= s_v1_out;
			rdy <= '1';
		end if;
	end process;
end behavioral;
	
