local M = {}

---@param color integer
---@param background integer
---@param alpha number
---@return integer
local function blend(color, background, alpha)
  local result = 0
  for _, shift in ipairs({ 0, 8, 16 }) do
    local channel = bit.band(bit.rshift(color, shift), 0xff)
    local base = bit.band(bit.rshift(background, shift), 0xff)
    result = bit.bor(result, bit.lshift(math.floor(channel * alpha + base * (1 - alpha)), shift))
  end
  return result
end

function M.apply()
  local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  local add = vim.api.nvim_get_hl(0, { name = 'DiffAdd', link = false })
  local change = vim.api.nvim_get_hl(0, { name = 'DiffChange', link = false })
  local text = vim.api.nvim_get_hl(0, { name = 'DiffText', link = false })
  local added = vim.api.nvim_get_hl(0, { name = 'diffAdded', link = false })
  local dark = vim.o.background ~= 'light'
  local background = normal.bg or (dark and 0x1a1a1a or 0xf0f0f0)
  local config = vim.g.diffs or {}
  local alpha = (config.highlights or {}).blend_alpha or 0.6
  local ours = blend(add.bg or (dark and 0x1a3a1a or 0xd0ffd0), background, alpha)
  local theirs = blend(change.bg or 0x3a3a4a, background, alpha)
  local base = blend(text.bg or 0x4a4a5a, background, math.max(alpha - 0.1, 0))
  local ours_fg = added.fg or add.fg or (dark and 0x80d080 or 0x206020)
  local theirs_fg = change.fg or text.fg or 0x80a0c0

  for name, attrs in pairs({
    DiffsConflictOurs = { bg = ours },
    DiffsConflictTheirs = { bg = theirs },
    DiffsConflictBase = { bg = base },
    DiffsConflictMarker = { fg = 0x808080, bold = true },
    DiffsConflictOursNr = { fg = ours_fg, bg = ours },
    DiffsConflictTheirsNr = { fg = theirs_fg, bg = theirs },
    DiffsConflictBaseNr = { fg = theirs_fg, bg = base },
    DiffsConflictDiffOff = {},
  }) do
    attrs.default = true
    vim.api.nvim_set_hl(0, name, attrs)
  end
end

return M
