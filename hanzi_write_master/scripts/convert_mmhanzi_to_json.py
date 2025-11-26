#!/usr/bin/env python3
"""
Converter for Make Me a Hanzi data files to JSON used by this Flutter app.

This script is intentionally permissive and supports several common variants of
`graphics.txt` and `dictionary.txt` found in the wild. It attempts to extract
for each character:
  - graphics.json: mapping char -> [ [ [x,y], [x,y], ... ],  ... ] (list of strokes)
  - dict.json: mapping char -> {"pinyin": "...", "meaning": "...", "radical": "..."}

Usage:
  python scripts/convert_mmhanzi_to_json.py --graphics path/to/graphics.txt \
      --dict path/to/dictionary.txt --out assets/hanzi

If you omit paths, the script will look for `graphics.txt` and `dictionary.txt`
in the current directory.

Note: The MakeMeAHanzi format varies; if the script fails to parse your files
completely, inspect the printed warnings and adjust the heuristics.
"""

import re
import json
import argparse
from pathlib import Path
from typing import List, Tuple

CJK_RE = re.compile(r'[\x00-\x7F]*([\u4E00-\u9FFF])')
# We'll detect CJK characters using direct Unicode range checks (e.g. '\u4e00'..'\u9fff')
CJK_CHAR_RE = re.compile(r'([\u4E00-\u9FFF])')

NUM_RE = re.compile(r'-?\d+(?:\.\d+)?')
PAIR_RE = re.compile(r'(-?\d+(?:\.\d+)?)[,\s]+(-?\d+(?:\.\d+)?)')
HEX_CODE_RE = re.compile(r'^(?:U\+)?([0-9A-Fa-f]{4,6})$')
PINYIN_RE = re.compile(r"[a-zü:]+[0-5]?", re.IGNORECASE)


def parse_graphics_line(line: str) -> Tuple[str, List[List[List[float]]]]:
    """Try to parse a single line from graphics.txt.

    Returns (char, strokes) or (None, None) if unable to parse.
    Heuristics supported:
    - lines starting with hex code (U+4E2D or 4E2D) followed by stroke groups
    - lines starting with character, then stroke groups
    Stroke groups may be separated by ';' '|' '/' or double spaces.
    Points in a stroke can be 'x,y' pairs or whitespace separated numbers (x y x y ...)
    """
    line = line.strip()
    if not line:
        return None, None

    # if line is JSON-like, try to decode it directly
    if line.startswith('{') or line.startswith('['):
        try:
            obj = json.loads(line)
            # If obj is a dict containing a character and strokes, extract them
            if isinstance(obj, dict):
                # possible keys for the character
                char = None
                for key in ('character', 'char', 'hanzi', 'glyph'):
                    if key in obj:
                        char = obj[key]
                        break
                # sometimes the file uses the codepoint as the key: {"4E2D": [...]}
                if not char and len(obj) == 1:
                    k = next(iter(obj.keys()))
                    if isinstance(k, str) and HEX_CODE_RE.match(k):
                        char = chr(int(k, 16))
                strokes = []
                # strokes may be under different keys or be the direct value
                raw = None
                for k in ('strokes', 'paths', 'shape', 'data'):
                    if k in obj:
                        raw = obj[k]
                        break
                if raw is None:
                    # maybe the dict maps a char/key to stroke list
                    if char is None:
                        # try the first value
                        vals = list(obj.values())
                        if vals:
                            raw = vals[0]
                # normalize raw strokes
                if isinstance(raw, list):
                    for item in raw:
                        if isinstance(item, list) and item and isinstance(item[0], (int, float)):
                            # already a flat list of numbers -> pair them
                            nums = [float(x) for x in item]
                            pts = []
                            for i in range(0, len(nums) - 1, 2):
                                pts.append([nums[i], nums[i + 1]])
                            if pts:
                                strokes.append(pts)
                        elif isinstance(item, list) and item and isinstance(item[0], list):
                            # already list of pairs
                            try:
                                pts = [[float(a), float(b)] for a, b in item]
                                strokes.append(pts)
                            except Exception:
                                pass
                        elif isinstance(item, str):
                            nums = NUM_RE.findall(item)
                            if nums:
                                nums = [float(n) for n in nums]
                                pts = []
                                for i in range(0, len(nums) - 1, 2):
                                    pts.append([nums[i], nums[i + 1]])
                                if pts:
                                    strokes.append(pts)
                elif isinstance(raw, str):
                    nums = NUM_RE.findall(raw)
                    if nums:
                        nums = [float(n) for n in nums]
                        pts = []
                        for i in range(0, len(nums) - 1, 2):
                            pts.append([nums[i], nums[i + 1]])
                        if pts:
                            strokes.append(pts)

                return char, strokes
            # if obj is not a dict, fall through to other heuristics
        except Exception:
            pass

    # split by whitespace; detect first token as codepoint or character
    parts = line.split()
    first = parts[0]

    # If first token is hex code
    mhex = HEX_CODE_RE.match(first)
    char = None
    rest = line[len(first):].strip()
    if mhex:
        try:
            cp = int(mhex.group(1), 16)
            char = chr(cp)
        except Exception:
            char = None
    else:
        # if first token contains a non-ascii char, take it as the character
        # else try to find the first CJK character in the line
        for ch in line:
            if '\u4e00' <= ch <= '\u9fff':
                char = ch
                break

    if not char:
        # give up for this line
        return None, None

    # Now, extract stroke groups from the rest of the line
    # heuristics: look for separators ; | / or groups in parenthesis
    groups = re.split(r"[;|/]", rest)
    strokes = []
    for g in groups:
        g = g.strip()
        if not g:
            continue
        # find all pairs x,y
        pairs = PAIR_RE.findall(g)
        if pairs:
            pts = [[float(x), float(y)] for x, y in pairs]
            strokes.append(pts)
            continue
        # else try to extract any numbers and pair them
        nums = NUM_RE.findall(g)
        if len(nums) >= 2:
            nums = [float(n) for n in nums]
            pts = []
            for i in range(0, len(nums) - 1, 2):
                pts.append([nums[i], nums[i + 1]])
            if pts:
                strokes.append(pts)
                continue
        # fallback: ignore group
    return char, strokes


def parse_graphics_file(path: Path) -> dict:
    """Parse an entire graphics.txt into a mapping char -> strokes"""
    out = {}
    text = path.read_text(encoding='utf-8')

    # Quick attempt: if file looks like JSON
    s = text.strip()
    if s.startswith('{') or s.startswith('['):
        try:
            obj = json.loads(s)
            # if keys are hex or U+ codes, convert
            newobj = {}
            for k, v in obj.items():
                # key may be 'U+4E2D' or '4E2D' or actual char
                kk = k
                m = HEX_CODE_RE.match(k)
                if m:
                    kk = chr(int(m.group(1), 16))
                newobj[kk] = v
            return newobj
        except Exception:
            pass

    for i, line in enumerate(text.splitlines()):
        char, strokes = parse_graphics_line(line)
        if char and strokes is not None:
            if strokes:
                out[char] = strokes
            else:
                # empty strokes; still put empty list
                out.setdefault(char, [])
    return out


def parse_dict_file(path: Path) -> dict:
    out = {}
    for line in path.read_text(encoding='utf-8').splitlines():
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        # find first Chinese char in line
        ch = None
        for c in line:
            if '\u4e00' <= c <= '\u9fff':
                ch = c
                break
        if not ch:
            # maybe line starts with hex code and then char
            tokens = line.split()
            if tokens:
                m = HEX_CODE_RE.match(tokens[0])
                if m and len(tokens) > 1:
                    # tokens[1] may be char
                    if any('\u4e00' <= c <= '\u9fff' for c in tokens[1]):
                        ch = tokens[1][0]
        if not ch:
            continue
        # attempt to extract pinyin (token containing letters and optional tone number)
        pinyin = None
        meaning = None
        # tokens after the character
        idx = line.find(ch)
        rest = line[idx + 1:].strip()
        tokens = rest.split()
        for t in tokens:
            if PINYIN_RE.fullmatch(t):
                pinyin = t
                break
        if not pinyin and tokens:
            # maybe pinyin is tokens[0]
            pinyin = tokens[0]
        # meaning: everything after pinyin
        if pinyin:
            try:
                pos = rest.index(pinyin)
                meaning = rest[pos + len(pinyin):].strip()
            except ValueError:
                meaning = ' '.join(tokens[1:]) if len(tokens) > 1 else ''
        else:
            meaning = rest
        out[ch] = {'pinyin': pinyin or '', 'meaning': meaning or '', 'radical': ''}
    return out


def main():
    p = argparse.ArgumentParser(description='Convert MakeMeAHanzi graphics/dict to JSON for HanziWriteMaster')
    p.add_argument('--graphics', '-g', type=str, default='graphics.txt', help='Path to graphics.txt')
    p.add_argument('--dict', '-d', type=str, default='dictionary.txt', help='Path to dictionary.txt')
    p.add_argument('--out', '-o', type=str, default='assets/hanzi', help='Output directory for graphics.json and dict.json')
    args = p.parse_args()

    gpath = Path(args.graphics)
    dpath = Path(args.dict)
    outdir = Path(args.out)
    outdir.mkdir(parents=True, exist_ok=True)

    if not gpath.exists():
        print(f"graphics file not found: {gpath}")
    else:
        print(f"Parsing graphics from {gpath}...")
        graphics = parse_graphics_file(gpath)
        print(f"Parsed {len(graphics)} characters from graphics file")
        (outdir / 'graphics.json').write_text(json.dumps(graphics, ensure_ascii=False, indent=2), encoding='utf-8')
        print(f"Wrote {outdir / 'graphics.json'}")

    if not dpath.exists():
        print(f"dictionary file not found: {dpath}")
    else:
        print(f"Parsing dictionary from {dpath}...")
        d = parse_dict_file(dpath)
        print(f"Parsed {len(d)} entries from dictionary file")
        (outdir / 'dict.json').write_text(json.dumps(d, ensure_ascii=False, indent=2), encoding='utf-8')
        print(f"Wrote {outdir / 'dict.json'}")

    print('Done.')

if __name__ == '__main__':
    main()
