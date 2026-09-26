-- COMBAT
local CM = _G.CM
if not CM then warn("[CM] core not loaded"); return end
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local P = CM.P
local cam = CM.cam
local page = CM.pages["Combat"]

local aimbotOn = false
local aimbotFOV = 300
local aimbotPart = "Head"
local autoFireOn = false
local autoFireRate = 0.08
local autoFireFOV = 500
local antiAimOn = false
local antiAimPitch = 89
local lastFire = 0

local function isVisible(part)
    local origin = cam.CFrame.Position
    local dir = part.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {P.Character, part.Parent}
    local res = workspace:Raycast(origin, dir, params)
    return res == nil or res.Instance:IsDescendantOf(part.Parent)
end

local function getTarget(fov)
    local closest, closestDist = nil, fov
    local center = cam.ViewportSize/2
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= P and plr.Character then
            local h = plr.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then
                local part = plr.Character:FindFirstChild(aimbotPart)
                if not part then part = plr.Character:FindFirstChild("Head") end
                if part then
                    local pos, onScreen = cam:WorldToViewportPoint(part.Position)
                    local toT = (part.Position - cam.CFrame.Position).Unit
                    if onScreen and toT:Dot(cam.CFrame.LookVector) > 0 then
                        local d = (Vector2.new(pos.X,pos.Y) - center).Magnitude
                        if d < closestDist and isVisible(part) then
                            closestDist = d; closest = part
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- Aimbot (silent)
local fAimbot = CM.feature(page, "aimbot", false, function(v) aimbotOn = v end)
CM.slider(fAimbot.settings, "fov", 10, 800, 300, function(v) aimbotFOV = v end)
CM.cfgs["aimbot"] = {set=function(v) fAimbot.setState(v) end, get=function() return fAimbot.getState() end}

RS.RenderStepped:Connect(function()
    if not aimbotOn then return end
    local target = getTarget(aimbotFOV)
    if target then
        local r = CM.hrp(); if not r then return end
        local dir = target.Position - r.Position
        local flat = Vector3.new(dir.X, 0, dir.Z)
        if flat.Magnitude > 0.1 then
            local lookCF = CFrame.lookAt(r.Position, r.Position + flat.Unit)
            r.CFrame = CFrame.new(r.Position) * (lookCF - lookCF.Position)
        end
    end
end)

-- Anti-Aim
local fAA = CM.feature(page, "antiaim", false, function(v) antiAimOn = v end)
CM.slider(fAA.settings, "aapitch", 10, 89, 89, function(v) antiAimPitch = v end)
CM.cfgs["antiaim"] = {set=function(v) fAA.setState(v) end, get=function() return fAA.getState() end}

RS.RenderStepped:Connect(function()
    if not antiAimOn then return end
    local r = CM.hrp(); if not r then return end
    local look = cam.CFrame.LookVector
    local flat = Vector3.new(look.X, 0, look.Z).Unit
    local pitch = math.rad(-antiAimPitch)
    local newDir = (flat * math.cos(pitch)) + (Vector3.new(0,1,0) * math.sin(pitch))
    local lookCF = CFrame.lookAt(r.Position, r.Position + newDir)
    r.CFrame = CFrame.new(r.Position) * (lookCF - lookCF.Position)
end)

-- AutoFire
local fAF = CM.feature(page, "autofire", false, function(v) autoFireOn = v end)
CM.slider(fAF.settings, "rate", 20, 500, 80, function(v) autoFireRate = v/1000 end)
CM.slider(fAF.settings, "fov", 50, 800, 500, function(v) autoFireFOV = v end)
CM.cfgs["autofire"] = {set=function(v) fAF.setState(v) end, get=function() return fAF.getState() end}

RS.Heartbeat:Connect(function()
    if not autoFireOn then return end
    if os.clock() - lastFire < autoFireRate then return end
    local target = getTarget(autoFireFOV)
    if target then
        local r = CM.hrp(); if not r then return end
        local dir = target.Position - r.Position
        local flat = Vector3.new(dir.X, 0, dir.Z)
        if flat.Magnitude > 0.1 then
            local lookCF = CFrame.lookAt(r.Position, r.Position + flat.Unit)
            r.CFrame = CFrame.new(r.Position) * (lookCF - lookCF.Position)
        end
        local c = P.Character
        if c then
            local tool = c:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function() tool:Activate() end)
                lastFire = os.clock()
            end
        end
    end
end)

CM.addBind("Aimbot", fAimbot)
CM.addBind("AutoFire", fAF)
CM.addBind("Anti-Aim", fAA)

print("[CM] combat loaded")
