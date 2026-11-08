local core = require('diffs-collection.core')

return {
  resolve = core.resolve_diffopt,
  inline = core.inline,
  vim_diff_opts = core.vim_diff_opts,
  git_flags = core.git_flags,
}
