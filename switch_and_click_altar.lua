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

                            -- 移动鼠标到匹配的中心
                            moveAndClick(match.center_x, match.center_y)

                            moveAndClick(1148, 783)
                            print("已经选择好了选项",response.target_name)
                            moveMouse(886,751)
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


-- 开始按照顺序查找图片
function imageFinder:startSequentialSearch()
    imageFinder:findImage()
end

-- 初始化提示
hs.alert.show("祭坛选项插件已启动", 2)

return imageFinder
