local M = {}

local conflict = require('diffs-collection.conflict')

local groups = { DiffAdd = true, DiffDelete = true, DiffChange = true, DiffText = true }
local override = 'DiffAdd:DiffsConflictDiffOff,DiffDelete:DiffsConflictDiffOff,'
  .. 'DiffChange:DiffsConflictDiffOff,DiffText:DiffsConflictDiffOff'

---@type table<integer, { previous: string, applied: string }>
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
    if vim.wo[win].winhighlight == saved.applied then
      vim.wo[win].winhighlight = saved.previous
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
      local previous = vim.wo[win].winhighlight
      local mappings = {}
      for mapping in previous:gmatch('[^,]+') do
        if not groups[mapping:match('^([^:]+):')] then
          mappings[#mappings + 1] = mapping
        end
      end
      mappings[#mappings + 1] = override
      local applied = table.concat(mappings, ',')
      windows[win] = { previous = previous, applied = applied }
      vim.wo[win].winhighlight = applied
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
