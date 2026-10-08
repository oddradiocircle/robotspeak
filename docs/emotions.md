# Catálogo de terminaciones

El mensaje y el aviso son idénticos para una misma palabra. La sensación cambia exclusivamente en el cierre. El sonido de portapapeles busca expresar «OK, listo y disponible para que lo uses» mediante `Ready`. La aliviada sigue disponible para otros contextos.

| Parámetro | Intención | Construcción |
| --- | --- | --- |
| Ready | Lista para usar | Sol-do agudo; dos notas claras, breves y ascendentes |
| Relieved | Aliviada | Sol-fa-mi-do; desacelera y pierde brillo hasta descansar |
| Neutral | Neutra | Sol-do; dos notas parejas con llegada firme |
| Happy | Contenta | Do-mi-sol-do agudo; saltos breves y ligeros |
| Enthusiastic | Entusiasmada | Do-sol-do-mi-do; rápida, amplia y brillante |
| Satisfied | Satisfecha | Sol-mi-do; pulso moderado y reposo largo |
| Calm | Tranquila | Fa-mi-do; lenta, ligada y suave |
| Sad | Triste | Sol-mi bemol-re-do; color menor y notas largas |
| Curious | Curiosa | Do-re…sol; pregunta abierta con pausa antes del final |
| Doubtful | Dudosa | Mi…mi-fa; vacilación por silencios y cambio pequeño |
| Concerned | Preocupada | Do-re bemol-do-re bemol; alternancia que acelera y queda tensa |
| Frustrated | Frustrada | Sol-sol-mi bemol-do; dos impulsos y descenso seco |
| Apologetic | Disculpa | Mi…re-do; descenso pequeño, contenido y suave |
| Surprised | Sorprendida | Do…do agudo-sol; salto inesperado y recuperación |

## Audición

Usar `-Word OK -Mood All` para comparar todas con el mismo mensaje. `-Mood Ready` selecciona una; `-Repeat 3` repite cada muestra; `-EndingOnly` omite aviso y Morse. `-ValidateOnly` genera y carga el PCM sin audio.

La pausa de audición entre muestras es 1400 ms y se controla con `-PauseMs`. No se aplica después de la última, así que una notificación no espera. Los puntos Morse duran 50 ms, las rayas 150 ms y el cierre queda separado por 180 ms. `-Speed 1.2` conserva alturas y la forma relativa del ritmo; `-MorseUnitMs` controla el mensaje por separado.

Los nombres son intenciones de diseño. Compararlos por escucha antes de asignar un uso; no implican que todo oyente descifre la misma emoción. La aliviada inicial comenzaba con re bemol-do; la revisión elegida para ese perfil elimina el roce y hace sol-fa-mi-do.
