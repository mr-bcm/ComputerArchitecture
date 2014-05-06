
library IEEE; 
use IEEE.STD_LOGIC_1164.all;

entity maindec is -- main control decoder
  port(op:                 in  STD_LOGIC_VECTOR(5 downto 0);
       memtoreg, memwrite: out STD_LOGIC;
       branch:			      out STD_LOGIC;
		 bc:						out STD_LOGIC;	-- Branch choice, chooses between bne(1) and beq(0)
		 alusrc: 				out STD_LOGIC_VECTOR(1 downto 0);
       regdst, regwrite:   out STD_LOGIC;
       jump:               out STD_LOGIC;
       aluop:              out  STD_LOGIC_VECTOR(1 downto 0));
end;

architecture behave of maindec is
  signal controls: STD_LOGIC_VECTOR(10 downto 0);
begin
  process(op) begin
    case op is
      when "000000" => controls <= "01100000010"; -- Rtype
      when "100011" => controls <= "01010001000"; -- LW
      when "101011" => controls <= "00X1001X000"; -- SW
      when "000100" => controls <= "00X0010X001"; -- BEQ
		when "000101" => controls <= "10X0100X001"; -- BNE
      when "001000" => controls <= "01010000000"; -- ADDI
      when "000010" => controls <= "00XXXX0X1XX"; -- J
      when others   => controls <= "-----------"; -- illegal op
    end case;
  end process;

  bc 		  <= controls(10);
  regwrite <= controls(9);
  regdst   <= controls(8);
  alusrc   <= controls(7 downto 6);
  branch   <= controls(5);
  memwrite <= controls(4);
  memtoreg <= controls(3);
  jump     <= controls(2);
  aluop    <= controls(1 downto 0);
end;


