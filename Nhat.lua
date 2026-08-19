-- ===================================================
-- 1. THÔNG BÁO ĐẾM NGƯỢC 10 GIÂY
-- ===================================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
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

for i = 10, 1, -1 do
    NoticeText.Text = "Đang tải Game... " .. i .. "s"
    task.wait(1)
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
_G.SPEED = 250
_G.DOCAO_MOB = 45
_G.DOCAO_CHEST = 1
_G.DOCAO_FRUIT = 1
_G.DOXATP = 0

local MobEnabled = false
local ChestEnabled = false
local FruitEnabled = false

local TargetMob = nil
local TargetChest = nil
local TargetFruit = nil

local BodyVelocity = nil
local NoclipConnection = nil
local IgnoredChests = {}
local TouchTimer = 0

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
        BodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
        BodyVelocity.P = 9000
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
-- 4. LOGIC TÌM KIẾM MỤC TIÊU (QUÁI, RƯƠNG, TRÁI QUỶ)
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

local function FindNearestMob()
    local MyRoot = GetRoot()
    if not MyRoot then return nil end
    local Nearest, NearestDistance = nil, 5000
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
    return Nearest
end

local function GetChestPart(Object)
    if not Object or not Object.Parent then return nil end
    local name = Object.Name:lower()
    if name:find("chest") then
        if Object:IsA("BasePart") then return Object
        elseif Object:IsA("Model") then
            return Object.PrimaryPart or (Object:FindFirstChild("TouchInterest", true) and Object:FindFirstChild("TouchInterest", true).Parent) or Object:FindFirstChildOfClass("BasePart")
        end
    end
    return nil
end

local function FindNearestChest()
    local MyRoot = GetRoot()
    if not MyRoot then return nil end
    local Nearest, NearestDistance = nil, 10000
    for _, Object in ipairs(Workspace:GetDescendants()) do
        local ChestPart = GetChestPart(Object)
        if ChestPart and not IgnoredChests[ChestPart] then
            local Distance = (ChestPart.Position - MyRoot.Position).Magnitude
            if Distance < NearestDistance then
                Nearest = ChestPart
                NearestDistance = Distance
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

    -- UUTIEN 2: TP MOB
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
                    local Speed = math.max(0, tonumber(_G.SPEED) or 250)
                    local Alpha = math.clamp((Speed * DeltaTime) / Distance, 0, 1)
                    MyRoot.CFrame = MyRoot.CFrame:Lerp(TargetCFrame, Alpha)
                end
            end
        end

    -- UUTIEN 3: FARM CHEST
    elseif ChestEnabled then
        if not TargetChest or not TargetChest.Parent or IgnoredChests[TargetChest] then
            TargetChest = FindNearestChest()
            TouchTimer = 0
        end
        if TargetChest then
            local TargetCFrame = TargetChest.CFrame * CFrame.new(0, _G.DOCAO_CHEST, 0)
            local Distance = (TargetCFrame.Position - MyRoot.Position).Magnitude
            if Distance <= 4 then
                TouchTimer = TouchTimer + DeltaTime
                if firetouchinterest then
                    firetouchinterest(MyRoot, TargetChest, 0)
                    firetouchinterest(MyRoot, TargetChest, 1)
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
            local Speed = math.max(0, tonumber(_G.SPEED) or 250)
            local Alpha = math.clamp((Speed * DeltaTime) / Distance, 0, 1)
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
        for _, v in ipairs(playerGui:GetDescendants()) do
            if v:IsA("TextLabel") and v.Text:find("v3") and v.Text:find("Sea") then
                if v.Text:find("Sea1") then return 1 end
                if v.Text:find("Sea2") then return 2 end
                if v.Text:find("Sea3") then return 3 end
            end
        end
    end
    if game.PlaceId == 2753915549 then return 1 end
    if game.PlaceId == 4442272183 then return 2 end
    if game.PlaceId == 7449423635 then return 3 end
    return 3
end

local CurrentSeaNum = GetCurrentSea()

local SeaIslandsData = {
    [1] = {
        {"Đảo Khỉ", "Jungle"}, {"Làng Hải Tặc", "Pirate"}, {"Đảo Khởi Đầu", "Default"},
        {"Sa Mạc", "Desert"}, {"Thị Trấn Trung Tâm", "Town"}, {"Đảo Tuyết", "SnowIsland"},
        {"Pháo Đài Hải Quân", "MarineBase"}, {"Đảo Trời 1", "Sky"}, {"Đảo Trời 2 (Cổng)", "Sky2Entrance"},
        {"Nhà Tù", "Prison"}, {"Đấu Trường", "Colosseum"}, {"Đảo Magma", "Magma"},
        {"Thành Phố Đài Phun Nước", "Fountain"}, {"Đảo Dưới Nước (Cổng)", "UnderwaterEntrance"}
    },
    [2] = {
        {"Quán Cà Phê (Cafe)", "Bar"}, {"Vương Quốc Hoa Hồng", "Default"}, {"Dinh Thự Sea 2 (Cổng)", "MansionSea2Entrance"},
        {"Phòng Swan (Cổng)", "SwanRoomEntrance"}, {"Đảo Nghĩa Địa", "Graveyard"}, {"Vườn Thực Vật", "Greenb"},
        {"Núi Tuyết", "Snowy"}, {"Lâu Đài Băng", "IceCastle"}, {"Thuyền Ma (Cổng)", "CursedShipEntrance"},
        {"Đảo Nóng Lạnh", "CircleIslandIce"}, {"Đảo Lãng Quên", "ForgottenIsland"}
    },
    [3] = {
        {"Đền Thời Gian (Cổng)", "TempleOfTime"}, -- ĐÃ THÊM ĐỀN THỜI GIAN VÀO SEA 3
        {"Pháo Đài Trên Biển", "SeaCastle"}, {"Pháo Đài Trên Biển (Cổng)", "SeaCastleEntrance"}, {"Lâu Đài Bóng Tối", "HauntedCastle"},
        {"Đảo Tiki", "Tiki"}, {"Đảo Bánh Kem / Katakuri", "Loaf"}, {"Đảo Socola", "Chocolate"}, {"Đảo Big Mom", "IceCream"},
        {"Cây Đại Thụ", "GreatTree"}, {"Đảo Hydra (Cổng)", "HydraEntrance"}, {"Đảo Phụ Nữ (Hydra 1)", "Hydra1"},
        {"Đảo Phụ Nữ (Hydra 2)", "Hydra2"}, {"Đảo Phụ Nữ (Hydra 3)", "Hydra3"}, {"Dinh Thự", "BigMansion"},
        {"Dinh Thự (Cổng)", "MansionEntrance"}, {"Đảo Rùa", "PineappleTown"}, {"Thị Trấn Cảng", "Default"}
    }
}

local CurrentList = SeaIslandsData[CurrentSeaNum] or SeaIslandsData[3]

local SeaGui = Instance.new("ScreenGui")
SeaGui.Name = "SeaMenu_Gui"
SeaGui.ResetOnSpawn = false
pcall(function() SeaGui.Parent = CoreGui end)
if not SeaGui.Parent then SeaGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local ToggleBtn = Instance.new("ImageButton", SeaGui)
ToggleBtn.Size = UDim2.new(0, 35, 0, 35)
ToggleBtn.Position = UDim2.new(0.015, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 25, 35)
ToggleBtn.BackgroundTransparency = 0.2
ToggleBtn.Draggable = true
ToggleBtn.ClipsDescendants = true
ToggleBtn.Image = "rbxassetid://77399452392419"
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local toggleStroke = Instance.new("UIStroke", ToggleBtn)
toggleStroke.Thickness = 1.5
toggleStroke.Color = Color3.fromRGB(0, 170, 255)

local MainMenu = Instance.new("Frame", SeaGui)
MainMenu.Size = UDim2.new(0, 230, 0, 290) 
MainMenu.AnchorPoint = Vector2.new(0.5, 0.5)
MainMenu.Position = UDim2.new(0.5, 0, 0.5, 0)
MainMenu.BackgroundColor3 = Color3.fromRGB(15, 20, 28)
MainMenu.BackgroundTransparency = 0.15
MainMenu.Visible = false
MainMenu.Draggable = true
Instance.new("UICorner", MainMenu).CornerRadius = UDim.new(0, 10)
local menuStroke = Instance.new("UIStroke", MainMenu)
menuStroke.Thickness = 1.5
menuStroke.Color = Color3.fromRGB(0, 170, 255)

local Title = Instance.new("TextLabel", MainMenu)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "BYPASS TP SEA " .. CurrentSeaNum
Title.Font = Enum.Font.Cartoon
Title.TextSize = 15
Title.TextColor3 = Color3.fromRGB(100, 200, 255)
Title.BackgroundTransparency = 1

local Scroll = Instance.new("ScrollingFrame", MainMenu)
Scroll.Size = UDim2.new(1, 0, 1, -40)
Scroll.Position = UDim2.new(0, 0, 0, 38)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 3
Scroll.CanvasSize = UDim2.new(0, 0, 0, (#CurrentList + 3) * 38)
local UIList = Instance.new("UIListLayout", Scroll)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 6)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

ToggleBtn.MouseButton1Click:Connect(function() MainMenu.Visible = not MainMenu.Visible end)

-- HÀM THỰC THI TELEPORT CỔNG
local function SpawnToIsland(spawnArg)
    local commF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
    
    -- ĐÃ THÊM TEMPLE OF TIME VÀO ĐÂY:
    if spawnArg == "TempleOfTime" then 
        pcall(function() 
            commF:InvokeServer("requestEntrance", Vector3.new(28310.0234, 14895.1123, 109.456741)) 
        end) 
        return
    elseif spawnArg == "CursedShipEntrance" then pcall(function() commF:InvokeServer("requestEntrance", Vector3.new(923.21, 126.97, 32852.83)) end) return
    elseif spawnArg == "MansionSea2Entrance" then pcall(function() commF:InvokeServer("requestEntrance", Vector3.new(-325.47, 331.92, 600.17)) end) return
    elseif spawnArg == "SwanRoomEntrance" then pcall(function() commF:InvokeServer("requestEntrance", Vector3.new(2284.90, 15.53, 905.46)) end) return
    elseif spawnArg == "Sky2Entrance" then pcall(function() commF:InvokeServer("requestEntrance", Vector3.new(-7894.61, 5547.14, -380.29)) end) return
    elseif spawnArg == "UnderwaterEntrance" then pcall(function() commF:InvokeServer("requestEntrance", Vector3.new(61163.85, 11.68, 1819.78)) end) return
    elseif spawnArg == "SeaCastleEntrance" then pcall(function() commF:InvokeServer("requestEntrance", Vector3.new(-5089.14, 314.58, -3164.46)) end) return
    elseif spawnArg == "MansionEntrance" then pcall(function() commF:InvokeServer("requestEntrance", Vector3.new(-12549.40, 336.98, -7576.59)) end) return
    elseif spawnArg == "HydraEntrance" then pcall(function() commF:InvokeServer("requestEntrance", Vector3.new(5681.00, 1013.11, -307.12)) end) return
    end

    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.Health = 0
        pcall(function() commF:InvokeServer("SetLastSpawnPoint", spawnArg) end)
    end
end

for _, island in ipairs(CurrentList) do
    local btnName, spawnArg = island[1], island[2]
    local Btn = Instance.new("TextButton", Scroll)
    Btn.Size = UDim2.new(0.9, 0, 0, 32)
    Btn.Text = btnName
    Btn.Font = Enum.Font.Cartoon
    Btn.TextSize = 13
    Btn.TextColor3 = Color3.fromRGB(100, 200, 255)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
    Btn.BackgroundTransparency = 0.3
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    local btnS = Instance.new("UIStroke", Btn)
    btnS.Thickness = 1
    btnS.Color = Color3.fromRGB(0, 120, 200)
    Btn.MouseButton1Click:Connect(function() SpawnToIsland(spawnArg) end)
end

-- ===================================================
-- 6. CÁC NÚT TÍNH NĂNG Ở CUỐI MENU
-- ===================================================

-- 1. NÚT FRUIT
local FruitBtn = Instance.new("TextButton", Scroll)
FruitBtn.Size = UDim2.new(0.9, 0, 0, 32)
FruitBtn.Text = "FARM TRÁI QUỶ: OFF"
FruitBtn.Font = Enum.Font.Cartoon
FruitBtn.TextSize = 13
FruitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FruitBtn.BackgroundColor3 = Color3.fromRGB(20, 50, 35)
FruitBtn.BackgroundTransparency = 0.2
Instance.new("UICorner", FruitBtn).CornerRadius = UDim.new(0, 6)
local fruitStroke = Instance.new("UIStroke", FruitBtn)
fruitStroke.Thickness = 1.2
fruitStroke.Color = Color3.fromRGB(0, 255, 127)

FruitBtn.MouseButton1Click:Connect(function()
    FruitEnabled = not FruitEnabled
    if FruitEnabled then
        FruitBtn.Text = "FARM TRÁI QUỶ: ON"
        FruitBtn.TextColor3 = Color3.fromRGB(0, 255, 127)
    else
        TargetFruit = nil
        FruitBtn.Text = "FARM TRÁI QUỶ: OFF"
        FruitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- 2. NÚT MOB
local MobBtn = Instance.new("TextButton", Scroll)
MobBtn.Size = UDim2.new(0.9, 0, 0, 32)
MobBtn.Text = "TP TỚI QUÁI: OFF"
MobBtn.Font = Enum.Font.Cartoon
MobBtn.TextSize = 13
MobBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MobBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 50)
MobBtn.BackgroundTransparency = 0.2
Instance.new("UICorner", MobBtn).CornerRadius = UDim.new(0, 6)
local mobStroke = Instance.new("UIStroke", MobBtn)
mobStroke.Thickness = 1.2
mobStroke.Color = Color3.fromRGB(170, 0, 255)

MobBtn.MouseButton1Click:Connect(function()
    MobEnabled = not MobEnabled
    if MobEnabled then
        MobBtn.Text = "TP TỚI QUÁI: ON"
        MobBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        mobStroke.Color = Color3.fromRGB(0, 255, 150)
    else
        TargetMob = nil
        MobBtn.Text = "TP TỚI QUÁI: OFF"
        MobBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        mobStroke.Color = Color3.fromRGB(170, 0, 255)
    end
end)

-- 3. NÚT CHEST
local ChestBtn = Instance.new("TextButton", Scroll)
ChestBtn.Size = UDim2.new(0.9, 0, 0, 32)
ChestBtn.Text = "FARM RƯƠNG: OFF"
ChestBtn.Font = Enum.Font.Cartoon
ChestBtn.TextSize = 13
ChestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ChestBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 20)
ChestBtn.BackgroundTransparency = 0.2
Instance.new("UICorner", ChestBtn).CornerRadius = UDim.new(0, 6)
local chestStroke = Instance.new("UIStroke", ChestBtn)
chestStroke.Thickness = 1.2
chestStroke.Color = Color3.fromRGB(255, 215, 0)

ChestBtn.MouseButton1Click:Connect(function()
    ChestEnabled = not ChestEnabled
    if ChestEnabled then
        LastBeli = GetCurrentBeli()
        ChestBtn.Text = "FARM RƯƠNG: ON"
        ChestBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
        chestStroke.Color = Color3.fromRGB(255, 215, 0)
    else
        TargetChest = nil
        TouchTimer = 0
        ChestBtn.Text = "FARM RƯƠNG: OFF"
        ChestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        chestStroke.Color = Color3.fromRGB(255, 215, 0)
    end
end)
