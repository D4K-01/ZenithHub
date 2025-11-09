local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- +===================================================================================+

local Window = Fluent:CreateWindow({
    Title = "ZenithHub " .. Fluent.Version,
    SubTitle = "by aiko",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- +===================================================================================+

local Tabs = {
    Credits = Window:AddTab({ Title = "Credits", Icon = "activity" }),
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "locate" }),
    Visual = Window:AddTab({ Title = "Visual", Icon = "eye" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "box" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "navigation" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- +===================================================================================+
-- CREDITS TAB
-- +===================================================================================+

do
    Tabs.Credits:AddParagraph({
        Title = "Welcome to ZenithHub !",
        Content = "\nNeed help or have questions? Join our Discord server for support, updates, and community discussions."
    })

    Tabs.Credits:AddParagraph({
        Title = "Credits | ZenithHub v1.0",
        Content = [[

Developed & Designed by Aiko.off

Powered by Fluent UI Library
Last Update: November 2025
Discord: discord.gg/9QwdpDx7cU

Special thanks to our testers and community!
        ]]
    })

    Tabs.Credits:AddButton({
        Title = "Join our Discord Server",
        Description = "\nClick to open https://discord.gg/9QwdpDx7cU",
        Callback = function()
            setclipboard("https://discord.gg/9QwdpDx7cU")
            Fluent:Notify({
                Title = "Discord Link Copied",
                Content = "Link copied to your clipboard! Paste it in your browser to join.",
                Duration = 5
            })
        end
    })
end

-- +===================================================================================+
-- SERVICES & VARIABLES
-- +===================================================================================+

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- === AIMBOT ===
local AimbotEnabled = false
local FOVEnabled = false
local TriggerBotEnabled = false
local Aiming = false

local AimbotSettings = {
    FOVSize = 120,
    Prediction = 0.13,
    Smoothing = 0.15,
    WallCheck = true,
    TeamCheck = false,
    HitPart = "Head",
    RainbowFOV = false,
    FOVColor = Color3.fromRGB(255, 0, 0),
    TargetColor = Color3.fromRGB(0, 255, 0)
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.NumSides = 64
FOVCircle.Radius = AimbotSettings.FOVSize
FOVCircle.Color = AimbotSettings.FOVColor
FOVCircle.Transparency = 0.8
FOVCircle.Visible = false

local hue = 0

-- === ESP ===
local Drawings = { ESP = {} }
local Highlights = {}

local ESPSettings = {
    Enabled = false,
    TeamCheck = false,
    ShowTeam = false,
    BoxESP = false,
    BoxStyle = "Corner",
    BoxColor = Color3.fromRGB(255, 255, 255),
    TracerESP = false,
    TracerOrigin = "Bottom",
    TracerColor = Color3.fromRGB(255, 255, 255),
    HealthESP = false,
    HealthColor = Color3.fromRGB(0, 255, 0),
    NameESP = false,
    NameColor = Color3.fromRGB(255, 255, 255),
    RainbowEnabled = false,
    ChamsEnabled = false,
    ChamsColor = Color3.fromRGB(255, 0, 0),
    MaxDistance = 1000
}

local TeamColor = Color3.fromRGB(25, 255, 25)
local EnemyColor = Color3.fromRGB(255, 25, 25)

-- === MISC ===
local MiscSettings = {
    FlyEnabled = false,
    FlySpeed = 50,
    NoClipEnabled = false,
    InfiniteJumpEnabled = false,
    SpeedEnabled = false,
    SpeedPower = 50,
    JumpPower = 50
}

local FlyConnection
local NoClipConnection

-- === TELEPORT ===
local TeleportSettings = {
    CTTEnabled = false,
    OrbitEnabled = false,
    CTTKey = Enum.UserInputType.MouseButton1,
    OrbitDistance = 10,
    OrbitSpeed = 5,
    OrbitTarget = nil
}

local CTTConnection
local OrbitConnection
local orbitDropdown

-- +===================================================================================+
-- MISC FUNCTIONS
-- +===================================================================================+

local function StartFly()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0,0,0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp
    FlyConnection = RunService.Heartbeat:Connect(function()
        if not MiscSettings.FlyEnabled then 
            bv:Destroy()
            if FlyConnection then FlyConnection:Disconnect() end
            return 
        end
        local cam = Camera.CFrame
        local move = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end
        bv.Velocity = move.Magnitude > 0 and (move.Unit * MiscSettings.FlySpeed) or Vector3.new(0,0,0)
    end)
end

local function StartNoClip()
    NoClipConnection = RunService.Stepped:Connect(function()
        if not MiscSettings.NoClipEnabled or not LocalPlayer.Character then 
            if NoClipConnection then NoClipConnection:Disconnect() end
            return 
        end
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function UpdateSpeedAndJump()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    local hum = LocalPlayer.Character.Humanoid
    hum.WalkSpeed = MiscSettings.SpeedEnabled and MiscSettings.SpeedPower or 16
    hum.JumpPower = MiscSettings.JumpPower
end

local InfiniteJumpConnection
local function EnableInfiniteJump()
    if InfiniteJumpConnection then InfiniteJumpConnection:Disconnect() end
    InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
        if MiscSettings.InfiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

-- +===================================================================================+
-- TELEPORT FUNCTIONS
-- +===================================================================================+

local function StartCTT()
    if CTTConnection then CTTConnection:Disconnect() end
    CTTConnection = UserInputService.InputBegan:Connect(function(input, gp)
        if gp or not TeleportSettings.CTTEnabled then return end
        if input.UserInputType == TeleportSettings.CTTKey then
            local mouse = LocalPlayer:GetMouse()
            local targetPos = mouse.Hit.Position + Vector3.new(0, 5, 0)
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(targetPos)
                Fluent:Notify({Title="CTT", Content="Téléporté !", Duration=1.5})
            end
        end
    end)
end

local function StartOrbit()
    if OrbitConnection then OrbitConnection:Disconnect() end
    local angle = 0
    OrbitConnection = RunService.Heartbeat:Connect(function(dt)
        if not TeleportSettings.OrbitEnabled or not TeleportSettings.OrbitTarget then
            if OrbitConnection then OrbitConnection:Disconnect() end
            return
        end

        local targetChar = TeleportSettings.OrbitTarget.Character
        if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
            TeleportSettings.OrbitTarget = nil
            Fluent:Notify({Title="Orbit", Content="Cible perdue.", Duration=2})
            return
        end

        local targetPos = targetChar.HumanoidRootPart.Position
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        angle = angle + dt * TeleportSettings.OrbitSpeed
        local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * TeleportSettings.OrbitDistance
        hrp.CFrame = CFrame.new(targetPos + offset + Vector3.new(0, 3, 0))
    end)
end

-- +===================================================================================+
-- AIMBOT FUNCTIONS
-- +===================================================================================+

local function getClosestTarget()
    local closestDistance = AimbotSettings.FOVSize
    local closestTarget = nil
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then continue end
        if AimbotSettings.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local targetPart = player.Character:FindFirstChild(AimbotSettings.HitPart) or player.Character:FindFirstChild("Head")
        if not targetPart then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if onScreen and screenPos.Z > 0 then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if distance < closestDistance then
                if AimbotSettings.WallCheck then
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
                    local raycastResult = Workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), raycastParams)
                    if raycastResult then continue end
                end
                closestDistance = distance
                closestTarget = targetPart
            end
        end
    end
    return closestTarget
end

local function getPredictedPosition(targetPart)
    local hrp = targetPart.Parent:FindFirstChild("HumanoidRootPart")
    if hrp then
        return targetPart.Position + (hrp.Velocity * AimbotSettings.Prediction)
    end
    return targetPart.Position
end

local function aimbotLoop()
    local targetPart = getClosestTarget()
    if targetPart and Aiming then
        local predictedPos = getPredictedPosition(targetPart)
        local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
        if onScreen and screenPos.Z > 0 then
            local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, predictedPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimbotSettings.Smoothing)
        end
    end
end

local function triggerBotLoop()
    if not TriggerBotEnabled then return end
    local target = Mouse.Target
    if target then
        local character = target:FindFirstAncestorOfClass("Model")
        local player = Players:GetPlayerFromCharacter(character)
        if player and player ~= LocalPlayer and (not AimbotSettings.TeamCheck or player.Team ~= LocalPlayer.Team) then
            mouse1press()
            task.wait(0.05)
            mouse1release()
        end
    end
end

-- +===================================================================================+
-- ESP FUNCTIONS
-- +===================================================================================+

local function CreateESP(player)
    if player == LocalPlayer then return end
    local box = {}
    for _, name in pairs({"TL","TR","BL","BR","L","R","T","B"}) do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = ESPSettings.BoxColor
        line.Thickness = 1.5
        box[name] = line
    end
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = ESPSettings.TracerColor
    tracer.Thickness = 1.5
    local healthBar = { Outline = Drawing.new("Square"), Fill = Drawing.new("Square") }
    healthBar.Outline.Visible = false
    healthBar.Outline.Color = Color3.new(0,0,0)
    healthBar.Outline.Thickness = 1
    healthBar.Fill.Visible = false
    healthBar.Fill.Filled = true
    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Center = true
    nameText.Size = 14
    nameText.Color = ESPSettings.NameColor
    nameText.Font = 2
    nameText.Outline = true
    local highlight = Instance.new("Highlight")
    highlight.FillColor = ESPSettings.ChamsColor
    highlight.OutlineColor = ESPSettings.ChamsColor
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Enabled = false
    Highlights[player] = highlight
    Drawings.ESP[player] = { Box = box, Tracer = tracer, HealthBar = healthBar, Name = nameText }
end

local function RemoveESP(player)
    local esp = Drawings.ESP[player]
    if esp then
        for _, obj in pairs(esp.Box) do obj:Remove() end
        esp.Tracer:Remove()
        for _, obj in pairs(esp.HealthBar) do obj:Remove() end
        esp.Name:Remove()
        Drawings.ESP[player] = nil
    end
    local h = Highlights[player]
    if h then h:Destroy(); Highlights[player] = nil end
end

local function GetPlayerColor(player)
    if ESPSettings.RainbowEnabled then
        return Color3.fromHSV(tick() % 5 / 5, 1, 1)
    end
    return player.Team == LocalPlayer.Team and TeamColor or EnemyColor
end

local function GetTracerOrigin()
    local o = ESPSettings.TracerOrigin
    if o == "Bottom" then return Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
    elseif o == "Top" then return Vector2.new(Camera.ViewportSize.X/2, 0)
    elseif o == "Center" then return Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    else return UserInputService:GetMouseLocation() end
end

-- +===================================================================================+
-- UPDATE ESP
-- +===================================================================================+

local function UpdateESP(player)
    if not ESPSettings.Enabled then return end
    local esp = Drawings.ESP[player]
    if not esp then return end

    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        for _, l in pairs(esp.Box) do l.Visible = false end
        esp.Tracer.Visible = false
        for _, o in pairs(esp.HealthBar) do o.Visible = false end
        esp.Name.Visible = false
        return
    end

    local root = char.HumanoidRootPart
    local hum = char:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local rootPos, rootOnScreen = Camera:WorldToViewportPoint(root.Position)
    local dist = (root.Position - Camera.CFrame.Position).Magnitude
    if dist > ESPSettings.MaxDistance then return end
    if ESPSettings.TeamCheck and player.Team == LocalPlayer.Team and not ESPSettings.ShowTeam then return end

    if not rootOnScreen then
        for _, l in pairs(esp.Box) do l.Visible = false end
        esp.Tracer.Visible = false
        for _, o in pairs(esp.HealthBar) do o.Visible = false end
        esp.Name.Visible = false
        return
    end

    local color = GetPlayerColor(player)
    local size = char:GetExtentsSize()
    local cf = root.CFrame
    local top = Camera:WorldToViewportPoint(cf * CFrame.new(0, size.Y/2, 0).Position)
    local bottom = Camera:WorldToViewportPoint(cf * CFrame.new(0, -size.Y/2, 0).Position)

    local screenH = bottom.Y - top.Y
    local boxW = screenH * 0.65
    local boxPos = Vector2.new(top.X - boxW/2, top.Y)
    local boxSize = Vector2.new(boxW, screenH)

    local onScreen = top.X > -boxW and top.X < Camera.ViewportSize.X + boxW and top.Y > -screenH and top.Y < Camera.ViewportSize.Y + screenH
    if not onScreen then
        for _, l in pairs(esp.Box) do l.Visible = false end
        esp.Tracer.Visible = false
        for _, o in pairs(esp.HealthBar) do o.Visible = false end
        esp.Name.Visible = false
        return
    end

    if ESPSettings.BoxESP then
        if ESPSettings.BoxStyle == "Corner" then
            local c = math.clamp(boxW * 0.2, 15, 40)
            esp.Box.TL.From = boxPos; esp.Box.TL.To = boxPos + Vector2.new(c, 0); esp.Box.TL.Color = color; esp.Box.TL.Visible = true
            esp.Box.TR.From = boxPos + Vector2.new(boxSize.X, 0); esp.Box.TR.To = boxPos + Vector2.new(boxSize.X - c, 0); esp.Box.TR.Color = color; esp.Box.TR.Visible = true
            esp.Box.BL.From = boxPos + Vector2.new(0, boxSize.Y); esp.Box.BL.To = boxPos + Vector2.new(c, boxSize.Y); esp.Box.BL.Color = color; esp.Box.BL.Visible = true
            esp.Box.BR.From = boxPos + Vector2.new(boxSize.X, boxSize.Y); esp.Box.BR.To = boxPos + Vector2.new(boxSize.X - c, boxSize.Y); esp.Box.BR.Color = color; esp.Box.BR.Visible = true
            esp.Box.L.From = boxPos; esp.Box.L.To = boxPos + Vector2.new(0, c); esp.Box.L.Color = color; esp.Box.L.Visible = true
            esp.Box.R.From = boxPos + Vector2.new(boxSize.X, 0); esp.Box.R.To = boxPos + Vector2.new(boxSize.X, c); esp.Box.R.Color = color; esp.Box.R.Visible = true
            esp.Box.T.From = boxPos + Vector2.new(0, boxSize.Y); esp.Box.T.To = boxPos + Vector2.new(0, boxSize.Y - c); esp.Box.T.Color = color; esp.Box.T.Visible = true
            esp.Box.B.From = boxPos + Vector2.new(boxSize.X, boxSize.Y); esp.Box.B.To = boxPos + Vector2.new(boxSize.X, boxSize.Y - c); esp.Box.B.Color = color; esp.Box.B.Visible = true
        else
            esp.Box.L.From = boxPos; esp.Box.L.To = boxPos + Vector2.new(0, boxSize.Y); esp.Box.L.Color = color; esp.Box.L.Visible = true
            esp.Box.R.From = boxPos + Vector2.new(boxSize.X, 0); esp.Box.R.To = boxPos + Vector2.new(boxSize.X, boxSize.Y); esp.Box.R.Color = color; esp.Box.R.Visible = true
            esp.Box.T.From = boxPos; esp.Box.T.To = boxPos + Vector2.new(boxSize.X, 0); esp.Box.T.Color = color; esp.Box.T.Visible = true
            esp.Box.B.From = boxPos + Vector2.new(0, boxSize.Y); esp.Box.B.To = boxPos + Vector2.new(boxSize.X, boxSize.Y); esp.Box.B.Color = color; esp.Box.B.Visible = true
            for _, name in pairs({"TL","TR","BL","BR"}) do esp.Box[name].Visible = false end
        end
    else
        for _, l in pairs(esp.Box) do l.Visible = false end
    end

    if ESPSettings.TracerESP then
        esp.Tracer.From = GetTracerOrigin()
        esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
        esp.Tracer.Color = color
        esp.Tracer.Visible = true
    else
        esp.Tracer.Visible = false
    end

    if ESPSettings.HealthESP then
        local hp = hum.Health / hum.MaxHealth
        local barH = screenH * 0.8
        local barPos = Vector2.new(boxPos.X - 6, boxPos.Y + (screenH - barH)/2)
        esp.HealthBar.Outline.Size = Vector2.new(4, barH)
        esp.HealthBar.Outline.Position = barPos
        esp.HealthBar.Outline.Visible = true
        esp.HealthBar.Fill.Size = Vector2.new(2, barH * hp)
        esp.HealthBar.Fill.Position = Vector2.new(barPos.X + 1, barPos.Y + barH * (1 - hp))
        esp.HealthBar.Fill.Color = ESPSettings.HealthColor
        esp.HealthBar.Fill.Visible = true
    else
        for _, o in pairs(esp.HealthBar) do o.Visible = false end
    end

    if ESPSettings.NameESP then
        esp.Name.Text = player.DisplayName
        esp.Name.Position = Vector2.new(boxPos.X + boxW/2, boxPos.Y - 20)
        esp.Name.Color = ESPSettings.NameColor
        esp.Name.Visible = true
    else
        esp.Name.Visible = false
    end

    local h = Highlights[player]
    if h and char then
        h.Parent = char
        h.Enabled = ESPSettings.ChamsEnabled
        h.FillColor = ESPSettings.ChamsColor
        h.OutlineColor = ESPSettings.ChamsColor
    end
end

-- +===================================================================================+
-- MAIN LOOP
-- +===================================================================================+

RunService.Heartbeat:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = AimbotSettings.FOVSize
    FOVCircle.Visible = FOVEnabled
    if AimbotSettings.RainbowFOV then
        hue = (hue + 0.008) % 1
        FOVCircle.Color = Color3.fromHSV(hue, 1, 1)
    else
        FOVCircle.Color = getClosestTarget() and AimbotSettings.TargetColor or AimbotSettings.FOVColor
    end

    if AimbotEnabled then aimbotLoop() end
    triggerBotLoop()

    if ESPSettings.Enabled then
        for _, p in Players:GetPlayers() do
            if p ~= LocalPlayer then
                if not Drawings.ESP[p] then CreateESP(p) end
                UpdateESP(p)
            end
        end
    end

    UpdateSpeedAndJump()
end)

-- +===================================================================================+
-- INPUTS
-- +===================================================================================+

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.CapsLock then
        AimbotEnabled = not AimbotEnabled
        Fluent:Notify({Title="Aimbot", Content=AimbotEnabled and "Activé (RMB)" or "Désactivé", Duration=3})
    end
end)

Mouse.Button2Down:Connect(function() Aiming = AimbotEnabled end)
Mouse.Button2Up:Connect(function() Aiming = false end)

Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
    -- Auto-refresh dropdown
    if orbitDropdown then
        task.delay(1, function()
            local names = {"-- Refresh List --"}
            for _, p in Players:GetPlayers() do
                if p ~= LocalPlayer then table.insert(names, p.Name) end
            end
            table.sort(names)
            orbitDropdown:Refresh(names)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
    if TeleportSettings.OrbitTarget == player then
        TeleportSettings.OrbitTarget = nil
    end
end)

-- +===================================================================================+
-- UI
-- +===================================================================================+

do
    local AimbotTab = Tabs.Aimbot
    AimbotTab:AddSection("Enable")
    AimbotTab:AddToggle("AimbotEnable", {Title="Enable Aimbot", Default=false, Callback=function(v) AimbotEnabled=v end})
    AimbotTab:AddToggle("FOVEnable", {Title="Enable FOV", Default=false, Callback=function(v) FOVEnabled=v end})
    AimbotTab:AddToggle("TriggerEnable", {Title="Enable TriggerBot", Default=false, Callback=function(v) TriggerBotEnabled=v end})

    AimbotTab:AddSection("Aimbot Settings")
    AimbotTab:AddSlider("PredictionSlider", {Title="Prediction", Min=0, Max=0.5, Default=0.13, Rounding=3, Callback=function(v) AimbotSettings.Prediction=v end})
    AimbotTab:AddDropdown("HitPartDropdown", {Title="Hit Part", Values={"Head","HumanoidRootPart","UpperTorso","LowerTorso"}, Default="Head", Callback=function(v) AimbotSettings.HitPart=v end})
    AimbotTab:AddToggle("WallCheckToggle", {Title="Wall Check", Default=true, Callback=function(v) AimbotSettings.WallCheck=v end})
    AimbotTab:AddToggle("TeamCheckToggle", {Title="Team Check", Default=false, Callback=function(v) AimbotSettings.TeamCheck=v end})

    AimbotTab:AddSection("FOV Settings")
    AimbotTab:AddSlider("FOVSizeSlider", {Title="FOV Size", Min=50, Max=500, Default=120, Rounding=0, Callback=function(v) AimbotSettings.FOVSize=v end})
    AimbotTab:AddSlider("SmoothingSlider", {Title="Smoothing", Min=0.05, Max=0.5, Default=0.15, Rounding=2, Callback=function(v) AimbotSettings.Smoothing=v end})
    AimbotTab:AddColorpicker("FOVColorPicker", {Title="FOV Color", Default=AimbotSettings.FOVColor, Callback=function(v) AimbotSettings.FOVColor=v end})
    AimbotTab:AddColorpicker("TargetColorPicker", {Title="Targeted Color", Default=AimbotSettings.TargetColor, Callback=function(v) AimbotSettings.TargetColor=v end})
    AimbotTab:AddToggle("RainbowFOVToggle", {Title="Rainbow FOV", Default=false, Callback=function(v) AimbotSettings.RainbowFOV=v end})
end

do
    local VisualTab = Tabs.Visual
    VisualTab:AddSection("Enable")
    VisualTab:AddToggle("ESPEnable", {Title="Enable ESP", Default=false, Callback=function(v) ESPSettings.Enabled=v end})
    VisualTab:AddToggle("BoxEnable", {Title="Enable Box", Default=false, Callback=function(v) ESPSettings.BoxESP=v end})
    VisualTab:AddToggle("TracerEnable", {Title="Enable Tracer", Default=false, Callback=function(v) ESPSettings.TracerESP=v end})
    VisualTab:AddToggle("HealthEnable", {Title="Enable Health Bar", Default=false, Callback=function(v) ESPSettings.HealthESP=v end})
    VisualTab:AddToggle("NameEnable", {Title="Enable Name", Default=false, Callback=function(v) ESPSettings.NameESP=v end})

    VisualTab:AddSection("ESP Settings")
    VisualTab:AddToggle("TeamCheckESP", {Title="Team Check", Default=false, Callback=function(v) ESPSettings.TeamCheck=v end})
    VisualTab:AddToggle("ShowTeamESP", {Title="Show Team", Default=false, Callback=function(v) ESPSettings.ShowTeam=v end})
    VisualTab:AddColorpicker("TeamColorPick", {Title="Team Color", Default=TeamColor, Callback=function(v) TeamColor=v end})
    VisualTab:AddColorpicker("EnemyColorPick", {Title="Ennemi Color", Default=EnemyColor, Callback=function(v) EnemyColor=v end})

    VisualTab:AddSection("Box Settings")
    VisualTab:AddDropdown("BoxStyleDrop", {Title="Box Style", Values={"Corner","Full"}, Default="Corner", Callback=function(v) ESPSettings.BoxStyle=v end})
    VisualTab:AddColorpicker("BoxColorPick", {Title="Box Color", Default=ESPSettings.BoxColor, Callback=function(v) ESPSettings.BoxColor=v end})

    VisualTab:AddSection("Tracer Settings")
    VisualTab:AddDropdown("TracerOriginDrop", {Title="Tracer Origin", Values={"Bottom","Top","Center","Mouse"}, Default="Bottom", Callback=function(v) ESPSettings.TracerOrigin=v end})
    VisualTab:AddColorpicker("TracerColorPick", {Title="Tracer Color", Default=ESPSettings.TracerColor, Callback=function(v) ESPSettings.TracerColor=v end})

    VisualTab:AddSection("Visual Settings")
    VisualTab:AddColorpicker("HealthColorPick", {Title="Health Bar Color", Default=ESPSettings.HealthColor, Callback=function(v) ESPSettings.HealthColor=v end})
    VisualTab:AddColorpicker("NameColorPick", {Title="Name Color", Default=ESPSettings.NameColor, Callback=function(v) ESPSettings.NameColor=v end})
    VisualTab:AddToggle("RainbowToggle", {Title="Rainbow Mode", Default=false, Callback=function(v) ESPSettings.RainbowEnabled=v end})

    VisualTab:AddSection("Visual Options")
    VisualTab:AddToggle("ChamsToggle", {Title="Enable Chams", Default=false, Callback=function(v) ESPSettings.ChamsEnabled=v end})
    VisualTab:AddColorpicker("ChamsColorPick", {Title="Chams Color", Default=ESPSettings.ChamsColor, Callback=function(v) ESPSettings.ChamsColor=v end})
end

do
    local MiscTab = Tabs.Misc
    MiscTab:AddSection("Enable")
    MiscTab:AddToggle("FlyToggle", {Title="Enable Fly", Default=false, Callback=function(v)
        MiscSettings.FlyEnabled = v
        if v then StartFly() end
    end})
    MiscTab:AddToggle("NoClipToggle", {Title="Enable NoClip", Default=false, Callback=function(v)
        MiscSettings.NoClipEnabled = v
        if v then StartNoClip() end
    end})
    MiscTab:AddToggle("InfJumpToggle", {Title="Enable Infinite Jump", Default=false, Callback=function(v)
        MiscSettings.InfiniteJumpEnabled = v
        EnableInfiniteJump()
    end})
    MiscTab:AddToggle("SpeedToggle", {Title="Enable Speed Hack", Default=false, Callback=function(v)
        MiscSettings.SpeedEnabled = v
    end})

    MiscTab:AddSection("Misc Settings")
    MiscTab:AddSlider("FlySpeedSlider", {Title="Fly Speed", Min=10, Max=200, Default=50, Rounding=0, Callback=function(v)
        MiscSettings.FlySpeed = v
    end})
    MiscTab:AddSlider("JumpPowerSlider", {Title="Jump Power", Min=50, Max=200, Default=50, Rounding=0, Callback=function(v)
        MiscSettings.JumpPower = v
    end})
    MiscTab:AddSlider("SpeedPowerSlider", {Title="Speed Power", Min=16, Max=300, Default=50, Rounding=0, Callback=function(v)
        MiscSettings.SpeedPower = v
    end})
end

-- +===================================================================================+
-- TELEPORT TAB UI (CORRIGÉ)
-- +===================================================================================+

do
    local TeleportTab = Tabs.Teleport

    -- === ENABLE ===
    TeleportTab:AddSection("Enable")
    TeleportTab:AddToggle("CTTEnable", {Title="Enable Click To Teleport (CTT)", Default=false, Callback=function(v)
        TeleportSettings.CTTEnabled = v
        if v then StartCTT() end
    end})
    TeleportTab:AddToggle("OrbitEnable", {Title="Enable Orbit Mode", Default=false, Callback=function(v)
        TeleportSettings.OrbitEnabled = v
        if v and TeleportSettings.OrbitTarget then
            StartOrbit()
        else
            if OrbitConnection then OrbitConnection:Disconnect() end
        end
    end})

    -- === CTT SETTINGS ===
    TeleportTab:AddSection("CTT Settings")
    TeleportTab:AddKeybind("CTTKeybind", {Title="Keybind", Default=Enum.UserInputType.MouseButton1, Callback=function(key)
        TeleportSettings.CTTKey = key
    end})

    -- === ORBIT MODE SETTINGS ===
    TeleportTab:AddSection("Orbit Mode Settings")
    TeleportTab:AddSlider("OrbitDistance", {Title="Distance to Player", Min=5, Max=50, Default=10, Rounding=1, Callback=function(v)
        TeleportSettings.OrbitDistance = v
    end})
    TeleportTab:AddSlider("OrbitSpeed", {Title="Speed", Min=1, Max=20, Default=5, Rounding=1, Callback=function(v)
        TeleportSettings.OrbitSpeed = v
    end})

    -- === PLAYER SELECTOR ===
    TeleportTab:AddSection("Orbit Target")
    
    orbitDropdown = TeleportTab:AddDropdown("OrbitPlayer", {
        Title = "Select Player",
        Values = {"-- Refresh List --"},
        Default = "-- Refresh List --",
        Callback = function(v)
            if v == "-- Refresh List --" then return end
            local player = Players:FindFirstChild(v)
            if player then
                TeleportSettings.OrbitTarget = player
                Fluent:Notify({Title="Orbit", Content="Cible: " .. player.DisplayName, Duration=2})
                if TeleportSettings.OrbitEnabled then
                    StartOrbit()
                end
            end
        end
    })

    TeleportTab:AddButton({
        Title = "Refresh Player List",
        Callback = function()
            local names = {"-- Refresh List --"}
            for _, p in Players:GetPlayers() do
                if p ~= LocalPlayer then table.insert(names, p.Name) end
            end
            table.sort(names)
            orbitDropdown:Refresh(names)
            Fluent:Notify({Title="Orbit", Content=#names-1 .. " joueurs trouvés", Duration=2})
        end
    })

    TeleportTab:AddParagraph({
        Title = "How to Use",
        Content = "1. Click 'Refresh Player List'\n2. Select a player\n3. Enable Orbit Mode\n\nCTT: Click anywhere with keybind"
    })
end

-- +===================================================================================+
-- SAVE MANAGER
-- +===================================================================================+

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "ZenithHub",
    Content = "TELEPORT TAB CORRIGÉ – Orbit Mode + CTT 100% FONCTIONNEL !",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
