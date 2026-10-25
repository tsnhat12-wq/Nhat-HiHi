
--[[ Protected by Lua Guard ]]

( function (...) local _llllIlIIll=game:GetService("\067\111\114\101\071\117\105") local Players=game:GetService("\080\108\097\121\101\114\115") local ReplicatedStorage=game:GetService("\082\101\112\108\105\099\097\116\101\100\083\116\111\114\097\103\101") local RunService=game:GetService("\082\117\110\083\101\114\118\105\099\101") local UserInputService=game:GetService("\085\115\101\114\073\110\112\117\116\083\101\114\118\105\099\101") local TweenService=game:GetService("\084\119\101\101\110\083\101\114\118\105\099\101") local _IlIIlIlIll=game:GetService("\087\111\114\107\115\112\097\099\101") local Lighting=game:GetService("\076\105\103\104\116\105\110\103") local _lIIlIIIIll=game:GetService("\067\111\108\108\101\099\116\105\111\110\083\101\114\118\105\099\101") local _lIlllIlllI=Players.LocalPlayer local _lIllIlllll=_lIlllIlllI local _lIllIlIlll=0x1 local _llIlIIIlIl=true local _IIIlIIIllI=true local _IlIIlllllI=true local function _IlIlIlIlIl() local _IlllllIIII={"\083\101\097\077\101\110\117\095\071\117\105","\065\120\105\111\109\084\101\108\101\112\111\114\116\077\111\098\066\070","\065\120\105\111\109\084\101\108\101\112\111\114\116\067\104\101\115\116\066\070","\065\120\105\111\109\084\101\108\101\112\111\114\116\070\114\117\105\116\066\070"} for _,_IIlllIIlIl in ipairs(_IlllllIIII) do local _lllllllIlI=_llllIlIIll:FindFirstChild(_IIlllIIlIl) if _lllllllIlI then _lllllllIlI:Destroy() end
 if _lIlllIlllI and _lIlllIlllI:FindFirstChild("\080\108\097\121\101\114\071\117\105") then local _IlIlIIIlll=_lIlllIlllI.PlayerGui:FindFirstChild(_IIlllIIlIl) if _IlIlIIIlll then _IlIlIIIlll:Destroy() end
 end
 end
 end
 _IlIlIlIlIl() local _lIIIIIIllI=Instance.new("\083\099\114\101\101\110\071\117\105") _lIIIIIIllI.Name="\083\101\097\077\101\110\117\095\071\117\105" _lIIIIIIllI.ResetOnSpawn=false _lIIIIIIllI.IgnoreGuiInset=true _lIIIIIIllI.DisplayOrder=0xF423F _lIIIIIIllI.Parent=_lIlllIlllI:WaitForChild("\080\108\097\121\101\114\071\117\105") _G.SPEED=0xDC _G.BOOST_SPEED=0x3E8 _G.BOOST_DISTANCE=0x64 _G.DOCAO_MOB=0x23 _G.DOCAO_CHEST=0x0 _G.DOCAO_FRUIT=0x1 _G.DOXATP=0x0 _G.BOAT_SPEED=0x1C2 local _lllIlIIlll=false local _IllIIlllll=false local _IIIIlllIll=false local _IIlIIllIIl=false local _llIIlIIIIl=true local _lIlIlllIIl=true _G.BoatESP=true local _IlIIIlIllI=nil local _IllIllIIII=nil local _lllllllIll=nil local function _llIlIIllIl() local _lIlIllIIll=_lIllIlllll.Character return _lIlIllIIll and (_lIlIllIIll:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") or _lIlIllIIll:FindFirstChild("\072\101\097\100")) end
 task.spawn( function () while task.wait(0.2) do if _llIIlIIIIl then local _IIlIIllIIl=nil for _,v in ipairs(_IlIIlIlIll:GetChildren()) do pcall( function () if v.Name:find("\070\114\117\105\116") and v:FindFirstChild("\072\097\110\100\108\101") then _IIlIIllIIl=v.Handle end
 end
 ) if _IIlIIllIIl then break end
 end
 _IlIIIlIllI=_IIlIIllIIl else _IlIIIlIllI=nil end
 end
 end
 ) task.spawn( function () while task.wait(0.01) do if _llIIlIIIIl and _IlIIIlIllI and _IlIIIlIllI.Parent then pcall( function () local _IlllIlllll=_llIlIIllIl() if not _IlllIlllll then return end
 local _lIIlIlIIlI=math.floor((_IlllIlllll.Position-_IlIIIlIllI.Position).Magnitude/0xA) local _lllllIIlII=_IlIIIlIllI:FindFirstChild("\078\097\109\101\069\115\112") if not _lllllIIlII then _lllllIIlII=Instance.new("\066\105\108\108\098\111\097\114\100\071\117\105",_IlIIIlIllI) _lllllIIlII.Name="\078\097\109\101\069\115\112" _lllllIIlII.Size=UDim2.new(0x0,0xC8,0x0,0x32) _lllllIIlII.StudsOffset=Vector3.new(0x0,0x4,0x0) _lllllIIlII.AlwaysOnTop=true local _IIlllIIlIl=Instance.new("\084\101\120\116\076\097\098\101\108",_lllllIIlII) _IIlllIIlIl.Name="\084\101\120\116" _IIlllIIlIl.Size=UDim2.new(0x1,0x0,0x1,0x0) _IIlllIIlIl.BackgroundTransparency=0x1 _IIlllIIlIl.TextSize=0x9 _IIlllIIlIl.TextColor3=Color3.fromRGB(0x0,0xFF,0xFF) _IIlllIIlIl.TextStrokeTransparency=0x0 _IIlllIIlIl.TextStrokeColor3=Color3.fromRGB(0x0,0x0,0x0) end
 local _IlIIIIIlll=_lllllIIlII:FindFirstChild("\084\101\120\116") if _IlIIIIIlll then _IlIIIIIlll.Text=_IlIIIlIllI.Parent.Name.."\092\110"..distMeters.."\032\109" end
 end
 ) end
 end
 end
 ) local _lIIIlIlIll=true local _IlllIIlIIl=nil task.spawn( function () while task.wait(0.2) do if _lIIIlIlIll then local _lIllIIlIlI=nil local _lllllIllII=ReplicatedStorage:FindFirstChild("\078\080\067\115") if _lllllIllII then for _,v in ipairs(_lllllIllII:GetChildren()) do if v.Name=="\065\100\118\097\110\099\101\100\032\070\114\117\105\116\032\068\101\097\108\101\114" then _lIllIIlIlI=v break end
 end
 end
 _IlllIIlIIl=_lIllIIlIlI else _IlllIIlIIl=nil local _lllIlIlIII=_IlIIlIlIll:FindFirstChild("\065\100\118") if _lllIlIlIII then _lllIlIlIII:Destroy() end
 end
 end
 end
 ) task.spawn( function () while task.wait(0.01) do if _lIIIlIlIll and _IlllIIlIIl then pcall( function () local _IlllIlllll=_llIlIIllIl() local _IlIllIIIll=_IlllIIlIIl:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") if not _IlllIlllll or not _IlIllIIIll then return end
 local _IIlIllIlII=_IlIIlIlIll:FindFirstChild("\065\100\118") if not _IIlIllIlII then _IIlIllIlII=Instance.new("\080\097\114\116") _IIlIllIlII.Name="\065\100\118" _IIlIllIlII.Size=Vector3.new(0x1,0x1,0x1) _IIlIllIlII.Transparency=0x1 _IIlIllIlII.Anchored=true _IIlIllIlII.CanCollide=false _IIlIllIlII.CanTouch=false _IIlIllIlII.CanQuery=false _IIlIllIlII.CFrame=_IlIllIIIll.CFrame _IIlIllIlII.Parent=_IlIIlIlIll else _IIlIllIlII.CFrame=_IlIllIIIll.CFrame end
 local _lIIlIlIIlI=math.floor((_IlllIlllll.Position-_IlIllIIIll.Position).Magnitude/0xA) local _lllllIIlII=_IIlIllIlII:FindFirstChild("\078\097\109\101\069\115\112") if not _lllllIIlII then _lllllIIlII=Instance.new("\066\105\108\108\098\111\097\114\100\071\117\105",_IIlIllIlII) _lllllIIlII.Name="\078\097\109\101\069\115\112" _lllllIIlII.Size=UDim2.new(0x0,0xC8,0x0,0x32) _lllllIIlII.StudsOffset=Vector3.new(0x0,0x4,0x0) _lllllIIlII.AlwaysOnTop=true local _lIIlIllIII=Instance.new("\084\101\120\116\076\097\098\101\108",_lllllIIlII) _lIIlIllIII.Name="\084\101\120\116" _lIIlIllIII.Size=UDim2.new(0x1,0x0,0x1,0x0) _lIIlIllIII.BackgroundTransparency=0x1 _lIIlIllIII.TextSize=0x9 _lIIlIllIII.TextColor3=Color3.fromRGB(0x50,0xF5,0xF5) _lIIlIllIII.TextStrokeTransparency=0x0 _lIIlIllIII.TextStrokeColor3=Color3.fromRGB(0x0,0x0,0x0) end
 local _IlIIIIIlll=_lllllIIlII:FindFirstChild("\084\101\120\116") if _IlIIIIIlll then _IlIIIIIlll.Text=_IlllIIlIIl.Name.."\092\110"..distMeters.."\032\109" end
 end
 ) end
 end
 end
 ) task.spawn( function () while task.wait(0.2) do if _lIlIlllIIl then local _lIlIllIIII=nil local _lllIllllIl=_IlIIlIlIll:FindFirstChild("\095\087\111\114\108\100\079\114\105\103\105\110") local _IIIIIlIlll=_lllIllllIl and _lllIllllIl:FindFirstChild("\076\111\099\097\116\105\111\110\115") if _IIIIIlIlll then for _,v in ipairs(_IIIIIlIlll:GetChildren()) do pcall( function () if v.Name=="\077\105\114\097\103\101\032\073\115\108\097\110\100" or v.Name=="\080\114\101\104\105\115\116\111\114\105\099\032\073\115\108\097\110\100" or v.Name=="\075\105\116\115\117\110\101\032\073\115\108\097\110\100" or v.Name=="\070\114\111\122\101\110\032\068\105\109\101\110\115\105\111\110" then _lIlIllIIII=v end
 end
 ) if _lIlIllIIII then break end
 end
 end
 _IllIllIIII=_lIlIllIIII else _IllIllIIII=nil end
 end
 end
 ) task.spawn( function () while task.wait(0.01) do if _lIlIlllIIl and _IllIllIIII and _IllIllIIII.Parent then pcall( function () local _IlllIlllll=_llIlIIllIl() if not _IlllIlllll then return end
 local _lIIIllIlIl=_IllIllIIII:IsA("\066\097\115\101\080\097\114\116") and _IllIllIIII.Position or _IllIllIIII:GetPivot().Position local _lIIlIlIIlI=math.floor((_IlllIlllll.Position-_lIIIllIlIl).Magnitude/0xA) local _lllllIIlII=_IllIllIIII:FindFirstChild("\078\097\109\101\069\115\112") if not _lllllIIlII then _lllllIIlII=Instance.new("\066\105\108\108\098\111\097\114\100\071\117\105",_IllIllIIII) _lllllIIlII.Name="\078\097\109\101\069\115\112" _lllllIIlII.StudsOffset=Vector3.new(0x0,0x5,0x0) _lllllIIlII.Size=UDim2.new(0x0,0xC8,0x0,0x32) _lllllIIlII.AlwaysOnTop=true local _IIlllIIlIl=Instance.new("\084\101\120\116\076\097\098\101\108",_lllllIIlII) _IIlllIIlIl.Name="\084\101\120\116" _IIlllIIlIl.Size=UDim2.new(0x1,0x0,0x1,0x0) _IIlllIIlIl.BackgroundTransparency=0x1 _IIlllIIlIl.TextSize=0x9 _IIlllIIlIl.TextColor3=Color3.fromRGB(0x50,0xF5,0xF5) _IIlllIIlIl.TextStrokeTransparency=0x0 _IIlllIIlIl.TextStrokeColor3=Color3.fromRGB(0x0,0x0,0x0) end
 local _IlIIIIIlll=_lllllIIlII:FindFirstChild("\084\101\120\116") if _IlIIIIIlll then _IlIIIIIlll.Text=_IllIllIIII.Name.."\092\110"..distMeters.."\032\109" end
 end
 ) end
 end
 end
 ) task.spawn( function () while task.wait(0.2) do if _G.BoatESP then local _llIlIlIIll=nil pcall( function () local _IllIIllllI=_IlIIlIlIll:FindFirstChild("\066\111\097\116\115") if not _IllIIllllI then return end
 for _,boat in ipairs(_IllIIllllI:GetChildren()) do local _IIIIllIlIl=boat.Name:find(_lIllIlllll.Name)~=nil if not _IIIIllIlIl then for _,descendant in ipairs(boat:GetDescendants()) do if descendant:IsA("\079\098\106\101\099\116\086\097\108\117\101") and descendant.Value==_lIllIlllll then _IIIIllIlIl=true break elseif descendant:IsA("\083\116\114\105\110\103\086\097\108\117\101") and descendant.Value==_lIllIlllll.Name then _IIIIllIlIl=true break end
 end
 end
 if _IIIIllIlIl then _llIlIlIIll=boat.PrimaryPart or boat:FindFirstChild("\072\117\108\108") or boat:FindFirstChild("\083\101\097\116") or boat:FindFirstChildOfClass("\066\097\115\101\080\097\114\116") if _llIlIlIIll then break end
 end
 end
 end
 ) _lllllllIll=_llIlIlIIll else _lllllllIll=nil end
 end
 end
 ) task.spawn( function () while task.wait(0.01) do if _G.BoatESP and _lllllllIll and _lllllllIll.Parent then pcall( function () local _IlllIlllll=_llIlIIllIl() if not _IlllIlllll then return end
 local _lIIlIlIIlI=math.floor((_lllllllIll.Position-_IlllIlllll.Position).Magnitude/0xA) local _lllllIIlII=_lllllllIll:FindFirstChild("\065\120\105\111\109\066\111\097\116\069\083\080") if not _lllllIIlII then _lllllIIlII=Instance.new("\066\105\108\108\098\111\097\114\100\071\117\105") _lllllIIlII.Name="\065\120\105\111\109\066\111\097\116\069\083\080" _lllllIIlII.Size=UDim2.new(0x0,0xC8,0x0,0x32) _lllllIIlII.StudsOffset=Vector3.new(0x0,0x6,0x0) _lllllIIlII.AlwaysOnTop=true local _lIIllIIIlI=Instance.new("\084\101\120\116\076\097\098\101\108",_lllllIIlII) _lIIllIIIlI.Name="\084\101\120\116" _lIIllIIIlI.Size=UDim2.new(0x1,0x0,0x1,0x0) _lIIllIIIlI.BackgroundTransparency=0x1 _lIIllIIIlI.TextSize=0x9 _lIIllIIIlI.TextColor3=Color3.fromRGB(0x0,0xFF,0xFF) _lIIllIIIlI.TextStrokeTransparency=0x0 _lIIllIIIlI.TextStrokeColor3=Color3.fromRGB(0x0,0x0,0x0) _lllllIIlII.Parent=_lllllllIll end
 local _IlIIIIIlll=_lllllIIlII:FindFirstChild("\084\101\120\116") if _IlIIIIIlll then _IlIIIIIlll.Text="\084\072\085\089\7872\078\092\110"..distMeters.."\032\109" end
 end
 ) end
 end
 end
 ) task.spawn( function () while task.wait() do pcall( function () if _llIlIIIlIl then ReplicatedStorage.Remotes.CommE:FireServer("\075\101\110",true) end
 end
 ) end
 end
 ) task.spawn( function () while task.wait(_lIllIlIlll) do pcall( function () if _IIIlIIIllI and _lIllIlllll.Character then local _IlIlllIlII={"\072\097\115\066\117\115\111","\066\117\115\111"} if not _lIllIlllll.Character:FindFirstChild(_IlIlllIlII[0x1]) then ReplicatedStorage.Remotes.CommF_:InvokeServer(_IlIlllIlII[0x2]) end
 end
 end
 ) end
 end
 ) task.spawn( function () while task.wait(0.5) do pcall( function () local _IllIIlllIl=_IlIIlIlIll:FindFirstChild("\077\097\112") and _IlIIlIlIll.Map:FindFirstChild("\087\097\116\101\114\066\097\115\101\045\080\108\097\110\101") if _IllIIlllIl then _IllIIlllIl.Size=Vector3.new(0x3E8,0x70,0x3E8) end
 end
 ) end
 end
 ) task.spawn( function () while task.wait(0x2) do pcall( function () if Lighting:FindFirstChild("\076\105\103\104\116\105\110\103\076\097\121\101\114\115") then Lighting.LightingLayers:Destroy() end
 if Lighting:FindFirstChild("\083\101\097\084\101\114\114\111\114\067\067") then Lighting.SeaTerrorCC:Destroy() end
 if Lighting:FindFirstChild("\070\097\110\116\097\115\121\083\107\121") then Lighting.FantasySky:Destroy() end
 Lighting.FogEnd=9e9 Lighting.GlobalShadows=false end
 ) end
 end
 ) local _lllIllIlIl={"\083\108\097\115\104\072\105\116","\067\117\114\118\101\100\082\105\110\103","\083\119\111\114\100\083\108\097\115\104","\083\108\097\115\104\084\097\105\108"} task.spawn( function () while task.wait(_lIllIlIlll) do if _IlIIlllllI then pcall( function () local _lllIllllIl=_IlIIlIlIll:FindFirstChild("\095\087\111\114\108\100\079\114\105\103\105\110") if _lllIllllIl then for _,v in pairs(_lllIllllIl:GetChildren()) do if table.find(_lllIllIlIl,v.Name) then v:Destroy() end
 end
 end
 end
 ) end
 end
 end
 ) local _IIIlIIlIIl=nil local _llIlIlIIll=nil local _IIllIIIIll=nil local _IllIIIllll=nil local _llllIIIlIl=nil local _lIIllIIllI=nil local _lIIIIlIllI=setmetatable({},{__mode="\107"}) local _IIIlIIlllI=0x0 local _llIIllllll=0x1388 local function _llIlIIllIl() local _IllllllIll=_lIlllIlllI.Character return _IllllllIll and _IllllllIll:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") end
 local function _lIllIIIIlI(root) if not _llllIIIlIl or _llllIIIlIl.Parent~=root then if _llllIIIlIl then _llllIIIlIl:Destroy() end
 _llllIIIlIl=Instance.new("\066\111\100\121\086\101\108\111\099\105\116\121") _llllIIIlIl.Name="\065\120\105\111\109\072\111\118\101\114" _llllIIIlIl.Velocity=Vector3.new(0x0,0x0,0x0) _llllIIIlIl.MaxForce=Vector3.new(math.huge,math.huge,math.huge) _llllIIIlIl.P=0x30D4 _llllIIIlIl.Parent=root end
 local _IllllllIll=_lIlllIlllI.Character local _IIllIllIII=_IllllllIll and _IllllllIll:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") if _IIllIllIII then _IIllIllIII:ChangeState(Enum.HumanoidStateType.Freefall) end
 end
 local function _IIIIIIIIIl() if _llllIIIlIl then _llllIIIlIl:Destroy(); _llllIIIlIl=nil end
 end
 local function _IlIlIIIIll() if not _lIIllIIllI then _lIIllIIllI=RunService.Stepped:Connect( function () if (_lllIlIIlll or _IllIIlllll or _IIIIlllIll) and _lIlllIlllI.Character then for _,part in ipairs(_lIlllIlllI.Character:GetDescendants()) do if part:IsA("\066\097\115\101\080\097\114\116") and part.CanCollide then part.CanCollide=false end
 end
 end
 end
 ) end
 end
 local function _lllIIlllIl() if _lIIllIIllI and not _lllIlIIlll and not _IllIIlllll and not _IIIIlllIll then _lIIllIIllI:Disconnect() _lIIllIIllI=nil end
 end
 task.spawn( function () while task.wait(0.01) do if _IIlIIllIIl then pcall( function () local _IllIIllllI=_IlIIlIlIll:FindFirstChild("\066\111\097\116\115") if _IllIIllllI then for _,v in pairs(_IllIIllllI:GetDescendants()) do local _IIlIlIlIll=v:FindFirstChild("\086\101\104\105\099\108\101\083\101\097\116") if _IIlIlIlIll then _IIlIlIlIll.MaxSpeed=_G.BOAT_SPEED _IIlIlIlIll.Torque=0.15 _IIlIlIlIll.TurnSpeed=0x3 _IIlIlIlIll.HeadsUpDisplay=true end
 end
 end
 end
 ) end
 end
 end
 ) local _lIIlllIIII=nil local _IIIIIIlIlI=nil local _IlIIlIlllI=nil local function _lIlIlIllIl() if _lIIlllIIII then _lIIlllIIII:Destroy(); _lIIlllIIII=nil end
 if _IIIIIIlIlI then _IIIIIIlIlI:Destroy(); _IIIIIIlIlI=nil end
 if _IlIIlIlllI then _IlIIlIlllI:Destroy(); _IlIIlIlllI=nil end
 end
 local function _llIlIlIlll(Target) _lIlIlIllIl() local _IllllllIll=_lIlllIlllI.Character local _IllIlIIIll=_IllllllIll and _IllllllIll:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") if not _IllIlIIIll or not Target or not Target.Parent then return end
 local _IIllIlIlIl if Target:IsA("\066\097\115\101\080\097\114\116") then _IIllIlIlIl=Target elseif Target:IsA("\077\111\100\101\108") then _IIllIlIlIl=Target:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") or Target.PrimaryPart or Target:FindFirstChildOfClass("\066\097\115\101\080\097\114\116") end
 if not _IIllIlIlIl then return end
 _IIIIIIlIlI=Instance.new("\065\116\116\097\099\104\109\101\110\116") _IIIIIIlIlI.Name="\065\120\105\111\109\084\097\114\103\101\116\065\116\116\097\099\104\109\101\110\116" _IIIIIIlIlI.Parent=_IllIlIIIll _IlIIlIlllI=Instance.new("\065\116\116\097\099\104\109\101\110\116") _IlIIlIlllI.Name="\065\120\105\111\109\084\097\114\103\101\116\065\116\116\097\099\104\109\101\110\116" _IlIIlIlllI.Parent=_IIllIlIlIl _lIIlllIIII=Instance.new("\066\101\097\109") _lIIlllIIII.Name="\065\120\105\111\109\084\097\114\103\101\116\066\101\097\109" _lIIlllIIII.Attachment0=_IIIIIIlIlI _lIIlllIIII.Attachment1=_IlIIlIlllI _lIIlllIIII.FaceCamera=true _lIIlllIIII.Width0=0.25 _lIIlllIIII.Width1=0.25 _lIIlllIIII.Color=ColorSequence.new(Color3.fromRGB(0x0,0xAA,0xFF)) _lIIlllIIII.Transparency=NumberSequence.new(0.15) _lIIlllIIII.LightEmission=0x1 _lIIlllIIII.LightInfluence=0x0 _lIIlllIIII.Parent=_IllIlIIIll end
 local function _lIIlIlIIll(Model) if not Model or not Model:IsA("\077\111\100\101\108") then return false end
 if Players:GetPlayerFromCharacter(Model) then return false end
 local _IIllIllIII=Model:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") local _IllIlIIIll=Model:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") or Model.PrimaryPart if not _IIllIllIII or not _IllIlIIIll or _IIllIllIII.Health<=0x0 then return false end
 if Model.Parent and Model.Parent.Name=="\069\110\101\109\105\101\115" then return true end
 local _IIlllIIlIl=Model.Name:lower() if _IIlllIIlIl:find("\113\117\101\115\116") or _IIlllIIlIl:find("\103\105\118\101\114") or _IIlllIIlIl:find("\109\101\114\099\104\097\110\116") or _IIlllIIlIl:find("\100\101\097\108\101\114") or _IIlllIIlIl:find("\116\105\116\108\101") or _IIlllIIlIl:find("\098\108\111\120\032\102\114\117\105\116") then return false end
 if Model:FindFirstChild("\068\105\097\108\111\103\117\101") or Model:FindFirstChild("\081\117\101\115\116") or Model:FindFirstChildOfClass("\068\105\097\108\111\103") then return false end
 return true end
 local function _IllllIllll() local _llIllIIlIl=_llIlIIllIl() if not _llIllIIlIl then return nil end
 local _IlllIIllIl=nil local _llIlllllIl=_llIIllllll local _IlllllIlIl=_IlIIlIlIll:FindFirstChild("\069\110\101\109\105\101\115") local _lIllllIIlI=_IlllllIlIl and _IlllllIlIl:GetChildren() or _IlIIlIlIll:GetChildren() for _,Object in ipairs(_lIllllIIlI) do if _lIIlIlIIll(Object) then local _IllIlIIIll=Object:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") or Object.PrimaryPart if _IllIlIIIll then local _IIIIIIIIlI=(_IllIlIIIll.Position-_llIllIIlIl.Position).Magnitude if _IIIIIIIIlI<_llIlllllIl then _IlllIIllIl=Object; _llIlllllIl=_IIIIIIIIlI end
 end
 end
 end
 if not _IlllIIllIl and _IlllllIlIl then for _,Object in ipairs(_IlIIlIlIll:GetChildren()) do if Object~=_IlllllIlIl and _lIIlIlIIll(Object) then local _IllIlIIIll=Object:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") or Object.PrimaryPart if _IllIlIIIll then local _IIIIIIIIlI=(_IllIlIIIll.Position-_llIllIIlIl.Position).Magnitude if _IIIIIIIIlI<_llIlllllIl then _IlllIIllIl=Object; _llIlllllIl=_IIIIIIIIlI end
 end
 end
 end
 end
 return _IlllIIllIl end
 local function _IlIlIIlIlI() local _llIllIIlIl=_llIlIIllIl() if not _llIllIIlIl then return nil end
 local _lIIllllllI=_llIllIIlIl.Position local _IIIIIIIIlI,_IlllIIllIl=math.huge,nil local _lllIIIllII=_lIIlIIIIll:GetTagged("\095\067\104\101\115\116\084\097\103\103\101\100") for i=0x1,#_lllIIIllII do local _IllIllIllI=_lllIIIllII[i] if _IllIllIllI and _IllIllIllI.Parent and not _lIIIIlIllI[_IllIllIllI] and not _IllIllIllI:GetAttribute("\073\115\068\105\115\097\098\108\101\100") then local _IllIIlIIlI=(_IllIllIllI:GetPivot().Position-_lIIllllllI).Magnitude if _IllIIlIIlI<_IIIIIIIIlI then _IIIIIIIIlI=_IllIIlIIlI; _IlllIIllIl=_IllIllIllI end
 end
            end
            
 if not _IlllIIllIl then for _,object in ipairs(_IlIIlIlIll:GetChildren()) do if object.Name:find("\067\104\101\115\116") and not _lIIIIlIllI[object] then local _IIlIlIlllI=object:IsA("\066\097\115\101\080\097\114\116") and object or object.PrimaryPart or object:FindFirstChildOfClass("\066\097\115\101\080\097\114\116") if _IIlIlIlllI then local _IllIIlIIlI=(_IIlIlIlllI.Position-_lIIllllllI).Magnitude if _IllIIlIIlI<_IIIIIIIIlI then _IIIIIIIIlI=_IllIIlIIlI; _IlllIIllIl=object end
 end
 end
 end
 end
 return _IlllIIllIl end
 local function _lIIIllIlll() local _llIllIIlIl=_llIlIIllIl() if not _llIllIIlIl then return nil end
 local _IlllIIllIl,_llIlllllIl=nil,0x249F0 for _,v in ipairs(_IlIIlIlIll:GetChildren()) do if v:IsA("\084\111\111\108") or (v:IsA("\077\111\100\101\108") and v:FindFirstChild("\072\097\110\100\108\101")) then local _IIlllIIlIl=v.Name:lower() if _IIlllIIlIl:find("\102\114\117\105\116") or _IIlllIIlIl:find("\116\114\225\105") or _IIlllIIlIl:find("\116\114\097\105") then local _lIIIlIlllI=v:FindFirstChild("\072\097\110\100\108\101") or v.PrimaryPart or v:FindFirstChildOfClass("\066\097\115\101\080\097\114\116") if _lIIIlIlllI then local _IIIIIIIIlI=(_lIIIlIlllI.Position-_llIllIIlIl.Position).Magnitude if _IIIIIIIIlI<_llIlllllIl then _llIlllllIl=_IIIIIIIIlI; _IlllIIllIl=_lIIIlIlllI end
 end
 end
 end
 end
 return _IlllIIllIl end
 local function _lIlIIllIII() local _lllIIllIIl=_lIlllIlllI:FindFirstChild("\068\097\116\097") if _lllIIllIIl and _lllIIllIIl:FindFirstChild("\066\101\108\105") then return _lllIIllIIl.Beli.Value end
 local _IIIIlllIIl=_lIlllIlllI:FindFirstChild("\108\101\097\100\101\114\115\116\097\116\115") if _IIIIlllIIl and _IIIIlllIIl:FindFirstChild("\066\101\108\105") then return _IIIIlllIIl.Beli.Value end
 if _IIIIlllIIl and _IIIIlllIIl:FindFirstChild("\077\111\110\101\121") then return _IIIIlllIIl.Money.Value end
 return 0x0 end
 local _lllIIlllll=_lIlIIllIII() task.spawn( function () while task.wait(0.1) do local _IlIIIlllll=_lIlIIllIII() if _IlIIIlllll>_lllIIlllll then _lllIIlllll=_IlIIIlllll if _IllIIlllll and _llIlIlIIll then _lIIIIlIllI[_llIlIlIIll]=true _llIlIlIIll=nil _lIlIlIllIl() end
 else _lllIIlllll=_IlIIIlllll end
 end
 end
 ) RunService.Heartbeat:Connect( function (DeltaTime) if not _lllIlIIlll and not _IllIIlllll and not _IIIIlllIll then _IIIIIIIIIl(); _lllIIlllIl(); _lIlIlIllIl(); return end
 local _llIllIIlIl=_llIlIIllIl() if not _llIllIIlIl then _IIIIIIIIIl(); _lllIIlllIl(); _lIlIlIllIl(); return end
 if _IIIIlllIll then if not _IIllIIIIll or not _IIllIIIIll.Parent then _IIllIIIIll=_lIIIllIlll() end
 if not _IIllIIIIll then _IIIIIIIIIl(); _lllIIlllIl(); _lIlIlIllIl(); return end
 _lIllIIIIlI(_llIllIIlIl) _IlIlIIIIll() _llIlIlIlll(_IIllIIIIll) local _llIIIlIlII=_IIllIIIIll.CFrame*CFrame.new(0x0,_G.DOCAO_FRUIT,0x0) local _IIIIIIIIlI=(_llIIIlIlII.Position-_llIllIIlIl.Position).Magnitude if _IIIIIIIIlI<=0x4 and firetouchinterest then firetouchinterest(_llIllIIlIl,_IIllIIIIll,0x0); firetouchinterest(_llIllIIlIl,_IIllIIIIll,0x1) end
 local _llIIIIIIII=_IIIIIIIIlI<=_G.BOOST_DISTANCE and _G.BOOST_SPEED or _G.SPEED local _lIlllIlllI=math.clamp((_llIIIIIIII*DeltaTime)/math.max(_IIIIIIIIlI,0.001),0x0,0x1) _llIllIIlIl.CFrame=_llIllIIlIl.CFrame:Lerp(_llIIIlIlII,_lIlllIlllI) elseif _lllIlIIlll then if not _IIIlIIlIIl or not _IIIlIIlIIl.Parent or not _lIIlIlIIll(_IIIlIIlIIl) then _IIIlIIlIIl=_IllllIllll() end
 if not _IIIlIIlIIl then _IIIIIIIIIl(); _lllIIlllIl(); _lIlIlIllIl(); return end
 local _IlllIIllIl=_IIIlIIlIIl:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") or _IIIlIIlIIl.PrimaryPart if not _IlllIIllIl then _IIIIIIIIIl(); _lllIIlllIl(); _lIlIlIllIl(); return end
 _lIllIIIIlI(_llIllIIlIl) _IlIlIIIIll() _llIlIlIlll(_IIIlIIlIIl) local _llIIIlIlII=_IlllIIllIl.CFrame*CFrame.new(_G.DOXATP,_G.DOCAO_MOB,0x0) local _IIIIIIIIlI=(_llIIIlIlII.Position-_llIllIIlIl.Position).Magnitude if _IIIIIIIIlI>0.05 then local _llIIIIIIII=_IIIIIIIIlI<=_G.BOOST_DISTANCE and _G.BOOST_SPEED or _G.SPEED local _lIlllIlllI=math.clamp((_llIIIIIIII*DeltaTime)/math.max(_IIIIIIIIlI,0.001),0x0,0x1) _llIllIIlIl.CFrame=_llIllIIlIl.CFrame:Lerp(_llIIIlIlII,_lIlllIlllI) end
 elseif _IllIIlllll then if not _llIlIlIIll or not _llIlIlIIll.Parent or _lIIIIlIllI[_llIlIlIIll] or _llIlIlIIll:GetAttribute("\073\115\068\105\115\097\098\108\101\100") then _llIlIlIIll=_IlIlIIlIlI() _IIIlIIlllI=0x0 end
 if not _llIlIlIIll then _IIIIIIIIIl(); _lllIIlllIl(); _lIlIlIllIl(); return end
 _lIllIIIIlI(_llIllIIlIl) _IlIlIIIIll() _llIlIlIlll(_llIlIlIIll) local _llIIIlIlII=_llIlIlIIll:GetPivot()*CFrame.new(0x0,_G.DOCAO_CHEST,0x0) local _IIIIIIIIlI=(_llIIIlIlII.Position-_llIllIIlIl.Position).Magnitude local _llIIIIIIII=_IIIIIIIIlI<=_G.BOOST_DISTANCE and _G.BOOST_SPEED or _G.SPEED if _IIIIIIIIlI<=0x4 then _IIIlIIlllI=_IIIlIIlllI+DeltaTime if firetouchinterest then local _lllllIIIlI=_llIlIlIIll:IsA("\066\097\115\101\080\097\114\116") and _llIlIlIIll or _llIlIlIIll.PrimaryPart or _llIlIlIIll:FindFirstChildOfClass("\066\097\115\101\080\097\114\116") if _lllllIIIlI then firetouchinterest(_llIllIIlIl,_lllllIIIlI,0x0); firetouchinterest(_llIllIIlIl,_lllllIIIlI,0x1) end
 end
 if _IIIlIIlllI>=0.4 then _lIIIIlIllI[_llIlIlIIll]=true _llIlIlIIll=nil _IIIlIIlllI=0x0 _lIlIlIllIl() return end
 else _IIIlIIlllI=0x0 end
 local _lIlllIlllI=math.clamp((_llIIIIIIII*DeltaTime)/math.max(_IIIIIIIIlI,0.001),0x0,0x1) _llIllIIlIl.CFrame=_llIllIIlIl.CFrame:Lerp(_llIIIlIlII,_lIlllIlllI) end
 end
 ) local _lIlllIIIlI=Instance.new("\073\109\097\103\101\066\117\116\116\111\110",_lIIIIIIllI) _lIlllIIIlI.Size=UDim2.new(0x0,0x28,0x0,0x28) _lIlllIIIlI.Position=UDim2.new(0.015,0x0,0.2,0x0) _lIlllIIIlI.BackgroundColor3=Color3.fromRGB(0xF,0x19,0x23) _lIlllIIIlI.BackgroundTransparency=0.2 _lIlllIIIlI.Draggable=true _lIlllIIIlI.ClipsDescendants=true _lIlllIIIlI.Image="\114\098\120\097\115\115\101\116\105\100\058\047\047\055\054\054\054\056\057\050\050\056\048\050\049\054\054" Instance.new("\085\073\067\111\114\110\101\114",_lIlllIIIlI).CornerRadius=UDim.new(0x1,0x0) local _llIlIlIlll=Instance.new("\085\073\083\116\114\111\107\101",_lIlllIIIlI) _llIlIlIlll.Thickness=1.5 _llIlIlIlll.ApplyStrokeMode=Enum.ApplyStrokeMode.Border _llIlIlIlll.LineJoinMode=Enum.LineJoinMode.Round _llIlIlIlll.Color=Color3.fromRGB(0xFF,0xFF,0xFF) local _lIIlIIIlIl=Instance.new("\085\073\071\114\097\100\105\101\110\116",_llIlIlIlll) _lIIlIIIlIl.Color=ColorSequence.new({ ColorSequenceKeypoint.new(0.00,Color3.fromRGB(0x0,0xAA,0xFF)), ColorSequenceKeypoint.new(0.25,Color3.fromRGB(0xFF,0xFF,0xFF)), ColorSequenceKeypoint.new(0.50,Color3.fromRGB(0x0,0x1E,0x5A)), ColorSequenceKeypoint.new(0.75,Color3.fromRGB(0xFF,0xFF,0xFF)), ColorSequenceKeypoint.new(1.00,Color3.fromRGB(0x0,0xAA,0xFF)) }) _lIIlIIIlIl.Parent=_llIlIlIlll local _lIlIllIIIl=Instance.new("\070\114\097\109\101",_lIIIIIIllI) local _IIIIIIllII=UDim2.new(0x0,0xE6,0x0,0x122) local _llIlIllIIl=UDim2.new(0x0,0xB4,0x0,0xDC) _lIlIllIIIl.Size=_llIlIllIIl _lIlIllIIIl.AnchorPoint=Vector2.new(0.5,0.5) _lIlIllIIIl.Position=UDim2.new(0.5,0x0,0.5,0x0) _lIlIllIIIl.BackgroundColor3=Color3.fromRGB(0xF,0x14,0x1C) _lIlIllIIIl.BackgroundTransparency=0.15 _lIlIllIIIl.Visible=false _lIlIllIIIl.Draggable=true _lIlIllIIIl.ClipsDescendants=true Instance.new("\085\073\067\111\114\110\101\114",_lIlIllIIIl).CornerRadius=UDim.new(0x0,0xA) local _IlIIIlllll=Instance.new("\070\114\097\109\101",_lIlIllIIIl) _IlIIIlllll.Name="\083\110\111\119\076\097\121\101\114" _IlIIIlllll.Size=UDim2.fromScale(0x1,0x1) _IlIIIlllll.BackgroundTransparency=0x1 _IlIIIlllll.ClipsDescendants=true _IlIIIlllll.ZIndex=0x0 local _IIIlIIIIIl={} for i=0x1,0x2D do local _IIlllIllIl=Instance.new("\070\114\097\109\101",_IlIIIlllll) local _IllIIlIIlI=math.random(0x1,0x3) _IIlllIllIl.Size=UDim2.new(0x2,_IllIIlIIlI,0x2,_IllIIlIIlI) _IIlllIllIl.Position=UDim2.new(math.random(),0x0,math.random(),0x0) _IIlllIllIl.BackgroundColor3=Color3.fromRGB(0xFF,0xFF,0xFF) _IIlllIllIl.BackgroundTransparency=math.random(0x14,0x3C)/0x64 _IIlllIllIl.BorderSizePixel=0x0 _IIlllIllIl.ZIndex=0x0 Instance.new("\085\073\067\111\114\110\101\114",_IIlllIllIl).CornerRadius=UDim.new(0x1,0x0) table.insert(_IIIlIIIIIl,{Object=_IIlllIllIl,Speed=math.random(0xF,0x23)/0x64,Drift=math.random(-0x8,0x8)/0x64}) end
 local _IlllIlIlII=Instance.new("\085\073\083\116\114\111\107\101",_lIlIllIIIl) _IlllIlIlII.Thickness=1.5 _IlllIlIlII.ApplyStrokeMode=Enum.ApplyStrokeMode.Border _IlllIlIlII.LineJoinMode=Enum.LineJoinMode.Round _IlllIlIlII.Color=Color3.fromRGB(0xFF,0xFF,0xFF) local _IIllIIIIII=Instance.new("\085\073\071\114\097\100\105\101\110\116",_IlllIlIlII) _IIllIIIIII.Color=ColorSequence.new({ ColorSequenceKeypoint.new(0.00,Color3.fromRGB(0x0,0xAA,0xFF)), ColorSequenceKeypoint.new(0.25,Color3.fromRGB(0xFF,0xFF,0xFF)), ColorSequenceKeypoint.new(0.50,Color3.fromRGB(0x0,0x1E,0x5A)), ColorSequenceKeypoint.new(0.75,Color3.fromRGB(0xFF,0xFF,0xFF)), ColorSequenceKeypoint.new(1.00,Color3.fromRGB(0x0,0xAA,0xFF)) }) _IIllIIIIII.Parent=_IlllIlIlII local _lIlIlllIIl=Instance.new("\084\101\120\116\076\097\098\101\108",_lIlIllIIIl) _lIlIlllIIl.Size=UDim2.new(0x1,-0x37,0x0,0x23) _lIlIlllIIl.Position=UDim2.new(0x0,0x0,0x0,0x0) _lIlIlllIIl.Text="" _lIlIlllIIl.RichText=true _lIlIlllIIl.Font=Enum.Font.Cartoon _lIlIlllIIl.TextSize=0xF _lIlIlllIIl.BackgroundTransparency=0x1 _lIlIlllIIl.TextXAlignment=Enum.TextXAlignment.Center _lIlIlllIIl.TextYAlignment=Enum.TextYAlignment.Center local _llIlIIllIl=Instance.new("\083\099\114\111\108\108\105\110\103\070\114\097\109\101",_lIlIllIIIl) _llIlIIllIl.Size=UDim2.new(0x1,0x0,0x1,-0x28) _llIlIIllIl.Position=UDim2.new(0x0,0x0,0x0,0x26) _llIlIIllIl.BackgroundTransparency=0x1 _llIlIIllIl.ScrollBarThickness=0x3 _llIlIIllIl.CanvasSize=UDim2.new(0x0,0x0,0x0,0x0) _llIlIIllIl.AutomaticCanvasSize=Enum.AutomaticSize.None local _lllllIllII=Instance.new("\085\073\076\105\115\116\076\097\121\111\117\116",_llIlIIllIl) _lllllIllII.SortOrder=Enum.SortOrder.LayoutOrder _lllllIllII.Padding=UDim.new(0x0,0x6) _lllllIllII.HorizontalAlignment=Enum.HorizontalAlignment.Center _lllllIllII:GetPropertyChangedSignal("\065\098\115\111\108\117\116\101\067\111\110\116\101\110\116\083\105\122\101"):Connect( function () _llIlIIllIl.CanvasSize=UDim2.new(0x0,0x0,0x0,_lllllIllII.AbsoluteContentSize.Y+0xA) end
 ) local _lIlIlIIlII="\078\072\065\084\032\072\073\072\073" local _lIlllIlIlI=0x0 local _IIlIIIlIll local _lllIIlllII local _lIllIIllll _lIllIIllll= function () if not _lIlIllIIIl or not _IIlIIIlIll then return end
 if not _lIlIllIIIl.Visible or not _IIlIIIlIll.Visible then return end
 local _llIlIllIlI=_lIlIllIIIl.AbsolutePosition local _IIllIllIll=_lIlIllIIIl.AbsoluteSize local _lIlllIIIll=_IIlIIIlIll.AbsoluteSize local _lIIIIlIIII=0x8 local _lIllllllII=_llIlIllIlI.X+_IIllIllIll.X+_lIIIIlIIII+(_lIlllIIIll.X*_IIlIIIlIll.AnchorPoint.X) local _llIIlllIll=_llIlIllIlI.Y+(_IIllIllIll.Y/0x2) _IIlIIIlIll.Position=UDim2.fromOffset(_lIllllllII,_llIIlllIll) end
 local _lIlIIIlIII=TweenInfo.new(0.28,Enum.EasingStyle.Quart,Enum.EasingDirection.Out) local _lIlIIIIlll=false local function _lIIllIlIIl() if _lIlIIIIlll then return end
 _lIlIllIIIl.Visible=true _lIlIllIIIl.Size=_llIlIllIIl TweenService:Create( _lIlIllIIIl, _lIlIIIlIII, {_IllIIlIIlI=_IIIIIIllII} ):Play() end
 local function _IIIlIIIlIl() if not _lIlIllIIIl.Visible or _lIlIIIIlll then return end
 _lIlIIIIlll=true if _IIlIIIlIll and _IIlIIIlIll.Visible then _IIlIIIlIll.Visible=false _IIlIIIlIll.Size=_IIlIIlllIl if _lllIIlllII then _lllIIlllII(true) end
 end
 local _llllllIIII=TweenService:Create( _lIlIllIIIl, TweenInfo.new(0.22,Enum.EasingStyle.Quart,Enum.EasingDirection.In), {_IllIIlIIlI=_llIlIllIIl} ) _llllllIIII:Play() _llllllIIII.Completed:Connect( function () _lIlIllIIIl.Visible=false _lIlIIIIlll=false end
 ) end
 local function _IIllIlIIIl() if _lIlIllIIIl.Visible then _IIIlIIIlIl() else _lIIllIlIIl() end
 end
 RunService.RenderStepped:Connect( function (delta) local _lIIIlIIIII=_lIlIllIIIl.Visible and 0x96 or 0x64 _lIIlIIIlIl.Rotation=(_lIIlIIIlIl.Rotation+delta*_lIIIlIIIII)%0x168 _IIllIIIIII.Rotation=(_IIllIIIIII.Rotation+delta*0x5A)%0x168 if _lIlIllIIIl.Visible and _IIlIIIlIll and _IIlIIIlIll.Visible then _lIllIIllll() end
 for _,flake in ipairs(_IIIlIIIIIl) do local _lIIlIIIIIl=flake.Object if _lIIlIIIIIl.Parent then local _lIlIlIIIII=_lIIlIIIIIl.Position.X.Scale+flake.Drift*delta local _llIIlIlIII=_lIIlIIIIIl.Position.Y.Scale+flake.Speed*delta if _llIIlIlIII>1.05 then _llIIlIlIII=-0.05 _lIlIlIIIII=math.random() end
 if _lIlIlIIIII>1.05 then _lIlIlIIIII=-0.05 elseif _lIlIlIIIII<-0.05 then _lIlIlIIIII=1.05 end
 _lIIlIIIIIl.Position=UDim2.new(_lIlIlIIIII,0x0,_llIIlIlIII,0x0) end
 end
 _lIlllIlIlI=(_lIlllIlIlI+delta*0.35)%0x1 local _IIIlIIllII="" for i=0x1,#_lIlIlIIlII do local _lIlIllIIll=_lIlIlIIlII:sub(i,i) if _lIlIllIIll=="\032" then _IIIlIIllII=_IIIlIIllII.."\032" else local _IllllllllI=(_lIlllIlIlI-(i-0x1)/#_lIlIlIIlII)%0x1 local _IIlIllIIII=Color3.fromHSV(_IllllllllI,0x1,0x1) local _IlIIIlIlll=math.floor(_IIlIllIIII.R*0xFF) local _lIIlIllIll=math.floor(_IIlIllIIII.G*0xFF) local _lIllIIllll=math.floor(_IIlIllIIII.B*0xFF) _IIIlIIllII=_IIIlIIllII..string.format( "\060\102\111\110\116\032\099\111\108\111\114\061\034\114\103\098\040\037\100\044\037\100\044\037\100\041\034\062\037\115\060\047\102\111\110\116\062", _IlIIIlIlll,_lIIlIllIll,_lIllIIllll,_lIlIllIIll ) end
 end
 _lIlIlllIIl.Text=_IIIlIIllII end
 ) _lIlllIIIlI.MouseButton1Click:Connect(_IIllIlIIIl) local _IlIlIllIll=Instance.new("\084\101\120\116\066\117\116\116\111\110",_lIlIllIIIl) _IlIlIllIll.Name="\083\101\116\116\105\110\103\115\066\117\116\116\111\110" _IlIlIllIll.Size=UDim2.new(0x0,0x1E,0x0,0x1E) _IlIlIllIll.Position=UDim2.new(0x1,-0x23,0x0,0x2) _IlIlIllIll.BackgroundColor3=Color3.fromRGB(0x19,0x23,0x32) _IlIlIllIll.BackgroundTransparency=0x1 _IlIlIllIll.AutoButtonColor=false _IlIlIllIll.Text="\9881\65039" _IlIlIllIll.Font=Enum.Font.Cartoon _IlIlIllIll.TextSize=0x12 _IlIlIllIll.TextColor3=Color3.fromRGB(0x64,0xC8,0xFF) Instance.new("\085\073\067\111\114\110\101\114",_IlIlIllIll).CornerRadius=UDim.new(0x1,0x0) local _IIIlIllIIl=Instance.new("\085\073\083\116\114\111\107\101",_IlIlIllIll) _IIIlIllIIl.Thickness=0x1 _IIIlIllIIl.Color=Color3.fromRGB(0x0,0x78,0xC8) _IIlIIIlIll=Instance.new("\070\114\097\109\101",_lIIIIIIllI) local _llllllIIlI=UDim2.new(0x0,0xB4,0x0,0xC3) local _IIlIIlllIl=UDim2.new(0x0,0x8C,0x0,0x96) _IIlIIIlIll.Name="\083\101\116\116\105\110\103\115\071\117\105" _IIlIIIlIll.Size=_IIlIIlllIl _IIlIIIlIll.AnchorPoint=Vector2.new(0x0,0.5) _IIlIIIlIll.Position=UDim2.new(0.5,0x0,0.5,0x0) _IIlIIIlIll.BackgroundColor3=Color3.fromRGB(0xF,0x14,0x1C) _IIlIIIlIll.BackgroundTransparency=0.08 _IIlIIIlIll.Visible=false _IIlIIIlIll.Active=true _IIlIIIlIll.Draggable=false _IIlIIIlIll.ZIndex=0x14 _IIlIIIlIll.ClipsDescendants=true Instance.new("\085\073\067\111\114\110\101\114",_IIlIIIlIll).CornerRadius=UDim.new(0x0,0x8) local _IIIIIlllll=Instance.new("\085\073\083\116\114\111\107\101",_IIlIIIlIll) _IIIIIlllll.Thickness=1.3 _IIIIIlllll.Color=Color3.fromRGB(0x0,0xAA,0xFF) local _IlIIllIIIl=Instance.new("\084\101\120\116\076\097\098\101\108",_IIlIIIlIll) _IlIIllIIIl.Size=UDim2.new(0x1,-0x1E,0x0,0x19) _IlIIllIIIl.Position=UDim2.new(0x0,0x5,0x0,0x2) _IlIIllIIIl.BackgroundTransparency=0x1 _IlIIllIIIl.Text="\067\192\073\032\272\7862\084" _IlIIllIIIl.Font=Enum.Font.Cartoon _IlIIllIIIl.TextSize=0xE _IlIIllIIIl.TextColor3=Color3.fromRGB(0x64,0xC8,0xFF) _IlIIllIIIl.TextXAlignment=Enum.TextXAlignment.Left _IlIIllIIIl.ZIndex=0x15 local _IlIlIlIIll=Instance.new("\084\101\120\116\066\117\116\116\111\110",_IIlIIIlIll) _IlIlIlIIll.Size=UDim2.new(0x0,0x16,0x0,0x16) _IlIlIlIIll.Position=UDim2.new(0x1,-0x19,0x0,0x3) _IlIlIlIIll.BackgroundTransparency=0x1 _IlIlIlIIll.Text="\088" _IlIlIlIIll.Font=Enum.Font.Gotham _IlIlIlIIll.TextSize=0x14 _IlIlIlIIll.TextColor3=Color3.fromRGB(0xFF,0x64,0x64) _IlIlIlIIll.AutoButtonColor=false _IlIlIlIIll.ZIndex=0x15 local _lllIlIIllI=Instance.new("\083\099\114\111\108\108\105\110\103\070\114\097\109\101",_IIlIIIlIll) _lllIlIIllI.Name="\083\101\116\116\105\110\103\115\083\099\114\111\108\108" _lllIlIIllI.Size=UDim2.new(0x1,-0x8,0x1,-0x20) _lllIlIIllI.Position=UDim2.new(0x0,0x4,0x0,0x1D) _lllIlIIllI.BackgroundTransparency=0x1 _lllIlIIllI.BorderSizePixel=0x0 _lllIlIIllI.ScrollBarThickness=0x3 _lllIlIIllI.ScrollBarImageColor3=Color3.fromRGB(0x0,0xAA,0xFF) _lllIlIIllI.CanvasSize=UDim2.new(0x0,0x0,0x0,0x0) _lllIlIIllI.AutomaticCanvasSize=Enum.AutomaticSize.None _lllIlIIllI.ScrollingDirection=Enum.ScrollingDirection.Y _lllIlIIllI.ZIndex=0x15 local _IIIIIIllII=Instance.new("\085\073\076\105\115\116\076\097\121\111\117\116",_lllIlIIllI) _IIIIIIllII.SortOrder=Enum.SortOrder.LayoutOrder _IIIIIIllII.Padding=UDim.new(0x0,0x7) _IIIIIIllII.HorizontalAlignment=Enum.HorizontalAlignment.Center _IIIIIIllII:GetPropertyChangedSignal("\065\098\115\111\108\117\116\101\067\111\110\116\101\110\116\083\105\122\101"):Connect( function () _lllIlIIllI.CanvasSize=UDim2.new(0x0,0x0,0x0,_IIIIIIllII.AbsoluteContentSize.Y+0xA) end
 ) local function _IlIIlIlIll(Parent,Name,MinValue,MaxValue,DefaultValue,Callback) local _lllIllIlll=Instance.new("\070\114\097\109\101",Parent) _lllIllIlll.Size=UDim2.new(0x1,-0x6,0x0,0x36) _lllIllIlll.BackgroundTransparency=0x1 _lllIllIlll.BorderSizePixel=0x0 _lllIllIlll.ZIndex=0x15 local _IIIIIIlIlI=Instance.new("\084\101\120\116\076\097\098\101\108",_lllIllIlll) _IIIIIIlIlI.Size=UDim2.new(0x1,-0x32,0x0,0x12) _IIIIIIlIlI.Position=UDim2.new(0x0,0x2,0x0,0x0) _IIIIIIlIlI.BackgroundTransparency=0x1 _IIIIIIlIlI.Text=Name _IIIIIIlIlI.Font=Enum.Font.Cartoon _IIIIIIlIlI.TextSize=0xB _IIIIIIlIlI.TextColor3=Color3.fromRGB(0x64,0xC8,0xFF) _IIIIIIlIlI.TextXAlignment=Enum.TextXAlignment.Left _IIIIIIlIlI.ZIndex=0x15 local _llllIllIlI=Instance.new("\084\101\120\116\066\111\120",_lllIllIlll) _llllIllIlI.Size=UDim2.new(0x0,0x26,0x0,0x13) _llllIllIlI.Position=UDim2.new(0x1,-0x28,0x0,-0x2) _llllIllIlI.BackgroundColor3=Color3.fromRGB(0x19,0x23,0x32) _llllIllIlI.BackgroundTransparency=0x0 _llllIllIlI.Text=tostring(DefaultValue) _llllIllIlI.Font=Enum.Font.Cartoon _llllIllIlI.TextSize=0xB _llllIllIlI.TextColor3=Color3.fromRGB(0xFF,0xFF,0xFF) _llllIllIlI.ClearTextOnFocus=false _llllIllIlI.TextXAlignment=Enum.TextXAlignment.Center _llllIllIlI.ZIndex=0x16 Instance.new("\085\073\067\111\114\110\101\114",_llllIllIlI).CornerRadius=UDim.new(0x0,0x4) local _IllIIIlllI=Instance.new("\085\073\083\116\114\111\107\101",_llllIllIlI) _IllIIIlllI.Thickness=0x1 _IllIIIlllI.Color=Color3.fromRGB(0x0,0x78,0xC8) local _IlIlIlIIlI=Instance.new("\070\114\097\109\101",_lllIllIlll) _IlIlIlIIlI.Size=UDim2.new(0x1,-0x2D,0x0,0x6) _IlIlIlIIlI.Position=UDim2.new(0x0,0x2,0x0,0x1B) _IlIlIlIIlI.BackgroundColor3=Color3.fromRGB(0x2D,0x37,0x41) _IlIlIlIIlI.BorderSizePixel=0x0 _IlIlIlIIlI.ZIndex=0x15 Instance.new("\085\073\067\111\114\110\101\114",_IlIlIlIIlI).CornerRadius=UDim.new(0x1,0x0) local _IIIIllIlII=Instance.new("\070\114\097\109\101",_IlIlIlIIlI) _IIIIllIlII.Size=UDim2.new(0x0,0x0,0x1,0x0) _IIIIllIlII.BackgroundColor3=Color3.fromRGB(0x0,0xAA,0xFF) _IIIIllIlII.BorderSizePixel=0x0 _IIIIllIlII.ZIndex=0x16 Instance.new("\085\073\067\111\114\110\101\114",_IIIIllIlII).CornerRadius=UDim.new(0x1,0x0) local _IIllIlIlII=math.clamp(DefaultValue,MinValue,MaxValue) local _IIllIllllI=false local function _IIIlIIlIIl(_IllIllIlII) _IllIllIlII=tonumber(_IllIllIlII) if not _IllIllIlII then _IllIllIlII=_IIllIlIlII end
 _IIllIlIlII=math.clamp( math.round(_IllIllIlII), MinValue, MaxValue ) local _lllllIIIlI=(_IIllIlIlII-MinValue)/(MaxValue-MinValue) _IIIIllIlII.Size=UDim2.new(_lllllIIIlI,0x0,0x1,
_llllIllIlI.Text=tostring(_IIllIlIlII) Callback(_IIllIlIlII) end
 local function _IllIllIIll(_lIllllllII) local _lllllIIIlI=math.clamp( (_lIllllllII-_IlIlIlIIlI.AbsolutePosition.X)/_IlIlIlIIlI.AbsoluteSize.X, 0x0, 0x1 ) _IIIlIIlIIl( MinValue+(MaxValue-MinValue)*_lllllIIIlI ) end
 _IlIlIlIIlI.InputBegan:Connect( function (InputObject) if InputObject.UserInputType==Enum.UserInputType.MouseButton1 or InputObject.UserInputType==Enum.UserInputType.Touch then _IIllIllllI=true _IllIllIIll(InputObject.Position.X) end
 end
 ) UserInputService.InputChanged:Connect( function (InputObject) if _IIllIllllI and ( InputObject.UserInputType==Enum.UserInputType.MouseMovement or InputObject.UserInputType==Enum.UserInputType.Touch ) then _IllIllIIll(InputObject.Position.X) end
 end
 ) UserInputService.InputEnded:Connect( function (InputObject) if InputObject.UserInputType==Enum.UserInputType.MouseButton1 or InputObject.UserInputType==Enum.UserInputType.Touch then _IIllIllllI=false end
 end
 ) _llllIllIlI.FocusLost:Connect( function () local _IllIllIlII=tonumber(_llllIllIlI.Text) if _IllIllIlII then _IIIlIIlIIl(_IllIllIlII) else _llllIllIlI.Text=tostring(_IIllIlIlII) end
 end
 ) _IIIlIIlIIl(DefaultValue) return { Set=_IIIlIIlIIl, Get= function () return _IIllIlIlII end
 } end
 local _IIlllIIIlI=_IlIIlIlIll( _lllIlIIllI, "\084\7889\099\032\273\7897\032\098\097\121", 0x96, 0xFA, _G.SPEED, function (_IIllIlIlII) _G.SPEED=_IIllIlIlII end
 ) local _IIIlIllllI=_IlIIlIlIll( _lllIlIIllI, "\272\7897\032\099\097\111\032\113\117\225\105", 0x0, 0x64, _G.DOCAO_MOB, function (_IIllIlIlII) _G.DOCAO_MOB=_IIllIlIlII end
 ) local _IIIIlIIIII=_IlIIlIlIll( _lllIlIIllI, "\084\7889\099\032\273\7897\032\116\104\117\121\7873\110", 0x64, 0x1F4, _G.BOAT_SPEED, function (_IIllIlIlII) _G.BOAT_SPEED=_IIllIlIlII end
 ) local _IlIIlllIIl=false local _lllIlIIlII=false _lllIIlllII= function (Instant) if Instant then _IlIIlllIIl=false _lllIlIIlII=false _IIlIIIlIll.Visible=false _IIlIIIlIll.Size=_IIlIIlllIl return end
 if _lllIlIIlII or not _IIlIIIlIll.Visible then return end
 _lllIlIIlII=true _IlIIlllIIl=false local _llllllIIII=TweenService:Create( _IIlIIIlIll, TweenInfo.new( 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In ), {_IllIIlIIlI=_IIlIIlllIl} ) _llllllIIII:Play() _llllllIIII.Completed:Connect( function () _IIlIIIlIll.Visible=false _lllIlIIlII=false end
 ) end
 local function _IllIIlllll() if _IlIIlllIIl or _IIlIIIlIll.Visible or not _lIlIllIIIl.Visible then return end
 _IlIIlllIIl=true _lllIlIIlII=false _IIlIIIlIll.Visible=true _IIlIIIlIll.Size=_IIlIIlllIl _lIllIIllll() local _llllllIIII=TweenService:Create( _IIlIIIlIll, TweenInfo.new( 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out ), {_IllIIlIIlI=_llllllIIlI} ) _llllllIIII:Play() _llllllIIII.Completed:Connect( function () _IlIIlllIIl=false _lIllIIllll() end
 ) end
 local function _IIlIlllIIl() if _IIlIIIlIll.Visible then _lllIIlllII() else _IllIIlllll() end
 end
 _IlIlIllIll.MouseButton1Click:Connect(_IIlIlllIIl) _IlIlIlIIll.MouseButton1Click:Connect( function () _lllIIlllII() end
 ) local function _IllIIlIlIl(spawnArg) local _lIIIlIIIII=ReplicatedStorage:WaitForChild("\082\101\109\111\116\101\115"):WaitForChild("\067\111\109\109\070\095") if spawnArg=="\084\101\109\112\108\101\079\102\084\105\109\101" then if _IllIIIllll or _llllIIIlIl then if _IllIIIllll then _IllIIIllll:Disconnect(); _IllIIIllll=nil end
 _IIIIIIIIIl() _lllIIlllIl() return end
 task.spawn( function () local _IllIIIIllI=_llIlIIllIl() if not _IllIIIIllI then return end
 _lIllIIIIlI(_IllIIIIllI) _IlIlIIIIll() local _IIllIlIIll=CFrame.new(3035.22,2280.89,-7321.22) local _IllllIlllI=0x1 local _IllIllIIll=nil _IllIIIllll=RunService.Heartbeat:Connect( function (deltaTime) local _IIlIlllllI=_llIlIIllIl() if not _IIlIlllllI then if _IllIIIllll then _IllIIIllll:Disconnect(); _IllIIIllll=nil end
 _IIIIIIIIIl() _lllIIlllIl() return end
 _IIlIlllllI.AssemblyLinearVelocity=Vector3.zero _IIlIlllllI.AssemblyAngularVelocity=Vector3.zero _IlIlIIIIll() if _IllllIlllI==0x2 then return end
 local _lllllIlIII if _IllllIlllI==0x1 then _lllllIlIII=_IIllIlIIll elseif _IllllIlllI==0x3 then _lllllIlIII=_IllIllIIll end
 if not _lllllIlIII then return end
 local _lIIIlIlIII=(_IIlIlllllI.Position-_lllllIlIII.Position).Magnitude local _IlIllIIllI=tonumber(_G.BOOST_DISTANCE) or 0x5A local _IIIIIIllII=tonumber(_G.BOOST_SPEED) or 0x3E8 local _llIlIIllIl=tonumber(_G.SPEED) or 0x8C local _IlIIIlllII=_lIIIlIlIII<=_IlIllIIllI and _IIIIIIllII or _llIlIIllIl local _lIlllIllII=math.clamp((_IlIIIlllII*deltaTime)/math.max(_lIIIlIlIII,0.001),0x0,0x1) if _IllllIlllI==0x1 then if _lIIIlIlIII<=0.5 then _IllllIlllI=0x2 task.spawn( function () for i=0x1,0xA do local _IIIlIlllIl=_IlIIlIlIll:FindFirstChild("\077\097\112") or _IlIIlIlIll if not _IIIlIlllIl:FindFirstChild("\084\101\109\112\108\101\032\111\102\032\084\105\109\101") then local _IlIIllIlIl=ReplicatedStorage:FindFirstChild("\077\097\112\083\116\097\115\104") or ReplicatedStorage local _lllIlIIIIl=_IlIIllIlIl:FindFirstChild("\084\101\109\112\108\101\032\111\102\032\084\105\109\101") if _lllIlIIIIl then _lllIlIIIIl.Parent=_IIIlIlllIl; break end
 else break end
 task.wait(0.3) end
 task.wait(0.5) pcall( function () _lIIIlIIIII:InvokeServer("\114\101\113\117\101\115\116\069\110\116\114\097\110\099\101",Vector3.new(28310.0234,14895.1123,109.456741)) end
 ) task.wait(0.5) local _IIIIllIlll=nil pcall( function () _IIIIllIlll=_lIlllIlllI.Data.Race.Value end
 ) if _IIIIllIlll=="\070\105\115\104\109\097\110" then _IllIllIIll=CFrame.new(28224.056640625,14889.4267578125,-210.5872039794922) elseif _IIIIllIlll=="\067\121\098\111\114\103" then _IllIllIIll=CFrame.new(28492.4140625,14894.4267578125,-422.1100158691406) elseif _IIIIllIlll=="\083\107\121\112\105\101\097" then _IllIllIIll=CFrame.new(28967.408203125,14918.0751953125,234.31198120117188) elseif _IIIIllIlll=="\071\104\111\117\108" then _IllIllIIll=CFrame.new(28672.720703125,14889.1279296875,454.5961608886719) elseif _IIIIllIlll=="\072\117\109\097\110" then _IllIllIIll=CFrame.new(29237.294921875,14889.4267578125,-206.94955444335938) else _IllIllIIll=CFrame.new(29020.66015625,14889.4267578125,-379.2682800292969) end
 _IllllIlllI=0x3 end
 ) else _IIlIlllllI.CFrame=_IIlIlllllI.CFrame:Lerp(_lllllIlIII,_lIlllIllII) end
 elseif _IllllIlllI==0x3 then if _lIIIlIlIII<=0x3 then if _IllIIIllll then _IllIIIllll:Disconnect(); _IllIIIllll=nil end
 _IIIIIIIIIl() _lllIIlllIl() return else _IIlIlllllI.CFrame=_IIlIlllllI.CFrame:Lerp(_lllllIlIII,_lIlllIllII) end
 end
 end
 ) end
 ) return end
 end
 local _llIlIlIlll=Instance.new("\084\101\120\116\066\117\116\116\111\110",_llIlIIllIl) _llIlIlIlll.Size=UDim2.new(0.9,0x0,0x0,0x20) _llIlIlIlll.Text="\272\7873\110\032\084\104\7901\105\032\071\105\097\110" _llIlIlIlll.Font=Enum.Font.Cartoon _llIlIlIlll.TextSize=0xD _llIlIlIlll.TextColor3=Color3.fromRGB(0x64,0xC8,0xFF) _llIlIlIlll.BackgroundColor3=Color3.fromRGB(0x19,0x23,0x32) _llIlIlIlll.BackgroundTransparency=0.3 _llIlIlIlll.AutoButtonColor=false Instance.new("\085\073\067\111\114\110\101\114",_llIlIlIlll).CornerRadius=UDim.new(0x0,0x6) local _IlIIIllIIl=Instance.new("\085\073\083\116\114\111\107\101",_llIlIlIlll) _IlIIIllIIl.Thickness=0x1 _IlIIIllIIl.Color=Color3.fromRGB(0x0,0x78,0xC8) _llIlIlIlll.MouseButton1Click:Connect( function () _IllIIlIlIl("\084\101\109\112\108\101\079\102\084\105\109\101") end
 ) local _IlIIlIIIll=Instance.new("\070\114\097\109\101",_llIlIIllIl) _IlIIlIIIll.Size=UDim2.new(0.9,0x0,0x0,0x26) _IlIIlIIIll.BackgroundColor3=Color3.fromRGB(0x19,0x23,0x32) _IlIIlIIIll.BackgroundTransparency=0.3 _IlIIlIIIll.BorderSizePixel=0x0 Instance.new("\085\073\067\111\114\110\101\114",_IlIIlIIIll).CornerRadius=UDim.new(0x0,0x6) local _IIlIIIIIIl=Instance.new("\085\073\083\116\114\111\107\101",_IlIIlIIIll) _IIlIIIIIIl.Thickness=0x1 _IIlIIIIIIl.Color=Color3.fromRGB(0x0,0x78,0xC8) local _lIlIlIIlll=Instance.new("\084\101\120\116\076\097\098\101\108",_IlIIlIIIll) _lIlIlIIlll.Size=UDim2.new(0x1,-0x41,0x1,0x0) _lIlIlIIlll.Position=UDim2.new(0x0,0x5,0x0,0x0) _lIlIlIIlll.BackgroundTransparency=0x1 _lIlIlIIlll.Text="\084\7888\067\032\272\7896\032\084\072\085\089\7872\078" _lIlIlIIlll.Font=Enum.Font.Cartoon _lIlIlIIlll.TextSize=0xD _lIlIlIIlll.TextColor3=Color3.fromRGB(0x64,0xC8,0xFF) _lIlIlIIlll.TextXAlignment=Enum.TextXAlignment.Left local _llIIIlIIII=Instance.new("\084\101\120\116\066\117\116\116\111\110",_IlIIlIIIll) _llIIIlIIII.Size=UDim2.new(0x0,0x2A,0x0,0x15) _llIIIlIIII.Position=UDim2.new(0x1,-0x2F,0.5,-10.5) _llIIIlIIII.BackgroundColor3=Color3.fromRGB(0x23,0x28,0x30) _llIIIlIIII.AutoButtonColor=false _llIIIlIIII.Text="" Instance.new("\085\073\067\111\114\110\101\114",_llIIIlIIII).CornerRadius=UDim.new(0x1,0x0) local _lllllllllI=Instance.new("\085\073\083\116\114\111\107\101",_llIIIlIIII) _lllllllllI.Thickness=0x1 _lllllllllI.Color=Color3.fromRGB(0x46,0x50,0x5A) local _IIIIIllllI=Instance.new("\070\114\097\109\101",_llIIIlIIII) _IIIIIllllI.Size=UDim2.new(0x0,0xF,0x0,0xF) _IIIIIllllI.Position=UDim2.new(0x0,0x3,0.5,-7.5) _IIIIIllllI.BackgroundColor3=Color3.fromRGB(0xFF,0xFF,0xFF) Instance.new("\085\073\067\111\114\110\101\114",_IIIIIllllI).CornerRadius=UDim.new(0x1,0x0) local function _llllllllII() if _IIlIIllIIl then _llIIIlIIII.BackgroundColor3=Color3.fromRGB(0xF,0x46,0x69) _lllllllllI.Color=Color3.fromRGB(0x0,0xAA,0xFF) TweenService:Create(_IIIIIllllI,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{_lIIllllllI=UDim2.new(0x1,-0x12,0.5,-7.5)}):Play() else _llIIIlIIII.BackgroundColor3=Color3.fromRGB(0x23,0x28,0x30) _lllllllllI.Color=Color3.fromRGB(0x46,0x50,0x5A) TweenService:Create(_IIIIIllllI,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{_lIIllllllI=UDim2.new(0x0,0x3,0.5,-7.5)}):Play() end
 end
 _llIIIlIIII.MouseButton1Click:Connect( function () _IIlIIllIIl= not _IIlIIllIIl _llllllllII() end
 ) local _llIIlllllI=Color3.fromRGB(0x0,0xAA,0xFF) local _llIllIlIll=Color3.fromRGB(0x23,0x28,0x30) local _IIlIIIIlIl=Color3.fromRGB(0xF,0x46,0x69) local _llIlIllIll=Color3.fromRGB(0x64,0xC8,0xFF) local function _llIlIIlIll(Name,Callback) local _lllIllIlll=Instance.new("\070\114\097\109\101",_llIlIIllIl) _lllIllIlll.Size=UDim2.new(0.9,0x0,0x0,0x26) _lllIllIlll.BackgroundColor3=Color3.fromRGB(0x19,0x23,0x32) _lllIllIlll.BackgroundTransparency=0.3 _lllIllIlll.BorderSizePixel=0x0 Instance.new("\085\073\067\111\114\110\101\114",_lllIllIlll).CornerRadius=UDim.new(0x0,0x6) local _llIIlllIll=Instance.new("\085\073\083\116\114\111\107\101",_lllIllIlll) _llIIlllIll.Thickness=0x1 _llIIlllIll.Color=Color3.fromRGB(0x0,0x78,0xC8) local _IIIIIIlIlI=Instance.new("\084\101\120\116\076\097\098\101\108",_lllIllIlll) _IIIIIIlIlI.Size=UDim2.new(0x1,-0x41,0x1,0x0) _IIIIIIlIlI.Position=UDim2.new(0x0,0x5,0x0,0x0) _IIIIIIlIlI.BackgroundTransparency=0x1 _IIIIIIlIlI.Text=Name _IIIIIIlIlI.Font=Enum.Font.Cartoon _IIIIIIlIlI.TextSize=0xD _IIIIIIlIlI.TextColor3=_llIlIllIll _IIIIIIlIlI.TextXAlignment=Enum.TextXAlignment.Left local _IlIIlIIllI=Instance.new("\084\101\120\116\066\117\116\116\111\110",_lllIllIlll) _IlIIlIIllI.Size=UDim2.new(0x0,0x2A,0x0,0x15) _IlIIlIIllI.Position=UDim2.new(0x1,-0x2F,0.5,-10.5) _IlIIlIIllI.BackgroundColor3=_llIllIlIll _IlIIlIIllI.AutoButtonColor=false _IlIIlIIllI.Text="" Instance.new("\085\073\067\111\114\110\101\114",_IlIIlIIllI).CornerRadius=UDim.new(0x1,0x0) local _IlIIIllllI=Instance.new("\085\073\083\116\114\111\107\101",_IlIIlIIllI) _IlIIIllllI.Thickness=0x1 _IlIIIllllI.Color=Color3.fromRGB(0x46,0x50,0x5A) local _lIIIIIllIl=Instance.new("\070\114\097\109\101",_IlIIlIIllI) _lIIIIIllIl.Size=UDim2.new(0x0,0xF,0x0,0xF) _lIIIIIllIl.Position=UDim2.new(0x0,0x3,0.5,-7.5) _lIIIIIllIl.BackgroundColor3=Color3.fromRGB(0xFF,0xFF,0xFF) Instance.new("\085\073\067\111\114\110\101\114",_lIIIIIllIl).CornerRadius=UDim.new(0x1,0x0) local _llIIIlIlll=false local function _IIlIIIllII() if _llIIIlIlll then _IlIIlIIllI.BackgroundColor3=_IIlIIIIlIl _IlIIIllllI.Color=_llIIlllllI _lIIIIIllIl.BackgroundColor3=Color3.fromRGB(0xFF,0xFF,0xFF) TweenService:Create(_lIIIIIllIl,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{_lIIllllllI=UDim2.new(0x1,-0x12,0.5,-7.5)}):Play() else _IlIIlIIllI.BackgroundColor3=_llIllIlIll _IlIIIllllI.Color=Color3.fromRGB(0x46,0x50,0x5A) _lIIIIIllIl.BackgroundColor3=Color3.fromRGB(0xFF,0xFF,0xFF) TweenService:Create(_lIIIIIllIl,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{_lIIllllllI=UDim2.new(0x0,0x3,0.5,-7.5)}):Play() end
 Callback(_llIIIlIlll) end
 _IlIIlIIllI.MouseButton1Click:Connect( function () _llIIIlIlll= not _llIIIlIlll _IIlIIIllII() end
 ) return {Set= function (_IIllIlIlII) _llIIIlIlll=_IIllIlIlII; _IIlIIIllII() end
 ,Get= function () return _llIIIlIlll end
 } end
 local _IIIIlIIlIl=_llIlIIlIll("\066\065\089\032\084\7898\073\032\084\082\193\073", function (_IIllIlIlII) _IIIIlllIll=_IIllIlIlII _IIllIIIIll=nil end
 ) local _lllllllIlI=_llIlIIlIll("\066\065\089\032\084\7898\073\032\081\085\193\073", function (_IIllIlIlII) _lllIlIIlll=_IIllIlIlII _IIIlIIlIIl=nil end
 ) local _IlllllIlll=_llIlIIlIll("\070\065\082\077\032\082\431\416\078\071", function (_IIllIlIlII) _IllIIlllll=_IIllIlIlII if _IIllIlIlII then _lllIIlllll=_lIlIIllIII() end
 _llIlIlIIll=nil _IIIlIIlllI=0x0 end
 ) end
 )(...)
