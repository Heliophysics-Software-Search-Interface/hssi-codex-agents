# HSSI Metadata to Submission API Mapping

Use this reference when converting `hssi_metadata.md` to the `POST /api/submission/` payload.

## Envelope

- Root JSON type must be an array (`[...]`).
- One array element is one submission object.
- Success is HTTP 201 with `softwareId` in each result.
- Submit with camelCase keys; the backend decamelizes internally.

## Required Keys (per object)

- `submitter` (array of submitter objects)
- `softwareName` (string)
- `codeRepositoryUrl` (string URL)
- `authors` (array of person objects)
- `description` (string)

## Object Shape Notes

- Person objects use `givenName` and `familyName`, not `firstName` or `lastName`.
- `license` is a plain string matching a `License.name` controlled-list value.
- `publisher` uses `{name, identifier}` only.
- `version` uses `{number, releaseDate, description, versionPid}`.

## Section Mapping (1-33)

1. Submitter -> `submitter[]`
2. Persistent Identifier -> `persistentIdentifier`
3. Code Repository -> `codeRepositoryUrl`
4. Software Functionality -> `softwareFunctionality[]`
5. Related Region -> `relatedRegion[]`
6. Authors -> `authors[]`
7. Software Name -> `softwareName`
8. Description -> `description`
9. Concise Description -> `conciseDescription`
10. Publication Date -> `publicationDate`
11. Publisher -> `publisher`
12. Version -> `version`
13. Programming Language -> `programmingLanguage[]`
14. Reference Publication -> `referencePublication`
15. License -> `license`
16. Keywords -> `keywords[]`
17. Data Sources -> `dataSources[]`
18. Input File Formats -> `inputFormats[]`
19. Output File Formats -> `outputFormats[]`
20. Operating System -> `operatingSystem[]`
21. CPU Architecture -> `cpuArchitecture[]`
22. Related Phenomena -> `relatedPhenomena[]`
23. Development Status -> `developmentStatus`
24. Documentation -> `documentation`
25. Funder -> `funder[]`
26. Award Title -> `award[]`
27. Related Publications -> `relatedPublications[]`
28. Related Datasets -> `relatedDatasets[]`
29. Related Software -> `relatedSoftware[]`
30. Interoperable Software -> `interoperableSoftware[]`
31. Related Instruments -> `relatedInstruments[]`
32. Related Observatories -> `relatedObservatories[]`
33. Logo -> `logo`

## Controlled Lists

Normalize values to exact endpoint `name` values:

- `/api/models/FunctionCategory/rows/all/`
- `/api/models/Region/rows/all/`
- `/api/models/ProgrammingLanguage/rows/all/`
- `/api/models/FileFormat/rows/all/`
- `/api/models/OperatingSystem/rows/all/`
- `/api/models/CPUArchitecture/rows/all/`
- `/api/models/RepoStatus/rows/all/`
- `/api/models/DataInput/rows/all/`
- `/api/models/Phenomena/rows/all/`
- `/api/models/License/rows/all/`

## Normalization Rules

- `Not found` means field omission.
- Remove source annotations and note prose from values.
- Keep URLs intact.
- Prefer canonical controlled-list names.
- Preserve required fields even when optional fields are omitted.
