entity fanout is 
	port ( 
		A : in bit; 
		B : out bit_vector(31 downto 0)
		); 
end fanout; 

architecture main of fanout is 
begin 
	
	B(0) <= A;
	B(1) <= A;
	B(2) <= A;
	B(3) <= A; 
	B(4) <= A; 
	B(5) <= A; 
	B(6) <= A; 
	B(7) <= A; 
	B(8) <= A; 
	B(9) <= A; 
	B(10) <= A; 
	B(11) <= A; 
	B(12) <= A; 
	B(13) <= A; 
	B(14) <= A; 
	B(15) <= A; 
	B(16) <= A; 
	B(17) <= A; 
	B(18) <= A; 
	B(19) <= A; 
	B(20) <= A; 
	B(21) <= A; 
	B(22) <= A; 
	B(23) <= A; 
	B(24) <= A; 
	B(25) <= A; 
	B(26) <= A; 
	B(27) <= A; 
	B(28) <= A; 
	B(29) <= A;
	B(30) <= A; 
	B(31) <= A;

end main; 
