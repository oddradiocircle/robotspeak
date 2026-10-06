#!/usr/bin/env bash
# Unix launcher: WSL plays through Windows PowerShell; macOS and Linux use Perl.
# ROBOTSPEAK_ENGINE=perl forces the Perl engine, also inside WSL.
set -euo pipefail
robotspeak_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ "${ROBOTSPEAK_ENGINE:-}" != perl ]] && command -v wslpath >/dev/null; then
    robotspeak_ps="$(command -v powershell.exe || true)"
    if [[ -z "$robotspeak_ps" ]]; then
        robotspeak_ps=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
    fi
    if [[ -x "$robotspeak_ps" ]]; then
        robotspeak_path="$(wslpath -w "$robotspeak_dir/robot-voice.ps1")"
        robotspeak_args=()
        while (($#)); do
            robotspeak_args+=("$1")
            case "$1" in
                # Windows PowerShell cannot open Linux paths; translate the export target.
                -[Oo][Uu][Tt][Ff][Ii][Ll][Ee])
                    if (($# > 1)); then robotspeak_args+=("$(wslpath -w "$2")"); shift; fi ;;
            esac
            shift
        done
        exec "$robotspeak_ps" -NoProfile -NonInteractive -File "$robotspeak_path" "${robotspeak_args[@]}"
    fi
fi
if ! command -v perl >/dev/null; then
    echo 'RobotSpeak requires Perl on macOS and Linux, or Windows PowerShell through WSL.' >&2
    exit 1
fi
exec perl "$robotspeak_dir/robot-voice.pl" "$@"
