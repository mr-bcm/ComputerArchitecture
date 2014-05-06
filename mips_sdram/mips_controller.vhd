library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controller is -- single cycle control decoder
  port(op, funct:          in  STD_LOGIC_VECTOR(5 downto 0);
       zero:               in  STD_LOGIC;
       memtoreg, memwrite: out STD_LOGIC;
       pcsrc:      			out STD_LOGIC;
		 alusrc: 				out STD_LOGIC_VECTOR(1 downto 0);
       regdst, regwrite:   out STD_LOGIC;
       jump:               out STD_LOGIC;
       alucontrol:         out STD_LOGIC_VECTOR(2 downto 0));
end;

architecture struct of controller is
  component maindec
    port(op:                 in  STD_LOGIC_VECTOR(5 downto 0);
         memtoreg, memwrite: out STD_LOGIC;
         branch:     		  out STD_LOGIC;
			bc:					  out STD_LOGIC;	-- Branch choice, chooses between bne(1) and beq(0)
			alusrc: 				  out STD_LOGIC_VECTOR(1 downto 0);
         regdst, regwrite:   out STD_LOGIC;
         jump:               out STD_LOGIC;
         aluop:              out  STD_LOGIC_VECTOR(1 downto 0));
  end component;
  component aludec
    port(funct:      in  STD_LOGIC_VECTOR(5 downto 0);
         aluop:      in  STD_LOGIC_VECTOR(1 downto 0);
         alucontrol: out STD_LOGIC_VECTOR(2 downto 0));------------------------------------------------------------------
  end component;
  
  component mux3
    port(d0, d1: in  STD_LOGIC;
         s:      in  STD_LOGIC;
         y:      out STD_LOGIC);
  end component;
  
  signal aluop: STD_LOGIC_VECTOR(1 downto 0);
  signal branch, bc: STD_LOGIC;
  signal b1, b2 : STD_LOGIC;
begin
  md: maindec port map(op, memtoreg, memwrite, branch, bc,
                       alusrc, regdst, regwrite, jump, aluop);
  ad: aludec port map(funct, aluop, alucontrol);
  
  b1 <= branch and zero;
  
  b2 <= branch and (not zero);
  
  pcsrcmux: mux3 port map(b1, b2, bc, pcsrc); -- b1 = beq, b2 = bne, bc = branch choice, pcsrc = pcsrc
end;