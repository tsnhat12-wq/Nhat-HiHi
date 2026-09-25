-- ===================================================
-- 1. THÔNG BÁO ĐẾM NGƯỢC 1.0s -> 0.0s
-- ===================================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local LocalPlayer = Players.LocalPlayer

local NoticeGui = Instance.new("ScreenGui")
NoticeGui.Name = "WaitNotice_Gui"
NoticeGui.ResetOnSpawn = false
pcall(function() NoticeGui.Parent = CoreGui end)
if not NoticeGui.Parent then NoticeGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local NoticeFrame = Instance.new("Frame", NoticeGui)
NoticeFrame.Size = UDim2.new(0, 220, 0, 45)
NoticeFrame.Position = UDim2.new(0.5, -110, 0.85, 0)
NoticeFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 28)
NoticeFrame.BackgroundTransparency = 0.2
Instance.new("UICorner", NoticeFrame).CornerRadius = UDim.new(0, 8)
local noticeStroke = Instance.new("UIStroke", NoticeFrame)
noticeStroke.Thickness = 1.5
noticeStroke.Color = Color3.fromRGB(0, 170, 255)

local NoticeText = Instance.new("TextLabel", NoticeFrame)
NoticeText.Size = UDim2.new(1, 0, 1, 0)
NoticeText.Font = Enum.Font.Cartoon
NoticeText.TextSize = 14
NoticeText.TextColor3 = Color3.fromRGB(100, 200, 255)
NoticeText.BackgroundTransparency = 1

-- Đếm ngược từ 1.0s về 0.0s
for i = 10, 0, -1 do
    NoticeText.Text = string.format("Đang Load Menu... %.1fs", i / 10)
    task.wait(0.1)
end
NoticeGui:Destroy()

-- ===================================================
-- 2. CLEAR OLD GUI & LOGIC
-- ===================================================
local function ClearOldGUI()
    local oldNames = {"SeaMenu_Gui", "AxiomTeleportMobBF", "AxiomTeleportChestBF", "AxiomTeleportFruitBF"}
    for _, name in ipairs(oldNames) do
        local oldCore = CoreGui:FindFirstChild(name)
        if oldCore then oldCore:Destroy() end
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
            local oldPlayerGui = LocalPlayer.PlayerGui:FindFirstChild(name)
            if oldPlayerGui then oldPlayerGui:Destroy() end
        end
    end
end
ClearOldGUI()

-- ===================================================
-- 3. CẤU HÌNH & HÀM HỖ TRỢ CHUNG
-- ===================================================
_G.SPEED = 180
_G.BOOST_SPEED = 1000 -- Tốc độ bứt phá khi dưới 60 studs
_G.BOOST_DISTANCE = 90
_G.DOCAO_MOB = 45
_G.DOCAO_CHEST = 0
_G.DOCAO_FRUIT = 1
_G.DOXATP = 0

local MobEnabled = false
local ChestEnabled = false
local FruitEnabled = false

local TargetMob = nil
local TargetChest = nil
local TargetFruit = nil
local TempleFlyConnection = nil -- <-- THÊM DÒNG NÀY VÀO ĐÂY LÀ XONG!

local BodyVelocity = nil
local NoclipConnection = nil
local IgnoredChests = setmetatable({}, {__mode = "k"})
local TouchTimer = 0
local SEARCH_MOB_DISTANCE = 5000

local function GetRoot()
    local Character = LocalPlayer.Character
    return Character and Character:FindFirstChild("HumanoidRootPart")
end

local function EnableAntiGravity(root)
    if not BodyVelocity or BodyVelocity.Parent ~= root then
        if BodyVelocity then BodyVelocity:Destroy() end
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.Name = "AxiomHover"
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BodyVelocity.P = 12500
        BodyVelocity.Parent = root
    end
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Freefall) end
end

local function DisableAntiGravity()
    if BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end
end

local function EnableNoclip()
    if not NoclipConnection then
        NoclipConnection = RunService.Stepped:Connect(function()
            if (MobEnabled or ChestEnabled or FruitEnabled) and LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

local function DisableNoclip()
    if NoclipConnection and not MobEnabled and not ChestEnabled and not FruitEnabled then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
end

-- ===================================================
-- 4. LOGIC TÌM KIẾM MỤC TIÊU
-- ===================================================
local function IsBloxFruitsMob(Model)
    if not Model or not Model:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(Model) then return false end
    local Humanoid = Model:FindFirstChildOfClass("Humanoid")
    local Root = Model:FindFirstChild("HumanoidRootPart") or Model.PrimaryPart
    if not Humanoid or not Root or Humanoid.Health <= 0 then return false end
    if Model.Parent and Model.Parent.Name == "Enemies" then return true end
    local name = Model.Name:lower()
    if name:find("quest") or name:find("giver") or name:find("merchant") or name:find("dealer") or name:find("title") or name:find("blox fruit") then return false end
    if Model:FindFirstChild("Dialogue") or Model:FindFirstChild("Quest") or Model:FindFirstChildOfClass("Dialog") then return false end
    return true
end

-- THUẬT TOÁN TÌM QUÁI TỐI ƯU
local function FindNearestMob()
    local MyRoot = GetRoot()
    if not MyRoot then return nil end

    local Nearest = nil
    local NearestDistance = SEARCH_MOB_DISTANCE
    local EnemiesFolder = Workspace:FindFirstChild("Enemies")
    local MobList = EnemiesFolder and EnemiesFolder:GetChildren() or Workspace:GetChildren()

    for _, Object in ipairs(MobList) do
        if IsBloxFruitsMob(Object) then
            local Root = Object:FindFirstChild("HumanoidRootPart") or Object.PrimaryPart
            if Root then
                local Distance = (Root.Position - MyRoot.Position).Magnitude
                if Distance < NearestDistance then
                    Nearest = Object
                    NearestDistance = Distance
                end
            end
        end
    end

    if not Nearest and EnemiesFolder then
        for _, Object in ipairs(Workspace:GetChildren()) do
            if Object ~= EnemiesFolder and IsBloxFruitsMob(Object) then
                local Root = Object:FindFirstChild("HumanoidRootPart") or Object.PrimaryPart
                if Root then
                    local Distance = (Root.Position - MyRoot.Position).Magnitude
                    if Distance < NearestDistance then
                        Nearest = Object
                        NearestDistance = Distance
                    end
                end
            end
        end
    end

    return Nearest
end

-- THUẬT TOÁN TÌM RƯƠNG NÂNG CẤP (QUÉT TAG + DỰ PHÒNG WORKSPACE)
local function FindNearestTaggedChest()
    local MyRoot = GetRoot()
    if not MyRoot then return nil end

    local Position = MyRoot.Position
    local Distance, Nearest = math.huge, nil

    -- 1. Quét theo Tag CollectionService (Nhanh & Tối ưu)
    local Chests = CollectionService:GetTagged("_ChestTagged")
    for i = 1, #Chests do
        local Chest = Chests[i]
        if Chest and Chest.Parent and not IgnoredChests[Chest] then
            if not Chest:GetAttribute("IsDisabled") then
                local Magnitude = (Chest:GetPivot().Position - Position).Magnitude
                if Magnitude < Distance then
                    Distance = Magnitude
                    Nearest = Chest
                end
            end
        end
    end

    -- 2. Quét dự phòng trực tiếp trong Workspace (Nếu Tag bỏ sót rương)
    if not Nearest then
        for _, object in ipairs(Workspace:GetChildren()) do
            if object.Name:find("Chest") and not IgnoredChests[object] then
                local touchPart = object:IsA("BasePart") and object or object.PrimaryPart or object:FindFirstChildOfClass("BasePart")
                if touchPart then
                    local Magnitude = (touchPart.Position - Position).Magnitude
                    if Magnitude < Distance then
                        Distance = Magnitude
                        Nearest = object
                    end
                end
            end
        end
    end

    return Nearest
end

local function FindNearestFruit()
    local MyRoot = GetRoot()
    if not MyRoot then return nil end
    local Nearest, NearestDistance = nil, 150000
    for _, v in ipairs(Workspace:GetChildren()) do
        if v:IsA("Tool") or (v:IsA("Model") and v:FindFirstChild("Handle")) then
            local name = v.Name:lower()
            if name:find("fruit") or name:find("trái") or name:find("trai") then
                local handle = v:FindFirstChild("Handle") or v.PrimaryPart or v:FindFirstChildOfClass("BasePart")
                if handle then
                    local dist = (handle.Position - MyRoot.Position).Magnitude
                    if dist < NearestDistance then
                        NearestDistance = dist
                        Nearest = handle
                    end
                end
            end
        end
    end
    return Nearest
end

local function GetCurrentBeli()
    local data = LocalPlayer:FindFirstChild("Data")
    if data and data:FindFirstChild("Beli") then return data.Beli.Value end
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Beli") then return stats.Beli.Value end
    if stats and stats:FindFirstChild("Money") then return stats.Money.Value end
    return 0
end

local LastBeli = GetCurrentBeli()
task.spawn(function()
    while task.wait(0.1) do
        local currentMoney = GetCurrentBeli()
        if currentMoney > LastBeli then
            LastBeli = currentMoney
            if ChestEnabled and TargetChest then
                IgnoredChests[TargetChest] = true
                TargetChest = nil
            end
        else
            LastBeli = currentMoney
        end
    end
end)

-- LOOP ĐIỀU KHIỂN TP DÙNG CHO CẢ 3 TÍNH NĂNG
RunService.Heartbeat:Connect(function(DeltaTime)
    if not MobEnabled and not ChestEnabled and not FruitEnabled then
        DisableAntiGravity()
        DisableNoclip()
        return
    end

    local MyRoot = GetRoot()
    if not MyRoot then
        DisableAntiGravity()
        return
    end

    EnableAntiGravity(MyRoot)
    EnableNoclip()

    -- UUTIEN 1: FARM FRUIT
    if FruitEnabled then
        if not TargetFruit or not TargetFruit.Parent then
            TargetFruit = FindNearestFruit()
        end
        if TargetFruit then
            local TargetCFrame = TargetFruit.CFrame * CFrame.new(0, _G.DOCAO_FRUIT, 0)
            local Distance = (TargetCFrame.Position - MyRoot.Position).Magnitude
            if Distance <= 4 and firetouchinterest then
                firetouchinterest(MyRoot, TargetFruit, 0)
                firetouchinterest(MyRoot, TargetFruit, 1)
            end
            local Speed = math.max(0, tonumber(_G.SPEED) or 250)
            local Alpha = math.clamp((Speed * DeltaTime) / Distance, 0, 1)
            MyRoot.CFrame = MyRoot.CFrame:Lerp(TargetCFrame, Alpha)
        end

    -- UUTIEN 2: TP MOB (DYNAMIC BOOST SPEED)
    elseif MobEnabled then
        if not TargetMob or not TargetMob.Parent or not IsBloxFruitsMob(TargetMob) then
            TargetMob = FindNearestMob()
        end
        if TargetMob then
            local MobRoot = TargetMob:FindFirstChild("HumanoidRootPart") or TargetMob.PrimaryPart
            if MobRoot then
                local TargetCFrame = MobRoot.CFrame * CFrame.new(_G.DOXATP, _G.DOCAO_MOB, 0)
                local Distance = (TargetCFrame.Position - MyRoot.Position).Magnitude
                if Distance > 0.05 then
                    local ActiveSpeed = (Distance <= _G.BOOST_DISTANCE) and _G.BOOST_SPEED or _G.SPEED
                    local StepProgress = (ActiveSpeed * DeltaTime) / math.max(Distance, 0.001)
                    local Alpha = math.clamp(StepProgress, 0, 1)
                    MyRoot.CFrame = MyRoot.CFrame:Lerp(TargetCFrame, Alpha)
                end
            end
        end

    -- UUTIEN 3: FARM CHEST (TAG + WORKSPACE BACKUP)
    elseif ChestEnabled then
        if not TargetChest or not TargetChest.Parent or IgnoredChests[TargetChest] or TargetChest:GetAttribute("IsDisabled") then
            TargetChest = FindNearestTaggedChest()
            TouchTimer = 0
        end

        if TargetChest then
            local TargetCFrame = TargetChest:GetPivot() * CFrame.new(0, _G.DOCAO_CHEST, 0)
            local Distance = (TargetCFrame.Position - MyRoot.Position).Magnitude

            local ActiveSpeed = (Distance <= _G.BOOST_DISTANCE) and _G.BOOST_SPEED or _G.SPEED

            if Distance <= 4 then
                TouchTimer = TouchTimer + DeltaTime
                if firetouchinterest then
                    local touchPart = TargetChest:IsA("BasePart") and TargetChest or TargetChest.PrimaryPart or TargetChest:FindFirstChildOfClass("BasePart")
                    if touchPart then
                        firetouchinterest(MyRoot, touchPart, 0)
                        firetouchinterest(MyRoot, touchPart, 1)
                    end
                end
                if TouchTimer >= 0.4 then
                    IgnoredChests[TargetChest] = true
                    TargetChest = nil
                    TouchTimer = 0
                    return
                end
            else
                TouchTimer = 0
            end

            local Alpha = math.clamp((ActiveSpeed * DeltaTime) / math.max(Distance, 0.001), 0, 1)
            MyRoot.CFrame = MyRoot.CFrame:Lerp(TargetCFrame, Alpha)
        end
    end
end)

-- ===================================================
-- 5. DỮ LIỆU ĐẢO VÀ GIAO DIỆN
-- ===================================================
local function GetCurrentSea()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _,v in ipairs(playerGui:GetDescendants()) do
            if v:IsA("TextLabel") and v.Text:find("v3") and v.Text:find("Sea") then
                if v.Text:find("Sea1") then return 1 end
                if v.Text:find("Sea2") then return 2 end
                if v.Text:find("Sea3") then return 3 end
            end
        end
    end
    if game.PlaceId == 85211729168715 then return 1 end
    if game.PlaceId == 79091703265657 then return 2 end
    if game.PlaceId == 7449423635 then return 3 end
    return 3
end

local CurrentSeaNum = GetCurrentSea()

local SeaIslandsData = {
    [1] = {
        {"Đảo Khỉ","Jungle"},{"Làng Hải Tặc","Pirate"},{"Đảo Khởi Đầu","Default"},{"Sa Mạc","Desert"},{"Thị Trấn Trung Tâm","Town"},{"Đảo Tuyết","Ice"},{"Pháo Đài Hải Quân","MarineBase"},{"Đảo Trời 1","Sky"},{"Đảo Trời 2 (Cổng)","Sky2Entrance"},{"Nhà Tù","Prison"},{"Đấu Trường","Colosseum"},{"Đảo Magma","Magma"},{"Thành Phố Đài Phun Nước","Fountain"},{"Đảo Dưới Nước (Cổng)","UnderwaterEntrance"}
    },
    [2] = {
        {"Quán Cà Phê (Cafe)","Bar"},{"Vương Quốc Hoa Hồng","Default"},{"Dinh Thự Sea 2 (Cổng)","MansionSea2Entrance"},{"Phòng Swan (Cổng)","SwanRoomEntrance"},{"Đảo Nghĩa Địa","Graveyard"},{"Vườn Thực Vật","Greenb"},{"Núi Tuyết","Snowy"},{"Lâu Đài Băng","IceCastle"},{"Thuyền Ma (Cổng)","CursedShipEntrance"},{"Đảo Nóng Lạnh","CircleIslandIce"},{"Đảo Lãng Quên","ForgottenIsland"}
    },
    [3] = {
        {"Đền Thời Gian","TempleOfTime"},{"Pháo Đài Trên Biển","SeaCastle"},{"Pháo Đài Trên Biển (Cổng)","SeaCastleEntrance"},{"Lâu Đài Bóng Tối","HauntedCastle"},{"Đảo Tiki","Tiki"},{"Đảo Bánh Kem / Katakuri","Loaf"},{"Đảo Socola","Chocolate"},{"Đảo Big Mom","IceCream"},{"Cây Đại Thụ","GreatTree"},{"Đảo Hydra (Cổng)","HydraEntrance"},{"Đảo Phụ Nữ (Hydra 1)","Hydra1"},{"Đảo Phụ Nữ (Hydra 2)","Hydra2"},{"Đảo Phụ Nữ (Hydra 3)","Hydra3"},{"Dinh Thự","BigMansion"},{"Dinh Thự (Cổng)","MansionEntrance"},{"Đảo Rùa","PineappleTown"},{"Thị Trấn Cảng","Default"}
    }
}

local CurrentList = SeaIslandsData[CurrentSeaNum] or SeaIslandsData[3]

-- ===================================================
-- SCREEN GUI
-- ===================================================
local SeaGui = Instance.new("ScreenGui")
SeaGui.Name = "SeaMenu_Gui"
SeaGui.ResetOnSpawn = false
pcall(function() SeaGui.Parent = CoreGui end)
if not SeaGui.Parent then SeaGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ===================================================
-- RAINBOW
-- ===================================================
local RainbowColors = {
    Color3.fromRGB(255,0,0),Color3.fromRGB(255,120,0),Color3.fromRGB(255,255,0),Color3.fromRGB(0,255,100),
    Color3.fromRGB(0,200,255),Color3.fromRGB(80,100,255),Color3.fromRGB(180,0,255),Color3.fromRGB(255,0,180)
}

local function CreateRainbowBars(parent,size,barLength,barThickness)
    local holder = Instance.new("Frame",parent)
    holder.Size = size
    holder.AnchorPoint = Vector2.new(0.5,0.5)
    holder.Position = UDim2.new(0.5,0,0.5,0)
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.ZIndex = parent.ZIndex + 1

    local bars = {}

    for i=1,4 do
        local bar = Instance.new("Frame",holder)
        bar.Size = UDim2.new(0,barLength,0,barThickness)
        bar.AnchorPoint = Vector2.new(0.5,0.5)
        bar.BackgroundColor3 = RainbowColors[i]
        bar.BorderSizePixel = 0
        bar.ZIndex = parent.ZIndex + 2
        Instance.new("UICorner",bar).CornerRadius = UDim.new(1,0)
        bars[i] = bar
    end

    bars[1].Position = UDim2.new(0.5,0,0,0)
    bars[2].Position = UDim2.new(1,0,0.5,0)
    bars[2].Rotation = 90
    bars[3].Position = UDim2.new(0.5,0,1,0)
    bars[3].Rotation = 180
    bars[4].Position = UDim2.new(0,0,0.5,0)
    bars[4].Rotation = 270

    return holder,bars
end

-- ===================================================
-- NÚT MỞ MENU
-- ===================================================
local ToggleBtn = Instance.new("ImageButton",SeaGui)
ToggleBtn.Size = UDim2.new(0,42,0,42)
ToggleBtn.Position = UDim2.new(0.015,0,0.2,0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(10,15,25)
ToggleBtn.BackgroundTransparency = 0.05
ToggleBtn.Image = "rbxassetid://137085832615070"
ToggleBtn.ScaleType = Enum.ScaleType.Fit
ToggleBtn.Draggable = true
ToggleBtn.ZIndex = 20

Instance.new("UICorner",ToggleBtn).CornerRadius = UDim.new(1,0)

local toggleStroke = Instance.new("UIStroke",ToggleBtn)
toggleStroke.Thickness = 1.5
toggleStroke.Color = Color3.fromRGB(0,170,255)

local ToggleRainbow = CreateRainbowBars(ToggleBtn,UDim2.new(1,4,1,4),20,2)
ToggleRainbow.ZIndex = 21

-- ===================================================
-- MAIN MENU
-- ===================================================
local MainMenu = Instance.new("Frame",SeaGui)
MainMenu.Size = UDim2.new(0,230,0,290)
MainMenu.AnchorPoint = Vector2.new(0.5,0.5)
MainMenu.Position = UDim2.new(0.5,0,0.5,0)
MainMenu.BackgroundColor3 = Color3.fromRGB(10,15,25)
MainMenu.BackgroundTransparency = 0.08
MainMenu.Visible = false
MainMenu.Draggable = true
MainMenu.ZIndex = 5

Instance.new("UICorner",MainMenu).CornerRadius = UDim.new(0,10)

local menuStroke = Instance.new("UIStroke",MainMenu)
menuStroke.Thickness = 1.5
menuStroke.Color = Color3.fromRGB(0,170,255)

local MenuRainbow = CreateRainbowBars(MainMenu,UDim2.new(1,4,1,4),55,3)
MenuRainbow.ZIndex = 6

-- ===================================================
-- TIÊU ĐỀ
-- ===================================================
local Title = Instance.new("TextLabel",MainMenu)
Title.Size = UDim2.new(1,0,0,35)
Title.Text = "BYPASS TP SEA "..CurrentSeaNum
Title.Font = Enum.Font.Cartoon
Title.TextSize = 15
Title.TextStrokeTransparency = 0.75
Title.TextStrokeColor3 = Color3.fromRGB(0,0,0)
Title.BackgroundTransparency = 1
Title.ZIndex = 10

local TitleColorTime = 0
local TitleBlue = Color3.fromRGB(100,200,255)
local TitleWhite = Color3.fromRGB(255,255,255)

RunService.RenderStepped:Connect(function(dt)
    TitleColorTime += dt
    local t = (math.sin(TitleColorTime*3)+1)/2
    Title.TextColor3 = TitleBlue:Lerp(TitleWhite,t)
end)

-- ===================================================
-- SCROLL
-- ===================================================
local Scroll = Instance.new("ScrollingFrame",MainMenu)
Scroll.Size = UDim2.new(1,0,1,-40)
Scroll.Position = UDim2.new(0,0,0,38)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.CanvasSize = UDim2.new(0,0,0,(#CurrentList+3)*38)
Scroll.ZIndex = 10

local UIList = Instance.new("UIListLayout",Scroll)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0,6)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ===================================================
-- ANIMATION RAINBOW
-- ===================================================
local RainbowTime = 0
local MenuOpen = false

RunService.RenderStepped:Connect(function(dt)
    RainbowTime += dt
    local ToggleSpeed = MenuOpen and 260 or 80
    ToggleRainbow.Rotation = (RainbowTime*ToggleSpeed)%360

    if MainMenu.Visible then
        MenuRainbow.Rotation = (RainbowTime*100)%360
    else
        MenuRainbow.Rotation = 0
    end

    for i,bar in ipairs(ToggleRainbow:GetChildren()) do
        if bar:IsA("Frame") then
            local index = ((math.floor(RainbowTime*5)+i-1)%#RainbowColors)+1
            bar.BackgroundColor3 = RainbowColors[index]
        end
    end

    for i,bar in ipairs(MenuRainbow:GetChildren()) do
        if bar:IsA("Frame") then
            local index = ((math.floor(RainbowTime*5)+i-1)%#RainbowColors)+1
            bar.BackgroundColor3 = RainbowColors[index]
        end
    end

    local index = (math.floor(RainbowTime*6)%#RainbowColors)+1
    toggleStroke.Color = RainbowColors[index]
    menuStroke.Color = RainbowColors[index]
end)

-- ===================================================
-- BẬT / TẮT MENU
-- ===================================================
ToggleBtn.MouseButton1Click:Connect(function()
    MenuOpen = not MenuOpen
    MainMenu.Visible = MenuOpen

    if MenuOpen then
        ToggleBtn.BackgroundTransparency = 0
        ToggleBtn.Size = UDim2.new(0,46,0,46)
    else
        ToggleBtn.BackgroundTransparency = 0.05
        ToggleBtn.Size = UDim2.new(0,42,0,42)
    end
end)

-- ===================================================
-- HÀM THỰC THI TELEPORT CỔNG
-- ===================================================
local function SpawnToIsland(spawnArg)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local commF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

    if spawnArg == "TempleOfTime" then
        if TempleFlyConnection or BodyVelocity then
            if TempleFlyConnection then TempleFlyConnection:Disconnect() TempleFlyConnection = nil end
            DisableAntiGravity()
            DisableNoclip()
            return
        end

        task.spawn(function()
            local hrp = GetRoot()
            if not hrp then return end

            EnableAntiGravity(hrp)
            EnableNoclip()

            local entranceCFrame = CFrame.new(3035.22,2280.89,-7321.22)
            local phase = 1
            local raceCFrame = nil

            TempleFlyConnection = RunService.Heartbeat:Connect(function(deltaTime)
                local currentHrp = GetRoot()

                if not currentHrp then
                    if TempleFlyConnection then TempleFlyConnection:Disconnect() TempleFlyConnection = nil end
                    DisableAntiGravity()
                    DisableNoclip()
                    return
                end

                currentHrp.AssemblyLinearVelocity = Vector3.zero
                currentHrp.AssemblyAngularVelocity = Vector3.zero

                if phase == 2 then return end

                local targetCFrame
                if phase == 1 then targetCFrame = entranceCFrame elseif phase == 3 then targetCFrame = raceCFrame end
                if not targetCFrame then return end

                local distance = (currentHrp.Position-targetCFrame.Position).Magnitude
                local boostDistance = tonumber(_G.BOOST_DISTANCE) or 90
                local boostSpeed = tonumber(_G.BOOST_SPEED) or 1000
                local normalSpeed = tonumber(_G.SPEED) or 140
                local activeSpeed = distance <= boostDistance and boostSpeed or normalSpeed
                local stepProgress = (activeSpeed*deltaTime)/math.max(distance,0.001)
                local alpha = math.clamp(stepProgress,0,1)

                if phase == 1 then
                    if distance <= 0.5 then
                        phase = 2

                        task.spawn(function()
                            for i=1,10 do
                                local mapFolder = Workspace:FindFirstChild("Map") or Workspace

                                if not mapFolder:FindFirstChild("Temple of Time") then
                                    local stash = ReplicatedStorage:FindFirstChild("MapStash") or ReplicatedStorage
                                    local tot = stash:FindFirstChild("Temple of Time")
                                    if tot then tot.Parent = mapFolder break end
                                else
                                    break
                                end

                                task.wait(0.3)
                            end

                            task.wait(0.5)

                            pcall(function()
                                commF:InvokeServer("requestEntrance",Vector3.new(28310.0234,14895.1123,109.456741))
                            end)

                            task.wait(0.5)

                            local race = nil
                            pcall(function() race = LocalPlayer.Data.Race.Value end)

                            if race == "Fishman" then
                                raceCFrame = CFrame.new(28224.056640625,14889.4267578125,-210.5872039794922)
                            elseif race == "Cyborg" then
                                raceCFrame = CFrame.new(28492.4140625,14894.4267578125,-422.1100158691406)
                            elseif race == "Skypiea" then
                                raceCFrame = CFrame.new(28967.408203125,14918.0751953125,234.31198120117188)
                            elseif race == "Ghoul" then
                                raceCFrame = CFrame.new(28672.720703125,14889.1279296875,454.5961608886719)
                            elseif race == "Human" then
                                raceCFrame = CFrame.new(29237.294921875,14889.4267578125,-206.94955444335938)
                            else
                                raceCFrame = CFrame.new(29020.66015625,14889.4267578125,-379.2682800292969)
                            end

                            phase = 3
                        end)
                    else
                        currentHrp.CFrame = currentHrp.CFrame:Lerp(targetCFrame,alpha)
                    end
                elseif phase == 3 then
                    if distance <= 3 then
                        if TempleFlyConnection then TempleFlyConnection:Disconnect() TempleFlyConnection = nil end
                        DisableAntiGravity()
                        DisableNoclip()
                        return
                    else
                        currentHrp.CFrame = currentHrp.CFrame:Lerp(targetCFrame,alpha)
                    end
                end
            end)
        end)

        return
    elseif spawnArg == "CursedShipEntrance" then pcall(function() commF:InvokeServer("requestEntrance",Vector3.new(923.21,126.97,32852.83)) end) return
    elseif spawnArg == "MansionSea2Entrance" then pcall(function() commF:InvokeServer("requestEntrance",Vector3.new(-325.47,331.92,600.17)) end) return
    elseif spawnArg == "SwanRoomEntrance" then pcall(function() commF:InvokeServer("requestEntrance",Vector3.new(2284.90,15.53,905.46)) end) return
    elseif spawnArg == "Sky2Entrance" then pcall(function() commF:InvokeServer("requestEntrance",Vector3.new(-6023.57666015625,5469.7197265625,2203.308349609375)) end) return
    elseif spawnArg == "UnderwaterEntrance" then pcall(function() commF:InvokeServer("requestEntrance",Vector3.new(61163.85,11.68,1819.78)) end) return
    elseif spawnArg == "SeaCastleEntrance" then pcall(function() commF:InvokeServer("requestEntrance",Vector3.new(-5089.14,314.58,-3164.46)) end) return
    elseif spawnArg == "MansionEntrance" then pcall(function() commF:InvokeServer("requestEntrance",Vector3.new(-12549.40,336.98,-7576.59)) end) return
    elseif spawnArg == "HydraEntrance" then pcall(function() commF:InvokeServer("requestEntrance",Vector3.new(5681.00,1013.11,-307.12)) end) return
    end

    local char = LocalPlayer.Character

    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.Health = 0
        pcall(function() commF:InvokeServer("SetLastSpawnPoint",spawnArg) end)
    end
end

-- ===================================================
-- NÚT ĐẢO
-- ===================================================
for _,island in ipairs(CurrentList) do
    local btnName,spawnArg = island[1],island[2]

    local Btn = Instance.new("TextButton",Scroll)
    Btn.Size = UDim2.new(0.9,0,0,32)
    Btn.Text = btnName
    Btn.Font = Enum.Font.Cartoon
    Btn.TextSize = 13
    Btn.TextColor3 = Color3.fromRGB(100,200,255)
    Btn.BackgroundColor3 = Color3.fromRGB(25,35,50)
    Btn.BackgroundTransparency = 0.3
    Btn.ZIndex = 11

    Instance.new("UICorner",Btn).CornerRadius = UDim.new(0,6)

    local btnS = Instance.new("UIStroke",Btn)
    btnS.Thickness = 1
    btnS.Color = Color3.fromRGB(0,120,200)

    Btn.MouseButton1Click:Connect(function()
        SpawnToIsland(spawnArg)
    end)
end
-- ===================================================
-- 6. CÁC NÚT TÍNH NĂNG
-- ===================================================
local FeatureButtons = {}

local function AddRainbowButton(button,stroke)
    table.insert(FeatureButtons,{Button=button,Stroke=stroke})
end

-- ===================================================
-- 1. BAY TỚI TRÁI
-- ===================================================
local FruitBtn = Instance.new("TextButton",Scroll)
FruitBtn.Size = UDim2.new(0.9,0,0,32)
FruitBtn.Text = "BAY TỚI TRÁI: OFF"
FruitBtn.Font = Enum.Font.Cartoon
FruitBtn.TextSize = 13
FruitBtn.TextColor3 = Color3.fromRGB(255,255,255)
FruitBtn.BackgroundColor3 = Color3.fromRGB(20,50,35)
FruitBtn.BackgroundTransparency = 0.2
FruitBtn.ZIndex = 11

Instance.new("UICorner",FruitBtn).CornerRadius = UDim.new(0,6)

local fruitStroke = Instance.new("UIStroke",FruitBtn)
fruitStroke.Thickness = 1.5

AddRainbowButton(FruitBtn,fruitStroke)

FruitBtn.MouseButton1Click:Connect(function()
    FruitEnabled = not FruitEnabled

    if FruitEnabled then
        FruitBtn.Text = "BAY TỚI TRÁI: ON"
    else
        TargetFruit = nil
        FruitBtn.Text = "BAY TỚI TRÁI: OFF"
    end
end)

-- ===================================================
-- 2. BAY TỚI QUÁI
-- ===================================================
local MobBtn = Instance.new("TextButton",Scroll)
MobBtn.Size = UDim2.new(0.9,0,0,32)
MobBtn.Text = "BAY TỚI QUÁI: OFF"
MobBtn.Font = Enum.Font.Cartoon
MobBtn.TextSize = 13
MobBtn.TextColor3 = Color3.fromRGB(255,255,255)
MobBtn.BackgroundColor3 = Color3.fromRGB(35,25,50)
MobBtn.BackgroundTransparency = 0.2
MobBtn.ZIndex = 11

Instance.new("UICorner",MobBtn).CornerRadius = UDim.new(0,6)

local mobStroke = Instance.new("UIStroke",MobBtn)
mobStroke.Thickness = 1.5

AddRainbowButton(MobBtn,mobStroke)

MobBtn.MouseButton1Click:Connect(function()
    MobEnabled = not MobEnabled

    if MobEnabled then
        MobBtn.Text = "BAY TỚI QUÁI: ON"
    else
        TargetMob = nil
        MobBtn.Text = "BAY TỚI QUÁI: OFF"
    end
end)

-- ===================================================
-- 3. FARM RƯƠNG
-- ===================================================
local ChestBtn = Instance.new("TextButton",Scroll)
ChestBtn.Size = UDim2.new(0.9,0,0,32)
ChestBtn.Text = "FARM RƯƠNG: OFF"
ChestBtn.Font = Enum.Font.Cartoon
ChestBtn.TextSize = 13
ChestBtn.TextColor3 = Color3.fromRGB(255,255,255)
ChestBtn.BackgroundColor3 = Color3.fromRGB(50,40,20)
ChestBtn.BackgroundTransparency = 0.2
ChestBtn.ZIndex = 11

Instance.new("UICorner",ChestBtn).CornerRadius = UDim.new(0,6)

local chestStroke = Instance.new("UIStroke",ChestBtn)
chestStroke.Thickness = 1.5

AddRainbowButton(ChestBtn,chestStroke)

ChestBtn.MouseButton1Click:Connect(function()
    ChestEnabled = not ChestEnabled

    if ChestEnabled then
        LastBeli = GetCurrentBeli()
        ChestBtn.Text = "FARM RƯƠNG: ON"
    else
        TargetChest = nil
        TouchTimer = 0
        ChestBtn.Text = "FARM RƯƠNG: OFF"
    end
end)

-- ===================================================
-- ANIMATION ĐỔI MÀU
-- ===================================================
local FeatureRainbowTime = 0

RunService.RenderStepped:Connect(function(dt)
    FeatureRainbowTime += dt

    for i,data in ipairs(FeatureButtons) do
        local button = data.Button
        local stroke = data.Stroke
        local index = (math.floor(FeatureRainbowTime*1)+i*2)%#RainbowColors+1
        local color = RainbowColors[index]

        button.TextColor3 = color
        stroke.Color = color
        button.BackgroundColor3 = Color3.fromRGB(15,20,30)
    end
end)
