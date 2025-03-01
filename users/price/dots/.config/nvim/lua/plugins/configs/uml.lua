local plantuml_fts = { "plantuml", "puml", "uml", "pu", "iuml" }

return {
    {
        "aklt/plantuml-syntax",
        config = false,
        ft = plantuml_fts,
    },
    {
        "weirongxu/plantuml-previewer.vim",
        dependencies = {
            "tyru/open-browser.vim",
        },
        ft = plantuml_fts,
        cmd = {
               "PlantumlOpen",
               "PlantumlStop",
               "PlantumlSave",
           },
        config = false,
    },
}
