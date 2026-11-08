vim.opt.packpath = {}
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.runtimepath:prepend(assert(vim.env.DIFFS_NVIM_PATH, 'Run with nix develop.'))
vim.g.diffs_diff = {}
vim.g.diffs_review = {}
vim.g.diffs_conflict = {}
vim.cmd('filetype plugin indent on')
