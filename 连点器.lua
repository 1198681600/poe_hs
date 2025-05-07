-- 自动点击工具
local autoClicker = {
    timer = nil,
    clickCount = 0,
    maxClicks = 6000
}

-- 开始自动点击
function autoClicker:start()
    -- 如果计时器已经存在，先清除
    if self.timer then
        self:stop()
        return
    end

    -- 重置计数器
    self.clickCount = 0

    -- 创建计时器，每秒执行一次
    self.timer = hs.timer.doEvery(0.1, function()
        -- 执行鼠标左键点击
        local currentPosition = hs.mouse.getAbsolutePosition()

        -- 使用eventtap.leftClick会移动鼠标，所以我们改用低级事件
        hs.eventtap.event.newMouseEvent(
                hs.eventtap.event.types.leftMouseDown,
                currentPosition
        ):post()

        hs.eventtap.event.newMouseEvent(
                hs.eventtap.event.types.leftMouseUp,
                currentPosition
        ):post()


        -- 增加计数
        self.clickCount = self.clickCount + 1

        -- 显示通知
        hs.printf("自动点击: %d/%d", self.clickCount, self.maxClicks)

        -- 如果达到最大点击次数，停止计时器
        if self.clickCount >= self.maxClicks then
            self:stop()
            hs.alert.show("自动点击完成: 已执行" .. self.clickCount .. "次点击")
        end
    end)

    hs.alert.show("自动点击已启动：每秒1次，持续60秒")
    hs.printf("自动点击已启动: 每秒1次，持续60秒")
end

-- 停止自动点击
function autoClicker:stop()
    if self.timer then
        self.timer:stop()
        self.timer = nil
        hs.alert.show("自动点击已停止: 已执行" .. self.clickCount .. "次点击")
        hs.printf("自动点击已停止: 已执行%d次点击", self.clickCount)
    end
end

-- 绑定重音符键来启动自动点击
hs.hotkey.bind({"cmd"}, "`", function()
    autoClicker:start()
end)

-- 提示已加载
hs.alert.show("自动点击器已加载\n按 ` 键开始")
