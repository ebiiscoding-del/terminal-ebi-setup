#!/usr/bin/env python3
"""
coloreza - Colored icons with uniform filenames for eza
https://github.com/ebiiscoding-del/coloreza
License: MIT
"""
import sys
import re

WHITE = '\x1b[38;5;255m'
RESET = '\x1b[0m'

def get_icon_color(filename):
    filename = filename.strip().lower()
    ext_colors = {
        '.js':        '\x1b[38;5;220m',
        '.ts':        '\x1b[38;5;39m',
        '.jsx':       '\x1b[38;5;220m',
        '.tsx':       '\x1b[38;5;39m',
        '.mjs':       '\x1b[38;5;220m',
        '.html':      '\x1b[38;5;208m',
        '.css':       '\x1b[38;5;171m',
        '.scss':      '\x1b[38;5;171m',
        '.sass':      '\x1b[38;5;171m',
        '.less':      '\x1b[38;5;171m',
        '.json':      '\x1b[38;5;196m',
        '.yaml':      '\x1b[38;5;226m',
        '.yml':       '\x1b[38;5;226m',
        '.toml':      '\x1b[38;5;226m',
        '.xml':       '\x1b[38;5;208m',
        '.env':       '\x1b[38;5;196m',
        '.lock':      '\x1b[38;5;242m',
        '.md':        '\x1b[38;5;117m',
        '.txt':       '\x1b[38;5;117m',
        '.pdf':       '\x1b[38;5;196m',
        '.png':       '\x1b[38;5;213m',
        '.jpg':       '\x1b[38;5;213m',
        '.jpeg':      '\x1b[38;5;213m',
        '.svg':       '\x1b[38;5;213m',
        '.gif':       '\x1b[38;5;213m',
        '.ico':       '\x1b[38;5;213m',
        '.sh':        '\x1b[38;5;114m',
        '.zsh':       '\x1b[38;5;114m',
        '.bash':      '\x1b[38;5;114m',
        '.fish':      '\x1b[38;5;114m',
        '.py':        '\x1b[38;5;226m',
        '.zip':       '\x1b[38;5;227m',
        '.tar':       '\x1b[38;5;227m',
        '.gz':        '\x1b[38;5;227m',
        '.rar':       '\x1b[38;5;227m',
        '.gitignore': '\x1b[38;5;242m',
        '.gitconfig': '\x1b[38;5;242m',
    }
    for ext, color in ext_colors.items():
        if filename.endswith(ext):
            return color
    return '\x1b[38;5;141m'  # purple for dirs/unknown

ANSI = re.compile(r'\x1b\[[0-9;]*m')

def process_line(line):
    # Strip all ANSI to get plain text
    plain = ANSI.sub('', line)
    
    # Find icon and filename from plain text
    # Plain looks like: "├──  filename" or " filename" or ". "
    # Icon is first non-tree char, filename follows after space
    tree_chars = set('├└│─ \t.')
    
    icon_pos = -1
    for i, ch in enumerate(plain):
        if ch not in tree_chars:
            icon_pos = i
            break
    
    if icon_pos == -1:
        return line
    
    # Everything after icon + space is filename
    space_pos = plain.find(' ', icon_pos)
    if space_pos == -1:
        return line
    
    filename = plain[space_pos + 1:].strip()
    tree_prefix = plain[:icon_pos]
    icon = plain[icon_pos]
    
    if not filename:
        return line
    
    icon_color = get_icon_color(filename)
    
    # Rebuild: tree (dark grey) + icon (colored) + filename (white)
    tree_ansi = '\x1b[1;90m' + tree_prefix + RESET if tree_prefix.strip() else tree_prefix
    
    return tree_ansi + icon_color + icon + ' ' + RESET + WHITE + filename + RESET

for line in sys.stdin:
    line = line.rstrip('\r\n')
    print(process_line(line))
