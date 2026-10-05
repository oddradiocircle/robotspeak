# RobotSpeak

Un lenguaje sonoro de robot, generado íntegramente con PowerShell: **aviso → mensaje Morse → cierre musical**.
El mensaje tiene de una a tres letras. La terminación expresa el matiz emocional.

La configuración elegida es **OK + lista para usar**, puntos Morse de **50 ms**, rayas de **150 ms**, y velocidad musical **1,2×**. Hay catorce terminaciones y tres timbres, independientes del mensaje.

## Ejecutarlo

En Windows, desde la carpeta del repositorio:

```powershell
.\scripts\robot-voice.ps1 -Word OK -Mood Ready
.\scripts\robot-voice.ps1 -Word ERR -Mood Sad
.\scripts\robot-voice.ps1 -Word OK -Mood All
```

En WSL, conectado al mismo Windows:

```bash
bash scripts/speak.sh -Word OK -Mood Ready
bash scripts/speak.sh -Word OK -Mood All
```

No requiere Python, Node, un sintetizador externo ni archivos de audio. Usa las clases .NET incluidas en Windows PowerShell. El audio se construye en memoria y sale por el dispositivo predeterminado de Windows. PowerShell nativo en Linux/macOS no está soportado por este reproductor.

## Opciones

| Opción | Predeterminado | Uso |
| --- | --- | --- |
| `-Word` | `OK` | 1–3 letras A–Z; `ERR` indica error; `R` como mensaje está retirado |
| `-Mood` | `Ready` | Una terminación; `All` reproduce las catorce |
| `-MorseUnitMs` | `50` | Duración efectiva del punto, independiente de la velocidad musical |
| `-Speed` | `1.2` | Velocidad del aviso y cierre; conserva alturas y ritmos relativos |
| `-Timbre` | `Digital` | Classic (original), Digital (FM), Crystal (campana electrónica) |
| `-Repeat` | `1` | Repeticiones de cada versión, entre 1 y 5 |
| `-PauseMs` | `1400` | Pausa entre muestras; `0` para una notificación |
| `-EndingOnly` | desactivado | Reproduce solo la terminación |
| `-ValidateOnly` | desactivado | Genera y carga PCM sin reproducirlo |

Terminaciones: `Ready`, `Relieved`, `Neutral`, `Happy`, `Enthusiastic`, `Satisfied`, `Calm`, `Sad`, `Curious`, `Doubtful`, `Concerned`, `Frustrated`, `Apologetic`, `Surprised`.

## Documentación

- [Protocolo y temporización](docs/protocol.md).
- [Teoría musical y diseño](docs/theory.md).
- [Catálogo de emociones](docs/emotions.md).
- [Pruebas y plataformas](docs/testing.md).
- [Historia de las muestras](experiments/README.md).
- [Versión de texto plano](readme.txt).

La habilidad [windows-clipboard](https://github.com/oddradiocircle/windows-clipboard) distribuye una copia fijada de este sintetizador y confirma cada copia con OK listo para usar. RobotSpeak es la fuente del sonido; la habilidad implementa el portapapeles.

## Validación

```powershell
.\tests\smoke.ps1
```

Las pruebas generan y cargan todas las terminaciones sin sonido y comprueban entradas inválidas. La percepción emocional se afina mediante escucha; las etiquetas son intenciones de diseño, no significados universales.

MIT. Creado por Daniel Gómez / oddradiocircle.

Para comparar musicalidad dentro del mensaje, añade `-Articulation Plain`,
`-Articulation Melodic` o `-Articulation Expressive`. La primera conserva una
altura; la segunda distingue las letras por notas; la tercera también modela
el ataque y el sostén de cada pulso. Las tres conservan los tiempos Morse.
