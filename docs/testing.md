# Pruebas y plataformas

Windows usa Windows PowerShell 5.1 y las clases .NET. WSL, mediante `scripts/speak.sh`, usa el motor Perl si Linux tiene reproductor, por ejemplo `paplay` con WSLg; si no, invoca ese mismo ejecutable de Windows, sin instalar PowerShell en Linux. macOS y Linux usan `scripts/robot-voice.pl` con el Perl del sistema; Linux necesita además PulseAudio, PipeWire o ALSA con su reproductor (`paplay`, `pw-play` o `aplay`).

`tests/smoke.sh` repite las comprobaciones silenciosas con el motor Perl. `tests/parity.sh`, solo en WSL, genera 28 casos con los dos motores, incluidas combinaciones de `-Parts`, y exige el mismo PCM; admite una diferencia de un paso por muestra, porque las bibliotecas matemáticas pueden redondear distinto el último bit. La reproducción nativa se probó de oído con `paplay` en Ubuntu 24.04 sobre WSL2 (WSLg), con el motor Perl. No se han probado `pw-play`, `aplay` ni macOS (`afplay`).

`tests/smoke.ps1` carga sin reproducción los catorce PCM, los tres timbres, las tres articulaciones, los cinco indicativos, las combinaciones de partes y las ocho frases del [diccionario](dictionary.md). Comprueba que Word no admita cuatro letras, minúsculas, una palabra vacía ni el antiguo token R, y rechaza duraciones Morse y partes inválidas. No requiere Pester ni módulos descargados.

Las pruebas del paquete windows-clipboard ejercitan una copia real con Unicode, saltos de línea y caracteres de shell literales. Su fixture conserva y restaura el portapapeles únicamente en memoria. La prueba completa emite una confirmación audible.

Las ejecuciones que acceden a PowerShell de Windows pueden requerir permiso del agente. Si el sistema bloquea scripts por su política de ejecución, explicar el error y pedir autorización para ese proceso; no cambiar la política de todo el equipo ni silenciar el fallo.

Una carga PCM y una llamada de reproducción exitosas no prueban que el usuario escuchó ni identificó la emoción. La duración de 50 ms procede de la aprobación humana durante las audiciones. El cierre de disponibilidad sustituye al aliviado en el portapapeles, siguiendo la corrección del usuario.
