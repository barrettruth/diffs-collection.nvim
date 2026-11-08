local M = {}

---@param object? string
---@param opts? { layout?: string, vertical?: boolean }
function M.open(object, opts)
  opts = opts or {}
  local args = {}
  if opts.layout then
    args[#args + 1] = '++layout=' .. opts.layout
  end
  if object then
    args[#args + 1] = object
  end
  return require('diffs-collection.commands').diff(args, opts.vertical)
end

---@param left? string
---@param right? string
---@param opts? { layout?: string, vertical?: boolean }
function M.files(left, right, opts)
  opts = vim.tbl_extend('keep', opts or {}, { layout = 'unified' })
  return require('diffs-collection.commands').diff_files(left, right, opts)
end

function M.refresh()
  return require('diffs-collection.commands').refresh()
end

return M
