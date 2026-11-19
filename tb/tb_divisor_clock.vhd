-- Testbench do divisor_clock com DIVISOR = 10.
-- Verifica: saída em '0' após reset; período de clk_saida = 10 ciclos de clk;
-- duty cycle 50 % (5 ciclos em cada nível); reset no meio da contagem.
library ieee;
use ieee.std_logic_1164.all;

entity tb_divisor_clock is
end entity;

architecture sim of tb_divisor_clock is
    constant PERIODO : time := 10 ns;   -- clk de 100 MHz
    constant DIV     : natural := 10;

    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1';
    signal clk_saida : std_logic;
    signal fim       : boolean := false;
begin
    uut : entity work.divisor_clock
        generic map (DIVISOR => DIV)
        port map (clk => clk, reset => reset, clk_saida => clk_saida);

    -- clock contínuo até o fim do teste
    clk <= not clk after PERIODO / 2 when not fim else '0';

    estimulo : process
        variable t_sobe1, t_sobe2, t_desce : time;
    begin
        -- 1) reset: saída em '0'
        wait for 2 * PERIODO;
        assert clk_saida = '0' report "T1: clk_saida deveria ser 0 durante o reset" severity failure;
        reset <= '0';
        wait until falling_edge(clk);   -- alinhar fora da borda de subida

        -- 2) primeira subida ocorre DIV/2 ciclos após o reset
        wait until rising_edge(clk_saida);
        t_sobe1 := now;
        wait until falling_edge(clk_saida);
        t_desce := now;
        assert (t_desce - t_sobe1) = (DIV / 2) * PERIODO
            report "T2: nivel alto deveria durar " & integer'image(DIV / 2) & " ciclos"
            severity failure;

        -- 3) período completo = DIV ciclos
        wait until rising_edge(clk_saida);
        t_sobe2 := now;
        assert (t_sobe2 - t_sobe1) = DIV * PERIODO
            report "T3: periodo deveria ser " & integer'image(DIV) & " ciclos"
            severity failure;

        -- 4) reset assíncrono no meio da contagem zera a saída na hora
        wait for 2 * PERIODO;
        reset <= '1';
        wait for 1 ns;
        assert clk_saida = '0' report "T4: reset nao zerou clk_saida" severity failure;
        wait for 2 * PERIODO;
        reset <= '0';
        -- após o reset, a próxima subida leva DIV/2 ciclos de novo
        wait until rising_edge(clk_saida);
        t_sobe1 := now;
        wait until rising_edge(clk_saida);
        assert (now - t_sobe1) = DIV * PERIODO
            report "T4: periodo apos reset incorreto" severity failure;

        report "tb_divisor_clock: todos os testes passaram" severity note;
        fim <= true;
        wait;
    end process;
end architecture;
