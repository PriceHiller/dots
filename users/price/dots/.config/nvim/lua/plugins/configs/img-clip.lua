return {
    {
        "HakonHarnes/img-clip.nvim",
        cmd = {
            "PasteImage",
            "ImgClipDebug",
            "ImgClipConfig",
        },
        keys = {
            { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste Image" },
        },
        config = function()
            require("img-clip").setup({
                default = {
                    relative_to_current_file = true,
                    dir_path = function()
                        local relpath_parts = {}
                        local root = vim.fs.root(0, function(name, path)
                            if not vim.list_contains(relpath_parts, path) then
                                table.insert(relpath_parts, path)
                            end
                            return vim.list_contains({ "assets", ".git" }, name) and vim.fn.isdirectory(path) == 1
                        end)
                        local relpath = ""

                        if root then
                            relpath = string.rep("../", #relpath_parts - 1)
                        else
                            relpath = "./"
                        end
                        local assets_dir = relpath .. "assets/" .. vim.fn.fnameescape(vim.fn.expand("%:t:r")) .. "/"
                        assets_dir = vim.fs.normalize(assets_dir, { expand_env = false })
                        return assets_dir
                    end,
                },
                filetypes = {
                    typst = {
                        template = [[#image("$FILE_PATH")]],
                    },
                    org = {
                        template = "[[file:$FILE_PATH]]",
                    },
                },
            })
        end,
    },
}
