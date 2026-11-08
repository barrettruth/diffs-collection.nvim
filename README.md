# diffs-collection.nvim

File comparisons, repository review, and conflict resolution for
[diffs.nvim](https://github.com/barrettruth/diffs.nvim).

| Component | Description |
| --- | --- |
| [diffs-diff](#diffs-diff) | File and buffer comparisons with `:Diff` |
| [diffs-review](#diffs-review) | Repository review with `:Review` |
| [diffs-conflict](#diffs-conflict) | Conflict highlighting and resolution |

## Installation

Install both plugins with your package manager of choice.

**Load diffs.nvim before diffs-collection.nvim.**

## Configuration

Each component has its own `vim.g` table. Components are enabled by default.
Set a component to `false` before plugin loading to disable it. Empty tables
select defaults. Configure core highlighting with `vim.g.diffs`.

### diffs-diff

Compare files, buffers, and Git objects with `:Diff`.

```lua
vim.g.diffs_diff = {
  default_layout = 'unified',
  difftastic = false,
}
```

### diffs-review

Review repository changes with `:Review`.

```lua
vim.g.diffs_review = { layout = 'unified' }
```

### diffs-conflict

Highlight and resolve conflict markers in the working buffer.

```lua
vim.g.diffs_conflict = {}
```

## Documentation

```vim
:help diffs-collection
```
