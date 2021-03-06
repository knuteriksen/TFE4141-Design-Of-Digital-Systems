----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.11.2020 13:53:34
-- Design Name: 
-- Module Name: csa_tb - Behavioral
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
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity csa_tb is
generic (
		C_block_size : integer := 256;
		Max_bits   : integer := 264
	);
 
end csa_tb;

architecture Behavioral of csa_tb is
signal a : std_logic_vector(Max_bits-1 downto 0);
signal b : std_logic_vector(Max_bits-1 downto 0);
signal carry_in : std_logic_vector(Max_bits-1 downto 0);

signal carry_out :  STD_LOGIC_VECTOR (Max_bits downto 0);
signal sum :  STD_LOGIC_VECTOR (Max_bits-1 downto 0);
constant CLK_PERIOD : time := 20ns;


begin

csa : entity work.csa
port map(

 a=>a,
 b=>b,
 carry_in=>carry_in,
 carry_out=>carry_out,
 sum=>sum
);

stimulus : process 
begin
    wait for 1*CLK_PERIOD;
    a        <= "00000000"&"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"&"10001100101";  -- 1125
    b        <= "00000000"&"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"&"00000000000";  -- 758
    carry_in <= "11111111"&"1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111"&"111011101011";  -- -277
    wait;
end process stimulus;


end Behavioral;
