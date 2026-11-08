local M = {}

-- Private diffs.nvim imports are restricted to this adapter. The development
-- environment pins the core revision until its highlighting API is public.
local function runtime()
  return require('diffs.runtime')
end

---@param bufnr? integer
function M.attach(bufnr)
  require('diffs').attach(bufnr)
end

---@param bufnr? integer
function M.refresh(bufnr)
  require('diffs').refresh(bufnr)
end

function M.invalidate_attached()
  runtime().invalidate_attached()
end

---@return diffs.HunkOpts
function M.get_highlight_opts()
  local backend = runtime()
  -- The pinned backend initializes highlight groups through its config getters.
  backend.get_view_config()
  return backend.get_highlight_opts()
end

---@param config diffs.Config
function M.configure(config)
  runtime().configure(config)
end

function M.attach_diff()
  runtime().attach_diff()
end

function M.detach_diff()
  runtime().detach_diff()
end

---@param lines string[]
---@return diffs.IntraChanges?
function M.compute_intra_hunks(lines)
  return require('diffs.diff').compute_intra_hunks(lines)
end

---@return diffs.DiffOpts
function M.resolve_diffopt()
  return require('diffs.diffopt').resolve()
end

---@return diffs.InlineMode
function M.inline()
  return require('diffs.diffopt').inline()
end

---@return diffs.DiffOpts
function M.vim_diff_opts()
  return require('diffs.diffopt').vim_diff_opts()
end

---@return string[]
function M.git_flags()
  return require('diffs.diffopt').git_flags()
end

-- Moved behavior specs inspect the backend cache through this adapter.
M._test = setmetatable({}, {
  __index = function(_, key)
    return runtime()._test[key]
  end,
})

return M
