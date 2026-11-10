---

description: "Task list for Basic Pre-Commit Hooks"
---

# Tasks: Basic Pre-Commit Hooks

**Input**: Design documents from `/specs/002-pre-commit-hooks/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/hook-config.md, quickstart.md

**Tests**: The spec does not request automated tests. Validation uses the manual scenarios in `quickstart.md`.

**Organization**: Tasks are grouped by user story. All paths are relative to the repository root.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Install the pinned tools on the developer machine. These tasks change no repository file.

- [ ] T001 [P] Install pre-commit with `uv tool install pre-commit==4.7.0 --exclude-newer 2026-10-13`, then confirm that `pre-commit --version` prints `pre-commit 4.7.0` (research R1; no repository file)
- [ ] T002 [P] Install StyLua with `cargo install stylua --version 2.6.0 --locked`, then confirm that `stylua --version` prints `stylua 2.6.0` (research R4; no repository file)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create the hook configuration file that all stories add to.

- [ ] T003 Create `.pre-commit-config.yaml` with a top-level `repos:` list and the first source entry: `repo: https://github.com/pre-commit/pre-commit-hooks`, `rev: 3e8a8703264a2f4a69428a0aa4dcb512790b2c8c  # frozen: v6.0.0`, and an empty `hooks:` list. Rule from data-model.md: "`rev`: Full 40-character commit SHA, with a `# frozen: <tag>` comment (FR-007)". Add no other comments (CLAUDE.md code comment rules)
- [ ] T004 Run `pre-commit install --allow-missing-config` in the worktree and confirm that git now uses the pre-commit hook script (it is written to the hooks directory that `git rev-parse --git-path hooks` prints; no repository file). All worktrees share this directory. The flag lets commits continue in checkouts that do not have `.pre-commit-config.yaml` yet. Confirm that the command finishes in under 1 minute (SC-001)

**Checkpoint**: The configuration file exists and git runs pre-commit on each commit.

---

## Phase 3: User Story 1 - Block common file hygiene problems at commit time (Priority: P1) MVP

**Goal**: Commits are blocked or fixed for trailing whitespace, missing final newline, merge conflict markers, large files, and invalid JSON, YAML, or TOML.

**Independent Test**: Quickstart scenarios 2, 3, 4, 8, 9, and 10 block the commit; a clean commit succeeds.

### Implementation for User Story 1

- [ ] T005 [US1] In `.pre-commit-config.yaml`, under the `pre-commit-hooks` source, add the hooks `trailing-whitespace` and `end-of-file-fixer`. Give each hook `exclude: ^(\.specify/|\.agents/skills/|\.claude/skills/|lazyvim\.json$)` (contract "Managed paths"; research R5)
- [ ] T006 [US1] In `.pre-commit-config.yaml`, under the same source, add `check-merge-conflict`, `check-added-large-files` with `args: [--maxkb=500]`, `check-json`, `check-yaml`, and `check-toml`, with no exclusions (contract table; FR-003 to FR-005)
- [ ] T007 [US1] Run `pre-commit run --all-files`. Expect `end-of-file-fixer` to add a final newline to `stylua.toml` only. Confirm that no file under `.specify/`, `.agents/skills/`, or `.claude/skills/`, and not `lazyvim.json`, was changed (`git status --short`)
- [ ] T008 [US1] Run quickstart scenarios 2, 3, 4, 8, 9, and 10 from `specs/002-pre-commit-hooks/quickstart.md`. Confirm each blocks the commit and names the scratch file. If a commit succeeds, stop and ask the user. Remove and unstage the scratch files after each scenario

**Checkpoint**: File hygiene checks work. This is the MVP.

---

## Phase 4: User Story 2 - Enforce consistent Lua formatting (Priority: P2)

**Goal**: Staged Lua files are checked and reformatted against `stylua.toml`.

**Independent Test**: Quickstart scenario 5 blocks the commit and reformats the file.

### Implementation for User Story 2

- [ ] T009 [US2] In `.pre-commit-config.yaml`, append a second source: `repo: https://github.com/JohnnyMorganz/StyLua`, `rev: 56f9630407f6bf6ee524fb1d7fe71f005a570478  # frozen: v2.6.0`, with one hook `id: stylua-system` and no arguments (research R4: do not use the `stylua` or `stylua-github` hook ids)
- [ ] T010 [US2] Run `pre-commit run stylua-system --all-files`. Review each Lua change under `lua/` and in `init.lua` with `git diff`. Confirm that the changes are formatting only
- [ ] T011 [US2] Run quickstart scenarios 5 and 6 from `specs/002-pre-commit-hooks/quickstart.md`. For scenario 6, run with a `PATH` that does not contain `~/.cargo/bin`. Remove and unstage the scratch files

**Checkpoint**: Lua formatting is enforced at commit time.

---

## Phase 5: User Story 3 - Run all checks on demand (Priority: P3)

**Goal**: One command checks all tracked files.

**Independent Test**: Quickstart scenario 1 passes with exit code `0`.

### Implementation for User Story 3

- [ ] T012 [US3] Run `pre-commit run --all-files` and confirm that every check prints `Passed` or `Skipped` and the exit code is `0` (SC-004, FR-010)

**Checkpoint**: All user stories work.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Verify the pins and make the commits.

- [ ] T013 Run quickstart scenario 7 (`grep -E '^\s+rev:' .pre-commit-config.yaml`) and confirm that each `rev` is a 40-character hexadecimal SHA (SC-005)
- [ ] T014 Time a commit of up to 10 changed files after the first run and confirm the checks finish in under 10 seconds (SC-003)
- [ ] T015 Commit `.pre-commit-config.yaml` and the `specs/002-pre-commit-hooks/` files with message `chore(pre-commit): add basic pre-commit hooks`. Let the hooks run; never use `--no-verify`
- [ ] T016 Commit the fixes from the first full run (`stylua.toml` and any Lua files under `lua/` or `init.lua`) as a separate commit with message `style: apply pre-commit fixes` (spec assumption: fixes in a separate commit)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: T003 needs nothing. T004 needs T001 and T003.
- **User Story 1 (Phase 3)**: Needs Phase 2.
- **User Story 2 (Phase 4)**: Needs Phase 2 and T002.
- **User Story 3 (Phase 5)**: Needs the stories whose checks it must run (US1 and US2 for a full check).
- **Polish (Phase 6)**: Needs all stories. T016 comes after T015 or before it, but each must be its own commit.

### User Story Dependencies

- **US1** and **US2** are independent. Both edit `.pre-commit-config.yaml`, so do them one after the other.
- **US3** has no configuration of its own. It validates the result of US1 and US2.

### Parallel Opportunities

- T001 and T002 run in parallel (different tools, no shared files).
- T003 runs in parallel with T001 and T002.
- All other tasks edit `.pre-commit-config.yaml` or depend on its result, so they run in sequence.

---

## Parallel Example: Setup

```bash
Task: "Install pre-commit 4.7.0 with uv"
Task: "Install StyLua 2.6.0 with cargo --locked"
Task: "Create .pre-commit-config.yaml with the pre-commit-hooks source"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (T001 only is required) and Phase 2.
2. Complete Phase 3.
3. Stop and validate with quickstart scenarios 2, 3, and 4.

### Incremental Delivery

1. Setup and Foundational: configuration file exists.
2. US1: file hygiene checks (MVP).
3. US2: Lua formatting.
4. US3: full on-demand validation.
5. Polish: verify pins and commit.

---

## Notes

- Never add `--no-verify` to a commit.
- If a hook fails on files that this feature did not touch, ask the user before you continue (CLAUDE.md).
- Keep scratch files from the quickstart scenarios out of all commits.
