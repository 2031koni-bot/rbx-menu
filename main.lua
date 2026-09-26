local BASE = "https://raw.githubusercontent.com/2031koni-bot/rbx-menu/main/"

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
