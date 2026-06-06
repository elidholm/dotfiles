-- ============================================================
-- SECTION 1: FOUNDATION
-- Core Neovim settings, leaders, options, basic keymaps, basic autocmds
-- ============================================================
do
	vim.loader.enable()

	vim.g.mapleader = " "
	vim.g.maplocalleader = " "

	vim.g.have_nerd_font = true

	vim.g.netrw_browse_split = 0
	vim.g.netrw_banner = 0
	vim.g.netrw_winsize = 25

	vim.opt.number = true
	vim.opt.relativenumber = true

	vim.opt.mouse = "a"
	vim.opt.showmode = false

	vim.opt.wrap = false
	vim.opt.smartindent = true

	vim.api.nvim_command("filetype plugin indent on")
	vim.opt.expandtab = true
	vim.opt.tabstop = 4
	vim.opt.softtabstop = 4
	vim.opt.shiftwidth = 4

	vim.opt.swapfile = false
	vim.opt.backup = false
	vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
	vim.opt.undofile = true

	vim.opt.ignorecase = true
	vim.opt.smartcase = true
	vim.opt.hlsearch = false
	vim.opt.incsearch = true

	vim.opt.termguicolors = true
	vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"

	vim.opt.updatetime = 250
	vim.opt.timeoutlen = 300

	vim.opt.splitright = true
	vim.opt.splitbelow = true

	vim.opt.list = true
	vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

	vim.opt.scrolloff = 10
	vim.opt.signcolumn = "yes"
	vim.opt.cursorline = true

	vim.opt.colorcolumn = "120"
	vim.opt.isfname:append("@-@")

	vim.opt.inccommand = "split"

	vim.opt.confirm = true
	vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

	vim.diagnostic.config({
		update_in_insert = false,
		severity_sort = true,
		float = { border = "rounded", source = "if_many" },
		underline = { severity = { min = vim.diagnostic.severity.WARN } },

		virtual_text = true, -- Text shows up at the end of the line
		virtual_lines = false, -- Text shows up underneath the line, with virtual lines

		-- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
		jump = {
			on_jump = function(_, bufnr)
				vim.diagnostic.open_float({
					bufnr = bufnr,
					scope = "cursor",
					focus = false,
				})
			end,
		},
	})

	vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

	vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

	vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>', { desc = "Disable left arrow key in normal mode" })
	vim.keymap.set(
		"n",
		"<right>",
		'<cmd>echo "Use l to move!!"<CR>',
		{ desc = "Disable right arrow key in normal mode" }
	)
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
	vim.keymap.set(
		"n",
		"<leader>dq",
		'ciW"<C-r>""<Esc>',
		{ desc = "Surround word under cursor with [D]ouble [Q]uotes" }
	)
	vim.keymap.set("v", "<leader>sq", "c'<C-r>\"'<Esc>", { desc = "Surround selection with [S]ingle [Q]uotes" })
	vim.keymap.set(
		"n",
		"<leader>sq",
		"ciW'<C-r>\"'<Esc>",
		{ desc = "Surround word under cursor with [S]ingle [Q]uotes" }
	)
	vim.keymap.set("n", "<leader>uq", 'di"hPl2x', { desc = "Remove surrounding double quotes from word under cursor" })

	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "Highlight when yanking (copying) text",
		group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
		pattern = "*",
		callback = function()
			vim.hl.on_yank({
				higroup = "IncSearch",
				timeout = 40,
			})
		end,
	})

	vim.api.nvim_create_autocmd({ "BufWritePre" }, {
		group = vim.api.nvim_create_augroup("conf", {}),
		pattern = "*",
		command = [[%s/\s\+$//e]],
	})
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
	vim.cmd.colorscheme("catppuccin-nvim")
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

	vim.pack.add({ gh("folke/todo-comments.nvim") })
	require("todo-comments").setup({ signs = false })

	vim.pack.add({ gh("nvim-mini/mini.nvim") })
	require("mini.ai").setup({
		mappings = {
			around_next = "aa",
			inside_next = "ii",
		},
		n_lines = 500,
	})
	require("mini.surround").setup({})
	local statusline = require("mini.statusline")
	statusline.setup({ use_icons = vim.g.have_nerd_font })

	---@diagnostic disable-next-line: duplicate-set-field
	statusline.section_location = function()
		return "%2l:%-2v"
	end
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

	require("telescope").setup({
		extensions = {
			["ui-select"] = { require("telescope.themes").get_dropdown() },
		},
	})
	pcall(require("telescope").load_extension, "fzf")
	pcall(require("telescope").load_extension, "ui-select")
	local builtin = require("telescope.builtin")
	vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
	vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
	vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
	vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
	vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
	vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
	vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
	vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
	vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
	vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })
	vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[F]ind existing [B]uffers" })

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
		callback = function(event)
			local buf = event.buf
			vim.keymap.set("n", "grr", builtin.lsp_references, { buffer = buf, desc = "[G]oto [R]eferences" })
			vim.keymap.set("n", "gri", builtin.lsp_implementations, { buffer = buf, desc = "[G]oto [I]mplementation" })
			vim.keymap.set("n", "grd", builtin.lsp_definitions, { buffer = buf, desc = "[G]oto [D]efinition" })
			vim.keymap.set("n", "gO", builtin.lsp_document_symbols, { buffer = buf, desc = "Open Document Symbols" })
			vim.keymap.set(
				"n",
				"gW",
				builtin.lsp_dynamic_workspace_symbols,
				{ buffer = buf, desc = "Open Workspace Symbols" }
			)
			vim.keymap.set(
				"n",
				"grt",
				builtin.lsp_type_definitions,
				{ buffer = buf, desc = "[G]oto [T]ype Definition" }
			)
		end,
	})

	vim.keymap.set("n", "<leader>/", function()
		builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
			previewer = false,
		}))
	end, { desc = "[/] Fuzzily search in current buffer" })

	vim.keymap.set("n", "<leader>s/", function()
		builtin.live_grep({
			grep_open_files = true,
			prompt_title = "Live Grep in Open Files",
		})
	end, { desc = "[S]earch [/] in Open Files" })

	-- Shortcut for searching your Neovim configuration files
	vim.keymap.set("n", "<leader>sn", function()
		builtin.find_files({
			cwd = vim.fn.stdpath("config"),
		})
	end, { desc = "[S]earch [N]eovim files" })

	vim.pack.add({ gh("theprimeagen/harpoon") })
	require("harpoon").setup({})
	vim.keymap.set("n", "<leader>a", require("harpoon.mark").add_file)
	vim.keymap.set("n", "<C-e>", require("harpoon.ui").toggle_quick_menu)
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
	require("conform").setup({
		notify_on_error = false,
		format_on_save = function(bufnr)
			local enabled_filetypes = {
				lua = true,
				python = true,
				sh = true,
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
			python = { "isort", "black" },
			sh = { "shfmt" },
		},
		formatters = {
			shfmt = {
				append_args = { "-i", "2" },
			},
		},
	})

	vim.keymap.set({ "n", "v" }, "<leader>f", function()
		require("conform").format({ async = true })
	end, { desc = "[F]ormat buffer" })
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
	local parsers = {
		"lua",
		"vim",
		"python",
		"bash",
		"css",
		"csv",
		"dockerfile",
		"groovy",
		"html",
		"json",
		"rust",
		"tsv",
		"xml",
		"yaml",
	}
	require("nvim-treesitter").install(parsers)

	---@param buf integer
	---@param language string
	local function treesitter_try_attach(buf, language)
		if not vim.treesitter.language.add(language) then
			return
		end
		vim.treesitter.start(buf, language)
	end

	local available_parsers = require("nvim-treesitter").get_available()
	vim.api.nvim_create_autocmd("FileType", {
		callback = function(args)
			local buf, filetype = args.buf, args.match

			local language = vim.treesitter.language.get_lang(filetype)
			if not language then
				return
			end

			local installed_parsers = require("nvim-treesitter").get_installed("parsers")

			if vim.tbl_contains(installed_parsers, language) then
				treesitter_try_attach(buf, language)
			elseif vim.tbl_contains(available_parsers, language) then
				require("nvim-treesitter").install(language):await(function()
					treesitter_try_attach(buf, language)
				end)
			else
				treesitter_try_attach(buf, language)
			end
		end,
	})
end

-- ============================================================
-- SECTION 9: EXTRA PLUGINS
-- ============================================================
do
	vim.pack.add({ gh("christoomey/vim-tmux-navigator") })

	vim.pack.add({ gh("tpope/vim-eunuch") })

	vim.pack.add({ gh("kdheepak/lazygit.nvim") })

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
	local lint = require("lint")
	lint.linters_by_ft = {
		markdown = { "markdownlint" },
		python = { "ruff" },
		json = { "jsonlint" },
		lua = { "luacheck" },
		text = { "vale" },
		sh = { "shellcheck" },
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

	vim.pack.add({ gh("nvim-treesitter/nvim-treesitter-context") })
end

-- ============================================================
-- SECTION 10: WORK CONFIGS
-- ============================================================
do
	vim.filetype.add({
		filename = {
			["Taskfile"] = "yaml",
		},
	})
end
-- vim: ts=4 sts=4 sw=4 et
