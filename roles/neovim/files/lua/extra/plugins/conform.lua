require("conform").setup({
	notify_on_error = false,
	format_on_save = function(bufnr)
		local enabled_filetypes = {
			lua = true,
			python = true,
			sh = true,
			rust = true,
			css = true,
			json = true,
			html = false,
			scss = true,
			jinja = false,
			groovy = true,
			rst = true,
			toml = true,
			yaml = true,
		}
		if enabled_filetypes[vim.bo[bufnr].filetype] then
			return { timeout_ms = 500 }
		else
			return nil
		end
	end,
	default_format_opts = {
		lsp_format = "fallback",
	},
	formatters_by_ft = {
		lua = { "stylua" },
		rust = { "rustfmt" },
		python = { "ruff_organize_imports", "docformatter", "ruff_format" },
		sh = { "shfmt", "shellcheck" },
		css = { "prettierd", "prettier", stop_after_first = true },
		json = { "json_repair", "prettierd" },
		html = { "prettierd", "prettier", stop_after_first = true },
		scss = { "prettierd", "prettier", stop_after_first = true },
		jinja = { "djlint" },
		groovy = { "npm-groovy-lint" },
		rst = { "rstfmt" },
		toml = { "taplo" },
		yaml = { "yamlfix" },
	},
	formatters = {
		shfmt = {
			append_args = { "-i", "2" },
		},
		yamlfix = {
			env = {
				YAMLFIX_WHITELINES = "1",
				YAMLFIX_SEQUENCE_STYLE = "keep_style",
				YAMLFIX_LINE_LENGTH = "119",
				YAMLFIX_preserve_quotes = "true",
			},
		},
	},
})

vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format({ async = true })
end, { desc = "[F]ormat buffer" })
