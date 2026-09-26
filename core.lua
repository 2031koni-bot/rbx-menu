-- CORE v24
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local LT = game:GetService("Lighting")
local HS = game:GetService("HttpService")

local P = Players.LocalPlayer
local PG = P:WaitForChild("PlayerGui")
local cam = workspace.CurrentCamera

_G.CM = _G.CM or {}
local CM = _G.CM
CM.P = P; CM.PG = PG; CM.cam = cam
CM.AC = Color3.fromRGB(0,170,255)
CM.BG = Color3.fromRGB(15,15,22)
CM.BG2 = Color3.fromRGB(45,45,60)
CM.BG3 = Color3.fromRGB(30,30,42)
CM.TXT = Color3.fromRGB(240,240,240)
CM.STX = Color3.fromRGB(150,150,165)
CM.bgT = 0.12
CM.LANG = "RU"
CM.tabs = {}; CM.pages = {}; CM.binds = {}; CM.cfgs = {}
CM.texts = {}; CM.sliders = {}
CM.waitingBind = nil

CM.lang = {
    RU = {combat="Бой",movement="Движение",visuals="Визуалы",misc="Разное",binds="Бинды",configs="Конфиги",
        speed="Скорость",jump="Прыжок",reset="Сбросить",noclip="Noclip",infjump="Беск. прыжок",
        fly="Полёт",bhop="BHop",autostrafe="Автострайф",hint="Delete - меню",
        bindhint="[Bind] -> клавиша. Клик - сброс.",
        cfgsave="Сохранить",cfgload="Загрузить",cfglist="Конфиги:",cfgrefresh="Обновить",
        esp="ESP",fullbright="Fullbright",fov="FOV",freelook="Своб. камера",
        aimbot="Aimbot",autofire="AutoFire",antiaim="Anti-Aim",tp="ТП к игроку",
        halo="Нимб",color="Цвет",aura="Аура",trail="Шлейф",blink="Блинк",
        antiragdoll="Анти-Рагдолл",antiafk="Анти-АФК",
        reset_fov="Сброс FOV",refresh="Обновить"},
    EN = {combat="Combat",movement="Movement",visuals="Visuals",misc="Misc",binds="Binds",configs="Configs",
        speed="Speed",jump="Jump",reset="Reset",noclip="Noclip",infjump="Infinite Jump",
        fly="Fly",bhop="BHop",autostrafe="Autostrafe",hint="Delete - menu",
        bindhint="[Bind] -> key. Click - reset.",
        cfgsave="Save",cfgload="Load",cfglist="Configs:",cfgrefresh="Refresh",
        esp="ESP",fullbright="Fullbright",fov="FOV",freelook="Free Look",
        aimbot="Aimbot",autofire="AutoFire",antiaim="Anti-Aim",tp="TP to Player",
        halo="Halo",color="Color",aura="Aura",trail="Trail",blink="Blink",
        antiragdoll="Anti-Ragdoll",antiafk="Anti-AFK",
        reset_fov="Reset FOV",refresh="Refresh"},
}
function CM.T(k) return (CM.lang[CM.LANG] and CM.lang[CM.LANG][k]) or k end
function CM.regT(obj, key)
    obj:SetAttribute("Lkey", key)
    obj.Text = CM.T(key)
    table.insert(CM.texts, {obj=obj, key=key})
end
function CM.regSlider(obj, key, getVal)
    obj:SetAttribute("Lkey", key)
    obj.Text = CM.T(key)..": "..getVal()
    table.insert(CM.sliders, {obj=obj, key=key, getVal=getVal})
end
function CM.refreshLang()
    for _, e in ipairs(CM.texts) do
        if e.obj and e.obj.Parent then e.obj.Text = CM.T(e.key) end
    end
    for _, e in ipairs(CM.sliders) do
        if e.obj and e.obj.Parent then e.obj.Text = CM.T(e.key)..": "..e.getVal() end
    end
end

local gui = Instance.new("ScreenGui")
gui.Name="CustomMenu"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.DisplayOrder=2147483647; gui.Parent=PG

local blur = Instance.new("BlurEffect", LT); blur.Size=22
CM.blur = blur; CM.gui = gui

local f = Instance.new("Frame", gui)
f.Size=UDim2.new(0,820,0,520); f.Position=UDim2.new(0.5,-410,0.5,-260)
f.BackgroundColor3=CM.BG; f.BackgroundTransparency=CM.bgT
f.BorderSizePixel=0; f.Visible=true; f.Active=true; f.Draggable=true
local fc = Instance.new("UICorner", f); fc.CornerRadius=UDim.new(0,10)
local fs = Instance.new("UIStroke", f); fs.Color=CM.AC; fs.Transparency=0.45
CM.frame = f; CM.fc = fc; CM.fs = fs

local tb = Instance.new("Frame", f)
tb.Size=UDim2.new(1,0,0,42); tb.BackgroundColor3=CM.BG
tb.BackgroundTransparency=CM.bgT; tb.BorderSizePixel=0
local tbc = Instance.new("UICorner", tb); tbc.CornerRadius=UDim.new(0,10)
CM.tb = tb; CM.tbc = tbc

local ttl = Instance.new("TextLabel", tb)
ttl.Size=UDim2.new(1,-320,1,0); ttl.Position=UDim2.new(0,15,0,0)
ttl.BackgroundTransparency=1; ttl.Text="CUSTOM v24"
ttl.TextColor3=CM.TXT; ttl.Font=Enum.Font.GothamBold; ttl.TextSize=16
ttl.TextXAlignment=Enum.TextXAlignment.Left

local hint = Instance.new("TextLabel", tb)
hint.Size=UDim2.new(0,200,1,0); hint.Position=UDim2.new(0,150,0,0)
hint.BackgroundTransparency=1; hint.TextColor3=CM.STX
hint.Font=Enum.Font.Gotham; hint.TextSize=11
hint.TextXAlignment=Enum.TextXAlignment.Left
CM.regT(hint, "hint")

local btnBox = Instance.new("Frame", tb)
btnBox.Size=UDim2.new(0,240,1,0); btnBox.Position=UDim2.new(1,-240,0,0)
btnBox.BackgroundTransparency=1
local bl = Instance.new("UIListLayout", btnBox)
bl.FillDirection=Enum.FillDirection.Horizontal
bl.HorizontalAlignment=Enum.HorizontalAlignment.Right
bl.VerticalAlignment=Enum.VerticalAlignment.Center
bl.Padding=UDim.new(0,6)

local function ctrlBtn(text, col, cb, w)
    local b = Instance.new("TextButton", btnBox)
    b.Size=UDim2.new(0, w or 30, 0, 26); b.BackgroundColor3=col
    b.BackgroundTransparency=0.1; b.BorderSizePixel=0
    b.Text=text; b.TextColor3=Color3.new(1,1,1)
    b.Font=Enum.Font.GothamBold; b.TextSize=12
    local c=Instance.new("UICorner",b); c.CornerRadius=UDim.new(0,6)
    b.MouseButton1Click:Connect(cb)
    return b
end

local langBtn = ctrlBtn("RU", Color3.fromRGB(100,100,140), function()
    CM.LANG = (CM.LANG=="RU") and "EN" or "RU"
    langBtn.Text = CM.LANG
    CM.refreshLang()
end, 40)

ctrlBtn("-", Color3.fromRGB(230,180,50), function() f.Visible=false; blur.Size=0 end)
ctrlBtn("O", Color3.fromRGB(70,200,100), function()
    if f.Size.X.Scale == 0 then
        f.Size=UDim2.new(1,0,1,0); f.Position=UDim2.new(0,0,0,0); f.Draggable=false
        fc.CornerRadius=UDim.new(0,0); tbc.CornerRadius=UDim.new(0,0)
    else
        f.Size=UDim2.new(0,820,0,520); f.Position=UDim2.new(0.5,-410,0.5,-260)
        f.Draggable=true
        fc.CornerRadius=UDim.new(0,10); tbc.CornerRadius=UDim.new(0,10)
    end
end)
ctrlBtn("X", Color3.fromRGB(220,60,60), function()
    for _, e in ipairs(CM.binds) do
        pcall(function() e.toggleObj.setState(false) end)
    end
    cam.CameraType = Enum.CameraType.Custom; cam.FieldOfView = 70
    local h = P.Character and P.Character:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = 16; h.JumpPower = 50 end
    local r = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
    if r then r.Anchored = false end
    LT.Brightness = 1; LT.FogEnd = 100000; LT.GlobalShadows = true
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name=="Halo" or obj.Name=="Orbs" then pcall(function() obj:Destroy() end) end
    end
    UIS.MouseBehavior = Enum.MouseBehavior.Default
    UIS.MouseIconEnabled = true
    gui:Destroy(); blur:Destroy()
end)

local tabBar = Instance.new("Frame", f)
tabBar.Size=UDim2.new(1,-20,0,32); tabBar.Position=UDim2.new(0,10,0,52)
tabBar.BackgroundTransparency=1
local tlay = Instance.new("UIListLayout", tabBar)
tlay.FillDirection=Enum.FillDirection.Horizontal
tlay.Padding=UDim.new(0,5)

local pagesHolder = Instance.new("Frame", f)
pagesHolder.Size=UDim2.new(1,-20,1,-104)
pagesHolder.Position=UDim2.new(0,10,0,92)
pagesHolder.BackgroundTransparency=1; pagesHolder.ClipsDescendants=true

function CM.mkTab(id, key, order)
    local b = Instance.new("TextButton", tabBar)
    b.Size=UDim2.new(0,100,1,0); b.BackgroundColor3=CM.BG2
    b.BackgroundTransparency=CM.bgT; b.BorderSizePixel=0
    b.TextColor3=CM.TXT; b.Font=Enum.Font.GothamMedium
    b.TextSize=12; b.LayoutOrder=order
    local c=Instance.new("UICorner",b); c.CornerRadius=UDim.new(0,6)
    CM.regT(b, key)
    local p = Instance.new("ScrollingFrame", pagesHolder)
    p.Size=UDim2.new(1,0,1,0); p.BackgroundTransparency=1
    p.BorderSizePixel=0; p.ScrollBarThickness=4
    p.ScrollBarImageColor3=CM.AC; p.CanvasSize=UDim2.new(0,0,0,0)
    p.AutomaticCanvasSize=Enum.AutomaticSize.Y; p.Visible=false
    local pl = Instance.new("UIListLayout", p); pl.Padding=UDim.new(0,8)
    local pp = Instance.new("UIPadding", p); pp.PaddingRight=UDim.new(0,8)
    CM.tabs[id]=b; CM.pages[id]=p
    b.MouseButton1Click:Connect(function()
        for k2,v in pairs(CM.tabs) do
            local on = (k2==id)
            v.BackgroundColor3 = on and CM.AC or CM.BG2
            v.TextColor3 = on and Color3.new(1,1,1) or CM.TXT
            CM.pages[k2].Visible = on
        end
    end)
    return p
end

function CM.btn(parent, key, cb)
    local b = Instance.new("TextButton", parent)
    b.Size=UDim2.new(1,0,0,32); b.BackgroundColor3=CM.BG2
    b.BackgroundTransparency=CM.bgT; b.BorderSizePixel=0
    b.TextColor3=CM.TXT; b.Font=Enum.Font.GothamMedium; b.TextSize=13
    local c=Instance.new("UICorner",b); c.CornerRadius=UDim.new(0,6)
    b.MouseButton1Click:Connect(function() if cb then cb(b) end end)
    CM.regT(b, key)
    return b
end

function CM.toggle(parent, key, def, cb)
    local h = Instance.new("Frame", parent)
    h.Size=UDim2.new(1,0,0,32); h.BackgroundColor3=CM.BG2
    h.BackgroundTransparency=CM.bgT; h.BorderSizePixel=0
    local hc=Instance.new("UICorner",h); hc.CornerRadius=UDim.new(0,6)
    local l = Instance.new("TextLabel", h)
    l.Size=UDim2.new(1,-70,1,0); l.Position=UDim2.new(0,12,0,0)
    l.BackgroundTransparency=1; l.TextColor3=CM.TXT
    l.Font=Enum.Font.Gotham; l.TextSize=13
    l.TextXAlignment=Enum.TextXAlignment.Left
    CM.regT(l, key)
    local tg = Instance.new("Frame", h)
    tg.Size=UDim2.new(0,44,0,22); tg.Position=UDim2.new(1,-54,0.5,-11)
    tg.BackgroundColor3 = def and CM.AC or Color3.fromRGB(50,50,65)
    tg.BorderSizePixel=0
    local tcc=Instance.new("UICorner",tg); tcc.CornerRadius=UDim.new(1,0)
    local kn = Instance.new("Frame", tg)
    kn.Size=UDim2.new(0,16,0,16)
    kn.Position = def and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
    kn.BackgroundColor3=Color3.new(1,1,1); kn.BorderSizePixel=0
    local knc=Instance.new("UICorner",kn); knc.CornerRadius=UDim.new(1,0)
    local st = def
    local function set(v)
        st = v and true or false
        tg.BackgroundColor3 = st and CM.AC or Color3.fromRGB(50,50,65)
        kn.Position = st and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
        if cb then cb(st) end
    end
    local cl = Instance.new("TextButton", h)
    cl.Size=UDim2.new(1,0,1,0); cl.BackgroundTransparency=1; cl.Text=""
    cl.MouseButton1Click:Connect(function() set(not st) end)
    return {setState=set, getState=function() return st end}
end

function CM.slider(parent, key, mn, mx, def, cb)
    local h = Instance.new("Frame", parent)
    h.Size=UDim2.new(1,0,0,48); h.BackgroundColor3=CM.BG2
    h.BackgroundTransparency=CM.bgT; h.BorderSizePixel=0
    local hc=Instance.new("UICorner",h); hc.CornerRadius=UDim.new(0,6)
    local l = Instance.new("TextLabel", h)
    l.Size=UDim2.new(1,-20,0,18); l.Position=UDim2.new(0,12,0,4)
    l.BackgroundTransparency=1; l.TextColor3=CM.TXT
    l.Font=Enum.Font.Gotham; l.TextSize=12
    l.TextXAlignment=Enum.TextXAlignment.Left
    local bg = Instance.new("Frame", h)
    bg.Size=UDim2.new(1,-24,0,6); bg.Position=UDim2.new(0,12,1,-15)
    bg.BackgroundColor3=CM.BG3; bg.BorderSizePixel=0
    local bgc=Instance.new("UICorner",bg); bgc.CornerRadius=UDim.new(1,0)
    local sr = (def-mn)/(mx-mn)
    local fill = Instance.new("Frame", bg)
    fill.Size=UDim2.new(sr,0,1,0); fill.BackgroundColor3=CM.AC
    fill.BorderSizePixel=0
    local flc=Instance.new("UICorner",fill); flc.CornerRadius=UDim.new(1,0)
    local k2 = Instance.new("Frame", bg)
    k2.Size=UDim2.new(0,14,0,14); k2.Position=UDim2.new(sr,-7,0.5,-7)
    k2.BackgroundColor3=Color3.new(1,1,1); k2.BorderSizePixel=0; k2.ZIndex=2
    local kc=Instance.new("UICorner",k2); kc.CornerRadius=UDim.new(1,0)
    local val = def; local drag = false
    local function set(v, skip)
        val = math.floor(v*100+0.5)/100
        local rel = math.clamp((val-mn)/(mx-mn),0,1)
        fill.Size=UDim2.new(rel,0,1,0); k2.Position=UDim2.new(rel,-7,0.5,-7)
        l.Text = CM.T(key)..": "..val
        if cb and not skip then cb(val) end
    end
    CM.regSlider(l, key, function() return val end)
    local ca = Instance.new("TextButton", h)
    ca.Size=UDim2.new(1,0,1,0); ca.BackgroundTransparency=1; ca.Text=""
    ca.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true
            local rel=math.clamp((i.Position.X-bg.AbsolutePosition.X)/bg.AbsoluteSize.X,0,1)
            set(mn+(mx-mn)*rel)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local rel=math.clamp((i.Position.X-bg.AbsolutePosition.X)/bg.AbsoluteSize.X,0,1)
            set(mn+(mx-mn)*rel)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
    set(def, true)
    return {setValue=set, getValue=function() return val end}
end

function CM.colorRow(parent, key, def, cb)
    local h = Instance.new("Frame", parent)
    h.Size=UDim2.new(1,0,0,58); h.BackgroundColor3=CM.BG2
    h.BackgroundTransparency=CM.bgT; h.BorderSizePixel=0
    local hc=Instance.new("UICorner",h); hc.CornerRadius=UDim.new(0,6)
    local l = Instance.new("TextLabel", h)
    l.Size=UDim2.new(1,-20,0,18); l.Position=UDim2.new(0,12,0,4)
    l.BackgroundTransparency=1; l.TextColor3=CM.TXT
    l.Font=Enum.Font.Gotham; l.TextSize=12
    l.TextXAlignment=Enum.TextXAlignment.Left
    CM.regT(l, key)
    local row = Instance.new("Frame", h)
    row.Size=UDim2.new(1,-20,0,22); row.Position=UDim2.new(0,12,0,28)
    row.BackgroundTransparency=1
    local rl=Instance.new("UIListLayout",row)
    rl.FillDirection=Enum.FillDirection.Horizontal
    rl.Padding=UDim.new(0,6)
    local cols = {
        Color3.fromRGB(255,255,255), Color3.fromRGB(0,170,255),
        Color3.fromRGB(255,60,60), Color3.fromRGB(70,220,100),
        Color3.fromRGB(255,200,60), Color3.fromRGB(200,80,255),
        Color3.fromRGB(255,130,220), Color3.fromRGB(0,0,0),
    }
    local cur = def
    for _, c in ipairs(cols) do
        local s = Instance.new("TextButton", row)
        s.Size=UDim2.new(0,22,0,22); s.BackgroundColor3=c
        s.BorderSizePixel=0; s.Text=""
        local sc=Instance.new("UICorner",s); sc.CornerRadius=UDim.new(0,5)
        s.MouseButton1Click:Connect(function() cur=c; if cb then cb(c) end end)
    end
    return {getValue=function() return cur end}
end

function CM.feature(parent, key, def, cb)
    local holder = Instance.new("Frame", parent)
    holder.Size=UDim2.new(1,0,0,34); holder.AutomaticSize=Enum.AutomaticSize.Y
    holder.BackgroundTransparency=1
    local vl=Instance.new("UIListLayout",holder); vl.Padding=UDim.new(0,4)
    local head = Instance.new("Frame", holder)
    head.Size=UDim2.new(1,0,0,34); head.BackgroundColor3=CM.BG2
    head.BackgroundTransparency=CM.bgT; head.BorderSizePixel=0
    local hc=Instance.new("UICorner",head); hc.CornerRadius=UDim.new(0,6)
    local ar = Instance.new("TextButton", head)
    ar.Size=UDim2.new(0,24,0,34); ar.Position=UDim2.new(0,4,0,0)
    ar.BackgroundTransparency=1; ar.Text=">"; ar.TextColor3=CM.STX
    ar.Font=Enum.Font.GothamBold; ar.TextSize=12
    local nm = Instance.new("TextLabel", head)
    nm.Size=UDim2.new(1,-120,1,0); nm.Position=UDim2.new(0,30,0,0)
    nm.BackgroundTransparency=1; nm.TextColor3=CM.TXT
    nm.Font=Enum.Font.Gotham; nm.TextSize=13
    nm.TextXAlignment=Enum.TextXAlignment.Left
    CM.regT(nm, key)
    local st = def
    local tg = Instance.new("Frame", head)
    tg.Size=UDim2.new(0,44,0,22); tg.Position=UDim2.new(1,-54,0.5,-11)
    tg.BackgroundColor3 = st and CM.AC or Color3.fromRGB(50,50,65)
    tg.BorderSizePixel=0
    local tcc=Instance.new("UICorner",tg); tcc.CornerRadius=UDim.new(1,0)
    local kn = Instance.new("Frame", tg)
    kn.Size=UDim2.new(0,16,0,16)
    kn.Position = st and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
    kn.BackgroundColor3=Color3.new(1,1,1); kn.BorderSizePixel=0
    local knc=Instance.new("UICorner",kn); knc.CornerRadius=UDim.new(1,0)
    local settings = Instance.new("Frame", holder)
    settings.Size=UDim2.new(1,-20,0,0); settings.Position=UDim2.new(0,20,0,0)
    settings.AutomaticSize=Enum.AutomaticSize.Y
    settings.BackgroundTransparency=1; settings.Visible=false
    local sl=Instance.new("UIListLayout",settings); sl.Padding=UDim.new(0,6)
    local exp = false
    ar.MouseButton1Click:Connect(function()
        exp = not exp
        settings.Visible = exp
        ar.Text = exp and "v" or ">"
    end)
    local function setState(v)
        st = v and true or false
        tg.BackgroundColor3 = st and CM.AC or Color3.fromRGB(50,50,65)
        kn.Position = st and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
        if cb then cb(st) end
    end
    local tcl = Instance.new("TextButton", head)
    tcl.Size=UDim2.new(0,44,0,34); tcl.Position=UDim2.new(1,-54,0,0)
    tcl.BackgroundTransparency=1; tcl.Text=""
    tcl.MouseButton1Click:Connect(function() setState(not st) end)
    return {setState=setState, getState=function() return st end, settings=settings}
end

function CM.hum()
    local c = P.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
function CM.hrp()
    local c = P.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- Create all tabs
CM.mkTab("Combat", "combat", 1)
CM.mkTab("Movement", "movement", 2)
CM.mkTab("Visuals", "visuals", 3)
CM.mkTab("Misc", "misc", 4)
CM.mkTab("Binds", "binds", 5)
CM.mkTab("Configs", "configs", 6)

-- Movement
local pMove = CM.pages["Movement"]
local speed, jump = 16, 50
local noclip, infjump, fly = false, false, false
local bhop, autostrafe = false, false

local fSpeed = CM.feature(pMove, "speed", false, function(v)
    if v then local h=CM.hum(); if h then h.WalkSpeed=speed end
    else local h=CM.hum(); if h then h.WalkSpeed=16 end end
end)
CM.slider(fSpeed.settings, "speed", 1, 200, 16, function(v)
    speed=v; if fSpeed.getState() then local h=CM.hum(); if h then h.WalkSpeed=speed end end
end)
local fJump = CM.feature(pMove, "jump", false, function(v)
    if v then local h=CM.hum(); if h then h.JumpPower=jump end
    else local h=CM.hum(); if h then h.JumpPower=50 end end
end)
CM.slider(fJump.settings, "jump", 0, 300, 50, function(v)
    jump=v; if fJump.getState() then local h=CM.hum(); if h then h.JumpPower=jump end end
end)
CM.btn(fJump.settings, "reset", function()
    speed=16; jump=50
    local h=CM.hum(); if h then h.WalkSpeed=16; h.JumpPower=50 end
end)
local fNoclip = CM.feature(pMove, "noclip", false, function(v) noclip=v end)
local fInf = CM.feature(pMove, "infjump", false, function(v) infjump=v end)
local fFly = CM.feature(pMove, "fly", false, function(v) fly=v end)
local fBhop = CM.feature(pMove, "bhop", false, function(v) bhop=v end)
local fStr = CM.feature(pMove, "autostrafe", false, function(v) autostrafe=v end)

-- Binds
local pBind = CM.pages["Binds"]
local bInfo = Instance.new("TextLabel", pBind)
bInfo.Size=UDim2.new(1,0,0,22); bInfo.BackgroundTransparency=1
bInfo.TextColor3=CM.STX; bInfo.Font=Enum.Font.Gotham
bInfo.TextSize=11; bInfo.TextXAlignment=Enum.TextXAlignment.Left
CM.regT(bInfo, "bindhint")

function CM.addBind(name, tog)
    local row = Instance.new("Frame", pBind)
    row.Size=UDim2.new(1,0,0,36); row.BackgroundColor3=CM.BG2
    row.BackgroundTransparency=CM.bgT; row.BorderSizePixel=0
    local rc=Instance.new("UICorner",row); rc.CornerRadius=UDim.new(0,6)
    local nm = Instance.new("TextLabel", row)
    nm.Size=UDim2.new(1,-260,1,0); nm.Position=UDim2.new(0,12,0,0)
    nm.BackgroundTransparency=1; nm.Text=name; nm.TextColor3=CM.TXT
    nm.Font=Enum.Font.Gotham; nm.TextSize=13
    nm.TextXAlignment=Enum.TextXAlignment.Left
    local kl = Instance.new("TextButton", row)
    kl.Size=UDim2.new(0,90,0,24); kl.Position=UDim2.new(1,-200,0.5,-12)
    kl.BackgroundColor3=CM.BG3; kl.BorderSizePixel=0
    kl.Text="None"; kl.TextColor3=CM.TXT
    kl.Font=Enum.Font.GothamMedium; kl.TextSize=12
    local kc=Instance.new("UICorner",kl); kc.CornerRadius=UDim.new(0,5)
    local bb = Instance.new("TextButton", row)
    bb.Size=UDim2.new(0,90,0,24); bb.Position=UDim2.new(1,-100,0.5,-12)
    bb.BackgroundColor3=CM.AC; bb.BorderSizePixel=0
    bb.Text="Bind"; bb.TextColor3=Color3.new(1,1,1)
    bb.Font=Enum.Font.GothamMedium; bb.TextSize=12
    local bc=Instance.new("UICorner",bb); bc.CornerRadius=UDim.new(0,5)
    local entry = {name=name, toggleObj=tog, keyCode=nil, labelUI=kl, bindBtn=bb}
    table.insert(CM.binds, entry)
    bb.MouseButton1Click:Connect(function()
        CM.waitingBind=entry; bb.Text="..."; bb.BackgroundColor3=Color3.fromRGB(230,180,50)
    end)
    kl.MouseButton1Click:Connect(function()
        entry.keyCode=nil; kl.Text="None"
    end)
end

CM.addBind("Noclip", fNoclip)
CM.addBind("Infinite Jump", fInf)
CM.addBind("Fly", fFly)
CM.addBind("BHop", fBhop)
CM.addBind("Autostrafe", fStr)

-- Configs
local pCfg = CM.pages["Configs"]
local cfgName = "default"
local cfgInp = Instance.new("TextBox", pCfg)
cfgInp.Size=UDim2.new(1,0,0,34); cfgInp.BackgroundColor3=CM.BG2
cfgInp.BackgroundTransparency=CM.bgT; cfgInp.BorderSizePixel=0
cfgInp.Text="default"; cfgInp.PlaceholderText="Name"
cfgInp.TextColor3=CM.TXT; cfgInp.Font=Enum.Font.Gotham; cfgInp.TextSize=13
cfgInp.ClearTextOnFocus=false
local cic=Instance.new("UICorner",cfgInp); cic.CornerRadius=UDim.new(0,6)
cfgInp.FocusLost:Connect(function() cfgName = cfgInp.Text ~= "" and cfgInp.Text or "default" end)

local function cfgPath(n) return "cv24_"..n..".json" end
function CM.saveCfg(n)
    local d = {}
    for k,v in pairs(CM.cfgs) do d[k]=v.get() end
    local ok, enc = pcall(function() return HS:JSONEncode(d) end)
    if not ok then return false end
    if writefile then return pcall(writefile, cfgPath(n), enc) end
    _G.__C= _G.__C or {}; _G.__C[n]=enc; return true
end
function CM.loadCfg(n)
    local raw
    if readfile and isfile then
        local ok, ex = pcall(isfile, cfgPath(n))
        if ok and ex then
            local ok2, r = pcall(readfile, cfgPath(n))
            if ok2 then raw=r end
        end
    end
    if not raw and _G.__C then raw=_G.__C[n] end
    if not raw then return nil end
    local ok, t = pcall(function() return HS:JSONDecode(raw) end)
    return ok and t or nil
end
function CM.applyCfg(d)
    if type(d)~="table" then return end
    for k,v in pairs(d) do
        if CM.cfgs[k] then pcall(CM.cfgs[k].set, v) end
    end
end

CM.btn(pCfg, "cfgsave", function(b)
    if CM.saveCfg(cfgName) then b.Text="OK: "..cfgName else b.Text="Err" end
    task.delay(2, function() b.Text=CM.T("cfgsave") end)
end)
CM.btn(pCfg, "cfgload", function(b)
    local d = CM.loadCfg(cfgName)
    if d then CM.applyCfg(d); b.Text="OK" else b.Text="Not found" end
    task.delay(2, function() b.Text=CM.T("cfgload") end)
end)

-- Input
UIS.InputBegan:Connect(function(input, gp)
    if CM.waitingBind then
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            CM.waitingBind.keyCode = input.KeyCode
            CM.waitingBind.labelUI.Text = input.KeyCode.Name
            CM.waitingBind.bindBtn.Text = "Bind"
            CM.waitingBind.bindBtn.BackgroundColor3 = CM.AC
            CM.waitingBind = nil
        end
        return
    end
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Delete then
        if not gui.Parent then return end
        f.Visible = not f.Visible
        blur.Size = f.Visible and 22 or 0
        return
    end
    for _, e in ipairs(CM.binds) do
        if e.keyCode and input.KeyCode == e.keyCode then
            e.toggleObj.setState(not e.toggleObj.getState())
            return
        end
    end
end)

-- Loops
RS.Stepped:Connect(function()
    if noclip then
        local c = P.Character
        if c then for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end end
    end
end)

UIS.JumpRequest:Connect(function()
    if infjump then local h=CM.hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)

RS.Stepped:Connect(function()
    if not bhop then return end
    local h = CM.hum()
    if h and h.FloorMaterial ~= Enum.Material.Air then h.Jump = true end
end)

RS.Heartbeat:Connect(function(dt)
    if not autostrafe then return end
    local h = CM.hum(); local r = CM.hrp()
    if not h or not r then return end
    if h.FloorMaterial == Enum.Material.Air then
        local v = Vector3.new(r.Velocity.X, 0, r.Velocity.Z)
        if v.Magnitude > 5 then
            local lk = cam.CFrame.LookVector
            local l2 = Vector3.new(lk.X, 0, lk.Z).Unit
            local vu = v.Unit
            local cr = l2:Cross(vu).Y
            cam.CFrame = cam.CFrame * CFrame.Angles(0, -cr*math.rad(3)*dt*60, 0)
        end
    end
end)

local bgB, bvB
RS.RenderStepped:Connect(function()
    local r = CM.hrp()
    if not r then
        if bgB then bgB:Destroy(); bgB=nil end
        if bvB then bvB:Destroy(); bvB=nil end
        return
    end
    if fly then
        if not bvB then
            bgB = Instance.new("BodyGyro", r)
            bgB.P=9e4; bgB.MaxTorque=Vector3.new(9e9,9e9,9e9)
            bgB.CFrame=r.CFrame
            bvB = Instance.new("BodyVelocity", r)
            bvB.Velocity=Vector3.new(0,0,0)
            bvB.MaxForce=Vector3.new(9e9,9e9,9e9)
        end
        local c = workspace.CurrentCamera
        local mv = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then mv = mv + c.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then mv = mv - c.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then mv = mv - c.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then mv = mv + c.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv = mv - Vector3.new(0,1,0) end
        if mv.Magnitude > 0 then mv = mv.Unit end
        bgB.CFrame = c.CFrame
        bvB.Velocity = mv * 60
    else
        if bgB then bgB:Destroy(); bgB=nil end
        if bvB then bvB:Destroy(); bvB=nil end
    end
end)

CM.tabs["Combat"].BackgroundColor3 = CM.AC
CM.tabs["Combat"].TextColor3 = Color3.new(1,1,1)
CM.pages["Combat"].Visible = true
