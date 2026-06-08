-- ============================================================
-- SECTION 1: FOUNDATION
-- Core Neovim settings, leaders, options, basic keymaps, basic autocmds
-- ============================================================
do
	vim.loader.enable()

	require("extra.config.globals")
	require("extra.config.options")
	require("extra.config.mappings")
	require("extra.config.autocmd")
end

-- ============================================================
-- SECTION 2: PLUGIN MANAGER INTRO
-- vim.pack intro, build hooks
-- ============================================================
do
	local function run_build(name, cmd, cwd)
		local result = vim.system(cmd, { cwd = cwd }):wait()
		if result.code ~= 0 then
			local stderr = result.stderr or ""
			local stdout = result.stdout or ""
			local output = stderr ~= "" and stderr or stdout
			if output == "" then
				output = "No output from build command."
			end
			vim.notify(("Build failed for %s:\n%s"):format(name, output), vim.log.levels.ERROR)
		end
	end

	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			local name = ev.data.spec.name
			local kind = ev.data.kind
			if kind ~= "install" and kind ~= "update" then
				return
			end

			if name == "telescope-fzf-native.nvim" and vim.fn.executable("make") == 1 then
				run_build(name, { "make" }, ev.data.path)
				return
			end

			if name == "LuaSnip" then
				if vim.fn.has("win32") ~= 1 and vim.fn.executable("make") == 1 then
					run_build(name, { "make", "install_jsregexp" }, ev.data.path)
				end
				return
			end

			if name == "nvim-treesitter" then
				if not ev.data.active then
					vim.cmd.packadd("nvim-treesitter")
				end
				vim.cmd("TSUpdate")
				return
			end
		end,
	})
end

---Because most plugins are hosted on GitHub, this helper function
---allows for less repetition in the following sections.
---@param repo string
---@return string
local function gh(repo)
	return "https://github.com/" .. repo
end

-- ============================================================
-- SECTION 3: UI / CORE UX PLUGINS
-- guess-indent, which-key, colorscheme, todo-comments, mini modules
-- ============================================================
do
	vim.pack.add({ gh("NMAC427/guess-indent.nvim") })
	require("guess-indent").setup({})

	vim.pack.add({ gh("nvim-tree/nvim-web-devicons") })
	require("nvim-web-devicons").setup({})

	vim.pack.add({ gh("lewis6991/gitsigns.nvim") })
	require("gitsigns").setup({
		signs = {
			add = { text = "+" }, ---@diagnostic disable-line: missing-fields
			change = { text = "~" }, ---@diagnostic disable-line: missing-fields
			delete = { text = "_" }, ---@diagnostic disable-line: missing-fields
			topdelete = { text = "‾" }, ---@diagnostic disable-line: missing-fields
			changedelete = { text = "~" }, ---@diagnostic disable-line: missing-fields
		},
	})
	require("extra.plugins.gitsigns")

	vim.pack.add({ gh("folke/which-key.nvim") })
	require("which-key").setup({
		delay = 0,
		icons = { mappings = vim.g.have_nerd_font },
		spec = {
			{ "<leader>s", group = "[S]earch", mode = { "n", "v" } },
			{ "<leader>t", group = "[T]oggle" },
			{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
			{ "gr", group = "LSP Actions", mode = { "n" } },
		},
	})

	vim.pack.add({ { src = gh("catppuccin/nvim"), name = "catppuccin" } })
	require("catppuccin").setup({
		flavour = "mocha",
		transparent_background = true,
	})
	require("extra.plugins.colorscheme")

	vim.pack.add({ gh("folke/todo-comments.nvim") })
	require("todo-comments").setup({ signs = false })

	vim.pack.add({ gh("nvim-mini/mini.nvim") })
	require("extra.plugins.mini")
end

-- ============================================================
-- SECTION 4: SEARCH & NAVIGATION
-- Telescope setup, keymaps, LSP picker mappings
-- ============================================================
do
	---@type (string|vim.pack.Spec)[]
	local telescope_plugins = {
		gh("nvim-lua/plenary.nvim"),
		gh("nvim-telescope/telescope.nvim"),
		gh("nvim-telescope/telescope-ui-select.nvim"),
	}
	if vim.fn.executable("make") == 1 then
		table.insert(telescope_plugins, gh("nvim-telescope/telescope-fzf-native.nvim"))
	end

	vim.pack.add(telescope_plugins)
	require("extra.plugins.telescope")

	vim.pack.add({ gh("theprimeagen/harpoon") })
	require("extra.plugins.harpoon")
end

-- ============================================================
-- SECTION 5: LSP
-- LSP keymaps, server configuration, Mason tools installations
-- ============================================================
do
	vim.pack.add({ gh("j-hui/fidget.nvim") })
	local fidget = require("fidget")
	fidget.setup({})
	vim.notify = fidget.notify

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
		callback = function(event)
			local map = function(keys, func, desc, mode)
				mode = mode or "n"
				vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
			end

			map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
			map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
			map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if client and client:supports_method("textDocument/documentHighlight", event.buf) then
				local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
				vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
					buffer = event.buf,
					group = highlight_augroup,
					callback = vim.lsp.buf.document_highlight,
				})

				vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					buffer = event.buf,
					group = highlight_augroup,
					callback = vim.lsp.buf.clear_references,
				})

				vim.api.nvim_create_autocmd("LspDetach", {
					group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
					callback = function(event2)
						vim.lsp.buf.clear_references()
						vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
					end,
				})
			end
		end,
	})

	---@type table<string, vim.lsp.Config>
	local servers = {
		pyright = {},
		pylsp = {},
		rust_analyzer = {},
		stylua = {},

		-- Special Lua Config, as recommended by neovim help docs
		lua_ls = {
			on_init = function(client)
				client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

				if client.workspace_folders then
					local path = client.workspace_folders[1].name
					if
						path ~= vim.fn.stdpath("config")
						and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
					then
						return
					end
				end

				client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
					runtime = {
						version = "LuaJIT",
						path = { "lua/?.lua", "lua/?/init.lua" },
					},
					workspace = {
						checkThirdParty = false,
						library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), {
							"${3rd}/luv/library",
							"${3rd}/busted/library",
						}),
					},
				})
			end,
			---@type lspconfig.settings.lua_ls
			settings = {
				Lua = {
					format = { enable = false },
					diagnostics = {
						globals = { "vim" },
					},
				},
			},
		},
	}

	vim.pack.add({
		gh("neovim/nvim-lspconfig"),
		gh("mason-org/mason.nvim"),
		gh("mason-org/mason-lspconfig.nvim"),
		gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
	})

	require("mason").setup({})
	local ensure_installed = vim.tbl_keys(servers or {})
	require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

	for name, server in pairs(servers) do
		vim.lsp.config(name, server)
		vim.lsp.enable(name)
	end
end

-- ============================================================
-- SECTION 6: FORMATTING
-- conform.nvim setup and keymap
-- ============================================================
do
	vim.pack.add({ gh("stevearc/conform.nvim") })
	require("extra.plugins.conform")
end

-- ============================================================
-- SECTION 7: AUTOCOMPLETE & SNIPPETS
-- github-copilot, blink.cmp and luasnip setup
-- ============================================================
do
	vim.pack.add({ { src = gh("L3MON4D3/LuaSnip"), version = vim.version.range("2.*") } })
	require("luasnip").setup({})

	vim.pack.add({ gh("rafamadriz/friendly-snippets") })
	require("luasnip.loaders.from_vscode").lazy_load()

	vim.pack.add({ { src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") } })
	require("blink.cmp").setup({
		keymap = {
			preset = "default",
		},
		appearance = {
			nerd_font_variant = "mono",
		},
		completion = {
			documentation = { auto_show = false, auto_show_delay_ms = 300 },
		},
		sources = {
			default = { "lsp", "path", "snippets" },
		},
		snippets = { preset = "luasnip" },
		fuzzy = { implementation = "lua" },
		signature = { enabled = true },
	})

	vim.pack.add({ gh("github/copilot.vim") })
end

-- ============================================================
-- SECTION 8: TREESITTER
-- Parser installation, syntax highlighting, folds, indentation
-- ============================================================
do
	vim.pack.add({ { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" } })
	require("extra.plugins.treesitter")

	vim.pack.add({ gh("nvim-treesitter/nvim-treesitter-context") })
end

-- ============================================================
-- SECTION 9: EXTRA PLUGINS
-- ============================================================
do
	vim.pack.add({ gh("christoomey/vim-tmux-navigator"), gh("tpope/vim-eunuch"), gh("kdheepak/lazygit.nvim") })

	vim.pack.add({ gh("windwp/nvim-autopairs") })
	require("nvim-autopairs").setup({})

	vim.pack.add({ gh("laytan/cloak.nvim") })
	require("cloak").setup({
		enabled = true,
		cloak_character = "*",
		highlight_group = "Comment",
		patterns = {
			{
				file_pattern = {
					".env*",
					"wrangler.toml",
					".dev.vars",
				},
				cloak_pattern = "=.+",
			},
		},
	})

	vim.pack.add({ gh("folke/trouble.nvim") })
	require("trouble").setup({})
	vim.keymap.set(
		"n",
		"<leader>tt",
		"<cmd>Trouble diagnostics toggle<cr>",
		{ desc = "[T]oggle [T]rouble diagnostics" }
	)

	vim.pack.add({ gh("mbbill/undotree") })
	vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

	vim.pack.add({ gh("mfussenegger/nvim-lint") })
	require("extra.plugins.lint")

	vim.pack.add({ gh("MeanderingProgrammer/render-markdown.nvim") })
	require("extra.plugins.render-markdown")
end

-- ============================================================
-- SECTION 10: WORK CONFIGS
-- ============================================================
do
	require("extra.config.work")
end

-- vim: ts=4 sts=4 sw=4 et
