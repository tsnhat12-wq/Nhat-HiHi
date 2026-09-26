-- ===================================================
-- 1. THÔNG BÁO ĐẾM NGƯỢC 5.0s -> 0.0s
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
_G.SPEED = 250
_G.BOOST_SPEED = 1000 -- Tốc độ bứt phá khi dưới 60 studs
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
local TargetBeam = nil
local TargetBeamAttachment = nil
local TargetBeamTargetAttachment = nil

local function RemoveTargetBeam()
    if TargetBeam then
        TargetBeam:Destroy()
        TargetBeam = nil
    end
    if TargetBeamAttachment then
        TargetBeamAttachment:Destroy()
        TargetBeamAttachment = nil
    end
    if TargetBeamTargetAttachment then
        TargetBeamTargetAttachment:Destroy()
        TargetBeamTargetAttachment = nil
    end
end

local function UpdateTargetBeam(Target)
    RemoveTargetBeam()

    local Character = LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root or not Target or not Target.Parent then return end

    local TargetPart

    if Target:IsA("BasePart") then
        TargetPart = Target
    elseif Target:IsA("Model") then
        TargetPart = Target:FindFirstChild("HumanoidRootPart") or Target.PrimaryPart or Target:FindFirstChildOfClass("BasePart")
    end

    if not TargetPart then return end

    TargetBeamAttachment = Instance.new("Attachment")
    TargetBeamAttachment.Name = "AxiomTargetAttachment"
    TargetBeamAttachment.Parent = Root

    TargetBeamTargetAttachment = Instance.new("Attachment")
    TargetBeamTargetAttachment.Name = "AxiomTargetAttachment"
    TargetBeamTargetAttachment.Parent = TargetPart

    TargetBeam = Instance.new("Beam")
    TargetBeam.Name = "AxiomTargetBeam"
    TargetBeam.Attachment0 = TargetBeamAttachment
    TargetBeam.Attachment1 = TargetBeamTargetAttachment
    TargetBeam.FaceCamera = true
    TargetBeam.Width0 = 0.12
    TargetBeam.Width1 = 0.12
    TargetBeam.Color = ColorSequence.new(Color3.fromRGB(0,170,255))
    TargetBeam.Transparency = NumberSequence.new(0.15)
    TargetBeam.LightEmission = 1
    TargetBeam.LightInfluence = 0
    TargetBeam.Parent = Root
end

local function IsBloxFruitsMob(Model)
    if not Model or not Model:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(Model) then return false end

    local Humanoid = Model:FindFirstChildOfClass("Humanoid")
    local Root = Model:FindFirstChild("HumanoidRootPart") or Model.PrimaryPart

    if not Humanoid or not Root or Humanoid.Health <= 0 then return false end

    if Model.Parent and Model.Parent.Name == "Enemies" then
        return true
    end

    local name = Model.Name:lower()

    if name:find("quest") or name:find("giver") or name:find("merchant") or name:find("dealer") or name:find("title") or name:find("blox fruit") then
        return false
    end

    if Model:FindFirstChild("Dialogue") or Model:FindFirstChild("Quest") or Model:FindFirstChildOfClass("Dialog") then
        return false
    end

    return true
end

-- ===================================================
-- TÌM QUÁI GẦN NHẤT
-- ===================================================
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
                local Distance = (Root.Position-MyRoot.Position).Magnitude
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
                    local Distance = (Root.Position-MyRoot.Position).Magnitude
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

-- ===================================================
-- TÌM RƯƠNG GẦN NHẤT
-- ===================================================
local function FindNearestTaggedChest()
    local MyRoot = GetRoot()
    if not MyRoot then return nil end

    local Position = MyRoot.Position
    local Distance, Nearest = math.huge, nil

    local Chests = CollectionService:GetTagged("_ChestTagged")

    for i = 1,#Chests do
        local Chest = Chests[i]

        if Chest and Chest.Parent and not IgnoredChests[Chest] then
            if not Chest:GetAttribute("IsDisabled") then
                local Magnitude = (Chest:GetPivot().Position-Position).Magnitude

                if Magnitude < Distance then
                    Distance = Magnitude
                    Nearest = Chest
                end
            end
        end
    end

    if not Nearest then
        for _, object in ipairs(Workspace:GetChildren()) do
            if object.Name:find("Chest") and not IgnoredChests[object] then
                local touchPart = object:IsA("BasePart") and object or object.PrimaryPart or object:FindFirstChildOfClass("BasePart")

                if touchPart then
                    local Magnitude = (touchPart.Position-Position).Magnitude

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

-- ===================================================
-- TÌM TRÁI GẦN NHẤT
-- ===================================================
local function FindNearestFruit()
    local MyRoot = GetRoot()
    if not MyRoot then return nil end

    local Nearest, NearestDistance = nil, 150000

    for _, v in ipairs(Workspace:GetChildren()) do
        if v:IsA("Tool") or (v:IsA("Model") and v:FindFirstChild("Handle")) then
            local name = v.Name:lower()

            if name:find("fruit") or name:find("trái") or name:find("trai") then
                local Handle = v:FindFirstChild("Handle") or v.PrimaryPart or v:FindFirstChildOfClass("BasePart")

                if Handle then
                    local Distance = (Handle.Position-MyRoot.Position).Magnitude

                    if Distance < NearestDistance then
                        NearestDistance = Distance
                        Nearest = Handle
                    end
                end
            end
        end
    end

    return Nearest
end

-- ===================================================
-- THEO DÕI BELI
-- ===================================================
local function GetCurrentBeli()
    local data = LocalPlayer:FindFirstChild("Data")

    if data and data:FindFirstChild("Beli") then
        return data.Beli.Value
    end

    local stats = LocalPlayer:FindFirstChild("leaderstats")

    if stats and stats:FindFirstChild("Beli") then
        return stats.Beli.Value
    end

    if stats and stats:FindFirstChild("Money") then
        return stats.Money.Value
    end

    return 0
end

local LastBeli = GetCurrentBeli()

task.spawn(function()
    while task.wait(0.1) do
        local CurrentMoney = GetCurrentBeli()

        if CurrentMoney > LastBeli then
            LastBeli = CurrentMoney

            if ChestEnabled and TargetChest then
                IgnoredChests[TargetChest] = true
                TargetChest = nil
                RemoveTargetBeam()
            end
        else
            LastBeli = CurrentMoney
        end
    end
end)

-- ===================================================
-- 5. LOOP ĐIỀU KHIỂN BAY TỚI MỤC TIÊU
-- ===================================================
RunService.Heartbeat:Connect(function(DeltaTime)
    if not MobEnabled and not ChestEnabled and not FruitEnabled then
        DisableAntiGravity()
        DisableNoclip()
        RemoveTargetBeam()
        return
    end

    local MyRoot = GetRoot()

    if not MyRoot then
        DisableAntiGravity()
        DisableNoclip()
        RemoveTargetBeam()
        return
    end

    -- ===================================================
    -- ƯU TIÊN 1: BAY TỚI TRÁI
    -- ===================================================
    if FruitEnabled then
        if not TargetFruit or not TargetFruit.Parent then
            TargetFruit = FindNearestFruit()
        end

        if not TargetFruit then
            DisableAntiGravity()
            DisableNoclip()
            RemoveTargetBeam()
            return
        end

        EnableAntiGravity(MyRoot)
        EnableNoclip()
        UpdateTargetBeam(TargetFruit)

        local TargetCFrame = TargetFruit.CFrame*CFrame.new(0,_G.DOCAO_FRUIT,0)
        local Distance = (TargetCFrame.Position-MyRoot.Position).Magnitude

        if Distance <= 4 and firetouchinterest then
            firetouchinterest(MyRoot,TargetFruit,0)
            firetouchinterest(MyRoot,TargetFruit,1)
        end

        -- <= 90 STUDS THÌ BOOST
        local ActiveSpeed = Distance <= _G.BOOST_DISTANCE and _G.BOOST_SPEED or _G.SPEED
        local Alpha = math.clamp((ActiveSpeed*DeltaTime)/math.max(Distance,0.001),0,1)

        MyRoot.CFrame = MyRoot.CFrame:Lerp(TargetCFrame,Alpha)

    -- ===================================================
    -- ƯU TIÊN 2: BAY TỚI QUÁI
    -- ===================================================
    elseif MobEnabled then
        if not TargetMob or not TargetMob.Parent or not IsBloxFruitsMob(TargetMob) then
            TargetMob = FindNearestMob()
        end

        if not TargetMob then
            DisableAntiGravity()
            DisableNoclip()
            RemoveTargetBeam()
            return
        end

        local MobRoot = TargetMob:FindFirstChild("HumanoidRootPart") or TargetMob.PrimaryPart

        if not MobRoot then
            DisableAntiGravity()
            DisableNoclip()
            RemoveTargetBeam()
            return
        end

        EnableAntiGravity(MyRoot)
        EnableNoclip()
        UpdateTargetBeam(TargetMob)

        local TargetCFrame = MobRoot.CFrame*CFrame.new(_G.DOXATP,_G.DOCAO_MOB,0)
        local Distance = (TargetCFrame.Position-MyRoot.Position).Magnitude

        if Distance > 0.05 then
            local ActiveSpeed = Distance <= _G.BOOST_DISTANCE and _G.BOOST_SPEED or _G.SPEED
            local Alpha = math.clamp((ActiveSpeed*DeltaTime)/math.max(Distance,0.001),0,1)

            MyRoot.CFrame = MyRoot.CFrame:Lerp(TargetCFrame,Alpha)
        end

    -- ===================================================
    -- ƯU TIÊN 3: FARM RƯƠNG
    -- ===================================================
    elseif ChestEnabled then
        if not TargetChest or not TargetChest.Parent or IgnoredChests[TargetChest] or TargetChest:GetAttribute("IsDisabled") then
            TargetChest = FindNearestTaggedChest()
            TouchTimer = 0
        end

        if not TargetChest then
            DisableAntiGravity()
            DisableNoclip()
            RemoveTargetBeam()
            return
        end

        EnableAntiGravity(MyRoot)
        EnableNoclip()
        UpdateTargetBeam(TargetChest)

        local TargetCFrame = TargetChest:GetPivot()*CFrame.new(0,_G.DOCAO_CHEST,0)
        local Distance = (TargetCFrame.Position-MyRoot.Position).Magnitude
        local ActiveSpeed = Distance <= _G.BOOST_DISTANCE and _G.BOOST_SPEED or _G.SPEED

        if Distance <= 4 then
            TouchTimer = TouchTimer+DeltaTime

            if firetouchinterest then
                local TouchPart = TargetChest:IsA("BasePart") and TargetChest or TargetChest.PrimaryPart or TargetChest:FindFirstChildOfClass("BasePart")

                if TouchPart then
                    firetouchinterest(MyRoot,TouchPart,0)
                    firetouchinterest(MyRoot,TouchPart,1)
                end
            end

            if TouchTimer >= 0.4 then
                IgnoredChests[TargetChest] = true
                TargetChest = nil
                TouchTimer = 0
                RemoveTargetBeam()
                return
            end
        else
            TouchTimer = 0
        end

        local Alpha = math.clamp((ActiveSpeed*DeltaTime)/math.max(Distance,0.001),0,1)
        MyRoot.CFrame = MyRoot.CFrame:Lerp(TargetCFrame,Alpha)
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
        {"Đảo Khỉ","Jungle"},{"Làng Hải Tặc","Pirate"},{"Đảo Khởi Đầu","Default"},
        {"Sa Mạc","Desert"},{"Thị Trấn Trung Tâm","Town"},{"Đảo Tuyết","Ice"},
        {"Pháo Đài Hải Quân","MarineBase"},{"Đảo Trời 1","Sky"},{"Đảo Trời 2 (Cổng)","Sky2Entrance"},
        {"Nhà Tù","Prison"},{"Đấu Trường","Colosseum"},{"Đảo Magma","Magma"},
        {"Thành Phố Đài Phun Nước","Fountain"},{"Đảo Dưới Nước (Cổng)","UnderwaterEntrance"}
    },
    [2] = {
        {"Quán Cà Phê (Cafe)","Bar"},{"Vương Quốc Hoa Hồng","Default"},{"Dinh Thự Sea 2 (Cổng)","MansionSea2Entrance"},
        {"Phòng Swan (Cổng)","SwanRoomEntrance"},{"Đảo Nghĩa Địa","Graveyard"},{"Vườn Thực Vật","Greenb"},
        {"Núi Tuyết","Snowy"},{"Lâu Đài Băng","IceCastle"},{"Thuyền Ma (Cổng)","CursedShipEntrance"},
        {"Đảo Nóng Lạnh","CircleIslandIce"},{"Đảo Lãng Quên","ForgottenIsland"}
    },
    [3] = {
        {"Đền Thời Gian","TempleOfTime"},{"Pháo Đài Trên Biển","SeaCastle"},
        {"Pháo Đài Trên Biển (Cổng)","SeaCastleEntrance"},{"Lâu Đài Bóng Tối","HauntedCastle"},
        {"Đảo Tiki","Tiki"},{"Đảo Bánh Kem / Katakuri","Loaf"},{"Đảo Socola","Chocolate"},
        {"Đảo Big Mom","IceCream"},{"Cây Đại Thụ","GreatTree"},{"Đảo Hydra (Cổng)","HydraEntrance"},
        {"Đảo Phụ Nữ (Hydra 1)","Hydra1"},{"Đảo Phụ Nữ (Hydra 2)","Hydra2"},
        {"Đảo Phụ Nữ (Hydra 3)","Hydra3"},{"Dinh Thự","BigMansion"},
        {"Dinh Thự (Cổng)","MansionEntrance"},{"Đảo Rùa","PineappleTown"},{"Thị Trấn Cảng","Default"}
    }
}

local CurrentList = SeaIslandsData[CurrentSeaNum] or SeaIslandsData[3]

local SeaGui = Instance.new("ScreenGui")
SeaGui.Name = "SeaMenu_Gui"
SeaGui.ResetOnSpawn = false
pcall(function() SeaGui.Parent = CoreGui end)
if not SeaGui.Parent then SeaGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local ToggleBtn = Instance.new("ImageButton",SeaGui)
ToggleBtn.Size = UDim2.new(0,35,0,35)
ToggleBtn.Position = UDim2.new(0.015,0,0.2,0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15,25,35)
ToggleBtn.BackgroundTransparency = 0.2
ToggleBtn.Draggable = true
ToggleBtn.ClipsDescendants = true
ToggleBtn.Image = "rbxassetid://77399452392419"
Instance.new("UICorner",ToggleBtn).CornerRadius = UDim.new(1,0)

local toggleStroke = Instance.new("UIStroke",ToggleBtn)
toggleStroke.Thickness = 1.5
toggleStroke.Color = Color3.fromRGB(0,170,255)

local MainMenu = Instance.new("Frame",SeaGui)
MainMenu.Size = UDim2.new(0,230,0,290)
MainMenu.AnchorPoint = Vector2.new(0.5,0.5)
MainMenu.Position = UDim2.new(0.5,0,0.5,0)
MainMenu.BackgroundColor3 = Color3.fromRGB(15,20,28)
MainMenu.BackgroundTransparency = 0.15
MainMenu.Visible = false
MainMenu.Draggable = true
Instance.new("UICorner",MainMenu).CornerRadius = UDim.new(0,10)

local menuStroke = Instance.new("UIStroke",MainMenu)
menuStroke.Thickness = 1.5
menuStroke.Color = Color3.fromRGB(0,170,255)

local Title = Instance.new("TextLabel",MainMenu)
Title.Size = UDim2.new(1,0,0,35)
Title.Text = "BYPASS TP SEA "..CurrentSeaNum
Title.Font = Enum.Font.Cartoon
Title.TextSize = 15
Title.TextColor3 = Color3.fromRGB(100,200,255)
Title.BackgroundTransparency = 1

local Scroll = Instance.new("ScrollingFrame",MainMenu)
Scroll.Size = UDim2.new(1,0,1,-40)
Scroll.Position = UDim2.new(0,0,0,38)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 3
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.None

local UIList = Instance.new("UIListLayout",Scroll)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0,6)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0,0,0,UIList.AbsoluteContentSize.Y + 10)
end)

ToggleBtn.MouseButton1Click:Connect(function()
    MainMenu.Visible = not MainMenu.Visible
end)

-- ===================================================
-- HÀM THỰC THI TELEPORT CỔNG
-- ===================================================

local function SpawnToIsland(spawnArg)
    local commF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

    -- TEMPLE OF TIME
    if spawnArg == "TempleOfTime" then
        if TempleFlyConnection or BodyVelocity then
            if TempleFlyConnection then
                TempleFlyConnection:Disconnect()
                TempleFlyConnection = nil
            end
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
                    if TempleFlyConnection then
                        TempleFlyConnection:Disconnect()
                        TempleFlyConnection = nil
                    end
                    DisableAntiGravity()
                    DisableNoclip()
                    return
                end

                currentHrp.AssemblyLinearVelocity = Vector3.zero
                currentHrp.AssemblyAngularVelocity = Vector3.zero

                if phase == 2 then return end

                local targetCFrame
                if phase == 1 then
                    targetCFrame = entranceCFrame
                elseif phase == 3 then
                    targetCFrame = raceCFrame
                end

                if not targetCFrame then return end

                local distance = (currentHrp.Position-targetCFrame.Position).Magnitude
                local boostDistance = tonumber(_G.BOOST_DISTANCE) or 90
                local boostSpeed = tonumber(_G.BOOST_SPEED) or 1000
                local normalSpeed = tonumber(_G.SPEED) or 140
                local activeSpeed = distance <= boostDistance and boostSpeed or normalSpeed
                local alpha = math.clamp((activeSpeed*deltaTime)/math.max(distance,0.001),0,1)

                if phase == 1 then
                    if distance <= 0.5 then
                        phase = 2

                        task.spawn(function()
                            for i = 1,10 do
                                local mapFolder = Workspace:FindFirstChild("Map") or Workspace

                                if not mapFolder:FindFirstChild("Temple of Time") then
                                    local stash = ReplicatedStorage:FindFirstChild("MapStash") or ReplicatedStorage
                                    local tot = stash:FindFirstChild("Temple of Time")

                                    if tot then
                                        tot.Parent = mapFolder
                                        break
                                    end
                                else
                                    break
                                end

                                task.wait(0.3)
                            end

                            task.wait(0.5)

                            pcall(function()
                                commF:InvokeServer(
                                    "requestEntrance",
                                    Vector3.new(28310.0234,14895.1123,109.456741)
                                )
                            end)

                            task.wait(0.5)

                            local race = nil
                            pcall(function()
                                race = LocalPlayer.Data.Race.Value
                            end)

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
                        if TempleFlyConnection then
                            TempleFlyConnection:Disconnect()
                            TempleFlyConnection = nil
                        end

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
    elseif spawnArg == "CursedShipEntrance" then
        pcall(function() commF:InvokeServer("requestEntrance",Vector3.new(923.21,126.97,32852.83)) end)
        return
    elseif spawnArg == "MansionSea2Entrance" then
        pcall(function() commF:InvokeServer("requestEntrance",Vector3.new(-325.47,331.92,600.17)) end)
        return
    elseif spawnArg == "SwanRoomEntrance" then
        pcall(function() commF:InvokeServer("requestEntrance",Vector3.new(2284.90,15.53,905.46)) end)
        return
    elseif spawnArg == "Sky2Entrance" then
        pcall(function() commF:InvokeServer("requestEntrance",Vector3.new(-6023.57666015625,5469.7197265625,2203.308349609375)) end)
        return
    elseif spawnArg == "UnderwaterEntrance" then
        pcall(function() commF:InvokeServer("requestEntrance",Vector3.new(61163.85,11.68,1819.78)) end)
        return
    elseif spawnArg == "SeaCastleEntrance" then
        pcall(function() commF:InvokeServer("requestEntrance",Vector3.new(-5089.14,314.58,-3164.46)) end)
        return
    elseif spawnArg == "MansionEntrance" then
        pcall(function() commF:InvokeServer("requestEntrance",Vector3.new(-12549.40,336.98,-7576.59)) end)
        return
    elseif spawnArg == "HydraEntrance" then
        pcall(function() commF:InvokeServer("requestEntrance",Vector3.new(5681.00,1013.11,-307.12)) end)
        return
    end

    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.Health = 0
        pcall(function()
            commF:InvokeServer("SetLastSpawnPoint",spawnArg)
        end)
    end
end

-- ===================================================
-- TẠO NÚT ĐẢO
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
    Btn.AutoButtonColor = false

    Instance.new("UICorner",Btn).CornerRadius = UDim.new(0,6)

    local btnS = Instance.new("UIStroke",Btn)
    btnS.Thickness = 1
    btnS.Color = Color3.fromRGB(0,120,200)

    Btn.MouseButton1Click:Connect(function()
        SpawnToIsland(spawnArg)
    end)
end

-- ===================================================
-- 6. TOGGLE BAY TRÁI / QUÁI / FARM RƯƠNG
-- ===================================================

local BLUE = Color3.fromRGB(0,170,255)
local OFF_BG = Color3.fromRGB(35,40,48)
local ON_BG = Color3.fromRGB(15,70,105)
local TEXT_COLOR = Color3.fromRGB(100,200,255)

local function CreateToggle(Name,Callback)
    local Holder = Instance.new("Frame",Scroll)
    Holder.Size = UDim2.new(0.9,0,0,38)
    Holder.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel",Holder)
    Label.Size = UDim2.new(1,-65,1,0)
    Label.Position = UDim2.new(0,5,0,0)
    Label.BackgroundTransparency = 1
    Label.Text = Name
    Label.Font = Enum.Font.Cartoon
    Label.TextSize = 13
    Label.TextColor3 = TEXT_COLOR
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Switch = Instance.new("TextButton",Holder)
    Switch.Size = UDim2.new(0,48,0,24)
    Switch.Position = UDim2.new(1,-53,0.5,-12)
    Switch.BackgroundColor3 = OFF_BG
    Switch.AutoButtonColor = false
    Switch.Text = ""

    Instance.new("UICorner",Switch).CornerRadius = UDim.new(1,0)

    local Stroke = Instance.new("UIStroke",Switch)
    Stroke.Thickness = 1
    Stroke.Color = Color3.fromRGB(70,80,90)

    local Knob = Instance.new("Frame",Switch)
    Knob.Size = UDim2.new(0,18,0,18)
    Knob.Position = UDim2.new(0,3,0.5,-9)
    Knob.BackgroundColor3 = Color3.fromRGB(170,175,180)

    Instance.new("UICorner",Knob).CornerRadius = UDim.new(1,0)

    local Enabled = false

    local function Update()
        if Enabled then
            Switch.BackgroundColor3 = ON_BG
            Stroke.Color = BLUE
            Knob.BackgroundColor3 = BLUE
            Knob.Position = UDim2.new(1,-21,0.5,-9)
        else
            Switch.BackgroundColor3 = OFF_BG
            Stroke.Color = Color3.fromRGB(70,80,90)
            Knob.BackgroundColor3 = Color3.fromRGB(170,175,180)
            Knob.Position = UDim2.new(0,3,0.5,-9)
        end

        Callback(Enabled)
    end

    Switch.MouseButton1Click:Connect(function()
        Enabled = not Enabled
        Update()
    end)

    return {
        Set = function(Value)
            Enabled = Value
            Update()
        end,
        Get = function()
            return Enabled
        end
    }
end

-- ===================================================
-- BAY TỚI TRÁI
-- ===================================================

local FruitToggle = CreateToggle("BAY TỚI TRÁI",function(Value)
    FruitEnabled = Value
    TargetFruit = nil
end)

-- ===================================================
-- BAY TỚI QUÁI
-- ===================================================

local MobToggle = CreateToggle("BAY TỚI QUÁI",function(Value)
    MobEnabled = Value
    TargetMob = nil
end)

-- ===================================================
-- FARM RƯƠNG
-- ===================================================

local ChestToggle = CreateToggle("FARM RƯƠNG",function(Value)
    ChestEnabled = Value

    if Value then
        LastBeli = GetCurrentBeli()
    end

    TargetChest = nil
    TouchTimer = 0
end)
