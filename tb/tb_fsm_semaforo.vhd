-- Testbench da fsm_semaforo (clock direto, 1 borda = 1 estado).
-- Verifica:
--   1) após reset: todos vermelhos (condição de segurança);
--   2) sequência RESET -> A_V -> A_A -> B_V -> B_A -> C_V -> C_A -> A_V -> ...
--   3) em toda borda: exatamente 1 luz acesa por via e no máximo 1 via fora
--      do vermelho (invariante do enunciado);
--   4) reset assíncrono no meio do ciclo volta a todos vermelhos sem esperar
--      a borda, e depois o ciclo recomeça por A.
library ieee;
use ieee.std_logic_1164.all;

entity tb_fsm_semaforo is
end entity;

architecture sim of tb_fsm_semaforo is
    constant PERIODO : time := 10 ns;

    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    signal a_vm, a_am, a_vd : std_logic;
    signal b_vm, b_am, b_vd : std_logic;
    signal c_vm, c_am, c_vd : std_logic;
    signal fim : boolean := false;

    -- vetor (vm, am, vd) por via, para comparar com o esperado
    subtype luz is std_logic_vector(2 downto 0);
    constant R  : luz := "100";
    constant AM : luz := "010";
    constant V  : luz := "001";

    type linha is record a, b, c : luz; end record;
    type tabela_t is array (natural range <>) of linha;
    -- ordem esperada a partir de S_RESET
    constant TABELA : tabela_t := (
        (R, R, R),    -- S_RESET
        (V, R, R),    -- S_A_VERDE
        (AM, R, R),   -- S_A_AMARELO
        (R, V, R),    -- S_B_VERDE
        (R, AM, R),   -- S_B_AMARELO
        (R, R, V),    -- S_C_VERDE
        (R, R, AM)    -- S_C_AMARELO
    );

    function conta_uns(vec : luz) return natural is
        variable n : natural := 0;
    begin
        for i in vec'range loop
            if vec(i) = '1' then n := n + 1; end if;
        end loop;
        return n;
    end function;
begin
    uut : entity work.fsm_semaforo
        port map (clk => clk, reset => reset,
                  a_vermelho => a_vm, a_amarelo => a_am, a_verde => a_vd,
                  b_vermelho => b_vm, b_amarelo => b_am, b_verde => b_vd,
                  c_vermelho => c_vm, c_amarelo => c_am, c_verde => c_vd);

    clk <= not clk after PERIODO / 2 when not fim else '0';

    -- Invariante checada continuamente (fora dos instantes de troca)
    invariante : process(clk)
        variable la, lb, lc : luz;
        variable fora_vm : natural;
    begin
        if falling_edge(clk) then
            la := a_vm & a_am & a_vd;
            lb := b_vm & b_am & b_vd;
            lc := c_vm & c_am & c_vd;
            assert conta_uns(la) = 1 and conta_uns(lb) = 1 and conta_uns(lc) = 1
                report "INV: cada via deve ter exatamente uma luz acesa" severity failure;
            fora_vm := 0;
            if la /= R then fora_vm := fora_vm + 1; end if;
            if lb /= R then fora_vm := fora_vm + 1; end if;
            if lc /= R then fora_vm := fora_vm + 1; end if;
            assert fora_vm <= 1
                report "INV: mais de uma via fora do vermelho ao mesmo tempo" severity failure;
        end if;
    end process;

    estimulo : process
        procedure confere(idx : natural; msg : string) is
            variable la, lb, lc : luz;
        begin
            la := a_vm & a_am & a_vd;
            lb := b_vm & b_am & b_vd;
            lc := c_vm & c_am & c_vd;
            assert la = TABELA(idx).a and lb = TABELA(idx).b and lc = TABELA(idx).c
                report msg & ": saidas diferentes do esperado para o estado " & integer'image(idx)
                severity failure;
        end procedure;
    begin
        -- 1) reset
        wait for PERIODO;
        confere(0, "T1 (reset)");
        reset <= '0';

        -- 2) dois ciclos completos: 7 estados + 6 do segundo ciclo (sem RESET)
        for k in 1 to 6 loop
            wait until rising_edge(clk); wait for 1 ns;
            confere(k, "T2 ciclo 1");
        end loop;
        for volta in 1 to 2 loop
            for k in 1 to 6 loop
                wait until rising_edge(clk); wait for 1 ns;
                confere(k, "T2 ciclo " & integer'image(volta + 1));
            end loop;
        end loop;

        -- 4) reset assíncrono no meio de S_C_VERDE (idx 5)
        for k in 1 to 5 loop
            wait until rising_edge(clk); wait for 1 ns;
        end loop;
        confere(5, "T4 antes do reset");
        wait for PERIODO / 4;             -- longe da borda
        reset <= '1';
        wait for 1 ns;
        confere(0, "T4 reset assincrono");
        wait for PERIODO;                 -- segura o reset por uma borda
        confere(0, "T4 reset mantido");
        reset <= '0';
        wait until rising_edge(clk); wait for 1 ns;
        confere(1, "T4 apos reset deve ir para A_VERDE");

        report "tb_fsm_semaforo: todos os testes passaram" severity note;
        fim <= true;
        wait;
    end process;
end architecture;
