library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
USE ieee.math_real.all;
use work.snake_package.all;

entity snake_datapath is 
	port (
		CLK : in std_logic;
		RESET_N : in std_logic;
		
		-- segnali di interazione con il CONTROLLER
		MOVE_UP : in std_logic;
		MOVE_DOWN : in std_logic;
		MOVE_RIGHT : in std_logic;
		MOVE_LEFT : in std_logic;
		CAN_MOVE_H_NV : out std_logic;
		--COLLISION : out std_logic;
		--EATEN_FOOD : out std_logic
		
		-- segnali di interazione con il generatore PRNG
		--RAND_NUM_ROW : in integer;
		--RAND_NUM_COL : in integer;
		--READY : in std_logic;
		--RERAND : out std_logic;
		
		-- segnali di interazione con la VIEW
		CELL_QUERY : in cell_position;
		CELL_CONTENT : out field_cell_type;
		
		LAST_MOVE_OUT : out std_logic_vector(2 downto 0);
		HEAD_ROW_OUT : out integer;
		HEAD_COL_OUT : out integer;
		TAIL_ROW_OUT : out integer;
		TAIL_COL_OUT : out integer
		
		
	);
end entity;

architecture RTL of snake_datapath is

	-- CAMPO DA GIOCO
	signal field : field_type;
	
	-- DATI PER IL MOVIMENTO
	signal curr_snake_pos : snake;		-- nuova posizione del serpente
	signal last_snake_pos : snake;		-- ultima posizione del serpente
	signal last_move : std_logic_vector(2 downto 0);			-- ultima direzione inserita dall'utente
	signal can_move_h_nv_int : std_logic;
	
	
	-- DATI PER IL CIBO
	signal food_pos : cell_position;	-- modificata dal food_process
	
	-- DIREZIONE E POSIZIONE DEL SERPENTE AL RESET
	constant dir_at_reset : std_logic_vector := "011";
	constant pos_at_reset : cell_position := DEFAULT_POS;
	
	-- SEGNALI DI SINCRONIZZAZIONE
	--signal update_pos : std_logic; -- Movement_process -> Field_process

begin

-- Field_process:
-- Processo che si occupa di tenere aggiornate le celle del field al verificarsi di eventi che ne cambiano stato
Field_process : process (RESET_N, curr_snake_pos.tail)

begin
	if(RESET_N = '0') then
		
		for col in 0 to FIELD_COLS-1 loop
			for row in 0 to FIELD_ROWS-1 loop
					field.cells(row, col).filled <= '0';
					field.cells(row, col).checkpoint <= "000";
					field.cells(row, col).food <= "00";
			end loop;
		end loop;
		
		-- Serpente in posizione di default. Lunghezza = 2 (testa più coda), coricato in orizzontale e diretto a destra.
		-- TESTA
		field.cells(pos_at_reset.row, pos_at_reset.col).filled <= '1';
		field.cells(pos_at_reset.row, pos_at_reset.col).checkpoint <= dir_at_reset;
		field.cells(pos_at_reset.row, pos_at_reset.col).head <= '1';
		
		-- CODA
		field.cells(pos_at_reset.row, pos_at_reset.col-1).filled <= '1';
		field.cells(pos_at_reset.row, pos_at_reset.col-1).checkpoint <= dir_at_reset;
		field.cells(pos_at_reset.row, pos_at_reset.col-1).head <= '0';

	else -- Movement_process ha segnalato nuove posizioni valide
		
			field.cells(last_snake_pos.head.row, last_snake_pos.head.col).checkpoint <= last_move; -- impostazione del nuovo checkpoint
			field.cells(last_snake_pos.head.row, last_snake_pos.head.col).head <= '0';
			-- accendiamo un pezzo in testa
			field.cells(curr_snake_pos.head.row, curr_snake_pos.head.col).filled <= '1';
			field.cells(curr_snake_pos.head.row, curr_snake_pos.head.col).head <= '1';
			-- spegnamo l'ultimo pezzo
			field.cells(last_snake_pos.tail.row, last_snake_pos.tail.col).filled <= '0';	-- vecchia coordinata dell'ultimo pezzo
			field.cells(last_snake_pos.tail.row, last_snake_pos.tail.col).checkpoint <= "000"; -- svuoto la cella abbandonata
			
			
			
	end if;
		
end process;

-- Movement_process:
-- Processo che riceve dalla Control Unit segnali indicanti verso dove il serpente deve muoversi.
-- In base a tali direzioni, aggiorna le posizioni della testa e della coda del serpente, ed infine, le
-- comunica valide al Field_process mediante il segnale di sincronizzazione "update_pos".
Movement_process : process (RESET_N, MOVE_UP, MOVE_DOWN, MOVE_RIGHT, MOVE_LEFT)

begin

	if(RESET_N = '0') then
		--	TESTA
		curr_snake_pos.head.row <= pos_at_reset.row;
		curr_snake_pos.head.col <= pos_at_reset.col;
		--	CODA
		curr_snake_pos.tail.row <= pos_at_reset.row-1;
		curr_snake_pos.tail.col <= pos_at_reset.col-1;
		
		last_snake_pos <= curr_snake_pos;
		last_move <= "000";
		LAST_MOVE_OUT <= last_move;
		
		HEAD_ROW_OUT <= curr_snake_pos.head.row;
		HEAD_COL_OUT <= curr_snake_pos.head.col;
	
		TAIL_ROW_OUT <= curr_snake_pos.tail.row;
		TAIL_COL_OUT <= curr_snake_pos.tail.col;
		
		--update_pos <= '0';		
	else
		last_snake_pos <= curr_snake_pos;
		--update_pos <= '0';
			
		-- aggiornamento posizione testa in base alla direzione inserita dall'utente
		if(MOVE_UP = '1' and can_move_h_nv_int = '0') then
			curr_snake_pos.head.row <= curr_snake_pos.head.row - 1;
			last_move <= "001";	--U
			LAST_MOVE_OUT <= last_move;
			HEAD_ROW_OUT <= curr_snake_pos.head.row;
			HEAD_COL_OUT <= curr_snake_pos.head.col;
	
			
				
		elsif(MOVE_DOWN = '1' and can_move_h_nv_int = '0') then
			curr_snake_pos.head.row <= curr_snake_pos.head.row + 1;
			last_move <= "010";	--D
			LAST_MOVE_OUT <= last_move;
			HEAD_ROW_OUT <= curr_snake_pos.head.row;
			HEAD_COL_OUT <= curr_snake_pos.head.col;
	
		elsif(MOVE_RIGHT = '1' and can_move_h_nv_int = '1') then
			curr_snake_pos.head.col <= curr_snake_pos.head.col + 1;
			last_move <= "011"; --R
			LAST_MOVE_OUT <= last_move;
			HEAD_ROW_OUT <= curr_snake_pos.head.row;
			HEAD_COL_OUT <= curr_snake_pos.head.col;

					
		elsif(MOVE_LEFT = '1' and can_move_h_nv_int = '1') then
			curr_snake_pos.head.col <= curr_snake_pos.head.col - 1;
			last_move <= "100";	--L
			LAST_MOVE_OUT <= last_move;
			HEAD_ROW_OUT <= curr_snake_pos.head.row;
			HEAD_COL_OUT <= curr_snake_pos.head.col;	
		end if;
		
		
			
		-- aggiornamento della coordinata dell'ultimo pezzo (coda)
		case field.cells(curr_snake_pos.tail.row, curr_snake_pos.tail.col).checkpoint is

			when "100" =>
				curr_snake_pos.tail.col <= curr_snake_pos.tail.col - 1;
				TAIL_ROW_OUT <= curr_snake_pos.tail.row;
			TAIL_COL_OUT <= curr_snake_pos.tail.col;

			when "011" =>
				curr_snake_pos.tail.col <= curr_snake_pos.tail.col + 1;
				TAIL_ROW_OUT <= curr_snake_pos.tail.row;
			TAIL_COL_OUT <= curr_snake_pos.tail.col;

			when "010" =>
				curr_snake_pos.tail.row <= curr_snake_pos.tail.row - 1;
				TAIL_ROW_OUT <= curr_snake_pos.tail.row;
			TAIL_COL_OUT <= curr_snake_pos.tail.col;

			when "001" =>
				curr_snake_pos.tail.row <= curr_snake_pos.tail.row + 1;
				TAIL_ROW_OUT <= curr_snake_pos.tail.row;
			TAIL_COL_OUT <= curr_snake_pos.tail.col;
					
			when others =>
				null;

		end case;
			
		--update_pos <= '1'; -- segnalo al Field_process la validità delle nuove posizioni
		
	end if;

end process;

Advisor_process : process(last_move, RESET_N)
begin
	
	if (RESET_N ='0') then
		CAN_MOVE_H_NV <= '0';	-- inizio: serpente si muove verso dx, quindi possibili mosse solo in verticale
		can_move_h_nv_int <='0';		
	
	else
		
		case last_move is
			
			when "100" =>
				CAN_MOVE_H_NV <= '0';
				can_move_h_nv_int <= '0';

			when "011" =>
				CAN_MOVE_H_NV <= '0';
				can_move_h_nv_int <= '0';

			when "010" =>
				CAN_MOVE_H_NV <= '1';
				can_move_h_nv_int <= '1';

			when "001" =>
				CAN_MOVE_H_NV <= '1';
				can_move_h_nv_int <= '1';
				
			when others =>
				null;

		end case;
	
	end if;
	
end process;

CellQuery : process(CELL_QUERY, field)
variable selected_cell : field_cell_type;
begin
	CELL_CONTENT.filled<='0';
	CELL_CONTENT.food<="00";
	CELL_CONTENT.checkpoint<="000";
	
	selected_cell := field.cells(CELL_QUERY.row,CELL_QUERY.col);
	CELL_CONTENT<=selected_cell;

end process;
end architecture;
