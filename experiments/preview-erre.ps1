$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
function Play-RobotErre {
    $rate = 22050
    $duration = 2.08
    $count = [int]($rate * $duration)
    $stream = [IO.MemoryStream]::new()
    $writer = [IO.BinaryWriter]::new($stream)
    $writer.Write([Text.Encoding]::ASCII.GetBytes('RIFF'))
    $writer.Write([int](36 + 2 * $count))
    $writer.Write([Text.Encoding]::ASCII.GetBytes('WAVEfmt '))
    $writer.Write([int]16)
    $writer.Write([int16]1)
    $writer.Write([int16]1)
    $writer.Write([int]$rate)
    $writer.Write([int](2 * $rate))
    $writer.Write([int16]2)
    $writer.Write([int16]16)
    $writer.Write([Text.Encoding]::ASCII.GetBytes('data'))
    $writer.Write([int](2 * $count))
    # E R R E in Morse: . / .-. / .-. / . ; unit = 80 ms.
    $starts = @(0.0, 0.32, 0.48, 0.80, 1.12, 1.28, 1.60, 1.92)
    $lengths = @(0.08, 0.08, 0.24, 0.08, 0.08, 0.24, 0.08, 0.08)
    $frequencies = @(523.25, 587.33, 659.25, 783.99, 659.25, 783.99, 880.0, 1046.50)
    for ($i = 0; $i -lt $count; $i++) {
        $t = $i / [double]$rate
        $sample = 0.0
        for ($n = 0; $n -lt 8; $n++) {
            $age = $t - $starts[$n]
            if ($age -lt 0 -or $age -ge $lengths[$n]) { continue }
            $envelope = [Math]::Min(1.0, $age / 0.006) * [Math]::Min(1.0, ($lengths[$n] - $age) / 0.015)
            # A tiny upward pitch glide adds a robotic articulation.
            $phase = 2 * [Math]::PI * ($frequencies[$n] * $age + 60 * $age * $age)
            $voice = [Math]::Sin($phase) + 0.22 * [Math]::Sin(2 * $phase) + 0.08 * [Math]::Sin(3 * $phase)
            $sample += 0.24 * $envelope * $voice
        }
        $writer.Write([int16]($sample * 32767))
    }
    $writer.Flush()
    $stream.Position = 0
    $player = [Media.SoundPlayer]::new($stream)
    try { $player.Load(); $player.PlaySync() }
    finally { $player.Dispose(); $writer.Dispose(); $stream.Dispose() }
}
Play-RobotErre
