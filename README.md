# hssi-codex-agents

Codex CLI agents for managing [HSSI](https://hssi.hsdcloud.org) software metadata — extraction, validation, submission, and updates.

## Agents

- **Orchestrator** (AGENTS.md) — Routes requests, manages pipelines, handles approval gates
- **Extractor** (skills/hssi-metadata-extractor/SKILL.md) — Uses subagent-assisted evidence collection to extract metadata from repos into hssi_metadata.md
- **Validator** (skills/hssi-metadata-validator/SKILL.md) — Independently validates extracted metadata
- **Submitter** (skills/hssi-metadata-submitter/SKILL.md) — Builds API payloads and submits to HSSI
- **Updater** (skills/hssi-metadata-updater/SKILL.md) — Updates existing HSSI entries with fresh metadata

## Steps to Use

1. Get [Codex CLI](https://developers.openai.com/codex/cli/)
2. Clone this repo
3. Run `codex` from the root dir
4. Point it to a software repo (e.g. local folder path, GitHub URL, DOI)
5. Metadata gets extracted into `repos/<repo>/hssi_metadata.md`
6. Optionally: ask Codex to submit the metadata to HSSI (production or localhost)
7. To update existing entries: ask Codex to e.g. "update sunpy on HSSI"

(Note: for the best results, always use the latest available model on the highest thinking setting—via `/model`)

## Other versions

This repo is the Codex CLI version. Equivalent versions exist for other agent CLIs:

- [Claude Code version](https://github.com/Heliophysics-Software-Search-Interface/hssi-claude-agents)
- [GitHub Copilot CLI version](https://github.com/Heliophysics-Software-Search-Interface/hssi-copilot-agents)
