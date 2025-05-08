-- 图像查找器模块
local imageFinder = {}

-- 存储当前显示的所有边框
imageFinder.highlightBoxes = {}

-- 图片查找顺序定义
imageFinder.targetSequence = {
    "药剂减速",
    "竞技场变小",
    "虹吸",
    "怪物暴击",
    "剃刀",
    "怪物加属性伤害",
    "怪物加速",
    "怪物必中",
    "寒冰爆炸",
    "喷火骷髅",
    "增益消失加快",
    "承伤",
    "无敌图腾",
    "毒云",
    "脆弱",
    "拿走能量球",
    "图腾",
    "回复降低",
    "催灭",
    "催灭2",
}

-- 清除当前显示的所有边框
function imageFinder:clearHighlights()
    for _, box in ipairs(self.highlightBoxes) do
        box:delete()
    end
    self.highlightBoxes = {}
end

-- 在屏幕上绘制边框来突出显示找到的图像
function imageFinder:drawHighlight(x, y, width, height, confidence, targetName)
    print(string.format("找到图片 '%s': x=%d, y=%d, width=%d, height=%d, confidence=%.2f%%",
            targetName, x, y, width, height, confidence * 100))

    -- 显示找到的图片名称的提示
    hs.alert.show("找到: " .. targetName, 2)

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
    }, {
        type = "text",
        text = targetName,
        textSize = 14,
        textColor = {white = 1, alpha = 1},
        textAlignment = "center",
        frame = {x=0, y=height+5, w=width, h=20}
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

function imageFinder:click(x, y)
    hs.mouse.absolutePosition({x=x, y=y})
    blockingSleep(0.1)
    hs.eventtap.leftClick({x=x, y=y},50000)
    blockingSleep(0.1)
end

-- API请求函数 - 修改为支持回调
function imageFinder:findImage()
    -- 准备要发送的JSON数据
    local requestData = {
        targets = imageFinder.targetSequence,
        max_results = 1,
        use_gray = false
    }

    -- 将Lua表转换为JSON字符串
    local jsonData = hs.json.encode(requestData)

    -- 准备HTTP头信息
    local headers = {
        ["Content-Type"] = "application/json"
    }

    -- 执行HTTP POST请求
    hs.http.asyncPost(
            "http://127.0.0.1:8077/find_first_match",
            jsonData,
            headers,
            function(status, body, responseHeaders)
                local found = false

                -- 检查请求状态
                if status == 200 then
                    -- 尝试解析JSON响应
                    local success, response = pcall(function() return hs.json.decode(body) end)
                    if success then
                        -- 检查是否成功找到图像
                        if response.status == "success" and response.count > 0 then
                            -- 处理第一个匹配结果
                            local match = response.matches[1]

                            -- 在屏幕上绘制边框
                            self:drawHighlight(
                                    match.top_left_x,
                                    match.top_left_y,
                                    match.width,
                                    match.height,
                                    match.confidence,
                                    response.target_name
                            )

                            -- 移动鼠标到匹配的中心
                            self:click(match.center_x, match.center_y)

                            self:click(1148, 783)

                            -- 设置边框自动消失的计时器 (3秒后)
                            hs.timer.doAfter(1, function() self:clearHighlights() end)

                            self:moveMouse(886,751)
                            -- 设置为已找到
                            found = true
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

function blockingSleep(seconds)
    hs.timer.usleep(seconds * 1000000)
end


-- 开始按照顺序查找图片
function imageFinder:startSequentialSearch()
    -- 清除可能存在的高亮显示
    self:clearHighlights()

    self:findImage()
end

-- 注册快捷键：⌘+⇧+F (Command+Shift+F)
hs.hotkey.bind({}, "`", function()
    imageFinder:startSequentialSearch()
end)

-- 初始化提示
hs.alert.show("增强版图像查找器已加载!\n按下 ⌘+⇧+F 按顺序查找图像", 2)

return imageFinder
