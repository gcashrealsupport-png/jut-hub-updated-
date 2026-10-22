## ikaw na

Source: <https://chat.deepseek.com/share/cqg0x1drix2v7grsdn>

### Assistant · 22 Oct 2026, 22:47

```lua
--[[
  JUT HUB — FINAL MASTER BUILD
  - Welcome Splash
  - Main GUI
  - Medusza V2 Team Check
  - Floating TP CAM (Toggleable sa TP Tab, Fixed Joystick, 1st click Fly, 2nd click TP)
  - Player Teleport List (Fixed & Auto-refreshing)
  - ROF/DMG Panels
  - Rapid Fire, Silent Aim, ESP, etc.
  - CAM LOCK (Auto-disables Wall Check when ON)
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

--==================================================
-- 1. ANTI-KICK
--==================================================
task.spawn(function()
    pcall(function()
        local url = "https://raw.githubusercontent.com/SUUUUUS00000/MEGGD-Anti-kick/refs/heads/main/MEGGD%20Best%20Anti-kick.lua"
        local runner = loadstring(game:HttpGet(url))
        if type(runner) == "function" then runner(); print("[Anti-Kick] Loaded.") end
    end)
end)

if hookmetamethod then
    local oldKickHook
    oldKickHook = hookmetamethod(game, "__namecall", function(self, ...)
        if getnamecallmethod() == "Kick" and not checkcaller() then return end
        return oldKickHook(self, ...)
    end)
end

--==================================================
-- 2. WELCOME SPLASH
--==================================================
local Splash = Instance.new("ScreenGui", PG)
Splash.IgnoreGuiInset = true
Splash.DisplayOrder = 999
local SF = Instance.new("Frame", Splash)
SF.Size = UDim2.fromScale(1,1)
SF.BackgroundColor3 = Color3.fromRGB(10,10,15)
local Pumpkin = Instance.new("TextLabel", SF)
Pumpkin.Size = UDim2.fromOffset(100,100)
Pumpkin.Position = UDim2.new(0.5, -50, 0.5, -100)
Pumpkin.BackgroundTransparency = 1
Pumpkin.Text = "🎃"
Pumpkin.TextSize = 80
local WTxt = Instance.new("TextLabel", SF)
WTxt.Size = UDim2.new(1,0,0,50)
WTxt.Position = UDim2.new(0,0,0.5,10)
WTxt.BackgroundTransparency = 1
WTxt.Text = "Welcome to Jut Hub"
WTxt.TextColor3 = Color3.new(1,1,1)
WTxt.TextSize = 24
WTxt.Font = Enum.Font.GothamBold
local LoadBar = Instance.new("Frame", SF)
LoadBar.Size = UDim2.fromOffset(200,4)
LoadBar.Position = UDim2.new(0.5, -100, 0.5, 110)
LoadBar.BackgroundColor3 = Color3.fromRGB(40,40,50)
local LoadFill = Instance.new("Frame", LoadBar)
LoadFill.Size = UDim2.fromScale(0,1)
LoadFill.BackgroundColor3 = Color3.fromRGB(255,150,50)

TweenService:Create(LoadFill, TweenInfo.new(2.5), {Size = UDim2.fromScale(1,1)}):Play()
task.delay(3, function()
    TweenService:Create(SF, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Pumpkin, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(WTxt, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(LoadBar, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoadFill, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    task.wait(0.6)
    Splash:Destroy()
end)

--==================================================
-- 3. CONFIG
--==================================================
local Config = {
    SilentAim = false, Aimbot = false, AimAssist = false, ESP = false, Wall = false, TeamCheck = true,
    WalkSpeed = 16, Noclip = false, InfJump = false,
    AutoReload = false, NoRecoil = false, TargetPart = "Head",
    FovRadius = 120, SmoothAim = 25, SmoothAssist = 50,
    RapidFire = false, RapidDelay = 0,
    CamLock = false, CamLockSmooth = 0.2
}
local SA = { targetPart = nil, namecallOld = nil, hookActive = false }
local ESPData = {}

--==================================================
-- 4. TEAM CHECK
--==================================================
local TEAM_MARKERS = {"StageTeamSide", "Team", "TeamName", "TeamColor", "TeamId", "TeamID", "team"}
local function ReadTeamMarker(inst)
    if not inst then return nil end
    for _,name in ipairs(TEAM_MARKERS) do
        local attr = inst:GetAttribute(name)
        if attr ~= nil then return name.."="..tostring(attr) end
        local child = inst:FindFirstChild(name)
        if child and child:IsA("ValueBase") then return name.."="..tostring(child.Value) end
    end
    return nil
end
local function GetCustomTeamIdentity(player)
    if not player then return nil end
    local marker = ReadTeamMarker(player) or ReadTeamMarker(player.Character)
    if marker then return marker end
    local stats = player:FindFirstChild("leaderstats")
    marker = ReadTeamMarker(stats)
    if marker then return marker end
    if not player.Neutral then return "TeamColor="..tostring(player.TeamColor) end
    return nil
end
local customTeamCache = {count=0, at=0}
local function GetCustomTeamCount()
    local now = os.clock()
    if now - customTeamCache.at > 0.5 then
        local seen = {}
        local count = 0
        for _, player in ipairs(Players:GetPlayers()) do
            local identity = GetCustomTeamIdentity(player)
            if identity and not seen[identity] then seen[identity] = true; count = count + 1 end
        end
        customTeamCache.count = count
        customTeamCache.at = now
    end
    return customTeamCache.count
end
local function IsSameTeam(plr)
    if not Config.TeamCheck then return false end
    if not plr or plr == LP then return true end
    if LP.Team and plr.Team then return LP.Team == plr.Team end
    local localTeam = GetCustomTeamIdentity(LP)
    local targetTeam = GetCustomTeamIdentity(plr)
    if not localTeam or not targetTeam then return false end
    return GetCustomTeamCount() >= 2 and localTeam == targetTeam
end
local function HasLineOfSight(part, char)
    if not Config.Wall then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character, char }
    return Workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params) == nil
end
local function GetPart(char)
    if not char then return nil end
    if Config.TargetPart == "Head" then return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") end
    return char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
end
local function FindTarget()
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local bestPart, bestScore = nil, math.huge
    for _, t in ipairs(Players:GetPlayers()) do
        if t ~= LP and not IsSameTeam(t) and t.Character then
            local hum = t.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = GetPart(t.Character)
                if part then
                    local scr, on = cam:WorldToViewportPoint(part.Position)
                    if on and scr.Z > 0 then
                        local dSq = (scr.X-center.X)^2 + (scr.Y-center.Y)^2
                        if dSq <= Config.FovRadius^2 and dSq < bestScore and HasLineOfSight(part, t.Character) then
                            bestScore = dSq; bestPart = part
                        end
                    end
                end
            end
        end
    end
    return bestPart
end

--==================================================
-- 5. SILENT AIM HOOK
--==================================================
local function SA_Install()
    if SA.hookActive then return end
    SA.namecallOld = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if Config.SilentAim and not checkcaller() then
            if method == "FireServer" or method == "Raycast" or method == "InvokeServer" then
                local hp = SA.targetPart
                if hp and hp.Parent then
                    local args = {...}
                    if method == "Raycast" then
                        local o, d = args[1], args[2]
                        if typeof(o) == "Vector3" and typeof(d) == "Vector3" then
                            local delta = hp.Position - o
                            if delta.Magnitude > 0 then args[2] = delta.Unit * d.Magnitude end
                            return SA.namecallOld(self, unpack(args))
                        end
                    else
                        local lower = string.lower(self.Name)
                        local isHit = false
                        for _, w in ipairs({"hit", "bullet", "shoot", "fire", "attack"}) do if lower:find(w) then isHit = true break end end
                        if isHit then
                            local newArgs = table.clone(args)
                            for i, v in ipairs(newArgs) do
                                if typeof(v) == "Vector3" then
                                    local delta = hp.Position - v
                                    if delta.Magnitude > 0 then newArgs[i] = delta.Unit * math.max(delta.Magnitude, 1) end
                                elseif typeof(v) == "CFrame" then
                                    newArgs[i] = CFrame.lookAt(v.Position, hp.Position)
                                end
                            end
                            return SA.namecallOld(self, unpack(newArgs))
                        end
                    end
                end
            end
        end
        return SA.namecallOld(self, ...)
    end))
    SA.hookActive = true
end
local function SA_Restore()
    if SA.namecallOld then hookmetamethod(game, "__namecall", SA.namecallOld) end
    SA.hookActive = false
end

--==================================================
-- 6. MAIN GUI
--==================================================
local Gui = Instance.new("ScreenGui", PG)
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.fromOffset(260, 300)
Main.Position = UDim2.new(0, 12, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(15,15,20)
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local dragging, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local Circle = Instance.new("Frame", Gui)
Circle.AnchorPoint = Vector2.new(0.5, 0.5)
Circle.Position = UDim2.fromScale(0.5, 0.5)
Circle.Size = UDim2.fromOffset(Config.FovRadius * 2, Config.FovRadius * 2)
Circle.BackgroundTransparency = 1
Circle.Visible = false
Instance.new("UICorner", Circle).CornerRadius = UDim.new(1,0)
local CircleStroke = Instance.new("UIStroke", Circle)
CircleStroke.Color = Color3.fromRGB(200,200,255)
CircleStroke.Thickness = 1.5

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundColor3 = Color3.fromRGB(20,20,27)
Header.Active = true
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.fromOffset(10, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎃 Jut Hub"
Title.TextColor3 = Color3.fromRGB(200,200,255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local Min = Instance.new("TextButton", Header)
Min.Size = UDim2.fromOffset(22, 22)
Min.Position = UDim2.new(1, -28, 0, 6)
Min.BackgroundColor3 = Color3.fromRGB(35,35,45)
Min.Text = "—"
Min.TextColor3 = Color3.fromRGB(200,200,255)
Min.TextSize = 13
Min.Font = Enum.Font.GothamBold
Instance.new("UICorner", Min).CornerRadius = UDim.new(0, 5)

local Side = Instance.new("Frame", Main)
Side.Size = UDim2.fromOffset(60, 266)
Side.Position = UDim2.fromOffset(0, 34)
Side.BackgroundColor3 = Color3.fromRGB(18,18,24)

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -64, 1, -38)
Content.Position = UDim2.fromOffset(62, 36)
Content.BackgroundColor3 = Color3.fromRGB(20,20,27)
Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 8)

local minimized = false
Min.Activated:Connect(function()
    minimized = not minimized
    Content.Visible = not minimized
    Side.Visible = not minimized
    Main.Size = minimized and UDim2.fromOffset(260, 34) or UDim2.fromOffset(260, 300)
    Min.Text = minimized and "+" or "—"
end)

local tabNames = { "Aim", "Movement", "Combat", "TP" }
local pages, tabButtons = {}, {}
for i, name in ipairs(tabNames) do
    local sc = Instance.new("ScrollingFrame", Content)
    sc.Size = UDim2.new(1,-6,1,-6); sc.Position = UDim2.fromOffset(3,3)
    sc.BackgroundTransparency = 1; sc.CanvasSize = UDim2.new(); sc.Visible = false
    pages[name] = sc
    local list = Instance.new("UIListLayout", sc); list.Padding = UDim.new(0,3)
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() sc.CanvasSize = UDim2.fromOffset(0, list.AbsoluteContentSize.Y + 6) end)

    local b = Instance.new("TextButton", Side)
    b.Size = UDim2.new(1,-6,0,30); b.Position = UDim2.fromOffset(3, 3 + (i-1)*33)
    b.BackgroundColor3 = Color3.fromRGB(25,25,33); b.Text = name
    b.TextColor3 = Color3.fromRGB(150,150,160); b.TextSize = 10; b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    tabButtons[name] = b
    b.Activated:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        for _, btn in pairs(tabButtons) do btn.BackgroundColor3 = Color3.fromRGB(25,25,33) end
        pages[name].Visible = true; b.BackgroundColor3 = Color3.fromRGB(35,35,48)
    end)
end
pages["Aim"].Visible = true; tabButtons["Aim"].BackgroundColor3 = Color3.fromRGB(35,35,48)

local function Button(parent, text)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,-4,0,24); b.BackgroundColor3 = Color3.fromRGB(30,30,40)
    b.Text = text; b.TextColor3 = Color3.fromRGB(220,220,230); b.TextSize = 10
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)
    return b
end

local function SetButton(b, on, name)
    b.Text = name .. "  [" .. (on and "ON" or "OFF") .. "]"
    b.BackgroundColor3 = on and Color3.fromRGB(40,120,70) or Color3.fromRGB(30,30,40)
end

local function Slider(parent, name, minV, maxV, default, cb)
    local wrap = Instance.new("Frame", parent)
    wrap.Size = UDim2.new(1,-4,0,32); wrap.BackgroundColor3 = Color3.fromRGB(26,26,35)
    Instance.new("UICorner", wrap).CornerRadius = UDim.new(0,5)
    local lab = Instance.new("TextLabel", wrap)
    lab.Size = UDim2.new(1,-50,0,14); lab.Position = UDim2.fromOffset(6,0)
    lab.BackgroundTransparency = 1; lab.Text = name; lab.TextColor3 = Color3.fromRGB(180,180,190); lab.TextSize = 9
    local val = Instance.new("TextLabel", wrap)
    val.Size = UDim2.fromOffset(44,14); val.Position = UDim2.new(1,-50,0,0)
    val.BackgroundTransparency = 1; val.Text = tostring(default); val.TextColor3 = Color3.fromRGB(200,200,255); val.TextSize = 9
    val.TextXAlignment = Enum.TextXAlignment.Right
    local track = Instance.new("Frame", wrap)
    track.Size = UDim2.new(1,-12,0,6); track.Position = UDim2.fromOffset(6,18)
    track.BackgroundColor3 = Color3.fromRGB(45,45,55); Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((default-minV)/math.max(maxV-minV,1), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100,120,220); Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    local drag = false
    local function update(input)
        local size = track.AbsoluteSize.X
        local pos = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, size)
        local alpha = pos / size
        local value = math.floor((minV + (maxV - minV) * alpha) + 0.5)
        fill.Size = UDim2.new(alpha, 0, 1, 0); val.Text = tostring(value); cb(value)
    end
    track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then drag = true; update(input) end end)
    UIS.InputChanged:Connect(function(input) if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then drag = false end end)
end

--==================================================
-- 7. STAT PANELS
--==================================================
local MIN_VALUE = 1
local MAX_VALUE = 100000000000000

local function buildStatPanel(name, titleText, attrNames, pos, defaultVal)
    local state = { value = defaultVal, enabled = true, attrNames = attrNames }
    local gui = Instance.new("ScreenGui", PG)
    gui.ResetOnSpawn = false
    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 240, 0, 150)
    main.Position = pos
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    main.Active = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(38, 38, 42); stroke.Thickness = 1

    local dragStart, startPos
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position; startPos = main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragStart = nil end end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, -28, 0, 18)
    title.Position = UDim2.fromOffset(14, 8)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Color3.fromRGB(235, 235, 240)
    title.TextSize = 12
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left

    local dot = Instance.new("Frame", main)
    dot.Size = UDim2.fromOffset(8, 8); dot.Position = UDim2.new(1, -22, 0, 13)
    dot.BackgroundColor3 = Color3.fromRGB(120, 220, 140)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local valueBox = Instance.new("TextBox", main)
    valueBox.Size = UDim2.new(1, -28, 0, 28); valueBox.Position = UDim2.fromOffset(14, 32)
    valueBox.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    valueBox.Text = tostring(state.value)
    valueBox.TextColor3 = Color3.fromRGB(235, 235, 240)
    valueBox.Font = Enum.Font.Code; valueBox.TextSize = 13
    valueBox.ClearTextOnFocus = false
    Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 6)

    local track = Instance.new("TextButton", main)
    track.Size = UDim2.new(1, -28, 0, 8); track.Position = UDim2.fromOffset(14, 72)
    track.BackgroundColor3 = Color3.fromRGB(28, 28, 32); track.Text = ""
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.fromOffset(12, 12); knob.Position = UDim2.new(0, 0, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local toggleBtn = Instance.new("TextButton", main)
    toggleBtn.Size = UDim2.new(1, -28, 0, 26); toggleBtn.Position = UDim2.new(0, 14, 1, -34)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    toggleBtn.Text = "ENABLED"; toggleBtn.TextColor3 = Color3.fromRGB(160, 230, 180)
    toggleBtn.Font = Enum.Font.GothamBold; toggleBtn.TextSize = 11
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

    local function clampV(v) return math.clamp(math.floor(v), MIN_VALUE, MAX_VALUE) end
    local function toSlider(v) return math.clamp((math.log(v) / math.log(10)) / 14, 0, 1) end
    local function fromSlider(t) return math.floor(10 ^ (math.clamp(t, 0, 1) * 14)) end

    local function updateVisuals()
        local t = toSlider(state.value)
        fill.Size = UDim2.new(t, 0, 1, 0)
        knob.Position = UDim2.new(t, -6, 0.5, -6)
        if not valueBox:IsFocused() then valueBox.Text = tostring(state.value) end
    end

    local function applyToTool(tool)
        if not state.enabled then return end
        local changed = false
        for _, n in ipairs(state.attrNames) do
            if tool:GetAttribute(n) ~= nil then tool:SetAttribute(n, state.value); changed = true end
        end
        if not changed then tool:SetAttribute(state.attrNames[1], state.value) end
    end

    local function applyAll()
        if not state.enabled or not LP.Character then return end
        for _, c in ipairs(LP.Character:GetChildren()) do if c:IsA("Tool") then applyToTool(c) end end
        local bp = LP:FindFirstChildOfClass("Backpack")
        if bp then for _, c in ipairs(bp:GetChildren()) do if c:IsA("Tool") then applyToTool(c) end end end
    end

    local function setValue(v) state.value = clampV(v); updateVisuals(); applyAll() end

    local sliding = false
    local function sliderFromInput(input)
        local t = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        setValue(fromSlider(t))
    end
    track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true; sliderFromInput(input) end end)
    UIS.InputChanged:Connect(function(input) if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then sliderFromInput(input) end end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end end)

    valueBox.FocusLost:Connect(function()
        local n = tonumber(valueBox.Text)
        if n then setValue(n) else valueBox.Text = tostring(state.value) end
    end)

    local function setEnabled(s)
        state.enabled = s
        if s then
            toggleBtn.Text = "ENABLED"; toggleBtn.TextColor3 = Color3.fromRGB(160, 230, 180)
            dot.BackgroundColor3 = Color3.fromRGB(120, 220, 140); applyAll()
        else
            toggleBtn.Text = "DISABLED"; toggleBtn.TextColor3 = Color3.fromRGB(230, 160, 160)
            dot.BackgroundColor3 = Color3.fromRGB(200, 90, 90)
        end
    end
    toggleBtn.MouseButton1Click:Connect(function() setEnabled(not state.enabled) end)

    local function watch(container)
        if not container then return end
        for _, c in ipairs(container:GetChildren()) do if c:IsA("Tool") then applyToTool(c) end end
        container.ChildAdded:Connect(function(c) if c:IsA("Tool") then applyToTool(c) end end)
    end
    if LP.Character then watch(LP.Character) end
    if LP:FindFirstChildOfClass("Backpack") then watch(LP:FindFirstChildOfClass("Backpack")) end
    LP.CharacterAdded:Connect(watch)
    LP.ChildAdded:Connect(function(c) if c:IsA("Backpack") then watch(c) end end)

    updateVisuals(); setEnabled(true)
    return {
        frame = main,
        setEnabled = setEnabled,
        isEnabled = function() return state.enabled end,
        setVisible = function(v) main.Visible = v end,
        isVisible = function() return main.Visible end
    }
end

local rofPanel = buildStatPanel("ROF", "RateOfFire", {"RateOfFire", "rateOfFire"}, UDim2.new(0, 12, 1, -170), 10000)
local dmgPanel = buildStatPanel("DMG", "Damage", {"Damage", "damage"}, UDim2.new(0, 12, 1, -330), 100)
rofPanel.setVisible(false); dmgPanel.setVisible(false)

--==================================================
-- 8. UI LOGIC (Aim, Movement, Combat)
--==================================================
do
    local p = pages["Aim"]
    local TeamBtn = Button(p, "TEAM CHECK  [ON]")
    TeamBtn.BackgroundColor3 = Color3.fromRGB(40,120,70)
    TeamBtn.Activated:Connect(function() Config.TeamCheck = not Config.TeamCheck; SetButton(TeamBtn, Config.TeamCheck, "TEAM CHECK") end)

    local SilentBtn = Button(p, "SILENT AIM  [OFF]")
    SilentBtn.Activated:Connect(function()
        Config.SilentAim = not Config.SilentAim; SetButton(SilentBtn, Config.SilentAim, "SILENT AIM")
        if Config.SilentAim then SA_Install() else SA_Restore() end
    end)

    local AimBtn = Button(p, "AIMBOT  [OFF]")
    AimBtn.Activated:Connect(function() Config.Aimbot = not Config.Aimbot; SetButton(AimBtn, Config.Aimbot, "AIMBOT") end)

    local AssistBtn = Button(p, "AIM ASSIST  [OFF]")
    AssistBtn.Activated:Connect(function() Config.AimAssist = not Config.AimAssist; SetButton(AssistBtn, Config.AimAssist, "AIM ASSIST") end)

    Slider(p, "FOV", 1, 120, 120, function(v) Config.FovRadius = v; Circle.Size = UDim2.fromOffset(v*2, v*2) end)
    Slider(p, "AIM SMOOTH", 1, 100, 25, function(v) Config.SmoothAim = v end)
    Slider(p, "ASSIST SMOOTH", 1, 100, 50, function(v) Config.SmoothAssist = v end)
end

do
    local p = pages["Movement"]
    Slider(p, "WALKSPEED", 1, 300, 16, function(v) Config.WalkSpeed = v end)
    local NoclipBtn = Button(p, "NOCLIP  [OFF]")
    NoclipBtn.Activated:Connect(function() Config.Noclip = not Config.Noclip; SetButton(NoclipBtn, Config.Noclip, "NOCLIP") end)
    local InfJumpBtn = Button(p, "INF JUMP  [OFF]")
    InfJumpBtn.Activated:Connect(function() Config.InfJump = not Config.InfJump; SetButton(InfJumpBtn, Config.InfJump, "INF JUMP") end)
end

do
    local p = pages["Combat"]
    local ESPBtn = Button(p, "ESP  [OFF]")
    ESPBtn.Activated:Connect(function() Config.ESP = not Config.ESP; SetButton(ESPBtn, Config.ESP, "ESP") end)
    
    local WallBtn = Button(p, "WALL CHECK  [OFF]")
    local CamLockBtn = Button(p, "CAM LOCK  [OFF]")

    WallBtn.Activated:Connect(function() 
        Config.Wall = not Config.Wall
        SetButton(WallBtn, Config.Wall, "WALL CHECK") 
    end)

    CamLockBtn.Activated:Connect(function()
        Config.CamLock = not Config.CamLock
        SetButton(CamLockBtn, Config.CamLock, "CAM LOCK")
        
        if Config.CamLock then
            if Config.Wall then
                Config.Wall = false
                SetButton(WallBtn, false, "WALL CHECK")
            end
        end
    end)

    local AutoReloadBtn = Button(p, "AUTO RELOAD  [OFF]")
    AutoReloadBtn.Activated:Connect(function() Config.AutoReload = not Config.AutoReload; SetButton(AutoReloadBtn, Config.AutoReload, "AUTO RELOAD") end)
    
    local NoRecoilBtn = Button(p, "NO RECOIL  [OFF]")
    NoRecoilBtn.Activated:Connect(function() Config.NoRecoil = not Config.NoRecoil; SetButton(NoRecoilBtn, Config.NoRecoil, "NO RECOIL") end)

    local RapidBtn = Button(p, "RAPID FIRE  [OFF]")
    RapidBtn.Activated:Connect(function() Config.RapidFire = not Config.RapidFire; SetButton(RapidBtn, Config.RapidFire, "RAPID FIRE") end)
    Slider(p, "RAPID DELAY (ms)", 0, 100, 0, function(v) Config.RapidDelay = v / 1000 end)

    local ROFBtn = Button(p, "ROF PANEL  [OFF]")
    ROFBtn.Activated:Connect(function()
        local vis = not rofPanel.isVisible(); rofPanel.setVisible(vis); SetButton(ROFBtn, vis, "ROF PANEL")
    end)
    local DMGBtn = Button(p, "DMG PANEL  [OFF]")
    DMGBtn.Activated:Connect(function()
        local vis = not dmgPanel.isVisible(); dmgPanel.setVisible(vis); SetButton(DMGBtn, vis, "DMG PANEL")
    end)
end

--==================================================
-- 9. FLOATING TP CAM
--==================================================
local ViewCamTP = false
local CamConn = nil
local CamRotation = CFrame.new()

local floatGui = Instance.new("ScreenGui", PG)
floatGui.Name = "JutFloatingCam"
floatGui.ResetOnSpawn = false
floatGui.Enabled = false

local tpCamBtn = Instance.new("TextButton", floatGui)
tpCamBtn.Size = UDim2.fromOffset(80, 40)
tpCamBtn.Position = UDim2.new(0, 20, 0.5, 50)
tpCamBtn.BackgroundColor3 = Color3.fromRGB(155, 90, 255)
tpCamBtn.Text = "TP CAM"
tpCamBtn.TextColor3 = Color3.new(1,1,1)
tpCamBtn.Font = Enum.Font.GothamBold
tpCamBtn.TextSize = 12
Instance.new("UICorner", tpCamBtn).CornerRadius = UDim.new(0, 8)

local mobileCtrl = Instance.new("Frame", floatGui)
mobileCtrl.Size = UDim2.fromScale(1,1)
mobileCtrl.BackgroundTransparency = 1
mobileCtrl.Visible = false

local stick = Instance.new("Frame", mobileCtrl)
stick.Size = UDim2.fromOffset(100, 100); stick.Position = UDim2.new(0, 30, 1, -130)
stick.BackgroundColor3 = Color3.fromRGB(20,20,30); stick.BackgroundTransparency = 0.5
Instance.new("UICorner", stick).CornerRadius = UDim.new(1,0)

local knob = Instance.new("Frame", stick)
knob.Size = UDim2.fromOffset(40, 40); knob.Position = UDim2.new(0.5,-20,0.5,-20)
knob.BackgroundColor3 = Color3.fromRGB(155, 90, 255); knob.BackgroundTransparency = 0.2
Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

local upBtn = Instance.new("TextButton", mobileCtrl)
upBtn.Size = UDim2.fromOffset(40, 40); upBtn.Position = UDim2.new(1, -60, 1, -180)
upBtn.BackgroundColor3 = Color3.fromRGB(40,40,60); upBtn.Text = "↑"; upBtn.TextColor3 = Color3.new(1,1,1); upBtn.TextSize = 20
Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0,8)

local downBtn = Instance.new("TextButton", mobileCtrl)
downBtn.Size = UDim2.fromOffset(40, 40); downBtn.Position = UDim2.new(1, -60, 1, -130)
downBtn.BackgroundColor3 = Color3.fromRGB(40,40,60); downBtn.Text = "↓"; downBtn.TextColor3 = Color3.new(1,1,1); downBtn.TextSize = 20
Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0,8)

local lookFrame = Instance.new("TextButton", mobileCtrl)
lookFrame.Size = UDim2.new(0.6, 0, 1, 0); lookFrame.Position = UDim2.new(0.4, 0, 0, 0)
lookFrame.BackgroundTransparency = 1; lookFrame.Text = ""

local moveVec = Vector3.new(0,0,0)
local _up, _down = false, false
local lookTouch = nil
local stickTouch = nil
local stickStart = nil

stick.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        stickTouch = input; stickStart = input.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                stickTouch = nil; knob.Position = UDim2.new(0.5,-20,0.5,-20); moveVec = Vector3.new(0,0,0)
            end
        end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if stickTouch and input == stickTouch then
        local d = input.Position - stickStart
        local m = math.min(d.Magnitude, 50)
        local dir = d.Magnitude > 0 and d.Unit or Vector2.new(0,0)
        knob.Position = UDim2.new(0.5,-20 + dir.X*m, 0.5,-20 + dir.Y*m)
        moveVec = Vector3.new(dir.X, -dir.Y, 0) * (m/50) 
    end
end)

lookFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        lookTouch = input
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then lookTouch = nil end end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if ViewCamTP and lookTouch and input == lookTouch and input.Delta then
        CamRotation = CamRotation * CFrame.Angles(0, math.rad(-input.Delta.X * 0.4), 0) * CFrame.Angles(math.rad(-input.Delta.Y * 0.4), 0, 0)
    end
end)

upBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then _up = true; i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then _up = false end end) end end)
downBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then _down = true; i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then _down = false end end) end end)

local function StartFly()
    local cam = Workspace.CurrentCamera
    CamRotation = cam.CFrame - cam.CFrame.Position
    cam.CameraType = Enum.CameraType.Scriptable
    ViewCamTP = true
    mobileCtrl.Visible = true
    tpCamBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 80) 
    tpCamBtn.Text = "TP HERE"

    if CamConn then CamConn:Disconnect() end
    CamConn = RunService.RenderStepped:Connect(function(dt)
        if not ViewCamTP then return end
        local c = Workspace.CurrentCamera
        if c.CameraType ~= Enum.CameraType.Scriptable then c.CameraType = Enum.CameraType.Scriptable end

        local move = Vector3.new(0,0,0)
        if moveVec.Magnitude > 0.1 then
            move += CamRotation.LookVector * moveVec.Y
            move += CamRotation.RightVector * moveVec.X
        end
        if _up then move += Vector3.new(0,1,0) end
        if _down then move -= Vector3.new(0,1,0) end

        if move.Magnitude > 0 then
            c.CFrame = CFrame.new(c.CFrame.Position + move.Unit * 140 * dt) * CamRotation
        else
            c.CFrame = CFrame.new(c.CFrame.Position) * CamRotation
        end
    end)
end

local function StopFly()
    ViewCamTP = false
    mobileCtrl.Visible = false
    tpCamBtn.BackgroundColor3 = Color3.fromRGB(155, 90, 255)
    tpCamBtn.Text = "TP CAM"
    if CamConn then CamConn:Disconnect(); CamConn = nil end
    local cam = Workspace.CurrentCamera
    if cam then
        cam.CameraType = Enum.CameraType.Custom
        if LP.Character then cam.CameraSubject = LP.Character:FindFirstChildOfClass("Humanoid") end
    end
end

tpCamBtn.Activated:Connect(function()
    if not ViewCamTP then
        StartFly()
    else
        local cam = Workspace.CurrentCamera
        if cam and LP.Character then
            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(cam.CFrame.Position + (cam.CFrame.LookVector * 3)) 
            end
        end
        StopFly()
    end
end)

--==================================================
-- 10. TP TAB
--==================================================
do
    local p = pages["TP"]

    local toggleFloatingBtn = Button(p, "Floating TP CAM  [OFF]")
    toggleFloatingBtn.Activated:Connect(function()
        local isEnabled = not floatGui.Enabled
        floatGui.Enabled = isEnabled
        SetButton(toggleFloatingBtn, isEnabled, "Floating TP CAM")
        if not isEnabled and ViewCamTP then
            StopFly()
        end
    end)

    local listContainer = Instance.new("ScrollingFrame", p)
    listContainer.Size = UDim2.new(1, -4, 0, 180)
    listContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    listContainer.Visible = false
    listContainer.CanvasSize = UDim2.new()
    listContainer.ScrollBarThickness = 3
    Instance.new("UICorner", listContainer).CornerRadius = UDim.new(0, 8)

    local l = Instance.new("UIListLayout", listContainer)
    l.Padding = UDim.new(0, 4)
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listContainer.CanvasSize = UDim2.fromOffset(0, l.AbsoluteContentSize.Y + 10)
    end)

    local function TeleportCharTo(plr)
        if not plr or not plr.Character then return end
        local myChar = LP.Character
        if not myChar then return end
        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        local tHrp = plr.Character:FindFirstChild("HumanoidRootPart")
        if myHrp and tHrp then
            myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 4)
        end
    end

    local function RefreshList()
        for _, c in ipairs(listContainer:GetChildren()) do
            if c:IsA("Frame") and c.Name == "PlayerRow" then c:Destroy() end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                local row = Instance.new("Frame", listContainer)
                row.Name = "PlayerRow"
                row.Size = UDim2.new(1, -8, 0, 32)
                row.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

                local nameLbl = Instance.new("TextLabel", row)
                nameLbl.Size = UDim2.new(1, -60, 1, 0); nameLbl.Position = UDim2.fromOffset(8, 0)
                nameLbl.BackgroundTransparency = 1; nameLbl.Text = plr.DisplayName
                nameLbl.TextColor3 = Color3.fromRGB(200, 200, 220); nameLbl.TextSize = 10
                nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextXAlignment = Enum.TextXAlignment.Left

                local tpBtn = Instance.new("TextButton", row)
                tpBtn.Size = UDim2.fromOffset(40, 22); tpBtn.Position = UDim2.new(1, -46, 0.5, -11)
                tpBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 200); tpBtn.Text = "TP"
                tpBtn.TextColor3 = Color3.new(1,1,1); tpBtn.TextSize = 10; tpBtn.Font = Enum.Font.GothamBold
                Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 4)

                tpBtn.Activated:Connect(function() TeleportCharTo(plr) end)
            end
        end
    end

    local TeleportToBtn = Button(p, "Teleport to player  [OFF]")
    TeleportToBtn.Activated:Connect(function()
        local isVis = not listContainer.Visible
        listContainer.Visible = isVis
        SetButton(TeleportToBtn, isVis, "Teleport to player")
        if isVis then RefreshList() end
    end)

    Players.PlayerAdded:Connect(function() if listContainer.Visible then task.wait(1); RefreshList() end end)
    Players.PlayerRemoving:Connect(function() if listContainer.Visible then task.wait(0.5); RefreshList() end end)
end

--==================================================
-- 11. RAPID FIRE LOOP
--==================================================
task.spawn(function()
    while true do
        if Config.RapidFire and LP.Character then
            local tool = LP.Character:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function() tool:Activate() end)
                pcall(function()
                    for _, r in ipairs(LP.Character:GetDescendants()) do
                        if r:IsA("RemoteEvent") then
                            local n = r.Name:lower()
                            if n:find("fire") or n:find("shoot") or n:find("attack") then r:FireServer() end
                        end
                    end
                end)
            end
        end
        task.wait(Config.RapidDelay)
    end
end)

--==================================================
-- 12. ESP & MAIN LOOP (With Cam Lock)
--==================================================
local ESPFolder = Instance.new("Folder", Workspace)
ESPFolder.Name = "JutHubESP"

local function ClearESPData()
    for p, d in pairs(ESPData) do
        if d.h then d.h:Destroy() end
        if d.n then d.n:Destroy() end
        ESPData[p] = nil
    end
end
LP.CharacterAdded:Connect(ClearESPData)

local function UpdateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local char = p.Character
            if Config.ESP and char and not IsSameTeam(p) then
                if not ESPData[p] or ESPData[p].h.Adornee ~= char then
                    if ESPData[p] then ESPData[p].h:Destroy(); ESPData[p].n:Destroy() end
                    local h = Instance.new("Highlight", ESPFolder); h.Adornee = char; h.FillTransparency = 0.5
                    local n = Instance.new("BillboardGui", ESPFolder); n.Adornee = char:FindFirstChild("Head"); n.Size = UDim2.fromOffset(80,15); n.AlwaysOnTop = true
                    local t = Instance.new("TextLabel", n); t.Size = UDim2.fromScale(1,1); t.BackgroundTransparency = 1; t.Text = p.DisplayName; t.TextSize = 9; t.TextColor3 = Color3.new(1,1,1)
                    ESPData[p] = { h = h, n = n }
                else
                    ESPData[p].h.Adornee = char; ESPData[p].n.Adornee = char:FindFirstChild("Head")
                end
            elseif ESPData[p] then
                ESPData[p].h:Destroy(); ESPData[p].n:Destroy(); ESPData[p] = nil
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    Camera = Workspace.CurrentCamera
    if not Camera then return end
    
    local targetPart = FindTarget()
    
    -- FOV Circle
    Circle.Visible = (Config.SilentAim or Config.Aimbot or Config.AimAssist)
    if Circle.Visible then Circle.Position = UDim2.fromOffset(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) end

    if Config.SilentAim then SA.targetPart = targetPart end
    
    -- Aim Assist / Aimbot
    if (Config.Aimbot or Config.AimAssist) and targetPart and not ViewCamTP and not Config.CamLock then
        local desired = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
        local alpha = Config.Aimbot and (Config.SmoothAim/100) or (Config.SmoothAssist/100)
        Camera.CFrame = Camera.CFrame:Lerp(desired, math.clamp(alpha, 0.01, 1))
    end

    -- Cam Lock (Locks camera to target)
    if Config.CamLock and targetPart and not ViewCamTP then
        local desired = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
        Camera.CFrame = Camera.CFrame:Lerp(desired, Config.CamLockSmooth)
    end

    -- Movement & Tool Logic
    if LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= Config.WalkSpeed then hum.WalkSpeed = Config.WalkSpeed end
        if Config.Noclip then for _, v in ipairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        local tool = LP.Character:FindFirstChildOfClass("Tool")
        if tool then
            if Config.AutoReload then for _, v in ipairs(tool:GetDescendants()) do if v:IsA("NumberValue") and v.Name:lower():find("ammo") then v.Value = 9999 end end end
            if Config.NoRecoil then for _, v in ipairs(tool:GetDescendants()) do if v:IsA("NumberValue") and (v.Name:lower():find("recoil") or v.Name:lower():find("spread")) then v.Value = 0 end end end
        end
    end
    UpdateESP()
end)

UIS.JumpRequest:Connect(function()
    if Config.InfJump and LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

print("[Jut Hub] Loaded — Cam Lock logic integrated.")
```
