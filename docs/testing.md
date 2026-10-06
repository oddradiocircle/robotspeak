# Pruebas y plataformas

Windows PowerShell 5.1 y las clases .NET de Windows son el objetivo inicial. WSL invoca ese mismo ejecutable mediante `scripts/speak.sh`. No se requiere una instalación nativa de PowerShell en WSL. Otros sistemas de audio no están implementados.

`tests/smoke.ps1` carga sin reproducción los catorce PCM, los tres timbres, las tres articulaciones y las ocho frases del [diccionario](dictionary.md). Comprueba que Word no admita cuatro letras, minúsculas, una palabra vacía ni el antiguo token R, y rechaza duraciones Morse fuera del rango. No requiere Pester ni módulos descargados.

Las pruebas del paquete windows-clipboard ejercitan una copia real con Unicode, saltos de línea y caracteres de shell literales. Su fixture conserva y restaura el portapapeles únicamente en memoria. La prueba completa emite una confirmación audible.

Las ejecuciones que acceden a PowerShell de Windows pueden requerir permiso del agente. Si el sistema bloquea scripts por su política de ejecución, explicar el error y pedir autorización para ese proceso; no cambiar la política de todo el equipo ni silenciar el fallo.

Una carga PCM y una llamada de reproducción exitosas no prueban que el usuario escuchó ni identificó la emoción. La duración de 50 ms procede de la aprobación humana durante las audiciones. El cierre de disponibilidad sustituye al aliviado en el portapapeles, siguiendo la corrección del usuario.
