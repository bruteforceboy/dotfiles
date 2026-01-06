-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.keymap.set("n", "<F2>", "<cmd>bprevious<cr>", { silent = true })
vim.keymap.set("n", "<F3>", "<cmd>bnext<cr>", { silent = true })

-- set default tab behavior to 4 spaces
vim.opt.expandtab = true -- use spaces instead of real tabs
vim.opt.shiftwidth = 4 -- size for autoindent
vim.opt.tabstop = 4 -- number of spaces a <Tab> counts for
vim.opt.softtabstop = 4 -- editing: how many spaces a Tab inserts/erases
vim.opt.smarttab = true
vim.o.background = "dark"

-- run ClangFormat on save for common C/C++ extensions
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.cpp", "*.cc", "*.c", "*.hpp", "*.h" },
  callback = function()
    vim.cmd("ClangFormat")
  end,
})

-- ---------------------------
-- clang-format based indentation
-- ---------------------------
local function parse_clang_format_dump(lines)
  -- lines: table of strings from clang-format -dump-config
  local indent_width, tab_width, use_tab
  for _, l in ipairs(lines) do
    -- trim leading/trailing spaces
    local s = l:match("^%s*(.-)%s*$")
    if s:match("^IndentWidth:") then
      indent_width = tonumber(s:match("^IndentWidth:%s*(%d+)"))
    elseif s:match("^TabWidth:") then
      tab_width = tonumber(s:match("^TabWidth:%s*(%d+)"))
    elseif s:match("^UseTab:") then
      -- possible values: Never, ForIndentation, Always
      use_tab = s:match("^UseTab:%s*(%S+)")
    end
  end
  return indent_width, tab_width, use_tab
end

local function apply_clang_indent_to_buffer(bufnr, indent_width, tab_width, use_tab)
  bufnr = bufnr or 0
  -- prefer tab_width if provided; otherwise fall back to indent_width
  local tw = tab_width or indent_width or 4
  local iw = indent_width or tw or 4
  -- Buffer-local settings
  local bo = vim.bo[bufnr]
  if use_tab and use_tab ~= "Never" then
    bo.expandtab = false
  else
    bo.expandtab = true
  end
  bo.shiftwidth = iw
  bo.tabstop = tw
  bo.softtabstop = iw
end

local function detect_and_apply_clangformat_indentation(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local fname = vim.api.nvim_buf_get_name(bufnr)
  if fname == "" then
    return
  end

  -- Build clang-format command safely
  local shell_fname = vim.fn.shellescape(fname)
  local cmd = "clang-format -style=file -assume-filename=" .. shell_fname .. " -dump-config"
  -- Try calling clang-format; if not available or fails, fallback will be used
  local ok, lines = pcall(vim.fn.systemlist, cmd)
  if not ok or not lines or #lines == 0 or (type(lines) == "table" and #lines == 1 and lines[1]:match("Error")) then
    -- fallback: try a safe default: use clang-format default style dump
    local ok2, lines2 = pcall(vim.fn.systemlist, "clang-format -style=LLVM -dump-config")
    if ok2 and lines2 and #lines2 > 0 then
      lines = lines2
    else
      -- last resort: apply sensible defaults (4-space)
      apply_clang_indent_to_buffer(bufnr, 4, 4, "Never")
      return
    end
  end

  local indent_width, tab_width, use_tab = parse_clang_format_dump(lines)
  -- apply parsed values (nil values will fall back inside apply_clang_indent_to_buffer)
  apply_clang_indent_to_buffer(bufnr, indent_width, tab_width, use_tab)
end

-- Autocmd group for clang-format indentation adaptation
local clang_group = vim.api.nvim_create_augroup("ClangFormatIndentDetect", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufEnter", "BufWritePost" }, {
  group = clang_group,
  pattern = { "*.c", "*.h", "*.cpp", "*.cc", "*.cxx", "*.hpp", "*.hh" },
  callback = function(args)
    -- run in protected call to avoid noisy errors
    pcall(detect_and_apply_clangformat_indentation, args.buf)
  end,
})

-- Filetype-specific mapping for C++: F5 = compile, F6 = run
vim.api.nvim_create_autocmd("FileType", {
  pattern = "cpp",
  callback = function()
    local file_dir = vim.fn.expand("%:p:h")
    local file_name = vim.fn.expand("%:t")
    local base_noext = vim.fn.expand("%:t:r")

    -- F5: write and compile
    vim.keymap.set("n", "<F5>", function()
      vim.cmd("write")
      -- Use bash -c and single quotes to avoid fish parsing issues
      vim.cmd(
        "belowright split | terminal bash -c 'cd \""
          .. file_dir
          .. '" && g++ -std=c++23 -DLOCAL "'
          .. file_name
          .. '" -o "'
          .. base_noext
          .. '" && echo "[g++] exit:$?" ; exec $SHELL\''
      )
    end, { buffer = true, noremap = true, silent = true })

    -- F6: write and run compiled binary
    vim.keymap.set("n", "<F6>", function()
      vim.cmd("write")
      vim.cmd(
        "belowright split | terminal bash -c 'cd \""
          .. file_dir
          .. '" && if [ -x "'
          .. base_noext
          .. '" ]; then ./'
          .. base_noext
          .. '; else echo "Executable not found: '
          .. base_noext
          .. "\"; fi; exec $SHELL'"
      )
    end, { buffer = true, noremap = true, silent = true })
  end,
})
