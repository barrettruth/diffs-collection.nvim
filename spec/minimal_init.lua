vim.opt.loadplugins = false
vim.opt.packpath = {}
vim.opt.runtimepath:prepend(assert(vim.env.DIFFS_NVIM_PATH))
vim.opt.runtimepath:prepend(vim.fn.getcwd())
