
-- ===================================================
-- 1. SERVICE
-- ===================================================
local CoreGui=game:GetService("CoreGui")
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local Workspace=game:GetService("Workspace")
local CollectionService=game:GetService("CollectionService")
local LocalPlayer=Players.LocalPlayer

-- ===================================================
-- 2. CLEAR OLD GUI & LOGIC
-- ===================================================
local function ClearOldGUI()
    local oldNames={"SeaMenu_Gui","AxiomTeleportMobBF","AxiomTeleportChestBF","AxiomTeleportFruitBF"}

    for _,name in ipairs(oldNames) do
        local oldCore=CoreGui:FindFirstChild(name)
        if oldCore then oldCore:Destroy() end
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
            local oldPlayerGui=LocalPlayer.PlayerGui:FindFirstChild(name)
            if oldPlayerGui then oldPlayerGui:Destroy() end
        end
    end
end

ClearOldGUI()

local SeaGui=Instance.new("ScreenGui")
SeaGui.Name="SeaMenu_Gui"
SeaGui.ResetOnSpawn=false
SeaGui.IgnoreGuiInset=true
SeaGui.DisplayOrder=999999
SeaGui.Parent=LocalPlayer:WaitForChild("PlayerGui")

-- ===================================================
-- 3. CẤU HÌNH & HÀM HỖ TRỢ CHUNG
-- ===================================================
_G.SPEED=220
_G.BOOST_SPEED=1000
_G.BOOST_DISTANCE=100
_G.DOCAO_MOB=35
_G.DOCAO_CHEST=0
_G.DOCAO_FRUIT=1
_G.DOXATP=0
_G.BOAT_SPEED=450

local MobEnabled=false
local ChestEnabled=false
local FruitEnabled=false
local BoatEnabled=false

local TargetMob=nil
local TargetChest=nil
local TargetFruit=nil
local TempleFlyConnection=nil

local BodyVelocity=nil
local NoclipConnection=nil
local IgnoredChests=setmetatable({},{__mode="k"})
local TouchTimer=0
local SEARCH_MOB_DISTANCE=5000

local function GetRoot()
    local Character=LocalPlayer.Character
    return Character and Character:FindFirstChild("HumanoidRootPart")
end

local function EnableAntiGravity(root)
    if not BodyVelocity or BodyVelocity.Parent~=root then
        if BodyVelocity then BodyVelocity:Destroy() end
        BodyVelocity=Instance.new("BodyVelocity")
        BodyVelocity.Name="AxiomHover"
        BodyVelocity.Velocity=Vector3.new(0,0,0)
        BodyVelocity.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
        BodyVelocity.P=12500
        BodyVelocity.Parent=root
    end

    local Character=LocalPlayer.Character
    local Humanoid=Character and Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Freefall) end
end

local function DisableAntiGravity()
    if BodyVelocity then BodyVelocity:Destroy(); BodyVelocity=nil end
end

local function EnableNoclip()
    if not NoclipConnection then
        NoclipConnection=RunService.Stepped:Connect(function()
            if (MobEnabled or ChestEnabled or FruitEnabled) and LocalPlayer.Character then
                for _,part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide=false end
                end
            end
        end)
    end
end

local function DisableNoclip()
    if NoclipConnection and not MobEnabled and not ChestEnabled and not FruitEnabled then
        NoclipConnection:Disconnect()
        NoclipConnection=nil
    end
end

-- ===================================================
-- 🚤 LOOP TỐC ĐỘ THUYỀN
-- ===================================================
task.spawn(function()
    while task.wait(0.01) do
        if BoatEnabled then
            pcall(function()
                local boatsFolder=Workspace:FindFirstChild("Boats")
                if boatsFolder then
                    for _,v in pairs(boatsFolder:GetDescendants()) do
                        local VehicleSeat=v:FindFirstChild("VehicleSeat")
                        if VehicleSeat then
                            VehicleSeat.MaxSpeed=_G.BOAT_SPEED
                            VehicleSeat.Torque=0.15
                            VehicleSeat.TurnSpeed=3
                            VehicleSeat.HeadsUpDisplay=true
                        end
                    end
                end
            end)
        end
    end
end)

-- ===================================================
-- 4. LOGIC TÌM KIẾM MỤC TIÊU
-- ===================================================
local TargetBeam=nil
local TargetBeamAttachment=nil
local TargetBeamTargetAttachment=nil

local function RemoveTargetBeam()
    if TargetBeam then TargetBeam:Destroy(); TargetBeam=nil end
    if TargetBeamAttachment then TargetBeamAttachment:Destroy(); TargetBeamAttachment=nil end
    if TargetBeamTargetAttachment then TargetBeamTargetAttachment:Destroy(); TargetBeamTargetAttachment=nil end
end

local function UpdateTargetBeam(Target)
    RemoveTargetBeam()

    local Character=LocalPlayer.Character
    local Root=Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root or not Target or not Target.Parent then return end

    local TargetPart
    if Target:IsA("BasePart") then
        TargetPart=Target
    elseif Target:IsA("Model") then
        TargetPart=Target:FindFirstChild("HumanoidRootPart") or Target.PrimaryPart or Target:FindFirstChildOfClass("BasePart")
    end
    if not TargetPart then return end

    TargetBeamAttachment=Instance.new("Attachment")
    TargetBeamAttachment.Name="AxiomTargetAttachment"
    TargetBeamAttachment.Parent=Root

    TargetBeamTargetAttachment=Instance.new("Attachment")
    TargetBeamTargetAttachment.Name="AxiomTargetAttachment"
    TargetBeamTargetAttachment.Parent=TargetPart

    TargetBeam=Instance.new("Beam")
    TargetBeam.Name="AxiomTargetBeam"
    TargetBeam.Attachment0=TargetBeamAttachment
    TargetBeam.Attachment1=TargetBeamTargetAttachment
    TargetBeam.FaceCamera=true
    TargetBeam.Width0=0.12
    TargetBeam.Width1=0.12
    TargetBeam.Color=ColorSequence.new(Color3.fromRGB(0,170,255))
    TargetBeam.Transparency=NumberSequence.new(0.15)
    TargetBeam.LightEmission=1
    TargetBeam.LightInfluence=0
    TargetBeam.Parent=Root
end

local function IsBloxFruitsMob(Model)
    if not Model or not Model:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(Model) then return false end

    local Humanoid=Model:FindFirstChildOfClass("Humanoid")
    local Root=Model:FindFirstChild("HumanoidRootPart") or Model.PrimaryPart
    if not Humanoid or not Root or Humanoid.Health<=0 then return false end
    if Model.Parent and Model.Parent.Name=="Enemies" then return true end

    local name=Model.Name:lower()
    if name:find("quest") or name:find("giver") or name:find("merchant") or name:find("dealer") or name:find("title") or name:find("blox fruit") then return false end
    if Model:FindFirstChild("Dialogue") or Model:FindFirstChild("Quest") or Model:FindFirstChildOfClass("Dialog") then return false end

    return true
end

-- ===================================================
-- TÌM QUÁI GẦN NHẤT
-- ===================================================
local function FindNearestMob()
    local MyRoot=GetRoot()
    if not MyRoot then return nil end

    local Nearest=nil
    local NearestDistance=SEARCH_MOB_DISTANCE
    local EnemiesFolder=Workspace:FindFirstChild("Enemies")
    local MobList=EnemiesFolder and EnemiesFolder:GetChildren() or Workspace:GetChildren()

    for _,Object in ipairs(MobList) do
        if IsBloxFruitsMob(Object) then
            local Root=Object:FindFirstChild("HumanoidRootPart") or Object.PrimaryPart
            if Root then
                local Distance=(Root.Position-MyRoot.Position).Magnitude
                if Distance<NearestDistance then Nearest=Object; NearestDistance=Distance end
            end
        end
    end

    if not Nearest and EnemiesFolder then
        for _,Object in ipairs(Workspace:GetChildren()) do
            if Object~=EnemiesFolder and IsBloxFruitsMob(Object) then
                local Root=Object:FindFirstChild("HumanoidRootPart") or Object.PrimaryPart
                if Root then
                    local Distance=(Root.Position-MyRoot.Position).Magnitude
                    if Distance<NearestDistance then Nearest=Object; NearestDistance=Distance end
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
    local MyRoot=GetRoot()
    if not MyRoot then return nil end

    local Position=MyRoot.Position
    local Distance,Nearest=math.huge,nil
    local Chests=CollectionService:GetTagged("_ChestTagged")

    for i=1,#Chests do
        local Chest=Chests[i]
        if Chest and Chest.Parent and not IgnoredChests[Chest] and not Chest:GetAttribute("IsDisabled") then
            local Magnitude=(Chest:GetPivot().Position-Position).Magnitude
            if Magnitude<Distance then Distance=Magnitude; Nearest=Chest end
        end
    end

    if not Nearest then
        for _,object in ipairs(Workspace:GetChildren()) do
            if object.Name:find("Chest") and not IgnoredChests[object] then
                local touchPart=object:IsA("BasePart") and object or object.PrimaryPart or object:FindFirstChildOfClass("BasePart")
                if touchPart then
                    local Magnitude=(touchPart.Position-Position).Magnitude
                    if Magnitude<Distance then Distance=Magnitude; Nearest=object end
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
    local MyRoot=GetRoot()
    if not MyRoot then return nil end

    local Nearest,NearestDistance=nil,150000

    for _,v in ipairs(Workspace:GetChildren()) do
        if v:IsA("Tool") or (v:IsA("Model") and v:FindFirstChild("Handle")) then
            local name=v.Name:lower()
            if name:find("fruit") or name:find("trái") or name:find("trai") then
                local Handle=v:FindFirstChild("Handle") or v.PrimaryPart or v:FindFirstChildOfClass("BasePart")
                if Handle then
                    local Distance=(Handle.Position-MyRoot.Position).Magnitude
                    if Distance<NearestDistance then NearestDistance=Distance; Nearest=Handle end
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
    local data=LocalPlayer:FindFirstChild("Data")
    if data and data:FindFirstChild("Beli") then return data.Beli.Value end

    local stats=LocalPlayer:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Beli") then return stats.Beli.Value end
    if stats and stats:FindFirstChild("Money") then return stats.Money.Value end

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
-- 5. LOOP ĐIỀU KHIỂN BAY TỚI MỤC TIÊU
-- ===================================================
RunService.Heartbeat:Connect(function(DeltaTime)
    if not MobEnabled and not ChestEnabled and not FruitEnabled then
        DisableAntiGravity(); DisableNoclip(); RemoveTargetBeam(); return
    end

    local MyRoot=GetRoot()
    if not MyRoot then
        DisableAntiGravity(); DisableNoclip(); RemoveTargetBeam(); return
    end

    if FruitEnabled then
        if not TargetFruit or not TargetFruit.Parent then TargetFruit=FindNearestFruit() end
        if not TargetFruit then DisableAntiGravity(); DisableNoclip(); RemoveTargetBeam(); return end

        EnableAntiGravity(MyRoot)
        EnableNoclip()
        UpdateTargetBeam(TargetFruit)

        local TargetCFrame=TargetFruit.CFrame*CFrame.new(0,_G.DOCAO_FRUIT,0)
        local Distance=(TargetCFrame.Position-MyRoot.Position).Magnitude

        if Distance<=4 and firetouchinterest then
            firetouchinterest(MyRoot,TargetFruit,0); firetouchinterest(MyRoot,TargetFruit,1)
        end

        local ActiveSpeed=Distance<=_G.BOOST_DISTANCE and _G.BOOST_SPEED or _G.SPEED
        local Alpha=math.clamp((ActiveSpeed*DeltaTime)/math.max(Distance,0.001),0,1)
        MyRoot.CFrame=MyRoot.CFrame:Lerp(TargetCFrame,Alpha)

    elseif MobEnabled then
        if not TargetMob or not TargetMob.Parent or not IsBloxFruitsMob(TargetMob) then TargetMob=FindNearestMob() end
        if not TargetMob then DisableAntiGravity(); DisableNoclip(); RemoveTargetBeam(); return end

        local MobRoot=TargetMob:FindFirstChild("HumanoidRootPart") or TargetMob.PrimaryPart
        if not MobRoot then DisableAntiGravity(); DisableNoclip(); RemoveTargetBeam(); return end

        EnableAntiGravity(MyRoot)
        EnableNoclip()
        UpdateTargetBeam(TargetMob)

        local TargetCFrame=MobRoot.CFrame*CFrame.new(_G.DOXATP,_G.DOCAO_MOB,0)
        local Distance=(TargetCFrame.Position-MyRoot.Position).Magnitude

        if Distance>0.05 then
            local ActiveSpeed=Distance<=_G.BOOST_DISTANCE and _G.BOOST_SPEED or _G.SPEED
            local Alpha=math.clamp((ActiveSpeed*DeltaTime)/math.max(Distance,0.001),0,1)
            MyRoot.CFrame=MyRoot.CFrame:Lerp(TargetCFrame,Alpha)
        end

    elseif ChestEnabled then
        if not TargetChest or not TargetChest.Parent or IgnoredChests[TargetChest] or TargetChest:GetAttribute("IsDisabled") then
            TargetChest=FindNearestTaggedChest()
            TouchTimer=0
        end

        if not TargetChest then DisableAntiGravity(); DisableNoclip(); RemoveTargetBeam(); return end

        EnableAntiGravity(MyRoot)
        EnableNoclip()
        UpdateTargetBeam(TargetChest)

        local TargetCFrame=TargetChest:GetPivot()*CFrame.new(0,_G.DOCAO_CHEST,0)
        local Distance=(TargetCFrame.Position-MyRoot.Position).Magnitude
        local ActiveSpeed=Distance<=_G.BOOST_DISTANCE and _G.BOOST_SPEED or _G.SPEED

        if Distance<=4 then
            TouchTimer=TouchTimer+DeltaTime

            if firetouchinterest then
                local TouchPart=TargetChest:IsA("BasePart") and TargetChest or TargetChest.PrimaryPart or TargetChest:FindFirstChildOfClass("BasePart")
                if TouchPart then
                    firetouchinterest(MyRoot,TouchPart,0); firetouchinterest(MyRoot,TouchPart,1)
                end
            end

            if TouchTimer>=0.4 then
                IgnoredChests[TargetChest]=true
                TargetChest=nil
                TouchTimer=0
                RemoveTargetBeam()
                return
            end
        else
            TouchTimer=0
        end

        local Alpha=math.clamp((ActiveSpeed*DeltaTime)/math.max(Distance,0.001),0,1)
        MyRoot.CFrame=MyRoot.CFrame:Lerp(TargetCFrame,Alpha)
    end
end)

-- ===================================================
-- 6. GIAO DIỆN
-- ===================================================
local ToggleBtn=Instance.new("ImageButton",SeaGui)
ToggleBtn.Size=UDim2.new(0,40,0,40)
ToggleBtn.Position=UDim2.new(0.015,0,0.2,0)
ToggleBtn.BackgroundColor3=Color3.fromRGB(15,25,35)
ToggleBtn.BackgroundTransparency=0.2
ToggleBtn.Draggable=true
ToggleBtn.ClipsDescendants=true
ToggleBtn.Image="rbxassetid://76668922802166"

Instance.new("UICorner",ToggleBtn).CornerRadius=UDim.new(1,0)

local toggleStroke=Instance.new("UIStroke",ToggleBtn)
toggleStroke.Thickness=1.5
toggleStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
toggleStroke.LineJoinMode=Enum.LineJoinMode.Round
toggleStroke.Color=Color3.fromRGB(255,255,255)

local toggleGradient=Instance.new("UIGradient",toggleStroke)
toggleGradient.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0.00,Color3.fromRGB(0,170,255)),
    ColorSequenceKeypoint.new(0.25,Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(0.50,Color3.fromRGB(0,30,90)),
    ColorSequenceKeypoint.new(0.75,Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1.00,Color3.fromRGB(0,170,255))
})
toggleGradient.Parent=toggleStroke

local MainMenu=Instance.new("Frame",SeaGui)
local MainMenuOpenSize=UDim2.new(0,230,0,290)
local MainMenuClosedSize=UDim2.new(0,180,0,220)

MainMenu.Size=MainMenuClosedSize
MainMenu.AnchorPoint=Vector2.new(0.5,0.5)
MainMenu.Position=UDim2.new(0.5,0,0.5,0)
MainMenu.BackgroundColor3=Color3.fromRGB(15,20,28)
MainMenu.BackgroundTransparency=0.15
MainMenu.Visible=false
MainMenu.Draggable=true
MainMenu.ClipsDescendants=true

Instance.new("UICorner",MainMenu).CornerRadius=UDim.new(0,10)


-- ===================================================
-- 7. HIỆU ỨNG TUYẾT RƠI
-- ===================================================
local SnowLayer=Instance.new("Frame",MainMenu)
SnowLayer.Name="SnowLayer"
SnowLayer.Size=UDim2.fromScale(1,1)
SnowLayer.BackgroundTransparency=1
SnowLayer.ClipsDescendants=true
SnowLayer.ZIndex=0

local Snowflakes={}

for i=1,25 do
    local Snow=Instance.new("Frame",SnowLayer)
    local Size=math.random(1,3)
    Snow.Size=UDim2.new(0,Size,0,Size)
    Snow.Position=UDim2.new(math.random(),0,math.random(),0)
    Snow.BackgroundColor3=Color3.fromRGB(255,255,255)
    Snow.BackgroundTransparency=math.random(20,60)/100
    Snow.BorderSizePixel=0
    Snow.ZIndex=0
    Instance.new("UICorner",Snow).CornerRadius=UDim.new(1,0)
    table.insert(Snowflakes,{Object=Snow,Speed=math.random(15,35)/100,Drift=math.random(-8,8)/100})
end

local menuStroke=Instance.new("UIStroke",MainMenu)
menuStroke.Thickness=1.5
menuStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
menuStroke.LineJoinMode=Enum.LineJoinMode.Round
menuStroke.Color=Color3.fromRGB(255,255,255)

local menuGradient=Instance.new("UIGradient",menuStroke)
menuGradient.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0.00,Color3.fromRGB(0,170,255)),
    ColorSequenceKeypoint.new(0.25,Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(0.50,Color3.fromRGB(0,30,90)),
    ColorSequenceKeypoint.new(0.75,Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1.00,Color3.fromRGB(0,170,255))
})
menuGradient.Parent=menuStroke

local Title=Instance.new("TextLabel",MainMenu)
Title.Size=UDim2.new(1,-55,0,35)
Title.Position=UDim2.new(0,0,0,0)
Title.Text=""
Title.RichText=true
Title.Font=Enum.Font.Cartoon
Title.TextSize=15
Title.BackgroundTransparency=1
Title.TextXAlignment=Enum.TextXAlignment.Center
Title.TextYAlignment=Enum.TextYAlignment.Center

local Scroll=Instance.new("ScrollingFrame",MainMenu)
Scroll.Size=UDim2.new(1,0,1,-40)
Scroll.Position=UDim2.new(0,0,0,38)
Scroll.BackgroundTransparency=1
Scroll.ScrollBarThickness=3
Scroll.CanvasSize=UDim2.new(0,0,0,0)
Scroll.AutomaticCanvasSize=Enum.AutomaticSize.None

local UIList=Instance.new("UIListLayout",Scroll)
UIList.SortOrder=Enum.SortOrder.LayoutOrder
UIList.Padding=UDim.new(0,6)
UIList.HorizontalAlignment=Enum.HorizontalAlignment.Center

UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize=UDim2.new(0,0,0,UIList.AbsoluteContentSize.Y+10)
end)

-- ===================================================
-- TIÊU ĐỀ
-- ===================================================
local titleText="NHAT HIHI"
local titleHue=0

-- ===================================================
-- 🎞️ TWEEN MENU
-- ===================================================
local MenuTweenInfo=TweenInfo.new(0.28,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
local MenuClosing=false

local function OpenMainMenu()
    if MenuClosing then return end
    MainMenu.Visible=true
    MainMenu.Size=MainMenuClosedSize
    TweenService:Create(MainMenu,MenuTweenInfo,{Size=MainMenuOpenSize}):Play()
end

local function CloseMainMenu()
    if not MainMenu.Visible or MenuClosing then return end
    MenuClosing=true
    local Tween=TweenService:Create(MainMenu,TweenInfo.new(0.22,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=MainMenuClosedSize})
    Tween:Play()
    Tween.Completed:Connect(function()
        MainMenu.Visible=false
        MenuClosing=false
    end)
end

local function ToggleMainMenu()
    if MainMenu.Visible then CloseMainMenu() else OpenMainMenu() end
end

RunService.RenderStepped:Connect(function(delta)
    local ToggleSpeed=MainMenu.Visible and 150 or 100
    toggleGradient.Rotation=(toggleGradient.Rotation+delta*ToggleSpeed)%360
    menuGradient.Rotation=(menuGradient.Rotation+delta*90)%360

    for _,flake in ipairs(Snowflakes) do
        local obj=flake.Object
        if obj.Parent then
            local x=obj.Position.X.Scale+flake.Drift*delta
            local y=obj.Position.Y.Scale+flake.Speed*delta
            if y>1.05 then y=-0.05; x=math.random() end
            if x>1.05 then x=-0.05 elseif x<-0.05 then x=1.05 end
            obj.Position=UDim2.new(x,0,y,0)
        end
    end

    titleHue=(titleHue+delta*0.35)%1
    local Text=""

    for i=1,#titleText do
        local char=titleText:sub(i,i)
        if char==" " then
            Text=Text.." "
        else
            local hue=(titleHue-(i-1)/#titleText)%1
            local color=Color3.fromHSV(hue,1,1)
            local r=math.floor(color.R*255)
            local g=math.floor(color.G*255)
            local b=math.floor(color.B*255)
            Text=Text..string.format('<font color="rgb(%d,%d,%d)">%s</font>',r,g,b,char)
        end
    end

    Title.Text=Text
end)

ToggleBtn.MouseButton1Click:Connect(ToggleMainMenu)

-- ===================================================
-- 8. NÚT CÀI ĐẶT
-- ===================================================
local SettingsBtn=Instance.new("TextButton",MainMenu)
SettingsBtn.Name="SettingsButton"
SettingsBtn.Size=UDim2.new(0,30,0,30)
SettingsBtn.Position=UDim2.new(1,-35,0,2)
SettingsBtn.BackgroundColor3=Color3.fromRGB(25,35,50)
SettingsBtn.BackgroundTransparency=0.15
SettingsBtn.AutoButtonColor=false
SettingsBtn.Text="⚙️"
SettingsBtn.Font=Enum.Font.Cartoon
SettingsBtn.TextSize=18
SettingsBtn.TextColor3=Color3.fromRGB(100,200,255)
Instance.new("UICorner",SettingsBtn).CornerRadius=UDim.new(1,0)

local SettingsStroke=Instance.new("UIStroke",SettingsBtn)
SettingsStroke.Thickness=1
SettingsStroke.Color=Color3.fromRGB(0,120,200)

local SettingsGui=Instance.new("Frame",SeaGui)
local SettingsOpenSize=UDim2.new(0,180,0,195)
local SettingsClosedSize=UDim2.new(0,140,0,150)

SettingsGui.Name="SettingsGui"
SettingsGui.Size=SettingsClosedSize
SettingsGui.AnchorPoint=Vector2.new(0.5,0.5)
SettingsGui.Position=UDim2.new(0.5,0,0.5,0)
SettingsGui.BackgroundColor3=Color3.fromRGB(15,20,28)
SettingsGui.BackgroundTransparency=0.08
SettingsGui.Visible=false
SettingsGui.Active=true
SettingsGui.Draggable=true
SettingsGui.ZIndex=20
SettingsGui.ClipsDescendants=true

Instance.new("UICorner",SettingsGui).CornerRadius=UDim.new(0,8)

local SettingsGuiStroke=Instance.new("UIStroke",SettingsGui)
SettingsGuiStroke.Thickness=1.3
SettingsGuiStroke.Color=Color3.fromRGB(0,170,255)

local SettingsTitle=Instance.new("TextLabel",SettingsGui)
SettingsTitle.Size=UDim2.new(1,-30,0,25)
SettingsTitle.Position=UDim2.new(0,5,0,2)
SettingsTitle.BackgroundTransparency=1
SettingsTitle.Text="CÀI ĐẶT"
SettingsTitle.Font=Enum.Font.Cartoon
SettingsTitle.TextSize=14
SettingsTitle.TextColor3=Color3.fromRGB(100,200,255)
SettingsTitle.TextXAlignment=Enum.TextXAlignment.Left
SettingsTitle.ZIndex=21

local SettingsClose=Instance.new("TextButton",SettingsGui)
SettingsClose.Size=UDim2.new(0,22,0,22)
SettingsClose.Position=UDim2.new(1,-25,0,3)
SettingsClose.BackgroundTransparency=1
SettingsClose.Text="×"
SettingsClose.Font=Enum.Font.Cartoon
SettingsClose.TextSize=20
SettingsClose.TextColor3=Color3.fromRGB(255,100,100)
SettingsClose.AutoButtonColor=false
SettingsClose.ZIndex=21

-- ===================================================
-- 🖱️ SCROLL GUI CÀI ĐẶT
-- ===================================================
local SettingsScroll=Instance.new("ScrollingFrame",SettingsGui)
SettingsScroll.Name="SettingsScroll"
SettingsScroll.Size=UDim2.new(1,-8,1,-32)
SettingsScroll.Position=UDim2.new(0,4,0,29)
SettingsScroll.BackgroundTransparency=1
SettingsScroll.BorderSizePixel=0
SettingsScroll.ScrollBarThickness=3
SettingsScroll.ScrollBarImageColor3=Color3.fromRGB(0,170,255)
SettingsScroll.CanvasSize=UDim2.new(0,0,0,0)
SettingsScroll.AutomaticCanvasSize=Enum.AutomaticSize.None
SettingsScroll.ScrollingDirection=Enum.ScrollingDirection.Y
SettingsScroll.ZIndex=21

local SettingsList=Instance.new("UIListLayout",SettingsScroll)
SettingsList.SortOrder=Enum.SortOrder.LayoutOrder
SettingsList.Padding=UDim.new(0,7)
SettingsList.HorizontalAlignment=Enum.HorizontalAlignment.Center

SettingsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SettingsScroll.CanvasSize=UDim2.new(0,0,0,SettingsList.AbsoluteContentSize.Y+10)
end)

-- ===================================================
-- 9. HÀM TẠO SLIDER
-- ===================================================
local function CreateSettingSlider(Parent,Name,MinValue,MaxValue,DefaultValue,Callback)
    local Holder=Instance.new("Frame",Parent)
    Holder.Size=UDim2.new(1,-6,0,54)
    Holder.BackgroundTransparency=1
    Holder.BorderSizePixel=0
    Holder.ZIndex=21

    local Label=Instance.new("TextLabel",Holder)
    Label.Size=UDim2.new(1,-50,0,18)
    Label.Position=UDim2.new(0,2,0,0)
    Label.BackgroundTransparency=1
    Label.Text=Name
    Label.Font=Enum.Font.Cartoon
    Label.TextSize=11
    Label.TextColor3=Color3.fromRGB(100,200,255)
    Label.TextXAlignment=Enum.TextXAlignment.Left
    Label.ZIndex=21

    local Input=Instance.new("TextBox",Holder)
    Input.Size=UDim2.new(0,38,0,19)
    Input.Position=UDim2.new(1,-40,0,-2)
    Input.BackgroundColor3=Color3.fromRGB(25,35,50)
    Input.BackgroundTransparency=0
    Input.Text=tostring(DefaultValue)
    Input.Font=Enum.Font.Cartoon
    Input.TextSize=11
    Input.TextColor3=Color3.fromRGB(255,255,255)
    Input.ClearTextOnFocus=false
    Input.TextXAlignment=Enum.TextXAlignment.Center
    Input.ZIndex=22

    Instance.new("UICorner",Input).CornerRadius=UDim.new(0,4)

    local InputStroke=Instance.new("UIStroke",Input)
    InputStroke.Thickness=1
    InputStroke.Color=Color3.fromRGB(0,120,200)

    local Bar=Instance.new("Frame",Holder)
    Bar.Size=UDim2.new(1,-45,0,6)
    Bar.Position=UDim2.new(0,2,0,27)
    Bar.BackgroundColor3=Color3.fromRGB(45,55,65)
    Bar.BorderSizePixel=0
    Bar.ZIndex=21

    Instance.new("UICorner",Bar).CornerRadius=UDim.new(1,0)

    local Fill=Instance.new("Frame",Bar)
    Fill.Size=UDim2.new(0,0,1,0)
    Fill.BackgroundColor3=Color3.fromRGB(0,170,255)
    Fill.BorderSizePixel=0
    Fill.ZIndex=22

    Instance.new("UICorner",Fill).CornerRadius=UDim.new(1,0)

    local Value=math.clamp(DefaultValue,MinValue,MaxValue)
    local Dragging=false

    local function SetValue(NewValue)
        NewValue=tonumber(NewValue)
        if not NewValue then NewValue=Value end
        Value=math.clamp(math.round(NewValue),MinValue,MaxValue)
        local Percent=(Value-MinValue)/(MaxValue-MinValue)
        Fill.Size=UDim2.new(Percent,0,1,0)
        Input.Text=tostring(Value)
        Callback(Value)
    end

    local function SetFromMouse(X)
        local Percent=math.clamp((X-Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X,0,1)
        SetValue(MinValue+(MaxValue-MinValue)*Percent)
    end

    Bar.InputBegan:Connect(function(InputObject)
        if InputObject.UserInputType==Enum.UserInputType.MouseButton1 or InputObject.UserInputType==Enum.UserInputType.Touch then
            Dragging=true
            SetFromMouse(InputObject.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(InputObject)
        if Dragging and (InputObject.UserInputType==Enum.UserInputType.MouseMovement or InputObject.UserInputType==Enum.UserInputType.Touch) then
            SetFromMouse(InputObject.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(InputObject)
        if InputObject.UserInputType==Enum.UserInputType.MouseButton1 or InputObject.UserInputType==Enum.UserInputType.Touch then Dragging=false end
    end)

    Input.FocusLost:Connect(function()
        local NewValue=tonumber(Input.Text)
        if NewValue then SetValue(NewValue) else Input.Text=tostring(Value) end
    end)

    SetValue(DefaultValue)

    return {Set=SetValue,Get=function() return Value end}
end

local SpeedSetting=CreateSettingSlider(SettingsScroll,"Tốc độ bay",150,250,_G.SPEED,function(Value) _G.SPEED=Value end)

local HeightSetting=CreateSettingSlider(SettingsScroll,"Độ cao quái",0,100,_G.DOCAO_MOB,function(Value) _G.DOCAO_MOB=Value end)

local BoatSpeedSetting=CreateSettingSlider(SettingsScroll,"Tốc độ thuyền",100,500,_G.BOAT_SPEED,function(Value) _G.BOAT_SPEED=Value end)
-- ===================================================
-- 🎞️ TWEEN GUI CÀI ĐẶT
-- ===================================================

local SettingsOpening=false
local SettingsClosing=false

local function OpenSettings()
    if SettingsOpening or SettingsGui.Visible then return end
    SettingsOpening=true
    SettingsGui.Visible=true
    SettingsGui.Size=SettingsClosedSize

    local Tween=TweenService:Create(SettingsGui,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=SettingsOpenSize})
    Tween:Play()

    Tween.Completed:Connect(function()
        SettingsOpening=false
    end)
end

local function CloseSettings()
    if SettingsClosing or not SettingsGui.Visible then return end
    SettingsClosing=true

    local Tween=TweenService:Create(SettingsGui,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=SettingsClosedSize})
    Tween:Play()

    Tween.Completed:Connect(function()
        SettingsGui.Visible=false
        SettingsClosing=false
    end)
end

local function ToggleSettings()
    if SettingsGui.Visible then CloseSettings() else OpenSettings() end
end

SettingsBtn.MouseButton1Click:Connect(ToggleSettings)
SettingsClose.MouseButton1Click:Connect(CloseSettings)

-- ===================================================
-- 9.1 HÀM THỰC THI TELEPORT CỔNG
-- ===================================================
local function SpawnToIsland(spawnArg)
    local commF=ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

    if spawnArg=="TempleOfTime" then
        if TempleFlyConnection or BodyVelocity then
            if TempleFlyConnection then TempleFlyConnection:Disconnect(); TempleFlyConnection=nil end
            DisableAntiGravity()
            DisableNoclip()
            return
        end

        task.spawn(function()
            local hrp=GetRoot()
            if not hrp then return end

            EnableAntiGravity(hrp)
            EnableNoclip()

            local entranceCFrame=CFrame.new(3035.22,2280.89,-7321.22)
            local phase=1
            local raceCFrame=nil

            TempleFlyConnection=RunService.Heartbeat:Connect(function(deltaTime)
                local currentHrp=GetRoot()

                if not currentHrp then
                    if TempleFlyConnection then TempleFlyConnection:Disconnect(); TempleFlyConnection=nil end
                    DisableAntiGravity()
                    DisableNoclip()
                    return
                end

                currentHrp.AssemblyLinearVelocity=Vector3.zero
                currentHrp.AssemblyAngularVelocity=Vector3.zero
                EnableNoclip()

                if phase==2 then return end

                local targetCFrame
                if phase==1 then targetCFrame=entranceCFrame elseif phase==3 then targetCFrame=raceCFrame end
                if not targetCFrame then return end

                local distance=(currentHrp.Position-targetCFrame.Position).Magnitude
                local boostDistance=tonumber(_G.BOOST_DISTANCE) or 90
                local boostSpeed=tonumber(_G.BOOST_SPEED) or 1000
                local normalSpeed=tonumber(_G.SPEED) or 140
                local activeSpeed=distance<=boostDistance and boostSpeed or normalSpeed
                local alpha=math.clamp((activeSpeed*deltaTime)/math.max(distance,0.001),0,1)

                if phase==1 then
                    if distance<=0.5 then
                        phase=2

                        task.spawn(function()
                            for i=1,10 do
                                local mapFolder=Workspace:FindFirstChild("Map") or Workspace

                                if not mapFolder:FindFirstChild("Temple of Time") then
                                    local stash=ReplicatedStorage:FindFirstChild("MapStash") or ReplicatedStorage
                                    local tot=stash:FindFirstChild("Temple of Time")
                                    if tot then tot.Parent=mapFolder; break end
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

                            local race=nil
                            pcall(function() race=LocalPlayer.Data.Race.Value end)

                            if race=="Fishman" then
                                raceCFrame=CFrame.new(28224.056640625,14889.4267578125,-210.5872039794922)
                            elseif race=="Cyborg" then
                                raceCFrame=CFrame.new(28492.4140625,14894.4267578125,-422.1100158691406)
                            elseif race=="Skypiea" then
                                raceCFrame=CFrame.new(28967.408203125,14918.0751953125,234.31198120117188)
                            elseif race=="Ghoul" then
                                raceCFrame=CFrame.new(28672.720703125,14889.1279296875,454.5961608886719)
                            elseif race=="Human" then
                                raceCFrame=CFrame.new(29237.294921875,14889.4267578125,-206.94955444335938)
                            else
                                raceCFrame=CFrame.new(29020.66015625,14889.4267578125,-379.2682800292969)
                            end

                            phase=3
                        end)
                    else
                        currentHrp.CFrame=currentHrp.CFrame:Lerp(targetCFrame,alpha)
                    end
                elseif phase==3 then
                    if distance<=3 then
                        if TempleFlyConnection then TempleFlyConnection:Disconnect(); TempleFlyConnection=nil end
                        DisableAntiGravity()
                        DisableNoclip()
                        return
                    else
                        currentHrp.CFrame=currentHrp.CFrame:Lerp(targetCFrame,alpha)
                    end
                end
            end)
        end)

        return
    end
end

-- ===================================================
-- 🚤 NÚT TỐC ĐỘ THUYỀN
-- ===================================================
local Btn=Instance.new("TextButton",Scroll)
Btn.Size=UDim2.new(0.9,0,0,32)
Btn.Text="Đền Thời Gian"
Btn.Font=Enum.Font.Cartoon
Btn.TextSize=13
Btn.TextColor3=Color3.fromRGB(100,200,255)
Btn.BackgroundColor3=Color3.fromRGB(25,35,50)
Btn.BackgroundTransparency=0.3
Btn.AutoButtonColor=false
Instance.new("UICorner",Btn).CornerRadius=UDim.new(0,6)

local btnS=Instance.new("UIStroke",Btn)
btnS.Thickness=1
btnS.Color=Color3.fromRGB(0,120,200)

Btn.MouseButton1Click:Connect(function() SpawnToIsland("TempleOfTime") end)

local BoatHolder=Instance.new("Frame",Scroll)
BoatHolder.Size=UDim2.new(0.9,0,0,38)
BoatHolder.BackgroundColor3=Color3.fromRGB(25,35,50)
BoatHolder.BackgroundTransparency=0.3
BoatHolder.BorderSizePixel=0
Instance.new("UICorner",BoatHolder).CornerRadius=UDim.new(0,6)

local BoatHolderStroke=Instance.new("UIStroke",BoatHolder)
BoatHolderStroke.Thickness=1
BoatHolderStroke.Color=Color3.fromRGB(0,120,200)

local BoatLabel=Instance.new("TextLabel",BoatHolder)
BoatLabel.Size=UDim2.new(1,-65,1,0)
BoatLabel.Position=UDim2.new(0,5,0,0)
BoatLabel.BackgroundTransparency=1
BoatLabel.Text="TỐC ĐỘ THUYỀN"
BoatLabel.Font=Enum.Font.Cartoon
BoatLabel.TextSize=13
BoatLabel.TextColor3=Color3.fromRGB(100,200,255)
BoatLabel.TextXAlignment=Enum.TextXAlignment.Left

local BoatSwitch=Instance.new("TextButton",BoatHolder)
BoatSwitch.Size=UDim2.new(0,42,0,21)
BoatSwitch.Position=UDim2.new(1,-47,0.5,-10.5)
BoatSwitch.BackgroundColor3=Color3.fromRGB(35,40,48)
BoatSwitch.AutoButtonColor=false
BoatSwitch.Text=""
Instance.new("UICorner",BoatSwitch).CornerRadius=UDim.new(1,0)

local BoatStroke=Instance.new("UIStroke",BoatSwitch)
BoatStroke.Thickness=1
BoatStroke.Color=Color3.fromRGB(70,80,90)

local BoatKnob=Instance.new("Frame",BoatSwitch)
BoatKnob.Size=UDim2.new(0,15,0,15)
BoatKnob.Position=UDim2.new(0,3,0.5,-7.5)
BoatKnob.BackgroundColor3=Color3.fromRGB(255,255,255)
Instance.new("UICorner",BoatKnob).CornerRadius=UDim.new(1,0)

local function UpdateBoatToggle()
    if BoatEnabled then
        BoatSwitch.BackgroundColor3=Color3.fromRGB(15,70,105)
        BoatStroke.Color=Color3.fromRGB(0,170,255)
        TweenService:Create(BoatKnob,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(1,-18,0.5,-7.5)}):Play()
    else
        BoatSwitch.BackgroundColor3=Color3.fromRGB(35,40,48)
        BoatStroke.Color=Color3.fromRGB(70,80,90)
        TweenService:Create(BoatKnob,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(0,3,0.5,-7.5)}):Play()
    end
end

BoatSwitch.MouseButton1Click:Connect(function()
    BoatEnabled=not BoatEnabled
    UpdateBoatToggle()
end)

-- ===================================================
-- 9.2 TOGGLE BAY TRÁI / QUÁI / FARM RƯƠNG
-- ===================================================
local BLUE=Color3.fromRGB(0,170,255)
local OFF_BG=Color3.fromRGB(35,40,48)
local ON_BG=Color3.fromRGB(15,70,105)
local TEXT_COLOR=Color3.fromRGB(100,200,255)

-- ===================================================
-- 9.3 TẠO TOGGLE
-- ===================================================
local function CreateToggle(Name,Callback)
    local Holder=Instance.new("Frame",Scroll)
    Holder.Size=UDim2.new(0.9,0,0,38)
    Holder.BackgroundColor3=Color3.fromRGB(25,35,50)
    Holder.BackgroundTransparency=0.3
    Holder.BorderSizePixel=0
    Instance.new("UICorner",Holder).CornerRadius=UDim.new(0,6)

    local HolderStroke=Instance.new("UIStroke",Holder)
    HolderStroke.Thickness=1
    HolderStroke.Color=Color3.fromRGB(0,120,200)

    local Label=Instance.new("TextLabel",Holder)
    Label.Size=UDim2.new(1,-65,1,0)
    Label.Position=UDim2.new(0,5,0,0)
    Label.BackgroundTransparency=1
    Label.Text=Name
    Label.Font=Enum.Font.Cartoon
    Label.TextSize=13
    Label.TextColor3=TEXT_COLOR
    Label.TextXAlignment=Enum.TextXAlignment.Left

    local Switch=Instance.new("TextButton",Holder)
    Switch.Size=UDim2.new(0,42,0,21)
    Switch.Position=UDim2.new(1,-47,0.5,-10.5)
    Switch.BackgroundColor3=OFF_BG
    Switch.AutoButtonColor=false
    Switch.Text=""
    Instance.new("UICorner",Switch).CornerRadius=UDim.new(1,0)

    local Stroke=Instance.new("UIStroke",Switch)
    Stroke.Thickness=1
    Stroke.Color=Color3.fromRGB(70,80,90)

    local Knob=Instance.new("Frame",Switch)
    Knob.Size=UDim2.new(0,15,0,15)
    Knob.Position=UDim2.new(0,3,0.5,-7.5)
    Knob.BackgroundColor3=Color3.fromRGB(255,255,255)
    Instance.new("UICorner",Knob).CornerRadius=UDim.new(1,0)

    local Enabled=false

    local function Update()
        if Enabled then
            Switch.BackgroundColor3=ON_BG
            Stroke.Color=BLUE
            Knob.BackgroundColor3=Color3.fromRGB(255,255,255)
            TweenService:Create(Knob,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(1,-18,0.5,-7.5)}):Play()
        else
            Switch.BackgroundColor3=OFF_BG
            Stroke.Color=Color3.fromRGB(70,80,90)
            Knob.BackgroundColor3=Color3.fromRGB(255,255,255)
            TweenService:Create(Knob,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(0,3,0.5,-7.5)}):Play()
        end
        Callback(Enabled)
    end

    Switch.MouseButton1Click:Connect(function()
        Enabled=not Enabled
        Update()
    end)

    return {Set=function(Value) Enabled=Value; Update() end,Get=function() return Enabled end}
end

-- ===================================================
-- BAY TỚI TRÁI
-- ===================================================
local FruitToggle=CreateToggle("BAY TỚI TRÁI",function(Value)
    FruitEnabled=Value
    TargetFruit=nil
end)

-- ===================================================
-- BAY TỚI QUÁI
-- ===================================================
local MobToggle=CreateToggle("BAY TỚI QUÁI",function(Value)
    MobEnabled=Value
    TargetMob=nil
end)

-- ===================================================
-- FARM RƯƠNG
-- ===================================================
local ChestToggle=CreateToggle("FARM RƯƠNG",function(Value)
    ChestEnabled=Value
    if Value then LastBeli=GetCurrentBeli() end
    TargetChest=nil
    TouchTimer=0
end)
