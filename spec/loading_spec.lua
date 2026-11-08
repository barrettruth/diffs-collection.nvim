require('spec.helpers')

describe('core and collection loading', function()
  it('loads both plugins without duplicate handlers or patch actions', function()
    local script = vim.fn.tempname() .. '.lua'
    vim.fn.writefile({
      'local ok, err = pcall(function()',
      'assert(vim.g.loaded_diffs and vim.g.loaded_diffs_collection)',
      "assert(vim.fn.exists(':Diff') == 2 and vim.fn.exists(':Review') == 2)",
      "local handlers = vim.api.nvim_get_autocmds({ event = 'BufReadCmd', pattern = 'diffs://*' })",
      'assert(#handlers == 1, vim.inspect(handlers))',
      'vim.api.nvim_buf_set_lines(0, 0, -1, false, {',
      "  'diff --git a/file.lua b/file.lua', '--- a/file.lua', '+++ b/file.lua',",
      "  '@@ -1 +1 @@', '-local value = 1', '+local value = 2',",
      '})',
      "vim.bo.filetype = 'diff'",
      "require('diffs').attach(0)",
      "require('diffs').refresh(0)",
      "for _, mode in ipairs({ 'n', 'x' }) do",
      '  for _, map in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do',
      "    assert(map.lhs ~= 'dp' and map.lhs ~= 'do', vim.inspect(map))",
      '  end',
      'end',
      'end)',
      "if not ok then io.stderr:write(tostring(err)); vim.cmd('cquit') end",
      "vim.cmd('qa!')",
    }, script)
    local output = vim.fn.system({
      vim.v.progpath,
      '--headless',
      '-u',
      'scripts/dev_init.lua',
      '-c',
      'luafile ' .. vim.fn.fnameescape(script),
    })
    local status = vim.v.shell_error
    vim.fn.delete(script)
    assert.are.equal(0, status, output)
  end)
end)
