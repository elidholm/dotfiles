return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    branch = "master",
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = { 
                "lua", "vim", "python", "bash", "css", "csv", "dockerfile", 
                "groovy", "html", "json", "rust", "tsv", "xml", "yaml" 
            },
            sync_install = false,
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
        })
    end
}
