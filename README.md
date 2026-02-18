# hssi-metadata-submitter

Prototype Codex CLI agent for converting `hssi_metadata.md` files into HSSI API payload JSON, then testing submissions locally.

## Quick Start

1. Start local HSSI website (`docker-compose up` in `hssi-website`) and confirm `http://localhost/` works.
2. In a new terminal:

```bash
cd ~/git/hssi-metadata-submitter
codex
```

3. In Codex, provide:
- path to `hssi_metadata.md`
- submitter name
- submitter email

Example prompt:

```text
Build an HSSI submission payload from ~/git/hssi-metadata-extractor/repos/AEindex/hssi_metadata.md using submitter name "Your Name" and email "you@example.org". Run a verification pass and show any gaps before submitting.
```

4. Review payload + verification report.
5. Approve submission explicitly when ready.

## Scope

- AI-first extraction (no local parser scripts).
- Default target is `http://localhost`.
- Submission requires explicit approval.
- Post-submit verification is required (`/api/view/<softwareId>/`).
