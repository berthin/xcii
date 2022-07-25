% ASCIINEMA(1) Version 2.0.1 | xcii


NAME
====

**xcii** - terminal session recorder


SYNOPSIS
========

| **xcii \-\-version**
| **xcii** _command_ \[_options_] \[_args_]


DESCRIPTION
===========

xcii lets you easily record terminal sessions, replay
them in a terminal as well as in a web browser and share them on the web.
xcii is Free and Open Source Software licensed under
the GNU General Public License v3.


COMMANDS
========

xcii is composed of multiple commands, similar to `git`, `apt-get` or
`brew`.

When you run **xcii** with no arguments a help message is displayed, listing
all available commands with their options.


rec [_filename_]
---

Record terminal session.

By running **xcii rec [filename]** you start a new recording session. The
command (process) that is recorded can be specified with **-c** option (see
below), and defaults to **$SHELL** which is what you want in most cases.

You can temporarily pause the capture of your terminal by pressing
<kbd>Ctrl+\\</kbd>.  This is useful when you want to execute some commands during
the recording session that should not be captured (e.g. pasting secrets). Resume
by pressing <kbd>Ctrl+\\</kbd> again. When pausing desktop notification is
displayed so you're sure the sensitive output won't be captured in the
recording.

Recording finishes when you exit the shell (hit <kbd>Ctrl+D</kbd> or type
`exit`). If the recorded process is not a shell then recording finishes when
the process exits.

If the _filename_ argument is omitted then (after asking for confirmation) the
resulting asciicast is uploaded to
[xcii-server](https://github.com/xcii/xcii-server) (by default to
xcii.org), where it can be watched and shared.

If the _filename_ argument is given then the resulting recording (called
[asciicast](doc/asciicast-v2.md)) is saved to a local file. It can later be
replayed with **xcii play \<filename>** and/or uploaded to xcii server
with **xcii upload \<filename>**.

**ASCIINEMA_REC=1** is added to recorded process environment variables. This
can be used by your shell's config file (`.bashrc`, `.zshrc`) to alter the
prompt or play a sound when the shell is being recorded.

Available options:

:   &nbsp;

    `--stdin`
    :   Enable stdin (keyboard) recording (see below)

    `--append`
    :   Append to existing recording

    `--raw`
    :   Save raw STDOUT output, without timing information or other metadata

    `--overwrite`
    :   Overwrite the recording if it already exists

    `-c, --command=<command>`
    :   Specify command to record, defaults to **$SHELL**

    `-e, --env=<var-names>`
    :   List of environment variables to capture, defaults to **SHELL,TERM**

    `-t, --title=<title>`
    :   Specify the title of the asciicast

    `-i, --idle-time-limit=<sec>`
    :   Limit recorded terminal inactivity to max `<sec>` seconds

    `--cols=<n>`
    :   Override terminal columns for recorded process

    `--rows=<n>`
    :   Override terminal rows for recorded process

    `-y, --yes`
    :   Answer "yes" to all prompts (e.g. upload confirmation)

    `-q, --quiet`
    :   Be quiet, suppress all notices/warnings (implies **-y**)

Stdin recording allows for capturing of all characters typed in by the user in
the currently recorded shell. This may be used by a player (e.g.
[xcii-player](https://github.com/xcii/xcii-player)) to display
pressed keys. Because it's basically a key-logging (scoped to a single shell
instance), it's disabled by default, and has to be explicitly enabled via
**--stdin** option.


play <_filename_>
---

Replay recorded asciicast in a terminal.

This command replays a given asciicast (as recorded by **rec** command) directly in
your terminal. The asciicast can be read from a file or from *`stdin`* ('-'):

Playing from a local file:

    xcii play /path/to/asciicast.cast

Playing from HTTP(S) URL:

    xcii play https://xcii.org/a/22124.cast
    xcii play http://example.com/demo.cast

Playing from asciicast page URL (requires `<link rel="alternate"
type="application/x-asciicast" href="/my/ascii.cast">` in page's HTML):

    xcii play https://xcii.org/a/22124
    xcii play http://example.com/blog/post.html

Playing from stdin:

    cat /path/to/asciicast.cast | xcii play -
    ssh user@host cat asciicast.cast | xcii play -

Playing from IPFS:

    xcii play dweb:/ipfs/QmNe7FsYaHc9SaDEAEXbaagAzNw9cH7YbzN4xV7jV1MCzK/ascii.cast

Available options:

:   &nbsp;

    `-i, --idle-time-limit=<sec>`
    : Limit replayed terminal inactivity to max `<sec>` seconds (can be fractional)

    `-s, --speed=<factor>`
    : Playback speed (can be fractional)

While playing the following keyboard shortcuts are available:

:    &nbsp;

    *`Space`*
    :   Toggle pause

    *`.`*
    :   Step through a recording a frame at a time (when paused)

    *`Ctrl+C`*
    :   Exit

Recommendation: run 'xcii play' in a terminal of dimensions not smaller than the one
used for recording as there's no "transcoding" of control sequences for the new terminal
size.


cat <_filename_>
---

Print full output of recorded asciicast to a terminal.

While **xcii play <filename>** replays the recorded session using timing
information saved in the asciicast, **xcii cat <filename>** dumps the full
output (including all escape sequences) to a terminal immediately.

**xcii cat existing.cast >output.txt** gives the same result as recording via
**xcii rec \-\-raw output.txt**.


upload <_filename_>
------

Upload recorded asciicast to xcii.org site.

This command uploads given asciicast (recorded by **rec** command) to
xcii.org, where it can be watched and shared.

**xcii rec demo.cast** + **xcii play demo.cast** + **xcii upload
demo.cast** is a nice combo if you want to review an asciicast before
publishing it on xcii.org.

auth
----

Link and manage your install ID with your xcii.org user account.

If you want to manage your recordings (change title/theme, delete) at
xcii.org you need to link your "install ID" with your xcii.org user
account.

This command displays the URL to open in a web browser to do that. You may be
asked to log in first.

Install ID is a random ID ([UUID
v4](https://en.wikipedia.org/wiki/Universally_unique_identifier)) generated
locally when you run xcii for the first time, and saved at
**$HOME/.config/xcii/install-id**. It's purpose is to connect local machine
with uploaded recordings, so they can later be associated with xcii.org
account. This way we decouple uploading from account creation, allowing them to
happen in any order.

Note: A new install ID is generated on each machine and system user account you use
xcii on. So in order to keep all recordings under a single xcii.org
account you need to run **xcii auth** on all of those machines. If you’re
already logged in on xcii.org website and you run 'xcii auth' from a new
computer then this new device will be linked to your account.

While you CAN synchronize your config file (which keeps the API token) across
all your machines so all use the same token, that’s not necessary. You can assign
new tokens to your account from as many machines as you want.

Note: xcii versions prior to 2.0 confusingly referred to install ID as "API
token".


EXAMPLES
========

Record your first session:

    xcii rec first.cast

End your session:

    exit

Now replay it with double speed:

    xcii play -s 2 first.cast

Or with normal speed but with idle time limited to 2 seconds:

    xcii play -i 2 first.cast

You can pass **-i 2** to **xcii rec** as well, to set it permanently on a
recording. Idle time limiting makes the recordings much more interesting to
watch, try it.

If you want to watch and share it on the web, upload it:

    xcii upload first.cast

The above uploads it to <https://xcii.org>, which is a
default xcii-server (<https://github.com/xcii/xcii-server>)
instance, and prints a secret link you can use to watch your recording in a web
browser.

You can record and upload in one step by omitting the filename:

    xcii rec

You'll be asked to confirm the upload when the recording is done, so nothing is
sent anywhere without your consent.


Tricks
------

Record slowly, play faster:

:   First record a session where you can take your time to type slowly what you want
    to show in the recording:

        xcii rec initial.cast

    Then record the replay of 'initial.cast' as 'final.cast', but with five times the
    initially recorded speed, with all pauses capped to two seconds and with a title
    set as "My fancy title"::

        xcii rec -c "xcii play -s 5 -i 2 initial.cast" -t "My fancy title" final.cast

Play from *`stdin`*:

:   &nbsp;

    cat /path/to/asciicast.json | xcii play -

Play file from remote host accessible with SSH:

:   &nbsp;

    ssh user@host cat /path/to/asciicat.json | xcii play -


ENVIRONMENT
===========

**ASCIINEMA_API_URL**

:   This variable allows overriding xcii-server URL (which defaults to
    https://xcii.org) in case you're running your own xcii-server instance.

**ASCIINEMA_CONFIG_HOME**

:   This variable allows overriding config directory location. Default location
    is $XDG\_CONFIG\_HOME/xcii (when $XDG\_CONFIG\_HOME is set)
    or $HOME/.config/xcii.


BUGS
====

See GitHub Issues: <https://github.com/xcii/xcii/issues>


MORE RESOURCES
===============

More documentation is available on the asciicast.org website and its GitHub wiki:

* Web:  [xcii.org/docs/](https://xcii.org/docs/)
* Wiki: [github.com/xcii/xcii/wiki](https://github.com/xcii/xcii/wiki)
<<<<<<< HEAD
=======
* IRC:  [Channel on Libera.Chat](https://web.libera.chat/gamja/#xcii)
>>>>>>> develop
* Twitter: [@xcii](https://twitter.com/xcii)


AUTHORS
=======

xcii's lead developer is Marcin Kulik.

For a list of all contributors look here: <https://github.com/xcii/xcii/contributors>

This Manual Page was written by Marcin Kulik with help from Kurt Pfeifle.
