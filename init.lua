
----------------------------------------------------------------------------------------------------
-- Register hammerspoon Reload config file
hsreload_keys = hsreload_keys or {{"cmd", "shift", "ctrl"}, "R"}
if string.len(hsreload_keys[2]) > 0 then
    hs.hotkey.bind(hsreload_keys[1], hsreload_keys[2], "Reload Configuration", function()
        hs.reload()
    end)
end
----------------------------------------------------------------------------------------------------
-- Auto Start brew bundle backup
-- hs.hotkey.bind({"cmd", "ctrl"}, "T", function()
    local autoDumpBrewBundleTimer = hs.timer.doEvery(6 * 60 * 60, function()
        local brewFilePath, brewFileName = "~/Documents/", "Brewfile"
        local notifyTitle = "Auto dump Brew bundle result"
        local result = hs.execute("cd " .. brewFilePath .. " && brew bundle dump -f", true)
        local BrewfileModTime = hs.fs.attributes(brewFilePath .. brewFileName, "modification")
        local diff = os.time() - BrewfileModTime
        if diff < 5 then
            if diff >= 0 then
                hs.notify.show(notifyTitle, "Success!", "Brewfile path: " .. brewFilePath .. brewFileName)
            else
                hs.notify.show(notifyTitle, "Error!!!!!", "")
            end
        else
            hs.notify.show(notifyTitle, "Error!!!!!", "")
        end
    end)
    autoDumpBrewBundleTimer:setNextTrigger(5)
    autoDumpBrewBundleTimer:start()
    -- end)
----------------------------------------------------------------------------------------------------
-- Define default Spoons which will be loaded later
if not hspoon_list then
    hspoon_list = {"BingDaily"
    -- "HCalendar",
    -- "WinWin",
    -- "FnMate",
    }
end
-- Load those Spoons
for _, v in pairs(hspoon_list) do
    hs.loadSpoon(v)
end
----------------------------------------------------------------------------------------------------
-- Register windowHints
hs.hotkey.bind({"alt"}, "tab", function()
    hs.hints.windowHints()
end)
----------------------------------------------------------------------------------------------------
-- Register lock screen
hs.hotkey.bind({"cmd"}, "L", function()
    hs.caffeinate.lockScreen()
end)
