----------------------------------------------------------------------------------
-- Company:        Whitworth University
-- Engineer:       Kent Jones
-- Create Date:    18:27:14 02/17/2014 
-- Design Name: 
-- Module Name:    VGA_KYBD_LAB - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VGA_KYBD_LAB is
	port(
	   -- external input/output signals for the ps2 keyboard
		clk       : in  std_logic;           -- main clock
		ps2_clk   : in  std_logic;           -- keyboard clock
		ps2_data  : in  std_logic;           -- keyboard data
		s         : out std_logic_vector(6 downto 0);  -- LED display

		-- external input/output signals for the vga module 
		clk50_in : in std_logic;
		red_out : out std_logic_vector(2 downto 0);
		green_out : out std_logic_vector(2 downto 0);
		blue_out : out std_logic_vector(2 downto 0);
		hs_out : out std_logic;
		vs_out : out std_logic
	);

end VGA_KYBD_LAB;

architecture Behavioral of VGA_KYBD_LAB is

	component test_kbd is
	  generic(
		 FREQ     :     natural := 100_000   -- frequency of main clock (KHz)
		 );
	  port(
		 clk       : in  std_logic;           -- main clock
		 ps2_clk   : in  std_logic;           -- keyboard clock
		 ps2_data  : in  std_logic;           -- keyboard data
		 s         : out std_logic_vector(6 downto 0);  -- LED display
		 scancode_bus  : out std_logic_vector(7 downto 0)   -- scancode from keyboard module
		 );
	end component;
	
	component vgatest is
	port(
		clk50_in : in std_logic;
		scancode  : in std_logic_vector(7 downto 0);   -- scancode from keyboard to VGA
		red_out : out std_logic_vector(2 downto 0);
		green_out : out std_logic_vector(2 downto 0);
		blue_out : out std_logic_vector(2 downto 0);
		hs_out : out std_logic;
		vs_out : out std_logic
	);
	end component;

	signal scancode_bus  : std_logic_vector(7 downto 0);   -- scancode from keyboard module

begin

	test_kbd_object : test_kbd port map( clk, ps2_clk, ps2_data, s, scancode_bus );
	
	vgatest_object : vgatest port map( clk50_in, scancode_bus, red_out, green_out, blue_out, hs_out, vs_out );
	
end Behavioral;

