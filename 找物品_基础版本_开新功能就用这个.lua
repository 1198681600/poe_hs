-- 图像查找器模块
local imageFinder = {}
-- 存储当前显示的所有边框
imageFinder.highlightBoxes = {}

-- 清除当前显示的所有边框
function imageFinder:clearHighlights()
    for _, box in ipairs(self.highlightBoxes) do
        box:delete()
    end
    self.highlightBoxes = {}
end

-- 在屏幕上绘制边框来突出显示找到的图像
function imageFinder:drawHighlight(x, y, width, height, confidence)
    print(string.format("查到内容: x=%d, y=%d, width=%d, height=%d, confidence=%.2f%%",
            x, y, width, height, confidence * 100))

    -- 创建新的边框
    local box = hs.canvas.new({x=x, y=y, w=width, h=height})

    -- 设置边框样式
    box:appendElements({
        type = "rectangle",
        action = "stroke",
        strokeColor = {red=1, green=0.2, blue=0.2, alpha=0.8},  -- 红色边框
        strokeWidth = 3,
        roundedRectRadii = {xRadius=5, yRadius=5},  -- 圆角矩形
        frame = {x=0, y=0, w="100%", h="100%"}
    }, {
        type = "rectangle",
        action = "fill",
        fillColor = {red=1, green=0.2, blue=0.2, alpha=0.2},  -- 半透明填充
        roundedRectRadii = {xRadius=5, yRadius=5},
        frame = {x=0, y=0, w="100%", h="100%"}
    })

    -- 显示边框
    box:show()

    -- 添加到边框列表中
    table.insert(self.highlightBoxes, box)
end

-- 移动鼠标到指定位置
function imageFinder:moveMouse(x, y)
    hs.mouse.absolutePosition({x=x, y=y})
end

-- API请求函数
function imageFinder:findImage()
    -- 准备要发送的JSON数据
    local requestData = {
        target_enum = "target"
    }

    -- 将Lua表转换为JSON字符串
    local jsonData = hs.json.encode(requestData)

    -- 准备HTTP头信息
    local headers = {
        ["Content-Type"] = "application/json"
    }

    -- 执行HTTP POST请求
    hs.http.asyncPost(
            "http://127.0.0.1:8077/find_image",
            jsonData,
            headers,
            function(status, body, responseHeaders)
                -- 检查请求状态
                if status == 200 then
                    -- 尝试解析JSON响应
                    local success, response = pcall(function() return hs.json.decode(body) end)
                    if success then
                        -- 格式化JSON以便更好地显示
                        local formattedResponse = hs.inspect(response)
                        print("API响应:", formattedResponse)

                        -- 检查是否成功找到图像
                        if response.status == "success" and response.count > 0 then
                            -- 清除之前的高亮
                            self:clearHighlights()

                            -- 显示成功消息
                            hs.alert.show(string.format(
                                    "找到 %d 个匹配结果!",
                                    response.count
                            ), 2)

                            -- 处理所有匹配结果
                            for i, match in ipairs(response.matches) do
                                -- 在屏幕上绘制边框
                                self:drawHighlight(
                                        match.top_left_x,
                                        match.top_left_y,
                                        match.width,
                                        match.height,
                                        match.confidence
                                )
                            end

                            -- 如果有匹配结果，移动鼠标到第一个匹配的中心
                            if #response.matches > 0 then
                                local firstMatch = response.matches[1]
                                --self:moveMouse(firstMatch.center_x, firstMatch.center_y)
                            end

                            -- 设置边框自动消失的计时器 (5秒后)
                            hs.timer.doAfter(5, function() self:clearHighlights() end)
                        else
                            -- 显示未找到图像的消息
                            hs.alert.show("未找到图像", 2)
                        end
                    else
                        hs.alert.show("无法解析JSON响应", 2)
                        print("无法解析的响应:", body)
                    end
                else
                    -- 显示错误信息
                    hs.alert.show("请求失败: " .. status, 2)
                    print("请求失败, 状态码:", status)
                    print("响应内容:", body)
                end
            end
    )
end

-- 注册快捷键：⌘+⇧+F (Command+Shift+F)
hs.hotkey.bind({"cmd", "shift"}, "F", function()
    hs.alert.show("正在查找图像...", 1)
    imageFinder:findImage()
end)

-- 初始化提示
hs.alert.show("图像查找器已加载!\n按下 ⌘+⇧+F 查找图像", 2)

return imageFinder
