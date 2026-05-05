-- ================================================================
--   Games/PenthouseTycoon.lua
--   https://raw.githubusercontent.com/JRodriguez07/RobloxThings/refs/heads/main/Games/PenthouseTycoon.lua
--
--   This file contains all scripts for Penthouse Tycoon.
--   Edit only this file when adding/changing scripts for this game.
--   Push to GitHub — all players get the update on next load.
-- ================================================================

local PLACE_ID = 124943244212764

-- Quick guard used at the top of every onScript
local guard = string.format([[
    if game.PlaceId ~= %d then
        warn("[Hub] This script is for Penthouse Tycoon only.")
        return
    end
]], PLACE_ID)

return {

    name    = "Penthouse Tycoon",
    desc    = "Tycoon game",
    placeId = PLACE_ID,

    scripts = {

        -- ── Script 1 ─────────────────────────────────────────────
{
    name     = "Money Auto Collect",
    desc     = "Collects money every 5 seconds",
    onScript = guard .. [[
        _G.PTMoneyLoopActive = true
        task.spawn(function()
            while _G.PTMoneyLoopActive do
                pcall(function()
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("__remotes", 5)
                        :WaitForChild("TycoonService", 5)
                        :WaitForChild("CollectMoneyTS", 5)
                        :FireServer()
                end)
                task.wait(5)
            end
        end)
    ]],
    offScript = [[
        _G.PTMoneyLoopActive = false
    ]],
},

        -- ── Script 2 ─────────────────────────────────────────────
        {
            name     = "Script 2",
            desc     = "Replace with your script",
            onScript = guard .. [[

                -- !! YOUR SCRIPT FOR PENTHOUSE TYCOON GOES HERE !!
                print("Script 2 ON — replace this with your code")

            ]],
            offScript = [[
                print("Script 2 OFF")
            ]],
        },

        -- ── Script 3 ─────────────────────────────────────────────
        {
            name     = "Script 3",
            desc     = "Replace with your script",
            onScript = guard .. [[

                print("Script 3 ON — replace this with your code")

            ]],
            offScript = [[
                print("Script 3 OFF")
            ]],
        },

        -- ─────────────────────────────────────────────────────────
        -- ADD MORE SCRIPTS BELOW — copy a block above and fill it in
        -- ─────────────────────────────────────────────────────────

    },
}