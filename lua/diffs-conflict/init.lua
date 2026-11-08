local conflict = require('diffs-collection.conflict')
local highlights = require('diffs-collection.conflict_highlights')
local windows = require('diffs-collection.conflict_windows')

local M = {}

local function enabled()
  return require('diffs-collection.config').get_conflict() ~= false
end

---@param bufnr? integer
function M.attach(bufnr)
  if not enabled() then
    return
  end
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  highlights.apply()
  conflict.attach(bufnr)
  windows.refresh()
end

---@param bufnr? integer
function M.detach(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  conflict.detach(bufnr)
  windows.detach(bufnr)
end

for _, name in ipairs({
  'resolve_ours',
  'resolve_theirs',
  'resolve_both',
  'resolve_none',
  'goto_next',
  'goto_prev',
}) do
  M[name] = function(bufnr)
    if enabled() then
      conflict[name](bufnr or vim.api.nvim_get_current_buf())
    end
  end
end

function M.setup()
  if not enabled() then
    return
  end
  highlights.apply()
  local group = vim.api.nvim_create_augroup('diffs_collection_conflict', { clear = true })
  vim.api.nvim_create_autocmd('BufReadPost', {
    group = group,
    callback = function(event)
      M.attach(event.buf)
    end,
  })
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = highlights.apply,
  })
  vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter' }, {
    group = group,
    callback = windows.refresh,
  })
  vim.api.nvim_create_autocmd('OptionSet', {
    group = group,
    pattern = 'diff',
    callback = windows.refresh,
  })
  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = { 'DiffsConflictDetected', 'DiffsConflictResolved' },
    callback = windows.refresh,
  })
  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'DiffsConflictDetached',
    callback = function(event)
      windows.detach(event.data.bufnr)
    end,
  })
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      M.attach(bufnr)
    end
  end
end

return M
