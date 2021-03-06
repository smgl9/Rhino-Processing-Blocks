----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:15:04 06/30/2014 
-- Design Name: 
-- Module Name:    r22sdf_even_last_stage - Behavioral 
-- Project Name: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity r22sdf_even_last_stage is
	generic(
		data_w : natural;
		del1_w : natural;
		del2_w : natural
	);
	port(
		clk,rst,en,s1,s2 : in std_logic;
		dinr,dini        : in std_logic_vector(data_w - 1 downto 0);
		doutr,douti      : out std_logic_vector(data_w + 1 downto 0)
	);
end r22sdf_even_last_stage;

architecture Behavioral of r22sdf_even_last_stage is
	COMPONENT BF2I
	   GENERIC(
			BF2I_data_w  : natural
		);
		PORT(
			s			    : in std_logic;
			xpr			 : in std_logic_vector  (BF2I_data_w  - 1 downto 0);
			xpi			 : in std_logic_vector  (BF2I_data_w  - 1 downto 0);
			xfr 			 : in std_logic_vector  (BF2I_data_w  downto 0);
			xfi 			 : in std_logic_vector  (BF2I_data_w  downto 0);
			znr          : out std_logic_vector (BF2I_data_w  downto 0);
			zni          : out std_logic_vector (BF2I_data_w  downto 0);
			zfr          : out std_logic_vector (BF2I_data_w  downto 0);
			zfi          : out std_logic_vector (BF2I_data_w  downto 0)
		);
	END COMPONENT;
	
	COMPONENT BF2II
		GENERIC(
			BF2II_data_w : natural
		);
		port(
			s			    : in std_logic;
			t			    : in std_logic;
			xpr			 : in std_logic_vector  (BF2II_data_w - 1 downto 0);
			xpi			 : in std_logic_vector  (BF2II_data_w - 1 downto 0);
			xfr 			 : in std_logic_vector  (BF2II_data_w downto 0);
			xfi 			 : in std_logic_vector  (BF2II_data_w downto 0);
			znr          : out std_logic_vector (BF2II_data_w downto 0);
			zni          : out std_logic_vector (BF2II_data_w downto 0);
			zfr          : out std_logic_vector (BF2II_data_w downto 0);
			zfi          : out std_logic_vector (BF2II_data_w downto 0)
		);
	END COMPONENT;
	
	COMPONENT shift_reg
		GENERIC(
			shift_reg_data_w : natural;
			depth  			  : natural
		);
		PORT(
			clk : IN  std_logic;
			rst : IN  std_logic;
			en  : in  std_logic;
			xr  : IN  std_logic_vector(shift_reg_data_w - 1 downto 0);
			xi  : IN  std_logic_vector(shift_reg_data_w - 1 downto 0);
			zr  : OUT  std_logic_vector(shift_reg_data_w - 1 downto 0);
			zi  : OUT  std_logic_vector(shift_reg_data_w - 1 downto 0)
		);
    END COMPONENT;

	 signal BF2I_zfr   : std_logic_vector(data_w downto 0) := (others => '0');
	 signal BF2I_zfi   : std_logic_vector(data_w downto 0) := (others => '0');
	 signal BF2I_znr   : std_logic_vector(data_w downto 0) := (others => '0');
	 signal BF2I_zni   : std_logic_vector(data_w downto 0) := (others => '0');
	 
	 signal BF2I_ram_xfr : std_logic_vector(data_w downto 0) := (others => '0');
	 signal BF2I_ram_xfi : std_logic_vector(data_w downto 0) := (others => '0');
	 
	 signal BF2II_zfr   : std_logic_vector(data_w + 1 downto 0) := (others => '0');
	 signal BF2II_zfi   : std_logic_vector(data_w + 1 downto 0) := (others => '0');
	 
	 signal BF2II_ram_xfr : std_logic_vector(data_w + 1 downto 0) := (others => '0');
	 signal BF2II_ram_xfi : std_logic_vector(data_w + 1 downto 0) := (others => '0');
	 
begin	
	-- stage instation of components
	BF2I_inst : BF2I
	GENERIC MAP(
			BF2I_data_w => data_w
	)
	PORT MAP(
		s			    => s1,
		xpr			 => dinr,
		xpi			 => dini,
		xfr 			 => BF2I_ram_xfr,
		xfi 			 => BF2I_ram_xfi,
		znr          => BF2I_znr,
		zni          => BF2I_zni,
		zfr          => BF2I_zfr,
		zfi          => BF2I_zfi
	);
	
	BF2I_RAM_inst : shift_reg
	GENERIC MAP(
		shift_reg_data_w => data_w + 1,
		depth  			  => del1_w
	)
	PORT MAP(
		clk => clk,
		rst => rst,
		en  => en,
		xr  => BF2I_zfr,
		xi  => BF2I_zfi,
		zr  => BF2I_ram_xfr,
		zi  => BF2I_ram_xfi
	);	 
	
	BF2II_inst : BF2II
	GENERIC MAP(
			BF2II_data_w => data_w + 1
	)
	PORT MAP(
		s   			 => s2,
		t   			 => s1,
		xpr			 => BF2I_znr,
		xpi			 => BF2I_zni,
		xfr 			 => BF2II_ram_xfr,
		xfi 			 => BF2II_ram_xfi,
		znr          => doutr,
		zni          => douti,
		zfr          => BF2II_zfr,
		zfi          => BF2II_zfi
	);
	
	BF2II_RAM_inst : shift_reg
	GENERIC MAP(
		shift_reg_data_w => data_w + 2,
		depth  			  => del2_w
	)
	PORT MAP(
		clk => clk,
		rst => rst,
		en  => en,
		xr  => BF2II_zfr,
		xi  => BF2II_zfi,
		zr  => BF2II_ram_xfr,
		zi  => BF2II_ram_xfi
	);
end Behavioral;



