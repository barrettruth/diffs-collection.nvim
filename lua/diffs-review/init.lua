local M = {}

local function command(name)
  return function(...)
    return require('diffs-collection.commands')[name](...)
  end
end

M.open = command('open_review')
M.files = command('review_files')
M.current = command('review_current')
M.goto_file = command('review_goto')
M.next_file = command('review_next_file')
M.prev_file = command('review_prev_file')
M.toggle_layout = command('review_toggle_layout')
M.select_file = command('select_review_file')

return M
