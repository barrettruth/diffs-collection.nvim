# diffs-collection.nvim

File comparisons, repository review, and conflict resolution for
[diffs.nvim](https://github.com/barrettruth/diffs.nvim).

| Component | Description |
| --- | --- |
| [diffs-diff](#diffs-diff) | File and buffer comparisons with `:Diff` |
| [diffs-review](#diffs-review) | Repository review with `:Review` |
| [diffs-conflict](#diffs-conflict) | Conflict highlighting and resolution |

<img width="1721" height="1035" alt="image" src="https://github.com/user-attachments/assets/e12052ba-fba0-408c-bcaa-53c059f6311c" />

## Installation

For example, with `vim.pack` (Neovim 0.12+):

**Load diffs.nvim before diffs-collection.nvim and specify configuration before**
`vim.pack`/your plugin manager loads the plugins.

For example, to enable all components:

```lua
vim.g.diffs_diff = {}
vim.g.diffs_review = { layout = 'split' }
vim.g.diffs_conflict = {}

vim.pack.add({
  'https://github.com/barrettruth/diffs.nvim',
  'https://github.com/barrettruth/diffs-collection.nvim',
}, { load = true })
```

## Configuration

Define a component's `vim.g.diffs_*` table before loading the plugin to enable it.
No `setup()` call is needed.

### diffs-diff

Compare files, buffers, and Git objects with `:Diff`. Enable with default settings:

```lua
vim.g.diffs_diff = {
  layout = 'unified', -- 'unified', 'stacked', or 'split'
  difftastic = false, -- true or { args = {} } to enable Difftastic
}
```

See `:help g:diffs_diff` for more information.

### diffs-review

Review repository changes with `:Review`. Enable with default settings:

```lua
vim.g.diffs_review = {
  layout = 'unified', -- 'unified', 'stacked', or 'split'
}
```

See `:help g:diffs_review` for more information.

### diffs-conflict

Highlight and resolve conflict markers in the working buffer. Enable with:

```lua
vim.g.diffs_conflict = {}
```

See `:help g:diffs_conflict` for more information.

## Hunk actions

In unified and stacked Git comparisons, place the cursor in a hunk:

| Key | Action | Where |
| --- | --- | --- |
| `dp` | Stage the hunk | `:Diff` against the index, or the Unstaged section of `:Review` |
| `do` | Unstage the hunk | The Staged section of `:Review` |

For example, run `:Diff ++layout=unified` and press `dp` to stage the current
hunk, which updates the Git index and refreshes the view.

Split views, `:Diff files`, and ordinary patch buffers do not have
these mappings.

See `:help diffs-collection-actions` for more information.

## Documentation

```vim
:help diffs-collection
```
