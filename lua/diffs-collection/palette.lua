local M = {}

local function apply()
  local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  local nr = vim.api.nvim_get_hl(0, { name = 'LineNr', link = false })
  local add = vim.api.nvim_get_hl(0, { name = 'DiffsAdd', link = false })
  local delete = vim.api.nvim_get_hl(0, { name = 'DiffsDelete', link = false })
  local plus = vim.api.nvim_get_hl(0, { name = 'diffAdded', link = false })
  local minus = vim.api.nvim_get_hl(0, { name = 'diffRemoved', link = false })
  local dark = vim.o.background ~= 'light'
  local add_fg = plus.fg or (dark and 0x80d080 or 0x206020)
  local del_fg = minus.fg or (dark and 0xd08080 or 0x802020)
  for name, attrs in pairs({
    DiffsRail = { fg = normal.fg, bg = normal.bg, nocombine = true },
    DiffsRailNr = { fg = nr.fg or normal.fg, bg = normal.bg, nocombine = true },
    DiffsAddRailNr = { fg = add_fg, bg = add.bg, nocombine = true },
    DiffsDeleteRailNr = { fg = del_fg, bg = delete.bg, nocombine = true },
    DiffsAddBar = { fg = add_fg, bg = add.bg },
    DiffsDeleteBar = { fg = del_fg, bg = delete.bg },
    DiffsAddCount = { fg = add_fg },
    DiffsDeleteCount = { fg = del_fg },
  }) do
    attrs.default = true
    vim.api.nvim_set_hl(0, name, attrs)
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup('diffs_collection_palette', { clear = false })
  if #vim.api.nvim_get_autocmds({ group = group }) == 0 then
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = group,
      callback = function()
        vim.schedule(apply)
      end,
    })
  end
  require('diffs').highlight_options()
  apply()
end

return M
