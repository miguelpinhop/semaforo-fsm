# Controle de semáforos em VHDL - Boolean Board
# Simulação local com GHDL; síntese/gravação com Vivado (máquina Windows, ver vivado/README.md)
TB ?= tb_semaforo

.PHONY: help sim sim-all sim-gui pacote clean

help:
	@echo "make sim [TB=tb_fsm_semaforo]  - simula um testbench com GHDL (padrao: tb_semaforo)"
	@echo "make sim-all                   - roda os tres testbenches"
	@echo "make sim-gui [TB=...]          - simula e abre a forma de onda no GTKWave"
	@echo "make pacote                    - zip com src/ tb/ vivado/ para a maquina com Vivado"
	@echo "make clean                     - remove arquivos gerados"

sim:
	tb/run.sh $(TB)

sim-all:
	tb/run.sh all

sim-gui: sim
	gtkwave tb/work/$(TB).ghw &

pacote:
	zip -r semaforo_vivado.zip src tb vivado/semaforo.xdc vivado/*.tcl vivado/vivado.bat vivado/README.md -x "tb/work/*"
	@echo "Pronto: semaforo_vivado.zip (copiar para C:\\SEMAFORO na maquina com Vivado)"

clean:
	rm -rf tb/work vivado/proj vivado/.Xil vivado/*.jou vivado/*.log vivado/*.bit vivado/utilizacao.txt semaforo_vivado.zip

