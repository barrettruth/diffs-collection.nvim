# diffs-collection.nvim

File comparisons, repository review, and conflict resolution for
[diffs.nvim](https://github.com/barrettruth/diffs.nvim).

| Component | Description |
| --- | --- |
| [diffs-diff](#diffs-diff) | File and buffer comparisons with `:Diff` |
| [diffs-review](#diffs-review) | Repository review with `:Review` |
| [diffs-conflict](#diffs-conflict) | Conflict highlighting and resolution |

## Installation

With `vim.pack` (Neovim 0.12+):

**Load diffs.nvim before diffs-collection.nvim.** Set configuration before
`vim.pack.add()`. This example opens repository reviews in split layout:

```lua
vim.g.diffs_review = { layout = 'split' }

vim.pack.add({
  'https://github.com/barrettruth/diffs.nvim',
  'https://github.com/barrettruth/diffs-collection.nvim',
}, { load = true })
```

`load = true` loads the plugins immediately, in the listed order.

## Configuration

### diffs-diff

Compare files, buffers, and Git objects with `:Diff`. Defaults:

```lua
vim.g.diffs_diff = {
  default_layout = 'unified', -- 'unified', 'stacked', or 'split'
  difftastic = false, -- true or { args = {} } to enable Difftastic
}
```

Difftastic requires the `difft` executable. Its optional `args` list defaults to
`{}`. Set `vim.g.diffs_diff = false` to disable `:Diff`.

### diffs-review

Review repository changes with `:Review`. Defaults:

```lua
vim.g.diffs_review = {
  layout = 'unified', -- 'unified', 'stacked', or 'split'
}
```

Set `vim.g.diffs_review = false` to disable `:Review`.

### diffs-conflict

Highlight and resolve conflict markers in the working buffer. Default:

```lua
vim.g.diffs_conflict = {}
```

The empty table enables conflict handling. There are no additional options.
Set `vim.g.diffs_conflict = false` to disable automatic detection and mappings.

## Documentation

```vim
:help diffs-collection
```
