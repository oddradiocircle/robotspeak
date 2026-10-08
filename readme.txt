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

macOS, Linux o WSL:
  bash scripts/speak.sh -Word OK -Mood Ready
  bash tests/smoke.sh
  bash tests/parity.sh   (solo WSL)

Windows usa Windows PowerShell/.NET. WSL usa Perl si Linux tiene
reproductor (paplay con WSLg); si no, invoca PowerShell con wslpath.
macOS y Linux usan Perl incluido en el sistema y reproducen con afplay
(macOS) o paplay, pw-play o aplay (Linux). Ambos motores generan el
mismo PCM. No requiere Python, Node, audio descargado ni archivos WAV
persistentes.

Documentación: docs/protocol.md, docs/theory.md, docs/emotions.md,
docs/dictionary.md, docs/testing.md. Los experimentos históricos están en experiments/.

Código: https://github.com/oddradiocircle/robotspeak
Habilidad: https://github.com/oddradiocircle/windows-clipboard
Licencia MIT. Daniel Gómez / oddradiocircle, 2026.
