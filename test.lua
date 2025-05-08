
--a = 0
--
--local downEvent = hs.eventtap.event.newKeyEvent({}, "w", true)
---- 创建按键释放事件
--local upEvent = hs.eventtap.event.newKeyEvent({}, "w", false)
--
---- 绑定重音符键来启动自动点击
--hs.hotkey.bind({}, "`", function()
--    if a ==0 then
--        -- 发送按键按下事件
--        downEvent:post()
--        a = 1
--    else
--        -- 发送按键释放事件
--        upEvent:post()
--        a = 0
--    end
--end)
--


hs.hotkey.bind({}, "`", function()

end)
