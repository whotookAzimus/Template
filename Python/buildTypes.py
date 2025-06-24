import re
import os
import sys
import time
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import PatternMatchingEventHandler

# --- Configuration ---
ROOT_DIR    = Path(__file__).parent.parent
TYPES_DIR   = ROOT_DIR / "src/shared/Types"
OUTPUT_FILE = TYPES_DIR / "init.luau"

# Allow letters, digits, underscore, <, >, and dot in captured type names
EXPORT_TYPE_REGEX = re.compile(r"export\s+type\s+([A-Za-z0-9_<>\.]+)\s*=")

def buildTypes():
    # --- Gather modules and their exported type names ---
    modules = []
    for luau_file in TYPES_DIR.glob("*.luau"):
        if luau_file.name == "init.luau":
            continue

        content = luau_file.read_text(encoding="utf-8")
        exported_types = []
        for line in content.splitlines():
            line = line.strip()
            if "export type" not in line:
                continue
            if match := EXPORT_TYPE_REGEX.search(line):
                # preserve generics and dots exactly as written
                type_name = match.group(1)
                exported_types.append(type_name)
        
        if exported_types:
            modules.append((luau_file.stem, exported_types))

    # --- Build the output lines ---
    lines = []
    lines.append("--!strict")
    lines.append("-- AUTO-GENERATED; DO NOT EDIT")
    lines.append("")

    # Require only modules that export types
    for module_name, type_names in modules:
        lines.append(f"local {module_name} = require(script.{module_name})")
    if modules:
        lines.append("")

    # Export each type, including any generics
    for module_name, type_names in modules:
        for type_name in type_names:
            lines.append(f"export type {type_name} = {module_name}.{type_name}")
    if modules:
        lines.append("")

    lines.append("return {}")
    lines.append("")  # trailing newline

    # --- Write to file if changed ---
    new_content = "\n".join(lines)
    old_content = OUTPUT_FILE.read_text(encoding="utf-8") if OUTPUT_FILE.exists() else ""
    if new_content != old_content:
        OUTPUT_FILE.write_text(new_content, encoding="utf-8")
        print(f"✅ Updated Types/init.luau")

class LuauChangeHandler(PatternMatchingEventHandler):
    patterns = ["*.luau"]
    
    def on_modified(self, event):
        if Path(event.src_path).name == "init.luau":
            return
        buildTypes()
    
    def on_created(self, event):
        if Path(event.src_path).name == "init.luau":
            return
        buildTypes()
    
    def on_deleted(self, event):
        buildTypes()

if __name__ == "__main__":
    # Initial build
    buildTypes()

    # Set up watcher
    event_handler = LuauChangeHandler()
    observer = Observer()
    observer.schedule(event_handler, str(TYPES_DIR), recursive=False)
    observer.start()
    print(f"Watching src/shared/Types for changes (ignoring init.luau)...")
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
