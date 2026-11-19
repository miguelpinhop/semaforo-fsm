-- ============================================================================
-- divisor_clock.vhd
-- Divisor de clock: gera uma onda quadrada lenta (clk_saida) a partir do
-- oscilador da placa (clk, 100 MHz na Boolean Board).
--
-- Com DIVISOR = 100_000_000, clk_saida tem período de 100 000 000 ciclos de
-- 10 ns = 1 s, ou seja, 1 Hz. É esse sinal que serve de clock para a máquina
-- de estados dos semáforos, garantindo exatamente 1 segundo por estado.
--
-- O contador conta até DIVISOR/2 - 1 e inverte a saída, de modo que a onda
-- fica 50 % do tempo em '1' e 50 % em '0'.
--
-- Nos testbenches usa-se um DIVISOR pequeno (ex.: 10) para a simulação ser
-- rápida; a lógica é a mesma.
--
-- Trabalho de Sistemas Digitais - 4o bimestre - Controle de semáforos
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;

entity divisor_clock is
    generic (
        DIVISOR : natural := 100_000_000   -- ciclos de clk por período de clk_saida
    );
    port (
        clk, reset : in  std_logic;        -- clock rápido da placa e reset assíncrono
        clk_saida  : out std_logic         -- clock lento (1 Hz na placa)
    );
end entity;

architecture behavior of divisor_clock is

    constant METADE : natural := DIVISOR / 2;          -- ciclos em cada nível
    signal contador : natural range 0 to METADE - 1 := 0;
    signal clk_int  : std_logic := '0';                -- valor atual da saída

begin

    -- Parte síncrona: contador e inversão da saída.
    -- O reset zera o contador e deixa a saída em '0', para que o primeiro
    -- período após o reset seja completo (1 s inteiro em cada estado da FSM).
    process(clk, reset)
    begin
        if (reset = '1') then
            contador <= 0;
            clk_int  <= '0';
        elsif (rising_edge(clk)) then
            if (contador = METADE - 1) then
                contador <= 0;
                clk_int  <= not clk_int;
            else
                contador <= contador + 1;
            end if;
        end if;
    end process;

    clk_saida <= clk_int;

end architecture;
