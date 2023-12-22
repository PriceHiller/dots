return {
    {
        "jbyuki/nabla.nvim",
        keys = {
            { ";nn", function() require("nabla").popup() end, desc = "Nabla: Popup" },
            {
                ";nv",
                function()
                    require("nabla").toggle_virt()
                end,
                desc = "Nabla: Toggle Virt Lines"
            }
        },
        ft = {
            "org",
            "tex"
        },
        config = false
    }
}
