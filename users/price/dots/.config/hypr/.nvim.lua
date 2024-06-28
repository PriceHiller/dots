local cur_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")

vim.filetype.add({
    extension = {
        conf = function(path)
            if path:sub(1, cur_dir:len()) == cur_dir then
                return "hyprlang"
            end
        end,
    },
})
