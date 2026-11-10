# Quickstart Validation: Basic Pre-Commit Hooks

## Prerequisites

- Python 3.11 or later, `uv`, and `cargo` on `PATH`.
- Tools installed and enabled as given in the [command contract](contracts/hook-config.md#command-contract).

## Scenario 1: Clean repository passes (SC-004, FR-010)

```sh
pre-commit run --all-files
```

Expected: every check prints `Passed` or `Skipped`. Exit code `0`.

## Scenario 2: Trailing whitespace is fixed (User Story 1)

```sh
printf 'local x = 1   \n' > scratch.lua && git add scratch.lua
git commit -m test
```

Expected: `trailing whitespace` prints `Failed - files were modified by this hook` and names `scratch.lua`. The commit is blocked. `scratch.lua` has no trailing spaces.

## Scenario 3: Invalid JSON is rejected (User Story 1)

```sh
printf '{"a": }\n' > scratch.json && git add scratch.json
git commit -m test
```

Expected: `check json` fails and names `scratch.json`. The commit is blocked.

## Scenario 4: Merge conflict marker is rejected (User Story 1)

Stage a file with a line that starts with `<<<<<<< `, then commit.

Expected: `check for merge conflicts` fails. The commit is blocked.

## Scenario 5: Lua formatting is enforced (User Story 2)

```sh
printf 'local x = {1,2,3}\nif x then\n        print(x)\nend\n' > scratch.lua && git add scratch.lua
git commit -m test
```

Expected: `StyLua (system)` reports modified files. The commit is blocked. `scratch.lua` uses 2-space indentation.

## Scenario 6: Missing formatter fails clearly (edge case)

Run `pre-commit run stylua-system --all-files` with `stylua` removed from `PATH`.

Expected: the check fails with `Executable \`stylua\` not found`.

## Scenario 7: Pins are exact (SC-005)

```sh
grep -E '^\s+rev:' .pre-commit-config.yaml
```

Expected: every `rev` is a 40-character hexadecimal SHA.

## Scenario 8: Invalid YAML is rejected (User Story 1)

```sh
printf 'a: [1, 2\n' > scratch.yaml && git add scratch.yaml
git commit -m test
```

Expected: `check yaml` fails and names `scratch.yaml`. The commit is blocked.

## Scenario 9: Invalid TOML is rejected (User Story 1)

```sh
printf 'a = \n' > scratch.toml && git add scratch.toml
git commit -m test
```

Expected: `check toml` fails and names `scratch.toml`. The commit is blocked.

## Scenario 10: Large file is rejected (FR-005)

```sh
head -c 600000 /dev/zero > scratch.bin && git add scratch.bin
git commit -m test
```

Expected: `check for added large files` fails and names `scratch.bin` with its size. The commit is blocked.

## Cleanup

Remove the scratch files and unstage them after each scenario.
