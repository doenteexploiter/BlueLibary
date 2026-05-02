--[[
    UI Library para Roblox Mobile - Versão COMPLETA
    Colocar em: ReplicatedStorage - UI_Library (ModuleScript)
]]

local UILibrary = {}
local players = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local starterGui = game:GetService("StarterGui")

-- Configurações da UI
local config = {
    mainColor = Color3.fromRGB(0, 150, 255),
    uiBackgroundAsset = "",
    uiTitle = "FUTURISTIC HUB",
    isOpen = true
}

-- Função para criar elementos UI
local function createFrame(parent, size, position, transparency, color)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = size
    frame.Position = position
    frame.BackgroundTransparency = transparency or 0.85
    frame.BackgroundColor3 = color or Color3.fromRGB(20, 20, 30)
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = frame
    corner.CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke")
    stroke.Parent = frame
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    
    return frame
end

local function createTextLabel(parent, text, size, position, color, textSize)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.Size = size
    label.Position = position
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = textSize or 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    return label
end

-- SISTEMA DE NOTIFICAÇÃO
local function sendNotification(title, text, duration, iconAsset)
    local notification = {
        Title = title or "Notificação",
        Text = text or "",
        Duration = duration or 3
    }
    if iconAsset and iconAsset ~= "" then
        notification.Icon = iconAsset
    end
    pcall(function()
        starterGui:SetCore("SendNotification", notification)
    end)
end

-- LABEL APENAS COM IMAGEM
local function createImageOnlyLabel(parent, imageAsset, size, position)
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Parent = parent
    imageLabel.Size = size
    imageLabel.Position = position
    imageLabel.BackgroundTransparency = 1
    imageLabel.Image = imageAsset
    imageLabel.ScaleType = Enum.ScaleType.Fit
    imageLabel.LayoutOrder = parent:GetChildren().Length
    
    local corner = Instance.new("UICorner")
    corner.Parent = imageLabel
    corner.CornerRadius = UDim.new(0, 12)
    
    return imageLabel
end

-- LABEL SIMPLES
local function createLabel(parent, text, size, position, textColor, textSize, textAlignment)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.Size = size
    label.Position = position
    label.Text = text
    label.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = textSize or 14
    label.TextXAlignment = textAlignment or Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.LayoutOrder = parent:GetChildren().Length
    return label
end

-- LABEL COM IMAGEM
local function createImageLabel(parent, text, imageAsset, imagePosition, size, position, textColor, textSize)
    local frame = createFrame(parent, size, position, 0.3)
    frame.LayoutOrder = parent:GetChildren().Length
    
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Parent = frame
    imageLabel.Size = UDim2.new(0, 40, 0, 40)
    imageLabel.Position = imagePosition or UDim2.new(0, 10, 0, 5)
    imageLabel.BackgroundTransparency = 1
    imageLabel.Image = imageAsset
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = frame
    textLabel.Size = UDim2.new(1, -60, 1, 0)
    textLabel.Position = UDim2.new(0, 60, 0, 0)
    textLabel.Text = text
    textLabel.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = textSize or 14
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    
    return {frame = frame, textLabel = textLabel, imageLabel = imageLabel}
end

-- BOTÃO FUNCIONAL
local function createButton(parent, text, size, position, color, callback)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.Size = size
    button.Position = position
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = color or config.mainColor
    button.BackgroundTransparency = 0.3
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.AutoButtonColor = false
    button.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.Parent = button
    corner.CornerRadius = UDim.new(0, 6)
    
    button.MouseButton1Click:Connect(function()
        if callback then
            tweenService:Create(button, TweenInfo.new(0.1), {BackgroundTransparency = 0.5}):Play()
            task.wait(0.1)
            tweenService:Create(button, TweenInfo.new(0.1), {BackgroundTransparency = 0.3}):Play()
            callback()
        end
    end)
    
    return button
end

-- TEXTBOX FUNCIONAL
local function createTextBox(parent, placeholder, size, position, callback)
    local frame = createFrame(parent, size, position, 0.3)
    local textBox = Instance.new("TextBox")
    textBox.Parent = frame
    textBox.Size = UDim2.new(1, -20, 1, -10)
    textBox.Position = UDim2.new(0, 10, 0, 5)
    textBox.PlaceholderText = placeholder
    textBox.Text = ""
    textBox.BackgroundTransparency = 1
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 14
    textBox.ClearTextOnFocus = false
    
    textBox.FocusLost:Connect(function()
        if callback and textBox.Text ~= "" then
            callback(textBox.Text)
        end
    end)
    
    return textBox
end

-- TOGGLE FUNCIONAL
local function createToggle(parent, text, size, position, defaultState, callback)
    local frame = createFrame(parent, size, position, 0.3)
    local label = createTextLabel(frame, text, UDim2.new(0.6, 0, 1, 0), UDim2.new(0, 10, 0, 0), nil, 12)
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Parent = frame
    toggleButton.Size = UDim2.new(0, 50, 0, 24)
    toggleButton.Position = UDim2.new(1, -60, 0, 10)
    toggleButton.BackgroundColor3 = defaultState and config.mainColor or Color3.fromRGB(80, 80, 80)
    toggleButton.BackgroundTransparency = 0.2
    toggleButton.Text = ""
    toggleButton.BorderSizePixel = 0
    toggleButton.AutoButtonColor = false
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.Parent = toggleButton
    toggleCorner.CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("TextButton")
    circle.Parent = toggleButton
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Position = defaultState and UDim2.new(1, -26, 0, 2) or UDim2.new(0, 4, 0, 2)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BackgroundTransparency = 0
    circle.Text = ""
    circle.BorderSizePixel = 0
    circle.AutoButtonColor = false
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.Parent = circle
    circleCorner.CornerRadius = UDim.new(1, 0)
    
    local state = defaultState or false
    
    local function updateToggle()
        local targetColor = state and config.mainColor or Color3.fromRGB(80, 80, 80)
        local targetPos = state and UDim2.new(1, -26, 0, 2) or UDim2.new(0, 4, 0, 2)
        tweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        tweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        if callback then callback(state) end
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
    end)
    
    return {setState = function(newState) state = newState updateToggle() end}
end

-- SLIDER CORRIGIDO
local function createSlider(parent, text, min, max, defaultVal, size, position, callback)
    local frame = createFrame(parent, size or UDim2.new(1, 0, 0, 85), position or UDim2.new(0, 0, 0, 0), 0.3)
    frame.LayoutOrder = parent:GetChildren().Length
    
    local label = createTextLabel(frame, text, UDim2.new(0.7, 0, 0, 30), UDim2.new(0, 10, 0, 0), nil, 12)
    
    local valueLabel = createTextLabel(frame, tostring(defaultVal), UDim2.new(0.3, 0, 0, 30), UDim2.new(0.7, 0, 0, 0), nil, 12)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Parent = frame
    sliderBg.Size = UDim2.new(1, -20, 0, 8)
    sliderBg.Position = UDim2.new(0, 10, 0, 45)
    sliderBg.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    sliderBg.BackgroundTransparency = 0.3
    sliderBg.BorderSizePixel = 0
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.Parent = sliderBg
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Parent = sliderBg
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = config.mainColor
    sliderFill.BackgroundTransparency = 0.2
    sliderFill.BorderSizePixel = 0
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.Parent = sliderFill
    fillCorner.CornerRadius = UDim.new(1, 0)
    
    local value = math.clamp(defaultVal, min, max)
    local dragging = false
    
    local sliderHandle = Instance.new("TextButton")
    sliderHandle.Parent = frame
    sliderHandle.Size = UDim2.new(0, 28, 0, 28)
    sliderHandle.Position = UDim2.new(0, 10, 0, 35)
    sliderHandle.BackgroundColor3 = config.mainColor
    sliderHandle.BackgroundTransparency = 0
    sliderHandle.Text = "◉"
    sliderHandle.TextColor3 = Color3.fromRGB(255, 255, 255)
    sliderHandle.TextSize = 18
    sliderHandle.BorderSizePixel = 0
    sliderHandle.AutoButtonColor = false
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.Parent = sliderHandle
    handleCorner.CornerRadius = UDim.new(1, 0)
    
    local function updateSliderFromInput(input)
        if not sliderBg or not sliderBg.AbsoluteSize then return end
        if not sliderBg.AbsoluteSize.X or sliderBg.AbsoluteSize.X == 0 then return end
        
        local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * relativeX)
        valueLabel.Text = tostring(value)
        
        local fillPercent = (value - min) / (max - min)
        sliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
        
        local newHandleX = 10 + (sliderBg.AbsoluteSize.X * fillPercent) - 14
        sliderHandle.Position = UDim2.new(0, newHandleX, 0, 35)
        
        if callback then callback(value) end
    end
    
    sliderHandle.MouseButton1Down:Connect(function() dragging = true end)
    sliderHandle.MouseButton1Up:Connect(function() dragging = false end)
    
    userInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSliderFromInput(input)
        end
    end)
    
    userInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            updateSliderFromInput(input)
        end
    end)
    
    task.wait(0.1)
    if sliderBg and sliderBg.AbsoluteSize and sliderBg.AbsoluteSize.X then
        local initialPercent = (value - min) / (max - min)
        sliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
        local newHandleX = 10 + (sliderBg.AbsoluteSize.X * initialPercent) - 14
        sliderHandle.Position = UDim2.new(0, newHandleX, 0, 35)
    end
    
    return {
        getValue = function() return value end,
        setValue = function(newValue) 
            value = math.clamp(newValue, min, max)
            valueLabel.Text = tostring(value)
            local fillPercent = (value - min) / (max - min)
            sliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
            if sliderBg and sliderBg.AbsoluteSize and sliderBg.AbsoluteSize.X then
                local newHandleX = 10 + (sliderBg.AbsoluteSize.X * fillPercent) - 14
                sliderHandle.Position = UDim2.new(0, newHandleX, 0, 35)
            end
            if callback then callback(value) end
        end
    }
end

-- DROPDOWN FUNCIONAL
local function createDropdown(parent, items, position, callback)
    local frame = createFrame(parent, UDim2.new(1, 0, 0, 45), position, 0.3)
    frame.LayoutOrder = parent:GetChildren().Length
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Parent = frame
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.Text = items[1] or "Selecione"
    dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownButton.BackgroundColor3 = config.mainColor
    dropdownButton.BackgroundTransparency = 0.2
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.TextSize = 14
    dropdownButton.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.Parent = dropdownButton
    btnCorner.CornerRadius = UDim.new(0, 6)
    
    local dropdownFrame = createFrame(parent, UDim2.new(1, 0, 0, 150), position + UDim2.new(0, 0, 0, 50), 0.3)
    dropdownFrame.Visible = false
    dropdownFrame.LayoutOrder = parent:GetChildren().Length
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Parent = dropdownFrame
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 4
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = scrollFrame
    listLayout.Padding = UDim.new(0, 5)
    
    local selected = items[1]
    
    for i, item in ipairs(items) do
        local itemButton = Instance.new("TextButton")
        itemButton.Parent = scrollFrame
        itemButton.Size = UDim2.new(1, -10, 0, 35)
        itemButton.Position = UDim2.new(0, 5, 0, (i-1)*40)
        itemButton.Text = item
        itemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        itemButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        itemButton.BackgroundTransparency = 0.2
        itemButton.Font = Enum.Font.Gotham
        itemButton.TextSize = 14
        itemButton.BorderSizePixel = 0
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.Parent = itemButton
        itemCorner.CornerRadius = UDim.new(0, 4)
        
        itemButton.MouseButton1Click:Connect(function()
            selected = item
            dropdownButton.Text = item
            dropdownFrame.Visible = false
            if callback then callback(item) end
        end)
    end
    
    local canvasHeight = #items * 41
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)
    
    dropdownButton.MouseButton1Click:Connect(function()
        dropdownFrame.Visible = not dropdownFrame.Visible
    end)
    
    return {getSelected = function() return selected end}
end

-- PLAYER DROPDOWN FUNCIONAL
local function createPlayerDropdown(parent, position, callback)
    local frame = createFrame(parent, UDim2.new(1, 0, 0, 180), position, 0.3)
    frame.LayoutOrder = parent:GetChildren().Length
    
    local titleLabel = createTextLabel(frame, "PLAYERS ONLINE", UDim2.new(1, 0, 0, 30), UDim2.new(0, 10, 0, 0), nil, 12)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Parent = frame
    scrollFrame.Size = UDim2.new(1, -10, 1, -40)
    scrollFrame.Position = UDim2.new(0, 5, 0, 35)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 4
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = scrollFrame
    listLayout.Padding = UDim.new(0, 5)
    
    local function updatePlayerList()
        for _, v in pairs(scrollFrame:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end
        
        local playerList = players:GetPlayers()
        for i, plr in ipairs(playerList) do
            local playerButton = Instance.new("TextButton")
            playerButton.Parent = scrollFrame
            playerButton.Size = UDim2.new(1, -10, 0, 35)
            playerButton.Position = UDim2.new(0, 5, 0, (i-1)*40)
            playerButton.Text = "👤 " .. plr.Name
            playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            playerButton.BackgroundTransparency = 0.2
            playerButton.Font = Enum.Font.Gotham
            playerButton.TextSize = 14
            playerButton.TextXAlignment = Enum.TextXAlignment.Left
            playerButton.BorderSizePixel = 0
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.Parent = playerButton
            btnCorner.CornerRadius = UDim.new(0, 4)
            
            playerButton.MouseButton1Click:Connect(function()
                if callback then callback(plr) end
            end)
        end
        
        local canvasHeight = #playerList * 41 + 10
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)
    end
    
    players.PlayerAdded:Connect(updatePlayerList)
    players.PlayerRemoving:Connect(updatePlayerList)
    updatePlayerList()
    
    return {update = updatePlayerList}
end

-- Função principal para criar a UI
function UILibrary:CreateUI(player)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player.PlayerGui
    screenGui.Name = "FuturisticUI"
    screenGui.ResetOnSpawn = false
    
    -- Tamanho reduzido para mobile
    local uiWidth = 650
    local uiHeight = 450
    
    -- Fundo da UI (CORRIGIDO - Agora funciona!)
    local uiBackground = Instance.new("ImageLabel")
    uiBackground.Parent = screenGui
    uiBackground.Size = UDim2.new(0, uiWidth, 0, uiHeight)
    uiBackground.Position = UDim2.new(0.5, -uiWidth/2, 0.5, -uiHeight/2)
    uiBackground.BackgroundTransparency = 1
    uiBackground.Image = config.uiBackgroundAsset ~= "" and config.uiBackgroundAsset or ""
    uiBackground.ImageTransparency = 0.3
    uiBackground.Visible = true
    uiBackground.ScaleType = Enum.ScaleType.Fit
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.Parent = uiBackground
    bgCorner.CornerRadius = UDim.new(0, 12)
    
    -- Frame principal
    local mainFrame = createFrame(screenGui, UDim2.new(0, uiWidth, 0, uiHeight), UDim2.new(0.5, -uiWidth/2, 0.5, -uiHeight/2), 0.88, Color3.fromRGB(20, 20, 30))
    mainFrame.Visible = true
    
    -- Barra de título
    local titleBar = createFrame(mainFrame, UDim2.new(1, 0, 0, 35), UDim2.new(0, 0, 0, 0), 0.95, Color3.fromRGB(30, 30, 40))
    
    local titleText = createTextLabel(titleBar, config.uiTitle, UDim2.new(0.5, 0, 1, 0), UDim2.new(0, 10, 0, 0), nil, 16)
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = titleBar
    closeBtn.Size = UDim2.new(0, 35, 1, 0)
    closeBtn.Position = UDim2.new(1, -40, 0, 0)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.TextSize = 20
    closeBtn.BorderSizePixel = 0
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeBtn
    closeCorner.CornerRadius = UDim.new(0, 6)
    
    local function toggleUI()
        config.isOpen = not config.isOpen
        mainFrame.Visible = config.isOpen
        uiBackground.Visible = config.isOpen
    end
    
    closeBtn.MouseButton1Click:Connect(toggleUI)
    
    -- Chat commands
    local function onChatMessage(message)
        if message:lower() == "!tool" then
            if not config.isOpen then
                config.isOpen = true
                mainFrame.Visible = true
                uiBackground.Visible = true
                sendNotification("UI Aberta", "Interface ativada com sucesso!", 2)
            end
        elseif message:lower() == "!close" then
            if config.isOpen then
                config.isOpen = false
                mainFrame.Visible = false
                uiBackground.Visible = false
                sendNotification("UI Fechada", "Interface desativada!", 2)
            end
        end
    end
    
    pcall(function()
        local playerChatted = player.Chatted
        if playerChatted then
            playerChatted:Connect(onChatMessage)
        end
    end)
    
    -- Sistema de arrastar
    local uiDragging = false
    local uiDragStart = nil
    local uiStartPos = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            uiDragging = true
            uiDragStart = input.Position
            uiStartPos = mainFrame.Position
        end
    end)
    
    userInputService.InputChanged:Connect(function(input)
        if uiDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - uiDragStart
            local newPos = UDim2.new(uiStartPos.X.Scale, uiStartPos.X.Offset + delta.X,
                                    uiStartPos.Y.Scale, uiStartPos.Y.Offset + delta.Y)
            mainFrame.Position = newPos
            uiBackground.Position = newPos
        end
    end)
    
    userInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            uiDragging = false
        end
    end)
    
    -- Tabs laterais
    local tabPanel = createFrame(mainFrame, UDim2.new(0, 130, 1, -35), UDim2.new(0, 0, 0, 35), 0.92, Color3.fromRGB(15, 15, 25))
    local contentFrame = createFrame(mainFrame, UDim2.new(1, -140, 1, -45), UDim2.new(0, 140, 0, 45), 0.9, Color3.fromRGB(25, 25, 35))
    
    local tabs = {}
    local activeTab = nil
    local tabButtons = {}
    
    function self:AddTab(name, icon)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Parent = tabPanel
        tabBtn.Size = UDim2.new(1, -20, 0, 40)
        tabBtn.Position = UDim2.new(0, 10, 0, #tabs * 45 + 10)
        tabBtn.Text = icon and icon .. " " .. name or name
        tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        tabBtn.BackgroundTransparency = 0.5
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.TextSize = 13
        tabBtn.BorderSizePixel = 0
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.Parent = tabBtn
        btnCorner.CornerRadius = UDim.new(0, 6)
        
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Parent = contentFrame
        tabContent.Size = UDim2.new(1, -20, 1, -20)
        tabContent.Position = UDim2.new(0, 10, 0, 10)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = config.mainColor
        
        local layout = Instance.new("UIListLayout")
        layout.Parent = tabContent
        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        
        tabBtn.MouseButton1Click:Connect(function()
            if activeTab then activeTab.Visible = false end
            for _, btn in pairs(tabButtons) do
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            tabContent.Visible = true
            activeTab = tabContent
            tabBtn.TextColor3 = config.mainColor
        end)
        
        table.insert(tabs, {button = tabBtn, content = tabContent})
        table.insert(tabButtons, tabBtn)
        
        if #tabs == 1 then
            tabContent.Visible = true
            activeTab = tabContent
            tabBtn.TextColor3 = config.mainColor
        end
        
        return tabContent
    end
    
    -- MÉTODOS PÚBLICOS
    
    function self:SendNotification(title, text, duration, iconAsset)
        sendNotification(title, text, duration, iconAsset)
    end
    
    function self:CreateImageOnly(parent, imageAsset, size)
        return createImageOnlyLabel(parent, imageAsset, size or UDim2.new(0, 80, 0, 80), UDim2.new(0, 0, 0, 0))
    end
    
    function self:CreateLabel(parent, text, size, textColor, textSize, textAlignment)
        return createLabel(parent, text, size or UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), textColor, textSize, textAlignment)
    end
    
    function self:CreateImageLabel(parent, text, imageAsset, size, textColor, textSize)
        return createImageLabel(parent, text, imageAsset, UDim2.new(0, 10, 0, 5), size or UDim2.new(1, 0, 0, 50), UDim2.new(0, 0, 0, 0), textColor, textSize)
    end
    
    function self:CreateButton(parent, text, size, color, callback)
        local btn = createButton(parent, text, size or UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), color, callback)
        btn.LayoutOrder = parent:GetChildren().Length
        return btn
    end
    
    function self:CreateTextBox(parent, placeholder, size, callback)
        local box = createTextBox(parent, placeholder, size or UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 0), callback)
        box.LayoutOrder = parent:GetChildren().Length
        return box
    end
    
    function self:CreateToggle(parent, text, defaultState, callback)
        local toggle = createToggle(parent, text, UDim2.new(1, 0, 0, 50), UDim2.new(0, 0, 0, 0), defaultState, callback)
        toggle.LayoutOrder = parent:GetChildren().Length
        return toggle
    end
    
    function self:CreateSlider(parent, text, min, max, defaultVal, size, callback)
        local slider = createSlider(parent, text, min, max, defaultVal, size or UDim2.new(1, 0, 0, 85), UDim2.new(0, 0, 0, 0), callback)
        slider.LayoutOrder = parent:GetChildren().Length
        return slider
    end
    
    function self:CreateDropdown(parent, items, callback)
        return createDropdown(parent, items, UDim2.new(0, 0, 0, 0), callback)
    end
    
    function self:CreatePlayerDropdown(parent, callback)
        return createPlayerDropdown(parent, UDim2.new(0, 0, 0, 0), callback)
    end
    
    function self:CreateDiscordButton(parent, discordLink)
        local btn = self:CreateButton(parent, "DISCORD", UDim2.new(0.48, 0, 0, 45), Color3.fromRGB(88, 101, 242), function()
            if discordLink then
                setclipboard(discordLink)
                sendNotification("Link Copiado", "Link do Discord copiado!", 2, "rbxassetid://136489865028091")
            end
        end)
        
        local logo = Instance.new("ImageLabel")
        logo.Parent = btn
        logo.Size = UDim2.new(0, 25, 0, 25)
        logo.Position = UDim2.new(1, -35, 0, 10)
        logo.BackgroundTransparency = 1
        logo.Image = "rbxassetid://136489865028091"
        
        return btn
    end
    
    function self:CreateYouTubeButton(parent, youtubeLink)
        local btn = self:CreateButton(parent, "YOUTUBE", UDim2.new(0.48, 0, 0, 45), Color3.fromRGB(255, 0, 0), function()
            if youtubeLink then
                setclipboard(youtubeLink)
                sendNotification("Link Copiado", "Link do YouTube copiado!", 2, "rbxassetid://89933784907487")
            end
        end)
        
        local logo = Instance.new("ImageLabel")
        logo.Parent = btn
        logo.Size = UDim2.new(0, 25, 0, 25)
        logo.Position = UDim2.new(1, -35, 0, 10)
        logo.BackgroundTransparency = 1
        logo.Image = "rbxassetid://89933784907487"
        
        return btn
    end
    
    function self:CreatePlayerProfile(parent)
        local frame = createFrame(parent, UDim2.new(1, 0, 0, 120), UDim2.new(0, 0, 0, 0), 0.3)
        frame.LayoutOrder = parent:GetChildren().Length
        
        local avatarImage = Instance.new("ImageLabel")
        avatarImage.Parent = frame
        avatarImage.Size = UDim2.new(0, 60, 0, 60)
        avatarImage.Position = UDim2.new(0, 15, 0, 10)
        avatarImage.BackgroundTransparency = 1
        avatarImage.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
        
        local avatarCorner = Instance.new("UICorner")
        avatarCorner.Parent = avatarImage
        avatarCorner.CornerRadius = UDim.new(1, 0)
        
        local playerName = createTextLabel(frame, player.Name, UDim2.new(1, -90, 0, 35), UDim2.new(0, 90, 0, 15), nil, 16)
        
        local statusText = createTextLabel(frame, "● ONLINE", UDim2.new(1, -90, 0, 25), UDim2.new(0, 90, 0, 55), Color3.fromRGB(0, 255, 0), 11)
        
        local playerId = createTextLabel(frame, "ID: " .. player.UserId, UDim2.new(1, -90, 0, 25), UDim2.new(0, 90, 0, 80), nil, 10)
        
        local function updateAvatar()
            local success, headshot = pcall(function()
                return players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            end)
            if success and headshot then
                avatarImage.Image = headshot
            end
        end
        
        updateAvatar()
        
        return {updateAvatar = updateAvatar}
    end
    
    function self:CreateLogChat(parent)
        local frame = createFrame(parent, UDim2.new(1, 0, 0, 180), UDim2.new(0, 0, 0, 0), 0.3)
        frame.LayoutOrder = parent:GetChildren().Length
        
        local titleLabel = createTextLabel(frame, "CHAT LOG", UDim2.new(1, 0, 0, 30), UDim2.new(0, 10, 0, 0), nil, 12)
        titleLabel.TextXAlignment = Enum.TextXAlignment.Center
        
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Parent = frame
        scrollFrame.Size = UDim2.new(1, -10, 1, -40)
        scrollFrame.Position = UDim2.new(0, 5, 0, 35)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.ScrollBarThickness = 4
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Parent = scrollFrame
        listLayout.Padding = UDim.new(0, 5)
        
        local logs = {}
        
        function self:AddLog(message)
            local logLabel = createTextLabel(scrollFrame, "> " .. message, UDim2.new(1, -10, 0, 22), UDim2.new(0, 5, 0, #logs * 27), Color3.fromRGB(200, 200, 200), 10)
            logLabel.TextXAlignment = Enum.TextXAlignment.Left
            table.insert(logs, logLabel)
            
            if #logs > 30 then
                logs[1]:Destroy()
                table.remove(logs, 1)
            end
            
            for i, log in ipairs(logs) do
                log.Position = UDim2.new(0, 5, 0, (i-1) * 27)
            end
            
            local canvasHeight = #logs * 27 + 10
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)
            scrollFrame.CanvasPosition = Vector2.new(0, canvasHeight)
        end
        
        return {addLog = self.AddLog}
    end
    
    -- CONFIGURAÇÕES
    function self:SetMainColor(color)
        config.mainColor = color
        if titleBar then titleBar.BackgroundColor3 = color end
        if titleText then titleText.TextColor3 = color end
    end
    
    function self:SetUITitle(title)
        config.uiTitle = title
        if titleText then titleText.Text = title end
    end
    
    function self:SetUIBackgroundAsset(assetId)
        config.uiBackgroundAsset = assetId
        if uiBackground then 
            uiBackground.Image = assetId
        end
    end
    
    return self
end

return UILibrary
