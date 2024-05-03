return {
    {
        "skosulor/nibbler",
        event = { "BufReadPre", "BufNewFile" },
        cmd = {
            "NibblerToBin",
            "NibblerToHex",
            "NibblerToDec",
            "NibblerToCArray",
            "NibblerHexStringToCArray",
            "NibblerToggle",
        },
        opts = {
            display_enabled = true,
        },
    },
}
