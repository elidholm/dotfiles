require('solarized').setup({
    transparent = {
        enabled = true,
    },
    palette = 'selenized',
    styles = {
        comments = { italic = true, bold = false },
    },
    variant = 'winter',
    plugins = {
        lsp = true,
        telescope = true,
        treesitter = true,
        cmp = true,
    },
    autocmd = true,
})

function ColorMyPencils(color)
	color = color or "solarized"
    vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

end

ColorMyPencils()
