ROBOTSPEAK
==========

Aviso -> mensaje Morse -> cierre musical.
Mensaje: una a tres letras A-Z. OK confirma; ERR indica error.
R y ERRE fueron retirados como mensajes para evitar confusión con ERR.

Configuración elegida:
  Timbre: Digital (electrónico), aprobado.
  Articulación: Plain; Melodic y Expressive disponibles para comparar.
  Punto Morse: 50 ms. Raya: 150 ms.
  Pausa interna: 50 ms. Pausa entre letras: 150 ms.
  Separación antes del cierre: 180 ms.
  Velocidad de aviso/cierre: 1,2 veces la original.
  Cierre predeterminado: listo para usar (sol-do agudo).

Windows PowerShell:
  .\scripts\robot-voice.ps1 -Word OK -Mood Ready
  .\scripts\robot-voice.ps1 -Word OK -Mood All
  .\tests\smoke.ps1

WSL:
  bash scripts/speak.sh -Word OK -Mood Ready

Solo requiere Windows PowerShell/.NET para sintetizar y reproducir.
WSL usa Bash y wslpath incluidos en WSL para invocar Windows PowerShell.
No requiere Python, Node, audio descargado ni archivos WAV persistentes.

Documentación: docs/protocol.md, docs/theory.md, docs/emotions.md,
docs/testing.md. Los experimentos históricos están en experiments/.

Código: https://github.com/oddradiocircle/robotspeak
Habilidad: https://github.com/oddradiocircle/windows-clipboard
Licencia MIT. Daniel Gómez / oddradiocircle, 2026.
