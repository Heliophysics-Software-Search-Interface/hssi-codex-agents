---
name: test-hssi-local-submission
description: Submit HSSI payloads to a local instance (`http://localhost`) and verify persistence using API readback. Use when a user wants safe local post/verify testing without production submission.
---

# Test HSSI Local Submission

Test payloads against local HSSI API with explicit safety gates and readback verification.

## Workflow

1. Confirm target base URL (default `http://localhost`).
2. Validate payload shape before submit.
3. Ask explicit user permission before submission.
4. Submit with `POST /api/submit`.
5. Verify each returned `softwareId` via `GET /api/view/<softwareId>/`.
6. Fetch queue item and stored data via `GET /sapi/software_edit_data/<queueId>/`.
7. Run roundtrip diff: submitted payload vs stored data.
8. Report matches, canonicalized equivalents, and degraded/lost fields.

## Safety Rules

- Never submit to production unless explicitly requested.
- Never auto-submit after payload generation; wait for explicit approval.

## Verification Criteria

A successful local submit must include:
- HTTP 200 from `POST /api/submit`
- `status: ok`
- `count` matches submitted object count
- each result has `submissionId` and `softwareId`
- `GET /api/view/<softwareId>/` returns expected key fields
- `/sapi/software_edit_data/<queueId>/` is retrievable
- roundtrip diff has no unexpected degraded/lost fields, or they are explicitly accepted

## Recommended Checks

- Confirm returned `softwareId` values are queryable via `/api/view/<softwareId>/`.
- If submit response is non-200, still check whether records were created when failure is email-related.
- For edit-link verification, use queue IDs from `/api/models/SoftwareEditQueue/rows/all/` and inspect:
  - `/curate/edit_submission/?uid=<queueId>`
  - `/sapi/software_edit_data/<queueId>/`
- In diff, account for expected representation differences:
  - `codeRepositoryUrl` vs `codeRepositoryURL`
  - `submitter` vs `submitterName`
  - `version` vs `versionNumber`
  - controlled-list arrays represented as name objects vs strings

## References

- `references/checklist.md`
  - Manual verification checklist and troubleshooting hints.
