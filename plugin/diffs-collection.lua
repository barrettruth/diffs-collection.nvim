if vim.g.loaded_diffs_collection then
  return
end

if vim.g.loaded_diffs then
  vim.notify(
    '[diffs-collection]: The prototype requires the diffs core Lua modules without its legacy plugin loader. See :help diffs-collection-development.',
    vim.log.levels.WARN
  )
  return
end

local config = require('diffs-collection.config')
local diff_enabled = config.get_diff() ~= false
local review_enabled = config.get_review() ~= false
local conflict_enabled = config.get_conflict() ~= false
vim.g.loaded_diffs_collection = true

local function commands()
  return require('diffs-collection.commands')
end

local function command(name, callback, opts)
  if vim.fn.exists(':' .. name) == 2 then
    vim.notify('[diffs-collection]: Command already exists: ' .. name, vim.log.levels.WARN)
    return
  end
  opts.force = false
  vim.api.nvim_create_user_command(name, callback, opts)
end

local function mapping(name, callback, description)
  vim.keymap.set('n', '<Plug>(diffs-' .. name .. ')', callback, { desc = description })
end

if diff_enabled then
  command('Diff', function(opts)
    commands().diff_command(opts.fargs, opts.smods.vertical)
  end, {
    nargs = '*',
    bar = true,
    complete = function(...)
      return commands().complete_diff_command(...)
    end,
    desc = 'Compare a file with Git or compare two files',
  })
  mapping('diff', function()
    commands().diff(nil, false)
  end, 'Unified diff (horizontal)')
  mapping('diff-vertical', function()
    commands().diff(nil, true)
  end, 'Unified diff (vertical)')
end

if review_enabled then
  command('Review', function(opts)
    commands().review_command(opts.fargs, opts.smods.vertical)
  end, {
    nargs = '*',
    bar = true,
    complete = function(...)
      return commands().complete_review_command(...)
    end,
    desc = 'Review repository changes',
  })
  mapping('review-open-split', function()
    commands().review_split()
  end, 'Open review file in split diff')
  mapping('review-toggle-layout', function()
    commands().review_toggle_layout()
  end, 'Toggle review layout')
  mapping('review-next-file', function()
    for _ = 1, vim.v.count1 do
      commands().review_next_file()
    end
  end, 'Next file in review split')
  mapping('review-prev-file', function()
    for _ = 1, vim.v.count1 do
      commands().review_prev_file()
    end
  end, 'Previous file in review split')
  mapping('review-select-file', function()
    commands().select_review_file()
  end, 'Pick a file in the review split')
end

if diff_enabled or review_enabled then
  local group = vim.api.nvim_create_augroup('diffs_collection_views', { clear = true })
  vim.api.nvim_create_autocmd('BufReadCmd', {
    group = group,
    pattern = 'diffs://*',
    callback = function(args)
      vim.cmd(
        ('lockmarks lua require("diffs-collection.commands").read_buffer(%d, { quickfix = %s })'):format(
          args.buf,
          tostring(vim.b[args.buf].diffs_source ~= nil)
        )
      )
    end,
  })
  vim.api.nvim_create_autocmd('OptionSet', {
    group = group,
    pattern = 'diffopt',
    callback = function()
      commands().on_diffopt_changed()
    end,
  })
  mapping('diff-open-source', function()
    require('diffs-collection.hunks').open_source(vim.api.nvim_get_current_buf())
  end, 'Open source file from generated diff')
  mapping('refresh', function()
    commands().refresh()
  end, 'Refresh the current diff buffer')
  if diff_enabled then
    vim.api.nvim_create_autocmd('FileType', {
      group = group,
      pattern = 'fugitive',
      callback = function(args)
        require('diffs-collection.fugitive').setup_keymaps(args.buf)
      end,
    })
  end
end

if conflict_enabled then
  require('diffs-conflict').setup()
  for _, kind in ipairs({ 'conflict', 'merge' }) do
    for _, side in ipairs({ 'ours', 'theirs', 'both', 'none' }) do
      mapping(kind .. '-' .. side, function()
        if config.get_conflict() then
          require('diffs-collection.' .. kind)['resolve_' .. side](vim.api.nvim_get_current_buf())
        end
      end, 'Resolve ' .. kind .. ': ' .. side)
    end
    for _, direction in ipairs({ 'next', 'prev' }) do
      mapping(kind .. '-' .. direction, function()
        require('diffs-collection.' .. kind)['goto_' .. direction](vim.api.nvim_get_current_buf())
      end, 'Navigate ' .. kind .. ': ' .. direction)
    end
  end
end
