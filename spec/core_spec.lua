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

  it('places generated header context after the rail exactly once', function()
    local raw = {
      'diff --git a/test.lua b/test.lua',
      '@@ -1 +1 @@ function test()',
      '-local value = 1',
      '+local value = 2',
    }
    local lines, info = require('diffs-collection.rails').annotate(raw)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.b[buf].diffs_rail_width = info.prefix_width
    vim.api.nvim_set_current_buf(buf)
    require('diffs-collection.core').attach(buf)
    vim.api.nvim__redraw({ valid = true, flush = true })
    local ns = vim.api.nvim_get_namespaces()
    vim.wait(1000, function()
      for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, ns.diffs, 0, -1, { details = true })) do
        if
          mark[2] == 1
          and mark[3] == info.prefix_width + #'@@ -1 +1 @@ '
          and mark[4].hl_group == 'DiffsClear'
        then
          return true
        end
      end
      return false
    end, 10)
    local marks = vim.api.nvim_buf_get_extmarks(buf, ns.diffs, 0, -1, { details = true })
    local context = false
    for _, mark in ipairs(marks) do
      assert.is_true(mark[3] >= info.prefix_width)
      if
        mark[2] == 1
        and mark[3] == info.prefix_width + #'@@ -1 +1 @@ '
        and mark[4].hl_group == 'DiffsClear'
      then
        context = true
        assert.are.equal(#lines[2], mark[4].end_col)
      end
    end
    assert.is_true(context)
    local backgrounds = {}
    for _, mark in
      ipairs(
        vim.api.nvim_buf_get_extmarks(buf, ns.diffs_collection_rails, 0, -1, { details = true })
      )
    do
      local detail = mark[4]
      if detail.hl_group == 'DiffsAdd' or detail.hl_group == 'DiffsDelete' then
        backgrounds[#backgrounds + 1] = { mark[2], mark[3], detail.end_col, detail.hl_group }
      end
    end
    assert.are.same({
      { 2, 0, info.prefix_width, 'DiffsDelete' },
      { 3, 0, info.prefix_width, 'DiffsAdd' },
    }, backgrounds)
    vim.api.nvim_buf_delete(buf, { force = true })
  end)
end)
