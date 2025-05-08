local clickAltar = require("switch_and_click_altar")

-- 图像查找器模块
local imageFinder = {}

-- 存储当前显示的所有边框
imageFinder.highlightBoxes = {}

-- 图片查找顺序定义
imageFinder.targetSequence = {
    "下个奖励",
}

local found = false

-- API请求函数 - 修改为支持回调
function imageFinder:findImage()
    print("查找祭坛选项")
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
                -- 检查请求状态
                if status == 200 then
                    -- 尝试解析JSON响应
                    local success, response = pcall(function() return hs.json.decode(body) end)
                    if success then
                        -- 检查是否成功找到图像
                        if response.status == "success" and response.count > 0 then
                            print("存在祭坛选项 开始请求选哪一个")
                            found = true
                            clickAltar.startSequentialSearch()
                            hs.timer.doAfter(4, function()
                                found = false
                            end)
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

-- 定义一个全局变量来跟踪查找状态
local isSearching = false
-- 存储计时器
local searchTimer = nil

-- 注册快捷键：` (反引号)
hs.hotkey.bind({}, "`", function()
    -- 如果当前正在查找，则停止查找
    if isSearching then
        -- 停止计时器
        if searchTimer then
            searchTimer:stop()
            searchTimer = nil
        end

        -- 更新状态
        isSearching = false

        -- 可选：显示通知告知用户已停止查找
        hs.alert.show("图像查找已停止", 2)
    else
        -- 如果当前没有查找，则开始查找

        -- 先立即执行一次查找
        imageFinder:findImage()

        -- 创建计时器，每1秒执行一次查找
        searchTimer = hs.timer.doEvery(1, function()
            if found then
                print("已经选择了，等待下一次判断")
                return
            end
            imageFinder:findImage()
        end)

        -- 更新状态
        isSearching = true

        -- 可选：显示通知告知用户已开始查找
        hs.alert.show("图像查找已开始", 2)
    end
end)

-- 初始化提示
hs.alert.show("增强版图像查找器已加载!\n按下 ` 按顺序查找图像", 2)

return imageFinder
