----------------------------------------------------------------------------------------------------
-- Register hammerspoon Reload config file
hsreload_keys = hsreload_keys or {{"cmd", "shift", "ctrl"}, "R"}
if string.len(hsreload_keys[2]) > 0 then
    hs.hotkey.bind(hsreload_keys[1], hsreload_keys[2], "Reload Configuration", function() hs.reload() end)
end
----------------------------------------------------------------------------------------------------
-- Define default Spoons which will be loaded later
if not hspoon_list then
    hspoon_list = {
        "BingDaily",
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