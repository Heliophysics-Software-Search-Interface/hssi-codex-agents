# hssi-codex-agents
Codex agents for extracting HSSI metadata from any repo and submitting it to the HSSI API.

## Agents

- **Extractor** (AGENTS.md) — Extracts metadata from software repositories into `hssi_metadata.md`
- **Validator** (skills/hssi-metadata-validator/SKILL.md) — Independently validates extracted metadata
- **Submitter** (skills/hssi-metadata-submitter/SKILL.md) — Converts metadata to API JSON and submits to HSSI

## Steps to Use:
1. Install the Codex CLI
2. Clone this repo
3. Run `codex` from the root dir
4. Point it to a software repo (e.g. local folder path, GitHub URL, DOI)
5. Metadata gets extracted into `repos/<repo>/hssi_metadata.md`
6. Optionally: ask Codex to submit the metadata to HSSI (production or localhost)
