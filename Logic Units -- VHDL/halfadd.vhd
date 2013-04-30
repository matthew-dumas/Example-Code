entity halfadd is 
	port ( 
		input1  : in bit;
		input2  : in bit; 
		output  : out bit; 
		carry   : out bit 
		); 
end halfadd; 

architecture main of halfadd is 
begin 
	
	carry <= input1 and input2; 
	output <= input1 xor input2; 
	
end main; 