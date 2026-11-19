-- ============================================================================
-- fsm_semaforo.vhd
-- Máquina de estados centralizada que controla três semáforos (vias A, B e C)
-- de um cruzamento.
--
-- Estrutura igual ao modelo visto em aula (maquina_exemplo.vhd):
--   * um process síncrono  : registrador de estado, com reset assíncrono;
--   * um process combinacional: próximo estado e saídas, num único case.
-- Máquina de Moore: as saídas dependem só do estado atual.
--
-- Cada estado dura um período de clk. O toplevel (semaforo.vhd) alimenta esta
-- entidade com o clock de 1 Hz vindo de divisor_clock, logo 1 s por estado.
--
-- Diagrama de estados (todas as transições são incondicionais):
--
--   reset ──► S_RESET ──► S_A_VERDE ──► S_A_AMARELO ──► S_B_VERDE ──►
--             S_B_AMARELO ──► S_C_VERDE ──► S_C_AMARELO ──┐
--                      ▲                                   │
--                      └────────────── (volta para S_A_VERDE)
--
-- Tabela de saídas (R = vermelho, Am = amarelo, V = verde):
--   Estado        | Via A | Via B | Via C
--   S_RESET       |   R   |   R   |   R     <- condição de segurança
--   S_A_VERDE     |   V   |   R   |   R
--   S_A_AMARELO   |   Am  |   R   |   R
--   S_B_VERDE     |   R   |   V   |   R
--   S_B_AMARELO   |   R   |   Am  |   R
--   S_C_VERDE     |   R   |   R   |   V
--   S_C_AMARELO   |   R   |   R   |   Am
--
-- Em todos os estados apenas uma via está em verde ou amarelo; as demais ficam
-- em vermelho (requisito do enunciado).
--
-- Condição de segurança do reset: ao ligar ou apertar o reset, os três
-- semáforos ficam vermelhos por 1 s (S_RESET). Nenhum veículo é liberado até
-- o sistema estabilizar, como em semáforos reais ao serem religados.
--
-- Trabalho de Sistemas Digitais - 4o bimestre - Controle de semáforos
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;

entity fsm_semaforo is
    port (
        clk, reset : in  std_logic;   -- clock de 1 Hz e reset assíncrono
        -- Via A
        a_vermelho, a_amarelo, a_verde : out std_logic;
        -- Via B
        b_vermelho, b_amarelo, b_verde : out std_logic;
        -- Via C
        c_vermelho, c_amarelo, c_verde : out std_logic
    );
end entity;

architecture behavior of fsm_semaforo is

    type estado is (S_RESET,
                    S_A_VERDE, S_A_AMARELO,
                    S_B_VERDE, S_B_AMARELO,
                    S_C_VERDE, S_C_AMARELO);
    signal prox_estado, atual_estado : estado;

    begin

        -- Parte síncrona: registrador de estado.
        -- Reset assíncrono leva imediatamente para S_RESET (todos vermelhos).
        process(clk, reset)
        begin
            if (reset = '1') then
                atual_estado <= S_RESET;
            elsif (rising_edge(clk)) then
                atual_estado <= prox_estado;
            end if;
        end process;

        -- Parte combinacional: saídas e próximo estado.
        -- Cada estado atribui as nove saídas explicitamente (evita latch).
        process(atual_estado)
        begin
            case atual_estado is

                when S_RESET =>                 -- todos vermelhos (segurança)
                    a_vermelho <= '1'; a_amarelo <= '0'; a_verde <= '0';
                    b_vermelho <= '1'; b_amarelo <= '0'; b_verde <= '0';
                    c_vermelho <= '1'; c_amarelo <= '0'; c_verde <= '0';
                    prox_estado <= S_A_VERDE;

                when S_A_VERDE =>               -- via A liberada
                    a_vermelho <= '0'; a_amarelo <= '0'; a_verde <= '1';
                    b_vermelho <= '1'; b_amarelo <= '0'; b_verde <= '0';
                    c_vermelho <= '1'; c_amarelo <= '0'; c_verde <= '0';
                    prox_estado <= S_A_AMARELO;

                when S_A_AMARELO =>             -- via A em atenção
                    a_vermelho <= '0'; a_amarelo <= '1'; a_verde <= '0';
                    b_vermelho <= '1'; b_amarelo <= '0'; b_verde <= '0';
                    c_vermelho <= '1'; c_amarelo <= '0'; c_verde <= '0';
                    prox_estado <= S_B_VERDE;

                when S_B_VERDE =>               -- via B liberada
                    a_vermelho <= '1'; a_amarelo <= '0'; a_verde <= '0';
                    b_vermelho <= '0'; b_amarelo <= '0'; b_verde <= '1';
                    c_vermelho <= '1'; c_amarelo <= '0'; c_verde <= '0';
                    prox_estado <= S_B_AMARELO;

                when S_B_AMARELO =>             -- via B em atenção
                    a_vermelho <= '1'; a_amarelo <= '0'; a_verde <= '0';
                    b_vermelho <= '0'; b_amarelo <= '1'; b_verde <= '0';
                    c_vermelho <= '1'; c_amarelo <= '0'; c_verde <= '0';
                    prox_estado <= S_C_VERDE;

                when S_C_VERDE =>               -- via C liberada
                    a_vermelho <= '1'; a_amarelo <= '0'; a_verde <= '0';
                    b_vermelho <= '1'; b_amarelo <= '0'; b_verde <= '0';
                    c_vermelho <= '0'; c_amarelo <= '0'; c_verde <= '1';
                    prox_estado <= S_C_AMARELO;

                when S_C_AMARELO =>             -- via C em atenção
                    a_vermelho <= '1'; a_amarelo <= '0'; a_verde <= '0';
                    b_vermelho <= '1'; b_amarelo <= '0'; b_verde <= '0';
                    c_vermelho <= '0'; c_amarelo <= '1'; c_verde <= '0';
                    prox_estado <= S_A_VERDE;   -- fecha o ciclo

            end case;
        end process;

    end architecture;
