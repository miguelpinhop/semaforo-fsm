# Sintetiza, implementa e gera o bitstream em modo batch.
# Uso (pasta vivado/):  vivado -mode batch -source gerar_bitstream.tcl
# Pré-requisito: criar_projeto.tcl já executado (existe proj/semaforo.xpr).

set raiz [file normalize [file dirname [info script]]/..]
open_project [file join $raiz vivado proj semaforo.xpr]

reset_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

set bit [file join $raiz vivado proj semaforo.runs impl_1 semaforo.bit]
if {[file exists $bit]} {
    file copy -force $bit [file join $raiz vivado semaforo.bit]
    puts "Bitstream pronto: [file join $raiz vivado semaforo.bit]"
} else {
    puts "ERRO: bitstream nao foi gerado. Veja os logs em vivado/proj/semaforo.runs/"
}

# Resumo de recursos para o vídeo (esperado: ~35 FFs, 0 BRAM, 0 latches)
open_run impl_1
report_utilization -hierarchical -file [file join $raiz vivado utilizacao.txt]
puts "Relatorio de recursos em vivado/utilizacao.txt"
