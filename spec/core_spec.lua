require('spec.helpers')

describe('core highlighting integration', function()
  it('highlights a split opened before any unified view', function()
    local script = vim.fn.tempname() .. '.lua'
    vim.fn.writefile(
      vim.split(
        [[
require('spec.helpers')
local git = require('diffs-collection.git')
local content = require('diffs-collection.content')
local render = require('diffs-collection.render')
local spec = require('diffs-collection.spec')
local split = require('diffs-collection.split')
local old_lines = content.from_raw_lines({ 'local value = 1', '' })
local new_lines = content.from_raw_lines({ 'local value = 2', '' })
git.get_index_content = function() return old_lines end
git.get_working_content = function() return new_lines end
local panes = assert(split.open({
  repo_root = '/tmp',
  spec = spec.index_to_worktree('file.lua'),
  filetype = 'lua',
  diff_lines = render.unified_lines(old_lines, new_lines, 'file.lua', 'file.lua'),
}))
assert(not vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = 'DiffsAddText' })))
local ns = vim.api.nvim_get_namespaces().diffs_split_intra
local marks = vim.api.nvim_buf_get_extmarks(panes.right_buf, ns, 0, -1, {})
assert(#marks > 0, 'The first split has no intra-line highlights')
assert(vim.g.loaded_diffs == nil, 'The legacy core plugin loader ran')
]],
        '\n'
      ),
      script
    )
    local output = vim.fn.system({ vim.v.progpath, '--headless', '-u', 'NONE', '-l', script })
    local status = vim.v.shell_error
    vim.fn.delete(script)
    assert.are.equal(0, status, output)
  end)
end)
