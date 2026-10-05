# Protocolo

## Estructura

Cada frase tiene un aviso fijo de dos pips, un mensaje Morse de una a tres letras y una terminación musical. El aviso y el Morse son iguales para una misma palabra en todas las emociones. La emoción modifica exclusivamente la terminación.

`OK` confirma una operación. `ERR` indica un error. `RCV` indica recepción de texto; en el skill del portapapeles usa el cierre Neutral descendente, mientras OK usa Ready ascendente. No se afirma que Morse o estas abreviaturas sean comprendidos por toda persona: son un vocabulario breve y documentado. `R` como mensaje y la palabra `ERRE` se retiraron porque resultaban confusos frente a ERR; la letra R sigue disponible dentro de ERR y otras palabras.

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

El script construye eventos de frecuencia, inicio, duración, intensidad, brillo, ataque y caída. Genera PCM mono de 16 bits a 22.050 Hz y agrega una cabecera RIFF/WAVE en memoria. Classic suma la fundamental y dos armónicos. Digital modula la fase con un oscilador a doble frecuencia y añade una onda levemente desafinada; Crystal suma parciales casi armónicos con caídas distintas. Ataque y caída suavizan los extremos de cada nota para evitar discontinuidades bruscas.

La carga del audio valida la cabecera PCM. El sintetizador también rechaza muestras que excedan su margen de amplitud. `SoundPlayer.PlaySync` solicita la reproducción síncrona; no verifica que una persona haya oído el sonido. No se cambia el volumen del sistema.

No hay llamadas de red, grabación, archivos de audio ni lectura del portapapeles en RobotSpeak. El portapapeles pertenece a la habilidad separada.
