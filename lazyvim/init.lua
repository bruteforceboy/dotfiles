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

-- Run ClangFormat on save for common C/C++ extensions
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.cpp", "*.cc", "*.c", "*.hpp", "*.h" },
  callback = function()
    vim.cmd("ClangFormat")
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

vim.diagnostic.config({
  virtual_text = {
    prefix = "●", -- a small marker before the message (optional)
    spacing = 2,
  },
  signs = true, -- show icons in the sign column
  underline = true, -- underline problem ranges
  update_in_insert = false, -- don't spam while inserting
  severity_sort = true,
})
