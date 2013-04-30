entity DMUX8WAY is
	port(
		inBit	:in bit;
		sel		:in bit_vector(2 downto 0);
		outA	:out bit;
		outB	:out bit;
		outC	:out bit;
		outD	:out bit;
		outE	:out bit;
		outF	:out bit;
		outG	:out bit;
		outH	:out bit
		);
end DMUX8WAY;
architecture test of DMUX8WAY is
signal notSel0 : bit := '0';
signal notSel1 : bit := '0';
signal notSel2 : bit := '0';
signal choose1 : bit := '0';
signal choose2 : bit := '0';
signal choose3 : bit := '0';
signal choose4 : bit := '0';
signal chooseA : bit := '0';
signal chooseB : bit := '0';
signal chooseC : bit := '0';
signal chooseD : bit := '0';
signal chooseE : bit := '0';
signal chooseF : bit := '0';
signal chooseG : bit := '0';
signal chooseH : bit := '0';
begin
	notSel0 <= not sel(0);
	notSel1 <= not sel(1);
	notSel2 <= not sel(2);
	
	choose1 <= notSel1 and notSel0;		--if 00, could choose outA or outE
	choose2 <= notSel1 and sel(0);		--if 01, could choose outB or outF
	choose3 <= sel(1) and notSel0;	--if 10, could choose outC or outG
	choose4 <= sel(1) and sel(0); 		--if 11, could choose outD or outH
	
	--use MSB to determine between corresponding letters (A or E, B or F, etc.)
	chooseA <= notSel2 and choose1;
	chooseB <= notSel2 and choose2;
	chooseC <= notSel2 and choose3;
	chooseD <= notSel2 and choose4;
	chooseE <= sel(2) and choose1;
	chooseF <= sel(2) and choose2;
	chooseG <= sel(2) and choose3;
	chooseH <= sel(2) and choose4;
	
	outA <= inBit and chooseA;
	outB <= inBit and chooseB;
	outC <= inBit and chooseC;
	outD <= inBit and chooseD;
	outE <= inBit and chooseE;
	outF <= inBit and chooseF;
	outG <= inBit and chooseG;
	outH <= inBit and chooseH;
						
end test;