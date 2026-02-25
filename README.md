# hssi-codex-agents
Codex agents for extracting HSSI metadata from any repo and submitting it to the HSSI API.

## Agents

- **Extractor** (AGENTS.md) — Extracts metadata from software repositories into `hssi_metadata.md`
- **Validator** (skills/hssi-metadata-validator/SKILL.md) — Independently validates extracted metadata
- **Submitter** (skills/hssi-metadata-submitter/SKILL.md) — Converts metadata to API JSON and submits to HSSI
- **Updater** (skills/hssi-metadata-updater/SKILL.md) — Updates existing HSSI entries with fresh metadata from repos

## Steps to Use:
1. Get [Codex CLI](https://developers.openai.com/codex/cli/)
2. Clone this repo
3. Run `codex` from the root dir
4. Point it to a software repo (e.g. local folder path, GitHub URL, DOI)
5. Metadata gets extracted into `repos/<repo>/hssi_metadata.md`
6. Optionally: ask Codex to submit the metadata to HSSI (production or localhost)
7. To update existing entries: ask Codex to "update sunpy on HSSI" or "enrich sunpy's metadata"
