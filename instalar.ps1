# Instala el equipo de agentes (comandos /equipo, /dividir, /costos + reglas) en Claude Code.
#
#   Global (todos los proyectos):  .\instalar.ps1
#   Solo en un proyecto:           .\instalar.ps1 -Proyecto "C:\ruta\al\proyecto"
#
# Si un archivo ya existe se sobrescribe (los originales viven en .\plantilla).

param(
    [string]$Proyecto
)

$ErrorActionPreference = 'Stop'
$origen = Join-Path $PSScriptRoot 'plantilla'

if ($Proyecto) {
    if (-not (Test-Path $Proyecto)) { throw "No existe la carpeta del proyecto: $Proyecto" }
    $destCommands = Join-Path $Proyecto '.claude\commands'
} else {
    $destCommands = Join-Path $HOME '.claude\commands'
}

# Crear carpeta de comandos si no existe
New-Item -ItemType Directory -Force $destCommands | Out-Null

# Copiar slash commands
Copy-Item (Join-Path $origen '.claude\commands\equipo.md') $destCommands -Force
Copy-Item (Join-Path $origen '.claude\commands\dividir.md') $destCommands -Force
Copy-Item (Join-Path $origen '.claude\commands\costos.md') $destCommands -Force
Copy-Item (Join-Path $origen '.claude\commands\equipo-max.md') $destCommands -Force

Write-Host "Comandos instalados en: $destCommands"
Write-Host "  /equipo  - Equipo completo (jefe + constructores + supervisor)"
Write-Host "  /equipo-max - Maxima calidad, todo Opus, sin importar el costo"
Write-Host "  /dividir - Dividir tarea en constructores paralelos"
Write-Host "  /costos  - Tabla de precios de los modelos"

# Mostrar las reglas para CLAUDE.md
$reglasPath = Join-Path $origen 'CLAUDE.md.equipo'
Write-Host ""
Write-Host "Para activar las reglas de economia automaticamente, agrega al CLAUDE.md de tu proyecto:"
Write-Host "  el contenido de: $reglasPath"
Write-Host ""

if ($Proyecto) {
    $claudeMd = Join-Path $Proyecto 'CLAUDE.md'
    if (Test-Path $claudeMd) {
        $contenido = Get-Content $claudeMd -Raw -Encoding utf8
        $reglas = Get-Content $reglasPath -Raw -Encoding utf8
        if ($contenido -notmatch 'equipo de agentes') {
            Write-Host "Agregando reglas del equipo al CLAUDE.md existente..."
            Add-Content -Path $claudeMd -Value "`n`n$reglas" -Encoding utf8
            Write-Host "Reglas agregadas a: $claudeMd"
        } else {
            Write-Host "El CLAUDE.md ya tiene reglas del equipo, no se modifico."
        }
    } else {
        Write-Host "Creando CLAUDE.md con las reglas del equipo..."
        Copy-Item $reglasPath $claudeMd -Force
        Write-Host "CLAUDE.md creado en: $claudeMd"
    }
    Write-Host ""
    Write-Host "Sugerencia: agrega '.equipo/' al .gitignore del proyecto."
} else {
    Write-Host "Para proyectos individuales, copia las reglas al CLAUDE.md de cada proyecto."
}

Write-Host ""
Write-Host "Listo. Los comandos estaran disponibles en la proxima conversacion de Claude Code."
