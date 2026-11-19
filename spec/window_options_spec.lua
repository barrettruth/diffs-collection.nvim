require('spec.helpers')

describe('diff window options', function()
  it('restores the source window options when a split opens another buffer', function()
    vim.cmd.tabnew()
    local tab = vim.api.nvim_get_current_tabpage()
    local ok, err = pcall(function()
      vim.g.loaded_diffs_collection = nil
      vim.g.diffs_diff = {}
      vim.g.diffs_review = {}
      dofile('plugin/diffs-collection.lua')
      vim.wo.number = true
      vim.wo.relativenumber = true
      vim.wo.statuscolumn = '%l'
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, 'diffs://review:window-options')
      vim.api.nvim_win_set_buf(0, buf)
      assert.is_false(vim.wo.number)
      vim.cmd.split()
      vim.cmd.enew()
      assert.is_true(vim.wo.number)
      assert.is_true(vim.wo.relativenumber)
      assert.are.equal('%l', vim.wo.statuscolumn)
    end)
    if vim.api.nvim_tabpage_is_valid(tab) then
      vim.cmd.tabclose({ bang = true })
    end
    assert.is_true(ok, err)
  end)
end)
