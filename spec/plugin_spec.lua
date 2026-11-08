require('spec.helpers')

local function child(lines)
  local script = vim.fn.tempname() .. '.lua'
  vim.fn.writefile(lines, script)
  local result = vim.fn.system({
    vim.v.progpath,
    '--headless',
    '-u',
    'spec/minimal_init.lua',
    '-l',
    script,
  })
  local status = vim.v.shell_error
  vim.fn.delete(script)
  assert.are.equal(0, status, result)
end

describe('collection commands', function()
  it('compares escaped file paths through Ex and reloads changed content', function()
    child({
      'vim.g.diffs_conflict = false',
      "vim.cmd('runtime plugin/diffs-collection.lua')",
      'local dir = vim.fn.tempname()',
      "vim.fn.mkdir(dir, 'p')",
      "local left = dir .. '/old file.lua'",
      "local right = dir .. '/new file.lua'",
      "vim.fn.writefile({ 'local value = 1' }, left)",
      "vim.fn.writefile({ 'local value = 2' }, right)",
      "vim.cmd('Diff files ' .. vim.fn.fnameescape(left) .. ' ' .. vim.fn.fnameescape(right))",
      'local buf = vim.api.nvim_get_current_buf()',
      "local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\\n')",
      "assert(text:find('-local value = 1', 1, true), text)",
      "assert(text:find('+local value = 2', 1, true), text)",
      "vim.fn.writefile({ 'local value = 3' }, right)",
      "vim.cmd('edit')",
      "text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\\n')",
      "assert(text:find('+local value = 3', 1, true), text)",
      "assert(not text:find('+local value = 2', 1, true), text)",
      "vim.fn.delete(dir, 'rf')",
    })
  end)

  it('allows review without the Diff command or conflict attachment', function()
    child({
      'vim.g.diffs_diff = false',
      'vim.g.diffs_conflict = false',
      "vim.cmd('runtime plugin/diffs-collection.lua')",
      "assert(vim.fn.exists(':Diff') == 0)",
      "assert(vim.fn.exists(':Review') == 2)",
      'local path = vim.fn.tempname()',
      "vim.fn.writefile({ '<<<<<<< ours', 'old', '=======', 'new', '>>>>>>> theirs' }, path)",
      "vim.cmd('edit ' .. vim.fn.fnameescape(path))",
      "assert(package.loaded['diffs-collection.conflict'] == nil)",
      "assert(vim.fn.maparg('<Plug>(diffs-conflict-ours)', 'n') == '')",
      'vim.fn.delete(path)',
    })
  end)
end)
