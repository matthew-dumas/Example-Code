entity AND32 is
	port(
			a	:in bit_vector(31 downto 0);
			b	:in bit_vector(31 downto 0);
			output	:out bit_vector(31 downto 0)
		);
end AND32;
architecture test of AND32 is
begin
	output(0) <= a(0) and b(0);
	output(1) <= a(1) and b(1);
	output(2) <= a(2) and b(2);
	output(3) <= a(3) and b(3);
	output(4) <= a(4) and b(4);
	output(5) <= a(5) and b(5);
	output(6) <= a(6) and b(6);
	output(7) <= a(7) and b(7);
	output(8) <= a(8) and b(8);
	output(9) <= a(9) and b(9);
	output(10) <= a(10) and b(10);
	output(11) <= a(11) and b(11);
	output(12) <= a(12) and b(12);
	output(13) <= a(13) and b(13);
	output(14) <= a(14) and b(14);
	output(15) <= a(15) and b(15);
	output(16) <= a(16) and b(16);
	output(17) <= a(17) and b(17);
	output(18) <= a(18) and b(18);
	output(19) <= a(19) and b(19);
	output(20) <= a(20) and b(20);
	output(21) <= a(21) and b(21);
	output(22) <= a(22) and b(22);
	output(23) <= a(23) and b(23);
	output(24) <= a(24) and b(24);
	output(25) <= a(25) and b(25);
	output(26) <= a(26) and b(26);
	output(27) <= a(27) and b(27);
	output(28) <= a(28) and b(28);
	output(29) <= a(29) and b(29);
	output(30) <= a(30) and b(30);
	output(31) <= a(31) and b(31);
end test; 