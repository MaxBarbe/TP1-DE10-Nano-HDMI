param([string]$Ghdl = 'ghdl')
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
New-Item -ItemType Directory -Force 'tests/work' | Out-Null
function Invoke-Ghdl([string[]]$GhdlArgs) {
    & $Ghdl @GhdlArgs
    if ($LASTEXITCODE -ne 0) { throw "GHDL a echoue : $GhdlArgs" }
}
Invoke-Ghdl @('-a', '--std=08', '--work=altera_mf', '--workdir=tests/work', 'tests/image_data.vhd', 'tests/altsyncram_model.vhd')
# Le meme modele en work permet la liaison par defaut du composant historique.
Invoke-Ghdl @('-a', '--std=08', '--workdir=tests/work', '-Ptests/work', 'tests/image_data.vhd', 'tests/altsyncram_model.vhd', 'vga_rom3.vhd', 'affichage_image_filtre.vhd', 'I2C.vhd', 'i2c_hdmi_config.vhd', 'HDMI_image_student.vhd', 'tests/tb_video.vhd')
Invoke-Ghdl @('-r', '--std=08', '--workdir=tests/work', '-Ptests/work', 'tb_video', '--assert-level=error')
Invoke-Ghdl @('-a', '--std=08', '--workdir=tests/work', '-Ptests/work', 'tests/tb_i2c.vhd', 'tests/tb_startup.vhd')
Invoke-Ghdl @('-r', '--std=08', '--workdir=tests/work', '-Ptests/work', 'tb_i2c', '--assert-level=error')
Invoke-Ghdl @('-r', '--std=08', '--workdir=tests/work', '-Ptests/work', 'tb_startup', '--assert-level=error')
