# hssi-codex-agents

Codex CLI agents for managing [HSSI](https://hssi.hsdcloud.org) software metadata — extraction, validation, submission, and updates.

## Agents

- **Orchestrator** (AGENTS.md) — Routes requests, manages pipelines, handles approval gates
- **Extractor** (skills/hssi-metadata-extractor/SKILL.md) — Extracts metadata from repos into hssi_metadata.md
- **Validator** (skills/hssi-metadata-validator/SKILL.md) — Independently validates extracted metadata
- **Submitter** (skills/hssi-metadata-submitter/SKILL.md) — Builds API payloads and submits to HSSI
- **Updater** (skills/hssi-metadata-updater/SKILL.md) — Updates existing HSSI entries with fresh metadata

## Steps to Use

1. Get [Codex CLI](https://developers.openai.com/codex/cli/)
2. Clone this repo
3. Run `codex` from the root dir
4. Point it to a software repo (e.g. local folder path, GitHub URL, DOI)
5. Metadata gets extracted into `repos/<repo>/hssi_metadata.md`
6. Optionally: ask Codex to submit the metadata to HSSI
7. To update existing entries: ask Codex to "update sunpy on HSSI"

## Claude Code
See the [Claude Code version of this repo](https://github.com/Heliophysics-Software-Search-Interface/hssi-claude-agents).
