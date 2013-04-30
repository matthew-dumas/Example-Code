library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all;

entity inc32 is
	port ( 
		input  : in bit_vector(31 downto 0); 
		output : out bit_vector(31 downto 0)
		); 
end inc32; 

architecture main of inc32 is 
	component add32 
		port ( 
			input1 : in std_logic_vector(31 downto 0); 
			input2 : in std_logic_vector(31 downto 0); 
			output : out bit_vector(31 downto 0)
			); 
	end component;
	 
	signal temp : bit_vector(31 downto 0) := "00000000000000000000000000000001";
	
begin 
	
	inc : add32 port map (to_stdlogicvector(input), to_stdlogicvector(temp), output); 
	
end; 