local BASE = "https://raw.githubusercontent.com/mitchellcirey/LT2Scripts/main/"
local FILES = {
    "Duper.lua",
}

local function fetch(path)
    return game:HttpGet(BASE .. path .. "?t=" .. tostring(os.time()))
end

local parts = table.create(#FILES)
for i, file in ipairs(FILES) do
    parts[i] = fetch(file)
end

assert(loadstring(table.concat(parts, "\n"), "LT2Duper"))()
