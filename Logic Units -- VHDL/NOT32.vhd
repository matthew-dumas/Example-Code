entity NOT32 is
	port(
			inVector	:in bit_vector(31 downto 0);
			outVector	:out bit_vector(31 downto 0)
		);
end NOT32;
architecture test of NOT32 is
begin
	outVector(0) <= not inVector(0);
	outVector(1) <= not inVector(1);
	outVector(2) <= not inVector(2);
	outVector(3) <= not inVector(3);
	outVector(4) <= not inVector(4);
	outVector(5) <= not inVector(5);
	outVector(6) <= not inVector(6);
	outVector(7) <= not inVector(7);
	outVector(8) <= not inVector(8);
	outVector(9) <= not inVector(9);
	outVector(10) <= not inVector(10);
	outVector(11) <= not inVector(11);
	outVector(12) <= not inVector(12);
	outVector(13) <= not inVector(13);
	outVector(14) <= not inVector(14);
	outVector(15) <= not inVector(15);
	outVector(16) <= not inVector(16);
	outVector(17) <= not inVector(17);
	outVector(18) <= not inVector(18);
	outVector(19) <= not inVector(19);
	outVector(20) <= not inVector(20);
	outVector(21) <= not inVector(21);
	outVector(22) <= not inVector(22);
	outVector(23) <= not inVector(23);
	outVector(24) <= not inVector(24);
	outVector(25) <= not inVector(25);
	outVector(26) <= not inVector(26);
	outVector(27) <= not inVector(27);
	outVector(28) <= not inVector(28);
	outVector(29) <= not inVector(29);
	outVector(30) <= not inVector(30);
	outVector(31) <= not inVector(31);
end test;