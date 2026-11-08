local M = {}

---@param bufnr? integer
function M.attach(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  local generated = require('diffs-collection.generated.highlight')
  if vim.b[bufnr].diffs_rail_width ~= nil then
    require('diffs').attach(bufnr, {
      hunks = generated.hunks,
      intra = not require('diffs-collection.difftastic').is_active(bufnr),
    })
    generated.apply(bufnr)
  else
    require('diffs').attach(bufnr)
  end
end

---@param bufnr? integer
function M.refresh(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  M.attach(bufnr)
  require('diffs').refresh(bufnr)
end

---@return diffs.HunkOpts
function M.get_highlight_opts()
  require('diffs-collection.palette').setup()
  return require('diffs').highlight_options()
end

---@param lines string[]
---@return diffs.IntraChanges?
function M.compute_intra_hunks(lines)
  return require('diffs').compute_intra_hunks(lines)
end

return M
