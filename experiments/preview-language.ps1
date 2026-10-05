param([ValidateSet('Neutral','Happy','Sad','All')][string]$Variant = 'All')
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
    # The letter gap also separates the emotional punctuation.
    switch ($Mood) {
        'Neutral' { $ending = @(659.25) }
        'Happy' { $ending = @(783.99, 1046.5) }
        'Sad' { $ending = @(587.33, 392.0) }
    }
    foreach ($frequency in $ending) {
        $events.Add(@{Start=$cursor; Length=0.16; Frequency=$frequency})
        $cursor += 0.20
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
    @{Word='R'; Mood='Neutral'},
    @{Word='OK'; Mood='Happy'},
    @{Word='ERR'; Mood='Sad'}
)
foreach ($phrase in $phrases) {
    if ($Variant -ne 'All' -and $Variant -ne $phrase.Mood) { continue }
    Write-Output ($phrase.Word + ': ' + $phrase.Mood)
    Play-RobotPhrase $phrase.Word $phrase.Mood
    Start-Sleep -Milliseconds 1400
}
