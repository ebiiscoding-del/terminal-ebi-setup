#!/usr/bin/env python3
"""Strip ANSI/VT100 escape sequences from stdin, writing clean plain text to stdout.
Used by the `cc` and `cplast` shell functions so clipboard content is clean,
shareable text rather than raw terminal color/control codes."""

import re
import sys


def strip_ansi(data: str) -> str:
    # CSI sequences: colors, cursor movement, mode-setting (e.g. ESC[38;2;247;30;105m, ESC[?25h)
    data = re.sub(r'\x1b\[[0-9;?]*[a-zA-Z]', '', data)
    # OSC sequences: terminal title-setting etc, terminated by BEL or ESC-backslash
    data = re.sub(r'\x1b\][^\x07\x1b]*(\x07|\x1b\\)', '', data)
    # any remaining lone escape + one character
    data = re.sub(r'\x1b.', '', data)
    return data


if __name__ == "__main__":
    sys.stdout.write(strip_ansi(sys.stdin.read()))
