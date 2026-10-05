param([ValidateSet('Bell','Shimmer','Retro','All')][string]$Style = 'All')
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Synthesized mono PCM, entirely in memory. No external audio assets.
function Play-Cue([string]$Kind) {
    $rate = 22050
    $duration = 0.75
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
    $notes = @(523.25, 659.25, 783.99)
    for ($i = 0; $i -lt $count; $i++) {
        $t = $i / [double]$rate
        $sample = 0.0
        for ($n = 0; $n -lt 3; $n++) {
            $age = $t - $n * 0.10
            if ($age -lt 0) { continue }
            $f = $notes[$n]
            $attack = [Math]::Min(1.0, $age / 0.008)
            $endFade = [Math]::Min(1.0, ($duration - $t) / 0.04)
            $phase = 2 * [Math]::PI * $f * $age
            switch ($Kind) {
                'Bell' {
                    $v = [Math]::Sin($phase) + 0.30 * [Math]::Sin(2.01 * $phase) + 0.12 * [Math]::Sin(3.98 * $phase)
                    $env = [Math]::Exp(-9 * $age)
                }
                'Shimmer' {
                    $v = 0.65 * [Math]::Sin($phase) + 0.25 * [Math]::Sin(1.005 * $phase) + 0.20 * [Math]::Sin(2 * $phase)
                    $env = [Math]::Exp(-6 * $age)
                }
                'Retro' {
                    $v = [Math]::Sin($phase) + 0.33 * [Math]::Sin(3 * $phase) + 0.12 * [Math]::Sin(5 * $phase)
                    $env = [Math]::Exp(-18 * $age)
                }
            }
            $sample += 0.18 * $attack * $endFade * $env * $v
        }
        $sample = [Math]::Max(-1.0, [Math]::Min(1.0, $sample))
        $writer.Write([int16]($sample * 32767))
    }
    $writer.Flush()
    $stream.Position = 0
    $player = [Media.SoundPlayer]::new($stream)
    try { $player.Load(); $player.PlaySync() }
    finally { $player.Dispose(); $writer.Dispose(); $stream.Dispose() }
}
if ($Style -eq 'All') {
    foreach ($cue in @('Bell','Shimmer','Retro')) {
        Write-Output ('Preview: ' + $cue)
        Play-Cue $cue
        Start-Sleep -Milliseconds 1100
    }
} else { Play-Cue $Style }
