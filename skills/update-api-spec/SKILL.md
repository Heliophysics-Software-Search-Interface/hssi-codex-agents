---
name: update-api-spec
description: >
  Update submitter API references from hssi-website source code.
  Use when HSSI API field names, shapes, or behavior have changed.
---

# Update API Spec

Sync submitter-facing reference material with current HSSI backend behavior.

## When To Use

- payloads start failing due to field/key mismatches
- controlled-list endpoints appear changed
- HSSI team announces API/schema updates

## Workflow

### Step 1: Fetch source of truth

Use local clone if available (preferred):

- `~/git/hssi-website`

Otherwise clone to temp:

```bash
git clone https://github.com/Heliophysics-Software-Search-Interface/hssi-website.git /tmp/hssi-website
```

### Step 2: Read canonical files

Review these files in `hssi-website`:

1. `concept/import_submission_notes.md`
2. `concept/import_submission.json`
3. `django/website/views/api_submit.py`
4. `django/website/data_parser.py`
5. `django/website/forms/names.py`

### Step 3: Compare with local skills

Compare findings against:

- `skills/submission-payload/SKILL.md`
- `skills/submission-verification/SKILL.md`
- `skills/submission-payload/references/field_mapping.md`
- `skills/submission-verification/references/checklist.md`

Explicitly detect parser-vs-documentation mismatches:

- differences between `concept/import_submission.json` and parser/runtime handling
- differences between conceptual docs and `django/website/data_parser.py`
- key naming/shape mismatches that could break payload compatibility

### Step 4: Update local reference skills

Update mappings and behavior docs for:

- field names and shapes
- required vs optional expectations
- controlled-list endpoints
- known backend quirks and equivalence mappings

### Step 5: Report deltas

Produce a concise changelog of:

- what changed
- why it changed
- any breaking impact on existing payloads/scripts
- parser-vs-doc mismatches discovered (with concrete examples)
- whether each mismatch is breaking, non-breaking, or informational

### Step 6: Cleanup

If temp clone used, keep or remove based on operator preference.
