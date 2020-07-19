------------------------------------------------------------
-- xtea-project
-- -> Pipeline
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

------------------------------------------------------------
-- Entity declaration
------------------------------------------------------------

entity encipher_pipeline is
	port(clk,rst : in std_logic;
	     rdy : out std_logic;
             v0_in, v1_in : in std_logic_vector(31 downto 0);
	     key0, key1, key2, key3: in std_logic_vector(31 downto 0);
	     sum_in,delta : in std_logic_vector(31 downto 0);
	     v0_out, v1_out: out std_logic_vector(31 downto 0));
end encipher_pipeline;

------------------------------------------------------------
-- Architecture description
------------------------------------------------------------

architecture behavioral of encipher_pipeline is
	
	-- Component declaration
	----------------------------------------------------

	component encipher_comp2
		port(clk,rst,en : in std_logic;
		     rdy : out std_logic;
		     counter_in : in std_logic_vector(6 downto 0);
		     counter_out : out std_logic_vector(6 downto 0);
		     v0_in,v1_in : in std_logic_vector(31 downto 0);
             	     key0, key1, key2, key3 : in std_logic_vector(31 downto 0);
             	     sum_in, delta : in std_logic_vector(31 downto 0);
             	     v0_out, v1_out : out std_logic_vector(31 downto 0);
             	     sum_out : out std_logic_vector(31 downto 0));
	end component;

	-- Signal declaration
	-----------------------------------------------------
	signal s_v0_in, s_v1_in, s_key0, s_key1, s_key2, s_key3, s_sum_in, s_delta, s_v0_out, s_v1_out, s_sum_out : std_logic_vector(31 downto 0);

	signal s_counter_end : std_logic_vector(6 downto 0);
	signal s_not_rst : std_logic;
	signal s_rdy : std_logic_vector(63 downto 0) := (others => '0');
	-- Array declaration
	-----------------------------------------------------
	type gen_array is array (0 to 63) of std_logic_vector(31 downto 0);
	signal a_v0_out, a_v1_out, a_sum_out : gen_array;
        type counter_array is array (0 to 63) of std_logic_vector(6 downto 0);
	signal a_counter_out : counter_array;	
begin
	s_v0_in <= v0_in;
	s_v1_in <= v1_in;
	s_key0 <= key0; s_key1 <= key1; s_key2 <= key2; s_key3 <= key3;
	s_sum_in <= sum_in;
	s_delta <= delta;
	s_not_rst <= not rst;
--Initializing the first encipher_component
	encipher_0 : encipher_comp2
		port map(clk => clk,
			 rst => rst,
			 en => s_not_rst,
			 rdy => s_rdy(0),
			 counter_in => "0000000",
			 counter_out => a_counter_out(0),
			 v0_in => s_v0_in,
			 v1_in => s_v1_in,
		 	 key0 => s_key0, key1 => s_key1, key2 => s_key2, key3 => s_key3,
		 	 sum_in => s_sum_in, 
		 	 delta => s_delta,
		 	 v0_out => a_v0_out(0),
		 	 v1_out => a_v1_out(0),
		 	 sum_out => a_sum_out(0));
--Initializing rest
	gen_encipher:
	for i in 1 to 62 generate
		encipher_x : encipher_comp2
			port map(clk => clk,
			         rst => rst,
				 en => s_rdy(i-1),
				 rdy => s_rdy(i),
				 counter_in => a_counter_out(i-1),
				 counter_out => a_counter_out(i),
				 v0_in => a_v0_out(i-1),
				 v1_in => a_v1_out(i-1),
				 key0 => s_key0, key1 => s_key1, key2 => s_key2, key3 => s_key3,
				 sum_in => a_sum_out(i-1),
				 delta => s_delta,
				 v0_out => a_v0_out(i),
				 v1_out => a_v1_out(i),
				 sum_out => a_sum_out(i));
	end generate gen_encipher;
--Initializing the last encipher_component
	encipher_63 : encipher_comp2
		port map(clk => clk,
			 rst => rst,
			 en => s_rdy(62),
			 rdy => s_rdy(63),
			 counter_in => a_counter_out(62),
			 counter_out => a_counter_out(63),
			 v0_in => a_v0_out(62),
		 	 v1_in => a_v1_out(62),
			 key0 => s_key0, key1 => s_key1, key2 => s_key2, key3 => s_key3,
			 sum_in => a_sum_out(62),
			 delta => s_delta,
			 v0_out => s_v0_out,
			 v1_out => s_v1_out,
			 sum_out => a_sum_out(63));
--Counter
	s_counter_end <= a_counter_out(63);

	
--Clk process
	process(clk)
	begin
		if rst = '1' then
			v0_out <= (others => '0');
			v1_out <= (others => '0');
		elsif clk'event and clk = '1' then
			if(s_counter_end(6) = '1')
			then 
				v0_out <= s_v0_out;
				v1_out <= s_v1_out;
				rdy <= '1';
			end if;
		end if;	

	end process;	

end behavioral;

