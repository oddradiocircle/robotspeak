# Protocolo

## Estructura

Cada frase tiene un aviso fijo de dos pips, un mensaje Morse de una a tres letras y una terminación musical. El aviso y el Morse son iguales para una misma palabra en todas las emociones. La emoción modifica exclusivamente la terminación.

`OK` confirma una operación. `ERR` indica un error. `RCV` indica recepción de texto; en el skill del portapapeles usa el cierre Neutral descendente, mientras OK usa Ready ascendente. `K` cede el turno; su uso y las demás frases de estado están en el [diccionario](dictionary.md). No se afirma que Morse o estas abreviaturas sean comprendidos por toda persona: son un vocabulario breve y documentado. `R` como mensaje y la palabra `ERRE` se retiraron porque resultaban confusos frente a ERR; la letra R sigue disponible dentro de ERR y otras palabras.

## Temporización elegida

| Parte | Tiempo efectivo |
| --- | --- |
| Punto | 50 ms |
| Raya | 150 ms |
| Silencio dentro de una letra | 50 ms |
| Silencio entre letras | 150 ms |
| Silencio antes del cierre musical | 180 ms |
| Silencio final | unos 67 ms |

Con `-Speed 1.2`, cada pip inicial dura 50 ms. Empiezan en 0 y aproximadamente 117 ms; el mensaje empieza en 350 ms. El último símbolo Morse se separa del cierre por una pausa fija de 180 ms, aunque se cambie la duración del punto.

`-MorseUnitMs` controla directamente los puntos: cambiarlo no altera las alturas, el aviso ni la música. Las rayas mantienen la proporción 3:1. `-Speed` escala el tiempo del aviso, las notas musicales, sus silencios y sus envolventes; no modifica frecuencias ni la duración efectiva del punto. Se conservan las diferencias de velocidad dentro de cada emoción.

La duración total depende de la palabra y el cierre. A la configuración predeterminada, OK listo para usar dura unos 2,02 s, sin contar el tiempo de síntesis ni la pausa opcional entre muestras.

## Generación

Los dos motores, `robot-voice.ps1` y `robot-voice.pl`, construyen eventos de frecuencia, inicio, duración, intensidad, brillo, ataque y caída. Generan PCM mono de 16 bits a 22.050 Hz y agregan una cabecera RIFF/WAVE en memoria. Classic suma la fundamental y dos armónicos. Digital modula la fase con un oscilador a doble frecuencia y añade una onda levemente desafinada; Crystal suma parciales casi armónicos con caídas distintas. Ataque y caída suavizan los extremos de cada nota para evitar discontinuidades bruscas.

En Windows, la carga del audio valida la cabecera PCM. Los dos motores rechazan muestras que excedan su margen de amplitud. `SoundPlayer.PlaySync` en Windows, y `afplay`, `paplay`, `pw-play` o `aplay` en macOS y Linux, solicitan la reproducción síncrona; no verifican que una persona haya oído el sonido. No se cambia el volumen del sistema.

No hay llamadas de red, grabación, archivos de audio persistentes ni lectura del portapapeles en RobotSpeak. En macOS y Linux el WAV se escribe en un archivo temporal que se borra al terminar la reproducción; `-OutFile` lo guarda solo cuando se pide. El portapapeles pertenece a la habilidad separada.
