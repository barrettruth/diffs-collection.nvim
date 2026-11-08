vim.opt.packpath = {}
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.runtimepath:prepend(assert(vim.env.DIFFS_NVIM_PATH, 'Run with nix develop.'))
vim.cmd('filetype plugin indent on')
