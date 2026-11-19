#!/usr/bin/env bash
# Simulação com GHDL.  Uso (de qualquer pasta):
#   tb/run.sh                 -> roda tb_semaforo
#   tb/run.sh tb_fsm_semaforo -> roda o testbench indicado
#   tb/run.sh all             -> roda os três
# Gera tb/work/<tb>.ghw para abrir no GTKWave: gtkwave tb/work/tb_semaforo.ghw
set -euo pipefail
cd "$(dirname "$0")"
TB="${1:-tb_semaforo}"
STD=08
mkdir -p work

FONTES=(../src/divisor_clock.vhd ../src/fsm_semaforo.vhd ../src/semaforo.vhd)

roda() {
    local tb=$1
    echo "=== $tb ==="
    ghdl -a --std=$STD --workdir=work "${FONTES[@]}" "$tb.vhd"
    ghdl -e --std=$STD --workdir=work -o "work/$tb" "$tb"
    ghdl -r --std=$STD --workdir=work "$tb" --wave="work/$tb.ghw" --assert-level=error
}

if [[ "$TB" == "all" ]]; then
    for t in tb_divisor_clock tb_fsm_semaforo tb_semaforo; do roda "$t"; done
else
    roda "$TB"
fi
