-- Usage: nvim --headless -c "luafile scripts/update-deps.lua"
-- Moves lazy-lock.json and mason-lock.json to the newest versions that are older than the cooldown.
-- Requires an authenticated `gh` CLI.

local Config = require("lazy.core.config")

local COOLDOWN_DAYS = tonumber(vim.env.DEPS_COOLDOWN_DAYS) or 7
local REPORT_PATH = vim.env.DEPS_REPORT or (vim.fn.stdpath("cache") .. "/deps-report.md")
local LAZY_LOCKFILE = Config.options.lockfile
local MASON_LOCKFILE = vim.fn.stdpath("config") .. "/mason-lock.json"
local MASON_REGISTRY_REPO = "mason-org/mason-registry"
local CUTOFF = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time() - COOLDOWN_DAYS * 24 * 60 * 60)
local PAGE_SIZE = 100

-- Files that can run code when a plugin is installed or built.
local INSTALL_TIME_FILE_PATTERNS = {
  "^build%.lua$",
  "^build/",
  "Makefile$",
  "%.rockspec$",
  "%.sh$",
  "^Cargo%.toml$",
  "^build%.rs$",
  "^package%.json$",
}

local function gh_api(endpoint)
  local result = vim.system({ "gh", "api", endpoint }, { text = true }):wait()
  if result.code ~= 0 then
    error(("gh api %s failed: %s"):format(endpoint, result.stderr))
  end
  return vim.json.decode(result.stdout, { luanil = { object = true, array = true } })
end

local function read_json(path)
  return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
end

local function write_file(path, content)
  local file = assert(io.open(path, "wb"))
  file:write(content)
  file:close()
end

local function is_null_sha(sha)
  return sha == nil or sha:match("^0+$") ~= nil
end

local function github_repo(url)
  return url:match("^https://github%.com/(.-)%.git$") or url:match("^https://github%.com/([^/]+/[^/]+)/?$")
end

local function warn(message)
  if vim.env.GITHUB_ACTIONS then
    io.stdout:write("::warning::" .. message .. "\n")
  else
    io.stdout:write("warning: " .. message .. "\n")
  end
end

-- Commit dates are set by the author and can be faked, so the cooldown uses the time
-- at which GitHub received each push, from the repository activity API.
local function cooled_down_commit(repo, branch)
  local activity = gh_api(("repos/%s/activity?ref=refs/heads/%s&per_page=%d"):format(repo, branch, PAGE_SIZE))
  table.sort(activity, function(a, b)
    return a.timestamp > b.timestamp
  end)

  for _, event in ipairs(activity) do
    if event.timestamp <= CUTOFF then
      if is_null_sha(event.after) then
        return nil, ("branch %s was deleted before the cutoff"):format(branch)
      end
      return event.after
    end
  end

  if #activity == PAGE_SIZE then
    return nil, ("more than %d pushes inside the cooldown window"):format(PAGE_SIZE)
  end

  if #activity > 0 then
    local before_oldest_push = activity[#activity].before
    if is_null_sha(before_oldest_push) then
      return nil, ("branch %s was created inside the cooldown window"):format(branch)
    end
    return before_oldest_push
  end

  local head = gh_api(("repos/%s/commits/%s"):format(repo, branch))
  if head.commit.committer.date > CUTOFF then
    return nil, "no push activity recorded, and the branch head is newer than the cutoff"
  end
  return head.sha
end

local function commit_authors(commits)
  local seen, authors = {}, {}
  for _, commit in ipairs(commits) do
    local author = (commit.author and commit.author.login) or commit.commit.author.name
    if not seen[author] then
      seen[author] = true
      table.insert(authors, author)
    end
  end
  table.sort(authors)
  return authors
end

local function install_time_files(files)
  local matches = {}
  for _, file in ipairs(files or {}) do
    local basename = vim.fs.basename(file.filename)
    for _, pattern in ipairs(INSTALL_TIME_FILE_PATTERNS) do
      if file.filename:match(pattern) or basename:match(pattern) then
        table.insert(matches, file.filename)
        break
      end
    end
  end
  return matches
end

local function update_plugin(name, locked, report)
  local plugin = Config.plugins[name] or Config.spec.disabled[name]
  if not plugin then
    table.insert(report.skipped, { name = name, reason = "not in the current config" })
    return
  end

  local repo = github_repo(plugin.url or "")
  if not repo then
    table.insert(report.skipped, { name = name, reason = "not hosted on GitHub" })
    return
  end

  local candidate, reason = cooled_down_commit(repo, locked.branch)
  if not candidate then
    table.insert(report.skipped, { name = name, reason = reason })
    return
  end
  if candidate == locked.commit then
    return
  end

  local comparison = gh_api(("repos/%s/compare/%s...%s"):format(repo, locked.commit, candidate))
  if comparison.status == "behind" or comparison.status == "identical" then
    return
  end
  if comparison.status ~= "ahead" then
    table.insert(report.blocked, { name = name, status = comparison.status, url = comparison.html_url })
    return
  end

  table.insert(report.updated, {
    name = name,
    from = locked.commit,
    to = candidate,
    url = comparison.html_url,
    commit_count = comparison.ahead_by,
    authors = commit_authors(comparison.commits),
    install_time_files = install_time_files(comparison.files),
    has_build_step = plugin.build ~= nil,
  })
  locked.commit = candidate
end

local function write_lazy_lockfile(lock)
  local names = vim.tbl_keys(lock)
  table.sort(names)
  local lines = {}
  for _, name in ipairs(names) do
    table.insert(lines, ([[  %q: { "branch": %q, "commit": %q }]]):format(name, lock[name].branch, lock[name].commit))
  end
  write_file(LAZY_LOCKFILE, "{\n" .. table.concat(lines, ",\n") .. "\n}\n")
end

local function cooled_down_registry_release()
  for page = 1, 10 do
    local releases = gh_api(("repos/%s/releases?per_page=%d&page=%d"):format(MASON_REGISTRY_REPO, PAGE_SIZE, page))
    for _, release in ipairs(releases) do
      if not release.draft and not release.prerelease and release.published_at <= CUTOFF then
        return release
      end
    end
    if #releases < PAGE_SIZE then
      break
    end
  end
  error("no Mason registry release is older than the cutoff " .. CUTOFF)
end

local function update_mason_registry(report)
  local lock = read_json(MASON_LOCKFILE)
  local current = gh_api(("repos/%s/releases/tags/%s"):format(MASON_REGISTRY_REPO, lock.registry))
  local candidate = cooled_down_registry_release()
  if candidate.published_at <= current.published_at then
    return
  end
  report.mason = { from = lock.registry, to = candidate.tag_name, url = candidate.html_url }
  write_file(MASON_LOCKFILE, ('{\n  "registry": %q\n}\n'):format(candidate.tag_name))
end

local function short(sha)
  return sha:sub(1, 7)
end

local function table_cell(text)
  return (text:gsub("|", "\\|"))
end

local function render_report(report)
  local lines = {
    "## Dependency update",
    "",
    ("Cooldown: %d days. Only versions that GitHub received before %s are used."):format(COOLDOWN_DAYS, CUTOFF),
    "",
  }

  if #report.blocked > 0 then
    vim.list_extend(lines, { "### Blocked: history rewritten", "" })
    for _, entry in ipairs(report.blocked) do
      table.insert(
        lines,
        ("- `%s`: comparison status `%s`. Review manually: %s"):format(entry.name, entry.status, entry.url)
      )
    end
    table.insert(lines, "")
  end

  if #report.updated > 0 then
    vim.list_extend(lines, {
      "### Updated plugins",
      "",
      "| Plugin | Change | Commits | Authors | Review flags |",
      "| --- | --- | --- | --- | --- |",
    })
    for _, entry in ipairs(report.updated) do
      local flags = {}
      if entry.has_build_step then
        table.insert(flags, "has build step")
      end
      if #entry.install_time_files > 0 then
        table.insert(flags, "install-time files: " .. table.concat(entry.install_time_files, ", "))
      end
      table.insert(
        lines,
        ("| `%s` | [`%s...%s`](%s) | %d | %s | %s |"):format(
          entry.name,
          short(entry.from),
          short(entry.to),
          entry.url,
          entry.commit_count,
          table_cell(table.concat(entry.authors, ", ")),
          table_cell(table.concat(flags, "; "))
        )
      )
    end
    table.insert(lines, "")
  end

  if report.mason then
    vim.list_extend(lines, {
      "### Mason registry",
      "",
      ("[`%s`](%s) replaces `%s`. Run `:MasonRestore` after you pull."):format(
        report.mason.to,
        report.mason.url,
        report.mason.from
      ),
      "",
    })
  end

  if #report.skipped > 0 then
    vim.list_extend(lines, { "### Skipped", "" })
    for _, entry in ipairs(report.skipped) do
      table.insert(lines, ("- `%s`: %s"):format(entry.name, entry.reason))
    end
    table.insert(lines, "")
  end

  return table.concat(lines, "\n")
end

local function main()
  local report = { updated = {}, blocked = {}, skipped = {} }

  local lock = read_json(LAZY_LOCKFILE)
  local names = vim.tbl_keys(lock)
  table.sort(names)
  for _, name in ipairs(names) do
    update_plugin(name, lock[name], report)
  end
  write_lazy_lockfile(lock)

  update_mason_registry(report)

  for _, entry in ipairs(report.blocked) do
    warn(("%s: history rewritten (%s), see %s"):format(entry.name, entry.status, entry.url))
  end
  for _, entry in ipairs(report.skipped) do
    warn(("%s skipped: %s"):format(entry.name, entry.reason))
  end

  local rendered = render_report(report)
  write_file(REPORT_PATH, rendered)
  io.stdout:write(rendered .. "\n")
end

local ok, err = xpcall(main, debug.traceback)
if ok then
  vim.cmd("qall!")
else
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
