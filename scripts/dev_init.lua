vim.opt.loadplugins = false
vim.opt.packpath = {}
vim.opt.runtimepath:prepend(assert(vim.env.DIFFS_NVIM_PATH, 'Run with nix develop.'))
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.cmd('filetype plugin indent on')
vim.cmd('runtime plugin/diffs-collection.lua')
