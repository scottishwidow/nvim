# Contract: Hook Configuration and Contributor Commands

## Configuration contract

`.pre-commit-config.yaml` must contain exactly these sources and checks:

| Source | Pinned commit | Tag | Check id | Arguments / exclusion |
|--------|---------------|-----|----------|-----------------------|
| `https://github.com/pre-commit/pre-commit-hooks` | `3e8a8703264a2f4a69428a0aa4dcb512790b2c8c` | `v6.0.0` | `trailing-whitespace` | exclude: managed paths |
| | | | `end-of-file-fixer` | exclude: managed paths |
| | | | `check-merge-conflict` | none |
| | | | `check-added-large-files` | `--maxkb=500` |
| | | | `check-json` | none |
| | | | `check-yaml` | none |
| | | | `check-toml` | none |
| `https://github.com/JohnnyMorganz/StyLua` | `56f9630407f6bf6ee524fb1d7fe71f005a570478` | `v2.6.0` | `stylua-system` | none (reads `stylua.toml`) |

Managed paths (regular expression):

```text
^(\.specify/|\.agents/skills/|\.claude/skills/|lazyvim\.json$)
```

## Command contract

| Purpose | Command | Expected result |
|---------|---------|-----------------|
| Install the framework (once per machine) | `uv tool install pre-commit==4.7.0 --exclude-newer 2026-10-13` | `pre-commit --version` prints `pre-commit 4.7.0` |
| Install the Lua formatter (once per machine) | `cargo install stylua --version 2.6.0 --locked` | `stylua --version` prints `stylua 2.6.0` |
| Enable the checks (once per clone) | `pre-commit install --allow-missing-config` | Git hook written to the hooks directory; commits in checkouts without the configuration file are not blocked |
| Run on demand (User Story 3) | `pre-commit run --all-files` | Each check prints `Passed`, `Failed`, or `Skipped` |
| Commit (User Stories 1 and 2) | `git commit` | Checks run on staged files only |

Exit codes of `pre-commit run`: `0` when all checks pass, `1` when any check fails or changes a file.
