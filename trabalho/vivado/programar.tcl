# Grava vivado/semaforo.bit na Boolean Board pela USB (PROG/UART).
# Uso (pasta vivado/):  vivado -mode batch -source programar.tcl
# Pré-requisitos: placa ligada, jumper J13 em "JTAG", bitstream gerado.

set raiz [file normalize [file dirname [info script]]/..]
set bit  [file join $raiz vivado semaforo.bit]

open_hw_manager
connect_hw_server
open_hw_target
set dev [lindex [get_hw_devices xc7s50*] 0]
current_hw_device $dev
set_property PROGRAM.FILE $bit $dev
program_hw_devices $dev
puts "Gravado: $bit em [get_property PART $dev]"
close_hw_target
disconnect_hw_server
close_hw_manager
