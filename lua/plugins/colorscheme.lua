return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                flavour = "mocha",
                transparent_background = true,
                integrations = {
                    cmp = true,
                    fidget = true,
                    gitsigns = true,
                    indent_blankline = {
                        enabled = true,
                        scope_color = "lavender",
                        colored_indent_levels = false,
                    },
                    mason = true,
                    telescope = {
                        enabled = true,
                    },
                    treesitter = true,
                },
            })
            vim.cmd.colorscheme("catppuccin")
        end,
    },
}
