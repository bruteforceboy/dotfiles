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

-- Run ClangFormat on save for common C/C++ extensions
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.cpp", "*.cc", "*.c", "*.hpp", "*.h" },
  callback = function()
    vim.cmd("ClangFormat")
  end,
})

-- Filetype-specific mapping for C++: write and compile current file
vim.api.nvim_create_autocmd("FileType", {
  pattern = "cpp",
  callback = function()
    vim.keymap.set("n", "<F5>", function()
      vim.cmd("write")
      vim.cmd("belowright split | terminal g++ -std=c++23 -DLOCAL % -o %:r")
    end, { buffer = true, noremap = true, silent = true })
  end,
})
