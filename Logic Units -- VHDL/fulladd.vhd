entity fulladd is
	port ( 
		input1 : in bit; 
		input2 : in bit; 
		input3 : in bit; 
		carry  : out bit; 
		output : out bit
		); 
end fulladd; 

architecture main of fulladd is 

component halfadd  
	port ( 
		input1  : in bit;
		input2  : in bit; 
		output  : out bit; 
		carry   : out bit 
		); 
end component; 

signal sum : bit := '0'; 
signal car : bit := '0'; 
signal car2 : bit := '0'; 

begin 

	half1 : halfadd port map ( input1, input2, sum, car); 
    half2 : halfadd port map ( sum, input3, output, car2); 
	
	carry <= car xor car2; 

end main;