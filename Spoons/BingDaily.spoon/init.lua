--- === BingDaily ===
---
--- Use Bing daily picture as your wallpaper, automatically.
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/BingDaily.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/BingDaily.spoon.zip)

local obj={}
obj.__index = obj

-- Metadata
-- obj.name = "BingDaily"
-- obj.version = "1.1"
-- obj.author = "ashfinal <ashfinal@gmail.com>"
-- obj.homepage = "https://github.com/Hammerspoon/Spoons"
-- obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.name = "BingDaily"
obj.version = "1.2"
obj.author = "nishizhen <nishizhen@gmail.com>"
obj.homepage = "https://github.com/nishizhen/hammerspoon-config"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- BingDaily.uhd_resolution
--- Variable
--- If `true`, download image in UHD resolution instead of HD. Defaults to `false`.
obj.uhd_resolution = true
obj.copyright = ""
obj.title = ""

local function curl_callback(exitCode, stdOut, stdErr)
    if exitCode == 0 then
        obj.task = nil
        obj.last_pic = obj.file_name
        local localpath = os.getenv("HOME") .. "/Pictures/BingDaily/" .. obj.file_name
        -- set wallpaper for all screens
        allScreen = hs.screen.allScreens()
        for _,screen in ipairs(allScreen) do
            screen:desktopImageURL("file://" .. localpath)
        end

        if obj.canvas then
            obj.canvas[2].text = obj.title
            obj.canvas[4].text = obj.copyright
            obj.canvas:show()
        end
        
    else
        print(stdOut, stdErr)
    end
end

local function bingRequest()
    local user_agent_str = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36 Edg/107.0.1418.56"
    local json_req_url = "http://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1"
    hs.http.asyncGet(json_req_url, {["User-Agent"]=user_agent_str}, function(stat,body,header)
        if stat == 200 then
            if pcall(function() hs.json.decode(body) end) then
                local decode_data = hs.json.decode(body)
                local pic_url = decode_data.images[1].url

                -- Get image title and copyright text
                obj.copyright = decode_data.images[1].copyright
                obj.title = decode_data.images[1].title

                if obj.uhd_resolution then
                    pic_url = pic_url:gsub("1920x1080", "UHD")
                end
                local pic_name = "pic-temp-spoon.jpg"
                for k, v in pairs(hs.http.urlParts(pic_url).queryItems) do
                    if v.id then
                        pic_name = v.id
                        break
                    end
                end
                if obj.last_pic ~= pic_name then
                    obj.file_name = pic_name
                    obj.full_url = "https://www.bing.com" .. pic_url
                    if obj.task then
                        obj.task:terminate()
                        obj.task = nil
                    end
                    local localpath = os.getenv("HOME") .. "/Pictures/BingDaily/" .. obj.file_name
                    obj.task = hs.task.new("/usr/bin/curl", curl_callback, {"-A", user_agent_str, obj.full_url, "-o", localpath})
                    obj.task:start()
                end
            end
        else
            print("Bing URL request failed!")
        end
    end)
end

obj.hcalw = 750
obj.hcalh = 100
--- Create the title canvas
function obj:createCanvas()
    if obj.canvas then
        return obj.canvas
    end

    local hcalbgcolor = {red=0, blue=0, green=0, alpha=0.3}
    local hcaltitlecolor = {red=1, blue=1, green=1, alpha=0.8}    
    local midlinecolor = {red=1, blue=1, green=1, alpha=0.5}
    local cscreen = hs.screen.mainScreen()
    local cres = cscreen:fullFrame()
    local canvas = hs.canvas.new({
        x = cres.w-obj.hcalw-40,
        y = cres.h-obj.hcalh-80,
        w = obj.hcalw,
        h = obj.hcalh,
    })

    canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
    canvas:level(hs.canvas.windowLevels.desktopIcon)
    -- bg rectangle
    canvas[1] = {
        id = "bingdaily_bg",
        type = "rectangle",
        action = "fill",
        fillColor = hcalbgcolor,
        roundedRectRadii = {xRadius = 10, yRadius = 10},
    }
    -- title text
    canvas[2] = {
        id = "bingdaily_title",
        type = "text",
        text = obj.title,
        textSize = 28,
        textColor = hcaltitlecolor,
        textAlignment = "right",
        frame = {
            x = tostring(10/obj.hcalw),
            y = tostring(10/obj.hcalh),
            w = tostring(1-20/obj.hcalw),
            h = "30%"
        }
    }
    -- midline rectangle
    canvas[3] = {
        type = "rectangle",
        action = "fill",
        fillColor = midlinecolor,
        frame = {
            x = 0,
            y = "50%",
            w = "100%",
            h = "4%"
        }
    }
    -- copyright text
    canvas[4] = {
        id = "bingdaily_copyright",
        type = "text",
        text = obj.copyright,
        textSize = 18,
        textColor = hcaltitlecolor,
        textAlignment = "right",
        frame = {
            x = tostring(10/obj.hcalw),
            y = tostring(64/obj.hcalh),
            w = tostring(1-20/obj.hcalw),
            h = "26%"
        }
    }
    return canvas
end

function obj:init()
    self.canvas = self:createCanvas()

    if obj.timer == nil then
        obj.timer = hs.timer.doEvery(3*60*60, function() bingRequest() end)
        obj.timer:setNextTrigger(5)
    else
        obj.timer:start()
    end

end

return obj
