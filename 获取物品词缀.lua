-- 注册快捷键：⌘+⇧+F (Command+Shift+F)
hs.hotkey.bind({"cmd", "shift"}, "`", function()
    -- 读取剪贴板内容
    local clipboardContent = hs.pasteboard.getContents()

    -- 判断剪贴板内容是否存在
    if clipboardContent then
        -- 打印到 Hammerspoon 控制台
        print("-------------- 剪贴板内容 --------------")
        print(clipboardContent)
        print("---------------------------------------")
    end
end)

-- 可选：添加一条提示消息，表明脚本已加载
print("剪贴板读取功能已加载 - 使用 ⌘+⇧+F 读取剪贴板内容")
