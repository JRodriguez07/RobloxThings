-- ================================================================
--   HubLoader.lua
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/JRodriguez07/RobloxThings/refs/heads/main/HubLoader.lua"))()
--
--   This file never needs to change. All content lives in:
--     HubConfig.lua   — branding, tabs, list of game file URLs
--     Games/*.lua     — one file per game
-- ================================================================

local CONFIG_URL = "https://raw.githubusercontent.com/JRodriguez07/RobloxThings/refs/heads/main/HubConfig.lua"

-- ================================================================
--   HTTP FETCH
-- ================================================================
local function httpGet(url)
    local ok1, r1 = pcall(function() return game:HttpGet(url, true) end)
    if ok1 and type(r1) == "string" and #r1 > 0 then return r1 end

    if typeof(HttpGet) == "function" then
        local ok2, r2 = pcall(HttpGet, url, true)
        if ok2 and type(r2) == "string" and #r2 > 0 then return r2 end
    end
    if typeof(syn) == "table" and typeof(syn.request) == "function" then
        local ok3, r3 = pcall(syn.request, { Url = url, Method = "GET" })
        if ok3 and r3 and type(r3.Body) == "string" and #r3.Body > 0 then return r3.Body end
    end
    if typeof(http) == "table" and typeof(http.request) == "function" then
        local ok4, r4 = pcall(http.request, { Url = url, Method = "GET" })
        if ok4 and r4 and type(r4.Body) == "string" and #r4.Body > 0 then return r4.Body end
    end
    if typeof(request) == "function" then
        local ok5, r5 = pcall(request, { Url = url, Method = "GET" })
        if ok5 and r5 and type(r5.Body) == "string" and #r5.Body > 0 then return r5.Body end
    end
    local ok6, r6 = pcall(function() return game:GetService("HttpService"):GetAsync(url, true) end)
    if ok6 and type(r6) == "string" and #r6 > 0 then return r6 end

    error("[Hub] No working HTTP method found in this executor.")
end

local function fetchLua(url)
    local raw = httpGet(url)
    local fn, err = loadstring(raw)
    if not fn then error("[Hub] Parse error (" .. url .. "): " .. tostring(err)) end
    local ok, result = pcall(fn)
    if not ok then error("[Hub] Runtime error (" .. url .. "): " .. tostring(result)) end
    return result
end

-- ================================================================
--   LOAD MAIN CONFIG
-- ================================================================
print("[Hub] Loading config...")
local cfg = fetchLua(CONFIG_URL)
if type(cfg) ~= "table" then error("[Hub] HubConfig.lua must return a table.") end

cfg.title     = cfg.title     or "Hub"
cfg.version   = cfg.version   or "1.0"
cfg.color     = cfg.color     or {88, 130, 255}
cfg.tabs      = cfg.tabs      or {}
cfg.gameFiles = cfg.gameFiles or {}

-- ================================================================
--   LOAD EACH GAME FILE
-- ================================================================
local games = {}
for i, url in ipairs(cfg.gameFiles) do
    local ok, result = pcall(fetchLua, url)
    if ok and type(result) == "table" then
        table.insert(games, result)
        print("[Hub] Loaded game: " .. tostring(result.name or url))
    else
        warn("[Hub] Failed to load game file (" .. url .. "): " .. tostring(result))
    end
end

print("[Hub] Ready — " .. #cfg.tabs .. " tabs, " .. #games .. " games")

-- ================================================================
--   SERVICES
-- ================================================================
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer
local guiParent        = (typeof(gethui) == "function" and gethui())
                      or LocalPlayer:WaitForChild("PlayerGui")

local prev = guiParent:FindFirstChild("GHubGui")
if prev then prev:Destroy() end

-- ================================================================
--   THEME
-- ================================================================
local ac       = cfg.color
local ACCENT   = Color3.fromRGB(ac[1], ac[2], ac[3])
local BG_DARK  = Color3.fromRGB(13,  13,  20)
local BG_MID   = Color3.fromRGB(22,  22,  34)
local BG_CARD  = Color3.fromRGB(30,  30,  46)
local BG_HOVER = Color3.fromRGB(40,  40,  60)
local ON_CLR   = Color3.fromRGB(60,  200, 110)
local OFF_CLR  = Color3.fromRGB(190, 55,  55)
local TEXT     = Color3.fromRGB(225, 225, 238)
local DIM      = Color3.fromRGB(120, 120, 148)
local W, H     = 390, 510

-- ================================================================
--   UI HELPERS
-- ================================================================
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
end
local function stroke(p, col, thick)
    local s = Instance.new("UIStroke")
    s.Color = col or Color3.fromRGB(40, 40, 65)
    s.Thickness = thick or 1
    s.Parent = p
end
local function pad(p, t, b, l, r)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, t or 0)
    u.PaddingBottom = UDim.new(0, b or 0)
    u.PaddingLeft   = UDim.new(0, l or 0)
    u.PaddingRight  = UDim.new(0, r or 0)
    u.Parent = p
end
local function lbl(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.TextColor3 = TEXT
    l.TextXAlignment = Enum.TextXAlignment.Left
    for k, v in pairs(props) do l[k] = v end
    l.Parent = parent
    return l
end
local function mkbtn(parent, props)
    local b = Instance.new("TextButton")
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.TextColor3 = TEXT
    for k, v in pairs(props) do b[k] = v end
    b.Parent = parent
    corner(b, 6)
    return b
end
local function makeScrollFrame(parent, name)
    local sf = Instance.new("ScrollingFrame")
    sf.Name = name or "Scroll"
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 4
    sf.ScrollBarImageColor3 = ACCENT
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.Visible = false
    sf.Parent = parent
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = sf
    pad(sf, 4, 8, 0, 0)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
    end)
    return sf
end

-- ================================================================
--   TOGGLE CARD
-- ================================================================
local function buildToggleCard(tcfg, order, parent)
    local name      = tostring(tcfg.name      or "Toggle")
    local desc      = tostring(tcfg.desc      or "")
    local onScript  = tostring(tcfg.onScript  or "")
    local offScript = tostring(tcfg.offScript or "")

    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 58)
    Card.BackgroundColor3 = BG_CARD
    Card.BorderSizePixel = 0
    Card.LayoutOrder = order
    Card.Parent = parent
    corner(Card, 8)
    stroke(Card, Color3.fromRGB(38, 38, 58))

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(0, 12, 0.5, -4)
    dot.BackgroundColor3 = DIM
    dot.BorderSizePixel = 0
    dot.Parent = Card
    corner(dot, 4)

    lbl(Card, { Text = name, Size = UDim2.new(1,-120,0,22), Position = UDim2.new(0,28,0,10), TextSize = 13 })
    lbl(Card, { Text = desc, Size = UDim2.new(1,-120,0,18), Position = UDim2.new(0,28,0,30), TextSize = 11, TextColor3 = DIM, Font = Enum.Font.Gotham })

    local togBtn = mkbtn(Card, {
        Text = "OFF",
        Size = UDim2.new(0, 64, 0, 30),
        Position = UDim2.new(1, -78, 0.5, -15),
        BackgroundColor3 = BG_HOVER,
        TextColor3 = DIM,
    })

    local enabled = false
    local function setState(on, errored)
        enabled = on
        if errored then
            togBtn.Text = "ERR"
            togBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
            togBtn.TextColor3 = TEXT
            dot.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        elseif on then
            togBtn.Text = "ON"
            togBtn.BackgroundColor3 = ON_CLR
            togBtn.TextColor3 = BG_DARK
            dot.BackgroundColor3 = ON_CLR
        else
            togBtn.Text = "OFF"
            togBtn.BackgroundColor3 = BG_HOVER
            togBtn.TextColor3 = DIM
            dot.BackgroundColor3 = DIM
        end
    end

    togBtn.MouseButton1Click:Connect(function()
        local turningOn = not enabled
        local code = turningOn and onScript or offScript
        if code ~= "" then
            local compiled, compErr = loadstring(code)
            if not compiled then warn("[Hub] Compile error '" .. name .. "': " .. tostring(compErr)) setState(false, true) return end
            local runOk, runErr = pcall(compiled)
            if not runOk then warn("[Hub] Runtime error '" .. name .. "': " .. tostring(runErr)) setState(false, true) return end
        end
        setState(turningOn, false)
    end)
end

-- ================================================================
--   GAME CARD
-- ================================================================
local function buildGameCard(gameCfg, order, parent, onOpen)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 64)
    Card.BackgroundColor3 = BG_CARD
    Card.BorderSizePixel = 0
    Card.LayoutOrder = order
    Card.Parent = parent
    corner(Card, 8)
    stroke(Card, Color3.fromRGB(38, 38, 58))

    local icon = Instance.new("Frame")
    icon.Size = UDim2.new(0, 44, 0, 44)
    icon.Position = UDim2.new(0, 10, 0.5, -22)
    icon.BackgroundColor3 = BG_MID
    icon.BorderSizePixel = 0
    icon.Parent = Card
    corner(icon, 8)
    stroke(icon, ACCENT, 1.5)

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(1, 0, 1, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = "🎮"
    iconLbl.TextSize = 20
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.TextColor3 = ACCENT
    iconLbl.Parent = icon

    lbl(Card, { Text = tostring(gameCfg.name or "Game"), Size = UDim2.new(1,-160,0,22), Position = UDim2.new(0,64,0,12), TextSize = 13 })
    lbl(Card, { Text = tostring(gameCfg.desc or ""),     Size = UDim2.new(1,-160,0,18), Position = UDim2.new(0,64,0,33), TextSize = 11, TextColor3 = DIM, Font = Enum.Font.Gotham })

    local openBtn = mkbtn(Card, {
        Text = "Open  ›",
        Size = UDim2.new(0, 72, 0, 30),
        Position = UDim2.new(1, -84, 0.5, -15),
        BackgroundColor3 = ACCENT,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
    })
    openBtn.MouseButton1Click:Connect(function() onOpen(gameCfg) end)
end

-- ================================================================
--   SCREEN GUI
-- ================================================================
local Gui = Instance.new("ScreenGui")
Gui.Name = "GHubGui"
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 999
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = guiParent

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, W, 0, H)
Main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
Main.BackgroundColor3 = BG_DARK
Main.BorderSizePixel = 0
Main.Parent = Gui
corner(Main, 10)
stroke(Main, Color3.fromRGB(38, 38, 62), 1.5)

local topStripe = Instance.new("Frame")
topStripe.Size = UDim2.new(1, 0, 0, 3)
topStripe.BackgroundColor3 = ACCENT
topStripe.BorderSizePixel = 0
topStripe.Parent = Main
corner(topStripe, 4)

-- ── Title bar ──
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.Position = UDim2.new(0, 0, 0, 3)
TitleBar.BackgroundColor3 = BG_MID
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
corner(TitleBar, 8)

local tbPatch = Instance.new("Frame")
tbPatch.Size = UDim2.new(1, 0, 0, 10)
tbPatch.Position = UDim2.new(0, 0, 1, -10)
tbPatch.BackgroundColor3 = BG_MID
tbPatch.BorderSizePixel = 0
tbPatch.Parent = TitleBar

lbl(TitleBar, { Text = cfg.title, Size = UDim2.new(1,-80,1,0), Position = UDim2.new(0,14,0,0), TextSize = 15 })
lbl(TitleBar, { Text = "v"..cfg.version, Size = UDim2.new(0,50,1,0), Position = UDim2.new(0,170,0,0), TextSize = 11, TextColor3 = DIM, Font = Enum.Font.Gotham })

local MinBtn   = mkbtn(TitleBar, { Text = "—", Size = UDim2.new(0,28,0,28), Position = UDim2.new(1,-62,0.5,-14), BackgroundColor3 = BG_CARD })
local CloseBtn = mkbtn(TitleBar, { Text = "✕", Size = UDim2.new(0,28,0,28), Position = UDim2.new(1,-30,0.5,-14), BackgroundColor3 = OFF_CLR })

local dragging, dStart, dOrigin
TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging, dStart, dOrigin = true, i.Position, Main.Position
    end
end)
TitleBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dStart
        Main.Position = UDim2.new(dOrigin.X.Scale, dOrigin.X.Offset + d.X, dOrigin.Y.Scale, dOrigin.Y.Offset + d.Y)
    end
end)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -47)
Content.Position = UDim2.new(0, 0, 0, 47)
Content.BackgroundTransparency = 1
Content.Parent = Main

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Content.Visible = not minimized
    Main.Size = minimized and UDim2.new(0, W, 0, 47) or UDim2.new(0, W, 0, H)
    MinBtn.Text = minimized and "▲" or "—"
end)
CloseBtn.MouseButton1Click:Connect(function() Gui:Destroy() end)

-- ── Tab bar ──
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -12, 0, 34)
TabBar.Position = UDim2.new(0, 6, 0, 6)
TabBar.BackgroundColor3 = BG_MID
TabBar.BorderSizePixel = 0
TabBar.Parent = Content
corner(TabBar, 7)
stroke(TabBar, Color3.fromRGB(38, 38, 60))

local tabRowLayout = Instance.new("UIListLayout")
tabRowLayout.FillDirection = Enum.FillDirection.Horizontal
tabRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabRowLayout.Padding = UDim.new(0, 3)
tabRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabRowLayout.Parent = TabBar
pad(TabBar, 3, 3, 4, 4)

local ListHost = Instance.new("Frame")
ListHost.Size = UDim2.new(1, -12, 1, -52)
ListHost.Position = UDim2.new(0, 6, 0, 46)
ListHost.BackgroundTransparency = 1
ListHost.Parent = Content

-- ================================================================
--   BUILD REGULAR TABS
-- ================================================================
local allTabBtns     = {}
local allTabContents = {}

local totalTabs = #cfg.tabs + 1
local tabW = math.floor((W - 12 - (totalTabs - 1) * 3 - 8) / totalTabs)

local function deactivateAll()
    for _, tb in ipairs(allTabBtns) do
        tb.BackgroundTransparency = 1
        tb.TextColor3 = DIM
    end
    for _, tc in ipairs(allTabContents) do tc.Visible = false end
end

for ti, tab in ipairs(cfg.tabs) do
    local tabBtn = mkbtn(TabBar, {
        Text = tostring(tab.name or ("Tab "..ti)),
        Size = UDim2.new(0, tabW, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = DIM,
        TextSize = 11,
        LayoutOrder = ti,
    })
    allTabBtns[ti] = tabBtn

    local tabScroll = makeScrollFrame(ListHost, "Tab_"..ti)
    allTabContents[ti] = tabScroll

    for oi, tcfg in ipairs(tab.toggles or {}) do
        buildToggleCard(tcfg, oi, tabScroll)
    end

    tabBtn.MouseButton1Click:Connect(function()
        deactivateAll()
        GamesPanel.Visible = false
        GameScriptsPanel.Visible = false
        tabBtn.BackgroundTransparency = 0
        tabBtn.BackgroundColor3 = ACCENT
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabScroll.Visible = true
        tabScroll.CanvasPosition = Vector2.zero
    end)
end

-- ================================================================
--   GAMES TAB
-- ================================================================
local gamesIdx = #cfg.tabs + 1

local GamesTabBtn = mkbtn(TabBar, {
    Text = "🎮 Games",
    Size = UDim2.new(0, tabW, 1, 0),
    BackgroundTransparency = 1,
    TextColor3 = DIM,
    TextSize = 11,
    LayoutOrder = gamesIdx,
})
allTabBtns[gamesIdx] = GamesTabBtn

-- Games list panel
local GamesPanel = makeScrollFrame(ListHost, "GamesPanel")

-- Game scripts sub-panel
local GameScriptsPanel = Instance.new("Frame")
GameScriptsPanel.Name = "GameScriptsPanel"
GameScriptsPanel.Size = UDim2.new(1, 0, 1, 0)
GameScriptsPanel.BackgroundTransparency = 1
GameScriptsPanel.Visible = false
GameScriptsPanel.Parent = ListHost

local BackBar = Instance.new("Frame")
BackBar.Size = UDim2.new(1, 0, 0, 32)
BackBar.BackgroundColor3 = BG_MID
BackBar.BorderSizePixel = 0
BackBar.Parent = GameScriptsPanel
corner(BackBar, 7)
stroke(BackBar, Color3.fromRGB(38, 38, 60))

local BackBtn = mkbtn(BackBar, {
    Text = "‹ Back",
    Size = UDim2.new(0, 60, 1, 0),
    BackgroundTransparency = 1,
    TextColor3 = ACCENT,
    TextSize = 12,
})
local GameTitleLbl = lbl(BackBar, {
    Text = "",
    Size = UDim2.new(1, -70, 1, 0),
    Position = UDim2.new(0, 65, 0, 0),
    TextSize = 13,
})

local ScriptsScroll = Instance.new("ScrollingFrame")
ScriptsScroll.Size = UDim2.new(1, 0, 1, -38)
ScriptsScroll.Position = UDim2.new(0, 0, 0, 38)
ScriptsScroll.BackgroundTransparency = 1
ScriptsScroll.BorderSizePixel = 0
ScriptsScroll.ScrollBarThickness = 4
ScriptsScroll.ScrollBarImageColor3 = ACCENT
ScriptsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ScriptsScroll.Parent = GameScriptsPanel

local scriptsLayout = Instance.new("UIListLayout")
scriptsLayout.SortOrder = Enum.SortOrder.LayoutOrder
scriptsLayout.Padding = UDim.new(0, 6)
scriptsLayout.Parent = ScriptsScroll
pad(ScriptsScroll, 4, 8, 0, 0)
scriptsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScriptsScroll.CanvasSize = UDim2.new(0, 0, 0, scriptsLayout.AbsoluteContentSize.Y + 12)
end)

local function openGameScripts(gameCfg)
    GamesPanel.Visible = false
    GameScriptsPanel.Visible = true
    GameTitleLbl.Text = tostring(gameCfg.name or "Game")
    ScriptsScroll.CanvasPosition = Vector2.zero

    for _, child in ipairs(ScriptsScroll:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then child:Destroy() end
    end

    local scripts = gameCfg.scripts or {}
    if #scripts == 0 then
        lbl(ScriptsScroll, { Text = "No scripts yet.", Size = UDim2.new(1,0,0,30), TextColor3 = DIM, TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.Gotham, TextSize = 12, LayoutOrder = 1 })
    else
        for si, scfg in ipairs(scripts) do
            buildToggleCard(scfg, si, ScriptsScroll)
        end
    end
end

BackBtn.MouseButton1Click:Connect(function()
    GameScriptsPanel.Visible = false
    GamesPanel.Visible = true
end)

for gi, gameCfg in ipairs(games) do
    buildGameCard(gameCfg, gi, GamesPanel, openGameScripts)
end

if #games == 0 then
    lbl(GamesPanel, { Text = "No game files loaded.", Size = UDim2.new(1,0,0,30), TextColor3 = DIM, TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.Gotham, TextSize = 12, LayoutOrder = 1 })
end

GamesTabBtn.MouseButton1Click:Connect(function()
    deactivateAll()
    GamesTabBtn.BackgroundTransparency = 0
    GamesTabBtn.BackgroundColor3 = ACCENT
    GamesTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    if not GameScriptsPanel.Visible then
        GamesPanel.Visible = true
    end
end)

-- Activate first tab
do
    deactivateAll()
    GamesPanel.Visible = false
    GameScriptsPanel.Visible = false
    if allTabBtns[1] and allTabContents[1] then
        allTabBtns[1].BackgroundTransparency = 0
        allTabBtns[1].BackgroundColor3 = ACCENT
        allTabBtns[1].TextColor3 = Color3.fromRGB(255, 255, 255)
        allTabContents[1].Visible = true
    end
end

-- ================================================================
--   KEYBIND: RightShift = show / hide
-- ================================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

print("[Hub] Ready! RightShift to show/hide.")