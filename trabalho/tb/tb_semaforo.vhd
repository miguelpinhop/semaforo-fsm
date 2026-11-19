-- Testbench do toplevel semaforo com DIVISOR = 10:
-- cada estado dura 10 ciclos de clk (1 período do clock dividido).
-- Verifica o mapeamento nos LEDs, a duração dos estados e o reset.
library ieee;
use ieee.std_logic_1164.all;

entity tb_semaforo is
end entity;

architecture sim of tb_semaforo is
    constant PERIODO : time := 10 ns;
    constant DIV     : natural := 10;

    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    signal led   : std_logic_vector(15 downto 0);
    signal fim   : boolean := false;

    -- padrões esperados nos 16 LEDs (bit 15 à esquerda)
    --                                   A:15 14 13  12 11  B:10 9 8  7 6  C:5 4 3  2 1 0
    constant L_RESET : std_logic_vector(15 downto 0) := "100" & "00" & "100" & "00" & "100" & "000";
    constant L_A_V   : std_logic_vector(15 downto 0) := "001" & "00" & "100" & "00" & "100" & "000";
    constant L_A_A   : std_logic_vector(15 downto 0) := "010" & "00" & "100" & "00" & "100" & "000";
    constant L_B_V   : std_logic_vector(15 downto 0) := "100" & "00" & "001" & "00" & "100" & "000";
    constant L_B_A   : std_logic_vector(15 downto 0) := "100" & "00" & "010" & "00" & "100" & "000";
    constant L_C_V   : std_logic_vector(15 downto 0) := "100" & "00" & "100" & "00" & "001" & "000";
    constant L_C_A   : std_logic_vector(15 downto 0) := "100" & "00" & "100" & "00" & "010" & "000";

    type seq_t is array (natural range <>) of std_logic_vector(15 downto 0);
    constant CICLO : seq_t := (L_A_V, L_A_A, L_B_V, L_B_A, L_C_V, L_C_A);
begin
    uut : entity work.semaforo
        generic map (DIVISOR => DIV)
        port map (clk => clk, reset => reset, led => led);

    clk <= not clk after PERIODO / 2 when not fim else '0';

    estimulo : process
        variable t0 : time;
    begin
        -- 1) reset: todos vermelhos nos LEDs
        wait for 2 * PERIODO;
        assert led = L_RESET report "T1: apos reset os LEDs deveriam mostrar todos vermelhos" severity failure;
        reset <= '0';

        -- 2) o estado de reset dura um período inteiro do clock dividido
        --    (a FSM só avança na primeira borda de subida de clk_1hz, DIV/2 ciclos após o reset)
        wait until led /= L_RESET;
        t0 := now;
        assert led = L_A_V report "T2: primeiro estado apos reset deveria ser A verde" severity failure;

        -- 3) cada estado seguinte dura exatamente DIV ciclos; dois ciclos completos
        for volta in 1 to 2 loop
            for k in CICLO'range loop
                assert led = CICLO(k)
                    report "T3: LEDs errados no estado " & integer'image(k) severity failure;
                wait until led'event;
                assert (now - t0) = DIV * PERIODO
                    report "T3: estado " & integer'image(k) & " durou " &
                           integer'image((now - t0) / PERIODO) & " ciclos em vez de " &
                           integer'image(DIV)
                    severity failure;
                t0 := now;
            end loop;
        end loop;

        -- 4) reset no meio do ciclo
        wait for 3 * PERIODO;
        reset <= '1';
        wait for 1 ns;
        assert led = L_RESET report "T4: reset nao levou a todos vermelhos" severity failure;
        wait for PERIODO;
        reset <= '0';
        wait until led /= L_RESET;
        assert led = L_A_V report "T4: apos reset deveria voltar para A verde" severity failure;

        report "tb_semaforo: todos os testes passaram" severity note;
        fim <= true;
        wait;
    end process;
end architecture;
