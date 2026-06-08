local lint = require("lint")
lint.linters_by_ft = {
	markdown = { "markdownlint" },
	python = { "ruff" },
	json = { "jsonlint" },
	lua = { "luacheck" },
	text = { "vale" },
	sh = { "shellcheck" },
	html = { "htmlhint" },
	css = { "stylelint" },
	rust = { "clippy" },
}
lint.linters.luacheck.args = { "--globals", "vim" }
local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
	group = lint_augroup,
	callback = function()
		if vim.bo.modifiable then
			lint.try_lint()
		end
	end,
})
