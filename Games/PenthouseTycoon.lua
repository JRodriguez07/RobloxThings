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
    name      = "Auto Buy",
    desc      = "Automatically buys all tycoon buttons",
    onScript  = guard .. [[
        _G.PTAutoBuyActive = true
        task.spawn(function()
            while _G.PTAutoBuyActive do
                local char = game.Players.LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local tycoon = workspace:FindFirstChild("Tycoons")
                    and workspace.Tycoons:FindFirstChild("1")
                    and workspace.Tycoons["1"]:FindFirstChild("Tycoon")
                local penthouse = tycoon and tycoon:FindFirstChild("Penthouse3")
                local buttons = penthouse and penthouse:FindFirstChild("Buttons")

                if buttons and hrp then
                    for _, btn in ipairs(buttons:GetChildren()) do
                        if not _G.PTAutoBuyActive then break end
                        local press = btn:FindFirstChild("Press")
                        if press then
                            firetouchinterest(hrp, press, 0) -- touch
                            task.wait(0.1)
                            firetouchinterest(hrp, press, 1) -- untouch
                            task.wait(0.3)
                        end
                    end
                end

                task.wait(5)
            end
        end)
    ]],
    offScript = [[
        _G.PTAutoBuyActive = false
    ]],
},

    },
}