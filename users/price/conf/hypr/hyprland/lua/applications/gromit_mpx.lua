hl.workspace_rule({
    workspace = "special:gromit",
    gaps_in = 0,
    gaps_out = 0,
    decorate = false,
    no_border = true,
})

local match = { class = "^(Gromit-mpx)$" }

hl.window_rule({ match = match, workspace = "special:gromit silent" })
hl.window_rule({ match = match, no_blur = true })
hl.window_rule({ match = match, opacity = "1 override" })
hl.window_rule({ match = match, suppress_event = "fullscreen maximize" })
hl.window_rule({ match = match, no_shadow = true })
hl.window_rule({ match = match, suppress_event = "fullscreen" })
hl.window_rule({ match = match, no_anim = true })
hl.window_rule({ match = match, no_dim = true })
hl.window_rule({ match = match, size = { "100%", "100%" } })

---@return boolean
local function gromit_visible()
    local ws = hl.get_workspace("special:gromit")
    return ws ~= nil and ws.active
end

local was_visible = gromit_visible()
hl.on("workspace.special_active", function()
    -- Events from other monitors/special workspaces must not toggle Gromit.
    local visible = gromit_visible()
    if visible == was_visible then
        return
    end

    was_visible = visible
    if visible then
        -- The systemd scope tracks gromit for us, makes it a _lot_ easier to determine the current
        -- state of gromit.
        --
        -- Important: I use a scope so we can inherit the full environment of the user so I don't
        -- have to do `setenv` or other calls
        hl.exec_cmd([[
            if systemctl --user is-active --quiet hyprland-gromit.scope; then
                gromit-mpx --toggle
            else
                exec systemd-run --user --scope --unit=hyprland-gromit.scope \
                    --collect \
                    --property=PartOf=hyprland-session.target \
                    "$(command -v gromit-mpx)" --active --key none --undo-key none
            fi
        ]])
    else
        hl.exec_cmd([[
            if systemctl --user is-active --quiet hyprland-gromit.scope; then
                gromit-mpx --toggle
            fi
        ]])
    end
    hl.dispatch(hl.dsp.submap(visible and "gromit" or "reset"))
end)

local function toggle_gromit()
    hl.dispatch(hl.dsp.workspace.toggle_special("gromit"))
end

hl.bind("CTRL + SUPER + x", toggle_gromit)

hl.define_submap("gromit", function()
    hl.bind("c", hl.dsp.exec_cmd("gromit-mpx --clear"))
    hl.bind("CTRL + z", hl.dsp.exec_cmd("gromit-mpx --undo"))
    hl.bind("z", hl.dsp.exec_cmd("gromit-mpx --redo"))

    hl.bind("escape", toggle_gromit)
end)
