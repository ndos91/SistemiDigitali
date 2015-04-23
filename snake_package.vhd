library ieee;
use ieee.std_logic_1164.all;

use ieee.math_real.all;
use ieee.numeric_std.all;
--use work.vga_package.all;


package snake_package is

	type food_type is (POINT_T, MOUSE_T, NULL_F);	-- briciola o topo
	attribute enum_encoding_food : string;
	attribute enum_encoding_food of food_type : type is ("00 01 11");
	
	type snake_type is (HEAD_T, TAIL_T);	-- testa o coda
	attribute enum_encoding_snake : string;
	attribute enum_encoding_snake of snake_type : type is ("0 1");
	
	--type direction is (U, D, L, R, NULL_D);
	--attribute enum_encoding_dir : string;
	--attribute enum_encoding_dir of food_type : type is ("001 010 011 100 000");
	
	-- codifica delle direzioni:
	-- 000 = NULL_D
	-- 001 = U
	-- 010 = D
	-- 011 = R
	-- 100 = L
	
	constant FIELD_COLS : positive := 20;
	constant FIELD_ROWS : positive := 20;
	constant SNAKE_SIZE : positive := 3;
	constant FOOD_SIZE : positive := 1;
	--constant MOUSE_SIZE : positive := ?;
	--constant MOUSE_TIMER := positive := 10;
	constant SLOW : positive := 1;
	constant MEDIUM : positive := 2;
	constant FAST : positive := 3;
	constant INIT_DIR : std_logic_vector := "011";
	
	type field_cell_type is record -- singola cella del campo da gioco
		filled : std_logic; --0 cella vuota, 1 cella piena
		food : std_logic_vector(1 downto 0);	--00: NULL_F, 01: NORMAL FOOD, 10: MOUSE FOOD 
		checkpoint : std_logic_vector(2 downto 0);	-- direzione verso cui si è spostata la testa in quella cella quando vi è passata
		head : std_logic; --1 se la cella attuale contiene la testa, 0 altrimenti
	end record;
	
	-- tipo di dato relativo a un array di celle del campo da gioco
	type field_cell_array is array(natural range <>, natural range <>) of field_cell_type;
	
	type field_type is record	-- tipo di dato che rappresenta il campo da gioco
		cells : field_cell_array(0 to FIELD_COLS-1,0 TO FIELD_ROWS-1);	
	end record;
	
	type cell_position is record	-- tipo di dato che rappresenta le coordinate di una cella nel campo da gioco
		col : integer range 0 to (FIELD_COLS-1);
		row : integer range 0 to (FIELD_ROWS-1);
	end record;
	
	-- tipo di dato che rappresenta un array di coordinate delle celle
	--type tail_array is array(natural range<>) of cell_position;
	
	type snake is record		-- tipo di dato che modella il serpente 
		head : cell_position;
		tail :  cell_position;
		lenght : integer;
	end record;
	
	constant DEFAULT_POS : cell_position := (col => 10, row =>10);

end package;
