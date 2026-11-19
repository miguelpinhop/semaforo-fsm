-- ============================================================================
-- semaforo.vhd  (TOPLEVEL)
-- Controle de três semáforos em um cruzamento, na Boolean Board.
--
-- Liga o oscilador de 100 MHz da placa ao divisor_clock (100 MHz -> 1 Hz) e o
-- clock de 1 Hz à máquina de estados fsm_semaforo. As nove saídas da FSM vão
-- para LEDs da placa, agrupados por via com um LED apagado entre os grupos:
--
--   Via | Vermelho | Amarelo | Verde
--    A  |  LED15   |  LED14  | LED13
--    B  |  LED10   |  LED9   | LED8
--    C  |  LED5    |  LED4   | LED3
--
-- reset = BTN0 (vale '1' enquanto apertado): leva o sistema a todos vermelhos.
-- Pinagem completa em vivado/semaforo.xdc.
--
-- Trabalho de Sistemas Digitais - 4o bimestre - Controle de semáforos
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;

entity semaforo is
    generic (
        DIVISOR : natural := 100_000_000   -- 100 MHz / 1e8 = 1 Hz (menor na simulação)
    );
    port (
        clk   : in  std_logic;                       -- oscilador 100 MHz (F14)
        reset : in  std_logic;                       -- BTN0
        led   : out std_logic_vector(15 downto 0)    -- LED15..LED0 da placa
    );
end entity;

architecture estrutural of semaforo is

    component divisor_clock
        generic (DIVISOR : natural);
        port (
            clk, reset : in  std_logic;
            clk_saida  : out std_logic
        );
    end component;

    component fsm_semaforo
        port (
            clk, reset : in  std_logic;
            a_vermelho, a_amarelo, a_verde : out std_logic;
            b_vermelho, b_amarelo, b_verde : out std_logic;
            c_vermelho, c_amarelo, c_verde : out std_logic
        );
    end component;

    signal clk_1hz : std_logic;   -- clock lento que cadencia a FSM

begin

    DIV : divisor_clock
        generic map (DIVISOR => DIVISOR)
        port map (
            clk       => clk,
            reset     => reset,
            clk_saida => clk_1hz
        );

    FSM : fsm_semaforo
        port map (
            clk        => clk_1hz,
            reset      => reset,
            a_vermelho => led(15), a_amarelo => led(14), a_verde => led(13),
            b_vermelho => led(10), b_amarelo => led(9),  b_verde => led(8),
            c_vermelho => led(5),  c_amarelo => led(4),  c_verde => led(3)
        );

    -- LEDs separadores e não usados ficam apagados
    led(12 downto 11) <= "00";
    led(7 downto 6)   <= "00";
    led(2 downto 0)   <= "000";

end architecture;
