-------------------------------------------------------------------------------------------
--- xtea-project
--- -> testbench
-------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity xtea_tb is
end entity;



architecture behavioral of xtea_tb is
	component xtea is
	        port(clk: in std_logic;
        	     rst,en : in std_logic;
        	     rdy : out std_logic;
        	     op : in std_logic; --0 : encipher, 1 : decipher
        	     v0_in,v1_in : in std_logic_vector(31 downto 0);
        	     key0, key1, key2, key3 : in std_logic_vector(31 downto 0);
        	     sum_in, delta : in std_logic_vector(31 downto 0);
        	     v0_out, v1_out : out std_logic_vector(31 downto 0));
	end component;
	signal clk, rst,en,rdy : std_logic;
	signal v0_in,v1_in,key0,key1,key2,key3,sum_in,delta,v0_out,v1_out : std_logic_vector(31 downto 0);
	signal v0_enc_out, v1_enc_out : std_logic_vector(31 downto 0);
	signal enc_rdy : std_logic := '0';
	signal e_v0_out, e_v1_out : std_logic_vector(31 downto 0);


begin
	comp_encipher : xtea
		port map(clk => clk, rst => rst, en => en, rdy => enc_rdy, op => '0', v0_in => v0_in, v1_in => v1_in, key0=>key0, key1=>key1, key2=>key2, key3=>key3, sum_in=>sum_in, delta =>delta, v0_out => v0_enc_out, v1_out => v1_enc_out);
	comp_decipher : xtea
		port map(clk => clk, rst => rst, en => enc_rdy, rdy => rdy, op => '1', v0_in => v0_enc_out, v1_in => v1_enc_out, key0 => key0, key1 => key1, key2 => key2, key3 => key3, sum_in => x"8dde6e40", delta => delta, v0_out => v0_out, v1_out => v1_out);  
	
	
			clk_proc : process
			begin
				clk <= '1';
				wait for 10 ns;
				clk <= '0';
				wait for 10 ns;
			end process;

			 stim_proc : process
			 begin
				 rst <='1';
				 wait for 100 ns;
				 en <= '1';
				 rst   <= '0';
				 v0_in <= x"00000020";
				 v1_in <= x"00000020";
				 key0  <= x"00000020";
				 key1  <= x"00000020";
				 key2  <= x"00000020";
				 key3  <= x"00000020";
				 delta <= x"9E3779B9";
				 sum_in<= x"00000000";
			wait for 50000 ns;

			end process;
end behavioral;



