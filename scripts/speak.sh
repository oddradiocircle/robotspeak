#!/usr/bin/env bash
# WSL only; native Windows callers use robot-voice.ps1 directly.
set -euo pipefail
robotspeak_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
robotspeak_ps="$(command -v powershell.exe || true)"
if [[ -z "$robotspeak_ps" ]]; then
    robotspeak_ps=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
fi
if [[ ! -x "$robotspeak_ps" ]] || ! command -v wslpath >/dev/null; then
    echo 'RobotSpeak requires WSL Windows interop, or native Windows PowerShell.' >&2
    exit 1
fi
robotspeak_path="$(wslpath -w "$robotspeak_dir/robot-voice.ps1")"
exec "$robotspeak_ps" -NoProfile -NonInteractive -File "$robotspeak_path" "$@"
