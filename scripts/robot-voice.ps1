param(
    [ValidatePattern('^[A-Z]{1,3}$')][ValidateScript({[regex]::IsMatch($_, '^[A-Z]{1,3}$') -and $_ -ne 'R'})][string]$Word = 'OK',
    [ValidateSet('Ready','Relieved','Neutral','Happy','Enthusiastic','Satisfied','Calm','Sad','Curious','Doubtful','Concerned','Frustrated','Apologetic','Surprised','All')][string]$Mood = 'Ready',
    [ValidateRange(0.5,2.0)][double]$Speed = 1.2,
    [ValidateRange(10,200)][int]$MorseUnitMs = 50,
    [ValidateSet('Classic','Digital','Crystal')][string]$Timbre = 'Digital',
    [ValidateSet('Plain','Melodic','Expressive')][string]$Articulation = 'Plain',
    [ValidateSet('Common','1','2','3','4')][string]$Callsign = 'Common',
    [ValidateRange(1,5)][int]$Repeat = 1,
    [ValidateRange(0,10000)][int]$PauseMs = 1400,
    [string]$OutFile,
    [switch]$EndingOnly,
    [switch]$ValidateOnly
)
$ErrorActionPreference = 'Stop'
if ($OutFile -and $Mood -eq 'All') { throw '-OutFile requires a single -Mood.' }
$ProgressPreference = 'SilentlyContinue'
$profiles = [ordered]@{
    Ready = @{Label='Lista para usar'; Notes=@(
        @(783.99, 0.09, 0.035, 0.20, 0.7, 0.006, 0.022),
        @(1046.50, 0.20, 0, 0.20, 0.6, 0.008, 0.050)
    )}
    Relieved = @{Label='Aliviada'; Notes=@(
        @(783.99, 0.065, 0.01, 0.19, 0.8, 0.007, 0.015),
        @(698.46, 0.105, 0.015, 0.18, 0.6, 0.012, 0.023),
        @(659.25, 0.18, 0.025, 0.16, 0.4, 0.018, 0.04),
        @(523.25, 0.36, 0, 0.14, 0.25, 0.025, 0.1)
    )}
    Neutral = @{Label='Neutra'; Notes=@(
        @(783.99, 0.12, 0.035, 0.2, 0.6, 0.008, 0.022),
        @(523.25, 0.23, 0, 0.2, 0.6, 0.008, 0.045)
    )}
    Happy = @{Label='Contenta'; Notes=@(
        @(523.25, 0.075, 0.025, 0.21, 1, 0.006, 0.018),
        @(659.25, 0.075, 0.025, 0.21, 1, 0.006, 0.018),
        @(783.99, 0.09, 0.025, 0.21, 1, 0.006, 0.02),
        @(1046.5, 0.18, 0, 0.21, 1, 0.008, 0.05)
    )}
    Enthusiastic = @{Label='Entusiasmada'; Notes=@(
        @(523.25, 0.055, 0.025, 0.23, 1.2, 0.004, 0.015),
        @(783.99, 0.055, 0.025, 0.23, 1.2, 0.004, 0.015),
        @(1046.5, 0.075, 0.025, 0.23, 1.2, 0.004, 0.018),
        @(1318.51, 0.08, 0.035, 0.23, 1.2, 0.004, 0.02),
        @(1046.5, 0.19, 0, 0.23, 1.2, 0.006, 0.045)
    )}
    Satisfied = @{Label='Satisfecha'; Notes=@(
        @(783.99, 0.16, 0.025, 0.19, 0.6, 0.01, 0.03),
        @(659.25, 0.19, 0.025, 0.19, 0.6, 0.014, 0.04),
        @(523.25, 0.34, 0, 0.18, 0.5, 0.018, 0.08)
    )}
    Calm = @{Label='Tranquila'; Notes=@(
        @(698.46, 0.23, 0.01, 0.16, 0.3, 0.035, 0.07),
        @(659.25, 0.24, 0.01, 0.15, 0.25, 0.04, 0.08),
        @(523.25, 0.37, 0, 0.14, 0.2, 0.045, 0.11)
    )}
    Sad = @{Label='Triste'; Notes=@(
        @(783.99, 0.19, 0.015, 0.17, 0.4, 0.025, 0.05),
        @(622.25, 0.22, 0.015, 0.16, 0.35, 0.028, 0.065),
        @(587.33, 0.23, 0.015, 0.15, 0.3, 0.03, 0.07),
        @(523.25, 0.32, 0, 0.14, 0.25, 0.035, 0.09)
    )}
    Curious = @{Label='Curiosa'; Notes=@(
        @(523.25, 0.09, 0.045, 0.19, 0.7, 0.008, 0.02),
        @(587.33, 0.095, 0.16, 0.19, 0.7, 0.008, 0.02),
        @(783.99, 0.26, 0, 0.19, 0.7, 0.012, 0.055)
    )}
    Doubtful = @{Label='Dudosa'; Notes=@(
        @(659.25, 0.14, 0.18, 0.18, 0.55, 0.013, 0.04),
        @(659.25, 0.11, 0.1, 0.17, 0.5, 0.015, 0.035),
        @(698.46, 0.19, 0, 0.17, 0.5, 0.018, 0.05)
    )}
    Concerned = @{Label='Preocupada'; Notes=@(
        @(523.25, 0.15, 0.05, 0.19, 0.7, 0.01, 0.025),
        @(554.37, 0.13, 0.035, 0.19, 0.7, 0.009, 0.024),
        @(523.25, 0.11, 0.025, 0.19, 0.7, 0.008, 0.023),
        @(554.37, 0.2, 0, 0.19, 0.7, 0.008, 0.045)
    )}
    Frustrated = @{Label='Frustrada'; Notes=@(
        @(783.99, 0.075, 0.075, 0.22, 1.1, 0.004, 0.012),
        @(783.99, 0.075, 0.045, 0.22, 1.1, 0.004, 0.012),
        @(622.25, 0.1, 0.015, 0.21, 0.9, 0.005, 0.016),
        @(523.25, 0.15, 0, 0.2, 0.8, 0.005, 0.025)
    )}
    Apologetic = @{Label='Disculpa'; Notes=@(
        @(659.25, 0.11, 0.07, 0.15, 0.3, 0.023, 0.04),
        @(587.33, 0.16, 0.025, 0.14, 0.25, 0.03, 0.05),
        @(523.25, 0.28, 0, 0.13, 0.2, 0.035, 0.09)
    )}
    Surprised = @{Label='Sorprendida'; Notes=@(
        @(523.25, 0.07, 0.11, 0.22, 1.1, 0.004, 0.018),
        @(1046.5, 0.12, 0.04, 0.22, 1.1, 0.004, 0.025),
        @(783.99, 0.19, 0, 0.2, 0.9, 0.008, 0.045)
    )}
}
$morse = @{
    A='.-'; B='-...'; C='-.-.'; D='-..'; E='.'; F='..-.'; G='--.';
    H='....'; I='..'; J='.---'; K='-.-'; L='.-..'; M='--'; N='-.';
    O='---'; P='.--.'; Q='--.-'; R='.-.'; S='...'; T='-'; U='..-';
    V='...-'; W='.--'; X='-..-'; Y='-.--'; Z='--..'
}
function Play-RobotPhrase([string]$Message, $Ending) {
    $events = [Collections.Generic.List[object]]::new()
    $cursor = 0.0
    if (-not $EndingOnly) {
        # Callsign: pip direction (same, up, down) and rhythm (apart or tied); see docs/dictionary.md.
        $pips = @{Common=@(1046.5, 1046.5, 0.14); '1'=@(1046.5, 1567.98, 0.14); '2'=@(1567.98, 1046.5, 0.14); '3'=@(1046.5, 1567.98, 0.07); '4'=@(1567.98, 1046.5, 0.07)}[$Callsign]
        $events.Add(@{Start=0.0; Length=0.06; Frequency=$pips[0]; Gain=.20; Bright=.7; Attack=.006; Release=.018})
        $events.Add(@{Start=$pips[2]; Length=0.06; Frequency=$pips[1]; Gain=.20; Bright=.7; Attack=.006; Release=.018})
        $cursor = 0.42
        # Compensate for the later overall timing scale: effective dot stays in ms.
        $unit = ($MorseUnitMs / 1000.0) * $Speed
        $letterIndex = 0
        foreach ($letter in $Message.ToCharArray()) {
            $frequency = 659.25
            if ($Articulation -ne 'Plain') {
                # E5, G5, B5: one stable pitch per letter, independent of Morse rhythm.
                $frequency = @(659.25, 783.99, 987.77)[$letterIndex]
            }
            foreach ($symbol in $morse[[string]$letter].ToCharArray()) {
                $length = $unit
                if ($symbol -eq '-') { $length = 3 * $unit }
                $gain = .20; $brightness = .7; $attack = .006; $release = .018
                $shaped = $Articulation -eq 'Expressive'
                if ($shaped) {
                    $gain = .18 + (.02 * $letterIndex)
                    $brightness = .85
                    $attack = .004
                    $release = .022
                }
                $events.Add(@{Start=$cursor; Length=$length; Frequency=$frequency; Gain=$gain; Bright=$brightness; Attack=$attack; Release=$release; Shaped=$shaped})
                $cursor += $length + $unit
            }
            $cursor += 2 * $unit
            $letterIndex++
        }
        # Keep a distinct 180 ms boundary before the emotional ending.
        $cursor += (0.18 * $Speed) - (3 * $unit)
    }
    foreach ($note in $Ending.Notes) {
        $events.Add(@{Start=$cursor; Frequency=$note[0]; Length=$note[1]; Gain=$note[3]; Bright=$note[4]; Attack=$note[5]; Release=$note[6]})
        $cursor += $note[1] + $note[2]
    }
    # Change timing only, preserving pitch and each ending's relative rhythm.
    foreach ($event in $events) {
        $event.Start /= $Speed
        $event.Length /= $Speed
        $event.Attack /= $Speed
        $event.Release /= $Speed
    }
    $duration = ($cursor + 0.08) / $Speed
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
        $start = [int][Math]::Floor($event.Start * $rate)
        $length = [int][Math]::Floor($event.Length * $rate)
        for ($j = 0; $j -lt $length; $j++) {
            $age = $j / [double]$rate
            $envelope = [Math]::Min(1.0, $age / $event.Attack) * [Math]::Min(1.0, ($event.Length - $age) / $event.Release)
            if ($event.Shaped) {
                # A small plucked accent settles to a sustain, without shortening the mark.
                $envelope *= .72 + .28 * [Math]::Exp(-$age / .025)
            }
            $phase = 2 * [Math]::PI * $event.Frequency * $age
            switch ($Timbre) {
                'Classic' {
                    $voice = [Math]::Sin($phase) + $event.Bright * (0.22 * [Math]::Sin(2 * $phase) + 0.08 * [Math]::Sin(3 * $phase))
                }
                'Digital' {
                    # FM creates a bright electronic attack that softens during each note.
                    $modulation = 1.7 * $event.Bright * [Math]::Exp(-$age / 0.12)
                    $voice = 0.82 * [Math]::Sin($phase + $modulation * [Math]::Sin(2 * $phase)) + 0.18 * [Math]::Sin(1.004 * $phase)
                }
                'Crystal' {
                    # Slightly inharmonic partials give a compact bell/computer chime.
                    $voice = 0.82 * [Math]::Sin($phase) + $event.Bright * (0.36 * [Math]::Sin(2.01 * $phase) * [Math]::Exp(-10 * $age) + 0.20 * [Math]::Sin(3.98 * $phase) * [Math]::Exp(-18 * $age))
                }
            }
            $samples[$start + $j] += $event.Gain * $envelope * $voice
        }
    }
    foreach ($sample in $samples) {
        if ([Math]::Abs($sample) -gt 0.99) { throw 'Clipped synthesized sample.' }
        $writer.Write([int16]($sample * 32767))
    }
    $writer.Flush()
    $stream.Position = 0
    if ($OutFile) {
        # Explicit export for comparisons; normal playback stays in memory.
        [IO.File]::WriteAllBytes($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutFile), $stream.ToArray())
    }
    $player = [Media.SoundPlayer]::new($stream)
    try {
        $player.Load()
        if (-not $ValidateOnly -and -not $OutFile) { $player.PlaySync() }
    } finally { $player.Dispose(); $writer.Dispose(); $stream.Dispose() }
}
foreach ($key in $profiles.Keys) {
    if ($Mood -ne 'All' -and $key -ne $Mood) { continue }
    $selected = $profiles[$key]
    foreach ($take in 1..$Repeat) {
        Write-Output ($Word + ': ' + $selected.Label + ' (' + $take + '/' + $Repeat + ')')
        Play-RobotPhrase $Word $selected
        if (-not $ValidateOnly -and -not $OutFile) { Start-Sleep -Milliseconds $PauseMs }
    }
}
