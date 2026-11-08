local M = {}

---@param name string
---@param defaults table
---@return table|false
local function component(name, defaults)
  local value = vim.g[name]
  if value == false then
    return false
  end
  vim.validate(name, value, 'table', true)
  return vim.tbl_deep_extend('force', defaults, value or {})
end

---@return table|false
function M.get_diff()
  return component('diffs_diff', { default_layout = 'unified', difftastic = false })
end

---@return table|false
function M.get_review()
  return component('diffs_review', { layout = 'unified' })
end

---@return table|false
function M.get_conflict()
  return component('diffs_conflict', {})
end

return M
