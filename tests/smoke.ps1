$ErrorActionPreference = 'Stop'
$voice = Join-Path (Split-Path $PSScriptRoot -Parent) 'scripts/robot-voice.ps1'
& $voice -Word OK -Mood All -ValidateOnly -PauseMs 0
& $voice -Word ERR -Mood Sad -ValidateOnly -PauseMs 0
foreach ($bad in @('ABCD', 'R', 'ok', '')) {
    $rejected = $false
    try { & $voice -Word $bad -ValidateOnly -PauseMs 0 }
    catch { $rejected = $true }
    if (-not $rejected) { throw ('Invalid Word accepted: ' + $bad) }
}
foreach ($badUnit in @(0, 201)) {
    $rejected = $false
    try { & $voice -MorseUnitMs $badUnit -ValidateOnly -PauseMs 0 }
    catch { $rejected = $true }
    if (-not $rejected) { throw 'Invalid Morse duration accepted.' }
}
Write-Output 'PASS: all PCM profiles loaded; invalid inputs rejected.'
