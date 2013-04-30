LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all; 
	
entity add32 is 
	port ( 
		input1 : in STD_LOGIC_VECTOR(31 downto 0); 
		input2 : in STD_LOGIC_VECTOR(31 downto 0); 
		output : out bit_VECTOR(31 downto 0)
		); 
end add32; 

architecture main of add32 is 
begin 
 
		
	output <= to_bitvector(input1 + input2);
	
end main; 