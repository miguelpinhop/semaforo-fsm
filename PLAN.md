# PLAN.md — Controle de 3 semáforos com máquina de estados em VHDL (4º bimestre)

Enunciado: `semaforo.pdf` (Opção 1). Apresentação até **04/12/2026**. Dupla. 10 pontos.

## 0. Auditoria do enunciado (feita em 19/11/2026)

`semaforo.pdf` **não contém prompt injection**. Evidências:

| Verificação | Resultado |
|---|---|
| Texto extraído (`pdftotext`) × página renderizada | Idênticos; nada que o leitor veja a mais ou a menos |
| Modo de renderização invisível (`3 Tr`), texto branco, fonte minúscula | Nenhum. Cores usadas: preto, cinza (só "*imagem ilustrativa") e vermelho (os dois avisos de plágio) |
| JavaScript, OpenAction, anotações, arquivos embutidos, camadas ocultas (OCG), metadados XMP | Nenhum |
| Imagem embutida (única, 1024×1024 JPEG) | Ilustração de cruzamento, sem texto |
| Produtor | WPS Writer, autor "User"; metadados normais |

`leitura_projeto RTL.pdf` é só imagem (impressão do capítulo 5 do Vahid, "Projeto em nível de transferência entre registradores", págs. 242–255). As 14 páginas foram vistas uma a uma; nada além do livro. Sem camada de texto, logo sem texto oculto possível.

`DE0_Nano_User_Manual.pdf`: manual oficial da Terasic, usado só como histórico (ver 2). Não auditado a fundo (154 págs.), e não será lido por ferramentas automatizadas.

Observação no enunciado: "10 pontos na nota do quarto bimestre. Sendo:" termina sem a divisão da nota. **Perguntar ao professor** como os 10 pontos se dividem (código / FPGA / vídeo).

## 1. O que o enunciado exige (checklist de requisitos)

| # | Requisito | Onde é atendido |
|---|---|---|
| R1 | Máquina de estados **centralizada** controlando 3 semáforos (via A, B, C), cada um com Verde/Amarelo/Vermelho | `src/fsm_semaforo.vhd` |
| R2 | Sequência Verde → Amarelo → Vermelho em cada via | Ordem dos estados |
| R3 | **Só um** semáforo em Verde ou Amarelo por vez; os outros em Vermelho | Tabela de saídas (Moore) e `assert` no testbench |
| R4 | **Estado de reset** com condição de segurança (escolha do grupo, será avaliada) | Estado `S_RESET` = todos vermelhos, entrado por reset assíncrono e por `when others` |
| R5 | Estrutura do código **exatamente** como nas aulas/vídeos: parte síncrona e combinacional **separadas** | Dois `process` na FSM (ver 3.2) |
| R6 | **1 segundo** em cada estado | Divisor do clock de 100 MHz → 1 Hz (`src/divisor_clock.vhd`) |
| R7 | Código VHDL **comentado** | Todos os `.vhd` com cabeçalho e comentários por bloco |
| R8 | Programação **obrigatória** no FPGA | Fluxo Vivado + Boolean Board (ver 2) |
| R9 | Vídeo ≤ 10 min, dupla aparecendo, explicando: diagrama de estados, funcionamento no FPGA, escolhas de projeto (leds internos × externos e motivo) | `docs/roteiro_video.md` |
| R10 | Entrega: código + link do vídeo | Zip + link |
| Opcional | Pedestres | Só se sobrar tempo (fase 9) |

## 2. Ambiente

| Item | Situação (19/11/2026) |
|---|---|
| **Placa alvo** | **Boolean Board** (Real Digital), Spartan-7 `xc7s50csga324-1`, clock 100 MHz no pino **F14**, 16 switches, 4 botões, 16 LEDs, 2 LEDs RGB, 2 displays de 7 seg × 4 dígitos. É isso que o link do professor descreve (manual de referência da Boolean Board). A DE0-Nano não é mais usada no laboratório (constatado no trabalho anterior, 23/10/2026) |
| **Vivado** | Em outra máquina, **Windows**. Scripts prontos do trabalho anterior em `../trab5/sd-trab05-memoria-vhdl/vivado/` (`criar_projeto.tcl`, `gerar_bitstream.tcl`, `programar.tcl`, `vivado.bat`, `README.md`) serão copiados e adaptados. Caminho do projeto lá **sem acento nem espaço** (ex.: `C:\SEMAFORO`) |
| **Simulador nesta máquina** | **GHDL 4.1 + GTKWave** instalados em 19/11/2026 (`make sim`, `make sim-gui`). Quartus/ModelSim do bimestre passado não existem mais. **Ao terminar o trabalho, remover** para liberar espaço: `make desinstalar-ghdl` imprime o comando (`sudo apt remove --purge ghdl ghdl-common ghdl-mcode gtkwave && sudo apt autoremove`). Na máquina com Vivado, o mesmo testbench roda no xsim |
| **Template da aula** | `exemplos de máquinas de estados-20261119/maquina_exemplo.vhd` (Moore) e `maquina_exemplo2.vhd` (Mealy). Detalhes em 3.2 |
| **Pinagem** | Tabela abaixo, do tutorial "A First Vivado Project for the Boolean board" (realdigital.org), conferida com o XDC do trabalho anterior nos pinos em comum (switches, LED0–7, BTN0): batem |
| **Referência de estilo** | `leitura_projeto RTL.pdf` (Vahid cap. 5): método em 4 passos — máquina de estados de alto nível → bloco operacional → ligar ao bloco de controle → FSM do bloco de controle. O divisor de clock (contador) é o "bloco operacional"; a FSM é o "bloco de controle" |

### Pinos da Boolean Board que o projeto usa (IOSTANDARD LVCMOS33 em todos)

| Sinal | Na placa | Pino |
|---|---|---|
| `clk` (100 MHz) | oscilador | F14 |
| `reset` | BTN0 ('0' solto, '1' apertado) | J2 |
| `led[0..15]` | LED0..LED15 (acendem com '1') | G1, G2, F1, F2, E1, E2, E3, E5, E6, C3, B2, A2, B3, A3, B4, A4 |
| `rgb0` R/G/B | LED RGB 0 | V6, V4, U6 |
| `rgb1` R/G/B | LED RGB 1 | U3, V3, V5 |
| `btn[1..3]` | BTN1..BTN3 (reserva: pedestre) | J5, H2, J1 |
| `sw[0..15]` | SW0..SW15 (reserva: modo teste) | V2, U2, U1, T2, T1, R2, R1, P2, P1, N2, N1, M2, M1, L1, K2, K1 |

## 3. Projeto

### 3.1 Diagrama de estados (7 estados, Moore, 1 s cada)

```
          reset (assíncrono, BTN0)
                 │
                 ▼
          ┌────────────┐
          │  S_RESET   │  A=R  B=R  C=R   (condição de segurança: tudo vermelho)
          └─────┬──────┘
                ▼
   ┌───► S_A_VERDE    A=G  B=R  C=R
   │        │
   │     S_A_AMARELO  A=Y  B=R  C=R
   │        │
   │     S_B_VERDE    A=R  B=G  C=R
   │        │
   │     S_B_AMARELO  A=R  B=Y  C=R
   │        │
   │     S_C_VERDE    A=R  B=R  C=G
   │        │
   └──── S_C_AMARELO  A=R  B=R  C=Y
```

Todas as transições são incondicionais (uma por borda do clock de 1 Hz). `when others => proximo_estado <= S_RESET` cobre codificações inválidas. Ciclo completo: 6 s; após o reset, 1 s de tudo vermelho antes de A ficar verde.

**Decisões a registrar no vídeo:**

1. **Condição de segurança do reset = todos vermelhos por 1 s.** Nenhum veículo é liberado enquanto o sistema não estabiliza; é a mesma convenção dos semáforos reais ao religar. Alternativa descartada: amarelo piscante (exigiria estado extra e não libera ninguém também, mas é menos óbvio de validar).
2. **Reset assíncrono** no registrador de estado (como no Vahid e no trabalho anterior): o botão age imediatamente, sem esperar a borda de 1 Hz. Estado após reset entra no `if reset = '1'` do processo síncrono.
3. **1 s por estado via clock dividido** (100 MHz → 1 Hz) em entidade separada. A FSM recebe `clk_1hz` como seu clock e fica **idêntica** ao modelo da aula (sem sinal de enable extra dentro dela). Os exemplos do professor não têm temporização nenhuma, então esta é a forma que menos mexe no template. Alternativa (não adotada): contador gera um pulso `tick` de 1 ciclo e a FSM avança só quando `tick='1'`; é a prática recomendada em projetos maiores (evita clock derivado de lógica), mas altera o processo síncrono em relação ao modelo da aula.
4. **LEDs internos** (9 dos 16 LEDs da placa) como entrega principal: zero fiação, demonstração confiável. **LEDs externos confirmados como extra** (temos LEDs e protoboard; fase 9). Agrupados com um LED apagado entre vias para a leitura visual:

   | Via | Vermelho | Amarelo | Verde |
   |---|---|---|---|
   | A | LED15 | LED14 | LED13 |
   | B | LED10 | LED9 | LED8 |
   | C | LED5 | LED4 | LED3 |

   **LEDs externos** (protoboard com LEDs vermelho/amarelo/verde reais, nos conectores de expansão, resistores de 330 Ω) como extra para o vídeo, se houver material. O enunciado pede explicitamente o *motivo* da escolha: internos = confiabilidade e tempo; externos = cores reais, melhor didática. Os 2 LEDs RGB da placa não cobrem 3 vias, por isso não são a solução principal (poderiam espelhar as vias A e B).

5. **Saídas Moore** definidas no processo combinacional por estado (como no Vahid, Fig. 5.20/5.21): cada estado atribui explicitamente os 9 sinais, sem valor padrão implícito, o que evita latch e deixa a tabela de saídas legível no código.

### 3.2 Estrutura da FSM (template do professor, `maquina_exemplo.vhd`)

O que o template fixa e o `src/fsm_semaforo.vhd` copia à risca:

| Elemento | No exemplo da aula | No nosso código |
|---|---|---|
| Arquitetura | `architecture behavior of …` | igual |
| Tipo e sinais | `type estado is (A, B); signal prox_estado, atual_estado : estado;` | `type estado is (S_RESET, S_A_VERDE, …)`; mesmos nomes de sinais |
| Processo 1 (síncrono) | `process(clk, reset)`, `if (reset = '1') then atual_estado <= A; elsif (rising_edge(clk)) then atual_estado <= prox_estado;` | igual, reset leva a `S_RESET` |
| Processo 2 (combinacional) | `process(…)` com um `case atual_estado is`; em cada `when`, saída e `prox_estado` | igual; 9 saídas por estado; transições incondicionais |
| Tipo de máquina | exemplo 1 = Moore (saída fora do `if`), exemplo 2 = Mealy | Moore (exemplo 1) |
| Processos | anônimos, sem rótulo | anônimos |
| `when others` | não tem | não tem (o tipo enumerado cobre todos os casos) |

**Diferença única, proposital: a lista de sensibilidade do processo combinacional.** Os exemplos usam `process(prox_estado, entrada)`; o correto é `process(atual_estado, entrada)`, porque o `case` lê `atual_estado`. Verificado com GHDL em 19/11/2026: o exemplo 1, simulado como está, fica travado com `saida = '0'` mesmo com `entrada = '1'`, porque o processo nunca acorda quando `atual_estado` muda. No FPGA funciona porque o Vivado ignora a lista de sensibilidade e sintetiza pelo corpo. Usamos `process(atual_estado)`; explicar no vídeo em uma frase ("mesma estrutura da aula; só a lista de sensibilidade aponta para o sinal que o `case` lê, para a simulação bater com a placa").

### 3.3 Arquivos

```
semaforo/
├── PLAN.md
├── semaforo.pdf, leitura_projeto RTL.pdf, DE0_Nano_User_Manual.pdf   (fontes)
├── src/
│   ├── divisor_clock.vhd     # 100 MHz -> 1 Hz; generic DIVISOR (default 100_000_000) p/ simular rápido
│   ├── fsm_semaforo.vhd      # FSM centralizada (3.2); entradas clk, reset; saídas 9 bits
│   └── semaforo.vhd          # TOPLEVEL: instancia divisor + fsm, mapeia nos LEDs
├── tb/
│   ├── tb_divisor_clock.vhd  # período de saída = DIVISOR ciclos; duty; reset
│   ├── tb_fsm_semaforo.vhd   # sequência, 1 ciclo por estado, invariante R3, reset no meio
│   ├── tb_semaforo.vhd       # integração com DIVISOR pequeno (ex.: 10)
│   └── run.sh                # ghdl -a / -e / -r com asserts; gera .ghw
├── vivado/
│   ├── semaforo.xdc          # pinos (tabela em 2) + create_clock 10 ns em clk
│   ├── criar_projeto.tcl, gerar_bitstream.tcl, programar.tcl, vivado.bat, README.md
├── docs/
│   ├── diagrama_estados.(svg|png)   # para o vídeo
│   ├── roteiro_video.md             # falas, ordem, tempo
│   └── relatorio_recursos.txt       # saída do report_utilization (opcional)
└── Makefile                   # sim, sim-gui, pacote, clean
```

## 4. Fases (cada fase só avança quando o teste passa)

### Fase 0 — Setup (nesta máquina) ✅ 19/11/2026
- [x] GHDL 4.1 + GTKWave instalados (apt). Remover ao final (`make desinstalar-ghdl`).
- [x] Pastas `src/ tb/ vivado/ docs/`; `git init`; `.gitignore`.
- [x] Makefile: `make sim [TB=…]`, `make sim-all`, `make sim-gui`, `make pacote`, `make clean`. Script `tb/run.sh` compila em VHDL-2008 e roda com `--assert-level=error`, gerando `tb/work/<tb>.ghw`.

### Fase 1 — Fixar o template da aula ✅ 19/11/2026
- [x] Exemplos do professor em `exemplos de máquinas de estados-20261119/`. Estrutura copiada (tabela em 3.2). Temporização: os exemplos não têm, logo clock dividido fora da FSM (decisão 3).

### Fase 2 — Divisor de clock (`src/divisor_clock.vhd`) ✅ 19/11/2026
- [x] `generic (DIVISOR : natural := 100_000_000)`; `clk, reset : in; clk_saida : out`. Contador até `DIVISOR/2 - 1` alternando a saída (50 %). Reset zera contador e saída, então o primeiro período após o reset é inteiro.
- [x] `tb/tb_divisor_clock.vhd` com `DIVISOR => 10`: nível alto = 5 ciclos, período = 10 ciclos, reset no meio zera a saída e o período seguinte continua correto. Passa.
- Na placa: 100 MHz / 100 000 000 = 1 Hz (contador de 26 bits até 49 999 999).

### Fase 3 — FSM (`src/fsm_semaforo.vhd`) ✅ 19/11/2026
- [x] Implementada no formato do template (3.2). Cabeçalho com diagrama e tabela de saídas; cada `when` comentado.
- [x] `tb/tb_fsm_semaforo.vhd`: (1) todos vermelhos após reset; (2) ordem RESET→A_V→A_A→B_V→B_A→C_V→C_A→A_V por três ciclos; (3) invariante a cada borda de descida: 1 luz por via e ≤ 1 via fora do vermelho; (4) reset assíncrono no meio de `S_C_VERDE` leva a `S_RESET` na hora e o ciclo recomeça por A. Passa.
- [ ] Latches: GHDL não reclama; confirmar no relatório de síntese do Vivado (fase 5).

### Fase 4 — Toplevel (`src/semaforo.vhd`) ✅ 19/11/2026
- [x] Portas `clk`, `reset`, `led(15 downto 0)` (nomes iguais ao XDC). `generic DIVISOR` repassado ao divisor. Instâncias `DIV` e `FSM` via `component`. LEDs 12, 11, 7, 6, 2, 1, 0 em '0'.
- [x] `tb/tb_semaforo.vhd` com `DIVISOR => 10`: LEDs corretos em cada estado, cada estado dura exatamente 10 ciclos por dois ciclos completos, reset no meio. Passa.
- [ ] Salvar forma de onda (`make sim-gui` → GTKWave → PNG em `docs/`) para o vídeo.

### Fase 5 — Restrições e fluxo Vivado (`vivado/`) — arquivos prontos, execução pendente
- [x] `semaforo.xdc`: `CFGBVS`/`CONFIG_VOLTAGE`, `clk` em F14 com `create_clock` de 10 ns, `reset` em J2 com false path, `led[0..15]`. Sem `CLOCK_DEDICATED_ROUTE FALSE` (F14 é pino de clock). Linha opcional comentada com `create_generated_clock` para `clk_1hz`.
- [x] `criar_projeto.tcl`, `gerar_bitstream.tcl`, `programar.tcl`, `vivado.bat`, `README.md` adaptados do trabalho anterior (top `semaforo`, VHDL-2008, `tb_semaforo` como topo da simulação).
- [ ] **Na máquina Windows:** `make pacote` → `C:\SEMAFORO` → `source criar_projeto.tcl` → Generate Bitstream. Conferir 0 erros, 0 latches, ~35 FFs, 0 BRAM. Copiar `vivado/utilizacao.txt` para `docs/`.
- [ ] Prints para o vídeo: Schematic (blocos DIV e FSM) e Report FSM (7 estados, codificação escolhida pelo Vivado).

### Fase 6 — Prototipação na Boolean Board
- [ ] Placa na USB (PROG/UART), J13 em **JTAG**. Hardware Manager → Program device (`semaforo.bit`) ou `programar.tcl`.
- [ ] Cronometrar: ciclo completo A→A deve levar 6 s; 1 s de tudo vermelho após apertar BTN0.
- [ ] Teste do reset: apertar BTN0 em cada um dos 7 estados; sempre volta para todos vermelhos imediatamente.
- [ ] Segurar BTN0: fica em todos vermelhos enquanto pressionado (reset assíncrono nível alto).
- [ ] Opcional: LEDs externos na protoboard (fase 9) e teste de polaridade.
- [ ] Gravar o `.bit` na ROM (J13 em PROM + Configuration Memory Device) para a placa iniciar sozinha no dia, sem Vivado. Opcional, mas evita depender do notebook na apresentação.

### Fase 7 — Documentação para o vídeo (`docs/`)
- [ ] `diagrama_estados.svg`: 7 estados, saídas por estado, reset. Gerar com draw.io/Graphviz; é o primeiro item exigido no vídeo.
- [ ] Tabela de estados × saídas (9 colunas) para colar no slide.
- [ ] `roteiro_video.md` (≤ 10 min; ambos aparecem):

  | Tempo | Conteúdo | Quem |
  |---|---|---|
  | 0:00–0:30 | Apresentação da dupla, objetivo, placa | ambos |
  | 0:30–2:30 | Diagrama de estados e condição de segurança do reset (R4) | 1 |
  | 2:30–5:00 | Código: processo síncrono, processo combinacional (R5), divisor de 1 s (R6), toplevel | 2 |
  | 5:00–7:30 | FPGA ao vivo: ciclo de 6 s cronometrado, reset em vários estados | 1 |
  | 7:30–9:00 | Escolhas de projeto: LEDs internos × externos e motivos, reset assíncrono, clock dividido | 2 |
  | 9:00–9:30 | Fechamento | ambos |

### Fase 8 — Entrega
- [ ] Revisão dos comentários em todos os `.vhd` (cabeçalho: nome, função, portas, autores).
- [ ] Zip: `src/`, `tb/`, `vivado/semaforo.xdc`, `docs/diagrama_estados.*`, `README.md` curto (como simular, como gravar).
- [ ] Vídeo no YouTube (não listado) + link em `docs/video.txt` e no envio.
- [ ] Ensaiar a apresentação com cronômetro (limite 10 min, nota zero se não apresentar).

### Fase 9 — Extras (só depois da fase 8 fechada)
- [ ] LEDs externos em protoboard nos conectores de expansão (3 × R/Y/G, 330 Ω) espelhando os internos; pinos a tirar do manual da Boolean Board (seção dos conectores de expansão).
- [ ] Pedestre: BTN1 como pedido; estado `S_PEDESTRE` (todos vermelhos + LED RGB verde) inserido após o próximo amarelo. Entrada na FSM exige sincronizador/latch do pedido (registrar `pedido` até ser atendido). Só vale a pena se o template da aula tiver FSM com entrada condicional.
- [ ] Mostrar o estado atual no display de 7 segmentos (dígito 0–6) para facilitar o vídeo.

## 5. Riscos

| Risco | Mitigação |
|---|---|
| Estrutura da FSM diferente da "vista em aula" (critério explícito de nota) | Fase 1 antes de codificar; comparar lado a lado com o exemplo do professor |
| Fluxo Vivado só testável na máquina Windows | Scripts já usados com sucesso no trabalho anterior; reservar uma ida ao laboratório antes do dia |
| Clock derivado de lógica (se FSM usar `clk_1hz`) | Aviso do Vivado, não erro; alternativa `tick` pronta se o professor preferir |
| Contador de 1 s errado na placa (ex.: 0,5 s por alternar a cada `DIVISOR` em vez de `DIVISOR/2`) | Testbench mede o período em ciclos; cronometrar na placa |
| Bounce no BTN0 | Irrelevante: reset de nível, múltiplas bordas só re-resetam |
| Prazo 04/12 (15 dias) | Fases 0–4 até 23/11; fase 5–6 na primeira ida ao laboratório; vídeo até 01/12 |

## 6. Perguntas para o professor
1. Divisão dos 10 pontos (o PDF corta em "Sendo:").
2. LEDs internos da placa são aceitos como entrega principal, com externos como extra?
3. Um estado "todos vermelhos" entre vias (além do reset) é bem-visto ou altera a sequência esperada?
4. (Opcional, com tato) A lista de sensibilidade dos exemplos (`prox_estado`) trava a simulação; podemos usar `atual_estado` mantendo o resto igual?

## 7. Como rodar

```bash
make sim-all                 # os três testbenches (GHDL)
make sim TB=tb_fsm_semaforo  # só um
make sim-gui TB=tb_semaforo  # abre o GTKWave com tb/work/tb_semaforo.ghw
make pacote                  # zip para a máquina com Vivado
```
