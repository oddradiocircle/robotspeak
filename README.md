# RobotSpeak

Un lenguaje sonoro de robot, generado íntegramente con herramientas incluidas en el sistema: **aviso → mensaje Morse → cierre musical**.
El mensaje tiene de una a tres letras. La terminación expresa el matiz emocional.

La configuración elegida es **OK + lista para usar**, puntos Morse de **50 ms**, rayas de **150 ms**, y velocidad musical **1,2×**. Hay catorce terminaciones, tres timbres y tres articulaciones, independientes del mensaje.

## Ejecutarlo

En Windows, desde la carpeta del repositorio:

```powershell
.\scripts\robot-voice.ps1 -Word OK -Mood Ready
.\scripts\robot-voice.ps1 -Word ERR -Mood Sad
.\scripts\robot-voice.ps1 -Word OK -Mood All
```

En macOS, Linux o WSL:

```bash
bash scripts/speak.sh -Word OK -Mood Ready
bash scripts/speak.sh -Word OK -Mood All
```

No requiere Python, Node, un sintetizador externo ni archivos de audio descargados. Hay dos motores equivalentes:

| Sistema | Motor | Reproducción |
| --- | --- | --- |
| Windows | `robot-voice.ps1` (Windows PowerShell 5.1 y .NET) | `SoundPlayer`, en memoria |
| WSL | El mismo, a través de Windows | El dispositivo predeterminado de Windows |
| macOS | `robot-voice.pl` (Perl incluido) | `afplay` |
| Linux | `robot-voice.pl` (Perl incluido) | `paplay`, `pw-play` o `aplay`, el primero disponible |

`speak.sh` elige el motor. En WSL, `ROBOTSPEAK_ENGINE=perl` usa Perl y el audio de Linux (WSLg) en lugar del de Windows. En macOS y Linux el WAV existe solo como archivo temporal durante la reproducción, porque `afplay` solo lee archivos.

Las instalaciones mínimas de Linux, como Ubuntu en WSL, pueden no traer reproductor. En Debian y Ubuntu, `sudo apt install pulseaudio-utils` instala `paplay`.

## Opciones

| Opción | Predeterminado | Uso |
| --- | --- | --- |
| `-Word` | `OK` | 1–3 letras A–Z; `OK`, `ERR`, `K` y `RCV` se definen en el [diccionario](docs/dictionary.md); `R` como mensaje está retirado |
| `-Mood` | `Ready` | Una terminación; `All` reproduce las catorce |
| `-MorseUnitMs` | `50` | Duración efectiva del punto, independiente de la velocidad musical |
| `-Speed` | `1.2` | Velocidad del aviso y cierre; conserva alturas y ritmos relativos |
| `-Timbre` | `Digital` | Classic (original), Digital (FM), Crystal (campana electrónica) |
| `-Articulation` | `Plain` | Plain (una altura), Melodic (una nota por letra), Expressive (además ataque y sostén); conserva los tiempos Morse |
| `-Callsign` | `Common` | Indicativo del aviso: `Common`, `1`–`4`; ver el [diccionario](docs/dictionary.md) |
| `-Repeat` | `1` | Repeticiones de cada versión, entre 1 y 5 |
| `-PauseMs` | `1400` | Pausa entre muestras; `0` para una notificación |
| `-OutFile` | ninguno | Escribe el WAV en vez de reproducirlo; requiere una sola terminación |
| `-EndingOnly` | desactivado | Reproduce solo la terminación |
| `-ValidateOnly` | desactivado | Genera y carga PCM sin reproducirlo |

Terminaciones: `Ready`, `Relieved`, `Neutral`, `Happy`, `Enthusiastic`, `Satisfied`, `Calm`, `Sad`, `Curious`, `Doubtful`, `Concerned`, `Frustrated`, `Apologetic`, `Surprised`.

## Documentación

- [Protocolo y temporización](docs/protocol.md).
- [Teoría musical y diseño](docs/theory.md).
- [Catálogo de emociones](docs/emotions.md).
- [Diccionario para agentes](docs/dictionary.md).
- [Pruebas y plataformas](docs/testing.md).
- [Historia de las muestras](experiments/README.md).
- [Versión de texto plano](readme.txt).

La habilidad [windows-clipboard](https://github.com/oddradiocircle/windows-clipboard) distribuye una copia fijada de este sintetizador y confirma cada copia con OK listo para usar. RobotSpeak es la fuente del sonido; la habilidad implementa el portapapeles.

## Validación

```powershell
.\tests\smoke.ps1
```

```bash
bash tests/smoke.sh    # motor Perl, en macOS y Linux
bash tests/parity.sh   # WSL: los dos motores deben generar el mismo PCM
```

Las pruebas generan todas las terminaciones sin sonido y comprueban entradas inválidas. La percepción emocional se afina mediante escucha; las etiquetas son intenciones de diseño, no significados universales.

MIT. Creado por Daniel Gómez / oddradiocircle.
