---
name: build-hssi-submission-payload
description: Build and verify HSSI submission API payload JSON directly from `hssi_metadata.md` (no parser scripts). Use when a user wants complete metadata extraction, strict API formatting checks, controlled-list normalization, and pre-submit repair.
---

# Build HSSI Submission Payload

Build a high-fidelity HSSI payload by reasoning directly over `hssi_metadata.md`.

## Inputs Required

- `hssi_metadata.md` path
- submitter full name
- submitter email
- target base URL (default `http://localhost`)

## Workflow

1. Parse markdown sections directly.
- Read all numbered sections in order.
- Build a section ledger: section title, extracted value, payload target, omission reason (if any).

2. Build candidate payload.
- Use mapping rules in `references/field_mapping.md`.
- Produce root JSON array with one object unless user requests batch mode.

3. Verification pass A: completeness.
- Every section with usable data must map to a payload field, or have an explicit justified omission.
- Flag any likely dropped content.

4. Verification pass B: contract and types.
- Required fields present and non-empty.
- Objects/arrays match required shape.
- Date strings are ISO (`YYYY-MM-DD`) where applicable.
- URL fields are valid URLs.

5. Verification pass C: controlled vocab.
- Query live controlled-list endpoints on target base URL.
- Normalize to exact names.
- If exact match is not possible, ask user before dropping/changing.

6. Finalize.
- Return payload JSON + verification findings + unresolved questions.
- Do not submit in this skill.

## Required Fields

Each object must include:
- `submitter` (non-empty array)
- `softwareName`
- `codeRepositoryUrl`
- `authors` (non-empty array)
- `description`

## Output Contract

Always return:
- payload JSON
- completeness report (mapped, omitted with reason, unresolved)
- normalization report (original -> final)
- explicit warnings for known backend quirks
- roundtrip-compare plan for submit phase (which endpoint fields will be compared and how)

## References

- `references/field_mapping.md`
  - Canonical section mapping, field shapes, and backend caveats.
