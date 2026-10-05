# Teoría musical aplicada

## Qué buscamos

El robot conserva una voz reconocible y mensajes breves. El sentimiento vive en una terminación que combina notas, tiempo, articulación y timbre. El diseño es propio; no es un sistema científicamente validado para transmitir catorce emociones en sonidos de menos de un segundo.

## Evidencia que inspira el diseño

Un experimento de Micallef Grimaud y Eerola estudió cómo tempo, altura, dinámica, brillo, articulación, modo e instrumentación contribuyen a la expresión emocional. Entre sus resultados aparecen combinaciones diferenciadas para alegría, calma y tristeza. También muestra que el efecto depende de varias señales y del material musical, no de una única propiedad. Sus fragmentos duraban 15–32 segundos; nuestros cierres son mucho más breves, por lo que la aplicación requiere escucha y ajuste propios. [Artículo original, PLOS ONE, 2022](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0279605).

En armonía tonal, las cadencias ayudan a expresar conclusión o continuidad. Una cadencia auténtica resuelve de dominante a tónica; una semicadencia termina en dominante y deja expectativa. [Material docente de UCSB sobre cadencias](https://rothfarb.faculty.music.ucsb.edu/courses/160A/cadences.html).

Nuestro sintetizador actual reproduce melodías monofónicas con armónicos. Sus gestos de llegada son inspirados por la resolución tonal; no se presentan como cadencias armónicas completas de dos acordes. Los armónicos que dan timbre a una nota tampoco equivalen a una progresión de acordes.

## Centro tonal

Do funciona como lugar de descanso en muchas terminaciones. Llegar a él puede servir como punto final, mientras que sostener sol u otra nota permite una pregunta abierta. Para que el usuario sepa que la transmisión terminó incluso con música abierta, el protocolo mantiene una frontera temporal y un silencio final.

Los mensajes Morse se mantienen en mi. Así el contenido usa un tono estable y el cierre puede moverse alrededor de do. Esta es una decisión de identidad sonora, no una exigencia del código Morse.

## Intervalos y color

Los saltos de do-mi-sol-do usan notas del acorde mayor y dan espacio a cierres ágiles. La variante triste incorpora mi bemol para cambiar el color. La preocupada alterna do y re bemol: un movimiento de semitono que conserva tensión. Ningún intervalo tiene por sí solo un significado emocional garantizado.

En la primera aliviada, re bemol-do generaba un roce que al usuario le sonó extraño. La versión elegida elimina ese comienzo y hace sol-fa-mi-do. Su carácter depende del descenso, de que las notas se alarguen y de que disminuyan intensidad y brillo. Es una corrección basada en la escucha del usuario.

## Velocidad y ritmo

Una melodía rápida con notas separadas puede servir para entusiasmo; la misma energía tonal con notas prolongadas puede servir para satisfacción. El alivio recorre una desaceleración. La preocupación acelera una alternancia estrecha. La duda introduce pausas que interrumpen el avance.

La velocidad tiene dos controles independientes: duración del punto Morse para el contenido y escala temporal para el aviso y la terminación. El mensaje nunca cambia de velocidad según la emoción. Esto evita convertir la lectura de las letras en una variable emocional.

## Articulación y timbre

Ataques cortos y silencios producen impulsos separados. Ataques y caídas más suaves, con pequeños huecos, producen una sensación más ligada. No se usa volumen alto como sustituto de emoción.

La fundamental aporta altura; segundo y tercer armónico añaden brillo. Los catorce perfiles mantienen esa misma familia de timbre, variando cuánto participan los armónicos. El robot no necesita imitar instrumentos reales para tener carácter.

## Escuchar antes de asignar

Comparar siempre la misma palabra, por ejemplo OK, con diferentes terminaciones. Primero comprobar que se distinguen; después preguntar qué evocan. Ajustar patrones que se confundan, especialmente aliviada, tranquila y satisfecha. Guardar una variante estable para usos frecuentes: en este proyecto es OK listo para usar para la copia exitosa.

Las etiquetas curiosa, disculpa o preocupación son convenciones de diseño que se aprenden. Un error no implica necesariamente tristeza: ERR puede combinarse con distintos cierres según el uso. El significado del evento lo da la palabra; su matiz lo da la música.

## Reproducción de bajo nivel

La suma de ondas y la envolvente se calculan directamente en PowerShell. Windows reproduce el PCM mediante la clase .NET SoundPlayer, sin motores musicales adicionales. [SoundPlayer.PlaySync](https://learn.microsoft.com/en-us/dotnet/api/system.media.soundplayer.playsync).
