# diffs-collection.nvim

File comparisons, repository review, and conflict resolution for Neovim.
Uses [diffs.nvim](https://github.com/barrettruth/diffs.nvim) for highlighting.

This is a development prototype. The current diffs.nvim plugin loader also
registers comparison commands and conflict handlers. Use the development launcher
below to load its Lua modules without those competing handlers. Normal package
installation is not supported yet.

## Development

The Nix environment pins Neovim, the development tools, and the core source.

```sh
nix develop -c just dev
nix develop -c just ci
```

The launcher uses an isolated Neovim configuration. It adds both repositories to
the runtime path and loads only the collection's plugin entry point.

## Commands

| Command | Comparison |
| --- | --- |
| `:Diff` | Index to current buffer |
| `:Diff HEAD` | Last commit to current buffer |
| `:Diff main:path/to/file` | File at that revision to its worktree file |
| `:Diff files` | Last save to current buffer |
| `:Diff files other.lua` | Named file to current buffer |
| `:Diff files old.lua new.lua` | Two files on disk |
| `:Review [base]` | Repository changes against a base |
| `:Review A..B` | Direct repository comparison |
| `:Review A...B` | Repository comparison from the merge base |

Current-state reviews include committed, staged, unstaged, and untracked changes.
Use `++nountracked` to omit untracked files. Review supports unified, stacked, and
paired split layouts. Current-file comparisons support the same layouts. Arbitrary
file comparisons support unified and stacked layouts.

```vim
:Diff ++layout=split HEAD
:Diff files ++layout=stacked old\ file.lua new\ file.lua
:Review ++layout=split main
:vertical Review ++layout=unified main
```

Named file paths read disk content. An omitted right path uses the current
buffer, including unsaved edits. Generated views retain `CTRL-L` refresh and the
existing hunk and file navigation mappings. User buffer-local mappings take
precedence.

## Components

All three components are enabled by default. Set a component to `false` before
the plugin loads to disable its commands or automatic attachment.

```lua
vim.g.diffs_diff = { default_layout = 'unified', difftastic = false }
vim.g.diffs_review = { layout = 'unified' }
vim.g.diffs_conflict = false
```

`vim.g.diffs` configures core highlighting. The collection does not expose the
deprecated libvscodediff or conflict-keymap settings.

## Lua API

```lua
require('diffs-diff').open('HEAD', { layout = 'split' })
require('diffs-diff').files('old.lua', 'new.lua')
require('diffs-review').open({ base = 'main' }, { layout = 'stacked' })
require('diffs-conflict').resolve_ours()
```

The review API also exposes `files`, `current`, `goto_file`, `next_file`,
`prev_file`, `toggle_layout`, and `select_file`. Conflict resolution exposes
`attach`, `detach`, `resolve_ours`, `resolve_theirs`, `resolve_both`,
`resolve_none`, `goto_next`, and `goto_prev`.

Existing `<Plug>(diffs-...)` mappings, `DiffsConflict*` events, `DiffsMergeReady`,
and conflict highlight names remain available. Conflict resolution changes the
working buffer without writing it to disk.
