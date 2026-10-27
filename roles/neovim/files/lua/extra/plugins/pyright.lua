local default_markers = {
	"pyrightconfig.json",
	"pyproject.toml",
	"setup.py",
	"setup.cfg",
	"requirements.txt",
	"Pipfile",
	".git",
}

local function glob(pattern)
	return vim.fn.glob(pattern, false, true)
end

local function pants_default_resolve(pants_root)
	local in_python_section = false
	for _, line in ipairs(vim.fn.readfile(pants_root .. "/pants.toml")) do
		local section = line:match("^%s*%[([^%]]+)%]")
		if section then
			in_python_section = section == "python"
		elseif in_python_section then
			local resolve = line:match([=[^%s*default_resolve%s*=%s*["']([^"']+)["']]=])
			if resolve then
				return resolve
			end
		end
	end

	return "python-default"
end

---@type vim.lsp.Config
return {
	-- Keep the nearest Python project root so Pyright loads app configs and virtualenvs correctly.
	root_dir = function(bufnr, on_dir)
		on_dir(vim.fs.root(bufnr, default_markers))
	end,

	on_init = function(client)
		local root = client.root_dir
		local pants_root = root and vim.fs.root(root, "pants.toml")
		if not pants_root then
			return
		end

		local resolve = pants_default_resolve(pants_root)
		local python = glob(pants_root .. "/dist/export/python/virtualenvs/" .. resolve .. "/*/bin/python")[1]
		local extra_paths = vim.list_extend(glob(pants_root .. "/libs/*/src"), glob(pants_root .. "/apps/*/src"))

		client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
			python = {
				pythonPath = python,
				analysis = { extraPaths = extra_paths },
			},
		})
		client:notify("workspace/didChangeConfiguration", { settings = client.settings })
	end,
}
