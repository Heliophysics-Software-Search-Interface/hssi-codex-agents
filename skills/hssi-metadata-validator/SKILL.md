---
name: hssi-metadata-validator
description: >
  Independently validate an HSSI metadata file against repository evidence.
  Use for adversarial quality checks, extraction review, or gatekeeping before submission.
---

# HSSI Metadata Validator

You are an independent validator. Do not trust extractor output. Verify claims with evidence.

## Trigger Conditions

Use this skill when any of the following is true:

- user asks to validate/verify/review/check an `hssi_metadata.md` file
- extraction is complete and a gate check is needed before submission
- operator asks for ERROR/WARNING/SUGGESTION triage

## Required Inputs

- path to `hssi_metadata.md`
- repository path (if metadata parent is not the repo root)
- report output destination

## Validation Workflow

1. Structural validation
   - ensure all 33 fields are present and numbered correctly
   - ensure mandatory fields are populated
2. Format validation
   - dates, DOI/URL/ORCID/ROR formats
   - controlled-list value validity
3. Accuracy validation
   - cross-check each claim against primary repository sources
   - deep-check Software Functionality and Related Region
4. Completeness validation
   - find likely omissions (authors, DOIs, formats, phenomena, keywords)

### Field-Specific Accuracy Priorities

For higher-risk fields, explicitly verify against canonical sources:

- Fields 2 and 12: DOI/version PID resolution and consistency with `CITATION.cff`, README, `codemeta.json`
- Field 3: repository URL consistency with remotes
- Field 4: exhaustive functionality validation with parent/subcategory checks
- Field 5: related region correctness against scientific scope
- Field 6: author completeness and identifier quality checks
- Field 7: software naming consistency across repo/docs/package metadata
- Field 8: description fidelity vs source docs
- Field 12: version consistency across tags/changelog/package metadata
- Field 13: declared language set vs observed source tree
- Field 14: reference publication DOI validity
- Field 15: license correctness from LICENSE text
- Field 24: documentation URL validity
- Field 33: logo URL validity

Use quick URL/DOI reachability checks when feasible. For optional fields marked `Not found`, perform a short confirmation pass before accepting omission.

## Evidence Requirements

- Every finding must include concrete evidence:
  - file path reference and relevant line context when possible
  - URL or endpoint evidence for network checks
- No unsupported claims.

## Output Contract

Report must include:

- summary counts for ERROR, WARNING, SUGGESTION, PASSED
- findings grouped by severity
- all 33 fields with status
- overall verdict (`PASS` or `NEEDS REVISION`)

Use this structure:

```markdown
# HSSI Metadata Validation Report

## Summary
...

## Findings
### ERRORS
### WARNINGS
### SUGGESTIONS

## Fields Validated
...
```

## Failure Behavior

- If mandatory fields are missing/invalid, emit ERROR.
- If controlled-list values are invalid, emit ERROR.
- If likely incomplete but not provable, emit WARNING.
- If quality can be improved with optional data, emit SUGGESTION.

## Severity Definitions

- **ERROR**: demonstrably incorrect, required format violation, mandatory-field failure, or invalid controlled-list value.
- **WARNING**: likely issue with incomplete proof.
- **SUGGESTION**: optional enhancement with no strict correctness failure.

## References

- `skills/hssi-field-definitions/SKILL.md`
- `skills/software-functionality/SKILL.md`
- `resource_submission_form_fields.md`
