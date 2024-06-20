return {
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
        init = function()
                -- set an empty statusline till lualine loads
                vim.o.statusline = " "
        end,
        opts = {},
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        event = "LazyFile",
        main = "ibl",
        opts = {
            indent = { char = "▏" },
            scope = {
                show_start = false,
                show_end = false,
            },
        },
    },
}
