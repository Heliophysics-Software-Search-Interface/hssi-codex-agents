# HSSI Submission Verification Checklist

## Before Submit

- target host reachable
- payload is valid JSON
- payload root is array
- all required keys present in each object
- submitter email shape appears valid

## Submit

- `POST /api/submission/` (trailing slash)
- expect HTTP 201 Created
- capture full response payload
- response results include `softwareId`; they do not include `submissionId` or `queueId`

## Readback Verification

For each returned `softwareId`:

Find matching queue item:

- `GET /api/models/SoftwareEditQueue/rows/all/`
- `GET /sapi/software_edit_data/<queueId>/`

Secondary public view, usually only after curator verification:

- `GET /api/view/software/<softwareId>/`

## Roundtrip Diff

Classify each submitted field as:

- Match
- Equivalent
- Degraded/Lost

Expected equivalence cases include:

- `codeRepositoryUrl` <-> `codeRepositoryURL`
- `givenName`/`familyName` <-> stored person/display-name fields
- submitter object <-> flattened submitter fields
- version object <-> flattened version fields
- license string <-> stored license object
- controlled-list values as strings vs object forms

Any unexpected Degraded/Lost fields require escalation.
