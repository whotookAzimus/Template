import re
from pathlib import Path

# === Configuration ===
ROOT_DIR = Path(__file__).parent.parent
PACKAGES_DIR = ROOT_DIR / "Packages"
SERVER_PACKAGES_DIR = ROOT_DIR / "ServerPackages"

TARGET_EXTENSIONS = [".lua", ".luau"]
SUPPRESSION_LINE = "--!nocheck\n"
STRIP_DIRECTIVES = {"--!strict", "--!nocheck", "--!nonstrict"}
INDENT = "                                                          "  # 8 spaces

INDENT = " " * 8

def indent_long_strings_and_bin_literals(text: str) -> str:
    # Indent all long string openings like [[, [=[, [==[ but NOT if preceded by --
    def indent_opening(match):
        if match.group(0).startswith("--"):
            # It's a comment, don't indent
            return match.group(0)
        return INDENT + match.group(0)

    # Pattern to find long string openings like [[ or [=[ or [==[
    # Negative lookbehind for -- to exclude comments
    pattern_opening = re.compile(r"(?<!\-\-)(\[(=*)\[)")

    text = pattern_opening.sub(lambda m: INDENT + m.group(1), text)

    # Indent matching closing long brackets: ]] or ]=] or ]==]
    pattern_closing = re.compile(r"(\](=*)\])")

    # For simplicity, indent all closing long brackets by 8 spaces
    text = pattern_closing.sub(lambda m: INDENT + m.group(1), text)

    # Indent lines starting with optional whitespace and a binary literal 0b...
    pattern_bin = re.compile(r"^[ \t]*0b[01]+.*$", re.MULTILINE)
    def indent_bin_line(match):
        line = match.group(0)
        stripped = line.lstrip()
        return INDENT + stripped

    text = pattern_bin.sub(indent_bin_line, text)

    return text

# === File Processor ===
def process_file(file: Path):
    try:
        content = file.read_text(encoding="utf-8")
        lines = content.splitlines(keepends=True)

        # Step 1: Remove directive lines
        lines = [line for line in lines if line.strip() not in STRIP_DIRECTIVES]

        # Step 2: Add --!nocheck at top if missing
        if not lines or lines[0].strip() != "--!nocheck":
            lines.insert(0, SUPPRESSION_LINE)

        # Step 3: Rejoin content for full processing
        cleaned_content = "".join(lines)

        # Step 4: Indent [[ (non-comments) and 0b lines unconditionally
        fixed_content = indent_long_strings_and_bin_literals(cleaned_content)

        # Step 5: Write back if changed
        if content != fixed_content:
            file.write_text(fixed_content, encoding="utf-8")
            print(f"Sanitized: {file.relative_to(ROOT_DIR)}")

    except Exception as e:
        print(f"Error processing {file}: {e}")


# === Directory Walker ===
def clean_directory(directory: Path):
    for file in directory.rglob("*"):
        if file.suffix in TARGET_EXTENSIONS and file.is_file():
            process_file(file)


# === Entry Point ===
if __name__ == "__main__":
    clean_directory(PACKAGES_DIR)
    clean_directory(SERVER_PACKAGES_DIR)
    print("All files cleaned, updated, and formatted.")
