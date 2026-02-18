# Local Submission Checklist

## Before Submit

- Local website responds at base URL (default `http://localhost`).
- Payload is valid JSON.
- Root payload type is array.
- Each object contains core required fields.
- Submitter email appears valid.

## Submit

- `POST /api/submit` with `Content-Type: application/json`.
- Capture response body and IDs.

## Verify

For each returned `softwareId`:
- call `GET /api/view/<softwareId>/`
- confirm key fields:
  - `softwareName`
  - `codeRepositoryURL`
  - `description`
  - `authors`
  - `submitterName`

For edit-link flow:
- find queue item in `GET /api/models/SoftwareEditQueue/rows/all/`
- open `GET /sapi/software_edit_data/<queueId>/`
- optional browser check: `/curate/edit_submission/?uid=<queueId>`

## Roundtrip Diff (Required)

Compare submitted payload object against `/sapi/software_edit_data/<queueId>/`.

- Mark each submitted field:
  - `match` (same value),
  - `equivalent` (same meaning, different representation),
  - `degraded_or_lost` (missing or materially changed).
- Use canonical equivalence rules for known shape differences:
  - `codeRepositoryUrl` == stored `codeRepositoryUrl` or public `codeRepositoryURL`
  - `submitter[].person/email` <-> `submitterName.submitterName/submitterEmail`
  - `version.number/release_date/description` <-> `version.versionNumber/versionDate/versionDescription` or `versionNumber.*`
  - `relatedObservatories[].identifier` <-> stored `relatedObservatories[].relatedObservatoryIdentifier`
  - controlled lists can appear as strings, objects with `name`, or IDs.
- Treat any unexpected `degraded_or_lost` field as a failed verification unless user explicitly accepts.

## Troubleshooting

- `400 Root JSON value must be an array`: wrap object in `[]`.
- `FunctionCategory ... does not exist`: normalize functionality terms to exact names.
- `POST expected` on `/api/submit`: wrong HTTP method.
- Email recipient rejected can produce `400` while DB write still persists; check `/api/view/<softwareId>/` and logs.
