#!/usr/bin/env bash

set -eExuo pipefail

if ! command -v "pkill" >/dev/null 2>&1; then
    printf "error: pkill not installed\n"
    exit 1
fi

python3 -V

ASCIINEMA_CONFIG_HOME="$(
    mktemp -d 2>/dev/null || mktemp -d -t xcii-config-home
)"

export ASCIINEMA_CONFIG_HOME

TMP_DATA_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t xcii-data-dir)"

trap 'rm -rf ${ASCIINEMA_CONFIG_HOME} ${TMP_DATA_DIR}' EXIT

xcii() {
    python3 -m xcii "${@}"
}

## test help message

xcii -h

## test version command

xcii --version

## test auth command

xcii auth

## test play command

# asciicast v1
xcii play -s 5 tests/demo.json
xcii play -s 5 -i 0.2 tests/demo.json
# shellcheck disable=SC2002
cat tests/demo.json | xcii play -s 5 -

# asciicast v2
xcii play -s 5 tests/demo.cast
xcii play -s 5 -i 0.2 tests/demo.cast
# shellcheck disable=SC2002
cat tests/demo.cast | xcii play -s 5 -

## test cat command

# asciicast v1
xcii cat tests/demo.json
# shellcheck disable=SC2002
cat tests/demo.json | xcii cat -

# asciicast v2
xcii cat tests/demo.cast
# shellcheck disable=SC2002
cat tests/demo.cast | xcii cat -

## test rec command

# normal program
xcii rec -c 'bash -c "echo t3st; sleep 2; echo ok"' "${TMP_DATA_DIR}/1a.cast"
grep '"o",' "${TMP_DATA_DIR}/1a.cast"

# very quickly exiting program
xcii rec -c whoami "${TMP_DATA_DIR}/1b.cast"
grep '"o",' "${TMP_DATA_DIR}/1b.cast"

# signal handling
bash -c "sleep 1; pkill -28 -n -f 'm xcii'" &
xcii rec -c 'bash -c "echo t3st; sleep 2; echo ok"' "${TMP_DATA_DIR}/2.cast"

bash -c "sleep 1; pkill -n -f 'bash -c echo t3st'" &
xcii rec -c 'bash -c "echo t3st; sleep 2; echo ok"' "${TMP_DATA_DIR}/3.cast"

bash -c "sleep 1; pkill -9 -n -f 'bash -c echo t3st'" &
xcii rec -c 'bash -c "echo t3st; sleep 2; echo ok"' "${TMP_DATA_DIR}/4.cast"

# with stdin recording
echo "ls" | xcii rec --stdin -c 'bash -c "sleep 1"' "${TMP_DATA_DIR}/5.cast"
cat "${TMP_DATA_DIR}/5.cast"
grep '"i", "ls\\n"' "${TMP_DATA_DIR}/5.cast"
grep '"o",' "${TMP_DATA_DIR}/5.cast"

# raw output recording
xcii rec --raw -c 'bash -c "echo t3st; sleep 1; echo ok"' "${TMP_DATA_DIR}/6.raw"

# appending to existing recording
xcii rec -c 'echo allright!; sleep 0.1' "${TMP_DATA_DIR}/7.cast"
xcii rec --append -c uptime "${TMP_DATA_DIR}/7.cast"
