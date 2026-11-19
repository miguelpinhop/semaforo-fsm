# Cria o projeto Vivado do controle de semáforos para a Boolean Board (xc7s50csga324-1).
#
# Uso, a partir da pasta vivado/ (Tcl Console do Vivado ou terminal):
#   vivado -mode batch -source criar_projeto.tcl
# ou, com o Vivado aberto:  cd <caminho>/SEMAFORO/vivado ; source criar_projeto.tcl
#
# Depois disso o projeto fica em vivado/proj/semaforo.xpr e pode ser aberto na GUI.

set raiz    [file normalize [file dirname [info script]]/..]
set projeto semaforo
set parte   xc7s50csga324-1

create_project -force $projeto [file join $raiz vivado proj] -part $parte
set_property target_language VHDL [current_project]

# Fontes
add_files -norecurse [glob [file join $raiz src *.vhd]]
set_property file_type {VHDL 2008} [get_files *.vhd]
set_property top semaforo [current_fileset]

# Restrições
add_files -fileset constrs_1 -norecurse [file join $raiz vivado semaforo.xdc]

# Testbenches (xsim). tb_semaforo usa DIVISOR=10 via generic map, não precisa alterar nada.
add_files -fileset sim_1 -norecurse [glob [file join $raiz tb tb_*.vhd]]
set_property file_type {VHDL 2008} [get_files -of [get_filesets sim_1] *.vhd]
set_property top tb_semaforo [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {all} -objects [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "Projeto criado em [file join $raiz vivado proj $projeto.xpr]"
