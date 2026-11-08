# diffs-collection.nvim

File comparisons, repository review, and conflict resolution for
[diffs.nvim](https://github.com/barrettruth/diffs.nvim).

| Component | Description |
| --- | --- |
| [diffs-diff](#diffs-diff) | File and buffer comparisons with `:Diff` |
| [diffs-review](#diffs-review) | Repository review with `:Review` |
| [diffs-conflict](#diffs-conflict) | Conflict highlighting and resolution |

<img width="640" alt="diffs-collection.nvim preview" src="https://github.com/user-attachments/assets/fb67f1f5-e64b-4b67-88f4-2d8d37d9f9f2" />

## Installation

For example, with `vim.pack` (Neovim 0.12+):

**Load diffs.nvim before diffs-collection.nvim and specify configuration before**
`vim.pack.add()`/your plugin manager loads the plugins. To enable all components:

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

Components are opt-in. Define a component's `vim.g.diffs_*` table before loading
diffs-collection.nvim. Empty tables enable defaults. No `setup()` call is needed.

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
