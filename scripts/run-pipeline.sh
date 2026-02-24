#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  run-pipeline.sh \
    --repo <path|url|doi> \
    [--mode extract|extract-submit|extract-submit-local] \
    [--output <metadata-path>] \
    [--submitter-name "First Last"] \
    [--submitter-email "email@example.org"] \
    [--dry-run] \
    [--confirm-submit] \
    [--use-collab]

Defaults:
  - mode: extract
  - submit disabled unless mode is extract-submit or extract-submit-local
  - submit step uses dry-run unless --confirm-submit is given
  - isolated multi-pass orchestration is default; --use-collab is experimental

Repository handling:
  - local paths: used directly
  - repository URLs: auto-cloned/refreshed into repos/<repo-name> before extraction
  - DOI inputs: resolved by AI to code repo URLs and cloned under repos/<repo-name>
  - non-clonable URL inputs fail after attempted clone with remediation guidance
USAGE
}

if ! command -v codex >/dev/null 2>&1; then
  echo "Error: codex CLI not found in PATH." >&2
  exit 127
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required to parse pipeline result artifacts." >&2
  exit 127
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
source "${script_dir}/lib/repo_input_resolver.sh"

repo_input=""
mode="extract"
output_path=""
submitter_name=""
submitter_email=""
confirm_submit="0"
force_dry_run="0"
use_collab="0"

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
    --submitter-name)
      submitter_name="${2:-}"
      shift 2
      ;;
    --submitter-email)
      submitter_email="${2:-}"
      shift 2
      ;;
    --confirm-submit)
      confirm_submit="1"
      shift
      ;;
    --dry-run)
      force_dry_run="1"
      shift
      ;;
    --use-collab)
      use_collab="1"
      shift
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

if ! resolve_repo_input "$repo_root" "$repo_input"; then
  exit $?
fi
resolved_repo_input="$REPO_INPUT_RESOLVED"
input_kind="$REPO_INPUT_KIND"
default_metadata_path="$REPO_INPUT_DEFAULT_METADATA_PATH"
effective_output_path="$output_path"
if [[ -z "$effective_output_path" && -n "$default_metadata_path" ]]; then
  effective_output_path="$default_metadata_path"
fi

extractor_result_path="${repo_root}/artifacts/extractor_result.json"
validator_result_path="${repo_root}/artifacts/validation_result.json"

if [[ "$use_collab" == "1" ]]; then
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
      echo "- DOI behavior: resolve DOI to repository URL and clone under repos/<repo-name>."
    fi
    echo "- Requested mode: ${mode}"
    if [[ -n "$effective_output_path" ]]; then
      echo "- Output path: ${effective_output_path}"
    fi
    if [[ -n "$submitter_name" ]]; then
      echo "- Submitter name: ${submitter_name}"
    fi
    if [[ -n "$submitter_email" ]]; then
      echo "- Submitter email: ${submitter_email}"
    fi
    echo "- Collaboration mode: enabled (single-session experimental path)"
    echo "- If mode includes submit, perform validation and submitter steps in-session."
  } >> "$tmp_prompt"
  codex exec - < "$tmp_prompt"
  echo "Pipeline completed in experimental collaborative mode."
  exit 0
fi

extractor_repo_input="$resolved_repo_input"
if [[ "$input_kind" == "doi" ]]; then
  extractor_repo_input="$repo_input"
fi

extract_args=(
  --repo "$extractor_repo_input"
  --mode "$mode"
)
if [[ -n "$effective_output_path" ]]; then
  extract_args+=(--output "$effective_output_path")
fi

if "${script_dir}/run-extractor.sh" "${extract_args[@]}"; then
  :
else
  extractor_rc=$?
  if [[ -f "$extractor_result_path" ]]; then
    extractor_status="$(jq -r '.status // empty' "$extractor_result_path" 2>/dev/null || true)"
    if [[ "$extractor_status" == "no_repo_found" ]]; then
      exit 4
    fi
  fi
  exit "$extractor_rc"
fi

if [[ ! -f "$extractor_result_path" ]]; then
  echo "Error: extractor result artifact missing: ${extractor_result_path}" >&2
  exit 3
fi

extractor_status="$(jq -r '.status // empty' "$extractor_result_path" 2>/dev/null || true)"
extractor_message="$(jq -r '.message // empty' "$extractor_result_path" 2>/dev/null || true)"
metadata_path="$(jq -r '.metadata_path // empty' "$extractor_result_path" 2>/dev/null || true)"

case "$extractor_status" in
  ok)
    if [[ -z "$metadata_path" || ! -f "$metadata_path" ]]; then
      echo "Error: extractor reported status=ok but metadata_path is missing or does not exist." >&2
      exit 3
    fi
    ;;
  no_repo_found)
    if [[ -z "$extractor_message" ]]; then
      extractor_message="This DOI does not appear to point to a code repository. Please provide a different DOI or a repository URL/path."
    fi
    echo "$extractor_message" >&2
    exit 4
    ;;
  error)
    if [[ -z "$extractor_message" ]]; then
      extractor_message="Extractor reported an error. Check ${extractor_result_path}."
    fi
    echo "$extractor_message" >&2
    exit 3
    ;;
  *)
    echo "Error: extractor result has unknown status '${extractor_status}'." >&2
    exit 3
    ;;
esac

"${script_dir}/run-validator.sh" --metadata "$metadata_path"

if [[ ! -f "$validator_result_path" ]]; then
  echo "Error: validator result artifact missing: ${validator_result_path}" >&2
  exit 3
fi

if [[ "$mode" == "extract" ]]; then
  echo "Pipeline completed in extract mode."
  exit 0
fi

if [[ -z "$submitter_name" || -z "$submitter_email" ]]; then
  echo "Error: submit mode requires --submitter-name and --submitter-email." >&2
  exit 2
fi

target_url="https://hssi.hsdcloud.org"
if [[ "$mode" == "extract-submit-local" ]]; then
  target_url="http://localhost"
fi

submit_args=(
  --metadata "$metadata_path"
  --submitter-name "$submitter_name"
  --submitter-email "$submitter_email"
  --target "$target_url"
)

if [[ "$confirm_submit" == "1" && "$force_dry_run" != "1" ]]; then
  submit_args+=(--confirm-submit)
else
  submit_args+=(--dry-run)
fi

"${script_dir}/run-submitter.sh" "${submit_args[@]}"

echo "Pipeline completed: mode=${mode} metadata=${metadata_path}"
