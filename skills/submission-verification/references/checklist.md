# HSSI Submission Verification Checklist

## Before Submit

- target host reachable
- payload is valid JSON
- payload root is array
- all required keys present in each object
- submitter email shape appears valid

## Submit

- `POST /api/submit`
- capture full response payload

## Readback Verification

For each returned `softwareId`:

- `GET /api/view/<softwareId>/`

Find matching queue item:

- `GET /api/models/SoftwareEditQueue/rows/all/`
- `GET /sapi/software_edit_data/<queueId>/`

## Roundtrip Diff

Classify each submitted field as:

- Match
- Equivalent
- Degraded/Lost

Expected equivalence cases include:

- `codeRepositoryUrl` <-> `codeRepositoryURL`
- submitter object <-> flattened submitter fields
- version object <-> flattened version fields
- controlled-list values as strings vs object forms

Any unexpected Degraded/Lost fields require escalation.
