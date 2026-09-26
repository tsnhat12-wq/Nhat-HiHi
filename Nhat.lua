
-- ===================================================
-- 1. THÔNG BÁO LOAD
-- ===================================================
local CoreGui=game:GetService("CoreGui")
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local Workspace=game:GetService("Workspace")
local CollectionService=game:GetService("CollectionService")
local UserInputService=game:GetService("UserInputService")
local LocalPlayer=Players.LocalPlayer

local WaitNotice_Gui=Instance.new("ScreenGui")
WaitNotice_Gui.Name="WaitNotice_Gui"
WaitNotice_Gui.ResetOnSpawn=false
WaitNotice_Gui.Parent=CoreGui

local NoticeFrame=Instance.new("Frame",WaitNotice_Gui)
NoticeFrame.Size=UDim2.new(0,230,0,70)
NoticeFrame.Position=UDim2.new(0.5,-115,0.5,-35)
NoticeFrame.BackgroundColor3=Color3.fromRGB(25,25,25)
Instance.new("UICorner",NoticeFrame).CornerRadius=UDim.new(0,8)

local NoticeText=Instance.new("TextLabel",NoticeFrame)
NoticeText.Size=UDim2.new(1,-10,1,-10)
NoticeText.Position=UDim2.new(0,5,0,5)
NoticeText.BackgroundTransparency=1
NoticeText.TextColor3=Color3.fromRGB(100,200,255)
NoticeText.Font=Enum.Font.Cartoon
NoticeText.TextSize=18

for i=10,0,-1 do
    NoticeText.Text=string.format("Đang Load Menu... %.1fs",i/10)
    task.wait(0.1)
end

WaitNotice_Gui:Destroy()

-- ===================================================
-- 2. XÓA GUI CŨ
-- ===================================================
local OldGUIs={
    "SeaMenu_Gui",
    "AxiomTeleportMobBF",
    "AxiomTeleportChestBF",
    "AxiomTeleportFruitBF",
    "SpeedControllerUI"
}

for _,Name in ipairs(OldGUIs) do
    local Old=CoreGui:FindFirstChild(Name) or LocalPlayer.PlayerGui:FindFirstChild(Name)
    if Old then Old:Destroy() end
end

-- ===================================================
-- 3. CẤU HÌNH
-- ===================================================
_G.SPEED=220
_G.BOOST_SPEED=1000
_G.BOOST_DISTANCE=100
_G.DOCAO_MOB=45
_G.DOCAO_CHEST=0
_G.DOCAO_FRUIT=1
_G.DOXATP=0

local MobEnabled=false
local ChestEnabled=false
local FruitEnabled=false

local TargetMob=nil
local TargetChest=nil
local TargetFruit=nil

local TempleFlyConnection=nil
local BodyVelocity=nil
local NoclipConnection=nil

local IgnoredChests={}
local TouchTimer=0
local SEARCH_MOB_DISTANCE=1000

-- ===================================================
-- HÀM ROOT
-- ===================================================
local function GetRoot(Character)
    return Character and (Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("RootPart"))
end

-- ===================================================
-- ANTI GRAVITY
-- ===================================================
local function EnableAntiGravity()
    local Character=LocalPlayer.Character
    local Root=GetRoot(Character)
    if not Root then return end

    if not BodyVelocity then
        BodyVelocity=Instance.new("BodyVelocity")
        BodyVelocity.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
        BodyVelocity.Velocity=Vector3.zero
        BodyVelocity.Parent=Root
    elseif BodyVelocity.Parent~=Root then
        BodyVelocity.Parent=Root
    end
end

local function DisableAntiGravity()
    if BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity=nil
    end
end

-- ===================================================
-- NOCLIP
-- ===================================================
local function EnableNoclip()
    if NoclipConnection then return end

    NoclipConnection=RunService.Stepped:Connect(function()
        local Character=LocalPlayer.Character
        if Character then
            for _,Part in ipairs(Character:GetDescendants()) do
                if Part:IsA("BasePart") then
                    Part.CanCollide=false
                end
            end
        end
    end)
end

local function DisableNoclip()
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection=nil
    end
end

-- ===================================================
-- TARGET BEAM
-- ===================================================
local TargetBeam=nil
local TargetBeamAttachment=nil
local TargetBeamTargetAttachment=nil

local function RemoveTargetBeam()
    if TargetBeam then TargetBeam:Destroy() TargetBeam=nil end
    if TargetBeamAttachment then TargetBeamAttachment:Destroy() TargetBeamAttachment=nil end
    if TargetBeamTargetAttachment then TargetBeamTargetAttachment:Destroy() TargetBeamTargetAttachment=nil end
end

local function UpdateTargetBeam(Target)
    RemoveTargetBeam()
    if not Target then return end

    local Root=GetRoot(LocalPlayer.Character)
    if not Root then return end

    local TargetPart

    if Target:IsA("Model") then
        TargetPart=Target:FindFirstChild("HumanoidRootPart") or Target.PrimaryPart
    elseif Target:IsA("BasePart") then
        TargetPart=Target
    end

    if not TargetPart then return end

    TargetBeamAttachment=Instance.new("Attachment",Root)
    TargetBeamTargetAttachment=Instance.new("Attachment",TargetPart)

    TargetBeam=Instance.new("Beam",Root)
    TargetBeam.Attachment0=TargetBeamAttachment
    TargetBeam.Attachment1=TargetBeamTargetAttachment
    TargetBeam.Width0=0.08
    TargetBeam.Width1=0.08
    TargetBeam.FaceCamera=true
    TargetBeam.LightEmission=1
    TargetBeam.Color=ColorSequence.new(Color3.fromRGB(0,170,255))
end

-- ===================================================
-- TÌM QUÁI
-- ===================================================
local function IsBloxFruitsMob(Model)
    if not Model or not Model:IsA("Model") then return false end

    local Humanoid=Model:FindFirstChildOfClass("Humanoid")
    local Root=Model:FindFirstChild("HumanoidRootPart")

    if not Humanoid or not Root then return false end
    if Humanoid.Health<=0 then return false end
    if Model==LocalPlayer.Character then return false end

    return true
end

local function FindNearestMob()
    local Root=GetRoot(LocalPlayer.Character)
    if not Root then return nil end

    local Nearest=nil
    local Distance=SEARCH_MOB_DISTANCE

    for _,Obj in ipairs(Workspace:GetDescendants()) do
        if IsBloxFruitsMob(Obj) then
            local MobRoot=Obj:FindFirstChild("HumanoidRootPart")
            local Dist=(MobRoot.Position-Root.Position).Magnitude

            if Dist<Distance then
                Distance=Dist
                Nearest=Obj
            end
        end
    end

    return Nearest
end

-- ===================================================
-- TÌM RƯƠNG
-- ===================================================
local function FindNearestTaggedChest()
    local Root=GetRoot(LocalPlayer.Character)
    if not Root then return nil end

    local Nearest=nil
    local Distance=math.huge

    for _,Chest in ipairs(CollectionService:GetTagged("Chest")) do
        if Chest and Chest.Parent and not IgnoredChests[Chest] then
            local Success,Pivot=pcall(function()
                return Chest:GetPivot()
            end)

            if Success then
                local Dist=(Pivot.Position-Root.Position).Magnitude

                if Dist<Distance then
                    Distance=Dist
                    Nearest=Chest
                end
            end
        end
    end

    return Nearest
end

-- ===================================================
-- TÌM TRÁI
-- ===================================================
local function FindNearestFruit()
    local Root=GetRoot(LocalPlayer.Character)
    if not Root then return nil end

    local Nearest=nil
    local Distance=math.huge

    for _,Obj in ipairs(Workspace:GetDescendants()) do
        if Obj:IsA("Tool") and Obj:FindFirstChild("Handle") then
            local Handle=Obj.Handle

            if not Obj:IsDescendantOf(LocalPlayer.Backpack) then
                local Dist=(Handle.Position-Root.Position).Magnitude

                if Dist<Distance then
                    Distance=Dist
                    Nearest=Handle
                end
            end
        end
    end

    return Nearest
end

-- ===================================================
-- LẤY BELI
-- ===================================================
local function GetCurrentBeli()
    local data=LocalPlayer:FindFirstChild("Data")

    if data and data:FindFirstChild("Beli") then
        return data.Beli.Value
    end

    local stats=LocalPlayer:FindFirstChild("leaderstats")

    if stats and stats:FindFirstChild("Beli") then
        return stats.Beli.Value
    end

    if stats and stats:FindFirstChild("Money") then
        return stats.Money.Value
    end

    return 0
end

local LastBeli=GetCurrentBeli()

task.spawn(function()
    while task.wait(0.1) do
        local CurrentMoney=GetCurrentBeli()

        if CurrentMoney>LastBeli then
            LastBeli=CurrentMoney

            if ChestEnabled and TargetChest then
                IgnoredChests[TargetChest]=true
                TargetChest=nil
                RemoveTargetBeam()
            end
        else
            LastBeli=CurrentMoney
        end
    end
end)

-- ===================================================
-- 5. BAY TỚI MỤC TIÊU
-- ===================================================
RunService.Heartbeat:Connect(function()
    local Character=LocalPlayer.Character
    local Root=GetRoot(Character)

    if not Root then
        DisableAntiGravity()
        DisableNoclip()
        RemoveTargetBeam()
        return
    end

    local Target=nil
    local TargetType=nil

    if FruitEnabled then
        TargetFruit=FindNearestFruit()
        Target=TargetFruit
        TargetType="Fruit"
    elseif MobEnabled then
        TargetMob=FindNearestMob()
        Target=TargetMob
        TargetType="Mob"
    elseif ChestEnabled then
        TargetChest=FindNearestTaggedChest()
        Target=TargetChest
        TargetType="Chest"
    end

    if not Target then
        DisableAntiGravity()
        DisableNoclip()
        RemoveTargetBeam()
        return
    end

    EnableAntiGravity()
    EnableNoclip()

    local TargetCFrame

    if TargetType=="Fruit" then
        TargetCFrame=Target.CFrame*CFrame.new(0,_G.DOCAO_FRUIT,0)

        if (Root.Position-Target.Position).Magnitude<=4 then
            firetouchinterest(Root,Target,0)
            firetouchinterest(Root,Target,1)
        end

    elseif TargetType=="Mob" then
        local MobRoot=Target:FindFirstChild("HumanoidRootPart")

        if MobRoot then
            TargetCFrame=MobRoot.CFrame*CFrame.new(_G.DOXATP,_G.DOCAO_MOB,0)
        end

    elseif TargetType=="Chest" then
        local Pivot=Target:GetPivot()
        TargetCFrame=Pivot*CFrame.new(0,_G.DOCAO_CHEST,0)

        if (Root.Position-Pivot.Position).Magnitude<=4 then
            local ChestPart=Target.PrimaryPart or Target:FindFirstChildWhichIsA("BasePart")

            if ChestPart then
                firetouchinterest(Root,ChestPart,0)
                firetouchinterest(Root,ChestPart,1)
            end

            if tick()-TouchTimer>0.4 then
                TouchTimer=tick()
            end
        end
    end

    if not TargetCFrame then return end

    UpdateTargetBeam(Target)

    local Distance=(Root.Position-TargetCFrame.Position).Magnitude
    local Speed=Distance<=_G.BOOST_DISTANCE and _G.BOOST_SPEED or _G.SPEED

    Root.CFrame=Root.CFrame:Lerp(
        TargetCFrame,
        math.clamp(Speed/1000,0,1)
    )
end)

-- ===================================================
-- 6. XÁC ĐỊNH SEA
-- ===================================================
local function GetCurrentSea()
    local PlayerGui=LocalPlayer:FindFirstChild("PlayerGui")

    if PlayerGui then
        for _,Obj in ipairs(PlayerGui:GetDescendants()) do
            if Obj:IsA("TextLabel") then
                local Text=Obj.Text

                if Text:find("Sea 1") or Text:find("Sea1") or Text:find("v3") and Text:find("1") then
                    return 1
                elseif Text:find("Sea 2") or Text:find("Sea2") or Text:find("v3") and Text:find("2") then
                    return 2
                elseif Text:find("Sea 3") or Text:find("Sea3") or Text:find("v3") and Text:find("3") then
                    return 3
                end
            end
        end
    end

    local PlaceId=game.PlaceId

    if PlaceId==85211729168715 then
        return 1
    elseif PlaceId==79091703265657 then
        return 2
    elseif PlaceId==7449423635 then
        return 3
    end

    return 3
end

local CurrentSeaNum=GetCurrentSea()

-- ===================================================
-- 7. DỮ LIỆU ĐẢO
-- ===================================================
local SeaIslandsData={
    [1]={
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

    [2]={
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

    [3]={
        {"Đền Thời Gian","TempleOfTime"},
        {"Pháo Đài Trên Biển","SeaCastle"},
        {"Pháo Đài Trên Biển (Cổng)","SeaCastleEntrance"},
        {"Lâu Đài Ma","HauntedCastle"},
        {"Đảo Tiki","Tiki"},
        {"Đảo Loaf","Loaf"},
        {"Đảo Chocolate","Chocolate"},
        {"Đảo Kem","IceCream"},
        {"Cây Khổng Lồ","GreatTree"},
        {"Hydra (Cổng)","HydraEntrance"},
        {"Hydra 1","Hydra1"},
        {"Hydra 2","Hydra2"},
        {"Hydra 3","Hydra3"},
        {"Big Mansion","BigMansion"},
        {"Mansion (Cổng)","MansionEntrance"},
        {"Thị Trấn Dứa","PineappleTown"},
        {"Lâu Đài Biển","Default"}
    }
}

local CurrentList=SeaIslandsData[CurrentSeaNum] or SeaIslandsData[3]

-- ===================================================
-- 8. TẠO GUI SEA
-- ===================================================
local SeaGui=Instance.new("ScreenGui")
SeaGui.Name="SeaMenu_Gui"
SeaGui.ResetOnSpawn=false
SeaGui.Parent=CoreGui

local MainMenu=Instance.new("Frame",SeaGui)
MainMenu.Size=UDim2.new(0,230,0,290)
MainMenu.Position=UDim2.new(0.5,-115,0.5,-145)
MainMenu.BackgroundColor3=Color3.fromRGB(20,20,20)
MainMenu.Active=true
MainMenu.Draggable=true

Instance.new("UICorner",MainMenu).CornerRadius=UDim.new(0,8)

local MainStroke=Instance.new("UIStroke",MainMenu)
MainStroke.Color=Color3.fromRGB(0,170,255)
MainStroke.Thickness=1.5

local Title=Instance.new("TextLabel",MainMenu)
Title.Size=UDim2.new(1,-45,0,38)
Title.Position=UDim2.new(0,8,0,0)
Title.BackgroundTransparency=1
Title.Text="BYPASS TP SEA "..tostring(CurrentSeaNum)
Title.TextColor3=Color3.fromRGB(100,200,255)
Title.Font=Enum.Font.Cartoon
Title.TextSize=18
Title.TextXAlignment=Enum.TextXAlignment.Left

-- ===================================================
-- NÚT BẬT/TẮT MENU
-- ===================================================
local ToggleBtn=Instance.new("ImageButton",SeaGui)
ToggleBtn.Size=UDim2.new(0,35,0,35)
ToggleBtn.Position=UDim2.new(0.015,0,0.2,0)
ToggleBtn.BackgroundTransparency=1
ToggleBtn.Image="rbxassetid://137085832615070"
ToggleBtn.Active=true
ToggleBtn.Draggable=true

ToggleBtn.Activated:Connect(function()
    MainMenu.Visible=not MainMenu.Visible
end)

-- ===================================================
-- NÚT SPEED
-- ===================================================
local SettingsButton=Instance.new("ImageButton",MainMenu)
SettingsButton.Size=UDim2.new(0,30,0,30)
SettingsButton.Position=UDim2.new(1,-36,0,4)
SettingsButton.BackgroundTransparency=1
SettingsButton.Image="rbxassetid://3274432757"

-- ===================================================
-- SPEED MENU
-- ===================================================
local SpeedMenu=Instance.new("Frame",SeaGui)
SpeedMenu.Size=UDim2.new(0,230,0,290)
SpeedMenu.Position=UDim2.new(0.5,-115,0.5,-145)
SpeedMenu.BackgroundColor3=Color3.fromRGB(20,20,20)
SpeedMenu.Active=true
SpeedMenu.Draggable=true
SpeedMenu.Visible=false

Instance.new("UICorner",SpeedMenu).CornerRadius=UDim.new(0,8)

local SpeedStroke=Instance.new("UIStroke",SpeedMenu)
SpeedStroke.Color=Color3.fromRGB(0,170,255)
SpeedStroke.Thickness=1.5

local SpeedTitle=Instance.new("TextLabel",SpeedMenu)
SpeedTitle.Size=UDim2.new(1,-40,0,35)
SpeedTitle.Position=UDim2.new(0,8,0,0)
SpeedTitle.BackgroundTransparency=1
SpeedTitle.Text="Speed Controller"
SpeedTitle.TextColor3=Color3.fromRGB(100,200,255)
SpeedTitle.Font=Enum.Font.Cartoon
SpeedTitle.TextSize=18
SpeedTitle.TextXAlignment=Enum.TextXAlignment.Left

local SpeedClose=Instance.new("TextButton",SpeedMenu)
SpeedClose.Size=UDim2.new(0,30,0,30)
SpeedClose.Position=UDim2.new(1,-35,0,3)
SpeedClose.BackgroundTransparency=1
SpeedClose.Text="X"
SpeedClose.TextColor3=Color3.fromRGB(255,80,80)
SpeedClose.Font=Enum.Font.GothamBold
SpeedClose.TextSize=18

SpeedClose.Activated:Connect(function()
    SpeedMenu.Visible=false
end)

-- ===================================================
-- SCROLL SPEED
-- ===================================================
local SpeedScroll=Instance.new("ScrollingFrame",SpeedMenu)
SpeedScroll.Size=UDim2.new(1,-10,1,-45)
SpeedScroll.Position=UDim2.new(0,5,0,42)
SpeedScroll.BackgroundTransparency=1
SpeedScroll.BorderSizePixel=0
SpeedScroll.ScrollBarThickness=3
SpeedScroll.ScrollBarImageColor3=Color3.fromRGB(0,170,255)
SpeedScroll.CanvasSize=UDim2.new(0,0,0,410)
SpeedScroll.ScrollingDirection=Enum.ScrollingDirection.Y
SpeedScroll.Active=true

local SpeedList=Instance.new("UIListLayout",SpeedScroll)
SpeedList.SortOrder=Enum.SortOrder.LayoutOrder
SpeedList.Padding=UDim.new(0,8)

SpeedList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SpeedScroll.CanvasSize=UDim2.new(0,0,0,SpeedList.AbsoluteContentSize.Y+10)
end)

-- ===================================================
-- HÀM TẠO CONTROL
-- ===================================================
local function CreateControl(Name,MinValue,MaxValue,DefaultValue,OnValue,OnToggle)
    local Holder=Instance.new("Frame",SpeedScroll)
    Holder.Size=UDim2.new(1,0,0,82)
    Holder.BackgroundTransparency=1

    local Label=Instance.new("TextLabel",Holder)
    Label.Size=UDim2.new(1,-60,0,25)
    Label.Position=UDim2.new(0,5,0,0)
    Label.BackgroundTransparency=1
    Label.Text=Name
    Label.TextColor3=Color3.fromRGB(255,255,255)
    Label.Font=Enum.Font.Gotham
    Label.TextSize=14
    Label.TextXAlignment=Enum.TextXAlignment.Left

    local Toggle=Instance.new("TextButton",Holder)
    Toggle.Size=UDim2.new(0,25,0,25)
    Toggle.Position=UDim2.new(1,-30,0,0)
    Toggle.BackgroundColor3=Color3.fromRGB(45,45,45)
    Toggle.Text=""
    Toggle.AutoButtonColor=false

    Instance.new("UICorner",Toggle).CornerRadius=UDim.new(0,5)

    local ToggleStroke=Instance.new("UIStroke",Toggle)
    ToggleStroke.Color=Color3.fromRGB(100,100,100)

    local Enabled=false

    local function UpdateToggle()
        if Enabled then
            Toggle.BackgroundColor3=Color3.fromRGB(0,170,255)
            ToggleStroke.Color=Color3.fromRGB(0,200,255)
        else
            Toggle.BackgroundColor3=Color3.fromRGB(45,45,45)
            ToggleStroke.Color=Color3.fromRGB(100,100,100)
        end
    end

    Toggle.Activated:Connect(function()
        Enabled=not Enabled
        UpdateToggle()
        OnToggle(Enabled)
    end)

    local Input=Instance.new("TextBox",Holder)
    Input.Size=UDim2.new(0,55,0,25)
    Input.Position=UDim2.new(1,-90,0,30)
    Input.BackgroundColor3=Color3.fromRGB(35,35,35)
    Input.TextColor3=Color3.fromRGB(255,255,255)
    Input.PlaceholderColor3=Color3.fromRGB(150,150,150)
    Input.Text=tostring(DefaultValue)
    Input.ClearTextOnFocus=false
    Input.Font=Enum.Font.Gotham
    Input.TextSize=13

    Instance.new("UICorner",Input).CornerRadius=UDim.new(0,5)

    local Slider=Instance.new("Frame",Holder)
    Slider.Size=UDim2.new(1,-100,0,5)
    Slider.Position=UDim2.new(0,5,0,40)
    Slider.BackgroundColor3=Color3.fromRGB(60,60,60)

    Instance.new("UICorner",Slider).CornerRadius=UDim.new(1,0)

    local Fill=Instance.new("Frame",Slider)
    Fill.BackgroundColor3=Color3.fromRGB(0,170,255)
    Fill.Size=UDim2.new((DefaultValue-MinValue)/(MaxValue-MinValue),0,1,0)

    Instance.new("UICorner",Fill).CornerRadius=UDim.new(1,0)

    local Knob=Instance.new("Frame",Slider)
    Knob.Size=UDim2.new(0,12,0,12)
    Knob.AnchorPoint=Vector2.new(0.5,0.5)
    Knob.Position=UDim2.new((DefaultValue-MinValue)/(MaxValue-MinValue),0,0.5,0)
    Knob.BackgroundColor3=Color3.fromRGB(255,255,255)

    Instance.new("UICorner",Knob).CornerRadius=UDim.new(1,0)

    local CurrentValue=DefaultValue

    local function SetValue(Value)
        Value=math.clamp(tonumber(Value) or CurrentValue,MinValue,MaxValue)
        Value=math.floor(Value)

        CurrentValue=Value
        Input.Text=tostring(Value)

        local Alpha=(Value-MinValue)/(MaxValue-MinValue)
        Fill.Size=UDim2.new(Alpha,0,1,0)
        Knob.Position=UDim2.new(Alpha,0,0.5,0)

        OnValue(Value)
    end

    Input.FocusLost:Connect(function()
        SetValue(Input.Text)
    end)

    Slider.InputBegan:Connect(function(InputObject)
        if InputObject.UserInputType==Enum.UserInputType.MouseButton1 or InputObject.UserInputType==Enum.UserInputType.Touch then
            local X=InputObject.Position.X
            local Alpha=math.clamp((X-Slider.AbsolutePosition.X)/Slider.AbsoluteSize.X,0,1)
            SetValue(MinValue+(MaxValue-MinValue)*Alpha)
        end
    end)

    SetValue(DefaultValue)
    UpdateToggle()

    return Holder
end

-- ===================================================
-- SPEED / WALK / JUMP / BOAT
-- ===================================================
CreateControl("Tốc độ bay",150,300,220,function(Value)
    _G.SPEED=Value
end,function(Value)
end)

CreateControl("Walk Speed",0,250,16,function(Value)
    _G.WalkSpeedValue=Value
end,function(Value)
    _G.WalkSpeedEnabled=Value
end)

CreateControl("Jump Power",0,500,50,function(Value)
    _G.JumpPowerValue=Value
end,function(Value)
    _G.JumpPowerEnabled=Value
end)

CreateControl("Boat Speed",150,500,300,function(Value)
    _G.BoatSpeed=Value
end,function(Value)
    _G.BoatSpeedEnabled=Value
end)

_G.WalkSpeedValue=16
_G.WalkSpeedEnabled=false
_G.JumpPowerValue=50
_G.JumpPowerEnabled=false
_G.BoatSpeed=300
_G.BoatSpeedEnabled=false

-- ===================================================
-- WALK SPEED / JUMP POWER
-- ===================================================
task.spawn(function()
    while task.wait(0.1) do
        local Character=LocalPlayer.Character
        local Humanoid=Character and Character:FindFirstChildOfClass("Humanoid")

        if Humanoid then
            if _G.WalkSpeedEnabled then
                Humanoid.WalkSpeed=_G.WalkSpeedValue
            end

            if _G.JumpPowerEnabled then
                Humanoid.UseJumpPower=true
                Humanoid.JumpPower=_G.JumpPowerValue
            end
        end
    end
end)

-- ===================================================
-- BOAT SPEED
-- ===================================================
task.spawn(function()
    while task.wait(0.01) do
        if _G.BoatSpeedEnabled then
            local Boats=Workspace:FindFirstChild("Boats")

            if Boats then
                for _,Obj in ipairs(Boats:GetDescendants()) do
                    if Obj:IsA("VehicleSeat") then
                        Obj.MaxSpeed=_G.BoatSpeed
                        Obj.Torque=0.15
                        Obj.TurnSpeed=3
                        Obj.HeadsUpDisplay=true
                    end
                end
            end
        end
    end
end)

-- ===================================================
-- NÚT MỞ SPEED MENU
-- ===================================================
SettingsButton.Activated:Connect(function()
    SpeedMenu.Visible=not SpeedMenu.Visible
end)

-- ===================================================
-- HÀM TELEPORT ĐẢO
-- ===================================================
local function SpawnToIsland(spawnArg)
    local Character=LocalPlayer.Character
    local Root=GetRoot(Character)
    local Humanoid=Character and Character:FindFirstChildOfClass("Humanoid")

    if not Root or not Humanoid then return end

    local CommF=ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

    if spawnArg=="TempleOfTime" then
        if TempleFlyConnection then
            TempleFlyConnection:Disconnect()
            TempleFlyConnection=nil
        end

        local Entrance=Vector3.new(28310.0234,14895.1123,109.456741)

        pcall(function()
            CommF:InvokeServer("requestEntrance",Entrance)
        end)

        task.wait(0.5)

        local Race=LocalPlayer.Data.Race.Value
        local TargetCFrame

        if Race=="Fishman" then
            TargetCFrame=CFrame.new(28224.056640625,14889.4267578125,-210.5872039794922)
        elseif Race=="Cyborg" then
            TargetCFrame=CFrame.new(28492.4140625,14894.4267578125,-422.1100158691406)
        elseif Race=="Skypiea" then
            TargetCFrame=CFrame.new(28967.408203125,14918.0751953125,234.31198120117188)
        elseif Race=="Ghoul" then
            TargetCFrame=CFrame.new(28672.720703125,14889.1279296875,454.5961608886719)
        elseif Race=="Human" then
            TargetCFrame=CFrame.new(29237.294921875,14889.4267578125,-206.94955444335938)
        else
            TargetCFrame=CFrame.new(29020.66015625,14889.4267578125,-379.2682800292969)
        end

        TempleFlyConnection=RunService.Heartbeat:Connect(function()
            local CurrentCharacter=LocalPlayer.Character
            local CurrentRoot=GetRoot(CurrentCharacter)

            if CurrentRoot then
                CurrentRoot.CFrame=CurrentRoot.CFrame:Lerp(TargetCFrame,0.08)
            end
        end)

        task.delay(3,function()
            if TempleFlyConnection then
                TempleFlyConnection:Disconnect()
                TempleFlyConnection=nil
            end
        end)

        return
    end

    local Entrances={
        CursedShipEntrance=Vector3.new(923.21,126.97,32852.83),
        MansionSea2Entrance=Vector3.new(-325.47,331.92,600.17),
        SwanRoomEntrance=Vector3.new(2284.90,15.53,905.46),
        Sky2Entrance=Vector3.new(-6023.57666015625,5469.7197265625,2203.308349609375),
        UnderwaterEntrance=Vector3.new(61163.85,11.68,1819.78),
        SeaCastleEntrance=Vector3.new(-5089.14,314.58,-3164.46),
        MansionEntrance=Vector3.new(-12549.40,336.98,-7576.59),
        HydraEntrance=Vector3.new(5681.00,1013.11,-307.12)
    }

    if Entrances[spawnArg] then
        pcall(function()
            CommF:InvokeServer("requestEntrance",Entrances[spawnArg])
        end)
        return
    end

    Humanoid.Health=0

    pcall(function()
        CommF:InvokeServer("SetLastSpawnPoint",spawnArg)
    end)
end

-- ===================================================
-- NÚT CHỌN ĐẢO
-- ===================================================
local Scroll=Instance.new("ScrollingFrame",MainMenu)
Scroll.Size=UDim2.new(1,-10,1,-45)
Scroll.Position=UDim2.new(0,5,0,42)
Scroll.BackgroundTransparency=1
Scroll.BorderSizePixel=0
Scroll.ScrollBarThickness=3
Scroll.ScrollBarImageColor3=Color3.fromRGB(0,170,255)
Scroll.ScrollingDirection=Enum.ScrollingDirection.Y
Scroll.Active=true

local List=Instance.new("UIListLayout",Scroll)
List.SortOrder=Enum.SortOrder.LayoutOrder
List.Padding=UDim.new(0,5)

local function CreateIslandButton(Name,SpawnArg)
    local Button=Instance.new("TextButton",Scroll)
    Button.Size=UDim2.new(1,0,0,32)
    Button.BackgroundColor3=Color3.fromRGB(35,35,35)
    Button.Text=Name
    Button.TextColor3=Color3.fromRGB(255,255,255)
    Button.Font=Enum.Font.Gotham
    Button.TextSize=13
    Button.AutoButtonColor=false

    Instance.new("UICorner",Button).CornerRadius=UDim.new(0,5)

    Button.Activated:Connect(function()
        SpawnToIsland(SpawnArg)
    end)
end

for _,Island in ipairs(CurrentList) do
    CreateIslandButton(Island[1],Island[2])
end

List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize=UDim2.new(0,0,0,List.AbsoluteContentSize.Y+10)
end)

-- ===================================================
-- TOGGLE BAY / FARM
-- ===================================================
local function CreateToggle(Name,Callback)
    local Holder=Instance.new("Frame",Scroll)
    Holder.Size=UDim2.new(1,0,0,35)
    Holder.BackgroundTransparency=1

    local Label=Instance.new("TextLabel",Holder)
    Label.Size=UDim2.new(1,-50,1,0)
    Label.Position=UDim2.new(0,5,0,0)
    Label.BackgroundTransparency=1
    Label.Text=Name
    Label.TextColor3=Color3.fromRGB(255,255,255)
    Label.Font=Enum.Font.Gotham
    Label.TextSize=13
    Label.TextXAlignment=Enum.TextXAlignment.Left

    local Button=Instance.new("TextButton",Holder)
    Button.Size=UDim2.new(0,28,0,28)
    Button.Position=UDim2.new(1,-33,0,3)
    Button.BackgroundColor3=Color3.fromRGB(35,35,35)
    Button.Text=""
    Button.AutoButtonColor=false

    Instance.new("UICorner",Button).CornerRadius=UDim.new(0,5)

    local Stroke=Instance.new("UIStroke",Button)
    Stroke.Color=Color3.fromRGB(100,100,100)

    local Enabled=false

    local function Update()
        if Enabled then
            Button.BackgroundColor3=Color3.fromRGB(0,170,255)
            Stroke.Color=Color3.fromRGB(0,200,255)
        else
            Button.BackgroundColor3=Color3.fromRGB(35,35,35)
            Stroke.Color=Color3.fromRGB(100,100,100)
        end
    end

    Button.Activated:Connect(function()
        Enabled=not Enabled
        Update()
        Callback(Enabled)
    end)

    Update()
end

CreateToggle("BAY TỚI TRÁI",function(Value)
    FruitEnabled=Value

    if not Value then
        TargetFruit=nil
        RemoveTargetBeam()
    end
end)

CreateToggle("BAY TỚI QUÁI",function(Value)
    MobEnabled=Value

    if not Value then
        TargetMob=nil
        RemoveTargetBeam()
    end
end)

CreateToggle("FARM RƯƠNG",function(Value)
    ChestEnabled=Value

    if not Value then
        TargetChest=nil
        RemoveTargetBeam()
    end
end)
