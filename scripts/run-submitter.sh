#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  run-submitter.sh \
    --metadata <path/to/hssi_metadata.md> \
    --submitter-name "First Last" \
    --submitter-email "email@example.org" \
    [--target https://hssi.hsdcloud.org|http://localhost] \
    [--dry-run] \
    [--confirm-submit]

Notes:
  - Default target is production: https://hssi.hsdcloud.org
  - Default behavior is dry-run unless --confirm-submit is set
USAGE
}

if ! command -v codex >/dev/null 2>&1; then
  echo "Error: codex CLI not found in PATH." >&2
  exit 127
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required to build final submission link summary." >&2
  exit 127
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"

metadata_path=""
submitter_name=""
submitter_email=""
target_url="https://hssi.hsdcloud.org"
dry_run="1"

while (($# > 0)); do
  case "$1" in
    --metadata)
      metadata_path="${2:-}"
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
    --target)
      target_url="${2:-}"
      shift 2
      ;;
    --dry-run)
      dry_run="1"
      shift
      ;;
    --confirm-submit)
      dry_run="0"
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

if [[ -z "$metadata_path" || -z "$submitter_name" || -z "$submitter_email" ]]; then
  echo "Error: --metadata, --submitter-name, and --submitter-email are required." >&2
  usage
  exit 2
fi
if [[ ! -f "$metadata_path" ]]; then
  echo "Error: metadata file not found: $metadata_path" >&2
  exit 2
fi
if [[ "$submitter_email" != *"@"* ]]; then
  echo "Error: submitter email appears invalid: $submitter_email" >&2
  exit 2
fi

payload_path="${repo_root}/artifacts/submission_payload.json"
response_path="${repo_root}/artifacts/submission_response.json"
roundtrip_path="${repo_root}/artifacts/roundtrip_report.md"

mkdir -p "${repo_root}/artifacts"
if [[ "$dry_run" == "1" ]]; then
  rm -f "$response_path"
fi

tmp_prompt="$(mktemp)"
trap 'rm -f "$tmp_prompt"' EXIT

cat "${repo_root}/prompts/submitter.md" > "$tmp_prompt"
{
  echo
  echo "## Runtime Inputs"
  echo "- Metadata path: ${metadata_path}"
  echo "- Submitter name: ${submitter_name}"
  echo "- Submitter email: ${submitter_email}"
  echo "- Target URL: ${target_url}"
  echo "- Payload output path: ${payload_path}"
  echo "- Response output path: ${response_path}"
  echo "- Roundtrip report path: ${roundtrip_path}"
  if [[ "$dry_run" == "1" ]]; then
    echo "- Approval status: not approved (dry-run only; DO NOT POST)"
  else
    echo "- Approval status: approved (operator passed --confirm-submit)"
  fi
} >> "$tmp_prompt"

codex exec - < "$tmp_prompt"

if [[ ! -f "$payload_path" ]]; then
  echo "Error: submitter did not produce payload at ${payload_path}" >&2
  exit 3
fi
if [[ ! -f "$roundtrip_path" ]]; then
  echo "Error: submitter did not produce roundtrip report at ${roundtrip_path}" >&2
  exit 3
fi
if [[ "$dry_run" == "0" && ! -f "$response_path" ]]; then
  echo "Error: confirmed submit expected response artifact at ${response_path}" >&2
  exit 3
fi

if [[ "$dry_run" == "1" ]]; then
  echo "Submitter dry-run completed."
  echo "Payload: ${payload_path}"
  if [[ -f "$response_path" ]]; then
    echo "Response: ${response_path}"
  fi
  echo "Roundtrip: ${roundtrip_path}"
  exit 0
fi

echo "Submitter confirmed submission completed."
echo "Payload: ${payload_path}"
echo "Response: ${response_path}"
echo "Roundtrip: ${roundtrip_path}"

target_base="${target_url%/}"
target_base="${target_base%/api/submit}"

submission_id="$(jq -r '.submissionId // .responseBodyRaw.results[0].submissionId // empty' "$response_path")"
software_id="$(jq -r '.softwareId // .responseBodyRaw.results[0].softwareId // empty' "$response_path")"
queue_id="$(jq -r '.queueId // .responseBodyRaw.results[0].queueId // empty' "$response_path")"

if [[ -z "$submission_id" ]]; then
  submission_id="$(sed -n 's/.*submissionId: `\([^`]*\)`.*/\1/p' "$roundtrip_path" | head -n1 || true)"
fi
if [[ -z "$software_id" ]]; then
  software_id="$(sed -n 's/.*softwareId: `\([^`]*\)`.*/\1/p' "$roundtrip_path" | head -n1 || true)"
fi
if [[ -z "$queue_id" ]]; then
  queue_id="$(sed -n 's/.*queueId: `\([^`]*\)`.*/\1/p' "$roundtrip_path" | head -n1 || true)"
fi

if [[ -z "$submission_id" || -z "$software_id" || -z "$queue_id" ]]; then
  echo "Error: could not determine submissionId/softwareId/queueId for final link summary." >&2
  echo "Check ${response_path} and ${roundtrip_path}." >&2
  exit 3
fi

echo
echo "New IDs:"
echo
echo "  - submissionId: ${submission_id}"
echo "  - softwareId: ${software_id}"
echo "  - queueId: ${queue_id}"
echo
echo "Direct links:"
echo
echo "  - Edit page: ${target_base}/curate/edit_submission/?uid=${queue_id}"
echo "  - API view: ${target_base}/api/view/${software_id}/"
echo "  - SAPI data: ${target_base}/sapi/software_edit_data/${queue_id}/"
