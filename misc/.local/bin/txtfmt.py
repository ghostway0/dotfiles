#!python3

import sys
from typing import List
import argparse
import re
import tempfile
import shutil
import os

def get_input_text(args):
    if not args.inplace and not args.file:
        try:
            return sys.stdin.read()
        except KeyboardInterrupt:
            print("\nCtrl+C detected. Exiting gracefully.", file=sys.stderr)
            sys.exit(0)
    elif args.file:
        try:
            with open(args.file, "r") as f:
                return f.read()
        except (IOError, OSError) as e:
            print(f"Error reading from input file '{args.file}': {e}", file=sys.stderr)
            sys.exit(1)
    return None


def write_output_text(args, formatted_text):
    if args.inplace:
        try:
            with tempfile.NamedTemporaryFile(
                mode="w", delete=False, dir=os.path.dirname(args.file)
            ) as tmp_file:
                tmp_file.write(formatted_text)
                tmp_name = tmp_file.name
            shutil.move(tmp_name, args.file)
        except (IOError, OSError) as e:
            print(
                f"Error writing to file '{args.file}' during in-place modification: {e}",
                file=sys.stderr,
            )
            if os.path.exists(tmp_name):
                os.remove(tmp_name)
            sys.exit(1)
    elif args.output:
        try:
            with open(args.output, "w") as outfile:
                outfile.write(formatted_text)
        except (IOError, OSError) as e:
            print(f"Error writing to output file '{args.output}': {e}", file=sys.stderr)
            sys.exit(1)
    else:
        sys.stdout.write(formatted_text)

def render_line_newline(line: str, width: int) -> List[str]:
    if not line:
        return ['']

    rendered_lines = []
    current_line = ""

    words_with_spaces = re.findall(r"(\s*)(\S*)", line) 

    for spaces, word in words_with_spaces:
        current_length = len(current_line)

        if current_length and current_length + len(word) > width:
            rendered_lines.append(current_line)
            current_line = ""
        else:
            current_line += spaces

        current_line += word

    if current_line:
        rendered_lines.append(current_line)

    return rendered_lines

def render_text(text: str, width: int, render_func) -> str:
    rendered = []

    for line in text.split('\n'):
        rendered += render_func(line, width)

    return "\n".join(rendered)

def main():
    parser = argparse.ArgumentParser(
        description="Format text to a fixed width, preserving newlines and spaces."
    )

    parser.add_argument(
        "-w", "--width", type=int, default=76, help="Output width (default: 76)"
    )
    parser.add_argument(
        "-o", "--output", type=str, help="Output file (default: stdout)"
    )
    parser.add_argument(
        "-i", "--inplace", action="store_true", help="Modify the input file in-place"
    )
    parser.add_argument(
        "file", nargs="?", default=None, help="Input file (required if not using stdin)"
    )

    args = parser.parse_args()

    if args.inplace and args.output:
        parser.error("Cannot use -i/--inplace and -o/--output together.")

    if args.inplace and args.file is None:
        parser.error("-i/--inplace requires a file argument.")

    text = get_input_text(args)

    if text is not None:
        formatted_text = render_text(text, args.width, render_line_newline)
        write_output_text(args, formatted_text)


if __name__ == "__main__":
    main()

