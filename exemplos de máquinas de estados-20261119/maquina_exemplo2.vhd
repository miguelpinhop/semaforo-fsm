library ieee;
use ieee.std_logic_1164.all;

entity maquina_exemplo2 is
    port(
        clk, reset : in std_logic;
        entrada : in std_logic;
        saida : out std_logic
    );
end entity;

architecture behavior of maquina_exemplo2 is

    type estado is (A, B);
    signal prox_estado, atual_estado : estado;

    begin

        process(clk, reset)
        begin
            if(reset = '1') then
                atual_estado <= A;
            elsif(rising_edge(clk)) then
                atual_estado <= prox_estado;
            end if;
        end process;


        process(prox_estado, entrada)
        begin
            case atual_estado is
                when A =>
                    if(entrada = '1') then
                        prox_estado <= B;
								saida <= '1';
                    else
                        prox_estado <= A;
								saida <= '0';
                    end if;

                when B =>
                    if(entrada = '1') then
                        prox_estado <= A;
								saida <= '0';
                    else
                        prox_estado <= B;
								saida <= '1';
                    end if;

            end case;
        end process;

    end architecture;