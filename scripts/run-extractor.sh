#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  run-extractor.sh --repo <path|url|doi> [--mode extract|extract-submit|extract-submit-local] [--output <path>]

Behavior:
  - Local repo paths are used directly.
  - Repository URLs are cloned/refreshed under repos/<repo-name>/.
  - DOI inputs are resolved by AI to the related code repo, which should be cloned under repos/<repo-name>/.
  - Writes machine-readable result contract to artifacts/extractor_result.json.
  - DOI values with no code repository return status=no_repo_found and a direct remediation message.
USAGE
}

if ! command -v codex >/dev/null 2>&1; then
  echo "Error: codex CLI not found in PATH." >&2
  exit 127
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required to parse extractor result artifacts." >&2
  exit 127
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
source "${script_dir}/lib/repo_input_resolver.sh"

repo_input=""
mode="extract"
output_path=""

while (($# > 0)); do
  case "$1" in
    --repo)
      repo_input="${2:-}"
      shift 2
      ;;
    --mode)
      mode="${2:-}"
      shift 2
      ;;
    --output)
      output_path="${2:-}"
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

if [[ -z "$repo_input" ]]; then
  echo "Error: --repo is required." >&2
  usage
  exit 2
fi

case "$mode" in
  extract|extract-submit|extract-submit-local)
    ;;
  *)
    echo "Error: --mode must be extract, extract-submit, or extract-submit-local." >&2
    exit 2
    ;;
esac

if [[ -n "$output_path" ]]; then
  mkdir -p "$(dirname "$output_path")"
fi

if ! resolve_repo_input "$repo_root" "$repo_input"; then
  exit $?
fi
resolved_repo_input="$REPO_INPUT_RESOLVED"
input_kind="$REPO_INPUT_KIND"
default_metadata_path="$REPO_INPUT_DEFAULT_METADATA_PATH"

if [[ -z "$output_path" && -n "$default_metadata_path" ]]; then
  output_path="$default_metadata_path"
  mkdir -p "$(dirname "$output_path")"
fi

artifacts_dir="${repo_root}/artifacts"
extractor_result_path="${artifacts_dir}/extractor_result.json"
mkdir -p "$artifacts_dir"
rm -f "$extractor_result_path"

tmp_prompt="$(mktemp)"
trap 'rm -f "$tmp_prompt"' EXIT

cat "${repo_root}/prompts/extractor.md" > "$tmp_prompt"
{
  echo
  echo "## Runtime Inputs"
  echo "- Original repository input: ${repo_input}"
  echo "- Repository input kind: ${input_kind}"
  echo "- Repository input for extraction: ${resolved_repo_input}"
  echo "- Default metadata output path: ${default_metadata_path}"
  echo "- Extractor result output path: ${extractor_result_path}"
  if [[ "$REPO_INPUT_CLONED" == "1" ]]; then
    echo "- Clone behavior: repository URL was cloned into ${resolved_repo_input}"
  elif [[ "$input_kind" == "doi" ]]; then
    echo "- DOI behavior: resolve DOI to repository URL, clone under repos/<repo-name>/, then extract."
  fi
  echo "- Requested mode: ${mode}"
  if [[ -n "$output_path" ]]; then
    echo "- Output path: ${output_path}"
  else
    echo "- Output path: <none provided>"
  fi
} >> "$tmp_prompt"

codex exec - < "$tmp_prompt"

if [[ ! -f "$extractor_result_path" ]]; then
  echo "Error: extractor did not produce result artifact at ${extractor_result_path}" >&2
  exit 3
fi

if ! jq -e '
  type == "object" and
  has("status") and
  has("input_kind") and
  has("original_input") and
  has("resolved_repo_url") and
  has("cloned_repo_path") and
  has("metadata_path") and
  has("message") and
  (.status | type == "string") and
  (.input_kind | type == "string") and
  (.original_input | type == "string") and
  (.message | type == "string")
' "$extractor_result_path" >/dev/null 2>&1; then
  echo "Error: extractor result artifact has invalid schema: ${extractor_result_path}" >&2
  exit 3
fi

status="$(jq -r '.status' "$extractor_result_path")"
result_input_kind="$(jq -r '.input_kind' "$extractor_result_path")"
metadata_path="$(jq -r '.metadata_path // empty' "$extractor_result_path")"
message="$(jq -r '.message // empty' "$extractor_result_path")"

if [[ "$result_input_kind" != "$input_kind" ]]; then
  echo "Error: extractor result input_kind mismatch (expected '${input_kind}', got '${result_input_kind}')." >&2
  exit 3
fi

case "$status" in
  ok)
    if [[ -z "$metadata_path" ]]; then
      echo "Error: extractor reported status=ok but metadata_path is empty." >&2
      exit 3
    fi
    if [[ ! -f "$metadata_path" ]]; then
      echo "Error: extractor reported metadata_path but file is missing: ${metadata_path}" >&2
      exit 3
    fi
    if [[ -n "$output_path" && "$metadata_path" != "$output_path" ]]; then
      echo "Warning: extractor wrote metadata to ${metadata_path}, overriding requested output ${output_path}" >&2
    fi
    echo "Extractor completed: ${metadata_path}"
    ;;
  no_repo_found)
    if [[ -z "$message" ]]; then
      message="This DOI does not appear to point to a code repository. Please provide a different DOI or a repository URL/path."
    fi
    echo "$message" >&2
    exit 4
    ;;
  error)
    if [[ -z "$message" ]]; then
      message="Extractor reported an error. Check ${extractor_result_path} for details."
    fi
    echo "$message" >&2
    exit 3
    ;;
  *)
    echo "Error: extractor result has unknown status '${status}'." >&2
    exit 3
    ;;
esac
