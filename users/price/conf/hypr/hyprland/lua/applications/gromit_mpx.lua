hl.workspace_rule({
    workspace = "special:gromit",
    gaps_in = 0,
    gaps_out = 0,
    decorate = false,
    no_border = true,
    -- When the special workspace is first toggled-into, spawn gromit-mpx in
    -- annotation mode (-a). Subsequent toggles just hide/show it.
    on_created_empty = "gromit-mpx -a",
})

local match = { class = "^(Gromit-mpx)$" }

hl.window_rule({ match = match, no_blur = true })
hl.window_rule({ match = match, opacity = "1 override" })
hl.window_rule({ match = match, suppress_event = "fullscreen maximize" })
hl.window_rule({ match = match, no_shadow = true })
hl.window_rule({ match = match, suppress_event = "fullscreen" })
hl.window_rule({ match = match, no_anim = true })
hl.window_rule({ match = match, no_dim = true })
hl.window_rule({ match = match, size = { "100%", "100%" } })

local function open_gromit()
    hl.dispatch(hl.dsp.workspace.toggle_special("gromit"))
    hl.dispatch(hl.dsp.submap("gromit"))
end

local function close_gromit()
    hl.dispatch(hl.dsp.workspace.toggle_special("gromit"))
    hl.dispatch(hl.dsp.submap("reset"))
end

hl.bind("CTRL + SUPER + x", open_gromit)

hl.define_submap("gromit", function()
    hl.bind("c", hl.dsp.exec_cmd("gromit-mpx --clear"))
    hl.bind("CTRL + z", hl.dsp.exec_cmd("gromit-mpx --undo"))
    hl.bind("z", hl.dsp.exec_cmd("gromit-mpx --redo"))

    hl.bind("escape", close_gromit)
end)
