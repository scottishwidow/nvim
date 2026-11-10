# Research: Basic Pre-Commit Hooks

All facts below were verified on 2026-11-10 against the official sources (GitHub tags, PyPI, crates.io).

## R1: Hook framework and version

- **Decision**: pre-commit `4.7.0` (PyPI, released 2026-10-12). Install as a user tool: `uv tool install pre-commit==4.7.0`.
- **Rationale**: The user named the framework. `4.7.0` is the latest release and is older than two weeks. It requires Python >= 3.11; the machine has Python 3.14. `uv` is already on the machine.
- **Alternatives considered**: `pipx install pre-commit==4.7.0` (also works; `uv` is faster and already used). A project-local virtual environment with a hashed requirements file (rejected: too heavy for a personal editor configuration).
- **Known gap**: `uv tool install` pins pre-commit but not its transitive dependencies. Mitigation: add `--exclude-newer 2026-10-13` so that transitive dependencies resolve to versions published before the pinned release.

## R2: File hygiene hooks

- **Decision**: `https://github.com/pre-commit/pre-commit-hooks`, tag `v6.0.0`, commit `3e8a8703264a2f4a69428a0aa4dcb512790b2c8c`. Hooks: `trailing-whitespace`, `end-of-file-fixer`, `check-merge-conflict`, `check-added-large-files` (`--maxkb=500`), `check-json`, `check-yaml`, `check-toml`.
- **Rationale**: Official hook set of the framework. Each hook maps to one functional requirement (FR-002 to FR-005).
- **Alternatives considered**: `mixed-line-ending`, `check-symlinks`, `detect-private-key` (useful, but outside the "basic" scope of the spec).

## R3: Version pin format

- **Decision**: Set `rev` to the full commit SHA with the tag in a trailing comment, for example `rev: 3e8a8703264a2f4a69428a0aa4dcb512790b2c8c  # frozen: v6.0.0`.
- **Rationale**: Git tags can move; a commit SHA cannot. This is the format `pre-commit autoupdate --freeze` writes, and it matches the GitHub Actions rule in `SECURITY.md`.
- **Alternatives considered**: Tag only (rejected: a tag can move).

## R4: Lua formatter source

- **Decision**: StyLua `2.6.0` (released 2026-10-10). Use the `stylua-system` hook from `https://github.com/JohnnyMorganz/StyLua`, tag `v2.6.0`, commit `56f9630407f6bf6ee524fb1d7fe71f005a570478`. Install the binary with `cargo install stylua --version 2.6.0 --locked` (crate verified on crates.io, not yanked).
- **Rationale**: The project already has `stylua.toml`. Of the three hooks that StyLua provides:
  - `stylua` (language `rust`): pre-commit 4.7.0 runs `cargo install` without `--locked` (verified in `pre_commit/languages/rust.py`). This ignores `Cargo.lock` and breaks the rule "install from the lock file only".
  - `stylua-github` (language `python`): downloads a release archive through `release-gitter` with no checksum check and an unpinned build dependency.
  - `stylua-system`: runs the `stylua` binary on `PATH`. The binary is installed once with a locked, exact-version build.
- **Behavior when the binary is missing**: pre-commit fails with "Executable `stylua` not found". The check does not pass silently, which satisfies the edge case in the spec.
- **Alternatives considered**: `stylua-github` and `stylua` (rejected for the supply-chain reasons above). The `mise` tool manager (rejected: adds a tool that this project does not need).

## R5: Exclusions

The scan of the current tracked files found:

- No trailing whitespace.
- Missing final newline: `.specify/workflows/workflow-registry.json`, `lazyvim.json`, `stylua.toml`.
- Largest file: 40 KB (under the 500 KB limit).
- Symbolic links: `CLAUDE.md` and `.claude/skills/*`.

- **Decision**: Exclude these paths from the fixer hooks (`trailing-whitespace`, `end-of-file-fixer`) only:
  - `^\.specify/`, `^\.agents/skills/`, `^\.claude/skills/`: managed by Spec Kit. A refresh overwrites local edits.
  - `^lazyvim\.json$`: written by LazyVim with no final newline. A fix would come back after each LazyVim write.
- **Rationale**: Prevents changes that a tool reverts later (edge case in the spec). The syntax checks still run on these files.
- **Result**: The first full run changes only `stylua.toml` (final newline), plus any Lua formatting fixes.

## R6: Continuous integration

- **Decision**: Not part of this feature (spec assumption).
