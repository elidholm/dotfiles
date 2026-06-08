vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>', { desc = "Disable left arrow key in normal mode" })
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>', { desc = "Disable right arrow key in normal mode" })
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>', { desc = "Disable up arrow key in normal mode" })
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>', { desc = "Disable down arrow key in normal mode" })

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open [P]roject [V]iew" })

vim.api.nvim_create_user_command("Sw", function()
	vim.cmd("SudoWrite")
end, { desc = "Use [S]udo permissions to [W]rite file" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center cursor" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center cursor" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result and center cursor" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result and center cursor" })

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Exit insert mode with Ctrl-c" })

vim.keymap.set("n", "Q", "<nop>", { desc = "Disable Ex mode" })

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make current file e[X]ecutable" })

vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
end, { desc = "Source current file" })

vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<CR>", { desc = "Open [L]azy[G]it" })

vim.keymap.set("v", "<leader>dq", 'c"<C-r>""<Esc>', { desc = "Surround selection with [D]ouble [Q]uotes" })
vim.keymap.set("n", "<leader>dq", 'ciW"<C-r>""<Esc>', { desc = "Surround word under cursor with [D]ouble [Q]uotes" })
vim.keymap.set("v", "<leader>sq", "c'<C-r>\"'<Esc>", { desc = "Surround selection with [S]ingle [Q]uotes" })
vim.keymap.set("n", "<leader>sq", "ciW'<C-r>\"'<Esc>", { desc = "Surround word under cursor with [S]ingle [Q]uotes" })
vim.keymap.set("n", "<leader>uq", 'di"hPl2x', { desc = "Remove surrounding double quotes from word under cursor" })
