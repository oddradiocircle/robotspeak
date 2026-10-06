#!/usr/bin/env perl
# RobotSpeak engine for macOS and Linux. It mirrors scripts/robot-voice.ps1;
# tests/parity.sh checks that both engines produce the same PCM.
use strict;
use warnings;
use File::Temp qw(tempfile);
use POSIX qw(floor);

$| = 1;
my $PI = 4 * atan2(1, 1);
my @order = qw(Ready Relieved Neutral Happy Enthusiastic Satisfied Calm Sad Curious Doubtful Concerned Frustrated Apologetic Surprised);
# Frequency, length, gap, gain, brightness, attack, release.
my %profiles = (
    Ready => ['Lista para usar', [
        [783.99, 0.09, 0.035, 0.20, 0.7, 0.006, 0.022],
        [1046.50, 0.20, 0, 0.20, 0.6, 0.008, 0.050],
    ]],
    Relieved => ['Aliviada', [
        [783.99, 0.065, 0.01, 0.19, 0.8, 0.007, 0.015],
        [698.46, 0.105, 0.015, 0.18, 0.6, 0.012, 0.023],
        [659.25, 0.18, 0.025, 0.16, 0.4, 0.018, 0.04],
        [523.25, 0.36, 0, 0.14, 0.25, 0.025, 0.1],
    ]],
    Neutral => ['Neutra', [
        [783.99, 0.12, 0.035, 0.2, 0.6, 0.008, 0.022],
        [523.25, 0.23, 0, 0.2, 0.6, 0.008, 0.045],
    ]],
    Happy => ['Contenta', [
        [523.25, 0.075, 0.025, 0.21, 1, 0.006, 0.018],
        [659.25, 0.075, 0.025, 0.21, 1, 0.006, 0.018],
        [783.99, 0.09, 0.025, 0.21, 1, 0.006, 0.02],
        [1046.5, 0.18, 0, 0.21, 1, 0.008, 0.05],
    ]],
    Enthusiastic => ['Entusiasmada', [
        [523.25, 0.055, 0.025, 0.23, 1.2, 0.004, 0.015],
        [783.99, 0.055, 0.025, 0.23, 1.2, 0.004, 0.015],
        [1046.5, 0.075, 0.025, 0.23, 1.2, 0.004, 0.018],
        [1318.51, 0.08, 0.035, 0.23, 1.2, 0.004, 0.02],
        [1046.5, 0.19, 0, 0.23, 1.2, 0.006, 0.045],
    ]],
    Satisfied => ['Satisfecha', [
        [783.99, 0.16, 0.025, 0.19, 0.6, 0.01, 0.03],
        [659.25, 0.19, 0.025, 0.19, 0.6, 0.014, 0.04],
        [523.25, 0.34, 0, 0.18, 0.5, 0.018, 0.08],
    ]],
    Calm => ['Tranquila', [
        [698.46, 0.23, 0.01, 0.16, 0.3, 0.035, 0.07],
        [659.25, 0.24, 0.01, 0.15, 0.25, 0.04, 0.08],
        [523.25, 0.37, 0, 0.14, 0.2, 0.045, 0.11],
    ]],
    Sad => ['Triste', [
        [783.99, 0.19, 0.015, 0.17, 0.4, 0.025, 0.05],
        [622.25, 0.22, 0.015, 0.16, 0.35, 0.028, 0.065],
        [587.33, 0.23, 0.015, 0.15, 0.3, 0.03, 0.07],
        [523.25, 0.32, 0, 0.14, 0.25, 0.035, 0.09],
    ]],
    Curious => ['Curiosa', [
        [523.25, 0.09, 0.045, 0.19, 0.7, 0.008, 0.02],
        [587.33, 0.095, 0.16, 0.19, 0.7, 0.008, 0.02],
        [783.99, 0.26, 0, 0.19, 0.7, 0.012, 0.055],
    ]],
    Doubtful => ['Dudosa', [
        [659.25, 0.14, 0.18, 0.18, 0.55, 0.013, 0.04],
        [659.25, 0.11, 0.1, 0.17, 0.5, 0.015, 0.035],
        [698.46, 0.19, 0, 0.17, 0.5, 0.018, 0.05],
    ]],
    Concerned => ['Preocupada', [
        [523.25, 0.15, 0.05, 0.19, 0.7, 0.01, 0.025],
        [554.37, 0.13, 0.035, 0.19, 0.7, 0.009, 0.024],
        [523.25, 0.11, 0.025, 0.19, 0.7, 0.008, 0.023],
        [554.37, 0.2, 0, 0.19, 0.7, 0.008, 0.045],
    ]],
    Frustrated => ['Frustrada', [
        [783.99, 0.075, 0.075, 0.22, 1.1, 0.004, 0.012],
        [783.99, 0.075, 0.045, 0.22, 1.1, 0.004, 0.012],
        [622.25, 0.1, 0.015, 0.21, 0.9, 0.005, 0.016],
        [523.25, 0.15, 0, 0.2, 0.8, 0.005, 0.025],
    ]],
    Apologetic => ['Disculpa', [
        [659.25, 0.11, 0.07, 0.15, 0.3, 0.023, 0.04],
        [587.33, 0.16, 0.025, 0.14, 0.25, 0.03, 0.05],
        [523.25, 0.28, 0, 0.13, 0.2, 0.035, 0.09],
    ]],
    Surprised => ['Sorprendida', [
        [523.25, 0.07, 0.11, 0.22, 1.1, 0.004, 0.018],
        [1046.5, 0.12, 0.04, 0.22, 1.1, 0.004, 0.025],
        [783.99, 0.19, 0, 0.2, 0.9, 0.008, 0.045],
    ]],
);
my %morse = (
    A => '.-', B => '-...', C => '-.-.', D => '-..', E => '.', F => '..-.', G => '--.',
    H => '....', I => '..', J => '.---', K => '-.-', L => '.-..', M => '--', N => '-.',
    O => '---', P => '.--.', Q => '--.-', R => '.-.', S => '...', T => '-', U => '..-',
    V => '...-', W => '.--', X => '-..-', Y => '-.--', Z => '--..',
);
# Callsign: pip direction (same, up, down) and rhythm (apart or tied); see docs/dictionary.md.
my %callsigns = (
    Common => [1046.5, 1046.5, 0.14],
    1 => [1046.5, 1567.98, 0.14],
    2 => [1567.98, 1046.5, 0.14],
    3 => [1046.5, 1567.98, 0.07],
    4 => [1567.98, 1046.5, 0.07],
);

sub fail { print STDERR "robot-voice: $_[0]\n"; exit 1 }

# PowerShell parameters are case-insensitive; keep the canonical spelling.
sub pick {
    my ($name, $value, @allowed) = @_;
    for (@allowed) { return $_ if lc $_ eq lc $value }
    fail("-$name must be one of: @allowed");
}

sub ranged {
    my ($name, $value, $pattern, $min, $max) = @_;
    fail("-$name must be between $min and $max") unless $value =~ $pattern && $value >= $min && $value <= $max;
    return $value + 0;
}

# PowerShell casts round half to even; printf does the same.
sub round_even { return sprintf('%.0f', $_[0]) + 0 }

my %opt = (Word => 'OK', Mood => 'Ready', Speed => 1.2, MorseUnitMs => 50, Timbre => 'Digital',
    Articulation => 'Plain', Callsign => 'Common', Repeat => 1, PauseMs => 1400, OutFile => '');
my %switch = (EndingOnly => 0, ValidateOnly => 0);
while (@ARGV) {
    my $arg = shift @ARGV;
    fail("unexpected argument '$arg'") unless $arg =~ /^-(\w+)$/;
    my $name = $1;
    my ($flag) = grep { lc $_ eq lc $name } keys %switch;
    if ($flag) { $switch{$flag} = 1; next }
    my ($key) = grep { lc $_ eq lc $name } keys %opt;
    fail("unknown option -$name") unless $key;
    fail("missing value for -$key") unless @ARGV;
    $opt{$key} = shift @ARGV;
}
fail('-Word must be 1-3 letters A-Z, other than R') unless $opt{Word} =~ /^[A-Z]{1,3}\z/ && $opt{Word} ne 'R';
$opt{Mood} = pick('Mood', $opt{Mood}, @order, 'All');
$opt{Timbre} = pick('Timbre', $opt{Timbre}, qw(Classic Digital Crystal));
$opt{Articulation} = pick('Articulation', $opt{Articulation}, qw(Plain Melodic Expressive));
$opt{Callsign} = pick('Callsign', $opt{Callsign}, qw(Common 1 2 3 4));
$opt{Speed} = ranged('Speed', $opt{Speed}, qr/^\d+(\.\d+)?\z/, 0.5, 2.0);
$opt{MorseUnitMs} = ranged('MorseUnitMs', $opt{MorseUnitMs}, qr/^\d+\z/, 10, 200);
$opt{Repeat} = ranged('Repeat', $opt{Repeat}, qr/^\d+\z/, 1, 5);
$opt{PauseMs} = ranged('PauseMs', $opt{PauseMs}, qr/^\d+\z/, 0, 10000);
fail('-OutFile requires a single -Mood') if $opt{OutFile} ne '' && $opt{Mood} eq 'All';
my $silent = $switch{ValidateOnly} || $opt{OutFile} ne '';

sub find_player {
    return ['afplay'] if $^O eq 'darwin';
    # paplay first: it works on PulseAudio and on PipeWire's Pulse layer, including WSLg.
    for my $candidate (['paplay'], ['pw-play'], ['aplay', '-q']) {
        for my $dir (split /:/, $ENV{PATH} // '') {
            return $candidate if -x "$dir/$candidate->[0]";
        }
    }
    fail('no audio player found; install paplay (PulseAudio), pw-play (PipeWire) or aplay (ALSA)');
}

sub synthesize {
    my ($message, $notes) = @_;
    my $speed = $opt{Speed};
    my @events;
    my $cursor = 0.0;
    unless ($switch{EndingOnly}) {
        my $pips = $callsigns{$opt{Callsign}};
        push @events, {Start => 0.0, Length => 0.06, Frequency => $pips->[0], Gain => .20, Bright => .7, Attack => .006, Release => .018};
        push @events, {Start => $pips->[2], Length => 0.06, Frequency => $pips->[1], Gain => .20, Bright => .7, Attack => .006, Release => .018};
        $cursor = 0.42;
        # Compensate for the later overall timing scale: effective dot stays in ms.
        my $unit = ($opt{MorseUnitMs} / 1000.0) * $speed;
        my $letter_index = 0;
        for my $letter (split //, $message) {
            my $frequency = 659.25;
            # E5, G5, B5: one stable pitch per letter, independent of Morse rhythm.
            $frequency = (659.25, 783.99, 987.77)[$letter_index] if $opt{Articulation} ne 'Plain';
            for my $symbol (split //, $morse{$letter}) {
                my $length = $symbol eq '-' ? 3 * $unit : $unit;
                my ($gain, $bright, $attack, $release) = (.20, .7, .006, .018);
                my $shaped = $opt{Articulation} eq 'Expressive';
                if ($shaped) {
                    $gain = .18 + (.02 * $letter_index);
                    ($bright, $attack, $release) = (.85, .004, .022);
                }
                push @events, {Start => $cursor, Length => $length, Frequency => $frequency, Gain => $gain,
                    Bright => $bright, Attack => $attack, Release => $release, Shaped => $shaped};
                $cursor += $length + $unit;
            }
            $cursor += 2 * $unit;
            $letter_index++;
        }
        # Keep a distinct 180 ms boundary before the emotional ending.
        $cursor += (0.18 * $speed) - (3 * $unit);
    }
    for my $note (@$notes) {
        push @events, {Start => $cursor, Frequency => $note->[0], Length => $note->[1], Gain => $note->[3],
            Bright => $note->[4], Attack => $note->[5], Release => $note->[6]};
        $cursor += $note->[1] + $note->[2];
    }
    # Change timing only, preserving pitch and each ending's relative rhythm.
    for my $event (@events) {
        $event->{$_} /= $speed for qw(Start Length Attack Release);
    }
    my $rate = 22050;
    my $count = round_even($rate * (($cursor + 0.08) / $speed));
    my @samples = (0.0) x $count;
    for my $event (@events) {
        my $start = floor($event->{Start} * $rate);
        my $length = floor($event->{Length} * $rate);
        for my $j (0 .. $length - 1) {
            my $age = $j / $rate;
            my $envelope = _min(1.0, $age / $event->{Attack}) * _min(1.0, ($event->{Length} - $age) / $event->{Release});
            # A small plucked accent settles to a sustain, without shortening the mark.
            $envelope *= .72 + .28 * exp(-$age / .025) if $event->{Shaped};
            my $phase = 2 * $PI * $event->{Frequency} * $age;
            my $bright = $event->{Bright};
            my $voice;
            if ($opt{Timbre} eq 'Classic') {
                $voice = sin($phase) + $bright * (0.22 * sin(2 * $phase) + 0.08 * sin(3 * $phase));
            } elsif ($opt{Timbre} eq 'Digital') {
                # FM creates a bright electronic attack that softens during each note.
                my $modulation = 1.7 * $bright * exp(-$age / 0.12);
                $voice = 0.82 * sin($phase + $modulation * sin(2 * $phase)) + 0.18 * sin(1.004 * $phase);
            } else {
                # Slightly inharmonic partials give a compact bell/computer chime.
                $voice = 0.82 * sin($phase) + $bright * (0.36 * sin(2.01 * $phase) * exp(-10 * $age) + 0.20 * sin(3.98 * $phase) * exp(-18 * $age));
            }
            fail('event outside the sample buffer') if $start + $j >= $count;
            $samples[$start + $j] += $event->{Gain} * $envelope * $voice;
        }
    }
    my @pcm;
    for my $sample (@samples) {
        fail('Clipped synthesized sample.') if abs($sample) > 0.99;
        push @pcm, round_even($sample * 32767);
    }
    return pack('a4 V a8 V v v V V v v a4 V s<*', 'RIFF', 36 + 2 * $count, 'WAVEfmt ', 16, 1, 1,
        $rate, 2 * $rate, 2, 16, 'data', 2 * $count, @pcm);
}

sub _min { return $_[0] < $_[1] ? $_[0] : $_[1] }

sub write_file {
    my ($path, $bytes) = @_;
    open(my $fh, '>:raw', $path) or fail("cannot write $path: $!");
    print {$fh} $bytes;
    close($fh) or fail("cannot write $path: $!");
}

my $player = $silent ? undef : find_player();
for my $key (@order) {
    next if $opt{Mood} ne 'All' && $key ne $opt{Mood};
    my ($label, $notes) = @{$profiles{$key}};
    for my $take (1 .. $opt{Repeat}) {
        print "$opt{Word}: $label ($take/$opt{Repeat})\n";
        my $wav = synthesize($opt{Word}, $notes);
        if ($opt{OutFile} ne '') {
            # Explicit export for comparisons; normal playback uses a temporary file.
            write_file($opt{OutFile}, $wav);
        } elsif (!$switch{ValidateOnly}) {
            # afplay reads only files; every player gets a WAV that lives only for this playback.
            my ($fh, $path) = tempfile('robotspeak-XXXXXX', SUFFIX => '.wav', TMPDIR => 1, UNLINK => 1);
            binmode $fh;
            print {$fh} $wav;
            close $fh;
            my $status = system(@$player, $path);
            unlink $path;
            fail("playback failed with $player->[0]") if $status != 0;
            select(undef, undef, undef, $opt{PauseMs} / 1000);
        }
    }
}
