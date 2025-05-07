-- 绑定重音符键来启动自动点击
hs.hotkey.bind({"cmd"}, "`", function()
    -- 执行移动操作
    moveMouseToPosition(1740/2, 1424/2)
end)


-- 移动鼠标指针到特定坐标
-- 坐标值: x=1740, y=1424
-- 函数：移动鼠标到指定位置
function moveMouseToPosition(x, y)
    -- 获取当前鼠标位置（用于日志）
    local currentPos = hs.mouse.absolutePosition()

    -- 移动鼠标到新位置
    hs.mouse.absolutePosition({x=x, y=y})

    -- 打印日志信息
    print(string.format("鼠标已从 (%.0f, %.0f) 移动到 (%.0f, %.0f)",
            currentPos.x, currentPos.y, x, y))
end
