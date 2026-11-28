# /// script
# requires-python = ">=3.9"
# dependencies = ["tomlkit==0.15.2"]
# ///
"""Merge repository-managed Codex settings into the user's TOML file."""

import os
import stat
import sys
from collections.abc import MutableMapping
from pathlib import Path
from tempfile import NamedTemporaryFile

import tomlkit
from tomlkit.exceptions import ParseError


def merge_settings(current, managed):
    for key, value in managed.items():
        if key in current and isinstance(value, MutableMapping):
            if not isinstance(current[key], MutableMapping):
                raise ValueError(f"Cannot merge a table into existing setting {key!r}")
            merge_settings(current[key], value)
        else:
            current[key] = value


def sync_config(source, target):
    managed = tomlkit.parse(source.read_bytes().decode("utf-8"))
    target = target.resolve()  # Keep user-created symlinks pointing to the same file.
    try:
        original = target.read_bytes()
    except FileNotFoundError:
        original = None

    current = tomlkit.parse((original or b"").decode("utf-8"))
    merge_settings(current, managed)
    updated = tomlkit.dumps(current).encode("utf-8")
    if updated == original:
        return

    target.parent.mkdir(parents=True, exist_ok=True)
    with NamedTemporaryFile(dir=target.parent, delete=False) as staged:
        try:
            staged.write(updated)
            staged.flush()
            if original is None:
                os.link(staged.name, target)
            else:
                if target.read_bytes() != original:
                    raise ValueError("Config changed during sync. Run the update again.")
                os.fchmod(staged.fileno(), stat.S_IMODE(target.stat().st_mode))
                os.replace(staged.name, target)
        finally:
            Path(staged.name).unlink(missing_ok=True)


if __name__ == "__main__":
    source, target = map(Path, sys.argv[1:])
    try:
        sync_config(source, target)
    except (OSError, ValueError, ParseError) as error:
        sys.exit(f"Could not sync {source} to {target}: {error}")
