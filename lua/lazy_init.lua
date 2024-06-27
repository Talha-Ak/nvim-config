local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("util").lazy_file()
require("lazy").setup("plugins", {
    ui = {
        border = "rounded",
        title = " Lazy Package Manager ",
    },
    performance = {
        disabled_plugins = {
            "gzip",
            "tarPlugin",
            "toHtml",
            "tutor",
            "zipPlugin",
        },
    },
})
