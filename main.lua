local BASE = "https://raw.githubusercontent.com/2031koni-bot/rbx-menu/main/"

-- Очистка от предыдущего запуска
pcall(function()
    for _, g in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if g.Name == "CustomMenu" or g.Name == "CM_FOV" or g.Name == "CM_WM" then
            g:Destroy()
        end
    end
end)
pcall(function()
    local pg = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        for _, g in ipairs(pg:GetChildren()) do
            if g.Name == "CustomMenu" or g.Name == "CM_FOV" or g.Name == "CM_WM" then
                g:Destroy()
            end
        end
    end
end)
pcall(function()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == "Halo" or obj.Name == "Orbs" then obj:Destroy() end
    end
end)
_G.CM = nil

local function loadm(name)
    local ok, src = pcall(function() return game:HttpGet(BASE..name..".lua") end)
    if not ok or not src then warn("[CM] HTTP fail: "..name); return end
    local fn, err = loadstring(src)
    if not fn then warn("[CM] Compile fail "..name..": "..tostring(err)); return end
    local ok2, err2 = pcall(fn)
    if not ok2 then warn("[CM] Runtime fail "..name..": "..tostring(err2)) end
end

loadm("core")
loadm("visuals")
loadm("combat")
loadm("misc")

print("[CM] all modules loaded")
