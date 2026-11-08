local M = {}
local rails = require('diffs-collection.rails')
local ns = vim.api.nvim_create_namespace('diffs_collection_rails')

---@param filename string?
---@param repo_root string?
---@return string?
local function filetype(filename, repo_root)
  if not filename then
    return nil
  end
  local path = repo_root and vim.fs.joinpath(repo_root, filename) or filename
  local absolute_path = vim.fn.resolve(vim.fn.fnamemodify(path, ':p'))
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.fn.resolve(vim.api.nvim_buf_get_name(buffer)) == absolute_path
      and vim.bo[buffer].filetype ~= ''
    then
      return vim.bo[buffer].filetype
    end
  end
  local ft = vim.filetype.match({ filename = path })
  if not ft and vim.fn.filereadable(path) == 1 then
    ft = vim.filetype.match({ filename = path, contents = vim.fn.readfile(path, '', 10) })
  end
  return ft
end

---@param bufnr integer
---@return diffs.Hunk[]
function M.hunks(bufnr)
  local width = rails.width_for_buffer(bufnr)
  local lines = rails.strip_lines(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), width)
  local hunks = {}
  local current
  local filename
  local header_start
  local headers = {}
  for lnum, line in ipairs(lines) do
    local path = line:match('^diff %-%-git %a/.+ %a/(.+)$')
      or line:match('^diff %-%-combined (.+)$')
      or line:match('^diff %-%-cc (.+)$')
    if path then
      current = nil
      filename = path
      header_start = lnum
      headers = { line }
    elseif line:match('^@@+') then
      local ft = filetype(filename, vim.b[bufnr].diffs_repo_root)
      local lang = ft and vim.treesitter.language.get_lang(ft) or nil
      if lang and not pcall(vim.treesitter.language.add, lang) then
        lang = nil
      end
      local prefix, context = line:match('^(@@+.-@@+%s*)(.*)')
      current = {
        filename = filename,
        ft = ft,
        lang = lang,
        start_line = lnum,
        lines = {},
        prefix_width = #line:match('^(@@+)') - 1,
        column_offset = width,
        header_start_line = header_start,
        header_lines = headers,
        header_context = context ~= '' and context or nil,
        header_context_col = prefix and #prefix or nil,
      }
      hunks[#hunks + 1] = current
      headers = {}
      header_start = nil
    elseif current then
      if line:match('^[ +%-\\]') then
        current.lines[#current.lines + 1] = line
      else
        current = nil
      end
    elseif header_start then
      headers[#headers + 1] = line
    end
  end
  return hunks
end

---@param bufnr integer
function M.apply(bufnr)
  require('diffs-collection.palette').setup()
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  local width = rails.width_for_buffer(bufnr)
  local ranges = rails.number_ranges(width, rails.style_for_buffer(bufnr)) or {}
  local opts = require('diffs').highlight_options()
  local priority = opts.highlights.priorities
  local raw = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for _, hunk in ipairs(M.hunks(bufnr)) do
    local whitespace = require('diffs').whitespace_only_lines(hunk.lines)
    for index, line in ipairs(hunk.lines) do
      local row = hunk.start_line + index - 1
      local limit = #raw[row + 1]
      local prefix = line:sub(1, hunk.prefix_width)
      local kind = prefix:find('-', 1, true) and 'Delete' or prefix:find('+', 1, true) and 'Add'
      local function mark(start, finish, group, level)
        finish = math.min(finish, limit)
        if start < finish then
          vim.api.nvim_buf_set_extmark(bufnr, ns, row, start, {
            end_col = finish,
            hl_group = group,
            priority = level,
          })
        end
      end
      if hunk.prefix_width > 1 and not prefix:find('[^+]') then
        local content = line:sub(hunk.prefix_width + 1)
        if
          content:match('^<<<<<<<')
          or content:match('^=======')
          or content:match('^>>>>>>>')
          or content:match('^|||||||')
        then
          mark(width + hunk.prefix_width, limit, 'DiffsConflictMarker', priority.char_bg)
        end
      end
      mark(0, width, 'DiffsRail', priority.syntax)
      for _, range in ipairs(ranges) do
        mark(range.start, range.finish, 'DiffsRailNr', priority.syntax + 1)
      end
      if kind and not whitespace[index] and #ranges > 0 then
        mark(
          ranges[1].start,
          ranges[#ranges].finish,
          'Diffs' .. kind .. 'RailNr',
          priority.syntax + 2
        )
        if opts.highlights.background then
          mark(0, width, 'Diffs' .. kind, priority.line_bg)
          vim.api.nvim_buf_set_extmark(bufnr, ns, row, 0, {
            virt_text = { { '▏', 'Diffs' .. kind .. 'Bar' } },
            virt_text_pos = 'overlay',
            hl_mode = 'replace',
            priority = priority.char_bg + 10,
          })
        end
      end
    end
  end
end

return M
