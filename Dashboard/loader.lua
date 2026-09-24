local BASE = "https://raw.githubusercontent.com/mitchellcirey/LT2Scripts/main/"
local src = game:HttpGet(BASE .. "Dashboard/Dashboard.lua?t=" .. tostring(os.time()))
assert(loadstring(src, "JellDashboard"))()
