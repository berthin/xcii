# xcii

[![Build Status](https://github.com/xcii/xcii/actions/workflows/xcii.yml/badge.svg)](https://github.com/xcii/xcii/actions/workflows/xcii.yml)
[![PyPI](https://img.shields.io/pypi/v/xcii.svg)](https://pypi.org/project/xcii/)
[![license](http://img.shields.io/badge/license-GNU-blue.svg)](https://raw.githubusercontent.com/xcii/xcii/master/LICENSE)

Terminal session recorder and the best companion of
[xcii.org](https://xcii.org).

[![demo](https://xcii.org/a/335480.svg)](https://xcii.org/a/335480?autoplay=1)

## Quick intro

xcii lets you easily record terminal sessions and replay
them in a terminal as well as in a web browser.

Install latest version ([other installation options](#installation))
using [pipx](https://pypa.github.io/pipx/) (if you have it):

```sh
pipx install xcii
```

If you don't have pipx, install using pip with your preferred Python version:

```sh
python3 -m pip install xcii
```

Record your first session:

```sh
xcii rec first.cast
```

Now replay it with double speed:

```sh
xcii play -s 2 first.cast
```

Or with normal speed but with idle time limited to 2 seconds:

```sh
xcii play -i 2 first.cast
```

You can pass `-i 2` to `xcii rec` as well, to set it permanently on a
recording. Idle time limiting makes the recordings much more interesting to
watch. Try it.

If you want to watch and share it on the web, upload it:

```sh
xcii upload first.cast
```

The above uploads it to [xcii.org](https://xcii.org), which is a
default [xcii-server](https://github.com/xcii/xcii-server)
instance, and prints a secret link you can use to watch your recording in a web
browser.

You can record and upload in one step by omitting the filename:

```sh
xcii rec
```

You'll be asked to confirm the upload when the recording is done. Nothing is
sent anywhere without your consent.

These are the basics, but there's much more you can do. The following sections
cover installation, usage and hosting of the recordings in more detail.

## Installation

### Python package from PyPI

[pypi]: https://pypi.python.org/pypi/xcii

xcii is available on [PyPI] and can be installed with
[pipx](https://pypa.github.io/pipx/) (if you have it) or with pip (Python 3
with setuptools required):

```sh
pipx install xcii
```

Or with pip (using your preferred Python version):

```sh
python3 -m pip install xcii
```

Installing from [PyPI] is the recommended way of installation, which gives you the latest released version.

### Native packages

xcii is included in repositories of most popular package managers on Mac OS
X, Linux and FreeBSD. Look for package named `xcii`. See the
[list of available packages](https://xcii.org/docs/installation).

### Running latest version from source code checkout

If you can't use Python package or native package for your OS is outdated you
can clone the repo and run xcii straight from the checkout.

Clone the repo:

```sh
git clone https://github.com/xcii/xcii.git
cd xcii
```

If you want latest stable version:

```sh
git checkout master
```

If you want current development version:

```sh
git checkout develop
```

Then run it with:

```sh
python3 -m xcii --version
```

### Docker image

xcii Docker image is based on [Ubuntu
20.04](https://releases.ubuntu.com/20.04/) and has the latest version of
xcii recorder pre-installed.

```sh
docker pull docker.io/xcii/xcii
```

When running it don't forget to allocate a pseudo-TTY (`-t`), keep STDIN open
(`-i`) and mount config directory volume (`-v`):

```sh
docker run --rm -it -v "${HOME}/.config/xcii:/root/.config/xcii" docker.io/xcii/xcii rec
```

Container's entrypoint is set to `/usr/local/bin/xcii` so you can run the
container with any arguments you would normally pass to `xcii` binary (see
Usage section for commands and options).

There's not much software installed in this image though. In most cases you may
want to install extra programs before recording. One option is to derive new
image from this one (start your custom Dockerfile with `FROM xcii/xcii`). Another option is to start the container with `/bin/bash`
as the entrypoint, install extra packages and manually start `xcii rec`:

```console
docker run --rm -it -v "${HOME}/.config/xcii:/root/.config/xcii" --entrypoint=/bin/bash docker.io/xcii/xcii rec
root@6689517d99a1:~# apt-get install foobar
root@6689517d99a1:~# xcii rec
```

It is also possible to run the docker container as a non-root user, which has
security benefits. You can specify a user and group id at runtime to give the
application permission similar to the calling user on your host.

```sh
docker run --rm -it \
    --env=ASCIINEMA_CONFIG_HOME="/run/user/$(id -u)/.config/xcii" \
    --user="$(id -u):$(id -g)" \
    --volume="${HOME}/.config/xcii:/run/user/$(id -u)/.config/xcii:rw" \
    --volume="${PWD}:/data:rw" \
    --workdir='/data' \
    docker.io/xcii/xcii rec
```

## Usage

xcii is composed of multiple commands, similar to `git`, `apt-get` or
`brew`.

When you run `xcii` with no arguments help message is displayed, listing
all available commands with their options.

### `rec [filename]`

**Record terminal session.**

By running `xcii rec [filename]` you start a new recording session. The
command (process) that is recorded can be specified with `-c` option (see
below), and defaults to `$SHELL` which is what you want in most cases.

You can temporarily pause the capture of your terminal by pressing
<kbd>Ctrl+\\</kbd>.  This is useful when you want to execute some commands during
the recording session that should not be captured (e.g. pasting secrets). Resume
by pressing <kbd>Ctrl+\\</kbd> again. When pausing desktop notification is
displayed so you're sure the sensitive output won't be captured in the
recording.

Recording finishes when you exit the shell (hit <kbd>Ctrl+D</kbd> or type
`exit`). If the recorded process is not a shell then recording finishes when
the process exits.

If the `filename` argument is omitted then (after asking for confirmation) the
resulting asciicast is uploaded to
[xcii-server](https://github.com/xcii/xcii-server) (by default to
xcii.org), where it can be watched and shared.

If the `filename` argument is given then the resulting recording (called
[asciicast](doc/asciicast-v2.md)) is saved to a local file. It can later be
replayed with `xcii play <filename>` and/or uploaded to xcii server
with `xcii upload <filename>`.

`ASCIINEMA_REC=1` is added to recorded process environment variables. This
can be used by your shell's config file (`.bashrc`, `.zshrc`) to alter the
prompt or play a sound when the shell is being recorded.

Available options:

- `--stdin` - Enable stdin (keyboard) recording (see below)
- `--append` - Append to existing recording
- `--raw` - Save raw STDOUT output, without timing information or other metadata
- `--overwrite` - Overwrite the recording if it already exists
- `-c, --command=<command>` - Specify command to record, defaults to $SHELL
- `-e, --env=<var-names>` - List of environment variables to capture, defaults
  to `SHELL,TERM`
- `-t, --title=<title>` - Specify the title of the asciicast
- `-i, --idle-time-limit=<sec>` - Limit recorded terminal inactivity to max `<sec>` seconds
- `--cols=<n>` - Override terminal columns for recorded process
- `--rows=<n>` - Override terminal rows for recorded process
- `-y, --yes` - Answer "yes" to all prompts (e.g. upload confirmation)
- `-q, --quiet` - Be quiet, suppress all notices/warnings (implies -y)

Stdin recording allows for capturing of all characters typed in by the user in
the currently recorded shell. This may be used by a player (e.g.
[xcii-player](https://github.com/xcii/xcii-player)) to display
pressed keys. Because it's basically key-logging (scoped to a single shell
instance), it's disabled by default, and has to be explicitly enabled via
`--stdin` option.

### `play <filename>`

**Replay recorded asciicast in a terminal.**

This command replays given asciicast (as recorded by `rec` command) directly in
your terminal.

Following keyboard shortcuts are available by default:

- <kbd>Space</kbd> - toggle pause,
- <kbd>.</kbd> - step through a recording a frame at a time (when paused),
- <kbd>Ctrl+C</kbd> - exit.

See "Configuration file" section for information on how to customize the
keyboard shortcuts.

Playing from a local file:

```sh
xcii play /path/to/asciicast.cast
```

Playing from HTTP(S) URL:

```sh
xcii play https://xcii.org/a/22124.cast
xcii play http://example.com/demo.cast
```

Playing from asciicast page URL (requires `<link rel="alternate" type="application/x-asciicast" href="/my/ascii.cast">` in page's HTML):

```sh
xcii play https://xcii.org/a/22124
xcii play http://example.com/blog/post.html
```

Playing from stdin:

```sh
cat /path/to/asciicast.cast | xcii play -
ssh user@host cat asciicast.cast | xcii play -
```

Playing from IPFS:

```sh
xcii play dweb:/ipfs/QmNe7FsYaHc9SaDEAEXbaagAzNw9cH7YbzN4xV7jV1MCzK/ascii.cast
```

Available options:

- `-i, --idle-time-limit=<sec>` - Limit replayed terminal inactivity to max `<sec>` seconds
- `-s, --speed=<factor>` - Playback speed (can be fractional)
- `-l, --loop` - Play in a loop
- `--stream=<stream>` - Select stream to play (see below)
- `--out-fmt=<format>` - Select output format (see below)

By default the output stream (`o`) is played. This is what you want in most
cases.  If you recorded the input stream (`i`) with `xcii rec --stdin` then
you can replay it with `xcii play --stream=i <filename>`.

By default the selected stream is written to stdout in original, raw data form.
This is also what you want in majority of cases. However you can change the
output format to asciicast (newline delimited JSON) with `xcii play
--out-fmt=asciicast <filename>`. This allows delegating actual rendering to
another place (e.g. outside of your terminal) by piping output of `xcii
play` to a tool of your choice.

> For the best playback experience it is recommended to run `xcii play` in
> a terminal of dimensions not smaller than the one used for recording, as
> there's no "transcoding" of control sequences for new terminal size.

### `cat <filename>`

**Print full output of recorded asciicast to a terminal.**

While `xcii play <filename>` replays the recorded session using timing
information saved in the asciicast, `xcii cat <filename>` dumps the full
output (including all escape sequences) to a terminal immediately.

`xcii cat existing.cast >output.txt` gives the same result as recording via
`xcii rec --raw output.txt`.

### `upload <filename>`

**Upload recorded asciicast to xcii.org site.**

This command uploads given asciicast (recorded by `rec` command) to
xcii.org, where it can be watched and shared.

`xcii rec demo.cast` + `xcii play demo.cast` + `xcii upload demo.cast` is a nice combo if you want to review an asciicast before
publishing it on xcii.org.

### `auth`

**Link your install ID with your xcii.org user account.**

If you want to manage your recordings (change title/theme, delete) at
xcii.org you need to link your "install ID" with xcii.org user
account.

This command displays the URL to open in a web browser to do that. You may be
asked to log in first.

Install ID is a random ID ([UUID
v4](https://en.wikipedia.org/wiki/Universally_unique_identifier)) generated
locally when you run xcii for the first time, and saved at
`$HOME/.config/xcii/install-id`. Its purpose is to connect local machine
with uploaded recordings, so they can later be associated with xcii.org
account. This way we decouple uploading from account creation, allowing them to
happen in any order.

> A new install ID is generated on each machine and system user account you use
> xcii on, so in order to keep all recordings under a single xcii.org
> account you need to run `xcii auth` on all of those machines.

> xcii versions prior to 2.0 confusingly referred to install ID as "API
> token".

## Hosting the recordings on the web

As mentioned in the `Usage > rec` section above, if the `filename` argument to
`xcii rec` is omitted then the recorded asciicast is uploaded to
[xcii.org](https://xcii.org). You can watch it there and share it via
secret URL.

If you prefer to host the recordings yourself, you can do so by either:

- recording to a file (`xcii rec demo.cast`), and using [xcii's
  standalone web
  player](https://github.com/xcii/xcii-player#self-hosting-quick-start)
  in your HTML page, or
- setting up your own
  [xcii-server](https://github.com/xcii/xcii-server) instance,
  and [setting API URL
  accordingly](https://github.com/xcii/xcii-server/wiki/Installation-guide#using-xcii-recorder-with-your-instance).

## Configuration file

You can configure xcii by creating config file at
`$HOME/.config/xcii/config`.

Configuration is split into sections (`[api]`, `[record]`, `[play]`). Here's a
list of all available options for each section:

```ini
[api]

; API server URL, default: https://xcii.org
; If you run your own instance of xcii-server then set its address here
; It can also be overriden by setting ASCIINEMA_API_URL environment variable
url = https://xcii.example.com

[record]

; Command to record, default: $SHELL
command = /bin/bash -l

; Enable stdin (keyboard) recording, default: no
stdin = yes

; List of environment variables to capture, default: SHELL,TERM
env = SHELL,TERM,USER

; Limit recorded terminal inactivity to max n seconds, default: off
idle_time_limit = 2

; Answer "yes" to all interactive prompts, default: no
yes = true

; Be quiet, suppress all notices/warnings, default: no
quiet = true

; Define hotkey for pausing recording (suspending capture of output),
; default: C-\ (control + backslash)
pause_key = C-p

; Define hotkey prefix key - when defined other recording hotkeys must
; be preceeded by it, default: no prefix
prefix_key = C-a

[play]

; Playback speed (can be fractional), default: 1
speed = 2

; Limit replayed terminal inactivity to max n seconds, default: off
idle_time_limit = 1

; Define hotkey for pausing/resuming playback,
; default: space
pause_key = p

; Define hotkey for stepping through playback, a frame at a time,
; default: .
step_key = ]

[notifications]
; Desktop notifications are displayed on certain occasions, e.g. when
; pausing/resuming the capture of terminal with C-\ keyboard shortcut.

; Should desktop notifications be enabled, default: yes
enabled = no

; Custom notification command
; xcii automatically detects available desktop notification system
; (notify-send on GNU/Linux, osacript/terminal-notifier on macOS). Custom
; command can be used if needed.
; When invoked, environment variable $TEXT contains notification text, while
; $ICON_PATH contains path to the xcii logo image.
command = tmux display-message "$TEXT"
```

A very minimal config file could look like that:

```ini
[record]
idle_time_limit = 2
```

Config directory location can be changed by setting `$ASCIINEMA_CONFIG_HOME`
environment variable.

If `$XDG_CONFIG_HOME` is set on Linux then xcii uses
`$XDG_CONFIG_HOME/xcii` instead of `$HOME/.config/xcii`.

> xcii versions prior to 1.1 used `$HOME/.xcii`. If you have it
> there you should `mv $HOME/.xcii $HOME/.config/xcii`.

## Contributing

If you want to contribute to this project check out
[Contributing](https://xcii.org/contributing) page.

## Authors

Developed with passion by [Marcin Kulik](http://ku1ik.com) and great open
source [contributors](https://github.com/xcii/xcii/contributors).

## License

Copyright &copy; 2011–2021 Marcin Kulik.

All code is licensed under the GPL, v3 or later. See [LICENSE](./LICENSE) file
for details.
