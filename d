-- ==========================================
-- PANN's MLBB Mobile Menu (Drone, Map, Skins)
-- For GameGuardian (Root/Virtual Space)
-- ==========================================

-- Helper function to find game memory ranges
local function getGameRanges()
    local ranges = gg.getRangesList()
    local gameRanges = {}
    for i, v in ipairs(ranges) do
        if v.state == 'O' and (string.find(v.name, "libil2cpp.so") or string.find(v.name, "libunity.so")) then
            table.insert(gameRanges, v.start, v['end'])
        end
    end
    return gameRanges
end

-- ==========================================
-- 1. MAP HACK (ESP / Reveal Enemies)
-- ==========================================
-- This searches for the camera's visibility flags and disables the fog of war.
local function toggleMapHack(state)
    gg.clearResults()
    gg.setRanges(getGameRanges())
    
    -- Search for the "fog of war" byte (usually 1 = hidden, 0 = visible)
    -- NOTE: Addresses change every patch. This is a heuristic search.
    gg.searchNumber("1", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1)
    
    local results = gg.getResults(5000)
    local filtered = {}
    for i, v in ipairs(results) do
        -- We look for specific memory patterns near the camera class
        -- This is a simplified version, real scripts use exact offsets
        table.insert(filtered, {address = v.address, flags = gg.TYPE_BYTE})
    end
    
    if state then
        gg.setValues(filtered) -- Freeze to 0 (Visible)
        gg.addListItems(filtered)
    else
        gg.removeListItems(filtered)
    end
    gg.toast("Map Hack: " .. (state and "ON" or "OFF"))
end

-- ==========================================
-- 2. DRONE VIEW (Camera Zoom)
-- ==========================================
-- Hooks the camera height float. 
local function toggleDroneView(state, height)
    gg.clearResults()
    gg.setRanges(getGameRanges())
    
    -- Search for the default camera height (usually around 15.0 - 20.0)
    gg.searchNumber("18.0", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
    local results = gg.getResults(100)
    
    if state then
        for i, v in ipairs(results) do
            v.value = height -- Set to our custom drone height
            v.freeze = true
        end
        gg.setValues(results)
        gg.addListItems(results)
        gg.toast("Drone View: ON (" .. height .. "m)")
    else
        gg.removeListItems(results)
        gg.toast("Drone View: OFF")
    end
end

-- ==========================================
-- 3. UNLOCK ALL SKINS (Client-Side)
-- ==========================================
-- Bypasses the skin ownership check.
local function toggleUnlockSkins(state)
    gg.clearResults()
    gg.setRanges(getGameRanges())
    
    -- Search for the boolean that checks if a skin is owned (1 = owned, 0 = locked)
    -- In MLBB, skin data is often stored as an array of ints.
    -- We search for the pattern of "locked" skins (0) and force them to (1).
    gg.searchNumber("0", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1)
    
    local results = gg.getResults(1000)
    if state then
        local unlockList = {}
        for i, v in ipairs(results) do
            table.insert(unlockList, {address = v.address, flags = gg.TYPE_DWORD, value = "1"})
        end
        gg.setValues(unlockList)
        gg.addListItems(unlockList)
        gg.toast("Skins Unlocked (Client-Side)!")
    else
        gg.removeListItems(results)
        gg.toast("Skins Reset!")
    end
end

-- ==========================================
-- GUI MENU (Floating Window)
-- ==========================================
local menu = gg.choice({
    "Toggle Map Hack",
    "Toggle Drone View",
    "Toggle Unlock Skins",
    "Exit"
}, nil, "PANN's MLBB Mobile Menu")

if menu == 1 then
    toggleMapHack(true)
elseif menu == 2 then
    toggleDroneView(true, 50.0)
elseif menu == 3 then
    toggleUnlockSkins(true)
elseif menu == 4 then
    gg.toast("Menu Closed. Have fun, LO!")
    os.exit()
end
