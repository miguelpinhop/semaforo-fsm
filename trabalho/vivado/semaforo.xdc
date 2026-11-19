# Restrições para a Boolean Board (Spartan-7 xc7s50csga324-1)
# Pinos conforme o tutorial "A First Vivado Project for the Boolean board" (realdigital.org),
# conferidos com o XDC do trabalho anterior (switches, LED0-7, BTN0 batem).
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# Oscilador de 100 MHz (pino de clock dedicado, MRCC)
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {clk}]
create_clock -name clk -period 10.000 [get_ports {clk}]

# reset = BTN0 ('0' solto, '1' apertado)
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {reset}]
set_false_path -from [get_ports {reset}]

# LEDs (acendem com '1')
#   Via A: LED15 vermelho, LED14 amarelo, LED13 verde
#   Via B: LED10 vermelho, LED9  amarelo, LED8  verde
#   Via C: LED5  vermelho, LED4  amarelo, LED3  verde
#   Demais LEDs ficam em '0'
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN E5 IOSTANDARD LVCMOS33} [get_ports {led[7]}]
set_property -dict {PACKAGE_PIN E6 IOSTANDARD LVCMOS33} [get_ports {led[8]}]
set_property -dict {PACKAGE_PIN C3 IOSTANDARD LVCMOS33} [get_ports {led[9]}]
set_property -dict {PACKAGE_PIN B2 IOSTANDARD LVCMOS33} [get_ports {led[10]}]
set_property -dict {PACKAGE_PIN A2 IOSTANDARD LVCMOS33} [get_ports {led[11]}]
set_property -dict {PACKAGE_PIN B3 IOSTANDARD LVCMOS33} [get_ports {led[12]}]
set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports {led[13]}]
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS33} [get_ports {led[14]}]
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports {led[15]}]
set_false_path -to [get_ports {led[*]}]

# O clock de 1 Hz da FSM (clk_1hz) sai de um flip-flop do divisor. O Vivado avisa que
# é um clock gerado por lógica; para 1 Hz isso não tem impacto. Se quiser analisá-lo:
# create_generated_clock -name clk_1hz -source [get_ports clk] -divide_by 100000000 [get_pins DIV/clk_int_reg/Q]
