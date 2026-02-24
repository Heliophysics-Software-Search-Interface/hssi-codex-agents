# hssi-codex-agents

Codex-first HSSI metadata pipeline for extraction, independent validation, and safe submission.

## Architecture

This repo uses a three-pass default pipeline:

1. Extractor pass: create `hssi_metadata.md`
2. Validator pass: adversarial independent review
3. Submitter pass: payload build, optional submit, roundtrip verification

Passes run in separate `codex exec` invocations by default for context isolation.

## Instruction-First Reasoning vs Script Guards

This repo intentionally splits responsibilities:

- AI instructions (`AGENTS.md`, `prompts/`, `skills/`) perform domain reasoning:
  - metadata extraction strategy
  - field-level validation logic
  - payload mapping and normalization choices
- Scripts enforce deterministic hand-off and safety guards:
  - sidecar artifact contracts (`extractor_result.json`, `validation_result.json`)
  - pass/fail gating and required artifact presence
  - explicit submit confirmation flag behavior

Known tradeoff vs fully interactive agent-only orchestration:

- The scripted path is less conversational/adaptive mid-run, but more reproducible and less likely to stall on ambiguous formatting.
- If a run fails due to contract mismatch, fix the instruction output/sidecar and rerun; this is expected in exchange for deterministic automation.

## Prerequisites

- `codex` CLI in `PATH`
- `jq` in `PATH` (used for machine-readable artifact parsing)
- Optional local HSSI backend at `http://localhost` for local tests
- Network access for live controlled-list endpoint checks

## Quickstart

```bash
cd ~/git/hssi-codex-agents
```

### Repository Input Behavior

- Local path input: uses that repository directly.
- Repository URL input: auto-clones into `repos/<repo-name>/` and writes metadata there.
- DOI input: AI resolves DOI metadata to the related code repository URL, then clones that repo into `repos/<repo-name>/`.
- Default output path: `<resolved-repo>/hssi_metadata.md`.
- Non-clonable URL input fails with a remediation hint after clone attempt.
- If DOI does not appear to point to a code repository, the extractor tells you directly to provide a different DOI or repo URL/path.

### Extract only (default mode)

```bash
./scripts/run-pipeline.sh \
  --repo /path/to/software-repo
```

### Extract from URL (auto-cloned under `repos/`)

```bash
./scripts/run-pipeline.sh \
  --repo https://github.com/organization/project
```

### Extract from DOI (auto-resolved to code repo and cloned under `repos/`)

```bash
./scripts/run-pipeline.sh \
  --repo 10.5281/zenodo.1234567
```

### Extract + submit (production dry-run by default)

```bash
./scripts/run-pipeline.sh \
  --repo /path/to/software-repo \
  --mode extract-submit \
  --submitter-name "First Last" \
  --submitter-email "you@example.org"
```

### Extract + submit to localhost (dry-run)

```bash
./scripts/run-pipeline.sh \
  --repo /path/to/software-repo \
  --mode extract-submit-local \
  --submitter-name "First Last" \
  --submitter-email "you@example.org"
```

### Confirmed submission

```bash
./scripts/run-pipeline.sh \
  --repo /path/to/software-repo \
  --mode extract-submit \
  --submitter-name "First Last" \
  --submitter-email "you@example.org" \
  --confirm-submit
```

## Script Interfaces

### `scripts/run-extractor.sh`

- Required: `--repo <path|url|doi>`
- Optional:
  - `--mode extract|extract-submit|extract-submit-local` (default `extract`)
  - `--output <path>`
- Behavior:
  - URL inputs are cloned/refreshed under `repos/` automatically.
  - DOI inputs are resolved by AI to repository URLs, then cloned under `repos/`.
  - If no `--output` is given and a resolved repo path exists, metadata defaults to `<resolved-repo>/hssi_metadata.md`.
  - Writes machine-readable extraction contract to `artifacts/extractor_result.json`.
  - Sidecar keys: `status`, `input_kind`, `original_input`, `resolved_repo_url`, `cloned_repo_path`, `metadata_path`, `message`.
  - For DOI values not linked to code repos, returns `status=no_repo_found` and a human-facing remediation message.

### `scripts/run-validator.sh`

- Required: `--metadata <path/to/hssi_metadata.md>`
- Writes `artifacts/validation_report.md`
- Writes `artifacts/validation_result.json`
- Sidecar keys: `status`, `error_count`, `warning_count`, `suggestion_count`, `verdict`, `report_path`
- Exits non-zero when `VALIDATOR_FAIL_ON_ERRORS=1` (default) and `validation_result.json` has `error_count > 0`

### `scripts/run-submitter.sh`

- Required:
  - `--metadata <path>`
  - `--submitter-name "First Last"`
  - `--submitter-email "email"`
- Optional:
  - `--target https://hssi.hsdcloud.org|http://localhost` (default production)
  - `--dry-run` (default behavior)
  - `--confirm-submit` (enables actual POST)
- On successful confirmed submission, always ends with `New IDs` and `Direct links` block (`Edit page`, `API view`, `SAPI data`).

### `scripts/run-pipeline.sh`

- Orchestrates extractor -> validator -> submitter in isolated passes
- Defaults:
  - mode `extract`
  - no submission unless submit mode selected
  - dry-run submit unless `--confirm-submit`
- Optional `--use-collab` enables experimental single-session path
- Passes requested mode through to extractor (`extract`, `extract-submit`, or `extract-submit-local`).
- Uses `artifacts/extractor_result.json` as canonical metadata handoff.
- Uses `artifacts/validation_result.json` as canonical validator gate.
- URL inputs are auto-cloned/refreshed under `repos/` before extraction.
- DOI inputs are resolved by AI and cloned under `repos/<repo-name>/` before downstream passes.

## Artifacts

Generated runtime outputs are written to `artifacts/`:

- `extractor_result.json`
- `validation_report.md`
- `validation_result.json`
- `submission_payload.json`
- `submission_response.json`
- `roundtrip_report.md`

## Operational Safety

- Extract-only default
- Production target default for submitter, with mandatory explicit confirmation before POST
- Recommended workflow: dry-run first, then confirmed submit
- Roundtrip verification is required for every confirmed submission

## Skill Layout

- `skills/hssi-field-definitions/`
- `skills/software-functionality/`
- `skills/submission-payload/`
- `skills/submission-verification/`
- `skills/update-api-spec/`
- `skills/hssi-metadata-validator/`
- `skills/hssi-metadata-submitter/`

## Canonical References

- `resource_submission_form_fields.md`
- `payloads/ACE_magnetometer_submission.json`
- `payloads/gemini3d_submission.json`
- `payloads/pydarn_submission.json`
