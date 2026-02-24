#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  run-validator.sh --metadata <path/to/hssi_metadata.md>

Environment:
  VALIDATOR_FAIL_ON_ERRORS=1   Exit non-zero when validation_result.json has error_count > 0 (default)
  VALIDATOR_FAIL_ON_ERRORS=0   Never fail based on validation error_count
USAGE
}

if ! command -v codex >/dev/null 2>&1; then
  echo "Error: codex CLI not found in PATH." >&2
  exit 127
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required to parse validator result artifacts." >&2
  exit 127
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"

metadata_path=""
report_path="${repo_root}/artifacts/validation_report.md"
result_path="${repo_root}/artifacts/validation_result.json"
fail_on_errors="${VALIDATOR_FAIL_ON_ERRORS:-1}"

canonicalize_path() {
  local path="${1:?path required}"
  local base_dir

  if [[ "$path" != /* ]]; then
    path="${repo_root}/${path}"
  fi

  base_dir="$(cd "$(dirname "$path")" 2>/dev/null && pwd)" || return 1
  printf '%s/%s\n' "$base_dir" "$(basename "$path")"
}

while (($# > 0)); do
  case "$1" in
    --metadata)
      metadata_path="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument '$1'" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ -z "$metadata_path" ]]; then
  echo "Error: --metadata is required." >&2
  usage
  exit 2
fi
if [[ ! -f "$metadata_path" ]]; then
  echo "Error: metadata file not found: $metadata_path" >&2
  exit 2
fi

mkdir -p "${repo_root}/artifacts"
rm -f "$result_path"

tmp_prompt="$(mktemp)"
trap 'rm -f "$tmp_prompt"' EXIT

cat "${repo_root}/prompts/validator.md" > "$tmp_prompt"
{
  echo
  echo "## Runtime Inputs"
  echo "- Metadata path: ${metadata_path}"
  echo "- Report output path: ${report_path}"
  echo "- Validation result output path: ${result_path}"
} >> "$tmp_prompt"

codex exec - < "$tmp_prompt"

if [[ ! -f "$report_path" ]]; then
  echo "Error: validator did not produce report at ${report_path}" >&2
  exit 3
fi

if [[ ! -f "$result_path" ]]; then
  echo "Error: validator did not produce result artifact at ${result_path}" >&2
  exit 3
fi

if ! jq -e '
  type == "object" and
  (.status | type == "string") and
  (.error_count | type == "number" and . >= 0 and floor == .) and
  (.warning_count | type == "number" and . >= 0 and floor == .) and
  (.suggestion_count | type == "number" and . >= 0 and floor == .) and
  (.verdict | type == "string") and
  (.report_path | type == "string")
' "$result_path" >/dev/null 2>&1; then
  echo "Error: validator result artifact has invalid schema: ${result_path}" >&2
  exit 3
fi

status="$(jq -r '.status' "$result_path")"
error_count="$(jq -r '.error_count' "$result_path")"
warning_count="$(jq -r '.warning_count' "$result_path")"
suggestion_count="$(jq -r '.suggestion_count' "$result_path")"
verdict="$(jq -r '.verdict' "$result_path")"
reported_report_path="$(jq -r '.report_path' "$result_path")"

if [[ "$status" != "ok" && "$status" != "error" ]]; then
  echo "Error: validator result has unknown status '${status}'." >&2
  exit 3
fi
if [[ "$verdict" != "PASS" && "$verdict" != "NEEDS REVISION" ]]; then
  echo "Error: validator result has unknown verdict '${verdict}'." >&2
  exit 3
fi
if [[ -z "$reported_report_path" || "$reported_report_path" == "null" ]]; then
  echo "Error: validator result has empty report_path." >&2
  exit 3
fi

expected_report_path_canon="$(canonicalize_path "$report_path")" || {
  echo "Error: could not normalize expected report path '${report_path}'." >&2
  exit 3
}
reported_report_path_canon="$(canonicalize_path "$reported_report_path")" || {
  echo "Error: could not normalize reported report path '${reported_report_path}'." >&2
  exit 3
}

if [[ "$reported_report_path_canon" != "$expected_report_path_canon" ]]; then
  echo "Error: validator result report_path mismatch." >&2
  echo "Expected: ${expected_report_path_canon}" >&2
  echo "Reported: ${reported_report_path_canon}" >&2
  exit 3
fi

if [[ "$error_count" -eq 0 && "$verdict" != "PASS" ]]; then
  echo "Error: verdict mismatch; error_count=0 requires verdict=PASS." >&2
  exit 3
fi
if [[ "$error_count" -gt 0 && "$verdict" != "NEEDS REVISION" ]]; then
  echo "Error: verdict mismatch; error_count>0 requires verdict=NEEDS REVISION." >&2
  exit 3
fi

echo "Validator completed: ${report_path} (ERRORS=${error_count} WARNINGS=${warning_count} SUGGESTIONS=${suggestion_count} VERDICT=${verdict})"

if [[ "$status" == "error" ]]; then
  echo "Validation pass returned status=error; check ${result_path} and ${report_path}." >&2
  exit 4
fi

if [[ "$fail_on_errors" == "1" && "$error_count" -gt 0 ]]; then
  echo "Validation failed due to ERROR count > 0 (set VALIDATOR_FAIL_ON_ERRORS=0 to override)." >&2
  exit 4
fi
