------------------------------------------------------------------------
-- xtea-project
-- -> encipher
--	-> encipher component
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encipher_comp2 is
	port(clk: in std_logic;
	     rst,en : in std_logic;
	     rdy : out std_logic;
	     counter_in : in std_logic_vector(6 downto 0);
	     counter_out : out std_logic_vector(6 downto 0);
	     v0_in,v1_in : in std_logic_vector(31 downto 0);
	     key0, key1, key2, key3 : in std_logic_vector(31 downto 0);
	     sum_in, delta : in std_logic_vector(31 downto 0);
	     v0_out, v1_out : out std_logic_vector(31 downto 0);
	     sum_out : out std_logic_vector(31 downto 0));
end encipher_comp2;

architecture behavioral of encipher_comp2 is
	component add
		port(rst, en, clk : in std_logic;
		     rdy : out std_logic;
		     A, B : in unsigned(31 downto 0);
		     Y : out unsigned(31 downto 0));
	end component;
	--Unsigned
	signal u_v0_in, u_v1_in, u_v0_out, u_v1_out : unsigned(31 downto 0);
	signal u_sum_inc : unsigned(31 downto 0);
	signal u_v0_inter_1, u_v0_inter_2, u_v1_inter_1, u_v1_inter_2 : unsigned(31 downto 0); --Intermediate calculations for v0_out and v1_out
	signal u_counter_in, u_counter_out : unsigned(6 downto 0);
	signal u_key_p_v0, u_key_p_v1, u_key_v0, u_key_v1 : unsigned(31 downto 0);
	signal u_v0_xor_1, u_v0_xor_2, u_v1_xor_1, u_v1_xor_2 : unsigned(31 downto 0);
	--Array
	type key is array (3 downto 0) of unsigned(31 downto 0);
	signal u_key : key;
	--std_logic_vector
	signal s_key_p_v0, s_key_p_v1 : std_logic_vector(1 downto 0);
	signal test1,test2,test3,test4 : unsigned(31 downto 0);
	signal s_v0_out, s_v1_out, s_sum_out : std_logic_vector(31 downto 0);
	signal s_counter_out : std_logic_vector(6 downto 0);
	--add Components
	signal c_v0_add0_rdy, c_v0_add1_rdy, c_v0_add2_rdy, c_v1_add0_rdy, c_v1_add1_rdy, c_v1_add2_rdy, c_sum_inc_rdy, c_v0_add2_en, c_v1_add0_en, c_v1_add2_en : std_logic;

begin
	------------------------------------------------------------
	--Calculation of v0_out in 3 intermediate steps
        --Step 1
        --u_v0_inter_1 <=  ((u_v1_in sll 4) xor (u_v1_in srl 5)) + u_v1_in;
	u_v0_xor_1 <= (u_v1_in sll 4) xor (u_v1_in srl 5);
	c_v0_add0 : add
		port map(clk => clk, rst => rst, en => en, rdy => c_v0_add0_rdy, A => u_v0_xor_1, B => u_v1_in, Y => u_v0_inter_1);
	--Step 2
        --u_v0_inter_2 <= unsigned(sum_in) + u_key_v0;
	c_v0_add1 : add
		port map(clk => clk, rst => rst, en => en, rdy => c_v0_add1_rdy, A => unsigned(sum_in), B => u_key_v0, Y => u_v0_inter_2);
	--Step 3
	--u_v0_out <= unsigned(v0_in) + (u_v0_inter_1 xor u_v0_inter_2);
	u_v0_xor_2 <= (u_v0_inter_1 xor u_v0_inter_2);
	c_v0_add2_en <= c_v0_add0_rdy and c_v0_add1_rdy;
	c_v0_add2 : add
		port map(clk => clk, rst => rst, en => c_v0_add2_en, rdy => c_v0_add2_rdy, A => unsigned(v0_in), B => u_v0_xor_2, Y => u_v0_out);
	-----------------------------------------------------------
	--Calculation of v1_out in 2 intermediate steps
        --Step 1
        --u_v1_inter_1 <= ((u_v0_out sll 4) xor (u_v0_out srl 5)) + u_v0_out;
        u_v1_xor_1 <= (u_v0_out sll 4) xor (u_v0_out srl 5);
	c_v1_add0_en <= c_v0_add2_rdy and c_sum_inc_rdy;
	c_v1_add0 : add
		port map(clk => clk, rst => rst, en => c_v1_add0_en, rdy => c_v1_add0_rdy,  A => u_v1_xor_1, B=> u_v0_out, Y => u_v1_inter_1);
	--Step 2
        --u_v1_inter_2 <= u_sum_inc + u_key_v1;
	c_v1_add1 : add
		port map(clk => clk, rst => rst, en => c_sum_inc_rdy, rdy => c_v1_add1_rdy, A => u_sum_inc, B => u_key_v1, Y => u_v1_inter_2);
        --Step 3
        --u_v1_out <= unsigned(v1_in) + (u_v1_inter_1 xor u_v1_inter_2);
	u_v1_xor_2 <= u_v1_inter_1 xor u_v1_inter_2;
	c_v1_add2_en <= c_v1_add0_rdy and c_v1_add1_rdy;
	c_v1_add2 : add
		port map(clk => clk, rst => rst, en => c_v1_add2_en, rdy => c_v1_add2_rdy, A => unsigned(v1_in), B => u_v1_xor_2, Y => u_v1_out);
	-----------------------------------------------------------
        -- Incrementation of sum by delta
        --u_sum_inc <= unsigned(sum_in) + unsigned(delta);
	c_sum_inc : add
		port map(clk => clk, rst => rst, en => en, rdy => c_sum_inc_rdy, A => unsigned(sum_in), B => unsigned(delta), Y => u_sum_inc);
	-----------------------------------------------------------

	--Counter
	u_counter_in <= unsigned(counter_in);
	u_counter_out <= u_counter_in + "000001";
	s_counter_out <= std_logic_vector(u_counter_out);
	--key
	u_key(0) <= unsigned(key0);
	u_key(1) <= unsigned(key1);
	u_key(2) <= unsigned(key2);
	u_key(3) <= unsigned(key3);
	-------------------------------------------------
	-- key[?] parameter
	u_key_p_v0 <= unsigned(sum_in and x"00000003");
	s_key_p_v0 <= std_logic_vector(u_key_p_v0(1 downto 0));
	u_key_p_v1 <= (u_sum_inc srl 11) and x"00000003"; 
	s_key_p_v1 <= std_logic_vector(u_key_p_v1(1 downto 0));
	--for v0
	u_key_v0 <= u_key(0) when s_key_p_v0 = "00" else
                    u_key(1) when s_key_p_v0 = "01" else
                    u_key(2) when s_key_p_v0 = "10" else
                    u_key(3);
	
	--for v1
		u_key_v1 <= u_key(0) when s_key_p_v1 = "00" else
			    u_key(1) when s_key_p_v1 = "01" else
			    u_key(2) when s_key_p_v1 = "10" else
                	    u_key(3);
	-------------------------------------------------
	-- v0 v1 In to unsigned
	u_v0_in <= unsigned(v0_in); u_v1_in <= unsigned(v1_in);
	-----------------------------------------------
	
	--Change unsigned to std_logic_vector for Output
	s_v0_out <= std_logic_vector(u_v0_out);
	s_v1_out <= std_logic_vector(u_v1_out);
	s_sum_out <= std_logic_vector(u_sum_inc);
	process(clk)
	begin	
		if rst = '1'
		then 
			v0_out <= (others => '0');
			v1_out <= (others => '0');
			sum_out <= (others => '0');
			counter_out <= (others => '0');
			rdy <= '0';
		elsif clk'event and clk = '1'
		then
			if c_v1_add2_rdy = '1'
			then	
				v0_out <= s_v0_out;
				v1_out <= s_v1_out;
				sum_out <= s_sum_out;
				counter_out <= s_counter_out;
				rdy <= '1';
			end if;
		end if;
	end process;
end behavioral;
	
	     
