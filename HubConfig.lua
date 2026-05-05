-- ================================================================
--   HubConfig.lua  —  Host this file on GitHub
--   Raw URL format:
--   https://raw.githubusercontent.com/YOURUSER/YOURREPO/main/HubConfig.lua
--
--   Push changes here anytime — players always get the latest version
--   on their next loadstring. You never need to touch the Loader.
-- ================================================================

return {

    -- ── Branding ─────────────────────────────────────────────────
    title   = "⚡ Jordan's Game Hub",
    version = "1.1",
    color   = {88, 130, 255},   -- RGB accent color

    -- ── Tabs & Toggles ───────────────────────────────────────────
    -- onScript  → runs when the player turns the toggle ON
    -- offScript → runs when the player turns it OFF  (optional)
    -- Use [[ ]] for multi-line scripts inside the strings.

    tabs = {

        -- ══════════════════════════════════
        --  MOVEMENT
        -- ══════════════════════════════════
        {
            name = "Movement",
            toggles = {

                {
                    name      = "Speed Hack",
                    desc      = "WalkSpeed → 100",
                    onScript  = [[
                        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
                    ]],
                    offScript = [[
                        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
                    ]],
                },

                {
                    name      = "High Jump",
                    desc      = "JumpPower → 150",
                    onScript  = [[
                        game.Players.LocalPlayer.Character.Humanoid.JumpPower = 150
                    ]],
                    offScript = [[
                        game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
                    ]],
                },

                {
                    name      = "Fly",
                    desc      = "WASD fly | Space/Ctrl up/down",
                    onScript  = [[
                        local lp  = game.Players.LocalPlayer
                        local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
                        local uis = game:GetService("UserInputService")
                        local spd = 50
                        local bv  = Instance.new("BodyVelocity")
                        bv.Name = "HubFlyBV" bv.MaxForce = Vector3.new(1e9,1e9,1e9) bv.Velocity = Vector3.zero bv.Parent = hrp
                        local bg = Instance.new("BodyGyro")
                        bg.Name = "HubFlyBG" bg.MaxTorque = Vector3.new(1e9,1e9,1e9) bg.D = 100 bg.Parent = hrp
                        _G.HubFlyConn = game:GetService("RunService").Heartbeat:Connect(function()
                            local cam = workspace.CurrentCamera
                            local v = Vector3.zero
                            if uis:IsKeyDown(Enum.KeyCode.W) then v = v + cam.CFrame.LookVector  * spd end
                            if uis:IsKeyDown(Enum.KeyCode.S) then v = v - cam.CFrame.LookVector  * spd end
                            if uis:IsKeyDown(Enum.KeyCode.A) then v = v - cam.CFrame.RightVector * spd end
                            if uis:IsKeyDown(Enum.KeyCode.D) then v = v + cam.CFrame.RightVector * spd end
                            if uis:IsKeyDown(Enum.KeyCode.Space)      then v = v + Vector3.new(0,spd,0) end
                            if uis:IsKeyDown(Enum.KeyCode.LeftControl) then v = v - Vector3.new(0,spd,0) end
                            bv.Velocity = v  bg.CFrame = cam.CFrame
                        end)
                    ]],
                    offScript = [[
                        if _G.HubFlyConn then _G.HubFlyConn:Disconnect() _G.HubFlyConn = nil end
                        local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local bv = hrp:FindFirstChild("HubFlyBV") if bv then bv:Destroy() end
                            local bg = hrp:FindFirstChild("HubFlyBG") if bg then bg:Destroy() end
                        end
                    ]],
                },

                {
                    name      = "Infinite Jump",
                    desc      = "Jump again mid-air",
                    onScript  = [[
                        _G.HubInfJump = game:GetService("UserInputService").JumpRequest:Connect(function()
                            game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end)
                    ]],
                    offScript = [[
                        if _G.HubInfJump then _G.HubInfJump:Disconnect() _G.HubInfJump = nil end
                    ]],
                },

                {
                    name      = "Noclip",
                    desc      = "Walk through walls",
                    onScript  = [[
                        _G.HubNoclip = game:GetService("RunService").Stepped:Connect(function()
                            local char = game.Players.LocalPlayer.Character
                            if not char then return end
                            for _, p in ipairs(char:GetDescendants()) do
                                if p:IsA("BasePart") then p.CanCollide = false end
                            end
                        end)
                    ]],
                    offScript = [[
                        if _G.HubNoclip then _G.HubNoclip:Disconnect() _G.HubNoclip = nil end
                    ]],
                },

            },
        },

        -- ══════════════════════════════════
        --  VISUAL
        -- ══════════════════════════════════
        {
            name = "Visual",
            toggles = {

                {
                    name      = "Fullbright",
                    desc      = "Max ambient lighting",
                    onScript  = [[
                        _G.HubOldBright  = game.Lighting.Brightness
                        _G.HubOldAmbient = game.Lighting.Ambient
                        game.Lighting.Brightness = 10
                        game.Lighting.Ambient    = Color3.fromRGB(255,255,255)
                    ]],
                    offScript = [[
                        game.Lighting.Brightness = _G.HubOldBright  or 1
                        game.Lighting.Ambient    = _G.HubOldAmbient or Color3.fromRGB(127,127,127)
                    ]],
                },

                {
                    name      = "ESP Players",
                    desc      = "Box highlight all players",
                    onScript  = [[
                        local svc = game:GetService("Players")
                        local lp  = svc.LocalPlayer
                        _G.HubESPBoxes = {}
                        local function applyChar(char, name)
                            local box = Instance.new("SelectionBox")
                            box.Name = "HubESP_"..name
                            box.Color3 = Color3.fromRGB(255,50,50)
                            box.SurfaceColor3 = Color3.fromRGB(255,50,50)
                            box.SurfaceTransparency = 0.8
                            box.LineThickness = 0.05
                            box.Adornee = char
                            box.Parent = workspace
                            table.insert(_G.HubESPBoxes, box)
                        end
                        local function addPlayer(p)
                            if p == lp then return end
                            if p.Character then applyChar(p.Character, p.Name) end
                            p.CharacterAdded:Connect(function(c) applyChar(c, p.Name) end)
                        end
                        for _, p in ipairs(svc:GetPlayers()) do addPlayer(p) end
                        _G.HubESPConn = svc.PlayerAdded:Connect(addPlayer)
                    ]],
                    offScript = [[
                        if _G.HubESPConn then _G.HubESPConn:Disconnect() _G.HubESPConn = nil end
                        if _G.HubESPBoxes then
                            for _, b in ipairs(_G.HubESPBoxes) do if b and b.Parent then b:Destroy() end end
                            _G.HubESPBoxes = nil
                        end
                    ]],
                },

                {
                    name      = "No Fog",
                    desc      = "Removes atmospheric fog",
                    onScript  = [[
                        _G.HubOldFogEnd   = game.Lighting.FogEnd
                        _G.HubOldFogStart = game.Lighting.FogStart
                        game.Lighting.FogEnd   = 100000
                        game.Lighting.FogStart = 100000
                    ]],
                    offScript = [[
                        game.Lighting.FogEnd   = _G.HubOldFogEnd   or 1000
                        game.Lighting.FogStart = _G.HubOldFogStart or 0
                    ]],
                },

            },
        },

        -- ══════════════════════════════════
        --  MISC
        -- ══════════════════════════════════
        {
            name = "Misc",
            toggles = {

                {
                    name      = "Anti-AFK",
                    desc      = "Prevents auto-kick timer",
                    onScript  = [[
                        local vu = game:GetService("VirtualUser")
                        _G.HubAFKConn = game:GetService("Players").LocalPlayer.Idled:Connect(function()
                            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                            task.wait(1)
                            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                        end)
                    ]],
                    offScript = [[
                        if _G.HubAFKConn then _G.HubAFKConn:Disconnect() _G.HubAFKConn = nil end
                    ]],
                },

                -- ─────────────────────────────────────────────────
                -- ADD MORE TOGGLES HERE — push to GitHub to deploy
                -- {
                --     name      = "My Feature",
                --     desc      = "Does something cool",
                --     onScript  = [[ print("on")  ]],
                --     offScript = [[ print("off") ]],
                -- },
                -- ─────────────────────────────────────────────────

            },
        },

        -- ══════════════════════════════════
        --  GAMES  (game-specific scripts)
        --  Add a new block per game below.
        --  Tip: use PlaceId checks in your
        --  onScript to guard against wrong games.
        -- ══════════════════════════════════
        {
            name = "Games",
            toggles = {

                -- ──────────────────────────────────
                --  🏠 PENTHOUSE TYCOON
                --  PlaceId: 7205494657
                -- ──────────────────────────────────
                {
                    name      = "Penthouse Tycoon",
                    desc      = "Game-specific script",
                    onScript  = [[
                        -- !! PASTE YOUR PENTHOUSE TYCOON SCRIPT BELOW !!
                        -- Example structure — replace everything inside:

                        local placeId = 7205494657
                        if game.PlaceId ~= placeId then
                            warn("[Hub] Wrong game! This script is for Penthouse Tycoon.")
                            return
                        end

                        -- YOUR SCRIPT GOES HERE:
                        print("Penthouse Tycoon script running!")

                        -- !! END OF YOUR SCRIPT !!
                    ]],
                    offScript = [[
                        -- Optional: cleanup when toggled off
                        -- e.g. disconnect connections, restore values
                        print("Penthouse Tycoon script stopped.")
                    ]],
                },

                -- ──────────────────────────────────
                -- ADD MORE GAMES BELOW THIS LINE
                -- Copy the block above, change the
                -- name, desc, PlaceId, and scripts.
                -- ──────────────────────────────────
                -- {
                --     name      = "Game Name Here",
                --     desc      = "Short description",
                --     onScript  = [[
                --         local placeId = 0000000000  -- replace with real PlaceId
                --         if game.PlaceId ~= placeId then
                --             warn("[Hub] Wrong game!")
                --             return
                --         end
                --         -- YOUR SCRIPT HERE
                --     ]],
                --     offScript = [[
                --         -- CLEANUP HERE
                --     ]],
                -- },

            },
        },

    },
}