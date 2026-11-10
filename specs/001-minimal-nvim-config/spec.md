# Feature Specification: Minimal Neovim Configuration Rebuild

**Feature Branch**: `worktree-001-minimal-nvim-config`

**Created**: 2026-11-10

**Status**: Draft

**Input**: User description: "Rebuild my Neovim configuration from scratch, so it is simple and has only the features I need. Remove the dependency on the LazyVim distribution. Use the built-in package management of Neovim 0.12 and later. Keep native features. Support TypeScript, JavaScript, Terraform, YAML, Helm, Python, Ansible, Markdown, JSON, and Git. Use space as leader key. Add a file manager with minimal navigation settings and a cheat sheet. Add color themes, icons, and a terminal overlay."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Own and understand the configuration (Priority: P1)

The user opens the editor. The editor starts with a configuration that the user wrote and owns. The configuration does not depend on a third-party distribution or a third-party plugin manager. The user can read the full configuration and understand each part of it.

**Why this priority**: This is the main reason for the rebuild. All other stories depend on this base.

**Independent Test**: Start the editor on a clean machine with only the new configuration. Confirm that the editor starts without errors, that no distribution is loaded, and that extensions are installed by the built-in package manager.

**Acceptance Scenarios**:

1. **Given** a clean machine with the new configuration, **When** the user starts the editor for the first time, **Then** the editor installs all declared extensions and starts without errors.
2. **Given** the new configuration, **When** the user searches the configuration for references to the old distribution or the old plugin manager, **Then** no references exist.
3. **Given** the new configuration, **When** the user reads each configuration file, **Then** each file has one clear purpose that the file name shows.
4. **Given** an installed configuration, **When** the user runs the update command for extensions, **Then** the editor updates extensions and records the exact installed versions in a lock file.

---

### User Story 2 - Edit code with language support (Priority: P1)

The user opens a file in one of the supported languages. The editor gives syntax highlighting, diagnostics, go-to-definition, hover documentation, completion, and formatting for that language.

**Why this priority**: The editor must support the daily work of the user. Without language support, the configuration has no practical value.

**Independent Test**: Open one sample file for each supported language. Confirm highlighting, diagnostics, navigation, completion, and formatting work for each one.

**Acceptance Scenarios**:

1. **Given** a TypeScript or JavaScript file, **When** the user opens it, **Then** the editor shows highlighting, diagnostics, completion, hover, go-to-definition, and can format the file.
2. **Given** a Terraform file, **When** the user saves it, **Then** the editor formats it with the standard Terraform format.
3. **Given** a YAML file, **When** the user opens it, **Then** the editor validates it against a matching public schema when one exists.
4. **Given** a Helm chart template, **When** the user opens it, **Then** the editor recognizes it as a Helm template and not as plain YAML.
5. **Given** an Ansible playbook or role file, **When** the user opens it, **Then** the editor recognizes it as Ansible and gives Ansible diagnostics and completion.
6. **Given** a Python, Markdown, or JSON file, **When** the user opens it, **Then** the editor shows highlighting, diagnostics, and completion where the language supports them.
7. **Given** a file of an unsupported language, **When** the user opens it, **Then** the editor opens it with native features only and shows no errors.

---

### User Story 3 - Navigate files with a file manager and cheat sheet (Priority: P2)

The user opens a file manager from the editor. The user moves through directories, opens files, and creates, renames, moves, and deletes files. The user opens a cheat sheet that lists the file manager keys.

**Why this priority**: File navigation is frequent. It is less critical than editing, because native commands can open files.

**Independent Test**: Open the file manager, do each file operation, and open the cheat sheet. Confirm each action works.

**Acceptance Scenarios**:

1. **Given** an open buffer, **When** the user presses the file manager key, **Then** the file manager opens at the directory of the current file.
2. **Given** an open file manager, **When** the user creates, renames, moves, or deletes a file, **Then** the change applies to the file system.
3. **Given** an open file manager, **When** the user presses the cheat sheet key, **Then** the editor shows all file manager keys with a short description of each.
4. **Given** an open file manager, **When** the user presses the close key, **Then** the file manager closes and the previous buffer shows.

---

### User Story 4 - Work with Git (Priority: P2)

The user edits files in a Git repository. The editor shows which lines changed. The user can see who changed a line and can move between changes. The user can stage, commit, read the log, and look at diffs without leaving the editor.

**Why this priority**: Git is part of daily work. Basic Git work is possible from a terminal, so this story is second to editing.

**Independent Test**: Open a changed file in a Git repository. Confirm change markers, line blame, and navigation between changes. Open the Git interface, stage a change, commit it, and open the log and a diff.

**Acceptance Scenarios**:

1. **Given** a changed file in a Git repository, **When** the user opens it, **Then** the editor marks added, changed, and deleted lines.
2. **Given** a changed file, **When** the user presses the next-change or previous-change key, **Then** the cursor moves to that change.
3. **Given** a line in a tracked file, **When** the user requests blame, **Then** the editor shows the author, date, and commit message for that line.
4. **Given** a changed section, **When** the user requests to preview or reset it, **Then** the editor shows or reverts that section.
5. **Given** a Git repository, **When** the user opens the Git interface, **Then** the editor shows the status of the repository and lets the user stage and unstage files and sections.
6. **Given** staged changes, **When** the user requests a commit from the Git interface, **Then** the user writes a message and the commit is created.
7. **Given** a Git repository, **When** the user requests the log, **Then** the editor shows the commit history and lets the user open the diff of a commit.
8. **Given** a changed file, **When** the user requests a diff view, **Then** the editor shows the working version and the committed version side by side.
9. **Given** an open Git interface, **When** the user selects a file to edit, **Then** the file opens in the current editor session, not in a new editor, and the Git interface hides.

---

### User Story 5 - Use a terminal overlay (Priority: P3)

The user opens a terminal that floats over the current editor content. The user runs commands, then hides the terminal and returns to editing. The terminal session stays alive when hidden.

**Why this priority**: The user needs it only sometimes. An external terminal is an alternative.

**Independent Test**: Open the terminal overlay, run a command, hide it, and open it again. Confirm the previous output is still there.

**Acceptance Scenarios**:

1. **Given** any editor state, **When** the user presses the terminal key, **Then** a terminal opens in a floating window over the editor.
2. **Given** an open terminal overlay, **When** the user presses the terminal key again, **Then** the overlay hides and the editor shows the previous buffer.
3. **Given** a hidden terminal overlay, **When** the user opens it again, **Then** the same session with its previous output shows.
4. **Given** an open terminal overlay, **When** the user presses the key to leave terminal mode, **Then** the user can scroll and copy the terminal output.

---

### User Story 6 - Appearance: color themes and icons (Priority: P3)

The user sees a dark color theme and file type icons. The user can switch to a different installed theme during a session.

**Why this priority**: Appearance improves comfort but does not block work.

**Independent Test**: Start the editor and confirm the default theme and icons. Switch the theme and confirm the change.

**Acceptance Scenarios**:

1. **Given** a new editor session, **When** the editor starts, **Then** the default theme shows.
2. **Given** a running session, **When** the user selects a different installed theme, **Then** the editor applies it immediately.
3. **Given** the file manager or another file list, **When** it shows files, **Then** each file shows an icon for its type.
4. **Given** a terminal without an icon font, **When** the editor starts, **Then** the editor still works and shows no errors.

---

### Edge Cases

- What happens when a language server or formatter for a supported language is not installed? The editor opens the file, shows a single clear message that names the missing tool, and continues with native features.
- What happens when there is no network on first start? The editor starts with native features, reports which extensions are not installed, and installs them on the next start with network.
- What happens when a YAML file is both a Helm template and a Kubernetes manifest? The Helm rule takes priority inside a Helm chart directory.
- What happens when a YAML file is an Ansible file? The Ansible rule takes priority for files in Ansible project locations (playbooks, roles, inventories).
- What happens when the editor runs under WSL? The system clipboard works with the Windows clipboard.
- What happens when the editor version is older than 0.12? The editor shows a clear message that states the minimum version.
- What happens when the user opens a file outside a Git repository? Git features stay inactive and show no errors.
- What happens when LazyGit is not installed? The Git interface key shows one message that names LazyGit. The other Git features still work.

## Requirements *(mandatory)*

### Functional Requirements

#### Base

- **FR-001**: The configuration MUST NOT depend on the LazyVim distribution or the lazy.nvim plugin manager.
- **FR-002**: The configuration MUST use the built-in package management of the editor to install and update extensions.
- **FR-003**: The configuration MUST record the exact version of each installed extension in a lock file that is part of the repository.
- **FR-004**: The configuration MUST use native editor features wherever a native feature gives the required behavior. An extension MUST be added only when no native feature gives that behavior.
- **FR-005**: The configuration MUST require editor version 0.12 or later and MUST show a clear message on older versions.
- **FR-006**: The configuration MUST be split into files with one purpose each (for example: options, keymaps, language support, appearance).

#### Keys

- **FR-007**: The leader key MUST be space. The local leader key MUST be backslash.
- **FR-008**: The configuration MUST keep these existing custom keys: `+` increments a number, `-` decrements a number, `Ctrl-a` selects the full buffer, and `Ctrl-w` plus an arrow key resizes the window.
- **FR-009**: Each custom key MUST have a description that the editor can show.

#### Language support

- **FR-010**: The editor MUST give syntax highlighting for TypeScript, JavaScript, Terraform (including HCL and variable files), YAML, Helm templates, Python, Ansible, Markdown, JSON, Git commit messages, and Git config files.
- **FR-011**: The editor MUST give diagnostics, completion, hover documentation, go-to-definition, find-references, rename, and code actions for TypeScript, JavaScript, Terraform, YAML, Helm, Python, Ansible, Markdown, and JSON.
- **FR-012**: The editor MUST format files on request for each supported language that has a formatter. Terraform files MUST use the standard Terraform format.
- **FR-013**: The editor MUST validate YAML and JSON files against matching public schemas.
- **FR-014**: The editor MUST detect Helm templates and Ansible files as their own file types and not as plain YAML.
- **FR-015**: The editor MUST use native completion and MUST NOT add a separate completion extension unless native completion cannot give completion from language servers.
- **FR-016**: The configuration MUST NOT install external language tools (language servers, formatters). The user installs them with system tools (for example: npm, pip, the system package manager). The configuration MUST only use tools that it finds on the system path.

#### File manager

- **FR-017**: The configuration MUST include one file manager that opens at the directory of the current file.
- **FR-018**: The file manager MUST support create, rename, move, copy, and delete of files and directories.
- **FR-019**: The file manager MUST show hidden files on request.
- **FR-020**: The configuration MUST include a cheat sheet that lists all file manager keys with a short description. The user MUST be able to open it from inside the file manager.

#### Git

- **FR-021**: The editor MUST mark added, changed, and deleted lines in files under Git.
- **FR-022**: The editor MUST let the user move to the next and previous change, preview a change, reset a change, and show blame for a line.
- **FR-022a**: The editor MUST give a Git interface that shows repository status and lets the user stage, unstage, commit, and read the log. The editor MUST show a side-by-side diff of the current file.
- **FR-022b**: The Git interface MUST be LazyGit, opened in a floating window from the editor. A file that the user opens from LazyGit MUST open in the current editor session.

#### Terminal

- **FR-023**: The editor MUST open a terminal in a floating window with one key and hide it with the same key.
- **FR-024**: The terminal session MUST stay alive while hidden.
- **FR-025**: The user MUST be able to leave terminal mode with one key to scroll and copy output.

#### Appearance

- **FR-026**: The default color theme MUST be Solarized Osaka, the current theme of the user.
- **FR-027**: The configuration MUST include at least one more installed theme, and the user MUST be able to switch themes during a session.
- **FR-028**: The configuration MUST show file type icons in the file manager and other file lists.

#### Platform

- **FR-029**: Under WSL, the system clipboard MUST use the Windows clipboard.

### Key Entities

- **Configuration module**: One file with one purpose (for example: options, keymaps, language support). It has a name and a scope.
- **Extension**: A third-party addition that the built-in package manager installs. It has a source, a pinned version, and a reason for inclusion.
- **Lock file**: The record of the exact version of each installed extension.
- **Language profile**: The set of support for one language: file type detection, highlighting, language server, formatter, and schemas.
- **Cheat sheet**: The list of file manager keys with descriptions.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The editor starts to a usable state in less than 100 ms on the user's machine after the first install.
- **SC-002**: The configuration has 15 or fewer third-party extensions in total.
- **SC-003**: The user can explain the purpose of each configuration file and each extension without outside help.
- **SC-004**: For each of the 10 supported languages and tools, a sample file opens with highlighting and, where FR-011 applies, with working diagnostics and completion. Pass rate: 10 of 10.
- **SC-005**: A first start on a clean machine with network completes installation with zero errors.
- **SC-006**: The user can find any file manager key in the cheat sheet in less than 10 seconds.
- **SC-007**: The user can open the terminal overlay, run a command, and return to the editor in less than 3 seconds.
- **SC-008**: The configuration contains zero references to the old distribution or the old plugin manager.

## Assumptions

- The user has Neovim 0.12 or later.
- The user works mainly under WSL on Linux, as the current configuration shows.
- The terminal of the user has a font with icon glyphs (a Nerd Font). Without it, icons show as fallback characters.
- Git and LazyGit are installed on the system.
- The user installs language servers and formatters for all supported languages before use. The Edge Cases section defines the behavior when a tool is missing.
- Native features cover fuzzy file search, commenting, snippets, completion, and diagnostics navigation. No separate extension is added for these unless a native feature is missing.
- The current custom keys and the WSL clipboard setup move to the new configuration without change.
- The old configuration files (LazyVim files, lazy.nvim lock file, `lazyvim.json`, `.neoconf.json`) are removed as part of the rebuild.
- A status line, a start screen, and a key-hint popup are out of scope. The native status line is used.
- Debugging (debug adapters) and test runners are out of scope.
- Linting beyond what language servers give is out of scope.
