-- ================================================================
--   HubLoader.lua  —  Host this on GitHub
--
--   One-liner for players to run in their executor:
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/YOURUSER/myhub/main/HubLoader.lua"))()
-- ================================================================

-- !! SET THIS to your GitHub Raw URL for HubConfig.lua !!
local CONFIG_URL = "https://raw.githubusercontent.com/JRodriguez07/RobloxThings/refs/heads/main/HubConfig.lua"

-- ================================================================
--   FETCH HELPER  (broad executor compatibility)
-- ================================================================
local function httpGet(url)

    -- Method 1: game:HttpGet  (Synapse X, Fluxus, most modern executors)
    local ok1, r1 = pcall(function() return game:HttpGet(url, true) end)
    if ok1 and type(r1) == "string" and #r1 > 0 then return r1 end

    -- Method 2: HttpGet global  (some older executors)
    if typeof(HttpGet) == "function" then
        local ok2, r2 = pcall(HttpGet, url, true)
        if ok2 and type(r2) == "string" and #r2 > 0 then return r2 end
    end

    -- Method 3: syn.request  (Synapse X)
    if typeof(syn) == "table" and typeof(syn.request) == "function" then
        local ok3, r3 = pcall(syn.request, { Url = url, Method = "GET" })
        if ok3 and r3 and type(r3.Body) == "string" and #r3.Body > 0 then return r3.Body end
    end

    -- Method 4: http.request  (Fluxus / Celery)
    if typeof(http) == "table" and typeof(http.request) == "function" then
        local ok4, r4 = pcall(http.request, { Url = url, Method = "GET" })
        if ok4 and r4 and type(r4.Body) == "string" and #r4.Body > 0 then return r4.Body end
    end

    -- Method 5: request global  (KRNL / Electron / others)
    if typeof(request) == "function" then
        local ok5, r5 = pcall(request, { Url = url, Method = "GET" })
        if ok5 and r5 and type(r5.Body) == "string" and #r5.Body > 0 then return r5.Body end
    end

    -- Method 6: HttpService:GetAsync  (last resort)
    local ok6, r6 = pcall(function()
        return game:GetService("HttpService"):GetAsync(url, true)
    end)
    if ok6 and type(r6) == "string" and #r6 > 0 then return r6 end

    error("[Hub] No working HTTP method found in this executor.")
end

-- ================================================================
--   LOAD + VALIDATE CONFIG FROM GITHUB
-- ================================================================
print("[Hub] Fetching config from GitHub...")

local rawConfig
local fetchOk, fetchErr = pcall(function() rawConfig = httpGet(CONFIG_URL) end)
if not fetchOk then
    error("[Hub] HTTP fetch failed: " .. tostring(fetchErr))
end

local configFn, parseErr = loadstring(rawConfig)
if not configFn then
    error("[Hub] Config syntax error: " .. tostring(parseErr))
end

local runOk, cfg = pcall(configFn)
if not runOk or type(cfg) ~= "table" then
    error("[Hub] Config did not return a table: " .. tostring(cfg))
end

-- Safe defaults so nothing below ever sees nil
cfg.title   = cfg.title   or "Hub"
cfg.version = cfg.version or "1.0"
cfg.color   = cfg.color   or {88, 130, 255}
cfg.tabs    = cfg.tabs    or {}

print("[Hub] Loaded: " .. cfg.title .. " v" .. cfg.version .. " | " .. #cfg.tabs .. " tab(s)")

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
local ac        = cfg.color
local ACCENT    = Color3.fromRGB(ac[1], ac[2], ac[3])
local BG_DARK   = Color3.fromRGB(13,  13,  20)
local BG_MID    = Color3.fromRGB(22,  22,  34)
local BG_CARD   = Color3.fromRGB(30,  30,  46)
local BG_HOVER  = Color3.fromRGB(40,  40,  60)
local ON_COLOR  = Color3.fromRGB(60,  200, 110)
local OFF_COLOR = Color3.fromRGB(190, 55,  55)
local TEXT      = Color3.fromRGB(225, 225, 238)
local DIM       = Color3.fromRGB(120, 120, 148)
local W, H      = 380, 500

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

-- ================================================================
--   SCREEN GUI + MAIN FRAME
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

local stripe = Instance.new("Frame")
stripe.Size = UDim2.new(1, 0, 0, 3)
stripe.BackgroundColor3 = ACCENT
stripe.BorderSizePixel = 0
stripe.Parent = Main
corner(stripe, 4)

-- ================================================================
--   TITLE BAR
-- ================================================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.Position = UDim2.new(0, 0, 0, 3)
TitleBar.BackgroundColor3 = BG_MID
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
corner(TitleBar, 8)

local tbBot = Instance.new("Frame")
tbBot.Size = UDim2.new(1, 0, 0, 10)
tbBot.Position = UDim2.new(0, 0, 1, -10)
tbBot.BackgroundColor3 = BG_MID
tbBot.BorderSizePixel = 0
tbBot.Parent = TitleBar

lbl(TitleBar, {
    Text = cfg.title,
    Size = UDim2.new(1, -80, 1, 0),
    Position = UDim2.new(0, 14, 0, 0),
    TextSize = 15,
})
lbl(TitleBar, {
    Text = "v" .. cfg.version,
    Size = UDim2.new(0, 50, 1, 0),
    Position = UDim2.new(0, 165, 0, 0),
    TextSize = 11,
    TextColor3 = DIM,
    Font = Enum.Font.Gotham,
})

local MinBtn   = mkbtn(TitleBar, { Text = "—", Size = UDim2.new(0,28,0,28), Position = UDim2.new(1,-62,0.5,-14), BackgroundColor3 = BG_CARD })
local CloseBtn = mkbtn(TitleBar, { Text = "X", Size = UDim2.new(0,28,0,28), Position = UDim2.new(1,-30,0.5,-14), BackgroundColor3 = OFF_COLOR })

-- Dragging
local dragging, dStart, dOrigin
TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging, dStart, dOrigin = true, i.Position, Main.Position
    end
end)
TitleBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dStart
        Main.Position = UDim2.new(dOrigin.X.Scale, dOrigin.X.Offset + d.X, dOrigin.Y.Scale, dOrigin.Y.Offset + d.Y)
    end
end)

-- Content area
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

-- ================================================================
--   TAB BAR
-- ================================================================
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -12, 0, 34)
TabBar.Position = UDim2.new(0, 6, 0, 6)
TabBar.BackgroundColor3 = BG_MID
TabBar.BorderSizePixel = 0
TabBar.Parent = Content
corner(TabBar, 7)
stroke(TabBar, Color3.fromRGB(38, 38, 60))

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 3)
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Parent = TabBar
pad(TabBar, 3, 3, 4, 4)

local ListHost = Instance.new("Frame")
ListHost.Size = UDim2.new(1, -12, 1, -52)
ListHost.Position = UDim2.new(0, 6, 0, 46)
ListHost.BackgroundTransparency = 1
ListHost.Parent = Content

-- ================================================================
--   TOGGLE CARD BUILDER
-- ================================================================
local function buildToggleCard(tcfg, order, parent)
    local name      = tostring(tcfg.name      or "Toggle")
    local desc      = tostring(tcfg.desc      or "")
    local onScript  = tostring(tcfg.onScript  or "")
    local offScript = tostring(tcfg.offScript or "")

    local Card = Instance.new("Frame")
    Card.Name = "Card_" .. name
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

    local function setState(on, err)
        enabled = on
        if err then
            togBtn.Text = "ERR"
            togBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
            togBtn.TextColor3 = TEXT
            dot.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        elseif on then
            togBtn.Text = "ON"
            togBtn.BackgroundColor3 = ON_COLOR
            togBtn.TextColor3 = BG_DARK
            dot.BackgroundColor3 = ON_COLOR
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
        if code and code ~= "" then
            local fn, compErr = loadstring(code)
            if not fn then
                warn("[Hub] Compile error '" .. name .. "': " .. tostring(compErr))
                setState(false, true)
                return
            end
            local runOk, runErr = pcall(fn)
            if not runOk then
                warn("[Hub] Runtime error '" .. name .. "': " .. tostring(runErr))
                setState(false, true)
                return
            end
        end
        setState(turningOn, false)
    end)
end

-- ================================================================
--   BUILD TABS
-- ================================================================
local tabBtns     = {}
local tabContents = {}

for ti, tab in ipairs(cfg.tabs) do
    local numTabs = #cfg.tabs
    local tabW = math.floor((W - 12 - (numTabs - 1) * 3 - 8) / numTabs)

    local tabBtn = mkbtn(TabBar, {
        Text = tostring(tab.name or ("Tab " .. ti)),
        Size = UDim2.new(0, tabW, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = DIM,
        TextSize = 12,
        LayoutOrder = ti,
    })
    tabBtns[ti] = tabBtn

    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Name = "Tab_" .. ti
    tabScroll.Size = UDim2.new(1, 0, 1, 0)
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0
    tabScroll.ScrollBarThickness = 4
    tabScroll.ScrollBarImageColor3 = ACCENT
    tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabScroll.Visible = false
    tabScroll.Parent = ListHost
    tabContents[ti] = tabScroll

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = tabScroll
    pad(tabScroll, 4, 4, 0, 0)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabScroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    local toggles = tab.toggles or {}
    for oi, toggleCfg in ipairs(toggles) do
        buildToggleCard(toggleCfg, oi, tabScroll)
    end

    tabBtn.MouseButton1Click:Connect(function()
        for i, tb in ipairs(tabBtns) do
            if i == ti then
                tb.BackgroundTransparency = 0
                tb.BackgroundColor3 = ACCENT
                tb.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                tb.BackgroundTransparency = 1
                tb.TextColor3 = DIM
            end
        end
        for i, tc in ipairs(tabContents) do
            tc.Visible = (i == ti)
            if i == ti then tc.CanvasPosition = Vector2.zero end
        end
    end)
end

-- Activate first tab
if tabBtns[1] then
    tabBtns[1].MouseButton1Click:Fire()
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

print("[Hub] Ready! Press RightShift to show/hide.")