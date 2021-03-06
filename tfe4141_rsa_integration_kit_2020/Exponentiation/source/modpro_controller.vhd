----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.10.2020 11:56:02
-- Design Name: 
-- Module Name: modpro_controller - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity modpro_controller is
	generic (
		C_block_size : integer := 256;
		Max_bits     : integer := 264
	);
	port (
		clk           : in  std_logic;
		reset_n       : in  std_logic;

		input_signal  : in  std_logic;
		output_signal : out std_logic;

		B             : in  std_logic_vector (C_block_size - 1 downto 0);

		-- CSA Outputs
		csa_sum       : in  std_logic_vector (Max_bits - 1 downto 0);

		-- Register Outputs
		reg_S_out     : in  std_logic_vector(Max_bits downto 0);

		-- MUX select
		mux_S_sel    : out std_logic_vector(1 downto 0);
		mux_A_sel     : out std_logic_vector(1 downto 0);

		-- Register enable and reset
		enable_reg    : out std_logic;
		reset_reg     : out std_logic
		--enable_csa_temp_reg : out std_logic;
		--reset_csa_temp_reg : out std_logic
	);

end entity modpro_controller;

architecture Behavioral of modpro_controller is
	signal data_in_ready_i  : std_logic;
	signal data_out_valid_i : std_logic;

	type state is (IDLE, ONE, TWO_A, TWO_B, TWO_C, C_POS, TWO_D, THREE);
	signal current_state, next_state : state;

	signal counter                   : unsigned(7 downto 0);
    signal i_counter                 : std_logic_vector(1 downto 0);

begin

	CombProc : process (input_signal, current_state)
	begin
		case (current_state) is

				-- READY AND WAITING TO START MODPRO"
			when IDLE =>
				output_signal <= '0';
				mux_S_sel <= "10"; -- Select register S
				mux_A_sel <= "01"; -- Select A
				enable_reg    <= '0';
				reset_reg  <= '1';
				i_counter <= "00"; -- Reset counter
				
				if (input_signal = '0') then
					next_state <= IDLE;
					-- counter    <= (others => '0');
				else
					next_state <= ONE;
				end if;

			when ONE =>
				output_signal <= '0';
				mux_S_sel <= "10"; -- Select register S
				mux_A_sel <= "01"; -- Select A
				enable_reg    <= '0';
				reset_reg  <= '1';
				i_counter <= "01"; -- Do nothing with counter
				
				if (input_signal = '0') then
					next_state <= IDLE;
				else
					reset_reg  <= '0';
					-- counter    <= (others => '0');
					next_state <= TWO_A;
				end if;

			when TWO_A =>
				output_signal <= '0';
				mux_S_sel <= "10"; -- Select register S
				mux_A_sel <= "01"; -- Select A
				enable_reg    <= '0';
				reset_reg     <= '1';
				i_counter <= "01"; -- Do nothing with counter
				
				
				if (input_signal = '0') then
					next_state <= IDLE;
				else
					mux_S_sel <= "01"; -- Select 2S
					if (B(C_block_size - 1 - to_integer(counter)) = '1') then
						mux_A_sel <= "01"; -- Select A
					else
						mux_A_sel <= "00"; -- Select 0
					end if;
					enable_reg <= '1';
					next_state <= TWO_B;
				end if;

			when TWO_B =>
				output_signal <= '0';
				mux_S_sel <= "10"; -- Select register S
				mux_A_sel  <= "10"; -- Select -N
				enable_reg    <= '0';
				reset_reg     <= '1';
				
				i_counter <= "01"; -- Do nothing with counter
				
				if (input_signal = '0') then
					next_state <= IDLE;
				else
					mux_S_sel <= "10"; -- Select register S
					mux_A_sel  <= "10"; -- Select -N
					next_state <= TWO_C;

				end if;

			when TWO_C =>
				output_signal <= '0';
				mux_S_sel <= "10"; -- Select register S
				mux_A_sel  <= "10"; -- Select -N
				enable_reg    <= '0';
				reset_reg     <= '1';
				i_counter <= "01"; -- Do nothing with counter
				
				if (input_signal = '0') then
					next_state <= IDLE;
				else
					if (signed(csa_sum)) < 0 then
						enable_reg <= '0';
						if to_integer(counter) < 255 then
							-- counter    <= counter + '1';
							i_counter <= "11"; -- Increment counter
							next_state <= TWO_A;
							enable_reg <= '0';
						else
							next_state <= THREE;
						end if;
					else
						enable_reg <= '1';
						next_state <= C_POS;
					end if;
				end if;

			when C_POS =>
			    output_signal <= '0';
			    mux_S_sel <= "10"; -- Select register S
			    mux_A_sel  <= "10"; -- Select -N
			    enable_reg    <= '0';
			    reset_reg     <= '1';
			    i_counter <= "01"; -- Do nothing with counter
			    			    
				next_state <= TWO_D;

			when TWO_D =>
				output_signal <= '0';
				mux_S_sel     <= "10"; -- Select register S
				mux_A_sel     <= "10"; -- Select -N
				enable_reg    <= '0';
				reset_reg     <= '1';
				i_counter <= "01"; -- Do nothing with counter
				
				if (input_signal = '0') then
					next_state <= IDLE;
				else
					if (signed(csa_sum) < 0) then
						enable_reg <= '0';
					else
						enable_reg <= '1';
					end if;
					if to_integer(counter) < 255 then
						-- counter    <= counter + '1';
						i_counter <= "11"; -- Increment counter
						next_state <= TWO_A;
					else
						next_state <= THREE;
					end if;
				end if;

			when THREE =>
				output_signal <= '1';
				mux_S_sel <= "10"; -- Select register S
				mux_A_sel  <= "10"; -- Select -N
				enable_reg <= '0';
				reset_reg     <= '1';
				i_counter <= "01"; -- Do nothing with counter
				
				if (input_signal = '0') then
					output_signal <= '0';
					next_state    <= IDLE;
				else
					output_signal <= '1';
					next_state    <= THREE;
				end if;

			when others =>
				output_signal <= '0';
				mux_S_sel <= "10"; -- Select register S
				mux_A_sel  <= "10"; -- Select -N
				enable_reg    <= '0';
				reset_reg     <= '1';
				i_counter <= "01"; -- Do nothing with counter
				
				next_state    <= IDLE;
		end case;

	end process CombProc;

	SyncProc : process (reset_n, clk)
	begin
		if (reset_n = '0') then
			current_state <= IDLE;
		elsif rising_edge(clk) then
			current_state <= next_state;
			if (i_counter = "00") then
                counter <= (others => '0');
            elsif (i_counter = "11") then
                counter <= counter + 1;
            end if;
		end if;
	end process SyncProc;

end Behavioral;