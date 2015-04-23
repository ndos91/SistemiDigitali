library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
USE ieee.math_real.all;
use work.snake_package.all;

entity Snake_controller is
port (
	CLK : in std_logic;
	RESET_N : in std_logic;
	
	BUTTON_UP : in std_logic;
	BUTTON_DOWN : in std_logic;
	BUTTON_RIGHT : in std_logic;
	BUTTON_LEFT : in std_logic;
	
	TIME_10MS : in std_logic;
	MOVE_UP : out std_logic;
	MOVE_DOWN : out std_logic;
	MOVE_RIGHT : out std_logic;
	MOVE_LEFT : out std_logic;
	
	CAN_MOVE_H_NV : in std_logic;
	REDRAW : out std_logic
);
end entity;
architecture RTL of Snake_controller is

constant SNAKE_SPEED : integer := 50;
signal move_time : std_logic;
signal time_to_next_move : integer range 0 to SNAKE_SPEED-1;

constant dir_at_reset : std_logic_vector := "011";
shared variable last_dir : std_logic_vector(2 downto 0); --rappresenta la direzione dell'ultimo pulsante premuto per permettere il movimento 
										--continuo del serpente, anche qundo l'utente non interagisce con il gioco. 

begin

--il processo TimedMove in funzione dell'ingresso TIME_10MS, ricevuto da un contatore esterno, genera un impulso periodico (move_time)
--con frequenza minore rispetto al clock quindi genera un clock più lento che alimenta il processo che si occupa di comunicare,
--in funzione dei pulsanti premuti sulla scheda, al datapath e alla view le azioni che essi devono svolgere.
--Tale processo prende il nome di Controller_RTL
--il segnale time_to_next_move rappresenta quanto tempo deve trascorrere prima del prossimo movimento del serpente pertanto
--viene decrementato ogni volta che TIME_10MS vale 1 fino a quando arriva al valore zero. Quando ciò accade vien riportato al valore
--SNAKE_SPEED-1 
TimedMove : process (CLK,RESET_N)
begin
	if (RESET_N = '0') then
		
		time_to_next_move <= 0;
		move_time <= '0';

	elsif(rising_edge(CLK)) then
		
		move_time <= '0';
		if(TIME_10MS='1') then 
			if(time_to_next_move=0) then
				time_to_next_move <= SNAKE_SPEED-1;
				move_time<='1';
			else
				time_to_next_move <= time_to_next_move-1;
			end if;
		else null;
		end if;

	else null;
	end if;
end process;

--il processo UpdateDir si occupa di aggiornare il segnale last_dir con la direzione relativa all'ultimo pulsante premuto dall'utente
--NOTA: last_dir viene aggiornata in qualsiasi caso, poi nel processo Controller_RTL si va a vedere se effettivamente quella direzione
--è possibile valutando il segnale CAN_MOVE_H_NV
UpdateDir : process(CLK,RESET_N)
begin

	if(RESET_N='0') then
		last_dir := dir_at_reset;
		
	elsif(rising_edge(CLK)) then
		
			if(BUTTON_DOWN='1') then
				last_dir := "010";
			elsif(BUTTON_UP='1') then
				last_dir := "001";
			elsif(BUTTON_RIGHT='1') then
				last_dir := "011";
			elsif(BUTTON_LEFT='1') then
				last_dir := "100";
			else null;
			end if;
	else null;
	end if;

end process;

Controller_RTL : process(CLK,RESET_N)
begin
	if(RESET_N='0') then
		MOVE_DOWN<='0';
		MOVE_UP<='0';
		MOVE_LEFT<='0';
		MOVE_RIGHT<='0';
		REDRAW<='0';
		
	elsif(rising_edge(CLK)) then
		MOVE_DOWN<='0'; --??
		MOVE_UP<='0'; --??
		MOVE_LEFT<='0'; --??
		MOVE_RIGHT<='0'; --??
		REDRAW<='0'; --?
		--se l'utente preme "destra" ed è possibile muoversi in orizzontale
		if(move_time='1') then
			if(last_dir="011" and CAN_MOVE_H_NV='1') then
				MOVE_RIGHT<='1';
				REDRAW<='1';
			elsif(last_dir="100" and CAN_MOVE_H_NV='1') then
				MOVE_LEFT<='1';
				REDRAW<='1';
			--se l'utente preme "sopra" ed è possibile muoversi in verticale
			elsif(last_dir="001" and CAN_MOVE_H_NV='0') then
				MOVE_UP<='1';
				REDRAW<='1';
			elsif(last_dir="010" and CAN_MOVE_H_NV='0') then
				MOVE_DOWN<='1';
				REDRAW<='1';
			else null;
			end if;
			
		else null;
		end if;
	else null;
	end if;
end process;
end architecture;
