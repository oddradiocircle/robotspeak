param([ValidateSet('Happy','Satisfied','Relieved','All')][string]$Variant = 'All')
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
function Play-RobotPhrase([string]$Word, [string]$Mood) {
    $events = [Collections.Generic.List[object]]::new()
    # Identical attention signal for every phrase.
    $events.Add(@{Start=0.0; Length=0.06; Frequency=1046.5})
    $events.Add(@{Start=0.14; Length=0.06; Frequency=1046.5})
    $morse = @{R='.-.'; O='---'; K='-.-'; E='.'}
    $unit = 0.08
    $cursor = 0.42
    foreach ($letter in $Word.ToCharArray()) {
        foreach ($symbol in $morse[[string]$letter].ToCharArray()) {
            $length = $unit
            if ($symbol -eq '-') { $length = 3 * $unit }
            $events.Add(@{Start=$cursor; Length=$length; Frequency=659.25})
            $cursor += $length + $unit
        }
        $cursor += 2 * $unit
    }
    # Same attention and Morse; only the musical ending changes.
    switch ($Mood) {
        'Happy' {
            $ending = @(
                @{Hz=523.25; Seconds=0.08; Gap=0.025},
                @{Hz=659.25; Seconds=0.08; Gap=0.025},
                @{Hz=783.99; Seconds=0.09; Gap=0.025},
                @{Hz=1046.50; Seconds=0.20; Gap=0.0}
            )
        }
        'Satisfied' {
            $ending = @(
                @{Hz=783.99; Seconds=0.16; Gap=0.025},
                @{Hz=659.25; Seconds=0.19; Gap=0.025},
                @{Hz=523.25; Seconds=0.34; Gap=0.0}
            )
        }
        'Relieved' {
            $ending = @(
                @{Hz=554.37; Seconds=0.065; Gap=0.015},
                @{Hz=523.25; Seconds=0.11; Gap=0.035},
                @{Hz=659.25; Seconds=0.18; Gap=0.045},
                @{Hz=523.25; Seconds=0.34; Gap=0.0}
            )
        }
    }
    foreach ($note in $ending) {
        $events.Add(@{Start=$cursor; Length=$note.Seconds; Frequency=$note.Hz})
        $cursor += $note.Seconds + $note.Gap
    }
    $duration = $cursor + 0.05
    $rate = 22050
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
    $samples = [double[]]::new($count)
    foreach ($event in $events) {
        $start = [int]($event.Start * $rate)
        $length = [int]($event.Length * $rate)
        for ($j = 0; $j -lt $length; $j++) {
            $age = $j / [double]$rate
            $envelope = [Math]::Min(1.0, $age / 0.006) * [Math]::Min(1.0, ($event.Length - $age) / 0.018)
            $phase = 2 * [Math]::PI * $event.Frequency * $age
            $voice = [Math]::Sin($phase) + 0.22 * [Math]::Sin(2 * $phase) + 0.08 * [Math]::Sin(3 * $phase)
            $samples[$start + $j] += 0.22 * $envelope * $voice
        }
    }
    foreach ($sample in $samples) { $writer.Write([int16]($sample * 32767)) }
    $writer.Flush()
    $stream.Position = 0
    $player = [Media.SoundPlayer]::new($stream)
    try { $player.Load(); $player.PlaySync() }
    finally { $player.Dispose(); $writer.Dispose(); $stream.Dispose() }
}
$phrases = @(
    @{Word='R'; Mood='Happy'},
    @{Word='R'; Mood='Satisfied'},
    @{Word='R'; Mood='Relieved'}
)
foreach ($phrase in $phrases) {
    if ($Variant -ne 'All' -and $Variant -ne $phrase.Mood) { continue }
    Write-Output ($phrase.Word + ': ' + $phrase.Mood)
    Play-RobotPhrase $phrase.Word $phrase.Mood
    Start-Sleep -Milliseconds 1800
}
