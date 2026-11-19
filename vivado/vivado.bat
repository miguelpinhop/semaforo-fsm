@echo off
rem Roda um script Tcl no Vivado em modo batch, no Windows.
rem Uso (prompt de comando, dentro da pasta vivado\):
rem   vivado.bat criar_projeto.tcl
rem   vivado.bat gerar_bitstream.tcl
rem   vivado.bat programar.tcl
rem Procura o Vivado em C:\Xilinx\Vivado\<versao>\bin. Se estiver em outro lugar,
rem defina a variavel VIVADO_BAT com o caminho completo de vivado.bat.
setlocal
if "%~1"=="" ( echo Informe o script Tcl. Ex.: vivado.bat criar_projeto.tcl & exit /b 1 )
if not defined VIVADO_BAT (
  for /d %%D in ("C:\Xilinx\Vivado\*") do if exist "%%D\bin\vivado.bat" set "VIVADO_BAT=%%D\bin\vivado.bat"
)
if not defined VIVADO_BAT (
  echo Vivado nao encontrado em C:\Xilinx\Vivado. Defina VIVADO_BAT.
  exit /b 1
)
echo Usando %VIVADO_BAT%
cd /d "%~dp0"
call "%VIVADO_BAT%" -mode batch -source "%~1" -nojournal -log "%~n1.log"
endlocal
