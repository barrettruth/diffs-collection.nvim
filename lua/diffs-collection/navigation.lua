local M = {}

---@param changed boolean[]
---@return integer[]
function M.blocks(changed)
  local starts = {}
  for i, is_changed in ipairs(changed) do
    if is_changed and not changed[i - 1] then
      starts[#starts + 1] = i
    end
  end
  return starts
end

---@param starts integer[]
---@param direction integer
function M.goto_block(starts, direction)
  if #starts == 0 then
    return
  end
  local line = vim.api.nvim_win_get_cursor(0)[1]
  for _ = 1, vim.v.count1 do
    local target
    if direction > 0 then
      for _, start in ipairs(starts) do
        if start > line then
          target = start
          break
        end
      end
      line = target or starts[1]
    else
      for i = #starts, 1, -1 do
        if starts[i] < line then
          target = starts[i]
          break
        end
      end
      line = target or starts[#starts]
    end
  end
  vim.api.nvim_win_set_cursor(0, { line, 0 })
end

return M
