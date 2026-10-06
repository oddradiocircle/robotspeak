#!/usr/bin/env bash
# Silent checks for the Perl engine (macOS, Linux and WSL).
set -euo pipefail
voice="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)/scripts/robot-voice.pl"
run() { perl "$voice" "$@" -ValidateOnly -PauseMs 0 >/dev/null; }
run -Word OK -Mood All
run -Word ERR -Mood Sad
for timbre in Classic Digital Crystal; do run -Word OK -Mood Ready -Timbre "$timbre"; done
for articulation in Plain Melodic Expressive; do run -Word OK -Mood Ready -Articulation "$articulation"; done
for callsign in Common 1 2 3 4; do run -Word OK -Mood Satisfied -Callsign "$callsign"; done
# Phrases defined in docs/dictionary.md.
for phrase in 'RCV Neutral' 'OK Satisfied' 'OK Doubtful' 'K Curious' 'K Concerned' 'ERR Apologetic' 'ERR Concerned' 'K Neutral'; do
    read -r word mood <<<"$phrase"
    run -Word "$word" -Mood "$mood"
done
for bad in ABCD R ok ''; do
    if run -Word "$bad" 2>/dev/null; then echo "Invalid Word accepted: $bad" >&2; exit 1; fi
done
for bad_unit in 0 201; do
    if run -MorseUnitMs "$bad_unit" 2>/dev/null; then echo 'Invalid Morse duration accepted.' >&2; exit 1; fi
done
echo 'PASS: all PCM profiles and dictionary phrases synthesized; invalid inputs rejected.'
