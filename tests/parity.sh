#!/usr/bin/env bash
# WSL only: the PowerShell and Perl engines must produce the same PCM.
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
powershell=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
command -v wslpath >/dev/null && [[ -x "$powershell" ]] || { echo 'parity.sh needs WSL with Windows PowerShell.' >&2; exit 1; }
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cases=(
    '-Word OK -Mood Ready' '-Word OK -Mood Relieved' '-Word OK -Mood Neutral' '-Word OK -Mood Happy'
    '-Word OK -Mood Enthusiastic' '-Word OK -Mood Satisfied' '-Word OK -Mood Calm' '-Word OK -Mood Sad'
    '-Word OK -Mood Curious' '-Word OK -Mood Doubtful' '-Word OK -Mood Concerned' '-Word OK -Mood Frustrated'
    '-Word OK -Mood Apologetic' '-Word OK -Mood Surprised'
    '-Word OK -Mood Ready -Timbre Classic' '-Word OK -Mood Ready -Timbre Crystal'
    '-Word ERR -Mood Sad -Articulation Melodic' '-Word ERR -Mood Sad -Articulation Expressive -Timbre Crystal'
    '-Word K -Mood Curious -Callsign 1' '-Word RCV -Mood Neutral -Callsign 2'
    '-Word ERR -Mood Concerned -Callsign 3' '-Word OK -Mood Satisfied -Callsign 4'
    '-Word OK -Mood Calm -EndingOnly' '-Word XYZ -Mood Happy -Speed 0.8 -MorseUnitMs 70'
)
# One PowerShell process renders every case; starting it per case is slow.
{
    echo "\$ErrorActionPreference = 'Stop'"
    echo "\$voice = '$(wslpath -w "$root/scripts/robot-voice.ps1")'"
    for i in "${!cases[@]}"; do
        echo "& \$voice ${cases[$i]} -OutFile '$(wslpath -w "$work")\\ps-$i.wav' | Out-Null"
    done
} > "$work/render.ps1"
"$powershell" -NoProfile -NonInteractive -File "$(wslpath -w "$work/render.ps1")"
for i in "${!cases[@]}"; do
    # shellcheck disable=SC2086
    perl "$root/scripts/robot-voice.pl" ${cases[$i]} -OutFile "$work/pl-$i.wav" >/dev/null
done
perl - "$work" "${#cases[@]}" <<'PERL'
use strict; use warnings;
my ($work, $total) = @ARGV;
my ($worst, $differing) = (0, 0);
for my $i (0 .. $total - 1) {
    my @wav = map { local $/; open(my $fh, '<:raw', "$work/$_-$i.wav") or die "$_-$i.wav: $!"; scalar <$fh> } qw(ps pl);
    die "case $i: header or length differs\n" if substr($wav[0], 0, 44) ne substr($wav[1], 0, 44) || length $wav[0] != length $wav[1];
    my @a = unpack('s<*', substr($wav[0], 44));
    my @b = unpack('s<*', substr($wav[1], 44));
    for my $n (0 .. $#a) {
        my $d = abs($a[$n] - $b[$n]);
        $differing++ if $d;
        $worst = $d if $d > $worst;
    }
}
# Different math libraries may round the last bit of sin/exp differently.
die "FAIL: samples differ by up to $worst\n" if $worst > 1;
print "PASS: $total cases; $differing samples differ by one step, none by more.\n";
PERL
