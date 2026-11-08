local M = {}

local conflict = require('diffs-collection.conflict')

---@type table<integer, { previous: integer, applied: integer }>
local windows = {}

---@param win integer
---@return boolean
local function has_conflict(win)
  if not vim.wo[win].diff then
    return false
  end
  local bufnr = vim.api.nvim_win_get_buf(win)
  if vim.bo[bufnr].buftype ~= '' then
    return false
  end
  return #vim.api.nvim_buf_get_extmarks(bufnr, conflict.get_namespace(), 0, -1, { limit = 1 }) > 0
end

---@param win integer
local function restore(win)
  local saved = windows[win]
  if saved and vim.api.nvim_win_is_valid(win) then
    if vim.api.nvim_get_hl_ns({ winid = win }) == saved.applied then
      vim.api.nvim_win_set_hl_ns(win, saved.previous)
    end
  end
  windows[win] = nil
end

function M.refresh()
  for win in pairs(windows) do
    if not vim.api.nvim_win_is_valid(win) or not has_conflict(win) then
      restore(win)
    end
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if has_conflict(win) and not windows[win] then
      local previous = vim.api.nvim_get_hl_ns({ winid = win })
      local applied = vim.api.nvim_create_namespace('')
      local effective = previous == -1 and vim.api.nvim_get_hl_ns({}) or previous
      if effective > 0 then
        for name, definition in pairs(vim.api.nvim_get_hl(effective, {})) do
          vim.api.nvim_set_hl(applied, name, definition)
        end
      else
        for source, target in vim.wo[win].winhighlight:gmatch('([^:,]+):([^,]+)') do
          vim.api.nvim_set_hl(applied, source, { link = target })
        end
      end
      for _, name in ipairs({ 'DiffAdd', 'DiffDelete', 'DiffChange', 'DiffText' }) do
        vim.api.nvim_set_hl(applied, name, {})
      end
      windows[win] = { previous = previous, applied = applied }
      vim.api.nvim_win_set_hl_ns(win, applied)
    end
  end
end

---@param bufnr integer
function M.detach(bufnr)
  for win in pairs(windows) do
    if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) == bufnr then
      restore(win)
    end
  end
end

function M.clear()
  for win in pairs(windows) do
    restore(win)
  end
end

return M
