local config = require('diffs-collection.config')
local core = require('diffs-collection.core')

local M = {
  attach = core.attach,
  refresh = core.refresh,
  invalidate_attached = core.invalidate_attached,
  get_highlight_opts = core.get_highlight_opts,
  configure = core.configure,
  attach_diff = core.attach_diff,
  detach_diff = core.detach_diff,
  _test = core._test,
}

---@return table
function M.get_view_config()
  return config.get_diff() or { default_layout = 'unified' }
end

---@return boolean|table
function M.get_difftastic_config()
  local diff = config.get_diff()
  return diff and diff.difftastic or false
end

---@return false|table
function M.get_conflict_config()
  return config.get_conflict()
end

---@return boolean
function M.get_fugitive_config()
  return config.get_diff() ~= false
end

return M
