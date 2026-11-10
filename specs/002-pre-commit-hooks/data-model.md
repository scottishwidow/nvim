# Data Model: Basic Pre-Commit Hooks

This feature has no runtime data. The only data is the hook configuration file.

## Entity: Hook configuration

File: `.pre-commit-config.yaml` at the repository root.

| Field | Value | Rule |
|-------|-------|------|
| `repos` | List of hook sources | One entry per source; two sources in total |

## Entity: Hook source (`repos[]`)

| Field | Rule |
|-------|------|
| `repo` | HTTPS URL of a verified repository |
| `rev` | Full 40-character commit SHA, with a `# frozen: <tag>` comment (FR-007) |
| `hooks` | List of checks from this source |

## Entity: Check (`hooks[]`)

| Field | Rule |
|-------|------|
| `id` | Must exist in the `.pre-commit-hooks.yaml` file of the source at the pinned `rev` |
| `args` | Optional; used only for `check-added-large-files` (`--maxkb=500`) |
| `exclude` | Optional regular expression; used only on the fixer checks (see research R5) |

## Check behavior

Each check has three possible results:

- **Passed**: no problem found.
- **Failed**: a problem was found. The commit is blocked.
- **Modified files**: the check fixed the files. The commit is blocked so that the contributor can review and stage the fix.
