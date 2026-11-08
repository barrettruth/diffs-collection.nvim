local M = {}

---@return diffs.DiffOpts
function M.resolve()
  return require('diffs').diff_options()
end

--- Effective intra-line granularity. 'diffopt' treats a missing `inline:` as
--- `simple`, so plugin surfaces resolve it the same way native diff windows do.
---@return diffs.InlineMode
function M.inline()
  return M.resolve().inline or 'simple'
end

--- Options to merge into a vim.diff()/vim.text.diff() call. inline is dropped:
--- it only shapes highlighting, and vim.diff() rejects keys it does not know.
---@return diffs.DiffOpts
function M.vim_diff_opts()
  local opts = M.resolve()
  opts.inline = nil
  return opts
end

--- Equivalent git diff flags for the resolved options. linematch has no git
--- counterpart and is omitted, and inline only shapes highlighting, not the
--- diff git is asked to produce.
---@return string[]
function M.git_flags()
  local opts = M.resolve()
  local flags = {}
  if opts.ignore_whitespace then
    flags[#flags + 1] = '--ignore-all-space'
  end
  if opts.ignore_whitespace_change then
    flags[#flags + 1] = '--ignore-space-change'
  end
  if opts.ignore_whitespace_change_at_eol then
    flags[#flags + 1] = '--ignore-space-at-eol'
  end
  if opts.ignore_blank_lines then
    flags[#flags + 1] = '--ignore-blank-lines'
  end
  if opts.algorithm then
    flags[#flags + 1] = '--diff-algorithm=' .. opts.algorithm
  end
  return flags
end

return M
