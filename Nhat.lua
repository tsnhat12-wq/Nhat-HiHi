-- ===================================================
-- ĐOẠN 1A: SERVICE, CẤU HÌNH, CLEANUP GUI & BIẾN TRẠNG THÁI
-- ===================================================
local CoreGui=game:GetService("CoreGui")
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local CollectionService=game:GetService("CollectionService")
local HttpService=game:GetService("HttpService")
local LocalPlayer=Players.LocalPlayer
local Player=LocalPlayer

local Sec=1
local Observation=true
local Boud=true
local DestroyHit=true

local CONFIG_FILE="sea_menu_config.json"

local DefaultConfig={
    Speed=220,
    HeightMob=35,
    BoatSpeed=450,
    FruitEnabled=false,
    MobEnabled=false,
    ChestEnabled=false,
    BoatEnabled=false,
    FastAttackEnabled=false,
    NormalFastAttackEnabled=false,
    FastAttackTool="Melee",
    FruitAttackEnabled=false,
    EspFruitEnabled=true,
    EspEventIslandEnabled=true,
    EspNpcEnabled=true,
    AutoRaceV4Enabled=false,
}

local function NormalizeFastAttackTool(val)
    if typeof(val)=="string" and val:lower()=="sword" then
        return "Sword"
    end
    return "Melee"
end

local function LoadMenuConfig()
    local cfg={
        Speed=DefaultConfig.Speed,
        HeightMob=DefaultConfig.HeightMob,
        BoatSpeed=DefaultConfig.BoatSpeed,
        FruitEnabled=DefaultConfig.FruitEnabled,
        MobEnabled=DefaultConfig.MobEnabled,
        ChestEnabled=DefaultConfig.ChestEnabled,
        BoatEnabled=DefaultConfig.BoatEnabled,
        FastAttackEnabled=DefaultConfig.FastAttackEnabled,
        NormalFastAttackEnabled=DefaultConfig.NormalFastAttackEnabled,
        FastAttackTool=DefaultConfig.FastAttackTool,
        FruitAttackEnabled=DefaultConfig.FruitAttackEnabled,
        EspFruitEnabled=DefaultConfig.EspFruitEnabled,
        EspEventIslandEnabled=DefaultConfig.EspEventIslandEnabled,
        EspNpcEnabled=DefaultConfig.EspNpcEnabled,
        AutoRaceV4Enabled=DefaultConfig.AutoRaceV4Enabled,
    }

    local function applyTable(tbl)
        if typeof(tbl)~="table" then return end
        if tonumber(tbl.Speed) then cfg.Speed=tonumber(tbl.Speed) end
        if tonumber(tbl.HeightMob) then cfg.HeightMob=tonumber(tbl.HeightMob) end
        if tonumber(tbl.BoatSpeed) then cfg.BoatSpeed=tonumber(tbl.BoatSpeed) end
        if typeof(tbl.FruitEnabled)=="boolean" then cfg.FruitEnabled=tbl.FruitEnabled end
        if typeof(tbl.MobEnabled)=="boolean" then cfg.MobEnabled=tbl.MobEnabled end
        if typeof(tbl.ChestEnabled)=="boolean" then cfg.ChestEnabled=tbl.ChestEnabled end
        if typeof(tbl.BoatEnabled)=="boolean" then cfg.BoatEnabled=tbl.BoatEnabled end
        if typeof(tbl.FastAttackEnabled)=="boolean" then cfg.FastAttackEnabled=tbl.FastAttackEnabled end
        if typeof(tbl.NormalFastAttackEnabled)=="boolean" then cfg.NormalFastAttackEnabled=tbl.NormalFastAttackEnabled end
        if tbl.FastAttackTool~=nil then cfg.FastAttackTool=NormalizeFastAttackTool(tbl.FastAttackTool) end
        if typeof(tbl.FruitAttackEnabled)=="boolean" then cfg.FruitAttackEnabled=tbl.FruitAttackEnabled end
        if typeof(tbl.EspFruitEnabled)=="boolean" then cfg.EspFruitEnabled=tbl.EspFruitEnabled end
        if typeof(tbl.EspEventIslandEnabled)=="boolean" then cfg.EspEventIslandEnabled=tbl.EspEventIslandEnabled end
        if typeof(tbl.EspNpcEnabled)=="boolean" then cfg.EspNpcEnabled=tbl.EspNpcEnabled end
        if typeof(tbl.AutoRaceV4Enabled)=="boolean" then cfg.AutoRaceV4Enabled=tbl.AutoRaceV4Enabled end
    end

    if isfile and readfile and isfile(CONFIG_FILE) then
        local ok,decoded=pcall(function()
            return HttpService:JSONDecode(readfile(CONFIG_FILE))
        end)
        if ok then applyTable(decoded) end
    end

    if typeof(_G.SeaMenuConfig)=="table" then
        applyTable(_G.SeaMenuConfig)
    end

    _G.SeaMenuConfig=cfg
    return cfg
end

local MenuConfig=LoadMenuConfig()

local function SaveMenuConfig()
    if typeof(_G.SeaMenuConfig)~="table" then
        _G.SeaMenuConfig={}
    end
    for k,v in pairs(MenuConfig) do
        _G.SeaMenuConfig[k]=v
    end
    if writefile then
        pcall(function()
            writefile(CONFIG_FILE,HttpService:JSONEncode(MenuConfig))
        end)
    end
end

local function ClearOldGUI()
    local oldNames={"SeaMenu_Gui","Toggle25x25Gui","AxiomTeleportMobBF","AxiomTeleportChestBF","AxiomTeleportFruitBF","RaceV4GUI"}

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

_G.SPEED=math.clamp(MenuConfig.Speed,150,250)
_G.BOOST_SPEED=5000
_G.BOOST_DISTANCE=100
_G.DOCAO_MOB=math.clamp(MenuConfig.HeightMob,0,100)
_G.DOCAO_CHEST=0
_G.DOCAO_FRUIT=1
_G.DOXATP=0
_G.BOAT_SPEED=math.clamp(MenuConfig.BoatSpeed,100,500)

MenuConfig.Speed=_G.SPEED
MenuConfig.HeightMob=_G.DOCAO_MOB
MenuConfig.BoatSpeed=_G.BOAT_SPEED
MenuConfig.FastAttackTool=NormalizeFastAttackTool(MenuConfig.FastAttackTool)

local MobEnabled=MenuConfig.MobEnabled
local ChestEnabled=MenuConfig.ChestEnabled
local FruitEnabled=MenuConfig.FruitEnabled
local BoatEnabled=MenuConfig.BoatEnabled
local DevilFruitESP=MenuConfig.EspFruitEnabled
local EspEventIsland=MenuConfig.EspEventIslandEnabled
local AdvancedFruitDealerESP=MenuConfig.EspNpcEnabled
local AutoRaceV4Enabled=MenuConfig.AutoRaceV4Enabled and true or false
_G.BoatESP=true

-- ===================================================
-- ĐOẠN 1B: ESP NHIỀU TRÁI, ĐẢO SỰ KIỆN & VÒNG LẶP MÔI TRƯỜNG
-- ===================================================
local cachedFruitHandles={}
local cachedEventIslands={}
local cachedMyBoatCore=nil
local cachedAdvancedFruitDealer=nil

local EventIslandNames={
    ["Mirage Island"]=true,
    ["Prehistoric Island"]=true,
    ["Kitsune Island"]=true,
    ["Frozen Dimension"]=true,
}

local function GetRoot()
    local char=Player.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"))
end

local function SetFruitESPEnabled(state)
    DevilFruitESP=state and true or false
    if not DevilFruitESP then
        table.clear(cachedFruitHandles)
        for _,v in ipairs(Workspace:GetChildren()) do
            pcall(function()
                local handle=v:FindFirstChild("Handle")
                local esp=handle and handle:FindFirstChild("NameEsp")
                if esp then esp:Destroy() end
            end)
        end
    end
end

local function SetEventIslandESPEnabled(state)
    EspEventIsland=state and true or false
    if not EspEventIsland then
        table.clear(cachedEventIslands)
        local worldOrigin=Workspace:FindFirstChild("_WorldOrigin")
        local locationsFolder=worldOrigin and worldOrigin:FindFirstChild("Locations")
        if locationsFolder then
            for _,v in ipairs(locationsFolder:GetChildren()) do
                pcall(function()
                    local esp=v:FindFirstChild("NameEsp")
                    if esp then esp:Destroy() end
                end)
            end
        end
    end
end

local function SetNpcESPEnabled(state)
    AdvancedFruitDealerESP=state and true or false
    if not AdvancedFruitDealerESP then
        cachedAdvancedFruitDealer=nil
        local oldAdv=Workspace:FindFirstChild("Adv")
        if oldAdv then oldAdv:Destroy() end
    end
end

local function IsWorldFruitModel(obj)
    if not obj then return false end
    if Players:GetPlayerFromCharacter(obj) then return false end
    if obj:IsA("Tool") or obj:IsA("Model") then
        local handle=obj:FindFirstChild("Handle")
        if handle and handle:IsA("BasePart") then
            local n=obj.Name:lower()
            if n:find("fruit") or n:find("trái") or n:find("trai") then
                return true
            end
        end
    end
    return false
end

task.spawn(function()
    while task.wait(0.25) do
        if DevilFruitESP then
            local list={}
            for _,v in ipairs(Workspace:GetChildren()) do
                pcall(function()
                    if IsWorldFruitModel(v) then
                        table.insert(list,v.Handle)
                    end
                end)
            end
            cachedFruitHandles=list
        else
            table.clear(cachedFruitHandles)
        end
    end
end)

task.spawn(function()
    while task.wait(0.02) do
        if DevilFruitESP and #cachedFruitHandles>0 then
            pcall(function()
                local myRoot=GetRoot()
                if not myRoot then return end

                for _,handle in ipairs(cachedFruitHandles) do
                    if handle and handle.Parent then
                        local distMeters=math.floor((myRoot.Position-handle.Position).Magnitude/10)
                        local bill=handle:FindFirstChild("NameEsp")

                        if not bill then
                            bill=Instance.new("BillboardGui",handle)
                            bill.Name="NameEsp"
                            bill.Size=UDim2.new(0,200,0,50)
                            bill.StudsOffset=Vector3.new(0,4,0)
                            bill.AlwaysOnTop=true

                            local name=Instance.new("TextLabel",bill)
                            name.Name="Text"
                            name.Size=UDim2.new(1,0,1,0)
                            name.BackgroundTransparency=1
                            name.TextSize=9
                            name.TextColor3=Color3.fromRGB(0,255,255)
                            name.TextStrokeTransparency=0
                            name.TextStrokeColor3=Color3.fromRGB(0,0,0)
                        end

                        local textLabel=bill:FindFirstChild("Text")
                        if textLabel then
                            textLabel.Text=handle.Parent.Name.."\n"..distMeters.." m"
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if AdvancedFruitDealerESP then
            local foundDealer=nil
            local npcs=ReplicatedStorage:FindFirstChild("NPCs")

            if npcs then
                for _,v in ipairs(npcs:GetChildren()) do
                    if v.Name=="Advanced Fruit Dealer" then
                        foundDealer=v
                        break
                    end
                end
            end

            cachedAdvancedFruitDealer=foundDealer
        else
            cachedAdvancedFruitDealer=nil

            local oldAdv=Workspace:FindFirstChild("Adv")
            if oldAdv then
                oldAdv:Destroy()
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.01) do
        if AdvancedFruitDealerESP and cachedAdvancedFruitDealer then
            pcall(function()
                local myRoot=GetRoot()
                local dealerRoot=cachedAdvancedFruitDealer:FindFirstChild("HumanoidRootPart")

                if not myRoot or not dealerRoot then return end

                local adv=Workspace:FindFirstChild("Adv")

                if not adv then
                    adv=Instance.new("Part")
                    adv.Name="Adv"
                    adv.Size=Vector3.new(1,1,1)
                    adv.Transparency=1
                    adv.Anchored=true
                    adv.CanCollide=false
                    adv.CanTouch=false
                    adv.CanQuery=false
                    adv.CFrame=dealerRoot.CFrame
                    adv.Parent=Workspace
                else
                    adv.CFrame=dealerRoot.CFrame
                end

                local distMeters=math.floor((myRoot.Position-dealerRoot.Position).Magnitude/10)
                local bill=adv:FindFirstChild("NameEsp")

                if not bill then
                    bill=Instance.new("BillboardGui",adv)
                    bill.Name="NameEsp"
                    bill.Size=UDim2.new(0,200,0,50)
                    bill.StudsOffset=Vector3.new(0,4,0)
                    bill.AlwaysOnTop=true

                    local text=Instance.new("TextLabel",bill)
                    text.Name="Text"
                    text.Size=UDim2.new(1,0,1,0)
                    text.BackgroundTransparency=1
                    text.TextSize=9
                    text.TextColor3=Color3.fromRGB(80,245,245)
                    text.TextStrokeTransparency=0
                    text.TextStrokeColor3=Color3.fromRGB(0,0,0)
                end

                local textLabel=bill:FindFirstChild("Text")

                if textLabel then
                    textLabel.Text=cachedAdvancedFruitDealer.Name.."\n"..distMeters.." m"
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.25) do
        if EspEventIsland then
            local list={}
            local worldOrigin=Workspace:FindFirstChild("_WorldOrigin")
            local locationsFolder=worldOrigin and worldOrigin:FindFirstChild("Locations")

            if locationsFolder then
                for _,v in ipairs(locationsFolder:GetChildren()) do
                    pcall(function()
                        if EventIslandNames[v.Name] then
                            table.insert(list,v)
                        end
                    end)
                end
            end

            cachedEventIslands=list
        else
            table.clear(cachedEventIslands)
        end
    end
end)

task.spawn(function()
    while task.wait(0.02) do
        if EspEventIsland and #cachedEventIslands>0 then
            pcall(function()
                local myRoot=GetRoot()
                if not myRoot then return end

                for _,island in ipairs(cachedEventIslands) do
                    if island and island.Parent then
                        local islandPosition=island:IsA("BasePart") and island.Position or island:GetPivot().Position
                        local distMeters=math.floor((myRoot.Position-islandPosition).Magnitude/10)
                        local bill=island:FindFirstChild("NameEsp")

                        if not bill then
                            bill=Instance.new("BillboardGui",island)
                            bill.Name="NameEsp"
                            bill.StudsOffset=Vector3.new(0,5,0)
                            bill.Size=UDim2.new(0,200,0,50)
                            bill.AlwaysOnTop=true

                            local name=Instance.new("TextLabel",bill)
                            name.Name="Text"
                            name.Size=UDim2.new(1,0,1,0)
                            name.BackgroundTransparency=1
                            name.TextSize=9
                            name.TextColor3=Color3.fromRGB(80,245,245)
                            name.TextStrokeTransparency=0
                            name.TextStrokeColor3=Color3.fromRGB(0,0,0)
                        end

                        local textLabel=bill:FindFirstChild("Text")
                        if textLabel then
                            textLabel.Text=island.Name.."\n"..distMeters.." m"
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if _G.BoatESP then
            local foundBoatCore=nil

            pcall(function()
                local boatsFolder=Workspace:FindFirstChild("Boats")
                if not boatsFolder then return end

                for _,boat in ipairs(boatsFolder:GetChildren()) do
                    local isMyBoat=boat.Name:find(Player.Name)~=nil

                    if not isMyBoat then
                        for _,descendant in ipairs(boat:GetDescendants()) do
                            if descendant:IsA("ObjectValue") and descendant.Value==Player then
                                isMyBoat=true
                                break
                            elseif descendant:IsA("StringValue") and descendant.Value==Player.Name then
                                isMyBoat=true
                                break
                            end
                        end
                    end

                    if isMyBoat then
                        foundBoatCore=boat.PrimaryPart or boat:FindFirstChild("Hull") or boat:FindFirstChild("Seat") or boat:FindFirstChildOfClass("BasePart")
                        if foundBoatCore then break end
                    end
                end
            end)

            cachedMyBoatCore=foundBoatCore
        else
            cachedMyBoatCore=nil
        end
    end
end)

task.spawn(function()
    while task.wait(0.01) do
        if _G.BoatESP and cachedMyBoatCore and cachedMyBoatCore.Parent then
            pcall(function()
                local myRoot=GetRoot()
                if not myRoot then return end

                local distMeters=math.floor((cachedMyBoatCore.Position-myRoot.Position).Magnitude/10)
                local bill=cachedMyBoatCore:FindFirstChild("AxiomBoatESP")

                if not bill then
                    bill=Instance.new("BillboardGui")
                    bill.Name="AxiomBoatESP"
                    bill.Size=UDim2.new(0,200,0,50)
                    bill.StudsOffset=Vector3.new(0,6,0)
                    bill.AlwaysOnTop=true

                    local txt=Instance.new("TextLabel",bill)
                    txt.Name="Text"
                    txt.Size=UDim2.new(1,0,1,0)
                    txt.BackgroundTransparency=1
                    txt.TextSize=9
                    txt.TextColor3=Color3.fromRGB(0,255,255)
                    txt.TextStrokeTransparency=0
                    txt.TextStrokeColor3=Color3.fromRGB(0,0,0)

                    bill.Parent=cachedMyBoatCore
                end

                local textLabel=bill:FindFirstChild("Text")
                if textLabel then
                    textLabel.Text="THUYỀN\n"..distMeters.." m"
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait() do
        pcall(function()
            if Observation then
                ReplicatedStorage.Remotes.CommE:FireServer("Ken",true)
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(Sec) do
        pcall(function()
            if Boud and Player.Character then
                local _HasBuso={"HasBuso","Buso"}

                if not Player.Character:FindFirstChild(_HasBuso[1]) then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer(_HasBuso[2])
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local waterPlane=Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("WaterBase-Plane")

            if waterPlane then
                waterPlane.Size=Vector3.new(1000,112,1000)
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(2) do
        pcall(function()
            if Lighting:FindFirstChild("LightingLayers") then Lighting.LightingLayers:Destroy() end
            if Lighting:FindFirstChild("SeaTerrorCC") then Lighting.SeaTerrorCC:Destroy() end
            if Lighting:FindFirstChild("FantasySky") then Lighting.FantasySky:Destroy() end

            Lighting.FogEnd=9e9
            Lighting.GlobalShadows=false
        end)
    end
end)

local HitEffects={"SlashHit","CurvedRing","SwordSlash","SlashTail"}

task.spawn(function()
    while task.wait(Sec) do
        if DestroyHit then
            pcall(function()
                local worldOrigin=Workspace:FindFirstChild("_WorldOrigin")

                if worldOrigin then
                    for _,v in pairs(worldOrigin:GetChildren()) do
                        if table.find(HitEffects,v.Name) then
                            v:Destroy()
                        end
                    end
                end
            end)
        end
    end
end)

-- ===================================================
-- ĐOẠN 2/4: TÌM MỤC TIÊU & LOOP ĐIỀU KHIỂN BAY (TWEEN / LERP)
-- ===================================================
local TargetMob=nil
local TargetChest=nil
local TargetFruit=nil
local TempleFlyConnection=nil
local BodyVelocity=nil
local NoclipConnection=nil
local IgnoredChests=setmetatable({},{__mode="k"})
local TouchTimer=0
local SEARCH_MOB_DISTANCE=1500
local BOOST_DISTANCE=100
local BOOST_SPEED=5000

local ActiveFlyTween=nil
local ActiveFlyTweenGoalPos=nil
local IsBoostingNearTween=false

local function CancelActiveFlyTween()
    IsBoostingNearTween=false
    if ActiveFlyTween then
        pcall(function() ActiveFlyTween:Cancel() end)
        ActiveFlyTween:Destroy()
        ActiveFlyTween=nil
    end
    ActiveFlyTweenGoalPos=nil
end

local function PlayTweenToTarget(root,targetCFrame,speed)
    if not root or not root.Parent then return end
    if ActiveFlyTween then
        pcall(function() ActiveFlyTween:Cancel() end)
        ActiveFlyTween:Destroy()
        ActiveFlyTween=nil
    end

    local targetPos=targetCFrame.Position
    local distance=(root.Position-targetPos).Magnitude
    local safeSpeed=math.max(tonumber(speed) or 200,1)
    local duration=math.max(distance/safeSpeed,0.01)
    local tweenInfo=TweenInfo.new(duration,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)

    ActiveFlyTweenGoalPos=targetPos
    ActiveFlyTween=TweenService:Create(root,tweenInfo,{CFrame=targetCFrame})

    local currentTween=ActiveFlyTween
    currentTween.Completed:Connect(function()
        if ActiveFlyTween==currentTween then
            ActiveFlyTween=nil
            ActiveFlyTweenGoalPos=nil
        end
    end)

    currentTween:Play()
end

local function GetRoot()
    local Character=LocalPlayer.Character
    return Character and Character:FindFirstChild("HumanoidRootPart")
end

local function EnableAntiGravity(root)
    if not BodyVelocity or BodyVelocity.Parent~=root then
        if BodyVelocity then
            BodyVelocity:Destroy()
        end
        BodyVelocity=Instance.new("BodyVelocity")
        BodyVelocity.Name="AxiomHover"
        BodyVelocity.Velocity=Vector3.zero
        BodyVelocity.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
        BodyVelocity.P=12500
        BodyVelocity.Parent=root
    end

    local Character=LocalPlayer.Character
    local Humanoid=Character and Character:FindFirstChildOfClass("Humanoid")
    if Humanoid and Humanoid.Sit then
        Humanoid.Sit=false
        if Humanoid.SeatPart then
            Humanoid.SeatPart=nil
        end
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

local function DisableAntiGravity()
    if BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity=nil
    end
end

local function EnableNoclip()
    if not NoclipConnection then
        NoclipConnection=RunService.Stepped:Connect(function()
            if (MobEnabled or ChestEnabled or FruitEnabled or TempleFlyConnection) and LocalPlayer.Character then
                for _,part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide=false
                    end
                end
            end
        end)
    end
end

local function DisableNoclip()
    if NoclipConnection and not MobEnabled and not ChestEnabled and not FruitEnabled and not TempleFlyConnection then
        NoclipConnection:Disconnect()
        NoclipConnection=nil
    end
end

local function GetFlySpeedForDistance(distance)
    local baseSpeed=tonumber(_G.SPEED) or 200
    local boostDist=tonumber(_G.BOOST_DISTANCE) or BOOST_DISTANCE
    local boostSpd=tonumber(_G.BOOST_SPEED) or BOOST_SPEED
    if distance<=boostDist then
        return boostSpd
    end
    return baseSpeed
end

local function StepFlyToCFrame(root,targetCFrame,deltaTime,customSpeed)
    if not root or not root.Parent then return end

    local currentPos=root.Position
    local targetPos=targetCFrame.Position
    local offset=targetPos-currentPos
    local distance=offset.Magnitude
    local boostDist=tonumber(_G.BOOST_DISTANCE) or BOOST_DISTANCE
    local boostSpd=tonumber(_G.BOOST_SPEED) or BOOST_SPEED
    local sliderSpeed=customSpeed or (tonumber(_G.SPEED) or 200)
    local shouldBoost=(distance<=boostDist)

    if distance<=0.05 then
        CancelActiveFlyTween()
        root.CFrame=targetCFrame
        return
    end

    if FlyMode=="Tween" then
        local activeSpeed=shouldBoost and boostSpd or sliderSpeed
        local targetMoved=(not ActiveFlyTweenGoalPos) or ((ActiveFlyTweenGoalPos-targetPos).Magnitude>1)

        if targetMoved then
            IsBoostingNearTween=shouldBoost
            PlayTweenToTarget(root,targetCFrame,activeSpeed)
        elseif shouldBoost and not IsBoostingNearTween then
            IsBoostingNearTween=true
            PlayTweenToTarget(root,targetCFrame,boostSpd)
        elseif (not ActiveFlyTween) or (ActiveFlyTween.PlaybackState~=Enum.PlaybackState.Playing) then
            IsBoostingNearTween=shouldBoost
            PlayTweenToTarget(root,targetCFrame,activeSpeed)
        end
    else
        CancelActiveFlyTween()
        local speed=shouldBoost and boostSpd or sliderSpeed
        local step=speed*deltaTime
        if step>=distance then
            root.CFrame=targetCFrame
        else
            local nextPos=currentPos+offset.Unit*step
            root.CFrame=(targetCFrame-targetPos)+nextPos
        end
    end
end

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
    TargetBeam.Width0=0.25
    TargetBeam.Width1=0.25
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

local function FindNearestTaggedChest()
    local MyRoot=GetRoot()
    if not MyRoot then return nil end

    local Position=MyRoot.Position
    local Distance,Nearest=math.huge,nil
    local Chests=CollectionService:GetTagged("_ChestTagged")

    for i=1,#Chests do
        local Chest=Chests[i]
        if Chest and Chest.Parent and not IgnoredChests[Chest] and not Chest:GetAttribute("IsDisabled") then
            if not SelectedIsland or Chest:IsDescendantOf(SelectedIsland) then
                local Magnitude=(Chest:GetPivot().Position-Position).Magnitude
                if Magnitude<Distance then
                    Distance=Magnitude
                    Nearest=Chest
                end
            end
        end
    end

    return Nearest
end

local function FindNearestFruit()
    local MyRoot=GetRoot()
    if not MyRoot then return nil end

    local Nearest=nil
    local NearestDistance=math.huge

    for _,x1 in pairs(Workspace:GetChildren()) do
        if string.find(x1.Name,"Fruit") then
            local Handle=x1:FindFirstChild("Handle")
            if Handle and Handle:IsA("BasePart") then
                local Distance=(Handle.Position-MyRoot.Position).Magnitude
                if Distance<NearestDistance then
                    NearestDistance=Distance
                    Nearest=Handle
                end
            end
        end
    end

    return Nearest
end

RunService.Heartbeat:Connect(function(DeltaTime)
    if TempleFlyConnection then return end

    if not MobEnabled and not ChestEnabled and not FruitEnabled then
        CancelActiveFlyTween(); DisableAntiGravity(); DisableNoclip(); RemoveTargetBeam(); return
    end

    local MyRoot=GetRoot()
    if not MyRoot then
        CancelActiveFlyTween(); DisableAntiGravity(); DisableNoclip(); RemoveTargetBeam(); return
    end

    MyRoot.AssemblyLinearVelocity=Vector3.zero
    MyRoot.AssemblyAngularVelocity=Vector3.zero

    if FruitEnabled then
        if not TargetFruit or not TargetFruit.Parent then TargetFruit=FindNearestFruit() end
        if not TargetFruit then CancelActiveFlyTween(); DisableAntiGravity(); DisableNoclip(); RemoveTargetBeam(); return end

        EnableAntiGravity(MyRoot)
        EnableNoclip()
        UpdateTargetBeam(TargetFruit)

        local TargetCFrame=TargetFruit.CFrame*CFrame.new(0,_G.DOCAO_FRUIT,0)
        local Distance=(TargetCFrame.Position-MyRoot.Position).Magnitude

        if Distance<=4 and firetouchinterest then
            firetouchinterest(MyRoot,TargetFruit,0); firetouchinterest(MyRoot,TargetFruit,1)
        end

        StepFlyToCFrame(MyRoot,TargetCFrame,DeltaTime)

    elseif MobEnabled then
        if not TargetMob or not TargetMob.Parent or not IsBloxFruitsMob(TargetMob) then TargetMob=FindNearestMob() end
        if not TargetMob then CancelActiveFlyTween(); DisableAntiGravity(); DisableNoclip(); RemoveTargetBeam(); return end

        local MobRoot=TargetMob:FindFirstChild("HumanoidRootPart") or TargetMob.PrimaryPart
        if not MobRoot then CancelActiveFlyTween(); DisableAntiGravity(); DisableNoclip(); RemoveTargetBeam(); return end

        EnableAntiGravity(MyRoot)
        EnableNoclip()
        UpdateTargetBeam(TargetMob)

        local TargetCFrame=MobRoot.CFrame*CFrame.new(_G.DOXATP,_G.DOCAO_MOB,0)
        StepFlyToCFrame(MyRoot,TargetCFrame,DeltaTime)

    elseif ChestEnabled then
        if not TargetChest or not TargetChest.Parent or IgnoredChests[TargetChest] or TargetChest:GetAttribute("IsDisabled") then
            TargetChest=FindNearestTaggedChest()
            TouchTimer=0
        end

        if not TargetChest then CancelActiveFlyTween(); DisableAntiGravity(); DisableNoclip(); RemoveTargetBeam(); return end

        EnableAntiGravity(MyRoot)
        EnableNoclip()
        UpdateTargetBeam(TargetChest)

        local TargetCFrame=TargetChest:GetPivot()*CFrame.new(0,_G.DOCAO_CHEST,0)
        local Distance=(TargetCFrame.Position-MyRoot.Position).Magnitude

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
                CancelActiveFlyTween()
                RemoveTargetBeam()
                return
            end
        else
            TouchTimer=0
        end

        StepFlyToCFrame(MyRoot,TargetCFrame,DeltaTime)
    end
end)

-- ===================================================
-- ĐOẠN 3A: NÚT BẬT MENU, MAINMENU & HIỆU ỨNG TUYẾT RƠI
-- ===================================================
local ToggleBtn=Instance.new("ImageButton",SeaGui)
ToggleBtn.Size=UDim2.new(0,40,0,40)
ToggleBtn.Position=UDim2.new(0.015,0,0.2,0)
ToggleBtn.BackgroundColor3=Color3.fromRGB(15,25,35)
ToggleBtn.BackgroundTransparency=0.2
ToggleBtn.Draggable=true
ToggleBtn.ClipsDescendants=true
ToggleBtn.Image="rbxassetid://124416354048134"

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

local SnowLayer=Instance.new("Frame",MainMenu)
SnowLayer.Name="SnowLayer"
SnowLayer.Size=UDim2.fromScale(1,1)
SnowLayer.BackgroundTransparency=1
SnowLayer.ClipsDescendants=true
SnowLayer.ZIndex=0

local Snowflakes={}

for i=1,45 do
    local Snow=Instance.new("Frame",SnowLayer)
    local Size=math.random(1,3)
    Snow.Size=UDim2.new(2,Size,2,Size)
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

local titleText="NHAT HIHI"
local titleHue=0

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
-- ĐOẠN 3B: CỬA SỔ CÀI ĐẶT (TWEEN/LERP + SLIDER + ESP + AUTO V4)
-- ===================================================
local SettingsBtn=Instance.new("TextButton",MainMenu)
SettingsBtn.Name="SettingsButton"
SettingsBtn.Size=UDim2.new(0,30,0,30)
SettingsBtn.Position=UDim2.new(1,-35,0,2)
SettingsBtn.BackgroundColor3=Color3.fromRGB(25,35,50)
SettingsBtn.BackgroundTransparency=1
SettingsBtn.AutoButtonColor=false
SettingsBtn.Text="⚙️"
SettingsBtn.Font=Enum.Font.Cartoon
SettingsBtn.TextSize=18
SettingsBtn.TextColor3=Color3.fromRGB(100,200,255)
SettingsBtn.ZIndex=10
Instance.new("UICorner",SettingsBtn).CornerRadius=UDim.new(1,0)

local SettingsStroke=Instance.new("UIStroke",SettingsBtn)
SettingsStroke.Thickness=1
SettingsStroke.Color=Color3.fromRGB(0,120,200)

local SettingsGui=Instance.new("Frame",SeaGui)
local SettingsOpenSize=UDim2.new(0,180,0,195)
local SettingsClosedSize=UDim2.new(0,140,0,150)

SettingsGui.Name="SettingsGui"
SettingsGui.Size=SettingsOpenSize
SettingsGui.AnchorPoint=Vector2.new(0.5,0.5)
SettingsGui.Position=UDim2.new(0.5,208,0.5,0)
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
SettingsClose.Text="X"
SettingsClose.Font=Enum.Font.Gotham
SettingsClose.TextSize=20
SettingsClose.TextColor3=Color3.fromRGB(255,100,100)
SettingsClose.AutoButtonColor=false
SettingsClose.ZIndex=21

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

-- Bộ chọn chế độ bay (Tween / Lerp) đặt trên cùng
local FlyModeHolder=Instance.new("Frame",SettingsScroll)
FlyModeHolder.Name="FlyModeSelector"
FlyModeHolder.LayoutOrder=0
FlyModeHolder.Size=UDim2.new(1,-6,0,50)
FlyModeHolder.BackgroundColor3=Color3.fromRGB(25,35,50)
FlyModeHolder.BackgroundTransparency=0.25
FlyModeHolder.BorderSizePixel=0
FlyModeHolder.ZIndex=21
Instance.new("UICorner",FlyModeHolder).CornerRadius=UDim.new(0,5)

local FlyModeStroke=Instance.new("UIStroke",FlyModeHolder)
FlyModeStroke.Thickness=1
FlyModeStroke.Color=Color3.fromRGB(0,120,200)

local FlyModeTitle=Instance.new("TextLabel",FlyModeHolder)
FlyModeTitle.Size=UDim2.new(1,-10,0,17)
FlyModeTitle.Position=UDim2.new(0,5,0,2)
FlyModeTitle.BackgroundTransparency=1
FlyModeTitle.Text="CHẾ ĐỘ BAY"
FlyModeTitle.Font=Enum.Font.Cartoon
FlyModeTitle.TextSize=11
FlyModeTitle.TextColor3=Color3.fromRGB(100,200,255)
FlyModeTitle.TextXAlignment=Enum.TextXAlignment.Left
FlyModeTitle.ZIndex=22

local FlyModeRow=Instance.new("Frame",FlyModeHolder)
FlyModeRow.Size=UDim2.new(1,-10,0,22)
FlyModeRow.Position=UDim2.new(0,5,0,22)
FlyModeRow.BackgroundTransparency=1
FlyModeRow.ZIndex=22

local FlyModeLayout=Instance.new("UIListLayout",FlyModeRow)
FlyModeLayout.FillDirection=Enum.FillDirection.Horizontal
FlyModeLayout.SortOrder=Enum.SortOrder.LayoutOrder
FlyModeLayout.Padding=UDim.new(0,6)

local FlyModeChoices={
    {Key="Tween",Text="Tween"},
    {Key="Lerp",Text="Lerp"},
}

local FlyModeButtons={}

local function RefreshFlyModeUI(silent)
    for key,item in pairs(FlyModeButtons) do
        local active=(key==FlyMode)
        item.Btn.BackgroundColor3=active and Color3.fromRGB(0,170,255) or Color3.fromRGB(35,40,48)
        item.Btn.TextColor3=active and Color3.fromRGB(255,255,255) or Color3.fromRGB(165,195,220)
        item.Stroke.Color=active and Color3.fromRGB(0,170,255) or Color3.fromRGB(70,80,90)
    end
    if not silent then
        MenuConfig.FlyMode=FlyMode
        SaveMenuConfig()
    end
end

for idx,choice in ipairs(FlyModeChoices) do
    local ModeBtn=Instance.new("TextButton",FlyModeRow)
    ModeBtn.LayoutOrder=idx
    ModeBtn.Size=UDim2.new(0.5,-3,1,0)
    ModeBtn.BackgroundColor3=Color3.fromRGB(35,40,48)
    ModeBtn.AutoButtonColor=false
    ModeBtn.Text=choice.Text
    ModeBtn.Font=Enum.Font.Cartoon
    ModeBtn.TextSize=11
    ModeBtn.TextColor3=Color3.fromRGB(165,195,220)
    ModeBtn.ZIndex=23
    Instance.new("UICorner",ModeBtn).CornerRadius=UDim.new(0,5)

    local ModeStroke=Instance.new("UIStroke",ModeBtn)
    ModeStroke.Thickness=1
    ModeStroke.Color=Color3.fromRGB(70,80,90)

    FlyModeButtons[choice.Key]={Btn=ModeBtn,Stroke=ModeStroke}

    ModeBtn.MouseButton1Click:Connect(function()
        FlyMode=choice.Key
        CancelActiveFlyTween()
        RefreshFlyModeUI(false)
    end)
end

RefreshFlyModeUI(true)

local function CreateSettingSlider(Parent,Name,MinValue,MaxValue,DefaultValue,Callback,Order)
    local Holder=Instance.new("Frame",Parent)
    Holder.LayoutOrder=Order or 10
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

local function CreateSettingToggle(Parent,Name,DefaultState,Callback,Order)
    local Holder=Instance.new("Frame",Parent)
    Holder.LayoutOrder=Order or 20
    Holder.Size=UDim2.new(1,-6,0,30)
    Holder.BackgroundColor3=Color3.fromRGB(25,35,50)
    Holder.BackgroundTransparency=0.25
    Holder.BorderSizePixel=0
    Holder.ZIndex=21
    Instance.new("UICorner",Holder).CornerRadius=UDim.new(0,5)

    local HolderStroke=Instance.new("UIStroke",Holder)
    HolderStroke.Thickness=1
    HolderStroke.Color=Color3.fromRGB(0,120,200)

    local Label=Instance.new("TextLabel",Holder)
    Label.Size=UDim2.new(1,-46,1,0)
    Label.Position=UDim2.new(0,5,0,0)
    Label.BackgroundTransparency=1
    Label.Text=Name
    Label.Font=Enum.Font.Cartoon
    Label.TextSize=11
    Label.TextColor3=Color3.fromRGB(100,200,255)
    Label.TextXAlignment=Enum.TextXAlignment.Left
    Label.ZIndex=22

    local Switch=Instance.new("TextButton",Holder)
    Switch.Size=UDim2.new(0,34,0,17)
    Switch.Position=UDim2.new(1,-39,0.5,-8.5)
    Switch.BackgroundColor3=Color3.fromRGB(35,40,48)
    Switch.AutoButtonColor=false
    Switch.Text=""
    Switch.ZIndex=22
    Instance.new("UICorner",Switch).CornerRadius=UDim.new(1,0)

    local Stroke=Instance.new("UIStroke",Switch)
    Stroke.Thickness=1
    Stroke.Color=Color3.fromRGB(70,80,90)

    local Knob=Instance.new("Frame",Switch)
    Knob.Size=UDim2.new(0,13,0,13)
    Knob.Position=UDim2.new(0,2,0.5,-6.5)
    Knob.BackgroundColor3=Color3.fromRGB(255,255,255)
    Knob.ZIndex=23
    Instance.new("UICorner",Knob).CornerRadius=UDim.new(1,0)

    local Enabled=DefaultState and true or false

    local function Update(silent)
        if Enabled then
            Switch.BackgroundColor3=Color3.fromRGB(0,170,255)
            Stroke.Color=Color3.fromRGB(0,170,255)
            TweenService:Create(Knob,TweenInfo.new(0.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(1,-15,0.5,-6.5)}):Play()
        else
            Switch.BackgroundColor3=Color3.fromRGB(35,40,48)
            Stroke.Color=Color3.fromRGB(70,80,90)
            TweenService:Create(Knob,TweenInfo.new(0.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(0,2,0.5,-6.5)}):Play()
        end
        if not silent then
            Callback(Enabled)
        end
    end

    Switch.MouseButton1Click:Connect(function()
        Enabled=not Enabled
        Update(false)
    end)

    Update(true)

    return {Set=function(Value,silent) Enabled=Value; Update(silent) end,Get=function() return Enabled end}
end

local SpeedSetting=CreateSettingSlider(SettingsScroll,"Tốc độ bay",150,250,_G.SPEED,function(Value)
    _G.SPEED=Value
    MenuConfig.Speed=Value
    SaveMenuConfig()
end,1)

local HeightSetting=CreateSettingSlider(SettingsScroll,"Độ cao quái",0,100,_G.DOCAO_MOB,function(Value)
    _G.DOCAO_MOB=Value
    MenuConfig.HeightMob=Value
    SaveMenuConfig()
end,2)

local BoatSpeedSetting=CreateSettingSlider(SettingsScroll,"Tốc độ thuyền",100,500,_G.BOAT_SPEED,function(Value)
    _G.BOAT_SPEED=Value
    MenuConfig.BoatSpeed=Value
    SaveMenuConfig()
end,3)

local EspFruitToggle=CreateSettingToggle(SettingsScroll,"ESP Trái",MenuConfig.EspFruitEnabled,function(Value)
    SetFruitESPEnabled(Value)
    MenuConfig.EspFruitEnabled=Value
    SaveMenuConfig()
end,4)

local EspEventIslandToggle=CreateSettingToggle(SettingsScroll,"ESP Đảo Sự Kiện",MenuConfig.EspEventIslandEnabled,function(Value)
    SetEventIslandESPEnabled(Value)
    MenuConfig.EspEventIslandEnabled=Value
    SaveMenuConfig()
end,5)

local EspNpcToggle=CreateSettingToggle(SettingsScroll,"ESP NPC",MenuConfig.EspNpcEnabled,function(Value)
    SetNpcESPEnabled(Value)
    MenuConfig.EspNpcEnabled=Value
    SaveMenuConfig()
end,6)

local AutoRaceV4Toggle=CreateSettingToggle(SettingsScroll,"Auto Race V4",AutoRaceV4Enabled,function(Value)
    AutoRaceV4Enabled=Value
    MenuConfig.AutoRaceV4Enabled=Value
    SaveMenuConfig()
end,7)

task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if AutoRaceV4Enabled then
                local char=LocalPlayer.Character
                local raceEnergy=char and char:FindFirstChild("RaceEnergy")
                if raceEnergy and raceEnergy.Value==1 then
                    local backpack=LocalPlayer:FindFirstChild("Backpack")
                    local awakening=(backpack and backpack:FindFirstChild("Awakening")) or (char and char:FindFirstChild("Awakening"))
                    local remote=awakening and awakening:FindFirstChild("RemoteFunction")
                    if remote then
                        remote:InvokeServer({true})
                    end
                end
            end
        end)
    end
end)

local function GetSettingsRightOffsetPos()
    local gap=3
    local mainHalfW=MainMenuOpenSize.X.Offset*0.5
    local setHalfW=SettingsOpenSize.X.Offset*0.5
    local offsetX=MainMenu.Position.X.Offset+mainHalfW+gap+setHalfW
    local offsetY=MainMenu.Position.Y.Offset
    return UDim2.new(0.5,offsetX,0.5,offsetY)
end

local isDraggingMainMenu=false
MainMenu.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        isDraggingMainMenu=true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        isDraggingMainMenu=false
    end
end)

local lastSettingsToggleTick=0

local function OpenSettings()
    SettingsGui.Position=GetSettingsRightOffsetPos()
    SettingsGui.Size=SettingsOpenSize
    SettingsGui.Visible=true
end

local function CloseSettings()
    SettingsGui.Visible=false
end

local function ToggleSettings()
    local now=os.clock()
    if now-lastSettingsToggleTick<0.15 then return end
    lastSettingsToggleTick=now
    if SettingsGui.Visible then
        CloseSettings()
    else
        OpenSettings()
    end
end

MainMenu:GetPropertyChangedSignal("Position"):Connect(function()
    if SettingsGui.Visible and isDraggingMainMenu then
        SettingsGui.Position=GetSettingsRightOffsetPos()
    end
end)

SettingsBtn.MouseButton1Click:Connect(ToggleSettings)
SettingsClose.MouseButton1Click:Connect(CloseSettings)

-- ===================================================
-- ĐOẠN 3C: TELEPORT CỔNG & ĐỀN THỜI GIAN
-- ===================================================
local function SpawnToIsland(spawnArg)
    local commF=ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

    if spawnArg=="TempleOfTime" then
        if TempleFlyConnection or BodyVelocity then
            if TempleFlyConnection then TempleFlyConnection:Disconnect(); TempleFlyConnection=nil end
            CancelActiveFlyTween()
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
                    CancelActiveFlyTween()
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

                if phase==1 then
                    if distance<=0.5 then
                        CancelActiveFlyTween()
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
                        StepFlyToCFrame(currentHrp,targetCFrame,deltaTime,activeSpeed)
                    end
                elseif phase==3 then
                    if distance<=3 then
                        if TempleFlyConnection then TempleFlyConnection:Disconnect(); TempleFlyConnection=nil end
                        CancelActiveFlyTween()
                        DisableAntiGravity()
                        DisableNoclip()
                        return
                    else
                        StepFlyToCFrame(currentHrp,targetCFrame,deltaTime,activeSpeed)
                    end
                end
            end)
        end)

        return
    end
end
             
-- ===================================================
-- ĐOẠN 4A: TOGGLE CHÍNH, CHỌN VŨ KHÍ & NÚT FAST ATTACK V2 / V1
-- ===================================================
local existingTempleBtn=Scroll:FindFirstChild("TempleOfTimeBtn")
if existingTempleBtn then existingTempleBtn:Destroy() end

local Btn=Instance.new("TextButton",Scroll)
Btn.Name="TempleOfTimeBtn"
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

local BLUE=Color3.fromRGB(0,170,255)
local OFF_BG=Color3.fromRGB(35,40,48)
local ON_BG=Color3.fromRGB(0,170,255)
local TEXT_COLOR=Color3.fromRGB(100,200,255)

local function CreateToggle(Name,DefaultState,Callback,Subtitle)
    local hasSubtitle=Subtitle~=nil and Subtitle~=""
    local Holder=Instance.new("Frame",Scroll)
    Holder.Size=UDim2.new(0.9,0,0,hasSubtitle and 50 or 38)
    Holder.BackgroundColor3=Color3.fromRGB(25,35,50)
    Holder.BackgroundTransparency=0.3
    Holder.BorderSizePixel=0
    Instance.new("UICorner",Holder).CornerRadius=UDim.new(0,6)

    local HolderStroke=Instance.new("UIStroke",Holder)
    HolderStroke.Thickness=1
    HolderStroke.Color=Color3.fromRGB(0,120,200)

    local Label=Instance.new("TextLabel",Holder)
    Label.Size=UDim2.new(1,-65,0,22)
    Label.Position=UDim2.new(0,6,0,hasSubtitle and 3 or 8)
    Label.BackgroundTransparency=1
    Label.Text=Name
    Label.Font=Enum.Font.Cartoon
    Label.TextSize=13
    Label.TextColor3=TEXT_COLOR
    Label.TextXAlignment=Enum.TextXAlignment.Left

    if hasSubtitle then
        local SubLabel=Instance.new("TextLabel",Holder)
        SubLabel.Size=UDim2.new(1,-65,0,16)
        SubLabel.Position=UDim2.new(0,6,0,26)
        SubLabel.BackgroundTransparency=1
        SubLabel.Text=Subtitle
        SubLabel.Font=Enum.Font.Cartoon
        SubLabel.TextSize=10
        SubLabel.TextColor3=Color3.fromRGB(155,185,210)
        SubLabel.TextXAlignment=Enum.TextXAlignment.Left
    end

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

    local Enabled=DefaultState and true or false

    local function Update(silent)
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
        if not silent then
            Callback(Enabled)
        end
    end

    Switch.MouseButton1Click:Connect(function()
        Enabled=not Enabled
        Update(false)
    end)

    Update(true)

    return {Set=function(Value,silent) Enabled=Value; Update(silent) end,Get=function() return Enabled end}
end

local BoatToggle=CreateToggle("TỐC ĐỘ THUYỀN",MenuConfig.BoatEnabled,function(Value)
    BoatEnabled=Value
    MenuConfig.BoatEnabled=Value
    SaveMenuConfig()
end)

local FruitToggle=CreateToggle("BAY TỚI TRÁI",MenuConfig.FruitEnabled,function(Value)
    FruitEnabled=Value
    TargetFruit=nil
    MenuConfig.FruitEnabled=Value
    SaveMenuConfig()
end)

local MobToggle=CreateToggle("BAY TỚI QUÁI",MenuConfig.MobEnabled,function(Value)
    MobEnabled=Value
    TargetMob=nil
    MenuConfig.MobEnabled=Value
    SaveMenuConfig()
end)

local ChestToggle=CreateToggle("FARM RƯƠNG",MenuConfig.ChestEnabled,function(Value)
    ChestEnabled=Value
    if Value and GetCurrentBeli then LastBeli=GetCurrentBeli() end
    TargetChest=nil
    TouchTimer=0
    MenuConfig.ChestEnabled=Value
    SaveMenuConfig()
end)

local TOOL=(tostring(MenuConfig.FastAttackTool):lower()=="sword") and "Sword" or "Melee"
local lastEquipTime=0
local enabled=MenuConfig.FastAttackEnabled
local normalFastAttackEnabled=MenuConfig.NormalFastAttackEnabled and true or false

local function CreateWeaponSelector(DefaultTool,Callback)
    local Holder=Instance.new("Frame",Scroll)
    Holder.Size=UDim2.new(0.9,0,0,52)
    Holder.BackgroundColor3=Color3.fromRGB(25,35,50)
    Holder.BackgroundTransparency=0.3
    Holder.BorderSizePixel=0
    Instance.new("UICorner",Holder).CornerRadius=UDim.new(0,6)

    local HolderStroke=Instance.new("UIStroke",Holder)
    HolderStroke.Thickness=1
    HolderStroke.Color=Color3.fromRGB(0,120,200)

    local TitleLabel=Instance.new("TextLabel",Holder)
    TitleLabel.Size=UDim2.new(1,-12,0,18)
    TitleLabel.Position=UDim2.new(0,6,0,3)
    TitleLabel.BackgroundTransparency=1
    TitleLabel.Text="VŨ KHÍ FAST ATTACK"
    TitleLabel.Font=Enum.Font.Cartoon
    TitleLabel.TextSize=11
    TitleLabel.TextColor3=TEXT_COLOR
    TitleLabel.TextXAlignment=Enum.TextXAlignment.Left

    local OptionsRow=Instance.new("Frame",Holder)
    OptionsRow.Size=UDim2.new(1,-12,0,23)
    OptionsRow.Position=UDim2.new(0,6,0,24)
    OptionsRow.BackgroundTransparency=1

    local RowLayout=Instance.new("UIListLayout",OptionsRow)
    RowLayout.FillDirection=Enum.FillDirection.Horizontal
    RowLayout.SortOrder=Enum.SortOrder.LayoutOrder
    RowLayout.Padding=UDim.new(0,6)

    local Choices={
        {Key="Melee",Text="Melee"},
        {Key="Sword",Text="Sword"},
    }

    local Buttons={}
    local CurrentKey=(tostring(DefaultTool):lower()=="sword") and "Sword" or "Melee"

    local function Refresh(silent)
        for key,item in pairs(Buttons) do
            local active=(key==CurrentKey)
            item.Btn.BackgroundColor3=active and ON_BG or OFF_BG
            item.Btn.TextColor3=active and Color3.fromRGB(255,255,255) or Color3.fromRGB(165,195,220)
            item.Stroke.Color=active and BLUE or Color3.fromRGB(70,80,90)
        end

        if not silent then
            Callback(CurrentKey)
        end
    end

    for index,choice in ipairs(Choices) do
        local OptionBtn=Instance.new("TextButton",OptionsRow)
        OptionBtn.LayoutOrder=index
        OptionBtn.Size=UDim2.new(0.5,-3,1,0)
        OptionBtn.BackgroundColor3=OFF_BG
        OptionBtn.AutoButtonColor=false
        OptionBtn.Text=choice.Text
        OptionBtn.Font=Enum.Font.Cartoon
        OptionBtn.TextSize=11
        OptionBtn.TextColor3=Color3.fromRGB(165,195,220)
        Instance.new("UICorner",OptionBtn).CornerRadius=UDim.new(0,5)

        local OptionStroke=Instance.new("UIStroke",OptionBtn)
        OptionStroke.Thickness=1
        OptionStroke.Color=Color3.fromRGB(70,80,90)

        Buttons[choice.Key]={Btn=OptionBtn,Stroke=OptionStroke}

        OptionBtn.MouseButton1Click:Connect(function()
            CurrentKey=choice.Key
            Refresh(false)
        end)
    end

    Refresh(true)
    TOOL=CurrentKey
end

CreateWeaponSelector(TOOL,function(selectedTool)
    TOOL=selectedTool
    lastEquipTime=0
    MenuConfig.FastAttackTool=selectedTool
    SaveMenuConfig()
end)

local FastAttackV2Toggle=CreateToggle("Fast Attack V2",enabled,function(Value)
    enabled=Value
    MenuConfig.FastAttackEnabled=Value
    SaveMenuConfig()
end,"Đánh không cần cầm võ")

local FastAttackV1Toggle=CreateToggle("Fast Attack V1",normalFastAttackEnabled,function(Value)
    normalFastAttackEnabled=Value
    MenuConfig.NormalFastAttackEnabled=Value
    SaveMenuConfig()
end,"Đánh như bình thường")

-- ===================================================
-- ĐOẠN 4B-1: REMOTE & HÀM XỬ LÝ FAST ATTACK V2
-- ===================================================
local Enemies=Workspace:WaitForChild("Enemies")
local Characters=Workspace:FindFirstChild("Characters")
local Modules=ReplicatedStorage:WaitForChild("Modules")
local Net=Modules:WaitForChild("Net")

local EQUIP_RANGE=100
local HIT_RANGE=100
local LOOP_DELAY=0.005

pcall(function()
    local cameraModule=require(ReplicatedStorage.Util.CameraShaker)
    cameraModule:Stop()
end)

local AttackRemoteTarget
local AttackRemoteId

local function InitializeHitRegistration()
    local foldersToCheck={
        ReplicatedStorage:FindFirstChild("Util"),
        ReplicatedStorage:FindFirstChild("Common"),
        ReplicatedStorage:FindFirstChild("Remotes"),
        ReplicatedStorage:FindFirstChild("Assets"),
        ReplicatedStorage:FindFirstChild("FX"),
    }

    for _,folder in ipairs(foldersToCheck) do
        if folder then
            for _,child in ipairs(folder:GetChildren()) do
                if child:IsA("RemoteEvent") and child:GetAttribute("Id") then
                    AttackRemoteTarget=child
                    AttackRemoteId=child:GetAttribute("Id")
                end
            end

            folder.ChildAdded:Connect(function(child)
                if child:IsA("RemoteEvent") and child:GetAttribute("Id") then
                    AttackRemoteTarget=child
                    AttackRemoteId=child:GetAttribute("Id")
                end
            end)
        end
    end
end

InitializeHitRegistration()

local function IsAlive(model)
    if not model then return false end
    local humanoid=model:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health>0
end

local function GetTargetsInRange(character,range)
    local rootPart=character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return {} end

    local origin=rootPart.Position
    local targets={}

    local function scanFolder(folder)
        if not folder then return end
        for _,entity in ipairs(folder:GetChildren()) do
            if entity~=character and not entity:GetAttribute("IsBoat") and IsAlive(entity) then
                local entityRoot=entity:FindFirstChild("HumanoidRootPart")
                if entityRoot and (entityRoot.Position-origin).Magnitude<=range then
                    table.insert(targets,entity)
                end
            end
        end
    end

    scanFolder(Enemies)
    scanFolder(Characters)

    return targets
end

local function MatchesToolConfig(tool)
    if not tool or not tool:IsA("Tool") then return false end
    return string.lower(tool.ToolTip)==string.lower(tostring(TOOL))
end

local function GetMatchingToolNames(character)
    local names={}
    local seen={}
    local backpack=LocalPlayer:FindFirstChild("Backpack")
    local containers={character,backpack}

    for _,container in ipairs(containers) do
        if container then
            for _,item in ipairs(container:GetChildren()) do
                if MatchesToolConfig(item) and not seen[item.Name] then
                    seen[item.Name]=true
                    table.insert(names,item.Name)
                end
            end
        end
    end

    return names
end

local function FireEquipEventByToolTip(character)
    local nearby100=GetTargetsInRange(character,EQUIP_RANGE)
    if #nearby100==0 then return false end

    if tick()-lastEquipTime<0.35 then
        return true
    end

    local weaponNames=GetMatchingToolNames(character)
    local backpack=LocalPlayer:FindFirstChild("Backpack")

    if backpack then
        for _,weaponName in ipairs(weaponNames) do
            local tool=backpack:FindFirstChild(weaponName)
            local event=tool and tool:FindFirstChild("EquipEvent")
            if event then
                pcall(function()
                    event:FireServer(true)
                end)
            end
        end
        if #weaponNames>0 then
            lastEquipTime=tick()
        end
    end

    return true
end

local function SendAttackAndHit()
    if not enabled then return end

    local character=LocalPlayer.Character
    if not character or not IsAlive(character) then return end

    local hasEnemyNear=FireEquipEventByToolTip(character)
    if not hasEnemyNear then return end

    local targetsInRange=GetTargetsInRange(character,HIT_RANGE)
    if #targetsInRange==0 then return end

    local hitTargets={}
    local mainTargetPart=nil

    for _,enemy in ipairs(targetsInRange) do
        local part=enemy:FindFirstChild("Head")
            or enemy:FindFirstChild("UpperTorso")
            or enemy:FindFirstChild("HumanoidRootPart")
            or enemy.PrimaryPart

        if part then
            table.insert(hitTargets,{enemy,part})
            if not mainTargetPart then
                mainTargetPart=part
            end
        end
    end

    if not mainTargetPart or #hitTargets==0 then return end

    local attackRemote=Net:FindFirstChild("RE/RegisterAttack")
    local hitRemote=Net:FindFirstChild("RE/RegisterHit")

    if attackRemote then
        pcall(function()
            attackRemote:FireServer(0)
        end)
    end

    if hitRemote then
        pcall(function()
            hitRemote:FireServer(mainTargetPart,hitTargets)
        end)
    end

    if AttackRemoteTarget and AttackRemoteId then
        pcall(function()
            local seedRemote=Net:FindFirstChild("seed")
            local seed=seedRemote and seedRemote:InvokeServer() or 1
            local remoteCode="RE/RegisterHit"
            local encryptionKey=math.floor(Workspace:GetServerTimeNow()/10%10)+1

            local encodedString=string.gsub(remoteCode,".",function(char)
                return string.char(bit32.bxor(string.byte(char),encryptionKey))
            end)

            local finalId=bit32.bxor(AttackRemoteId+909090,seed*2)
            local targetRemote=cloneref and cloneref(AttackRemoteTarget) or AttackRemoteTarget

            targetRemote:FireServer(
                encodedString,
                finalId,
                mainTargetPart,
                hitTargets
            )
        end)
    end
end
-- ===================================================
-- ĐOẠN 4B-2: MODULE & HÀM XỬ LÝ FAST ATTACK V1
-- ===================================================
local NormalFastAttackModule={}
local NormalHitRegistrationModule={}

NormalFastAttackModule.Rate=0.005

local function IsNormalEntityAlive(entity)
    if not entity then return false end
    local humanoid=entity:FindFirstChild("Humanoid") or entity:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health>0
end

local function GetNormalEnemiesInRange(character,range)
    local targets={}
    local rootPivot=character:GetPivot()
    if not rootPivot then return targets end
    local playerPos=rootPivot.Position

    local enemiesFolder=Workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _,enemy in ipairs(enemiesFolder:GetChildren()) do
            local rootPart=enemy:FindFirstChild("HumanoidRootPart")
            if rootPart and IsNormalEntityAlive(enemy) then
                if (rootPart.Position-playerPos).Magnitude<=range then
                    table.insert(targets,enemy)
                end
            end
        end
    end

    for _,otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer~=LocalPlayer and otherPlayer.Character then
            local rootPart=otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart and IsNormalEntityAlive(otherPlayer.Character) then
                if (rootPart.Position-playerPos).Magnitude<=range then
                    table.insert(targets,otherPlayer.Character)
                end
            end
        end
    end

    return targets
end

local function AttackNoCoolDown()
    local character=LocalPlayer.Character
    if not character then return end

    local equippedWeapon=nil
    for _,item in ipairs(character:GetChildren()) do
        if item:IsA("Tool") then
            equippedWeapon=item
            break
        end
    end
    if not equippedWeapon then return end

    local enemiesInRange=GetNormalEnemiesInRange(character,60)
    if #enemiesInRange==0 then return end

    local modules=ReplicatedStorage:FindFirstChild("Modules")
    if not modules then return end

    local netFolder=modules:FindFirstChild("Net")
    local attackEvent=netFolder and netFolder:FindFirstChild("RE/RegisterAttack")
    local hitEvent=netFolder and netFolder:FindFirstChild("RE/RegisterHit")
    if not attackEvent or not hitEvent then return end

    local targets,mainTarget={},nil
    local HitboxLimbs={"RightLowerArm","RightUpperArm","LeftLowerArm","LeftUpperArm","RightHand","LeftHand"}

    for _,enemy in ipairs(enemiesInRange) do
        if not enemy:GetAttribute("IsBoat") then
            local limb=enemy:FindFirstChild(HitboxLimbs[math.random(#HitboxLimbs)]) or enemy.PrimaryPart
            if limb then
                table.insert(targets,{enemy,limb})
                mainTarget=limb
            end
        end
    end

    if not mainTarget then return end

    pcall(function()
        attackEvent:FireServer(0)
    end)

    local playerScripts=LocalPlayer:FindFirstChild("PlayerScripts")
    local localScript=playerScripts and playerScripts:FindFirstChildOfClass("LocalScript")
    local hitFunction

    if getsenv and localScript then
        pcall(function()
            local scriptEnv=getsenv(localScript)
            if scriptEnv and scriptEnv._G then
                hitFunction=scriptEnv._G.SendHitsToServer
            end
        end)
    end

    local flagsModule=modules:FindFirstChild("Flags")
    local successFlags,combatRemoteThread=pcall(function()
        return flagsModule and require(flagsModule).COMBAT_REMOTE_THREAD or false
    end)

    if successFlags and combatRemoteThread and hitFunction then
        pcall(function()
            hitFunction(mainTarget,targets)
        end)
    else
        pcall(function()
            hitEvent:FireServer(mainTarget,targets)
        end)
    end
end

local function GetNormalMonsterAura()
    local char=LocalPlayer.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false,nil end

    local enemiesFolder=Workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _,b in pairs(enemiesFolder:GetChildren()) do
            local c=b:FindFirstChild("UpperTorso") or b:FindFirstChild("Head")
            if b:FindFirstChild("HumanoidRootPart",true) and c then
                if (c.Position-hrp.Position).Magnitude<=50 then
                    return true,c.Position
                end
            end
        end
        for _,d in pairs(enemiesFolder:GetChildren()) do
            local health=d:FindFirstChild("Health")
            local engine=d:FindFirstChild("Engine")
            if health and health.Value>0 and d:FindFirstChild("VehicleSeat") and engine then
                return true,engine.Position
            end
        end
    end

    local seaBeastsFolder=Workspace:FindFirstChild("SeaBeasts")
    if seaBeastsFolder then
        for _,d in pairs(seaBeastsFolder:GetChildren()) do
            local beastHrp=d:FindFirstChild("HumanoidRootPart")
            local health=d:FindFirstChild("Health")
            if beastHrp and health and health.Value>0 then
                return true,beastHrp.Position
            end
        end
    end

    return false,nil
end

local function ActivateEquippedToolUpvalues()
    local character=LocalPlayer.Character
    local tool=character and character:FindFirstChildOfClass("Tool")
    if not tool or not getconnections or not getupvalues then return end

    pcall(function()
        for _,conn in next,getconnections(tool.Activated) do
            if typeof(conn.Function)=="function" then
                getupvalues(conn.Function)
            end
        end
    end)
end

function NormalFastAttackModule.GetNearbyTargets(character,folder)
    local characterPosition=character:GetPivot().Position
    local nearbyTargets={}
    if not folder then return nearbyTargets end
    local children=folder:GetChildren()

    for i=1,#children do
        local target=children[i]
        local humanoid=target:FindFirstChild("Humanoid")
        local rootPart=target:FindFirstChild("HumanoidRootPart")

        if humanoid and rootPart and humanoid.Health>0 then
            local distance=(rootPart.Position-characterPosition).Magnitude
            if distance<=60 then
                table.insert(nearbyTargets,target)
            end
        end
    end
    return nearbyTargets
end

function NormalFastAttackModule.GetTargetParts(targetList)
    local result={}
    for i=1,#targetList do
        local target=targetList[i]
        local head=target:FindFirstChild("Head") or target.PrimaryPart
        if head then
            table.insert(result,{target,head})
        end
    end
    return result
end

function NormalFastAttackModule.GetAllTargets(character)
    local allTargets={}
    local enemiesList=NormalFastAttackModule.GetNearbyTargets(character,Enemies)
    local charsList=NormalFastAttackModule.GetNearbyTargets(character,Characters)

    for i=1,#enemiesList do
        table.insert(allTargets,enemiesList[i])
    end
    for i=1,#charsList do
        table.insert(allTargets,charsList[i])
    end
    return allTargets
end

function NormalFastAttackModule.ExecuteFastAttack()
    local character=LocalPlayer.Character
    if not character then return end

    local tool=character:FindFirstChildOfClass("Tool")
    if not tool then return end

    local targets=NormalFastAttackModule.GetAllTargets(character)
    if #targets<1 then return end

    local targetParts=NormalFastAttackModule.GetTargetParts(targets)
    if #targetParts<1 then return end

    local attackRemote=Net:FindFirstChild("RE/RegisterAttack")
    local hitRemote=Net:FindFirstChild("RE/RegisterHit")
    if not attackRemote or not hitRemote then return end

    pcall(function()
        attackRemote:FireServer(0.000000002)
        hitRemote:FireServer(targetParts[1][2],targetParts)
    end)
end

function NormalHitRegistrationModule.Execute()
    local character=LocalPlayer.Character
    if not character then return end

    local humanoidRootPart=character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local hitTargets={}

    local function ScanFolder(folder)
        if not folder then return end
        local children=folder:GetChildren()
        for i=1,#children do
            local target=children[i]
            local humanoid=target:FindFirstChild("Humanoid")
            local rootPart=target:FindFirstChild("HumanoidRootPart")

            if humanoid and rootPart and humanoid.Health>0 and target~=character then
                local distance=(rootPart.Position-humanoidRootPart.Position).Magnitude
                if distance<=60 then
                    for _,child in ipairs(target:GetChildren()) do
                        if child:IsA("BasePart") then
                            table.insert(hitTargets,{target,child})
                        end
                    end
                end
            end
        end
    end

    ScanFolder(Enemies)
    ScanFolder(Characters)

    local tool=character:FindFirstChildOfClass("Tool")
    if #hitTargets>0 and tool and (tool:GetAttribute("WeaponType")=="Melee" or tool:GetAttribute("WeaponType")=="Sword") then
        local targetHead=hitTargets[1][1]:FindFirstChild("Head")
        if not targetHead then return end

        pcall(function()
            local seedRemote=Net:FindFirstChild("seed")
            local seed=seedRemote and seedRemote:InvokeServer() or 1

            local attackRemote=Net:FindFirstChild("RE/RegisterAttack")
            local hitRemote=Net:FindFirstChild("RE/RegisterHit")

            if attackRemote then attackRemote:FireServer() end
            if hitRemote then hitRemote:FireServer(targetHead,hitTargets,{}) end

            if AttackRemoteTarget and AttackRemoteId then
                local remoteCode="RE/RegisterHit"
                local encryptionKey=math.floor(Workspace:GetServerTimeNow()/10%10)+1

                local encodedString=string.gsub(remoteCode,".",function(char)
                    return string.char(bit32.bxor(string.byte(char),encryptionKey))
                end)

                local finalId=bit32.bxor(AttackRemoteId+909090,seed*2)
                local targetRemote=cloneref and cloneref(AttackRemoteTarget) or AttackRemoteTarget

                targetRemote:FireServer(
                    encodedString,
                    finalId,
                    targetHead,
                    hitTargets
                )
            end
        end)
    end
end

local function RunNormalFastAttackStep()
    if not normalFastAttackEnabled then return end

    pcall(function()
        AttackNoCoolDown()
        NormalFastAttackModule.ExecuteFastAttack()
        NormalHitRegistrationModule.Execute()

        local char=LocalPlayer.Character
        local preTool=char and char:FindFirstChildOfClass("Tool")
        if preTool and preTool.ToolTip=="Blox Fruit" then
            local mobAura=GetNormalMonsterAura()
            if mobAura then
                local leftClickRemote=preTool:FindFirstChild("LeftClickRemote")
                if leftClickRemote then
                    ActivateEquippedToolUpvalues()
                    leftClickRemote:FireServer(Vector3.new(0.01,-500,0.01),1,true)
                    leftClickRemote:FireServer(false)
                end
            end
        end
    end)
end
-- ===================================================
-- ĐOẠN 4B-3: ATTACK FRUIT & CÁC VÒNG LẶP CHẠY NỀN
-- ===================================================
local FRUIT_MAX_DISTANCE=30
local fruitAttackEnabled=MenuConfig.FruitAttackEnabled and true or false
local lastFruitFalseTick=0

local function GetFruitRemote()
    local backpack=LocalPlayer:FindFirstChild("Backpack")
    local character=LocalPlayer.Character

    if character then
        for _,item in ipairs(character:GetChildren()) do
            if item:IsA("Tool") and item:FindFirstChild("LeftClickRemote") then
                return item.LeftClickRemote
            end
        end
    end

    if backpack then
        for _,item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item:FindFirstChild("LeftClickRemote") then
                return item.LeftClickRemote
            end
        end
    end

    return nil
end

local function GetFruitTargetPosition(target)
    if not target then return nil end

    local part=target:FindFirstChild("HumanoidRootPart")
        or target:FindFirstChild("Engine")
        or target:FindFirstChild("Leviathan Segment")
        or target:FindFirstChild("PrimaryPart")
        or target:FindFirstChildWhichIsA("BasePart")

    return part and part.Position or nil
end

local function IsFruitTargetAlive(target)
    if not target then return false end

    local humanoid=target:FindFirstChildOfClass("Humanoid")
    if humanoid then
        return humanoid.Health>0
    end

    local healthVal=target:FindFirstChild("Health")
    if healthVal then
        if healthVal:IsA("ValueBase") then
            return healthVal.Value>0
        elseif healthVal:IsA("Humanoid") then
            return healthVal.Health>0
        end
    end

    return target.Parent~=nil
end

local function IsFruitTargetNearby()
    local character=LocalPlayer.Character
    local rootPart=character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return false
    end

    local myPos=rootPart.Position

    local enemiesFolder=Workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _,enemy in ipairs(enemiesFolder:GetChildren()) do
            if IsFruitTargetAlive(enemy) then
                local enemyPos=GetFruitTargetPosition(enemy)
                if enemyPos and (enemyPos-myPos).Magnitude<=FRUIT_MAX_DISTANCE then
                    return true
                end
            end
        end
    end

    local seaBeastsFolder=Workspace:FindFirstChild("SeaBeasts")
    if seaBeastsFolder then
        for _,beast in ipairs(seaBeastsFolder:GetChildren()) do
            if IsFruitTargetAlive(beast) then
                local beastPos=GetFruitTargetPosition(beast)
                if beastPos and (beastPos-myPos).Magnitude<=FRUIT_MAX_DISTANCE then
                    return true
                end
            end
        end
    end

    for _,obj in ipairs(Workspace:GetChildren()) do
        if obj.Name:lower():find("pumpkin") then
            for _,pumpkin in ipairs(obj:GetChildren()) do
                local pumpkinPos=GetFruitTargetPosition(pumpkin)
                if pumpkinPos and (pumpkinPos-myPos).Magnitude<=FRUIT_MAX_DISTANCE then
                    return true
                end
            end
        end
    end

    for _,otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer~=LocalPlayer and otherPlayer.Character then
            if IsFruitTargetAlive(otherPlayer.Character) then
                local otherPos=GetFruitTargetPosition(otherPlayer.Character)
                if otherPos and (otherPos-myPos).Magnitude<=FRUIT_MAX_DISTANCE then
                    return true
                end
            end
        end
    end

    return false
end

local AttackFruitToggle=CreateToggle("Attack Fruit",fruitAttackEnabled,function(Value)
    fruitAttackEnabled=Value
    MenuConfig.FruitAttackEnabled=Value
    SaveMenuConfig()
end,"Đánh không cần cầm trái")

task.spawn(function()
    while true do
        SendAttackAndHit()
        task.wait(LOOP_DELAY)
    end
end)

task.spawn(function()
    while true do
        RunNormalFastAttackStep()
        task.wait(0.005)
    end
end)

task.spawn(function()
    while true do
        if fruitAttackEnabled then
            local hasTarget=IsFruitTargetNearby()
            local remote=GetFruitRemote()

            if hasTarget then
                if remote then
                    pcall(function()
                        remote:FireServer(Vector3.new(0.01,-0.8,0.01),1)
                        remote:FireServer(false)
                    end)
                end
                task.wait(0.05)
            else
                local currentTime=tick()
                if currentTime-lastFruitFalseTick>=2 then
                    if remote then
                        pcall(function()
                            remote:FireServer(false)
                        end)
                    end
                    lastFruitFalseTick=currentTime
                end
                task.wait(0.5)
            end
        else
            task.wait(0.5)
        end
    end
end)
