---
name: hssi-metadata-submitter
description: >
  Build HSSI submission payloads from hssi_metadata.md, run verification,
  and submit with explicit approval followed by roundtrip validation.
---

# HSSI Metadata Submitter

Convert extracted metadata into API-ready JSON and safely submit to HSSI.

## Trigger Conditions

Use this skill when any of the following is true:

- user asks to submit metadata to HSSI
- user asks to build/repair submission payload JSON
- user asks for roundtrip verification of submitted records

## Required Inputs

- metadata path (`hssi_metadata.md`)
- submitter name and email
- target base URL (`https://hssi.hsdcloud.org` or `http://localhost`)
- approval state (approved or dry-run)

## Workflow

1. Parse all metadata sections and build section ledger
2. Build payload JSON using `submission-payload` mapping
3. Verify:
   - completeness (all usable values accounted for)
   - schema/type correctness
   - controlled-list normalization via live endpoints
4. Present payload and verification findings before submit decision
5. If dry-run, stop without POST
6. If approved, submit via `POST /api/submit`
7. Verify persistence via `/api/view/<softwareId>/` and `/sapi/software_edit_data/<queueId>/`
8. Classify roundtrip status per field: Match, Equivalent, Degraded/Lost

## Source of Truth Order

When sources conflict, use this precedence:

1. Live endpoint responses from the selected target URL
2. `skills/submission-payload/SKILL.md`
3. `skills/submission-verification/SKILL.md`
4. Verified payload fixtures in `payloads/`

## Output Contract

Always provide:

- payload JSON artifact
- mapping/normalization notes
- explicit omitted-field reasons
- roundtrip report (or dry-run roundtrip plan)
- section-to-payload audit trail (`section -> payload key`)
- normalization trail (`original -> normalized`)

On confirmed submit, provide IDs and links:

- `submissionId`
- `softwareId`
- `queueId`
- edit link, view link, sapi link

After successful submission, always end console output with a final block in this exact shape:

```text
New IDs:

  - submissionId: <submissionId>
  - softwareId: <softwareId>
  - queueId: <queueId>

Direct links:

  - Edit page: <targetUrl>/curate/edit_submission/?uid=<queueId>
  - API view: <targetUrl>/api/view/<softwareId>/
  - SAPI data: <targetUrl>/sapi/software_edit_data/<queueId>/
```

This block must be the last thing printed after a successful submission.

## Safety Rules

- Never submit without explicit approval.
- Never silently drop required fields.
- If required values are ambiguous, ask before proceeding.
- Report all degraded/lost fields explicitly.

## Failure Behavior

- Missing required payload fields: stop and request fixes.
- Unresolved controlled-list mismatches: emit warning and request operator decision.
- Failed POST or uncertain persistence: run readback checks and report exact state.

## References

- `skills/submission-payload/SKILL.md`
- `skills/submission-verification/SKILL.md`
- `skills/hssi-field-definitions/SKILL.md`
- `payloads/gemini3d_submission.json`
