return {
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            local npairs = require("nvim-autopairs")
            local Rule = require("nvim-autopairs.rule")
            local cond = require("nvim-autopairs.conds")
            local ts_cond = require("nvim-autopairs.ts-conds")

            npairs.setup({
                check_ts = true,
                ts_config = {
                    typst = { "formula", "math", "raw_blck", "blob" },
                    markdown = { "latex_block", "code_span", "fenced_code_block" },
                },
            })

            local conds = {
                True = function(_)
                    return function()
                        return true
                    end
                end,
                False = function(_)
                    return function(_)
                        return false
                    end
                end,
                ---@param chk_conds [fun(opts)]
                And = function(chk_conds)
                    local f = function(opts)
                        return vim.iter(chk_conds):all(function(chk_cond)
                            return chk_cond(opts)
                        end)
                    end
                    return f
                end,
                ---@param chk_conds [fun(opts)]
                Or = function(chk_conds)
                    return function(opts)
                        return vim.iter(chk_conds):any(function(chk_cond)
                            return chk_cond(opts)
                        end)
                    end
                end,
                Nil = function(chk_cond)
                    return function(opts)
                        return chk_cond(opts) == nil
                    end
                end,
                Not = function(chk_cond)
                    local f = function(opts)
                        return not chk_cond(opts)
                    end
                    return f
                end,
                in_ts_node = function(node_names)
                    if type(node_names) == "string" then
                        node_names = { node_names }
                    end
                    assert(node_names ~= nil, "ts nodes should be string or table")
                    return function(opts)
                        if #node_names == 0 then
                            return
                        end

                        ---@param node TSNode?
                        ---@param nodes [string]
                        local node_within_tree = function(node, nodes)
                            while node do
                                if node and vim.list_contains(nodes, node:type()) then
                                    return true
                                end
                                node = node:parent()
                            end
                            return false
                        end

                        vim.treesitter.get_parser():parse()

                        return node_within_tree(vim.treesitter.get_node(), node_names)
                            or node_within_tree(vim.treesitter.get_node({ ignore_injections = false }), node_names)
                    end
                end,
            }

            ---@param char string
            local OrgPair = function(char)
                return Rule(char, char, { "org" })
                    :with_pair(ts_cond.is_not_ts_node({ "block", "link" }))
                    :with_pair(conds.And({ cond.not_before_text("["), cond.not_after_text("]") }))
                    :with_pair(conds.And({ cond.not_before_text("$"), cond.not_after_text("$") }))
                    :with_move(cond.done())
            end

            npairs.add_rules({
                OrgPair("~"),
                OrgPair("_"),
                OrgPair("/"),
                OrgPair("="),
                OrgPair("$"),
                OrgPair("/"),
                OrgPair("*"):with_pair(cond.not_before_regex("^$")):with_pair(cond.not_before_regex("%*")),
            })

            ---@param char string
            local MDPair = function(char)
                return Rule(char, char, { "markdown" }):with_pair(
                    conds.Not(conds.in_ts_node({ "latex_block", "code_span", "fenced_code_block" }))
                )
            end

            ---@param opts CondOpts
            local md_is_in_bold_italics = function(opts)
                ---@type string
                ---@diagnostic disable-next-line: undefined-field
                local line = opts.line
                ---@type integer
                ---@diagnostic disable-next-line: undefined-field
                local col = opts.col
                if ts_cond.is_ts_node({ "strong_emphasis" })(opts) and ts_cond.is_ts_node({ "emphasis" })(opts) then
                    return true
                end

                if col <= 1 then
                    return false
                end

                if col - 2 == 0 then
                    return false
                end
                local next = line:sub(col, col + 1)
                local prev = line:sub(col, col - 2)
                if prev == "***" and next == "***" then
                    return true
                end

                if col - 3 ~= 0 and line:sub(col - 3, col) == "****" and line:sub(col, col + 1) == "**" then
                    return true
                end

                if col - 4 ~= 0 and line:sub(col - 4, col) == "*****" and line:sub(col, col) == "*" then
                    return true
                end

                return false
            end
            npairs.add_rules({
                MDPair("*"):with_pair(conds.Not(md_is_in_bold_italics)):with_move(md_is_in_bold_italics),
                MDPair("_"):with_move(cond.done()),
            })

            ---@param char string
            local TypstPair = function(char)
                local chks = {
                    conds.Not(conds.in_ts_node({ "formula", "math", "raw_blck", "blob", "string" })),
                    conds.Nil(cond.not_inside_quote()),
                }
                return Rule(char, char, { "typst" }):with_pair(conds.And(chks)):with_move(conds.And(chks))
            end

            npairs.add_rules({
                TypstPair("*"),
                TypstPair("_"),
                TypstPair("$"),
            })
        end,
    },
}
