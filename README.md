# diffs-collection.nvim

File comparisons, repository review, and conflict resolution for Neovim.
[diffs.nvim](https://github.com/barrettruth/diffs.nvim) provides highlighting.

Load **diffs.nvim before diffs-collection.nvim**. The collection requires the
public highlighting API on diffs.nvim's `integration/collection` branch.

```lua
-- lazy.nvim
{
  'barrettruth/diffs-collection.nvim',
  dependencies = {
    { 'barrettruth/diffs.nvim', branch = 'integration/collection' },
  },
}
```

All three components are enabled by default. Set a component to `false` before
plugin loading to disable it. Configure core highlighting with `vim.g.diffs`.

```lua
vim.g.diffs_diff = {}     -- :Diff file comparisons; :help diffs-collection-commands
vim.g.diffs_review = {}   -- :Review repository changes; :help diffs-collection-commands
vim.g.diffs_conflict = {} -- Conflict resolution; :help diffs-collection-mappings
```

See `:help diffs-collection` for configuration, commands, and mappings.
