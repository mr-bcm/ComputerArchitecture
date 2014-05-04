----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Brennan Metzelaar, James Corrigan, and Will Czifro
-- 
-- Create Date:    22:39:15 01/28/2008 
-- Design Name: 
-- Module Name:    vga_gen - Behavioral 
-- Project Name: 	 CMC_Pong
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity vgatest is
port(
	clk50_in : in std_logic;
	scancode1  : in std_logic_vector(7 downto 0);   -- scancode from keyboard to VGA
	red_out : out std_logic_vector(2 downto 0);
	green_out : out std_logic_vector(2 downto 0);
	blue_out : out std_logic_vector(2 downto 0);
	hs_out : out std_logic;
	vs_out : out std_logic
);
end vgatest;

architecture behavioral of vgatest is

signal clk25              : std_logic;
signal hcounter : integer range 0 to 800;	--[BCM] was integer range 0 to 800;
signal vcounter   : integer range 0 to 521;	--[BCM] was integer range 0 to 521;

-- ball
signal ball_hor, ball_hor_next : integer range 0 to 639;	-- horizontal range of where the ball can be on the screen (was 639?)
signal ball_ver, ball_ver_next : integer range 0 to 469;	-- vertical range of where the ball can be on the screen
signal verSpeed, horSpeed : integer := 3;	-- This controls the vertical and horizontal speed of the ball. It seems that if this is made faster, the screen boundaries of when the ball changes direction gets a little messed up.
signal ball_h : integer := 10;	-- ball height (ball size)
signal ball_w : integer := 10;	-- ball width (ball size)

-- ball animation
signal verSpeedReg, verSpeedNext : integer := 3;	-- variable of the vertical speed
signal horSpeedReg, horSpeedNext : integer := 3;	-- variable of the horizontal speed

-- left paddle
signal lp_ver, lp_ver_next : integer range 0 to 469;   -- range in which paddle can move vertically
signal left_pad_w : integer := 15;  -- left paddle width
signal left_pad_h : integer := 80;  -- left paddle height
signal left_pad_pos_hor : integer := 10;   -- horizontal position
signal left_pad_pos_ver : integer := 235;   -- vertical position

-- left paddle animation
signal lp_verSpeed : integer := 3;

-- right paddle
signal rp_ver, rp_ver_next : integer range 0 to 469;   -- range in which paddle can move vertically
signal right_pad_w : integer := 15;  -- left paddle width
signal right_pad_h : integer := 80;  -- left paddle height
signal right_pad_pos_hor : integer := 619;    -- horizontal position
signal right_pad_pos_ver : integer := 235;    -- vertical position

-- right paddle animation
signal rp_verSpeed : integer := 3;

-- separating line
signal line_w : integer := 8;	-- the width of the line
signal line_h : integer := 400;	-- the length (height) of the line

signal color: std_logic_vector(2 downto 0);
begin

-- generate a 25Mhz clock
process (clk50_in)
begin
  if clk50_in'event and clk50_in='1' then
    clk25 <= not clk25;
  end if;
end process;

-- update ball position
p0: process (clk25)
	variable cnt: integer;
begin
	if clk25'event and clk25='1' then
		cnt := cnt + 1;
		if cnt = 250000 then	-- Original value was changed from cnt = 25000000 to cnt = 250000. This was done to increase the speed of the ball.
			
			ball_hor <= ball_hor_next;	-- horizontal location of ball
			ball_ver <= ball_ver_next;	-- vertical location of ball
			verSpeedReg <= verSpeedNext;	-- updates vertical ball direction
			horSpeedReg <= horSpeedNext;	-- updates horizontal ball direction
			
			-- adding the vertical ball bounce
			if ball_ver < 10 then			-- If the ball goes past the 10th top pixel
				verSpeedNext <= verSpeed;	-- reverse direction.
			elsif ball_ver > 468 then		-- If the ball goes past the bottom 468 pixel
				verSpeedNext <= -verSpeed;	-- reverse direction.
			end if;
			
			-- adding the horizontal ball bounce
			if ball_hor < 4 then				-- If the ball goes past the left 4 pixel
				horSpeedNext <= horSpeed;	-- reverse direction.
			elsif ball_hor > 628 then		-- If the ball goes past the right 628 pixel
				horSpeedNext <= -horSpeed;	-- reverse direction.
			end if;
			ball_ver_next <= ball_ver + verSpeedReg;
			ball_hor_next <= ball_hor + horSpeedReg;
			
			cnt := 0;
			
		end if;
	end if;
end process;

p1: process (clk25)
   variable cnt : integer;
begin
   if clk25'event and clk25='1' then
	   cnt := cnt + 1;
	   if cnt = 250000 then
	      -- if left paddle ver position is less then upper sceen edge and scancode1 = w key, scancode move paddle up
		   if (left_pad_pos_ver + left_pad_h) < 628 and scancode1 = "00011101" then
		      left_pad_pos_ver <= left_pad_pos_ver + lp_verSpeed;
		   elsif left_pad_pos_ver > 0 and scancode1 = "00011011" then
		      left_pad_pos_ver <= left_pad_pos_ver - lp_verSpeed;
			end if;
		end if;
	end if;
end process;

p2: process (clk25)
   variable cnt : integer;
begin
   if clk25'event and clk25='1' then
	   cnt := cnt + 1;
	   if cnt = 250000 then
	      -- if left paddle ver position is less then upper sceen edge and scancode1 = w key, scancode move paddle up
		   if (right_pad_pos_ver + right_pad_h) < 628 and scancode1 = "01000100" then
		      right_pad_pos_ver <= right_pad_pos_ver + rp_verSpeed;
		   elsif left_pad_pos_ver > 0 and scancode1 = "01001011" then
		      right_pad_pos_ver <= right_pad_pos_ver - rp_verSpeed;
			end if;
		end if;
	end if;
end process;

p3: process (clk25, hcounter, vcounter)
	variable x: integer range 0 to 639;	-- screen dimensions
	variable y: integer range 0 to 479;
begin
	-- hcounter counts from 0 to 799
	-- vcounter counts from 0 to 520
	-- x coordinate: 0 - 639 (x = hcounter - 144, i.e., hcounter -Tpw-Tbp)
	-- y coordinate: 0 - 479 (y = vcounter - 31, i.e., vcounter-Tpw-Tbp)
	x := hcounter - 144;
	y := vcounter - 31;
  	if clk25'event and clk25 = '1' then
 		-- To draw a pixel in (x0, y0), simply test if the ray trace to it
		-- and set its color to any value between 1 to 7. The following example simply sets 
		-- the whole display area to a single-color wash, which is changed every one 
		-- second. 	
		
		-- Left Paddle, player 1
	 	if ( (( x > 20) and (x < 35)) and ((y > 100) and (y < 180)) ) then
      	red_out <= "000";
			green_out <= "000";
      	blue_out <= "111";
			
		-- Right Paddle, player 2
    	elsif ( (( x > 610) and (x < 625)) and ((y > 100) and (y < 180)) ) then
      	red_out <= "000";
			green_out <= "111";
      	blue_out <= "111";
			
		-- Ball	
		elsif ( (( x > ball_hor) and (x < (ball_hor + ball_h))) and ((y > ball_ver) and (y < (ball_ver + ball_w))) ) then
      	red_out <= "111";
			green_out <= "111";
      	blue_out <= "111";
			
		-- Center Line
		--elsif ( (( x > 317) and (x < 317 + line_w)) and ((y > 50) and (y < 50 + line_h)) ) then
      --	red_out <= "111";
		--	green_out <= "111";
      --	blue_out <= "111";
		
		-- Everything else is set to black
    	else
			-- if not traced, set it to "black" color
      	red_out <= "000";
      	green_out <= "000";
      	blue_out <= "000";
    	end if;
		
		-- Here is the timing for horizontal synchronization.
		-- (Refer to p. 24, Xilinx, Spartan-3 Starter Kit Board User Guide)
	 	-- Pulse width: Tpw = 96 cycles @ 25 MHz
	 	-- Back porch: Tbp = 48 cycles
		-- Display time: Tdisp = 640 cycles
	 	-- Front porch: Tfp = 16 cycles
		-- Sync pulse time (total cycles) Ts = 800 cycles

    	if hcounter > 0 and hcounter < 97 then
      	hs_out <= '0';
    	else
      	hs_out <= '1';
    	end if;
		-- Here is the timing for vertical synchronization.
		-- (Refer to p. 24, Xilinx, Spartan-3 Starter Kit Board User Guide)
	 	-- Pulse width: Tpw = 1600 cycles (2 lines) @ 25 MHz
	 	-- Back porch: Tbp = 23200 cycles (29 lines)
		-- Display time: Tdisp = 38400 cycles (480 lines)
	 	-- Front porch: Tfp = 8000 cycles (10 lines)
		-- Sync pulse time (total cycles) Ts = 416800 cycles (521 lines)
    	if vcounter > 0 and vcounter < 3 then
      	vs_out <= '0';
    	else
      	vs_out <= '1';
    	end if;
	 	-- horizontal counts from 0 to 799
    	hcounter <= hcounter+1;
    	if hcounter = 800 then
      	vcounter <= vcounter+1;
      	hcounter <= 0;
    	end if;
	 	-- vertical counts from 0 to 519
    	if vcounter = 521 then
      	vcounter <= 0;
    	end if;
  end if;
end process;

end behavioral;