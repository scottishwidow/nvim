# Implementation Plan: Basic Pre-Commit Hooks

**Branch**: `worktree-002-pre-commit-hooks` | **Date**: 2026-11-10 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/002-pre-commit-hooks/spec.md`

## Summary

Add one `.pre-commit-config.yaml` at the repository root. It runs file hygiene checks from `pre-commit/pre-commit-hooks` (v6.0.0) and Lua formatting with StyLua (v2.6.0) through the `stylua-system` hook. Each hook source is pinned to a full commit SHA. Contributors install pre-commit 4.7.0 and StyLua 2.6.0 once per machine with exact-version, locked installs. Spec Kit files and `lazyvim.json` are excluded from the fixer checks, because their tools overwrite them.

## Technical Context

**Language/Version**: YAML configuration; Lua 5.1 / LuaJIT code is checked. Python >= 3.11 runs pre-commit (machine has 3.14).

**Primary Dependencies**: pre-commit 4.7.0, pre-commit-hooks v6.0.0, StyLua 2.6.0 (see [research.md](research.md)).

**Storage**: N/A

**Testing**: Manual scenarios in [quickstart.md](quickstart.md); `pre-commit run --all-files` as the acceptance gate.

**Target Platform**: Linux (WSL2) developer machine.

**Project Type**: Personal Neovim configuration (LazyVim based).

**Performance Goals**: Under 10 seconds for a commit of up to 10 files after the first run (SC-003).

**Constraints**: `SECURITY.md` supply-chain rules: exact pins, locked installs, verified packages, no piped remote scripts.

**Scale/Scope**: About 10 Lua files and 50 tracked files in total.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

`.specify/memory/constitution.md` is still the unfilled template. It defines no principles, so there are no constitution gates.

The project rules apply in place of the constitution:

| Rule | Source | Status |
|------|--------|--------|
| Pin each dependency to an exact version | `SECURITY.md` | Pass: SHA pins and `==` / `--version` installs |
| Install from the lock file only | `SECURITY.md` | Pass for StyLua (`--locked`). Partial for pre-commit transitive dependencies; see Complexity Tracking |
| Verify each package on its official registry | `SECURITY.md` | Pass: PyPI, crates.io, and GitHub tags checked |
| Tell the user about each new dependency | `SECURITY.md` | Pass: listed in this Summary and in research |
| Let pre-commit hooks run; never use `--no-verify` | `CLAUDE.md` | Pass: no bypass in the design |
| No comments that restate code | `CLAUDE.md` | Pass: only `# frozen: <tag>` pin comments |

Post-design re-check: no change. Pass.

## Project Structure

### Documentation (this feature)

```text
specs/002-pre-commit-hooks/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── hook-config.md
└── tasks.md             # Created by /speckit-tasks
```

### Source Code (repository root)

```text
.pre-commit-config.yaml  # New: hook sources, pins, exclusions
stylua.toml              # Changed by the first full run: final newline added
lua/**/*.lua             # Changed by the first full run only if StyLua finds formatting differences
```

**Structure Decision**: One new file at the root. No new directories. The first full run fixes existing files in a separate commit (spec assumption).

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| pre-commit transitive dependencies are not locked | The framework must be installed, and the user named it | A project virtual environment with a hashed requirements file is too heavy for a personal configuration. Mitigation: `--exclude-newer 2026-10-13` limits transitive dependencies to versions published before the pinned release |
| StyLua binary is installed outside pre-commit (`stylua-system`) | The `stylua` (rust) hook runs `cargo install` without `--locked`; `stylua-github` downloads with no checksum check | Both managed hooks break `SECURITY.md` |
