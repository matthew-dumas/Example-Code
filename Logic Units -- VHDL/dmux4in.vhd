entity dmux4in is 
	port ( 
	    input : in bit; 
		sel   : in bit_vector(1 downto 0); 
		A     : out bit;
		B     : out bit;
		C     : out bit;
		D     : out bit
		); 
end dmux4in; 

architecture main of dmux4in is 
begin 

 	A <= not(sel(0)) and not(sel(1)) and input;
	B <= sel(0) and not(sel(1)) and input;
	C <= not(sel(0)) and sel(1) and input;
	D <= sel(0) and sel(1) and input;
end main;