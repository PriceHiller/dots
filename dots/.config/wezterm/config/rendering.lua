return {
    freetype_load_target = "Normal",
    window_padding = {
        left = 2,
        right = 0,
        top = 0,
        bottom = 0,
    },
    enable_scroll_bar = true,
    -- HACK: This lets custom chars like '' render better,
    -- HACK: but wez intends to resolve and remove this at a later time
    anti_alias_custom_block_glyphs = false,
}
