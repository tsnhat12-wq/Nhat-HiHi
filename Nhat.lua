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
_G.SPEED = 350
_G.BOOST_SPEED = 1000 
_G.BOOST_DISTANCE = 100
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
    local pg = player:FindFirstChild("PlayerGui")
    if pg then
        for _,v in ipairs(pg:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                local text = string.lower(v.Text or "")
                if string.find(text,"v3") and string.find(text,"sea") then
                    if string.find(text,"sea 1") then return 1 end
                    if string.find(text,"sea 2") then return 2 end
                    if string.find(text,"sea 3") then return 3 end
                end
            end
        end
    end

    local id = game.PlaceId
    if id == 85211729168715 then return 1 end
    if id == 79091703265657 then return 2 end
    if id == 7449423635 then return 3 end
    return 3
end

local CurrentSeaNum = GetCurrentSea()

local SeaIslandsData = {
    [1] = {
        {"Đảo Khỉ","Jungle"},
        {"Làng Hải Tặc","Pirate"},
        {"Đảo Khởi Đầu","Default"},
        {"Sa Mạc","Desert"},
        {"Thị Trấn Trung Tâm","Town"},
        {"Đảo Tuyết","Ice"},
        {"Pháo Đài Hải Quân","MarineBase"},
        {"Đảo Trời 1","Sky"},
        {"Đảo Trời 2 (Cổng)","Sky2Entrance"},
        {"Nhà Tù","Prison"},
        {"Đấu Trường","Colosseum"},
        {"Đảo Magma","Magma"},
        {"Thành Phố Đài Phun Nước","Fountain"},
        {"Đảo Dưới Nước (Cổng)","UnderwaterEntrance"}
    },
    [2] = {
        {"Quán Cà Phê (Cafe)","Bar"},
        {"Vương Quốc Hoa Hồng","Default"},
        {"Dinh Thự Sea 2 (Cổng)","MansionSea2Entrance"},
        {"Phòng Swan (Cổng)","SwanRoomEntrance"},
        {"Đảo Nghĩa Địa","Graveyard"},
        {"Vườn Thực Vật","Greenb"},
        {"Núi Tuyết","Snowy"},
        {"Lâu Đài Băng","IceCastle"},
        {"Thuyền Ma (Cổng)","CursedShipEntrance"},
        {"Đảo Nóng Lạnh","CircleIslandIce"},
        {"Đảo Lãng Quên","ForgottenIsland"}
    },
    [3] = {
        {"Đền Thời Gian","TempleOfTime"},
        {"Pháo Đài Trên Biển","SeaCastle"},
        {"Pháo Đài Trên Biển (Cổng)","SeaCastleEntrance"},
        {"Lâu Đài Bóng Tối","HauntedCastle"},
        {"Đảo Tiki","Tiki"},
        {"Đảo Bánh Kem / Katakuri","Loaf"},
        {"Đảo Socola","Chocolate"},
        {"Đảo Big Mom","IceCream"},
        {"Cây Đại Thụ","GreatTree"},
        {"Đảo Hydra (Cổng)","HydraEntrance"},
        {"Đảo Phụ Nữ (Hydra 1)","Hydra1"},
        {"Đảo Phụ Nữ (Hydra 2)","Hydra2"},
        {"Đảo Phụ Nữ (Hydra 3)","Hydra3"},
        {"Dinh Thự","BigMansion"},
        {"Dinh Thự (Cổng)","MansionEntrance"},
        {"Đảo Rùa","PineappleTown"},
        {"Thị Trấn Cảng","Default"}
    }
}

local function SpawnToIsland(spawnArg)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local commF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

    if spawnArg == "TempleOfTime" then
        if TempleFlyConnection then
            TempleFlyConnection:Disconnect()
            TempleFlyConnection = nil
        end

        local character = player.Character or player.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart")

        root.CFrame = CFrame.new(3035.22,2280.89,-7321.22)

        task.wait(0.5)

        pcall(function()
            commF:InvokeServer("requestEntrance",Vector3.new(28310.0234,14895.1123,109.456741))
        end)

        task.wait(0.5)

        local race = player.Data.Race.Value
        local targetCFrame

        if race == "Fishman" then
            targetCFrame = CFrame.new(28224.056640625,14889.4267578125,-210.5872039794922)
        elseif race == "Cyborg" then
            targetCFrame = CFrame.new(28492.4140625,14894.4267578125,-422.1100158691406)
        elseif race == "Skypiea" then
            targetCFrame = CFrame.new(28967.408203125,14918.0751953125,234.31198120117188)
        elseif race == "Ghoul" then
            targetCFrame = CFrame.new(28672.720703125,14889.1279296875,454.5961608886719)
        elseif race == "Human" then
            targetCFrame = CFrame.new(29237.294921875,14889.4267578125,-206.94955444335938)
        else
            targetCFrame = CFrame.new(29020.66015625,14889.4267578125,-379.2682800292969)
        end

        EnableAntiGravity()
        EnableNoclip()

        TempleFlyConnection = RunService.Heartbeat:Connect(function()
            if root and root.Parent then
                root.CFrame = targetCFrame
            end
        end)

        task.delay(1,function()
            if TempleFlyConnection then
                TempleFlyConnection:Disconnect()
                TempleFlyConnection = nil
            end
        end)

        return
    end

    local entrances = {
        CursedShipEntrance = Vector3.new(923.21,126.97,32852.83),
        MansionSea2Entrance = Vector3.new(-325.47,331.92,600.17),
        SwanRoomEntrance = Vector3.new(2284.90,15.53,905.46),
        Sky2Entrance = Vector3.new(-6023.57666015625,5469.7197265625,2203.308349609375),
        UnderwaterEntrance = Vector3.new(61163.85,11.68,1819.78),
        SeaCastleEntrance = Vector3.new(-5089.14,314.58,-3164.46),
        MansionEntrance = Vector3.new(-12549.40,336.98,-7576.59),
        HydraEntrance = Vector3.new(5681.00,1013.11,-307.12)
    }

    if entrances[spawnArg] then
        pcall(function()
            commF:InvokeServer("requestEntrance",entrances[spawnArg])
        end)
        task.wait(0.5)
    end

    pcall(function()
        commF:InvokeServer("SetLastSpawnPoint",spawnArg)
    end)

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.Health = 0
    end
end

local SeaGui = Instance.new("ScreenGui")
SeaGui.Name = "NhatSeaGui"
SeaGui.ResetOnSpawn = false
SeaGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SeaGui.Parent = player:WaitForChild("PlayerGui")

local RainbowColors = {
    Color3.fromRGB(255,0,0),
    Color3.fromRGB(255,120,0),
    Color3.fromRGB(255,255,0),
    Color3.fromRGB(0,255,100),
    Color3.fromRGB(0,200,255),
    Color3.fromRGB(80,100,255),
    Color3.fromRGB(180,0,255),
    Color3.fromRGB(255,0,180)
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

    return holder,bars
end

local function UpdateRainbowBars(holder,bars,time,speed)
    local w = holder.AbsoluteSize.X
    local h = holder.AbsoluteSize.Y
    local perimeter = w*2+h*2

    for i,bar in ipairs(bars) do
        local offset = ((time*speed)+(i-1)*(perimeter/4))%perimeter
        local x,y,rotation

        if offset < w then
            x,y,rotation = offset,0,0
        elseif offset < w+h then
            x,y,rotation = w,offset-w,90
        elseif offset < w*2+h then
            x,y,rotation = w-(offset-w-h),h,180
        else
            x,y,rotation = 0,h-(offset-w*2-h),270
        end

        bar.Position = UDim2.new(0,x,0,y)
        bar.Rotation = rotation

        local index = (math.floor(time*5)+i-1)%#RainbowColors+1
        bar.BackgroundColor3 = RainbowColors[index]
    end
end

local ToggleBtn = Instance.new("ImageButton",SeaGui)
ToggleBtn.Size = UDim2.new(0,42,0,42)
ToggleBtn.Position = UDim2.new(0.015,0,0.2,0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(10,15,25)
ToggleBtn.BackgroundTransparency = 0.05
ToggleBtn.Image = "rbxassetid://118492596948240"
ToggleBtn.ScaleType = Enum.ScaleType.Fit
ToggleBtn.Draggable = true
ToggleBtn.ZIndex = 20

local toggleStroke = Instance.new("UIStroke",ToggleBtn)
toggleStroke.Thickness = 1.5
toggleStroke.Color = Color3.fromRGB(0,170,255)

local ToggleRainbow,ToggleBars = CreateRainbowBars(ToggleBtn,UDim2.new(1,4,1,4),18,2)
ToggleRainbow.ZIndex = 21

local MainMenu = Instance.new("Frame",SeaGui)
MainMenu.Size = UDim2.new(0,230,0,290)
MainMenu.AnchorPoint = Vector2.new(0.5,0.5)
MainMenu.Position = UDim2.new(0.5,0,0.5,0)
MainMenu.BackgroundColor3 = Color3.fromRGB(10,15,25)
MainMenu.BackgroundTransparency = 0.08
MainMenu.Visible = false
MainMenu.Draggable = true
MainMenu.ZIndex = 5

local menuStroke = Instance.new("UIStroke",MainMenu)
menuStroke.Thickness = 1.5
menuStroke.Color = Color3.fromRGB(0,170,255)

local MenuRainbow,MenuBars = CreateRainbowBars(MainMenu,UDim2.new(1,4,1,4),45,3)
MenuRainbow.ZIndex = 6

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

local Scroll = Instance.new("ScrollingFrame",MainMenu)
Scroll.Size = UDim2.new(1,-10,1,-45)
Scroll.Position = UDim2.new(0,5,0,40)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ZIndex = 10

local Layout = Instance.new("UIListLayout",Scroll)
Layout.Padding = UDim.new(0,4)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

local Padding = Instance.new("UIPadding",Scroll)
Padding.PaddingTop = UDim.new(0,2)
Padding.PaddingBottom = UDim.new(0,4)

local function AddIslandButton(text,spawnArg)
    local button = Instance.new("TextButton",Scroll)
    button.Size = UDim2.new(1,-4,0,30)
    button.BackgroundColor3 = Color3.fromRGB(15,20,30)
    button.BackgroundTransparency = 0.1
    button.BorderSizePixel = 0
    button.Text = text
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 12
    button.TextColor3 = Color3.fromRGB(100,200,255)
    button.AutoButtonColor = false
    button.ZIndex = 11

    local stroke = Instance.new("UIStroke",button)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(0,170,255)

    Instance.new("UICorner",button).CornerRadius = UDim.new(0,5)

    button.MouseButton1Click:Connect(function()
        SpawnToIsland(spawnArg)
    end)
end

for _,data in ipairs(SeaIslandsData[CurrentSeaNum] or {}) do
    AddIslandButton(data[1],data[2])
end

local MenuOpen = false
local RainbowTime = 0

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

RunService.RenderStepped:Connect(function(dt)
    RainbowTime += dt

    local ToggleSpeed = MenuOpen and 220 or 90
    local MenuSpeed = MenuOpen and 160 or 80

    UpdateRainbowBars(ToggleRainbow,ToggleBars,RainbowTime,ToggleSpeed)

    if MainMenu.Visible then
        UpdateRainbowBars(MenuRainbow,MenuBars,RainbowTime,MenuSpeed)
    end

    local index = (math.floor(RainbowTime*6)%#RainbowColors)+1
    toggleStroke.Color = RainbowColors[index]
    menuStroke.Color = RainbowColors[index]
end)
-- ===================================================
-- 6. CÁC NÚT TÍNH NĂNG
-- ===================================================

local FeatureButtons = {}
local BlueColor = Color3.fromRGB(100,200,255)

local function AddRainbowButton(button,stroke)
    table.insert(FeatureButtons,{Button=button,Stroke=stroke})
end

local function AddFeatureButton(text,callback)
    local button = Instance.new("TextButton",Scroll)
    button.Size = UDim2.new(1,-4,0,30)
    button.BackgroundColor3 = Color3.fromRGB(15,20,30)
    button.BackgroundTransparency = 0.1
    button.BorderSizePixel = 0
    button.Text = text
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 12
    button.TextColor3 = BlueColor
    button.AutoButtonColor = false
    button.ZIndex = 11

    local stroke = Instance.new("UIStroke",button)
    stroke.Thickness = 1
    stroke.Color = BlueColor

    Instance.new("UICorner",button).CornerRadius = UDim.new(0,5)

    button.MouseButton1Click:Connect(function()
        callback(button,stroke)
    end)

    return button,stroke
end

local FruitEnabled = false
local MobEnabled = false
local ChestEnabled = false

local FruitButton,FruitStroke = AddFeatureButton(
    "BAY TỚI TRÁI: OFF",
    function(button,stroke)
        FruitEnabled = not FruitEnabled

        if FruitEnabled then
            button.Text = "BAY TỚI TRÁI: ON"
        else
            button.Text = "BAY TỚI TRÁI: OFF"
            TargetFruit = nil
        end
    end
)

local MobButton,MobStroke = AddFeatureButton(
    "BAY TỚI QUÁI: OFF",
    function(button,stroke)
        MobEnabled = not MobEnabled

        if MobEnabled then
            button.Text = "BAY TỚI QUÁI: ON"
        else
            button.Text = "BAY TỚI QUÁI: OFF"
            TargetMob = nil
        end
    end
)

local ChestButton,ChestStroke = AddFeatureButton(
    "FARM RƯƠNG: OFF",
    function(button,stroke)
        ChestEnabled = not ChestEnabled

        if ChestEnabled then
            button.Text = "FARM RƯƠNG: ON"
            LastBeli = GetCurrentBeli()
        else
            button.Text = "FARM RƯƠNG: OFF"
            TargetChest = nil
            TouchTimer = 0
        end
    end
)

AddRainbowButton(FruitButton,FruitStroke)
AddRainbowButton(MobButton,MobStroke)
AddRainbowButton(ChestButton,ChestStroke)

-- ===================================================
-- MÀU NÚT TÍNH NĂNG
-- ===================================================

for _,data in ipairs(FeatureButtons) do
    data.Button.TextColor3 = BlueColor
    data.Stroke.Color = BlueColor
    data.Button.BackgroundColor3 = Color3.fromRGB(15,20,30)
end
