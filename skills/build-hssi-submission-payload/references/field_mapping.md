# HSSI Metadata To API Mapping

Use this mapping when converting `hssi_metadata.md` into a submission payload.

## Root Envelope

- Endpoint expects `POST /api/submit` with root JSON array.
- Each array item is one submission object.

## Required Keys (Per Object)

- `submitter`: array of objects
  - each object: `email`, `person`
  - `person`: `firstName`, `lastName`
- `softwareName`: string
- `codeRepositoryUrl`: string URL
- `authors`: array of objects
  - each object: `firstName`, `lastName`
  - optional: `identifier`, `affiliation` (array of organization objects)
- `description`: string

## Section Mapping

- `1. Submitter` -> `submitter[]`
- `2. Persistent Identifier` -> `persistentIdentifier`
- `3. Code Repository` -> `codeRepositoryUrl`
- `4. Software Functionality` -> `softwareFunctionality[]`
- `5. Related Region` -> `relatedRegion[]`
- `6. Authors` -> `authors[]`
- `7. Software Name` -> `softwareName`
- `8. Description` -> `description`
- `9. Concise Description` -> `conciseDescription`
- `10. Publication Date` -> `publicationDate`
- `11. Publisher` -> `publisher` (`name`, optional `identifier`)
- `12. Version` -> `version` (`number`, `release_date`, `description`, `version_pid`)
- `13. Programming Language` -> `programmingLanguage[]`
- `14. Reference Publication` -> `referencePublication`
- `15. License` -> `license` (string name, or object with `name` and optional `url`)
- `16. Keywords` -> `keywords[]`
- `17. Data Sources` -> `dataSources[]`
- `18. Input File Formats` -> `inputFormats[]`
- `19. Output File Formats` -> `outputFormats[]`
- `20. Operating System` -> `operatingSystem[]`
- `21. CPU Architecture` -> `cpuArchitecture[]`
- `22. Related Phenomena` -> `relatedPhenomena[]`
- `23. Development Status` -> `developmentStatus`
- `24. Documentation` -> `documentation`
- `25. Funder` -> `funder[]` (organization objects)
- `26. Award Title` -> `awardTitle[]` (`name`, optional `identifier`)
- `27. Related Publications` -> `relatedPublications[]`
- `28. Related Datasets` -> `relatedDatasets[]`
- `29. Related Software` -> `relatedSoftware[]`
- `30. Interoperable Software` -> `interoperableSoftware[]`
- `31. Related Instruments` -> `relatedInstruments[]` (`name`, optional `identifier`)
- `32. Related Observatories` -> `relatedObservatories[]` (`name`, optional `identifier`)
- `33. Logo` -> `logo`

## Controlled-List Endpoints

Normalize values to exact names from:
- `/api/models/FunctionCategory/rows/all/`
- `/api/models/Region/rows/all/`
- `/api/models/ProgrammingLanguage/rows/all/`
- `/api/models/FileFormat/rows/all/`
- `/api/models/OperatingSystem/rows/all/`
- `/api/models/CPUArchitecture/rows/all/`
- `/api/models/RepoStatus/rows/all/`
- `/api/models/DataInput/rows/all/`
- `/api/models/Phenomena/rows/all/`
- `/api/models/License/rows/all/` (if using license name)

## Normalization Rules

- Treat `Not found` as missing.
- Keep source and note prose out of final field values.
- Preserve URLs as URLs.
- Use exact controlled-list strings where possible.
- For function categories, parser supports `Parent: Child` and often `Parent:Child`; prefer canonical endpoint naming.

## Known Backend Caveats (Current Local Source)

- Payload key is `codeRepositoryUrl`, while `/api/view` output can show `codeRepositoryURL`.
- Email send occurs after DB commit in submit flow; API can return error while record is still stored.
