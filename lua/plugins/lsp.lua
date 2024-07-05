-- Adapted from kickstart.nvim
return {
    {
        "neovim/nvim-lspconfig",
        event = "LazyFile",
        dependencies = {
            -- Automatically install LSPs and related tools to stdpath for Neovim
            { "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",

            -- Useful status updates for LSP.
            {
                "j-hui/fidget.nvim",
                opts = {
                    progress = {
                        display = {
                            done_icon = "",
                        },
                    },
                    notification = {
                        window = {
                            winblend = 0,
                        },
                    },
                },
            },
        },
        config = function()
            --  This function gets run when an LSP attaches to a particular buffer.
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc)
                        vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                    end

                    -- Jump to the definition of the word under your cursor.
                    --  To jump back, press <C-T>.
                    map("gd", function()
                        require("telescope.builtin").lsp_definitions()
                    end, "[G]oto [D]efinition")

                    -- Find references for the word under your cursor.
                    map("gr", function()
                        require("telescope.builtin").lsp_references()
                    end, "[G]oto [R]eferences")

                    -- Jump to the implementation of the word under your cursor.
                    map("gI", function()
                        require("telescope.builtin").lsp_implementations()
                    end, "[G]oto [I]mplementation")

                    -- Jump to the type of the word under your cursor.
                    map("<leader>D", function()
                        require("telescope.builtin").lsp_type_definitions()
                    end, "Type [D]efinition")

                    -- Fuzzy find all the symbols in your current document.
                    map("<leader>ds", function()
                        require("telescope.builtin").lsp_document_symbols()
                    end, "[D]ocument [S]ymbols")

                    -- Fuzzy find all the symbols in your current workspace
                    map("<leader>ws", function()
                        require("telescope.builtin").lsp_dynamic_workspace_symbols()
                    end, "[W]orkspace [S]ymbols")

                    map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

                    map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

                    -- This is now default in 0.10
                    map("K", vim.lsp.buf.hover, "Hover Documentation")

                    -- WARN: This is not Goto Definition, this is Goto Declaration.
                    --  For example, in C this would take you to the header
                    map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

                    -- Highlight references of word under your cursor when idle.
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client.server_capabilities.documentHighlightProvider then
                        local highlight_augroup =
                            vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
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

                    -- Toggle inlay hints
                    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
                        map("<leader>th", function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
                        end, "[T]oggle Inlay [H]ints")
                    end
                end,
            })

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

            local servers = {
                lua_ls = {
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = "Replace",
                            },
                        },
                    },
                },
            }

            require("mason").setup({
                ui = {
                    border = "rounded",
                    width = 0.8,
                    height = 0.8,
                },
            })

            local ensure_installed = vim.tbl_keys(servers or {})
            vim.list_extend(ensure_installed, {
                "stylua", -- Used to format lua code
            })
            require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

            require("mason-lspconfig").setup({
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                        require("lspconfig")[server_name].setup(server)
                    end,
                },
            })
        end,
    },
    {
        "stevearc/conform.nvim",
        lazy = false,
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>cf",
                function()
                    require("conform").format({ async = true, lsp_fallback = true })
                end,
                mode = "",
                desc = "Format buffer",
            },
        },
        opts = {
            notify_on_error = false,
            format_on_save = function(bufnr)
                -- Disable "format_on_save lsp_fallback" for languages that don't
                -- have a well standardized coding style. You can add additional
                -- languages here or re-enable it for the disabled ones.
                local disable_filetypes = { c = true, cpp = true }
                return {
                    timeout_ms = 500,
                    lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
                }
            end,
            -- Currently using LSP formatting. Custom formatters can be set here.
            formatters_by_ft = {
                lua = { "stylua" },
            },
        },
    },
}
