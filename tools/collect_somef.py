#!/usr/bin/env python3
"""Run SoMEF while preserving its raw output for LLM interpretation.

This helper intentionally does not parse, summarize, truncate, or rewrite the
SoMEF JSON output. It runs the SoMEF command, leaves the raw output exactly
where SoMEF wrote it, and records a small manifest with command metadata and
hashes so the extractor can inspect the raw file directly.
"""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import os
import pathlib
import shutil
import subprocess
import sys
from typing import Any


def sha256_file(path: pathlib.Path) -> str | None:
    if not path.exists():
        return None

    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def file_size(path: pathlib.Path) -> int | None:
    if not path.exists():
        return None
    return path.stat().st_size


def write_text(path: pathlib.Path, text: str) -> None:
    path.write_text(text, encoding="utf-8")


def build_manifest(
    *,
    command: list[str],
    returncode: int | None,
    raw_output_path: pathlib.Path,
    stdout_path: pathlib.Path,
    stderr_path: pathlib.Path,
    started_at: str,
    finished_at: str,
    error: str | None = None,
) -> dict[str, Any]:
    return {
        "tool": "collect_somef.py",
        "purpose": "Run SoMEF and preserve raw output for LLM interpretation",
        "raw_output_is_unmodified": True,
        "parses_somef_fields": False,
        "truncates_somef_output": False,
        "started_at_utc": started_at,
        "finished_at_utc": finished_at,
        "command": command,
        "returncode": returncode,
        "error": error,
        "raw_output_path": str(raw_output_path),
        "raw_output_bytes": file_size(raw_output_path),
        "raw_output_sha256": sha256_file(raw_output_path),
        "stdout_path": str(stdout_path),
        "stdout_bytes": file_size(stdout_path),
        "stdout_sha256": sha256_file(stdout_path),
        "stderr_path": str(stderr_path),
        "stderr_bytes": file_size(stderr_path),
        "stderr_sha256": sha256_file(stderr_path),
    }


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Run `somef describe` and preserve the raw SoMEF output exactly as "
            "SoMEF writes it."
        )
    )
    parser.add_argument("--repo-url", required=True, help="Repository URL to pass to SoMEF.")
    parser.add_argument(
        "--output-dir",
        required=True,
        help="Directory where somef_output.json and the manifest should be written.",
    )
    parser.add_argument(
        "--threshold",
        default="0.7",
        help="SoMEF confidence threshold passed to `somef describe -t`.",
    )
    parser.add_argument(
        "--basename",
        default="somef_output",
        help="Base name for output files. Defaults to somef_output.",
    )

    args = parser.parse_args()
    output_dir = pathlib.Path(args.output_dir).expanduser().resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    raw_output_path = output_dir / f"{args.basename}.json"
    manifest_path = output_dir / f"{args.basename}_manifest.json"
    stdout_path = output_dir / f"{args.basename}.stdout.txt"
    stderr_path = output_dir / f"{args.basename}.stderr.txt"

    command = [
        "somef",
        "describe",
        "-t",
        args.threshold,
        "-r",
        args.repo_url,
        "-o",
        str(raw_output_path),
    ]

    started_at = dt.datetime.now(dt.timezone.utc).isoformat()
    returncode: int | None = None
    error: str | None = None

    try:
        if shutil.which("somef") is None:
            raise FileNotFoundError("Could not find `somef` on PATH.")

        result = subprocess.run(command, capture_output=True, text=True, check=False)
        returncode = result.returncode
        write_text(stdout_path, result.stdout)
        write_text(stderr_path, result.stderr)
    except Exception as exc:  # noqa: BLE001 - preserve failure details in manifest.
        error = f"{type(exc).__name__}: {exc}"
        write_text(stdout_path, "")
        write_text(stderr_path, error + os.linesep)
        returncode = 127 if isinstance(exc, FileNotFoundError) else 1

    finished_at = dt.datetime.now(dt.timezone.utc).isoformat()
    manifest = build_manifest(
        command=command,
        returncode=returncode,
        raw_output_path=raw_output_path,
        stdout_path=stdout_path,
        stderr_path=stderr_path,
        started_at=started_at,
        finished_at=finished_at,
        error=error,
    )
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")

    print(json.dumps({"manifest_path": str(manifest_path), **manifest}, indent=2))
    return 0 if returncode == 0 else returncode


if __name__ == "__main__":
    sys.exit(main())
