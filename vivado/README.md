# Fluxo Vivado para a Boolean Board (xc7s50csga324-1), no Windows

Os fontes VHDL em `src/` são os mesmos simulados com GHDL no Linux.

## Mapeamento na placa

| Sinal | Na placa | Observação |
|---|---|---|
| `clk` | oscilador 100 MHz (F14) | dividido para 1 Hz dentro do projeto |
| `reset` | BTN0 | '1' enquanto apertado: todos vermelhos; solta e o ciclo recomeça |
| Via A | LED15 vermelho, LED14 amarelo, LED13 verde | |
| Via B | LED10 vermelho, LED9 amarelo, LED8 verde | |
| Via C | LED5 vermelho, LED4 amarelo, LED3 verde | |

Comportamento esperado: ao ligar ou soltar BTN0, 1 s com os três vermelhos, depois
A verde (1 s), A amarelo (1 s), B verde, B amarelo, C verde, C amarelo e volta para A
verde. Ciclo completo: 6 s.

## Antes de começar (Windows)

1. **Vivado ML Standard** (gratuito) com o dispositivo **Spartan-7** marcado na
   instalação e **Install Cable Drivers** marcado. Qualquer versão de 2019.1 em diante.
2. **Caminho do projeto sem acentos e sem espaços.** Copie a pasta (o zip de
   `make pacote`) para algo como `C:\SEMAFORO`. A pasta `exemplos de máquinas de
   estados-20261119` não vai no zip de propósito.
3. Se o driver do cabo não foi instalado junto, rode como administrador:
   `C:\Xilinx\Vivado\<versão>\data\xicom\cable_drivers\nt64\install_drivers_wrapper.bat`

## Passo a passo pela interface gráfica

1. Abra o Vivado. Na **Tcl Console** (parte de baixo da janela):
   ```tcl
   cd {C:/SEMAFORO/vivado}         ;# barras normais, mesmo no Windows
   source criar_projeto.tcl
   ```
2. **Generate Bitstream** (Program and Debug, barra lateral). Alguns minutos.
3. Ligue a placa pela USB (porta PROG/UART), jumper **J13 em JTAG**.
4. **Open Hardware Manager → Open target → Auto Connect → Program device**,
   escolher `proj\semaforo.runs\impl_1\semaforo.bit`.
5. Para o vídeo: **Open Synthesized Design → Schematic** (dois blocos: DIV e FSM) e
   **Reports → Report → FSM** mostra os 7 estados extraídos; tire prints.

## Alternativa pelo prompt de comando

Na pasta `vivado\`:

```bat
vivado.bat criar_projeto.tcl
vivado.bat gerar_bitstream.tcl     ← gera vivado\semaforo.bit e utilizacao.txt
vivado.bat programar.tcl           ← placa ligada
```

Se o Vivado estiver em outro lugar: `set VIVADO_BAT=D:\Xilinx\Vivado\2023.1\bin\vivado.bat`.

## Simulação no Vivado

**Run Simulation → Run Behavioral Simulation** roda `tb_semaforo` (já é o topo da
simulação; usa `DIVISOR => 10`, então cada estado dura 100 ns na forma de onda).

## Avisos esperados e erros conhecidos

- Aviso de **clock derivado de lógica** / "no clock defined" nos caminhos da FSM:
  `clk_1hz` sai de um flip-flop do divisor. Esperado; 1 Hz não tem risco de tempo.
  Se quiser constrangê-lo, descomente a última linha do `semaforo.xdc`.
- `[DRC NSTD-1] / [DRC UCIO-1]`: falta IOSTANDARD ou pino em alguma porta. Confira se
  o XDC foi adicionado ao fileset de constraints.
- Hardware Manager não acha a placa: trocar o cabo USB (alguns são só de carga),
  conferir J13 em JTAG, reinstalar o driver do cabo.
- Erro ao criar o projeto citando o caminho: há acento ou espaço na pasta.
