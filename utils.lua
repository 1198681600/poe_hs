-- utils.lua
local utils = {}
-- 休眠函数（阻塞方式）
function blockingSleep(seconds)
    hs.timer.usleep(seconds * 1000000)
end
-- 格式化日期时间
function formatDateTime(format)
    format = format or "%Y-%m-%d %H:%M:%S"
    return os.date(format)
end
-- 安全地获取表中的嵌套值
function getNestedValue(tbl, ...)
    local value = tbl
    for _, key in ipairs({...}) do
        if type(value) ~= "table" then
            return nil
        end
        value = value[key]
        if value == nil then
            return nil
        end
    end
    return value
end
-- 安全地执行函数，捕获错误并返回状态
function safeExecute(func, ...)
    local status, result = pcall(func, ...)
    return status, result
end
-- 简单的防抖函数
function debounce(func, wait)
    local timer = nil
    return function(...)
        local args = {...}
        if timer then
            timer:stop()
        end
        timer = hs.timer.doAfter(wait, function()
            func(table.unpack(args))
            timer = nil
        end)
    end
end
-- 简单的节流函数
function throttle(func, limit)
    local lastRun = 0
    return function(...)
        local now = hs.timer.secondsSinceEpoch()
        if (now - lastRun) > limit then
            func(...)
            lastRun = now
        end
    end
end
-- 随机生成UUID
function generateUUID()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return string.gsub(template, "[xy]", function(c)
        local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format("%x", v)
    end)
end
-- 移动并按下
function moveAndClick(x, y)
    hs.mouse.absolutePosition({x=x, y=y})
    blockingSleep(0.1)
    hs.eventtap.leftClick({x=x, y=y},50000)
    blockingSleep(0.1)
end

-- 移动鼠标到指定位置
function moveMouse(x, y)
    hs.mouse.absolutePosition({x=x, y=y})
end



return utils