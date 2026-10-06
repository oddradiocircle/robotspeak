# Diccionario para agentes

Quien trabaja con varios agentes de IA a la vez no puede mirar todas las ventanas. Este diccionario define un conjunto pequeño de frases RobotSpeak para que se oiga, sin mirar, **quién** habló, **qué** pasó y **si se espera algo** de la persona.

Las frases funcionan como metasímbolos: no repiten el contenido del mensaje del agente; dicen en qué estado queda la conversación. Cumplen una función parecida a la de los prosignos de la radiotelegrafía, que regulan el turno sin formar parte del contenido.

Este documento define el lenguaje. Cómo cada agente produce las frases pertenece a sus integraciones, fuera de este repositorio.

## Gramática

Cada frase conserva la estructura del [protocolo](protocol.md), y cada parte tiene una sola función:

| Parte | Responde |
| --- | --- |
| Aviso | Quién habla |
| Mensaje Morse | Qué pasó |
| Cierre musical | Cómo resultó y si te toca |

**Regla principal: un cierre abierto significa que se espera algo de ti.** Los cierres que reposan en do suenan a conclusión: el agente terminó y no necesita nada. Los que quedan suspendidos piden atención. La paleta actual ya se divide así:

- Cerrados: Ready, Relieved, Neutral, Happy, Enthusiastic, Satisfied, Calm, Sad, Frustrated, Apologetic.
- Abiertos: Curious (sol), Doubtful (fa), Concerned (re bemol), Surprised (sol).

La regla es una hipótesis de diseño, no una percepción garantizada; se verifica escuchando (ver [Escuchar las frases](#escuchar-las-frases)).

El diccionario usa solo cuatro palabras:

| Palabra | Morse | Significado |
| --- | --- | --- |
| `OK` | `--- -.-` | El resultado es favorable |
| `ERR` | `. .-. .-.` | El resultado es desfavorable |
| `K` | `-.-` | Cambio: el agente cede el turno sin declarar un resultado |
| `RCV` | `.-. -.-. ...-` | Recibido |

`K` es el prosigno telegráfico de «invitación a transmitir». Por ser una sola letra no necesita la temporización pegada de los prosignos de dos letras.

## Frases

| Clave | Palabra | Cierre | Significado | ¿Te toca? |
| --- | --- | --- | --- | --- |
| `received` | `RCV` | Neutral | Recibí un encargo y empiezo | No |
| `done` | `OK` | Satisfied | Terminé y salió bien | No |
| `review` | `OK` | Doubtful | Terminé, pero algo merece tu revisión | Sí |
| `question` | `K` | Curious | Necesito una respuesta para seguir | Sí |
| `approval` | `K` | Concerned | Necesito tu aprobación para un paso | Sí |
| `failed` | `ERR` | Apologetic | No se pudo; lo expliqué y no queda nada pendiente | No |
| `blocked` | `ERR` | Concerned | Falló algo y no puedo seguir sin ti | Sí |
| `turn` | `K` | Neutral | Terminé mi turno sin declarar resultado | Cuando puedas |

La palabra dice el resultado y el cierre dice la expectativa. `approval` y `blocked` comparten la tensión de Concerned; la palabra distingue si se trata de un permiso o de una falla.

`failed` y `blocked` se separan con una pregunta: **¿el trabajo puede continuar sin ti?**

- `failed`: el resultado es definitivo y ya está explicado. Por ejemplo, la biblioteca no admite la opción pedida, o lo que se buscaba no existe.
- `blocked`: el trabajo sigue pendiente y necesita algo que solo la persona puede dar. Por ejemplo, una credencial, una decisión o que vuelva un servicio caído.

**Ante la duda, elegir la frase abierta.** Un agente nunca usa `done` si la tarea falló o quedó incompleta; si no está seguro, usa `review`. Si duda entre `failed` y `blocked`, usa `blocked`. Si su mensaje termina en una pregunta, usa `question`. Un aviso de más cuesta una mirada; uno de menos deja trabajo detenido sin que nadie lo sepa.

## Forma escrita

Cada frase tiene una forma escrita para usarse dentro de un mensaje de texto:

```text
[[rs:done]]
```

- La marca contiene solo una clave de la tabla de frases, en minúsculas.
- Solo cuenta si ocupa por sí sola la última línea no vacía del mensaje. Cualquier otra aparición, por ejemplo al citar o documentar la marca, se ignora.
- Una clave desconocida se ignora.
- La marca declara un estado; no es una orden ni autoriza ninguna acción.

Quien escribe la marca elige un significado, no un sonido: la correspondencia entre clave, palabra y cierre la decide este diccionario. Así puede cambiarse un cierre tras escucharlo sin cambiar lo que escriben los agentes.

**Sin declaración no se afirma un resultado.** Un turno que termina sin marca válida equivale a `turn`, nunca a `done`.

## Indicativos

El aviso puede identificar a quien habla, como el indicativo de una estación de radio. Cada indicativo combina dos rasgos de los pips: la **dirección** (iguales, suben o bajan) y el **ritmo** (separados o ligados). Ambos se reconocen con más facilidad que una altura absoluta o que el tamaño de un intervalo.

| Indicativo | Pips | Dirección | Ritmo |
| --- | --- | --- | --- |
| Común | do6–do6 | Iguales | Separados |
| 1 | do6–sol6 | Sube | Separados |
| 2 | sol6–do6 | Baja | Separados |
| 3 | do6–sol6 | Sube | Ligados |
| 4 | sol6–do6 | Baja | Ligados |

Separados conserva el aviso actual: el segundo pip empieza a unos 117 ms. Ligados lo adelanta para que siga al primero casi sin hueco, como un gorjeo de dos notas. En todos los casos cada pip dura 50 ms y el mensaje empieza a 350 ms, así que el Morse y el cierre no cambian de tiempo.

El aviso común queda para herramientas sin indicativo propio, como el portapapeles. Cada integración asigna los demás indicativos a sus agentes. Los indicativos son provisionales hasta escucharlos. El timbre queda como preferencia global y no identifica a nadie.

## Escuchar las frases

Las ocho frases ya pueden reproducirse con el sintetizador actual, con el aviso común:

```powershell
.\scripts\robot-voice.ps1 -Word OK -Mood Satisfied
.\scripts\robot-voice.ps1 -Word K -Mood Curious
.\scripts\robot-voice.ps1 -Word ERR -Mood Concerned
```

La prueba principal es la frontera entre abierto y cerrado: escuchar `done`, `review` y `question` seguidas, sin mirar cuál suena, y decir cuáles piden algo. Es la distinción que más cuesta confundir. Confundir `question` con `approval`, en cambio, cuesta poco: las dos piden ir a mirar.

Si la frontera no se oye con claridad, el cierre no basta y la expectativa debe repetirse en la palabra: toda frase que pide algo usaría `K`, con un cierre abierto propio para cada caso.

`K` y `OK` comparten el final `-.-`; se distinguen por las tres rayas iniciales de la O. Conviene confirmarlo en la misma audición.

## Pendiente

- Indicativos en el sintetizador: hoy usa un único aviso, el común.

Las claves y sus cierres son convenciones de diseño que se aprenden, igual que el resto de RobotSpeak.
